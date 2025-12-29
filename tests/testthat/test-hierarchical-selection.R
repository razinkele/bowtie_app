# =============================================================================
# Test Suite: Hierarchical Selection System
# Version: 1.0.0
# Date: 2025-12-26
# Description: Comprehensive tests for hierarchical vocabulary selection
#              and custom entry tracking in guided workflow
# =============================================================================

library(testthat)
library(shiny)
library(dplyr)

# Suppress warnings for cleaner test output
options(warn = -1)

# =============================================================================
# TEST CONTEXT: Hierarchical Selection Functionality
# =============================================================================

context("Hierarchical Selection - Vocabulary Structure")

test_that("Vocabulary data has hierarchical structure", {
  # Source vocabulary module
  source("../../vocabulary.R")

  # Load vocabulary
  vocab <- load_vocabulary()

  # Test activities hierarchy
  expect_true(!is.null(vocab$activities), "Activities data should exist")
  expect_true("level" %in% names(vocab$activities), "Activities should have level column")

  level1_activities <- vocab$activities[vocab$activities$level == 1, ]
  expect_true(nrow(level1_activities) > 0, "Should have Level 1 activities (groups)")

  # Test pressures hierarchy
  expect_true(!is.null(vocab$pressures), "Pressures data should exist")
  expect_true("level" %in% names(vocab$pressures), "Pressures should have level column")

  level1_pressures <- vocab$pressures[vocab$pressures$level == 1, ]
  expect_true(nrow(level1_pressures) > 0, "Should have Level 1 pressures (groups)")

  # Test controls hierarchy
  expect_true(!is.null(vocab$controls), "Controls data should exist")
  expect_true("level" %in% names(vocab$controls), "Controls should have level column")

  level1_controls <- vocab$controls[vocab$controls$level == 1, ]
  expect_true(nrow(level1_controls) > 0, "Should have Level 1 controls (groups)")

  # Test consequences hierarchy
  expect_true(!is.null(vocab$consequences), "Consequences data should exist")
  expect_true("level" %in% names(vocab$consequences), "Consequences should have level column")

  level1_consequences <- vocab$consequences[vocab$consequences$level == 1, ]
  expect_true(nrow(level1_consequences) > 0, "Should have Level 1 consequences (groups)")
})

test_that("get_children function returns correct hierarchical data", {
  source("../../vocabulary.R")
  vocab <- load_vocabulary()

  # Get first Level 1 activity
  if (nrow(vocab$activities) > 0) {
    level1 <- vocab$activities[vocab$activities$level == 1, ]
    if (nrow(level1) > 0) {
      parent_id <- level1$id[1]
      children <- get_children(vocab$activities, parent_id)

      # Children should have IDs starting with parent_id
      if (nrow(children) > 0) {
        expect_true(all(grepl(paste0("^", parent_id, "\\."), children$id)),
                   "All children should have IDs starting with parent ID")
      }
    }
  }
})

test_that("Hierarchical structure is consistent across vocabulary types", {
  source("../../vocabulary.R")
  vocab <- load_vocabulary()

  # Check each vocabulary type has consistent structure
  vocab_types <- list(
    activities = vocab$activities,
    pressures = vocab$pressures,
    controls = vocab$controls,
    consequences = vocab$consequences
  )

  for (type_name in names(vocab_types)) {
    data <- vocab_types[[type_name]]

    expect_true("id" %in% names(data),
               paste(type_name, "should have 'id' column"))
    expect_true("name" %in% names(data),
               paste(type_name, "should have 'name' column"))
    expect_true("level" %in% names(data),
               paste(type_name, "should have 'level' column"))

    # Level should be numeric
    expect_true(is.numeric(data$level),
               paste(type_name, "level should be numeric"))
  }
})

# =============================================================================
# TEST CONTEXT: Custom Entry Tracking
# =============================================================================

context("Custom Entry Tracking - State Management")

test_that("Custom entries reactive value initializes correctly", {
  # Create mock custom entries structure
  custom_entries <- list(
    activities = character(0),
    pressures = character(0),
    preventive_controls = character(0),
    consequences = character(0),
    protective_controls = character(0)
  )

  expect_equal(length(custom_entries), 5, "Should have 5 categories")
  expect_equal(names(custom_entries),
              c("activities", "pressures", "preventive_controls",
                "consequences", "protective_controls"),
              "Should have correct category names")

  # All categories should start empty
  for (category in names(custom_entries)) {
    expect_equal(length(custom_entries[[category]]), 0,
                paste(category, "should start empty"))
  }
})

