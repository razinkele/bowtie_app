# =============================================================================
# ml_link_classifier.R
# Machine Learning Link Quality Classifier
# =============================================================================
# STATUS: EXPERIMENTAL - Not integrated into main application
# This module is loaded optionally and provides ML classification
# features that are not yet used in the production workflow.
# =============================================================================
# Version: 1.0
# Description: Random Forest classifier for predicting suggestion acceptance
#
# This module provides ML-based quality prediction for AI vocabulary linking,
# learning from historical user feedback to improve suggestion ranking.
#
# Author: Claude Code
# Date: 2025-12-28

# =============================================================================
# ML CAPABILITIES AND DEPENDENCIES
# =============================================================================

# Track ML capabilities
ML_CLASSIFIER_CAPABILITIES <- list(
  randomForest = FALSE,
  caret = FALSE,
  basic_ml = TRUE
)

# Try to load randomForest package
if (requireNamespace("randomForest", quietly = TRUE)) {
  ML_CLASSIFIER_CAPABILITIES$randomForest <- TRUE
}

# Try to load caret package (for advanced training)
if (requireNamespace("caret", quietly = TRUE)) {
  ML_CLASSIFIER_CAPABILITIES$caret <- TRUE
}

# =============================================================================
# FEATURE ENGINEERING
# =============================================================================

#' Extract features from link data for ML classification
#'
#' Converts link attributes into feature vector for ML model
#'
#' @param link Single link record (data frame row or list)
#' @param context Optional context data
#' @return Named numeric vector of features
extract_link_features <- function(link, context = list()) {

  # Base features from link
  similarity <- if (!is.null(link$similarity)) link$similarity else 0.5
  confidence <- if (!is.null(link$confidence)) link$confidence else similarity

  # Method encoding (one-hot)
  method <- if (!is.null(link$method)) as.character(link$method) else "unknown"
  method_keyword <- as.numeric(grepl("keyword", method, ignore.case = TRUE))
  method_semantic <- as.numeric(grepl("semantic|jaccard|cosine", method, ignore.case = TRUE))
  method_causal <- as.numeric(grepl("causal", method, ignore.case = TRUE))
  method_causal_chain <- as.numeric(grepl("causal_chain", method, ignore.case = TRUE))

  # Link type encoding
  from_type <- if (!is.null(link$from_type)) as.character(link$from_type) else "Unknown"
  to_type <- if (!is.null(link$to_type)) as.character(link$to_type) else "Unknown"

  type_activity_pressure <- as.numeric(from_type == "Activity" && to_type == "Pressure")
  type_pressure_consequence <- as.numeric(from_type == "Pressure" && to_type == "Consequence")
  type_activity_control <- as.numeric(from_type == "Activity" && to_type == "Control")
  type_consequence_control <- as.numeric(from_type == "Consequence" && to_type == "Control")

  # Text length features
  from_name <- if (!is.null(link$from_name)) as.character(link$from_name) else ""
  to_name <- if (!is.null(link$to_name)) as.character(link$to_name) else ""

  from_word_count <- length(unlist(strsplit(from_name, "\\s+")))
  to_word_count <- length(unlist(strsplit(to_name, "\\s+")))
  word_count_ratio <- if (to_word_count > 0) from_word_count / to_word_count else 1

  # Confidence factors (if available)
  confidence_factors <- if (!is.null(link$confidence_factors)) {
    link$confidence_factors
  } else {
    NULL
  }

  method_multiplier <- if (!is.null(confidence_factors$method_multiplier)) {
    confidence_factors$method_multiplier
  } else {
    1.0
  }

  connection_multiplicity <- if (!is.null(confidence_factors$connection_multiplicity)) {
    confidence_factors$connection_multiplicity
  } else {
    1
  }

  # Derived features
  similarity_confidence_gap <- abs(similarity - confidence)
  similarity_squared <- similarity^2
  confidence_squared <- confidence^2

  # Create feature vector
  features <- c(
    # Core similarity features
    similarity = similarity,
    confidence = confidence,
    similarity_squared = similarity_squared,
    confidence_squared = confidence_squared,
    similarity_confidence_gap = similarity_confidence_gap,

    # Method features
    method_keyword = method_keyword,
    method_semantic = method_semantic,
    method_causal = method_causal,
    method_causal_chain = method_causal_chain,
    method_multiplier = method_multiplier,

    # Link type features
    type_activity_pressure = type_activity_pressure,
    type_pressure_consequence = type_pressure_consequence,
    type_activity_control = type_activity_control,
    type_consequence_control = type_consequence_control,

    # Text features
    from_word_count = from_word_count,
    to_word_count = to_word_count,
    word_count_ratio = word_count_ratio,

    # Advanced features
    connection_multiplicity = connection_multiplicity
  )

  return(features)
}

