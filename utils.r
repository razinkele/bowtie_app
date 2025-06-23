# =============================================================================
# Environmental Bowtie Risk Analysis - Utility Functions (Optimized)
# Version: 4.0.4 (Bowtie Structure Fixed)
# Date: June 2025
# Description: Optimized helper functions with corrected bowtie barrier connections
#
# PERFORMANCE OPTIMIZATIONS IMPLEMENTED:
# - Vectorized operations for risk calculations
# - Pre-allocation of data frames and vectors
# - Caching system for expensive computations (nodes, edges, unique values)
# - Optimized data structures using integers where possible
# - Reduced string operations and repeated calculations
# - Memory-efficient data generation and processing
#
# BOWTIE STRUCTURE CORRECTIONS:
# - Fixed barrier connections to show proper intervention points
# - Preventive barriers now correctly intercept threat → hazard paths
# - Protective barriers now correctly intercept hazard → consequence paths
# - Added clear visual distinction between causal flow and barrier intervention
# =============================================================================

# Cache for expensive computations
.cache <- new.env()

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
      rep("Eutrophication", 6),
      
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
    
    Likelihood = c(4, 4, 4, 3, 3, 3, 3, 2, 5, 2),
    Severity = c(5, 5, 4, 5, 4, 4, 4, 5, 5, 3),
    stringsAsFactors = FALSE
  )
  
  # Calculate Risk_Level vectorized
  risk_scores <- sample_data$Likelihood * sample_data$Severity
  sample_data$Risk_Level <- ifelse(risk_scores <= 6, "Low",
                                  ifelse(risk_scores <= 15, "Medium", "High"))
  
  cat("Generated", nrow(sample_data), "rows of environmental data with", 
      sum(sample_data$Hazard == "Eutrophication"), "eutrophication scenarios\n")
  return(sample_data)
}

# Function to validate required columns in uploaded data
validateDataColumns <- function(data) {
  required_cols <- c("Threat", "Hazard", "Consequence")
  missing_cols <- setdiff(required_cols, names(data))
  
  list(valid = length(missing_cols) == 0, missing = missing_cols)
}

