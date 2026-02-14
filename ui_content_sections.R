# =============================================================================
# UI Content Sections for bs4Dash Conversion
# This file contains functions that return the content for each tab
# Extracted and adapted from the original UI
# =============================================================================

# =============================================================================
# DASHBOARD TAB CONTENT
# =============================================================================
get_dashboard_tab_content <- function() {
  tagList(
    h2(tagList(icon("dashboard"), "Dashboard"), class = "mb-4"),

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
        h6(tagList(icon("database"), "Vocabulary Statistics"), class = "mb-3"),

        # Activities InfoBox
        uiOutput("vocab_activities_infobox"),

        # Pressures InfoBox
        uiOutput("vocab_pressures_infobox"),

        # Controls InfoBox
        uiOutput("vocab_controls_infobox"),

        # Consequences InfoBox
        uiOutput("vocab_consequences_infobox")
      ),

      column(4,
        conditionalPanel(
          condition = "output.dataLoaded",
          h6(tagList(icon("chart-bar"), "Loaded Data Statistics"), class = "mb-3"),

          # Total Scenarios InfoBox
          uiOutput("data_scenarios_infobox"),

          # Elements Used InfoBox
          uiOutput("data_elements_infobox")
        ),

        conditionalPanel(
          condition = "!output.dataLoaded",
          box(
            title = tagList(icon("info-circle"), "Getting Started"),
            status = "warning",
            solidHeader = TRUE,
            width = 12,

            tags$p("Welcome to the Environmental Bowtie Risk Analysis application!"),
            tags$hr(),
            tags$h6(tagList(icon("upload"), " Quick Start:")),
            tags$ul(
              tags$li("Upload your Excel data via the ", tags$strong("Data Upload"), " tab"),
              tags$li("Or generate sample data using ", tags$strong("Environmental Scenarios")),
              tags$li("Create a new analysis with the ", tags$strong("Guided Creation"), " wizard")
            ),
            tags$div(class = "text-center mt-3",
              actionButton("dashboard_goto_upload",
                          tagList(icon("arrow-right"), " Go to Data Upload"),
                          class = "btn-primary",
                          `data-toggle` = "tooltip",
                          title = "Navigate to the Data Upload page to get started")
            )
          )
        )
      )
    )
  )
}

