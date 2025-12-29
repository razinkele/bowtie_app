# =============================================================================
# UI Content Sections for bs4Dash Conversion
# This file contains functions that return the content for each tab
# Extracted and adapted from the original UI
# =============================================================================

# =============================================================================
# DATA UPLOAD TAB CONTENT
# =============================================================================
get_upload_tab_content <- function() {
  tagList(
    fluidRow(
      column(12,
        box(
          title = uiOutput("data_input_options_header", inline = TRUE),
          status = "primary",
          solidHeader = TRUE,
          width = 12,

          fluidRow(
            # Left column - File upload
            column(6,
              h6(uiOutput("data_upload_option1_title", inline = TRUE)),
              uiOutput("file_input_ui"),
              conditionalPanel(
                condition = "output.fileUploaded",
                selectInput("sheet", "Select Sheet:", choices = NULL),
                actionButton("loadData",
                            tagList(icon("upload"), "Load Data"),
                            class = "btn-primary btn-block")
              )
            ),

            # Right column - Generate from vocabulary
            column(6,
              div(style = "min-height: 150px;",
                uiOutput("data_upload_option2_title"),
                uiOutput("data_option2_desc")
              ),
              div(class = "mb-3",
                selectInput("data_scenario_template",
                           "Select environmental scenario:",
                           choices = getEnvironmentalScenarioChoices(include_blank = TRUE),
                           selected = "")
              ),
              actionButton("generateMultipleControls",
                          tagList(icon("seedling"), "Generate Data"),
                          class = "btn-success btn-block"),
              conditionalPanel(
                condition = "output.envDataGenerated",
                downloadButton("downloadSample",
                              tagList(icon("download"), "Download"),
                              class = "btn-success btn-block mt-2")
              )
            )
          )
        )
      )
    ),

    fluidRow(
      column(4,
        box(
          title = uiOutput("data_structure_header"),
          status = "info",
          solidHeader = TRUE,
          width = 12,

          uiOutput("bowtie_elements_section"),
          tags$div(class = "alert alert-success mt-2 mb-0 py-2",
            tags$small(
              tagList(icon("check-circle"), " "),
              strong("Structure:"),
              br(),
              "Activity → Pressure → ",
              tags$span(class = "badge badge-success", "Control"),
              " → Central Problem",
              br(),
              tags$span(class = "badge badge-warning", "Escalation"),
              " weakens Controls & Mitigations",
              br(),
              "Central Problem → ",
              tags$span(class = "badge badge-info", "Mitigation"),
              " → Consequence"
            ))
        )
      ),

      column(4,
        box(
          title = tagList(icon("database"), "Vocabulary Statistics"),
          status = "success",
          solidHeader = TRUE,
          width = 12,

          h6(tagList(icon("layer-group"), "Available Elements"), class = "text-center mb-3"),
          div(class = "row text-center",
            div(class = "col-6 mb-3",
              div(class = "p-2 border rounded",
                div(class = "h2 text-primary", textOutput("vocab_activities_count", inline = TRUE)),
                div(class = "small text-muted", tagList(icon("play"), " Activities"))
              )
            ),
            div(class = "col-6 mb-3",
              div(class = "p-2 border rounded",
                div(class = "h2 text-danger", textOutput("vocab_pressures_count", inline = TRUE)),
                div(class = "small text-muted", tagList(icon("triangle-exclamation"), " Pressures"))
              )
            ),
            div(class = "col-6 mb-3",
              div(class = "p-2 border rounded",
                div(class = "h2 text-success", textOutput("vocab_controls_count", inline = TRUE)),
                div(class = "small text-muted", tagList(icon("shield-halved"), " Controls"))
              )
            ),
            div(class = "col-6 mb-3",
              div(class = "p-2 border rounded",
                div(class = "h2 text-warning", textOutput("vocab_consequences_count", inline = TRUE)),
                div(class = "small text-muted", tagList(icon("burst"), " Consequences"))
              )
            )
          ),
          tags$div(class = "alert alert-info mt-2 mb-0 py-2",
            tags$small(
              tagList(icon("info-circle"), " "),
              strong("Total Elements: "),
              textOutput("vocab_total_count", inline = TRUE)
            )
          )
        )
      ),

      column(4,
        conditionalPanel(
          condition = "output.dataLoaded",
          box(
            title = tagList(icon("chart-bar"), "Data Summary"),
            status = "secondary",
            solidHeader = TRUE,
            width = 12,
            verbatimTextOutput("dataInfo")
          )
        )
      )
    ),

    # Empty state when no data is loaded
    conditionalPanel(
      condition = "!output.dataLoaded",
      br(),
      empty_state_table(
        message = "No data loaded yet. Upload an Excel file or generate sample data to get started.",
        action_buttons = div(class = "d-flex gap-2 justify-content-center mt-3",
          actionButton("empty_upload", "Upload Data",
                      icon = icon("upload"),
                      class = "btn-primary"),
          actionButton("empty_generate", "Generate Sample",
                      icon = icon("seedling"),
                      class = "btn-secondary")
        )
      )
    ),

    # Data preview when data is loaded
    conditionalPanel(
      condition = "output.dataLoaded",
      br(),
      box(
        title = tagList(icon("eye"), "Data Preview"),
        status = "success",
        solidHeader = TRUE,
        width = 12,

        withSpinner(DT::dataTableOutput("preview")),
        br(),
        tags$div(class = "alert alert-info mb-0",
          tagList(icon("info-circle"), " "),
          textOutput("debugInfo", inline = TRUE))
      )
    )
  )
}

