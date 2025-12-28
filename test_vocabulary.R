# Test vocabulary loading
cat("Testing vocabulary data loading...\n\n")

source("vocabulary.R")

# Load vocabulary
vocab <- load_vocabulary()

# Check controls
cat("Controls data:\n")
cat("  Total rows:", nrow(vocab$controls), "\n")
cat("  Columns:", paste(names(vocab$controls), collapse = ", "), "\n\n")

# Check Level 1 categories
cat("Level 1 categories:\n")
level1 <- vocab$controls[vocab$controls$level == 1, ]
cat("  Count:", nrow(level1), "\n")
if (nrow(level1) > 0) {
  for (i in 1:nrow(level1)) {
    cat("  •", level1$id[i], "-", level1$name[i], "\n")
  }
}

# Test filtering for first category
cat("\nTesting filtering for first category:\n")
if (nrow(level1) > 0) {
  first_cat_id <- level1$id[1]
  first_cat_name <- level1$name[1]
  cat("  Category ID:", first_cat_id, "\n")
  cat("  Category Name:", first_cat_name, "\n")

  # Filter items
  library(dplyr)
  filtered <- vocab$controls %>%
    filter(level > 1, startsWith(id, first_cat_id))

  cat("  Items found:", nrow(filtered), "\n")
  if (nrow(filtered) > 0) {
    cat("  First 10 items:\n")
    for (i in 1:min(10, nrow(filtered))) {
      cat("    -", filtered$id[i], ":", filtered$name[i], "\n")
    }
  }
}

cat("\n✅ Test complete\n")
