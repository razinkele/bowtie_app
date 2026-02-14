# =============================================================================
# Environmental Bowtie Risk Analysis - Error Handling Helpers
# Version: 5.4.0+
# Date: January 2026
# Purpose: Standardized error handling to replace 138 inconsistent tryCatch blocks
# =============================================================================

#' Safe execution with standardized error handling
#'
#' @param expr Expression to execute
#' @param on_error Callback function(error) to execute on error
#' @param notify Show notification on error (default: TRUE)
#' @param log Log error to console (default: TRUE)
#' @param context Context description for error message
#' @param silent If TRUE, suppresses error notifications but still logs
#' @param default_value Value to return on error (default: NULL)
#' @return Result of expr on success, default_value on error
#'
#' @examples
#' safe_exec({
#'   data <- read_excel(file_path)
#' }, context = "loading data file")
#'
#' result <- safe_exec({
#'   risky_operation()
#' }, on_error = function(e) {
#'   cleanup_resources()
#' }, default_value = data.frame())
safe_exec <- function(expr, on_error = NULL, notify = TRUE,
                      log = TRUE, context = NULL, silent = FALSE,
                      default_value = NULL) {
  tryCatch(
    expr,
    error = function(e) {
      # Format error message
      error_msg <- e$message
      full_context <- if (!is.null(context)) {
        paste(context, ":", error_msg)
      } else {
        error_msg
      }

      # Log error
      if (log && exists("log_error") && is.function(log_error)) {
        log_error(full_context)
      } else if (log) {
        cat("❌ ERROR:", full_context, "\n", file = stderr())
      }

      # Show notification
      if (notify && !silent) {
        if (exists("notify_error") && is.function(notify_error)) {
          notify_error(e, context = context)
        } else {
          # Fallback to base notification
          if (exists("showNotification") && is.function(showNotification)) {
            showNotification(
              paste("❌ Error:", full_context),
              type = "error",
              duration = 5
            )
          }
        }
      }

      # Execute callback
      if (!is.null(on_error) && is.function(on_error)) {
        tryCatch(
          on_error(e),
          error = function(callback_error) {
            if (log) {
              cat("⚠️ Warning: Error in error callback:",
                  callback_error$message, "\n", file = stderr())
            }
          }
        )
      }

      # Return default value
      default_value
    },
    warning = function(w) {
      # Log warning
      if (log && exists("log_warning") && is.function(log_warning)) {
        log_warning(paste(context, ":", w$message))
      } else if (log) {
        cat("⚠️ WARNING:", context, ":", w$message, "\n", file = stderr())
      }

      # Continue execution
      suppressWarnings(eval(expr))
    }
  )
}

#' Require data with validation
#'
#' @param data Data to validate
#' @param name Name of the data for error messages
#' @param validate_fn Optional custom validation function(data) -> TRUE/error
#' @param allow_empty Allow empty data frames (default: FALSE)
#' @return data (invisible) if valid, stops with error otherwise
#'
#' @examples
#' require_data(user_input, "user input")
#' require_data(bowtie_data, "bowtie data",
#'              validate_fn = function(d) nrow(d) > 0)
require_data <- function(data, name = "data", validate_fn = NULL,
                         allow_empty = FALSE) {
  # Check NULL
  if (is.null(data)) {
    stop(paste(name, "is NULL - expected valid data"))
  }

  # Check empty data frame
  if (is.data.frame(data) && !allow_empty && nrow(data) == 0) {
    stop(paste(name, "is empty - expected at least one row"))
  }

  # Check empty vector/list
  if ((is.vector(data) || is.list(data)) && !allow_empty && length(data) == 0) {
    stop(paste(name, "is empty - expected at least one element"))
  }

  # Custom validation
  if (!is.null(validate_fn) && is.function(validate_fn)) {
    tryCatch({
      validation_result <- validate_fn(data)
      if (!isTRUE(validation_result)) {
        if (is.character(validation_result)) {
          stop(validation_result)
        } else {
          stop(paste(name, "failed custom validation"))
        }
      }
    }, error = function(e) {
      stop(paste(name, "validation error:", e$message))
    })
  }

  invisible(data)
}

