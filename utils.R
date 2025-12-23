# =============================================================================
# Environmental Bowtie Risk Analysis - ENHANCED Utility Functions v5.1.0
# Version: 5.1.0 (Refreshed with Modern R Practices)
# Date: September 2025
# Description: Optimized performance with improved caching and error handling
# =============================================================================

# Improved cache for expensive computations with memory management
.cache <- new.env()
.cache$max_size <- 100  # Maximum cache entries
.cache$current_size <- 0

# Cache management functions
clear_cache <- function() {
  rm(list = ls(.cache), envir = .cache)
  .cache$current_size <- 0
  bowtie_log("🧹 Cache cleared successfully", .verbose = TRUE)
}

# Backward-compatibility wrapper
clearCache <- function() {
  clear_cache()
}

# Memory-aware cache setter
set_cache <- function(key, value) {
  if (.cache$current_size >= .cache$max_size) {
    clear_cache()
  }
  .cache[[key]] <- value
  .cache$current_size <- .cache$current_size + 1
}

# Safe cache getter
get_cache <- function(key, default = NULL) {
  if (exists(key, envir = .cache)) {
    return(.cache[[key]])
  }
  return(default)
}

# Performance monitoring utilities
.perf <- new.env()

# Centralized, controllable logging helper
# Use options(bowtie.verbose = TRUE) to enable logs in development. Tests/CI will be quiet by default.
bowtie_log <- function(..., level = c("info", "warn", "error"), .verbose = getOption("bowtie.verbose", FALSE)) {
  level <- match.arg(level)
  if (!.verbose) return(invisible(NULL))
  msg <- paste(..., collapse = " ")
  # Use message() so logs are visible but can be captured separately
  if (level == "info") message(msg)
  else if (level == "warn") warning(msg, call. = FALSE)
  else message(msg)
}

# Performance timer
start_timer <- function(operation = "task") {
  .perf[[paste0(operation, "_start")]] <- Sys.time()
}

end_timer <- function(operation = "task", silent = FALSE) {
  start_key <- paste0(operation, "_start")
  if (exists(start_key, envir = .perf)) {
    duration <- as.numeric(difftime(Sys.time(), .perf[[start_key]], units = "secs"))
    if (!silent) {
      bowtie_log("⏱️", operation, "completed in", round(duration, 2), "seconds", .verbose = TRUE)
    }
    return(duration)
  }
  return(NULL)
}

# Memory usage check
check_memory <- function() {
  if (requireNamespace("pryr", quietly = TRUE)) {
    bowtie_log(paste0("💾 Memory usage: ", pryr::mem_used()), .verbose = TRUE)
  } else {
    bowtie_log("💾 Memory monitoring requires 'pryr' package", .verbose = TRUE)
  }
}

# Function to generate environmental management sample data with connections and granular risk values
generateEnvironmentalDataFixed <- function() {
  bowtie_log("🔄 Generating environmental management data with granular connection risks", .verbose = TRUE)
  
  # Create comprehensive data with PROPERLY MAPPED protective mitigations
  sample_data <- data.frame(
    # Human Activities that create environmental pressures
    Activity = c(
      "Intensive agriculture operations", "Intensive agriculture operations", "Intensive agriculture operations",
      "Livestock farming practices", "Livestock farming practices", 
      "Urban development", "Urban development", "Urban development",
      "Municipal wastewater management", "Municipal wastewater management",
      "Residential septic systems", "Residential septic systems",
      "Industrial manufacturing", "Industrial manufacturing", "Industrial manufacturing",
      "Industrial waste disposal", "Industrial waste disposal",
      "Chemical transportation", "Chemical transportation",
      "Fossil fuel consumption", "Fossil fuel consumption",
      "International shipping", "International shipping",
      "Construction activities", "Construction activities",
      "Mining operations", "Mining operations"
    ),
    
    # Environmental Pressures (Threats) from activities
    Pressure = c(
      "Agricultural fertilizer runoff", "Pesticide contamination", "Soil erosion",
      "Animal waste from farms", "Methane emissions",
      "Urban stormwater runoff", "Habitat fragmentation", "Increased impervious surfaces",
      "Sewage treatment overflow", "Nutrient loading",
      "Septic system leakage", "Groundwater contamination",
      "Industrial nutrient discharge", "Heavy metal contamination", "Air emissions",
      "Industrial wastewater discharge", "Solid waste generation", 
      "Chemical spill", "Hazardous material release",
      "Greenhouse gas emissions", "Air quality degradation",
      "Invasive species introduction", "Oil spills",
      "Sediment runoff", "Noise pollution",
      "Acid mine drainage", "Groundwater depletion"
    ),
    
    # Preventive Controls
    Preventive_Control = c(
      "Nutrient management plans and buffer strips", "Integrated pest management", "Conservation tillage practices",
      "Manure management and rotational grazing", "Methane capture systems",
      "Stormwater management and green infrastructure", "Wildlife corridors and habitat preservation", "Permeable pavement systems",
      "Wastewater treatment upgrades and monitoring", "Advanced nutrient removal technology",
      "Septic system inspections and maintenance programs", "Groundwater monitoring wells",
      "Industrial discharge permits and real-time monitoring", "Heavy metal treatment systems", "Air pollution control equipment",
      "Advanced wastewater treatment standards", "Waste minimization programs",
      "Spill prevention and containment systems", "Hazardous material handling protocols",
      "Carbon reduction strategies and renewable energy", "Emission control technologies",
      "Biosecurity measures and quarantine protocols", "Double hull tankers and navigation systems",
      "Erosion control measures", "Noise abatement technology",
      "Acid neutralization systems", "Water conservation measures"
    ),
    
    # Escalation Factors
    Escalation_Factor = c(
      "Heavy rainfall and flooding events", "Drought conditions concentrating chemicals", "Equipment failure during peak season",
      "Drought conditions concentrating pollutants", "Infrastructure damage from extreme weather",
      "High water temperatures promoting growth", "Climate change altering precipitation patterns", "Urban heat island effects",
      "Infrastructure failures during peak flow", "Power outages affecting treatment",
      "Soil saturation and system overload", "Aging infrastructure failure",
      "Equipment malfunction and human error", "Power supply interruptions", "Extreme weather events",
      "Inadequate treatment during high demand", "Economic pressures reducing maintenance",
      "Transportation accidents in sensitive areas", "Emergency response delays",
      "Extreme weather events and system stress", "Regulatory compliance failures",
      "Established invasion pathways", "Severe weather damaging containment",
      "Heavy precipitation overwhelming controls", "Construction equipment failures",
      "Extreme precipitation events", "Economic downturns reducing monitoring"
    ),
    
    # Central Problem (Main Environmental Hazard)
    Central_Problem = c(
      "Eutrophication", "Eutrophication", "Eutrophication",
      "Eutrophication", "Climate impact",
      "Eutrophication", "Habitat loss", "Eutrophication",
      "Eutrophication", "Eutrophication",
      "Eutrophication", "Water pollution",
      "Water pollution", "Water pollution", "Air pollution",
      "Water pollution", "Water pollution",
      "Toxic release", "Toxic release",
      "Climate impact", "Air pollution",
      "Ecosystem disruption", "Water pollution",
      "Water pollution", "Environmental degradation",
      "Water pollution", "Water stress"
    ),
    
    # Updated Protective Mitigation - PROPERLY MAPPED to specific consequences
    Protective_Mitigation = c(
      "Algae bloom emergency response and lake aeration systems",           # → Algal blooms and dead zones
      "Algae bloom monitoring and aquatic ecosystem restoration",           # → Algal blooms and dead zones  
      "Water quality restoration and algae prevention systems",             # → Algal blooms and dead zones
      "Fish habitat restoration and aquatic biodiversity recovery",         # → Fish kills and biodiversity loss
      "Climate adaptation programs and carbon sequestration",              # → Global warming acceleration
      "Emergency water treatment and alternative supply systems",           # → Drinking water contamination
      "Species protection programs and habitat restoration corridors",      # → Species extinction and habitat loss
      "Advanced water purification and treatment technology",               # → Drinking water contamination
      "Beach closure protocols and public health monitoring",               # → Beach closures and health risks
      "Health advisory systems and water quality alerts",                  # → Beach closures and health risks
      "Economic recovery programs and tourism restoration",                 # → Economic losses to fisheries and tourism
      "Groundwater remediation and contamination cleanup",                 # → Groundwater contamination
      "Aquatic ecosystem rehabilitation and water quality improvement",     # → Aquatic ecosystem degradation
      "Ecosystem restoration and heavy metal remediation",                 # → Aquatic ecosystem degradation
      "Air quality monitoring and respiratory health protection",           # → Respiratory health impacts
      "Water treatment enhancement and ecosystem recovery",                 # → Aquatic ecosystem degradation
      "Environmental cleanup and contamination site remediation",          # → Land and water contamination
      "Wildlife protection and habitat preservation emergency response",    # → Wildlife poisoning and habitat loss
      "Emergency medical response and community safety protocols",          # → Human health emergencies
      "Climate resilience infrastructure and extreme weather adaptation",   # → Extreme weather events and infrastructure damage
      "Public health protection and air quality improvement programs",      # → Public health impacts
      "Invasive species control and native ecosystem restoration",          # → Native species displacement and ecosystem collapse
      "Marine ecosystem recovery and oil spill cleanup operations",         # → Marine ecosystem damage
      "Water quality restoration and contamination treatment",              # → Water quality degradation
      "Community health programs and noise reduction measures",             # → Community health impacts
      "Environmental remediation and long-term ecosystem recovery",         # → Long-term environmental damage
      "Water resource conservation and sustainable management programs"      # → Water scarcity and ecosystem stress
    ),
    
    # Final Environmental Consequences - MAPPED to protective mitigations above
    Consequence = c(
      "Algal blooms and dead zones", "Algal blooms and dead zones", "Algal blooms and dead zones",
      "Fish kills and biodiversity loss", "Global warming acceleration",
      "Drinking water contamination", "Species extinction and habitat loss", "Drinking water contamination",
      "Beach closures and health risks", "Beach closures and health risks", 
      "Economic losses to fisheries and tourism", "Groundwater contamination",
      "Aquatic ecosystem degradation", "Aquatic ecosystem degradation", "Respiratory health impacts",
      "Aquatic ecosystem degradation", "Land and water contamination",
      "Wildlife poisoning and habitat loss", "Human health emergencies",
      "Extreme weather events and infrastructure damage", "Public health impacts",
      "Native species displacement and ecosystem collapse", "Marine ecosystem damage",
      "Water quality degradation", "Community health impacts",
      "Long-term environmental damage", "Water scarcity and ecosystem stress"
    ),
    
    # GRANULAR BOWTIE CONNECTION RISKS (Enhancement)
    # Connection 1: Activity → Pressure
    Activity_to_Pressure_Likelihood = c(4, 3, 3, 4, 4, 5, 3, 4, 3, 4, 3, 3, 4, 3, 4, 4, 3, 2, 2, 5, 4, 2, 3, 4, 3, 3, 2),
    Activity_to_Pressure_Severity = c(3, 4, 2, 4, 3, 4, 4, 3, 4, 4, 3, 4, 3, 4, 3, 3, 2, 3, 3, 4, 3, 3, 4, 3, 2, 4, 3),
    
    # Connection 2: Pressure → Preventive Control (effectiveness/failure risk)
    Pressure_to_Control_Likelihood = c(2, 3, 2, 3, 2, 2, 3, 2, 3, 2, 3, 3, 2, 3, 2, 2, 3, 1, 1, 3, 2, 2, 2, 3, 2, 2, 3),
    Pressure_to_Control_Severity = c(4, 3, 3, 4, 4, 4, 4, 4, 4, 5, 3, 3, 4, 4, 4, 4, 3, 5, 4, 4, 4, 4, 4, 3, 3, 4, 3),
    
    # Connection 3: Escalation Factor → Control (escalation weakens control effectiveness)
    Control_to_Escalation_Likelihood = c(3, 2, 2, 3, 3, 3, 2, 3, 3, 3, 2, 2, 2, 2, 3, 3, 2, 2, 2, 4, 3, 2, 3, 3, 2, 3, 2),
    Control_to_Escalation_Severity = c(4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 4, 4, 3, 4, 4, 5, 4, 4, 4, 4, 3, 4, 4),

    # Connection 4: Failed Control → Central Problem (when control fails, problem occurs)
    Escalation_to_Central_Likelihood = c(4, 3, 3, 4, 3, 4, 3, 4, 4, 4, 3, 3, 3, 2, 3, 3, 3, 3, 3, 4, 4, 3, 3, 4, 3, 3, 3),
    Escalation_to_Central_Severity = c(5, 4, 3, 5, 4, 5, 4, 4, 5, 5, 4, 4, 4, 5, 4, 4, 3, 5, 4, 5, 4, 4, 4, 3, 4, 4, 3),
    
    # Connection 5: Central Problem → Protective Mitigation (mitigation effectiveness)
    Central_to_Mitigation_Likelihood = c(2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 2, 3, 1, 1, 3, 2, 2, 2, 2, 2, 2, 2),
    Central_to_Mitigation_Severity = c(4, 4, 4, 5, 3, 5, 4, 5, 5, 5, 4, 4, 4, 4, 4, 4, 3, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4),

    # Connection 5a: Escalation Factor → Protective Mitigation (escalation weakens mitigation effectiveness)
    Escalation_to_Mitigation_Likelihood = c(3, 2, 2, 3, 2, 3, 2, 3, 3, 3, 2, 2, 2, 2, 3, 3, 2, 2, 2, 3, 3, 2, 3, 3, 2, 2, 2),
    Escalation_to_Mitigation_Severity = c(4, 3, 3, 4, 3, 4, 3, 4, 4, 4, 3, 3, 3, 3, 4, 4, 3, 3, 3, 4, 4, 3, 4, 3, 3, 3, 3),

    # Connection 6: Mitigation → Consequence (residual risk after mitigation)
    Mitigation_to_Consequence_Likelihood = c(2, 2, 2, 3, 2, 3, 2, 2, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2),
    Mitigation_to_Consequence_Severity = c(5, 4, 3, 5, 4, 5, 4, 4, 5, 5, 4, 4, 4, 5, 4, 4, 3, 5, 4, 5, 4, 4, 4, 3, 4, 4, 3),
    
    stringsAsFactors = FALSE
  )
  
  # Calculate overall pathway risk using chain multiplication
  # Overall Likelihood = Product of all likelihood values in the chain (with some adjustment to prevent overly low values)
  overall_likelihood_raw <- with(sample_data,
    Activity_to_Pressure_Likelihood *
    (Pressure_to_Control_Likelihood/5) *
    (Control_to_Escalation_Likelihood/5) *
    (Escalation_to_Central_Likelihood/5) *
    (Central_to_Mitigation_Likelihood/5) *
    (Escalation_to_Mitigation_Likelihood/5) *
    (Mitigation_to_Consequence_Likelihood/5)
  )

  # Scale back to 1-5 range and ensure minimum of 1
  sample_data$Overall_Likelihood <- pmax(1, pmin(5, round(overall_likelihood_raw^0.3 * 2.5)))

  # Overall Severity = Maximum severity along the pathway (worst case)
  sample_data$Overall_Severity <- with(sample_data, pmax(
    Activity_to_Pressure_Severity,
    Pressure_to_Control_Severity,
    Control_to_Escalation_Severity,
    Escalation_to_Central_Severity,
    Central_to_Mitigation_Severity,
    Escalation_to_Mitigation_Severity,
    Mitigation_to_Consequence_Severity
  ))
  
  # Calculate Risk_Level based on overall pathway risk
  risk_scores <- sample_data$Overall_Likelihood * sample_data$Overall_Severity
  sample_data$Risk_Level <- ifelse(risk_scores <= 6, "Low",
                                  ifelse(risk_scores <= 15, "Medium", "High"))
  
  # Keep legacy columns for backward compatibility
  sample_data$Likelihood <- sample_data$Overall_Likelihood
  sample_data$Severity <- sample_data$Overall_Severity
  
  bowtie_log(paste("✅ Generated", nrow(sample_data), "rows of environmental data with granular connection risks"), .verbose = TRUE)
  bowtie_log("🔗 Each protective mitigation is properly mapped to its corresponding consequence", .verbose = TRUE)
  bowtie_log("📊 Added granular likelihood/severity for 6 bowtie connections per scenario", .verbose = TRUE)
  bowtie_log("🎯 Overall risk calculated from pathway chain analysis", .verbose = TRUE)

  # Backwards-compatibility: provide columns expected by older tests and callers
  if (!"Problem" %in% names(sample_data)) sample_data$Problem <- as.character(sample_data$Central_Problem)
  if (!"Threat_Likelihood" %in% names(sample_data)) {
    if ("Activity_to_Pressure_Likelihood" %in% names(sample_data)) {
      sample_data$Threat_Likelihood <- sample_data$Activity_to_Pressure_Likelihood
    } else if ("Likelihood" %in% names(sample_data)) {
      sample_data$Threat_Likelihood <- sample_data$Likelihood
    } else {
      sample_data$Threat_Likelihood <- sample_data$Overall_Likelihood
    }
  }
  if (!"Consequence_Severity" %in% names(sample_data)) {
    if ("Central_to_Mitigation_Severity" %in% names(sample_data)) {
      sample_data$Consequence_Severity <- sample_data$Central_to_Mitigation_Severity
    } else {
      sample_data$Consequence_Severity <- sample_data$Overall_Severity
    }
  }

  # Ensure character types for key columns expected by tests
  sample_data$Activity <- as.character(sample_data$Activity)
  sample_data$Pressure <- as.character(sample_data$Pressure)
  sample_data$Problem <- as.character(sample_data$Problem)
  sample_data$Consequence <- as.character(sample_data$Consequence)

  return(sample_data)
}

