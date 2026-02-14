# =============================================================================
# explainable_ai.R
# Explainable AI for Link Quality Predictions
# =============================================================================
# STATUS: EXPERIMENTAL - Not integrated into main application
# This module is loaded optionally and provides advanced explainability
# features that are not yet used in the production workflow.
# =============================================================================
# Version: 1.0
# Description: Provides explanations for why suggestions were made
#
# This module implements explainability features that help users understand
# why certain suggestions were made and what factors influenced the predictions.
#
# Author: Claude Code
# Date: 2025-12-29

# =============================================================================
# EXPLANATION GENERATION
# =============================================================================

#' Generate explanation for a link/suggestion
#'
#' Creates human-readable explanation of why a link was suggested
#'
#' @param link Single link data frame row or list
#' @param model ML model or ensemble (optional)
#' @return List with explanation components
explain_suggestion <- function(link, model = NULL) {

  explanation <- list(
    link_id = paste(link$from_id, link$to_id, sep = " → "),
    link_name = paste(link$from_name, "→", link$to_name),
    overall_score = if (!is.null(link$confidence)) link$confidence else link$similarity,
    factors = list(),
    top_reasons = c(),
    confidence_level = if (!is.null(link$confidence_level)) link$confidence_level else "medium"
  )

  # Factor 1: Similarity Score
  similarity <- if (!is.null(link$similarity)) link$similarity else 0
  if (similarity > 0) {
    similarity_strength <- if (similarity >= 0.7) {
      "strong"
    } else if (similarity >= 0.5) {
      "moderate"
    } else {
      "weak"
    }

    explanation$factors$similarity <- list(
      score = similarity,
      strength = similarity_strength,
      description = sprintf("%.0f%% text similarity between items",
                           similarity * 100)
    )

    if (similarity >= 0.5) {
      explanation$top_reasons <- c(explanation$top_reasons,
                                  sprintf("%s semantic similarity (%.0f%%)",
                                         tools::toTitleCase(similarity_strength),
                                         similarity * 100))
    }
  }

  # Factor 2: Detection Method
  method <- if (!is.null(link$method)) as.character(link$method) else "unknown"
  method_name <- if (grepl("causal_chain", method)) {
    "Complete causal chain detected"
  } else if (grepl("causal", method)) {
    "Causal relationship detected"
  } else if (grepl("keyword", method)) {
    "Thematic keyword match"
  } else if (grepl("semantic", method)) {
    "Semantic analysis"
  } else {
    "Basic analysis"
  }

  method_reliability <- if (grepl("causal_chain", method)) {
    "very high"
  } else if (grepl("causal", method)) {
    "high"
  } else {
    "medium"
  }

  explanation$factors$method <- list(
    name = method,
    display_name = method_name,
    reliability = method_reliability
  )

  explanation$top_reasons <- c(explanation$top_reasons, method_name)

  # Factor 3: Connection Multiplicity
  if (!is.null(link$confidence_factors) &&
      !is.null(link$confidence_factors$connection_multiplicity)) {
    multiplicity <- link$confidence_factors$connection_multiplicity

    if (multiplicity > 1) {
      explanation$factors$multiplicity <- list(
        count = multiplicity,
        description = sprintf("Found %d different connection paths", multiplicity)
      )

      explanation$top_reasons <- c(explanation$top_reasons,
                                  sprintf("Multiple connection paths (%d)", multiplicity))
    }
  }

  # Factor 4: Environmental Domain Match
  if (!is.null(link$theme)) {
    explanation$factors$domain <- list(
      theme = link$theme,
      description = sprintf("Both items relate to '%s'", link$theme)
    )

    explanation$top_reasons <- c(explanation$top_reasons,
                                sprintf("Common environmental theme: %s", link$theme))
  }

  # Factor 5: Link Type Appropriateness
  link_type <- paste(link$from_type, "→", link$to_type)
  type_score <- 0

  if (link$from_type == "Activity" && link$to_type == "Pressure") {
    type_score <- 1.0
    type_reason <- "Activities naturally cause Pressures"
  } else if (link$from_type == "Pressure" && link$to_type == "Consequence") {
    type_score <- 1.0
    type_reason <- "Pressures naturally lead to Consequences"
  } else if (link$from_type == "Activity" && link$to_type == "Control") {
    type_score <- 0.9
    type_reason <- "Controls can prevent Activities"
  } else if (link$from_type == "Consequence" && link$to_type == "Control") {
    type_score <- 0.9
    type_reason <- "Controls can mitigate Consequences"
  } else {
    type_score <- 0.7
    type_reason <- "Valid environmental link type"
  }

  explanation$factors$link_type <- list(
    type = link_type,
    score = type_score,
    reason = type_reason
  )

  if (type_score >= 0.9) {
    explanation$top_reasons <- c(explanation$top_reasons, type_reason)
  }

  # Limit top reasons to 3-5
  explanation$top_reasons <- head(explanation$top_reasons, 5)

  return(explanation)
}

