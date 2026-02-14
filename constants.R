# =============================================================================
# Environmental Bowtie Risk Analysis - Application Constants
# Version: 5.4.0+
# Date: January 2026
# Purpose: Centralized constants for maintainability and consistency
# =============================================================================

# =============================================================================
# NODE ID OFFSETS FOR BOWTIE DIAGRAMS
# =============================================================================
# These offsets ensure unique node IDs for different node types in visualizations

NODE_ID_OFFSET_ACTIVITY <- 50
NODE_ID_OFFSET_PRESSURE <- 100
NODE_ID_OFFSET_CONSEQUENCE <- 200
NODE_ID_OFFSET_PREVENTIVE_CONTROL <- 300
NODE_ID_OFFSET_ESCALATION_FACTOR <- 350
NODE_ID_OFFSET_PROTECTIVE_CONTROL <- 400
NODE_ID_OFFSET_PROBLEM <- 1  # Central problem starts at 1

# =============================================================================
# COLOR CONSTANTS
# =============================================================================
# Standard color palette for UI consistency
#
# NOTE: These are BOOTSTRAP STANDARD colors for framework defaults.
# For custom application branding (green theme), see APP_CONFIG$THEME in config.R
# Use COLOR_* for standard Bootstrap elements, APP_CONFIG$THEME for branding

## Primary Colors (Bootstrap standard - framework defaults)
COLOR_PRIMARY <- "#007bff"  # Bootstrap blue - use for standard UI components
COLOR_SUCCESS <- "#28a745"
COLOR_DANGER <- "#dc3545"
COLOR_WARNING <- "#ffc107"
COLOR_INFO <- "#17a2b8"
COLOR_LIGHT <- "#f8f9fa"
COLOR_DARK <- "#343a40"
COLOR_SECONDARY <- "#6c757d"

## Custom Application Colors
COLOR_PURPLE <- "#8E44AD"
COLOR_RED <- "#E74C3C"
COLOR_BLUE <- "#3498DB"
COLOR_GREEN <- "#2ECC71"
COLOR_ORANGE <- "#E67E22"
COLOR_TEAL <- "#1ABC9C"
COLOR_NAVY <- "#34495E"

## Node Colors (Bowtie Diagram)
NODE_COLOR_ACTIVITY <- "#3498DB"      # Blue
NODE_COLOR_PRESSURE <- "#E67E22"      # Orange
NODE_COLOR_PREVENTIVE_CONTROL <- "#2ECC71"  # Green
NODE_COLOR_PROBLEM <- "#E74C3C"       # Red (central)
NODE_COLOR_ESCALATION_FACTOR <- "#F39C12"  # Dark Orange
NODE_COLOR_PROTECTIVE_CONTROL <- "#1ABC9C"  # Teal
NODE_COLOR_CONSEQUENCE <- "#8E44AD"   # Purple

## Risk Level Colors
COLOR_RISK_CRITICAL <- "#E74C3C"      # Red
COLOR_RISK_HIGH <- "#E67E22"          # Orange
COLOR_RISK_MEDIUM <- "#F39C12"        # Yellow-Orange
COLOR_RISK_LOW <- "#2ECC71"           # Green
COLOR_RISK_NEGLIGIBLE <- "#3498DB"    # Blue

# =============================================================================
# UI CONSTANTS
# =============================================================================

## Visualization Settings
DEFAULT_NODE_SIZE <- 20
DEFAULT_EDGE_WIDTH <- 2
DEFAULT_ARROW_SIZE <- 10
DEFAULT_FONT_SIZE <- 14
DEFAULT_LABEL_SIZE <- 12

## Layout Constants
LAYOUT_HIERARCHICAL_LEVEL_SEPARATION <- 150
LAYOUT_NODE_SPACING <- 100
LAYOUT_TREE_SPACING <- 200

## Animation Settings
ANIMATION_DURATION_MS <- 300
ANIMATION_EASING <- "easeInOutQuad"

## Notification Durations (seconds)
NOTIFICATION_DURATION_DEFAULT <- 3
NOTIFICATION_DURATION_SUCCESS <- 3
NOTIFICATION_DURATION_ERROR <- 5
NOTIFICATION_DURATION_WARNING <- 4
NOTIFICATION_DURATION_INFO <- 2
NOTIFICATION_DURATION_PROGRESS <- 2

## Modal Settings
MODAL_WIDTH_SMALL <- "400px"
MODAL_WIDTH_MEDIUM <- "600px"
MODAL_WIDTH_LARGE <- "800px"
MODAL_WIDTH_XLARGE <- "1000px"

## Responsive Breakpoints (pixels)
BREAKPOINT_XS <- 576
BREAKPOINT_SM <- 768
BREAKPOINT_MD <- 992
BREAKPOINT_LG <- 1200
BREAKPOINT_XL <- 1400

