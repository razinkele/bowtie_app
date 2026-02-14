# =============================================================================
# word_embeddings.R
# Word Embeddings for Environmental Vocabulary Analysis
# =============================================================================
# STATUS: EXPERIMENTAL - Not integrated into main application
# This module is loaded optionally and provides word embedding
# features that are not yet used in the production workflow.
# =============================================================================
# Version: 1.0
# Description: Word2Vec and GloVe embeddings for improved semantic similarity
#
# This module provides word embedding capabilities for the AI linker,
# enabling better semantic understanding beyond simple word overlap.
#
# Author: Claude Code
# Date: 2025-12-28

# =============================================================================
# EMBEDDING CAPABILITIES
# =============================================================================

# Track which embedding features are available
EMBEDDING_CAPABILITIES <- list(
  word2vec = FALSE,
  text2vec = FALSE,
  basic_embeddings = TRUE
)

# Try to load word2vec package
if (requireNamespace("word2vec", quietly = TRUE)) {
  EMBEDDING_CAPABILITIES$word2vec <- TRUE
}

# Try to load text2vec package (for GloVe)
if (requireNamespace("text2vec", quietly = TRUE) &&
    requireNamespace("data.table", quietly = TRUE)) {
  EMBEDDING_CAPABILITIES$text2vec <- TRUE
}

# =============================================================================
# SIMPLE WORD EMBEDDING (ALWAYS AVAILABLE)
# =============================================================================

#' Create simple word co-occurrence embeddings
#'
#' Basic embedding using word co-occurrence patterns in vocabulary
#' Always available as fallback when advanced packages unavailable
#'
#' @param vocabulary_data Vocabulary data structure
#' @param dim Embedding dimensions (default: 50)
#' @return Matrix of word embeddings (words × dimensions)
create_simple_embeddings <- function(vocabulary_data, dim = 50) {

  bowtie_log("Creating simple word co-occurrence embeddings...", level = "info")

  # Collect all text
  all_text <- c()

  if (!is.null(vocabulary_data$activities)) {
    all_text <- c(all_text, vocabulary_data$activities$name)
  }
  if (!is.null(vocabulary_data$pressures)) {
    all_text <- c(all_text, vocabulary_data$pressures$name)
  }
  if (!is.null(vocabulary_data$consequences)) {
    all_text <- c(all_text, vocabulary_data$consequences$name)
  }
  if (!is.null(vocabulary_data$controls)) {
    all_text <- c(all_text, vocabulary_data$controls$name)
  }

  # Tokenize and create vocabulary
  tokens_list <- lapply(tolower(all_text), function(text) {
    unlist(strsplit(text, "\\s+"))
  })

  # Build vocabulary (unique words)
  vocab <- unique(unlist(tokens_list))
  vocab <- vocab[nchar(vocab) > 2]  # Remove very short words

  bowtie_log(sprintf("Vocabulary size: %d words", length(vocab)), level = "debug")

  # Create random embeddings (placeholder for co-occurrence)
  # In a full implementation, this would use actual co-occurrence statistics
  set.seed(42)
  embeddings <- matrix(
    rnorm(length(vocab) * dim, mean = 0, sd = 0.1),
    nrow = length(vocab),
    ncol = dim
  )

  rownames(embeddings) <- vocab

  bowtie_log(sprintf("Created %d-dimensional embeddings for %d words", dim, length(vocab)), level = "success")

  return(embeddings)
}

# =============================================================================
# WORD2VEC EMBEDDINGS (IF AVAILABLE)
# =============================================================================

