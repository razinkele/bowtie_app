# test-ai-linker.R
# Comprehensive test suite for AI-powered vocabulary linker
# Tests all linking methods: semantic, keyword, causal, and basic

library(testthat)
library(dplyr)

context("AI-Powered Vocabulary Linker Tests")

# =============================================================================
# TEST FIXTURES AND SETUP
# =============================================================================

# Create mock vocabulary data for testing
create_test_vocabulary <- function() {
  list(
    activities = data.frame(
      id = c("ACT001", "ACT002", "ACT003", "ACT004", "ACT005"),
      name = c(
        "Commercial fishing operations",
        "Industrial wastewater discharge",
        "Agricultural fertilizer application",
        "Coastal tourism activities",
        "Marine shipping and transportation"
      ),
      level1 = rep("Activities", 5),
      level2 = c("Fishing", "Industry", "Agriculture", "Tourism", "Shipping"),
      stringsAsFactors = FALSE
    ),

    pressures = data.frame(
      id = c("PRES001", "PRES002", "PRES003", "PRES004", "PRES005"),
      name = c(
        "Overfishing and stock depletion",
        "Water pollution from industrial effluent",
        "Nutrient runoff and eutrophication",
        "Habitat disturbance and degradation",
        "Oil and chemical spills"
      ),
      level1 = rep("Pressures", 5),
      level2 = c("Fishing Impact", "Pollution", "Nutrient Loading", "Habitat Impact", "Spills"),
      stringsAsFactors = FALSE
    ),

    consequences = data.frame(
      id = c("CONS001", "CONS002", "CONS003", "CONS004", "CONS005"),
      name = c(
        "Marine biodiversity loss",
        "Fish stock collapse",
        "Water quality degradation",
        "Ecosystem service disruption",
        "Coastal habitat destruction"
      ),
      level1 = rep("Consequences", 5),
      level2 = c("Biodiversity", "Fisheries", "Water Quality", "Ecosystem", "Habitat"),
      stringsAsFactors = FALSE
    ),

    controls = data.frame(
      id = c("CTRL001", "CTRL002", "CTRL003", "CTRL004", "CTRL005"),
      name = c(
        "Fishing quota management and regulation",
        "Wastewater treatment and monitoring",
        "Fertilizer reduction and best practices",
        "Marine protected area designation",
        "Spill prevention and response systems"
      ),
      level1 = rep("Controls", 5),
      level2 = c("Fisheries Management", "Treatment", "Agriculture Management", "Protection", "Safety"),
      stringsAsFactors = FALSE
    )
  )
}

# =============================================================================
# TEST: MODULE LOADING AND INITIALIZATION
# =============================================================================

test_that("AI linker module loads successfully", {
  # Source the AI linker
  expect_silent(source("../../vocabulary_ai_linker.R", local = TRUE))

  # Check that key functions are defined
  expect_true(exists("find_vocabulary_links"))
  expect_true(exists("find_basic_connections"))
  expect_true(exists("detect_causal_relationships"))
  expect_true(exists("calculate_semantic_similarity"))

  # Check that capabilities are defined
  expect_true(exists("AI_LINKER_CAPABILITIES"))
  expect_type(AI_LINKER_CAPABILITIES, "list")
})

test_that("AI linker capabilities are properly initialized", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  # Check capability flags exist
  expect_true("text_mining" %in% names(AI_LINKER_CAPABILITIES))
  expect_true("string_distance" %in% names(AI_LINKER_CAPABILITIES))
  expect_true("basic_only" %in% names(AI_LINKER_CAPABILITIES))

  # All flags should be logical
  expect_type(AI_LINKER_CAPABILITIES$text_mining, "logical")
  expect_type(AI_LINKER_CAPABILITIES$string_distance, "logical")
  expect_type(AI_LINKER_CAPABILITIES$basic_only, "logical")
})

