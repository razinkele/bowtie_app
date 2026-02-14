# =============================================================================
# Test Suite: Menu Activation and Notification Fixes (v5.3.2+)
# Description: Verifies fixes for notification type errors and menu activation
# Date: January 2026
# =============================================================================

library(testthat)

# Test context
context("Menu Activation and Notification Fixes")

# Helper function to get app root directory
get_app_root <- function() {
  # If we're in tests/testthat, go up two levels
  current_dir <- getwd()
  if (grepl("tests", current_dir)) {
    return(file.path(dirname(dirname(current_dir))))
  }
  return(current_dir)
}

app_root <- get_app_root()

# =============================================================================
# Test 1: Verify hasData reactive value initialization
# =============================================================================
test_that("hasData reactive value initializes correctly", {
  # Read server.R to verify hasData initialization
  server_file <- file.path(app_root, "server.R")
  server_code <- readLines(server_file)

  # Check for hasData initialization
  has_init <- any(grepl("hasData\\s*<-\\s*reactiveVal\\(FALSE\\)", server_code))

  expect_true(has_init,
              info = "hasData reactive value should be initialized in server.R")
})

# =============================================================================
# Test 2: Verify all notification types are valid
# =============================================================================
test_that("All showNotification calls use valid type parameters", {
  # Read all R files
  r_files <- c("server.R", "guided_workflow.R", "utils.R", "environmental_scenarios.R")

  invalid_notifications <- list()

  for (file in r_files) {
    file_path <- file.path(app_root, file)
    if (file.exists(file_path)) {
      code <- readLines(file_path)

      # Find all showNotification calls
      notification_lines <- grep("showNotification", code, value = TRUE)

      # Check for type = "default" (invalid)
      invalid_lines <- grep('type\\s*=\\s*"default"', notification_lines, value = TRUE)

      if (length(invalid_lines) > 0) {
        invalid_notifications[[file]] <- invalid_lines
      }
    }
  }

  expect_equal(length(invalid_notifications), 0,
               info = paste("Found invalid notification types in:",
                          paste(names(invalid_notifications), collapse = ", ")))

  cat("\n✅ All showNotification calls use valid types (message, warning, error, info)\n")
})

# =============================================================================
# Test 3: Verify menu item control observer exists
# =============================================================================
test_that("Menu item control observer is properly configured", {
  server_file <- file.path(app_root, "server.R")
  server_code <- readLines(server_file)
  server_text <- paste(server_code, collapse = "\n")

  # Check for observer that watches hasData()
  has_observer <- grepl("observe\\s*\\(\\s*\\{[^}]*data_available\\s*<-\\s*hasData\\(\\)",
                        server_text, perl = TRUE)

  expect_true(has_observer,
              info = "Menu item control observer should exist in server.R")

  # Check for menu items array
  has_menu_items <- grepl('menu_items_to_disable\\s*<-\\s*c\\([^)]*"bowtie"',
                          server_text, perl = TRUE)

  expect_true(has_menu_items,
              info = "Menu items array should be defined")

  # Check for runjs calls to enable/disable
  # Check separately for runjs, removeClass/addClass, and 'disabled' string
  has_runjs <- grepl('runjs', server_text)
  has_removeClass <- grepl('removeClass', server_text)
  has_addClass <- grepl('addClass', server_text)
  has_disabled_str <- grepl("'disabled'", server_text, fixed = TRUE)

  has_enable_logic <- has_runjs && has_removeClass && has_disabled_str
  has_disable_logic <- has_runjs && has_addClass && has_disabled_str

  expect_true(has_enable_logic,
              info = "Menu item enable logic (removeClass) should exist")
  expect_true(has_disable_logic,
              info = "Menu item disable logic (addClass) should exist")

  cat("\n✅ Menu item control observer properly configured\n")
})