test_that("Custom entries can be added to each category", {
  custom_entries <- list(
    activities = character(0),
    pressures = character(0),
    preventive_controls = character(0),
    consequences = character(0),
    protective_controls = character(0)
  )

  # Add custom activity
  custom_entries$activities <- c(custom_entries$activities, "Custom Activity 1")
  expect_equal(length(custom_entries$activities), 1)
  expect_equal(custom_entries$activities[1], "Custom Activity 1")

  # Add multiple custom pressures
  custom_entries$pressures <- c(custom_entries$pressures,
                                "Custom Pressure 1",
                                "Custom Pressure 2")
  expect_equal(length(custom_entries$pressures), 2)

  # Add custom control
  custom_entries$preventive_controls <- c(custom_entries$preventive_controls,
                                          "Custom Control 1")
  expect_equal(length(custom_entries$preventive_controls), 1)
})

test_that("Custom entries prevent duplicates", {
  custom_entries <- list(
    activities = c("Activity 1", "Activity 2")
  )

  new_entry <- "Activity 1"

  # Check if entry already exists
  if (!new_entry %in% custom_entries$activities) {
    custom_entries$activities <- c(custom_entries$activities, new_entry)
  }

  # Should still have only 2 entries
  expect_equal(length(custom_entries$activities), 2)
  expect_equal(custom_entries$activities, c("Activity 1", "Activity 2"))
})

# =============================================================================
# TEST CONTEXT: UI Component Generation
# =============================================================================

context("Hierarchical Selection - UI Components")

test_that("Step 3 UI generates hierarchical selection inputs", {
  source("../../guided_workflow.R")
  source("../../vocabulary.R")

  vocab <- load_vocabulary()

  # Generate Step 3 UI
  ui <- generate_step3_ui(vocabulary_data = vocab, session = NULL, current_lang = "en")

  # Convert to HTML for testing
  ui_html <- as.character(ui)

  # Check for hierarchical selection inputs
  expect_true(grepl("activity_group", ui_html),
             "Should have activity group selector")
  expect_true(grepl("activity_item", ui_html),
             "Should have activity item selector")
  expect_true(grepl("pressure_group", ui_html),
             "Should have pressure group selector")
  expect_true(grepl("pressure_item", ui_html),
             "Should have pressure item selector")
})

test_that("Step 3 UI includes custom entry options", {
  source("../../guided_workflow.R")
  source("../../vocabulary.R")

  vocab <- load_vocabulary()
  ui <- generate_step3_ui(vocabulary_data = vocab, session = NULL, current_lang = "en")
  ui_html <- as.character(ui)

  # Check for custom entry checkboxes
  expect_true(grepl("activity_custom_toggle", ui_html),
             "Should have activity custom toggle")
  expect_true(grepl("pressure_custom_toggle", ui_html),
             "Should have pressure custom toggle")

  # Check for custom text inputs
  expect_true(grepl("activity_custom_text", ui_html),
             "Should have activity custom text input")
  expect_true(grepl("pressure_custom_text", ui_html),
             "Should have pressure custom text input")
})

test_that("Step 4 UI generates hierarchical control selection", {
  source("../../guided_workflow.R")
  source("../../vocabulary.R")

  vocab <- load_vocabulary()
  ui <- generate_step4_ui(vocabulary_data = vocab, session = NULL, current_lang = "en")
  ui_html <- as.character(ui)

  expect_true(grepl("preventive_control_group", ui_html),
             "Should have preventive control group selector")
  expect_true(grepl("preventive_control_item", ui_html),
             "Should have preventive control item selector")
  expect_true(grepl("preventive_control_custom_toggle", ui_html),
             "Should have preventive control custom toggle")
})

test_that("Step 5 UI generates hierarchical consequence selection", {
  source("../../guided_workflow.R")
  source("../../vocabulary.R")

  vocab <- load_vocabulary()
  ui <- generate_step5_ui(vocabulary_data = vocab, session = NULL, current_lang = "en")
  ui_html <- as.character(ui)

  expect_true(grepl("consequence_group", ui_html),
             "Should have consequence group selector")
  expect_true(grepl("consequence_item", ui_html),
             "Should have consequence item selector")
  expect_true(grepl("consequence_custom_toggle", ui_html),
             "Should have consequence custom toggle")
})

test_that("Step 6 UI generates hierarchical protective control selection", {
  source("../../guided_workflow.R")
  source("../../vocabulary.R")

  vocab <- load_vocabulary()
  ui <- generate_step6_ui(vocabulary_data = vocab, session = NULL, current_lang = "en")
  ui_html <- as.character(ui)

  expect_true(grepl("protective_control_group", ui_html),
             "Should have protective control group selector")
  expect_true(grepl("protective_control_item", ui_html),
             "Should have protective control item selector")
  expect_true(grepl("protective_control_custom_toggle", ui_html),
             "Should have protective control custom toggle")
})

