# Custom Terms Storage Module
# Version: 5.4.1
# Date: 2025-12-27
#
# Provides persistent storage for custom terms entered across all guided workflows
# Custom terms are stored in a centralized RDS file for review by authorized users

library(dplyr)
library(openxlsx)

# Storage file path
CUSTOM_TERMS_FILE <- "custom_terms_database.rds"

#' Initialize custom terms storage
#'
#' Creates empty storage file if it doesn't exist
#' @return TRUE if successful, FALSE otherwise
init_custom_terms_storage <- function() {
  if (!file.exists(CUSTOM_TERMS_FILE)) {
    # Create empty storage structure
    empty_storage <- list(
      activities = data.frame(
        term = character(),
        original_name = character(),
        added_date = character(),
        workflow_id = character(),
        user = character(),
        status = character(),
        notes = character(),
        reviewed_by = character(),
        reviewed_date = character(),
        stringsAsFactors = FALSE
      ),
      pressures = data.frame(
        term = character(),
        original_name = character(),
        added_date = character(),
        workflow_id = character(),
        user = character(),
        status = character(),
        notes = character(),
        reviewed_by = character(),
        reviewed_date = character(),
        stringsAsFactors = FALSE
      ),
      preventive_controls = data.frame(
        term = character(),
        original_name = character(),
        added_date = character(),
        workflow_id = character(),
        user = character(),
        status = character(),
        notes = character(),
        reviewed_by = character(),
        reviewed_date = character(),
        stringsAsFactors = FALSE
      ),
      consequences = data.frame(
        term = character(),
        original_name = character(),
        added_date = character(),
        workflow_id = character(),
        user = character(),
        status = character(),
        notes = character(),
        reviewed_by = character(),
        reviewed_date = character(),
        stringsAsFactors = FALSE
      ),
      protective_controls = data.frame(
        term = character(),
        original_name = character(),
        added_date = character(),
        workflow_id = character(),
        user = character(),
        status = character(),
        notes = character(),
        reviewed_by = character(),
        reviewed_date = character(),
        stringsAsFactors = FALSE
      )
    )

    saveRDS(empty_storage, CUSTOM_TERMS_FILE)
    cat("✅ Custom terms storage initialized:", CUSTOM_TERMS_FILE, "\n")
    return(TRUE)
  }
  return(TRUE)
}

#' Load all custom terms from storage
#'
#' @return List of data frames by category
load_custom_terms <- function() {
  if (!file.exists(CUSTOM_TERMS_FILE)) {
    init_custom_terms_storage()
  }

  tryCatch({
    custom_terms <- readRDS(CUSTOM_TERMS_FILE)
    cat("📖 Loaded custom terms from storage\n")
    return(custom_terms)
  }, error = function(e) {
    cat("❌ Error loading custom terms:", e$message, "\n")
    init_custom_terms_storage()
    return(readRDS(CUSTOM_TERMS_FILE))
  })
}

#' Save custom terms to storage
#'
#' @param custom_terms List of data frames by category
#' @return TRUE if successful, FALSE otherwise
save_custom_terms <- function(custom_terms) {
  tryCatch({
    saveRDS(custom_terms, CUSTOM_TERMS_FILE)
    cat("💾 Saved custom terms to storage\n")
    return(TRUE)
  }, error = function(e) {
    cat("❌ Error saving custom terms:", e$message, "\n")
    return(FALSE)
  })
}

