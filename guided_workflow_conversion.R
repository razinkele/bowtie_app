# =============================================================================
# guided_workflow_conversion.R
# Data Conversion Functions for Guided Workflow
# =============================================================================
# Part of: Guided Workflow System modularization
# Version: 5.4.0
# Date: January 2026
# Description: Converts workflow data to main application bowtie format
# =============================================================================

# %||% operator is defined in guided_workflow_validation.R (loaded before this file)

# =============================================================================
# MAIN DATA CONVERSION
# =============================================================================

#' Convert workflow data to main application format
#'
#' Creates a comprehensive bowtie data frame from workflow data.
#' NOTE: Escalation factors in bow-tie methodology affect CONTROLS, not the central event.
#' The data structure uses a single Escalation_Factor column for simplicity,
#' but these factors represent threats to control effectiveness.
#'
#' @param project_data List containing workflow project data
#' @param reviewed_selections Optional list of reviewed/filtered selections from Step 8 Review
#' @return Data frame in main application bowtie format
convert_to_main_data_format <- function(project_data, reviewed_selections = NULL) {
  tryCatch({
    # Extract all components
    central_problem <- project_data$problem_statement %||% "Unnamed Problem"
    project_name <- project_data$project_name %||% "Unnamed Project"

    # If reviewed_selections provided (from Step 8 Review), use filtered data
    if (!is.null(reviewed_selections)) {
      activities <- as.character(reviewed_selections$activities)
      pressures <- as.character(reviewed_selections$pressures)
      preventive_controls <- as.character(reviewed_selections$preventive_controls)
      consequences <- as.character(reviewed_selections$consequences)
      protective_controls <- as.character(reviewed_selections$protective_controls)
      escalation_factors <- as.character(project_data$escalation_factors %||% list())
    } else {
      # Fallback: use project_data directly (backward compatible)
      activities <- as.character(project_data$activities %||% list())
      pressures <- as.character(project_data$pressures %||% list())
      preventive_controls <- as.character(project_data$preventive_controls %||% list())
      consequences <- as.character(project_data$consequences %||% list())
      protective_controls <- as.character(project_data$protective_controls %||% list())
      escalation_factors <- as.character(project_data$escalation_factors %||% list())
    }

    # =========================================================================
    # Build bowtie dataframe using vector recycling
    # =========================================================================
    # In bowtie topology, all causes converge on the central problem and all
    # consequences fan out. Row-level pairings from recycling are NOT meaningful
    # relationships — downstream code (utils.R, bowtie_bayesian_network.r)
    # extracts unique values per column for node creation.
    # This approach includes ALL user-selected elements with no truncation.
    # Row count = max of all vector lengths (linear, not exponential).
    # =========================================================================

    n_rows <- max(
      length(activities), length(pressures),
      length(preventive_controls), length(consequences),
      length(protective_controls), length(escalation_factors), 1
    )

    bowtie_data <- data.frame(
      Activity = if (length(activities) > 0) rep_len(activities, n_rows) else NA_character_,
      Pressure = if (length(pressures) > 0) rep_len(pressures, n_rows) else NA_character_,
      Preventive_Control = if (length(preventive_controls) > 0) rep_len(preventive_controls, n_rows) else NA_character_,
      Escalation_Factor = if (length(escalation_factors) > 0) rep_len(escalation_factors, n_rows) else NA_character_,
      Central_Problem = rep(central_problem, n_rows),
      Protective_Mitigation = if (length(protective_controls) > 0) rep_len(protective_controls, n_rows) else NA_character_,
      Consequence = if (length(consequences) > 0) rep_len(consequences, n_rows) else NA_character_,
      Likelihood = 3L,
      Severity = 3L,
      stringsAsFactors = FALSE
    )

    # Calculate risk level
    bowtie_data$Risk_Level <- ifelse(
      bowtie_data$Likelihood * bowtie_data$Severity <= 6, "Low",
      ifelse(bowtie_data$Likelihood * bowtie_data$Severity <= 15, "Medium", "High")
    )

    # Add metadata
    attr(bowtie_data, "project_name") <- project_name
    attr(bowtie_data, "created_from") <- "guided_workflow"
    attr(bowtie_data, "created_at") <- Sys.time()
    esc_count <- length(unique(escalation_factors[nchar(escalation_factors) > 0]))
    attr(bowtie_data, "escalation_factors_count") <- esc_count
    attr(bowtie_data, "note") <- "Escalation factors threaten control effectiveness, not the central problem directly"

    bowtie_log(paste("Generated", nrow(bowtie_data), "bow-tie pathway(s)"), level = "info")
    bowtie_log(paste("Components:",
        length(unique(bowtie_data$Activity[!is.na(bowtie_data$Activity)])), "activities,",
        length(unique(bowtie_data$Pressure[!is.na(bowtie_data$Pressure)])), "pressures,",
        length(unique(bowtie_data$Preventive_Control[!is.na(bowtie_data$Preventive_Control)])), "preventive controls,",
        length(unique(bowtie_data$Protective_Mitigation[!is.na(bowtie_data$Protective_Mitigation)])), "protective controls,",
        length(unique(bowtie_data$Consequence[!is.na(bowtie_data$Consequence)])), "consequences,",
        length(unique(bowtie_data$Escalation_Factor[!is.na(bowtie_data$Escalation_Factor)])), "escalation factors"),
        level = "info")

    return(bowtie_data)

  }, error = function(e) {
    cat("Error converting workflow data:", e$message, "\n")
    # Return minimal valid data frame
    data.frame(
      Activity = "Error in conversion",
      Pressure = "Error in conversion",
      Preventive_Control = "Error in conversion",
      Escalation_Factor = "System error (threatens controls)",
      Central_Problem = "Error in conversion",
      Protective_Mitigation = "Error in conversion",
      Consequence = "Error in conversion",
      Likelihood = 1L,
      Severity = 1L,
      Risk_Level = "Low",
      stringsAsFactors = FALSE
    )
  })
}

# =============================================================================
# INTEGRATION HELPER
# =============================================================================

#' Create guided workflow tab for integration
#' @return nav_panel or tabPanel object
create_guided_workflow_tab <- function() {
  tryCatch({
    # Check if bslib nav_panel function is available
    if (exists("nav_panel", mode = "function")) {
      nav_panel(
        title = tagList(icon("magic"), "Guided Creation"),
        icon = icon("magic"),
        value = "guided_workflow",
        guided_workflow_ui()
      )
    } else {
      # Fallback for older Shiny versions
      tabPanel(
        title = tagList(icon("magic"), "Guided Creation"),
        value = "guided_workflow",
        guided_workflow_ui()
      )
    }
  }, error = function(e) {
    cat("Warning: Error creating guided workflow tab:", e$message, "\n")
    # Return basic tabPanel as fallback
    tabPanel(
      title = "Guided Creation",
      value = "guided_workflow",
      guided_workflow_ui()
    )
  })
}

bowtie_log("   - guided_workflow_conversion.R loaded (data conversion + integration)", level = "debug")
