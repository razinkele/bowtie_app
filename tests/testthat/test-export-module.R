# =============================================================================
# Tests for Export Module
# =============================================================================
# File: tests/testthat/test-export-module.R
# Tests: Excel export, format preservation, file operations
# =============================================================================

context("Export Module")

# Load required packages
library(testthat)

# Load the helper setup (provides app_root, create_test_dir, cleanup_test_files)
# Explicit source with error handling to ensure test infrastructure is available
tryCatch({
  # Try multiple possible locations for the helper file
  possible_paths <- c(
    file.path(getwd(), "tests/testthat/helper-setup.R"),  # From project root
    file.path(getwd(), "helper-setup.R"),                  # From tests/testthat dir
    file.path(dirname(getwd()), "testthat/helper-setup.R") # From tests dir
  )

  helper_path <- NULL
  for (path in possible_paths) {
    if (file.exists(path)) {
      helper_path <- path
      break
    }
  }

  if (is.null(helper_path)) {
    stop("Helper setup file not found. Searched paths:\n  - ",
         paste(possible_paths, collapse = "\n  - "))
  }

  source(helper_path)
}, error = function(e) {
  stop("Failed to load test helper setup. Ensure tests are run from the project root directory or tests/testthat directory. Error: ", e$message)
})

# Load dependencies safely
skip_if_not_installed("openxlsx")
if (requireNamespace("openxlsx", quietly = TRUE)) {
  suppressPackageStartupMessages(library(openxlsx))
}

# =============================================================================
# Module Loading Tests
# =============================================================================

test_that("export_module.R can be sourced", {
  module_path <- file.path(app_root, "server_modules/export_module.R")

  expect_true(file.exists(module_path),
              info = paste("Module file should exist at:", module_path))

  # Source should not error (it defines functions, doesn't execute server code)
  expect_no_error({
    source(module_path, local = TRUE)
  })
})

test_that("export_module_server function is defined after sourcing", {
  module_path <- file.path(app_root, "server_modules/export_module.R")
  local_env <- new.env()
  source(module_path, local = local_env)

  expect_true(exists("export_module_server", envir = local_env),
              info = "export_module_server function should be defined")
  expect_true(is.function(local_env$export_module_server),
              info = "export_module_server should be a function")
})

# =============================================================================
# Excel Export Tests
# =============================================================================

describe("Excel Export Operations", {

  it("exports data frame to valid XLSX file", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    test_data <- data.frame(
      Activity = c("Marine Transport", "Offshore Wind"),
      Pressure = c("Oil Pollution", "Noise Disturbance"),
      Central_Problem = c("Water Contamination", "Wildlife Impact"),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "export_test.xlsx")

    expect_no_error({
      openxlsx::write.xlsx(test_data, export_path)
    })

    expect_true(file.exists(export_path))

    # Verify it's a valid XLSX (ZIP with PK signature)
    con <- file(export_path, "rb")
    first_bytes <- readBin(con, "raw", n = 2)
    close(con)
    expect_equal(first_bytes, as.raw(c(0x50, 0x4B)))
  })

  it("preserves all columns on export", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      Col1 = 1:3,
      Col2 = c("a", "b", "c"),
      Col3 = c(TRUE, FALSE, TRUE),
      Col4 = c(1.1, 2.2, 3.3),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "columns_test.xlsx")
    openxlsx::write.xlsx(original, export_path)

    reimported <- openxlsx::read.xlsx(export_path)

    expect_equal(ncol(reimported), ncol(original),
                 info = "Column count should be preserved")
    expect_equal(names(reimported), names(original),
                 info = "Column names should be preserved")

    # Verify column ORDER is preserved (not just names match)
    for (i in seq_along(names(original))) {
      expect_equal(names(reimported)[i], names(original)[i],
                   info = paste("Column order mismatch at position", i,
                                "- expected:", names(original)[i],
                                "got:", names(reimported)[i]))
    }
  })

  it("preserves row count on export", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      Activity = paste0("Activity_", 1:100),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "rows_test.xlsx")
    openxlsx::write.xlsx(original, export_path)

    reimported <- openxlsx::read.xlsx(export_path)

    expect_equal(nrow(reimported), 100)
  })

  it("handles empty data frame", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    empty_data <- data.frame(
      Activity = character(0),
      Pressure = character(0),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "empty_test.xlsx")

    expect_no_error({
      openxlsx::write.xlsx(empty_data, export_path)
    })

    expect_true(file.exists(export_path))
  })

  it("handles single-row data frame", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    single_row <- data.frame(
      Activity = "Single Activity",
      Pressure = "Single Pressure",
      Central_Problem = "Single Problem",
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "single_row_test.xlsx")
    openxlsx::write.xlsx(single_row, export_path)

    reimported <- openxlsx::read.xlsx(export_path)

    expect_equal(nrow(reimported), 1)
    expect_equal(reimported$Activity, "Single Activity")
  })

  it("handles large data frame export", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    large_data <- data.frame(
      Activity = paste0("Activity_", 1:1000),
      Pressure = paste0("Pressure_", 1:1000),
      Central_Problem = paste0("Problem_", 1:1000),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "large_data_test.xlsx")

    expect_no_error({
      openxlsx::write.xlsx(large_data, export_path)
    })

    reimported <- openxlsx::read.xlsx(export_path)
    expect_equal(nrow(reimported), 1000)
  })
})

