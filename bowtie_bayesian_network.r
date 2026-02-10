# bowtie_bayesian_network.R
# Convert Environmental Bowtie Diagrams to Bayesian Networks
# Version 5.4.1 - Advanced probabilistic risk modeling
#
# NOTE: All packages are loaded via global.R - do not add library() calls here
# Required packages: bnlearn, gRain, igraph, visNetwork, DiagrammeR, dplyr, tidyr

# Check if required packages are available
BNLEARN_AVAILABLE <- requireNamespace("bnlearn", quietly = TRUE)
GRAIN_AVAILABLE <- requireNamespace("gRain", quietly = TRUE)
GRBASE_AVAILABLE <- requireNamespace("gRbase", quietly = TRUE)

if (!BNLEARN_AVAILABLE) {
  warning("bnlearn package not available - Bayesian network functionality will be limited")
}
if (!GRAIN_AVAILABLE) {
  warning("gRain package not available - Bayesian inference functionality will be limited")
}
if (!GRBASE_AVAILABLE) {
  warning("gRbase package not available - Bayesian inference compilation will be limited")
}

# Function to convert bowtie data to Bayesian network structure
create_bayesian_structure <- function(bowtie_data, central_problem = NULL) {
  bowtie_log("Converting bowtie to Bayesian network structure...", level = "info")
  
  # Filter data for specific central problem if provided
  if (!is.null(central_problem)) {
    bowtie_data <- bowtie_data %>% filter(Central_Problem == central_problem)
  }
  
  # Create nodes list with proper naming
  nodes <- list()
  
  # Normalize Protective column name
  if ("Protective_Mitigation" %in% names(bowtie_data)) {
    protective_col <- bowtie_data$Protective_Mitigation
  } else if ("Protective_Control" %in% names(bowtie_data)) {
    protective_col <- bowtie_data$Protective_Control
  } else {
    protective_col <- rep("Unknown_Protection", nrow(bowtie_data))
  }

  # Extract unique elements as nodes
  all_nodes <- unique(c(
    paste0("ACT_", gsub("[^A-Za-z0-9]", "_", bowtie_data$Activity)),
    paste0("PRES_", gsub("[^A-Za-z0-9]", "_", bowtie_data$Pressure)),
    paste0("CTRL_", gsub("[^A-Za-z0-9]", "_", bowtie_data$Preventive_Control)),
    paste0("ESC_", gsub("[^A-Za-z0-9]", "_", bowtie_data$Escalation_Factor)),
    paste0("PROB_", gsub("[^A-Za-z0-9]", "_", bowtie_data$Central_Problem)),
    paste0("MIT_", gsub("[^A-Za-z0-9]", "_", protective_col)),
    paste0("CONS_", gsub("[^A-Za-z0-9]", "_", bowtie_data$Consequence))
  ))
  
  # Create node metadata
  node_metadata <- data.frame(
    node_id = all_nodes,
    node_type = dplyr::case_when(
      grepl("^ACT_", all_nodes) ~ "Activity",
      grepl("^PRES_", all_nodes) ~ "Pressure",
      grepl("^CTRL_", all_nodes) ~ "Control",
      grepl("^ESC_", all_nodes) ~ "Escalation",
      grepl("^PROB_", all_nodes) ~ "Problem",
      grepl("^MIT_", all_nodes) ~ "Mitigation",
      grepl("^CONS_", all_nodes) ~ "Consequence"
    ),
    original_name = gsub("^[A-Z]+_", "", all_nodes) %>% gsub("_", " ", .),
    stringsAsFactors = FALSE
  )
  
  # Create edges using vectorized operations (optimized - avoids O(n²) rbind loop)
  # Pre-compute all node IDs at once using vectorized gsub
  clean_text <- function(x) gsub("[^A-Za-z0-9]", "_", x)

  act_nodes <- paste0("ACT_", clean_text(bowtie_data$Activity))
  pres_nodes <- paste0("PRES_", clean_text(bowtie_data$Pressure))
  ctrl_nodes <- paste0("CTRL_", clean_text(bowtie_data$Preventive_Control))
  esc_nodes <- paste0("ESC_", clean_text(bowtie_data$Escalation_Factor))
  prob_nodes <- paste0("PROB_", clean_text(bowtie_data$Central_Problem))
  mit_nodes <- paste0("MIT_", clean_text(protective_col))
  cons_nodes <- paste0("CONS_", clean_text(bowtie_data$Consequence))

  # Create all edges at once using vectorized data.frame construction
  edges <- data.frame(
    from = c(act_nodes, pres_nodes, ctrl_nodes, esc_nodes, prob_nodes, mit_nodes),
    to = c(pres_nodes, ctrl_nodes, esc_nodes, prob_nodes, mit_nodes, cons_nodes),
    type = rep(c("causes", "requires_control", "can_fail",
                 "escalates_to", "requires_mitigation", "affects_outcome"),
               each = nrow(bowtie_data)),
    stringsAsFactors = FALSE
  )
  
  # Remove duplicate edges
  edges <- edges %>% distinct()
  
  # Create BN structure
  bn_structure <- list(
    nodes = node_metadata,
    edges = edges,
    data = bowtie_data
  )
  
  bowtie_log(paste("Created Bayesian network with", nrow(node_metadata), "nodes and", nrow(edges), "edges"), level = "success")
  
  return(bn_structure)
}

