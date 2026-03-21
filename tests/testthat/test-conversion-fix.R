# =============================================================================
# Test Suite for convert_to_main_data_format() - TDD for rep_len() rewrite
# Version: 1.0.0
# Description: Tests verifying NEW behavior after replacing nested for-loops
#              with rep_len() vector recycling. These tests FAIL against the
#              current code (max 3 activities, max 2 of everything else).
#              That is expected and intentional (TDD red phase).
#
# Dependencies sourced automatically by tests/testthat/helper-setup.R:
#   - guided_workflow_validation.R  (defines %||%)
#   - guided_workflow_conversion.R  (defines convert_to_main_data_format())
# =============================================================================

library(testthat)

# =============================================================================
# Helper: build a full project_data list for tests
# =============================================================================

make_project_data <- function(
    activities          = c("Activity A", "Activity B", "Activity C"),
    pressures           = c("Pressure 1", "Pressure 2"),
    preventive_controls = c("Control P1", "Control P2"),
    consequences        = c("Consequence X", "Consequence Y"),
    protective_controls = c("Control R1"),
    escalation_factors  = c("Budget cuts", "Staff turnover"),
    problem_statement   = "Test Central Problem",
    project_name        = "Test Project"
) {
  list(
    problem_statement   = problem_statement,
    project_name        = project_name,
    activities          = activities,
    pressures           = pressures,
    preventive_controls = preventive_controls,
    consequences        = consequences,
    protective_controls = protective_controls,
    escalation_factors  = escalation_factors
  )
}

# =============================================================================
# TEST 1: All activities are included (no truncation at 3)
# =============================================================================

test_that("convert_to_main_data_format includes ALL activities (no truncation)", {
  eight_activities <- paste("Activity", LETTERS[1:8])

  project_data <- make_project_data(
    activities          = eight_activities,
    pressures           = c("Pressure 1", "Pressure 2"),
    preventive_controls = c("Control P1"),
    consequences        = c("Consequence X"),
    protective_controls = c("Control R1")
  )

  result <- convert_to_main_data_format(project_data)

  # Extract non-empty activity values
  found_activities <- unique(result$Activity[!is.na(result$Activity) & result$Activity != ""])

  # All 8 should appear - old code truncated to min(3, length(activities))
  expect_equal(
    length(found_activities),
    8,
    info = paste("Expected 8 activities but found:", length(found_activities),
                 "- old code truncates at min(3, length(activities))")
  )
})

# =============================================================================
# TEST 2: All pressures are included (no truncation at 2)
# =============================================================================

test_that("convert_to_main_data_format includes ALL pressures (no truncation)", {
  five_pressures <- paste("Pressure", 1:5)

  project_data <- make_project_data(
    activities          = c("Activity A"),
    pressures           = five_pressures,
    preventive_controls = c("Control P1"),
    consequences        = c("Consequence X"),
    protective_controls = c("Control R1")
  )

  result <- convert_to_main_data_format(project_data)

  found_pressures <- unique(result$Pressure[!is.na(result$Pressure) & result$Pressure != ""])

  # All 5 should appear - old code truncated to min(2, length(pressures))
  expect_equal(
    length(found_pressures),
    5,
    info = paste("Expected 5 pressures but found:", length(found_pressures),
                 "- old code truncates at min(2, length(pressures))")
  )
})

# =============================================================================
# TEST 3: Row count equals the length of the longest input vector
# =============================================================================

test_that("convert_to_main_data_format row count equals max vector length", {
  # Longest vector is activities (10). All others are shorter and must be recycled.
  project_data <- make_project_data(
    activities          = paste("Activity", 1:10),
    pressures           = paste("Pressure", 1:3),
    preventive_controls = paste("Control P", 1:2),
    consequences        = paste("Consequence", 1:5),
    protective_controls = paste("Control R", 1:1),
    escalation_factors  = paste("Escalation", 1:2)
  )

  result <- convert_to_main_data_format(project_data)

  expect_equal(
    nrow(result),
    10,
    info = paste("Expected 10 rows (max vector length) but got:", nrow(result),
                 "- new code uses rep_len() so nrow == max(lengths(vectors))")
  )
})

# =============================================================================
# TEST 4: Escalation_Factor column exists and contains user-supplied values
# =============================================================================

test_that("convert_to_main_data_format has Escalation_Factor column", {
  user_escalations <- c("Budget constraints", "Staff turnover", "Equipment failure")

  project_data <- make_project_data(
    escalation_factors = user_escalations
  )

  result <- convert_to_main_data_format(project_data)

  # Column must exist
  expect_true(
    "Escalation_Factor" %in% names(result),
    info = "Escalation_Factor column is missing from the output data frame"
  )

  # At least one of the user-supplied values should appear
  found_factors <- unique(result$Escalation_Factor[!is.na(result$Escalation_Factor) &
                                                     result$Escalation_Factor != ""])
  overlap <- intersect(found_factors, user_escalations)
  expect_gt(
    length(overlap),
    0,
    label = "user-supplied escalation factors appear in output"
  )
})

# =============================================================================
# TEST 5: Empty escalation_factors produces all-NA column (no dummy text)
# =============================================================================

test_that("convert_to_main_data_format handles empty escalation factors with NA", {
  project_data <- make_project_data(
    escalation_factors = character(0)   # explicitly empty
  )

  result <- convert_to_main_data_format(project_data)

  expect_true(
    "Escalation_Factor" %in% names(result),
    info = "Escalation_Factor column must exist even when input is empty"
  )

  # All values should be NA when no escalation factors are supplied.
  # Old code fills the column with 6 hardcoded dummy strings instead.
  non_na_values <- result$Escalation_Factor[!is.na(result$Escalation_Factor)]
  expect_equal(
    length(non_na_values),
    0,
    info = paste("Expected all-NA Escalation_Factor when none supplied,",
                 "but found non-NA values:",
                 paste(unique(non_na_values), collapse = ", "))
  )
})

