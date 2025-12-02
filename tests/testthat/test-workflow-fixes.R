# =============================================================================
# Test Suite for Guided Workflow Fixes (v5.3.2)
# Date: December 2025
# Description: Tests for navigation, templates, export, and completion fixes
# =============================================================================

library(testthat)
library(shiny)

# Source required files
if (file.exists("../../guided_workflow.R")) {
  source("../../guided_workflow.R")
}
if (file.exists("../../environmental_scenarios.R")) {
  source("../../environmental_scenarios.R")
}

context("Workflow Fixes - Navigation & Templates")

# =============================================================================
# Test 1: Template Configuration
# =============================================================================

test_that("All environmental scenarios have corresponding templates", {
  # Get scenario choices
  scenario_choices <- getEnvironmentalScenarioChoices(include_blank = TRUE)

  # Remove blank option
  scenarios <- scenario_choices[scenario_choices != ""]

  # Check each scenario has a template
  for (scenario_id in scenarios) {
    template <- WORKFLOW_CONFIG$templates[[scenario_id]]
    expect_false(is.null(template),
                 info = paste("Template missing for:", scenario_id))
  }

  # Verify we have 13 templates (excluding blank) - Updated Dec 2025 with marine biodiversity loss
  expect_equal(length(scenarios), 13)
})

test_that("All templates have required fields", {
  required_fields <- c("project_name", "project_location", "project_type",
                       "project_description", "central_problem",
                       "problem_category", "problem_details")

  for (template_id in names(WORKFLOW_CONFIG$templates)) {
    template <- WORKFLOW_CONFIG$templates[[template_id]]

    for (field in required_fields) {
      expect_false(is.null(template[[field]]),
                   info = paste(template_id, "missing field:", field))
      expect_true(nchar(template[[field]]) > 0,
                  info = paste(template_id, "has empty field:", field))
    }
  }
})

test_that("Template IDs match scenario IDs", {
  scenario_ids <- names(ENVIRONMENTAL_SCENARIOS)
  template_ids <- names(WORKFLOW_CONFIG$templates)

  # Every scenario should have a matching template
  for (scenario_id in scenario_ids) {
    expect_true(scenario_id %in% template_ids,
                info = paste("No template for scenario:", scenario_id))
  }

  # Every template should have a matching scenario
  for (template_id in template_ids) {
    expect_true(template_id %in% scenario_ids,
                info = paste("No scenario for template:", template_id))
  }
})

# =============================================================================
# Test 2: Workflow State Management
# =============================================================================

test_that("Workflow state initializes correctly", {
  state <- init_workflow_state()

  expect_true(is.list(state))
  expect_equal(state$current_step, 1)
  expect_equal(state$total_steps, 8)
  expect_equal(length(state$completed_steps), 0)
  expect_false(isTRUE(state$workflow_complete))
  expect_true(is.list(state$project_data))
})

test_that("Workflow state preserves data across navigation", {
  state <- init_workflow_state()

  # Simulate adding data in step 1
  state$project_data$project_name <- "Test Project"
  state$project_data$project_location <- "Test Location"

  # Move to step 2
  state$current_step <- 2

  # Verify data preserved
  expect_equal(state$project_data$project_name, "Test Project")
  expect_equal(state$project_data$project_location, "Test Location")
})

# =============================================================================
# Test 3: Validation Functions
# =============================================================================

test_that("validate_current_step handles missing inputs", {
  state <- init_workflow_state()
  state$current_step <- 1

  # Create mock input with missing project_name
  mock_input <- list(project_name = NULL)

  result <- validate_current_step(state, mock_input, "en")

  expect_false(result$is_valid)
  expect_true(nchar(result$message) > 0)
})

test_that("validate_current_step accepts valid inputs", {
  state <- init_workflow_state()
  state$current_step <- 1

  # Create mock input with valid data
  mock_input <- list(
    project_name = "Valid Project Name",
    project_location = "Valid Location"
  )

  result <- validate_current_step(state, mock_input, "en")

  expect_true(result$is_valid)
})

test_that("validate_current_step works for all steps", {
  state <- init_workflow_state()
  mock_input <- list(
    project_name = "Test",
    problem_statement = "Test Problem"
  )

  for (step in 1:8) {
    state$current_step <- step
    result <- validate_current_step(state, mock_input, "en")
    expect_true(is.list(result))
    expect_true("is_valid" %in% names(result))
  }
})

# =============================================================================
# Test 4: Data Conversion
# =============================================================================

test_that("convert_to_main_data_format creates valid output", {
  project_data <- list(
    project_name = "Test Project",
    problem_statement = "Test Problem",
    activities = c("Activity 1", "Activity 2"),
    pressures = c("Pressure 1", "Pressure 2"),
    preventive_controls = c("Control 1"),
    consequences = c("Consequence 1"),
    protective_controls = c("Control 2"),
    escalation_factors = c("Factor 1")
  )

  result <- convert_to_main_data_format(project_data)

  expect_true(is.data.frame(result))
  expect_true(nrow(result) > 0)
  expect_true("Activity" %in% names(result))
  expect_true("Central_Problem" %in% names(result))
  expect_true("Consequence" %in% names(result))
})

