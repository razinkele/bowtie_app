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
      # User menu dropdown (dynamic - shows after login)
      uiOutput("header_user_menu"),

      # Help dropdown
      dropdownMenu(
        badgeStatus = "info",
        type = "messages",
        icon = icon("question-circle"),
        headerText = "Help & Support",

        # User Guide - properly structured with vertical alignment
        messageItem(
          from = "User Guide",
          message = "Learn how to use the application",
          icon = icon("book"),
          time = NULL,
          href = "javascript:void(0);",
          inputId = "show_user_guide"
        ),
        # About - properly structured with vertical alignment
        messageItem(
          from = "About",
          message = "Version info and credits",
          icon = icon("info-circle"),
          time = NULL,
          href = "javascript:void(0);",
          inputId = "show_about"
        )
      )
    )
  ),

  # =============================================================================
  # SIDEBAR
  # =============================================================================
  sidebar = dashboardSidebar(
    id = "sidebar",
    skin = "light",
    status = "primary",
    elevation = 3,
    collapsed = FALSE,
    minified = TRUE,
    expandOnHover = TRUE,
    fixed = TRUE,

    # User info panel (dynamic - shows logged in user)
    uiOutput("sidebar_user_panel"),

    sidebarMenu(
      id = "sidebar_menu",
      flat = FALSE,
      compact = FALSE,
      childIndent = TRUE,

      # Dashboard
      menuItem(
        text = "Dashboard",
        tabName = "dashboard",
        icon = icon("dashboard")
      ),

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
        icon = icon("table"),
        badgeLabel = textOutput("badge_data_table", inline = TRUE),
        badgeColor = "primary"
      ),

      menuItem(
        text = "Guided Creation",
        tabName = "guided",
        icon = icon("magic"),
        badgeLabel = textOutput("badge_guided", inline = TRUE),
        badgeColor = "warning"
      ),

      menuItem(
        text = "Link Review",
        tabName = "link_risk",
        icon = icon("link"),
        badgeLabel = textOutput("badge_link_review", inline = TRUE),
        badgeColor = "info"
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
        icon = icon("book"),
        badgeLabel = textOutput("badge_vocabulary", inline = TRUE),
        badgeColor = "success"
      ),

      menuItem(
        text = "Report",
        tabName = "report",
        icon = icon("file-alt")
      ),

      # Admin Section (dynamically shown only for admin users)
      uiOutput("admin_menu_section"),

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
    collapsed = TRUE,
    width = 420,

    controlbarMenu(
      id = "controlbarMenu",

      # =========================================================================
      # TAB 1: APPEARANCE (Language & Theme)
      # =========================================================================
      controlbarItem(
        title = "Appearance",
        icon = icon("palette"),

        div(class = "p-2",
          # Language Section
          div(class = "card mb-3",
            div(class = "card-header bg-primary text-white py-2",
              icon("language"), " Language"
            ),
            div(class = "card-body",
              uiOutput("settings_language_section")
            )
          ),

          # Theme Section
          div(class = "card",
            div(class = "card-header bg-primary text-white py-2",
              icon("brush"), " Theme"
            ),
            div(class = "card-body",
              uiOutput("settings_theme_header"),

              selectInput("theme_preset", NULL,
                         choices = c(
                           "Environmental (Default)" = "journal",
                           "Dark Mode" = "darkly",
                           "Light & Clean" = "flatly",
                           "Ocean Blue" = "cosmo",
                           "Forest Green" = "materia",
                           "Corporate Blue" = "cerulean",
                           "Minimal Clean" = "minty",
                           "Dashboard" = "lumen",
                           "Creative Purple" = "pulse",
                           "Science Lab" = "sandstone",
                           "Space Dark" = "slate",
                           "Professional" = "united",
                           "Modern Contrast" = "superhero",
                           "Sunset Orange" = "solar",
                           "Analytics" = "spacelab",
                           "Vibrant" = "sketchy",
                           "Nature Fresh" = "cyborg",
                           "Business" = "vapor",
                           "Research" = "zephyr",
                           "High Contrast" = "bootstrap"
                         ),
                         selected = "journal"),

              actionButton("applyTheme",
                          "Apply Theme",
                          icon = icon("check"),
                          class = "btn-primary btn-sm w-100 mt-2")
            )
          )
        )
      ),

      # =========================================================================
      # TAB 2: AI FEATURES
      # =========================================================================
      controlbarItem(
        title = "AI Features",
        icon = icon("robot"),

        div(class = "p-2",
          div(class = "card",
            div(class = "card-header bg-info text-white py-2",
              icon("lightbulb"), " AI Suggestions"
            ),
            div(class = "card-body",
              p(class = "text-muted small mb-3",
                "AI-powered vocabulary suggestions for Guided Workflow"),

              div(class = "form-check form-switch mb-3",
                checkboxInput("ai_suggestions_enabled",
                             "Enable AI Suggestions",
                             value = FALSE)
              ),
              tags$small(class = "form-text text-muted mb-3 d-block",
                icon("exclamation-triangle"), " May cause 2-3 second delays"
              ),

              conditionalPanel(
                condition = "input.ai_suggestions_enabled",

                hr(),

                h6(class = "text-secondary mb-2", "Analysis Methods"),

                div(class = "ms-2",
                  checkboxInput("ai_method_semantic",
                               "Semantic Similarity",
                               value = TRUE),

                  checkboxInput("ai_method_keyword",
                               "Keyword Matching",
                               value = TRUE),

                  checkboxInput("ai_method_causal",
                               "Causal Relationships",
                               value = TRUE)
                ),

                hr(),

                sliderInput("ai_max_suggestions",
                           "Max Suggestions:",
                           min = 1,
                           max = 10,
                           value = 5,
                           step = 1,
                           ticks = FALSE,
                           width = "100%")
              )
            )
          )
        )
      ),

      # =========================================================================
      # TAB 3: AUTOSAVE
      # =========================================================================
      controlbarItem(
        title = "Autosave",
        icon = icon("save"),

        div(class = "p-2",
          div(class = "card",
            div(class = "card-header bg-success text-white py-2",
              icon("clock"), " Autosave Settings"
            ),
            div(class = "card-body",
              p(class = "text-muted small mb-3",
                "Automatically save your work at regular intervals"),

              div(class = "form-check form-switch mb-3",
                checkboxInput("autosave_enabled",
                             "Enable Autosave",
                             value = FALSE)
              ),

              conditionalPanel(
                condition = "input.autosave_enabled",

                hr(),

                sliderInput("autosave_interval",
                           "Interval (minutes):",
                           min = 1,
                           max = 30,
                           value = 5,
                           step = 1,
                           ticks = FALSE,
                           width = "100%"),

                sliderInput("autosave_versions",
                           "Versions to Keep:",
                           min = 1,
                           max = 10,
                           value = 3,
                           step = 1,
                           ticks = FALSE,
                           width = "100%"),

                selectInput("autosave_location",
                           "Save Location:",
                           choices = c(
                             "Browser Storage" = "browser",
                             "Download to File" = "file",
                             "Both" = "both"
                           ),
                           selected = "browser"),

                hr(),

                checkboxInput("autosave_notify",
                             "Show notification on save",
                             value = TRUE),

                checkboxInput("autosave_autoload",
                             "Auto-load on startup",
                             value = TRUE),

                checkboxInput("autosave_include_data",
                             "Include data table",
                             value = FALSE),
                tags$small(class = "form-text text-muted mb-3 d-block",
                  icon("exclamation-triangle"), " May increase file size"
                ),

                hr(),

                div(class = "d-grid gap-2",
                  actionButton("autosave_now",
                              "Save Now",
                              icon = icon("save"),
                              class = "btn-success btn-sm"),
                  actionButton("autosave_clear",
                              "Clear All Saves",
                              icon = icon("trash"),
                              class = "btn-outline-danger btn-sm")
                ),

                div(class = "alert alert-light mt-3 mb-0 py-2 small",
                  icon("info-circle"), " Last save: ",
                  tags$span(id = "last_autosave_time", "Never")
                )
              )
            )
          )
        )
      ),

      # =========================================================================
      # TAB 4: STORAGE
      # =========================================================================
      controlbarItem(
        title = "Storage",
        icon = icon("folder-open"),

        div(class = "p-2",
          div(class = "card mb-3",
            div(class = "card-header bg-secondary text-white py-2",
              icon("database"), " Storage Mode"
            ),
            div(class = "card-body",
              p(class = "text-muted small mb-3",
                "Configure where to store configurations and saves"),

              # Custom radio buttons with descriptions
              div(class = "storage-options",
                div(class = "form-check mb-2",
                  tags$input(type = "radio", class = "form-check-input",
                             name = "storage_mode", id = "storage_browser",
                             value = "browser", checked = "checked"),
                  tags$label(class = "form-check-label", `for` = "storage_browser",
                    tags$strong("Browser (LocalStorage)")
                  ),
                  tags$small(class = "d-block text-muted ps-4",
                    "Saves in your browser. Quick and easy, but limited to ~5MB and may be cleared."
                  )
                ),
                div(class = "form-check mb-2",
                  tags$input(type = "radio", class = "form-check-input",
                             name = "storage_mode", id = "storage_local",
                             value = "local"),
                  tags$label(class = "form-check-label", `for` = "storage_local",
                    tags$strong("Local Folder")
                  ),
                  tags$small(class = "d-block text-muted ps-4",
                    "Saves to a folder on your computer. Best for large files and long-term storage."
                  )
                ),
                div(class = "form-check mb-2",
                  tags$input(type = "radio", class = "form-check-input",
                             name = "storage_mode", id = "storage_server",
                             value = "server"),
                  tags$label(class = "form-check-label", `for` = "storage_server",
                    tags$strong("Server Default")
                  ),
                  tags$small(class = "d-block text-muted ps-4",
                    "Saves to server's shared location. ",
                    tags$span(class = "text-warning",
                      icon("exclamation-triangle", class = "fa-xs"),
                      " Multi-user: files may conflict or be overwritten by others."
                    )
                  )
                )
              ),

              # Bind custom radios to Shiny input
              tags$script(HTML("
                $(document).on('change', 'input[name=\"storage_mode\"]', function() {
                  Shiny.setInputValue('storage_mode', this.value);
                });
                $(document).ready(function() {
                  Shiny.setInputValue('storage_mode', 'browser');
                });
              ")),

              # Browser storage info tooltip
              tags$details(class = "mt-2",
                tags$summary(class = "text-info small",
                  style = "cursor: pointer;",
                  icon("info-circle"), " Storage tips by browser"
                ),
                div(class = "small mt-2 ps-2", style = "font-size: 0.8em;",
                  tags$dl(class = "mb-0",
                    tags$dt("Chrome / Edge"),
                    tags$dd(class = "text-muted mb-2",
                      "Best support. ~5MB limit. Data persists until cleared."),

                    tags$dt("Firefox"),
                    tags$dd(class = "text-muted mb-2",
                      "Good support. May prompt for permission in private mode."),

                    tags$dt("Safari"),
                    tags$dd(class = "text-muted mb-2",
                      "7-day limit in some versions. Use 'Local Folder' for long-term storage."),

                    tags$dt("Private/Incognito"),
                    tags$dd(class = "text-muted mb-0",
                      "Data lost when window closes. Use 'Local Folder' instead.")
                  ),
                  hr(class = "my-2"),
                  p(class = "text-muted mb-0",
                    icon("lightbulb"), " ",
                    tags$strong("Tip:"), " For reliable long-term storage, use 'Local Folder' mode.")
                )
              )
            )
          ),

          conditionalPanel(
            condition = "input.storage_mode == 'local'",

            div(class = "card mb-3",
              div(class = "card-header bg-light py-2",
                icon("folder"), " Local Folder"
              ),
              div(class = "card-body",
                textInput("local_folder_path",
                          "Folder Path:",
                          value = "",
                          placeholder = "No folder selected...",
                          width = "100%"),

                div(class = "d-grid gap-2 mb-3",
                  shinyDirButton("select_folder",
                                 "Browse...",
                                 title = "Select folder for saving configurations",
                                 icon = icon("folder-open"),
                                 class = "btn-outline-primary btn-sm")
                ),

                checkboxInput("create_subfolder",
                              "Create 'bowtie_saves' subfolder",
                              value = TRUE),

                uiOutput("folder_status"),

                div(class = "d-grid gap-2 d-md-flex mt-3",
                  actionButton("verify_folder",
                               "Verify",
                               icon = icon("check-circle"),
                               class = "btn-info btn-sm"),
                  actionButton("open_folder",
                               "Open",
                               icon = icon("external-link-alt"),
                               class = "btn-secondary btn-sm")
                )
              )
            ),

            div(class = "card",
              div(class = "card-header bg-light py-2",
                icon("file-archive"), " Saved Files"
              ),
              div(class = "card-body", style = "max-height: 150px; overflow-y: auto;",
                uiOutput("local_files_list")
              )
            )
          ),

          hr(),

          div(class = "card",
            div(class = "card-header bg-light py-2",
              icon("bolt"), " Quick Actions"
            ),
            div(class = "card-body",
              div(class = "d-grid gap-2",
                actionButton("local_quick_save",
                             "Quick Save",
                             icon = icon("save"),
                             class = "btn-success btn-sm"),
                actionButton("local_quick_load",
                             "Quick Load",
                             icon = icon("folder-open"),
                             class = "btn-primary btn-sm")
              )
            )
          ),

          # Hidden file input for loading
          fileInput("local_load_file_input",
                    label = NULL,
                    accept = c(".rds", ".json"),
                    width = "0px"),
          tags$style("#local_load_file_input { display: none; }")
        )
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

    # Login Module UI
    login_ui("login"),
    login_css(),

    # UI Components
    ui_components_css(),
    ui_components_js(),
    
    # Local Storage JavaScript handlers
    local_storage_js(),

    # Custom CSS for bs4Dash compatibility
    tags$head(
      tags$style(HTML("
        /* Custom styling for bs4Dash */
        .content-wrapper {
          background-color: #f4f6f9;
        }

        /* ============================================= */
        /* HEADER WIDGET VERTICAL ALIGNMENT FIXES       */
        /* ============================================= */

        /* Main header navbar alignment */
        .main-header .navbar-nav {
          display: flex;
          align-items: center;
          height: 100%;
        }

        .main-header .navbar-nav > li {
          display: flex;
          align-items: center;
        }

        .main-header .navbar-nav > li > a {
          display: flex;
          align-items: center;
          height: 100%;
          padding: 0 0.75rem;
        }

        /* Dropdown menu items alignment */
        .main-header .dropdown-menu .dropdown-item,
        .main-header .dropdown-menu a {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 0.5rem 1rem;
        }

        /* Icon alignment in dropdown items */
        .main-header .dropdown-menu .dropdown-item i,
        .main-header .dropdown-menu a i,
        .main-header .dropdown-menu .fa,
        .main-header .dropdown-menu .fas,
        .main-header .dropdown-menu .far {
          min-width: 20px;
          text-align: center;
          display: inline-flex;
          align-items: center;
          justify-content: center;
        }

        /* Message item improvements for help dropdown */
        .dropdown-menu .media {
          display: flex;
          align-items: flex-start;
          padding: 0.5rem;
        }

        .dropdown-menu .media .media-body {
          flex: 1;
          min-width: 0;
        }

        .dropdown-menu .media img,
        .dropdown-menu .media .img-size-50 {
          flex-shrink: 0;
        }

        /* Navbar brand vertical alignment */
        .navbar-brand {
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .navbar-brand img {
          vertical-align: middle;
        }

        /* Badge alignment in navbar */
        .main-header .navbar-badge {
          position: absolute;
          top: 5px;
          right: 3px;
          font-size: 0.6rem;
          padding: 2px 4px;
        }

        /* Controlbar icon alignment */
        .main-header [data-widget='control-sidebar'] {
          display: flex;
          align-items: center;
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

      # DASHBOARD TAB
      tabItem(
        tabName = "dashboard",
        get_dashboard_tab_content()
      ),

      # DATA UPLOAD TAB
      tabItem(
        tabName = "upload",
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

      # CUSTOM TERMS REVIEW TAB (Admin Only)
      tabItem(
        tabName = "custom_terms",
        uiOutput("custom_terms_content")
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
