# Integration tests for complete vocabulary bow-tie generation workflow
# Tests the full end-to-end process from vocabulary to Excel output

library(testthat)

# Source required files (use repo-root-aware helper)
repo_root <- find_repo_root()
if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
source(file.path(repo_root, "tests", "fixtures", "test_data.R"), local = TRUE)

# Test complete workflow integration
test_that("complete vocabulary bowtie workflow works end-to-end", {
  skip_if_not_installed("openxlsx")
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  
  # Source the generator (repo-root aware)
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  
  # Create temporary file
  temp_file <- get_test_temp_file(".xlsx")
  
  # Run complete workflow
  expect_no_error({
    result <- generate_vocabulary_bowtie(
      central_problems = c("Water Pollution"),
      output_file = temp_file,
      similarity_threshold = 0.4,
      max_connections_per_item = 2,
      use_ai_linking = FALSE  # Disable for consistent testing
    )
  })
  
  # Validate results
  expect_type(result, "list")
  expect_true("data" %in% names(result))
  expect_true("file" %in% names(result))
  expect_true("vocabulary_used" %in% names(result))
  
  # Validate generated data
  validation <- validate_bowtie_data_structure(result$data)
  expect_true(validation$valid, info = paste("Validation failed:", paste(names(validation$checks)[!unlist(validation$checks)], collapse = ", ")))
  
  # Validate file was created
  expect_true(file.exists(temp_file))
  
  # Test file can be read back
  expect_no_error({
    read_back <- read.xlsx(temp_file, sheet = "Bowtie_Data")
  })
  
  # Clean up
  cleanup_test_files(temp_file)
})

# Test workflow with different scenarios
test_that("workflow handles different generation scenarios", {
  skip_if_not_installed("openxlsx")
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  
  # If tests provide a local shim, prefer the real generator in repo root
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  scenarios <- get_bowtie_test_scenarios()
  
  for (scenario_name in c("minimal", "standard")) {  # Test subset for performance
    scenario <- scenarios[[scenario_name]]
    temp_file <- get_test_temp_file(".xlsx")
    
    expect_no_error({
      result <- generate_vocabulary_bowtie(
        central_problems = scenario$central_problems,
        output_file = temp_file,
        similarity_threshold = scenario$similarity_threshold,
        max_connections_per_item = scenario$max_connections,
        use_ai_linking = FALSE
      )
    }, info = paste("Scenario failed:", scenario_name))
    
    expect_true(file.exists(temp_file), info = paste("File not created for scenario:", scenario_name))
    cleanup_test_files(temp_file)
  }
})

# Test vocabulary loading integration
test_that("workflow integrates correctly with vocabulary system", {
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  
  # Test with mock vocabulary data
  mock_vocab <- create_test_vocabulary_for_bowtie()
  
  expect_no_error({
    result <- create_problem_specific_bowtie(
      "Water Pollution",
      mock_vocab,
      create_test_vocabulary_links(),
      max_connections = 2
    )
  })
  
  expect_s3_class(result, "data.frame")
  expect_true("Problem" %in% names(result))
  expect_true(all(result$Problem == "Water Pollution"))
})

# Test AI linking integration (if available)
test_that("workflow integrates with AI linking when available", {
  skip_if_not(exists("find_vocabulary_links"), "AI linking functions not available")
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  skip_if_not_installed("openxlsx")
  
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  temp_file <- get_test_temp_file(".xlsx")
  
  expect_no_error({
    result <- generate_vocabulary_bowtie(
      central_problems = c("Water Pollution"),
      output_file = temp_file,
      use_ai_linking = TRUE,
      similarity_threshold = 0.5,
      max_connections_per_item = 2
    )
  })
  
  # Check that links were generated
  expect_true("links_generated" %in% names(result))
  if (!is.null(result$links_generated)) {
    expect_s3_class(result$links_generated, "data.frame")
  }
  
  cleanup_test_files(temp_file)
})

# Test error handling in complete workflow
test_that("workflow handles errors gracefully", {
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  skip_if_not_installed("openxlsx")
  
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  
  # Test with invalid output path (simulate un-writable parent by using a file as the parent directory)
  tmp_parent_file <- tempfile()
  file.create(tmp_parent_file)
  invalid_path <- file.path(tmp_parent_file, "test.xlsx")
  
  expect_error({
    result <- generate_vocabulary_bowtie(
      central_problems = c("Water Pollution"),
      output_file = invalid_path,
      use_ai_linking = FALSE
    )
  })
  
  # Test with empty problems list
  temp_file <- get_test_temp_file(".xlsx")
  
  expect_no_error({
    result <- generate_vocabulary_bowtie(
      central_problems = character(0),
      output_file = temp_file,
      use_ai_linking = FALSE
    )
  })
  
  cleanup_test_files(temp_file)
})

