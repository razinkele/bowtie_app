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

# Step UI generators, progress tracker, sidebar (extracted to guided_workflow_ui.R)
source("guided_workflow_ui.R")

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
  # SMART AUTOSAVE SYSTEM (extracted to guided_workflow_autosave.R)
  # =============================================================================
  source("guided_workflow_autosave.R", local = TRUE)
  autosave_result <- init_workflow_autosave(input, output, session, workflow_state)
  last_saved_hash <- autosave_result$last_saved_hash
  autosave_enabled <- autosave_result$autosave_enabled
  compute_state_hash <- autosave_result$compute_state_hash

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
  # FINALIZATION & EXPORT (extracted to guided_workflow_export.R)
  # =============================================================================
  source("guided_workflow_export.R", local = TRUE)
  init_workflow_export(input, output, session, workflow_state,
                       workflow_complete_reactive, lang,
                       selected_activities, selected_pressures,
                       selected_preventive_controls, selected_consequences,
                       selected_protective_controls, selected_escalation_factors)

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
