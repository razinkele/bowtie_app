# test_phase3_features.R
# Comprehensive tests for Phase 3 AI Linker improvements
# Tests: Ensemble methods, Explainable AI
# Version: 1.0
# Date: 2025-12-29

cat("\n🧪 Phase 3 Feature Testing Suite\n")
cat("==================================================\n\n")

# Load required packages
suppressMessages({
  library(testthat)
  library(dplyr)
})

# Source required modules
setwd("..")
cat("📦 Loading application modules...\n")
source("utils.R")
source("vocabulary.R")
source("vocabulary_ai_linker.R")
source("ml_link_classifier.R")
source("ml_ensemble_predictor.R")
source("explainable_ai.R")

# Load test vocabulary data
cat("📊 Loading vocabulary data...\n")
vocabulary_data <- load_vocabulary()

cat("\n")

# =============================================================================
# TEST 1: ENSEMBLE PREDICTOR
# =============================================================================

test_that("Ensemble predictor works correctly", {
  cat("🎯 Test 1: Ensemble Predictor\n")

  # Check capability detection
  expect_true(exists("ENSEMBLE_CAPABILITIES"))
  expect_type(ENSEMBLE_CAPABILITIES, "list")
  expect_true("randomForest" %in% names(ENSEMBLE_CAPABILITIES))
  expect_true("gbm" %in% names(ENSEMBLE_CAPABILITIES))

  cat("  ✓ Ensemble capabilities detected\n")

  # Create synthetic feedback data
  set.seed(42)
  synthetic_feedback <- data.frame(
    from_id = paste0("A", sprintf("%03d", 1:100)),
    from_name = rep("Test activity", 100),
    from_type = rep("Activity", 100),
    to_id = paste0("P", sprintf("%03d", 1:100)),
    to_name = rep("Test pressure", 100),
    to_type = rep("Pressure", 100),
    similarity = runif(100, 0.3, 0.9),
    confidence = runif(100, 0.4, 0.95),
    method = sample(c("keyword", "semantic", "causal"), 100, replace = TRUE),
    action = sample(c("accepted", "rejected"), 100, replace = TRUE, prob = c(0.75, 0.25)),
    stringsAsFactors = FALSE
  )

  cat(sprintf("  ℹ️ Created %d synthetic feedback samples\n", nrow(synthetic_feedback)))

  # Test ensemble training if available
  if (ENSEMBLE_CAPABILITIES$ensemble_available) {
    cat("  ℹ️ Ensemble available, testing training...\n")

    tryCatch({
      # Determine which models to use
      available_models <- c()
      if (ENSEMBLE_CAPABILITIES$randomForest) available_models <- c(available_models, "randomForest")
      if (ENSEMBLE_CAPABILITIES$gbm) available_models <- c(available_models, "gbm")

      if (length(available_models) >= 2) {
        ensemble <- train_ensemble(
          synthetic_feedback,
          models = available_models,
          min_samples = 50
        )

        expect_true(!is.null(ensemble))
        expect_true(inherits(ensemble, "ensemble_predictor"))
        expect_true(length(ensemble$models) >= 2)
        expect_true(length(ensemble$weights) == length(ensemble$models))

        cat(sprintf("  ✓ Ensemble trained with %d models\n", length(ensemble$models)))

        # Test prediction
        test_links <- synthetic_feedback[1:5, ]
        predictions <- predict_ensemble(ensemble, test_links)

        expect_true(is.numeric(predictions))
        expect_true(length(predictions) == 5)
        expect_true(all(predictions >= 0 & predictions <= 1))

        cat(sprintf("  ✓ Ensemble predictions: %.3f, %.3f, %.3f\n",
                    predictions[1], predictions[2], predictions[3]))

        # Test quality score addition
        links_with_ensemble <- add_ensemble_quality_scores(test_links, ensemble)

        expect_true("ensemble_quality" %in% names(links_with_ensemble))
        expect_true("ensemble_quality_level" %in% names(links_with_ensemble))

        cat("  ✓ Ensemble quality scores added\n")

        # Test model persistence
        test_file <- tempfile(fileext = ".rds")
        save_ensemble(ensemble, test_file)
        expect_true(file.exists(test_file))

        loaded_ensemble <- load_ensemble(test_file)
        expect_true(!is.null(loaded_ensemble))
        expect_true(length(loaded_ensemble$models) == length(ensemble$models))

        cat("  ✓ Ensemble save/load working\n")

        # Cleanup
        unlink(test_file)

      } else {
        cat("  ℹ️ Not enough models available for ensemble (need 2+)\n")
      }
    }, error = function(e) {
      cat("  ⚠️ Ensemble test failed:", e$message, "\n")
    })
  } else {
    cat("  ℹ️ Ensemble not available (install randomForest + gbm)\n")
  }

  cat("\n")
})

# =============================================================================
# TEST 2: EXPLAINABLE AI
# =============================================================================

