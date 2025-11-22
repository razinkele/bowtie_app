#!/usr/bin/env Rscript
# =============================================================================
# Quick Test Runner for Guided Workflow
# Usage: Rscript tests/run_guided_workflow_tests.R
# =============================================================================

cat("\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("🧪 GUIDED WORKFLOW TEST RUNNER\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("\n")

# Set working directory to project root
if (basename(getwd()) == "tests") {
  setwd("..")
}

# Load required packages
cat("📦 Loading packages...\n")
required_packages <- c("testthat", "shiny", "DT", "dplyr")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("   ⚠️  Package", pkg, "not found. Installing...\n")
    install.packages(pkg, quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

cat("   ✓ All packages loaded\n\n")

# Source guided workflow
cat("📋 Loading guided workflow system...\n")
tryCatch({
  source("guided_workflow.R")
  cat("   ✓ Guided workflow loaded successfully\n\n")
}, error = function(e) {
  cat("   ❌ Error loading guided workflow:", e$message, "\n")
  quit(status = 1)
})

# Run tests
cat("🧪 Running test suite...\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("\n")

test_results <- test_file("tests/testthat/test-guided-workflow.R", reporter = "progress")

cat("\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("📊 TEST SUMMARY\n")
cat("=" , rep("=", 78), "\n", sep = "")

# Summary
if (is.null(test_results)) {
  cat("❌ Tests failed to run\n")
} else {
  cat("✅ Tests completed\n")
}

cat("\n")
cat("💡 To run interactive tests:\n")
cat("   Rscript tests/test_guided_workflow_interactive.R\n")
cat("\n")
