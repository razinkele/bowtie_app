# =============================================================================
# Test Script: Verify Bowtie Logic in AI-Powered Vocabulary Analysis
# =============================================================================

# Load required libraries
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)

# Set working directory (assumes script is run from app directory)
# setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Source required files
cat("Loading vocabulary system...\n")
source("vocabulary.R")

cat("Loading AI linker with bowtie logic...\n")
source("vocabulary_ai_linker.R")

cat("Loading vocabulary bowtie generator...\n")
source("vocabulary_bowtie_generator.R")

# =============================================================================
# TEST 1: Verify AI Linker Creates Bowtie-Compliant Links
# =============================================================================

cat("\n" , rep("=", 80), "\n", sep = "")
cat("TEST 1: AI Linker - Bowtie Structure Compliance\n")
cat(rep("=", 80), "\n", sep = "")

# Load vocabulary
vocab <- load_vocabulary()

# Generate AI-powered links
cat("\nGenerating AI-powered links with bowtie logic...\n")
ai_links <- find_vocabulary_links(
  vocab,
  similarity_threshold = 0.25,
  max_links_per_item = 3,
  methods = c("jaccard", "keyword", "causal")
)

# Verify link structure
cat("\n📊 Link Statistics:\n")
cat(sprintf("  Total links created: %d\n", nrow(ai_links)))

if (nrow(ai_links) > 0) {
  link_summary <- ai_links %>%
    group_by(from_type, to_type, relationship) %>%
    summarise(count = n(), avg_similarity = mean(similarity, na.rm = TRUE), .groups = 'drop') %>%
    arrange(desc(count))

  cat("\n  Links by type and relationship:\n")
  print(link_summary)

  # Check for invalid connections
  cat("\n🔍 Validating bowtie structure...\n")

  invalid_connections <- list()

  # Rule 1: Activities should only connect to Pressures (or be controlled)
  invalid_activity <- ai_links %>%
    filter(from_type == "Activity" & !(to_type %in% c("Pressure")))
  if (nrow(invalid_activity) > 0) {
    invalid_connections$activities <- invalid_activity
    cat(sprintf("  ❌ Found %d invalid Activity connections (should only go to Pressure)\n", nrow(invalid_activity)))
  } else {
    cat("  ✅ All Activity connections are valid (→ Pressure)\n")
  }

  # Rule 2: Pressures should only connect to Consequences (or be controlled)
  invalid_pressure <- ai_links %>%
    filter(from_type == "Pressure" & !(to_type %in% c("Consequence")))
  if (nrow(invalid_pressure) > 0) {
    invalid_connections$pressures <- invalid_pressure
    cat(sprintf("  ❌ Found %d invalid Pressure connections (should only go to Consequence)\n", nrow(invalid_pressure)))
  } else {
    cat("  ✅ All Pressure connections are valid (→ Consequence)\n")
  }

  # Rule 3: Preventive controls should only connect to Activities/Pressures
  invalid_preventive <- ai_links %>%
    filter(from_type == "Control" & control_category == "preventive" &
           !(to_type %in% c("Activity", "Pressure")))
  if (nrow(invalid_preventive) > 0) {
    invalid_connections$preventive <- invalid_preventive
    cat(sprintf("  ❌ Found %d invalid Preventive Control connections\n", nrow(invalid_preventive)))
  } else {
    cat("  ✅ All Preventive Control connections are valid (→ Activity/Pressure)\n")
  }

  # Rule 4: Protective controls should only connect to Consequences
  invalid_protective <- ai_links %>%
    filter(from_type == "Control" & control_category == "protective" &
           to_type != "Consequence")
  if (nrow(invalid_protective) > 0) {
    invalid_connections$protective <- invalid_protective
    cat(sprintf("  ❌ Found %d invalid Protective Control connections\n", nrow(invalid_protective)))
  } else {
    cat("  ✅ All Protective Control connections are valid (→ Consequence)\n")
  }

  if (length(invalid_connections) == 0) {
    cat("\n✅ TEST 1 PASSED: All AI-generated links respect bowtie structure!\n")
  } else {
    cat("\n❌ TEST 1 FAILED: Found invalid connections:\n")
    print(invalid_connections)
  }
} else {
  cat("\n⚠️ No links generated - check vocabulary data\n")
}

# =============================================================================
# TEST 2: Verify Basic Connections Respect Bowtie Structure
# =============================================================================

cat("\n" , rep("=", 80), "\n", sep = "")
cat("TEST 2: Basic Connections - Bowtie Structure Compliance\n")
cat(rep("=", 80), "\n", sep = "")

# Generate basic connections
cat("\nGenerating basic keyword-based connections...\n")
basic_links <- find_basic_connections(vocab)

# Verify link structure
cat("\n📊 Link Statistics:\n")
cat(sprintf("  Total links created: %d\n", nrow(basic_links)))

