# Test suite for vocabulary_bowtie_generator.r
# Tests bow-tie network generation from vocabulary elements

library(testthat)

# Source the generator file from the repository root
repo_root <- find_repo_root()
if (is.null(repo_root)) repo_root <- normalizePath("..", mustWork = FALSE)
skip_if_not(file.exists(file.path(repo_root, "vocabulary_bowtie_generator.R")), "vocabulary_bowtie_generator.R not available")
source(file.path(repo_root, "vocabulary_bowtie_generator.R"), local = TRUE)

# Test main generation function
test_that("generate_vocabulary_bowtie creates valid output", {
  skip_if_not_installed("openxlsx")
  
  # Create temporary output file
  temp_file <- tempfile(fileext = ".xlsx")
  
  # Test with minimal parameters
  expect_no_error({
    result <- generate_vocabulary_bowtie(
      central_problems = c("Water Pollution"),
      output_file = temp_file,
      similarity_threshold = 0.3,
      max_connections_per_item = 2,
      use_ai_linking = FALSE  # Disable AI linking for stable testing
    )
  })
  
  # Check result structure
  expect_type(result, "list")
  expect_true("data" %in% names(result))
  expect_true("file" %in% names(result))
  expect_true("vocabulary_used" %in% names(result))
  
  # Check data structure
  expect_s3_class(result$data, "data.frame")
  expect_true(nrow(result$data) > 0)
  
  # Check required columns
  required_cols <- c("Activity", "Pressure", "Central_Problem", "Consequence",
                     "Preventive_Control", "Protective_Mitigation",
                     "Threat_Likelihood", "Consequence_Severity")
  expect_true(all(required_cols %in% names(result$data)))
  
  # Check file was created
  expect_true(file.exists(temp_file))
  
  # Clean up
  unlink(temp_file)
})

# Test problem-specific bow-tie creation
test_that("create_problem_specific_bowtie generates valid structure", {
  # Create mock vocabulary data
  mock_vocab <- list(
    activities = data.frame(
      id = c("ACT1", "ACT2"), 
      name = c("Industrial Discharge", "Agricultural Runoff"),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      id = c("PRES1", "PRES2"), 
      name = c("Chemical Contamination", "Nutrient Loading"),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      id = c("CONS1", "CONS2"), 
      name = c("Ecosystem Damage", "Human Health Risk"),
      stringsAsFactors = FALSE
    ),
    controls = data.frame(
      id = c("CTRL1", "CTRL2"), 
      name = c("Treatment Systems", "Monitoring"),
      stringsAsFactors = FALSE
    )
  )
  
  # Create mock links
  mock_links <- data.frame(
    from_type = "Activity",
    to_type = "Pressure",
    similarity = 0.8,
    stringsAsFactors = FALSE
  )
  
  result <- create_problem_specific_bowtie(
    "Water Pollution", 
    mock_vocab, 
    mock_links, 
    max_connections = 2
  )
  
  expect_s3_class(result, "data.frame")
  expect_true("Problem" %in% names(result))
  expect_true(all(result$Problem == "Water Pollution"))
  expect_true("Activity" %in% names(result))
  expect_true("Pressure" %in% names(result))
})

# Test connected items finding
test_that("find_connected_items returns relevant items", {
  mock_vocab <- list(
    activities = data.frame(
      id = c("ACT1", "ACT2", "ACT3"), 
      name = c("Water Treatment", "Industrial Water Use", "Agricultural Irrigation"),
      stringsAsFactors = FALSE
    )
  )
  
  result <- find_connected_items(
    "Water Pollution", 
    "Activity", 
    mock_vocab, 
    links = NULL, 
    max_items = 2
  )
  
  expect_s3_class(result, "data.frame")
  expect_true("id" %in% names(result))
  expect_true("name" %in% names(result))
  expect_true(nrow(result) <= 2)
})

# Test fallback item creation
test_that("create_fallback_items generates appropriate items", {
  activities <- create_fallback_items("Climate Change", "Activity")
  expect_type(activities, "character")
  expect_true(length(activities) > 0)
  expect_true(any(grepl("climate change", activities, ignore.case = TRUE)))
  
  pressures <- create_fallback_items("Air Pollution", "Pressure")
  expect_type(pressures, "character")
  expect_true(length(pressures) > 0)
  expect_true(any(grepl("air pollution", pressures, ignore.case = TRUE)))
})

