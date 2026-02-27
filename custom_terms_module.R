# =============================================================================
# Custom Terms Storage Module
# Version: 1.1.0 (Multi-User Session Isolation)
# Description: Persistent storage and management of custom vocabulary terms
#              with file locking for concurrent access protection
# =============================================================================

# =============================================================================
# STORAGE CONFIGURATION
# =============================================================================

CUSTOM_TERMS_FILE <- "data/custom_terms.rds"
CUSTOM_TERMS_BACKUP_DIR <- "data/custom_terms_backups"
CUSTOM_TERMS_LOCK_FILE <- "data/custom_terms.lock"
CUSTOM_TERMS_LOCK_TIMEOUT <- 10000  # 10 seconds timeout for lock acquisition

# Ensure directories exist
if (!dir.exists("data")) dir.create("data", recursive = TRUE)
if (!dir.exists(CUSTOM_TERMS_BACKUP_DIR)) dir.create(CUSTOM_TERMS_BACKUP_DIR, recursive = TRUE)

# =============================================================================
# FILE LOCKING UTILITIES (v5.4.1 - Multi-User Isolation)
# =============================================================================

#' Acquire file lock for custom terms operations
#' @param timeout_ms Timeout in milliseconds
#' @return Lock object or NULL if failed
acquire_custom_terms_lock <- function(timeout_ms = CUSTOM_TERMS_LOCK_TIMEOUT) {
  tryCatch({
    # Check if filelock package is available
    if (!requireNamespace("filelock", quietly = TRUE)) {
      # Fallback: simple lock file approach
      return(acquire_simple_lock(timeout_ms))
    }

    lock <- filelock::lock(CUSTOM_TERMS_LOCK_FILE, timeout = timeout_ms)
    return(lock)
  }, error = function(e) {
    bowtie_log(paste("Warning: Could not acquire file lock:", e$message),
               level = "warn", .verbose = TRUE)
    return(NULL)
  })
}

#' Release file lock
#' @param lock Lock object from acquire_custom_terms_lock
release_custom_terms_lock <- function(lock) {
  if (is.null(lock)) return(invisible(NULL))

  tryCatch({
    if (!requireNamespace("filelock", quietly = TRUE)) {
      # Fallback: simple lock file approach
      return(release_simple_lock(lock))
    }

    filelock::unlock(lock)
  }, error = function(e) {
    bowtie_log(paste("Warning: Error releasing lock:", e$message),
               level = "warn", .verbose = TRUE)
  })

  invisible(NULL)
}

#' Simple fallback lock mechanism using temporary files
#' @param timeout_ms Timeout in milliseconds
#' @return Lock info list or NULL
acquire_simple_lock <- function(timeout_ms = CUSTOM_TERMS_LOCK_TIMEOUT) {
  lock_file <- CUSTOM_TERMS_LOCK_FILE
  start_time <- Sys.time()
  timeout_sec <- timeout_ms / 1000

  while (as.numeric(difftime(Sys.time(), start_time, units = "secs")) < timeout_sec) {
    # Try to create lock file exclusively
    if (!file.exists(lock_file)) {
      tryCatch({
        # Write our process ID to the lock file
        writeLines(as.character(Sys.getpid()), lock_file)

        # Verify we own the lock (check for race condition)
        Sys.sleep(0.05)  # Small delay
        if (file.exists(lock_file)) {
          content <- readLines(lock_file, warn = FALSE)
          if (length(content) > 0 && content[1] == as.character(Sys.getpid())) {
            return(list(file = lock_file, pid = Sys.getpid(), time = Sys.time()))
          }
        }
      }, error = function(e) {
        # Another process might have created the file
      })
    } else {
      # Check if existing lock is stale (older than 60 seconds)
      lock_info <- file.info(lock_file)
      if (!is.na(lock_info$mtime)) {
        age <- as.numeric(difftime(Sys.time(), lock_info$mtime, units = "secs"))
        if (age > 60) {
          # Stale lock - remove and retry
          tryCatch(file.remove(lock_file), error = function(e) {})
        }
      }
    }

    Sys.sleep(0.1)  # Wait before retry
  }

  bowtie_log("Warning: Lock acquisition timed out", level = "warn", .verbose = TRUE)
  return(NULL)
}

