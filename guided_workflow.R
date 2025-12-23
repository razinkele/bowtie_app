# =============================================================================
# Guided Workflow System - Step-by-Step Bowtie Creation
# Version: 5.1.0
# Date: September 2025
# Description: Comprehensive wizard-based system for guided bowtie diagram creation
#              with progress tracking, validation, and expert guidance
# =============================================================================

# =============================================================================
# DEPENDENCY VALIDATION AND LOADING
# =============================================================================

# Validate and load required dependencies
validate_guided_workflow_dependencies <- function() {
  cat("🔍 Validating guided workflow dependencies...\n")

  required_packages <- c("shiny", "bslib", "dplyr", "DT")
  optional_packages <- c("ggplot2", "plotly", "openxlsx", "jsonlite")
  missing_required <- c()
  missing_optional <- c()

  # Check required packages
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_required <- c(missing_required, pkg)
    } else {
      tryCatch({
        library(pkg, character.only = TRUE, quietly = TRUE)
      }, error = function(e) {
        missing_required <- c(missing_required, pkg)
      })
    }
  }

  # Check optional packages
  for (pkg in optional_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_optional <- c(missing_optional, pkg)
    }
  }

  # Report results
  if (length(missing_required) > 0) {
    cat("❌ Missing required packages:", paste(missing_required, collapse = ", "), "\n")
    cat("   Install with: install.packages(c(", paste(paste0("'", missing_required, "'"), collapse = ", "), "))\n")
    return(FALSE)
  }

  if (length(missing_optional) > 0) {
    cat("⚠️ Missing optional packages:", paste(missing_optional, collapse = ", "), "\n")
    cat("   Some features may be limited. Install with: install.packages(c(", paste(paste0("'", missing_optional, "'"), collapse = ", "), "))\n")
  }

  # Validate function availability
  required_functions <- c(
    "fluidPage", "tabPanel", "actionButton", "selectizeInput", "DTOutput"
  )

  missing_functions <- c()
  for (func in required_functions) {
    if (!exists(func, mode = "function")) {
      missing_functions <- c(missing_functions, func)
    }
  }

  if (length(missing_functions) > 0) {
    cat("❌ Missing required functions:", paste(missing_functions, collapse = ", "), "\n")
    return(FALSE)
  }

  cat("✅ All dependencies validated successfully!\n")
  return(TRUE)
}

# Load dependencies
if (!validate_guided_workflow_dependencies()) {
  stop("❌ Guided Workflow System: Dependency validation failed")
}

cat("🧙 GUIDED WORKFLOW SYSTEM v1.1.0\n")
cat("=================================\n")
cat("Step-by-step bowtie creation with expert guidance\n\n")

# =============================================================================
# WORKFLOW CONFIGURATION
# =============================================================================

WORKFLOW_CONFIG <- list(
  steps = list(
    step1 = list(
      id = "project_setup",
      title = "Project Setup",
      description = "gw_step1_desc",
      icon = "clipboard-list",
      estimated_time = "gw_step8_time"
    ),
    step2 = list(
      id = "central_problem",
      title = "Central Problem Definition",
      description = "gw_step2_desc",
      icon = "bullseye",
      estimated_time = "gw_step7_time"
    ),
    step3 = list(
      id = "threats_causes",
      title = "Threats & Causes",
      description = "gw_step3_desc",
      icon = "exclamation-triangle",
      estimated_time = "gw_step3_time"
    ),
    step4 = list(
      id = "preventive_controls",
      title = "Preventive Controls",
      description = "gw_step4_desc",
      icon = "shield-alt",
      estimated_time = "gw_step6_time"
    ),
    step5 = list(
      id = "consequences",
      title = "Consequences",
      description = "gw_step5_desc",
      icon = "exclamation",
      estimated_time = "gw_step7_time"
    ),
    step6 = list(
      id = "protective_controls",
      title = "Protective Controls",
      description = "gw_step6_desc",
      icon = "life-ring",
      estimated_time = "gw_step6_time"
    ),
    step7 = list(
      id = "review_validate",
      title = "Review & Validate",
      description = "gw_step7_desc",
      icon = "check-circle",
      estimated_time = "gw_step7_time"
    ),
    step8 = list(
      id = "finalize_export",
      title = "Finalize & Export",
      description = "gw_step8_desc",
      icon = "download",
      estimated_time = "gw_step8_time"
    )
  ),
  templates = list(
    marine_pollution = list(
      name = "Marine Pollution Assessment",
      project_name = "Marine Pollution Risk Assessment",
      project_location = "Coastal and Marine Environment",
      project_type = "marine",
      project_description = "Comprehensive assessment of marine pollution from shipping operations, coastal activities, and industrial discharge impacting marine ecosystems and biodiversity.",
      central_problem = "Marine pollution from shipping and coastal activities",
      problem_category = "pollution",
      problem_details = "Assessment of chemical contaminants, oil spills, nutrient loading, and marine debris from shipping operations, port activities, and coastal industrial discharge affecting water quality, marine biodiversity, and ecosystem health.",
      problem_scale = "regional",
      problem_urgency = "high",
      example_activities = c("Industrial discharge", "Shipping operations", "Urban runoff"),
      example_pressures = c("Chemical contamination", "Oil spills", "Nutrient loading"),
      category = "Marine Environment"
    ),
    industrial_contamination = list(
      name = "Industrial Contamination Assessment",
      project_name = "Industrial Chemical Discharge Risk Assessment",
      project_location = "Industrial Zone / Coastal Area",
      project_type = "marine",
      project_description = "Risk analysis of chemical pollutants from industrial processes, waste discharge, and manufacturing operations affecting water quality and ecosystems.",
      central_problem = "Industrial contamination through chemical discharge",
      problem_category = "pollution",
      problem_details = "Analysis of toxic chemical releases, heavy metal contamination, pH alterations, and industrial wastewater discharge from manufacturing processes affecting water bodies, soil quality, and ecosystem health.",
      problem_scale = "local",
      problem_urgency = "critical",
      example_activities = c("Chemical manufacturing", "Industrial wastewater", "Process discharge"),
      example_pressures = c("Heavy metal contamination", "Toxic chemical release", "pH alteration"),
      category = "Industrial Impact"
    ),
    oil_spills = list(
      name = "Oil Spill Risk Assessment",
      project_name = "Maritime Oil Spill Risk Assessment",
      project_location = "Maritime Routes and Coastal Waters",
      project_type = "marine",
      project_description = "Assessment of petroleum-based contamination scenarios from tanker operations, pipeline leaks, and offshore drilling activities.",
      central_problem = "Oil spills from maritime transportation",
      problem_category = "pollution",
      problem_details = "Evaluation of crude oil and refined product contamination from tanker accidents, pipeline leaks, offshore drilling operations, and bunkering activities affecting marine ecosystems, coastal habitats, and wildlife.",
      problem_scale = "regional",
      problem_urgency = "critical",
      example_activities = c("Tanker operations", "Offshore drilling", "Pipeline transport"),
      example_pressures = c("Crude oil contamination", "Refined product spills", "Persistent pollutants"),
      category = "Maritime Safety"
    ),
    agricultural_runoff = list(
      name = "Agricultural Runoff Assessment",
      project_name = "Agricultural Nutrient Pollution Risk Assessment",
      project_location = "Agricultural Watershed / Coastal Zone",
      project_type = "freshwater",
      project_description = "Analysis of nutrient pollution and water quality impacts from fertilizer use, livestock operations, and agricultural irrigation affecting water bodies.",
      central_problem = "Agricultural runoff causing eutrophication",
      problem_category = "pollution",
      problem_details = "Assessment of nitrogen and phosphorus loading, pesticide contamination, and sediment pollution from fertilizer application, livestock operations, and irrigation practices leading to eutrophication, algal blooms, and water quality degradation.",
      problem_scale = "regional",
      problem_urgency = "high",
      example_activities = c("Fertilizer application", "Livestock farming", "Irrigation"),
      example_pressures = c("Nitrogen loading", "Phosphorus pollution", "Pesticide runoff"),
      category = "Agricultural Impact"
    ),
    overfishing = list(
      name = "Overfishing Impact Assessment",
      project_name = "Commercial Fishing Stock Depletion Assessment",
      project_location = "Marine Fishing Grounds",
      project_type = "marine",
      project_description = "Evaluation of marine resource depletion and ecosystem impacts from commercial fishing practices, bycatch, and habitat destruction.",
      central_problem = "Overfishing and commercial stock depletion",
      problem_category = "resource_depletion",
      problem_details = "Analysis of fish stock depletion, bycatch mortality, seafloor habitat destruction, and ecosystem imbalance from trawl fishing, longline operations, purse seine fishing, and unsustainable harvest practices affecting marine biodiversity and food security.",
      problem_scale = "international",
      problem_urgency = "critical",
      example_activities = c("Trawl fishing", "Longline fishing", "Purse seine operations"),
      example_pressures = c("Stock depletion", "Bycatch mortality", "Habitat destruction"),
      category = "Fisheries Management"
    ),
    martinique_coastal_erosion = list(
      name = "Martinique Coastal Erosion",
      project_name = "Martinique Coastal Erosion and Beach Degradation Assessment",
      project_location = "Martinique - Caribbean and Atlantic Coastlines",
      project_type = "marine",
      project_description = "Assessment of coastal erosion from sea level rise, storm surge, infrastructure development, and sand mining affecting beaches and coastal ecosystems in Martinique.",
      central_problem = "Coastal erosion and beach degradation in Martinique",
      problem_category = "habitat_loss",
      problem_details = "Analysis of beach erosion, coastal habitat loss, and infrastructure vulnerability from sea level rise, storm surge, wave action, coastal development, sand mining, and climate change impacts on Martinique's Caribbean and Atlantic coastlines.",
      problem_scale = "regional",
      problem_urgency = "high",
      example_activities = c("Coastal development", "Sand mining", "Storm impacts"),
      example_pressures = c("Beach erosion", "Habitat loss", "Infrastructure damage"),
      category = "Coastal Management"
    ),
    martinique_sargassum = list(
      name = "Martinique Sargassum Impact",
      project_name = "Martinique Sargassum Seaweed Influx Impact Assessment",
      project_location = "Martinique - Coastal Waters and Beaches",
      project_type = "marine",
      project_description = "Risk analysis of massive Sargassum seaweed arrivals affecting beaches, tourism, marine life, and coastal water quality with hydrogen sulfide emissions.",
      central_problem = "Sargassum seaweed influx impacts on coastal ecosystems",
      problem_category = "ecosystem_services",
      problem_details = "Assessment of massive Sargassum seaweed arrivals, hydrogen sulfide emissions from decomposition, oxygen depletion in coastal waters, beach contamination, tourism disruption, and marine ecosystem degradation affecting Martinique's coastline.",
      problem_scale = "regional",
      problem_urgency = "high",
      example_activities = c("Sargassum influx", "Beach accumulation", "Decomposition"),
      example_pressures = c("Hydrogen sulfide emission", "Oxygen depletion", "Tourism impacts"),
      category = "Marine Nuisance"
    ),
    martinique_coral_degradation = list(
      name = "Martinique Coral Degradation",
      project_name = "Martinique Coral Reef Degradation and Bleaching Assessment",
      project_location = "Martinique - Caribbean Coral Reefs",
      project_type = "marine",
      project_description = "Assessment of coral reef ecosystem degradation including bleaching from rising temperatures, pollution, overfishing, and physical damage from tourism.",
      central_problem = "Coral reef degradation and bleaching events",
      problem_category = "climate_impacts",
      problem_details = "Evaluation of coral bleaching from rising sea temperatures, physical damage from tourism and anchoring, disease outbreaks, pollution runoff, overfishing impacts, and ecosystem degradation threatening Caribbean coral reef biodiversity and fisheries.",
      problem_scale = "regional",
      problem_urgency = "critical",
      example_activities = c("Tourism activities", "Coastal pollution", "Climate warming"),
      example_pressures = c("Coral bleaching", "Physical damage", "Disease outbreak"),
      category = "Reef Conservation"
    ),
    martinique_watershed_pollution = list(
      name = "Martinique Watershed Pollution",
      project_name = "Martinique Agricultural Watershed Pollution Assessment",
      project_location = "Martinique - Agricultural Watersheds",
      project_type = "freshwater",
      project_description = "Analysis of agricultural chemical contamination including chlordecone pesticide legacy, nutrient runoff from plantations, and sediment pollution.",
      central_problem = "Watershed pollution from agricultural chemicals",
      problem_category = "pollution",
      problem_details = "Assessment of persistent chlordecone pesticide contamination, nutrient runoff from banana plantations, sediment pollution from soil erosion, and impacts on rivers, coastal waters, drinking water sources, and aquatic ecosystems in Martinique.",
      problem_scale = "local",
      problem_urgency = "critical",
      example_activities = c("Pesticide application", "Banana cultivation", "Soil erosion"),
      example_pressures = c("Chlordecone contamination", "Nutrient runoff", "Sediment pollution"),
      category = "Agricultural Contamination"
    ),
    martinique_mangrove_loss = list(
      name = "Martinique Mangrove Loss",
      project_name = "Martinique Mangrove Forest Degradation Assessment",
      project_location = "Martinique - Mangrove Areas (Baie de Fort-de-France)",
      project_type = "marine",
      project_description = "Assessment of mangrove ecosystem loss from coastal development, marina construction, pollution, and climate impacts affecting biodiversity.",
      central_problem = "Mangrove forest degradation and loss",
      problem_category = "habitat_loss",
      problem_details = "Analysis of mangrove habitat destruction from marina construction, urban development, pollution discharge, water quality decline, and species loss affecting fish nurseries, coastal protection, and biodiversity in Baie de Fort-de-France and other key areas.",
      problem_scale = "local",
      problem_urgency = "high",
      example_activities = c("Marina construction", "Urban development", "Pollution discharge"),
      example_pressures = c("Habitat destruction", "Water quality decline", "Species loss"),
      category = "Wetland Conservation"
    ),
    martinique_hurricane_impacts = list(
      name = "Martinique Hurricane Impacts",
      project_name = "Martinique Hurricane and Tropical Storm Impact Assessment",
      project_location = "Martinique - Island-wide",
      project_type = "climate",
      project_description = "Comprehensive risk assessment of hurricane effects including infrastructure damage, coastal flooding, ecosystem disruption, and pollution mobilization.",
      central_problem = "Hurricane and tropical storm environmental impacts",
      problem_category = "climate_impacts",
      problem_details = "Comprehensive assessment of hurricane and tropical storm impacts including infrastructure damage, coastal flooding, physical destruction, pollution mobilization, habitat disruption, ecosystem damage, and emergency response challenges across Martinique.",
      problem_scale = "regional",
      problem_urgency = "critical",
      example_activities = c("Storm events", "Coastal flooding", "Infrastructure damage"),
      example_pressures = c("Physical destruction", "Pollution mobilization", "Habitat disruption"),
      category = "Climate Hazards"
    ),
    martinique_marine_tourism = list(
      name = "Martinique Marine Tourism",
      project_name = "Martinique Marine Tourism Environmental Pressure Assessment",
      project_location = "Martinique - Coastal and Marine Tourism Areas",
      project_type = "marine",
      project_description = "Analysis of environmental impacts from cruise ships, yacht anchoring, diving activities, beach recreation, and tourism infrastructure on marine ecosystems.",
      central_problem = "Marine tourism environmental pressures",
      problem_category = "ecosystem_services",
      problem_details = "Evaluation of environmental impacts from cruise ship operations, yacht anchoring damage to coral reefs and seagrass beds, diving tourism pressures, water pollution from vessels, reef trampling, and beach recreation affecting marine ecosystems and coastal water quality.",
      problem_scale = "regional",
      problem_urgency = "medium",
      example_activities = c("Cruise ship operations", "Yacht anchoring", "Diving tourism"),
      example_pressures = c("Anchor damage", "Water pollution", "Reef trampling"),
      category = "Tourism Management"
    ),
    marine_biodiversity_loss = list(
      name = "Marine Biodiversity Loss",
      project_name = "Marine Biodiversity Loss and Ecosystem Degradation Assessment",
      project_location = "Coastal and Marine Ecosystems",
      project_type = "marine",
      project_description = "Comprehensive assessment of marine species decline, habitat destruction, and ecosystem imbalance from multiple pressures including overfishing, pollution, climate change, invasive species, and coastal development.",
      central_problem = "Marine biodiversity loss and ecosystem degradation",
      problem_category = "habitat_loss",
      problem_details = "Analysis of declining marine species populations, loss of critical habitats (coral reefs, seagrass beds, mangroves), ecosystem function deterioration from overfishing, pollution runoff, coastal development, climate change impacts (warming, acidification), invasive species introductions, and cumulative anthropogenic pressures threatening marine biodiversity and ecosystem services.",
      problem_scale = "global",
      problem_urgency = "critical",
      example_activities = c("Overfishing", "Coastal development", "Pollution discharge"),
      example_pressures = c("Habitat destruction", "Species decline", "Ecosystem imbalance"),
      category = "Marine Conservation"
    ),

    # Macaronesian islands-specific scenarios
    macaronesia_volcanic_impacts = list(
      name = "Macaronesian Volcanic Impacts",
      project_name = "Volcanic Activity Impacts on Marine Ecosystems - Macaronesia",
      project_location = "Macaronesian Islands (Azores, Madeira, Canary Islands, Cape Verde)",
      project_type = "marine",
      project_description = "Assessment of volcanic eruptions, lava flows, ash deposition, and hydrothermal vents affecting coastal waters, marine life, fisheries, and ecosystem recovery in oceanic volcanic islands.",
      central_problem = "Volcanic activity impacts on marine ecosystems",
      problem_category = "climate_impacts",
      problem_details = "Analysis of volcanic eruption effects including lava entry into the sea, ash fallout on water surfaces, changes in water temperature and chemistry near hydrothermal vents, impacts on fish populations and nursery areas, coral and benthic community responses, water quality degradation from volcanic particulates, disruption to fishing activities, and long-term ecosystem recovery patterns in volcanic island marine environments.",
      problem_scale = "regional",
      problem_urgency = "high",
      example_activities = c("Volcanic eruptions", "Lava flows", "Hydrothermal activity"),
      example_pressures = c("Water quality degradation", "Habitat destruction", "Temperature changes"),
      category = "Geological Hazards"
    ),

    macaronesia_endemic_species = list(
      name = "Macaronesian Endemic Species",
      project_name = "Endemic Marine Species Conservation Threats - Macaronesia",
      project_location = "Macaronesian Islands (Azores, Madeira, Canary Islands, Cape Verde)",
      project_type = "marine",
      project_description = "Risk analysis for unique Macaronesian endemic species including monk seals, sea turtles, cetaceans, endemic fish, and invertebrates facing threats from habitat loss, invasive species, climate change, and human activities.",
      central_problem = "Endemic marine species conservation threats",
      problem_category = "habitat_loss",
      problem_details = "Assessment of pressures on endemic and endangered species unique to Macaronesian waters including Mediterranean monk seals, loggerhead and green sea turtles, endemic fish species, rare invertebrates, and resident cetacean populations. Threats include coastal development destroying critical habitats, invasive alien species competition, climate change affecting breeding and feeding areas, overfishing and bycatch, pollution impacts, ship strikes, noise pollution, and cumulative anthropogenic stressors on already vulnerable populations.",
      problem_scale = "regional",
      problem_urgency = "critical",
      example_activities = c("Coastal development", "Invasive species introduction", "Fishing operations"),
      example_pressures = c("Habitat loss", "Species competition", "Bycatch mortality"),
      category = "Biodiversity Conservation"
    ),

    macaronesia_deep_sea = list(
      name = "Macaronesian Deep-Sea Ecosystems",
      project_name = "Deep-Sea Ecosystems and Mining Pressures - Macaronesia",
      project_location = "Macaronesian Deep-Sea Waters (Azores, Madeira, Canary Islands, Cape Verde)",
      project_type = "marine",
      project_description = "Assessment of deep-sea habitats including seamounts, hydrothermal vents, cold-water corals, and abyssal plains threatened by potential deep-sea mining, fishing impacts, climate change, and research activities.",
      central_problem = "Deep-sea ecosystems and mining pressures",
      problem_category = "resource_depletion",
      problem_details = "Analysis of threats to unique Macaronesian deep-sea ecosystems including seamount communities, hydrothermal vent fauna, cold-water coral gardens, sponge aggregations, and abyssal plain biodiversity. Pressures include potential polymetallic nodule and sulfide mining, deep-sea bottom trawling impacts, cable laying activities, oceanographic research disturbance, climate change affecting deep circulation patterns and oxygen levels, ocean acidification, and lack of comprehensive data on ecosystem structure and function limiting conservation efforts.",
      problem_scale = "regional",
      problem_urgency = "high",
      example_activities = c("Deep-sea mining exploration", "Bottom trawling", "Cable installation"),
      example_pressures = c("Habitat destruction", "Sediment plumes", "Biodiversity loss"),
      category = "Deep-Sea Conservation"
    )
  )
)

