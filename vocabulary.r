# vocabulary.R
# Reads hierarchical data from Excel files for activities, pressures, consequences, and controls

if (!require("readxl")) library(readxl)
if (!require("dplyr")) library(dplyr)
if (!require("tidyr")) library(tidyr)

# Function to read and process hierarchical data from Excel
read_hierarchical_data <- function(file_path, sheet_name = NULL) {
  # Read Excel file
  if (!is.null(sheet_name)) {
    data <- read_excel(file_path, sheet = sheet_name)
  } else {
    data <- read_excel(file_path)
  }
  
  # Clean column names - remove trailing spaces
  names(data) <- trimws(names(data))
  
  # Ensure required columns exist
  required_cols <- c("Hierarchy", "ID#", "name")
  if (!all(required_cols %in% names(data))) {
    stop(paste("Missing required columns. Expected:", paste(required_cols, collapse = ", ")))
  }
  
  # Select and rename columns for consistency
  data <- data %>%
    select(hierarchy = Hierarchy, id = `ID#`, name = name) %>%
    filter(!is.na(id)) %>%  # Remove rows without IDs
    mutate(
      # Extract hierarchy level number
      level = as.numeric(gsub("Level ", "", hierarchy)),
      # Clean up names
      name = trimws(name),
      id = trimws(id)
    )
  
  return(data)
}

# Function to create a hierarchical list structure
create_hierarchy_list <- function(data) {
  # Sort by ID to ensure proper hierarchical order
  data <- data %>% arrange(id)
  
  # Create a nested list structure
  hierarchy_list <- list()
  
  for (i in 1:nrow(data)) {
    row <- data[i, ]
    
    # Create the item
    item <- list(
      id = row$id,
      name = row$name,
      level = row$level,
      children = list()
    )
    
    # Determine parent ID based on ID structure
    parts <- strsplit(row$id, "\\.")[[1]]
    if (length(parts) > 1) {
      # Has a parent - construct parent ID
      parent_parts <- parts[1:(length(parts) - 1)]
      parent_id <- paste(parent_parts, collapse = ".")
      item$parent_id <- parent_id
    } else {
      # Top-level item
      item$parent_id <- NULL
    }
    
    hierarchy_list[[row$id]] <- item
  }
  
  return(hierarchy_list)
}

# Function to load all vocabulary data
load_vocabulary <- function(causes_file = "CAUSES.xlsx",
                          consequences_file = "CONSEQUENCES.xlsx",
                          controls_file = "CONTROLS.xlsx") {
  
  vocabulary <- list()
  
  # Load Activities from CAUSES file
  tryCatch({
    vocabulary$activities <- read_hierarchical_data(causes_file, sheet_name = "Activities")
    message("✓ Loaded Activities data: ", nrow(vocabulary$activities), " items")
  }, error = function(e) {
    warning("Failed to load Activities: ", e$message)
    vocabulary$activities <- data.frame()
  })
  
  # Load Pressures from CAUSES file
  tryCatch({
    vocabulary$pressures <- read_hierarchical_data(causes_file, sheet_name = "Pressures")
    message("✓ Loaded Pressures data: ", nrow(vocabulary$pressures), " items")
  }, error = function(e) {
    warning("Failed to load Pressures: ", e$message)
    vocabulary$pressures <- data.frame()
  })
  
  # Load Consequences
  tryCatch({
    vocabulary$consequences <- read_hierarchical_data(consequences_file)
    message("✓ Loaded Consequences data: ", nrow(vocabulary$consequences), " items")
  }, error = function(e) {
    warning("Failed to load Consequences: ", e$message)
    vocabulary$consequences <- data.frame()
  })
  
  # Load Controls
  tryCatch({
    vocabulary$controls <- read_hierarchical_data(controls_file)
    message("✓ Loaded Controls data: ", nrow(vocabulary$controls), " items")
  }, error = function(e) {
    warning("Failed to load Controls: ", e$message)
    vocabulary$controls <- data.frame()
  })
  
  # Create hierarchical lists for each vocabulary
  vocabulary$activities_hierarchy <- create_hierarchy_list(vocabulary$activities)
  vocabulary$pressures_hierarchy <- create_hierarchy_list(vocabulary$pressures)
  vocabulary$consequences_hierarchy <- create_hierarchy_list(vocabulary$consequences)
  vocabulary$controls_hierarchy <- create_hierarchy_list(vocabulary$controls)
  
  return(vocabulary)
}

# Helper function to get items by level
get_items_by_level <- function(data, level) {
  data %>% filter(level == !!level)
}

# Helper function to get children of a specific item
get_children <- function(data, parent_id) {
  # Find all items whose ID starts with the parent_id followed by a dot
  pattern <- paste0("^", gsub("\\.", "\\\\.", parent_id), "\\.")
  data %>% filter(grepl(pattern, id))
}

# Helper function to get the full path of an item (all ancestors)
get_item_path <- function(data, item_id) {
  item <- data %>% filter(id == item_id)
  if (nrow(item) == 0) return(NULL)
  
  path <- list()
  current_id <- item_id
  
  while (!is.null(current_id)) {
    current_item <- data %>% filter(id == current_id)
    if (nrow(current_item) == 0) break
    
    path <- c(list(current_item), path)
    
    # Get parent ID
    parts <- strsplit(current_id, "\\.")[[1]]
    if (length(parts) > 1) {
      parent_parts <- parts[1:(length(parts) - 1)]
      current_id <- paste(parent_parts, collapse = ".")
    } else {
      current_id <- NULL
    }
  }
  
  return(bind_rows(path))
}

# Function to create a tree structure for visualization
create_tree_structure <- function(data) {
  # Create a tree-friendly format
  tree_data <- data %>%
    mutate(
      # Create indentation based on level
      indent = strrep("  ", level - 1),
      # Create display text
      display = paste0(indent, id, " - ", name),
      # Create full path
      path = sapply(id, function(x) {
        path_items <- get_item_path(data, x)
        paste(path_items$name, collapse = " > ")
      })
    )
  
  return(tree_data)
}

# Function to search vocabulary items
search_vocabulary <- function(data, search_term, search_in = c("id", "name")) {
  search_term <- tolower(search_term)
  
  results <- data %>%
    filter(
      if ("id" %in% search_in) grepl(search_term, tolower(id), fixed = TRUE) else FALSE |
      if ("name" %in% search_in) grepl(search_term, tolower(name), fixed = TRUE) else FALSE
    )
  
  return(results)
}

# Example usage function
example_usage <- function() {
  # Load all vocabulary data
  vocab <- load_vocabulary()
  
  # Example: Get all Level 1 activities
  level1_activities <- get_items_by_level(vocab$activities, 1)
  print("Level 1 Activities:")
  print(level1_activities$name)
  
  # Example: Get children of a specific item
  if (nrow(vocab$activities) > 0) {
    first_item <- vocab$activities$id[1]
    children <- get_children(vocab$activities, first_item)
    print(paste("\nChildren of", first_item, ":"))
    print(children %>% select(id, name))
  }
  
  # Example: Search for items
  search_results <- search_vocabulary(vocab$pressures, "biological", c("name"))
  print("\nSearch results for 'biological':")
  print(search_results %>% select(id, name))
  
  # Example: Create tree structure
  tree <- create_tree_structure(vocab$consequences)
  print("\nConsequences Tree (first 10 items):")
  print(head(tree$display, 10))
}

# Make the main function available when sourced
# This will be called when the file is sourced in the Shiny app
if (!interactive()) {
  # Load vocabulary when sourced non-interactively
  vocabulary_data <- load_vocabulary()
}