# tests/testthat/test-review-step.R
# Tests for Step 8: Review & Adjust validation

test_that("validate_step8_review requires at least 1 activity", {
  data <- list(
    activities = c("A1", "A2"),
    excluded_activities = c("A1", "A2"),
    pressures = c("P1"),
    excluded_pressures = character(0),
    consequences = c("C1"),
    excluded_consequences = character(0)
  )
  result <- validate_step8_review(data)
  expect_false(result$valid)
  expect_true(grepl("activity", result$message, ignore.case = TRUE))
})

test_that("validate_step8_review requires at least 1 pressure", {
  data <- list(
    activities = c("A1"),
    excluded_activities = character(0),
    pressures = c("P1"),
    excluded_pressures = c("P1"),
    consequences = c("C1"),
    excluded_consequences = character(0)
  )
  result <- validate_step8_review(data)
  expect_false(result$valid)
  expect_true(grepl("pressure", result$message, ignore.case = TRUE))
})

test_that("validate_step8_review requires at least 1 consequence", {
  data <- list(
    activities = c("A1"),
    excluded_activities = character(0),
    pressures = c("P1"),
    excluded_pressures = character(0),
    consequences = c("C1"),
    excluded_consequences = c("C1")
  )
  result <- validate_step8_review(data)
  expect_false(result$valid)
  expect_true(grepl("consequence", result$message, ignore.case = TRUE))
})

test_that("validate_step8_review passes with at least 1 of each required", {
  data <- list(
    activities = c("A1", "A2"),
    excluded_activities = c("A2"),
    pressures = c("P1", "P2"),
    excluded_pressures = c("P2"),
    consequences = c("C1"),
    excluded_consequences = character(0)
  )
  result <- validate_step8_review(data)
  expect_true(result$valid)
})

test_that("validate_step8_review allows empty optional categories", {
  data <- list(
    activities = c("A1"),
    excluded_activities = character(0),
    pressures = c("P1"),
    excluded_pressures = character(0),
    consequences = c("C1"),
    excluded_consequences = character(0),
    preventive_controls = character(0),
    excluded_preventive = character(0),
    protective_controls = character(0),
    excluded_protective = character(0)
  )
  result <- validate_step8_review(data)
  expect_true(result$valid)
})

test_that("validate_step9 always passes", {
  result <- validate_step9(list())
  expect_true(result$valid)
})

test_that("step_durations vector has 9 elements", {
  state <- list(total_steps = 9, completed_steps = integer(0))
  remaining <- estimate_remaining_time(state)
  expect_true(is.numeric(remaining))
  expect_true(remaining > 0)
})

test_that("workflow config has 9 steps", {
  expect_equal(length(WORKFLOW_CONFIG$steps), 9)
  expect_equal(WORKFLOW_CONFIG$steps$step8$id, "review_adjust")
  expect_equal(WORKFLOW_CONFIG$steps$step9$id, "finalize_export")
})

test_that("step 7 config ID is escalation_factors", {
  expect_equal(WORKFLOW_CONFIG$steps$step7$id, "escalation_factors")
})
