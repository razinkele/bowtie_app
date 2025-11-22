# =============================================================================
# Interactive Guided Workflow Test Runner
# Version: 1.0.0
# Description: Interactive Shiny app to test guided workflow with sample data
# =============================================================================

# Load required packages
library(shiny)
library(bslib)
library(DT)
library(dplyr)

# Source the guided workflow system
cat("Loading guided workflow system...\n")
source("guided_workflow.R")

# =============================================================================
# TEST DATA GENERATION
# =============================================================================

# Create comprehensive test vocabulary
create_test_vocabulary <- function() {
  list(
    activities = data.frame(
      id = 1:15,
      name = c(
        "Agriculture",
        "Industrial discharge",
        "Urban development",
        "Commercial fishing",
        "Tourism activities",
        "Transportation",
        "Mining operations",
        "Forestry",
        "Aquaculture",
        "Waste disposal",
        "Energy production",
        "Construction",
        "Port operations",
        "Dredging",
        "Shipping"
      ),
      category = c("Primary", "Secondary", "Tertiary", "Primary", "Tertiary",
                   "Secondary", "Primary", "Primary", "Primary", "Secondary",
                   "Secondary", "Secondary", "Tertiary", "Secondary", "Tertiary"),
      description = c(
        "Farming and agricultural activities",
        "Industrial wastewater and effluents",
        "Urban expansion and infrastructure",
        "Commercial fishing operations",
        "Tourism and recreational activities",
        "Road, rail, and air transport",
        "Extractive mining activities",
        "Logging and forest management",
        "Fish and shellfish farming",
        "Waste management and disposal",
        "Power generation facilities",
        "Building and infrastructure projects",
        "Harbor and port activities",
        "Channel and waterway dredging",
        "Maritime shipping activities"
      ),
      stringsAsFactors = FALSE
    ),
    
    pressures = data.frame(
      id = 1:15,
      name = c(
        "Nutrient pollution",
        "Chemical contamination",
        "Habitat destruction",
        "Overfishing",
        "Physical disturbance",
        "Noise pollution",
        "Sediment runoff",
        "Temperature changes",
        "Plastic pollution",
        "Oil spills",
        "Heavy metal contamination",
        "Eutrophication",
        "Turbidity",
        "Salinity changes",
        "Invasive species"
      ),
      category = c("Chemical", "Chemical", "Physical", "Biological", "Physical",
                   "Physical", "Physical", "Physical", "Chemical", "Chemical",
                   "Chemical", "Chemical", "Physical", "Physical", "Biological"),
      description = c(
        "Excess nitrogen and phosphorus",
        "Toxic chemical pollutants",
        "Loss of habitat structure",
        "Unsustainable fishing pressure",
        "Physical damage to ecosystems",
        "Underwater and atmospheric noise",
        "Soil erosion and sedimentation",
        "Thermal pollution effects",
        "Microplastic and macroplastic debris",
        "Petroleum hydrocarbon spills",
        "Lead, mercury, cadmium contamination",
        "Algal bloom formation",
        "Reduced water clarity",
        "Altered salinity levels",
        "Non-native species introduction"
      ),
      stringsAsFactors = FALSE
    ),
    
    controls = data.frame(
      id = 1:12,
      name = c(
        "Environmental regulations",
        "Impact assessments",
        "Protected areas",
        "Fishing quotas",
        "Pollution monitoring",
        "Treatment facilities",
        "Buffer zones",
        "Education programs",
        "Best management practices",
        "Enforcement mechanisms",
        "Technology upgrades",
        "Restoration projects"
      ),
      type = c("Regulatory", "Administrative", "Physical", "Regulatory",
               "Monitoring", "Technical", "Physical", "Social",
               "Administrative", "Regulatory", "Technical", "Physical"),
      effectiveness = c("High", "Medium", "High", "High", "Medium", "High",
                       "Medium", "Low", "Medium", "High", "High", "Medium"),
      stringsAsFactors = FALSE
    ),
    
    consequences = data.frame(
      id = 1:10,
      name = c(
        "Biodiversity loss",
        "Ecosystem collapse",
        "Water quality degradation",
        "Human health impacts",
        "Economic losses",
        "Social impacts",
        "Food security threats",
        "Habitat fragmentation",
        "Species extinction",
        "Cultural heritage loss"
      ),
      severity = c("High", "Critical", "High", "High", "Medium", "Medium",
                   "High", "Medium", "Critical", "Medium"),
      timeframe = c("Long-term", "Medium-term", "Short-term", "Medium-term",
                    "Short-term", "Long-term", "Medium-term", "Long-term",
                    "Long-term", "Long-term"),
      stringsAsFactors = FALSE
    )
  )
}