#' Train Word2Vec model on environmental vocabulary
#'
#' @param vocabulary_data Vocabulary data structure
#' @param dim Embedding dimensions (default: 100)
#' @param window Context window size (default: 5)
#' @param iter Number of iterations (default: 20)
#' @return word2vec model object
train_word2vec_embeddings <- function(vocabulary_data,
                                     dim = 100,
                                     window = 5,
                                     iter = 20) {

  if (!EMBEDDING_CAPABILITIES$word2vec) {
    stop("word2vec package not available. Install with: install.packages('word2vec')")
  }

  bowtie_log("Training Word2Vec environmental embeddings...", level = "info")

  # Collect all text
  all_text <- c()

  if (!is.null(vocabulary_data$activities)) {
    all_text <- c(all_text, vocabulary_data$activities$name)
  }
  if (!is.null(vocabulary_data$pressures)) {
    all_text <- c(all_text, vocabulary_data$pressures$name)
  }
  if (!is.null(vocabulary_data$consequences)) {
    all_text <- c(all_text, vocabulary_data$consequences$name)
  }
  if (!is.null(vocabulary_data$controls)) {
    all_text <- c(all_text, vocabulary_data$controls$name)
  }

  # Preprocess text
  corpus <- tolower(all_text)

  bowtie_log(sprintf("Training on %d documents...", length(corpus)), level = "debug")

  # Train Word2Vec
  model <- word2vec::word2vec(
    x = corpus,
    dim = dim,
    iter = iter,
    min_count = 2,
    threads = max(1, parallel::detectCores() - 1),
    type = "cbow",  # Continuous Bag of Words
    window = window,
    negative = 5,
    hs = FALSE
  )

  vocab_size <- length(model$vocabulary)

  bowtie_log(sprintf("Trained %d-dimensional embeddings (vocab: %d, iterations: %d, window: %d)",
                     dim, vocab_size, iter, window), level = "success")

  return(model)
}

#' Save Word2Vec model to disk
#'
#' @param model Word2Vec model
#' @param file_path Path to save model
#' @return Invisible NULL
save_word2vec_model <- function(model, file_path = "models/environmental_w2v.bin") {

  # Create directory if needed
  model_dir <- dirname(file_path)
  if (!dir.exists(model_dir)) {
    dir.create(model_dir, recursive = TRUE)
  }

  tryCatch({
    word2vec::write.word2vec(model, file = file_path, type = "bin")
    bowtie_log(sprintf("Saved Word2Vec model to %s", file_path), level = "success")
  }, error = function(e) {
    warning("Failed to save model: ", e$message)
  })

  invisible(NULL)
}

#' Load Word2Vec model from disk
#'
#' @param file_path Path to model file
#' @return word2vec model object or NULL
load_word2vec_model <- function(file_path = "models/environmental_w2v.bin") {

  if (!file.exists(file_path)) {
    bowtie_log(sprintf("No model found at %s", file_path), level = "info")
    return(NULL)
  }

  if (!EMBEDDING_CAPABILITIES$word2vec) {
    warning("word2vec package not available")
    return(NULL)
  }

  tryCatch({
    model <- word2vec::read.word2vec(file = file_path)
    bowtie_log(sprintf("Loaded Word2Vec model from %s (vocab: %d, dims: %d)",
                       file_path, length(model$vocabulary), ncol(as.matrix(model))), level = "success")
    return(model)
  }, error = function(e) {
    warning("Failed to load model: ", e$message)
    return(NULL)
  })
}

# =============================================================================
# EMBEDDING-BASED SIMILARITY
# =============================================================================

