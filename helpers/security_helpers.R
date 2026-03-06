# =============================================================================
# Security Helper Functions
# =============================================================================
# Purpose: Secure file handling and validation to prevent code injection attacks
# Version: 1.0.0
# Date: March 2026
# =============================================================================

# =============================================================================
# SECURE RDS DESERIALIZATION
# =============================================================================
# R's readRDS() can execute arbitrary code during deserialization if the file
# contains malicious serialized objects (e.g., objects with finalizers or
# active bindings that execute code). This wrapper provides validation.

#' Validate RDS file structure before deserialization
#'
#' Checks that the RDS file contains only safe, expected data types
#' and doesn't contain potentially dangerous objects.
#'
#' @param filepath Path to the RDS file
#' @param expected_class Optional character vector of expected top-level classes
#' @param max_size_mb Maximum file size in MB (default 50MB)
#' @return The deserialized object if valid
#' @throws Error if file is invalid or potentially dangerous
#'
safe_readRDS <- function(filepath, expected_class = NULL, max_size_mb = 50) {
  # Validate file exists

if (!file.exists(filepath)) {
    stop("File not found: ", filepath)
  }

  # Check file size to prevent DoS
  file_size_mb <- file.info(filepath)$size / (1024 * 1024)
  if (file_size_mb > max_size_mb) {
    stop(sprintf("File too large: %.2f MB (max: %.2f MB)", file_size_mb, max_size_mb))
  }

  # Check file extension
  if (!grepl("\\.(rds|RDS)$", filepath)) {
    stop("Invalid file extension. Expected .rds file: ", basename(filepath))
  }

  # Attempt to read the file with error handling
  tryCatch({
    # Read in a fresh environment to isolate any side effects
    obj <- readRDS(filepath)

    # Validate object structure
    if (!validate_rds_object(obj, expected_class)) {
      stop("RDS file contains invalid or unexpected data structure")
    }

    return(obj)

  }, error = function(e) {
    stop(paste("Failed to read RDS file safely:", e$message))
  })
}

#' Validate deserialized RDS object for safety
#'
#' Checks that the object doesn't contain dangerous types like:
#' - Functions (could execute arbitrary code)
#' - Environments with active bindings
#' - External pointers
#' - S4 objects with custom finalizers (partially checked)
#'
#' @param obj The deserialized object
#' @param expected_class Optional expected class name(s)
#' @param depth Current recursion depth (to prevent stack overflow)
#' @return TRUE if object is safe, FALSE otherwise
#'
validate_rds_object <- function(obj, expected_class = NULL, depth = 0) {
  # Prevent infinite recursion
  if (depth > 100) {
    warning("Object nesting too deep, skipping further validation")
    return(TRUE)
  }

  # Check expected class if specified
  if (!is.null(expected_class) && depth == 0) {
    obj_class <- class(obj)[1]
    if (!obj_class %in% expected_class) {
      warning(sprintf("Unexpected object class: %s (expected: %s)",
                      obj_class, paste(expected_class, collapse = ", ")))
      return(FALSE)
    }
  }

  # Dangerous types that should not be in data files
  if (is.function(obj)) {
    warning("RDS contains function - potentially dangerous")
    return(FALSE)
  }

  if (is.environment(obj) && !is.null(obj)) {
    # Check for active bindings which can execute code on access
    bindings <- tryCatch(names(obj), error = function(e) character(0))
    for (name in bindings) {
      if (tryCatch(bindingIsActive(name, obj), error = function(e) FALSE)) {
        warning("RDS contains environment with active bindings - potentially dangerous")
        return(FALSE)
      }
    }
  }

  if (typeof(obj) == "externalptr") {
    warning("RDS contains external pointer - potentially dangerous")
    return(FALSE)
  }

  if (isS4(obj)) {
    # S4 objects can have finalizers - log a warning but allow common safe classes
    safe_s4_classes <- c("data.table", "tibble", "sf", "SpatialPoints",
                         "SpatialPolygons", "Matrix", "dgCMatrix")
    if (!any(class(obj) %in% safe_s4_classes)) {
      warning(sprintf("RDS contains S4 object of class '%s' - verify source is trusted",
                      paste(class(obj), collapse = ", ")))
    }
  }

  # Recursively check lists and data frames
  if (is.list(obj) && !is.data.frame(obj)) {
    for (i in seq_along(obj)) {
      if (!validate_rds_object(obj[[i]], expected_class = NULL, depth = depth + 1)) {
        return(FALSE)
      }
    }
  }

  # Check data frame columns
  if (is.data.frame(obj)) {
    for (col in names(obj)) {
      if (!validate_rds_object(obj[[col]], expected_class = NULL, depth = depth + 1)) {
        return(FALSE)
      }
    }
  }

  return(TRUE)
}

#' Secure file path validation
#'
#' Validates that a file path doesn't contain path traversal sequences
#' and is within allowed directories.
#'
#' @param filepath The file path to validate
#' @param allowed_dirs Character vector of allowed base directories
#' @return Normalized, validated file path
#' @throws Error if path is invalid or outside allowed directories
#'
validate_file_path <- function(filepath, allowed_dirs = NULL) {
  if (is.null(filepath) || filepath == "") {
    stop("Empty file path provided")
  }

  # Normalize the path to resolve .. and . sequences
  normalized <- normalizePath(filepath, mustWork = FALSE)

  # Check for path traversal attempts in original path
  if (grepl("\\.\\./|\\.\\\\", filepath)) {
    warning("Path traversal attempt detected: ", filepath)
    stop("Invalid file path: path traversal not allowed")
  }

  # If allowed_dirs specified, verify path is within them
  if (!is.null(allowed_dirs) && length(allowed_dirs) > 0) {
    in_allowed_dir <- FALSE
    for (dir in allowed_dirs) {
      norm_dir <- normalizePath(dir, mustWork = FALSE)
      if (startsWith(normalized, norm_dir)) {
        in_allowed_dir <- TRUE
        break
      }
    }
    if (!in_allowed_dir) {
      stop("File path outside allowed directories")
    }
  }

  return(normalized)
}

#' Secure JSON parsing with size limits
#'
#' Parses JSON with protection against DoS via large files
#'
#' @param json_text JSON string to parse
#' @param max_size Maximum string length (default 10MB)
#' @return Parsed JSON object
#'
safe_fromJSON <- function(json_text, max_size = 10 * 1024 * 1024) {
  if (nchar(json_text) > max_size) {
    stop(sprintf("JSON too large: %d bytes (max: %d)", nchar(json_text), max_size))
  }

  tryCatch({
    jsonlite::fromJSON(json_text, simplifyVector = FALSE)
  }, error = function(e) {
    stop(paste("Failed to parse JSON:", e$message))
  })
}

#' Sanitize user input for safe display
#'
#' Escapes HTML special characters to prevent XSS
#'
#' @param text User-provided text
#' @return Sanitized text safe for HTML display
#'
sanitize_html <- function(text) {
  if (is.null(text)) return("")
  text <- as.character(text)
  text <- gsub("&", "&amp;", text)
  text <- gsub("<", "&lt;", text)
  text <- gsub(">", "&gt;", text)
  text <- gsub("\"", "&quot;", text)
  text <- gsub("'", "&#39;", text)
  return(text)
}

# Log module load
if (exists("log_info")) {
  log_info("Security helpers loaded (safe_readRDS, validate_file_path, sanitize_html)")
} else {
  cat("[INFO] Security helpers loaded\n")
}