# =============================================================================
# WORKFLOW STATE MANAGEMENT
# =============================================================================

# Initialize workflow state with complete structure
init_workflow_state <- function() {
  list(
    current_step = 1,
    total_steps = length(WORKFLOW_CONFIG$steps),
    completed_steps = numeric(0),
    project_data = list(
      # Template system compatibility
      template_applied = NULL,
      project_type = NULL,
      project_location = NULL,
      project_description = NULL,
      analysis_scope = NULL,
      # Example data for templates
      example_activities = character(0),
      example_pressures = character(0)
    ),
    validation_status = list(),
    progress_percentage = 0,
    start_time = Sys.time(),
    step_times = list(),
    # Core integration properties
    project_name = "",
    central_problem = "",
    # Additional workflow metadata
    workflow_complete = FALSE,
    converted_main_data = NULL,
    last_saved = NULL
  )
}

# Update workflow progress
update_workflow_progress <- function(state, step_number = NULL, data = NULL) {
  if (!is.null(step_number)) {
    state$current_step <- step_number
    if (!step_number %in% state$completed_steps && step_number < state$current_step) {
      state$completed_steps <- c(state$completed_steps, step_number)
    }
  }
  
  if (!is.null(data)) {
    state$project_data <- append(state$project_data, data)
  }
  
  # Update progress percentage
  state$progress_percentage <- (length(state$completed_steps) / state$total_steps) * 100
  
  return(state)
}

# =============================================================================
# UI COMPONENTS
# =============================================================================

# Main guided workflow UI
guided_workflow_ui <- function(id, current_lang = "en") {
  ns <- NS(id)
  fluidPage(
    # Custom CSS for workflow
    tags$head(
      tags$style(HTML("
        .workflow-header {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 20px;
          border-radius: 10px;
          margin-bottom: 20px;
        }
        /* Hide any text that looks like raw HTML in workflow steps */
        .list-group-item {
          overflow: hidden;
        }
        .list-group-item > div::before {
          content: '';
          display: block;
          height: 0;
          overflow: hidden;
        }
        .workflow-step {
          border: 2px solid #e9ecef;
          border-radius: 10px;
          padding: 20px;
          margin: 10px 0;
          transition: all 0.3s ease;
        }
        .workflow-step.active {
          border-color: #007bff;
          background: #f8f9ff;
        }
        .workflow-step.completed {
          border-color: #28a745;
          background: #f8fff8;
        }
        .step-icon {
          font-size: 2em;
          margin-bottom: 10px;
        }
        .progress-tracker {
          background: white;
          border-radius: 10px;
          padding: 15px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .template-card {
          border: 1px solid #dee2e6;
          border-radius: 8px;
          padding: 15px;
          margin: 10px 0;
          cursor: pointer;
          transition: all 0.2s ease;
        }
        .template-card:hover {
          border-color: #007bff;
          background: #f8f9ff;
        }
        .template-card.selected {
          border-color: #28a745;
          background: #f8fff8;
        }
      "))
    ),
    
    # Workflow header
    div(class = "workflow-header",
        fluidRow(
          column(8,
                 h2(tagList(icon("magic"), span(class = "icon gw-icon", "✨"), t("gw_title", current_lang)), style = "margin: 0;"),
                 p(t("gw_subtitle", current_lang), style = "margin: 5px 0 0 0;")
          ),
          column(4,
                 div(class = "text-end d-flex align-items-center justify-content-end gap-2",
                     actionButton(ns("workflow_help"), tagList(icon("question-circle"), t("gw_help", current_lang)), class = "btn-light btn-sm"),
                    actionButton(ns("workflow_load_btn"), tagList(icon("folder-open"), t("gw_load_progress", current_lang)), class = "btn-light btn-sm"),
                    # Hidden file input for load functionality
                    tags$div(style = "display: none;",
                        fileInput(ns("workflow_load_file_hidden"), NULL, accept = ".rds")
                    ),
                     downloadButton(ns("workflow_download"), tagList(icon("save"), t("gw_save_progress", current_lang)), class = "btn-light btn-sm")
                 )
          )
        )
    ),
    
    # Progress tracker
    fluidRow(
      column(12,
             div(class = "progress-tracker",
                 uiOutput(ns("workflow_progress_ui"))
             )
      )
    ),
    
    # Main workflow content
    fluidRow(
      column(3,
             # Step navigation sidebar
             div(class = "card",
                 div(class = "card-header", h5(tagList(icon("list-check"), t("gw_workflow_steps", current_lang)))),
                 div(class = "card-body",
                     uiOutput(ns("workflow_steps_sidebar"))
                 )
             )
      ),
      column(9,
             # Current step content
             div(class = "card",
                 div(class = "card-header",
                     uiOutput(ns("current_step_header"))
                 ),
                 div(class = "card-body",
                     uiOutput(ns("current_step_content"))
                 ),
                 div(class = "card-footer",
                     uiOutput(ns("workflow_navigation"))
                 )
             )
      )
    )
  )
}

# Progress tracker UI
workflow_progress_ui <- function(state, current_lang = "en") {
  progress_percentage <- state$progress_percentage
  current_step <- state$current_step
  total_steps <- state$total_steps
  
  tagList(
    fluidRow(
      column(8,
             div(
               h5(paste(t("gw_step", current_lang), current_step, "of", total_steps, "•", 
                       t(WORKFLOW_CONFIG$steps[[current_step]]$title, current_lang))),
               div(class = "progress", style = "height: 20px;",
                   div(class = "progress-bar bg-success", 
                       role = "progressbar",
                       style = paste0("width: ", progress_percentage, "%"),
                       paste0(round(progress_percentage), "% Complete")
                   )
               )
             )
      ),
      column(4,
             div(class = "text-end",
                 h6(paste(t("gw_completed", current_lang), length(state$completed_steps), "/", total_steps)),
                 if (length(state$completed_steps) > 0) {
                   tags$small(paste(t("gw_estimated_time_remaining", current_lang), 
                              estimate_remaining_time(state), t("gw_minutes", current_lang)))
                 } else {
                   tags$small(t("gw_estimated_total", current_lang))
                 }
             )
      )
    )
  )
}

# Steps sidebar UI
workflow_steps_sidebar_ui <- function(state, current_lang = "en") {
  steps <- WORKFLOW_CONFIG$steps
  current_step <- state$current_step
  completed_steps <- state$completed_steps
  
  step_items <- lapply(1:length(steps), function(i) {
    step <- steps[[i]]
    status_class <- if (i %in% completed_steps) {
      "list-group-item-success"
    } else if (i == current_step) {
      "list-group-item-primary" 
    } else {
      ""
    }
    
    step_icon <- if (i %in% completed_steps) {
      icon("check-circle", class = "text-success", style = "margin-right: 8px;")
    } else if (i == current_step) {
      icon("play", class = "text-primary", style = "margin-right: 8px;")
    } else {
      icon("clock", class = "text-muted", style = "margin-right: 8px;")
    }

    div(class = paste("list-group-item", status_class),
        onclick = paste0("Shiny.setInputValue('guided_workflow-goto_step', ", i, ")"),
        style = "cursor: pointer;",
        div(
          step_icon,
          strong(t(step$title, current_lang)),
          br(),
          tags$small(t(step$description, current_lang))
        )
    )
  })
  
  div(class = "list-group", step_items)
}

# =============================================================================
# STEP CONTENT GENERATORS
# =============================================================================

# Step 1: Project Setup
generate_step1_ui <- function(session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    fluidRow(
      column(6,
             h4(tagList(span(class = "icon gw-icon", "📋"), t("gw_project_info", current_lang))),
             textInput(ns("project_name"), t("gw_project_name", current_lang), 
                      placeholder = t("gw_project_name_placeholder", current_lang)),
             textInput(ns("project_location"), t("gw_location", current_lang), 
                      placeholder = t("gw_location_placeholder", current_lang)),
             selectInput(ns("project_type"), t("gw_assessment_type", current_lang),
                        choices = if (current_lang == "fr") {
                          c("Marin" = "marine",
                            "Terrestre" = "terrestrial",
                            "Eau douce" = "freshwater",
                            "Urbain" = "urban",
                            "Climat" = "climate",
                            "Personnalisé" = "custom")
                        } else {
                          c("Marine" = "marine",
                            "Terrestrial" = "terrestrial",
                            "Freshwater" = "freshwater",
                            "Urban" = "urban",
                            "Climate" = "climate",
                            "Custom" = "custom")
                        }),
             textAreaInput(ns("project_description"), t("gw_project_description", current_lang),
                          placeholder = t("gw_project_desc_placeholder", current_lang),
                          rows = 3)
      ),
      column(6,
             h4(t("gw_template_selection", current_lang)),
             p(t("gw_template_desc", current_lang)),

             # Listbox with environmental scenarios (using centralized configuration)
             div(class = "mb-3",
                 h6(t("gw_select_template", current_lang)),
                 selectInput(ns("problem_template"), t("gw_quick_start", current_lang),
                           choices = getEnvironmentalScenarioChoices(include_blank = TRUE),
                           selected = ""
                 )
             ),
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_expert_tip", current_lang)),
                 p(t("gw_template_tip", current_lang))
             )
      )
    )
  )
}

# Step 2: Central Problem Definition  
generate_step2_ui <- function(session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-primary",
        h5(t("gw_step2_define_problem_title", current_lang)),
        p(t("gw_step2_define_problem_desc", current_lang))
    ),
    
    fluidRow(
      column(8,
             h4(t("gw_central_problem", current_lang)),
             textInput(ns("problem_statement"), t("gw_problem_statement", current_lang),
                      placeholder = t("gw_problem_statement_placeholder", current_lang)),
             
             selectInput(ns("problem_category"), t("gw_problem_category", current_lang),
                        choices = setNames(
                          c("pollution", "habitat_loss", "climate_impacts", "resource_depletion", "ecosystem_services", "other"),
                          c(t("gw_problem_category_pollution", current_lang), t("gw_problem_category_habitat", current_lang), t("gw_problem_category_climate", current_lang), t("gw_problem_category_resource", current_lang), t("gw_problem_category_ecosystem", current_lang), t("gw_problem_category_other", current_lang))
                        )),
             
             textAreaInput(ns("problem_details"), t("gw_detailed_description", current_lang),
                          placeholder = t("gw_detailed_description_placeholder", current_lang),
                          rows = 4),
             
             selectInput(ns("problem_scale"), t("gw_spatial_scale", current_lang),
                        choices = setNames(
                          c("local", "regional", "national", "international", "global"),
                          c(t("gw_scale_local", current_lang), t("gw_scale_regional", current_lang), t("gw_scale_national", current_lang), t("gw_scale_international", current_lang), t("gw_scale_global", current_lang))
                        )),
             
             selectInput(ns("problem_urgency"), t("gw_urgency_level", current_lang),
                        choices = setNames(
                          c("critical", "high", "medium", "low"),
                          c(t("gw_urgency_critical", current_lang), t("gw_urgency_high", current_lang), t("gw_urgency_medium", current_lang), t("gw_urgency_low", current_lang))
                        ))
      ),
      column(4,
             h4(t("gw_problem_examples_title", current_lang)),

             div(class = "card",
                 div(class = "card-body",
                     h6(t("gw_additional_examples", current_lang)),
                     tags$ul(
                       tags$li(t("gw_example_acidification", current_lang)),
                       tags$li(t("gw_example_bleaching", current_lang)),
                       tags$li(t("gw_example_deforestation", current_lang)),
                       tags$li(t("gw_example_biodiversity", current_lang))
                     )
                 )
             ),
             br(),
             div(class = "alert alert-warning",
                 h6(t("gw_important_title", current_lang)),
                 p(t("gw_problem_tip", current_lang))
             )
      )
    )
  )
}

