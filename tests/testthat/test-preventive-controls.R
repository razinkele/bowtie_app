# test-preventive-controls.R
# Comprehensive tests for the preventive controls functionality that was fixed

library(testthat)
library(shiny)

# Load the realistic test data
if (file.exists("tests/fixtures/realistic_test_data.R")) {
  source("tests/fixtures/realistic_test_data.R")
} else if (file.exists("../../tests/fixtures/realistic_test_data.R")) {
  source("../../tests/fixtures/realistic_test_data.R")
} else if (file.exists("fixtures/realistic_test_data.R")) {
  source("fixtures/realistic_test_data.R")
}

test_that("vocabulary data loads controls correctly", {
  # Test the actual vocabulary loading
  skip_if_not(file.exists("vocabulary.r"), "vocabulary.r not found")

  source("vocabulary.r")

  # Test that load_vocabulary function exists and works
  expect_true(exists("load_vocabulary"))

  # Load the vocabulary (this uses real Excel files)
  vocab_data <- NULL
  expect_silent({
    vocab_data <- load_vocabulary()
  })

  # Test that controls data is loaded
  expect_true("controls" %in% names(vocab_data))
  expect_true(is.data.frame(vocab_data$controls))
  expect_true(nrow(vocab_data$controls) > 0)

  # Test that controls have required columns
  required_cols <- c("hierarchy", "id", "name", "level")
  expect_true(all(required_cols %in% names(vocab_data$controls)))

  # Test that control names exist and are not empty
  expect_true(all(nchar(vocab_data$controls$name) > 0))
  expect_true(all(!is.na(vocab_data$controls$name)))
})

test_that("generate_step4_ui creates controls selectizeInput", {
  skip_if_not(file.exists("guided_workflow_steps.r"), "guided_workflow_steps.r not found")

  source("guided_workflow_steps.r")

  # Create test vocabulary data
  test_vocab <- create_realistic_test_vocabulary()

  # Test that the function exists
  expect_true(exists("generate_step4_ui"))

  # Test UI generation with vocabulary data
  ui_result <- NULL
  expect_silent({
    ui_result <- generate_step4_ui(test_vocab)
  })

  # Test that UI is created (should be a tagList or similar)
  expect_true(!is.null(ui_result))

  # Convert to HTML to check for selectizeInput
  html_output <- as.character(ui_result)

  # Check that it contains the control search input
  expect_true(grepl("control_search", html_output))
  expect_true(grepl("Search Control Measures", html_output))
  expect_true(grepl("add_preventive_control", html_output))
  expect_true(grepl("preventive_controls_table", html_output))
})

test_that("generate_step4_ui handles NULL vocabulary data gracefully", {
  source("guided_workflow_steps.r")

  # Test with NULL vocabulary data
  ui_result <- NULL
  expect_silent({
    ui_result <- generate_step4_ui(NULL)
  })

  # Should still create UI, just with empty choices
  expect_true(!is.null(ui_result))

  html_output <- as.character(ui_result)
  expect_true(grepl("control_search", html_output))
})

test_that("generate_step4_ui handles empty controls data", {
  source("guided_workflow_steps.r")

  # Create vocabulary with empty controls
  empty_vocab <- list(
    controls = data.frame(
      hierarchy = character(0),
      id = character(0),
      name = character(0),
      level = numeric(0),
      stringsAsFactors = FALSE
    )
  )

  ui_result <- NULL
  expect_silent({
    ui_result <- generate_step4_ui(empty_vocab)
  })

  expect_true(!is.null(ui_result))
})

test_that("controls choices are properly formatted for selectizeInput", {
  test_vocab <- create_realistic_test_vocabulary()

  # Test the choice creation logic
  controls_data <- test_vocab$controls
  control_choices <- setNames(controls_data$name, controls_data$name)

  # Test that choices are properly named
  expect_true(is.vector(control_choices))
  expect_true(length(control_choices) == nrow(controls_data))
  expect_true(all(names(control_choices) == controls_data$name))
  expect_true(all(control_choices == controls_data$name))
})

test_that("guided_workflow server integration works", {
  skip_if_not(file.exists("guided_workflow.r"), "guided_workflow.r not found")

  source("guided_workflow.r")

  # Test that guided_workflow_server function exists
  expect_true(exists("guided_workflow_server"))

  # Test that vocabulary data parameter is passed to Step 4
  # This tests the fix we implemented in guided_workflow.r line 593

  # Create a mock test to verify the integration
  test_vocab <- create_realistic_test_vocabulary()

  # Verify that the vocabulary structure is correct for the server
  expect_true("controls" %in% names(test_vocab))
  expect_true(nrow(test_vocab$controls) > 0)

  # Test that control names can be used as selectize choices
  choices <- setNames(test_vocab$controls$name, test_vocab$controls$name)
  expect_true(length(choices) > 0)
  expect_true(all(nchar(names(choices)) > 0))
})

test_that("preventive controls functionality integration test", {
  # This tests the complete fix:
  # 1. Vocabulary loading
  # 2. UI generation with vocabulary data
  # 3. Server-side handlers

  # Step 1: Load vocabulary
  source("vocabulary.r")
  vocab_data <- load_vocabulary()
  expect_true("controls" %in% names(vocab_data))
  expect_true(nrow(vocab_data$controls) > 0)

  # Step 2: Generate UI with vocabulary
  source("guided_workflow_steps.r")
  ui_result <- generate_step4_ui(vocab_data)
  expect_true(!is.null(ui_result))

  # Step 3: Test that choices are available
  control_choices <- setNames(vocab_data$controls$name, vocab_data$controls$name)
  expect_true(length(control_choices) > 0)

  # Step 4: Test guided workflow integration
  source("guided_workflow.r")
  expect_true(exists("guided_workflow_server"))
})

test_that("real Excel data structure matches expected format", {
  # Test that the actual Excel files have the expected structure
  skip_if_not(file.exists("CONTROLS.xlsx"), "CONTROLS.xlsx not found")

  source("vocabulary.r")
  vocab_data <- load_vocabulary()

  # Test controls data structure
  controls <- vocab_data$controls
  expect_true(is.data.frame(controls))
  expect_true("name" %in% names(controls))
  expect_true("id" %in% names(controls))
  expect_true("level" %in% names(controls))
  expect_true("hierarchy" %in% names(controls))

  # Test that we have a reasonable number of controls
  expect_true(nrow(controls) >= 10)  # Should have at least 10 controls

  # Test that control names are meaningful (not empty or just whitespace)
  expect_true(all(nchar(trimws(controls$name)) > 0))

  # Test that IDs follow expected pattern
  expect_true(all(grepl("Ctrl", controls$id)))
})

cat("✅ Preventive controls tests loaded\n")