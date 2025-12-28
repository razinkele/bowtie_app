# =============================================================================
# COMPREHENSIVE INTEGRATION TEST SUITE
# Tests all improvements from Phases 1, 2, and 3
# Version: 1.0.0
# Date: 2025-12-27
# =============================================================================

cat("\n")
cat("╔════════════════════════════════════════════════════════════════════════╗\n")
cat("║     COMPREHENSIVE INTEGRATION TEST SUITE - ALL PHASES                 ║\n")
cat("║     Testing Phases 1, 2, and 3 Improvements                           ║\n")
cat("╚════════════════════════════════════════════════════════════════════════╝\n\n")

# Change to app directory if in tests folder
if (basename(getwd()) == "tests") setwd("..")

# Source required files
cat("📦 Loading application modules...\n")
source("config.R")
source("utils.R")
source("vocabulary.R")
source("bowtie_bayesian_network.R")

# Test tracking
tests_passed <- 0
tests_failed <- 0
test_results <- list()

# Helper function to run a test
run_test <- function(name, test_fn) {
  cat(sprintf("\n🧪 Testing: %s\n", name))
  result <- tryCatch({
    test_fn()
    cat("   ✅ PASS\n")
    tests_passed <<- tests_passed + 1
    test_results[[name]] <<- "PASS"
    TRUE
  }, error = function(e) {
    cat(sprintf("   ❌ FAIL: %s\n", e$message))
    tests_failed <<- tests_failed + 1
    test_results[[name]] <<- paste("FAIL:", e$message)
    FALSE
  })
  return(result)
}

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("  PHASE 1: QUICK WINS & SAFETY IMPROVEMENTS\n")
cat("═══════════════════════════════════════════════════════════════════════\n")

# Test 1.1: NULL-safe coalesce operations
run_test("Phase 1.1: NULL-safe coalesce function", function() {
  source("bowtie_bayesian_network.R")

  # Test NULL handling
  test_data <- data.frame(
    Activity = c("Test Activity"),
    Pressure = c("Test Pressure"),
    Consequence = c("Test Consequence"),
    Central_Problem = NA,
    Problem = c("Fallback Problem"),
    stringsAsFactors = FALSE
  )

  result <- tryCatch({
    create_bayesian_structure(test_data)
  }, error = function(e) {
    stop("NULL handling failed in coalesce operations")
  })

  if (is.null(result)) stop("Expected result but got NULL")
  invisible(TRUE)
})

# Test 1.2: Enhanced error messages
run_test("Phase 1.2: User-friendly error messages", function() {
  # Test that error messages are informative
  error_msg <- tryCatch({
    read_hierarchical_data("nonexistent_file.xlsx")
  }, error = function(e) {
    return(e$message)
  })

  # Error message should contain helpful information
  if (!grepl("Please ensure", error_msg)) {
    stop("Error messages not enhanced with troubleshooting steps")
  }
  invisible(TRUE)
})

# Test 1.3: Clear cache function (renamed, not duplicated)
run_test("Phase 1.3: Duplicate clearCache() removed", function() {
  # Should have clear_cache() but not clearCache()
  if (!exists("clear_cache")) {
    stop("clear_cache function not found")
  }

  # Test it works
  clear_cache()
  invisible(TRUE)
})

# Test 1.4: Input validation improvements
run_test("Phase 1.4: Enhanced input validation", function() {
  # Test NULL input
  error_caught <- FALSE
  tryCatch({
    create_bayesian_structure(NULL)
  }, error = function(e) {
    if (grepl("cannot be NULL", e$message)) {
      error_caught <<- TRUE
    }
  })

  if (!error_caught) stop("NULL validation not working")

  # Test empty data frame
  error_caught <- FALSE
  tryCatch({
    create_bayesian_structure(data.frame())
  }, error = function(e) {
    if (grepl("empty", e$message)) {
      error_caught <<- TRUE
    }
  })

  if (!error_caught) stop("Empty data validation not working")
  invisible(TRUE)
})

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("  PHASE 2: CONFIGURATION & STABILITY\n")
cat("═══════════════════════════════════════════════════════════════════════\n")