# =============================================================================
# DATA UPLOAD TAB CONTENT
# =============================================================================
get_upload_tab_content <- function() {
  tagList(
    h2(tagList(icon("upload"), "Data Upload & Generation"), class = "mb-4"),

    fluidRow(
      column(12,
        box(
          title = uiOutput("data_input_options_header", inline = TRUE),
          status = "primary",
          solidHeader = TRUE,
          width = 12,

          fluidRow(
            # Left column - File upload (Option 1)
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

            # Right column - Generate from vocabulary (Option 2)
            column(6,
              div(style = "min-height: 150px;",
                uiOutput("data_upload_option2_title"),
                uiOutput("data_option2_desc")
              ),
              div(class = "mb-3",
                selectInput("data_scenario_template",
                           "Select environmental scenario:",
                           choices = get_environmental_scenario_choices(include_blank = TRUE),
                           selected = "")
              ),
              actionButton("generateMultipleControls",
                          tagList(icon("seedling"), "Generate Data"),
                          class = "btn-success btn-block",
                          `data-toggle` = "tooltip",
                          `data-placement` = "top",
                          title = "Generate sample environmental data based on selected scenario"),
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
        maximizable = TRUE,

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
      title = tagList(icon("sliders-h"), "Diagram Configuration"),
      status = "primary",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12,

      fluidRow(
        column(3,
          selectInput("selectedProblem", "Select Central Problem:",
                     choices = NULL,
                     selected = NULL)
        ),
        column(2,
          selectInput("nodeSize", "Node Size:",
                     choices = c("Small" = "small",
                               "Medium" = "medium",
                               "Large" = "large"),
                     selected = "medium")
        ),
        column(2,
          sliderInput("fontSize", "Font Size:",
                     min = 8, max = 24, value = 12, step = 1,
                     post = "px")
        ),
        column(2,
          checkboxInput("showRiskLevels", "Show Risk Levels", value = TRUE),
          checkboxInput("showBarriers", "Show Barriers", value = TRUE)
        ),
        column(3,
          checkboxInput("editMode", "Edit Mode", value = FALSE),
          actionButton("resetFontSize", "Reset Font",
                      class = "btn-outline-secondary btn-sm mt-1",
                      icon = icon("undo"))
        )
      )
    ),

    box(
      title = tagList(icon("network-wired"), "Interactive Bowtie Diagram"),
      status = "success",
      solidHeader = TRUE,
      width = 12,
      maximizable = TRUE,
      elevation = 2,
      dropdownMenu = boxDropdown(
        icon = icon("bars"),
        boxDropdownItem("Refresh Diagram", id = "refresh_bowtie_menu", icon = icon("sync")),
        boxDropdownItem("Export PNG", id = "export_bowtie_png_menu", icon = icon("image")),
        boxDropdownItem("Export SVG", id = "export_bowtie_svg_menu", icon = icon("file-code")),
        boxDropdownItem("Fit to Screen", id = "fit_bowtie_menu", icon = icon("expand"))
      ),

      div(class = "network-container",
        withSpinner(visNetworkOutput("bowtieNetwork", height = "700px"))
      ),

      hr(),

      # Export options
      div(class = "export-options p-3 bg-light rounded mb-3",
        h6(tagList(icon("download"), " Export Diagram"), class = "mb-3"),
        fluidRow(
          column(4,
            downloadButton("downloadBowtie",
                          tagList(icon("code"), " HTML (Interactive)"),
                          class = "btn-info btn-sm w-100"),
            tags$small(class = "text-muted d-block mt-1", "Full interactivity, larger file")
          ),
          column(4,
            downloadButton("downloadBowtieJPEG",
                          tagList(icon("image"), " JPEG (Image)"),
                          class = "btn-success btn-sm w-100"),
            tags$small(class = "text-muted d-block mt-1", "White background, best for documents")
          ),
          column(4,
            downloadButton("downloadBowtiePNG",
                          tagList(icon("image"), " PNG (Image)"),
                          class = "btn-secondary btn-sm w-100"),
            tags$small(class = "text-muted d-block mt-1", "White background, good quality")
          )
        )
      ),

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
    h2(tagList(icon("brain"), "Bayesian Network Analysis"), class = "mb-3"),

    # Row 1: Configuration + Inference Controls + Results (3 columns)
    fluidRow(
      # Left: Network Configuration
      column(3,
        box(
          title = tagList(icon("cogs"), "Network Setup"),
          status = "primary",
          solidHeader = TRUE,
          collapsible = FALSE,
          width = 12,

          selectInput("bayesianProblem", "Central Problem:",
                     choices = NULL,
                     selected = NULL),

          div(class = "d-grid",
            actionButton("createBayesianNetwork",
                        tagList(icon("brain"), " Create Network"),
                        class = "btn-success")
          )
        )
      ),

      # Middle: Probabilistic Inference Controls
      column(5,
        box(
          title = tagList(icon("calculator"), "Probabilistic Inference"),
          status = "info",
          solidHeader = TRUE,
          collapsible = FALSE,
          width = 12,

          uiOutput("bayesian_evidence_ui"),

          hr(),
          div(class = "d-grid",
            actionButton("runInference",
                        tagList(icon("play-circle"), " Run Inference"),
                        class = "btn-primary btn-lg")
          )
        )
      ),

      # Right: Inference Results
      column(4,
        box(
          title = tagList(icon("chart-bar"), "Inference Results"),
          status = "warning",
          solidHeader = TRUE,
          collapsible = FALSE,
          width = 12,

          conditionalPanel(
            condition = "!output.inferenceCompleted",
            div(class = "text-center p-3 text-muted",
              icon("calculator", class = "fa-2x mb-2"),
              p(class = "small mb-0", "Click 'Run Inference' to see predictions")
            )
          ),

          conditionalPanel(
            condition = "output.inferenceCompleted",
            uiOutput("inferenceResults")
          ),

          hr(),

          # Risk Interpretation inline
          conditionalPanel(
            condition = "output.inferenceCompleted",
            uiOutput("riskInterpretation")
          )
        )
      )
    ),

    # Row 2: Network Visualization + CPTs
    fluidRow(
      # Network visualization (larger)
      column(8,
        box(
          title = tagList(icon("project-diagram"), "Bayesian Network Structure"),
          status = "success",
          solidHeader = TRUE,
          width = 12,
          maximizable = TRUE,

          # Legend is now provided by native visNetwork (left side)
          withSpinner(visNetworkOutput("bayesianNetworkVis", height = "500px"))
        )
      ),

      # CPT Tables (smaller, on right)
      column(4,
        box(
          title = tagList(icon("table"), "CPT Tables"),
          status = "secondary",
          solidHeader = TRUE,
          collapsible = TRUE,
          collapsed = TRUE,
          width = 12,
          maximizable = TRUE,
          style = "max-height: 580px; overflow-y: auto;",

          withSpinner(uiOutput("cptTables"))
        )
      )
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
      maximizable = TRUE,
      elevation = 2,
      dropdownMenu = boxDropdown(
        icon = icon("bars"),
        boxDropdownItem("Refresh Table", id = "refresh_data_table_menu", icon = icon("sync")),
        boxDropdownItem("Export CSV", id = "export_csv_menu", icon = icon("file-csv")),
        boxDropdownItem("Export Excel", id = "export_excel_menu", icon = icon("file-excel")),
        boxDropdownItem("Table Settings", id = "table_settings_menu", icon = icon("cog"))
      ),

      withSpinner(DT::dataTableOutput("data_table")),

      hr(),

      fluidRow(
        column(4,
          downloadButton("downloadData",
                        tagList(icon("download"), "Download CSV"),
                        class = "btn-success btn-block",
                        `data-toggle` = "tooltip",
                        title = "Export current data to CSV format")
        ),
        column(4,
          downloadButton("downloadExcel",
                        tagList(icon("file-excel"), "Download Excel"),
                        class = "btn-info btn-block",
                        `data-toggle` = "tooltip",
                        title = "Export current data to Excel format (.xlsx)")
        ),
        column(4,
          actionButton("refreshTable",
                      tagList(icon("refresh"), "Refresh Table"),
                      class = "btn-secondary btn-block",
                      `data-toggle` = "tooltip",
                      title = "Reload and refresh the data table")
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
                      class = "btn-primary btn-block",
                      `data-toggle` = "tooltip",
                      title = "Regenerate risk matrix with current settings")
        )
      )
    ),

    box(
      title = tagList(icon("th-large"), "Risk Heat Map"),
      status = "danger",
      solidHeader = TRUE,
      width = 12,
      maximizable = TRUE,
      elevation = 2,

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
      maximizable = TRUE,
      elevation = 2,

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
      maximizable = TRUE,
      dropdownMenu = boxDropdown(
        icon = icon("bars"),
        boxDropdownItem("Refresh Data", id = "refresh_vocabulary_menu", icon = icon("sync")),
        boxDropdownItem("Export Results", id = "export_vocabulary_menu", icon = icon("download")),
        boxDropdownItem("Clear Filters", id = "clear_vocab_filters_menu", icon = icon("filter-circle-xmark")),
        boxDropdownItem("View Statistics", id = "vocab_stats_menu", icon = icon("chart-bar"))
      ),

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
                        class = "btn-danger btn-block btn-lg",
                        `data-toggle` = "tooltip",
                        title = "Generate and download a comprehensive PDF report")
        ),
        column(4,
          downloadButton("downloadWord",
                        tagList(icon("file-word"), "Download Word"),
                        class = "btn-primary btn-block btn-lg",
                        `data-toggle` = "tooltip",
                        title = "Generate and download an editable Word document")
        ),
        column(4,
          downloadButton("downloadHTML",
                        tagList(icon("file-code"), "Download HTML"),
                        class = "btn-info btn-block btn-lg",
                        `data-toggle` = "tooltip",
                        title = "Generate and download an interactive HTML report")
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
