# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application with Bayesian Networks
# Version: 5.3.0 (Production-Ready Edition)
# Date: November 2025
# Author: Marbefes Team & AI Assistant
# Description: Production-ready with comprehensive deployment framework, UI improvements, and bug fixes
# =============================================================================

# Load centralized configuration first
cat("⚙️ Loading centralized configuration...\n")
source("config.R")

# Enhanced package loading with better error handling
load_packages <- function() {
  cat("🚀 Starting", APP_CONFIG$TITLE, "...\n")
  cat("📦 Loading required packages...\n")

  required_packages <- c(
    "shiny", "bslib", "DT", "readxl", "openxlsx",
    "ggplot2", "plotly", "dplyr", "visNetwork",
    "shinycssloaders", "colourpicker", "htmlwidgets", "shinyjs"
  )

  bayesian_packages <- c("bnlearn", "gRain", "igraph", "DiagrammeR")

  # Load core packages
  cat("   • Loading core Shiny and visualization packages...\n")
  for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat("     Installing missing package:", pkg, "\n")
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }

  # Load Bayesian network packages with BiocManager support
  cat("   • Loading Bayesian network analysis packages...\n")
  for (pkg in bayesian_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat("     Installing Bayesian package:", pkg, "\n")
      if (pkg == "gRain" && !requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
      }
      if (pkg == "gRain") {
        BiocManager::install(pkg, dependencies = TRUE)
      } else {
        install.packages(pkg, dependencies = TRUE)
      }
      library(pkg, character.only = TRUE)
    }
  }
  cat("✅ All packages loaded successfully!\n")
}

# Load all packages
suppressMessages(load_packages())

# Source utility functions and vocabulary management
cat("🔧 Loading application modules...\n")
cat("   • Loading utility functions and data management...\n")
source("utils.R")
source("ui_components.R")  # UI component library for enhanced UX
source("vocabulary.R")
source("environmental_scenarios.R")

# Load translation system from separate file
cat("   • Loading translation system...\n")
source("translations_data.R")

cat("   • Loading Bayesian network analysis...\n")
source("bowtie_bayesian_network.R")

cat("   • Loading vocabulary bowtie generator...\n")
source("vocabulary_bowtie_generator.R")

# Source guided workflow system with dependency management
cat("   • Loading guided workflow system...\n")
tryCatch({
  # Load workflow configuration first
  source("guided_workflow.R")
  cat("     ✓ Guided workflow core loaded\n")

  # Load step definitions (depends on WORKFLOW_CONFIG from guided_workflow.R)
  # NOTE: guided_workflow_steps.r was removed - functionality merged into guided_workflow.R
  # source("guided_workflow_steps.r")
  # cat("     ✓ Workflow step definitions loaded\n")
}, error = function(e) {
  cat("     ⚠️ Warning: Failed to load guided workflow system:", e$message, "\n")
})

# Enhanced vocabulary data loading with graceful fallback
load_app_data <- function() {
  tryCatch({
    vocabulary_data <- load_vocabulary()
    cat("✅ Vocabulary data loaded successfully\n")
    return(vocabulary_data)
  }, error = function(e) {
    cat("⚠️ Warning: Could not load vocabulary data:", e$message, "\n")
    cat("📝 Using fallback empty data structure\n")
    return(list(
      activities = data.frame(hierarchy = character(), id = character(), name = character()),
      pressures = data.frame(hierarchy = character(), id = character(), name = character()),
      consequences = data.frame(hierarchy = character(), id = character(), name = character()),
      controls = data.frame(hierarchy = character(), id = character(), name = character())
    ))
  })
}

# Load vocabulary data with enhanced error handling
cat("📊 Loading environmental vocabulary data from Excel files...\n")
vocabulary_data <- load_app_data()