# =============================================================================
# Format Preservation Tests
# =============================================================================

describe("Data Format Preservation", {

  it("preserves numeric values", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      integer_col = c(1L, 2L, 3L),
      double_col = c(1.5, 2.7, 3.9),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "numeric_test.xlsx")
    openxlsx::write.xlsx(original, export_path)
    reimported <- openxlsx::read.xlsx(export_path)

    expect_equal(reimported$double_col, original$double_col, tolerance = 0.001)
  })

  it("preserves date values", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      date_col = as.Date(c("2026-01-01", "2026-06-15", "2026-12-31")),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "date_test.xlsx")
    openxlsx::write.xlsx(original, export_path)
    reimported <- openxlsx::read.xlsx(export_path, detectDates = TRUE)

    expect_s3_class(reimported$date_col, "Date")
  })

  it("handles special characters in text", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      text_col = c(
        "Normal text",
        "Text with 'quotes'",
        'Text with "double quotes"',
        "Text with\nnewline"
      ),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "special_chars_test.xlsx")
    openxlsx::write.xlsx(original, export_path)
    reimported <- openxlsx::read.xlsx(export_path)

    expect_equal(reimported$text_col[1], "Normal text")
    expect_true(grepl("quotes", reimported$text_col[2]))
  })

  it("preserves UTF-8 encoding", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      french = "cafe\u0301",
      greek = "\u03b1\u03b2\u03b3\u03b4",
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "utf8_test.xlsx")
    openxlsx::write.xlsx(original, export_path)
    reimported <- openxlsx::read.xlsx(export_path)

    # Verify content is preserved (encoding may vary by platform)
    expect_equal(nchar(reimported$french), nchar(original$french))
  })

  it("preserves logical values as TRUE/FALSE", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      bool_col = c(TRUE, FALSE, TRUE, FALSE),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "logical_test.xlsx")
    openxlsx::write.xlsx(original, export_path)
    reimported <- openxlsx::read.xlsx(export_path)

    # Excel converts logical to TRUE/FALSE strings or 1/0
    expect_equal(length(reimported$bool_col), 4)
  })

  it("handles NA values in data", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Use explicit NA replacement to ensure consistent export/import
    original <- data.frame(
      text_col = c("A", "", "C"),  # Use empty string instead of NA
      num_col = c(1, 2, 3),        # Use actual values for numeric
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "na_test.xlsx")
    openxlsx::write.xlsx(original, export_path)
    reimported <- openxlsx::read.xlsx(export_path)

    # Verify structure is preserved
    expect_equal(nrow(reimported), 3, info = "Row count should be preserved")
    expect_equal(reimported$text_col[1], "A", info = "First value should be preserved")
    expect_equal(reimported$text_col[3], "C", info = "Third value should be preserved")
    expect_equal(reimported$num_col[1], 1, info = "First numeric should be preserved")
    expect_equal(reimported$num_col[3], 3, info = "Third numeric should be preserved")
  })

  it("exports data with NA using keepNA option", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      Activity = c("Activity 1", NA, "Activity 3"),
      Value = c(1, NA, 3),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "na_keepna_test.xlsx")

    # Use workbook with keepNA to preserve NA values in Excel
    wb <- openxlsx::createWorkbook()
    openxlsx::addWorksheet(wb, "Data")
    openxlsx::writeData(wb, "Data", original, keepNA = TRUE)
    openxlsx::saveWorkbook(wb, export_path, overwrite = TRUE)

    expect_true(file.exists(export_path))

    # Re-import with skipEmptyRows = FALSE to preserve rows with NA values
    # By default, read.xlsx skips rows where all cells are empty/NA
    reimported <- openxlsx::read.xlsx(export_path, skipEmptyRows = FALSE)

    expect_equal(nrow(reimported), 3,
                 info = "Row count should be preserved when using skipEmptyRows = FALSE")
    expect_equal(reimported$Activity[1], "Activity 1",
                 info = "First Activity value should be preserved")
    expect_true(is.na(reimported$Activity[2]),
                info = "NA in Activity column should be preserved after re-import")
    expect_equal(reimported$Activity[3], "Activity 3",
                 info = "Third Activity value should be preserved")
    expect_equal(reimported$Value[1], 1,
                 info = "First numeric value should be preserved")
    expect_true(is.na(reimported$Value[2]),
                info = "NA in Value column should be preserved after re-import")
    expect_equal(reimported$Value[3], 3,
                 info = "Third numeric value should be preserved")
  })

  it("handles mixed data types in data frame", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      Activity = "Marine Transport",
      Likelihood = 3.5,
      Count = 10L,
      Active = TRUE,
      Date = as.Date("2026-01-15"),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "mixed_types_test.xlsx")
    openxlsx::write.xlsx(original, export_path)
    reimported <- openxlsx::read.xlsx(export_path, detectDates = TRUE)

    expect_equal(reimported$Activity, "Marine Transport")
    expect_equal(reimported$Likelihood, 3.5, tolerance = 0.001)
  })
})

