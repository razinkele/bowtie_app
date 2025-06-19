# =============================================================================
# Environmental Bowtie Risk Analysis - Utility Functions
# Version: 4.0.2
# Date: June 2025
# Description: Helper functions and data generation utilities for the 
#              Environmental Bowtie Risk Analysis Shiny Application
# =============================================================================

# Function to generate environmental management sample data
generateEnvironmentalData <- function() {
  cat("Generating simplified environmental management data with eutrophication focus\n")
  
  sample_data <- data.frame(
    # Simplified Eutrophication scenarios - key examples only
    Threat = c(
      # Agricultural sources
      "Agricultural fertilizer runoff",
      "Animal waste from farms",
      
      # Urban sources
      "Urban stormwater runoff", 
      "Sewage treatment overflow",
      
      # Other nutrient sources
      "Septic system leakage",
      "Industrial nutrient discharge",
      
      # Other environmental threats for comparison
      "Industrial wastewater discharge", 
      "Chemical spill",
      "Climate change", 
      "Invasive species introduction"
    ),
    
    Hazard = c(
      # Eutrophication cases
      "Eutrophication",
      "Eutrophication",
      "Eutrophication",
      "Eutrophication",
      "Eutrophication",
      "Eutrophication",
      
      # Other hazards
      "Water pollution", 
      "Toxic release",
      "Temperature rise", 
      "Ecosystem disruption"
    ),
    
    Consequence = c(
      # Eutrophication consequences
      "Algal blooms and dead zones",
      "Fish kills and biodiversity loss",
      "Oxygen depletion in water",
      "Drinking water contamination",
      "Beach closures and health risks",
      "Economic losses to fisheries",
      
      # Other consequences
      "Aquatic ecosystem damage", 
      "Wildlife poisoning",
      "Extreme weather events", 
      "Native species displacement"
    ),
    
    Preventive_Barrier = c(
      # Eutrophication prevention
      "Nutrient management plans and buffer strips",
      "Manure management and rotational grazing",
      "Stormwater management and green infrastructure",
      "Wastewater treatment upgrades",
      "Septic system inspections and maintenance",
      "Industrial discharge permits and monitoring",
      
      # Other prevention
      "Wastewater treatment standards", 
      "Spill prevention plans",
      "Carbon reduction strategies", 
      "Biosecurity measures"
    ),
    
    Protective_Barrier = c(
      # Eutrophication protection
      "Water quality monitoring and alerts",
      "Habitat restoration and restocking",
      "Emergency water treatment",
      "Public health advisories",
      "Alternative water supplies",
      "Lake aeration and biomanipulation",
      
      # Other protection
      "Emergency response protocols", 
      "Emergency containment systems",
      "Adaptation measures", 
      "Control and eradication programs"
    ),
    
    Likelihood = c(
      # Higher likelihood for common sources
      4, 4, 4, 3, 3, 3,
      # Other threats
      3, 2, 5, 2
    ),
    
    Severity = c(
      # High severity for ecosystem impacts
      5, 5, 4, 5, 4, 4,
      # Other severities  
      4, 5, 5, 3
    ),
    
    stringsAsFactors = FALSE
  )
  
  # Calculate Risk_Level with bounds checking
  sample_data$Risk_Level <- ifelse(sample_data$Likelihood * sample_data$Severity <= 6, "Low",
                                  ifelse(sample_data$Likelihood * sample_data$Severity <= 15, "Medium", "High"))
  
  cat("Generated", nrow(sample_data), "rows of environmental data with", 
      sum(sample_data$Hazard == "Eutrophication"), "eutrophication scenarios\n")
  return(sample_data)
}

# Function to validate required columns in uploaded data
validateDataColumns <- function(data) {
  required_cols <- c("Threat", "Hazard", "Consequence")
  missing_cols <- setdiff(required_cols, names(data))
  
  if (length(missing_cols) > 0) {
    return(list(valid = FALSE, missing = missing_cols))
  }
  
  return(list(valid = TRUE, missing = NULL))
}