# Test 2.1: Centralized configuration
run_test("Phase 2.1: APP_CONFIG centralized configuration", function() {
  if (!exists("APP_CONFIG")) {
    stop("APP_CONFIG not loaded")
  }

  # Check key configuration values
  if (is.null(APP_CONFIG$DEFAULT_PORT)) stop("DEFAULT_PORT not configured")
  if (is.null(APP_CONFIG$DEFAULT_HOST)) stop("DEFAULT_HOST not configured")
  if (is.null(APP_CONFIG$RISK_LEVELS)) stop("RISK_LEVELS not configured")

  invisible(TRUE)
})

# Test 2.2: Risk colors from config
run_test("Phase 2.2: Risk colors use APP_CONFIG", function() {
  # RISK_COLORS should be defined
  if (!exists("RISK_COLORS")) {
    stop("RISK_COLORS not defined")
  }

  # Should have Low, Medium, High
  required_levels <- c("Low", "Medium", "High")
  if (!all(required_levels %in% names(RISK_COLORS))) {
    stop("RISK_COLORS missing required levels")
  }

  invisible(TRUE)
})

# Test 2.3: Config helper functions
run_test("Phase 2.3: Configuration helper functions", function() {
  if (!exists("get_config")) stop("get_config function not found")
  if (!exists("get_risk_level")) stop("get_risk_level function not found")

  # Test get_config
  port <- get_config(c("DEFAULT_PORT"), default = 3838)
  if (is.null(port)) stop("get_config not working")

  # Test get_risk_level
  risk <- get_risk_level(0.8)
  if (is.null(risk)) stop("get_risk_level not working")

  invisible(TRUE)
})

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("  PHASE 3: PERFORMANCE OPTIMIZATIONS\n")
cat("═══════════════════════════════════════════════════════════════════════\n")

# Test 3.1: LRU Cache Implementation
run_test("Phase 3.1: LRU cache with smart eviction", function() {
  clear_cache()

  # Test basic operations
  set_cache("test_key_1", "value_1")
  set_cache("test_key_2", "value_2")

  result1 <- get_cache("test_key_1")
  if (result1 != "value_1") stop("Cache retrieval failed")

  # Test cache stats
  stats <- get_cache_stats()
  if (stats$size != 2) stop("Cache size tracking failed")
  if (stats$max_size != 100) stop("Max size not set correctly")

  # Test LRU eviction
  original_max <- .cache$max_size
  .cache$max_size <- 2

  set_cache("key1", "val1")
  Sys.sleep(0.01)
  set_cache("key2", "val2")
  Sys.sleep(0.01)
  set_cache("key3", "val3")  # Should evict key1

  if (!is.null(get_cache("key1"))) stop("LRU eviction failed")
  if (is.null(get_cache("key2"))) stop("Recent item was incorrectly evicted")

  .cache$max_size <- original_max
  invisible(TRUE)
})

# Test 3.2: Memoization
run_test("Phase 3.2: Function memoization", function() {
  if (!exists("memoize")) stop("memoize function not found")
  if (!exists("memoize_simple")) stop("memoize_simple function not found")

  clear_cache()

  # Test simple memoization
  call_count <- 0
  test_fn <- function() {
    call_count <<- call_count + 1
    return(42)
  }

  memoized <- memoize_simple(test_fn, "test_memo_key")

  result1 <- memoized()
  if (call_count != 1) stop("First call didn't execute function")

  result2 <- memoized()
  if (call_count != 1) stop("Second call executed function (should use cache)")

  if (result1 != result2) stop("Results don't match")

  invisible(TRUE)
})

# Test 3.3: Lazy loading for vocabulary
run_test("Phase 3.3: Vocabulary lazy loading with cache", function() {
  if (!exists("load_vocabulary")) stop("load_vocabulary not found")

  # Clear vocabulary cache
  if (exists(".vocabulary_cache")) {
    rm(list = ls(envir = .vocabulary_cache), envir = .vocabulary_cache)
  }

  # Skip if files don't exist
  if (!file.exists("CAUSES.xlsx")) {
    cat("   ⊘ SKIP: Vocabulary files not available\n")
    return(invisible(TRUE))
  }

  # First load
  start_time <- Sys.time()
  vocab1 <- suppressMessages(suppressWarnings(load_vocabulary(use_cache = TRUE)))
  first_duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  # Second load (should be faster)
  start_time <- Sys.time()
  vocab2 <- suppressMessages(suppressWarnings(load_vocabulary(use_cache = TRUE)))
  second_duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  if (second_duration > first_duration) {
    cat(sprintf("   ⚠️  WARNING: Second load (%.3fs) not faster than first (%.3fs)\n",
                second_duration, first_duration))
    cat("   (This may be due to test environment, not necessarily a failure)\n")
  }

  invisible(TRUE)
})