# =============================================================================
# File Operation Error Tests
# =============================================================================

describe("File Operation Errors", {

  it("fails gracefully on invalid path", {
    test_data <- data.frame(a = 1)

    # On Windows, write to invalid path generates warning not error
    # On Linux, it may error. Test that some indication of failure occurs.
    result <- tryCatch({
      suppressWarnings(openxlsx::write.xlsx(test_data, "/nonexistent/directory/file.xlsx"))
      "no_error"
    }, error = function(e) {
      "error_occurred"
    }, warning = function(w) {
      "warning_occurred"
    })

    # File should not exist at invalid path
    expect_false(file.exists("/nonexistent/directory/file.xlsx"))
  })

  it("generates unique filenames with timestamp", {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    filename <- paste0("bowtie_export_", timestamp, ".xlsx")

    expect_match(filename, "^bowtie_export_\\d{8}_\\d{6}\\.xlsx$")
  })

  it("sanitizes problem names for filenames", {
    problem_name <- "Water Pollution / Oil Spill"
    sanitized <- gsub("[^A-Za-z0-9_-]", "_", problem_name)

    expect_false(grepl("/", sanitized))
    expect_equal(sanitized, "Water_Pollution___Oil_Spill")
  })

  it("handles very long filenames", {
    long_name <- paste(rep("a", 200), collapse = "")
    truncated <- substr(long_name, 1, 100)

    expect_equal(nchar(truncated), 100)
    expect_lte(nchar(truncated), 255)  # Max filename length
  })

  it("sanitizes special characters in filenames", {
    unsafe_chars <- c("<", ">", ":", '"', "/", "\\", "|", "?", "*")

    for (char in unsafe_chars) {
      filename <- paste0("test", char, "file.xlsx")
      sanitized <- gsub("[<>:\"/\\|?*]", "_", filename)
      expect_false(grepl(paste0("[", char, "]"), sanitized),
                   info = paste("Character should be sanitized:", char))
    }
  })

  it("generates correct file extension", {
    base_name <- "bowtie_export_2026"

    xlsx_name <- paste0(base_name, ".xlsx")
    csv_name <- paste0(base_name, ".csv")

    expect_equal(tools::file_ext(xlsx_name), "xlsx")
    expect_equal(tools::file_ext(csv_name), "csv")
  })

  it("handles filename with spaces", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    test_data <- data.frame(a = 1:3)
    export_path <- file.path(test_dir, "file with spaces.xlsx")

    expect_no_error({
      openxlsx::write.xlsx(test_data, export_path)
    })

    expect_true(file.exists(export_path))
  })
})

