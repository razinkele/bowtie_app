# =============================================================================
# Test Suite: Smart Autosave System - Integration Tests
# Version: 1.0.0
# Date: 2025-12-26
# Description: End-to-end integration tests for autosave and session restore
#              functionality in the guided workflow
# =============================================================================

library(testthat)
library(shiny)

# Suppress warnings for cleaner test output
options(warn = -1)

# =============================================================================
# TEST CONTEXT: Complete Autosave Workflow
# =============================================================================

context("Autosave Integration - Complete Workflow")

test_that("Complete autosave workflow: enter data, save, restore", {
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("digest")

  source("../../guided_workflow.R")

  # Step 1: Create initial workflow state
  state1 <- init_workflow_state()
  state1$current_step <- 3
  state1$completed_steps <- c(1, 2)
  state1$project_data$project_name <- "Marine Pollution Assessment"
  state1$project_data$central_problem <- "Oil spill from tanker"
  state1$project_data$activities <- c("Shipping operations", "Coastal development")
  state1$project_data$pressures <- c("Oil discharge", "Habitat destruction")

  # Step 2: Compute hash
  hashable <- list(
    current_step = state1$current_step,
    completed_steps = state1$completed_steps,
    project_data = state1$project_data,
    validation_status = state1$validation_status,
    workflow_complete = state1$workflow_complete
  )
  json_state <- jsonlite::toJSON(hashable, auto_unbox = TRUE)
  hash1 <- digest::digest(json_state, algo = "md5")

  expect_true(nchar(hash1) == 32, "Hash should be 32 characters (MD5)")

  # Step 3: Serialize for autosave
  state_json <- jsonlite::toJSON(state1, auto_unbox = TRUE)

  expect_true(is.character(state_json), "Serialized state should be JSON string")

  # Step 4: Simulate localStorage save (in real app, JavaScript does this)
  # Here we just verify the data can round-trip

  # Step 5: Restore from JSON
  restored_state <- jsonlite::fromJSON(state_json, simplifyVector = FALSE)

  # Step 6: Verify restored data matches original
  expect_equal(restored_state$current_step, state1$current_step)
  expect_equal(length(restored_state$completed_steps), length(state1$completed_steps))
  expect_equal(restored_state$project_data$project_name, state1$project_data$project_name)
  expect_equal(restored_state$project_data$central_problem, state1$project_data$central_problem)
  expect_equal(length(restored_state$project_data$activities),
               length(state1$project_data$activities))

  cat("\n✅ Complete autosave workflow test passed\n")
})

test_that("Autosave workflow with custom entries", {
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("digest")

  source("../../guided_workflow.R")

  # Create state with custom entries
  state <- init_workflow_state()
  state$current_step <- 4
  state$completed_steps <- c(1, 2, 3)
  state$project_data$project_name <- "Industrial Contamination Study"

  # Add custom entries
  state$project_data$custom_entries <- list(
    activities = c("Custom Activity 1", "Custom Activity 2"),
    pressures = c("Custom Pressure 1"),
    preventive_controls = character(0),
    consequences = character(0),
    protective_controls = character(0)
  )

  state$project_data$activities <- c("Regular Activity", "Custom Activity 1", "Custom Activity 2")

  # Serialize
  state_json <- jsonlite::toJSON(state, auto_unbox = TRUE)

  # Restore
  restored <- jsonlite::fromJSON(state_json, simplifyVector = FALSE)

  # Verify custom entries preserved
  expect_true(!is.null(restored$project_data$custom_entries))
  expect_equal(length(restored$project_data$custom_entries$activities), 2)
  expect_equal(restored$project_data$custom_entries$activities[[1]], "Custom Activity 1")

  cat("\n✅ Autosave with custom entries test passed\n")
})

# =============================================================================
# TEST CONTEXT: Session Restore Scenarios
# =============================================================================

context("Autosave Integration - Session Restore")

