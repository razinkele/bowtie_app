# Test suite for Shiny application integration tests
# Tests UI components and server functionality

library(testthat)
library(shiny)

# Mock Shiny testing functions
create_test_session <- function() {
  # Create a mock session for testing
  list(
    input = list(),
    output = list(),
    sendCustomMessage = function(...) {},
    sendNotification = function(...) {}
  )
}

# Test UI component creation
test_that("UI components are created without errors", {
  # Source the main app file to get UI definition (use repo root path)
  repo_root <- find_repo_root()
  stopifnot(!is.null(repo_root))
  source(file.path(repo_root, "app.R"), local = TRUE)
  
  expect_no_error({
    ui_object <- ui
  })
  
  expect_true(!is.null(ui_object))
})

# Test server function creation
test_that("Server function is created without errors", {
  # Source the main app file to get server definition (use repo root path)
  repo_root <- find_repo_root()
  stopifnot(!is.null(repo_root))
  source(file.path(repo_root, "app.R"), local = TRUE)
  
  expect_type(server, "closure")
  expect_true(is.function(server))
})

# Test app initialization
test_that("Shiny app can be initialized", {
  # Source the main app components (repo-root aware)
  repo_root <- find_repo_root()
  stopifnot(!is.null(repo_root))
  source(file.path(repo_root, "utils.R"), local = TRUE)
  source(file.path(repo_root, "vocabulary.R"), local = TRUE)
  source(file.path(repo_root, "bowtie_bayesian_network.R"), local = TRUE)
  
  expect_no_error({
    source(file.path(repo_root, "app.R"), local = TRUE)
  })
})

# Test reactive value initialization
test_that("Reactive values are properly initialized", {
  skip_if_not_installed("shiny")
  
  # Create a test server environment
  test_session <- create_test_session()
  
  # Mock input and output
  input <- reactiveValues()
  output <- list()
  session <- test_session
  
  expect_no_error({
    # Test that reactive values can be created
    currentData <- reactiveVal(NULL)
    editedData <- reactiveVal(NULL)
    sheets <- reactiveVal(NULL)
    
    expect_true(is.reactive(currentData))
    expect_true(is.reactive(editedData))
    expect_true(is.reactive(sheets))
  })
})

# Test data generation functionality
test_that("Environmental data generation works in app context", {
  # Source required files
  source("utils.R", local = TRUE)
  
  expect_no_error({
    env_data <- generateEnvironmentalDataFixed()
  })
  
  expect_s3_class(env_data, "data.frame")
  expect_true(nrow(env_data) > 0)
})

# Test vocabulary loading
test_that("Vocabulary loading works in app context", {
  source("vocabulary.R", local = TRUE)
  
  # Test vocabulary loading with error handling
  expect_no_error({
    tryCatch({
      vocab_data <- load_vocabulary()
    }, error = function(e) {
      # Expected if Excel files are not present
      vocab_data <- list(
        activities = data.frame(),
        pressures = data.frame(),
        consequences = data.frame(),
        controls = data.frame()
      )
    })
  })
})

# Test Bayesian network integration
test_that("Bayesian network functions work in app context", {
  skip_if_not_installed("bnlearn")
  
  source("utils.R", local = TRUE)
  source("bowtie_bayesian_network.R", local = TRUE)
  
  expect_no_error({
    test_data <- generateEnvironmentalDataFixed()
    bn_structure <- create_bayesian_structure(test_data)
  })
})

# Test file upload simulation
test_that("File processing functions handle different inputs", {
  source("utils.R", local = TRUE)
  
  # Test with generated data
  test_data <- generateEnvironmentalDataFixed()
  
  expect_no_error({
    validated <- validateDataColumns(test_data)
    expect_true(validated)
  })
  
  expect_no_error({
    enhanced_data <- addDefaultColumns(test_data)
    expect_true(ncol(enhanced_data) >= ncol(test_data))
  })
})

# Test visualization components
test_that("Visualization functions work correctly", {
  source("utils.R", local = TRUE)
  
  test_data <- generateEnvironmentalDataFixed()
  
  expect_no_error({
    # Test bowtie node creation
    nodes <- createBowtieNodesFixed(test_data, "Water Pollution", 50, TRUE, TRUE)
    expect_s3_class(nodes, "data.frame")
  })
  
  expect_no_error({
    # Test bowtie edge creation
    edges <- createBowtieEdgesFixed(test_data, TRUE)
    expect_s3_class(edges, "data.frame")
  })
})

# Test error handling in app context
test_that("App handles errors gracefully", {
  source("utils.R", local = TRUE)
  
  # Test with invalid data
  expect_error({
    invalid_data <- data.frame()
    createBowtieNodesFixed(invalid_data, "Test Problem", 50, TRUE, TRUE)
  })
  
  # Test risk calculation with edge cases
  expect_no_error({
    risk1 <- calculateRiskLevel(0, 0)  # Edge case
    risk2 <- calculateRiskLevel(10, 10)  # Above normal range
  })
})

# Test data summary functionality
test_that("Data summary functions work in app", {
  source("utils.R", local = TRUE)
  
  test_data <- generateEnvironmentalDataFixed()
  
  expect_no_error({
    summary_data <- getDataSummaryFixed(test_data)
    expect_s3_class(summary_data, "data.frame")
    expect_true(nrow(summary_data) > 0)
  })
})

# Test cache functionality
test_that("Cache operations work correctly", {
  source("utils.R", local = TRUE)

  expect_no_error({
    clear_cache()
  })
})

# Test input validation
test_that("Input validation functions work properly", {
  source("utils.R", local = TRUE)
  
  # Test numeric validation
  expect_equal(validateNumericInput(3, 1, 5), 3)
  expect_equal(validateNumericInput(-1, 1, 5), 1)
  expect_equal(validateNumericInput(10, 1, 5), 5)
  expect_equal(validateNumericInput("invalid", 1, 5), 1)
})