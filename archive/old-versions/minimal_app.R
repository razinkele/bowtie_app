# Minimal Environmental Bowtie App - Version 5.1
# Simplified version for testing and demonstration

library(shiny)
library(DT)
library(ggplot2)

# Simple data for demonstration
demo_data <- data.frame(
  Activity = c("Industrial Manufacturing", "Agricultural Operations", "Urban Development"),
  Pressure = c("Chemical Discharge", "Nutrient Runoff", "Habitat Fragmentation"),
  Problem = c("Water Pollution", "Water Pollution", "Biodiversity Loss"),
  Consequence = c("Ecosystem Damage", "Algal Blooms", "Species Decline"),
  Risk_Level = c("High", "Medium", "High"),
  stringsAsFactors = FALSE
)

# UI
ui <- fluidPage(
  titlePanel("🌿 Environmental Bowtie Risk Analysis v5.1 - Demo"),

  sidebarLayout(
    sidebarPanel(
      h4("📊 Application Status"),
      p("✅ Version 5.1.0 loaded successfully"),
      p("🎯 Core functionality active"),
      p("📋 Demo data loaded"),
      br(),

      selectInput("problem", "Select Environmental Problem:",
                  choices = unique(demo_data$Problem),
                  selected = "Water Pollution"),

      br(),
      h5("🚀 Full App Features:"),
      tags$ul(
        tags$li("21+ Bootstrap Themes"),
        tags$li("Guided Workflow System"),
        tags$li("Bayesian Network Analysis"),
        tags$li("189+ Vocabulary Items"),
        tags$li("Excel Import/Export"),
        tags$li("Interactive Risk Matrix")
      )
    ),

    mainPanel(
      h3("📈 Risk Assessment Results"),

      tabsetPanel(
        tabPanel("Data Table",
                 br(),
                 DT::dataTableOutput("dataTable")
        ),

        tabPanel("Risk Visualization",
                 br(),
                 plotOutput("riskPlot")
        ),

        tabPanel("About v5.1",
                 br(),
                 h4("🎉 What's New in Version 5.1"),
                 tags$ul(
                   tags$li("Enhanced Development Infrastructure"),
                   tags$li("Parallel Test Execution (95%+ coverage)"),
                   tags$li("Performance Benchmarking"),
                   tags$li("Memory Usage Monitoring"),
                   tags$li("Bootstrap Theme Testing"),
                   tags$li("Cross-Platform Compatibility"),
                   tags$li("Structured Logging System")
                 ),
                 br(),
                 p("This is a minimal demo. The full application includes comprehensive bowtie analysis,
                   Bayesian networks, guided workflow, and advanced visualization features.")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {

  # Reactive data
  filtered_data <- reactive({
    demo_data[demo_data$Problem == input$problem, ]
  })

  # Data table output
  output$dataTable <- DT::renderDataTable({
    DT::datatable(filtered_data(),
                  options = list(pageLength = 10, scrollX = TRUE),
                  caption = paste("Environmental Risk Data for:", input$problem))
  })

  # Risk plot
  output$riskPlot <- renderPlot({
    data <- filtered_data()

    if(nrow(data) > 0) {
      ggplot(data, aes(x = Activity, y = Consequence, color = Risk_Level)) +
        geom_point(size = 4) +
        scale_color_manual(values = c("High" = "red", "Medium" = "orange", "Low" = "green")) +
        theme_minimal() +
        labs(title = paste("Risk Assessment:", input$problem),
             subtitle = "Environmental Bowtie Analysis v5.1",
             x = "Activities", y = "Consequences") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
  })
}

# Launch app
cat("🚀 Launching Environmental Bowtie Risk Analysis v5.1 - Demo Version\n")
cat("📍 Access the app in your browser once started\n")

shinyApp(ui = ui, server = server, options = list(port = 3838, host = "0.0.0.0"))