# Step 3: Threats & Causes
generate_step3_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-danger",
        h5(t("gw_step3_map_threats_title", current_lang)),
        p(t("gw_step3_map_threats_desc", current_lang))
    ),
    
    fluidRow(
      column(6,
             h4(t("gw_human_activities_title", current_lang)),
             p(t("gw_human_activities_desc", current_lang)),
             
             fluidRow(
               column(8, {
                 # Prepare activity choices from vocabulary data
                 # CRITICAL FIX (Issue #1): Filter out Level 1 category headers
                 activity_choices <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities) && nrow(vocabulary_data$activities) > 0) {
                   # Only include Level 2 and above (exclude category headers)
                   if ("level" %in% names(vocabulary_data$activities)) {
                     activity_choices <- vocabulary_data$activities %>%
                       filter(level > 1) %>%
                       pull(name)
                   } else {
                     # Fallback if level column doesn't exist
                     activity_choices <- vocabulary_data$activities$name
                   }
                 }

                 selectizeInput(ns("activity_search"), t("gw_search_activities", current_lang),
                              choices = activity_choices,  # Use vocabulary choices if available
                              selected = NULL,
                              options = list(
                                placeholder = "Search or type custom activity (min 3 chars)...",
                                maxOptions = 100,
                                openOnFocus = TRUE,
                                selectOnTab = TRUE,
                                hideSelected = FALSE,
                                create = TRUE,  # HIGH PRIORITY FIX (Issue #2): Enable custom entries
                                createFilter = '^.{3,}$'  # Minimum 3 characters for custom entries
                              ))
               }),
               column(4,
                      br(),
                      actionButton(ns("add_activity"), tagList(icon("plus"), t("gw_add_activity", current_lang)),
                                 class = "btn-success btn-sm")
               )
             ),
             
             h5(t("gw_selected_activities", current_lang)),
             DTOutput(ns("selected_activities_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_examples_title", current_lang)),
                 p(t("gw_activities_examples_text", current_lang))
             )
      ),
      
      column(6,
             h4(t("gw_env_pressures_title", current_lang)),
             p(t("gw_env_pressures_desc", current_lang)),
             
             fluidRow(
               column(8, {
                 # Prepare pressure choices from vocabulary data
                 # CRITICAL FIX (Issue #1): Filter out Level 1 category headers
                 pressure_choices <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures) && nrow(vocabulary_data$pressures) > 0) {
                   # Only include Level 2 and above (exclude category headers)
                   if ("level" %in% names(vocabulary_data$pressures)) {
                     pressure_choices <- vocabulary_data$pressures %>%
                       filter(level > 1) %>%
                       pull(name)
                   } else {
                     # Fallback if level column doesn't exist
                     pressure_choices <- vocabulary_data$pressures$name
                   }
                 }

                 selectizeInput(ns("pressure_search"), t("gw_search_pressures", current_lang),
                              choices = pressure_choices,  # Use vocabulary choices if available
                              selected = NULL,
                              options = list(
                                placeholder = "Search or type custom pressure (min 3 chars)...",
                                maxOptions = 100,
                                openOnFocus = TRUE,
                                selectOnTab = TRUE,
                                hideSelected = FALSE,
                                create = TRUE,  # HIGH PRIORITY FIX (Issue #2): Enable custom entries
                                createFilter = '^.{3,}$'  # Minimum 3 characters for custom entries
                              ))
               }),
               column(4,
                      br(),
                      actionButton(ns("add_pressure"), tagList(icon("plus"), t("gw_add_pressure", current_lang)),
                                 class = "btn-warning btn-sm")
               )
             ),
             
             h5(t("gw_selected_pressures", current_lang)),
             DTOutput(ns("selected_pressures_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_examples_title", current_lang)),
                 p(t("gw_pressures_examples_text", current_lang))
             )
      )
    ),
    
    br(),
    h4(t("gw_activity_pressure_connections_title", current_lang)),
    p(t("gw_link_activities", current_lang)),

    # HIGH PRIORITY FIX (Issue #7): Manual linking interface
    div(class = "card mb-3",
      div(class = "card-body",
        h5(class = "card-title", icon("link"), " Create Manual Links"),
        p(class = "card-text", "Select an activity and pressure to create a connection:"),
        fluidRow(
          column(5,
            selectInput(ns("link_activity"), "Select Activity:",
                       choices = NULL,
                       width = "100%")
          ),
          column(5,
            selectInput(ns("link_pressure"), "Select Pressure:",
                       choices = NULL,
                       width = "100%")
          ),
          column(2,
            br(),
            actionButton(ns("create_link"), "Create Link",
                        icon = icon("plus"),
                        class = "btn-primary btn-sm w-100")
          )
        )
      )
    ),

    DTOutput(ns("activity_pressure_connections"))
  )
}

# Step 4: Preventive Controls
generate_step4_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-success",
        h5(t("gw_step4_preventive_controls_title", current_lang)),
        p(t("gw_preventive_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             h4(t("gw_search_add_preventive_controls_title", current_lang)),
             p(t("gw_search_add_preventive_controls_desc", current_lang)),
             
             fluidRow(
               column(8, {
                 # Prepare control choices from vocabulary data
                 # CRITICAL FIX (Issue #1): Filter out Level 1 category headers
                 control_choices <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
                   # Only include Level 2 and above (exclude category headers)
                   if ("level" %in% names(vocabulary_data$controls)) {
                     control_choices <- vocabulary_data$controls %>%
                       filter(level > 1) %>%
                       pull(name)
                   } else {
                     # Fallback if level column doesn't exist
                     control_choices <- vocabulary_data$controls$name
                   }
                 }

                 selectizeInput(ns("preventive_control_search"), t("gw_search_preventive_controls_label", current_lang),
                              choices = control_choices,
                              selected = NULL,
                              options = list(
                                placeholder = "Search or type custom control (min 3 chars)...",
                                maxOptions = 100,
                                openOnFocus = TRUE,
                                selectOnTab = TRUE,
                                hideSelected = FALSE,
                                create = TRUE,  # HIGH PRIORITY FIX (Issue #2): Enable custom entries
                                createFilter = '^.{3,}$'  # Minimum 3 characters for custom entries
                              ))
               }),
               column(4,
                      br(),
                      actionButton(ns("add_preventive_control"), tagList(icon("shield-alt"), t("gw_add_control", current_lang)),
                                 class = "btn-success btn-sm")
               )
             ),
             
             br(),
             h5(t("gw_selected_preventive_controls", current_lang)),
             DTOutput(ns("selected_preventive_controls_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_preventive_controls_examples_title", current_lang)),
                 tags$ul(
                   tags$li(strong(t("gw_preventive_regulatory", current_lang)), t("gw_preventive_regulatory_examples", current_lang)),
                   tags$li(strong(t("gw_preventive_technical", current_lang)), t("gw_preventive_technical_examples", current_lang)),
                   tags$li(strong(t("gw_preventive_management", current_lang)), t("gw_preventive_management_examples", current_lang)),
                   tags$li(strong(t("gw_preventive_physical", current_lang)), t("gw_preventive_physical_examples", current_lang)),
                   tags$li(strong(t("gw_preventive_operational", current_lang)), t("gw_preventive_operational_examples", current_lang))
                 )
             )
      )
    ),
    
    br(),
    h4(t("gw_link_controls_title", current_lang)),
    p(t("gw_link_controls_desc", current_lang)),
    DTOutput(ns("preventive_control_links"))
  )
}

# Step 5: Consequences
generate_step5_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-warning",
        h5(t("gw_step5_consequences_title", current_lang)),
        p(t("gw_consequences_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             h4(t("gw_search_add_consequences_title", current_lang)),
             p(t("gw_consequences_desc2", current_lang)),
             
             fluidRow(
               column(8, {
                 # Prepare consequence choices from vocabulary data
                 # CRITICAL FIX (Issue #1): Filter out Level 1 category headers
                 consequence_choices <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$consequences) && nrow(vocabulary_data$consequences) > 0) {
                   # Only include Level 2 and above (exclude category headers)
                   if ("level" %in% names(vocabulary_data$consequences)) {
                     consequence_choices <- vocabulary_data$consequences %>%
                       filter(level > 1) %>%
                       pull(name)
                   } else {
                     # Fallback if level column doesn't exist
                     consequence_choices <- vocabulary_data$consequences$name
                   }
                 }

                 selectizeInput(ns("consequence_search"), t("gw_search_consequences_label", current_lang),
                              choices = consequence_choices,
                              selected = NULL,
                              options = list(
                                placeholder = "Search or type custom consequence (min 3 chars)...",
                                maxOptions = 100,
                                openOnFocus = TRUE,
                                selectOnTab = TRUE,
                                hideSelected = FALSE,
                                create = TRUE,  # HIGH PRIORITY FIX (Issue #2): Enable custom entries
                                createFilter = '^.{3,}$'  # Minimum 3 characters for custom entries
                              ))
               }),
               column(4,
                      br(),
                      actionButton(ns("add_consequence"), tagList(icon("exclamation-triangle"), t("gw_add_consequence", current_lang)),
                                 class = "btn-warning btn-sm")
               )
             ),
             
             br(),
             h5(t("gw_selected_consequences", current_lang)),
             DTOutput(ns("selected_consequences_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_consequences_examples_title", current_lang)),
                 tags$ul(
                   tags$li(strong(t("gw_consequences_ecological", current_lang)), t("gw_consequences_ecological_examples", current_lang)),
                   tags$li(strong(t("gw_consequences_health", current_lang)), t("gw_consequences_health_examples", current_lang)),
                   tags$li(strong(t("gw_consequences_economic", current_lang)), t("gw_consequences_economic_examples", current_lang)),
                   tags$li(strong(t("gw_consequences_social", current_lang)), t("gw_consequences_social_examples", current_lang)),
                   tags$li(strong(t("gw_consequences_environmental", current_lang)), t("gw_consequences_environmental_examples", current_lang))
                 )
             )
      )
    ),
    
    br(),
    h4(t("gw_consequence_severity_title", current_lang)),
    p(t("gw_consequence_severity_desc", current_lang)),
    DTOutput(ns("consequence_severity_table"))
  )
}

# Step 6: Protective Controls
generate_step6_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-primary",
        h5("�️ Define Protective Controls"),
        p(t("gw_protective_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             h4("🔍 Search and Add Protective/Mitigation Controls"),
             p(t("gw_protective_controls_desc", current_lang)),
             
             fluidRow(
               column(8, {
                 # Prepare protective control choices from vocabulary data
                 # CRITICAL FIX (Issue #1): Filter out Level 1 category headers
                 protective_control_choices <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
                   # Only include Level 2 and above (exclude category headers)
                   if ("level" %in% names(vocabulary_data$controls)) {
                     protective_control_choices <- vocabulary_data$controls %>%
                       filter(level > 1) %>%
                       pull(name)
                   } else {
                     # Fallback if level column doesn't exist
                     protective_control_choices <- vocabulary_data$controls$name
                   }
                 }

                 selectizeInput(ns("protective_control_search"), t("gw_search_protective_controls_label", current_lang),
                              choices = protective_control_choices,
                              selected = NULL,
                              options = list(
                                placeholder = "Search or type custom protective control (min 3 chars)...",
                                maxOptions = 100,
                                openOnFocus = TRUE,
                                selectOnTab = TRUE,
                                hideSelected = FALSE,
                                create = TRUE,  # HIGH PRIORITY FIX (Issue #2): Enable custom entries
                                createFilter = '^.{3,}$'  # Minimum 3 characters for custom entries
                              ))
               }),
               column(4,
                      br(),
                      actionButton(ns("add_protective_control"), tagList(icon("medkit"), t("gw_add_control", current_lang)),
                                 class = "btn-primary btn-sm")
               )
             ),
             
             br(),
             h5(t("gw_selected_protective_controls", current_lang)),
             DTOutput(ns("selected_protective_controls_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_protective_controls_examples_title", current_lang)),
                 tags$ul(
                   tags$li(strong(t("gw_protective_emergency", current_lang)), t("gw_protective_emergency_examples", current_lang)),
                   tags$li(strong(t("gw_protective_restoration", current_lang)), t("gw_protective_restoration_examples", current_lang)),
                   tags$li(strong(t("gw_protective_compensation", current_lang)), t("gw_protective_compensation_examples", current_lang)),
                   tags$li(strong(t("gw_protective_recovery", current_lang)), t("gw_protective_recovery_examples", current_lang)),
                   tags$li(strong(t("gw_protective_adaptive", current_lang)), t("gw_protective_adaptive_examples", current_lang))
                 )
             )
      )
    ),
    
    br(),
    h4(t("gw_link_protective_controls_title", current_lang)),
    p(t("gw_link_protective_controls_desc", current_lang)),
    DTOutput(ns("protective_control_links"))
  )
}

# Step 7: Escalation Factors
generate_step7_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-danger",
        h5(t("gw_step7_escalation_factors_title", current_lang)),
        p(t("gw_step7_escalation_factors_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             div(class = "alert alert-warning",
                 h6(t("gw_what_are_escalation_factors_title", current_lang)),
                 p(t("gw_what_are_escalation_factors_desc", current_lang)),
                 p(strong(t("gw_key_concept_title", current_lang)), t("gw_key_concept_desc", current_lang))
             ),
             
             h4(t("gw_search_add_escalation_factors_title", current_lang)),
             
             fluidRow(
               column(8,
                      textInput(ns("escalation_factor_input"), t("gw_add_escalation_factor_label", current_lang),
                               placeholder = t("gw_add_escalation_factor_placeholder", current_lang))
               ),
               column(4,
                      br(),
                      actionButton(ns("add_escalation_factor"), tagList(icon("bolt"), t("gw_add_factor_button", current_lang)),
                                 class = "btn-danger btn-sm")
               )
             ),
             
             br(),
             h5(t("gw_selected_escalation_factors_title", current_lang)),
             DTOutput(ns("selected_escalation_factors_table")),
             
             br(),
             div(class = "alert alert-info",
                 h6(t("gw_escalation_factors_examples_title", current_lang)),
                 tags$ul(
                   tags$li(strong(t("gw_escalation_resource", current_lang)), t("gw_escalation_resource_examples", current_lang)),
                   tags$li(strong(t("gw_escalation_human", current_lang)), t("gw_escalation_human_examples", current_lang)),
                   tags$li(strong(t("gw_escalation_technical", current_lang)), t("gw_escalation_technical_examples", current_lang)),
                   tags$li(strong(t("gw_escalation_organizational", current_lang)), t("gw_escalation_organizational_examples", current_lang)),
                   tags$li(strong(t("gw_escalation_external", current_lang)), t("gw_escalation_external_examples", current_lang))
                 )
             )
      )
    ),
    
    br(),
    h4(t("gw_link_escalation_factors_title", current_lang)),
    p(t("gw_link_escalation_factors_desc", current_lang)),
    
    fluidRow(
      column(6,
             h5(t("gw_preventive_controls_at_risk_title", current_lang)),
             DTOutput(ns("escalation_preventive_links"))
      ),
      column(6,
             h5(t("gw_protective_controls_at_risk_title", current_lang)),
             DTOutput(ns("escalation_protective_links"))
      )
    )
  )
}

# Step 8: Review & Finalize
generate_step8_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity
  
  tagList(
    div(class = "alert alert-success",
        h5(t("gw_step8_review_finalize_title", current_lang)),
        p(t("gw_review_desc", current_lang))
    ),
    
    fluidRow(
      column(12,
             h4(t("gw_complete_bowtie_review_title", current_lang)),
             p(t("gw_verify_components", current_lang)),
             
             div(class = "card mb-3",
                 div(class = "card-header bg-primary text-white",
                     h6(t("gw_central_event", current_lang), style = "margin: 0;")
                 ),
                 div(class = "card-body",
                     uiOutput(ns("review_central_problem"))
                 )
             ),
             
             fluidRow(
               column(6,
                      div(class = "card mb-3",
                          div(class = "card-header bg-info text-white",
                              h6(t("gw_left_side_title", current_lang), style = "margin: 0;")
                          ),
                          div(class = "card-body",
                              h6(t("gw_activities_pressures", current_lang)),
                              uiOutput(ns("review_activities_pressures")),
                              hr(),
                              h6(t("gw_preventive_controls_label", current_lang)),
                              uiOutput(ns("review_preventive_controls")),
                              hr(),
                              h6(t("gw_escalation_prevention", current_lang)),
                              uiOutput(ns("review_escalation_preventive"))
                          )
                      )
               ),
               column(6,
                      div(class = "card mb-3",
                          div(class = "card-header bg-warning text-dark",
                              h6(t("gw_right_side_title", current_lang), style = "margin: 0;")
                          ),
                          div(class = "card-body",
                              h6(t("gw_consequences_label", current_lang)),
                              uiOutput(ns("review_consequences")),
                              hr(),
                              h6(t("gw_protective_controls_label", current_lang)),
                              uiOutput(ns("review_protective_controls")),
                              hr(),
                              h6(t("gw_escalation_protection", current_lang)),
                              uiOutput(ns("review_escalation_protective"))
                          )
                      )
               )
             )
      )
    ),
    
    br(),
    fluidRow(
      column(6,
             h4(t("gw_assessment_summary_title", current_lang)),
             div(class = "card",
                 div(class = "card-body",
                     uiOutput(ns("assessment_statistics"))
                 )
             )
      ),
      
      column(6,
             h4(t("gw_export_options_title", current_lang)),

             # Add Complete Workflow button first
             div(class = "mb-3",
                 actionButton(ns("complete_workflow_btn"),
                            tagList(icon("check-circle"), "Complete Workflow"),
                            class = "btn-success btn-lg w-100"),
                 tags$small(class = "text-muted", "Click this button first to finalize your bowtie analysis")
             ),

             hr(),

             div(class = "d-grid gap-2",
                 actionButton(ns("export_excel"),
                            tagList(icon("file-excel"), t("gw_export_excel", current_lang)),
                            class = "btn-outline-success"),

                 actionButton(ns("export_pdf"),
                            tagList(icon("file-pdf"), t("gw_export_pdf", current_lang)),
                            class = "btn-outline-danger"),

                 actionButton(ns("load_to_main"),
                            tagList(icon("arrow-right"), t("gw_load_main", current_lang)),
                            class = "btn-outline-primary")
             ),

             br(),
             div(class = "alert alert-info",
                 h6(icon("info-circle"), " Note"),
                 p("After completing the workflow, use the buttons above to export your analysis or load it into the main visualization tab.")
             )
      )
    )
  )
}

