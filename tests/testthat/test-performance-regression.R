# test-performance-regression.R
# Performance regression tests for version 5.2
# Monitors application performance and prevents performance degradation

library(testthat)

context("Performance Regression Testing")

# Robust file reader for tests
safe_read <- function(filename) {
  # Prefer parent dir first (so shims in tests/testthat don't mask real files)
  parent <- file.path("..", filename)
  if (file.exists(parent)) return(readLines(parent))
  if (file.exists(filename)) return(readLines(filename))

  # Search common parent paths (supports temp/test copies where parent may differ)
  search_dirs <- c("..", "../..", "../../..", "../../../..")
  for (d in search_dirs) {
    if (!dir.exists(d)) next
    files <- list.files(d, pattern = paste0("^", gsub("\\.", "\\\\.", filename), "$"), ignore.case = TRUE, full.names = TRUE)
    if (length(files) > 0) return(readLines(files[1]))
  }

  # Finally, try a recursive search from current dir
  rec_files <- list.files(".", pattern = basename(filename), ignore.case = TRUE, recursive = TRUE, full.names = TRUE)
  if (length(rec_files) > 0) return(readLines(rec_files[1]))

  # Return empty content if not found (performance tests tolerate missing docs)
  return(character(0))
}

# Helper function to measure memory usage
get_memory_usage <- function() {
  if (requireNamespace("pryr", quietly = TRUE)) {
    pryr::mem_used()
  } else {
    # Fallback method
    gc_info <- gc()
    sum(gc_info[, "used"] * c(8, 8))  # Approximate memory usage
  }
}

test_that("Application startup time is within acceptable limits", {
  skip_if_not_installed("microbenchmark")
  library(microbenchmark)

  # Measure startup time
  startup_benchmark <- microbenchmark(
    {
      # Clear environment to simulate fresh start
      rm(list = ls(all.names = TRUE))
      gc()

      # Source main components
      source("global.R", chdir = TRUE)
    },
    times = 3,
    unit = "s"
  )

  median_time <- median(startup_benchmark$time) / 1e9  # Convert to seconds

  expect_true(median_time < 15,
              sprintf("Startup time (%.2f seconds) should be under 15 seconds", median_time))

  cat("Application startup time: ", median_time, " seconds\n")
})

test_that("Vocabulary loading performance is acceptable", {
  skip_if_not_installed("microbenchmark")
  library(microbenchmark)

  # Ensure vocabulary.r is available
  expect_true(file.exists("vocabulary.r"), "vocabulary.r file should exist")

  # Measure vocabulary loading time
  vocab_benchmark <- microbenchmark(
    {
      source("vocabulary.r", chdir = TRUE)
      vocabulary_data <- load_vocabulary()
    },
    times = 5,
    unit = "ms"
  )

  median_time <- median(vocab_benchmark$time) / 1e6  # Convert to milliseconds

  expect_true(median_time < 2000,
              sprintf("Vocabulary loading (%.0f ms) should be under 2 seconds", median_time))

  cat("Vocabulary loading time: ", median_time, " ms\n")
})

test_that("Memory usage is within reasonable bounds", {
  initial_memory <- get_memory_usage()

  # Load main application components
  source("global.R")

  post_load_memory <- get_memory_usage()
  memory_increase <- post_load_memory - initial_memory

  # Memory increase should be reasonable (less than 500MB)
  memory_limit_mb <- 500 * 1024 * 1024  # 500MB in bytes

  expect_true(memory_increase < memory_limit_mb,
              sprintf("Memory increase (%.1f MB) should be under 500MB",
                     memory_increase / (1024 * 1024)))

  cat("Memory increase after loading: ",
      round(memory_increase / (1024 * 1024), 2), " MB\n")
})

test_that("Guided workflow initialization performance", {
  skip_if_not_installed("microbenchmark")
  library(microbenchmark)

  # Ensure guided workflow file exists
  expect_true(file.exists("guided_workflow.r"), "guided_workflow.r should exist")

  # Measure guided workflow loading time
  workflow_benchmark <- microbenchmark(
    {
      source("guided_workflow.R", chdir = TRUE)
    },
    times = 3,
    unit = "ms"
  )

  median_time <- median(workflow_benchmark$time) / 1e6  # Convert to milliseconds

  expect_true(median_time < 5000,
              sprintf("Guided workflow loading (%.0f ms) should be under 5 seconds", median_time))

  cat("Guided workflow loading time: ", median_time, " ms\n")
})

