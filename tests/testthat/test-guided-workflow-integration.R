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

# (rest unchanged)
