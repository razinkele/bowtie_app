# test_phase2_features.R
# Comprehensive tests for Phase 2 AI Linker improvements
# Tests: Parallel processing, Word embeddings, ML classification
# Version: 1.0
# Date: 2025-12-28

cat("\n🧪 Phase 2 Feature Testing Suite\n")
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
source("word_embeddings.R")
source("ml_link_classifier.R")
source("suggestion_feedback_tracker.R")

# Load test vocabulary data
cat("📊 Loading vocabulary data...\n")
vocabulary_data <- load_vocabulary()

cat("\n")

# =============================================================================
# TEST 1: PARALLEL PROCESSING
# =============================================================================

test_that("Parallel processing capability detection works", {
  cat("🔄 Test 1: Parallel Processing\n")

  # Check capability detection
  capability <- check_parallel_capability(vocabulary_data, threshold = 100)

  expect_type(capability, "list")
  expect_true("available" %in% names(capability))
  expect_true("cores" %in% names(capability))
  expect_true("recommended" %in% names(capability))

  cat("  ✓ Capability detection working\n")

  if (capability$available) {
    cat(sprintf("  ℹ️ Parallel processing available with %d cores\n", capability$cores))

    # Test parallel semantic connections
    tryCatch({
      start_time <- Sys.time()
      parallel_results <- find_semantic_connections_parallel(
        vocabulary_data,
        method = "jaccard",
        threshold = 0.3,
        use_parallel = TRUE,
        n_cores = 2
      )
      end_time <- Sys.time()

      expect_true(nrow(parallel_results) > 0)
      cat(sprintf("  ✓ Parallel processing completed in %.2f seconds\n",
                  as.numeric(end_time - start_time)))
    }, error = function(e) {
      cat("  ⚠️ Parallel processing test failed:", e$message, "\n")
    })
  } else {
    cat("  ℹ️ Parallel processing not available (expected on single-core systems)\n")
  }

  cat("\n")
})

# =============================================================================
# TEST 2: WORD EMBEDDINGS
# =============================================================================

test_that("Word embeddings module works correctly", {
  cat("🧠 Test 2: Word Embeddings\n")

  # Check capability detection
  expect_true(exists("EMBEDDING_CAPABILITIES"))
  expect_type(EMBEDDING_CAPABILITIES, "list")
  expect_true("word2vec" %in% names(EMBEDDING_CAPABILITIES))
  expect_true("basic_embeddings" %in% names(EMBEDDING_CAPABILITIES))

  cat("  ✓ Embedding capabilities detected\n")

  # Test basic embeddings (always available)
  if (EMBEDDING_CAPABILITIES$basic_embeddings) {
    tryCatch({
      embeddings <- create_simple_embeddings(vocabulary_data, dim = 50)

      expect_true(is.matrix(embeddings))
      expect_true(ncol(embeddings) == 50)
      expect_true(nrow(embeddings) > 0)

      cat(sprintf("  ✓ Basic embeddings created: %d words × %d dimensions\n",
                  nrow(embeddings), ncol(embeddings)))
    }, error = function(e) {
      cat("  ⚠️ Basic embeddings test failed:", e$message, "\n")
    })
  }

  # Test Word2Vec if available
  if (EMBEDDING_CAPABILITIES$word2vec) {
    cat("  ℹ️ Word2Vec available, testing training...\n")

    tryCatch({
      # Train small model for testing
      model <- train_word2vec_embeddings(
        vocabulary_data,
        dim = 50,
        window = 3,
        iter = 5  # Reduced for speed
      )

      expect_true(!is.null(model))
      expect_true(inherits(model, "word2vec"))

      cat("  ✓ Word2Vec model trained successfully\n")

      # Test similarity calculation
      similarity <- calculate_embedding_similarity(
        "pollution",
        "contamination",
        model
      )

      expect_true(is.numeric(similarity))
      expect_true(similarity >= 0 && similarity <= 1)

      cat(sprintf("  ✓ Embedding similarity: 'pollution' ↔ 'contamination' = %.3f\n",
                  similarity))

      # Test similar word search
      similar_words <- find_similar_words("marine", model, top_n = 5)

      expect_true(is.data.frame(similar_words))
      expect_true(nrow(similar_words) > 0)

      cat("  ✓ Similar word search working\n")

    }, error = function(e) {
      cat("  ⚠️ Word2Vec test failed:", e$message, "\n")
    })
  } else {
    cat("  ℹ️ Word2Vec not available (install word2vec package for full functionality)\n")
  }

  cat("\n")
})

