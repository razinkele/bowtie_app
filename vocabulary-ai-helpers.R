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

# Extract key terms: very small deterministic heuristic - split, remove stopwords, return top_n unique words
extract_key_terms <- function(text, top_n = 5) {
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

# Simple semantic similarity: average of Jaccard and keyword similarity (uses existing functions if available)
calculate_semantic_similarity <- function(text1, text2) {
  # handle NA
  if (is.na(text1) || is.na(text2)) return(0)
  t1 <- preprocess_text(text1)
  t2 <- preprocess_text(text2)

  # Jaccard
  words1 <- unlist(strsplit(gsub("[^a-z0-9 ]", "", t1), " "))
  words2 <- unlist(strsplit(gsub("[^a-z0-9 ]", "", t2), " "))
  words1 <- words1[words1 != ""]
  words2 <- words2[words2 != ""]
  inter <- length(intersect(words1, words2))
  uni <- length(union(words1, words2))
  jaccard <- ifelse(uni == 0, 0, inter / uni)

  # Keyword similarity: simple shared domain keywords
  # Reuse a small set consistent with the other code
  env_keywords <- c("water","pollution","species","habitat","agriculture","industrial","mitigat","protect","monitor","runoff")
  t1l <- tolower(t1)
  t2l <- tolower(t2)
  key_matches <- sum(sapply(env_keywords, function(kw) {
    ifelse(isTRUE(grepl(kw, t1l)) && isTRUE(grepl(kw, t2l)), 1, 0)
  }))
  keyword_sim <- min(1.0, key_matches / 5)

  sim <- (jaccard + keyword_sim) / 2
  return(sim)
}