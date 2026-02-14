# =============================================================================
# Local Storage Module
# =============================================================================
# Purpose: Allow users to select a local folder on their computer for storing
#          configurations, saves, and workflow progress when running from 
#          Shiny Server
# Dependencies: shiny, shinyFiles, jsonlite
# Version: 1.0.0
# Date: January 2026
# =============================================================================

# =============================================================================
# DEPRECATED: Namespaced module version (NOT USED)
# The app uses local_storage_server() (non-namespaced, defined below at ~line 688)
# called from server.R. This namespaced version is kept for reference only.
# =============================================================================

#' @deprecated Use local_storage_server() instead
local_storage_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h4(icon("folder-open"), " Local Storage Settings"),
    p(class = "text-muted small", 
      "Configure a local folder on your computer to store configurations and saves."),
    
    # Storage mode selection
    radioButtons(ns("storage_mode"),
                 "Storage Mode:",
                 choices = c(
                   "Browser (LocalStorage)" = "browser",
                   "Local Folder" = "local",
                   "Server Default" = "server"
                 ),
                 selected = "browser"),
    
    # Local folder selection (shown only when local mode selected)
    conditionalPanel(
      condition = sprintf("input['%s'] == 'local'", ns("storage_mode")),
      ns = ns,
      
      div(class = "local-folder-settings", style = "margin-left: 20px; margin-top: 10px;",
          
          # Folder selection button
          div(class = "form-group",
              tags$label("Select Storage Folder:"),
              div(class = "input-group",
                  # Text input showing selected path
                  textInput(ns("local_folder_path"), 
                            label = NULL,
                            value = "",
                            placeholder = "No folder selected...",
                            width = "100%"),
                  div(class = "input-group-append",
                      shinyDirButton(ns("select_folder"), 
                                     "Browse...",
                                     title = "Select folder for saving configurations",
                                     icon = icon("folder-open"),
                                     class = "btn-outline-primary")
                  )
              ),
              tags$small(class = "form-text text-muted",
                         "Choose a folder on your computer where saves will be stored.")
          ),
          
          # Create subfolder option
          checkboxInput(ns("create_subfolder"),
                        "Create 'bowtie_saves' subfolder",
                        value = TRUE),
          
          # Folder status indicator
          uiOutput(ns("folder_status")),
          
          br(),
          
          # Action buttons for local storage
          div(class = "btn-group btn-block",
              actionButton(ns("verify_folder"),
                           "Verify Folder",
                           icon = icon("check-circle"),
                           class = "btn-info btn-sm"),
              actionButton(ns("open_folder"),
                           "Open in Explorer",
                           icon = icon("external-link-alt"),
                           class = "btn-secondary btn-sm")
          ),
          
          br(),
          
          # Files in folder
          div(class = "card mt-3",
              div(class = "card-header bg-light",
                  icon("file-archive"), " Saved Files in Local Folder"),
              div(class = "card-body", style = "max-height: 200px; overflow-y: auto;",
                  uiOutput(ns("local_files_list"))
              )
          )
      )
    ),
    
    hr(),
    
    # Quick save/load buttons
    div(class = "btn-group btn-block mt-2",
        actionButton(ns("quick_save"),
                     "Quick Save",
                     icon = icon("save"),
                     class = "btn-success"),
        actionButton(ns("quick_load"),
                     "Quick Load",
                     icon = icon("folder-open"),
                     class = "btn-primary")
    ),
    
    # Hidden file input for loading
    fileInput(ns("load_file_input"),
              label = NULL,
              accept = c(".rds", ".json"),
              width = "0px"),
    tags$style(sprintf("#%s { display: none; }", ns("load_file_input")))
  )
}