# Function to add default columns if missing
addDefaultColumns <- function(data) {
  if (!"Preventive_Barrier" %in% names(data)) data$Preventive_Barrier <- ""
  if (!"Protective_Barrier" %in% names(data)) data$Protective_Barrier <- ""
  if (!"Likelihood" %in% names(data)) data$Likelihood <- sample(1:5, nrow(data), replace = TRUE)
  if (!"Severity" %in% names(data)) data$Severity <- sample(1:5, nrow(data), replace = TRUE)
  if (!"Risk_Level" %in% names(data)) {
    data$Risk_Level <- ifelse(data$Likelihood * data$Severity <= 6, "Low",
                             ifelse(data$Likelihood * data$Severity <= 15, "Medium", "High"))
  }
  
  return(data)
}

# Function to calculate risk level based on likelihood and severity
calculateRiskLevel <- function(likelihood, severity) {
  risk_score <- likelihood * severity
  ifelse(risk_score <= 6, "Low",
         ifelse(risk_score <= 15, "Medium", "High"))
}

# Function to get risk color based on risk level
getRiskColor <- function(risk_level, show_risk_levels = TRUE) {
  if (!show_risk_levels) {
    return("#CCCCCC")  # Default gray
  }
  
  switch(risk_level,
         "Low" = "#90EE90",
         "Medium" = "#FFD700",
         "High" = "#FF6B6B",
         "#FFCCCB")  # Default light red
}

# Function to create network nodes for bowtie diagram
createBowtieNodes <- function(hazard_data, selected_hazard, node_size, show_risk_levels, show_barriers) {
  nodes <- data.frame(
    id = integer(),
    label = character(),
    group = character(),
    color = character(),
    shape = character(),
    size = numeric(),
    font.size = numeric(),
    stringsAsFactors = FALSE
  )
  
  # Add hazard node (center) - Diamond shape for central hazard
  nodes <- rbind(nodes, data.frame(
    id = 1,
    label = selected_hazard,
    group = "hazard",
    color = "#FFD700",
    shape = "diamond",
    size = node_size * 1.5,
    font.size = 16
  ))
  
  # Add threat nodes (left side) - Triangular for threats/initiating events
  threats <- unique(hazard_data$Threat[hazard_data$Threat != ""])
  for (i in seq_along(threats)) {
    color <- if (show_risk_levels) {
      threat_risk <- hazard_data$Risk_Level[hazard_data$Threat == threats[i]][1]
      getRiskColor(threat_risk, TRUE)
    } else "#FF6B6B"
    
    nodes <- rbind(nodes, data.frame(
      id = 100 + i,
      label = threats[i],
      group = "threat",
      color = color,
      shape = "triangle",
      size = node_size,
      font.size = 12
    ))
  }
  
  # Add consequence nodes (right side) - Hexagonal for consequences/impacts
  consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
  for (i in seq_along(consequences)) {
    color <- if (show_risk_levels) {
      cons_risk <- hazard_data$Risk_Level[hazard_data$Consequence == consequences[i]][1]
      getRiskColor(cons_risk, TRUE)
    } else "#FF8C94"
    
    nodes <- rbind(nodes, data.frame(
      id = 200 + i,
      label = consequences[i],
      group = "consequence",
      color = color,
      shape = "hexagon",
      size = node_size,
      font.size = 12
    ))
  }
  
  # Add barrier nodes if requested - Square shapes for barriers
  if (show_barriers) {
    prev_barriers <- unique(hazard_data$Preventive_Barrier[hazard_data$Preventive_Barrier != ""])
    for (i in seq_along(prev_barriers)) {
      nodes <- rbind(nodes, data.frame(
        id = 300 + i,
        label = prev_barriers[i],
        group = "preventive_barrier",
        color = "#4ECDC4",
        shape = "box",
        size = node_size * 0.8,
        font.size = 10
      ))
    }
    
    prot_barriers <- unique(hazard_data$Protective_Barrier[hazard_data$Protective_Barrier != ""])
    for (i in seq_along(prot_barriers)) {
      nodes <- rbind(nodes, data.frame(
        id = 400 + i,
        label = prot_barriers[i],
        group = "protective_barrier",
        color = "#45B7D1",
        shape = "box",
        size = node_size * 0.8,
        font.size = 10
      ))
    }
  }
  
  return(nodes)
}

