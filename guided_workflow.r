# =============================================================================
# Guided Workflow System - Step-by-Step Bowtie Creation
# Version: 5.1.0
# Date: September 2025
# Description: Comprehensive wizard-based system for guided bowtie diagram creation
#              with progress tracking, validation, and expert guidance
# =============================================================================

library(shiny)
library(bslib)
library(dplyr)
library(DT)

cat("🧙 GUIDED WORKFLOW SYSTEM v1.1.0\n")
cat("=================================\n")
cat("Step-by-step bowtie creation with expert guidance\n\n")

# =============================================================================
# WORKFLOW CONFIGURATION
# =============================================================================

WORKFLOW_CONFIG <- list(
  steps = list(
    step1 = list(
      id = "project_setup",
      title = "📋 Project Setup",
      description = "Define your environmental risk assessment project",
      icon = "clipboard-list",
      estimated_time = "2-3 minutes"
    ),
    step2 = list(
      id = "central_problem",
      title = "🎯 Central Problem Definition",
      description = "Identify the core environmental issue to analyze",
      icon = "target",
      estimated_time = "3-5 minutes"
    ),
    step3 = list(
      id = "threats_causes",
      title = "⚠️ Threats & Causes",
      description = "Map activities and pressures leading to the problem",
      icon = "exclamation-triangle",
      estimated_time = "5-10 minutes"
    ),
    step4 = list(
      id = "preventive_controls",
      title = "🛡️ Preventive Controls",
      description = "Define measures to prevent or reduce threats",
      icon = "shield-alt",
      estimated_time = "5-8 minutes"
    ),
    step5 = list(
      id = "consequences",
      title = "💥 Consequences",
      description = "Identify potential environmental impacts",
      icon = "radiation",
      estimated_time = "3-5 minutes"
    ),
    step6 = list(
      id = "protective_controls",
      title = "🚨 Protective Controls",
      description = "Define measures to mitigate consequences",
      icon = "life-ring",
      estimated_time = "5-8 minutes"
    ),
    step7 = list(
      id = "review_validate",
      title = "✅ Review & Validate",
      description = "Review complete bowtie and validate connections",
      icon = "check-circle",
      estimated_time = "3-5 minutes"
    ),
    step8 = list(
      id = "finalize_export",
      title = "🎉 Finalize & Export",
      description = "Complete your bowtie and generate reports",
      icon = "download",
      estimated_time = "2-3 minutes"
    )
  ),
  templates = list(
    marine_pollution = list(
      name = "Marine Pollution Assessment",
      central_problem = "Marine ecosystem contamination",
      example_activities = c("Industrial discharge", "Shipping operations", "Urban runoff"),
      example_pressures = c("Chemical contamination", "Oil spills", "Nutrient loading"),
      category = "Marine Environment"
    ),
    climate_impact = list(
      name = "Climate Change Impact",
      central_problem = "Ecosystem disruption from climate change", 
      example_activities = c("Greenhouse gas emissions", "Land use change", "Energy production"),
      example_pressures = c("Temperature increase", "Sea level rise", "Extreme weather"),
      category = "Climate & Weather"
    ),
    biodiversity_loss = list(
      name = "Biodiversity Loss Assessment",
      central_problem = "Species population decline",
      example_activities = c("Habitat destruction", "Invasive species", "Overexploitation"),
      example_pressures = c("Habitat fragmentation", "Species competition", "Overharvesting"),
      category = "Biodiversity"
    )
  )
)

# =============================================================================
# WORKFLOW STATE MANAGEMENT
# =============================================================================

# Initialize workflow state
init_workflow_state <- function() {
  list(
    current_step = 1,
    total_steps = length(WORKFLOW_CONFIG$steps),
    completed_steps = numeric(0),
    project_data = list(),
    validation_status = list(),
    progress_percentage = 0,
    start_time = Sys.time(),
    step_times = list()
  )
}

