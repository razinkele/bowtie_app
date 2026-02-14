# =============================================================================
# ml_ensemble_predictor.R
# Ensemble Learning for Link Quality Prediction
# =============================================================================
# STATUS: EXPERIMENTAL - Not integrated into main application
# This module is loaded optionally and provides advanced ML ensemble
# features that are not yet used in the production workflow.
# =============================================================================
# Version: 1.0
# Description: Combines multiple ML models for improved prediction accuracy
#
# This module implements ensemble methods that combine Random Forest,
# Gradient Boosting, and other models to achieve better prediction performance
# than any single model alone.
#
# Author: Claude Code
# Date: 2025-12-29

# =============================================================================
# ENSEMBLE CAPABILITIES
# =============================================================================

# Track which ensemble models are available
ENSEMBLE_CAPABILITIES <- list(
  randomForest = FALSE,
  gbm = FALSE,
  xgboost = FALSE,
  ensemble_available = FALSE
)

# Try to load ensemble packages
if (requireNamespace("randomForest", quietly = TRUE)) {
  ENSEMBLE_CAPABILITIES$randomForest <- TRUE
}

if (requireNamespace("gbm", quietly = TRUE)) {
  ENSEMBLE_CAPABILITIES$gbm <- TRUE
}

if (requireNamespace("xgboost", quietly = TRUE)) {
  ENSEMBLE_CAPABILITIES$xgboost <- TRUE
}

# Ensemble available if at least 2 models available
ENSEMBLE_CAPABILITIES$ensemble_available <-
  sum(ENSEMBLE_CAPABILITIES$randomForest,
      ENSEMBLE_CAPABILITIES$gbm,
      ENSEMBLE_CAPABILITIES$xgboost) >= 2

# =============================================================================
# ENSEMBLE TRAINING
# =============================================================================

#' Train ensemble of ML models
#'
#' Trains multiple models and creates an ensemble predictor
#'
#' @param feedback_data Feedback data frame
#' @param models Vector of model types to include (default: all available)
#' @param min_samples Minimum samples for training
#' @return Ensemble model object
train_ensemble <- function(feedback_data,
                          models = c("randomForest", "gbm"),
                          min_samples = 50) {

  if (nrow(feedback_data) < min_samples) {
    bowtie_log(sprintf("Insufficient data (%d < %d) for ensemble training",
                nrow(feedback_data), min_samples), level = "info")
    return(NULL)
  }

  bowtie_log(sprintf("Training ensemble with %d models on %d samples...",
              length(models), nrow(feedback_data)), level = "info")

  # Extract features
  if (!exists("extract_features_batch")) {
    stop("extract_features_batch() not found. Load ml_link_classifier.R first.")
  }

  features <- extract_features_batch(feedback_data)
  outcome <- factor(
    feedback_data$action == "accepted",
    levels = c(FALSE, TRUE),
    labels = c("rejected", "accepted")
  )

  # Prepare training data
  train_data <- as.data.frame(features)
  train_data$outcome <- outcome
  train_data <- train_data[complete.cases(train_data), ]

  if (nrow(train_data) < min_samples) {
    bowtie_log("Insufficient complete cases for ensemble", level = "info")
    return(NULL)
  }

  # Train individual models
  ensemble <- list(
    models = list(),
    weights = c(),
    model_types = c(),
    trained_on = nrow(train_data)
  )

  # 1. Random Forest
  if ("randomForest" %in% models && ENSEMBLE_CAPABILITIES$randomForest) {
    bowtie_log("Training Random Forest...", level = "debug")
    tryCatch({
      rf_model <- randomForest::randomForest(
        outcome ~ .,
        data = train_data,
        ntree = 500,
        mtry = floor(sqrt(ncol(train_data) - 1)),
        importance = TRUE
      )

      oob_error <- rf_model$err.rate[500, "OOB"]
      oob_accuracy <- 1 - oob_error

      ensemble$models$randomForest <- rf_model
      ensemble$weights <- c(ensemble$weights, oob_accuracy)
      ensemble$model_types <- c(ensemble$model_types, "randomForest")

      bowtie_log(sprintf("RF accuracy: %.2f%%", oob_accuracy * 100), level = "success")
    }, error = function(e) {
      bowtie_log(paste("RF training failed:", e$message), level = "warning")
    })
  }

  # 2. Gradient Boosting Machine
  if ("gbm" %in% models && ENSEMBLE_CAPABILITIES$gbm) {
    bowtie_log("Training Gradient Boosting...", level = "debug")
    tryCatch({
      # Convert outcome to numeric for gbm
      train_data_gbm <- train_data
      train_data_gbm$outcome <- as.numeric(train_data$outcome == "accepted")

      gbm_model <- gbm::gbm(
        outcome ~ .,
        data = train_data_gbm,
        distribution = "bernoulli",
        n.trees = 500,
        interaction.depth = 4,
        shrinkage = 0.01,
        bag.fraction = 0.5,
        cv.folds = 5,
        verbose = FALSE
      )

      # Get optimal number of trees
      best_iter <- gbm::gbm.perf(gbm_model, method = "cv", plot.it = FALSE)

      # Estimate accuracy from cross-validation
      cv_error <- min(gbm_model$cv.error)
      cv_accuracy <- 1 - cv_error

      ensemble$models$gbm <- list(
        model = gbm_model,
        best_iter = best_iter
      )
      ensemble$weights <- c(ensemble$weights, cv_accuracy)
      ensemble$model_types <- c(ensemble$model_types, "gbm")

      bowtie_log(sprintf("GBM accuracy: %.2f%% (trees: %d)", cv_accuracy * 100, best_iter), level = "success")
    }, error = function(e) {
      bowtie_log(paste("GBM training failed:", e$message), level = "warning")
    })
  }

  # 3. XGBoost (if available)
  if ("xgboost" %in% models && ENSEMBLE_CAPABILITIES$xgboost) {
    bowtie_log("Training XGBoost...", level = "debug")
    tryCatch({
      # Prepare data for xgboost
      train_matrix <- xgboost::xgb.DMatrix(
        data = as.matrix(train_data[, -ncol(train_data)]),
        label = as.numeric(train_data$outcome == "accepted")
      )

      xgb_model <- xgboost::xgboost(
        data = train_matrix,
        nrounds = 100,
        objective = "binary:logistic",
        max_depth = 6,
        eta = 0.3,
        verbose = 0,
        nthread = max(1, parallel::detectCores() - 1)
      )

      # Estimate accuracy from training
      preds <- predict(xgb_model, train_matrix)
      accuracy <- mean((preds > 0.5) == (train_data$outcome == "accepted"))

      ensemble$models$xgboost <- xgb_model
      ensemble$weights <- c(ensemble$weights, accuracy)
      ensemble$model_types <- c(ensemble$model_types, "xgboost")

      bowtie_log(sprintf("XGBoost accuracy: %.2f%%", accuracy * 100), level = "success")
    }, error = function(e) {
      bowtie_log(paste("XGBoost training failed:", e$message), level = "warning")
    })
  }

  # Normalize weights
  if (length(ensemble$weights) > 0) {
    ensemble$weights <- ensemble$weights / sum(ensemble$weights)

    weight_details <- paste(sapply(seq_along(ensemble$model_types), function(i) {
      sprintf("%s: %.3f", ensemble$model_types[i], ensemble$weights[i])
    }), collapse = ", ")
    bowtie_log(sprintf("Ensemble trained with %d models (%s)", length(ensemble$models), weight_details), level = "success")

    class(ensemble) <- c("ensemble_predictor", "list")
    return(ensemble)
  } else {
    bowtie_log("No models trained successfully", level = "error")
    return(NULL)
  }
}