# Function to discretize continuous variables
# Supports both 0-1 scale (probabilities) and 1-5 scale (typical risk ratings)
discretize_risk_levels <- function(value, levels = c("Low", "Medium", "High")) {
  # Validate inputs
  if (is.null(value)) return(NA)
  if (length(value) == 0) return(NA)
  if (is.na(value)) return(NA)

  # Ensure value is numeric
  if (!is.numeric(value)) {
    tryCatch({
      value <- as.numeric(value)
    }, error = function(e) {
      return(NA)
    })
    if (is.na(value)) return(NA)
  }

  # Handle negative values - treat as lowest level
  if (value < 0) {
    warning("discretize_risk_levels: Negative value ", value, " treated as lowest level")
    return(levels[1])
  }

  # Validate levels parameter
  if (length(levels) < 3) {
    warning("discretize_risk_levels: levels should have at least 3 elements, using defaults")
    levels <- c("Low", "Medium", "High")
  }

  # Auto-detect scale based on value range
  # Values strictly less than 1 are treated as 0-1 probability scale
  # Values >= 1 are treated as 1-5 risk rating scale
  if (value < 1) {
    # 0-1 probability scale (0.0 to 0.99...)
    if (value <= 0.33) return(levels[1])
    else if (value <= 0.66) return(levels[2])
    else return(levels[3])
  } else {
    # 1-5 risk rating scale (1, 2, 3, 4, 5)
    if (value <= 2) return(levels[1])
    else if (value <= 3.5) return(levels[2])
    else return(levels[3])
  }
}

# Function to create conditional probability tables (CPTs)
create_cpts <- function(bn_structure, use_data = TRUE) {
  bowtie_log("Creating conditional probability tables...", level = "info")
  
  nodes <- bn_structure$nodes
  edges <- bn_structure$edges
  data <- bn_structure$data
  
  cpts <- list()
  
  # For each node, create CPT based on parents
  for (i in 1:nrow(nodes)) {
    node <- nodes$node_id[i]
    node_type <- nodes$node_type[i]
    
    # Find parents of this node
    parents <- edges$from[edges$to == node]
    
    if (length(parents) == 0) {
      # Root node - use marginal probabilities
      if (use_data && nrow(data) > 0) {
        # Extract probabilities from data
        if (node_type == "Activity") {
          # Activities are always "present" in the data
          cpts[[node]] <- c(Present = 0.8, Absent = 0.2)
        } else {
          # Use likelihood data if available
          cpts[[node]] <- c(Low = 0.3, Medium = 0.4, High = 0.3)
        }
      } else {
        # Default uniform distribution
        cpts[[node]] <- c(Low = 0.33, Medium = 0.34, High = 0.33)
      }
    } else {
      # Node with parents - create conditional probability table
      
      # Simplified CPT based on node type
      if (node_type == "Pressure") {
        # Pressure depends on Activity
        cpts[[node]] <- matrix(
          c(0.1, 0.3, 0.6,  # Activity Present: Low, Med, High pressure
            0.7, 0.2, 0.1), # Activity Absent: Low, Med, High pressure
          nrow = 3, ncol = 2,
          dimnames = list(
            Pressure = c("Low", "Medium", "High"),
            Activity = c("Present", "Absent")
          )
        )
      } else if (node_type == "Control") {
        # Control effectiveness depends on Pressure
        cpts[[node]] <- matrix(
          c(0.8, 0.15, 0.05,  # Low pressure: Effective, Partial, Failed
            0.6, 0.30, 0.10,  # Medium pressure
            0.3, 0.40, 0.30), # High pressure
          nrow = 3, ncol = 3,
          dimnames = list(
            Control = c("Effective", "Partial", "Failed"),
            Pressure = c("Low", "Medium", "High")
          )
        )
      } else if (node_type == "Escalation") {
        # Escalation depends on Control effectiveness
        cpts[[node]] <- matrix(
          c(0.1, 0.2, 0.7,  # Control Effective: Low, Med, High escalation
            0.3, 0.5, 0.2,  # Control Partial
            0.6, 0.3, 0.1), # Control Failed
          nrow = 3, ncol = 3,
          dimnames = list(
            Escalation = c("Low", "Medium", "High"),
            Control = c("Effective", "Partial", "Failed")
          )
        )
      } else if (node_type == "Consequence") {
        # Consequence depends on Mitigation
        cpts[[node]] <- matrix(
          c(0.7, 0.25, 0.05,  # Mitigation Effective
            0.4, 0.40, 0.20,  # Mitigation Partial
            0.1, 0.30, 0.60), # Mitigation Failed
          nrow = 3, ncol = 3,
          dimnames = list(
            Consequence = c("Low", "Medium", "High"),
            Mitigation = c("Effective", "Partial", "Failed")
          )
        )
      } else {
        # Default CPT
        cpts[[node]] <- c(Low = 0.33, Medium = 0.34, High = 0.33)
      }
    }
  }
  
  return(cpts)
}

