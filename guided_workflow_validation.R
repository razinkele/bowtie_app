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
  step_durations <- c(2.5, 4, 7.5, 6.5, 4, 6.5, 4, 5, 2.5)  # Average minutes per step (9 steps)
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
         "8" = validate_step8_review(data),
         "9" = validate_step9(data),
         # Default
         list(valid = TRUE, message = "")
  )
}

#' Validate a required text field with length constraints
#' Helper function to reduce nested conditionals in validation
#' @param value Text value to validate
#' @param field_name Human-readable field name for error messages
#' @param max_length Maximum allowed length
#' @param translation_key Translation key for empty field error
#' @param current_lang Current language code
#' @return List with is_valid (boolean) and message
validate_text_field <- function(value, field_name, max_length, translation_key = NULL, current_lang = "en") {
  # Check for empty/NULL
  if (is.null(value) || nchar(trimws(value)) == 0) {
    msg <- if (!is.null(translation_key)) {
      tryCatch(t(translation_key, current_lang), error = function(e) paste("Please enter", field_name))
    } else {
      paste("Please enter", field_name)
    }
    return(list(is_valid = FALSE, message = msg))
  }

  # Check length constraint
  if (nchar(value) > max_length) {
    return(list(is_valid = FALSE, message = paste(field_name, "too long. Maximum", max_length, "characters.")))
  }

  # Valid
  list(is_valid = TRUE, message = "")
}

#' Validate current step before proceeding
#' Enhanced with input length validation (Issue #4 fix)
#' Refactored to use helper function (Issue #16 fix - reduce nested conditionals)
#' @param state Current workflow state
#' @param input Shiny input object
#' @param current_lang Current language code (for translations)
#' @return List with is_valid (boolean) and message
validate_current_step <- function(state, input, current_lang = "en") {
  step <- state$current_step

  # Get max lengths from constants (with fallbacks)
  max_name_length <- if (exists("MAX_NAME_LENGTH")) MAX_NAME_LENGTH else 200
  max_text_length <- if (exists("MAX_TEXT_LENGTH")) MAX_TEXT_LENGTH else 1000

  # Validation using helper function to reduce nesting
  validation <- switch(as.character(step),
    "1" = validate_text_field(input$project_name, "Project name", max_name_length,
                              "gw_enter_project_name", current_lang),
    "2" = validate_text_field(input$problem_statement, "Problem statement", max_text_length,
                              "gw_define_central_problem", current_lang),
    # Step 8: Review & Adjust — require at least 1 activity, pressure, consequence
    "8" = {
      state_data <- if (!is.null(input$review_activities)) {
        list(
          activities = input$review_activities,
          pressures = input$review_pressures,
          consequences = input$review_consequences,
          excluded_activities = character(0),
          excluded_pressures = character(0),
          excluded_consequences = character(0)
        )
      } else {
        list(activities = list(), pressures = list(), consequences = list(),
             excluded_activities = character(0), excluded_pressures = character(0),
             excluded_consequences = character(0))
      }
      result <- validate_step8_review(state_data)
      list(is_valid = result$valid, message = result$message)
    },
    # Steps 3-7, 9: Optional validation
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

#' Step 8 validation: Review & Adjust
#' Requires at least 1 activity, 1 pressure, and 1 consequence
#' @param data Project data (with exclusion lists)
#' @return List with valid and message
validate_step8_review <- function(data) {
  activities <- data$activities %||% list()
  excluded_act <- data$excluded_activities %||% character(0)
  included_act <- setdiff(as.character(activities), excluded_act)

  pressures <- data$pressures %||% list()
  excluded_pres <- data$excluded_pressures %||% character(0)
  included_pres <- setdiff(as.character(pressures), excluded_pres)

  consequences <- data$consequences %||% list()
  excluded_cons <- data$excluded_consequences %||% character(0)
  included_cons <- setdiff(as.character(consequences), excluded_cons)

  if (length(included_act) == 0) {
    return(list(valid = FALSE, message = "At least one activity must be selected to proceed."))
  }
  if (length(included_pres) == 0) {
    return(list(valid = FALSE, message = "At least one pressure must be selected to proceed."))
  }
  if (length(included_cons) == 0) {
    return(list(valid = FALSE, message = "At least one consequence must be selected to proceed."))
  }

  list(valid = TRUE, message = "")
}

#' Step 9 validation: Finalize & Export
#' @param data Project data
#' @return List with valid and message
validate_step9 <- function(data) {
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
    if (is.null(state$project_data$activities)) {
      state$project_data$activities <- list()
    }
    if (is.null(state$project_data$pressures)) {
      state$project_data$pressures <- list()
    }
    # Note: Connection persistence (activity_pressure_connections) happens in
    # the next_step observer in guided_workflow.R where reactiveVals are in scope.
  } else if (step == 4) {
    # Save preventive controls data
    if (is.null(state$project_data$preventive_controls)) {
      state$project_data$preventive_controls <- list()
    }
    # Note: Connection persistence (preventive_control_links) happens in
    # the next_step observer in guided_workflow.R where reactiveVals are in scope.
  } else if (step == 5) {
    # Save consequences data
    if (is.null(state$project_data$consequences)) {
      state$project_data$consequences <- list()
    }
  } else if (step == 6) {
    # Save protective controls data
    if (is.null(state$project_data$protective_controls)) {
      state$project_data$protective_controls <- list()
    }
    # Note: Connection persistence (consequence_protective_links) happens in
    # the next_step observer in guided_workflow.R where reactiveVals are in scope.
  } else if (step == 7) {
    # Save escalation factors data
    if (is.null(state$project_data$escalation_factors)) {
      state$project_data$escalation_factors <- list()
    }
  } else if (step == 8) {
    # Review exclusions are saved by the next_step observer in guided_workflow.R
  }
  # Step 9 is finalize only - no data to save

  # Record timestamp for this step
  state$step_times[[paste0("step_", step)]] <- Sys.time()

  return(state)
}

bowtie_log("   - guided_workflow_validation.R loaded (validation + save functions)", level = "debug")