#' Validate input parameters
#'
#' @param value Value to validate
#' @param name Parameter name for error messages
#' @param type Expected type (e.g., "character", "numeric", "data.frame")
#' @param allowed_values Vector of allowed values
#' @param min_length Minimum length for vectors/lists
#' @param max_length Maximum length for vectors/lists
#' @param min_value Minimum value for numeric
#' @param max_value Maximum value for numeric
#' @param pattern Regex pattern for character validation
#' @param custom Custom validation function
#' @return value (invisible) if valid, stops with error otherwise
#'
#' @examples
#' validate_input(theme, "theme",
#'                allowed_values = c("light", "dark"))
#' validate_input(port, "port", type = "numeric",
#'                min_value = 1000, max_value = 9999)
#' validate_input(email, "email",
#'                pattern = "^[^@]+@[^@]+\\.[^@]+$")
validate_input <- function(value, name, type = NULL, allowed_values = NULL,
                          min_length = NULL, max_length = NULL,
                          min_value = NULL, max_value = NULL,
                          pattern = NULL, custom = NULL) {
  # NULL check
  if (is.null(value)) {
    stop(paste(name, "is required (cannot be NULL)"))
  }

  # Empty string check
  if (is.character(value) && length(value) == 1 && value == "") {
    stop(paste(name, "cannot be empty string"))
  }

  # Type check
  if (!is.null(type)) {
    if (!inherits(value, type)) {
      stop(paste(name, "must be of type", type,
                 "but got", class(value)[1]))
    }
  }

  # Allowed values check
  if (!is.null(allowed_values)) {
    if (length(value) == 1) {
      if (!(value %in% allowed_values)) {
        stop(paste(name, "must be one of:",
                   paste(allowed_values, collapse = ", "),
                   "but got:", value))
      }
    } else {
      invalid <- setdiff(value, allowed_values)
      if (length(invalid) > 0) {
        stop(paste(name, "contains invalid values:",
                   paste(invalid, collapse = ", ")))
      }
    }
  }

  # Length validation
  if (!is.null(min_length)) {
    if (length(value) < min_length) {
      stop(paste(name, "must have at least", min_length,
                 "elements, but has", length(value)))
    }
  }

  if (!is.null(max_length)) {
    if (length(value) > max_length) {
      stop(paste(name, "must have at most", max_length,
                 "elements, but has", length(value)))
    }
  }

  # Numeric range validation
  if (!is.null(min_value) && is.numeric(value)) {
    if (any(value < min_value, na.rm = TRUE)) {
      stop(paste(name, "must be >=", min_value))
    }
  }

  if (!is.null(max_value) && is.numeric(value)) {
    if (any(value > max_value, na.rm = TRUE)) {
      stop(paste(name, "must be <=", max_value))
    }
  }

  # Pattern validation for strings
  if (!is.null(pattern) && is.character(value)) {
    if (!all(grepl(pattern, value))) {
      stop(paste(name, "does not match required pattern:", pattern))
    }
  }

  # Custom validation
  if (!is.null(custom) && is.function(custom)) {
    custom_result <- custom(value)
    if (!isTRUE(custom_result)) {
      if (is.character(custom_result)) {
        stop(paste(name, ":", custom_result))
      } else {
        stop(paste(name, "failed custom validation"))
      }
    }
  }

  invisible(value)
}

#' Validate file path exists and is readable
#'
#' @param file_path Path to file
#' @param name Parameter name for error messages
#' @param extensions Allowed file extensions (e.g., c(".xlsx", ".csv"))
#' @return file_path (invisible) if valid
validate_file_path <- function(file_path, name = "file", extensions = NULL) {
  validate_input(file_path, name, type = "character")

  if (!file.exists(file_path)) {
    stop(paste(name, "does not exist:", file_path))
  }

  if (!file.access(file_path, mode = 4) == 0) {
    stop(paste(name, "is not readable:", file_path))
  }

  if (!is.null(extensions)) {
    file_ext <- tools::file_ext(file_path)
    if (!paste0(".", file_ext) %in% extensions) {
      stop(paste(name, "must have extension:",
                 paste(extensions, collapse = " or ")))
    }
  }

  invisible(file_path)
}