# Function to learn CPTs from data using Maximum Likelihood
learn_cpts_from_data <- function(bn_structure) {
  bowtie_log("Learning CPTs from data using Maximum Likelihood...", level = "info")
  
  data <- bn_structure$data
  
  if (nrow(data) == 0) {
    bowtie_log("No data available for learning. Using default CPTs.", level = "warning")
    return(create_cpts(bn_structure, use_data = FALSE))
  }
  
  # Prepare data for bnlearn
  # Convert to discrete variables
  bn_data <- data.frame(
    Activity = factor(ifelse(data$Activity != "", "Present", "Absent")),
    Pressure_Level = factor(sapply(data$Likelihood, discretize_risk_levels)),
    Control_Effect = factor(sample(c("Effective", "Partial", "Failed"), 
                                  nrow(data), replace = TRUE, 
                                  prob = c(0.5, 0.3, 0.2))),
    Escalation_Level = factor(sapply(data$Severity, discretize_risk_levels)),
    Problem_Severity = factor(sapply(data$Severity, discretize_risk_levels)),
    Mitigation_Effect = factor(sample(c("Effective", "Partial", "Failed"), 
                                     nrow(data), replace = TRUE, 
                                     prob = c(0.4, 0.4, 0.2))),
    Consequence_Level = factor(data$Risk_Level)
  )
  
  # Define network structure for bnlearn
  arc_set <- matrix(c(
    "Activity", "Pressure_Level",
    "Pressure_Level", "Control_Effect",
    "Control_Effect", "Escalation_Level",
    "Escalation_Level", "Problem_Severity",
    "Problem_Severity", "Mitigation_Effect",
    "Mitigation_Effect", "Consequence_Level"
  ), ncol = 2, byrow = TRUE)
  
  # Create empty graph and add arcs
  if (!BNLEARN_AVAILABLE) {
    stop("bnlearn package is required for learning CPTs from data")
  }
  dag <- bnlearn::empty.graph(names(bn_data))
  bnlearn::arcs(dag) <- arc_set

  # Fit the network
  fitted_bn <- bnlearn::bn.fit(dag, bn_data, method = "mle")
  
  return(fitted_bn)
}

