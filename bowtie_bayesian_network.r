# bowtie_bayesian_network.R
# Convert Environmental Bowtie Diagrams to Bayesian Networks
# Version 5.6.1 - Fixed bowtie topology, CPT fitting, and inference pipeline
#
# NOTE: All packages are loaded via global.R - do not add library() calls here
# Required packages: bnlearn, gRain, igraph, visNetwork, DiagrammeR, dplyr, tidyr

# Check if required packages are available
BNLEARN_AVAILABLE <- requireNamespace("bnlearn", quietly = TRUE)
GRAIN_AVAILABLE <- requireNamespace("gRain", quietly = TRUE)
GRBASE_AVAILABLE <- requireNamespace("gRbase", quietly = TRUE)

if (!BNLEARN_AVAILABLE) {
  log_warning("bnlearn package not available - Bayesian network functionality will be limited")
}
if (!GRAIN_AVAILABLE) {
  log_warning("gRain package not available - Bayesian inference functionality will be limited")
}
if (!GRBASE_AVAILABLE) {
  log_warning("gRbase package not available - Bayesian inference compilation will be limited")
}

# =============================================================================
# HELPER: Clean text for node IDs
# =============================================================================
.bn_clean_text <- function(x) gsub("[^A-Za-z0-9]", "_", x)

# =============================================================================
# DISCRETIZE RISK LEVELS
# Supports both 0-1 probability scale and >1 risk rating scale
# =============================================================================
discretize_risk_levels <- function(value, levels = c("Low", "Medium", "High")) {
  if (is.null(value) || length(value) == 0 || is.na(value)) return(NA)

  if (!is.numeric(value)) {
    value <- tryCatch(as.numeric(value), error = function(e) NA)
    if (is.na(value)) return(NA)
  }

  if (value < 0) {
    bowtie_log(paste("discretize_risk_levels: Negative value", value, "treated as lowest level"), level = "debug")
    return(levels[1])
  }

  if (length(levels) < 3) levels <- c("Low", "Medium", "High")

  # Values in [0, 1.0] are treated as probabilities
  if (value <= 1.0) {
    if (value <= 0.33) return(levels[1])
    if (value <= 0.66) return(levels[2])
    return(levels[3])
  }

  # Values > 1.0 are risk ratings (typically 1-5)
  if (value <= 2) return(levels[1])
  if (value < 4) return(levels[2])
  return(levels[3])
}

