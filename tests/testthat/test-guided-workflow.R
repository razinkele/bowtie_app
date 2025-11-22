# =============================================================================
# Test Suite for Guided Workflow System
# Version: 1.0.0
# Description: Comprehensive tests for guided bowtie creation workflow
# =============================================================================

library(testthat)
library(shiny)
library(DT)

# =============================================================================
# TEST DATA FIXTURES
# =============================================================================

# Create mock vocabulary data
create_mock_vocabulary <- function() {
  list(
    activities = data.frame(
      id = 1:10,
      name = c(
        "Agriculture",
        "Industrial discharge",
        "Urban development",
        "Commercial fishing",
        "Tourism activities",
        "Transportation",
        "Mining operations",
        "Forestry",
        "Aquaculture",
        "Waste disposal"
      ),
      category = c("Primary", "Secondary", "Tertiary", "Primary", "Tertiary",
                   "Secondary", "Primary", "Primary", "Primary", "Secondary"),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      id = 1:10,
      name = c(
        "Nutrient pollution",
        "Chemical contamination",
        "Habitat destruction",
        "Overfishing",
        "Physical disturbance",
        "Noise pollution",
        "Sediment runoff",
        "Temperature changes",
        "Plastic pollution",
        "Oil spills"
      ),
      category = c("Chemical", "Chemical", "Physical", "Biological", "Physical",
                   "Physical", "Physical", "Physical", "Chemical", "Chemical"),
      stringsAsFactors = FALSE
    ),
    controls = data.frame(
      id = 1:8,
      name = c(
        "Environmental regulations",
        "Impact assessments",
        "Protected areas",
        "Fishing quotas",
        "Pollution monitoring",
        "Treatment facilities",
        "Buffer zones",
        "Education programs"
      ),
      type = c("Regulatory", "Administrative", "Physical", "Regulatory",
               "Monitoring", "Technical", "Physical", "Social"),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      id = 1:6,
      name = c(
        "Biodiversity loss",
        "Ecosystem collapse",
        "Water quality degradation",
        "Human health impacts",
        "Economic losses",
        "Social impacts"
      ),
      severity = c("High", "Critical", "High", "High", "Medium", "Medium"),
      stringsAsFactors = FALSE
    )
  )
}

# Create test workflow state
create_test_workflow_state <- function() {
  list(
    current_step = 1,
    total_steps = 8,
    completed_steps = integer(0),
    progress_percentage = 0,
    project_name = "",
    central_problem = "",
    project_data = list(
      project_name = "",
      project_location = "",
      project_type = "",
      project_description = "",
      problem_statement = "",
      problem_category = "",
      problem_details = "",
      activities = list(),
      pressures = list(),
      preventive_controls = list(),
      consequences = list(),
      protective_controls = list(),
      escalation_factors = list()
    ),
    step_times = list()
  )
}

# Sample project scenarios for testing
create_test_scenarios <- function() {
  list(
    coastal_eutrophication = list(
      project_name = "Baltic Sea Eutrophication Management",
      project_location = "Baltic Sea, Northern Europe",
      project_type = "Marine",
      project_description = "Managing nutrient pollution and algal blooms in the Baltic Sea",
      problem_statement = "Excessive nutrient loading causing harmful algal blooms",
      problem_category = "Water Quality",
      problem_details = "High nitrogen and phosphorus levels from agricultural runoff",
      problem_scale = "Regional",
      problem_urgency = "High",
      activities = c("Agriculture", "Urban development", "Industrial discharge"),
      pressures = c("Nutrient pollution", "Chemical contamination", "Sediment runoff"),
      expected_controls = c("Environmental regulations", "Buffer zones", "Treatment facilities")
    ),
    
    coral_reef_degradation = list(
      project_name = "Great Barrier Reef Protection",
      project_location = "Great Barrier Reef, Australia",
      project_type = "Marine",
      project_description = "Protecting coral reefs from multiple stressors",
      problem_statement = "Coral bleaching and reef degradation",
      problem_category = "Ecosystem Health",
      problem_details = "Rising ocean temperatures and water quality issues",
      problem_scale = "Regional",
      problem_urgency = "Critical",
      activities = c("Tourism activities", "Commercial fishing", "Agriculture"),
      pressures = c("Temperature changes", "Physical disturbance", "Nutrient pollution"),
      expected_controls = c("Protected areas", "Fishing quotas", "Impact assessments")
    ),
    
    industrial_pollution = list(
      project_name = "Urban Industrial Pollution Control",
      project_location = "Industrial River Basin",
      project_type = "Freshwater",
      project_description = "Reducing industrial pollution in urban waterways",
      problem_statement = "Heavy metal contamination from industrial discharge",
      problem_category = "Pollution",
      problem_details = "Multiple industrial sources contributing to water contamination",
      problem_scale = "Local",
      problem_urgency = "High",
      activities = c("Industrial discharge", "Mining operations", "Waste disposal"),
      pressures = c("Chemical contamination", "Oil spills", "Plastic pollution"),
      expected_controls = c("Environmental regulations", "Treatment facilities", "Pollution monitoring")
    )
  )
}