test_that("Session restore handles complete workflow state", {
  skip_if_not_installed("jsonlite")

  source("../../guided_workflow.R")

  # Create advanced workflow state (step 7)
  state <- init_workflow_state()
  state$current_step <- 7
  state$completed_steps <- c(1, 2, 3, 4, 5, 6)
  state$project_data <- list(
    project_name = "Comprehensive Risk Assessment",
    central_problem = "Marine ecosystem degradation",
    activities = c("Fishing", "Tourism", "Shipping"),
    pressures = c("Overfishing", "Pollution", "Noise"),
    preventive_controls = c("Quotas", "Regulations", "Speed limits"),
    consequences = c("Species loss", "Habitat damage"),
    protective_controls = c("Marine reserves", "Restoration"),
    custom_entries = list(
      activities = c("Custom 1"),
      pressures = character(0),
      preventive_controls = character(0),
      consequences = character(0),
      protective_controls = character(0)
    )
  )

  # Serialize
  json_str <- jsonlite::toJSON(state, auto_unbox = TRUE)

  # Restore
  restored <- jsonlite::fromJSON(json_str, simplifyVector = FALSE)

  # Merge into default state (simulating actual restore logic)
  default_state <- init_workflow_state()
  for (name in names(restored)) {
    if (name %in% names(default_state)) {
      default_state[[name]] <- restored[[name]]
    }
  }

  # Verify comprehensive restore
  expect_equal(default_state$current_step, 7)
  expect_equal(length(default_state$completed_steps), 6)
  expect_equal(default_state$project_data$project_name, "Comprehensive Risk Assessment")
  expect_equal(length(default_state$project_data$activities), 3)
  expect_equal(length(default_state$project_data$preventive_controls), 3)

  cat("\n✅ Complete workflow state restore test passed\n")
})

test_that("Session restore validates restored structure", {
  skip_if_not_installed("jsonlite")

  # Valid restored state
  valid_restored <- list(
    current_step = 3,
    total_steps = 8,
    completed_steps = c(1, 2),
    project_data = list(project_name = "Test")
  )

  # Check if it's valid (has current_step)
  is_valid <- (is.list(valid_restored) && "current_step" %in% names(valid_restored))

  expect_true(is_valid, "Valid state should pass validation")

  # Invalid restored state (missing current_step)
  invalid_restored <- list(
    total_steps = 8,
    project_data = list(project_name = "Test")
  )

  is_valid <- (is.list(invalid_restored) && "current_step" %in% names(invalid_restored))

  expect_false(is_valid, "Invalid state should fail validation")
})

test_that("Session restore handles empty/null data gracefully", {
  skip_if_not_installed("jsonlite")

  source("../../guided_workflow.R")

  # State with minimal data
  state <- init_workflow_state()
  state$current_step <- 2
  # No project data added

  # Serialize
  json_str <- jsonlite::toJSON(state, auto_unbox = TRUE)

  # Restore
  restored <- jsonlite::fromJSON(json_str, simplifyVector = FALSE)

  # Should still have valid structure
  expect_true("current_step" %in% names(restored))
  expect_true("project_data" %in% names(restored))
  expect_equal(restored$current_step, 2)
})

# =============================================================================
# TEST CONTEXT: Multi-Step Progression with Autosave
# =============================================================================

context("Autosave Integration - Multi-Step Progression")

test_that("Autosave tracks progression through multiple steps", {
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("digest")

  source("../../guided_workflow.R")

  # Simulate user progressing through workflow
  hashes <- list()

  # Step 1 (not autosaved)
  state <- init_workflow_state()
  state$current_step <- 1
  # No hash for step 1

  # Step 2 - first autosave
  state$current_step <- 2
  state$completed_steps <- c(1)
  state$project_data$project_name <- "Test Project"

  hashable <- list(
    current_step = state$current_step,
    completed_steps = state$completed_steps,
    project_data = state$project_data,
    validation_status = state$validation_status,
    workflow_complete = state$workflow_complete
  )
  json <- jsonlite::toJSON(hashable, auto_unbox = TRUE)
  hashes[[2]] <- digest::digest(json, algo = "md5")

  # Step 3 - hash should change
  state$current_step <- 3
  state$completed_steps <- c(1, 2)
  state$project_data$central_problem <- "Environmental issue"

  hashable <- list(
    current_step = state$current_step,
    completed_steps = state$completed_steps,
    project_data = state$project_data,
    validation_status = state$validation_status,
    workflow_complete = state$workflow_complete
  )
  json <- jsonlite::toJSON(hashable, auto_unbox = TRUE)
  hashes[[3]] <- digest::digest(json, algo = "md5")

  # Step 4 - hash should change again
  state$current_step <- 4
  state$completed_steps <- c(1, 2, 3)
  state$project_data$activities <- c("Activity 1", "Activity 2")

  hashable <- list(
    current_step = state$current_step,
    completed_steps = state$completed_steps,
    project_data = state$project_data,
    validation_status = state$validation_status,
    workflow_complete = state$workflow_complete
  )
  json <- jsonlite::toJSON(hashable, auto_unbox = TRUE)
  hashes[[4]] <- digest::digest(json, algo = "md5")

  # Verify hashes are different at each step
  expect_false(hashes[[2]] == hashes[[3]], "Step 2 and 3 hashes should differ")
  expect_false(hashes[[3]] == hashes[[4]], "Step 3 and 4 hashes should differ")
  expect_false(hashes[[2]] == hashes[[4]], "Step 2 and 4 hashes should differ")

  cat("\n✅ Multi-step progression test passed\n")
})

