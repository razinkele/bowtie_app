# Simple test runner script for the Environmental Bowtie Risk Analysis Application
# Usage: Rscript tests/run_tests.R

# Install testthat if not available
if (!require("testthat", quietly = TRUE)) {
  install.packages("testthat")
  library(testthat)
}

# Change to app directory if running from tests folder
if (basename(getwd()) == "tests") {
  setwd("..")
}

# Source the main files
cat("Loading application modules...\n")
source("utils.r")
source("vocabulary.r")
source("bowtie_bayesian_network.r")

# Run all tests
cat("Running tests...\n")
test_results <- test_dir("tests/testthat", reporter = "summary")

# Return appropriate exit code
if (length(test_results) > 0) {
  failed_tests <- sum(sapply(test_results, function(x) length(x$failed)))
  if (failed_tests > 0) {
    cat("Tests failed!\n")
    quit(status = 1)
  } else {
    cat("All tests passed!\n")
    quit(status = 0)
  }
} else {
  cat("No tests found!\n")
  quit(status = 1)
}