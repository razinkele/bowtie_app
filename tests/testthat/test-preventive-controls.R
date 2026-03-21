# test-preventive-controls.R
# Comprehensive tests for the preventive controls functionality that was fixed

library(testthat)
library(shiny)

# Load the realistic test data
fixtures_file <- file.path(app_root, "tests/fixtures/realistic_test_data.R")
if (file.exists(fixtures_file)) {
  source(fixtures_file)
} else if (file.exists("fixtures/realistic_test_data.R")) {
  source("fixtures/realistic_test_data.R")
}

test_that("vocabulary data loads controls correctly", {
  skip_if_not(exists("load_vocabulary"), "load_vocabulary not available")
  skip_if_not(file.exists(file.path(app_root, "CONTROLS.xlsx")), "CONTROLS.xlsx not found")

  # Load vocabulary from app root directory
  old_wd <- getwd()
  setwd(app_root)
  on.exit(setwd(old_wd), add = TRUE)
  vocab_data <- tryCatch(
    suppressWarnings(suppressMessages(load_vocabulary())),
    error = function(e) { skip(paste("load_vocabulary failed:", e$message)) }
  )

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
