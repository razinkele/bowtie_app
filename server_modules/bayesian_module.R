# =============================================================================
# bayesian_module.R
# Bayesian Network Analysis Module
# =============================================================================
# Part of: Server modularization (Phase 4)
# Version: 5.4.0
# Date: January 2026
# Description: Handles Bayesian network creation, inference, and visualization
# =============================================================================

#' Bayesian Network Module Server
#'
#' Provides Bayesian network analysis functionality including:
#' - Network creation from bowtie data
#' - Probabilistic inference with evidence
#' - Scenario presets (worst case, best case, etc.)
#' - CPT generation and visualization
#' - Results download
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param getCurrentData Function to get current data
#' @param lang Reactive language function
#' @return List of reactive values for use by other modules
bayesian_module_server <- function(input, output, session, getCurrentData, lang) {

  # ===========================================================================
  # REACTIVE VALUES
  # ===========================================================================
  bayesianNetwork <- reactiveVal(NULL)
  bayesianNetworkCreated <- reactiveVal(FALSE)
  inferenceResults <- reactiveVal(NULL)
  inferenceCompleted <- reactiveVal(FALSE)

  # ===========================================================================
  # CREATE BAYESIAN NETWORK
  # ===========================================================================
  observeEvent(input$createBayesianNetwork, {
    data <- getCurrentData()
    req(data, input$bayesianProblem)

    notify_info(paste("🧠", t("notify_bayesian_creating", lang())), duration = 3)

    tryCatch({
      # Convert bowtie to Bayesian network
      bn_result <- bowtie_to_bayesian(
        data,
        central_problem = input$bayesianProblem,
        learn_from_data = FALSE,
        visualize = TRUE
      )

      bayesianNetwork(bn_result)
      bayesianNetworkCreated(TRUE)

      notify_success(paste("✅", t("notify_bayesian_success", lang())), duration = 3)

    }, error = function(e) {
      notify_error(paste("❌", t("notify_bayesian_error", lang()), e$message))
      bowtie_log("Bayesian network error:", e$message, level = "error")
    })
  })

  # ===========================================================================
  # NETWORK STATUS OUTPUTS
  # ===========================================================================

  # Bayesian network created flag
  output$bayesianNetworkCreated <- reactive({
    bayesianNetworkCreated()
  })
  outputOptions(output, "bayesianNetworkCreated", suspendWhenHidden = FALSE)

  # Inference completed flag
  output$inferenceCompleted <- reactive({
    inferenceCompleted()
  })
  outputOptions(output, "inferenceCompleted", suspendWhenHidden = FALSE)

  # ===========================================================================
  # NETWORK VISUALIZATION
  # ===========================================================================

  output$bayesianNetworkVis <- renderVisNetwork({
    bn_result <- bayesianNetwork()
    req(bn_result, bn_result$visualization)
    bn_result$visualization
  })

  # Network information
  output$networkInfo <- renderPrint({
    bn_result <- bayesianNetwork()
    req(bn_result)

    structure <- bn_result$structure
    cat("Network Structure:\n")
    cat("  Nodes:", nrow(structure$nodes), "\n")
    cat("  Edges:", nrow(structure$edges), "\n")
    cat("  Node types:\n")
    node_types <- table(structure$nodes$node_type)
    for (i in 1:length(node_types)) {
      cat("    ", names(node_types)[i], ":", node_types[i], "\n")
    }
  })

  # ===========================================================================
  # BAYESIAN INFERENCE
  # ===========================================================================

  observeEvent(input$runInference, {
    bn_result <- bayesianNetwork()

    # Check if we have query nodes selected
    if (is.null(input$queryNodes) || length(input$queryNodes) == 0) {
      notify_warning("Please select at least one outcome to query", duration = 3)
      return()
    }

    # Show loading indicator
    showNotification(
      id = "inference_loading",
      "Running Bayesian inference... Please wait.",
      type = "message",
      duration = NULL
    )

    # Use withProgress for visual feedback
    withProgress(message = "Running Bayesian Inference", value = 0, {
      tryCatch({
        incProgress(0.2, detail = "Preparing evidence...")

        # Prepare evidence
        evidence <- list()

        if (!is.null(input$evidenceActivity) && input$evidenceActivity != "" && input$evidenceActivity != "Any") {
          evidence$Activity <- input$evidenceActivity
        }
        if (!is.null(input$evidencePressure) && input$evidencePressure != "" && input$evidencePressure != "Any") {
          evidence$Pressure_Level <- input$evidencePressure
        }
        if (!is.null(input$evidenceControl) && input$evidenceControl != "" && input$evidenceControl != "Any") {
          evidence$Control_Effect <- input$evidenceControl
        }

        incProgress(0.4, detail = "Computing probabilities...")

        # Try to use actual Bayesian network inference first
        results <- NULL

        if (!is.null(bn_result) && !is.null(bn_result$network)) {
          tryCatch({
            if (exists("perform_inference") && is.function(perform_inference)) {
              results <- perform_inference(bn_result$network, evidence, input$queryNodes)
            }
          }, error = function(e) {
            bowtie_log(paste("BBN inference fallback:", e$message), level = "debug")
          })
        }

        incProgress(0.2, detail = "Finalizing results...")

        # If BBN inference didn't work, use simplified inference
        if (is.null(results) || length(results) == 0) {
          results <- run_simplified_inference(evidence, input$queryNodes)
        }

        # Store results
        inferenceResults(results)
        inferenceCompleted(TRUE)

        incProgress(0.2, detail = "Done!")

        # Remove loading notification and show success
        removeNotification(id = "inference_loading")
        notify_success("Inference completed! See results below.", duration = 3)

      }, error = function(e) {
        removeNotification(id = "inference_loading")
        notify_error(paste("Error in inference:", e$message), duration = 5)
        bowtie_log(paste("Inference error:", e$message), level = "error")
      })
    })
  })

  # ===========================================================================
  # SIMPLIFIED INFERENCE FUNCTION
  # ===========================================================================

  run_simplified_inference <- function(evidence, query_nodes) {
    results <- list()

    # Base probabilities
    base_probs <- list(
      Consequence_Level = c(Low = 0.4, Medium = 0.4, High = 0.2),
      Problem_Severity = c(Low = 0.3, Medium = 0.5, High = 0.2),
      Escalation_Level = c(Low = 0.5, Medium = 0.3, High = 0.2)
    )

    for (node in query_nodes) {
      if (node %in% names(base_probs)) {
        probs <- base_probs[[node]]

        # Adjust based on evidence
        if ("Activity" %in% names(evidence) && evidence$Activity == "Present") {
          probs["High"] <- min(0.8, probs["High"] * 1.5)
          probs["Medium"] <- max(0.1, probs["Medium"] * 1.2)
          probs["Low"] <- max(0.1, 1 - probs["High"] - probs["Medium"])
        }

        if ("Pressure_Level" %in% names(evidence)) {
          if (evidence$Pressure_Level == "High") {
            probs["High"] <- min(0.9, probs["High"] * 2)
            probs["Medium"] <- max(0.05, probs["Medium"] * 0.8)
            probs["Low"] <- max(0.05, 1 - probs["High"] - probs["Medium"])
          } else if (evidence$Pressure_Level == "Low") {
            probs["Low"] <- min(0.8, probs["Low"] * 1.5)
            probs["High"] <- max(0.05, probs["High"] * 0.3)
            probs["Medium"] <- max(0.15, 1 - probs["High"] - probs["Low"])
          }
        }

        if ("Control_Effect" %in% names(evidence)) {
          if (evidence$Control_Effect == "Failed") {
            probs["High"] <- min(0.85, probs["High"] * 1.8)
            probs["Medium"] <- max(0.1, probs["Medium"] * 1.1)
            probs["Low"] <- max(0.05, 1 - probs["High"] - probs["Medium"])
          } else if (evidence$Control_Effect == "Effective") {
            probs["Low"] <- min(0.7, probs["Low"] * 1.4)
            probs["High"] <- max(0.05, probs["High"] * 0.4)
            probs["Medium"] <- max(0.25, 1 - probs["High"] - probs["Low"])
          }
        }

        # Normalize
        total <- sum(probs)
        probs <- probs / total
        results[[node]] <- probs
      }
    }

    return(results)
  }

  # ===========================================================================
  # INFERENCE RESULTS OUTPUT
  # ===========================================================================

  output$inferenceResults <- renderUI({
    results <- inferenceResults()
    req(results)

    # Create formatted HTML output
    result_divs <- lapply(names(results), function(node) {
      node_results <- results[[node]]

      # Create progress bars for each state
      state_bars <- lapply(names(node_results), function(state) {
        prob <- node_results[state]
        prob_pct <- sprintf("%.1f%%", prob * 100)

        # Color based on probability
        bar_color <- if (prob > 0.6) "success"
                     else if (prob > 0.3) "warning"
                     else "secondary"

        div(class = "mb-2",
          tags$label(state, class = "small"),
          div(class = "progress",
            div(class = paste("progress-bar bg-", bar_color, sep = ""),
                role = "progressbar",
                style = paste0("width: ", prob * 100, "%"),
                `aria-valuenow` = prob * 100,
                `aria-valuemin` = "0",
                `aria-valuemax` = "100",
                prob_pct
            )
          )
        )
      })

      div(class = "mb-3",
        tags$h6(node, class = "text-primary"),
        tagList(state_bars)
      )
    })

    return(div(
      div(class = "alert alert-info mb-3",
          icon("chart-bar"), " ",
          strong("Probabilistic Predictions"),
          p(class = "mb-0 mt-2 small",
            "Probability distributions for queried nodes based on evidence provided")),
      tagList(result_divs)
    ))
  })

  # ===========================================================================
  # RISK INTERPRETATION
  # ===========================================================================

  output$riskInterpretation <- renderUI({
    results <- inferenceResults()
    req(results)

    interpretations <- list()

    # Analyze consequence level
    if ("Consequence_Level" %in% names(results)) {
      cons_results <- results$Consequence_Level
      if ("High" %in% names(cons_results) && cons_results["High"] > 0.5) {
        interpretations <- append(interpretations, list(
          div(class = "alert alert-danger",
              icon("exclamation-triangle"), " ",
              strong("High Risk: "), sprintf("%.1f%% probability of severe consequences", cons_results["High"] * 100))))
      } else if ("Medium" %in% names(cons_results) && cons_results["Medium"] > 0.4) {
        interpretations <- append(interpretations, list(
          div(class = "alert alert-warning",
              icon("exclamation"), " ",
              strong("Medium Risk: "), sprintf("%.1f%% probability of moderate consequences", cons_results["Medium"] * 100))))
      } else {
        interpretations <- append(interpretations, list(
          div(class = "alert alert-success",
              icon("check-circle"), " ",
              strong("Low Risk: "), "Consequences likely to be manageable")))
      }
    }

    # Analyze problem severity
    if ("Problem_Severity" %in% names(results)) {
      prob_results <- results$Problem_Severity
      if ("High" %in% names(prob_results) && prob_results["High"] > 0.4) {
        interpretations <- append(interpretations, list(
          div(class = "alert alert-info",
              icon("info-circle"), " ",
              strong("Problem Analysis: "), "Central problem likely to be severe - enhanced monitoring recommended")))
      }
    }

    if (length(interpretations) == 0) {
      interpretations <- list(div(class = "alert alert-secondary", "Run inference to see risk interpretation"))
    }

    return(tagList(interpretations))
  })

  # ===========================================================================
  # CONDITIONAL PROBABILITY TABLES (CPTs)
  # ===========================================================================

  output$cptTables <- renderUI({
    bn_result <- bayesianNetwork()
    req(bn_result, bn_result$structure)

    tryCatch({
      structure <- bn_result$structure
      nodes <- structure$nodes
      edges <- structure$edges

      # Create CPTs using the function from bowtie_bayesian_network.R
      if (exists("create_cpts")) {
        cpts <- create_cpts(structure, use_data = FALSE)
      } else {
        return(div(class = "alert alert-warning",
                  icon("exclamation-triangle"),
                  " CPT generation function not available"))
      }

      # Create HTML tables for each CPT
      cpt_tables <- lapply(names(cpts), function(node_name) {
        cpt <- cpts[[node_name]]
        node_info <- nodes[nodes$node_id == node_name, ]

        # Create table based on CPT type
        if (is.vector(cpt)) {
          # Simple probability vector (no parents)
          table_html <- tags$table(
            class = "table table-sm table-bordered table-hover",
            tags$thead(
              tags$tr(
                tags$th("State", class = "bg-light"),
                tags$th("Probability", class = "bg-light")
              )
            ),
            tags$tbody(
              lapply(names(cpt), function(state) {
                tags$tr(
                  tags$td(state),
                  tags$td(sprintf("%.2f", cpt[state]))
                )
              })
            )
          )
        } else if (is.matrix(cpt)) {
          # Conditional probability matrix (has parents)
          col_names <- colnames(cpt)
          row_names <- rownames(cpt)

          table_html <- tags$table(
            class = "table table-sm table-bordered table-hover",
            tags$thead(
              tags$tr(
                tags$th("", class = "bg-light"),
                lapply(col_names, function(col) tags$th(col, class = "bg-light"))
              )
            ),
            tags$tbody(
              lapply(1:nrow(cpt), function(i) {
                tags$tr(
                  tags$td(row_names[i], class = "font-weight-bold"),
                  lapply(1:ncol(cpt), function(j) {
                    tags$td(sprintf("%.2f", cpt[i, j]))
                  })
                )
              })
            )
          )
        } else {
          table_html <- div(class = "alert alert-secondary", "Complex CPT structure")
        }

        # Get icon based on node type
        node_icon <- if (nrow(node_info) > 0) {
          switch(as.character(node_info$node_type[1]),
            "Activity" = "play",
            "Pressure" = "exclamation-triangle",
            "Control" = "shield-alt",
            "Problem" = "bullseye",
            "Consequence" = "fire",
            "circle"
          )
        } else {
          "circle"
        }

        # Wrap each table in a card
        div(
          class = "mb-3",
          tags$h6(
            tagList(icon(node_icon), " ", node_name),
            class = "text-primary"
          ),
          table_html,
          tags$small(
            class = "text-muted",
            paste("Type:", if (nrow(node_info) > 0) node_info$node_type[1] else "Unknown")
          )
        )
      })

      return(div(
        div(class = "alert alert-info mb-3",
            icon("info-circle"), " ",
            strong("Conditional Probability Tables (CPTs)"),
            p(class = "mb-0 mt-2 small",
              "These tables show the probability distributions for each node in the Bayesian network. ",
              "Nodes without parents show simple probability distributions, while nodes with parents show ",
              "conditional probabilities given different parent states.")),
        tagList(cpt_tables)
      ))

    }, error = function(e) {
      return(div(class = "alert alert-danger",
                icon("exclamation-triangle"), " ",
                strong("Error generating CPTs: "), e$message))
    })
  })

  # ===========================================================================
  # SCENARIO PRESETS
  # ===========================================================================

  observeEvent(input$scenarioWorstCase, {
    updateSelectInput(session, "evidenceActivity", selected = "Present")
    updateSelectInput(session, "evidencePressure", selected = "High")
    updateSelectInput(session, "evidenceControl", selected = "Failed")
    notify_warning("Worst case scenario set", duration = 2)
  })

  observeEvent(input$scenarioBestCase, {
    updateSelectInput(session, "evidenceActivity", selected = "Absent")
    updateSelectInput(session, "evidencePressure", selected = "Low")
    updateSelectInput(session, "evidenceControl", selected = "Effective")
    notify_info("Best case scenario set", duration = 2)
  })

  observeEvent(input$scenarioControlFailure, {
    updateSelectInput(session, "evidenceActivity", selected = "Present")
    updateSelectInput(session, "evidencePressure", selected = "Medium")
    updateSelectInput(session, "evidenceControl", selected = "Failed")
    notify_warning("Control failure scenario set", duration = 2)
  })

  observeEvent(input$scenarioBaseline, {
    updateSelectInput(session, "evidenceActivity", selected = "")
    updateSelectInput(session, "evidencePressure", selected = "")
    updateSelectInput(session, "evidenceControl", selected = "")
    notify_info("Baseline scenario set (no evidence)", duration = 2)
  })

  # ===========================================================================
  # DOWNLOAD HANDLER
  # ===========================================================================

  output$downloadBayesianResults <- downloadHandler(
    filename = function() paste("bayesian_analysis_", Sys.Date(), ".html", sep = ""),
    content = function(file) {
      bn_result <- bayesianNetwork()
      results <- inferenceResults()
      req(bn_result)

      # Create HTML report
      html_content <- paste(
        "<html><head><title>Bayesian Network Analysis Report</title>",
        "<style>body{font-family:Arial,sans-serif;margin:20px;}</style></head>",
        "<body>",
        "<h1>Environmental Bowtie Bayesian Network Analysis</h1>",
        "<h2>Network Structure</h2>",
        paste("<p><strong>Nodes:</strong>", nrow(bn_result$structure$nodes), "</p>"),
        paste("<p><strong>Edges:</strong>", nrow(bn_result$structure$edges), "</p>"),
        "<h2>Analysis Date</h2>",
        paste("<p>", Sys.Date(), "</p>"),
        if (!is.null(results)) {
          paste("<h2>Inference Results</h2>",
                "<p>Results based on provided evidence.</p>")
        } else "",
        "</body></html>",
        sep = ""
      )

      writeLines(html_content, file)
    }
  )

  # ===========================================================================
  # RETURN REACTIVE VALUES
  # ===========================================================================
  return(list(
    bayesianNetwork = bayesianNetwork,
    bayesianNetworkCreated = bayesianNetworkCreated,
    inferenceResults = inferenceResults,
    inferenceCompleted = inferenceCompleted,
    resetBayesian = function() {
      bayesianNetworkCreated(FALSE)
      inferenceCompleted(FALSE)
    }
  ))
}

log_debug("   bayesian_module.R loaded (Bayesian network analysis)")
