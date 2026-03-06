# =============================================================================
# Code Coverage Runner
# =============================================================================
# File: tests/coverage_runner.R
# Purpose: Generate code coverage reports using covr
# =============================================================================

cat("========================================\n")
cat("Code Coverage Analysis\n")
cat("========================================\n\n")

# Check if covr is available
if (!requireNamespace("covr", quietly = TRUE)) {
  cat("Installing covr package...\n")
  install.packages("covr", repos = "https://cloud.r-project.org")
}

library(covr)

# Set working directory
if (basename(getwd()) == "tests") {
  setwd("..")
}

cat("Working directory:", getwd(), "\n\n")

# Define source files to measure coverage for
source_files <- c(
  # Core files
  "utils.R",
  "vocabulary.R"
)

# Add server modules if directory exists
if (dir.exists("server_modules")) {
  source_files <- c(
    source_files,
    list.files("server_modules", pattern = "\\.R$", full.names = TRUE)
  )
} else {
  cat("Warning: server_modules directory not found\n")
}

# Filter to existing files
source_files <- source_files[file.exists(source_files)]

# Validate source files not empty
if (length(source_files) == 0) {
  cat("ERROR: No source files found\n")
  quit(status = 1)
}

cat("Measuring coverage for", length(source_files), "source files:\n")
for (f in source_files) {
  cat("  -", f, "\n")
}

# Define test files
test_files <- list.files(
  "tests/testthat",
  pattern = "^test-.*\\.R$",
  full.names = TRUE
)

cat("\nUsing", length(test_files), "test files\n\n")

# Run coverage analysis
cat("Running coverage analysis (this may take a few minutes)...\n\n")

coverage <- tryCatch({
  covr::file_coverage(
    source_files = source_files,
    test_files = test_files
  )
}, error = function(e) {
  cat("Error running coverage:", e$message, "\n")
  NULL
})

if (!is.null(coverage)) {
  # Print summary
  cat("\n========================================\n")
  cat("COVERAGE SUMMARY\n")
  cat("========================================\n")

  print(coverage)

  # Calculate overall percentage
  coverage_df <- as.data.frame(coverage)
  if (nrow(coverage_df) > 0) {
    total_lines <- sum(coverage_df$value >= 0, na.rm = TRUE)
    covered_lines <- sum(coverage_df$value > 0, na.rm = TRUE)

    # Guard clause for division by zero
    if (total_lines > 0) {
      percentage <- round(covered_lines / total_lines * 100, 1)
    } else {
      percentage <- 0
    }

    cat("\n----------------------------------------\n")
    cat(sprintf("Overall Coverage: %.1f%% (%d/%d lines)\n",
                percentage, covered_lines, total_lines))
    cat("----------------------------------------\n")

    # Target check
    if (percentage >= 60) {
      cat("\n✅ Coverage meets 60% target!\n")
    } else {
      cat(sprintf("\n⚠️  Coverage below 60%% target (need %.1f%% more)\n",
                  60 - percentage))
    }
  }

  # Generate HTML report
  report_path <- "tests/coverage_report.html"
  cat("\nGenerating HTML report:", report_path, "\n")

  tryCatch({
    covr::report(coverage, file = report_path, browse = FALSE)
    cat("✅ HTML report generated successfully\n")
  }, error = function(e) {
    cat("Warning: Could not generate HTML report:", e$message, "\n")
  })

  # Generate Cobertura XML for CI/CD
  xml_path <- "tests/coverage.xml"
  cat("Generating Cobertura XML:", xml_path, "\n")

  tryCatch({
    covr::to_cobertura(coverage, filename = xml_path)
    cat("✅ Cobertura XML generated successfully\n")
  }, error = function(e) {
    cat("Warning: Could not generate Cobertura XML:", e$message, "\n")
  })

} else {
  cat("\n❌ Coverage analysis failed\n")
  quit(status = 1)
}

cat("\n========================================\n")
cat("Coverage analysis complete\n")
cat("========================================\n")