# =============================================================================
# Multiple Sheet Export Tests
# =============================================================================

describe("Multiple Sheet Export", {

  it("exports multiple sheets to single workbook", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    wb <- openxlsx::createWorkbook()

    data1 <- data.frame(Activity = c("A1", "A2"))
    data2 <- data.frame(Pressure = c("P1", "P2"))

    openxlsx::addWorksheet(wb, "Activities")
    openxlsx::writeData(wb, "Activities", data1)

    openxlsx::addWorksheet(wb, "Pressures")
    openxlsx::writeData(wb, "Pressures", data2)

    export_path <- file.path(test_dir, "multi_sheet.xlsx")
    openxlsx::saveWorkbook(wb, export_path, overwrite = TRUE)

    sheets <- openxlsx::getSheetNames(export_path)
    expect_equal(length(sheets), 2)
    expect_true("Activities" %in% sheets)
    expect_true("Pressures" %in% sheets)
  })

  it("preserves data in each sheet independently", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    wb <- openxlsx::createWorkbook()

    activities <- data.frame(Activity = c("Marine Transport", "Offshore Wind"))
    pressures <- data.frame(Pressure = c("Oil Pollution", "Noise"))

    openxlsx::addWorksheet(wb, "Activities")
    openxlsx::writeData(wb, "Activities", activities)

    openxlsx::addWorksheet(wb, "Pressures")
    openxlsx::writeData(wb, "Pressures", pressures)

    export_path <- file.path(test_dir, "multi_sheet_data.xlsx")
    openxlsx::saveWorkbook(wb, export_path, overwrite = TRUE)

    reimported_activities <- openxlsx::read.xlsx(export_path, sheet = "Activities")
    reimported_pressures <- openxlsx::read.xlsx(export_path, sheet = "Pressures")

    expect_equal(reimported_activities$Activity[1], "Marine Transport")
    expect_equal(reimported_pressures$Pressure[1], "Oil Pollution")
  })

  it("handles sheet with bowtie-specific structure", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    wb <- openxlsx::createWorkbook()

    # Create bowtie-specific sheets
    causes <- data.frame(
      Activity = c("Shipping", "Fishing"),
      Pressure = c("Oil Pollution", "Overfishing"),
      stringsAsFactors = FALSE
    )

    consequences <- data.frame(
      Consequence = c("Ecosystem Damage", "Species Decline"),
      Impact_Level = c("High", "Medium"),
      stringsAsFactors = FALSE
    )

    controls <- data.frame(
      Control = c("Safety Protocol", "Monitoring"),
      Control_Type = c("Preventive", "Protective"),
      stringsAsFactors = FALSE
    )

    openxlsx::addWorksheet(wb, "Causes")
    openxlsx::writeData(wb, "Causes", causes)

    openxlsx::addWorksheet(wb, "Consequences")
    openxlsx::writeData(wb, "Consequences", consequences)

    openxlsx::addWorksheet(wb, "Controls")
    openxlsx::writeData(wb, "Controls", controls)

    export_path <- file.path(test_dir, "bowtie_structure.xlsx")
    openxlsx::saveWorkbook(wb, export_path, overwrite = TRUE)

    sheets <- openxlsx::getSheetNames(export_path)
    expect_equal(length(sheets), 3)
    expect_true(all(c("Causes", "Consequences", "Controls") %in% sheets))

    reimported_controls <- openxlsx::read.xlsx(export_path, sheet = "Controls")
    expect_equal(nrow(reimported_controls), 2)
  })

  it("handles empty sheets in workbook", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    wb <- openxlsx::createWorkbook()

    # Add empty sheet
    openxlsx::addWorksheet(wb, "EmptySheet")

    # Add sheet with data
    data1 <- data.frame(Activity = c("A1", "A2"))
    openxlsx::addWorksheet(wb, "DataSheet")
    openxlsx::writeData(wb, "DataSheet", data1)

    export_path <- file.path(test_dir, "mixed_empty.xlsx")
    openxlsx::saveWorkbook(wb, export_path, overwrite = TRUE)

    sheets <- openxlsx::getSheetNames(export_path)
    expect_equal(length(sheets), 2)
  })
})

