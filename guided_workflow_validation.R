# =============================================================================
# guided_workflow_validation.R
# Validation and Step Data Management Functions
# =============================================================================
# Part of: Guided Workflow System modularization
# Version: 5.4.0
# Date: January 2026
# Description: Contains validation functions, step data saving, and helper utilities
# =============================================================================

# =============================================================================
# HELPER UTILITIES
# =============================================================================

#' Helper operator for default values
#' Returns y if x is NULL, empty, or zero-length character
#' @param x Value to test
#' @param y Default value
#' @return x if valid, otherwise y
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || (is.character(x) && all(nchar(x) == 0))) y else x
}

#' Estimate remaining time based on progress
#' @param state Current workflow state
#' @return Estimated minutes remaining
estimate_remaining_time <- function(state) {
  step_durations <- c(2.5, 4, 7.5, 6.5, 4, 6.5, 4, 2.5)  # Average minutes per step
  remaining_steps <- setdiff(1:state$total_steps, state$completed_steps)
  sum(step_durations[remaining_steps])
}

# =============================================================================
# STEP VALIDATION FUNCTIONS
# =============================================================================

#' Validate step completion
#' @param step_number Step number to validate (as character or numeric)
#' @param data Step data to validate
#' @return List with valid (boolean) and message
validate_step <- function(step_number, data) {
  switch(as.character(step_number),
         "1" = validate_step1(data),
         "2" = validate_step2(data),
         "3" = validate_step3(data),
         "4" = validate_step4(data),
         "5" = validate_step5(data),
         "6" = validate_step6(data),
         "7" = validate_step7(data),
         "8" = validate_step8(data),
         # Default
         list(valid = TRUE, message = "")
  )
}

#' Validate current step before proceeding
#' @param state Current workflow state
#' @param input Shiny input object
#' @param current_lang Current language code (for translations)
#' @return List with is_valid (boolean) and message
validate_current_step <- function(state, input, current_lang = "en") {
  step <- state$current_step

  # Basic validation based on step number
  validation <- switch(as.character(step),
    "1" = {
      # Step 1: Project Setup
      project_name <- input$project_name
      if (is.null(project_name) || nchar(trimws(project_name)) == 0) {
        # Try to use translation function if available
        msg <- tryCatch(
          t("gw_enter_project_name", current_lang),
          error = function(e) "Please enter a project name"
        )
        list(is_valid = FALSE, message = msg)
      } else {
        list(is_valid = TRUE, message = "")
      }
    },
    "2" = {
      # Step 2: Central Problem
      problem <- input$problem_statement
      if (is.null(problem) || nchar(trimws(problem)) == 0) {
        msg <- tryCatch(
          t("gw_define_central_problem", current_lang),
          error = function(e) "Please define the central problem"
        )
        list(is_valid = FALSE, message = msg)
      } else {
        list(is_valid = TRUE, message = "")
      }
    },
    "3" = {
      # Step 3: Activities and Pressures
      # Optional validation - can proceed without entries
      list(is_valid = TRUE, message = "")
    },
    # Steps 4-7 have no mandatory fields (placeholders)
    "4" = list(is_valid = TRUE, message = ""),
    "5" = list(is_valid = TRUE, message = ""),
    "6" = list(is_valid = TRUE, message = ""),
    "7" = list(is_valid = TRUE, message = ""),
    "8" = list(is_valid = TRUE, message = ""),
    # Default
    list(is_valid = TRUE, message = "")
  )

  return(validation)
}

#' Step 1 validation: Project Setup
#' @param data Project data
#' @return List with valid and message
validate_step1 <- function(data) {
  list(
    valid = !is.null(data$project_name) && nchar(data$project_name) > 0,
    message = "Project name is required"
  )
}

#' Step 2 validation: Central Problem
#' @param data Project data
#' @return List with valid and message
validate_step2 <- function(data) {
  list(
    valid = !is.null(data$central_problem) && nchar(data$central_problem) > 0,
    message = "Central problem definition is required"
  )
}