#' Generate batch explanations
#'
#' @param links Data frame of links
#' @param model Optional ML model
#' @return List of explanations
explain_suggestions_batch <- function(links, model = NULL) {
  lapply(1:nrow(links), function(i) {
    explain_suggestion(links[i, ], model)
  })
}

# =============================================================================
# FEATURE IMPORTANCE ANALYSIS
# =============================================================================

#' Get feature importance from model
#'
#' Extracts and ranks feature importance
#'
#' @param model Trained ML model (randomForest, gbm, etc.)
#' @return Data frame with features and importance scores
get_feature_importance <- function(model) {

  if (inherits(model, "randomForest")) {
    # Random Forest importance
    importance_matrix <- randomForest::importance(model)

    importance_df <- data.frame(
      feature = rownames(importance_matrix),
      importance = importance_matrix[, "MeanDecreaseGini"],
      stringsAsFactors = FALSE
    )

  } else if (inherits(model, "gbm")) {
    # GBM importance
    importance_summary <- summary(model, plotit = FALSE)

    importance_df <- data.frame(
      feature = importance_summary$var,
      importance = importance_summary$rel.inf,
      stringsAsFactors = FALSE
    )

  } else if (inherits(model, "xgb.Booster")) {
    # XGBoost importance
    importance_matrix <- xgboost::xgb.importance(model = model)

    importance_df <- data.frame(
      feature = importance_matrix$Feature,
      importance = importance_matrix$Gain,
      stringsAsFactors = FALSE
    )

  } else if (inherits(model, "ensemble_predictor")) {
    # Ensemble - aggregate importance from all models
    all_importance <- list()

    for (model_name in names(model$models)) {
      model_obj <- if (model_name == "gbm") model$models[[model_name]]$model else model$models[[model_name]]
      importance <- get_feature_importance(model_obj)
      all_importance[[model_name]] <- importance
    }

    # Combine and average
    all_features <- unique(unlist(lapply(all_importance, function(x) x$feature)))

    importance_df <- data.frame(
      feature = all_features,
      importance = sapply(all_features, function(feat) {
        scores <- sapply(all_importance, function(imp) {
          idx <- which(imp$feature == feat)
          if (length(idx) > 0) imp$importance[idx] else 0
        })
        mean(scores)
      }),
      stringsAsFactors = FALSE
    )

  } else {
    warning("Unknown model type for importance extraction")
    return(data.frame(feature = character(), importance = numeric()))
  }

  # Normalize and sort
  importance_df$importance <- importance_df$importance / sum(importance_df$importance)
  importance_df <- importance_df[order(importance_df$importance, decreasing = TRUE), ]
  rownames(importance_df) <- NULL

  return(importance_df)
}

#' Plot feature importance
#'
#' @param model Trained ML model
#' @param top_n Number of top features to show (default: 10)
#' @return ggplot object
plot_feature_importance <- function(model, top_n = 10) {

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 required for plotting")
  }

  importance_df <- get_feature_importance(model)
  importance_df <- head(importance_df, top_n)

  # Create human-readable labels
  importance_df$label <- sapply(importance_df$feature, function(feat) {
    gsub("_", " ", tools::toTitleCase(gsub("_", " ", feat)))
  })

  library(ggplot2)

  ggplot(importance_df, aes(x = reorder(label, importance),
                            y = importance,
                            fill = importance)) +
    geom_col() +
    coord_flip() +
    scale_fill_gradient(low = "#3498db", high = "#e74c3c") +
    labs(
      title = "Feature Importance for Link Quality Prediction",
      subtitle = sprintf("Top %d features", top_n),
      x = "Feature",
      y = "Importance Score",
      fill = "Importance"
    ) +
    theme_minimal() +
    theme(
      legend.position = "none",
      plot.title = element_text(face = "bold", size = 14),
      axis.text = element_text(size = 10)
    ) +
    scale_y_continuous(labels = scales::percent)
}