# Function to create bnlearn network
create_bnlearn_network <- function(bn_structure) {
  bowtie_log("Creating bnlearn network object...", level = "info")

  if (!BNLEARN_AVAILABLE) {
    stop("bnlearn package is required for creating Bayesian networks")
  }

  edges <- bn_structure$edges
  nodes <- unique(c(edges$from, edges$to))

  # Create arc matrix for bnlearn
  arc_matrix <- as.matrix(edges[, c("from", "to")])

  # Create empty graph
  dag <- bnlearn::empty.graph(nodes)

  # Add arcs with error tracking
  failed_arcs <- character(0)
  tryCatch({
    bnlearn::arcs(dag) <- arc_matrix
    bowtie_log(paste("All", nrow(arc_matrix), "arcs added successfully"), level = "success")
  }, error = function(e) {
    bowtie_log("Some arcs created cycles. Creating approximate DAG.", level = "warning")
    # Remove cycles by keeping only forward edges
    dag <<- bnlearn::empty.graph(nodes)
    # Add arcs one by one, skipping those that create cycles
    for (i in 1:nrow(arc_matrix)) {
      tryCatch({
        bnlearn::arcs(dag) <- rbind(bnlearn::arcs(dag), arc_matrix[i, ])
      }, error = function(e2) {
        # Track failed arc
        failed_arcs <<- c(failed_arcs, paste(arc_matrix[i, 1], "->", arc_matrix[i, 2]))
      })
    }
    if (length(failed_arcs) > 0) {
      bowtie_log(paste("Skipped", length(failed_arcs), "arcs that would create cycles"), level = "warning")
      for (arc in head(failed_arcs, 5)) {
        bowtie_log(paste("  -", arc), level = "debug")
      }
      if (length(failed_arcs) > 5) {
        bowtie_log(paste("  ... and", length(failed_arcs) - 5, "more"), level = "debug")
      }
    }
  })

  return(dag)
}

# Function to perform Bayesian inference
perform_inference <- function(fitted_bn, evidence = list(), query_nodes = NULL) {
  bowtie_log("Performing Bayesian inference...", level = "info")

  if (!GRAIN_AVAILABLE) {
    warning("gRain package not available - returning empty results")
    return(list())
  }

  if (!GRBASE_AVAILABLE) {
    warning("gRbase package not available - returning empty results")
    return(list())
  }

  if (!BNLEARN_AVAILABLE) {
    warning("bnlearn package not available - returning empty results")
    return(list())
  }

  # Validate input - must be a bn.fit object (fitted network with CPTs)
  # Note: as.grain() only works with bn.fit, not bn (raw DAG structure)
  if (is.null(fitted_bn)) {
    warning("fitted_bn is NULL - returning empty results")
    return(list())
  }

  if (inherits(fitted_bn, "bn") && !inherits(fitted_bn, "bn.fit")) {
    warning("Cannot perform inference on raw DAG (bn object). Need fitted network (bn.fit) with CPTs.")
    return(list())
  }

  if (!inherits(fitted_bn, "bn.fit")) {
    warning("Invalid fitted_bn object - must be bn.fit class, got: ", class(fitted_bn)[1])
    return(list())
  }

  # Convert to grain object for inference
  tryCatch({
    grain_obj <- bnlearn::as.grain(fitted_bn)
    junction <- gRbase::compile(grain_obj)

    # Set evidence if provided
    if (length(evidence) > 0) {
      junction <- gRain::setEvidence(junction, evidence = evidence)
    }

    # Query specific nodes or all nodes
    if (is.null(query_nodes)) {
      query_nodes <- names(fitted_bn)
    }

    # Get probabilities
    results <- list()
    for (node in query_nodes) {
      tryCatch({
        results[[node]] <- gRain::querygrain(junction, nodes = node)[[node]]
      }, error = function(e) {
        # Skip nodes that can't be queried
      })
    }

    return(results)
  }, error = function(e) {
    warning("Bayesian inference failed: ", e$message)
    return(list())
  })
}

