# test-consistency-fixes.R
# Tests for consistency fixes implemented in version 5.2
# Tests circular dependency fixes, icon standardization, and documentation accuracy

library(testthat)
library(stringr)

context("Consistency Fixes Validation")

test_that("Circular dependency is resolved", {
  # Test that guided_workflow.r loads without circular dependencies
  workflow_content <- readLines("guided_workflow.r")

  # Should not contain any problematic circular source calls
  circular_source_pattern <- 'source\\("guided_workflow\\.r"\\)'
  has_circular_import <- any(grepl(circular_source_pattern, workflow_content))

  expect_false(has_circular_import,
               "guided_workflow.r should not source itself")

  # Should have proper dependency validation
  dependency_pattern <- "validate_guided_workflow_dependencies"
  has_dependency_check <- any(grepl(dependency_pattern, workflow_content))

  expect_true(has_dependency_check,
              "guided_workflow.r should have dependency validation")
})

test_that("Icon usage is standardized across files", {
  # Check guided_workflow.r for consistent icon() usage
  workflow_content <- readLines("guided_workflow.r")

  # Should not contain any tags$i() patterns for FontAwesome
  tags_i_pattern <- 'tags\\$i\\(class = "fas'
  has_tags_i <- any(grepl(tags_i_pattern, workflow_content))

  expect_false(has_tags_i,
               "guided_workflow.r should use icon() function instead of tags$i()")

  # Should contain standardized icon() calls
  icon_pattern <- 'icon\\("check-circle"'
  has_standard_icons <- any(grepl(icon_pattern, workflow_content))

  expect_true(has_standard_icons,
              "guided_workflow.r should use standardized icon() function calls")
})

test_that("CLAUDE.md documentation matches actual file structure", {
  claude_content <- readLines("CLAUDE.md")
  claude_text <- paste(claude_content, collapse = "\n")

  # Should describe app.r as launcher, not complete UI/server
  launcher_pattern <- "Application Launcher"
  has_launcher_desc <- grepl(launcher_pattern, claude_text)

  expect_true(has_launcher_desc,
              "CLAUDE.md should describe app.r as Application Launcher")

  # Should mention separate ui.R and server.R files
  separate_files_pattern <- "ui\\.R.*server\\.R"
  has_separate_files <- grepl(separate_files_pattern, claude_text, ignore.case = TRUE)

  expect_true(has_separate_files,
              "CLAUDE.md should mention separate ui.R and server.R files")

  # Should not claim app.r contains complete UI/server logic
  old_pattern <- "Contains the complete Shiny UI and server logic"
  has_old_desc <- grepl(old_pattern, claude_text)

  expect_false(has_old_desc,
               "CLAUDE.md should not claim app.r contains complete UI/server logic")
})

test_that("Global.R has enhanced import logic", {
  global_content <- readLines("global.R")
  global_text <- paste(global_content, collapse = "\n")

  # Should have tryCatch block for guided workflow loading
  trycatch_pattern <- "tryCatch\\(\\{"
  has_trycatch <- grepl(trycatch_pattern, global_text)

  expect_true(has_trycatch,
              "global.R should have tryCatch block for robust module loading")

  # Should have success/failure logging
  success_pattern <- "Guided workflow core loaded"
  has_success_logging <- grepl(success_pattern, global_text)

  expect_true(has_success_logging,
              "global.R should have success logging for workflow loading")

  # Should have error handling
  error_pattern <- "Failed to load guided workflow system"
  has_error_handling <- grepl(error_pattern, global_text)

  expect_true(has_error_handling,
              "global.R should have error handling for workflow loading")
})

test_that("Application starts without circular dependency warnings", {
  # This test would require actually running the app, so we'll check the structure instead

  # Verify that global.R loads guided_workflow.r properly
  global_content <- readLines("global.R")

  workflow_line <- which(grepl('source\\("guided_workflow\\.r"\\)', global_content))

  expect_true(length(workflow_line) > 0, "global.R should source guided_workflow.r")

  # Verify guided_workflow.r has proper error handling
  if (length(workflow_line) > 0) {
    # Check that loading is wrapped in tryCatch
    context_start <- max(1, workflow_line[1] - 5)
    context_end <- min(length(global_content), workflow_line[1] + 5)
    context <- global_content[context_start:context_end]

    has_error_handling <- any(grepl("tryCatch|error", context, ignore.case = TRUE))
    expect_true(has_error_handling,
                "global.R should have error handling for guided_workflow.r loading")
  }
})

test_that("FontAwesome integration is consistent", {
  # Check that CLAUDE.md reflects the actual standardization
  claude_content <- readLines("CLAUDE.md")
  claude_text <- paste(claude_content, collapse = "\n")

  # Should mention standardization, not direct element usage
  standardized_pattern <- "Standardized icon usage"
  has_standardized_desc <- grepl(standardized_pattern, claude_text)

  expect_true(has_standardized_desc,
              "CLAUDE.md should mention standardized icon usage")

  # Should mention icon() function consistency
  icon_function_pattern <- "icon\\(\\) function"
  has_icon_function_desc <- grepl(icon_function_pattern, claude_text)

  expect_true(has_icon_function_desc,
              "CLAUDE.md should mention consistent icon() function usage")
})

# Performance regression test
test_that("Consistency fixes don't impact performance", {
  skip_if_not_installed("microbenchmark")
  library(microbenchmark)

  # Test that loading times are reasonable
  loading_time <- system.time({
    source("global.R")
  })

  expect_true(loading_time[["elapsed"]] < 10,
              "Application loading should complete within 10 seconds")
})

# Integration test
test_that("All modules load successfully after fixes", {
  # Test that we can source all main files without errors
  expect_silent(source("global.R"))

  # Test that key objects are available
  expect_true(exists("vocabulary_data"), "vocabulary_data should be loaded")
  expect_true(exists("WORKFLOW_CONFIG"), "WORKFLOW_CONFIG should be loaded")

  # Test that guided workflow functions are available
  expect_true(exists("guided_workflow_ui"), "guided_workflow_ui function should be available")
  expect_true(exists("guided_workflow_server"), "guided_workflow_server function should be available")
})