#' @deprecated Use local_storage_server() instead
local_storage_module_server <- function(input, output, session,
                                         getCurrentData = NULL,
                                         getWorkflowState = NULL,
                                         lang = reactive("en")) {
  
  # Reactive values for local storage state
  storage_path <- reactiveVal(NULL)
  storage_verified <- reactiveVal(FALSE)
  storage_mode <- reactiveVal("browser")
  last_save_time <- reactiveVal(NULL)
  
  # Define available volumes for shinyFiles
  # This provides access to user's home directory and common locations
  volumes <- reactive({
    # Get user's home directory
    home_dir <- Sys.getenv("USERPROFILE")
    if (home_dir == "") home_dir <- Sys.getenv("HOME")
    if (home_dir == "") home_dir <- path.expand("~")
    
    # Define volumes based on OS
    if (.Platform$OS.type == "windows") {
      # Windows: Include common drives and user folders
      vols <- c(
        "Home" = home_dir,
        "Documents" = file.path(home_dir, "Documents"),
        "Desktop" = file.path(home_dir, "Desktop"),
        "Downloads" = file.path(home_dir, "Downloads")
      )
      
      # Add available drive letters
      for (drive in c("C", "D", "E", "F")) {
        drive_path <- paste0(drive, ":/")
        if (dir.exists(drive_path)) {
          vols <- c(vols, setNames(drive_path, paste0(drive, ":")))
        }
      }
    } else {
      # Linux/Mac
      vols <- c(
        "Home" = home_dir,
        "Root" = "/"
      )
    }
    
    # Filter to only existing directories
    vols[sapply(vols, dir.exists)]
  })
  
  # Initialize shinyFiles directory chooser
  # Note: roots must be a function that returns a named vector, not a reactive directly
  shinyDirChoose(input, "select_folder",
                 roots = function() volumes(),
                 filetypes = NULL,
                 restrictions = NULL,
                 allowDirCreate = TRUE,
                 defaultRoot = "Home",
                 defaultPath = "")
  
  # =============================================================================
  # FOLDER SELECTION HANDLING
  # =============================================================================
  
  observeEvent(input$select_folder, {
    if (!is.null(input$select_folder) && !is.integer(input$select_folder)) {
      # Parse the selected path
      selected_path <- parseDirPath(volumes(), input$select_folder)
      
      if (length(selected_path) > 0 && nchar(selected_path) > 0) {
        # Create subfolder if option is selected
        if (isTRUE(input$create_subfolder)) {
          selected_path <- file.path(selected_path, "bowtie_saves")
          
          # Create the subfolder if it doesn't exist
          if (!dir.exists(selected_path)) {
            tryCatch({
              dir.create(selected_path, recursive = TRUE)
              log_info(paste("Created bowtie_saves subfolder:", selected_path))
            }, error = function(e) {
              notify_error(paste("Failed to create subfolder:", e$message), duration = 5)
              return()
            })
          }
        }
        
        # Update path and verify
        storage_path(selected_path)
        updateTextInput(session, "local_folder_path", value = selected_path)
        
        # Verify the folder is writable
        verify_folder_access(selected_path)
      }
    }
  })
  
  # Handle manual path entry
  observeEvent(input$local_folder_path, {
    path <- input$local_folder_path
    if (!is.null(path) && nchar(path) > 0 && path != storage_path()) {
      storage_path(path)
    }
  })
  
  # Update storage mode
  observeEvent(input$storage_mode, {
    storage_mode(input$storage_mode)
  })
  
  # =============================================================================
  # FOLDER VERIFICATION
  # =============================================================================
  
  verify_folder_access <- function(path) {
    if (is.null(path) || nchar(path) == 0) {
      storage_verified(FALSE)
      return(FALSE)
    }
    
    tryCatch({
      # Check if directory exists
      if (!dir.exists(path)) {
        # Try to create it
        dir.create(path, recursive = TRUE)
      }
      
      # Test write access by creating a temp file
      test_file <- file.path(path, ".bowtie_write_test")
      writeLines("test", test_file)
      
      if (file.exists(test_file)) {
        file.remove(test_file)
        storage_verified(TRUE)
        
        notify_success(paste("✅ Folder verified:", path), duration = 3)
        
        log_info(paste("Local storage folder verified:", path))
        return(TRUE)
      } else {
        storage_verified(FALSE)
        return(FALSE)
      }
      
    }, error = function(e) {
      storage_verified(FALSE)
      notify_error(paste("❌ Cannot access folder:", e$message), duration = 5)
      log_error(paste("Local storage verification failed:", e$message))
      return(FALSE)
    })
  }
  
  # Verify folder button
  observeEvent(input$verify_folder, {
    path <- storage_path()
    if (!is.null(path) && nchar(path) > 0) {
      verify_folder_access(path)
    } else {
      notify_warning("Please select a folder first")
    }
  })
  
  # =============================================================================
  # FOLDER STATUS DISPLAY
  # =============================================================================
  
  output$folder_status <- renderUI({
    path <- storage_path()
    verified <- storage_verified()
    
    if (is.null(path) || nchar(path) == 0) {
      div(class = "alert alert-secondary",
          icon("info-circle"), " No folder selected")
    } else if (verified) {
      div(class = "alert alert-success",
          icon("check-circle"), " Folder is accessible and ready for saving")
    } else {
      div(class = "alert alert-warning",
          icon("exclamation-triangle"), " Folder access not verified. Click 'Verify Folder' to check.")
    }
  })
  
  # =============================================================================
  # LIST FILES IN LOCAL FOLDER
  # =============================================================================
  
  output$local_files_list <- renderUI({
    path <- storage_path()
    
    if (is.null(path) || !dir.exists(path)) {
      return(p(class = "text-muted", "No folder selected"))
    }
    
    # Get list of save files
    files <- list.files(path, pattern = "\\.(rds|json)$", full.names = FALSE)
    
    if (length(files) == 0) {
      return(p(class = "text-muted", "No saved files found"))
    }
    
    # Get file info
    file_info <- file.info(file.path(path, files))
    files_df <- data.frame(
      name = files,
      size = paste0(round(file_info$size / 1024, 1), " KB"),
      modified = format(file_info$mtime, "%Y-%m-%d %H:%M"),
      stringsAsFactors = FALSE
    )
    
    # Create list of file items
    file_items <- lapply(seq_len(nrow(files_df)), function(i) {
      ns <- session$ns
      div(class = "d-flex justify-content-between align-items-center py-1 border-bottom",
          div(
            icon("file"), " ",
            strong(files_df$name[i]),
            tags$small(class = "text-muted ml-2", files_df$size[i])
          ),
          div(
            actionButton(ns(paste0("load_file_", i)), 
                         icon("upload"),
                         class = "btn-xs btn-outline-primary",
                         title = "Load this file"),
            actionButton(ns(paste0("delete_file_", i)),
                         icon("trash"),
                         class = "btn-xs btn-outline-danger ml-1",
                         title = "Delete this file")
          )
      )
    })
    
    tagList(
      tags$small(class = "text-muted", 
                 paste("Last updated:", format(Sys.time(), "%H:%M:%S"))),
      do.call(tagList, file_items)
    )
  })
  
  # =============================================================================
  # OPEN FOLDER IN EXPLORER
  # =============================================================================
  
  observeEvent(input$open_folder, {
    path <- storage_path()
    
    if (is.null(path) || !dir.exists(path)) {
      notify_warning("No valid folder selected")
      return()
    }
    
    tryCatch({
      if (.Platform$OS.type == "windows") {
        shell.exec(normalizePath(path))
      } else if (Sys.info()["sysname"] == "Darwin") {
        system2("open", path)
      } else {
        system2("xdg-open", path)
      }
    }, error = function(e) {
      notify_error(paste("Could not open folder:", e$message))
    })
  })
  
  # =============================================================================
  # QUICK SAVE FUNCTIONALITY
  # =============================================================================
  
  observeEvent(input$quick_save, {
    mode <- storage_mode()
    
    if (mode == "browser") {
      # Trigger browser localStorage save via JavaScript
      session$sendCustomMessage("triggerAutosave", list())
      notify_info("💾 Saved to browser storage")
      
    } else if (mode == "local") {
      path <- storage_path()
      
      if (is.null(path) || !storage_verified()) {
        notify_warning("Please select and verify a local folder first")
        return()
      }
      
      # Collect data to save
      save_data <- collect_save_data()
      
      if (!is.null(save_data)) {
        # Generate filename with timestamp
        filename <- sprintf("bowtie_save_%s.rds", format(Sys.time(), "%Y%m%d_%H%M%S"))
        filepath <- file.path(path, filename)
        
        tryCatch({
          saveRDS(save_data, filepath)
          last_save_time(Sys.time())
          
          notify_success(paste("✅ Saved to:", filename), duration = 3)
          
          log_info(paste("Quick save completed:", filepath))
          
        }, error = function(e) {
          notify_error(paste("❌ Save failed:", e$message), duration = 5)
        })
      }
      
    } else {
      # Server mode - save to default server location
      notify_info("Server save mode - using default location")
    }
  })
  
  # =============================================================================
  # QUICK LOAD FUNCTIONALITY  
  # =============================================================================
  
  observeEvent(input$quick_load, {
    mode <- storage_mode()
    
    if (mode == "browser") {
      # Trigger browser localStorage load via JavaScript
      session$sendCustomMessage("triggerAutoload", list())
      
    } else if (mode == "local") {
      path <- storage_path()
      
      if (is.null(path) || !dir.exists(path)) {
        notify_warning("Please select a local folder first")
        return()
      }
      
      # Get most recent save file
      files <- list.files(path, pattern = "\\.rds$", full.names = TRUE)
      
      if (length(files) == 0) {
        notify_warning("No save files found in selected folder")
        return()
      }
      
      # Sort by modification time (newest first)
      file_times <- file.info(files)$mtime
      newest_file <- files[which.max(file_times)]
      
      tryCatch({
        loaded_data <- readRDS(newest_file)
        
        # Send loaded data to the app
        session$sendCustomMessage("localDataLoaded", list(
          data = loaded_data,
          filename = basename(newest_file)
        ))
        
        notify_success(paste("✅ Loaded:", basename(newest_file)), duration = 3)

      }, error = function(e) {
        notify_error(paste("❌ Load failed:", e$message), duration = 5)
      })

    } else {
      notify_info("Server mode - load from server location")
    }
  })
  
  # Handle file input for explicit file loading
  observeEvent(input$load_file_input, {
    file <- input$load_file_input
    req(file)
    
    tryCatch({
      if (grepl("\\.rds$", file$name, ignore.case = TRUE)) {
        loaded_data <- readRDS(file$datapath)
      } else if (grepl("\\.json$", file$name, ignore.case = TRUE)) {
        loaded_data <- jsonlite::fromJSON(file$datapath)
      } else {
        notify_error("Unsupported file format")
        return()
      }
      
      session$sendCustomMessage("localDataLoaded", list(
        data = loaded_data,
        filename = file$name
      ))
      
      notify_success(paste("✅ Loaded:", file$name))
      
    }, error = function(e) {
      notify_error(paste("❌ Failed to load file:", e$message))
    })
  })
  
  # =============================================================================
  # HELPER FUNCTIONS
  # =============================================================================
  
  # Collect all data that should be saved
  collect_save_data <- function() {
    save_data <- list(
      timestamp = Sys.time(),
      version = APP_CONFIG$VERSION %||% "5.4.0"
    )
    
    # Add current data if available
    if (!is.null(getCurrentData)) {
      tryCatch({
        data <- getCurrentData()
        if (!is.null(data) && nrow(data) > 0) {
          save_data$current_data <- data
        }
      }, error = function(e) {
        log_debug(paste("Could not get current data:", e$message))
      })
    }
    
    # Add workflow state if available
    if (!is.null(getWorkflowState)) {
      tryCatch({
        state <- getWorkflowState()
        if (!is.null(state)) {
          save_data$workflow_state <- state
        }
      }, error = function(e) {
        log_debug(paste("Could not get workflow state:", e$message))
      })
    }
    
    # Add settings
    save_data$settings <- list(
      language = isolate(lang()),
      storage_mode = isolate(storage_mode()),
      storage_path = isolate(storage_path())
    )
    
    return(save_data)
  }
  
  # =============================================================================
  # SAVE TO LOCAL FOLDER (Exported function for other modules)
  # =============================================================================
  
  save_to_local <- function(data, filename = NULL) {
    if (storage_mode() != "local" || !storage_verified()) {
      return(FALSE)
    }
    
    path <- storage_path()
    if (is.null(filename)) {
      filename <- sprintf("bowtie_save_%s.rds", format(Sys.time(), "%Y%m%d_%H%M%S"))
    }
    
    filepath <- file.path(path, filename)
    
    tryCatch({
      saveRDS(data, filepath)
      last_save_time(Sys.time())
      return(TRUE)
    }, error = function(e) {
      log_error(paste("Local save failed:", e$message))
      return(FALSE)
    })
  }
  
  # Load from local folder (Exported function)
  load_from_local <- function(filename = NULL) {
    if (storage_mode() != "local") {
      return(NULL)
    }
    
    path <- storage_path()
    if (is.null(path) || !dir.exists(path)) {
      return(NULL)
    }
    
    if (is.null(filename)) {
      # Get most recent file
      files <- list.files(path, pattern = "\\.rds$", full.names = TRUE)
      if (length(files) == 0) return(NULL)
      
      file_times <- file.info(files)$mtime
      filepath <- files[which.max(file_times)]
    } else {
      filepath <- file.path(path, filename)
    }
    
    if (!file.exists(filepath)) {
      return(NULL)
    }
    
    tryCatch({
      readRDS(filepath)
    }, error = function(e) {
      log_error(paste("Local load failed:", e$message))
      return(NULL)
    })
  }
  
  # =============================================================================
  # RETURN MODULE API
  # =============================================================================
  
  list(
    storage_path = storage_path,
    storage_mode = storage_mode,
    storage_verified = storage_verified,
    last_save_time = last_save_time,
    save_to_local = save_to_local,
    load_from_local = load_from_local,
    get_volumes = volumes
  )
}

