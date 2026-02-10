# =============================================================================
# Export and Download Handlers Module
# =============================================================================
# Purpose: Handles all export and download functionality for bowtie diagrams and data
# Dependencies: visNetwork, openxlsx, utils.R
# =============================================================================

#' Initialize export module server logic
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param getCurrentData Reactive function that returns current data
#' @return NULL (module defines outputs directly)
#' @export
export_module_server <- function(input, output, session, getCurrentData) {

  # Enhanced download bowtie diagram (HTML with interactive features)
  output$downloadBowtie <- downloadHandler(
    filename = function() paste("enhanced_bowtie_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".html"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)

      if (!("Central_Problem" %in% names(data)) && "Problem" %in% names(data)) data$Central_Problem <- data$Problem
      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, 50, FALSE, TRUE)
      edges <- createBowtieEdgesFixed(problem_data, TRUE)

      network <- visNetwork(nodes, edges,
                          main = paste("🌟 Enhanced Environmental Bowtie Analysis with Bayesian Networks:", input$selectedProblem),
                          submain = paste("Generated on", Sys.Date(), "- with Bayesian network support"),
                          footer = "🔧 ENHANCED: Activities → Pressures → Controls → Escalation → Central Problem → Mitigation → Consequences + Bayesian Networks") %>%
        visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
                font = list(color = "#2C3E50", face = "Arial")) %>%
        visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
                smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
        visLayout(randomSeed = 123, improvedLayout = FALSE) %>%
        visPhysics(enabled = FALSE, stabilization = FALSE) %>%
        visLegend(useGroups = FALSE, addNodes = list(
          list(label = "Activities (Human Actions)",
               color = "#8E44AD", shape = "box", size = 15),
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

      visSave(network, file, selfcontained = TRUE)
    },
    contentType = "text/html"
  )

  # Download bowtie as JPEG with white background
  output$downloadBowtieJPEG <- downloadHandler(
    filename = function() paste("bowtie_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".jpeg"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)

      if (!("Central_Problem" %in% names(data)) && "Problem" %in% names(data)) data$Central_Problem <- data$Problem
      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, input$nodeSize,
                                     input$showRiskLevels, input$showBarriers)
      edges <- createBowtieEdgesFixed(problem_data, input$showBarriers)

      # Create network
      network <- visNetwork(nodes, edges,
                          main = paste("Environmental Bowtie Analysis:", input$selectedProblem),
                          height = "800px", width = "100%") %>%
        visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
                font = list(color = "#2C3E50", face = "Arial", size = 14)) %>%
        visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
                smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
        visLayout(randomSeed = 123, improvedLayout = FALSE) %>%
        visPhysics(enabled = FALSE, stabilization = FALSE) %>%
        visInteraction(navigationButtons = FALSE, dragNodes = FALSE,
                      dragView = FALSE, zoomView = FALSE) %>%
        visExport(type = "jpeg", name = paste0("bowtie_", input$selectedProblem),
                 float = "left", label = "Export JPEG",
                 background = "#FFFFFF",  # White background for readability
                 style = "position: absolute; top: 0; left: 0;")

      # Save to temp HTML first
      temp_html <- tempfile(fileext = ".html")
      visSave(network, temp_html, selfcontained = TRUE)

      # Note: visSave with visExport will create export button in the HTML
      # For server-side export, we'll use the HTML with export functionality
      file.copy(temp_html, file)

      showNotification("JPEG export: Click the 'Export JPEG' button in the opened diagram",
                      type = "message", duration = 10)
    },
    contentType = "text/html"
  )

  # Download bowtie as PNG with white background (for readability)
  output$downloadBowtiePNG <- downloadHandler(
    filename = function() paste("bowtie_", gsub(" ", "_", input$selectedProblem), "_", Sys.Date(), ".png"),
    content = function(file) {
      data <- getCurrentData()
      req(data, input$selectedProblem)

      if (!("Central_Problem" %in% names(data)) && "Problem" %in% names(data)) data$Central_Problem <- data$Problem
      problem_data <- data[data$Central_Problem == input$selectedProblem, ]
      nodes <- createBowtieNodesFixed(problem_data, input$selectedProblem, input$nodeSize,
                                     input$showRiskLevels, input$showBarriers)
      edges <- createBowtieEdgesFixed(problem_data, input$showBarriers)

      # Create network with export button - WHITE background for readability
      network <- visNetwork(nodes, edges,
                          main = paste("Environmental Bowtie Analysis:", input$selectedProblem),
                          height = "800px", width = "100%",
                          background = "#FFFFFF") %>%
        visNodes(borderWidth = 2, shadow = list(enabled = TRUE, size = 5),
                font = list(color = "#2C3E50", face = "Arial", size = 14)) %>%
        visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 1)),
                smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2)) %>%
        visLayout(randomSeed = 123, improvedLayout = FALSE) %>%
        visPhysics(enabled = FALSE, stabilization = FALSE) %>%
        visInteraction(navigationButtons = FALSE, dragNodes = FALSE,
                      dragView = FALSE, zoomView = FALSE) %>%
        visExport(type = "png", name = paste0("bowtie_", input$selectedProblem),
                 float = "left", label = "Save as PNG",
                 background = "#FFFFFF",  # White background for readability
                 style = "position: absolute; top: 10px; left: 10px;")

      # Save to temp HTML
      temp_html <- tempfile(fileext = ".html")
      visSave(network, temp_html, selfcontained = TRUE)

      file.copy(temp_html, file)

      showNotification("PNG export: Click 'Save as PNG' button in the opened file",
                      type = "message", duration = 8)
    },
    contentType = "text/html"
  )

  # Download data as CSV
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("bowtie_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data <- getCurrentData()
      if (!is.null(data) && nrow(data) > 0) {
        write.csv(data, file, row.names = FALSE)
      } else {
        # Write empty CSV with message
        write.csv(data.frame(Message = "No data available"), file, row.names = FALSE)
      }
    }
  )

  # Download data as Excel
  output$downloadExcel <- downloadHandler(
    filename = function() {
      paste0("bowtie_data_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      data <- getCurrentData()
      if (!is.null(data) && nrow(data) > 0) {
        write.xlsx(data, file, rowNames = FALSE)
      } else {
        # Write empty Excel with message
        write.xlsx(data.frame(Message = "No data available"), file, rowNames = FALSE)
      }
    }
  )

  # Return NULL - this module defines outputs only
  invisible(NULL)
}
