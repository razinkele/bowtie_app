# Simple test to check controls filtering
library(readxl)
library(dplyr)

cat("Testing controls filtering...\n\n")

# Read and transform like vocabulary.R does
data <- read_excel('CONTROLS.xlsx')
controls <- data %>%
  select(hierarchy = Hierarchy, id = `ID#`, name = name) %>%
  filter(!is.na(id)) %>%
  mutate(
    level = as.numeric(gsub('Level ', '', hierarchy)),
    name = trimws(as.character(name)),
    id = trimws(as.character(id))
  ) %>%
  filter(!is.na(name), !is.na(id), nchar(trimws(name)) > 0, nchar(trimws(id)) > 0)

cat("Total rows:", nrow(controls), "\n\n")

# Get Level 1
level1 <- controls %>% filter(level == 1)
cat("Level 1 categories:\n")
print(level1[, c('id', 'name')])

# Test filtering
cat("\n\nTesting filtering:\n")
first_cat_id <- level1$id[1]
first_cat_name <- level1$name[1]
cat("Category ID:", first_cat_id, "\n")
cat("Category Name:", first_cat_name, "\n\n")

# Apply the same filter as the observer
filtered <- controls %>%
  filter(level > 1, startsWith(id, first_cat_id))

cat("Items found:", nrow(filtered), "\n")
if (nrow(filtered) > 0) {
  cat("\nFirst 10 items:\n")
  print(filtered[1:min(10, nrow(filtered)), c('id', 'level', 'name')])
}

cat("\n✅ Test complete\n")
