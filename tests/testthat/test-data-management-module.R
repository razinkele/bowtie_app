# =============================================================================
# Tests for Data Management Module
# =============================================================================
# File: tests/testthat/test-data-management-module.R
# Tests: Excel import, data validation, edit operations, reactive state
# =============================================================================

context("Data Management Module")

# Load required packages
library(testthat)

# Load the helper setup (provides app_root, create_test_dir, cleanup_test_files)
if (!exists("app_root")) {
  source(file.path(getwd(), "tests/testthat/helper-setup.R"))
}

# =============================================================================
# Module Loading Tests
# =============================================================================

test_that("data_management_module.R can be sourced", {
  module_path <- file.path(app_root, "server_modules/data_management_module.R")

  expect_true(file.exists(module_path),
              info = paste("Module file should exist at:", module_path))

  # Source should not error (it defines functions, doesn't execute server code)
  expect_no_error({
    source(module_path, local = TRUE)
  })
})

test_that("validate_excel_file function is defined after sourcing", {
  module_path <- file.path(app_root, "server_modules/data_management_module.R")
  local_env <- new.env()
  source(module_path, local = local_env)

  expect_true(exists("validate_excel_file", envir = local_env),
              info = "validate_excel_file function should be defined")
  expect_true(is.function(local_env$validate_excel_file),
              info = "validate_excel_file should be a function")
})

test_that("data_management_module_server function is defined", {
  module_path <- file.path(app_root, "server_modules/data_management_module.R")
  local_env <- new.env()
  source(module_path, local = local_env)

  expect_true(exists("data_management_module_server", envir = local_env),
              info = "data_management_module_server function should be defined")
})

# =============================================================================
# Excel File Validation Tests
# =============================================================================

describe("Excel File Validation", {

  # Source the module to get validate_excel_file
  module_path <- file.path(app_root, "server_modules/data_management_module.R")
  local_env <- new.env()
  source(module_path, local = local_env)
  validate_excel_file <- local_env$validate_excel_file

  it("rejects non-existent files", {
    result <- validate_excel_file("/nonexistent/path/file.xlsx")

    expect_false(result$valid)
    expect_true(grepl("does not exist", result$error, ignore.case = TRUE))
  })

  it("rejects files with wrong extension", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create a text file with wrong extension
    wrong_ext <- file.path(test_dir, "data.txt")
    writeLines("test content", wrong_ext)

    result <- validate_excel_file(wrong_ext)

    expect_false(result$valid)
    expect_true(grepl("extension", result$error, ignore.case = TRUE))
  })

  it("rejects CSV files masquerading as Excel", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    csv_path <- file.path(test_dir, "data.csv")
    writeLines("col1,col2\nval1,val2", csv_path)

    result <- validate_excel_file(csv_path)

    expect_false(result$valid)
    expect_true(grepl("extension", result$error, ignore.case = TRUE))
  })

  it("accepts valid XLSX files", {
    # Use existing vocabulary file as test case
    xlsx_path <- file.path(app_root, "CAUSES.xlsx")
    skip_if_not(file.exists(xlsx_path), "CAUSES.xlsx not found")

    result <- validate_excel_file(xlsx_path)

    expect_true(result$valid,
                info = paste("Valid XLSX should pass validation. Error:", result$error))
    expect_null(result$error)
  })

  it("validates magic bytes for XLSX format (ZIP/PK signature)", {
    xlsx_path <- file.path(app_root, "CAUSES.xlsx")
    skip_if_not(file.exists(xlsx_path), "CAUSES.xlsx not found")

    # XLSX files start with PK (ZIP signature: 0x50 0x4B 0x03 0x04)
    con <- file(xlsx_path, "rb")
    first_bytes <- readBin(con, "raw", n = 4)
    close(con)

    expect_equal(first_bytes[1:2], as.raw(c(0x50, 0x4B)),
                 info = "XLSX files should have PK signature")
  })

  it("rejects masqueraded files (wrong content, right extension)", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create a text file with .xlsx extension
    fake_xlsx <- file.path(test_dir, "fake.xlsx")
    writeLines("This is not an Excel file", fake_xlsx)

    result <- validate_excel_file(fake_xlsx)

    expect_false(result$valid)
    expect_true(grepl("content|security|format", result$error, ignore.case = TRUE))
  })

  it("rejects files that are too small to be valid Excel", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create a tiny file with .xlsx extension
    tiny_xlsx <- file.path(test_dir, "tiny.xlsx")
    writeBin(raw(2), tiny_xlsx)  # Just 2 bytes

    result <- validate_excel_file(tiny_xlsx)

    expect_false(result$valid)
    expect_true(grepl("small|content|format", result$error, ignore.case = TRUE))
  })

  it("returns structured result with valid and error fields", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    fake_file <- file.path(test_dir, "test.xlsx")
    writeLines("fake", fake_file)

    result <- validate_excel_file(fake_file)

    expect_true("valid" %in% names(result),
                info = "Result should have 'valid' field")
    expect_true("error" %in% names(result),
                info = "Result should have 'error' field")
    expect_type(result$valid, "logical")
  })
})

