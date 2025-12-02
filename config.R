# =============================================================================
# Environmental Bowtie Risk Analysis - Application Configuration
# Version: 5.3.6
# Last Updated: December 2025
# =============================================================================
# This file contains all centralized configuration settings for the application.
# It should be sourced by global.R and referenced by deployment scripts.
# =============================================================================

APP_CONFIG <- list(
  # Application Metadata
  APP_NAME = "bowtie_app",
  VERSION = "5.3.6",
  TITLE = "Environmental Bowtie Risk Analysis",
  SUBTITLE = "Marine Biodiversity and Ecosystem Services Assessment",
  AUTHOR = "Marbefes Team & AI Assistant",
  
  # Deployment Settings
  SHINY_SERVER_DIR = "/srv/shiny-server",
  DEFAULT_PORT = 3838,
  DEFAULT_HOST = "0.0.0.0",
  
  # Required Application Files (for deployment validation)
  REQUIRED_FILES = c(
    # Core application files
    "app.R",
    "global.R",
    "ui.R",
    "server.R",
    "start_app.R",
    "config.R",
    "requirements.R",

    # Module files
    "guided_workflow.R",
    "bowtie_bayesian_network.R",
    "utils.R",
    "vocabulary.R",
    "vocabulary_bowtie_generator.R",
    "translations_data.R",
    "environmental_scenarios.R",

    # Data files
    "CAUSES.xlsx",
    "CONSEQUENCES.xlsx",
    "CONTROLS.xlsx"
  ),

  # Required Directories (for deployment validation)
  REQUIRED_DIRS = c(
    "deployment",
    "tests",
    "docs",
    "data",
    "www"
  ),

  # Optional Directories (for full deployment)
  OPTIONAL_DIRS = c(
    "utils",
    "archive",
    "archivedocs",
    "archivelaunchers",
    "archivelogs",
    "archiveprogress",
    "Bow-tie guidance"
  ),
  
  # Data File Paths (relative to app root)
  DATA_FILES = list(
    CAUSES = "CAUSES.xlsx",
    CONSEQUENCES = "CONSEQUENCES.xlsx",
    CONTROLS = "CONTROLS.xlsx",
    SCENARIOS = "environmental_bowtie_data_2025-06-19.xlsx"
  ),

  # Documentation File Paths (relative to app root)
  DOCS = list(
    MANUAL_DIR = "docs",
    MANUAL_BASENAME = "Environmental_Bowtie_Risk_Analysis_Manual",
    README = "README.md"
  ),
  
  # UI Theme Configuration
  THEME = list(
    PRIMARY_COLOR = "#2C5F2D",
    SECONDARY_COLOR = "#97BC62",
    SUCCESS_COLOR = "#28a745",
    WARNING_COLOR = "#ffc107",
    DANGER_COLOR = "#dc3545",
    INFO_COLOR = "#17a2b8"
  ),
  
  # Risk Assessment Configuration
  RISK_LEVELS = list(
    HIGH = list(
      label = "High Risk",
      color = "#dc3545",
      threshold = 0.7
    ),
    MEDIUM = list(
      label = "Medium Risk",
      color = "#ffc107",
      threshold = 0.4
    ),
    LOW = list(
      label = "Low Risk",
      color = "#28a745",
      threshold = 0.0
    )
  ),
  
  # Bayesian Network Configuration
  BAYESIAN = list(
    DEFAULT_CPT_PROBABILITY = 0.5,
    MIN_NODES = 3,
    MAX_ITERATIONS = 1000,
    CONVERGENCE_THRESHOLD = 0.001
  ),
  
  # Report Generation Settings
  REPORT = list(
    FORMATS = c("HTML", "PDF", "DOCX"),
    TYPES = c("Summary", "Detailed", "Risk Matrix", "Bayesian", "Complete"),
    DEFAULT_FORMAT = "HTML",
    DEFAULT_TYPE = "Complete",
    MAX_SCENARIOS_TABLE = 50,
    TOP_PROBLEMS_COUNT = 10
  ),
  
  # File Upload Limits
  UPLOAD = list(
    MAX_FILE_SIZE_MB = 100,
    ALLOWED_EXTENSIONS = c("xlsx", "xls", "csv", "rds")
  ),
  
  # Session & Cache Settings
  SESSION = list(
    TIMEOUT_MINUTES = 60,
    MAX_CACHE_SIZE_MB = 500,
    ENABLE_BOOKMARKING = TRUE
  ),
  
  # Language Settings
  LANGUAGES = list(
    SUPPORTED = c("en", "fr"),
    DEFAULT = "en",
    LABELS = list(
      en = "English",
      fr = "Français"
    )
  ),
  
  # Logging Configuration
  LOGGING = list(
    ENABLED = TRUE,
    LEVEL = "INFO",  # DEBUG, INFO, WARNING, ERROR
    FILE = "app.log",
    MAX_SIZE_MB = 50
  ),
  
  # Performance Settings
  PERFORMANCE = list(
    ENABLE_CACHING = TRUE,
    CACHE_DIR = "app_cache",
    ENABLE_PROGRESS_BAR = TRUE,
    DEBOUNCE_MS = 500
  ),
  
  # Database Configuration (if needed in future)
  DATABASE = list(
    ENABLED = FALSE,
    TYPE = "sqlite",  # sqlite, postgres, mysql
    PATH = "data/bowtie_app.db"
  ),
  
  # External API Settings (if needed)
  API = list(
    ENABLED = FALSE,
    BASE_URL = NULL,
    TIMEOUT_SECONDS = 30
  ),
  
  # Development Mode Settings
  DEV = list(
    DEBUG_MODE = FALSE,
    ENABLE_PROFILING = FALSE,
    SHOW_ERRORS = TRUE,
    RELOAD_ON_SAVE = TRUE
  )
)

