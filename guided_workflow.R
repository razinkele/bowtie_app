# =============================================================================
# Guided Workflow System - Step-by-Step Bowtie Creation
# Version: 5.4.0
# Date: January 2026
# Description: Comprehensive wizard-based system for guided bowtie diagram creation
#              with progress tracking, validation, and expert guidance
# =============================================================================

# =============================================================================
# DEPENDENCY VALIDATION AND LOADING
# =============================================================================

# Validate and load required dependencies
validate_guided_workflow_dependencies <- function() {
  log_debug("Validating guided workflow dependencies...")

  required_packages <- c("shiny", "bslib", "dplyr", "DT")
  optional_packages <- c("ggplot2", "plotly", "openxlsx", "jsonlite", "digest")
  missing_required <- c()
  missing_optional <- c()

  # Check required packages
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_required <- c(missing_required, pkg)
    } else {
      tryCatch({
        library(pkg, character.only = TRUE, quietly = TRUE)
      }, error = function(e) {
        missing_required <- c(missing_required, pkg)
      })
    }
  }

  # Check optional packages
  for (pkg in optional_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_optional <- c(missing_optional, pkg)
    }
  }

  # Report results
  if (length(missing_required) > 0) {
    log_error(paste("Missing required packages:", paste(missing_required, collapse = ", ")))
    log_info(paste("Install with: install.packages(c(", paste(paste0("'", missing_required, "'"), collapse = ", "), "))"))
    return(FALSE)
  }

  if (length(missing_optional) > 0) {
    log_warning(paste("Missing optional packages:", paste(missing_optional, collapse = ", ")))
    log_info(paste("Some features may be limited. Install with: install.packages(c(", paste(paste0("'", missing_optional, "'"), collapse = ", "), "))"))
  }

  # Validate function availability
  required_functions <- c(
    "fluidPage", "tabPanel", "actionButton", "selectizeInput", "DTOutput"
  )

  missing_functions <- c()
  for (func in required_functions) {
    if (!exists(func, mode = "function")) {
      missing_functions <- c(missing_functions, func)
    }
  }

  if (length(missing_functions) > 0) {
    log_error(paste("Missing required functions:", paste(missing_functions, collapse = ", ")))
    return(FALSE)
  }

  log_success("All dependencies validated successfully")
  return(TRUE)
}

# Load dependencies
if (!validate_guided_workflow_dependencies()) {
  stop("❌ Guided Workflow System: Dependency validation failed")
}

# =============================================================================
# LOAD MODULAR COMPONENTS
# =============================================================================
log_debug("Loading guided workflow modules...")

# Load configuration and state management
if (file.exists("guided_workflow_config.R")) {
  source("guided_workflow_config.R")
} else {
  stop("❌ Missing required module: guided_workflow_config.R")
}

# Load validation functions
if (file.exists("guided_workflow_validation.R")) {
  source("guided_workflow_validation.R")
} else {
  stop("❌ Missing required module: guided_workflow_validation.R")
}

# Load data conversion functions
if (file.exists("guided_workflow_conversion.R")) {
  source("guided_workflow_conversion.R")
} else {
  stop("❌ Missing required module: guided_workflow_conversion.R")
}

# =============================================================================
# UTILITY HELPER FUNCTIONS
# =============================================================================

#' Create a simple DataTable for displaying a list of items
#' Reduces code duplication across multiple renderDT calls
#' @param items Character vector of items to display
#' @param column_name Name of the column to display
#' @param page_length Number of rows per page (default 5)
#' @param show_search Whether to show search box (default FALSE)
#' @param selection Selection mode: 'none', 'single', 'multiple' (default 'none')
#' @return DT::datatable object
create_simple_datatable <- function(items, column_name, page_length = 5,
                                    show_search = FALSE, selection = "none") {
  # Handle empty or NULL items
  if (is.null(items) || length(items) == 0) {
    dt_data <- setNames(data.frame(character(0), stringsAsFactors = FALSE), column_name)
  } else {
    dt_data <- setNames(data.frame(as.character(items), stringsAsFactors = FALSE), column_name)
  }

  # Determine DOM string based on options
  dom_string <- if (show_search) "ftp" else "t"

  DT::datatable(
    dt_data,
    options = list(
      pageLength = page_length,
      searching = show_search,
      lengthChange = FALSE,
      info = show_search,
      dom = dom_string,
      language = list(emptyTable = "No items added yet")
    ),
    rownames = FALSE,
    selection = selection,
    class = "cell-border stripe compact"
  )
}

#' Create a DataTable for connections/links with multiple columns
#' @param data Data frame with connection data
#' @param page_length Number of rows per page (default 10)
#' @return DT::datatable object
create_connection_datatable <- function(data, page_length = 10) {
  if (is.null(data) || nrow(data) == 0) {
    data <- data.frame(matrix(ncol = 0, nrow = 0))
  }

  DT::datatable(
    data,
    options = list(
      pageLength = page_length,
      searching = TRUE,
      lengthChange = FALSE,
      info = TRUE,
      dom = "tp",
      language = list(emptyTable = "No connections defined")
    ),
    rownames = FALSE,
    selection = "none",
    class = "cell-border stripe compact"
  )
}

# =============================================================================
# SECURITY HELPER FUNCTIONS
# =============================================================================

#' Safely escape a string for use in regex patterns
#' Safe regex escape utility - Prevents ReDoS attacks
#'
#' NOTE: This is a security utility function available for use in regex operations.
#' Use this when building regex patterns from user input to prevent ReDoS attacks.
#' Example: grepl(safe_regex_escape(user_input), text)
#'
#' @param x String to escape
#' @param max_length Maximum allowed string length (default 100)
#' @return Safely escaped string for regex use
safe_regex_escape <- function(x, max_length = 100) {
  # Validate input

  if (is.null(x) || !is.character(x) || length(x) != 1) {
    return("")
  }

  # Truncate to max length to prevent resource exhaustion
  if (nchar(x) > max_length) {
    x <- substr(x, 1, max_length)
  }

  # Escape all regex special characters
  # This includes: . \ | ( ) [ ] { } ^ $ + * ?
  escaped <- gsub("([.|\\\\()\\[\\]{}^$+*?])", "\\\\\\1", x)

  return(escaped)
}

#' Get children of a vocabulary item by ID prefix matching
#' Uses fixed string matching instead of regex for security
#' @param data Data frame with 'id' and 'name' columns
#' @param parent_id Parent ID to match (e.g., "1.1")
#' @return Data frame of children items
get_vocabulary_children <- function(data, parent_id) {
  if (is.null(data) || nrow(data) == 0 || is.null(parent_id) || nchar(parent_id) == 0) {
    return(data.frame(id = character(0), name = character(0), stringsAsFactors = FALSE))
  }

  # Use fixed string matching (startsWith) instead of regex for security
  prefix <- paste0(parent_id, ".")
  children <- data[startsWith(data$id, prefix), ]

  return(children)
}

log_info("GUIDED WORKFLOW SYSTEM v1.1.0 - Step-by-step bowtie creation with expert guidance")

# Load AI suggestions module
log_debug("Loading AI-powered suggestions...")
# AI suggestions available but controlled by user settings (gear icon)
if (file.exists("guided_workflow_ai_suggestions.R")) {
  tryCatch({
    source("guided_workflow_ai_suggestions.R")
    WORKFLOW_AI_AVAILABLE <- TRUE
    log_success("AI suggestions module loaded (controlled by user settings)")
    log_debug("   Enable in Settings -> AI Suggestions Settings")
    log_debug("   Warning: May cause 2-3 second delays when enabled")
  }, error = function(e) {
    WORKFLOW_AI_AVAILABLE <- FALSE
    log_warning(paste("AI suggestions unavailable:", e$message))
  })
} else {
  WORKFLOW_AI_AVAILABLE <- FALSE
  log_info("AI suggestions module not found")
}

# =============================================================================
# WORKFLOW CONFIGURATION - MOVED TO MODULE
# =============================================================================
# NOTE: WORKFLOW_CONFIG, init_workflow_state(), and update_workflow_progress()
# have been moved to guided_workflow_config.R for better maintainability.
# These are loaded via source() at the top of this file.
# =============================================================================

# =============================================================================
# UI COMPONENTS
# =============================================================================