# =============================================================================
# GUIDED CREATION TAB CONTENT
# =============================================================================
get_guided_tab_content <- function() {
  # Call guided_workflow_ui directly with required id parameter
  guided_workflow_ui(id = "guided_workflow")
}

# =============================================================================
# BOWTIE DIAGRAM TAB CONTENT
# =============================================================================
get_bowtie_tab_content <- function() {
  tagList(
    h2(tagList(icon("project-diagram"), "Bowtie Diagram"), class = "mb-4"),

    box(
      title = tagList(icon("sliders-h"), "Visualization Options"),
      status = "primary",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12,

      fluidRow(
        column(3,
          selectInput("layout_algorithm", "Layout Algorithm:",
                     choices = c("Hierarchical (Default)" = "hierarchical",
                               "Physics-based" = "physics",
                               "Circular" = "circular",
                               "Grid" = "grid"),
                     selected = "hierarchical")
        ),
        column(3,
          sliderInput("node_spacing", "Node Spacing:",
                     min = 50, max = 300, value = 150, step = 10)
        ),
        column(3,
          sliderInput("level_separation", "Level Separation:",
                     min = 100, max = 500, value = 200, step = 50)
        ),
        column(3,
          selectInput("color_scheme", "Color Scheme:",
                     choices = c("Environmental (Default)" = "default",
                               "High Contrast" = "contrast",
                               "Colorblind Safe" = "colorblind",
                               "Monochrome" = "mono"),
                     selected = "default")
        )
      )
    ),

    box(
      title = tagList(icon("network-wired"), "Interactive Bowtie Diagram"),
      status = "success",
      solidHeader = TRUE,
      width = 12,

      div(class = "network-container",
        withSpinner(visNetworkOutput("bowtieNetwork", height = "700px"))
      ),

      hr(),

      div(class = "enhanced-legend p-3",
        h5(tagList(icon("info-circle"), "Legend"), class = "mb-3"),
        fluidRow(
          column(2,
            div(class = "mb-2",
              tags$span(class = "badge bg-primary", "● Activity"),
              br(), tags$small(class = "text-muted", "Human actions"))
          ),
          column(2,
            div(class = "mb-2",
              tags$span(class = "badge bg-danger", "● Pressure"),
              br(), tags$small(class = "text-muted", "Environmental stress"))
          ),
          column(2,
            div(class = "mb-2",
              tags$span(class = "badge bg-success", "● Control"),
              br(), tags$small(class = "text-muted", "Preventive measures"))
          ),
          column(2,
            div(class = "mb-2",
              tags$span(class = "badge bg-dark", "● Problem"),
              br(), tags$small(class = "text-muted", "Central issue"))
          ),
          column(2,
            div(class = "mb-2",
              tags$span(class = "badge bg-info", "● Mitigation"),
              br(), tags$small(class = "text-muted", "Protective controls"))
          ),
          column(2,
            div(class = "mb-2",
              tags$span(class = "badge bg-warning", "● Consequence"),
              br(), tags$small(class = "text-muted", "Environmental impacts"))
          )
        ),
        fluidRow(
          column(6,
            div(class = "mt-3",
              tags$span(class = "badge bg-secondary", "● Escalation Factor"),
              br(), tags$small(class = "text-muted", "Factors that can reduce control effectiveness"))
          ),
          column(6,
            div(class = "mt-3 text-end",
              tags$small(class = "text-muted",
                tagList(icon("hand-pointer"), " Click nodes for details • ",
                       icon("expand"), " Drag to pan • ",
                       icon("search"), " Scroll to zoom"))
            )
          )
        )
      )
    )
  )
}

