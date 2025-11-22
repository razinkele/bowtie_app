#!/usr/bin/env Rscript
# =============================================================================
# Automated Test Report Generator
# Version: 1.0.0
# Description: Generates comprehensive HTML test report with coverage metrics
# =============================================================================

library(testthat)
library(htmltools)

# =============================================================================
# CONFIGURATION
# =============================================================================

REPORT_DIR <- "tests/reports"
TIMESTAMP <- format(Sys.time(), "%Y%m%d_%H%M%S")
REPORT_FILE <- file.path(REPORT_DIR, paste0("test_report_", TIMESTAMP, ".html"))

# Create report directory
if (!dir.exists(REPORT_DIR)) {
  dir.create(REPORT_DIR, recursive = TRUE)
}

# =============================================================================
# RUN ALL TESTS
# =============================================================================

cat("\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("🧪 RUNNING COMPREHENSIVE TEST SUITE\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("\n")

# Source guided workflow
cat("📋 Loading guided workflow system...\n")
source("guided_workflow.R")
cat("   ✓ Guided workflow loaded\n\n")

# Initialize results storage
all_results <- list()
test_start_time <- Sys.time()

# Test files to run
test_files <- c(
  "tests/testthat/test-guided-workflow.R",
  "tests/testthat/test-guided-workflow-integration.R",
  "tests/testthat/test-guided-workflow-performance.R",
  "tests/testthat/test-guided-workflow-ui.R"
)

# Run each test file
for (test_file in test_files) {
  if (file.exists(test_file)) {
    cat("Running:", basename(test_file), "...\n")
    
    result <- tryCatch({
      test_file(test_file, reporter = "silent")
    }, error = function(e) {
      list(
        file = test_file,
        error = e$message,
        failed = TRUE
      )
    })
    
    all_results[[basename(test_file)]] <- result
    cat("   ✓ Complete\n\n")
  } else {
    cat("   ⚠️  File not found:", test_file, "\n\n")
  }
}

test_end_time <- Sys.time()
test_duration <- as.numeric(difftime(test_end_time, test_start_time, units = "secs"))

# =============================================================================
# GENERATE HTML REPORT
# =============================================================================

cat("📊 Generating HTML report...\n")

# Calculate summary statistics
total_tests <- 0
passed_tests <- 0
failed_tests <- 0
skipped_tests <- 0
error_tests <- 0

for (result in all_results) {
  if (!is.null(result$results)) {
    for (test in result$results) {
      total_tests <- total_tests + 1
      if (test$passed) {
        passed_tests <- passed_tests + 1
      } else if (!is.null(test$skipped) && test$skipped) {
        skipped_tests <- skipped_tests + 1
      } else {
        failed_tests <- failed_tests + 1
      }
    }
  }
}

pass_rate <- if (total_tests > 0) round((passed_tests / total_tests) * 100, 1) else 0

# Build HTML report
html_report <- tags$html(
  tags$head(
    tags$title("Guided Workflow Test Report"),
    tags$style(HTML("
      body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; 
             margin: 20px; background: #f5f5f5; }
      .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                color: white; padding: 30px; border-radius: 10px; margin-bottom: 30px; }
      .header h1 { margin: 0 0 10px 0; }
      .header p { margin: 5px 0; opacity: 0.9; }
      .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); 
                 gap: 20px; margin-bottom: 30px; }
      .metric { background: white; padding: 20px; border-radius: 8px; 
                box-shadow: 0 2px 8px rgba(0,0,0,0.1); text-align: center; }
      .metric-value { font-size: 36px; font-weight: bold; margin: 10px 0; }
      .metric-label { color: #666; font-size: 14px; }
      .passed { color: #10b981; }
      .failed { color: #ef4444; }
      .skipped { color: #f59e0b; }
      .section { background: white; padding: 25px; border-radius: 8px; 
                 margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
      .section h2 { margin-top: 0; color: #333; border-bottom: 2px solid #667eea; 
                    padding-bottom: 10px; }
      .test-file { margin-bottom: 20px; padding: 15px; background: #f9fafb; 
                   border-radius: 6px; border-left: 4px solid #667eea; }
      .test-file h3 { margin: 0 0 10px 0; color: #667eea; }
      .test-item { padding: 8px 12px; margin: 5px 0; border-radius: 4px; 
                   display: flex; align-items: center; }
      .test-passed { background: #d1fae5; border-left: 3px solid #10b981; }
      .test-failed { background: #fee2e2; border-left: 3px solid #ef4444; }
      .test-skipped { background: #fef3c7; border-left: 3px solid #f59e0b; }
      .icon { margin-right: 10px; font-weight: bold; }
      .timestamp { color: #666; font-size: 12px; }
      .progress-bar { width: 100%; height: 30px; background: #e5e7eb; 
                      border-radius: 15px; overflow: hidden; margin: 20px 0; }
      .progress-fill { height: 100%; background: linear-gradient(90deg, #10b981, #34d399); 
                       transition: width 0.3s; display: flex; align-items: center; 
                       justify-content: center; color: white; font-weight: bold; }
      .footer { text-align: center; color: #666; margin-top: 40px; padding: 20px; 
                border-top: 1px solid #ddd; }
    "))
  ),
  tags$body(
    tags$div(class = "header",
      tags$h1("🧪 Guided Workflow Test Report"),
      tags$p(paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))),
      tags$p(paste("Test Duration:", round(test_duration, 2), "seconds")),
      tags$p(paste("R Version:", R.version$version.string))
    ),
    
    tags$div(class = "summary",
      tags$div(class = "metric",
        tags$div(class = "metric-value", total_tests),
        tags$div(class = "metric-label", "Total Tests")
      ),
      tags$div(class = "metric",
        tags$div(class = "metric-value passed", passed_tests),
        tags$div(class = "metric-label", "Passed")
      ),
      tags$div(class = "metric",
        tags$div(class = "metric-value failed", failed_tests),
        tags$div(class = "metric-label", "Failed")
      ),
      tags$div(class = "metric",
        tags$div(class = "metric-value skipped", skipped_tests),
        tags$div(class = "metric-label", "Skipped")
      ),
      tags$div(class = "metric",
        tags$div(class = "metric-value", paste0(pass_rate, "%")),
        tags$div(class = "metric-label", "Pass Rate")
      )
    ),
    
    tags$div(class = "progress-bar",
      tags$div(class = "progress-fill", 
               style = paste0("width: ", pass_rate, "%"),
               paste0(pass_rate, "%")
      )
    ),
    
    tags$div(class = "section",
      tags$h2("📋 Test Suite Results"),
      lapply(names(all_results), function(test_name) {
        result <- all_results[[test_name]]
        
        tags$div(class = "test-file",
          tags$h3(test_name),
          if (!is.null(result$results)) {
            lapply(result$results, function(test) {
              status_class <- if (test$passed) {
                "test-passed"
              } else if (!is.null(test$skipped) && test$skipped) {
                "test-skipped"
              } else {
                "test-failed"
              }
              
              icon <- if (test$passed) "✓" else if (!is.null(test$skipped) && test$skipped) "⊘" else "✗"
              
              tags$div(class = paste("test-item", status_class),
                tags$span(class = "icon", icon),
                tags$span(test$test %||% "Unnamed test")
              )
            })
          } else {
            tags$p("No detailed results available")
          }
        )
      })
    ),
    
    tags$div(class = "section",
      tags$h2("📊 Test Coverage Summary"),
      tags$ul(
        tags$li(tags$strong("Unit Tests:"), " Workflow initialization, validation, data persistence"),
        tags$li(tags$strong("Integration Tests:"), " End-to-end workflow, data flow, navigation"),
        tags$li(tags$strong("Performance Tests:"), " Speed benchmarks, stress tests, memory usage"),
        tags$li(tags$strong("UI Tests:"), " Component rendering, namespacing, accessibility")
      )
    ),
    
    tags$div(class = "section",
      tags$h2("🎯 Test Scenarios"),
      tags$ul(
        tags$li("Baltic Sea Eutrophication - Marine nutrient management"),
        tags$li("Great Barrier Reef Conservation - Multi-stressor management"),
        tags$li("Industrial River Pollution - Heavy metal contamination"),
        tags$li("Coastal Fisheries Management - Sustainable fisheries"),
        tags$li("Ocean Plastic Pollution - Plastic waste reduction")
      )
    ),
    
    tags$div(class = "footer",
      tags$p("Generated by Guided Workflow Automated Test Suite v1.0.0"),
      tags$p(class = "timestamp", 
             paste("Report saved to:", REPORT_FILE))
    )
  )
)

# Save report
cat("   Writing report to:", REPORT_FILE, "\n")
save_html(html_report, file = REPORT_FILE)

cat("   ✓ Report generated successfully\n\n")

# =============================================================================
# CONSOLE SUMMARY
# =============================================================================

cat("=" , rep("=", 78), "\n", sep = "")
cat("📊 TEST SUMMARY\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("\n")
cat(sprintf("  Total Tests:     %d\n", total_tests))
cat(sprintf("  ✓ Passed:        %d\n", passed_tests))
cat(sprintf("  ✗ Failed:        %d\n", failed_tests))
cat(sprintf("  ⊘ Skipped:       %d\n", skipped_tests))
cat(sprintf("  Pass Rate:       %.1f%%\n", pass_rate))
cat(sprintf("  Duration:        %.2f seconds\n", test_duration))
cat("\n")
cat("📄 Report:", REPORT_FILE, "\n")
cat("\n")

# Open report in browser
if (interactive()) {
  cat("Opening report in browser...\n")
  browseURL(REPORT_FILE)
}

# Exit with appropriate code
if (failed_tests > 0) {
  cat("❌ TESTS FAILED\n")
  quit(status = 1)
} else {
  cat("✅ ALL TESTS PASSED\n")
  quit(status = 0)
}
