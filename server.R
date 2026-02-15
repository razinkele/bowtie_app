# Server Logic for Environmental Bowtie Risk Analysis Application
# =============================================================================

server <- function(input, output, session) {

  # =============================================================================
  # HELPER FUNCTION FOR SAFE UI RENDERING
  # =============================================================================

  # Safe renderUI wrapper that catches errors and provides fallback content
  # Use this for output renderers that depend on reactive values that could be NULL
  safe_render_ui <- function(expr, fallback = NULL) {
    tryCatch({
      result <- expr
      if (is.null(result)) fallback else result
    }, error = function(e) {
      bowtie_log(paste("UI render error:", e$message), level = "warn")
      if (is.null(fallback)) {
        div(class = "text-muted small", "Content unavailable")
      } else {
        fallback
      }
    })
  }

  # Safe translation function that returns key if translation fails
  safe_t <- function(key, lang_val = NULL) {
    tryCatch({
      if (is.null(lang_val)) lang_val <- "en"
      result <- t(key, lang_val)
      if (is.null(result) || result == "") key else result
    }, error = function(e) {
      # Log translation errors at debug level to avoid noise but maintain visibility
      bowtie_log(paste("Translation failed for key:", key, "-", e$message), level = "debug")
      key
    })
  }

  # =============================================================================
  # INITIALIZE SERVER MODULES (Phase 3: Server Modularization)
  # =============================================================================

  # Initialize login module (must be first)
  current_user <- login_server("login")

  # Initialize language module
  language_module <- language_module_server(input, output, session)
  lang <- language_module$lang
  currentLanguage <- language_module$currentLanguage

  # Initialize theme module
  theme_module <- theme_module_server(input, output, session, lang)
  current_theme <- theme_module$current_theme
  appliedTheme <- theme_module$appliedTheme
  themeUpdateTrigger <- theme_module$themeUpdateTrigger

  # Initialize data management module
  data_module <- data_management_module_server(input, output, session, lang)
  currentData <- data_module$currentData
  editedData <- data_module$editedData
  getCurrentData <- data_module$getCurrentData
  hasData <- data_module$hasData
  envDataGenerated <- data_module$envDataGenerated
  selectedRows <- data_module$selectedRows
  dataVersion <- data_module$dataVersion
  lastNotification <- data_module$lastNotification
  sheets <- data_module$sheets

  # Initialize export module
  export_module_server(input, output, session, getCurrentData)

  # Initialize autosave module
  autosave_module <- autosave_module_server(input, output, session, getCurrentData, lang)
  lastAutosaveTime <- autosave_module$lastAutosaveTime
  autosaveVersion <- autosave_module$autosaveVersion

  # Initialize local storage module (for user-selected local folder storage)
  local_storage <- local_storage_server(input, output, session, getCurrentData, lang)

  # Initialize Bayesian network module
  bayesian_module <- bayesian_module_server(input, output, session, getCurrentData, lang)
  bayesianNetwork <- bayesian_module$bayesianNetwork
  bayesianNetworkCreated <- bayesian_module$bayesianNetworkCreated
  inferenceResults <- bayesian_module$inferenceResults
  inferenceCompleted <- bayesian_module$inferenceCompleted

  # Initialize Bowtie Visualization module
  bowtie_visualization_module_server(input, output, session, getCurrentData, lang)

  # Initialize Report Generation module
  report_generation_module_server(input, output, session, currentData, lang)

  # Initialize AI Analysis module
  ai_analysis_module_server(input, output, session, vocabulary_data, lang)

  # Initialize Help & Documentation module
  source("server_modules/help_module.R", local = TRUE)
  init_help_module(input, output, session, lang)

  # Initialize Vocabulary Management module
  source("server_modules/vocabulary_server_module.R", local = TRUE)
  init_vocabulary_server_module(input, output, session, vocabulary_data)

  # Initialize Link Risk Assessment module
  source("server_modules/link_risk_module.R", local = TRUE)
  init_link_risk_module(input, output, session, getCurrentData,
                        currentData, editedData, dataVersion, lang)

  # =============================================================================
  # SESSION CLEANUP HANDLER (Memory leak prevention)
  # =============================================================================
  session$onSessionEnded(function() {
    bowtie_log("🧹 Session ended - cleaning up resources...", .verbose = TRUE)
    tryCatch({
      # Clear reactive values to prevent memory leaks
      if (exists("currentData") && is.function(currentData)) currentData(NULL)
      if (exists("editedData") && is.function(editedData)) editedData(NULL)
      if (exists("bayesianNetwork") && is.function(bayesianNetwork)) bayesianNetwork(NULL)
      if (exists("inferenceResults") && is.function(inferenceResults)) inferenceResults(NULL)

      # Clear application cache
      if (exists("clear_cache") && is.function(clear_cache)) {
        clear_cache(reset_stats = TRUE)
      }

      # Clean up temporary files created during session
      temp_files <- list.files(tempdir(), pattern = "bowtie_.*", full.names = TRUE)
      if (length(temp_files) > 0) {
        unlink(temp_files, recursive = TRUE)
        bowtie_log(paste("🗑️ Cleaned up", length(temp_files), "temporary files"), .verbose = TRUE)
      }

      # Force garbage collection
      gc(verbose = FALSE)

      bowtie_log("✅ Session cleanup complete", .verbose = TRUE)
    }, error = function(e) {
      bowtie_log(paste("⚠️ Error during session cleanup:", e$message), level = "warn", .verbose = TRUE)
    })
  })

  # =============================================================================
  # ADDITIONAL SERVER LOGIC (not yet modularized)
  # =============================================================================
  # NOTE: Language module handles all language/translation logic
  # NOTE: Theme module handles all theme management logic
  # NOTE: Data management module handles file upload, data loading, and generation
  # NOTE: Export module handles all download handlers for diagrams and data
  # NOTE: Autosave module handles automatic and manual saving of workflow state
  # NOTE: Local storage module handles user-selected local folder storage

  # =============================================================================
  # LOCAL DATA RESTORE HANDLER
  # =============================================================================
  # Handler for when data is loaded from local folder
  observeEvent(input$local_data_restore, {
    loaded_data <- input$local_data_restore
    if (is.null(loaded_data)) return()
    
    tryCatch({
      # Restore current data if present
      if (!is.null(loaded_data$current_data)) {
        currentData(loaded_data$current_data)
        editedData(loaded_data$current_data)
        hasData(TRUE)
        dataVersion(dataVersion() + 1)
        
        # Update problem selectors
        problems <- unique(loaded_data$current_data$Central_Problem)
        updateSelectInput(session, "selectedProblem", choices = problems)
        updateSelectInput(session, "bayesianProblem", choices = problems)
        
        notify_success("✅ Data restored from local save", duration = 3)
      }
      
      # Restore settings if present
      if (!is.null(loaded_data$settings)) {
        settings <- loaded_data$settings
        
        if (!is.null(settings$storage_mode)) {
          updateRadioButtons(session, "storage_mode", selected = settings$storage_mode)
        }
        if (!is.null(settings$storage_path)) {
          updateTextInput(session, "local_folder_path", value = settings$storage_path)
        }
      }
      
    }, error = function(e) {
      notify_warning(paste("⚠️ Could not restore all data:", e$message))
    })
  })

  # =============================================================================
  # SIDEBAR USER PANEL (Login-based)
  # =============================================================================

  output$sidebar_user_panel <- renderUI({
    # Check if user is logged in
    if (isTRUE(current_user$logged_in)) {
      # Determine icon and badge based on role
      user_icon <- if (current_user$role == "admin") "user-shield" else "user"
      badge_class <- if (current_user$role == "admin") "bg-danger" else "bg-secondary"
      badge_text <- if (current_user$role == "admin") "Admin" else "User"

      sidebarUserPanel(
        name = tagList(
          current_user$display_name,
          tags$span(class = paste("badge", badge_class, "ms-2"), badge_text)
        ),
        image = NULL
      )
    } else {
      sidebarUserPanel(
        name = "Environmental Risk Management"
      )
    }
  })

  # Header user menu dropdown with login/logout options
  output$header_user_menu <- renderUI({
    user_icon <- if (current_user$role == "admin") "user-shield" else "user"

    if (current_user$role == "admin") {
      # Admin user - show logout option
      dropdownMenu(
        badgeStatus = "danger",
        type = "messages",
        icon = icon(user_icon),
        headerText = current_user$display_name,

        messageItem(
          from = "Administrator",
          message = "Full access enabled",
          icon = icon("id-badge"),
          time = NULL
        ),
        messageItem(
          from = "Switch to Default",
          message = "Return to standard user mode",
          icon = icon("sign-out-alt"),
          time = NULL,
          href = "javascript:void(0);",
          inputId = "switch_to_default_btn"
        )
      )
    } else {
      # Default user - show login as admin option
      dropdownMenu(
        badgeStatus = "secondary",
        type = "messages",
        icon = icon(user_icon),
        headerText = current_user$display_name,

        messageItem(
          from = "Default User",
          message = "Standard access",
          icon = icon("id-badge"),
          time = NULL
        ),
        messageItem(
          from = "Login as Admin",
          message = "Switch to administrator mode",
          icon = icon("user-shield"),
          time = NULL,
          href = "javascript:void(0);",
          inputId = "show_admin_login_btn"
        )
      )
    }
  })

  # Handle "Login as Admin" button - show the admin login modal
  observeEvent(input$show_admin_login_btn, {
    shinyjs::runjs("$('#login-admin_login_modal').modal('show');")
  })

  # Handle "Switch to Default" button - switch back to default user
  observeEvent(input$switch_to_default_btn, {
    # Switch to default user
    current_user$logged_in <- TRUE
    current_user$username <- "default"
    current_user$role <- "default"
    current_user$display_name <- "Default User"
    current_user$login_time <- Sys.time()

    notify_info("Switched to Default User", duration = 3)
  })

  # =============================================================================
  # ADMIN MENU SECTION (Conditionally shown for admin users)
  # =============================================================================

  output$admin_menu_section <- renderUI({
    if (current_user$role == "admin") {
      tagList(
        sidebarHeader("ADMINISTRATION"),
        menuItem(
          text = "Custom Terms Review",
          tabName = "custom_terms",
          icon = icon("clipboard-check"),
          badgeLabel = textOutput("badge_pending_terms", inline = TRUE),
          badgeColor = "warning"
        )
      )
    } else {
      NULL
    }
  })

  # Badge showing pending custom terms count
  output$badge_pending_terms <- renderText({
    if (current_user$role == "admin") {
      tryCatch({
        terms <- load_custom_terms()
        pending_count <- sum(
          sum(terms$activities$status == "pending"),
          sum(terms$pressures$status == "pending"),
          sum(terms$preventive_controls$status == "pending"),
          sum(terms$consequences$status == "pending"),
          sum(terms$protective_controls$status == "pending"),
          sum(terms$escalation_factors$status == "pending")
        )
        if (pending_count > 0) return(as.character(pending_count))
        return("")
      }, error = function(e) "")
    } else {
      ""
    }
  })

  # =============================================================================
  # CUSTOM TERMS REVIEW (Admin Only)
  # =============================================================================

  # Reactive to trigger refresh of custom terms
  custom_terms_refresh <- reactiveVal(0)

  # Custom terms content (only for admin)
  output$custom_terms_content <- renderUI({
    # Force refresh when needed
    custom_terms_refresh()

    if (current_user$role != "admin") {
      return(
        div(
          class = "text-center p-5",
          icon("lock", class = "fa-4x text-danger mb-3"),
          h3("Access Denied", class = "text-danger"),
          p("This section is only available to administrators."),
          p("Please login as admin to access custom terms review.")
        )
      )
    }

    # Load terms
    all_terms <- get_all_custom_terms_flat()
    summary_data <- get_custom_terms_summary()

    fluidRow(
      # Header
      column(12,
        div(
          class = "d-flex justify-content-between align-items-center mb-4",
          h2(tagList(icon("clipboard-check"), " Custom Terms Review")),
          div(
            actionButton("refresh_custom_terms", tagList(icon("refresh"), " Refresh"),
                        class = "btn-outline-primary me-2"),
            downloadButton("export_custom_terms", tagList(icon("download"), " Export"),
                          class = "btn-outline-success")
          )
        )
      ),

      # Summary Cards
      column(12,
        div(class = "row mb-4",
          lapply(1:nrow(summary_data), function(i) {
            row <- summary_data[i, ]
            div(class = "col-md-2 col-sm-4 mb-3",
              div(class = "card text-center h-100",
                div(class = "card-body p-3",
                  h6(class = "card-title text-muted mb-1", row$Category),
                  h3(class = "mb-0", row$Total),
                  div(class = "small",
                    if (row$Pending > 0) span(class = "badge bg-warning me-1", paste(row$Pending, "pending")),
                    if (row$Approved > 0) span(class = "badge bg-success me-1", paste(row$Approved, "approved")),
                    if (row$Rejected > 0) span(class = "badge bg-danger", paste(row$Rejected, "rejected"))
                  )
                )
              )
            )
          })
        )
      ),

      # Filter controls
      column(12,
        div(class = "card mb-4",
          div(class = "card-body",
            fluidRow(
              column(3,
                selectInput("filter_term_category", "Category:",
                  choices = c("All" = "all",
                              "Activities" = "activities",
                              "Pressures" = "pressures",
                              "Preventive Controls" = "preventive_controls",
                              "Consequences" = "consequences",
                              "Protective Controls" = "protective_controls",
                              "Escalation Factors" = "escalation_factors"),
                  selected = "all")
              ),
              column(3,
                selectInput("filter_term_status", "Status:",
                  choices = c("All" = "all", "Pending" = "pending",
                              "Approved" = "approved", "Rejected" = "rejected"),
                  selected = "pending")
              ),
              column(3,
                textInput("filter_term_search", "Search:", placeholder = "Search terms...")
              ),
              column(3,
                div(class = "mt-4",
                  actionButton("apply_term_filters", tagList(icon("filter"), " Apply"),
                              class = "btn-primary")
                )
              )
            )
          )
        )
      ),

      # Terms table
      column(12,
        div(class = "card",
          div(class = "card-header bg-primary text-white",
            h5(class = "mb-0", tagList(icon("list"), " Custom Terms"))
          ),
          div(class = "card-body",
            if (nrow(all_terms) == 0) {
              div(class = "text-center p-5 text-muted",
                icon("inbox", class = "fa-3x mb-3"),
                h5("No custom terms found"),
                p("Custom terms added in the Guided Workflow will appear here for review.")
              )
            } else {
              DTOutput("custom_terms_table")
            }
          )
        )
      )
    )
  })

  # Render custom terms table
  output$custom_terms_table <- renderDT({
    custom_terms_refresh()

    all_terms <- get_all_custom_terms_flat()

    if (nrow(all_terms) == 0) return(NULL)

    # Apply filters
    filtered <- all_terms

    # Category filter
    if (!is.null(input$filter_term_category) && input$filter_term_category != "all") {
      filtered <- filtered[filtered$category_key == input$filter_term_category, ]
    }

    # Status filter
    if (!is.null(input$filter_term_status) && input$filter_term_status != "all") {
      filtered <- filtered[filtered$status == input$filter_term_status, ]
    }

    # Search filter
    if (!is.null(input$filter_term_search) && nchar(input$filter_term_search) > 0) {
      search_term <- tolower(input$filter_term_search)
      filtered <- filtered[grepl(search_term, tolower(filtered$term)), ]
    }

    if (nrow(filtered) == 0) return(NULL)

    # Add action buttons
    filtered$actions <- sapply(1:nrow(filtered), function(i) {
      row <- filtered[i, ]
      paste0(
        '<div class="btn-group btn-group-sm">',
        if (row$status == "pending") {
          paste0(
            '<button class="btn btn-success btn-sm approve-term" data-id="', row$id,
            '" data-category="', row$category_key, '"><i class="fas fa-check"></i></button>',
            '<button class="btn btn-danger btn-sm reject-term" data-id="', row$id,
            '" data-category="', row$category_key, '"><i class="fas fa-times"></i></button>'
          )
        } else "",
        '<button class="btn btn-outline-danger btn-sm delete-term" data-id="', row$id,
        '" data-category="', row$category_key, '"><i class="fas fa-trash"></i></button>',
        '</div>'
      )
    })

    # Format status with badges
    filtered$status_badge <- sapply(filtered$status, function(s) {
      switch(s,
        "pending" = '<span class="badge bg-warning text-dark">Pending</span>',
        "approved" = '<span class="badge bg-success">Approved</span>',
        "rejected" = '<span class="badge bg-danger">Rejected</span>',
        '<span class="badge bg-secondary">Unknown</span>'
      )
    })

    # Select columns for display
    display_df <- filtered[, c("term", "category", "status_badge", "added_by",
                               "added_date", "project_name", "actions")]
    colnames(display_df) <- c("Term", "Category", "Status", "Added By",
                              "Date Added", "Project", "Actions")

    datatable(
      display_df,
      escape = FALSE,
      selection = "none",
      rownames = FALSE,
      options = list(
        pageLength = 15,
        dom = 'frtip',
        order = list(list(4, 'desc')),
        columnDefs = list(
          list(className = 'dt-center', targets = c(2, 6)),
          list(width = '120px', targets = 6)
        )
      ),
      class = "table table-striped table-hover"
    )
  })

  # Handle approve term button clicks
  observeEvent(input$approve_term_click, {
    if (current_user$role != "admin") return()

    term_id <- input$approve_term_click$id
    category <- input$approve_term_click$category

    result <- update_term_status(category, term_id, "approved", current_user$username)

    if (result$success) {
      notify_info("Term approved")
      custom_terms_refresh(custom_terms_refresh() + 1)
    } else {
      notify_error(result$message)
    }
  })

  # Handle reject term button clicks
  observeEvent(input$reject_term_click, {
    if (current_user$role != "admin") return()

    term_id <- input$reject_term_click$id
    category <- input$reject_term_click$category

    result <- update_term_status(category, term_id, "rejected", current_user$username)

    if (result$success) {
      notify_warning("Term rejected")
      custom_terms_refresh(custom_terms_refresh() + 1)
    } else {
      notify_error(result$message)
    }
  })

  # Handle delete term button clicks
  observeEvent(input$delete_term_click, {
    if (current_user$role != "admin") return()

    term_id <- input$delete_term_click$id
    category <- input$delete_term_click$category

    result <- delete_custom_term(category, term_id)

    if (result$success) {
      notify_info("Term deleted")
      custom_terms_refresh(custom_terms_refresh() + 1)
    } else {
      notify_error(result$message)
    }
  })

  # Refresh button
  observeEvent(input$refresh_custom_terms, {
    custom_terms_refresh(custom_terms_refresh() + 1)
    notify_info("Refreshed", duration = 2)
  })

  # Apply filters button
  observeEvent(input$apply_term_filters, {
    custom_terms_refresh(custom_terms_refresh() + 1)
  })

  # Export custom terms to Excel
  output$export_custom_terms <- downloadHandler(
    filename = function() {
      paste0("custom_terms_export_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".xlsx")
    },
    content = function(file) {
      all_terms <- get_all_custom_terms_flat()
      if (nrow(all_terms) > 0) {
        # Remove internal columns
        export_df <- all_terms[, c("term", "category", "status", "added_by",
                                    "added_date", "project_name", "reviewed_by",
                                    "reviewed_date", "notes")]
        colnames(export_df) <- c("Term", "Category", "Status", "Added By",
                                 "Date Added", "Project", "Reviewed By",
                                 "Review Date", "Notes")
        openxlsx::write.xlsx(export_df, file)
      } else {
        # Create empty file with headers
        empty_df <- data.frame(
          Term = character(), Category = character(), Status = character(),
          `Added By` = character(), `Date Added` = character(), Project = character(),
          `Reviewed By` = character(), `Review Date` = character(), Notes = character()
        )
        openxlsx::write.xlsx(empty_df, file)
      }
    }
  )

  # JavaScript to handle button clicks in DataTable
  observeEvent(TRUE, {
    shinyjs::runjs("
      $(document).on('click', '.approve-term', function() {
        var id = $(this).data('id');
        var category = $(this).data('category');
        Shiny.setInputValue('approve_term_click', {id: id, category: category}, {priority: 'event'});
      });

      $(document).on('click', '.reject-term', function() {
        var id = $(this).data('id');
        var category = $(this).data('category');
        Shiny.setInputValue('reject_term_click', {id: id, category: category}, {priority: 'event'});
      });

      $(document).on('click', '.delete-term', function() {
        if (confirm('Are you sure you want to delete this term?')) {
          var id = $(this).data('id');
          var category = $(this).data('category');
          Shiny.setInputValue('delete_term_click', {id: id, category: category}, {priority: 'event'});
        }
      });
    ")
  }, once = TRUE)

  # =============================================================================
  # HELP MENU HANDLERS (Handled by help_module)
  # =============================================================================
  # NOTE: Help menu handlers (show_user_guide, show_about) moved to help_module.R

  # Conditional menu item disabling based on data availability
  # Uses ignoreNULL to prevent initial NULL triggers
  # Note: Add debounce() wrapper if performance issues occur with rapid data changes
  observeEvent(hasData(), {
    # Throttle: Only update if state actually changed
    data_available <- hasData()

    # Debug logging gated behind verbose option
    if (getOption("bowtie.verbose", FALSE)) {
      bowtie_log("Menu observer triggered. hasData() =", data_available, level = "debug")
    }

    # Menu items that require bowtie data to function
    if (data_available) {
      if (getOption("bowtie.verbose", FALSE)) {
        bowtie_log("Enabling menu items...", level = "debug")
      }
      # Enable menu items when data is available
      runjs("
        $('a[data-value=\"bowtie\"]').removeClass('disabled').css('pointer-events', 'auto').css('opacity', '1');
        $('a[data-value=\"matrix\"]').removeClass('disabled').css('pointer-events', 'auto').css('opacity', '1');
        $('a[data-value=\"link_risk\"]').removeClass('disabled').css('pointer-events', 'auto').css('opacity', '1');
        $('a[data-value=\"bayesian\"]').removeClass('disabled').css('pointer-events', 'auto').css('opacity', '1');
      ")
    } else {
      if (getOption("bowtie.verbose", FALSE)) {
        bowtie_log("Disabling menu items...", level = "debug")
      }
      # Disable menu items when no data is available
      runjs("
        $('a[data-value=\"bowtie\"]').addClass('disabled').css('pointer-events', 'none').css('opacity', '0.5');
        $('a[data-value=\"matrix\"]').addClass('disabled').css('pointer-events', 'none').css('opacity', '0.5');
        $('a[data-value=\"link_risk\"]').addClass('disabled').css('pointer-events', 'none').css('opacity', '0.5');
        $('a[data-value=\"bayesian\"]').addClass('disabled').css('pointer-events', 'none').css('opacity', '0.5');
      ")
    }
  }, ignoreInit = FALSE, ignoreNULL = TRUE)

  # ARIA live region announcer for accessibility
  output$notification_announcer <- renderUI({
    msg <- lastNotification()
    if (!is.null(msg)) {
      tags$span(msg)
    }
  })

  # Dashboard navigation button
  observeEvent(input$dashboard_goto_upload, {
    updateTabItems(session, "sidebar_menu", selected = "upload")
  })

  # Empty state navigation buttons
  observeEvent(input$empty_upload, {
    updateTabItems(session, "sidebar_menu", selected = "upload")
  })

  observeEvent(input$empty_generate, {
    updateTabItems(session, "sidebar_menu", selected = "upload")
    notify_info("Select an environmental scenario and click 'Generate Data'", duration = 5)
  })

  # Risk Matrix update button
  observeEvent(input$updateMatrix, {
    dataVersion(dataVersion() + 1)
    notify_info("Risk matrix updated!", duration = 3)
  })

  # =============================================================================
  # BAYESIAN NETWORK (Handled by bayesian_module)
  # =============================================================================
  # NOTE: Bayesian network analysis is now handled by bayesian_module.R
  # Available from module:
  # - bayesianNetwork() - Reactive Bayesian network object
  # - bayesianNetworkCreated() - Network creation flag
  # - inferenceResults() - Inference results
  # - inferenceCompleted() - Inference completion flag

  # =============================================================================
  # THEME MANAGEMENT (Handled by theme_module)
  # =============================================================================
  # NOTE: All theme logic is now in theme_module.R
  # Available from module:
  # - current_theme() - Reactive theme object
  # - appliedTheme() - Currently applied theme name
  # - themeUpdateTrigger() - Theme change trigger
  # - All theme observers and handlers

  # =============================================================================
  # DATA MANAGEMENT (Handled by data_management_module)
  # =============================================================================
  # NOTE: All file upload, data loading, and generation logic is now in
  # data_management_module.R. The following functionality is handled by the module:
  # - File upload and sheet selection
  # - Data loading with validation
  # - Environmental data generation
  # - Data info outputs
  # - Sample data download
  #
  # Removed duplicate code (lines 200-351) that was conflicting with module

  # =============================================================================
  # BAYESIAN NETWORK ANALYSIS - MOVED TO MODULE
  # =============================================================================
  # NOTE: All Bayesian network functionality has been moved to bayesian_module.R
  # The module handles:
  # - Network creation (observeEvent input$createBayesianNetwork)
  # - Network visualization (output$bayesianNetworkVis)
  # - Network info (output$networkInfo)
  # - Inference (observeEvent input$runInference)
  # - Inference results (output$inferenceResults)
  # - Risk interpretation (output$riskInterpretation)
  # - CPT tables (output$cptTables)
  # - Scenario presets (worst/best case, control failure, baseline)
  # - Download handler (output$downloadBayesianResults)
  # =============================================================================

  # =============================================================================
  # EXISTING FUNCTIONALITY (keeping all original features)
  # =============================================================================

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

    # Build columnDefs dynamically based on available columns
    ncols <- ncol(data)
    col_defs <- list()

    # Only add column definitions for columns that exist
    if (ncols > 0) {
      # Center alignment for numeric-like columns (if they exist)
      center_targets <- intersect(c(7, 8, 9), seq(0, ncols - 1))
      if (length(center_targets) > 0) {
        col_defs[[length(col_defs) + 1]] <- list(className = 'dt-center', targets = center_targets)
      }

      # Width for text columns
      text_targets <- intersect(seq(0, 6), seq(0, ncols - 1))
      if (length(text_targets) > 0) {
        col_defs[[length(col_defs) + 1]] <- list(width = '100px', targets = text_targets)
      }
    }

    DT::datatable(
      data,
      options = list(
        scrollX = TRUE,
        pageLength = 20,
        selection = 'multiple',
        processing = TRUE,
        deferRender = TRUE,
        columnDefs = if (length(col_defs) > 0) col_defs else NULL,
        autoWidth = FALSE,
        dom = 'Blfrtip',
        buttons = c('copy', 'csv', 'excel'),
        language = list(processing = "Loading enhanced data with Bayesian network support...")
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
      notify_error("❌ Invalid cell reference")
      return()
    }

    col_names <- names(data)
    col_name <- col_names[info$col]

    # Numeric columns validation
    numeric_columns <- c("Likelihood", "Severity", "Overall_Likelihood", "Overall_Severity")

    if (col_name %in% numeric_columns) {
      validation <- validate_numeric_input(info$value)
      if (!validation$valid) {
        notify_error(validation$message, duration = 3)
        return()
      }
      data[info$row, info$col] <- validation$value
      data[info$row, "Risk_Level"] <- calculate_risk_level(data[info$row, "Likelihood"], data[info$row, "Severity"])
    } else {
      data[info$row, info$col] <- as.character(info$value)
    }

    editedData(data)
    dataVersion(dataVersion() + 1)
    clear_similarity_cache(confirm = FALSE)  # Non-interactive cache clear

    # Reset Bayesian network when data changes
    bayesianNetworkCreated(FALSE)
    inferenceCompleted(FALSE)

    if (runif(1) < 0.3) {
      notify_info("✓ Cell updated - Bayesian network ready for recreation", duration = 1)
    }
  }, ignoreInit = TRUE, ignoreNULL = TRUE)

  # Track selected rows efficiently
  observe({
    # Allow NULL to clear selection - intentional
    selectedRows(input$editableTable_rows_selected)
  })

  # Enhanced row operations with safe column matching
  observeEvent(input$addRow, {
    tryCatch({
      data <- getCurrentData()

      # Initialize data if none exists
      if (is.null(data) || nrow(data) == 0) {
        if (getOption("bowtie.verbose", FALSE)) {
          bowtie_log("Initializing data for addRow operation...", level = "debug")
        }
        initial_data <- generate_environmental_data_fixed()
        # Take only the structure but remove all rows to start fresh
        data <- initial_data[0, , drop = FALSE]
        currentData(data)
        editedData(data)
        notify_info("📊 Initialized new dataset for editing", duration = 2)
      }

      selected_problem <- if (!is.null(input$selectedProblem)) input$selectedProblem else "New Environmental Risk"
      new_row <- create_default_row_fixed(selected_problem)

      # Ensure column structure compatibility
      existing_cols <- names(data)
      new_row_cols <- names(new_row)

      # Add missing columns to new_row with NA values
      for (col in existing_cols) {
        if (!col %in% new_row_cols) {
          new_row[[col]] <- NA
        }
      }

      # Add missing columns to data with appropriate defaults
      for (col in new_row_cols) {
        if (!col %in% existing_cols) {
          data[[col]] <- NA
        }
      }

      # Reorder columns to match
      new_row <- new_row[, names(data), drop = FALSE]

      updated_data <- rbind(data, new_row)

      editedData(updated_data)
      dataVersion(dataVersion() + 1)
      clear_similarity_cache(confirm = FALSE)  # Non-interactive cache clear
      bayesianNetworkCreated(FALSE)  # Reset Bayesian network
      notify_success("✅ New row added with Bayesian support!", duration = 2)

    }, error = function(e) {
      bowtie_log("Error in addRow:", e$message, level = "error")
      notify_error(paste("❌ Error adding row:", e$message), duration = 5)
    })
  })

  observeEvent(input$deleteSelected, {
    rows <- selectedRows()
    if (!is.null(rows) && length(rows) > 0) {
      data <- getCurrentData()
      updated_data <- data[-rows, ]
      editedData(updated_data)
      dataVersion(dataVersion() + 1)
      clear_similarity_cache(confirm = FALSE)  # Non-interactive cache clear
      bayesianNetworkCreated(FALSE)  # Reset Bayesian network
      notify_warning(paste("🗑️ Deleted", length(rows), "row(s) - Bayesian network reset"), duration = 2)
    } else {
      notify_error(paste("❌", t("notify_no_rows_selected", lang())), duration = 2)
    }
  })

  observeEvent(input$saveChanges, {
    edited <- editedData()
    if (!is.null(edited)) {
      currentData(edited)
      notify_success("💾 Changes saved with Bayesian network support!", duration = 2)
    }
  })

  # Enhanced quick add functionality
  observeEvent(input$addActivityChain, {
    req(input$selectedProblem, input$newActivity, input$newPressure, input$newConsequence)

    if (trimws(input$newActivity) == "" || trimws(input$newPressure) == "" || trimws(input$newConsequence) == "") {
      notify_error("❌ Please enter activity, pressure, and consequence")
      return()
    }

    data <- getCurrentData()

    new_row <- data.frame(
      Activity = input$newActivity,
      Pressure = input$newPressure,
      Preventive_Control = "Enhanced preventive control",
      Escalation_Factor = "Enhanced escalation factor",
      Central_Problem = input$selectedProblem,
      Protective_Mitigation = paste("Enhanced protective mitigation for", input$newConsequence),
      Consequence = input$newConsequence,
      Likelihood = 3L,
      Severity = 3L,
      Risk_Level = "Medium",
      stringsAsFactors = FALSE
    )

    updated_data <- rbind(data, new_row)
    editedData(updated_data)
    dataVersion(dataVersion() + 1)
    clear_similarity_cache(confirm = FALSE)  # Non-interactive cache clear
    bayesianNetworkCreated(FALSE)  # Reset Bayesian network

    updateTextInput(session, "newActivity", value = "")
    updateTextInput(session, "newPressure", value = "")
    updateTextInput(session, "newConsequence", value = "")

    notify_success("🔗 Activity chain added with Bayesian network support!", duration = 3)
  })

  # Enhanced debug info
  output$debugInfo <- renderText({
    data <- getCurrentData()
    if (!is.null(data)) {
      paste("✅ Loaded:", nrow(data), "rows,", ncol(data), "columns - Enhanced bowtie structure with Bayesian network support")
    } else {
      "No enhanced data loaded"
    }
  })

  # =============================================================================
  # BOWTIE VISUALIZATION (Handled by bowtie_visualization_module)
  # =============================================================================
  # NOTE: All bowtie visualization code has been moved to server_modules/bowtie_visualization_module.R:
  # - filtered_problem_data reactive
  # - cached_bowtie_nodes reactive
  # - cached_bowtie_edges reactive
  # - output$bowtieNetwork (visNetwork visualization)
  # - output$riskMatrix (plotly risk matrix)
  # - output$riskStats (risk statistics table)
  #
  # Reactive values are available via: filtered_problem_data, cached_bowtie_nodes, cached_bowtie_edges

  # =============================================================================
  # EXPORT HANDLERS (Handled by export_module)
  # =============================================================================
  # NOTE: All download handlers for bowtie diagrams are now in export_module.R:
  # - downloadBowtie (HTML)
  # - downloadBowtieJPEG
  # - downloadBowtiePNG
  # - downloadData (CSV)
  # - downloadExcel
  #
  # Removed duplicate code that was conflicting with module

  # =============================================================================
  # Link Risk Assessment (Handled by link_risk_module)
  # =============================================================================
  # NOTE: All link risk assessment logic moved to server_modules/link_risk_module.R

  # =============================================================================
  # Vocabulary Management (Handled by vocabulary_server_module)
  # =============================================================================
  # NOTE: All vocabulary management logic moved to server_modules/vocabulary_server_module.R

  # =============================================================================
  # AI-Powered Vocabulary Analysis
  # --- MOVED TO: server_modules/ai_analysis_module.R ---
  # Module initialized at top of server function as: ai_module
  # All outputs handled by module:
  # - output$aiAnalysisComplete, output$ai_summary, output$ai_connections_table
  # - output$ai_network, output$ai_connection_summary, output$ai_connection_plot
  # - output$ai_recommendations, output$causal_paths, output$causal_structure
  # - output$key_drivers, output$key_outcomes
  # =============================================================================

  # NOTE: The following code has been removed (400+ lines moved to module):
  # - ai_analysis_results reactiveVal
  # - observeEvent(input$run_ai_analysis) handler
  # - All 13 output renderers for AI analysis
  # See ai_analysis_module.R for full implementation

  # Guided Workflow Server Logic
  guided_workflow_state <- guided_workflow_server(
    "guided_workflow",
    vocabulary_data = vocabulary_data,
    lang = lang,
    ai_enabled = reactive({
      # Explicitly check - only TRUE if checkbox is checked
      # NULL, NA, FALSE all treated as disabled
      result <- !is.null(input$ai_suggestions_enabled) && isTRUE(input$ai_suggestions_enabled)
      if (getOption("bowtie.verbose", FALSE)) {
        bowtie_log("[SERVER] AI enabled reactive:", input$ai_suggestions_enabled, "→", result, level = "debug")
      }
      result
    }),
    ai_methods = reactive({
      methods <- c()
      if (isTRUE(input$ai_method_semantic)) methods <- c(methods, "jaccard")
      if (isTRUE(input$ai_method_keyword)) methods <- c(methods, "keyword")
      if (isTRUE(input$ai_method_causal)) methods <- c(methods, "causal")
      if (length(methods) == 0) methods <- "jaccard"  # Default
      methods
    }),
    ai_max_suggestions = reactive({ as.integer(input$ai_max_suggestions %||% 5) })
  )

  # React to workflow completion - only when actually completed (step 8)
  observeEvent(guided_workflow_state()$workflow_complete, {
    req(guided_workflow_state()$workflow_complete)  # Only proceed if not NULL/FALSE
    state <- guided_workflow_state()

    # Enhanced validation: only trigger if genuinely completed
    if (!is.null(state) &&
        isTRUE(state$workflow_complete) &&  # Use isTRUE for safer boolean check
        !is.null(state$current_step) &&
        state$current_step >= 8 &&
        length(state$completed_steps) >= 7) {  # Must have completed at least 7 steps

      notify_success("🎉 Bowtie workflow completed successfully!", duration = 5)

      # Auto-switch to visualization tab (bs4Dash uses updateTabItems)
      updateTabItems(session, "sidebar_menu", selected = "bowtie")

      if (getOption("bowtie.verbose", FALSE)) {
        bowtie_log("Genuine workflow completion triggered from step", state$current_step, level = "debug")
        bowtie_log("  Completed steps:", paste(state$completed_steps, collapse = ", "), level = "debug")
      }
    } else {
      if (getOption("bowtie.verbose", FALSE)) {
        bowtie_log("Prevented premature workflow completion trigger:", level = "debug")
        bowtie_log("  Step:", state$current_step %||% "unknown", level = "debug")
        bowtie_log("  Complete flag:", state$workflow_complete %||% "unknown", level = "debug")
        bowtie_log("  Completed steps:", length(state$completed_steps %||% c()), level = "debug")
      }
    }
  }, ignoreInit = TRUE)  # Ignore initial reactive trigger

  # Automatic data integration: Watch for exported workflow data
  # Use ignoreNULL=FALSE to ensure trigger fires even when value changes from NULL
  observeEvent(guided_workflow_state()$converted_main_data, {
    workflow_state <- guided_workflow_state()
    exported_data <- workflow_state$converted_main_data

    if (!is.null(exported_data) && is.data.frame(exported_data) && nrow(exported_data) > 0) {
      log_info("Loading guided workflow data into main application...")
      log_debug(paste("Data rows:", nrow(exported_data)))
      log_debug(paste("Data columns:", paste(names(exported_data), collapse = ", ")))

      # Load the converted data into main application reactive values
      currentData(exported_data)
      editedData(exported_data)
      envDataGenerated(TRUE)
      hasData(TRUE)  # Enable menu items

      # Update data version for reactive triggers
      dataVersion(dataVersion() + 1)

      # Update problem selection choices for bowtie diagram
      problem_choices <- unique(exported_data$Central_Problem)
      log_debug(paste("Central problems:", paste(problem_choices, collapse = ", ")))
      updateSelectInput(session, "selectedProblem", choices = problem_choices, selected = problem_choices[1])
      updateSelectInput(session, "bayesianProblem", choices = problem_choices, selected = problem_choices[1])

      notify_success(paste("Successfully loaded", nrow(exported_data),
              "bowtie scenarios from guided workflow!"), duration = 5)

      # Auto-switch to the bowtie visualization tab (bs4Dash uses updateTabItems)
      updateTabItems(session, "sidebar_menu", selected = "bowtie")

      log_success("Guided workflow data integration complete")
    }
  }, ignoreNULL = FALSE, ignoreInit = TRUE)

  # Additional watcher for workflow completion to ensure data loads
  observeEvent(guided_workflow_state()$workflow_complete, {
    state <- guided_workflow_state()
    if (isTRUE(state$workflow_complete) && !is.null(state$converted_main_data)) {
      exported_data <- state$converted_main_data
      if (is.data.frame(exported_data) && nrow(exported_data) > 0) {
        # Ensure data is loaded even if the converted_main_data observer didn't fire
        if (is.null(currentData()) || nrow(currentData()) == 0) {
          log_info("[Backup] Loading workflow data on completion...")
          currentData(exported_data)
          editedData(exported_data)
          envDataGenerated(TRUE)
          hasData(TRUE)  # Enable menu items
          dataVersion(dataVersion() + 1)

          problem_choices <- unique(exported_data$Central_Problem)
          updateSelectInput(session, "selectedProblem", choices = problem_choices, selected = problem_choices[1])
          updateSelectInput(session, "bayesianProblem", choices = problem_choices, selected = problem_choices[1])
        }
        # Always ensure hasData is true if we have valid data
        if (!hasData()) {
          hasData(TRUE)
        }
      }
    }
  }, ignoreInit = TRUE)

  # NOTE: Theme apply handlers (applyTheme, applyCustomTheme) are now in theme_module.R

  # ============================================================================
  # TRANSLATION SYSTEM - Dynamic UI Rendering
  # ============================================================================

  # Main header translations
  output$app_title_text <- renderUI({
    t("app_title", lang())
  })
  
  output$app_subtitle_text <- renderUI({
    t("app_subtitle", lang())
  })
  
  # Data Input tab translations
  output$tab_data_input_title <- renderUI({
    tagList(icon("upload"), t("tab_data_input", lang()))
  })

  output$tab_guided_creation_title <- renderUI({
    tagList(icon("magic"), "🧙 ", t("tab_guided_creation", lang()))
  })

  # =============================================================================
  # LINK REVIEW TAB (Handled by link_risk_module)
  # =============================================================================
  # NOTE: All link review and risk analysis code moved to server_modules/link_risk_module.R

  output$data_input_options_header <- renderUI({
    tagList(icon("database"), t("data_input_options", lang()))
  })
  
  # Render file input with translated text
  output$file_input_ui <- renderUI({
    fileInput("file",
              label = t("data_upload_option1_label", lang()),
              accept = c(".xlsx", ".xls"),
              buttonLabel = t("data_upload_button_label", lang()),
              placeholder = t("data_upload_placeholder", lang()))
  })

  # Render Settings Language Section
  output$settings_language_section <- renderUI({
    current_lang <- lang()
    
    div(class = "mb-3",
      h6(tagList(icon("language"), " ", t("language_settings", current_lang)), class = "text-primary"),
      fluidRow(
        column(3, selectInput("app_language", t("select_language", current_lang),
                            choices = c("English" = "en", "Français" = "fr"),
                            selected = currentLanguage())),
        column(3,
          div(class = "mt-4",
            actionButton("applyLanguage",
                       label = as.character(t("apply_language", current_lang)),
                       icon = icon("check"),
                       class = "btn-primary")
          )
        )
      )
    )
  })

  # Render Settings Theme Header
  output$settings_theme_header <- renderUI({
    current_lang <- lang()
    h6(tagList(icon("palette"), " ", t("theme_settings", current_lang)), class = "text-primary")
  })

  # Render Data Input Card Headers
  output$data_input_header <- renderUI({
    current_lang <- lang()
    tagList(icon("database"), t("data_input_options", current_lang))
  })

  output$data_structure_header <- renderUI({
    current_lang <- lang()
    tagList(icon("info-circle"), t("data_structure_title", current_lang))
  })

  # Render Data Input Tab Content
  output$data_upload_option1_title <- renderUI({
    current_lang <- lang()
    h5(tagList(icon("file-excel"), t("data_upload_option1", current_lang)))
  })

  output$data_upload_option2_title <- renderUI({
    current_lang <- lang()
    h5(tagList(icon("leaf"), t("data_upload_option2", current_lang)))
  })

  output$data_option2_desc <- renderUI({
    current_lang <- lang()
    div(
      p(t("data_option2_description", current_lang)),
      tags$ul(class = "small text-muted",
        tags$li(paste("📊", t("complete_vocabulary_coverage", current_lang))),
        tags$li(paste("🛡️", t("multiple_controls_per_pressure", current_lang))),
        tags$li(paste("🔗", t("pressure_linked_measures", current_lang)))
      )
    )
  })

  output$bowtie_elements_section <- renderUI({
    current_lang <- lang()
    data <- getCurrentData()
    
    # Count elements if data is loaded
    if (!is.null(data)) {
      counts <- list(
        activities = length(unique(data$Activity)),
        pressures = length(unique(data$Pressure)),
        controls = length(unique(data$Preventive_Control)),
        escalations = if("Escalation_Factor" %in% names(data)) length(unique(data$Escalation_Factor)) else 0,
        problems = length(unique(data$Central_Problem)),
        mitigations = length(unique(data$Protective_Mitigation)),
        consequences = length(unique(data$Consequence))
      )
    } else {
      counts <- list(activities = 0, pressures = 0, controls = 0, escalations = 0, 
                     problems = 0, mitigations = 0, consequences = 0)
    }
    
    div(
      h6(tagList(icon("list"), t("bowtie_elements", current_lang))),
      p(t("data_structure_description", current_lang)),
      tags$ul(class = "mb-2",
        tags$li(tagList(icon("play", class = "text-primary"),
                       strong(paste0(t("column_activity", current_lang), ":")), " ",
                       t("column_description_activity", current_lang),
                       if(counts$activities > 0) tags$span(class = "badge bg-primary ms-2", counts$activities))),
        tags$li(tagList(icon("triangle-exclamation", class = "text-danger"),
                       strong(paste0(t("column_pressure", current_lang), ":")), " ",
                       t("column_description_pressure", current_lang),
                       if(counts$pressures > 0) tags$span(class = "badge bg-danger ms-2", counts$pressures))),
        tags$li(tagList(icon("shield-halved", class = "text-success"),
                       strong(paste0(t("column_preventive_control", current_lang), ":")), " ",
                       t("column_description_preventive", current_lang),
                       if(counts$controls > 0) tags$span(class = "badge bg-success ms-2", counts$controls))),
        tags$li(tagList(icon("exclamation-triangle", class = "text-warning"),
                       strong(paste0(t("column_escalation_factor", current_lang), ":")), " ",
                       "Factors that weaken controls",
                       if(counts$escalations > 0) tags$span(class = "badge bg-warning ms-2", counts$escalations))),
        tags$li(tagList(icon("radiation", class = "text-danger"),
                       strong(paste0(t("column_central_problem", current_lang), ":")), " ",
                       t("column_description_central", current_lang),
                       if(counts$problems > 0) tags$span(class = "badge bg-danger ms-2", counts$problems))),
        tags$li(tagList(icon("shield", class = "text-info"),
                       strong(paste0(t("column_protective_mitigation", current_lang), ":")), " ",
                       t("column_description_protective", current_lang),
                       if(counts$mitigations > 0) tags$span(class = "badge bg-info ms-2", counts$mitigations))),
        tags$li(tagList(icon("burst", class = "text-warning"),
                       strong(paste0(t("column_consequence", current_lang), ":")), " ",
                       t("column_description_consequence", current_lang),
                       if(counts$consequences > 0) tags$span(class = "badge bg-warning ms-2", counts$consequences)))
      )
    )
  })

  # NOTE: Vocabulary statistics outputs moved to vocabulary_server_module.R

  # Sidebar Menu Badge Outputs
  output$badge_data_table <- renderText({
    data <- getCurrentData()
    if (!is.null(data) && nrow(data) > 0) {
      return(as.character(nrow(data)))
    }
    return("")
  })

  output$badge_guided <- renderText({
    # Check if workflow is active
    if (exists("workflow_state") && !is.null(workflow_state$current_step)) {
      current_step <- workflow_state$current_step
      if (current_step > 0 && current_step <= 8) {
        return(paste0("Step ", current_step))
      }
    }
    return("")
  })

  output$badge_link_review <- renderText({
    data <- getCurrentData()
    if (!is.null(data) && nrow(data) > 0) {
      # Count unique links (Activity-Pressure pairs)
      links <- length(unique(paste(data$Activity, data$Pressure, sep = "|")))
      return(as.character(links))
    }
    return("")
  })

  # NOTE: badge_vocabulary output moved to vocabulary_server_module.R

  # NOTE: Dashboard vocabulary infoboxes moved to vocabulary_server_module.R

  # Loaded Data Statistics InfoBoxes
  output$data_scenarios_infobox <- renderUI({
    data <- getCurrentData()
    req(data)

    total_rows <- nrow(data)

    bs4InfoBox(
      title = "Total Scenarios",
      value = total_rows,
      subtitle = "Complete bowtie pathways loaded",
      icon = icon("chart-line"),
      iconElevation = 2,
      color = "primary",
      gradient = TRUE,
      width = 12,
      fill = TRUE
    )
  })

  output$data_elements_infobox <- renderUI({
    data <- getCurrentData()
    req(data)

    # Count unique elements in loaded data
    counts <- list(
      activities = length(unique(data$Activity)),
      pressures = length(unique(data$Pressure)),
      controls = length(unique(data$Preventive_Control)),
      consequences = length(unique(data$Consequence))
    )

    # Get vocabulary totals for comparison
    vocab_totals <- list(
      activities = if (!is.null(vocabulary_data$activities)) nrow(vocabulary_data$activities) else 0,
      pressures = if (!is.null(vocabulary_data$pressures)) nrow(vocabulary_data$pressures) else 0,
      controls = if (!is.null(vocabulary_data$controls)) nrow(vocabulary_data$controls) else 0,
      consequences = if (!is.null(vocabulary_data$consequences)) nrow(vocabulary_data$consequences) else 0
    )

    # Calculate total used vs available
    total_used <- counts$activities + counts$pressures + counts$controls + counts$consequences
    total_available <- vocab_totals$activities + vocab_totals$pressures + vocab_totals$controls + vocab_totals$consequences
    usage_pct <- if (total_available > 0) round((total_used / total_available) * 100, 1) else 0

    bs4InfoBox(
      title = "Elements Used",
      value = total_used,
      subtitle = sprintf("%d of %d available (%s%%)", total_used, total_available, usage_pct),
      icon = icon("layer-group"),
      iconElevation = 2,
      color = "success",
      gradient = TRUE,
      width = 12,
      fill = TRUE
    )
  })

  # Render Bowtie Diagram Tab Elements
  output$bowtie_legend_help <- renderUI({
    current_lang <- lang()
    div(class = "alert alert-info mb-3",
      h6(tagList(icon("info-circle"), t("bowtie_legend_title", current_lang))),
      tags$small(
        tags$ul(class = "mb-2",
          tags$li(tags$strong(t("bowtie_legend_activities", current_lang)), " ", t("bowtie_legend_activities_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_pressures", current_lang)), " ", t("bowtie_legend_pressures_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_preventive", current_lang)), " ", t("bowtie_legend_preventive_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_escalation", current_lang)), " ", t("bowtie_legend_escalation_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_central", current_lang)), " ", t("bowtie_legend_central_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_protective", current_lang)), " ", t("bowtie_legend_protective_desc", current_lang)),
          tags$li(tags$strong(t("bowtie_legend_consequences", current_lang)), " ", t("bowtie_legend_consequences_desc", current_lang))
        ),
        tags$p(class = "mb-0",
          tags$strong(t("bowtie_interaction_title", current_lang)), " ", t("bowtie_interaction_desc", current_lang)
        )
      )
    )
  })

  output$bowtie_no_data_message <- renderUI({
    current_lang <- lang()
    div(class = "text-center p-5",
      icon("upload", class = "fa-3x text-muted mb-3"),
      h4(t("bowtie_upload_prompt", current_lang), class = "text-muted"),
      p(t("bowtie_upload_desc", current_lang), class = "text-muted")
    )
  })

  # Render Bayesian Network Tab Elements
  output$bayesian_controls_header <- renderUI({
    current_lang <- lang()
    tagList(icon("brain"), t("bayesian_controls_title", current_lang))
  })

  output$bayesian_network_creation_section <- renderUI({
    current_lang <- lang()
    div(
      h6(tagList(icon("cogs"), t("bayesian_network_creation", current_lang))),
      selectInput("bayesianProblem", t("bayesian_select_problem", current_lang), choices = NULL),
      div(class = "d-grid mb-3",
        actionButton("createBayesianNetwork",
          tagList(icon("brain"), t("bayesian_create_button", current_lang)),
          class = "btn-success"
        )
      )
    )
  })

  # Evidence UI for Bayesian inference (referenced by uiOutput("bayesian_evidence_ui"))
  output$bayesian_evidence_ui <- renderUI({
    current_lang <- lang()

    # Build choices dynamically
    activity_choices <- setNames(c("", "Present", "Absent"),
                                 c("Not Set", "Present", "Absent"))

    pressure_choices <- setNames(c("", "Low", "Medium", "High"),
                                c("Not Set", "Low", "Medium", "High"))

    control_choices <- setNames(c("", "Effective", "Partial", "Failed"),
                               c("Not Set", "Effective", "Partial", "Failed"))

    query_choices <- setNames(c("Consequence_Level", "Problem_Severity", "Escalation_Level"),
                             c("Consequence Level", "Problem Severity", "Escalation Level"))

    div(
      # Section 1: Set Evidence
      div(class = "mb-4",
        h6(tagList(icon("eye"), " Set Evidence"), class = "text-primary border-bottom pb-2"),
        p(class = "text-muted small mb-3", "What we observe:"),

        div(class = "mb-3",
          tags$label("Activity Level:", class = "form-label fw-bold"),
          selectInput("evidenceActivity", NULL,
            choices = activity_choices,
            width = "100%")
        ),

        div(class = "mb-3",
          tags$label("Pressure Level:", class = "form-label fw-bold"),
          selectInput("evidencePressure", NULL,
            choices = pressure_choices,
            width = "100%")
        ),

        div(class = "mb-3",
          tags$label("Control Effectiveness:", class = "form-label fw-bold"),
          selectInput("evidenceControl", NULL,
            choices = control_choices,
            width = "100%")
        )
      ),

      hr(),

      # Section 2: Query Outcomes
      div(class = "mb-4",
        h6(tagList(icon("crosshairs"), " Query"), class = "text-primary border-bottom pb-2"),
        p(class = "text-muted small mb-3", "What we want to predict:"),

        tags$label("Select outcomes to predict:", class = "form-label fw-bold"),
        checkboxGroupInput("queryNodes", NULL,
          choices = query_choices,
          selected = c("Consequence_Level", "Problem_Severity", "Escalation_Level"))
      ),

      hr(),

      # Section 3: Risk Scenarios
      div(class = "mb-3",
        h6(tagList(icon("bolt"), " Risk Scenarios"), class = "text-primary border-bottom pb-2"),
        p(class = "text-muted small mb-2", "Quick presets:"),

        div(class = "d-grid gap-2",
          div(class = "btn-group btn-group-sm",
            actionButton("scenarioWorstCase",
              tagList(icon("exclamation-triangle"), " Worst Case"),
              class = "btn-outline-danger"),
            actionButton("scenarioBestCase",
              tagList(icon("shield-alt"), " Best Case"),
              class = "btn-outline-success")
          ),
          div(class = "btn-group btn-group-sm",
            actionButton("scenarioControlFailure",
              tagList(icon("times-circle"), " Control Failure"),
              class = "btn-outline-warning"),
            actionButton("scenarioBaseline",
              tagList(icon("undo"), " Reset"),
              class = "btn-outline-secondary")
          )
        )
      )
    )
  })

  output$bayesian_inference_section <- renderUI({
    current_lang <- lang()

    # Build choices dynamically
    activity_choices <- setNames(c("", "Present", "Absent"),
                                 c(t("evidence_not_set", current_lang),
                                   t("evidence_present", current_lang),
                                   t("evidence_absent", current_lang)))

    pressure_choices <- setNames(c("", "Low", "Medium", "High"),
                                c(t("evidence_not_set", current_lang),
                                  t("evidence_low", current_lang),
                                  t("evidence_medium", current_lang),
                                  t("evidence_high", current_lang)))

    control_choices <- setNames(c("", "Effective", "Partial", "Failed"),
                               c(t("evidence_not_set", current_lang),
                                 t("evidence_effective", current_lang),
                                 t("evidence_partial", current_lang),
                                 t("evidence_failed", current_lang)))

    query_choices <- setNames(c("Consequence_Level", "Problem_Severity", "Escalation_Level"),
                             c(t("bayesian_consequence_level", current_lang),
                               t("bayesian_problem_severity", current_lang),
                               t("bayesian_escalation_level", current_lang)))

    div(
      hr(),
      h6(tagList(icon("question-circle"), t("bayesian_inference_title", current_lang))),
      h6(t("bayesian_evidence_title", current_lang)),
      selectInput("evidenceActivity", t("bayesian_activity_level", current_lang),
        choices = activity_choices),
      selectInput("evidencePressure", t("bayesian_pressure_level", current_lang),
        choices = pressure_choices),
      selectInput("evidenceControl", t("bayesian_control_effectiveness", current_lang),
        choices = control_choices),
      h6(t("bayesian_query_title", current_lang)),
      checkboxGroupInput("queryNodes", t("bayesian_select_outcomes", current_lang),
        choices = query_choices,
        selected = c("Consequence_Level", "Problem_Severity")),
      div(class = "d-grid mb-3",
        actionButton("runInference",
          tagList(icon("play"), t("bayesian_run_inference", current_lang)),
          class = "btn-primary"
        )
      )
    )
  })

  output$bayesian_no_data_message <- renderUI({
    current_lang <- lang()
    div(class = "text-center p-3",
      icon("brain", class = "fa-3x text-muted mb-3"),
      h5(t("bayesian_load_data_first", current_lang), class = "text-muted"),
      p(t("bayesian_load_data_desc", current_lang), class = "text-muted")
    )
  })

  output$bayesian_network_how_to <- renderUI({
    current_lang <- lang()
    div(
      h6(t("bayesian_how_to_use", current_lang)),
      tags$ul(
        tags$li(t("bayesian_how_to_1", current_lang)),
        tags$li(t("bayesian_how_to_2", current_lang)),
        tags$li(t("bayesian_how_to_3", current_lang)),
        tags$li(t("bayesian_how_to_4", current_lang)),
        tags$li(t("bayesian_how_to_5", current_lang))
      )
    )
  })

  # Render Data Table Tab Elements
  output$data_table_header <- renderUI({
    current_lang <- lang()
    tagList(icon("table"), t("data_table_title", current_lang))
  })

  output$data_table_buttons <- renderUI({
    current_lang <- lang()
    div(
      actionButton("addRow", tagList(icon("plus"), t("data_table_add_row", current_lang)),
        class = "btn-success btn-sm me-2"),
      actionButton("deleteSelected", tagList(icon("trash"), t("data_table_delete_selected", current_lang)),
        class = "btn-danger btn-sm me-2"),
      actionButton("saveChanges", tagList(icon("save"), t("data_table_save_changes", current_lang)),
        class = "btn-primary btn-sm")
    )
  })

  output$data_table_no_data <- renderUI({
    current_lang <- lang()
    div(class = "text-center p-5",
      icon("table", class = "fa-3x text-muted mb-3"),
      h4(t("data_table_no_data", current_lang), class = "text-muted"),
      p(t("data_table_upload_prompt", current_lang), class = "text-muted")
    )
  })

  # Render Risk Matrix Tab Elements
  output$risk_matrix_help <- renderUI({
    current_lang <- lang()
    div(class = "alert alert-info mb-3",
      h6(tagList(icon("info-circle"), t("risk_matrix_guide_title", current_lang))),
      tags$small(
        tags$p(tags$strong(t("risk_matrix_understanding", current_lang))),
        tags$ul(
          tags$li(t("risk_matrix_axes", current_lang)),
          tags$li(t("risk_matrix_color_zones", current_lang))
        ),
        tags$p(tags$strong(t("risk_matrix_interpretation", current_lang))),
        tags$ul(
          tags$li(t("risk_matrix_green", current_lang)),
          tags$li(t("risk_matrix_yellow", current_lang)),
          tags$li(t("risk_matrix_orange", current_lang)),
          tags$li(t("risk_matrix_red", current_lang))
        )
      )
    )
  })

  # NOTE: About header, about content, and all detailed help content moved to help_module.R

  # Observer to update scenario select input when language changes
  observe({
    current_lang <- lang()
    updateSelectInput(session, "data_scenario_template",
                     label = t("select_scenario", current_lang),
                     choices = get_scenario_choices(current_lang, include_blank = TRUE))
  })

  # =============================================================================
  # VOCABULARY TAB (Handled by vocabulary_server_module)
  # =============================================================================
  # NOTE: All vocabulary tab outputs moved to server_modules/vocabulary_server_module.R

  # =============================================================================
  # DATA TABLE TAB
  # =============================================================================

  # Render main data table
  output$data_table <- DT::renderDataTable({
    data <- getCurrentData()

    if (is.null(data) || nrow(data) == 0) {
      # Return empty table with message
      return(datatable(
        data.frame(Message = "No data loaded. Please upload data or generate environmental scenarios from the Data Upload tab."),
        options = list(dom = 't', ordering = FALSE),
        rownames = FALSE
      ))
    }

    # Render the complete bowtie data table
    datatable(
      data,
      options = list(
        pageLength = 25,
        lengthMenu = c(10, 25, 50, 100, 200),
        order = list(list(0, 'asc')),
        searchHighlight = TRUE,
        scrollX = TRUE,
        dom = 'Blfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
        columnDefs = list(
          list(className = 'dt-center', targets = '_all')
        )
      ),
      rownames = FALSE,
      filter = 'top',
      selection = 'multiple',
      class = 'cell-border stripe hover'
    ) %>%
      formatStyle(
        columns = colnames(data),
        fontSize = '12px'
      ) %>%
      {
        # Conditionally add highlighting for Central_Problem column if it exists
        if ("Central_Problem" %in% colnames(data)) {
          formatStyle(., 'Central_Problem',
                     backgroundColor = '#fff3cd',
                     fontWeight = 'bold')
        } else {
          .
        }
      }
  })

  # Refresh table button observer
  observeEvent(input$refreshTable, {
    # Just trigger a reactive invalidation to refresh the table
    dataVersion(dataVersion() + 1)

    notify_info("Data table refreshed successfully!", duration = 3)
  })

  # Dropdown menu handlers for Data Table box
  observeEvent(input$refresh_data_table_menu, {
    dataVersion(dataVersion() + 1)
    notify_info("Data table refreshed!", duration = 3)
  })

  observeEvent(input$export_csv_menu, {
    # Trigger the existing download button
    shinyjs::click("downloadData")
  })

  observeEvent(input$export_excel_menu, {
    # Trigger the existing download button
    shinyjs::click("downloadExcel")
  })

  observeEvent(input$table_settings_menu, {
    notify_info("Table settings feature coming soon!", duration = 3)
  })

  # NOTE: Vocabulary dropdown menu handlers moved to vocabulary_server_module.R

  # Dropdown menu handlers for Bowtie Diagram box
  observeEvent(input$refresh_bowtie_menu, {
    # Re-render the bowtie network
    if (!is.null(input$selectedProblem)) {
      notify_info("Bowtie diagram refreshed!", duration = 3)
    } else {
      notify_warning("Please select a central problem first", duration = 3)
    }
  })

  observeEvent(input$fit_bowtie_menu, {
    # Trigger visNetwork fit command via JavaScript
    session$sendCustomMessage("fitBowtieNetwork", TRUE)
    notify_info("Diagram fitted to screen!", duration = 2)
  })

  # Bowtie diagram export menu items - trigger existing download handlers via JS
  observeEvent(input$export_bowtie_png_menu, {
    session$sendCustomMessage("triggerDownload", "downloadBowtiePNG")
  })

  observeEvent(input$export_bowtie_svg_menu, {
    # SVG not directly supported - use HTML export as alternative
    session$sendCustomMessage("triggerDownload", "downloadBowtie")
    notify_info("SVG not available - downloading interactive HTML instead", duration = 3)
  })

  # Dropdown menu handlers for Bayesian Network box
  observeEvent(input$refresh_bayesian_menu, {
    if (!is.null(bayesian_network$network)) {
      notify_info("Bayesian network refreshed!", duration = 3)
    } else {
      notify_warning("Please create a Bayesian network first", duration = 3)
    }
  })

  observeEvent(input$fit_bayesian_menu, {
    # Trigger visNetwork fit command via JavaScript
    session$sendCustomMessage("fitBayesianNetwork", TRUE)
    notify_info("Network fitted to screen!", duration = 2)
  })

  # NOTE: Download handlers (downloadData, downloadExcel) are now in export_module.R

  # =============================================================================
  # REPORT GENERATION (Handled by report_generation_module)
  # =============================================================================
  # Report generation is handled by server_modules/report_generation_module.R
  # The module provides:
  #   - output$downloadPDF, output$downloadWord, output$downloadHTML handlers
  #   - output$reportPreview renderer
  #   - report_generated and report_content reactive values
  # Manual download handlers (download_manual, download_manual_fr) are below.

  # NOTE: Manual download handlers moved to server_modules/help_module.R
  # NOTE: perform_inference_simple function moved to server_modules/bayesian_module.R

}
