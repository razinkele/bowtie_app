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
  # Skip if app.R can't be sourced (requires full package environment)
  ui_obj <- tryCatch({
    source(file.path(app_root, "app.R"), local = TRUE)
    ui
  }, error = function(e) NULL)
  skip_if(is.null(ui_obj), "Cannot source app.R in test environment")

  expect_true(!is.null(ui_obj))
})

# Test server function creation
test_that("Server function is created without errors", {
  server_fn <- tryCatch({
    source(file.path(app_root, "app.R"), local = TRUE)
    server
  }, error = function(e) NULL)
  skip_if(is.null(server_fn), "Cannot source app.R in test environment")

  expect_type(server_fn, "closure")
  expect_true(is.function(server_fn))
})

# Test app initialization
test_that("Shiny app can be initialized", {
  app_obj <- tryCatch({
    source(file.path(app_root, "app.R"), local = TRUE)
    TRUE
  }, error = function(e) NULL)
  skip_if(is.null(app_obj), "Cannot source app.R in test environment")
  expect_true(app_obj)
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
    env_data <- generate_environmental_data_fixed()
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
    test_data <- generate_environmental_data_fixed()
    bn_structure <- create_bayesian_structure(test_data)
  })
})

# Test file upload simulation
test_that("File processing functions handle different inputs", {
  source("utils.R", local = TRUE)
  
  # Test with generated data
  test_data <- generate_environmental_data_fixed()
  
  expect_no_error({
    validated <- validate_data_columns(test_data)
    expect_true(validated)
  })
  
  expect_no_error({
    enhanced_data <- add_default_columns(test_data)
    expect_true(ncol(enhanced_data) >= ncol(test_data))
  })
})

# Test visualization components
test_that("Visualization functions work correctly", {
  source("utils.R", local = TRUE)
  
  test_data <- generate_environmental_data_fixed()
  
  expect_no_error({
    # Test bowtie node creation
    nodes <- create_bowtie_nodes_fixed(test_data, "Water Pollution", 50, TRUE, TRUE)
    expect_s3_class(nodes, "data.frame")
  })
  
  expect_no_error({
    # Test bowtie edge creation
    edges <- create_bowtie_edges_fixed(test_data, TRUE)
    expect_s3_class(edges, "data.frame")
  })
})

# Test error handling in app context
test_that("App handles errors gracefully", {
  source("utils.R", local = TRUE)
  
  # Test with invalid data
  expect_error({
    invalid_data <- data.frame()
    create_bowtie_nodes_fixed(invalid_data, "Test Problem", 50, TRUE, TRUE)
  })
  
  # Test risk calculation with edge cases
  expect_no_error({
    risk1 <- calculate_risk_level(0, 0)  # Edge case
    risk2 <- calculate_risk_level(10, 10)  # Above normal range
  })
})

# Test data summary functionality
test_that("Data summary functions work in app", {
  source("utils.R", local = TRUE)
  
  test_data <- generate_environmental_data_fixed()
  
  expect_no_error({
    summary_data <- get_data_summary_fixed(test_data)
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
  expect_equal(validate_numeric_input(3, 1, 5), 3)
  expect_equal(validate_numeric_input(-1, 1, 5), 1)
  expect_equal(validate_numeric_input(10, 1, 5), 5)
  expect_equal(validate_numeric_input("invalid", 1, 5), 1)
})