# =============================================================================
# SERVER FUNCTIONS
# =============================================================================

# Server logic for the guided workflow module
guided_workflow_server <- function(id, vocabulary_data, lang = reactive({"en"})) {
  moduleServer(id, function(input, output, session) {
    
    # =============================================================================
    # INITIALIZATION & REACTIVE STATE
    # =============================================================================
    
    # Initialize workflow state
    workflow_state <- reactiveVal(init_workflow_state())
  
  # Reactive value for vocabulary data
  vocab_data <- reactiveVal(vocabulary_data)
  
  # Reactive trigger for saving workflow state
  save_trigger <- reactiveVal(0)

  # Store user-defined connections
  activity_pressure_connections <- reactiveVal(data.frame(
    Activity = character(0),
    Pressure = character(0),
    stringsAsFactors = FALSE
  ))

  preventive_control_links <- reactiveVal(data.frame(
    Control = character(0),
    Target = character(0),
    Type = character(0),  # "Activity" or "Pressure"
    stringsAsFactors = FALSE
  ))

  consequence_protective_links <- reactiveVal(data.frame(
    Consequence = character(0),
    Control = character(0),
    stringsAsFactors = FALSE
  ))

  # =============================================================================
  # UI RENDERING
  # =============================================================================
  
  # Render progress tracker
  output$workflow_progress_ui <- renderUI({
    req(workflow_state())
    workflow_progress_ui(workflow_state(), lang())
  })
  
  # Render steps sidebar
  output$workflow_steps_sidebar <- renderUI({
    req(workflow_state())
    workflow_steps_sidebar_ui(workflow_state(), lang())
  })
  
  # Render current step header
  output$current_step_header <- renderUI({
    state <- workflow_state()
    req(state)
    current_lang <- lang()
    step_info <- WORKFLOW_CONFIG$steps[[state$current_step]]
    
    tagList(
      h4(t(step_info$title, current_lang)),
      tags$small(class = "text-muted", t(step_info$description, current_lang))
    )
  })
  
  # Render current step content
  output$current_step_content <- renderUI({
    state <- workflow_state()
    req(state)
    
    # Get the UI generation function for the current step
    ui_function_name <- paste0("generate_step", state$current_step, "_ui")
    
    if (exists(ui_function_name, mode = "function")) {
      ui_function <- get(ui_function_name)
      # Call with session parameter and vocabulary_data for step 3
      if (state$current_step == 3) {
        ui_function(vocabulary_data = vocabulary_data, session = session, current_lang = lang())
      } else {
        ui_function(session = session, current_lang = lang())
      }
    } else {
      div(class = "alert alert-danger", 
          paste("UI for step", state$current_step, "not found."))
    }
  })
  
  # Render navigation buttons
  output$workflow_navigation <- renderUI({
    state <- workflow_state()
    req(state)
    
    ns <- session$ns  # Get namespace function
    
    tagList(
      if (state$current_step > 1) {
        actionButton(ns("prev_step"), t("gw_previous", lang()), icon = icon("arrow-left"), class = "btn-secondary")
      },
      if (state$current_step < state$total_steps) {
        actionButton(ns("next_step"), t("gw_next", lang()), icon = icon("arrow-right"), class = "btn-primary")
      } else {
        actionButton(ns("finalize_workflow"), t("gw_step8_title", lang()), icon = icon("check-circle"), class = "btn-success")
      }
    )
  })
  
  # =============================================================================
  # EVENT HANDLING & NAVIGATION
  # =============================================================================
  
  # Update selectize choices when entering step 3
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 3) {
      
      cat("🔍 Step 3 detected - updating vocabulary choices\n")
      
      # Update activity choices
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities)) {
        activity_choices <- vocabulary_data$activities$name
        if (length(activity_choices) > 0) {
          cat("📝 Updating activity_search with", length(activity_choices), "choices\n")
          updateSelectizeInput(session, "activity_search", 
                             choices = activity_choices,
                             server = TRUE,
                             selected = character(0))
        }
      }
      
      # Update pressure choices
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures)) {
        pressure_choices <- vocabulary_data$pressures$name
        if (length(pressure_choices) > 0) {
          cat("📝 Updating pressure_search with", length(pressure_choices), "choices\n")
          updateSelectizeInput(session, "pressure_search", 
                             choices = pressure_choices,
                             server = TRUE,
                             selected = character(0))
        }
      }
    }
  })
  
  # Handle "Next" button click
  observeEvent(input$next_step, {
    state <- workflow_state()

    # Validate current step before proceeding
    validation_result <- tryCatch({
      validate_current_step(state, input, lang())
    }, error = function(e) {
      cat("❌ Validation error:", e$message, "\n")
      list(is_valid = FALSE, message = paste("Validation error:", e$message))
    })

    if (!validation_result$is_valid) {
      showNotification(validation_result$message, type = "error", duration = 5)
      return()
    }

    # Save data from current step
    state <- tryCatch({
      save_step_data(state, input)
    }, error = function(e) {
      cat("❌ Error saving step data:", e$message, "\n")
      showNotification(paste("Error saving data:", e$message), type = "error", duration = 5)
      return(state)
    })

    # Mark step as complete
    if (!state$current_step %in% state$completed_steps) {
      state$completed_steps <- c(state$completed_steps, state$current_step)
    }

    # Move to next step
    if (state$current_step < state$total_steps) {
      state$current_step <- state$current_step + 1
    }

    # Update progress
    state$progress_percentage <- (length(state$completed_steps) / state$total_steps) * 100

    workflow_state(state)
  })
  
  # Handle "Previous" button click
  observeEvent(input$prev_step, {
    state <- workflow_state()
    if (state$current_step > 1) {
      # CRITICAL FIX: Save current step data before navigating back (Issue #11 - State Preservation)
      cat("💾 Previous button: Saving step", state$current_step, "data before navigation...\n")
      state <- save_step_data(state, input)

      state$current_step <- state$current_step - 1
      workflow_state(state)

      cat("⬅️ Navigated back to step", state$current_step, "\n")
    }
  })
  
  # Handle direct step navigation from sidebar
  observeEvent(input$goto_step, {
    state <- workflow_state()
    target_step <- as.numeric(input$goto_step)

    # Allow navigation only to completed steps or current step
    if (target_step <= state$current_step || target_step - 1 %in% state$completed_steps) {
      state$current_step <- target_step
      workflow_state(state)
    } else {
      showNotification(t("gw_complete_previous", lang()), type = "warning")
    }
  })

  # =============================================================================
  # STEP 1 & 2: STATE RESTORATION
  # =============================================================================

  # Restore Step 1 fields from workflow state when navigating back
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 1) {
      # Restore project setup fields from state if available
      if (!is.null(state$project_data$project_name) && nchar(state$project_data$project_name) > 0) {
        updateTextInput(session, "project_name", value = state$project_data$project_name)
      }
      if (!is.null(state$project_data$project_location) && nchar(state$project_data$project_location) > 0) {
        updateTextInput(session, "project_location", value = state$project_data$project_location)
      }
      if (!is.null(state$project_data$project_type)) {
        updateSelectInput(session, "project_type", selected = state$project_data$project_type)
      }
      if (!is.null(state$project_data$project_description) && nchar(state$project_data$project_description) > 0) {
        updateTextAreaInput(session, "project_description", value = state$project_data$project_description)
      }
      cat("🔄 Step 1: Restored fields from workflow state\n")
    }
  })

  # Restore Step 2 fields from workflow state when navigating back
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 2) {
      # Restore central problem fields from state if available
      if (!is.null(state$project_data$problem_statement) && nchar(state$project_data$problem_statement) > 0) {
        updateTextInput(session, "problem_statement", value = state$project_data$problem_statement)
      }
      if (!is.null(state$project_data$problem_category)) {
        updateSelectInput(session, "problem_category", selected = state$project_data$problem_category)
      }
      if (!is.null(state$project_data$problem_details) && nchar(state$project_data$problem_details) > 0) {
        updateTextAreaInput(session, "problem_details", value = state$project_data$problem_details)
      }
      if (!is.null(state$project_data$problem_scale)) {
        updateSelectInput(session, "problem_scale", selected = state$project_data$problem_scale)
      }
      if (!is.null(state$project_data$problem_urgency)) {
        updateSelectInput(session, "problem_urgency", selected = state$project_data$problem_urgency)
      }
      cat("🔄 Step 2: Restored fields from workflow state\n")
    }
  })

  # =============================================================================
  # STEP 3: ACTIVITY & PRESSURE MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected activities and pressures
  selected_activities <- reactiveVal(list())
  selected_pressures <- reactiveVal(list())
  
  # Sync reactive values with workflow state when entering Step 3
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 3) {
      # Load activities from state if available
      if (!is.null(state$project_data$activities) && length(state$project_data$activities) > 0) {
        # Ensure it's a character vector
        activities <- as.character(state$project_data$activities)
        selected_activities(activities)
      } else {
        selected_activities(list())
      }
      
      # Load pressures from state if available
      if (!is.null(state$project_data$pressures) && length(state$project_data$pressures) > 0) {
        # Ensure it's a character vector
        pressures <- as.character(state$project_data$pressures)
        selected_pressures(pressures)
      } else {
        selected_pressures(list())
      }
    }
  })
  
  # Handle "Add Activity" button
  observeEvent(input$add_activity, {
    activity_name <- input$activity_search

    if (!is.null(activity_name) && nchar(trimws(activity_name)) > 0) {
      # HIGH PRIORITY FIX (Issue #2): Check if custom entry and add label
      is_custom <- FALSE
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities)) {
        # Check if activity is in vocabulary
        if (!activity_name %in% vocabulary_data$activities$name) {
          is_custom <- TRUE
          activity_name <- paste0(activity_name, " (Custom)")
          cat("✏️ Added custom activity:", activity_name, "\n")
        }
      }

      # Get current list
      current <- selected_activities()

      # Check if already added
      if (!activity_name %in% current) {
        current <- c(current, activity_name)
        selected_activities(current)

        # Update workflow state
        state <- workflow_state()
        state$project_data$activities <- current
        workflow_state(state)

        notification_msg <- if (is_custom) {
          paste("Added custom activity:", activity_name)
        } else {
          paste(t("gw_added_activity", lang()), activity_name)
        }
        showNotification(notification_msg, type = "message", duration = 2)

        # Clear the search input
        updateSelectizeInput(session, "activity_search", selected = character(0))
      } else {
        showNotification(t("gw_activity_exists", lang()), type = "warning", duration = 2)
      }
    }
  })

  # CRITICAL FIX (Issue #4): Handle "Delete Activity" button
  observeEvent(input$delete_activity, {
    activity_to_delete <- input$delete_activity

    if (!is.null(activity_to_delete) && nchar(trimws(activity_to_delete)) > 0) {
      # Get current list
      current <- selected_activities()

      # Remove the activity
      current <- current[current != activity_to_delete]
      selected_activities(current)

      # Update workflow state
      state <- workflow_state()
      state$project_data$activities <- current
      workflow_state(state)

      cat("🗑️ Deleted activity:", activity_to_delete, "\n")
      showNotification(paste("Removed:", activity_to_delete), type = "message", duration = 2)
    }
  })

  # Handle "Add Pressure" button
  observeEvent(input$add_pressure, {
    pressure_name <- input$pressure_search

    if (!is.null(pressure_name) && nchar(trimws(pressure_name)) > 0) {
      # HIGH PRIORITY FIX (Issue #2): Check if custom entry and add label
      is_custom <- FALSE
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures)) {
        # Check if pressure is in vocabulary
        if (!pressure_name %in% vocabulary_data$pressures$name) {
          is_custom <- TRUE
          pressure_name <- paste0(pressure_name, " (Custom)")
          cat("✏️ Added custom pressure:", pressure_name, "\n")
        }
      }

      # Get current list
      current <- selected_pressures()

      # Check if already added
      if (!pressure_name %in% current) {
        current <- c(current, pressure_name)
        selected_pressures(current)

        # Update workflow state
        state <- workflow_state()
        state$project_data$pressures <- current
        workflow_state(state)

        notification_msg <- if (is_custom) {
          paste("Added custom pressure:", pressure_name)
        } else {
          paste(t("gw_added_pressure", lang()), pressure_name)
        }
        showNotification(notification_msg, type = "message", duration = 2)

        # Clear the search input
        updateSelectizeInput(session, "pressure_search", selected = character(0))
      } else {
        showNotification(t("gw_pressure_exists", lang()), type = "warning", duration = 2)
      }
    }
  })

  # CRITICAL FIX (Issue #4): Handle "Delete Pressure" button
  observeEvent(input$delete_pressure, {
    pressure_to_delete <- input$delete_pressure

    if (!is.null(pressure_to_delete) && nchar(trimws(pressure_to_delete)) > 0) {
      # Get current list
      current <- selected_pressures()

      # Remove the pressure
      current <- current[current != pressure_to_delete]
      selected_pressures(current)

      # Update workflow state
      state <- workflow_state()
      state$project_data$pressures <- current
      workflow_state(state)

      cat("🗑️ Deleted pressure:", pressure_to_delete, "\n")
      showNotification(paste("Removed:", pressure_to_delete), type = "message", duration = 2)
    }
  })

  # HIGH PRIORITY FIX (Issue #7): Update manual linking dropdowns
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 3) {
      activities <- selected_activities()
      pressures <- selected_pressures()

      # Update activity dropdown
      if (length(activities) > 0) {
        updateSelectInput(session, "link_activity",
                         choices = c("", activities),
                         selected = "")
      }

      # Update pressure dropdown
      if (length(pressures) > 0) {
        updateSelectInput(session, "link_pressure",
                         choices = c("", pressures),
                         selected = "")
      }
    }
  })

  # HIGH PRIORITY FIX (Issue #7): Handle manual link creation
  observeEvent(input$create_link, {
    activity <- input$link_activity
    pressure <- input$link_pressure

    if (!is.null(activity) && !is.null(pressure) &&
        nchar(trimws(activity)) > 0 && nchar(trimws(pressure)) > 0) {

      # Get current connections
      current_connections <- activity_pressure_connections()

      # Check if link already exists
      link_exists <- FALSE
      if (nrow(current_connections) > 0) {
        link_exists <- any(current_connections$Activity == activity &
                          current_connections$Pressure == pressure)
      }

      if (!link_exists) {
        # Create new link
        new_link <- data.frame(
          Activity = activity,
          Pressure = pressure,
          stringsAsFactors = FALSE
        )

        # Add to connections
        updated_connections <- rbind(current_connections, new_link)
        activity_pressure_connections(updated_connections)

        cat("🔗 Created manual link:", activity, "→", pressure, "\n")
        showNotification(paste("Created link:", activity, "→", pressure),
                        type = "message", duration = 3)

        # Clear selections
        updateSelectInput(session, "link_activity", selected = "")
        updateSelectInput(session, "link_pressure", selected = "")
      } else {
        showNotification("This link already exists!", type = "warning", duration = 2)
      }
    } else {
      showNotification("Please select both an activity and a pressure.", type = "warning", duration = 2)
    }
  })

  # Render selected activities table
  # CRITICAL FIX (Issue #4): Added delete functionality
  output$selected_activities_table <- renderDT({
    activities <- selected_activities()

    if (length(activities) == 0) {
      # Return empty data frame with proper column names
      dt_data <- data.frame(Activity = character(0), Delete = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with activities and delete buttons
      dt_data <- data.frame(
        Activity = activities,
        Delete = sprintf(
          '<button class="btn btn-danger btn-sm delete-activity-btn" data-value="%s" onclick="Shiny.setInputValue(\'%s\', \'%s\', {priority: \'event\'})">
            <i class="fa fa-trash"></i>
          </button>',
          activities,
          session$ns("delete_activity"),
          activities
        ),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package - escape=FALSE to allow HTML buttons
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't',
        columnDefs = list(
          list(width = '80%', targets = 0),
          list(width = '20%', targets = 1, className = 'dt-center')
        )
      ),
      rownames = FALSE,
      selection = 'none',
      escape = FALSE,
      class = 'cell-border stripe'
    )
  })
  
  # Render selected pressures table
  # CRITICAL FIX (Issue #4): Added delete functionality
  output$selected_pressures_table <- renderDT({
    pressures <- selected_pressures()

    if (length(pressures) == 0) {
      # Return empty data frame with proper column names
      dt_data <- data.frame(Pressure = character(0), Delete = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with pressures and delete buttons
      dt_data <- data.frame(
        Pressure = pressures,
        Delete = sprintf(
          '<button class="btn btn-danger btn-sm delete-pressure-btn" data-value="%s" onclick="Shiny.setInputValue(\'%s\', \'%s\', {priority: \'event\'})">
            <i class="fa fa-trash"></i>
          </button>',
          pressures,
          session$ns("delete_pressure"),
          pressures
        ),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package - escape=FALSE to allow HTML buttons
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't',
        columnDefs = list(
          list(width = '80%', targets = 0),
          list(width = '20%', targets = 1, className = 'dt-center')
        )
      ),
      rownames = FALSE,
      selection = 'none',
      escape = FALSE,
      class = 'cell-border stripe'
    )
  })
  
  # Render activity-pressure connections table
  output$activity_pressure_connections <- renderDT({
    activities <- selected_activities()
    pressures <- selected_pressures()

    # Get user-defined connections
    user_connections <- activity_pressure_connections()

    # If user hasn't created any connections yet, show auto-suggested ones
    if (nrow(user_connections) == 0 && length(activities) > 0 && length(pressures) > 0) {
      # Auto-suggest connections (all combinations) with a note
      connections <- expand.grid(
        Activity = activities,
        Pressure = pressures,
        stringsAsFactors = FALSE
      )
      connections$Note <- "Auto-suggested"
    } else if (nrow(user_connections) > 0) {
      # Show user-created connections
      connections <- user_connections
      connections$Note <- "User-defined"
    } else {
      # Empty state
      connections <- data.frame(
        Activity = character(0),
        Pressure = character(0),
        Note = character(0),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package - explicitly use DT::datatable
    DT::datatable(
      connections,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'single',
      class = 'cell-border stripe'
    )
  })
  
  # =============================================================================
  # STEP 4: PREVENTIVE CONTROLS MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected preventive controls
  selected_preventive_controls <- reactiveVal(list())
  
  # Sync reactive values with workflow state when entering Step 4
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 4) {
      # Update control search choices
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls)) {
        control_choices <- vocabulary_data$controls$name
        if (length(control_choices) > 0) {
          cat("📝 Updating preventive_control_search with", length(control_choices), "choices\n")
          updateSelectizeInput(session, "preventive_control_search", 
                             choices = control_choices,
                             server = TRUE,
                             selected = character(0))
        }
      }
      
      # Load controls from state if available
      if (!is.null(state$project_data$preventive_controls) && length(state$project_data$preventive_controls) > 0) {
        controls <- as.character(state$project_data$preventive_controls)
        selected_preventive_controls(controls)
      } else {
        selected_preventive_controls(list())
      }
    }
  })
  
  # Handle "Add Control" button
  observeEvent(input$add_preventive_control, {
    control_name <- input$preventive_control_search

    if (!is.null(control_name) && nchar(trimws(control_name)) > 0) {
      # HIGH PRIORITY FIX (Issue #2): Check if custom entry and add label
      is_custom <- FALSE
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls)) {
        # Check if control is in vocabulary
        if (!control_name %in% vocabulary_data$controls$name) {
          is_custom <- TRUE
          control_name <- paste0(control_name, " (Custom)")
          cat("✏️ Added custom preventive control:", control_name, "\n")
        }
      }

      # Get current list
      current <- selected_preventive_controls()

      # Check if already added
      if (!control_name %in% current) {
        current <- c(current, control_name)
        selected_preventive_controls(current)

        # Update workflow state
        state <- workflow_state()
        state$project_data$preventive_controls <- current
        workflow_state(state)

        notification_msg <- if (is_custom) {
          paste("Added custom preventive control:", control_name)
        } else {
          paste(t("gw_added_control", lang()), control_name)
        }
        showNotification(notification_msg, type = "message", duration = 2)

        # Clear the search input
        updateSelectizeInput(session, "preventive_control_search", selected = character(0))
      } else {
        showNotification(t("gw_control_exists", lang()), type = "warning", duration = 2)
      }
    }
  })

  # CRITICAL FIX (Issue #4): Handle "Delete Preventive Control" button
  observeEvent(input$delete_preventive_control, {
    control_to_delete <- input$delete_preventive_control

    if (!is.null(control_to_delete) && nchar(trimws(control_to_delete)) > 0) {
      # Get current list
      current <- selected_preventive_controls()

      # Remove the control
      current <- current[current != control_to_delete]
      selected_preventive_controls(current)

      # Update workflow state
      state <- workflow_state()
      state$project_data$preventive_controls <- current
      workflow_state(state)

      cat("🗑️ Deleted preventive control:", control_to_delete, "\n")
      showNotification(paste("Removed:", control_to_delete), type = "message", duration = 2)
    }
  })

  # Render selected preventive controls table
  # CRITICAL FIX (Issue #4): Added delete functionality
  output$selected_preventive_controls_table <- renderDT({
    controls <- selected_preventive_controls()

    if (length(controls) == 0) {
      # Return empty data frame with proper column names
      dt_data <- data.frame(Control = character(0), Delete = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with controls and delete buttons
      dt_data <- data.frame(
        Control = controls,
        Delete = sprintf(
          '<button class="btn btn-danger btn-sm delete-preventive-control-btn" data-value="%s" onclick="Shiny.setInputValue(\'%s\', \'%s\', {priority: \'event\'})">
            <i class="fa fa-trash"></i>
          </button>',
          controls,
          session$ns("delete_preventive_control"),
          controls
        ),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package - escape=FALSE to allow HTML buttons
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't',
        columnDefs = list(
          list(width = '80%', targets = 0),
          list(width = '20%', targets = 1, className = 'dt-center')
        )
      ),
      rownames = FALSE,
      selection = 'none',
      escape = FALSE,
      class = 'cell-border stripe'
    )
  })

  # Render preventive control links table
  output$preventive_control_links <- renderDT({
    controls <- selected_preventive_controls()
    activities <- selected_activities()
    pressures <- selected_pressures()

    # Get user-defined preventive control links
    user_links <- preventive_control_links()

    # If no user-defined links, show auto-suggested ones
    if (nrow(user_links) == 0 && length(controls) > 0) {
      # Create auto-suggested links
      targets <- c(
        if (length(activities) > 0) paste("Activity:", activities) else character(0),
        if (length(pressures) > 0) paste("Pressure:", pressures) else character(0)
      )

      if (length(targets) > 0) {
        # Suggest all combinations with a note
        auto_links <- expand.grid(
          Control = controls,
          Addresses = targets,
          stringsAsFactors = FALSE
        )
        auto_links$Note <- "Auto-suggested"
        display_data <- auto_links
      } else {
        display_data <- data.frame(
          Control = controls,
          Addresses = "No activities/pressures defined",
          Note = "Waiting for data",
          stringsAsFactors = FALSE
        )
      }
    } else if (nrow(user_links) > 0) {
      # Format user-defined links
      display_data <- data.frame(
        Control = user_links$Control,
        Addresses = paste0(user_links$Type, ": ", user_links$Target),
        Note = "User-defined",
        stringsAsFactors = FALSE
      )
    } else {
      # Empty state
      display_data <- data.frame(
        Control = character(0),
        Addresses = character(0),
        Note = character(0),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package
    DT::datatable(
      display_data,
      options = list(
        pageLength = 15,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'single',
      class = 'cell-border stripe'
    )
  })
  
  # =============================================================================
  # STEP 5: CONSEQUENCES MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected consequences
  selected_consequences <- reactiveVal(list())
  
  # Sync reactive values with workflow state when entering Step 5
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 5) {
      # Update consequence search choices
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$consequences)) {
        consequence_choices <- vocabulary_data$consequences$name
        if (length(consequence_choices) > 0) {
          cat("📝 Updating consequence_search with", length(consequence_choices), "choices\n")
          updateSelectizeInput(session, "consequence_search", 
                             choices = consequence_choices,
                             server = TRUE,
                             selected = character(0))
        }
      }
      
      # Load consequences from state if available
      if (!is.null(state$project_data$consequences) && length(state$project_data$consequences) > 0) {
        consequences <- as.character(state$project_data$consequences)
        selected_consequences(consequences)
      } else {
        selected_consequences(list())
      }
    }
  })
  
  # Handle "Add Consequence" button
  observeEvent(input$add_consequence, {
    consequence_name <- input$consequence_search

    if (!is.null(consequence_name) && nchar(trimws(consequence_name)) > 0) {
      # HIGH PRIORITY FIX (Issue #2): Check if custom entry and add label
      is_custom <- FALSE
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$consequences)) {
        # Check if consequence is in vocabulary
        if (!consequence_name %in% vocabulary_data$consequences$name) {
          is_custom <- TRUE
          consequence_name <- paste0(consequence_name, " (Custom)")
          cat("✏️ Added custom consequence:", consequence_name, "\n")
        }
      }

      # Get current list
      current <- selected_consequences()

      # Check if already added
      if (!consequence_name %in% current) {
        current <- c(current, consequence_name)
        selected_consequences(current)

        # Update workflow state
        state <- workflow_state()
        state$project_data$consequences <- current
        workflow_state(state)

        notification_msg <- if (is_custom) {
          paste("Added custom consequence:", consequence_name)
        } else {
          paste(t("gw_added_consequence", lang()), consequence_name)
        }
        showNotification(notification_msg, type = "message", duration = 2)

        # Clear the search input
        updateSelectizeInput(session, "consequence_search", selected = character(0))
      } else {
        showNotification(t("gw_consequence_exists", lang()), type = "warning", duration = 2)
      }
    }
  })

  # CRITICAL FIX (Issue #4): Handle "Delete Consequence" button
  observeEvent(input$delete_consequence, {
    consequence_to_delete <- input$delete_consequence

    if (!is.null(consequence_to_delete) && nchar(trimws(consequence_to_delete)) > 0) {
      # Get current list
      current <- selected_consequences()

      # Remove the consequence
      current <- current[current != consequence_to_delete]
      selected_consequences(current)

      # Update workflow state
      state <- workflow_state()
      state$project_data$consequences <- current
      workflow_state(state)

      cat("🗑️ Deleted consequence:", consequence_to_delete, "\n")
      showNotification(paste("Removed:", consequence_to_delete), type = "message", duration = 2)
    }
  })

  # Render selected consequences table
  # CRITICAL FIX (Issue #4): Added delete functionality
  output$selected_consequences_table <- renderDT({
    consequences <- selected_consequences()

    if (length(consequences) == 0) {
      # Return empty data frame with proper column names
      dt_data <- data.frame(Consequence = character(0), Delete = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with consequences and delete buttons
      dt_data <- data.frame(
        Consequence = consequences,
        Delete = sprintf(
          '<button class="btn btn-danger btn-sm delete-consequence-btn" data-value="%s" onclick="Shiny.setInputValue(\'%s\', \'%s\', {priority: \'event\'})">
            <i class="fa fa-trash"></i>
          </button>',
          consequences,
          session$ns("delete_consequence"),
          consequences
        ),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package - escape=FALSE to allow HTML buttons
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't',
        columnDefs = list(
          list(width = '80%', targets = 0),
          list(width = '20%', targets = 1, className = 'dt-center')
        )
      ),
      rownames = FALSE,
      selection = 'none',
      escape = FALSE,
      class = 'cell-border stripe'
    )
  })
  
  # Render consequence severity assessment table
  output$consequence_severity_table <- renderDT({
    consequences <- selected_consequences()
    
    if (length(consequences) == 0) {
      # Return empty data frame
      dt_data <- data.frame(
        Consequence = character(0),
        Severity = character(0),
        stringsAsFactors = FALSE
      )
    } else {
      # Create a table for severity assessment
      dt_data <- data.frame(
        Consequence = consequences,
        Severity = rep("Medium (to be assessed)", length(consequences)),
        stringsAsFactors = FALSE
      )
    }
    
    # Render with DT package
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })
  
  # =============================================================================
  # STEP 6: PROTECTIVE CONTROLS MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected protective controls
  selected_protective_controls <- reactiveVal(list())
  
  # Sync reactive values with workflow state when entering Step 6
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 6) {
      # Update protective control search choices
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls)) {
        protective_control_choices <- vocabulary_data$controls$name
        if (length(protective_control_choices) > 0) {
          cat("📝 Updating protective_control_search with", length(protective_control_choices), "choices\n")
          updateSelectizeInput(session, "protective_control_search", 
                             choices = protective_control_choices,
                             server = TRUE,
                             selected = character(0))
        }
      }
      
      # Load protective controls from state if available
      if (!is.null(state$project_data$protective_controls) && length(state$project_data$protective_controls) > 0) {
        controls <- as.character(state$project_data$protective_controls)
        selected_protective_controls(controls)
      } else {
        selected_protective_controls(list())
      }
    }
  })
  
  # Handle "Add Protective Control" button
  observeEvent(input$add_protective_control, {
    control_name <- input$protective_control_search

    if (!is.null(control_name) && nchar(trimws(control_name)) > 0) {
      # HIGH PRIORITY FIX (Issue #2): Check if custom entry and add label
      is_custom <- FALSE
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls)) {
        # Check if control is in vocabulary
        if (!control_name %in% vocabulary_data$controls$name) {
          is_custom <- TRUE
          control_name <- paste0(control_name, " (Custom)")
          cat("✏️ Added custom protective control:", control_name, "\n")
        }
      }

      # Get current list
      current <- selected_protective_controls()

      # Check if already added
      if (!control_name %in% current) {
        current <- c(current, control_name)
        selected_protective_controls(current)

        # Update workflow state
        state <- workflow_state()
        state$project_data$protective_controls <- current
        workflow_state(state)

        notification_msg <- if (is_custom) {
          paste("Added custom protective control:", control_name)
        } else {
          paste(t("gw_added_protective", lang()), control_name)
        }
        showNotification(notification_msg, type = "message", duration = 2)

        # Clear the search input
        updateSelectizeInput(session, "protective_control_search", selected = character(0))
      } else {
        showNotification(t("gw_control_exists", lang()), type = "warning", duration = 2)
      }
    }
  })

  # CRITICAL FIX (Issue #4): Handle "Delete Protective Control" button
  observeEvent(input$delete_protective_control, {
    control_to_delete <- input$delete_protective_control

    if (!is.null(control_to_delete) && nchar(trimws(control_to_delete)) > 0) {
      # Get current list
      current <- selected_protective_controls()

      # Remove the control
      current <- current[current != control_to_delete]
      selected_protective_controls(current)

      # Update workflow state
      state <- workflow_state()
      state$project_data$protective_controls <- current
      workflow_state(state)

      cat("🗑️ Deleted protective control:", control_to_delete, "\n")
      showNotification(paste("Removed:", control_to_delete), type = "message", duration = 2)
    }
  })

  # Render selected protective controls table
  # CRITICAL FIX (Issue #4): Added delete functionality
  output$selected_protective_controls_table <- renderDT({
    controls <- selected_protective_controls()

    if (length(controls) == 0) {
      # Return empty data frame with proper column names
      dt_data <- data.frame(Control = character(0), Delete = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with controls and delete buttons
      dt_data <- data.frame(
        Control = controls,
        Delete = sprintf(
          '<button class="btn btn-danger btn-sm delete-protective-control-btn" data-value="%s" onclick="Shiny.setInputValue(\'%s\', \'%s\', {priority: \'event\'})">
            <i class="fa fa-trash"></i>
          </button>',
          controls,
          session$ns("delete_protective_control"),
          controls
        ),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package - escape=FALSE to allow HTML buttons
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't',
        columnDefs = list(
          list(width = '80%', targets = 0),
          list(width = '20%', targets = 1, className = 'dt-center')
        )
      ),
      rownames = FALSE,
      selection = 'none',
      escape = FALSE,
      class = 'cell-border stripe'
    )
  })

  # Render protective control links table
  output$protective_control_links <- renderDT({
    consequences <- selected_consequences()
    protective_controls <- selected_protective_controls()

    # Get user-defined consequence-protective control links
    user_links <- consequence_protective_links()

    # If no user-defined links, show auto-suggested ones
    if (nrow(user_links) == 0 && length(protective_controls) > 0 && length(consequences) > 0) {
      # Auto-suggest all combinations
      auto_links <- expand.grid(
        Control = protective_controls,
        Mitigates = consequences,
        stringsAsFactors = FALSE
      )
      auto_links$Note <- "Auto-suggested"
      display_data <- auto_links
    } else if (nrow(user_links) > 0) {
      # Show user-defined links
      display_data <- data.frame(
        Control = user_links$Control,
        Mitigates = user_links$Consequence,
        Note = "User-defined",
        stringsAsFactors = FALSE
      )
    } else {
      # Empty state
      display_data <- data.frame(
        Control = character(0),
        Mitigates = character(0),
        Note = character(0),
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package
    DT::datatable(
      display_data,
      options = list(
        pageLength = 15,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'single',
      class = 'cell-border stripe'
    )
  })
  
  # =============================================================================
  # STEP 7: ESCALATION FACTORS MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected escalation factors
  selected_escalation_factors <- reactiveVal(list())
  
  # Sync reactive values with workflow state when entering Step 7
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 7) {
      # Load escalation factors from state if available
      if (!is.null(state$project_data$escalation_factors) && length(state$project_data$escalation_factors) > 0) {
        factors <- as.character(state$project_data$escalation_factors)
        selected_escalation_factors(factors)
      } else {
        selected_escalation_factors(list())
      }
    }
  })
  
  # Handle "Add Escalation Factor" button
  observeEvent(input$add_escalation_factor, {
    factor_name <- input$escalation_factor_input
    
    if (!is.null(factor_name) && nchar(trimws(factor_name)) > 0) {
      # Get current list
      current <- selected_escalation_factors()
      
      # Check if already added
      if (!factor_name %in% current) {
        current <- c(current, factor_name)
        selected_escalation_factors(current)
        
        # Update workflow state
        state <- workflow_state()
        state$project_data$escalation_factors <- current
        workflow_state(state)
        
        showNotification(paste(t("gw_added_escalation", lang()), factor_name), type = "message", duration = 2)

        # Clear the input
        updateTextInput(session, "escalation_factor_input", value = "")
      } else {
        showNotification(t("gw_escalation_exists", lang()), type = "warning", duration = 2)
      }
    }
  })

  # CRITICAL FIX (Issue #4): Handle "Delete Escalation Factor" button
  observeEvent(input$delete_escalation_factor, {
    factor_to_delete <- input$delete_escalation_factor

    if (!is.null(factor_to_delete) && nchar(trimws(factor_to_delete)) > 0) {
      # Get current list
      current <- selected_escalation_factors()

      # Remove the factor
      current <- current[current != factor_to_delete]
      selected_escalation_factors(current)

      # Update workflow state
      state <- workflow_state()
      state$project_data$escalation_factors <- current
      workflow_state(state)

      cat("🗑️ Deleted escalation factor:", factor_to_delete, "\n")
      showNotification(paste("Removed:", factor_to_delete), type = "message", duration = 2)
    }
  })

  # Render selected escalation factors table
  # CRITICAL FIX (Issue #4): Added delete functionality
  output$selected_escalation_factors_table <- renderDT({
    factors <- selected_escalation_factors()

    if (length(factors) == 0) {
      # Return empty data frame with proper column names
      dt_data <- data.frame(`Escalation Factor` = character(0), Delete = character(0), stringsAsFactors = FALSE, check.names = FALSE)
    } else {
      # Create data frame with factors and delete buttons
      dt_data <- data.frame(
        `Escalation Factor` = factors,
        Delete = sprintf(
          '<button class="btn btn-danger btn-sm delete-escalation-factor-btn" data-value="%s" onclick="Shiny.setInputValue(\'%s\', \'%s\', {priority: \'event\'})">
            <i class="fa fa-trash"></i>
          </button>',
          factors,
          session$ns("delete_escalation_factor"),
          factors
        ),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    }

    # Render with DT package - escape=FALSE to allow HTML buttons
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't',
        columnDefs = list(
          list(width = '80%', targets = 0),
          list(width = '20%', targets = 1, className = 'dt-center')
        )
      ),
      rownames = FALSE,
      selection = 'none',
      escape = FALSE,
      class = 'cell-border stripe'
    )
  })
  
  # Render escalation factors affecting preventive controls
  output$escalation_preventive_links <- renderDT({
    factors <- selected_escalation_factors()
    preventive_controls <- selected_preventive_controls()
    
    if (length(factors) == 0) {
      # Return empty data frame
      dt_data <- data.frame(
        `Escalation Factor` = character(0),
        `Affects Control` = character(0),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    } else {
      # Create a table showing which preventive controls are affected
      if (length(preventive_controls) > 0) {
        # Create combinations for user to review
        links <- expand.grid(
          `Escalation Factor` = factors,
          `Affects Control` = preventive_controls,
          stringsAsFactors = FALSE
        )
        names(links) <- c(t("gw_col_escalation", lang()), "Affects Control")
        dt_data <- links
      } else {
        dt_data <- data.frame(
          `Escalation Factor` = factors,
          `Affects Control` = "No preventive controls defined yet",
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
      }
    }
    
    # Render with DT package
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })
  
  # Render escalation factors affecting protective controls
  output$escalation_protective_links <- renderDT({
    factors <- selected_escalation_factors()
    protective_controls <- selected_protective_controls()
    
    if (length(factors) == 0) {
      # Return empty data frame
      dt_data <- data.frame(
        `Escalation Factor` = character(0),
        `Affects Control` = character(0),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    } else {
      # Create a table showing which protective controls are affected
      if (length(protective_controls) > 0) {
        # Create combinations for user to review
        links <- expand.grid(
          `Escalation Factor` = factors,
          `Affects Control` = protective_controls,
          stringsAsFactors = FALSE
        )
        names(links) <- c(t("gw_col_escalation", lang()), "Affects Control")
        dt_data <- links
      } else {
        dt_data <- data.frame(
          `Escalation Factor` = factors,
          `Affects Control` = "No protective controls defined yet",
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
      }
    }
    
    # Render with DT package
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 'tp'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })

  # =============================================================================
  # CONNECTION OBSERVERS - Handle user-defined connection creation
  # =============================================================================

  # Observer for adding activity-pressure connections
  observeEvent(input$add_connection, {
    req(input$connection_activity, input$connection_pressure)

    current_connections <- activity_pressure_connections()
    new_connection <- data.frame(
      Activity = input$connection_activity,
      Pressure = input$connection_pressure,
      stringsAsFactors = FALSE
    )

    # Check for duplicates
    is_duplicate <- nrow(current_connections) > 0 && any(
      current_connections$Activity == new_connection$Activity &
      current_connections$Pressure == new_connection$Pressure
    )

    if (!is_duplicate) {
      updated_connections <- rbind(current_connections, new_connection)
      activity_pressure_connections(updated_connections)

      showNotification(
        "Connection added successfully!",
        type = "message",
        duration = 2
      )

      # Reset selections
      updateSelectizeInput(session, "connection_activity", selected = character(0))
      updateSelectizeInput(session, "connection_pressure", selected = character(0))
    } else {
      showNotification(
        "This connection already exists!",
        type = "warning",
        duration = 2
      )
    }
  })

  # Observer for adding preventive control links
  observeEvent(input$add_control_link, {
    req(input$link_control, input$link_target)

    current_links <- preventive_control_links()

    # Determine if target is activity or pressure
    target_type <- if(grepl("^Activity:", input$link_target)) "Activity" else "Pressure"
    target_name <- gsub("^(Activity|Pressure): ", "", input$link_target)

    new_link <- data.frame(
      Control = input$link_control,
      Target = target_name,
      Type = target_type,
      stringsAsFactors = FALSE
    )

    # Check for duplicates
    is_duplicate <- nrow(current_links) > 0 && any(
      current_links$Control == new_link$Control &
      current_links$Target == new_link$Target
    )

    if (!is_duplicate) {
      updated_links <- rbind(current_links, new_link)
      preventive_control_links(updated_links)

      showNotification(
        "Control link added successfully!",
        type = "message",
        duration = 2
      )

      # Reset selections
      updateSelectizeInput(session, "link_control", selected = character(0))
      updateSelectizeInput(session, "link_target", selected = character(0))
    } else {
      showNotification(
        "This link already exists!",
        type = "warning",
        duration = 2
      )
    }
  })

  # Observer for adding consequence-protective control connections
  observeEvent(input$add_protective_link, {
    req(input$link_consequence, input$link_protective_control)

    current_links <- consequence_protective_links()
    new_link <- data.frame(
      Consequence = input$link_consequence,
      Control = input$link_protective_control,
      stringsAsFactors = FALSE
    )

    # Check for duplicates
    is_duplicate <- nrow(current_links) > 0 && any(
      current_links$Consequence == new_link$Consequence &
      current_links$Control == new_link$Control
    )

    if (!is_duplicate) {
      updated_links <- rbind(current_links, new_link)
      consequence_protective_links(updated_links)

      showNotification(
        "Protective control link added successfully!",
        type = "message",
        duration = 2
      )

      # Reset selections
      updateSelectizeInput(session, "link_consequence", selected = character(0))
      updateSelectizeInput(session, "link_protective_control", selected = character(0))
    } else {
      showNotification(
        "This link already exists!",
        type = "warning",
        duration = 2
      )
    }
  })

  # =============================================================================
  # DYNAMIC CHOICE UPDATES - Update selectizeInput choices based on selections
  # =============================================================================

  # Update connection activity choices (Step 3)
  observe({
    activities <- selected_activities()
    if (length(activities) > 0) {
      updateSelectizeInput(session, "connection_activity", choices = activities)
    }
  })

  # Update connection pressure choices (Step 3)
  observe({
    pressures <- selected_pressures()
    if (length(pressures) > 0) {
      updateSelectizeInput(session, "connection_pressure", choices = pressures)
    }
  })

  # Update control link choices (Step 4)
  observe({
    controls <- selected_preventive_controls()
    if (length(controls) > 0) {
      updateSelectizeInput(session, "link_control", choices = controls)
    }

    # Update targets (activities + pressures)
    activities <- selected_activities()
    pressures <- selected_pressures()
    targets <- c()

    if (length(activities) > 0) {
      targets <- c(targets, setNames(paste0("Activity: ", activities), paste0("Activity: ", activities)))
    }
    if (length(pressures) > 0) {
      targets <- c(targets, setNames(paste0("Pressure: ", pressures), paste0("Pressure: ", pressures)))
    }

    if (length(targets) > 0) {
      updateSelectizeInput(session, "link_target", choices = targets)
    }
  })

  # Update consequence-protective control choices (Step 6)
  observe({
    consequences <- selected_consequences()
    if (length(consequences) > 0) {
      updateSelectizeInput(session, "link_consequence", choices = consequences)
    }

    protective_controls <- selected_protective_controls()
    if (length(protective_controls) > 0) {
      updateSelectizeInput(session, "link_protective_control", choices = protective_controls)
    }
  })

  # =============================================================================
  # STEP 8: REVIEW & SUMMARY
  # =============================================================================
  
  # Render review outputs for Step 8
  output$review_central_problem <- renderUI({
    state <- workflow_state()
    problem <- state$project_data$problem_statement %||% t("gw_not_defined", lang())
    tags$p(strong(problem))
  })
  
  output$review_activities_pressures <- renderUI({
    state <- workflow_state()
    activities <- state$project_data$activities %||% list()
    pressures <- state$project_data$pressures %||% list()

    tagList(
      if (length(activities) > 0) {
        tags$div(
          tags$strong("Activities: "), tags$span(paste(length(activities), t("gw_items", lang()))),
          tags$ul(lapply(activities, function(x) tags$li(x)))
        )
      } else {
        tags$p(em(t("gw_no_activities", lang())))
      },
      if (length(pressures) > 0) {
        tags$div(
          tags$strong("Pressures: "), tags$span(paste(length(pressures), t("gw_items", lang()))),
          tags$ul(lapply(pressures, function(x) tags$li(x)))
        )
      } else {
        tags$p(em(t("gw_no_pressures", lang())))
      }
    )
  })
  
  output$review_preventive_controls <- renderUI({
    state <- workflow_state()
    controls <- state$project_data$preventive_controls %||% list()

    if (length(controls) > 0) {
      tags$div(
        tags$span(paste(length(controls), t("gw_controls", lang()))),
        tags$ul(lapply(controls, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_preventive_controls", lang())))
    }
  })
  
  output$review_consequences <- renderUI({
    state <- workflow_state()
    consequences <- state$project_data$consequences %||% list()

    if (length(consequences) > 0) {
      tags$div(
        tags$span(paste(length(consequences), "consequences")),
        tags$ul(lapply(consequences, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_consequences", lang())))
    }
  })
  
  output$review_protective_controls <- renderUI({
    state <- workflow_state()
    controls <- state$project_data$protective_controls %||% list()

    if (length(controls) > 0) {
      tags$div(
        tags$span(paste(length(controls), t("gw_controls", lang()))),
        tags$ul(lapply(controls, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_protective_controls", lang())))
    }
  })
  
  output$review_escalation_preventive <- renderUI({
    state <- workflow_state()
    factors <- state$project_data$escalation_factors %||% list()

    if (length(factors) > 0) {
      tags$div(
        tags$span(paste(length(factors), t("gw_factors", lang()))),
        tags$ul(lapply(factors, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_escalation", lang())))
    }
  })
  
  output$review_escalation_protective <- renderUI({
    state <- workflow_state()
    factors <- state$project_data$escalation_factors %||% list()

    if (length(factors) > 0) {
      tags$div(
        tags$span(paste(length(factors), "factors (same as preventive side)")),
        tags$ul(lapply(factors, function(x) tags$li(x)))
      )
    } else {
      tags$p(em(t("gw_no_escalation", lang())))
    }
  })
  
  output$assessment_statistics <- renderUI({
    state <- workflow_state()

    activities_count <- length(state$project_data$activities %||% list())
    pressures_count <- length(state$project_data$pressures %||% list())
    preventive_count <- length(state$project_data$preventive_controls %||% list())
    consequences_count <- length(state$project_data$consequences %||% list())
    protective_count <- length(state$project_data$protective_controls %||% list())
    escalation_count <- length(state$project_data$escalation_factors %||% list())

    tags$div(
      tags$h6("Component Summary:"),
      tags$ul(
        tags$li(paste("Activities:", activities_count)),
        tags$li(paste("Pressures:", pressures_count)),
        tags$li(paste(t("gw_preventive_controls_label", lang()), preventive_count)),
        tags$li(paste(t("gw_consequences_label", lang()), consequences_count)),
        tags$li(paste(t("gw_protective_controls_label", lang()), protective_count)),
        tags$li(paste("Escalation Factors:", escalation_count))
      ),
      tags$hr(),
      tags$p(strong(t("gw_total_components", lang())),
             activities_count + pressures_count + preventive_count +
             consequences_count + protective_count + escalation_count)
    )
  })
  
  # =============================================================================
  # TEMPLATE & DATA HANDLING
  # =============================================================================
  
  # Apply template data when selected
  observeEvent(input$problem_template, {
    req(input$problem_template)
    template_id <- input$problem_template

    cat("🎯 Template selected:", template_id, "\n")

    if (template_id != "") {
      template_data <- WORKFLOW_CONFIG$templates[[template_id]]

      if (!is.null(template_data)) {
        cat("✅ Template found:", template_data$name, "\n")

        tryCatch({
          # Update Step 1 (Project Setup) fields
          cat("📝 Updating Step 1 fields...\n")
          updateTextInput(session, "project_name", value = template_data$project_name)
          updateTextInput(session, "project_location", value = template_data$project_location)
          updateSelectInput(session, "project_type", selected = template_data$project_type)
          updateTextAreaInput(session, "project_description", value = template_data$project_description)

          # Update Step 2 (Central Problem Definition) fields
          cat("📝 Updating Step 2 fields...\n")
          updateTextInput(session, "problem_statement", value = template_data$central_problem)
          if (!is.null(template_data$problem_category)) {
            updateSelectInput(session, "problem_category", selected = template_data$problem_category)
          }
          if (!is.null(template_data$problem_details)) {
            updateTextAreaInput(session, "problem_details", value = template_data$problem_details)
          }
          if (!is.null(template_data$problem_scale)) {
            updateSelectInput(session, "problem_scale", selected = template_data$problem_scale)
          }
          if (!is.null(template_data$problem_urgency)) {
            updateSelectInput(session, "problem_urgency", selected = template_data$problem_urgency)
          }

          # Store template info in state
          cat("💾 Saving template data to workflow state...\n")
          state <- workflow_state()
          state$project_data$template_applied <- template_id
          state$project_data$project_name <- template_data$project_name
          state$project_data$project_location <- template_data$project_location
          state$project_data$project_type <- template_data$project_type
          state$project_data$project_description <- template_data$project_description
          state$project_data$problem_statement <- template_data$central_problem
          state$project_data$problem_category <- template_data$problem_category
          state$project_data$problem_details <- template_data$problem_details
          state$project_data$problem_scale <- template_data$problem_scale
          state$project_data$problem_urgency <- template_data$problem_urgency
          state$project_data$example_activities <- template_data$example_activities
          state$project_data$example_pressures <- template_data$example_pressures
          workflow_state(state)

          cat("✅ Template applied successfully!\n")

          showNotification(
            paste0("✅ Applied template: ", template_data$name,
                   " - Project Setup (Step 1) and Central Problem (Step 2) have been pre-filled!"),
            type = "message",
            duration = 5
          )
        }, error = function(e) {
          cat("❌ Error applying template:", e$message, "\n")
          showNotification(
            paste("Error applying template:", e$message),
            type = "error",
            duration = 5
          )
        })
      } else {
        cat("❌ Template not found for ID:", template_id, "\n")
        showNotification(
          paste("Template not found for:", template_id),
          type = "warning",
          duration = 5
        )
      }
    } else {
      cat("ℹ️ Blank template selected - using custom mode\n")
    }
  })
  
  # =============================================================================
  # FINALIZATION & EXPORT
  # =============================================================================

  # Helper function to complete workflow (shared logic)
  complete_workflow <- function() {
    state <- workflow_state()

    # Check if already complete
    if (isTRUE(state$workflow_complete)) {
      showNotification("Workflow is already completed.", type = "message", duration = 3)
      return(state)
    }

    cat("🎯 Completing workflow...\n")

    # Save final step data if on step 8
    if (state$current_step == 8) {
      state <- tryCatch({
        save_step_data(state, input)
      }, error = function(e) {
        cat("❌ Error saving final step data:", e$message, "\n")
        return(state)
      })
    }

    # Mark workflow as complete
    state$workflow_complete <- TRUE

    # Convert workflow data to main application format
    converted_data <- tryCatch({
      convert_to_main_data_format(state$project_data)
    }, error = function(e) {
      cat("❌ Error converting data:", e$message, "\n")
      showNotification(paste("Error converting data:", e$message), type = "error", duration = 5)
      return(NULL)
    })

    if (!is.null(converted_data)) {
      state$converted_main_data <- converted_data
      workflow_state(state)
      cat("✅ Workflow completed successfully!\n")
      showNotification("🎉 Workflow complete! You can now export your analysis or load it to the main application.", type = "message", duration = 5)
      return(state)
    } else {
      state$workflow_complete <- FALSE
      workflow_state(state)
      return(state)
    }
  }

  # Handle "Complete Workflow" button in Step 8
  observeEvent(input$complete_workflow_btn, {
    complete_workflow()
  })

  # Handle workflow finalization from navigation button
  observeEvent(input$finalize_workflow, {
    state <- workflow_state()

    # Final validation
    validation_result <- tryCatch({
      validate_current_step(state, input, lang())
    }, error = function(e) {
      cat("❌ Final validation error:", e$message, "\n")
      list(is_valid = FALSE, message = paste("Validation error:", e$message))
    })

    if (!validation_result$is_valid) {
      showNotification(validation_result$message, type = "error")
      return()
    }

    # Complete the workflow
    complete_workflow()
  })

  # =============================================================================
  # EXPORT HANDLERS FOR STEP 8
  # =============================================================================

  # Handler for Export to Excel
  observeEvent(input$export_excel, {
    state <- workflow_state()

    # Check if workflow is complete, if not complete it now
    if (!isTRUE(state$workflow_complete)) {
      cat("ℹ️ Workflow not complete, completing now before export...\n")
      state <- complete_workflow()
      if (!isTRUE(state$workflow_complete)) {
        showNotification(
          "Could not complete workflow. Please ensure all required fields are filled.",
          type = "error",
          duration = 5
        )
        return()
      }
    }

    tryCatch({
      # Get converted data
      converted_data <- state$converted_main_data

      if (is.null(converted_data) || nrow(converted_data) == 0) {
        # Try to convert now
        converted_data <- convert_to_main_data_format(state$project_data)
        state$converted_main_data <- converted_data
        workflow_state(state)
      }

      # Create filename with timestamp
      project_name <- state$project_data$project_name %||% "Bowtie"
      project_name <- gsub("[^A-Za-z0-9_-]", "_", project_name)  # Sanitize filename
      filename <- paste0(project_name, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx")

      # Create temporary file
      temp_file <- file.path(tempdir(), filename)

      # Export using the existing function from vocabulary_bowtie_generator.R
      # Note: This function should be sourced in global.R
      if (exists("export_bowtie_to_excel")) {
        export_bowtie_to_excel(converted_data, temp_file)

        # Trigger download
        showNotification(
          paste("✅ Excel file created:", filename),
          type = "message",
          duration = 3
        )

        # Return file info for download handler (if downloadHandler is implemented)
        # For now, just notify where the file is saved
        showNotification(
          paste("File saved to:", temp_file),
          type = "message",
          duration = 10
        )
      } else {
        # Fallback: use openxlsx directly
        library(openxlsx)
        wb <- createWorkbook()
        addWorksheet(wb, "Bowtie_Data")
        writeData(wb, "Bowtie_Data", converted_data)

        # Add summary sheet
        addWorksheet(wb, "Summary")
        summary_data <- data.frame(
          Metric = c("Project Name", "Central Problem", "Total Entries",
                     "Unique Activities", "Unique Consequences", "Export Date"),
          Value = c(
            state$project_data$project_name %||% "Unnamed",
            state$project_data$problem_statement %||% "Unnamed",
            nrow(converted_data),
            length(unique(converted_data$Activity)),
            length(unique(converted_data$Consequence)),
            as.character(Sys.time())
          ),
          stringsAsFactors = FALSE
        )
        writeData(wb, "Summary", summary_data)

        # Save workbook
        saveWorkbook(wb, temp_file, overwrite = TRUE)

        showNotification(
          paste("✅ Excel file exported:", filename),
          type = "message",
          duration = 5
        )
      }

    }, error = function(e) {
      showNotification(
        paste("❌ Export failed:", e$message),
        type = "error",
        duration = 5
      )
    })
  })

  # Handler for Generate PDF Report
  observeEvent(input$export_pdf, {
    state <- workflow_state()

    # Check if workflow is complete, if not complete it now
    if (!isTRUE(state$workflow_complete)) {
      cat("ℹ️ Workflow not complete, completing now before export...\n")
      state <- complete_workflow()
      if (!isTRUE(state$workflow_complete)) {
        showNotification(
          "Could not complete workflow. Please ensure all required fields are filled.",
          type = "error",
          duration = 5
        )
        return()
      }
    }

    tryCatch({
      # Create a simple PDF report using base graphics or ggplot2
      project_name <- state$project_data$project_name %||% "Bowtie_Report"
      project_name <- gsub("[^A-Za-z0-9_-]", "_", project_name)
      filename <- paste0(project_name, "_Report_", format(Sys.Date(), "%Y%m%d"), ".pdf")
      temp_file <- file.path(tempdir(), filename)

      # Create PDF with summary information
      pdf(temp_file, width = 11, height = 8.5)

      # Title page
      plot.new()
      text(0.5, 0.9, "Bowtie Risk Assessment Report", cex = 2.5, font = 2)
      text(0.5, 0.8, state$project_data$project_name %||% "Unnamed Project", cex = 2)
      text(0.5, 0.7, paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M")), cex = 1.2)

      # Summary statistics page
      plot.new()
      text(0.5, 0.95, "Assessment Summary", cex = 2, font = 2)

      y_pos <- 0.85
      line_height <- 0.06

      # Project info
      text(0.1, y_pos, "Central Problem:", pos = 4, cex = 1.3, font = 2)
      text(0.1, y_pos - line_height, state$project_data$problem_statement %||% "Not specified",
           pos = 4, cex = 1.1)
      y_pos <- y_pos - 3 * line_height

      # Activities
      activities <- state$project_data$activities %||% list()
      text(0.1, y_pos, paste("Human Activities (", length(activities), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(activities) > 0) {
        for(i in seq_along(activities)[1:min(10, length(activities))]) {
          text(0.15, y_pos - i * line_height, paste("-", activities[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(10, length(activities)) + 1.5) * line_height
      } else {
        y_pos <- y_pos - line_height
      }

      # Pressures
      pressures <- state$project_data$pressures %||% list()
      text(0.1, y_pos, paste("Environmental Pressures (", length(pressures), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(pressures) > 0) {
        for(i in seq_along(pressures)[1:min(8, length(pressures))]) {
          text(0.15, y_pos - i * line_height, paste("-", pressures[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(8, length(pressures)) + 1.5) * line_height
      }

      # Page 3: Controls and Consequences
      plot.new()
      text(0.5, 0.95, "Controls & Consequences", cex = 2, font = 2)

      y_pos <- 0.85

      # Preventive Controls
      prev_controls <- state$project_data$preventive_controls %||% list()
      text(0.1, y_pos, paste("Preventive Controls (", length(prev_controls), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(prev_controls) > 0) {
        for(i in seq_along(prev_controls)[1:min(8, length(prev_controls))]) {
          text(0.15, y_pos - i * line_height, paste("-", prev_controls[i]), pos = 4, cex = 1)
        }
        y_pos <- y_pos - (min(8, length(prev_controls)) + 1.5) * line_height
      } else {
        y_pos <- y_pos - line_height
      }

      # Consequences
      consequences <- state$project_data$consequences %||% list()
      text(0.1, y_pos, paste("Consequences (", length(consequences), "):"),
           pos = 4, cex = 1.3, font = 2)
      if (length(consequences) > 0) {
        for(i in seq_along(consequences)[1:min(8, length(consequences))]) {
          text(0.15, y_pos - i * line_height, paste("-", consequences[i]), pos = 4, cex = 1)
        }
      }

      # Protective Controls
      prot_controls <- state$project_data$protective_controls %||% list()
      if (length(prot_controls) > 0 && y_pos > 0.3) {
        y_pos <- y_pos - (min(8, length(consequences)) + 2) * line_height
        text(0.1, y_pos, paste("Protective Controls (", length(prot_controls), "):"),
             pos = 4, cex = 1.3, font = 2)
        for(i in seq_along(prot_controls)[1:min(6, length(prot_controls))]) {
          text(0.15, y_pos - i * line_height, paste("-", prot_controls[i]), pos = 4, cex = 1)
        }
      }

      dev.off()

      showNotification(
        paste("✅ PDF report generated:", filename),
        type = "message",
        duration = 5
      )

      showNotification(
        paste("File saved to:", temp_file),
        type = "message",
        duration = 10
      )

    }, error = function(e) {
      showNotification(
        paste("❌ PDF generation failed:", e$message),
        type = "error",
        duration = 5
      )
    })
  })

  # Handler for Load to Main Application
  observeEvent(input$load_to_main, {
    state <- workflow_state()

    # Check if workflow is complete, if not complete it now
    if (!isTRUE(state$workflow_complete)) {
      cat("ℹ️ Workflow not complete, completing now before loading to main...\n")
      state <- complete_workflow()
      if (!isTRUE(state$workflow_complete)) {
        showNotification(
          "Could not complete workflow. Please ensure all required fields are filled.",
          type = "error",
          duration = 5
        )
        return()
      }
    }

    tryCatch({
      # Get or create converted data
      converted_data <- state$converted_main_data

      if (is.null(converted_data) || nrow(converted_data) == 0) {
        converted_data <- convert_to_main_data_format(state$project_data)
        state$converted_main_data <- converted_data
        workflow_state(state)
      }

      # Validate data
      if (is.null(converted_data) || nrow(converted_data) == 0) {
        showNotification(
          "❌ No data available to load. Please ensure your workflow is complete.",
          type = "error",
          duration = 5
        )
        return()
      }

      # Success notification
      showNotification(
        paste("✅ Loading", nrow(converted_data), "scenarios into main application..."),
        type = "message",
        duration = 3
      )

      # The actual loading is handled by the observer in server.R
      # which watches for changes to guided_workflow_state()$converted_main_data
      # That observer is around line 2025 in server.R

      # Additional notification
      showNotification(
        "🎉 Data will be loaded automatically. Switch to the 'Bowtie Diagram' tab to view.",
        type = "message",
        duration = 8
      )

    }, error = function(e) {
      showNotification(
        paste("❌ Failed to load data:", e$message),
        type = "error",
        duration = 5
      )
    })
  })

  # =============================================================================
  # SAVE & LOAD FUNCTIONALITY
  # =============================================================================
  
  # Trigger hidden file input for loading
  observeEvent(input$workflow_load_btn, {
    # Use shinyjs to trigger the namespaced file input click
    shinyjs::runjs("$('#guided_workflow-workflow_load_file_hidden').click();")
  })
  
  # Handle file loading
  observeEvent(input$workflow_load_file_hidden, {
    file <- input$workflow_load_file_hidden
    req(file)

    cat("📂 Loading workflow from file:", file$name, "\n")

    tryCatch({
      loaded_state <- readRDS(file$datapath)

      # Basic validation of loaded state
      if (is.list(loaded_state) && "current_step" %in% names(loaded_state)) {

        cat("✅ Valid workflow file detected\n")

        # Migrate old data structures if needed
        if (!is.null(loaded_state$project_data)) {
          # Ensure activities are character vectors, not data frames
          if (!is.null(loaded_state$project_data$activities)) {
            if (is.data.frame(loaded_state$project_data$activities)) {
              # Try multiple column names (Activity, Actvity - old typo)
              if ("Activity" %in% names(loaded_state$project_data$activities)) {
                loaded_state$project_data$activities <- loaded_state$project_data$activities$Activity
              } else if ("Actvity" %in% names(loaded_state$project_data$activities)) {
                loaded_state$project_data$activities <- loaded_state$project_data$activities$Actvity
              } else if (ncol(loaded_state$project_data$activities) > 0) {
                # Take first column if column names don't match
                loaded_state$project_data$activities <- loaded_state$project_data$activities[[1]]
              }
            }
            loaded_state$project_data$activities <- as.character(loaded_state$project_data$activities)
          }

          # Ensure pressures are character vectors
          if (!is.null(loaded_state$project_data$pressures)) {
            if (is.data.frame(loaded_state$project_data$pressures)) {
              if ("Pressure" %in% names(loaded_state$project_data$pressures)) {
                loaded_state$project_data$pressures <- loaded_state$project_data$pressures$Pressure
              } else if (ncol(loaded_state$project_data$pressures) > 0) {
                loaded_state$project_data$pressures <- loaded_state$project_data$pressures[[1]]
              }
            }
            loaded_state$project_data$pressures <- as.character(loaded_state$project_data$pressures)
          }

          # Ensure preventive controls are character vectors
          if (!is.null(loaded_state$project_data$preventive_controls)) {
            if (is.data.frame(loaded_state$project_data$preventive_controls)) {
              if ("Control" %in% names(loaded_state$project_data$preventive_controls)) {
                loaded_state$project_data$preventive_controls <- loaded_state$project_data$preventive_controls$Control
              } else if (ncol(loaded_state$project_data$preventive_controls) > 0) {
                loaded_state$project_data$preventive_controls <- loaded_state$project_data$preventive_controls[[1]]
              }
            }
            loaded_state$project_data$preventive_controls <- as.character(loaded_state$project_data$preventive_controls)
          }

          # Ensure consequences are character vectors
          if (!is.null(loaded_state$project_data$consequences)) {
            if (is.data.frame(loaded_state$project_data$consequences)) {
              if ("Consequence" %in% names(loaded_state$project_data$consequences)) {
                loaded_state$project_data$consequences <- loaded_state$project_data$consequences$Consequence
              } else if (ncol(loaded_state$project_data$consequences) > 0) {
                loaded_state$project_data$consequences <- loaded_state$project_data$consequences[[1]]
              }
            }
            loaded_state$project_data$consequences <- as.character(loaded_state$project_data$consequences)
          }

          # Ensure protective controls are character vectors
          if (!is.null(loaded_state$project_data$protective_controls)) {
            if (is.data.frame(loaded_state$project_data$protective_controls)) {
              if ("Control" %in% names(loaded_state$project_data$protective_controls)) {
                loaded_state$project_data$protective_controls <- loaded_state$project_data$protective_controls$Control
              } else if (ncol(loaded_state$project_data$protective_controls) > 0) {
                loaded_state$project_data$protective_controls <- loaded_state$project_data$protective_controls[[1]]
              }
            }
            loaded_state$project_data$protective_controls <- as.character(loaded_state$project_data$protective_controls)
          }

          # Ensure escalation factors are character vectors
          if (!is.null(loaded_state$project_data$escalation_factors)) {
            if (is.data.frame(loaded_state$project_data$escalation_factors)) {
              # Try multiple possible column names
              if ("Escalation Factor" %in% names(loaded_state$project_data$escalation_factors)) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors$`Escalation Factor`
              } else if ("escalation_factor" %in% names(loaded_state$project_data$escalation_factors)) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors$escalation_factor
              } else if (ncol(loaded_state$project_data$escalation_factors) > 0) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors[[1]]
              }
            }
            loaded_state$project_data$escalation_factors <- as.character(loaded_state$project_data$escalation_factors)
          }
        }

        cat("✅ Data migration complete\n")
        workflow_state(loaded_state)
        
        # Update the reactive values based on current step
        if (loaded_state$current_step == 3) {
          if (!is.null(loaded_state$project_data$activities)) {
            selected_activities(loaded_state$project_data$activities)
          }
          if (!is.null(loaded_state$project_data$pressures)) {
            selected_pressures(loaded_state$project_data$pressures)
          }
        } else if (loaded_state$current_step == 4) {
          if (!is.null(loaded_state$project_data$activities)) {
            selected_activities(loaded_state$project_data$activities)
          }
          if (!is.null(loaded_state$project_data$pressures)) {
            selected_pressures(loaded_state$project_data$pressures)
          }
          if (!is.null(loaded_state$project_data$preventive_controls)) {
            selected_preventive_controls(loaded_state$project_data$preventive_controls)
          }
        } else if (loaded_state$current_step == 5) {
          if (!is.null(loaded_state$project_data$consequences)) {
            selected_consequences(loaded_state$project_data$consequences)
          }
        } else if (loaded_state$current_step == 6) {
          if (!is.null(loaded_state$project_data$consequences)) {
            selected_consequences(loaded_state$project_data$consequences)
          }
          if (!is.null(loaded_state$project_data$protective_controls)) {
            selected_protective_controls(loaded_state$project_data$protective_controls)
          }
        } else if (loaded_state$current_step == 7) {
          if (!is.null(loaded_state$project_data$escalation_factors)) {
            selected_escalation_factors(loaded_state$project_data$escalation_factors)
          }
        }
        
        showNotification("✅ Workflow progress loaded successfully!", type = "message")
      } else {
        showNotification("❌ Invalid workflow file.", type = "error")
      }
    }, error = function(e) {
      showNotification(paste(t("gw_error_loading", lang()), e$message), type = "error")
    })
  })
  
  # Handle file download (saving)
  output$workflow_download <- downloadHandler(
    filename = function() {
      project_name <- workflow_state()$project_data$project_name %||% "untitled"
      paste0(gsub(" ", "_", project_name), "_workflow_", Sys.Date(), ".rds")
    },
    content = function(file) {
      state_to_save <- workflow_state()
      state_to_save$last_saved <- Sys.time()
      saveRDS(state_to_save, file)
    },
    contentType = "application/octet-stream"  # Proper MIME type to avoid browser warnings
  )
  
  # =============================================================================
  # RETURN VALUE
  # =============================================================================
  
  # Return the reactive workflow state
  return(workflow_state)
  
  })  # End of moduleServer
}  # End of guided_workflow_server

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Helper operator for default values
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || (is.character(x) && all(nchar(x) == 0))) y else x
}

# Estimate remaining time based on progress
estimate_remaining_time <- function(state) {
  step_durations <- c(2.5, 4, 7.5, 6.5, 4, 6.5, 4, 2.5)  # Average minutes per step
  remaining_steps <- setdiff(1:state$total_steps, state$completed_steps)
  sum(step_durations[remaining_steps])
}

# Validate step completion
validate_step <- function(step_number, data) {
  switch(step_number,
         "1" = validate_step1(data),
         "2" = validate_step2(data),
         "3" = validate_step3(data),
         "4" = validate_step4(data),
         "5" = validate_step5(data),
         "6" = validate_step6(data),
         "7" = validate_step7(data),
         "8" = validate_step8(data)
  )
}

# Validate current step before proceeding
validate_current_step <- function(state, input, current_lang = "en") {
  step <- state$current_step

  # Basic validation based on step number
  validation <- switch(as.character(step),
    "1" = {
      # Step 1: Project Setup
      project_name <- input$project_name
      if (is.null(project_name) || nchar(trimws(project_name)) == 0) {
        list(is_valid = FALSE, message = "Please enter a project name before continuing.")
      } else {
        list(is_valid = TRUE, message = "")
      }
    },
    "2" = {
      # Step 2: Central Problem
      problem <- input$problem_statement
      if (is.null(problem) || nchar(trimws(problem)) == 0) {
        list(is_valid = FALSE, message = "Please define the central problem before continuing.")
      } else {
        list(is_valid = TRUE, message = "")
      }
    },
    "3" = {
      # Step 3: Activities and Pressures
      # Optional validation - can proceed without entries
      list(is_valid = TRUE, message = "")
    },
    # Steps 4-7 have no mandatory fields (placeholders)
    "4" = list(is_valid = TRUE, message = ""),
    "5" = list(is_valid = TRUE, message = ""),
    "6" = list(is_valid = TRUE, message = ""),
    "7" = list(is_valid = TRUE, message = ""),
    "8" = list(is_valid = TRUE, message = ""),
    # Default
    list(is_valid = TRUE, message = "")
  )

  return(validation)
}

# Save step data to workflow state
save_step_data <- function(state, input) {
  step <- state$current_step

  # Save data based on current step
  if (step == 1) {
    # Save project setup data - safely access inputs with fallbacks
    state$project_data$project_name <- if (!is.null(input$project_name)) input$project_name else state$project_data$project_name
    state$project_data$project_location <- if (!is.null(input$project_location)) input$project_location else state$project_data$project_location
    state$project_data$project_type <- if (!is.null(input$project_type)) input$project_type else state$project_data$project_type
    state$project_data$project_description <- if (!is.null(input$project_description)) input$project_description else state$project_data$project_description
    state$project_name <- state$project_data$project_name  # Also save at top level
  } else if (step == 2) {
    # Save central problem data - safely access inputs with fallbacks
    state$project_data$problem_statement <- if (!is.null(input$problem_statement)) input$problem_statement else state$project_data$problem_statement
    state$project_data$problem_category <- if (!is.null(input$problem_category)) input$problem_category else state$project_data$problem_category
    state$project_data$problem_details <- if (!is.null(input$problem_details)) input$problem_details else state$project_data$problem_details
    state$project_data$problem_scale <- if (!is.null(input$problem_scale)) input$problem_scale else state$project_data$problem_scale
    state$project_data$problem_urgency <- if (!is.null(input$problem_urgency)) input$problem_urgency else state$project_data$problem_urgency
    state$central_problem <- state$project_data$problem_statement  # Also save at top level
  } else if (step == 3) {
    # CRITICAL FIX (Issue #11): Save activities and pressures data
    # Ensure data is preserved - don't overwrite with empty values
    if (is.null(state$project_data$activities)) {
      state$project_data$activities <- list()
    }
    if (is.null(state$project_data$pressures)) {
      state$project_data$pressures <- list()
    }

    # Debugging: Log current data
    cat("📊 Step 3 - Saving activities:", length(state$project_data$activities), "items\n")
    cat("📊 Step 3 - Saving pressures:", length(state$project_data$pressures), "items\n")

  } else if (step == 4) {
    # CRITICAL FIX (Issue #11): Save preventive controls data
    # Ensure data is preserved - don't overwrite with empty values
    if (is.null(state$project_data$preventive_controls)) {
      state$project_data$preventive_controls <- list()
    }

    # Debugging: Log current data
    cat("📊 Step 4 - Saving preventive controls:", length(state$project_data$preventive_controls), "items\n")

  } else if (step == 5) {
    # CRITICAL FIX (Issue #11): Save consequences data
    # Ensure data is preserved - don't overwrite with empty values
    if (is.null(state$project_data$consequences)) {
      state$project_data$consequences <- list()
    }

    # Debugging: Log current data
    cat("📊 Step 5 - Saving consequences:", length(state$project_data$consequences), "items\n")

  } else if (step == 6) {
    # CRITICAL FIX (Issue #11): Save protective controls data
    # Ensure data is preserved - don't overwrite with empty values
    if (is.null(state$project_data$protective_controls)) {
      state$project_data$protective_controls <- list()
    }

    # Debugging: Log current data
    cat("📊 Step 6 - Saving protective controls:", length(state$project_data$protective_controls), "items\n")

  } else if (step == 7) {
    # CRITICAL FIX (Issue #11): Save escalation factors data
    # Ensure data is preserved - don't overwrite with empty values
    if (is.null(state$project_data$escalation_factors)) {
      state$project_data$escalation_factors <- list()
    }

    # Debugging: Log current data
    cat("📊 Step 7 - Saving escalation factors:", length(state$project_data$escalation_factors), "items\n")
  }
  # Step 8 is review only - no data to save

  # CRITICAL FIX (Issue #11): Validate data integrity
  # Ensure all data fields exist and are not accidentally set to NULL
  if (is.null(state$project_data)) {
    state$project_data <- list()
  }

  # Initialize all data fields if they don't exist (prevents data loss)
  if (is.null(state$project_data$activities)) state$project_data$activities <- list()
  if (is.null(state$project_data$pressures)) state$project_data$pressures <- list()
  if (is.null(state$project_data$preventive_controls)) state$project_data$preventive_controls <- list()
  if (is.null(state$project_data$consequences)) state$project_data$consequences <- list()
  if (is.null(state$project_data$protective_controls)) state$project_data$protective_controls <- list()
  if (is.null(state$project_data$escalation_factors)) state$project_data$escalation_factors <- list()

  # Log total data in state for debugging
  total_items <- length(state$project_data$activities) +
                 length(state$project_data$pressures) +
                 length(state$project_data$preventive_controls) +
                 length(state$project_data$consequences) +
                 length(state$project_data$protective_controls) +
                 length(state$project_data$escalation_factors)

  cat("💾 State saved - Total items:", total_items, "\n")

  # Record timestamp for this step
  state$step_times[[paste0("step_", step)]] <- Sys.time()

  return(state)
}

# Convert workflow data to main application format
convert_to_main_data_format <- function(project_data) {
  # Create a comprehensive bowtie data frame from workflow data
  # NOTE: Escalation factors in bow-tie methodology affect CONTROLS, not the central event
  # The data structure uses a single Escalation_Factor column for simplicity,
  # but these factors represent threats to control effectiveness
  
  tryCatch({
    # Extract all components
    central_problem <- project_data$problem_statement %||% "Unnamed Problem"
    project_name <- project_data$project_name %||% "Unnamed Project"
    
    activities <- project_data$activities %||% list()
    pressures <- project_data$pressures %||% list()
    preventive_controls <- project_data$preventive_controls %||% list()
    consequences <- project_data$consequences %||% list()
    protective_controls <- project_data$protective_controls %||% list()
    escalation_factors <- project_data$escalation_factors %||% list()
    
    # Convert to character vectors if needed
    activities <- as.character(activities)
    pressures <- as.character(pressures)
    preventive_controls <- as.character(preventive_controls)
    consequences <- as.character(consequences)
    protective_controls <- as.character(protective_controls)
    escalation_factors <- as.character(escalation_factors)
    
    # If no escalation factors, create dummy ones
    if (length(escalation_factors) == 0) {
      escalation_factors <- c(
        "Budget constraints reducing monitoring",
        "Staff turnover affecting expertise",
        "Equipment maintenance delays",
        "Regulatory changes creating gaps",
        "Extreme weather overwhelming systems",
        "Human error during critical operations"
      )
      cat("ℹ️ No escalation factors defined - using dummy examples\n")
    }
    
    # Create bow-tie rows
    # Structure: Activity → Pressure → Preventive_Control → Central_Problem → Protective_Mitigation → Consequence
    # Escalation_Factor: Represents threats to control effectiveness (assigned to each control pathway)
    
    bowtie_rows <- list()
    
    # If we have complete data, create proper combinations
    if (length(activities) > 0 && length(pressures) > 0 && 
        length(preventive_controls) > 0 && length(consequences) > 0 && 
        length(protective_controls) > 0) {
      
      # Create multiple rows representing different pathways through the bow-tie
      # Limit combinations to avoid explosion of rows
      
      for (activity in activities[1:min(3, length(activities))]) {
        for (pressure in pressures[1:min(2, length(pressures))]) {
          for (preventive in preventive_controls[1:min(2, length(preventive_controls))]) {
            for (consequence in consequences[1:min(2, length(consequences))]) {
              for (protective in protective_controls[1:min(2, length(protective_controls))]) {
                
                # Select an escalation factor for this pathway
                # In reality, each escalation factor threatens specific controls
                # Here we randomly assign one to represent the control vulnerability
                escalation <- sample(escalation_factors, 1)
                
                bowtie_rows[[length(bowtie_rows) + 1]] <- data.frame(
                  Activity = activity,
                  Pressure = pressure,
                  Preventive_Control = preventive,
                  Escalation_Factor = escalation,  # Threatens the controls, not the central problem
                  Central_Problem = central_problem,
                  Protective_Mitigation = protective,
                  Consequence = consequence,
                  Likelihood = sample(1:5, 1),
                  Severity = sample(1:5, 1),
                  stringsAsFactors = FALSE
                )
              }
            }
          }
        }
      }
      
    } else {
      # Create sample rows if data is incomplete
      cat("ℹ️ Incomplete workflow data - creating sample bow-tie structure\n")
      
      # Create at least one row per escalation factor to show they threaten controls
      for (i in 1:min(3, max(1, length(escalation_factors)))) {
        bowtie_rows[[i]] <- data.frame(
          Activity = if(length(activities) > 0) activities[min(i, length(activities))] else "Sample Activity",
          Pressure = if(length(pressures) > 0) pressures[min(i, length(pressures))] else "Sample Pressure",
          Preventive_Control = if(length(preventive_controls) > 0) preventive_controls[min(i, length(preventive_controls))] else "Sample Preventive Control",
          Escalation_Factor = if(i <= length(escalation_factors)) escalation_factors[i] else escalation_factors[1],
          Central_Problem = central_problem,
          Protective_Mitigation = if(length(protective_controls) > 0) protective_controls[min(i, length(protective_controls))] else "Sample Protective Control",
          Consequence = if(length(consequences) > 0) consequences[min(i, length(consequences))] else "Sample Consequence",
          Likelihood = 3L,
          Severity = 3L,
          stringsAsFactors = FALSE
        )
      }
    }
    
    # Combine all rows
    bowtie_data <- do.call(rbind, bowtie_rows)
    
    # Calculate risk level
    bowtie_data$Risk_Level <- ifelse(
      bowtie_data$Likelihood * bowtie_data$Severity > 15, "High",
      ifelse(bowtie_data$Likelihood * bowtie_data$Severity > 8, "Medium", "Low")
    )
    
    # Add metadata
    attr(bowtie_data, "project_name") <- project_name
    attr(bowtie_data, "created_from") <- "guided_workflow"
    attr(bowtie_data, "created_at") <- Sys.time()
    attr(bowtie_data, "escalation_factors_count") <- length(unique(escalation_factors))
    attr(bowtie_data, "note") <- "Escalation factors threaten control effectiveness, not the central problem directly"
    
    cat("✅ Generated", nrow(bowtie_data), "bow-tie pathway(s)\n")
    cat("📊 Components: ", 
        length(unique(bowtie_data$Activity)), "activities, ",
        length(unique(bowtie_data$Preventive_Control)), "preventive controls, ",
        length(unique(bowtie_data$Protective_Mitigation)), "protective controls, ",
        length(unique(bowtie_data$Consequence)), "consequences, ",
        length(unique(bowtie_data$Escalation_Factor)), "escalation factors\n")
    
    return(bowtie_data)
    
  }, error = function(e) {
    cat("❌ Error converting workflow data:", e$message, "\n")
    # Return minimal valid data frame
    data.frame(
      Activity = "Error in conversion",
      Pressure = "Error in conversion",
      Preventive_Control = "Error in conversion",
      Escalation_Factor = "System error (threatens controls)",
      Central_Problem = "Error in conversion",
      Protective_Mitigation = "Error in conversion",
      Consequence = "Error in conversion",
      Likelihood = 1L,
      Severity = 1L,
      Risk_Level = "Low",
      stringsAsFactors = FALSE
    )
  })
}

# Step validation functions (to be implemented)
validate_step1 <- function(data) {
  list(valid = !is.null(data$project_name) && nchar(data$project_name) > 0,
       message = "Project name is required")
}

validate_step2 <- function(data) {
  list(valid = !is.null(data$central_problem) && nchar(data$central_problem) > 0,
       message = "Central problem definition is required")
}

# Integration helper - create guided workflow tab
create_guided_workflow_tab <- function() {
  tryCatch({
    # Check if bslib nav_panel function is available
    if (exists("nav_panel", mode = "function")) {
      nav_panel(
        title = tagList(icon("magic"), "Guided Creation"),
        icon = icon("magic"),
        value = "guided_workflow",
        guided_workflow_ui()
      )
    } else {
      # Fallback for older Shiny versions
      tabPanel(
        title = tagList(icon("magic"), "Guided Creation"),
        value = "guided_workflow",
        guided_workflow_ui()
      )
    }
  }, error = function(e) {
    cat("Warning: Error creating guided workflow tab:", e$message, "\n")
    # Return basic tabPanel as fallback
    tabPanel(
      title = "Guided Creation",
      value = "guided_workflow",
      guided_workflow_ui()
    )
  })
}

cat("✅ Guided Workflow System Ready!\n")
cat("📋 Available functions:\n")
cat("   - guided_workflow_ui(): Main workflow UI\n")
cat("   - guided_workflow_server(): Server logic\n")
cat("   - create_guided_workflow_tab(): Integration helper\n")
cat("   - init_workflow_state(): Initialize workflow\n")
cat("\n🎯 Add to your app with create_guided_workflow_tab()!\n")
