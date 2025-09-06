# Test fixtures and mock data for Environmental Bowtie Risk Analysis tests
# This file provides consistent test data across all test suites

# Mock bowtie data for testing
create_test_bowtie_data <- function(num_rows = 10) {
  data.frame(
    Activity = rep(c("Intensive Agriculture", "Urban Development", "Industrial Operations", 
                     "Transportation", "Waste Management"), length.out = num_rows),
    Pressure = rep(c("Nutrient Runoff", "Habitat Fragmentation", "Chemical Discharge", 
                     "Air Pollution", "Soil Contamination"), length.out = num_rows),
    Problem = rep(c("Water Pollution", "Biodiversity Loss", "Air Quality", 
                    "Climate Change", "Soil Degradation"), length.out = num_rows),
    Consequence = rep(c("Ecosystem Damage", "Human Health Risk", "Economic Loss", 
                       "Species Extinction", "Food Security"), length.out = num_rows),
    Preventive_Control = rep(c("Environmental Monitoring", "Pollution Prevention", 
                              "Regulatory Compliance", "Technology Upgrade", "Education"), 
                            length.out = num_rows),
    Protective_Mitigation = rep(c("Emergency Response", "Restoration Programs", 
                                 "Health Monitoring", "Conservation", "Remediation"), 
                               length.out = num_rows),
    Threat_Likelihood = sample(1:5, num_rows, replace = TRUE),
    Consequence_Severity = sample(1:5, num_rows, replace = TRUE),
    stringsAsFactors = FALSE
  )
}

# Mock vocabulary data with hierarchical structure
create_test_vocabulary_data <- function() {
  list(
    activities = data.frame(
      hierarchy = c("1", "1.1", "1.1.1", "1.1.2", "1.2", "1.2.1", "2", "2.1", "2.1.1"),
      id = c("AGR", "AGR.CROP", "AGR.CROP.FERT", "AGR.CROP.PEST", "AGR.LIVE", "AGR.LIVE.GRAZE", 
             "IND", "IND.MANF", "IND.MANF.CHEM"),
      name = c("Agriculture", "Crop Production", "Fertilizer Application", "Pesticide Use", 
               "Livestock", "Grazing", "Industry", "Manufacturing", "Chemical Production"),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      hierarchy = c("1", "1.1", "1.2", "2", "2.1", "2.2"),
      id = c("WTR", "WTR.NUTR", "WTR.CHEM", "AIR", "AIR.PART", "AIR.GAS"),
      name = c("Water Pollution", "Nutrient Loading", "Chemical Contamination", 
               "Air Pollution", "Particulate Matter", "Gaseous Emissions"),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      hierarchy = c("1", "1.1", "1.2", "2", "2.1"),
      id = c("ECO", "ECO.HAB", "ECO.SPEC", "HUM", "HUM.HLTH"),
      name = c("Ecological Impact", "Habitat Degradation", "Species Loss", 
               "Human Impact", "Health Effects"),
      stringsAsFactors = FALSE
    ),
    controls = data.frame(
      hierarchy = c("1", "1.1", "1.2", "2", "2.1"),
      id = c("PREV", "PREV.TECH", "PREV.REG", "PROT", "PROT.RESP"),
      name = c("Prevention", "Technology Controls", "Regulatory Controls", 
               "Protection", "Emergency Response"),
      stringsAsFactors = FALSE
    )
  )
}