#' Add custom terms from workflow to storage
#'
#' @param workflow_custom_terms Custom terms from a specific workflow
#' @param workflow_id Unique workflow identifier
#' @param user Username or "anonymous"
#' @return TRUE if successful, FALSE otherwise
add_workflow_custom_terms <- function(workflow_custom_terms, workflow_id = NULL, user = "anonymous") {
  # Load existing storage
  storage <- load_custom_terms()

  # Generate workflow ID if not provided
  if (is.null(workflow_id)) {
    workflow_id <- paste0("workflow_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  }

  # Process each category
  for (category in names(workflow_custom_terms)) {
    if (category %in% names(storage)) {
      category_terms <- workflow_custom_terms[[category]]

      if (nrow(category_terms) > 0) {
        # Add workflow metadata if not present
        if (!"workflow_id" %in% names(category_terms)) {
          category_terms$workflow_id <- workflow_id
        }
        if (!"user" %in% names(category_terms)) {
          category_terms$user <- user
        }
        if (!"reviewed_by" %in% names(category_terms)) {
          category_terms$reviewed_by <- ""
        }
        if (!"reviewed_date" %in% names(category_terms)) {
          category_terms$reviewed_date <- ""
        }

        # Append to storage
        storage[[category]] <- rbind(storage[[category]], category_terms)
        cat("➕ Added", nrow(category_terms), category, "to storage\n")
      }
    }
  }

  # Save updated storage
  return(save_custom_terms(storage))
}

#' Get combined custom terms table for display
#'
#' @param custom_terms List of custom terms by category
#' @param status_filter Filter by status (NULL = all)
#' @return Data frame with combined terms
get_combined_custom_terms_table <- function(custom_terms, status_filter = NULL) {
  combined <- data.frame()

  for (category in names(custom_terms)) {
    df <- custom_terms[[category]]
    if (nrow(df) > 0) {
      df$category <- tools::toTitleCase(gsub("_", " ", category))
      combined <- rbind(combined, df)
    }
  }

  # Apply status filter if provided
  if (!is.null(status_filter) && nrow(combined) > 0) {
    combined <- combined %>% filter(status == status_filter)
  }

  # Reorder columns for better display
  if (nrow(combined) > 0) {
    combined <- combined %>%
      select(category, original_name, term, added_date, workflow_id, user,
             status, notes, reviewed_by, reviewed_date)
  }

  return(combined)
}

#' Update status of custom terms
#'
#' @param term_indices Row indices of terms to update
#' @param new_status New status value ("approved", "rejected", "pending")
#' @param reviewer_name Name of reviewer
#' @return TRUE if successful
update_custom_term_status <- function(term_indices, new_status, reviewer_name = "admin") {
  storage <- load_custom_terms()
  combined <- get_combined_custom_terms_table(storage)

  if (nrow(combined) == 0 || length(term_indices) == 0) {
    return(FALSE)
  }

  # Get terms to update
  terms_to_update <- combined[term_indices, ]

  # Update in each category
  for (i in 1:nrow(terms_to_update)) {
    term_info <- terms_to_update[i, ]
    category <- tolower(gsub(" ", "_", term_info$category))

    if (category %in% names(storage)) {
      # Find matching term in category
      match_idx <- which(
        storage[[category]]$original_name == term_info$original_name &
        storage[[category]]$added_date == term_info$added_date
      )

      if (length(match_idx) > 0) {
        storage[[category]]$status[match_idx] <- new_status
        storage[[category]]$reviewed_by[match_idx] <- reviewer_name
        storage[[category]]$reviewed_date[match_idx] <- as.character(Sys.time())
      }
    }
  }

  return(save_custom_terms(storage))
}

#' Remove reviewed custom terms
#'
#' @param remove_approved Remove approved terms (default: TRUE)
#' @param remove_rejected Remove rejected terms (default: TRUE)
#' @return Number of terms removed
clear_reviewed_terms <- function(remove_approved = TRUE, remove_rejected = TRUE) {
  storage <- load_custom_terms()
  total_removed <- 0

  for (category in names(storage)) {
    df <- storage[[category]]
    original_count <- nrow(df)

    # Filter based on parameters
    if (remove_approved && remove_rejected) {
      storage[[category]] <- df %>% filter(status == "pending")
    } else if (remove_approved) {
      storage[[category]] <- df %>% filter(status != "approved")
    } else if (remove_rejected) {
      storage[[category]] <- df %>% filter(status != "rejected")
    }

    removed <- original_count - nrow(storage[[category]])
    total_removed <- total_removed + removed

    if (removed > 0) {
      cat("🗑️  Removed", removed, "reviewed", category, "\n")
    }
  }

  save_custom_terms(storage)
  return(total_removed)
}

#' Export custom terms to Excel
#'
#' @param custom_terms List of custom terms by category
#' @param filepath Output file path
#' @param status_filter Optional status filter
#' @return TRUE if successful
export_custom_terms_excel <- function(custom_terms, filepath, status_filter = NULL) {
  tryCatch({
    # Create workbook
    wb <- createWorkbook()

    # Add summary sheet
    summary_data <- data.frame(
      Category = character(),
      Total = integer(),
      Pending = integer(),
      Approved = integer(),
      Rejected = integer(),
      stringsAsFactors = FALSE
    )

    for (category in names(custom_terms)) {
      df <- custom_terms[[category]]

      # Apply status filter if provided
      if (!is.null(status_filter)) {
        df <- df %>% filter(status == status_filter)
      }

      if (nrow(df) > 0) {
        # Add to summary
        summary_data <- rbind(summary_data, data.frame(
          Category = tools::toTitleCase(gsub("_", " ", category)),
          Total = nrow(df),
          Pending = sum(df$status == "pending"),
          Approved = sum(df$status == "approved"),
          Rejected = sum(df$status == "rejected"),
          stringsAsFactors = FALSE
        ))

        # Add category sheet
        addWorksheet(wb, tools::toTitleCase(gsub("_", " ", category)))
        writeData(wb, tools::toTitleCase(gsub("_", " ", category)), df)
      }
    }

    # Add summary sheet first
    if (nrow(summary_data) > 0) {
      addWorksheet(wb, "Summary", gridLines = TRUE)
      writeData(wb, "Summary", summary_data)

      # Move summary to first position
      worksheetOrder(wb) <- c(length(names(wb)), 1:(length(names(wb))-1))
    }

    # Save workbook
    saveWorkbook(wb, filepath, overwrite = TRUE)
    cat("📊 Exported custom terms to:", filepath, "\n")
    return(TRUE)

  }, error = function(e) {
    cat("❌ Error exporting custom terms:", e$message, "\n")
    return(FALSE)
  })
}

#' Get statistics about custom terms
#'
#' @param custom_terms List of custom terms by category
#' @return List with statistics
get_custom_terms_stats <- function(custom_terms) {
  stats <- list(
    total = 0,
    pending = 0,
    approved = 0,
    rejected = 0,
    by_category = list()
  )

  for (category in names(custom_terms)) {
    df <- custom_terms[[category]]
    cat_stats <- list(
      total = nrow(df),
      pending = sum(df$status == "pending"),
      approved = sum(df$status == "approved"),
      rejected = sum(df$status == "rejected")
    )

    stats$total <- stats$total + cat_stats$total
    stats$pending <- stats$pending + cat_stats$pending
    stats$approved <- stats$approved + cat_stats$approved
    stats$rejected <- stats$rejected + cat_stats$rejected
    stats$by_category[[category]] <- cat_stats
  }

  return(stats)
}

# Initialize storage on module load
init_custom_terms_storage()

cat("✅ Custom Terms Storage Module loaded (v5.4.1)\n")
cat("   📁 Storage file:", CUSTOM_TERMS_FILE, "\n")
cat("   📊 Functions available:\n")
cat("      - load_custom_terms()\n")
cat("      - save_custom_terms()\n")
cat("      - add_workflow_custom_terms()\n")
cat("      - update_custom_term_status()\n")
cat("      - clear_reviewed_terms()\n")
cat("      - export_custom_terms_excel()\n")
cat("      - get_custom_terms_stats()\n")
