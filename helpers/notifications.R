# =============================================================================
# Environmental Bowtie Risk Analysis - Notification Helpers
# Version: 5.4.0+
# Date: January 2026
# Purpose: Standardized notification functions to reduce code duplication
# =============================================================================

#' Show success notification with translation support
#'
#' @param message_key Translation key or direct message
#' @param lang Language code (default: "en")
#' @param duration Duration in seconds (uses constant if not specified)
#' @param ... Additional parameters passed to paste()
#' @return NULL (invisible)
#'
#' @examples
#' notify_success("notify_data_loaded", lang = "en")
#' notify_success("Data loaded successfully")
notify_success <- function(message_key, lang = "en", duration = NULL, ...) {
  if (is.null(duration)) {
    duration <- NOTIFICATION_DURATION_SUCCESS
  }

  # Check if message_key is a translation key
  translated <- tryCatch({
    if (exists("t") && is.function(t)) {
      t(message_key, lang)
    } else {
      message_key
    }
  }, error = function(e) {
    message_key
  })

  # Format with additional parameters
  if (length(list(...)) > 0) {
    message_text <- paste(translated, ...)
  } else {
    message_text <- translated
  }

  showNotification(
    paste("✅", message_text),
    type = "message",
    duration = duration
  )

  invisible(NULL)
}

#' Show error notification
#'
#' @param error Error object or character string
#' @param duration Duration in seconds (uses constant if not specified)
#' @param context Context description for the error
#' @param lang Language code for translation
#' @return NULL (invisible)
#'
#' @examples
#' notify_error("File not found")
#' notify_error(err_object, context = "loading data")
notify_error <- function(error, duration = NULL, context = NULL, lang = "en") {
  if (is.null(duration)) {
    duration <- NOTIFICATION_DURATION_ERROR
  }

  # Extract message from error object or use string directly
  message_text <- if (is.character(error)) {
    error
  } else if (inherits(error, "error") || inherits(error, "condition")) {
    error$message
  } else {
    as.character(error)
  }

  # Add context if provided
  if (!is.null(context)) {
    full_message <- paste(context, ":", message_text)
  } else {
    full_message <- message_text
  }

  showNotification(
    paste("❌ Error:", full_message),
    type = "error",
    duration = duration
  )

  invisible(NULL)
}

#' Show info notification with icon
#'
#' @param icon_name FontAwesome icon name (without "fa-" prefix)
#' @param message Message text or translation key
#' @param duration Duration in seconds (uses constant if not specified)
#' @param lang Language code
#' @return NULL (invisible)
#'
#' @examples
#' notify_info("project-diagram", "Navigating to Bowtie Diagram...")
notify_info <- function(icon_name, message, duration = NULL, lang = "en") {
  if (is.null(duration)) {
    duration <- NOTIFICATION_DURATION_INFO
  }

  # Translate message if needed
  translated <- tryCatch({
    if (exists("t") && is.function(t)) {
      t(message, lang)
    } else {
      message
    }
  }, error = function(e) {
    message
  })

  showNotification(
    tagList(icon(icon_name), " ", translated),
    type = "message",
    duration = duration
  )

  invisible(NULL)
}

#' Show warning notification
#'
#' @param message Warning message or translation key
#' @param duration Duration in seconds (uses constant if not specified)
#' @param lang Language code
#' @return NULL (invisible)
#'
#' @examples
#' notify_warning("Cache size limit reached")
notify_warning <- function(message, duration = NULL, lang = "en") {
  if (is.null(duration)) {
    duration <- NOTIFICATION_DURATION_WARNING
  }

  # Translate message if needed
  translated <- tryCatch({
    if (exists("t") && is.function(t)) {
      t(message, lang)
    } else {
      message
    }
  }, error = function(e) {
    message
  })

  showNotification(
    paste("⚠️", translated),
    type = "warning",
    duration = duration
  )

  invisible(NULL)
}

#' Show progress notification
#'
#' @param message Progress message or translation key
#' @param duration Duration in seconds (uses constant if not specified)
#' @param lang Language code
#' @return NULL (invisible)
#'
#' @examples
#' notify_progress("Generating data...")
#' notify_progress("notify_generating_data", lang = "fr")
notify_progress <- function(message, duration = NULL, lang = "en") {
  if (is.null(duration)) {
    duration <- NOTIFICATION_DURATION_PROGRESS
  }

  # Translate message if needed
  translated <- tryCatch({
    if (exists("t") && is.function(t)) {
      t(message, lang)
    } else {
      message
    }
  }, error = function(e) {
    message
  })

  showNotification(
    paste("🔄", translated),
    type = "message",
    duration = duration
  )

  invisible(NULL)
}