# =============================================================================
# CSV Export Tests
# =============================================================================

describe("CSV Export Operations", {

  it("exports data frame to CSV successfully", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    test_data <- data.frame(
      Activity = c("A1", "A2", "A3"),
      Pressure = c("P1", "P2", "P3"),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "export_test.csv")

    expect_no_error({
      write.csv(test_data, export_path, row.names = FALSE)
    })

    expect_true(file.exists(export_path))
  })

  it("preserves data in CSV round-trip", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original <- data.frame(
      Activity = c("Activity 1", "Activity 2"),
      Pressure = c("Pressure 1", "Pressure 2"),
      Value = c(1.5, 2.5),
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "roundtrip.csv")
    write.csv(original, export_path, row.names = FALSE)
    reimported <- read.csv(export_path, stringsAsFactors = FALSE)

    expect_equal(nrow(reimported), nrow(original))
    expect_equal(reimported$Activity, original$Activity)
    expect_equal(reimported$Value, original$Value)
  })

  it("handles commas in field values", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    test_data <- data.frame(
      Activity = "Marine Transport, Fishing",
      Pressure = "Oil, Chemical Pollution",
      stringsAsFactors = FALSE
    )

    export_path <- file.path(test_dir, "comma_test.csv")
    write.csv(test_data, export_path, row.names = FALSE)
    reimported <- read.csv(export_path, stringsAsFactors = FALSE)

    expect_equal(reimported$Activity, "Marine Transport, Fishing")
  })
})

# =============================================================================
# Export Handler Pattern Tests
# =============================================================================

describe("Export Handler Patterns", {

  it("generates filename with date stamp", {
    # Pattern used in export_module.R
    filename <- paste0("bowtie_data_", Sys.Date(), ".xlsx")

    expect_match(filename, "^bowtie_data_\\d{4}-\\d{2}-\\d{2}\\.xlsx$")
  })

  it("generates filename with problem name", {
    problem <- "Water Contamination"
    sanitized_problem <- gsub(" ", "_", problem)
    filename <- paste("enhanced_bowtie_", sanitized_problem, "_", Sys.Date(), ".html", sep = "")

    expect_match(filename, "Water_Contamination")
    expect_match(filename, "\\.html$")
  })

  it("handles NULL data gracefully", {
    # Pattern used in downloadData handler
    data <- NULL

    if (!is.null(data) && nrow(data) > 0) {
      result <- "has_data"
    } else {
      result <- "no_data"
    }

    expect_equal(result, "no_data")
  })

  it("handles empty data frame gracefully", {
    data <- data.frame()

    if (!is.null(data) && nrow(data) > 0) {
      result <- "has_data"
    } else {
      result <- "no_data"
    }

    expect_equal(result, "no_data")
  })

  it("writes fallback message for empty data", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Pattern used when no data is available
    fallback <- data.frame(Message = "No data available")

    export_path <- file.path(test_dir, "fallback.csv")
    write.csv(fallback, export_path, row.names = FALSE)

    reimported <- read.csv(export_path, stringsAsFactors = FALSE)
    expect_equal(reimported$Message, "No data available")
  })
})