test_that("Environmental domain knowledge is properly defined", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  # Check that theme constants exist
  expect_true(exists("ENVIRONMENTAL_THEMES"))
  expect_type(ENVIRONMENTAL_THEMES, "list")

  # Check key themes exist
  expect_true("water" %in% names(ENVIRONMENTAL_THEMES))
  expect_true("pollution" %in% names(ENVIRONMENTAL_THEMES))
  expect_true("ecosystem" %in% names(ENVIRONMENTAL_THEMES))
  expect_true("fisheries" %in% names(ENVIRONMENTAL_THEMES))

  # Check theme structure
  water_theme <- ENVIRONMENTAL_THEMES$water
  expect_true("keywords" %in% names(water_theme))
  expect_true("strength" %in% names(water_theme))
  expect_type(water_theme$keywords, "character")
  expect_type(water_theme$strength, "double")
})

# =============================================================================
# TEST: BASIC LINKING FUNCTIONALITY
# =============================================================================

test_that("find_basic_connections works with valid vocabulary data", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  # Run basic connections
  result <- find_basic_connections(vocab_data, max_links_per_item = 5)

  # Check result structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) >= 0)

  # If links found, check structure
  if (nrow(result) > 0) {
    expected_cols <- c("from_id", "from_name", "from_type", "to_id", "to_name", "to_type", "similarity", "method")
    expect_true(all(expected_cols %in% names(result)))

    # Check similarity scores are in valid range
    expect_true(all(result$similarity >= 0))
    expect_true(all(result$similarity <= 1))

    # Check that links are between different types
    expect_true(all(result$from_type != result$to_type))
  }
})

test_that("find_basic_connections handles empty vocabulary gracefully", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  empty_vocab <- list(
    activities = data.frame(id = character(0), name = character(0), stringsAsFactors = FALSE),
    pressures = data.frame(id = character(0), name = character(0), stringsAsFactors = FALSE),
    consequences = data.frame(id = character(0), name = character(0), stringsAsFactors = FALSE),
    controls = data.frame(id = character(0), name = character(0), stringsAsFactors = FALSE)
  )

  # Should return empty dataframe without error
  result <- find_basic_connections(empty_vocab)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("find_basic_connections validates input data", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  # Test NULL input
  expect_warning(result <- find_basic_connections(NULL))
  expect_equal(nrow(result), 0)

  # Test missing components
  incomplete_vocab <- list(
    activities = data.frame(id = "A1", name = "Activity 1", stringsAsFactors = FALSE)
    # Missing pressures, consequences, controls
  )

  expect_warning(result <- find_basic_connections(incomplete_vocab))
})

# =============================================================================
# TEST: SEMANTIC SIMILARITY CALCULATION
# =============================================================================

test_that("calculate_semantic_similarity returns valid scores", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  # Test identical texts
  sim1 <- calculate_semantic_similarity("fishing operations", "fishing operations", method = "jaccard")
  expect_equal(sim1, 1.0)

  # Test completely different texts
  sim2 <- calculate_semantic_similarity("fishing", "agriculture", method = "jaccard")
  expect_true(sim2 >= 0 && sim2 <= 1)

  # Test partial overlap
  sim3 <- calculate_semantic_similarity("marine fishing", "fishing operations", method = "jaccard")
  expect_true(sim3 > 0 && sim3 < 1)
})

test_that("calculate_semantic_similarity handles edge cases", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  # Empty strings
  expect_equal(calculate_semantic_similarity("", "", method = "jaccard"), 0)

  # NULL inputs
  expect_equal(calculate_semantic_similarity(NULL, "test", method = "jaccard"), 0)
  expect_equal(calculate_semantic_similarity("test", NULL, method = "jaccard"), 0)

  # NA inputs
  expect_equal(calculate_semantic_similarity(NA_character_, "test", method = "jaccard"), 0)
})

test_that("calculate_semantic_similarity supports multiple methods", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  text1 <- "commercial fishing operations"
  text2 <- "fishing commercial activities"

  # Jaccard similarity
  sim_jaccard <- calculate_semantic_similarity(text1, text2, method = "jaccard")
  expect_true(sim_jaccard >= 0 && sim_jaccard <= 1)

  # Cosine similarity
  sim_cosine <- calculate_semantic_similarity(text1, text2, method = "cosine")
  expect_true(sim_cosine >= 0 && sim_cosine <= 1)

  # Both should detect high similarity
  expect_true(sim_jaccard > 0.5)
  expect_true(sim_cosine > 0.5)
})