# Function to create network edges for bowtie diagram
createBowtieEdges <- function(hazard_data, show_barriers) {
  edges <- data.frame(
    from = integer(),
    to = integer(),
    arrows = character(),
    color = character(),
    width = numeric(),
    dashes = logical(),
    stringsAsFactors = FALSE
  )
  
  threats <- unique(hazard_data$Threat[hazard_data$Threat != ""])
  consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
  
  # Threat to hazard edges - Solid red arrows
  for (i in seq_along(threats)) {
    edges <- rbind(edges, data.frame(
      from = 100 + i,
      to = 1,
      arrows = "to",
      color = "#E74C3C",
      width = 3,
      dashes = FALSE
    ))
  }
  
  # Hazard to consequence edges - Solid red arrows
  for (i in seq_along(consequences)) {
    edges <- rbind(edges, data.frame(
      from = 1,
      to = 200 + i,
      arrows = "to",
      color = "#E74C3C",
      width = 3,
      dashes = FALSE
    ))
  }
  
  # Barrier edges if shown - Different styles for preventive vs protective
  if (show_barriers) {
    prev_barriers <- unique(hazard_data$Preventive_Barrier[hazard_data$Preventive_Barrier != ""])
    prot_barriers <- unique(hazard_data$Protective_Barrier[hazard_data$Protective_Barrier != ""])
    
    # Preventive barriers - Green dashed lines blocking threats
    for (i in seq_along(prev_barriers)) {
      related_threats <- hazard_data$Threat[hazard_data$Preventive_Barrier == prev_barriers[i]]
      for (threat in related_threats) {
        threat_id <- which(threats == threat) + 100
        if (length(threat_id) > 0) {
          edges <- rbind(edges, data.frame(
            from = 300 + i,
            to = threat_id,
            arrows = "to",
            color = "#27AE60",
            width = 2,
            dashes = TRUE
          ))
        }
      }
    }
    
    # Protective barriers - Blue dashed lines mitigating consequences
    for (i in seq_along(prot_barriers)) {
      related_cons <- hazard_data$Consequence[hazard_data$Protective_Barrier == prot_barriers[i]]
      for (cons in related_cons) {
        cons_id <- which(consequences == cons) + 200
        if (length(cons_id) > 0) {
          edges <- rbind(edges, data.frame(
            from = cons_id,
            to = 400 + i,
            arrows = "to",
            color = "#3498DB",
            width = 2,
            dashes = TRUE
          ))
        }
      }
    }
  }
  
  return(edges)
}

# Constants for risk colors
RISK_COLORS <- c("Low" = "#90EE90", "Medium" = "#FFD700", "High" = "#FF6B6B")

# Function to create a default row for data editing
createDefaultRow <- function(selected_hazard = "New Hazard") {
  data.frame(
    Threat = "New Threat",
    Hazard = selected_hazard,
    Consequence = "New Consequence",
    Preventive_Barrier = "New Preventive Barrier",
    Protective_Barrier = "New Protective Barrier",
    Likelihood = 3,
    Severity = 3,
    Risk_Level = "Medium",
    stringsAsFactors = FALSE
  )
}

# Function to validate numeric inputs (likelihood and severity)
validateNumericInput <- function(value, min_val = 1, max_val = 5) {
  num_value <- as.numeric(value)
  if (is.na(num_value) || num_value < min_val || num_value > max_val) {
    return(list(valid = FALSE, value = NULL, 
                message = paste("Value must be between", min_val, "and", max_val)))
  }
  return(list(valid = TRUE, value = num_value, message = NULL))
}