# Backward compatibility alias removed - use generateEnvironmentalDataFixed() directly

# Detailed validation (returns list with missing columns) - used by server
validateDataColumnsDetailed <- function(data) {
  # Accept either 'Central_Problem' or legacy 'Problem' as the central problem column
  required_cols <- c("Activity", "Pressure", "Consequence")
  missing_cols <- setdiff(required_cols, names(data))

  # Check for central problem presence
  if (!("Central_Problem" %in% names(data) || "Problem" %in% names(data))) {
    missing_cols <- c(missing_cols, "Central_Problem or Problem")
  }

  list(valid = length(missing_cols) == 0, missing = missing_cols)
}

# Backwards-compatible boolean validator (used by tests)
validateDataColumns <- function(data) {
  res <- validateDataColumnsDetailed(data)
  res$valid
} 

# Function to add default columns if missing (improved structure with granular risks)
addDefaultColumns <- function(data, scenario_type = "") {
  n_rows <- nrow(data)
  
  if (!"Activity" %in% names(data)) data$Activity <- paste("Activity", seq_len(n_rows))
  if (!"Pressure" %in% names(data)) data$Pressure <- paste("Pressure", seq_len(n_rows))
  if (!"Preventive_Control" %in% names(data)) data$Preventive_Control <- paste("Preventive control", seq_len(n_rows))
  
  # Scenario-specific escalation factors
  if (!"Escalation_Factor" %in% names(data)) {
    scenario_escalations <- switch(scenario_type,
      "marine_pollution" = c("Budget cuts reducing monitoring", "Staff turnover affecting expertise", "Equipment aging reducing effectiveness", "Regulatory enforcement gaps"),
      "industrial_contamination" = c("Cost-cutting reducing safety measures", "Maintenance delays on treatment systems", "Staff training inadequacy", "Regulatory oversight gaps"),
      "oil_spills" = c("Severe weather conditions", "Equipment maintenance failures", "Human error in operations", "Communication system failures"),
      "agricultural_runoff" = c("Extreme weather events", "Economic pressures on farmers", "Lack of technical support", "Equipment maintenance issues"),
      "overfishing_depletion" = c("Enforcement capacity limitations", "Economic pressures on fishers", "IUU fishing activities", "Technology detection gaps"),
      "martinique_coastal_erosion" = c("Climate change intensification", "Budget constraints for interventions", "Maintenance gaps in structures", "Storm frequency increases"),
      "martinique_sargassum" = c("Climate variability", "Resource limitations for cleanup", "Forecast accuracy issues", "Equipment capacity constraints"),
      "martinique_coral_degradation" = c("Ocean acidification", "Marine heatwave intensity", "Tourism pressure increases", "Limited enforcement resources"),
      "martinique_watershed_pollution" = c("Legacy contamination persistence", "Economic farming pressures", "Technical support gaps", "Monitoring resource limitations"),
      "martinique_mangrove_loss" = c("Development pressure increases", "Enforcement resource gaps", "Climate stress factors", "Community awareness limitations"),
      "martinique_hurricane_impacts" = c("Climate change intensification", "Building code compliance gaps", "Infrastructure aging", "Emergency capacity limitations"),
      "martinique_marine_tourism" = c("Tourism growth pressures", "Enforcement capacity gaps", "Economic incentive conflicts", "Visitor education limitations"),
      # Default generic escalation factors
      c("Budget constraints reducing monitoring", "Staff turnover affecting expertise", "Equipment maintenance delays", "Regulatory changes creating gaps", "Extreme weather overwhelming systems", "Human error during critical operations")
    )
    
    # Cycle through scenario-specific escalation factors
    data$Escalation_Factor <- rep_len(scenario_escalations, n_rows)
  }
  
  if (!"Central_Problem" %in% names(data)) data$Central_Problem <- "Environmental Risk"
  
  # Handle Protective_Mitigation - use Protective_Control if available, otherwise create scenario-specific
  if (!"Protective_Mitigation" %in% names(data)) {
    if ("Protective_Control" %in% names(data)) {
      # Use the Protective_Control values
      data$Protective_Mitigation <- data$Protective_Control
    } else {
      # Create scenario-specific protective mitigations
      scenario_mitigations <- switch(scenario_type,
        "marine_pollution" = c("Marine pollution cleanup operations", "Ecosystem restoration programs", "Water quality recovery measures", "Marine sanctuary designation"),
        "industrial_contamination" = c("Contaminated site remediation", "Groundwater treatment systems", "Soil decontamination programs", "Health monitoring systems"),
        "oil_spills" = c("Oil spill cleanup operations", "Marine ecosystem restoration", "Wildlife rescue and rehabilitation", "Coastal cleanup programs"),
        "agricultural_runoff" = c("Water treatment facilities", "Wetland restoration projects", "Alternative water supply systems", "Ecosystem recovery programs"),
        "overfishing_depletion" = c("Stock rebuilding programs", "Habitat restoration projects", "Alternative livelihood support", "Fisheries recovery plans"),
        "martinique_coastal_erosion" = c("Beach nourishment programs", "Coastal infrastructure relocation", "Natural buffer restoration", "Emergency coastal protection"),
        "martinique_sargassum" = c("Beach cleanup operations", "Sargassum collection barriers", "Alternative tourism promotion", "H2S monitoring systems"),
        "martinique_coral_degradation" = c("Coral restoration programs", "Reef rehabilitation projects", "Marine sanctuary expansion", "Tourism education programs"),
        "martinique_watershed_pollution" = c("Water treatment infrastructure", "Soil remediation programs", "Alternative water sources", "Health surveillance systems"),
        "martinique_mangrove_loss" = c("Mangrove replanting programs", "Coastal restoration projects", "Alternative protection measures", "Ecosystem recovery plans"),
        "martinique_hurricane_impacts" = c("Emergency response coordination", "Infrastructure rebuilding", "Disaster recovery programs", "Community resilience building"),
        "martinique_marine_tourism" = c("Reef restoration projects", "Marine sanctuary management", "Sustainable tourism programs", "Environmental education"),
        # Default generic protective mitigations
        c("Emergency response procedures", "Environmental restoration", "Impact mitigation measures", "Recovery programs", "Remediation activities", "Alternative solutions")
      )
      data$Protective_Mitigation <- rep_len(scenario_mitigations, n_rows)
    }
  }
  
  if (!"Consequence" %in% names(data)) data$Consequence <- paste("Consequence", seq_len(n_rows))
  
  # Add granular connection risk columns if missing
  if (!"Activity_to_Pressure_Likelihood" %in% names(data)) data$Activity_to_Pressure_Likelihood <- sample.int(5, n_rows, replace = TRUE)
  if (!"Activity_to_Pressure_Severity" %in% names(data)) data$Activity_to_Pressure_Severity <- sample.int(5, n_rows, replace = TRUE)
  if (!"Pressure_to_Control_Likelihood" %in% names(data)) data$Pressure_to_Control_Likelihood <- sample.int(3, n_rows, replace = TRUE)
  if (!"Pressure_to_Control_Severity" %in% names(data)) data$Pressure_to_Control_Severity <- sample.int(5, n_rows, replace = TRUE)
  if (!"Control_to_Escalation_Likelihood" %in% names(data)) data$Control_to_Escalation_Likelihood <- sample.int(4, n_rows, replace = TRUE)
  if (!"Control_to_Escalation_Severity" %in% names(data)) data$Control_to_Escalation_Severity <- sample.int(5, n_rows, replace = TRUE)
  if (!"Escalation_to_Central_Likelihood" %in% names(data)) data$Escalation_to_Central_Likelihood <- sample.int(5, n_rows, replace = TRUE)
  if (!"Escalation_to_Central_Severity" %in% names(data)) data$Escalation_to_Central_Severity <- sample.int(5, n_rows, replace = TRUE)
  if (!"Central_to_Mitigation_Likelihood" %in% names(data)) data$Central_to_Mitigation_Likelihood <- sample.int(3, n_rows, replace = TRUE)
  if (!"Central_to_Mitigation_Severity" %in% names(data)) data$Central_to_Mitigation_Severity <- sample.int(5, n_rows, replace = TRUE)
  if (!"Escalation_to_Mitigation_Likelihood" %in% names(data)) data$Escalation_to_Mitigation_Likelihood <- sample.int(3, n_rows, replace = TRUE)
  if (!"Escalation_to_Mitigation_Severity" %in% names(data)) data$Escalation_to_Mitigation_Severity <- sample.int(4, n_rows, replace = TRUE)
  if (!"Mitigation_to_Consequence_Likelihood" %in% names(data)) data$Mitigation_to_Consequence_Likelihood <- sample.int(3, n_rows, replace = TRUE)
  if (!"Mitigation_to_Consequence_Severity" %in% names(data)) data$Mitigation_to_Consequence_Severity <- sample.int(5, n_rows, replace = TRUE)

  # Calculate overall pathway risk if granular data exists
  if (all(c("Activity_to_Pressure_Likelihood", "Mitigation_to_Consequence_Severity") %in% names(data))) {
    # Calculate overall likelihood using chain multiplication
    overall_likelihood_raw <- with(data,
      Activity_to_Pressure_Likelihood *
      (Pressure_to_Control_Likelihood/5) *
      (Control_to_Escalation_Likelihood/5) *
      (Escalation_to_Central_Likelihood/5) *
      (Central_to_Mitigation_Likelihood/5) *
      (Escalation_to_Mitigation_Likelihood/5) *
      (Mitigation_to_Consequence_Likelihood/5)
    )

    # Scale back to 1-5 range
    data$Overall_Likelihood <- pmax(1, pmin(5, round(overall_likelihood_raw^0.3 * 2.5)))

    # Overall Severity = Maximum severity along the pathway
    data$Overall_Severity <- with(data, pmax(
      Activity_to_Pressure_Severity,
      Pressure_to_Control_Severity,
      Control_to_Escalation_Severity,
      Escalation_to_Central_Severity,
      Central_to_Mitigation_Severity,
      Escalation_to_Mitigation_Severity,
      Mitigation_to_Consequence_Severity
    ))
  } else {
    # Fallback to simple values
    if (!"Overall_Likelihood" %in% names(data)) data$Overall_Likelihood <- sample.int(5, n_rows, replace = TRUE)
    if (!"Overall_Severity" %in% names(data)) data$Overall_Severity <- sample.int(5, n_rows, replace = TRUE)
  }
  
  # Legacy columns for backward compatibility
  if (!"Likelihood" %in% names(data)) data$Likelihood <- data$Overall_Likelihood
  if (!"Severity" %in% names(data)) data$Severity <- data$Overall_Severity
  
  if (!"Risk_Level" %in% names(data)) {
    risk_scores <- data$Overall_Likelihood * data$Overall_Severity
    data$Risk_Level <- ifelse(risk_scores <= 6, "Low",
                             ifelse(risk_scores <= 15, "Medium", "High"))
  }

  # Compatibility columns expected by older callers/tests
  if (!"Threat_Likelihood" %in% names(data)) {
    if ("Activity_to_Pressure_Likelihood" %in% names(data)) data$Threat_Likelihood <- data$Activity_to_Pressure_Likelihood else data$Threat_Likelihood <- data$Likelihood
  }
  if (!"Consequence_Severity" %in% names(data)) {
    if ("Central_to_Mitigation_Severity" %in% names(data)) data$Consequence_Severity <- data$Central_to_Mitigation_Severity else data$Consequence_Severity <- data$Overall_Severity
  }
  if (!"Risk_Rating" %in% names(data)) data$Risk_Rating <- data$Overall_Likelihood * data$Overall_Severity

  data
}

