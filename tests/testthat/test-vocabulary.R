# Test suite for vocabulary functions (vocabulary.R)
# Tests hierarchical data processing and vocabulary management

library(testthat)

# Mock data using dot-separated IDs (matches real vocabulary structure)
create_mock_vocabulary_data <- function() {
  data.frame(
    hierarchy = c("1", "1.1", "1.1.1", "1.2", "2", "2.1"),
    id = c("1", "1.1", "1.1.1", "1.2", "2", "2.1"),
    name = c("Agriculture", "Crop Production", "Fertilizer Use", "Livestock", "Industry", "Manufacturing"),
    level = c(1, 2, 3, 2, 1, 2),
    stringsAsFactors = FALSE
  )
}

# Test hierarchical data processing
test_that("create_hierarchy_list creates proper tree structure", {
  mock_data <- create_mock_vocabulary_data()
  hierarchy_list <- create_hierarchy_list(mock_data)

  expect_type(hierarchy_list, "list")
  expect_true(length(hierarchy_list) > 0)

  # Check that top-level items exist (IDs "1" and "2")
  expect_true("1" %in% names(hierarchy_list))
  expect_true("2" %in% names(hierarchy_list))
})

test_that("get_items_by_level returns correct items", {
  mock_data <- create_mock_vocabulary_data()

  level_1 <- get_items_by_level(mock_data, 1)
  expect_equal(nrow(level_1), 2) # "1" (Agriculture) and "2" (Industry)

  level_2 <- get_items_by_level(mock_data, 2)
  expect_equal(nrow(level_2), 3) # "1.1", "1.2", "2.1"

  level_3 <- get_items_by_level(mock_data, 3)
  expect_equal(nrow(level_3), 1) # "1.1.1" (Fertilizer Use)
})

test_that("get_children returns correct children", {
  mock_data <- create_mock_vocabulary_data()

  # Children of "1" (Agriculture) should be "1.1" and "1.2"
  children <- get_children(mock_data, "1")
  expect_equal(nrow(children), 3) # "1.1", "1.1.1", "1.2" (all descendants)
  expect_true("1.1" %in% children$id)
  expect_true("1.2" %in% children$id)

  # Children of "2" (Industry) should be "2.1"
  children_2 <- get_children(mock_data, "2")
  expect_equal(nrow(children_2), 1)
  expect_true("2.1" %in% children_2$id)
})

test_that("get_item_path returns correct hierarchical path", {
  mock_data <- create_mock_vocabulary_data()

  # get_item_path returns a data.frame of ancestor rows
  path <- get_item_path(mock_data, "1.1.1")
  expect_s3_class(path, "data.frame")
  expect_true(nrow(path) >= 3) # Should include 1 -> 1.1 -> 1.1.1
  expect_true("Agriculture" %in% path$name)
  expect_true("Crop Production" %in% path$name)
  expect_true("Fertilizer Use" %in% path$name)
})

# Test search functionality
test_that("search_vocabulary finds correct items", {
  mock_data <- create_mock_vocabulary_data()

  # Search by name
  results <- search_vocabulary(mock_data, "Agriculture", "name")
  expect_true(nrow(results) > 0)
  expect_true("1" %in% results$id)

  # Search by ID
  results_id <- search_vocabulary(mock_data, "1", "id")
  expect_true(nrow(results_id) >= 1)
})

# Test tree structure creation
test_that("create_tree_structure creates valid tree", {
  mock_data <- create_mock_vocabulary_data()
  tree <- create_tree_structure(mock_data)

  # create_tree_structure returns an augmented data.frame
  expect_s3_class(tree, "data.frame")
  expect_true("display" %in% names(tree))
  expect_true("path" %in% names(tree))
  expect_true("indent" %in% names(tree))

  # All original rows should be present
  expect_equal(nrow(tree), nrow(mock_data))
})

# Test connection finding
test_that("find_basic_connections processes vocabulary data", {
  # Create mock vocabulary data structure matching expected format
  mock_vocab <- list(
    activities = create_mock_vocabulary_data(),
    pressures = create_mock_vocabulary_data(),
    consequences = create_mock_vocabulary_data(),
    controls = create_mock_vocabulary_data()
  )

  connections <- find_basic_connections(mock_vocab)

  # find_basic_connections returns a data.frame of connections
  expect_s3_class(connections, "data.frame")
})

# Test preprocessing functions (if available in vocabulary_ai_linker.R)
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
      id = "1",
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