#' Validate data frame has required columns
#'
#' @param data Data frame to validate
#' @param required_cols Vector of required column names
#' @param name Name for error messages
#' @return data (invisible) if valid
validate_columns <- function(data, required_cols, name = "data") {
  require_data(data, name)

  if (!is.data.frame(data)) {
    stop(paste(name, "must be a data frame"))
  }

  missing_cols <- setdiff(required_cols, names(data))

  if (length(missing_cols) > 0) {
    stop(paste(name, "missing required columns:",
               paste(missing_cols, collapse = ", ")))
  }

  invisible(data)
}

#' Safe file operation wrapper
#'
#' @param file_path Path to file
#' @param operation Function to perform on file
#' @param context Context description
#' @param ... Additional arguments to operation
#' @return Result of operation or NULL on error
safe_file_operation <- function(file_path, operation, context = NULL, ...) {
  if (is.null(context)) {
    context <- paste("file operation on", basename(file_path))
  }

  safe_exec({
    validate_file_path(file_path, "file path")
    operation(file_path, ...)
  }, context = context)
}

#' Retry operation with exponential backoff
#'
#' @param expr Expression to retry
#' @param max_attempts Maximum number of attempts (default: 3)
#' @param initial_delay Initial delay in seconds (default: 1)
#' @param backoff_factor Multiplier for delay (default: 2)
#' @param on_retry Callback function(attempt, error)
#' @return Result of expr or error after max attempts
#'
#' @examples
#' retry_operation({
#'   fetch_remote_data(url)
#' }, max_attempts = 5, initial_delay = 2)
retry_operation <- function(expr, max_attempts = 3, initial_delay = 1,
                           backoff_factor = 2, on_retry = NULL) {
  attempt <- 1
  delay <- initial_delay

  while (attempt <= max_attempts) {
    result <- tryCatch({
      eval(expr)
    }, error = function(e) {
      if (attempt < max_attempts) {
        # Log retry attempt
        if (exists("log_warning") && is.function(log_warning)) {
          log_warning(paste("Attempt", attempt, "failed:", e$message,
                          "- retrying in", delay, "seconds"))
        }

        # Call retry callback
        if (!is.null(on_retry) && is.function(on_retry)) {
          on_retry(attempt, e)
        }

        # Wait before retry
        Sys.sleep(delay)
        delay <- delay * backoff_factor

        # Return special marker to continue loop
        structure(list(retry = TRUE), class = "retry_marker")
      } else {
        # Max attempts reached, re-throw error
        stop(paste("Operation failed after", max_attempts, "attempts:",
                  e$message))
      }
    })

    # Check if we should retry
    if (!inherits(result, "retry_marker")) {
      return(result)
    }

    attempt <- attempt + 1
  }
}

#' Assert condition with custom error message
#'
#' @param condition Boolean condition to assert
#' @param message Error message if condition is FALSE
#' @param ... Additional values to include in message
#' @return NULL if condition is TRUE, stops otherwise
#'
#' @examples
#' assert_that(nrow(data) > 0, "Data cannot be empty")
#' assert_that(port > 1000, "Port must be > 1000, got:", port)
assert_that <- function(condition, message, ...) {
  if (!isTRUE(condition)) {
    full_message <- if (length(list(...)) > 0) {
      paste(message, ...)
    } else {
      message
    }
    stop(full_message, call. = FALSE)
  }
  invisible(NULL)
}

#' Validate reactive input in Shiny
#'
#' @param input Reactive input value
#' @param name Input name
#' @param ... Additional validation parameters for validate_input()
#' @return input value if valid
#'
#' @examples
#' validate_reactive_input(input$theme, "theme",
#'                        allowed_values = c("light", "dark"))
validate_reactive_input <- function(input, name, ...) {
  # Use req() if available in Shiny context
  if (exists("req") && is.function(req)) {
    req(input)
  }

  validate_input(input, name, ...)
}