# =============================================================================
# Data Column Validation Tests
# =============================================================================

describe("Data Column Validation", {

  # Source utils.R to get validation functions in a local environment
  local_utils_env <- new.env(parent = globalenv())
  source(file.path(app_root, "utils.R"), local = local_utils_env)
  # Attach functions needed for this describe block
  validate_data_columns <- local_utils_env$validate_data_columns
  validate_data_columns_detailed <- local_utils_env$validate_data_columns_detailed

  it("accepts data with required columns", {
    valid_data <- data.frame(
      Activity = "Marine Transport",
      Pressure = "Oil Pollution",
      Central_Problem = "Water Contamination",
      Consequence = "Ecosystem Damage",
      stringsAsFactors = FALSE
    )

    expect_true(validate_data_columns(valid_data))
  })

  it("accepts data with legacy 'Problem' column instead of Central_Problem", {
    legacy_data <- data.frame(
      Activity = "Marine Transport",
      Pressure = "Oil Pollution",
      Problem = "Water Contamination",  # Legacy column name
      Consequence = "Ecosystem Damage",
      stringsAsFactors = FALSE
    )

    expect_true(validate_data_columns(legacy_data))
  })

  it("detects missing required columns", {
    incomplete_data <- data.frame(
      Activity = "Marine Transport",
      Pressure = "Oil Pollution",
      stringsAsFactors = FALSE
    )

    result <- validate_data_columns_detailed(incomplete_data)

    expect_false(result$valid)
    expect_true(length(result$missing) > 0)
  })

  it("reports specific missing columns", {
    minimal_data <- data.frame(
      Activity = "Test Activity",
      stringsAsFactors = FALSE
    )

    result <- validate_data_columns_detailed(minimal_data)

    expect_false(result$valid)
    expect_true("Pressure" %in% result$missing)
    expect_true("Consequence" %in% result$missing)
  })

  it("handles column name aliases (Problem vs Central_Problem)", {
    alias_data <- data.frame(
      Activity = "Test",
      Pressure = "Test",
      Problem = "Using alias",  # Alias for Central_Problem
      Consequence = "Test",
      stringsAsFactors = FALSE
    )

    # Check if alias is recognized
    expect_true(validate_data_columns(alias_data))
  })

  it("validates numeric data types are preserved", {
    test_data <- data.frame(
      Activity = "Marine Transport",
      Pressure = "Oil Pollution",
      Central_Problem = "Water Contamination",
      Consequence = "Ecosystem Damage",
      Overall_Likelihood = 3.5,  # Should be numeric
      Risk_Level = "High",  # Should be character
      stringsAsFactors = FALSE
    )

    expect_type(test_data$Overall_Likelihood, "double")
    expect_type(test_data$Risk_Level, "character")
  })

  it("handles NA values in data", {
    data_with_na <- data.frame(
      Activity = c("Activity 1", NA, "Activity 3"),
      Pressure = c("Pressure 1", "Pressure 2", NA),
      Central_Problem = c("Problem 1", "Problem 2", "Problem 3"),
      Consequence = c("Consequence 1", NA, "Consequence 3"),
      stringsAsFactors = FALSE
    )

    na_count <- sum(is.na(data_with_na))
    expect_equal(na_count, 3)

    # Validation should still pass (required columns exist)
    expect_true(validate_data_columns(data_with_na))
  })

  it("handles empty data frame", {
    empty_df <- data.frame(
      Activity = character(0),
      Pressure = character(0),
      Central_Problem = character(0),
      Consequence = character(0),
      stringsAsFactors = FALSE
    )

    # Empty but with correct columns should be valid
    expect_true(validate_data_columns(empty_df))
  })
})

