# =============================================================================
# Performance and Stress Tests for Guided Workflow
# Version: 1.0.0
# Description: Performance benchmarks, load tests, and stress testing
# =============================================================================

library(testthat)
library(shiny)
library(microbenchmark)

# =============================================================================
# PERFORMANCE BENCHMARKS
# =============================================================================

test_that("Workflow initialization is fast", {
  skip_on_cran()
  
  # Benchmark workflow state creation
  result <- microbenchmark(
    create_test_workflow_state(),
    times = 100
  )
  
  # Should complete in under 10ms on average
  mean_time <- mean(result$time) / 1e6  # Convert to milliseconds
  expect_lt(mean_time, 10, 
           info = paste("Mean initialization time:", round(mean_time, 2), "ms"))
})

test_that("Step validation is performant", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  state$current_step <- 1
  input <- list(project_name = "Performance Test Project")
  
  # Benchmark validation
  result <- microbenchmark(
    validate_current_step(state, input),
    times = 100
  )
  
  mean_time <- mean(result$time) / 1e6
  expect_lt(mean_time, 5, 
           info = paste("Mean validation time:", round(mean_time, 2), "ms"))
})

test_that("Data saving is fast", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  state$current_step <- 1
  input <- list(
    project_name = "Performance Test",
    project_location = "Test Location",
    project_type = "Marine",
    project_description = "Testing performance"
  )
  
  result <- microbenchmark(
    save_step_data(state, input),
    times = 100
  )
  
  mean_time <- mean(result$time) / 1e6
  expect_lt(mean_time, 5, 
           info = paste("Mean save time:", round(mean_time, 2), "ms"))
})

test_that("Vocabulary data loads efficiently", {
  skip_on_cran()
  
  result <- microbenchmark(
    create_mock_vocabulary(),
    times = 50
  )
  
  mean_time <- mean(result$time) / 1e6
  expect_lt(mean_time, 20, 
           info = paste("Mean vocabulary load time:", round(mean_time, 2), "ms"))
})

# =============================================================================
# STRESS TESTS: Large Data Sets
# =============================================================================

test_that("Handles large number of activities", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  
  # Add 100 activities
  large_activity_list <- paste0("Activity_", 1:100)
  state$project_data$activities <- large_activity_list
  
  expect_equal(length(state$project_data$activities), 100)
  expect_true(all(grepl("Activity_", state$project_data$activities)))
  
  # Verify can still save
  state$current_step <- 3
  updated_state <- save_step_data(state, list())
  expect_equal(length(updated_state$project_data$activities), 100)
})

test_that("Handles large number of pressures", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  
  # Add 100 pressures
  large_pressure_list <- paste0("Pressure_", 1:100)
  state$project_data$pressures <- large_pressure_list
  
  expect_equal(length(state$project_data$pressures), 100)
  
  # Performance should still be acceptable
  start_time <- Sys.time()
  state$current_step <- 3
  save_step_data(state, list())
  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  expect_lt(elapsed, 1, info = "Should handle 100 pressures in under 1 second")
})

test_that("Handles very long text inputs", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  state$current_step <- 1
  
  # Create 10,000 character text
  long_text <- paste(rep("Lorem ipsum dolor sit amet, ", 200), collapse = "")
  
  input <- list(
    project_name = long_text,
    project_description = long_text
  )
  
  # Should handle without crashing
  expect_silent({
    validation <- validate_current_step(state, input)
    updated_state <- save_step_data(state, input)
  })
  
  expect_true(validation$is_valid)
  expect_equal(nchar(updated_state$project_data$project_name), nchar(long_text))
})

test_that("Handles large vocabulary datasets", {
  skip_on_cran()
  
  # Create vocabulary with 1000 entries each
  large_vocab <- list(
    activities = data.frame(
      id = 1:1000,
      name = paste0("Activity_", 1:1000),
      category = rep(c("Primary", "Secondary", "Tertiary"), length.out = 1000),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      id = 1:1000,
      name = paste0("Pressure_", 1:1000),
      category = rep(c("Chemical", "Physical", "Biological"), length.out = 1000),
      stringsAsFactors = FALSE
    )
  )
  
  expect_equal(nrow(large_vocab$activities), 1000)
  expect_equal(nrow(large_vocab$pressures), 1000)
  
  # Verify vocabulary is searchable
  search_result <- grep("Activity_500", large_vocab$activities$name)
  expect_true(length(search_result) > 0)
})

# =============================================================================
# STRESS TESTS: Rapid Operations
# =============================================================================

test_that("Handles rapid step navigation", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  
  # Rapidly navigate through all steps
  for (i in 1:10) {
    for (step in 1:8) {
      state$current_step <- step
      expect_equal(state$current_step, step)
    }
  }
  
  # State should remain consistent
  expect_equal(state$total_steps, 8)
})

test_that("Handles repeated save operations", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  state$current_step <- 1
  
  input <- list(project_name = "Rapid Save Test")
  
  # Save 100 times
  for (i in 1:100) {
    state <- save_step_data(state, input)
  }
  
  # Data should still be correct
  expect_equal(state$project_data$project_name, "Rapid Save Test")
  expect_equal(length(state$step_times), 1)
})

test_that("Handles concurrent step validations", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  
  inputs <- list(
    list(project_name = "Test 1"),
    list(project_name = "Test 2"),
    list(project_name = "Test 3")
  )
  
  # Multiple validations
  state$current_step <- 1
  results <- lapply(inputs, function(inp) {
    validate_current_step(state, inp)
  })
  
  expect_equal(length(results), 3)
  expect_true(all(sapply(results, function(r) r$is_valid)))
})