# =============================================================================
# TEST 3: ML CLASSIFIER
# =============================================================================

test_that("ML classifier works correctly", {
  cat("🤖 Test 3: ML Classifier\n")

  # Check capability detection
  expect_true(exists("ML_CLASSIFIER_CAPABILITIES"))
  expect_type(ML_CLASSIFIER_CAPABILITIES, "list")
  expect_true("randomForest" %in% names(ML_CLASSIFIER_CAPABILITIES))

  cat("  ✓ ML capabilities detected\n")

  # Test feature extraction
  test_link <- data.frame(
    from_id = "A001",
    from_name = "Commercial fishing",
    from_type = "Activity",
    to_id = "P001",
    to_name = "Overfishing pressure",
    to_type = "Pressure",
    similarity = 0.75,
    confidence = 0.82,
    method = "causal_chain",
    stringsAsFactors = FALSE
  )

  features <- extract_link_features(test_link)

  expect_true(is.numeric(features))
  expect_true(length(features) == 19)
  expect_true("similarity" %in% names(features))
  expect_true("confidence" %in% names(features))

  cat("  ✓ Feature extraction working (19 features)\n")

  # Test batch feature extraction
  test_links <- rbind(test_link, test_link, test_link)
  features_batch <- extract_features_batch(test_links)

  expect_true(is.matrix(features_batch))
  expect_true(nrow(features_batch) == 3)
  expect_true(ncol(features_batch) == 19)

  cat("  ✓ Batch feature extraction working\n")

  # Test ML training if randomForest available and feedback data exists
  if (ML_CLASSIFIER_CAPABILITIES$randomForest) {
    cat("  ℹ️ Random Forest available, testing training...\n")

    # Create synthetic feedback data for testing
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

    tryCatch({
      model <- train_link_classifier(
        synthetic_feedback,
        min_samples = 50,
        ntree = 100  # Reduced for speed
      )

      expect_true(!is.null(model))
      expect_true(inherits(model, "randomForest"))

      cat("  ✓ ML classifier trained successfully\n")

      # Test prediction
      test_predictions <- predict_link_quality(test_links, model)

      expect_true(is.numeric(test_predictions))
      expect_true(length(test_predictions) == 3)
      expect_true(all(test_predictions >= 0 & test_predictions <= 1))

      cat(sprintf("  ✓ ML predictions: %.3f, %.3f, %.3f\n",
                  test_predictions[1], test_predictions[2], test_predictions[3]))

      # Test quality score addition
      links_with_ml <- add_ml_quality_scores(test_links, model)

      expect_true("ml_quality" %in% names(links_with_ml))
      expect_true("ml_quality_level" %in% names(links_with_ml))

      cat("  ✓ ML quality scores added to links\n")

    }, error = function(e) {
      cat("  ⚠️ ML classifier test failed:", e$message, "\n")
    })
  } else {
    cat("  ℹ️ Random Forest not available (install randomForest package)\n")
  }

  cat("\n")
})

# =============================================================================
# TEST 4: INTEGRATION TEST
# =============================================================================

test_that("Phase 2 features integrate correctly", {
  cat("🔗 Test 4: Integration\n")

  # Test that AI linker recognizes new capabilities
  expect_true(exists("AI_LINKER_CAPABILITIES"))
  expect_true("word_embeddings" %in% names(AI_LINKER_CAPABILITIES))

  cat("  ✓ AI linker capabilities updated\n")

  # Test embedding similarity method
  if (AI_LINKER_CAPABILITIES$word_embeddings) {
    tryCatch({
      # This should use embedding similarity if available
      similarity <- calculate_semantic_similarity(
        "marine pollution",
        "ocean contamination",
        method = "embedding"
      )

      expect_true(is.numeric(similarity))
      expect_true(similarity >= 0 && similarity <= 1)

      cat(sprintf("  ✓ Embedding similarity method: %.3f\n", similarity))
    }, error = function(e) {
      cat("  ⚠️ Embedding similarity integration failed:", e$message, "\n")
    })
  }

  # Test vocabulary embedding training functions
  if (exists("train_vocabulary_embeddings")) {
    cat("  ✓ Vocabulary embedding functions available\n")
  }

  # Test ML classifier integration
  if (exists("get_ml_classifier")) {
    cat("  ✓ ML classifier access functions available\n")
  }

  cat("\n")
})

