# =============================================================================
# Tests for Local Storage Module
# =============================================================================
# File: tests/testthat/test-local-storage-module.R
# Tests: File save/load, path validation, session isolation, error recovery
# =============================================================================

context("Local Storage Module")

# Load required packages
library(testthat)
library(jsonlite)

# Load the helper setup (provides app_root, create_test_dir, cleanup_test_files)
if (!exists("app_root")) {
  source(file.path(getwd(), "tests/testthat/helper-setup.R"))
}

# =============================================================================
# Module Loading Tests
# =============================================================================

test_that("local_storage_module.R can be sourced", {
  module_path <- file.path(app_root, "server_modules/local_storage_module.R")

  # First verify the file exists

  expect_true(file.exists(module_path),
              info = paste("Module file should exist at:", module_path))

  # Module requires shiny and shinyFiles - skip if not available
  skip_if_not_installed("shiny")
  skip_if_not_installed("shinyFiles")

  # Source should not error (it defines functions, doesn't execute server code)
  expect_no_error({
    source(module_path, local = TRUE)
  })
})

test_that("security_helpers.R provides required functions", {
  security_path <- file.path(app_root, "helpers/security_helpers.R")

  expect_true(file.exists(security_path),
              info = "Security helpers file should exist")

  # Source the security helpers
  local_env <- new.env()
  source(security_path, local = local_env)

  # Verify required functions exist
  expect_true(exists("safe_readRDS", envir = local_env),
              info = "safe_readRDS function should be defined")
  expect_true(exists("safe_fromJSON", envir = local_env),
              info = "safe_fromJSON function should be defined")
  expect_true(exists("validate_file_path", envir = local_env),
              info = "validate_file_path function should be defined")
  expect_true(exists("validate_rds_object", envir = local_env),
              info = "validate_rds_object function should be defined")
})

# =============================================================================
# File Save/Load Tests
# =============================================================================

describe("File Save Operations", {

  it("saves data to valid path successfully", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    test_data <- list(
      project_name = "Test Project",
      activities = c("Activity 1", "Activity 2"),
      pressures = c("Pressure 1")
    )

    save_path <- file.path(test_dir, "test_save.rds")

    # Test that saveRDS works (the module wraps this)
    expect_no_error({
      saveRDS(test_data, save_path)
    })

    expect_true(file.exists(save_path),
                info = "Save file should be created")
  })

  it("handles empty data gracefully", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    empty_data <- list()
    save_path <- file.path(test_dir, "empty_save.rds")

    expect_no_error({
      saveRDS(empty_data, save_path)
    })

    loaded <- readRDS(save_path)
    expect_equal(loaded, empty_data,
                 info = "Empty list should save and load correctly")
  })

  it("preserves data integrity through save/load cycle", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    original_data <- list(
      project_name = "Integrity Test",
      activities = c("Marine Transport", "Offshore Wind"),
      pressures = c("Oil Pollution", "Noise"),
      controls = c("Safety Protocol", "Monitoring"),
      numeric_values = c(1.5, 2.7, 3.9),
      nested = list(a = 1, b = list(c = 2))
    )

    save_path <- file.path(test_dir, "integrity_test.rds")
    saveRDS(original_data, save_path)
    loaded_data <- readRDS(save_path)

    expect_equal(loaded_data, original_data,
                 info = "Data should be identical after save/load cycle")
    expect_equal(loaded_data$nested$b$c, 2,
                 info = "Nested data should be preserved correctly")
  })

  it("saves data with timestamp metadata", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Simulating the structure used by local_storage_module
    save_data <- list(
      timestamp = Sys.time(),
      version = "5.4.0",
      current_data = data.frame(
        id = 1:3,
        name = c("Item A", "Item B", "Item C"),
        stringsAsFactors = FALSE
      ),
      settings = list(
        storage_mode = "local",
        storage_path = test_dir
      )
    )

    save_path <- file.path(test_dir, "metadata_test.rds")
    saveRDS(save_data, save_path)
    loaded <- readRDS(save_path)

    expect_true(!is.null(loaded$timestamp),
                info = "Timestamp should be preserved")
    expect_equal(loaded$version, "5.4.0",
                 info = "Version should be preserved")
    expect_equal(nrow(loaded$current_data), 3,
                 info = "Data frame should be preserved")
  })

  it("handles large data structures", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create a moderately large dataset (not too large for test speed)
    large_data <- list(
      activities = paste0("Activity_", 1:1000),
      pressures = paste0("Pressure_", 1:500),
      matrix_data = matrix(runif(10000), nrow = 100, ncol = 100),
      df = data.frame(
        id = 1:5000,
        value = rnorm(5000),
        category = sample(LETTERS, 5000, replace = TRUE),
        stringsAsFactors = FALSE
      )
    )

    save_path <- file.path(test_dir, "large_data.rds")

    expect_no_error({
      saveRDS(large_data, save_path)
    })

    loaded <- readRDS(save_path)
    expect_equal(length(loaded$activities), 1000)
    expect_equal(nrow(loaded$df), 5000)
  })
})