# =============================================================================
# TEST: CAUSAL RELATIONSHIP DETECTION
# =============================================================================

test_that("detect_causal_relationships finds Activity->Pressure links", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  # Run causal detection
  result <- detect_causal_relationships(vocab_data, use_domain_knowledge = TRUE)

  # Should find some causal links
  expect_s3_class(result, "data.frame")

  if (nrow(result) > 0) {
    # Check for Activity -> Pressure links
    ap_links <- result[result$from_type == "Activity" & result$to_type == "Pressure", ]

    if (nrow(ap_links) > 0) {
      # Should have expected structure
      expect_true("causal_type" %in% names(ap_links))
      expect_true(all(ap_links$causal_type == "activity_pressure"))

      # Method should indicate causal analysis
      expect_true(all(grepl("causal", ap_links$method)))

      # Similarity scores should be reasonable
      expect_true(all(ap_links$similarity > 0))
      expect_true(all(ap_links$similarity <= 1))
    }
  }
})

test_that("detect_causal_relationships finds Pressure->Consequence links", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  result <- detect_causal_relationships(vocab_data, use_domain_knowledge = TRUE)

  if (nrow(result) > 0) {
    # Check for Pressure -> Consequence links
    pc_links <- result[result$from_type == "Pressure" & result$to_type == "Consequence", ]

    if (nrow(pc_links) > 0) {
      expect_true(all(pc_links$causal_type == "pressure_consequence"))
      expect_true(all(grepl("causal", pc_links$method)))
    }
  }
})

test_that("detect_causal_relationships finds Control interventions", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  result <- detect_causal_relationships(vocab_data, use_domain_knowledge = TRUE)

  if (nrow(result) > 0) {
    # Check for Control -> Pressure links
    cp_links <- result[result$from_type == "Control" & result$to_type == "Pressure", ]

    if (nrow(cp_links) > 0) {
      expect_true(all(cp_links$causal_type == "control_pressure"))
      expect_true(all(grepl("intervention", cp_links$method)))
    }
  }
})

test_that("detect_causal_relationships domain knowledge improves results", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  # Run with domain knowledge
  result_with_dk <- detect_causal_relationships(vocab_data, use_domain_knowledge = TRUE)

  # Run without domain knowledge
  result_without_dk <- detect_causal_relationships(vocab_data, use_domain_knowledge = FALSE)

  # With domain knowledge should find more or equal links
  expect_true(nrow(result_with_dk) >= nrow(result_without_dk))
})

# =============================================================================
# TEST: KEYWORD-BASED CONNECTIONS
# =============================================================================

test_that("find_keyword_connections identifies thematic links", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  result <- find_keyword_connections(vocab_data, ENVIRONMENTAL_THEMES)

  expect_s3_class(result, "data.frame")

  if (nrow(result) > 0) {
    # Should have keyword-based methods
    expect_true(any(grepl("keyword", result$method)))

    # Check similarity scores match theme strengths
    expect_true(all(result$similarity >= 0.5))  # Theme strengths are typically 0.6-0.8
    expect_true(all(result$similarity <= 1))
  }
})

test_that("find_keyword_connections handles missing themes gracefully", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  # Use empty themes list
  result <- find_keyword_connections(vocab_data, themes = list())

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

# =============================================================================
# TEST: MAIN LINKING FUNCTION
# =============================================================================

test_that("find_vocabulary_links returns proper structure", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  result <- find_vocabulary_links(
    vocab_data,
    similarity_threshold = 0.3,
    max_links_per_item = 5,
    methods = c("jaccard", "keyword", "causal")
  )

  # Check result is a list with expected components
  expect_type(result, "list")
  expect_true("links" %in% names(result))
  expect_true("summary" %in% names(result))
  expect_true("capabilities" %in% names(result))
  expect_true("methods_used" %in% names(result))
  expect_true("parameters" %in% names(result))

  # Check links dataframe
  expect_s3_class(result$links, "data.frame")

  # Check summary dataframe
  expect_s3_class(result$summary, "data.frame")

  # Check parameters captured
  expect_equal(result$parameters$similarity_threshold, 0.3)
  expect_equal(result$parameters$max_links_per_item, 5)
})