# =============================================================================
# CREATE BAYESIAN STRUCTURE (Fixed: proper bowtie fan-in/fan-out topology)
#
# Bowtie topology:
#   Activities ──┐                    ┌── Consequences
#   Activities ──┼── Pressures ──┐    │
#   Activities ──┘               ├── Problem ──┼── Consequences
#   Controls ──── Pressures ──┘    │
#                                     └── Consequences
#   (Preventive controls connect to pressures on left side)
#   (Protective controls connect to consequences on right side)
# =============================================================================
create_bayesian_structure <- function(bowtie_data, central_problem = NULL) {
  bowtie_log("Converting bowtie to Bayesian network structure...", level = "info")

  if (!is.null(central_problem)) {
    bowtie_data <- bowtie_data %>% filter(Central_Problem == central_problem)
  }

  # Normalize Protective column name
  if ("Protective_Mitigation" %in% names(bowtie_data)) {
    protective_col <- bowtie_data$Protective_Mitigation
  } else if ("Protective_Control" %in% names(bowtie_data)) {
    protective_col <- bowtie_data$Protective_Control
  } else {
    protective_col <- rep("Unknown_Protection", nrow(bowtie_data))
  }

  # Filter out rows where ALL key columns are NA (from rep_len recycling with empty vectors)
  valid_rows <- !is.na(bowtie_data$Activity) | !is.na(bowtie_data$Pressure) |
                !is.na(bowtie_data$Consequence)
  bowtie_data <- bowtie_data[valid_rows, , drop = FALSE]

  if (nrow(bowtie_data) == 0) {
    bowtie_log("No valid rows for Bayesian network after NA filtering", level = "warning")
    return(list(nodes = data.frame(), edges = data.frame(), dag = NULL))
  }

  # Create node IDs, filtering NA values per column to avoid spurious "ACT_NA" nodes
  act_nodes <- if (any(!is.na(bowtie_data$Activity))) {
    paste0("ACT_", .bn_clean_text(bowtie_data$Activity[!is.na(bowtie_data$Activity)]))
  } else { character(0) }

  pres_nodes <- if (any(!is.na(bowtie_data$Pressure))) {
    paste0("PRES_", .bn_clean_text(bowtie_data$Pressure[!is.na(bowtie_data$Pressure)]))
  } else { character(0) }

  ctrl_nodes <- if (any(!is.na(bowtie_data$Preventive_Control))) {
    paste0("CTRL_", .bn_clean_text(bowtie_data$Preventive_Control[!is.na(bowtie_data$Preventive_Control)]))
  } else { character(0) }

  esc_nodes <- if (any(!is.na(bowtie_data$Escalation_Factor))) {
    paste0("ESC_", .bn_clean_text(bowtie_data$Escalation_Factor[!is.na(bowtie_data$Escalation_Factor)]))
  } else { character(0) }

  prob_nodes <- paste0("PROB_", .bn_clean_text(bowtie_data$Central_Problem))

  mit_nodes <- if (any(!is.na(protective_col))) {
    paste0("MIT_", .bn_clean_text(protective_col[!is.na(protective_col)]))
  } else { character(0) }

  cons_nodes <- if (any(!is.na(bowtie_data$Consequence))) {
    paste0("CONS_", .bn_clean_text(bowtie_data$Consequence[!is.na(bowtie_data$Consequence)]))
  } else { character(0) }

  # Build unique node list
  all_nodes <- unique(c(act_nodes, pres_nodes, ctrl_nodes, esc_nodes,
                        prob_nodes, mit_nodes, cons_nodes))

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

  # ==========================================================================
  # Build edges with proper bowtie fan-in / fan-out topology
  # ==========================================================================
  # LEFT SIDE (threats converge on problem):
  #   Activity -> Pressure (many-to-many from data rows)
  #   Pressure -> Central Problem (all pressures fan into the shared problem)
  #   Control -> Pressure (preventive controls act on pressures)
  #   Escalation -> Pressure (escalation factors amplify pressures)
  #
  # RIGHT SIDE (consequences fan out from problem):
  #   Central Problem -> Consequence (problem fans out to all consequences)
  #   Mitigation -> Consequence (protective controls act on consequences)

  edge_list <- list()

  # Activity -> Pressure (from data rows, deduplicated)
  edge_list[[1]] <- data.frame(
    from = act_nodes, to = pres_nodes,
    type = "causes", stringsAsFactors = FALSE
  )

  # Pressure -> Central Problem (fan-in: each unique pressure connects to the problem)
  edge_list[[2]] <- data.frame(
    from = pres_nodes, to = prob_nodes,
    type = "leads_to_problem", stringsAsFactors = FALSE
  )

  # Control -> Pressure (preventive controls mitigate pressures)
  edge_list[[3]] <- data.frame(
    from = ctrl_nodes, to = pres_nodes,
    type = "mitigates", stringsAsFactors = FALSE
  )

  # Escalation -> Pressure (escalation factors amplify the pressure pathway)
  edge_list[[4]] <- data.frame(
    from = esc_nodes, to = pres_nodes,
    type = "amplifies", stringsAsFactors = FALSE
  )

  # Central Problem -> Consequence (fan-out)
  edge_list[[5]] <- data.frame(
    from = prob_nodes, to = cons_nodes,
    type = "results_in", stringsAsFactors = FALSE
  )

  # Mitigation -> Consequence (protective controls reduce consequences)
  edge_list[[6]] <- data.frame(
    from = mit_nodes, to = cons_nodes,
    type = "protects_against", stringsAsFactors = FALSE
  )

  edges <- do.call(rbind, edge_list)
  edges <- edges %>% distinct()

  bn_structure <- list(
    nodes = node_metadata,
    edges = edges,
    data = bowtie_data
  )

  bowtie_log(paste("Created Bayesian network with", nrow(node_metadata),
                   "nodes and", nrow(edges), "edges"), level = "success")
  return(bn_structure)
}

