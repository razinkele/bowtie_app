# =============================================================================
# Environmental Bowtie Risk Analysis - Network-Ready Launcher
# Version: 5.3.0
# Description: Launches app with network access using centralized configuration
# =============================================================================

library(shiny)

# Load centralized configuration
if (file.exists("config.R")) {
  source("config.R")
  host <- APP_CONFIG$DEFAULT_HOST
  port <- APP_CONFIG$DEFAULT_PORT
} else {
  # Fallback defaults
  host <- "0.0.0.0"
  port <- 3838
}

cat("=============================================================================\n")
cat("Starting Environmental Bowtie Risk Analysis Application...\n")
cat("Version:", ifelse(exists("APP_CONFIG"), APP_CONFIG$VERSION, "5.3.0"), "\n")
cat("=============================================================================\n\n")
cat("🌐 Server Configuration:\n")
cat("   Host:", host, ifelse(host == "0.0.0.0", "(network access enabled)", "(local only)"), "\n")
cat("   Port:", port, "\n\n")
cat("📍 Access URLs:\n")
cat("   Local:   http://localhost:", port, "/\n", sep = "")
cat("   Network: http://[YOUR_IP]:", port, "/\n", sep = "")
if (host == "0.0.0.0") {
  # Try to get local IP
  ip <- tryCatch({
    system("hostname -I 2>/dev/null | awk '{print $1}'", intern = TRUE)
  }, error = function(e) NULL)
  if (!is.null(ip) && length(ip) > 0 && nchar(ip) > 0) {
    cat("   Current: http://", ip, ":", port, "/\n", sep = "")
  }
}
cat("\n")

# Set options before running
options(shiny.maxRequestSize = 30*1024^2)  # 30MB max file size

# Launch the app using runApp (will source global.R, ui.R, server.R automatically)
shiny::runApp(
  appDir = ".",
  host = host,
  port = port,
  launch.browser = TRUE
)