# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application with Bootstrap Themes
# Version: 4.0.1 (Fixed)
# Date: June 2025
# Author: AI Assistant
# Description: Interactive bowtie analysis tool focused on environmental 
#              management with Bootstrap theming support
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
library(DiagrammeR)
library(visNetwork)
library(shinycssloaders)
library(colourpicker)
library(htmlwidgets)

# Define UI
ui <- fluidPage(
  # Set initial theme
  theme = bs_theme(version = 5, bootswatch = "journal"),
  
  # Theme controls at the top
  fluidRow(
    column(12,
           div(class = "bg-light p-3 mb-4 rounded shadow-sm",
               h4("🌊 Environmental Bowtie Risk Analysis", class = "mb-3 text-primary"),
               fluidRow(
                 column(3,
                        selectInput("theme_preset", "Theme:",
                                   choices = c("Default" = "default",
                                             "Dark" = "darkly", 
                                             "Ocean Blue" = "cosmo",
                                             "Forest Green" = "journal",
                                             "Environmental" = "materia",
                                             "Corporate" = "flatly",
                                             "Minimal" = "minty",
                                             "Custom" = "custom"),
                                   selected = "journal")
                 ),
                 column(2,
                        conditionalPanel(
                          condition = "input.theme_preset == 'custom'",
                          colourInput("primary_color", "Primary:", value = "#28a745")
                        )
                 ),
                 column(2,
                        conditionalPanel(
                          condition = "input.theme_preset == 'custom'", 
                          colourInput("secondary_color", "Secondary:", value = "#6c757d")
                        )
                 ),
                 column(5,
                        div(class = "text-end mt-2",
                            span(class = "badge bg-success", "v4.0.1"),
                            span(class = "text-muted ms-2", "Eutrophication Focus"))
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
      title = tagList(icon("upload"), "Data Upload"),
      value = "upload",
      
      fluidRow(
        column(6,
               card(
                 card_header(
                   tagList(icon("database"), "Data Input Options"),
                   class = "bg-primary text-white"
                 ),
                 card_body(
                   h5(tagList(icon("file-excel"), "Option 1: Upload Excel File")),
                   fileInput("file", "Choose Excel File:",
                            accept = c(".xlsx", ".xls"),
                            buttonLabel = "Browse...",
                            placeholder = "No file selected"),
                   
                   conditionalPanel(
                     condition = "output.fileUploaded",
                     selectInput("sheet", "Select Sheet:", choices = NULL),
                     div(class = "d-grid",
                         actionButton("loadData", 
                                     tagList(icon("upload"), "Load Data"), 
                                     class = "btn-primary"))
                   ),
                   
                   hr(),
                   
                   h5(tagList(icon("leaf"), "Option 2: Generate Sample Data")),
                   p("Generate comprehensive environmental management bowtie data with focus on eutrophication:"),
                   div(class = "d-grid",
                       actionButton("generateSample", 
                                   tagList(icon("seedling"), "Generate Environmental Data"), 
                                   class = "btn-success")),
                   
                   conditionalPanel(
                     condition = "output.envDataGenerated",
                     br(),
                     div(class = "d-grid",
                         downloadButton("downloadSample", 
                                       tagList(icon("download"), "Download as Excel"), 
                                       class = "btn-info"))
                   )
                 )
               )
        ),
        
        column(6,
               card(
                 card_header(
                   tagList(icon("info-circle"), "Data Structure Requirements"),
                   class = "bg-info text-white"
                 ),
                 card_body(
                   h6(tagList(icon("list"), "Required Columns:")),
                   p("Your Excel file should contain environmental risk data with these columns:"),
                   tags$ul(
                     tags$li(tagList(icon("triangle-exclamation", class = "text-danger"), 
                                    strong("Threat:"), " Environmental threat (e.g., agricultural runoff)")),
                     tags$li(tagList(icon("radiation", class = "text-warning"), 
                                    strong("Hazard:"), " Environmental hazard (e.g., eutrophication)")),
                     tags$li(tagList(icon("burst", class = "text-danger"), 
                                    strong("Consequence:"), " Environmental impacts (e.g., fish kills)")),
                     tags$li(tagList(icon("shield-halved", class = "text-success"), 
                                    strong("Preventive_Barrier:"), " Prevention measures")),
                     tags$li(tagList(icon("shield", class = "text-info"), 
                                    strong("Protective_Barrier:"), " Mitigation measures")),
                     tags$li(tagList(icon("percent"), strong("Likelihood:"), " Probability (1-5)")),
                     tags$li(tagList(icon("bolt"), strong("Severity:"), " Impact severity (1-5)")),
                     tags$li(tagList(icon("chart-line"), strong("Risk_Level:"), " Overall risk level"))
                   ),
                   
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
          card_header(
            tagList(icon("eye"), "Data Preview"),
            class = "bg-success text-white"
          ),
          card_body(
            withSpinner(DT::dataTableOutput("preview")),
            br(),
            div(class = "alert alert-info",
                tagList(icon("info-circle"), " "),
                textOutput("debugInfo", inline = TRUE))
          )
        )
      )
    ),
    
    # Bowtie Visualization Tab
    nav_panel(
      title = tagList(icon("project-diagram"), "Bowtie Visualization"),
      value = "bowtie",
      
      fluidRow(
        column(4,
               card(
                 card_header(
                   tagList(icon("cogs"), "Bowtie Controls"),
                   class = "bg-primary text-white"
                 ),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     selectInput("selectedHazard", "Select Hazard:", choices = NULL),
                     
                     hr(),
                     h6(tagList(icon("edit"), "Editing Mode:")),
                     div(class = "form-check",
                         checkboxInput("editMode", "Enable Network Editing", value = FALSE)),
                     conditionalPanel(
                       condition = "input.editMode",
                       div(class = "alert alert-warning small",
                           tagList(icon("exclamation-triangle"), " "),
                           "Use manipulation toolbar in the network to add/edit/delete nodes and edges.")
                     ),
                     
                     hr(),
                     h6(tagList(icon("eye"), "Display Options:")),
                     div(class = "form-check",
                         checkboxInput("showBarriers", "Show Barriers", value = TRUE)),
                     div(class = "form-check",
                         checkboxInput("showRiskLevels", "Color by Risk Level", value = TRUE)),
                     sliderInput("nodeSize", "Node Size:", min = 20, max = 60, value = 40),
                     
                     hr(),
                     h6(tagList(icon("plus"), "Quick Add:")),
                     textInput("newThreat", "New Threat:", placeholder = "Enter threat description"),
                     textInput("newConsequence", "New Consequence:", placeholder = "Enter consequence description"),
                     div(class = "d-grid",
                         actionButton("addThreatConsequence", 
                                     tagList(icon("plus-circle"), "Add to Current Hazard"), 
                                     class = "btn-outline-primary btn-sm")),
                     
                     hr(),
                     h6(tagList(icon("palette"), "Bowtie Legend:")),
                     div(class = "p-3 border rounded bg-light",
                         div(class = "d-flex align-items-center mb-2",
                             span(class = "badge bg-danger me-2", "▲"),
                             span(tagList(icon("triangle-exclamation"), " Threats"))),
                         div(class = "d-flex align-items-center mb-2",
                             span(class = "badge bg-warning me-2", "♦"),
                             span(tagList(icon("radiation"), " Hazards"))),
                         div(class = "d-flex align-items-center mb-2",
                             span(class = "badge bg-info me-2", "⬟"),
                             span(tagList(icon("burst"), " Consequences"))),
                         div(class = "d-flex align-items-center mb-2",
                             span(class = "badge bg-success me-2", "◼"),
                             span(tagList(icon("shield-halved"), " Preventive Barriers"))),
                         div(class = "d-flex align-items-center",
                             span(class = "badge bg-primary me-2", "◼"),
                             span(tagList(icon("shield"), " Protective Barriers")))
                     ),
                     
                     hr(),
                     div(class = "d-grid",
                         downloadButton("downloadBowtie", 
                                       tagList(icon("download"), "Download Diagram"), 
                                       class = "btn-success"))
                   )
                 )
               )
        ),
        
        column(8,
               card(
                 card_header(
                   tagList(icon("sitemap"), "Interactive Bowtie Diagram"),
                   class = "bg-success text-white"
                 ),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     div(class = "text-center mb-3",
                         h5(tagList(icon("water"), "Environmental Bowtie Risk Analysis"),
                            class = "text-primary")),
                     withSpinner(visNetworkOutput("bowtieNetwork", height = "600px"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("upload", class = "fa-3x text-muted mb-3"),
                         h4("Upload Data or Generate Sample Data", class = "text-muted"),
                         p("Please upload environmental data or generate sample data to view the bowtie diagram", 
                           class = "text-muted"))
                   )
                 )
               )
        )
      )
    ),
    
    # Data Table Tab
    nav_panel(
      title = tagList(icon("table"), "Data Table"),
      value = "table",
      
      fluidRow(
        column(12,
               card(
                 card_header(
                   div(class = "d-flex justify-content-between align-items-center",
                       tagList(icon("table"), "Environmental Bowtie Data"),
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
                         "Click on any cell to edit. Select rows and use buttons above to add/delete entries."),
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
      ),
      
      # Read-only table for reference
      br(),
      fluidRow(
        column(12,
               card(
                 card_header(
                   tagList(icon("eye"), "Read-Only View"),
                   class = "bg-secondary text-white"
                 ),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     withSpinner(DT::dataTableOutput("fullTable"))
                   )
                 )
               )
        )
      )
    ),
    
    # Risk Matrix Tab
    nav_panel(
      title = tagList(icon("chart-line"), "Risk Matrix"),
      value = "matrix",
      
      fluidRow(
        column(8,
               card(
                 card_header(
                   tagList(icon("chart-scatter"), "Environmental Risk Matrix"),
                   class = "bg-primary text-white"
                 ),
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
                 card_header(
                   tagList(icon("chart-pie"), "Risk Statistics"),
                   class = "bg-info text-white"
                 ),
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
      p("Environmental Bowtie Risk Analysis Tool | Focus on Eutrophication Scenarios"))
)

# Define Server
server <- function(input, output, session) {
  
  # 1. Define reactive values FIRST
  values <- reactiveValues(
    data = NULL,
    sheets = NULL,
    envDataGenerated = FALSE,
    editedData = NULL,
    selectedRows = NULL
  )
  
  # 2. Define helper functions at server level
  getCurrentData <- reactive({
    if (!is.null(values$editedData)) {
      return(values$editedData)
    } else {
      return(values$data)
    }
  })
  
  updateData <- function(newData) {
    values$editedData <- newData
    if (!is.null(newData) && nrow(newData) > 0) {
      hazard_choices <- unique(newData$Hazard)
      updateSelectInput(session, "selectedHazard", 
                       choices = hazard_choices, 
                       selected = if (input$selectedHazard %in% hazard_choices) input$selectedHazard else hazard_choices[1])
    }
  }
  
  # 3. Define current_theme reactive PROPERLY
  current_theme <- reactive({
    if (input$theme_preset == "custom") {
      bs_theme(
        version = 5,
        primary = input$primary_color,
        secondary = input$secondary_color
      )
    } else if (input$theme_preset == "default") {
      bs_theme(version = 5)
    } else {
      bs_theme(version = 5, bootswatch = input$theme_preset)
    }
  })
  
  # 4. Apply theme with error handling
  observe({
    tryCatch({
      session$setCurrentTheme(current_theme())
    }, error = function(e) {
      cat("Theme switching warning:", e$message, "\n")
    })
  })
  
  # 5. Function to generate environmental management sample data
  generateEnvironmentalData <- function() {
    cat("Generating comprehensive environmental management data with eutrophication focus\n")
    
    sample_data <- data.frame(
      # Eutrophication scenarios - expanded section
      Threat = c(
        # Eutrophication threats (expanded)
        "Agricultural fertilizer runoff", "Agricultural fertilizer runoff", "Agricultural fertilizer runoff",
        "Urban stormwater runoff", "Urban stormwater runoff", "Urban stormwater runoff", 
        "Sewage treatment overflow", "Sewage treatment overflow", "Sewage treatment overflow",
        "Animal waste from farms", "Animal waste from farms", "Animal waste from farms",
        "Septic system leakage", "Septic system leakage", "Septic system leakage",
        "Industrial nutrient discharge", "Industrial nutrient discharge", "Industrial nutrient discharge",
        "Atmospheric nitrogen deposition", "Atmospheric nitrogen deposition", "Atmospheric nitrogen deposition",
        "Aquaculture operations", "Aquaculture operations", "Aquaculture operations",
        
        # Other environmental threats
        "Industrial wastewater discharge", "Industrial wastewater discharge", 
        "Improper waste disposal", "Vehicle emissions", "Deforestation", "Chemical spill",
        "Construction activities", "Mining operations", "Climate change", "Invasive species introduction"
      ),
      
      Hazard = c(
        # Eutrophication hazards (expanded)
        "Eutrophication", "Eutrophication", "Eutrophication",
        "Eutrophication", "Eutrophication", "Eutrophication",
        "Eutrophication", "Eutrophication", "Eutrophication", 
        "Eutrophication", "Eutrophication", "Eutrophication",
        "Eutrophication", "Eutrophication", "Eutrophication",
        "Eutrophication", "Eutrophication", "Eutrophication",
        "Eutrophication", "Eutrophication", "Eutrophication",
        "Eutrophication", "Eutrophication", "Eutrophication",
        
        # Other environmental hazards  
        "Water pollution", "Water pollution", "Soil contamination", "Air pollution", 
        "Habitat loss", "Toxic release", "Erosion and sedimentation", 
        "Acid mine drainage", "Temperature rise", "Ecosystem disruption"
      ),
      
      Consequence = c(
        # Eutrophication consequences (expanded)
        "Algal blooms", "Dead zones formation", "Fish kills",
        "Oxygen depletion", "Water quality degradation", "Drinking water contamination",
        "Ecosystem collapse", "Biodiversity loss", "Recreational water closure",
        "Economic losses to fisheries", "Tourism impact", "Public health risks", 
        "Habitat destruction", "Food web disruption", "Water treatment costs",
        "Beach closures", "Shellfish bed closure", "Swimming restrictions",
        "Toxic algae production", "Aquatic vegetation loss", "Sediment contamination",
        "Commercial fishing ban", "Property value decline", "Restoration costs",
        
        # Other environmental consequences
        "Aquatic ecosystem damage", "Drinking water contamination", "Crop contamination", "Respiratory diseases",
        "Species extinction", "Wildlife poisoning", "Sedimentation of waterways", 
        "Water source contamination", "Extreme weather events", "Native species displacement"
      ),
      
      Preventive_Barrier = c(
        # Eutrophication prevention barriers (expanded)
        "Nutrient management plans", "Buffer strip implementation", "Precision agriculture techniques",
        "Stormwater management systems", "Green infrastructure", "Permeable pavement installation",
        "Wastewater treatment upgrades", "Combined sewer overflow controls", "Tertiary treatment systems",
        "Livestock exclusion fencing", "Manure management protocols", "Rotational grazing systems",
        "Septic system inspections", "Advanced septic technologies", "Centralized wastewater systems",
        "Industrial discharge permits", "Nutrient trading programs", "Best management practices",
        "Emission reduction strategies", "Agricultural policy reforms", "Land use regulations",
        "Aquaculture best practices", "Feed optimization programs", "Waste minimization protocols",
        
        # Other prevention barriers
        "Wastewater treatment", "Discharge permits", "Waste management protocols", "Emission controls",
        "Protected area designation", "Spill prevention plans", "Environmental impact assessment", 
        "Mine closure planning", "Carbon reduction strategies", "Biosecurity measures"
      ),
      
      Protective_Barrier = c(
        # Eutrophication protection barriers (expanded)
        "Water quality monitoring", "Algal bloom early warning systems", "Nutrient load tracking",
        "Emergency water treatment", "Alternative water supplies", "Public health advisories",
        "Lake aeration systems", "Biomanipulation programs", "Restoration projects",
        "Fishery restocking programs", "Habitat rehabilitation", "Wetland construction",
        "Drinking water alerts", "Recreation advisories", "Beach monitoring programs",
        "Economic compensation programs", "Tourism recovery plans", "Community support",
        "Cleanup operations", "Sediment removal", "Phosphorus inactivation",
        "Medical monitoring", "Alternative recreation sites", "Water treatment subsidies",
        
        # Other protection barriers  
        "Water quality monitoring", "Emergency response", "Soil testing and cleanup", "Air quality alerts",
        "Species reintroduction", "Emergency containment", "Sediment management", 
        "Long-term monitoring", "Adaptation measures", "Control programs"
      ),
      
      Likelihood = c(
        # Eutrophication likelihoods (higher for agricultural and urban sources)
        4, 4, 4, 4, 4, 4, 3, 3, 3, 4, 4, 4, 3, 3, 3, 3, 3, 3, 2, 2, 2, 3, 3, 3,
        # Other environmental likelihoods
        4, 4, 3, 5, 4, 2, 4, 3, 5, 2
      ),
      
      Severity = c(
        # Eutrophication severities (high for ecosystem and health impacts)
        4, 5, 5, 4, 4, 5, 5, 5, 3, 4, 3, 4, 4, 4, 3, 3, 4, 3, 5, 4, 3, 4, 2, 4,
        # Other environmental severities  
        4, 5, 4, 3, 5, 5, 3, 5, 5, 3
      ),
      
      stringsAsFactors = FALSE
    )
    
    # Calculate Risk_Level with bounds checking
    sample_data$Risk_Level <- ifelse(sample_data$Likelihood * sample_data$Severity <= 6, "Low",
                                    ifelse(sample_data$Likelihood * sample_data$Severity <= 15, "Medium", "High"))
    
    cat("Generated", nrow(sample_data), "rows of environmental data with", 
        sum(sample_data$Hazard == "Eutrophication"), "eutrophication scenarios\n")
    return(sample_data)
  }
  
  # File upload handling
  observeEvent(input$file, {
    req(input$file)
    
    tryCatch({
      values$sheets <- excel_sheets(input$file$datapath)
      updateSelectInput(session, "sheet", choices = values$sheets, selected = values$sheets[1])
    }, error = function(e) {
      showNotification("Error reading Excel file", type = "error")
    })
  })
  
  output$fileUploaded <- reactive({
    return(!is.null(input$file))
  })
  outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)
  
  # Load data from Excel
  observeEvent(input$loadData, {
    req(input$file, input$sheet)
    
    tryCatch({
      data <- read_excel(input$file$datapath, sheet = input$sheet)
      
      # Validate required columns
      required_cols <- c("Threat", "Hazard", "Consequence")
      missing_cols <- setdiff(required_cols, names(data))
      
      if (length(missing_cols) > 0) {
        showNotification(paste("Missing required columns:", paste(missing_cols, collapse = ", ")), 
                        type = "error")
        return()
      }
      
      # Add default columns if missing
      if (!"Preventive_Barrier" %in% names(data)) data$Preventive_Barrier <- ""
      if (!"Protective_Barrier" %in% names(data)) data$Protective_Barrier <- ""
      if (!"Likelihood" %in% names(data)) data$Likelihood <- sample(1:5, nrow(data), replace = TRUE)
      if (!"Severity" %in% names(data)) data$Severity <- sample(1:5, nrow(data), replace = TRUE)
      if (!"Risk_Level" %in% names(data)) {
        data$Risk_Level <- ifelse(data$Likelihood * data$Severity <= 6, "Low",
                                 ifelse(data$Likelihood * data$Severity <= 15, "Medium", "High"))
      }
      
      values$data <- data
      values$editedData <- data  # Initialize edited data
      updateSelectInput(session, "selectedHazard", choices = unique(data$Hazard))
      showNotification("Data loaded successfully!", type = "default")
      
    }, error = function(e) {
      showNotification(paste("Error loading data:", e$message), type = "error")
    })
  })
  
  # Generate environmental sample data
  observeEvent(input$generateSample, {
    cat("Generate button clicked for environmental data\n")
    
    showNotification("Generating environmental sample data...", type = "default", duration = 2)
    
    tryCatch({
      sample_data <- generateEnvironmentalData()
      cat("Environmental data generated successfully, rows:", nrow(sample_data), "\n")
      
      values$data <- sample_data
      values$editedData <- sample_data  # Initialize edited data
      values$envDataGenerated <- TRUE
      
      cat("Data stored in values$data\n")
      
      hazard_choices <- unique(sample_data$Hazard)
      updateSelectInput(session, "selectedHazard", 
                       choices = hazard_choices, 
                       selected = hazard_choices[1])
      
      showNotification(paste("✓ Success! Generated", nrow(sample_data), "environmental scenarios with", 
                            length(hazard_choices), "hazards"), 
                      type = "default", duration = 5)
      
    }, error = function(e) {
      cat("Error generating environmental data:", e$message, "\n")
      showNotification(paste("❌ Error:", e$message), type = "error", duration = 10)
    })
  })
  
  output$envDataGenerated <- reactive({
    return(values$envDataGenerated)
  })
  outputOptions(output, "envDataGenerated", suspendWhenHidden = FALSE)
  
  output$dataLoaded <- reactive({
    current_data <- getCurrentData()
    result <- !is.null(current_data) && nrow(current_data) > 0
    cat("dataLoaded reactive called, result:", result, "\n")
    return(result)
  })
  outputOptions(output, "dataLoaded", suspendWhenHidden = FALSE)
  
  # Data info output
  output$dataInfo <- renderText({
    current_data <- getCurrentData()
    req(current_data)
    paste(
      "Rows:", nrow(current_data), "\n",
      "Hazards:", length(unique(current_data$Hazard)), "\n",
      "Threats:", length(unique(current_data$Threat)), "\n",
      "Consequences:", length(unique(current_data$Consequence)), "\n",
      "Risk Levels:", paste(names(table(current_data$Risk_Level)), collapse = ", ")
    )
  })
  
  # Download sample data as Excel
  output$downloadSample <- downloadHandler(
    filename = function() {
      paste("environmental_bowtie_data_", Sys.Date(), ".xlsx", sep = "")
    },
    content = function(file) {
      current_data <- getCurrentData()
      req(current_data)
      openxlsx::write.xlsx(current_data, file, rowNames = FALSE)
    }
  )
  
  # Data preview
  output$preview <- DT::renderDataTable({
    current_data <- getCurrentData()
    req(current_data)
    DT::datatable(head(current_data, 100), 
                  options = list(scrollX = TRUE, pageLength = 10, autoWidth = TRUE),
                  class = 'cell-border stripe')
  })
  
  # Editable data table
  output$editableTable <- DT::renderDataTable({
    current_data <- getCurrentData()
    req(current_data)
    DT::datatable(
      current_data, 
      options = list(
        scrollX = TRUE, 
        pageLength = 15,
        selection = 'multiple'
      ),
      editable = list(
        target = 'cell',
        disable = list(columns = NULL)  # Allow editing all columns
      ),
      class = 'cell-border stripe',
      filter = 'top'
    )
  })
  
  # Handle table edits with validation
  observeEvent(input$editableTable_cell_edit, {
    info <- input$editableTable_cell_edit
    current_data <- getCurrentData()
    
    # Column names for reference (1-indexed)
    col_names <- names(current_data)
    
    # Validate numeric columns (Likelihood and Severity)
    if (col_names[info$col] %in% c("Likelihood", "Severity")) {
      new_value <- as.numeric(info$value)
      if (is.na(new_value) || new_value < 1 || new_value > 5) {
        showNotification("Likelihood and Severity must be between 1 and 5", type = "error")
        return()
      }
      current_data[info$row, info$col] <- new_value
    } else {
      current_data[info$row, info$col] <- info$value
    }
    
    # Recalculate Risk_Level if Likelihood or Severity changed
    if (col_names[info$col] %in% c("Likelihood", "Severity")) {
      likelihood <- as.numeric(current_data[info$row, "Likelihood"])
      severity <- as.numeric(current_data[info$row, "Severity"])
      risk_score <- likelihood * severity
      current_data[info$row, "Risk_Level"] <- ifelse(risk_score <= 6, "Low",
                                                     ifelse(risk_score <= 15, "Medium", "High"))
    }
    
    updateData(current_data)
    showNotification("Cell updated successfully!", type = "default", duration = 2)
  })
  
  # Track selected rows
  observe({
    values$selectedRows <- input$editableTable_rows_selected
  })
  
  # Add new row functionality
  observeEvent(input$addRow, {
    current_data <- getCurrentData()
    req(current_data)
    
    # Create new row with default values
    new_row <- data.frame(
      Threat = "New Threat",
      Hazard = if (!is.null(input$selectedHazard)) input$selectedHazard else "New Hazard",
      Consequence = "New Consequence",
      Preventive_Barrier = "New Preventive Barrier",
      Protective_Barrier = "New Protective Barrier",
      Likelihood = 3,
      Severity = 3,
      Risk_Level = "Medium",
      stringsAsFactors = FALSE
    )
    
    updated_data <- rbind(current_data, new_row)
    updateData(updated_data)
    showNotification("New row added successfully!", type = "success", duration = 3)
  })
  
  # Delete selected rows
  observeEvent(input$deleteSelected, {
    if (!is.null(values$selectedRows) && length(values$selectedRows) > 0) {
      current_data <- getCurrentData()
      updated_data <- current_data[-values$selectedRows, ]
      updateData(updated_data)
      showNotification(paste("Deleted", length(values$selectedRows), "row(s)"), type = "warning", duration = 3)
    } else {
      showNotification("No rows selected for deletion", type = "error", duration = 3)
    }
  })
  
  # Save changes (update original data)
  observeEvent(input$saveChanges, {
    if (!is.null(values$editedData)) {
      values$data <- values$editedData
      showNotification("Changes saved successfully!", type = "success", duration = 3)
    }
  })
  
  # Quick add threat/consequence to current hazard
  observeEvent(input$addThreatConsequence, {
    req(input$selectedHazard)
    
    # Validate inputs
    if (trimws(input$newThreat) == "" || trimws(input$newConsequence) == "") {
      showNotification("Please enter both threat and consequence", type = "error")
      return()
    }
    
    current_data <- getCurrentData()
    
    # Create new row with quick add data
    new_row <- data.frame(
      Threat = input$newThreat,
      Hazard = input$selectedHazard,
      Consequence = input$newConsequence,
      Preventive_Barrier = "To be defined",
      Protective_Barrier = "To be defined",
      Likelihood = 3,
      Severity = 3,
      Risk_Level = "Medium",
      stringsAsFactors = FALSE
    )
    
    updated_data <- rbind(current_data, new_row)
    updateData(updated_data)
    
    # Clear input fields
    updateTextInput(session, "newThreat", value = "")
    updateTextInput(session, "newConsequence", value = "")
    
    showNotification("Threat and consequence added successfully!", type = "success", duration = 3)
  })
  
  # Full data table (read-only)
  output$fullTable <- DT::renderDataTable({
    current_data <- getCurrentData()
    req(current_data)
    DT::datatable(current_data, 
                  options = list(scrollX = TRUE, pageLength = 15),
                  filter = "top",
                  class = 'cell-border stripe')
  })
  
  # Debug info
  output$debugInfo <- renderText({
    current_data <- getCurrentData()
    if (!is.null(current_data)) {
      paste("Debug: Data loaded successfully with", nrow(current_data), "rows and", ncol(current_data), "columns")
    } else {
      "Debug: No data loaded"
    }
  })
  
  # Bowtie Network Visualization with editing capabilities
  output$bowtieNetwork <- renderVisNetwork({
    current_data <- getCurrentData()
    req(current_data, input$selectedHazard)
    
    # Filter data for selected hazard
    hazard_data <- current_data[current_data$Hazard == input$selectedHazard, ]
    
    if (nrow(hazard_data) == 0) {
      showNotification("No data for selected hazard", type = "warning")
      return(NULL)
    }
    
    # Create nodes with bowtie-specific styling
    nodes <- data.frame(
      id = integer(),
      label = character(),
      group = character(),
      color = character(),
      shape = character(),
      size = numeric(),
      font.size = numeric(),
      stringsAsFactors = FALSE
    )
    
    # Add hazard node (center) - Diamond shape for central hazard
    nodes <- rbind(nodes, data.frame(
      id = 1,
      label = input$selectedHazard,
      group = "hazard",
      color = "#FFD700",
      shape = "diamond",
      size = input$nodeSize * 1.5,
      font.size = 16
    ))
    
    # Add threat nodes (left side) - Triangular for threats/initiating events
    threats <- unique(hazard_data$Threat[hazard_data$Threat != ""])
    for (i in seq_along(threats)) {
      color <- if (input$showRiskLevels) {
        threat_risk <- hazard_data$Risk_Level[hazard_data$Threat == threats[i]][1]
        switch(threat_risk,
               "Low" = "#90EE90",
               "Medium" = "#FFD700", 
               "High" = "#FF6B6B",
               "#FFCCCB")
      } else "#FF6B6B"
      
      nodes <- rbind(nodes, data.frame(
        id = 100 + i,
        label = threats[i],
        group = "threat",
        color = color,
        shape = "triangle",
        size = input$nodeSize,
        font.size = 12
      ))
    }
    
    # Add consequence nodes (right side) - Hexagonal for consequences/impacts
    consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
    for (i in seq_along(consequences)) {
      color <- if (input$showRiskLevels) {
        cons_risk <- hazard_data$Risk_Level[hazard_data$Consequence == consequences[i]][1]
        switch(cons_risk,
               "Low" = "#90EE90",
               "Medium" = "#FFD700",
               "High" = "#FF6B6B",
               "#FFB6C1")
      } else "#FF8C94"
      
      nodes <- rbind(nodes, data.frame(
        id = 200 + i,
        label = consequences[i],
        group = "consequence",
        color = color,
        shape = "hexagon",
        size = input$nodeSize,
        font.size = 12
      ))
    }
    
    # Add barrier nodes if requested - Square shapes for barriers
    if (input$showBarriers) {
      prev_barriers <- unique(hazard_data$Preventive_Barrier[hazard_data$Preventive_Barrier != ""])
      for (i in seq_along(prev_barriers)) {
        nodes <- rbind(nodes, data.frame(
          id = 300 + i,
          label = prev_barriers[i],
          group = "preventive_barrier",
          color = "#4ECDC4",
          shape = "box",
          size = input$nodeSize * 0.8,
          font.size = 10
        ))
      }
      
      prot_barriers <- unique(hazard_data$Protective_Barrier[hazard_data$Protective_Barrier != ""])
      for (i in seq_along(prot_barriers)) {
        nodes <- rbind(nodes, data.frame(
          id = 400 + i,
          label = prot_barriers[i],
          group = "protective_barrier",
          color = "#45B7D1",
          shape = "box",
          size = input$nodeSize * 0.8,
          font.size = 10
        ))
      }
    }
    
    # Create edges with different styles
    edges <- data.frame(
      from = integer(),
      to = integer(),
      arrows = character(),
      color = character(),
      width = numeric(),
      dashes = logical(),
      stringsAsFactors = FALSE
    )
    
    # Threat to hazard edges - Solid red arrows
    for (i in seq_along(threats)) {
      edges <- rbind(edges, data.frame(
        from = 100 + i,
        to = 1,
        arrows = "to",
        color = "#E74C3C",
        width = 3,
        dashes = FALSE
      ))
    }
    
    # Hazard to consequence edges - Solid red arrows
    for (i in seq_along(consequences)) {
      edges <- rbind(edges, data.frame(
        from = 1,
        to = 200 + i,
        arrows = "to",
        color = "#E74C3C",
        width = 3,
        dashes = FALSE
      ))
    }
    
    # Barrier edges if shown - Different styles for preventive vs protective
    if (input$showBarriers) {
      # Preventive barriers - Green dashed lines blocking threats
      for (i in seq_along(prev_barriers)) {
        related_threats <- hazard_data$Threat[hazard_data$Preventive_Barrier == prev_barriers[i]]
        for (threat in related_threats) {
          threat_id <- which(threats == threat) + 100
          if (length(threat_id) > 0) {
            edges <- rbind(edges, data.frame(
              from = 300 + i,
              to = threat_id,
              arrows = "to",
              color = "#27AE60",
              width = 2,
              dashes = TRUE
            ))
          }
        }
      }
      
      # Protective barriers - Blue dashed lines mitigating consequences
      for (i in seq_along(prot_barriers)) {
        related_cons <- hazard_data$Consequence[hazard_data$Protective_Barrier == prot_barriers[i]]
        for (cons in related_cons) {
          cons_id <- which(consequences == cons) + 200
          if (length(cons_id) > 0) {
            edges <- rbind(edges, data.frame(
              from = cons_id,
              to = 400 + i,
              arrows = "to",
              color = "#3498DB",
              width = 2,
              dashes = TRUE
            ))
          }
        }
      }
    }
    
    # Create network with bowtie-specific layout
    visNetwork(nodes, edges) %>%
      visNodes(
        borderWidth = 2,
        shadow = list(enabled = TRUE, size = 5),
        font = list(color = "#2C3E50", face = "Arial")
      ) %>%
      visEdges(
        arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
        smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)
      ) %>%
      visLayout(
        randomSeed = 123,
        hierarchical = list(
          enabled = TRUE,
          direction = "LR",
          sortMethod = "directed",
          levelSeparation = 200,
          nodeSpacing = 150
        )
      ) %>%
      visPhysics(enabled = FALSE) %>%
      visOptions(
        highlightNearest = list(enabled = TRUE, degree = 1),
        nodesIdSelection = TRUE,
        collapse = FALSE,
        manipulation = if(input$editMode) {
          list(
            enabled = TRUE,
            addNode = TRUE,
            addEdge = TRUE,
            editNode = TRUE,
            editEdge = TRUE,
            deleteNode = TRUE,
            deleteEdge = TRUE
          )
        } else {
          list(enabled = FALSE)
        }
      ) %>%
      visInteraction(
        navigationButtons = TRUE,
        dragNodes = TRUE,
        dragView = TRUE,
        zoomView = TRUE
      )
  })
  
  # Risk Matrix
  output$riskMatrix <- renderPlotly({
    current_data <- getCurrentData()
    req(current_data)
    req(nrow(current_data) > 0)
    
    risk_plot <- ggplot(current_data, aes(x = Likelihood, y = Severity)) +
      geom_point(aes(color = Risk_Level, text = paste("Hazard:", Hazard, 
                                                      "<br>Threat:", Threat,
                                                      "<br>Consequence:", Consequence)),
                 size = 4, alpha = 0.7) +
      scale_color_manual(values = c("Low" = "#90EE90", "Medium" = "#FFD700", "High" = "#FF6B6B")) +
      scale_x_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
      scale_y_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
      labs(title = "Environmental Risk Matrix", x = "Likelihood", y = "Severity") +
      theme_minimal() +
      theme(legend.position = "bottom")
    
    ggplotly(risk_plot, tooltip = "text")
  })
  
  # Risk Statistics with icons
  output$riskStats <- renderTable({
    current_data <- getCurrentData()
    req(current_data)
    req(nrow(current_data) > 0)
    
    risk_summary <- current_data %>%
      group_by(Risk_Level) %>%
      summarise(
        Count = n(),
        Percentage = round(n() / nrow(current_data) * 100, 1),
        .groups = "drop"
      )
    
    # Add icon column
    risk_summary$Icon <- ifelse(risk_summary$Risk_Level == "High", "🔴",
                               ifelse(risk_summary$Risk_Level == "Medium", "🟡", "🟢"))
    
    risk_summary <- risk_summary[, c("Icon", "Risk_Level", "Count", "Percentage")]
    names(risk_summary) <- c("", "Risk Level", "Count", "Percentage (%)")
    
    risk_summary
  }, sanitize.text.function = function(x) x)
  
  # Download handler for bowtie diagram
  output$downloadBowtie <- downloadHandler(
    filename = function() {
      paste("environmental_bowtie_", gsub(" ", "_", input$selectedHazard), "_", Sys.Date(), ".html", sep = "")
    },
    content = function(file) {
      current_data <- getCurrentData()
      req(current_data, input$selectedHazard)
      
      # Filter data for selected hazard
      hazard_data <- current_data[current_data$Hazard == input$selectedHazard, ]
      
      # Recreate the nodes and edges (same logic as in the main network)
      nodes <- data.frame(
        id = 1,
        label = input$selectedHazard,
        color = "#FFD700",
        shape = "diamond",
        size = 60,
        font.size = 16,
        stringsAsFactors = FALSE
      )
      
      threats <- unique(hazard_data$Threat[hazard_data$Threat != ""])
      for (i in seq_along(threats)) {
        nodes <- rbind(nodes, data.frame(
          id = 100 + i,
          label = threats[i],
          color = "#FF6B6B",
          shape = "triangle",
          size = 40,
          font.size = 12
        ))
      }
      
      consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
      for (i in seq_along(consequences)) {
        nodes <- rbind(nodes, data.frame(
          id = 200 + i,
          label = consequences[i],
          color = "#FF8C94",
          shape = "hexagon",
          size = 40,
          font.size = 12
        ))
      }
      
      edges <- data.frame(
        from = integer(),
        to = integer(),
        arrows = character(),
        color = character(),
        width = numeric(),
        stringsAsFactors = FALSE
      )
      
      for (i in seq_along(threats)) {
        edges <- rbind(edges, data.frame(
          from = 100 + i,
          to = 1,
          arrows = "to",
          color = "#E74C3C",
          width = 3
        ))
      }
      
      for (i in seq_along(consequences)) {
        edges <- rbind(edges, data.frame(
          from = 1,
          to = 200 + i,
          arrows = "to",
          color = "#E74C3C",
          width = 3
        ))
      }
      
      # Create and save the network
      network <- visNetwork(nodes, edges, 
                          main = paste("Environmental Bowtie Analysis:", input$selectedHazard),
                          submain = paste("Generated on", Sys.Date()),
                          footer = "Environmental Risk Management System") %>%
        visNodes(
          borderWidth = 2,
          shadow = list(enabled = TRUE, size = 5),
          font = list(color = "#2C3E50", face = "Arial")
        ) %>%
        visEdges(
          arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
          smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)
        ) %>%
        visLayout(
          randomSeed = 123,
          hierarchical = list(
            enabled = TRUE,
            direction = "LR",
            sortMethod = "directed",
            levelSeparation = 200,
            nodeSpacing = 150
          )
        ) %>%
        visPhysics(enabled = FALSE)
      
      # Use visSave to export
      visSave(network, file, selfcontained = TRUE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)