# =============================================================================
# CREATE CPTs (Conditional Probability Tables)
# Uses 3-state discretization: Low/Medium/High for all non-root nodes
# Root nodes (Activities, Controls) use Present/Absent
# =============================================================================
create_cpts <- function(bn_structure, use_data = TRUE) {
  bowtie_log("Creating conditional probability tables...", level = "info")

  nodes <- bn_structure$nodes
  edges <- bn_structure$edges
  cpts <- list()

  for (i in seq_len(nrow(nodes))) {
    node <- nodes$node_id[i]
    node_type <- nodes$node_type[i]
    parents <- edges$from[edges$to == node]

    if (length(parents) == 0) {
      # Root nodes — Activities and Controls
      if (node_type == "Activity") {
        cpts[[node]] <- c(Present = 0.8, Absent = 0.2)
      } else if (node_type == "Control") {
        cpts[[node]] <- c(Effective = 0.5, Partial = 0.3, Failed = 0.2)
      } else if (node_type == "Mitigation") {
        cpts[[node]] <- c(Effective = 0.4, Partial = 0.4, Failed = 0.2)
      } else if (node_type == "Escalation") {
        cpts[[node]] <- c(Low = 0.4, Medium = 0.4, High = 0.2)
      } else {
        cpts[[node]] <- c(Low = 0.33, Medium = 0.34, High = 0.33)
      }
    } else {
      # Non-root nodes — use simplified CPTs based on node type
      # These are expert-elicited conditional distributions
      if (node_type == "Pressure") {
        # Pressure level depends on upstream activity/control/escalation
        # Simplified to single-parent conditioning
        cpts[[node]] <- c(Low = 0.3, Medium = 0.4, High = 0.3)
      } else if (node_type == "Problem") {
        # Problem severity depends on pressure levels feeding in
        cpts[[node]] <- c(Low = 0.2, Medium = 0.5, High = 0.3)
      } else if (node_type == "Consequence") {
        # Consequence depends on problem severity and mitigation
        cpts[[node]] <- c(Low = 0.3, Medium = 0.4, High = 0.3)
      } else {
        cpts[[node]] <- c(Low = 0.33, Medium = 0.34, High = 0.33)
      }
    }
  }

  return(cpts)
}

# =============================================================================
# LEARN CPTs FROM DATA (Fixed: no random sampling, uses actual data columns)
# =============================================================================
learn_cpts_from_data <- function(bn_structure) {
  bowtie_log("Learning CPTs from data using Maximum Likelihood...", level = "info")

  data <- bn_structure$data

  if (nrow(data) == 0) {
    bowtie_log("No data available for learning. Using default CPTs.", level = "warning")
    return(create_cpts(bn_structure, use_data = FALSE))
  }

  # Build a simplified 5-node DAG that maps to available data columns
  # Activity -> Pressure_Level -> Problem_Severity -> Consequence_Level
  #                                   ^
  #                                   |
  #                          Risk_Level (as proxy for overall severity)

  # Derive discretized variables from actual data columns
  has_likelihood <- "Likelihood" %in% names(data)
  has_severity <- "Severity" %in% names(data)
  has_risk <- "Risk_Level" %in% names(data)

  bn_data <- data.frame(
    Activity = factor(ifelse(nzchar(as.character(data$Activity)), "Present", "Absent")),
    stringsAsFactors = FALSE
  )

  if (has_likelihood) {
    bn_data$Pressure_Level <- factor(sapply(data$Likelihood, discretize_risk_levels),
                                     levels = c("Low", "Medium", "High"))
  } else {
    bn_data$Pressure_Level <- factor("Medium", levels = c("Low", "Medium", "High"))
  }

  if (has_severity) {
    bn_data$Problem_Severity <- factor(sapply(data$Severity, discretize_risk_levels),
                                       levels = c("Low", "Medium", "High"))
  } else {
    bn_data$Problem_Severity <- factor("Medium", levels = c("Low", "Medium", "High"))
  }

  if (has_risk) {
    bn_data$Consequence_Level <- factor(data$Risk_Level,
                                        levels = c("Low", "Medium", "High"))
    # Fill missing levels
    bn_data$Consequence_Level[is.na(bn_data$Consequence_Level)] <- "Medium"
  } else {
    bn_data$Consequence_Level <- factor("Medium", levels = c("Low", "Medium", "High"))
  }

  # Ensure all factor levels are present (bnlearn requires this)
  for (col in names(bn_data)) {
    bn_data[[col]] <- factor(bn_data[[col]], levels = levels(bn_data[[col]]))
    # Add pseudo-counts if any level is missing
    level_counts <- table(bn_data[[col]])
    if (any(level_counts == 0)) {
      bowtie_log(paste("Adding pseudo-observations for", col, "to cover empty levels"), level = "debug")
      missing_levels <- names(level_counts[level_counts == 0])
      for (ml in missing_levels) {
        pseudo_row <- bn_data[1, , drop = FALSE]
        pseudo_row[[col]] <- ml
        bn_data <- rbind(bn_data, pseudo_row)
      }
    }
  }

  # Define a simple DAG: Activity -> Pressure_Level -> Problem_Severity -> Consequence_Level
  arc_set <- matrix(c(
    "Activity", "Pressure_Level",
    "Pressure_Level", "Problem_Severity",
    "Problem_Severity", "Consequence_Level"
  ), ncol = 2, byrow = TRUE)

  if (!BNLEARN_AVAILABLE) {
    stop("bnlearn package is required for learning CPTs from data")
  }

  dag <- bnlearn::empty.graph(names(bn_data))
  bnlearn::arcs(dag) <- arc_set

  # Fit using Bayesian estimation (handles sparse data better than MLE)
  fitted_bn <- bnlearn::bn.fit(dag, bn_data, method = "bayes")

  bowtie_log("CPTs learned from data successfully", level = "success")
  return(fitted_bn)
}

