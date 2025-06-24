# =============================================================================
# Environmental Bowtie Risk Analysis - ENHANCED Utility Functions v4.2.3
# Version: 4.2.3 (FIXED Protective Mitigation Connections & PNG Support)
# Date: June 2025
# Description: Complete FIXED protective mitigation connections with enhanced mapping
# =============================================================================

# Cache for expensive computations
.cache <- new.env()

# ENHANCED function to generate environmental management sample data with FIXED connections and granular risk values
generateEnvironmentalDataFixed <- function() {
  cat("🔄 Generating v4.2.3 enhanced environmental management data with GRANULAR bowtie connection risks\n")
  
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
    
    # v4.2.3 FIXED Protective Mitigation - PROPERLY MAPPED to specific consequences
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
    
    # GRANULAR BOWTIE CONNECTION RISKS (v4.2.3 Enhancement)
    # Connection 1: Activity → Pressure
    Activity_to_Pressure_Likelihood = c(4, 3, 3, 4, 4, 5, 3, 4, 3, 4, 3, 3, 4, 3, 4, 4, 3, 2, 2, 5, 4, 2, 3, 4, 3, 3, 2),
    Activity_to_Pressure_Severity = c(3, 4, 2, 4, 3, 4, 4, 3, 4, 4, 3, 4, 3, 4, 3, 3, 2, 3, 3, 4, 3, 3, 4, 3, 2, 4, 3),
    
    # Connection 2: Pressure → Preventive Control (effectiveness/failure risk)
    Pressure_to_Control_Likelihood = c(2, 3, 2, 3, 2, 2, 3, 2, 3, 2, 3, 3, 2, 3, 2, 2, 3, 1, 1, 3, 2, 2, 2, 3, 2, 2, 3),
    Pressure_to_Control_Severity = c(4, 3, 3, 4, 4, 4, 4, 4, 4, 5, 3, 3, 4, 4, 4, 4, 3, 5, 4, 4, 4, 4, 4, 3, 3, 4, 3),
    
    # Connection 3: Control → Escalation Factor (control failure leading to escalation)
    Control_to_Escalation_Likelihood = c(3, 2, 2, 3, 3, 3, 2, 3, 3, 3, 2, 2, 2, 2, 3, 3, 2, 2, 2, 4, 3, 2, 3, 3, 2, 3, 2),
    Control_to_Escalation_Severity = c(4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 4, 4, 3, 4, 4, 5, 4, 4, 4, 4, 3, 4, 4),
    
    # Connection 4: Escalation → Central Problem
    Escalation_to_Central_Likelihood = c(4, 3, 3, 4, 3, 4, 3, 4, 4, 4, 3, 3, 3, 2, 3, 3, 3, 3, 3, 4, 4, 3, 3, 4, 3, 3, 3),
    Escalation_to_Central_Severity = c(5, 4, 3, 5, 4, 5, 4, 4, 5, 5, 4, 4, 4, 5, 4, 4, 3, 5, 4, 5, 4, 4, 4, 3, 4, 4, 3),
    
    # Connection 5: Central Problem → Protective Mitigation (mitigation effectiveness)
    Central_to_Mitigation_Likelihood = c(2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 2, 3, 1, 1, 3, 2, 2, 2, 2, 2, 2, 2),
    Central_to_Mitigation_Severity = c(4, 4, 4, 5, 3, 5, 4, 5, 5, 5, 4, 4, 4, 4, 4, 4, 3, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4),
    
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
    Mitigation_to_Consequence_Severity
  ))
  
  # Calculate Risk_Level based on overall pathway risk
  risk_scores <- sample_data$Overall_Likelihood * sample_data$Overall_Severity
  sample_data$Risk_Level <- ifelse(risk_scores <= 6, "Low",
                                  ifelse(risk_scores <= 15, "Medium", "High"))
  
  # Keep legacy columns for backward compatibility
  sample_data$Likelihood <- sample_data$Overall_Likelihood
  sample_data$Severity <- sample_data$Overall_Severity
  
  cat("✅ Generated", nrow(sample_data), "rows of v4.2.3 enhanced environmental data with GRANULAR bowtie connection risks\n")
  cat("🔗 Each protective mitigation is properly mapped to its corresponding consequence\n")
  cat("📊 Added granular likelihood/severity for 6 bowtie connections per scenario\n")
  cat("🎯 Overall risk calculated from pathway chain analysis\n")
  return(sample_data)
}

