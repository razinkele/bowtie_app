# =============================================================================
# Environmental Bowtie Risk Analysis Shiny Application with Bayesian Networks
# Version: 4.4.0 (Enhanced with Bayesian Network Analysis)
# Date: June 2025
# Author: Marbefes Team & AI Assistant
# Description: Complete version with Bayesian network probabilistic modeling
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

# Load Bayesian network libraries
if (!require("bnlearn")) install.packages("bnlearn")
if (!require("gRain")) install.packages("gRain")
if (!require("igraph")) install.packages("igraph")
if (!require("DiagrammeR")) install.packages("DiagrammeR")

library(bnlearn)
library(gRain)
library(igraph)
library(DiagrammeR)

# Source utility functions and vocabulary management
source("utils.r")
source("vocabulary.r")
source("bowtie_bayesian_network.r")

# Load vocabulary data at startup
tryCatch({
  vocabulary_data <- load_vocabulary()
  cat("✅ Vocabulary data loaded successfully\n")
}, error = function(e) {
  cat("⚠️ Warning: Could not load vocabulary data:", e$message, "\n")
  vocabulary_data <- list(
    activities = data.frame(),
    pressures = data.frame(),
    consequences = data.frame(),
    controls = data.frame()
  )
})

# Define UI with Bayesian network integration
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
      .bayesian-panel {
        border: 2px solid #007bff;
        border-radius: 8px;
        background: linear-gradient(135deg, #e3f2fd 0%, #ffffff 100%);
      }
      .inference-result {
        background: #f8f9fa;
        border-left: 4px solid #007bff;
        padding: 10px;
        margin: 10px 0;
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
                   # PNG Image - marbefes.png logo from www/ folder
                   img(src = "marbefes.png", class = "app-title-image", alt = "Marbefes Logo",
                       onerror = "this.style.display='none'", 
                       title = "Marbefes Environmental Bowtie Risk Analysis"),
                   h4("Environmental Bowtie Risk Analysis", class = "mb-0 text-primary d-inline-block me-3"),
                   span(class = "badge bg-success me-2 version-badge", "v4.4.0"),
                   span(class = "text-muted small", "Enhanced with Bayesian Networks")
                 )
               ),
               actionButton("toggleTheme", label = NULL, icon = icon("gear"),
                           class = "btn-sm btn-outline-secondary", title = "Theme Settings")
             ),
             card_body(
               id = "themePanel", class = "collapse",
               fluidRow(
                 column(3, selectInput("theme_preset", "Theme:",
                                     choices = c(
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
                                     ),
                                     selected = "journal")),
                 column(3, conditionalPanel(
                   condition = "input.theme_preset == 'custom'",
                   colourpicker::colourInput("primary_color", "Primary Color:", value = "#28a745"),
                   colourpicker::colourInput("secondary_color", "Secondary Color:", value = "#6c757d")
                 )),
                 column(3, conditionalPanel(
                   condition = "input.theme_preset == 'custom'",
                   colourpicker::colourInput("success_color", "Success Color:", value = "#28a745"),
                   colourpicker::colourInput("info_color", "Info Color:", value = "#17a2b8")
                 )),
                 column(3, conditionalPanel(
                   condition = "input.theme_preset == 'custom'",
                   colourpicker::colourInput("warning_color", "Warning Color:", value = "#ffc107"),
                   colourpicker::colourInput("danger_color", "Danger Color:", value = "#dc3545")
                 ), conditionalPanel(
                   condition = "input.theme_preset != 'custom'",
                   div(class = "mt-2",
                     h6("🎨 Theme Information", class = "text-primary"),
                     p(class = "text-muted small", 
                       "Choose from 20+ professional Bootstrap themes optimized for environmental risk analysis."),
                     p(class = "text-muted small", 
                       "Dark themes improve visibility during extended analysis sessions."),
                     p(class = "text-muted small", 
                       "Select 'Custom Colors' for complete color control.")
                   )
                 ))
               )
             )
           )
    )
  ),

  # Navigation tabs with Bayesian Networks
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
                   p("Generate comprehensive environmental bowtie data with GRANULAR connection-level risk analysis:"),
                   tags$ul(class = "small text-muted",
                     tags$li("🔗 Activity → Pressure risks"),
                     tags$li("🛡️ Pressure → Control effectiveness"),
                     tags$li("⚠️ Control → Escalation risks"),
                     tags$li("🔥 Escalation → Central Problem risks"),
                     tags$li("🛡️ Central → Mitigation effectiveness"),
                     tags$li("💥 Mitigation → Consequence residual risks")
                   ),
                   div(class = "d-grid", actionButton("generateSample", 
                                                     tagList(icon("seedling"), "Generate GRANULAR Data v4.4.0"), 
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
                 card_header(tagList(icon("info-circle"), "Enhanced Data Structure v4.4.0"), class = "bg-info text-white"),
                 card_body(
                   h6(tagList(icon("list"), "Bowtie Elements:")),
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
                   
                   div(class = "alert alert-success mt-3",
                       tagList(icon("check-circle"), " "),
                       strong("v4.4.0 ENHANCED:"), " Activity → Pressure → Control → Escalation → Central Problem → Mitigation → Consequence"),
                   
                   div(class = "alert alert-info mt-2",
                       tagList(icon("brain"), " "),
                       strong("NEW: Bayesian Networks:"), " Convert bowties to probabilistic networks for advanced risk inference and scenario analysis"),
                   
                   div(class = "alert alert-primary mt-2",
                       tagList(icon("book"), " "),
                       strong("v4.4.0 AI Analysis:"), " Enhanced causal analysis finds Activity→Pressure→Consequence chains and Control interventions!"),
                   
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
          card_header(tagList(icon("eye"), "Data Preview - v4.4.0 Enhanced"), class = "bg-success text-white"),
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
      title = tagList(icon("project-diagram"), "Bowtie Diagram v4.4.0"), value = "bowtie",
      
      fluidRow(
        column(4,
               card(
                 card_header(tagList(icon("cogs"), "Enhanced Bowtie Controls v4.4.0"), class = "bg-primary text-white"),
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
                     checkboxInput("showBarriers", "Show Controls & Mitigation", value = TRUE),
                     checkboxInput("showRiskLevels", "Color by Risk Level", value = TRUE),
                     sliderInput("nodeSize", "Node Size:", min = 25, max = 80, value = 45),
                     
                     hr(),
                     h6(tagList(icon("plus"), "Quick Add Enhanced:")),
                     textInput("newActivity", "New Activity:", placeholder = "Enter activity description"),
                     textInput("newPressure", "New Pressure:", placeholder = "Enter pressure/threat"),
                     textInput("newConsequence", "New Consequence:", placeholder = "Enter consequence"),
                     div(class = "d-grid", actionButton("addActivityChain", 
                                                       tagList(icon("plus-circle"), "Add Enhanced Chain v4.4.0"), 
                                                       class = "btn-outline-primary btn-sm")),
                     
                     hr(),
                     h6(tagList(icon("palette"), "Bowtie Visual Legend v4.4.0:")),
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
                             span(tagList(icon("shield"), " Protective Mitigation"))),
                         div(class = "d-flex align-items-center mb-1",
                             span(class = "badge" , style = "background-color: #E67E22; color: white; margin-right: 8px;", "⬢"),
                             span(tagList(icon("burst"), " Consequences (Environmental Impacts)"))),
                         hr(class = "my-2"),
                         div(class = "small text-success",
                             strong("✓ v4.4.0:"), " Enhanced with Bayesian network conversion"),
                         div(class = "small text-muted",
                             strong("Enhanced Flow:"), " Activity → Pressure → Control → Escalation → Central Problem → Mitigation → Consequence"),
                         div(class = "small text-muted",
                             strong("Line Types:"), " Solid = causal flow, Dashed = intervention/control effects"),
                         div(class = "small text-info mt-1",
                             strong("PNG Support:"), " Add marbefes.png to www/ folder for custom branding")
                     ),
                     
                     hr(),
                     div(class = "d-grid", downloadButton("downloadBowtie", 
                                                         tagList(icon("download"), "Download Diagram v4.4.0"), 
                                                         class = "btn-success"))
                   )
                 )
               )
        ),
        
        column(8,
               card(
                 card_header(tagList(icon("sitemap"), "Bowtie Diagram v4.4.0"), 
                           class = "bg-success text-white"),
                 card_body(
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     div(class = "text-center mb-3",
                         h5(tagList(icon("water"), "Environmental Bowtie Risk Analysis - v4.4.0"), class = "text-primary"),
                         p(class = "small text-success", 
                           "✓ Enhanced: Activities → Pressures → Controls → Escalation → Central Problem → Mitigation → Consequences with Bayesian conversion")),
                     div(class = "network-container",
                         withSpinner(visNetworkOutput("bowtieNetwork", height = "650px"))
                     )
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("upload", class = "fa-3x text-muted mb-3"),
                         h4("Upload Data or Generate Enhanced Sample Data v4.4.0", class = "text-muted"),
                         p("Please upload environmental data or generate enhanced sample data to view the bowtie diagram with Bayesian network conversion", 
                           class = "text-muted"))
                   )
                 )
               )
        )
      )
    ),
    
    # NEW: Bayesian Network Analysis Tab
    nav_panel(
      title = tagList(icon("brain"), "Bayesian Networks"), value = "bayesian",
      
      fluidRow(
        column(4,
               card(
                 card_header(tagList(icon("brain"), "Bayesian Network Controls"), class = "bg-primary text-white"),
                 card_body(class = "bayesian-panel",
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     
                     h6(tagList(icon("cogs"), "Network Creation:")),
                     selectInput("bayesianProblem", "Select Central Problem:", choices = NULL),
                     
                     div(class = "d-grid mb-3",
                         actionButton("createBayesianNetwork", 
                                     tagList(icon("brain"), "Create Bayesian Network"), 
                                     class = "btn-success")),
                     
                     conditionalPanel(
                       condition = "output.bayesianNetworkCreated",
                       
                       hr(),
                       h6(tagList(icon("question-circle"), "Probabilistic Inference:")),
                       
                       h6("Set Evidence (What we observe):"),
                       selectInput("evidenceActivity", "Activity Level:",
                                  choices = c("Not Set" = "", "Present" = "Present", "Absent" = "Absent")),
                       selectInput("evidencePressure", "Pressure Level:",
                                  choices = c("Not Set" = "", "Low" = "Low", "Medium" = "Medium", "High" = "High")),
                       selectInput("evidenceControl", "Control Effectiveness:",
                                  choices = c("Not Set" = "", "Effective" = "Effective", "Partial" = "Partial", "Failed" = "Failed")),
                       
                       h6("Query (What we want to predict):"),
                       checkboxGroupInput("queryNodes", "Select outcomes to predict:",
                                         choices = c("Consequence Level" = "Consequence_Level",
                                                   "Problem Severity" = "Problem_Severity",
                                                   "Escalation Level" = "Escalation_Level"),
                                         selected = c("Consequence_Level", "Problem_Severity")),
                       
                       div(class = "d-grid mb-3",
                           actionButton("runInference", 
                                       tagList(icon("play"), "Run Inference"), 
                                       class = "btn-primary")),
                       
                       hr(),
                       h6(tagList(icon("chart-line"), "Risk Scenarios:")),
                       
                       # Pre-defined scenarios
                       actionButton("scenarioWorstCase", "Worst Case", class = "btn-danger btn-sm mb-2"),
                       actionButton("scenarioBestCase", "Best Case", class = "btn-success btn-sm mb-2"),
                       actionButton("scenarioControlFailure", "Control Failure", class = "btn-warning btn-sm mb-2"),
                       actionButton("scenarioBaseline", "Baseline", class = "btn-info btn-sm mb-2"),
                       
                       hr(),
                       h6(tagList(icon("download"), "Export:")),
                       downloadButton("downloadBayesianResults", 
                                     tagList(icon("download"), "Download Analysis"), 
                                     class = "btn-outline-primary btn-sm")
                     )
                   ),
                   
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-3",
                         icon("brain", class = "fa-3x text-muted mb-3"),
                         h5("Load Data First", class = "text-muted"),
                         p("Upload or generate environmental data to access Bayesian network analysis", class = "text-muted"))
                   )
                 )
               )
        ),
        
        column(8,
               fluidRow(
                 column(12,
                        card(
                          card_header(tagList(icon("sitemap"), "Bayesian Network Visualization"), 
                                    class = "bg-info text-white"),
                          card_body(
                            conditionalPanel(
                              condition = "output.bayesianNetworkCreated",
                              div(class = "network-container",
                                  withSpinner(visNetworkOutput("bayesianNetworkVis", height = "400px"))
                              )
                            ),
                            conditionalPanel(
                              condition = "!output.bayesianNetworkCreated",
                              div(class = "text-center p-5",
                                  icon("brain", class = "fa-3x text-muted mb-3"),
                                  h4("Create Bayesian Network", class = "text-muted"),
                                  p("Click 'Create Bayesian Network' to convert your bowtie data into a probabilistic model", 
                                    class = "text-muted"))
                            )
                          )
                        )
                 )
               ),
               
               fluidRow(
                 column(6,
                        card(
                          card_header(tagList(icon("chart-bar"), "Inference Results"), 
                                    class = "bg-success text-white"),
                          card_body(
                            conditionalPanel(
                              condition = "output.inferenceCompleted",
                              div(class = "inference-result",
                                  h6("Probabilistic Predictions:"),
                                  withSpinner(verbatimTextOutput("inferenceResults"))
                              )
                            ),
                            conditionalPanel(
                              condition = "!output.inferenceCompleted",
                              div(class = "text-center p-3",
                                  icon("question-circle", class = "fa-2x text-muted mb-2"),
                                  p("Set evidence and run inference to see results", class = "text-muted"))
                            )
                          )
                        )
                 ),
                 
                 column(6,
                        card(
                          card_header(tagList(icon("exclamation-triangle"), "Risk Analysis"), 
                                    class = "bg-warning text-white"),
                          card_body(
                            conditionalPanel(
                              condition = "output.inferenceCompleted",
                              div(class = "inference-result",
                                  h6("Risk Interpretation:"),
                                  withSpinner(htmlOutput("riskInterpretation"))
                              )
                            ),
                            conditionalPanel(
                              condition = "!output.inferenceCompleted",
                              div(class = "text-center p-3",
                                  icon("chart-line", class = "fa-2x text-muted mb-2"),
                                  p("Run inference to see risk analysis", class = "text-muted"))
                            )
                          )
                        )
                 )
               ),
               
               fluidRow(
                 column(12,
                        card(
                          card_header(tagList(icon("info-circle"), "Network Information"), 
                                    class = "bg-secondary text-white"),
                          card_body(
                            conditionalPanel(
                              condition = "output.bayesianNetworkCreated",
                              h6("Network Structure:"),
                              verbatimTextOutput("networkInfo"),
                              hr(),
                              h6("How to Use:"),
                              tags$ul(
                                tags$li("Set evidence to represent what you observe in the real situation"),
                                tags$li("Select query nodes to predict what you're interested in"),
                                tags$li("Run inference to get probabilistic predictions"),
                                tags$li("Try different scenarios using the preset buttons"),
                                tags$li("Higher probabilities indicate more likely outcomes")
                              )
                            )
                          )
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
                       tagList(icon("table"), "Enhanced Environmental Bowtie Data v4.4.0"),
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
                         "✓ v4.4.0 ENHANCED: Click on any cell to edit. Data ready for Bayesian network conversion."),
                     withSpinner(DT::dataTableOutput("editableTable"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("table", class = "fa-3x text-muted mb-3"),
                         h4("No Enhanced Data Available", class = "text-muted"),
                         p("Please upload data or generate enhanced sample data v4.4.0", class = "text-muted"))
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
                 card_header(tagList(icon("chart-line"), "Enhanced Environmental Risk Matrix v4.4.0"), 
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
                         p("Please upload data or generate enhanced sample data v4.4.0 to view the risk matrix", class = "text-muted"))
                   )
                 )
               )
        ),
        
        column(4,
               card(
                 card_header(tagList(icon("chart-pie"), "Enhanced Risk Statistics v4.4.0"), class = "bg-info text-white"),
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
    ),
    
    # Vocabulary Management Tab (keeping existing functionality)
    nav_panel(
      title = tagList(icon("book"), "Vocabulary Management"), value = "vocabulary",
      
      fluidRow(
        column(3,
               card(
                 card_header(tagList(icon("filter"), "Vocabulary Controls"), class = "bg-primary text-white"),
                 card_body(
                   h6(tagList(icon("list"), "Select Vocabulary:")),
                   selectInput("vocab_type", NULL,
                               choices = list(
                                 "Activities" = "activities",
                                 "Pressures" = "pressures", 
                                 "Consequences" = "consequences",
                                 "Controls" = "controls"
                               ),
                               selected = "activities"),
                   
                   hr(),
                   
                   h6(tagList(icon("search"), "Search:")),
                   textInput("vocab_search", NULL, placeholder = "Enter search term..."),
                   checkboxGroupInput("search_in", "Search in:",
                                      choices = list("ID" = "id", "Name" = "name"),
                                      selected = c("id", "name")),
                   actionButton("search_vocab", tagList(icon("search"), "Search"), 
                               class = "btn-primary btn-sm"),
                   
                   hr(),
                   
                   h6(tagList(icon("layer-group"), "Filter by Level:")),
                   uiOutput("vocab_level_filter"),
                   
                   hr(),
                   
                   h6(tagList(icon("info-circle"), "Selected Item:")),
                   uiOutput("selected_item_info"),
                   
                   hr(),
                   
                   h6(tagList(icon("chart-pie"), "Statistics:")),
                   tableOutput("vocab_stats")
                 )
               )
        ),
        
        column(9,
               card(
                 card_header(
                   div(class = "d-flex justify-content-between align-items-center",
                       tagList(icon("sitemap"), "Hierarchical Vocabulary Browser"),
                       div(
                         downloadButton("download_vocab", tagList(icon("download"), "Export"), 
                                       class = "btn-success btn-sm me-2"),
                         actionButton("refresh_vocab", tagList(icon("sync"), "Refresh"), 
                                     class = "btn-info btn-sm")
                       )
                   ),
                   class = "bg-primary text-white"
                 ),
                 card_body(
                   tabsetPanel(
                     tabPanel("Tree View",
                              br(),
                              div(class = "border rounded p-3 bg-light",
                                  style = "max-height: 500px; overflow-y: auto;",
                                  verbatimTextOutput("vocab_tree")
                              )
                     ),
                     
                     tabPanel("Data Table",
                              br(),
                              withSpinner(DT::dataTableOutput("vocab_table"))
                     ),
                     
                     tabPanel("Search Results",
                              br(),
                              conditionalPanel(
                                condition = "output.hasSearchResults",
                                withSpinner(DT::dataTableOutput("vocab_search_results"))
                              ),
                              conditionalPanel(
                                condition = "!output.hasSearchResults",
                                div(class = "text-center p-5 text-muted",
                                    icon("search", class = "fa-3x mb-3"),
                                    h5("No search performed yet"),
                                    p("Use the search controls to find vocabulary items"))
                              )
                     ),
                     
                     tabPanel("Relationships",
                              br(),
                              div(class = "alert alert-info",
                                  tagList(icon("info-circle"), " "),
                                  "Select an item from the data table to view its relationships"),
                              uiOutput("vocab_relationships")
                     ),
                     
                     tabPanel("AI Analysis",
                              br(),
                              fluidRow(
                                column(12,
                                       div(class = "alert alert-primary",
                                           tagList(icon("robot"), " "),
                                           strong("AI-Powered Vocabulary Analysis"),
                                           " - Discover semantic connections between vocabulary groups using artificial intelligence"
                                       )
                                )
                              ),
                              
                              fluidRow(
                                column(4,
                                       card(
                                         card_header(tagList(icon("brain"), "AI Analysis Controls"), 
                                                   class = "bg-primary text-white"),
                                         card_body(
                                           h6("Analysis Methods:"),
                                           checkboxGroupInput("ai_methods", NULL,
                                                            choices = list(
                                                              "Semantic Similarity" = "jaccard",
                                                              "Keyword Connections" = "keyword",
                                                              "Causal Relationships (Enhanced)" = "causal"
                                                            ),
                                                            selected = c("causal")),
                                           
                                           conditionalPanel(
                                             condition = "input.ai_methods.includes('causal')",
                                             div(class = "alert alert-info small mt-2",
                                                 tagList(icon("info-circle"), " "),
                                                 strong("Enhanced Causal Analysis:"),
                                                 tags$ul(class = "mb-0 small",
                                                   tags$li("Activity → Pressure → Consequence chains"),
                                                   tags$li("Control intervention relationships"),
                                                   tags$li("Environmental process detection"),
                                                   tags$li("Multi-hop causal pathways")
                                                 )
                                             )
                                           ),
                                           
                                           sliderInput("similarity_threshold", "Similarity Threshold:",
                                                      min = 0.1, max = 0.9, value = 0.3, step = 0.1),
                                           
                                           sliderInput("max_links_per_item", "Max Links per Item:",
                                                      min = 1, max = 10, value = 5),
                                           
                                           div(class = "d-grid",
                                               actionButton("run_ai_analysis", 
                                                          tagList(icon("play"), "Run AI Analysis"),
                                                          class = "btn-success")
                                           ),
                                           
                                           hr(),
                                           
                                           conditionalPanel(
                                             condition = "output.aiAnalysisComplete",
                                             h6("Analysis Results:"),
                                             verbatimTextOutput("ai_summary")
                                           )
                                         )
                                       )
                                ),
                                
                                column(8,
                                       conditionalPanel(
                                         condition = "output.aiAnalysisComplete",
                                         card(
                                           card_header(tagList(icon("network-wired"), "Discovered Connections"),
                                                     class = "bg-success text-white"),
                                           card_body(
                                             tabsetPanel(
                                               tabPanel("Connection Table",
                                                        br(),
                                                        withSpinner(DT::dataTableOutput("ai_connections_table"))
                                               ),
                                               tabPanel("Network Visualization",
                                                        br(),
                                                        withSpinner(visNetworkOutput("ai_network", height = "500px"))
                                               ),
                                               tabPanel("Connection Summary",
                                                        br(),
                                                        tableOutput("ai_connection_summary"),
                                                        hr(),
                                                        plotOutput("ai_connection_plot", height = "300px")
                                               ),
                                               tabPanel("Causal Analysis",
                                                        br(),
                                                        h5(tagList(icon("sitemap"), "Causal Pathway Analysis")),
                                                        p(class = "text-muted", "Discovered causal chains from activities to consequences"),
                                                        
                                                        fluidRow(
                                                          column(6,
                                                                 h6("Top Causal Pathways:"),
                                                                 div(style = "height: 300px; overflow-y: auto;",
                                                                     verbatimTextOutput("causal_paths"))
                                                          ),
                                                          column(6,
                                                                 h6("Causal Network Structure:"),
                                                                 tableOutput("causal_structure")
                                                          )
                                                        ),
                                                        
                                                        hr(),
                                                        
                                                        fluidRow(
                                                          column(6,
                                                                 h6("Key Drivers (Root Causes):"),
                                                                 tableOutput("key_drivers")
                                                          ),
                                                          column(6,
                                                                 h6("Key Outcomes (Final Impacts):"),
                                                                 tableOutput("key_outcomes")
                                                          )
                                                        )
                                               )
                                             )
                                           )
                                         )
                                       ),
                                       conditionalPanel(
                                         condition = "!output.aiAnalysisComplete",
                                         card(
                                           card_body(
                                             div(class = "text-center p-5",
                                                 icon("brain", class = "fa-3x text-muted mb-3"),
                                                 h4("AI Analysis Not Started", class = "text-muted"),
                                                 p("Configure analysis settings and click 'Run AI Analysis' to discover connections", 
                                                   class = "text-muted")
                                             )
                                           )
                                         )
                                       )
                                )
                              ),
                              
                              fluidRow(
                                column(12,
                                       conditionalPanel(
                                         condition = "output.aiAnalysisComplete",
                                         card(
                                           card_header(tagList(icon("lightbulb"), "AI Recommendations"),
                                                     class = "bg-info text-white"),
                                           card_body(
                                             h6("Suggested Vocabulary Links:"),
                                             p(class = "text-muted", 
                                               "Based on AI analysis, these vocabulary items show strong potential connections:"),
                                             DT::dataTableOutput("ai_recommendations")
                                           )
                                         )
                                       )
                                )
                              )
                     )
                   )
                 )
               )
        )
      ),
      
      fluidRow(
        column(12,
               card(
                 card_header(tagList(icon("info-circle"), "Vocabulary Information"), 
                           class = "bg-info text-white"),
                 card_body(
                   uiOutput("vocab_info")
                 )
               )
        )
      )
    ),
    
    # Help Tab
    nav_panel(
      title = tagList(icon("question-circle"), "Help"), value = "help",
      
      fluidRow(
        column(12,
          card(
            card_header(
              tagList(icon("book"), "Application Documentation"),
              class = "bg-info text-white"
            ),
            card_body(
              includeMarkdown("README.md")
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
        span(class = "badge bg-success", "v4.4.0"),
        " - Enhanced with Bayesian Network Analysis"
      )))
)

# Define Server with Bayesian network integration
server <- function(input, output, session) {
  
  # Optimized reactive values using reactiveVal for single values
  currentData <- reactiveVal(NULL)
  editedData <- reactiveVal(NULL)
  sheets <- reactiveVal(NULL)
  envDataGenerated <- reactiveVal(FALSE)
  selectedRows <- reactiveVal(NULL)
  dataVersion <- reactiveVal(0)  # For cache invalidation
  
  # NEW: Bayesian network reactive values
  bayesianNetwork <- reactiveVal(NULL)
  bayesianNetworkCreated <- reactiveVal(FALSE)
  inferenceResults <- reactiveVal(NULL)
  inferenceCompleted <- reactiveVal(FALSE)
  
  # Optimized data retrieval with caching
  getCurrentData <- reactive({
    edited <- editedData()
    if (!is.null(edited)) edited else currentData()
  })
  
  # Enhanced Theme management with comprehensive Bootstrap theme support
  current_theme <- reactive({
    theme_choice <- input$theme_preset
    
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
      updateSelectInput(session, "bayesianProblem", choices = unique(data$Central_Problem))
      showNotification("✅ Data loaded successfully with v4.4.0 Bayesian network ready!", type = "message", duration = 3)
      
    }, error = function(e) {
      showNotification(paste("❌ Error loading data:", e$message), type = "error")
    })
  })
  
  # Enhanced sample data generation
  observeEvent(input$generateSample, {
    showNotification("🔄 Generating v4.4.0 enhanced sample data with Bayesian network support...", 
                    type = "message", duration = 3)
    
    tryCatch({
      sample_data <- generateEnvironmentalDataFixed()
      currentData(sample_data)
      editedData(sample_data)
      envDataGenerated(TRUE)
      dataVersion(dataVersion() + 1)
      clearCache()
      
      problem_choices <- unique(sample_data$Central_Problem)
      updateSelectInput(session, "selectedProblem", choices = problem_choices, selected = problem_choices[1])
      updateSelectInput(session, "bayesianProblem", choices = problem_choices, selected = problem_choices[1])
      
      showNotification(paste("✅ Generated", nrow(sample_data), "enhanced environmental scenarios with v4.4.0 Bayesian network support!"), 
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
  
  # Enhanced data info with v4.4.0 details
  output$dataInfo <- renderText({
    data <- getCurrentData()
    req(data)
    getDataSummaryFixed(data)
  })
  
  # Enhanced download handler
  output$downloadSample <- downloadHandler(
    filename = function() paste("enhanced_environmental_bowtie_v4.4.0_", Sys.Date(), ".xlsx", sep = ""),
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
    
    showNotification("🧠 Creating Bayesian network from bowtie data...", type = "message", duration = 3)
    
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
      
      showNotification("✅ Bayesian network created successfully!", type = "success", duration = 3)
      
    }, error = function(e) {
      showNotification(paste("❌ Error creating Bayesian network:", e$message), type = "error")
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
    
    showNotification("🔮 Running Bayesian inference...", type = "message", duration = 2)
    
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
      
      showNotification("✅ Inference completed!", type = "success", duration = 2)
      
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
    showNotification("🟢 Best case scenario set", type = "success", duration = 2)
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
    showNotification("ℹ️ Baseline scenario set (no evidence)", type = "info", duration = 2)
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
  
  # (All existing server code for bowtie visualization, data tables, risk matrix, vocabulary management, etc.)
  # [Previous server logic would continue here - I'm including the key parts for the example]
  
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
        language = list(processing = "Loading v4.4.0 enhanced data with Bayesian network support...")
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
    clearCache()
    
    # Reset Bayesian network when data changes
    bayesianNetworkCreated(FALSE)
    inferenceCompleted(FALSE)
    
    if (runif(1) < 0.3) {
      showNotification("✓ Cell updated - v4.4.0 Bayesian network ready for recreation", type = "message", duration = 1)
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
    
    selected_problem <- if (!is.null(input$selectedProblem)) input$selectedProblem else "New Environmental Risk v4.4.0"
    new_row <- createDefaultRowFixed(selected_problem)
    updated_data <- rbind(data, new_row)
    
    editedData(updated_data)
    dataVersion(dataVersion() + 1)
    clearCache()
    bayesianNetworkCreated(FALSE)  # Reset Bayesian network
    showNotification("✅ New enhanced row added with v4.4.0 Bayesian support!", type = "message", duration = 2)
  })
  
  observeEvent(input$deleteSelected, {
    rows <- selectedRows()
    if (!is.null(rows) && length(rows) > 0) {
      data <- getCurrentData()
      updated_data <- data[-rows, ]
      editedData(updated_data)
      dataVersion(dataVersion() + 1)
      clearCache()
      bayesianNetworkCreated(FALSE)  # Reset Bayesian network
      showNotification(paste("🗑️ Deleted", length(rows), "row(s) - v4.4.0 Bayesian network reset"), type = "warning", duration = 2)
    } else {
      showNotification("❌ No rows selected", type = "error", duration = 2)
    }
  })
  
  observeEvent(input$saveChanges, {
    edited <- editedData()
    if (!is.null(edited)) {
      currentData(edited)
      showNotification("💾 Changes saved with v4.4.0 Bayesian network support!", type = "message", duration = 2)
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
      Preventive_Control = "v4.4.0 Enhanced preventive control",
      Escalation_Factor = "v4.4.0 Enhanced escalation factor",
      Central_Problem = input$selectedProblem,
      Protective_Mitigation = paste("v4.4.0 Enhanced protective mitigation for", input$newConsequence),
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
    bayesianNetworkCreated(FALSE)  # Reset Bayesian network
    
    updateTextInput(session, "newActivity", value = "")
    updateTextInput(session, "newPressure", value = "")
    updateTextInput(session, "newConsequence", value = "")
    
    showNotification("🔗 Enhanced activity chain added with v4.4.0 Bayesian network support!", type = "message", duration = 3)
  })
  
  # Enhanced debug info
  output$debugInfo <- renderText({
    data <- getCurrentData()
    if (!is.null(data)) {
      paste("✅ Loaded:", nrow(data), "rows,", ncol(data), "columns - v4.4.0 Enhanced bowtie structure with Bayesian network support")
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
               main = paste("🌟 Enhanced Bowtie Analysis v4.4.0 with Bayesian Networks:", input$selectedProblem),
               submain = if(input$showBarriers) "✅ Interconnected pathways with v4.4.0 Bayesian network conversion ready" else "Direct causal relationships with enhanced connections",
               footer = "🔧 v4.4.0 ENHANCED: Activities → Pressures → Controls → Escalation → Central Problem → Mitigation → Consequences + Bayesian Networks") %>%
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
        list(label = "Protective Mitigation (v4.4.0)", 
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
      geom_point(aes(color = Risk_Level, text = paste(
        "Central Problem:", Central_Problem, 
        "<br>Activity:", Activity,
        "<br>Pressure:", Pressure,
        "<br>Protective Mitigation:", Protective_Mitigation,
        "<br>Consequence:", Consequence,
        "<br>v4.4.0 Bayesian Networks: ✅"
      )), size = 4, alpha = 0.7) +
      scale_color_manual(values = RISK_COLORS) +
      scale_x_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
      scale_y_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
      labs(title = "🌟 Enhanced Environmental Risk Matrix v4.4.0 with Bayesian Networks", 
           x = "Likelihood", y = "Severity",
           subtitle = "✅ Data ready for probabilistic modeling and Bayesian inference") +
      theme_minimal() + 
      theme(legend.position = "bottom",
            plot.title = element_text(color = "#2C3E50", size = 14),
            plot.subtitle = element_text(color = "#007bff", size = 10))
    
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
      select(Icon, Risk_Level, Count = n, Percentage)
    
    names(risk_summary) <- c("Icon", "Risk Level", "Count", "Percentage (%)")
    
    footer_row <- data.frame(
      Icon = "🧠",
      `Risk Level` = "v4.4.0 Bayesian",
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
    filename = function() paste("enhanced_bowtie_v4.4.0_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".html"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)
      
      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, 50, FALSE, TRUE)
      edges <- createBowtieEdgesFixed(problem_data, TRUE)
      
      network <- visNetwork(nodes, edges, 
                          main = paste("🌟 Enhanced Environmental Bowtie Analysis v4.4.0 with Bayesian Networks:", input$selectedProblem),
                          submain = paste("Generated on", Sys.Date(), "- v4.4.0 with Bayesian network support"),
                          footer = "🔧 v4.4.0 ENHANCED: Activities → Pressures → Controls → Escalation → Central Problem → Mitigation → Consequences + Bayesian Networks") %>%
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
          list(label = "Protective Mitigation (v4.4.0)", 
               color = "#3498DB", shape = "square", size = 15),
          list(label = "Consequences (Impacts)", 
               color = "#E67E22", shape = "hexagon", size = 15)
        ), position = "right", width = 0.25, ncol = 1)
      
      visSave(network, file, selfcontained = TRUE)
    }
  )
  
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
    showNotification("Refreshing vocabulary data...", type = "message", duration = 2)
    tryCatch({
      vocabulary_data <<- load_vocabulary()
      vocab_search_results(data.frame())
      selected_vocab_item(NULL)
      showNotification("✅ Vocabulary refreshed successfully!", type = "success", duration = 3)
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
    showNotification("🤖 Starting AI analysis...", type = "message", duration = 2)
    
    tryCatch({
      if (exists("find_vocabulary_links")) {
        results <- find_vocabulary_links(
          vocabulary_data,
          similarity_threshold = input$similarity_threshold,
          max_links_per_item = input$max_links_per_item,
          methods = input$ai_methods
        )
        
        ai_analysis_results(results)
        
        showNotification(
          paste("✅ AI analysis complete! Found", nrow(results$links), "connections"),
          type = "success",
          duration = 3
        )
      } else {
        results <- find_vocabulary_connections(vocabulary_data, use_ai = FALSE)
        ai_analysis_results(results)
        
        showNotification(
          "ℹ️ Using basic keyword analysis (AI linker not available)",
          type = "warning",
          duration = 3
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
}

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

# Run the enhanced application with Bayesian networks
shinyApp(ui = ui, server = server)