# Main guided workflow UI
guided_workflow_ui <- function(id, current_lang = "en") {
  ns <- NS(id)
  fluidPage(
    # Custom CSS for workflow
    tags$head(
      tags$style(HTML("
        .workflow-header {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 20px;
          border-radius: 10px;
          margin-bottom: 20px;
        }
        /* Hide any text that looks like raw HTML in workflow steps */
        .list-group-item {
          overflow: hidden;
        }
        .list-group-item > div::before {
          content: '';
          display: block;
          height: 0;
          overflow: hidden;
        }
        .workflow-step {
          border: 2px solid #e9ecef;
          border-radius: 10px;
          padding: 20px;
          margin: 10px 0;
          transition: all 0.3s ease;
        }
        .workflow-step.active {
          border-color: #007bff;
          background: #f8f9ff;
        }
        .workflow-step.completed {
          border-color: #28a745;
          background: #f8fff8;
        }
        .step-icon {
          font-size: 2em;
          margin-bottom: 10px;
        }
        .progress-tracker {
          background: white;
          border-radius: 10px;
          padding: 15px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .template-card {
          border: 1px solid #dee2e6;
          border-radius: 8px;
          padding: 15px;
          margin: 10px 0;
          cursor: pointer;
          transition: all 0.2s ease;
        }
        .template-card:hover {
          border-color: #007bff;
          background: #f8f9ff;
        }
        .template-card.selected {
          border-color: #28a745;
          background: #f8fff8;
        }
        /* Autosave status indicator */
        .autosave-status {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          padding: 4px 12px;
          border-radius: 20px;
          font-size: 0.85rem;
          font-weight: 500;
          transition: all 0.3s ease;
          opacity: 0;
          background: rgba(255, 255, 255, 0.95);
          color: #6c757d;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        .autosave-status.saving {
          opacity: 1;
          color: #0d6efd;
          background: #e7f1ff;
        }
        .autosave-status.saved {
          opacity: 1;
          color: #198754;
          background: #d1f4e0;
        }
        .autosave-status.error {
          opacity: 1;
          color: #dc3545;
          background: #ffe5e5;
        }
        .autosave-status i {
          font-size: 1rem;
        }
        .autosave-status.saving i {
          animation: spin 1s linear infinite;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      ")),
      # JavaScript for autosave functionality
      tags$script(HTML("
        // Autosave localStorage handlers
        Shiny.addCustomMessageHandler('smartAutosave', function(data) {
          try {
            localStorage.setItem('bowtie_workflow_autosave', data.state);
            localStorage.setItem('bowtie_workflow_autosave_timestamp', data.timestamp);
            localStorage.setItem('bowtie_workflow_autosave_hash', data.hash);

            updateAutosaveStatus('saved', 'Saved ' + data.timestamp);
          } catch (e) {
            console.error('Autosave failed:', e);
            updateAutosaveStatus('error', 'Save failed');
          }
        });

        Shiny.addCustomMessageHandler('loadFromLocalStorage', function(data) {
          try {
            var value = localStorage.getItem(data.key);
            if (value) {
              Shiny.setInputValue(data.inputId, value);
            }
          } catch (e) {
            console.error('Failed to load from localStorage:', e);
          }
        });

        Shiny.addCustomMessageHandler('clearAutosave', function(data) {
          try {
            localStorage.removeItem('bowtie_workflow_autosave');
            localStorage.removeItem('bowtie_workflow_autosave_timestamp');
            localStorage.removeItem('bowtie_workflow_autosave_hash');
          } catch (e) {
            console.error('Failed to clear autosave:', e);
          }
        });

        function updateAutosaveStatus(status, text) {
          var statusDiv = $('#guided_workflow-autosave_status');
          if (statusDiv.length === 0) return;

          var iconSpan = statusDiv.find('.autosave-icon');
          var textSpan = statusDiv.find('.autosave-text');

          statusDiv.removeClass('saving saved error');

          if (status === 'saving') {
            statusDiv.addClass('saving');
            iconSpan.html('<i class=\"fas fa-spinner\"></i>');
            textSpan.text(text || 'Saving...');
            statusDiv.css('opacity', '1');
          } else if (status === 'saved') {
            statusDiv.addClass('saved');
            iconSpan.html('<i class=\"fas fa-check-circle\"></i>');
            textSpan.text(text || 'Saved');
            statusDiv.css('opacity', '1');

            // Fade out after 3 seconds
            setTimeout(function() {
              statusDiv.css('opacity', '0');
            }, 3000);
          } else if (status === 'error') {
            statusDiv.addClass('error');
            iconSpan.html('<i class=\"fas fa-exclamation-circle\"></i>');
            textSpan.text(text || 'Error');
            statusDiv.css('opacity', '1');

            // Fade out after 5 seconds
            setTimeout(function() {
              statusDiv.css('opacity', '0');
            }, 5000);
          }
        }
      "))
    ),
    
    # Workflow header
    div(class = "workflow-header",
        fluidRow(
          column(8,
                 h2(tagList(icon("magic"), t("gw_title", current_lang)), style = "margin: 0;"),
                 p(t("gw_subtitle", current_lang), style = "margin: 5px 0 0 0;")
          ),
          column(4,
                 div(class = "text-end d-flex align-items-center justify-content-end gap-2",
                     # Autosave status indicator
                     tags$div(id = ns("autosave_status"), class = "autosave-status",
                              tags$span(class = "autosave-icon"),
                              tags$span(class = "autosave-text")
                     ),
                     actionButton(ns("workflow_help"), tagList(icon("question-circle"), t("gw_help", current_lang)), class = "btn-light btn-sm"),
                    actionButton(ns("workflow_load_btn"), tagList(icon("folder-open"), t("gw_load_progress", current_lang)), class = "btn-light btn-sm"),
                    # Hidden file input for load functionality (accepts JSON and legacy RDS)
                    tags$div(style = "display: none;",
                        fileInput(ns("workflow_load_file_hidden"), NULL, accept = c(".json", ".rds"))
                    ),
                     downloadButton(ns("workflow_download"), tagList(icon("save"), t("gw_save_progress", current_lang)), class = "btn-light btn-sm")
                 )
          )
        )
    ),
    
    # Progress tracker
    fluidRow(
      column(12,
             div(class = "progress-tracker",
                 uiOutput(ns("workflow_progress_ui"))
             )
      )
    ),
    
    # Main workflow content
    fluidRow(
      column(3,
             # Step navigation sidebar
             div(class = "card",
                 div(class = "card-header", h5(tagList(icon("list-check"), t("gw_workflow_steps", current_lang)))),
                 div(class = "card-body",
                     uiOutput(ns("workflow_steps_sidebar"))
                 )
             )
      ),
      column(9,
             # Current step content
             div(class = "card",
                 div(class = "card-header",
                     uiOutput(ns("current_step_header"))
                 ),
                 div(class = "card-body",
                     uiOutput(ns("current_step_content"))
                 ),
                 div(class = "card-footer",
                     uiOutput(ns("workflow_navigation"))
                 )
             )
      )
    )
  )
}

# Progress tracker UI
workflow_progress_ui <- function(state, current_lang = "en") {
  progress_percentage <- state$progress_percentage
  current_step <- state$current_step
  total_steps <- state$total_steps
  
  tagList(
    fluidRow(
      column(8,
             div(
               h5(paste(t("gw_step", current_lang), current_step, "of", total_steps, "•", 
                       t(WORKFLOW_CONFIG$steps[[current_step]]$title, current_lang))),
               div(class = "progress", style = "height: 20px;",
                   div(class = "progress-bar bg-success", 
                       role = "progressbar",
                       style = paste0("width: ", progress_percentage, "%"),
                       paste0(round(progress_percentage), "% Complete")
                   )
               )
             )
      ),
      column(4,
             div(class = "text-end",
                 h6(paste(t("gw_completed", current_lang), length(state$completed_steps), "/", total_steps)),
                 if (length(state$completed_steps) > 0) {
                   tags$small(paste(t("gw_estimated_time_remaining", current_lang), 
                              estimate_remaining_time(state), t("gw_minutes", current_lang)))
                 } else {
                   tags$small(t("gw_estimated_total", current_lang))
                 }
             )
      )
    )
  )
}

# Steps sidebar UI
workflow_steps_sidebar_ui <- function(state, current_lang = "en") {
  steps <- WORKFLOW_CONFIG$steps
  current_step <- state$current_step
  completed_steps <- state$completed_steps
  
  step_items <- lapply(1:length(steps), function(i) {
    step <- steps[[i]]
    status_class <- if (i %in% completed_steps) {
      "list-group-item-success"
    } else if (i == current_step) {
      "list-group-item-primary" 
    } else {
      ""
    }
    
    step_icon <- if (i %in% completed_steps) {
      icon("check-circle", class = "text-success", style = "margin-right: 8px;")
    } else if (i == current_step) {
      icon("play", class = "text-primary", style = "margin-right: 8px;")
    } else {
      icon("clock", class = "text-muted", style = "margin-right: 8px;")
    }

    div(class = paste("list-group-item", status_class),
        onclick = paste0("Shiny.setInputValue('guided_workflow-goto_step', ", i, ")"),
        style = "cursor: pointer;",
        div(
          step_icon,
          strong(t(step$title, current_lang)),
          br(),
          tags$small(t(step$description, current_lang))
        )
    )
  })
  
  div(class = "list-group", step_items)
}

# =============================================================================
# STEP CONTENT GENERATORS
# =============================================================================

# Step 1: Project Setup
generate_step1_ui <- function(session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    fluidRow(
      column(6,
             h4(t("gw_project_info", current_lang)),
             validated_text_input(
               id = ns("project_name"),
               label = t("gw_project_name", current_lang),
               placeholder = t("gw_project_name_placeholder", current_lang),
               required = TRUE,
               min_length = 3,
               max_length = 100,
               help_text = "Enter a descriptive name for your environmental risk analysis project (3-100 characters)"
             ),
             validated_text_input(
               id = ns("project_location"),
               label = t("gw_location", current_lang),
               placeholder = t("gw_location_placeholder", current_lang),
               required = TRUE,
               min_length = 2,
               max_length = 100,
               help_text = "Specify the geographic location or region for this assessment"
             ),
             validated_select_input(
               id = ns("project_type"),
               label = t("gw_assessment_type", current_lang),
               choices = if (current_lang == "fr") {
                 c("Marin" = "marine",
                   "Terrestre" = "terrestrial",
                   "Eau douce" = "freshwater",
                   "Urbain" = "urban",
                   "Climat" = "climate",
                   "Personnalisé" = "custom")
               } else {
                 c("Marine" = "marine",
                   "Terrestrial" = "terrestrial",
                   "Freshwater" = "freshwater",
                   "Urban" = "urban",
                   "Climate" = "climate",
                   "Custom" = "custom")
               },
               required = TRUE,
               help_text = "Select the primary environmental domain for this assessment"
             ),
             textAreaInput(ns("project_description"), t("gw_project_description", current_lang),
                          placeholder = t("gw_project_desc_placeholder", current_lang),
                          rows = 3)
      ),
      column(6,
             h4(t("gw_template_selection", current_lang)),
             p(t("gw_template_desc", current_lang)),

             # Listbox with environmental scenarios (using centralized configuration)
             div(class = "mb-3",
                 h6(t("gw_select_template", current_lang)),
                 selectInput(ns("problem_template"), t("gw_quick_start", current_lang),
                           choices = get_environmental_scenario_choices(include_blank = TRUE),
                           selected = ""
                 )
             ),
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_expert_tip", current_lang)),
                 p(t("gw_template_tip", current_lang))
             )
      )
    )
  )
}

# Step 2: Central Problem Definition  
generate_step2_ui <- function(session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-primary",
        h5(t("gw_step2_define_problem_title", current_lang)),
        p(t("gw_step2_define_problem_desc", current_lang))
    ),
    
    fluidRow(
      column(8,
             h4(t("gw_central_problem", current_lang)),
             validated_text_input(
               id = ns("problem_statement"),
               label = t("gw_problem_statement", current_lang),
               placeholder = t("gw_problem_statement_placeholder", current_lang),
               required = TRUE,
               min_length = 5,
               max_length = 200,
               help_text = "Clearly define the central environmental problem or hazard (5-200 characters)"
             ),

             validated_select_input(
               id = ns("problem_category"),
               label = t("gw_problem_category", current_lang),
               choices = setNames(
                 c("pollution", "habitat_loss", "climate_impacts", "resource_depletion", "ecosystem_services", "other"),
                 c(t("gw_problem_category_pollution", current_lang), t("gw_problem_category_habitat", current_lang), t("gw_problem_category_climate", current_lang), t("gw_problem_category_resource", current_lang), t("gw_problem_category_ecosystem", current_lang), t("gw_problem_category_other", current_lang))
               ),
               required = TRUE,
               help_text = "Select the primary category that best describes this environmental problem"
             ),

             textAreaInput(ns("problem_details"), t("gw_detailed_description", current_lang),
                          placeholder = t("gw_detailed_description_placeholder", current_lang),
                          rows = 4),

             validated_select_input(
               id = ns("problem_scale"),
               label = t("gw_spatial_scale", current_lang),
               choices = setNames(
                 c("local", "regional", "national", "international", "global"),
                 c(t("gw_scale_local", current_lang), t("gw_scale_regional", current_lang), t("gw_scale_national", current_lang), t("gw_scale_international", current_lang), t("gw_scale_global", current_lang))
               ),
               required = TRUE,
               help_text = "Specify the geographic scale or extent of the environmental problem"
             ),

             validated_select_input(
               id = ns("problem_urgency"),
               label = t("gw_urgency_level", current_lang),
               choices = setNames(
                 c("critical", "high", "medium", "low"),
                 c(t("gw_urgency_critical", current_lang), t("gw_urgency_high", current_lang), t("gw_urgency_medium", current_lang), t("gw_urgency_low", current_lang))
               ),
               required = TRUE,
               help_text = "Indicate the urgency level for addressing this environmental issue"
             )
      ),
      column(4,
             h4(t("gw_problem_examples_title", current_lang)),

             div(class = "card",
                 div(class = "card-body",
                     h6(t("gw_additional_examples", current_lang)),
                     tags$ul(
                       tags$li(t("gw_example_acidification", current_lang)),
                       tags$li(t("gw_example_bleaching", current_lang)),
                       tags$li(t("gw_example_deforestation", current_lang)),
                       tags$li(t("gw_example_biodiversity", current_lang))
                     )
                 )
             ),
             br(),
             div(class = "alert alert-warning",
                 h6(t("gw_important_title", current_lang)),
                 p(t("gw_problem_tip", current_lang))
             )
      )
    )
  )
}

# Step 3: Threats & Causes
generate_step3_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-danger",
        h5(t("gw_step3_map_threats_title", current_lang)),
        p(t("gw_step3_map_threats_desc", current_lang))
    ),
    
    fluidRow(
      column(6,
             h4(t("gw_human_activities_title", current_lang)),
             p(t("gw_human_activities_desc", current_lang)),

             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 activity_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities) && nrow(vocabulary_data$activities) > 0) {
                   level1_activities <- vocabulary_data$activities[vocabulary_data$activities$level == 1 & !is.na(vocabulary_data$activities$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_activities) > 0) {
                     level1_activities <- level1_activities[!is.na(level1_activities$name) & !is.na(level1_activities$id), ]
                     if (nrow(level1_activities) > 0) {
                       activity_groups <- setNames(level1_activities$id, level1_activities$name)
                     }
                   }
                 }

                 selectizeInput(ns("activity_group"), "Step 1: Select Activity Group",
                              choices = c("Choose a group..." = "", activity_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select an activity category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("activity_item"), "Step 2: Select Specific Activity",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select an activity from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("activity_custom_toggle"), "Or enter a custom activity not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.activity_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("activity_custom_text"),
                     label = "Custom Activity Name:",
                     placeholder = "Enter new activity name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom human activity not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_activity"), tagList(icon("plus"), t("gw_add_activity", current_lang)),
                            class = "btn-success btn-block")
               )
             ),
             
             h5(t("gw_selected_activities", current_lang)),
             DTOutput(ns("selected_activities_table")),

             br(),
             div(class = "alert alert-info",
                 h6(t("gw_examples_title", current_lang)),
                 p(t("gw_activities_examples_text", current_lang))
             ),

             # AI-powered suggestions for activities (always render, controlled by availability)
             {
               if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
                 create_ai_suggestions_ui(
                   ns,
                   "activity",
                   "🤖 AI-Powered Activity Suggestions",
                   current_lang
                 )
               }
             }
      ),
      
      column(6,
             h4(t("gw_env_pressures_title", current_lang)),
             p(t("gw_env_pressures_desc", current_lang)),

             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 pressure_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures) && nrow(vocabulary_data$pressures) > 0) {
                   level1_pressures <- vocabulary_data$pressures[vocabulary_data$pressures$level == 1 & !is.na(vocabulary_data$pressures$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_pressures) > 0) {
                     level1_pressures <- level1_pressures[!is.na(level1_pressures$name) & !is.na(level1_pressures$id), ]
                     if (nrow(level1_pressures) > 0) {
                       pressure_groups <- setNames(level1_pressures$id, level1_pressures$name)
                     }
                   }
                 }

                 selectizeInput(ns("pressure_group"), "Step 1: Select Pressure Group",
                              choices = c("Choose a group..." = "", pressure_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a pressure category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("pressure_item"), "Step 2: Select Specific Pressure",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a pressure from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("pressure_custom_toggle"), "Or enter a custom pressure not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.pressure_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("pressure_custom_text"),
                     label = "Custom Pressure Name:",
                     placeholder = "Enter new pressure name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom environmental pressure not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_pressure"), tagList(icon("plus"), t("gw_add_pressure", current_lang)),
                            class = "btn-warning btn-block")
               )
             ),
             
             h5(t("gw_selected_pressures", current_lang)),
             DTOutput(ns("selected_pressures_table")),

             br(),
             div(class = "alert alert-info",
                 h6(t("gw_examples_title", current_lang)),
                 p(t("gw_pressures_examples_text", current_lang))
             ),

             # AI-powered suggestions for pressures (if available)
             if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
               create_ai_suggestions_ui(
                 ns,
                 "pressure",
                 "🤖 AI-Powered Pressure Suggestions",
                 current_lang
               )
             } else {
               NULL
             }
      )
    ),

    br(),
    h4(t("gw_activity_pressure_connections_title", current_lang)),
    p(t("gw_link_activities", current_lang)),
    DTOutput(ns("activity_pressure_connections"))
  )
}

# Step 4: Preventive Controls
generate_step4_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-success",
        h5(t("gw_step4_preventive_controls_title", current_lang)),
        p(t("gw_preventive_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             h4(t("gw_search_add_preventive_controls_title", current_lang)),
             p(t("gw_search_add_preventive_controls_desc", current_lang)),
             
             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 control_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
                   level1_controls <- vocabulary_data$controls[vocabulary_data$controls$level == 1 & !is.na(vocabulary_data$controls$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_controls) > 0) {
                     level1_controls <- level1_controls[!is.na(level1_controls$name) & !is.na(level1_controls$id), ]
                     if (nrow(level1_controls) > 0) {
                       control_groups <- setNames(level1_controls$id, level1_controls$name)
                     }
                   }
                 }

                 selectizeInput(ns("preventive_control_group"), "Step 1: Select Control Group",
                              choices = c("Choose a group..." = "", control_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a control category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("preventive_control_item"), "Step 2: Select Specific Control",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a control from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("preventive_control_custom_toggle"), "Or enter a custom control not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.preventive_control_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("preventive_control_custom_text"),
                     label = "Custom Control Name:",
                     placeholder = "Enter new control name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom preventive control measure not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_preventive_control"), tagList(icon("shield-alt"), t("gw_add_control", current_lang)),
                            class = "btn-success btn-block")
               )
             ),
             
             br(),
             h5(t("gw_selected_preventive_controls", current_lang)),
             DTOutput(ns("selected_preventive_controls_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_preventive_controls_examples_title", current_lang)),
                 tags$ul(
                   tags$li(strong(t("gw_preventive_regulatory", current_lang)), t("gw_preventive_regulatory_examples", current_lang)),
                   tags$li(strong(t("gw_preventive_technical", current_lang)), t("gw_preventive_technical_examples", current_lang)),
                   tags$li(strong(t("gw_preventive_management", current_lang)), t("gw_preventive_management_examples", current_lang)),
                   tags$li(strong(t("gw_preventive_physical", current_lang)), t("gw_preventive_physical_examples", current_lang)),
                   tags$li(strong(t("gw_preventive_operational", current_lang)), t("gw_preventive_operational_examples", current_lang))
                 )
             ),

             # AI-powered suggestions for preventive controls (if available)
             if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
               create_ai_suggestions_ui(
                 ns,
                 "control_preventive",
                 "🤖 AI-Powered Control Suggestions",
                 current_lang
               )
             } else {
               NULL
             }
      )
    ),

    br(),
    h4(t("gw_link_controls_title", current_lang)),
    p(t("gw_link_controls_desc", current_lang)),
    DTOutput(ns("preventive_control_links"))
  )
}