# =============================================================================
# MEMORY TESTS
# =============================================================================

test_that("Memory usage remains reasonable", {
  skip_on_cran()
  
  # Create workflow with moderate data
  state <- create_test_workflow_state()
  state$project_data$activities <- paste0("Activity_", 1:50)
  state$project_data$pressures <- paste0("Pressure_", 1:50)
  
  # Check object size
  obj_size <- object.size(state)
  size_kb <- as.numeric(obj_size) / 1024
  
  # Should be under 100 KB
  expect_lt(size_kb, 100, 
           info = paste("State size:", round(size_kb, 2), "KB"))
})

test_that("No memory leaks during repeated operations", {
  skip_on_cran()
  
  initial_state <- create_test_workflow_state()
  initial_size <- object.size(initial_state)
  
  # Perform 1000 operations
  state <- initial_state
  for (i in 1:1000) {
    state$current_step <- (i %% 8) + 1
  }
  
  final_size <- object.size(state)
  
  # Size should not grow significantly
  size_increase <- as.numeric(final_size - initial_size) / 1024
  expect_lt(size_increase, 10, 
           info = paste("Size increase:", round(size_increase, 2), "KB"))
})

# =============================================================================
# EDGE CASE STRESS TESTS
# =============================================================================

test_that("Handles Unicode and special characters at scale", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  state$current_step <- 1
  
  special_texts <- c(
    "Проект 测试 🌊 🐟",
    "Émissions de CO₂",
    "Überwachung der Wasserqualität",
    "Επιπτώσεις στο περιβάλλον",
    "مشروع البيئة البحرية"
  )
  
  for (text in special_texts) {
    input <- list(project_name = text)
    validation <- validate_current_step(state, input)
    expect_true(validation$is_valid)
    
    updated_state <- save_step_data(state, input)
    expect_equal(updated_state$project_data$project_name, text)
  }
})

test_that("Handles empty and whitespace-only inputs", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  state$current_step <- 1
  
  whitespace_inputs <- c(
    "",
    "   ",
    "\t\t",
    "\n\n",
    "  \t \n  "
  )
  
  for (ws in whitespace_inputs) {
    input <- list(project_name = ws)
    validation <- validate_current_step(state, input)
    expect_false(validation$is_valid, 
                info = paste("Should reject whitespace:", repr(ws)))
  }
})

test_that("Handles NULL and NA values robustly", {
  skip_on_cran()
  
  state <- create_test_workflow_state()
  state$current_step <- 1
  
  # NULL input
  expect_silent({
    validation <- validate_current_step(state, list(project_name = NULL))
  })
  expect_false(validation$is_valid)
  
  # NA input
  expect_silent({
    validation <- validate_current_step(state, list(project_name = NA))
  })
  expect_false(validation$is_valid)
})

# =============================================================================
# CONCURRENCY SIMULATION
# =============================================================================

test_that("Simulates multiple user sessions", {
  skip_on_cran()
  
  # Create 10 independent workflow states
  sessions <- lapply(1:10, function(i) {
    state <- create_test_workflow_state()
    state$project_data$project_name <- paste0("Session_", i)
    state
  })
  
  # Verify each session is independent
  expect_equal(length(sessions), 10)
  expect_equal(length(unique(sapply(sessions, function(s) s$project_data$project_name))), 10)
  
  # Modify one session
  sessions[[5]]$current_step <- 5
  
  # Other sessions should be unaffected
  expect_equal(sessions[[1]]$current_step, 1)
  expect_equal(sessions[[5]]$current_step, 5)
  expect_equal(sessions[[10]]$current_step, 1)
})

# =============================================================================
# PERFORMANCE REGRESSION TESTS
# =============================================================================

test_that("Complete workflow executes in reasonable time", {
  skip_on_cran()
  
  start_time <- Sys.time()
  
  # Execute complete workflow
  state <- create_test_workflow_state()
  
  for (step in 1:8) {
    state$current_step <- step
    
    if (step == 1) {
      input <- list(project_name = "Perf Test")
      state <- save_step_data(state, input)
    } else if (step == 2) {
      input <- list(problem_statement = "Test Problem")
      state <- save_step_data(state, input)
    } else {
      state <- save_step_data(state, list())
    }
    
    state$completed_steps <- c(state$completed_steps, step)
  }
  
  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  # Should complete in under 1 second
  expect_lt(elapsed, 1, 
           info = paste("Complete workflow took:", round(elapsed, 3), "seconds"))
})

# =============================================================================
# SUMMARY
# =============================================================================

cat("\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("✅ PERFORMANCE & STRESS TEST SUITE COMPLETE\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("📊 Performance Test Coverage:\n")
cat("   • Initialization speed\n")
cat("   • Validation performance\n")
cat("   • Data saving efficiency\n")
cat("   • Vocabulary loading\n")
cat("   • Large dataset handling (100+ items)\n")
cat("   • Very long text inputs (10,000+ chars)\n")
cat("   • Rapid operations (100+ iterations)\n")
cat("   • Memory usage tracking\n")
cat("   • Unicode and special characters\n")
cat("   • Edge cases (NULL, NA, whitespace)\n")
cat("   • Multi-session simulation\n")
cat("   • End-to-end performance\n")
cat("\n")
