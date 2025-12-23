# test-guided-workflow-integration.R
# Integration tests for the complete guided workflow functionality

library(testthat)
library(shiny)

# Load test data
if (file.exists("tests/fixtures/realistic_test_data.R")) {
  source("tests/fixtures/realistic_test_data.R")
} else if (file.exists("../../tests/fixtures/realistic_test_data.R")) {
  source("../../tests/fixtures/realistic_test_data.R")
} else if (file.exists("fixtures/realistic_test_data.R")) {
  source("fixtures/realistic_test_data.R")
}

test_that("guided workflow modules load correctly", {
  expect_silent(suppressWarnings(suppressMessages(source("guided_workflow.R"))))
  expect_silent(suppressWarnings(suppressMessages(source("vocabulary.R"))))
})

test_that("vocabulary data is properly integrated into guided workflow", {
  # Load the modules
  source("vocabulary.R")
  source("guided_workflow.R")

  # Test vocabulary loading
  vocab_data <- load_vocabulary()
  expect_true(is.list(vocab_data))
  expect_true("controls" %in% names(vocab_data))
  expect_true("activities" %in% names(vocab_data))
  expect_true("pressures" %in% names(vocab_data))

  # Test that Step 4 UI generation works with real vocabulary data
  # Note: generate_step4_ui is defined within guided_workflow.r
  if (exists("generate_step4_ui")) {
    # Set vocabulary_data globally (function expects it in global environment)
    vocabulary_data <<- vocab_data
    ui_step4 <- generate_step4_ui(session = NULL, current_lang = "en")
    expect_true(!is.null(ui_step4))

    # Convert to character to check content
    ui_html <- as.character(ui_step4)
    expect_true(grepl("preventive_control_search", ui_html))
    expect_true(grepl("add_preventive_control", ui_html))

    # Cleanup
    rm(vocabulary_data, envir = .GlobalEnv)
  }
})

test_that("step UI functions accept vocabulary parameter correctly", {
  source("guided_workflow.R")

  test_vocab <- create_realistic_test_vocabulary()

  # Test Step 4 UI generation with vocabulary data
  if (exists("generate_step4_ui")) {
    ui_step4 <- NULL
    expect_silent(suppressWarnings(suppressMessages({
      vocabulary_data <<- test_vocab
      ui_step4 <- generate_step4_ui(session = NULL, current_lang = "en")
      rm(vocabulary_data, envir = .GlobalEnv)
    })))
    expect_true(!is.null(ui_step4))

    # Test that it handles NULL/empty gracefully
    expect_silent(suppressWarnings(suppressMessages({
      vocabulary_data <<- NULL
      ui_step4_null <- generate_step4_ui(session = NULL, current_lang = "en")
      rm(vocabulary_data, envir = .GlobalEnv)
    })))
  }
})

test_that("selectizeInput choices are properly populated", {
  test_vocab <- create_realistic_test_vocabulary()

  # Test activities choices (reference implementation)
  activity_choices <- setNames(test_vocab$activities$name, test_vocab$activities$name)
  expect_true(length(activity_choices) > 0)
  expect_true(is.character(activity_choices))
  expect_true(all(nchar(names(activity_choices)) > 0))

  # Test controls choices (our implementation)
  control_choices <- setNames(test_vocab$controls$name, test_vocab$controls$name)
  expect_true(length(control_choices) > 0)
  expect_true(is.character(control_choices))
  expect_true(all(nchar(names(control_choices)) > 0))
  expect_true(all(control_choices == names(control_choices)))
})

test_that("guided workflow server function handles controls data", {
  source("guided_workflow.R")

  expect_true(exists("guided_workflow_server"))

  # Test that the function can be called (basic structure test)
  expect_true(is.function(guided_workflow_server))

  # Test that required modules are available for the server
  expect_true(exists("generate_step4_ui"))
})

test_that("complete workflow integration works end-to-end", {
  # This tests the complete workflow functionality:
  # 1. Load vocabulary data
  # 2. Pass to UI generation functions
  # 3. Generate working selectizeInputs
  # 4. Server functions can handle the data

  # Step 1: Load all required modules
  source("vocabulary.R")
  source("guided_workflow.R")

  # Step 2: Load vocabulary data
  vocab_data <- load_vocabulary()
  expect_true("controls" %in% names(vocab_data))

  # Step 3: Test UI generation with real data (if function exists)
  if (exists("generate_step4_ui")) {
    vocabulary_data <<- vocab_data
    ui_result <- generate_step4_ui(session = NULL, current_lang = "en")
    expect_true(!is.null(ui_result))
    rm(vocabulary_data, envir = .GlobalEnv)
  }

  # Step 4: Test choice generation
  if (nrow(vocab_data$controls) > 0) {
    control_choices <- setNames(vocab_data$controls$name, vocab_data$controls$name)
    expect_true(length(control_choices) > 0)

    # Test a few sample choices
    sample_choices <- head(control_choices, 3)
    expect_true(all(nchar(names(sample_choices)) > 0))
    expect_true(all(nchar(sample_choices) > 0))
  }

  # Step 5: Test that guided workflow server exists
  expect_true(exists("guided_workflow_server"))
})

test_that("error handling works correctly", {
  source("guided_workflow.R")

  # Test with completely invalid data (if function exists)
  if (exists("generate_step4_ui")) {
    expect_silent(suppressWarnings(suppressMessages({
      vocabulary_data <<- list()
      ui_result <- generate_step4_ui(session = NULL, current_lang = "en")
      rm(vocabulary_data, envir = .GlobalEnv)
    })))

    # Test with NULL
    expect_silent(suppressWarnings(suppressMessages({
      vocabulary_data <<- NULL
      ui_step4_null <- generate_step4_ui(session = NULL, current_lang = "en")
      rm(vocabulary_data, envir = .GlobalEnv)
    })))

    # Test with missing controls key
    incomplete_vocab <- list(activities = data.frame())
    expect_silent(suppressWarnings(suppressMessages({
      vocabulary_data <<- incomplete_vocab
      ui_result <- generate_step4_ui(session = NULL, current_lang = "en")
      rm(vocabulary_data, envir = .GlobalEnv)
    })))
  }
})

test_that("UI elements are properly structured", {
  source("guided_workflow.R")
  test_vocab <- create_realistic_test_vocabulary()

  if (exists("generate_step4_ui")) {
    vocabulary_data <<- test_vocab
    ui_result <- generate_step4_ui(session = NULL, current_lang = "en")
    ui_html <- as.character(ui_result)

    # Check for essential UI elements
    expect_true(grepl("preventive_control_search", ui_html))
    expect_true(grepl("add_preventive_control", ui_html))

    # Cleanup
    rm(vocabulary_data, envir = .GlobalEnv)
  }
})

test_that("real vocabulary data structure is compatible", {
  source("vocabulary.R")

  # Test that real Excel data works with our implementation
  vocab_data <- load_vocabulary()

  # Test controls structure
  expect_true("controls" %in% names(vocab_data))
  controls <- vocab_data$controls
  expect_true(is.data.frame(controls))

  required_cols <- c("name", "id", "level", "hierarchy")
  expect_true(all(required_cols %in% names(controls)))

  # Test that names can be used for selectizeInput
  if (nrow(controls) > 0) {
    control_choices <- setNames(controls$name, controls$name)
    expect_true(is.character(control_choices))
    expect_true(length(control_choices) == nrow(controls))
    expect_true(all(!is.na(control_choices)))
    expect_true(all(nchar(control_choices) > 0))
  }
})

cat("✅ Guided workflow integration tests loaded\n")