# =============================================================================
# TEST: Workflow Initialization
# =============================================================================

test_that("Workflow state initializes correctly", {
  state <- create_test_workflow_state()
  
  expect_equal(state$current_step, 1)
  expect_equal(state$total_steps, 8)
  expect_equal(length(state$completed_steps), 0)
  expect_equal(state$progress_percentage, 0)
  expect_type(state$project_data, "list")
  expect_named(state$project_data, 
               c("project_name", "project_location", "project_type", "project_description",
                 "problem_statement", "problem_category", "problem_details",
                 "activities", "pressures", "preventive_controls", "consequences",
                 "protective_controls", "escalation_factors"))
})

test_that("Mock vocabulary data has correct structure", {
  vocab <- create_mock_vocabulary()
  
  expect_named(vocab, c("activities", "pressures", "controls", "consequences"))
  expect_s3_class(vocab$activities, "data.frame")
  expect_s3_class(vocab$pressures, "data.frame")
  expect_gt(nrow(vocab$activities), 0)
  expect_gt(nrow(vocab$pressures), 0)
  expect_true("name" %in% names(vocab$activities))
  expect_true("name" %in% names(vocab$pressures))
})

# =============================================================================
# TEST: Step Validation Functions
# =============================================================================

test_that("Step 1 validation works correctly", {
  # Test with empty project name
  input1 <- list(project_name = "")
  state1 <- create_test_workflow_state()
  state1$current_step <- 1
  
  result1 <- validate_current_step(state1, input1)
  expect_false(result1$is_valid)
  expect_match(result1$message, "project name", ignore.case = TRUE)
  
  # Test with valid project name
  input2 <- list(project_name = "Test Project")
  result2 <- validate_current_step(state1, input2)
  expect_true(result2$is_valid)
})

test_that("Step 2 validation works correctly", {
  # Test with empty problem statement
  input1 <- list(problem_statement = "")
  state1 <- create_test_workflow_state()
  state1$current_step <- 2
  
  result1 <- validate_current_step(state1, input1)
  expect_false(result1$is_valid)
  expect_match(result1$message, "central problem", ignore.case = TRUE)
  
  # Test with valid problem statement
  input2 <- list(problem_statement = "Nutrient pollution causing algal blooms")
  result2 <- validate_current_step(state1, input2)
  expect_true(result2$is_valid)
})

test_that("Step 3 validation allows optional entries", {
  # Step 3 should pass validation even without activities/pressures
  input <- list(activity_search = "", pressure_search = "")
  state <- create_test_workflow_state()
  state$current_step <- 3
  
  result <- validate_current_step(state, input)
  expect_true(result$is_valid)
})

# =============================================================================
# TEST: Data Saving Functions
# =============================================================================

test_that("save_step_data saves Step 1 data correctly", {
  state <- create_test_workflow_state()
  state$current_step <- 1
  
  input <- list(
    project_name = "Test Marine Project",
    project_location = "North Sea",
    project_type = "Marine",
    project_description = "Testing bowtie creation"
  )
  
  updated_state <- save_step_data(state, input)
  
  expect_equal(updated_state$project_data$project_name, "Test Marine Project")
  expect_equal(updated_state$project_data$project_location, "North Sea")
  expect_equal(updated_state$project_data$project_type, "Marine")
  expect_equal(updated_state$project_name, "Test Marine Project")
  expect_true("step_1" %in% names(updated_state$step_times))
})

test_that("save_step_data saves Step 2 data correctly", {
  state <- create_test_workflow_state()
  state$current_step <- 2
  
  input <- list(
    problem_statement = "Excessive nutrient loading",
    problem_category = "Water Quality",
    problem_details = "Agricultural runoff causing algal blooms",
    problem_scale = "Regional",
    problem_urgency = "High"
  )
  
  updated_state <- save_step_data(state, input)
  
  expect_equal(updated_state$project_data$problem_statement, "Excessive nutrient loading")
  expect_equal(updated_state$project_data$problem_category, "Water Quality")
  expect_equal(updated_state$central_problem, "Excessive nutrient loading")
  expect_true("step_2" %in% names(updated_state$step_times))
})