#' Release simple fallback lock
#' @param lock Lock info from acquire_simple_lock
release_simple_lock <- function(lock) {
  if (is.null(lock)) return(invisible(NULL))

  tryCatch({
    if (file.exists(lock$file)) {
      # Only remove if we own it
      content <- readLines(lock$file, warn = FALSE)
      if (length(content) > 0 && content[1] == as.character(lock$pid)) {
        file.remove(lock$file)
      }
    }
  }, error = function(e) {
    # Ignore errors during cleanup
  })

  invisible(NULL)
}

#' Execute function with file lock protection
#' @param fn Function to execute
#' @param ... Arguments to pass to function
#' @return Result of function execution
with_custom_terms_lock <- function(fn, ...) {
  lock <- acquire_custom_terms_lock()

  on.exit({
    release_custom_terms_lock(lock)
  }, add = TRUE)

  fn(...)
}

# =============================================================================
# CUSTOM TERMS DATA STRUCTURE
# =============================================================================

#' Initialize empty custom terms structure
init_custom_terms <- function() {
  list(
    activities = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),  # "pending", "approved", "rejected"
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    preventive_controls = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    protective_controls = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    escalation_factors = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    )
  )
}

# =============================================================================
# STORAGE FUNCTIONS
# =============================================================================

#' Load custom terms from file (with file locking for multi-user safety)
#' @return List of custom terms data frames
load_custom_terms <- function() {
  # Acquire read lock to prevent reading during write
  lock <- acquire_custom_terms_lock()
  on.exit(release_custom_terms_lock(lock), add = TRUE)

  tryCatch({
    if (file.exists(CUSTOM_TERMS_FILE)) {
      terms <- readRDS(CUSTOM_TERMS_FILE)
      # Ensure all required categories exist
      default_terms <- init_custom_terms()
      for (cat in names(default_terms)) {
        if (is.null(terms[[cat]])) {
          terms[[cat]] <- default_terms[[cat]]
        }
      }
      return(terms)
    } else {
      return(init_custom_terms())
    }
  }, error = function(e) {
    bowtie_log(paste("Error loading custom terms:", e$message), level = "warn")
    return(init_custom_terms())
  })
}

#' Save custom terms to file (with atomic write and file locking)
#' @param terms List of custom terms data frames
#' @param create_backup Whether to create a backup before saving
save_custom_terms <- function(terms, create_backup = TRUE) {
  # Acquire exclusive lock for write operation
  lock <- acquire_custom_terms_lock()
  if (is.null(lock)) {
    bowtie_log("Warning: Could not acquire lock for saving custom terms",
               level = "warn")
    # Proceed anyway but log the warning
  }
  on.exit(release_custom_terms_lock(lock), add = TRUE)

  tryCatch({
    # Create backup if file exists
    if (create_backup && file.exists(CUSTOM_TERMS_FILE)) {
      # Use milliseconds to avoid backup filename collisions
      backup_file <- file.path(
        CUSTOM_TERMS_BACKUP_DIR,
        paste0("custom_terms_", format(Sys.time(), "%Y%m%d_%H%M%S_%OS3"), ".rds")
      )
      file.copy(CUSTOM_TERMS_FILE, backup_file)

      # Keep only last 10 backups
      backups <- list.files(CUSTOM_TERMS_BACKUP_DIR, pattern = "\\.rds$", full.names = TRUE)
      if (length(backups) > 10) {
        old_backups <- sort(backups)[1:(length(backups) - 10)]
        tryCatch(file.remove(old_backups), error = function(e) {})
      }
    }

    # ATOMIC WRITE: Write to temp file first, then rename
    # This prevents corruption if process is interrupted during write
    temp_file <- tempfile(pattern = "custom_terms_", tmpdir = "data", fileext = ".tmp")
    saveRDS(terms, temp_file)

    # Atomic rename (on most filesystems)
    if (file.exists(temp_file)) {
      # On Windows, we need to remove target first
      if (.Platform$OS.type == "windows" && file.exists(CUSTOM_TERMS_FILE)) {
        file.remove(CUSTOM_TERMS_FILE)
      }
      file.rename(temp_file, CUSTOM_TERMS_FILE)
    }

    return(TRUE)
  }, error = function(e) {
    bowtie_log(paste("Error saving custom terms:", e$message), level = "warn")
    # Clean up temp file if it exists
    if (exists("temp_file") && file.exists(temp_file)) {
      tryCatch(file.remove(temp_file), error = function(e) {})
    }
    return(FALSE)
  })
}