# Update workflow progress
update_workflow_progress <- function(state, step_number = NULL, data = NULL) {
  if (!is.null(step_number)) {
    state$current_step <- step_number
    if (!step_number %in% state$completed_steps && step_number < state$current_step) {
      state$completed_steps <- c(state$completed_steps, step_number)
    }
  }
  
  if (!is.null(data)) {
    state$project_data <- append(state$project_data, data)
  }
  
  # Update progress percentage
  state$progress_percentage <- (length(state$completed_steps) / state$total_steps) * 100
  
  return(state)
}

# =============================================================================
# UI COMPONENTS
# =============================================================================

# Main guided workflow UI
guided_workflow_ui <- function() {
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
      "))
    ),
    
    # Workflow header
    div(class = "workflow-header",
        fluidRow(
          column(8,
                 h2("🧙 Guided Bowtie Creation Wizard", style = "margin: 0;"),
                 p("Step-by-step environmental risk assessment with expert guidance", style = "margin: 5px 0 0 0;")
          ),
          column(4,
                 div(class = "text-end",
                     actionButton("workflow_help", "❓ Help", class = "btn-light btn-sm me-2"),
                     actionButton("workflow_load", "📂 Load Progress", class = "btn-light btn-sm me-2"),
                     actionButton("workflow_save", "💾 Save Progress", class = "btn-light btn-sm")
                 )
          )
        )
    ),
    
    # Progress tracker
    fluidRow(
      column(12,
             div(class = "progress-tracker",
                 uiOutput("workflow_progress_ui")
             )
      )
    ),
    
    # Main workflow content
    fluidRow(
      column(3,
             # Step navigation sidebar
             div(class = "card",
                 div(class = "card-header", h5("📋 Workflow Steps")),
                 div(class = "card-body",
                     uiOutput("workflow_steps_sidebar")
                 )
             )
      ),
      column(9,
             # Current step content
             div(class = "card",
                 div(class = "card-header",
                     uiOutput("current_step_header")
                 ),
                 div(class = "card-body",
                     uiOutput("current_step_content")
                 ),
                 div(class = "card-footer",
                     uiOutput("workflow_navigation")
                 )
             )
      )
    )
  )
}

# Progress tracker UI
workflow_progress_ui <- function(state) {
  progress_percentage <- state$progress_percentage
  current_step <- state$current_step
  total_steps <- state$total_steps
  
  tagList(
    fluidRow(
      column(8,
             div(
               h5(paste("Step", current_step, "of", total_steps, "•", 
                       names(WORKFLOW_CONFIG$steps)[current_step])),
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
                 h6(paste("Completed:", length(state$completed_steps), "/", total_steps)),
                 if (length(state$completed_steps) > 0) {
                   tags$small(paste("Estimated time remaining:", 
                              estimate_remaining_time(state), "minutes"))
                 } else {
                   tags$small("Estimated total time: 25-35 minutes")
                 }
             )
      )
    )
  )
}

# Steps sidebar UI
workflow_steps_sidebar_ui <- function(state) {
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
    
    icon_html <- if (i %in% completed_steps) {
      "✅"
    } else if (i == current_step) {
      "👉"
    } else {
      "⏳"
    }
    
    div(class = paste("list-group-item", status_class),
        onclick = paste0("Shiny.setInputValue('goto_step', ", i, ")"),
        style = "cursor: pointer;",
        div(
          span(icon_html, style = "margin-right: 8px;"),
          strong(step$title),
          br(),
          tags$small(step$description)
        )
    )
  })
  
  div(class = "list-group", step_items)
}

# =============================================================================
# STEP CONTENT GENERATORS
# =============================================================================

