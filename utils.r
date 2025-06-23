# =============================================================================
# Environmental Bowtie Risk Analysis - Utility Functions (Connection Fix)
# Version: 4.2.2 (Fixed Barrier Connections)
# Date: June 2025
# Description: Fixed protective mitigation and barrier connections in bowtie diagrams
#
# FIXES:
# - Protective mitigation barriers now properly connected
# - Only show barrier nodes that have actual connections
# - Improved logic for preventive controls and escalation factors
# - Better data validation for barrier relationships
# - Ensured all displayed nodes have proper incoming/outgoing edges
#
# FEATURES:
# - Multiple activities can contribute to same pressures
# - Multiple controls can address same pressures  
# - Multiple escalation factors can affect same controls
# - Multiple mitigation strategies for same consequences
# - Proper visual legend showing actual node shapes and colors
# - Optimized node sizing for better readability
# - Enhanced visual hierarchy with size differentiation
#
# PERFORMANCE OPTIMIZATIONS:
# - Vectorized operations for risk calculations
# - Pre-allocation of data frames and vectors
# - Caching system for expensive computations
# - Optimized data structures using integers where possible
# - Memory-efficient data generation and processing
# =============================================================================

# Cache for expensive computations
.cache <- new.env()

# Function to generate enhanced environmental management sample data with multiple connections
generateEnvironmentalData <- function() {
  cat("Generating comprehensive environmental management data with multiple interconnected pathways\n")
  
  # Create more comprehensive data with multiple connections
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
    
    # Environmental Pressures (Threats) from activities - multiple pressures per activity
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
    
    # Preventive Controls - multiple controls can address same pressure
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
    
    # Escalation Factors that can worsen the situation - multiple factors per scenario
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
    
    # Central Problem (Main Environmental Hazard) - multiple pathways to same problem
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
    
    # Protective Mitigation - multiple mitigations for same problem
    Protective_Mitigation = c(
      "Water quality monitoring and rapid response alerts", "Algae bloom early warning systems", "Lake aeration systems",
      "Habitat restoration and fish restocking programs", "Carbon sequestration programs",
      "Emergency water treatment and alternative supplies", "Species relocation and habitat restoration", "Emergency water treatment systems",
      "Public health advisories and beach closure protocols", "Advanced water treatment technology",
      "Community alternative water supplies and filters", "Groundwater remediation systems",
      "Emergency response protocols and containment", "Heavy metal remediation technology", "Air quality monitoring and alerts",
      "Emergency response protocols and containment", "Waste cleanup and remediation",
      "Emergency medical response and decontamination", "Community evacuation procedures",
      "Climate adaptation measures and resilient infrastructure", "Public health protection measures",
      "Control and eradication programs with monitoring", "Oil spill response and cleanup",
      "Sediment removal and water treatment", "Community noise protection measures",
      "Water treatment and ecosystem restoration", "Emergency water supplies and conservation"
    ),
    
    # Final Environmental Consequences - multiple consequences per problem
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
    
    Likelihood = c(4, 3, 3, 4, 3, 4, 3, 4, 3, 4, 3, 3, 3, 2, 3, 3, 3, 2, 2, 5, 4, 2, 3, 4, 3, 3, 2),
    Severity = c(5, 4, 3, 5, 4, 5, 4, 4, 5, 5, 4, 4, 4, 5, 4, 4, 3, 5, 4, 5, 4, 4, 4, 3, 4, 4, 3),
    stringsAsFactors = FALSE
  )
  
  # Calculate Risk_Level vectorized
  risk_scores <- sample_data$Likelihood * sample_data$Severity
  sample_data$Risk_Level <- ifelse(risk_scores <= 6, "Low",
                                  ifelse(risk_scores <= 15, "Medium", "High"))
  
  cat("Generated", nrow(sample_data), "rows of comprehensive environmental data with multiple interconnected pathways\n")
  return(sample_data)
}

# Function to validate required columns in uploaded data
validateDataColumns <- function(data) {
  required_cols <- c("Activity", "Pressure", "Central_Problem", "Consequence")
  missing_cols <- setdiff(required_cols, names(data))
  list(valid = length(missing_cols) == 0, missing = missing_cols)
}