# Function to visualize Bayesian network with visNetwork
visualize_bayesian_network <- function(bn_structure, highlight_path = NULL) {
  bowtie_log("Creating Bayesian network visualization...", level = "info")
  
  nodes_df <- bn_structure$nodes
  edges_df <- bn_structure$edges
  
  # Prepare nodes for visNetwork - using same shapes as bowtie diagram
  vis_nodes <- data.frame(
    id = nodes_df$node_id,
    label = nodes_df$original_name,
    group = nodes_df$node_type,
    title = paste(nodes_df$node_type, ":", nodes_df$original_name),
    shape = dplyr::case_when(
      nodes_df$node_type == "Activity" ~ "square",
      nodes_df$node_type == "Pressure" ~ "triangle",
      nodes_df$node_type == "Control" ~ "square",
      nodes_df$node_type == "Escalation" ~ "triangleDown",
      nodes_df$node_type == "Problem" ~ "diamond",
      nodes_df$node_type == "Mitigation" ~ "square",
      nodes_df$node_type == "Consequence" ~ "hexagon",
      TRUE ~ "dot"
    ),
    color = dplyr::case_when(
      nodes_df$node_type == "Activity" ~ "#8E44AD",
      nodes_df$node_type == "Pressure" ~ "#E74C3C",
      nodes_df$node_type == "Control" ~ "#27AE60",
      nodes_df$node_type == "Escalation" ~ "#F39C12",
      nodes_df$node_type == "Problem" ~ "#2C3E50",
      nodes_df$node_type == "Mitigation" ~ "#3498DB",
      nodes_df$node_type == "Consequence" ~ "#E67E22",
      TRUE ~ "#95A5A6"
    ),
    size = ifelse(nodes_df$node_type == "Problem", 35, 25)
  )
  
  # Prepare edges
  vis_edges <- data.frame(
    from = edges_df$from,
    to = edges_df$to,
    arrows = "to",
    title = edges_df$type,
    width = 2,
    color = list(opacity = 0.7),
    smooth = list(enabled = TRUE, type = "dynamic", roundness = 0.2)
  )
  
  # Highlight path if specified
  if (!is.null(highlight_path)) {
    vis_edges$width <- ifelse(
      paste(vis_edges$from, vis_edges$to) %in% paste(highlight_path$from, highlight_path$to),
      4, 2
    )
    vis_edges$color <- ifelse(
      paste(vis_edges$from, vis_edges$to) %in% paste(highlight_path$from, highlight_path$to),
      "red", list(opacity = 0.7)
    )
  }
  
  # Create visualization
  visNetwork::visNetwork(vis_nodes, vis_edges,
             main = "Environmental Bowtie as Bayesian Network",
             submain = "Probabilistic Risk Model") %>%
    visNetwork::visOptions(
      highlightNearest = list(enabled = TRUE, degree = 2),
      nodesIdSelection = TRUE
    ) %>%
    visNetwork::visPhysics(
      stabilization = list(iterations = 100),
      barnesHut = list(gravitationalConstant = -8000, springConstant = 0.04)
    ) %>%
    visNetwork::visLayout(randomSeed = 123) %>%
    visNetwork::visInteraction(
      navigationButtons = TRUE,
      dragNodes = TRUE,
      zoomView = TRUE
    ) %>%
    visNetwork::visLegend(
      useGroups = FALSE,
      addNodes = list(
        list(label = "Activity", shape = "square", color = "#8E44AD", size = 20),
        list(label = "Pressure", shape = "triangle", color = "#E74C3C", size = 20),
        list(label = "Preventive Control", shape = "square", color = "#27AE60", size = 20),
        list(label = "Escalation Factor", shape = "triangleDown", color = "#F39C12", size = 20),
        list(label = "Central Problem", shape = "diamond", color = "#2C3E50", size = 25),
        list(label = "Protective Control", shape = "square", color = "#3498DB", size = 20),
        list(label = "Consequence", shape = "hexagon", color = "#E67E22", size = 20)
      ),
      position = "left",
      width = 0.15,
      ncol = 1
    )
}

# Function to calculate risk propagation
calculate_risk_propagation <- function(fitted_bn, scenario = list()) {
  bowtie_log("Calculating risk propagation through network...", level = "info")
  
  # Baseline probabilities (no evidence)
  baseline <- perform_inference(fitted_bn)
  
  # Scenario probabilities (with evidence)
  scenario_probs <- perform_inference(fitted_bn, evidence = scenario)
  
  # Calculate changes
  risk_changes <- list()
  for (node in names(baseline)) {
    if (node %in% names(scenario_probs)) {
      baseline_risk <- baseline[[node]]
      scenario_risk <- scenario_probs[[node]]
      
      # Calculate risk change
      if ("High" %in% names(baseline_risk)) {
        risk_changes[[node]] <- list(
          baseline_high = baseline_risk["High"],
          scenario_high = scenario_risk["High"],
          change = scenario_risk["High"] - baseline_risk["High"]
        )
      }
    }
  }
  
  return(risk_changes)
}

