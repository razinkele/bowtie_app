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
    step_times = list(),
    # Missing properties for integration
    project_name = "",
    central_problem = ""
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
             textInput("problem_statement", "Problem Statement:",
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
                              choices = character(0),  # Start with empty choices
                              selected = NULL,
                              options = list(
                                placeholder = "Type to search activities...",
                                create = TRUE,
                                maxOptions = 1000,
                                openOnFocus = FALSE,
                                selectOnTab = FALSE,
                                hideSelected = FALSE,
                                clearAfterSelect = TRUE
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
                              choices = character(0),  # Start with empty choices
                              selected = NULL,
                              options = list(
                                placeholder = "Type to search pressures...",
                                create = TRUE,
                                maxOptions = 1000,
                                openOnFocus = FALSE,
                                selectOnTab = FALSE,
                                hideSelected = FALSE,
                                clearAfterSelect = TRUE
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

  # Separate reactive value for current step (isolated from input updates)
  current_step <- reactiveVal(1)

  # Loading flag to prevent observer interference during restoration
  loading_in_progress <- reactiveVal(FALSE)

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
    current_step(as.numeric(input$goto_step))
    # Also update main workflow state for saving
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
  
  # Render current step content (isolated from input updates)
  output$current_step_content <- renderUI({
    step_num <- current_step()

    switch(as.character(step_num),
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
      new_step <- state$current_step + 1
      current_step(new_step)
      state$current_step <- new_step
      state$completed_steps <- unique(c(state$completed_steps, state$current_step - 1))
      workflow_state(update_workflow_progress(state))
    }
  })

  observeEvent(input$prev_step, {
    state <- workflow_state()
    if (state$current_step > 1) {
      new_step <- state$current_step - 1
      current_step(new_step)
      state$current_step <- new_step
      workflow_state(state)
    }
  })

  # Initialize problem statement as reactive value for editing
  problem_statement_reactive <- reactiveVal("")

  # Create separate reactive values for input storage (don't trigger UI re-renders)
  input_values <- reactiveValues(
    project_name = "",
    problem_statement = ""
  )

  # Create debounced reactive values to prevent rapid updates
  problem_statement_debounced <- debounce(reactive(input$problem_statement), 1000)
  project_name_debounced <- debounce(reactive(input$project_name), 1000)

  # Update input storage immediately (for immediate feedback) without touching workflow_state
  observeEvent(input$problem_statement, {
    if (!is.null(input$problem_statement) && !loading_in_progress()) {
      problem_statement_reactive(input$problem_statement)
      input_values$problem_statement <- input$problem_statement
    }
  }, ignoreInit = TRUE)

  observeEvent(input$project_name, {
    if (!is.null(input$project_name) && !loading_in_progress()) {
      input_values$project_name <- input$project_name
    }
  }, ignoreInit = TRUE)

  # Only update main workflow state on debounced changes (for save functionality)
  observeEvent(problem_statement_debounced(), {
    if (!is.null(problem_statement_debounced()) && !loading_in_progress()) {
      state <- workflow_state()
      state$central_problem <- problem_statement_debounced()
      workflow_state(state)
    }
  }, ignoreInit = TRUE)

  observeEvent(project_name_debounced(), {
    if (!is.null(project_name_debounced()) && !loading_in_progress()) {
      state <- workflow_state()
      state$project_name <- project_name_debounced()
      workflow_state(state)
    }
  }, ignoreInit = TRUE)

  # Reactive values to store selected activities and pressures
  selected_items <- reactiveValues(
    activities = data.frame(name = character(), stringsAsFactors = FALSE),
    pressures = data.frame(name = character(), stringsAsFactors = FALSE),
    controls = data.frame(name = character(), stringsAsFactors = FALSE),
    consequences = data.frame(name = character(), stringsAsFactors = FALSE),
    protective_controls = data.frame(name = character(), stringsAsFactors = FALSE)
  )

  # Update selectizeInput choices when steps change
  observe({
    current_step_value <- current_step()
    if (!is.null(vocabulary_data)) {
      # Step 3: Update activity and pressure search choices
      if (current_step_value == 3) {
        if (!is.null(vocabulary_data$activities) && nrow(vocabulary_data$activities) > 0) {
          activity_choices <- setNames(vocabulary_data$activities$name, vocabulary_data$activities$name)
          updateSelectizeInput(session, "activity_search", choices = activity_choices, selected = character(0), server = TRUE)
        }
        if (!is.null(vocabulary_data$pressures) && nrow(vocabulary_data$pressures) > 0) {
          pressure_choices <- setNames(vocabulary_data$pressures$name, vocabulary_data$pressures$name)
          updateSelectizeInput(session, "pressure_search", choices = pressure_choices, selected = character(0), server = TRUE)
        }
      }
      # Step 4: Update control search choices
      else if (current_step_value == 4) {
        if (!is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
          control_choices <- setNames(vocabulary_data$controls$name, vocabulary_data$controls$name)
          updateSelectizeInput(session, "control_search", choices = control_choices, selected = character(0), server = TRUE)
        }
      }
      # Step 5: Update consequence search choices
      else if (current_step_value == 5) {
        if (!is.null(vocabulary_data$consequences) && nrow(vocabulary_data$consequences) > 0) {
          consequence_choices <- setNames(vocabulary_data$consequences$name, vocabulary_data$consequences$name)
          updateSelectizeInput(session, "consequence_search", choices = consequence_choices, selected = character(0), server = TRUE)
        }
      }
      # Step 6: Update protective control search choices
      else if (current_step_value == 6) {
        if (!is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
          protective_choices <- setNames(vocabulary_data$controls$name, vocabulary_data$controls$name)
          updateSelectizeInput(session, "protective_search", choices = protective_choices, selected = character(0), server = TRUE)
        }
      }
    }
  })

  # Handle Add Activity button
  observeEvent(input$add_activity, {
    activity_name <- input$activity_search
    if (!is.null(activity_name) && activity_name != "" && !activity_name %in% selected_items$activities$name) {
      new_activity <- data.frame(name = activity_name, stringsAsFactors = FALSE)
      selected_items$activities <- rbind(selected_items$activities, new_activity)

      # Clear the search box
      updateSelectizeInput(session, "activity_search", selected = character(0))

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
      updateSelectizeInput(session, "pressure_search", selected = character(0))

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
      updateSelectizeInput(session, "control_search", selected = character(0))

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
      updateSelectizeInput(session, "consequence_search", selected = character(0))

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
      updateSelectizeInput(session, "protective_search", selected = character(0))
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
      current_state <- workflow_state()
      save_data <- list(
        timestamp = Sys.time(),
        current_step = current_state$current_step,
        completed_steps = current_state$completed_steps,
        selected_items = list(
          activities = isolate(selected_items$activities),
          pressures = isolate(selected_items$pressures),
          controls = isolate(selected_items$controls),
          consequences = isolate(selected_items$consequences),
          protective_controls = isolate(selected_items$protective_controls)
        ),
        inputs = list(
          project_name = input_values$project_name %||% input$project_name %||% "",
          project_description = input$project_description %||% "",
          analysis_scope = input$analysis_scope %||% "",
          problem_statement = input_values$problem_statement %||% input$problem_statement %||% ""
        )
      )

      # Save to file with timestamp
      filename <- paste0("workflow_progress_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds")
      saveRDS(save_data, file = filename)

      # Show success message
      showNotification(
        paste("Progress saved successfully to", filename),
        type = "message",
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
      # Set loading flag to prevent observer interference
      loading_in_progress(TRUE)

      # Get list of available save files
      save_files <- list.files(pattern = "^workflow_progress_.*\\.rds$", full.names = TRUE)

      if (length(save_files) == 0) {
        loading_in_progress(FALSE)
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
      current_state <- workflow_state()
      current_state$current_step <- load_data$current_step
      current_state$completed_steps <- load_data$completed_steps
      current_state$project_name <- load_data$inputs$project_name %||% ""
      current_state$central_problem <- load_data$inputs$problem_statement %||% ""
      workflow_state(current_state)

      # Also update isolated step
      current_step(as.numeric(load_data$current_step %||% 1))

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

        # Also update our internal reactive values
        input_values$project_name <- load_data$inputs$project_name %||% ""
        input_values$problem_statement <- load_data$inputs$problem_statement %||% ""
        problem_statement_reactive(load_data$inputs$problem_statement %||% "")
      }

      # Show success message
      showNotification(
        paste("Progress loaded from", basename(latest_file),
              "- saved on", format(load_data$timestamp, "%Y-%m-%d %H:%M:%S")),
        type = "message",
        duration = 4
      )
      cat("✅ Progress loaded from:", latest_file, "\n")

      # Reset loading flag to allow normal input behavior
      loading_in_progress(FALSE)

    }, error = function(e) {
      # Reset loading flag on error
      loading_in_progress(FALSE)
      showNotification(
        paste("Error loading progress:", e$message),
        type = "error",
        duration = 5
      )
      cat("❌ Error loading progress:", e$message, "\n")
    })
  })

  # =============================================================================
  # Step 7: Review & Validate Server Logic
  # =============================================================================

  # Review outputs for step 7
  output$review_central_problem <- renderText({
    # Use reactive value if available, otherwise fall back to input
    problem_text <- problem_statement_reactive()
    if (is.null(problem_text) || nchar(trimws(problem_text)) == 0) {
      problem_text <- input$problem_statement %||% "No central problem defined"
    }
    problem_text
  })

  output$activity_count <- renderText({
    nrow(selected_items$activities)
  })

  output$pressure_count <- renderText({
    nrow(selected_items$pressures)
  })

  output$preventive_count <- renderText({
    nrow(selected_items$controls)
  })

  output$consequence_count <- renderText({
    nrow(selected_items$consequences)
  })

  output$protective_count <- renderText({
    nrow(selected_items$protective_controls)
  })

  output$review_activities <- DT::renderDataTable({
    if (nrow(selected_items$activities) == 0) {
      data.frame(Activity = "No activities added yet")
    } else {
      selected_items$activities
    }
  }, options = list(pageLength = 5, searching = FALSE, info = FALSE))

  output$review_pressures <- DT::renderDataTable({
    if (nrow(selected_items$pressures) == 0) {
      data.frame(Pressure = "No pressures added yet")
    } else {
      selected_items$pressures
    }
  }, options = list(pageLength = 5, searching = FALSE, info = FALSE))

  output$review_preventive <- DT::renderDataTable({
    if (nrow(selected_items$controls) == 0) {
      data.frame(Control = "No preventive controls added yet")
    } else {
      selected_items$controls
    }
  }, options = list(pageLength = 5, searching = FALSE, info = FALSE))

  output$review_consequences <- DT::renderDataTable({
    if (nrow(selected_items$consequences) == 0) {
      data.frame(Consequence = "No consequences added yet")
    } else {
      selected_items$consequences
    }
  }, options = list(pageLength = 5, searching = FALSE, info = FALSE))

  output$review_protective <- DT::renderDataTable({
    if (nrow(selected_items$protective_controls) == 0) {
      data.frame(Control = "No protective controls added yet")
    } else {
      selected_items$protective_controls
    }
  }, options = list(pageLength = 5, searching = FALSE, info = FALSE))

  output$validation_results <- renderUI({
    total_activities <- nrow(selected_items$activities)
    total_pressures <- nrow(selected_items$pressures)
    total_preventive <- nrow(selected_items$controls)
    total_consequences <- nrow(selected_items$consequences)
    total_protective <- nrow(selected_items$protective_controls)

    validations <- list()

    if (total_activities == 0) {
      validations <- append(validations, list(div(class = "alert alert-warning", "⚠️ No activities defined")))
    } else {
      validations <- append(validations, list(div(class = "alert alert-success", paste("✅", total_activities, "activities defined"))))
    }

    if (total_pressures == 0) {
      validations <- append(validations, list(div(class = "alert alert-warning", "⚠️ No pressures defined")))
    } else {
      validations <- append(validations, list(div(class = "alert alert-success", paste("✅", total_pressures, "pressures defined"))))
    }

    if (total_consequences == 0) {
      validations <- append(validations, list(div(class = "alert alert-warning", "⚠️ No consequences defined")))
    } else {
      validations <- append(validations, list(div(class = "alert alert-success", paste("✅", total_consequences, "consequences defined"))))
    }

    tagList(validations)
  })

  output$bowtie_statistics <- renderText({
    total_activities <- nrow(selected_items$activities)
    total_pressures <- nrow(selected_items$pressures)
    total_preventive <- nrow(selected_items$controls)
    total_consequences <- nrow(selected_items$consequences)
    total_protective <- nrow(selected_items$protective_controls)

    paste(
      "Total Elements:", total_activities + total_pressures + total_preventive + total_consequences + total_protective, "\n",
      "Activities:", total_activities, "\n",
      "Pressures:", total_pressures, "\n",
      "Preventive Controls:", total_preventive, "\n",
      "Consequences:", total_consequences, "\n",
      "Protective Controls:", total_protective
    )
  })

  output$completeness_score <- renderUI({
    total_activities <- nrow(selected_items$activities)
    total_pressures <- nrow(selected_items$pressures)
    total_consequences <- nrow(selected_items$consequences)

    # Basic completeness check
    score <- 0
    if (total_activities > 0) score <- score + 25
    if (total_pressures > 0) score <- score + 25
    if (total_consequences > 0) score <- score + 25

    # Check problem statement using reactive value
    problem_text <- problem_statement_reactive()
    if (is.null(problem_text) || nchar(trimws(problem_text)) == 0) {
      problem_text <- input$problem_statement %||% ""
    }
    if (nchar(trimws(problem_text)) > 0) score <- score + 25

    color <- if (score >= 75) "success" else if (score >= 50) "warning" else "danger"

    div(class = paste("alert alert-", color),
        h5(paste("Completeness Score:", score, "%")),
        if (score == 100) p("🎉 Your bowtie is complete!") else p("Complete all sections to reach 100%")
    )
  })

  # =============================================================================
  # Step 7: Edit Button Handlers
  # =============================================================================

  # Edit Central Problem Handler
  observeEvent(input$edit_central_problem, {
    showModal(modalDialog(
      title = "✏️ Edit Central Problem",
      textAreaInput("edit_problem_text",
                   "Central Problem Statement:",
                   value = input$problem_statement %||% "",
                   placeholder = "Define the central environmental problem...",
                   height = "120px"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("save_edited_problem", "💾 Save Changes", class = "btn-primary")
      ),
      easyClose = TRUE
    ))
  })

  # Save edited problem
  observeEvent(input$save_edited_problem, {
    if (!is.null(input$edit_problem_text) && nchar(trimws(input$edit_problem_text)) > 0) {
      # Update the reactive value immediately
      problem_statement_reactive(input$edit_problem_text)

      # Update workflow state for integration
      current_state <- workflow_state()
      current_state$central_problem <- input$edit_problem_text
      workflow_state(current_state)

      # Try to update the UI input as well for consistency
      tryCatch({
        updateTextAreaInput(session, "problem_statement", value = input$edit_problem_text)
      }, error = function(e) {
        cat("Warning: Could not update problem_statement UI element:", e$message, "\n")
      })

      showNotification("✅ Central problem updated successfully!", type = "message")
      removeModal()
    } else {
      showNotification("⚠️ Please enter a valid problem statement", type = "warning")
    }
  })

  # Add More Threats Handler (goes back to step 3)
  observeEvent(input$add_more_threats, {
    showModal(modalDialog(
      title = "➕ Add More Threats & Causes",
      p("You will be redirected to Step 3 to add more activities and pressures."),
      p("Your current progress will be preserved."),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_add_threats", "🔄 Go to Step 3", class = "btn-warning")
      ),
      easyClose = TRUE
    ))
  })

  # Confirm add threats
  observeEvent(input$confirm_add_threats, {
    current_state <- workflow_state()
    current_state$current_step <- 3
    workflow_state(current_state)
    showNotification("🔄 Redirected to Step 3 - Add Activities & Pressures", type = "message")
    removeModal()
  })

  # Add More Consequences Handler (goes back to step 5)
  observeEvent(input$add_more_consequences, {
    showModal(modalDialog(
      title = "➕ Add More Consequences",
      p("You will be redirected to Step 5 to add more consequences."),
      p("Your current progress will be preserved."),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_add_consequences", "🔄 Go to Step 5", class = "btn-danger")
      ),
      easyClose = TRUE
    ))
  })

  # Confirm add consequences
  observeEvent(input$confirm_add_consequences, {
    current_state <- workflow_state()
    current_state$current_step <- 5
    workflow_state(current_state)
    showNotification("🔄 Redirected to Step 5 - Add Consequences", type = "message")
    removeModal()
  })

  # =============================================================================
  # Step 7: Graphical Bowtie View
  # =============================================================================

  # Bowtie diagram output
  output$bowtie_diagram <- renderPlot({
    # Create a simple bowtie visualization using ggplot2
    tryCatch({
      if (!require(ggplot2, quietly = TRUE)) {
        plot.new()
        text(0.5, 0.5, "ggplot2 package required for visualization", cex = 1.2)
        return()
      }

      # Get current data with safe access
      activities <- tryCatch({
        if (is.null(selected_items$activities)) data.frame() else selected_items$activities
      }, error = function(e) data.frame())

      pressures <- tryCatch({
        if (is.null(selected_items$pressures)) data.frame() else selected_items$pressures
      }, error = function(e) data.frame())

      controls <- tryCatch({
        if (is.null(selected_items$controls)) data.frame() else selected_items$controls
      }, error = function(e) data.frame())

      consequences <- tryCatch({
        if (is.null(selected_items$consequences)) data.frame() else selected_items$consequences
      }, error = function(e) data.frame())

      protective_controls <- tryCatch({
        if (is.null(selected_items$protective_controls)) data.frame() else selected_items$protective_controls
      }, error = function(e) data.frame())

      # Debug output (commented out for production)
      # cat("Bowtie diagram debug:\n")
      # cat("- Activities:", nrow(activities), "rows, columns:", paste(names(activities), collapse = ", "), "\n")

      # Check if we have any meaningful data
      total_elements <- nrow(activities) + nrow(pressures) + nrow(consequences)

      if (total_elements == 0) {
        # Show instructional diagram with bowtie-specific icons and larger fonts
        ggplot() +
          theme_void() +
          theme(
            plot.background = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA)
          ) +
          # Central problem (large, prominent)
          geom_point(aes(x = 0.5, y = 0.5), size = 20, color = "#FF6B6B", alpha = 0.8) +
          geom_text(aes(x = 0.5, y = 0.5), label = "⚠️\nCentral\nProblem", size = 5, fontface = "bold", color = "white") +

          # Activities (left side, human/industrial activities)
          geom_point(aes(x = 0.15, y = 0.7), size = 14, color = "#4ECDC4", alpha = 0.7) +
          geom_text(aes(x = 0.15, y = 0.7), label = "🏭\nActivity", size = 4, color = "white", fontface = "bold") +

          # Pressures (environmental stressors)
          geom_point(aes(x = 0.3, y = 0.55), size = 14, color = "#45B7D1", alpha = 0.7) +
          geom_text(aes(x = 0.3, y = 0.55), label = "🌊\nPressure", size = 4, color = "white", fontface = "bold") +

          # Consequences (environmental impacts)
          geom_point(aes(x = 0.7, y = 0.55), size = 14, color = "#FFEAA7", alpha = 0.8) +
          geom_text(aes(x = 0.7, y = 0.55), label = "💥\nConsequence", size = 4, color = "#8B4513", fontface = "bold") +

          # Controls (protection measures)
          geom_point(aes(x = 0.85, y = 0.7), size = 14, color = "#96CEB4", alpha = 0.8) +
          geom_text(aes(x = 0.85, y = 0.7), label = "🛡️\nControl", size = 4, color = "white", fontface = "bold") +

          # Enhanced connecting lines with arrows
          geom_segment(aes(x = 0.22, y = 0.68, xend = 0.43, yend = 0.52),
                      arrow = arrow(length = unit(0.02, "npc"), type = "closed"),
                      linewidth = 1.5, color = "#666666", alpha = 0.8) +
          geom_segment(aes(x = 0.37, y = 0.53, xend = 0.43, yend = 0.51),
                      arrow = arrow(length = unit(0.02, "npc"), type = "closed"),
                      linewidth = 1.5, color = "#666666", alpha = 0.8) +
          geom_segment(aes(x = 0.57, y = 0.51, xend = 0.63, yend = 0.54),
                      arrow = arrow(length = unit(0.02, "npc"), type = "closed"),
                      linewidth = 1.5, color = "#666666", alpha = 0.8) +

          # Preventive controls barrier (left side)
          geom_rect(aes(xmin = 0.24, xmax = 0.26, ymin = 0.35, ymax = 0.65),
                   fill = "#96CEB4", alpha = 0.6) +
          geom_text(aes(x = 0.25, y = 0.3), label = "🚧 Preventive", size = 3.5, color = "#2D5016", angle = 90, fontface = "bold") +

          # Protective controls barrier (right side)
          geom_rect(aes(xmin = 0.74, xmax = 0.76, ymin = 0.35, ymax = 0.65),
                   fill = "#DDA0DD", alpha = 0.6) +
          geom_text(aes(x = 0.75, y = 0.3), label = "🛡️ Protective", size = 3.5, color = "#4A0E4E", angle = 90, fontface = "bold") +

          # Enhanced instructions with larger font
          annotate("text", x = 0.5, y = 0.15,
                  label = "🎯 Complete the guided workflow steps to build your bowtie diagram\n🏭 Activities → 🌊 Pressures → ⚠️ Central Problem → 💥 Consequences → 🛡️ Controls",
                  size = 5, hjust = 0.5, vjust = 0.5, color = "#2C3E50", fontface = "bold") +

          # Title
          annotate("text", x = 0.5, y = 0.9,
                  label = "🎯 Environmental Bowtie Risk Analysis",
                  size = 6, hjust = 0.5, vjust = 0.5, color = "#2C3E50", fontface = "bold") +

          xlim(0, 1) + ylim(0, 1)
      } else {
        # Create bowtie layout data
        center_x <- 0.5
        center_y <- 0.5

        # Create nodes data frame
        nodes <- data.frame(
          x = numeric(0),
          y = numeric(0),
          label = character(0),
          type = character(0),
          stringsAsFactors = FALSE
        )

        # Central problem - use reactive value
        problem_text <- problem_statement_reactive()
        if (is.null(problem_text) || nchar(trimws(problem_text)) == 0) {
          problem_text <- input$problem_statement %||% "Central Problem"
        }
        central_problem <- if (nchar(problem_text) > 0) {
          paste("⚠️", substr(problem_text, 1, 15))
        } else {
          "⚠️ Central Problem"
        }

        nodes <- rbind(nodes, data.frame(
          x = center_x, y = center_y,
          label = central_problem,
          type = "problem"
        ))

        # Activities (left side, top) - handle multiple possible column names
        if (nrow(activities) > 0) {
          activity_col <- NULL
          for (col in c("Activity", "name", "Name", "activity")) {
            if (col %in% names(activities)) {
              activity_col <- col
              break
            }
          }

          if (!is.null(activity_col)) {
            for (i in 1:min(3, nrow(activities))) {
              activity_label <- paste("🏭", substr(as.character(activities[[activity_col]][i]), 1, 12))
              nodes <- rbind(nodes, data.frame(
                x = 0.1, y = 0.7 - (i-1) * 0.15,
                label = activity_label,
                type = "activity",
                stringsAsFactors = FALSE
              ))
            }
          } else {
            cat("Warning: No recognized activity column found in:", paste(names(activities), collapse = ", "), "\n")
          }
        }

        # Pressures (left side, closer to center)
        if (nrow(pressures) > 0) {
          pressure_col <- NULL
          for (col in c("Pressure", "name", "Name", "pressure")) {
            if (col %in% names(pressures)) {
              pressure_col <- col
              break
            }
          }

          if (!is.null(pressure_col)) {
            for (i in 1:min(3, nrow(pressures))) {
              pressure_label <- paste("🌊", substr(as.character(pressures[[pressure_col]][i]), 1, 12))
              nodes <- rbind(nodes, data.frame(
                x = 0.25, y = 0.65 - (i-1) * 0.1,
                label = pressure_label,
                type = "pressure",
                stringsAsFactors = FALSE
              ))
            }
          } else {
            cat("Warning: No recognized pressure column found in:", paste(names(pressures), collapse = ", "), "\n")
          }
        }

        # Preventive Controls (left side, middle)
        if (nrow(controls) > 0) {
          control_col <- NULL
          for (col in c("Control", "name", "Name", "control")) {
            if (col %in% names(controls)) {
              control_col <- col
              break
            }
          }

          if (!is.null(control_col)) {
            for (i in 1:min(2, nrow(controls))) {
              control_label <- paste("🚧", substr(as.character(controls[[control_col]][i]), 1, 12))
              nodes <- rbind(nodes, data.frame(
                x = 0.3, y = 0.3 + (i-1) * 0.1,
                label = control_label,
                type = "preventive",
                stringsAsFactors = FALSE
              ))
            }
          } else {
            cat("Warning: No recognized control column found in:", paste(names(controls), collapse = ", "), "\n")
          }
        }

        # Consequences (right side)
        if (nrow(consequences) > 0) {
          consequence_col <- NULL
          for (col in c("Consequence", "name", "Name", "consequence")) {
            if (col %in% names(consequences)) {
              consequence_col <- col
              break
            }
          }

          if (!is.null(consequence_col)) {
            for (i in 1:min(3, nrow(consequences))) {
              consequence_label <- paste("💥", substr(as.character(consequences[[consequence_col]][i]), 1, 12))
              nodes <- rbind(nodes, data.frame(
                x = 0.75, y = 0.65 - (i-1) * 0.1,
                label = consequence_label,
                type = "consequence",
                stringsAsFactors = FALSE
              ))
            }
          } else {
            cat("Warning: No recognized consequence column found in:", paste(names(consequences), collapse = ", "), "\n")
          }
        }

        # Protective Controls (right side, bottom)
        if (nrow(protective_controls) > 0) {
          protective_col <- NULL
          for (col in c("Control", "name", "Name", "control")) {
            if (col %in% names(protective_controls)) {
              protective_col <- col
              break
            }
          }

          if (!is.null(protective_col)) {
            for (i in 1:min(2, nrow(protective_controls))) {
              protective_label <- paste("🛡️", substr(as.character(protective_controls[[protective_col]][i]), 1, 12))
              nodes <- rbind(nodes, data.frame(
                x = 0.7, y = 0.3 + (i-1) * 0.1,
                label = protective_label,
                type = "protective",
                stringsAsFactors = FALSE
              ))
            }
          } else {
            cat("Warning: No recognized protective control column found in:", paste(names(protective_controls), collapse = ", "), "\n")
          }
        }

        # Create connections data frame
        connections <- data.frame(
          x1 = numeric(0), y1 = numeric(0),
          x2 = numeric(0), y2 = numeric(0),
          stringsAsFactors = FALSE
        )

        # Add connections from activities to center
        activity_nodes <- nodes[nodes$type == "activity", , drop = FALSE]
        if (nrow(activity_nodes) > 0) {
          for (i in 1:nrow(activity_nodes)) {
            connections <- rbind(connections, data.frame(
              x1 = activity_nodes$x[i], y1 = activity_nodes$y[i],
              x2 = center_x, y2 = center_y,
              stringsAsFactors = FALSE
            ))
          }
        }

        # Add connections from center to consequences
        consequence_nodes <- nodes[nodes$type == "consequence", , drop = FALSE]
        if (nrow(consequence_nodes) > 0) {
          for (i in 1:nrow(consequence_nodes)) {
            connections <- rbind(connections, data.frame(
              x1 = center_x, y1 = center_y,
              x2 = consequence_nodes$x[i], y2 = consequence_nodes$y[i],
              stringsAsFactors = FALSE
            ))
          }
        }

        # Define colors for each type
        type_colors <- c(
          "problem" = "#FF6B6B",
          "activity" = "#4ECDC4",
          "pressure" = "#45B7D1",
          "preventive" = "#96CEB4",
          "consequence" = "#FFEAA7",
          "protective" = "#DDA0DD"
        )

        # Create the plot
        p <- ggplot() +
          theme_void() +
          theme(
            plot.background = element_rect(fill = "white", color = NA),
            panel.background = element_rect(fill = "white", color = NA)
          ) +
          xlim(0, 1) + ylim(0, 1)

        # Add connections with enhanced arrows
        if (nrow(connections) > 0) {
          p <- p + geom_segment(data = connections,
                               aes(x = x1, y = y1, xend = x2, yend = y2),
                               arrow = arrow(length = unit(0.02, "npc"), type = "closed"),
                               color = "#666666", linewidth = 1.2, alpha = 0.8)
        }

        # Add nodes with enhanced styling
        if (nrow(nodes) > 0) {
          # Filter type_colors to only include types present in nodes
          present_types <- unique(nodes$type)
          filtered_colors <- type_colors[names(type_colors) %in% present_types]

          # Determine node sizes based on type
          node_sizes <- ifelse(nodes$type == "problem", 16, 12)

          p <- p + geom_point(data = nodes,
                             aes(x = x, y = y, color = type),
                             size = node_sizes, alpha = 0.9) +
                   scale_color_manual(values = filtered_colors,
                                    limits = present_types) +
                   geom_text(data = nodes,
                            aes(x = x, y = y, label = label),
                            size = 3.5, hjust = 0.5, vjust = 0.5,
                            color = "white", fontface = "bold")
        }

        # Add enhanced legend with icons
        p <- p + guides(color = guide_legend(title = "🎯 Bowtie Elements",
                                           override.aes = list(size = 6))) +
                theme(legend.position = "bottom",
                      legend.title = element_text(size = 12, face = "bold"),
                      legend.text = element_text(size = 10),
                      legend.background = element_rect(fill = "white", color = "gray80"),
                      legend.margin = margin(10, 10, 10, 10))

        p
      }
    }, error = function(e) {
      # Fallback plot if ggplot2 fails
      plot.new()
      text(0.5, 0.5, paste("Error creating bowtie diagram:", e$message), cex = 1)
    })
  })

  # =============================================================================
  # Step 8: Export Functionality Handlers
  # =============================================================================

  # Download bowtie files handler
  output$download_bowtie <- downloadHandler(
    filename = function() {
      timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
      project_name <- if (!is.null(workflow_state()$project_name)) {
        gsub("[^A-Za-z0-9_-]", "_", workflow_state()$project_name)
      } else {
        "Bowtie_Analysis"
      }
      paste0(project_name, "_", timestamp, ".zip")
    },
    content = function(file) {
      tryCatch({
        # Create temporary directory
        temp_dir <- tempdir()
        files_to_zip <- c()

        # Get current workflow data
        current_state <- workflow_state()
        selected_formats <- input$export_formats
        report_sections <- input$report_sections

        # Collect all workflow data
        workflow_data <- list(
          project_info = list(
            name = current_state$project_name %||% "Environmental Risk Assessment Project",
            central_problem = current_state$central_problem %||% problem_statement_reactive() %||% "",
            timestamp = Sys.time(),
            created_by = "Guided Workflow System v5.1.0"
          ),
          activities = selected_items$activities %||% data.frame(),
          pressures = selected_items$pressures %||% data.frame(),
          controls = selected_items$controls %||% data.frame(),
          consequences = selected_items$consequences %||% data.frame(),
          protective_controls = selected_items$protective_controls %||% data.frame()
        )

        # Generate files based on selected formats
        if ("excel" %in% selected_formats) {
          excel_file <- file.path(temp_dir, "bowtie_analysis.xlsx")
          if (require(openxlsx, quietly = TRUE)) {
            wb <- createWorkbook()

            # Project info sheet
            addWorksheet(wb, "Project_Info")
            writeData(wb, "Project_Info", data.frame(
              Field = c("Project Name", "Central Problem", "Created", "Timestamp"),
              Value = c(
                workflow_data$project_info$name,
                workflow_data$project_info$central_problem,
                workflow_data$project_info$created_by,
                as.character(workflow_data$project_info$timestamp)
              )
            ))

            # Data sheets
            if (nrow(workflow_data$activities) > 0) {
              addWorksheet(wb, "Activities")
              writeData(wb, "Activities", workflow_data$activities)
            }
            if (nrow(workflow_data$pressures) > 0) {
              addWorksheet(wb, "Pressures")
              writeData(wb, "Pressures", workflow_data$pressures)
            }
            if (nrow(workflow_data$controls) > 0) {
              addWorksheet(wb, "Preventive_Controls")
              writeData(wb, "Preventive_Controls", workflow_data$controls)
            }
            if (nrow(workflow_data$consequences) > 0) {
              addWorksheet(wb, "Consequences")
              writeData(wb, "Consequences", workflow_data$consequences)
            }
            if (nrow(workflow_data$protective_controls) > 0) {
              addWorksheet(wb, "Protective_Controls")
              writeData(wb, "Protective_Controls", workflow_data$protective_controls)
            }

            saveWorkbook(wb, excel_file, overwrite = TRUE)
            files_to_zip <- c(files_to_zip, excel_file)
          }
        }

        if ("csv" %in% selected_formats) {
          # Export each data frame as separate CSV
          if (nrow(workflow_data$activities) > 0) {
            csv_file <- file.path(temp_dir, "activities.csv")
            write.csv(workflow_data$activities, csv_file, row.names = FALSE)
            files_to_zip <- c(files_to_zip, csv_file)
          }
          if (nrow(workflow_data$pressures) > 0) {
            csv_file <- file.path(temp_dir, "pressures.csv")
            write.csv(workflow_data$pressures, csv_file, row.names = FALSE)
            files_to_zip <- c(files_to_zip, csv_file)
          }
          if (nrow(workflow_data$controls) > 0) {
            csv_file <- file.path(temp_dir, "preventive_controls.csv")
            write.csv(workflow_data$controls, csv_file, row.names = FALSE)
            files_to_zip <- c(files_to_zip, csv_file)
          }
          if (nrow(workflow_data$consequences) > 0) {
            csv_file <- file.path(temp_dir, "consequences.csv")
            write.csv(workflow_data$consequences, csv_file, row.names = FALSE)
            files_to_zip <- c(files_to_zip, csv_file)
          }
          if (nrow(workflow_data$protective_controls) > 0) {
            csv_file <- file.path(temp_dir, "protective_controls.csv")
            write.csv(workflow_data$protective_controls, csv_file, row.names = FALSE)
            files_to_zip <- c(files_to_zip, csv_file)
          }
        }

        if ("json" %in% selected_formats) {
          json_file <- file.path(temp_dir, "bowtie_analysis.json")
          if (require(jsonlite, quietly = TRUE)) {
            writeLines(toJSON(workflow_data, pretty = TRUE), json_file)
            files_to_zip <- c(files_to_zip, json_file)
          }
        }

        if ("png" %in% selected_formats) {
          png_file <- file.path(temp_dir, "bowtie_diagram.png")
          if (require(ggplot2, quietly = TRUE)) {
            # Create enhanced bowtie diagram
            ggsave(png_file, plot = last_plot(), width = 12, height = 8, dpi = 300)
            files_to_zip <- c(files_to_zip, png_file)
          }
        }

        # Create README file
        readme_file <- file.path(temp_dir, "README.txt")
        readme_content <- paste0(
          "Environmental Bowtie Risk Analysis Export\n",
          "=========================================\n\n",
          "Project: ", workflow_data$project_info$name, "\n",
          "Central Problem: ", workflow_data$project_info$central_problem, "\n",
          "Generated: ", workflow_data$project_info$timestamp, "\n",
          "Created by: ", workflow_data$project_info$created_by, "\n\n",
          "Files included:\n",
          paste0("- ", basename(files_to_zip), collapse = "\n"), "\n\n",
          "Data Summary:\n",
          "- Activities: ", nrow(workflow_data$activities), " items\n",
          "- Pressures: ", nrow(workflow_data$pressures), " items\n",
          "- Preventive Controls: ", nrow(workflow_data$controls), " items\n",
          "- Consequences: ", nrow(workflow_data$consequences), " items\n",
          "- Protective Controls: ", nrow(workflow_data$protective_controls), " items\n"
        )
        writeLines(readme_content, readme_file)
        files_to_zip <- c(files_to_zip, readme_file)

        # Create ZIP file
        if (length(files_to_zip) > 0) {
          zip(file, files_to_zip, flags = "-j")  # -j flag excludes directory structure
        } else {
          # Create empty file if no data
          writeLines("No data available for export", file)
        }

      }, error = function(e) {
        # Error handling - create simple text file with error message
        writeLines(paste("Export error:", e$message), file)
      })
    }
  )

  # Save to cloud handler (placeholder functionality)
  observeEvent(input$save_to_cloud, {
    tryCatch({
      # Get current workflow data
      current_state <- workflow_state()

      # For now, show a success message (cloud integration would go here)
      showModal(modalDialog(
        title = "☁️ Cloud Save Feature",
        div(
          h4("🚧 Development Notice"),
          p("The cloud save functionality is currently in development."),
          p("Your bowtie analysis has been prepared for cloud storage with the following details:"),
          hr(),
          p(strong("Project Name:"), current_state$project_name %||% "Unnamed Project"),
          p(strong("Central Problem:"), current_state$central_problem %||% "Not defined"),
          p(strong("Data Components:")),
          tags$ul(
            tags$li("Activities: ", nrow(selected_items$activities %||% data.frame()), " items"),
            tags$li("Pressures: ", nrow(selected_items$pressures %||% data.frame()), " items"),
            tags$li("Preventive Controls: ", nrow(selected_items$controls %||% data.frame()), " items"),
            tags$li("Consequences: ", nrow(selected_items$consequences %||% data.frame()), " items"),
            tags$li("Protective Controls: ", nrow(selected_items$protective_controls %||% data.frame()), " items")
          ),
          hr(),
          p("💡 ", strong("Tip:"), " Use the Download Files button to export your analysis locally."),
          p("🔄 Cloud integration will be available in a future update.")
        ),
        footer = tagList(
          modalButton("Close"),
          downloadButton("download_from_modal", "📥 Download Instead", class = "btn-success")
        ),
        easyClose = TRUE,
        size = "l"
      ))

      # Show notification
      showNotification(
        "☁️ Cloud save initiated (development mode)",
        type = "message",
        duration = 3
      )

    }, error = function(e) {
      showNotification(
        paste("❌ Cloud save error:", e$message),
        type = "error",
        duration = 5
      )
    })
  })

  # Alternative download from modal
  output$download_from_modal <- downloadHandler(
    filename = function() {
      timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
      project_name <- if (!is.null(workflow_state()$project_name)) {
        gsub("[^A-Za-z0-9_-]", "_", workflow_state()$project_name)
      } else {
        "Bowtie_Analysis"
      }
      paste0(project_name, "_", timestamp, ".zip")
    },
    content = function(file) {
      # Reuse the same content generation logic as main download
      # This ensures consistency between download methods
      if (exists("output") && exists("download_bowtie", envir = as.environment(output))) {
        # Call the main download handler's content function
        output$download_bowtie$content(file)
      } else {
        writeLines("Error: Download functionality not available", file)
      }
    }
  )

  # =============================================================================
  # GUIDED WORKFLOW TO MAIN APP DATA CONVERSION
  # =============================================================================

  # Convert guided workflow data to main application format
  convert_workflow_to_main_format <- function() {
    tryCatch({
      # Get current workflow data
      current_state <- workflow_state()

      # Check if we have sufficient data
      if (is.null(selected_items$activities) || nrow(selected_items$activities) == 0 ||
          is.null(selected_items$pressures) || nrow(selected_items$pressures) == 0) {
        showNotification("⚠️ Need at least activities and pressures to convert data",
                        type = "warning", duration = 4)
        return(NULL)
      }

      # Create all possible combinations (Cartesian product)
      activities_df <- selected_items$activities
      pressures_df <- selected_items$pressures
      controls_df <- selected_items$controls %||% data.frame(name = "No Preventive Control Specified")
      consequences_df <- selected_items$consequences %||% data.frame(name = "Environmental Impact")
      protective_df <- selected_items$protective_controls %||% data.frame(name = "Emergency Response Measures")

      # Generate main application format data
      converted_data <- data.frame()

      # Create combinations based on available data
      for (i in 1:nrow(activities_df)) {
        for (j in 1:nrow(pressures_df)) {
          for (k in 1:min(nrow(controls_df), 3)) {  # Limit to 3 controls per combination
            for (l in 1:min(nrow(consequences_df), 2)) {  # Limit to 2 consequences per combination
              for (m in 1:min(nrow(protective_df), 2)) {  # Limit to 2 protective controls

                new_row <- data.frame(
                  # Core bowtie components
                  Activity = activities_df$name[i],
                  Pressure = pressures_df$name[j],
                  Preventive_Control = controls_df$name[k],
                  Central_Problem = current_state$central_problem %||% problem_statement_reactive() %||% "Environmental Risk Assessment",
                  Consequence = consequences_df$name[l],
                  Protective_Mitigation = protective_df$name[m],

                  # Generated escalation factors (realistic examples)
                  Escalation_Factor = sample(c(
                    "Extreme weather events and system stress",
                    "Equipment malfunction and human error",
                    "Infrastructure failures during peak demand",
                    "Economic pressures reducing maintenance",
                    "Climate change altering environmental conditions",
                    "Regulatory compliance failures",
                    "Emergency response delays"
                  ), 1),

                  # Risk assessment scores (randomized but realistic)
                  Activity_to_Pressure_Likelihood = sample(2:5, 1),
                  Activity_to_Pressure_Severity = sample(2:5, 1),
                  Pressure_to_Control_Effectiveness = sample(2:5, 1),
                  Control_to_Problem_Prevention = sample(2:5, 1),
                  Problem_to_Consequence_Likelihood = sample(2:5, 1),
                  Problem_to_Consequence_Severity = sample(2:5, 1),
                  Consequence_to_Protection_Effectiveness = sample(2:5, 1),
                  Protection_to_Recovery_Success = sample(2:5, 1),

                  # Escalation factor connection scores
                  Control_to_Escalation_Likelihood = sample(2:5, 1),
                  Control_to_Escalation_Severity = sample(2:5, 1),
                  Escalation_to_Central_Likelihood = sample(2:5, 1),
                  Escalation_to_Central_Severity = sample(2:5, 1),

                  stringsAsFactors = FALSE
                )

                # Calculate combined risk scores
                new_row$Activity_to_Pressure_Risk <- new_row$Activity_to_Pressure_Likelihood * new_row$Activity_to_Pressure_Severity
                new_row$Problem_to_Consequence_Risk <- new_row$Problem_to_Consequence_Likelihood * new_row$Problem_to_Consequence_Severity
                new_row$Overall_Pathway_Risk <- (new_row$Activity_to_Pressure_Risk + new_row$Problem_to_Consequence_Risk) / 2

                # Add main app required columns
                new_row$Likelihood <- new_row$Problem_to_Consequence_Likelihood
                new_row$Severity <- new_row$Problem_to_Consequence_Severity
                risk_score <- new_row$Likelihood * new_row$Severity
                new_row$Risk_Level <- ifelse(risk_score <= 6, "Low",
                                           ifelse(risk_score <= 15, "Medium", "High"))

                converted_data <- rbind(converted_data, new_row)
              }
            }
          }
        }
      }

      # Limit total rows to prevent overwhelming the interface
      if (nrow(converted_data) > 100) {
        converted_data <- converted_data[sample(nrow(converted_data), 100), ]
        showNotification("📊 Converted data limited to 100 scenarios for performance",
                        type = "message", duration = 3)
      }

      return(converted_data)

    }, error = function(e) {
      cat("❌ Error converting workflow data:", e$message, "\n")
      showNotification(paste("❌ Data conversion error:", e$message),
                      type = "error", duration = 5)
      return(NULL)
    })
  }

  # Export workflow data to main application
  observeEvent(input$export_to_main_app, {
    showNotification("🔄 Converting guided workflow data to main application format...",
                    type = "default", duration = 3)

    converted_data <- convert_workflow_to_main_format()

    if (!is.null(converted_data) && nrow(converted_data) > 0) {

      # Store converted data in workflow state for external access
      current_state <- workflow_state()
      current_state$converted_main_data <- converted_data
      workflow_state(current_state)

      showNotification(
        paste("✅ Successfully converted", nrow(converted_data),
              "bowtie scenarios! Data is ready for main application."),
        type = "message", duration = 5
      )

      # Additional notification with instructions
      showNotification(
        "📋 Navigate to other tabs to view your data in bowtie diagrams, risk matrices, and data tables.",
        type = "message", duration = 7
      )

    } else {
      showNotification("❌ Failed to convert workflow data. Please ensure you have completed the workflow.",
                      type = "error", duration = 5)
    }
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