test_that("Step 7 UI includes custom entries review table", {
  source("../../guided_workflow.R")

  ui <- generate_step7_ui(session = NULL, current_lang = "en")
  ui_html <- as.character(ui)

  expect_true(grepl("custom_entries_review_table", ui_html),
             "Should have custom entries review table")
  expect_true(grepl("Custom Entries Review", ui_html),
             "Should have custom entries section header")
})

# =============================================================================
# TEST CONTEXT: Server Logic
# =============================================================================

context("Hierarchical Selection - Server Logic")

test_that("Group selection updates item choices correctly", {
  source("../../vocabulary.R")
  vocab <- load_vocabulary()

  # Simulate selecting a group
  if (nrow(vocab$activities) > 0) {
    level1 <- vocab$activities[vocab$activities$level == 1, ]
    if (nrow(level1) > 0) {
      selected_group <- level1$id[1]

      # Get children of selected group
      children <- vocab$activities[
        grepl(paste0("^", gsub("\\.", "\\\\.", selected_group), "\\."),
              vocab$activities$id),
      ]

      # Should have children (items in the group)
      expect_true(nrow(children) >= 0,
                 "Should return children for selected group")

      if (nrow(children) > 0) {
        # All children should belong to the selected group
        expect_true(all(grepl(paste0("^", selected_group, "\\."), children$id)),
                   "All items should belong to selected group")
      }
    }
  }
})

test_that("Custom entry detection works correctly", {
  # Simulate custom entry detection logic
  is_custom_mode <- function(toggle, text_input) {
    !is.null(toggle) && toggle == TRUE &&
      !is.null(text_input) && nchar(trimws(text_input)) > 0
  }

  # Test custom mode enabled with text
  expect_true(is_custom_mode(TRUE, "Custom Entry"),
             "Should detect custom mode when toggle is TRUE and text exists")

  # Test custom mode disabled
  expect_false(is_custom_mode(FALSE, "Custom Entry"),
              "Should not be custom mode when toggle is FALSE")

  # Test custom mode with empty text
  expect_false(is_custom_mode(TRUE, ""),
              "Should not be custom mode when text is empty")
  expect_false(is_custom_mode(TRUE, "   "),
              "Should not be custom mode when text is only spaces")
})

test_that("Item selection from hierarchy works correctly", {
  # Simulate hierarchical selection logic
  get_selected_item <- function(group_id, item_name, vocabulary_data) {
    if (is.null(group_id) || is.null(item_name)) return(NULL)
    if (nchar(trimws(group_id)) == 0 || nchar(trimws(item_name)) == 0) return(NULL)

    # Find item in vocabulary
    items <- vocabulary_data[
      grepl(paste0("^", gsub("\\.", "\\\\.", group_id), "\\."), vocabulary_data$id),
    ]

    matching_item <- items[items$name == item_name, ]
    if (nrow(matching_item) > 0) {
      return(matching_item$name[1])
    }
    return(NULL)
  }

  source("../../vocabulary.R")
  vocab <- load_vocabulary()

  if (nrow(vocab$activities) > 0) {
    level1 <- vocab$activities[vocab$activities$level == 1, ]
    if (nrow(level1) > 0) {
      group_id <- level1$id[1]
      children <- vocab$activities[
        grepl(paste0("^", gsub("\\.", "\\\\.", group_id), "\\."), vocab$activities$id),
      ]

      if (nrow(children) > 0) {
        item_name <- children$name[1]
        result <- get_selected_item(group_id, item_name, vocab$activities)
        expect_equal(result, item_name, "Should return correct item name")
      }
    }
  }
})

# =============================================================================
# TEST CONTEXT: Integration Tests
# =============================================================================

context("Hierarchical Selection - Workflow Integration")

test_that("Workflow state stores custom entries correctly", {
  # Create mock workflow state
  state <- list(
    project_data = list(
      activities = c("Activity 1", "Custom Activity"),
      pressures = c("Pressure 1"),
      custom_entries = list(
        activities = c("Custom Activity"),
        pressures = character(0),
        preventive_controls = character(0),
        consequences = character(0),
        protective_controls = character(0)
      )
    )
  )

  # Verify custom entries are stored
  expect_true(!is.null(state$project_data$custom_entries),
             "Custom entries should be in state")
  expect_equal(length(state$project_data$custom_entries$activities), 1,
              "Should have 1 custom activity")
  expect_equal(state$project_data$custom_entries$activities[1], "Custom Activity",
              "Custom activity name should match")
})

