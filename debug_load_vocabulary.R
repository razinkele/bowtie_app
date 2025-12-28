# Debug vocabulary loading
library(readxl)
library(dplyr)

# Source vocabulary.R to get read_hierarchical_data function
source("vocabulary.R")

cat("===== Testing direct file read =====\n")
data1 <- read_excel('CAUSES.xlsx', sheet='Activities')
cat("Direct read of Activities sheet:", nrow(data1), "rows\n\n")

cat("===== Testing read_hierarchical_data function =====\n")
data2 <- read_hierarchical_data('CAUSES.xlsx', sheet_name='Activities')
cat("read_hierarchical_data result:", nrow(data2), "rows\n")
cat("Columns:", names(data2), "\n")
cat("\nFirst 5 rows:\n")
print(head(data2, 5))

cat("\n\n===== Testing load_vocabulary function =====\n")
# Clear cache first
if (exists(".vocabulary_cache")) {
  rm(list = ls(envir = .vocabulary_cache), envir = .vocabulary_cache)
}

vocab <- load_vocabulary(use_cache = FALSE)
cat("\nActivities loaded:", nrow(vocab$activities), "rows\n")
cat("Pressures loaded:", nrow(vocab$pressures), "rows\n")

cat("\nActivities columns:", names(vocab$activities), "\n")
cat("\nFirst 5 activities:\n")
print(head(vocab$activities, 5))
