# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application with Bayesian Networks
# Version: 5.4.0 (Stability & Infrastructure Edition)
# Date: January 2026
# Author: Marbefes Team & AI Assistant
# Description: Production-ready with comprehensive deployment framework, UI improvements, and bug fixes
# =============================================================================

# =============================================================================
# EARLY LOADING PHASE (before logging.R - cat() is intentional here)
# The logging system loads at line 65, so we use cat() for early startup messages
# =============================================================================

# Ensure user library is on the library path (needed when system lib is not writable)
user_lib <- Sys.getenv("R_LIBS_USER")
if (nzchar(user_lib)) {
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(user_lib, .libPaths()))
}

# Load centralized configuration first
cat("[STARTUP] Loading centralized configuration...\n")
source("config.R")

# Load application constants
cat("[STARTUP] Loading application constants...\n")
source("constants.R")

# Enhanced package loading with better error handling
load_packages <- function() {
  cat("🚀 Starting", APP_CONFIG$TITLE, "...\n")
  cat("📦 Loading required packages...\n")

  required_packages <- c(
    "shiny", "bslib", "DT", "readxl", "openxlsx",
    "ggplot2", "plotly", "dplyr", "tidyr", "visNetwork",
    "shinycssloaders", "colourpicker", "htmlwidgets", "shinyjs",
    "bs4Dash", "shinyWidgets", "fresh", "shinyFiles"
  )

  bayesian_packages <- c("bnlearn", "gRain", "gRbase", "igraph", "DiagrammeR")

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
      if (pkg %in% c("gRain", "gRbase") && !requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
      }
      if (pkg %in% c("gRain", "gRbase")) {
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

# Load logging configuration and helpers
cat("[STARTUP] Loading logging and error handling systems...\n")
source("config/logging.R")
source("helpers/error_handling.R")
source("helpers/notifications.R")

# =============================================================================
# POST-LOGGING PHASE (logging.R is now loaded - use log_*() functions)
# =============================================================================

# Source utility functions and vocabulary management
log_info("Loading application modules...")
log_debug("   Loading utility functions and data management...")
source("utils.R")
source("ui_components.R")  # UI component library for enhanced UX
source("vocabulary.R")

# Load AI-powered vocabulary linker
log_debug("   Loading AI-powered vocabulary linker...")
tryCatch({
  source("vocabulary_ai_linker.R")
  log_success("   AI vocabulary linker loaded successfully")
  if (exists("AI_LINKER_CAPABILITIES")) {
    if (AI_LINKER_CAPABILITIES$basic_only) {
      log_info("   Running in basic mode (some optional packages unavailable)")
    } else {
      log_success("   All advanced AI features available")
    }
  }
}, error = function(e) {
  log_warning(paste("AI linker not available:", e$message))
  log_info("   Application will use basic linking fallback")
})

# =============================================================================
# EXPERIMENTAL AI/ML MODULES (Optional - app works without these)
# These modules enhance AI linking with ML capabilities but are not required.
# They fail gracefully if dependencies (randomForest, word2vec, etc.) are missing.
# =============================================================================

# Load suggestion feedback tracker
tryCatch({
  source("suggestion_feedback_tracker.R")
  log_debug("   Feedback tracking loaded")
}, error = function(e) {
  log_debug("   Feedback tracker unavailable (optional)")
})

# Load word embeddings for semantic similarity
tryCatch({
  source("word_embeddings.R")
  log_debug("   Word embeddings loaded")
}, error = function(e) {
  log_debug("   Word embeddings unavailable (optional)")
})

# Load ML link quality classifier
tryCatch({
  source("ml_link_classifier.R")
  log_debug("   ML classifier loaded")
}, error = function(e) {
  log_debug("   ML classifier unavailable (optional)")
})

# Load ensemble predictor
tryCatch({
  source("ml_ensemble_predictor.R")
  log_debug("   Ensemble predictor loaded")
}, error = function(e) {
  log_debug("   Ensemble predictor unavailable (optional)")
})

# Load explainable AI
tryCatch({
  source("explainable_ai.R")
  log_debug("   Explainable AI loaded")
}, error = function(e) {
  log_debug("   Explainable AI unavailable (optional)")
})

# =============================================================================
# END EXPERIMENTAL MODULES
# =============================================================================

source("environmental_scenarios.R")

# Load translation system from separate file
log_debug("   Loading translation system...")
source("translations_data.R")

log_debug("   Loading Bayesian network analysis...")
source("bowtie_bayesian_network.R")

log_debug("   Loading vocabulary bowtie generator...")
source("vocabulary_bowtie_generator.R")

# Source guided workflow system with dependency management
log_debug("   Loading guided workflow system...")
tryCatch({
  # Load workflow configuration (includes all step definitions)
  source("guided_workflow.R")
  log_success("   Guided workflow system loaded")
}, error = function(e) {
  log_warning(paste("Failed to load guided workflow system:", e$message))
})

# Load server modules (Phase 3 & 4: Server Modularization)
log_debug("   Loading server modules...")
tryCatch({
  # Phase 3 modules
  source("server_modules/language_module.R")
  source("server_modules/theme_module.R")
  source("server_modules/data_management_module.R")
  source("server_modules/export_module.R")
  source("server_modules/autosave_module.R")
  source("server_modules/local_storage_module.R")  # Local folder storage support
  # Phase 4 modules (server.R modularization)
  source("server_modules/bayesian_module.R")
  source("server_modules/bowtie_visualization_module.R")
  source("server_modules/report_generation_module.R")
  source("server_modules/ai_analysis_module.R")
  log_success("   Server modules loaded successfully (10 modules)")
}, error = function(e) {
  log_warning(paste("Failed to load server modules:", e$message))
  log_info("   Application will use legacy inline server code")
})

# Load login module
log_debug("   Loading login module...")
tryCatch({
  source("login_module.R")
  log_success("   Login module loaded successfully")
}, error = function(e) {
  log_warning(paste("Failed to load login module:", e$message))
})

# Load custom terms storage module
log_debug("   Loading custom terms module...")
tryCatch({
  source("custom_terms_module.R")
  log_success("   Custom terms module loaded successfully")
}, error = function(e) {
  log_warning(paste("Failed to load custom terms module:", e$message))
})

# Enhanced vocabulary data loading with graceful fallback
load_app_data <- function() {
  tryCatch({
    vocabulary_data <- load_vocabulary()
    log_success("Vocabulary data loaded successfully")
    return(vocabulary_data)
  }, error = function(e) {
    log_warning(paste("Could not load vocabulary data:", e$message))
    log_info("Using fallback empty data structure")
    return(list(
      activities = data.frame(hierarchy = character(), id = character(), name = character()),
      pressures = data.frame(hierarchy = character(), id = character(), name = character()),
      consequences = data.frame(hierarchy = character(), id = character(), name = character()),
      controls = data.frame(hierarchy = character(), id = character(), name = character())
    ))
  })
}

# Load vocabulary data with enhanced error handling
log_info("Loading environmental vocabulary data from Excel files...")
vocabulary_data <- load_app_data()

# =============================================================================
# DEVELOPMENT TOOLS (Optional - only in development mode)
# =============================================================================
# Load development configuration if in development mode or interactive session
if (Sys.getenv("SHINY_ENV") == "development" ||
    (interactive() && Sys.getenv("SHINY_ENV") != "production")) {
  if (file.exists("dev_config.R")) {
    tryCatch({
      source("dev_config.R")
      log_debug("Development tools loaded")
    }, error = function(e) {
      log_warning(paste("dev_config.R available but failed to load:", e$message))
    })
  }
}

log_success("Global environment initialized successfully")