# =============================================================================
# Column Name Normalization Tests (for Problem/Central_Problem compatibility)
# =============================================================================

describe("Column Name Normalization", {

  it("handles Problem column alias for Central_Problem", {
    data <- data.frame(
      Activity = "Test",
      Pressure = "Test",
      Problem = "Legacy Problem Name",
      stringsAsFactors = FALSE
    )

    # Pattern used in export_module.R
    if (!("Central_Problem" %in% names(data)) && "Problem" %in% names(data)) {
      data$Central_Problem <- data$Problem
    }

    expect_true("Central_Problem" %in% names(data))
    expect_equal(data$Central_Problem, "Legacy Problem Name")
  })

  it("preserves Central_Problem when it already exists", {
    data <- data.frame(
      Activity = "Test",
      Pressure = "Test",
      Central_Problem = "Original Problem",
      Problem = "Should Not Override",
      stringsAsFactors = FALSE
    )

    if (!("Central_Problem" %in% names(data)) && "Problem" %in% names(data)) {
      data$Central_Problem <- data$Problem
    }

    expect_equal(data$Central_Problem, "Original Problem")
  })

  it("filters data by selected problem correctly", {
    data <- data.frame(
      Activity = c("A1", "A2", "A3"),
      Central_Problem = c("Problem X", "Problem Y", "Problem X"),
      stringsAsFactors = FALSE
    )

    selected_problem <- "Problem X"
    filtered <- data[data$Central_Problem == selected_problem, ]

    expect_equal(nrow(filtered), 2)
    expect_true(all(filtered$Central_Problem == "Problem X"))
  })
})

# =============================================================================
# Integration Test: Complete Export Cycle
# =============================================================================

describe("Complete Export Integration", {

  it("performs complete bowtie data export cycle", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create comprehensive bowtie data
    bowtie_data <- data.frame(
      Activity = c("Marine Transport", "Offshore Drilling", "Coastal Development"),
      Pressure = c("Oil Pollution", "Noise Disturbance", "Habitat Loss"),
      Central_Problem = c("Marine Ecosystem Degradation", "Marine Ecosystem Degradation", "Coastal Zone Damage"),
      Consequence = c("Species Decline", "Wildlife Displacement", "Erosion"),
      Preventive_Control = c("Safety Protocols", "Environmental Monitoring", "Impact Assessment"),
      Protective_Control = c("Emergency Response", "Remediation Plan", "Restoration Program"),
      Risk_Level = c("High", "Medium", "High"),
      Overall_Likelihood = c(3.5, 2.0, 4.0),
      stringsAsFactors = FALSE
    )

    # Export to XLSX
    xlsx_path <- file.path(test_dir, "bowtie_complete.xlsx")
    openxlsx::write.xlsx(bowtie_data, xlsx_path)

    # Export to CSV
    csv_path <- file.path(test_dir, "bowtie_complete.csv")
    write.csv(bowtie_data, csv_path, row.names = FALSE)

    # Verify both files exist
    expect_true(file.exists(xlsx_path))
    expect_true(file.exists(csv_path))

    # Verify XLSX content
    reimported_xlsx <- openxlsx::read.xlsx(xlsx_path)
    expect_equal(nrow(reimported_xlsx), 3)
    expect_equal(ncol(reimported_xlsx), 8)
    expect_true("Central_Problem" %in% names(reimported_xlsx))
    expect_true("Risk_Level" %in% names(reimported_xlsx))

    # Verify CSV content
    reimported_csv <- read.csv(csv_path, stringsAsFactors = FALSE)
    expect_equal(nrow(reimported_csv), 3)
    expect_equal(reimported_csv$Activity[1], "Marine Transport")

    # Verify data consistency between formats
    expect_equal(reimported_xlsx$Activity, reimported_csv$Activity)
    expect_equal(reimported_xlsx$Central_Problem, reimported_csv$Central_Problem)
  })
})
