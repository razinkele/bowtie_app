# =============================================================================
# Bowtie Visualization Module
# server_modules/bowtie_visualization_module.R
# =============================================================================
# Description: Handles bowtie diagram rendering, risk matrix, and statistics
# Version: 5.4.0
# Date: January 2026
# Part of: server.R modularization (Phase 4)
# =============================================================================

#' Initialize Bowtie Visualization Module
#'
#' Handles all bowtie diagram visualization including:
#' - Cached reactive expressions for nodes/edges
#' - Network visualization (visNetwork)
#' - Risk matrix plot (plotly)
#' - Risk statistics table
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param getCurrentData Reactive expression that returns current bowtie data
#' @param lang Reactive expression for current language
#' @return List with reactive expressions for external access
bowtie_visualization_module_server <- function(input, output, session, getCurrentData, lang) {

  # ===========================================================================
  # CACHED REACTIVE EXPRESSIONS FOR BOWTIE VISUALIZATION
  # ===========================================================================
  # These cached reactives prevent expensive recalculation of nodes/edges
  # when only visualization options change (not data)

  # Cached filtered problem data
  filtered_problem_data <- reactive({
    data <- getCurrentData()
    req(data, input$selectedProblem)
    # Normalize Central_Problem column name
    if (!("Central_Problem" %in% names(data)) && "Problem" %in% names(data)) {
      data$Central_Problem <- data$Problem
    }
    req("Central_Problem" %in% names(data))
    data[data$Central_Problem == input$selectedProblem, ]
  })

  # Cached bowtie nodes (expensive calculation)
  cached_bowtie_nodes <- reactive({
    problem_data <- filtered_problem_data()
    req(nrow(problem_data) > 0)

    # Generate cache key based on data content and visualization options
    font_size <- if (!is.null(input$fontSize)) input$fontSize else 12
    node_size <- if (!is.null(input$nodeSize)) input$nodeSize else "Medium"
    show_risk <- if (!is.null(input$showRiskLevels)) input$showRiskLevels else TRUE
    show_barriers <- if (!is.null(input$showBarriers)) input$showBarriers else TRUE
    cache_key <- paste0("bowtie_nodes_",
                       digest::digest(problem_data, algo = "xxhash32"),
                       "_", node_size,
                       "_", show_risk,
                       "_", show_barriers,
                       "_font", font_size)

    # Check cache first
    cached <- get_cache(cache_key)
    if (!is.null(cached)) {
      return(cached)
    }

    # Calculate nodes
    nodes <- create_bowtie_nodes_fixed(problem_data, input$selectedProblem, node_size,
                                   show_risk, show_barriers)

    # Store in cache
    set_cache(cache_key, nodes)

    nodes
  })

  # Cached bowtie edges (expensive calculation)
  cached_bowtie_edges <- reactive({
    problem_data <- filtered_problem_data()
    req(nrow(problem_data) > 0)

    # Generate cache key based on data content and barrier option
    show_barriers <- if (!is.null(input$showBarriers)) input$showBarriers else TRUE
    cache_key <- paste0("bowtie_edges_",
                       digest::digest(problem_data, algo = "xxhash32"),
                       "_", show_barriers)

    # Check cache first
    cached <- get_cache(cache_key)
    if (!is.null(cached)) {
      return(cached)
    }

    # Calculate edges
    edges <- create_bowtie_edges_fixed(problem_data, show_barriers)

    # Store in cache
    set_cache(cache_key, edges)

    edges
  })

  # ===========================================================================
  # FONT SIZE RESET HANDLER
  # ===========================================================================

  # Reset font size to default when button is clicked
  observeEvent(input$resetFontSize, {
    updateSliderInput(session, "fontSize", value = 12)
  })

  # ===========================================================================
  # BOWTIE NETWORK VISUALIZATION
  # ===========================================================================

  # Bowtie network visualization (uses cached nodes/edges for performance)
  output$bowtieNetwork <- renderVisNetwork({
    # Use cached filtered data and nodes/edges for better performance
    problem_data <- filtered_problem_data()
    if (is.null(problem_data) || nrow(problem_data) == 0) {
      showNotification("Warning: No data for selected central problem", type = "warning")
      return(NULL)
    }

    # Use cached nodes and edges (avoids expensive recalculation)
    nodes <- cached_bowtie_nodes()
    edges <- cached_bowtie_edges()

    req(nodes, edges)

    # Get font size from input (default to 12 if not set)
    font_size <- if (!is.null(input$fontSize)) input$fontSize else 12

    visNetwork(nodes, edges,
               main = input$selectedProblem,
               submain = if(input$showBarriers) "Complete risk pathway analysis" else "Direct causal relationships",
               width = "100%", height = "800px") %>%
      visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
               font = list(size = font_size, color = "#2C3E50", face = "Arial", multi = "html",
                          bold = paste0(font_size, "px Arial #000000"))) %>%
      visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
               smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
      visLayout(randomSeed = 123, improvedLayout = FALSE) %>%
      visPhysics(enabled = FALSE, stabilization = FALSE) %>%
      visOptions(highlightNearest = list(enabled = TRUE, degree = 1),
                nodesIdSelection = TRUE, collapse = FALSE,
                manipulation = if(input$editMode) list(enabled = TRUE, addNode = TRUE, addEdge = TRUE,
                                                      editNode = TRUE, editEdge = TRUE, deleteNode = TRUE,
                                                      deleteEdge = TRUE) else list(enabled = FALSE)) %>%
      visInteraction(navigationButtons = TRUE, dragNodes = TRUE, dragView = TRUE, zoomView = TRUE) %>%
      visLegend(useGroups = FALSE, addNodes = list(
        list(label = "Activities (Human Actions)",
             color = "#8E44AD", shape = "square", size = 15),
        list(label = "Pressures (Environmental Threats)",
             color = "#E74C3C", shape = "triangle", size = 15),
        list(label = "Preventive Controls",
             color = "#27AE60", shape = "square", size = 15),
        list(label = "Escalation Factors",
             color = "#F39C12", shape = "triangleDown", size = 15),
        list(label = "Central Problem (Main Risk)",
             color = "#C0392B", shape = "diamond", size = 18),
        list(label = "Protective Mitigation",
             color = "#3498DB", shape = "square", size = 15),
        list(label = "Consequences (Impacts)",
             color = "#E67E22", shape = "hexagon", size = 15)
      ), position = "right", width = 0.25, ncol = 1)
  })

  # ===========================================================================
  # RISK MATRIX VISUALIZATION
  # ===========================================================================

  # Enhanced risk matrix with comprehensive error handling
  output$riskMatrix <- renderPlotly({
    data <- getCurrentData()
    req(data, nrow(data) > 0)

    # Ensure Risk_Level column exists and is properly formatted
    if (!"Risk_Level" %in% names(data)) {
      # Calculate risk level based on likelihood and severity
      likelihood_col <- if ("Likelihood" %in% names(data)) data$Likelihood else data$Overall_Likelihood
      severity_col <- if ("Severity" %in% names(data)) data$Severity else data$Overall_Severity

      risk_scores <- likelihood_col * severity_col
      data$Risk_Level <- ifelse(risk_scores <= 6, "Low",
                               ifelse(risk_scores <= 15, "Medium", "High"))
    }

    # Ensure Risk_Level is character and has valid values
    if (is.numeric(data$Risk_Level)) {
      # Convert numeric risk level to categorical
      data$Risk_Level <- ifelse(data$Risk_Level <= 6, "Low",
                               ifelse(data$Risk_Level <= 15, "Medium", "High"))
    }

    # Validate Risk_Level values and set defaults for invalid ones
    valid_levels <- c("Low", "Medium", "High")
    data$Risk_Level[!data$Risk_Level %in% valid_levels] <- "Medium"

    # Ensure Likelihood and Severity columns exist
    if (!"Likelihood" %in% names(data)) {
      data$Likelihood <- data$Overall_Likelihood
    }
    if (!"Severity" %in% names(data)) {
      data$Severity <- data$Overall_Severity
    }

    # Create the risk matrix plot
    tryCatch({
      risk_plot <- ggplot(data, aes(x = Likelihood, y = Severity)) +
        geom_point(aes(color = Risk_Level, text = paste(
          "Central Problem:", Central_Problem,
          "<br>Activity:", Activity,
          "<br>Pressure:", Pressure,
          "<br>Protective Mitigation:", Protective_Mitigation,
          "<br>Consequence:", Consequence,
          "<br>Risk Level:", Risk_Level,
          "<br>Risk Score:", Likelihood * Severity,
          "<br>Bayesian Networks: Enabled"
        )), size = 4, alpha = 0.7) +
        scale_color_manual(values = RISK_COLORS, name = "Risk Level") +
        scale_x_continuous(breaks = 1:5, limits = c(0.5, 5.5),
                          name = "Likelihood (1=Very Low, 5=Very High)") +
        scale_y_continuous(breaks = 1:5, limits = c(0.5, 5.5),
                          name = "Severity (1=Negligible, 5=Catastrophic)") +
        labs(title = "Enhanced Environmental Risk Matrix with Bayesian Networks",
             subtitle = paste("Analyzing", nrow(data), "risk scenarios - Ready for probabilistic modeling")) +
        theme_minimal() +
        theme(legend.position = "bottom",
              plot.title = element_text(color = "#2C3E50", size = 14),
              plot.subtitle = element_text(color = "#007bff", size = 10))

      ggplotly(risk_plot, tooltip = "text")

    }, error = function(e) {
      if (exists("bowtie_log")) {
        bowtie_log("Error in risk matrix generation:", e$message, level = "error")
      }

      # Create a simple fallback plot
      fallback_plot <- ggplot() +
        geom_text(aes(x = 3, y = 3),
                  label = paste("Risk Matrix Error\nData issue detected:\n", e$message),
                  size = 4, color = "#dc3545") +
        xlim(1, 5) + ylim(1, 5) +
        labs(title = "Risk Matrix Generation Error",
             x = "Likelihood", y = "Severity") +
        theme_minimal()

      ggplotly(fallback_plot)
    })
  })

  # ===========================================================================
  # RISK STATISTICS TABLE
  # ===========================================================================

  # Enhanced risk statistics
  output$riskStats <- renderTable({
    data <- getCurrentData()
    req(data, nrow(data) > 0)

    risk_summary <- data %>%
      count(Risk_Level) %>%
      mutate(Percentage = round(n / sum(n) * 100, 1)) %>%
      mutate(Icon = case_when(
        Risk_Level == "High" ~ "High Risk",
        Risk_Level == "Medium" ~ "Medium Risk",
        TRUE ~ "Low Risk"
      )) %>%
      select(Icon, Risk_Level, Count = n, Percentage)

    names(risk_summary) <- c("Category", "Risk Level", "Count", "Percentage (%)")

    footer_row <- data.frame(
      Category = "Bayesian",
      `Risk Level` = "Total",
      Count = nrow(data),
      `Percentage (%)` = 100.0,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )

    names(footer_row) <- names(risk_summary)

    rbind(risk_summary, footer_row)
  }, sanitize.text.function = function(x) x)

  # ===========================================================================
  # RETURN REACTIVE EXPRESSIONS FOR EXTERNAL ACCESS
  # ===========================================================================

  return(list(
    filtered_problem_data = filtered_problem_data,
    cached_bowtie_nodes = cached_bowtie_nodes,
    cached_bowtie_edges = cached_bowtie_edges
  ))
}

log_debug("   bowtie_visualization_module.R loaded (diagram, risk matrix, statistics)")
