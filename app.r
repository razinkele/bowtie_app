# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application (Connection Fix)
# Version: 4.2.2 (Fixed Barrier Connections)
# Date: June 2025
# Author: AI Assistant
# Description: Fixed protective mitigation and barrier connections in bowtie diagrams
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

# Define UI with enhanced structure
ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(version = 5, bootswatch = "journal"),
  
  # Theme controls
  fluidRow(
    column(12,
           card(
             card_header(
               class = "d-flex justify-content-between align-items-center bg-light",
               div(
                 h4("🌊 Environmental Bowtie Risk Analysis", class = "mb-0 text-primary d-inline-block me-3"),
                 span(class = "badge bg-success me-2", "v4.2.2"),
                 span(class = "text-muted", "Fixed Barrier Connections")
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
                 column(3, p(class = "text-muted mt-2", "Comprehensive environmental risk analysis."))
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
                   
                   h5(tagList(icon("leaf"), "Option 2: Generate Sample Data")),
                   p("Generate comprehensive environmental bowtie data with multiple interconnected pathways:"),
                   div(class = "d-grid", actionButton("generateSample", 
                                                     tagList(icon("seedling"), "Generate Comprehensive Data"), 
                                                     class = "btn-success")),
                   
                   conditionalPanel(
                     condition = "output.envDataGenerated",
                     br(),
                     div(class = "d-grid", downloadButton("downloadSample", 
                                                         tagList(icon("download"), "Download as Excel"), 
                                                         class = "btn-info"))
                   )
                 )
               )
        ),
        
        column(6,
               card(
                 card_header(tagList(icon("info-circle"), "Enhanced Data Structure"), class = "bg-info text-white"),
                 card_body(
                   h6(tagList(icon("list"), "Comprehensive Bowtie Elements:")),
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
                                    strong("Protective_Mitigation:"), " Measures to reduce impact")),
                     tags$li(tagList(icon("burst", class = "text-warning"), 
                                    strong("Consequence:"), " Final environmental outcomes")),
                     tags$li(tagList(icon("percent"), strong("Likelihood:"), " Probability (1-5)")),
                     tags$li(tagList(icon("bolt"), strong("Severity:"), " Impact severity (1-5)"))
                   ),
                   
                   div(class = "alert alert-info mt-3",
                       tagList(icon("info-circle"), " "),
                       strong("Multiple Pathways:"), " Activity → Pressure → Control → Escalation → Central Problem → Mitigation → Consequence"),
                   
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     hr(),
                     h6(tagList(icon("chart-bar"), "Data Summary:")),
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
          card_header(tagList(icon("eye"), "Data Preview"), class = "bg-success text-white"),
          card_body(
            withSpinner(DT::dataTableOutput("preview")),
            br(),
            div(class = "alert alert-info", tagList(icon("info-circle"), " "), 
                textOutput("debugInfo", inline = TRUE))
          )
        )
      )
    ),
    
    # Bowtie Visualization Tab
    nav_panel(
      title = tagList(icon("project-diagram"), "Comprehensive Bowtie"), value = "bowtie",
      
      fluidRow(
        column(4,
               card(
                 card_header(tagList(icon("cogs"), "Bowtie Controls"), class = "bg-primary text-white"),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     selectInput("selectedProblem", "Select Central Problem:", choices = NULL),
                     
                     hr(),
                     h6(tagList(icon("edit"), "Editing Mode:")),
                     checkboxInput("editMode", "Enable Network Editing", value = FALSE),
                     conditionalPanel(
                       condition = "input.editMode",
                       div(class = "alert alert-warning small",
                           tagList(icon("exclamation-triangle"), " "),
                           "Use manipulation toolbar in the network.")
                     ),
                     
                     hr(),
                     h6(tagList(icon("eye"), "Display Options:")),
                     checkboxInput("showBarriers", "Show Controls & Mitigation", value = TRUE),
                     checkboxInput("showRiskLevels", "Color by Risk Level", value = TRUE),
                     sliderInput("nodeSize", "Node Size:", min = 25, max = 80, value = 45),
                     
                     hr(),
                     h6(tagList(icon("plus"), "Quick Add:")),
                     textInput("newActivity", "New Activity:", placeholder = "Enter activity description"),
                     textInput("newPressure", "New Pressure:", placeholder = "Enter pressure/threat"),
                     textInput("newConsequence", "New Consequence:", placeholder = "Enter consequence"),
                     div(class = "d-grid", actionButton("addActivityChain", 
                                                       tagList(icon("plus-circle"), "Add to Current Problem"), 
                                                       class = "btn-outline-primary btn-sm")),
                     
                     hr(),
                     h6(tagList(icon("palette"), "Bowtie Visual Legend:")),
                     div(class = "p-3 border rounded bg-light",
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
                             span(tagList(icon("shield"), " Protective Mitigation"))),
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge" , style = "background-color: #E67E22; color: white; margin-right: 8px;", "⬢"),
                             span(tagList(icon("burst"), " Consequences (Environmental Impacts)"))),
                         hr(class = "my-2"),
                         div(class = "small text-muted",
                             strong("Visual Hierarchy:"), " Larger nodes = more critical elements"),
                         div(class = "small text-muted",
                             strong("Multiple Flow Paths:"), " Activity → Pressure → Control → Escalation → Central Problem → Mitigation → Consequence"),
                         div(class = "small text-muted",
                             strong("Line Types:"), " Solid = causal flow, Dashed = intervention/control effects")
                     ),
                     
                     hr(),
                     div(class = "d-grid", downloadButton("downloadBowtie", 
                                                         tagList(icon("download"), "Download Diagram"), 
                                                         class = "btn-success"))
                   )
                 )
               )
        ),
        
        column(8,
               card(
                 card_header(tagList(icon("sitemap"), "Comprehensive Bowtie Diagram"), class = "bg-success text-white"),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     div(class = "text-center mb-3",
                         h5(tagList(icon("water"), "Environmental Bowtie Risk Analysis"), class = "text-primary"),
                         p(class = "small text-muted", 
                           "Multiple interconnected pathways: Activities → Pressures → Controls → Escalation → Central Problem → Mitigation → Consequences")),
                     withSpinner(visNetworkOutput("bowtieNetwork", height = "650px"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("upload", class = "fa-3x text-muted mb-3"),
                         h4("Upload Data or Generate Sample Data", class = "text-muted"),
                         p("Please upload environmental data or generate sample data to view the comprehensive bowtie diagram", 
                           class = "text-muted"))
                   )
                 )
               )
        )
      )
    ),
    
    # Data Table Tab (Enhanced)
    nav_panel(
      title = tagList(icon("table"), "Data Table"), value = "table",
      
      fluidRow(
        column(12,
               card(
                 card_header(
                   div(class = "d-flex justify-content-between align-items-center",
                       tagList(icon("table"), "Multiple Pathway Environmental Bowtie Data"),
                       div(
                         conditionalPanel(
                           condition = "output.dataLoaded",
                           actionButton("addRow", tagList(icon("plus"), "Add Row"), 
                                      class = "btn-success btn-sm me-2"),
                           actionButton("deleteSelected", tagList(icon("trash"), "Delete Selected"), 
                                      class = "btn-danger btn-sm me-2"),
                           actionButton("saveChanges", tagList(icon("save"), "Save Changes"), 
                                      class = "btn-primary btn-sm")
                         )
                       )
                   ),
                   class = "bg-primary text-white"
                 ),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     div(class = "alert alert-info",
                         tagList(icon("info-circle"), " "),
                         "Click on any cell to edit. The table shows multiple interconnected pathways from activities to consequences."),
                     withSpinner(DT::dataTableOutput("editableTable"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("table", class = "fa-3x text-muted mb-3"),
                         h4("No Data Available", class = "text-muted"),
                         p("Please upload data or generate sample data to view the table", class = "text-muted"))
                   )
                 )
               )
        )
      )
    ),
    
    # Risk Matrix Tab
    nav_panel(
      title = tagList(icon("chart-line"), "Risk Matrix"), value = "matrix",
      
      fluidRow(
        column(8,
               card(
                 card_header(tagList(icon("chart-scatter"), "Environmental Risk Matrix"), 
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
                         h4("No Data Available", class = "text-muted"),
                         p("Please upload data or generate sample data to view the risk matrix", class = "text-muted"))
                   )
                 )
               )
        ),
        
        column(4,
               card(
                 card_header(tagList(icon("chart-pie"), "Risk Statistics"), class = "bg-info text-white"),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     withSpinner(tableOutput("riskStats"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-3",
                         icon("chart-pie", class = "fa-2x text-muted mb-2"),
                         p("No statistics available", class = "text-muted"))
                   )
                 )
               )
        )
      )
    )
  ),
  
  # Footer
  hr(),
  div(class = "text-center text-muted mb-3",
      p("Environmental Bowtie Risk Analysis Tool | v4.2.2 - Fixed Barrier Connections"))
)

