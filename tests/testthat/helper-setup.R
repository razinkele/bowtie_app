# =============================================================================
# Test Helper: Environment Setup
# Description: Sets up the proper environment for running tests
# =============================================================================

# Store original working directory
original_wd <- getwd()

# Determine app root directory
find_app_root <- function() {
  current <- getwd()

  # If we're in tests/testthat, go up two levels
  if (grepl("tests/testthat$|tests\\\\testthat$", current)) {
    return(normalizePath(file.path(current, "../.."), mustWork = FALSE))
  }

  # If we're in tests, go up one level
  if (grepl("tests$", current)) {
    return(normalizePath(file.path(current, ".."), mustWork = FALSE))
  }

  # If app.R exists in current directory, we're in app root
  if (file.exists("app.R")) {
    return(current)
  }

  # Try to find app.R in parent directories
  for (i in 1:3) {
    parent <- normalizePath(file.path(current, paste(rep("..", i), collapse = "/")), mustWork = FALSE)
    if (file.exists(file.path(parent, "app.R"))) {
      return(parent)
    }
  }

  return(current)
}

# Get app root and change to it for sourcing
app_root <- find_app_root()

# Function to source files from app root
source_from_root <- function(file) {
  full_path <- file.path(app_root, file)
  if (file.exists(full_path)) {
    source(full_path, local = FALSE)
    return(TRUE)
  }
  return(FALSE)
}

# Load logging system first (required by other modules)
if (!exists("log_info")) {
  source_from_root("config/logging.R")
}

# Load core dependencies that tests commonly need
suppressWarnings(suppressMessages({
  if (!require("dplyr", quietly = TRUE)) library(dplyr)
  if (!require("jsonlite", quietly = TRUE)) library(jsonlite)
}))

# Helper function to load guided workflow with all dependencies
load_guided_workflow <- function() {
  old_wd <- getwd()
  tryCatch({
    setwd(app_root)

    # Load dependencies in order - use local=FALSE to make functions available globally
    if (!exists("log_info", envir = .GlobalEnv)) source("config/logging.R", local = FALSE)
    if (!exists("load_vocabulary", envir = .GlobalEnv)) source("vocabulary.R", local = FALSE)
    if (!exists("WORKFLOW_CONFIG", envir = .GlobalEnv)) source("guided_workflow_config.R", local = FALSE)
    if (!exists("validate_step_1", envir = .GlobalEnv)) source("guided_workflow_validation.R", local = FALSE)
    if (!exists("convert_to_main_data_format", envir = .GlobalEnv)) source("guided_workflow_conversion.R", local = FALSE)

    # Load the main workflow file
    source("guided_workflow.R", local = FALSE)

    setwd(old_wd)
    return(TRUE)
  }, error = function(e) {
    setwd(old_wd)
    warning(paste("Failed to load guided workflow:", e$message))
    return(FALSE)
  })
}

# Helper function to safely initialize workflow state for tests
safe_init_workflow_state <- function() {
  if (!exists("init_workflow_state")) {
    if (!load_guided_workflow()) {
      # Return a minimal mock state if loading fails
      return(list(
        current_step = 1,
        total_steps = 8,
        completed_steps = integer(0),
        progress_percentage = 0,
        workflow_complete = FALSE,
        project_data = list(
          project_name = "",
          central_problem = "",
          activities = character(0),
          pressures = character(0),
          preventive_controls = character(0),
          consequences = character(0),
          protective_controls = character(0),
          escalation_factors = character(0)
        ),
        validation_status = list()
      ))
    }
  }
  return(init_workflow_state())
}

# Message to confirm helper loaded
message("Test helper loaded. App root: ", app_root)

# =============================================================================
# Mock Session Helpers for Server Module Testing
# =============================================================================

#' Create a mock Shiny session for testing server modules
#' @return A list mimicking a Shiny session object
create_mock_session <- function() {
  # Create a minimal mock session
  session <- new.env(parent = emptyenv())

  session$ns <- function(id) id
  session$userData <- new.env(parent = emptyenv())
  session$userData$cache <- list()
  session$token <- paste0("mock_", as.integer(Sys.time()))
  session$clientData <- list(
    url_protocol = "http:",
    url_hostname = "localhost",
    url_port = 3838
  )

  # Mock reactive domain
  session$makeScope <- function(id) session
  session$onSessionEnded <- function(callback) invisible(NULL)
  session$onFlushed <- function(callback, once = TRUE) invisible(NULL)

  class(session) <- c("ShinySession", "R6", class(session))
  return(session)
}

