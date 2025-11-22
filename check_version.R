#!/usr/bin/env Rscript
# =============================================================================
# Version Consistency Checker
# Validates that all version numbers are synchronized across the application
# =============================================================================

cat("🔍 Checking version consistency across application files...\n")
cat("═══════════════════════════════════════════════════════════\n\n")

# Load configuration
source("config.R")
config_version <- APP_CONFIG$VERSION

cat("📋 Primary Version Source (config.R):\n")
cat("   Version:", config_version, "\n\n")

# Check VERSION file
version_file_content <- tryCatch({
  trimws(readLines("VERSION")[1])
}, error = function(e) {
  "FILE NOT FOUND"
})

cat("📄 VERSION file:\n")
cat("   Version:", version_file_content, "\n")
if (version_file_content == config_version) {
  cat("   ✅ MATCH\n\n")
} else {
  cat("   ❌ MISMATCH!\n\n")
}

# Check file headers
files_to_check <- c(
  "global.R" = 3,
  "app.R" = 3,
  "requirements.R" = 3
)

cat("📝 Checking file headers:\n")
all_match <- TRUE

for (file_name in names(files_to_check)) {
  line_num <- files_to_check[file_name]
  line_content <- tryCatch({
    readLines(file_name)[line_num]
  }, error = function(e) {
    "FILE NOT FOUND"
  })

  # Extract version from line (look for X.Y.Z pattern)
  version_match <- regmatches(line_content, regexpr("[0-9]+\\.[0-9]+\\.[0-9]+", line_content))

  if (length(version_match) > 0) {
    file_version <- version_match[1]
    match_status <- if (file_version == config_version) "✅" else "❌"
    cat(sprintf("   %s %s (line %d): %s\n", match_status, file_name, line_num, file_version))

    if (file_version != config_version) {
      all_match <- FALSE
    }
  } else {
    cat(sprintf("   ⚠️  %s: No version found\n", file_name))
    all_match <- FALSE
  }
}

cat("\n")

# Summary
cat("═══════════════════════════════════════════════════════════\n")
if (all_match && version_file_content == config_version) {
  cat("✅ ALL VERSION NUMBERS ARE CONSISTENT!\n")
  cat("📦 Current Version: ", config_version, "\n")
} else {
  cat("❌ VERSION INCONSISTENCIES DETECTED!\n")
  cat("Please update all files to match config.R version: ", config_version, "\n")
}
cat("═══════════════════════════════════════════════════════════\n")