# Step 5: Consequences
generate_step5_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-warning",
        h5(t("gw_step5_consequences_title", current_lang)),
        p(t("gw_consequences_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             h4(t("gw_search_add_consequences_title", current_lang)),
             p(t("gw_consequences_desc2", current_lang)),
             
             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 consequence_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$consequences) && nrow(vocabulary_data$consequences) > 0) {
                   level1_consequences <- vocabulary_data$consequences[vocabulary_data$consequences$level == 1 & !is.na(vocabulary_data$consequences$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_consequences) > 0) {
                     level1_consequences <- level1_consequences[!is.na(level1_consequences$name) & !is.na(level1_consequences$id), ]
                     if (nrow(level1_consequences) > 0) {
                       consequence_groups <- setNames(level1_consequences$id, level1_consequences$name)
                     }
                   }
                 }

                 selectizeInput(ns("consequence_group"), "Step 1: Select Consequence Group",
                              choices = c("Choose a group..." = "", consequence_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a consequence category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("consequence_item"), "Step 2: Select Specific Consequence",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a consequence from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("consequence_custom_toggle"), "Or enter a custom consequence not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.consequence_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("consequence_custom_text"),
                     label = "Custom Consequence Name:",
                     placeholder = "Enter new consequence name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom environmental consequence not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_consequence"), tagList(icon("exclamation-triangle"), t("gw_add_consequence", current_lang)),
                            class = "btn-warning btn-block")
               )
             ),
             
             br(),
             h5(t("gw_selected_consequences", current_lang)),
             DTOutput(ns("selected_consequences_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_consequences_examples_title", current_lang)),
                 tags$ul(
                   tags$li(strong(t("gw_consequences_ecological", current_lang)), t("gw_consequences_ecological_examples", current_lang)),
                   tags$li(strong(t("gw_consequences_health", current_lang)), t("gw_consequences_health_examples", current_lang)),
                   tags$li(strong(t("gw_consequences_economic", current_lang)), t("gw_consequences_economic_examples", current_lang)),
                   tags$li(strong(t("gw_consequences_social", current_lang)), t("gw_consequences_social_examples", current_lang)),
                   tags$li(strong(t("gw_consequences_environmental", current_lang)), t("gw_consequences_environmental_examples", current_lang))
                 )
             ),

             # AI-powered suggestions for consequences (if available)
             if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
               create_ai_suggestions_ui(
                 ns,
                 "consequence",
                 "🤖 AI-Powered Consequence Suggestions",
                 current_lang
               )
             } else {
               NULL
             }
      )
    ),

    br(),
    h4(t("gw_consequence_severity_title", current_lang)),
    p(t("gw_consequence_severity_desc", current_lang)),
    DTOutput(ns("consequence_severity_table"))
  )
}

# Step 6: Protective Controls
generate_step6_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-primary",
        h5("�️ Define Protective Controls"),
        p(t("gw_protective_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             h4("🔍 Search and Add Protective/Mitigation Controls"),
             p(t("gw_protective_controls_desc", current_lang)),
             
             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 protective_control_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
                   level1_controls <- vocabulary_data$controls[vocabulary_data$controls$level == 1 & !is.na(vocabulary_data$controls$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_controls) > 0) {
                     level1_controls <- level1_controls[!is.na(level1_controls$name) & !is.na(level1_controls$id), ]
                     if (nrow(level1_controls) > 0) {
                       protective_control_groups <- setNames(level1_controls$id, level1_controls$name)
                     }
                   }
                 }

                 selectizeInput(ns("protective_control_group"), "Step 1: Select Control Group",
                              choices = c("Choose a group..." = "", protective_control_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a control category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("protective_control_item"), "Step 2: Select Specific Control",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a control from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("protective_control_custom_toggle"), "Or enter a custom control not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.protective_control_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("protective_control_custom_text"),
                     label = "Custom Control Name:",
                     placeholder = "Enter new control name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom protective control measure not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_protective_control"), tagList(icon("medkit"), t("gw_add_control", current_lang)),
                            class = "btn-primary btn-block")
               )
             ),
             
             br(),
             h5(t("gw_selected_protective_controls", current_lang)),
             DTOutput(ns("selected_protective_controls_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_protective_controls_examples_title", current_lang)),
                 tags$ul(
                   tags$li(strong(t("gw_protective_emergency", current_lang)), t("gw_protective_emergency_examples", current_lang)),
                   tags$li(strong(t("gw_protective_restoration", current_lang)), t("gw_protective_restoration_examples", current_lang)),
                   tags$li(strong(t("gw_protective_compensation", current_lang)), t("gw_protective_compensation_examples", current_lang)),
                   tags$li(strong(t("gw_protective_recovery", current_lang)), t("gw_protective_recovery_examples", current_lang)),
                   tags$li(strong(t("gw_protective_adaptive", current_lang)), t("gw_protective_adaptive_examples", current_lang))
                 )
             ),

             # AI-powered suggestions for protective controls (if available)
             if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
               create_ai_suggestions_ui(
                 ns,
                 "control_protective",
                 "🤖 AI-Powered Protective Control Suggestions",
                 current_lang
               )
             } else {
               NULL
             }
      )
    ),

    br(),
    h4(t("gw_link_protective_controls_title", current_lang)),
    p(t("gw_link_protective_controls_desc", current_lang)),
    DTOutput(ns("protective_control_links"))
  )
}

# Step 7: Escalation Factors
generate_step7_ui <- function(session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity

  tagList(
    # Custom Entries Review Section
    div(class = "alert alert-info",
        h5(icon("star"), " Custom Entries Review"),
        p("The following custom entries were added during the workflow. Please review them to ensure they are correct.")
    ),

    fluidRow(
      column(12,
             h5("📋 Custom Entries Summary"),
             DTOutput(ns("custom_entries_review_table")),
             br(),
             div(class = "alert alert-warning",
                 h6(icon("info-circle"), " Note"),
                 p("Custom entries are items you added that were not in the predefined vocabulary. Please verify they are accurate and relevant to your analysis.")
             )
      )
    ),

    br(),
    hr(),
    br(),

    div(class = "alert alert-danger",
        h5(t("gw_step7_escalation_factors_title", current_lang)),
        p(t("gw_step7_escalation_factors_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             div(class = "alert alert-warning",
                 h6(t("gw_what_are_escalation_factors_title", current_lang)),
                 p(t("gw_what_are_escalation_factors_desc", current_lang)),
                 p(strong(t("gw_key_concept_title", current_lang)), t("gw_key_concept_desc", current_lang))
             ),
             
             h4(t("gw_search_add_escalation_factors_title", current_lang)),
             
             fluidRow(
               column(8,
                      textInput(ns("escalation_factor_input"), t("gw_add_escalation_factor_label", current_lang),
                               placeholder = t("gw_add_escalation_factor_placeholder", current_lang))
               ),
               column(4,
                      br(),
                      actionButton(ns("add_escalation_factor"), tagList(icon("bolt"), t("gw_add_factor_button", current_lang)),
                                 class = "btn-danger btn-sm")
               )
             ),
             
             br(),
             h5(t("gw_selected_escalation_factors_title", current_lang)),
             DTOutput(ns("selected_escalation_factors_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_escalation_factors_examples_title", current_lang)),
                 tags$ul(
                   tags$li(strong(t("gw_escalation_resource", current_lang)), t("gw_escalation_resource_examples", current_lang)),
                   tags$li(strong(t("gw_escalation_human", current_lang)), t("gw_escalation_human_examples", current_lang)),
                   tags$li(strong(t("gw_escalation_technical", current_lang)), t("gw_escalation_technical_examples", current_lang)),
                   tags$li(strong(t("gw_escalation_organizational", current_lang)), t("gw_escalation_organizational_examples", current_lang)),
                   tags$li(strong(t("gw_escalation_external", current_lang)), t("gw_escalation_external_examples", current_lang))
                 )
             )
      )
    ),
    
    br(),
    h4(t("gw_link_escalation_factors_title", current_lang)),
    p(t("gw_link_escalation_factors_desc", current_lang)),
    
    fluidRow(
      column(6,
             h5(t("gw_preventive_controls_at_risk_title", current_lang)),
             DTOutput(ns("escalation_preventive_links"))
      ),
      column(6,
             h5(t("gw_protective_controls_at_risk_title", current_lang)),
             DTOutput(ns("escalation_protective_links"))
      )
    )
  )
}

# Step 8: Review & Finalize
generate_step8_ui <- function(session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity

  tagList(
    # Review Summary Header
    div(class = "alert alert-success",
        h5(t("gw_step8_review_finalize_title", current_lang)),
        p(t("gw_review_desc", current_lang))
    ),

    # Review Cards
    fluidRow(
      column(12,
             h4(t("gw_complete_bowtie_review_title", current_lang)),

             div(class = "card mb-3",
                 div(class = "card-header bg-primary text-white",
                     h6(t("gw_central_event", current_lang), style = "margin: 0;")
                 ),
                 div(class = "card-body",
                     uiOutput(ns("review_central_problem"))
                 )
             ),

             fluidRow(
               column(6,
                      div(class = "card mb-3",
                          div(class = "card-header bg-info text-white",
                              h6(t("gw_left_side_title", current_lang), style = "margin: 0;")
                          ),
                          div(class = "card-body",
                              h6(t("gw_activities_pressures", current_lang)),
                              uiOutput(ns("review_activities_pressures")),
                              hr(),
                              h6(t("gw_preventive_controls_label", current_lang)),
                              uiOutput(ns("review_preventive_controls"))
                          )
                      )
               ),
               column(6,
                      div(class = "card mb-3",
                          div(class = "card-header bg-warning text-dark",
                              h6(t("gw_right_side_title", current_lang), style = "margin: 0;")
                          ),
                          div(class = "card-body",
                              h6(t("gw_consequences_label", current_lang)),
                              uiOutput(ns("review_consequences")),
                              hr(),
                              h6(t("gw_protective_controls_label", current_lang)),
                              uiOutput(ns("review_protective_controls"))
                          )
                      )
               )
             )
      )
    ),

    br(),

    # Finalize & Export Section - ONE BUTTON DOES ALL
    fluidRow(
      column(12,
             uiOutput(ns("finalize_export_section"))
      )
    )
  )
}

# =============================================================================
# SERVER FUNCTIONS
# =============================================================================