#' Extract features from multiple links (batch)
#'
#' @param links Data frame of links
#' @param context Optional context data
#' @return Matrix of features (rows = links, cols = features)
extract_features_batch <- function(links, context = list()) {

  if (nrow(links) == 0) {
    return(matrix(nrow = 0, ncol = 19))
  }

  # Extract features for each link
  features_list <- lapply(1:nrow(links), function(i) {
    extract_link_features(links[i, ], context)
  })

  # Combine into matrix
  features_matrix <- do.call(rbind, features_list)
  rownames(features_matrix) <- NULL

  return(features_matrix)
}

# =============================================================================
# MODEL TRAINING
# =============================================================================

#' Train Random Forest classifier from feedback data
#'
#' Trains a model to predict whether a suggestion will be accepted
#'
#' @param feedback_data Data frame from suggestion_feedback_tracker
#' @param min_samples Minimum samples required for training (default: 50)
#' @param mtry Number of features to try at each split (default: sqrt(n_features))
#' @param ntree Number of trees (default: 500)
#' @return Trained randomForest model or NULL
train_link_classifier <- function(feedback_data,
                                 min_samples = 50,
                                 mtry = NULL,
                                 ntree = 500) {

  if (!ML_CLASSIFIER_CAPABILITIES$randomForest) {
    warning("randomForest package not available. Install with: install.packages('randomForest')")
    return(NULL)
  }

  if (nrow(feedback_data) < min_samples) {
    bowtie_log(sprintf("Insufficient training data (%d < %d), skipping ML training",
                nrow(feedback_data), min_samples), level = "info")
    return(NULL)
  }

  bowtie_log(sprintf("Training Random Forest classifier on %d samples...", nrow(feedback_data)), level = "info")

  # Extract features
  features <- extract_features_batch(feedback_data)

  # Create binary outcome (accepted = TRUE, rejected/dismissed = FALSE)
  outcome <- factor(
    feedback_data$action == "accepted",
    levels = c(FALSE, TRUE),
    labels = c("rejected", "accepted")
  )

  # Combine into training data
  training_data <- as.data.frame(features)
  training_data$outcome <- outcome

  # Remove rows with missing values
  complete_cases <- complete.cases(training_data)
  training_data <- training_data[complete_cases, ]

  if (nrow(training_data) < min_samples) {
    bowtie_log(sprintf("Insufficient complete cases (%d < %d), skipping ML training",
                nrow(training_data), min_samples), level = "info")
    return(NULL)
  }

  bowtie_log(sprintf("Training on %d complete samples (positive rate: %.1f%%)",
              nrow(training_data), 100 * mean(training_data$outcome == "accepted")), level = "debug")

  # Set mtry if not provided (sqrt of number of features)
  if (is.null(mtry)) {
    mtry <- floor(sqrt(ncol(training_data) - 1))
  }

  # Train Random Forest
  tryCatch({
    model <- randomForest::randomForest(
      outcome ~ .,
      data = training_data,
      ntree = ntree,
      mtry = mtry,
      importance = TRUE,
      na.action = na.omit
    )

    # Print model summary
    bowtie_log(sprintf("Random Forest trained: %d trees, %d features/split, OOB error: %.2f%%",
                       ntree, mtry, model$err.rate[ntree, "OOB"] * 100), level = "success")

    # Feature importance
    importance <- randomForest::importance(model)
    top_features <- head(rownames(importance)[order(importance[, "MeanDecreaseGini"], decreasing = TRUE)], 5)
    bowtie_log(sprintf("Top features: %s", paste(top_features, collapse = ", ")), level = "debug")

    return(model)
  }, error = function(e) {
    warning("Failed to train Random Forest: ", e$message)
    return(NULL)
  })
}

#' Save trained classifier to disk
#'
#' @param model Trained randomForest model
#' @param file_path Path to save model (default: models/link_classifier.rds)
#' @return Invisible NULL
save_classifier <- function(model, file_path = "models/link_classifier.rds") {

  # Create directory if needed
  model_dir <- dirname(file_path)
  if (!dir.exists(model_dir)) {
    dir.create(model_dir, recursive = TRUE)
  }

  tryCatch({
    saveRDS(model, file_path)
    bowtie_log(sprintf("Classifier saved to %s", file_path), level = "success")
  }, error = function(e) {
    warning("Failed to save classifier: ", e$message)
  })

  invisible(NULL)
}

#' Load trained classifier from disk
#'
#' @param file_path Path to model file (default: models/link_classifier.rds)
#' @return randomForest model or NULL
load_classifier <- function(file_path = "models/link_classifier.rds") {

  if (!file.exists(file_path)) {
    bowtie_log(sprintf("No classifier found at %s", file_path), level = "info")
    return(NULL)
  }

  if (!ML_CLASSIFIER_CAPABILITIES$randomForest) {
    warning("randomForest package not available")
    return(NULL)
  }

  tryCatch({
    model <- readRDS(file_path)
    bowtie_log(sprintf("Loaded classifier from %s (trees: %d, OOB error: %.2f%%)",
                       file_path, model$ntree, model$err.rate[model$ntree, "OOB"] * 100), level = "success")
    return(model)
  }, error = function(e) {
    warning("Failed to load classifier: ", e$message)
    return(NULL)
  })
}