# Vectorized risk score calculation (numeric product). Tests expect numeric rating (likelihood * severity)
calculateRiskLevel <- function(likelihood, severity) {
  as.numeric(likelihood) * as.numeric(severity)
} 

# Improved color mappings for comprehensive structure
RISK_COLORS <- c("Low" = "#90EE90", "Medium" = "#FFD700", "High" = "#FF6B6B")
ACTIVITY_COLOR <- "#8E44AD"          # Purple for activities
PRESSURE_COLOR <- "#E74C3C"          # Red for pressures/threats
PREVENTIVE_COLOR <- "#27AE60"        # Green for preventive controls
ESCALATION_COLOR <- "#F39C12"        # Orange for escalation factors
CENTRAL_PROBLEM_COLOR <- "#C0392B"   # Dark red for central problem
PROTECTIVE_COLOR <- "#3498DB"        # Blue for protective mitigation
CONSEQUENCE_COLOR <- "#E67E22"       # Dark orange for consequences

# Optimized risk color function - accepts numeric scores or categorical levels
getRiskColor <- function(risk_level, show_risk_levels = TRUE) {
  if (!show_risk_levels) return("#CCCCCC")
  if (is.numeric(risk_level)) {
    catg <- ifelse(risk_level <= 6, "Low", ifelse(risk_level <= 15, "Medium", "High"))
    return(RISK_COLORS[catg])
  }
  RISK_COLORS[as.character(risk_level)]
} 

# Clear cache when data changes
# Duplicate clearCache function removed - use clear_cache() instead

