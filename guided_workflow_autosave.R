# =============================================================================
# Guided Workflow - Smart Autosave System
# Extracted from guided_workflow.R for maintainability
# =============================================================================
# Contains:
#   - init_workflow_autosave()  - Initializes autosave observers and session restore
#     - compute_state_hash()    - Hash computation for change detection
#     - perform_smart_autosave() - Smart autosave with change detection
#     - Debounced autosave observer
#     - State hash watcher (throttled)
#     - Session restore from localStorage
#     - Restore confirmation dialog handlers
# =============================================================================

#' Initialize the smart autosave system for the guided workflow
#'
#' Sets up autosave observers, hash-based change detection, and session restore
#' from localStorage. Must be called inside moduleServer() with local = TRUE.
#' Enhanced with mutex locking to prevent race conditions (Issue #5 fix).
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param workflow_state reactiveVal holding the workflow state
#' @return list with autosave-related reactive values (last_saved_hash, autosave_enabled)
init_workflow_autosave <- function(input, output, session, workflow_state) {

  # Get constants (with fallbacks)
  lock_timeout_ms <- if (exists("AUTOSAVE_LOCK_TIMEOUT_MS")) AUTOSAVE_LOCK_TIMEOUT_MS else 10000
  min_interval_ms <- if (exists("AUTOSAVE_MIN_INTERVAL_MS")) AUTOSAVE_MIN_INTERVAL_MS else 2000

  # Reactive values for autosave
  last_saved_hash <- reactiveVal(NULL)
  debounce_timer <- reactiveVal(NULL)
  autosave_enabled <- reactiveVal(TRUE)

  # AUTOSAVE LOCK MECHANISM (Issue #5 fix - prevent race conditions)
  # Store lock state in session$userData for cleanup on session end
  if (is.null(session$userData)) {
    session$userData <- new.env()
  }
  session$userData$autosave_lock <- FALSE
  session$userData$autosave_lock_time <- NULL
  session$userData$last_autosave_time <- NULL

  #' Acquire autosave lock with timeout
  #' @return TRUE if lock acquired, FALSE if already locked
  acquire_autosave_lock <- function() {
    # Check if lock is held
    if (isTRUE(session$userData$autosave_lock)) {
      # Check if lock has timed out (stale lock protection)
      if (!is.null(session$userData$autosave_lock_time)) {
        lock_age_ms <- as.numeric(difftime(Sys.time(), session$userData$autosave_lock_time, units = "secs")) * 1000
        if (lock_age_ms > lock_timeout_ms) {
          # Lock timed out - release and reacquire
          log_warning(paste("Autosave lock timed out after", round(lock_age_ms), "ms - releasing stale lock"))
          session$userData$autosave_lock <- FALSE
        } else {
          # Lock is still valid
          return(FALSE)
        }
      }
    }

    # Check minimum interval since last save
    if (!is.null(session$userData$last_autosave_time)) {
      time_since_last_ms <- as.numeric(difftime(Sys.time(), session$userData$last_autosave_time, units = "secs")) * 1000
      if (time_since_last_ms < min_interval_ms) {
        log_debug(paste("Autosave skipped - too soon since last save (", round(time_since_last_ms), "ms)"))
        return(FALSE)
      }
    }

    # Acquire lock
    session$userData$autosave_lock <- TRUE
    session$userData$autosave_lock_time <- Sys.time()
    return(TRUE)
  }

  #' Release autosave lock
  release_autosave_lock <- function() {
    session$userData$autosave_lock <- FALSE
    session$userData$autosave_lock_time <- NULL
  }

  # Helper: Compute state hash for change detection
  compute_state_hash <- function(state) {
    tryCatch({
      if (!requireNamespace("digest", quietly = TRUE)) {
        return(NULL)
      }
      if (!requireNamespace("jsonlite", quietly = TRUE)) {
        return(NULL)
      }

      # Extract only the parts that matter for autosave
      hashable_state <- list(
        current_step = state$current_step,
        completed_steps = state$completed_steps,
        project_data = state$project_data,
        validation_status = state$validation_status,
        workflow_complete = state$workflow_complete
      )

      json_state <- jsonlite::toJSON(hashable_state, auto_unbox = TRUE)
      hash_value <- digest::digest(json_state, algo = "md5")

      return(hash_value)
    }, error = function(e) {
      log_warning(paste("Hash computation failed:", e$message))
      return(NULL)
    })
  }

  # Helper: Perform smart autosave with locking (Issue #5 fix)
  perform_smart_autosave <- function() {
    isolate({
      state <- workflow_state()
      req(state)
      req(autosave_enabled())

      # Only autosave if we're past step 1
      if (state$current_step <= 1) {
        return(NULL)
      }

      # TRY TO ACQUIRE LOCK (Issue #5 fix - prevent race conditions)
      if (!acquire_autosave_lock()) {
        log_debug("Autosave skipped - lock held by another operation")
        return(NULL)
      }

      # Ensure lock is released on exit (even if error occurs)
      on.exit(release_autosave_lock(), add = TRUE)

      current_hash <- compute_state_hash(state)

      # Only save if state actually changed
      if (!is.null(current_hash) &&
          (is.null(last_saved_hash()) || current_hash != last_saved_hash())) {

        tryCatch({
          if (requireNamespace("jsonlite", quietly = TRUE)) {
            state_json <- jsonlite::toJSON(state, auto_unbox = TRUE)
            timestamp <- format(Sys.time(), "%H:%M:%S")

            session$sendCustomMessage("smartAutosave", list(
              state = as.character(state_json),
              timestamp = timestamp,
              hash = current_hash
            ))

            last_saved_hash(current_hash)
            session$userData$last_autosave_time <- Sys.time()  # Track last save time
            log_debug(paste("Autosaved at", timestamp, "(hash:", substr(current_hash, 1, 8), ")"))
          }
        }, error = function(e) {
          log_error(paste("Autosave failed:", e$message))
        })
      }
    })
  }

  # Helper: Trigger autosave with debouncing (no nested observers)
  trigger_autosave_debounced <- function(delay_ms = 3000) {
    debounce_timer(Sys.time())
  }

  # Single observer for debounced autosave (avoids observer leak)
  observe({
    timer_value <- debounce_timer()
    req(timer_value)
    invalidateLater(3000, session)

    time_diff <- difftime(Sys.time(), timer_value, units = "secs")
    if (as.numeric(time_diff) >= 3) {
      perform_smart_autosave()
      debounce_timer(NULL)
    }
  }, priority = -1)

  # Watch for workflow state changes and trigger autosave
  # Throttled to 500ms - prevents excessive autosave triggers during rapid state updates
  # (e.g., adding multiple items quickly). The actual save is further debounced to 3000ms
  # by trigger_autosave_debounced, so this throttle just limits how often we check.
  autosave_state_hash_raw <- reactive({
    state <- workflow_state()
    req(state)
    req(autosave_enabled())
    compute_state_hash(state)
  })
  autosave_state_hash_throttled <- autosave_state_hash_raw %>% throttle(500)

  observe({
    hash <- autosave_state_hash_throttled()
    req(hash)

    # Trigger debounced autosave on any state change
    trigger_autosave_debounced(delay_ms = 3000)
  }, priority = -1)  # Low priority to run after other state updates

  # =============================================================================
  # SESSION RESTORE
  # =============================================================================

  # On session start, check for autosaved state
  observeEvent(session$clientData$url_search, {
    if (requireNamespace("jsonlite", quietly = TRUE)) {
      session$sendCustomMessage("loadFromLocalStorage", list(
        key = "bowtie_workflow_autosave",
        inputId = "restored_workflow_state"
      ))
    }
  }, once = TRUE, priority = 100)  # High priority to run early

  # Handle restored state
  observeEvent(input$restored_workflow_state, {
    req(input$restored_workflow_state)

    tryCatch({
      if (requireNamespace("jsonlite", quietly = TRUE)) {
        restored <- jsonlite::fromJSON(input$restored_workflow_state, simplifyVector = FALSE)

        # Validate restored state
        if (is.list(restored) && "current_step" %in% names(restored)) {
          # Show restore dialog
          showModal(modalDialog(
            title = tagList(icon("history"), " Restore Previous Session?"),
            tagList(
              p(HTML(paste0(
                "A previous workflow session was found.<br>",
                "<strong>Step ", restored$current_step, " of ", restored$total_steps, "</strong>",
                if (!is.null(restored$project_data$project_name) && nchar(restored$project_data$project_name) > 0) {
                  paste0("<br>Project: <em>", restored$project_data$project_name, "</em>")
                } else { "" }
              ))),
              hr(),
              p("Would you like to restore this session or start fresh?")
            ),
            footer = tagList(
              actionButton("restore_yes", "Restore Session", class = "btn-primary", icon = icon("undo")),
              actionButton("restore_no", "Start Fresh", class = "btn-secondary", icon = icon("file"))
            ),
            size = "m",
            easyClose = FALSE
          ))
        }
      }
    }, error = function(e) {
      log_warning(paste("Error processing restored state:", e$message))
    })
  }, once = TRUE, ignoreNULL = TRUE)

  # Handle restore confirmation
  observeEvent(input$restore_yes, {
    req(input$restored_workflow_state)

    tryCatch({
      if (requireNamespace("jsonlite", quietly = TRUE)) {
        restored <- jsonlite::fromJSON(input$restored_workflow_state, simplifyVector = FALSE)

        # Convert list back to proper structure
        restored_state <- init_workflow_state()  # Start with default

        # Merge restored data
        for (name in names(restored)) {
          if (name %in% names(restored_state)) {
            restored_state[[name]] <- restored[[name]]
          }
        }

        # Update workflow state
        workflow_state(restored_state)

        # Update hash to current state
        last_saved_hash(compute_state_hash(restored_state))

        notify_success(paste("Session restored successfully! Resuming at Step", restored_state$current_step), duration = 5)

        log_success("Workflow session restored from autosave")
      }
    }, error = function(e) {
      notify_error(paste("Error restoring session:", e$message), duration = 10)
      log_error(paste("Error restoring session:", e$message))
    })

    removeModal()
  })

  # Handle start fresh
  observeEvent(input$restore_no, {
    # Clear autosave from localStorage
    session$sendCustomMessage("clearAutosave", list())

    notify_info("Starting fresh workflow session", duration = 3)

    removeModal()
  })

  # Return autosave-related values for use by other modules
  list(
    last_saved_hash = last_saved_hash,
    autosave_enabled = autosave_enabled,
    compute_state_hash = compute_state_hash
  )
}