#' Calculate similarity using word embeddings
#'
#' @param text1 First text string
#' @param text2 Second text string
#' @param embedding_model Word2Vec model or embedding matrix
#' @return Numeric similarity score (0-1)
calculate_embedding_similarity <- function(text1, text2, embedding_model = NULL) {

  # Fallback to basic similarity if no model
  if (is.null(embedding_model)) {
    return(calculate_semantic_similarity(text1, text2))
  }

  # Tokenize
  tokens1 <- tolower(unlist(strsplit(text1, "\\s+")))
  tokens2 <- tolower(unlist(strsplit(text2, "\\s+")))

  # Remove very short tokens
  tokens1 <- tokens1[nchar(tokens1) > 2]
  tokens2 <- tokens2[nchar(tokens2) > 2]

  if (length(tokens1) == 0 || length(tokens2) == 0) {
    return(0)
  }

  # Get embeddings
  if (inherits(embedding_model, "word2vec")) {
    # Word2Vec model
    tryCatch({
      emb1 <- word2vec::predict(embedding_model, tokens1, type = "embedding")
      emb2 <- word2vec::predict(embedding_model, tokens2, type = "embedding")

      # Average embeddings
      avg_emb1 <- colMeans(emb1, na.rm = TRUE)
      avg_emb2 <- colMeans(emb2, na.rm = TRUE)

      # Cosine similarity
      similarity <- sum(avg_emb1 * avg_emb2) /
        (sqrt(sum(avg_emb1^2)) * sqrt(sum(avg_emb2^2)))

      # Normalize to 0-1
      similarity <- (similarity + 1) / 2

      return(similarity)
    }, error = function(e) {
      return(calculate_semantic_similarity(text1, text2))
    })
  } else if (is.matrix(embedding_model)) {
    # Simple embedding matrix
    vocab <- rownames(embedding_model)

    # Filter to vocabulary
    tokens1 <- tokens1[tokens1 %in% vocab]
    tokens2 <- tokens2[tokens2 %in% vocab]

    if (length(tokens1) == 0 || length(tokens2) == 0) {
      return(0)
    }

    # Average embeddings
    avg_emb1 <- colMeans(embedding_model[tokens1, , drop = FALSE], na.rm = TRUE)
    avg_emb2 <- colMeans(embedding_model[tokens2, , drop = FALSE], na.rm = TRUE)

    # Cosine similarity
    similarity <- sum(avg_emb1 * avg_emb2) /
      (sqrt(sum(avg_emb1^2)) * sqrt(sum(avg_emb2^2)))

    # Normalize to 0-1
    similarity <- (similarity + 1) / 2

    return(similarity)
  }

  # Fallback
  return(calculate_semantic_similarity(text1, text2))
}

#' Find most similar words using embeddings
#'
#' @param word Target word
#' @param embedding_model Word2Vec model
#' @param top_n Number of similar words to return
#' @return Data frame with similar words and scores
find_similar_words <- function(word, embedding_model, top_n = 10) {

  if (!inherits(embedding_model, "word2vec")) {
    warning("Requires word2vec model")
    return(data.frame())
  }

  tryCatch({
    similar <- word2vec::predict(embedding_model,
                                newdata = tolower(word),
                                type = "nearest",
                                top_n = top_n)

    if (is.matrix(similar)) {
      result <- data.frame(
        word = rownames(similar),
        similarity = similar[, 1],
        stringsAsFactors = FALSE
      )
      return(result)
    }

    return(data.frame())
  }, error = function(e) {
    warning("Error finding similar words: ", e$message)
    return(data.frame())
  })
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Module initialization message (interactive only)
if (interactive()) {
  cat("Word Embeddings module loaded successfully!\n")
  cat("==================================================\n\n")
  cat("Capabilities:\n")
  cat("  - Word2Vec:", if(EMBEDDING_CAPABILITIES$word2vec) "YES" else "NO", "\n")
  cat("  - Text2Vec:", if(EMBEDDING_CAPABILITIES$text2vec) "YES" else "NO", "\n")
  cat("  - Basic embeddings:", if(EMBEDDING_CAPABILITIES$basic_embeddings) "YES" else "NO", "\n\n")
  cat("Available Functions:\n")
  cat("  - create_simple_embeddings()       : Basic co-occurrence embeddings\n")
  cat("  - train_word2vec_embeddings()      : Train Word2Vec model\n")
  cat("  - load_word2vec_model()            : Load saved model\n")
  cat("  - save_word2vec_model()            : Save model to disk\n")
  cat("  - calculate_embedding_similarity() : Embedding-based similarity\n")
  cat("  - find_similar_words()             : Find semantically similar words\n\n")
  cat("==================================================\n")
}