# =============================================================================
# CACHE CONSTANTS
# =============================================================================

CACHE_MAX_SIZE <- 100
CACHE_MAX_AGE_SECONDS <- 3600  # 1 hour
CACHE_CLEANUP_INTERVAL_SECONDS <- 600  # 10 minutes

# =============================================================================
# WORKFLOW CONSTANTS
# =============================================================================

WORKFLOW_TOTAL_STEPS <- 8
WORKFLOW_MIN_STEP <- 1
WORKFLOW_MAX_STEP <- 8

## Workflow Step Names
WORKFLOW_STEP_NAMES <- c(
  "Project Setup",
  "Central Problem Definition",
  "Threats & Causes",
  "Preventive Controls",
  "Consequences",
  "Protective Controls",
  "Review & Validate",
  "Finalize & Export"
)

# =============================================================================
# DATA VALIDATION CONSTANTS
# =============================================================================

## Required Columns for Bowtie Data
REQUIRED_COLUMNS_BOWTIE <- c(
  "Activity",
  "Pressure",
  "Preventive_Control",
  "Central_Problem",
  "Escalation_Factor",
  "Protective_Mitigation",
  "Consequence"
)

## Optional Columns
OPTIONAL_COLUMNS_BOWTIE <- c(
  "Risk_Level",
  "Likelihood",
  "Impact",
  "Notes",
  "Date_Created",
  "Date_Modified"
)

## Data Limits
MAX_ACTIVITIES_PER_SCENARIO <- 100
MAX_PRESSURES_PER_SCENARIO <- 100
MAX_CONTROLS_PER_SCENARIO <- 200
MAX_CONSEQUENCES_PER_SCENARIO <- 50

## String Length Limits
MAX_TEXT_LENGTH <- 1000
MAX_NAME_LENGTH <- 200
MAX_DESCRIPTION_LENGTH <- 2000

# =============================================================================
# FILE CONSTANTS
# =============================================================================

## Supported File Extensions
SUPPORTED_EXCEL_EXTENSIONS <- c(".xlsx", ".xls")
SUPPORTED_CSV_EXTENSIONS <- c(".csv")
SUPPORTED_RDS_EXTENSIONS <- c(".rds", ".RDS")
SUPPORTED_EXPORT_FORMATS <- c("xlsx", "csv", "rds", "pdf")

## File Size Limits (bytes)
MAX_UPLOAD_FILE_SIZE <- 50 * 1024 * 1024  # 50 MB
MAX_EXPORT_FILE_SIZE <- 100 * 1024 * 1024  # 100 MB

## Default File Names
DEFAULT_EXPORT_FILENAME <- "bowtie_export"
DEFAULT_TEMPLATE_FILENAME <- "bowtie_template"
DEFAULT_WORKFLOW_FILENAME <- "workflow_progress"

# =============================================================================
# BAYESIAN NETWORK CONSTANTS
# =============================================================================

## CPT (Conditional Probability Table) Defaults
CPT_DEFAULT_TRUE <- 0.7
CPT_DEFAULT_FALSE <- 0.3
CPT_CONFIDENCE_THRESHOLD <- 0.6

## Network Structure
BAYESIAN_MAX_PARENTS <- 5
BAYESIAN_MAX_CHILDREN <- 10

# =============================================================================
# AI LINKING CONSTANTS
# =============================================================================

## Similarity Thresholds
AI_SIMILARITY_THRESHOLD_JACCARD <- 0.3
AI_SIMILARITY_THRESHOLD_KEYWORD <- 0.5
AI_SIMILARITY_THRESHOLD_CAUSAL <- 0.4
AI_SIMILARITY_THRESHOLD_SEMANTIC <- 0.6

## AI Processing Limits
AI_MAX_SUGGESTIONS <- 10
AI_MAX_PROCESSING_TIME_SECONDS <- 30

# =============================================================================
# TRANSLATION CONSTANTS
# =============================================================================

## Supported Languages
# NOTE: Must match APP_CONFIG$LANGUAGES$SUPPORTED in config.R
# Only add languages here if translations exist in translations_data.R
SUPPORTED_LANGUAGES <- c("en", "fr")
DEFAULT_LANGUAGE <- "en"

# =============================================================================
# PERFORMANCE CONSTANTS
# =============================================================================

## Timeouts (milliseconds)
TIMEOUT_DATABASE_QUERY <- 5000
TIMEOUT_FILE_OPERATION <- 10000
TIMEOUT_NETWORK_REQUEST <- 15000
TIMEOUT_EXPORT_OPERATION <- 30000

## Processing Limits
MAX_CONCURRENT_OPERATIONS <- 4
MAX_RETRY_ATTEMPTS <- 3
RETRY_DELAY_MS <- 1000

# =============================================================================
# LOGGING CONSTANTS
# =============================================================================

