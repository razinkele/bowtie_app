# Test what vocabulary data is actually loaded
source("utils.R")
source("vocabulary.R")

cat("===== Loading Vocabulary =====\n")
vocab <- load_vocabulary()

cat("\n===== Vocabulary Structure =====\n")
cat("Names:", names(vocab), "\n")

if (!is.null(vocab$activities)) {
  cat("\n===== Activities =====\n")
  cat("Rows:", nrow(vocab$activities), "\n")
  cat("Columns:", names(vocab$activities), "\n")
  cat("\nLevel distribution:\n")
  print(table(vocab$activities$level, useNA = "ifany"))

  cat("\nLevel 1 (headers):\n")
  print(vocab$activities %>% filter(level == 1) %>% select(id, name))

  cat("\nLevel 2+ (actual items) - first 10:\n")
  print(vocab$activities %>% filter(level > 1) %>% select(id, name, level) %>% head(10))
}

if (!is.null(vocab$pressures)) {
  cat("\n===== Pressures =====\n")
  cat("Rows:", nrow(vocab$pressures), "\n")
  cat("Level distribution:\n")
  print(table(vocab$pressures$level, useNA = "ifany"))
}

if (!is.null(vocab$controls)) {
  cat("\n===== Controls =====\n")
  cat("Rows:", nrow(vocab$controls), "\n")
  cat("Level distribution:\n")
  print(table(vocab$controls$level, useNA = "ifany"))
}

if (!is.null(vocab$consequences)) {
  cat("\n===== Consequences =====\n")
  cat("Rows:", nrow(vocab$consequences), "\n")
  cat("Level distribution:\n")
  print(table(vocab$consequences$level, useNA = "ifany"))
}
