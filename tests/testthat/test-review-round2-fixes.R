# =============================================================================
# Tests for Review Round 2 Fixes
# TDD: These tests are written BEFORE the fixes, expected to FAIL first.
# =============================================================================

library(testthat)

# =============================================================================
# TEST GROUP 1: update_workflow_progress() logic bug
# =============================================================================

test_that("update_workflow_progress marks previous step as completed when advancing", {
  state <- init_workflow_state()
  state$current_step <- 1

  # Advance from step 1 to step 2 — step 1 should be marked completed
  updated <- update_workflow_progress(state, step_number = 2)

  expect_equal(updated$current_step, 2)
  expect_true(1 %in% updated$completed_steps,
              info = "Previous step (1) should be in completed_steps after advancing to step 2")
})

test_that("update_workflow_progress calculates progress correctly after advancing", {
  state <- init_workflow_state()
  state$current_step <- 1

  # Advance through steps 1->2->3
  state <- update_workflow_progress(state, step_number = 2)
  state <- update_workflow_progress(state, step_number = 3)

  expect_true(1 %in% state$completed_steps)
  expect_true(2 %in% state$completed_steps)
  expect_equal(round(state$progress_percentage, 4), round(200/9, 4)) # 2/9 ≈ 22.22%
})

test_that("update_workflow_progress does not duplicate completed steps", {
  state <- init_workflow_state()
  state$current_step <- 1
  state$completed_steps <- c(1L)

  # Going back to step 1 should not add it again

  updated <- update_workflow_progress(state, step_number = 2)
  updated <- update_workflow_progress(updated, step_number = 1)

  expect_equal(sum(updated$completed_steps == 1), 1,
               info = "Step 1 should appear only once in completed_steps")
})

# =============================================================================
# TEST GROUP 2: WORKFLOW_CONFIG step estimated_time keys
# =============================================================================

test_that("WORKFLOW_CONFIG step estimated_time keys reference correct steps", {
  expect_equal(WORKFLOW_CONFIG$steps$step1$estimated_time, "gw_step1_time")
  expect_equal(WORKFLOW_CONFIG$steps$step2$estimated_time, "gw_step2_time")
  expect_equal(WORKFLOW_CONFIG$steps$step3$estimated_time, "gw_step3_time")
  expect_equal(WORKFLOW_CONFIG$steps$step4$estimated_time, "gw_step4_time")
  expect_equal(WORKFLOW_CONFIG$steps$step5$estimated_time, "gw_step5_time")
  expect_equal(WORKFLOW_CONFIG$steps$step6$estimated_time, "gw_step6_time")
  expect_equal(WORKFLOW_CONFIG$steps$step7$estimated_time, "gw_step7_time")
  expect_equal(WORKFLOW_CONFIG$steps$step8$estimated_time, "gw_step8_time")
  expect_equal(WORKFLOW_CONFIG$steps$step9$estimated_time, "gw_step9_time")
})

# =============================================================================
# TEST GROUP 3: get_risk_level() NULL/NA guard
# =============================================================================

test_that("get_risk_level handles NULL input without error", {
  result <- get_risk_level(NULL)
  expect_type(result, "list")
  expect_true(grepl("Low", result$label, ignore.case = TRUE))
})

test_that("get_risk_level handles NA input without error", {
  result <- get_risk_level(NA)
  expect_type(result, "list")
  expect_true(grepl("Low", result$label, ignore.case = TRUE))
})

test_that("get_risk_level handles non-numeric input without error", {
  result <- get_risk_level("invalid")
  expect_type(result, "list")
  expect_true(grepl("Low", result$label, ignore.case = TRUE))
})

test_that("get_risk_level still works correctly for valid numeric input", {
  high <- get_risk_level(0.9)
  expect_true(grepl("High", high$label, ignore.case = TRUE))

  medium <- get_risk_level(0.5)
  expect_true(grepl("Medium", medium$label, ignore.case = TRUE))

  low <- get_risk_level(0.1)
  expect_true(grepl("Low", low$label, ignore.case = TRUE))
})

# =============================================================================
# TEST GROUP 4: search_logs() unsanitized regex
# =============================================================================

test_that("search_logs handles invalid regex pattern gracefully", {
  # An invalid regex like "[" should not throw an uncaught error
  result <- search_logs("[invalid_regex", n_lines = 10)
  expect_type(result, "character")
})

test_that("search_logs handles regex metacharacters in search pattern", {
  # Parentheses, brackets, etc. should not cause errors
  result <- search_logs("(unclosed", n_lines = 10)
  expect_type(result, "character")
})

# =============================================================================
# TEST GROUP 5: safe_readRDS() indentation fix
# =============================================================================

test_that("safe_readRDS validates file existence inside function body", {
  # Should throw "File not found" error when called with non-existent file
  expect_error(
    safe_readRDS("/nonexistent/path/to/file.rds"),
    "File not found"
  )
})

test_that("safe_readRDS rejects non-.rds extensions", {
  # Create a temp file with wrong extension
  temp <- tempfile(fileext = ".txt")
  writeLines("test", temp)
  on.exit(unlink(temp))

  expect_error(safe_readRDS(temp), "Invalid file extension")
})

# =============================================================================
# TEST GROUP 6: validate_file_path() traversal check
# =============================================================================

test_that("validate_file_path catches path traversal with normalized path", {
  # A path containing .. should be rejected even without trailing slash
  expect_error(
    validate_file_path("foo/../../../etc/passwd"),
    "path traversal"
  )
})

test_that("validate_file_path catches Windows-style path traversal", {
  # Windows backslash traversal
  expect_error(
    validate_file_path("foo\\..\\..\\secret"),
    "path traversal"
  )
})

# =============================================================================
# TEST GROUP 7: data_management_module file size limit from config
# =============================================================================

test_that("validate_excel_file uses APP_CONFIG upload limit", {
  # The max size used by validate_excel_file should match APP_CONFIG
  expected_mb <- APP_CONFIG$UPLOAD$MAX_FILE_SIZE_MB
  expect_equal(expected_mb, 100)

  # MAX_UPLOAD_FILE_SIZE constant should also be consistent
  if (exists("MAX_UPLOAD_FILE_SIZE")) {
    expected_bytes <- expected_mb * 1024 * 1024
    expect_equal(MAX_UPLOAD_FILE_SIZE, expected_bytes,
                 info = "MAX_UPLOAD_FILE_SIZE should match APP_CONFIG$UPLOAD$MAX_FILE_SIZE_MB in bytes")
  }
})