# Function to add default columns if missing (enhanced structure)
addDefaultColumns <- function(data) {
  n_rows <- nrow(data)
  
  if (!"Activity" %in% names(data)) data$Activity <- paste("Activity", seq_len(n_rows))
  if (!"Pressure" %in% names(data)) data$Pressure <- paste("Pressure", seq_len(n_rows))
  if (!"Preventive_Control" %in% names(data)) data$Preventive_Control <- character(n_rows)
  if (!"Escalation_Factor" %in% names(data)) data$Escalation_Factor <- character(n_rows)
  if (!"Central_Problem" %in% names(data)) data$Central_Problem <- "Environmental Risk"
  if (!"Protective_Mitigation" %in% names(data)) data$Protective_Mitigation <- character(n_rows)
  if (!"Consequence" %in% names(data)) data$Consequence <- paste("Consequence", seq_len(n_rows))
  if (!"Likelihood" %in% names(data)) data$Likelihood <- sample.int(5, n_rows, replace = TRUE)
  if (!"Severity" %in% names(data)) data$Severity <- sample.int(5, n_rows, replace = TRUE)
  if (!"Risk_Level" %in% names(data)) {
    risk_scores <- data$Likelihood * data$Severity
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

# Enhanced node creation for comprehensive bowtie structure
createBowtieNodes <- function(hazard_data, selected_problem, node_size, show_risk_levels, show_barriers) {
  cache_key <- paste0("nodes_", selected_problem, "_", node_size, "_", show_risk_levels, "_", show_barriers)
  if (exists(cache_key, envir = .cache)) {
    return(get(cache_key, envir = .cache))
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
    # Pre-calculate unique values for barrier elements - this will be updated in node creation
    preventive_controls <- unique(hazard_data$Preventive_Control[hazard_data$Preventive_Control != ""])
    escalation_factors <- unique(hazard_data$Escalation_Factor[hazard_data$Escalation_Factor != ""])
    protective_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Protective_Mitigation != ""])
    n_barriers <- length(preventive_controls) + length(escalation_factors) + length(protective_mitigations)
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
  
  # Hazard node (center)
  ids[idx] <- 1
  labels[idx] <- selected_problem
  groups[idx] <- "central_problem"
  colors[idx] <- CENTRAL_PROBLEM_COLOR
  shapes[idx] <- "diamond"
  sizes[idx] <- node_size * 2.0  # Larger central problem
  font_sizes[idx] <- 18
  idx <- idx + 1
  
  # Activity nodes (far left)
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
    sizes[activity_indices] <- node_size * 1.1  # Slightly larger activities
    font_sizes[activity_indices] <- 12
    idx <- idx + n_activities
  }
  
  # Pressure nodes (left side)
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
    sizes[pressure_indices] <- node_size * 1.0  # Standard size pressures
    font_sizes[pressure_indices] <- 12
    idx <- idx + n_pressures
  }
  
  # Consequence nodes (right side)
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
    sizes[cons_indices] <- node_size * 1.0  # Standard size consequences
    font_sizes[cons_indices] <- 12
    idx <- idx + n_consequences
  }
  
  # Barrier and escalation factor nodes (only include those that are actually used)
  if (show_barriers) {
    # Only include preventive controls that are actually used in the data
    used_preventive_controls <- unique(hazard_data$Preventive_Control[hazard_data$Preventive_Control != ""])
    if (length(used_preventive_controls) > 0) {
      prev_indices <- idx:(idx + length(used_preventive_controls) - 1)
      ids[prev_indices] <- 300 + seq_len(length(used_preventive_controls))
      labels[prev_indices] <- used_preventive_controls
      groups[prev_indices] <- "preventive_control"
      colors[prev_indices] <- PREVENTIVE_COLOR
      shapes[prev_indices] <- "square"
      sizes[prev_indices] <- node_size * 0.9  # Slightly smaller controls
      font_sizes[prev_indices] <- 11
      idx <- idx + length(used_preventive_controls)
      # Update the variable for edge creation
      preventive_controls <- used_preventive_controls
    }
    
    # Only include escalation factors that are actually used in the data
    used_escalation_factors <- unique(hazard_data$Escalation_Factor[hazard_data$Escalation_Factor != ""])
    if (length(used_escalation_factors) > 0) {
      esc_indices <- idx:(idx + length(used_escalation_factors) - 1)
      ids[esc_indices] <- 350 + seq_len(length(used_escalation_factors))
      labels[esc_indices] <- used_escalation_factors
      groups[esc_indices] <- "escalation_factor"
      colors[esc_indices] <- ESCALATION_COLOR
      shapes[esc_indices] <- "triangleDown"
      sizes[esc_indices] <- node_size * 0.9  # Slightly smaller escalation factors
      font_sizes[esc_indices] <- 11
      idx <- idx + length(used_escalation_factors)
      # Update the variable for edge creation
      escalation_factors <- used_escalation_factors
    }
    
    # Only include protective mitigations that have consequences in the data
    mitigations_with_consequences <- character(0)
    for (consequence in unique(hazard_data$Consequence[hazard_data$Consequence != ""])) {
      related_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Consequence == consequence & hazard_data$Protective_Mitigation != ""])
      mitigations_with_consequences <- c(mitigations_with_consequences, related_mitigations)
    }
    used_protective_mitigations <- unique(mitigations_with_consequences)
    
    if (length(used_protective_mitigations) > 0) {
      prot_indices <- idx:(idx + length(used_protective_mitigations) - 1)
      ids[prot_indices] <- 400 + seq_len(length(used_protective_mitigations))
      labels[prot_indices] <- used_protective_mitigations
      groups[prot_indices] <- "protective_mitigation"
      colors[prot_indices] <- PROTECTIVE_COLOR
      shapes[prot_indices] <- "square"
      sizes[prot_indices] <- node_size * 0.9  # Slightly smaller mitigations
      font_sizes[prot_indices] <- 11
      # Update the variable for edge creation
      protective_mitigations <- used_protective_mitigations
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
  
  # Cache the result
  assign(cache_key, nodes, envir = .cache)
  nodes
}