test_that("find_vocabulary_links respects max_links_per_item parameter", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  max_links <- 3
  result <- find_vocabulary_links(
    vocab_data,
    similarity_threshold = 0.2,  # Lower threshold to get more links
    max_links_per_item = max_links,
    methods = c("jaccard", "keyword", "causal")
  )

  if (nrow(result$links) > 0) {
    # Count links per source item
    links_per_item <- result$links %>%
      group_by(from_id) %>%
      summarise(count = n(), .groups = 'drop')

    # No item should have more than max_links
    expect_true(all(links_per_item$count <= max_links))
  }
})

test_that("find_vocabulary_links handles individual methods correctly", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  # Test each method individually
  methods_to_test <- c("jaccard", "keyword", "causal", "basic")

  for (method in methods_to_test) {
    result <- find_vocabulary_links(
      vocab_data,
      methods = method,
      similarity_threshold = 0.3
    )

    expect_type(result, "list")
    expect_true("links" %in% names(result))
    expect_true(method %in% result$methods_used)

    # If links found, check they use appropriate method
    if (nrow(result$links) > 0) {
      # Method name should appear in the links
      if (method != "basic") {
        expect_true(any(grepl(method, result$links$method)))
      }
    }
  }
})

test_that("find_vocabulary_links validates input parameters", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  # Test invalid methods
  expect_warning({
    result <- find_vocabulary_links(vocab_data, methods = c("invalid_method", "jaccard"))
  })

  # Should fall back to valid methods
  expect_true("jaccard" %in% result$methods_used)
  expect_false("invalid_method" %in% result$methods_used)
})

test_that("find_vocabulary_links handles NULL/invalid vocabulary data", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  # NULL input should error
  expect_error(find_vocabulary_links(NULL))

  # Non-list input should error
  expect_error(find_vocabulary_links("not a list"))
})

# =============================================================================
# TEST: INTEGRATION AND END-TO-END SCENARIOS
# =============================================================================

test_that("Complete workflow: link generation to analysis", {
  source("../../vocabulary_ai_linker.R", local = TRUE)
  vocab_data <- create_test_vocabulary()

  # Step 1: Generate links using all methods
  result <- find_vocabulary_links(
    vocab_data,
    similarity_threshold = 0.3,
    max_links_per_item = 5,
    methods = c("jaccard", "keyword", "causal")
  )

  # Step 2: Verify we got results
  expect_true(nrow(result$links) > 0)

  # Step 3: Check summary statistics
  if (nrow(result$summary) > 0) {
    expect_true("from_type" %in% names(result$summary))
    expect_true("to_type" %in% names(result$summary))
    expect_true("count" %in% names(result$summary))
    expect_true("avg_similarity" %in% names(result$summary))

    # Counts should match links
    total_from_summary <- sum(result$summary$count)
    expect_equal(total_from_summary, nrow(result$links))
  }

  # Step 4: Verify causal summary if causal method used
  if (!is.null(result$causal_summary)) {
    expect_s3_class(result$causal_summary, "data.frame")
    expect_true(all(grepl("causal", result$causal_summary$method)))
  }
})