# Test scenarios with pre-filled data
test_scenarios <- list(
  blank = list(
    name = "Blank Workflow",
    description = "Start with empty workflow",
    data = NULL
  ),
  
  eutrophication = list(
    name = "Baltic Sea Eutrophication",
    description = "Nutrient pollution management in Baltic Sea",
    data = list(
      project_name = "Baltic Sea Nutrient Management Project",
      project_location = "Baltic Sea, Northern Europe",
      project_type = "Marine",
      project_description = "Addressing excessive nutrient loading from agricultural and urban sources leading to harmful algal blooms and hypoxic conditions",
      problem_statement = "Excessive nutrient loading causing harmful algal blooms and oxygen depletion",
      problem_category = "Water Quality",
      problem_details = "High concentrations of nitrogen and phosphorus from agricultural runoff, urban wastewater, and atmospheric deposition are causing eutrophication. This leads to massive algal blooms, oxygen depletion in bottom waters, and degradation of marine ecosystems.",
      problem_scale = "Regional",
      problem_urgency = "High",
      activities = c("Agriculture", "Urban development", "Waste disposal"),
      pressures = c("Nutrient pollution", "Eutrophication", "Chemical contamination")
    )
  ),
  
  coral_reef = list(
    name = "Great Barrier Reef Conservation",
    description = "Multi-stressor management for coral reef protection",
    data = list(
      project_name = "Great Barrier Reef Multi-Stressor Management",
      project_location = "Great Barrier Reef, Queensland, Australia",
      project_type = "Marine",
      project_description = "Comprehensive approach to protecting coral reefs from climate change impacts, water quality degradation, and physical disturbances",
      problem_statement = "Coral bleaching and reef degradation from multiple stressors",
      problem_category = "Ecosystem Health",
      problem_details = "Rising sea temperatures, declining water quality from agricultural runoff, crown-of-thorns starfish outbreaks, and tourism impacts are causing widespread coral mortality and reef degradation.",
      problem_scale = "Regional",
      problem_urgency = "Critical",
      activities = c("Agriculture", "Tourism activities", "Commercial fishing", "Shipping"),
      pressures = c("Temperature changes", "Nutrient pollution", "Physical disturbance", "Sediment runoff")
    )
  ),
  
  industrial_pollution = list(
    name = "Industrial River Pollution",
    description = "Heavy metal contamination from industrial sources",
    data = list(
      project_name = "Urban Industrial Waterway Remediation",
      project_location = "Industrial River Basin, Urban Area",
      project_type = "Freshwater",
      project_description = "Managing heavy metal and chemical contamination from industrial discharge in urban waterways",
      problem_statement = "Heavy metal contamination threatening aquatic ecosystems and drinking water",
      problem_category = "Pollution",
      problem_details = "Multiple industrial facilities discharge treated and untreated wastewater containing heavy metals (mercury, lead, cadmium) and organic pollutants. Legacy contamination in sediments continues to impact water quality.",
      problem_scale = "Local",
      problem_urgency = "High",
      activities = c("Industrial discharge", "Mining operations", "Waste disposal", "Urban development"),
      pressures = c("Heavy metal contamination", "Chemical contamination", "Sediment runoff", "Turbidity")
    )
  ),
  
  overfishing = list(
    name = "Coastal Fisheries Management",
    description = "Sustainable fisheries and ecosystem recovery",
    data = list(
      project_name = "Coastal Fisheries Sustainability Program",
      project_location = "Coastal Waters, West Africa",
      project_type = "Marine",
      project_description = "Addressing overfishing, illegal fishing, and ecosystem degradation in coastal fisheries",
      problem_statement = "Overfishing and destructive fishing practices depleting fish stocks",
      problem_category = "Resource Management",
      problem_details = "Intensive commercial and artisanal fishing using destructive methods (bottom trawling, dynamite) combined with illegal, unreported, and unregulated (IUU) fishing is depleting fish stocks and damaging critical habitats.",
      problem_scale = "Regional",
      problem_urgency = "High",
      activities = c("Commercial fishing", "Aquaculture", "Port operations"),
      pressures = c("Overfishing", "Habitat destruction", "Physical disturbance")
    )
  ),
  
  plastic_pollution = list(
    name = "Ocean Plastic Reduction",
    description = "Reducing plastic pollution in marine environment",
    data = list(
      project_name = "Marine Plastic Pollution Prevention Initiative",
      project_location = "Southeast Asian Coastal Waters",
      project_type = "Marine",
      project_description = "Comprehensive strategy to reduce plastic waste entering oceans from land-based and marine sources",
      problem_statement = "Plastic pollution threatening marine life and ecosystem function",
      problem_category = "Pollution",
      problem_details = "Large volumes of plastic waste from inadequate waste management, single-use plastics, fishing gear, and shipping activities are accumulating in marine environments, harming wildlife and entering food chains.",
      problem_scale = "Regional",
      problem_urgency = "High",
      activities = c("Waste disposal", "Tourism activities", "Shipping", "Commercial fishing"),
      pressures = c("Plastic pollution", "Chemical contamination", "Physical disturbance")
    )
  )
)