# Define Server with enhanced structure
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
  
  # Data loading with validation
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
      showNotification("Data loaded successfully!", type = "default")
      
    }, error = function(e) {
      showNotification(paste("Error loading data:", e$message), type = "error")
    })
  })
  
  # Enhanced sample data generation
  observeEvent(input$generateSample, {
    showNotification("Generating multiple pathway sample data...", type = "default", duration = 2)
    
    tryCatch({
      sample_data <- generateEnvironmentalData()
      currentData(sample_data)
      editedData(sample_data)
      envDataGenerated(TRUE)
      dataVersion(dataVersion() + 1)
      clearCache()
      
      problem_choices <- unique(sample_data$Central_Problem)
      updateSelectInput(session, "selectedProblem", choices = problem_choices, selected = problem_choices[1])
      
      showNotification(paste("✓ Generated", nrow(sample_data), "interconnected environmental scenarios with multiple pathways"), 
                      type = "default", duration = 3)
      
    }, error = function(e) {
      showNotification(paste("❌ Error:", e$message), type = "error", duration = 5)
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
  
  # Data info with caching
  output$dataInfo <- renderText({
    data <- getCurrentData()
    req(data)
    getDataSummary(data)
  })
  
  # Download handler
  output$downloadSample <- downloadHandler(
    filename = function() paste("comprehensive_environmental_bowtie_", Sys.Date(), ".xlsx", sep = ""),
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
  
  # High-performance editable table with enhanced structure
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
        language = list(processing = "Loading comprehensive data...")
      ),
      editable = list(target = 'cell'),
      extensions = c('Buttons', 'Scroller'),
      class = 'cell-border stripe compact hover',
      filter = 'top'
    )
  })
  
  # Optimized cell editing with validation
  observeEvent(input$editableTable_cell_edit, {
    info <- input$editableTable_cell_edit
    data <- getCurrentData()
    req(data)
    
    # Validate row and column indices
    if (info$row > nrow(data) || info$col > ncol(data)) {
      showNotification("Invalid cell reference", type = "error")
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
    
    # Show success feedback less frequently for better performance
    if (runif(1) < 0.3) {  # Only show notification 30% of the time
      showNotification("Cell updated", type = "message", duration = 1)
    }
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # Track selected rows efficiently
  observe({
    selectedRows(input$editableTable_rows_selected)
  })
  
  # Row operations
  observeEvent(input$addRow, {
    data <- getCurrentData()
    req(data)
    
    selected_problem <- if (!is.null(input$selectedProblem)) input$selectedProblem else "New Environmental Risk"
    new_row <- createDefaultRow(selected_problem)
    updated_data <- rbind(data, new_row)
    
    editedData(updated_data)
    dataVersion(dataVersion() + 1)
    clearCache()
    showNotification("New row added!", type = "success", duration = 2)
  })
  
  observeEvent(input$deleteSelected, {
    rows <- selectedRows()
    if (!is.null(rows) && length(rows) > 0) {
      data <- getCurrentData()
      updated_data <- data[-rows, ]
      editedData(updated_data)
      dataVersion(dataVersion() + 1)
      clearCache()
      showNotification(paste("Deleted", length(rows), "row(s)"), type = "warning", duration = 2)
    } else {
      showNotification("No rows selected", type = "error", duration = 2)
    }
  })
  
  observeEvent(input$saveChanges, {
    edited <- editedData()
    if (!is.null(edited)) {
      currentData(edited)
      showNotification("Changes saved!", type = "success", duration = 2)
    }
  })
  
  # Enhanced quick add functionality
  observeEvent(input$addActivityChain, {
    req(input$selectedProblem, input$newActivity, input$newPressure, input$newConsequence)
    
    if (trimws(input$newActivity) == "" || trimws(input$newPressure) == "" || trimws(input$newConsequence) == "") {
      showNotification("Please enter activity, pressure, and consequence", type = "error")
      return()
    }
    
    data <- getCurrentData()
    new_row <- data.frame(
      Activity = input$newActivity,
      Pressure = input$newPressure,
      Preventive_Control = "To be defined",
      Escalation_Factor = "To be defined",
      Central_Problem = input$selectedProblem,
      Protective_Mitigation = "To be defined",
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
    showNotification("Activity chain added successfully!", type = "success", duration = 2)
  })
  
  # Debug info
  output$debugInfo <- renderText({
    data <- getCurrentData()
    if (!is.null(data)) {
      paste("Loaded:", nrow(data), "rows,", ncol(data), "columns - Multiple pathway bowtie structure")
    } else {
      "No data loaded"
    }
  })
  
  # Enhanced bowtie network with comprehensive structure
  output$bowtieNetwork <- renderVisNetwork({
    data <- getCurrentData()
    req(data, input$selectedProblem)
    
    problem_data <- data[data$Central_Problem == input$selectedProblem, ]
    if (nrow(problem_data) == 0) {
      showNotification("No data for selected central problem", type = "warning")
      return(NULL)
    }
    
    nodes <- createBowtieNodes(problem_data, input$selectedProblem, input$nodeSize, 
                              input$showRiskLevels, input$showBarriers)
    edges <- createBowtieEdges(problem_data, input$showBarriers)
    
    visNetwork(nodes, edges, 
               main = paste("Multiple Pathway Bowtie Analysis:", input$selectedProblem),
               submain = if(input$showBarriers) "Interconnected pathways with multiple controls and mitigation strategies" else "Direct causal relationships with multiple connections",
               footer = "Multiple Activities → Pressures → Controls → Escalation → Central Problem → Mitigation → Consequences") %>%
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
        list(label = "Protective Mitigation", 
             color = "#3498DB", shape = "square", size = 15),
        list(label = "Consequences (Impacts)", 
             color = "#E67E22", shape = "hexagon", size = 15)
      ), position = "right", width = 0.25, ncol = 1)
  })
  
  # Enhanced risk matrix
  output$riskMatrix <- renderPlotly({
    data <- getCurrentData()
    req(data, nrow(data) > 0)
    
    risk_plot <- ggplot(data, aes(x = Likelihood, y = Severity)) +
      geom_point(aes(color = Risk_Level, 
                     text = paste("Central Problem:", Central_Problem, 
                                 "<br>Activity:", Activity,
                                 "<br>Pressure:", Pressure,
                                 "<br>Consequence:", Consequence)),
                 size = 4, alpha = 0.7) +
      scale_color_manual(values = RISK_COLORS) +
      scale_x_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
      scale_y_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
      labs(title = "Multiple Pathway Environmental Risk Matrix", x = "Likelihood", y = "Severity") +
      theme_minimal() + theme(legend.position = "bottom")
    
    ggplotly(risk_plot, tooltip = "text")
  })
  
  # Risk statistics
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
      select(Icon, Risk_Level, Count = n, `Percentage (%)` = Percentage)
    
    risk_summary
  }, sanitize.text.function = function(x) x)
  
  # Download multiple pathway bowtie diagram
  output$downloadBowtie <- downloadHandler(
    filename = function() paste("multiple_pathway_bowtie_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".html"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)
      
      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodes(problem_data, input$selectedProblem, 50, FALSE, TRUE)
      edges <- createBowtieEdges(problem_data, TRUE)
      
      network <- visNetwork(nodes, edges, 
                          main = paste("Multiple Pathway Environmental Bowtie Analysis:", input$selectedProblem),
                          submain = paste("Generated on", Sys.Date(), "- Interconnected pathways with multiple connections"),
                          footer = "Multiple Activities → Pressures → Controls → Escalation → Central Problem → Mitigation → Consequences") %>%
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
          list(label = "Protective Mitigation", 
               color = "#3498DB", shape = "square", size = 15),
          list(label = "Consequences (Impacts)", 
               color = "#E67E22", shape = "hexagon", size = 15)
        ), position = "right", width = 0.25, ncol = 1)
      
      visSave(network, file, selfcontained = TRUE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)