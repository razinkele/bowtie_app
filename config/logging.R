# =============================================================================
# Environmental Bowtie Risk Analysis - Logging Configuration
# Version: 5.4.0+
# Date: January 2026
# Purpose: Unified logging system to replace 1,902 inconsistent logging calls
# =============================================================================

# =============================================================================
# LOGGING CONFIGURATION
# =============================================================================

LOGGING_CONFIG <- list(
  # Enable/disable logging
  enabled = TRUE,

  # Minimum log level to display ("DEBUG", "INFO", "WARNING", "ERROR")
  level = "INFO",

  # Output destinations
  console = TRUE,
  file = FALSE,  # Set to TRUE to enable file logging
  file_path = "logs/app.log",

  # Log format template
  # Available placeholders: {timestamp}, {level}, {emoji}, {message}, {context}
  format = "[{timestamp}] {level}: {message}",

  # Include emoji icons in logs
  emoji = TRUE,

  # Include context information (slower but more detailed)
  include_context = FALSE,

  # Timestamp format
  timestamp_format = "%Y-%m-%d %H:%M:%S",

  # Maximum log file size (bytes) before rotation
  max_file_size = 10 * 1024 * 1024,  # 10 MB

  # Number of rotated log files to keep
  max_backup_files = 5,

  # Color output for console (if terminal supports it)
  color = FALSE
)

# =============================================================================
# LOG LEVEL HIERARCHY
# =============================================================================

LOG_LEVELS <- list(
  DEBUG = 1,
  INFO = 2,
  WARNING = 3,
  ERROR = 4
)

# =============================================================================
# LOG EMOJI MAPPING
# =============================================================================

LOG_EMOJI <- list(
  DEBUG = "🔍",
  INFO = "ℹ️",
  SUCCESS = "✅",
  WARNING = "⚠️",
  ERROR = "❌",
  PROGRESS = "🔄",
  START = "🚀",
  STOP = "🛑",
  SAVE = "💾",
  LOAD = "📂",
  NETWORK = "🌐",
  DATABASE = "🗄️",
  CACHE = "📦"
)

# =============================================================================
# LOGGING ENVIRONMENT
# =============================================================================

.log_env <- new.env()
.log_env$buffer <- character(0)
.log_env$file_handle <- NULL
.log_env$log_count <- 0

# =============================================================================
# CORE LOGGING FUNCTION
# =============================================================================

#' Unified logging function
#'
#' @param message Log message
#' @param level Log level ("DEBUG", "INFO", "WARNING", "ERROR")
#' @param emoji Emoji icon to use (overrides level default)
#' @param context Additional context information
#' @param ... Additional values to append to message
#' @return NULL (invisible)
#'
#' @examples
#' app_log("Application started", level = "INFO")
#' app_log("Data loaded", level = "INFO", emoji = "📊")
app_log <- function(message, level = "INFO", emoji = NULL,
                    context = NULL, ...) {
  # Check if logging is enabled
  if (!LOGGING_CONFIG$enabled) {
    return(invisible(NULL))
  }

  # Validate log level
  level <- toupper(level)
  if (!level %in% names(LOG_LEVELS)) {
    level <- "INFO"
  }

  # Check minimum log level
  if (LOG_LEVELS[[level]] < LOG_LEVELS[[LOGGING_CONFIG$level]]) {
    return(invisible(NULL))
  }

  # Append additional parameters to message
  if (length(list(...)) > 0) {
    message <- paste(message, ...)
  }

  # Get emoji for level
  if (LOGGING_CONFIG$emoji) {
    if (is.null(emoji)) {
      emoji <- LOG_EMOJI[[level]]
      if (is.null(emoji)) emoji <- ""
    }
  } else {
    emoji <- ""
  }

  # Format timestamp
  timestamp <- format(Sys.time(), LOGGING_CONFIG$timestamp_format)

  # Build log entry
  log_entry <- LOGGING_CONFIG$format
  log_entry <- gsub("\\{timestamp\\}", timestamp, log_entry)
  log_entry <- gsub("\\{level\\}", level, log_entry)
  log_entry <- gsub("\\{emoji\\}", emoji, log_entry)
  log_entry <- gsub("\\{message\\}", message, log_entry)

  # Add context if enabled
  if (LOGGING_CONFIG$include_context && !is.null(context)) {
    log_entry <- paste0(log_entry, " [Context: ", context, "]")
  }

  # Trim any double spaces from emoji replacement
  log_entry <- gsub("  +", " ", log_entry)

  # Console output
  if (LOGGING_CONFIG$console) {
    output_stream <- if (level == "ERROR") stderr() else stdout()
    cat(log_entry, "\n", file = output_stream)
  }

  # File output
  if (LOGGING_CONFIG$file) {
    write_to_log_file(log_entry)
  }

  # Increment log count
  .log_env$log_count <- .log_env$log_count + 1

  invisible(log_entry)
}

