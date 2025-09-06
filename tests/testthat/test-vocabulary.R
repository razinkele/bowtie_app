# Test suite for vocabulary functions (vocabulary.r)
# Tests hierarchical data processing and vocabulary management

library(testthat)

# Mock data for testing
create_mock_vocabulary_data <- function() {
  data.frame(
    hierarchy = c("1", "1.1", "1.1.1", "1.2", "2", "2.1"),
    id = c("ACT001", "ACT002", "ACT003", "ACT004", "ACT005", "ACT006"),
    name = c("Agriculture", "Crop Production", "Fertilizer Use", "Livestock", "Industry", "Manufacturing"),
    stringsAsFactors = FALSE
  )
}

# Test hierarchical data processing
test_that("create_hierarchy_list creates proper tree structure", {
  mock_data <- create_mock_vocabulary_data()
  hierarchy_list <- create_hierarchy_list(mock_data)
  
  expect_type(hierarchy_list, "list")
  expect_true(length(hierarchy_list) > 0)
  
  # Check that top-level items exist
  top_level_ids <- c("ACT001", "ACT005")
  expect_true(any(names(hierarchy_list) %in% top_level_ids))
})

test_that("get_items_by_level returns correct items", {
  mock_data <- create_mock_vocabulary_data()
  
  level_1 <- get_items_by_level(mock_data, 1)
  expect_equal(nrow(level_1), 2) # Should return ACT001 and ACT005
  
  level_2 <- get_items_by_level(mock_data, 2)
  expect_equal(nrow(level_2), 2) # Should return ACT002 and ACT006
})

test_that("get_children returns correct children", {
  mock_data <- create_mock_vocabulary_data()
  
  # Test getting children of top-level item
  children <- get_children(mock_data, "ACT001")
  expect_true(nrow(children) > 0)
  expect_true("ACT002" %in% children$id)
})

test_that("get_item_path returns correct hierarchical path", {
  mock_data <- create_mock_vocabulary_data()
  
  path <- get_item_path(mock_data, "ACT003")
  expect_type(path, "character")
  expect_true(length(path) >= 3) # Should include full path
  expect_true("Agriculture" %in% path)
  expect_true("Crop Production" %in% path)
  expect_true("Fertilizer Use" %in% path)
})

# Test search functionality
test_that("search_vocabulary finds correct items", {
  mock_data <- create_mock_vocabulary_data()
  
  # Search by name
  results <- search_vocabulary(mock_data, "Agriculture", "name")
  expect_true(nrow(results) > 0)
  expect_true("ACT001" %in% results$id)
  
  # Search by ID
  results_id <- search_vocabulary(mock_data, "ACT001", "id")
  expect_equal(nrow(results_id), 1)
  expect_equal(results_id$id, "ACT001")
})

# Test tree structure creation
test_that("create_tree_structure creates valid tree", {
  mock_data <- create_mock_vocabulary_data()
  tree <- create_tree_structure(mock_data)
  
  expect_type(tree, "list")
  expect_true("nodes" %in% names(tree))
  expect_true("edges" %in% names(tree))
  
  # Check nodes structure
  expect_s3_class(tree$nodes, "data.frame")
  expect_true(all(c("id", "label", "level") %in% names(tree$nodes)))
  
  # Check edges structure
  expect_s3_class(tree$edges, "data.frame")
  expect_true(all(c("from", "to") %in% names(tree$edges)))
})

# Test connection finding
test_that("find_basic_connections processes vocabulary data", {
  # Create mock vocabulary data structure
  mock_vocab <- list(
    activities = create_mock_vocabulary_data(),
    pressures = create_mock_vocabulary_data(),
    consequences = create_mock_vocabulary_data(),
    controls = create_mock_vocabulary_data()
  )
  
  connections <- find_basic_connections(mock_vocab)
  
  expect_type(connections, "list")
  expect_true("summary" %in% names(connections))
})

# Test preprocessing functions (if available in vocabulary-ai-linker.r)
test_that("preprocess_text function works correctly", {
  skip_if_not(exists("preprocess_text"), "preprocess_text function not available")
  
  test_text <- "  This is a TEST string with Numbers 123  "
  result <- preprocess_text(test_text)
  
  expect_type(result, "character")
  expect_true(nchar(result) > 0)
  expect_false(grepl("^\\s|\\s$", result)) # Should not start/end with whitespace
})

test_that("extract_key_terms extracts meaningful terms", {
  skip_if_not(exists("extract_key_terms"), "extract_key_terms function not available")
  
  mock_vocab <- list(
    activities = data.frame(
      id = "ACT001",
      name = "Agricultural fertilizer application",
      stringsAsFactors = FALSE
    )
  )
  
  terms <- extract_key_terms(mock_vocab)
  
  expect_type(terms, "list")
  expect_true(length(terms) > 0)
})

# Test similarity calculations
test_that("calculate_semantic_similarity works with different methods", {
  skip_if_not(exists("calculate_semantic_similarity"), "calculate_semantic_similarity function not available")
  
  text1 <- "agricultural fertilizer runoff"
  text2 <- "farm nutrient discharge"
  
  # Test Jaccard similarity
  jaccard_sim <- calculate_semantic_similarity(text1, text2, "jaccard")
  expect_type(jaccard_sim, "double")
  expect_true(jaccard_sim >= 0 && jaccard_sim <= 1)
  
  # Test cosine similarity
  cosine_sim <- calculate_semantic_similarity(text1, text2, "cosine")
  expect_type(cosine_sim, "double")
  expect_true(cosine_sim >= -1 && cosine_sim <= 1)
})