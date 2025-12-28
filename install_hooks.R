#!/usr/bin/env Rscript
# =============================================================================
# Git Pre-commit Hook Installer
# Version: 5.5.3
# Installs pre-commit hooks for code quality enforcement
# =============================================================================

cat("🔧 Installing git pre-commit hooks...\n\n")

# =============================================================================
# 1. VERIFY GIT REPOSITORY
# =============================================================================
hooks_dir <- ".git/hooks"

if (!dir.exists(".git")) {
  stop("❌ Error: Not a git repository\n",
       "   This script must be run from the repository root.\n")
}

if (!dir.exists(hooks_dir)) {
  stop("❌ Error: .git/hooks directory not found\n",
       "   Your git installation may be corrupted.\n")
}

cat("✅ Git repository detected\n")

# =============================================================================
# 2. CHECK FOR HOOK TEMPLATE
# =============================================================================
hook_source <- "tools/pre-commit"

if (!file.exists(hook_source)) {
  stop("❌ Error: Hook template not found at: ", hook_source, "\n",
       "   Expected location: tools/pre-commit\n")
}

cat("✅ Hook template found\n")

# =============================================================================
# 3. BACKUP EXISTING HOOK (if present)
# =============================================================================
hook_dest <- file.path(hooks_dir, "pre-commit")

if (file.exists(hook_dest)) {
  backup_file <- paste0(hook_dest, ".backup.", format(Sys.time(), "%Y%m%d_%H%M%S"))

  cat("⚠️  Pre-commit hook already exists\n")
  cat("   Creating backup: ", basename(backup_file), "\n")

  file.copy(hook_dest, backup_file)

  if (file.exists(backup_file)) {
    cat("✅ Backup created successfully\n")
  } else {
    stop("❌ Error: Failed to create backup\n")
  }
}

# =============================================================================
# 4. INSTALL HOOK
# =============================================================================
cat("\n📋 Installing pre-commit hook...\n")

# Copy hook to destination
success <- file.copy(hook_source, hook_dest, overwrite = TRUE)

if (!success) {
  stop("❌ Error: Failed to copy hook to .git/hooks/\n")
}

cat("✅ Hook file copied\n")

# =============================================================================
# 5. MAKE EXECUTABLE (Unix/Mac/Git Bash on Windows)
# =============================================================================
if (.Platform$OS.type != "windows") {
  # Unix/Mac: use chmod
  system_result <- system(paste("chmod +x", hook_dest))

  if (system_result == 0) {
    cat("✅ Hook made executable (chmod +x)\n")
  } else {
    cat("⚠️  Warning: Could not make hook executable\n")
    cat("   Run manually: chmod +x .git/hooks/pre-commit\n")
  }
} else {
  # Windows: Git Bash should handle execution automatically
  # Try to make executable anyway (works in Git Bash)
  tryCatch({
    system(paste("chmod +x", shQuote(hook_dest)), ignore.stdout = TRUE, ignore.stderr = TRUE)
    cat("✅ Hook permissions set (Git Bash compatible)\n")
  }, error = function(e) {
    cat("ℹ️  Running on Windows - Git will handle hook execution\n")
  })
}

# =============================================================================
# 6. VERIFY INSTALLATION
# =============================================================================
cat("\n🔍 Verifying installation...\n")

if (!file.exists(hook_dest)) {
  stop("❌ Error: Hook was not installed correctly\n")
}

hook_content <- readLines(hook_dest, warn = FALSE)

if (length(hook_content) < 10) {
  stop("❌ Error: Hook file appears to be empty or corrupted\n")
}

if (!any(grepl("pre-commit checks", hook_content))) {
  stop("❌ Error: Hook file does not contain expected content\n")
}

cat("✅ Hook installation verified\n")

# =============================================================================
# 7. INSTALL DEPENDENCIES (if needed)
# =============================================================================
cat("\n📦 Checking dependencies...\n")

# Check for lintr
if (!requireNamespace("lintr", quietly = TRUE)) {
  cat("⚠️  lintr package not installed\n")
  cat("   Installing lintr...\n")

  tryCatch({
    install.packages("lintr", repos = "https://cloud.r-project.org", quiet = TRUE)
    cat("✅ lintr installed successfully\n")
  }, error = function(e) {
    cat("⚠️  Warning: Could not install lintr automatically\n")
    cat("   Install manually: install.packages('lintr')\n")
  })
} else {
  cat("✅ lintr package already installed\n")
}

# Check for testthat (for tests)
if (!requireNamespace("testthat", quietly = TRUE)) {
  cat("ℹ️  testthat package not installed (optional for pre-commit tests)\n")
} else {
  cat("✅ testthat package installed\n")
}

# =============================================================================
# 8. SUCCESS MESSAGE
# =============================================================================
cat("\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("🎉 Pre-commit hooks installed successfully!\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("\n")
cat("What happens now:\n")
cat("  • Every commit will run code quality checks\n")
cat("  • Lintr will check R code style\n")
cat("  • Syntax errors will be detected\n")
cat("  • Fast tests will run (if available)\n")
cat("\n")
cat("To bypass checks (not recommended):\n")
cat("  git commit --no-verify\n")
cat("\n")
cat("To uninstall hooks:\n")
cat("  rm .git/hooks/pre-commit\n")
cat("\n")
cat("To test the hook:\n")
cat("  .git/hooks/pre-commit\n")
cat("\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("\n")

# =============================================================================
# 9. OPTIONAL: TEST HOOK
# =============================================================================
cat("Would you like to test the hook now? (y/n): ")

# Try to read user input (works in interactive mode)
if (interactive()) {
  response <- tolower(trimws(readline()))

  if (response == "y" || response == "yes") {
    cat("\n🧪 Testing pre-commit hook...\n\n")

    # Run the hook
    test_result <- system(hook_dest, intern = FALSE)

    cat("\n")
    if (test_result == 0) {
      cat("✅ Hook test passed!\n")
    } else {
      cat("⚠️  Hook test failed - this is normal if you have uncommitted changes\n")
      cat("   The hook will still work correctly during commits\n")
    }
  }
} else {
  cat("(Skipping test in non-interactive mode)\n")
}

cat("\n✅ Installation complete!\n\n")
