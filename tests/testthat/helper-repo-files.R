# Helper: repo-aware file lookup utilities
# Provides read_repo_file() used across test files to deterministically
# pick files from the intended repository root (avoids ambiguous parent
# copies in OneDrive or sibling projects).

find_repo_root <- function(start = getwd()) {
  cur <- normalizePath(start, mustWork = FALSE)
  # Walk up until we find a repo marker (Rproj, VERSION, or .git)
  repeat {
    if (file.exists(file.path(cur, "bowtie_app.Rproj")) ||
        file.exists(file.path(cur, "VERSION")) ||
        dir.exists(file.path(cur, ".git"))) {
      return(cur)
    }
    parent <- dirname(cur)
    if (identical(parent, cur)) break
    cur <- parent
  }
  return(NULL)
}

# Read a file located in the repository tree. Prefer the file inside
# the detected repository root; fallback to a smaller set of search
# directories if repo root cannot be determined.
read_repo_file <- function(filename) {
  # Prefer a file within the repository root
  repo_root <- find_repo_root()
  if (!is.null(repo_root)) {
    files <- list.files(repo_root, recursive = TRUE, full.names = TRUE)
    candidates <- files[tolower(basename(files)) == tolower(filename)]
    if (length(candidates) > 0) {
      return(tryCatch(readLines(candidates[1], warn = FALSE), error = function(e) character(0)))
    }
    # Also check directly at root for simple names
    root_path <- file.path(repo_root, filename)
    if (file.exists(root_path)) return(tryCatch(readLines(root_path, warn = FALSE), error = function(e) character(0)))
  }

  # Fallback: search a bounded set of parent/relative directories
  search_dirs <- c('.', '..', '../..', '../../..', '../../../..')
  for (d in search_dirs) {
    if (!dir.exists(d)) next
    files <- list.files(d, recursive = TRUE, full.names = TRUE)
    candidates <- files[tolower(basename(files)) == tolower(filename)]
    if (length(candidates) > 0) return(tryCatch(readLines(candidates[1], warn = FALSE), error = function(e) character(0)))
  }

  stop(paste('File not found in repo tree:', filename))
}

# Return full path to a repo file, or NULL if not found (handles case-insensitive matches)
find_repo_file_path <- function(filename) {
  repo_root <- find_repo_root()
  if (!is.null(repo_root)) {
    files <- list.files(repo_root, recursive = TRUE, full.names = TRUE)
    candidates <- files[tolower(basename(files)) == tolower(filename)]
    if (length(candidates) > 0) return(normalizePath(candidates[1], winslash = "/", mustWork = TRUE))
    root_path <- file.path(repo_root, filename)
    if (file.exists(root_path)) return(normalizePath(root_path, winslash = "/", mustWork = TRUE))
  }

  search_dirs <- c('.', '..', '../..', '../../..')
  for (d in search_dirs) {
    if (!dir.exists(d)) next
    files <- list.files(d, recursive = TRUE, full.names = TRUE)
    candidates <- files[tolower(basename(files)) == tolower(filename)]
    if (length(candidates) > 0) return(normalizePath(candidates[1], winslash = "/", mustWork = TRUE))
  }

  return(NULL)
}

# Variation that returns character(0) instead of error when not found
read_repo_file_if_exists <- function(filename) {
  tryCatch(read_repo_file(filename), error = function(e) character(0))
}