# =============================================================================
# TEST UI
# =============================================================================

test_ui <- page_navbar(
  title = "Guided Workflow Test Suite",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  
  nav_panel(
    "Test Runner",
    icon = icon("flask"),
    
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        
        h4("Test Configuration"),
        
        selectInput(
          "test_scenario",
          "Load Test Scenario:",
          choices = c(
            "Select a scenario..." = "",
            "Blank Workflow" = "blank",
            "Baltic Sea Eutrophication" = "eutrophication",
            "Great Barrier Reef" = "coral_reef",
            "Industrial Pollution" = "industrial_pollution",
            "Coastal Fisheries" = "overfishing",
            "Ocean Plastic Pollution" = "plastic_pollution"
          )
        ),
        
        actionButton("load_scenario", "Load Scenario", 
                    class = "btn-primary w-100", icon = icon("upload")),
        
        hr(),
        
        h5("Scenario Information"),
        uiOutput("scenario_info"),
        
        hr(),
        
        h5("Test Actions"),
        actionButton("auto_complete_step", "Auto-Complete Current Step",
                    class = "btn-success w-100 mb-2", icon = icon("magic")),
        actionButton("reset_workflow", "Reset Workflow",
                    class = "btn-warning w-100 mb-2", icon = icon("refresh")),
        
        hr(),
        
        h5("Workflow Status"),
        uiOutput("workflow_status")
      ),
      
      # Main test area with guided workflow
      card(
        card_header("Guided Workflow Testing Environment"),
        guided_workflow_ui("test_workflow")
      )
    )
  ),
  
  nav_panel(
    "Test Data",
    icon = icon("database"),
    
    layout_columns(
      col_widths = c(6, 6),
      
      card(
        card_header("Activities Vocabulary"),
        DTOutput("activities_table")
      ),
      
      card(
        card_header("Pressures Vocabulary"),
        DTOutput("pressures_table")
      )
    ),
    
    layout_columns(
      col_widths = c(6, 6),
      
      card(
        card_header("Controls Vocabulary"),
        DTOutput("controls_table")
      ),
      
      card(
        card_header("Consequences Vocabulary"),
        DTOutput("consequences_table")
      )
    )
  ),
  
  nav_panel(
    "Test Results",
    icon = icon("chart-bar"),
    
    card(
      card_header("Workflow State Debug View"),
      verbatimTextOutput("workflow_state_debug")
    ),
    
    card(
      card_header("Exported Data Preview"),
      DTOutput("exported_data_preview")
    )
  )
)

