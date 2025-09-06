# Test suite for Bayesian network functions (bowtie_bayesian_network.r)
# Tests Bayesian network creation, inference, and analysis

library(testthat)

# Mock bowtie data for testing
create_mock_bowtie_data <- function() {
  data.frame(
    Activity = c("Test Activity 1", "Test Activity 2"),
    Pressure = c("Test Pressure 1", "Test Pressure 2"), 
    Problem = c("Water Pollution", "Water Pollution"),
    Consequence = c("Ecosystem Damage", "Human Health Risk"),
    Preventive_Control = c("Control 1", "Control 2"),
    Protective_Mitigation = c("Mitigation 1", "Mitigation 2"),
    Threat_Likelihood = c(3, 4),
    Consequence_Severity = c(4, 3),
    stringsAsFactors = FALSE
  )
}

# Test Bayesian network structure creation
test_that("create_bayesian_structure creates valid network structure", {
  mock_data <- create_mock_bowtie_data()
  
  # Skip if bnlearn is not available
  skip_if_not_installed("bnlearn")
  
  bn_structure <- create_bayesian_structure(mock_data)
  
  expect_type(bn_structure, "list")
  expect_true("nodes" %in% names(bn_structure))
  expect_true("edges" %in% names(bn_structure))
  expect_true("node_levels" %in% names(bn_structure))
  
  # Check nodes structure
  expect_s3_class(bn_structure$nodes, "data.frame")
  expect_true(all(c("id", "label", "type") %in% names(bn_structure$nodes)))
  
  # Check edges structure  
  expect_s3_class(bn_structure$edges, "data.frame")
  expect_true(all(c("from", "to") %in% names(bn_structure$edges)))
})

# Test risk level discretization
test_that("discretize_risk_levels works correctly", {
  expect_equal(discretize_risk_levels(0.2), "Low")
  expect_equal(discretize_risk_levels(0.5), "Medium") 
  expect_equal(discretize_risk_levels(0.8), "High")
  
  # Test with custom levels
  custom_levels <- c("Very Low", "Low", "Medium", "High", "Very High")
  result <- discretize_risk_levels(0.9, custom_levels)
  expect_true(result %in% custom_levels)
})

# Test CPT creation
test_that("create_cpts generates conditional probability tables", {
  skip_if_not_installed("bnlearn")
  
  mock_data <- create_mock_bowtie_data()
  bn_structure <- create_bayesian_structure(mock_data)
  
  cpts <- create_cpts(bn_structure, use_data = FALSE)
  
  expect_type(cpts, "list")
  expect_true(length(cpts) > 0)
})

# Test bnlearn network creation
test_that("create_bnlearn_network creates valid bnlearn object", {
  skip_if_not_installed("bnlearn")
  
  mock_data <- create_mock_bowtie_data()
  bn_structure <- create_bayesian_structure(mock_data)
  
  bnlearn_net <- create_bnlearn_network(bn_structure)
  
  expect_s3_class(bnlearn_net, "bn")
})

# Test inference functionality
test_that("perform_inference works with valid evidence", {
  skip_if_not_installed("bnlearn")
  skip_if_not_installed("gRain")
  
  mock_data <- create_mock_bowtie_data()
  
  # Create a simple test - may need to adjust based on actual implementation
  expect_no_error({
    bn_structure <- create_bayesian_structure(mock_data)
    fitted_bn <- create_bnlearn_network(bn_structure)
    
    # Simple inference test - adjust evidence based on actual node names
    evidence <- list("Activity_Level" = "High")
    results <- perform_inference(fitted_bn, evidence)
  })
})

# Test network visualization
test_that("visualize_bayesian_network creates visualization output", {
  skip_if_not_installed("visNetwork")
  
  mock_data <- create_mock_bowtie_data()
  bn_structure <- create_bayesian_structure(mock_data)
  
  viz <- visualize_bayesian_network(bn_structure)
  
  # Check that visualization object is created
  expect_true(!is.null(viz))
})

# Test risk propagation calculation
test_that("calculate_risk_propagation processes scenarios", {
  skip_if_not_installed("bnlearn")
  
  mock_data <- create_mock_bowtie_data()
  bn_structure <- create_bayesian_structure(mock_data)
  fitted_bn <- create_bnlearn_network(bn_structure)
  
  scenario <- list("Activity_Level" = "High")
  
  expect_no_error({
    risk_prop <- calculate_risk_propagation(fitted_bn, scenario)
  })
})

# Test critical path finding
test_that("find_critical_paths identifies important pathways", {
  skip_if_not_installed("bnlearn")
  
  mock_data <- create_mock_bowtie_data()
  bn_structure <- create_bayesian_structure(mock_data)
  fitted_bn <- create_bnlearn_network(bn_structure)
  
  expect_no_error({
    critical_paths <- find_critical_paths(fitted_bn)
  })
})

# Test main conversion function
test_that("bowtie_to_bayesian performs full conversion", {
  skip_if_not_installed("bnlearn")
  skip_if_not_installed("gRain")
  
  mock_data <- create_mock_bowtie_data()
  
  expect_no_error({
    result <- bowtie_to_bayesian(mock_data, 
                                central_problem = "Water Pollution",
                                create_cpts = TRUE,
                                fit_parameters = FALSE)  # Set to FALSE to avoid data fitting issues
  })
  
  expect_type(result, "list")
  expect_true("bn_structure" %in% names(result))
})

# Test example analysis function
test_that("example_bayesian_analysis runs without errors", {
  skip_if_not_installed("bnlearn")
  
  mock_data <- create_mock_bowtie_data()
  
  expect_no_error({
    example_result <- example_bayesian_analysis(mock_data)
  })
})

# Test error handling
test_that("functions handle invalid input gracefully", {
  # Test with empty data
  empty_data <- data.frame()
  
  expect_error(create_bayesian_structure(empty_data))
  
  # Test with missing required columns
  invalid_data <- data.frame(Activity = "Test")
  expect_error(create_bayesian_structure(invalid_data))
})

# Test with different central problems
test_that("create_bayesian_structure works with different central problems", {
  skip_if_not_installed("bnlearn")
  
  mock_data <- create_mock_bowtie_data()
  
  # Test with specific central problem
  bn_structure1 <- create_bayesian_structure(mock_data, "Water Pollution")
  expect_type(bn_structure1, "list")
  
  # Test with NULL central problem (should use all data)
  bn_structure2 <- create_bayesian_structure(mock_data, NULL)
  expect_type(bn_structure2, "list")
})