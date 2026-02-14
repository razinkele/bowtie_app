# =============================================================================
# AI Analysis Module
# server_modules/ai_analysis_module.R
# =============================================================================
# Description: Handles AI-powered vocabulary analysis and linking
# Version: 5.4.0
# Date: January 2026
# Part of: server.R modularization (Phase 4)
# =============================================================================

#' Initialize AI Analysis Module
#'
#' Handles all AI-powered vocabulary analysis including:
#' - Vocabulary link discovery
#' - Semantic similarity analysis
#' - Causal pathway detection
#' - Network visualization
#' - Connection recommendations
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param vocabulary_data Vocabulary data list
#' @param lang Reactive expression for current language
#' @return List with reactive expressions for external access
ai_analysis_module_server <- function(input, output, session, vocabulary_data, lang) {

  # ===========================================================================
  # REACTIVE VALUES
  # ===========================================================================

  ai_analysis_results <- reactiveVal(NULL)

  # ===========================================================================
  # RUN AI ANALYSIS
  # ===========================================================================

  observeEvent(input$run_ai_analysis, {
    req(input$similarity_threshold, input$max_links_per_item)
    notify_info("Starting AI analysis...", duration = 2)

    tryCatch({
      if (exists("find_vocabulary_links")) {
        results <- find_vocabulary_links(
          vocabulary_data,
          similarity_threshold = input$similarity_threshold,
          max_links_per_item = input$max_links_per_item,
          methods = input$ai_methods
        )

        ai_analysis_results(results)

        # Handle both list and dataframe results
        link_count <- if (is.list(results) && !is.null(results$links)) {
          nrow(results$links)
        } else if (is.data.frame(results)) {
          nrow(results)
        } else {
          0
        }

        notify_success(paste("AI analysis complete! Found", link_count, "connections"), duration = 3)
      } else if (exists("find_basic_connections")) {
        # Fall back to basic connections
        basic_links <- find_basic_connections(
          vocabulary_data,
          max_links_per_item = input$max_links_per_item
        )

        results <- list(
          links = basic_links,
          summary = data.frame(),
          capabilities = list(basic_only = TRUE)
        )
        ai_analysis_results(results)

        notify_warning(paste("Using basic analysis (AI linker not available). Found", nrow(basic_links), "connections"), duration = 3)
      } else {
        notify_error("No linking functions available. Please ensure vocabulary_ai_linker.R is loaded.", duration = 5)
      }
    }, error = function(e) {
      notify_error(paste("Error in AI analysis:", e$message))
    })
  })

  # ===========================================================================
  # AI ANALYSIS COMPLETE FLAG
  # ===========================================================================

  output$aiAnalysisComplete <- reactive({
    !is.null(ai_analysis_results())
  })
  outputOptions(output, "aiAnalysisComplete", suspendWhenHidden = FALSE)

  # ===========================================================================
  # AI SUMMARY OUTPUT
  # ===========================================================================

  output$ai_summary <- renderPrint({
    results <- ai_analysis_results()
    if (!is.null(results)) {
      cat("Total connections found:", nrow(results$links), "\n")
      cat("Analysis methods used:", paste(unique(results$links$method), collapse = ", "), "\n")
      cat("Average similarity score:", round(mean(results$links$similarity), 3), "\n")

      if (length(results$keyword_connections) > 0) {
        cat("\nKeyword themes identified:", paste(names(results$keyword_connections), collapse = ", "))
      }

      if (!is.null(results$causal_summary) && nrow(results$causal_summary) > 0) {
        cat("\n\nCausal relationships found:\n")
        causal_count <- sum(results$causal_summary$count)
        cat("  Total causal links:", causal_count, "\n")
        cat("  Activity -> Pressure:",
            sum(results$causal_summary$count[results$causal_summary$from_type == "Activity" &
                                            results$causal_summary$to_type == "Pressure"]), "\n")
        cat("  Pressure -> Consequence:",
            sum(results$causal_summary$count[results$causal_summary$from_type == "Pressure" &
                                            results$causal_summary$to_type == "Consequence"]), "\n")
        cat("  Control interventions:",
            sum(results$causal_summary$count[results$causal_summary$from_type == "Control"]), "\n")
      }
    }
  })

  # ===========================================================================
  # AI CONNECTIONS TABLE
  # ===========================================================================

  output$ai_connections_table <- DT::renderDataTable({
    results <- ai_analysis_results()
    if (!is.null(results) && nrow(results$links) > 0) {
      display_data <- results$links %>%
        select(
          `From Type` = from_type,
          `From` = from_name,
          `To Type` = to_type,
          `To` = to_name,
          `Similarity` = similarity,
          `Method` = method
        ) %>%
        mutate(
          Similarity = round(Similarity, 3),
          Method = gsub("_", " ", Method)
        )

      DT::datatable(
        display_data,
        options = list(
          pageLength = 10,
          order = list(list(4, 'desc'))
        ),
        rownames = FALSE
      ) %>%
        formatStyle("Similarity",
                   background = styleColorBar(display_data$Similarity, "lightblue"),
                   backgroundSize = '100% 90%',
                   backgroundRepeat = 'no-repeat',
                   backgroundPosition = 'center')
    }
  })

  # ===========================================================================
  # AI NETWORK VISUALIZATION
  # ===========================================================================

  output$ai_network <- renderVisNetwork({
    results <- ai_analysis_results()
    if (!is.null(results) && nrow(results$links) > 0) {
      tryCatch({
        all_nodes <- unique(c(
          paste(results$links$from_type, results$links$from_id, results$links$from_name, sep = "|"),
          paste(results$links$to_type, results$links$to_id, results$links$to_name, sep = "|")
        ))

        nodes_df <- data.frame(
          id = sapply(strsplit(all_nodes, "\\|"), function(x) paste(x[1], x[2], sep = "_")),
          group = sapply(strsplit(all_nodes, "\\|"), `[`, 1),
          label = sapply(strsplit(all_nodes, "\\|"), function(x) {
            name <- paste(x[3:length(x)], collapse = "|")
            if (nchar(name) > 30) paste0(substr(name, 1, 27), "...") else name
          }),
          title = sapply(strsplit(all_nodes, "\\|"), function(x) paste(x[3:length(x)], collapse = "|")),
          stringsAsFactors = FALSE
        )

        if (length(unique(nodes_df$id)) != nrow(nodes_df)) {
          nodes_df$id <- paste(nodes_df$id, seq_len(nrow(nodes_df)), sep = "_")
        }

        type_colors <- list(
          activities = "#8E44AD",
          pressures = "#E74C3C",
          consequences = "#E67E22",
          controls = "#27AE60"
        )

        nodes_df$color <- sapply(nodes_df$group, function(g) type_colors[[g]])

        edges_df <- results$links %>%
          mutate(
            from = paste(from_type, from_id, sep = "_"),
            to = paste(to_type, to_id, sep = "_"),
            width = similarity * 5,
            title = paste("Similarity:", round(similarity, 3))
          ) %>%
          select(from, to, width, title)

        if (length(unique(sapply(strsplit(all_nodes, "\\|"), function(x) paste(x[1], x[2], sep = "_")))) != nrow(nodes_df)) {
          id_mapping <- setNames(nodes_df$id, sapply(strsplit(all_nodes, "\\|"), function(x) paste(x[1], x[2], sep = "_")))
          edges_df$from <- id_mapping[edges_df$from]
          edges_df$to <- id_mapping[edges_df$to]
        }

        visNetwork(nodes_df, edges_df) %>%
          visNodes(
            shape = "dot",
            size = 20,
            font = list(size = 12)
          ) %>%
          visEdges(
            smooth = TRUE,
            color = list(opacity = 0.5)
          ) %>%
          visGroups(groupname = "activities", color = "#8E44AD") %>%
          visGroups(groupname = "pressures", color = "#E74C3C") %>%
          visGroups(groupname = "consequences", color = "#E67E22") %>%
          visGroups(groupname = "controls", color = "#27AE60") %>%
          visLegend(width = 0.2, position = "right") %>%
          visPhysics(
            stabilization = TRUE,
            barnesHut = list(
              gravitationalConstant = -2000,
              springConstant = 0.04
            )
          ) %>%
          visOptions(
            highlightNearest = TRUE,
            nodesIdSelection = FALSE
          ) %>%
          visInteraction(
            navigationButtons = TRUE,
            dragNodes = TRUE,
            dragView = TRUE,
            zoomView = TRUE
          )
      }, error = function(e) {
        notify_error(paste("Error creating network visualization:", e$message))
        return(NULL)
      })
    } else {
      return(NULL)
    }
  })

  # ===========================================================================
  # CONNECTION SUMMARY TABLE
  # ===========================================================================

  output$ai_connection_summary <- renderTable({
    results <- ai_analysis_results()
    if (!is.null(results) && !is.null(results$summary) && nrow(results$summary) > 0) {
      results$summary %>%
        mutate(
          avg_similarity = round(avg_similarity, 3),
          max_similarity = round(max_similarity, 3),
          min_similarity = round(min_similarity, 3)
        ) %>%
        rename(
          `From Type` = from_type,
          `To Type` = to_type,
          `Method` = method,
          `Count` = count,
          `Avg Similarity` = avg_similarity,
          `Max Similarity` = max_similarity,
          `Min Similarity` = min_similarity
        )
    }
  })

  # ===========================================================================
  # CONNECTION PLOT
  # ===========================================================================

  output$ai_connection_plot <- renderPlot({
    results <- ai_analysis_results()
    if (!is.null(results) && nrow(results$links) > 0) {
      connection_summary <- results$links %>%
        mutate(connection_type = paste(from_type, "->", to_type)) %>%
        group_by(connection_type) %>%
        summarise(count = n(), .groups = 'drop') %>%
        arrange(desc(count))

      ggplot(connection_summary, aes(x = reorder(connection_type, count), y = count)) +
        geom_bar(stat = "identity", fill = "#3498DB") +
        coord_flip() +
        labs(
          title = "AI-Discovered Connection Types",
          x = "Connection Type",
          y = "Number of Connections"
        ) +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 14, face = "bold"),
          axis.text = element_text(size = 10)
        )
    }
  })

  # ===========================================================================
  # AI RECOMMENDATIONS
  # ===========================================================================

  output$ai_recommendations <- DT::renderDataTable({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("generate_link_recommendations")) {
      recommendations <- generate_link_recommendations(vocabulary_data, focus = "causal")

      if (nrow(recommendations) > 0) {
        display_recs <- recommendations %>%
          select(
            `From` = from_name,
            `To` = to_name,
            `Type` = method,
            `Score` = recommendation_score,
            `Reasoning` = reasoning
          ) %>%
          mutate(
            Score = round(Score, 3),
            Type = gsub("causal_", "", Type)
          )

        DT::datatable(
          display_recs,
          options = list(
            pageLength = 10,
            dom = 't'
          ),
          rownames = FALSE
        )
      }
    }
  })

  # ===========================================================================
  # CAUSAL PATHWAYS OUTPUT
  # ===========================================================================

  output$causal_paths <- renderPrint({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("find_causal_paths")) {
      causal_links <- results$links %>% filter(grepl("causal", method))

      if (nrow(causal_links) > 0) {
        paths <- find_causal_paths(causal_links, max_length = 5)

        if (length(paths) > 0) {
          cat("Top 10 Causal Pathways:\n\n")
          for (i in 1:min(10, length(paths))) {
            path <- paths[[i]]
            cat(sprintf("%d. %s\n", i, path$path_string))
            cat(sprintf("   Strength: %.3f (avg: %.3f)\n\n",
                       path$total_similarity, path$avg_similarity))
          }
        } else {
          cat("No complete causal pathways found.")
        }
      }
    }
  })

  # ===========================================================================
  # CAUSAL STRUCTURE ANALYSIS
  # ===========================================================================

  output$causal_structure <- renderTable({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("analyze_causal_structure")) {
      causal_analysis <- analyze_causal_structure(results$links)

      if (!is.null(causal_analysis$link_types)) {
        causal_analysis$link_types %>%
          mutate(avg_strength = round(avg_strength, 3)) %>%
          rename(
            `From` = from_type,
            `To` = to_type,
            `Count` = count,
            `Avg Strength` = avg_strength
          )
      }
    }
  })

  # ===========================================================================
  # KEY DRIVERS TABLE
  # ===========================================================================

  output$key_drivers <- renderTable({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("analyze_causal_structure")) {
      causal_analysis <- analyze_causal_structure(results$links)

      if (!is.null(causal_analysis$key_drivers)) {
        causal_analysis$key_drivers %>%
          select(-from_id) %>%
          mutate(
            avg_impact = round(avg_impact, 3),
            impact_score = round(outgoing_links * avg_impact, 2)
          ) %>%
          rename(
            `Driver` = from_name,
            `Type` = from_type,
            `Links` = outgoing_links,
            `Avg Impact` = avg_impact,
            `Score` = impact_score
          ) %>%
          head(5)
      }
    }
  })

  # ===========================================================================
  # KEY OUTCOMES TABLE
  # ===========================================================================

  output$key_outcomes <- renderTable({
    results <- ai_analysis_results()
    if (!is.null(results) && exists("analyze_causal_structure")) {
      causal_analysis <- analyze_causal_structure(results$links)

      if (!is.null(causal_analysis$key_outcomes)) {
        causal_analysis$key_outcomes %>%
          select(-to_id) %>%
          mutate(
            avg_impact = round(avg_impact, 3),
            impact_score = round(incoming_links * avg_impact, 2)
          ) %>%
          rename(
            `Outcome` = to_name,
            `Type` = to_type,
            `Links` = incoming_links,
            `Avg Impact` = avg_impact,
            `Score` = impact_score
          ) %>%
          head(5)
      }
    }
  })

  # ===========================================================================
  # RETURN REACTIVE EXPRESSIONS FOR EXTERNAL ACCESS
  # ===========================================================================

  return(list(
    ai_analysis_results = ai_analysis_results
  ))
}

log_debug("   ai_analysis_module.R loaded (AI-powered vocabulary analysis)")