#' Predict using ensemble
#'
#' Makes predictions using weighted average of ensemble models
#'
#' @param ensemble Trained ensemble object
#' @param links Data frame of links
#' @return Numeric vector of probabilities
predict_ensemble <- function(ensemble, links) {

  if (is.null(ensemble) || length(ensemble$models) == 0) {
    warning("No ensemble models available")
    return(rep(0.5, nrow(links)))
  }

  # Extract features
  if (!exists("extract_features_batch")) {
    stop("extract_features_batch() not found")
  }

  features <- extract_features_batch(links)
  features_df <- as.data.frame(features)

  # Get predictions from each model
  predictions_matrix <- matrix(nrow = nrow(features_df),
                               ncol = length(ensemble$models))

  model_idx <- 1
  for (model_name in names(ensemble$models)) {
    model <- ensemble$models[[model_name]]

    if (model_name == "randomForest") {
      preds <- predict(model, features_df, type = "prob")[, "accepted"]
    } else if (model_name == "gbm") {
      preds <- predict(model$model, features_df,
                      n.trees = model$best_iter,
                      type = "response")
    } else if (model_name == "xgboost") {
      pred_matrix <- xgboost::xgb.DMatrix(data = as.matrix(features_df))
      preds <- predict(model, pred_matrix)
    } else {
      preds <- rep(0.5, nrow(features_df))
    }

    predictions_matrix[, model_idx] <- preds
    model_idx <- model_idx + 1
  }

  # Weighted average
  ensemble_predictions <- predictions_matrix %*% ensemble$weights

  return(as.vector(ensemble_predictions))
}

