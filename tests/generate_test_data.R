# =============================================================================
# Advanced Test Data Generator
# Version: 1.0.0
# Description: Generate realistic, diverse test data for guided workflow
# =============================================================================

library(dplyr)

# =============================================================================
# VOCABULARY DATA GENERATOR
# =============================================================================

generate_comprehensive_vocabulary <- function(size = "large") {
  
  # Determine sizes based on parameter
  sizes <- list(
    small = list(activities = 10, pressures = 10, controls = 8, consequences = 6),
    medium = list(activities = 25, pressures = 20, controls = 15, consequences = 12),
    large = list(activities = 50, pressures = 40, controls = 25, consequences = 20),
    xlarge = list(activities = 100, pressures = 80, controls = 50, consequences = 40)
  )
  
  counts <- sizes[[size]]
  
  # ===========================================================================
  # ACTIVITIES
  # ===========================================================================
  
  activity_categories <- c("Primary", "Secondary", "Tertiary", "Quaternary")
  activity_sectors <- c("Agriculture", "Industry", "Urban", "Marine", "Energy", 
                       "Transport", "Tourism", "Fisheries", "Aquaculture", "Mining")
  
  activities <- data.frame(
    id = 1:counts$activities,
    name = sapply(1:counts$activities, function(i) {
      sector <- sample(activity_sectors, 1)
      action <- sample(c("operations", "development", "discharge", "extraction", 
                        "construction", "activities", "practices"), 1)
      paste(sector, action)
    }),
    category = sample(activity_categories, counts$activities, replace = TRUE),
    sector = sample(activity_sectors, counts$activities, replace = TRUE),
    intensity = sample(c("Low", "Medium", "High", "Very High"), 
                      counts$activities, replace = TRUE),
    geographic_scope = sample(c("Local", "Regional", "National", "International"), 
                             counts$activities, replace = TRUE),
    description = sapply(1:counts$activities, function(i) {
      paste("Description for activity", i)
    }),
    stringsAsFactors = FALSE
  )
  
  # ===========================================================================
  # PRESSURES
  # ===========================================================================
  
  pressure_types <- c("Chemical", "Physical", "Biological", "Thermal", 
                     "Acoustic", "Visual")
  pressure_pathways <- c("Direct discharge", "Atmospheric deposition", "Runoff", 
                        "Leaching", "Mechanical disturbance", "Biological introduction")
  
  pressures <- data.frame(
    id = 1:counts$pressures,
    name = sapply(1:counts$pressures, function(i) {
      type <- sample(c("pollution", "contamination", "disturbance", "destruction", 
                      "alteration", "depletion"), 1)
      source <- sample(c("nutrient", "chemical", "plastic", "noise", "thermal", 
                        "physical", "biological"), 1)
      paste(source, type, sep = " ")
    }),
    category = sample(pressure_types, counts$pressures, replace = TRUE),
    pathway = sample(pressure_pathways, counts$pressures, replace = TRUE),
    severity = sample(c("Low", "Moderate", "High", "Severe", "Critical"), 
                     counts$pressures, replace = TRUE),
    reversibility = sample(c("Reversible", "Partially reversible", "Irreversible"), 
                          counts$pressures, replace = TRUE),
    temporal_scale = sample(c("Acute", "Chronic", "Episodic", "Continuous"), 
                           counts$pressures, replace = TRUE),
    description = sapply(1:counts$pressures, function(i) {
      paste("Description for pressure", i)
    }),
    stringsAsFactors = FALSE
  )
  
  # ===========================================================================
  # CONTROLS
  # ===========================================================================
  
  control_types <- c("Regulatory", "Administrative", "Technical", "Physical", 
                    "Social", "Economic", "Monitoring", "Enforcement")
  control_effectiveness <- c("Very Low", "Low", "Medium", "High", "Very High")
  
  controls <- data.frame(
    id = 1:counts$controls,
    name = sapply(1:counts$controls, function(i) {
      type <- sample(c("regulations", "assessments", "areas", "quotas", "monitoring", 
                      "facilities", "zones", "programs", "standards", "measures"), 1)
      modifier <- sample(c("Environmental", "Marine", "Coastal", "Resource", 
                          "Pollution", "Conservation", "Management"), 1)
      paste(modifier, type)
    }),
    type = sample(control_types, counts$controls, replace = TRUE),
    effectiveness = sample(control_effectiveness, counts$controls, replace = TRUE),
    implementation_cost = sample(c("Low", "Medium", "High", "Very High"), 
                                counts$controls, replace = TRUE),
    timeframe = sample(c("Immediate", "Short-term", "Medium-term", "Long-term"), 
                      counts$controls, replace = TRUE),
    stakeholders = sample(c("Government", "Industry", "NGOs", "Community", 
                           "Multi-stakeholder"), counts$controls, replace = TRUE),
    description = sapply(1:counts$controls, function(i) {
      paste("Description for control", i)
    }),
    stringsAsFactors = FALSE
  )
  
  # ===========================================================================
  # CONSEQUENCES
  # ===========================================================================
  
  consequence_domains <- c("Ecological", "Economic", "Social", "Health", 
                          "Cultural", "Aesthetic")
  consequence_receptors <- c("Ecosystems", "Species", "Habitats", "Communities", 
                            "Livelihoods", "Infrastructure")
  
  consequences <- data.frame(
    id = 1:counts$consequences,
    name = sapply(1:counts$consequences, function(i) {
      impact <- sample(c("loss", "degradation", "decline", "damage", "impact", 
                        "disruption", "change"), 1)
      target <- sample(c("biodiversity", "water quality", "ecosystem", "habitat", 
                        "population", "resource", "service"), 1)
      paste(target, impact, sep = " ")
    }),
    category = sample(consequence_domains, counts$consequences, replace = TRUE),
    receptor = sample(consequence_receptors, counts$consequences, replace = TRUE),
    severity = sample(c("Minor", "Moderate", "Major", "Severe", "Catastrophic"), 
                     counts$consequences, replace = TRUE),
    likelihood = sample(1:5, counts$consequences, replace = TRUE),
    timeframe = sample(c("Immediate", "Short-term", "Long-term", "Permanent"), 
                      counts$consequences, replace = TRUE),
    reversibility = sample(c("Reversible", "Partially reversible", "Irreversible"), 
                          counts$consequences, replace = TRUE),
    spatial_extent = sample(c("Site", "Local", "Regional", "National", "Global"), 
                           counts$consequences, replace = TRUE),
    description = sapply(1:counts$consequences, function(i) {
      paste("Description for consequence", i)
    }),
    stringsAsFactors = FALSE
  )
  
  list(
    activities = activities,
    pressures = pressures,
    controls = controls,
    consequences = consequences
  )
}