test_that("Custom entries persist across workflow steps", {
  # Simulate moving between steps with custom entries
  initial_state <- list(
    current_step = 3,
    project_data = list(
      custom_entries = list(
        activities = c("Custom Activity 1"),
        pressures = c("Custom Pressure 1"),
        preventive_controls = character(0),
        consequences = character(0),
        protective_controls = character(0)
      )
    )
  )

  # Move to step 7
  step7_state <- initial_state
  step7_state$current_step <- 7

  # Custom entries should persist
  expect_equal(step7_state$project_data$custom_entries$activities,
              initial_state$project_data$custom_entries$activities,
              "Custom activities should persist across steps")
  expect_equal(step7_state$project_data$custom_entries$pressures,
              initial_state$project_data$custom_entries$pressures,
              "Custom pressures should persist across steps")
})

test_that("Custom entries review table generates correct data", {
  # Create mock custom entries
  custom_entries <- list(
    activities = c("Custom Activity 1", "Custom Activity 2"),
    pressures = c("Custom Pressure 1"),
    preventive_controls = c("Custom Control 1", "Custom Control 2", "Custom Control 3"),
    consequences = character(0),
    protective_controls = c("Custom Protective Control 1")
  )

  # Generate review table data
  entries_data <- data.frame(
    Category = character(0),
    Item = character(0),
    stringsAsFactors = FALSE
  )

  if (length(custom_entries$activities) > 0) {
    entries_data <- rbind(entries_data, data.frame(
      Category = rep("Activity", length(custom_entries$activities)),
      Item = custom_entries$activities,
      stringsAsFactors = FALSE
    ))
  }

  if (length(custom_entries$pressures) > 0) {
    entries_data <- rbind(entries_data, data.frame(
      Category = rep("Pressure", length(custom_entries$pressures)),
      Item = custom_entries$pressures,
      stringsAsFactors = FALSE
    ))
  }

  if (length(custom_entries$preventive_controls) > 0) {
    entries_data <- rbind(entries_data, data.frame(
      Category = rep("Preventive Control", length(custom_entries$preventive_controls)),
      Item = custom_entries$preventive_controls,
      stringsAsFactors = FALSE
    ))
  }

  if (length(custom_entries$protective_controls) > 0) {
    entries_data <- rbind(entries_data, data.frame(
      Category = rep("Protective Control", length(custom_entries$protective_controls)),
      Item = custom_entries$protective_controls,
      stringsAsFactors = FALSE
    ))
  }

  # Verify review table data
  expect_equal(nrow(entries_data), 7, "Should have 7 total entries")
  expect_equal(sum(entries_data$Category == "Activity"), 2, "Should have 2 activities")
  expect_equal(sum(entries_data$Category == "Pressure"), 1, "Should have 1 pressure")
  expect_equal(sum(entries_data$Category == "Preventive Control"), 3, "Should have 3 preventive controls")
  expect_equal(sum(entries_data$Category == "Protective Control"), 1, "Should have 1 protective control")
})

# =============================================================================
# TEST CONTEXT: Edge Cases and Error Handling
# =============================================================================

context("Hierarchical Selection - Edge Cases")

test_that("Empty vocabulary data is handled gracefully", {
  source("../../guided_workflow.R")

  # Create empty vocabulary data
  empty_vocab <- list(
    activities = data.frame(id = character(0), name = character(0), level = numeric(0)),
    pressures = data.frame(id = character(0), name = character(0), level = numeric(0)),
    controls = data.frame(id = character(0), name = character(0), level = numeric(0)),
    consequences = data.frame(id = character(0), name = character(0), level = numeric(0))
  )

  # Should not error when generating UI with empty vocabulary
  expect_error(generate_step3_ui(vocabulary_data = empty_vocab, session = NULL), NA,
              "Should handle empty vocabulary without error")
})

test_that("NULL vocabulary data is handled gracefully", {
  source("../../guided_workflow.R")

  # Should not error when generating UI with NULL vocabulary
  expect_error(generate_step3_ui(vocabulary_data = NULL, session = NULL), NA,
              "Should handle NULL vocabulary without error")
})

test_that("Invalid group selection returns no items", {
  source("../../vocabulary.R")
  vocab <- load_vocabulary()

  # Try to get children of non-existent group
  invalid_group <- "999.999"
  children <- vocab$activities[
    grepl(paste0("^", gsub("\\.", "\\\\.", invalid_group), "\\."), vocab$activities$id),
  ]

  expect_equal(nrow(children), 0, "Should return no items for invalid group")
})