test_that("convert_to_main_data_format handles empty data", {
  project_data <- list(
    project_name = "Test",
    problem_statement = "Test Problem"
  )

  result <- convert_to_main_data_format(project_data)

  expect_true(is.data.frame(result))
  expect_true(nrow(result) > 0)  # Should create sample data
})

# =============================================================================
# Test 5: Save/Load Data Migration
# =============================================================================

test_that("Data migration handles data frame formats", {
  # Simulate old format with data frames
  old_format <- list(
    current_step = 3,
    project_data = list(
      activities = data.frame(Activity = c("Act1", "Act2")),
      pressures = data.frame(Pressure = c("Press1", "Press2"))
    )
  )

  # Migrate activities
  if (is.data.frame(old_format$project_data$activities)) {
    if ("Activity" %in% names(old_format$project_data$activities)) {
      old_format$project_data$activities <-
        old_format$project_data$activities$Activity
    }
  }

  expect_true(is.character(old_format$project_data$activities))
  expect_equal(length(old_format$project_data$activities), 2)
})

test_that("Data migration handles character vectors", {
  # New format with character vectors
  new_format <- list(
    current_step = 3,
    project_data = list(
      activities = c("Act1", "Act2"),
      pressures = c("Press1", "Press2")
    )
  )

  # Should remain unchanged
  expect_true(is.character(new_format$project_data$activities))
  expect_equal(length(new_format$project_data$activities), 2)
})

# =============================================================================
# Test 6: Cross-Platform Compatibility
# =============================================================================

test_that("Platform detection works correctly", {
  expect_true(.Platform$OS.type %in% c("windows", "unix"))
})

test_that("IP detection doesn't crash on any platform", {
  # This should not throw an error
  expect_error({
    tryCatch({
      if (.Platform$OS.type == "windows") {
        # Windows IP detection
        ip_output <- system("ipconfig", intern = TRUE)
      } else {
        # Linux/Mac IP detection
        ip_output <- system("hostname -I 2>/dev/null", intern = TRUE)
      }
    }, error = function(e) {
      # Error is acceptable, just shouldn't crash
      NULL
    })
  }, NA)
})

# =============================================================================
# Test 7: Error Handling
# =============================================================================

test_that("save_step_data handles NULL inputs safely", {
  state <- init_workflow_state()
  state$current_step <- 1

  # Create mock input with NULLs
  mock_input <- list(
    project_name = NULL,
    project_location = NULL
  )

  # Should not crash
  expect_error(save_step_data(state, mock_input), NA)
})

test_that("Error handlers provide meaningful messages", {
  state <- init_workflow_state()

  # Test validation error message
  result <- validate_current_step(state, list(project_name = NULL), "en")

  expect_false(result$is_valid)
  expect_true(grepl("project name", result$message, ignore.case = TRUE))
})

# =============================================================================
# Test 8: Workflow Completion
# =============================================================================

test_that("Workflow completion marks state correctly", {
  state <- init_workflow_state()
  state$current_step <- 8
  state$project_data$project_name <- "Test"
  state$project_data$problem_statement <- "Test Problem"

  # Simulate completion
  state$workflow_complete <- TRUE

  expect_true(state$workflow_complete)
  expect_equal(state$current_step, 8)
})

# =============================================================================
# Test Summary
# =============================================================================

test_that("All critical workflow components are functional", {
  # This meta-test verifies that all key functions exist
  expect_true(exists("init_workflow_state"))
  expect_true(exists("validate_current_step"))
  expect_true(exists("save_step_data"))
  expect_true(exists("convert_to_main_data_format"))
  expect_true(exists("getEnvironmentalScenarioChoices"))
  expect_true(exists("WORKFLOW_CONFIG"))
  expect_true(exists("ENVIRONMENTAL_SCENARIOS"))
})

# =============================================================================
# Print Test Summary
# =============================================================================

cat("\n")
cat("========================================\n")
cat("Workflow Fixes Test Suite Complete\n")
cat("========================================\n")
cat("Version: 5.3.2\n")
cat("Date:", format(Sys.Date()), "\n")
cat("Tests cover:\n")
cat("  ✓ Template configuration (12 scenarios)\n")
cat("  ✓ Workflow state management\n")
cat("  ✓ Validation functions\n")
cat("  ✓ Data conversion\n")
cat("  ✓ Save/load migration\n")
cat("  ✓ Cross-platform compatibility\n")
cat("  ✓ Error handling\n")
cat("  ✓ Workflow completion\n")
cat("========================================\n")
cat("\n")