#' Add a custom term (atomic read-modify-write with locking)
#' @param category Character: "activities", "pressures", etc.
#' @param term Character: The custom term text
#' @param added_by Character: Username who added the term
#' @param project_name Character: Project name (optional)
#' @return Updated terms list
add_custom_term <- function(category, term, added_by = "default", project_name = "") {
  # Acquire lock for the entire read-modify-write operation
  lock <- acquire_custom_terms_lock()
  on.exit(release_custom_terms_lock(lock), add = TRUE)

  tryCatch({
    # Load terms (without separate lock since we already have it)
    terms <- if (file.exists(CUSTOM_TERMS_FILE)) {
      readRDS(CUSTOM_TERMS_FILE)
    } else {
      init_custom_terms()
    }

    # Ensure category exists
    if (is.null(terms[[category]])) {
      terms[[category]] <- init_custom_terms()[[category]]
    }

    # Check if term already exists
    if (term %in% terms[[category]]$term) {
      return(list(success = FALSE, message = "Term already exists", terms = terms))
    }

    # Generate unique ID with microsecond precision to avoid collisions
    new_id <- paste0(substr(category, 1, 3), "_",
                     format(Sys.time(), "%Y%m%d%H%M%S"),
                     sprintf("%04d", as.integer((as.numeric(Sys.time()) %% 1) * 10000)), "_",
                     sample(1000:9999, 1))

    # Create new row
    new_row <- data.frame(
      id = new_id,
      term = term,
      added_by = added_by,
      added_date = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      project_name = project_name,
      status = "pending",
      reviewed_by = "",
      reviewed_date = "",
      notes = "",
      stringsAsFactors = FALSE
    )

    # Add to category
    terms[[category]] <- rbind(terms[[category]], new_row)

    # Atomic save
    temp_file <- tempfile(pattern = "custom_terms_", tmpdir = "data", fileext = ".tmp")
    saveRDS(terms, temp_file)
    if (.Platform$OS.type == "windows" && file.exists(CUSTOM_TERMS_FILE)) {
      file.remove(CUSTOM_TERMS_FILE)
    }
    file.rename(temp_file, CUSTOM_TERMS_FILE)

    return(list(success = TRUE, message = "Term added successfully", terms = terms, id = new_id))

  }, error = function(e) {
    bowtie_log(paste("Error adding custom term:", e$message), level = "warn")
    return(list(success = FALSE, message = paste("Error:", e$message), terms = NULL))
  })
}

#' Update term status (atomic read-modify-write with locking)
#' @param category Character: Category name
#' @param term_id Character: Term ID
#' @param new_status Character: "approved" or "rejected"
#' @param reviewed_by Character: Admin username
#' @param notes Character: Optional notes
update_term_status <- function(category, term_id, new_status, reviewed_by = "admin", notes = "") {
  # Acquire lock for the entire read-modify-write operation
  lock <- acquire_custom_terms_lock()
  on.exit(release_custom_terms_lock(lock), add = TRUE)

  tryCatch({
    # Load terms directly
    terms <- if (file.exists(CUSTOM_TERMS_FILE)) {
      readRDS(CUSTOM_TERMS_FILE)
    } else {
      return(list(success = FALSE, message = "No custom terms file exists"))
    }

    idx <- which(terms[[category]]$id == term_id)
    if (length(idx) == 0) {
      return(list(success = FALSE, message = "Term not found"))
    }

    terms[[category]]$status[idx] <- new_status
    terms[[category]]$reviewed_by[idx] <- reviewed_by
    terms[[category]]$reviewed_date[idx] <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    terms[[category]]$notes[idx] <- notes

    # Atomic save
    temp_file <- tempfile(pattern = "custom_terms_", tmpdir = "data", fileext = ".tmp")
    saveRDS(terms, temp_file)
    if (.Platform$OS.type == "windows" && file.exists(CUSTOM_TERMS_FILE)) {
      file.remove(CUSTOM_TERMS_FILE)
    }
    file.rename(temp_file, CUSTOM_TERMS_FILE)

    return(list(success = TRUE, message = paste("Term", new_status)))

  }, error = function(e) {
    bowtie_log(paste("Error updating term status:", e$message), level = "warn")
    return(list(success = FALSE, message = paste("Error:", e$message)))
  })
}