# =============================================================================
# BAYESIAN NETWORKS TAB CONTENT
# =============================================================================
get_bayesian_tab_content <- function() {
  tagList(
    h2(tagList(icon("brain"), "Bayesian Network Analysis"), class = "mb-4"),

    box(
      title = tagList(icon("cogs"), "Network Configuration"),
      status = "primary",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12,

      fluidRow(
        column(4,
          selectInput("bn_structure", "Network Structure:",
                     choices = c("Auto from Bowtie" = "auto",
                               "Custom Structure" = "custom"),
                     selected = "auto")
        ),
        column(4,
          selectInput("bn_learning_algorithm", "Learning Algorithm:",
                     choices = c("Constraint-based (PC)" = "pc",
                               "Score-based (Hill-Climbing)" = "hc",
                               "Hybrid (MMHC)" = "mmhc"),
                     selected = "hc")
        ),
        column(4,
          actionButton("learnBN", tagList(icon("brain"), "Learn Network"),
                      class = "btn-primary btn-block")
        )
      )
    ),

    box(
      title = tagList(icon("project-diagram"), "Bayesian Network Structure"),
      status = "success",
      solidHeader = TRUE,
      width = 12,

      div(class = "bayesian-panel",
        withSpinner(visNetworkOutput("bnNetwork", height = "600px"))
      )
    ),

    fluidRow(
      column(6,
        box(
          title = tagList(icon("calculator"), "Probability Inference"),
          status = "info",
          solidHeader = TRUE,
          width = 12,

          uiOutput("bayesian_evidence_ui"),

          actionButton("runInference",
                      tagList(icon("play"), "Run Inference"),
                      class = "btn-info btn-block mt-3")
        )
      ),

      column(6,
        box(
          title = tagList(icon("chart-bar"), "Inference Results"),
          status = "warning",
          solidHeader = TRUE,
          width = 12,

          withSpinner(uiOutput("inferenceResults"))
        )
      )
    ),

    box(
      title = tagList(icon("table"), "Conditional Probability Tables (CPTs)"),
      status = "secondary",
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed = TRUE,
      width = 12,

      withSpinner(uiOutput("cptTables"))
    )
  )
}

# =============================================================================
# DATA TABLE TAB CONTENT
# =============================================================================
get_table_tab_content <- function() {
  tagList(
    h2(tagList(icon("table"), "Data Table View"), class = "mb-4"),

    box(
      title = tagList(icon("database"), "Interactive Data Table"),
      status = "primary",
      solidHeader = TRUE,
      width = 12,

      withSpinner(DT::dataTableOutput("data_table")),

      hr(),

      fluidRow(
        column(4,
          downloadButton("downloadData",
                        tagList(icon("download"), "Download CSV"),
                        class = "btn-success btn-block")
        ),
        column(4,
          downloadButton("downloadExcel",
                        tagList(icon("file-excel"), "Download Excel"),
                        class = "btn-info btn-block")
        ),
        column(4,
          actionButton("refreshTable",
                      tagList(icon("refresh"), "Refresh Table"),
                      class = "btn-secondary btn-block")
        )
      )
    )
  )
}

