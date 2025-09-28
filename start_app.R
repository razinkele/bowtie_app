# Simple app launcher for Environmental Bowtie Risk Analysis
# This script should work around any server function conflicts

library(shiny)

# Source the files in order
cat("Loading global configuration...\n")
source("global.R")

cat("Loading UI...\n")
source("ui.R")

cat("Loading server...\n")
source("server.R")

cat("Starting app...\n")

# Start the app with explicit options
options(shiny.maxRequestSize = 30*1024^2)  # 30MB max file size
options(shiny.host = "0.0.0.0")
options(shiny.port = 3838)

# Launch with error handling
tryCatch({
  shinyApp(ui = ui, server = server)
}, error = function(e) {
  cat("Error starting app:", e$message, "\n")
  cat("Trying alternative method...\n")

  # Alternative launch method
  shiny::runApp(
    appDir = ".",
    host = "0.0.0.0",
    port = 3838,
    launch.browser = FALSE
  )
})