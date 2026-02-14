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
#' @return Data frame in main application bowtie format
convert_to_main_data_format <- function(project_data) {
  tryCatch({
    # Extract all components
    central_problem <- project_data$problem_statement %||% "Unnamed Problem"
    project_name <- project_data$project_name %||% "Unnamed Project"

    activities <- project_data$activities %||% list()
    pressures <- project_data$pressures %||% list()
    preventive_controls <- project_data$preventive_controls %||% list()
    consequences <- project_data$consequences %||% list()
    protective_controls <- project_data$protective_controls %||% list()
    escalation_factors <- project_data$escalation_factors %||% list()

    # Convert to character vectors if needed
    activities <- as.character(activities)
    pressures <- as.character(pressures)
    preventive_controls <- as.character(preventive_controls)
    consequences <- as.character(consequences)
    protective_controls <- as.character(protective_controls)
    escalation_factors <- as.character(escalation_factors)

    # If no escalation factors, create dummy ones
    if (length(escalation_factors) == 0) {
      escalation_factors <- c(
        "Budget constraints reducing monitoring",
        "Staff turnover affecting expertise",
        "Equipment maintenance delays",
        "Regulatory changes creating gaps",
        "Extreme weather overwhelming systems",
        "Human error during critical operations"
      )
      cat("i No escalation factors defined - using dummy examples\n")
    }

    # Create bow-tie rows
    # Structure: Activity -> Pressure -> Preventive_Control -> Central_Problem -> Protective_Mitigation -> Consequence
    # Escalation_Factor: Represents threats to control effectiveness (assigned to each control pathway)

    bowtie_rows <- list()

    # If we have complete data, create proper combinations
    if (length(activities) > 0 && length(pressures) > 0 &&
        length(preventive_controls) > 0 && length(consequences) > 0 &&
        length(protective_controls) > 0) {

      # Create multiple rows representing different pathways through the bow-tie
      # Limit combinations to avoid explosion of rows

      for (activity in activities[1:min(3, length(activities))]) {
        for (pressure in pressures[1:min(2, length(pressures))]) {
          for (preventive in preventive_controls[1:min(2, length(preventive_controls))]) {
            for (consequence in consequences[1:min(2, length(consequences))]) {
              for (protective in protective_controls[1:min(2, length(protective_controls))]) {

                # Select an escalation factor for this pathway
                # In reality, each escalation factor threatens specific controls
                # Here we randomly assign one to represent the control vulnerability
                escalation <- sample(escalation_factors, 1)

                bowtie_rows[[length(bowtie_rows) + 1]] <- data.frame(
                  Activity = activity,
                  Pressure = pressure,
                  Preventive_Control = preventive,
                  Escalation_Factor = escalation,  # Threatens the controls, not the central problem
                  Central_Problem = central_problem,
                  Protective_Mitigation = protective,
                  Consequence = consequence,
                  Likelihood = sample(1:5, 1),
                  Severity = sample(1:5, 1),
                  stringsAsFactors = FALSE
                )
              }
            }
          }
        }
      }

    } else {
      # Create sample rows if data is incomplete
      cat("i Incomplete workflow data - creating sample bow-tie structure\n")

      # Create at least one row per escalation factor to show they threaten controls
      for (i in 1:min(3, max(1, length(escalation_factors)))) {
        bowtie_rows[[i]] <- data.frame(
          Activity = if(length(activities) > 0) activities[min(i, length(activities))] else "Sample Activity",
          Pressure = if(length(pressures) > 0) pressures[min(i, length(pressures))] else "Sample Pressure",
          Preventive_Control = if(length(preventive_controls) > 0) preventive_controls[min(i, length(preventive_controls))] else "Sample Preventive Control",
          Escalation_Factor = if(i <= length(escalation_factors)) escalation_factors[i] else escalation_factors[1],
          Central_Problem = central_problem,
          Protective_Mitigation = if(length(protective_controls) > 0) protective_controls[min(i, length(protective_controls))] else "Sample Protective Control",
          Consequence = if(length(consequences) > 0) consequences[min(i, length(consequences))] else "Sample Consequence",
          Likelihood = 3L,
          Severity = 3L,
          stringsAsFactors = FALSE
        )
      }
    }

    # Combine all rows
    bowtie_data <- do.call(rbind, bowtie_rows)

    # Calculate risk level
    bowtie_data$Risk_Level <- ifelse(
      bowtie_data$Likelihood * bowtie_data$Severity > 15, "High",
      ifelse(bowtie_data$Likelihood * bowtie_data$Severity > 8, "Medium", "Low")
    )

    # Add metadata
    attr(bowtie_data, "project_name") <- project_name
    attr(bowtie_data, "created_from") <- "guided_workflow"
    attr(bowtie_data, "created_at") <- Sys.time()
    attr(bowtie_data, "escalation_factors_count") <- length(unique(escalation_factors))
    attr(bowtie_data, "note") <- "Escalation factors threaten control effectiveness, not the central problem directly"

    cat("Generated", nrow(bowtie_data), "bow-tie pathway(s)\n")
    cat("Components: ",
        length(unique(bowtie_data$Activity)), "activities, ",
        length(unique(bowtie_data$Preventive_Control)), "preventive controls, ",
        length(unique(bowtie_data$Protective_Mitigation)), "protective controls, ",
        length(unique(bowtie_data$Consequence)), "consequences, ",
        length(unique(bowtie_data$Escalation_Factor)), "escalation factors\n")

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

cat("   - guided_workflow_conversion.R loaded (data conversion + integration)\n")
