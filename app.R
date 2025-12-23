# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application Launcher
# Version: 5.3.0 (Production-Ready Edition)
# Date: November 2025
# Author: Marbefes Team & AI Assistant
# Description: Production-ready with comprehensive deployment framework, UI improvements, and bug fixes
# =============================================================================

# Determine application directory robustly and source files relative to it
bowtie_log("🚀 Loading application modules...")
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

# Load UI definition
bowtie_log("🎨 Loading user interface...")
source(file.path(app_dir, "ui.R"))

# Load server logic
bowtie_log("⚙️ Loading server logic...")
source(file.path(app_dir, "server.R"))

# Launch the application
bowtie_log("🌐 Starting Shiny web server...", .verbose = TRUE)
bowtie_log("🎉 Environmental Bowtie Risk Analysis Application ready to launch!", .verbose = TRUE)
bowtie_log("📋 Features: Bowtie diagrams, Bayesian networks, Guided workflow, Save/Load progress", .verbose = TRUE)
# Visual separators are optional in verbose mode
bowtie_log("═══════════════════════════════════════════════════════════════", .verbose = TRUE)

# Only launch the Shiny app when running interactively (avoid launching during test sourcing)
if (interactive()) {
  shinyApp(ui = ui, server = server)
}