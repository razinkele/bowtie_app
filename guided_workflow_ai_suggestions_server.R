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


  # Helper function to convert character vector to item list with vocab lookup
  convert_to_item_list <- function(names_vector, vocab_type, vocab_data) {

    if (is.null(names_vector) || length(names_vector) == 0) {
      return(list())
    }

    vocab_df <- switch(vocab_type,
      "Activity" = vocab_data$activities,
      "Pressure" = vocab_data$pressures,
      "Consequence" = vocab_data$consequences,
      "Control" = vocab_data$controls,
      NULL
    )


    if (is.null(vocab_df)) {
      return(list())
    }

    # Convert each name to item format
    # All vocab types use same structure: hierarchy, id, name, level
    result <- lapply(names_vector, function(item_name) {

      # Try to find in vocabulary by matching the 'name' column
      row <- vocab_df[vocab_df$name == item_name, ]

      if (nrow(row) > 0) {
        list(
          id = as.character(row$id[1]),
          name = as.character(row$name[1]),
          type = vocab_type
        )
      } else {
        # Custom entry - use name as ID
        list(
          id = paste0("custom_", gsub("[^a-z0-9_]", "_", tolower(item_name))),
          name = item_name,
          type = vocab_type
        )
      }
    })

    return(result)
  }

  # Check if AI linker is available
  ai_available <- exists("find_vocabulary_links") && exists("generate_ai_suggestions")

  if (!ai_available) {
    bowtie_log("AI linker not available - suggestions disabled", level = "warning")
    return(NULL)
  }

  # Initialize feedback tracker if available
  feedback_enabled <- FALSE
  if (exists("init_feedback_tracker")) {
    tryCatch({
      init_feedback_tracker()
      feedback_enabled <- TRUE
    }, error = function(e) {
      bowtie_log(paste("Feedback tracking unavailable:", e$message), level = "warning")
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


  # Observer for activity suggestions based on central problem
  observe({

    # Check if AI is enabled FIRST
    if (!ai_enabled()) {
      return()
    }

    # Get central problem from Step 2
    state <- workflow_state()
    problem_statement <- state$project_data$problem_statement


    if (is.null(problem_statement) || nchar(trimws(problem_statement)) < 5) {
      shinyjs::hide(id = session$ns("suggestion_loading_activity"))
      shinyjs::hide(id = session$ns("suggestions_list_activity"))
      shinyjs::hide(id = session$ns("no_suggestions_activity"))
      shinyjs::hide(id = session$ns("suggestion_error_activity"))
      shinyjs::show(id = session$ns("suggestion_status_activity"))
      return()
    }


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


        # Use JavaScript setTimeout to ensure UI is rendered before trying to show/hide
        suggestions_id <- session$ns("suggestions_list_activity")
        loading_id <- session$ns("suggestion_loading_activity")
        status_id <- session$ns("suggestion_status_activity")

        js_code <- sprintf("
          // DOM polling mechanism - more robust than fixed timeout
          setTimeout(function() {
            console.log('[AI SUGGESTIONS] Starting DOM polling for activity suggestions...');
            var attempts = 0;
            var maxAttempts = 50; // Poll for up to 5 seconds (50 * 100ms)

            var checkExist = setInterval(function() {
              attempts++;

              var suggestionsEl = $('#%s');
              var loadingEl = $('#%s');
              var statusEl = $('#%s');

              if (suggestionsEl.length > 0) {
                clearInterval(checkExist);
                console.log('[AI SUGGESTIONS] ✅ Elements found after', attempts * 100, 'ms');

                // Hide loading/status and show suggestions
                loadingEl.hide();
                statusEl.hide();
                suggestionsEl.show();

                console.log('[AI SUGGESTIONS] Successfully showed activity suggestions panel!');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - elements not found after 5 seconds');
                console.log('[AI SUGGESTIONS] Looking for ID: %s');

                // Debug: List all elements with 'suggestion' in ID
                var allSuggestionEls = $('[id*=\"suggestion\"]');
                console.log('[AI SUGGESTIONS] Found', allSuggestionEls.length, 'total suggestion elements:');
                allSuggestionEls.each(function() {
                  console.log('  -', this.id);
                });
              }
            }, 100); // Check every 100ms
          }, 200); // Start checking after 200ms initial delay
        ", suggestions_id, loading_id, status_id, suggestions_id)

        shinyjs::runjs(js_code)
      }
    }, error = function(e) {
      bowtie_log(paste("Error generating activity suggestions:", e$message), level = "error")
      shinyjs::hide(id = session$ns("suggestion_loading_activity"))
      shinyjs::show(id = session$ns("suggestion_error_activity"))
    })
  })

  # Handle activity suggestion "Add" button clicks
  # The suggestion cards create buttons like: add_suggestion_activity_1, add_suggestion_activity_2, etc.
  # We need to observe all possible button clicks dynamically
  # Use lapply to avoid closure issues with loops
  lapply(1:10, function(i) {
    button_id <- paste0("add_suggestion_activity_", i)

    observeEvent(input[[button_id]], {

        # Get the current suggestions from the reactive
        state <- workflow_state()
        problem_statement <- state$project_data$problem_statement

        if (!is.null(problem_statement) && nchar(trimws(problem_statement)) >= 5) {
          # Re-generate suggestions to get the data (we don't store them)
          vocab_data <- vocabulary_data_reactive()

          # Extract keywords
          raw_split <- unlist(strsplit(problem_statement, "\\W+"))
          problem_keywords <- tolower(raw_split)
          problem_keywords <- problem_keywords[nchar(problem_keywords) > 3]

          # Find matching activities
          matching_activities <- list()
          for (j in seq_len(nrow(vocab_data$activities))) {
            activity_name <- tolower(vocab_data$activities$name[j])
            activity_id <- tolower(vocab_data$activities$id[j])

            for (keyword in problem_keywords) {
              if (grepl(keyword, activity_name) || grepl(keyword, activity_id)) {
                if (!is.na(vocab_data$activities$level[j]) && vocab_data$activities$level[j] >= 2) {
                  matching_activities <- c(matching_activities, list(list(
                    id = vocab_data$activities$id[j],
                    name = vocab_data$activities$name[j]
                  )))
                  break
                }
              }
            }
          }

          # Limit to max suggestions
          if (length(matching_activities) > ai_max_suggestions()) {
            matching_activities <- matching_activities[1:ai_max_suggestions()]
          }

          # Get the clicked suggestion
          if (i <= length(matching_activities)) {
            suggestion <- matching_activities[[i]]
            activity_name <- suggestion$name


            # Add to workflow state
            current_activities <- state$project_data$activities
            if (is.null(current_activities)) current_activities <- character(0)

            if (!(activity_name %in% current_activities)) {
              current_activities <- c(current_activities, activity_name)
              state$project_data$activities <- current_activities
              workflow_state(state)


              notify_success(paste0("✅ Added suggested activity: ", activity_name), duration = 3)
            } else {
              notify_warning("ℹ️ This activity is already in your selection", duration = 3)
            }
          }
        }
      }, ignoreInit = TRUE)
  })

  # Legacy handler (keeping for backward compatibility)
  observeEvent(input$suggestion_clicked_activity, {
    suggestion_data <- input$suggestion_clicked_activity

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

            notify_success(paste0("✅ Added suggested activity: ", activity_name), duration = 3)
          } else {
            notify_warning("ℹ️ This activity is already in your selection", duration = 2)
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

    ai_status <- ai_enabled()

    # Check if AI is enabled FIRST (before any expensive operations)
    if (!ai_status) {
      return()
    }

    # Get current activities directly from state
    state <- workflow_state()
    selected_activities_names <- state$project_data$activities

    if (is.null(selected_activities_names) || length(selected_activities_names) == 0) {
      # Hide suggestions (use session$ns for proper namespacing in module)
      shinyjs::hide(id = "suggestion_loading_pressure", asis = FALSE)
      shinyjs::hide(id = "suggestions_list_pressure", asis = FALSE)
      shinyjs::hide(id = "no_suggestions_pressure", asis = FALSE)
      shinyjs::hide(id = "suggestion_error_pressure", asis = FALSE)
      shinyjs::show(id = "suggestion_status_pressure", asis = FALSE)
      return()
    }

    # Show loading (use session$ns for proper namespacing in module)
    shinyjs::hide(id = "suggestion_status_pressure", asis = FALSE)
    shinyjs::hide(id = "suggestions_list_pressure", asis = FALSE)
    shinyjs::hide(id = "no_suggestions_pressure", asis = FALSE)
    shinyjs::hide(id = "suggestion_error_pressure", asis = FALSE)
    shinyjs::show(id = "suggestion_loading_pressure", asis = FALSE)

    # Generate suggestions
    tryCatch({

      # Convert character vector to item list format
      vocab_data <- vocabulary_data_reactive()

      selected_activities <- convert_to_item_list(selected_activities_names, "Activity", vocab_data)

      # Debug logging removed - use bowtie_log for debug output if needed


      suggestions <- generate_ai_suggestions(
        vocab_data,
        selected_activities,
        target_type = "Pressure",
        max_suggestions = ai_max_suggestions(),
        methods = ai_methods()
      )


      if (length(suggestions) == 0) {

        # Use DOM polling for no suggestions message too
        loading_id <- session$ns("suggestion_loading_pressure")
        no_sugg_id <- session$ns("no_suggestions_pressure")

        js_code <- sprintf("
          setTimeout(function() {
            var attempts = 0;
            var maxAttempts = 50;

            var checkExist = setInterval(function() {
              attempts++;
              var noSuggestionsEl = $('#%s');
              var loadingEl = $('#%s');

              if (noSuggestionsEl.length > 0) {
                clearInterval(checkExist);
                loadingEl.hide();
                noSuggestionsEl.show();
                console.log('[AI SUGGESTIONS] ✅ Showed no-suggestions message for pressure');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - no-suggestions element not found');
              }
            }, 100);
          }, 200);
        ", no_sugg_id, loading_id)

        shinyjs::runjs(js_code)
      } else {

        # Render suggestions
        output$suggestions_content_pressure <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "pressure")
            })
          )
        })


        # Use DOM polling mechanism
        suggestions_id <- session$ns("suggestions_list_pressure")
        loading_id <- session$ns("suggestion_loading_pressure")

        js_code <- sprintf("
          // DOM polling mechanism for pressure suggestions
          setTimeout(function() {
            console.log('[AI SUGGESTIONS] Starting DOM polling for pressure suggestions...');
            var attempts = 0;
            var maxAttempts = 50;

            var checkExist = setInterval(function() {
              attempts++;

              var suggestionsEl = $('#%s');
              var loadingEl = $('#%s');

              if (suggestionsEl.length > 0) {
                clearInterval(checkExist);
                console.log('[AI SUGGESTIONS] ✅ Pressure elements found after', attempts * 100, 'ms');

                loadingEl.hide();
                suggestionsEl.show();

                console.log('[AI SUGGESTIONS] Successfully showed pressure suggestions panel!');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - pressure elements not found after 5 seconds');
              }
            }, 100);
          }, 200);
        ", suggestions_id, loading_id)

        shinyjs::runjs(js_code)
      }
    }, error = function(e) {
      bowtie_log(paste("Error generating pressure suggestions:", e$message), level = "error")
      bowtie_log(paste("Error call:", deparse(e$call)), level = "debug")
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
                # Log error but don't interrupt user workflow
                bowtie_log(paste("Failed to log suggestion feedback:", e$message), level = "warning")
              })
            }

            notify_success(paste0("✅ Added suggested pressure: ", new_pressure$name), duration = 3)
          } else {
            notify_warning("ℹ️ This pressure is already in your selection", duration = 2)
          }
        }
      }
    }
  })

  # ======================================================================
  # STEP 4: PREVENTIVE CONTROL SUGGESTIONS (based on activities & pressures)
  # ======================================================================

  observe({

    # Check if AI is enabled FIRST
    if (!ai_enabled()) {
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
        # Use DOM polling for no suggestions message
        loading_id <- session$ns("suggestion_loading_control_preventive")
        no_sugg_id <- session$ns("no_suggestions_control_preventive")

        js_code <- sprintf("
          setTimeout(function() {
            var attempts = 0;
            var maxAttempts = 50;

            var checkExist = setInterval(function() {
              attempts++;
              var noSuggestionsEl = $('#%s');
              var loadingEl = $('#%s');

              if (noSuggestionsEl.length > 0) {
                clearInterval(checkExist);
                loadingEl.hide();
                noSuggestionsEl.show();
                console.log('[AI SUGGESTIONS] ✅ Showed no-suggestions message for preventive controls');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - preventive control no-suggestions element not found');
              }
            }, 100);
          }, 200);
        ", no_sugg_id, loading_id)

        shinyjs::runjs(js_code)
      } else {
        output$suggestions_content_control_preventive <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "control_preventive")
            })
          )
        })

        # Use DOM polling mechanism
        suggestions_id <- session$ns("suggestions_list_control_preventive")
        loading_id <- session$ns("suggestion_loading_control_preventive")

        js_code <- sprintf("
          setTimeout(function() {
            console.log('[AI SUGGESTIONS] Starting DOM polling for preventive control suggestions...');
            var attempts = 0;
            var maxAttempts = 50;

            var checkExist = setInterval(function() {
              attempts++;

              var suggestionsEl = $('#%s');
              var loadingEl = $('#%s');

              if (suggestionsEl.length > 0) {
                clearInterval(checkExist);
                console.log('[AI SUGGESTIONS] ✅ Preventive control elements found after', attempts * 100, 'ms');

                loadingEl.hide();
                suggestionsEl.show();

                console.log('[AI SUGGESTIONS] Successfully showed preventive control suggestions!');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - preventive control elements not found');
              }
            }, 100);
          }, 200);
        ", suggestions_id, loading_id)

        shinyjs::runjs(js_code)
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
              }, error = function(e) {
                bowtie_log(paste("Failed to log preventive control feedback:", e$message), level = "warning")
              })
            }

            notify_success(paste0("✅ Added suggested control: ", new_control$name), duration = 3)
          } else {
            notify_warning("ℹ️ This control is already in your selection", duration = 2)
          }
        }
      }
    }
  })

  # ======================================================================
  # STEP 5: CONSEQUENCE SUGGESTIONS (based on pressures)
  # ======================================================================

  observe({

    # Check if AI is enabled FIRST
    if (!ai_enabled()) {
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
        # Use DOM polling for no suggestions message
        loading_id <- session$ns("suggestion_loading_consequence")
        no_sugg_id <- session$ns("no_suggestions_consequence")

        js_code <- sprintf("
          setTimeout(function() {
            var attempts = 0;
            var maxAttempts = 50;

            var checkExist = setInterval(function() {
              attempts++;
              var noSuggestionsEl = $('#%s');
              var loadingEl = $('#%s');

              if (noSuggestionsEl.length > 0) {
                clearInterval(checkExist);
                loadingEl.hide();
                noSuggestionsEl.show();
                console.log('[AI SUGGESTIONS] ✅ Showed no-suggestions message for consequences');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - consequence no-suggestions element not found');
              }
            }, 100);
          }, 200);
        ", no_sugg_id, loading_id)

        shinyjs::runjs(js_code)
      } else {
        output$suggestions_content_consequence <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "consequence")
            })
          )
        })

        # Use DOM polling mechanism
        suggestions_id <- session$ns("suggestions_list_consequence")
        loading_id <- session$ns("suggestion_loading_consequence")

        js_code <- sprintf("
          setTimeout(function() {
            console.log('[AI SUGGESTIONS] Starting DOM polling for consequence suggestions...');
            var attempts = 0;
            var maxAttempts = 50;

            var checkExist = setInterval(function() {
              attempts++;

              var suggestionsEl = $('#%s');
              var loadingEl = $('#%s');

              if (suggestionsEl.length > 0) {
                clearInterval(checkExist);
                console.log('[AI SUGGESTIONS] ✅ Consequence elements found after', attempts * 100, 'ms');

                loadingEl.hide();
                suggestionsEl.show();

                console.log('[AI SUGGESTIONS] Successfully showed consequence suggestions!');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - consequence elements not found');
              }
            }, 100);
          }, 200);
        ", suggestions_id, loading_id)

        shinyjs::runjs(js_code)
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
              }, error = function(e) {
                bowtie_log(paste("Failed to log consequence feedback:", e$message), level = "warning")
              })
            }

            notify_success(paste0("✅ Added suggested consequence: ", new_consequence$name), duration = 3)
          } else {
            notify_warning("ℹ️ This consequence is already in your selection", duration = 2)
          }
        }
      }
    }
  })

  # ======================================================================
  # STEP 6: PROTECTIVE CONTROL SUGGESTIONS (based on consequences)
  # ======================================================================

  observe({

    # Check if AI is enabled FIRST
    if (!ai_enabled()) {
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
        # Use DOM polling for no suggestions message
        loading_id <- session$ns("suggestion_loading_control_protective")
        no_sugg_id <- session$ns("no_suggestions_control_protective")

        js_code <- sprintf("
          setTimeout(function() {
            var attempts = 0;
            var maxAttempts = 50;

            var checkExist = setInterval(function() {
              attempts++;
              var noSuggestionsEl = $('#%s');
              var loadingEl = $('#%s');

              if (noSuggestionsEl.length > 0) {
                clearInterval(checkExist);
                loadingEl.hide();
                noSuggestionsEl.show();
                console.log('[AI SUGGESTIONS] ✅ Showed no-suggestions message for protective controls');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - protective control no-suggestions element not found');
              }
            }, 100);
          }, 200);
        ", no_sugg_id, loading_id)

        shinyjs::runjs(js_code)
      } else {
        output$suggestions_content_control_protective <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(session$ns, suggestions[[i]], i, "control_protective")
            })
          )
        })

        # Use DOM polling mechanism
        suggestions_id <- session$ns("suggestions_list_control_protective")
        loading_id <- session$ns("suggestion_loading_control_protective")

        js_code <- sprintf("
          setTimeout(function() {
            console.log('[AI SUGGESTIONS] Starting DOM polling for protective control suggestions...');
            var attempts = 0;
            var maxAttempts = 50;

            var checkExist = setInterval(function() {
              attempts++;

              var suggestionsEl = $('#%s');
              var loadingEl = $('#%s');

              if (suggestionsEl.length > 0) {
                clearInterval(checkExist);
                console.log('[AI SUGGESTIONS] ✅ Protective control elements found after', attempts * 100, 'ms');

                loadingEl.hide();
                suggestionsEl.show();

                console.log('[AI SUGGESTIONS] Successfully showed protective control suggestions!');
              } else if (attempts >= maxAttempts) {
                clearInterval(checkExist);
                console.error('[AI SUGGESTIONS] ❌ Timeout - protective control elements not found');
              }
            }, 100);
          }, 200);
        ", suggestions_id, loading_id)

        shinyjs::runjs(js_code)
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
              }, error = function(e) {
                bowtie_log(paste("Failed to log protective control feedback:", e$message), level = "warning")
              })
            }

            notify_success(paste0("✅ Added suggested control: ", new_control$name), duration = 3)
          } else {
            notify_warning("ℹ️ This control is already in your selection", duration = 2)
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
        bowtie_log(paste("Failed to save feedback on session end:", e$message), level = "warning")
      })
    }
  })


  return(TRUE)
}