# =============================================================================
# NON-NAMESPACED LOCAL STORAGE SERVER
# =============================================================================
# This version works with UI elements defined directly in ui.R without namespacing

#' Initialize local storage server logic (non-namespaced version)
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param getCurrentData Reactive function to get current data
#' @param lang Reactive language value
#' @return List containing local storage reactive values and functions
#' @export
local_storage_server <- function(input, output, session, getCurrentData = NULL, lang = reactive("en")) {
  
  # Reactive values for local storage state
  storage_path <- reactiveVal(NULL)
  storage_verified <- reactiveVal(FALSE)
  storage_mode <- reactiveVal("browser")
  last_save_time <- reactiveVal(NULL)
  
  # Define available volumes for shinyFiles
  volumes <- reactive({
    # Get user's home directory
    home_dir <- Sys.getenv("USERPROFILE")
    if (home_dir == "") home_dir <- Sys.getenv("HOME")
    if (home_dir == "") home_dir <- path.expand("~")
    
    # Define volumes based on OS
    if (.Platform$OS.type == "windows") {
      vols <- c(
        "Home" = home_dir,
        "Documents" = file.path(home_dir, "Documents"),
        "Desktop" = file.path(home_dir, "Desktop"),
        "Downloads" = file.path(home_dir, "Downloads")
      )
      
      # Add available drive letters
      for (drive in c("C", "D", "E", "F")) {
        drive_path <- paste0(drive, ":/")
        if (dir.exists(drive_path)) {
          vols <- c(vols, setNames(drive_path, paste0(drive, ":")))
        }
      }
    } else {
      vols <- c(
        "Home" = home_dir,
        "Root" = "/"
      )
    }
    
    # Filter to only existing directories
    vols[sapply(vols, dir.exists)]
  })
  
  # Initialize shinyFiles directory chooser
  # Note: roots must be a function that returns a named vector, not a reactive directly
  shinyDirChoose(input, "select_folder",
                 roots = function() volumes(),
                 filetypes = NULL,
                 restrictions = NULL,
                 allowDirCreate = TRUE,
                 defaultRoot = "Home",
                 defaultPath = "")
  
  # =============================================================================
  # FOLDER SELECTION HANDLING
  # =============================================================================
  
  observeEvent(input$select_folder, {
    if (!is.null(input$select_folder) && !is.integer(input$select_folder)) {
      selected_path <- parseDirPath(volumes(), input$select_folder)
      
      if (length(selected_path) > 0 && nchar(selected_path) > 0) {
        # Create subfolder if option is selected
        if (isTRUE(input$create_subfolder)) {
          selected_path <- file.path(selected_path, "bowtie_saves")
          
          if (!dir.exists(selected_path)) {
            tryCatch({
              dir.create(selected_path, recursive = TRUE)
              bowtie_log(paste("Created bowtie_saves subfolder:", selected_path), level = "info")
            }, error = function(e) {
              notify_error(paste("Failed to create subfolder:", e$message), duration = 5)
              return()
            })
          }
        }
        
        storage_path(selected_path)
        updateTextInput(session, "local_folder_path", value = selected_path)
        verify_folder_access(selected_path)
      }
    }
  })
  
  # Handle manual path entry
  observeEvent(input$local_folder_path, {
    path <- input$local_folder_path
    if (!is.null(path) && nchar(path) > 0 && path != storage_path()) {
      storage_path(path)
    }
  })
  
  # Update storage mode
  observeEvent(input$storage_mode, {
    storage_mode(input$storage_mode)
  })
  
  # =============================================================================
  # FOLDER VERIFICATION
  # =============================================================================
  
  verify_folder_access <- function(path) {
    if (is.null(path) || nchar(path) == 0) {
      storage_verified(FALSE)
      return(FALSE)
    }
    
    tryCatch({
      if (!dir.exists(path)) {
        dir.create(path, recursive = TRUE)
      }
      
      test_file <- file.path(path, ".bowtie_write_test")
      writeLines("test", test_file)
      
      if (file.exists(test_file)) {
        file.remove(test_file)
        storage_verified(TRUE)
        
        notify_success(paste("✅ Folder verified:", path), duration = 3)
        return(TRUE)
      } else {
        storage_verified(FALSE)
        return(FALSE)
      }
      
    }, error = function(e) {
      storage_verified(FALSE)
      notify_error(paste("❌ Cannot access folder:", e$message), duration = 5)
      return(FALSE)
    })
  }
  
  # Verify folder button
  observeEvent(input$verify_folder, {
    path <- storage_path()
    if (!is.null(path) && nchar(path) > 0) {
      verify_folder_access(path)
    } else {
      notify_warning("Please select a folder first")
    }
  })
  
  # =============================================================================
  # FOLDER STATUS DISPLAY
  # =============================================================================
  
  output$folder_status <- renderUI({
    path <- storage_path()
    verified <- storage_verified()
    
    if (is.null(path) || nchar(path) == 0) {
      div(class = "alert alert-secondary",
          icon("info-circle"), " No folder selected")
    } else if (verified) {
      div(class = "alert alert-success",
          icon("check-circle"), " Folder is accessible and ready for saving")
    } else {
      div(class = "alert alert-warning",
          icon("exclamation-triangle"), " Folder access not verified. Click 'Verify Folder' to check.")
    }
  })
  
  # =============================================================================
  # LIST FILES IN LOCAL FOLDER
  # =============================================================================
  
  output$local_files_list <- renderUI({
    path <- storage_path()
    
    if (is.null(path) || !dir.exists(path)) {
      return(p(class = "text-muted", "No folder selected"))
    }
    
    files <- list.files(path, pattern = "\\.(rds|json)$", full.names = FALSE)
    
    if (length(files) == 0) {
      return(p(class = "text-muted", "No saved files found"))
    }
    
    file_info <- file.info(file.path(path, files))
    files_df <- data.frame(
      name = files,
      size = paste0(round(file_info$size / 1024, 1), " KB"),
      modified = format(file_info$mtime, "%Y-%m-%d %H:%M"),
      stringsAsFactors = FALSE
    )
    
    file_items <- lapply(seq_len(nrow(files_df)), function(i) {
      div(class = "d-flex justify-content-between align-items-center py-1 border-bottom",
          div(
            icon("file"), " ",
            strong(files_df$name[i]),
            tags$small(class = "text-muted ml-2", files_df$size[i]),
            tags$small(class = "text-muted ml-2", files_df$modified[i])
          ),
          div(
            actionButton(paste0("load_local_file_", i), 
                         icon("upload"),
                         class = "btn-xs btn-outline-primary",
                         title = "Load this file"),
            actionButton(paste0("delete_local_file_", i),
                         icon("trash"),
                         class = "btn-xs btn-outline-danger ml-1",
                         title = "Delete this file")
          )
      )
    })
    
    tagList(
      tags$small(class = "text-muted", 
                 paste("Last updated:", format(Sys.time(), "%H:%M:%S"))),
      actionButton("refresh_local_files", icon("sync"), class = "btn-xs btn-outline-secondary ml-2"),
      do.call(tagList, file_items)
    )
  })
  
  # Refresh file list
  observeEvent(input$refresh_local_files, {
    # Just trigger a re-render by invalidating
    storage_path(storage_path())
  })
  
  # =============================================================================
  # OPEN FOLDER IN EXPLORER
  # =============================================================================
  
  observeEvent(input$open_folder, {
    path <- storage_path()
    
    if (is.null(path) || !dir.exists(path)) {
      notify_warning("No valid folder selected")
      return()
    }
    
    tryCatch({
      if (.Platform$OS.type == "windows") {
        shell.exec(normalizePath(path))
      } else if (Sys.info()["sysname"] == "Darwin") {
        system2("open", path)
      } else {
        system2("xdg-open", path)
      }
    }, error = function(e) {
      notify_error(paste("Could not open folder:", e$message))
    })
  })
  
  # =============================================================================
  # QUICK SAVE FUNCTIONALITY
  # =============================================================================
  
  observeEvent(input$local_quick_save, {
    mode <- storage_mode()
    
    if (mode == "browser") {
      session$sendCustomMessage("triggerAutosave", list())
      notify_info("💾 Saved to browser storage")
      
    } else if (mode == "local") {
      path <- storage_path()
      
      if (is.null(path) || !storage_verified()) {
        notify_warning("Please select and verify a local folder first")
        return()
      }
      
      save_data <- list(
        timestamp = Sys.time(),
        version = APP_CONFIG$VERSION %||% "5.4.0",
        settings = list(
          storage_mode = mode,
          storage_path = path
        )
      )
      
      if (!is.null(getCurrentData)) {
        tryCatch({
          data <- getCurrentData()
          if (!is.null(data) && nrow(data) > 0) {
            save_data$current_data <- data
          }
        }, error = function(e) {
          bowtie_log(paste("Could not get current data:", e$message), level = "debug")
        })
      }
      
      # Use JSON format for browser compatibility
      filename <- sprintf("bowtie_save_%s.json", format(Sys.time(), "%Y%m%d_%H%M%S"))
      filepath <- file.path(path, filename)

      tryCatch({
        json_content <- jsonlite::toJSON(save_data, auto_unbox = TRUE, pretty = TRUE)
        writeLines(json_content, filepath)
        last_save_time(Sys.time())
        
        notify_success(paste("✅ Saved to:", filename), duration = 3)

        bowtie_log(paste("Quick save completed:", filepath), level = "info")

      }, error = function(e) {
        notify_error(paste("❌ Save failed:", e$message), duration = 5)
      })
      
    } else {
      notify_info("Server save mode - using default location")
    }
  })
  
  # =============================================================================
  # QUICK LOAD FUNCTIONALITY  
  # =============================================================================
  
  observeEvent(input$local_quick_load, {
    mode <- storage_mode()
    
    if (mode == "browser") {
      session$sendCustomMessage("triggerAutoload", list())
      
    } else if (mode == "local") {
      path <- storage_path()

      if (is.null(path) || !dir.exists(path)) {
        notify_warning("Please select a local folder first")
        return()
      }

      # Look for both JSON (preferred) and RDS (legacy) files
      json_files <- list.files(path, pattern = "\\.json$", full.names = TRUE)
      rds_files <- list.files(path, pattern = "\\.rds$", full.names = TRUE)
      files <- c(json_files, rds_files)

      if (length(files) == 0) {
        notify_warning("No save files found in selected folder")
        return()
      }

      file_times <- file.info(files)$mtime
      newest_file <- files[which.max(file_times)]

      tryCatch({
        # Load based on file extension
        if (grepl("\\.json$", newest_file, ignore.case = TRUE)) {
          json_content <- readLines(newest_file, warn = FALSE)
          loaded_data <- jsonlite::fromJSON(paste(json_content, collapse = "\n"))
        } else {
          loaded_data <- readRDS(newest_file)
        }

        session$sendCustomMessage("localDataLoaded", list(
          data = loaded_data,
          filename = basename(newest_file)
        ))

        notify_success(paste("Loaded:", basename(newest_file)), duration = 3)

      }, error = function(e) {
        notify_error(paste("Load failed:", e$message), duration = 5)
      })
      
    } else {
      notify_info("Server mode - load from server location")
    }
  })
  
  # Handle file input for explicit file loading
  observeEvent(input$local_load_file_input, {
    file <- input$local_load_file_input
    req(file)
    
    tryCatch({
      if (grepl("\\.rds$", file$name, ignore.case = TRUE)) {
        loaded_data <- readRDS(file$datapath)
      } else if (grepl("\\.json$", file$name, ignore.case = TRUE)) {
        loaded_data <- jsonlite::fromJSON(file$datapath)
      } else {
        notify_error("Unsupported file format")
        return()
      }
      
      session$sendCustomMessage("localDataLoaded", list(
        data = loaded_data,
        filename = file$name
      ))
      
      notify_success(paste("✅ Loaded:", file$name))
      
    }, error = function(e) {
      notify_error(paste("❌ Failed to load file:", e$message))
    })
  })
  
  # =============================================================================
  # RETURN API
  # =============================================================================
  
  list(
    storage_path = storage_path,
    storage_mode = storage_mode,
    storage_verified = storage_verified,
    last_save_time = last_save_time,
    volumes = volumes
  )
}

