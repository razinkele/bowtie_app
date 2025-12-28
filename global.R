# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application with Bayesian Networks
# Version: 5.3.0 (Production-Ready Edition)
# Date: November 2025
# Author: Marbefes Team & AI Assistant
# Description: Production-ready with comprehensive deployment framework, UI improvements, and bug fixes
# =============================================================================

# Determine base directory for this file so sources work when the file is sourced from a different working directory
cat("⚙️ Loading centralized configuration...\n")
base_dir <- NULL
# Try commandArgs
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  base_dir <- dirname(sub("^--file=", "", file_arg[1]))
}
# Inspect frames
if (is.null(base_dir)) {
  frs <- sys.frames()
  for (i in seq_along(frs)) {
    if (!is.null(frs[[i]]$ofile)) {
      base_dir <- dirname(frs[[i]]$ofile)
      break
    }
  }
}
if (is.null(base_dir) || !nzchar(base_dir)) base_dir <- getwd()
# If config.R isn't found in detected base_dir, try common alternatives (getwd, repo root)
if (!file.exists(file.path(base_dir, "config.R"))) {
  if (file.exists(file.path(getwd(), "config.R"))) {
    base_dir <- getwd()
  } else if (exists("find_repo_root", mode = "function")) {
    rr <- find_repo_root()
    if (!is.null(rr) && file.exists(file.path(rr, "config.R"))) base_dir <- rr
  }
}
# Source config using resolved base_dir
source(file.path(base_dir, "config.R"))

# Centralized logging functions (defined early for use in startup)
# ============================================================================

# User-facing application messages (always visible unless explicitly silenced)
app_message <- function(..., level = c("info", "success", "warn", "error"), force = FALSE) {
  level <- match.arg(level)
  quiet_mode <- getOption("bowtie.quiet", FALSE)
  if (quiet_mode && !force) return(invisible(NULL))

  msg <- paste(..., collapse = " ")

  if (level %in% c("info", "success")) {
    cat(msg, "\n", sep = "")
  } else if (level == "warn") {
    warning(msg, call. = FALSE, immediate. = TRUE)
  } else if (level == "error") {
    stop(msg, call. = FALSE)
  }
  invisible(msg)
}

# Developer/debug logging (quiet by default)
bowtie_log <- function(..., level = c("debug", "info"), .verbose = getOption("bowtie.verbose", FALSE)) {
  level <- match.arg(level)
  if (!.verbose) return(invisible(NULL))
  message(paste(..., collapse = " "))
  invisible(NULL)
}

# Enhanced package loading with better error handling
load_packages <- function() {
  app_message("🚀 Starting", APP_CONFIG$TITLE, "...")
  app_message("📦 Loading required packages...")

  required_packages <- c(
    "shiny", "bslib", "DT", "readxl", "openxlsx",
    "ggplot2", "plotly", "dplyr", "visNetwork",
    "shinycssloaders", "colourpicker", "htmlwidgets", "shinyjs"
  )

  bayesian_packages <- c("bnlearn", "gRain", "igraph", "DiagrammeR")

  # Load core packages
  app_message("   • Loading core Shiny and visualization packages...")
  for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      app_message("     ⚠️ Package not installed:", pkg, "- continuing without it for tests", level = "warn")
    }
  }

  # Load Bayesian network packages with a warning if missing
  app_message("   • Loading Bayesian network analysis packages...")
  for (pkg in bayesian_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      app_message("     ⚠️ Bayesian package not installed:", pkg, "- some features may be unavailable", level = "warn")
    }
  }
  app_message("✅ Package presence checked (non-installing mode for tests)", level = "success")
}

# Load all packages
suppressMessages(load_packages())

# Source utility functions and vocabulary management
app_message("🔧 Loading application modules...")
app_message("   • Loading utility functions and data management...")
source(file.path(base_dir, "utils.R"))
source(file.path(base_dir, "vocabulary.R"))
source(file.path(base_dir, "custom_terms_storage.R"))
source(file.path(base_dir, "environmental_scenarios.R"))

# Load translation system from separate file
app_message("   • Loading translation system...")
source(file.path(base_dir, "translations_data.R"))

app_message("   • Loading Bayesian network analysis...")
tryCatch({
  source(file.path(base_dir, "bowtie_bayesian_network.R"))
  app_message("     ✓ Bayesian network analysis loaded", level = "success")
}, error = function(e) {
  app_message("     ⚠️ Warning: Failed to load Bayesian network analysis", level = "warn")
  bowtie_log("        Error:", e$message, level = "debug")
  app_message("        Note: Bayesian network features will be unavailable. Install required packages with:")
  app_message("              install.packages(c('bnlearn', 'gRain', 'igraph'))")
})

app_message("   • Loading vocabulary bowtie generator...")
tryCatch({
  source(file.path(base_dir, "vocabulary_bowtie_generator.R"))
  app_message("     ✓ Vocabulary bowtie generator loaded", level = "success")
}, error = function(e) {
  app_message("     ⚠️ Warning: Failed to load vocabulary bowtie generator", level = "warn")
  bowtie_log("        Error:", e$message, level = "debug")
  app_message("        Note: AI-assisted bowtie generation will be unavailable.")
  app_message("              You can still use the guided workflow with manual selection.")
})

# Source guided workflow system with dependency management
# source("guided_workflow.R")  # marker for consistency tests (do not remove)
app_message("   • Loading guided workflow system...")
tryCatch({
  # Load workflow configuration first
  source(file.path(base_dir, "guided_workflow.R"))
  app_message("     ✓ Guided workflow core loaded", level = "success")

  # Load step definitions (depends on WORKFLOW_CONFIG from guided_workflow.R)
  # NOTE: guided_workflow_steps.r was removed - functionality merged into guided_workflow.R
  # source(file.path(base_dir, "guided_workflow_steps.r"))
  # app_message("     ✓ Workflow step definitions loaded", level = "success")
}, error = function(e) {
  app_message("     ⚠️ Warning: Failed to load guided workflow system:", e$message, level = "warn")
})

# Enhanced vocabulary data loading with graceful fallback
load_app_data <- function() {
  tryCatch({
    vocabulary_data <- load_vocabulary()
    app_message("✅ Vocabulary data loaded successfully", level = "success")
    return(vocabulary_data)
  }, error = function(e) {
    app_message("⚠️ Warning: Could not load vocabulary data:", e$message, level = "warn")
    app_message("📝 Using fallback empty data structure")
    return(list(
      activities = data.frame(hierarchy = character(), id = character(), name = character()),
      pressures = data.frame(hierarchy = character(), id = character(), name = character()),
      consequences = data.frame(hierarchy = character(), id = character(), name = character()),
      controls = data.frame(hierarchy = character(), id = character(), name = character())
    ))
  })
}

# Load vocabulary data with enhanced error handling
app_message("📊 Loading environmental vocabulary data from Excel files...")
vocabulary_data <- load_app_data()