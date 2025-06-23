# =============================================================================
# Environmental Bowtie Risk Analysis - Utility Functions (Enhanced Structure)
# Version: 4.1.0 (Comprehensive Bowtie Structure)
# Date: June 2025
# Description: Enhanced bowtie structure with Activities → Pressures → Controls → 
#              Escalation Factors → Central Problem → Mitigation → Consequences
# =============================================================================

# Cache for expensive computations
.cache <- new.env()

# Function to generate enhanced environmental management sample data
generateEnvironmentalData <- function() {
  cat("Generating comprehensive environmental management data with enhanced bowtie structure\n")
  
  sample_data <- data.frame(
    # Human Activities that create environmental pressures
    Activity = c(
      "Intensive agriculture operations",
      "Livestock farming practices", 
      "Urban development",
      "Municipal wastewater management",
      "Residential septic systems",
      "Industrial manufacturing",
      "Industrial waste disposal",
      "Chemical transportation",
      "Fossil fuel consumption",
      "International shipping"
    ),
    
    # Environmental Pressures (Threats) from activities
    Pressure = c(
      "Agricultural fertilizer runoff",
      "Animal waste from farms",
      "Urban stormwater runoff", 
      "Sewage treatment overflow",
      "Septic system leakage",
      "Industrial nutrient discharge",
      "Industrial wastewater discharge", 
      "Chemical spill",
      "Climate change emissions", 
      "Invasive species introduction"
    ),
    
    # Preventive Barriers (Controls) to prevent escalation
    Preventive_Control = c(
      "Nutrient management plans and buffer strips",
      "Manure management and rotational grazing",
      "Stormwater management and green infrastructure",
      "Wastewater treatment upgrades and monitoring",
      "Septic system inspections and maintenance programs",
      "Industrial discharge permits and real-time monitoring",
      "Advanced wastewater treatment standards", 
      "Spill prevention and containment systems",
      "Carbon reduction strategies and renewable energy", 
      "Biosecurity measures and quarantine protocols"
    ),
    
    # Escalation Factors that can worsen the situation
    Escalation_Factor = c(
      "Heavy rainfall and flooding events",
      "Drought conditions concentrating pollutants",
      "High water temperatures promoting growth",
      "Infrastructure failures during peak flow",
      "Soil saturation and system overload",
      "Equipment malfunction and human error",
      "Inadequate treatment during high demand",
      "Transportation accidents in sensitive areas",
      "Extreme weather events and system stress",
      "Established invasion pathways"
    ),
    
    # Central Problem (Main Environmental Hazard)
    Central_Problem = c(
      rep("Eutrophication", 6),
      "Water pollution", 
      "Toxic release",
      "Climate impact", 
      "Ecosystem disruption"
    ),
    
    # Protective Barriers (Mitigation) to reduce consequences
    Protective_Mitigation = c(
      "Water quality monitoring and rapid response alerts",
      "Habitat restoration and fish restocking programs",
      "Emergency water treatment and alternative supplies",
      "Public health advisories and beach closure protocols",
      "Community alternative water supplies and filters",
      "Lake aeration systems and biomanipulation",
      "Emergency response protocols and containment", 
      "Emergency medical response and decontamination",
      "Climate adaptation measures and resilient infrastructure", 
      "Control and eradication programs with monitoring"
    ),
    
    # Final Environmental Consequences
    Consequence = c(
      "Algal blooms and dead zones",
      "Fish kills and biodiversity loss",
      "Oxygen depletion in water bodies",
      "Drinking water contamination",
      "Beach closures and health risks",
      "Economic losses to fisheries and tourism",
      "Aquatic ecosystem degradation", 
      "Wildlife poisoning and habitat loss",
      "Extreme weather events and infrastructure damage", 
      "Native species displacement and ecosystem collapse"
    ),
    
    Likelihood = c(4, 4, 4, 3, 3, 3, 3, 2, 5, 2),
    Severity = c(5, 5, 4, 5, 4, 4, 4, 5, 5, 3),
    stringsAsFactors = FALSE
  )
  
  # Calculate Risk_Level vectorized
  risk_scores <- sample_data$Likelihood * sample_data$Severity
  sample_data$Risk_Level <- ifelse(risk_scores <= 6, "Low",
                                  ifelse(risk_scores <= 15, "Medium", "High"))
  
  cat("Generated", nrow(sample_data), "rows of comprehensive environmental data\n")
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
  
  # Central Problem node (center) - Diamond shape
  ids[idx] <- 1
  labels[idx] <- selected_problem
  groups[idx] <- "central_problem"
  colors[idx] <- CENTRAL_PROBLEM_COLOR
  shapes[idx] <- "diamond"
  sizes[idx] <- node_size * 1.8
  font_sizes[idx] <- 16
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
    sizes[activity_indices] <- node_size * 0.9
    font_sizes[activity_indices] <- 11
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
    sizes[pressure_indices] <- node_size
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
    sizes[cons_indices] <- node_size
    font_sizes[cons_indices] <- 12
    idx <- idx + n_consequences
  }
  
  # Barrier and escalation factor nodes
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
    
    if (exists("protective_mitigations") && length(protective_mitigations) > 0) {
      prot_indices <- idx:(idx + length(protective_mitigations) - 1)
      ids[prot_indices] <- 400 + seq_len(length(protective_mitigations))
      labels[prot_indices] <- protective_mitigations
      groups[prot_indices] <- "protective_mitigation"
      colors[prot_indices] <- PROTECTIVE_COLOR
      shapes[prot_indices] <- "square"
      sizes[prot_indices] <- node_size * 0.8
      font_sizes[prot_indices] <- 10
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

# Enhanced edge creation for comprehensive bowtie structure
createBowtieEdges <- function(hazard_data, show_barriers) {
  cache_key <- paste0("edges_comp_", nrow(hazard_data), "_", show_barriers)
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
    # Complex flow with barriers: Activity → Pressure → Control → Escalation → Central Problem → Mitigation → Consequence
    
    preventive_controls <- unique(hazard_data$Preventive_Control[hazard_data$Preventive_Control != ""])
    escalation_factors <- unique(hazard_data$Escalation_Factor[hazard_data$Escalation_Factor != ""])
    protective_mitigations <- unique(hazard_data$Protective_Mitigation[hazard_data$Protective_Mitigation != ""])
    
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
    
    # Central Problem → Protective Mitigation → Consequence pathway
    for (i in seq_along(consequences)) {
      consequence <- consequences[i]
      mitigation_for_consequence <- hazard_data$Protective_Mitigation[hazard_data$Consequence == consequence][1]
      
      if (!is.na(mitigation_for_consequence) && mitigation_for_consequence != "") {
        mitigation_idx <- which(protective_mitigations == mitigation_for_consequence)
        if (length(mitigation_idx) > 0) {
          # Central Problem → Protective Mitigation
          from <- c(from, 1)
          to <- c(to, 400 + mitigation_idx)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#C0392B")
          widths <- c(widths, 2)
          dashes <- c(dashes, FALSE)
          
          # Protective Mitigation → Consequence (mitigation reduces impact)
          from <- c(from, 400 + mitigation_idx)
          to <- c(to, 200 + i)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#3498DB")
          widths <- c(widths, 2)
          dashes <- c(dashes, TRUE)
        }
      } else {
        # Direct central problem → consequence if no mitigation
        from <- c(from, 1)
        to <- c(to, 200 + i)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#C0392B")
        widths <- c(widths, 3)
        dashes <- c(dashes, FALSE)
      }
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