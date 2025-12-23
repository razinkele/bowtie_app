# Test runner for Environmental Bowtie Risk Analysis Application
# This file runs all tests in the tests/testthat directory (non-package mode)

library(testthat)

# Ensure app code is sourced from the project root (tests are executed from tests/)
source(file.path("..", "utils.R"))
source(file.path("..", "vocabulary.R"))
source(file.path("..", "bowtie_bayesian_network.R"))

# Run all tests in this directory
test_dir(".", reporter = "summary")