# =============================================================================
# Optimized Startup Script for Environmental Bowtie App
# Version: 5.1.0 - Reduces package conflicts and improves load times
# Date: September 2025
# =============================================================================

cat("🚀 Starting Environmental Bowtie Risk Analysis Application v5.1.0\n")
cat("📦 Loading packages with optimized startup...\n")

# Suppress startup messages for cleaner output
suppressMessages({
  suppressWarnings({
    # Core application packages
    library(shiny)
    library(bslib) 
    library(DT)
    library(readxl)
    library(openxlsx)
    library(dplyr)
    library(ggplot2)
    library(plotly)
    library(visNetwork)
    library(shinycssloaders)
    library(colourpicker)
    library(htmlwidgets)
    library(shinyjs)
  })
})

cat("✅ Core packages loaded\n")

# Load Bayesian network packages with conflict management
suppressMessages({
  suppressWarnings({
    library(bnlearn)
    library(gRain)
    library(igraph)
    library(DiagrammeR)
    # Only load Rgraphviz if needed for advanced plotting
    if (requireNamespace("Rgraphviz", quietly = TRUE)) {
      library(Rgraphviz)
    }
  })
})

cat("✅ Bayesian network packages loaded\n")

# Source application files
source("utils.r")
source("vocabulary.r") 
source("bowtie_bayesian_network.r")

cat("✅ Application modules loaded\n")

# Load vocabulary data
vocabulary_data <- tryCatch({
  load_vocabulary()
}, error = function(e) {
  cat("⚠️ Using fallback data structure\n")
  list(
    activities = data.frame(hierarchy = character(), id = character(), name = character()),
    pressures = data.frame(hierarchy = character(), id = character(), name = character()),
    consequences = data.frame(hierarchy = character(), id = character(), name = character()),
    controls = data.frame(hierarchy = character(), id = character(), name = character())
  )
})

cat("✅ Data loaded successfully\n")
cat("🎯 Application ready to launch!\n")
cat("\n📋 To start the application, run: source('app.r')\n")
cat("🌐 Or launch directly with: shiny::runApp()\n\n")