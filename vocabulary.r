# vocabulary.R
# Reads hierarchical data from Excel files for activities, pressures, consequences, and controls
# Version 5.4.0 - Modern framework with enhanced error handling and validation
# Date: January 2026
#
# NOTE: All packages are loaded via global.R - do not add library() calls here
# Required packages: readxl, dplyr, tidyr

# Enhanced function to read and process hierarchical data from Excel
read_hierarchical_data <- function(file_path, sheet_name = NULL) {
  # Validate file existence
  if (!file.exists(file_path)) {
    stop(paste("File not found:", file_path))
  }
  
  tryCatch({
    # Read Excel file with enhanced error handling
    if (!is.null(sheet_name)) {
      data <- read_excel(file_path, sheet = sheet_name, .name_repair = "minimal")
    } else {
      data <- read_excel(file_path, .name_repair = "minimal")
    }
    
    # Validate data is not empty
    if (nrow(data) == 0) {
      warning(paste("No data found in file:", file_path))
      return(data.frame(hierarchy = character(), id = character(), name = character()))
    }
    
    # Clean column names - remove trailing spaces and normalize
    names(data) <- trimws(names(data))
    
    # Ensure required columns exist
    required_cols <- c("Hierarchy", "ID#", "name")
    if (!all(required_cols %in% names(data))) {
      available_cols <- names(data)
      stop(paste("Missing required columns. Expected:", paste(required_cols, collapse = ", "), 
                ". Available:", paste(available_cols, collapse = ", ")))
    }
    
    log_debug(paste("Successfully read", nrow(data), "rows from", basename(file_path)))
    
  }, error = function(e) {
    stop(paste("Error reading Excel file:", file_path, "-", e$message))
  })
  
  # Select and rename columns for consistency
  data <- data %>%
    select(hierarchy = Hierarchy, id = `ID#`, name = name) %>%
    filter(!is.na(id)) %>%  # Remove rows without IDs
    mutate(
      # Extract hierarchy level number with improved handling
      level = suppressWarnings(as.numeric(gsub("Level ", "", hierarchy))),
      # Clean up names and handle NAs
      name = trimws(as.character(name)),
      id = trimws(as.character(id))
    ) %>%
    # Remove rows with invalid data
    filter(!is.na(name), !is.na(id), nchar(trimws(name)) > 0, nchar(trimws(id)) > 0
    )
  
  return(data)
}