#' Write to log file with rotation
#'
#' @param entry Log entry to write
#' @return NULL (invisible)
write_to_log_file <- function(entry) {
  log_file <- LOGGING_CONFIG$file_path

  # Ensure log directory exists
  log_dir <- dirname(log_file)
  if (!dir.exists(log_dir)) {
    dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
  }

  # Check file size and rotate if needed
  if (file.exists(log_file)) {
    file_size <- file.info(log_file)$size
    if (file_size > LOGGING_CONFIG$max_file_size) {
      rotate_log_files()
    }
  }

  # Write to file
  tryCatch({
    cat(entry, "\n", file = log_file, append = TRUE)
  }, error = function(e) {
    warning("Failed to write to log file: ", e$message)
  })

  invisible(NULL)
}

#' Rotate log files
#'
#' @return NULL (invisible)
rotate_log_files <- function() {
  log_file <- LOGGING_CONFIG$file_path
  max_backups <- LOGGING_CONFIG$max_backup_files

  # Remove oldest backup if at limit
  oldest_backup <- paste0(log_file, ".", max_backups)
  if (file.exists(oldest_backup)) {
    file.remove(oldest_backup)
  }

  # Rotate existing backups
  for (i in (max_backups - 1):1) {
    old_file <- paste0(log_file, ".", i)
    new_file <- paste0(log_file, ".", i + 1)
    if (file.exists(old_file)) {
      file.rename(old_file, new_file)
    }
  }

  # Rotate current log file
  if (file.exists(log_file)) {
    file.rename(log_file, paste0(log_file, ".1"))
  }

  invisible(NULL)
}

# =============================================================================
# CONVENIENCE LOGGING FUNCTIONS
# =============================================================================

#' Log debug message
#' @param msg Debug message
#' @param ... Additional parameters
log_debug <- function(msg, ...) {
  app_log(msg, level = "DEBUG", emoji = LOG_EMOJI$DEBUG, ...)
}

#' Log info message
#' @param msg Info message
#' @param ... Additional parameters
log_info <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$INFO, ...)
}

#' Log success message
#' @param msg Success message
#' @param ... Additional parameters
log_success <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$SUCCESS, ...)
}

#' Log warning message
#' @param msg Warning message
#' @param ... Additional parameters
log_warning <- function(msg, ...) {
  app_log(msg, level = "WARNING", emoji = LOG_EMOJI$WARNING, ...)
}

#' Log error message
#' @param msg Error message
#' @param ... Additional parameters
log_error <- function(msg, ...) {
  app_log(msg, level = "ERROR", emoji = LOG_EMOJI$ERROR, ...)
}

#' Log progress message
#' @param msg Progress message
#' @param ... Additional parameters
log_progress <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$PROGRESS, ...)
}

#' Log application start
#' @param msg Start message
#' @param ... Additional parameters
log_start <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$START, ...)
}

#' Log application stop
#' @param msg Stop message
#' @param ... Additional parameters
log_stop <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$STOP, ...)
}

#' Log save operation
#' @param msg Save message
#' @param ... Additional parameters
log_save <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$SAVE, ...)
}

