# =============================================================================
# Environmental Bowtie Risk Analysis Application - bs4Dash UI
# Version: 5.4.0 (Dashboard Edition)
# Framework: bs4Dash (AdminLTE3) with Bootstrap 4+ compatibility
# =============================================================================

# Source the original UI content sections
source("ui_content_sections.R", local = TRUE)

ui <- dashboardPage(
  dark = NULL,
  help = NULL,
  fullscreen = TRUE,
  scrollToTop = TRUE,

  # =============================================================================
  # HEADER
  # =============================================================================
  header = dashboardHeader(
    title = dashboardBrand(
      title = "Bowtie Risk Analysis",
      color = "primary",
      href = "#",
      image = "img/marbefes.png",
      opacity = 1
    ),
    skin = "light",
    status = "white",
    border = TRUE,
    sidebarIcon = icon("bars"),
    controlbarIcon = icon("gear"),
    fixed = FALSE,

    leftUi = tagList(
      dropdownMenu(
        badgeStatus = "info",
        type = "messages",
        icon = icon("bell"),
        headerText = "Notifications",

        messageItem(
          message = paste0("Version ", APP_CONFIG$VERSION),
          from = "System",
          icon = icon("check"),
          time = "Now"
        )
      )
    ),

    rightUi = tagList(
      dropdownMenu(
        badgeStatus = "danger",
        type = "notifications",
        icon = icon("question-circle"),
        headerText = "Help",

        notificationItem(
          text = "User Guide",
          icon = icon("book"),
          status = "info",
          href = "#"
        ),
        notificationItem(
          text = "About",
          icon = icon("info-circle"),
          status = "success",
          href = "#"
        )
      )
    )
  ),

  # =============================================================================
  # SIDEBAR
  # =============================================================================
  sidebar = dashboardSidebar(
    skin = "light",
    status = "primary",
    elevation = 3,
    collapsed = FALSE,
    minified = TRUE,
    expandOnHover = TRUE,
    fixed = TRUE,

    sidebarUserPanel(
      name = "Environmental Risk Management"
    ),

    sidebarMenu(
      id = "sidebar_menu",
      flat = FALSE,
      compact = FALSE,
      childIndent = TRUE,

      # Data Management
      sidebarHeader("DATA MANAGEMENT"),

      menuItem(
        text = "Data Upload",
        tabName = "upload",
        icon = icon("upload")
      ),

      menuItem(
        text = "Data Table",
        tabName = "table",
        icon = icon("table")
      ),

      menuItem(
        text = "Guided Creation",
        tabName = "guided",
        icon = icon("magic")
      ),

      menuItem(
        text = "Link Review",
        tabName = "link_risk",
        icon = icon("link")
      ),

      # Analysis Tools
      sidebarHeader("RISK ANALYSIS"),

      menuItem(
        text = "Bowtie Diagram",
        tabName = "bowtie",
        icon = icon("project-diagram")
      ),

      menuItem(
        text = "Risk Matrix",
        tabName = "matrix",
        icon = icon("th")
      ),

      # Advanced Analysis
      sidebarHeader("ADVANCED ANALYSIS"),

      menuItem(
        text = "Bayesian Networks",
        tabName = "bayesian",
        icon = icon("brain")
      ),

      # Resources
      sidebarHeader("RESOURCES"),

      menuItem(
        text = "Vocabulary",
        tabName = "vocabulary",
        icon = icon("book")
      ),

      menuItem(
        text = "Report",
        tabName = "report",
        icon = icon("file-alt")
      ),

      # Help & Documentation
      sidebarHeader("HELP & DOCS"),

      menuItem(
        text = "Help Center",
        icon = icon("question-circle"),
        startExpanded = FALSE,

        menuSubItem(
          text = "Guided Workflow",
          tabName = "workflow_help",
          icon = icon("magic")
        ),
        menuSubItem(
          text = "Risk Matrix Guide",
          tabName = "risk_matrix_help",
          icon = icon("chart-line")
        ),
        menuSubItem(
          text = "Bayesian Approach",
          tabName = "bayesian_help",
          icon = icon("brain")
        ),
        menuSubItem(
          text = "BowTie Method",
          tabName = "bowtie_method_help",
          icon = icon("diagram-project")
        ),
        menuSubItem(
          text = "Application Guide",
          tabName = "app_guide_help",
          icon = icon("book")
        ),
        menuSubItem(
          text = "User Manual",
          tabName = "user_manual_help",
          icon = icon("file-pdf")
        ),
        menuSubItem(
          text = "About",
          tabName = "about",
          icon = icon("info-circle")
        )
      )
    )
  ),

  # =============================================================================
  # CONTROL BAR (Settings)
  # =============================================================================
  controlbar = dashboardControlbar(
    id = "controlbar",
    skin = "light",
    pinned = FALSE,
    overlay = TRUE,

    controlbarMenu(
      id = "controlbarMenu",

      controlbarItem(
        title = "Settings",
        icon = icon("gear"),

        h4("Language Settings"),
        uiOutput("settings_language_section"),

        hr(),

        h4("Theme Settings"),
        uiOutput("settings_theme_header"),

        selectInput("theme_preset", "Select Theme:",
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
                     "⚡ High Contrast" = "bootstrap"
                   ),
                   selected = "journal"),

        br(),
        actionButton("applyTheme",
                    "Apply Theme",
                    icon = icon("palette"),
                    class = "btn-primary btn-block")
      )
    )
  ),

  # =============================================================================
  # FOOTER
  # =============================================================================
  footer = dashboardFooter(
    left = tagList(
      "Environmental Bowtie Risk Analysis Tool",
      tags$span(class = "badge badge-success ml-2", paste0("v", APP_CONFIG$VERSION))
    ),
    right = "Marbefes © 2025"
  ),

  # =============================================================================
  # BODY
  # =============================================================================
  body = dashboardBody(

    # Shinyjs
    useShinyjs(),

    # UI Components
    ui_components_css(),
    ui_components_js(),

    # Custom CSS for bs4Dash compatibility
    tags$head(
      tags$style(HTML("
        /* Custom styling for bs4Dash */
        .content-wrapper {
          background-color: #f4f6f9;
        }

        /* Network visualization */
        .network-container {
          border: 2px solid #e9ecef;
          border-radius: 8px;
          padding: 10px;
          background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
        }

        /* Enhanced legend */
        .enhanced-legend {
          background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
          border: 1px solid #dee2e6;
          border-radius: 8px;
          padding: 15px;
        }

        /* Bayesian panel */
        .bayesian-panel {
          border: 2px solid #007bff;
          border-radius: 8px;
          background: linear-gradient(135deg, #e3f2fd 0%, #ffffff 100%);
          padding: 15px;
        }

        /* Inference results */
        .inference-result {
          background: #f8f9fa;
          border-left: 4px solid #007bff;
          padding: 15px;
          margin: 10px 0;
          border-radius: 4px;
        }

        /* Card enhancements */
        .card {
          box-shadow: 0 0 1px rgba(0,0,0,.125), 0 1px 3px rgba(0,0,0,.2);
          margin-bottom: 1rem;
        }

        /* Sidebar branding */
        .brand-link {
          padding: 0.8125rem 0.5rem;
        }

        .brand-image {
          max-height: 40px;
          width: auto;
        }

        /* Menu improvements */
        .nav-sidebar > .nav-item .nav-icon {
          margin-left: 0;
          font-size: 1.1rem;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
          .content-wrapper {
            margin-left: 0 !important;
          }
        }

        /* Badge animations */
        @keyframes pulse {
          0% { transform: scale(1); }
          50% { transform: scale(1.05); }
          100% { transform: scale(1); }
        }

        .badge-success {
          animation: pulse 2s infinite;
        }

        /* Disabled menu items */
        .nav-sidebar .nav-link.disabled {
          opacity: 0.5;
          cursor: not-allowed;
          pointer-events: none;
        }

        .nav-sidebar .nav-link.disabled:hover {
          background-color: transparent;
        }
      "))
    ),

    # Tab Items
    tabItems(

      # DATA UPLOAD TAB
      tabItem(
        tabName = "upload",
        h2("Data Upload & Generation", class = "mb-4"),

        # Load tab content
        get_upload_tab_content()
      ),

      # GUIDED CREATION TAB
      tabItem(
        tabName = "guided",
        get_guided_tab_content()
      ),

      # BOWTIE DIAGRAM TAB
      tabItem(
        tabName = "bowtie",
        get_bowtie_tab_content()
      ),

      # BAYESIAN NETWORKS TAB
      tabItem(
        tabName = "bayesian",
        get_bayesian_tab_content()
      ),

      # DATA TABLE TAB
      tabItem(
        tabName = "table",
        get_table_tab_content()
      ),

      # RISK MATRIX TAB
      tabItem(
        tabName = "matrix",
        get_matrix_tab_content()
      ),

      # LINK RISK TAB
      tabItem(
        tabName = "link_risk",
        get_link_risk_tab_content()
      ),

      # VOCABULARY TAB
      tabItem(
        tabName = "vocabulary",
        get_vocabulary_tab_content()
      ),

      # REPORT TAB
      tabItem(
        tabName = "report",
        get_report_tab_content()
      ),

      # HELP TABS
      tabItem(
        tabName = "workflow_help",
        get_workflow_help_content()
      ),

      tabItem(
        tabName = "risk_matrix_help",
        get_risk_matrix_help_content()
      ),

      tabItem(
        tabName = "bayesian_help",
        get_bayesian_help_content()
      ),

      tabItem(
        tabName = "bowtie_method_help",
        get_bowtie_method_help_content()
      ),

      tabItem(
        tabName = "app_guide_help",
        get_app_guide_help_content()
      ),

      tabItem(
        tabName = "user_manual_help",
        get_user_manual_help_content()
      ),

      tabItem(
        tabName = "about",
        get_about_content()
      )
    )
  ),

  # Dashboard options
  title = "Environmental Bowtie Risk Analysis"
)
