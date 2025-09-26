# Simple app launcher for Environmental Bowtie Risk Analysis Application v5.1
# This script provides a clean way to launch the application

cat("🚀 Environmental Bowtie Risk Analysis Application v5.1.0\n")
cat("📋 Simple launcher to avoid package conflicts\n\n")

# Set options for better Shiny performance
options(shiny.maxRequestSize = 30*1024^2)  # 30MB max file size
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Launch the application
tryCatch({
  source("app.r")
}, error = function(e) {
  cat("❌ Error launching application:", e$message, "\n")
  cat("💡 Try running the individual components first:\n")
  cat("   - source('utils.r')\n")
  cat("   - source('vocabulary.r')\n")
  cat("   - source('app.r')\n")
})