#' Log load operation
#' @param msg Load message
#' @param ... Additional parameters
log_load <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$LOAD, ...)
}

#' Log network operation
#' @param msg Network message
#' @param ... Additional parameters
log_network <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$NETWORK, ...)
}

#' Log database operation
#' @param msg Database message
#' @param ... Additional parameters
log_database <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$DATABASE, ...)
}

#' Log cache operation
#' @param msg Cache message
#' @param ... Additional parameters
log_cache <- function(msg, ...) {
  app_log(msg, level = "INFO", emoji = LOG_EMOJI$CACHE, ...)
}

# =============================================================================
# STRUCTURED LOGGING
# =============================================================================

#' Log structured data
#'
#' @param message Log message
#' @param data Named list of data to log
#' @param level Log level
#' @return NULL (invisible)
log_structured <- function(message, data = list(), level = "INFO") {
  # Format structured data
  data_str <- paste(
    names(data),
    sapply(data, function(x) {
      if (is.atomic(x) && length(x) == 1) {
        as.character(x)
      } else {
        paste0("[", paste(head(x, 3), collapse = ", "),
               if (length(x) > 3) "..." else "", "]")
      }
    }),
    sep = "=",
    collapse = ", "
  )

  full_message <- paste0(message, " {", data_str, "}")
  app_log(full_message, level = level)
}

#' Log function entry
#'
#' @param function_name Name of function
#' @param params Named list of parameters
#' @return NULL (invisible)
log_function_entry <- function(function_name, params = list()) {
  if (LOGGING_CONFIG$level == "DEBUG") {
    param_str <- paste(
      names(params),
      sapply(params, deparse, width.cutoff = 30),
      sep = "=",
      collapse = ", "
    )
    log_debug(paste0("→ ", function_name, "(", param_str, ")"))
  }
}

#' Log function exit
#'
#' @param function_name Name of function
#' @param result Result value
#' @return NULL (invisible)
log_function_exit <- function(function_name, result = NULL) {
  if (LOGGING_CONFIG$level == "DEBUG") {
    result_str <- if (!is.null(result)) {
      paste0(" → ", deparse(result, width.cutoff = 50)[1])
    } else {
      ""
    }
    log_debug(paste0("← ", function_name, result_str))
  }
}

# =============================================================================
# PERFORMANCE LOGGING
# =============================================================================

.perf_timers <- new.env()

#' Start performance timer
#'
#' @param name Timer name
#' @return NULL (invisible)
start_timer <- function(name) {
  .perf_timers[[name]] <- Sys.time()
  invisible(NULL)
}

#' Stop performance timer and log duration
#'
#' @param name Timer name
#' @param log_level Log level for output
#' @return Duration in seconds
stop_timer <- function(name, log_level = "DEBUG") {
  if (!exists(name, envir = .perf_timers)) {
    log_warning(paste("Timer", name, "was not started"))
    return(NULL)
  }

  start_time <- get(name, envir = .perf_timers)
  duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  app_log(
    paste0(name, " completed in ", round(duration, 3), " seconds"),
    level = log_level,
    emoji = "⏱️"
  )

  rm(list = name, envir = .perf_timers)
  invisible(duration)
}

#' Measure and log execution time
#'
#' @param expr Expression to measure
#' @param name Name for the measurement
#' @param log_level Log level
#' @return Result of expression
measure_time <- function(expr, name = "operation", log_level = "DEBUG") {
  start_time <- Sys.time()

  result <- eval(expr, envir = parent.frame())

  duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  app_log(
    paste0(name, " took ", round(duration, 3), " seconds"),
    level = log_level,
    emoji = "⏱️"
  )

  result
}

# =============================================================================
# LOG FILTERING AND SEARCH
# =============================================================================