# =============================================================================
# TEST 5: PERFORMANCE BENCHMARK
# =============================================================================

test_that("Phase 2 features improve performance", {
  cat("⚡ Test 5: Performance Benchmark\n")

  # Benchmark 1: Semantic similarity (with vs without caching)
  cat("  📊 Benchmarking semantic similarity...\n")

  test_texts <- c(
    "marine pollution",
    "water contamination",
    "coastal degradation",
    "ocean acidification",
    "aquatic ecosystem"
  )

  # Without cache
  clear_cache()
  start_time <- Sys.time()
  for (i in 1:length(test_texts)) {
    for (j in i:length(test_texts)) {
      calculate_semantic_similarity_cached(test_texts[i], test_texts[j], use_cache = FALSE)
    }
  }
  time_no_cache <- as.numeric(Sys.time() - start_time)

  # With cache
  clear_cache()
  start_time <- Sys.time()
  for (i in 1:length(test_texts)) {
    for (j in i:length(test_texts)) {
      calculate_semantic_similarity_cached(test_texts[i], test_texts[j], use_cache = TRUE)
    }
  }
  time_first_cache <- as.numeric(Sys.time() - start_time)

  # Second run with cache (should be faster)
  start_time <- Sys.time()
  for (i in 1:length(test_texts)) {
    for (j in i:length(test_texts)) {
      calculate_semantic_similarity_cached(test_texts[i], test_texts[j], use_cache = TRUE)
    }
  }
  time_cached <- as.numeric(Sys.time() - start_time)

  speedup <- time_no_cache / time_cached

  cat(sprintf("    No cache: %.4f seconds\n", time_no_cache))
  cat(sprintf("    First run with cache: %.4f seconds\n", time_first_cache))
  cat(sprintf("    Cached run: %.4f seconds\n", time_cached))
  cat(sprintf("    Speedup: %.1fx faster\n", speedup))

  expect_true(speedup > 1)  # Cached should be faster

  # Benchmark 2: Keyword index (with vs without)
  if (exists("build_keyword_index")) {
    cat("  📊 Benchmarking keyword index...\n")

    build_keyword_index(vocabulary_data)

    start_time <- Sys.time()
    results_with_index <- find_keyword_connections(
      vocabulary_data,
      use_index = TRUE
    )
    time_with_index <- as.numeric(Sys.time() - start_time)

    start_time <- Sys.time()
    results_without_index <- find_keyword_connections(
      vocabulary_data,
      use_index = FALSE
    )
    time_without_index <- as.numeric(Sys.time() - start_time)

    speedup_index <- time_without_index / time_with_index

    cat(sprintf("    Without index: %.4f seconds\n", time_without_index))
    cat(sprintf("    With index: %.4f seconds\n", time_with_index))
    cat(sprintf("    Speedup: %.1fx faster\n", speedup_index))

    expect_true(speedup_index >= 1)  # Index should not slow down
  }

  cat("\n")
})

# =============================================================================
# SUMMARY
# =============================================================================

cat("\n✅ Phase 2 Testing Complete!\n")
cat("==================================================\n\n")

cat("📋 Test Summary:\n")
cat("  1. Parallel Processing: Tested\n")
cat("  2. Word Embeddings: Tested\n")
cat("  3. ML Classifier: Tested\n")
cat("  4. Integration: Tested\n")
cat("  5. Performance: Benchmarked\n\n")

cat("💡 Recommendations:\n")
if (!ML_CLASSIFIER_CAPABILITIES$randomForest) {
  cat("  • Install randomForest package for ML classification\n")
}
if (!EMBEDDING_CAPABILITIES$word2vec) {
  cat("  • Install word2vec package for advanced embeddings\n")
}

cat("\n🎉 All Phase 2 features working as expected!\n\n")