#' Add ensemble predictions to links
#'
#' @param links Data frame of links
#' @param ensemble Trained ensemble object
#' @return Links with ensemble_quality column
add_ensemble_quality_scores <- function(links, ensemble = NULL) {

  if (nrow(links) == 0) {
    links$ensemble_quality <- numeric(0)
    links$ensemble_quality_level <- character(0)
    return(links)
  }

  if (is.null(ensemble)) {
    # Try to get cached ensemble
    if (exists(".ensemble_model", envir = .GlobalEnv)) {
      ensemble <- get(".ensemble_model", envir = .GlobalEnv)
    }
  }

  if (is.null(ensemble)) {
    # Fallback to ml_quality if available
    if ("ml_quality" %in% names(links)) {
      links$ensemble_quality <- links$ml_quality
    } else if ("confidence" %in% names(links)) {
      links$ensemble_quality <- links$confidence
    } else {
      links$ensemble_quality <- rep(0.5, nrow(links))
    }
  } else {
    # Use ensemble predictions
    links$ensemble_quality <- predict_ensemble(ensemble, links)
  }

  # Categorize quality
  links$ensemble_quality_level <- cut(
    links$ensemble_quality,
    breaks = c(0, 0.3, 0.5, 0.7, 0.85, 1.0),
    labels = c("very_low", "low", "medium", "high", "very_high"),
    include.lowest = TRUE
  )

  return(links)
}

# =============================================================================
# MODEL MANAGEMENT
# =============================================================================

#' Save ensemble to disk
#'
#' @param ensemble Trained ensemble object
#' @param file_path Path to save (default: models/ensemble_predictor.rds)
#' @return Invisible NULL
save_ensemble <- function(ensemble, file_path = "models/ensemble_predictor.rds") {

  model_dir <- dirname(file_path)
  if (!dir.exists(model_dir)) {
    dir.create(model_dir, recursive = TRUE)
  }

  tryCatch({
    saveRDS(ensemble, file_path)
    bowtie_log(sprintf("Ensemble saved to %s (models: %s)", file_path, paste(names(ensemble$models), collapse = ", ")), level = "success")
  }, error = function(e) {
    warning("Failed to save ensemble: ", e$message)
  })

  invisible(NULL)
}

#' Load ensemble from disk
#'
#' @param file_path Path to model file
#' @return Ensemble object or NULL
load_ensemble <- function(file_path = "models/ensemble_predictor.rds") {

  if (!file.exists(file_path)) {
    bowtie_log(sprintf("No ensemble found at %s", file_path), level = "info")
    return(NULL)
  }

  tryCatch({
    ensemble <- readRDS(file_path)
    bowtie_log(sprintf("Loaded ensemble from %s (models: %s, trained on %d samples)",
                       file_path, paste(names(ensemble$models), collapse = ", "), ensemble$trained_on), level = "success")
    return(ensemble)
  }, error = function(e) {
    warning("Failed to load ensemble: ", e$message)
    return(NULL)
  })
}

#' Initialize ensemble predictor
#'
#' @param feedback_data Optional feedback data for training
#' @param auto_train Train if no saved model found
#' @return TRUE if initialized, FALSE otherwise
init_ensemble_predictor <- function(feedback_data = NULL, auto_train = FALSE) {

  if (!ENSEMBLE_CAPABILITIES$ensemble_available) {
    bowtie_log("Ensemble not available (need 2+ models installed)", level = "info")
    return(FALSE)
  }

  # Try to load from disk
  ensemble <- load_ensemble()

  if (is.null(ensemble) && auto_train && !is.null(feedback_data)) {
    bowtie_log("No saved ensemble found, training new models...", level = "info")
    ensemble <- train_ensemble(feedback_data)

    if (!is.null(ensemble)) {
      save_ensemble(ensemble)
    }
  }

  # Cache globally
  if (!is.null(ensemble)) {
    assign(".ensemble_model", ensemble, envir = .GlobalEnv)
    return(TRUE)
  }

  return(FALSE)
}

#' Get cached ensemble
#'
#' @return Ensemble object or NULL
get_ensemble <- function() {
  if (exists(".ensemble_model", envir = .GlobalEnv)) {
    return(get(".ensemble_model", envir = .GlobalEnv))
  }
  return(NULL)
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Module initialization message (interactive only)
if (interactive()) {
  cat("Ensemble Predictor loaded successfully!\n")
  cat("==================================================\n\n")
  cat("Capabilities:\n")
  cat("  - Random Forest:", if(ENSEMBLE_CAPABILITIES$randomForest) "YES" else "NO", "\n")
  cat("  - Gradient Boosting:", if(ENSEMBLE_CAPABILITIES$gbm) "YES" else "NO", "\n")
  cat("  - XGBoost:", if(ENSEMBLE_CAPABILITIES$xgboost) "YES" else "NO", "\n")
  cat("  - Ensemble available:", if(ENSEMBLE_CAPABILITIES$ensemble_available) "YES" else "NO", "\n\n")
  cat("Available Functions:\n")
  cat("  - train_ensemble()                 : Train ensemble of models\n")
  cat("  - predict_ensemble()               : Predict with ensemble\n")
  cat("  - add_ensemble_quality_scores()    : Add ensemble scores to links\n")
  cat("  - save_ensemble() / load_ensemble(): Model persistence\n")
  cat("  - init_ensemble_predictor()        : Initialize ensemble\n")
  cat("  - get_ensemble()                   : Get cached ensemble\n\n")
  cat("==================================================\n")
}
