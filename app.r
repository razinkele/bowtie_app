# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application
# Version: 4.2.3 (PNG Image Support & Fixed Protective Mitigation Connections)
# Date: June 2025
# Author: AI Assistant
# Description: Complete enhanced version with PNG image support and fixed connections
# =============================================================================

# Load required libraries
library(shiny)
library(bslib)
library(DT)
library(readxl)
library(openxlsx)
library(ggplot2)
library(plotly)
library(dplyr)
library(visNetwork)
library(shinycssloaders)
library(colourpicker)
library(htmlwidgets)
library(shinyjs)

# Source utility functions
source("utils.r")

# Define UI with PNG image support and enhanced structure
ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(version = 5, bootswatch = "journal"),
  
  # Add custom CSS for PNG image styling and enhanced layout
  tags$head(
    tags$style(HTML("
      .app-title-image {
        max-height: 40px;
        margin-right: 15px;
        vertical-align: middle;
        border-radius: 4px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .title-container {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        width: 100%;
      }
      .title-text {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        flex-grow: 1;
      }
      .version-badge {
        animation: pulse 2s infinite;
      }
      @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.05); }
        100% { transform: scale(1); }
      }
      .network-container {
        border: 2px solid #e9ecef;
        border-radius: 8px;
        padding: 10px;
        background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
      }
      .enhanced-legend {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border: 1px solid #dee2e6;
        border-radius: 8px;
      }
    "))
  ),
  
  # Enhanced header with PNG image support
  fluidRow(
    column(12,
           card(
             card_header(
               class = "d-flex justify-content-between align-items-center bg-light",
               div(
                 class = "title-container",
                 div(
                   class = "title-text",
                   # PNG Image - Place your logo.png in the www/ folder
                   img(src = "logo.png", class = "app-title-image", alt = "Environmental Risk Analysis Logo",
                       onerror = "this.style.display='none'", 
                       title = "Environmental Bowtie Risk Analysis"),
                   h4("🌊 Environmental Bowtie Risk Analysis", class = "mb-0 text-primary d-inline-block me-3"),
                   span(class = "badge bg-success me-2 version-badge", "v4.2.3"),
                   span(class = "text-muted small", "PNG Support & Fixed Connections")
                 )
               ),
               actionButton("toggleTheme", label = NULL, icon = icon("gear"),
                           class = "btn-sm btn-outline-secondary", title = "Theme Settings")
             ),
             card_body(
               id = "themePanel", class = "collapse",
               fluidRow(
                 column(3, selectInput("theme_preset", "Theme:",
                                     choices = c("Default" = "default", "Dark" = "darkly", 
                                               "Ocean Blue" = "cosmo", "Forest Green" = "journal",
                                               "Environmental" = "materia", "Corporate" = "flatly",
                                               "Minimal" = "minty", "Custom" = "custom"),
                                     selected = "journal")),
                 column(3, conditionalPanel(condition = "input.theme_preset == 'custom'",
                                          colourpicker::colourInput("primary_color", "Primary:", value = "#28a745"))),
                 column(3, conditionalPanel(condition = "input.theme_preset == 'custom'",
                                          colourpicker::colourInput("secondary_color", "Secondary:", value = "#6c757d"))),
                 column(3, p(class = "text-muted mt-2", "Enhanced environmental risk analysis with PNG support and fixed protective mitigation connections."))
               )
             )
           )
    )
  ),

  # Navigation tabs
  navset_card_tab(
    id = "main_tabs",
    
    # Data Upload Tab
    nav_panel(
      title = tagList(icon("upload"), "Data Upload"), value = "upload",
      
      fluidRow(
        column(6,
               card(
                 card_header(tagList(icon("database"), "Data Input Options"), class = "bg-primary text-white"),
                 card_body(
                   h5(tagList(icon("file-excel"), "Option 1: Upload Excel File")),
                   fileInput("file", "Choose Excel File:", accept = c(".xlsx", ".xls"),
                            buttonLabel = "Browse...", placeholder = "No file selected"),
                   
                   conditionalPanel(
                     condition = "output.fileUploaded",
                     selectInput("sheet", "Select Sheet:", choices = NULL),
                     div(class = "d-grid", actionButton("loadData", tagList(icon("upload"), "Load Data"), 
                                                       class = "btn-primary"))
                   ),
                   
                   hr(),
                   
                   h5(tagList(icon("leaf"), "Option 2: Generate Enhanced Sample Data")),
                   p("Generate comprehensive environmental bowtie data with fixed protective mitigation connections:"),
                   div(class = "d-grid", actionButton("generateSample", 
                                                     tagList(icon("seedling"), "Generate Enhanced Data v4.2.3"), 
                                                     class = "btn-success")),
                   
                   conditionalPanel(
                     condition = "output.envDataGenerated",
                     br(),
                     div(class = "d-grid", downloadButton("downloadSample", 
                                                         tagList(icon("download"), "Download Enhanced Excel"), 
                                                         class = "btn-info"))
                   )
                 )
               )
        ),
        
        column(6,
               card(
                 card_header(tagList(icon("info-circle"), "Enhanced Data Structure v4.2.3"), class = "bg-info text-white"),
                 card_body(
                   h6(tagList(icon("list"), "Fixed Bowtie Elements:")),
                   p("Your Excel file should contain environmental risk data with these columns:"),
                   tags$ul(
                     tags$li(tagList(icon("play", class = "text-primary"), 
                                    strong("Activity:"), " Human activities that create risk")),
                     tags$li(tagList(icon("triangle-exclamation", class = "text-danger"), 
                                    strong("Pressure:"), " Environmental pressures/threats")),
                     tags$li(tagList(icon("shield-halved", class = "text-success"), 
                                    strong("Preventive_Control:"), " Controls to prevent escalation")),
                     tags$li(tagList(icon("exclamation-triangle", class = "text-warning"), 
                                    strong("Escalation_Factor:"), " Factors that worsen situations")),
                     tags$li(tagList(icon("radiation", class = "text-danger"), 
                                    strong("Central_Problem:"), " Main environmental risk")),
                     tags$li(tagList(icon("shield", class = "text-info"), 
                                    strong("Protective_Mitigation:"), " FIXED - Measures to reduce impact")),
                     tags$li(tagList(icon("burst", class = "text-warning"), 
                                    strong("Consequence:"), " Final environmental outcomes")),
                     tags$li(tagList(icon("percent"), strong("Likelihood:"), " Probability (1-5)")),
                     tags$li(tagList(icon("bolt"), strong("Severity:"), " Impact severity (1-5)"))
                   ),
                   
                   div(class = "alert alert-success mt-3",
                       tagList(icon("check-circle"), " "),
                       strong("v4.2.3 FIXED Pathways:"), " Activity → Pressure → Control → Escalation → Central Problem → FIXED Mitigation → Consequence"),
                   
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     hr(),
                     h6(tagList(icon("chart-bar"), "Enhanced Data Summary:")),
                     verbatimTextOutput("dataInfo")
                   )
                 )
               )
        )
      ),
      
      conditionalPanel(
        condition = "output.dataLoaded",
        br(),
        card(
          card_header(tagList(icon("eye"), "Data Preview - v4.2.3 Enhanced"), class = "bg-success text-white"),
          card_body(
            withSpinner(DT::dataTableOutput("preview")),
            br(),
            div(class = "alert alert-info", tagList(icon("info-circle"), " "), 
                textOutput("debugInfo", inline = TRUE))
          )
        )
      )
    ),
    
    # Enhanced Bowtie Visualization Tab
    nav_panel(
      title = tagList(icon("project-diagram"), "Fixed Bowtie v4.2.3"), value = "bowtie",
      
      fluidRow(
        column(4,
               card(
                 card_header(tagList(icon("cogs"), "Enhanced Bowtie Controls v4.2.3"), class = "bg-primary text-white"),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     selectInput("selectedProblem", "Select Central Problem:", choices = NULL),
                     
                     hr(),
                     h6(tagList(icon("edit"), "Network Editing:")),
                     checkboxInput("editMode", "Enable Network Editing", value = FALSE),
                     conditionalPanel(
                       condition = "input.editMode",
                       div(class = "alert alert-warning small",
                           tagList(icon("exclamation-triangle"), " "),
                           "Use manipulation toolbar in the network.")
                     ),
                     
                     hr(),
                     h6(tagList(icon("eye"), "Display Options:")),
                     checkboxInput("showBarriers", "Show Controls & FIXED Mitigation", value = TRUE),
                     checkboxInput("showRiskLevels", "Color by Risk Level", value = TRUE),
                     sliderInput("nodeSize", "Node Size:", min = 25, max = 80, value = 45),
                     
                     hr(),
                     h6(tagList(icon("plus"), "Quick Add Enhanced:")),
                     textInput("newActivity", "New Activity:", placeholder = "Enter activity description"),
                     textInput("newPressure", "New Pressure:", placeholder = "Enter pressure/threat"),
                     textInput("newConsequence", "New Consequence:", placeholder = "Enter consequence"),
                     div(class = "d-grid", actionButton("addActivityChain", 
                                                       tagList(icon("plus-circle"), "Add Enhanced Chain v4.2.3"), 
                                                       class = "btn-outline-primary btn-sm")),
                     
                     hr(),
                     h6(tagList(icon("palette"), "FIXED Bowtie Visual Legend v4.2.3:")),
                     div(class = "p-3 border rounded enhanced-legend",
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge" , style = "background-color: #8E44AD; color: white; margin-right: 8px;", "◼"),
                             span(tagList(icon("play"), " Activities (Human Actions)"))),
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge bg-danger me-2", "▲"),
                             span(tagList(icon("triangle-exclamation"), " Pressures (Environmental Threats)"))),
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge bg-success me-2", "◼"),
                             span(tagList(icon("shield-halved"), " Preventive Controls"))),
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge bg-warning me-2", "▼"),
                             span(tagList(icon("exclamation-triangle"), " Escalation Factors"))),
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge" , style = "background-color: #C0392B; color: white; margin-right: 8px;", "♦"),
                             span(tagList(icon("radiation"), " Central Problem (Main Risk)"))),
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge bg-primary me-2", "◼"),
                             span(tagList(icon("shield"), " Protective Mitigation "), 
                                  span(class = "badge bg-success text-white small ms-1", "FIXED v4.2.3"))),
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge" , style = "background-color: #E67E22; color: white; margin-right: 8px;", "⬢"),
                             span(tagList(icon("burst"), " Consequences (Environmental Impacts)"))),
                         hr(class = "my-2"),
                         div(class = "small text-success",
                             strong("✓ FIXED v4.2.3:"), " Protective mitigation connections now properly mapped"),
                         div(class = "small text-muted",
                             strong("Enhanced Flow:"), " Activity → Pressure → Control → Escalation → Central Problem → FIXED Mitigation → Consequence"),
                         div(class = "small text-muted",
                             strong("Line Types:"), " Solid = causal flow, Dashed = intervention/control effects"),
                         div(class = "small text-info mt-1",
                             strong("PNG Support:"), " Add logo.png to www/ folder for custom branding")
                     ),
                     
                     hr(),
                     div(class = "d-grid", downloadButton("downloadBowtie", 
                                                         tagList(icon("download"), "Download Fixed Diagram v4.2.3"), 
                                                         class = "btn-success"))
                   )
                 )
               )
        ),
        
        column(8,
               card(
                 card_header(tagList(icon("sitemap"), "FIXED Bowtie Diagram v4.2.3"), 
                           class = "bg-success text-white"),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     div(class = "text-center mb-3",
                         h5(tagList(icon("water"), "Environmental Bowtie Risk Analysis - v4.2.3 FIXED"), class = "text-primary"),
                         p(class = "small text-success", 
                           "✓ FIXED protective mitigation connections: Activities → Pressures → Controls → Escalation → Central Problem → ENHANCED Mitigation → Consequences")),
                     div(class = "network-container",
                         withSpinner(visNetworkOutput("bowtieNetwork", height = "650px"))
                     )
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("upload", class = "fa-3x text-muted mb-3"),
                         h4("Upload Data or Generate Enhanced Sample Data v4.2.3", class = "text-muted"),
                         p("Please upload environmental data or generate enhanced sample data to view the FIXED bowtie diagram with proper protective mitigation connections", 
                           class = "text-muted"))
                   )
                 )
               )
        )
      )
    ),
    
    # Enhanced Data Table Tab
    nav_panel(
      title = tagList(icon("table"), "Enhanced Data Table"), value = "table",
      
      fluidRow(
        column(12,
               card(
                 card_header(
                   div(class = "d-flex justify-content-between align-items-center",
                       tagList(icon("table"), "Enhanced Environmental Bowtie Data v4.2.3 - FIXED Connections"),
                       div(
                         conditionalPanel(
                           condition = "output.dataLoaded",
                           actionButton("addRow", tagList(icon("plus"), "Add Enhanced Row"), 
                                      class = "btn-success btn-sm me-2"),
                           actionButton("deleteSelected", tagList(icon("trash"), "Delete Selected"), 
                                      class = "btn-danger btn-sm me-2"),
                           actionButton("saveChanges", tagList(icon("save"), "Save Enhanced Changes"), 
                                      class = "btn-primary btn-sm")
                         )
                       )
                   ),
                   class = "bg-primary text-white"
                 ),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     div(class = "alert alert-success",
                         tagList(icon("check-circle"), " "),
                         "✓ v4.2.3 ENHANCED: Click on any cell to edit. The table shows FIXED protective mitigation connections with proper pathway mapping."),
                     withSpinner(DT::dataTableOutput("editableTable"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("table", class = "fa-3x text-muted mb-3"),
                         h4("No Enhanced Data Available", class = "text-muted"),
                         p("Please upload data or generate enhanced sample data v4.2.3 to view the table with FIXED connections", class = "text-muted"))
                   )
                 )
               )
        )
      )
    ),
    
    # Enhanced Risk Matrix Tab
    nav_panel(
      title = tagList(icon("chart-line"), "Enhanced Risk Matrix"), value = "matrix",
      
      fluidRow(
        column(8,
               card(
                 card_header(tagList(icon("chart-scatter"), "Enhanced Environmental Risk Matrix v4.2.3"), 
                           class = "bg-primary text-white"),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     withSpinner(plotlyOutput("riskMatrix", height = "500px"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("chart-line", class = "fa-3x text-muted mb-3"),
                         h4("No Enhanced Data Available", class = "text-muted"),
                         p("Please upload data or generate enhanced sample data v4.2.3 to view the risk matrix", class = "text-muted"))
                   )
                 )
               )
        ),
        
        column(4,
               card(
                 card_header(tagList(icon("chart-pie"), "Enhanced Risk Statistics v4.2.3"), class = "bg-info text-white"),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     withSpinner(tableOutput("riskStats"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-3",
                         icon("chart-pie", class = "fa-2x text-muted mb-2"),
                         p("No enhanced statistics available", class = "text-muted"))
                   )
                 )
               )
        )
      )
    )
  ),
  
  # Enhanced Footer
  hr(),
  div(class = "text-center text-muted mb-3",
      p(tagList(
        strong("Environmental Bowtie Risk Analysis Tool"),
        " | ",
        span(class = "badge bg-success", "v4.2.3"),
        " - PNG Image Support & FIXED Protective Mitigation Connections"
      )))
)

