# =============================================================================
# Guided Workflow - Step UI Generators
# Extracted from guided_workflow.R for maintainability
# =============================================================================
# Contains:
#   - workflow_progress_ui()        - Progress bar display
#   - workflow_steps_sidebar_ui()   - Step navigation sidebar
#   - generate_step1_ui()           - Project Setup
#   - generate_step2_ui()           - Central Problem Definition
#   - generate_step3_ui()           - Threats & Causes
#   - generate_step4_ui()           - Preventive Controls
#   - generate_step5_ui()           - Consequences
#   - generate_step6_ui()           - Protective Controls
#   - generate_step7_ui()           - Escalation Factors
#   - generate_step8_ui()           - Review & Finalize
# =============================================================================

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
                   "Personnalis\u00e9" = "custom")
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
                   "\U0001f916 AI-Powered Activity Suggestions",
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
                 "\U0001f916 AI-Powered Pressure Suggestions",
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
                 "\U0001f916 AI-Powered Control Suggestions",
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
                 "\U0001f916 AI-Powered Consequence Suggestions",
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
        h5("\U0001f6e1\ufe0f Define Protective Controls"),
        p(t("gw_protective_desc", current_lang))
    ),

    fluidRow(
      column(12,
             h4("\U0001f50d Search and Add Protective/Mitigation Controls"),
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
                 "\U0001f916 AI-Powered Protective Control Suggestions",
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
             h5("\U0001f4cb Custom Entries Summary"),
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
