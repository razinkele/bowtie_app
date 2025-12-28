# Small deterministic AI helper functions used by vocabulary tests

# Simple preprocessing: lowercase, remove punctuation, collapse whitespace
preprocess_text <- function(text) {
  if (is.na(text) || length(text) == 0) return("")
  txt <- as.character(text)
  txt <- tolower(txt)
  txt <- gsub("[^a-z0-9\\s]", " ", txt)
  txt <- gsub("\\s+", " ", txt)
  txt <- trimws(txt)
  return(txt)
}

# Extract key terms: very small deterministic heuristic - accepts either text or vocabulary lists
extract_key_terms <- function(text, top_n = 5) {
  # If a vocabulary list is passed, return a list of terms per section
  if (is.list(text)) {
    out <- list()
    for (name in names(text)) {
      df <- text[[name]]
      if (is.data.frame(df) && "name" %in% names(df)) {
        combined <- paste(df$name, collapse = " ")
        out[[name]] <- extract_key_terms(combined, top_n = top_n)
      } else {
        out[[name]] <- character(0)
      }
    }
    return(out)
  }

  txt <- preprocess_text(text)
  if (txt == "") return(character(0))
  words <- unlist(strsplit(txt, " "))
  stop_words <- c("the","a","an","and","or","but","in","on","at","to","for","of","with","by","from","as","is","was","are","were")
  words <- words[!words %in% stop_words]
  if (length(words) == 0) return(character(0))
  freqs <- sort(table(words), decreasing = TRUE)
  terms <- names(freqs)[1:min(top_n, length(freqs))]
  return(terms)
}

# Simple semantic similarity with method support: 'jaccard' or 'cosine'
calculate_semantic_similarity <- function(text1, text2, method = "jaccard") {
  # handle NA
  if (is.na(text1) || is.na(text2)) return(0)
  t1 <- preprocess_text(text1)
  t2 <- preprocess_text(text2)

  # Tokenize
  words1 <- unlist(strsplit(gsub("[^a-z0-9 ]", "", t1), " "))
  words2 <- unlist(strsplit(gsub("[^a-z0-9 ]", "", t2), " "))
  words1 <- words1[words1 != ""]
  words2 <- words2[words2 != ""]

  if (method == "jaccard") {
    inter <- length(intersect(words1, words2))
    uni <- length(union(words1, words2))
    jaccard <- ifelse(uni == 0, 0, inter / uni)
    return(jaccard)
  } else if (method == "cosine") {
    vocab <- unique(c(words1, words2))
    v1 <- as.numeric(table(factor(words1, levels = vocab)))
    v2 <- as.numeric(table(factor(words2, levels = vocab)))
    denom <- sqrt(sum(v1 * v1)) * sqrt(sum(v2 * v2))
    if (denom == 0) return(0)
    cos_sim <- sum(v1 * v2) / denom
    return(cos_sim)
  } else {
    # default fallback: jaccard
    inter <- length(intersect(words1, words2))
    uni <- length(union(words1, words2))
    jaccard <- ifelse(uni == 0, 0, inter / uni)
    return(jaccard)
  }
}