## Log Levels
LOG_LEVEL_DEBUG <- "DEBUG"
LOG_LEVEL_INFO <- "INFO"
LOG_LEVEL_WARNING <- "WARNING"
LOG_LEVEL_ERROR <- "ERROR"

## Log Emoji Icons
LOG_EMOJI_DEBUG <- "\U0001F50D"     # 🔍
LOG_EMOJI_INFO <- "\U00002139"      # ℹ️
LOG_EMOJI_SUCCESS <- "\U00002705"   # ✅
LOG_EMOJI_WARNING <- "\U000026A0"   # ⚠️
LOG_EMOJI_ERROR <- "\U0000274C"     # ❌
LOG_EMOJI_PROGRESS <- "\U0001F504"  # 🔄

# =============================================================================
# VERSION CONSTANTS (DEPRECATED - use APP_CONFIG$VERSION from config.R)
# =============================================================================
# These are kept for backward compatibility only.
# Prefer using APP_CONFIG$VERSION as the single source of truth.

APP_VERSION <- "5.4.0"
APP_BUILD_DATE <- "2026-01-01"
APP_CODENAME <- "Stability & Infrastructure Edition"

# =============================================================================
# HELPER FUNCTIONS FOR CONSTANTS
# =============================================================================

#' Get node color by type
#' @param node_type Type of node ("activity", "pressure", etc.)
#' @return Color hex code
get_node_color <- function(node_type) {
  node_type <- tolower(node_type)
  colors <- list(
    "activity" = NODE_COLOR_ACTIVITY,
    "pressure" = NODE_COLOR_PRESSURE,
    "preventive_control" = NODE_COLOR_PREVENTIVE_CONTROL,
    "preventive control" = NODE_COLOR_PREVENTIVE_CONTROL,
    "control" = NODE_COLOR_PREVENTIVE_CONTROL,
    "problem" = NODE_COLOR_PROBLEM,
    "central_problem" = NODE_COLOR_PROBLEM,
    "escalation_factor" = NODE_COLOR_ESCALATION_FACTOR,
    "escalation factor" = NODE_COLOR_ESCALATION_FACTOR,
    "protective_control" = NODE_COLOR_PROTECTIVE_CONTROL,
    "protective control" = NODE_COLOR_PROTECTIVE_CONTROL,
    "mitigation" = NODE_COLOR_PROTECTIVE_CONTROL,
    "consequence" = NODE_COLOR_CONSEQUENCE
  )

  color <- colors[[node_type]]
  if (is.null(color)) {
    warning("Unknown node type: ", node_type, ". Using default color.")
    return(COLOR_SECONDARY)
  }

  color
}

#' Get risk color by level
#' @param risk_level Risk level ("critical", "high", "medium", "low", "negligible")
#' @return Color hex code
get_risk_color <- function(risk_level) {
  risk_level <- tolower(risk_level)
  colors <- list(
    "critical" = COLOR_RISK_CRITICAL,
    "high" = COLOR_RISK_HIGH,
    "medium" = COLOR_RISK_MEDIUM,
    "moderate" = COLOR_RISK_MEDIUM,
    "low" = COLOR_RISK_LOW,
    "negligible" = COLOR_RISK_NEGLIGIBLE,
    "minimal" = COLOR_RISK_NEGLIGIBLE
  )

  color <- colors[[risk_level]]
  if (is.null(color)) {
    warning("Unknown risk level: ", risk_level, ". Using default color.")
    return(COLOR_WARNING)
  }

  color
}

#' Validate required columns in data
#' @param data Data frame to validate
#' @param required_cols Vector of required column names
#' @return TRUE if all columns present, error otherwise
validate_required_columns <- function(data, required_cols = REQUIRED_COLUMNS_BOWTIE) {
  missing_cols <- setdiff(required_cols, names(data))

  if (length(missing_cols) > 0) {
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }

  TRUE
}

#' Get notification duration by type
#' @param type Notification type ("success", "error", "warning", "info", "progress")
#' @return Duration in seconds
get_notification_duration <- function(type) {
  durations <- list(
    "success" = NOTIFICATION_DURATION_SUCCESS,
    "message" = NOTIFICATION_DURATION_SUCCESS,
    "error" = NOTIFICATION_DURATION_ERROR,
    "warning" = NOTIFICATION_DURATION_WARNING,
    "info" = NOTIFICATION_DURATION_INFO,
    "progress" = NOTIFICATION_DURATION_PROGRESS
  )

  duration <- durations[[tolower(type)]]
  if (is.null(duration)) {
    return(NOTIFICATION_DURATION_DEFAULT)
  }

  duration
}

# =============================================================================
# END OF CONSTANTS
# =============================================================================

# Note: Using cat() here because constants.R loads before logging.R
# Once bowtie_log() is available, prefer using it for consistency
if (interactive()) {
  cat("✅ Application constants loaded successfully\n")
}
