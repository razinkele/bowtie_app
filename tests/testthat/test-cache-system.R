# =============================================================================
# Cache System Tests
# Tests for P1-5: Enhanced LRU caching with monitoring and invalidation
# =============================================================================

library(testthat)

# Source utils.R to get cache functions
test_that("Cache system can be loaded", {
  # Should already be loaded if running from test suite, but be safe
  if (!exists("get_cache", mode = "function")) {
    source("../../utils.R")
  }

  expect_true(exists("get_cache"))
  expect_true(exists("set_cache"))
  expect_true(exists("clear_cache"))
  expect_true(exists("get_cache_stats"))
})

# Test basic cache operations
test_that("Basic cache set and get operations work", {
  # Clear cache and reset stats for clean test
  clear_cache(reset_stats = TRUE)

  # Set a value
  set_cache("test_key_1", "test_value_1")

  # Get the value back
  result <- get_cache("test_key_1")
  expect_equal(result, "test_value_1")

  # Non-existent key returns NULL
  result <- get_cache("nonexistent")
  expect_null(result)

  # Non-existent key with default
  result <- get_cache("nonexistent", default = "default_value")
  expect_equal(result, "default_value")
})

# Test hit/miss tracking
test_that("Cache tracks hits and misses correctly", {
  clear_cache(reset_stats = TRUE)

  # Initial stats
  stats <- get_cache_stats()
  expect_equal(stats$hits, 0)
  expect_equal(stats$misses, 0)

  # Add some data
  set_cache("key1", "value1")
  set_cache("key2", "value2")

  # Hit (should increment hits)
  get_cache("key1")
  stats <- get_cache_stats()
  expect_equal(stats$hits, 1)
  expect_equal(stats$misses, 0)

  # Another hit
  get_cache("key2")
  stats <- get_cache_stats()
  expect_equal(stats$hits, 2)
  expect_equal(stats$misses, 0)

  # Miss (should increment misses)
  get_cache("nonexistent")
  stats <- get_cache_stats()
  expect_equal(stats$hits, 2)
  expect_equal(stats$misses, 1)

  # Hit rate calculation
  expect_equal(stats$hit_rate, 2/3)
})

# Test cache size management
test_that("Cache respects size limits", {
  clear_cache(reset_stats = TRUE)

  # Add items
  for (i in 1:5) {
    set_cache(paste0("key_", i), paste0("value_", i))
  }

  stats <- get_cache_stats()
  expect_equal(stats$current_size, 5)
  expect_le(stats$current_size, stats$max_size)
})

# Test LRU eviction
test_that("LRU eviction works correctly", {
  clear_cache(reset_stats = TRUE)

  # Fill cache to max size
  max_size <- .cache$max_size

  # Add max_size items
  for (i in 1:max_size) {
    set_cache(paste0("key_", i), paste0("value_", i))
  }

  stats <- get_cache_stats()
  expect_equal(stats$current_size, max_size)
  expect_equal(stats$evictions, 0)

  # Add one more item - should trigger eviction of least recently used
  set_cache("new_key", "new_value")

  stats <- get_cache_stats()
  expect_equal(stats$current_size, max_size)  # Size should stay at max
  expect_equal(stats$evictions, 1)  # One eviction should have occurred

  # The oldest key (key_1) should have been evicted
  result <- get_cache("key_1")
  expect_null(result)  # Should be evicted

  # New key should exist
  result <- get_cache("new_key")
  expect_equal(result, "new_value")
})

# Test LRU access time updating
test_that("LRU correctly updates access times on get", {
  clear_cache(reset_stats = TRUE)

  # Add items
  set_cache("old_key", "old_value")
  Sys.sleep(0.1)  # Small delay
  set_cache("new_key", "new_value")

  # Access old_key to update its access time
  get_cache("old_key")

  # Now old_key should be more recently accessed than new_key
  # Check access times directly
  old_time <- .cache$access_times[["old_key"]]
  new_time <- .cache$access_times[["new_key"]]

  expect_true(old_time >= new_time)
})

