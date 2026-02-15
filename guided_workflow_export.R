# =============================================================================
# Guided Workflow - Export & Persistence Functions
# Extracted from guided_workflow.R for maintainability
# =============================================================================
# Contains:
#   - init_workflow_export()  - Initializes all export/save/load handlers
#     - Finalization status output
#     - Finalize workflow button handlers (Step 8 + legacy)
#     - Export to Excel handler
#     - PDF report generation handler
#     - Load to Main Application handler
#     - Workflow help modal
#     - Load/save progress handlers (JSON + legacy RDS)
#     - Download handler (JSON format)
# =============================================================================

#' Initialize export and persistence handlers for the guided workflow
#'
#' Sets up all observers and download handlers related to workflow finalization,
#' export (Excel, PDF), loading to main app, and save/load progress.
#' Must be called inside moduleServer() with local = TRUE.
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param workflow_state reactiveVal holding the workflow state
#' @param workflow_complete_reactive narrowed reactive for completion status
#' @param lang reactive returning current language code
#' @param selected_activities reactiveVal for activities list
#' @param selected_pressures reactiveVal for pressures list
#' @param selected_preventive_controls reactiveVal for preventive controls list
#' @param selected_consequences reactiveVal for consequences list
#' @param selected_protective_controls reactiveVal for protective controls list
#' @param selected_escalation_factors reactiveVal for escalation factors list
init_workflow_export <- function(input, output, session, workflow_state,
                                 workflow_complete_reactive, lang,
                                 selected_activities, selected_pressures,
                                 selected_preventive_controls, selected_consequences,
                                 selected_protective_controls, selected_escalation_factors) {

  # =============================================================================
  # FINALIZATION & EXPORT
  # =============================================================================

  # Finalization status output
  # Uses narrowed workflow_complete_reactive to only re-render when completion changes
  output$finalization_status <- renderUI({
    is_complete <- workflow_complete_reactive()

    if (is_complete) {
      # Read converted data count only when complete (isolate to avoid extra dependency)
      scenario_count <- isolate({
        state <- workflow_state()
        if (!is.null(state$converted_main_data)) nrow(state$converted_main_data) else 0
      })
      div(class = "d-flex align-items-center",
        span(class = "badge bg-success fs-6 me-2",
             tagList(icon("check-circle"), " Finalized")),
        span(class = "text-success",
             paste("Ready to export -", scenario_count, "scenarios"))
      )
    } else {
      span(class = "text-muted fst-italic", "Not yet finalized")
    }
  })

  # Handle workflow finalization from Step 8 button
  observeEvent(input$finalize_workflow_btn, {
    state <- workflow_state()

    # Final validation
    validation_result <- validate_current_step(state, input)
    if (!validation_result$is_valid) {
      notify_error(validation_result$message)
      return()
    }

    # Save final step data
    state <- save_step_data(state, input)

    # Mark step 8 as complete
    if (!8 %in% state$completed_steps) {
      state$completed_steps <- c(state$completed_steps, 8)
    }

    # Update progress to 100%
    state$progress_percentage <- 100

    # Mark workflow as complete
    state$workflow_complete <- TRUE

    # Convert workflow data to main application format
    converted_data <- convert_to_main_data_format(state$project_data)
    state$converted_main_data <- converted_data

    log_success(paste("Workflow finalized! Data rows:", nrow(converted_data)))

    workflow_state(state)

    # Clear autosave - workflow is complete, no need to keep autosave
    session$sendCustomMessage("clearAutosave", list())

    notify_success("Workflow finalized successfully! You can now export or view the diagram.",
      duration = 5
    )
  })

  # Handle workflow finalization from navigation button (legacy)
  observeEvent(input$finalize_workflow, {
    state <- workflow_state()

    # Final validation
    validation_result <- validate_current_step(state, input)
    if (!validation_result$is_valid) {
      notify_error(validation_result$message)
      return()
    }

    # Save final step data
    state <- save_step_data(state, input)

    # Mark workflow as complete
    state$workflow_complete <- TRUE

    # Convert workflow data to main application format
    converted_data <- convert_to_main_data_format(state$project_data)
    state$converted_main_data <- converted_data

    workflow_state(state)

    # Clear autosave - workflow is complete, no need to keep autosave
    session$sendCustomMessage("clearAutosave", list())

    notify_success("Workflow finalized! You can now export or view the diagram.",
      duration = 5
    )
  })

  # =============================================================================
  # EXPORT HANDLERS FOR STEP 8
  # =============================================================================

  # Handler for Export to Excel
  observeEvent(input$export_excel, {
    state <- workflow_state()

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      notify_warning("Please complete the workflow first by clicking 'Complete Workflow'.", duration = 4)
      return()
    }

    tryCatch({
      # Get converted data
      converted_data <- state$converted_main_data

      if (is.null(converted_data) || nrow(converted_data) == 0) {
        # Try to convert now
        converted_data <- convert_to_main_data_format(state$project_data)
        state$converted_main_data <- converted_data
        workflow_state(state)
      }

      # Create filename with timestamp
      project_name <- state$project_data$project_name %||% "Bowtie"
      project_name <- gsub("[^A-Za-z0-9_-]", "_", project_name)  # Sanitize filename
      filename <- paste0(project_name, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx")

      # Create temporary file
      temp_file <- file.path(tempdir(), filename)

      # Export using the existing function from vocabulary_bowtie_generator.R
      # Note: This function should be sourced in global.R
      if (exists("export_bowtie_to_excel")) {
        export_bowtie_to_excel(converted_data, temp_file)

        # Trigger download
        notify_success(paste("\u2705 Excel file created:", filename), duration = 3)

        # Return file info for download handler (if downloadHandler is implemented)
        # For now, just notify where the file is saved
        notify_info(paste("File saved to:", temp_file), duration = 10)
      } else {
        # Fallback: use openxlsx directly
        library(openxlsx)
        wb <- createWorkbook()
        addWorksheet(wb, "Bowtie_Data")
        writeData(wb, "Bowtie_Data", converted_data)

        # Add summary sheet
        addWorksheet(wb, "Summary")
        summary_data <- data.frame(
          Metric = c("Project Name", "Central Problem", "Total Entries",
                     "Unique Activities", "Unique Consequences", "Export Date"),
          Value = c(
            state$project_data$project_name %||% "Unnamed",
            state$project_data$problem_statement %||% "Unnamed",
            nrow(converted_data),
            length(unique(converted_data$Activity)),
            length(unique(converted_data$Consequence)),
            as.character(Sys.time())
          ),
          stringsAsFactors = FALSE
        )
        writeData(wb, "Summary", summary_data)

        # Save workbook
        saveWorkbook(wb, temp_file, overwrite = TRUE)

        notify_success(paste("\u2705 Excel file exported:", filename), duration = 5)
      }

    }, error = function(e) {
      notify_error(paste("\u274c Export failed:", e$message), duration = 5)
    })
  })

  # Handler for Generate PDF Report
  observeEvent(input$export_pdf, {
    state <- workflow_state()

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      notify_warning("Please complete the workflow first by clicking 'Complete Workflow'.", duration = 4)
      return()
    }

    tryCatch({
      # Create a simple PDF report using base graphics or ggplot2
      project_name <- state$project_data$project_name %||% "Bowtie_Report"
      project_name <- gsub("[^A-Za-z0-9_-]", "_", project_name)
      filename <- paste0(project_name, "_Report_", format(Sys.Date(), "%Y%m%d"), ".pdf")
      temp_file <- file.path(tempdir(), filename)

      # Create PDF with summary information
      pdf(temp_file, width = 11, height = 8.5)

      # Title page
      plot.new()
      text(0.5, 0.9, "Bowtie Risk Assessment Report", cex = 2.5, font = 2)
      text(0.5, 0.8, state$project_data$project_name %||% "Unnamed Project", cex = 2)
      text(0.5, 0.7, paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M")), cex = 1.2)

      # Summary statistics page
      plot.new()
      text(0.5, 0.95, "Assessment Summary", cex = 2, font = 2)

      y_pos <- 0.85
      line_height <- 0.06

      # Project info
      text(0.1, y_pos, "Central Problem:", pos = 4, cex = 1.3, font = 2)
      text(0.1, y_pos - line_height, state$project_data$problem_statement %||% "Not specified",
           pos = 4, cex = 1.1)
      y_pos <- y_pos - 3 * line_height

      # Activities
      activities <- state$project_data$activities %||% list()
      text(0.1, y_pos, paste("Human Activities (", length(activities), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(activities) > 0) {
        for(i in seq_along(activities)[1:min(10, length(activities))]) {
          text(0.15, y_pos - i * line_height, paste("-", activities[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(10, length(activities)) + 1.5) * line_height
      } else {
        y_pos <- y_pos - line_height
      }

      # Pressures
      pressures <- state$project_data$pressures %||% list()
      text(0.1, y_pos, paste("Environmental Pressures (", length(pressures), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(pressures) > 0) {
        for(i in seq_along(pressures)[1:min(8, length(pressures))]) {
          text(0.15, y_pos - i * line_height, paste("-", pressures[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(8, length(pressures)) + 1.5) * line_height
      }

      # Page 3: Controls and Consequences
      plot.new()
      text(0.5, 0.95, "Controls & Consequences", cex = 2, font = 2)

      y_pos <- 0.85

      # Preventive Controls
      prev_controls <- state$project_data$preventive_controls %||% list()
      text(0.1, y_pos, paste("Preventive Controls (", length(prev_controls), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(prev_controls) > 0) {
        for(i in seq_along(prev_controls)[1:min(8, length(prev_controls))]) {
          text(0.15, y_pos - i * line_height, paste("-", prev_controls[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(8, length(prev_controls)) + 1.5) * line_height
      } else {
        y_pos <- y_pos - line_height
      }

      # Consequences
      consequences <- state$project_data$consequences %||% list()
      text(0.1, y_pos, paste("Consequences (", length(consequences), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(consequences) > 0) {
        for(i in seq_along(consequences)[1:min(8, length(consequences))]) {
          text(0.15, y_pos - i * line_height, paste("-", consequences[i]), pos = 4, cex = 1)
        }
      }

      # Protective Controls
      prot_controls <- state$project_data$protective_controls %||% list()
      if (length(prot_controls) > 0 && y_pos > 0.3) {
        y_pos <- y_pos - (min(8, length(consequences)) + 2) * line_height
        text(0.1, y_pos, paste("Protective Controls (", length(prot_controls), "):"),
             pos = 4, cex = 1.3, font = 2)
        for(i in seq_along(prot_controls)[1:min(6, length(prot_controls))]) {
          text(0.15, y_pos - i * line_height, paste("-", prot_controls[i]), pos = 4, cex = 1)
        }
      }

      dev.off()

      notify_success(paste("\u2705 PDF report generated:", filename), duration = 5)

      notify_info(paste("File saved to:", temp_file), duration = 10)

    }, error = function(e) {
      notify_error(paste("\u274c PDF generation failed:", e$message), duration = 5)
    })
  })

  # Handler for Load to Main Application (View Bowtie Diagram)
  observeEvent(input$load_to_main, {
    state <- workflow_state()

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      notify_warning("Please finalize the workflow first by clicking 'Finalize Workflow'.", duration = 4)
      return()
    }

    tryCatch({
      # Always regenerate converted data to ensure fresh state trigger
      log_info("Preparing bowtie data for main application...")
      converted_data <- convert_to_main_data_format(state$project_data)

      # Validate data
      if (is.null(converted_data) || !is.data.frame(converted_data) || nrow(converted_data) == 0) {
        notify_error("No data available to load. Please ensure your workflow has data.", duration = 5)
        return()
      }

      log_info(paste("Generated", nrow(converted_data), "bowtie scenarios"))
      log_debug(paste("Columns:", paste(names(converted_data), collapse = ", ")))

      # Success notification
      notify_info(paste("Loading", nrow(converted_data), "scenarios..."), duration = 2)

      # Update state with fresh data and trigger timestamp to force reactive update
      state$converted_main_data <- converted_data
      state$data_load_timestamp <- Sys.time()
      state$navigate_to_bowtie <- TRUE
      workflow_state(state)

      log_success("State updated with converted data")

      # Small delay to allow reactive to propagate, then navigate
      shinyjs::delay(500, {
        shinyjs::runjs("
          // Try multiple selectors for bs4Dash compatibility
          var bowtieLink = $('a[href=\"#shiny-tab-bowtie\"]');
          if (bowtieLink.length > 0) {
            bowtieLink.click();
          } else {
            bowtieLink = $('a[data-value=\"bowtie\"]');
            if (bowtieLink.length > 0) {
              bowtieLink.click();
            }
          }
          // Also ensure tab content is shown
          $('#shiny-tab-bowtie').addClass('active show');
          $('.tab-pane').not('#shiny-tab-bowtie').removeClass('active show');
        ")
      })

      # Show success message
      notify_info("Opening Bowtie Diagram...", duration = 3)

    }, error = function(e) {
      notify_error(paste("Failed to load data:", e$message), duration = 5)
    })
  })

  # =============================================================================
  # SAVE & LOAD FUNCTIONALITY
  # =============================================================================

  # Workflow help button - show help modal
  observeEvent(input$workflow_help, {
    showModal(modalDialog(
      title = tagList(icon("question-circle"), " Guided Workflow Help"),
      size = "l",
      easyClose = TRUE,
      tagList(
        h4("How to use the Guided Workflow"),
        tags$ol(
          tags$li(strong("Project Setup"), " - Enter basic project information and select an environmental scenario template"),
          tags$li(strong("Central Problem"), " - Define the core environmental problem to analyze"),
          tags$li(strong("Threats & Causes"), " - Select activities and pressures from the vocabulary"),
          tags$li(strong("Preventive Controls"), " - Choose mitigation measures"),
          tags$li(strong("Consequences"), " - Identify potential environmental impacts"),
          tags$li(strong("Protective Controls"), " - Add protective measures and recovery controls"),
          tags$li(strong("Review & Validate"), " - Check all connections and data completeness"),
          tags$li(strong("Finalize & Export"), " - Export your completed bowtie analysis")
        ),
        hr(),
        p(icon("lightbulb"), " Tip: Use the Save/Load buttons to preserve your progress between sessions.")
      ),
      footer = modalButton("Close")
    ))
  })

  # Trigger hidden file input for loading
  observeEvent(input$workflow_load_btn, {
    # Check if user has selected local folder storage mode
    storage_mode <- session$input$storage_mode
    local_path <- session$input$local_folder_path

    if (!is.null(storage_mode) && storage_mode == "local" &&
        !is.null(local_path) && nchar(local_path) > 0 && dir.exists(local_path)) {
      # Show modal to select from local files
      files <- list.files(local_path, pattern = "_workflow_.*\\.rds$", full.names = FALSE)

      if (length(files) == 0) {
        notify_warning("No workflow files found in local folder")
        # Fall back to file picker
        shinyjs::runjs("$('#guided_workflow-workflow_load_file_hidden').click();")
      } else {
        ns <- session$ns
        # Show file selection modal
        showModal(modalDialog(
          title = tagList(icon("folder-open"), " Load Workflow from Local Folder"),
          selectInput(ns("local_workflow_file"),
                      "Select workflow file:",
                      choices = files,
                      selected = files[1]),
          footer = tagList(
            modalButton("Cancel"),
            actionButton(ns("load_local_workflow_confirm"),
                        "Load",
                        class = "btn-primary",
                        icon = icon("upload"))
          ),
          easyClose = TRUE
        ))
      }
    } else {
      # Use standard file picker
      shinyjs::runjs("$('#guided_workflow-workflow_load_file_hidden').click();")
    }
  })

  # Handle loading from local folder selection
  observeEvent(input$load_local_workflow_confirm, {
    local_path <- session$input$local_folder_path
    selected_file <- input$local_workflow_file

    if (!is.null(local_path) && !is.null(selected_file)) {
      filepath <- file.path(local_path, selected_file)

      tryCatch({
        loaded_state <- readRDS(filepath)
        removeModal()

        # Basic validation and load (same as regular file load)
        if (is.list(loaded_state) && "current_step" %in% names(loaded_state)) {
          workflow_state(loaded_state)
          notify_success(paste("\u2705 Loaded workflow from local folder:", selected_file))
        } else {
          notify_error("\u274c Invalid workflow file.")
        }

      }, error = function(e) {
        removeModal()
        notify_error(paste("\u274c Failed to load:", e$message))
      })
    }
  })

  # Handle file loading from file picker (supports JSON and legacy RDS)
  observeEvent(input$workflow_load_file_hidden, {
    file <- input$workflow_load_file_hidden
    req(file)

    tryCatch({
      # Detect file format and load accordingly
      if (grepl("\\.json$", file$name, ignore.case = TRUE)) {
        # Load JSON format (new default)
        json_content <- readLines(file$datapath, warn = FALSE)
        loaded_state <- jsonlite::fromJSON(paste(json_content, collapse = "\n"), simplifyVector = FALSE)
      } else {
        # Load RDS format (legacy support)
        loaded_state <- readRDS(file$datapath)
      }

      # Basic validation of loaded state
      if (is.list(loaded_state) && "current_step" %in% names(loaded_state)) {

        # Migrate old data structures if needed
        if (!is.null(loaded_state$project_data)) {
          # Ensure activities and pressures are character vectors, not data frames
          if (!is.null(loaded_state$project_data$activities)) {
            if (is.data.frame(loaded_state$project_data$activities)) {
              # Extract from old data frame format
              if ("Activity" %in% names(loaded_state$project_data$activities)) {
                loaded_state$project_data$activities <- loaded_state$project_data$activities$Activity
              } else if ("Actvity" %in% names(loaded_state$project_data$activities)) {
                # Fix old typo
                loaded_state$project_data$activities <- loaded_state$project_data$activities$Actvity
              }
            }
            # Convert to character vector
            loaded_state$project_data$activities <- as.character(loaded_state$project_data$activities)
          }

          if (!is.null(loaded_state$project_data$pressures)) {
            if (is.data.frame(loaded_state$project_data$pressures)) {
              # Extract from old data frame format
              if ("Pressure" %in% names(loaded_state$project_data$pressures)) {
                loaded_state$project_data$pressures <- loaded_state$project_data$pressures$Pressure
              }
            }
            # Convert to character vector
            loaded_state$project_data$pressures <- as.character(loaded_state$project_data$pressures)
          }

          # Ensure preventive controls are character vectors
          if (!is.null(loaded_state$project_data$preventive_controls)) {
            if (is.data.frame(loaded_state$project_data$preventive_controls)) {
              # Extract from old data frame format
              if ("Control" %in% names(loaded_state$project_data$preventive_controls)) {
                loaded_state$project_data$preventive_controls <- loaded_state$project_data$preventive_controls$Control
              }
            }
            # Convert to character vector
            loaded_state$project_data$preventive_controls <- as.character(loaded_state$project_data$preventive_controls)
          }

          # Ensure consequences are character vectors
          if (!is.null(loaded_state$project_data$consequences)) {
            if (is.data.frame(loaded_state$project_data$consequences)) {
              # Extract from old data frame format
              if ("Consequence" %in% names(loaded_state$project_data$consequences)) {
                loaded_state$project_data$consequences <- loaded_state$project_data$consequences$Consequence
              }
            }
            # Convert to character vector
            loaded_state$project_data$consequences <- as.character(loaded_state$project_data$consequences)
          }

          # Ensure protective controls are character vectors
          if (!is.null(loaded_state$project_data$protective_controls)) {
            if (is.data.frame(loaded_state$project_data$protective_controls)) {
              # Extract from old data frame format
              if ("Control" %in% names(loaded_state$project_data$protective_controls)) {
                loaded_state$project_data$protective_controls <- loaded_state$project_data$protective_controls$Control
              }
            }
            # Convert to character vector
            loaded_state$project_data$protective_controls <- as.character(loaded_state$project_data$protective_controls)
          }

          # Ensure escalation factors are character vectors
          if (!is.null(loaded_state$project_data$escalation_factors)) {
            if (is.data.frame(loaded_state$project_data$escalation_factors)) {
              # Extract from old data frame format
              if ("Escalation Factor" %in% names(loaded_state$project_data$escalation_factors)) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors$`Escalation Factor`
              } else if ("escalation_factor" %in% names(loaded_state$project_data$escalation_factors)) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors$escalation_factor
              }
            }
            # Convert to character vector
            loaded_state$project_data$escalation_factors <- as.character(loaded_state$project_data$escalation_factors)
          }
        }

        workflow_state(loaded_state)

        # Update the reactive values based on current step
        if (loaded_state$current_step == 3) {
          if (!is.null(loaded_state$project_data$activities)) {
            selected_activities(loaded_state$project_data$activities)
          }
          if (!is.null(loaded_state$project_data$pressures)) {
            selected_pressures(loaded_state$project_data$pressures)
          }
        } else if (loaded_state$current_step == 4) {
          if (!is.null(loaded_state$project_data$activities)) {
            selected_activities(loaded_state$project_data$activities)
          }
          if (!is.null(loaded_state$project_data$pressures)) {
            selected_pressures(loaded_state$project_data$pressures)
          }
          if (!is.null(loaded_state$project_data$preventive_controls)) {
            selected_preventive_controls(loaded_state$project_data$preventive_controls)
          }
        } else if (loaded_state$current_step == 5) {
          if (!is.null(loaded_state$project_data$consequences)) {
            selected_consequences(loaded_state$project_data$consequences)
          }
        } else if (loaded_state$current_step == 6) {
          if (!is.null(loaded_state$project_data$consequences)) {
            selected_consequences(loaded_state$project_data$consequences)
          }
          if (!is.null(loaded_state$project_data$protective_controls)) {
            selected_protective_controls(loaded_state$project_data$protective_controls)
          }
        } else if (loaded_state$current_step == 7) {
          if (!is.null(loaded_state$project_data$escalation_factors)) {
            selected_escalation_factors(loaded_state$project_data$escalation_factors)
          }
        }

        notify_success("\u2705 Workflow progress loaded successfully!")
      } else {
        notify_error("\u274c Invalid workflow file.")
      }
    }, error = function(e) {
      notify_error(paste(t("gw_error_loading", lang()), e$message))
    })
  })

  # Handle file download (saving) - Uses JSON format for browser compatibility
  output$workflow_download <- downloadHandler(
    filename = function() {
      project_name <- workflow_state()$project_data$project_name %||% "untitled"
      # Use .json extension - browsers recognize this as safe
      paste0(gsub(" ", "_", project_name), "_bowtie_", Sys.Date(), ".json")
    },
    content = function(file) {
      state_to_save <- workflow_state()
      state_to_save$last_saved <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      state_to_save$app_version <- APP_CONFIG$VERSION %||% "5.4.0"
      state_to_save$file_format <- "bowtie_workflow_v1"

      # Convert to JSON for browser-safe download
      json_content <- jsonlite::toJSON(state_to_save, auto_unbox = TRUE, pretty = TRUE)
      writeLines(json_content, file)

      # Check if local storage mode is selected - save backup copy
      storage_mode <- session$input$storage_mode
      local_path <- session$input$local_folder_path

      # Additionally save to local folder if that mode is selected
      if (!is.null(storage_mode) && storage_mode == "local" &&
          !is.null(local_path) && nchar(local_path) > 0 && dir.exists(local_path)) {
        tryCatch({
          project_name <- state_to_save$project_data$project_name %||% "untitled"
          local_filename <- paste0(gsub(" ", "_", project_name), "_bowtie_", Sys.Date(), ".json")
          local_filepath <- file.path(local_path, local_filename)
          writeLines(json_content, local_filepath)

          notify_info(paste("Also saved to local folder:", local_filename), duration = 3)
        }, error = function(e) {
          notify_warning(paste("Could not save to local folder:", e$message))
        })
      }

      notify_success("Workflow saved successfully!", duration = 3)
    },
    contentType = "application/json"  # JSON MIME type - browsers trust this
  )
}