# =============================================================================
# RISK MATRIX TAB CONTENT
# =============================================================================
get_matrix_tab_content <- function() {
  tagList(
    h2(tagList(icon("th"), "Risk Matrix"), class = "mb-4"),

    box(
      title = tagList(icon("sliders-h"), "Matrix Configuration"),
      status = "primary",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12,

      fluidRow(
        column(4,
          selectInput("matrix_type", "Matrix Type:",
                     choices = c("5x5 Standard" = "5x5",
                               "3x3 Simple" = "3x3",
                               "7x7 Detailed" = "7x7"),
                     selected = "5x5")
        ),
        column(4,
          selectInput("risk_calc_method", "Risk Calculation:",
                     choices = c("Likelihood × Impact" = "multiply",
                               "Maximum Value" = "max",
                               "Weighted Average" = "weighted"),
                     selected = "multiply")
        ),
        column(4,
          actionButton("updateMatrix",
                      tagList(icon("refresh"), "Update Matrix"),
                      class = "btn-primary btn-block")
        )
      )
    ),

    box(
      title = tagList(icon("th-large"), "Risk Heat Map"),
      status = "danger",
      solidHeader = TRUE,
      width = 12,

      withSpinner(plotlyOutput("riskMatrix", height = "600px")),

      hr(),

      div(class = "alert alert-info",
        tagList(icon("info-circle"), " "),
        strong("Risk Levels:"),
        tags$ul(
          tags$li(tags$span(class = "badge bg-success", "Low"), " - Acceptable risk"),
          tags$li(tags$span(class = "badge bg-warning", "Medium"), " - Monitor and control"),
          tags$li(tags$span(class = "badge bg-danger", "High"), " - Immediate action required")
        )
      )
    )
  )
}

# =============================================================================
# LINK RISK TAB CONTENT
# =============================================================================
get_link_risk_tab_content <- function() {
  tagList(
    h2(uiOutput("tab_link_risk_title", inline = TRUE), class = "mb-4"),

    box(
      title = tagList(icon("link"), "Risk Linkage Analysis"),
      status = "primary",
      solidHeader = TRUE,
      width = 12,

      p("This section analyzes the connections and dependencies between risk elements."),

      withSpinner(uiOutput("linkRiskContent"))
    )
  )
}

# =============================================================================
# VOCABULARY TAB CONTENT
# =============================================================================
get_vocabulary_tab_content <- function() {
  tagList(
    h2(tagList(icon("book"), "Vocabulary Management"), class = "mb-4"),

    box(
      title = tagList(icon("database"), "Vocabulary Statistics"),
      status = "info",
      solidHeader = TRUE,
      width = 12,

      fluidRow(
        column(3,
          valueBox(
            value = textOutput("vocab_activities_count_box", inline = TRUE),
            subtitle = "Activities",
            icon = icon("play"),
            color = "primary"
          )
        ),
        column(3,
          valueBox(
            value = textOutput("vocab_pressures_count_box", inline = TRUE),
            subtitle = "Pressures",
            icon = icon("triangle-exclamation"),
            color = "danger"
          )
        ),
        column(3,
          valueBox(
            value = textOutput("vocab_controls_count_box", inline = TRUE),
            subtitle = "Controls",
            icon = icon("shield-halved"),
            color = "success"
          )
        ),
        column(3,
          valueBox(
            value = textOutput("vocab_consequences_count_box", inline = TRUE),
            subtitle = "Consequences",
            icon = icon("burst"),
            color = "warning"
          )
        )
      )
    ),

    box(
      title = tagList(icon("search"), "Search Vocabulary"),
      status = "primary",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12,

      fluidRow(
        column(8,
          textInput("vocab_search", "Search term:",
                   placeholder = "Enter keywords...")
        ),
        column(4,
          selectInput("vocab_category", "Category:",
                     choices = c("All" = "all",
                               "Activities" = "activities",
                               "Pressures" = "pressures",
                               "Controls" = "controls",
                               "Consequences" = "consequences"),
                     selected = "all")
        )
      ),

      withSpinner(DT::dataTableOutput("vocabularyTable"))
    )
  )
}

