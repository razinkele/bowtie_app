#!/usr/bin/env Rscript
# =============================================================================
# Test Runner: Menu Activation and Notification Fixes
# Description: Runs comprehensive tests to verify all fixes are working
# Version: 1.0
# Date: January 2026
# =============================================================================

cat("\n")
cat("========================================================================\n")
cat("  MENU ACTIVATION & NOTIFICATION FIXES - TEST RUNNER\n")
cat("  Version: 1.0\n")
cat("  Date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("========================================================================\n")
cat("\n")

# Set working directory to app root
if (basename(getwd()) == "tests") {
  setwd("..")
}

# Load required packages
cat("📦 Loading testing packages...\n")
if (!require("testthat", quietly = TRUE)) {
  cat("   Installing testthat package...\n")
  install.packages("testthat", repos = "https://cloud.r-project.org")
  library(testthat)
}
cat("✅ Testing packages loaded\n\n")

# Create test results directory
results_dir <- "tests/results"
if (!dir.exists(results_dir)) {
  dir.create(results_dir, recursive = TRUE)
}

# Set up test reporter
timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
report_file <- file.path(results_dir, paste0("menu_activation_test_", timestamp, ".txt"))

cat("🧪 Running Menu Activation & Notification Tests...\n")
cat("📝 Test report will be saved to:", report_file, "\n\n")

# Capture output
sink(report_file, split = TRUE)

cat("========================================================================\n")
cat("  TEST EXECUTION STARTED\n")
cat("========================================================================\n")
cat("Working Directory:", getwd(), "\n")
cat("R Version:", R.version.string, "\n")
cat("Test File: tests/testthat/test-menu-activation-fixes.R\n")
cat("Timestamp:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("========================================================================\n\n")

# Run the tests
test_results <- NULL
tryCatch({
  test_results <- test_file(
    "tests/testthat/test-menu-activation-fixes.R",
    reporter = "summary"
  )
}, error = function(e) {
  cat("\n❌ ERROR RUNNING TESTS:\n")
  cat(e$message, "\n")
})

cat("\n")
cat("========================================================================\n")
cat("  TEST EXECUTION COMPLETED\n")
cat("========================================================================\n")

# Stop capturing output
sink()

# Display results summary
cat("\n")
cat("========================================================================\n")
cat("  TEST RESULTS SUMMARY\n")
cat("========================================================================\n")

if (!is.null(test_results)) {
  # Count test outcomes
  passed <- sum(sapply(test_results, function(x) {
    if (inherits(x, "expectation_success")) 1 else 0
  }))

  failed <- sum(sapply(test_results, function(x) {
    if (inherits(x, "expectation_failure")) 1 else 0
  }))

  warnings <- sum(sapply(test_results, function(x) {
    if (inherits(x, "expectation_warning")) 1 else 0
  }))

  skipped <- sum(sapply(test_results, function(x) {
    if (inherits(x, "expectation_skip")) 1 else 0
  }))

  total <- passed + failed + warnings + skipped

  cat("\n")
  cat("Total Tests Run:     ", total, "\n")
  cat("✅ Passed:           ", passed, "\n")
  cat("❌ Failed:           ", failed, "\n")
  cat("⚠️  Warnings:         ", warnings, "\n")
  cat("⏭️  Skipped:          ", skipped, "\n")
  cat("\n")

  # Overall status
  if (failed == 0 && warnings == 0) {
    cat("🎉 ALL TESTS PASSED! 🎉\n")
    cat("\n")
    cat("Menu activation and notification fixes are working correctly!\n")
    exit_code <- 0
  } else {
    cat("⚠️  SOME TESTS FAILED OR HAVE WARNINGS\n")
    cat("\n")
    cat("Please review the detailed report at:\n")
    cat(report_file, "\n")
    exit_code <- 1
  }

} else {
  cat("\n❌ Test execution encountered errors\n")
  cat("Please check the report file for details:\n")
  cat(report_file, "\n")
  exit_code <- 2
}

cat("\n")
cat("========================================================================\n")
cat("  REPORT LOCATION\n")
cat("========================================================================\n")
cat("\n")
cat("📄 Full test report saved to:\n")
cat("   ", report_file, "\n")
cat("\n")

# Additional verification checks
cat("========================================================================\n")
cat("  ADDITIONAL VERIFICATION\n")
cat("========================================================================\n")
cat("\n")

# Check if app is running
cat("Checking application status...\n")
app_running <- system("tasklist | findstr -i Rscript.exe", intern = FALSE, ignore.stderr = TRUE)
if (app_running == 0) {
  cat("✅ Application appears to be running\n")
} else {
  cat("⚠️  Application may not be running\n")
}

# Check key files exist
cat("\nVerifying key files...\n")
key_files <- c(
  "server.R",
  "ui.R",
  "global.R",
  "utils.R",
  "environmental_scenarios.R",
  "guided_workflow.R"
)

for (file in key_files) {
  if (file.exists(file)) {
    cat("  ✓", file, "\n")
  } else {
    cat("  ✗", file, "NOT FOUND\n")
  }
}

cat("\n")
cat("========================================================================\n")
cat("  NEXT STEPS\n")
cat("========================================================================\n")
cat("\n")
cat("1. Review the test report above\n")
cat("2. If all tests passed, verify manually in the browser:\n")
cat("   - Open http://127.0.0.1:4848\n")
cat("   - Navigate to Data Upload tab\n")
cat("   - Select an environmental scenario\n")
cat("   - Click 'Generate Data with Multiple Controls'\n")
cat("   - Verify:\n")
cat("     ✓ No notification type errors\n")
cat("     ✓ Menu items become enabled\n")
cat("     ✓ Automatic navigation to Bowtie tab\n")
cat("     ✓ Bowtie diagram is visible\n")
cat("\n")
cat("3. If tests failed, review the detailed report:\n")
cat("   ", report_file, "\n")
cat("\n")
cat("========================================================================\n")

# Return exit code
if (exists("exit_code")) {
  quit(status = exit_code)
}