# Enhanced edge creation for comprehensive bowtie structure with multiple connections
createBowtieEdges <- function(hazard_data, show_barriers) {
  cache_key <- paste0("edges_multi_", nrow(hazard_data), "_", show_barriers)
  if (exists(cache_key, envir = .cache)) {
    return(get(cache_key, envir = .cache))
  }
  
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
    # Simple flow with multiple connections: Activity → Pressure → Central Problem → Consequence
    
    # Activity → Multiple Pressures connections
    for (i in seq_along(activities)) {
      activity <- activities[i]
      # Find ALL pressures associated with this activity
      related_pressures <- unique(hazard_data$Pressure[hazard_data$Activity == activity & hazard_data$Pressure != ""])
      
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
    
    # Pressure → Central Problem connections (multiple pressures can contribute to same problem)
    for (i in seq_along(pressures)) {
      from <- c(from, 100 + i)
      to <- c(to, 1)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#E74C3C")
      widths <- c(widths, 3)
      dashes <- c(dashes, FALSE)
    }
    
    # Central Problem → Multiple Consequences connections
    for (i in seq_along(consequences)) {
      from <- c(from, 1)
      to <- c(to, 200 + i)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#C0392B")
      widths <- c(widths, 3)
      dashes <- c(dashes, FALSE)
    }
    
  } else {
    # Complex flow with barriers and multiple connections
    
    # Get barrier elements that are actually used in the data
    used_preventive_controls <- unique(hazard_data$Preventive_Control[hazard_data$Preventive_Control != ""])
    used_escalation_factors <- unique(hazard_data$Escalation_Factor[hazard_data$Escalation_Factor != ""])
    
    # Get protective mitigations that have consequences
    mitigations_with_consequences <- character(0)
    for (consequence in consequences) {
      related_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Consequence == consequence & hazard_data$Protective_Mitigation != ""])
      mitigations_with_consequences <- c(mitigations_with_consequences, related_mitigations)
    }
    used_protective_mitigations <- unique(mitigations_with_consequences)
    
    # Activity → Multiple Pressures connections
    for (i in seq_along(activities)) {
      activity <- activities[i]
      related_pressures <- unique(hazard_data$Pressure[hazard_data$Activity == activity & hazard_data$Pressure != ""])
      
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
    
    # Pressure → Multiple Preventive Controls connections
    for (i in seq_along(pressures)) {
      pressure <- pressures[i]
      # Find ALL controls that address this pressure
      related_controls <- unique(hazard_data$Preventive_Control[hazard_data$Pressure == pressure & hazard_data$Preventive_Control != ""])
      
      if (length(related_controls) > 0) {
        for (control in related_controls) {
          control_idx <- which(used_preventive_controls == control)
          if (length(control_idx) > 0) {
            # Pressure → Preventive Control
            from <- c(from, 100 + i)
            to <- c(to, 300 + control_idx)
            arrows <- c(arrows, "to")
            colors <- c(colors, "#E74C3C")
            widths <- c(widths, 2)
            dashes <- c(dashes, FALSE)
          }
        }
      } else {
        # If no controls, direct connection to central problem
        from <- c(from, 100 + i)
        to <- c(to, 1)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#E74C3C")
        widths <- c(widths, 3)
        dashes <- c(dashes, FALSE)
      }
    }
    
    # Preventive Control → Multiple Escalation Factors (control failures) and Central Problem
    for (i in seq_along(used_preventive_controls)) {
      control <- used_preventive_controls[i]
      # Find escalation factors associated with this control
      related_escalations <- unique(hazard_data$Escalation_Factor[hazard_data$Preventive_Control == control & hazard_data$Escalation_Factor != ""])
      
      if (length(related_escalations) > 0) {
        for (escalation in related_escalations) {
          escalation_idx <- which(used_escalation_factors == escalation)
          if (length(escalation_idx) > 0) {
            # Control → Escalation Factor (control fails)
            from <- c(from, 300 + i)
            to <- c(to, 350 + escalation_idx)
            arrows <- c(arrows, "to")
            colors <- c(colors, "#F39C12")
            widths <- c(widths, 2)
            dashes <- c(dashes, TRUE)
          }
        }
      }
      
      # Control success path to central problem (always included for used controls)
      from <- c(from, 300 + i)
      to <- c(to, 1)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#27AE60")
      widths <- c(widths, 1)
      dashes <- c(dashes, TRUE)
    }
    
    # Multiple Escalation Factors → Central Problem
    for (i in seq_along(used_escalation_factors)) {
      from <- c(from, 350 + i)
      to <- c(to, 1)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#F39C12")
      widths <- c(widths, 2)
      dashes <- c(dashes, FALSE)
    }
    
    # Central Problem → Multiple Protective Mitigations (only those with consequences)
    for (i in seq_along(used_protective_mitigations)) {
      # Central Problem → Protective Mitigation
      from <- c(from, 1)
      to <- c(to, 400 + i)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#C0392B")
      widths <- c(widths, 2)
      dashes <- c(dashes, FALSE)
    }
    
    # Multiple Protective Mitigations → Consequences
    for (i in seq_along(consequences)) {
      consequence <- consequences[i]
      # Find ALL mitigations that address this consequence
      related_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Consequence == consequence & hazard_data$Protective_Mitigation != ""])
      
      if (length(related_mitigations) > 0) {
        for (mitigation in related_mitigations) {
          mitigation_idx <- which(used_protective_mitigations == mitigation)
          if (length(mitigation_idx) > 0) {
            # Protective Mitigation → Consequence (mitigation reduces impact)
            from <- c(from, 400 + mitigation_idx)
            to <- c(to, 200 + i)
            arrows <- c(arrows, "to")
            colors <- c(colors, "#3498DB")
            widths <- c(widths, 2)
            dashes <- c(dashes, TRUE)
          }
        }
      } else {
        # If no mitigation, direct severe consequence from central problem
        from <- c(from, 1)
        to <- c(to, 200 + i)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#C0392B")
        widths <- c(widths, 3)
        dashes <- c(dashes, FALSE)
      }
    }
    
    # Add cross-connections for same elements that appear in multiple pathways
    # These connections show the complex interconnected nature of environmental systems
    
    # Find pressures that have multiple activities contributing to them
    for (i in seq_along(pressures)) {
      pressure <- pressures[i]
      contributing_activities <- unique(hazard_data$Activity[hazard_data$Pressure == pressure & hazard_data$Activity != ""])
      
      # If multiple activities contribute to same pressure, they're already connected above
      # This creates the convergent nature of environmental risks
    }
    
    # Find consequences that can result from multiple mitigation failures
    for (i in seq_along(consequences)) {
      consequence <- consequences[i]
      related_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Consequence == consequence & hazard_data$Protective_Mitigation != ""])
      
      # Multiple mitigation strategies for same consequence are already connected above
      # This shows redundancy in protective measures
    }
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
  
  # Cache the result
  assign(cache_key, edges, envir = .cache)
  edges
}

