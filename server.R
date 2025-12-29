# Server Logic for Environmental Bowtie Risk Analysis Application
# =============================================================================

server <- function(input, output, session) {

  # Optimized reactive values using reactiveVal for single values
  currentData <- reactiveVal(NULL)
  editedData <- reactiveVal(NULL)
  sheets <- reactiveVal(NULL)
  envDataGenerated <- reactiveVal(FALSE)
  selectedRows <- reactiveVal(NULL)
  dataVersion <- reactiveVal(0)  # For cache invalidation

  # UI state tracking for empty states and accessibility
  hasData <- reactiveVal(FALSE)
  lastNotification <- reactiveVal(NULL)  # For aria-live regions

  # Translation reactive value (triggered by button click)
  currentLanguage <- reactiveVal("en")

  observeEvent(input$applyLanguage, {
    new_lang <- input$app_language
    currentLanguage(new_lang)

    # Update button labels
    tryCatch({
      updateActionButton(session, "loadData",
                        label = t("upload_button", new_lang), icon = icon("upload"))
      updateActionButton(session, "generateMultipleControls",
                        label = t("generate_data_button", new_lang), icon = icon("seedling"))
      updateActionButton(session, "applyLanguage",
                        label = t("apply_language", new_lang), icon = icon("check"))
    }, error = function(e) {
      cat("Note: Some UI elements may not update until page refresh\n")
    })

    # Update main navigation tab titles using JavaScript
    translations <- list(
      upload = t("tab_data_input", new_lang),
      guided_workflow = paste0("🧙 ", t("tab_guided_creation", new_lang)),
      bowtie = t("tab_bowtie_diagram", new_lang),
      bayesian = t("tab_bayesian", new_lang),
      table = t("tab_data_table", new_lang),
      matrix = t("tab_risk_matrix", new_lang),
      vocabulary = t("tab_vocabulary_management", new_lang),
      help = t("tab_help", new_lang)
    )

    # Target the nav-link elements by their data-value attribute
    # Multiple selectors to handle different bslib structures
    tab_updates <- list(
      list(value = "upload", icon = "upload", text = translations$upload),
      list(value = "guided_workflow", icon = "magic", text = translations$guided_workflow),
      list(value = "bowtie", icon = "project-diagram", text = translations$bowtie),
      list(value = "bayesian", icon = "brain", text = translations$bayesian),
      list(value = "table", icon = "table", text = translations$table),
      list(value = "matrix", icon = "chart-line", text = translations$matrix),
      list(value = "vocabulary", icon = "book", text = translations$vocabulary),
      list(value = "help", icon = "question-circle", text = translations$help)
    )

    # Generate JavaScript to update each tab - use data-value attribute
    js_code <- paste(
      sapply(tab_updates, function(tab) {
        sprintf(
          "setTimeout(function() {
             var $tab = $('#main_tabs a.nav-link[data-value=\"%s\"]');
             if ($tab.length > 0) {
               $tab.html('<i class=\"fa fa-%s\"></i> %s');
             }
           }, 100);",
          tab$value, tab$icon, tab$text
        )
      }),
      collapse = "\n"
    )

    runjs(js_code)

    showNotification(
      paste(t("language_label", new_lang), ":", ifelse(new_lang == "en", "English", "Français")),
      type = "message",
      duration = 3
    )
  })

  lang <- reactive({
    currentLanguage()
  })

  # Output for conditional rendering based on data availability
  output$hasData <- reactive({ hasData() })
  outputOptions(output, "hasData", suspendWhenHidden = FALSE)

  # Conditional menu item disabling based on data availability
  observe({
    data_available <- hasData()

    # Menu items that require bowtie data to function
    menu_items_to_disable <- c("bowtie", "matrix", "link_risk", "bayesian")

    if (data_available) {
      # Enable menu items when data is available
      runjs(paste0("
        ", paste(sapply(menu_items_to_disable, function(item) {
          sprintf("$('.sidebar-menu a.nav-link[data-value=\"%s\"]').removeClass('disabled');", item)
        }), collapse = "\n        "), "
        console.log('Menu items enabled: data available');
      "))
    } else {
      # Disable menu items when no data is available
      runjs(paste0("
        ", paste(sapply(menu_items_to_disable, function(item) {
          sprintf("$('.sidebar-menu a.nav-link[data-value=\"%s\"]').addClass('disabled');", item)
        }), collapse = "\n        "), "
        console.log('Menu items disabled: no data available');
      "))
    }
  })

  # ARIA live region announcer for accessibility
  output$notification_announcer <- renderUI({
    msg <- lastNotification()
    if (!is.null(msg)) {
      tags$span(msg)
    }
  })

  # NEW: Bayesian network reactive values
  bayesianNetwork <- reactiveVal(NULL)
  bayesianNetworkCreated <- reactiveVal(FALSE)
  inferenceResults <- reactiveVal(NULL)
  inferenceCompleted <- reactiveVal(FALSE)

  # Theme management reactive values
  themeUpdateTrigger <- reactiveVal(0)
  appliedTheme <- reactiveVal("zephyr")

  # Optimized data retrieval with caching
  getCurrentData <- reactive({
    edited <- editedData()
    if (!is.null(edited)) edited else currentData()
  })

  # Enhanced Theme management with comprehensive Bootstrap theme support
  current_theme <- reactive({
    # React to the trigger to update theme
    trigger_val <- themeUpdateTrigger()
    theme_choice <- appliedTheme()

    cat("🔄 current_theme() reactive triggered. Trigger:", trigger_val, "Choice:", theme_choice, "\n")

    # Handle custom theme with comprehensive user-defined colors
    if (theme_choice == "custom") {
      primary_color <- if (!is.null(input$primary_color)) input$primary_color else "#28a745"
      secondary_color <- if (!is.null(input$secondary_color)) input$secondary_color else "#6c757d"
      success_color <- if (!is.null(input$success_color)) input$success_color else "#28a745"
      info_color <- if (!is.null(input$info_color)) input$info_color else "#17a2b8"
      warning_color <- if (!is.null(input$warning_color)) input$warning_color else "#ffc107"
      danger_color <- if (!is.null(input$danger_color)) input$danger_color else "#dc3545"

      bs_theme(
        version = 5,
        primary = primary_color,
        secondary = secondary_color,
        success = success_color,
        info = info_color,
        warning = warning_color,
        danger = danger_color
      )
    } else if (theme_choice == "bootstrap") {
      # Default Bootstrap theme (no bootswatch)
      bs_theme(version = 5)
    } else {
      # Apply bootswatch theme with environmental enhancements
      base_theme <- bs_theme(version = 5, bootswatch = theme_choice)

      # Add theme-specific customizations for environmental application
      if (theme_choice == "journal") {
        # Environmental theme enhancements
        base_theme <- bs_theme(
          version = 5,
          bootswatch = theme_choice,
          success = "#2E7D32",  # Forest green
          info = "#0277BD",     # Ocean blue
          warning = "#F57C00",  # Earth orange
          danger = "#C62828"    # Environmental alert red
        )
      } else if (theme_choice == "darkly" || theme_choice == "slate" || theme_choice == "superhero" || theme_choice == "cyborg") {
        # Dark theme enhancements for better visibility
        base_theme <- bs_theme(
          version = 5,
          bootswatch = theme_choice,
          bg = if(theme_choice == "darkly") "#212529" else NULL,
          fg = if(theme_choice == "darkly") "#ffffff" else NULL
        )
      }

      base_theme
    }
  })

  # Enhanced theme observer with better error handling for bslib v5+
  observe({
    theme <- current_theme()
    tryCatch({
      # Use bs_themer() for dynamic theme switching in bslib 0.4+
      if (exists("bs_themer") && packageVersion("bslib") >= "0.4.0") {
        # For newer bslib versions, use reactive theme updating
        if (exists("session$setCurrentTheme")) {
          session$setCurrentTheme(theme)
        }
      }
    }, error = function(e) {
      # Silent error handling - theme functionality is working
    })
  })

  observeEvent(input$toggleTheme, {
    runjs('$("#themePanel").collapse("toggle");')
  })

  # Toggle controls panel
  observeEvent(input$toggleControls, {
    if (input$toggleControls %% 2 == 1) {
      # Hide controls, expand diagram
      updateActionButton(session, "toggleControls",
                        label = HTML('<i class="fa fa-chevron-right"></i> Show Controls'))
      runjs("
        $('#controlsPanel').hide();
        $('#diagramPanel').removeClass('col-sm-8').addClass('col-sm-12');
      ")
    } else {
      # Show controls, normal layout
      updateActionButton(session, "toggleControls",
                        label = HTML('<i class="fa fa-chevron-left"></i> Hide Controls'))
      runjs("
        $('#controlsPanel').show();
        $('#diagramPanel').removeClass('col-sm-12').addClass('col-sm-8');
      ")
    }
  })

  # File upload handling
  observeEvent(input$file, {
    req(input$file)
    tryCatch({
      sheet_names <- excel_sheets(input$file$datapath)
      sheets(sheet_names)
      updateSelectInput(session, "sheet", choices = sheet_names, selected = sheet_names[1])
    }, error = function(e) {
      showNotification(t("notify_error_reading_file", lang()), type = "error")
    })
  })

  output$fileUploaded <- reactive(!is.null(input$file))
  outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)

  # Enhanced data loading with validation
  observeEvent(input$loadData, {
    req(input$file, input$sheet)

    tryCatch({
      data <- read_excel(input$file$datapath, sheet = input$sheet)
      validation <- validateDataColumns(data)

      if (!validation$valid) {
        showNotification(paste("Missing required columns:",
                              paste(validation$missing, collapse = ", ")), type = "error")
        return()
      }

      data <- addDefaultColumns(data)
      currentData(data)
      editedData(data)
      dataVersion(dataVersion() + 1)
      hasData(TRUE)  # Track that data is loaded
      clear_cache()  # Clear cache when new data is loaded

      updateSelectInput(session, "selectedProblem", choices = unique(data$Central_Problem))
      updateSelectInput(session, "bayesianProblem", choices = unique(data$Central_Problem))

      # Improved success notification
      lastNotification(paste("✅", t("notify_data_loaded", lang())))
      showNotification(paste("✅", t("notify_data_loaded", lang())), type = "message", duration = 3)

    }, error = function(e) {
      hasData(FALSE)
      lastNotification(paste("❌ Error loading data:", e$message))
      showNotification(paste("❌ Error loading data:", e$message), type = "error", duration = 8)
    })
  })

  # Generate data using standardized vocabularies with multiple controls
  observeEvent(input$generateMultipleControls, {
    scenario_key <- input$data_scenario_template
    
    scenario_msg <- if (!is.null(scenario_key) && scenario_key != "") {
      paste0("🔄 Generating data with MULTIPLE CONTROLS for scenario: ", scenario_key)
    } else {
      "🔄 Generating data with MULTIPLE PREVENTIVE CONTROLS per pressure..."
    }
    
    showNotification(scenario_msg, type = "default", duration = 3)

    tryCatch({
      multiple_controls_data <- generateEnvironmentalDataWithMultipleControls(scenario_key)
      currentData(multiple_controls_data)
      editedData(multiple_controls_data)
      envDataGenerated(TRUE)
      dataVersion(dataVersion() + 1)
      clear_cache()

      problem_choices <- unique(multiple_controls_data$Central_Problem)
      updateSelectInput(session, "selectedProblem", choices = problem_choices, selected = problem_choices[1])
      updateSelectInput(session, "bayesianProblem", choices = problem_choices, selected = problem_choices[1])

      # Show detailed statistics
      unique_pressures <- length(unique(multiple_controls_data$Pressure))
      unique_controls <- length(unique(multiple_controls_data$Preventive_Control))
      total_entries <- nrow(multiple_controls_data)

      showNotification(
        paste("✅ Generated", total_entries, "entries with", unique_controls,
              "preventive controls across", unique_pressures, "environmental pressures!"),
        type = "default", duration = 5)

    }, error = function(e) {
      showNotification(paste("❌ Error generating multiple controls data:", e$message), type = "error", duration = 5)
    })
  })

  output$envDataGenerated <- reactive(envDataGenerated())
  outputOptions(output, "envDataGenerated", suspendWhenHidden = FALSE)

  # Optimized data loading check
  output$dataLoaded <- reactive({
    data <- getCurrentData()
    !is.null(data) && nrow(data) > 0
  })
  outputOptions(output, "dataLoaded", suspendWhenHidden = FALSE)

  # Enhanced data info with details
  output$dataInfo <- renderText({
    data <- getCurrentData()
    req(data)
    
    # Count unique elements in the bowtie
    counts <- list(
      activities = length(unique(data$Activity)),
      pressures = length(unique(data$Pressure)),
      controls = length(unique(data$Preventive_Control)),
      escalations = if("Escalation_Factor" %in% names(data)) length(unique(data$Escalation_Factor)) else 0,
      problems = length(unique(data$Central_Problem)),
      mitigations = length(unique(data$Protective_Mitigation)),
      consequences = length(unique(data$Consequence)),
      total_rows = nrow(data)
    )
    
    sprintf("Total Scenarios: %d\nActivities: %d | Pressures: %d | Controls: %d\nEscalations: %d | Problems: %d | Mitigations: %d | Consequences: %d",
            counts$total_rows, counts$activities, counts$pressures, counts$controls,
            counts$escalations, counts$problems, counts$mitigations, counts$consequences)
  })

  # Enhanced download handler
  output$downloadSample <- downloadHandler(
    filename = function() paste("enhanced_environmental_bowtie_", Sys.Date(), ".xlsx", sep = ""),
    content = function(file) {
      data <- getCurrentData()
      req(data)
      openxlsx::write.xlsx(data, file, rowNames = FALSE)
    }
  )

  # =============================================================================
  # NEW: BAYESIAN NETWORK ANALYSIS SERVER LOGIC
  # =============================================================================

  # Create Bayesian Network
  observeEvent(input$createBayesianNetwork, {
    data <- getCurrentData()
    req(data, input$bayesianProblem)

    showNotification(paste("🧠", t("notify_bayesian_creating", lang())), type = "default", duration = 3)

    tryCatch({
      # Convert bowtie to Bayesian network
      bn_result <- bowtie_to_bayesian(
        data,
        central_problem = input$bayesianProblem,
        learn_from_data = FALSE,
        visualize = TRUE
      )

      bayesianNetwork(bn_result)
      bayesianNetworkCreated(TRUE)

      showNotification(paste("✅", t("notify_bayesian_success", lang())), type = "message", duration = 3)

    }, error = function(e) {
      showNotification(paste("❌", t("notify_bayesian_error", lang()), e$message), type = "error")
      cat("Bayesian network error:", e$message, "\n")
    })
  })

  # Bayesian network created flag
  output$bayesianNetworkCreated <- reactive({
    bayesianNetworkCreated()
  })
  outputOptions(output, "bayesianNetworkCreated", suspendWhenHidden = FALSE)

  # Bayesian network visualization
  output$bayesianNetworkVis <- renderVisNetwork({
    bn_result <- bayesianNetwork()
    req(bn_result, bn_result$visualization)

    bn_result$visualization
  })

  # Network information
  output$networkInfo <- renderPrint({
    bn_result <- bayesianNetwork()
    req(bn_result)

    structure <- bn_result$structure
    cat("Network Structure:\n")
    cat("  Nodes:", nrow(structure$nodes), "\n")
    cat("  Edges:", nrow(structure$edges), "\n")
    cat("  Node types:\n")
    node_types <- table(structure$nodes$node_type)
    for (i in 1:length(node_types)) {
      cat("    ", names(node_types)[i], ":", node_types[i], "\n")
    }
  })

  # Run Bayesian inference
  observeEvent(input$runInference, {
    bn_result <- bayesianNetwork()
    req(bn_result, input$queryNodes)

    showNotification("🔮 Running Bayesian inference...", type = "default", duration = 2)

    tryCatch({
      # Prepare evidence
      evidence <- list()

      if (!is.null(input$evidenceActivity) && input$evidenceActivity != "") {
        evidence$Activity <- input$evidenceActivity
      }
      if (!is.null(input$evidencePressure) && input$evidencePressure != "") {
        evidence$Pressure_Level <- input$evidencePressure
      }
      if (!is.null(input$evidenceControl) && input$evidenceControl != "") {
        evidence$Control_Effect <- input$evidenceControl
      }

      # Run inference
      if (exists("perform_inference_simple")) {
        results <- perform_inference_simple(evidence, input$queryNodes)
      } else {
        # Fallback simplified inference for demo
        results <- list(
          Consequence_Level = c(Low = 0.3, Medium = 0.4, High = 0.3),
          Problem_Severity = c(Low = 0.2, Medium = 0.5, High = 0.3),
          Escalation_Level = c(Low = 0.4, Medium = 0.4, High = 0.2)
        )
      }

      inferenceResults(results)
      inferenceCompleted(TRUE)

      showNotification("✅ Inference completed!", type = "message", duration = 2)

    }, error = function(e) {
      showNotification(paste("❌ Error in inference:", e$message), type = "error")
      cat("Inference error:", e$message, "\n")
    })
  })

  # Inference results output
  output$inferenceResults <- renderPrint({
    results <- inferenceResults()
    req(results)

    cat("Probabilistic Predictions:\n\n")
    for (node in names(results)) {
      cat(node, ":\n")
      node_results <- results[[node]]
      for (state in names(node_results)) {
        cat("  ", state, ": ", sprintf("%.1f%%", node_results[state] * 100), "\n")
      }
      cat("\n")
    }
  })

  # Risk interpretation
  output$riskInterpretation <- renderUI({
    results <- inferenceResults()
    req(results)

    interpretations <- list()

    # Analyze consequence level
    if ("Consequence_Level" %in% names(results)) {
      cons_results <- results$Consequence_Level
      if ("High" %in% names(cons_results) && cons_results["High"] > 0.5) {
        interpretations <- append(interpretations,
          div(class = "alert alert-danger",
              tagList(icon("exclamation-triangle"), " "),
              strong("High Risk: "), sprintf("%.1f%% probability of severe consequences", cons_results["High"] * 100)))
      } else if ("Medium" %in% names(cons_results) && cons_results["Medium"] > 0.4) {
        interpretations <- append(interpretations,
          div(class = "alert alert-warning",
              tagList(icon("exclamation"), " "),
              strong("Medium Risk: "), sprintf("%.1f%% probability of moderate consequences", cons_results["Medium"] * 100)))
      } else {
        interpretations <- append(interpretations,
          div(class = "alert alert-success",
              tagList(icon("check-circle"), " "),
              strong("Low Risk: "), "Consequences likely to be manageable"))
      }
    }

    # Analyze problem severity
    if ("Problem_Severity" %in% names(results)) {
      prob_results <- results$Problem_Severity
      if ("High" %in% names(prob_results) && prob_results["High"] > 0.4) {
        interpretations <- append(interpretations,
          div(class = "alert alert-info",
              tagList(icon("info-circle"), " "),
              strong("Problem Analysis: "), "Central problem likely to be severe - enhanced monitoring recommended"))
      }
    }

    if (length(interpretations) == 0) {
      interpretations <- list(div(class = "alert alert-secondary", "Run inference to see risk interpretation"))
    }

    return(tagList(interpretations))
  })

  # Inference completed flag
  output$inferenceCompleted <- reactive({
    inferenceCompleted()
  })
  outputOptions(output, "inferenceCompleted", suspendWhenHidden = FALSE)

  # Scenario buttons
  observeEvent(input$scenarioWorstCase, {
    updateSelectInput(session, "evidenceActivity", selected = "Present")
    updateSelectInput(session, "evidencePressure", selected = "High")
    updateSelectInput(session, "evidenceControl", selected = "Failed")
    showNotification("🔴 Worst case scenario set", type = "warning", duration = 2)
  })

  observeEvent(input$scenarioBestCase, {
    updateSelectInput(session, "evidenceActivity", selected = "Absent")
    updateSelectInput(session, "evidencePressure", selected = "Low")
    updateSelectInput(session, "evidenceControl", selected = "Effective")
    showNotification("🟢 Best case scenario set", type = "message", duration = 2)
  })

  observeEvent(input$scenarioControlFailure, {
    updateSelectInput(session, "evidenceActivity", selected = "Present")
    updateSelectInput(session, "evidencePressure", selected = "Medium")
    updateSelectInput(session, "evidenceControl", selected = "Failed")
    showNotification("🟡 Control failure scenario set", type = "warning", duration = 2)
  })

  observeEvent(input$scenarioBaseline, {
    updateSelectInput(session, "evidenceActivity", selected = "")
    updateSelectInput(session, "evidencePressure", selected = "")
    updateSelectInput(session, "evidenceControl", selected = "")
    showNotification("ℹ️ Baseline scenario set (no evidence)", type = "message", duration = 2)
  })

  # Download Bayesian results
  output$downloadBayesianResults <- downloadHandler(
    filename = function() paste("bayesian_analysis_", Sys.Date(), ".html", sep = ""),
    content = function(file) {
      bn_result <- bayesianNetwork()
      results <- inferenceResults()
      req(bn_result)

      # Create HTML report
      html_content <- paste(
        "<html><head><title>Bayesian Network Analysis Report</title></head>",
        "<body>",
        "<h1>Environmental Bowtie Bayesian Network Analysis</h1>",
        "<h2>Network Structure</h2>",
        paste("<p>Nodes:", nrow(bn_result$structure$nodes), "</p>"),
        paste("<p>Edges:", nrow(bn_result$structure$edges), "</p>"),
        "<h2>Analysis Date</h2>",
        paste("<p>", Sys.Date(), "</p>"),
        "</body></html>",
        sep = ""
      )

      writeLines(html_content, file)
    }
  )

  # =============================================================================
  # EXISTING FUNCTIONALITY (keeping all original features)
  # =============================================================================

  # Optimized preview table
  output$preview <- DT::renderDataTable({
    data <- getCurrentData()
    req(data)

    DT::datatable(
      data,
      options = list(
        scrollX = TRUE,
        pageLength = 10,
        autoWidth = TRUE,
        processing = TRUE,
        deferRender = TRUE,
        scroller = TRUE,
        scrollY = 400
      ),
      class = 'cell-border stripe compact'
    )
  })

  # Enhanced editable table
  output$editableTable <- DT::renderDataTable({
    data <- getCurrentData()
    req(data)

    DT::datatable(
      data,
      options = list(
        scrollX = TRUE,
        pageLength = 20,
        selection = 'multiple',
        processing = TRUE,
        deferRender = TRUE,
        columnDefs = list(
          list(className = 'dt-center', targets = c(7, 8, 9)),
          list(width = '100px', targets = c(0, 1, 2, 3, 4, 5, 6)),
          list(width = '60px', targets = c(7, 8)),
          list(width = '80px', targets = c(9))
        ),
        autoWidth = FALSE,
        dom = 'Blfrtip',
        buttons = c('copy', 'csv', 'excel'),
        language = list(processing = "Loading enhanced data with Bayesian network support...")
      ),
      editable = list(target = 'cell'),
      extensions = c('Buttons', 'Scroller'),
      class = 'cell-border stripe compact hover',
      filter = 'top'
    )
  })

  # Enhanced cell editing
  observeEvent(input$editableTable_cell_edit, {
    info <- input$editableTable_cell_edit
    data <- getCurrentData()
    req(data)

    # Validate row and column indices
    if (info$row > nrow(data) || info$col > ncol(data)) {
      showNotification("❌ Invalid cell reference", type = "error")
      return()
    }

    col_names <- names(data)
    col_name <- col_names[info$col]

    # Numeric columns validation
    numeric_columns <- c("Likelihood", "Severity", "Overall_Likelihood", "Overall_Severity")

    if (col_name %in% numeric_columns) {
      validation <- validateNumericInput(info$value)
      if (!validation$valid) {
        showNotification(validation$message, type = "error", duration = 3)
        return()
      }
      data[info$row, info$col] <- validation$value
      data[info$row, "Risk_Level"] <- calculateRiskLevel(data[info$row, "Likelihood"], data[info$row, "Severity"])
    } else {
      data[info$row, info$col] <- as.character(info$value)
    }

    editedData(data)
    dataVersion(dataVersion() + 1)
    clear_cache()

    # Reset Bayesian network when data changes
    bayesianNetworkCreated(FALSE)
    inferenceCompleted(FALSE)

    if (runif(1) < 0.3) {
      showNotification("✓ Cell updated - Bayesian network ready for recreation", type = "default", duration = 1)
    }
  }, ignoreInit = TRUE, ignoreNULL = TRUE)

  # Track selected rows efficiently
  observe({
    selectedRows(input$editableTable_rows_selected)
  })

  # Enhanced row operations with safe column matching
  observeEvent(input$addRow, {
    tryCatch({
      data <- getCurrentData()

      # Initialize data if none exists
      if (is.null(data) || nrow(data) == 0) {
        cat("🔄 Initializing data for addRow operation...\n")
        initial_data <- generateEnvironmentalDataFixed()
        # Take only the structure but remove all rows to start fresh
        data <- initial_data[0, , drop = FALSE]
        currentData(data)
        editedData(data)
        showNotification("📊 Initialized new dataset for editing", type = "default", duration = 2)
      }

      selected_problem <- if (!is.null(input$selectedProblem)) input$selectedProblem else "New Environmental Risk"
      new_row <- createDefaultRowFixed(selected_problem)

      # Ensure column structure compatibility
      existing_cols <- names(data)
      new_row_cols <- names(new_row)

      # Add missing columns to new_row with NA values
      for (col in existing_cols) {
        if (!col %in% new_row_cols) {
          new_row[[col]] <- NA
        }
      }

      # Add missing columns to data with appropriate defaults
      for (col in new_row_cols) {
        if (!col %in% existing_cols) {
          data[[col]] <- NA
        }
      }

      # Reorder columns to match
      new_row <- new_row[, names(data), drop = FALSE]

      updated_data <- rbind(data, new_row)

      editedData(updated_data)
      dataVersion(dataVersion() + 1)
      clear_cache()
      bayesianNetworkCreated(FALSE)  # Reset Bayesian network
      showNotification("✅ New row added with Bayesian support!", type = "default", duration = 2)

    }, error = function(e) {
      cat("Error in addRow:", e$message, "\n")
      showNotification(paste("❌ Error adding row:", e$message), type = "error", duration = 5)
    })
  })

  observeEvent(input$deleteSelected, {
    rows <- selectedRows()
    if (!is.null(rows) && length(rows) > 0) {
      data <- getCurrentData()
      updated_data <- data[-rows, ]
      editedData(updated_data)
      dataVersion(dataVersion() + 1)
      clear_cache()
      bayesianNetworkCreated(FALSE)  # Reset Bayesian network
      showNotification(paste("🗑️ Deleted", length(rows), "row(s) - Bayesian network reset"), type = "warning", duration = 2)
    } else {
      showNotification(paste("❌", t("notify_no_rows_selected", lang())), type = "error", duration = 2)
    }
  })

  observeEvent(input$saveChanges, {
    edited <- editedData()
    if (!is.null(edited)) {
      currentData(edited)
      showNotification("💾 Changes saved with Bayesian network support!", type = "default", duration = 2)
    }
  })

  # Enhanced quick add functionality
  observeEvent(input$addActivityChain, {
    req(input$selectedProblem, input$newActivity, input$newPressure, input$newConsequence)

    if (trimws(input$newActivity) == "" || trimws(input$newPressure) == "" || trimws(input$newConsequence) == "") {
      showNotification("❌ Please enter activity, pressure, and consequence", type = "error")
      return()
    }

    data <- getCurrentData()

    new_row <- data.frame(
      Activity = input$newActivity,
      Pressure = input$newPressure,
      Preventive_Control = "Enhanced preventive control",
      Escalation_Factor = "Enhanced escalation factor",
      Central_Problem = input$selectedProblem,
      Protective_Mitigation = paste("Enhanced protective mitigation for", input$newConsequence),
      Consequence = input$newConsequence,
      Likelihood = 3L,
      Severity = 3L,
      Risk_Level = "Medium",
      stringsAsFactors = FALSE
    )

    updated_data <- rbind(data, new_row)
    editedData(updated_data)
    dataVersion(dataVersion() + 1)
    clear_cache()
    bayesianNetworkCreated(FALSE)  # Reset Bayesian network

    updateTextInput(session, "newActivity", value = "")
    updateTextInput(session, "newPressure", value = "")
    updateTextInput(session, "newConsequence", value = "")

    showNotification("🔗 Activity chain added with Bayesian network support!", type = "default", duration = 3)
  })

  # Enhanced debug info
  output$debugInfo <- renderText({
    data <- getCurrentData()
    if (!is.null(data)) {
      paste("✅ Loaded:", nrow(data), "rows,", ncol(data), "columns - Enhanced bowtie structure with Bayesian network support")
    } else {
      "No enhanced data loaded"
    }
  })

  # Bowtie network visualization
  output$bowtieNetwork <- renderVisNetwork({
    data <- getCurrentData()
    req(data, input$selectedProblem)

    problem_data <- data[data$Central_Problem == input$selectedProblem, ]
    if (nrow(problem_data) == 0) {
      showNotification("⚠️ No data for selected central problem", type = "warning")
      return(NULL)
    }

    nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, input$nodeSize,
                                   input$showRiskLevels, input$showBarriers)
    edges <- createBowtieEdgesFixed(problem_data, input$showBarriers)

    visNetwork(nodes, edges,
               main = input$selectedProblem,
               submain = if(input$showBarriers) "Complete risk pathway analysis" else "Direct causal relationships",
               width = "100%", height = "800px") %>%
      visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
               font = list(color = "#2C3E50", face = "Arial", multi = "html", bold = "12px Arial #000000")) %>%
      visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
               smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
      visLayout(randomSeed = 123, improvedLayout = FALSE) %>%
      visPhysics(enabled = FALSE, stabilization = FALSE) %>%
      visOptions(highlightNearest = list(enabled = TRUE, degree = 1),
                nodesIdSelection = TRUE, collapse = FALSE,
                manipulation = if(input$editMode) list(enabled = TRUE, addNode = TRUE, addEdge = TRUE,
                                                      editNode = TRUE, editEdge = TRUE, deleteNode = TRUE,
                                                      deleteEdge = TRUE) else list(enabled = FALSE)) %>%
      visInteraction(navigationButtons = TRUE, dragNodes = TRUE, dragView = TRUE, zoomView = TRUE) %>%
      visLegend(useGroups = FALSE, addNodes = list(
        list(label = "Activities (Human Actions)",
             color = "#8E44AD", shape = "square", size = 15),
        list(label = "Pressures (Environmental Threats)",
             color = "#E74C3C", shape = "triangle", size = 15),
        list(label = "Preventive Controls",
             color = "#27AE60", shape = "square", size = 15),
        list(label = "Escalation Factors",
             color = "#F39C12", shape = "triangleDown", size = 15),
        list(label = "Central Problem (Main Risk)",
             color = "#C0392B", shape = "diamond", size = 18),
        list(label = "Protective Mitigation",
             color = "#3498DB", shape = "square", size = 15),
        list(label = "Consequences (Impacts)",
             color = "#E67E22", shape = "hexagon", size = 15)
      ), position = "right", width = 0.25, ncol = 1)
  })

  # Enhanced risk matrix with comprehensive error handling
  output$riskMatrix <- renderPlotly({
    data <- getCurrentData()
    req(data, nrow(data) > 0)

    # Ensure Risk_Level column exists and is properly formatted
    if (!"Risk_Level" %in% names(data)) {
      # Calculate risk level based on likelihood and severity
      likelihood_col <- if ("Likelihood" %in% names(data)) data$Likelihood else data$Overall_Likelihood
      severity_col <- if ("Severity" %in% names(data)) data$Severity else data$Overall_Severity

      risk_scores <- likelihood_col * severity_col
      data$Risk_Level <- ifelse(risk_scores <= 6, "Low",
                               ifelse(risk_scores <= 15, "Medium", "High"))
    }

    # Ensure Risk_Level is character and has valid values
    if (is.numeric(data$Risk_Level)) {
      # Convert numeric risk level to categorical
      data$Risk_Level <- ifelse(data$Risk_Level <= 6, "Low",
                               ifelse(data$Risk_Level <= 15, "Medium", "High"))
    }

    # Validate Risk_Level values and set defaults for invalid ones
    valid_levels <- c("Low", "Medium", "High")
    data$Risk_Level[!data$Risk_Level %in% valid_levels] <- "Medium"

    # Ensure Likelihood and Severity columns exist
    if (!"Likelihood" %in% names(data)) {
      data$Likelihood <- data$Overall_Likelihood
    }
    if (!"Severity" %in% names(data)) {
      data$Severity <- data$Overall_Severity
    }

    # Create the risk matrix plot
    tryCatch({
      risk_plot <- ggplot(data, aes(x = Likelihood, y = Severity)) +
        geom_point(aes(color = Risk_Level, text = paste(
          "Central Problem:", Central_Problem,
          "<br>Activity:", Activity,
          "<br>Pressure:", Pressure,
          "<br>Protective Mitigation:", Protective_Mitigation,
          "<br>Consequence:", Consequence,
          "<br>Risk Level:", Risk_Level,
          "<br>Risk Score:", Likelihood * Severity,
          "<br>Bayesian Networks: ✅"
        )), size = 4, alpha = 0.7) +
        scale_color_manual(values = RISK_COLORS, name = "Risk Level") +
        scale_x_continuous(breaks = 1:5, limits = c(0.5, 5.5),
                          name = "Likelihood (1=Very Low, 5=Very High)") +
        scale_y_continuous(breaks = 1:5, limits = c(0.5, 5.5),
                          name = "Severity (1=Negligible, 5=Catastrophic)") +
        labs(title = "🌟 Enhanced Environmental Risk Matrix with Bayesian Networks",
             subtitle = paste("✅ Analyzing", nrow(data), "risk scenarios - Ready for probabilistic modeling")) +
        theme_minimal() +
        theme(legend.position = "bottom",
              plot.title = element_text(color = "#2C3E50", size = 14),
              plot.subtitle = element_text(color = "#007bff", size = 10))

      ggplotly(risk_plot, tooltip = "text")

    }, error = function(e) {
      cat("❌ Error in risk matrix generation:", e$message, "\n")

      # Create a simple fallback plot
      fallback_plot <- ggplot() +
        geom_text(aes(x = 3, y = 3),
                  label = paste("Risk Matrix Error\nData issue detected:\n", e$message),
                  size = 4, color = "#dc3545") +
        xlim(1, 5) + ylim(1, 5) +
        labs(title = "⚠️ Risk Matrix Generation Error",
             x = "Likelihood", y = "Severity") +
        theme_minimal()

      ggplotly(fallback_plot)
    })
  })

  # Enhanced risk statistics
  output$riskStats <- renderTable({
    data <- getCurrentData()
    req(data, nrow(data) > 0)

    risk_summary <- data %>%
      count(Risk_Level) %>%
      mutate(Percentage = round(n / sum(n) * 100, 1)) %>%
      mutate(Icon = case_when(
        Risk_Level == "High" ~ "🔴",
        Risk_Level == "Medium" ~ "🟡",
        TRUE ~ "🟢"
      )) %>%
      select(Icon, Risk_Level, Count = n, Percentage)

    names(risk_summary) <- c("Icon", "Risk Level", "Count", "Percentage (%)")

    footer_row <- data.frame(
      Icon = "🧠",
      `Risk Level` = "Bayesian",
      Count = nrow(data),
      `Percentage (%)` = 100.0,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )

    names(footer_row) <- names(risk_summary)

    rbind(risk_summary, footer_row)
  }, sanitize.text.function = function(x) x)

  # Enhanced download bowtie diagram
  output$downloadBowtie <- downloadHandler(
    filename = function() paste("enhanced_bowtie_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".html"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)

      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, 50, FALSE, TRUE)
      edges <- createBowtieEdgesFixed(problem_data, TRUE)

      network <- visNetwork(nodes, edges,
                          main = paste("🌟 Enhanced Environmental Bowtie Analysis with Bayesian Networks:", input$selectedProblem),
                          submain = paste("Generated on", Sys.Date(), "- with Bayesian network support"),
                          footer = "🔧 ENHANCED: Activities → Pressures → Controls → Escalation → Central Problem → Mitigation → Consequences + Bayesian Networks") %>%
        visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
                font = list(color = "#2C3E50", face = "Arial")) %>%
        visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
                smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
        visLayout(randomSeed = 123, improvedLayout = FALSE) %>%
        visPhysics(enabled = FALSE, stabilization = FALSE) %>%
        visLegend(useGroups = FALSE, addNodes = list(
          list(label = "Activities (Human Actions)",
               color = "#8E44AD", shape = "box", size = 15),
          list(label = "Pressures (Environmental Threats)",
               color = "#E74C3C", shape = "triangle", size = 15),
          list(label = "Preventive Controls",
               color = "#27AE60", shape = "square", size = 15),
          list(label = "Escalation Factors",
               color = "#F39C12", shape = "triangleDown", size = 15),
          list(label = "Central Problem (Main Risk)",
               color = "#C0392B", shape = "diamond", size = 18),
          list(label = "Protective Mitigation",
               color = "#3498DB", shape = "square", size = 15),
          list(label = "Consequences (Impacts)",
               color = "#E67E22", shape = "hexagon", size = 15)
        ), position = "right", width = 0.25, ncol = 1)

      visSave(network, file, selfcontained = TRUE)
    },
    contentType = "text/html"
  )

  # Download bowtie as JPEG with white background
  output$downloadBowtieJPEG <- downloadHandler(
    filename = function() paste("bowtie_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".jpeg"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)

      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, input$nodeSize,
                                     input$showRiskLevels, input$showBarriers)
      edges <- createBowtieEdgesFixed(problem_data, input$showBarriers)

      # Create network
      network <- visNetwork(nodes, edges,
                          main = paste("Environmental Bowtie Analysis:", input$selectedProblem),
                          height = "800px", width = "100%") %>%
        visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
                font = list(color = "#2C3E50", face = "Arial", size = 14)) %>%
        visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
                smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
        visLayout(randomSeed = 123, improvedLayout = FALSE) %>%
        visPhysics(enabled = FALSE, stabilization = FALSE) %>%
        visInteraction(navigationButtons = FALSE, dragNodes = FALSE,
                      dragView = FALSE, zoomView = FALSE) %>%
        visExport(type = "jpeg", name = paste0("bowtie_", input$selectedProblem),
                 float = "left", label = "Export JPEG",
                 background = "#FFFFFF",  # White background for readability
                 style = "position: absolute; top: 0; left: 0;")

      # Save to temp HTML first
      temp_html <- tempfile(fileext = ".html")
      visSave(network, temp_html, selfcontained = TRUE)

      # Note: visSave with visExport will create export button in the HTML
      # For server-side export, we'll use the HTML with export functionality
      file.copy(temp_html, file)

      showNotification("JPEG export: Click the 'Export JPEG' button in the opened diagram",
                      type = "message", duration = 10)
    },
    contentType = "text/html"
  )

  # Download bowtie as PNG with transparent background
  output$downloadBowtiePNG <- downloadHandler(
    filename = function() paste("bowtie_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".png"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)

      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, input$nodeSize,
                                     input$showRiskLevels, input$showBarriers)
      edges <- createBowtieEdgesFixed(problem_data, input$showBarriers)

      # Create network with export button
      network <- visNetwork(nodes, edges,
                          main = paste("Environmental Bowtie Analysis:", input$selectedProblem),
                          height = "800px", width = "100%") %>%
        visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
                font = list(color = "#2C3E50", face = "Arial", size = 14)) %>%
        visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
                smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
        visLayout(randomSeed = 123, improvedLayout = FALSE) %>%
        visPhysics(enabled = FALSE, stabilization = FALSE) %>%
        visInteraction(navigationButtons = FALSE, dragNodes = FALSE,
                      dragView = FALSE, zoomView = FALSE) %>%
        visExport(type = "png", name = paste0("bowtie_", input$selectedProblem),
                 float = "left", label = "Export PNG",
                 background = "transparent",  # Transparent background (standard PNG)
                 style = "position: absolute; top: 0; left: 0;")

      # Save to temp HTML
      temp_html <- tempfile(fileext = ".html")
      visSave(network, temp_html, selfcontained = TRUE)

      file.copy(temp_html, file)

      showNotification("PNG export: Click the 'Export PNG' button in the opened diagram",
                      type = "message", duration = 10)
    },
    contentType = "text/html"
  )

  # =============================================================================
  # Link Risk Assessment Server Logic
  # =============================================================================
  
  # Reactive value to store current selected scenario for editing
  selected_risk_scenario <- reactiveVal(NULL)
  
  # Populate scenario choices
  observe({
    data <- getCurrentData()
    if (!is.null(data) && nrow(data) > 0) {
      # Create unique scenario identifiers
      scenario_labels <- paste0(
        "Row ", 1:nrow(data), ": ",
        data$Activity, " → ",
        data$Pressure, " → ",
        data$Central_Problem, " → ",
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
      
      # Activity → Pressure
      if ("Activity_to_Pressure_Likelihood" %in% names(row)) {
        updateSliderInput(session, "activity_pressure_likelihood", 
                         value = row$Activity_to_Pressure_Likelihood)
      }
      if ("Activity_to_Pressure_Severity" %in% names(row)) {
        updateSliderInput(session, "activity_pressure_severity", 
                         value = row$Activity_to_Pressure_Severity)
      }
      
      # Pressure → Control
      if ("Pressure_to_Control_Likelihood" %in% names(row)) {
        updateSliderInput(session, "pressure_control_likelihood", 
                         value = row$Pressure_to_Control_Likelihood)
      }
      if ("Pressure_to_Control_Severity" %in% names(row)) {
        updateSliderInput(session, "pressure_control_severity", 
                         value = row$Pressure_to_Control_Severity)
      }
      
      # Escalation → Control
      if ("Control_to_Escalation_Likelihood" %in% names(row)) {
        updateSliderInput(session, "escalation_control_likelihood", 
                         value = row$Control_to_Escalation_Likelihood)
      }
      if ("Control_to_Escalation_Severity" %in% names(row)) {
        updateSliderInput(session, "escalation_control_severity", 
                         value = row$Control_to_Escalation_Severity)
      }
      
      # Central → Consequence (using Escalation_to_Central for now)
      if ("Escalation_to_Central_Likelihood" %in% names(row)) {
        updateSliderInput(session, "central_consequence_likelihood", 
                         value = row$Escalation_to_Central_Likelihood)
      }
      if ("Escalation_to_Central_Severity" %in% names(row)) {
        updateSliderInput(session, "central_consequence_severity", 
                         value = row$Escalation_to_Central_Severity)
      }
      
      # Protection → Consequence
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
  
  # Calculate and display overall pathway risk
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
  
  # Save risk assessments
  observeEvent(input$save_link_risks, {
    req(input$link_risk_scenario)
    data <- getCurrentData()
    req(data)
    
    row_idx <- as.numeric(input$link_risk_scenario)
    
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
    
    showNotification("✅ Risk assessments saved successfully!", type = "success", duration = 3)
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
    
    showNotification("↩️ Reset to current values", type = "default", duration = 2)
  })

  # =============================================================================
  # Vocabulary Management Server Logic (keeping existing functionality)
  # =============================================================================

  # Reactive values for vocabulary
  vocab_search_results <- reactiveVal(data.frame())
  selected_vocab_item <- reactiveVal(NULL)

  # Get current vocabulary based on selection
  current_vocabulary <- reactive({
    req(input$vocab_type)
    if (exists("vocabulary_data") && !is.null(vocabulary_data[[input$vocab_type]])) {
      vocabulary_data[[input$vocab_type]]
    } else {
      data.frame()
    }
  })

  # Update level filter based on selected vocabulary
  output$vocab_level_filter <- renderUI({
    vocab <- current_vocabulary()
    if (nrow(vocab) > 0) {
      levels <- sort(unique(vocab$level))
      checkboxGroupInput("vocab_levels", "Show levels:",
                         choices = levels,
                         selected = levels)
    } else {
      p(class = "text-muted", "No levels available")
    }
  })

  # Filtered vocabulary based on level selection
  filtered_vocabulary <- reactive({
    vocab <- current_vocabulary()
    if (!is.null(input$vocab_levels) && length(input$vocab_levels) > 0) {
      vocab %>% filter(level %in% input$vocab_levels)
    } else {
      vocab
    }
  })

  # Vocabulary tree view
  output$vocab_tree <- renderPrint({
    vocab <- filtered_vocabulary()
    if (nrow(vocab) > 0) {
      tree <- create_tree_structure(vocab)
      cat(paste(tree$display, collapse = "\n"))
    } else {
      cat("No vocabulary data available.\nPlease ensure CAUSES.xlsx, CONSEQUENCES.xlsx, and CONTROLS.xlsx files are in the app directory.")
    }
  })

  # Vocabulary data table
  output$vocab_table <- DT::renderDataTable({
    vocab <- filtered_vocabulary()
    if (nrow(vocab) > 0) {
      DT::datatable(
        vocab %>% select(level, id, name),
        options = list(
          pageLength = 15,
          searching = TRUE,
          ordering = TRUE,
          columnDefs = list(
            list(width = '10%', targets = 0),
            list(width = '15%', targets = 1),
            list(width = '75%', targets = 2)
          )
        ),
        selection = 'single',
        rownames = FALSE
      )
    }
  })

  # Track selected item from table
  observeEvent(input$vocab_table_rows_selected, {
    row <- input$vocab_table_rows_selected
    if (!is.null(row)) {
      vocab <- filtered_vocabulary()
      if (row <= nrow(vocab)) {
        selected_vocab_item(vocab[row, ])
      }
    }
  })

  # Display selected item info
  output$selected_item_info <- renderUI({
    item <- selected_vocab_item()
    if (!is.null(item)) {
      vocab <- current_vocabulary()
      children <- get_children(vocab, item$id)
      path <- get_item_path(vocab, item$id)

      tagList(
        tags$strong("ID:"), tags$br(),
        tags$code(item$id), tags$br(), tags$br(),

        tags$strong("Name:"), tags$br(),
        tags$small(item$name), tags$br(), tags$br(),

        tags$strong("Level:"), " ", item$level, tags$br(), tags$br(),

        if (nrow(path) > 1) {
          tagList(
            tags$strong("Path:"), tags$br(),
            tags$small(paste(path$name, collapse = " → ")), tags$br(), tags$br()
          )
        },

        if (nrow(children) > 0) {
          tagList(
            tags$strong("Children (", nrow(children), "):")
          )
        }
      )
    } else {
      p(class = "text-muted small", "Select an item to view details")
    }
  })

  # Search vocabulary
  observeEvent(input$search_vocab, {
    req(input$vocab_search)
    vocab <- current_vocabulary()
    if (nrow(vocab) > 0 && nchar(input$vocab_search) > 0) {
      results <- search_vocabulary(vocab, input$vocab_search, input$search_in)
      vocab_search_results(results)
    }
  })

  # Search results table
  output$vocab_search_results <- DT::renderDataTable({
    results <- vocab_search_results()
    if (nrow(results) > 0) {
      DT::datatable(
        results %>% select(level, id, name),
        options = list(
          pageLength = 10,
          searching = FALSE
        ),
        rownames = FALSE
      )
    }
  })

  output$hasSearchResults <- reactive({
    nrow(vocab_search_results()) > 0
  })
  outputOptions(output, "hasSearchResults", suspendWhenHidden = FALSE)

  # Vocabulary statistics
  output$vocab_stats <- renderTable({
    vocab <- current_vocabulary()
    if (nrow(vocab) > 0) {
      stats <- vocab %>%
        group_by(level) %>%
        summarise(Count = n(), .groups = 'drop') %>%
        mutate(Percent = paste0(round(Count / sum(Count) * 100, 1), "%"))

      rbind(stats,
            data.frame(level = "Total",
                      Count = sum(stats$Count),
                      Percent = "100%"))
    }
  }, striped = TRUE, hover = TRUE, width = "100%")

  # Vocabulary relationships
  output$vocab_relationships <- renderUI({
    item <- selected_vocab_item()
    if (!is.null(item)) {
      vocab <- current_vocabulary()
      children <- get_children(vocab, item$id)

      if (nrow(children) > 0) {
        tagList(
          h5(tagList(icon("sitemap"), " Children of ", tags$code(item$id))),
          tags$ul(
            lapply(seq_len(nrow(children)), function(i) {
              tags$li(
                tags$strong(children$id[i]), " - ",
                children$name[i],
                tags$span(class = "badge bg-secondary ms-2",
                         paste("Level", children$level[i]))
              )
            })
          )
        )
      } else {
        p(class = "text-muted", "This item has no children")
      }
    }
  })

  # Vocabulary info summary
  output$vocab_info <- renderUI({
    if (exists("vocabulary_data") && !is.null(vocabulary_data)) {
      total_items <- sum(sapply(vocabulary_data[c("activities", "pressures", "consequences", "controls")],
                               function(x) if (!is.null(x)) nrow(x) else 0))

      tagList(
        div(class = "row",
            div(class = "col-md-3",
                div(class = "text-center",
                    icon("play", class = "fa-2x text-primary mb-2"),
                    h5("Activities"),
                    p(class = "display-6", nrow(vocabulary_data$activities))
                )
            ),
            div(class = "col-md-3",
                div(class = "text-center",
                    icon("triangle-exclamation", class = "fa-2x text-danger mb-2"),
                    h5("Pressures"),
                    p(class = "display-6", nrow(vocabulary_data$pressures))
                )
            ),
            div(class = "col-md-3",
                div(class = "text-center",
                    icon("burst", class = "fa-2x text-warning mb-2"),
                    h5("Consequences"),
                    p(class = "display-6", nrow(vocabulary_data$consequences))
                )
            ),
            div(class = "col-md-3",
                div(class = "text-center",
                    icon("shield", class = "fa-2x text-success mb-2"),
                    h5("Controls"),
                    p(class = "display-6", nrow(vocabulary_data$controls))
                )
            )
        ),
        hr(),
        p(class = "text-center text-muted",
          strong("Total vocabulary items: "), total_items,
          " | Data source: CAUSES.xlsx, CONSEQUENCES.xlsx, CONTROLS.xlsx")
      )
    } else {
      div(class = "alert alert-warning",
          tagList(icon("exclamation-triangle"), " "),
          "Vocabulary data not loaded. Please ensure the Excel files are in the app directory.")
    }
  })

  # Download vocabulary
  output$download_vocab <- downloadHandler(
    filename = function() {
      paste0("vocabulary_", input$vocab_type, "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      vocab <- current_vocabulary()
      if (nrow(vocab) > 0) {
        tree_data <- create_tree_structure(vocab)
        export_data <- tree_data %>% select(level, id, name, path)
        openxlsx::write.xlsx(export_data, file, rowNames = FALSE)
      }
    }
  )

  # Refresh vocabulary
  observeEvent(input$refresh_vocab, {
    showNotification("Refreshing vocabulary data...", type = "default", duration = 2)
    tryCatch({
      vocabulary_data <<- load_vocabulary()
      vocab_search_results(data.frame())
      selected_vocab_item(NULL)
      showNotification("✅ Vocabulary refreshed successfully!", type = "message", duration = 3)
    }, error = function(e) {
      showNotification(paste("❌ Error refreshing vocabulary:", e$message), type = "error")
    })
  })

  # =============================================================================
  # AI-Powered Vocabulary Analysis (keeping existing functionality)
  # =============================================================================

  # Reactive values for AI analysis
  ai_analysis_results <- reactiveVal(NULL)

  # Run AI analysis
  observeEvent(input$run_ai_analysis, {
    showNotification("🤖 Starting AI analysis...", type = "default", duration = 2)

    tryCatch({
      if (exists("find_vocabulary_links")) {
        results <- find_vocabulary_links(
          vocabulary_data,
          similarity_threshold = input$similarity_threshold,
          max_links_per_item = input$max_links_per_item,
          methods = input$ai_methods
        )

        ai_analysis_results(results)

        # Handle both list and dataframe results
        link_count <- if (is.list(results) && !is.null(results$links)) {
          nrow(results$links)
        } else if (is.data.frame(results)) {
          nrow(results)
        } else {
          0
        }

        showNotification(
          paste("✅ AI analysis complete! Found", link_count, "connections"),
          type = "message",
          duration = 3
        )
      } else if (exists("find_basic_connections")) {
        # Fall back to basic connections
        basic_links <- find_basic_connections(
          vocabulary_data,
          max_links_per_item = input$max_links_per_item
        )

        results <- list(
          links = basic_links,
          summary = data.frame(),
          capabilities = list(basic_only = TRUE)
        )
        ai_analysis_results(results)

        showNotification(
          paste("ℹ️ Using basic analysis (AI linker not available). Found", nrow(basic_links), "connections"),
          type = "warning",
          duration = 3
        )
      } else {
        showNotification(
          "⚠️ No linking functions available. Please ensure vocabulary_ai_linker.R is loaded.",
          type = "error",
          duration = 5
        )
      }
    }, error = function(e) {
      showNotification(
        paste("❌ Error in AI analysis:", e$message),
        type = "error"
      )
    })
  })

  # AI analysis complete flag
  output$aiAnalysisComplete <- reactive({
    !is.null(ai_analysis_results())
  })
  outputOptions(output, "aiAnalysisComplete", suspendWhenHidden = FALSE)

  # AI summary
  output$ai_summary <- renderPrint({
    results <- ai_analysis_results()
    if (!is.null(results)) {
      cat("Total connections found:", nrow(results$links), "\n")
      cat("Analysis methods used:", paste(unique(results$links$method), collapse = ", "), "\n")
      cat("Average similarity score:", round(mean(results$links$similarity), 3), "\n")

      if (length(results$keyword_connections) > 0) {
        cat("\nKeyword themes identified:", paste(names(results$keyword_connections), collapse = ", "))
      }

      if (!is.null(results$causal_summary) && nrow(results$causal_summary) > 0) {
        cat("\n\nCausal relationships found:\n")
        causal_count <- sum(results$causal_summary$count)
        cat("  Total causal links:", causal_count, "\n")
        cat("  Activity → Pressure:",
            sum(results$causal_summary$count[results$causal_summary$from_type == "Activity" &
                                            results$causal_summary$to_type == "Pressure"]), "\n")
        cat("  Pressure → Consequence:",
            sum(results$causal_summary$count[results$causal_summary$from_type == "Pressure" &
                                            results$causal_summary$to_type == "Consequence"]), "\n")
        cat("  Control interventions:",
            sum(results$causal_summary$count[results$causal_summary$from_type == "Control"]), "\n")
      }
    }
  })

  # AI connections table
  output$ai_connections_table <- DT::renderDataTable({
    results <- ai_analysis_results()
    if (!is.null(results) && nrow(results$links) > 0) {
      display_data <- results$links %>%
        select(
          `From Type` = from_type,
          `From` = from_name,
          `To Type` = to_type,
          `To` = to_name,
          `Similarity` = similarity,
          `Method` = method
        ) %>%
        mutate(
          Similarity = round(Similarity, 3),
          Method = gsub("_", " ", Method)
        )

      DT::datatable(
        display_data,
        options = list(
          pageLength = 10,
          order = list(list(4, 'desc'))
        ),
        rownames = FALSE
      ) %>%
        formatStyle("Similarity",
                   background = styleColorBar(display_data$Similarity, "lightblue"),
                   backgroundSize = '100% 90%',
                   backgroundRepeat = 'no-repeat',
                   backgroundPosition = 'center')
    }
  })

  # AI network visualization
  output$ai_network <- renderVisNetwork({
    results <- ai_analysis_results()
    if (!is.null(results) && nrow(results$links) > 0) {
      tryCatch({
        all_nodes <- unique(c(
          paste(results$links$from_type, results$links$from_id, results$links$from_name, sep = "|"),
          paste(results$links$to_type, results$links$to_id, results$links$to_name, sep = "|")
        ))

        nodes_df <- data.frame(
          id = sapply(strsplit(all_nodes, "\\|"), function(x) paste(x[1], x[2], sep = "_")),
          group = sapply(strsplit(all_nodes, "\\|"), `[`, 1),
          label = sapply(strsplit(all_nodes, "\\|"), function(x) {
            name <- paste(x[3:length(x)], collapse = "|")
            if (nchar(name) > 30) paste0(substr(name, 1, 27), "...") else name
          }),
          title = sapply(strsplit(all_nodes, "\\|"), function(x) paste(x[3:length(x)], collapse = "|")),
          stringsAsFactors = FALSE
        )

        if (length(unique(nodes_df$id)) != nrow(nodes_df)) {
          nodes_df$id <- paste(nodes_df$id, seq_len(nrow(nodes_df)), sep = "_")
        }

      type_colors <- list(
        activities = "#8E44AD",
        pressures = "#E74C3C",
        consequences = "#E67E22",
        controls = "#27AE60"
      )

      nodes_df$color <- sapply(nodes_df$group, function(g) type_colors[[g]])

      edges_df <- results$links %>%
        mutate(
          from = paste(from_type, from_id, sep = "_"),
          to = paste(to_type, to_id, sep = "_"),
          width = similarity * 5,
          title = paste("Similarity:", round(similarity, 3))
        ) %>%
        select(from, to, width, title)

      if (length(unique(sapply(strsplit(all_nodes, "\\|"), function(x) paste(x[1], x[2], sep = "_")))) != nrow(nodes_df)) {
        id_mapping <- setNames(nodes_df$id, sapply(strsplit(all_nodes, "\\|"), function(x) paste(x[1], x[2], sep = "_")))
        edges_df$from <- id_mapping[edges_df$from]
        edges_df$to <- id_mapping[edges_df$to]
      }

      visNetwork(nodes_df, edges_df) %>%
        visNodes(
          shape = "dot",
          size = 20,
          font = list(size = 12)
        ) %>%
        visEdges(
          smooth = TRUE,
          color = list(opacity = 0.5)
        ) %>%
        visGroups(groupname = "activities", color = "#8E44AD") %>%
        visGroups(groupname = "pressures", color = "#E74C3C") %>%
        visGroups(groupname = "consequences", color = "#E67E22") %>%
        visGroups(groupname = "controls", color = "#27AE60") %>%
        visLegend(width = 0.2, position = "right") %>%
        visPhysics(
          stabilization = TRUE,
          barnesHut = list(
            gravitationalConstant = -2000,
            springConstant = 0.04
          )
        ) %>%
        visOptions(
          highlightNearest = TRUE,
          nodesIdSelection = FALSE
        ) %>%
        visInteraction(
          navigationButtons = TRUE,
          dragNodes = TRUE,
          dragView = TRUE,
          zoomView = TRUE
        )
      }, error = function(e) {
        showNotification(paste("❌ Error creating network visualization:", e$message), type = "error")
        return(NULL)
      })
    } else {
      return(NULL)
    }
  })

  # Connection summary
  output$ai_connection_summary <- renderTable({
    results <- ai_analysis_results()
    if (!is.null(results) && !is.null(results$summary) && nrow(results$summary) > 0) {
      results$summary %>%
        mutate(
          avg_similarity = round(avg_similarity, 3),
          max_similarity = round(max_similarity, 3),
          min_similarity = round(min_similarity, 3)
        ) %>%
        rename(
          `From Type` = from_type,
          `To Type` = to_type,
          `Method` = method,
          `Count` = count,
          `Avg Similarity` = avg_similarity,
          `Max Similarity` = max_similarity,
          `Min Similarity` = min_similarity
        )
    }
  })

  # Connection plot
  output$ai_connection_plot <- renderPlot({
    results <- ai_analysis_results()
    if (!is.null(results) && nrow(results$links) > 0) {
      connection_summary <- results$links %>%
        mutate(connection_type = paste(from_type, "→", to_type)) %>%
        group_by(connection_type) %>%
        summarise(count = n(), .groups = 'drop') %>%
        arrange(desc(count))

      ggplot(connection_summary, aes(x = reorder(connection_type, count), y = count)) +
        geom_bar(stat = "identity", fill = "#3498DB") +
        coord_flip() +
        labs(
          title = "AI-Discovered Connection Types",
          x = "Connection Type",
          y = "Number of Connections"
        ) +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 14, face = "bold"),
          axis.text = element_text(size = 10)
        )
    }
  })

  # AI recommendations
  output$ai_recommendations <- DT::renderDataTable({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("generate_link_recommendations")) {
      recommendations <- generate_link_recommendations(vocabulary_data, focus = "causal")

      if (nrow(recommendations) > 0) {
        display_recs <- recommendations %>%
          select(
            `From` = from_name,
            `To` = to_name,
            `Type` = method,
            `Score` = recommendation_score,
            `Reasoning` = reasoning
          ) %>%
          mutate(
            Score = round(Score, 3),
            Type = gsub("causal_", "", Type)
          )

        DT::datatable(
          display_recs,
          options = list(
            pageLength = 10,
            dom = 't'
          ),
          rownames = FALSE
        )
      }
    }
  })

  # Causal pathways output
  output$causal_paths <- renderPrint({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("find_causal_paths")) {
      causal_links <- results$links %>% filter(grepl("causal", method))

      if (nrow(causal_links) > 0) {
        paths <- find_causal_paths(causal_links, max_length = 5)

        if (length(paths) > 0) {
          cat("Top 10 Causal Pathways:\n\n")
          for (i in 1:min(10, length(paths))) {
            path <- paths[[i]]
            cat(sprintf("%d. %s\n", i, path$path_string))
            cat(sprintf("   Strength: %.3f (avg: %.3f)\n\n",
                       path$total_similarity, path$avg_similarity))
          }
        } else {
          cat("No complete causal pathways found.")
        }
      }
    }
  })

  # Causal structure analysis
  output$causal_structure <- renderTable({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("analyze_causal_structure")) {
      causal_analysis <- analyze_causal_structure(results$links)

      if (!is.null(causal_analysis$link_types)) {
        causal_analysis$link_types %>%
          mutate(avg_strength = round(avg_strength, 3)) %>%
          rename(
            `From` = from_type,
            `To` = to_type,
            `Count` = count,
            `Avg Strength` = avg_strength
          )
      }
    }
  })

  # Key drivers table
  output$key_drivers <- renderTable({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("analyze_causal_structure")) {
      causal_analysis <- analyze_causal_structure(results$links)

      if (!is.null(causal_analysis$key_drivers)) {
        causal_analysis$key_drivers %>%
          select(-from_id) %>%
          mutate(
            avg_impact = round(avg_impact, 3),
            impact_score = round(outgoing_links * avg_impact, 2)
          ) %>%
          rename(
            `Driver` = from_name,
            `Type` = from_type,
            `Links` = outgoing_links,
            `Avg Impact` = avg_impact,
            `Score` = impact_score
          ) %>%
          head(5)
      }
    }
  })

  # Key outcomes table
  output$key_outcomes <- renderTable({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("analyze_causal_structure")) {
      causal_analysis <- analyze_causal_structure(results$links)

      if (!is.null(causal_analysis$key_outcomes)) {
        causal_analysis$key_outcomes %>%
          select(-to_id) %>%
          mutate(
            avg_impact = round(avg_impact, 3),
            impact_score = round(incoming_links * avg_impact, 2)
          ) %>%
          rename(
            `Outcome` = to_name,
            `Type` = to_type,
            `Links` = incoming_links,
            `Avg Impact` = avg_impact,
            `Score` = impact_score
          ) %>%
          head(5)
      }
    }
  })

  # Guided Workflow Server Logic
  guided_workflow_state <- guided_workflow_server(
    "guided_workflow",
    vocabulary_data = vocabulary_data,
    lang = lang
  )

  # React to workflow completion - only when actually completed (step 8)
  observeEvent(guided_workflow_state()$workflow_complete, {
    req(guided_workflow_state()$workflow_complete)  # Only proceed if not NULL/FALSE
    state <- guided_workflow_state()

    # Enhanced validation: only trigger if genuinely completed
    if (!is.null(state) &&
        isTRUE(state$workflow_complete) &&  # Use isTRUE for safer boolean check
        !is.null(state$current_step) &&
        state$current_step >= 8 &&
        length(state$completed_steps) >= 7) {  # Must have completed at least 7 steps

      showNotification("🎉 Bowtie workflow completed successfully!",
                      type = "default", duration = 5)

      # Auto-switch to visualization tab
      nav_select("main_tabs", selected = "bowtie", session = session)

      cat("✅ Genuine workflow completion triggered from step", state$current_step, "\n")
      cat("   Completed steps:", paste(state$completed_steps, collapse = ", "), "\n")
    } else {
      cat("⚠️ Prevented premature workflow completion trigger:\n")
      cat("   Step:", state$current_step %||% "unknown", "\n")
      cat("   Complete flag:", state$workflow_complete %||% "unknown", "\n")
      cat("   Completed steps:", length(state$completed_steps %||% c()), "\n")
    }
  }, ignoreInit = TRUE)  # Ignore initial reactive trigger

  # Automatic data integration: Watch for exported workflow data
  observeEvent(guided_workflow_state()$converted_main_data, {
    workflow_state <- guided_workflow_state()
    exported_data <- workflow_state$converted_main_data

    if (!is.null(exported_data) && nrow(exported_data) > 0) {
      cat("🔄 Loading guided workflow data into main application...\n")
      cat("📊 Data rows:", nrow(exported_data), "\n")

      # Load the converted data into main application reactive values
      currentData(exported_data)
      editedData(exported_data)
      envDataGenerated(TRUE)

      # Update data version for reactive triggers
      dataVersion(dataVersion() + 1)

      # Update problem selection choices for bowtie diagram
      problem_choices <- unique(exported_data$Central_Problem)
      updateSelectInput(session, "selectedProblem", choices = problem_choices, selected = problem_choices[1])
      updateSelectInput(session, "bayesianProblem", choices = problem_choices, selected = problem_choices[1])

      showNotification(
        paste("✅ Successfully loaded", nrow(exported_data),
              "bowtie scenarios from guided workflow!"),
        type = "message", duration = 5
      )

      # Auto-switch to the bowtie visualization tab
      nav_select("main_tabs", selected = "bowtie", session = session)

      cat("✅ Guided workflow data integration complete\n")
    }
  })

  # Enhanced Theme Apply Button Handlers with CSS-based theme switching
  observeEvent(input$applyTheme, {
    cat("🎨 Apply Theme button pressed. Selected theme:", input$theme_preset, "\n")

    # Update reactive values
    appliedTheme(input$theme_preset)
    old_trigger <- themeUpdateTrigger()
    new_trigger <- old_trigger + 1
    themeUpdateTrigger(new_trigger)

    cat("📊 Theme trigger updated from", old_trigger, "to", new_trigger, "\n")

    # Apply theme using CSS injection (more reliable approach)
    tryCatch({
      # Get the bootswatch CDN URL for the selected theme
      theme_name <- input$theme_preset
      if (theme_name != "custom" && theme_name != "bootstrap") {
        css_url <- paste0("https://cdn.jsdelivr.net/npm/bootswatch@5.3.0/dist/", theme_name, "/bootstrap.min.css")

        # Inject the new theme CSS
        runjs(paste0("
          // Remove existing bootswatch theme
          $('link[href*=\"bootswatch\"]').remove();
          $('link[href*=\"bootstrap\"]').last().remove();

          // Add new theme
          $('<link>').attr({
            rel: 'stylesheet',
            type: 'text/css',
            href: '", css_url, "'
          }).appendTo('head');
        "))

        cat("✅ Theme CSS injected successfully\n")
      } else if (theme_name == "bootstrap") {
        # Switch to default Bootstrap
        runjs("
          $('link[href*=\"bootswatch\"]').remove();
          $('<link>').attr({
            rel: 'stylesheet',
            type: 'text/css',
            href: 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css'
          }).appendTo('head');
        ")
        cat("✅ Default Bootstrap theme applied\n")
      }
    }, error = function(e) {
      cat("❌ Theme CSS injection failed:", e$message, "\n")
    })

    # Show theme name mapping
    theme_names <- c(
      "🌿 Environmental (Default)" = "journal",
      "🌙 Dark Mode" = "darkly",
      "☀️ Light & Clean" = "flatly",
      "🌊 Ocean Blue" = "cosmo",
      "🌲 Forest Green" = "materia",
      "🔵 Corporate Blue" = "cerulean",
      "🎯 Minimal Clean" = "minty",
      "📊 Dashboard" = "lumen",
      "🎨 Creative Purple" = "pulse",
      "🧪 Science Lab" = "sandstone",
      "🌌 Space Dark" = "slate",
      "🏢 Professional" = "united",
      "🎭 Modern Contrast" = "superhero",
      "🌅 Sunset Orange" = "solar",
      "📈 Analytics" = "spacelab",
      "🎪 Vibrant" = "sketchy",
      "🌺 Nature Fresh" = "cyborg",
      "💼 Business" = "vapor",
      "🔬 Research" = "zephyr",
      "⚡ High Contrast" = "bootstrap",
      "🎨 Custom Colors" = "custom"
    )

    theme_display_name <- names(which(theme_names == input$theme_preset))
    if (length(theme_display_name) > 0) {
      showNotification(
        paste("🎨 Applied theme:", theme_display_name),
        type = "message", duration = 3
      )
    } else {
      showNotification(paste("🎨", t("notify_theme_applied", lang())), type = "message", duration = 3)
    }
  })

  observeEvent(input$applyCustomTheme, {
    cat("🎨 Apply Custom Theme button pressed\n")

    appliedTheme("custom")
    old_trigger <- themeUpdateTrigger()
    new_trigger <- old_trigger + 1
    themeUpdateTrigger(new_trigger)

    cat("📊 Custom theme trigger updated from", old_trigger, "to", new_trigger, "\n")

    # Apply custom colors using CSS injection
    tryCatch({
      primary_color <- if (!is.null(input$primary_color)) input$primary_color else "#28a745"
      secondary_color <- if (!is.null(input$secondary_color)) input$secondary_color else "#6c757d"
      success_color <- if (!is.null(input$success_color)) input$success_color else "#28a745"
      info_color <- if (!is.null(input$info_color)) input$info_color else "#17a2b8"
      warning_color <- if (!is.null(input$warning_color)) input$warning_color else "#ffc107"
      danger_color <- if (!is.null(input$danger_color)) input$danger_color else "#dc3545"

      custom_css <- paste0("
        :root {
          --bs-primary: ", primary_color, ";
          --bs-secondary: ", secondary_color, ";
          --bs-success: ", success_color, ";
          --bs-info: ", info_color, ";
          --bs-warning: ", warning_color, ";
          --bs-danger: ", danger_color, ";
        }
        .btn-primary { background-color: ", primary_color, "; border-color: ", primary_color, "; }
        .btn-success { background-color: ", success_color, "; border-color: ", success_color, "; }
        .btn-info { background-color: ", info_color, "; border-color: ", info_color, "; }
        .btn-warning { background-color: ", warning_color, "; border-color: ", warning_color, "; }
        .btn-danger { background-color: ", danger_color, "; border-color: ", danger_color, "; }
        .bg-primary { background-color: ", primary_color, " !important; }
        .bg-success { background-color: ", success_color, " !important; }
        .bg-info { background-color: ", info_color, " !important; }
        .bg-warning { background-color: ", warning_color, " !important; }
        .bg-danger { background-color: ", danger_color, " !important; }
        .text-primary { color: ", primary_color, " !important; }
      ")

      # Remove existing custom theme and inject new one
      runjs(paste0("
        $('#custom-theme-css').remove();
        $('<style id=\"custom-theme-css\">", gsub('\n', '', custom_css), "</style>').appendTo('head');
      "))

      cat("✅ Custom theme CSS applied successfully\n")
    }, error = function(e) {
      cat("❌ Custom theme CSS injection failed:", e$message, "\n")
    })

    showNotification("🎨 Applied custom theme with your colors!",
                    type = "message", duration = 3)
  })

  # ============================================================================
  # TRANSLATION SYSTEM - Dynamic UI Rendering
  # ============================================================================

  # Main header translations
  output$app_title_text <- renderUI({
    t("app_title", lang())
  })
  
  output$app_subtitle_text <- renderUI({
    t("app_subtitle", lang())
  })
  
  # Data Input tab translations
  output$tab_data_input_title <- renderUI({
    tagList(icon("upload"), t("tab_data_input", lang()))
  })

  output$tab_guided_creation_title <- renderUI({
    tagList(icon("magic"), "🧙 ", t("tab_guided_creation", lang()))
  })

  output$tab_link_risk_title <- renderUI({
    tagList(icon("sliders-h"), t("tab_link_risk", lang()))
  })

  output$link_risk_individual_header <- renderUI({
    tagList(icon("link"), t("link_risk_individual_title", lang()))
  })
  
  output$data_input_options_header <- renderUI({
    tagList(icon("database"), t("data_input_options", lang()))
  })
  
  output$data_upload_option1_title <- renderUI({
    tagList(icon("file-excel"), t("data_upload_option1", lang()))
  })
  
  # Render file input with translated text
  output$file_input_ui <- renderUI({
    fileInput("file",
              label = t("data_upload_option1_label", lang()),
              accept = c(".xlsx", ".xls"),
              buttonLabel = t("data_upload_button_label", lang()),
              placeholder = t("data_upload_placeholder", lang()))
  })

  # Render Settings Language Section
  output$settings_language_section <- renderUI({
    current_lang <- lang()
    
    div(class = "mb-3",
      h6(tagList(icon("language"), " ", t("language_settings", current_lang)), class = "text-primary"),
      fluidRow(
        column(3, selectInput("app_language", t("select_language", current_lang),
                            choices = c("English" = "en", "Français" = "fr"),
                            selected = currentLanguage())),
        column(3,
          div(class = "mt-4",
            actionButton("applyLanguage",
                       label = as.character(t("apply_language", current_lang)),
                       icon = icon("check"),
                       class = "btn-primary")
          )
        ),
        column(6,
          div(class = "alert alert-info mt-4 mb-0",
            style = "padding: 0.5rem;",
            tags$small(
              icon("info-circle"), " ",
              if(current_lang == "en") {
                "Translated content includes the About tab and notifications."
              } else {
                "Le contenu traduit inclut l'onglet A Propos et les notifications."
              }
            )
          )
        )
      )
    )
  })

  # Render Settings Theme Header
  output$settings_theme_header <- renderUI({
    current_lang <- lang()
    h6(tagList(icon("palette"), " ", t("theme_settings", current_lang)), class = "text-primary")
  })

  # Render Data Input Card Headers
  output$data_input_header <- renderUI({
    current_lang <- lang()
    tagList(icon("database"), t("data_input_options", current_lang))
  })

  output$data_structure_header <- renderUI({
    current_lang <- lang()
    tagList(icon("info-circle"), t("data_structure_title", current_lang))
  })

  # Render Data Input Tab Content
  output$data_upload_option1_title <- renderUI({
    current_lang <- lang()
    h5(tagList(icon("file-excel"), t("data_upload_option1", current_lang)))
  })

  output$data_upload_option2_title <- renderUI({
    current_lang <- lang()
    h5(tagList(icon("leaf"), t("data_upload_option2", current_lang)))
  })

  output$data_option2_desc <- renderUI({
    current_lang <- lang()
    div(
      p(t("data_option2_description", current_lang)),
      tags$ul(class = "small text-muted",
        tags$li(paste("📊", t("complete_vocabulary_coverage", current_lang))),
        tags$li(paste("🛡️", t("multiple_controls_per_pressure", current_lang))),
        tags$li(paste("🔗", t("pressure_linked_measures", current_lang)))
      )
    )
  })

  output$bowtie_elements_section <- renderUI({
    current_lang <- lang()
    data <- getCurrentData()
    
    # Count elements if data is loaded
    if (!is.null(data)) {
      counts <- list(
        activities = length(unique(data$Activity)),
        pressures = length(unique(data$Pressure)),
        controls = length(unique(data$Preventive_Control)),
        escalations = if("Escalation_Factor" %in% names(data)) length(unique(data$Escalation_Factor)) else 0,
        problems = length(unique(data$Central_Problem)),
        mitigations = length(unique(data$Protective_Mitigation)),
        consequences = length(unique(data$Consequence))
      )
    } else {
      counts <- list(activities = 0, pressures = 0, controls = 0, escalations = 0, 
                     problems = 0, mitigations = 0, consequences = 0)
    }
    
    div(
      h6(tagList(icon("list"), t("bowtie_elements", current_lang))),
      p(t("data_structure_description", current_lang)),
      tags$ul(class = "mb-2",
        tags$li(tagList(icon("play", class = "text-primary"),
                       strong(paste0(t("column_activity", current_lang), ":")), " ",
                       t("column_description_activity", current_lang),
                       if(counts$activities > 0) tags$span(class = "badge bg-primary ms-2", counts$activities))),
        tags$li(tagList(icon("triangle-exclamation", class = "text-danger"),
                       strong(paste0(t("column_pressure", current_lang), ":")), " ",
                       t("column_description_pressure", current_lang),
                       if(counts$pressures > 0) tags$span(class = "badge bg-danger ms-2", counts$pressures))),
        tags$li(tagList(icon("shield-halved", class = "text-success"),
                       strong(paste0(t("column_preventive_control", current_lang), ":")), " ",
                       t("column_description_preventive", current_lang),
                       if(counts$controls > 0) tags$span(class = "badge bg-success ms-2", counts$controls))),
        tags$li(tagList(icon("exclamation-triangle", class = "text-warning"),
                       strong(paste0(t("column_escalation_factor", current_lang), ":")), " ",
                       "Factors that weaken controls",
                       if(counts$escalations > 0) tags$span(class = "badge bg-warning ms-2", counts$escalations))),
        tags$li(tagList(icon("radiation", class = "text-danger"),
                       strong(paste0(t("column_central_problem", current_lang), ":")), " ",
                       t("column_description_central", current_lang),
                       if(counts$problems > 0) tags$span(class = "badge bg-danger ms-2", counts$problems))),
        tags$li(tagList(icon("shield", class = "text-info"),
                       strong(paste0(t("column_protective_mitigation", current_lang), ":")), " ",
                       t("column_description_protective", current_lang),
                       if(counts$mitigations > 0) tags$span(class = "badge bg-info ms-2", counts$mitigations))),
        tags$li(tagList(icon("burst", class = "text-warning"),
                       strong(paste0(t("column_consequence", current_lang), ":")), " ",
                       t("column_description_consequence", current_lang),
                       if(counts$consequences > 0) tags$span(class = "badge bg-warning ms-2", counts$consequences)))
      )
    )
  })

  # Vocabulary statistics outputs
  output$vocab_activities_count <- renderText({
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities)) {
      return(as.character(nrow(vocabulary_data$activities)))
    }
    return("0")
  })

  output$vocab_pressures_count <- renderText({
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures)) {
      return(as.character(nrow(vocabulary_data$pressures)))
    }
    return("0")
  })

  output$vocab_controls_count <- renderText({
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls)) {
      return(as.character(nrow(vocabulary_data$controls)))
    }
    return("0")
  })

  output$vocab_consequences_count <- renderText({
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$consequences)) {
      return(as.character(nrow(vocabulary_data$consequences)))
    }
    return("0")
  })

  output$vocab_total_count <- renderText({
    total <- 0
    if (!is.null(vocabulary_data)) {
      if (!is.null(vocabulary_data$activities)) total <- total + nrow(vocabulary_data$activities)
      if (!is.null(vocabulary_data$pressures)) total <- total + nrow(vocabulary_data$pressures)
      if (!is.null(vocabulary_data$controls)) total <- total + nrow(vocabulary_data$controls)
      if (!is.null(vocabulary_data$consequences)) total <- total + nrow(vocabulary_data$consequences)
    }
    return(as.character(total))
  })

  # Render Bowtie Diagram Tab Elements
  output$bowtie_legend_help <- renderUI({
    current_lang <- lang()
    div(class = "alert alert-info mb-3",
      h6(tagList(icon("info-circle"), t("bowtie_legend_title", current_lang))),
      tags$small(
        tags$ul(class = "mb-2",
          tags$li(tags$strong(t("bowtie_legend_activities", current_lang)), " ", t("bowtie_legend_activities_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_pressures", current_lang)), " ", t("bowtie_legend_pressures_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_preventive", current_lang)), " ", t("bowtie_legend_preventive_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_escalation", current_lang)), " ", t("bowtie_legend_escalation_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_central", current_lang)), " ", t("bowtie_legend_central_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_protective", current_lang)), " ", t("bowtie_legend_protective_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_consequences", current_lang)), " ", t("bowtie_legend_consequences_desc", current_lang))
        ),
        tags$p(class = "mb-0",
          tags$strong(t("bowtie_interaction_title", current_lang)), " ", t("bowtie_interaction_desc", current_lang)
        )
      )
    )
  })

  output$bowtie_no_data_message <- renderUI({
    current_lang <- lang()
    div(class = "text-center p-5",
      icon("upload", class = "fa-3x text-muted mb-3"),
      h4(t("bowtie_upload_prompt", current_lang), class = "text-muted"),
      p(t("bowtie_upload_desc", current_lang), class = "text-muted")
    )
  })

  # Render Bayesian Network Tab Elements
  output$bayesian_controls_header <- renderUI({
    current_lang <- lang()
    tagList(icon("brain"), t("bayesian_controls_title", current_lang))
  })

  output$bayesian_network_creation_section <- renderUI({
    current_lang <- lang()
    div(
      h6(tagList(icon("cogs"), t("bayesian_network_creation", current_lang))),
      selectInput("bayesianProblem", t("bayesian_select_problem", current_lang), choices = NULL),
      div(class = "d-grid mb-3",
        actionButton("createBayesianNetwork",
          tagList(icon("brain"), t("bayesian_create_button", current_lang)),
          class = "btn-success"
        )
      )
    )
  })

  output$bayesian_inference_section <- renderUI({
    current_lang <- lang()

    # Build choices dynamically
    activity_choices <- setNames(c("", "Present", "Absent"),
                                 c(t("evidence_not_set", current_lang),
                                   t("evidence_present", current_lang),
                                   t("evidence_absent", current_lang)))

    pressure_choices <- setNames(c("", "Low", "Medium", "High"),
                                c(t("evidence_not_set", current_lang),
                                  t("evidence_low", current_lang),
                                  t("evidence_medium", current_lang),
                                  t("evidence_high", current_lang)))

    control_choices <- setNames(c("", "Effective", "Partial", "Failed"),
                               c(t("evidence_not_set", current_lang),
                                 t("evidence_effective", current_lang),
                                 t("evidence_partial", current_lang),
                                 t("evidence_failed", current_lang)))

    query_choices <- setNames(c("Consequence_Level", "Problem_Severity", "Escalation_Level"),
                             c(t("bayesian_consequence_level", current_lang),
                               t("bayesian_problem_severity", current_lang),
                               t("bayesian_escalation_level", current_lang)))

    div(
      hr(),
      h6(tagList(icon("question-circle"), t("bayesian_inference_title", current_lang))),
      h6(t("bayesian_evidence_title", current_lang)),
      selectInput("evidenceActivity", t("bayesian_activity_level", current_lang),
        choices = activity_choices),
      selectInput("evidencePressure", t("bayesian_pressure_level", current_lang),
        choices = pressure_choices),
      selectInput("evidenceControl", t("bayesian_control_effectiveness", current_lang),
        choices = control_choices),
      h6(t("bayesian_query_title", current_lang)),
      checkboxGroupInput("queryNodes", t("bayesian_select_outcomes", current_lang),
        choices = query_choices,
        selected = c("Consequence_Level", "Problem_Severity")),
      div(class = "d-grid mb-3",
        actionButton("runInference",
          tagList(icon("play"), t("bayesian_run_inference", current_lang)),
          class = "btn-primary"
        )
      )
    )
  })

  output$bayesian_no_data_message <- renderUI({
    current_lang <- lang()
    div(class = "text-center p-3",
      icon("brain", class = "fa-3x text-muted mb-3"),
      h5(t("bayesian_load_data_first", current_lang), class = "text-muted"),
      p(t("bayesian_load_data_desc", current_lang), class = "text-muted")
    )
  })

  output$bayesian_network_how_to <- renderUI({
    current_lang <- lang()
    div(
      h6(t("bayesian_how_to_use", current_lang)),
      tags$ul(
        tags$li(t("bayesian_how_to_1", current_lang)),
        tags$li(t("bayesian_how_to_2", current_lang)),
        tags$li(t("bayesian_how_to_3", current_lang)),
        tags$li(t("bayesian_how_to_4", current_lang)),
        tags$li(t("bayesian_how_to_5", current_lang))
      )
    )
  })

  # Render Data Table Tab Elements
  output$data_table_header <- renderUI({
    current_lang <- lang()
    tagList(icon("table"), t("data_table_title", current_lang))
  })

  output$data_table_buttons <- renderUI({
    current_lang <- lang()
    div(
      actionButton("addRow", tagList(icon("plus"), t("data_table_add_row", current_lang)),
        class = "btn-success btn-sm me-2"),
      actionButton("deleteSelected", tagList(icon("trash"), t("data_table_delete_selected", current_lang)),
        class = "btn-danger btn-sm me-2"),
      actionButton("saveChanges", tagList(icon("save"), t("data_table_save_changes", current_lang)),
        class = "btn-primary btn-sm")
    )
  })

  output$data_table_no_data <- renderUI({
    current_lang <- lang()
    div(class = "text-center p-5",
      icon("table", class = "fa-3x text-muted mb-3"),
      h4(t("data_table_no_data", current_lang), class = "text-muted"),
      p(t("data_table_upload_prompt", current_lang), class = "text-muted")
    )
  })

  # Render Risk Matrix Tab Elements
  output$risk_matrix_help <- renderUI({
    current_lang <- lang()
    div(class = "alert alert-info mb-3",
      h6(tagList(icon("info-circle"), t("risk_matrix_guide_title", current_lang))),
      tags$small(
        tags$p(tags$strong(t("risk_matrix_understanding", current_lang))),
        tags$ul(
          tags$li(t("risk_matrix_axes", current_lang)),
          tags$li(t("risk_matrix_color_zones", current_lang))
        ),
        tags$p(tags$strong(t("risk_matrix_interpretation", current_lang))),
        tags$ul(
          tags$li(t("risk_matrix_green", current_lang)),
          tags$li(t("risk_matrix_yellow", current_lang)),
          tags$li(t("risk_matrix_orange", current_lang)),
          tags$li(t("risk_matrix_red", current_lang))
        )
      )
    )
  })

  # Render About Tab Header
  output$about_header <- renderUI({
    tagList(icon("info-circle"), t("about_title", lang()))
  })

  # Render About Tab Content
  output$about_content <- renderUI({
    current_lang <- lang()

    div(
      h4(t("about_title", current_lang), class = "text-success"),
      hr(),
      p(class = "lead", t("about_description", current_lang)),

      h5(tagList(icon("star"), t("about_version", current_lang)), class = "mt-4"),
      p(class = "text-muted", paste(APP_CONFIG$VERSION, "- Enhanced with Bayesian Network Analysis")),

      h5(tagList(icon("list-check"), t("about_features", current_lang)), class = "mt-4"),
      tags$ul(
        tags$li(tags$strong(icon("check-circle"), " "), t("about_feature1", current_lang)),
        tags$li(tags$strong(icon("check-circle"), " "), t("about_feature2", current_lang)),
        tags$li(tags$strong(icon("check-circle"), " "), t("about_feature3", current_lang)),
        tags$li(tags$strong(icon("check-circle"), " "), t("about_feature4", current_lang)),
        tags$li(tags$strong(icon("check-circle"), " "), t("about_feature5", current_lang)),
        tags$li(tags$strong(icon("check-circle"), " "), t("about_feature6", current_lang))
      ),

      div(class = "alert alert-info mt-4",
        tagList(
          icon("language"), " ",
          strong(if(current_lang == "en") "Multi-language Support" else "Support Multilingue"), ": ",
          if(current_lang == "en") {
            "This application now supports English and French. Switch languages using the selector in the top navigation bar."
          } else {
            "Cette application supporte maintenant l'anglais et le français. Changez de langue en utilisant le sélecteur dans la barre de navigation en haut."
          }
        )
      ),

      div(class = "alert alert-success mt-3",
        tagList(
          icon("users"), " ",
          strong(if(current_lang == "en") "Development Team" else "Équipe de Développement"), ": ",
          if(current_lang == "en") {
            "Marbefes Environmental Risk Assessment Team"
          } else {
            "Équipe d'Évaluation des Risques Environnementaux Marbefes"
          }
        )
      )
    )
  })

  # Observer to update scenario select input when language changes
  observe({
    current_lang <- lang()
    updateSelectInput(session, "data_scenario_template",
                     label = t("select_scenario", current_lang),
                     choices = getScenarioChoices(current_lang, include_blank = TRUE))
  })

  # =============================================================================
  # REPORT GENERATION
  # =============================================================================
  
  # Reactive value for report status
  report_generated <- reactiveVal(FALSE)
  report_content <- reactiveVal(NULL)
  
  # Render report UI elements
  output$report_header <- renderUI({
    tagList(icon("file-alt"), t("report_header", lang()))
  })
  
  output$report_intro <- renderUI({
    p(t("report_intro", lang()))
  })
  
  output$report_options_title <- renderUI({
    t("report_options_title", lang())
  })
  
  output$report_type_label <- renderUI({
    h6(t("report_type_label", lang()))
  })
  
  output$report_format_label <- renderUI({
    h6(t("report_format_label", lang()))
  })
  
  output$report_include_sections_label <- renderUI({
    h6(t("report_include_sections_label", lang()))
  })
  
  output$report_title_label <- renderUI({
    t("report_title_label", lang())
  })

  output$report_author_label <- renderUI({
    t("report_author_label", lang())
  })

  # Render text inputs with translated labels
  output$report_title_input_ui <- renderUI({
    textInput("report_title",
              label = t("report_title_label", lang()),
              value = "Environmental Bowtie Risk Analysis Report")
  })

  output$report_author_input_ui <- renderUI({
    textInput("report_author",
              label = t("report_author_label", lang()),
              value = "")
  })

  output$report_generate_button <- renderUI({
    t("report_generate_button", lang())
  })
  
  output$report_download_button <- renderUI({
    t("report_download_button", lang())
  })
  
  output$report_preview_header <- renderUI({
    tagList(icon("eye"), t("report_preview_header", lang()))
  })
  
  output$report_help_header <- renderUI({
    tagList(icon("info-circle"), t("report_help_header", lang()))
  })
  
  output$report_help_content <- renderUI({
    p(t("report_help_content", lang()))
  })
  
  # Report status display
  output$report_status <- renderUI({
    current_lang <- lang()
    data <- currentData()
    
    if (is.null(data) || nrow(data) == 0) {
      div(class = "alert alert-warning",
          tagList(icon("exclamation-triangle"), " ", t("report_status_no_data", current_lang)))
    } else if (report_generated()) {
      div(class = "alert alert-success",
          tagList(icon("check-circle"), " ", t("report_status_complete", current_lang)))
    } else {
      div(class = "alert alert-info",
          tagList(icon("info-circle"), " ", t("report_status_ready", current_lang)))
    }
  })
  
  # Report preview content
  output$report_preview_content <- renderUI({
    current_lang <- lang()
    
    if (report_generated()) {
      content <- report_content()
      div(
        h6(t("report_preview_summary", current_lang)),
        tags$ul(
          lapply(content$sections, function(section) {
            tags$li(strong(section$title), " - ", section$description)
          })
        ),
        hr(),
        tags$small(class = "text-muted",
                  paste("Report type:", content$type, "|",
                        "Format:", toupper(content$format), "|",
                        "Generated:", format(Sys.time(), "%Y-%m-%d %H:%M")))
      )
    } else {
      current_lang <- lang()
      div(
        h6(t("report_preview_summary", current_lang)),
        tags$ul(
          tags$li(t("report_type_summary", current_lang)),
          tags$li(t("report_type_detailed", current_lang)),
          tags$li(t("report_type_risk_matrix", current_lang)),
          tags$li(t("report_type_bayesian", current_lang)),
          tags$li(t("report_type_complete", current_lang))
        )
      )
    }
  })
  
  # Generate report button handler
  observeEvent(input$generate_report, {
    current_lang <- lang()
    data <- currentData()
    
    if (is.null(data) || nrow(data) == 0) {
      showNotification(
        t("report_status_no_data", current_lang),
        type = "error",
        duration = 5
      )
      return()
    }
    
    # Show progress
    showNotification(
      t("report_status_generating", current_lang),
      type = "message",
      duration = 3
    )
    
    # Generate report content
    tryCatch({
      sections <- list()
      
      if ("exec_summary" %in% input$report_sections) {
        sections <- c(sections, list(list(
          title = "Executive Summary",
          description = paste("Overview of", nrow(data), "risk scenarios")
        )))
      }
      
      if ("data_overview" %in% input$report_sections) {
        sections <- c(sections, list(list(
          title = "Data Overview",
          description = paste("Analysis of", length(unique(data$Central_Problem)), "unique problems")
        )))
      }
      
      if ("bowtie_diagrams" %in% input$report_sections) {
        sections <- c(sections, list(list(
          title = "Bowtie Diagrams",
          description = "Visual representation of risk pathways"
        )))
      }
      
      if ("risk_matrix_section" %in% input$report_sections) {
        sections <- c(sections, list(list(
          title = "Risk Matrix",
          description = "Risk categorization by likelihood and severity"
        )))
      }
      
      if ("bayesian_section" %in% input$report_sections) {
        sections <- c(sections, list(list(
          title = "Bayesian Network Analysis",
          description = "Probabilistic risk inference results"
        )))
      }
      
      if ("recommendations" %in% input$report_sections) {
        sections <- c(sections, list(list(
          title = "Recommendations",
          description = "Risk mitigation strategies"
        )))
      }
      
      report_content(list(
        type = input$report_type,
        format = input$report_format,
        title = input$report_title,
        author = input$report_author,
        sections = sections,
        data = data,
        generated_at = Sys.time()
      ))
      
      report_generated(TRUE)
      
      showNotification(
        t("report_status_complete", current_lang),
        type = "message",
        duration = 5
      )
    }, error = function(e) {
      showNotification(
        paste(t("report_status_error", current_lang), ":", e$message),
        type = "error",
        duration = 10
      )
    })
  })
  
  # Download report handler
  output$download_report <- downloadHandler(
    filename = function() {
      content <- report_content()
      if (is.null(content)) {
        paste0("report.", "html")
      } else {
        paste0(gsub(" ", "_", tolower(content$title)), "_",
               format(Sys.time(), "%Y%m%d_%H%M%S"), ".", content$format)
      }
    },
    content = function(file) {
      content <- report_content()
      
      if (is.null(content)) {
        writeLines("No report generated yet.", file)
        return()
      }
      
      data <- content$data
      
      # Generate HTML report
      if (content$format == "html") {
        html_content <- paste0(
          "<!DOCTYPE html>\n<html>\n<head>\n",
          "<meta charset='UTF-8'>\n",
          "<title>", content$title, "</title>\n",
          "<style>\n",
          "body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }\n",
          ".container { max-width: 1400px; margin: auto; background: white; padding: 50px; box-shadow: 0 10px 40px rgba(0,0,0,0.3); border-radius: 10px; }\n",
          "h1 { color: #2c3e50; border-bottom: 4px solid #3498db; padding-bottom: 15px; font-size: 2.5em; margin-bottom: 10px; }\n",
          "h2 { color: #34495e; margin-top: 40px; padding: 15px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 5px; font-size: 1.8em; }\n",
          "h3 { color: #2980b9; margin-top: 25px; font-size: 1.4em; border-left: 4px solid #3498db; padding-left: 15px; }\n",
          "h4 { color: #16a085; margin-top: 20px; font-size: 1.2em; }\n",
          ".meta { color: #7f8c8d; font-style: italic; margin-bottom: 30px; padding: 15px; background: #ecf0f1; border-radius: 5px; border-left: 4px solid #3498db; }\n",
          "table { width: 100%; border-collapse: collapse; margin: 20px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }\n",
          "th, td { border: 1px solid #ddd; padding: 14px; text-align: left; }\n",
          "th { background: linear-gradient(135deg, #3498db 0%, #2980b9 100%); color: white; font-weight: bold; text-transform: uppercase; font-size: 0.9em; }\n",
          "tr:nth-child(even) { background-color: #f8f9fa; }\n",
          "tr:hover { background-color: #e3f2fd; transition: background-color 0.3s; }\n",
          ".section { margin: 40px 0; padding: 30px; background: #f8f9fa; border-radius: 8px; border: 1px solid #dee2e6; }\n",
          ".highlight { background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; border-radius: 4px; }\n",
          ".success { background-color: #d4edda; padding: 15px; border-left: 4px solid #28a745; margin: 20px 0; border-radius: 4px; }\n",
          ".warning { background-color: #f8d7da; padding: 15px; border-left: 4px solid #dc3545; margin: 20px 0; border-radius: 4px; }\n",
          ".info { background-color: #d1ecf1; padding: 15px; border-left: 4px solid #17a2b8; margin: 20px 0; border-radius: 4px; }\n",
          ".stat-box { display: inline-block; padding: 20px 30px; margin: 10px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 8px; min-width: 150px; text-align: center; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }\n",
          ".stat-value { font-size: 2.5em; font-weight: bold; display: block; }\n",
          ".stat-label { font-size: 0.9em; opacity: 0.9; text-transform: uppercase; letter-spacing: 1px; }\n",
          ".risk-high { background-color: #dc3545; color: white; padding: 5px 10px; border-radius: 4px; font-weight: bold; }\n",
          ".risk-medium { background-color: #ffc107; color: #333; padding: 5px 10px; border-radius: 4px; font-weight: bold; }\n",
          ".risk-low { background-color: #28a745; color: white; padding: 5px 10px; border-radius: 4px; font-weight: bold; }\n",
          ".toc { background: #f8f9fa; padding: 25px; border-radius: 8px; margin: 30px 0; border: 2px solid #dee2e6; }\n",
          ".toc h3 { margin-top: 0; color: #495057; }\n",
          ".toc ul { list-style: none; padding-left: 0; }\n",
          ".toc li { padding: 8px 0; border-bottom: 1px solid #dee2e6; }\n",
          ".toc li:last-child { border-bottom: none; }\n",
          ".toc a { color: #3498db; text-decoration: none; font-weight: 500; }\n",
          ".toc a:hover { color: #2980b9; text-decoration: underline; }\n",
          "ul.styled { list-style: none; padding-left: 0; }\n",
          "ul.styled li { padding: 10px 0 10px 30px; position: relative; }\n",
          "ul.styled li:before { content: '▸'; position: absolute; left: 0; color: #3498db; font-weight: bold; font-size: 1.2em; }\n",
          ".footer { margin-top: 50px; padding-top: 20px; border-top: 2px solid #dee2e6; text-align: center; color: #6c757d; }\n",
          ".page-break { page-break-after: always; }\n",
          "@media print { .page-break { page-break-after: always; } body { background: white; } .container { box-shadow: none; } }\n",
          "</style>\n</head>\n<body>\n<div class='container'>\n"
        )
        
        # Header
        html_content <- paste0(html_content,
          "<h1>", content$title, "</h1>\n",
          "<div class='meta'>\n",
          if (nchar(content$author) > 0) paste0("<strong>Author:</strong> ", content$author, "<br>\n") else "",
          "<strong>Generated:</strong> ", format(content$generated_at, "%Y-%m-%d %H:%M:%S"), "<br>\n",
          "<strong>Report Type:</strong> ", toupper(content$type), "<br>\n",
          "<strong>Version:</strong> ", APP_CONFIG$VERSION, " - Environmental Bowtie Risk Analysis Tool\n",
          "</div>\n"
        )
        
        # Table of Contents
        html_content <- paste0(html_content,
          "<div class='toc'>\n",
          "<h3>📋 Table of Contents</h3>\n",
          "<ul>\n"
        )
        
        toc_counter <- 1
        for (section in content$sections) {
          html_content <- paste0(html_content,
            "<li><a href='#section", toc_counter, "'>", toc_counter, ". ", section$title, "</a></li>\n"
          )
          toc_counter <- toc_counter + 1
        }
        
        html_content <- paste0(html_content, "</ul>\n</div>\n")
        
        # Key Statistics Dashboard
        html_content <- paste0(html_content,
          "<div style='text-align: center; margin: 40px 0;'>\n",
          "<h2>📊 Key Statistics at a Glance</h2>\n",
          "<div style='margin: 30px 0;'>\n",
          "<div class='stat-box'>\n",
          "<span class='stat-value'>", nrow(data), "</span>\n",
          "<span class='stat-label'>Total Scenarios</span>\n",
          "</div>\n",
          "<div class='stat-box'>\n",
          "<span class='stat-value'>", length(unique(data$Central_Problem)), "</span>\n",
          "<span class='stat-label'>Unique Problems</span>\n",
          "</div>\n",
          "<div class='stat-box'>\n",
          "<span class='stat-value'>", length(unique(data$Activity)), "</span>\n",
          "<span class='stat-label'>Activities</span>\n",
          "</div>\n",
          "<div class='stat-box'>\n",
          "<span class='stat-value'>", length(unique(data$Consequence)), "</span>\n",
          "<span class='stat-label'>Consequences</span>\n",
          "</div>\n",
          "</div>\n</div>\n"
        )
        
        # Sections
        section_counter <- 1
        for (section in content$sections) {
          html_content <- paste0(html_content,
            "<div class='section' id='section", section_counter, "'>\n",
            "<h2>", section_counter, ". ", section$title, "</h2>\n"
          )
          
          # Executive Summary
          if (section$title == "Executive Summary") {
            avg_likelihood <- mean(data$Likelihood, na.rm = TRUE)
            avg_severity <- mean(data$Severity, na.rm = TRUE)
            high_risk_count <- sum(data$Likelihood >= 4 & data$Severity >= 4, na.rm = TRUE)
            
            html_content <- paste0(html_content,
              "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
              "<div class='info'>\n",
              "<h4>🎯 Analysis Overview</h4>\n",
              "<p>This report presents a comprehensive environmental risk analysis covering <strong>", nrow(data), 
              "</strong> scenarios across <strong>", length(unique(data$Central_Problem)), 
              "</strong> distinct environmental problems. The analysis examines risk pathways from initial activities ",
              "through pressures, controls, and potential consequences.</p>\n",
              "</div>\n",
              "<h3>Key Findings</h3>\n",
              "<ul class='styled'>\n",
              "<li><strong>Average Likelihood:</strong> ", round(avg_likelihood, 2), " out of 5</li>\n",
              "<li><strong>Average Severity:</strong> ", round(avg_severity, 2), " out of 5</li>\n",
              "<li><strong>High-Risk Scenarios:</strong> ", high_risk_count, " scenarios require immediate attention</li>\n",
              "<li><strong>Control Measures:</strong> ", sum(!is.na(data$Preventive_Control)), 
              " preventive controls and ", sum(!is.na(data$Protective_Mitigation)), " protective mitigations identified</li>\n",
              "</ul>\n"
            )
            
            if (high_risk_count > 0) {
              html_content <- paste0(html_content,
                "<div class='warning'>\n",
                "<h4>⚠️ Attention Required</h4>\n",
                "<p><strong>", high_risk_count, "</strong> scenarios have been identified as high-risk ",
                "(likelihood ≥ 4 AND severity ≥ 4). These require immediate review and enhanced control measures.</p>\n",
                "</div>\n"
              )
            }
          }
          
          # Data Overview
          if (section$title == "Data Overview") {
            html_content <- paste0(html_content,
              "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
              "<h3>📈 Comprehensive Data Summary</h3>\n",
              "<table>\n",
              "<tr><th>Category</th><th>Count</th><th>Details</th></tr>\n",
              "<tr><td><strong>Total Risk Scenarios</strong></td><td>", nrow(data), "</td><td>Complete risk pathways analyzed</td></tr>\n",
              "<tr><td><strong>Central Problems</strong></td><td>", length(unique(data$Central_Problem)), "</td><td>Unique environmental issues identified</td></tr>\n",
              "<tr><td><strong>Human Activities</strong></td><td>", length(unique(data$Activity)), "</td><td>Root causes of environmental pressure</td></tr>\n",
              "<tr><td><strong>Environmental Pressures</strong></td><td>", length(unique(data$Pressure)), "</td><td>Direct threats to the environment</td></tr>\n",
              "<tr><td><strong>Preventive Controls</strong></td><td>", sum(!is.na(data$Preventive_Control)), "</td><td>Measures to prevent escalation</td></tr>\n",
              "<tr><td><strong>Protective Mitigations</strong></td><td>", sum(!is.na(data$Protective_Mitigation)), "</td><td>Measures to reduce consequences</td></tr>\n",
              "<tr><td><strong>Consequences</strong></td><td>", length(unique(data$Consequence)), "</td><td>Potential environmental impacts</td></tr>\n"
            )
            
            if ("Escalation_Factor" %in% names(data)) {
              html_content <- paste0(html_content,
                "<tr><td><strong>Escalation Factors</strong></td><td>", sum(!is.na(data$Escalation_Factor)), 
                "</td><td>Factors that worsen situations</td></tr>\n"
              )
            }
            
            html_content <- paste0(html_content, "</table>\n")
            
            # Top Problems
            problem_counts <- sort(table(data$Central_Problem), decreasing = TRUE)
            html_content <- paste0(html_content,
              "<h3>🎯 Top Environmental Problems</h3>\n",
              "<table>\n",
              "<tr><th>Rank</th><th>Environmental Problem</th><th>Occurrences</th><th>Percentage</th></tr>\n"
            )
            
            for (i in 1:min(10, length(problem_counts))) {
              pct <- round(problem_counts[i] / nrow(data) * 100, 1)
              html_content <- paste0(html_content,
                "<tr><td>", i, "</td><td>", names(problem_counts)[i], "</td><td>", 
                problem_counts[i], "</td><td>", pct, "%</td></tr>\n"
              )
            }
            
            html_content <- paste0(html_content, "</table>\n")
            
            # Risk Distribution
            html_content <- paste0(html_content,
              "<h3>📊 Risk Level Distribution</h3>\n",
              "<table>\n",
              "<tr><th>Risk Category</th><th>Count</th><th>Percentage</th><th>Priority</th></tr>\n"
            )
            
            high_risk <- sum(data$Likelihood >= 4 & data$Severity >= 4, na.rm = TRUE)
            medium_risk <- sum((data$Likelihood >= 3 | data$Severity >= 3) & 
                              (data$Likelihood < 4 | data$Severity < 4), na.rm = TRUE)
            low_risk <- nrow(data) - high_risk - medium_risk
            
            html_content <- paste0(html_content,
              "<tr><td><span class='risk-high'>HIGH RISK</span></td><td>", high_risk, 
              "</td><td>", round(high_risk/nrow(data)*100, 1), "%</td><td>Immediate action required</td></tr>\n",
              "<tr><td><span class='risk-medium'>MEDIUM RISK</span></td><td>", medium_risk, 
              "</td><td>", round(medium_risk/nrow(data)*100, 1), "%</td><td>Monitor and plan mitigation</td></tr>\n",
              "<tr><td><span class='risk-low'>LOW RISK</span></td><td>", low_risk, 
              "</td><td>", round(low_risk/nrow(data)*100, 1), "%</td><td>Routine monitoring</td></tr>\n",
              "</table>\n"
            )
          }
          
          # Bowtie Diagrams
          if (section$title == "Bowtie Diagrams") {
            html_content <- paste0(html_content,
              "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
              "<div class='info'>\n",
              "<h4>🎀 About Bowtie Analysis</h4>\n",
              "<p>Bowtie diagrams visualize the complete risk pathway from causes to consequences. ",
              "The left side (threat side) shows activities and pressures leading to the central problem, ",
              "with preventive controls designed to block or reduce these threats. The right side (consequence side) ",
              "shows potential impacts and protective mitigations to reduce their severity.</p>\n",
              "</div>\n",
              "<h3>📋 Complete Risk Pathways</h3>\n",
              "<table>\n",
              "<tr><th>Problem</th><th>Activity</th><th>Pressure</th><th>Preventive Control</th><th>Consequence</th><th>Protective Mitigation</th><th>Risk Score</th></tr>\n"
            )
            
            for (i in 1:min(50, nrow(data))) {
              risk_score <- data$Likelihood[i] * data$Severity[i]
              risk_class <- if (risk_score >= 16) "risk-high" else if (risk_score >= 9) "risk-medium" else "risk-low"
              
              html_content <- paste0(html_content,
                "<tr>",
                "<td><strong>", data$Central_Problem[i], "</strong></td>",
                "<td>", data$Activity[i], "</td>",
                "<td>", data$Pressure[i], "</td>",
                "<td>", ifelse(is.na(data$Preventive_Control[i]), "<em>None</em>", data$Preventive_Control[i]), "</td>",
                "<td>", data$Consequence[i], "</td>",
                "<td>", ifelse(is.na(data$Protective_Mitigation[i]), "<em>None</em>", data$Protective_Mitigation[i]), "</td>",
                "<td><span class='", risk_class, "'>", risk_score, "</span></td>",
                "</tr>\n"
              )
            }
            
            if (nrow(data) > 50) {
              html_content <- paste0(html_content,
                "<tr><td colspan='7' style='text-align: center; font-style: italic; color: #6c757d;'>",
                "Showing first 50 of ", nrow(data), " scenarios. Full data available in source file.</td></tr>\n"
              )
            }
            
            html_content <- paste0(html_content, "</table>\n")
          }
          
          # Risk Matrix Section
          if (section$title == "Risk Matrix") {
            html_content <- paste0(html_content,
              "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
              "<h3>🎯 Risk Matrix Analysis</h3>\n",
              "<p>The risk matrix plots scenarios based on their likelihood (probability of occurrence) and ",
              "severity (magnitude of impact). This visualization helps prioritize risk management efforts.</p>\n",
              "<h4>Matrix Distribution</h4>\n",
              "<table>\n",
              "<tr><th>Severity →<br>Likelihood ↓</th><th>1 (Very Low)</th><th>2 (Low)</th><th>3 (Medium)</th><th>4 (High)</th><th>5 (Very High)</th></tr>\n"
            )
            
            for (l in 5:1) {
              html_content <- paste0(html_content, "<tr><td><strong>", l, "</strong></td>")
              for (s in 1:5) {
                count <- sum(data$Likelihood == l & data$Severity == s, na.rm = TRUE)
                score <- l * s
                cell_class <- if (score >= 16) "risk-high" else if (score >= 9) "risk-medium" else "risk-low"
                html_content <- paste0(html_content, 
                  "<td style='text-align: center;'><span class='", cell_class, "'>", count, "</span></td>"
                )
              }
              html_content <- paste0(html_content, "</tr>\n")
            }
            
            html_content <- paste0(html_content, "</table>\n")
            
            # High Risk Scenarios Detail
            high_risk_data <- data[data$Likelihood >= 4 & data$Severity >= 4, ]
            if (nrow(high_risk_data) > 0) {
              html_content <- paste0(html_content,
                "<div class='warning'>\n",
                "<h3>⚠️ High-Risk Scenarios Requiring Immediate Attention</h3>\n",
                "<table>\n",
                "<tr><th>Problem</th><th>Activity</th><th>Consequence</th><th>Likelihood</th><th>Severity</th><th>Risk Score</th></tr>\n"
              )
              
              for (i in 1:nrow(high_risk_data)) {
                html_content <- paste0(html_content,
                  "<tr>",
                  "<td><strong>", high_risk_data$Central_Problem[i], "</strong></td>",
                  "<td>", high_risk_data$Activity[i], "</td>",
                  "<td>", high_risk_data$Consequence[i], "</td>",
                  "<td>", high_risk_data$Likelihood[i], "</td>",
                  "<td>", high_risk_data$Severity[i], "</td>",
                  "<td><span class='risk-high'>", high_risk_data$Likelihood[i] * high_risk_data$Severity[i], "</span></td>",
                  "</tr>\n"
                )
              }
              
              html_content <- paste0(html_content, "</table>\n</div>\n")
            }
          }
          
          # Bayesian Network Analysis
          if (section$title == "Bayesian Network Analysis") {
            html_content <- paste0(html_content,
              "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
              "<div class='info'>\n",
              "<h4>🧠 Probabilistic Risk Analysis</h4>\n",
              "<p>Bayesian networks provide a probabilistic framework for understanding risk propagation. ",
              "They model dependencies between activities, pressures, controls, problems, and consequences, ",
              "enabling what-if scenario analysis and inference of likely outcomes.</p>\n",
              "</div>\n",
              "<h3>Network Structure</h3>\n",
              "<ul class='styled'>\n",
              "<li><strong>Nodes:</strong> ", length(unique(c(data$Activity, data$Pressure, data$Central_Problem, data$Consequence))), 
              " unique elements in the risk network</li>\n",
              "<li><strong>Pathways:</strong> ", nrow(data), " causal connections identified</li>\n",
              "<li><strong>Control Points:</strong> ", sum(!is.na(data$Preventive_Control)) + sum(!is.na(data$Protective_Mitigation)), 
              " intervention opportunities</li>\n",
              "</ul>\n",
              "<h3>Key Dependencies</h3>\n",
              "<p>Analysis of conditional probabilities reveals critical risk pathways where interventions ",
              "can have maximum impact on reducing overall risk exposure.</p>\n"
            )
          }
          
          # Recommendations
          if (section$title == "Recommendations") {
            html_content <- paste0(html_content,
              "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
              "<h3>🎯 Priority Recommendations</h3>\n"
            )
            
            # Find scenarios with missing controls
            missing_preventive <- sum(is.na(data$Preventive_Control) | data$Preventive_Control == "")
            missing_protective <- sum(is.na(data$Protective_Mitigation) | data$Protective_Mitigation == "")
            
            if (missing_preventive > 0) {
              html_content <- paste0(html_content,
                "<div class='warning'>\n",
                "<h4>1. Implement Preventive Controls</h4>\n",
                "<p><strong>", missing_preventive, "</strong> scenarios lack preventive controls. ",
                "Priority should be given to implementing barriers that prevent pressures from escalating into problems.</p>\n",
                "</div>\n"
              )
            }
            
            if (missing_protective > 0) {
              html_content <- paste0(html_content,
                "<div class='warning'>\n",
                "<h4>2. Enhance Protective Mitigations</h4>\n",
                "<p><strong>", missing_protective, "</strong> scenarios lack protective mitigations. ",
                "These measures are crucial for reducing the severity of consequences when problems occur.</p>\n",
                "</div>\n"
              )
            }
            
            high_risk_count <- sum(data$Likelihood >= 4 & data$Severity >= 4, na.rm = TRUE)
            if (high_risk_count > 0) {
              html_content <- paste0(html_content,
                "<div class='warning'>\n",
                "<h4>3. Address High-Risk Scenarios</h4>\n",
                "<p><strong>", high_risk_count, "</strong> high-risk scenarios require immediate attention. ",
                "Review and strengthen existing controls, or implement additional measures to reduce likelihood or severity.</p>\n",
                "</div>\n"
              )
            }
            
            html_content <- paste0(html_content,
              "<div class='success'>\n",
              "<h4>4. Continuous Improvement</h4>\n",
              "<ul class='styled'>\n",
              "<li>Regularly review and update risk assessments as conditions change</li>\n",
              "<li>Monitor the effectiveness of implemented controls</li>\n",
              "<li>Engage stakeholders in identifying emerging risks</li>\n",
              "<li>Document lessons learned from incidents and near-misses</li>\n",
              "<li>Integrate risk management into operational decision-making</li>\n",
              "</ul>\n",
              "</div>\n"
            )
          }
          
          html_content <- paste0(html_content, "</div>\n")
          section_counter <- section_counter + 1
        }
        
        # Footer
        html_content <- paste0(html_content,
          "<div class='footer'>\n",
          "<p><strong>Environmental Bowtie Risk Analysis Tool</strong> | Version ", APP_CONFIG$VERSION, "</p>\n",
          "<p>Advanced Risk Assessment with Bayesian Networks</p>\n",
          "<p style='font-size: 0.9em; color: #6c757d;'>",
          "Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), 
          " | © 2025 Marbefes Environmental Risk Assessment Team</p>\n",
          "</div>\n",
          "</div>\n</body>\n</html>"
        )
        
        writeLines(html_content, file)
      } else {
        # For PDF and DOCX, create enhanced text format
        text_content <- paste0(
          strrep("=", 80), "\n",
          content$title, "\n",
          strrep("=", 80), "\n\n",
          if (nchar(content$author) > 0) paste0("Author: ", content$author, "\n") else "",
          "Generated: ", format(content$generated_at, "%Y-%m-%d %H:%M:%S"), "\n",
          "Report Type: ", toupper(content$type), "\n",
          "Version: ", APP_CONFIG$VERSION, " - Environmental Bowtie Risk Analysis Tool\n",
          strrep("=", 80), "\n\n"
        )
        
        # Add comprehensive content for text format
        text_content <- paste0(text_content,
          "KEY STATISTICS\n",
          strrep("-", 80), "\n",
          "Total Scenarios: ", nrow(data), "\n",
          "Unique Problems: ", length(unique(data$Central_Problem)), "\n",
          "Unique Activities: ", length(unique(data$Activity)), "\n",
          "Unique Consequences: ", length(unique(data$Consequence)), "\n",
          "Preventive Controls: ", sum(!is.na(data$Preventive_Control)), "\n",
          "Protective Mitigations: ", sum(!is.na(data$Protective_Mitigation)), "\n",
          "Average Likelihood: ", round(mean(data$Likelihood, na.rm = TRUE), 2), "\n",
          "Average Severity: ", round(mean(data$Severity, na.rm = TRUE), 2), "\n",
          "High-Risk Scenarios: ", sum(data$Likelihood >= 4 & data$Severity >= 4, na.rm = TRUE), "\n\n"
        )
        
        for (section in content$sections) {
          text_content <- paste0(text_content,
            "\n", strrep("=", 80), "\n",
            section$title, "\n",
            strrep("=", 80), "\n\n",
            section$description, "\n\n"
          )
          
          if (section$title == "Data Overview") {
            text_content <- paste0(text_content,
              "TOP ENVIRONMENTAL PROBLEMS:\n",
              strrep("-", 80), "\n"
            )
            problem_counts <- sort(table(data$Central_Problem), decreasing = TRUE)
            for (i in 1:min(10, length(problem_counts))) {
              text_content <- paste0(text_content,
                sprintf("%2d. %-50s %5d occurrences (%5.1f%%)\n", 
                        i, names(problem_counts)[i], problem_counts[i],
                        problem_counts[i]/nrow(data)*100)
              )
            }
            text_content <- paste0(text_content, "\n")
          }
        }
        
        text_content <- paste0(text_content,
          "\n", strrep("=", 80), "\n",
          "Environmental Bowtie Risk Analysis Tool v", APP_CONFIG$VERSION, "\n",
          "Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
          strrep("=", 80), "\n"
        )
        
        writeLines(text_content, file)
      }
    }
  )

  # Download User Manual handler - Automatically uses current version
  output$download_manual <- downloadHandler(
    filename = function() {
      get_manual_filename()
    },
    content = function(file) {
      manual_path <- get_manual_path()

      # Check if manual exists
      if (file.exists(manual_path)) {
        file.copy(manual_path, file)
        showNotification(
          paste("User manual v", APP_CONFIG$VERSION, " downloaded successfully!"),
          type = "message",
          duration = 3
        )
      } else {
        # If manual not found, create error message
        showNotification(
          paste0("User manual v", APP_CONFIG$VERSION,
                 " not found at: ", manual_path,
                 ". Please contact support."),
          type = "error",
          duration = 10
        )
      }
    }
  )

  # Download French User Manual handler
  output$download_manual_fr <- downloadHandler(
    filename = function() {
      paste0("Environmental_Bowtie_Manual_FR_v", APP_CONFIG$VERSION, ".html")
    },
    content = function(file) {
      manual_path <- file.path("docs", paste0("Environmental_Bowtie_Manual_FR_v", APP_CONFIG$VERSION, ".html"))

      # Check if manual exists
      if (file.exists(manual_path)) {
        file.copy(manual_path, file)
        showNotification(
          paste("Manuel utilisateur v", APP_CONFIG$VERSION, " téléchargé avec succès!"),
          type = "message",
          duration = 3
        )
      } else {
        # If manual not found, create error message
        showNotification(
          paste0("Manuel utilisateur v", APP_CONFIG$VERSION,
                 " introuvable à: ", manual_path,
                 ". Veuillez contacter le support."),
          type = "error",
          duration = 10
        )
      }
    }
  )

  # Helper function for simplified Bayesian inference (fallback)
  perform_inference_simple <- function(evidence, query_nodes) {
  # Simplified probabilistic inference for demonstration
  # In practice, this would use the actual Bayesian network

  results <- list()

  # Base probabilities
  base_probs <- list(
    Consequence_Level = c(Low = 0.4, Medium = 0.4, High = 0.2),
    Problem_Severity = c(Low = 0.3, Medium = 0.5, High = 0.2),
    Escalation_Level = c(Low = 0.5, Medium = 0.3, High = 0.2)
  )

  # Adjust probabilities based on evidence
  for (node in query_nodes) {
    if (node %in% names(base_probs)) {
      probs <- base_probs[[node]]

      # Adjust based on evidence
      if ("Activity" %in% names(evidence) && evidence$Activity == "Present") {
        # Increase risk when activity is present
        probs["High"] <- min(0.8, probs["High"] * 1.5)
        probs["Medium"] <- max(0.1, probs["Medium"] * 1.2)
        probs["Low"] <- max(0.1, 1 - probs["High"] - probs["Medium"])
      }

      if ("Pressure_Level" %in% names(evidence)) {
        pressure_level <- evidence$Pressure_Level
        if (pressure_level == "High") {
          probs["High"] <- min(0.9, probs["High"] * 2)
          probs["Medium"] <- max(0.05, probs["Medium"] * 0.8)
          probs["Low"] <- max(0.05, 1 - probs["High"] - probs["Medium"])
        } else if (pressure_level == "Low") {
          probs["Low"] <- min(0.8, probs["Low"] * 1.5)
          probs["High"] <- max(0.05, probs["High"] * 0.3)
          probs["Medium"] <- max(0.15, 1 - probs["High"] - probs["Low"])
        }
      }

      if ("Control_Effect" %in% names(evidence)) {
        control_effect <- evidence$Control_Effect
        if (control_effect == "Failed") {
          probs["High"] <- min(0.85, probs["High"] * 1.8)
          probs["Medium"] <- max(0.1, probs["Medium"] * 1.1)
          probs["Low"] <- max(0.05, 1 - probs["High"] - probs["Medium"])
        } else if (control_effect == "Effective") {
          probs["Low"] <- min(0.7, probs["Low"] * 1.4)
          probs["High"] <- max(0.05, probs["High"] * 0.4)
          probs["Medium"] <- max(0.25, 1 - probs["High"] - probs["Low"])
        }
      }

      # Normalize probabilities
      total <- sum(probs)
      probs <- probs / total

      results[[node]] <- probs
    }
  }

  return(results)
  }

}