# =============================================================================
# Helper Functions for Configuration Access
# =============================================================================

#' Get configuration value by path
#' @param path Character vector of nested list keys (e.g., c("THEME", "PRIMARY_COLOR"))
#' @param default Default value if path not found
#' @return Configuration value or default
get_config <- function(path, default = NULL) {
  value <- APP_CONFIG
  for (key in path) {
    if (is.list(value) && key %in% names(value)) {
      value <- value[[key]]
    } else {
      return(default)
    }
  }
  return(value)
}

#' Get risk level configuration by probability
#' @param probability Numeric probability value (0-1)
#' @return List with risk level details (label, color, threshold)
get_risk_level <- function(probability) {
  if (probability >= APP_CONFIG$RISK_LEVELS$HIGH$threshold) {
    return(APP_CONFIG$RISK_LEVELS$HIGH)
  } else if (probability >= APP_CONFIG$RISK_LEVELS$MEDIUM$threshold) {
    return(APP_CONFIG$RISK_LEVELS$MEDIUM)
  } else {
    return(APP_CONFIG$RISK_LEVELS$LOW)
  }
}

#' Check if a file is required by the application
#' @param filename Character string of filename to check
#' @return Logical TRUE if file is required
is_required_file <- function(filename) {
  filename %in% APP_CONFIG$REQUIRED_FILES
}

#' Get application version string
#' @return Character string with app name and version
get_app_version <- function() {
  paste0(APP_CONFIG$APP_NAME, " v", APP_CONFIG$VERSION)
}

#' Get full path to data file
#' @param file_key Key from APP_CONFIG$DATA_FILES
#' @return Character string with full file path
get_data_file_path <- function(file_key) {
  if (file_key %in% names(APP_CONFIG$DATA_FILES)) {
    return(APP_CONFIG$DATA_FILES[[file_key]])
  }
  return(NULL)
}

#' Get manual file path with version
#' @param version Optional version string (defaults to current version)
#' @return Character string with full manual path
get_manual_path <- function(version = NULL) {
  if (is.null(version)) {
    version <- APP_CONFIG$VERSION
  }
  file.path(
    APP_CONFIG$DOCS$MANUAL_DIR,
    paste0(APP_CONFIG$DOCS$MANUAL_BASENAME, "_v", version, ".pdf")
  )
}

#' Get manual filename for download
#' @param version Optional version string (defaults to current version)
#' @return Character string with manual filename
get_manual_filename <- function(version = NULL) {
  if (is.null(version)) {
    version <- APP_CONFIG$VERSION
  }
  paste0(APP_CONFIG$DOCS$MANUAL_BASENAME, "_v", version, ".pdf")
}

# =============================================================================
# Environment-Specific Configuration Override
# =============================================================================

# Load environment-specific overrides if they exist
if (file.exists(".env.R")) {
  source(".env.R")
  if (exists("ENV_CONFIG")) {
    APP_CONFIG <- modifyList(APP_CONFIG, ENV_CONFIG)
    if (interactive()) {
      cat("✅ Environment-specific configuration loaded from .env.R\n")
    }
  }
}

# Print configuration summary (only in interactive mode)
if (interactive()) {
  cat("⚙️ Configuration loaded:", get_app_version(), "\n")
  cat("   • Required files:", length(APP_CONFIG$REQUIRED_FILES), "\n")
  cat("   • Supported languages:", paste(APP_CONFIG$LANGUAGES$SUPPORTED, collapse = ", "), "\n")
  cat("   • Debug mode:", APP_CONFIG$DEV$DEBUG_MODE, "\n")
}