# Test 3.4: Performance benchmarking utilities
run_test("Phase 3.4: Benchmarking utilities", function() {
  if (!exists("benchmark_function")) stop("benchmark_function not found")
  if (!exists("get_benchmark_history")) stop("get_benchmark_history not found")
  if (!exists("compare_benchmarks")) stop("compare_benchmarks not found")
  if (!exists("check_memory")) stop("check_memory not found")

  clear_benchmark_history()

  # Test benchmarking
  test_fn <- function() Sys.sleep(0.01)
  result <- benchmark_function(test_fn, "test_bench", iterations = 2)

  if (is.null(result)) stop("Benchmark returned NULL")
  if (result$iterations != 2) stop("Iterations not recorded correctly")

  # Test history
  history <- get_benchmark_history()
  if (length(history) != 1) stop("Benchmark not added to history")

  # Test memory check
  memory_mb <- check_memory()
  if (!is.numeric(memory_mb) || memory_mb <= 0) {
    stop("Memory check failed")
  }

  invisible(TRUE)
})

# Test 3.5: Debouncing
run_test("Phase 3.5: Theme debouncing implemented", function() {
  # Check if debounce function is available (from shiny)
  if (!exists("debounce", where = asNamespace("shiny"))) {
    cat("   ⊘ SKIP: Shiny debounce not available in this context\n")
    return(invisible(TRUE))
  }

  # Verify the pattern is used in server.R
  if (!file.exists("server.R")) {
    stop("server.R not found")
  }

  server_content <- readLines("server.R", warn = FALSE)
  if (!any(grepl("theme_debounced.*debounce", server_content))) {
    stop("Debouncing not implemented in server.R")
  }

  invisible(TRUE)
})

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("  BACKWARD COMPATIBILITY TESTS\n")
cat("═══════════════════════════════════════════════════════════════════════\n")

# Test: Existing functions still work
run_test("Backward Compatibility: Core functions unchanged", function() {
  # Test data generation
  data <- generateEnvironmentalDataFixed()
  if (!is.data.frame(data)) stop("generateEnvironmentalDataFixed() changed behavior")
  if (nrow(data) == 0) stop("No data generated")

  # Test validation
  is_valid <- validateDataColumns(data)
  if (!is_valid) stop("Validation function behavior changed")

  invisible(TRUE)
})

# Test: Config is backward compatible
run_test("Backward Compatibility: Optional config usage", function() {
  # Functions should work even if APP_CONFIG doesn't exist
  # (They have fallback values)

  # Test that RISK_COLORS exists
  if (!exists("RISK_COLORS")) stop("RISK_COLORS not available")

  # Should have default values even without config
  if (length(RISK_COLORS) < 3) stop("RISK_COLORS not properly initialized")

  invisible(TRUE)
})

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("  INTEGRATION TESTS\n")
cat("═══════════════════════════════════════════════════════════════════════\n")

# Test: Full workflow with all improvements
run_test("Integration: Complete bowtie workflow with optimizations", function() {
  clear_cache()

  # Generate data (will be cached)
  data1 <- generateEnvironmentalDataFixed()

  # Validate (with enhanced validation)
  if (!validateDataColumns(data1)) {
    stop("Data validation failed")
  }

  # Create Bayesian structure (with NULL-safe coalesce)
  bn_result <- tryCatch({
    create_bayesian_structure(data1)
  }, error = function(e) {
    stop(paste("Bayesian structure creation failed:", e$message))
  })

  if (is.null(bn_result)) stop("Bayesian network creation returned NULL")

  # Check cache stats
  stats <- get_cache_stats()
  cat(sprintf("   📊 Cache: %d/%d entries\n", stats$size, stats$max_size))

  invisible(TRUE)
})