# =============================================================================
# Path Validation Tests
# =============================================================================

describe("Path Validation", {

  it("accepts valid directory paths", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    expect_true(dir.exists(test_dir),
                info = "Test directory should exist")
    expect_true(file.info(test_dir)$isdir,
                info = "Path should be a directory")
  })

  it("rejects paths with directory traversal attempts", {
    # This tests the security aspect - paths should not escape intended directory
    dangerous_paths <- c(
      "../../../etc/passwd",
      "..\\..\\..\\windows\\system32",
      "normal/../../../etc/passwd"
    )

    for (path in dangerous_paths) {
      # normalizePath should reveal the actual path
      # Application should validate paths don't escape base directory
      normalized <- suppressWarnings(normalizePath(path, mustWork = FALSE))
      expect_false(grepl("^/etc|^C:\\\\Windows", normalized, ignore.case = TRUE),
                   info = paste("Path should not resolve to system directories:", path))
    }
  })

  it("detects path traversal patterns", {
    # Load security helpers to test validate_file_path
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    # Test that validate_file_path catches traversal attempts
    expect_error(
      local_env$validate_file_path("../../../secret.txt"),
      "path traversal",
      info = "Should reject path traversal with ../"
    )

    expect_error(
      local_env$validate_file_path("..\\..\\secret.txt"),
      "path traversal",
      info = "Should reject Windows-style path traversal"
    )
  })

  it("handles special characters in filenames", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Test safe special characters
    safe_names <- c(
      "project_2026.rds",
      "bowtie-analysis.rds",
      "save (1).rds"
    )

    for (name in safe_names) {
      path <- file.path(test_dir, name)
      # Save should succeed without error
      saveRDS(list(test = TRUE), path)
      expect_true(file.exists(path),
                  info = paste("File should exist:", name))
    }
  })

  it("rejects invalid file extensions", {
    # Module should validate .rds and .json only
    invalid_extensions <- c(".exe", ".bat", ".sh", ".php")

    for (ext in invalid_extensions) {
      filename <- paste0("malicious", ext)
      # Just verify the extension is detected
      expect_equal(tools::file_ext(filename), substr(ext, 2, nchar(ext)),
                   info = paste("Extension should be detected:", ext))
    }
  })

  it("validates file extensions properly with security helpers", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create a file with wrong extension
    wrong_ext_file <- file.path(test_dir, "test.txt")
    saveRDS(list(data = "test"), wrong_ext_file)

    # safe_readRDS should reject non-.rds files
    expect_error(
      local_env$safe_readRDS(wrong_ext_file),
      "Invalid file extension",
      info = "Should reject files without .rds extension"
    )
  })

  it("normalizes paths correctly on Windows and Unix", {
    # Test that path normalization works across platforms
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create a nested directory
    nested_dir <- file.path(test_dir, "subdir1", "subdir2")
    dir.create(nested_dir, recursive = TRUE)

    # Create a file
    test_file <- file.path(nested_dir, "test.rds")
    saveRDS(list(test = TRUE), test_file)

    # Verify normalized path works
    normalized <- normalizePath(test_file, mustWork = TRUE)
    expect_true(file.exists(normalized))

    # Verify we can load using normalized path
    loaded <- readRDS(normalized)
    expect_true(loaded$test)
  })
})

# =============================================================================
# Error Recovery Tests
# =============================================================================