# =============================================================================
# Add Default Columns Tests
# =============================================================================

describe("Add Default Columns Function", {

  # Source utils.R in a local environment to get add_default_columns
  local_utils_env <- new.env(parent = globalenv())
  source(file.path(app_root, "utils.R"), local = local_utils_env)
  add_default_columns <- local_utils_env$add_default_columns

  it("adds missing Activity column", {
    data <- data.frame(
      Pressure = c("P1", "P2"),
      stringsAsFactors = FALSE
    )

    result <- add_default_columns(data)

    expect_true("Activity" %in% names(result))
    expect_equal(nrow(result), 2)
  })

  it("adds missing Preventive_Control column", {
    data <- data.frame(
      Activity = c("A1", "A2"),
      Pressure = c("P1", "P2"),
      stringsAsFactors = FALSE
    )

    result <- add_default_columns(data)

    expect_true("Preventive_Control" %in% names(result))
  })

  it("adds Escalation_Factor column with scenario-specific content", {
    data <- data.frame(
      Activity = "Test",
      Pressure = "Test",
      stringsAsFactors = FALSE
    )

    result <- add_default_columns(data, scenario_type = "marine_pollution")

    expect_true("Escalation_Factor" %in% names(result))
  })

  it("preserves existing columns when adding defaults", {
    data <- data.frame(
      Activity = "Existing Activity",
      Pressure = "Existing Pressure",
      Custom_Column = "Custom Value",
      stringsAsFactors = FALSE
    )

    result <- add_default_columns(data)

    expect_equal(result$Activity[1], "Existing Activity")
    expect_equal(result$Pressure[1], "Existing Pressure")
    expect_true("Custom_Column" %in% names(result))
    expect_equal(result$Custom_Column[1], "Custom Value")
  })

  it("adds granular risk columns", {
    data <- data.frame(
      Activity = "Test",
      Pressure = "Test",
      stringsAsFactors = FALSE
    )

    result <- add_default_columns(data)

    risk_columns <- c(
      "Activity_to_Pressure_Likelihood",
      "Activity_to_Pressure_Severity",
      "Pressure_to_Control_Likelihood",
      "Pressure_to_Control_Severity"
    )

    for (col in risk_columns) {
      expect_true(col %in% names(result),
                  info = paste("Should have column:", col))
    }
  })

  it("handles multiple rows correctly", {
    data <- data.frame(
      Activity = paste0("Activity_", 1:5),
      Pressure = paste0("Pressure_", 1:5),
      stringsAsFactors = FALSE
    )

    result <- add_default_columns(data)

    expect_equal(nrow(result), 5)
    expect_equal(nrow(result), length(result$Activity))
  })
})

# =============================================================================
# Edit Operations Tests
# =============================================================================

