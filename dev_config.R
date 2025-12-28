# dev_config.R
# Enhanced Development Framework Configuration (Version 5.2)
# Modern development tools, hot reload, debugging, and optimization settings

# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# =============================================================================

cat("🔧 Loading Enhanced Development Framework v5.2\n")

# Load APP_CONFIG for centralized configuration
if (file.exists("config.R") && !exists("APP_CONFIG")) {
  source("config.R", local = FALSE)
}

# Development mode settings
dev_config <- list(
  # Environment settings
  mode = Sys.getenv("SHINY_ENV", "development"),  # development, testing, production
  debug = TRUE,
  hot_reload = TRUE,

  # Performance settings
  cache_enabled = TRUE,
  memory_monitoring = TRUE,
  profiling_enabled = TRUE,

  # UI/UX settings
  show_debug_panel = TRUE,
  icon_standardization = "icon_function",  # icon_function, tags_i, mixed
  theme_validation = TRUE,

  # Testing settings
  auto_test = FALSE,
  test_coverage = TRUE,
  performance_regression = TRUE,

  # Network settings
  host = ifelse(exists("APP_CONFIG"), APP_CONFIG$DEFAULT_HOST, "0.0.0.0"),
  port = ifelse(exists("APP_CONFIG"), APP_CONFIG$DEFAULT_PORT, 3838),
  network_accessible = TRUE,

  # Logging settings
  log_level = "INFO",  # DEBUG, INFO, WARN, ERROR
  log_to_file = TRUE,
  log_performance = TRUE
)

# =============================================================================
# DEVELOPMENT UTILITIES
# =============================================================================

#' Enhanced Hot Reload Function
#' Automatically reloads changed files during development
setup_hot_reload <- function(watch_files = c("ui.R", "server.R", "global.R",
                                             "guided_workflow.R", "utils.R")) {
  if (!dev_config$hot_reload) return(invisible())

  cat("🔄 Hot reload enabled for files:", paste(watch_files, collapse = ", "), "\n")

  # Store file modification times
  file_times <- sapply(watch_files[file.exists(watch_files)], file.mtime)

  # Return file watcher function
  function() {
    current_times <- sapply(names(file_times), file.mtime)
    changed_files <- names(file_times)[current_times != file_times]

    if (length(changed_files) > 0) {
      cat("📝 Files changed:", paste(changed_files, collapse = ", "), "\n")
      cat("🔄 Reloading application...\n")
      file_times <<- current_times
      return(TRUE)
    }
    return(FALSE)
  }
}

#' Performance Profiler
#' Monitors application performance during development
setup_performance_profiler <- function() {
  if (!dev_config$profiling_enabled) return(invisible())

  cat("📊 Performance profiling enabled\n")

  # Memory monitoring
  if (dev_config$memory_monitoring) {
    start_memory <- gc()
    cat("💾 Initial memory usage:",
        round(sum(start_memory[,"used"] * c(8, 8)) / 1024 / 1024, 2), "MB\n")
  }

  # Performance logging
  performance_log <- data.frame(
    timestamp = Sys.time(),
    event = "app_start",
    memory_mb = ifelse(dev_config$memory_monitoring,
                       round(sum(gc()[,"used"] * c(8, 8)) / 1024 / 1024, 2),
                       NA),
    stringsAsFactors = FALSE
  )

  # Return logging function
  function(event_name) {
    if (dev_config$log_performance) {
      current_memory <- ifelse(dev_config$memory_monitoring,
                               round(sum(gc()[,"used"] * c(8, 8)) / 1024 / 1024, 2),
                               NA)

      new_entry <- data.frame(
        timestamp = Sys.time(),
        event = event_name,
        memory_mb = current_memory,
        stringsAsFactors = FALSE
      )

      performance_log <<- rbind(performance_log, new_entry)

      cat("📈 Performance:", event_name,
          ifelse(is.na(current_memory), "", paste("(", current_memory, "MB)")), "\n")
    }
  }
}

#' Development Logger
#' Enhanced logging for development debugging
setup_dev_logger <- function() {
  log_file <- paste0("dev_logs/app_", Sys.Date(), ".log")

  # Create logs directory if needed
  if (!dir.exists("dev_logs")) dir.create("dev_logs", recursive = TRUE)

  function(level = "INFO", message, category = "GENERAL") {
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    log_entry <- paste0("[", timestamp, "] [", level, "] [", category, "] ", message)

    # Console output
    if (dev_config$debug) {
      cat("🔍", log_entry, "\n")
    }

    # File output
    if (dev_config$log_to_file) {
      cat(log_entry, "\n", file = log_file, append = TRUE)
    }
  }
}

