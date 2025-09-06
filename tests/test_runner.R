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
if (!file.exists("app.r")) {
  stop("ERROR: app.r not found. Please run this script from the app root directory.")
}

cat("Working directory:", getwd(), "\n")
cat("Loading application modules...\n")

# Source the application files with error handling
tryCatch({
  source("utils.r")
  cat("✓ Loaded utils.r\n")
}, error = function(e) {
  cat("✗ Failed to load utils.r:", e$message, "\n")
  stop("Cannot proceed without utils.r")
})

tryCatch({
  source("vocabulary.r")
  cat("✓ Loaded vocabulary.r\n")
}, error = function(e) {
  cat("✗ Failed to load vocabulary.r:", e$message, "\n")
  stop("Cannot proceed without vocabulary.r")
})

tryCatch({
  source("bowtie_bayesian_network.r")
  cat("✓ Loaded bowtie_bayesian_network.r\n")
}, error = function(e) {
  cat("✗ Failed to load bowtie_bayesian_network.r:", e$message, "\n")
  stop("Cannot proceed without bowtie_bayesian_network.r")
})

# Load test fixtures
if (file.exists("tests/fixtures/test_data.R")) {
  source("tests/fixtures/test_data.R")
  cat("✓ Loaded test fixtures\n")
} else {
  cat("⚠ Test fixtures not found, continuing with basic tests\n")
}

# Load vocabulary bowtie generator if available
if (file.exists("vocabulary_bowtie_generator.r")) {
  tryCatch({
    source("vocabulary_bowtie_generator.r")
    cat("✓ Loaded vocabulary_bowtie_generator.r\n")
  }, error = function(e) {
    cat("⚠ Warning loading vocabulary_bowtie_generator.r:", e$message, "\n")
  })
} else {
  cat("⚠ vocabulary_bowtie_generator.r not found, skipping related tests\n")
}

cat("\n========================================\n")
cat("Running Test Suites\n")
cat("========================================\n\n")

# Function to run a specific test file and capture results
run_test_file <- function(test_file) {
  cat("Running", test_file, "...\n")
  
  tryCatch({
    results <- test_file(test_file, reporter = "minimal")
    
    # Extract test summary
    if (length(results) > 0) {
      passed <- sum(sapply(results, function(x) x$nb))
      failed <- sum(sapply(results, function(x) length(x$failed)))
      
      if (failed == 0) {
        cat("✓", test_file, "- All", passed, "tests passed\n")
        return(list(passed = passed, failed = 0, file = test_file))
      } else {
        cat("✗", test_file, "-", failed, "failed,", passed - failed, "passed\n")
        return(list(passed = passed - failed, failed = failed, file = test_file))
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