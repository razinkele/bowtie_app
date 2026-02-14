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