# Function to find critical paths using sensitivity analysis
find_critical_paths <- function(fitted_bn, target_node = "Consequence_Level") {
  bowtie_log(paste("Finding critical paths to", target_node, "..."), level = "info")

  if (!BNLEARN_AVAILABLE) {
    warning("bnlearn package not available - cannot find critical paths")
    return(list())
  }

  # Validate input
 if (is.null(fitted_bn)) {
    warning("fitted_bn is NULL - cannot find critical paths")
    return(list())
  }

  if (!inherits(fitted_bn, c("bn.fit", "bn"))) {
    warning("fitted_bn must be a bn.fit or bn object - cannot find critical paths")
    return(list())
  }

  # Get all nodes
  all_nodes <- tryCatch({
    names(fitted_bn)
  }, error = function(e) {
    warning("Could not extract nodes from fitted_bn: ", e$message)
    return(character(0))
  })

  if (length(all_nodes) == 0) {
    warning("No nodes found in network - cannot find critical paths")
    return(list())
  }

  all_nodes <- all_nodes
  root_nodes <- all_nodes[sapply(all_nodes, function(n) length(bnlearn::parents(fitted_bn, n)) == 0)]

  critical_paths <- list()

  # Test each root node
  for (root in root_nodes) {
    tryCatch({
      # Set root to high state
      evidence <- setNames(list("High"), root)

      # Calculate impact on target
      inference_result <- perform_inference(fitted_bn, evidence = evidence, query_nodes = target_node)

      if (target_node %in% names(inference_result)) {
        impact <- inference_result[[target_node]]["High"]

        critical_paths[[root]] <- list(
          root = root,
          target = target_node,
          impact_on_high_risk = impact,
          path = paste(root, "→ ... →", target_node)
        )
      }
    }, error = function(e) {
      # Skip nodes that cause errors
    })
  }

  # Sort by impact
  if (length(critical_paths) > 0) {
    critical_paths <- critical_paths[order(sapply(critical_paths, function(x) {
      if (is.null(x$impact_on_high_risk) || is.na(x$impact_on_high_risk)) 0
      else x$impact_on_high_risk
    }), decreasing = TRUE)]
  }

  return(critical_paths)
}

# Main function to convert bowtie to Bayesian network
bowtie_to_bayesian <- function(bowtie_data, central_problem = NULL,
                              learn_from_data = TRUE, visualize = TRUE) {

  bowtie_log("Converting Bowtie to Bayesian Network...", level = "info")

  # Use a local environment to avoid locked binding issues with <<-
  # This allows safe modification within tryCatch blocks
  state <- new.env(parent = emptyenv())
  state$dag <- NULL
  state$fitted_bn <- NULL
  state$cpts <- NULL

  # Step 1: Create structure
  bn_structure <- create_bayesian_structure(bowtie_data, central_problem)

  # Step 2: Create or learn CPTs
  tryCatch({
    if (learn_from_data && nrow(bowtie_data) > 10) {
      state$fitted_bn <- learn_cpts_from_data(bn_structure)
    } else {
      # Create bnlearn DAG
      state$dag <- create_bnlearn_network(bn_structure)

      # Create CPTs
      state$cpts <- create_cpts(bn_structure)

      # Try to create fitted network from DAG and CPTs
      if (!is.null(state$dag) && BNLEARN_AVAILABLE) {
        tryCatch({
          # First try custom.fit with our CPTs
          if (!is.null(state$cpts)) {
            state$fitted_bn <- bnlearn::custom.fit(state$dag, state$cpts)
            bowtie_log("Created fitted Bayesian network with custom CPTs", level = "success")
          }
        }, error = function(e) {
          bowtie_log(paste("Could not attach custom CPTs:", e$message), level = "warning")
          # Fallback: Create fitted network with simulated uniform data
          tryCatch({
            bowtie_log("Creating fitted network with uniform distributions...", level = "info")
            # Generate simulated data with uniform distributions for all nodes
            node_names <- bnlearn::nodes(state$dag)
            n_samples <- 100
            sim_data <- as.data.frame(lapply(node_names, function(n) {
              factor(sample(c("Low", "Medium", "High"), n_samples, replace = TRUE))
            }))
            names(sim_data) <- node_names
            # Fit the network with the simulated data
            state$fitted_bn <- bnlearn::bn.fit(state$dag, sim_data, method = "bayes")
            bowtie_log("Created fitted Bayesian network with uniform distributions", level = "success")
          }, error = function(e2) {
            bowtie_log(paste("Fallback fitting also failed:", e2$message), level = "warning")
            bowtie_log("Inference will not be available for this network.", level = "warning")
          })
        })
      } else {
        bowtie_log("Cannot create fitted network - DAG or bnlearn not available.", level = "warning")
      }
    }
  }, error = function(e) {
    bowtie_log(paste("CPT learning error:", e$message), level = "warning")
    # Fallback: Create DAG and fit with uniform distributions
    tryCatch({
      state$dag <- create_bnlearn_network(bn_structure)
      if (!is.null(state$dag) && BNLEARN_AVAILABLE) {
        bowtie_log("Creating fallback fitted network with uniform distributions...", level = "info")
        node_names <- bnlearn::nodes(state$dag)
        n_samples <- 100
        sim_data <- as.data.frame(lapply(node_names, function(n) {
          factor(sample(c("Low", "Medium", "High"), n_samples, replace = TRUE))
        }))
        names(sim_data) <- node_names
        state$fitted_bn <- bnlearn::bn.fit(state$dag, sim_data, method = "bayes")
        bowtie_log("Created fallback fitted network", level = "success")
      }
    }, error = function(e2) {
      bowtie_log(paste("Fallback also failed:", e2$message), level = "warning")
    })
  })

  # Step 3: Visualize if requested
  if (visualize) {
    vis_plot <- tryCatch({
      visualize_bayesian_network(bn_structure)
    }, error = function(e) {
      bowtie_log(paste("Bayesian network visualization error:", e$message), level = "error")
      NULL
    })
  } else {
    vis_plot <- NULL
  }

  # Determine which network to use (prefer fitted_bn over dag)
  network_to_use <- if (!is.null(state$fitted_bn)) state$fitted_bn else state$dag

  # Copy state variables for use in closure
  fitted_bn_final <- state$fitted_bn

  # Return results
  result <- list(
    structure = bn_structure,
    network = network_to_use,
    visualization = vis_plot,
    inference_function = function(evidence, query) {
      if (!is.null(fitted_bn_final)) {
        perform_inference(fitted_bn_final, evidence, query)
      } else {
        bowtie_log("Inference not available without fitted network.", level = "warning")
        NULL
      }
    }
  )
  
  bowtie_log("Bayesian network creation complete!", level = "success")

  return(result)
}