#' Search log file for pattern
#'
#' @param pattern Regex pattern to search
#' @param n_lines Number of lines to return (default: 100)
#' @param level Filter by log level
#' @return Vector of matching log lines
search_logs <- function(pattern, n_lines = 100, level = NULL) {
  log_file <- LOGGING_CONFIG$file_path

  if (!file.exists(log_file)) {
    warning("Log file does not exist")
    return(character(0))
  }

  # Read log file
  all_lines <- readLines(log_file, warn = FALSE)

  # Filter by level if specified
  if (!is.null(level)) {
    level_pattern <- paste0("] ", toupper(level), ":")
    all_lines <- all_lines[grepl(level_pattern, all_lines)]
  }

  # Filter by pattern
  matching_lines <- all_lines[grepl(pattern, all_lines, ignore.case = TRUE)]

  # Return last n lines
  tail(matching_lines, n_lines)
}

#' Get recent log entries
#'
#' @param n Number of entries to retrieve
#' @param level Filter by level
#' @return Vector of log entries
get_recent_logs <- function(n = 50, level = NULL) {
  log_file <- LOGGING_CONFIG$file_path

  if (!file.exists(log_file)) {
    return(character(0))
  }

  all_lines <- readLines(log_file, warn = FALSE)

  # Filter by level if specified
  if (!is.null(level)) {
    level_pattern <- paste0("] ", toupper(level), ":")
    all_lines <- all_lines[grepl(level_pattern, all_lines)]
  }

  tail(all_lines, n)
}

# =============================================================================
# LOGGING STATISTICS
# =============================================================================

#' Get logging statistics
#'
#' @return List of statistics
get_log_stats <- function() {
  list(
    total_logs = .log_env$log_count,
    file_logging_enabled = LOGGING_CONFIG$file,
    console_logging_enabled = LOGGING_CONFIG$console,
    current_level = LOGGING_CONFIG$level,
    log_file = if (LOGGING_CONFIG$file) LOGGING_CONFIG$file_path else NA,
    log_file_size = if (LOGGING_CONFIG$file && file.exists(LOGGING_CONFIG$file_path)) {
      file.info(LOGGING_CONFIG$file_path)$size
    } else NA
  )
}

#' Clear log file
#'
#' @return TRUE if successful
clear_log_file <- function() {
  log_file <- LOGGING_CONFIG$file_path

  if (file.exists(log_file)) {
    tryCatch({
      file.remove(log_file)
      log_info("Log file cleared")
      TRUE
    }, error = function(e) {
      log_error("Failed to clear log file:", e$message)
      FALSE
    })
  } else {
    log_warning("Log file does not exist")
    FALSE
  }
}

# =============================================================================
# BACKWARD COMPATIBILITY WRAPPERS
# =============================================================================

#' Backward compatible wrapper for bowtie_log
#'
#' @param message Log message
#' @param level Log level (debug, info, warning, error)
#' @param ... Additional parameters
bowtie_log <- function(message, level = "debug", ...) {
  # Map old levels to new levels
  level_map <- c(
    "debug" = "DEBUG",
    "info" = "INFO",
    "warning" = "WARNING",
    "warn" = "WARNING",
    "error" = "ERROR"
  )

  level_key <- tolower(level)
  new_level <- if (level_key %in% names(level_map)) {
    level_map[level_key]
  } else {
    "INFO"
  }

  app_log(message, level = new_level, ...)
}

#' Backward compatible wrapper for app_message
#'
#' @param message Message to log
#' @param ... Additional parameters
app_message <- function(message, ...) {
  log_info(message, ...)
}

# =============================================================================
# INITIALIZE LOGGING
# =============================================================================

# Create logs directory if file logging is enabled
if (LOGGING_CONFIG$file) {
  log_dir <- dirname(LOGGING_CONFIG$file_path)
  if (!dir.exists(log_dir)) {
    dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
  }
}

cat("✅ Logging configuration loaded successfully\n")
cat(paste0("   Log level: ", LOGGING_CONFIG$level, "\n"))
cat(paste0("   Console output: ", LOGGING_CONFIG$console, "\n"))
cat(paste0("   File output: ", LOGGING_CONFIG$file, "\n"))

# =============================================================================
# END OF LOGGING CONFIGURATION
# =============================================================================
