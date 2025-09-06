# Test runner for Environmental Bowtie Risk Analysis Application
# This file runs all tests in the tests/testthat directory

library(testthat)

# Set the working directory to the app root
if (!file.exists("app.r")) {
  stop("Tests must be run from the app root directory containing app.r")
}

# Load the app's dependencies and source files
source("utils.r")
source("vocabulary.r") 
source("bowtie_bayesian_network.r")

# Run all tests
test_check("bowtie_app", reporter = "summary")