# =============================================================================
# TEST SCENARIO GENERATOR
# =============================================================================

generate_test_scenarios <- function(n_scenarios = 10, vocabulary = NULL) {
  
  if (is.null(vocabulary)) {
    vocabulary <- generate_comprehensive_vocabulary("medium")
  }
  
  ecosystem_types <- c("Marine", "Freshwater", "Coastal", "Terrestrial", 
                      "Wetland", "Estuarine")
  problem_categories <- c("Pollution", "Habitat Loss", "Overexploitation", 
                         "Climate Change", "Invasive Species", "Disease")
  urgency_levels <- c("Low", "Medium", "High", "Critical")
  scales <- c("Site", "Local", "Regional", "National", "International")
  
  scenarios <- lapply(1:n_scenarios, function(i) {
    
    ecosystem <- sample(ecosystem_types, 1)
    category <- sample(problem_categories, 1)
    
    # Generate realistic project name
    location <- sample(c("River Basin", "Coastal Zone", "Marine Area", 
                        "Lake System", "Protected Area", "Urban Zone"), 1)
    project_name <- paste(ecosystem, location, "Management Project", i)
    
    # Generate problem statement
    problem_statement <- paste(
      "Environmental degradation in",
      tolower(location),
      "due to",
      tolower(category)
    )
    
    # Sample activities from vocabulary
    n_activities <- sample(2:5, 1)
    activities <- sample(vocabulary$activities$name, n_activities)
    
    # Sample pressures from vocabulary
    n_pressures <- sample(2:5, 1)
    pressures <- sample(vocabulary$pressures$name, n_pressures)
    
    # Sample controls from vocabulary
    n_controls <- sample(2:4, 1)
    controls <- sample(vocabulary$controls$name, n_controls)
    
    # Sample consequences from vocabulary
    n_consequences <- sample(2:4, 1)
    consequences <- sample(vocabulary$consequences$name, n_consequences)
    
    list(
      scenario_id = i,
      name = project_name,
      description = paste("Test scenario", i, "for", ecosystem, "ecosystem"),
      data = list(
        project_name = project_name,
        project_location = paste(sample(c("North", "South", "East", "West", "Central"), 1),
                                location),
        project_type = ecosystem,
        project_description = paste(
          "Comprehensive management approach for",
          tolower(ecosystem),
          "ecosystem addressing",
          tolower(category),
          "and associated impacts"
        ),
        problem_statement = problem_statement,
        problem_category = category,
        problem_details = paste(
          "Detailed analysis of",
          tolower(problem_statement),
          "including contributing factors and mechanisms"
        ),
        problem_scale = sample(scales, 1),
        problem_urgency = sample(urgency_levels, 1),
        activities = activities,
        pressures = pressures,
        preventive_controls = controls[1:ceiling(length(controls)/2)],
        protective_controls = controls[ceiling(length(controls)/2):length(controls)],
        consequences = consequences
      )
    )
  })
  
  names(scenarios) <- paste0("scenario_", 1:n_scenarios)
  scenarios
}

