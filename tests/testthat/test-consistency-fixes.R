# test-consistency-fixes.R
# Tests for consistency fixes implemented in version 5.2
# Tests circular dependency fixes, icon standardization, and documentation accuracy

library(testthat)
library(stringr)

context("Consistency Fixes Validation")

# Using centralized repo-aware file reader from helper (see helper-repo-files.R)
# Helper functions `find_repo_root()`, `read_repo_file()` and
# `read_repo_file_if_exists()` are provided by
# `tests/testthat/helper-repo-files.R` and are loaded automatically by testthat.



test_that("Circular dependency is resolved", {
  # Prefer repo-aware lookup for the guided workflow file (case-insensitive)
  found_content <- read_repo_file_if_exists("guided_workflow.R")
  if (length(found_content) == 0) found_content <- read_repo_file_if_exists("guided_workflow.r")
  found <- NULL
  if (length(found_content) == 0) {
    repo_root <- find_repo_root()
    if (!is.null(repo_root)) {
      files <- list.files(repo_root, recursive = TRUE, full.names = TRUE)
      matches <- files[grepl("guided_workflow", basename(files), ignore.case = TRUE)]
      if (length(matches) > 0) {
        found_content <- tryCatch(readLines(matches[1], warn = FALSE), error = function(e) character(0))
        found <- matches[1]
      }
    }
  } else {
    found <- "<repo>"
  }

  expect_false(is.null(found), "guided_workflow file should have dependency validation")

  workflow_content <- found_content

  # Should not contain any problematic circular source calls (case-insensitive)
  circular_source_pattern <- "source\\((\"|')guided_workflow\\.r(\"|')\\)"
  has_circular_import <- any(grepl(circular_source_pattern, workflow_content, ignore.case = TRUE))

  expect_false(has_circular_import,
               "guided_workflow should not source itself")
})

test_that("Icon usage is standardized across files", {
  # Check known host files for icon usage rather than scanning everything
  files_to_check <- c("guided_workflow.R", "ui.R", "server.R", "utils/advanced_benchmarks.R")
  has_tags_i <- FALSE
  has_standard_icons <- FALSE

  for (fname in files_to_check) {
    content <- tryCatch(read_repo_file(fname), error = function(e) character(0))
    if (length(content) == 0) next
    if (any(grepl('tags\\$i\\(class = "fas', content))) has_tags_i <- TRUE
    if (any(grepl('icon\\("check-circle"', content))) has_standard_icons <- TRUE
  }

  expect_false(has_tags_i,
               "Repository should use icon() function instead of tags$i() in key files")

  expect_true(has_standard_icons,
              "Repository should contain standardized icon() function calls (check-circle) in key files")
})

test_that("CLAUDE.md documentation matches actual file structure", {
  claude_content <- read_repo_file("CLAUDE.md")
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
  # Use repo-aware lookup to locate global.R
  global_path <- find_repo_file_path('global.R')
  skip_if(is.null(global_path), "global.R not available in test environment")

  global_content <- tryCatch(readLines(global_path, warn = FALSE), error = function(e) character(0))
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

  # Verify that global.R loads guided_workflow properly (repo-aware)
  global_path <- find_repo_file_path('global.R')
  skip_if(is.null(global_path), "global.R not found")

  global_content <- tryCatch(readLines(global_path, warn = FALSE), error = function(e) character(0))

  workflow_line <- which(grepl("source\\((\"|')guided_workflow\\.r(\"|')\\)", global_content, ignore.case = TRUE))

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
  skip_if(is.null(find_repo_file_path('CLAUDE.md')), "CLAUDE.md not available in test environment")
  # Check that CLAUDE.md reflects the actual standardization
  claude_content <- read_repo_file("CLAUDE.md")
  claude_text <- paste(claude_content, collapse = "\n")

  # Should mention standardization, not direct element usage
  standardized_pattern <- "Standardized icon usage"
  has_standardized_desc <- grepl(standardized_pattern, claude_text)

  expect_true(has_standardized_desc,
              "CLAUDE.md should mention standardized icon usage")

  # Should mention icon() function consistency (allow punctuation/whitespace between)
  icon_function_pattern <- "icon\\(\\)\[[:space:][:punct:]]*function"
  has_icon_function_desc <- grepl(icon_function_pattern, claude_text, ignore.case = TRUE)

  expect_true(has_icon_function_desc,
              "CLAUDE.md should mention consistent icon() function usage")
})

# Performance regression test
test_that("Consistency fixes don't impact performance", {
  skip_if_not_installed("microbenchmark")
  library(microbenchmark)

  # Test that loading times are reasonable
  global_path <- find_repo_file_path('global.R')
  skip_if(is.null(global_path), "global.R not found for performance test")

  loading_time <- system.time({
    source(global_path, chdir = TRUE)
  })

  expect_true(loading_time[["elapsed"]] < 10,
              "Application loading should complete within 10 seconds")
})

# Integration test
test_that("All modules load successfully after fixes", {
  # Source the repo root global.R explicitly to avoid path ambiguity
  global_path <- find_repo_file_path('global.R')
  skip_if(is.null(global_path), "global.R not found in known locations")

  expect_error(source(global_path, chdir = TRUE), NA)

  # Test that key objects are available
  expect_true(exists("vocabulary_data"), "vocabulary_data should be loaded")
  expect_true(exists("WORKFLOW_CONFIG"), "WORKFLOW_CONFIG should be loaded")

  # Test that guided workflow functions are available
  expect_true(exists("guided_workflow_ui"), "guided_workflow_ui function should be available")
  expect_true(exists("guided_workflow_server"), "guided_workflow_server function should be available")
})