# Server logic for the guided workflow module
guided_workflow_server <- function(id, vocabulary_data, lang = reactive({"en"}),
                                   ai_enabled = reactive({FALSE}),
                                   ai_methods = reactive({c("jaccard")}),
                                   ai_max_suggestions = reactive({5})) {
  moduleServer(id, function(input, output, session) {
    
    # =============================================================================
    # INITIALIZATION & REACTIVE STATE
    # =============================================================================

    # Initialize workflow state
    workflow_state <- reactiveVal(init_workflow_state())

  # -------------------------------------------------------------------------
  # NARROWED REACTIVES - Reduce unnecessary reactive cascade invalidations
  # Instead of watching the entire workflow_state() list (which invalidates
  # ALL downstream observers on ANY field change), these extract specific
  # fields so observers only re-execute when their actual dependency changes.
  # -------------------------------------------------------------------------

  # Narrowed reactive: only invalidates when current_step changes
  current_step_reactive <- reactive({
    workflow_state()$current_step
  })

  # Narrowed reactive: only invalidates when project_data changes
  # Used by Step 8 review renderers (debounced to avoid rapid re-renders)
  project_data_reactive <- reactive({
    workflow_state()$project_data
  })
  project_data_debounced <- project_data_reactive %>% debounce(300)

  # Narrowed reactive: only invalidates when workflow_complete changes
  workflow_complete_reactive <- reactive({
    isTRUE(workflow_state()$workflow_complete)
  })

  # Narrowed reactive: progress-related fields for the progress bar
  progress_state_reactive <- reactive({
    state <- workflow_state()
    list(
      current_step = state$current_step,
      total_steps = state$total_steps,
      completed_steps = state$completed_steps,
      progress_percentage = state$progress_percentage
    )
  })

  # Reactive value for vocabulary data
  vocab_data <- reactiveVal(vocabulary_data)
  
  # Reactive trigger for saving workflow state
  save_trigger <- reactiveVal(0)

  # Store user-defined connections
  activity_pressure_connections <- reactiveVal(data.frame(
    Activity = character(0),
    Pressure = character(0),
    stringsAsFactors = FALSE
  ))

  preventive_control_links <- reactiveVal(data.frame(
    Control = character(0),
    Target = character(0),
    Type = character(0),  # "Activity" or "Pressure"
    stringsAsFactors = FALSE
  ))

  consequence_protective_links <- reactiveVal(data.frame(
    Consequence = character(0),
    Control = character(0),
    stringsAsFactors = FALSE
  ))

  # =============================================================================
  # SMART AUTOSAVE SYSTEM
  # =============================================================================

  # Reactive values for autosave
  last_saved_hash <- reactiveVal(NULL)
  debounce_timer <- reactiveVal(NULL)
  autosave_enabled <- reactiveVal(TRUE)

  # Helper: Compute state hash for change detection
  compute_state_hash <- function(state) {
    tryCatch({
      if (!requireNamespace("digest", quietly = TRUE)) {
        return(NULL)
      }
      if (!requireNamespace("jsonlite", quietly = TRUE)) {
        return(NULL)
      }

      # Extract only the parts that matter for autosave
      hashable_state <- list(
        current_step = state$current_step,
        completed_steps = state$completed_steps,
        project_data = state$project_data,
        validation_status = state$validation_status,
        workflow_complete = state$workflow_complete
      )

      json_state <- jsonlite::toJSON(hashable_state, auto_unbox = TRUE)
      hash_value <- digest::digest(json_state, algo = "md5")

      return(hash_value)
    }, error = function(e) {
      log_warning(paste("Hash computation failed:", e$message))
      return(NULL)
    })
  }

  # Helper: Perform smart autosave
  perform_smart_autosave <- function() {
    isolate({
      state <- workflow_state()
      req(state)
      req(autosave_enabled())

      # Only autosave if we're past step 1
      if (state$current_step <= 1) {
        return(NULL)
      }

      current_hash <- compute_state_hash(state)

      # Only save if state actually changed
      if (!is.null(current_hash) &&
          (is.null(last_saved_hash()) || current_hash != last_saved_hash())) {

        tryCatch({
          if (requireNamespace("jsonlite", quietly = TRUE)) {
            state_json <- jsonlite::toJSON(state, auto_unbox = TRUE)
            timestamp <- format(Sys.time(), "%H:%M:%S")

            session$sendCustomMessage("smartAutosave", list(
              state = as.character(state_json),
              timestamp = timestamp,
              hash = current_hash
            ))

            last_saved_hash(current_hash)
            log_debug(paste("Autosaved at", timestamp, "(hash:", substr(current_hash, 1, 8), ")"))
          }
        }, error = function(e) {
          log_error(paste("Autosave failed:", e$message))
        })
      }
    })
  }

  # Helper: Trigger autosave with debouncing (no nested observers)
  trigger_autosave_debounced <- function(delay_ms = 3000) {
    debounce_timer(Sys.time())
  }

  # Single observer for debounced autosave (avoids observer leak)
  observe({
    timer_value <- debounce_timer()
    req(timer_value)
    invalidateLater(3000, session)

    time_diff <- difftime(Sys.time(), timer_value, units = "secs")
    if (as.numeric(time_diff) >= 3) {
      perform_smart_autosave()
      debounce_timer(NULL)
    }
  }, priority = -1)

  # Watch for workflow state changes and trigger autosave
  # Throttled to 500ms - prevents excessive autosave triggers during rapid state updates
  # (e.g., adding multiple items quickly). The actual save is further debounced to 3000ms
  # by trigger_autosave_debounced, so this throttle just limits how often we check.
  autosave_state_hash_raw <- reactive({
    state <- workflow_state()
    req(state)
    req(autosave_enabled())
    compute_state_hash(state)
  })
  autosave_state_hash_throttled <- autosave_state_hash_raw %>% throttle(500)

  observe({
    hash <- autosave_state_hash_throttled()
    req(hash)

    # Trigger debounced autosave on any state change
    trigger_autosave_debounced(delay_ms = 3000)
  }, priority = -1)  # Low priority to run after other state updates

  # =============================================================================
  # SESSION RESTORE
  # =============================================================================

  # On session start, check for autosaved state
  observeEvent(session$clientData$url_search, {
    if (requireNamespace("jsonlite", quietly = TRUE)) {
      session$sendCustomMessage("loadFromLocalStorage", list(
        key = "bowtie_workflow_autosave",
        inputId = "restored_workflow_state"
      ))
    }
  }, once = TRUE, priority = 100)  # High priority to run early

  # Handle restored state
  observeEvent(input$restored_workflow_state, {
    req(input$restored_workflow_state)

    tryCatch({
      if (requireNamespace("jsonlite", quietly = TRUE)) {
        restored <- jsonlite::fromJSON(input$restored_workflow_state, simplifyVector = FALSE)

        # Validate restored state
        if (is.list(restored) && "current_step" %in% names(restored)) {
          # Show restore dialog
          showModal(modalDialog(
            title = tagList(icon("history"), " Restore Previous Session?"),
            tagList(
              p(HTML(paste0(
                "A previous workflow session was found.<br>",
                "<strong>Step ", restored$current_step, " of ", restored$total_steps, "</strong>",
                if (!is.null(restored$project_data$project_name) && nchar(restored$project_data$project_name) > 0) {
                  paste0("<br>Project: <em>", restored$project_data$project_name, "</em>")
                } else { "" }
              ))),
              hr(),
              p("Would you like to restore this session or start fresh?")
            ),
            footer = tagList(
              actionButton("restore_yes", "Restore Session", class = "btn-primary", icon = icon("undo")),
              actionButton("restore_no", "Start Fresh", class = "btn-secondary", icon = icon("file"))
            ),
            size = "m",
            easyClose = FALSE
          ))
        }
      }
    }, error = function(e) {
      log_warning(paste("Error processing restored state:", e$message))
    })
  }, once = TRUE, ignoreNULL = TRUE)

  # Handle restore confirmation
  observeEvent(input$restore_yes, {
    req(input$restored_workflow_state)

    tryCatch({
      if (requireNamespace("jsonlite", quietly = TRUE)) {
        restored <- jsonlite::fromJSON(input$restored_workflow_state, simplifyVector = FALSE)

        # Convert list back to proper structure
        restored_state <- init_workflow_state()  # Start with default

        # Merge restored data
        for (name in names(restored)) {
          if (name %in% names(restored_state)) {
            restored_state[[name]] <- restored[[name]]
          }
        }

        # Update workflow state
        workflow_state(restored_state)

        # Update hash to current state
        last_saved_hash(compute_state_hash(restored_state))

        notify_success(paste("Session restored successfully! Resuming at Step", restored_state$current_step), duration = 5)

        log_success("Workflow session restored from autosave")
      }
    }, error = function(e) {
      notify_error(paste("Error restoring session:", e$message), duration = 10)
      log_error(paste("Error restoring session:", e$message))
    })

    removeModal()
  })

  # Handle start fresh
  observeEvent(input$restore_no, {
    # Clear autosave from localStorage
    session$sendCustomMessage("clearAutosave", list())

    notify_info("Starting fresh workflow session", duration = 3)

    removeModal()
  })

  # =============================================================================
  # AI-POWERED SUGGESTIONS INITIALIZATION
  # =============================================================================

  # Initialize AI suggestion handlers if available
  if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE) {
    tryCatch({
      # Source the server-side suggestion handlers
      if (file.exists("guided_workflow_ai_suggestions_server.R")) {
        source("guided_workflow_ai_suggestions_server.R", local = TRUE)

        # Initialize handlers with workflow state and vocabulary data
        init_ai_suggestion_handlers(
          input = input,
          output = output,
          session = session,
          workflow_state = workflow_state,  # Pass reactive, not value
          vocabulary_data_reactive = vocab_data,
          ai_enabled = ai_enabled,  # User setting from settings panel
          ai_methods = ai_methods,  # Selected methods (jaccard, keyword, causal)
          ai_max_suggestions = ai_max_suggestions  # Max number of suggestions
        )

        log_success("AI suggestions module ready (controlled by settings)")
      }
    }, error = function(e) {
      log_warning(paste("Failed to initialize AI suggestions:", e$message))
    })
  }

  # =============================================================================
  # UI RENDERING
  # =============================================================================
  
  # Render progress tracker
  # Uses narrowed progress_state_reactive instead of full workflow_state()
  output$workflow_progress_ui <- renderUI({
    progress_state <- progress_state_reactive()
    req(progress_state)
    # Build a minimal state-like list for the UI function
    workflow_progress_ui(progress_state, lang())
  })

  # Render steps sidebar
  # Uses narrowed progress_state_reactive (only needs current_step + completed_steps)
  output$workflow_steps_sidebar <- renderUI({
    progress_state <- progress_state_reactive()
    req(progress_state)
    workflow_steps_sidebar_ui(progress_state, lang())
  })

  # Render current step header
  # Uses narrowed current_step_reactive - only re-renders on step change
  output$current_step_header <- renderUI({
    step_num <- current_step_reactive()
    req(step_num)
    current_lang <- lang()
    step_info <- WORKFLOW_CONFIG$steps[[step_num]]

    tagList(
      h4(t(step_info$title, current_lang)),
      tags$small(class = "text-muted", t(step_info$description, current_lang))
    )
  })

  # Render current step content
  # Uses narrowed current_step_reactive - only re-renders on step change
  output$current_step_content <- renderUI({
    step_num <- current_step_reactive()
    req(step_num)

    # Get the UI generation function for the current step
    ui_function_name <- paste0("generate_step", step_num, "_ui")

    if (exists(ui_function_name, mode = "function")) {
      ui_function <- get(ui_function_name)
      # Call with session parameter and vocabulary_data for steps that need it
      if (step_num %in% c(3, 4, 5, 6)) {
        ui_function(vocabulary_data = vocabulary_data, session = session, current_lang = lang())
      } else {
        ui_function(session = session, current_lang = lang())
      }
    } else {
      div(class = "alert alert-danger",
          paste("UI for step", step_num, "not found."))
    }
  })

  # Render navigation buttons
  # Uses narrowed current_step_reactive - only re-renders on step change
  output$workflow_navigation <- renderUI({
    step_num <- current_step_reactive()
    req(step_num)

    ns <- session$ns  # Get namespace function
    total <- isolate(workflow_state()$total_steps)

    # On Step 8, only show Previous button - the finalize button is in the step content
    if (step_num == total) {
      tagList(
        if (step_num > 1) {
          actionButton(ns("prev_step"), t("gw_previous", lang()), icon = icon("arrow-left"), class = "btn-secondary")
        }
      )
    } else {
      # For steps 1-7, show normal navigation
      tagList(
        if (step_num > 1) {
          actionButton(ns("prev_step"), t("gw_previous", lang()), icon = icon("arrow-left"), class = "btn-secondary")
        },
        actionButton(ns("next_step"), t("gw_next", lang()), icon = icon("arrow-right"), class = "btn-primary")
      )
    }
  })
  
  # =============================================================================
  # EVENT HANDLING & NAVIGATION
  # =============================================================================
  
  # Track the previous step to detect ACTUAL step changes
  # Use reactiveVal to store the last step we processed
  last_processed_step <- reactiveVal(0)

  # Update selectize choices when entering step 3
  # ONLY triggers when step ACTUALLY changes from a different value
  # Uses narrowed current_step_reactive to avoid firing on non-step state changes
  observe({
    current_step_num <- current_step_reactive() %||% 0
    previous_step <- last_processed_step()

    log_debug(paste("[VOCAB CHOICES] Observer triggered. Current step:", current_step_num, "| Previous:", previous_step))

    # Only update if step has ACTUALLY CHANGED
    if (current_step_num != previous_step) {
      log_debug(paste("[VOCAB CHOICES] Step changed from", previous_step, "to", current_step_num))
      last_processed_step(current_step_num)

      if (current_step_num == 3) {
        log_debug("[VOCAB CHOICES] Entering Step 3 - updating vocabulary choices")

        # Update activity choices
        if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities)) {
          activity_choices <- vocabulary_data$activities$name
          if (length(activity_choices) > 0) {
            log_debug(paste("[VOCAB CHOICES] Updating activity_search with", length(activity_choices), "choices"))
            updateSelectizeInput(session, "activity_search",
                               choices = activity_choices,
                               server = TRUE,
                               selected = character(0))
          }
        }

        # Update pressure choices
        if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures)) {
          pressure_choices <- vocabulary_data$pressures$name
          if (length(pressure_choices) > 0) {
            log_debug(paste("[VOCAB CHOICES] Updating pressure_search with", length(pressure_choices), "choices"))
            updateSelectizeInput(session, "pressure_search",
                               choices = pressure_choices,
                               server = TRUE,
                               selected = character(0))
          }
        }

        log_debug("[VOCAB CHOICES] Vocabulary choices updated.")
      }
    } else {
      log_debug(paste("[VOCAB CHOICES] Step unchanged (still", current_step_num, ") - skipping vocab update"))
    }
  })
  
  # Handle "Next" button click
  observeEvent(input$next_step, {
    state <- workflow_state()
    
    # Validate current step before proceeding
    validation_result <- validate_current_step(state, input)
    if (!validation_result$is_valid) {
      notify_error(validation_result$message, duration = 5)
      return()
    }
    
    # Save data from current step
    state <- save_step_data(state, input)
    
    # Mark step as complete
    if (!state$current_step %in% state$completed_steps) {
      state$completed_steps <- c(state$completed_steps, state$current_step)
    }
    
    # Move to next step
    if (state$current_step < state$total_steps) {
      state$current_step <- state$current_step + 1
    }
    
    # Update progress
    state$progress_percentage <- (length(state$completed_steps) / state$total_steps) * 100
    
    workflow_state(state)
  })
  
  # Handle "Previous" button click
  observeEvent(input$prev_step, {
    state <- workflow_state()
    if (state$current_step > 1) {
      state$current_step <- state$current_step - 1
      workflow_state(state)
    }
  })
  
  # Handle direct step navigation from sidebar
  observeEvent(input$goto_step, {
    state <- workflow_state()
    target_step <- as.numeric(input$goto_step)
    
    # Allow navigation only to completed steps or current step
    if (target_step <= state$current_step || target_step - 1 %in% state$completed_steps) {
      state$current_step <- target_step
      workflow_state(state)
    } else {
      notify_warning(t("gw_complete_previous", lang()))
    }
  })
  
  # =============================================================================
  # STEP 3: ACTIVITY & PRESSURE MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected activities and pressures
  selected_activities <- reactiveVal(list())
  selected_pressures <- reactiveVal(list())

  # Reactive values to track custom entries (not in vocabulary)
  custom_entries <- reactiveVal(list(
    activities = character(0),
    pressures = character(0),
    preventive_controls = character(0),
    consequences = character(0),
    protective_controls = character(0)
  ))

  # =============================================================================
  # HIERARCHICAL SELECTION: Update item choices when group is selected
  # =============================================================================

  # Update activity items when group is selected
  observeEvent(input$activity_group, {
    req(input$activity_group)
    if (nchar(input$activity_group) > 0 && !is.null(vocabulary_data$activities)) {
      # Get children of selected group using secure helper function
      children <- get_vocabulary_children(vocabulary_data$activities, input$activity_group)
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "activity_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Update pressure items when group is selected
  observeEvent(input$pressure_group, {
    req(input$pressure_group)
    if (nchar(input$pressure_group) > 0 && !is.null(vocabulary_data$pressures)) {
      # Get children of selected group using secure helper function
      children <- get_vocabulary_children(vocabulary_data$pressures, input$pressure_group)
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "pressure_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Update preventive control items when group is selected
  observeEvent(input$preventive_control_group, {
    req(input$preventive_control_group)
    if (nchar(input$preventive_control_group) > 0 && !is.null(vocabulary_data$controls)) {
      # Get children of selected group using secure helper function
      children <- get_vocabulary_children(vocabulary_data$controls, input$preventive_control_group)
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "preventive_control_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Update consequence items when group is selected
  observeEvent(input$consequence_group, {
    req(input$consequence_group)
    if (nchar(input$consequence_group) > 0 && !is.null(vocabulary_data$consequences)) {
      # Get children of selected group using secure helper function
      children <- get_vocabulary_children(vocabulary_data$consequences, input$consequence_group)
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "consequence_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Update protective control items when group is selected
  observeEvent(input$protective_control_group, {
    req(input$protective_control_group)
    if (nchar(input$protective_control_group) > 0 && !is.null(vocabulary_data$controls)) {
      # Get children of selected group using secure helper function
      children <- get_vocabulary_children(vocabulary_data$controls, input$protective_control_group)
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "protective_control_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Sync reactive values with workflow state when entering Step 3
  # Uses narrowed current_step_reactive to only fire on step changes
  observe({
    step_num <- current_step_reactive()
    if (!is.null(step_num) && step_num == 3) {
      log_debug("[STATE SYNC] Step 3 state sync triggered")

      # Read full state only when we know we need it (isolate prevents dependency)
      state <- isolate(workflow_state())

      # Load activities from state if available
      if (!is.null(state$project_data$activities) && length(state$project_data$activities) > 0) {
        # Ensure it's a character vector
        activities <- as.character(state$project_data$activities)
        log_debug(paste("[STATE SYNC] Loading", length(activities), "activities from state:", paste(activities, collapse = ", ")))
        selected_activities(activities)
      } else {
        log_debug("[STATE SYNC] No activities in state - clearing list")
        selected_activities(list())
      }

      # Load pressures from state if available
      if (!is.null(state$project_data$pressures) && length(state$project_data$pressures) > 0) {
        # Ensure it's a character vector
        pressures <- as.character(state$project_data$pressures)
        log_debug(paste("[STATE SYNC] Loading", length(pressures), "pressures from state:", paste(pressures, collapse = ", ")))
        selected_pressures(pressures)
      } else {
        log_debug("[STATE SYNC] No pressures in state - clearing list")
        selected_pressures(list())
      }

      log_debug("[STATE SYNC] State sync completed. NOT touching input fields.")
    }
  })
  
  # =========================================================================
  # Factory function for "add item" observers
  # Replaces 5 identical ~60-line observeEvent handlers
  # =========================================================================
  create_add_item_observer <- function(
    add_button_id,        # e.g., "add_activity"
    item_type,            # e.g., "activities" (key in project_data)
    custom_toggle_id,     # e.g., "activity_custom_toggle"
    custom_text_id,       # e.g., "activity_custom_text"
    item_input_id,        # e.g., "activity_item"
    reactive_selected,    # e.g., selected_activities (reactiveVal)
    translation_added,    # e.g., "gw_added_activity"
    translation_exists,   # e.g., "gw_activity_exists"
    group_input_id = NULL # e.g., "activity_group" (for selectize restore)
  ) {
    observeEvent(input[[add_button_id]], {
      # Determine if using custom entry or hierarchical selection
      item_name <- NULL
      is_custom <- FALSE

      if (!is.null(input[[custom_toggle_id]]) && input[[custom_toggle_id]]) {
        item_name <- input[[custom_text_id]]
        is_custom <- TRUE
      } else {
        item_name <- input[[item_input_id]]
      }

      # Validate: not NULL, not NA, not empty after trimming
      if (!is.null(item_name) && !is.na(item_name) &&
          nchar(trimws(item_name)) > 0) {
        current <- reactive_selected()

        if (!item_name %in% current) {
          current <- c(current, item_name)
          reactive_selected(current)

          # Track custom entries
          if (is_custom) {
            custom_list <- custom_entries()
            custom_list[[item_type]] <- c(custom_list[[item_type]], item_name)
            custom_entries(custom_list)

            tryCatch({
              state <- workflow_state()
              project_name <- if (!is.null(state$project_data$project_name)) state$project_data$project_name else ""
              add_custom_term(item_type, item_name, "default", project_name)
            }, error = function(e) {
              log_warning(paste("Failed to persist custom term:", e$message))
            })

            # Use generic label from item_type: "activities" -> "activity"
            label <- gsub("_", " ", sub("s$", "", item_type))
            notify_info(paste("Added custom", label, ":", item_name, "(marked for review)"), duration = 3)
          } else {
            notify_info(paste(t(translation_added, lang()), item_name), duration = 2)
          }

          # Update workflow state
          state <- workflow_state()
          state$project_data[[item_type]] <- current
          state$project_data$custom_entries <- custom_entries()
          workflow_state(state)

          # Save parent group before clearing child (prevents Selectize.js cascade)
          saved_group <- if (!is.null(group_input_id)) input[[group_input_id]] else NULL

          # Clear item selection
          updateSelectizeInput(session, session$ns(item_input_id), selected = character(0))
          if (is_custom) {
            updateTextInput(session, session$ns(custom_text_id), value = "")
          }

          # Restore parent group via JS if needed
          if (!is.null(saved_group) && !is.null(group_input_id) && nchar(saved_group) > 0) {
            ns_id <- session$ns(group_input_id)
            shinyjs::runjs(sprintf(
              "setTimeout(function() {
                var elem = $('#%s');
                if (elem.length > 0 && elem[0].selectize) {
                  elem[0].selectize.setValue('%s', false);
                }
              }, 200);",
              ns_id, saved_group
            ))
          }
        } else {
          notify_warning(t(translation_exists, lang()), duration = 2)
        }
      } else {
        label <- gsub("_", " ", sub("s$", "", item_type))
        notify_warning(paste("Please select a", label, "or enter a custom name"), duration = 2)
      }
    })
  }

  # Handle "Add Activity" button
  create_add_item_observer(
    add_button_id = "add_activity",
    item_type = "activities",
    custom_toggle_id = "activity_custom_toggle",
    custom_text_id = "activity_custom_text",
    item_input_id = "activity_item",
    reactive_selected = selected_activities,
    translation_added = "gw_added_activity",
    translation_exists = "gw_activity_exists",
    group_input_id = "activity_group"
  )
  
  # Handle "Add Pressure" button
  create_add_item_observer(
    add_button_id = "add_pressure",
    item_type = "pressures",
    custom_toggle_id = "pressure_custom_toggle",
    custom_text_id = "pressure_custom_text",
    item_input_id = "pressure_item",
    reactive_selected = selected_pressures,
    translation_added = "gw_added_pressure",
    translation_exists = "gw_pressure_exists",
    group_input_id = "pressure_group"
  )
  
  # Render selected activities table (uses helper function for consistency)
  output$selected_activities_table <- renderDT({
    create_simple_datatable(selected_activities(), "Activity")
  })

  # Render selected pressures table (uses helper function for consistency)
  output$selected_pressures_table <- renderDT({
    create_simple_datatable(selected_pressures(), "Pressure")
  })
  
  # Render activity-pressure connections table
  output$activity_pressure_connections <- renderDT({
    activities <- selected_activities()
    pressures <- selected_pressures()

    # Get user-defined connections
    user_connections <- activity_pressure_connections()

    # If user hasn't created any connections yet, show auto-suggested ones
    if (nrow(user_connections) == 0 && length(activities) > 0 && length(pressures) > 0) {
      # Auto-suggest connections (all combinations) with a note
      connections <- expand.grid(
        Activity = activities,
        Pressure = pressures,
        stringsAsFactors = FALSE
      )
      connections$Note <- "Auto-suggested"
    } else if (nrow(user_connections) > 0) {
      # Show user-created connections
      connections <- user_connections
      connections$Note <- "User-defined"
    } else {
      # Empty state
      connections <- data.frame(
        Activity = character(0),
        Pressure = character(0),
        Note = character(0),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package - explicitly use DT::datatable
    DT::datatable(
      connections,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'single',
      class = 'cell-border stripe'
    )
  })
  
  # =============================================================================
  # STEP 4: PREVENTIVE CONTROLS MANAGEMENT
  # =============================================================================
  
  # =========================================================================
  # Factory function for step-sync observers
  # Replaces identical step-sync patterns for steps 4, 5, 6
  # =========================================================================
  create_step_sync_observer <- function(
    step_number,
    vocab_type,         # e.g., "controls", "consequences" (key in vocabulary_data)
    search_input_id,    # e.g., "preventive_control_search"
    reactive_selected,  # e.g., selected_preventive_controls
    state_key           # e.g., "preventive_controls" (key in project_data)
  ) {
    # Uses narrowed current_step_reactive to only fire on step changes
    observe({
      step_num <- current_step_reactive()
      if (!is.null(step_num) && step_num == step_number) {
        # Update vocabulary search choices
        if (!is.null(vocabulary_data) && !is.null(vocabulary_data[[vocab_type]])) {
          choices <- vocabulary_data[[vocab_type]]$name
          if (length(choices) > 0) {
            log_debug(paste("Updating", search_input_id, "with", length(choices), "choices"))
            updateSelectizeInput(session, search_input_id,
                               choices = choices, server = TRUE,
                               selected = character(0))
          }
        }

        # Read full state only when we know we need it (isolate prevents dependency)
        state <- isolate(workflow_state())

        # Load from state if available
        if (!is.null(state$project_data[[state_key]]) &&
            length(state$project_data[[state_key]]) > 0) {
          reactive_selected(as.character(state$project_data[[state_key]]))
        } else {
          reactive_selected(list())
        }
      }
    })
  }

  # Reactive values to store selected preventive controls
  selected_preventive_controls <- reactiveVal(list())

  # Sync reactive values with workflow state when entering Step 4
  create_step_sync_observer(
    step_number = 4,
    vocab_type = "controls",
    search_input_id = "preventive_control_search",
    reactive_selected = selected_preventive_controls,
    state_key = "preventive_controls"
  )
  
  # Handle "Add Preventive Control" button
  create_add_item_observer(
    add_button_id = "add_preventive_control",
    item_type = "preventive_controls",
    custom_toggle_id = "preventive_control_custom_toggle",
    custom_text_id = "preventive_control_custom_text",
    item_input_id = "preventive_control_item",
    reactive_selected = selected_preventive_controls,
    translation_added = "gw_added_control",
    translation_exists = "gw_control_exists"
  )
  
  # Render selected preventive controls table
  output$selected_preventive_controls_table <- renderDT({
    create_simple_datatable(selected_preventive_controls(), "Control", page_length = 10)
  })
  
  # Render preventive control links table
  output$preventive_control_links <- renderDT({
    controls <- selected_preventive_controls()
    activities <- selected_activities()
    pressures <- selected_pressures()

    # Get user-defined preventive control links
    user_links <- preventive_control_links()

    # If no user-defined links, show auto-suggested ones
    if (nrow(user_links) == 0 && length(controls) > 0) {
      # Create auto-suggested links
      targets <- c(
        if (length(activities) > 0) paste("Activity:", activities) else character(0),
        if (length(pressures) > 0) paste("Pressure:", pressures) else character(0)
      )

      if (length(targets) > 0) {
        # Suggest all combinations with a note
        auto_links <- expand.grid(
          Control = controls,
          Addresses = targets,
          stringsAsFactors = FALSE
        )
        auto_links$Note <- "Auto-suggested"
        display_data <- auto_links
      } else {
        display_data <- data.frame(
          Control = controls,
          Addresses = "No activities/pressures defined",
          Note = "Waiting for data",
          stringsAsFactors = FALSE
        )
      }
    } else if (nrow(user_links) > 0) {
      # Format user-defined links
      display_data <- data.frame(
        Control = user_links$Control,
        Addresses = paste0(user_links$Type, ": ", user_links$Target),
        Note = "User-defined",
        stringsAsFactors = FALSE
      )
    } else {
      # Empty state
      display_data <- data.frame(
        Control = character(0),
        Addresses = character(0),
        Note = character(0),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package
    DT::datatable(
      display_data,
      options = list(
        pageLength = 15,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'single',
      class = 'cell-border stripe'
    )
  })
  
  # =============================================================================
  # STEP 5: CONSEQUENCES MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected consequences
  selected_consequences <- reactiveVal(list())

  # Sync reactive values with workflow state when entering Step 5
  create_step_sync_observer(
    step_number = 5,
    vocab_type = "consequences",
    search_input_id = "consequence_search",
    reactive_selected = selected_consequences,
    state_key = "consequences"
  )
  
  # Handle "Add Consequence" button
  create_add_item_observer(
    add_button_id = "add_consequence",
    item_type = "consequences",
    custom_toggle_id = "consequence_custom_toggle",
    custom_text_id = "consequence_custom_text",
    item_input_id = "consequence_item",
    reactive_selected = selected_consequences,
    translation_added = "gw_added_consequence",
    translation_exists = "gw_consequence_exists"
  )
  
  # Render selected consequences table
  output$selected_consequences_table <- renderDT({
    create_simple_datatable(selected_consequences(), "Consequence", page_length = 10)
  })
  
  # Render consequence severity assessment table
  output$consequence_severity_table <- renderDT({
    consequences <- selected_consequences()
    
    if (length(consequences) == 0) {
      # Return empty data frame
      dt_data <- data.frame(
        Consequence = character(0),
        Severity = character(0),
        stringsAsFactors = FALSE
      )
    } else {
      # Create a table for severity assessment
      dt_data <- data.frame(
        Consequence = consequences,
        Severity = rep("Medium (to be assessed)", length(consequences)),
        stringsAsFactors = FALSE
      )
    }
    
    # Render with DT package
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })
  
  # =============================================================================
  # STEP 6: PROTECTIVE CONTROLS MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected protective controls
  selected_protective_controls <- reactiveVal(list())

  # Sync reactive values with workflow state when entering Step 6
  create_step_sync_observer(
    step_number = 6,
    vocab_type = "controls",
    search_input_id = "protective_control_search",
    reactive_selected = selected_protective_controls,
    state_key = "protective_controls"
  )
  
  # Handle "Add Protective Control" button
  create_add_item_observer(
    add_button_id = "add_protective_control",
    item_type = "protective_controls",
    custom_toggle_id = "protective_control_custom_toggle",
    custom_text_id = "protective_control_custom_text",
    item_input_id = "protective_control_item",
    reactive_selected = selected_protective_controls,
    translation_added = "gw_added_protective",
    translation_exists = "gw_protective_exists"
  )
  
  # Render selected protective controls table
  output$selected_protective_controls_table <- renderDT({
    create_simple_datatable(selected_protective_controls(), "Control", page_length = 10)
  })
  
  # Render protective control links table
  output$protective_control_links <- renderDT({
    consequences <- selected_consequences()
    protective_controls <- selected_protective_controls()

    # Get user-defined consequence-protective control links
    user_links <- consequence_protective_links()

    # If no user-defined links, show auto-suggested ones
    if (nrow(user_links) == 0 && length(protective_controls) > 0 && length(consequences) > 0) {
      # Auto-suggest all combinations
      auto_links <- expand.grid(
        Control = protective_controls,
        Mitigates = consequences,
        stringsAsFactors = FALSE
      )
      auto_links$Note <- "Auto-suggested"
      display_data <- auto_links
    } else if (nrow(user_links) > 0) {
      # Show user-defined links
      display_data <- data.frame(
        Control = user_links$Control,
        Mitigates = user_links$Consequence,
        Note = "User-defined",
        stringsAsFactors = FALSE
      )
    } else {
      # Empty state
      display_data <- data.frame(
        Control = character(0),
        Mitigates = character(0),
        Note = character(0),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package
    DT::datatable(
      display_data,
      options = list(
        pageLength = 15,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'single',
      class = 'cell-border stripe'
    )
  })
  
  # =============================================================================
  # STEP 7: ESCALATION FACTORS MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected escalation factors
  selected_escalation_factors <- reactiveVal(list())
  
  # Sync reactive values with workflow state when entering Step 7
  # Uses narrowed current_step_reactive to only fire on step changes
  observe({
    step_num <- current_step_reactive()
    if (!is.null(step_num) && step_num == 7) {
      # Read full state only when we know we need it (isolate prevents dependency)
      state <- isolate(workflow_state())

      # Load escalation factors from state if available
      if (!is.null(state$project_data$escalation_factors) && length(state$project_data$escalation_factors) > 0) {
        factors <- as.character(state$project_data$escalation_factors)
        selected_escalation_factors(factors)
      } else {
        selected_escalation_factors(list())
      }

      # Load custom entries from state if available
      if (!is.null(state$project_data$custom_entries)) {
        custom_entries(state$project_data$custom_entries)
      }
    }
  })

  # Render custom entries review table
  output$custom_entries_review_table <- renderDT({
    custom_list <- custom_entries()

    # Create a data frame with all custom entries (optimized - single rbind)
    # Collect all non-empty categories in a list, then rbind once
    entries_list <- list()

    if (length(custom_list$activities) > 0) {
      entries_list$activities <- data.frame(
        Category = rep("Activity", length(custom_list$activities)),
        Item = custom_list$activities,
        stringsAsFactors = FALSE
      )
    }

    if (length(custom_list$pressures) > 0) {
      entries_list$pressures <- data.frame(
        Category = rep("Pressure", length(custom_list$pressures)),
        Item = custom_list$pressures,
        stringsAsFactors = FALSE
      )
    }

    if (length(custom_list$preventive_controls) > 0) {
      entries_list$preventive_controls <- data.frame(
        Category = rep("Preventive Control", length(custom_list$preventive_controls)),
        Item = custom_list$preventive_controls,
        stringsAsFactors = FALSE
      )
    }

    if (length(custom_list$consequences) > 0) {
      entries_list$consequences <- data.frame(
        Category = rep("Consequence", length(custom_list$consequences)),
        Item = custom_list$consequences,
        stringsAsFactors = FALSE
      )
    }

    if (length(custom_list$protective_controls) > 0) {
      entries_list$protective_controls <- data.frame(
        Category = rep("Protective Control", length(custom_list$protective_controls)),
        Item = custom_list$protective_controls,
        stringsAsFactors = FALSE
      )
    }

    # Single rbind operation at the end
    if (length(entries_list) > 0) {
      entries_data <- do.call(rbind, entries_list)
    } else {
      entries_data <- data.frame(Category = character(0), Item = character(0), stringsAsFactors = FALSE)
    }

    if (nrow(entries_data) == 0) {
      entries_data <- data.frame(
        Category = "No custom entries",
        Item = "All items were selected from the vocabulary",
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package
    DT::datatable(
      entries_data,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 't'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })

  # Handle "Add Escalation Factor" button
  observeEvent(input$add_escalation_factor, {
    factor_name <- input$escalation_factor_input

    # Validate: not NULL, not NA, not empty after trimming
    if (!is.null(factor_name) && !is.na(factor_name) &&
        nchar(trimws(factor_name)) > 0) {
      # Get current list
      current <- selected_escalation_factors()

      # Check if already added
      if (!factor_name %in% current) {
        current <- c(current, factor_name)
        selected_escalation_factors(current)
        
        # Update workflow state
        state <- workflow_state()
        state$project_data$escalation_factors <- current
        workflow_state(state)
        
        notify_info(paste(t("gw_added_escalation", lang()), factor_name), duration = 2)

        # Clear the input
        updateTextInput(session, session$ns("escalation_factor_input"), value = "")
      } else {
        notify_warning(t("gw_escalation_exists", lang()), duration = 2)
      }
    }
  })
  
  # Render selected escalation factors table
  output$selected_escalation_factors_table <- renderDT({
    create_simple_datatable(selected_escalation_factors(), "Escalation Factor", page_length = 10)
  })
  
  # Render escalation factors affecting preventive controls
  output$escalation_preventive_links <- renderDT({
    factors <- selected_escalation_factors()
    preventive_controls <- selected_preventive_controls()
    
    if (length(factors) == 0) {
      # Return empty data frame
      dt_data <- data.frame(
        `Escalation Factor` = character(0),
        `Affects Control` = character(0),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    } else {
      # Create a table showing which preventive controls are affected
      if (length(preventive_controls) > 0) {
        # Create combinations for user to review
        links <- expand.grid(
          `Escalation Factor` = factors,
          `Affects Control` = preventive_controls,
          stringsAsFactors = FALSE
        )
        names(links) <- c(t("gw_col_escalation", lang()), "Affects Control")
        dt_data <- links
      } else {
        dt_data <- data.frame(
          `Escalation Factor` = factors,
          `Affects Control` = "No preventive controls defined yet",
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
      }
    }
    
    # Render with DT package
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })
  
  # Render escalation factors affecting protective controls
  output$escalation_protective_links <- renderDT({
    factors <- selected_escalation_factors()
    protective_controls <- selected_protective_controls()
    
    if (length(factors) == 0) {
      # Return empty data frame
      dt_data <- data.frame(
        `Escalation Factor` = character(0),
        `Affects Control` = character(0),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    } else {
      # Create a table showing which protective controls are affected
      if (length(protective_controls) > 0) {
        # Create combinations for user to review
        links <- expand.grid(
          `Escalation Factor` = factors,
          `Affects Control` = protective_controls,
          stringsAsFactors = FALSE
        )
        names(links) <- c(t("gw_col_escalation", lang()), "Affects Control")
        dt_data <- links
      } else {
        dt_data <- data.frame(
          `Escalation Factor` = factors,
          `Affects Control` = "No protective controls defined yet",
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
      }
    }
    
    # Render with DT package
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })

  # =============================================================================
  # CONNECTION OBSERVERS - Handle user-defined connection creation
  # =============================================================================

  # Observer for adding activity-pressure connections
  observeEvent(input$add_connection, {
    req(input$connection_activity, input$connection_pressure)

    current_connections <- activity_pressure_connections()
    new_connection <- data.frame(
      Activity = input$connection_activity,
      Pressure = input$connection_pressure,
      stringsAsFactors = FALSE
    )

    # Check for duplicates
    is_duplicate <- nrow(current_connections) > 0 && any(
      current_connections$Activity == new_connection$Activity &
      current_connections$Pressure == new_connection$Pressure
    )

    if (!is_duplicate) {
      updated_connections <- rbind(current_connections, new_connection)
      activity_pressure_connections(updated_connections)

      notify_info("Connection added successfully!", duration = 2)

      # Reset selections
      updateSelectizeInput(session, "connection_activity", selected = character(0))
      updateSelectizeInput(session, "connection_pressure", selected = character(0))
    } else {
      notify_warning("This connection already exists!", duration = 2)
    }
  })

  # Observer for adding preventive control links
  observeEvent(input$add_control_link, {
    req(input$link_control, input$link_target)

    current_links <- preventive_control_links()

    # Determine if target is activity or pressure
    target_type <- if(grepl("^Activity:", input$link_target)) "Activity" else "Pressure"
    target_name <- gsub("^(Activity|Pressure): ", "", input$link_target)

    new_link <- data.frame(
      Control = input$link_control,
      Target = target_name,
      Type = target_type,
      stringsAsFactors = FALSE
    )

    # Check for duplicates
    is_duplicate <- nrow(current_links) > 0 && any(
      current_links$Control == new_link$Control &
      current_links$Target == new_link$Target
    )

    if (!is_duplicate) {
      updated_links <- rbind(current_links, new_link)
      preventive_control_links(updated_links)

      notify_info("Control link added successfully!", duration = 2)

      # Reset selections
      updateSelectizeInput(session, "link_control", selected = character(0))
      updateSelectizeInput(session, "link_target", selected = character(0))
    } else {
      notify_warning("This link already exists!", duration = 2)
    }
  })

  # Observer for adding consequence-protective control connections
  observeEvent(input$add_protective_link, {
    req(input$link_consequence, input$link_protective_control)

    current_links <- consequence_protective_links()
    new_link <- data.frame(
      Consequence = input$link_consequence,
      Control = input$link_protective_control,
      stringsAsFactors = FALSE
    )

    # Check for duplicates
    is_duplicate <- nrow(current_links) > 0 && any(
      current_links$Consequence == new_link$Consequence &
      current_links$Control == new_link$Control
    )

    if (!is_duplicate) {
      updated_links <- rbind(current_links, new_link)
      consequence_protective_links(updated_links)

      notify_info("Protective control link added successfully!", duration = 2)

      # Reset selections
      updateSelectizeInput(session, "link_consequence", selected = character(0))
      updateSelectizeInput(session, "link_protective_control", selected = character(0))
    } else {
      notify_warning("This link already exists!", duration = 2)
    }
  })

  # =============================================================================
  # DYNAMIC CHOICE UPDATES - Update selectizeInput choices based on selections
  # =============================================================================

  # Update connection activity choices (Step 3)
  observe({
    activities <- selected_activities()
    if (length(activities) > 0) {
      updateSelectizeInput(session, "connection_activity", choices = activities)
    }
  })

  # Update connection pressure choices (Step 3)
  observe({
    pressures <- selected_pressures()
    if (length(pressures) > 0) {
      updateSelectizeInput(session, "connection_pressure", choices = pressures)
    }
  })

  # Update control link choices (Step 4)
  observe({
    controls <- selected_preventive_controls()
    if (length(controls) > 0) {
      updateSelectizeInput(session, "link_control", choices = controls)
    }

    # Update targets (activities + pressures)
    activities <- selected_activities()
    pressures <- selected_pressures()
    targets <- c()

    if (length(activities) > 0) {
      targets <- c(targets, setNames(paste0("Activity: ", activities), paste0("Activity: ", activities)))
    }
    if (length(pressures) > 0) {
      targets <- c(targets, setNames(paste0("Pressure: ", pressures), paste0("Pressure: ", pressures)))
    }

    if (length(targets) > 0) {
      updateSelectizeInput(session, "link_target", choices = targets)
    }
  })

  # Update consequence-protective control choices (Step 6)
  observe({
    consequences <- selected_consequences()
    if (length(consequences) > 0) {
      updateSelectizeInput(session, "link_consequence", choices = consequences)
    }

    protective_controls <- selected_protective_controls()
    if (length(protective_controls) > 0) {
      updateSelectizeInput(session, "link_protective_control", choices = protective_controls)
    }
  })

  # =============================================================================
  # STEP 8: REVIEW & SUMMARY
  # =============================================================================
  
  # Render review outputs for Step 8
  # All review renderers use project_data_debounced (300ms) to avoid rapid
  # re-renders when multiple state fields change in quick succession.
  # These outputs are only visible on Step 8, so a small delay is imperceptible.
  output$review_central_problem <- renderUI({
    pd <- project_data_debounced()
    problem <- pd$problem_statement %||% t("gw_not_defined", lang())
    tags$p(strong(problem))
  })

  output$review_activities_pressures <- renderUI({
    pd <- project_data_debounced()
    activities <- pd$activities %||% list()
    pressures <- pd$pressures %||% list()

    tagList(
      if (length(activities) > 0) {
        tags$div(
          tags$strong("Activities: "), tags$span(paste(length(activities), t("gw_items", lang()))),
          tags$ul(lapply(activities, function(x) tags$li(x)))
        )
      } else {
        tags$p(em(t("gw_no_activities", lang())))
      },
      if (length(pressures) > 0) {
        tags$div(
          tags$strong("Pressures: "), tags$span(paste(length(pressures), t("gw_items", lang()))),
          tags$ul(lapply(pressures, function(x) tags$li(x)))
        )
      } else {
        tags$p(em(t("gw_no_pressures", lang())))
      }
    )
  })

  output$review_preventive_controls <- renderUI({
    pd <- project_data_debounced()
    controls <- pd$preventive_controls %||% list()

    if (length(controls) > 0) {
      tags$div(
        tags$span(paste(length(controls), t("gw_controls", lang()))),
        tags$ul(lapply(controls, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_preventive_controls", lang())))
    }
  })

  output$review_consequences <- renderUI({
    pd <- project_data_debounced()
    consequences <- pd$consequences %||% list()

    if (length(consequences) > 0) {
      tags$div(
        tags$span(paste(length(consequences), "consequences")),
        tags$ul(lapply(consequences, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_consequences", lang())))
    }
  })

  output$review_protective_controls <- renderUI({
    pd <- project_data_debounced()
    controls <- pd$protective_controls %||% list()

    if (length(controls) > 0) {
      tags$div(
        tags$span(paste(length(controls), t("gw_controls", lang()))),
        tags$ul(lapply(controls, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_protective_controls", lang())))
    }
  })

  output$review_escalation_preventive <- renderUI({
    pd <- project_data_debounced()
    factors <- pd$escalation_factors %||% list()

    if (length(factors) > 0) {
      tags$div(
        tags$span(paste(length(factors), t("gw_factors", lang()))),
        tags$ul(lapply(factors, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_escalation", lang())))
    }
  })

  output$review_escalation_protective <- renderUI({
    pd <- project_data_debounced()
    factors <- pd$escalation_factors %||% list()

    if (length(factors) > 0) {
      tags$div(
        tags$span(paste(length(factors), "factors (same as preventive side)")),
        tags$ul(lapply(factors, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_escalation", lang())))
    }
  })

  output$assessment_statistics <- renderUI({
    pd <- project_data_debounced()

    activities_count <- length(pd$activities %||% list())
    pressures_count <- length(pd$pressures %||% list())
    preventive_count <- length(pd$preventive_controls %||% list())
    consequences_count <- length(pd$consequences %||% list())
    protective_count <- length(pd$protective_controls %||% list())
    escalation_count <- length(pd$escalation_factors %||% list())

    tags$div(
      tags$h6("Component Summary:"),
      tags$ul(
        tags$li(paste("Activities:", activities_count)),
        tags$li(paste("Pressures:", pressures_count)),
        tags$li(paste(t("gw_preventive_controls_label", lang()), preventive_count)),
        tags$li(paste(t("gw_consequences_label", lang()), consequences_count)),
        tags$li(paste(t("gw_protective_controls_label", lang()), protective_count)),
        tags$li(paste("Escalation Factors:", escalation_count))
      ),
      tags$hr(),
      tags$p(strong(t("gw_total_components", lang())),
             activities_count + pressures_count + preventive_count +
             consequences_count + protective_count + escalation_count)
    )
  })

  # =============================================================================
  # STEP 8: FINALIZE & EXPORT SECTION
  # =============================================================================

  # Render the finalize/export section based on workflow completion status
  # Uses narrowed workflow_complete_reactive to only re-render when completion status changes
  output$finalize_export_section <- renderUI({
    is_complete <- workflow_complete_reactive()

    if (!is_complete) {
      # Workflow NOT complete - show single Finalize button
      tagList(
        div(class = "card border-success",
            div(class = "card-header bg-success text-white",
                h5(icon("flag-checkered"), " ", t("gw_finalize_workflow", lang()), style = "margin: 0;")
            ),
            div(class = "card-body text-center",
                p(class = "mb-3",
                  t("gw_finalize_description", lang())
                ),
                actionButton(
                  session$ns("finalize_workflow_btn"),
                  label = tagList(icon("check-double"), " ", t("gw_finalize_workflow", lang())),
                  class = "btn btn-success btn-lg",
                  style = "font-size: 1.25rem; padding: 15px 40px;"
                ),
                div(class = "mt-3 text-muted",
                    tags$small(t("gw_finalize_note", lang()))
                )
            )
        )
      )
    } else {
      # Workflow IS complete - show export options
      tagList(
        div(class = "alert alert-success mb-4",
            icon("check-circle"), " ",
            strong(t("gw_workflow_complete_title", lang())),
            " - ", t("gw_export_ready", lang())
        ),

        div(class = "card border-primary",
            div(class = "card-header bg-primary text-white",
                h5(icon("download"), " ", t("gw_export_options", lang()), style = "margin: 0;")
            ),
            div(class = "card-body",
                fluidRow(
                  column(4,
                         div(class = "text-center p-3",
                             icon("file-excel", class = "fa-3x text-success mb-2"),
                             h6(t("gw_export_excel", lang())),
                             p(class = "text-muted small", t("gw_export_excel_desc", lang())),
                             actionButton(
                               session$ns("export_excel"),
                               label = tagList(icon("file-excel"), " ", t("gw_export_excel_btn", lang())),
                               class = "btn btn-success"
                             )
                         )
                  ),
                  column(4,
                         div(class = "text-center p-3",
                             icon("file-pdf", class = "fa-3x text-danger mb-2"),
                             h6(t("gw_export_pdf", lang())),
                             p(class = "text-muted small", t("gw_export_pdf_desc", lang())),
                             actionButton(
                               session$ns("export_pdf"),
                               label = tagList(icon("file-pdf"), " ", t("gw_generate_pdf", lang())),
                               class = "btn btn-danger"
                             )
                         )
                  ),
                  column(4,
                         div(class = "text-center p-3",
                             icon("diagram-project", class = "fa-3x text-info mb-2"),
                             h6(t("gw_view_diagram", lang())),
                             p(class = "text-muted small", t("gw_view_diagram_desc", lang())),
                             actionButton(
                               session$ns("load_to_main"),
                               label = tagList(icon("diagram-project"), " ", t("gw_view_diagram_btn", lang())),
                               class = "btn btn-info"
                             )
                         )
                  )
                )
            )
        )
      )
    }
  })

  # =============================================================================
  # TEMPLATE & DATA HANDLING
  # =============================================================================

  # Apply template data when selected
  observeEvent(input$problem_template, {
    req(input$problem_template)
    template_id <- input$problem_template

    if (template_id != "") {
      template_data <- WORKFLOW_CONFIG$templates[[template_id]]

      if (!is.null(template_data)) {
        # Update Step 1 (Project Setup) fields
        updateTextInput(session, "project_name", value = template_data$project_name)
        updateTextInput(session, "project_location", value = template_data$project_location)
        updateSelectInput(session, "project_type", selected = template_data$project_type)
        updateTextAreaInput(session, "project_description", value = template_data$project_description)

        # Update Step 2 (Central Problem Definition) fields
        updateTextInput(session, "problem_statement", value = template_data$central_problem)
        if (!is.null(template_data$problem_category)) {
          updateSelectInput(session, "problem_category", selected = template_data$problem_category)
        }
        if (!is.null(template_data$problem_details)) {
          updateTextAreaInput(session, "problem_details", value = template_data$problem_details)
        }
        if (!is.null(template_data$problem_scale)) {
          updateSelectInput(session, "problem_scale", selected = template_data$problem_scale)
        }
        if (!is.null(template_data$problem_urgency)) {
          updateSelectInput(session, "problem_urgency", selected = template_data$problem_urgency)
        }

        # Store template info in state
        state <- workflow_state()
        state$project_data$template_applied <- template_id
        state$project_data$project_name <- template_data$project_name
        state$project_data$project_location <- template_data$project_location
        state$project_data$project_type <- template_data$project_type
        state$project_data$project_description <- template_data$project_description
        state$project_data$problem_statement <- template_data$central_problem
        state$project_data$problem_category <- template_data$problem_category
        state$project_data$problem_details <- template_data$problem_details
        state$project_data$problem_scale <- template_data$problem_scale
        state$project_data$problem_urgency <- template_data$problem_urgency
        state$project_data$example_activities <- template_data$example_activities
        state$project_data$example_pressures <- template_data$example_pressures
        workflow_state(state)

        notify_success(paste0("✅ ", t("gw_applied_template", lang()), template_data$name,
                 " - Project Setup and Central Problem have been pre-filled!"), duration = 5)
      }
    }
  })

  # Populate Step 2 fields from template data when navigating to Step 2
  # Uses narrowed current_step_reactive to only fire on step changes
  observe({
    step_num <- current_step_reactive()
    req(step_num)

    # When user navigates to Step 2, populate fields from stored template data
    if (step_num == 2) {
      # Read full state only when we know we need it (isolate prevents dependency)
      state <- isolate(workflow_state())

      if (!is.null(state$project_data$template_applied)) {
        # Small delay to ensure Step 2 UI is fully rendered
        shinyjs::delay(100, {
          # Populate problem statement if available
          if (!is.null(state$project_data$problem_statement) && state$project_data$problem_statement != "") {
            updateTextInput(session, "problem_statement", value = state$project_data$problem_statement)
          }

          # Populate problem category if available
          if (!is.null(state$project_data$problem_category) && state$project_data$problem_category != "") {
            updateSelectInput(session, "problem_category", selected = state$project_data$problem_category)
          }

          # Populate problem details if available
          if (!is.null(state$project_data$problem_details) && state$project_data$problem_details != "") {
            updateTextAreaInput(session, "problem_details", value = state$project_data$problem_details)
          }

          # Populate problem scale if available
          if (!is.null(state$project_data$problem_scale) && state$project_data$problem_scale != "") {
            updateSelectInput(session, "problem_scale", selected = state$project_data$problem_scale)
          }

          # Populate problem urgency if available
          if (!is.null(state$project_data$problem_urgency) && state$project_data$problem_urgency != "") {
            updateSelectInput(session, "problem_urgency", selected = state$project_data$problem_urgency)
          }
        })
      }
    }
  })

  # =============================================================================
  # FINALIZATION & EXPORT
  # =============================================================================

  # Finalization status output
  # Uses narrowed workflow_complete_reactive to only re-render when completion changes
  output$finalization_status <- renderUI({
    is_complete <- workflow_complete_reactive()

    if (is_complete) {
      # Read converted data count only when complete (isolate to avoid extra dependency)
      scenario_count <- isolate({
        state <- workflow_state()
        if (!is.null(state$converted_main_data)) nrow(state$converted_main_data) else 0
      })
      div(class = "d-flex align-items-center",
        span(class = "badge bg-success fs-6 me-2",
             tagList(icon("check-circle"), " Finalized")),
        span(class = "text-success",
             paste("Ready to export -", scenario_count, "scenarios"))
      )
    } else {
      span(class = "text-muted fst-italic", "Not yet finalized")
    }
  })

  # Handle workflow finalization from Step 8 button
  observeEvent(input$finalize_workflow_btn, {
    state <- workflow_state()

    # Final validation
    validation_result <- validate_current_step(state, input)
    if (!validation_result$is_valid) {
      notify_error(validation_result$message)
      return()
    }

    # Save final step data
    state <- save_step_data(state, input)

    # Mark step 8 as complete
    if (!8 %in% state$completed_steps) {
      state$completed_steps <- c(state$completed_steps, 8)
    }

    # Update progress to 100%
    state$progress_percentage <- 100

    # Mark workflow as complete
    state$workflow_complete <- TRUE

    # Convert workflow data to main application format
    converted_data <- convert_to_main_data_format(state$project_data)
    state$converted_main_data <- converted_data

    log_success(paste("Workflow finalized! Data rows:", nrow(converted_data)))

    workflow_state(state)

    # Clear autosave - workflow is complete, no need to keep autosave
    session$sendCustomMessage("clearAutosave", list())

    notify_success("Workflow finalized successfully! You can now export or view the diagram.",
      duration = 5
    )
  })

  # Handle workflow finalization from navigation button (legacy)
  observeEvent(input$finalize_workflow, {
    state <- workflow_state()

    # Final validation
    validation_result <- validate_current_step(state, input)
    if (!validation_result$is_valid) {
      notify_error(validation_result$message)
      return()
    }

    # Save final step data
    state <- save_step_data(state, input)

    # Mark workflow as complete
    state$workflow_complete <- TRUE

    # Convert workflow data to main application format
    converted_data <- convert_to_main_data_format(state$project_data)
    state$converted_main_data <- converted_data

    workflow_state(state)

    # Clear autosave - workflow is complete, no need to keep autosave
    session$sendCustomMessage("clearAutosave", list())

    notify_success("Workflow finalized! You can now export or view the diagram.",
      duration = 5
    )
  })

  # =============================================================================
  # EXPORT HANDLERS FOR STEP 8
  # =============================================================================

  # Handler for Export to Excel
  observeEvent(input$export_excel, {
    state <- workflow_state()

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      notify_warning("Please complete the workflow first by clicking 'Complete Workflow'.", duration = 4)
      return()
    }

    tryCatch({
      # Get converted data
      converted_data <- state$converted_main_data

      if (is.null(converted_data) || nrow(converted_data) == 0) {
        # Try to convert now
        converted_data <- convert_to_main_data_format(state$project_data)
        state$converted_main_data <- converted_data
        workflow_state(state)
      }

      # Create filename with timestamp
      project_name <- state$project_data$project_name %||% "Bowtie"
      project_name <- gsub("[^A-Za-z0-9_-]", "_", project_name)  # Sanitize filename
      filename <- paste0(project_name, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx")

      # Create temporary file
      temp_file <- file.path(tempdir(), filename)

      # Export using the existing function from vocabulary_bowtie_generator.R
      # Note: This function should be sourced in global.R
      if (exists("export_bowtie_to_excel")) {
        export_bowtie_to_excel(converted_data, temp_file)

        # Trigger download
        notify_success(paste("✅ Excel file created:", filename), duration = 3)

        # Return file info for download handler (if downloadHandler is implemented)
        # For now, just notify where the file is saved
        notify_info(paste("File saved to:", temp_file), duration = 10)
      } else {
        # Fallback: use openxlsx directly
        library(openxlsx)
        wb <- createWorkbook()
        addWorksheet(wb, "Bowtie_Data")
        writeData(wb, "Bowtie_Data", converted_data)

        # Add summary sheet
        addWorksheet(wb, "Summary")
        summary_data <- data.frame(
          Metric = c("Project Name", "Central Problem", "Total Entries",
                     "Unique Activities", "Unique Consequences", "Export Date"),
          Value = c(
            state$project_data$project_name %||% "Unnamed",
            state$project_data$problem_statement %||% "Unnamed",
            nrow(converted_data),
            length(unique(converted_data$Activity)),
            length(unique(converted_data$Consequence)),
            as.character(Sys.time())
          ),
          stringsAsFactors = FALSE
        )
        writeData(wb, "Summary", summary_data)

        # Save workbook
        saveWorkbook(wb, temp_file, overwrite = TRUE)

        notify_success(paste("✅ Excel file exported:", filename), duration = 5)
      }

    }, error = function(e) {
      notify_error(paste("❌ Export failed:", e$message), duration = 5)
    })
  })

  # Handler for Generate PDF Report
  observeEvent(input$export_pdf, {
    state <- workflow_state()

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      notify_warning("Please complete the workflow first by clicking 'Complete Workflow'.", duration = 4)
      return()
    }

    tryCatch({
      # Create a simple PDF report using base graphics or ggplot2
      project_name <- state$project_data$project_name %||% "Bowtie_Report"
      project_name <- gsub("[^A-Za-z0-9_-]", "_", project_name)
      filename <- paste0(project_name, "_Report_", format(Sys.Date(), "%Y%m%d"), ".pdf")
      temp_file <- file.path(tempdir(), filename)

      # Create PDF with summary information
      pdf(temp_file, width = 11, height = 8.5)

      # Title page
      plot.new()
      text(0.5, 0.9, "Bowtie Risk Assessment Report", cex = 2.5, font = 2)
      text(0.5, 0.8, state$project_data$project_name %||% "Unnamed Project", cex = 2)
      text(0.5, 0.7, paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M")), cex = 1.2)

      # Summary statistics page
      plot.new()
      text(0.5, 0.95, "Assessment Summary", cex = 2, font = 2)

      y_pos <- 0.85
      line_height <- 0.06

      # Project info
      text(0.1, y_pos, "Central Problem:", pos = 4, cex = 1.3, font = 2)
      text(0.1, y_pos - line_height, state$project_data$problem_statement %||% "Not specified",
           pos = 4, cex = 1.1)
      y_pos <- y_pos - 3 * line_height

      # Activities
      activities <- state$project_data$activities %||% list()
      text(0.1, y_pos, paste("Human Activities (", length(activities), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(activities) > 0) {
        for(i in seq_along(activities)[1:min(10, length(activities))]) {
          text(0.15, y_pos - i * line_height, paste("-", activities[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(10, length(activities)) + 1.5) * line_height
      } else {
        y_pos <- y_pos - line_height
      }

      # Pressures
      pressures <- state$project_data$pressures %||% list()
      text(0.1, y_pos, paste("Environmental Pressures (", length(pressures), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(pressures) > 0) {
        for(i in seq_along(pressures)[1:min(8, length(pressures))]) {
          text(0.15, y_pos - i * line_height, paste("-", pressures[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(8, length(pressures)) + 1.5) * line_height
      }

      # Page 3: Controls and Consequences
      plot.new()
      text(0.5, 0.95, "Controls & Consequences", cex = 2, font = 2)

      y_pos <- 0.85

      # Preventive Controls
      prev_controls <- state$project_data$preventive_controls %||% list()
      text(0.1, y_pos, paste("Preventive Controls (", length(prev_controls), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(prev_controls) > 0) {
        for(i in seq_along(prev_controls)[1:min(8, length(prev_controls))]) {
          text(0.15, y_pos - i * line_height, paste("-", prev_controls[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(8, length(prev_controls)) + 1.5) * line_height
      } else {
        y_pos <- y_pos - line_height
      }

      # Consequences
      consequences <- state$project_data$consequences %||% list()
      text(0.1, y_pos, paste("Consequences (", length(consequences), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(consequences) > 0) {
        for(i in seq_along(consequences)[1:min(8, length(consequences))]) {
          text(0.15, y_pos - i * line_height, paste("-", consequences[i]), pos = 4, cex = 1)
        }
      }

      # Protective Controls
      prot_controls <- state$project_data$protective_controls %||% list()
      if (length(prot_controls) > 0 && y_pos > 0.3) {
        y_pos <- y_pos - (min(8, length(consequences)) + 2) * line_height
        text(0.1, y_pos, paste("Protective Controls (", length(prot_controls), "):"),
             pos = 4, cex = 1.3, font = 2)
        for(i in seq_along(prot_controls)[1:min(6, length(prot_controls))]) {
          text(0.15, y_pos - i * line_height, paste("-", prot_controls[i]), pos = 4, cex = 1)
        }
      }

      dev.off()

      notify_success(paste("✅ PDF report generated:", filename), duration = 5)

      notify_info(paste("File saved to:", temp_file), duration = 10)

    }, error = function(e) {
      notify_error(paste("❌ PDF generation failed:", e$message), duration = 5)
    })
  })

  # Handler for Load to Main Application (View Bowtie Diagram)
  observeEvent(input$load_to_main, {
    state <- workflow_state()

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      notify_warning("Please finalize the workflow first by clicking 'Finalize Workflow'.", duration = 4)
      return()
    }

    tryCatch({
      # Always regenerate converted data to ensure fresh state trigger
      log_info("Preparing bowtie data for main application...")
      converted_data <- convert_to_main_data_format(state$project_data)

      # Validate data
      if (is.null(converted_data) || !is.data.frame(converted_data) || nrow(converted_data) == 0) {
        notify_error("No data available to load. Please ensure your workflow has data.", duration = 5)
        return()
      }

      log_info(paste("Generated", nrow(converted_data), "bowtie scenarios"))
      log_debug(paste("Columns:", paste(names(converted_data), collapse = ", ")))

      # Success notification
      notify_info(paste("Loading", nrow(converted_data), "scenarios..."), duration = 2)

      # Update state with fresh data and trigger timestamp to force reactive update
      state$converted_main_data <- converted_data
      state$data_load_timestamp <- Sys.time()
      state$navigate_to_bowtie <- TRUE
      workflow_state(state)

      log_success("State updated with converted data")

      # Small delay to allow reactive to propagate, then navigate
      shinyjs::delay(500, {
        shinyjs::runjs("
          // Try multiple selectors for bs4Dash compatibility
          var bowtieLink = $('a[href=\"#shiny-tab-bowtie\"]');
          if (bowtieLink.length > 0) {
            bowtieLink.click();
          } else {
            bowtieLink = $('a[data-value=\"bowtie\"]');
            if (bowtieLink.length > 0) {
              bowtieLink.click();
            }
          }
          // Also ensure tab content is shown
          $('#shiny-tab-bowtie').addClass('active show');
          $('.tab-pane').not('#shiny-tab-bowtie').removeClass('active show');
        ")
      })

      # Show success message
      notify_info("Opening Bowtie Diagram...", duration = 3)

    }, error = function(e) {
      notify_error(paste("Failed to load data:", e$message), duration = 5)
    })
  })

  # =============================================================================
  # SAVE & LOAD FUNCTIONALITY
  # =============================================================================
  
  # Workflow help button - show help modal
  observeEvent(input$workflow_help, {
    showModal(modalDialog(
      title = tagList(icon("question-circle"), " Guided Workflow Help"),
      size = "l",
      easyClose = TRUE,
      tagList(
        h4("How to use the Guided Workflow"),
        tags$ol(
          tags$li(strong("Project Setup"), " - Enter basic project information and select an environmental scenario template"),
          tags$li(strong("Central Problem"), " - Define the core environmental problem to analyze"),
          tags$li(strong("Threats & Causes"), " - Select activities and pressures from the vocabulary"),
          tags$li(strong("Preventive Controls"), " - Choose mitigation measures"),
          tags$li(strong("Consequences"), " - Identify potential environmental impacts"),
          tags$li(strong("Protective Controls"), " - Add protective measures and recovery controls"),
          tags$li(strong("Review & Validate"), " - Check all connections and data completeness"),
          tags$li(strong("Finalize & Export"), " - Export your completed bowtie analysis")
        ),
        hr(),
        p(icon("lightbulb"), " Tip: Use the Save/Load buttons to preserve your progress between sessions.")
      ),
      footer = modalButton("Close")
    ))
  })

  # Trigger hidden file input for loading
  observeEvent(input$workflow_load_btn, {
    # Check if user has selected local folder storage mode
    storage_mode <- session$input$storage_mode
    local_path <- session$input$local_folder_path
    
    if (!is.null(storage_mode) && storage_mode == "local" && 
        !is.null(local_path) && nchar(local_path) > 0 && dir.exists(local_path)) {
      # Show modal to select from local files
      files <- list.files(local_path, pattern = "_workflow_.*\\.rds$", full.names = FALSE)
      
      if (length(files) == 0) {
        notify_warning("No workflow files found in local folder")
        # Fall back to file picker
        shinyjs::runjs("$('#guided_workflow-workflow_load_file_hidden').click();")
      } else {
        # Show file selection modal
        showModal(modalDialog(
          title = tagList(icon("folder-open"), " Load Workflow from Local Folder"),
          selectInput(ns("local_workflow_file"), 
                      "Select workflow file:",
                      choices = files,
                      selected = files[1]),
          footer = tagList(
            modalButton("Cancel"),
            actionButton(ns("load_local_workflow_confirm"), 
                        "Load", 
                        class = "btn-primary",
                        icon = icon("upload"))
          ),
          easyClose = TRUE
        ))
      }
    } else {
      # Use standard file picker
      shinyjs::runjs("$('#guided_workflow-workflow_load_file_hidden').click();")
    }
  })
  
  # Handle loading from local folder selection
  observeEvent(input$load_local_workflow_confirm, {
    local_path <- session$input$local_folder_path
    selected_file <- input$local_workflow_file
    
    if (!is.null(local_path) && !is.null(selected_file)) {
      filepath <- file.path(local_path, selected_file)
      
      tryCatch({
        loaded_state <- readRDS(filepath)
        removeModal()
        
        # Basic validation and load (same as regular file load)
        if (is.list(loaded_state) && "current_step" %in% names(loaded_state)) {
          workflow_state(loaded_state)
          notify_success(paste("✅ Loaded workflow from local folder:", selected_file))
        } else {
          notify_error("❌ Invalid workflow file.")
        }

      }, error = function(e) {
        removeModal()
        notify_error(paste("❌ Failed to load:", e$message))
      })
    }
  })
  
  # Handle file loading from file picker (supports JSON and legacy RDS)
  observeEvent(input$workflow_load_file_hidden, {
    file <- input$workflow_load_file_hidden
    req(file)

    tryCatch({
      # Detect file format and load accordingly
      if (grepl("\\.json$", file$name, ignore.case = TRUE)) {
        # Load JSON format (new default)
        json_content <- readLines(file$datapath, warn = FALSE)
        loaded_state <- jsonlite::fromJSON(paste(json_content, collapse = "\n"), simplifyVector = FALSE)
      } else {
        # Load RDS format (legacy support)
        loaded_state <- readRDS(file$datapath)
      }
      
      # Basic validation of loaded state
      if (is.list(loaded_state) && "current_step" %in% names(loaded_state)) {
        
        # Migrate old data structures if needed
        if (!is.null(loaded_state$project_data)) {
          # Ensure activities and pressures are character vectors, not data frames
          if (!is.null(loaded_state$project_data$activities)) {
            if (is.data.frame(loaded_state$project_data$activities)) {
              # Extract from old data frame format
              if (t("gw_col_activity", current_lang) %in% names(loaded_state$project_data$activities)) {
                loaded_state$project_data$activities <- loaded_state$project_data$activities$Activity
              } else if ("Actvity" %in% names(loaded_state$project_data$activities)) {
                # Fix old typo
                loaded_state$project_data$activities <- loaded_state$project_data$activities$Actvity
              }
            }
            # Convert to character vector
            loaded_state$project_data$activities <- as.character(loaded_state$project_data$activities)
          }
          
          if (!is.null(loaded_state$project_data$pressures)) {
            if (is.data.frame(loaded_state$project_data$pressures)) {
              # Extract from old data frame format
              if (t("gw_col_pressure", current_lang) %in% names(loaded_state$project_data$pressures)) {
                loaded_state$project_data$pressures <- loaded_state$project_data$pressures$Pressure
              }
            }
            # Convert to character vector
            loaded_state$project_data$pressures <- as.character(loaded_state$project_data$pressures)
          }
          
          # Ensure preventive controls are character vectors
          if (!is.null(loaded_state$project_data$preventive_controls)) {
            if (is.data.frame(loaded_state$project_data$preventive_controls)) {
              # Extract from old data frame format
              if (t("gw_col_control", current_lang) %in% names(loaded_state$project_data$preventive_controls)) {
                loaded_state$project_data$preventive_controls <- loaded_state$project_data$preventive_controls$Control
              }
            }
            # Convert to character vector
            loaded_state$project_data$preventive_controls <- as.character(loaded_state$project_data$preventive_controls)
          }
          
          # Ensure consequences are character vectors
          if (!is.null(loaded_state$project_data$consequences)) {
            if (is.data.frame(loaded_state$project_data$consequences)) {
              # Extract from old data frame format
              if (t("gw_col_consequence", current_lang) %in% names(loaded_state$project_data$consequences)) {
                loaded_state$project_data$consequences <- loaded_state$project_data$consequences$Consequence
              }
            }
            # Convert to character vector
            loaded_state$project_data$consequences <- as.character(loaded_state$project_data$consequences)
          }
          
          # Ensure protective controls are character vectors
          if (!is.null(loaded_state$project_data$protective_controls)) {
            if (is.data.frame(loaded_state$project_data$protective_controls)) {
              # Extract from old data frame format
              if (t("gw_col_control", current_lang) %in% names(loaded_state$project_data$protective_controls)) {
                loaded_state$project_data$protective_controls <- loaded_state$project_data$protective_controls$Control
              }
            }
            # Convert to character vector
            loaded_state$project_data$protective_controls <- as.character(loaded_state$project_data$protective_controls)
          }
          
          # Ensure escalation factors are character vectors
          if (!is.null(loaded_state$project_data$escalation_factors)) {
            if (is.data.frame(loaded_state$project_data$escalation_factors)) {
              # Extract from old data frame format
              if (t("gw_col_escalation", current_lang) %in% names(loaded_state$project_data$escalation_factors)) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors$`Escalation Factor`
              } else if ("escalation_factor" %in% names(loaded_state$project_data$escalation_factors)) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors$escalation_factor
              }
            }
            # Convert to character vector
            loaded_state$project_data$escalation_factors <- as.character(loaded_state$project_data$escalation_factors)
          }
        }
        
        workflow_state(loaded_state)
        
        # Update the reactive values based on current step
        if (loaded_state$current_step == 3) {
          if (!is.null(loaded_state$project_data$activities)) {
            selected_activities(loaded_state$project_data$activities)
          }
          if (!is.null(loaded_state$project_data$pressures)) {
            selected_pressures(loaded_state$project_data$pressures)
          }
        } else if (loaded_state$current_step == 4) {
          if (!is.null(loaded_state$project_data$activities)) {
            selected_activities(loaded_state$project_data$activities)
          }
          if (!is.null(loaded_state$project_data$pressures)) {
            selected_pressures(loaded_state$project_data$pressures)
          }
          if (!is.null(loaded_state$project_data$preventive_controls)) {
            selected_preventive_controls(loaded_state$project_data$preventive_controls)
          }
        } else if (loaded_state$current_step == 5) {
          if (!is.null(loaded_state$project_data$consequences)) {
            selected_consequences(loaded_state$project_data$consequences)
          }
        } else if (loaded_state$current_step == 6) {
          if (!is.null(loaded_state$project_data$consequences)) {
            selected_consequences(loaded_state$project_data$consequences)
          }
          if (!is.null(loaded_state$project_data$protective_controls)) {
            selected_protective_controls(loaded_state$project_data$protective_controls)
          }
        } else if (loaded_state$current_step == 7) {
          if (!is.null(loaded_state$project_data$escalation_factors)) {
            selected_escalation_factors(loaded_state$project_data$escalation_factors)
          }
        }
        
        notify_success("✅ Workflow progress loaded successfully!")
      } else {
        notify_error("❌ Invalid workflow file.")
      }
    }, error = function(e) {
      notify_error(paste(t("gw_error_loading", lang()), e$message))
    })
  })
  
  # Handle file download (saving) - Uses JSON format for browser compatibility
  output$workflow_download <- downloadHandler(
    filename = function() {
      project_name <- workflow_state()$project_data$project_name %||% "untitled"
      # Use .json extension - browsers recognize this as safe
      paste0(gsub(" ", "_", project_name), "_bowtie_", Sys.Date(), ".json")
    },
    content = function(file) {
      state_to_save <- workflow_state()
      state_to_save$last_saved <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      state_to_save$app_version <- APP_CONFIG$VERSION %||% "5.4.0"
      state_to_save$file_format <- "bowtie_workflow_v1"

      # Convert to JSON for browser-safe download
      json_content <- jsonlite::toJSON(state_to_save, auto_unbox = TRUE, pretty = TRUE)
      writeLines(json_content, file)

      # Check if local storage mode is selected - save backup copy
      storage_mode <- session$input$storage_mode
      local_path <- session$input$local_folder_path

      # Additionally save to local folder if that mode is selected
      if (!is.null(storage_mode) && storage_mode == "local" &&
          !is.null(local_path) && nchar(local_path) > 0 && dir.exists(local_path)) {
        tryCatch({
          project_name <- state_to_save$project_data$project_name %||% "untitled"
          local_filename <- paste0(gsub(" ", "_", project_name), "_bowtie_", Sys.Date(), ".json")
          local_filepath <- file.path(local_path, local_filename)
          writeLines(json_content, local_filepath)

          notify_info(paste("Also saved to local folder:", local_filename), duration = 3)
        }, error = function(e) {
          notify_warning(paste("Could not save to local folder:", e$message))
        })
      }

      notify_success("Workflow saved successfully!", duration = 3)
    },
    contentType = "application/json"  # JSON MIME type - browsers trust this
  )
  
  # =============================================================================
  # RETURN VALUE
  # =============================================================================
  
  # Return the reactive workflow state
  return(workflow_state)
  
  })  # End of moduleServer
}  # End of guided_workflow_server

# =============================================================================
# UTILITY FUNCTIONS - MOVED TO MODULES
# =============================================================================
# NOTE: The following functions have been moved to separate modules:
#
# guided_workflow_validation.R:
#   - %||% operator
#   - estimate_remaining_time()
#   - validate_step(), validate_current_step()
#   - validate_step1() through validate_step8()
#   - save_step_data()
#
# guided_workflow_conversion.R:
#   - convert_to_main_data_format()
#   - create_guided_workflow_tab()
#
# These modules are loaded via source() at the top of this file.
# =============================================================================

log_success("Guided Workflow System Ready!")
log_debug("Available functions: guided_workflow_ui(), guided_workflow_server(), create_guided_workflow_tab(), init_workflow_state()")