# Step 1: Project Setup
generate_step1_ui <- function() {
  tagList(
    fluidRow(
      column(6,
             h4("🎯 Project Information"),
             textInput("project_name", "Project Name:", 
                      placeholder = "e.g., Marine Plastic Pollution Assessment"),
             textInput("project_location", "Location/Region:", 
                      placeholder = "e.g., Mediterranean Sea, Baltic Region"),
             selectInput("project_type", "Assessment Type:",
                        choices = c(
                          "Marine Environment" = "marine",
                          "Terrestrial Ecosystem" = "terrestrial", 
                          "Freshwater System" = "freshwater",
                          "Urban Environment" = "urban",
                          "Climate Impact" = "climate",
                          "Custom Assessment" = "custom"
                        )),
             textAreaInput("project_description", "Project Description:",
                          placeholder = "Brief description of the environmental risk assessment...",
                          rows = 3)
      ),
      column(6,
             h4("📝 Template Selection"),
             p("Choose a template to get started quickly with pre-filled examples:"),
             uiOutput("template_selector"),
             br(),
             div(class = "alert alert-info",
                 h6("💡 Expert Tip:"),
                 p("Templates provide structured starting points based on common environmental risk scenarios. You can customize all content after selection.")
             )
      )
    )
  )
}

# Step 2: Central Problem Definition  
generate_step2_ui <- function() {
  tagList(
    div(class = "alert alert-primary",
        h5("🎯 Define Your Central Problem"),
        p("The central problem is the core environmental issue you're assessing. It sits at the center of your bowtie diagram and connects threats (left side) to consequences (right side).")
    ),
    
    fluidRow(
      column(8,
             h4("Central Environmental Problem"),
             textInput("central_problem", "Problem Statement:",
                      placeholder = "e.g., Marine ecosystem contamination from plastic pollution"),
             
             selectInput("problem_category", "Problem Category:",
                        choices = c(
                          "Pollution & Contamination" = "pollution",
                          "Habitat Loss & Degradation" = "habitat_loss",
                          "Species Decline & Extinction" = "species_decline",
                          "Climate & Weather Impacts" = "climate_impacts",
                          "Resource Depletion" = "resource_depletion",
                          "Ecosystem Services Loss" = "ecosystem_services",
                          "Other" = "other"
                        )),
             
             textAreaInput("problem_details", "Detailed Description:",
                          placeholder = "Provide more context about this environmental problem...",
                          rows = 4),
             
             selectInput("problem_scale", "Spatial Scale:",
                        choices = c(
                          "Local (< 10 km)" = "local",
                          "Regional (10-100 km)" = "regional", 
                          "National (country-wide)" = "national",
                          "International (multi-country)" = "international",
                          "Global" = "global"
                        )),
             
             selectInput("problem_urgency", "Urgency Level:",
                        choices = c(
                          "Critical (immediate action needed)" = "critical",
                          "High (action needed within months)" = "high",
                          "Medium (action needed within 1-2 years)" = "medium", 
                          "Low (long-term planning)" = "low"
                        ))
      ),
      column(4,
             h4("🔍 Problem Examples"),
             div(class = "card",
                 div(class = "card-body",
                     h6("Marine Examples:"),
                     tags$ul(
                       tags$li("Ocean acidification"),
                       tags$li("Coral reef bleaching"),
                       tags$li("Marine plastic pollution"),
                       tags$li("Overfishing impacts")
                     ),
                     h6("Terrestrial Examples:"),
                     tags$ul(
                       tags$li("Deforestation"),
                       tags$li("Soil degradation"),
                       tags$li("Biodiversity loss"),
                       tags$li("Invasive species spread")
                     )
                 )
             ),
             br(),
             div(class = "alert alert-warning",
                 h6("⚠️ Important:"),
                 p("Keep your central problem focused and specific. Avoid combining multiple issues - create separate bowtie diagrams for different problems.")
             )
      )
    )
  )
}

