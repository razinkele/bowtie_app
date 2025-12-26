# =============================================================================
# Environmental Bowtie Risk Analysis - Network-Ready Launcher
# Version: 5.4.0
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

bowtie_log("=============================================================================")
bowtie_log("Starting Environmental Bowtie Risk Analysis Application...", .verbose = TRUE)
bowtie_log("Version:", ifelse(exists("APP_CONFIG"), APP_CONFIG$VERSION, "5.4.0"), .verbose = TRUE)
bowtie_log("=============================================================================\n", .verbose = TRUE)

bowtie_log("🌐 Server Configuration:", .verbose = TRUE)
bowtie_log("   Host:", host, ifelse(host == "0.0.0.0", "(network access enabled)", "(local only)"), .verbose = TRUE)
bowtie_log("   Port:", port, .verbose = TRUE)

bowtie_log("📍 Access URLs:", .verbose = TRUE)
bowtie_log(paste0("   Local:   http://localhost:", port, "/"), .verbose = TRUE)
bowtie_log(paste0("   Network: http://[YOUR_IP]:", port, "/"), .verbose = TRUE)
if (host == "0.0.0.0") {
  # Try to get local IP (cross-platform)
  ip <- tryCatch({
    if (.Platform$OS.type == "windows") {
      # Windows: Use ipconfig and parse output
      ip_output <- system("ipconfig", intern = TRUE)
      # Find IPv4 Address line
      ip_lines <- ip_output[grepl("IPv4.*:", ip_output)]
      if (length(ip_lines) > 0) {
        # Extract IP from first match
        ip_addr <- gsub(".*: ", "", ip_lines[1])
        ip_addr <- trimws(ip_addr)
        # Filter out loopback
        if (!grepl("^127\\.", ip_addr)) {
          return(ip_addr)
        }
      }
      return(NULL)
    } else {
      # Linux/Mac: Use hostname -I
      ip_result <- system("hostname -I 2>/dev/null | awk '{print $1}'", intern = TRUE)
      if (length(ip_result) > 0 && nchar(ip_result[1]) > 0) {
        return(ip_result[1])
      }
      return(NULL)
    }
  }, error = function(e) {
    return(NULL)
  })

  # Display IP if found
  if (!is.null(ip) && length(ip) == 1 && nchar(ip) > 0) {
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