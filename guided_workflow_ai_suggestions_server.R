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
#' @param ai_enabled Reactive returning TRUE/FALSE for whether AI is enabled
#' @param ai_methods Reactive returning vector of methods (e.g., c("jaccard", "keyword"))
#' @param ai_max_suggestions Reactive returning max number of suggestions
init_ai_suggestion_handlers <- function(input, output, session, workflow_state, vocabulary_data_reactive,
                                       ai_enabled = reactive({FALSE}),
                                       ai_methods = reactive({c("jaccard")}),
                                       ai_max_suggestions = reactive({5})) {

  cat("🤖 Initializing AI suggestion handlers...\n")
  cat("   AI will be controlled by user settings\n")
  cat("🔍 [INIT DEBUG] Checking for required functions:\n")
  cat("   - find_vocabulary_links exists?", exists("find_vocabulary_links"), "\n")
  cat("   - generate_ai_suggestions exists?", exists("generate_ai_suggestions"), "\n")

  # Helper function to convert character vector to item list with vocab lookup
  convert_to_item_list <- function(names_vector, vocab_type, vocab_data) {
    cat("🔍 [CONVERT] convert_to_item_list called\n")
    cat("🔍 [CONVERT] vocab_type: ", vocab_type, "\n")
    cat("🔍 [CONVERT] names_vector: ", if (is.null(names_vector)) "NULL" else paste(names_vector, collapse = ", "), "\n")
    cat("🔍 [CONVERT] names_vector length: ", if (is.null(names_vector)) 0 else length(names_vector), "\n")

    if (is.null(names_vector) || length(names_vector) == 0) {
      cat("🔍 [CONVERT] Empty input - returning empty list\n")
      return(list())
    }

    vocab_df <- switch(vocab_type,
      "Activity" = vocab_data$activities,
      "Pressure" = vocab_data$pressures,
      "Consequence" = vocab_data$consequences,
      "Control" = vocab_data$controls,
      NULL
    )

    cat("🔍 [CONVERT] vocab_df is ", if (is.null(vocab_df)) "NULL" else paste("data.frame with", nrow(vocab_df), "rows"), "\n")

    if (is.null(vocab_df)) {
      cat("🔍 [CONVERT] vocab_df is NULL - returning empty list\n")
      return(list())
    }

    # Convert each name to item format
    # All vocab types use same structure: hierarchy, id, name, level
    result <- lapply(names_vector, function(item_name) {
      cat("🔍 [CONVERT] Processing item: '", item_name, "'\n", sep = "")

      # Try to find in vocabulary by matching the 'name' column
      row <- vocab_df[vocab_df$name == item_name, ]
      cat("🔍 [CONVERT] Matching rows found: ", nrow(row), "\n")

      if (nrow(row) > 0) {
        cat("🔍 [CONVERT] Found in vocabulary! ID: ", row$id[1], "\n")
        list(
          id = as.character(row$id[1]),
          name = as.character(row$name[1]),
          type = vocab_type
        )
      } else {
        cat("🔍 [CONVERT] Not found in vocabulary - creating custom entry\n")
        # Custom entry - use name as ID
        list(
          id = paste0("custom_", gsub("[^a-z0-9_]", "_", tolower(item_name))),
          name = item_name,
          type = vocab_type
        )
      }
    })

    cat("🔍 [CONVERT] Converted ", length(result), " items\n")
    return(result)
  }

  # Check if AI linker is available
  ai_available <- exists("find_vocabulary_links") && exists("generate_ai_suggestions")

  if (!ai_available) {
    cat("⚠️ AI linker not available - suggestions disabled\n")
    return(NULL)
  }

  # Initialize feedback tracker if available
  feedback_enabled <- FALSE
  if (exists("init_feedback_tracker")) {
    tryCatch({
      init_feedback_tracker()
      feedback_enabled <- TRUE
      cat("✅ Feedback tracking enabled\n")
    }, error = function(e) {
      cat("⚠️ Feedback tracking unavailable:", e$message, "\n")
    })
  }

  # Require shinyjs for showing/hiding elements
  if (!requireNamespace("shinyjs", quietly = TRUE)) {
    warning("shinyjs package required for AI suggestions")
    return(NULL)
  }

  # ======================================================================
  # STEP 3: ACTIVITY SUGGESTIONS (based on central problem from Step 2)
  # ======================================================================

  cat("🔧 [INIT DEBUG] Registering activity suggestions observer...\n")

  # Observer for activity suggestions based on central problem
  observe({
    cat("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    cat("🔍 [AI SUGGESTIONS] Activity observer triggered!\n")

    # Check if AI is enabled FIRST
    if (!ai_enabled()) {
      cat("🔍 [AI SUGGESTIONS] AI is DISABLED - skipping activity suggestions\n")
      cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
      return()
    }

    # Get central problem from Step 2
    state <- workflow_state()
    problem_statement <- state$project_data$problem_statement

    cat("🔍 [AI SUGGESTIONS] Problem statement:", if(is.null(problem_statement)) "NULL" else problem_statement, "\n")

    if (is.null(problem_statement) || nchar(trimws(problem_statement)) < 5) {
      cat("🔍 [AI SUGGESTIONS] No problem statement or too short - hiding suggestions\n")
      shinyjs::hide(id = session$ns("suggestion_loading_activity"))
      shinyjs::hide(id = session$ns("suggestions_list_activity"))
      shinyjs::hide(id = session$ns("no_suggestions_activity"))
      shinyjs::hide(id = session$ns("suggestion_error_activity"))
      shinyjs::show(id = session$ns("suggestion_status_activity"))
      return()
    }

    cat("🔍 [AI SUGGESTIONS] Generating activity suggestions based on problem...\n")

    # Show loading
    shinyjs::hide(id = session$ns("suggestion_status_activity"))
    shinyjs::hide(id = session$ns("suggestions_list_activity"))
    shinyjs::hide(id = session$ns("no_suggestions_activity"))
    shinyjs::hide(id = session$ns("suggestion_error_activity"))
    shinyjs::show(id = session$ns("suggestion_loading_activity"))

    # Generate suggestions
    tryCatch({
      vocab_data <- vocabulary_data_reactive()

      # Use text analysis to find relevant activities
      # Search for activities that match keywords from the problem statement

      # Use robust word splitting (non-word character boundary)
      # This is more reliable than regex patterns that can fail on special characters
      raw_split <- unlist(strsplit(problem_statement, "\\W+"))
      problem_keywords <- tolower(raw_split)

      # Filter short words and empty strings
      problem_keywords <- problem_keywords[nchar(problem_keywords) > 3]

      cat("🔍 [AI SUGGESTIONS] Extracted keywords:", paste(problem_keywords, collapse = ", "), "\n")

      # Find activities with matching keywords in their names or IDs
      matching_activities <- list()
      for (i in seq_len(nrow(vocab_data$activities))) {
        activity_name <- tolower(vocab_data$activities$name[i])
        activity_id <- tolower(vocab_data$activities$id[i])

        # Check if any keywords match
        for (keyword in problem_keywords) {
          if (grepl(keyword, activity_name) || grepl(keyword, activity_id)) {
            # Only include level 2+ items (not category headers)
            if (!is.na(vocab_data$activities$level[i]) && vocab_data$activities$level[i] >= 2) {
              matching_activities <- c(matching_activities, list(list(
                id = vocab_data$activities$id[i],
                to_name = vocab_data$activities$name[i],  # Use 'to_name' to match expected field
                to_type = "Activity",
                confidence = 0.8,  # High confidence for keyword match
                confidence_level = "high",  # For badge display
                method = "keyword",
                reasoning = paste("Matches keyword:", keyword)
              )))
              break
            }
          }
        }
      }

      # Limit to max suggestions
      suggestions <- matching_activities
      if (length(suggestions) > ai_max_suggestions()) {
        suggestions <- suggestions[1:ai_max_suggestions()]
      }

      cat("🔍 [AI SUGGESTIONS] Found", length(suggestions), "activity suggestions\n")

      if (length(suggestions) == 0) {
        shinyjs::hide(id = session$ns("suggestion_loading_activity"))
        shinyjs::show(id = session$ns("no_suggestions_activity"))
      } else {
        # Render suggestions
        output$suggestions_content_activity <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "activity")
            })
          )
        })

        cat("🔍 [AI SUGGESTIONS] Hiding loading, showing suggestions list...\n")
        cat("🔍 [AI SUGGESTIONS] Namespaced ID for suggestions_list:", session$ns("suggestions_list_activity"), "\n")

        # Use JavaScript setTimeout to ensure UI is rendered before trying to show/hide
        suggestions_id <- session$ns("suggestions_list_activity")
        loading_id <- session$ns("suggestion_loading_activity")
        status_id <- session$ns("suggestion_status_activity")

        js_code <- sprintf("
          setTimeout(function() {
            console.log('[AI SUGGESTIONS] Delayed show - checking elements...');
            console.log('[AI SUGGESTIONS] Looking for ID: %s');

            // List ALL elements with 'suggestion' in ID
            var allSuggestionEls = $('[id*=\"suggestion\"]');
            console.log('[AI SUGGESTIONS] Found', allSuggestionEls.length, 'elements with suggestion in ID:');
            allSuggestionEls.each(function() {
              console.log('  -', this.id, '(visible:', $(this).is(':visible'), ')');
            });

            var suggestionsEl = $('#%s');
            var loadingEl = $('#%s');
            var statusEl = $('#%s');

            console.log('TARGET suggestions element exists:', suggestionsEl.length);
            console.log('TARGET loading element exists:', loadingEl.length);
            console.log('TARGET status element exists:', statusEl.length);

            if (suggestionsEl.length > 0) {
              loadingEl.hide();
              statusEl.hide();
              suggestionsEl.show();
              console.log('[AI SUGGESTIONS] Successfully showed suggestions panel!');
            } else {
              console.error('[AI SUGGESTIONS] Suggestions element not found in DOM!');
            }
          }, 500);
        ", suggestions_id, suggestions_id, loading_id, status_id)

        shinyjs::runjs(js_code)
        cat("✅ [AI SUGGESTIONS] Activity suggestions display scheduled via JavaScript!\n")
      }
    }, error = function(e) {
      cat("❌ [AI SUGGESTIONS] ERROR in activity suggestions:\n")
      cat("   Error message: ", e$message, "\n")
      warning("Error generating activity suggestions: ", e$message)
      shinyjs::hide(id = session$ns("suggestion_loading_activity"))
      shinyjs::show(id = session$ns("suggestion_error_activity"))
    })
  })

  # Handle activity suggestion clicks
  observeEvent(input$suggestion_clicked_activity, {
    cat("\n🔔 [CLICK HANDLER] Activity suggestion clicked!\n")
    suggestion_data <- input$suggestion_clicked_activity
    cat("🔔 [CLICK HANDLER] Suggestion data:", if(is.null(suggestion_data)) "NULL" else paste(names(suggestion_data), collapse = ", "), "\n")
    cat("🔔 [CLICK HANDLER] Suggestion ID:", if(is.null(suggestion_data$id)) "NULL" else suggestion_data$id, "\n")

    if (!is.null(suggestion_data) && !is.null(suggestion_data$id)) {
      # Get the full item from vocabulary
      vocab <- vocabulary_data_reactive()

      if (!is.null(vocab$activities)) {
        activity_row <- vocab$activities[vocab$activities$id == suggestion_data$id, ]

        if (nrow(activity_row) > 0) {
          # Add to selected activities (trigger the add button)
          activity_name <- activity_row$name[1]

          # Add to workflow state
          state <- workflow_state()
          current_activities <- state$project_data$activities
          if (is.null(current_activities)) current_activities <- character(0)

          if (!(activity_name %in% current_activities)) {
            current_activities <- c(current_activities, activity_name)
            state$project_data$activities <- current_activities
            workflow_state(state)

            showNotification(
              paste0("✅ Added suggested activity: ", activity_name),
              type = "message",
              duration = 3
            )
          } else {
            showNotification(
              "ℹ️ This activity is already in your selection",
              type = "warning",
              duration = 2
            )
          }
        }
      }
    }
  })

  # ======================================================================
  # STEP 3: PRESSURE SUGGESTIONS (based on selected activities)
  # ======================================================================

  # Observer for pressure suggestions
  observe({
    cat("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    cat("🔍 [AI SUGGESTIONS] Pressure observer triggered!\n")
    cat("🔍 [AI SUGGESTIONS] Checking AI enabled status...\n")

    ai_status <- ai_enabled()
    cat("🔍 [AI SUGGESTIONS] ai_enabled() returned:", ai_status, "\n")
    cat("🔍 [AI SUGGESTIONS] ai_enabled() class:", class(ai_status), "\n")

    # Check if AI is enabled FIRST (before any expensive operations)
    if (!ai_status) {
      cat("🔍 [AI SUGGESTIONS] AI is DISABLED in settings - skipping\n")
      cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
      return()
    }
    cat("🔍 [AI SUGGESTIONS] AI is ENABLED in settings - proceeding\n")

    # Get current activities directly from state
    state <- workflow_state()
    selected_activities_names <- state$project_data$activities
    cat("🔍 [AI SUGGESTIONS] Selected activities: ",
        if (is.null(selected_activities_names)) "NULL" else paste(selected_activities_names, collapse = ", "), "\n")
    cat("🔍 [AI SUGGESTIONS] Activity count: ",
        if (is.null(selected_activities_names)) 0 else length(selected_activities_names), "\n")

    if (is.null(selected_activities_names) || length(selected_activities_names) == 0) {
      cat("🔍 [AI SUGGESTIONS] No activities selected - hiding suggestions UI\n")
      # Hide suggestions (use session$ns for proper namespacing in module)
      shinyjs::hide(id = "suggestion_loading_pressure", asis = FALSE)
      shinyjs::hide(id = "suggestions_list_pressure", asis = FALSE)
      shinyjs::hide(id = "no_suggestions_pressure", asis = FALSE)
      shinyjs::hide(id = "suggestion_error_pressure", asis = FALSE)
      shinyjs::show(id = "suggestion_status_pressure", asis = FALSE)
      return()
    }

    cat("🔍 [AI SUGGESTIONS] Activities found! Showing loading UI...\n")
    # Show loading (use session$ns for proper namespacing in module)
    shinyjs::hide(id = "suggestion_status_pressure", asis = FALSE)
    shinyjs::hide(id = "suggestions_list_pressure", asis = FALSE)
    shinyjs::hide(id = "no_suggestions_pressure", asis = FALSE)
    shinyjs::hide(id = "suggestion_error_pressure", asis = FALSE)
    shinyjs::show(id = "suggestion_loading_pressure", asis = FALSE)

    # Generate suggestions
    tryCatch({
      cat("🔍 [AI SUGGESTIONS] Starting suggestion generation...\n")

      # Convert character vector to item list format
      vocab_data <- vocabulary_data_reactive()
      cat("🔍 [AI SUGGESTIONS] Got vocabulary data\n")
      cat("🔍 [AI SUGGESTIONS] Vocab activities count: ", nrow(vocab_data$activities), "\n")

      selected_activities <- convert_to_item_list(selected_activities_names, "Activity", vocab_data)
      cat("🔍 [AI SUGGESTIONS] Converted to item list. Count: ", length(selected_activities), "\n")

      if (length(selected_activities) > 0) {
        cat("🔍 [AI SUGGESTIONS] First activity item structure:\n")
        print(str(selected_activities[[1]]))
      }

      cat("🔍 [AI SUGGESTIONS] Calling generate_ai_suggestions()...\n")
      cat("🔍 [AI SUGGESTIONS] Using methods: ", paste(ai_methods(), collapse = ", "), "\n")
      cat("🔍 [AI SUGGESTIONS] Max suggestions: ", ai_max_suggestions(), "\n")

      suggestions <- generate_ai_suggestions(
        vocab_data,
        selected_activities,
        target_type = "Pressure",
        max_suggestions = ai_max_suggestions(),
        methods = ai_methods()
      )

      cat("🔍 [AI SUGGESTIONS] generate_ai_suggestions() returned. Count: ", length(suggestions), "\n")

      if (length(suggestions) == 0) {
        cat("🔍 [AI SUGGESTIONS] No suggestions generated - showing 'no suggestions' message\n")
        shinyjs::hide(id = "suggestion_loading_pressure", asis = FALSE)
        shinyjs::show(id = "no_suggestions_pressure", asis = FALSE)
      } else {
        cat("🔍 [AI SUGGESTIONS] Got ", length(suggestions), " suggestions! Rendering UI...\n")

        # Render suggestions
        output$suggestions_content_pressure <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "pressure")
            })
          )
        })

        cat("🔍 [AI SUGGESTIONS] UI rendered. Showing suggestions list...\n")
        shinyjs::hide(id = "suggestion_loading_pressure", asis = FALSE)
        shinyjs::show(id = "suggestions_list_pressure", asis = FALSE)
        cat("✅ [AI SUGGESTIONS] Pressure suggestions displayed successfully!\n")
      }
    }, error = function(e) {
      cat("❌ [AI SUGGESTIONS] ERROR in pressure suggestions:\n")
      cat("   Error message: ", e$message, "\n")
      cat("   Error call: ", deparse(e$call), "\n")
      print(traceback())
      warning("Error generating pressure suggestions: ", e$message)
      shinyjs::hide(id = "suggestion_loading_pressure", asis = FALSE)
      shinyjs::show(id = "suggestion_error_pressure", asis = FALSE)
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
          state <- workflow_state()
          existing_ids <- sapply(state$selected_pressures, function(x) x$id)

          if (!(new_pressure$id %in% existing_ids)) {
            state$selected_pressures <- c(state$selected_pressures, list(new_pressure))
            workflow_state(state)

            # Log feedback (accepted)
            if (feedback_enabled && exists("log_suggestion_feedback")) {
              tryCatch({
                log_suggestion_feedback(
                  suggestion = suggestion_data,
                  action = "accepted",
                  session_id = session$token,
                  step = "step3_pressure"
                )
              }, error = function(e) {
                # Silently fail - don't interrupt user workflow
              })
            }

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
    cat("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    cat("🔍 [AI SUGGESTIONS] Preventive control observer triggered!\n")

    # Check if AI is enabled FIRST
    if (!ai_enabled()) {
      cat("🔍 [AI SUGGESTIONS] AI is DISABLED - skipping preventive control suggestions\n")
      cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
      return()
    }

    # Get selected activities and pressures from reactive state
    state <- workflow_state()
    activity_names <- state$project_data$activities
    pressure_names <- state$project_data$pressures

    if ((is.null(activity_names) || length(activity_names) == 0) &&
        (is.null(pressure_names) || length(pressure_names) == 0)) {
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
      # Convert character vectors to item list format
      vocab_data <- vocabulary_data_reactive()
      selected_items <- c(
        convert_to_item_list(activity_names, "Activity", vocab_data),
        convert_to_item_list(pressure_names, "Pressure", vocab_data)
      )

      suggestions <- generate_ai_suggestions(
        vocab_data,
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

          state <- workflow_state()
          existing_ids <- sapply(state$selected_preventive_controls, function(x) x$id)

          if (!(new_control$id %in% existing_ids)) {
            state$selected_preventive_controls <- c(state$selected_preventive_controls, list(new_control))
            workflow_state(state)

            # Log feedback (accepted)
            if (feedback_enabled && exists("log_suggestion_feedback")) {
              tryCatch({
                log_suggestion_feedback(
                  suggestion = suggestion_data,
                  action = "accepted",
                  session_id = session$token,
                  step = "step4_preventive_control"
                )
              }, error = function(e) { })
            }

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
    cat("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    cat("🔍 [AI SUGGESTIONS] Consequence observer triggered!\n")

    # Check if AI is enabled FIRST
    if (!ai_enabled()) {
      cat("🔍 [AI SUGGESTIONS] AI is DISABLED - skipping consequence suggestions\n")
      cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
      return()
    }

    # Get selected pressures from reactive state
    state <- workflow_state()
    pressure_names <- state$project_data$pressures

    if (is.null(pressure_names) || length(pressure_names) == 0) {
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
      # Convert character vector to item list format
      vocab_data <- vocabulary_data_reactive()
      selected_pressures <- convert_to_item_list(pressure_names, "Pressure", vocab_data)

      suggestions <- generate_ai_suggestions(
        vocab_data,
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

          state <- workflow_state()
          existing_ids <- sapply(state$selected_consequences, function(x) x$id)

          if (!(new_consequence$id %in% existing_ids)) {
            state$selected_consequences <- c(state$selected_consequences, list(new_consequence))
            workflow_state(state)

            # Log feedback (accepted)
            if (feedback_enabled && exists("log_suggestion_feedback")) {
              tryCatch({
                log_suggestion_feedback(
                  suggestion = suggestion_data,
                  action = "accepted",
                  session_id = session$token,
                  step = "step5_consequence"
                )
              }, error = function(e) { })
            }

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
    cat("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    cat("🔍 [AI SUGGESTIONS] Protective control observer triggered!\n")

    # Check if AI is enabled FIRST
    if (!ai_enabled()) {
      cat("🔍 [AI SUGGESTIONS] AI is DISABLED - skipping protective control suggestions\n")
      cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
      return()
    }

    # Get selected consequences from reactive state
    state <- workflow_state()
    consequence_names <- state$project_data$consequences

    if (is.null(consequence_names) || length(consequence_names) == 0) {
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
      # Convert character vector to item list format
      vocab_data <- vocabulary_data_reactive()
      selected_consequences <- convert_to_item_list(consequence_names, "Consequence", vocab_data)

      suggestions <- generate_ai_suggestions(
        vocab_data,
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

          state <- workflow_state()
          existing_ids <- sapply(state$selected_protective_controls, function(x) x$id)

          if (!(new_control$id %in% existing_ids)) {
            state$selected_protective_controls <- c(state$selected_protective_controls, list(new_control))
            workflow_state(state)

            # Log feedback (accepted)
            if (feedback_enabled && exists("log_suggestion_feedback")) {
              tryCatch({
                log_suggestion_feedback(
                  suggestion = suggestion_data,
                  action = "accepted",
                  session_id = session$token,
                  step = "step6_protective_control"
                )
              }, error = function(e) { })
            }

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

  # Save feedback on exit (if enabled)
  session$onSessionEnded(function() {
    if (feedback_enabled && exists("save_feedback")) {
      tryCatch({
        save_feedback(quiet = TRUE)
      }, error = function(e) {
        # Silent failure
      })
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