# Define Server with enhanced structure and FIXED connections
server <- function(input, output, session) {
  
  # Optimized reactive values using reactiveVal for single values
  currentData <- reactiveVal(NULL)
  editedData <- reactiveVal(NULL)
  sheets <- reactiveVal(NULL)
  envDataGenerated <- reactiveVal(FALSE)
  selectedRows <- reactiveVal(NULL)
  dataVersion <- reactiveVal(0)  # For cache invalidation
  
  # Optimized data retrieval with caching
  getCurrentData <- reactive({
    edited <- editedData()
    if (!is.null(edited)) edited else currentData()
  })
  
  # Theme management
  current_theme <- reactive({
    theme_choice <- input$theme_preset
    if (theme_choice == "custom") {
      bs_theme(version = 5, primary = input$primary_color, secondary = input$secondary_color)
    } else if (theme_choice == "default") {
      bs_theme(version = 5)
    } else {
      bs_theme(version = 5, bootswatch = theme_choice)
    }
  })
  
  observe({
    tryCatch(session$setCurrentTheme(current_theme()), 
             error = function(e) cat("Theme switching warning:", e$message, "\n"))
  })
  
  observeEvent(input$toggleTheme, {
    runjs('$("#themePanel").collapse("toggle");')
  })
  
  # File upload handling
  observeEvent(input$file, {
    req(input$file)
    tryCatch({
      sheet_names <- excel_sheets(input$file$datapath)
      sheets(sheet_names)
      updateSelectInput(session, "sheet", choices = sheet_names, selected = sheet_names[1])
    }, error = function(e) {
      showNotification("Error reading Excel file", type = "error")
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
      clearCache()  # Clear cache when new data is loaded
      
      updateSelectInput(session, "selectedProblem", choices = unique(data$Central_Problem))
      showNotification("✓ Data loaded successfully with v4.2.3 FIXED connections!", type = "message", duration = 3)
      
    }, error = function(e) {
      showNotification(paste("❌ Error loading data:", e$message), type = "error")
    })
  })
  
  # Enhanced sample data generation with FIXED connections
  observeEvent(input$generateSample, {
    showNotification("🔄 Generating v4.2.3 enhanced sample data with FIXED protective mitigation connections...", 
                    type = "message", duration = 3)
    
    tryCatch({
      sample_data <- generateEnvironmentalDataFixed()  # Using FIXED function
      currentData(sample_data)
      editedData(sample_data)
      envDataGenerated(TRUE)
      dataVersion(dataVersion() + 1)
      clearCache()
      
      problem_choices <- unique(sample_data$Central_Problem)
      updateSelectInput(session, "selectedProblem", choices = problem_choices, selected = problem_choices[1])
      
      showNotification(paste("✅ Generated", nrow(sample_data), "enhanced environmental scenarios with v4.2.3 FIXED protective mitigation connections!"), 
                      type = "message", duration = 4)
      
    }, error = function(e) {
      showNotification(paste("❌ Error generating enhanced data:", e$message), type = "error", duration = 5)
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
  
  # Enhanced data info with v4.2.3 details
  output$dataInfo <- renderText({
    data <- getCurrentData()
    req(data)
    getDataSummaryFixed(data)  # Using enhanced summary function
  })
  
  # Enhanced download handler
  output$downloadSample <- downloadHandler(
    filename = function() paste("enhanced_environmental_bowtie_v4.2.3_", Sys.Date(), ".xlsx", sep = ""),
    content = function(file) {
      data <- getCurrentData()
      req(data)
      openxlsx::write.xlsx(data, file, rowNames = FALSE)
    }
  )
  
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
  
  # Enhanced editable table with v4.2.3 improvements
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
          list(className = 'dt-center', targets = c(7, 8, 9)),  # Likelihood, Severity, Risk_Level
          list(width = '100px', targets = c(0, 1, 2, 3, 4, 5, 6)),
          list(width = '60px', targets = c(7, 8)),
          list(width = '80px', targets = c(9))
        ),
        autoWidth = FALSE,
        dom = 'Blfrtip',
        buttons = c('copy', 'csv', 'excel'),
        language = list(processing = "Loading v4.2.3 enhanced data with FIXED connections...")
      ),
      editable = list(target = 'cell'),
      extensions = c('Buttons', 'Scroller'),
      class = 'cell-border stripe compact hover',
      filter = 'top'
    )
  })
  
  # Enhanced cell editing with validation and v4.2.3 features
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
    
    if (col_names[info$col] %in% c("Likelihood", "Severity")) {
      validation <- validateNumericInput(info$value)
      if (!validation$valid) {
        showNotification(validation$message, type = "error", duration = 3)
        return()
      }
      data[info$row, info$col] <- validation$value
      
      # Recalculate risk level efficiently
      likelihood <- data[info$row, "Likelihood"]
      severity <- data[info$row, "Severity"]
      data[info$row, "Risk_Level"] <- calculateRiskLevel(likelihood, severity)
    } else {
      data[info$row, info$col] <- as.character(info$value)
    }
    
    editedData(data)
    dataVersion(dataVersion() + 1)
    clearCache()
    
    # Show enhanced success feedback
    if (runif(1) < 0.3) {  # Only show notification 30% of the time
      showNotification("✓ Cell updated - v4.2.3 FIXED connections refreshed", type = "message", duration = 1)
    }
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # Track selected rows efficiently
  observe({
    selectedRows(input$editableTable_rows_selected)
  })
  
  # Enhanced row operations
  observeEvent(input$addRow, {
    data <- getCurrentData()
    req(data)
    
    selected_problem <- if (!is.null(input$selectedProblem)) input$selectedProblem else "New Environmental Risk v4.2.3"
    new_row <- createDefaultRowFixed(selected_problem)  # Using FIXED function
    updated_data <- rbind(data, new_row)
    
    editedData(updated_data)
    dataVersion(dataVersion() + 1)
    clearCache()
    showNotification("✅ New enhanced row added with v4.2.3 FIXED connections!", type = "message", duration = 2)
  })
  
  observeEvent(input$deleteSelected, {
    rows <- selectedRows()
    if (!is.null(rows) && length(rows) > 0) {
      data <- getCurrentData()
      updated_data <- data[-rows, ]
      editedData(updated_data)
      dataVersion(dataVersion() + 1)
      clearCache()
      showNotification(paste("🗑️ Deleted", length(rows), "row(s) - v4.2.3 connections updated"), type = "warning", duration = 2)
    } else {
      showNotification("❌ No rows selected", type = "error", duration = 2)
    }
  })
  
  observeEvent(input$saveChanges, {
    edited <- editedData()
    if (!is.null(edited)) {
      currentData(edited)
      showNotification("💾 Changes saved with v4.2.3 FIXED connections!", type = "message", duration = 2)
    }
  })
  
  # Enhanced quick add functionality with v4.2.3 features
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
      Preventive_Control = "v4.2.3 Enhanced preventive control",
      Escalation_Factor = "v4.2.3 Enhanced escalation factor",
      Central_Problem = input$selectedProblem,
      Protective_Mitigation = paste("v4.2.3 FIXED protective mitigation for", input$newConsequence),
      Consequence = input$newConsequence,
      Likelihood = 3L,
      Severity = 3L,
      Risk_Level = "Medium",
      stringsAsFactors = FALSE
    )
    
    updated_data <- rbind(data, new_row)
    editedData(updated_data)
    dataVersion(dataVersion() + 1)
    clearCache()
    
    updateTextInput(session, "newActivity", value = "")
    updateTextInput(session, "newPressure", value = "")
    updateTextInput(session, "newConsequence", value = "")
    showNotification("🔗 Enhanced activity chain added with v4.2.3 FIXED connections!", type = "message", duration = 3)
  })
  
  # Enhanced debug info
  output$debugInfo <- renderText({
    data <- getCurrentData()
    if (!is.null(data)) {
      paste("✅ Loaded:", nrow(data), "rows,", ncol(data), "columns - v4.2.3 Enhanced bowtie structure with FIXED protective mitigation connections")
    } else {
      "No enhanced data loaded"
    }
  })
  
  # FIXED bowtie network with v4.2.3 enhancements
  output$bowtieNetwork <- renderVisNetwork({
    data <- getCurrentData()
    req(data, input$selectedProblem)
    
    problem_data <- data[data$Central_Problem == input$selectedProblem, ]
    if (nrow(problem_data) == 0) {
      showNotification("⚠️ No data for selected central problem", type = "warning")
      return(NULL)
    }
    
    nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, input$nodeSize, 
                                   input$showRiskLevels, input$showBarriers)  # Using FIXED function
    edges <- createBowtieEdgesFixed(problem_data, input$showBarriers)  # Using FIXED function
    
    visNetwork(nodes, edges, 
               main = paste("🌟 Enhanced Bowtie Analysis v4.2.3 with FIXED Connections:", input$selectedProblem),
               submain = if(input$showBarriers) "✅ Interconnected pathways with v4.2.3 FIXED protective mitigation connections" else "Direct causal relationships with enhanced connections",
               footer = "🔧 v4.2.3 ENHANCED: Activities → Pressures → Controls → Escalation → Central Problem → FIXED Mitigation → Consequences") %>%
      visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
               font = list(color = "#2C3E50", face = "Arial", size = 12)) %>%
      visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
               smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
      visLayout(randomSeed = 123, hierarchical = list(enabled = TRUE, direction = "LR",
                                                      sortMethod = "directed", levelSeparation = 140,
                                                      nodeSpacing = 90)) %>%
      visPhysics(enabled = FALSE) %>%
      visOptions(highlightNearest = list(enabled = TRUE, degree = 1),
                nodesIdSelection = TRUE, collapse = FALSE,
                manipulation = if(input$editMode) list(enabled = TRUE, addNode = TRUE, addEdge = TRUE,
                                                      editNode = TRUE, editEdge = TRUE, deleteNode = TRUE,
                                                      deleteEdge = TRUE) else list(enabled = FALSE)) %>%
      visInteraction(navigationButtons = TRUE, dragNodes = TRUE, dragView = TRUE, zoomView = TRUE) %>%
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
        list(label = "Protective Mitigation (v4.2.3 FIXED)", 
             color = "#3498DB", shape = "square", size = 15),
        list(label = "Consequences (Impacts)", 
             color = "#E67E22", shape = "hexagon", size = 15)
      ), position = "right", width = 0.25, ncol = 1)
  })
  
  # Enhanced risk matrix with v4.2.3 features
  output$riskMatrix <- renderPlotly({
    data <- getCurrentData()
    req(data, nrow(data) > 0)
    
    risk_plot <- ggplot(data, aes(x = Likelihood, y = Severity)) +
      geom_point(aes(color = Risk_Level, 
                     text = paste("Central Problem:", Central_Problem, 
                                 "<br>Activity:", Activity,
                                 "<br>Pressure:", Pressure,
                                 "<br>Protective Mitigation:", Protective_Mitigation,
                                 "<br>Consequence:", Consequence,
                                 "<br>v4.2.3 FIXED Connections: ✅")),
                 size = 4, alpha = 0.7) +
      scale_color_manual(values = RISK_COLORS) +
      scale_x_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
      scale_y_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
      labs(title = "🌟 Enhanced Environmental Risk Matrix v4.2.3 with FIXED Connections", 
           x = "Likelihood", y = "Severity",
           subtitle = "✅ Protective mitigation connections properly mapped") +
      theme_minimal() + 
      theme(legend.position = "bottom",
            plot.title = element_text(color = "#2C3E50", size = 14),
            plot.subtitle = element_text(color = "#27AE60", size = 10))
    
    ggplotly(risk_plot, tooltip = "text")
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
      select(Icon, `Risk Level` = Risk_Level, Count = n, `Percentage (%)` = Percentage)
    
    # Add footer row showing v4.2.3 status
    footer_row <- data.frame(
      Icon = "✅",
      `Risk Level` = "v4.2.3 FIXED",
      Count = nrow(data),
      `Percentage (%)` = 100.0,
      stringsAsFactors = FALSE
    )
    
    rbind(risk_summary, footer_row)
  }, sanitize.text.function = function(x) x)
  
  # Enhanced download bowtie diagram
  output$downloadBowtie <- downloadHandler(
    filename = function() paste("enhanced_bowtie_v4.2.3_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".html"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)
      
      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, 50, FALSE, TRUE)  # Using FIXED function
      edges <- createBowtieEdgesFixed(problem_data, TRUE)  # Using FIXED function
      
      network <- visNetwork(nodes, edges, 
                          main = paste("🌟 Enhanced Environmental Bowtie Analysis v4.2.3 with FIXED Connections:", input$selectedProblem),
                          submain = paste("Generated on", Sys.Date(), "- v4.2.3 with FIXED protective mitigation connections"),
                          footer = "🔧 v4.2.3 ENHANCED: Activities → Pressures → Controls → Escalation → Central Problem → FIXED Mitigation → Consequences") %>%
        visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
                font = list(color = "#2C3E50", face = "Arial")) %>%
        visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
                smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
        visLayout(randomSeed = 123, hierarchical = list(enabled = TRUE, direction = "LR",
                                                        sortMethod = "directed", levelSeparation = 160,
                                                        nodeSpacing = 110)) %>%
        visPhysics(enabled = FALSE) %>%
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
          list(label = "Protective Mitigation (v4.2.3 FIXED)", 
               color = "#3498DB", shape = "square", size = 15),
          list(label = "Consequences (Impacts)", 
               color = "#E67E22", shape = "hexagon", size = 15)
        ), position = "right", width = 0.25, ncol = 1)
      
      visSave(network, file, selfcontained = TRUE)
    }
  )
}

# Run the enhanced application
shinyApp(ui = ui, server = server)