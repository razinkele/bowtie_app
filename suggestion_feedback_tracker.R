# suggestion_feedback_tracker.R
# AI Suggestion Feedback Tracking System
# Version: 1.0
# Description: Tracks user interactions with AI suggestions for learning and improvement
#
# This module provides feedback collection, storage, and analysis for AI-powered
# vocabulary suggestions, enabling adaptive learning and threshold optimization.
#
# Author: Claude Code
# Date: 2025-12-28

# =============================================================================
# FEEDBACK DATA STRUCTURE
# =============================================================================

# Global feedback storage (in-memory, persisted to disk)
.feedback_data <- new.env(parent = emptyenv())

#' Initialize feedback tracking system
#'
#' Sets up the feedback data structure and loads historical data if available
#'
#' @param data_file Path to feedback data file (default: "data/suggestion_feedback.rds")
#' @return Invisible NULL
init_feedback_tracker <- function(data_file = "data/suggestion_feedback.rds") {

  bowtie_log("Initializing suggestion feedback tracker...", level = "info")

  # Initialize empty feedback dataframe
  .feedback_data$records <- data.frame(
    timestamp = character(),
    session_id = character(),
    user_id = character(),
    from_id = character(),
    from_name = character(),
    from_type = character(),
    to_id = character(),
    to_name = character(),
    to_type = character(),
    similarity = numeric(),
    confidence = numeric(),
    method = character(),
    action = character(),  # "accepted", "rejected", "dismissed"
    step = character(),    # Workflow step where suggestion appeared
    context_data = character(),  # JSON-encoded additional context
    stringsAsFactors = FALSE
  )

  # Set data file path
  .feedback_data$data_file <- data_file

  # Load existing feedback if available
  if (file.exists(data_file)) {
    tryCatch({
      loaded_data <- readRDS(data_file)
      .feedback_data$records <- loaded_data
      bowtie_log(sprintf("Loaded %d historical feedback records", nrow(loaded_data)), level = "success")
    }, error = function(e) {
      warning("Failed to load feedback data: ", e$message)
      bowtie_log("Starting with empty feedback database", level = "warning")
    })
  } else {
    bowtie_log("No historical feedback found - starting fresh", level = "info")
  }

  bowtie_log(sprintf("Feedback will be saved to: %s", data_file), level = "info")

  invisible(NULL)
}

# =============================================================================
# FEEDBACK LOGGING FUNCTIONS
# =============================================================================