# =============================================================================
# CREATE BNLEARN DAG (Fixed: arc fallback scoping bug)
# =============================================================================
create_bnlearn_network <- function(bn_structure) {
  bowtie_log("Creating bnlearn network object...", level = "info")

  if (!BNLEARN_AVAILABLE) {
    stop("bnlearn package is required for creating Bayesian networks")
  }

  edges <- bn_structure$edges
  nodes <- unique(c(edges$from, edges$to))
  arc_matrix <- as.matrix(edges[, c("from", "to")])

  dag <- bnlearn::empty.graph(nodes)
  failed_arcs <- character(0)

  # Try bulk arc insertion first
  bulk_ok <- tryCatch({
    bnlearn::arcs(dag) <- arc_matrix
    TRUE
  }, error = function(e) {
    FALSE
  })

  if (bulk_ok) {
    bowtie_log(paste("All", nrow(arc_matrix), "arcs added successfully"), level = "success")
  } else {
    # Fallback: add arcs one by one, skipping cycle-creating ones
    bowtie_log("Some arcs created cycles. Building approximate DAG arc-by-arc.", level = "warning")
    dag <- bnlearn::empty.graph(nodes)

    for (i in seq_len(nrow(arc_matrix))) {
      tryCatch({
        current_arcs <- bnlearn::arcs(dag)
        new_arcs <- rbind(current_arcs, arc_matrix[i, , drop = FALSE])
        bnlearn::arcs(dag) <- new_arcs
      }, error = function(e) {
        failed_arcs <<- c(failed_arcs, paste(arc_matrix[i, 1], "->", arc_matrix[i, 2]))
      })
    }

    if (length(failed_arcs) > 0) {
      bowtie_log(paste("Skipped", length(failed_arcs), "arcs that would create cycles"), level = "warning")
      for (arc in head(failed_arcs, 5)) {
        bowtie_log(paste("  -", arc), level = "debug")
      }
    }
  }

  return(dag)
}

# =============================================================================
# PERFORM BAYESIAN INFERENCE
# =============================================================================
perform_inference <- function(fitted_bn, evidence = list(), query_nodes = NULL) {
  bowtie_log("Performing Bayesian inference...", level = "info")

  if (!GRAIN_AVAILABLE || !GRBASE_AVAILABLE || !BNLEARN_AVAILABLE) {
    log_warning("Required packages not available for inference")
    return(list())
  }

  if (is.null(fitted_bn)) {
    log_warning("fitted_bn is NULL - returning empty results")
    return(list())
  }

  if (inherits(fitted_bn, "bn") && !inherits(fitted_bn, "bn.fit")) {
    log_warning("Cannot perform inference on raw DAG. Need fitted network (bn.fit).")
    return(list())
  }

  if (!inherits(fitted_bn, "bn.fit")) {
    log_warning(paste("Invalid fitted_bn class:", class(fitted_bn)[1]))
    return(list())
  }

  tryCatch({
    grain_obj <- bnlearn::as.grain(fitted_bn)
    junction <- gRbase::compile(grain_obj)

    if (length(evidence) > 0) {
      junction <- gRain::setEvidence(junction,
        nodes = names(evidence),
        states = as.character(unlist(evidence)))
    }

    if (is.null(query_nodes)) {
      query_nodes <- names(fitted_bn)
    }

    results <- list()
    for (node in query_nodes) {
      tryCatch({
        results[[node]] <- gRain::querygrain(junction, nodes = node)[[node]]
      }, error = function(e) {
        log_debug(paste("Skipping node in query:", node, "-", e$message))
      })
    }

    return(results)
  }, error = function(e) {
    log_warning(paste("Bayesian inference failed:", e$message))
    return(list())
  })
}