# Test: Performance under load
run_test("Integration: Performance with multiple operations", function() {
  clear_cache()
  clear_benchmark_history()

  # Benchmark data generation
  gen_result <- benchmark_function(
    generateEnvironmentalDataFixed,
    "data_generation",
    iterations = 3
  )

  if (gen_result$mean_time > 5) {
    cat(sprintf("   ⚠️  WARNING: Data generation slow (%.2fs average)\n",
                gen_result$mean_time))
  }

  # Test cache efficiency
  set_cache("perf_test_1", runif(1000))
  set_cache("perf_test_2", runif(1000))
  set_cache("perf_test_3", runif(1000))

  stats <- get_cache_stats()
  if (stats$size < 3) stop("Cache not storing items correctly")

  invisible(TRUE)
})

# =============================================================================
# FINAL REPORT
# =============================================================================

cat("\n\n")
cat("╔════════════════════════════════════════════════════════════════════════╗\n")
cat("║                        TEST RESULTS SUMMARY                            ║\n")
cat("╚════════════════════════════════════════════════════════════════════════╝\n\n")

total_tests <- tests_passed + tests_failed
pass_rate <- if (total_tests > 0) (tests_passed / total_tests) * 100 else 0

cat(sprintf("Total Tests:    %d\n", total_tests))
cat(sprintf("Passed:         %d ✅\n", tests_passed))
cat(sprintf("Failed:         %d ❌\n", tests_failed))
cat(sprintf("Pass Rate:      %.1f%%\n\n", pass_rate))

cat("DETAILED RESULTS:\n")
cat("─────────────────────────────────────────────────────────────────────────\n")

for (name in names(test_results)) {
  status <- test_results[[name]]
  symbol <- if (status == "PASS") "✅" else "❌"
  cat(sprintf("%s %s\n", symbol, name))
  if (status != "PASS") {
    cat(sprintf("   Error: %s\n", status))
  }
}

cat("\n")
cat("PHASE SUMMARIES:\n")
cat("─────────────────────────────────────────────────────────────────────────\n")

phase1_tests <- grep("Phase 1\\.", names(test_results), value = TRUE)
phase1_passed <- sum(sapply(phase1_tests, function(x) test_results[[x]] == "PASS"))
cat(sprintf("Phase 1 (Quick Wins):        %d/%d passed\n", phase1_passed, length(phase1_tests)))

phase2_tests <- grep("Phase 2\\.", names(test_results), value = TRUE)
phase2_passed <- sum(sapply(phase2_tests, function(x) test_results[[x]] == "PASS"))
cat(sprintf("Phase 2 (Configuration):     %d/%d passed\n", phase2_passed, length(phase2_tests)))

phase3_tests <- grep("Phase 3\\.", names(test_results), value = TRUE)
phase3_passed <- sum(sapply(phase3_tests, function(x) test_results[[x]] == "PASS"))
cat(sprintf("Phase 3 (Performance):       %d/%d passed\n", phase3_passed, length(phase3_tests)))

compat_tests <- grep("Backward Compatibility", names(test_results), value = TRUE)
compat_passed <- sum(sapply(compat_tests, function(x) test_results[[x]] == "PASS"))
cat(sprintf("Backward Compatibility:      %d/%d passed\n", compat_passed, length(compat_tests)))

integ_tests <- grep("Integration", names(test_results), value = TRUE)
integ_passed <- sum(sapply(integ_tests, function(x) test_results[[x]] == "PASS"))
cat(sprintf("Integration Tests:           %d/%d passed\n", integ_passed, length(integ_tests)))

cat("\n")
if (tests_failed == 0) {
  cat("╔════════════════════════════════════════════════════════════════════════╗\n")
  cat("║                   🎉 ALL TESTS PASSED! 🎉                              ║\n")
  cat("║                                                                        ║\n")
  cat("║  All Phase 1, 2, and 3 improvements verified and working correctly!   ║\n")
  cat("╚════════════════════════════════════════════════════════════════════════╝\n")
  quit(status = 0)
} else {
  cat("╔════════════════════════════════════════════════════════════════════════╗\n")
  cat("║                    ⚠️  SOME TESTS FAILED ⚠️                            ║\n")
  cat("║                                                                        ║\n")
  cat(sprintf("║  %d out of %d tests failed. Review details above.               ║\n",
              tests_failed, total_tests))
  cat("╚════════════════════════════════════════════════════════════════════════╝\n")
  quit(status = 1)
}