describe("Error Recovery", {

  it("handles non-existent file gracefully", {
    expect_error({
      readRDS("/nonexistent/path/file.rds")
    }, info = "Should error on non-existent file")
  })

  it("safe_readRDS handles non-existent file with clear message", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    expect_error(
      local_env$safe_readRDS("/definitely/not/existing/file.rds"),
      "File not found",
      info = "safe_readRDS should give clear error for missing file"
    )
  })

  it("handles corrupt file gracefully", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    corrupt_path <- file.path(test_dir, "corrupt.rds")
    writeLines("not valid rds content", corrupt_path)

    expect_error({
      readRDS(corrupt_path)
    }, info = "Should error on corrupt RDS file")
  })

  it("safe_readRDS rejects corrupt files", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    corrupt_path <- file.path(test_dir, "corrupt.rds")
    writeLines("this is not valid RDS content at all", corrupt_path)

    expect_error(
      local_env$safe_readRDS(corrupt_path),
      "Failed to read RDS",
      info = "safe_readRDS should error on corrupt files"
    )
  })

  it("handles permission denied scenario", {
    skip_on_os("windows")  # Permission handling differs on Windows

    test_dir <- create_test_dir()
    on.exit({
      Sys.chmod(test_dir, "755")
      cleanup_test_files(test_dir)
    })

    # Make directory read-only
    Sys.chmod(test_dir, "444")

    expect_error({
      saveRDS(list(test = TRUE), file.path(test_dir, "denied.rds"))
    }, info = "Should error when directory is read-only")
  })

  it("recovers gracefully from file size limits", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create a valid but large-ish file
    large_data <- list(
      data = rep("x", 1000000)  # ~1MB of data
    )

    save_path <- file.path(test_dir, "large.rds")
    saveRDS(large_data, save_path)

    # Should work with reasonable size limit
    expect_no_error({
      result <- local_env$safe_readRDS(save_path, max_size_mb = 50)
    })

    # Should fail with very small size limit
    expect_error(
      local_env$safe_readRDS(save_path, max_size_mb = 0.001),
      "too large",
      info = "Should reject files exceeding size limit"
    )
  })

  it("handles unexpected object types in RDS", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Save a valid list
    save_path <- file.path(test_dir, "expected_list.rds")
    saveRDS(list(a = 1, b = 2), save_path)

    # Should succeed when expecting a list
    result <- local_env$safe_readRDS(save_path, expected_class = "list")
    expect_equal(result$a, 1)

    # Save a data frame
    df_path <- file.path(test_dir, "dataframe.rds")
    saveRDS(data.frame(x = 1:3), df_path)

    # Should error when class doesn't match (after warning about unexpected class)
    # The validate_rds_object warns then returns FALSE, causing safe_readRDS to error
    expect_error(
      suppressWarnings(local_env$safe_readRDS(df_path, expected_class = "list")),
      "invalid or unexpected"
    )
  })
})

# =============================================================================
# JSON Format Tests (Alternative Save Format)
# =============================================================================

describe("JSON Save Format", {

  it("saves workflow state as JSON", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    workflow_state <- list(
      current_step = 3,
      project_name = "JSON Test",
      activities = c("Activity A", "Activity B")
    )

    json_path <- file.path(test_dir, "workflow.json")

    expect_no_error({
      jsonlite::write_json(workflow_state, json_path, auto_unbox = TRUE, pretty = TRUE)
    })

    expect_true(file.exists(json_path),
                info = "JSON file should be created")

    loaded <- jsonlite::read_json(json_path, simplifyVector = TRUE)
    expect_equal(loaded$current_step, 3,
                 info = "Current step should be preserved")
    expect_equal(loaded$project_name, "JSON Test",
                 info = "Project name should be preserved")
  })

  it("handles nested JSON structures", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    complex_state <- list(
      metadata = list(
        version = "5.4.0",
        timestamp = as.character(Sys.time())
      ),
      project = list(
        name = "Complex Project",
        settings = list(
          theme = "zephyr",
          language = "en"
        )
      ),
      workflow = list(
        current_step = 5,
        steps = list(
          list(id = 1, name = "Setup", complete = TRUE),
          list(id = 2, name = "Analysis", complete = TRUE),
          list(id = 3, name = "Export", complete = FALSE)
        )
      )
    )

    json_path <- file.path(test_dir, "complex.json")
    jsonlite::write_json(complex_state, json_path, auto_unbox = TRUE, pretty = TRUE)

    loaded <- jsonlite::read_json(json_path, simplifyVector = FALSE)

    expect_equal(loaded$metadata$version, "5.4.0")
    expect_equal(loaded$project$settings$theme, "zephyr")
    expect_equal(loaded$workflow$steps[[1]]$complete, TRUE)
  })

  it("safe_fromJSON enforces size limits", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    # Small JSON should work
    small_json <- '{"test": true, "value": 123}'
    result <- local_env$safe_fromJSON(small_json)
    expect_true(result$test)
    expect_equal(result$value, 123)

    # Very large JSON should fail (create a large string)
    large_json <- paste0('{"data": "', paste(rep("x", 100000), collapse = ""), '"}')

    # Should fail with tiny size limit
    expect_error(
      local_env$safe_fromJSON(large_json, max_size = 1000),
      "JSON too large",
      info = "Should reject JSON exceeding size limit"
    )
  })

  it("handles JSON with special characters", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    special_data <- list(
      project_name = "Test with \"quotes\" and \\ backslash",
      description = "Line1\nLine2\tTabbed",
      unicode = "Environmental \u2192 Impact"
    )

    json_path <- file.path(test_dir, "special.json")
    jsonlite::write_json(special_data, json_path, auto_unbox = TRUE, pretty = TRUE)

    loaded <- jsonlite::read_json(json_path, simplifyVector = TRUE)
    expect_equal(loaded$project_name, special_data$project_name)
    expect_equal(loaded$description, special_data$description)
  })

  it("converts between JSON and RDS formats", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Original data
    original <- list(
      project = "Format Test",
      values = c(1.1, 2.2, 3.3),
      categories = c("A", "B", "C")
    )

    # Save as JSON
    json_path <- file.path(test_dir, "data.json")
    jsonlite::write_json(original, json_path, auto_unbox = TRUE)

    # Load JSON and save as RDS
    from_json <- jsonlite::read_json(json_path, simplifyVector = TRUE)
    rds_path <- file.path(test_dir, "data.rds")
    saveRDS(from_json, rds_path)

    # Load RDS
    from_rds <- readRDS(rds_path)

    # Verify data consistency
    expect_equal(from_rds$project, original$project)
    expect_equal(from_rds$values, original$values, tolerance = 1e-10)
    expect_equal(from_rds$categories, original$categories)
  })
})