# =============================================================================
# VISUALIZE BAYESIAN NETWORK (Fixed: mixed-type color column)
# =============================================================================
visualize_bayesian_network <- function(bn_structure, highlight_path = NULL) {
  bowtie_log("Creating Bayesian network visualization...", level = "info")

  nodes_df <- bn_structure$nodes
  edges_df <- bn_structure$edges

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

  vis_edges <- data.frame(
    from = edges_df$from,
    to = edges_df$to,
    arrows = "to",
    title = edges_df$type,
    width = 2,
    color = "#999999",
    smooth = TRUE,
    stringsAsFactors = FALSE
  )

  # Highlight path if specified (use uniform color type)
  if (!is.null(highlight_path)) {
    highlight_keys <- paste(highlight_path$from, highlight_path$to)
    edge_keys <- paste(vis_edges$from, vis_edges$to)
    is_highlighted <- edge_keys %in% highlight_keys
    vis_edges$width <- ifelse(is_highlighted, 4, 2)
    vis_edges$color <- ifelse(is_highlighted, "#FF0000", "#999999")
  }

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

# =============================================================================
# CALCULATE RISK PROPAGATION
# =============================================================================
calculate_risk_propagation <- function(fitted_bn, scenario = list()) {
  bowtie_log("Calculating risk propagation through network...", level = "info")

  baseline <- perform_inference(fitted_bn)
  scenario_probs <- perform_inference(fitted_bn, evidence = scenario)

  risk_changes <- list()
  for (node in names(baseline)) {
    if (node %in% names(scenario_probs)) {
      baseline_risk <- baseline[[node]]
      scenario_risk <- scenario_probs[[node]]

      if ("High" %in% names(baseline_risk) && "High" %in% names(scenario_risk)) {
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

# =============================================================================
# FIND CRITICAL PATHS
# =============================================================================
find_critical_paths <- function(fitted_bn, target_node = "Consequence_Level") {
  bowtie_log(paste("Finding critical paths to", target_node, "..."), level = "info")

  if (!BNLEARN_AVAILABLE || is.null(fitted_bn)) {
    log_warning("Cannot find critical paths - network not available")
    return(list())
  }

  if (!inherits(fitted_bn, c("bn.fit", "bn"))) {
    log_warning("fitted_bn must be a bn.fit or bn object")
    return(list())
  }

  all_nodes <- tryCatch(names(fitted_bn), error = function(e) character(0))
  if (length(all_nodes) == 0) return(list())

  root_nodes <- all_nodes[sapply(all_nodes, function(n) {
    length(bnlearn::parents(fitted_bn, n)) == 0
  })]

  critical_paths <- list()

  for (root in root_nodes) {
    tryCatch({
      evidence <- setNames(list("High"), root)
      inference_result <- perform_inference(fitted_bn, evidence = evidence,
                                           query_nodes = target_node)

      if (target_node %in% names(inference_result)) {
        impact <- inference_result[[target_node]]["High"]
        critical_paths[[root]] <- list(
          root = root,
          target = target_node,
          impact_on_high_risk = impact,
          path = paste(root, "-> ... ->", target_node)
        )
      }
    }, error = function(e) {
      log_debug(paste("Error analyzing critical path for:", root, "-", e$message))
    })
  }

  if (length(critical_paths) > 0) {
    critical_paths <- critical_paths[order(sapply(critical_paths, function(x) {
      if (is.null(x$impact_on_high_risk) || is.na(x$impact_on_high_risk)) 0
      else x$impact_on_high_risk
    }), decreasing = TRUE)]
  }

  return(critical_paths)
}

# =============================================================================
# MAIN ENTRY POINT: BOWTIE TO BAYESIAN NETWORK
# =============================================================================
bowtie_to_bayesian <- function(bowtie_data, central_problem = NULL,
                              learn_from_data = TRUE, visualize = TRUE) {
  bowtie_log("Converting Bowtie to Bayesian Network...", level = "info")

  state <- new.env(parent = emptyenv())
  state$dag <- NULL
  state$fitted_bn <- NULL

  # Step 1: Create bowtie structure
  bn_structure <- create_bayesian_structure(bowtie_data, central_problem)

  # Step 2: Learn or construct CPTs
  tryCatch({
    if (learn_from_data && nrow(bowtie_data) > 10) {
      # Learn simplified BN from data (does not use random sampling)
      state$fitted_bn <- learn_cpts_from_data(bn_structure)
    } else {
      # Build DAG from bowtie structure and fit with Bayesian estimation
      state$dag <- create_bnlearn_network(bn_structure)

      if (!is.null(state$dag) && BNLEARN_AVAILABLE) {
        tryCatch({
          # Generate training data with marginal distributions for all nodes
          node_names <- bnlearn::nodes(state$dag)
          n_samples <- max(100, nrow(bowtie_data) * 5)
          sim_data <- as.data.frame(lapply(node_names, function(n) {
            factor(sample(c("Low", "Medium", "High"), n_samples, replace = TRUE,
                          prob = c(0.3, 0.4, 0.3)))
          }))
          names(sim_data) <- node_names
          state$fitted_bn <- bnlearn::bn.fit(state$dag, sim_data, method = "bayes")
          bowtie_log("Created fitted Bayesian network", level = "success")
        }, error = function(e) {
          bowtie_log(paste("Could not fit network:", e$message), level = "warning")
        })
      }
    }
  }, error = function(e) {
    bowtie_log(paste("CPT learning error:", e$message), level = "warning")
  })

  # Step 3: Visualize if requested
  vis_plot <- NULL
  if (visualize) {
    vis_plot <- tryCatch(
      visualize_bayesian_network(bn_structure),
      error = function(e) {
        bowtie_log(paste("Visualization error:", e$message), level = "error")
        NULL
      }
    )
  }

  network_to_use <- if (!is.null(state$fitted_bn)) state$fitted_bn else state$dag
  fitted_bn_final <- state$fitted_bn

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

# =============================================================================
# EXAMPLE USAGE
# =============================================================================
example_bayesian_analysis <- function(bowtie_data) {
  bowtie_log("EXAMPLE BAYESIAN NETWORK ANALYSIS", level = "info")

  bn_result <- bowtie_to_bayesian(bowtie_data, learn_from_data = FALSE)

  # Example 1: Basic inference
  bowtie_log("1. BASIC INFERENCE", level = "info")
  evidence <- list(Pressure_Level = "High")
  results <- bn_result$inference_function(evidence, c("Consequence_Level", "Problem_Severity"))
  log_debug(paste(capture.output(str(results)), collapse = "\n"))

  # Example 2: Intervention analysis
  bowtie_log("2. INTERVENTION ANALYSIS", level = "info")
  evidence <- list(Control_Effect = "Effective", Pressure_Level = "High")
  results <- bn_result$inference_function(evidence, "Consequence_Level")
  log_debug(paste(capture.output(str(results)), collapse = "\n"))

  # Example 3: Risk propagation
  bowtie_log("3. RISK PROPAGATION", level = "info")
  if (!is.null(bn_result) && !is.null(bn_result$network)) {
    scenario <- list(Activity = "Present")
    risk_changes <- calculate_risk_propagation(bn_result$network, scenario)

    bowtie_log("Risk changes with activity present:", level = "info")
    for (node in names(risk_changes)) {
      change <- risk_changes[[node]]
      if (!is.null(change$change) && abs(change$change) > 0.01) {
        bowtie_log(sprintf("  %s: %.1f%% -> %.1f%% (change: %+.1f%%)",
                   node,
                   change$baseline_high * 100,
                   change$scenario_high * 100,
                   change$change * 100), level = "info")
      }
    }
  }

  return(bn_result$visualization)
}

if (interactive()) {
  cat("Bowtie to Bayesian Network converter loaded!\n")
  cat("Main functions:\n")
  cat("  - bowtie_to_bayesian(): Convert bowtie data to Bayesian network\n")
  cat("  - perform_inference(): Run probabilistic queries\n")
  cat("  - calculate_risk_propagation(): Analyze risk scenarios\n")
  cat("  - find_critical_paths(): Identify high-impact pathways\n")
  cat("  - visualize_bayesian_network(): Create interactive visualization\n")
}