# =============================================================================
# REALISTIC TEST DATA GENERATOR
# =============================================================================

generate_realistic_workflow_data <- function(scenario_type = "complete") {
  
  vocab <- generate_comprehensive_vocabulary("medium")
  
  if (scenario_type == "minimal") {
    # Minimal valid workflow
    list(
      project_name = "Minimal Test Project",
      problem_statement = "Test problem"
    )
    
  } else if (scenario_type == "partial") {
    # Partially completed workflow
    list(
      project_name = "Partially Completed Project",
      project_location = "Test Location",
      project_type = "Marine",
      problem_statement = "Environmental issue requiring attention",
      problem_category = "Pollution",
      activities = sample(vocab$activities$name, 3)
    )
    
  } else if (scenario_type == "complete") {
    # Fully completed workflow
    list(
      project_name = "Comprehensive Test Project",
      project_location = "Test Marine Protected Area",
      project_type = "Marine",
      project_description = "Complete test scenario with all fields populated",
      problem_statement = "Multiple stressors affecting marine ecosystem health",
      problem_category = "Multiple Stressors",
      problem_details = "Detailed problem analysis with contributing factors",
      problem_scale = "Regional",
      problem_urgency = "High",
      activities = sample(vocab$activities$name, 5),
      pressures = sample(vocab$pressures$name, 5),
      preventive_controls = sample(vocab$controls$name, 3),
      protective_controls = sample(vocab$controls$name, 3),
      consequences = sample(vocab$consequences$name, 4),
      escalation_factors = c("Climate change", "Cumulative impacts", "Lag effects")
    )
    
  } else if (scenario_type == "stress") {
    # Large dataset for stress testing
    list(
      project_name = "Large Scale Stress Test Project",
      project_location = "Multiple Regions",
      project_type = "Marine",
      project_description = paste(rep("Detailed description. ", 100), collapse = ""),
      problem_statement = "Complex multi-faceted environmental problem",
      problem_category = "Multiple Stressors",
      problem_details = paste(rep("Detailed analysis. ", 100), collapse = ""),
      problem_scale = "International",
      problem_urgency = "Critical",
      activities = vocab$activities$name[1:min(50, nrow(vocab$activities))],
      pressures = vocab$pressures$name[1:min(40, nrow(vocab$pressures))],
      preventive_controls = vocab$controls$name[1:min(15, nrow(vocab$controls))],
      consequences = vocab$consequences$name[1:min(20, nrow(vocab$consequences))]
    )
  }
}

# =============================================================================
# EDGE CASE TEST DATA
# =============================================================================