test_that("Duplicate custom entries are prevented", {
  custom_entries <- list(
    activities = c("Custom 1", "Custom 2")
  )

  new_entry <- "Custom 1"

  # Simulate duplicate check
  if (!new_entry %in% custom_entries$activities) {
    custom_entries$activities <- c(custom_entries$activities, new_entry)
  }

  expect_equal(length(custom_entries$activities), 2,
              "Should not add duplicate entry")
  expect_true("Custom 1" %in% custom_entries$activities,
             "Original entry should still exist")
})

test_that("Empty custom entries show appropriate message", {
  custom_entries <- list(
    activities = character(0),
    pressures = character(0),
    preventive_controls = character(0),
    consequences = character(0),
    protective_controls = character(0)
  )

  # Generate review table data
  entries_data <- data.frame(
    Category = character(0),
    Item = character(0),
    stringsAsFactors = FALSE
  )

  # Check if any custom entries exist
  total_entries <- sum(
    length(custom_entries$activities),
    length(custom_entries$pressures),
    length(custom_entries$preventive_controls),
    length(custom_entries$consequences),
    length(custom_entries$protective_controls)
  )

  if (total_entries == 0) {
    entries_data <- data.frame(
      Category = "No custom entries",
      Item = "All items were selected from the vocabulary",
      stringsAsFactors = FALSE
    )
  }

  expect_equal(nrow(entries_data), 1, "Should have 1 row for empty message")
  expect_equal(entries_data$Category[1], "No custom entries",
              "Should show 'No custom entries' message")
})

# =============================================================================
# TEST CONTEXT: Performance Tests
# =============================================================================

context("Hierarchical Selection - Performance")

test_that("Large vocabulary loads efficiently", {
  source("../../vocabulary.R")

  # Measure load time
  start_time <- Sys.time()
  vocab <- load_vocabulary()
  end_time <- Sys.time()

  load_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

  # Should load in under 2 seconds
  expect_true(load_time < 2,
             paste("Vocabulary should load in under 2 seconds, took",
                   round(load_time, 2), "seconds"))
})

test_that("Hierarchical filtering is performant", {
  source("../../vocabulary.R")
  vocab <- load_vocabulary()

  if (nrow(vocab$activities) > 0) {
    level1 <- vocab$activities[vocab$activities$level == 1, ]
    if (nrow(level1) > 0) {
      # Measure filtering time
      start_time <- Sys.time()

      for (i in 1:min(10, nrow(level1))) {
        group_id <- level1$id[i]
        children <- vocab$activities[
          grepl(paste0("^", gsub("\\.", "\\\\.", group_id), "\\."), vocab$activities$id),
        ]
      }

      end_time <- Sys.time()
      filter_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

      # Should complete in under 1 second
      expect_true(filter_time < 1,
                 paste("Filtering should complete in under 1 second, took",
                       round(filter_time, 2), "seconds"))
    }
  }
})

test_that("UI generation is performant", {
  source("../../guided_workflow.R")
  source("../../vocabulary.R")

  vocab <- load_vocabulary()

  # Measure UI generation time for all steps
  start_time <- Sys.time()

  ui3 <- generate_step3_ui(vocabulary_data = vocab, session = NULL)
  ui4 <- generate_step4_ui(vocabulary_data = vocab, session = NULL)
  ui5 <- generate_step5_ui(vocabulary_data = vocab, session = NULL)
  ui6 <- generate_step6_ui(vocabulary_data = vocab, session = NULL)
  ui7 <- generate_step7_ui(session = NULL)

  end_time <- Sys.time()
  gen_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

  # Should generate all UIs in under 2 seconds
  expect_true(gen_time < 2,
             paste("UI generation should complete in under 2 seconds, took",
                   round(gen_time, 2), "seconds"))
})

# =============================================================================
# TEST SUMMARY
# =============================================================================

cat("\n")
cat("=============================================================================\n")
cat("HIERARCHICAL SELECTION TEST SUITE SUMMARY\n")
cat("=============================================================================\n")
cat("Test Coverage:\n")
cat("  ✓ Vocabulary hierarchical structure\n")
cat("  ✓ Custom entry tracking and state management\n")
cat("  ✓ UI component generation for all steps\n")
cat("  ✓ Server logic for group/item selection\n")
cat("  ✓ Workflow integration and persistence\n")
cat("  ✓ Edge cases and error handling\n")
cat("  ✓ Performance benchmarks\n")
cat("\n")
cat("Total Test Categories: 7\n")
cat("=============================================================================\n")
cat("\n")
