# Test helper: ensure vocabulary code and AI helpers are loaded for tests
# Determine repo root without relying on other helpers (ensures correct ordering of helper files)
repo_root <- NULL
# Try naive parent traversal
candidate_dirs <- c('.', '..', '../..', '../../..', '../../../..')
for (d in candidate_dirs) {
  if (file.exists(file.path(d, 'bowtie_app.Rproj')) || file.exists(file.path(d, 'VERSION')) || dir.exists(file.path(d, '.git'))) {
    repo_root <- normalizePath(d)
    break
  }
}
if (is.null(repo_root)) {
  # fallback to one level up
  repo_root <- normalizePath('..', mustWork = FALSE)
}
tryCatch({
  # Ensure core utilities are available (e.g., bowtie_log)
  tryCatch({
    source(file.path(repo_root, "utils.R"), local = TRUE)
  }, error = function(e) {
    message("helper-load-vocabulary: failed to source utils.R (", e$message, ")")
  })

  source(file.path(repo_root, "vocabulary.R"), local = TRUE)
}, error = function(e) {
  message("helper-load-vocabulary: failed to source vocabulary.R (", e$message, ")")
})
tryCatch({
  source(file.path(repo_root, "vocabulary-ai-helpers.R"), local = TRUE)
}, error = function(e) {
  message("helper-load-vocabulary: failed to source vocabulary-ai-helpers.R (", e$message, ")")
})