#' Step 3 validation: Activities and Pressures
#' @param data Project data
#' @return List with valid and message
validate_step3 <- function(data) {
  # Optional - can proceed without entries
  list(valid = TRUE, message = "")
}

#' Step 4 validation: Preventive Controls
#' @param data Project data
#' @return List with valid and message
validate_step4 <- function(data) {
  list(valid = TRUE, message = "")
}

#' Step 5 validation: Consequences
#' @param data Project data
#' @return List with valid and message
validate_step5 <- function(data) {
  list(valid = TRUE, message = "")
}

#' Step 6 validation: Protective Controls
#' @param data Project data
#' @return List with valid and message
validate_step6 <- function(data) {
  list(valid = TRUE, message = "")
}

#' Step 7 validation: Review
#' @param data Project data
#' @return List with valid and message
validate_step7 <- function(data) {
  list(valid = TRUE, message = "")
}

#' Step 8 validation: Export
#' @param data Project data
#' @return List with valid and message
validate_step8 <- function(data) {
  list(valid = TRUE, message = "")
}

# =============================================================================
# STEP DATA SAVING
# =============================================================================

#' Save step data to workflow state
#' @param state Current workflow state
#' @param input Shiny input object
#' @return Updated workflow state
save_step_data <- function(state, input) {
  step <- state$current_step

  # Save data based on current step
  if (step == 1) {
    # Save project setup data
    state$project_data$project_name <- input$project_name
    state$project_data$project_location <- input$project_location
    state$project_data$project_type <- input$project_type
    state$project_data$project_description <- input$project_description
    state$project_name <- input$project_name  # Also save at top level
  } else if (step == 2) {
    # Save central problem data
    state$project_data$problem_statement <- input$problem_statement
    state$project_data$problem_category <- input$problem_category
    state$project_data$problem_details <- input$problem_details
    state$project_data$problem_scale <- input$problem_scale
    state$project_data$problem_urgency <- input$problem_urgency
    state$central_problem <- input$problem_statement  # Also save at top level
  } else if (step == 3) {
    # Save activities and pressures data
    # Note: The data is already being saved in real-time by the Add Activity/Pressure handlers
    # We just need to ensure it's preserved in the state
    # Don't overwrite with empty values
    if (is.null(state$project_data$activities)) {
      state$project_data$activities <- list()
    }
    if (is.null(state$project_data$pressures)) {
      state$project_data$pressures <- list()
    }
  } else if (step == 4) {
    # Save preventive controls data
    # Note: The data is already being saved in real-time by the Add Control handler
    # We just need to ensure it's preserved in the state
    if (is.null(state$project_data$preventive_controls)) {
      state$project_data$preventive_controls <- list()
    }
  } else if (step == 5) {
    # Save consequences data
    # Note: The data is already being saved in real-time by the Add Consequence handler
    # We just need to ensure it's preserved in the state
    if (is.null(state$project_data$consequences)) {
      state$project_data$consequences <- list()
    }
  } else if (step == 6) {
    # Save protective controls data
    # Note: The data is already being saved in real-time by the Add Protective Control handler
    # We just need to ensure it's preserved in the state
    if (is.null(state$project_data$protective_controls)) {
      state$project_data$protective_controls <- list()
    }
  } else if (step == 7) {
    # Save escalation factors data
    # Note: The data is already being saved in real-time by the Add Escalation Factor handler
    # We just need to ensure it's preserved in the state
    if (is.null(state$project_data$escalation_factors)) {
      state$project_data$escalation_factors <- list()
    }
  }
  # Step 8 is review only - no data to save

  # Record timestamp for this step
  state$step_times[[paste0("step_", step)]] <- Sys.time()

  return(state)
}

cat("   - guided_workflow_validation.R loaded (validation + save functions)\n")