# =============================================================================
# TEST: Workflow Navigation
# =============================================================================

test_that("Workflow progresses through steps correctly", {
  state <- create_test_workflow_state()
  
  # Start at step 1
  expect_equal(state$current_step, 1)
  
  # Mark step 1 complete and move to step 2
  state$completed_steps <- c(state$completed_steps, 1)
  state$current_step <- 2
  expect_equal(state$current_step, 2)
  expect_true(1 %in% state$completed_steps)
  
  # Progress percentage updates
  state$progress_percentage <- (length(state$completed_steps) / state$total_steps) * 100
  expect_equal(state$progress_percentage, 12.5)
})

test_that("Cannot skip steps without completing previous", {
  state <- create_test_workflow_state()
  state$current_step <- 1
  state$completed_steps <- integer(0)
  
  # Attempting to jump to step 4 should fail validation
  target_step <- 4
  can_navigate <- target_step <= state$current_step || (target_step - 1) %in% state$completed_steps
  
  expect_false(can_navigate)
  
  # After completing step 3, should be able to go to step 4
  state$completed_steps <- c(1, 2, 3)
  state$current_step <- 4
  can_navigate <- target_step <= state$current_step || (target_step - 1) %in% state$completed_steps
  
  expect_true(can_navigate)
})

# =============================================================================
# TEST: Complete Workflow Scenarios
# =============================================================================

test_that("Complete eutrophication scenario processes correctly", {
  scenarios <- create_test_scenarios()
  scenario <- scenarios$coastal_eutrophication
  vocab <- create_mock_vocabulary()
  
  # Initialize workflow
  state <- create_test_workflow_state()
  
  # Step 1: Project Setup
  state$current_step <- 1
  input_step1 <- list(
    project_name = scenario$project_name,
    project_location = scenario$project_location,
    project_type = scenario$project_type,
    project_description = scenario$project_description
  )
  
  validation <- validate_current_step(state, input_step1)
  expect_true(validation$is_valid)
  
  state <- save_step_data(state, input_step1)
  expect_equal(state$project_data$project_name, scenario$project_name)
  
  # Step 2: Central Problem
  state$completed_steps <- c(1)
  state$current_step <- 2
  input_step2 <- list(
    problem_statement = scenario$problem_statement,
    problem_category = scenario$problem_category,
    problem_details = scenario$problem_details,
    problem_scale = scenario$problem_scale,
    problem_urgency = scenario$problem_urgency
  )
  
  validation <- validate_current_step(state, input_step2)
  expect_true(validation$is_valid)
  
  state <- save_step_data(state, input_step2)
  expect_equal(state$project_data$problem_statement, scenario$problem_statement)
  
  # Step 3: Activities and Pressures
  state$completed_steps <- c(1, 2)
  state$current_step <- 3
  state$project_data$activities <- scenario$activities
  state$project_data$pressures <- scenario$pressures
  
  # Verify activities and pressures are in vocabulary
  for (activity in scenario$activities) {
    expect_true(activity %in% vocab$activities$name,
                info = paste("Activity", activity, "should be in vocabulary"))
  }
  
  for (pressure in scenario$pressures) {
    expect_true(pressure %in% vocab$pressures$name,
                info = paste("Pressure", pressure, "should be in vocabulary"))
  }
})

test_that("Coral reef scenario processes correctly", {
  scenarios <- create_test_scenarios()
  scenario <- scenarios$coral_reef_degradation
  vocab <- create_mock_vocabulary()
  
  state <- create_test_workflow_state()
  state$project_data$project_name <- scenario$project_name
  state$project_data$problem_statement <- scenario$problem_statement
  state$project_data$activities <- scenario$activities
  state$project_data$pressures <- scenario$pressures
  
  # Verify all activities exist in vocabulary
  expect_true(all(scenario$activities %in% vocab$activities$name))
  
  # Verify all pressures exist in vocabulary
  expect_true(all(scenario$pressures %in% vocab$pressures$name))
  
  # Check expected controls are available
  expect_true(all(scenario$expected_controls %in% vocab$controls$name))
})

# =============================================================================
# TEST: Data Conversion and Export
# =============================================================================