# Step 3: Threats & Causes
generate_step3_ui <- function(vocabulary_data = NULL) {
  tagList(
    div(class = "alert alert-danger",
        h5("⚠️ Map Threats Leading to Your Problem"),
        p("Identify the activities (human actions) and pressures (environmental stressors) that can lead to your central problem.")
    ),
    
    fluidRow(
      column(6,
             h4("👥 Human Activities"),
             p("What human activities contribute to this problem?"),
             
             fluidRow(
               column(8, {
                 # Prepare activity choices from vocabulary data
                 activity_choices <- NULL
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities) && nrow(vocabulary_data$activities) > 0) {
                   activity_choices <- setNames(vocabulary_data$activities$name, vocabulary_data$activities$name)
                 }

                 selectizeInput("activity_search", "Search Activities:",
                              choices = if (is.null(activity_choices)) character(0) else activity_choices,
                              selected = character(0),
                              options = list(
                                placeholder = "Type to search activities...",
                                create = TRUE,
                                maxOptions = 1000,
                                openOnFocus = FALSE,
                                selectOnTab = FALSE,
                                hideSelected = FALSE
                              ))
               }),
               column(4,
                      br(),
                      actionButton("add_activity", "➕ Add Activity", 
                                 class = "btn-success btn-sm")
               )
             ),
             
             h5("Selected Activities:"),
             DTOutput("selected_activities_table"),
             
             br(),
             div(class = "alert alert-info",
                 h6("💡 Examples:"),
                 p("Industrial discharge, Urban development, Agricultural practices, Transportation, Tourism activities")
             )
      ),
      
      column(6,
             h4("🌊 Environmental Pressures"),
             p("What environmental pressures result from these activities?"),
             
             fluidRow(
               column(8, {
                 # Prepare pressure choices from vocabulary data
                 pressure_choices <- NULL
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures) && nrow(vocabulary_data$pressures) > 0) {
                   pressure_choices <- setNames(vocabulary_data$pressures$name, vocabulary_data$pressures$name)
                 }

                 selectizeInput("pressure_search", "Search Pressures:",
                              choices = if (is.null(pressure_choices)) character(0) else pressure_choices,
                              selected = character(0),
                              options = list(
                                placeholder = "Type to search pressures...",
                                create = TRUE,
                                maxOptions = 1000,
                                openOnFocus = FALSE,
                                selectOnTab = FALSE,
                                hideSelected = FALSE
                              ))
               }),
               column(4,
                      br(),
                      actionButton("add_pressure", "➕ Add Pressure",
                                 class = "btn-warning btn-sm")
               )
             ),
             
             h5("Selected Pressures:"),
             DTOutput("selected_pressures_table"),
             
             br(),
             div(class = "alert alert-info",
                 h6("💡 Examples:"),
                 p("Chemical contamination, Habitat destruction, Noise pollution, Physical disturbance, Temperature changes")
             )
      )
    ),
    
    br(),
    h4("🔗 Activity-Pressure Connections"),
    p("Link activities to the pressures they create:"),
    DTOutput("activity_pressure_connections")
  )
}

# =============================================================================
# SERVER FUNCTIONS
# =============================================================================

