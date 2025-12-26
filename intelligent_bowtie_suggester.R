# =============================================================================
# Intelligent Bowtie Suggestion Engine
# Version: 1.0
# Date: November 2025
# Description: Knowledge-based system for suggesting bowtie components based on
#              central problem selection using comprehensive marine vocabulary
# =============================================================================

# Load required packages
if (!require("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
}
library(jsonlite)
library(dplyr)

# =============================================================================
# VOCABULARY DATA LOADING
# =============================================================================

#' Load JSON vocabulary files
#' @param vocab_dir Directory containing JSON files
#' @return List of vocabulary data
load_marine_vocabulary <- function(vocab_dir = "data/vocabulary_json") {

  cat("🔍 Loading marine environmental vocabulary...\n")

  vocabulary <- list()

  # Load all JSON files
  files <- list(
    central_problems = "central_problems.json",
    causes = "causes.json",
    consequences = "consequences.json",
    controls = "controls.json",
    escalation_factors = "escalation_factors.json",
    relationships = "relationships.json"
  )

  for (name in names(files)) {
    filepath <- file.path(vocab_dir, files[[name]])

    if (file.exists(filepath)) {
      tryCatch({
        vocabulary[[name]] <- jsonlite::fromJSON(filepath)
        cat("  ✓ Loaded", name, "\n")
      }, error = function(e) {
        warning(paste("Failed to load", name, ":", e$message))
        vocabulary[[name]] <- NULL
      })
    } else {
      warning(paste("File not found:", filepath))
      vocabulary[[name]] <- NULL
    }
  }

  cat("✅ Vocabulary loaded successfully!\n")
  cat("   • Central Problems:", nrow(vocabulary$central_problems$central_problems), "\n")
  cat("   • Activities:", nrow(vocabulary$causes$activities), "\n")
  cat("   • Pressures:", nrow(vocabulary$causes$pressures), "\n")
  cat("   • Consequences:", nrow(vocabulary$consequences$consequences), "\n")
  cat("   • Preventive Controls:", nrow(vocabulary$controls$preventive_controls), "\n")
  cat("   • Mitigation Controls:", nrow(vocabulary$controls$mitigation_controls), "\n")
  cat("   • Escalation Factors:", nrow(vocabulary$escalation_factors$escalation_factors), "\n")
  cat("   • Bowtie Relationships:", nrow(vocabulary$relationships$bowtie_relationships), "\n")

  return(vocabulary)
}

# =============================================================================
# SUGGESTION ENGINE FUNCTIONS
# =============================================================================

#' Get suggestions based on selected central problem
#' @param central_problem_id ID of selected central problem
#' @param vocabulary Loaded vocabulary data
#' @param top_n Number of top suggestions to return (NULL for all)
#' @return List of suggested components
get_suggestions_for_problem <- function(central_problem_id, vocabulary, top_n = NULL) {

  # Find the relationship for this central problem
  relationships <- vocabulary$relationships$bowtie_relationships
  relationship <- relationships[relationships$central_problem_id == central_problem_id, ]

  if (nrow(relationship) == 0) {
    warning(paste("No relationships found for central problem:", central_problem_id))
    return(NULL)
  }

  # Extract suggestions
  suggestions <- list(
    activities = get_activity_suggestions(relationship$relevant_activities[[1]], vocabulary, top_n),
    pressures = get_pressure_suggestions(relationship$relevant_pressures[[1]], vocabulary, top_n),
    consequences = get_consequence_suggestions(relationship$likely_consequences[[1]], vocabulary, top_n),
    preventive_controls = get_preventive_control_suggestions(relationship$recommended_preventive_controls[[1]], vocabulary, top_n),
    mitigation_controls = get_mitigation_control_suggestions(relationship$recommended_mitigation_controls[[1]], vocabulary, top_n),
    escalation_factors = get_escalation_factor_suggestions(relationship$escalation_factors[[1]], vocabulary, top_n)
  )

  suggestions$pathway_strength <- relationship$pathway_strength

  return(suggestions)
}

#' Get activity suggestions
get_activity_suggestions <- function(activity_ids, vocabulary, top_n = NULL) {
  activities <- vocabulary$causes$activities

  if (is.null(activity_ids) || length(activity_ids) == 0) {
    return(data.frame())
  }

  suggested <- activities[activities$id %in% activity_ids, ]

  # Add relevance score (could be enhanced with more sophisticated ranking)
  suggested$relevance <- 1.0

  # Sort by relevance and limit
  suggested <- suggested[order(-suggested$relevance), ]
  if (!is.null(top_n)) {
    suggested <- head(suggested, top_n)
  }

  return(suggested)
}

#' Get pressure suggestions
get_pressure_suggestions <- function(pressure_ids, vocabulary, top_n = NULL) {
  pressures <- vocabulary$causes$pressures

  if (is.null(pressure_ids) || length(pressure_ids) == 0) {
    return(data.frame())
  }

  suggested <- pressures[pressures$id %in% pressure_ids, ]
  suggested$relevance <- 1.0

  suggested <- suggested[order(-suggested$relevance), ]
  if (!is.null(top_n)) {
    suggested <- head(suggested, top_n)
  }

  return(suggested)
}

#' Get consequence suggestions
get_consequence_suggestions <- function(consequence_ids, vocabulary, top_n = NULL) {
  consequences <- vocabulary$consequences$consequences

  if (is.null(consequence_ids) || length(consequence_ids) == 0) {
    return(data.frame())
  }

  suggested <- consequences[consequences$id %in% consequence_ids, ]
  suggested$relevance <- 1.0

  # Sort by severity and relevance
  severity_order <- c("critical" = 5, "high" = 4, "medium-high" = 3.5, "medium" = 3, "low-medium" = 2, "low" = 1)
  suggested$severity_score <- severity_order[suggested$severity]
  suggested <- suggested[order(-suggested$severity_score, -suggested$relevance), ]

  if (!is.null(top_n)) {
    suggested <- head(suggested, top_n)
  }

  return(suggested)
}

#' Get preventive control suggestions
get_preventive_control_suggestions <- function(control_ids, vocabulary, top_n = NULL) {
  controls <- vocabulary$controls$preventive_controls

  if (is.null(control_ids) || length(control_ids) == 0) {
    return(data.frame())
  }

  suggested <- controls[controls$id %in% control_ids, ]

  # Rank by effectiveness
  effectiveness_order <- c("high" = 5, "medium-high" = 4, "medium" = 3, "low-medium" = 2, "low" = 1)
  suggested$effectiveness_score <- effectiveness_order[suggested$effectiveness]
  suggested$relevance <- 1.0

  suggested <- suggested[order(-suggested$effectiveness_score, -suggested$relevance), ]
  if (!is.null(top_n)) {
    suggested <- head(suggested, top_n)
  }

  return(suggested)
}

#' Get mitigation control suggestions
get_mitigation_control_suggestions <- function(control_ids, vocabulary, top_n = NULL) {
  controls <- vocabulary$controls$mitigation_controls

  if (is.null(control_ids) || length(control_ids) == 0) {
    return(data.frame())
  }

  suggested <- controls[controls$id %in% control_ids, ]

  # Rank by effectiveness
  effectiveness_order <- c("high" = 5, "medium-high" = 4, "medium" = 3, "low-medium" = 2, "low" = 1)
  suggested$effectiveness_score <- effectiveness_order[suggested$effectiveness]
  suggested$relevance <- 1.0

  suggested <- suggested[order(-suggested$effectiveness_score, -suggested$relevance), ]
  if (!is.null(top_n)) {
    suggested <- head(suggested, top_n)
  }

  return(suggested)
}

#' Get escalation factor suggestions
get_escalation_factor_suggestions <- function(escalation_ids, vocabulary, top_n = NULL) {
  escalations <- vocabulary$escalation_factors$escalation_factors

  if (is.null(escalation_ids) || length(escalation_ids) == 0) {
    return(data.frame())
  }

  suggested <- escalations[escalations$id %in% escalation_ids, ]
  suggested$relevance <- 1.0

  # Sort by trend (increasing threats are more relevant)
  trend_order <- c("increasing" = 5, "increasing frequency" = 4.5, "stable-increasing intensity" = 4, "variable" = 3, "stable" = 2, "cyclical" = 2, "decreasing (improving)" = 1)
  suggested$trend_score <- trend_order[suggested$trend]

  suggested <- suggested[order(-suggested$trend_score, -suggested$relevance), ]
  if (!is.null(top_n)) {
    suggested <- head(suggested, top_n)
  }

  return(suggested)
}

# =============================================================================
# UTILITY FUNCTIONS FOR SHINY INTEGRATION
# =============================================================================

#' Format suggestions for selectizeInput choices
#' @param suggestions Data frame of suggestions
#' @param value_col Column to use as value (default: "id")
#' @param label_col Column to use as label (default: "name")
#' @return Named vector for selectizeInput
format_for_selectize <- function(suggestions, value_col = "id", label_col = "name") {
  if (is.null(suggestions) || nrow(suggestions) == 0) {
    return(c())
  }

  choices <- setNames(suggestions[[value_col]], suggestions[[label_col]])
  return(choices)
}

#' Get all central problems for selection
#' @param vocabulary Loaded vocabulary data
#' @return Named vector of central problems
get_all_central_problems <- function(vocabulary) {
  problems <- vocabulary$central_problems$central_problems
  choices <- setNames(problems$id, problems$name)
  return(choices)
}

#' Search vocabulary by keyword
#' @param keyword Search term
#' @param vocabulary Loaded vocabulary data
#' @param component_type Type of component to search (NULL for all)
#' @return Matching results
search_vocabulary <- function(keyword, vocabulary, component_type = NULL) {

  keyword <- tolower(keyword)
  results <- list()

  if (is.null(component_type) || component_type == "activities") {
    activities <- vocabulary$causes$activities
    matches <- grepl(keyword, tolower(activities$name)) |
               grepl(keyword, tolower(activities$description)) |
               sapply(activities$keywords, function(x) any(grepl(keyword, tolower(x))))
    results$activities <- activities[matches, ]
  }

  if (is.null(component_type) || component_type == "pressures") {
    pressures <- vocabulary$causes$pressures
    matches <- grepl(keyword, tolower(pressures$name)) |
               grepl(keyword, tolower(pressures$description)) |
               sapply(pressures$keywords, function(x) any(grepl(keyword, tolower(x))))
    results$pressures <- pressures[matches, ]
  }

  if (is.null(component_type) || component_type == "consequences") {
    consequences <- vocabulary$consequences$consequences
    matches <- grepl(keyword, tolower(consequences$name)) |
               grepl(keyword, tolower(consequences$description)) |
               sapply(consequences$keywords, function(x) any(grepl(keyword, tolower(x))))
    results$consequences <- consequences[matches, ]
  }

  return(results)
}

#' Get detailed information about a component
#' @param component_id ID of component
#' @param component_type Type of component
#' @param vocabulary Loaded vocabulary data
#' @return Detailed information
get_component_details <- function(component_id, component_type, vocabulary) {

  details <- switch(component_type,
    "activity" = vocabulary$causes$activities[vocabulary$causes$activities$id == component_id, ],
    "pressure" = vocabulary$causes$pressures[vocabulary$causes$pressures$id == component_id, ],
    "consequence" = vocabulary$consequences$consequences[vocabulary$consequences$consequences$id == component_id, ],
    "preventive_control" = vocabulary$controls$preventive_controls[vocabulary$controls$preventive_controls$id == component_id, ],
    "mitigation_control" = vocabulary$controls$mitigation_controls[vocabulary$controls$mitigation_controls$id == component_id, ],
    "escalation_factor" = vocabulary$escalation_factors$escalation_factors[vocabulary$escalation_factors$escalation_factors$id == component_id, ],
    NULL
  )

  return(details)
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Global vocabulary cache
.vocabulary_cache <- new.env()

#' Initialize vocabulary (cached)
#' @param force_reload Force reload even if cached
#' @return Vocabulary data
init_vocabulary <- function(force_reload = FALSE) {
  if (force_reload || !exists("vocabulary", envir = .vocabulary_cache)) {
    .vocabulary_cache$vocabulary <- load_marine_vocabulary()
  }
  return(.vocabulary_cache$vocabulary)
}

cat("✅ Intelligent Bowtie Suggestion Engine loaded\n")
cat("   Use init_vocabulary() to load marine environmental vocabulary\n")
cat("   Use get_suggestions_for_problem() to get intelligent suggestions\n")
