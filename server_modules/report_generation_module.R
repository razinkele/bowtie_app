# =============================================================================
# Report Generation Module
# server_modules/report_generation_module.R
# =============================================================================
# Description: Handles report generation, download, and preview functionality
# Version: 5.5.0
# Date: February 2026
# Part of: server.R modularization (Phase 4)
#
# UI buttons (defined in ui_content_sections.R):
#   downloadPDF, downloadWord, downloadHTML
# UI inputs:
#   report_title, report_author, report_date, report_sections
# UI checkbox values:
#   "summary", "bowtie", "matrix", "bayesian", "vocabulary", "tables"
# =============================================================================

#' Initialize Report Generation Module
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param currentData Reactive value returning current bowtie data
#' @param lang Reactive expression for current language
#' @return List with reactive values for external access
report_generation_module_server <- function(input, output, session, currentData, lang) {

  # ===========================================================================
  # REACTIVE VALUES
  # ===========================================================================

  report_generated <- reactiveVal(FALSE)
  report_content <- reactiveVal(NULL)

  # ===========================================================================
  # HELPER: BUILD REPORT CONTENT
  # ===========================================================================

  build_report_content <- function(data, format_type) {
    sections <- list()
    selected <- input$report_sections

    if ("summary" %in% selected) {
      sections <- c(sections, list(list(
        title = "Executive Summary",
        description = paste("Overview of", nrow(data), "risk scenarios")
      )))
    }

    if ("bowtie" %in% selected) {
      sections <- c(sections, list(list(
        title = "Bowtie Diagrams",
        description = "Visual representation of risk pathways"
      )))
    }

    if ("matrix" %in% selected) {
      sections <- c(sections, list(list(
        title = "Risk Matrix",
        description = "Risk categorization by likelihood and severity"
      )))
    }

    if ("bayesian" %in% selected) {
      sections <- c(sections, list(list(
        title = "Bayesian Network Analysis",
        description = "Probabilistic risk inference results"
      )))
    }

    if ("vocabulary" %in% selected) {
      sections <- c(sections, list(list(
        title = "Vocabulary Details",
        description = "Environmental vocabulary data used in analysis"
      )))
    }

    if ("tables" %in% selected) {
      sections <- c(sections, list(list(
        title = "Data Tables",
        description = "Complete data tables for all risk scenarios"
      )))
    }

    # If no sections selected, include a summary by default
    if (length(sections) == 0) {
      sections <- list(list(
        title = "Executive Summary",
        description = paste("Overview of", nrow(data), "risk scenarios")
      ))
    }

    list(
      format = format_type,
      title = input$report_title %||% "Environmental Risk Analysis Report",
      author = input$report_author %||% "",
      date = as.character(input$report_date %||% Sys.Date()),
      sections = sections,
      data = data,
      generated_at = Sys.time()
    )
  }

  # ===========================================================================
  # REPORT PREVIEW (matches UI: uiOutput("reportPreview"))
  # ===========================================================================

  output$reportPreview <- renderUI({
    data <- currentData()

    if (is.null(data) || nrow(data) == 0) {
      div(class = "alert alert-warning",
          tagList(icon("exclamation-triangle"),
                  " No data available. Load or generate data first to preview the report."))
    } else {
      selected <- input$report_sections
      tagList(
        h5("Report will include:"),
        tags$ul(
          if ("summary" %in% selected) tags$li(icon("chart-pie"), " Executive Summary"),
          if ("bowtie" %in% selected) tags$li(icon("project-diagram"), " Bowtie Diagrams"),
          if ("matrix" %in% selected) tags$li(icon("th"), " Risk Matrix"),
          if ("bayesian" %in% selected) tags$li(icon("brain"), " Bayesian Analysis"),
          if ("vocabulary" %in% selected) tags$li(icon("book"), " Vocabulary Details"),
          if ("tables" %in% selected) tags$li(icon("table"), " Data Tables")
        ),
        hr(),
        tags$small(class = "text-muted",
                   paste("Data: ", nrow(data), "scenarios,",
                         length(unique(data$Central_Problem)), "problems,",
                         length(unique(data$Activity)), "activities"))
      )
    }
  })

  # ===========================================================================
  # DOWNLOAD PDF HANDLER
  # ===========================================================================

  output$downloadPDF <- downloadHandler(
    filename = function() {
      title <- input$report_title %||% "Environmental_Risk_Analysis_Report"
      paste0(gsub(" ", "_", title), "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".html")
    },
    content = function(file) {
      data <- currentData()

      if (is.null(data) || nrow(data) == 0) {
        writeLines("<html><body><h1>No data available</h1><p>Please load or generate data before generating a report.</p></body></html>", file)
        return()
      }

      tryCatch({
        content <- build_report_content(data, "pdf")
        html_content <- generate_html_report(content, data)
        # Add print-friendly CSS for PDF printing from browser
        html_content <- sub("</style>",
          paste0("@media print { body { background: white !important; } ",
                 ".container { box-shadow: none !important; } ",
                 "@page { margin: 1cm; } }\n</style>"),
          html_content)
        writeLines(html_content, file)

        report_content(content)
        report_generated(TRUE)
      }, error = function(e) {
        writeLines(paste("<html><body><h1>Report Generation Error</h1><p>", e$message, "</p></body></html>"), file)
      })
    },
    contentType = "text/html"
  )

  # ===========================================================================
  # DOWNLOAD WORD HANDLER
  # ===========================================================================

  output$downloadWord <- downloadHandler(
    filename = function() {
      title <- input$report_title %||% "Environmental_Risk_Analysis_Report"
      paste0(gsub(" ", "_", title), "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
    },
    content = function(file) {
      data <- currentData()

      if (is.null(data) || nrow(data) == 0) {
        writeLines("No data available. Please load or generate data before generating a report.", file)
        return()
      }

      tryCatch({
        content <- build_report_content(data, "text")
        text_content <- generate_text_report(content, data)
        writeLines(text_content, file)

        report_content(content)
        report_generated(TRUE)
      }, error = function(e) {
        writeLines(paste("Report Generation Error:", e$message), file)
      })
    },
    contentType = "text/plain"
  )

  # ===========================================================================
  # DOWNLOAD HTML HANDLER
  # ===========================================================================

  output$downloadHTML <- downloadHandler(
    filename = function() {
      title <- input$report_title %||% "Environmental_Risk_Analysis_Report"
      paste0(gsub(" ", "_", title), "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".html")
    },
    content = function(file) {
      data <- currentData()

      if (is.null(data) || nrow(data) == 0) {
        writeLines("<html><body><h1>No data available</h1><p>Please load or generate data before generating a report.</p></body></html>", file)
        return()
      }

      tryCatch({
        content <- build_report_content(data, "html")
        html_content <- generate_html_report(content, data)
        writeLines(html_content, file)

        report_content(content)
        report_generated(TRUE)
      }, error = function(e) {
        writeLines(paste("<html><body><h1>Report Generation Error</h1><p>", e$message, "</p></body></html>"), file)
      })
    },
    contentType = "text/html"
  )

  # ===========================================================================
  # RETURN REACTIVE VALUES
  # ===========================================================================

  return(list(
    report_generated = report_generated,
    report_content = report_content
  ))
}

# =============================================================================
# HELPER FUNCTIONS FOR REPORT GENERATION
# =============================================================================

#' Generate HTML Report Content
#' @param content Report content list
#' @param data Bowtie data frame
#' @return HTML string
generate_html_report <- function(content, data) {
  html_content <- paste0(
    "<!DOCTYPE html>\n<html>\n<head>\n",
    "<meta charset='UTF-8'>\n",
    "<title>", content$title, "</title>\n",
    "<style>\n",
    get_report_css_styles(),
    "</style>\n</head>\n<body>\n<div class='container'>\n"
  )

  # Header
  html_content <- paste0(html_content,
    "<h1>", content$title, "</h1>\n",
    "<div class='meta'>\n",
    if (nchar(content$author) > 0) paste0("<strong>Author:</strong> ", content$author, "<br>\n") else "",
    "<strong>Generated:</strong> ", format(content$generated_at, "%Y-%m-%d %H:%M:%S"), "<br>\n",
    "<strong>Version:</strong> ", APP_CONFIG$VERSION, " - Environmental Bowtie Risk Analysis Tool\n",
    "</div>\n"
  )

  # Table of Contents
  html_content <- paste0(html_content,
    "<div class='toc'>\n",
    "<h3>Table of Contents</h3>\n",
    "<ul>\n"
  )

  toc_counter <- 1
  for (section in content$sections) {
    html_content <- paste0(html_content,
      "<li><a href='#section", toc_counter, "'>", toc_counter, ". ", section$title, "</a></li>\n"
    )
    toc_counter <- toc_counter + 1
  }

  html_content <- paste0(html_content, "</ul>\n</div>\n")

  # Key Statistics Dashboard
  html_content <- paste0(html_content, generate_statistics_dashboard(data))

  # Sections
  section_counter <- 1
  for (section in content$sections) {
    html_content <- paste0(html_content,
      "<div class='section' id='section", section_counter, "'>\n",
      "<h2>", section_counter, ". ", section$title, "</h2>\n"
    )

    html_content <- paste0(html_content, generate_section_content(section, data))
    html_content <- paste0(html_content, "</div>\n")
    section_counter <- section_counter + 1
  }

  # Footer
  html_content <- paste0(html_content,
    "<div class='footer'>\n",
    "<p><strong>Environmental Bowtie Risk Analysis Tool</strong> | Version ", APP_CONFIG$VERSION, "</p>\n",
    "<p>Advanced Risk Assessment with Bayesian Networks</p>\n",
    "<p style='font-size: 0.9em; color: #6c757d;'>",
    "Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | Marbefes Environmental Risk Assessment Team</p>\n",
    "</div>\n",
    "</div>\n</body>\n</html>"
  )

  return(html_content)
}

#' Generate Text Report Content
#' @param content Report content list
#' @param data Bowtie data frame
#' @return Text string
generate_text_report <- function(content, data) {
  text_content <- paste0(
    strrep("=", 80), "\n",
    content$title, "\n",
    strrep("=", 80), "\n\n",
    if (nchar(content$author) > 0) paste0("Author: ", content$author, "\n") else "",
    "Generated: ", format(content$generated_at, "%Y-%m-%d %H:%M:%S"), "\n",
    "Version: ", APP_CONFIG$VERSION, " - Environmental Bowtie Risk Analysis Tool\n",
    strrep("=", 80), "\n\n"
  )

  # Key Statistics
  text_content <- paste0(text_content,
    "KEY STATISTICS\n",
    strrep("-", 80), "\n",
    "Total Scenarios: ", nrow(data), "\n",
    "Unique Problems: ", if ("Central_Problem" %in% names(data)) length(unique(data$Central_Problem)) else 0, "\n",
    "Unique Activities: ", if ("Activity" %in% names(data)) length(unique(data$Activity)) else 0, "\n",
    "Unique Consequences: ", if ("Consequence" %in% names(data)) length(unique(data$Consequence)) else 0, "\n",
    "Preventive Controls: ", if ("Preventive_Control" %in% names(data)) sum(!is.na(data$Preventive_Control)) else 0, "\n",
    "Protective Mitigations: ", if ("Protective_Mitigation" %in% names(data)) sum(!is.na(data$Protective_Mitigation)) else if ("Protective_Control" %in% names(data)) sum(!is.na(data$Protective_Control)) else 0, "\n",
    "Average Likelihood: ", if ("Likelihood" %in% names(data)) round(mean(data$Likelihood, na.rm = TRUE), 2) else "N/A", "\n",
    "Average Severity: ", if ("Severity" %in% names(data)) round(mean(data$Severity, na.rm = TRUE), 2) else "N/A", "\n",
    "High-Risk Scenarios: ", if (all(c("Likelihood", "Severity") %in% names(data))) sum(data$Likelihood >= 4 & data$Severity >= 4, na.rm = TRUE) else 0, "\n\n"
  )

  for (section in content$sections) {
    text_content <- paste0(text_content,
      "\n", strrep("=", 80), "\n",
      section$title, "\n",
      strrep("=", 80), "\n\n",
      section$description, "\n\n"
    )

    if (section$title == "Data Tables") {
      text_content <- paste0(text_content,
        "TOP ENVIRONMENTAL PROBLEMS:\n",
        strrep("-", 80), "\n"
      )
      problem_counts <- sort(table(data$Central_Problem), decreasing = TRUE)
      for (i in 1:min(10, length(problem_counts))) {
        text_content <- paste0(text_content,
          sprintf("%2d. %-50s %5d occurrences (%5.1f%%)\n",
                  i, names(problem_counts)[i], problem_counts[i],
                  problem_counts[i]/nrow(data)*100)
        )
      }
      text_content <- paste0(text_content, "\n")
    }

    if (section$title == "Risk Matrix") {
      text_content <- paste0(text_content,
        "RISK DISTRIBUTION:\n",
        strrep("-", 40), "\n"
      )
      if ("Risk_Level" %in% names(data)) {
        risk_counts <- table(data$Risk_Level)
        for (level in names(risk_counts)) {
          text_content <- paste0(text_content,
            sprintf("  %-15s %5d scenarios\n", level, risk_counts[level]))
        }
      }
      text_content <- paste0(text_content, "\n")
    }
  }

  text_content <- paste0(text_content,
    "\n", strrep("=", 80), "\n",
    "Environmental Bowtie Risk Analysis Tool v", APP_CONFIG$VERSION, "\n",
    "Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
    strrep("=", 80), "\n"
  )

  return(text_content)
}

#' Get CSS Styles for HTML Report
#' @return CSS string
get_report_css_styles <- function() {
  paste0(
    "body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }\n",
    ".container { max-width: 1400px; margin: auto; background: white; padding: 50px; box-shadow: 0 10px 40px rgba(0,0,0,0.3); border-radius: 10px; }\n",
    "h1 { color: #2c3e50; border-bottom: 4px solid #3498db; padding-bottom: 15px; font-size: 2.5em; margin-bottom: 10px; }\n",
    "h2 { color: #34495e; margin-top: 40px; padding: 15px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 5px; font-size: 1.8em; }\n",
    "h3 { color: #2980b9; margin-top: 25px; font-size: 1.4em; border-left: 4px solid #3498db; padding-left: 15px; }\n",
    "h4 { color: #16a085; margin-top: 20px; font-size: 1.2em; }\n",
    ".meta { color: #7f8c8d; font-style: italic; margin-bottom: 30px; padding: 15px; background: #ecf0f1; border-radius: 5px; border-left: 4px solid #3498db; }\n",
    "table { width: 100%; border-collapse: collapse; margin: 20px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }\n",
    "th, td { border: 1px solid #ddd; padding: 14px; text-align: left; }\n",
    "th { background: linear-gradient(135deg, #3498db 0%, #2980b9 100%); color: white; font-weight: bold; text-transform: uppercase; font-size: 0.9em; }\n",
    "tr:nth-child(even) { background-color: #f8f9fa; }\n",
    "tr:hover { background-color: #e3f2fd; transition: background-color 0.3s; }\n",
    ".section { margin: 40px 0; padding: 30px; background: #f8f9fa; border-radius: 8px; border: 1px solid #dee2e6; }\n",
    ".highlight { background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; border-radius: 4px; }\n",
    ".success { background-color: #d4edda; padding: 15px; border-left: 4px solid #28a745; margin: 20px 0; border-radius: 4px; }\n",
    ".warning { background-color: #f8d7da; padding: 15px; border-left: 4px solid #dc3545; margin: 20px 0; border-radius: 4px; }\n",
    ".info { background-color: #d1ecf1; padding: 15px; border-left: 4px solid #17a2b8; margin: 20px 0; border-radius: 4px; }\n",
    ".stat-box { display: inline-block; padding: 20px 30px; margin: 10px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 8px; min-width: 150px; text-align: center; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }\n",
    ".stat-value { font-size: 2.5em; font-weight: bold; display: block; }\n",
    ".stat-label { font-size: 0.9em; opacity: 0.9; text-transform: uppercase; letter-spacing: 1px; }\n",
    ".risk-high { background-color: #dc3545; color: white; padding: 5px 10px; border-radius: 4px; font-weight: bold; }\n",
    ".risk-medium { background-color: #ffc107; color: #333; padding: 5px 10px; border-radius: 4px; font-weight: bold; }\n",
    ".risk-low { background-color: #28a745; color: white; padding: 5px 10px; border-radius: 4px; font-weight: bold; }\n",
    ".toc { background: #f8f9fa; padding: 25px; border-radius: 8px; margin: 30px 0; border: 2px solid #dee2e6; }\n",
    ".toc h3 { margin-top: 0; color: #495057; }\n",
    ".toc ul { list-style: none; padding-left: 0; }\n",
    ".toc li { padding: 8px 0; border-bottom: 1px solid #dee2e6; }\n",
    ".toc li:last-child { border-bottom: none; }\n",
    ".toc a { color: #3498db; text-decoration: none; font-weight: 500; }\n",
    ".toc a:hover { color: #2980b9; text-decoration: underline; }\n",
    "ul.styled { list-style: none; padding-left: 0; }\n",
    "ul.styled li { padding: 10px 0 10px 30px; position: relative; }\n",
    "ul.styled li:before { content: '>'; position: absolute; left: 0; color: #3498db; font-weight: bold; font-size: 1.2em; }\n",
    ".footer { margin-top: 50px; padding-top: 20px; border-top: 2px solid #dee2e6; text-align: center; color: #6c757d; }\n",
    ".page-break { page-break-after: always; }\n",
    "@media print { .page-break { page-break-after: always; } body { background: white; } .container { box-shadow: none; } }\n"
  )
}

#' Generate Statistics Dashboard HTML
#' @param data Bowtie data frame
#' @return HTML string
generate_statistics_dashboard <- function(data) {
  paste0(
    "<div style='text-align: center; margin: 40px 0;'>\n",
    "<h2>Key Statistics at a Glance</h2>\n",
    "<div style='margin: 30px 0;'>\n",
    "<div class='stat-box'>\n",
    "<span class='stat-value'>", nrow(data), "</span>\n",
    "<span class='stat-label'>Total Scenarios</span>\n",
    "</div>\n",
    "<div class='stat-box'>\n",
    "<span class='stat-value'>", length(unique(data$Central_Problem)), "</span>\n",
    "<span class='stat-label'>Unique Problems</span>\n",
    "</div>\n",
    "<div class='stat-box'>\n",
    "<span class='stat-value'>", length(unique(data$Activity)), "</span>\n",
    "<span class='stat-label'>Activities</span>\n",
    "</div>\n",
    "<div class='stat-box'>\n",
    "<span class='stat-value'>", length(unique(data$Consequence)), "</span>\n",
    "<span class='stat-label'>Consequences</span>\n",
    "</div>\n",
    "</div>\n</div>\n"
  )
}

#' Generate Section Content HTML
#' @param section Section list
#' @param data Bowtie data frame
#' @return HTML string
generate_section_content <- function(section, data) {
  html_content <- ""

  if (section$title == "Executive Summary") {
    html_content <- generate_executive_summary(section, data)
  } else if (section$title == "Bowtie Diagrams") {
    html_content <- generate_bowtie_section(section, data)
  } else if (section$title == "Risk Matrix") {
    html_content <- generate_risk_matrix_section(section, data)
  } else if (section$title == "Bayesian Network Analysis") {
    html_content <- generate_bayesian_section(section, data)
  } else if (section$title == "Vocabulary Details") {
    html_content <- generate_vocabulary_section(section, data)
  } else if (section$title == "Data Tables") {
    html_content <- generate_data_tables_section(section, data)
  }

  return(html_content)
}

#' Generate Executive Summary HTML
generate_executive_summary <- function(section, data) {
  avg_likelihood <- mean(data$Likelihood, na.rm = TRUE)
  avg_severity <- mean(data$Severity, na.rm = TRUE)
  high_risk_count <- sum(data$Likelihood >= 4 & data$Severity >= 4, na.rm = TRUE)

  html_content <- paste0(
    "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
    "<div class='info'>\n",
    "<h4>Analysis Overview</h4>\n",
    "<p>This report presents a comprehensive environmental risk analysis covering <strong>", nrow(data),
    "</strong> scenarios across <strong>", length(unique(data$Central_Problem)),
    "</strong> distinct environmental problems.</p>\n",
    "</div>\n",
    "<h3>Key Findings</h3>\n",
    "<ul class='styled'>\n",
    "<li><strong>Average Likelihood:</strong> ", round(avg_likelihood, 2), " out of 5</li>\n",
    "<li><strong>Average Severity:</strong> ", round(avg_severity, 2), " out of 5</li>\n",
    "<li><strong>High-Risk Scenarios:</strong> ", high_risk_count, " scenarios require immediate attention</li>\n",
    "<li><strong>Control Measures:</strong> ", sum(!is.na(data$Preventive_Control)),
    " preventive controls and ", sum(!is.na(data$Protective_Mitigation)), " protective mitigations identified</li>\n",
    "</ul>\n"
  )

  if (high_risk_count > 0) {
    html_content <- paste0(html_content,
      "<div class='warning'>\n",
      "<h4>Attention Required</h4>\n",
      "<p><strong>", high_risk_count, "</strong> scenarios have been identified as high-risk.</p>\n",
      "</div>\n"
    )
  }

  return(html_content)
}

#' Generate Bowtie Diagrams Section HTML
generate_bowtie_section <- function(section, data) {
  html_content <- paste0(
    "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
    "<div class='info'>\n",
    "<h4>About Bowtie Analysis</h4>\n",
    "<p>Bowtie diagrams visualize the complete risk pathway from causes to consequences.</p>\n",
    "</div>\n",
    "<h3>Complete Risk Pathways</h3>\n",
    "<table>\n",
    "<tr><th>Problem</th><th>Activity</th><th>Pressure</th><th>Preventive Control</th><th>Consequence</th><th>Risk Score</th></tr>\n"
  )

  for (i in 1:min(50, nrow(data))) {
    risk_score <- data$Likelihood[i] * data$Severity[i]
    risk_class <- if (risk_score >= 16) "risk-high" else if (risk_score >= 9) "risk-medium" else "risk-low"

    html_content <- paste0(html_content,
      "<tr>",
      "<td><strong>", data$Central_Problem[i], "</strong></td>",
      "<td>", data$Activity[i], "</td>",
      "<td>", data$Pressure[i], "</td>",
      "<td>", ifelse(is.na(data$Preventive_Control[i]), "<em>None</em>", data$Preventive_Control[i]), "</td>",
      "<td>", data$Consequence[i], "</td>",
      "<td><span class='", risk_class, "'>", risk_score, "</span></td>",
      "</tr>\n"
    )
  }

  if (nrow(data) > 50) {
    html_content <- paste0(html_content,
      "<tr><td colspan='6' style='text-align: center; font-style: italic;'>",
      "Showing first 50 of ", nrow(data), " scenarios.</td></tr>\n"
    )
  }

  html_content <- paste0(html_content, "</table>\n")
  return(html_content)
}

#' Generate Risk Matrix Section HTML
generate_risk_matrix_section <- function(section, data) {
  html_content <- paste0(
    "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
    "<h3>Risk Matrix Analysis</h3>\n",
    "<table>\n",
    "<tr><th>Severity / Likelihood</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th></tr>\n"
  )

  for (l in 5:1) {
    html_content <- paste0(html_content, "<tr><td><strong>", l, "</strong></td>")
    for (s in 1:5) {
      count <- sum(data$Likelihood == l & data$Severity == s, na.rm = TRUE)
      score <- l * s
      cell_class <- if (score >= 16) "risk-high" else if (score >= 9) "risk-medium" else "risk-low"
      html_content <- paste0(html_content,
        "<td style='text-align: center;'><span class='", cell_class, "'>", count, "</span></td>"
      )
    }
    html_content <- paste0(html_content, "</tr>\n")
  }

  html_content <- paste0(html_content, "</table>\n")
  return(html_content)
}

#' Generate Bayesian Network Section HTML
generate_bayesian_section <- function(section, data) {
  paste0(
    "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
    "<div class='info'>\n",
    "<h4>Probabilistic Risk Analysis</h4>\n",
    "<p>Bayesian networks provide a probabilistic framework for understanding risk propagation.</p>\n",
    "</div>\n",
    "<h3>Network Structure</h3>\n",
    "<ul class='styled'>\n",
    "<li><strong>Nodes:</strong> ", length(unique(c(data$Activity, data$Pressure, data$Central_Problem, data$Consequence))),
    " unique elements</li>\n",
    "<li><strong>Pathways:</strong> ", nrow(data), " causal connections</li>\n",
    "<li><strong>Control Points:</strong> ",
    (if ("Preventive_Control" %in% names(data)) sum(!is.na(data$Preventive_Control)) else 0) +
    (if ("Protective_Mitigation" %in% names(data)) sum(!is.na(data$Protective_Mitigation)) else if ("Protective_Control" %in% names(data)) sum(!is.na(data$Protective_Control)) else 0),
    " intervention opportunities</li>\n",
    "</ul>\n"
  )
}

#' Generate Vocabulary Details Section HTML
generate_vocabulary_section <- function(section, data) {
  html_content <- paste0(
    "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
    "<h3>Activities</h3>\n",
    "<ul class='styled'>\n"
  )
  for (act in unique(data$Activity)) {
    if (!is.na(act)) html_content <- paste0(html_content, "<li>", act, "</li>\n")
  }
  html_content <- paste0(html_content, "</ul>\n",
    "<h3>Pressures</h3>\n",
    "<ul class='styled'>\n"
  )
  for (pr in unique(data$Pressure)) {
    if (!is.na(pr)) html_content <- paste0(html_content, "<li>", pr, "</li>\n")
  }
  html_content <- paste0(html_content, "</ul>\n",
    "<h3>Consequences</h3>\n",
    "<ul class='styled'>\n"
  )
  for (cons in unique(data$Consequence)) {
    if (!is.na(cons)) html_content <- paste0(html_content, "<li>", cons, "</li>\n")
  }
  html_content <- paste0(html_content, "</ul>\n")
  return(html_content)
}

#' Generate Data Tables Section HTML
generate_data_tables_section <- function(section, data) {
  html_content <- paste0(
    "<p style='font-size: 1.1em; line-height: 1.8;'>", section$description, "</p>\n",
    "<h3>Environmental Problems Overview</h3>\n",
    "<table>\n",
    "<tr><th>#</th><th>Problem</th><th>Occurrences</th><th>Percentage</th></tr>\n"
  )

  problem_counts <- sort(table(data$Central_Problem), decreasing = TRUE)
  for (i in 1:min(20, length(problem_counts))) {
    html_content <- paste0(html_content,
      "<tr><td>", i, "</td>",
      "<td>", names(problem_counts)[i], "</td>",
      "<td>", problem_counts[i], "</td>",
      "<td>", round(problem_counts[i] / nrow(data) * 100, 1), "%</td></tr>\n"
    )
  }

  html_content <- paste0(html_content, "</table>\n")
  return(html_content)
}

log_debug("   report_generation_module.R loaded (report generation, download handlers)")
