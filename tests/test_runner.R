#!/usr/bin/env Rscript
# Comprehensive test runner for Environmental Bowtie Risk Analysis Application
# This script runs all tests and provides detailed reporting

# Load required libraries
if (!require("testthat", quietly = TRUE)) {
  cat("Installing testthat package...\n")
  install.packages("testthat")
  library(testthat)
}

# Set up environment
cat("========================================\n")
cat("Environmental Bowtie App Test Runner\n")
cat("========================================\n\n")

# Change to app directory if needed
if (basename(getwd()) == "tests") {
  setwd("..")
  cat("Changed working directory to app root\n")
}

# Verify we're in the correct directory
if (!file.exists("app.R")) {
  stop("ERROR: app.R not found. Please run this script from the app root directory.")
}

cat("Working directory:", getwd(), "\n")
cat("Loading application modules...\n")

# Source the application files with error handling
# Load configuration first (required by other modules)
tryCatch({
  source("config.R")
  cat("✓ Loaded config.R\n")
}, error = function(e) {
  cat("✗ Failed to load config.R:", e$message, "\n")
  stop("Cannot proceed without config.R")
})

tryCatch({
  source("constants.R")
  cat("✓ Loaded constants.R\n")
}, error = function(e) {
  cat("✗ Failed to load constants.R:", e$message, "\n")
  stop("Cannot proceed without constants.R")
})

# Load logging system (required by vocabulary.R and other modules)
tryCatch({
  source("config/logging.R")
  cat("✓ Loaded config/logging.R\n")
}, error = function(e) {
  cat("✗ Failed to load config/logging.R:", e$message, "\n")
  # Create stub logging functions if logging.R fails to load
  log_debug <<- function(...) invisible(NULL)
  log_info <<- function(...) invisible(NULL)
  log_success <<- function(...) invisible(NULL)
  log_warning <<- function(...) invisible(NULL)
  log_error <<- function(...) invisible(NULL)
  cat("  Using stub logging functions\n")
})

# Load error handling helpers
tryCatch({
  source("helpers/error_handling.R")
  cat("✓ Loaded helpers/error_handling.R\n")
}, error = function(e) {
  cat("✗ Failed to load helpers/error_handling.R:", e$message, "\n")
})

tryCatch({
  source("utils.R")
  cat("✓ Loaded utils.R\n")
}, error = function(e) {
  cat("✗ Failed to load utils.R:", e$message, "\n")
  stop("Cannot proceed without utils.R")
})

tryCatch({
  source("vocabulary.R")
  cat("✓ Loaded vocabulary.R\n")
}, error = function(e) {
  cat("✗ Failed to load vocabulary.R:", e$message, "\n")
  stop("Cannot proceed without vocabulary.R")
})

tryCatch({
  source("bowtie_bayesian_network.R")
  cat("✓ Loaded bowtie_bayesian_network.R\n")
}, error = function(e) {
  cat("✗ Failed to load bowtie_bayesian_network.R:", e$message, "\n")
  stop("Cannot proceed without bowtie_bayesian_network.R")
})

# Load test fixtures
if (file.exists("tests/fixtures/test_data.R")) {
  source("tests/fixtures/test_data.R")
  cat("✓ Loaded test fixtures\n")
} else {
  cat("⚠ Test fixtures not found, continuing with basic tests\n")
}

# Load vocabulary bowtie generator if available
if (file.exists("vocabulary_bowtie_generator.R")) {
  tryCatch({
    source("vocabulary_bowtie_generator.R")
    cat("✓ Loaded vocabulary_bowtie_generator.R\n")
  }, error = function(e) {
    cat("⚠ Warning loading vocabulary_bowtie_generator.R:", e$message, "\n")
  })
} else {
  cat("⚠ vocabulary_bowtie_generator.R not found, skipping related tests\n")
}

cat("\n========================================\n")
cat("Running Test Suites\n")
cat("========================================\n\n")

# Function to run a specific test file and capture results
run_test_file <- function(test_file) {
  cat("Running", test_file, "...\n")

  tryCatch({
    results <- testthat::test_file(test_file, reporter = testthat::SilentReporter$new())

    # Extract test summary from testthat results (data.frame-like object)
    df <- as.data.frame(results)
    if (nrow(df) > 0) {
      passed <- sum(df$passed, na.rm = TRUE)
      failed <- sum(df$failed, na.rm = TRUE)
      skipped <- sum(df$skipped, na.rm = TRUE)

      if (failed == 0) {
        cat("✓", test_file, "- All", passed, "tests passed")
        if (skipped > 0) cat(" (", skipped, "skipped)")
        cat("\n")
        return(list(passed = passed, failed = 0, file = test_file))
      } else {
        cat("✗", test_file, "-", failed, "failed,", passed, "passed\n")
        return(list(passed = passed, failed = failed, file = test_file))
      }
    } else {
      cat("⚠", test_file, "- No tests found\n")
      return(list(passed = 0, failed = 0, file = test_file))
    }
  }, error = function(e) {
    cat("✗", test_file, "- Error:", e$message, "\n")
    return(list(passed = 0, failed = 1, file = test_file, error = e$message))
  })
}

# Find and run all test files
test_files <- list.files("tests/testthat", pattern = "^test-.*\\.R$", full.names = TRUE)

if (length(test_files) == 0) {
  stop("No test files found in tests/testthat/")
}

cat("Found", length(test_files), "test files:\n")
for (file in test_files) {
  cat(" -", basename(file), "\n")
}
cat("\n")

# Check for vocabulary bowtie generator tests specifically
if (any(grepl("vocabulary-bowtie-generator", test_files))) {
  cat("🔗 Vocabulary bowtie generator tests included\n")
}
cat("\n")

# Run all tests
all_results <- list()
total_passed <- 0
total_failed <- 0

for (test_file in test_files) {
  result <- run_test_file(test_file)
  all_results[[basename(test_file)]] <- result
  total_passed <- total_passed + result$passed
  total_failed <- total_failed + result$failed
}

# Summary report
cat("\n========================================\n")
cat("Test Summary Report\n")
cat("========================================\n")

for (result in all_results) {
  status <- if (result$failed == 0) "PASS" else "FAIL"
  cat(sprintf("%-30s %s (%d passed, %d failed)\n", 
              result$file, status, result$passed, result$failed))
  
  if (!is.null(result$error)) {
    cat("  Error:", result$error, "\n")
  }
}

cat("\n")
cat("Total Tests:", total_passed + total_failed, "\n")
cat("Passed:", total_passed, "\n")
cat("Failed:", total_failed, "\n")

# Overall result
if (total_failed == 0) {
  cat("\n🎉 ALL TESTS PASSED! 🎉\n")
  quit(status = 0)
} else {
  cat("\n❌ SOME TESTS FAILED ❌\n")
  cat("Please review the failed tests above.\n")
  quit(status = 1)
}