# =============================================================================
# TEST SERVER
# =============================================================================

test_server <- function(input, output, session) {
  
  # Create test vocabulary
  vocabulary_data <- create_test_vocabulary()
  
  # Initialize guided workflow
  workflow_state <- guided_workflow_server("test_workflow", vocabulary_data = vocabulary_data)
  
  # Track loaded scenario
  current_scenario <- reactiveVal(NULL)
  
  # Display scenario information
  output$scenario_info <- renderUI({
    scenario_id <- input$test_scenario
    
    if (is.null(scenario_id) || scenario_id == "") {
      return(p("No scenario selected", class = "text-muted"))
    }
    
    scenario <- test_scenarios[[scenario_id]]
    
    tagList(
      h6(scenario$name, class = "text-primary"),
      p(scenario$description, class = "small text-muted")
    )
  })
  
  # Display workflow status
  output$workflow_status <- renderUI({
    state <- workflow_state()
    req(state)
    
    tagList(
      div(
        class = "mb-2",
        strong("Current Step:"), br(),
        span(paste(state$current_step, "of", state$total_steps), class = "badge bg-primary")
      ),
      div(
        class = "mb-2",
        strong("Progress:"), br(),
        span(paste0(round(state$progress_percentage, 1), "%"), class = "badge bg-success")
      ),
      div(
        class = "mb-2",
        strong("Completed Steps:"), br(),
        span(length(state$completed_steps), class = "badge bg-info")
      ),
      div(
        strong("Project:"), br(),
        p(if (nchar(state$project_name) > 0) state$project_name else "Not set", 
          class = "small text-muted")
      )
    )
  })
  
  # Load scenario data
  observeEvent(input$load_scenario, {
    req(input$test_scenario)
    
    scenario_id <- input$test_scenario
    scenario <- test_scenarios[[scenario_id]]
    current_scenario(scenario)
    
    if (is.null(scenario$data)) {
      showNotification("Blank workflow loaded", type = "message")
    } else {
      showNotification(paste("Loaded:", scenario$name), type = "message", duration = 3)
    }
  })
  
  # Auto-complete current step (for testing navigation)
  observeEvent(input$auto_complete_step, {
    state <- workflow_state()
    req(state)
    
    scenario <- current_scenario()
    
    if (is.null(scenario) || is.null(scenario$data)) {
      showNotification("Please load a test scenario first", type = "warning")
      return()
    }
    
    step <- state$current_step
    data <- scenario$data
    
    # Update inputs based on current step
    if (step == 1 && !is.null(data$project_name)) {
      updateTextInput(session, "test_workflow-project_name", value = data$project_name)
      updateTextInput(session, "test_workflow-project_location", value = data$project_location)
      updateSelectInput(session, "test_workflow-project_type", selected = data$project_type)
      updateTextAreaInput(session, "test_workflow-project_description", value = data$project_description)
      showNotification("Step 1 data filled", type = "message")
    } else if (step == 2 && !is.null(data$problem_statement)) {
      updateTextAreaInput(session, "test_workflow-problem_statement", value = data$problem_statement)
      updateSelectInput(session, "test_workflow-problem_category", selected = data$problem_category)
      updateTextAreaInput(session, "test_workflow-problem_details", value = data$problem_details)
      updateSelectInput(session, "test_workflow-problem_scale", selected = data$problem_scale)
      updateSelectInput(session, "test_workflow-problem_urgency", selected = data$problem_urgency)
      showNotification("Step 2 data filled", type = "message")
    } else {
      showNotification(paste("Auto-complete not implemented for step", step), type = "info")
    }
  })
  
  # Reset workflow
  observeEvent(input$reset_workflow, {
    showModal(modalDialog(
      title = "Reset Workflow?",
      "This will clear all workflow data and return to step 1. Are you sure?",
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_reset", "Reset", class = "btn-danger")
      )
    ))
  })
  
  observeEvent(input$confirm_reset, {
    removeModal()
    session$reload()
  })
  
  # Display vocabulary tables
  output$activities_table <- renderDT({
    datatable(
      vocabulary_data$activities,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  output$pressures_table <- renderDT({
    datatable(
      vocabulary_data$pressures,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  output$controls_table <- renderDT({
    datatable(
      vocabulary_data$controls,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  output$consequences_table <- renderDT({
    datatable(
      vocabulary_data$consequences,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  # Debug view of workflow state
  output$workflow_state_debug <- renderPrint({
    state <- workflow_state()
    req(state)
    
    cat("WORKFLOW STATE DEBUG\n")
    cat("====================\n\n")
    cat("Current Step:", state$current_step, "\n")
    cat("Total Steps:", state$total_steps, "\n")
    cat("Completed Steps:", paste(state$completed_steps, collapse = ", "), "\n")
    cat("Progress:", round(state$progress_percentage, 1), "%\n\n")
    
    cat("PROJECT DATA:\n")
    cat("-------------\n")
    cat("Project Name:", state$project_data$project_name, "\n")
    cat("Location:", state$project_data$project_location, "\n")
    cat("Type:", state$project_data$project_type, "\n")
    cat("Problem:", state$project_data$problem_statement, "\n")
    cat("Category:", state$project_data$problem_category, "\n\n")
    
    cat("ACTIVITIES:", length(state$project_data$activities), "\n")
    if (length(state$project_data$activities) > 0) {
      cat("  ", paste(state$project_data$activities, collapse = ", "), "\n")
    }
    
    cat("PRESSURES:", length(state$project_data$pressures), "\n")
    if (length(state$project_data$pressures) > 0) {
      cat("  ", paste(state$project_data$pressures, collapse = ", "), "\n")
    }
  })
  
  # Preview exported data
  output$exported_data_preview <- renderDT({
    state <- workflow_state()
    req(state)
    
    if (length(state$project_data$activities) > 0 && length(state$project_data$pressures) > 0) {
      # Create simple preview
      preview <- expand.grid(
        Activity = state$project_data$activities,
        Pressure = state$project_data$pressures,
        stringsAsFactors = FALSE
      )
      preview$Central_Problem <- state$project_data$problem_statement
      
      datatable(preview, options = list(pageLength = 5), rownames = FALSE)
    } else {
      datatable(
        data.frame(Message = "No data to preview yet. Complete steps 1-3."),
        options = list(dom = 't'),
        rownames = FALSE
      )
    }
  })
}

# =============================================================================
# RUN TEST APP
# =============================================================================

cat("\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("🧪 GUIDED WORKFLOW INTERACTIVE TEST SUITE\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("\n")
cat("📋 Available Test Scenarios:\n")
cat("   1. Blank Workflow - Start fresh\n")
cat("   2. Baltic Sea Eutrophication - Nutrient management\n")
cat("   3. Great Barrier Reef - Multi-stressor management\n")
cat("   4. Industrial Pollution - Heavy metal contamination\n")
cat("   5. Coastal Fisheries - Overfishing management\n")
cat("   6. Ocean Plastic - Plastic pollution reduction\n")
cat("\n")
cat("🎯 Features:\n")
cat("   • Load pre-configured test scenarios\n")
cat("   • Auto-complete step data for testing\n")
cat("   • View vocabulary tables\n")
cat("   • Debug workflow state in real-time\n")
cat("   • Preview exported data\n")
cat("\n")
cat("▶️  Starting test application...\n")
cat("\n")

shinyApp(ui = test_ui, server = test_server)