# Test performance with larger datasets
test_that("workflow performs adequately with larger vocabularies", {
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  skip_if_not_installed("openxlsx")
  skip("Performance test - run manually if needed")
  
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  
  # Create larger vocabulary dataset
  large_vocab <- create_large_vocabulary_dataset(size_multiplier = 5)
  temp_file <- get_test_temp_file(".xlsx")
  
  start_time <- Sys.time()
  
  expect_no_error({
    # Override the vocabulary loading for this test
    result <- generate_vocabulary_bowtie(
      central_problems = c("Water Pollution", "Air Quality"),
      output_file = temp_file,
      use_ai_linking = FALSE,
      max_connections_per_item = 3
    )
  })
  
  end_time <- Sys.time()
  execution_time <- as.numeric(end_time - start_time, units = "secs")
  
  # Should complete within reasonable time (adjust threshold as needed)
  expect_true(execution_time < 60, info = paste("Execution took", execution_time, "seconds"))
  
  cleanup_test_files(temp_file)
})

# Test data quality and consistency
test_that("generated data maintains quality and consistency", {
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  skip_if_not_installed("openxlsx")
  
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  temp_file <- get_test_temp_file(".xlsx")
  
  result <- generate_vocabulary_bowtie(
    central_problems = c("Water Pollution", "Climate Change"),
    output_file = temp_file,
    use_ai_linking = FALSE,
    max_connections_per_item = 3
  )
  
  data <- result$data
  
  # Test data quality
  expect_true(all(!is.na(data$Activity)), "Activities should not be NA")
  expect_true(all(!is.na(data$Pressure)), "Pressures should not be NA")
  expect_true(all(!is.na(data$Problem)), "Problems should not be NA")
  expect_true(all(!is.na(data$Consequence)), "Consequences should not be NA")
  
  # Test risk level consistency
  calculated_risk <- data$Threat_Likelihood * data$Consequence_Severity
  expect_equal(data$Risk_Level, calculated_risk, info = "Risk levels should match calculation")
  
  # Test risk rating consistency
  expected_ratings <- ifelse(calculated_risk <= 4, "Low",
                           ifelse(calculated_risk <= 9, "Medium",
                                 ifelse(calculated_risk <= 16, "High", "Very High")))
  expect_equal(data$Risk_Rating, expected_ratings, info = "Risk ratings should match categories")
  
  # Test central problems are correctly assigned
  expect_true(all(data$Problem %in% c("Water Pollution", "Climate Change")),
             "All problems should match input central problems")
  
  cleanup_test_files(temp_file)
})

# Test Excel file structure and readability
test_that("Excel output has correct structure for main app", {
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  skip_if_not_installed("openxlsx")
  
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  temp_file <- get_test_temp_file(".xlsx")
  
  result <- generate_vocabulary_bowtie(
    central_problems = c("Water Pollution"),
    output_file = temp_file,
    use_ai_linking = FALSE
  )
  
  # Test main data sheet
  main_data <- read.xlsx(temp_file, sheet = "Bowtie_Data")
  expect_s3_class(main_data, "data.frame")
  
  # Check required columns for main app compatibility
  required_for_app <- c("Activity", "Pressure", "Problem", "Consequence",
                       "Preventive_Control", "Protective_Mitigation", 
                       "Threat_Likelihood", "Consequence_Severity")
  expect_true(all(required_for_app %in% names(main_data)),
             info = paste("Missing columns for app:", paste(required_for_app[!required_for_app %in% names(main_data)], collapse = ", ")))
  
  # Test summary sheet exists
  expect_no_error({
    summary_data <- read.xlsx(temp_file, sheet = "Summary")
  })
  
  cleanup_test_files(temp_file)
})

# Test fallback mechanisms
test_that("workflow uses fallback mechanisms when needed", {
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  
  # Test fallback vocabulary creation
  fallback_vocab <- create_sample_vocabulary_data()
  expect_type(fallback_vocab, "list")
  expect_true(all(c("activities", "pressures", "consequences", "controls") %in% names(fallback_vocab)))
  
  # Test fallback items creation
  for (item_type in c("Activity", "Pressure", "Consequence", "Control")) {
    fallback_items <- create_fallback_items("Test Problem", item_type)
    expect_type(fallback_items, "character")
    expect_true(length(fallback_items) > 0)
    expect_true(any(grepl("test problem", fallback_items, ignore.case = TRUE)))
  }
})

# Test reproducibility
test_that("workflow produces consistent results", {
  skip_if_not(file.exists("vocabulary_bowtie_generator.r"), "vocabulary_bowtie_generator.r not available")
  skip_if_not_installed("openxlsx")
  
  repo_root <- find_repo_root()
  if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
  source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)
  
  # Set seed for reproducibility
  set.seed(12345)
  temp_file1 <- get_test_temp_file(".xlsx")
  result1 <- generate_vocabulary_bowtie(
    central_problems = c("Water Pollution"),
    output_file = temp_file1,
    use_ai_linking = FALSE
  )
  
  # Reset seed and generate again
  set.seed(12345)
  temp_file2 <- get_test_temp_file(".xlsx")
  result2 <- generate_vocabulary_bowtie(
    central_problems = c("Water Pollution"),
    output_file = temp_file2,
    use_ai_linking = FALSE
  )
  
  # Results should be similar (allowing for some randomness in sampling)
  expect_equal(nrow(result1$data), nrow(result2$data), 
              info = "Result sizes should be consistent")
  expect_equal(unique(result1$data$Problem), unique(result2$data$Problem),
              info = "Problems should be consistent")
  
  cleanup_test_files(c(temp_file1, temp_file2))
})