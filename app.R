# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application Launcher
# Version: 5.7.0 (Scientific Foundations Edition)
# Date: March 2026
# Author: Marbefes Team & AI Assistant
# Description: Production-ready with comprehensive bug fixes and filename normalization
# =============================================================================

# Early logging function (before global.R is loaded)
# This is a minimal version - full bowtie_log is defined in utils.R
.early_log <- function(..., .verbose = getOption("bowtie.verbose", FALSE)) {
  if (.verbose) message(paste(..., collapse = " "))
  invisible(NULL)
}

# Determine application directory robustly and source files relative to it
.early_log("🚀 Loading application modules...")
# Try multiple strategies to find the directory containing this file (works when sourced or run via Rscript)
app_dir <- NULL
# Strategy 1: commandArgs (if launched via: Rscript --file=app.R)
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  app_dir <- dirname(sub("^--file=", "", file_arg[1]))
}
# Strategy 2: inspect call frames for 'ofile'
if (is.null(app_dir)) {
  frs <- sys.frames()
  for (i in seq_along(frs)) {
    if (!is.null(frs[[i]]$ofile)) {
      app_dir <- dirname(frs[[i]]$ofile)
      break
    }
  }
}
# Strategy 3: if still NULL, fall back to working directory
if (is.null(app_dir) || !nzchar(app_dir)) {
  app_dir <- getwd()
}

# Source files from the determined app directory
source(file.path(app_dir, "global.R"))

# Set upload size limit from config (must be after global.R loads APP_CONFIG)
max_size_mb <- if (exists("APP_CONFIG") && !is.null(APP_CONFIG$UPLOAD$MAX_FILE_SIZE_MB)) {
  APP_CONFIG$UPLOAD$MAX_FILE_SIZE_MB
} else {
  100
}
options(shiny.maxRequestSize = max_size_mb * 1024^2)

# Load UI definition
bowtie_log("🎨 Loading user interface...")
source(file.path(app_dir, "ui.R"))

# Load server logic
bowtie_log("⚙️ Loading server logic...")
source(file.path(app_dir, "server.R"))

# Launch the application
bowtie_log("🌐 Starting Shiny web server...")
bowtie_log("🎉 Environmental Bowtie Risk Analysis Application ready to launch!")
bowtie_log("📋 Features: Bowtie diagrams, Bayesian networks, Guided workflow, Save/Load progress")
# Visual separators are optional in verbose mode
bowtie_log("═══════════════════════════════════════════════════════════════")

# Only launch the Shiny app when running interactively (avoid launching during test sourcing)
if (interactive()) {
  shinyApp(ui = ui, server = server)
}