# =============================================================================
# EXPLANATION FORMATTING
# =============================================================================

#' Format explanation as text
#'
#' @param explanation Explanation object from explain_suggestion()
#' @return Character string with formatted explanation
format_explanation_text <- function(explanation) {

  text <- sprintf("Suggestion: %s\n", explanation$link_name)
  text <- paste0(text, sprintf("Overall Score: %.0f%% (%s confidence)\n",
                              explanation$overall_score * 100,
                              explanation$confidence_level))
  text <- paste0(text, "\nTop Reasons:\n")

  for (i in seq_along(explanation$top_reasons)) {
    text <- paste0(text, sprintf("  %d. %s\n", i, explanation$top_reasons[i]))
  }

  if (length(explanation$factors) > 0) {
    text <- paste0(text, "\nDetailed Factors:\n")

    if (!is.null(explanation$factors$similarity)) {
      text <- paste0(text, sprintf("  • Similarity: %s (%s)\n",
                                  explanation$factors$similarity$description,
                                  explanation$factors$similarity$strength))
    }

    if (!is.null(explanation$factors$method)) {
      text <- paste0(text, sprintf("  • Method: %s (reliability: %s)\n",
                                  explanation$factors$method$display_name,
                                  explanation$factors$method$reliability))
    }

    if (!is.null(explanation$factors$multiplicity)) {
      text <- paste0(text, sprintf("  • %s\n",
                                  explanation$factors$multiplicity$description))
    }

    if (!is.null(explanation$factors$link_type)) {
      text <- paste0(text, sprintf("  • Link Type: %s\n",
                                  explanation$factors$link_type$reason))
    }
  }

  return(text)
}

#' Format explanation as HTML
#'
#' @param explanation Explanation object
#' @return HTML tags for Shiny
format_explanation_html <- function(explanation) {

  if (!requireNamespace("shiny", quietly = TRUE)) {
    return(format_explanation_text(explanation))
  }

  tags <- shiny::tags

  tags$div(
    class = "explanation-card",
    style = "padding: 10px; background-color: #f8f9fa; border-radius: 5px; margin: 5px 0;",

    # Header
    tags$div(
      style = "font-weight: bold; margin-bottom: 10px;",
      explanation$link_name
    ),

    # Overall score
    tags$div(
      style = "margin-bottom: 10px;",
      sprintf("Score: %.0f%% ", explanation$overall_score * 100),
      tags$span(
        class = paste0("badge bg-", if (explanation$overall_score >= 0.7) "success" else if (explanation$overall_score >= 0.5) "info" else "warning"),
        explanation$confidence_level
      )
    ),

    # Top reasons
    tags$div(
      tags$strong("Why this suggestion:"),
      tags$ul(
        style = "margin-top: 5px; margin-bottom: 0;",
        lapply(explanation$top_reasons, function(reason) {
          tags$li(reason)
        })
      )
    )
  )
}

# =============================================================================
# INITIALIZATION
# =============================================================================

cat("✅ Explainable AI module loaded successfully!\n")
cat("==================================================\n\n")
cat("🔧 Available Functions:\n")
cat("  - explain_suggestion()           : Generate explanation for a link\n")
cat("  - explain_suggestions_batch()    : Batch explanations\n")
cat("  - get_feature_importance()       : Extract feature importance from model\n")
cat("  - plot_feature_importance()      : Visualize feature importance\n")
cat("  - format_explanation_text()      : Format as plain text\n")
cat("  - format_explanation_html()      : Format as HTML for Shiny\n\n")

cat("📚 Usage Example:\n")
cat('  explanation <- explain_suggestion(link, model)\n')
cat('  cat(format_explanation_text(explanation))\n')
cat('  importance <- get_feature_importance(model)\n')
cat('  plot_feature_importance(model, top_n = 10)\n\n')

cat("✅ Ready for explainable predictions!\n")
cat("==================================================\n\n")
