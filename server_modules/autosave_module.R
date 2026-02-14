# =============================================================================
# Autosave Module
# =============================================================================
# Purpose: Automatic saving of workflow state and data
# Dependencies: shiny, jsonlite
# =============================================================================

#' Initialize autosave module server logic
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param getCurrentData Reactive function to get current data
#' @param lang Reactive language value
#' @return List containing autosave reactive values
#' @export
autosave_module_server <- function(input, output, session, getCurrentData, lang = reactive("en")) {

  # Reactive values for autosave state
  lastAutosaveTime <- reactiveVal(NULL)
  autosaveVersion <- reactiveVal(0)

  # =============================================================================
  # MANUAL SAVE NOW
  # =============================================================================
  observeEvent(input$autosave_now, {
    req(input$autosave_enabled)

    tryCatch({
      # Collect all state to save
      save_data <- list(
        timestamp = Sys.time(),
        version = autosaveVersion() + 1,
        settings = list(
          language = lang(),
          theme = input$theme_preset,
          ai_enabled = isTRUE(input$ai_suggestions_enabled),
          ai_methods = list(
            semantic = isTRUE(input$ai_method_semantic),
            keyword = isTRUE(input$ai_method_keyword),
            causal = isTRUE(input$ai_method_causal)
          ),
          ai_max_suggestions = input$ai_max_suggestions
        ),
        autosave_config = list(
          interval = input$autosave_interval,
          versions = input$autosave_versions,
          location = input$autosave_location,
          notify = isTRUE(input$autosave_notify),
          autoload = isTRUE(input$autosave_autoload),
          include_data = isTRUE(input$autosave_include_data)
        )
      )

      # Include data if requested
      if (isTRUE(input$autosave_include_data)) {
        data <- getCurrentData()
        if (!is.null(data) && nrow(data) > 0) {
          save_data$data <- data
        }
      }

      # Convert to JSON
      save_json <- jsonlite::toJSON(save_data, pretty = TRUE, auto_unbox = TRUE)

      # Save based on location preference
      location <- input$autosave_location
      if (is.null(location)) location <- "browser"
      
      # Flag to track if save was completed via local folder
      local_save_completed <- FALSE
      
      # Check if user has selected local folder storage mode
      storage_mode <- input$storage_mode
      if (!is.null(storage_mode) && storage_mode == "local") {
        # Save to local folder instead
        local_path <- input$local_folder_path
        if (!is.null(local_path) && nchar(local_path) > 0 && dir.exists(local_path)) {
          tryCatch({
            filename <- sprintf("bowtie_autosave_%s_v%d.rds",
                               format(Sys.time(), "%Y%m%d_%H%M%S"),
                               autosaveVersion() + 1)
            filepath <- file.path(local_path, filename)
            saveRDS(save_data, filepath)
            
            # Update state
            autosaveVersion(autosaveVersion() + 1)
            lastAutosaveTime(Sys.time())
            
            # Show notification if enabled
            if (isTRUE(input$autosave_notify)) {
              notify_success(sprintf("✅ Autosaved to local folder (v%d)", autosaveVersion()), duration = 3)
            }
            
            log_debug(paste("Local autosave completed. Version:", autosaveVersion()))
            local_save_completed <- TRUE  # Mark as completed, skip browser/file saves
            
          }, error = function(e) {
            notify_warning(paste("Local autosave failed, falling back to browser:", e$message))
            # Fall through to browser save
          })
        }
      }

      # Skip browser/file saves if local folder save was completed
      if (local_save_completed) {
        return()  # Now we can safely return from the outer tryCatch
      }
      
      # Browser storage (localStorage)
      if (location %in% c("browser", "both")) {
        # Generate JavaScript to save to localStorage
        js_code <- sprintf("
          try {
            // Manage version history
            var maxVersions = %d;
            var currentVersion = %d;
            var saveData = %s;

            // Save current version
            localStorage.setItem('bowtie_autosave_current', JSON.stringify(saveData));

            // Add to version history
            var versionKey = 'bowtie_autosave_v' + currentVersion;
            localStorage.setItem(versionKey, JSON.stringify(saveData));

            // Clean old versions
            for (var i = 1; i <= currentVersion - maxVersions; i++) {
              localStorage.removeItem('bowtie_autosave_v' + i);
            }

            // Update metadata
            var metadata = {
              lastSave: new Date().toISOString(),
              currentVersion: currentVersion,
              totalVersions: Math.min(currentVersion, maxVersions)
            };
            localStorage.setItem('bowtie_autosave_metadata', JSON.stringify(metadata));

            // Update UI timestamp
            var timestamp = new Date().toLocaleString();
            $('#last_autosave_time').text(timestamp);

          } catch(e) {
            console.error('Autosave failed:', e);
          }
        ",
          input$autosave_versions,
          autosaveVersion() + 1,
          save_json
        )

        session$sendCustomMessage("eval", list(code = js_code))
      }

      # File download
      if (location %in% c("file", "both")) {
        # Create filename with timestamp
        filename <- sprintf("bowtie_autosave_%s_v%d.json",
                           format(Sys.time(), "%Y%m%d_%H%M%S"),
                           autosaveVersion() + 1)

        # Trigger download
        session$sendCustomMessage("downloadData", list(
          filename = filename,
          content = save_json,
          contentType = "application/json"
        ))
      }

      # Update state
      autosaveVersion(autosaveVersion() + 1)
      lastAutosaveTime(Sys.time())

      # Show notification if enabled
      if (isTRUE(input$autosave_notify)) {
        notify_success(sprintf("✅ Autosaved at %s (v%d)",
                 format(Sys.time(), "%H:%M:%S"),
                 autosaveVersion()), duration = 3)
      }

      log_debug(paste("Manual autosave completed. Version:", autosaveVersion()))

    }, error = function(e) {
      notify_error(paste("Autosave failed:", e$message), duration = 5)
      log_error(paste("Autosave error:", e$message))
    })
  })

  # =============================================================================
  # CLEAR ALL SAVES
  # =============================================================================
  observeEvent(input$autosave_clear, {
    # Show confirmation modal
    showModal(modalDialog(
      title = tagList(icon("exclamation-triangle"), " Delete All Autosaves?"),
      sprintf("This will remove all %d saved versions.", autosaveVersion()),
      tags$p(class = "text-danger", "⚠️ This action cannot be undone!"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("autosave_clear_confirm",
                    "Delete All Saves",
                    class = "btn-danger",
                    icon = icon("trash"))
      ),
      easyClose = TRUE
    ))
  })

  # Confirm clear
  observeEvent(input$autosave_clear_confirm, {
    tryCatch({
      # Clear localStorage via JavaScript
      js_code <- "
        try {
          // Clear all autosave data
          var keys = Object.keys(localStorage);
          for (var i = 0; i < keys.length; i++) {
            if (keys[i].startsWith('bowtie_autosave_')) {
              localStorage.removeItem(keys[i]);
            }
          }

          // Reset UI
          $('#last_autosave_time').text('Never');

          console.log('All autosaves cleared');
        } catch(e) {
          console.error('Clear autosaves failed:', e);
        }
      "

      session$sendCustomMessage("eval", list(code = js_code))

      # Reset state
      autosaveVersion(0)
      lastAutosaveTime(NULL)

      removeModal()

      notify_warning("🗑️ All autosaves cleared", duration = 3)

      log_info("All autosaves cleared")

    }, error = function(e) {
      notify_error(paste("❌ Error clearing autosaves:", e$message), duration = 5)
    })
  })

  # =============================================================================
  # PERIODIC AUTOSAVE TIMER
  # =============================================================================
  observe({
    # Only run if autosave is enabled
    req(input$autosave_enabled)
    req(input$autosave_interval)

    # Convert minutes to milliseconds
    interval_ms <- input$autosave_interval * 60 * 1000

    # Invalidate this observer every interval
    invalidateLater(interval_ms, session)

    # Trigger autosave (skip first run)
    if (!is.null(lastAutosaveTime())) {
      # Trigger the same logic as manual save
      # Use updateActionButton to simulate click
      session$sendCustomMessage("eval", list(
        code = "$('#autosave_now').trigger('click');"
      ))

      log_debug(paste("Periodic autosave triggered (interval:", input$autosave_interval, "min)"))
    } else {
      # First run - just set timestamp
      lastAutosaveTime(Sys.time())
    }
  })

  # =============================================================================
  # AUTO-LOAD ON STARTUP
  # =============================================================================
  observe({
    req(input$autosave_autoload)

    # Only run once on startup
    isolate({
      # JavaScript to load last save and send to server
      js_code <- "
        try {
          var autoload = $('#autosave_autoload').is(':checked');
          if (autoload) {
            var saveData = localStorage.getItem('bowtie_autosave_current');
            if (saveData) {
              var data = JSON.parse(saveData);
              console.log('Auto-loading last save from:', data.timestamp);

              // Send data to Shiny server for restore
              Shiny.setInputValue('autosave_restore_data', data, {priority: 'event'});

              // Update UI
              if (data.timestamp) {
                var timestamp = new Date(data.timestamp).toLocaleString();
                $('#last_autosave_time').text(timestamp);
              }
            }
          }
        } catch(e) {
          console.error('Auto-load failed:', e);
        }
      "

      session$sendCustomMessage("eval", list(code = js_code))
    })
  })

  # =============================================================================
  # RESTORE SAVED STATE
  # =============================================================================
  observeEvent(input$autosave_restore_data, {
    save_data <- input$autosave_restore_data
    if (is.null(save_data)) return()

    tryCatch({
      # Restore settings if present
      if (!is.null(save_data$settings)) {
        settings <- save_data$settings

        # Restore theme
        if (!is.null(settings$theme)) {
          updateSelectInput(session, "theme_preset", selected = settings$theme)
        }

        # Restore AI settings
        if (!is.null(settings$ai_enabled)) {
          updateCheckboxInput(session, "ai_suggestions_enabled", value = settings$ai_enabled)
        }

        if (!is.null(settings$ai_methods)) {
          if (!is.null(settings$ai_methods$semantic)) {
            updateCheckboxInput(session, "ai_method_semantic", value = settings$ai_methods$semantic)
          }
          if (!is.null(settings$ai_methods$keyword)) {
            updateCheckboxInput(session, "ai_method_keyword", value = settings$ai_methods$keyword)
          }
          if (!is.null(settings$ai_methods$causal)) {
            updateCheckboxInput(session, "ai_method_causal", value = settings$ai_methods$causal)
          }
        }

        if (!is.null(settings$ai_max_suggestions)) {
          updateSliderInput(session, "ai_max_suggestions", value = settings$ai_max_suggestions)
        }
      }

      # Restore autosave config if present
      if (!is.null(save_data$autosave_config)) {
        config <- save_data$autosave_config

        if (!is.null(config$interval)) {
          updateSliderInput(session, "autosave_interval", value = config$interval)
        }
        if (!is.null(config$versions)) {
          updateSliderInput(session, "autosave_versions", value = config$versions)
        }
        if (!is.null(config$location)) {
          updateRadioButtons(session, "autosave_location", selected = config$location)
        }
        if (!is.null(config$notify)) {
          updateCheckboxInput(session, "autosave_notify", value = config$notify)
        }
        if (!is.null(config$include_data)) {
          updateCheckboxInput(session, "autosave_include_data", value = config$include_data)
        }
      }

      # Restore version counter
      if (!is.null(save_data$version)) {
        autosaveVersion(save_data$version)
      }

      # Update timestamp
      if (!is.null(save_data$timestamp)) {
        lastAutosaveTime(as.POSIXct(save_data$timestamp))
      }

      notify_success(sprintf("✅ Settings restored from autosave (v%s)",
               if (!is.null(save_data$version)) save_data$version else "?"),
        duration = 3
      )

    }, error = function(e) {
      notify_warning(paste("⚠️ Could not restore all settings:", e$message), duration = 5)
    })
  })

  # =============================================================================
  # INITIALIZE LAST SAVE TIMESTAMP DISPLAY
  # =============================================================================
  observe({
    # Load timestamp from localStorage on startup
    js_code <- "
      try {
        var metadata = localStorage.getItem('bowtie_autosave_metadata');
        if (metadata) {
          var data = JSON.parse(metadata);
          if (data.lastSave) {
            var timestamp = new Date(data.lastSave).toLocaleString();
            $('#last_autosave_time').text(timestamp);
          }
        }
      } catch(e) {
        console.error('Load timestamp failed:', e);
      }
    "

    session$sendCustomMessage("eval", list(code = js_code))
  })

  # Return module API
  list(
    lastAutosaveTime = lastAutosaveTime,
    autosaveVersion = autosaveVersion
  )
}
