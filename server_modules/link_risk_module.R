# =============================================================================
# Server Module - Link Risk Assessment
# =============================================================================
# Purpose: Handles link-by-link risk assessment for bowtie pathways
# Dependencies: DT, plotly, utils.R (getCurrentData)
# =============================================================================

#' Initialize link risk assessment module
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param getCurrentData Reactive function that returns current data
#' @param currentData Reactive value for current data (settable)
#' @param editedData Reactive value for edited data (settable)
#' @param dataVersion Reactive value for data version counter
#' @param lang Reactive function returning current language code
#' @return NULL (module defines outputs and observers directly)
init_link_risk_module <- function(input, output, session, getCurrentData,
                                  currentData, editedData, dataVersion, lang) {

  # ===========================================================================
  # REACTIVE VALUES
  # ===========================================================================

  # Reactive value to store current selected scenario for editing
  selected_risk_scenario <- reactiveVal(NULL)

  # ===========================================================================
  # SCENARIO SELECTION AND LOADING
  # ===========================================================================

  # Populate scenario choices
  observe({
    data <- getCurrentData()
    if (!is.null(data) && nrow(data) > 0) {
      # Create unique scenario identifiers
      scenario_labels <- paste0(
        "Row ", 1:nrow(data), ": ",
        data$Activity, " -> ",
        data$Pressure, " -> ",
        data$Central_Problem, " -> ",
        data$Consequence
      )
      scenario_choices <- setNames(1:nrow(data), scenario_labels)
      updateSelectInput(session, "link_risk_scenario",
                       choices = scenario_choices,
                       selected = scenario_choices[1])
    }
  })

  # Load selected scenario data
  observeEvent(input$link_risk_scenario, {
    req(input$link_risk_scenario)
    data <- getCurrentData()
    req(data)

    row_idx <- as.numeric(input$link_risk_scenario)
    if (row_idx > 0 && row_idx <= nrow(data)) {
      selected_risk_scenario(data[row_idx, ])

      # Update sliders with current values
      row <- data[row_idx, ]

      # Activity -> Pressure
      if ("Activity_to_Pressure_Likelihood" %in% names(row)) {
        updateSliderInput(session, "activity_pressure_likelihood",
                         value = row$Activity_to_Pressure_Likelihood)
      }
      if ("Activity_to_Pressure_Severity" %in% names(row)) {
        updateSliderInput(session, "activity_pressure_severity",
                         value = row$Activity_to_Pressure_Severity)
      }

      # Pressure -> Control
      if ("Pressure_to_Control_Likelihood" %in% names(row)) {
        updateSliderInput(session, "pressure_control_likelihood",
                         value = row$Pressure_to_Control_Likelihood)
      }
      if ("Pressure_to_Control_Severity" %in% names(row)) {
        updateSliderInput(session, "pressure_control_severity",
                         value = row$Pressure_to_Control_Severity)
      }

      # Escalation -> Control
      if ("Control_to_Escalation_Likelihood" %in% names(row)) {
        updateSliderInput(session, "escalation_control_likelihood",
                         value = row$Control_to_Escalation_Likelihood)
      }
      if ("Control_to_Escalation_Severity" %in% names(row)) {
        updateSliderInput(session, "escalation_control_severity",
                         value = row$Control_to_Escalation_Severity)
      }

      # Central -> Consequence (using Escalation_to_Central for now)
      if ("Escalation_to_Central_Likelihood" %in% names(row)) {
        updateSliderInput(session, "central_consequence_likelihood",
                         value = row$Escalation_to_Central_Likelihood)
      }
      if ("Escalation_to_Central_Severity" %in% names(row)) {
        updateSliderInput(session, "central_consequence_severity",
                         value = row$Escalation_to_Central_Severity)
      }

      # Protection -> Consequence
      if ("Mitigation_to_Consequence_Likelihood" %in% names(row)) {
        updateSliderInput(session, "protection_consequence_likelihood",
                         value = row$Mitigation_to_Consequence_Likelihood)
      }
      if ("Mitigation_to_Consequence_Severity" %in% names(row)) {
        updateSliderInput(session, "protection_consequence_severity",
                         value = row$Mitigation_to_Consequence_Severity)
      }
    }
  })

  # ===========================================================================
  # SCENARIO INFO AND DESCRIPTIONS
  # ===========================================================================

  # Display selected scenario info
  output$selected_scenario_info <- renderUI({
    scenario <- selected_risk_scenario()
    req(scenario)

    tagList(
      h6("Current Pathway:", class = "text-primary"),
      tags$ul(class = "small",
        tags$li(strong("Activity: "), scenario$Activity),
        tags$li(strong("Pressure: "), scenario$Pressure),
        tags$li(strong("Preventive Control: "), scenario$Preventive_Control),
        tags$li(strong("Escalation Factor: "), scenario$Escalation_Factor),
        tags$li(strong("Central Problem: "), scenario$Central_Problem),
        tags$li(strong("Protective Control: "),
               if("Protective_Control" %in% names(scenario)) scenario$Protective_Control else scenario$Protective_Mitigation),
        tags$li(strong("Consequence: "), scenario$Consequence)
      )
    )
  })

  # Connection descriptions
  output$activity_pressure_description <- renderUI({
    scenario <- selected_risk_scenario()
    req(scenario)
    p(paste("How likely and severe is it that", scenario$Activity,
            "leads to", scenario$Pressure, "?"))
  })

  output$pressure_control_description <- renderUI({
    scenario <- selected_risk_scenario()
    req(scenario)
    p(paste("How likely and severe is", scenario$Pressure,
            "if", scenario$Preventive_Control, "is in place?"))
  })

  output$escalation_control_description <- renderUI({
    scenario <- selected_risk_scenario()
    req(scenario)
    p(paste("How likely and severe is it that", scenario$Escalation_Factor,
            "undermines", scenario$Preventive_Control, "?"))
  })

  output$central_consequence_description <- renderUI({
    scenario <- selected_risk_scenario()
    req(scenario)
    p(paste("How likely and severe is it that", scenario$Central_Problem,
            "leads to", scenario$Consequence, "?"))
  })

  output$protection_consequence_description <- renderUI({
    scenario <- selected_risk_scenario()
    req(scenario)
    prot_control <- if("Protective_Control" %in% names(scenario)) {
      scenario$Protective_Control
    } else {
      scenario$Protective_Mitigation
    }
    p(paste("How effective is", prot_control,
            "at reducing", scenario$Consequence, "severity?"))
  })

  # ===========================================================================
  # OVERALL PATHWAY RISK CALCULATION
  # ===========================================================================

  output$overall_pathway_risk <- renderUI({
    req(input$activity_pressure_likelihood, input$activity_pressure_severity,
        input$pressure_control_likelihood, input$pressure_control_severity,
        input$escalation_control_likelihood, input$escalation_control_severity,
        input$central_consequence_likelihood, input$central_consequence_severity,
        input$protection_consequence_likelihood, input$protection_consequence_severity)

    # Calculate overall likelihood (chain multiplication with scaling)
    overall_likelihood_raw <-
      input$activity_pressure_likelihood *
      (input$pressure_control_likelihood/5) *
      (input$escalation_control_likelihood/5) *
      (input$central_consequence_likelihood/5) *
      (input$protection_consequence_likelihood/5)

    overall_likelihood <- max(1, min(5, round(overall_likelihood_raw^0.3 * 2.5)))

    # Overall severity = maximum along pathway
    overall_severity <- max(
      input$activity_pressure_severity,
      input$pressure_control_severity,
      input$escalation_control_severity,
      input$central_consequence_severity,
      input$protection_consequence_severity
    )

    # Calculate risk score
    risk_score <- overall_likelihood * overall_severity
    risk_level <- ifelse(risk_score <= 6, "Low",
                        ifelse(risk_score <= 15, "Medium", "High"))
    risk_color <- switch(risk_level,
                        "Low" = "success",
                        "Medium" = "warning",
                        "High" = "danger")

    tagList(
      fluidRow(
        column(4,
          div(class = "text-center",
            h5("Likelihood"),
            h2(overall_likelihood, class = "text-primary")
          )
        ),
        column(4,
          div(class = "text-center",
            h5("Severity"),
            h2(overall_severity, class = "text-danger")
          )
        ),
        column(4,
          div(class = "text-center",
            h5("Risk Level"),
            h2(class = paste0("text-", risk_color), risk_level),
            p(class = "small", paste("Score:", risk_score))
          )
        )
      )
    )
  })

  # ===========================================================================
  # SAVE AND RESET HANDLERS
  # ===========================================================================

  # Save risk assessments
  observeEvent(input$save_link_risks, {
    req(input$link_risk_scenario)
    req(input$activity_pressure_likelihood, input$activity_pressure_severity,
        input$pressure_control_likelihood, input$pressure_control_severity,
        input$escalation_control_likelihood, input$escalation_control_severity,
        input$central_consequence_likelihood, input$central_consequence_severity,
        input$protection_consequence_likelihood, input$protection_consequence_severity)
    data <- getCurrentData()
    req(data)

    row_idx <- as.numeric(input$link_risk_scenario)

    # Check if data has granular risk columns before updating
    granular_cols <- c("Activity_to_Pressure_Likelihood", "Activity_to_Pressure_Severity",
                       "Pressure_to_Control_Likelihood", "Pressure_to_Control_Severity",
                       "Control_to_Escalation_Likelihood", "Control_to_Escalation_Severity",
                       "Escalation_to_Central_Likelihood", "Escalation_to_Central_Severity",
                       "Mitigation_to_Consequence_Likelihood", "Mitigation_to_Consequence_Severity")
    has_granular <- all(granular_cols %in% names(data))

    if (!has_granular) {
      # Create missing granular columns with current generic values as defaults
      for (col in granular_cols) {
        if (!(col %in% names(data))) {
          if (grepl("Likelihood", col)) data[[col]] <- data$Likelihood
          else data[[col]] <- data$Severity
        }
      }
      if (!("Overall_Likelihood" %in% names(data))) data$Overall_Likelihood <- data$Likelihood
      if (!("Overall_Severity" %in% names(data))) data$Overall_Severity <- data$Severity
      if (!("Risk_Level" %in% names(data))) data$Risk_Level <- ifelse(data$Likelihood * data$Severity <= 6, "Low", ifelse(data$Likelihood * data$Severity <= 15, "Medium", "High"))
    }

    # Update the data with new values
    data[row_idx, "Activity_to_Pressure_Likelihood"] <- input$activity_pressure_likelihood
    data[row_idx, "Activity_to_Pressure_Severity"] <- input$activity_pressure_severity
    data[row_idx, "Pressure_to_Control_Likelihood"] <- input$pressure_control_likelihood
    data[row_idx, "Pressure_to_Control_Severity"] <- input$pressure_control_severity
    data[row_idx, "Control_to_Escalation_Likelihood"] <- input$escalation_control_likelihood
    data[row_idx, "Control_to_Escalation_Severity"] <- input$escalation_control_severity
    data[row_idx, "Escalation_to_Central_Likelihood"] <- input$central_consequence_likelihood
    data[row_idx, "Escalation_to_Central_Severity"] <- input$central_consequence_severity
    data[row_idx, "Mitigation_to_Consequence_Likelihood"] <- input$protection_consequence_likelihood
    data[row_idx, "Mitigation_to_Consequence_Severity"] <- input$protection_consequence_severity

    # Recalculate overall risk
    overall_likelihood_raw <-
      input$activity_pressure_likelihood *
      (input$pressure_control_likelihood/5) *
      (input$escalation_control_likelihood/5) *
      (input$central_consequence_likelihood/5) *
      (input$protection_consequence_likelihood/5)

    data[row_idx, "Overall_Likelihood"] <- max(1, min(5, round(overall_likelihood_raw^0.3 * 2.5)))
    data[row_idx, "Overall_Severity"] <- max(
      input$activity_pressure_severity,
      input$pressure_control_severity,
      input$escalation_control_severity,
      input$central_consequence_severity,
      input$protection_consequence_severity
    )

    risk_score <- data[row_idx, "Overall_Likelihood"] * data[row_idx, "Overall_Severity"]
    data[row_idx, "Risk_Level"] <- ifelse(risk_score <= 6, "Low",
                                          ifelse(risk_score <= 15, "Medium", "High"))

    # Update both current and edited data
    currentData(data)
    editedData(data)
    dataVersion(dataVersion() + 1)

    notify_success("Risk assessments saved successfully!", duration = 3)
  })

  # Reset to current values
  observeEvent(input$reset_link_risks, {
    req(input$link_risk_scenario)
    data <- getCurrentData()
    req(data)

    row_idx <- as.numeric(input$link_risk_scenario)
    row <- data[row_idx, ]

    # Reset all sliders to current data values
    if ("Activity_to_Pressure_Likelihood" %in% names(row)) {
      updateSliderInput(session, "activity_pressure_likelihood", value = row$Activity_to_Pressure_Likelihood)
    }
    if ("Activity_to_Pressure_Severity" %in% names(row)) {
      updateSliderInput(session, "activity_pressure_severity", value = row$Activity_to_Pressure_Severity)
    }
    if ("Pressure_to_Control_Likelihood" %in% names(row)) {
      updateSliderInput(session, "pressure_control_likelihood", value = row$Pressure_to_Control_Likelihood)
    }
    if ("Pressure_to_Control_Severity" %in% names(row)) {
      updateSliderInput(session, "pressure_control_severity", value = row$Pressure_to_Control_Severity)
    }
    if ("Control_to_Escalation_Likelihood" %in% names(row)) {
      updateSliderInput(session, "escalation_control_likelihood", value = row$Control_to_Escalation_Likelihood)
    }
    if ("Control_to_Escalation_Severity" %in% names(row)) {
      updateSliderInput(session, "escalation_control_severity", value = row$Control_to_Escalation_Severity)
    }
    if ("Escalation_to_Central_Likelihood" %in% names(row)) {
      updateSliderInput(session, "central_consequence_likelihood", value = row$Escalation_to_Central_Likelihood)
    }
    if ("Escalation_to_Central_Severity" %in% names(row)) {
      updateSliderInput(session, "central_consequence_severity", value = row$Escalation_to_Central_Severity)
    }
    if ("Mitigation_to_Consequence_Likelihood" %in% names(row)) {
      updateSliderInput(session, "protection_consequence_likelihood", value = row$Mitigation_to_Consequence_Likelihood)
    }
    if ("Mitigation_to_Consequence_Severity" %in% names(row)) {
      updateSliderInput(session, "protection_consequence_severity", value = row$Mitigation_to_Consequence_Severity)
    }

    notify_info("Reset to current values", duration = 2)
  })

  # ===========================================================================
  # LINK REVIEW TAB CONTENT
  # ===========================================================================

  output$tab_link_risk_title <- renderUI({
    tagList(icon("link"), "Link Review & Risk Analysis")
  })

  output$linkRiskContent <- renderUI({
    data <- getCurrentData()

    if (is.null(data) || nrow(data) == 0) {
      return(
        div(class = "alert alert-info",
          h4(icon("info-circle"), " No Data Available"),
          p("Please load data from the Data Upload tab or create a bowtie using the Guided Workflow to analyze risk linkages.")
        )
      )
    }

    # Extract unique elements
    activities <- unique(data$Activity[!is.na(data$Activity)])
    pressures <- unique(data$Pressure[!is.na(data$Pressure)])
    controls <- unique(data$Preventive_Control[!is.na(data$Preventive_Control)])
    problems <- unique(data$Central_Problem[!is.na(data$Central_Problem)])
    consequences <- unique(data$Consequence[!is.na(data$Consequence)])
    if ("Protective_Control" %in% names(data)) {
      protections <- unique(data$Protective_Control[!is.na(data$Protective_Control)])
    } else if ("Protective_Mitigation" %in% names(data)) {
      protections <- unique(data$Protective_Mitigation[!is.na(data$Protective_Mitigation)])
    } else {
      protections <- character(0)
    }

    tagList(
      fluidRow(
        column(4,
          valueBox(
            value = length(activities),
            subtitle = "Activities",
            icon = icon("play"),
            color = "primary"
          )
        ),
        column(4,
          valueBox(
            value = length(pressures),
            subtitle = "Pressures",
            icon = icon("triangle-exclamation"),
            color = "danger"
          )
        ),
        column(4,
          valueBox(
            value = length(controls),
            subtitle = "Preventive Controls",
            icon = icon("shield-halved"),
            color = "success"
          )
        )
      ),

      fluidRow(
        column(4,
          valueBox(
            value = length(problems),
            subtitle = "Central Problems",
            icon = icon("bullseye"),
            color = "warning"
          )
        ),
        column(4,
          valueBox(
            value = length(consequences),
            subtitle = "Consequences",
            icon = icon("burst"),
            color = "orange"
          )
        ),
        column(4,
          valueBox(
            value = length(protections),
            subtitle = "Protective Controls",
            icon = icon("shield"),
            color = "info"
          )
        )
      ),

      hr(),

      h4(icon("diagram-project"), " Risk Linkage Network"),

      box(
        title = "Connection Analysis",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,

        tabsetPanel(
          id = "link_analysis_tabs",

          tabPanel(
            "Activity -> Pressure Links",
            icon = icon("arrow-right"),
            br(),
            p(class = "text-muted", paste("Analyzing", nrow(data), "activity-pressure connections")),
            DT::dataTableOutput("activity_pressure_links")
          ),

          tabPanel(
            "Pressure -> Control Links",
            icon = icon("arrow-right"),
            br(),
            p(class = "text-muted", "Preventive control effectiveness analysis"),
            DT::dataTableOutput("pressure_control_links")
          ),

          tabPanel(
            "Central Problem Pathways",
            icon = icon("bullseye"),
            br(),
            p(class = "text-muted", "Risk propagation to central problems"),
            DT::dataTableOutput("central_problem_links")
          ),

          tabPanel(
            "Consequence Pathways",
            icon = icon("burst"),
            br(),
            p(class = "text-muted", "Impact analysis and consequence severity"),
            DT::dataTableOutput("consequence_links")
          ),

          tabPanel(
            "Overall Risk Summary",
            icon = icon("chart-bar"),
            br(),
            plotly::plotlyOutput("risk_summary_plot", height = "500px")
          )
        )
      )
    )
  })

  # ===========================================================================
  # LINK ANALYSIS TABLES
  # ===========================================================================

  # Activity-Pressure Links Table
  output$activity_pressure_links <- DT::renderDataTable({
    data <- getCurrentData()
    req(data)

    # Use link-specific columns if available, fall back to generic Likelihood/Severity
    has_link_cols <- all(c("Activity_to_Pressure_Likelihood", "Activity_to_Pressure_Severity") %in% names(data))

    if (has_link_cols) {
      link_data <- data %>%
        select(Activity, Pressure, Activity_to_Pressure_Likelihood, Activity_to_Pressure_Severity) %>%
        filter(!is.na(Activity) & !is.na(Pressure)) %>%
        distinct()
      severity_col <- "Activity_to_Pressure_Severity"
    } else {
      link_data <- data %>%
        select(Activity, Pressure, Likelihood, Severity) %>%
        filter(!is.na(Activity) & !is.na(Pressure)) %>%
        distinct()
      severity_col <- "Severity"
    }

    datatable(
      link_data,
      options = list(pageLength = 10, scrollX = TRUE),
      colnames = c('Activity', 'Pressure', 'Likelihood', 'Severity'),
      rownames = FALSE
    ) %>%
      formatStyle(
        severity_col,
        backgroundColor = styleInterval(
          c(3, 6),
          c('#d4edda', '#fff3cd', '#f8d7da')
        )
      )
  })

  # Pressure-Control Links Table
  output$pressure_control_links <- DT::renderDataTable({
    data <- getCurrentData()
    req(data)

    has_link_cols <- all(c("Pressure_to_Control_Likelihood", "Pressure_to_Control_Severity") %in% names(data))

    if (has_link_cols) {
      link_data <- data %>%
        select(Pressure, Preventive_Control, Pressure_to_Control_Likelihood, Pressure_to_Control_Severity) %>%
        filter(!is.na(Pressure) & !is.na(Preventive_Control)) %>%
        distinct()
    } else {
      link_data <- data %>%
        select(Pressure, Preventive_Control, Likelihood, Severity) %>%
        filter(!is.na(Pressure) & !is.na(Preventive_Control)) %>%
        distinct()
    }

    datatable(
      link_data,
      options = list(pageLength = 10, scrollX = TRUE),
      colnames = c('Pressure', 'Preventive Control', 'Likelihood', 'Severity'),
      rownames = FALSE
    )
  })

  # Central Problem Links Table
  output$central_problem_links <- DT::renderDataTable({
    data <- getCurrentData()
    req(data)

    has_link_cols <- all(c("Escalation_to_Central_Likelihood", "Escalation_to_Central_Severity") %in% names(data))

    if (has_link_cols) {
      link_data <- data %>%
        select(Pressure, Central_Problem, Escalation_to_Central_Likelihood, Escalation_to_Central_Severity) %>%
        filter(!is.na(Central_Problem)) %>%
        distinct()
    } else {
      link_data <- data %>%
        select(Pressure, Central_Problem, Likelihood, Severity) %>%
        filter(!is.na(Central_Problem)) %>%
        distinct()
    }

    datatable(
      link_data,
      options = list(pageLength = 10, scrollX = TRUE),
      colnames = c('Pressure', 'Central Problem', 'Likelihood', 'Severity'),
      rownames = FALSE
    )
  })

  # Consequence Links Table
  output$consequence_links <- DT::renderDataTable({
    data <- getCurrentData()
    req(data)

    has_link_cols <- all(c("Mitigation_to_Consequence_Likelihood", "Mitigation_to_Consequence_Severity") %in% names(data))

    if (has_link_cols) {
      link_data <- data %>%
        select(Central_Problem, Consequence, Mitigation_to_Consequence_Likelihood, Mitigation_to_Consequence_Severity, Risk_Level) %>%
        filter(!is.na(Consequence)) %>%
        distinct()
    } else {
      link_data <- data %>%
        select(Central_Problem, Consequence, Likelihood, Severity, Risk_Level) %>%
        filter(!is.na(Consequence)) %>%
        distinct()
    }

    datatable(
      link_data,
      options = list(pageLength = 10, scrollX = TRUE),
      colnames = c('Central Problem', 'Consequence', 'Likelihood', 'Severity', 'Risk Level'),
      rownames = FALSE
    ) %>%
      formatStyle(
        'Risk_Level',
        backgroundColor = styleEqual(
          c('Low', 'Medium', 'High', 'Critical'),
          c('#d4edda', '#fff3cd', '#f8d7da', '#dc3545')
        ),
        color = styleEqual(
          c('Low', 'Medium', 'High', 'Critical'),
          c('#155724', '#856404', '#721c24', '#ffffff')
        )
      )
  })

  # Risk Summary Plot
  output$risk_summary_plot <- plotly::renderPlotly({
    data <- getCurrentData()
    req(data)

    risk_counts <- data %>%
      filter(!is.na(Risk_Level)) %>%
      count(Risk_Level) %>%
      mutate(Risk_Level = factor(Risk_Level, levels = c('Low', 'Medium', 'High', 'Critical')))

    plot_ly(risk_counts, x = ~Risk_Level, y = ~n, type = 'bar',
            marker = list(color = c('#28a745', '#ffc107', '#dc3545', '#6c757d'))) %>%
      layout(
        title = "Risk Distribution",
        xaxis = list(title = "Risk Level"),
        yaxis = list(title = "Count"),
        showlegend = FALSE
      )
  })

  # Link risk individual header
  output$link_risk_individual_header <- renderUI({
    tagList(icon("link"), t("link_risk_individual_title", lang()))
  })

  bowtie_log("Link risk assessment module initialized", level = "info")
}
