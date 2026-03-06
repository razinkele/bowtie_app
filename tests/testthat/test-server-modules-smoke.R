# =============================================================================
# Smoke Tests for Server Modules
# =============================================================================
# File: tests/testthat/test-server-modules-smoke.R
# Description: Basic smoke tests for all 13 server modules in server_modules/
# Tests: Module sourcing, file existence, syntax validation, function presence
# Coverage: ~50 assertions across 13 modules (~4 tests per module)
# =============================================================================

context("Server Modules Smoke Tests")

# Load required packages
library(testthat)

# =============================================================================
# Setup: Find server_modules directory
# =============================================================================

# Load the helper setup (provides app_root and utilities)
if (!exists("app_root")) {
  helper_path <- file.path(getwd(), "tests/testthat/helper-setup.R")
  if (file.exists(helper_path)) {
    source(helper_path)
  } else {
    # Fallback: try to find app root
    app_root <- getwd()
    if (!file.exists(file.path(app_root, "app.R"))) {
      app_root <- normalizePath(file.path(getwd(), "../.."), mustWork = FALSE)
    }
  }
}

# Define modules directory
modules_dir <- file.path(app_root, "server_modules")

# List of all 13 server modules with expected characteristics
server_modules <- list(
  ai_analysis_module = list(
    file = "ai_analysis_module.R",
    min_size = 15000,  # ~17KB
    description = "AI suggestions and analysis"
  ),
  autosave_module = list(
    file = "autosave_module.R",
    min_size = 15000,  # ~18KB
    description = "Auto-save logic and scheduling"
  ),
  bayesian_module = list(
    file = "bayesian_module.R",
    min_size = 18000,  # ~21KB
    description = "Bayesian network UI and analysis"
  ),
  bowtie_visualization_module = list(
    file = "bowtie_visualization_module.R",
    min_size = 12000,  # ~14KB
    description = "Diagram rendering and visualization"
  ),
  data_management_module = list(
    file = "data_management_module.R",
    min_size = 9000,   # ~10KB
    description = "Data CRUD operations"
  ),
  export_module = list(
    file = "export_module.R",
    min_size = 8000,   # ~9KB
    description = "Export functionality"
  ),
  help_module = list(
    file = "help_module.R",
    min_size = 17000,  # ~19KB
    description = "Documentation and help system"
  ),
  language_module = list(
    file = "language_module.R",
    min_size = 3500,   # ~4KB
    description = "Internationalization (i18n)"
  ),
  link_risk_module = list(
    file = "link_risk_module.R",
    min_size = 23000,  # ~25KB
    description = "Risk assessment and linking"
  ),
  local_storage_module = list(
    file = "local_storage_module.R",
    min_size = 35000,  # ~39KB
    description = "Data persistence and storage"
  ),
  report_generation_module = list(
    file = "report_generation_module.R",
    min_size = 25000,  # ~28KB
    description = "Report exports and generation"
  ),
  theme_module = list(
    file = "theme_module.R",
    min_size = 8000,   # ~9KB
    description = "Theme switching"
  ),
  vocabulary_server_module = list(
    file = "vocabulary_server_module.R",
    min_size = 18000,  # ~20KB
    description = "Vocabulary CRUD operations"
  )
)

# =============================================================================
# Test Helper: Safe Module Sourcing
# =============================================================================

#' Safely source a module file without polluting global environment
#' @param module_path Path to the module file
#' @return List with success status and any error message
safe_source_module <- function(module_path) {
  tryCatch({
    local_env <- new.env(parent = globalenv())
    source(module_path, local = local_env)
    list(success = TRUE, error = NULL, env = local_env)
  }, error = function(e) {
    list(success = FALSE, error = conditionMessage(e), env = NULL)
  })
}

# =============================================================================
# Test 1: Modules Directory Exists
# =============================================================================

test_that("server_modules directory exists and contains expected files", {
  expect_true(dir.exists(modules_dir),
              info = paste("Modules directory should exist:", modules_dir))

  # List all R files in directory
  files_found <- list.files(modules_dir, pattern = "\\.R$", full.names = FALSE)

  expect_true(length(files_found) >= 13,
              info = "Should have at least 13 module files")

  # Verify each expected module file exists
  for (module_name in names(server_modules)) {
    expected_file <- server_modules[[module_name]]$file
    expect_true(expected_file %in% files_found,
                info = paste("Module file should exist:", expected_file))
  }
})

# =============================================================================
# Test 2: File Existence and Size Tests (All Modules)
# =============================================================================