#' Log suggestion feedback
#'
#' Records user interaction with an AI suggestion
#'
#' @param suggestion Suggestion data (list or data frame row)
#' @param action Action taken: "accepted", "rejected", "dismissed"
#' @param session_id Current session identifier
#' @param user_id User identifier (optional)
#' @param step Workflow step (optional)
#' @param context Additional context data (optional, will be JSON-encoded)
#' @return Invisible NULL
log_suggestion_feedback <- function(suggestion,
                                   action = c("accepted", "rejected", "dismissed"),
                                   session_id = NULL,
                                   user_id = "default",
                                   step = NA,
                                   context = NULL) {

  # Validate action
  action <- match.arg(action)

  # Generate session ID if not provided
  if (is.null(session_id)) {
    session_id <- paste0("session_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  }

  # Extract suggestion data
  from_id <- if (is.list(suggestion)) suggestion$from_id else suggestion$from_id[1]
  from_name <- if (is.list(suggestion)) suggestion$from_name else suggestion$from_name[1]
  from_type <- if (is.list(suggestion)) suggestion$from_type else suggestion$from_type[1]
  to_id <- if (is.list(suggestion)) suggestion$to_id else suggestion$to_id[1]
  to_name <- if (is.list(suggestion)) suggestion$to_name else suggestion$to_name[1]
  to_type <- if (is.list(suggestion)) suggestion$to_type else suggestion$to_type[1]
  similarity <- if (is.list(suggestion)) suggestion$similarity else suggestion$similarity[1]
  method <- if (is.list(suggestion)) suggestion$method else as.character(suggestion$method[1])

  # Get confidence if available
  confidence <- if (!is.null(suggestion$confidence)) {
    if (is.list(suggestion)) suggestion$confidence else suggestion$confidence[1]
  } else {
    similarity  # Fallback to similarity
  }

  # Encode context as JSON if provided
  context_json <- if (!is.null(context)) {
    tryCatch({
      jsonlite::toJSON(context, auto_unbox = TRUE)
    }, error = function(e) {
      "{}"
    })
  } else {
    "{}"
  }

  # Create new feedback record
  new_record <- data.frame(
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    session_id = session_id,
    user_id = user_id,
    from_id = from_id,
    from_name = from_name,
    from_type = from_type,
    to_id = to_id,
    to_name = to_name,
    to_type = to_type,
    similarity = similarity,
    confidence = confidence,
    method = method,
    action = action,
    step = if (is.na(step)) NA_character_ else as.character(step),
    context_data = context_json,
    stringsAsFactors = FALSE
  )

  # Append to feedback data
  if (exists("records", envir = .feedback_data)) {
    .feedback_data$records <- rbind(.feedback_data$records, new_record)
  } else {
    # Initialize if not yet initialized
    init_feedback_tracker()
    .feedback_data$records <- rbind(.feedback_data$records, new_record)
  }

  # Auto-save every 10 records
  if (nrow(.feedback_data$records) %% 10 == 0) {
    save_feedback(quiet = TRUE)
  }

  invisible(NULL)
}

#' Save feedback to disk
#'
#' Persists all feedback records to disk
#'
#' @param quiet Suppress output messages (default FALSE)
#' @return Invisible NULL
save_feedback <- function(quiet = FALSE) {

  if (!exists("records", envir = .feedback_data)) {
    if (!quiet) warning("No feedback data to save")
    return(invisible(NULL))
  }

  data_file <- .feedback_data$data_file

  # Create directory if it doesn't exist
  data_dir <- dirname(data_file)
  if (!dir.exists(data_dir)) {
    dir.create(data_dir, recursive = TRUE)
  }

  tryCatch({
    saveRDS(.feedback_data$records, data_file)
    if (!quiet) {
      bowtie_log(sprintf("Saved %d feedback records to %s",
                  nrow(.feedback_data$records), data_file), level = "success")
    }
  }, error = function(e) {
    warning("Failed to save feedback: ", e$message)
  })

  invisible(NULL)
}

# =============================================================================
# FEEDBACK ANALYSIS FUNCTIONS
# =============================================================================

#' Get feedback statistics
#'
#' @return List with summary statistics
get_feedback_stats <- function() {

  if (!exists("records", envir = .feedback_data) ||
      nrow(.feedback_data$records) == 0) {
    return(list(
      total_records = 0,
      acceptance_rate = NA,
      by_method = data.frame(),
      by_link_type = data.frame(),
      by_confidence = data.frame()
    ))
  }

  records <- .feedback_data$records

  # Overall statistics
  total <- nrow(records)
  accepted <- sum(records$action == "accepted")
  rejected <- sum(records$action == "rejected")
  dismissed <- sum(records$action == "dismissed")

  # By method
  by_method <- if (nrow(records) > 0) {
    records %>%
      dplyr::group_by(method) %>%
      dplyr::summarise(
        count = n(),
        accepted = sum(action == "accepted"),
        rejected = sum(action == "rejected"),
        acceptance_rate = mean(action == "accepted"),
        avg_similarity = mean(similarity, na.rm = TRUE),
        avg_confidence = mean(confidence, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      dplyr::arrange(desc(acceptance_rate))
  } else {
    data.frame()
  }

  # By link type
  by_link_type <- if (nrow(records) > 0) {
    records %>%
      dplyr::mutate(link_type = paste(from_type, to_type, sep = " → ")) %>%
      dplyr::group_by(link_type) %>%
      dplyr::summarise(
        count = n(),
        accepted = sum(action == "accepted"),
        acceptance_rate = mean(action == "accepted"),
        .groups = 'drop'
      ) %>%
      dplyr::arrange(desc(acceptance_rate))
  } else {
    data.frame()
  }

  # By confidence bands
  by_confidence <- if (nrow(records) > 0) {
    records %>%
      dplyr::mutate(
        confidence_band = cut(
          confidence,
          breaks = c(0, 0.3, 0.5, 0.7, 0.85, 1.0),
          labels = c("Very Low", "Low", "Medium", "High", "Very High"),
          include.lowest = TRUE
        )
      ) %>%
      dplyr::group_by(confidence_band) %>%
      dplyr::summarise(
        count = n(),
        accepted = sum(action == "accepted"),
        acceptance_rate = mean(action == "accepted"),
        .groups = 'drop'
      )
  } else {
    data.frame()
  }

  list(
    total_records = total,
    accepted = accepted,
    rejected = rejected,
    dismissed = dismissed,
    acceptance_rate = if (total > 0) accepted / total else NA,
    by_method = by_method,
    by_link_type = by_link_type,
    by_confidence = by_confidence,
    first_record = if (total > 0) min(records$timestamp) else NA,
    last_record = if (total > 0) max(records$timestamp) else NA
  )
}

#' Get feedback for specific suggestion type
#'
#' @param link_type Link type (e.g., "Activity → Pressure")
#' @param method Method filter (optional)
#' @return Data frame of relevant feedback
get_feedback_for_type <- function(link_type = NULL, method = NULL) {

  if (!exists("records", envir = .feedback_data)) {
    return(data.frame())
  }

  records <- .feedback_data$records

  # Filter by link type
  if (!is.null(link_type)) {
    records <- records %>%
      dplyr::mutate(type = paste(from_type, to_type, sep = " → ")) %>%
      dplyr::filter(type == link_type)
  }

  # Filter by method
  if (!is.null(method)) {
    records <- records %>%
      dplyr::filter(grepl(method, method, ignore.case = TRUE))
  }

  return(records)
}

#' Export feedback to CSV
#'
#' @param file_path Path to export CSV file
#' @return Invisible NULL
export_feedback_csv <- function(file_path = "data/suggestion_feedback.csv") {

  if (!exists("records", envir = .feedback_data)) {
    warning("No feedback data to export")
    return(invisible(NULL))
  }

  tryCatch({
    write.csv(.feedback_data$records, file_path, row.names = FALSE)
    bowtie_log(sprintf("Exported %d feedback records to %s",
                nrow(.feedback_data$records), file_path), level = "success")
  }, error = function(e) {
    warning("Failed to export feedback: ", e$message)
  })

  invisible(NULL)
}

# =============================================================================
# VISUALIZATION FUNCTIONS
# =============================================================================

#' Plot feedback acceptance rates
#'
#' @return ggplot object
plot_acceptance_rates <- function() {

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 package required for plotting")
  }

  stats <- get_feedback_stats()

  if (nrow(stats$by_method) == 0) {
    bowtie_log("No feedback data available for plotting", level = "info")
    return(NULL)
  }

  library(ggplot2)

  ggplot(stats$by_method, aes(x = reorder(method, acceptance_rate),
                               y = acceptance_rate,
                               fill = acceptance_rate)) +
    geom_col() +
    geom_text(aes(label = sprintf("%.1f%%\n(%d/%d)",
                                   acceptance_rate * 100,
                                   accepted,
                                   count)),
              hjust = -0.1, size = 3) +
    coord_flip() +
    scale_y_continuous(labels = scales::percent, limits = c(0, 1.1)) +
    scale_fill_gradient2(low = "#e74c3c", mid = "#f39c12", high = "#27ae60",
                        midpoint = 0.5, labels = scales::percent) +
    labs(
      title = "AI Suggestion Acceptance Rate by Method",
      x = "Detection Method",
      y = "Acceptance Rate",
      fill = "Acceptance\nRate"
    ) +
    theme_minimal() +
    theme(legend.position = "right")
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Module initialization message (interactive only)
if (interactive()) {
  cat("Suggestion Feedback Tracker loaded successfully!\n")
  cat("==================================================\n\n")
  cat("Available Functions:\n")
  cat("  - init_feedback_tracker()      : Initialize feedback system\n")
  cat("  - log_suggestion_feedback()    : Log user action on suggestion\n")
  cat("  - save_feedback()              : Save feedback to disk\n")
  cat("  - get_feedback_stats()         : Get summary statistics\n")
  cat("  - get_feedback_for_type()      : Filter feedback by type/method\n")
  cat("  - export_feedback_csv()        : Export to CSV format\n")
  cat("  - plot_acceptance_rates()      : Visualize acceptance rates\n\n")
  cat("==================================================\n")
}