# Mock Excel data structure (simulates what would be read from Excel files)
create_test_excel_data <- function() {
  list(
    causes = data.frame(
      Hierarchy = c("1", "1.1", "1.1.1", "2", "2.1"),
      "ID#" = c("C001", "C002", "C003", "C004", "C005"),
      name = c("Human Activities", "Agricultural Activities", "Fertilizer Use", 
               "Industrial Activities", "Manufacturing"),
      stringsAsFactors = FALSE,
      check.names = FALSE
    ),
    consequences = data.frame(
      Hierarchy = c("1", "1.1", "2", "2.1", "2.2"),
      "ID#" = c("CON001", "CON002", "CON003", "CON004", "CON005"),
      name = c("Environmental Impact", "Water Quality Impact", "Human Health Impact", 
               "Acute Health Effects", "Chronic Health Effects"),
      stringsAsFactors = FALSE,
      check.names = FALSE
    ),
    controls = data.frame(
      Hierarchy = c("1", "1.1", "2", "2.1", "2.2"),
      "ID#" = c("CTL001", "CTL002", "CTL003", "CTL004", "CTL005"),
      name = c("Preventive Controls", "Source Control", "Protective Controls", 
               "Monitoring", "Response"),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  )
}

# Mock Bayesian network structure
create_test_bayesian_structure <- function() {
  list(
    nodes = data.frame(
      id = c("Activity_Level", "Pressure_Level", "Problem_Level", "Consequence_Level", 
             "Control_Effectiveness"),
      label = c("Activity Level", "Environmental Pressure", "Central Problem", 
                "Consequence Severity", "Control Effectiveness"),
      type = c("activity", "pressure", "problem", "consequence", "control"),
      level = c(1, 2, 3, 4, 2),
      stringsAsFactors = FALSE
    ),
    edges = data.frame(
      from = c("Activity_Level", "Pressure_Level", "Problem_Level", "Control_Effectiveness"),
      to = c("Pressure_Level", "Problem_Level", "Consequence_Level", "Problem_Level"),
      stringsAsFactors = FALSE
    ),
    node_levels = list(
      Activity_Level = c("Low", "Medium", "High"),
      Pressure_Level = c("Low", "Medium", "High"),
      Problem_Level = c("Low", "Medium", "High"),
      Consequence_Level = c("Low", "Medium", "High"),
      Control_Effectiveness = c("Low", "Medium", "High")
    )
  )
}

# Helper function to create minimal valid data for specific tests
create_minimal_valid_data <- function() {
  data.frame(
    Activity = "Test Activity",
    Pressure = "Test Pressure",
    Problem = "Test Problem", 
    Consequence = "Test Consequence",
    Preventive_Control = "Test Control",
    Protective_Mitigation = "Test Mitigation",
    Threat_Likelihood = 3,
    Consequence_Severity = 3,
    stringsAsFactors = FALSE
  )
}

# Helper function to create invalid data for error testing
create_invalid_data_samples <- function() {
  list(
    empty = data.frame(),
    missing_columns = data.frame(Activity = "Test"),
    wrong_types = data.frame(
      Activity = "Test",
      Pressure = "Test", 
      Threat_Likelihood = "invalid",
      stringsAsFactors = FALSE
    ),
    na_values = data.frame(
      Activity = NA,
      Pressure = "Test",
      Problem = "Test",
      Consequence = "Test",
      stringsAsFactors = FALSE
    )
  )
}

# Mock network visualization data
create_test_network_viz_data <- function() {
  list(
    nodes = data.frame(
      id = 1:5,
      label = c("Activity", "Pressure", "Problem", "Consequence", "Control"),
      group = c("activity", "pressure", "problem", "consequence", "control"),
      color = c("#FF6B6B", "#4ECDC4", "#45B7D1", "#F7DC6F", "#BB8FCE"),
      stringsAsFactors = FALSE
    ),
    edges = data.frame(
      from = c(1, 2, 3, 5),
      to = c(2, 3, 4, 3),
      arrows = "to",
      stringsAsFactors = FALSE
    )
  )
}

# Test configuration settings
get_test_config <- function() {
  list(
    max_risk_level = 25,
    min_risk_level = 1,
    default_node_size = 50,
    risk_colors = list(
      low = "#28a745",
      medium = "#ffc107", 
      high = "#dc3545",
      very_high = "#6f42c1"
    ),
    test_timeout = 30  # seconds for long-running tests
  )
}

# =============================================================================
# VOCABULARY BOWTIE GENERATOR TEST FIXTURES
# =============================================================================

# Mock vocabulary data for bowtie generator testing
create_test_vocabulary_for_bowtie <- function() {
  list(
    activities = data.frame(
      hierarchy = c("1", "1.1", "1.1.1", "1.2", "2", "2.1"),
      id = c("AGR", "AGR.CROP", "AGR.CROP.FERT", "AGR.LIVE", "IND", "IND.CHEM"),
      name = c("Agriculture", "Crop Production", "Fertilizer Application", 
               "Livestock Farming", "Industrial Operations", "Chemical Production"),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      hierarchy = c("1", "1.1", "2", "2.1", "3", "3.1"),
      id = c("WTR", "WTR.POLL", "AIR", "AIR.EMIT", "SOIL", "SOIL.CONT"),
      name = c("Water Impact", "Water Pollution", "Air Impact", 
               "Air Emissions", "Soil Impact", "Soil Contamination"),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      hierarchy = c("1", "1.1", "2", "2.1", "3"),
      id = c("ECO", "ECO.DEGR", "HUM", "HUM.HLTH", "ECON"),
      name = c("Ecological Impact", "Ecosystem Degradation", "Human Impact", 
               "Health Effects", "Economic Impact"),
      stringsAsFactors = FALSE
    ),
    controls = data.frame(
      hierarchy = c("1", "1.1", "2", "2.1", "3"),
      id = c("PREV", "PREV.TECH", "MONIT", "MONIT.QUAL", "RESP"),
      name = c("Prevention", "Technology Controls", "Monitoring", 
               "Quality Monitoring", "Response Measures"),
      stringsAsFactors = FALSE
    )
  )
}

# Mock vocabulary links for testing
create_test_vocabulary_links <- function() {
  data.frame(
    from_id = c("AGR.CROP.FERT", "IND.CHEM", "WTR.POLL", "AIR.EMIT"),
    from_name = c("Fertilizer Application", "Chemical Production", "Water Pollution", "Air Emissions"),
    from_type = c("Activity", "Activity", "Pressure", "Pressure"),
    to_id = c("WTR.POLL", "AIR.EMIT", "ECO.DEGR", "HUM.HLTH"),
    to_name = c("Water Pollution", "Air Emissions", "Ecosystem Degradation", "Health Effects"),
    to_type = c("Pressure", "Pressure", "Consequence", "Consequence"),
    similarity = c(0.8, 0.7, 0.9, 0.6),
    method = c("causal", "causal", "causal", "causal"),
    stringsAsFactors = FALSE
  )
}

# Expected bowtie output structure for validation
create_expected_bowtie_structure <- function() {
  data.frame(
    Activity = "Test Activity",
    Pressure = "Test Pressure",
    Problem = "Test Problem",
    Consequence = "Test Consequence",
    Preventive_Control = "Test Preventive Control",
    Protective_Mitigation = "Test Protective Mitigation",
    Threat_Likelihood = 3,
    Consequence_Severity = 3,
    Risk_Level = 9,
    Risk_Rating = "Medium",
    Entry_ID = "TEST_001",
    Generation_Method = "Test_Generated",
    Generation_Date = Sys.Date(),
    stringsAsFactors = FALSE
  )
}

# Mock Excel file structure for bowtie generator
create_mock_excel_structure_for_bowtie <- function() {
  list(
    main_data = data.frame(
      Activity = c("Industrial Discharge", "Agricultural Runoff", "Urban Development"),
      Pressure = c("Chemical Contamination", "Nutrient Loading", "Habitat Fragmentation"),
      Problem = c("Water Pollution", "Water Pollution", "Biodiversity Loss"),
      Consequence = c("Ecosystem Damage", "Algal Blooms", "Species Loss"),
      Preventive_Control = c("Treatment Systems", "Buffer Strips", "Planning Controls"),
      Protective_Mitigation = c("Monitoring", "Emergency Response", "Restoration"),
      Threat_Likelihood = c(4, 3, 3),
      Consequence_Severity = c(4, 4, 5),
      Risk_Level = c(16, 12, 15),
      Risk_Rating = c("High", "High", "High"),
      stringsAsFactors = FALSE
    ),
    summary_data = data.frame(
      Metric = c("Total Entries", "Unique Problems", "Generation Date"),
      Value = c("3", "2", as.character(Sys.Date())),
      stringsAsFactors = FALSE
    )
  )
}

# Temporary file helpers for testing
get_test_temp_file <- function(extension = ".xlsx") {
  tempfile(pattern = "bowtie_test_", fileext = extension)
}

# Cleanup helper for test files
cleanup_test_files <- function(file_paths) {
  for (file_path in file_paths) {
    if (file.exists(file_path)) {
      unlink(file_path)
    }
  }
}

# Validate bowtie data structure
validate_bowtie_data_structure <- function(data) {
  required_columns <- c("Activity", "Pressure", "Problem", "Consequence", 
                       "Preventive_Control", "Protective_Mitigation",
                       "Threat_Likelihood", "Consequence_Severity")
  
  checks <- list(
    is_dataframe = is.data.frame(data),
    has_rows = nrow(data) > 0,
    has_required_columns = all(required_columns %in% names(data)),
    valid_likelihood_range = all(data$Threat_Likelihood >= 1 & data$Threat_Likelihood <= 5),
    valid_severity_range = all(data$Consequence_Severity >= 1 & data$Consequence_Severity <= 5)
  )
  
  return(list(
    valid = all(unlist(checks)),
    checks = checks,
    missing_columns = required_columns[!required_columns %in% names(data)]
  ))
}

# Performance testing helpers
create_large_vocabulary_dataset <- function(size_multiplier = 10) {
  base_vocab <- create_test_vocabulary_for_bowtie()
  
  # Multiply each vocabulary type
  large_vocab <- list()
  for (vocab_type in names(base_vocab)) {
    base_data <- base_vocab[[vocab_type]]
    large_data <- base_data[rep(1:nrow(base_data), size_multiplier), ]
    large_data$id <- paste0(large_data$id, "_", rep(1:size_multiplier, each = nrow(base_data)))
    large_data$name <- paste(large_data$name, "Variant", rep(1:size_multiplier, each = nrow(base_data)))
    rownames(large_data) <- NULL
    large_vocab[[vocab_type]] <- large_data
  }
  
  return(large_vocab)
}

# Test scenario configurations
get_bowtie_test_scenarios <- function() {
  list(
    minimal = list(
      central_problems = "Water Pollution",
      max_connections = 1,
      similarity_threshold = 0.5
    ),
    standard = list(
      central_problems = c("Water Pollution", "Air Quality"),
      max_connections = 3,
      similarity_threshold = 0.3
    ),
    comprehensive = list(
      central_problems = c("Water Pollution", "Air Quality", "Climate Change", "Biodiversity Loss"),
      max_connections = 5,
      similarity_threshold = 0.2
    ),
    stress_test = list(
      central_problems = rep(c("Water Pollution", "Air Quality"), 5),
      max_connections = 10,
      similarity_threshold = 0.1
    )
  )
}