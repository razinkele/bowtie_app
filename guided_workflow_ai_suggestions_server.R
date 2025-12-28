# =============================================================================
# Guided Workflow AI Suggestions - Server Handlers
# Version: 1.0
# Description: Server-side reactive handlers for AI-powered suggestions
# =============================================================================

#' Initialize AI suggestion observers for the guided workflow
#'
#' This function sets up all reactive observers for AI suggestions in steps 3-6
#' Must be called from within the guided workflow server module
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param workflow_state Reactive values containing workflow state
#' @param vocabulary_data_reactive Reactive containing vocabulary data
init_ai_suggestion_handlers <- function(input, output, session, workflow_state, vocabulary_data_reactive) {

  cat("🤖 Initializing AI suggestion handlers...\n")

  # Check if AI linker is available
  ai_available <- exists("find_vocabulary_links") && exists("generate_ai_suggestions")

  if (!ai_available) {
    cat("⚠️ AI linker not available - suggestions disabled\n")
    return(NULL)
  }

  # Require shinyjs for showing/hiding elements
  if (!requireNamespace("shinyjs", quietly = TRUE)) {
    warning("shinyjs package required for AI suggestions")
    return(NULL)
  }

  # ======================================================================
  # STEP 3: PRESSURE SUGGESTIONS (based on selected activities)
  # ======================================================================

  observe({
    # Get selected activities
    selected_activities <- workflow_state$selected_activities

    if (is.null(selected_activities) || length(selected_activities) == 0) {
      # Hide suggestions
      shinyjs::hide("suggestion_loading_pressure")
      shinyjs::hide("suggestions_list_pressure")
      shinyjs::hide("no_suggestions_pressure")
      shinyjs::hide("suggestion_error_pressure")
      shinyjs::show("suggestion_status_pressure")
      return()
    }

    # Show loading
    shinyjs::hide("suggestion_status_pressure")
    shinyjs::hide("suggestions_list_pressure")
    shinyjs::hide("no_suggestions_pressure")
    shinyjs::hide("suggestion_error_pressure")
    shinyjs::show("suggestion_loading_pressure")

    # Generate suggestions
    tryCatch({
      suggestions <- generate_ai_suggestions(
        vocabulary_data_reactive(),
        selected_activities,
        target_type = "Pressure",
        max_suggestions = 5
      )

      if (length(suggestions) == 0) {
        shinyjs::hide("suggestion_loading_pressure")
        shinyjs::show("no_suggestions_pressure")
      } else {
        # Render suggestions
        output$suggestions_content_pressure <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "pressure")
            })
          )
        })

        shinyjs::hide("suggestion_loading_pressure")
        shinyjs::show("suggestions_list_pressure")
      }
    }, error = function(e) {
      warning("Error generating pressure suggestions: ", e$message)
      shinyjs::hide("suggestion_loading_pressure")
      shinyjs::show("suggestion_error_pressure")
    })
  })

  # Handle pressure suggestion clicks
  observeEvent(input$suggestion_clicked_pressure, {
    suggestion_data <- input$suggestion_clicked_pressure

    if (!is.null(suggestion_data) && !is.null(suggestion_data$id)) {
      # Get the full item from vocabulary
      vocab <- vocabulary_data_reactive()

      if (!is.null(vocab$pressures)) {
        pressure_row <- vocab$pressures[vocab$pressures$id == suggestion_data$id, ]

        if (nrow(pressure_row) > 0) {
          # Add to selected pressures (similar to manual add)
          new_pressure <- list(
            id = pressure_row$id[1],
            name = pressure_row$name[1],
            level1 = if ("level1" %in% names(pressure_row)) pressure_row$level1[1] else "Pressure",
            level2 = if ("level2" %in% names(pressure_row)) pressure_row$level2[1] else "",
            source = "AI Suggestion"
          )

          # Check if already added
          existing_ids <- sapply(workflow_state$selected_pressures, function(x) x$id)

          if (!(new_pressure$id %in% existing_ids)) {
            workflow_state$selected_pressures <- c(workflow_state$selected_pressures, list(new_pressure))

            showNotification(
              paste0("✅ Added suggested pressure: ", new_pressure$name),
              type = "message",
              duration = 3
            )
          } else {
            showNotification(
              "ℹ️ This pressure is already in your selection",
              type = "warning",
              duration = 2
            )
          }
        }
      }
    }
  })

  # ======================================================================
  # STEP 4: PREVENTIVE CONTROL SUGGESTIONS (based on activities & pressures)
  # ======================================================================

  observe({
    # Get selected activities and pressures
    selected_items <- c(
      workflow_state$selected_activities,
      workflow_state$selected_pressures
    )

    if (is.null(selected_items) || length(selected_items) == 0) {
      shinyjs::hide("suggestion_loading_control_preventive")
      shinyjs::hide("suggestions_list_control_preventive")
      shinyjs::hide("no_suggestions_control_preventive")
      shinyjs::hide("suggestion_error_control_preventive")
      shinyjs::show("suggestion_status_control_preventive")
      return()
    }

    # Show loading
    shinyjs::hide("suggestion_status_control_preventive")
    shinyjs::hide("suggestions_list_control_preventive")
    shinyjs::hide("no_suggestions_control_preventive")
    shinyjs::hide("suggestion_error_control_preventive")
    shinyjs::show("suggestion_loading_control_preventive")

    # Generate suggestions
    tryCatch({
      suggestions <- generate_ai_suggestions(
        vocabulary_data_reactive(),
        selected_items,
        target_type = "Control",
        max_suggestions = 5
      )

      if (length(suggestions) == 0) {
        shinyjs::hide("suggestion_loading_control_preventive")
        shinyjs::show("no_suggestions_control_preventive")
      } else {
        output$suggestions_content_control_preventive <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "control_preventive")
            })
          )
        })

        shinyjs::hide("suggestion_loading_control_preventive")
        shinyjs::show("suggestions_list_control_preventive")
      }
    }, error = function(e) {
      warning("Error generating control suggestions: ", e$message)
      shinyjs::hide("suggestion_loading_control_preventive")
      shinyjs::show("suggestion_error_control_preventive")
    })
  })

  # Handle preventive control suggestion clicks
  observeEvent(input$suggestion_clicked_control_preventive, {
    suggestion_data <- input$suggestion_clicked_control_preventive

    if (!is.null(suggestion_data) && !is.null(suggestion_data$id)) {
      vocab <- vocabulary_data_reactive()

      if (!is.null(vocab$controls)) {
        control_row <- vocab$controls[vocab$controls$id == suggestion_data$id, ]

        if (nrow(control_row) > 0) {
          new_control <- list(
            id = control_row$id[1],
            name = control_row$name[1],
            level1 = if ("level1" %in% names(control_row)) control_row$level1[1] else "Control",
            level2 = if ("level2" %in% names(control_row)) control_row$level2[1] else "",
            source = "AI Suggestion"
          )

          existing_ids <- sapply(workflow_state$selected_preventive_controls, function(x) x$id)

          if (!(new_control$id %in% existing_ids)) {
            workflow_state$selected_preventive_controls <- c(workflow_state$selected_preventive_controls, list(new_control))

            showNotification(
              paste0("✅ Added suggested control: ", new_control$name),
              type = "message",
              duration = 3
            )
          } else {
            showNotification(
              "ℹ️ This control is already in your selection",
              type = "warning",
              duration = 2
            )
          }
        }
      }
    }
  })

  # ======================================================================
  # STEP 5: CONSEQUENCE SUGGESTIONS (based on pressures)
  # ======================================================================

  observe({
    selected_pressures <- workflow_state$selected_pressures

    if (is.null(selected_pressures) || length(selected_pressures) == 0) {
      shinyjs::hide("suggestion_loading_consequence")
      shinyjs::hide("suggestions_list_consequence")
      shinyjs::hide("no_suggestions_consequence")
      shinyjs::hide("suggestion_error_consequence")
      shinyjs::show("suggestion_status_consequence")
      return()
    }

    shinyjs::hide("suggestion_status_consequence")
    shinyjs::hide("suggestions_list_consequence")
    shinyjs::hide("no_suggestions_consequence")
    shinyjs::hide("suggestion_error_consequence")
    shinyjs::show("suggestion_loading_consequence")

    tryCatch({
      suggestions <- generate_ai_suggestions(
        vocabulary_data_reactive(),
        selected_pressures,
        target_type = "Consequence",
        max_suggestions = 5
      )

      if (length(suggestions) == 0) {
        shinyjs::hide("suggestion_loading_consequence")
        shinyjs::show("no_suggestions_consequence")
      } else {
        output$suggestions_content_consequence <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "consequence")
            })
          )
        })

        shinyjs::hide("suggestion_loading_consequence")
        shinyjs::show("suggestions_list_consequence")
      }
    }, error = function(e) {
      warning("Error generating consequence suggestions: ", e$message)
      shinyjs::hide("suggestion_loading_consequence")
      shinyjs::show("suggestion_error_consequence")
    })
  })

  # Handle consequence suggestion clicks
  observeEvent(input$suggestion_clicked_consequence, {
    suggestion_data <- input$suggestion_clicked_consequence

    if (!is.null(suggestion_data) && !is.null(suggestion_data$id)) {
      vocab <- vocabulary_data_reactive()

      if (!is.null(vocab$consequences)) {
        consequence_row <- vocab$consequences[vocab$consequences$id == suggestion_data$id, ]

        if (nrow(consequence_row) > 0) {
          new_consequence <- list(
            id = consequence_row$id[1],
            name = consequence_row$name[1],
            level1 = if ("level1" %in% names(consequence_row)) consequence_row$level1[1] else "Consequence",
            level2 = if ("level2" %in% names(consequence_row)) consequence_row$level2[1] else "",
            source = "AI Suggestion"
          )

          existing_ids <- sapply(workflow_state$selected_consequences, function(x) x$id)

          if (!(new_consequence$id %in% existing_ids)) {
            workflow_state$selected_consequences <- c(workflow_state$selected_consequences, list(new_consequence))

            showNotification(
              paste0("✅ Added suggested consequence: ", new_consequence$name),
              type = "message",
              duration = 3
            )
          } else {
            showNotification(
              "ℹ️ This consequence is already in your selection",
              type = "warning",
              duration = 2
            )
          }
        }
      }
    }
  })

  # ======================================================================
  # STEP 6: PROTECTIVE CONTROL SUGGESTIONS (based on consequences)
  # ======================================================================

  observe({
    selected_consequences <- workflow_state$selected_consequences

    if (is.null(selected_consequences) || length(selected_consequences) == 0) {
      shinyjs::hide("suggestion_loading_control_protective")
      shinyjs::hide("suggestions_list_control_protective")
      shinyjs::hide("no_suggestions_control_protective")
      shinyjs::hide("suggestion_error_control_protective")
      shinyjs::show("suggestion_status_control_protective")
      return()
    }

    shinyjs::hide("suggestion_status_control_protective")
    shinyjs::hide("suggestions_list_control_protective")
    shinyjs::hide("no_suggestions_control_protective")
    shinyjs::hide("suggestion_error_control_protective")
    shinyjs::show("suggestion_loading_control_protective")

    tryCatch({
      suggestions <- generate_ai_suggestions(
        vocabulary_data_reactive(),
        selected_consequences,
        target_type = "Control",
        max_suggestions = 5
      )

      if (length(suggestions) == 0) {
        shinyjs::hide("suggestion_loading_control_protective")
        shinyjs::show("no_suggestions_control_protective")
      } else {
        output$suggestions_content_control_protective <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "control_protective")
            })
          )
        })

        shinyjs::hide("suggestion_loading_control_protective")
        shinyjs::show("suggestions_list_control_protective")
      }
    }, error = function(e) {
      warning("Error generating protective control suggestions: ", e$message)
      shinyjs::hide("suggestion_loading_control_protective")
      shinyjs::show("suggestion_error_control_protective")
    })
  })

  # Handle protective control suggestion clicks
  observeEvent(input$suggestion_clicked_control_protective, {
    suggestion_data <- input$suggestion_clicked_control_protective

    if (!is.null(suggestion_data) && !is.null(suggestion_data$id)) {
      vocab <- vocabulary_data_reactive()

      if (!is.null(vocab$controls)) {
        control_row <- vocab$controls[vocab$controls$id == suggestion_data$id, ]

        if (nrow(control_row) > 0) {
          new_control <- list(
            id = control_row$id[1],
            name = control_row$name[1],
            level1 = if ("level1" %in% names(control_row)) control_row$level1[1] else "Control",
            level2 = if ("level2" %in% names(control_row)) control_row$level2[1] else "",
            source = "AI Suggestion"
          )

          existing_ids <- sapply(workflow_state$selected_protective_controls, function(x) x$id)

          if (!(new_control$id %in% existing_ids)) {
            workflow_state$selected_protective_controls <- c(workflow_state$selected_protective_controls, list(new_control))

            showNotification(
              paste0("✅ Added suggested control: ", new_control$name),
              type = "message",
              duration = 3
            )
          } else {
            showNotification(
              "ℹ️ This control is already in your selection",
              type = "warning",
              duration = 2
            )
          }
        }
      }
    }
  })

  cat("✅ AI suggestion handlers initialized successfully\n")
  cat("   - Pressure suggestions: enabled\n")
  cat("   - Preventive control suggestions: enabled\n")
  cat("   - Consequence suggestions: enabled\n")
  cat("   - Protective control suggestions: enabled\n\n")

  return(TRUE)
}

cat("✅ Guided Workflow AI Suggestions Server module loaded\n\n")
