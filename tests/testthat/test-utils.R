# Test suite for utility functions (utils.r)
# Tests data generation, validation, and risk calculations

library(testthat)

# Test data generation functions
test_that("generateEnvironmentalDataFixed produces valid data frame", {
  data <- generateEnvironmentalDataFixed()
  
  expect_s3_class(data, "data.frame")
  expect_true(nrow(data) > 0)
  
  # Check required columns exist
  required_cols <- c("Activity", "Pressure", "Preventive_Control", "Protective_Mitigation", 
                     "Problem", "Consequence", "Threat_Likelihood", "Consequence_Severity")
  expect_true(all(required_cols %in% names(data)))
  
  # Check data types
  expect_type(data$Activity, "character")
  expect_type(data$Pressure, "character")
  expect_type(data$Problem, "character")
  expect_type(data$Consequence, "character")
})

# Test validation functions
test_that("validateDataColumns works correctly", {
  # Create valid test data
  valid_data <- data.frame(
    Activity = "Test Activity",
    Pressure = "Test Pressure",
    Problem = "Test Problem",
    Consequence = "Test Consequence",
    stringsAsFactors = FALSE
  )
  
  expect_true(validateDataColumns(valid_data))
  
  # Test with missing columns
  invalid_data <- data.frame(Activity = "Test Activity")
  expect_false(validateDataColumns(invalid_data))
})

test_that("addDefaultColumns adds required columns", {
  test_data <- data.frame(
    Activity = "Test Activity",
    Pressure = "Test Pressure",
    stringsAsFactors = FALSE
  )
  
  result <- addDefaultColumns(test_data)
  
  expect_true("Threat_Likelihood" %in% names(result))
  expect_true("Consequence_Severity" %in% names(result))
  expect_true("Risk_Level" %in% names(result))
  expect_true("Risk_Rating" %in% names(result))
})

# Test risk calculation functions
test_that("calculateRiskLevel works correctly", {
  expect_equal(calculateRiskLevel(1, 1), 1)  # Low + Low = Low
  expect_equal(calculateRiskLevel(5, 5), 25) # High + High = Very High
  expect_equal(calculateRiskLevel(3, 3), 9)  # Medium + Medium = High
  
  # Test edge cases
  expect_equal(calculateRiskLevel(1, 5), 5)  # Low likelihood, high severity
  expect_equal(calculateRiskLevel(5, 1), 5)  # High likelihood, low severity
})

test_that("getRiskColor returns appropriate colors", {
  expect_type(getRiskColor(1), "character")
  expect_type(getRiskColor(25), "character")
  
  # Test with risk levels disabled
  color_no_levels <- getRiskColor(15, show_risk_levels = FALSE)
  expect_type(color_no_levels, "character")
})

# Test validation functions
test_that("validateNumericInput validates correctly", {
  expect_equal(validateNumericInput(3), 3)
  expect_equal(validateNumericInput(0), 1)  # Below min
  expect_equal(validateNumericInput(10), 5) # Above max
  expect_equal(validateNumericInput("invalid"), 1) # Invalid input
})

# Test default row creation
test_that("createDefaultRowFixed creates proper structure", {
  default_row <- createDefaultRowFixed("Test Problem")
  
  expect_s3_class(default_row, "data.frame")
  expect_equal(nrow(default_row), 1)
  expect_equal(default_row$Problem, "Test Problem")
  expect_true(all(c("Activity", "Pressure", "Preventive_Control", "Protective_Mitigation", 
                    "Consequence", "Threat_Likelihood", "Consequence_Severity") %in% names(default_row)))
})

# Test data summary function
test_that("getDataSummaryFixed returns valid summary", {
  test_data <- generateEnvironmentalDataFixed()
  summary_data <- getDataSummaryFixed(test_data)
  
  expect_s3_class(summary_data, "data.frame")
  expect_true("Problem" %in% names(summary_data))
  expect_true("Total_Entries" %in% names(summary_data))
  expect_true("Avg_Risk_Rating" %in% names(summary_data))
})

# Test cache functions
test_that("clear_cache works without error", {
  expect_no_error(clear_cache())
})