#' Delete a custom term (atomic read-modify-write with locking)
#' @param category Character: Category name
#' @param term_id Character: Term ID
delete_custom_term <- function(category, term_id) {
  # Acquire lock for the entire read-modify-write operation
  lock <- acquire_custom_terms_lock()
  on.exit(release_custom_terms_lock(lock), add = TRUE)

  tryCatch({
    # Load terms directly
    terms <- if (file.exists(CUSTOM_TERMS_FILE)) {
      readRDS(CUSTOM_TERMS_FILE)
    } else {
      return(list(success = FALSE, message = "No custom terms file exists"))
    }

    idx <- which(terms[[category]]$id == term_id)
    if (length(idx) == 0) {
      return(list(success = FALSE, message = "Term not found"))
    }

    terms[[category]] <- terms[[category]][-idx, , drop = FALSE]

    # Atomic save
    temp_file <- tempfile(pattern = "custom_terms_", tmpdir = "data", fileext = ".tmp")
    saveRDS(terms, temp_file)
    if (.Platform$OS.type == "windows" && file.exists(CUSTOM_TERMS_FILE)) {
      file.remove(CUSTOM_TERMS_FILE)
    }
    file.rename(temp_file, CUSTOM_TERMS_FILE)

    return(list(success = TRUE, message = "Term deleted"))

  }, error = function(e) {
    bowtie_log(paste("Error deleting custom term:", e$message), level = "warn")
    return(list(success = FALSE, message = paste("Error:", e$message)))
  })
}

#' Get summary statistics
get_custom_terms_summary <- function() {
  terms <- load_custom_terms()

  summary_data <- data.frame(
    Category = c("Activities", "Pressures", "Preventive Controls",
                 "Consequences", "Protective Controls", "Escalation Factors"),
    Total = c(
      nrow(terms$activities),
      nrow(terms$pressures),
      nrow(terms$preventive_controls),
      nrow(terms$consequences),
      nrow(terms$protective_controls),
      nrow(terms$escalation_factors)
    ),
    Pending = c(
      sum(terms$activities$status == "pending"),
      sum(terms$pressures$status == "pending"),
      sum(terms$preventive_controls$status == "pending"),
      sum(terms$consequences$status == "pending"),
      sum(terms$protective_controls$status == "pending"),
      sum(terms$escalation_factors$status == "pending")
    ),
    Approved = c(
      sum(terms$activities$status == "approved"),
      sum(terms$pressures$status == "approved"),
      sum(terms$preventive_controls$status == "approved"),
      sum(terms$consequences$status == "approved"),
      sum(terms$protective_controls$status == "approved"),
      sum(terms$escalation_factors$status == "approved")
    ),
    Rejected = c(
      sum(terms$activities$status == "rejected"),
      sum(terms$pressures$status == "rejected"),
      sum(terms$preventive_controls$status == "rejected"),
      sum(terms$consequences$status == "rejected"),
      sum(terms$protective_controls$status == "rejected"),
      sum(terms$escalation_factors$status == "rejected")
    ),
    stringsAsFactors = FALSE
  )

  return(summary_data)
}

#' Get all terms as a flat table for display
get_all_custom_terms_flat <- function() {
  terms <- load_custom_terms()

  categories <- list(
    activities = "Activity",
    pressures = "Pressure",
    preventive_controls = "Preventive Control",
    consequences = "Consequence",
    protective_controls = "Protective Control",
    escalation_factors = "Escalation Factor"
  )

  terms_list <- lapply(names(categories), function(cat_name) {
    if (nrow(terms[[cat_name]]) > 0) {
      cat_data <- terms[[cat_name]]
      cat_data$category <- categories[[cat_name]]
      cat_data$category_key <- cat_name
      cat_data
    } else {
      NULL
    }
  })
  terms_list <- Filter(Negate(is.null), terms_list)
  all_terms <- if (length(terms_list) > 0) do.call(rbind, terms_list) else data.frame()

  if (nrow(all_terms) == 0) {
    return(data.frame(
      id = character(),
      term = character(),
      category = character(),
      category_key = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ))
  }

  # Reorder columns
  all_terms <- all_terms[, c("id", "term", "category", "category_key", "added_by",
                              "added_date", "project_name", "status",
                              "reviewed_by", "reviewed_date", "notes")]

  return(all_terms)
}

cat("Custom terms storage module loaded successfully\n")