# Function to add default columns if missing (optimized)
addDefaultColumns <- function(data) {
  n_rows <- nrow(data)
  
  if (!"Preventive_Barrier" %in% names(data)) data$Preventive_Barrier <- character(n_rows)
  if (!"Protective_Barrier" %in% names(data)) data$Protective_Barrier <- character(n_rows)
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

# Pre-defined color mappings for performance
RISK_COLORS <- c("Low" = "#90EE90", "Medium" = "#FFD700", "High" = "#FF6B6B")
THREAT_COLOR <- "#FF6B6B"
CONSEQUENCE_COLOR <- "#FF8C94"
HAZARD_COLOR <- "#FFD700"
PREVENTIVE_BARRIER_COLOR <- "#4ECDC4"
PROTECTIVE_BARRIER_COLOR <- "#45B7D1"

# Optimized risk color function
getRiskColor <- function(risk_level, show_risk_levels = TRUE) {
  if (!show_risk_levels) return("#CCCCCC")
  RISK_COLORS[risk_level]
}

# Cached unique value extraction
getCachedUnique <- function(data, column, cache_key) {
  if (exists(cache_key, envir = .cache)) {
    return(get(cache_key, envir = .cache))
  }
  
  unique_vals <- unique(data[[column]][data[[column]] != ""])
  assign(cache_key, unique_vals, envir = .cache)
  unique_vals
}

# Clear cache when data changes
clearCache <- function() {
  rm(list = ls(envir = .cache), envir = .cache)
}

# Optimized node creation with pre-allocation
createBowtieNodes <- function(hazard_data, selected_hazard, node_size, show_risk_levels, show_barriers) {
  # Clear cache if hazard changed
  cache_key <- paste0("nodes_", selected_hazard, "_", node_size, "_", show_risk_levels, "_", show_barriers)
  if (exists(cache_key, envir = .cache)) {
    return(get(cache_key, envir = .cache))
  }
  
  # Pre-calculate unique values
  threats <- getCachedUnique(hazard_data, "Threat", paste0("threats_", selected_hazard))
  consequences <- getCachedUnique(hazard_data, "Consequence", paste0("consequences_", selected_hazard))
  
  # Pre-allocate node data frame
  n_threats <- length(threats)
  n_consequences <- length(consequences)
  n_barriers <- 0
  
  if (show_barriers) {
    prev_barriers <- getCachedUnique(hazard_data, "Preventive_Barrier", paste0("prev_barriers_", selected_hazard))
    prot_barriers <- getCachedUnique(hazard_data, "Protective_Barrier", paste0("prot_barriers_", selected_hazard))
    n_barriers <- length(prev_barriers) + length(prot_barriers)
  }
  
  total_nodes <- 1 + n_threats + n_consequences + n_barriers
  
  # Pre-allocate vectors for better performance
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
  labels[idx] <- selected_hazard
  groups[idx] <- "hazard"
  colors[idx] <- HAZARD_COLOR
  shapes[idx] <- "diamond"
  sizes[idx] <- node_size * 1.5
  font_sizes[idx] <- 16
  idx <- idx + 1
  
  # Threat nodes
  if (n_threats > 0) {
    threat_colors <- if (show_risk_levels) {
      sapply(threats, function(t) {
        risk <- hazard_data$Risk_Level[hazard_data$Threat == t][1]
        getRiskColor(risk, TRUE)
      })
    } else {
      rep(THREAT_COLOR, n_threats)
    }
    
    threat_indices <- idx:(idx + n_threats - 1)
    ids[threat_indices] <- 100 + seq_len(n_threats)
    labels[threat_indices] <- threats
    groups[threat_indices] <- "threat"
    colors[threat_indices] <- threat_colors
    shapes[threat_indices] <- "triangle"
    sizes[threat_indices] <- node_size
    font_sizes[threat_indices] <- 12
    idx <- idx + n_threats
  }
  
  # Consequence nodes
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
  
  # Barrier nodes
  if (show_barriers) {
    if (exists("prev_barriers") && length(prev_barriers) > 0) {
      prev_indices <- idx:(idx + length(prev_barriers) - 1)
      ids[prev_indices] <- 300 + seq_len(length(prev_barriers))
      labels[prev_indices] <- prev_barriers
      groups[prev_indices] <- "preventive_barrier"
      colors[prev_indices] <- PREVENTIVE_BARRIER_COLOR
      shapes[prev_indices] <- "box"
      sizes[prev_indices] <- node_size * 0.8
      font_sizes[prev_indices] <- 10
      idx <- idx + length(prev_barriers)
    }
    
    if (exists("prot_barriers") && length(prot_barriers) > 0) {
      prot_indices <- idx:(idx + length(prot_barriers) - 1)
      ids[prot_indices] <- 400 + seq_len(length(prot_barriers))
      labels[prot_indices] <- prot_barriers
      groups[prot_indices] <- "protective_barrier"
      colors[prot_indices] <- PROTECTIVE_BARRIER_COLOR
      shapes[prot_indices] <- "box"
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

# Optimized edge creation with correct bowtie logic
createBowtieEdges <- function(hazard_data, show_barriers) {
  # Create simple cache key without digest dependency
  cache_key <- paste0("edges_", nrow(hazard_data), "_", show_barriers, "_", 
                     paste(head(hazard_data$Threat, 3), collapse = ""))
  if (exists(cache_key, envir = .cache)) {
    return(get(cache_key, envir = .cache))
  }
  
  threats <- unique(hazard_data$Threat[hazard_data$Threat != ""])
  consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
  
  # Initialize edge vectors
  from <- integer(0)
  to <- integer(0)
  arrows <- character(0)
  colors <- character(0)
  widths <- numeric(0)
  dashes <- logical(0)
  
  # Main causal path edges - Threat to hazard (without barriers)
  if (!show_barriers) {
    # Direct threat to hazard connections (red solid arrows)
    for (i in seq_along(threats)) {
      from <- c(from, 100 + i)
      to <- c(to, 1)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#E74C3C")
      widths <- c(widths, 3)
      dashes <- c(dashes, FALSE)
    }
    
    # Direct hazard to consequence connections (red solid arrows)
    for (i in seq_along(consequences)) {
      from <- c(from, 1)
      to <- c(to, 200 + i)
      arrows <- c(arrows, "to")
      colors <- c(colors, "#E74C3C")
      widths <- c(widths, 3)
      dashes <- c(dashes, FALSE)
    }
  } else {
    # With barriers: Create proper bowtie structure
    prev_barriers <- unique(hazard_data$Preventive_Barrier[hazard_data$Preventive_Barrier != ""])
    prot_barriers <- unique(hazard_data$Protective_Barrier[hazard_data$Protective_Barrier != ""])
    
    # For each threat, create path: Threat → Preventive Barrier → Hazard
    for (i in seq_along(threats)) {
      threat <- threats[i]
      # Find the preventive barrier for this threat
      barrier_for_threat <- hazard_data$Preventive_Barrier[hazard_data$Threat == threat][1]
      
      if (!is.na(barrier_for_threat) && barrier_for_threat != "") {
        # Find barrier ID
        barrier_idx <- which(prev_barriers == barrier_for_threat)
        if (length(barrier_idx) > 0) {
          barrier_id <- 300 + barrier_idx
          
          # Threat → Preventive Barrier (red solid)
          from <- c(from, 100 + i)
          to <- c(to, barrier_id)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#E74C3C")
          widths <- c(widths, 2)
          dashes <- c(dashes, FALSE)
          
          # Preventive Barrier → Hazard (green dashed - barrier intervenes)
          from <- c(from, barrier_id)
          to <- c(to, 1)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#27AE60")
          widths <- c(widths, 2)
          dashes <- c(dashes, TRUE)
        }
      } else {
        # No barrier - direct connection
        from <- c(from, 100 + i)
        to <- c(to, 1)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#E74C3C")
        widths <- c(widths, 3)
        dashes <- c(dashes, FALSE)
      }
    }
    
    # For each consequence, create path: Hazard → Protective Barrier → Consequence
    for (i in seq_along(consequences)) {
      consequence <- consequences[i]
      # Find the protective barrier for this consequence
      barrier_for_cons <- hazard_data$Protective_Barrier[hazard_data$Consequence == consequence][1]
      
      if (!is.na(barrier_for_cons) && barrier_for_cons != "") {
        # Find barrier ID
        barrier_idx <- which(prot_barriers == barrier_for_cons)
        if (length(barrier_idx) > 0) {
          barrier_id <- 400 + barrier_idx
          
          # Hazard → Protective Barrier (red solid)
          from <- c(from, 1)
          to <- c(to, barrier_id)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#E74C3C")
          widths <- c(widths, 2)
          dashes <- c(dashes, FALSE)
          
          # Protective Barrier → Consequence (blue dashed - barrier mitigates)
          from <- c(from, barrier_id)
          to <- c(to, 200 + i)
          arrows <- c(arrows, "to")
          colors <- c(colors, "#3498DB")
          widths <- c(widths, 2)
          dashes <- c(dashes, TRUE)
        }
      } else {
        # No barrier - direct connection
        from <- c(from, 1)
        to <- c(to, 200 + i)
        arrows <- c(arrows, "to")
        colors <- c(colors, "#E74C3C")
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

# Function to create a default row for data editing
createDefaultRow <- function(selected_hazard = "New Hazard") {
  data.frame(
    Threat = "New Threat",
    Hazard = selected_hazard,
    Consequence = "New Consequence",
    Preventive_Barrier = "New Preventive Barrier",
    Protective_Barrier = "New Protective Barrier",
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

# Optimized data summary function
getDataSummary <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  paste(
    "Rows:", nrow(data),
    "| Hazards:", length(unique(data$Hazard)),
    "| Threats:", length(unique(data$Threat)),
    "| Consequences:", length(unique(data$Consequence)),
    "| Risk Levels:", paste(names(table(data$Risk_Level)), collapse = ", ")
  )
}