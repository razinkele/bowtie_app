# =============================================================================
# Custom Terms Storage Module
# Version: 1.0.0
# Description: Persistent storage and management of custom vocabulary terms
# =============================================================================

# =============================================================================
# STORAGE CONFIGURATION
# =============================================================================

CUSTOM_TERMS_FILE <- "data/custom_terms.rds"
CUSTOM_TERMS_BACKUP_DIR <- "data/custom_terms_backups"

# Ensure directories exist
if (!dir.exists("data")) dir.create("data", recursive = TRUE)
if (!dir.exists(CUSTOM_TERMS_BACKUP_DIR)) dir.create(CUSTOM_TERMS_BACKUP_DIR, recursive = TRUE)

# =============================================================================
# CUSTOM TERMS DATA STRUCTURE
# =============================================================================

#' Initialize empty custom terms structure
init_custom_terms <- function() {
  list(
    activities = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),  # "pending", "approved", "rejected"
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    preventive_controls = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    protective_controls = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ),
    escalation_factors = data.frame(
      id = character(),
      term = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    )
  )
}

# =============================================================================
# STORAGE FUNCTIONS
# =============================================================================

#' Load custom terms from file
#' @return List of custom terms data frames
load_custom_terms <- function() {
  tryCatch({
    if (file.exists(CUSTOM_TERMS_FILE)) {
      terms <- readRDS(CUSTOM_TERMS_FILE)
      # Ensure all required categories exist
      default_terms <- init_custom_terms()
      for (cat in names(default_terms)) {
        if (is.null(terms[[cat]])) {
          terms[[cat]] <- default_terms[[cat]]
        }
      }
      return(terms)
    } else {
      return(init_custom_terms())
    }
  }, error = function(e) {
    warning(paste("Error loading custom terms:", e$message))
    return(init_custom_terms())
  })
}

#' Save custom terms to file
#' @param terms List of custom terms data frames
#' @param create_backup Whether to create a backup before saving
save_custom_terms <- function(terms, create_backup = TRUE) {
  tryCatch({
    # Create backup if file exists
    if (create_backup && file.exists(CUSTOM_TERMS_FILE)) {
      backup_file <- file.path(
        CUSTOM_TERMS_BACKUP_DIR,
        paste0("custom_terms_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds")
      )
      file.copy(CUSTOM_TERMS_FILE, backup_file)

      # Keep only last 10 backups
      backups <- list.files(CUSTOM_TERMS_BACKUP_DIR, pattern = "\\.rds$", full.names = TRUE)
      if (length(backups) > 10) {
        old_backups <- sort(backups)[1:(length(backups) - 10)]
        file.remove(old_backups)
      }
    }

    saveRDS(terms, CUSTOM_TERMS_FILE)
    return(TRUE)
  }, error = function(e) {
    warning(paste("Error saving custom terms:", e$message))
    return(FALSE)
  })
}

#' Add a custom term
#' @param category Character: "activities", "pressures", etc.
#' @param term Character: The custom term text
#' @param added_by Character: Username who added the term
#' @param project_name Character: Project name (optional)
#' @return Updated terms list
add_custom_term <- function(category, term, added_by = "default", project_name = "") {
  terms <- load_custom_terms()

  # Check if term already exists
  if (term %in% terms[[category]]$term) {
    return(list(success = FALSE, message = "Term already exists", terms = terms))
  }

  # Generate unique ID
  new_id <- paste0(substr(category, 1, 3), "_", format(Sys.time(), "%Y%m%d%H%M%S"), "_",
                   sample(1000:9999, 1))

  # Create new row
  new_row <- data.frame(
    id = new_id,
    term = term,
    added_by = added_by,
    added_date = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    project_name = project_name,
    status = "pending",
    reviewed_by = "",
    reviewed_date = "",
    notes = "",
    stringsAsFactors = FALSE
  )

  # Add to category
  terms[[category]] <- rbind(terms[[category]], new_row)

  # Save
  save_custom_terms(terms)

  return(list(success = TRUE, message = "Term added successfully", terms = terms, id = new_id))
}