# Backward compatibility function (calls the FIXED version)
generateEnvironmentalData <- function() {
  generateEnvironmentalDataFixed()
}

# Function to validate required columns in uploaded data
validateDataColumns <- function(data) {
  required_cols <- c("Activity", "Pressure", "Central_Problem", "Consequence")
  missing_cols <- setdiff(required_cols, names(data))
  list(valid = length(missing_cols) == 0, missing = missing_cols)
}

# Function to add default columns if missing (enhanced structure with granular risks)
addDefaultColumns <- function(data) {
  n_rows <- nrow(data)
  
  if (!"Activity" %in% names(data)) data$Activity <- paste("Activity", seq_len(n_rows))
  if (!"Pressure" %in% names(data)) data$Pressure <- paste("Pressure", seq_len(n_rows))
  if (!"Preventive_Control" %in% names(data)) data$Preventive_Control <- paste("v4.2.3 Enhanced preventive control", seq_len(n_rows))
  if (!"Escalation_Factor" %in% names(data)) data$Escalation_Factor <- paste("v4.2.3 Enhanced escalation factor", seq_len(n_rows))
  if (!"Central_Problem" %in% names(data)) data$Central_Problem <- "Environmental Risk v4.2.3"
  if (!"Protective_Mitigation" %in% names(data)) data$Protective_Mitigation <- paste("v4.2.3 FIXED protective mitigation", seq_len(n_rows))
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
  
  data
}

# Vectorized risk level calculation
calculateRiskLevel <- function(likelihood, severity) {
  risk_scores <- likelihood * severity
  ifelse(risk_scores <= 6, "Low",
         ifelse(risk_scores <= 15, "Medium", "High"))
}

# Enhanced color mappings for comprehensive structure
RISK_COLORS <- c("Low" = "#90EE90", "Medium" = "#FFD700", "High" = "#FF6B6B")
ACTIVITY_COLOR <- "#8E44AD"          # Purple for activities
PRESSURE_COLOR <- "#E74C3C"          # Red for pressures/threats
PREVENTIVE_COLOR <- "#27AE60"        # Green for preventive controls
ESCALATION_COLOR <- "#F39C12"        # Orange for escalation factors
CENTRAL_PROBLEM_COLOR <- "#C0392B"   # Dark red for central problem
PROTECTIVE_COLOR <- "#3498DB"        # Blue for protective mitigation
CONSEQUENCE_COLOR <- "#E67E22"       # Dark orange for consequences

# Optimized risk color function
getRiskColor <- function(risk_level, show_risk_levels = TRUE) {
  if (!show_risk_levels) return("#CCCCCC")
  RISK_COLORS[risk_level]
}

# Clear cache when data changes
clearCache <- function() {
  rm(list = ls(envir = .cache), envir = .cache)
}

