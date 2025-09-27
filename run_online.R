# Run the Environmental Bowtie Risk Analysis App Online
# =============================================================================

# Load the modular application
source("global.R")
source("ui.R")
source("server.R")

# Run the app with online configuration
options(shiny.host = "0.0.0.0")  # Allow external connections
options(shiny.port = 3838)       # Use standard Shiny port

cat("🌐 Starting Environmental Bowtie Risk Analysis Application...\n")
cat("🔗 Application will be available at: http://localhost:3838\n")
cat("📱 Access from network: http://[your-ip]:3838\n")
cat("═══════════════════════════════════════════════════════════════\n")

# Launch the application
shinyApp(ui = ui, server = server)