test_that("Realistic scenario: Marine pollution bowtie network", {
  source("../../vocabulary_ai_linker.R", local = TRUE)

  # Create realistic marine pollution scenario
  marine_vocab <- list(
    activities = data.frame(
      id = c("A1", "A2", "A3"),
      name = c(
        "Industrial wastewater discharge into coastal waters",
        "Marine shipping and oil transportation",
        "Coastal urban development and construction"
      ),
      stringsAsFactors = FALSE
    ),

    pressures = data.frame(
      id = c("P1", "P2", "P3"),
      name = c(
        "Chemical pollution and contamination of marine ecosystems",
        "Oil spills and petroleum-based pollution",
        "Nutrient loading and eutrophication in coastal zones"
      ),
      stringsAsFactors = FALSE
    ),

    consequences = data.frame(
      id = c("C1", "C2", "C3"),
      name = c(
        "Marine biodiversity loss and species decline",
        "Water quality degradation and ecosystem health impacts",
        "Coastal fishery collapse and economic losses"
      ),
      stringsAsFactors = FALSE
    ),

    controls = data.frame(
      id = c("CT1", "CT2", "CT3"),
      name = c(
        "Wastewater treatment and pollution prevention systems",
        "Oil spill response and containment measures",
        "Coastal zone management and protection regulations"
      ),
      stringsAsFactors = FALSE
    )
  )

  # Generate links
  result <- find_vocabulary_links(
    marine_vocab,
    similarity_threshold = 0.3,
    max_links_per_item = 5,
    methods = c("jaccard", "keyword", "causal")
  )

  # Should find meaningful connections
  expect_true(nrow(result$links) > 0)

  # Should have Activity->Pressure links (causal pathway)
  ap_links <- result$links %>%
    filter(from_type == "Activity", to_type == "Pressure")
  expect_true(nrow(ap_links) > 0)

  # Should have Pressure->Consequence links
  pc_links <- result$links %>%
    filter(from_type == "Pressure", to_type == "Consequence")
  expect_true(nrow(pc_links) > 0)

  # Should have Control interventions
  control_links <- result$links %>%
    filter(from_type == "Control")
  expect_true(nrow(control_links) > 0)

  # Verify domain knowledge detected pollution theme
  pollution_links <- result$links %>%
    filter(grepl("pollution|water|marine", method, ignore.case = TRUE))

  # Should have detected pollution-related connections
  expect_true(nrow(pollution_links) > 0)
})

# =============================================================================
# TEST: PERFORMANCE AND SCALABILITY
# =============================================================================

test_that("AI linker handles large vocabulary datasets efficiently", {
  skip_if_not_installed("microbenchmark")

  source("../../vocabulary_ai_linker.R", local = TRUE)

  # Create larger vocabulary (50 items each)
  large_vocab <- list(
    activities = data.frame(
      id = paste0("A", 1:50),
      name = paste("Activity", 1:50, sample(c("fishing", "pollution", "agriculture", "industry"), 50, replace = TRUE)),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      id = paste0("P", 1:50),
      name = paste("Pressure", 1:50, sample(c("contamination", "degradation", "depletion", "impact"), 50, replace = TRUE)),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      id = paste0("C", 1:50),
      name = paste("Consequence", 1:50, sample(c("loss", "decline", "damage", "collapse"), 50, replace = TRUE)),
      stringsAsFactors = FALSE
    ),
    controls = data.frame(
      id = paste0("CT", 1:50),
      name = paste("Control", 1:50, sample(c("prevention", "treatment", "regulation", "protection"), 50, replace = TRUE)),
      stringsAsFactors = FALSE
    )
  )

  # Benchmark performance
  execution_time <- system.time({
    result <- find_vocabulary_links(
      large_vocab,
      similarity_threshold = 0.3,
      max_links_per_item = 5,
      methods = c("basic")  # Use basic for consistent performance
    )
  })

  # Should complete in reasonable time (< 30 seconds for 200 items)
  expect_true(execution_time[["elapsed"]] < 30)

  # Should still produce results
  expect_true(nrow(result$links) > 0)
})

# =============================================================================
# TEST SUMMARY
# =============================================================================

cat("\n✅ AI Linker Test Suite Complete\n")
cat("==================================\n")
cat("Tested:\n")
cat("  ✓ Module loading and initialization\n")
cat("  ✓ Basic connection finding\n")
cat("  ✓ Semantic similarity calculation\n")
cat("  ✓ Causal relationship detection\n")
cat("  ✓ Keyword-based thematic linking\n")
cat("  ✓ Main linking function integration\n")
cat("  ✓ End-to-end workflow scenarios\n")
cat("  ✓ Performance and scalability\n\n")
