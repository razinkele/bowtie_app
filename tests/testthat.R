# Test runner for Environmental Bowtie Risk Analysis Application
# This file runs all tests in the tests/testthat directory

library(testthat)

# Set the working directory to the app root
if (!file.exists("app.R")) {
  stop("Tests must be run from the app root directory containing app.R")
}

# Load logging system first (required by other modules)
source("config/logging.R")

# Load the app's dependencies and source files
source("utils.R")
source("vocabulary.R")
source("bowtie_bayesian_network.R")

# Run all tests
test_check("bowtie_app", reporter = "summary")