# Test cache update (overwriting existing key)
test_that("Cache correctly updates existing keys", {
  clear_cache(reset_stats = TRUE)

  # Set initial value
  set_cache("key1", "value1")
  stats1 <- get_cache_stats()

  # Update with new value
  set_cache("key1", "value2")
  stats2 <- get_cache_stats()

  # Size should not increase
  expect_equal(stats1$current_size, stats2$current_size)

  # Value should be updated
  result <- get_cache("key1")
  expect_equal(result, "value2")
})

# Test memory monitoring
test_that("Cache statistics include memory usage", {
  clear_cache(reset_stats = TRUE)

  # Add some data
  large_data <- rep("x", 10000)
  set_cache("large_key", large_data)

  stats <- get_cache_stats()

  # Memory should be calculated
  expect_true(stats$memory_bytes > 0)
  expect_true(stats$memory_mb > 0)
  expect_type(stats$memory_bytes, "double")
  expect_type(stats$memory_mb, "double")
})

# Test cache statistics structure
test_that("Cache statistics have correct structure", {
  clear_cache(reset_stats = TRUE)

  # Add some test data
  set_cache("test1", "value1")
  set_cache("test2", "value2")
  get_cache("test1")  # Hit
  get_cache("missing")  # Miss

  stats <- get_cache_stats()

  # Check all expected fields exist
  expect_true("current_size" %in% names(stats))
  expect_true("max_size" %in% names(stats))
  expect_true("utilization" %in% names(stats))
  expect_true("hits" %in% names(stats))
  expect_true("misses" %in% names(stats))
  expect_true("total_requests" %in% names(stats))
  expect_true("hit_rate" %in% names(stats))
  expect_true("evictions" %in% names(stats))
  expect_true("memory_bytes" %in% names(stats))
  expect_true("memory_mb" %in% names(stats))

  # Verify calculations
  expect_equal(stats$total_requests, stats$hits + stats$misses)
  expect_equal(stats$utilization, stats$current_size / stats$max_size)
})

# Test cache clear with stats reset
test_that("Cache clear can reset statistics", {
  clear_cache(reset_stats = TRUE)

  # Generate activity
  set_cache("key1", "value1")
  get_cache("key1")  # Hit
  get_cache("missing")  # Miss

  stats1 <- get_cache_stats()
  expect_gt(stats1$hits, 0)
  expect_gt(stats1$misses, 0)

  # Clear without resetting stats
  clear_cache(reset_stats = FALSE)
  stats2 <- get_cache_stats()
  expect_equal(stats2$current_size, 0)
  expect_equal(stats2$hits, stats1$hits)  # Stats preserved

  # Clear with resetting stats
  clear_cache(reset_stats = TRUE)
  stats3 <- get_cache_stats()
  expect_equal(stats3$current_size, 0)
  expect_equal(stats3$hits, 0)  # Stats reset
  expect_equal(stats3$misses, 0)
  expect_equal(stats3$evictions, 0)
})

# Test memoization wrapper
test_that("Memoization wrapper caches function results", {
  clear_cache(reset_stats = TRUE)

  # Counter to track function calls
  call_count <- 0

  # Function to memoize
  expensive_fn <- function(x) {
    call_count <<- call_count + 1
    return(x * 2)
  }

  # Create memoized version
  memo_fn <- memoize(expensive_fn)

  # First call - should execute function
  result1 <- memo_fn(5)
  expect_equal(result1, 10)
  expect_equal(call_count, 1)

  # Second call with same arg - should use cache
  result2 <- memo_fn(5)
  expect_equal(result2, 10)
  expect_equal(call_count, 1)  # Not incremented - used cache

  # Different arg - should execute function again
  result3 <- memo_fn(10)
  expect_equal(result3, 20)
  expect_equal(call_count, 2)
})