# =============================================================================
# JAVASCRIPT HANDLERS FOR LOCAL STORAGE
# =============================================================================

#' Generate JavaScript code for local storage message handlers
#' 
#' @return Character string containing JavaScript code
#' @export
local_storage_js <- function() {
  HTML("
  <script>
  // Handler for triggering autosave
  Shiny.addCustomMessageHandler('triggerAutosave', function(message) {
    if (typeof(Storage) !== 'undefined') {
      // Trigger the autosave button click
      $('#autosave_now').click();
    }
  });
  
  // Handler for triggering autoload
  Shiny.addCustomMessageHandler('triggerAutoload', function(message) {
    if (typeof(Storage) !== 'undefined') {
      var saveData = localStorage.getItem('bowtie_autosave_current');
      if (saveData) {
        Shiny.setInputValue('autosave_restore_data', JSON.parse(saveData), {priority: 'event'});
        console.log('Triggered autoload from localStorage');
      } else {
        Shiny.setInputValue('local_storage_notify', {type: 'warning', message: 'No saved data found in browser'}, {priority: 'event'});
      }
    }
  });
  
  // Handler for local data loaded - send to server for restoration
  Shiny.addCustomMessageHandler('localDataLoaded', function(message) {
    console.log('Local data loaded:', message.filename);
    // Send the loaded data to Shiny for proper restoration
    if (message.data) {
      Shiny.setInputValue('local_data_restore', message.data, {priority: 'event'});
    }
  });
  
  // Handler for download data (for autosave to file)
  Shiny.addCustomMessageHandler('downloadData', function(message) {
    var blob = new Blob([message.content], {type: message.contentType || 'application/octet-stream'});
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = message.filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    console.log('Downloaded file:', message.filename);
  });
  
  // Handler for eval (execute JavaScript code)
  Shiny.addCustomMessageHandler('eval', function(message) {
    try {
      eval(message.code);
    } catch(e) {
      console.error('Error executing JavaScript:', e);
    }
  });
  </script>
  ")
}