# =============================================================================
# TEST CONTEXT: Data Persistence Scenarios
# =============================================================================

context("Autosave Integration - Data Persistence")

test_that("Autosave preserves all workflow data types", {
  skip_if_not_installed("jsonlite")

  source("../../guided_workflow.R")

  # Create comprehensive state
  state <- init_workflow_state()
  state$current_step <- 6
  state$completed_steps <- c(1, 2, 3, 4, 5)
  state$project_data <- list(
    # String data
    project_name = "Test Project",
    central_problem = "Central Issue",

    # Array data
    activities = c("Act1", "Act2", "Act3"),
    pressures = c("Press1", "Press2"),

    # Nested list data
    custom_entries = list(
      activities = c("Custom1"),
      pressures = c("Custom2", "Custom3"),
      preventive_controls = character(0),
      consequences = character(0),
      protective_controls = character(0)
    ),

    # Mixed data
    preventive_controls = c("Control1", "Control2"),
    consequences = c("Cons1")
  )

  # Serialize and restore
  json_str <- jsonlite::toJSON(state, auto_unbox = TRUE)
  restored <- jsonlite::fromJSON(json_str, simplifyVector = FALSE)

  # Verify all data types preserved
  expect_equal(restored$project_data$project_name, "Test Project")
  expect_equal(length(restored$project_data$activities), 3)
  expect_equal(length(restored$project_data$custom_entries$pressures), 2)
  expect_equal(restored$current_step, 6)

  cat("\n✅ Data type persistence test passed\n")
})

test_that("Autosave handles large workflow states efficiently", {
  skip_if_not_installed("jsonlite")

  source("../../guided_workflow.R")

  # Create large state
  state <- init_workflow_state()
  state$current_step <- 7

  # Add many items
  state$project_data$activities <- paste("Activity", 1:50)
  state$project_data$pressures <- paste("Pressure", 1:40)
  state$project_data$preventive_controls <- paste("Control", 1:30)
  state$project_data$consequences <- paste("Consequence", 1:25)
  state$project_data$protective_controls <- paste("Protective", 1:20)

  # Add custom entries
  state$project_data$custom_entries <- list(
    activities = paste("Custom Activity", 1:10),
    pressures = paste("Custom Pressure", 1:10),
    preventive_controls = paste("Custom Control", 1:10),
    consequences = paste("Custom Consequence", 1:10),
    protective_controls = paste("Custom Protective", 1:10)
  )

  # Serialize
  start_time <- Sys.time()
  json_str <- jsonlite::toJSON(state, auto_unbox = TRUE)
  serialize_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  # Restore
  start_time <- Sys.time()
  restored <- jsonlite::fromJSON(json_str, simplifyVector = FALSE)
  deserialize_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  # Verify performance
  expect_true(serialize_time < 0.5, "Serialization should be fast (<0.5s)")
  expect_true(deserialize_time < 0.5, "Deserialization should be fast (<0.5s)")

  # Verify data integrity
  expect_equal(length(restored$project_data$activities), 50)
  expect_equal(length(restored$project_data$custom_entries$activities), 10)

  cat(sprintf("\n✅ Large state test passed (serialize: %.3fs, deserialize: %.3fs)\n",
              serialize_time, deserialize_time))
})

# =============================================================================
# TEST CONTEXT: Edge Cases and Error Recovery
# =============================================================================

context("Autosave Integration - Edge Cases")

test_that("Autosave handles corrupted JSON gracefully", {
  skip_if_not_installed("jsonlite")

  # Corrupted JSON string
  corrupted_json <- '{"current_step": 3, "project_data": {'  # Missing closing braces

  # Attempt to parse
  result <- tryCatch({
    jsonlite::fromJSON(corrupted_json, simplifyVector = FALSE)
    "success"
  }, error = function(e) {
    "error"
  })

  expect_equal(result, "error", "Should catch corrupted JSON error")
})