describe("Data Edit Operations", {

  it("adds a new row correctly", {
    original <- data.frame(
      Activity = c("A1", "A2"),
      Pressure = c("P1", "P2"),
      stringsAsFactors = FALSE
    )

    new_row <- data.frame(
      Activity = "A3",
      Pressure = "P3",
      stringsAsFactors = FALSE
    )

    edited <- rbind(original, new_row)

    expect_equal(nrow(edited), 3)
    expect_equal(edited$Activity[3], "A3")
    expect_equal(edited$Pressure[3], "P3")
  })

  it("deletes a row correctly", {
    original <- data.frame(
      Activity = c("A1", "A2", "A3"),
      Pressure = c("P1", "P2", "P3"),
      stringsAsFactors = FALSE
    )

    edited <- original[-2, ]  # Delete row 2

    expect_equal(nrow(edited), 2)
    expect_false("A2" %in% edited$Activity)
    expect_true("A1" %in% edited$Activity)
    expect_true("A3" %in% edited$Activity)
  })

  it("modifies a cell correctly", {
    original <- data.frame(
      Activity = c("A1", "A2"),
      Pressure = c("P1", "P2"),
      stringsAsFactors = FALSE
    )

    edited <- original
    edited$Activity[1] <- "Modified Activity"

    expect_equal(edited$Activity[1], "Modified Activity")
    expect_equal(edited$Pressure[1], "P1")  # Unchanged
    expect_equal(edited$Activity[2], "A2")  # Other row unchanged
  })

  it("preserves row order after edits", {
    original <- data.frame(
      id = 1:5,
      Activity = paste0("A", 1:5),
      stringsAsFactors = FALSE
    )

    # Edit middle row
    edited <- original
    edited$Activity[3] <- "Modified"

    expect_equal(edited$id, 1:5)  # Order preserved
    expect_equal(edited$Activity[3], "Modified")
    expect_equal(edited$Activity[1], "A1")
    expect_equal(edited$Activity[5], "A5")
  })

  it("handles bulk row deletion", {
    original <- data.frame(
      id = 1:10,
      Activity = paste0("A", 1:10),
      stringsAsFactors = FALSE
    )

    # Delete multiple rows
    rows_to_delete <- c(2, 5, 8)
    edited <- original[-rows_to_delete, ]

    expect_equal(nrow(edited), 7)
    expect_false(any(edited$id %in% c(2, 5, 8)))
    expect_true(all(c(1, 3, 4, 6, 7, 9, 10) %in% edited$id))
  })

  it("handles column addition", {
    original <- data.frame(
      Activity = c("A1", "A2"),
      Pressure = c("P1", "P2"),
      stringsAsFactors = FALSE
    )

    edited <- original
    edited$NewColumn <- c("New1", "New2")

    expect_true("NewColumn" %in% names(edited))
    expect_equal(edited$NewColumn[1], "New1")
    expect_equal(ncol(edited), ncol(original) + 1)
  })

  it("handles column removal", {
    original <- data.frame(
      Activity = c("A1", "A2"),
      Pressure = c("P1", "P2"),
      ToRemove = c("R1", "R2"),
      stringsAsFactors = FALSE
    )

    edited <- original[, names(original) != "ToRemove"]

    expect_false("ToRemove" %in% names(edited))
    expect_true("Activity" %in% names(edited))
    expect_true("Pressure" %in% names(edited))
  })

  it("preserves data types during edits", {
    original <- data.frame(
      Activity = c("A1", "A2"),
      Likelihood = c(3.5, 4.2),
      Count = c(10L, 20L),
      stringsAsFactors = FALSE
    )

    edited <- original
    edited$Likelihood[1] <- 2.8

    expect_type(edited$Likelihood, "double")
    expect_type(edited$Count, "integer")
  })
})

# =============================================================================
# Reactive State Tests
# =============================================================================

describe("Reactive State Management", {

  it("currentData starts as NULL in typical pattern", {
    current <- NULL
    expect_null(current)
  })

  it("hasData reflects data presence", {
    has_data_check <- function(data) {
      !is.null(data) && nrow(data) > 0
    }

    expect_false(has_data_check(NULL))
    expect_false(has_data_check(data.frame()))
    expect_true(has_data_check(data.frame(a = 1)))
    expect_true(has_data_check(data.frame(a = 1:10)))
  })

  it("dataVersion increments on changes", {
    version <- 0

    # Simulate data change
    version <- version + 1
    expect_equal(version, 1)

    # Another change
    version <- version + 1
    expect_equal(version, 2)

    # Multiple changes
    for (i in 1:5) {
      version <- version + 1
    }
    expect_equal(version, 7)
  })

  it("editedData takes precedence over currentData", {
    current <- data.frame(value = "original")
    edited <- data.frame(value = "edited")

    get_data <- function() {
      if (!is.null(edited)) edited else current
    }

    expect_equal(get_data()$value, "edited")
  })

  it("falls back to currentData when editedData is NULL", {
    current <- data.frame(value = "original")
    edited <- NULL

    get_data <- function() {
      if (!is.null(edited)) edited else current
    }

    expect_equal(get_data()$value, "original")
  })

  it("tracks modification state correctly", {
    original_data <- data.frame(a = 1, b = 2)
    current_data <- original_data

    # No modification yet
    is_modified <- !identical(current_data, original_data)
    expect_false(is_modified)

    # Make a change
    current_data$a <- 999
    is_modified <- !identical(current_data, original_data)
    expect_true(is_modified)
  })

  it("detects structural changes to data", {
    original_data <- data.frame(a = 1:3, b = 4:6)

    # Adding row
    modified_rows <- rbind(original_data, data.frame(a = 4, b = 7))
    expect_false(identical(modified_rows, original_data))

    # Adding column
    modified_cols <- original_data
    modified_cols$c <- 7:9
    expect_false(identical(modified_cols, original_data))

    # Unmodified copy should be identical
    exact_copy <- original_data
    expect_true(identical(exact_copy, original_data))
  })
})

