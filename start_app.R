# Simple app launcher for Environmental Bowtie Risk Analysis
# Uses runApp to avoid double-loading issues

library(shiny)

cat("Starting Environmental Bowtie Risk Analysis Application...\n")
cat("Loading on http://127.0.0.1:4848...\n")
cat("Access locally: http://localhost:4848\n\n")

# Set options before running
options(shiny.maxRequestSize = 30*1024^2)  # 30MB max file size

# Launch the app using runApp (will source global.R, ui.R, server.R automatically)
shiny::runApp(
  appDir = ".",
  host = "127.0.0.1",
  port = 4848,
  launch.browser = TRUE
)