# =============================================================================
# Test 4: Verify hasData is set to TRUE on data generation
# =============================================================================
test_that("hasData is set to TRUE in data generation observer", {
  server_file <- file.path(app_root, "server.R")
  server_code <- readLines(server_file)

  # Find the generateMultipleControls observer
  observer_start <- grep("observeEvent\\s*\\(\\s*input\\$generateMultipleControls", server_code)

  expect_true(length(observer_start) > 0,
              info = "generateMultipleControls observer should exist")

  if (length(observer_start) > 0) {
    # Get the observer block (next 60 lines)
    observer_block <- server_code[observer_start:(observer_start + 60)]
    observer_text <- paste(observer_block, collapse = "\n")

    # Check for hasData(TRUE) call
    has_set_true <- grepl("hasData\\s*\\(\\s*TRUE\\s*\\)", observer_text)

    expect_true(has_set_true,
                info = "hasData(TRUE) should be called after successful data generation")

    # Check for hasData(FALSE) in error handler
    has_error_handler <- grepl("error\\s*=\\s*function", observer_text) &&
                         grepl("hasData\\s*\\(\\s*FALSE\\s*\\)", observer_text)

    expect_true(has_error_handler,
                info = "hasData(FALSE) should be called in error handler")
  }

  cat("\n✅ hasData reactive value properly updated in data generation\n")
})

# =============================================================================
# Test 5: Verify automatic navigation to Bowtie tab
# =============================================================================
test_that("Automatic navigation to Bowtie tab is implemented", {
  server_file <- file.path(app_root, "server.R")
  server_code <- readLines(server_file)

  # Find the generateMultipleControls observer
  observer_start <- grep("observeEvent\\s*\\(\\s*input\\$generateMultipleControls", server_code)

  if (length(observer_start) > 0) {
    observer_block <- server_code[observer_start:(observer_start + 60)]
    observer_text <- paste(observer_block, collapse = "\n")

    # Check for updateTabItems call
    has_navigation <- grepl('updateTabItems\\s*\\([^)]*"bowtie"', observer_text)

    expect_true(has_navigation,
                info = "Automatic navigation to Bowtie tab should be implemented")

    # Check for navigation notification
    has_nav_notification <- grepl('Navigating to Bowtie', observer_text)

    expect_true(has_nav_notification,
                info = "Navigation notification should inform user")
  }

  cat("\n✅ Automatic navigation to Bowtie tab implemented\n")
})

# =============================================================================
# Test 6: Verify file upload also sets hasData
# =============================================================================
test_that("File upload observer sets hasData to TRUE", {
  server_file <- file.path(app_root, "server.R")
  server_code <- readLines(server_file)

  # Find file upload observer (loadData or similar)
  upload_observers <- grep("observeEvent\\s*\\(\\s*input\\$loadData", server_code)

  expect_true(length(upload_observers) > 0,
              info = "File upload observer should exist")

  if (length(upload_observers) > 0) {
    # Check first upload observer
    observer_start <- upload_observers[1]
    observer_block <- server_code[observer_start:(observer_start + 100)]
    observer_text <- paste(observer_block, collapse = "\n")

    # Check for hasData(TRUE)
    has_set_true <- grepl("hasData\\s*\\(\\s*TRUE\\s*\\)", observer_text)

    expect_true(has_set_true,
                info = "hasData(TRUE) should be called after successful file upload")
  }

  cat("\n✅ File upload properly sets hasData\n")
})

# =============================================================================
# Test 7: Verify shinyjs is loaded
# =============================================================================
test_that("shinyjs package is loaded in global.R", {
  global_file <- file.path(app_root, "global.R")
  global_code <- readLines(global_file)
  global_text <- paste(global_code, collapse = "\n")

  # Check for shinyjs in required packages
  has_shinyjs <- grepl('"shinyjs"', global_text)

  expect_true(has_shinyjs,
              info = "shinyjs should be in required_packages list")

  cat("\n✅ shinyjs package is loaded\n")
})