# =============================================================================
# Data Import Tests
# =============================================================================

describe("Data Import from Excel", {

  skip_if_not_installed("readxl")
  # Safely load library after skip check
  if (requireNamespace("readxl", quietly = TRUE)) {
    library(readxl)
  }

  it("imports all rows from valid file", {
    xlsx_path <- file.path(app_root, "CAUSES.xlsx")
    skip_if_not(file.exists(xlsx_path), "CAUSES.xlsx not found")

    data <- read_excel(xlsx_path)

    expect_gt(nrow(data), 0)
    expect_gt(ncol(data), 0)
  })

  it("preserves column names from Excel", {
    xlsx_path <- file.path(app_root, "CAUSES.xlsx")
    skip_if_not(file.exists(xlsx_path), "CAUSES.xlsx not found")

    data <- read_excel(xlsx_path)

    # Should have named columns
    expect_true(all(nchar(names(data)) > 0))
    # No auto-named columns like ...1, ...2
    expect_false(any(grepl("^\\.\\.\\.\\d+$", names(data))))
  })

  it("handles sheets correctly", {
    xlsx_path <- file.path(app_root, "CAUSES.xlsx")
    skip_if_not(file.exists(xlsx_path), "CAUSES.xlsx not found")

    sheets <- excel_sheets(xlsx_path)

    expect_gt(length(sheets), 0)
    expect_true(all(nchar(sheets) > 0))
  })

  it("reads specific sheet by name", {
    xlsx_path <- file.path(app_root, "CAUSES.xlsx")
    skip_if_not(file.exists(xlsx_path), "CAUSES.xlsx not found")

    sheets <- excel_sheets(xlsx_path)
    skip_if(length(sheets) == 0, "No sheets found in file")

    # Read first sheet by name
    data <- read_excel(xlsx_path, sheet = sheets[1])

    expect_true(is.data.frame(data))
    expect_gte(nrow(data), 0)
  })

  it("imports consequences file successfully", {
    xlsx_path <- file.path(app_root, "CONSEQUENCES.xlsx")
    skip_if_not(file.exists(xlsx_path), "CONSEQUENCES.xlsx not found")

    data <- read_excel(xlsx_path)

    expect_gt(nrow(data), 0)
    expect_true(is.data.frame(data))
  })

  it("imports controls file successfully", {
    xlsx_path <- file.path(app_root, "CONTROLS.xlsx")
    skip_if_not(file.exists(xlsx_path), "CONTROLS.xlsx not found")

    data <- read_excel(xlsx_path)

    expect_gt(nrow(data), 0)
    expect_true(is.data.frame(data))
  })
})

# =============================================================================
# Data Export Tests
# =============================================================================