generate_edge_case_data <- function() {
  list(
    empty = list(
      project_name = "",
      problem_statement = ""
    ),
    
    whitespace = list(
      project_name = "   ",
      problem_statement = "\t\n  "
    ),
    
    special_chars = list(
      project_name = "Test & Project <html>alert('xss')</html> 测试",
      problem_statement = "Problem with émoji 🌊 and spëcial çhars"
    ),
    
    very_long = list(
      project_name = paste(rep("A", 10000), collapse = ""),
      problem_statement = paste(rep("Long problem statement. ", 500), collapse = "")
    ),
    
    null_values = list(
      project_name = NULL,
      problem_statement = NULL,
      activities = NULL
    ),
    
    na_values = list(
      project_name = NA,
      problem_statement = NA_character_
    ),
    
    mixed_encoding = list(
      project_name = "Проект 测试 مشروع Projet",
      problem_statement = "Διεθνές πρόβλημα περιβάλλοντος"
    )
  )
}

# =============================================================================
# EXPORT TEST DATA
# =============================================================================

save_test_data <- function(output_dir = "tests/fixtures") {
  
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  cat("Generating comprehensive test data...\n")
  
  # Generate vocabularies of different sizes
  vocab_small <- generate_comprehensive_vocabulary("small")
  vocab_medium <- generate_comprehensive_vocabulary("medium")
  vocab_large <- generate_comprehensive_vocabulary("large")
  
  # Generate test scenarios
  scenarios <- generate_test_scenarios(20, vocab_medium)
  
  # Generate realistic workflow data
  workflow_minimal <- generate_realistic_workflow_data("minimal")
  workflow_partial <- generate_realistic_workflow_data("partial")
  workflow_complete <- generate_realistic_workflow_data("complete")
  workflow_stress <- generate_realistic_workflow_data("stress")
  
  # Generate edge cases
  edge_cases <- generate_edge_case_data()
  
  # Save to RDS files
  saveRDS(vocab_small, file.path(output_dir, "vocabulary_small.rds"))
  saveRDS(vocab_medium, file.path(output_dir, "vocabulary_medium.rds"))
  saveRDS(vocab_large, file.path(output_dir, "vocabulary_large.rds"))
  saveRDS(scenarios, file.path(output_dir, "test_scenarios.rds"))
  saveRDS(workflow_minimal, file.path(output_dir, "workflow_minimal.rds"))
  saveRDS(workflow_partial, file.path(output_dir, "workflow_partial.rds"))
  saveRDS(workflow_complete, file.path(output_dir, "workflow_complete.rds"))
  saveRDS(workflow_stress, file.path(output_dir, "workflow_stress.rds"))
  saveRDS(edge_cases, file.path(output_dir, "edge_cases.rds"))
  
  cat("✅ Test data saved to:", output_dir, "\n")
  cat("\nGenerated:\n")
  cat("  • 3 vocabulary datasets (small, medium, large)\n")
  cat("  • 20 test scenarios\n")
  cat("  • 4 workflow variants (minimal, partial, complete, stress)\n")
  cat("  • 7 edge case datasets\n")
  cat("\n")
  
  invisible(list(
    vocabularies = list(small = vocab_small, medium = vocab_medium, large = vocab_large),
    scenarios = scenarios,
    workflows = list(
      minimal = workflow_minimal,
      partial = workflow_partial,
      complete = workflow_complete,
      stress = workflow_stress
    ),
    edge_cases = edge_cases
  ))
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

if (!interactive()) {
  cat("\n")
  cat("=" , rep("=", 78), "\n", sep = "")
  cat("🎲 ADVANCED TEST DATA GENERATOR\n")
  cat("=" , rep("=", 78), "\n", sep = "")
  cat("\n")
  
  test_data <- save_test_data()
  
  cat("\n📊 Summary:\n")
  cat(sprintf("  Activities: %d (small), %d (medium), %d (large)\n",
             nrow(test_data$vocabularies$small$activities),
             nrow(test_data$vocabularies$medium$activities),
             nrow(test_data$vocabularies$large$activities)))
  cat(sprintf("  Pressures: %d (small), %d (medium), %d (large)\n",
             nrow(test_data$vocabularies$small$pressures),
             nrow(test_data$vocabularies$medium$pressures),
             nrow(test_data$vocabularies$large$pressures)))
  cat(sprintf("  Test Scenarios: %d\n", length(test_data$scenarios)))
  cat("\n")
}