#' Show detailed statistics notification
#'
#' @param title Title for the notification
#' @param stats Named list or vector of statistics
#' @param duration Duration in seconds
#' @return NULL (invisible)
#'
#' @examples
#' notify_stats("Data Generation Complete", list(
#'   entries = 357,
#'   controls = 74,
#'   pressures = 36
#' ))
notify_stats <- function(title, stats, duration = NULL) {
  if (is.null(duration)) {
    duration <- NOTIFICATION_DURATION_SUCCESS
  }

  # Format statistics
  stats_text <- paste(names(stats), stats, sep = ": ", collapse = ", ")
  full_message <- paste("✅", title, "-", stats_text)

  showNotification(
    full_message,
    type = "message",
    duration = duration
  )

  invisible(NULL)
}

#' Show notification with custom type and icon
#'
#' @param message Message text
#' @param type Notification type ("message", "warning", "error", "info")
#' @param icon_emoji Emoji icon to prepend
#' @param duration Duration in seconds
#' @return NULL (invisible)
#'
#' @examples
#' notify_custom("Processing complete", "message", "🎉", 3)
notify_custom <- function(message, type = "message", icon_emoji = NULL, duration = NULL) {
  if (is.null(duration)) {
    duration <- get_notification_duration(type)
  }

  # Add icon if provided
  full_message <- if (!is.null(icon_emoji)) {
    paste(icon_emoji, message)
  } else {
    message
  }

  showNotification(
    full_message,
    type = type,
    duration = duration
  )

  invisible(NULL)
}

#' Show notification for data generation with detailed stats
#'
#' @param total_entries Total number of entries generated
#' @param unique_controls Number of unique controls
#' @param unique_pressures Number of unique pressures
#' @param duration Duration in seconds
#' @return NULL (invisible)
#'
#' @examples
#' notify_data_generated(357, 74, 36)
notify_data_generated <- function(total_entries, unique_controls, unique_pressures, duration = NULL) {
  if (is.null(duration)) {
    duration <- NOTIFICATION_DURATION_SUCCESS
  }

  message_text <- paste(
    "✅ Generated", total_entries, "entries with",
    unique_controls, "preventive controls across",
    unique_pressures, "environmental pressures!"
  )

  showNotification(
    message_text,
    type = "message",
    duration = duration
  )

  invisible(NULL)
}

#' Show batch notification for multiple messages
#'
#' @param messages Vector of messages
#' @param type Notification type
#' @param stagger_delay Delay between notifications in seconds
#' @return NULL (invisible)
#'
#' @examples
#' notify_batch(c("Step 1 complete", "Step 2 complete"), "message", 0.5)
notify_batch <- function(messages, type = "message", stagger_delay = 0.5) {
  for (i in seq_along(messages)) {
    showNotification(
      messages[i],
      type = type,
      duration = get_notification_duration(type)
    )

    # Add delay between notifications
    if (i < length(messages)) {
      Sys.sleep(stagger_delay)
    }
  }

  invisible(NULL)
}

# =============================================================================
# NOTIFICATION QUEUE (Advanced feature for managing multiple notifications)
# =============================================================================

.notification_queue <- new.env()
.notification_queue$messages <- list()
.notification_queue$processing <- FALSE

#' Add notification to queue
#'
#' @param message Message text
#' @param type Notification type
#' @param priority Priority level (1-10, higher = more important)
#' @return NULL (invisible)
add_to_notification_queue <- function(message, type = "message", priority = 5) {
  notification <- list(
    message = message,
    type = type,
    priority = priority,
    timestamp = Sys.time()
  )

  .notification_queue$messages <- c(.notification_queue$messages, list(notification))

  invisible(NULL)
}

#' Process notification queue
#'
#' @param max_notifications Maximum number to process
#' @return Number of notifications processed
process_notification_queue <- function(max_notifications = 5) {
  if (.notification_queue$processing) {
    return(0)
  }

  .notification_queue$processing <- TRUE
  on.exit(.notification_queue$processing <- FALSE)

  messages <- .notification_queue$messages

  if (length(messages) == 0) {
    return(0)
  }

  # Sort by priority (descending)
  priorities <- sapply(messages, function(x) x$priority)
  sorted_indices <- order(priorities, decreasing = TRUE)
  messages <- messages[sorted_indices]

  # Process top N notifications
  n_to_process <- min(length(messages), max_notifications)
  processed <- 0

  for (i in seq_len(n_to_process)) {
    msg <- messages[[i]]
    showNotification(
      msg$message,
      type = msg$type,
      duration = get_notification_duration(msg$type)
    )
    processed <- processed + 1
    Sys.sleep(0.3)  # Delay between notifications
  }

  # Remove processed notifications
  .notification_queue$messages <- messages[-seq_len(n_to_process)]

  processed
}

#' Clear notification queue
#'
#' @return Number of notifications cleared
clear_notification_queue <- function() {
  n_cleared <- length(.notification_queue$messages)
  .notification_queue$messages <- list()
  n_cleared
}

# =============================================================================
# END OF NOTIFICATION HELPERS
# =============================================================================

cat("✅ Notification helpers loaded successfully\n")