#' Update term status (approve/reject)
#' @param category Character: Category name
#' @param term_id Character: Term ID
#' @param new_status Character: "approved" or "rejected"
#' @param reviewed_by Character: Admin username
#' @param notes Character: Optional notes
update_term_status <- function(category, term_id, new_status, reviewed_by = "admin", notes = "") {
  terms <- load_custom_terms()

  idx <- which(terms[[category]]$id == term_id)
  if (length(idx) == 0) {
    return(list(success = FALSE, message = "Term not found"))
  }

  terms[[category]]$status[idx] <- new_status
  terms[[category]]$reviewed_by[idx] <- reviewed_by
  terms[[category]]$reviewed_date[idx] <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  terms[[category]]$notes[idx] <- notes

  save_custom_terms(terms)

  return(list(success = TRUE, message = paste("Term", new_status)))
}

#' Delete a custom term
#' @param category Character: Category name
#' @param term_id Character: Term ID
delete_custom_term <- function(category, term_id) {
  terms <- load_custom_terms()

  idx <- which(terms[[category]]$id == term_id)
  if (length(idx) == 0) {
    return(list(success = FALSE, message = "Term not found"))
  }

  terms[[category]] <- terms[[category]][-idx, , drop = FALSE]
  save_custom_terms(terms)

  return(list(success = TRUE, message = "Term deleted"))
}

#' Get summary statistics
get_custom_terms_summary <- function() {
  terms <- load_custom_terms()

  summary_data <- data.frame(
    Category = c("Activities", "Pressures", "Preventive Controls",
                 "Consequences", "Protective Controls", "Escalation Factors"),
    Total = c(
      nrow(terms$activities),
      nrow(terms$pressures),
      nrow(terms$preventive_controls),
      nrow(terms$consequences),
      nrow(terms$protective_controls),
      nrow(terms$escalation_factors)
    ),
    Pending = c(
      sum(terms$activities$status == "pending"),
      sum(terms$pressures$status == "pending"),
      sum(terms$preventive_controls$status == "pending"),
      sum(terms$consequences$status == "pending"),
      sum(terms$protective_controls$status == "pending"),
      sum(terms$escalation_factors$status == "pending")
    ),
    Approved = c(
      sum(terms$activities$status == "approved"),
      sum(terms$pressures$status == "approved"),
      sum(terms$preventive_controls$status == "approved"),
      sum(terms$consequences$status == "approved"),
      sum(terms$protective_controls$status == "approved"),
      sum(terms$escalation_factors$status == "approved")
    ),
    Rejected = c(
      sum(terms$activities$status == "rejected"),
      sum(terms$pressures$status == "rejected"),
      sum(terms$preventive_controls$status == "rejected"),
      sum(terms$consequences$status == "rejected"),
      sum(terms$protective_controls$status == "rejected"),
      sum(terms$escalation_factors$status == "rejected")
    ),
    stringsAsFactors = FALSE
  )

  return(summary_data)
}

#' Get all terms as a flat table for display
get_all_custom_terms_flat <- function() {
  terms <- load_custom_terms()

  categories <- list(
    activities = "Activity",
    pressures = "Pressure",
    preventive_controls = "Preventive Control",
    consequences = "Consequence",
    protective_controls = "Protective Control",
    escalation_factors = "Escalation Factor"
  )

  terms_list <- lapply(names(categories), function(cat_name) {
    if (nrow(terms[[cat_name]]) > 0) {
      cat_data <- terms[[cat_name]]
      cat_data$category <- categories[[cat_name]]
      cat_data$category_key <- cat_name
      cat_data
    } else {
      NULL
    }
  })
  terms_list <- Filter(Negate(is.null), terms_list)
  all_terms <- if (length(terms_list) > 0) do.call(rbind, terms_list) else data.frame()

  if (nrow(all_terms) == 0) {
    return(data.frame(
      id = character(),
      term = character(),
      category = character(),
      category_key = character(),
      added_by = character(),
      added_date = character(),
      project_name = character(),
      status = character(),
      reviewed_by = character(),
      reviewed_date = character(),
      notes = character(),
      stringsAsFactors = FALSE
    ))
  }

  # Reorder columns
  all_terms <- all_terms[, c("id", "term", "category", "category_key", "added_by",
                              "added_date", "project_name", "status",
                              "reviewed_by", "reviewed_date", "notes")]

  return(all_terms)
}

cat("Custom terms storage module loaded successfully\n")