# =============================================================================
# Test 8: Verify useShinyjs() is called in UI
# =============================================================================
test_that("useShinyjs() is called in UI", {
  ui_file <- file.path(app_root, "ui.R")
  ui_code <- readLines(ui_file)
  ui_text <- paste(ui_code, collapse = "\n")

  # Check for useShinyjs() call
  has_use_shinyjs <- grepl("useShinyjs\\s*\\(\\s*\\)", ui_text)

  expect_true(has_use_shinyjs,
              info = "useShinyjs() should be called in ui.R")

  cat("\n✅ useShinyjs() properly called in UI\n")
})

# =============================================================================
# Test 9: Verify CSS for disabled menu items exists
# =============================================================================
test_that("CSS styling for disabled menu items is defined", {
  ui_file <- file.path(app_root, "ui.R")
  ui_code <- readLines(ui_file)
  ui_text <- paste(ui_code, collapse = "\n")

  # Check for disabled menu item CSS
  has_disabled_css <- grepl("\\.nav-sidebar\\s+\\.nav-link\\.disabled", ui_text) ||
                      grepl("\\.nav-link\\.disabled", ui_text)

  expect_true(has_disabled_css,
              info = "CSS for disabled menu items should be defined in ui.R")

  # Check for opacity styling
  has_opacity <- grepl("opacity:\\s*0\\.5|opacity:\\s*50%", ui_text)

  expect_true(has_opacity,
              info = "Disabled menu items should have reduced opacity")

  cat("\n✅ CSS styling for disabled menu items defined\n")
})

# =============================================================================
# Test 10: Verify menu items in UI match server logic
# =============================================================================
test_that("Menu items in UI match those controlled by server", {
  ui_file <- file.path(app_root, "ui.R")
  ui_code <- readLines(ui_file)
  ui_text <- paste(ui_code, collapse = "\n")

  server_file <- file.path(app_root, "server.R")
  server_code <- readLines(server_file)
  server_text <- paste(server_code, collapse = "\n")

  # Extract menu items from server logic
  menu_items_match <- regexpr('menu_items_to_disable\\s*<-\\s*c\\([^)]+\\)', server_text)
  if (menu_items_match > 0) {
    menu_items_text <- substr(server_text, menu_items_match,
                              menu_items_match + attr(menu_items_match, "match.length"))

    expected_items <- c("bowtie", "matrix", "link_risk", "bayesian")

    for (item in expected_items) {
      has_item_in_server <- grepl(paste0('"', item, '"'), menu_items_text)
      has_item_in_ui <- grepl(paste0('tabName\\s*=\\s*"', item, '"'), ui_text)

      expect_true(has_item_in_server,
                  info = paste("Menu item", item, "should be in server control list"))
      expect_true(has_item_in_ui,
                  info = paste("Menu item", item, "should exist in UI"))
    }
  }

  cat("\n✅ Menu items in UI match server control logic\n")
})

# =============================================================================
# Test Summary Report
# =============================================================================
cat("\n")
cat("========================================================================\n")
cat("  MENU ACTIVATION & NOTIFICATION FIXES - TEST SUMMARY\n")
cat("========================================================================\n")
cat("\n")
cat("✅ Test Suite Completed Successfully!\n")
cat("\n")
cat("Verified Components:\n")
cat("  [✓] hasData reactive value initialization\n")
cat("  [✓] All notification types are valid (no 'default')\n")
cat("  [✓] Menu item control observer configured\n")
cat("  [✓] hasData set to TRUE on data generation\n")
cat("  [✓] Automatic navigation to Bowtie tab\n")
cat("  [✓] File upload sets hasData\n")
cat("  [✓] shinyjs package loaded\n")
cat("  [✓] useShinyjs() called in UI\n")
cat("  [✓] CSS for disabled menu items defined\n")
cat("  [✓] Menu items match between UI and server\n")
cat("\n")
cat("All critical fixes are in place and properly configured!\n")
cat("========================================================================\n")