# Function to create a hierarchical list structure
create_hierarchy_list <- function(data) {
  # Handle NULL or empty data
  if (is.null(data) || nrow(data) == 0) {
    return(list())
  }

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

# =============================================================================
# FILE PATH CACHE
# =============================================================================
# Cache resolved file paths to avoid repeated directory searches

.file_path_cache <- new.env(parent = emptyenv())

# Get cached file path or search and cache it
get_cached_file_path <- function(filename, search_locations) {
  cache_key <- filename

  # Return cached path if available
  if (exists(cache_key, envir = .file_path_cache)) {
    cached_path <- .file_path_cache[[cache_key]]
    # Verify file still exists
    if (file.exists(cached_path)) {
      return(cached_path)
    }
    # Clear stale cache entry
    rm(list = cache_key, envir = .file_path_cache)
  }

  # Search for file
  for (loc in search_locations) {
    if (file.exists(loc)) {
      resolved_path <- normalizePath(loc, mustWork = TRUE)
      # Cache the result
      .file_path_cache[[cache_key]] <- resolved_path
      return(resolved_path)
    }
  }

  return(filename)  # Return original if not found (will error later)
}

# Clear the file path cache (call when data files change)
clear_file_path_cache <- function() {
  rm(list = ls(.file_path_cache), envir = .file_path_cache)
}

# Function to load all vocabulary data
load_vocabulary <- function(causes_file = "CAUSES.xlsx",
                          consequences_file = "CONSEQUENCES.xlsx",
                          controls_file = "CONTROLS.xlsx") {

  # Helper to find files in multiple locations with path validation
  find_data_file <- function(filename) {
    # Security: Validate filename to prevent path traversal attacks
    if (is.null(filename) || !is.character(filename) || length(filename) != 1) {
      stop("Invalid filename: must be a single character string")
    }

    # Security: Block path traversal attempts
    if (grepl("\\.\\.", filename) || grepl("^/", filename) || grepl("^[A-Za-z]:", filename)) {
      stop("Invalid filename: path traversal not allowed. Use only filenames without directory components.")
    }

    # Security: Only allow specific file extensions
    valid_extensions <- c(".xlsx", ".xls", ".csv")
    file_ext <- tolower(tools::file_ext(filename))
    if (!paste0(".", file_ext) %in% valid_extensions) {
      stop(paste("Invalid file extension:", file_ext, ". Allowed:", paste(valid_extensions, collapse = ", ")))
    }

    # Sanitize filename (remove any remaining problematic characters)
    sanitized_filename <- basename(filename)

    # Define search locations (current dir, data/, ../../data/ for tests)
    locations <- c(
      sanitized_filename,
      file.path("data", sanitized_filename),
      file.path("../../data", sanitized_filename),
      file.path("../../", sanitized_filename)
    )

    # Use cached file path lookup for performance
    return(get_cached_file_path(sanitized_filename, locations))
  }

  # Find the actual file paths
  causes_file <- find_data_file(causes_file)
  consequences_file <- find_data_file(consequences_file)
  controls_file <- find_data_file(controls_file)

  vocabulary <- list()

  # Load Activities from CAUSES file
  tryCatch({
    vocabulary$activities <- read_hierarchical_data(causes_file, sheet_name = "Activities")
    log_info(paste("Loaded Activities data:", nrow(vocabulary$activities), "items"))
  }, error = function(e) {
    log_warning(paste("Failed to load Activities:", e$message))
    vocabulary$activities <- data.frame()
  })
  
  # Load Pressures from CAUSES file
  tryCatch({
    vocabulary$pressures <- read_hierarchical_data(causes_file, sheet_name = "Pressures")
    log_info(paste("Loaded Pressures data:", nrow(vocabulary$pressures), "items"))
  }, error = function(e) {
    log_warning(paste("Failed to load Pressures:", e$message))
    vocabulary$pressures <- data.frame()
  })
  
  # Load Consequences
  tryCatch({
    vocabulary$consequences <- read_hierarchical_data(consequences_file)
    log_info(paste("Loaded Consequences data:", nrow(vocabulary$consequences), "items"))
  }, error = function(e) {
    log_warning(paste("Failed to load Consequences:", e$message))
    vocabulary$consequences <- data.frame()
  })
  
  # Load Controls
  tryCatch({
    vocabulary$controls <- read_hierarchical_data(controls_file)
    log_info(paste("Loaded Controls data:", nrow(vocabulary$controls), "items"))
  }, error = function(e) {
    log_warning(paste("Failed to load Controls:", e$message))
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

# Source AI linker if available
if (file.exists("vocabulary_ai_linker.R")) {
  source("vocabulary_ai_linker.R")
  log_success("AI vocabulary linker loaded")
} else {
  log_info("AI vocabulary linker not found - basic functionality only")
}

# Function to find basic keyword connections (fallback if AI linker not available)
find_basic_connections <- function(vocabulary_data) {
  # Basic keyword matching between vocabulary types
  connections <- data.frame()
  
  # Common environmental keywords
  keywords <- c("water", "pollution", "waste", "emission", "habitat", "ecosystem", 
                "contamination", "discharge", "runoff", "degradation")
  
  # Get all vocabulary items
  all_items <- rbind(
    data.frame(id = vocabulary_data$activities$id, 
               name = vocabulary_data$activities$name, 
               type = "Activity", stringsAsFactors = FALSE),
    data.frame(id = vocabulary_data$pressures$id, 
               name = vocabulary_data$pressures$name, 
               type = "Pressure", stringsAsFactors = FALSE),
    data.frame(id = vocabulary_data$consequences$id, 
               name = vocabulary_data$consequences$name, 
               type = "Consequence", stringsAsFactors = FALSE),
    data.frame(id = vocabulary_data$controls$id, 
               name = vocabulary_data$controls$name, 
               type = "Control", stringsAsFactors = FALSE)
  )
  
  # Find items sharing keywords
  for (keyword in keywords) {
    matching_items <- all_items[grepl(keyword, tolower(all_items$name)), ]
    
    if (nrow(matching_items) > 1) {
      for (i in 1:(nrow(matching_items) - 1)) {
        for (j in (i + 1):nrow(matching_items)) {
          if (matching_items$type[i] != matching_items$type[j]) {
            connections <- rbind(connections, data.frame(
              from_id = matching_items$id[i],
              from_name = matching_items$name[i],
              from_type = matching_items$type[i],
              to_id = matching_items$id[j],
              to_name = matching_items$name[j],
              to_type = matching_items$type[j],
              keyword = keyword,
              similarity = 0.5,  # Default similarity for keyword matches
              method = paste("keyword", keyword, sep = "_"),
              stringsAsFactors = FALSE
            ))
          }
        }
      }
    }
  }
  
  return(connections)
}

# Wrapper function for AI-powered vocabulary linking
find_vocabulary_connections <- function(vocabulary_data, use_ai = TRUE) {
  if (use_ai && exists("find_vocabulary_links")) {
    # Use AI-powered linking
    return(find_vocabulary_links(vocabulary_data))
  } else {
    # Fallback to basic keyword matching
    connections <- find_basic_connections(vocabulary_data)
    return(list(
      links = connections,
      keyword_connections = list(),
      summary = if(nrow(connections) > 0) {
        connections %>%
          group_by(from_type, to_type, method) %>%
          summarise(
            count = n(),
            avg_similarity = mean(similarity),
            max_similarity = max(similarity),
            min_similarity = min(similarity),
            .groups = 'drop'
          )
      } else {
        data.frame()
      }
    ))
  }
}

# =============================================================================
# USAGE EXAMPLES (for documentation - run interactively if needed)
# =============================================================================
# vocab <- load_vocabulary()
# level1_activities <- get_items_by_level(vocab$activities, 1)
# children <- get_children(vocab$activities, vocab$activities$id[1])
# search_results <- search_vocabulary(vocab$pressures, "biological", c("name"))
# tree <- create_tree_structure(vocab$consequences)
# =============================================================================

# NOTE: Vocabulary data is loaded via global.R using load_app_data()
# Do not load vocabulary here to avoid duplicate loading

log_debug("Vocabulary management system loaded (v5.4.0)")