test_that("Large dataset processing performance", {
  skip_if_not_installed("microbenchmark")
  library(microbenchmark)

  # Load utilities for data generation
  source("utils.R")

  # Generate larger test dataset
  large_data_benchmark <- microbenchmark(
    {
      # Generate comprehensive environmental data
      large_data <- generate_comprehensive_environmental_data(
        num_scenarios = 100,  # Generate 100 scenarios
        activities_per_scenario = 5,
        pressures_per_scenario = 4,
        consequences_per_scenario = 3,
        controls_per_scenario = 6
      )
    },
    times = 3,
    unit = "s"
  )

  median_time <- median(large_data_benchmark$time) / 1e9  # Convert to seconds

  expect_true(median_time < 30,
              sprintf("Large dataset generation (%.2f seconds) should be under 30 seconds", median_time))

  cat("Large dataset generation time: ", median_time, " seconds\n")
})

test_that("Icon rendering performance after standardization", {
  # This is a structural test since we can't easily measure icon rendering
  # We test that the standardized approach doesn't introduce performance issues

  # Count icon() function calls in main UI file
  if (file.exists("ui.R")) {
    ui_content <- readLines("ui.R")
    icon_calls <- length(grep('icon\\(', ui_content))

    # Should have reasonable number of icon calls (not excessive)
    expect_true(icon_calls < 200,
                sprintf("Number of icon calls (%d) should be reasonable", icon_calls))

    cat("Total icon() calls in ui.R: ", icon_calls, "\n")
  }

  # Test that guided workflow icons are efficiently implemented
  workflow_content <- safe_read("guided_workflow.r")
  if (length(workflow_content) > 0) {
    workflow_icons <- length(grep('icon\\(', workflow_content))

    expect_true(workflow_icons < 50,
                sprintf("Guided workflow icon calls (%d) should be efficient", workflow_icons))

    cat("Guided workflow icon() calls: ", workflow_icons, "\n")
  }
})

test_that("No memory leaks in module loading", {
  initial_objects <- length(ls(all.names = TRUE))
  initial_memory <- get_memory_usage()

  # Load and unload modules multiple times to test for leaks
  for (i in 1:5) {
    # Load modules
    source("guided_workflow.R")

    # Force garbage collection
    gc()

    # Clear specific objects that might accumulate
    if (exists("temp_workflow_data")) rm(temp_workflow_data)
  }

  final_memory <- get_memory_usage()
  final_objects <- length(ls(all.names = TRUE))

  memory_growth <- final_memory - initial_memory
  object_growth <- final_objects - initial_objects

  # Memory growth should be minimal
  expect_true(memory_growth < 50 * 1024 * 1024,  # Less than 50MB growth
              sprintf("Memory growth (%.1f MB) should be minimal",
                     memory_growth / (1024 * 1024)))

  # Object count should not grow excessively
  expect_true(object_growth < 20,
              sprintf("Object count growth (%d) should be minimal", object_growth))

  cat("Memory growth after repeated loading: ",
      round(memory_growth / (1024 * 1024), 2), " MB\n")
  cat("Object count growth: ", object_growth, "\n")
})

# Benchmark comparison test
test_that("Performance is better than or equal to baseline", {
  # This test establishes performance baselines for future comparisons

  baseline_times <- list(
    startup = 15.0,      # seconds
    vocabulary = 2.0,    # seconds
    workflow = 5.0,      # seconds
    large_data = 30.0    # seconds
  )

  # Store current performance metrics
  current_metrics <- list()

  if (requireNamespace("microbenchmark", quietly = TRUE)) {
    # Quick startup test
    startup_time <- system.time({
      source("global.R")
    })[["elapsed"]]

    current_metrics$startup <- startup_time

    expect_true(startup_time <= baseline_times$startup * 1.1,  # Allow 10% tolerance
                sprintf("Startup time (%.2f s) should be within 10%% of baseline (%.2f s)",
                       startup_time, baseline_times$startup))
  }

  cat("Performance baselines established:\n")
  for (metric in names(baseline_times)) {
    cat("  ", metric, ": ", baseline_times[[metric]], " seconds\n")
  }
})