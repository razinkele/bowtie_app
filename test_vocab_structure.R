# Quick script to check vocabulary structure
library(readxl)
library(dplyr)

# Read CAUSES.xlsx
data <- read_excel('CAUSES.xlsx')

# Process like vocabulary.R does
data <- data %>%
  select(hierarchy = Hierarchy, id = `ID#`, name = name) %>%
  filter(!is.na(id)) %>%
  mutate(
    level = suppressWarnings(as.numeric(gsub("Level ", "", hierarchy))),
    name = trimws(as.character(name)),
    id = trimws(as.character(id))
  ) %>%
  filter(!is.na(name), !is.na(id), nchar(trimws(name)) > 0, nchar(trimws(id)) > 0)

cat("===== CAUSES.xlsx Structure =====\n")
print(head(data, 30))

cat("\n\n===== Level Distribution =====\n")
print(table(data$level, useNA = "ifany"))

cat("\n\n===== Level 1 Items (Headers) =====\n")
level1 <- data %>% filter(level == 1)
print(level1)

cat("\n\n===== Level 2+ Items (Actual Items) =====\n")
level2plus <- data %>% filter(level > 1)
print(head(level2plus, 20))

cat("\n\nTotal rows:", nrow(data), "\n")
cat("Level 1 (headers):", nrow(level1), "\n")
cat("Level 2+ (items):", nrow(level2plus), "\n")