# =============================================================================
# REPORT TAB CONTENT
# =============================================================================
get_report_tab_content <- function() {
  tagList(
    h2(tagList(icon("file-alt"), "Report Generation"), class = "mb-4"),

    box(
      title = tagList(icon("cog"), "Report Options"),
      status = "primary",
      solidHeader = TRUE,
      width = 12,

      fluidRow(
        column(6,
          textInput("report_title", "Report Title:",
                   value = "Environmental Risk Analysis Report"),
          textInput("report_author", "Author:",
                   placeholder = "Your name"),
          dateInput("report_date", "Report Date:",
                   value = Sys.Date())
        ),
        column(6,
          checkboxGroupInput("report_sections", "Include Sections:",
                            choices = c("Executive Summary" = "summary",
                                      "Bowtie Diagram" = "bowtie",
                                      "Risk Matrix" = "matrix",
                                      "Bayesian Analysis" = "bayesian",
                                      "Vocabulary Details" = "vocabulary",
                                      "Data Tables" = "tables"),
                            selected = c("summary", "bowtie", "matrix"))
        )
      )
    ),

    box(
      title = tagList(icon("download"), "Generate Report"),
      status = "success",
      solidHeader = TRUE,
      width = 12,

      fluidRow(
        column(4,
          downloadButton("downloadPDF",
                        tagList(icon("file-pdf"), "Download PDF"),
                        class = "btn-danger btn-block btn-lg")
        ),
        column(4,
          downloadButton("downloadWord",
                        tagList(icon("file-word"), "Download Word"),
                        class = "btn-primary btn-block btn-lg")
        ),
        column(4,
          downloadButton("downloadHTML",
                        tagList(icon("file-code"), "Download HTML"),
                        class = "btn-info btn-block btn-lg")
        )
      ),

      hr(),

      div(class = "alert alert-info",
        tagList(icon("info-circle"), " "),
        "Reports include all visualizations, data tables, and analysis results."
      )
    ),

    box(
      title = tagList(icon("eye"), "Report Preview"),
      status = "secondary",
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed = TRUE,
      width = 12,

      withSpinner(uiOutput("reportPreview"))
    )
  )
}

# =============================================================================
# HELP TAB CONTENTS
# =============================================================================
get_workflow_help_content <- function() {
  tagList(
    h2(tagList(icon("magic"), "Guided Workflow Help"), class = "mb-4"),
    box(
      title = "Using the Guided Workflow",
      status = "info",
      solidHeader = TRUE,
      width = 12,
      p("The guided workflow helps you create comprehensive bowtie diagrams step-by-step."),
      uiOutput("workflow_help_detailed")
    )
  )
}

get_risk_matrix_help_content <- function() {
  tagList(
    h2(tagList(icon("chart-line"), "Risk Matrix Guide"), class = "mb-4"),
    box(
      title = "Understanding Risk Matrices",
      status = "warning",
      solidHeader = TRUE,
      width = 12,
      uiOutput("risk_matrix_help_detailed")
    )
  )
}

get_bayesian_help_content <- function() {
  tagList(
    h2(tagList(icon("brain"), "Bayesian Approach Guide"), class = "mb-4"),
    box(
      title = "Bayesian Network Analysis",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      uiOutput("bayesian_help_detailed")
    )
  )
}

get_bowtie_method_help_content <- function() {
  tagList(
    h2(tagList(icon("diagram-project"), "BowTie Method"), class = "mb-4"),
    box(
      title = "BowTie Analysis Methodology",
      status = "success",
      solidHeader = TRUE,
      width = 12,
      uiOutput("bowtie_method_help_detailed")
    )
  )
}

get_app_guide_help_content <- function() {
  tagList(
    h2(tagList(icon("book"), "Application Guide"), class = "mb-4"),
    box(
      title = "Complete Application Guide",
      status = "info",
      solidHeader = TRUE,
      width = 12,
      uiOutput("app_guide_detailed")
    )
  )
}

get_user_manual_help_content <- function() {
  tagList(
    h2(tagList(icon("file-pdf"), "User Manual"), class = "mb-4"),
    box(
      title = "Comprehensive User Manual",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      uiOutput("user_manual_detailed")
    )
  )
}

get_about_content <- function() {
  tagList(
    h2(tagList(icon("info-circle"), "About"), class = "mb-4"),
    box(
      title = "About This Application",
      status = "info",
      solidHeader = TRUE,
      width = 12,
      uiOutput("about_content")
    )
  )
}
