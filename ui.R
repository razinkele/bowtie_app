# UI Definition for Environmental Bowtie Risk Analysis Application
# =============================================================================

ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(version = 5, bootswatch = "zephyr"),

  # Skip navigation links for accessibility
  skip_links(),

  # ARIA live region for accessibility announcements
  div(id = "main-content",
      `aria-live` = "polite",
      `aria-atomic` = "true",
      class = "visually-hidden",
      uiOutput("notification_announcer")),

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

  # UI Components CSS and JS
  ui_components_css(),
  ui_components_js(),

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
                   # PNG Image - marbefes.png logo from www/img/ folder
                   img(src = "img/marbefes.png", class = "app-title-image", alt = "Marbefes Logo",
                       onerror = "this.style.display='none'",
                       title = "Marbefes Environmental Bowtie Risk Analysis"),
                   h4(uiOutput("app_title_text", inline = TRUE), class = "mb-0 text-primary d-inline-block me-3"),
                   span(class = "badge bg-success me-2 version-badge", paste0("v", APP_CONFIG$VERSION)),
                   span(class = "text-muted small", uiOutput("app_subtitle_text", inline = TRUE))
                 ),
                # Language selector
               ),
               actionButton("toggleTheme", label = NULL, icon = icon("gear"),
                           class = "btn-sm btn-outline-secondary",
                           title = "Settings",
                           `aria-label` = "Open settings panel")
             ),
             card_body(
               id = "themePanel", class = "collapse",
               fluidRow(
                 column(12,
                   uiOutput("settings_language_section"),
                   hr(),
                   uiOutput("settings_theme_header")
                 )
               ),
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
                       "Select 'Custom Colors' for complete color control."),
                     br(),
                     div(class = "d-grid",
                       actionButton("applyTheme",
                                  tagList(icon("palette"), "Apply Theme"),
                                  class = "btn-primary btn-sm"))
                   )
                 )),
                 # Apply button for custom themes
                 column(12, conditionalPanel(
                   condition = "input.theme_preset == 'custom'",
                   div(class = "text-center mt-3",
                     actionButton("applyCustomTheme",
                                tagList(icon("palette"), "Apply Custom Theme"),
                                class = "btn-success"))
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
      title = uiOutput("tab_data_input_title", inline = TRUE), value = "upload",

      fluidRow(
        column(12,
               card(
                 card_header(uiOutput("data_input_options_header", inline = TRUE), class = "bg-primary text-white"),
                 card_body(
                   fluidRow(
                     # Left column - File upload
                     column(6,
                       h6(uiOutput("data_upload_option1_title", inline = TRUE)),
                       uiOutput("file_input_ui"),
                       conditionalPanel(
                         condition = "output.fileUploaded",
                         selectInput("sheet", "Select Sheet:", choices = NULL),
                         div(class = "d-grid", actionButton("loadData", tagList(icon("upload"), "Load Data"),
                                                           class = "btn-primary"))
                       )
                     ),

                     # Right column - Generate from vocabulary
                     column(6,
                       div(style = "min-height: 150px;",
                         uiOutput("data_upload_option2_title"),
                         uiOutput("data_option2_desc")
                       ),
                       div(class = "mb-3",
                         selectInput("data_scenario_template", "Select environmental scenario:",
                                     choices = getEnvironmentalScenarioChoices(include_blank = TRUE),
                                     selected = "")
                       ),
                       div(class = "d-grid", actionButton("generateMultipleControls",
                                                         tagList(icon("seedling"), "Generate Data"),
                                                         class = "btn-success")),
                       conditionalPanel(
                         condition = "output.envDataGenerated",
                         div(class = "d-grid mt-2", downloadButton("downloadSample",
                                                             tagList(icon("download"), "Download"),
                                                             class = "btn-success"))
                       )
                     )
                   )
                 )
               )
        )
      ),
      
      br(),

      fluidRow(
        column(4,
               card(
                 card_header(uiOutput("data_structure_header"), class = "bg-info text-white"),
                 card_body(
                   uiOutput("bowtie_elements_section"),
                   div(class = "alert alert-success mt-2 mb-0 py-2",
                       tags$small(
                         tagList(icon("check-circle"), " "),
                         strong("Structure:"),
                         br(),
                         "Activity → Pressure → ",
                         tags$span(class = "badge bg-success", "Control"),
                         " → Central Problem",
                         br(),
                         tags$span(class = "badge bg-warning", "Escalation"),
                         " weakens Controls & Mitigations",
                         br(),
                         "Central Problem → ",
                         tags$span(class = "badge bg-info", "Mitigation"),
                         " → Consequence"
                       ))
                 )
               )
        ),

        column(4,
               card(
                 card_header(tagList(icon("database"), "Vocabulary Statistics"), class = "bg-success text-white"),
                 card_body(
                   h6(tagList(icon("layer-group"), "Available Elements"), class = "text-center mb-3"),
                   div(class = "row text-center",
                       div(class = "col-6 mb-3",
                           div(class = "p-2 border rounded",
                               div(class = "display-6 text-primary", textOutput("vocab_activities_count", inline = TRUE)),
                               div(class = "small text-muted", tagList(icon("play"), " Activities"))
                           )
                       ),
                       div(class = "col-6 mb-3",
                           div(class = "p-2 border rounded",
                               div(class = "display-6 text-danger", textOutput("vocab_pressures_count", inline = TRUE)),
                               div(class = "small text-muted", tagList(icon("triangle-exclamation"), " Pressures"))
                           )
                       ),
                       div(class = "col-6 mb-3",
                           div(class = "p-2 border rounded",
                               div(class = "display-6 text-success", textOutput("vocab_controls_count", inline = TRUE)),
                               div(class = "small text-muted", tagList(icon("shield-halved"), " Controls"))
                           )
                       ),
                       div(class = "col-6 mb-3",
                           div(class = "p-2 border rounded",
                               div(class = "display-6 text-warning", textOutput("vocab_consequences_count", inline = TRUE)),
                               div(class = "small text-muted", tagList(icon("burst"), " Consequences"))
                           )
                       )
                   ),
                   div(class = "alert alert-info mt-2 mb-0 py-2",
                       tags$small(
                         tagList(icon("info-circle"), " "),
                         strong("Total Elements: "),
                         textOutput("vocab_total_count", inline = TRUE)
                       )
                   )
                 )
               )
        ),

        column(4,
               conditionalPanel(
                 condition = "output.dataLoaded",
                 card(
                   card_header(tagList(icon("chart-bar"), "Data Summary"), class = "bg-secondary text-white"),
                   card_body(class = "py-2",
                     verbatimTextOutput("dataInfo")
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
                        class = "btn-primary",
                        onclick = "$('a[data-value=\"upload\"]').tab('show'); $('#loadData').focus();"),
            actionButton("empty_generate", "Generate Sample",
                        icon = icon("seedling"),
                        class = "btn-secondary",
                        onclick = "$('a[data-value=\"upload\"]').tab('show'); $('#generateSample').focus();")
          )
        )
      ),

      # Data preview when data is loaded
      conditionalPanel(
        condition = "output.dataLoaded",
        br(),
        card(
          card_header(tagList(icon("eye"), "Data Preview"), class = "bg-success text-white"),
          card_body(
            withSpinner(DT::dataTableOutput("preview")),
            br(),
            div(class = "alert alert-info mb-0", tagList(icon("info-circle"), " "),
                textOutput("debugInfo", inline = TRUE))
          )
        )
      )
    ),

    # Guided Workflow Tab
    nav_panel(
      title = uiOutput("tab_guided_creation_title", inline = TRUE),
      icon = icon("magic"),
      value = "guided_workflow",
      guided_workflow_ui("guided_workflow")
    ),

    # Enhanced Bowtie Visualization Tab
    nav_panel(
      title = tagList(icon("project-diagram"), "Bowtie Diagram"), value = "bowtie",

      # Toggle controls panel button
      div(class = "mb-3",
          actionButton("toggleControls",
                      tagList(icon("chevron-left"), "Hide Controls"),
                      class = "btn-outline-secondary btn-sm")),

      fluidRow(
        # Controls panel
        column(width = 4, id = "controlsPanel",
               card(
               card_header(tagList(icon("cogs"), "Bowtie Controls"), class = "bg-primary text-white"),
               card_body(
                 conditionalPanel(
                   condition = "output.dataLoaded",
                   selectInput("selectedProblem", "Select Central Problem:", choices = NULL),

                   hr(),
                   h6(tagList(icon("edit"), "Diagram Editing:")),
                   checkboxInput("editMode", "Enable Diagram Editing", value = FALSE),
                   conditionalPanel(
                     condition = "input.editMode",
                     div(class = "alert alert-warning small",
                         tagList(icon("exclamation-triangle"), " "),
                         "Use the editing toolbar in the diagram.")
                   ),

                   hr(),
                   h6(tagList(icon("eye"), "Display Options:")),
                   checkboxInput("showBarriers", "Show Controls & Mitigation", value = TRUE),
                   checkboxInput("showRiskLevels", "Color by Risk Level", value = TRUE),
                   sliderInput("nodeSize", "Element Size:", min = 25, max = 80, value = 45),

                   hr(),
                   h6(tagList(icon("plus"), "Quick Add:")),
                   textInput("newActivity", "New Activity:", placeholder = "Enter activity description"),
                   textInput("newPressure", "New Pressure:", placeholder = "Enter pressure/threat"),
                   textInput("newConsequence", "New Consequence:", placeholder = "Enter consequence"),
                   div(class = "d-grid", actionButton("addActivityChain",
                                                     tagList(icon("plus-circle"), "Add Chain"),
                                                     class = "btn-outline-primary btn-sm")),

                   hr(),
                   h6(tagList(icon("palette"), "Bowtie Visual Legend:")),
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
                           strong("✓ Enhanced:"), " With Bayesian network conversion"),
                       div(class = "small text-muted",
                           strong("Flow:"), " Activity → Pressure → Control → Escalation → Central Problem → Mitigation → Consequence"),
                       div(class = "small text-muted",
                           strong("Line Types:"), " Solid = causal flow, Dashed = intervention/control effects"),
                       div(class = "small text-info mt-1",
                           strong("PNG Support:"), " Add marbefes.png to www/ folder for custom branding")
                   ),

                   hr(),
                   h6(tagList(icon("download"), "Export Diagram:")),
                   div(class = "d-grid gap-2",
                       downloadButton("downloadBowtie",
                                     tagList(icon("file-code"), "HTML (Interactive)"),
                                     class = "btn-success btn-sm"),
                       downloadButton("downloadBowtieJPEG",
                                     tagList(icon("image"), "JPEG (White Background)"),
                                     class = "btn-info btn-sm"),
                       downloadButton("downloadBowtiePNG",
                                     tagList(icon("image"), "PNG (Transparent)"),
                                     class = "btn-secondary btn-sm")
                   )
                 )
               )
             )
        ),

        # Diagram panel with flexible width
        column(width = 8, id = "diagramPanel",
             card(
               card_header(
                 tagList(
                   icon("sitemap"), "Bowtie Diagram",
                   tags$span(
                     class = "float-end",
                     actionButton("bowtie_help", "", icon = icon("question-circle"),
                                class = "btn-sm btn-link text-white",
                                style = "padding: 0; text-decoration: none;",
                                title = "Click for diagram legend and help",
                                `aria-label` = "Show bowtie diagram legend and help")
                   )
                 ),
                 class = "bg-success text-white"
               ),
               card_body(
                 # Help panel (hidden by default)
                 conditionalPanel(
                   condition = "input.bowtie_help % 2 == 1",
                   div(class = "alert alert-info mb-3",
                     # Rendered in server.R as uiOutput("bowtie_legend_help")
                     tags$small(
                       tags$ul(class = "mb-2",
                         tags$li(tags$strong("Purple rectangles:"), " Activities - human actions causing environmental pressures"),
                         tags$li(tags$strong("Red ovals:"), " Pressures - environmental stressors resulting from activities"),
                         tags$li(tags$strong("Green rectangles:"), " Preventive Controls - measures to stop pressures reaching the central problem"),
                         tags$li(tags$strong("Orange triangles:"), " Escalation Factors - conditions that weaken both preventive controls AND protective mitigations"),
                         tags$li(tags$strong("Red diamond (center):"), " Central Problem - the main environmental issue being assessed"),
                         tags$li(tags$strong("Blue squares:"), " Protective Mitigations - measures to reduce consequences after the problem occurs"),
                         tags$li(tags$strong("Orange ovals:"), " Consequences - environmental impacts resulting from the central problem")
                       ),
                       tags$p(class = "mb-0",
                         tags$strong("Interaction:"), " Hover over elements for details. Click and drag to reposition elements. Use mouse wheel to zoom. Double-click elements for more information."
                       )
                     )
                   )
                 ),
                 conditionalPanel(
                   condition = "output.dataLoaded",
                   div(class = "network-container",
                       withSpinner(visNetworkOutput("bowtieNetwork", height = "650px"))
                   )
                 ),
                 conditionalPanel(
                   condition = "!output.dataLoaded",
                   empty_state_network(
                     message = "Upload environmental data or generate sample data to view the bowtie diagram.",
                     action_buttons = div(class = "d-flex gap-2 justify-content-center mt-3",
                       actionButton("bowtie_upload", "Upload Data",
                                   icon = icon("upload"),
                                   class = "btn-primary",
                                   onclick = "$('a[data-value=\"upload\"]').tab('show'); $('#loadData').focus();"),
                       actionButton("bowtie_generate", "Generate Sample",
                                   icon = icon("seedling"),
                                   class = "btn-secondary",
                                   onclick = "$('a[data-value=\"upload\"]').tab('show'); $('#generateSample').focus();")
                     )
                   )
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
                     empty_state(
                       icon_name = "brain",
                       title = "Load Data First",
                       message = "Upload or generate environmental data to access Bayesian network analysis.",
                       primary_action = actionButton("bayesian_upload", "Upload Data",
                                                    icon = icon("upload"),
                                                    class = "btn-primary",
                                                    onclick = "$('a[data-value=\"upload\"]').tab('show'); $('#loadData').focus();")
                     )
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
                              empty_state_network(
                                icon_name = "brain",
                                message = "Click 'Create Bayesian Network' above to convert your bowtie data into a probabilistic model for advanced risk analysis."
                              )
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
      title = tagList(icon("table"), "Data Table"), value = "table",

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
                     div(class = "alert alert-success",
                         tagList(icon("check-circle"), " "),
                         "✓ ENHANCED: Click on any cell to edit. Data ready for Bayesian network conversion."),
                     withSpinner(DT::dataTableOutput("editableTable"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     div(class = "text-center p-5",
                         icon("table", class = "fa-3x text-muted mb-3"),
                         h4("No Data Available", class = "text-muted"),
                         p("Please upload data or generate sample data", class = "text-muted"))
                   )
                 )
               )
        )
      )
    ),

    # Enhanced Risk Matrix Tab
    nav_panel(
      title = tagList(icon("chart-line"), "Risk Matrix"), value = "matrix",

      fluidRow(
        column(8,
               card(
                 card_header(
                   tagList(
                     icon("chart-line"), "Environmental Risk Matrix",
                     tags$span(
                       class = "float-end",
                       actionButton("matrix_help", "", icon = icon("question-circle"),
                                  class = "btn-sm btn-link text-white",
                                  style = "padding: 0; text-decoration: none;",
                                  title = "Click for risk matrix guide and interpretation")
                     )
                   ),
                   class = "bg-primary text-white"
                 ),
                 card_body(
                   # Help panel (hidden by default)
                   conditionalPanel(
                     condition = "input.matrix_help % 2 == 1",
                     div(class = "alert alert-info mb-3",
                       h6(tagList(icon("info-circle"), "Risk Matrix Guide & Interpretation")),
                       tags$small(
                         tags$p(tags$strong("Understanding the Graph:")),
                         tags$ul(class = "mb-2",
                           tags$li(tags$strong("X-Axis (Horizontal):"), " Likelihood - How likely is this risk to occur? (1 = Very Unlikely, 2 = Unlikely, 3 = Possible, 4 = Likely, 5 = Very Likely)"),
                           tags$li(tags$strong("Y-Axis (Vertical):"), " Severity - How serious would the impact be? (1 = Negligible, 2 = Minor, 3 = Moderate, 4 = Major, 5 = Catastrophic)"),
                           tags$li(tags$strong("Each Dot:"), " Represents ONE complete risk pathway: Activity → Pressure → Central Problem → Consequence. Multiple dots = multiple different risk scenarios being assessed.")
                         ),
                         tags$p(tags$strong("Why Multiple Dots?")),
                         tags$p("Your bowtie diagram contains multiple pathways. For example: 'Shipping operations causing oil spills leading to marine ecosystem damage' is one dot, while 'Agricultural runoff causing nutrient pollution leading to eutrophication' is another dot. Each pathway is assessed separately for its likelihood and severity."),
                         tags$p(tags$strong("Color-Coded Risk Levels:")),
                         tags$ul(class = "mb-2",
                           tags$li(tags$strong("🟢 Green dots:"), " Low risk (score 1-6) - minimal concern, routine monitoring"),
                           tags$li(tags$strong("🟡 Yellow/Orange dots:"), " Medium risk (score 7-15) - moderate concern, targeted controls needed"),
                           tags$li(tags$strong("🔴 Red dots:"), " High risk (score 16-25) - critical concern, urgent action required")
                         ),
                         tags$p(tags$strong("Risk Score:"), " Calculated as Likelihood × Severity. A dot at position (4, 5) has a risk score of 20 (High Risk)."),
                         tags$p(class = "mb-0",
                           tags$strong("How to use:"), " Hover over any dot to see the complete pathway details. Prioritize resources on high-risk (red) items first. The top-right corner (5,5) represents the most critical risks requiring immediate attention."
                         )
                       )
                     )
                   ),
                   conditionalPanel(
                     condition = "output.dataLoaded",
                     withSpinner(plotlyOutput("riskMatrix", height = "500px"))
                   ),
                   conditionalPanel(
                     condition = "!output.dataLoaded",
                     empty_state(
                       icon_name = "chart-line",
                       title = "No Risk Matrix Data",
                       message = "Upload environmental data or generate sample data to view the risk matrix visualization.",
                       primary_action = actionButton("matrix_upload", "Upload Data",
                                                    icon = icon("upload"),
                                                    class = "btn-primary",
                                                    onclick = "$('a[data-value=\"upload\"]').tab('show'); $('#loadData').focus();"),
                       secondary_action = actionButton("matrix_generate", "Generate Sample",
                                                      icon = icon("seedling"),
                                                      class = "btn-secondary",
                                                      onclick = "$('a[data-value=\"upload\"]').tab('show'); $('#generateSample').focus();")
                     )
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
    ),

    # Link Risk Assessment Tab - NEW
    nav_panel(
      title = uiOutput("tab_link_risk_title", inline = TRUE), value = "link_risk",

      fluidRow(
        column(12,
          card(
            card_header(uiOutput("link_risk_individual_header"), class = "bg-info text-white"),
            card_body(
              conditionalPanel(
                condition = "output.dataLoaded",
                
                fluidRow(
                  column(12,
                    div(class = "alert alert-info",
                      icon("info-circle"),
                      strong(" Instructions: "),
                      "Select a scenario pathway below to review and adjust the likelihood and severity of each connection in the bowtie structure."
                    )
                  )
                ),
                
                fluidRow(
                  column(4,
                    card(
                      card_header("Select Pathway", class = "bg-secondary text-white"),
                      card_body(
                        selectInput("link_risk_scenario", "Select Scenario:",
                                  choices = NULL,
                                  selected = NULL),
                        hr(),
                        div(id = "scenario_info",
                          uiOutput("selected_scenario_info")
                        )
                      )
                    )
                  ),
                  
                  column(8,
                    card(
                      card_header("Connection Risk Assessments", class = "bg-primary text-white"),
                      card_body(
                        # Activity → Pressure
                        h5(tagList(icon("arrow-right"), "Activity → Pressure")),
                        fluidRow(
                          column(6,
                            sliderInput("activity_pressure_likelihood",
                                      "Likelihood (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          ),
                          column(6,
                            sliderInput("activity_pressure_severity",
                                      "Severity (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          )
                        ),
                        div(class = "small text-muted mb-3",
                          uiOutput("activity_pressure_description")
                        ),
                        
                        hr(),
                        
                        # Pressure → Preventive Control
                        h5(tagList(icon("arrow-right"), "Pressure → Preventive Control")),
                        fluidRow(
                          column(6,
                            sliderInput("pressure_control_likelihood",
                                      "Likelihood (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          ),
                          column(6,
                            sliderInput("pressure_control_severity",
                                      "Severity (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          )
                        ),
                        div(class = "small text-muted mb-3",
                          uiOutput("pressure_control_description")
                        ),
                        
                        hr(),
                        
                        # Escalation Factor → Control
                        h5(tagList(icon("arrow-right"), "Escalation Factor → Control")),
                        fluidRow(
                          column(6,
                            sliderInput("escalation_control_likelihood",
                                      "Likelihood (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          ),
                          column(6,
                            sliderInput("escalation_control_severity",
                                      "Severity (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          )
                        ),
                        div(class = "small text-muted mb-3",
                          uiOutput("escalation_control_description")
                        ),
                        
                        hr(),
                        
                        # Central Problem → Consequence
                        h5(tagList(icon("arrow-right"), "Central Problem → Consequence")),
                        fluidRow(
                          column(6,
                            sliderInput("central_consequence_likelihood",
                                      "Likelihood (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          ),
                          column(6,
                            sliderInput("central_consequence_severity",
                                      "Severity (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          )
                        ),
                        div(class = "small text-muted mb-3",
                          uiOutput("central_consequence_description")
                        ),
                        
                        hr(),
                        
                        # Protective Control → Consequence
                        h5(tagList(icon("arrow-right"), "Protective Control → Consequence")),
                        fluidRow(
                          column(6,
                            sliderInput("protection_consequence_likelihood",
                                      "Likelihood (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          ),
                          column(6,
                            sliderInput("protection_consequence_severity",
                                      "Severity (1-5):",
                                      min = 1, max = 5, value = 3, step = 1)
                          )
                        ),
                        div(class = "small text-muted mb-3",
                          uiOutput("protection_consequence_description")
                        ),
                        
                        hr(),
                        
                        div(class = "d-grid gap-2 mt-4",
                          actionButton("save_link_risks",
                                     tagList(icon("save"), "Save Risk Assessments"),
                                     class = "btn-success btn-lg"),
                          actionButton("reset_link_risks",
                                     tagList(icon("undo"), "Reset to Current Values"),
                                     class = "btn-outline-secondary")
                        ),
                        
                        # Overall Risk Summary
                        div(class = "mt-4",
                          card(
                            card_header("Overall Pathway Risk", class = "bg-dark text-white"),
                            card_body(
                              uiOutput("overall_pathway_risk")
                            )
                          )
                        )
                      )
                    )
                  )
                )
              ),
              
              conditionalPanel(
                condition = "!output.dataLoaded",
                div(class = "text-center p-5",
                  icon("exclamation-triangle", class = "fa-3x text-warning mb-3"),
                  h4("No Data Loaded"),
                  p("Please upload or generate bowtie data to use the Link Risk Assessment tool.", class = "text-muted")
                )
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
                                empty_state_search(
                                  message = "Use the search controls above to find vocabulary items by keyword, category, or type."
                                )
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

    # Report Generation Tab
    nav_panel(
      title = tagList(icon("file-alt"), "Report"), value = "report",

      fluidRow(
        column(6,
               card(
                 card_header(uiOutput("report_header"), class = "bg-primary text-white"),
                 card_body(
                   uiOutput("report_intro"),
                   
                   hr(),
                   
                   h5(tagList(icon("cog"), uiOutput("report_options_title", inline = TRUE))),
                   
                   uiOutput("report_type_label"),
                   selectInput("report_type", NULL,
                             choices = c(
                               "Summary Report" = "summary",
                               "Detailed Analysis" = "detailed",
                               "Risk Matrix Report" = "risk_matrix",
                               "Bayesian Analysis Report" = "bayesian",
                               "Complete Report (All Sections)" = "complete"
                             ),
                             selected = "summary"),
                   
                   uiOutput("report_format_label"),
                   radioButtons("report_format", NULL,
                              choices = c("PDF" = "pdf", "HTML" = "html", "Word" = "docx"),
                              selected = "html", inline = TRUE),
                   
                   hr(),
                   
                   uiOutput("report_include_sections_label"),
                   checkboxGroupInput("report_sections", NULL,
                                    choices = c(
                                      "Executive Summary" = "exec_summary",
                                      "Data Overview" = "data_overview",
                                      "Bowtie Diagrams" = "bowtie_diagrams",
                                      "Risk Matrix" = "risk_matrix_section",
                                      "Bayesian Network Analysis" = "bayesian_section",
                                      "Recommendations" = "recommendations"
                                    ),
                                    selected = c("exec_summary", "data_overview", "bowtie_diagrams")),
                   
                   hr(),
                   
                   uiOutput("report_title_input_ui"),
                   uiOutput("report_author_input_ui"),
                   
                   hr(),
                   
                   div(class = "d-grid gap-2",
                       actionButton("generate_report",
                                  tagList(icon("file-export"), uiOutput("report_generate_button", inline = TRUE)),
                                  class = "btn-success btn-lg"),
                       downloadButton("download_report",
                                    tagList(icon("download"), uiOutput("report_download_button", inline = TRUE)),
                                    class = "btn-primary")
                   )
                 )
               )
        ),
        
        column(6,
               card(
                 card_header(uiOutput("report_preview_header"), class = "bg-info text-white"),
                 card_body(
                   uiOutput("report_status"),
                   hr(),
                   uiOutput("report_preview_content")
                 )
               ),
               
               card(
                 card_header(uiOutput("report_help_header"), class = "bg-secondary text-white"),
                 card_body(
                   uiOutput("report_help_content")
                 )
               )
        )
      )
    ),

    # Help Tab with organized sub-tabs
    nav_panel(
      title = tagList(icon("question-circle"), "Help"), value = "help",

      # Sub-navigation for help topics
      navset_tab(
        id = "help_tabs",

        # Guided Workflow Tab
        nav_panel(
          title = tagList(icon("magic"), "Guided Workflow"), value = "workflow_help",

          fluidRow(
            column(12,
              card(
                card_header(
                  tagList(icon("magic"), "🧙 Guided Workflow System"),
                  class = "bg-success text-white"
                ),
                card_body(
                  div(class = "alert alert-success",
                      tagList(icon("star"), " "),
                      strong("Step-by-Step Bowtie Creation Wizard")
                  ),

                  h5(tagList(icon("route"), "How to Use the Guided Workflow:")),
                  tags$ol(
                    tags$li(strong("Click the "), code("🧙 Guided Creation"), strong(" tab")),
                    tags$li(strong("Choose your approach:"),
                      tags$ul(
                        tags$li("Select a pre-built template (Marine, Climate, Biodiversity)"),
                        tags$li("Start from scratch with custom project")
                      )
                    ),
                    tags$li(strong("Follow the 8-step process:"),
                      tags$ul(class = "mt-2",
                        tags$li("📋 Project Setup - Define your assessment"),
                        tags$li("🎯 Central Problem - Identify the main environmental issue"),
                        tags$li("⚠️ Threats & Causes - Map activities and pressures"),
                        tags$li("🛡️ Preventive Controls - Add proactive measures"),
                        tags$li("💥 Consequences - Identify potential impacts"),
                        tags$li("🚨 Protective Controls - Add reactive measures"),
                        tags$li("✅ Review & Validate - Check completeness"),
                        tags$li("🎉 Finalize & Export - Generate professional reports")
                      )
                    ),
                    tags$li(strong("Track Progress:"), " Visual progress bar shows completion status"),
                    tags$li(strong("Get Expert Guidance:"), " Built-in tips and examples at each step"),
                    tags$li(strong("Professional Output:"), " Export to Excel, PDF, or other formats")
                  ),

                  div(class = "alert alert-info mt-3",
                      tagList(icon("clock"), " "),
                      strong("Estimated Time: "), "25-35 minutes for complete assessment"
                  ),

                  h5(tagList(icon("lightbulb"), "Benefits of Guided Workflow:")),
                  tags$ul(
                    tags$li(strong("Structured Approach:"), " Ensures complete and consistent assessments"),
                    tags$li(strong("Expert Knowledge:"), " Built-in environmental risk expertise"),
                    tags$li(strong("Quality Assurance:"), " Validation checks prevent incomplete work"),
                    tags$li(strong("Time Efficient:"), " Faster than manual bowtie creation"),
                    tags$li(strong("Professional Results:"), " Export-ready for stakeholders")
                  ),

                  div(class = "alert alert-warning",
                      tagList(icon("info-circle"), " "),
                      strong("Tip: "), "New users should start with the ",
                      code("🧙 Guided Creation"), " tab, while experienced users can use the ",
                      code("📤 Data Upload"), " tab for direct data import."
                  )
                )
              )
            )
          )
        ),

        # Risk Matrix Tab
        nav_panel(
          title = tagList(icon("chart-line"), "Risk Matrix"), value = "risk_matrix_help",

          fluidRow(
            column(12,
              card(
                card_header(
                  tagList(icon("chart-line"), "Risk Matrix Methodology"),
                  class = "bg-warning text-dark"
                ),
                card_body(
                  div(class = "alert alert-info mb-3",
                    tagList(icon("info-circle"), " "),
                    p(class = "mb-0", "The application uses a quantitative risk matrix approach combining likelihood and severity assessments for systematic environmental risk evaluation. This method transforms subjective risk perceptions into objective, comparable numerical scores that support evidence-based decision making.")
                  ),

                  h6(tagList(icon("question-circle"), "Why Use Risk Matrices?")),
                  div(class = "row mb-3",
                    div(class = "col-md-6",
                      h6(class = "text-success", "✓ Advantages:"),
                      tags$ul(class = "small",
                        tags$li("Standardizes risk assessment across different environmental domains"),
                        tags$li("Enables quantitative comparison of diverse risks (e.g., chemical vs. physical vs. biological)"),
                        tags$li("Supports prioritization and resource allocation decisions"),
                        tags$li("Facilitates risk communication to non-technical stakeholders"),
                        tags$li("Provides audit trail for regulatory compliance"),
                        tags$li("Enables trend analysis and performance monitoring over time")
                      )
                    ),
                    div(class = "col-md-6",
                      h6(class = "text-warning", "⚠️ Limitations to Consider:"),
                      tags$ul(class = "small",
                        tags$li("Discretization may obscure important distinctions near category boundaries"),
                        tags$li("Assumes independence between likelihood and consequence (may not hold for all environmental systems)"),
                        tags$li("Risk aggregation across different impact types requires careful weighting"),
                        tags$li("Qualitative scales can introduce assessor bias despite quantitative scoring"),
                        tags$li("May oversimplify complex, dynamic environmental systems")
                      )
                    )
                  ),

                  h6(tagList(icon("calculator"), "Risk Calculation Formula:")),
                  div(class = "alert alert-light border",
                    div(class = "text-center mb-3",
                      tags$code("Risk Score = Threat Likelihood × Consequence Severity", class = "fs-5"),
                      br(), br(),
                      tags$code("Risk Level = f(Risk Score)", class = "fs-6")
                    )
                  ),

                  h6("Risk Level Classification:"),
                  tags$ul(
                    tags$li(strong("Low Risk:"), " Score ≤ 6 (Green) - Minimal impact, routine monitoring"),
                    tags$li(strong("Medium Risk:"), " Score 7-15 (Yellow) - Moderate impact, active management required"),
                    tags$li(strong("High Risk:"), " Score 16-20 (Orange) - Significant impact, priority intervention"),
                    tags$li(strong("Very High Risk:"), " Score > 20 (Red) - Critical impact, immediate action required")
                  ),

                  div(class = "row mt-4",
                    div(class = "col-md-6",
                      h6("Likelihood Scale (1-5):"),
                      div(class = "card border-primary",
                        div(class = "card-body p-2",
                          tags$ul(class = "small mb-0",
                            tags$li(strong("1 - Rare:"), " < 1% annual probability", br(),
                                   em("Example: Major oil spill in well-regulated waters")),
                            tags$li(strong("2 - Unlikely:"), " 1-10% annual probability", br(),
                                   em("Example: Extreme weather event beyond historical range")),
                            tags$li(strong("3 - Possible:"), " 11-50% annual probability", br(),
                                   em("Example: Moderate pollution incident from industrial operations")),
                            tags$li(strong("4 - Likely:"), " 51-90% annual probability", br(),
                                   em("Example: Seasonal algal bloom in nutrient-enriched waters")),
                            tags$li(strong("5 - Almost Certain:"), " > 90% annual probability", br(),
                                   em("Example: Continued habitat loss in high-development areas"))
                          )
                        )
                      )
                    ),
                    div(class = "col-md-6",
                      h6("Severity Scale (1-5):"),
                      div(class = "card border-danger",
                        div(class = "card-body p-2",
                          tags$ul(class = "small mb-0",
                            tags$li(strong("1 - Negligible:"), " Minor environmental impact", br(),
                                   em("Example: Temporary aesthetic impact, full recovery < 1 month")),
                            tags$li(strong("2 - Minor:"), " Localized, reversible impact", br(),
                                   em("Example: Local water quality degradation, recovery 1-12 months")),
                            tags$li(strong("3 - Moderate:"), " Regional impact, some irreversibility", br(),
                                   em("Example: Regional species population decline, recovery 1-10 years")),
                            tags$li(strong("4 - Major:"), " Widespread impact, significant irreversibility", br(),
                                   em("Example: Ecosystem state change, recovery 10-50 years or uncertain")),
                            tags$li(strong("5 - Catastrophic:"), " Permanent, large-scale environmental damage", br(),
                                   em("Example: Species extinction, irreversible ecosystem collapse"))
                          )
                        )
                      )
                    )
                  ),

                  h6(tagList(icon("calculator"), "Risk Matrix Interpretation Guide:")),
                  div(class = "alert alert-light border mb-3",
                    div(class = "row text-center small",
                      div(class = "col-3",
                          div(class = "badge bg-success p-2 w-100", "LOW RISK", br(), "(1-6)", br(), "Monitor")),
                      div(class = "col-3",
                          div(class = "badge bg-warning p-2 w-100", "MEDIUM RISK", br(), "(7-15)", br(), "Manage")),
                      div(class = "col-3",
                          div(class = "badge bg-orange p-2 w-100 text-white", "HIGH RISK", br(), "(16-20)", br(), "Priority")),
                      div(class = "col-3",
                          div(class = "badge bg-danger p-2 w-100", "CRITICAL RISK", br(), "(21-25)", br(), "Immediate"))
                    ),
                    hr(class = "my-2"),
                    div(class = "row small",
                      div(class = "col-6",
                        h6("Management Actions by Risk Level:"),
                        tags$ul(
                          tags$li(strong("Low (1-6):"), " Routine monitoring, standard controls adequate"),
                          tags$li(strong("Medium (7-15):"), " Active management required, enhanced monitoring, specific controls")
                        )
                      ),
                      div(class = "col-6 mt-4",
                        tags$ul(
                          tags$li(strong("High (16-20):"), " Priority intervention, additional resources, regular review"),
                          tags$li(strong("Critical (21-25):"), " Immediate action required, emergency response, senior management involvement")
                        )
                      )
                    )
                  ),

                  div(class = "alert alert-info mt-3",
                    tagList(icon("lightbulb"), " "),
                    strong("Practical Application: "), "Use the Risk Matrix tab to visualize risk levels, identify high-priority threats, and track risk reduction progress over time. The quantitative approach enables objective decision-making and supports regulatory reporting requirements."
                  ),

                  div(class = "alert alert-success mt-2",
                    tagList(icon("rocket"), " "),
                    strong("Integration with BowTie: "), "Risk matrix scores can be assigned to individual bowtie pathways (cause → central event → consequence chains), enabling quantitative comparison of different risk scenarios and prioritization of control measures for maximum risk reduction impact."
                  )
                )
              )
            )
          )
        ),

        # Bayesian Approach Tab
        nav_panel(
          title = tagList(icon("brain"), "Bayesian Approach"), value = "bayesian_help",

          fluidRow(
            column(12,
              card(
                card_header(
                  tagList(icon("brain"), "Bayesian Network Integration"),
                  class = "bg-primary text-white"
                ),
                card_body(
                  div(class = "alert alert-primary mb-3",
                    tagList(icon("brain"), " "),
                    p(class = "mb-0", "The application incorporates Bayesian Networks to model probabilistic relationships between bowtie elements, enabling advanced uncertainty quantification and scenario analysis. This cutting-edge approach transforms traditional deterministic risk assessment into a probabilistic framework that explicitly handles uncertainty and supports evidence-based decision making.")
                  ),

                  h6(tagList(icon("question-circle"), "Why Bayesian Networks for Environmental Risk?")),
                  div(class = "row mb-3",
                    div(class = "col-md-4",
                      div(class = "card border-info h-100",
                        div(class = "card-header bg-info text-white text-center", "🎲 Uncertainty Handling"),
                        div(class = "card-body small",
                          p("Environmental systems involve inherent uncertainty from natural variability, measurement limitations, and incomplete knowledge. Bayesian networks explicitly model these uncertainties as probability distributions rather than point estimates.")
                        )
                      )
                    ),
                    div(class = "col-md-4",
                      div(class = "card border-warning h-100",
                        div(class = "card-header bg-warning text-dark text-center", "🔗 Causal Relationships"),
                        div(class = "card-body small",
                          p("Environmental risks involve complex cause-effect relationships. Bayesian networks can model both direct causal links and indirect dependencies, capturing the true complexity of environmental systems.")
                        )
                      )
                    ),
                    div(class = "col-md-4",
                      div(class = "card border-success h-100",
                        div(class = "card-header bg-success text-white text-center", "📊 Learning from Data"),
                        div(class = "card-body small",
                          p("As new environmental data becomes available, Bayesian networks can update their probability estimates automatically, providing an adaptive framework that improves with experience.")
                        )
                      )
                    )
                  ),

                  h6(tagList(icon("network-wired"), "Network Structure:")),
                  div(class = "alert alert-info",
                    h6("Basic BowTie-to-Bayesian Mapping:"),
                    p(class = "mb-2", strong("Activities → Pressures → Central Problem → Consequences")),
                    p("With conditional probability distributions: ", tags$code("P(Effect | Cause)")),
                    hr(class = "my-2"),
                    h6("Enhanced Network Features:"),
                    tags$ul(class = "small mb-0",
                      tags$li(strong("Control Integration: "), "Preventive and protective controls modeled as intervening nodes that modify transmission probabilities"),
                      tags$li(strong("Interaction Effects: "), "Multiple pressures can interact synergistically, with joint probability distributions capturing combined effects"),
                      tags$li(strong("Temporal Dependencies: "), "Time-lagged relationships (e.g., long-term consequences) modeled through dynamic Bayesian networks"),
                      tags$li(strong("Uncertainty Nodes: "), "Explicit representation of measurement uncertainty, model uncertainty, and natural variability")
                    )
                  ),

                  h6(tagList(icon("lightbulb"), "Real-World Example - Marine Oil Spill:")),
                  div(class = "alert alert-light border mb-3",
                    div(class = "row small",
                      div(class = "col-md-6",
                        h6("Network Structure:"),
                        tags$ol(
                          tags$li(strong("Vessel Traffic Volume "), "(Activity node)"),
                          tags$li(strong("Navigation Hazards "), "(Pressure node)"),
                          tags$li(strong("Collision Risk "), "(Central problem)"),
                          tags$li(strong("Oil Release "), "(Immediate consequence)"),
                          tags$li(strong("Marine Ecosystem Impact "), "(Final consequence)")
                        )
                      ),
                      div(class = "col-md-6",
                        h6("Probabilistic Relationships:"),
                        tags$ul(
                          tags$li(tags$code("P(Navigation Hazards | Heavy Traffic) = 0.15")),
                          tags$li(tags$code("P(Collision | Hazards + No Controls) = 0.08")),
                          tags$li(tags$code("P(Collision | Hazards + GPS Systems) = 0.03")),
                          tags$li(tags$code("P(Oil Release | Collision) = 0.45")),
                          tags$li(tags$code("P(Severe Impact | Large Release + Sensitive Area) = 0.75"))
                        )
                      )
                    )
                  ),

                  h6("Key Bayesian Formulas:"),
                  div(class = "alert alert-light border",
                    h6("1. Conditional Probability:"),
                    tags$code("P(Consequence | Pressure) = P(Pressure | Consequence) × P(Consequence) / P(Pressure)", class = "d-block mb-2"),

                    h6("2. Joint Probability:"),
                    tags$code("P(A ∩ B ∩ C) = P(A) × P(B|A) × P(C|A,B)", class = "d-block mb-2"),

                    h6("3. Total Probability:"),
                    tags$code("P(Consequence) = Σ P(Consequence | Pressure_i) × P(Pressure_i)", class = "d-block mb-2"),

                    h6("4. Posterior Update (Bayes' Theorem):"),
                    tags$code("P(Cause | Evidence) = P(Evidence | Cause) × P(Cause) / P(Evidence)", class = "d-block")
                  ),

                  h6("Bayesian Network Applications:"),
                  tags$ul(
                    tags$li(strong("Scenario Analysis:"), " 'What-if' modeling with evidence propagation"),
                    tags$li(strong("Root Cause Analysis:"), " Backward inference to identify most probable causes"),
                    tags$li(strong("Risk Propagation:"), " Forward inference to predict downstream impacts"),
                    tags$li(strong("Uncertainty Quantification:"), " Confidence intervals for risk estimates"),
                    tags$li(strong("Sensitivity Analysis:"), " Identify critical control points")
                  ),

                  h6("Prior Distribution Assumptions:"),
                  div(class = "alert alert-secondary",
                    p(class = "small mb-2", "Prior distributions represent our initial beliefs about probabilities before observing specific data. These are based on expert knowledge, historical data, and environmental risk literature:"),
                    div(class = "row small",
                      div(class = "col-md-6",
                        tags$ul(
                          tags$li(strong("Activity occurrence: "), tags$code("Beta(α=2, β=3)"), br(),
                                 em("Rationale: Most human activities have moderate occurrence rates, with bias toward lower frequencies for high-impact activities")),
                          tags$li(strong("Pressure intensity: "), tags$code("Gamma(α=2, β=2)"), br(),
                                 em("Rationale: Environmental pressures can have heavy-tail distributions, allowing for rare but extreme events"))
                        )
                      ),
                      div(class = "col-md-6",
                        tags$ul(
                          tags$li(strong("Control effectiveness: "), tags$code("Beta(α=3, β=2)"), br(),
                                 em("Rationale: Controls are typically designed to be effective, but with some failure probability")),
                          tags$li(strong("Consequence severity: "), tags$code("Log-normal(μ=1, σ=0.5)"), br(),
                                 em("Rationale: Environmental consequences often follow log-normal distributions, with possibility of extreme impacts"))
                        )
                      )
                    ),
                    hr(class = "my-2"),
                    p(class = "small text-muted mb-0", strong("Important: "), "These priors are updated automatically as you input data specific to your environmental context, ensuring the analysis reflects your particular situation rather than generic assumptions.")
                  ),

                  h6(tagList(icon("cogs"), "Implementation Details:")),
                  tags$ul(
                    tags$li(strong("Structure Learning:"), " Automatic network structure inference from data using constraint-based algorithms"),
                    tags$li(strong("Parameter Learning:"), " Maximum likelihood estimation with Bayesian updating"),
                    tags$li(strong("Inference Engine:"), " Junction tree algorithm for efficient probabilistic queries"),
                    tags$li(strong("Model Validation:"), " Cross-validation and posterior predictive checks")
                  ),

                  div(class = "alert alert-success mt-3",
                    tagList(icon("lightbulb"), " "),
                    strong("Practical Benefits for Environmental Management:"),
                    div(class = "row mt-2",
                      div(class = "col-md-6",
                        tags$ul(class = "small",
                          tags$li(strong("Uncertainty Quantification: "), "Know not just the risk level, but how confident you can be in that estimate"),
                          tags$li(strong("Evidence-Based Decisions: "), "Make decisions based on probability distributions rather than single-point estimates"),
                          tags$li(strong("Scenario Planning: "), "Explore 'what-if' scenarios with quantified outcomes and confidence intervals"),
                          tags$li(strong("Adaptive Management: "), "Update risk assessments automatically as new monitoring data becomes available")
                        )
                      ),
                      div(class = "col-md-6",
                        tags$ul(class = "small",
                          tags$li(strong("Resource Optimization: "), "Prioritize monitoring and management actions based on probabilistic cost-benefit analysis"),
                          tags$li(strong("Stakeholder Communication: "), "Present risks with confidence intervals that stakeholders can understand and trust"),
                          tags$li(strong("Regulatory Support: "), "Provide robust, defendable risk assessments that meet scientific standards"),
                          tags$li(strong("Learning from Experience: "), "Build institutional knowledge as the network learns from each new case")
                        )
                      )
                    )
                  ),

                  div(class = "alert alert-info mt-2",
                    tagList(icon("graduation-cap"), " "),
                    strong("Learning Resources: "), "New to Bayesian networks? The application includes built-in tutorials and examples. Start with simple scenarios and gradually explore more complex probabilistic relationships as your confidence grows."
                  ),

                  div(class = "alert alert-warning mt-2",
                    tagList(icon("exclamation-triangle"), " "),
                    strong("Note: "), "Bayesian network functionality requires the 'bnlearn' and 'gRain' packages. ",
                    "If not available, the system falls back to simplified deterministic calculations."
                  )
                )
              )
            )
          )
        ),

        # BowTie Analysis Tab
        nav_panel(
          title = tagList(icon("diagram-project"), "BowTie Analysis"), value = "bowtie_method_help",

          fluidRow(
            column(12,
              card(
                card_header(
                  tagList(icon("diagram-project"), "BowTie Risk Analysis Methodology"),
                  class = "bg-warning text-dark"
                ),
                card_body(
                  div(class = "alert alert-warning",
                    tagList(icon("lightbulb"), " "),
                    strong("BowTie Analysis: "), "A systematic risk assessment technique combining fault tree analysis (causes) and event tree analysis (consequences) around a central hazardous event. This integrated approach provides a comprehensive view of risk scenarios from initiation through to final outcomes."
                  ),

                  h5(tagList(icon("info-circle"), "What Makes BowTie Analysis Unique:")),
                  div(class = "row mb-3",
                    div(class = "col-md-4",
                      div(class = "card border-info h-100",
                        div(class = "card-header bg-info text-white text-center", "🔍 Comprehensive View"),
                        div(class = "card-body small",
                          p("Unlike traditional risk methods that focus on either causes OR consequences, BowTie analysis examines the complete risk pathway from initial threats through to final outcomes, providing a holistic understanding of risk scenarios.")
                        )
                      )
                    ),
                    div(class = "col-md-4",
                      div(class = "card border-warning h-100",
                        div(class = "card-header bg-warning text-dark text-center", "🛡️ Control Integration"),
                        div(class = "card-body small",
                          p("BowTie analysis explicitly models both preventive controls (barriers to prevent incidents) and protective controls (mitigation measures), allowing for systematic evaluation of risk management effectiveness.")
                        )
                      )
                    ),
                    div(class = "col-md-4",
                      div(class = "card border-success h-100",
                        div(class = "card-header bg-success text-white text-center", "📊 Visual Communication"),
                        div(class = "card-body small",
                          p("The distinctive 'bow-tie' shape makes complex risk scenarios immediately understandable to stakeholders, facilitating better risk communication and decision-making across organizational levels.")
                        )
                      )
                    )
                  ),

                  h5(tagList(icon("sitemap"), "BowTie Structure & Components:")),
                  div(class = "row mb-4",
                    div(class = "col-md-6",
                      h6("Left Side - Fault Tree Analysis:"),
                      tags$ul(
                        tags$li(strong("Threats/Hazards: "), "Sources of risk or danger"),
                        tags$li(strong("Causes: "), "Specific events or conditions that can trigger the central event"),
                        tags$li(strong("Preventive Controls: "), "Barriers designed to prevent the central event from occurring")
                      )
                    ),
                    div(class = "col-md-6",
                      h6("Right Side - Event Tree Analysis:"),
                      tags$ul(
                        tags$li(strong("Central Event: "), "The main hazardous event of concern"),
                        tags$li(strong("Consequences: "), "Potential outcomes if the central event occurs"),
                        tags$li(strong("Protective Controls: "), "Barriers to mitigate consequences after the central event")
                      )
                    )
                  ),

                  h5(tagList(icon("leaf"), "Environmental Risk Applications:")),
                  div(class = "alert alert-success",
                    p("BowTie analysis is particularly valuable for environmental risk assessment as it provides a holistic view of environmental hazards, their causes, and potential ecological consequences. It excels in complex environmental systems where multiple stressors interact and cascading effects are common."),

                    h6("Key Environmental Applications:"),
                    tags$ul(
                      tags$li(strong("Marine Ecosystems: "), "Oil spills (vessel accidents → marine pollution → biodiversity loss), plastic pollution (waste management failures → microplastic accumulation → food chain contamination), overfishing impacts (unsustainable practices → stock depletion → ecosystem collapse)"),
                      tags$li(strong("Climate Change: "), "Greenhouse gas emissions (industrial activities → atmospheric accumulation → global warming → extreme weather), ecosystem disruption (temperature shifts → species migration → habitat mismatch), tipping points (ice sheet melting → sea level rise → coastal flooding)"),
                      tags$li(strong("Biodiversity Loss: "), "Habitat destruction (land use change → fragmentation → species isolation), invasive species (transport vectors → establishment → native species displacement), species extinction pathways (population decline → genetic bottlenecks → local extinction)"),
                      tags$li(strong("Water Quality: "), "Industrial discharge (process failures → toxic release → aquatic contamination), agricultural runoff (intensive farming → nutrient loading → eutrophication), contamination sources (landfill leaching → groundwater pollution → drinking water safety)"),
                      tags$li(strong("Air Quality: "), "Industrial emissions (combustion processes → particulate release → respiratory health impacts), vehicle pollution (transportation demand → exhaust emissions → urban air quality degradation), particulate matter (dust storms → PM2.5 exposure → cardiovascular effects)"),
                      tags$li(strong("Soil Contamination: "), "Chemical spills (storage failures → soil penetration → groundwater migration), mining activities (extraction operations → heavy metal release → agricultural contamination), waste disposal (improper handling → leachate formation → soil degradation)")
                    ),

                    h6("Why BowTie Works Well for Environmental Risks:"),
                    div(class = "row mt-3",
                      div(class = "col-md-6",
                        tags$ul(
                          tags$li(strong("System Complexity: "), "Environmental systems involve multiple interacting components that BowTie can map systematically"),
                          tags$li(strong("Multiple Pathways: "), "Environmental problems often have diverse causes and consequences that benefit from comprehensive mapping"),
                          tags$li(strong("Stakeholder Engagement: "), "Visual format facilitates communication between scientists, policymakers, and the public")
                        )
                      ),
                      div(class = "col-md-6",
                        tags$ul(
                          tags$li(strong("Regulatory Compliance: "), "Many environmental regulations require systematic risk assessment approaches"),
                          tags$li(strong("Prevention Focus: "), "Environmental protection emphasizes prevention over remediation, aligning with BowTie's control-focused approach"),
                          tags$li(strong("Uncertainty Management: "), "Environmental risks involve significant uncertainty that BowTie (especially with Bayesian enhancement) handles well")
                        )
                      )
                    )
                  ),

                  h5(tagList(icon("cogs"), "Methodological Framework:")),
                  div(class = "row",
                    div(class = "col-md-4",
                      div(class = "card border-primary mb-3",
                        div(class = "card-header bg-primary text-white", "1. Hazard Identification"),
                        div(class = "card-body",
                          tags$ul(class = "small",
                            tags$li("Define central environmental event"),
                            tags$li("Identify environmental stressors"),
                            tags$li("Map ecosystem vulnerabilities")
                          )
                        )
                      )
                    ),
                    div(class = "col-md-4",
                      div(class = "card border-info mb-3",
                        div(class = "card-header bg-info text-white", "2. Cause Analysis"),
                        div(class = "card-body",
                          tags$ul(class = "small",
                            tags$li("Analyze anthropogenic pressures"),
                            tags$li("Assess natural variability factors"),
                            tags$li("Identify control failure modes")
                          )
                        )
                      )
                    ),
                    div(class = "col-md-4",
                      div(class = "card border-success mb-3",
                        div(class = "card-header bg-success text-white", "3. Consequence Assessment"),
                        div(class = "card-body",
                          tags$ul(class = "small",
                            tags$li("Evaluate ecosystem impacts"),
                            tags$li("Assess biodiversity effects"),
                            tags$li("Quantify recovery potential")
                          )
                        )
                      )
                    )
                  ),

                  h5(tagList(icon("graduation-cap"), "Recent Scientific Publications & Resources:")),
                  div(class = "alert alert-light border",

                    h6("Environmental BowTie Applications (2023-2024):"),
                    tags$ul(
                      tags$li(
                        strong("Urban Waterlogging Risk Assessment:"), br(),
                        em("Frontiers in Environmental Science, 2023"), " - ",
                        a("Risk analysis of waterlogging using bow-tie Bayesian network model",
                          href = "https://www.frontiersin.org/journals/environmental-science/articles/10.3389/fenvs.2023.1258544/full",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Sustainability Assessment:"), br(),
                        em("Sustainability (MDPI), 2022"), " - ",
                        a("Health-Safety Risk Assessment of Landfill with Fuzzy Multi-Criteria and Bow Tie Model",
                          href = "https://www.mdpi.com/2071-1050/14/22/15465",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Laboratory Safety:"), br(),
                        em("Journal of Chemical Health & Safety, 2017"), " - ",
                        a("Using bowtie methodology to support laboratory hazard identification and risk management",
                          href = "https://pubs.acs.org/doi/10.1016/j.jchas.2016.10.003",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Marine Biodiversity Risk Assessment:"), br(),
                        em("Arpha Preprints, 2025"), " - ",
                        a("Bowtie method for marine biodiversity change assessment using DAPSI(W)R(M) framework",
                          href = "https://doi.org/10.3897/arphapreprints.e167392",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Marine Environmental Management:"), br(),
                        em("ScienceDirect, 2018"), " - ",
                        a("Putting on a bow-tie to sort out marine policy and management complexity",
                          href = "https://www.sciencedirect.com/science/article/pii/S0048969718331322",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Wastewater Treatment Risk Assessment:"), br(),
                        em("ResearchGate, 2020"), " - ",
                        a("Risk assessment of industrial wastewater treatment using bow-tie method",
                          href = "https://www.researchgate.net/publication/337903092_Risk_assessment_of_an_industrial_wastewater_treatment_and_reclamation_plant_using_the_bow-tie_method",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Petroleum Storage Environmental Risk:"), br(),
                        em("Sustainability (MDPI), 2025"), " - ",
                        a("Sustainable Risk Management for Petroleum Storage: Bow-Tie and Dynamic Bayesian Networks",
                          href = "https://www.mdpi.com/2071-1050/17/6/2642",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("General Environmental Risk:"), br(),
                        em("ResearchGate, 2016"), " - ",
                        a("Environmental Risk Assessment Utilizing Bow-Tie Methodology",
                          href = "https://www.researchgate.net/publication/290587167_Environmental_Risk_Assessment_Utilizing_Bow-Tie_Methodology",
                          target = "_blank", class = "text-primary")
                      )
                    ),

                    h6("Recent Environmental Applications (2024-2025):"),
                    tags$ul(
                      tags$li(
                        strong("Digital Twin Safety Management:"), br(),
                        em("Systems (MDPI), 2024"), " - ",
                        a("The BowTie as a Digital Twin: Data-Driven Safety Management",
                          href = "https://www.mdpi.com/2313-576X/10/2/34",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Food Processing Industry Risk:"), br(),
                        em("ResearchGate, 2024"), " - ",
                        a("Risk evaluation of grease interceptor treatment using bowtie analysis",
                          href = "https://www.researchgate.net/publication/379141514_Evaluation_of_risk_associated_with_treatment_of_fat_oil_and_grease_Grease_interceptor_from_food_processing_industry_effluent_using_bowtie_analysis",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Subsea Pipeline Environmental Risk:"), br(),
                        em("ResearchGate, 2023"), " - ",
                        a("Risk Identification and Bowtie Analysis for Subsea Pipeline Management",
                          href = "https://www.researchgate.net/publication/374146704_Risk_Identification_and_Bowtie_Analysis_for_Risk_Management_of_Subsea_Pipelines",
                          target = "_blank", class = "text-primary")
                      )
                    ),

                    h6("Methodological Advances (2021-2024):"),
                    tags$ul(
                      tags$li(
                        strong("Fuzzy BowTie Analysis:"), br(),
                        em("Applied Soft Computing, 2021"), " - ",
                        a("Comprehensive methodology for quantification of Bow-tie under type II fuzzy data",
                          href = "https://www.sciencedirect.com/science/article/abs/pii/S1568494621000715",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Quantitative and Graphical Improvements:"), br(),
                        em("ResearchGate, 2024"), " - ",
                        a("Use and misuse of Bowtie Analysis: quantitative and graphical approaches",
                          href = "https://www.researchgate.net/publication/377471510_Use_and_misuse_of_Bowtie_Analysis_and_ways_to_make_it_better_using_quantitative_and_graphical_approaches",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Aviation Safety Applications:"), br(),
                        em("Aerospace (MDPI), 2020"), " - ",
                        a("Systematic Methodology for Developing Bowtie in Risk Assessment: Application to Borescope Inspection",
                          href = "https://www.mdpi.com/2226-4310/7/7/86",
                          target = "_blank", class = "text-primary")
                      ),
                      tags$li(
                        strong("Industrial Risk Management:"), br(),
                        em("Chemical Engineering Progress, 2019"), " - ",
                        a("Enhancing PHAs: The Power of Bowties",
                          href = "https://www.aiche.org/resources/publications/cep/2019/february/enhancing-phas-power-bowties",
                          target = "_blank", class = "text-primary")
                      )
                    ),

                    h6("Standards & Guidelines:"),
                    tags$ul(
                      tags$li(
                        strong("ISO 31000:2018"), " - Risk management principles and guidelines"
                      ),
                      tags$li(
                        strong("IEC 31010:2019"), " - Risk assessment techniques (includes BowTie methodology)"
                      ),
                      tags$li(
                        strong("UNEP Guidelines"), " - Environmental risk assessment best practices"
                      ),
                      tags$li(
                        a("Center for Chemical Process Safety (CCPS) - Bow Ties in Risk Management",
                          href = "https://www.aiche.org/ccps/resources/publications/books/bow-ties-risk-management-concept-book-process-safety",
                          target = "_blank", class = "text-primary")
                      )
                    )
                  ),

                  div(class = "alert alert-info mt-3",
                    tagList(icon("info-circle"), " "),
                    strong("Application Note: "), "This tool implements the latest BowTie methodology enhanced with Bayesian probabilistic modeling for quantitative environmental risk assessment. The integration allows for uncertainty quantification and evidence-based decision making under incomplete information."
                  )
                )
              )
            )
          )
        ),

        # Application Guide Tab
        nav_panel(
          title = tagList(icon("book"), "Application Guide"), value = "app_guide_help",

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
        ),

        # User Manual Tab
        nav_panel(
          title = tagList(icon("file-pdf"), "User Manual"), value = "user_manual_help",

          fluidRow(
            column(12,
              card(
                card_header(
                  tagList(icon("file-pdf"), "Download User Manual"),
                  class = "bg-primary text-white"
                ),
                card_body(
                  div(class = "text-center p-4",
                    icon("file-pdf", class = "fa-5x text-danger mb-3"),
                    h4("Environmental Bowtie Risk Analysis User Manual"),
                    p(class = "text-muted",
                      "Comprehensive guide covering all features, workflows, and best practices"
                    ),
                    hr(),
                    div(class = "row mb-3",
                      div(class = "col-md-4",
                        div(class = "card border-primary",
                          div(class = "card-body text-center",
                            icon("book-open", class = "fa-2x text-primary mb-2"),
                            h6("Contents"),
                            p(class = "small text-muted",
                              "Step-by-step guides, screenshots, and examples"
                            )
                          )
                        )
                      ),
                      div(class = "col-md-4",
                        div(class = "card border-success",
                          div(class = "card-body text-center",
                            icon("lightbulb", class = "fa-2x text-success mb-2"),
                            h6("Features"),
                            p(class = "small text-muted",
                              "Complete coverage of all application capabilities"
                            )
                          )
                        )
                      ),
                      div(class = "col-md-4",
                        div(class = "card border-info",
                          div(class = "card-body text-center",
                            icon("graduation-cap", class = "fa-2x text-info mb-2"),
                            h6("Learning"),
                            p(class = "small text-muted",
                              "Best practices and troubleshooting tips"
                            )
                          )
                        )
                      )
                    ),
                    div(class = "alert alert-info",
                      icon("info-circle"),
                      strong(" Manual Details: "),
                      paste("Version", APP_CONFIG$VERSION, "| Multiple Languages | Comprehensive Documentation")
                    ),
                    div(class = "d-flex gap-2 justify-content-center",
                      downloadButton(
                        "download_manual",
                        "Download User Manual (PDF - English)",
                        class = "btn-lg btn-primary",
                        icon = icon("download")
                      ),
                      downloadButton(
                        "download_manual_fr",
                        "Télécharger le Manuel (HTML - Français)",
                        class = "btn-lg btn-success",
                        icon = icon("download")
                      )
                    ),
                    hr(),
                    p(class = "small text-muted mt-3",
                      "The manual is regularly updated to reflect the latest features and improvements."
                    )
                  )
                )
              )
            )
          )
        ),

        # About Tab - Fully Translated
        nav_panel(
          title = tagList(icon("info-circle"), "About"), value = "about",

          fluidRow(
            column(12,
              card(
                card_header(
                  uiOutput("about_header"),
                  class = "bg-success text-white"
                ),
                card_body(
                  uiOutput("about_content")
                )
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
        span(class = "badge bg-success", paste0("v", APP_CONFIG$VERSION)),
        " - Enhanced with Bayesian Network Analysis"
      )))
)