#' Create mock reactive values for testing
#' @param ... Named values to initialize
#' @return A reactiveValues-like list
create_mock_reactive_values <- function(...) {
  values <- list(...)

  # Wrap each value in a function to mimic reactiveVal behavior
  result <- lapply(values, function(v) {
    stored_value <- v
    function(new_value) {
      if (missing(new_value)) {
        return(stored_value)
      } else {
        stored_value <<- new_value
        invisible(stored_value)
      }
    }
  })

  return(result)
}

#' Create mock input object for testing
#' @param ... Named input values
#' @return A list mimicking Shiny input
create_mock_input <- function(...) {
  values <- list(...)
  class(values) <- c("reactivevalues", "list")
  return(values)
}

# =============================================================================
# Cached Vocabulary Fixture
# =============================================================================

# Cache vocabulary data to avoid repeated loading
.test_vocabulary_cache <- new.env(parent = emptyenv())

#' Get cached test vocabulary data
#' @return Vocabulary data list with activities, pressures, controls, consequences
get_test_vocabulary <- function() {
  # Helper to create mock vocabulary data
  create_mock_vocabulary <- function() {
    list(
      activities = data.frame(
        id = c("1", "1.1", "1.2"),
        name = c("ACTIVITIES", "Marine Transport", "Fishing"),
        level = c(1, 2, 2),
        stringsAsFactors = FALSE
      ),
      pressures = data.frame(
        id = c("1", "1.1"),
        name = c("PRESSURES", "Water Pollution"),
        level = c(1, 2),
        stringsAsFactors = FALSE
      ),
      controls = data.frame(
        id = c("1", "1.1"),
        name = c("CONTROLS", "Equipment Maintenance"),
        level = c(1, 2),
        stringsAsFactors = FALSE
      ),
      consequences = data.frame(
        id = c("1", "1.1"),
        name = c("CONSEQUENCES", "Ecosystem Damage"),
        level = c(1, 2),
        stringsAsFactors = FALSE
      )
    )
  }

  if (is.null(.test_vocabulary_cache$data)) {
    vocab_data <- tryCatch({
      old_wd <- getwd()
      on.exit(setwd(old_wd), add = TRUE)
      setwd(app_root)
      source("vocabulary.R", local = FALSE)
      load_vocabulary()
    }, error = function(e) {
      NULL
    })

    # Validate the loaded data has expected structure
    required_names <- c("activities", "pressures", "controls", "consequences")
    if (is.null(vocab_data) ||
        !is.list(vocab_data) ||
        !all(required_names %in% names(vocab_data)) ||
        !all(sapply(vocab_data[required_names], is.data.frame))) {
      # Use mock vocabulary if loading fails or structure is invalid
      .test_vocabulary_cache$data <- create_mock_vocabulary()
    } else {
      .test_vocabulary_cache$data <- vocab_data
    }
  }
  return(.test_vocabulary_cache$data)
}

# =============================================================================
# Test Cleanup Helpers
# =============================================================================

#' Execute expression with automatic cleanup
#' @param expr Expression to execute
#' @param cleanup_expr Cleanup expression (runs even on error)
#' @param envir Environment for evaluation (default: caller's environment)
with_test_cleanup <- function(expr, cleanup_expr = NULL, envir = parent.frame()) {
  on.exit({
    if (!is.null(cleanup_expr)) {
      tryCatch(eval(cleanup_expr, envir = envir), error = function(e) NULL)
    }
    gc(verbose = FALSE)
  }, add = TRUE)

  eval(substitute(expr), envir = envir)
}

#' Create a temporary test directory
#' @return Path to temporary directory
create_test_dir <- function() {
  dir <- tempfile(pattern = "bowtie_test_")
  dir.create(dir, recursive = TRUE)
  return(dir)
}

#' Clean up temporary test files
#' @param paths Vector of paths to remove
cleanup_test_files <- function(paths) {
  for (path in paths) {
    if (file.exists(path)) {
      unlink(path, recursive = TRUE)
    }
  }
}