# v4.2.3 FIXED node creation for comprehensive bowtie structure
createBowtieNodesFixed <- function(hazard_data, selected_problem, node_size, show_risk_levels, show_barriers) {
  cache_key <- paste0("nodes_fixed_v423_", selected_problem, "_", node_size, "_", show_risk_levels, "_", show_barriers, "_", nrow(hazard_data))
  if (exists(cache_key, envir = .cache)) {
    cat("📋 Using cached nodes for v4.2.3\n")
    return(get(cache_key, envir = .cache))
  }
  
  cat("🔧 Creating v4.2.3 FIXED bowtie nodes\n")
  
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
    
    cat("🛡️ Found", length(protective_mitigations), "unique protective mitigations in v4.2.3\n")
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
  
  idx <- 1
  
  # Central Problem node (center) - Enhanced Diamond shape for v4.2.3
  ids[idx] <- 1
  labels[idx] <- paste(selected_problem, "(v4.2.3)")
  groups[idx] <- "central_problem"
  colors[idx] <- CENTRAL_PROBLEM_COLOR
  shapes[idx] <- "diamond"
  sizes[idx] <- node_size * 1.8
  font_sizes[idx] <- 16
  idx <- idx + 1
  
  # Activity nodes (far left) - Enhanced for v4.2.3
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
    labels[activity_indices] <- activities
    groups[activity_indices] <- "activity"
    colors[activity_indices] <- activity_colors
    shapes[activity_indices] <- "box"
    sizes[activity_indices] <- node_size * 0.9
    font_sizes[activity_indices] <- 11
    idx <- idx + n_activities
  }
  
  # Pressure nodes (left side) - Enhanced for v4.2.3
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
    labels[pressure_indices] <- pressures
    groups[pressure_indices] <- "pressure"
    colors[pressure_indices] <- pressure_colors
    shapes[pressure_indices] <- "triangle"
    sizes[pressure_indices] <- node_size
    font_sizes[pressure_indices] <- 12
    idx <- idx + n_pressures
  }
  
  # Consequence nodes (right side) - Enhanced for v4.2.3
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
    labels[cons_indices] <- consequences
    groups[cons_indices] <- "consequence"
    colors[cons_indices] <- cons_colors
    shapes[cons_indices] <- "hexagon"
    sizes[cons_indices] <- node_size
    font_sizes[cons_indices] <- 12
    idx <- idx + n_consequences
  }
  
  # v4.2.3 Enhanced barrier and escalation factor nodes
  if (show_barriers) {
    if (exists("preventive_controls") && length(preventive_controls) > 0) {
      prev_indices <- idx:(idx + length(preventive_controls) - 1)
      ids[prev_indices] <- 300 + seq_len(length(preventive_controls))
      labels[prev_indices] <- preventive_controls
      groups[prev_indices] <- "preventive_control"
      colors[prev_indices] <- PREVENTIVE_COLOR
      shapes[prev_indices] <- "square"
      sizes[prev_indices] <- node_size * 0.8
      font_sizes[prev_indices] <- 10
      idx <- idx + length(preventive_controls)
    }
    
    if (exists("escalation_factors") && length(escalation_factors) > 0) {
      esc_indices <- idx:(idx + length(escalation_factors) - 1)
      ids[esc_indices] <- 350 + seq_len(length(escalation_factors))
      labels[esc_indices] <- escalation_factors
      groups[esc_indices] <- "escalation_factor"
      colors[esc_indices] <- ESCALATION_COLOR
      shapes[esc_indices] <- "triangleDown"
      sizes[esc_indices] <- node_size * 0.8
      font_sizes[esc_indices] <- 10
      idx <- idx + length(escalation_factors)
    }
    
    # v4.2.3 ENHANCED Protective Mitigation nodes
    if (exists("protective_mitigations") && length(protective_mitigations) > 0) {
      prot_indices <- idx:(idx + length(protective_mitigations) - 1)
      ids[prot_indices] <- 400 + seq_len(length(protective_mitigations))
      labels[prot_indices] <- protective_mitigations
      groups[prot_indices] <- "protective_mitigation"
      colors[prot_indices] <- PROTECTIVE_COLOR
      shapes[prot_indices] <- "square"
      sizes[prot_indices] <- node_size * 0.9  # Slightly larger for v4.2.3
      font_sizes[prot_indices] <- 11         # Larger font for v4.2.3
      
      cat("🔗 Created", length(protective_mitigations), "protective mitigation nodes for v4.2.3\n")
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
    stringsAsFactors = FALSE
  )
  
  cat("✅ Created", nrow(nodes), "total nodes for v4.2.3 FIXED bowtie\n")
  
  # Cache the result
  assign(cache_key, nodes, envir = .cache)
  nodes
}

# Backward compatibility function
createBowtieNodes <- function(hazard_data, selected_problem, node_size, show_risk_levels, show_barriers) {
  createBowtieNodesFixed(hazard_data, selected_problem, node_size, show_risk_levels, show_barriers)
}