# Test risk data enhancement
test_that("enhance_with_risk_data adds proper risk assessments", {
  test_data <- data.frame(
    Activity = "Industrial Operations",
    Pressure = "Chemical Discharge", 
    Problem = "Water Pollution",
    Consequence = "Ecosystem Damage",
    Preventive_Control = "Treatment",
    Protective_Mitigation = "Monitoring",
    stringsAsFactors = FALSE
  )
  
  enhanced <- enhance_with_risk_data(test_data)
  
  expect_s3_class(enhanced, "data.frame")
  expect_true("Threat_Likelihood" %in% names(enhanced))
  expect_true("Consequence_Severity" %in% names(enhanced))
  expect_true("Risk_Level" %in% names(enhanced))
  expect_true("Risk_Rating" %in% names(enhanced))
  
  # Check risk values are in valid ranges
  expect_true(all(enhanced$Threat_Likelihood >= 1 & enhanced$Threat_Likelihood <= 5))
  expect_true(all(enhanced$Consequence_Severity >= 1 & enhanced$Consequence_Severity <= 5))
  expect_true(all(enhanced$Risk_Rating %in% c("Low", "Medium", "High", "Very High")))
})

# Test Excel export functionality
test_that("export_bowtie_to_excel creates valid Excel file", {
  skip_if_not_installed("openxlsx")
  
  test_data <- data.frame(
    Activity = "Test Activity",
    Pressure = "Test Pressure",
    Problem = "Test Problem", 
    Consequence = "Test Consequence",
    Preventive_Control = "Test Control",
    Protective_Mitigation = "Test Mitigation",
    Threat_Likelihood = 3,
    Consequence_Severity = 3,
    Risk_Level = 9,
    Risk_Rating = "Medium",
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".xlsx")
  
  expect_no_error({
    export_bowtie_to_excel(test_data, temp_file)
  })
  
  expect_true(file.exists(temp_file))
  
  # Test that file can be read back
  expect_no_error({
    wb_data <- read.xlsx(temp_file, sheet = "Bowtie_Data")
  })
  
  # Clean up
  unlink(temp_file)
})

# Test sample vocabulary creation
test_that("create_sample_vocabulary_data creates valid structure", {
  sample_vocab <- create_sample_vocabulary_data()
  
  expect_type(sample_vocab, "list")
  expect_true(all(c("activities", "pressures", "consequences", "controls") %in% names(sample_vocab)))
  
  # Check each vocabulary type has required columns
  for (vocab_type in names(sample_vocab)) {
    vocab_data <- sample_vocab[[vocab_type]]
    expect_s3_class(vocab_data, "data.frame")
    expect_true(all(c("hierarchy", "id", "name") %in% names(vocab_data)))
    expect_true(nrow(vocab_data) > 0)
  }
})

# Integration test with AI linking (if available)
test_that("generation works with AI linking enabled", {
  skip_if_not(exists("find_vocabulary_links"), "AI linking functions not available")
  skip_if_not_installed("openxlsx")
  
  temp_file <- tempfile(fileext = ".xlsx")
  
  expect_no_error({
    result <- generate_vocabulary_bowtie(
      central_problems = c("Water Pollution"),
      output_file = temp_file,
      use_ai_linking = TRUE,
      similarity_threshold = 0.4,
      max_connections_per_item = 2
    )
  })
  
  expect_s3_class(result$data, "data.frame")
  expect_true(file.exists(temp_file))
  
  # Clean up
  unlink(temp_file)
})

# Test error handling
test_that("functions handle errors gracefully", {
  # Test with invalid central problem
  expect_no_error({
    result <- generate_vocabulary_bowtie(
      central_problems = c("Nonexistent Problem"),
      output_file = tempfile(fileext = ".xlsx"),
      use_ai_linking = FALSE
    )
  })
  
  # Test with empty vocabulary
  empty_vocab <- list(
    activities = data.frame(id = character(0), name = character(0)),
    pressures = data.frame(id = character(0), name = character(0)),
    consequences = data.frame(id = character(0), name = character(0)),
    controls = data.frame(id = character(0), name = character(0))
  )
  
  expect_no_error({
    result <- create_problem_specific_bowtie(
      "Test Problem", 
      empty_vocab, 
      NULL, 
      max_connections = 1
    )
  })
})