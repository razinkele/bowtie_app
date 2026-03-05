# =============================================================================
# Data Management Module
# =============================================================================
# Purpose: Handles file uploads, data loading, validation, and generation
# Dependencies: readxl, openxlsx, utils.R
# =============================================================================

#' Validate file is actually an Excel file using magic bytes (server-side security)
#' @param file_path Path to the uploaded file
#' @return list(valid = TRUE/FALSE, error = error message if invalid)
validate_excel_file <- function(file_path) {
  tryCatch({
    # Check file exists
    if (!file.exists(file_path)) {
      return(list(valid = FALSE, error = "File does not exist"))
    }

    # Check file size (prevent DoS via huge files)
    file_size <- file.info(file_path)$size
    max_size <- if (exists("MAX_UPLOAD_FILE_SIZE")) MAX_UPLOAD_FILE_SIZE else 50 * 1024 * 1024
    if (file_size > max_size) {
      return(list(valid = FALSE, error = paste("File too large. Maximum size:", max_size / (1024 * 1024), "MB")))
    }

    # Check extension (case-insensitive)
    ext <- tolower(tools::file_ext(file_path))
    if (!ext %in% c("xlsx", "xls")) {
      return(list(valid = FALSE, error = "Invalid file extension. Only .xlsx and .xls files are allowed."))
    }

    # Read first bytes and validate magic number
    con <- file(file_path, "rb")
    on.exit(close(con), add = TRUE)
    first_bytes <- readBin(con, "raw", n = 8)

    if (length(first_bytes) < 4) {
      return(list(valid = FALSE, error = "File is too small to be a valid Excel file"))
    }

    # Check for XLSX (ZIP/PK signature)
    is_xlsx <- identical(first_bytes[1:4], as.raw(c(0x50, 0x4B, 0x03, 0x04)))

    # Check for XLS (OLE2 signature)
    is_xls <- identical(first_bytes[1:4], as.raw(c(0xD0, 0xCF, 0x11, 0xE0)))

    if (!is_xlsx && !is_xls) {
      return(list(valid = FALSE, error = "File content does not match Excel format. Possible security risk detected."))
    }

    # Verify extension matches detected type
    if (ext == "xlsx" && !is_xlsx) {
      return(list(valid = FALSE, error = "File extension .xlsx does not match file content (appears to be .xls format)"))
    }
    if (ext == "xls" && !is_xls) {
      return(list(valid = FALSE, error = "File extension .xls does not match file content (appears to be .xlsx format)"))
    }

    return(list(valid = TRUE, error = NULL))
  }, error = function(e) {
    return(list(valid = FALSE, error = paste("File validation error:", e$message)))
  })
}