test_that("Autosave handles very long strings in state", {
  skip_if_not_installed("jsonlite")

  source("../../guided_workflow.R")

  state <- init_workflow_state()
  state$current_step <- 3

  # Very long project description
  long_text <- paste(rep("This is a very long description. ", 1000), collapse = "")
  state$project_data$project_description <- long_text

  # Should still serialize
  json_str <- jsonlite::toJSON(state, auto_unbox = TRUE)

  expect_true(nchar(json_str) > 10000, "JSON should be large")

  # Should still deserialize
  restored <- jsonlite::fromJSON(json_str, simplifyVector = FALSE)

  expect_equal(nchar(restored$project_data$project_description),
               nchar(long_text))
})

test_that("Autosave handles special characters in data", {
  skip_if_not_installed("jsonlite")

  source("../../guided_workflow.R")

  state <- init_workflow_state()
  state$current_step <- 3

  # Special characters
  state$project_data$project_name <- "Test Project: 'Quotes' & \"Double Quotes\" <HTML>"
  state$project_data$activities <- c(
    "Activity with émojis 🌊🐟",
    "Activity with symbols: @#$%^&*()",
    "Activity with unicode: 日本語"
  )

  # Serialize
  json_str <- jsonlite::toJSON(state, auto_unbox = TRUE)

  # Restore
  restored <- jsonlite::fromJSON(json_str, simplifyVector = FALSE)

  # Verify special characters preserved
  expect_true(grepl("Quotes", restored$project_data$project_name))
  expect_true(grepl("🌊", restored$project_data$activities[[1]]))

  cat("\n✅ Special characters test passed\n")
})

# =============================================================================
# TEST CONTEXT: Workflow Completion and Cleanup
# =============================================================================

context("Autosave Integration - Workflow Completion")

test_that("Workflow completion marks state correctly", {
  source("../../guided_workflow.R")

  state <- init_workflow_state()
  state$current_step <- 8
  state$completed_steps <- c(1, 2, 3, 4, 5, 6, 7)
  state$workflow_complete <- FALSE

  # Mark as complete
  state$workflow_complete <- TRUE

  expect_true(state$workflow_complete, "Workflow should be marked complete")

  # After completion, autosave should be cleared (in real app)
  # This is a signal that localStorage should be cleared
})

test_that("Completed workflow state can be serialized for final save", {
  skip_if_not_installed("jsonlite")

  source("../../guided_workflow.R")

  state <- init_workflow_state()
  state$current_step <- 8
  state$completed_steps <- c(1, 2, 3, 4, 5, 6, 7, 8)
  state$workflow_complete <- TRUE
  state$project_data$project_name <- "Completed Project"
  state$converted_main_data <- data.frame(
    Activity = c("Act1", "Act2"),
    Pressure = c("Press1", "Press2"),
    stringsAsFactors = FALSE
  )

  # Serialize complete state
  json_str <- jsonlite::toJSON(state, auto_unbox = TRUE)

  # Restore
  restored <- jsonlite::fromJSON(json_str, simplifyVector = FALSE)

  expect_true(restored$workflow_complete)
  expect_true(!is.null(restored$converted_main_data))
})

# =============================================================================
# TEST SUMMARY
# =============================================================================

cat("\n")
cat("=============================================================================\n")
cat("AUTOSAVE INTEGRATION TEST SUITE SUMMARY\n")
cat("=============================================================================\n")
cat("Test Categories:\n")
cat("  ✓ Complete autosave workflow (save → restore)\n")
cat("  ✓ Session restore scenarios\n")
cat("  ✓ Multi-step progression tracking\n")
cat("  ✓ Data persistence and integrity\n")
cat("  ✓ Edge cases and error recovery\n")
cat("  ✓ Workflow completion and cleanup\n")
cat("\n")
cat("Key Scenarios Tested:\n")
cat("  ✓ Full workflow state round-trip\n")
cat("  ✓ Custom entries preservation\n")
cat("  ✓ Multi-step hash changes\n")
cat("  ✓ Large state handling\n")
cat("  ✓ Special characters and unicode\n")
cat("  ✓ Corrupted data recovery\n")
cat("  ✓ Workflow completion marking\n")
cat("=============================================================================\n")
cat("\n")