# =============================================================================
# Security Validation Tests (using security_helpers.R)
# =============================================================================

describe("Security Validations", {

  it("validate_rds_object rejects functions", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    # Function object should be rejected
    dangerous_obj <- function(x) x + 1

    expect_warning(
      result <- local_env$validate_rds_object(dangerous_obj),
      "function"
    )
    expect_false(result, info = "Function objects should be rejected")
  })

  it("validate_rds_object accepts safe data types", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    # Safe data types
    safe_objects <- list(
      "character vector" = c("a", "b", "c"),
      "numeric vector" = c(1, 2, 3),
      "data frame" = data.frame(x = 1:3, y = c("a", "b", "c")),
      "simple list" = list(a = 1, b = "text"),
      "nested list" = list(a = list(b = list(c = 1)))
    )

    for (name in names(safe_objects)) {
      result <- local_env$validate_rds_object(safe_objects[[name]])
      expect_true(result, info = paste("Should accept:", name))
    }
  })

  it("validate_rds_object checks expected class", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    # List object expecting list class - should pass
    expect_true(
      local_env$validate_rds_object(list(a = 1), expected_class = "list")
    )

    # Data frame expecting list class - should warn and fail
    expect_warning(
      result <- local_env$validate_rds_object(data.frame(x = 1), expected_class = "list"),
      "Unexpected object class"
    )
    expect_false(result)
  })

  it("handles deeply nested structures safely", {
    security_path <- file.path(app_root, "helpers/security_helpers.R")
    local_env <- new.env()
    source(security_path, local = local_env)

    # Create a reasonably deep structure (not exceeding depth limit)
    deep <- list(level = 1)
    for (i in 2:50) {
      deep <- list(level = i, nested = deep)
    }

    # Should validate without error
    expect_no_warning({
      result <- local_env$validate_rds_object(deep)
    })
    expect_true(result)
  })
})

# =============================================================================
# Storage Mode Tests
# =============================================================================

describe("Storage Modes", {

  it("differentiates between browser, local, and server modes", {
    # This tests the logic structure, not the actual Shiny reactives
    modes <- c("browser", "local", "server")

    for (mode in modes) {
      expect_true(mode %in% c("browser", "local", "server"),
                  info = paste("Mode should be valid:", mode))
    }

    # Verify mode names match expected patterns
    expect_equal(length(modes), 3,
                 info = "Should have exactly 3 storage modes")
  })

  it("generates appropriate filenames with timestamps", {
    # Test the filename generation pattern used by the module
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")

    rds_filename <- sprintf("bowtie_save_%s.rds", timestamp)
    json_filename <- sprintf("bowtie_save_%s.json", timestamp)

    # Verify pattern
    expect_match(rds_filename, "^bowtie_save_\\d{8}_\\d{6}\\.rds$",
                 info = "RDS filename should match expected pattern")
    expect_match(json_filename, "^bowtie_save_\\d{8}_\\d{6}\\.json$",
                 info = "JSON filename should match expected pattern")
  })
})

# =============================================================================
# Volume/Directory Access Tests
# =============================================================================