describe("Module File Existence and Size Validation", {

  for (module_name in names(server_modules)) {
    module_info <- server_modules[[module_name]]
    file_path <- file.path(modules_dir, module_info$file)

    it(paste0(module_info$file, " exists and has expected content size"), {
      # File existence
      expect_true(file.exists(file_path),
                  info = paste("File should exist:", module_info$file))

      # File size check - testthat 3.x compatible
      file_size <- file.info(file_path)$size
      expect_true(file_size > 0,
                  info = paste("File should not be empty:", module_info$file))
      expect_true(file_size >= module_info$min_size,
                  info = paste("File size should be at least", module_info$min_size,
                               "bytes for:", module_info$file))
    })
  }
})

# =============================================================================
# Test 3: R Syntax Validation Tests (All Modules)
# =============================================================================

describe("Module R Syntax Validation", {

  for (module_name in names(server_modules)) {
    module_info <- server_modules[[module_name]]
    file_path <- file.path(modules_dir, module_info$file)

    it(paste0(module_info$file, " has valid R syntax"), {
      skip_if_not(file.exists(file_path),
                  message = paste("File does not exist:", module_info$file))

      # Use parse() to validate syntax - will error on syntax issues
      parsed <- NULL
      parse_error <- tryCatch({
        parsed <- parse(file_path)
        NULL
      }, error = function(e) {
        conditionMessage(e)
      })

      expect_null(parse_error,
                  info = paste("R syntax validation failed for:", module_info$file,
                               "Error:", parse_error %||% "none"))

      # Verify parse returned expressions
      expect_true(length(parsed) > 0,
                  info = paste("Parsed file should contain expressions:", module_info$file))
    })
  }
})

# =============================================================================
# Test 4: Module Sourcing Tests (All Modules)
# =============================================================================

describe("Module Sourcing Without Error", {

  # Skip entire section if essential packages missing
  skip_if_not_installed("shiny")

  for (module_name in names(server_modules)) {
    module_info <- server_modules[[module_name]]
    file_path <- file.path(modules_dir, module_info$file)

    it(paste0(module_info$file, " can be sourced without fatal errors"), {
      skip_if_not(file.exists(file_path),
                  message = paste("File does not exist:", module_info$file))

      # Some modules require specific packages - skip gracefully if missing
      skip_if_not_installed("shiny")

      # Module-specific dependency checks
      if (module_name == "local_storage_module") {
        skip_if_not_installed("shinyFiles")
      }
      if (module_name == "bayesian_module") {
        skip_if_not_installed("bnlearn")
      }
      if (module_name == "export_module" || module_name == "report_generation_module") {
        skip_if_not_installed("openxlsx")
      }

      # Attempt to source the module
      result <- safe_source_module(file_path)

      expect_true(result$success,
                  info = paste("Module should source without error:", module_info$file,
                               "Error:", result$error %||% "none"))
    })
  }
})

# =============================================================================
# Test 5: Individual Module Deep Tests
# =============================================================================