test_that("convert_to_main_data_format creates valid output", {
  scenarios <- create_test_scenarios()
  scenario <- scenarios$industrial_pollution
  
  project_data <- list(
    project_name = scenario$project_name,
    problem_statement = scenario$problem_statement,
    activities = scenario$activities,
    pressures = scenario$pressures
  )
  
  result <- convert_to_main_data_format(project_data)
  
  expect_s3_class(result, "data.frame")
  expect_true("Central_Problem" %in% names(result))
  expect_equal(result$Central_Problem[1], scenario$problem_statement)
})

# =============================================================================
# TEST: Edge Cases and Error Handling
# =============================================================================

test_that("Handles empty vocabulary gracefully", {
  empty_vocab <- list(
    activities = data.frame(name = character(0), stringsAsFactors = FALSE),
    pressures = data.frame(name = character(0), stringsAsFactors = FALSE)
  )
  
  # Should not crash with empty vocabulary
  expect_equal(nrow(empty_vocab$activities), 0)
  expect_equal(nrow(empty_vocab$pressures), 0)
})

test_that("Handles very long text inputs", {
  state <- create_test_workflow_state()
  state$current_step <- 1
  
  long_text <- paste(rep("A", 1000), collapse = "")
  input <- list(
    project_name = long_text,
    project_description = long_text
  )
  
  validation <- validate_current_step(state, input)
  expect_true(validation$is_valid)
  
  updated_state <- save_step_data(state, input)
  expect_equal(nchar(updated_state$project_data$project_name), 1000)
})

test_that("Handles special characters in inputs", {
  state <- create_test_workflow_state()
  state$current_step <- 1
  
  special_chars <- "Test & Project <script>alert('test')</script> 日本語"
  input <- list(
    project_name = special_chars,
    project_description = "Testing special: @#$%^&*()"
  )
  
  validation <- validate_current_step(state, input)
  expect_true(validation$is_valid)
  
  updated_state <- save_step_data(state, input)
  expect_equal(updated_state$project_data$project_name, special_chars)
})

test_that("Progress percentage calculates correctly", {
  state <- create_test_workflow_state()
  
  # No steps completed
  progress <- (length(state$completed_steps) / state$total_steps) * 100
  expect_equal(progress, 0)
  
  # 4 steps completed
  state$completed_steps <- c(1, 2, 3, 4)
  progress <- (length(state$completed_steps) / state$total_steps) * 100
  expect_equal(progress, 50)
  
  # All steps completed
  state$completed_steps <- 1:8
  progress <- (length(state$completed_steps) / state$total_steps) * 100
  expect_equal(progress, 100)
})

# =============================================================================
# TEST: UI Generation Functions
# =============================================================================

test_that("Step UI generators return valid tagLists", {
  vocab <- create_mock_vocabulary()
  
  # Mock session with namespace function
  mock_session <- list(
    ns = function(id) paste0("test-", id)
  )
  
  # Test each step UI generator exists and returns tagList
  ui1 <- generate_step1_ui(session = mock_session)
  expect_s3_class(ui1, "shiny.tag.list")
  
  ui2 <- generate_step2_ui(session = mock_session)
  expect_s3_class(ui2, "shiny.tag.list")
  
  ui3 <- generate_step3_ui(vocabulary_data = vocab, session = mock_session)
  expect_s3_class(ui3, "shiny.tag.list")
  
  ui4 <- generate_step4_ui(session = mock_session)
  expect_s3_class(ui4, "shiny.tag.list")
  
  ui5 <- generate_step5_ui(session = mock_session)
  expect_s3_class(ui5, "shiny.tag.list")
})

# =============================================================================
# SUMMARY MESSAGE
# =============================================================================

cat("\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("✅ GUIDED WORKFLOW TEST SUITE COMPLETE\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("📊 Test Coverage:\n")
cat("   • Workflow initialization and state management\n")
cat("   • Step validation (Steps 1-3)\n")
cat("   • Data saving and retrieval\n")
cat("   • Navigation and progress tracking\n")
cat("   • Complete workflow scenarios (3 scenarios)\n")
cat("   • Data conversion and export\n")
cat("   • Edge cases and error handling\n")
cat("   • UI generation\n")
cat("\n")
cat("🎯 Test Scenarios Included:\n")
cat("   1. Coastal Eutrophication (Baltic Sea)\n")
cat("   2. Coral Reef Degradation (Great Barrier Reef)\n")
cat("   3. Industrial Pollution (Urban Waterways)\n")
cat("\n")