# v4.2.3 FIXED edge creation function with PROPER protective mitigation connections
createBowtieEdgesFixed <- function(hazard_data, show_barriers) {
  # Create a unique cache key that includes mitigation data for proper caching
  if(!requireNamespace("digest", quietly = TRUE)) {
    # If digest package is not available, create a simple hash
    mitigation_hash <- paste(hazard_data$Protective_Mitigation, collapse = "_")
    mitigation_hash <- substr(mitigation_hash, 1, 50)  # Truncate for cache key
  } else {
    mitigation_hash <- digest::digest(hazard_data$Protective_Mitigation)
  }
  
  cache_key <- paste0("edges_fixed_v423_", nrow(hazard_data), "_", show_barriers, "_", mitigation_hash)
  if (exists(cache_key, envir = .cache)) {
    cat("📋 Using cached edges for v4.2.3\n")
    return(get(cache_key, envir = .cache))
  }
  
  cat("🔧 Creating v4.2.3 FIXED bowtie edges with enhanced protective mitigation connections\n")
  
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
        }
      }
    }
    
    # Pressure → Central Problem connections
    for (i in seq_along(pressures)) {
      from <- c(from, 100 + i)
      to <- c(to, 1)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#E74C3C")
      widths <- c(widths, 3)
      dashes <- c(dashes, FALSE)
    }
    
    # Central Problem → Consequence connections
    for (i in seq_along(consequences)) {
      from <- c(from, 1)
      to <- c(to, 200 + i)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#C0392B")
      widths <- c(widths, 3)
      dashes <- c(dashes, FALSE)
    }
    
  } else {
    # v4.2.3 FIXED Complex flow with PROPER protective mitigation mapping
    
    preventive_controls <- unique(hazard_data$Preventive_Control[hazard_data$Preventive_Control != ""])
    escalation_factors <- unique(hazard_data$Escalation_Factor[hazard_data$Escalation_Factor != ""])
    protective_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Protective_Mitigation != ""])
    
    cat("🛡️ v4.2.3 Found", length(protective_mitigations), "unique protective mitigations\n")
    cat("🎯 v4.2.3 Found", length(consequences), "unique consequences\n")
    
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
        }
      }
    }
    
    # Pressure → Preventive Control → Escalation Factor → Central Problem pathway
    for (i in seq_along(pressures)) {
      pressure <- pressures[i]
      control_for_pressure <- hazard_data$Preventive_Control[hazard_data$Pressure == pressure][1]
      escalation_for_pressure <- hazard_data$Escalation_Factor[hazard_data$Pressure == pressure][1]
      
      if (!is.na(control_for_pressure) && control_for_pressure != "") {
        control_idx <- which(preventive_controls == control_for_pressure)
        if (length(control_idx) > 0) {
          # Pressure → Preventive Control
          from <- c(from, 100 + i)
          to <- c(to, 300 + control_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#E74C3C")
          widths <- c(widths, 2)
          dashes <- c(dashes, FALSE)
          
          # Check for escalation factor
          if (!is.na(escalation_for_pressure) && escalation_for_pressure != "") {
            escalation_idx <- which(escalation_factors == escalation_for_pressure)
            if (length(escalation_idx) > 0) {
              # Preventive Control → Escalation Factor (control can fail)
              from <- c(from, 300 + control_idx)
              to <- c(to, 350 + escalation_idx)
              arrows <- c(arrows, "to")
              colors <- c(colors, "#F39C12")
              widths <- c(widths, 2)
              dashes <- c(dashes, TRUE)
              
              # Escalation Factor → Central Problem
              from <- c(from, 350 + escalation_idx)
              to <- c(to, 1)
              arrows <- c(arrows, "to")
              colors <- c(colors, "#F39C12")
              widths <- c(widths, 2)
              dashes <- c(dashes, FALSE)
            } else {
              # Preventive Control → Central Problem (if control fails)
              from <- c(from, 300 + control_idx)
              to <- c(to, 1)
              arrows <- c(arrows, "to")
              colors <- c(colors, "#27AE60")
              widths <- c(widths, 2)
              dashes <- c(dashes, TRUE)
            }
          } else {
            # Preventive Control → Central Problem (if control fails)
            from <- c(from, 300 + control_idx)
            to <- c(to, 1)
            arrows <- c(arrows, "to")
            colors <- c(colors, "#27AE60")
            widths <- c(widths, 2)
            dashes <- c(dashes, TRUE)
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
      }
    }
    
    # v4.2.3 FIXED: Central Problem → Protective Mitigation → Consequence pathway
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
    
    cat("🔍 v4.2.3 Processing", nrow(mitigation_map), "mitigation mappings\n")
    
    # Method 1: Enhanced row-wise mapping with validation
    for (i in seq_len(nrow(hazard_data))) {
      row <- hazard_data[i, ]
      consequence <- row$Consequence
      mitigation <- row$Protective_Mitigation
      
      if (!is.na(consequence) && consequence != "" && !is.na(mitigation) && mitigation != "") {
        consequence_idx <- which(consequences == consequence)
        mitigation_idx <- which(protective_mitigations == mitigation)
        
        if (length(consequence_idx) > 0 && length(mitigation_idx) > 0) {
          # Central Problem → Protective Mitigation (enhanced width for v4.2.3)
          from <- c(from, 1)
          to <- c(to, 400 + mitigation_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#C0392B")
          widths <- c(widths, 3)  # Enhanced width for v4.2.3
          dashes <- c(dashes, FALSE)
          
          # Protective Mitigation → Consequence (enhanced connection for v4.2.3)
          from <- c(from, 400 + mitigation_idx)
          to <- c(to, 200 + consequence_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#3498DB")
          widths <- c(widths, 3)  # Enhanced width for v4.2.3
          dashes <- c(dashes, TRUE)  # Dashed to show intervention effect
          
          mitigation_connections <- mitigation_connections + 1
          cat("✅ v4.2.3 Connected mitigation", mitigation_idx, "('", substr(mitigation, 1, 30), "...') to consequence", consequence_idx, "('", consequence, "')\n")
        }
      }
    }
    
    # Method 2: Add remaining direct connections for consequences without proper mitigation
    for (i in seq_along(consequences)) {
      consequence <- consequences[i]
      # Check if this consequence already has a proper mitigation connection
      has_proper_mitigation <- any(hazard_data$Consequence == consequence & 
                                   !is.na(hazard_data$Protective_Mitigation) & 
                                   hazard_data$Protective_Mitigation != "" &
                                   nchar(hazard_data$Protective_Mitigation) > 10)  # Enhanced validation
      
      if (!has_proper_mitigation) {
        # Direct central problem → consequence if no proper mitigation
        from <- c(from, 1)
        to <- c(to, 200 + i)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#C0392B")
        widths <- c(widths, 3)
        dashes <- c(dashes, FALSE)
        direct_connections <- direct_connections + 1
        cat("⚠️ v4.2.3 Direct connection to consequence", i, "('", consequence, "') - no proper mitigation\n")
      }
    }
    
    cat("📊 v4.2.3 Connection Summary:\n")
    cat("   🔗 Mitigation connections:", mitigation_connections, "\n")
    cat("   ➡️ Direct connections:", direct_connections, "\n")
  }
  
  edges <- data.frame(
    from = from,
    to = to,
    arrows = arrows,
    color = colors,
    width = widths,
    dashes = dashes,
    stringsAsFactors = FALSE
  )
  
  cat("✅ Created", nrow(edges), "edges with v4.2.3 FIXED protective mitigation connections\n")
  
  # Cache the result
  assign(cache_key, edges, envir = .cache)
  edges
}

# Backward compatibility function
createBowtieEdges <- function(hazard_data, show_barriers) {
  createBowtieEdgesFixed(hazard_data, show_barriers)
}

# v4.2.3 Enhanced function to create a default row for data editing with granular risks
createDefaultRowFixed <- function(selected_problem = "New Environmental Risk v4.2.3") {
  new_row <- data.frame(
    Activity = "New Enhanced Activity v4.2.3",
    Pressure = "New Enhanced Pressure v4.2.3",
    Preventive_Control = "New Enhanced Preventive Control v4.2.3",
    Escalation_Factor = "New Enhanced Escalation Factor v4.2.3",
    Central_Problem = selected_problem,
    Protective_Mitigation = "New v4.2.3 FIXED Protective Mitigation with enhanced mapping",
    Consequence = "New Enhanced Consequence v4.2.3",
    
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
    Mitigation_to_Consequence_Likelihood = 2L,
    Mitigation_to_Consequence_Severity = 3L,
    
    # Calculated overall values
    Overall_Likelihood = 3L,
    Overall_Severity = 4L,
    
    # Legacy columns for backward compatibility
    Likelihood = 3L,
    Severity = 4L,
    Risk_Level = "Medium",
    stringsAsFactors = FALSE
  )
  
  return(new_row)
}

# Backward compatibility function
createDefaultRow <- function(selected_problem = "New Environmental Risk") {
  createDefaultRowFixed(selected_problem)
}

# Optimized numeric validation
validateNumericInput <- function(value, min_val = 1L, max_val = 5L) {
  num_value <- suppressWarnings(as.integer(value))
  if (is.na(num_value) || num_value < min_val || num_value > max_val) {
    list(valid = FALSE, value = NULL, 
         message = paste("❌ Value must be between", min_val, "and", max_val))
  } else {
    list(valid = TRUE, value = num_value, message = NULL)
  }
}

# v4.2.3 Enhanced data summary function with granular connection analysis
getDataSummaryFixed <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  # Check if granular data is available
  has_granular_data <- all(c("Activity_to_Pressure_Likelihood", "Overall_Likelihood") %in% names(data))
  
  if (has_granular_data) {
    paste(
      "📊 v4.2.3 GRANULAR ENHANCED Summary:",
      "Rows:", nrow(data),
      "| Activities:", length(unique(data$Activity)),
      "| Central Problems:", length(unique(data$Central_Problem)),
      "| 🛡️ FIXED Protective Mitigations:", length(unique(data$Protective_Mitigation[data$Protective_Mitigation != ""])),
      "| Consequences:", length(unique(data$Consequence)),
      "| Risk Levels:", paste(names(table(data$Risk_Level)), collapse = ", "),
      "| 🔗 GRANULAR: 6 connection risks per scenario",
      "| ✅ v4.2.3 PATHWAY ANALYSIS with enhanced mapping"
    )
  } else {
    paste(
      "📊 v4.2.3 Enhanced Summary:",
      "Rows:", nrow(data),
      "| Activities:", length(unique(data$Activity)),
      "| Central Problems:", length(unique(data$Central_Problem)),
      "| 🛡️ FIXED Protective Mitigations:", length(unique(data$Protective_Mitigation[data$Protective_Mitigation != ""])),
      "| Consequences:", length(unique(data$Consequence)),
      "| Risk Levels:", paste(names(table(data$Risk_Level)), collapse = ", "),
      "| ✅ v4.2.3 FIXED connections with enhanced mapping"
    )
  }
}

# Backward compatibility function
getDataSummary <- function(data) {
  getDataSummaryFixed(data)
}

# v4.2.3 Enhanced validation function for protective mitigations
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
    issues <- c(issues, paste("✅ Good mitigation coverage:", round(mapping_ratio * 100, 1), "% - v4.2.3 FIXED quality"))
  }
  
  list(valid = length(issues) == 0, issues = issues)
}

cat("🎉 v4.2.3 Enhanced Environmental Bowtie Risk Analysis Utilities Loaded\n")
cat("✅ FIXED protective mitigation connections\n")
cat("🖼️ PNG image support enabled\n")
cat("🔗 GRANULAR connection-level risk analysis (6 connections per scenario)\n")
cat("🎯 Overall pathway risk calculation from granular components\n")
cat("🔧 Enhanced mapping and validation functions ready\n")