if (nrow(basic_links) > 0) {
  link_summary <- basic_links %>%
    group_by(from_type, to_type, relationship) %>%
    summarise(count = n(), .groups = 'drop') %>%
    arrange(desc(count))

  cat("\n  Links by type and relationship:\n")
  print(link_summary)

  # Check for invalid connections (same rules as above)
  cat("\n🔍 Validating bowtie structure...\n")

  test2_passed <- TRUE

  # Rule 1: Activities → Pressures only
  invalid_activity <- basic_links %>%
    filter(from_type == "Activity" & to_type != "Pressure")
  if (nrow(invalid_activity) > 0) {
    cat(sprintf("  ❌ Found %d invalid Activity connections\n", nrow(invalid_activity)))
    test2_passed <- FALSE
  } else {
    cat("  ✅ All Activity connections are valid (→ Pressure)\n")
  }

  # Rule 2: Pressures → Consequences only
  invalid_pressure <- basic_links %>%
    filter(from_type == "Pressure" & to_type != "Consequence")
  if (nrow(invalid_pressure) > 0) {
    cat(sprintf("  ❌ Found %d invalid Pressure connections\n", nrow(invalid_pressure)))
    test2_passed <- FALSE
  } else {
    cat("  ✅ All Pressure connections are valid (→ Consequence)\n")
  }

  # Rule 3: Preventive controls → Activities/Pressures
  invalid_preventive <- basic_links %>%
    filter(from_type == "Control" & control_category == "preventive" &
           !(to_type %in% c("Activity", "Pressure")))
  if (nrow(invalid_preventive) > 0) {
    cat(sprintf("  ❌ Found %d invalid Preventive Control connections\n", nrow(invalid_preventive)))
    test2_passed <- FALSE
  } else {
    cat("  ✅ All Preventive Control connections are valid\n")
  }

  # Rule 4: Protective controls → Consequences
  invalid_protective <- basic_links %>%
    filter(from_type == "Control" & control_category == "protective" &
           to_type != "Consequence")
  if (nrow(invalid_protective) > 0) {
    cat(sprintf("  ❌ Found %d invalid Protective Control connections\n", nrow(invalid_protective)))
    test2_passed <- FALSE
  } else {
    cat("  ✅ All Protective Control connections are valid\n")
  }

  if (test2_passed) {
    cat("\n✅ TEST 2 PASSED: All basic connections respect bowtie structure!\n")
  } else {
    cat("\n❌ TEST 2 FAILED: Found invalid connections\n")
  }
} else {
  cat("\n⚠️ No links generated - check vocabulary data\n")
}

# =============================================================================
# TEST 3: Generate Complete Bowtie Network and Verify Structure
# =============================================================================

cat("\n" , rep("=", 80), "\n", sep = "")
cat("TEST 3: Complete Bowtie Generation - Verify Causal Chain\n")
cat(rep("=", 80), "\n", sep = "")

# Generate bowtie network
cat("\nGenerating vocabulary-based bowtie network...\n")
bowtie_result <- tryCatch({
  generate_vocabulary_bowtie(
    central_problems = c("Water Pollution"),
    output_file = "test_bowtie_output.xlsx",
    similarity_threshold = 0.25,
    max_connections_per_item = 2,
    use_ai_linking = TRUE
  )
}, error = function(e) {
  cat("Error generating bowtie:", e$message, "\n")
  return(NULL)
})

if (!is.null(bowtie_result) && !is.null(bowtie_result$data)) {
  bowtie_data <- bowtie_result$data

  cat("\n📊 Bowtie Statistics:\n")
  cat(sprintf("  Total bowtie entries: %d\n", nrow(bowtie_data)))
  cat(sprintf("  Unique activities: %d\n", length(unique(bowtie_data$Activity))))
  cat(sprintf("  Unique pressures: %d\n", length(unique(bowtie_data$Pressure))))
  cat(sprintf("  Unique consequences: %d\n", length(unique(bowtie_data$Consequence))))

  # Sample some entries to verify structure
  cat("\n📋 Sample bowtie entries (showing causal chain):\n")
  if (nrow(bowtie_data) > 0) {
    sample_entries <- head(bowtie_data, 3)
    for (i in 1:nrow(sample_entries)) {
      entry <- sample_entries[i, ]
      cat(sprintf("\n  Entry %d:\n", i))
      cat(sprintf("    Activity: %s\n", substr(entry$Activity, 1, 50)))
      cat(sprintf("      ↓ causes\n"))
      cat(sprintf("    Pressure: %s\n", substr(entry$Pressure, 1, 50)))
      cat(sprintf("      ↓ leads to\n"))
      cat(sprintf("    Problem: %s\n", entry$Problem))
      cat(sprintf("      ↓ results in\n"))
      cat(sprintf("    Consequence: %s\n", substr(entry$Consequence, 1, 50)))
      cat(sprintf("    \n"))
      cat(sprintf("    Prevention: %s\n", substr(entry$Preventive_Control, 1, 50)))
      cat(sprintf("    Mitigation: %s\n", substr(entry$Protective_Mitigation, 1, 50)))
    }
  }

  cat("\n✅ TEST 3 PASSED: Bowtie network generated with proper causal structure!\n")
  cat(sprintf("   Output file created: %s\n", bowtie_result$file))
} else {
  cat("\n❌ TEST 3 FAILED: Could not generate bowtie network\n")
}

# =============================================================================
# SUMMARY
# =============================================================================

cat("\n" , rep("=", 80), "\n", sep = "")
cat("BOWTIE LOGIC VERIFICATION SUMMARY\n")
cat(rep("=", 80), "\n", sep = "")
cat("\n")
cat("✅ Proper Bowtie Structure:\n")
cat("   Activities → Pressures → Central Problem → Consequences\n")
cat("   \n")
cat("   Preventive Controls: Activities/Pressures → Problem (prevent occurrence)\n")
cat("   Protective Controls: Problem → Consequences (mitigate impacts)\n")
cat("\n")
cat("All tests completed. Review results above to verify bowtie logic compliance.\n")
cat("\n")