# Function to create a default row for data editing (enhanced structure)
createDefaultRow <- function(selected_problem = "New Environmental Risk") {
  data.frame(
    Activity = "New Activity",
    Pressure = "New Pressure",
    Preventive_Control = "New Control",
    Escalation_Factor = "New Escalation Factor",
    Central_Problem = selected_problem,
    Protective_Mitigation = "New Mitigation",
    Consequence = "New Consequence",
    Likelihood = 3L,
    Severity = 3L,
    Risk_Level = "Medium",
    stringsAsFactors = FALSE
  )
}

# Optimized numeric validation
validateNumericInput <- function(value, min_val = 1L, max_val = 5L) {
  num_value <- suppressWarnings(as.integer(value))
  if (is.na(num_value) || num_value < min_val || num_value > max_val) {
    list(valid = FALSE, value = NULL, 
         message = paste("Value must be between", min_val, "and", max_val))
  } else {
    list(valid = TRUE, value = num_value, message = NULL)
  }
}

# Enhanced data summary function
getDataSummary <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  paste(
    "Rows:", nrow(data),
    "| Activities:", length(unique(data$Activity)),
    "| Central Problems:", length(unique(data$Central_Problem)),
    "| Consequences:", length(unique(data$Consequence)),
    "| Risk Levels:", paste(names(table(data$Risk_Level)), collapse = ", ")
  )
}