# Main guided workflow server
guided_workflow_server <- function(input, output, session, vocabulary_data = NULL) {
  
  # Initialize workflow state
  workflow_state <- reactiveVal(init_workflow_state())
  
  # Render progress UI
  output$workflow_progress_ui <- renderUI({
    workflow_progress_ui(workflow_state())
  })
  
  # Render steps sidebar
  output$workflow_steps_sidebar <- renderUI({
    workflow_steps_sidebar_ui(workflow_state())
  })
  
  # Handle step navigation
  observeEvent(input$goto_step, {
    state <- workflow_state()
    state$current_step <- input$goto_step
    workflow_state(state)
  })
  
  # Render current step header
  output$current_step_header <- renderUI({
    current_step <- workflow_state()$current_step
    step_info <- WORKFLOW_CONFIG$steps[[current_step]]
    
    fluidRow(
      column(8,
             h4(step_info$title),
             p(step_info$description)
      ),
      column(4,
             div(class = "text-end",
                 span(class = "badge bg-primary", paste("Step", current_step)),
                 span(class = "badge bg-info ms-2", step_info$estimated_time)
             )
      )
    )
  })
  
  # Render current step content
  output$current_step_content <- renderUI({
    current_step <- workflow_state()$current_step

    switch(current_step,
           "1" = generate_step1_ui(),
           "2" = generate_step2_ui(),
           "3" = generate_step3_ui(vocabulary_data),
           "4" = generate_step4_ui(vocabulary_data),
           "5" = generate_step5_ui(vocabulary_data),
           "6" = generate_step6_ui(vocabulary_data),
           "7" = generate_step7_ui(),
           "8" = generate_step8_ui()
    )
  })
  
  # Render workflow navigation
  output$workflow_navigation <- renderUI({
    current_step <- workflow_state()$current_step
    total_steps <- workflow_state()$total_steps
    
    fluidRow(
      column(6,
             if (current_step > 1) {
               actionButton("prev_step", "← Previous Step", 
                          class = "btn-secondary")
             }
      ),
      column(6,
             div(class = "text-end",
                 if (current_step < total_steps) {
                   actionButton("next_step", "Next Step →",
                              class = "btn-primary")
                 } else {
                   actionButton("complete_workflow", "🎉 Complete Workflow",
                              class = "btn-success")
                 }
             )
      )
    )
  })
  
  # Handle navigation buttons
  observeEvent(input$next_step, {
    state <- workflow_state()
    if (state$current_step < state$total_steps) {
      state$current_step <- state$current_step + 1
      state$completed_steps <- unique(c(state$completed_steps, state$current_step - 1))
      workflow_state(update_workflow_progress(state))
    }
  })
  
  observeEvent(input$prev_step, {
    state <- workflow_state()
    if (state$current_step > 1) {
      state$current_step <- state$current_step - 1
      workflow_state(state)
    }
  })

  # Reactive values to store selected activities and pressures
  selected_items <- reactiveValues(
    activities = data.frame(name = character(), stringsAsFactors = FALSE),
    pressures = data.frame(name = character(), stringsAsFactors = FALSE),
    controls = data.frame(name = character(), stringsAsFactors = FALSE),
    consequences = data.frame(name = character(), stringsAsFactors = FALSE),
    protective_controls = data.frame(name = character(), stringsAsFactors = FALSE)
  )

  # Handle Add Activity button
  observeEvent(input$add_activity, {
    activity_name <- input$activity_search
    if (!is.null(activity_name) && activity_name != "" && !activity_name %in% selected_items$activities$name) {
      new_activity <- data.frame(name = activity_name, stringsAsFactors = FALSE)
      selected_items$activities <- rbind(selected_items$activities, new_activity)

      # Clear the search box
      updateSelectizeInput(session, "activity_search", selected = "")

      cat("✅ Added activity:", activity_name, "\n")
    }
  })

  # Handle Add Pressure button
  observeEvent(input$add_pressure, {
    pressure_name <- input$pressure_search
    if (!is.null(pressure_name) && pressure_name != "" && !pressure_name %in% selected_items$pressures$name) {
      new_pressure <- data.frame(name = pressure_name, stringsAsFactors = FALSE)
      selected_items$pressures <- rbind(selected_items$pressures, new_pressure)

      # Clear the search box
      updateSelectizeInput(session, "pressure_search", selected = "")

      cat("✅ Added pressure:", pressure_name, "\n")
    }
  })

  # Handle Add Preventive Control button
  observeEvent(input$add_preventive_control, {
    control_name <- input$control_search
    if (!is.null(control_name) && control_name != "" && !control_name %in% selected_items$controls$name) {
      new_control <- data.frame(name = control_name, stringsAsFactors = FALSE)
      selected_items$controls <- rbind(selected_items$controls, new_control)

      # Clear the search box
      updateSelectizeInput(session, "control_search", selected = "")

      cat("✅ Added preventive control:", control_name, "\n")
    }
  })

  # Handle Add Consequence button
  observeEvent(input$add_consequence, {
    consequence_name <- input$consequence_search
    if (!is.null(consequence_name) && consequence_name != "" && !consequence_name %in% selected_items$consequences$name) {
      new_consequence <- data.frame(name = consequence_name, stringsAsFactors = FALSE)
      selected_items$consequences <- rbind(selected_items$consequences, new_consequence)

      # Clear the search box
      updateSelectizeInput(session, "consequence_search", selected = "")

      cat("✅ Added consequence:", consequence_name, "\n")
    }
  })

  # Handle Add Protective Control button
  observeEvent(input$add_protective_control, {
    protective_name <- input$protective_search
    if (!is.null(protective_name) && protective_name != "" && !protective_name %in% selected_items$protective_controls$name) {
      new_protective <- data.frame(name = protective_name, stringsAsFactors = FALSE)
      selected_items$protective_controls <- rbind(selected_items$protective_controls, new_protective)
      # Clear the search box
      updateSelectizeInput(session, "protective_search", selected = "")
      cat("✅ Added protective control:", protective_name, "\n")
    }
  })

  # Render selected activities table
  output$selected_activities_table <- DT::renderDataTable({
    if (nrow(selected_items$activities) == 0) {
      data.frame("No activities selected yet" = character(0))
    } else {
      selected_items$activities
    }
  }, options = list(
    pageLength = 5,
    searching = FALSE,
    info = FALSE,
    paging = FALSE
  ), rownames = FALSE)

  # Render selected pressures table
  output$selected_pressures_table <- DT::renderDataTable({
    if (nrow(selected_items$pressures) == 0) {
      data.frame("No pressures selected yet" = character(0))
    } else {
      selected_items$pressures
    }
  }, options = list(
    pageLength = 5,
    searching = FALSE,
    info = FALSE,
    paging = FALSE
  ), rownames = FALSE)

  # Render selected preventive controls table
  output$preventive_controls_table <- DT::renderDataTable({
    if (nrow(selected_items$controls) == 0) {
      data.frame("No preventive controls selected yet" = character(0))
    } else {
      selected_items$controls
    }
  }, options = list(
    pageLength = 5,
    searching = FALSE,
    info = FALSE,
    paging = FALSE
  ), rownames = FALSE)

  # Render selected consequences table
  output$consequences_table <- DT::renderDataTable({
    if (nrow(selected_items$consequences) == 0) {
      data.frame("No consequences selected yet" = character(0))
    } else {
      selected_items$consequences
    }
  }, options = list(
    pageLength = 5,
    searching = FALSE,
    info = FALSE,
    paging = FALSE
  ), rownames = FALSE)

  # Render selected protective controls table
  output$protective_controls_table <- DT::renderDataTable({
    if (nrow(selected_items$protective_controls) == 0) {
      data.frame("No protective controls selected yet" = character(0))
    } else {
      selected_items$protective_controls
    }
  }, options = list(
    pageLength = 5,
    searching = FALSE,
    info = FALSE,
    paging = FALSE
  ), rownames = FALSE)

  # Render activity-pressure connections table
  output$activity_pressure_connections <- DT::renderDataTable({
    if (nrow(selected_items$activities) == 0 || nrow(selected_items$pressures) == 0) {
      data.frame("Message" = "Add activities and pressures first to see their potential connections")
    } else {
      # Create a simple cross-reference table showing all activity-pressure combinations
      connections <- expand.grid(
        Activity = selected_items$activities$name,
        Pressure = selected_items$pressures$name,
        stringsAsFactors = FALSE
      )
      connections$Connection <- "Possible Link"  # In a full implementation, this could be user-defined
      connections
    }
  }, options = list(
    pageLength = 10,
    searching = TRUE,
    info = TRUE,
    paging = TRUE
  ), rownames = FALSE)

  # Save progress handler
  observeEvent(input$workflow_save, {
    tryCatch({
      # Create a comprehensive save object
      save_data <- list(
        timestamp = Sys.time(),
        current_step = workflow_state$current_step,
        completed_steps = workflow_state$completed_steps,
        selected_items = reactiveValuesToList(selected_items),
        inputs = list(
          project_name = input$project_name %||% "",
          project_description = input$project_description %||% "",
          analysis_scope = input$analysis_scope %||% "",
          problem_statement = input$problem_statement %||% ""
        )
      )

      # Save to file with timestamp
      filename <- paste0("workflow_progress_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds")
      saveRDS(save_data, file = filename)

      # Show success message
      showNotification(
        paste("Progress saved successfully to", filename),
        type = "success",
        duration = 3
      )
      cat("✅ Progress saved to:", filename, "\n")

    }, error = function(e) {
      showNotification(
        paste("Error saving progress:", e$message),
        type = "error",
        duration = 5
      )
      cat("❌ Error saving progress:", e$message, "\n")
    })
  })

  # Load progress handler
  observeEvent(input$workflow_load, {
    tryCatch({
      # Get list of available save files
      save_files <- list.files(pattern = "^workflow_progress_.*\\.rds$", full.names = TRUE)

      if (length(save_files) == 0) {
        showNotification(
          "No saved progress files found",
          type = "warning",
          duration = 3
        )
        return()
      }

      # Get the most recent save file
      latest_file <- save_files[which.max(file.mtime(save_files))]
      load_data <- readRDS(latest_file)

      # Restore workflow state
      workflow_state$current_step <- load_data$current_step
      workflow_state$completed_steps <- load_data$completed_steps

      # Restore selected items
      selected_items$activities <- load_data$selected_items$activities %||% data.frame(name = character(), stringsAsFactors = FALSE)
      selected_items$pressures <- load_data$selected_items$pressures %||% data.frame(name = character(), stringsAsFactors = FALSE)
      selected_items$controls <- load_data$selected_items$controls %||% data.frame(name = character(), stringsAsFactors = FALSE)
      selected_items$consequences <- load_data$selected_items$consequences %||% data.frame(name = character(), stringsAsFactors = FALSE)
      selected_items$protective_controls <- load_data$selected_items$protective_controls %||% data.frame(name = character(), stringsAsFactors = FALSE)

      # Restore input fields
      if (!is.null(load_data$inputs)) {
        updateTextInput(session, "project_name", value = load_data$inputs$project_name %||% "")
        updateTextAreaInput(session, "project_description", value = load_data$inputs$project_description %||% "")
        updateTextInput(session, "analysis_scope", value = load_data$inputs$analysis_scope %||% "")
        updateTextAreaInput(session, "problem_statement", value = load_data$inputs$problem_statement %||% "")
      }

      # Show success message
      showNotification(
        paste("Progress loaded from", basename(latest_file),
              "- saved on", format(load_data$timestamp, "%Y-%m-%d %H:%M:%S")),
        type = "success",
        duration = 4
      )
      cat("✅ Progress loaded from:", latest_file, "\n")

    }, error = function(e) {
      showNotification(
        paste("Error loading progress:", e$message),
        type = "error",
        duration = 5
      )
      cat("❌ Error loading progress:", e$message, "\n")
    })
  })

  # Return workflow state for integration
  return(workflow_state)
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Estimate remaining time based on progress
estimate_remaining_time <- function(state) {
  step_durations <- c(2.5, 4, 7.5, 6.5, 4, 6.5, 4, 2.5)  # Average minutes per step
  remaining_steps <- setdiff(1:state$total_steps, state$completed_steps)
  sum(step_durations[remaining_steps])
}

# Validate step completion
validate_step <- function(step_number, data) {
  switch(step_number,
         "1" = validate_step1(data),
         "2" = validate_step2(data),
         "3" = validate_step3(data),
         "4" = validate_step4(data),
         "5" = validate_step5(data),
         "6" = validate_step6(data),
         "7" = validate_step7(data),
         "8" = validate_step8(data)
  )
}

# Step validation functions (to be implemented)
validate_step1 <- function(data) {
  list(valid = !is.null(data$project_name) && nchar(data$project_name) > 0,
       message = "Project name is required")
}

validate_step2 <- function(data) {
  list(valid = !is.null(data$central_problem) && nchar(data$central_problem) > 0,
       message = "Central problem definition is required")
}

# Integration helper - create guided workflow tab
create_guided_workflow_tab <- function() {
  nav_panel(
    title = "🧙 Guided Creation",
    icon = icon("magic-wand"),
    guided_workflow_ui()
  )
}

cat("✅ Guided Workflow System Ready!\n")
cat("📋 Available functions:\n")
cat("   - guided_workflow_ui(): Main workflow UI\n")
cat("   - guided_workflow_server(): Server logic\n")
cat("   - create_guided_workflow_tab(): Integration helper\n")
cat("   - init_workflow_state(): Initialize workflow\n")
cat("\n🎯 Add to your app with create_guided_workflow_tab()!\n")