#' Create error context for debugging
#'
#' @param context_name Name of the context
#' @param ... Named values to include in context
#' @return List with context information
#'
#' @examples
#' ctx <- error_context("data_loading",
#'                     file = file_path,
#'                     user = session$user)
error_context <- function(context_name, ...) {
  list(
    context = context_name,
    timestamp = Sys.time(),
    values = list(...),
    call_stack = sys.calls()
  )
}

#' Log detailed error information
#'
#' @param error Error object
#' @param context Error context from error_context()
#' @return NULL (invisible)
log_error_details <- function(error, context = NULL) {
  error_info <- list(
    message = error$message,
    class = class(error),
    call = deparse(error$call),
    timestamp = Sys.time()
  )

  if (!is.null(context)) {
    error_info$context <- context
  }

  # Log to file if logging is configured
  if (exists("log_error") && is.function(log_error)) {
    log_error(paste("Detailed error:",
                   jsonlite::toJSON(error_info, auto_unbox = TRUE)))
  } else {
    # Fallback to console
    cat("❌ ERROR DETAILS:\n", file = stderr())
    cat(jsonlite::toJSON(error_info, pretty = TRUE, auto_unbox = TRUE),
        "\n", file = stderr())
  }

  invisible(NULL)
}

#' Graceful degradation wrapper
#'
#' @param primary_expr Primary expression to try
#' @param fallback_expr Fallback expression if primary fails
#' @param context Context description
#' @return Result of primary_expr or fallback_expr
#'
#' @examples
#' data <- graceful_degrade({
#'   read_from_database()
#' }, {
#'   read_from_cache()
#' }, context = "loading user data")
graceful_degrade <- function(primary_expr, fallback_expr, context = NULL) {
  result <- safe_exec(
    primary_expr,
    silent = TRUE,
    log = TRUE,
    context = paste(context, "(primary)")
  )

  if (is.null(result)) {
    if (exists("log_warning") && is.function(log_warning)) {
      log_warning(paste(context, "- using fallback method"))
    }

    safe_exec(
      fallback_expr,
      context = paste(context, "(fallback)")
    )
  } else {
    result
  }
}

#' Validate multiple conditions
#'
#' @param ... Named conditions to validate
#' @return TRUE if all valid, stops with first error
#'
#' @examples
#' validate_all(
#'   data_loaded = !is.null(data),
#'   has_rows = nrow(data) > 0,
#'   has_columns = ncol(data) > 0
#' )
validate_all <- function(...) {
  conditions <- list(...)

  for (name in names(conditions)) {
    if (!isTRUE(conditions[[name]])) {
      stop(paste("Validation failed:", name))
    }
  }

  TRUE
}

# =============================================================================
# ERROR RECOVERY HELPERS
# =============================================================================

#' Create checkpoint for error recovery
#'
#' @param state State object to checkpoint
#' @param name Checkpoint name
#' @return NULL (invisible)
create_checkpoint <- function(state, name = "default") {
  if (!exists(".checkpoints")) {
    .checkpoints <<- new.env()
  }

  .checkpoints[[name]] <- list(
    state = state,
    timestamp = Sys.time()
  )

  invisible(NULL)
}

#' Restore from checkpoint
#'
#' @param name Checkpoint name
#' @return Checkpointed state or NULL if not found
restore_checkpoint <- function(name = "default") {
  if (exists(".checkpoints") && exists(name, envir = .checkpoints)) {
    checkpoint <- get(name, envir = .checkpoints)

    if (exists("log_info") && is.function(log_info)) {
      log_info(paste("Restored checkpoint:", name,
                    "from", checkpoint$timestamp))
    }

    return(checkpoint$state)
  }

  NULL
}

# =============================================================================
# END OF ERROR HANDLING HELPERS
# =============================================================================

cat("✅ Error handling helpers loaded successfully\n")
