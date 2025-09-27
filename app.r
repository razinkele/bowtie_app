# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application Launcher
# Version: 5.1.0 (Modern Framework Edition)
# Date: September 2025
# Author: Marbefes Team & AI Assistant
# Description: Modular application launcher for enhanced maintainability
# =============================================================================

# Load global configuration, packages, and utility functions
cat("🚀 Loading application modules...\n")
source("global.R")

# Load UI definition
cat("🎨 Loading user interface...\n")
source("ui.R")

# Load server logic
cat("⚙️ Loading server logic...\n")
source("server.R")

# Launch the application
cat("🌐 Starting Shiny web server...\n")
cat("🎉 Environmental Bowtie Risk Analysis Application ready to launch!\n")
cat("📋 Features: Bowtie diagrams, Bayesian networks, Guided workflow, Save/Load progress\n")
cat("═══════════════════════════════════════════════════════════════\n")

shinyApp(ui = ui, server = server)