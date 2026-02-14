# =============================================================================
# Configuration Tests
# Version: 5.4.0
# Tests for config.R and constants.R configuration consistency
# =============================================================================

context("Configuration Tests")

# =============================================================================
# Setup - Load configuration files
# =============================================================================

test_that("config.R loads without errors", {
  expect_no_error(source("../../config.R", local = TRUE))
})

test_that("constants.R loads without errors", {
  expect_no_error(source("../../constants.R", local = TRUE))
})

# =============================================================================
# APP_CONFIG Structure Tests
# =============================================================================

test_that("APP_CONFIG exists and is a list", {
  source("../../config.R", local = TRUE)
  expect_true(exists("APP_CONFIG"))
  expect_type(APP_CONFIG, "list")
})

test_that("APP_CONFIG has required top-level fields", {
  source("../../config.R", local = TRUE)
  required_fields <- c(
    "APP_NAME", "VERSION", "TITLE",
    "DEFAULT_PORT", "DEFAULT_HOST",
    "REQUIRED_FILES", "REQUIRED_DIRS",
    "THEME", "LANGUAGES", "LOGGING"
  )
  for (field in required_fields) {
    expect_true(field %in% names(APP_CONFIG),
                info = paste("Missing required field:", field))
  }
})

test_that("APP_CONFIG VERSION is valid semver format", {
  source("../../config.R", local = TRUE)
  version <- APP_CONFIG$VERSION
  # Check format X.Y.Z
  expect_true(grepl("^[0-9]+[.][0-9]+[.][0-9]+$", version),
              info = "Version should be in X.Y.Z format")
})

test_that("APP_CONFIG DEFAULT_PORT is valid", {
  source("../../config.R", local = TRUE)
  port <- APP_CONFIG$DEFAULT_PORT
  expect_type(port, "double")
  expect_true(port >= 1024 && port <= 65535,
              info = "Port should be between 1024 and 65535")
})

# =============================================================================
# Constants Tests
# =============================================================================

test_that("Color constants are valid hex codes", {
  source("../../constants.R", local = TRUE)
  color_vars <- c(
    "COLOR_PRIMARY", "COLOR_SUCCESS", "COLOR_DANGER",
    "COLOR_WARNING", "COLOR_INFO"
  )
  hex_pattern <- "^#[0-9A-Fa-f]{6}$"
  for (var in color_vars) {
    if (exists(var)) {
      value <- get(var)
      expect_true(grepl(hex_pattern, value),
                  info = paste(var, "should be valid hex color"))
    }
  }
})

test_that("Node ID offsets are positive integers", {
  source("../../constants.R", local = TRUE)
  offset_vars <- c(
    "NODE_ID_OFFSET_ACTIVITY",
    "NODE_ID_OFFSET_PRESSURE",
    "NODE_ID_OFFSET_CONSEQUENCE",
    "NODE_ID_OFFSET_PREVENTIVE_CONTROL"
  )
  for (var in offset_vars) {
    if (exists(var)) {
      value <- get(var)
      expect_true(value > 0 && value == floor(value),
                  info = paste(var, "should be positive integer"))
    }
  }
})

test_that("Cache constants have reasonable values", {
  source("../../constants.R", local = TRUE)
  expect_true(CACHE_MAX_SIZE >= 10 && CACHE_MAX_SIZE <= 10000)
  expect_true(CACHE_MAX_AGE_SECONDS >= 60)
})

test_that("Workflow constants match expected step count", {
  source("../../constants.R", local = TRUE)
  expect_equal(WORKFLOW_TOTAL_STEPS, 8)
  expect_equal(WORKFLOW_MIN_STEP, 1)
  expect_equal(WORKFLOW_MAX_STEP, 8)
  expect_length(WORKFLOW_STEP_NAMES, 8)
})

# =============================================================================
# Consistency Tests (config.R vs constants.R)
# =============================================================================

test_that("Language settings are consistent", {
  source("../../config.R", local = TRUE)
  source("../../constants.R", local = TRUE)
  
  config_languages <- APP_CONFIG$LANGUAGES$SUPPORTED
  constant_languages <- SUPPORTED_LANGUAGES
  
  expect_equal(sort(config_languages), sort(constant_languages),
               info = "Languages in config.R and constants.R should match")
})

test_that("Version constants match config", {
  source("../../config.R", local = TRUE)
  source("../../constants.R", local = TRUE)
  
  expect_equal(APP_CONFIG$VERSION, APP_VERSION,
               info = "APP_CONFIG VERSION should match APP_VERSION constant")
})

# =============================================================================
# Helper Function Tests
# =============================================================================

test_that("get_config function works correctly", {
  source("../../config.R", local = TRUE)
  
  # Test valid path
  version <- get_config(c("VERSION"))
  expect_equal(version, APP_CONFIG$VERSION)
  
  # Test nested path
  primary_color <- get_config(c("THEME", "PRIMARY_COLOR"))
  expect_equal(primary_color, APP_CONFIG$THEME$PRIMARY_COLOR)
  
  # Test default value for missing path
  missing <- get_config(c("NONEXISTENT", "PATH"), default = "default_value")
  expect_equal(missing, "default_value")
})

test_that("get_risk_level function returns correct levels", {
  source("../../config.R", local = TRUE)
  
  high_risk <- get_risk_level(0.8)
  expect_equal(high_risk$label, "High Risk")
  
  medium_risk <- get_risk_level(0.5)
  expect_equal(medium_risk$label, "Medium Risk")
  
  low_risk <- get_risk_level(0.2)
  expect_equal(low_risk$label, "Low Risk")
})

test_that("get_node_color returns valid colors", {
  source("../../constants.R", local = TRUE)
  
  hex_pattern <- "^#[0-9A-Fa-f]{6}$"
  expect_true(grepl(hex_pattern, get_node_color("activity")))
  expect_true(grepl(hex_pattern, get_node_color("pressure")))
  expect_true(grepl(hex_pattern, get_node_color("consequence")))
})

# =============================================================================
# Required Files Validation
# =============================================================================

test_that("Required files list contains essential files", {
  source("../../config.R", local = TRUE)
  
  essential_files <- c("app.R", "global.R", "ui.R", "server.R", "config.R")
  for (file in essential_files) {
    expect_true(file %in% APP_CONFIG$REQUIRED_FILES,
                info = paste(file, "should be in REQUIRED_FILES"))
  }
})