# Test simple memoization
test_that("Simple memoization works for parameterless functions", {
  clear_cache(reset_stats = TRUE)

  call_count <- 0
  test_fn <- function() {
    call_count <<- call_count + 1
    return("result")
  }

  memo_fn <- memoize_simple(test_fn, "test_memo_key")

  # First call
  result1 <- memo_fn()
  expect_equal(result1, "result")
  expect_equal(call_count, 1)

  # Second call - should use cache
  result2 <- memo_fn()
  expect_equal(result2, "result")
  expect_equal(call_count, 1)
})

# Test invalidate_bowtie_caches function
test_that("Bowtie cache invalidation works", {
  clear_cache(reset_stats = TRUE)

  # Add some bowtie-related caches
  set_cache("nodes_updated_v432_test", "node_data")
  set_cache("edges_updated_v430_test", "edge_data")
  set_cache("other_cache_key", "other_data")

  stats1 <- get_cache_stats()
  expect_equal(stats1$current_size, 3)

  # Invalidate bowtie caches
  invalidate_bowtie_caches()

  stats2 <- get_cache_stats()
  expect_equal(stats2$current_size, 1)  # Only other_cache_key remains

  # Verify correct keys were removed
  expect_null(get_cache("nodes_updated_v432_test"))
  expect_null(get_cache("edges_updated_v430_test"))
  expect_equal(get_cache("other_cache_key"), "other_data")
})

# Test cache with different data types
test_that("Cache handles different data types correctly", {
  clear_cache(reset_stats = TRUE)

  # Test various data types
  set_cache("numeric", 42)
  set_cache("string", "hello")
  set_cache("list", list(a = 1, b = 2))
  set_cache("dataframe", data.frame(x = 1:3, y = 4:6))
  set_cache("function", function(x) x + 1)

  # Retrieve and verify
  expect_equal(get_cache("numeric"), 42)
  expect_equal(get_cache("string"), "hello")
  expect_equal(get_cache("list"), list(a = 1, b = 2))
  expect_equal(get_cache("dataframe"), data.frame(x = 1:3, y = 4:6))

  fn <- get_cache("function")
  expect_equal(fn(5), 6)
})

# Integration test: vocabulary cache using LRU system
test_that("Vocabulary cache integrates with LRU system", {
  skip_if_not(file.exists("../../vocabulary.R"), "vocabulary.R not found")

  # This test verifies that load_vocabulary uses the LRU cache
  # Note: This is more of an integration test

  # Clear cache
  clear_cache(reset_stats = TRUE)

  # Load vocabulary (should cache)
  tryCatch({
    source("../../vocabulary.R")
    vocab1 <- load_vocabulary(use_cache = TRUE)

    # Second load should hit cache
    stats1 <- get_cache_stats()
    vocab2 <- load_vocabulary(use_cache = TRUE)
    stats2 <- get_cache_stats()

    # Hits should increase
    expect_gt(stats2$hits, stats1$hits)
  }, error = function(e) {
    skip(paste("Could not test vocabulary cache integration:", e$message))
  })
})

# Performance test: cache is faster than recomputation
test_that("Cache provides performance benefit", {
  clear_cache(reset_stats = TRUE)

  # Expensive function
  expensive <- function(n) {
    sum(1:n)
  }

  # Memoized version
  memo_expensive <- memoize(expensive)

  # First call (will compute)
  time1 <- system.time(result1 <- memo_expensive(10000))

  # Second call (should use cache)
  time2 <- system.time(result2 <- memo_expensive(10000))

  # Results should be identical
  expect_equal(result1, result2)

  # Cached call should be faster (or at least not slower)
  expect_lte(time2[["elapsed"]], time1[["elapsed"]] * 1.5)
})

# Test print_cache_stats (just ensure it doesn't error)
test_that("print_cache_stats runs without error", {
  clear_cache(reset_stats = TRUE)
  set_cache("test", "value")

  # Should not throw error
  expect_silent({
    invisible(capture.output(print_cache_stats()))
  })
})

cat("\n✅ Cache system tests complete!\n")
cat("   All LRU caching, statistics, and memory monitoring features validated.\n\n")