# Updated node creation for comprehensive bowtie structure
createBowtieNodesFixed <- function(hazard_data, selected_problem, node_size, show_risk_levels, show_barriers) {
  # Validate input data
  if (missing(hazard_data) || !is.data.frame(hazard_data) || nrow(hazard_data) == 0) {
    stop("Invalid hazard data: 'hazard_data' must be a non-empty data.frame with required columns")
  }
  required_cols <- c("Activity", "Pressure", "Problem", "Consequence")
  if (!all(required_cols %in% names(hazard_data))) {
    stop(sprintf("Invalid hazard data: missing required columns: %s", paste(setdiff(required_cols, names(hazard_data)), collapse = ", ")))
  }

  # Check cache first (removed aggressive cache clearing for better performance)
  cache_key <- paste0("nodes_updated_v432_", selected_problem, "_", node_size, "_", show_risk_levels, "_", show_barriers, "_", nrow(hazard_data))
  if (exists(cache_key, envir = .cache)) {
    cat("📋 Using cached nodes\n")
    return(get(cache_key, envir = .cache))
  }

  cat("🔧 Creating Updated bowtie nodes (v432 - extra spacing)\n")

  # Helper function to wrap text for multi-word labels
  wrap_label <- function(text, max_width = 20) {
    words <- strsplit(text, " ")[[1]]
    if (length(words) < 2) {
      return(text)  # Single word, no wrapping needed
    }

    lines <- character()
    current_line <- ""

    for (word in words) {
      if (nchar(current_line) == 0) {
        current_line <- word
      } else if (nchar(paste(current_line, word)) <= max_width) {
        current_line <- paste(current_line, word)
      } else {
        lines <- c(lines, current_line)
        current_line <- word
      }
    }

    if (nchar(current_line) > 0) {
      lines <- c(lines, current_line)
    }

    return(paste(lines, collapse = "\n"))
  }
  
  # Pre-calculate unique values for each element
  activities <- unique(hazard_data$Activity[hazard_data$Activity != ""])
  pressures <- unique(hazard_data$Pressure[hazard_data$Pressure != ""])
  consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
  
  # Calculate total nodes needed
  n_activities <- length(activities)
  n_pressures <- length(pressures)
  n_consequences <- length(consequences)
  n_barriers <- 0
  
  if (show_barriers) {
    # Pre-calculate unique values for barrier elements
    preventive_controls <- unique(hazard_data$Preventive_Control[hazard_data$Preventive_Control != ""])
    escalation_factors <- unique(hazard_data$Escalation_Factor[hazard_data$Escalation_Factor != ""])
    protective_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Protective_Mitigation != ""])
    n_barriers <- length(preventive_controls) + length(escalation_factors) + length(protective_mitigations)
    
    cat("🛡️ Found", length(protective_mitigations), "unique protective mitigations\n")
  }
  
  total_nodes <- 1 + n_activities + n_pressures + n_consequences + n_barriers
  
  # Pre-allocate vectors
  ids <- integer(total_nodes)
  labels <- character(total_nodes)
  groups <- character(total_nodes)
  colors <- character(total_nodes)
  shapes <- character(total_nodes)
  sizes <- numeric(total_nodes)
  font_sizes <- numeric(total_nodes)
  titles <- character(total_nodes)  # For tooltips
  x_coords <- numeric(total_nodes)  # X coordinates for free positioning
  y_coords <- numeric(total_nodes)  # Y coordinates for free positioning

  idx <- 1

  # Central Problem node (center) - Improved Diamond shape
  ids[idx] <- 1
  labels[idx] <- wrap_label(selected_problem, max_width = 25)
  groups[idx] <- "central_problem"
  colors[idx] <- CENTRAL_PROBLEM_COLOR
  shapes[idx] <- "diamond"
  sizes[idx] <- node_size * 1.8
  font_sizes[idx] <- 16
  x_coords[idx] <- 0     # Center horizontally
  y_coords[idx] <- 0     # Center vertically
  titles[idx] <- paste0("<b>Central Problem:</b><br/>", selected_problem,
                       "<br/><br/><b>Type:</b> Environmental Risk Focus<br/>",
                       "<b>Node ID:</b> ", 1, "<br/>",
                       "<b>Connections:</b> Links activities to consequences")
  idx <- idx + 1
  
  # Activity nodes (far left) - Improved
  if (n_activities > 0) {
    activity_colors <- if (show_risk_levels) {
      sapply(activities, function(a) {
        risk <- hazard_data$Risk_Level[hazard_data$Activity == a][1]
        getRiskColor(risk, TRUE)
      })
    } else {
      rep(ACTIVITY_COLOR, n_activities)
    }

    activity_indices <- idx:(idx + n_activities - 1)
    ids[activity_indices] <- 50 + seq_len(n_activities)
    labels[activity_indices] <- sapply(activities, wrap_label, max_width = 18)
    groups[activity_indices] <- "activity_custom"
    colors[activity_indices] <- "#8E44AD"  # Force purple color
    shapes[activity_indices] <- "square"    # Square shape
    sizes[activity_indices] <- node_size * 0.85  # Reduced from node_size
    font_sizes[activity_indices] <- 11  # Reduced from 12

    # Set positions for activities (far left) - FURTHER INCREASED SPACING
    x_coords[activity_indices] <- -800  # Increased from -600
    # Spread activities vertically - FURTHER INCREASED SPACING
    y_spacing <- if (n_activities > 1) 250 else 0  # Increased from 180
    y_coords[activity_indices] <- seq(-(n_activities - 1) * y_spacing / 2,
                                       (n_activities - 1) * y_spacing / 2,
                                       length.out = n_activities)

    # Add tooltips for activities
    for (i in seq_len(n_activities)) {
      activity_name <- activities[i]
      activity_data <- hazard_data[hazard_data$Activity == activity_name, ]
      risk_level <- if(nrow(activity_data) > 0) activity_data$Risk_Level[1] else "Unknown"
      pressures_connected <- unique(activity_data$Pressure[activity_data$Pressure != ""])

      titles[activity_indices[i]] <- paste0(
        "<b>Activity:</b><br/>", activity_name,
        "<br/><br/><b>Type:</b> Human Action<br/>",
        "<b>Risk Level:</b> ", risk_level, "<br/>",
        "<b>Node ID:</b> ", 50 + i, "<br/>",
        "<b>Connected Pressures:</b><br/>• ",
        if(length(pressures_connected) > 0) paste(pressures_connected, collapse = "<br/>• ") else "None"
      )
    }
    idx <- idx + n_activities
  }
  
  # Pressure nodes (left side) - Improved
  if (n_pressures > 0) {
    pressure_colors <- if (show_risk_levels) {
      sapply(pressures, function(p) {
        risk <- hazard_data$Risk_Level[hazard_data$Pressure == p][1]
        getRiskColor(risk, TRUE)
      })
    } else {
      rep(PRESSURE_COLOR, n_pressures)
    }

    pressure_indices <- idx:(idx + n_pressures - 1)
    ids[pressure_indices] <- 100 + seq_len(n_pressures)
    labels[pressure_indices] <- sapply(pressures, wrap_label, max_width = 18)
    groups[pressure_indices] <- "pressure"
    colors[pressure_indices] <- pressure_colors
    shapes[pressure_indices] <- "triangle"
    sizes[pressure_indices] <- node_size * 0.85  # Reduced from node_size
    font_sizes[pressure_indices] <- 11  # Reduced from 12

    # Set positions for pressures (left side, between activities and central problem) - FURTHER INCREASED SPACING
    x_coords[pressure_indices] <- -400  # Increased from -300
    # Spread pressures vertically - FURTHER INCREASED SPACING
    y_spacing <- if (n_pressures > 1) 220 else 0  # Increased from 150
    y_coords[pressure_indices] <- seq(-(n_pressures - 1) * y_spacing / 2,
                                       (n_pressures - 1) * y_spacing / 2,
                                       length.out = n_pressures)

    # Add tooltips for pressures
    for (i in seq_len(n_pressures)) {
      pressure_name <- pressures[i]
      pressure_data <- hazard_data[hazard_data$Pressure == pressure_name, ]
      risk_level <- if(nrow(pressure_data) > 0) pressure_data$Risk_Level[1] else "Unknown"
      activities_connected <- unique(pressure_data$Activity[pressure_data$Activity != ""])
      consequences_connected <- unique(pressure_data$Consequence[pressure_data$Consequence != ""])

      titles[pressure_indices[i]] <- paste0(
        "<b>Pressure:</b><br/>", pressure_name,
        "<br/><br/><b>Type:</b> Environmental Threat<br/>",
        "<b>Risk Level:</b> ", risk_level, "<br/>",
        "<b>Node ID:</b> ", 100 + i, "<br/>",
        "<b>From Activities:</b><br/>• ",
        if(length(activities_connected) > 0) paste(activities_connected, collapse = "<br/>• ") else "None",
        "<br/><b>To Consequences:</b><br/>• ",
        if(length(consequences_connected) > 0) paste(consequences_connected, collapse = "<br/>• ") else "None"
      )
    }
    idx <- idx + n_pressures
  }
  
  # Consequence nodes (right side) - Improved
  if (n_consequences > 0) {
    cons_colors <- if (show_risk_levels) {
      sapply(consequences, function(c) {
        risk <- hazard_data$Risk_Level[hazard_data$Consequence == c][1]
        getRiskColor(risk, TRUE)
      })
    } else {
      rep(CONSEQUENCE_COLOR, n_consequences)
    }

    cons_indices <- idx:(idx + n_consequences - 1)
    ids[cons_indices] <- 200 + seq_len(n_consequences)
    labels[cons_indices] <- sapply(consequences, wrap_label, max_width = 18)
    groups[cons_indices] <- "consequence"
    colors[cons_indices] <- cons_colors
    shapes[cons_indices] <- "hexagon"
    sizes[cons_indices] <- node_size * 0.85  # Reduced from node_size
    font_sizes[cons_indices] <- 11  # Reduced from 12

    # Set positions for consequences (right side) - FURTHER INCREASED SPACING
    x_coords[cons_indices] <- 400  # Increased from 300
    # Spread consequences vertically - FURTHER INCREASED SPACING
    y_spacing <- if (n_consequences > 1) 220 else 0  # Increased from 150
    y_coords[cons_indices] <- seq(-(n_consequences - 1) * y_spacing / 2,
                                   (n_consequences - 1) * y_spacing / 2,
                                   length.out = n_consequences)

    # Add tooltips for consequences
    for (i in seq_len(n_consequences)) {
      consequence_name <- consequences[i]
      consequence_data <- hazard_data[hazard_data$Consequence == consequence_name, ]
      risk_level <- if(nrow(consequence_data) > 0) consequence_data$Risk_Level[1] else "Unknown"
      pressures_connected <- unique(consequence_data$Pressure[consequence_data$Pressure != ""])

      titles[cons_indices[i]] <- paste0(
        "<b>Consequence:</b><br/>", consequence_name,
        "<br/><br/><b>Type:</b> Environmental Impact<br/>",
        "<b>Risk Level:</b> ", risk_level, "<br/>",
        "<b>Node ID:</b> ", 200 + i, "<br/>",
        "<b>From Pressures:</b><br/>• ",
        if(length(pressures_connected) > 0) paste(pressures_connected, collapse = "<br/>• ") else "None"
      )
    }
    idx <- idx + n_consequences
  }
  
  # Improved barrier and escalation factor nodes
  if (show_barriers) {
    if (exists("preventive_controls") && length(preventive_controls) > 0) {
      prev_indices <- idx:(idx + length(preventive_controls) - 1)
      ids[prev_indices] <- 300 + seq_len(length(preventive_controls))
      labels[prev_indices] <- sapply(preventive_controls, wrap_label, max_width = 16)
      groups[prev_indices] <- "preventive_control"
      colors[prev_indices] <- PREVENTIVE_COLOR
      shapes[prev_indices] <- "square"
      sizes[prev_indices] <- node_size * 0.7  # Reduced from 0.8
      font_sizes[prev_indices] <- 9  # Reduced from 10

      # Set positions for preventive controls (between activities/pressures and central problem) - FURTHER INCREASED SPACING
      x_coords[prev_indices] <- -200  # Increased from -150
      # Spread preventive controls vertically - FURTHER INCREASED SPACING
      y_spacing <- if (length(preventive_controls) > 1) 180 else 0  # Increased from 120
      y_coords[prev_indices] <- seq(-(length(preventive_controls) - 1) * y_spacing / 2,
                                     (length(preventive_controls) - 1) * y_spacing / 2,
                                     length.out = length(preventive_controls))

      # Add tooltips for preventive controls
      for (i in seq_len(length(preventive_controls))) {
        control_name <- preventive_controls[i]
        titles[prev_indices[i]] <- paste0(
          "<b>Preventive Control:</b><br/>", control_name,
          "<br/><br/><b>Type:</b> Mitigation Measure<br/>",
          "<b>Function:</b> Prevents threat escalation<br/>",
          "<b>Node ID:</b> ", 300 + i, "<br/>",
          "<b>Purpose:</b> Block or reduce risk pathways"
        )
      }
      idx <- idx + length(preventive_controls)
    }

    if (exists("escalation_factors") && length(escalation_factors) > 0) {
      esc_indices <- idx:(idx + length(escalation_factors) - 1)
      ids[esc_indices] <- 350 + seq_len(length(escalation_factors))
      labels[esc_indices] <- sapply(escalation_factors, wrap_label, max_width = 16)
      groups[esc_indices] <- "escalation_factor"
      colors[esc_indices] <- ESCALATION_COLOR
      shapes[esc_indices] <- "triangleDown"
      sizes[esc_indices] <- node_size * 0.7  # Reduced from 0.8
      font_sizes[esc_indices] <- 9  # Reduced from 10

      # Set positions for escalation factors (near preventive controls) - FURTHER INCREASED SPACING
      x_coords[esc_indices] <- -200  # Increased from -150
      # Spread escalation factors vertically (offset from preventive controls) - FURTHER INCREASED SPACING
      y_spacing <- if (length(escalation_factors) > 1) 180 else 0  # Increased from 120
      y_offset <- if (exists("preventive_controls") && length(preventive_controls) > 0) 300 else 0  # Increased from 220
      y_coords[esc_indices] <- seq(-(length(escalation_factors) - 1) * y_spacing / 2,
                                    (length(escalation_factors) - 1) * y_spacing / 2,
                                    length.out = length(escalation_factors)) + y_offset

      # Add tooltips for escalation factors
      for (i in seq_len(length(escalation_factors))) {
        escalation_name <- escalation_factors[i]
        titles[esc_indices[i]] <- paste0(
          "<b>Escalation Factor:</b><br/>", escalation_name,
          "<br/><br/><b>Type:</b> Risk Amplifier<br/>",
          "<b>Function:</b> Weakens control effectiveness<br/>",
          "<b>Node ID:</b> ", 350 + i, "<br/>",
          "<b>Effect:</b> Reduces effectiveness of both<br/>",
          "preventive controls AND protective mitigations"
        )
      }
      idx <- idx + length(escalation_factors)
    }

    # ENHANCED Protective Mitigation nodes
    if (exists("protective_mitigations") && length(protective_mitigations) > 0) {
      prot_indices <- idx:(idx + length(protective_mitigations) - 1)
      ids[prot_indices] <- 400 + seq_len(length(protective_mitigations))
      labels[prot_indices] <- sapply(protective_mitigations, wrap_label, max_width = 16)
      groups[prot_indices] <- "protective_mitigation"
      colors[prot_indices] <- PROTECTIVE_COLOR
      shapes[prot_indices] <- "square"
      sizes[prot_indices] <- node_size * 0.75  # Reduced from 0.9
      font_sizes[prot_indices] <- 10  # Reduced from 11

      # Set positions for protective mitigations (between central problem and consequences) - FURTHER INCREASED SPACING
      x_coords[prot_indices] <- 200  # Increased from 150
      # Spread protective mitigations vertically - FURTHER INCREASED SPACING
      y_spacing <- if (length(protective_mitigations) > 1) 180 else 0  # Increased from 120
      y_coords[prot_indices] <- seq(-(length(protective_mitigations) - 1) * y_spacing / 2,
                                     (length(protective_mitigations) - 1) * y_spacing / 2,
                                     length.out = length(protective_mitigations))

      # Add tooltips for protective mitigations
      for (i in seq_len(length(protective_mitigations))) {
        mitigation_name <- protective_mitigations[i]
        titles[prot_indices[i]] <- paste0(
          "<b>Protective Mitigation:</b><br/>", mitigation_name,
          "<br/><br/><b>Type:</b> Recovery Measure<br/>",
          "<b>Function:</b> Reduces consequence severity<br/>",
          "<b>Node ID:</b> ", 400 + i, "<br/>",
          "<b>Purpose:</b> Minimize impact after occurrence"
        )
      }

      cat("🔗 Created", length(protective_mitigations), "protective mitigation nodes\n")
    }
  }
  
  nodes <- data.frame(
    id = ids,
    label = labels,
    group = groups,
    color = colors,
    shape = shapes,
    size = sizes,
    font.size = font_sizes,
    title = titles,
    x = x_coords,
    y = y_coords,
    stringsAsFactors = FALSE
  )
  
  cat("✅ Created", nrow(nodes), "total nodes for Updated bowtie\n")
  
  # Cache the result
  assign(cache_key, nodes, envir = .cache)
  nodes
}

# Backward compatibility function
# Backward compatibility alias removed - use createBowtieNodesFixed() directly

