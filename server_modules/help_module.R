# =============================================================================
# Server Module - Help & Documentation
# =============================================================================
# Purpose: Handles all help-related observers, modals, and detailed help content
# Dependencies: translations (t function), APP_CONFIG
# =============================================================================

#' Initialize help and documentation module
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param lang Reactive function returning current language code
#' @return NULL (module defines outputs and observers directly)
init_help_module <- function(input, output, session, lang) {

  # ===========================================================================
  # HELP MENU HANDLERS
  # ===========================================================================

  # Show User Guide modal when clicked from help dropdown
  observeEvent(input$show_user_guide, {
    showModal(modalDialog(
      title = tagList(icon("book"), " User Guide"),
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),

      h4("Environmental Bowtie Risk Analysis", class = "text-primary"),
      hr(),

      h5(icon("info-circle"), " Overview"),
      p("This application helps you create and analyze environmental risk assessments using bowtie diagrams enhanced with Bayesian network analysis."),

      h5(icon("list-ol"), " Getting Started", class = "mt-4"),
      tags$ol(
        tags$li("Go to ", tags$strong("Guided Workflow"), " tab to create a new bowtie diagram"),
        tags$li("Or upload existing data via ", tags$strong("Data Management"), " tab"),
        tags$li("View your bowtie diagram in the ", tags$strong("Bowtie Diagram"), " tab"),
        tags$li("Analyze risks using ", tags$strong("Risk Matrix"), " and ", tags$strong("Bayesian Analysis"))
      ),

      h5(icon("lightbulb"), " Tips", class = "mt-4"),
      tags$ul(
        tags$li("Use the 8-step guided workflow for structured risk assessment"),
        tags$li("Export your work to Excel for sharing and backup"),
        tags$li("Switch languages using the flag icons in the header")
      ),

      h5(icon("file-pdf"), " Full Documentation", class = "mt-4"),
      p("For detailed documentation, see the User Manual in the docs folder.")
    ))
  }, ignoreInit = TRUE)

  # Show About modal when clicked from help dropdown
  observeEvent(input$show_about, {
    current_lang <- lang()

    showModal(modalDialog(
      title = tagList(icon("info-circle"), " ", t("about_title", current_lang)),
      size = "l",
      easyClose = TRUE,
      footer = modalButton(if(current_lang == "en") "Close" else "Fermer"),

      div(class = "text-center mb-4",
        h4("Environmental Bowtie Risk Analysis", class = "text-success"),
        p(class = "text-muted", paste("Version", APP_CONFIG$VERSION))
      ),

      # App Summary Section
      div(class = "alert alert-primary",
        h5(tagList(icon("info-circle"), " ", t("about_summary_title", current_lang)), class = "alert-heading"),
        p(t("about_summary_text", current_lang)),
        hr(),
        h6(tagList(icon("rocket"), " ", t("about_getting_started", current_lang))),
        p(class = "mb-0", t("about_getting_started_text", current_lang))
      ),

      hr(),

      # Key Features
      h5(tagList(icon("list-check"), " ", t("about_features", current_lang)), class = "mt-3"),
      tags$ul(
        tags$li(tagList(icon("check-circle", class = "text-success"), " ", t("about_feature1", current_lang))),
        tags$li(tagList(icon("check-circle", class = "text-success"), " ", t("about_feature2", current_lang))),
        tags$li(tagList(icon("check-circle", class = "text-success"), " ", t("about_feature3", current_lang))),
        tags$li(tagList(icon("check-circle", class = "text-success"), " ", t("about_feature4", current_lang))),
        tags$li(tagList(icon("check-circle", class = "text-success"), " ", t("about_feature5", current_lang))),
        tags$li(tagList(icon("check-circle", class = "text-success"), " ", t("about_feature6", current_lang)))
      ),

      hr(),

      fluidRow(
        column(4, class = "text-center",
          h6(icon("users"), if(current_lang == "en") " Developed by" else " Developpe par"),
          p(class = "small", "Marbefes Team")
        ),
        column(4, class = "text-center",
          h6(icon("code"), if(current_lang == "en") " Built with" else " Construit avec"),
          p(class = "small", "R Shiny, bs4Dash, bnlearn")
        ),
        column(4, class = "text-center",
          h6(icon("calendar"), if(current_lang == "en") " Release" else " Version"),
          p(class = "small", "January 2026")
        )
      )
    ))
  }, ignoreInit = TRUE)

  # ===========================================================================
  # DETAILED HELP CONTENT RENDERERS
  # ===========================================================================

  # Workflow Help Content
  output$workflow_help_detailed <- renderUI({
    current_lang <- lang()

    div(
      h4("Step-by-Step Guided Workflow", class = "text-info"),
      hr(),

      p(class = "lead", "The Guided Workflow system helps you create comprehensive bowtie diagrams through an interactive 8-step process."),

      h5(tagList(icon("list-ol"), "Workflow Steps"), class = "mt-4"),
      tags$ol(
        tags$li(tags$strong("Project Setup:"), " Define basic project information and select environmental scenario"),
        tags$li(tags$strong("Central Problem:"), " Identify the core environmental problem or hazard event"),
        tags$li(tags$strong("Threats & Causes:"), " Select activities and pressures from the vocabulary database"),
        tags$li(tags$strong("Preventive Controls:"), " Choose controls to prevent or mitigate threats"),
        tags$li(tags$strong("Consequences:"), " Identify potential environmental impacts"),
        tags$li(tags$strong("Protective Controls:"), " Add controls to reduce consequence severity"),
        tags$li(tags$strong("Review & Validate:"), " Check connections and data integrity"),
        tags$li(tags$strong("Finalize & Export:"), " Export to Excel or load into main application")
      ),

      div(class = "alert alert-success mt-4",
        tagList(
          icon("lightbulb"), " ",
          strong("Tip:"), " Use the AI suggestions feature (available in Settings) to get intelligent recommendations based on your selections."
        )
      )
    )
  })

  # Risk Matrix Help Content
  output$risk_matrix_help_detailed <- renderUI({
    current_lang <- lang()

    div(
      h4("Understanding Risk Matrices", class = "text-warning"),
      hr(),

      p(class = "lead", "Risk matrices provide a visual representation of risks based on likelihood and impact."),

      h5(tagList(icon("chart-bar"), "Matrix Types"), class = "mt-4"),
      tags$ul(
        tags$li(tags$strong("3x3 Simple:"), " Basic risk assessment with Low, Medium, High categories"),
        tags$li(tags$strong("5x5 Standard:"), " Comprehensive assessment with five levels of likelihood and impact"),
        tags$li(tags$strong("7x7 Detailed:"), " Advanced assessment for complex scenarios")
      ),

      h5(tagList(icon("calculator"), "Risk Calculation Methods"), class = "mt-4"),
      tags$ul(
        tags$li(tags$strong("Likelihood x Impact:"), " Traditional risk score calculation"),
        tags$li(tags$strong("Maximum Value:"), " Takes the higher of likelihood or impact"),
        tags$li(tags$strong("Weighted Average:"), " Customizable weights for likelihood and impact")
      ),

      div(class = "alert alert-info mt-4",
        tagList(
          icon("info-circle"), " ",
          strong("Note:"), " Color coding helps identify high-risk items (red) that require immediate attention."
        )
      )
    )
  })

  # Bayesian Network Help Content
  output$bayesian_help_detailed <- renderUI({
    current_lang <- lang()

    div(
      h4("Bayesian Network Analysis", class = "text-primary"),
      hr(),

      p(class = "lead", "Bayesian Networks provide probabilistic modeling of environmental risks, enabling advanced inference and scenario analysis."),

      h5(tagList(icon("network-wired"), "Key Concepts"), class = "mt-4"),
      tags$ul(
        tags$li(tags$strong("Probabilistic Dependencies:"), " Models relationships between activities, pressures, and consequences"),
        tags$li(tags$strong("Conditional Probability:"), " Calculates likelihood of events given observed conditions"),
        tags$li(tags$strong("Inference:"), " Determines probability of consequences based on control effectiveness"),
        tags$li(tags$strong("Critical Path Analysis:"), " Identifies highest-risk pathways through the network")
      ),

      h5(tagList(icon("cogs"), "How to Use"), class = "mt-4"),
      tags$ol(
        tags$li("Load or create bowtie diagram data"),
        tags$li("Navigate to Bayesian Networks tab"),
        tags$li("Click 'Create Bayesian Network' to generate the network"),
        tags$li("Use inference tools to analyze specific scenarios"),
        tags$li("Visualize and export results")
      ),

      div(class = "alert alert-warning mt-4",
        tagList(
          icon("exclamation-triangle"), " ",
          strong("Advanced Feature:"), " Bayesian analysis requires complete probability data. Ensure all connections have assigned probabilities."
        )
      )
    )
  })

  # BowTie Method Help Content
  output$bowtie_method_help_detailed <- renderUI({
    current_lang <- lang()

    div(
      h4("BowTie Risk Analysis Method", class = "text-success"),
      hr(),

      p(class = "lead", "The BowTie method is a risk assessment tool that visualizes the relationship between hazards, threats, consequences, and controls."),

      h5(tagList(icon("diagram-project"), "BowTie Components"), class = "mt-4"),
      tags$dl(
        tags$dt("Central Problem (Hazard Event)"),
        tags$dd("The core environmental hazard or problem being analyzed"),

        tags$dt("Threats (Left Side)"),
        tags$dd("Activities and pressures that can trigger the hazard event"),

        tags$dt("Preventive Controls (Left Barriers)"),
        tags$dd("Measures that prevent threats from causing the hazard"),

        tags$dt("Consequences (Right Side)"),
        tags$dd("Potential environmental impacts if the hazard occurs"),

        tags$dt("Protective Controls (Right Barriers)"),
        tags$dd("Measures that mitigate consequence severity")
      ),

      h5(tagList(icon("star"), "Benefits"), class = "mt-4"),
      tags$ul(
        tags$li("Visual representation of complex risk scenarios"),
        tags$li("Identifies control gaps and redundancies"),
        tags$li("Facilitates communication among stakeholders"),
        tags$li("Supports risk-based decision making")
      ),

      div(class = "alert alert-success mt-4",
        tagList(
          icon("check-circle"), " ",
          strong("Best Practice:"), " Start with the central problem and work outward to threats and consequences. Add controls last."
        )
      )
    )
  })

  # Application Guide Help Content
  output$app_guide_detailed <- renderUI({
    current_lang <- lang()

    div(
      h4("Complete Application Guide", class = "text-info"),
      hr(),

      h5(tagList(icon("rocket"), "Getting Started"), class = "mt-4"),
      tags$ol(
        tags$li(tags$strong("Upload Data:"), " Import Excel file or generate environmental scenario data"),
        tags$li(tags$strong("Create Bowtie:"), " Use Guided Workflow or Data Upload to create your analysis"),
        tags$li(tags$strong("Visualize:"), " View bowtie diagram and network visualization"),
        tags$li(tags$strong("Analyze:"), " Use risk matrix and Bayesian networks for deeper insights"),
        tags$li(tags$strong("Export:"), " Download results as Excel, PDF, or image files")
      ),

      h5(tagList(icon("table"), "Main Features"), class = "mt-4"),
      tags$ul(
        tags$li(tags$strong("Dashboard:"), " Overview of data structure and vocabulary statistics"),
        tags$li(tags$strong("Data Upload:"), " Import from Excel or generate environmental scenarios"),
        tags$li(tags$strong("Guided Creation:"), " Step-by-step workflow for creating bowties"),
        tags$li(tags$strong("Bowtie Diagram:"), " Interactive network visualization"),
        tags$li(tags$strong("Bayesian Networks:"), " Probabilistic risk analysis"),
        tags$li(tags$strong("Risk Matrix:"), " Likelihood/impact assessment"),
        tags$li(tags$strong("Vocabulary:"), " Browse environmental risk database (189 items)")
      ),

      div(class = "alert alert-primary mt-4",
        tagList(
          icon("question-circle"), " ",
          strong("Need Help?"), " Each tab has context-specific help. Look for ", icon("question-circle"), " icons throughout the application."
        )
      )
    )
  })

  # User Manual Help Content
  output$user_manual_detailed <- renderUI({
    current_lang <- lang()

    div(
      h4("Comprehensive User Manual", class = "text-primary"),
      hr(),

      h5(tagList(icon("book-open"), "Table of Contents"), class = "mt-4"),
      tags$ol(
        tags$li(tags$a(href = "#intro", "Introduction & Overview")),
        tags$li(tags$a(href = "#installation", "Installation & Setup")),
        tags$li(tags$a(href = "#navigation", "Navigation & Interface")),
        tags$li(tags$a(href = "#data", "Data Management")),
        tags$li(tags$a(href = "#workflow", "Guided Workflow Tutorial")),
        tags$li(tags$a(href = "#analysis", "Analysis Tools")),
        tags$li(tags$a(href = "#export", "Exporting Results")),
        tags$li(tags$a(href = "#troubleshooting", "Troubleshooting"))
      ),

      h5(tagList(icon("download"), "Documentation Downloads"), class = "mt-4"),
      p("Comprehensive documentation is available for download:"),

      div(class = "mt-3",
        actionButton("download_user_manual_pdf",
                    tagList(icon("file-pdf"), " Download User Manual (PDF)"),
                    class = "btn-primary"),

        actionButton("download_quick_start",
                    tagList(icon("file-alt"), " Download Quick Start Guide"),
                    class = "btn-info ml-2")
      ),

      div(class = "alert alert-info mt-4",
        tagList(
          icon("lightbulb"), " ",
          strong("Quick Start:"), " New users should begin with the Guided Workflow (Guided Creation tab) to learn the application step-by-step."
        )
      )
    )
  })

  # About Tab Content
  output$about_content <- renderUI({
    current_lang <- lang()

    div(
      h4(t("about_title", current_lang), class = "text-success"),
      hr(),

      # App Summary Section
      div(class = "alert alert-primary mb-4",
        h5(tagList(icon("info-circle"), " ", t("about_summary_title", current_lang)), class = "alert-heading mb-3"),
        p(t("about_summary_text", current_lang)),
        hr(),
        h6(tagList(icon("rocket"), " ", t("about_getting_started", current_lang)), class = "mb-2"),
        p(class = "mb-0", t("about_getting_started_text", current_lang))
      ),

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
            "Cette application supporte maintenant l'anglais et le francais. Changez de langue en utilisant le selecteur dans la barre de navigation en haut."
          }
        )
      ),

      div(class = "alert alert-success mt-3",
        tagList(
          icon("users"), " ",
          strong(if(current_lang == "en") "Development Team" else "Equipe de Developpement"), ": ",
          if(current_lang == "en") {
            "Marbefes Environmental Risk Assessment Team"
          } else {
            "Equipe d'Evaluation des Risques Environnementaux Marbefes"
          }
        )
      )
    )
  })

  # About Tab Header
  output$about_header <- renderUI({
    tagList(icon("info-circle"), t("about_title", lang()))
  })

  # ===========================================================================
  # MANUAL DOWNLOAD HANDLERS
  # ===========================================================================

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
        notify_success(paste("User manual v", APP_CONFIG$VERSION, " downloaded successfully!"), duration = 3)
      } else {
        # If manual not found, create error message
        notify_error(paste0("User manual v", APP_CONFIG$VERSION,
                 " not found at: ", manual_path,
                 ". Please contact support."), duration = 10)
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
        notify_success(paste("Manuel utilisateur v", APP_CONFIG$VERSION, " telecharge avec succes!"), duration = 3)
      } else {
        # If manual not found, create error message
        notify_error(paste0("Manuel utilisateur v", APP_CONFIG$VERSION,
                 " introuvable a: ", manual_path,
                 ". Veuillez contacter le support."), duration = 10)
      }
    }
  )

  bowtie_log("Help & documentation module initialized", level = "info")
}