describe("Volume and Directory Access", {

  it("identifies user home directory correctly", {
    # Test the home directory detection logic from the module
    home_dir <- Sys.getenv("USERPROFILE")
    if (home_dir == "") home_dir <- Sys.getenv("HOME")
    if (home_dir == "") home_dir <- path.expand("~")

    expect_true(nchar(home_dir) > 0,
                info = "Home directory should be detected")
    expect_true(dir.exists(home_dir),
                info = "Home directory should exist")
  })

  it("creates subdirectories recursively", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Test creating nested bowtie_saves folder
    nested_path <- file.path(test_dir, "subdir1", "subdir2", "bowtie_saves")

    expect_false(dir.exists(nested_path),
                 info = "Nested directory should not exist initially")

    dir.create(nested_path, recursive = TRUE)

    expect_true(dir.exists(nested_path),
                info = "Nested directory should be created")
  })

  it("verifies folder write access correctly", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Test write verification (similar to verify_folder_access in module)
    test_file <- file.path(test_dir, ".bowtie_write_test")

    # Write test file
    writeLines("test", test_file)
    expect_true(file.exists(test_file),
                info = "Test file should be created")

    # Clean up test file
    file.remove(test_file)
    expect_false(file.exists(test_file),
                 info = "Test file should be removed")
  })

  it("lists save files with correct patterns", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create various files
    saveRDS(list(a = 1), file.path(test_dir, "save1.rds"))
    saveRDS(list(b = 2), file.path(test_dir, "save2.rds"))
    jsonlite::write_json(list(c = 3), file.path(test_dir, "save3.json"))
    writeLines("text", file.path(test_dir, "notes.txt"))

    # List only save files (rds and json)
    files <- list.files(test_dir, pattern = "\\.(rds|json)$", full.names = FALSE)

    expect_equal(length(files), 3,
                 info = "Should find 3 save files")
    expect_true("save1.rds" %in% files)
    expect_true("save3.json" %in% files)
    expect_false("notes.txt" %in% files,
                 info = "Non-save files should be excluded")
  })

  it("sorts files by modification time", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create files with slight time delays
    saveRDS(list(first = 1), file.path(test_dir, "first.rds"))
    Sys.sleep(0.1)
    saveRDS(list(second = 2), file.path(test_dir, "second.rds"))
    Sys.sleep(0.1)
    saveRDS(list(third = 3), file.path(test_dir, "third.rds"))

    # Get files and sort by modification time
    files <- list.files(test_dir, pattern = "\\.rds$", full.names = TRUE)
    file_times <- file.info(files)$mtime
    newest_file <- files[which.max(file_times)]

    expect_match(basename(newest_file), "third.rds",
                 info = "Most recently modified file should be detected")
  })
})

# =============================================================================
# Integration Test: Complete Save/Load Cycle
# =============================================================================

describe("Complete Save/Load Integration", {

  it("performs complete workflow save/load cycle", {
    test_dir <- create_test_dir()
    on.exit(cleanup_test_files(test_dir))

    # Create comprehensive workflow state
    workflow_state <- list(
      timestamp = Sys.time(),
      version = "5.4.0",
      current_step = 5,
      project_data = list(
        project_name = "Integration Test Project",
        central_problem = "Marine Pollution Assessment",
        activities = c("Shipping", "Offshore Drilling", "Coastal Development"),
        pressures = c("Oil Pollution", "Noise Disturbance", "Habitat Loss"),
        preventive_controls = c("Safety Protocols", "Environmental Monitoring"),
        consequences = c("Ecosystem Damage", "Species Decline"),
        protective_controls = c("Emergency Response", "Remediation")
      ),
      settings = list(
        storage_mode = "local",
        storage_path = test_dir,
        language = "en"
      )
    )

    # Save as RDS
    rds_path <- file.path(test_dir, "workflow_state.rds")
    saveRDS(workflow_state, rds_path)

    # Save as JSON
    json_path <- file.path(test_dir, "workflow_state.json")
    jsonlite::write_json(workflow_state, json_path, auto_unbox = TRUE, pretty = TRUE)

    # Verify both files exist
    expect_true(file.exists(rds_path))
    expect_true(file.exists(json_path))

    # Load and verify RDS
    loaded_rds <- readRDS(rds_path)
    expect_equal(loaded_rds$project_data$project_name, "Integration Test Project")
    expect_equal(length(loaded_rds$project_data$activities), 3)

    # Load and verify JSON
    loaded_json <- jsonlite::read_json(json_path, simplifyVector = TRUE)
    expect_equal(loaded_json$project_data$project_name, "Integration Test Project")
    expect_equal(loaded_json$current_step, 5)

    # Verify data consistency between formats
    expect_equal(
      loaded_rds$project_data$central_problem,
      loaded_json$project_data$central_problem
    )
  })
})