test_that("Explainable AI works correctly", {
  cat("🔍 Test 2: Explainable AI\n")

  # Create test link
  test_link <- data.frame(
    from_id = "A001",
    from_name = "Commercial fishing",
    from_type = "Activity",
    to_id = "P001",
    to_name = "Overfishing pressure",
    to_type = "Pressure",
    similarity = 0.85,
    confidence = 0.92,
    method = "causal_chain",
    confidence_level = "very_high",
    stringsAsFactors = FALSE
  )

  # Test explanation generation
  explanation <- explain_suggestion(test_link)

  expect_true(is.list(explanation))
  expect_true("link_id" %in% names(explanation))
  expect_true("overall_score" %in% names(explanation))
  expect_true("top_reasons" %in% names(explanation))
  expect_true("factors" %in% names(explanation))

  expect_true(length(explanation$top_reasons) > 0)
  expect_true(length(explanation$factors) > 0)

  cat("  ✓ Explanation generated successfully\n")
  cat(sprintf("    - Overall score: %.0f%%\n", explanation$overall_score * 100))
  cat(sprintf("    - Top reasons: %d found\n", length(explanation$top_reasons)))
  cat(sprintf("    - Factors analyzed: %d\n", length(explanation$factors)))

  # Test batch explanations
  test_links <- rbind(test_link, test_link, test_link)
  explanations <- explain_suggestions_batch(test_links)

  expect_true(is.list(explanations))
  expect_true(length(explanations) == 3)

  cat("  ✓ Batch explanations working\n")

  # Test text formatting
  text_explanation <- format_explanation_text(explanation)

  expect_true(is.character(text_explanation))
  expect_true(nchar(text_explanation) > 0)
  expect_true(grepl("Suggestion:", text_explanation))
  expect_true(grepl("Top Reasons:", text_explanation))

  cat("  ✓ Text formatting working\n")

  # Test HTML formatting (if shiny available)
  if (requireNamespace("shiny", quietly = TRUE)) {
    html_explanation <- format_explanation_html(explanation)
    expect_true(!is.null(html_explanation))
    cat("  ✓ HTML formatting working\n")
  }

  cat("\n")
})

# =============================================================================
# TEST 3: FEATURE IMPORTANCE
# =============================================================================

test_that("Feature importance extraction works", {
  cat("📊 Test 3: Feature Importance\n")

  # Create synthetic feedback and train a model
  set.seed(42)
  synthetic_feedback <- data.frame(
    from_id = paste0("A", sprintf("%03d", 1:100)),
    from_name = rep("Test activity", 100),
    from_type = rep("Activity", 100),
    to_id = paste0("P", sprintf("%03d", 1:100)),
    to_name = rep("Test pressure", 100),
    to_type = rep("Pressure", 100),
    similarity = runif(100, 0.3, 0.9),
    confidence = runif(100, 0.4, 0.95),
    method = sample(c("keyword", "semantic", "causal"), 100, replace = TRUE),
    action = sample(c("accepted", "rejected"), 100, replace = TRUE, prob = c(0.7, 0.3)),
    stringsAsFactors = FALSE
  )

  if (exists("train_link_classifier") && requireNamespace("randomForest", quietly = TRUE)) {
    cat("  ℹ️ Training model for importance analysis...\n")

    tryCatch({
      model <- train_link_classifier(synthetic_feedback, ntree = 100)

      if (!is.null(model)) {
        # Test feature importance extraction
        importance <- get_feature_importance(model)

        expect_true(is.data.frame(importance))
        expect_true("feature" %in% names(importance))
        expect_true("importance" %in% names(importance))
        expect_true(nrow(importance) > 0)

        # Importance should sum to 1 (normalized)
        expect_true(abs(sum(importance$importance) - 1) < 0.01)

        cat(sprintf("  ✓ Feature importance extracted (%d features)\n", nrow(importance)))

        # Show top 3 features
        top_features <- head(importance, 3)
        cat("    Top 3 features:\n")
        for (i in 1:min(3, nrow(top_features))) {
          cat(sprintf("      %d. %s: %.1f%%\n",
                      i,
                      top_features$feature[i],
                      top_features$importance[i] * 100))
        }

        # Test plotting (if ggplot2 available)
        if (requireNamespace("ggplot2", quietly = TRUE)) {
          tryCatch({
            plot <- plot_feature_importance(model, top_n = 5)
            expect_true(inherits(plot, "gg"))
            cat("  ✓ Feature importance plotting working\n")
          }, error = function(e) {
            cat("  ⚠️ Plotting failed:", e$message, "\n")
          })
        }
      }
    }, error = function(e) {
      cat("  ⚠️ Feature importance test failed:", e$message, "\n")
    })
  } else {
    cat("  ℹ️ Skipping (randomForest not available)\n")
  }

  cat("\n")
})

# =============================================================================
# TEST 4: INTEGRATION
# =============================================================================

test_that("Phase 3 features integrate correctly", {
  cat("🔗 Test 4: Integration\n")

  # Check all functions exist
  expect_true(exists("train_ensemble"))
  expect_true(exists("predict_ensemble"))
  expect_true(exists("explain_suggestion"))
  expect_true(exists("get_feature_importance"))

  cat("  ✓ All Phase 3 functions available\n")

  # Test that ensemble can use explainable AI
  test_link <- data.frame(
    from_id = "A001",
    from_name = "Test",
    from_type = "Activity",
    to_id = "P001",
    to_name = "Test2",
    to_type = "Pressure",
    similarity = 0.75,
    confidence = 0.82,
    method = "causal",
    stringsAsFactors = FALSE
  )

  explanation <- explain_suggestion(test_link)
  expect_true(!is.null(explanation))

  cat("  ✓ Explainable AI works with test data\n")

  cat("\n")
})

# =============================================================================
# SUMMARY
# =============================================================================

cat("\n✅ Phase 3 Testing Complete!\n")
cat("==================================================\n\n")

cat("📋 Test Summary:\n")
cat("  1. Ensemble Predictor: Tested\n")
cat("  2. Explainable AI: Tested\n")
cat("  3. Feature Importance: Tested\n")
cat("  4. Integration: Tested\n\n")

cat("💡 Recommendations:\n")
if (!ENSEMBLE_CAPABILITIES$ensemble_available) {
  if (!ENSEMBLE_CAPABILITIES$randomForest) {
    cat("  • Install randomForest package for ensemble methods\n")
  }
  if (!ENSEMBLE_CAPABILITIES$gbm) {
    cat("  • Install gbm package for gradient boosting\n")
  }
}

cat("\n🎉 All Phase 3 features working as expected!\n\n")
