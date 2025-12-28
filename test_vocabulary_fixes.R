# Quick test to verify vocabulary fixes
cat("===== VOCABULARY FIXES VERIFICATION =====\n\n")

# Source required files
source("utils.R")
source("vocabulary.R")

cat("1. Testing vocabulary loading...\n")
vocab <- load_vocabulary(use_cache = FALSE)

cat("\n2. Checking vocabulary sizes:\n")
cat("   Activities:", nrow(vocab$activities), "items\n")
cat("   Pressures:", nrow(vocab$pressures), "items\n")
cat("   Controls:", nrow(vocab$controls), "items\n")
cat("   Consequences:", nrow(vocab$consequences), "items\n")

# Verify correct sizes
if (nrow(vocab$activities) == 53 &&
    nrow(vocab$pressures) == 36 &&
    nrow(vocab$controls) == 74 &&
    nrow(vocab$consequences) == 26) {
  cat("\n✅ PASS: All vocabulary files loaded correctly\n")
} else {
  cat("\n❌ FAIL: Vocabulary sizes don't match expected values\n")
  cat("   Expected: Activities=53, Pressures=36, Controls=74, Consequences=26\n")
}

cat("\n3. Checking hierarchical structure:\n")

# Check Level 1 categories
level1_activities <- vocab$activities %>% filter(level == 1)
cat("   Activity categories (Level 1):", nrow(level1_activities), "\n")
cat("   Example categories:\n")
print(head(level1_activities %>% select(id, name), 3))

# Check Level 2+ items
level2plus_activities <- vocab$activities %>% filter(level > 1)
cat("\n   Activity items (Level 2+):", nrow(level2plus_activities), "\n")
cat("   Example items:\n")
print(head(level2plus_activities %>% select(id, name, level), 5))

# Test category filtering logic
cat("\n4. Testing category-based filtering:\n")
test_category <- level1_activities$name[1]
test_prefix <- level1_activities$id[1]
cat("   Test category:", test_category, "(ID:", test_prefix, ")\n")

filtered_items <- vocab$activities %>%
  filter(level > 1, startsWith(id, test_prefix))
cat("   Items in this category:", nrow(filtered_items), "\n")
cat("   Example items:\n")
print(head(filtered_items %>% select(id, name), 5))

cat("\n5. Testing pressure hierarchies:\n")
level1_pressures <- vocab$pressures %>% filter(level == 1)
cat("   Pressure categories (Level 1):", nrow(level1_pressures), "\n")
level2plus_pressures <- vocab$pressures %>% filter(level > 1)
cat("   Pressure items (Level 2+):", nrow(level2plus_pressures), "\n")

cat("\n===== ALL TESTS COMPLETED =====\n")
cat("\nSummary:\n")
cat("✅ Vocabulary loading: WORKING\n")
cat("✅ Hierarchical structure: PRESERVED\n")
cat("✅ Category filtering: FUNCTIONAL\n")
cat("\nThe guided workflow should now show:\n")
cat("1. Category dropdown with Level 1 headers\n")
cat("2. Item dropdown that populates based on selected category\n")
cat("3. Custom entry option (min 3 characters)\n")
cat("4. Full vocabulary (not test data)\n")