#' Icon Standardization Validator
#' Ensures consistent icon usage across the application
validate_icon_usage <- function() {
  if (!dev_config$theme_validation) return(invisible())

  cat("🎨 Validating icon standardization...\n")

  files_to_check <- c("ui.R", "server.R", "guided_workflow.R")
  existing_files <- files_to_check[file.exists(files_to_check)]

  issues <- list()

  for (file in existing_files) {
    content <- readLines(file, warn = FALSE)

    # Check for inconsistent icon usage
    tags_i_lines <- grep('tags\\$i\\(class = "fas', content)
    icon_lines <- grep('icon\\("', content)

    if (length(tags_i_lines) > 0) {
      issues[[file]] <- list(
        type = "mixed_icon_usage",
        tags_i_count = length(tags_i_lines),
        icon_count = length(icon_lines),
        lines = tags_i_lines
      )
    }
  }

  if (length(issues) > 0) {
    cat("⚠️ Icon standardization issues found:\n")
    for (file in names(issues)) {
      issue <- issues[[file]]
      cat("  📁", file, "- Mixed usage:", issue$tags_i_count, "tags$i() calls\n")
    }
  } else {
    cat("✅ Icon usage is standardized across all files\n")
  }

  invisible(issues)
}

#' Dependency Validator
#' Checks for circular dependencies and import issues
validate_dependencies <- function() {
  cat("🔗 Validating module dependencies...\n")

  # Check guided_workflow.R for circular dependencies (self-references)
  workflow_content <- if (file.exists("guided_workflow.R")) {
    readLines("guided_workflow.R", warn = FALSE)
  } else { character(0) }

  circular_imports <- grep('source\\("guided_workflow\\.R"\\)', workflow_content)

  if (length(circular_imports) > 0) {
    cat("❌ Circular dependency detected in guided_workflow.R\n")
    return(FALSE)
  }

  # Check global.R loading order
  global_content <- if (file.exists("global.R")) {
    readLines("global.R", warn = FALSE)
  } else { character(0) }

  workflow_line <- grep('source\\("guided_workflow\\.R"\\)', global_content)

  if (length(workflow_line) == 0) {
    cat("⚠️ guided_workflow.R not loaded in global.R\n")
    return(FALSE)
    }
  }

  cat("✅ Module dependencies are properly structured\n")
  return(TRUE)
}

# =============================================================================
# DEVELOPMENT STARTUP SEQUENCE
# =============================================================================

#' Initialize Development Environment
init_dev_environment <- function() {
  cat("🚀 Initializing Enhanced Development Environment v5.2\n")
  cat("===============================================\n")

  # Setup components
  dev_logger <- setup_dev_logger()
  performance_profiler <- setup_performance_profiler()
  hot_reload_watcher <- setup_hot_reload()

  dev_logger("INFO", "Development environment initialized", "STARTUP")

  # Run validations
  validate_dependencies()
  validate_icon_usage()

  # Environment info
  cat("📋 Environment Configuration:\n")
  cat("   Mode:", dev_config$mode, "\n")
  cat("   Host:", dev_config$host, "Port:", dev_config$port, "\n")
  cat("   Hot Reload:", ifelse(dev_config$hot_reload, "✅", "❌"), "\n")
  cat("   Debug Mode:", ifelse(dev_config$debug, "✅", "❌"), "\n")
  cat("   Performance Profiling:", ifelse(dev_config$profiling_enabled, "✅", "❌"), "\n")
  cat("   Memory Monitoring:", ifelse(dev_config$memory_monitoring, "✅", "❌"), "\n")

  # Return development tools
  list(
    logger = dev_logger,
    profiler = performance_profiler,
    hot_reload = hot_reload_watcher,
    config = dev_config
  )
}

# =============================================================================
# AUTO-INITIALIZATION
# =============================================================================

# Initialize development environment automatically
if (interactive() || Sys.getenv("SHINY_ENV") == "development") {
  dev_tools <- init_dev_environment()

  # Make tools available globally
  .GlobalEnv$dev_log <- dev_tools$logger
  .GlobalEnv$dev_profile <- dev_tools$profiler
  .GlobalEnv$dev_hot_reload <- dev_tools$hot_reload

  cat("✅ Development tools ready!\n")
  cat("   Usage: dev_log('INFO', 'message'), dev_profile('event_name')\n")
  cat("===============================================\n\n")
}