#' Initialize data management module server logic
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param lang Reactive language value from language module
#' @return List containing data reactive values and helper functions
#' @export
data_management_module_server <- function(input, output, session, lang = reactive("en")) {

  # Optimized reactive values using reactiveVal for single values
  currentData <- reactiveVal(NULL)
  editedData <- reactiveVal(NULL)
  sheets <- reactiveVal(NULL)
  envDataGenerated <- reactiveVal(FALSE)
  selectedRows <- reactiveVal(NULL)
  dataVersion <- reactiveVal(0)  # For cache invalidation

  # UI state tracking for empty states and accessibility
  hasData <- reactiveVal(FALSE)
  lastNotification <- reactiveVal(NULL)  # For aria-live regions

  # Optimized data retrieval with caching
  getCurrentData <- reactive({
    edited <- editedData()
    if (!is.null(edited)) edited else currentData()
  })

  # File upload handling with server-side validation (Issue #2 fix)
  observeEvent(input$file, {
    req(input$file)

    # SERVER-SIDE FILE VALIDATION (security fix)
    # Validates: file existence, size limits, extension, and magic bytes
    validation_result <- validate_excel_file(input$file$datapath)

    if (!validation_result$valid) {
      notify_error(paste("❌ File validation failed:", validation_result$error), duration = 8)
      bowtie_log(paste("File upload rejected:", validation_result$error, "- File:", input$file$name), level = "warn")
      return()
    }

    tryCatch({
      sheet_names <- excel_sheets(input$file$datapath)
      sheets(sheet_names)
      updateSelectInput(session, "sheet", choices = sheet_names, selected = sheet_names[1])
      bowtie_log(paste("File validated and loaded:", input$file$name), level = "info")
    }, error = function(e) {
      notify_error(t("notify_error_reading_file", lang()))
      bowtie_log(paste("Error reading Excel file:", e$message), level = "error")
    })
  })

  output$fileUploaded <- reactive(!is.null(input$file))
  outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)

  # Enhanced data loading with validation
  observeEvent(input$loadData, {
    req(input$file, input$sheet)

    tryCatch({
      data <- read_excel(input$file$datapath, sheet = input$sheet)
      validation <- validate_data_columns(data)

      if (!validation$valid) {
        notify_error(paste("Missing required columns:",
                              paste(validation$missing, collapse = ", ")))
        return()
      }

      data <- add_default_columns(data)
      currentData(data)
      editedData(data)
      dataVersion(dataVersion() + 1)
      hasData(TRUE)  # Track that data is loaded
      clear_similarity_cache(confirm = FALSE)  # Clear cache when new data is loaded (non-interactive)

      updateSelectInput(session, "selectedProblem", choices = unique(data$Central_Problem))
      updateSelectInput(session, "bayesianProblem", choices = unique(data$Central_Problem))

      # Improved success notification
      lastNotification(paste("✅", t("notify_data_loaded", lang())))
      notify_success(paste("✅", t("notify_data_loaded", lang())), duration = 3)

      # Automatically navigate to Bowtie tab to show the diagram
      updateTabItems(session, "sidebar_menu", selected = "bowtie")

      # Show navigation notification
      notify_info("📊 Navigating to Bowtie Diagram...", duration = 2)

    }, error = function(e) {
      hasData(FALSE)
      lastNotification(paste("❌ Error loading data:", e$message))
      notify_error(paste("❌ Error loading data:", e$message), duration = 8)
    })
  })

  # Generate data using standardized vocabularies with multiple controls
  observeEvent(input$generateMultipleControls, {
    scenario_key <- input$data_scenario_template

    scenario_msg <- if (!is.null(scenario_key) && scenario_key != "") {
      paste0("🔄 Generating data with MULTIPLE CONTROLS for scenario: ", scenario_key)
    } else {
      "🔄 Generating data with MULTIPLE PREVENTIVE CONTROLS per pressure..."
    }

    notify_info(scenario_msg, duration = 3)

    tryCatch({
      multiple_controls_data <- generate_environmental_data_with_multiple_controls(scenario_key)
      currentData(multiple_controls_data)
      editedData(multiple_controls_data)
      envDataGenerated(TRUE)
      hasData(TRUE)  # Enable menu items when data is generated
      dataVersion(dataVersion() + 1)
      clear_similarity_cache(confirm = FALSE)  # Non-interactive cache clear

      problem_choices <- unique(multiple_controls_data$Central_Problem)
      updateSelectInput(session, "selectedProblem", choices = problem_choices, selected = problem_choices[1])
      updateSelectInput(session, "bayesianProblem", choices = problem_choices, selected = problem_choices[1])

      # Show detailed statistics
      unique_pressures <- length(unique(multiple_controls_data$Pressure))
      unique_controls <- length(unique(multiple_controls_data$Preventive_Control))
      total_entries <- nrow(multiple_controls_data)

      notify_success(paste("✅ Generated", total_entries, "entries with", unique_controls,
              "preventive controls across", unique_pressures, "environmental pressures!"), duration = 5)

      # Automatically navigate to Bowtie tab to show the diagram
      updateTabItems(session, "sidebar_menu", selected = "bowtie")

      # Show navigation notification
      notify_info("📊 Navigating to Bowtie Diagram...", duration = 2)

    }, error = function(e) {
      hasData(FALSE)  # Ensure menu items stay disabled on error
      notify_error(paste("❌ Error generating multiple controls data:", e$message), duration = 5)
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

  # Output for conditional rendering based on data availability
  output$hasData <- reactive({ hasData() })
  outputOptions(output, "hasData", suspendWhenHidden = FALSE)

  # Enhanced data info with details
  output$dataInfo <- renderText({
    data <- getCurrentData()
    req(data)

    # Count unique elements in the bowtie
    counts <- list(
      activities = length(unique(data$Activity)),
      pressures = length(unique(data$Pressure)),
      controls = length(unique(data$Preventive_Control)),
      escalations = if("Escalation_Factor" %in% names(data)) length(unique(data$Escalation_Factor)) else 0,
      problems = length(unique(data$Central_Problem)),
      mitigations = length(unique(data$Protective_Mitigation)),
      consequences = length(unique(data$Consequence)),
      total_rows = nrow(data)
    )

    sprintf("Total Scenarios: %d\nActivities: %d | Pressures: %d | Controls: %d\nEscalations: %d | Problems: %d | Mitigations: %d | Consequences: %d",
            counts$total_rows, counts$activities, counts$pressures, counts$controls,
            counts$escalations, counts$problems, counts$mitigations, counts$consequences)
  })

  # Enhanced download handler
  output$downloadSample <- downloadHandler(
    filename = function() paste("enhanced_environmental_bowtie_", Sys.Date(), ".xlsx", sep = ""),
    content = function(file) {
      data <- getCurrentData()
      req(data)
      openxlsx::write.xlsx(data, file, rowNames = FALSE)
    }
  )

  # Return module API
  list(
    currentData = currentData,
    editedData = editedData,
    getCurrentData = getCurrentData,
    hasData = hasData,
    envDataGenerated = envDataGenerated,
    selectedRows = selectedRows,
    dataVersion = dataVersion,
    lastNotification = lastNotification,
    sheets = sheets
  )
}