# =============================================================================
# TEST 6: Empty optional columns produce NA; non-empty columns stay non-NA
# =============================================================================

test_that("convert_to_main_data_format handles empty optional columns with NA", {
  project_data <- make_project_data(
    activities          = c("Activity A", "Activity B", "Activity C"),
    pressures           = c("Pressure 1", "Pressure 2", "Pressure 3"),
    preventive_controls = character(0),   # empty
    consequences        = c("Consequence X", "Consequence Y", "Consequence Z"),
    protective_controls = character(0)    # empty
  )

  result <- convert_to_main_data_format(project_data)

  # Non-empty inputs should not produce all-NA columns
  non_na_activities <- result$Activity[!is.na(result$Activity) & result$Activity != ""]
  expect_gt(
    length(non_na_activities),
    0,
    label = "Activity column has non-NA values when activities are provided"
  )

  # Empty inputs should produce all-NA columns
  non_na_preventive <- result$Preventive_Control[!is.na(result$Preventive_Control) &
                                                   result$Preventive_Control != ""]
  expect_equal(
    length(non_na_preventive),
    0,
    info = "Preventive_Control should be all-NA when no preventive_controls provided"
  )

  non_na_protective <- result$Protective_Mitigation[!is.na(result$Protective_Mitigation) &
                                                      result$Protective_Mitigation != ""]
  expect_equal(
    length(non_na_protective),
    0,
    info = "Protective_Mitigation should be all-NA when no protective_controls provided"
  )
})

# =============================================================================
# TEST 7: Function is deterministic (no random sampling)
# =============================================================================

test_that("convert_to_main_data_format is deterministic (no random sampling)", {
  project_data <- make_project_data(
    activities          = paste("Activity", 1:4),
    pressures           = paste("Pressure", 1:4),
    preventive_controls = paste("Control P", 1:4),
    consequences        = paste("Consequence", 1:4),
    protective_controls = paste("Control R", 1:4),
    escalation_factors  = paste("Escalation", 1:4)
  )

  result1 <- convert_to_main_data_format(project_data)
  result2 <- convert_to_main_data_format(project_data)

  expect_identical(
    result1$Likelihood,
    result2$Likelihood,
    info = "Likelihood values differ between two calls - old code uses sample(1:5, 1)"
  )

  expect_identical(
    result1$Severity,
    result2$Severity,
    info = "Severity values differ between two calls - old code uses sample(1:5, 1)"
  )

  expect_identical(
    result1$Escalation_Factor,
    result2$Escalation_Factor,
    info = "Escalation_Factor values differ between two calls - old code uses sample(escalation_factors, 1)"
  )
})

# =============================================================================
# TEST 8: Risk_Level exists and is computed correctly (3*3=9 -> "Medium")
# =============================================================================

test_that("convert_to_main_data_format has Risk_Level column", {
  project_data <- make_project_data(
    activities          = c("Activity A"),
    pressures           = c("Pressure 1"),
    preventive_controls = c("Control P1"),
    consequences        = c("Consequence X"),
    protective_controls = c("Control R1"),
    escalation_factors  = c("Budget cuts")
  )

  result <- convert_to_main_data_format(project_data)

  expect_true(
    "Risk_Level" %in% names(result),
    info = "Risk_Level column is missing from the output data frame"
  )

  # All Risk_Level values must be one of the valid categories
  valid_levels <- c("Low", "Medium", "High")
  non_na_risk <- result$Risk_Level[!is.na(result$Risk_Level)]
  expect_true(
    all(non_na_risk %in% valid_levels),
    info = paste("Unexpected Risk_Level values found:",
                 paste(setdiff(unique(non_na_risk), valid_levels), collapse = ", "))
  )

  # When Likelihood=3 and Severity=3, product=9 which is in (6, 15] -> "Medium"
  rows_l3_s3 <- result[!is.na(result$Likelihood) & !is.na(result$Severity) &
                          result$Likelihood == 3 & result$Severity == 3, ]

  if (nrow(rows_l3_s3) > 0) {
    expect_true(
      all(rows_l3_s3$Risk_Level == "Medium"),
      info = "Rows with Likelihood=3, Severity=3 should have Risk_Level='Medium' (3*3=9, <=15)"
    )
  }
})

# =============================================================================
# TEST 9: Central_Problem is constant across all rows
# =============================================================================

test_that("convert_to_main_data_format Central_Problem is constant across all rows", {
  my_problem <- "Marine Ecosystem Degradation from Pollution"

  project_data <- make_project_data(
    activities          = paste("Activity", 1:6),
    pressures           = paste("Pressure", 1:6),
    preventive_controls = paste("Control P", 1:6),
    consequences        = paste("Consequence", 1:6),
    protective_controls = paste("Control R", 1:6),
    escalation_factors  = paste("Escalation", 1:6),
    problem_statement   = my_problem
  )

  result <- convert_to_main_data_format(project_data)

  expect_true(
    "Central_Problem" %in% names(result),
    info = "Central_Problem column is missing from the output data frame"
  )

  unique_problems <- unique(result$Central_Problem)

  expect_equal(
    length(unique_problems),
    1,
    info = paste("Expected exactly 1 unique Central_Problem value but found:",
                 length(unique_problems))
  )

  expect_equal(
    unique_problems[[1]],
    my_problem,
    info = paste("Central_Problem should be '", my_problem,
                 "' but got: '", unique_problems[[1]], "'")
  )
})
