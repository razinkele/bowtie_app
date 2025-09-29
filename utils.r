# =============================================================================
# Environmental Bowtie Risk Analysis - ENHANCED Utility Functions v5.1.0
# Version: 5.1.0 (Refreshed with Modern R Practices)
# Date: September 2025
# Description: Optimized performance with enhanced caching and error handling
# =============================================================================

# Enhanced cache for expensive computations with memory management
.cache <- new.env()
.cache$max_size <- 100  # Maximum cache entries
.cache$current_size <- 0

# Cache management functions
clear_cache <- function() {
  rm(list = ls(.cache), envir = .cache)
  .cache$current_size <- 0
  cat("🧹 Cache cleared successfully\n")
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

# Performance timer
start_timer <- function(operation = "task") {
  .perf[[paste0(operation, "_start")]] <- Sys.time()
}

end_timer <- function(operation = "task", silent = FALSE) {
  start_key <- paste0(operation, "_start")
  if (exists(start_key, envir = .perf)) {
    duration <- as.numeric(difftime(Sys.time(), .perf[[start_key]], units = "secs"))
    if (!silent) {
      cat("⏱️", operation, "completed in", round(duration, 2), "seconds\n")
    }
    return(duration)
  }
  return(NULL)
}

# Memory usage check
check_memory <- function() {
  if (requireNamespace("pryr", quietly = TRUE)) {
    cat("💾 Memory usage:", pryr::mem_used(), "\n")
  } else {
    cat("💾 Memory monitoring requires 'pryr' package\n")
  }
}

# ENHANCED function to generate environmental management sample data with FIXED connections and granular risk values
generateEnvironmentalDataFixed <- function() {
  cat("🔄 Generating enhanced environmental management data with GRANULAR bowtie connection risks\n")
  
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
    
    # FIXED Protective Mitigation - PROPERLY MAPPED to specific consequences
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
  
  cat("✅ Generated", nrow(sample_data), "rows of enhanced environmental data with GRANULAR bowtie connection risks\n")
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
  if (!"Preventive_Control" %in% names(data)) data$Preventive_Control <- paste("Enhanced preventive control", seq_len(n_rows))
  if (!"Escalation_Factor" %in% names(data)) data$Escalation_Factor <- paste("Enhanced escalation factor", seq_len(n_rows))
  if (!"Central_Problem" %in% names(data)) data$Central_Problem <- "Environmental Risk"
  if (!"Protective_Mitigation" %in% names(data)) data$Protective_Mitigation <- paste("FIXED protective mitigation", seq_len(n_rows))
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

# FIXED node creation for comprehensive bowtie structure
createBowtieNodesFixed <- function(hazard_data, selected_problem, node_size, show_risk_levels, show_barriers) {
  cache_key <- paste0("nodes_fixed_v423_", selected_problem, "_", node_size, "_", show_risk_levels, "_", show_barriers, "_", nrow(hazard_data))
  if (exists(cache_key, envir = .cache)) {
    cat("📋 Using cached nodes\n")
    return(get(cache_key, envir = .cache))
  }
  
  cat("🔧 Creating FIXED bowtie nodes\n")
  
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
  
  idx <- 1
  
  # Central Problem node (center) - Enhanced Diamond shape
  ids[idx] <- 1
  labels[idx] <- selected_problem
  groups[idx] <- "central_problem"
  colors[idx] <- CENTRAL_PROBLEM_COLOR
  shapes[idx] <- "diamond"
  sizes[idx] <- node_size * 1.8
  font_sizes[idx] <- 16
  idx <- idx + 1
  
  # Activity nodes (far left) - Enhanced
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
  
  # Pressure nodes (left side) - Enhanced
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
  
  # Consequence nodes (right side) - Enhanced
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
  
  # Enhanced barrier and escalation factor nodes
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
    
    # ENHANCED Protective Mitigation nodes
    if (exists("protective_mitigations") && length(protective_mitigations) > 0) {
      prot_indices <- idx:(idx + length(protective_mitigations) - 1)
      ids[prot_indices] <- 400 + seq_len(length(protective_mitigations))
      labels[prot_indices] <- protective_mitigations
      groups[prot_indices] <- "protective_mitigation"
      colors[prot_indices] <- PROTECTIVE_COLOR
      shapes[prot_indices] <- "square"
      sizes[prot_indices] <- node_size * 0.9  # Slightly larger
      font_sizes[prot_indices] <- 11         # Larger font
      
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
    stringsAsFactors = FALSE
  )
  
  cat("✅ Created", nrow(nodes), "total nodes for FIXED bowtie\n")
  
  # Cache the result
  assign(cache_key, nodes, envir = .cache)
  nodes
}

# Backward compatibility function
createBowtieNodes <- function(hazard_data, selected_problem, node_size, show_risk_levels, show_barriers) {
  createBowtieNodesFixed(hazard_data, selected_problem, node_size, show_risk_levels, show_barriers)
}

# FIXED edge creation function with PROPER protective mitigation connections
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
    cat("📋 Using cached edges\n")
    return(get(cache_key, envir = .cache))
  }
  
  cat("🔧 Creating FIXED bowtie edges with enhanced protective mitigation connections\n")
  
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
    # FIXED Complex flow with PROPER protective mitigation mapping
    
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
        }
      }
    }
    
    # Enhanced Pressure → Multiple Preventive Controls pathway
    escalations_connected <- c()  # Track which escalation factors have been connected to central problem
    
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
            
            # Every preventive control must have a failure path to the central problem
            # Check if there's an escalation factor for this pressure
            if (!is.na(escalation_for_pressure) && escalation_for_pressure != "") {
              escalation_idx <- which(escalation_factors == escalation_for_pressure)
              if (length(escalation_idx) > 0) {
                # Path 1: Preventive Control → Escalation Factor (if control fails and escalates)
                from <- c(from, 300 + control_idx)
                to <- c(to, 350 + escalation_idx)
                arrows <- c(arrows, "to")
                colors <- c(colors, "#F39C12")  # Orange for control failure leading to escalation
                widths <- c(widths, 1.5)
                dashes <- c(dashes, TRUE)  # Dashed for failure pathway
                
                # Track this escalation factor for later connection to central problem
                if (!escalation_for_pressure %in% escalations_connected) {
                  escalations_connected <- c(escalations_connected, escalation_for_pressure)
                }
                
                # Path 2: Preventive Control → Central Problem (direct failure path as backup)
                from <- c(from, 300 + control_idx)
                to <- c(to, 1)
                arrows <- c(arrows, "to")
                colors <- c(colors, "#E74C3C")  # Red for direct control failure
                widths <- c(widths, 1)  # Thinner line for direct failure
                dashes <- c(dashes, TRUE)
              } else {
                # No valid escalation factor found, direct path only
                from <- c(from, 300 + control_idx)
                to <- c(to, 1)
                arrows <- c(arrows, "to")
                colors <- c(colors, "#E74C3C")  # Red for control failure
                widths <- c(widths, 1.5)
                dashes <- c(dashes, TRUE)
              }
            } else {
              # No escalation factor, direct failure path for each control
              from <- c(from, 300 + control_idx)
              to <- c(to, 1)
              arrows <- c(arrows, "to")
              colors <- c(colors, "#E74C3C")  # Red for control failure
              widths <- c(widths, 1.5)  # Standard width for control failure paths
              dashes <- c(dashes, TRUE)
            }
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
    
    # CRITICAL: Ensure ALL escalation factors connect to the central problem
    # Get ALL unique escalation factors from the dataset (not just those linked to controls)
    all_escalation_factors <- unique(hazard_data$Escalation_Factor)
    all_escalation_factors <- all_escalation_factors[!is.na(all_escalation_factors) & all_escalation_factors != ""]
    
    for (escalation_name in all_escalation_factors) {
      escalation_idx <- which(escalation_factors == escalation_name)
      if (length(escalation_idx) > 0) {
        # Escalation Factor → Central Problem
        from <- c(from, 350 + escalation_idx)
        to <- c(to, 1)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#F39C12")  # Orange for escalated threat
        widths <- c(widths, 2)
        dashes <- c(dashes, FALSE)
      }
    }
    
    # FIXED: Central Problem → Protective Mitigation → Consequence pathway
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
    
    # Method 1: Enhanced row-wise mapping with validation
    for (i in seq_len(nrow(hazard_data))) {
      row <- hazard_data[i, ]
      consequence <- row$Consequence
      mitigation <- row$Protective_Mitigation
      
      if (!is.na(consequence) && consequence != "" && !is.na(mitigation) && mitigation != "") {
        consequence_idx <- which(consequences == consequence)
        mitigation_idx <- which(protective_mitigations == mitigation)
        
        if (length(consequence_idx) > 0 && length(mitigation_idx) > 0) {
          # Central Problem → Protective Mitigation (enhanced width)
          from <- c(from, 1)
          to <- c(to, 400 + mitigation_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#C0392B")
          widths <- c(widths, 3)  # Enhanced width
          dashes <- c(dashes, FALSE)
          
          # Protective Mitigation → Consequence (enhanced connection)
          from <- c(from, 400 + mitigation_idx)
          to <- c(to, 200 + consequence_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#3498DB")
          widths <- c(widths, 3)  # Enhanced width
          dashes <- c(dashes, TRUE)  # Dashed to show intervention effect
          
          mitigation_connections <- mitigation_connections + 1
          cat("✅ Connected mitigation", mitigation_idx, "('", substr(mitigation, 1, 30), "...') to consequence", consequence_idx, "('", consequence, "')\n")
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
        cat("⚠️ Direct connection to consequence", i, "('", consequence, "') - no proper mitigation\n")
      }
    }
    
    cat("📊 Connection Summary:\n")
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
  
  cat("✅ Created", nrow(edges), "edges with FIXED protective mitigation connections\n")
  
  # Cache the result
  assign(cache_key, edges, envir = .cache)
  edges
}

# Backward compatibility function
createBowtieEdges <- function(hazard_data, show_barriers) {
  createBowtieEdgesFixed(hazard_data, show_barriers)
}

# Enhanced function to create a default row for data editing with granular risks
createDefaultRowFixed <- function(selected_problem = "New Environmental Risk") {
  new_row <- data.frame(
    Activity = "New Enhanced Activity",
    Pressure = "New Enhanced Pressure",
    Preventive_Control = "New Enhanced Preventive Control",
    Escalation_Factor = "New Enhanced Escalation Factor",
    Central_Problem = selected_problem,
    Protective_Mitigation = "New FIXED Protective Mitigation with enhanced mapping",
    Consequence = "New Enhanced Consequence",
    
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

# Enhanced data summary function with granular connection analysis
getDataSummaryFixed <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  # Check if granular data is available
  has_granular_data <- all(c("Activity_to_Pressure_Likelihood", "Overall_Likelihood") %in% names(data))
  
  if (has_granular_data) {
    paste(
      "📊 GRANULAR ENHANCED Summary:",
      "Rows:", nrow(data),
      "| Activities:", length(unique(data$Activity)),
      "| Central Problems:", length(unique(data$Central_Problem)),
      "| 🛡️ FIXED Protective Mitigations:", length(unique(data$Protective_Mitigation[data$Protective_Mitigation != ""])),
      "| Consequences:", length(unique(data$Consequence)),
      "| Risk Levels:", paste(names(table(data$Risk_Level)), collapse = ", "),
      "| 🔗 GRANULAR: 6 connection risks per scenario",
      "| ✅ PATHWAY ANALYSIS with enhanced mapping"
    )
  } else {
    paste(
      "📊 Enhanced Summary:",
      "Rows:", nrow(data),
      "| Activities:", length(unique(data$Activity)),
      "| Central Problems:", length(unique(data$Central_Problem)),
      "| 🛡️ FIXED Protective Mitigations:", length(unique(data$Protective_Mitigation[data$Protective_Mitigation != ""])),
      "| Consequences:", length(unique(data$Consequence)),
      "| Risk Levels:", paste(names(table(data$Risk_Level)), collapse = ", "),
      "| ✅ FIXED connections with enhanced mapping"
    )
  }
}

# Backward compatibility function
getDataSummary <- function(data) {
  getDataSummaryFixed(data)
}

# Enhanced validation function for protective mitigations
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
    issues <- c(issues, paste("✅ Good mitigation coverage:", round(mapping_ratio * 100, 1), "% - FIXED quality"))
  }
  
  list(valid = length(issues) == 0, issues = issues)
}

# NEW: Generate data with multiple preventive controls per pressure
generateEnvironmentalDataWithMultipleControls <- function() {
  cat("🔄 Generating data with MULTIPLE PREVENTIVE CONTROLS per pressure\n")
  
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
  
  # Add default columns
  pressure_control_data <- addDefaultColumns(pressure_control_data)
  
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

  # Generate activity-pressure combinations for focused bow-tie
  activity_pressure_combinations <- list()
  for (activity in focused_activities) {
    # Each activity causes 1-2 specific pressures
    n_pressures <- sample(1:2, 1)
    selected_pressures <- sample(focused_pressures,
                                min(n_pressures, length(focused_pressures)),
                                replace = FALSE)

    for (pressure in selected_pressures) {
      activity_pressure_combinations[[length(activity_pressure_combinations) + 1]] <- list(
        activity = activity,
        pressure = pressure
      )
    }
  }

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

  for (combo in activity_pressure_combinations) {
    activity <- combo$activity
    pressure <- combo$pressure

    # Select 1-2 preventive controls for this pressure
    n_prev_controls <- sample(1:2, 1)
    selected_prev_controls <- sample(controls$name,
                                   min(n_prev_controls, nrow(controls)),
                                   replace = FALSE)

    for (prev_control in selected_prev_controls) {
      # Select 1-2 relevant consequences (from focused set)
      n_consequences <- sample(1:2, 1)
      selected_consequences <- sample(focused_consequences,
                                    min(n_consequences, length(focused_consequences)),
                                    replace = FALSE)

      for (consequence in selected_consequences) {
        # Select 1-2 protective controls (different from preventive)
        available_prot_controls <- setdiff(controls$name, prev_control)
        n_prot_controls <- sample(1:2, 1)
        selected_prot_controls <- sample(available_prot_controls,
                                       min(n_prot_controls, length(available_prot_controls)),
                                       replace = FALSE)

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
  bowtie_data <- addDefaultColumns(bowtie_data)

  cat("✅ Generated", nrow(bowtie_data), "bowtie scenarios with SINGLE central problem\n")
  cat("🎯 Central Problem:", unique(bowtie_data$Central_Problem), "\n")
  cat("📊 Activities:", length(unique(bowtie_data$Activity)), "\n")
  cat("⚠️ Pressures:", length(unique(bowtie_data$Pressure)), "\n")
  cat("💥 Consequences:", length(unique(bowtie_data$Consequence)), "\n")
  cat("🛡️ Controls:", length(unique(c(bowtie_data$Preventive_Control, bowtie_data$Protective_Control))), "\n")

  return(bowtie_data)
}

cat("🎉 v5.1.0 Enhanced Environmental Bowtie Risk Analysis Utilities Loaded\n")
cat("✅ FIXED protective mitigation connections\n")
cat("🖼️ PNG image support enabled\n")
cat("🔗 GRANULAR connection-level risk analysis (6 connections per scenario)\n")
cat("🎯 Overall pathway risk calculation from granular components\n")
cat("🔧 Enhanced mapping and validation functions ready\n")
cat("🆕 MULTIPLE PREVENTIVE CONTROLS per pressure support added\n")