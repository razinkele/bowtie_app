# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application Launcher
# Version: 5.3.0 (Production-Ready Edition)
# Date: November 2025
# Author: Marbefes Team & AI Assistant
# Description: Production-ready with comprehensive deployment framework, UI improvements, and bug fixes
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