# Updated edge creation function with PROPER protective mitigation connections
createBowtieEdgesFixed <- function(hazard_data, show_barriers) {
  # Create a unique cache key that includes mitigation data for proper caching
  if(!requireNamespace("digest", quietly = TRUE)) {
    # If digest package is not available, create a simple hash
    mitigation_hash <- paste(hazard_data$Protective_Mitigation, collapse = "_")
    mitigation_hash <- substr(mitigation_hash, 1, 50)  # Truncate for cache key
  } else {
    mitigation_hash <- digest::digest(hazard_data$Protective_Mitigation)
  }
  
  cache_key <- paste0("edges_updated_v430_", nrow(hazard_data), "_", show_barriers, "_", mitigation_hash)
  if (exists(cache_key, envir = .cache)) {
    cat("📋 Using cached edges\n")
    return(get(cache_key, envir = .cache))
  }
  
  cat("🔧 Creating Updated bowtie edges with improved protective mitigation connections\n")
  
  activities <- unique(hazard_data$Activity[hazard_data$Activity != ""])
  pressures <- unique(hazard_data$Pressure[hazard_data$Pressure != ""])
  consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
  
  # Initialize edge vectors
  from <- integer(0)
  to <- integer(0)
  arrows <- character(0)
  colors <- character(0)
  widths <- numeric(0)
  dashes <- logical(0)
  titles <- character(0)  # For edge tooltips
  
  if (!show_barriers) {
    # Simple flow: Activity → Pressure → Central Problem → Consequence

    # Activity → Pressure connections
    for (i in seq_along(activities)) {
      activity <- activities[i]
      related_pressures <- hazard_data$Pressure[hazard_data$Activity == activity]
      for (pressure in related_pressures) {
        pressure_idx <- which(pressures == pressure)
        if (length(pressure_idx) > 0) {
          from <- c(from, 50 + i)
          to <- c(to, 100 + pressure_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#8E44AD")
          widths <- c(widths, 2)
          dashes <- c(dashes, FALSE)
          titles <- c(titles, paste0(
            "<b>Activity → Pressure Link</b><br/>",
            "<b>From:</b> ", activity, "<br/>",
            "<b>To:</b> ", pressure, "<br/>",
            "<b>Type:</b> Causal relationship<br/>",
            "<b>Risk:</b> Activity generates pressure"
          ))
        }
      }
    }
    
    # Pressure → Central Problem connections
    for (i in seq_along(pressures)) {
      pressure <- pressures[i]
      from <- c(from, 100 + i)
      to <- c(to, 1)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#E74C3C")
      widths <- c(widths, 3)
      dashes <- c(dashes, FALSE)
      titles <- c(titles, paste0(
        "<b>Pressure → Central Problem</b><br/>",
        "<b>From:</b> ", pressure, "<br/>",
        "<b>To:</b> Central Environmental Problem<br/>",
        "<b>Type:</b> Contributing threat<br/>",
        "<b>Effect:</b> Pressure contributes to problem"
      ))
    }
    
    # Central Problem → Consequence connections
    for (i in seq_along(consequences)) {
      consequence <- consequences[i]
      from <- c(from, 1)
      to <- c(to, 200 + i)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#C0392B")
      widths <- c(widths, 3)
      dashes <- c(dashes, FALSE)
      titles <- c(titles, paste0(
        "<b>Central Problem → Consequence</b><br/>",
        "<b>From:</b> Central Environmental Problem<br/>",
        "<b>To:</b> ", consequence, "<br/>",
        "<b>Type:</b> Impact manifestation<br/>",
        "<b>Effect:</b> Problem leads to environmental impact"
      ))
    }
    
  } else {
    # Updated Complex flow with PROPER protective mitigation mapping
    
    preventive_controls <- unique(hazard_data$Preventive_Control[hazard_data$Preventive_Control != ""])
    escalation_factors <- unique(hazard_data$Escalation_Factor[hazard_data$Escalation_Factor != ""])
    protective_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Protective_Mitigation != ""])
    
    cat("🛡️ Found", length(protective_mitigations), "unique protective mitigations\n")
    cat("🎯 Found", length(consequences), "unique consequences\n")
    
    # Activity → Pressure connections
    for (i in seq_along(activities)) {
      activity <- activities[i]
      related_pressures <- hazard_data$Pressure[hazard_data$Activity == activity]
      for (pressure in related_pressures) {
        pressure_idx <- which(pressures == pressure)
        if (length(pressure_idx) > 0) {
          from <- c(from, 50 + i)
          to <- c(to, 100 + pressure_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#8E44AD")
          widths <- c(widths, 2)
          dashes <- c(dashes, FALSE)
          titles <- c(titles, paste0(
            "<b>Activity → Pressure Link</b><br/>",
            "<b>From:</b> ", activity, "<br/>",
            "<b>To:</b> ", pressure, "<br/>",
            "<b>Type:</b> Causal relationship (Complex flow)<br/>",
            "<b>Note:</b> Can be mitigated by preventive controls"
          ))
        }
      }
    }
    
    # Improved Pressure → Multiple Preventive Controls pathway
    for (i in seq_along(pressures)) {
      pressure <- pressures[i]
      # Get ALL controls for this pressure (not just the first one)
      controls_for_pressure <- unique(hazard_data$Preventive_Control[hazard_data$Pressure == pressure])
      controls_for_pressure <- controls_for_pressure[!is.na(controls_for_pressure) & controls_for_pressure != ""]
      escalation_for_pressure <- hazard_data$Escalation_Factor[hazard_data$Pressure == pressure][1]

      # Create links to multiple preventive controls if they exist
      if (length(controls_for_pressure) > 0) {
        for (control_name in controls_for_pressure) {
          control_idx <- which(preventive_controls == control_name)
          if (length(control_idx) > 0) {
            # Pressure → Preventive Control
            from <- c(from, 100 + i)
            to <- c(to, 300 + control_idx)
            arrows <- c(arrows, "to")
            colors <- c(colors, "#E74C3C")  # Red for pressure-control link
            widths <- c(widths, 2)
            dashes <- c(dashes, FALSE)
            titles <- c(titles, paste0(
              "<b>Pressure → Control</b><br/>",
              "<b>From:</b> ", pressure, "<br/>",
              "<b>To:</b> ", control_name
            ))
            
            # Control failure path to central problem
            # (Escalation factors will connect TO controls separately)
            from <- c(from, 300 + control_idx)
            to <- c(to, 1)
            arrows <- c(arrows, "to")
            colors <- c(colors, "#E74C3C")  # Red for control failure
            widths <- c(widths, 1.5)
            dashes <- c(dashes, TRUE)  # Dashed for failure pathway
            titles <- c(titles, paste0(
              "<b>Control Failure → Central Problem</b><br/>",
              "<b>From:</b> ", control_name, "<br/>",
              "<b>To:</b> Central Problem<br/>",
              "<b>Note:</b> Control failure leads to problem"
            ))
          }
        }
      } else {
        # Direct pressure → central problem if no control
        from <- c(from, 100 + i)
        to <- c(to, 1)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#E74C3C")
        widths <- c(widths, 3)
        dashes <- c(dashes, FALSE)
        titles <- c(titles, paste0(
          "<b>Pressure → Central (No Control)</b><br/>",
          "<b>From:</b> ", pressure, "<br/>",
          "<b>To:</b> Central Problem"
        ))
      }
    }
    
    # CRITICAL: Connect ALL escalation factors to their respective controls
    # Escalation factors impact controls, causing them to fail
    for (i in seq_len(nrow(hazard_data))) {
      row <- hazard_data[i, ]
      escalation <- row$Escalation_Factor
      control <- row$Preventive_Control

      if (!is.na(escalation) && escalation != "" && !is.na(control) && control != "") {
        escalation_idx <- which(escalation_factors == escalation)
        control_idx <- which(preventive_controls == control)

        if (length(escalation_idx) > 0 && length(control_idx) > 0) {
          # Escalation Factor → Control (escalation affects control effectiveness)
          from <- c(from, 350 + escalation_idx)
          to <- c(to, 300 + control_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#F39C12")  # Orange for escalation impact
          widths <- c(widths, 2)
          dashes <- c(dashes, TRUE)  # Dashed to show negative impact
          titles <- c(titles, paste0(
            "<b>Escalation → Control</b><br/>",
            "<b>From:</b> ", escalation, "<br/>",
            "<b>To:</b> ", control, "<br/>",
            "<b>Effect:</b> Reduces control effectiveness"
          ))
        }
      }
    }
    
    # Updated: Central Problem → Protective Mitigation → Consequence pathway
    # ENHANCED row-wise mapping with validation
    
    mitigation_connections <- 0
    direct_connections <- 0
    
    # Create a mapping table for better tracking
    mitigation_map <- data.frame(
      row_id = seq_len(nrow(hazard_data)),
      consequence = hazard_data$Consequence,
      mitigation = hazard_data$Protective_Mitigation,
      stringsAsFactors = FALSE
    )
    
    cat("🔍 Processing", nrow(mitigation_map), "mitigation mappings\n")
    
    # Method 1: Improved row-wise mapping with validation
    for (i in seq_len(nrow(hazard_data))) {
      row <- hazard_data[i, ]
      consequence <- row$Consequence
      mitigation <- row$Protective_Mitigation
      
      if (!is.na(consequence) && consequence != "" && !is.na(mitigation) && mitigation != "") {
        consequence_idx <- which(consequences == consequence)
        mitigation_idx <- which(protective_mitigations == mitigation)
        
        if (length(consequence_idx) > 0 && length(mitigation_idx) > 0) {
          # Central Problem → Protective Mitigation (improved width)
          from <- c(from, 1)
          to <- c(to, 400 + mitigation_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#C0392B")
          widths <- c(widths, 3)  # Improved width
          dashes <- c(dashes, FALSE)
          titles <- c(titles, paste0(
            "<b>Central → Mitigation</b><br/>",
            "<b>From:</b> Central Problem<br/>",
            "<b>To:</b> ", substr(mitigation, 1, 40), "..."
          ))

          # Protective Mitigation → Consequence (improved connection)
          from <- c(from, 400 + mitigation_idx)
          to <- c(to, 200 + consequence_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#3498DB")
          widths <- c(widths, 3)  # Improved width
          dashes <- c(dashes, TRUE)  # Dashed to show intervention effect
          titles <- c(titles, paste0(
            "<b>Mitigation → Consequence</b><br/>",
            "<b>From:</b> ", substr(mitigation, 1, 40), "...<br/>",
            "<b>To:</b> ", consequence
          ))

          mitigation_connections <- mitigation_connections + 1
          cat("✅ Connected mitigation", mitigation_idx, "('", substr(mitigation, 1, 30), "...') to consequence", consequence_idx, "('", consequence, "')\n")
        }
      }
    }

    # Connect escalation factors to protective mitigations (right side of bowtie)
    # Escalation factors can weaken both preventive controls (left) AND protective mitigations (right)
    cat("🔗 Connecting escalation factors to protective mitigations...\n")
    escalation_mitigation_connections <- 0

    for (i in seq_len(nrow(hazard_data))) {
      row <- hazard_data[i, ]
      escalation <- row$Escalation_Factor
      mitigation <- row$Protective_Mitigation

      if (!is.na(escalation) && escalation != "" && !is.na(mitigation) && mitigation != "") {
        escalation_idx <- which(escalation_factors == escalation)
        mitigation_idx <- which(protective_mitigations == mitigation)

        if (length(escalation_idx) > 0 && length(mitigation_idx) > 0) {
          # Escalation Factor → Protective Mitigation (escalation weakens mitigation effectiveness)
          from <- c(from, 350 + escalation_idx)
          to <- c(to, 400 + mitigation_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#F39C12")  # Orange for escalation impact
          widths <- c(widths, 2)
          dashes <- c(dashes, TRUE)  # Dashed to show negative impact
          titles <- c(titles, paste0(
            "<b>Escalation → Protective Mitigation</b><br/>",
            "<b>From:</b> ", escalation, "<br/>",
            "<b>To:</b> ", substr(mitigation, 1, 40), "...<br/>",
            "<b>Effect:</b> Reduces mitigation effectiveness"
          ))
          escalation_mitigation_connections <- escalation_mitigation_connections + 1
        }
      }
    }

    if (escalation_mitigation_connections > 0) {
      cat("✅ Created", escalation_mitigation_connections, "escalation → protective mitigation connections\n")
    }

    # Method 2: Add remaining direct connections for consequences without proper mitigation
    for (i in seq_along(consequences)) {
      consequence <- consequences[i]
      # Check if this consequence already has a proper mitigation connection
      has_proper_mitigation <- any(hazard_data$Consequence == consequence &
                                   !is.na(hazard_data$Protective_Mitigation) &
                                   hazard_data$Protective_Mitigation != "" &
                                   nchar(hazard_data$Protective_Mitigation) > 10)  # Improved validation

      if (!has_proper_mitigation) {
        # Direct central problem → consequence if no proper mitigation
        from <- c(from, 1)
        to <- c(to, 200 + i)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#C0392B")
        widths <- c(widths, 3)
        dashes <- c(dashes, FALSE)
        titles <- c(titles, paste0(
          "<b>Central → Consequence (No Mitigation)</b><br/>",
          "<b>From:</b> Central Problem<br/>",
          "<b>To:</b> ", consequence
        ))
        direct_connections <- direct_connections + 1
        cat("⚠️ Direct connection to consequence", i, "('", consequence, "') - no proper mitigation\n")
      }
    }
    
    cat("📊 Connection Summary:\n")
    cat("   🔗 Central → Mitigation connections:", mitigation_connections, "\n")
    cat("   ⚡ Escalation → Mitigation connections:", escalation_mitigation_connections, "\n")
    cat("   ➡️ Direct consequence connections:", direct_connections, "\n")
  }
  
  edges <- data.frame(
    from = from,
    to = to,
    arrows = arrows,
    color = colors,
    width = widths,
    dashes = dashes,
    title = titles,
    stringsAsFactors = FALSE
  )
  
  cat("✅ Created", nrow(edges), "edges with protective mitigation connections\n")
  
  # Cache the result
  assign(cache_key, edges, envir = .cache)
  edges
}

# Backward compatibility function
# Backward compatibility alias removed - use createBowtieEdgesFixed() directly

# Improved function to create a default row for data editing with granular risks
createDefaultRowFixed <- function(selected_problem = "New Environmental Risk") {
  new_row <- data.frame(
    Activity = "New Improved Activity",
    Pressure = "New Improved Pressure",
    Preventive_Control = "New Improved Preventive Control",
    Escalation_Factor = "New Improved Escalation Factor",
    Central_Problem = selected_problem,
    Problem = selected_problem,
    Protective_Mitigation = "New Updated Protective Mitigation with improved mapping",
    Consequence = "New Improved Consequence",

    # Granular connection risks
    Activity_to_Pressure_Likelihood = 3L,
    Activity_to_Pressure_Severity = 3L,
    Pressure_to_Control_Likelihood = 2L,
    Pressure_to_Control_Severity = 4L,
    Control_to_Escalation_Likelihood = 2L,
    Control_to_Escalation_Severity = 4L,
    Escalation_to_Central_Likelihood = 3L,
    Escalation_to_Central_Severity = 4L,
    Central_to_Mitigation_Likelihood = 2L,
    Central_to_Mitigation_Severity = 4L,
    Escalation_to_Mitigation_Likelihood = 2L,
    Escalation_to_Mitigation_Severity = 3L,
    Mitigation_to_Consequence_Likelihood = 2L,
    Mitigation_to_Consequence_Severity = 3L,

    # Calculated overall values
    Overall_Likelihood = 3L,
    Overall_Severity = 4L,

    # Legacy columns for backward compatibility
    Likelihood = 3L,
    Severity = 4L,
    Threat_Likelihood = 3L,
    Consequence_Severity = 4L,
    Risk_Rating = 12,
    Risk_Level = "Medium",
    stringsAsFactors = FALSE
  )
  
  return(new_row)
}

# Backward compatibility function
# Backward compatibility alias removed - use createDefaultRowFixed() directly

# Detailed numeric validation (returns list) used by server
validateNumericInputDetailed <- function(value, min_val = 1L, max_val = 5L) {
  num_value <- suppressWarnings(as.integer(value))
  if (is.na(num_value) || num_value < min_val || num_value > max_val) {
    list(valid = FALSE, value = NULL,
         message = paste("❌ Value must be between", min_val, "and", max_val))
  } else {
    list(valid = TRUE, value = num_value, message = NULL)
  }
}

# Backwards-compatible simple numeric validator (used by tests)
validateNumericInput <- function(value, min_val = 1L, max_val = 5L) {
  num_value <- suppressWarnings(as.integer(value))
  if (is.na(num_value)) return(min_val)
  if (num_value < min_val) return(min_val)
  if (num_value > max_val) return(max_val)
  num_value
} 

# Improved data summary function with granular connection analysis
getDataSummaryFixed <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(NULL)

  # Prefer Problem if present, otherwise Central_Problem
  problem_col <- ifelse("Problem" %in% names(data), "Problem", "Central_Problem")
  if (!(problem_col %in% names(data))) return(NULL)

  # Ensure Risk_Rating is available; compute if necessary
  if (!"Risk_Rating" %in% names(data)) data$Risk_Rating <- ifelse(!is.na(data$Overall_Likelihood & data$Overall_Severity), data$Overall_Likelihood * data$Overall_Severity, ifelse(!is.na(data$Likelihood & data$Severity), data$Likelihood * data$Severity, NA))

  summary_df <- data %>%
    dplyr::group_by(!!rlang::sym(problem_col)) %>%
    dplyr::summarise(Total_Entries = dplyr::n(), Avg_Risk_Rating = mean(Risk_Rating, na.rm = TRUE)) %>%
    dplyr::rename(Problem = !!rlang::sym(problem_col)) %>%
    as.data.frame()

  return(summary_df)
}

# Backward compatibility function
# Backward compatibility alias removed - use getDataSummaryFixed() directly

# Improved validation function for protective mitigations
validateProtectiveMitigations <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(list(valid = TRUE, issues = character(0)))
  
  issues <- character(0)
  
  # Check for empty or too short mitigations
  empty_mitigations <- sum(is.na(data$Protective_Mitigation) | data$Protective_Mitigation == "" | nchar(data$Protective_Mitigation) < 10)
  if (empty_mitigations > 0) {
    issues <- c(issues, paste("⚠️", empty_mitigations, "rows have inadequate protective mitigations"))
  }
  
  # Check for duplicate consequence-mitigation pairs (should be one-to-one)
  consequence_mitigation_pairs <- paste(data$Consequence, data$Protective_Mitigation, sep = " | ")
  duplicate_pairs <- sum(duplicated(consequence_mitigation_pairs))
  if (duplicate_pairs > 0) {
    issues <- c(issues, paste("⚠️", duplicate_pairs, "duplicate consequence-mitigation pairs found"))
  }
  
  # Check mapping quality
  unique_consequences <- length(unique(data$Consequence))
  unique_mitigations <- length(unique(data$Protective_Mitigation[data$Protective_Mitigation != ""]))
  mapping_ratio <- unique_mitigations / unique_consequences
  
  if (mapping_ratio < 0.8) {
    issues <- c(issues, paste("⚠️ Low mitigation coverage: only", round(mapping_ratio * 100, 1), "% of consequences have unique mitigations"))
  } else {
    issues <- c(issues, paste("✅ Good mitigation coverage:", round(mapping_ratio * 100, 1), "% - Updated quality"))
  }
  
  list(valid = length(issues) == 0, issues = issues)
}

# NEW: Generate data with multiple preventive controls per pressure
generateEnvironmentalDataWithMultipleControls <- function(scenario_key = NULL) {
  cat("🔄 Generating data with MULTIPLE PREVENTIVE CONTROLS per pressure\n")

  # If a scenario is provided, use it as the base and expand controls
  if (!is.null(scenario_key) && scenario_key != "") {
    tryCatch({
      # Use generateScenarioSpecificBowtie to get base scenario data
      base_scenario <- generateScenarioSpecificBowtie(scenario_key)
      if (!is.null(base_scenario) && nrow(base_scenario) > 0) {
        cat("📋 Using scenario:", scenario_key, "\n")

        # Define scenario-specific control variations
        preventive_variations <- switch(scenario_key,
          "marine_pollution" = list(
            suffix = c("(routine operations)", "(emergency response)", "(enhanced monitoring)"),
            alternatives = c("Vessel inspection programs", "Port reception facilities", "Marine spatial planning")
          ),
          "industrial_contamination" = list(
            suffix = c("(primary treatment)", "(secondary treatment)", "(advanced filtration)"),
            alternatives = c("Effluent quality monitoring", "Chemical storage protocols", "Spill containment systems")
          ),
          "oil_spills" = list(
            suffix = c("(prevention phase)", "(detection phase)", "(containment phase)"),
            alternatives = c("Automatic identification systems", "Oil spill detection sensors", "Boom deployment readiness")
          ),
          "agricultural_runoff" = list(
            suffix = c("(source reduction)", "(transport interception)", "(field-level)"),
            alternatives = c("Nutrient management plans", "Constructed treatment wetlands", "Contour farming practices")
          ),
          "overfishing_depletion" = list(
            suffix = c("(catch limits)", "(spatial management)", "(gear restrictions)"),
            alternatives = c("Electronic monitoring systems", "Observer programs", "Mesh size regulations")
          ),
          "martinique_coastal_erosion" = list(
            suffix = c("(soft engineering)", "(hard engineering)", "(regulatory)"),
            alternatives = c("Beach sand renourishment", "Seawall construction", "Building setback enforcement")
          ),
          "martinique_sargassum" = list(
            suffix = c("(prediction)", "(interception)", "(removal)"),
            alternatives = c("Satellite monitoring systems", "Offshore collection vessels", "Beach grooming equipment")
          ),
          "martinique_coral_degradation" = list(
            suffix = c("(prevention)", "(active management)", "(enforcement)"),
            alternatives = c("Water quality standards", "Coral nursery establishment", "Patrol vessel operations")
          ),
          "martinique_watershed_pollution" = list(
            suffix = c("(agricultural BMPs)", "(regulatory)", "(treatment)"),
            alternatives = c("Integrated pest management", "Buffer strip requirements", "Vegetated filter strips")
          ),
          "martinique_mangrove_loss" = list(
            suffix = c("(protection)", "(restoration)", "(management)"),
            alternatives = c("No-development zones", "Seedling propagation", "Community stewardship")
          ),
          "martinique_hurricane_impacts" = list(
            suffix = c("(structural)", "(non-structural)", "(preparedness)"),
            alternatives = c("Storm shutters requirements", "Evacuation route planning", "Emergency supply caching")
          ),
          "martinique_marine_tourism" = list(
            suffix = c("(infrastructure)", "(regulation)", "(education)"),
            alternatives = c("Permanent mooring installations", "Visitor permit systems", "Dive guide certification")
          ),
          # Default
          list(
            suffix = c("(primary measure)", "(secondary measure)", "(backup measure)"),
            alternatives = c("Monitoring and detection", "Containment protocols", "Response procedures")
          )
        )
        
        protective_variations <- switch(scenario_key,
          "marine_pollution" = list(
            suffix = c("(immediate)", "(short-term)", "(long-term)"),
            alternatives = c("Emergency cleanup crews", "Habitat assessment teams", "Ecosystem monitoring programs")
          ),
          "industrial_contamination" = list(
            suffix = c("(containment)", "(treatment)", "(recovery)"),
            alternatives = c("Excavation and disposal", "In-situ bioremediation", "Groundwater extraction")
          ),
          "oil_spills" = list(
            suffix = c("(response)", "(cleanup)", "(restoration)"),
            alternatives = c("Skimmer vessel deployment", "Shoreline protection teams", "Natural attenuation monitoring")
          ),
          "agricultural_runoff" = list(
            suffix = c("(treatment)", "(diversion)", "(restoration)"),
            alternatives = c("Aeration systems", "Bypass channels", "Native vegetation planting")
          ),
          "overfishing_depletion" = list(
            suffix = c("(recovery)", "(habitat)", "(livelihood)"),
            alternatives = c("No-take zones", "Artificial reef deployment", "Fisher retraining programs")
          ),
          "martinique_coastal_erosion" = list(
            suffix = c("(emergency)", "(temporary)", "(permanent)"),
            alternatives = c("Sandbag placement", "Geotextile installation", "Living shoreline creation")
          ),
          "martinique_sargassum" = list(
            suffix = c("(mechanical)", "(manual)", "(repurposing)"),
            alternatives = c("Front-loader operations", "Community cleanup brigades", "Composting facilities")
          ),
          "martinique_coral_degradation" = list(
            suffix = c("(transplantation)", "(propagation)", "(adaptation)"),
            alternatives = c("Fragment reattachment", "Micro-fragmentation", "Heat-resistant strain selection")
          ),
          "martinique_watershed_pollution" = list(
            suffix = c("(water treatment)", "(soil remediation)", "(health)"),
            alternatives = c("Activated carbon filtration", "Phytoremediation plots", "Blood testing programs")
          ),
          "martinique_mangrove_loss" = list(
            suffix = c("(replanting)", "(hydrology)", "(succession)"),
            alternatives = c("Propagule direct planting", "Tidal flow restoration", "Natural regeneration zones")
          ),
          "martinique_hurricane_impacts" = list(
            suffix = c("(rescue)", "(assessment)", "(rebuilding)"),
            alternatives = c("Search and rescue teams", "Structural engineers deployment", "Reconstruction financing")
          ),
          "martinique_marine_tourism" = list(
            suffix = c("(active restoration)", "(passive recovery)", "(alternative sites)"),
            alternatives = c("Coral gardening projects", "Site closure programs", "New dive site development")
          ),
          # Default
          list(
            suffix = c("(immediate response)", "(recovery phase)", "(long-term restoration)"),
            alternatives = c("Emergency procedures", "Impact assessment", "Monitoring programs")
          )
        )

        # Expand the scenario with multiple DIFFERENT controls per pressure
        expanded_data <- do.call(rbind, lapply(1:nrow(base_scenario), function(i) {
          row <- base_scenario[i, ]
          # Create 2-3 variations with different controls
          num_controls <- sample(2:3, 1)

          replicated_rows <- do.call(rbind, replicate(num_controls, row, simplify = FALSE))
          
          # Create diverse preventive controls
          if (num_controls <= length(preventive_variations$suffix)) {
            # Use suffixes for first approach
            replicated_rows$Preventive_Control <- paste0(row$Preventive_Control, " ", preventive_variations$suffix[1:num_controls])
          } else {
            # Mix suffixes and alternatives
            replicated_rows$Preventive_Control[1] <- paste0(row$Preventive_Control, " ", preventive_variations$suffix[1])
            replicated_rows$Preventive_Control[2:num_controls] <- preventive_variations$alternatives[1:(num_controls-1)]
          }
          
          # Create diverse protective mitigations
          if (num_controls <= length(protective_variations$suffix)) {
            replicated_rows$Protective_Mitigation <- paste0(row$Protective_Mitigation, " ", protective_variations$suffix[1:num_controls])
          } else {
            replicated_rows$Protective_Mitigation[1] <- paste0(row$Protective_Mitigation, " ", protective_variations$suffix[1])
            replicated_rows$Protective_Mitigation[2:num_controls] <- protective_variations$alternatives[1:(num_controls-1)]
          }
          
          # Also update Protective_Control if it exists
          if ("Protective_Control" %in% names(replicated_rows)) {
            replicated_rows$Protective_Control <- replicated_rows$Protective_Mitigation
          }
          
          return(replicated_rows)
        }))

        cat("✅ Expanded to", nrow(expanded_data), "rows with multiple DIFFERENT controls\n")
        return(expanded_data)
      }
    }, error = function(e) {
      cat("⚠️ Error using scenario:", scenario_key, "-", e$message, "\n")
      cat("📋 Falling back to default scenario\n")
    })
  }
  
  # Default fallback: generate water pollution scenario with multiple controls
  cat("📋 Using default water pollution scenario with multiple controls\n")
  
  # Define pressure-control relationships (2 controls per activity for tidier diagram)
  pressure_control_data <- data.frame(
    Activity = c(
      # Nutrient enrichment activities
      rep("Agricultural fertilizer application", 2),
      rep("Municipal wastewater discharge", 2), 
      rep("Septic system failures", 2),
      
      # Toxic chemical exposure activities  
      rep("Pesticide use on crops", 2),
      rep("Industrial chemical discharge", 2),
      
      # Habitat fragmentation activities
      rep("Habitat conversion for development", 2),
      rep("Infrastructure development", 2),
      
      # Polluted runoff activities
      rep("Urban stormwater runoff", 2),
      rep("Construction site runoff", 2)
    ),
    
    Pressure = c(
      # Nutrient enrichment pressure (6 entries)
      rep("Nutrient enrichment", 6),
      
      # Toxic chemical exposure pressure (4 entries)
      rep("Toxic chemical exposure", 4),
      
      # Habitat fragmentation pressure (4 entries) 
      rep("Habitat fragmentation", 4),
      
      # Polluted runoff pressure (4 entries)
      rep("Polluted runoff", 4)
    ),
    
    Preventive_Control = c(
      # Nutrient enrichment controls (2 per activity = 6 total)
      "Precision fertilizer application systems", "Cover crop rotation programs",
      "Advanced nutrient removal technology", "Phosphorus reduction programs", 
      "Septic system inspections", "Alternative septic technologies",
      
      # Toxic chemical exposure controls (2 per activity = 4 total)
      "Integrated pest management", "Organic farming certification",
      "Industrial discharge permits", "Real-time monitoring systems",
      
      # Habitat fragmentation controls (2 per activity = 4 total)
      "Wildlife corridors creation", "Protected area designation",
      "Green infrastructure requirements", "Environmental impact assessments",
      
      # Polluted runoff controls (2 per activity = 4 total)
      "Green infrastructure systems", "Constructed wetlands",
      "Erosion and sediment control", "Construction best practices"
    ),
    
    stringsAsFactors = FALSE
  )
  
  # Add other required columns
  n_rows <- nrow(pressure_control_data)
  
  pressure_control_data$Escalation_Factor <- sample(c(
    "Heavy rainfall events", "Equipment failure", "Climate change impacts", 
    "Infrastructure aging", "Human error", "Extreme weather", "Drought conditions"
  ), n_rows, replace = TRUE)
  
  pressure_control_data$Central_Problem <- "Water Pollution"
  
  pressure_control_data$Consequence <- sample(c(
    "Algal blooms and dead zones", "Fish kills and biodiversity loss", 
    "Drinking water contamination", "Beach closures and health risks",
    "Economic losses to fisheries", "Ecosystem degradation"
  ), n_rows, replace = TRUE)
  
  pressure_control_data$Protective_Mitigation <- sample(c(
    "Emergency response systems", "Water quality monitoring", "Public health advisories",
    "Environmental restoration", "Economic recovery programs", "Alternative water supplies"
  ), n_rows, replace = TRUE)
  
  pressure_control_data$Threat_Likelihood <- sample(1:5, n_rows, replace = TRUE)
  pressure_control_data$Consequence_Severity <- sample(1:5, n_rows, replace = TRUE)
  pressure_control_data$Risk_Level <- pressure_control_data$Threat_Likelihood * pressure_control_data$Consequence_Severity
  
  # Add default columns (pass empty scenario for default escalation factors)
  pressure_control_data <- addDefaultColumns(pressure_control_data, "")
  
  cat("✅ Generated", n_rows, "entries with multiple preventive controls per pressure\n")
  cat("🎯 Unique pressures:", length(unique(pressure_control_data$Pressure)), "\n")
  cat("🛡️ Unique preventive controls:", length(unique(pressure_control_data$Preventive_Control)), "\n")
  cat("📊 Controls per pressure:\n")
  pressure_counts <- table(pressure_control_data$Pressure)
  for (pressure in names(pressure_counts)) {
    controls_for_pressure <- unique(pressure_control_data$Preventive_Control[pressure_control_data$Pressure == pressure])
    cat("   ", pressure, ":", length(controls_for_pressure), "controls\n")
  }
  
  return(pressure_control_data)
}

# Generate bowtie data using ALL vocabulary elements from Excel files
generateDataFromVocabulary <- function(scenario_type = "marine_pollution") {
  cat("🔄 Redirecting to FOCUSED bow-tie generation instead of comprehensive data...\n")
  cat("📋 Using focused scenario:", scenario_type, "\n")

  # Redirect to our focused scenario-specific function
  return(generateScenarioSpecificBowtie(scenario_type))


  cat("📊 Using vocabulary data:\n")
  cat("   • Activities:", nrow(activities), "items\n")
  cat("   • Pressures:", nrow(pressures), "items\n")
  cat("   • Consequences:", nrow(consequences), "items\n")
  cat("   • Controls:", nrow(controls), "items\n")

  # Create comprehensive bowtie combinations
  # Each activity can cause multiple pressures, each pressure needs controls and can lead to consequences

  # Generate activity-pressure combinations (each activity -> multiple random pressures)
  activity_pressure_combinations <- list()
  for (i in 1:nrow(activities)) {
    activity_name <- activities$name[i]
    # Each activity causes 1-3 random pressures
    n_pressures <- sample(1:3, 1)
    selected_pressures <- sample(pressures$name, n_pressures, replace = FALSE)

    for (pressure in selected_pressures) {
      activity_pressure_combinations[[length(activity_pressure_combinations) + 1]] <- list(
        activity = activity_name,
        pressure = pressure
      )
    }
  }

  # Generate full bowtie data
  bowtie_data <- data.frame(
    Activity = character(0),
    Pressure = character(0),
    Preventive_Control = character(0),
    Central_Problem = character(0),
    Consequence = character(0),
    Protective_Control = character(0),
    stringsAsFactors = FALSE
  )

  # Central problems - sensible environmental issues from vocabulary
  central_problems <- c(
    "Marine pollution",
    "Water ecosystem degradation",
    "Biodiversity loss",
    "Soil contamination",
    "Air quality deterioration",
    "Climate change acceleration"
  )

  # Build comprehensive data
  for (combo in activity_pressure_combinations) {
    activity <- combo$activity
    pressure <- combo$pressure

    # Select 1-2 preventive controls for this pressure
    n_prev_controls <- sample(1:2, 1)
    selected_prev_controls <- sample(controls$name, n_prev_controls, replace = FALSE)

    for (prev_control in selected_prev_controls) {
      # Select central problem
      central_problem <- sample(central_problems, 1)

      # Select 1-2 consequences
      n_consequences <- sample(1:2, 1)
      selected_consequences <- sample(consequences$name, n_consequences, replace = FALSE)

      for (consequence in selected_consequences) {
        # Select 1-2 protective controls
        n_prot_controls <- sample(1:2, 1)
        # Use different controls for protective measures
        available_prot_controls <- setdiff(controls$name, prev_control)
        selected_prot_controls <- sample(available_prot_controls, n_prot_controls, replace = FALSE)

        for (prot_control in selected_prot_controls) {
          # Add row to bowtie data
          bowtie_data <- rbind(bowtie_data, data.frame(
            Activity = activity,
            Pressure = pressure,
            Preventive_Control = prev_control,
            Central_Problem = central_problem,
            Consequence = consequence,
            Protective_Control = prot_control,
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }

  # Add default columns that the app expects
  bowtie_data <- addDefaultColumns(bowtie_data)

  cat("✅ Generated", nrow(bowtie_data), "comprehensive bowtie scenarios from vocabulary\n")
  cat("🎯 Activities included:", length(unique(bowtie_data$Activity)), "/", nrow(activities), "\n")
  cat("⚠️ Pressures included:", length(unique(bowtie_data$Pressure)), "/", nrow(pressures), "\n")
  cat("🛡️ Controls included:", length(unique(c(bowtie_data$Preventive_Control, bowtie_data$Protective_Control))), "/", nrow(controls), "\n")
  cat("💥 Consequences included:", length(unique(bowtie_data$Consequence)), "/", nrow(consequences), "\n")

  return(bowtie_data)
}

# Generate scenario-specific bowtie data with SINGLE central problem
generateScenarioSpecificBowtie <- function(scenario_type = "") {
  cat("🎯 Generating FOCUSED bowtie with ONE central problem for scenario:", scenario_type, "\n")

  # Check if vocabulary_data is available
  if (!exists("vocabulary_data") || is.null(vocabulary_data)) {
    stop("Vocabulary data not available. Please ensure Excel files are loaded.")
  }

  # Extract vocabulary elements
  activities <- vocabulary_data$activities
  pressures <- vocabulary_data$pressures
  consequences <- vocabulary_data$consequences
  controls <- vocabulary_data$controls

  # Define scenario-specific focused configurations (5-8 elements each for targeted bow-tie)
  scenario_config <- switch(scenario_type,
    "marine_pollution" = list(
      central_problem = "Marine pollution from shipping activities",
      specific_activities = c("Commercial shipping", "Port operations", "Oil transportation", "Ballast water discharge", "Cargo handling"),
      specific_pressures = c("Chemical pollution", "Oil spills", "Ballast water discharge", "Underwater noise"),
      specific_consequences = c("Marine ecosystem degradation", "Water quality deterioration", "Marine species mortality", "Habitat destruction")
    ),
    "industrial_contamination" = list(
      central_problem = "Industrial contamination through chemical discharge",
      specific_activities = c("Industrial manufacturing", "Chemical processing", "Mining operations", "Power generation", "Waste treatment"),
      specific_pressures = c("Chemical pollution", "Heavy metal contamination", "Toxic waste discharge", "Groundwater contamination"),
      specific_consequences = c("Groundwater contamination", "Human health impacts", "Soil ecosystem degradation", "Agricultural productivity loss")
    ),
    "oil_spills" = list(
      central_problem = "Oil spills from maritime transportation",
      specific_activities = c("Oil transportation", "Tanker operations", "Offshore drilling", "Fuel transfer", "Pipeline transport"),
      specific_pressures = c("Oil spills", "Hydrocarbon pollution", "Surface water contamination", "Sediment contamination"),
      specific_consequences = c("Marine ecosystem degradation", "Coastal habitat destruction", "Marine species mortality", "Economic losses")
    ),
    "agricultural_runoff" = list(
      central_problem = "Agricultural runoff causing eutrophication",
      specific_activities = c("Fertilizer application", "Livestock farming", "Intensive agriculture", "Pesticide use", "Agricultural drainage"),
      specific_pressures = c("Nutrient pollution", "Fertilizer runoff", "Pesticide contamination", "Organic pollution"),
      specific_consequences = c("Eutrophication", "Algal blooms", "Aquatic ecosystem degradation", "Oxygen depletion", "Fish kills")
    ),
    "overfishing_depletion" = list(
      central_problem = "Overfishing and commercial stock depletion",
      specific_activities = c("Commercial fishing", "Trawling operations", "Fish processing", "Aquaculture", "Recreational fishing"),
      specific_pressures = c("Overfishing", "Habitat destruction", "Bycatch mortality", "Stock depletion"),
      specific_consequences = c("Fish stock collapse", "Marine ecosystem degradation", "Food web disruption", "Economic losses")
    ),
    # Martinique-specific scenarios
    "martinique_coastal_erosion" = list(
      central_problem = "Coastal erosion and beach degradation in Martinique",
      specific_activities = c("Coastal development", "Sand mining", "Infrastructure construction", "Tourism facilities", "Marina development"),
      specific_pressures = c("Habitat destruction", "Beach erosion", "Sediment depletion", "Storm surge impacts"),
      specific_consequences = c("Beach loss", "Coastal habitat destruction", "Tourism infrastructure damage", "Property loss", "Marine ecosystem degradation")
    ),
    "martinique_sargassum" = list(
      central_problem = "Sargassum seaweed influx impacts on Martinique",
      specific_activities = c("Climate change", "Ocean warming", "Nutrient enrichment", "Agricultural runoff", "Ocean current changes"),
      specific_pressures = c("Massive seaweed accumulation", "Beach smothering", "Decomposition gases", "Oxygen depletion"),
      specific_consequences = c("Tourism decline", "Beach closures", "H2S emissions health impacts", "Marine life mortality", "Economic losses")
    ),
    "martinique_coral_degradation" = list(
      central_problem = "Coral reef degradation and bleaching in Martinique",
      specific_activities = c("Ocean warming", "Coastal development", "Tourism activities", "Overfishing", "Agricultural runoff"),
      specific_pressures = c("Thermal stress", "Pollution", "Physical damage", "Sedimentation", "Nutrient enrichment"),
      specific_consequences = c("Coral bleaching", "Reef structural collapse", "Biodiversity loss", "Fish habitat loss", "Coastal protection loss")
    ),
    "martinique_watershed_pollution" = list(
      central_problem = "Watershed pollution from agriculture in Martinique",
      specific_activities = c("Banana cultivation", "Pesticide application", "Fertilizer use", "Soil erosion", "Legacy chlordecone contamination"),
      specific_pressures = c("Chemical contamination", "Nutrient pollution", "Sediment runoff", "Pesticide residues", "Heavy metals"),
      specific_consequences = c("Drinking water contamination", "Coastal water pollution", "Soil contamination", "Food chain contamination", "Human health impacts")
    ),
    "martinique_mangrove_loss" = list(
      central_problem = "Mangrove forest degradation in Martinique",
      specific_activities = c("Coastal development", "Marina construction", "Tourism infrastructure", "Pollution discharge", "Land reclamation"),
      specific_pressures = c("Habitat destruction", "Pollution", "Hydrological changes", "Sedimentation", "Physical degradation"),
      specific_consequences = c("Fish nursery loss", "Coastal protection reduction", "Biodiversity decline", "Carbon sequestration loss", "Storm vulnerability increase")
    ),
    "martinique_hurricane_impacts" = list(
      central_problem = "Hurricane and tropical storm impacts on Martinique",
      specific_activities = c("Climate change", "Infrastructure development", "Coastal settlement", "Deforestation", "Wetland loss"),
      specific_pressures = c("Storm surge", "High winds", "Heavy rainfall", "Flooding", "Wave action"),
      specific_consequences = c("Infrastructure damage", "Coastal flooding", "Marine pollution", "Ecosystem disruption", "Economic losses", "Public safety risks")
    ),
    "martinique_marine_tourism" = list(
      central_problem = "Marine tourism environmental pressures in Martinique",
      specific_activities = c("Cruise ship arrivals", "Yacht anchoring", "Diving tourism", "Beach recreation", "Tourism infrastructure"),
      specific_pressures = c("Anchor damage", "Pollution discharge", "Physical disturbance", "Waste generation", "Underwater noise"),
      specific_consequences = c("Coral reef damage", "Seagrass bed destruction", "Water quality deterioration", "Marine life disturbance", "Ecosystem degradation")
    ),
    # Default - use first few items from vocabulary
    list(
      central_problem = "Environmental degradation",
      specific_activities = head(activities$name, 5),
      specific_pressures = head(pressures$name, 4),
      specific_consequences = head(consequences$name, 4)
    )
  )

  cat("📋 Scenario:", scenario_type, "\n")
  cat("🎯 Central Problem:", scenario_config$central_problem, "\n")

  # Use SPECIFIC elements for focused bow-tie (no filtering needed - direct selection)
  focused_activities <- scenario_config$specific_activities
  focused_pressures <- scenario_config$specific_pressures
  focused_consequences <- scenario_config$specific_consequences

  cat("📊 Focused elements:\n")
  cat("   • Activities:", length(focused_activities), "specific items\n")
  cat("   • Pressures:", length(focused_pressures), "specific items\n")
  cat("   • Consequences:", length(focused_consequences), "specific items\n")

  # Generate well-connected activity-pressure combinations
  activity_pressure_combinations <- list()

  # Create specific, logical activity-pressure pairs for each scenario (max 2)
  scenario_specific_pairs <- switch(scenario_type,
    "marine_pollution" = list(
      list(activity = "Commercial shipping", pressure = "Chemical pollution"),
      list(activity = "Oil transportation", pressure = "Oil spills")
    ),
    "industrial_contamination" = list(
      list(activity = "Chemical processing", pressure = "Chemical pollution"),
      list(activity = "Mining operations", pressure = "Heavy metal contamination")
    ),
    "oil_spills" = list(
      list(activity = "Oil transportation", pressure = "Oil spills"),
      list(activity = "Tanker operations", pressure = "Hydrocarbon pollution")
    ),
    "agricultural_runoff" = list(
      list(activity = "Fertilizer application", pressure = "Nutrient pollution"),
      list(activity = "Livestock farming", pressure = "Organic pollution")
    ),
    "overfishing_depletion" = list(
      list(activity = "Commercial fishing", pressure = "Overfishing"),
      list(activity = "Trawling operations", pressure = "Habitat destruction")
    ),
    "martinique_coastal_erosion" = list(
      list(activity = "Coastal development", pressure = "Habitat destruction"),
      list(activity = "Sand mining", pressure = "Beach erosion")
    ),
    "martinique_sargassum" = list(
      list(activity = "Climate change", pressure = "Massive seaweed accumulation"),
      list(activity = "Agricultural runoff", pressure = "Beach smothering")
    ),
    "martinique_coral_degradation" = list(
      list(activity = "Ocean warming", pressure = "Thermal stress"),
      list(activity = "Tourism activities", pressure = "Physical damage")
    ),
    "martinique_watershed_pollution" = list(
      list(activity = "Banana cultivation", pressure = "Chemical contamination"),
      list(activity = "Pesticide application", pressure = "Pesticide residues")
    ),
    "martinique_mangrove_loss" = list(
      list(activity = "Coastal development", pressure = "Habitat destruction"),
      list(activity = "Marina construction", pressure = "Hydrological changes")
    ),
    "martinique_hurricane_impacts" = list(
      list(activity = "Climate change", pressure = "Storm surge"),
      list(activity = "Coastal settlement", pressure = "Flooding")
    ),
    "martinique_marine_tourism" = list(
      list(activity = "Cruise ship arrivals", pressure = "Pollution discharge"),
      list(activity = "Yacht anchoring", pressure = "Anchor damage")
    ),
    # Default - create 2 logical pairs from available elements
    list(
      list(activity = focused_activities[1], pressure = focused_pressures[1]),
      list(activity = focused_activities[2], pressure = focused_pressures[2])
    )
  )

  # Use the well-connected pairs (limit to 2)
  activity_pressure_combinations <- head(scenario_specific_pairs, 2)

  cat("🔗 Created", length(activity_pressure_combinations), "well-connected activity-pressure pairs\n")

  # Generate bowtie data with SINGLE central problem
  bowtie_data <- data.frame(
    Activity = character(0),
    Pressure = character(0),
    Preventive_Control = character(0),
    Central_Problem = character(0),
    Consequence = character(0),
    Protective_Control = character(0),
    stringsAsFactors = FALSE
  )

  # Build comprehensive data with single central problem
  central_problem <- scenario_config$central_problem

  # Define scenario-specific control mappings (more specific and descriptive names)
  scenario_control_mapping <- switch(scenario_type,
    "marine_pollution" = list(
      preventive = c("Ship emission monitoring systems", "Ballast water treatment requirements", "Port pollution prevention protocols"),
      protective = c("Marine oil spill response teams", "Coastal ecosystem restoration", "Marine sanctuary emergency closures")
    ),
    "industrial_contamination" = list(
      preventive = c("Industrial wastewater treatment plants", "Chemical containment systems", "Real-time pollution monitoring"),
      protective = c("Contaminated site excavation and treatment", "Groundwater pump-and-treat systems", "Public health surveillance programs")
    ),
    "oil_spills" = list(
      preventive = c("Vessel traffic separation schemes", "Double-hulled tanker requirements", "Oil transfer safety protocols"),
      protective = c("Oil boom deployment and containment", "Dispersant application operations", "Shoreline cleanup and wildlife rescue")
    ),
    "agricultural_runoff" = list(
      preventive = c("Precision fertilizer application", "Riparian buffer zone establishment", "Cover crop requirements"),
      protective = c("Agricultural runoff wetlands", "Algal bloom treatment systems", "Alternative drinking water sources")
    ),
    "overfishing_depletion" = list(
      preventive = c("Science-based catch quotas", "Vessel monitoring systems", "Seasonal fishing closures"),
      protective = c("Fish stock rebuilding zones", "Habitat restoration for spawning", "Alternative livelihood programs")
    ),
    "martinique_coastal_erosion" = list(
      preventive = c("Coastal setback regulations", "Beach sand management plans", "Breakwater construction"),
      protective = c("Emergency sand nourishment", "Infrastructure relocation assistance", "Natural dune restoration")
    ),
    "martinique_sargassum" = list(
      preventive = c("Ocean current forecasting systems", "Nutrient pollution reduction", "Early warning buoy networks"),
      protective = c("Mechanical beach cleanup equipment", "Offshore sargassum barriers", "Tourism compensation programs")
    ),
    "martinique_coral_degradation" = list(
      preventive = c("Marine protected area enforcement", "Anchor-free mooring buoys", "Tourism carrying capacity limits"),
      protective = c("Coral fragment nursery programs", "Active reef restoration", "Climate-resilient coral propagation")
    ),
    "martinique_watershed_pollution" = list(
      preventive = c("Organic farming incentives", "Pesticide application restrictions", "Soil conservation practices"),
      protective = c("Advanced water treatment facilities", "Contaminated soil excavation", "Alternative groundwater sources")
    ),
    "martinique_mangrove_loss" = list(
      preventive = c("Mangrove protection legislation", "Development impact assessments", "Wetland buffer requirements"),
      protective = c("Community mangrove replanting", "Hydrological restoration", "Alternative coastal defenses")
    ),
    "martinique_hurricane_impacts" = list(
      preventive = c("Reinforced building codes", "Hurricane early warning systems", "Coastal infrastructure hardening"),
      protective = c("Emergency evacuation coordination", "Rapid damage assessment teams", "Infrastructure reconstruction")
    ),
    "martinique_marine_tourism" = list(
      preventive = c("Fixed mooring buoy systems", "Cruise ship discharge regulations", "Dive site rotation schedules"),
      protective = c("Damaged reef restoration", "Tourist education programs", "Marine sanctuary recovery zones")
    ),
    # Default - use descriptive generic control names
    list(
      preventive = c("Environmental monitoring and compliance", "Pollution prevention protocols", "Resource management systems"),
      protective = c("Environmental restoration programs", "Emergency response procedures", "Impact remediation measures")
    )
  )

  for (combo in activity_pressure_combinations) {
    activity <- combo$activity
    pressure <- combo$pressure

    # Use 1 specific preventive control per pressure for simplicity
    relevant_prev_controls <- head(scenario_control_mapping$preventive, 1)

    for (prev_control in relevant_prev_controls) {
      # Select 1 most relevant consequence (from focused set)
      selected_consequences <- head(focused_consequences, 1)

      for (consequence in selected_consequences) {
        # Use 1 specific protective control from library (different from preventive)
        available_prot_controls <- setdiff(scenario_control_mapping$protective, prev_control)
        selected_prot_controls <- head(available_prot_controls, 1)  # One protective control per consequence

        for (prot_control in selected_prot_controls) {
          # Add row to bowtie data with SINGLE central problem
          bowtie_data <- rbind(bowtie_data, data.frame(
            Activity = activity,
            Pressure = pressure,
            Preventive_Control = prev_control,
            Central_Problem = central_problem,  # Same for all rows!
            Consequence = consequence,
            Protective_Control = prot_control,
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }

  # Add default columns that the app expects
  bowtie_data <- addDefaultColumns(bowtie_data, scenario_type)

  cat("✅ Generated", nrow(bowtie_data), "bowtie scenarios with SINGLE central problem\n")
  cat("🎯 Central Problem:", unique(bowtie_data$Central_Problem), "\n")
  cat("📊 Activities:", length(unique(bowtie_data$Activity)), "\n")
  cat("⚠️ Pressures:", length(unique(bowtie_data$Pressure)), "\n")
  cat("💥 Consequences:", length(unique(bowtie_data$Consequence)), "\n")
  cat("🛡️ Controls:", length(unique(c(bowtie_data$Preventive_Control, bowtie_data$Protective_Control))), "\n")

  return(bowtie_data)
}

# Generate a comprehensive synthetic environmental dataset for performance tests
generate_comprehensive_environmental_data <- function(num_scenarios = 100,
                                                      activities_per_scenario = 5,
                                                      pressures_per_scenario = 4,
                                                      consequences_per_scenario = 3,
                                                      controls_per_scenario = 6) {
  total_rows <- num_scenarios * activities_per_scenario
  activities <- paste("Activity", seq_len(total_rows))
  pressures <- paste("Pressure", rep(seq_len(pressures_per_scenario), length.out = total_rows))
  central <- paste("Problem", rep(seq_len(num_scenarios), each = activities_per_scenario))
  consequences <- paste("Consequence", rep(seq_len(consequences_per_scenario), length.out = total_rows))
  preventive <- paste("Preventive", seq_len(total_rows))
  protective <- paste("Protective", seq_len(total_rows))

  df <- data.frame(
    Activity = activities,
    Pressure = pressures,
    Central_Problem = central,
    Consequence = consequences,
    Preventive_Control = preventive,
    Protective_Control = protective,
    Threat_Likelihood = sample(1:5, total_rows, replace = TRUE),
    Consequence_Severity = sample(1:5, total_rows, replace = TRUE),
    stringsAsFactors = FALSE
  )

  return(df)
}

cat("🎉 v5.1.0 Environmental Bowtie Risk Analysis Utilities Loaded\n")
cat("✅ Protective mitigation connections\n")
cat("🖼️ PNG image support enabled\n")
cat("🔗 GRANULAR connection-level risk analysis (7 connections per scenario)\n")
cat("   • Escalation factors affect BOTH preventive controls AND protective mitigations\n")
cat("🎯 Overall pathway risk calculation from granular components\n")
cat("🔧 Mapping and validation functions ready\n")
cat("🆕 MULTIPLE PREVENTIVE CONTROLS per pressure support added\n")