# =============================================================================
# PREDICTION
# =============================================================================

#' Predict acceptance probability for links
#'
#' Uses trained Random Forest to predict probability of acceptance
#'
#' @param links Data frame of links
#' @param classifier Trained randomForest model
#' @param context Optional context data
#' @return Numeric vector of probabilities (0-1)
predict_link_quality <- function(links, classifier = NULL, context = list()) {

  if (is.null(classifier) || !ML_CLASSIFIER_CAPABILITIES$randomForest) {
    # Return confidence scores as fallback
    return(if (!is.null(links$confidence)) links$confidence else rep(0.5, nrow(links)))
  }

  # Extract features
  features <- extract_features_batch(links, context)
  features_df <- as.data.frame(features)

  # Predict probabilities
  tryCatch({
    predictions <- predict(classifier, features_df, type = "prob")
    probabilities <- predictions[, "accepted"]
    return(probabilities)
  }, error = function(e) {
    warning("Prediction failed: ", e$message)
    # Return confidence scores as fallback
    return(if (!is.null(links$confidence)) links$confidence else rep(0.5, nrow(links)))
  })
}

#' Add ML quality scores to links
#'
#' Enhances links with ML-predicted acceptance probability
#'
#' @param links Data frame of links
#' @param classifier Trained randomForest model
#' @param context Optional context data
#' @return Links data frame with added ml_quality column
add_ml_quality_scores <- function(links, classifier = NULL, context = list()) {

  if (nrow(links) == 0) {
    links$ml_quality <- numeric(0)
    return(links)
  }

  # Predict quality scores
  quality_scores <- predict_link_quality(links, classifier, context)

  # Add to links
  links$ml_quality <- quality_scores

  # Categorize quality level
  links$ml_quality_level <- cut(
    quality_scores,
    breaks = c(0, 0.3, 0.5, 0.7, 0.85, 1.0),
    labels = c("very_low", "low", "medium", "high", "very_high"),
    include.lowest = TRUE
  )

  return(links)
}

# =============================================================================
# MODEL MANAGEMENT
# =============================================================================

# Global classifier storage
.ml_classifier <- new.env(parent = emptyenv())

#' Initialize ML classifier (load or train)
#'
#' @param feedback_data Optional feedback data for training
#' @param auto_train Automatically train if no saved model found
#' @param min_samples Minimum samples for training
#' @return TRUE if classifier initialized, FALSE otherwise
init_ml_classifier <- function(feedback_data = NULL,
                              auto_train = FALSE,
                              min_samples = 50) {

  if (!ML_CLASSIFIER_CAPABILITIES$randomForest) {
    bowtie_log("randomForest not available, ML classification disabled", level = "info")
    return(FALSE)
  }

  # Try to load from disk first
  model <- load_classifier()

  if (is.null(model) && auto_train && !is.null(feedback_data)) {
    bowtie_log("No saved classifier found, training new model...", level = "info")
    model <- train_link_classifier(feedback_data, min_samples = min_samples)

    if (!is.null(model)) {
      save_classifier(model)
    }
  }

  # Cache globally
  if (!is.null(model)) {
    assign("classifier", model, envir = .ml_classifier)
    return(TRUE)
  }

  return(FALSE)
}

#' Get cached ML classifier
#'
#' @return Trained classifier or NULL
get_ml_classifier <- function() {
  if (exists("classifier", envir = .ml_classifier)) {
    return(get("classifier", envir = .ml_classifier))
  }
  return(NULL)
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Module initialization message (interactive only)
if (interactive()) {
  cat("ML Link Classifier loaded successfully!\n")
  cat("==================================================\n\n")
  cat("Capabilities:\n")
  cat("  - Random Forest:", if(ML_CLASSIFIER_CAPABILITIES$randomForest) "YES" else "NO", "\n")
  cat("  - Caret (advanced):", if(ML_CLASSIFIER_CAPABILITIES$caret) "YES" else "NO", "\n")
  cat("  - Basic ML:", if(ML_CLASSIFIER_CAPABILITIES$basic_ml) "YES" else "NO", "\n\n")
  cat("Available Functions:\n")
  cat("  - train_link_classifier()      : Train Random Forest on feedback\n")
  cat("  - load_classifier()            : Load saved model\n")
  cat("  - save_classifier()            : Save model to disk\n")
  cat("  - predict_link_quality()       : Predict acceptance probability\n")
  cat("  - add_ml_quality_scores()      : Add ML scores to links\n")
  cat("  - extract_link_features()      : Feature engineering\n")
  cat("  - init_ml_classifier()         : Initialize classifier\n")
  cat("  - get_ml_classifier()          : Get cached classifier\n\n")
  cat("==================================================\n")
}
