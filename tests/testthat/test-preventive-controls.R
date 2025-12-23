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

  source("vocabulary.R")

  # Test that load_vocabulary function exists and works
  expect_true(exists("load_vocabulary"))

  # Load the vocabulary (this uses real Excel files)
  vocab_data <- NULL
  expect_silent(invisible(capture.output(suppressWarnings(suppressMessages({
    vocab_data <- load_vocabulary()
  })))) )

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

# (rest unchanged)