# Example usage function
example_bayesian_analysis <- function(bowtie_data) {
  bowtie_log("EXAMPLE BAYESIAN NETWORK ANALYSIS", level = "info")
  bowtie_log("=====================================", level = "info")

  # Convert to Bayesian network
  bn_result <- bowtie_to_bayesian(bowtie_data, learn_from_data = FALSE)

  # Example 1: Basic inference
  bowtie_log("1. BASIC INFERENCE", level = "info")
  bowtie_log("What's the risk if we have high pressure?", level = "info")
  evidence <- list(Pressure_Level = "High")
  results <- bn_result$inference_function(evidence, c("Consequence_Level", "Problem_Severity"))
  print(results)

  # Example 2: Intervention analysis
  bowtie_log("2. INTERVENTION ANALYSIS", level = "info")
  bowtie_log("What if we improve control effectiveness?", level = "info")
  evidence <- list(Control_Effect = "Effective", Pressure_Level = "High")
  results <- bn_result$inference_function(evidence, "Consequence_Level")
  print(results)

  # Example 3: Risk propagation
  bowtie_log("3. RISK PROPAGATION", level = "info")
  if (exists("fitted_bn")) {
    scenario <- list(Activity = "Present", Control_Effect = "Failed")
    risk_changes <- calculate_risk_propagation(fitted_bn, scenario)

    bowtie_log("Risk changes with failed controls:", level = "info")
    for (node in names(risk_changes)) {
      change <- risk_changes[[node]]
      if (abs(change$change) > 0.1) {
        bowtie_log(sprintf("  %s: %.1f%% -> %.1f%% (change: %+.1f%%)",
                   node,
                   change$baseline_high * 100,
                   change$scenario_high * 100,
                   change$change * 100), level = "info")
      }
    }
  }
  
  # Return visualization
  return(bn_result$visualization)
}

# Export message - using cat() here is acceptable as this runs at source() time
# before full application context is available
if (interactive()) {
  cat("Bowtie to Bayesian Network converter loaded!\n")
  cat("Main functions:\n")
  cat("  - bowtie_to_bayesian(): Convert bowtie data to Bayesian network\n")
  cat("  - perform_inference(): Run probabilistic queries\n")
  cat("  - calculate_risk_propagation(): Analyze risk scenarios\n")
  cat("  - find_critical_paths(): Identify high-impact pathways\n")
  cat("  - visualize_bayesian_network(): Create interactive visualization\n")
}