# --- ai_analysis_module.R ---
test_that("ai_analysis_module.R structure is valid", {
  file_path <- file.path(modules_dir, "ai_analysis_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for expected patterns in AI analysis module
  expect_true(grepl("function", content_str, ignore.case = FALSE),
              info = "Module should contain function definitions")
  expect_true(grepl("observeEvent|observe|reactive", content_str),
              info = "Module should contain Shiny reactive patterns")
})

# --- autosave_module.R ---
test_that("autosave_module.R structure is valid", {
  file_path <- file.path(modules_dir, "autosave_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for autosave-specific patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("save|autosave|interval", content_str, ignore.case = TRUE),
              info = "Module should contain save-related logic")
})

# --- bayesian_module.R ---
test_that("bayesian_module.R structure is valid", {
  file_path <- file.path(modules_dir, "bayesian_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for Bayesian network patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("bayesian|network|bn|node|cpt", content_str, ignore.case = TRUE),
              info = "Module should contain Bayesian network terminology")
})

# --- bowtie_visualization_module.R ---
test_that("bowtie_visualization_module.R structure is valid", {
  file_path <- file.path(modules_dir, "bowtie_visualization_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for visualization patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("visual|render|diagram|bowtie|plot", content_str, ignore.case = TRUE),
              info = "Module should contain visualization terminology")
})

# --- data_management_module.R ---
test_that("data_management_module.R structure is valid", {
  file_path <- file.path(modules_dir, "data_management_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for data management patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("data|add|remove|update|delete|manage", content_str, ignore.case = TRUE),
              info = "Module should contain data management terminology")
})

# --- export_module.R ---
test_that("export_module.R structure is valid", {
  file_path <- file.path(modules_dir, "export_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for export patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("export|download|xlsx|excel|file", content_str, ignore.case = TRUE),
              info = "Module should contain export terminology")
})

# --- help_module.R ---
test_that("help_module.R structure is valid", {
  file_path <- file.path(modules_dir, "help_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for help/documentation patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("help|documentation|guide|tutorial|modal", content_str, ignore.case = TRUE),
              info = "Module should contain help/documentation terminology")
})

# --- language_module.R ---
test_that("language_module.R structure is valid", {
  file_path <- file.path(modules_dir, "language_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for i18n patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("language|lang|translate|i18n|en|fr", content_str, ignore.case = TRUE),
              info = "Module should contain internationalization terminology")
})

# --- link_risk_module.R ---
test_that("link_risk_module.R structure is valid", {
  file_path <- file.path(modules_dir, "link_risk_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for risk assessment patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("risk|link|matrix|likelihood|impact|severity", content_str, ignore.case = TRUE),
              info = "Module should contain risk assessment terminology")
})

# --- local_storage_module.R ---
test_that("local_storage_module.R structure is valid", {
  file_path <- file.path(modules_dir, "local_storage_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for storage patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("storage|save|load|file|path|rds|json", content_str, ignore.case = TRUE),
              info = "Module should contain storage terminology")
})

# --- report_generation_module.R ---
test_that("report_generation_module.R structure is valid", {
  file_path <- file.path(modules_dir, "report_generation_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for report generation patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("report|generate|pdf|excel|html|markdown", content_str, ignore.case = TRUE),
              info = "Module should contain report generation terminology")
})

# --- theme_module.R ---
test_that("theme_module.R structure is valid", {
  file_path <- file.path(modules_dir, "theme_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for theme patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("theme|bootstrap|bslib|css|style|color", content_str, ignore.case = TRUE),
              info = "Module should contain theme terminology")
})

# --- vocabulary_server_module.R ---
test_that("vocabulary_server_module.R structure is valid", {
  file_path <- file.path(modules_dir, "vocabulary_server_module.R")
  skip_if_not(file.exists(file_path))

  content <- readLines(file_path, warn = FALSE)
  content_str <- paste(content, collapse = "\n")

  # Check for vocabulary patterns
  expect_true(grepl("function", content_str),
              info = "Module should contain function definitions")
  expect_true(grepl("vocabulary|activities|pressures|controls|consequences", content_str, ignore.case = TRUE),
              info = "Module should contain vocabulary terminology")
})

# =============================================================================
# Test 6: Module Integration Checks
# =============================================================================

test_that("all modules follow consistent naming conventions", {
  for (module_name in names(server_modules)) {
    module_file <- server_modules[[module_name]]$file

    # All module files should end with _module.R
    expect_match(module_file, "_module\\.R$",
                 info = paste("Module should follow naming convention:", module_file))
  }
})

test_that("modules do not have duplicate filenames", {
  files <- sapply(server_modules, function(m) m$file)

  expect_equal(length(files), length(unique(files)),
               info = "All module filenames should be unique")
})

test_that("module file sizes are within expected ranges", {
  # Verify no module is suspiciously small (likely incomplete or empty)
  for (module_name in names(server_modules)) {
    file_path <- file.path(modules_dir, server_modules[[module_name]]$file)

    if (file.exists(file_path)) {
      file_size <- file.info(file_path)$size

      expect_true(file_size > 1000,
                  info = paste("Module should be > 1KB:", server_modules[[module_name]]$file))
      expect_true(file_size < 100000,
                  info = paste("Module should be < 100KB:", server_modules[[module_name]]$file))
    }
  }
})

# =============================================================================
# Test 7: Cross-Module Dependency Sanity Check
# =============================================================================

test_that("modules do not have obvious circular references in file content", {
  # Simple check: ensure modules don't source each other directly
  # (they should use proper Shiny module patterns)

  for (module_name in names(server_modules)) {
    file_path <- file.path(modules_dir, server_modules[[module_name]]$file)

    if (file.exists(file_path)) {
      content <- readLines(file_path, warn = FALSE)
      content_str <- paste(content, collapse = "\n")

      # Check for direct source() calls to other server modules
      # This is a heuristic - direct sourcing of sibling modules is usually bad practice
      has_source_calls <- grepl('source\\s*\\(.*_module\\.R', content_str)

      expect_false(has_source_calls,
                   info = paste("Module should not directly source other server modules:",
                                server_modules[[module_name]]$file))
    }
  }
})

# =============================================================================
# Summary Statistics
# =============================================================================

test_that("smoke test summary statistics are recorded", {
  total_modules <- length(server_modules)
  total_assertions_per_module <- 4  # Approximately
  expected_total <- total_modules * total_assertions_per_module

  expect_equal(total_modules, 13,
               info = "Should have exactly 13 server modules defined")

  # Record summary for reporting
  cat("\n")
  cat("=== Server Modules Smoke Test Summary ===\n")
  cat(sprintf("Total modules tested: %d\n", total_modules))
  cat(sprintf("Estimated assertions: %d\n", expected_total))
  cat("==========================================\n")
})