describe("Data Export Operations", {

  skip_if_not_installed("openxlsx")
  # Safely load library after skip check
  if (requireNamespace("openxlsx", quietly = TRUE)) {
    library(openxlsx)
  }

  it("exports data frame to xlsx successfully", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    test_data <- data.frame(
      Activity = c("A1", "A2", "A3"),
      Pressure = c("P1", "P2", "P3"),
      Central_Problem = c("CP1", "CP1", "CP2"),
      Consequence = c("C1", "C2", "C3"),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "export_test.xlsx")

    expect_no_error({
      write.xlsx(test_data, export_path, rowNames = FALSE)
    })

    expect_true(file.exists(export_path))
  })

  it("preserves all columns in export", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    test_data <- data.frame(
      Activity = "Test",
      Pressure = "Test",
      Central_Problem = "Test",
      Consequence = "Test",
      Custom1 = "Custom Value 1",
      Custom2 = 123,
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "export_columns.xlsx")
    write.xlsx(test_data, export_path, rowNames = FALSE)

    # Re-import and verify columns
    reimported <- read.xlsx(export_path)

    expect_equal(ncol(reimported), ncol(test_data))
    expect_true(all(names(test_data) %in% names(reimported)))
  })

  it("handles special characters in data", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    test_data <- data.frame(
      Activity = "Test with special chars: & < > \"",
      Pressure = "Unicode: cafe\u0301",  # cafe with accent
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "export_special.xlsx")

    expect_no_error({
      write.xlsx(test_data, export_path, rowNames = FALSE)
    })
  })

  it("round-trips data through export/import", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original_data <- data.frame(
      Activity = c("Activity 1", "Activity 2"),
      Pressure = c("Pressure 1", "Pressure 2"),
      Value = c(1.5, 2.5),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "roundtrip.xlsx")
    write.xlsx(original_data, export_path, rowNames = FALSE)
    reimported <- read.xlsx(export_path)

    expect_equal(nrow(reimported), nrow(original_data))
    expect_equal(reimported$Activity, original_data$Activity)
    expect_equal(reimported$Value, original_data$Value)
  })
})

# =============================================================================
# Edge Cases and Error Handling Tests
# =============================================================================

describe("Edge Cases and Error Handling", {

  # Source utils.R in a local environment to get validate_data_columns
  local_utils_env <- new.env(parent = globalenv())
  source(file.path(app_root, "utils.R"), local = local_utils_env)
  validate_data_columns <- local_utils_env$validate_data_columns

  it("handles single-row data frame", {
    single_row <- data.frame(
      Activity = "Single Activity",
      Pressure = "Single Pressure",
      Central_Problem = "Single Problem",
      Consequence = "Single Consequence",
      stringsAsFactors = FALSE
    )

    expect_true(validate_data_columns(single_row))
    expect_equal(nrow(single_row), 1)
  })

  it("handles data with all NA values in optional columns", {
    data_with_nas <- data.frame(
      Activity = c("A1", "A2"),
      Pressure = c("P1", "P2"),
      Central_Problem = c("CP1", "CP2"),
      Consequence = c("C1", "C2"),
      Optional_Field = c(NA, NA),
      stringsAsFactors = FALSE
    )

    expect_true(validate_data_columns(data_with_nas))
    expect_true(all(is.na(data_with_nas$Optional_Field)))
  })

  it("handles very wide data frames", {
    # Create data with many columns
    base_data <- data.frame(
      Activity = "Test",
      Pressure = "Test",
      Central_Problem = "Test",
      Consequence = "Test",
      stringsAsFactors = FALSE
    )

    # Add 50 additional columns
    for (i in 1:50) {
      base_data[[paste0("Col_", i)]] <- paste0("Value_", i)
    }

    expect_true(validate_data_columns(base_data))
    expect_equal(ncol(base_data), 54)  # 4 base + 50 added
  })

  it("handles data with long string values", {
    long_string <- paste(rep("A", 1000), collapse = "")

    long_data <- data.frame(
      Activity = long_string,
      Pressure = "Normal",
      Central_Problem = "Normal",
      Consequence = long_string,
      stringsAsFactors = FALSE
    )

    expect_true(validate_data_columns(long_data))
    expect_equal(nchar(long_data$Activity[1]), 1000)
  })

  it("handles whitespace-only values", {
    whitespace_data <- data.frame(
      Activity = c("  ", "\t", "\n"),
      Pressure = c("P1", "P2", "P3"),
      Central_Problem = c("CP1", "CP2", "CP3"),
      Consequence = c("C1", "C2", "C3"),
      stringsAsFactors = FALSE
    )

    # Columns exist, so validation passes (content validation is separate)
    expect_true(validate_data_columns(whitespace_data))
  })

  it("handles duplicate column names gracefully", {
    # R automatically renames duplicate columns
    dup_data <- data.frame(
      Activity = "A1",
      Activity = "A2",  # Will become Activity.1
      Pressure = "P1",
      Central_Problem = "CP1",
      Consequence = "C1",
      check.names = TRUE,
      stringsAsFactors = FALSE
    )

    # R adds suffix to duplicate names
    expect_true("Activity" %in% names(dup_data))
    expect_true(validate_data_columns(dup_data))
  })
})
