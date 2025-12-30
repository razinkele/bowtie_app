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
  optional_packages <- c("ggplot2", "plotly", "openxlsx", "jsonlite", "digest")
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

# Load AI suggestions module
cat("🤖 Loading AI-powered suggestions...\n")
# AI suggestions available but controlled by user settings (gear icon)
if (file.exists("guided_workflow_ai_suggestions.R")) {
  tryCatch({
    source("guided_workflow_ai_suggestions.R")
    WORKFLOW_AI_AVAILABLE <- TRUE
    cat("✅ AI suggestions module loaded (controlled by user settings)\n")
    cat("   ⚙️  Enable in Settings → AI Suggestions Settings\n")
    cat("   ⚠️  Warning: May cause 2-3 second delays when enabled\n\n")
  }, error = function(e) {
    WORKFLOW_AI_AVAILABLE <- FALSE
    cat("⚠️ AI suggestions unavailable:", e$message, "\n\n")
  })
} else {
  WORKFLOW_AI_AVAILABLE <- FALSE
  cat("ℹ️ AI suggestions module not found\n\n")
}

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
    climate_impact = list(
      name = "Climate Change Impact",
      project_name = "Climate Change Ecosystem Impact Assessment",
      project_location = "Regional / Global",
      project_type = "climate",
      project_description = "Comprehensive assessment of ecosystem disruption from climate change including temperature rise, sea level changes, and extreme weather events.",
      central_problem = "Ecosystem disruption from climate change",
      problem_category = "climate_impacts",
      problem_details = "Comprehensive analysis of temperature increases, sea level rise, extreme weather events, ocean acidification, and altered precipitation patterns from greenhouse gas emissions affecting ecosystems, biodiversity, and human communities globally.",
      problem_scale = "global",
      problem_urgency = "critical",
      example_activities = c("Greenhouse gas emissions", "Land use change", "Energy production"),
      example_pressures = c("Temperature increase", "Sea level rise", "Extreme weather"),
      category = "Climate & Weather"
    ),
    biodiversity_loss = list(
      name = "Biodiversity Loss Assessment",
      project_name = "Biodiversity Decline Risk Assessment",
      project_location = "Ecosystem / Protected Area",
      project_type = "terrestrial",
      project_description = "Assessment of species population decline and biodiversity loss from habitat destruction, invasive species, and overexploitation of natural resources.",
      central_problem = "Species population decline and habitat loss",
      problem_category = "habitat_loss",
      problem_details = "Evaluation of habitat fragmentation, species competition from invasive species, overharvesting of wildlife, ecosystem degradation, and loss of genetic diversity from deforestation, urbanization, and unsustainable resource extraction threatening biodiversity.",
      problem_scale = "national",
      problem_urgency = "high",
      example_activities = c("Habitat destruction", "Invasive species", "Overexploitation"),
      example_pressures = c("Habitat fragmentation", "Species competition", "Overharvesting"),
      category = "Biodiversity"
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
        /* Autosave status indicator */
        .autosave-status {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          padding: 4px 12px;
          border-radius: 20px;
          font-size: 0.85rem;
          font-weight: 500;
          transition: all 0.3s ease;
          opacity: 0;
          background: rgba(255, 255, 255, 0.95);
          color: #6c757d;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        .autosave-status.saving {
          opacity: 1;
          color: #0d6efd;
          background: #e7f1ff;
        }
        .autosave-status.saved {
          opacity: 1;
          color: #198754;
          background: #d1f4e0;
        }
        .autosave-status.error {
          opacity: 1;
          color: #dc3545;
          background: #ffe5e5;
        }
        .autosave-status i {
          font-size: 1rem;
        }
        .autosave-status.saving i {
          animation: spin 1s linear infinite;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      ")),
      # JavaScript for autosave functionality
      tags$script(HTML("
        // Autosave localStorage handlers
        Shiny.addCustomMessageHandler('smartAutosave', function(data) {
          try {
            localStorage.setItem('bowtie_workflow_autosave', data.state);
            localStorage.setItem('bowtie_workflow_autosave_timestamp', data.timestamp);
            localStorage.setItem('bowtie_workflow_autosave_hash', data.hash);

            updateAutosaveStatus('saved', 'Saved ' + data.timestamp);
          } catch (e) {
            console.error('Autosave failed:', e);
            updateAutosaveStatus('error', 'Save failed');
          }
        });

        Shiny.addCustomMessageHandler('loadFromLocalStorage', function(data) {
          try {
            var value = localStorage.getItem(data.key);
            if (value) {
              Shiny.setInputValue(data.inputId, value);
            }
          } catch (e) {
            console.error('Failed to load from localStorage:', e);
          }
        });

        Shiny.addCustomMessageHandler('clearAutosave', function(data) {
          try {
            localStorage.removeItem('bowtie_workflow_autosave');
            localStorage.removeItem('bowtie_workflow_autosave_timestamp');
            localStorage.removeItem('bowtie_workflow_autosave_hash');
          } catch (e) {
            console.error('Failed to clear autosave:', e);
          }
        });

        function updateAutosaveStatus(status, text) {
          var statusDiv = $('#guided_workflow-autosave_status');
          if (statusDiv.length === 0) return;

          var iconSpan = statusDiv.find('.autosave-icon');
          var textSpan = statusDiv.find('.autosave-text');

          statusDiv.removeClass('saving saved error');

          if (status === 'saving') {
            statusDiv.addClass('saving');
            iconSpan.html('<i class=\"fas fa-spinner\"></i>');
            textSpan.text(text || 'Saving...');
            statusDiv.css('opacity', '1');
          } else if (status === 'saved') {
            statusDiv.addClass('saved');
            iconSpan.html('<i class=\"fas fa-check-circle\"></i>');
            textSpan.text(text || 'Saved');
            statusDiv.css('opacity', '1');

            // Fade out after 3 seconds
            setTimeout(function() {
              statusDiv.css('opacity', '0');
            }, 3000);
          } else if (status === 'error') {
            statusDiv.addClass('error');
            iconSpan.html('<i class=\"fas fa-exclamation-circle\"></i>');
            textSpan.text(text || 'Error');
            statusDiv.css('opacity', '1');

            // Fade out after 5 seconds
            setTimeout(function() {
              statusDiv.css('opacity', '0');
            }, 5000);
          }
        }
      "))
    ),
    
    # Workflow header
    div(class = "workflow-header",
        fluidRow(
          column(8,
                 h2(tagList(icon("magic"), t("gw_title", current_lang)), style = "margin: 0;"),
                 p(t("gw_subtitle", current_lang), style = "margin: 5px 0 0 0;")
          ),
          column(4,
                 div(class = "text-end d-flex align-items-center justify-content-end gap-2",
                     # Autosave status indicator
                     tags$div(id = ns("autosave_status"), class = "autosave-status",
                              tags$span(class = "autosave-icon"),
                              tags$span(class = "autosave-text")
                     ),
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
             h4(t("gw_project_info", current_lang)),
             validated_text_input(
               id = ns("project_name"),
               label = t("gw_project_name", current_lang),
               placeholder = t("gw_project_name_placeholder", current_lang),
               required = TRUE,
               min_length = 3,
               max_length = 100,
               help_text = "Enter a descriptive name for your environmental risk analysis project (3-100 characters)"
             ),
             validated_text_input(
               id = ns("project_location"),
               label = t("gw_location", current_lang),
               placeholder = t("gw_location_placeholder", current_lang),
               required = TRUE,
               min_length = 2,
               max_length = 100,
               help_text = "Specify the geographic location or region for this assessment"
             ),
             validated_select_input(
               id = ns("project_type"),
               label = t("gw_assessment_type", current_lang),
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
               },
               required = TRUE,
               help_text = "Select the primary environmental domain for this assessment"
             ),
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
             validated_text_input(
               id = ns("problem_statement"),
               label = t("gw_problem_statement", current_lang),
               placeholder = t("gw_problem_statement_placeholder", current_lang),
               required = TRUE,
               min_length = 5,
               max_length = 200,
               help_text = "Clearly define the central environmental problem or hazard (5-200 characters)"
             ),

             validated_select_input(
               id = ns("problem_category"),
               label = t("gw_problem_category", current_lang),
               choices = setNames(
                 c("pollution", "habitat_loss", "climate_impacts", "resource_depletion", "ecosystem_services", "other"),
                 c(t("gw_problem_category_pollution", current_lang), t("gw_problem_category_habitat", current_lang), t("gw_problem_category_climate", current_lang), t("gw_problem_category_resource", current_lang), t("gw_problem_category_ecosystem", current_lang), t("gw_problem_category_other", current_lang))
               ),
               required = TRUE,
               help_text = "Select the primary category that best describes this environmental problem"
             ),

             textAreaInput(ns("problem_details"), t("gw_detailed_description", current_lang),
                          placeholder = t("gw_detailed_description_placeholder", current_lang),
                          rows = 4),

             validated_select_input(
               id = ns("problem_scale"),
               label = t("gw_spatial_scale", current_lang),
               choices = setNames(
                 c("local", "regional", "national", "international", "global"),
                 c(t("gw_scale_local", current_lang), t("gw_scale_regional", current_lang), t("gw_scale_national", current_lang), t("gw_scale_international", current_lang), t("gw_scale_global", current_lang))
               ),
               required = TRUE,
               help_text = "Specify the geographic scale or extent of the environmental problem"
             ),

             validated_select_input(
               id = ns("problem_urgency"),
               label = t("gw_urgency_level", current_lang),
               choices = setNames(
                 c("critical", "high", "medium", "low"),
                 c(t("gw_urgency_critical", current_lang), t("gw_urgency_high", current_lang), t("gw_urgency_medium", current_lang), t("gw_urgency_low", current_lang))
               ),
               required = TRUE,
               help_text = "Indicate the urgency level for addressing this environmental issue"
             )
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

             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 activity_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities) && nrow(vocabulary_data$activities) > 0) {
                   level1_activities <- vocabulary_data$activities[vocabulary_data$activities$level == 1 & !is.na(vocabulary_data$activities$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_activities) > 0) {
                     level1_activities <- level1_activities[!is.na(level1_activities$name) & !is.na(level1_activities$id), ]
                     if (nrow(level1_activities) > 0) {
                       activity_groups <- setNames(level1_activities$id, level1_activities$name)
                     }
                   }
                 }

                 selectizeInput(ns("activity_group"), "Step 1: Select Activity Group",
                              choices = c("Choose a group..." = "", activity_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select an activity category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("activity_item"), "Step 2: Select Specific Activity",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select an activity from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("activity_custom_toggle"), "Or enter a custom activity not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.activity_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("activity_custom_text"),
                     label = "Custom Activity Name:",
                     placeholder = "Enter new activity name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom human activity not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_activity"), tagList(icon("plus"), t("gw_add_activity", current_lang)),
                            class = "btn-success btn-block")
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

             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 pressure_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures) && nrow(vocabulary_data$pressures) > 0) {
                   level1_pressures <- vocabulary_data$pressures[vocabulary_data$pressures$level == 1 & !is.na(vocabulary_data$pressures$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_pressures) > 0) {
                     level1_pressures <- level1_pressures[!is.na(level1_pressures$name) & !is.na(level1_pressures$id), ]
                     if (nrow(level1_pressures) > 0) {
                       pressure_groups <- setNames(level1_pressures$id, level1_pressures$name)
                     }
                   }
                 }

                 selectizeInput(ns("pressure_group"), "Step 1: Select Pressure Group",
                              choices = c("Choose a group..." = "", pressure_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a pressure category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("pressure_item"), "Step 2: Select Specific Pressure",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a pressure from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("pressure_custom_toggle"), "Or enter a custom pressure not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.pressure_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("pressure_custom_text"),
                     label = "Custom Pressure Name:",
                     placeholder = "Enter new pressure name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom environmental pressure not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_pressure"), tagList(icon("plus"), t("gw_add_pressure", current_lang)),
                            class = "btn-warning btn-block")
               )
             ),
             
             h5(t("gw_selected_pressures", current_lang)),
             DTOutput(ns("selected_pressures_table")),

             br(),
             div(class = "alert alert-info",
                 h6(t("gw_examples_title", current_lang)),
                 p(t("gw_pressures_examples_text", current_lang))
             ),

             # AI-powered suggestions for pressures (if available)
             if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
               create_ai_suggestions_ui(
                 ns,
                 "pressure",
                 "🤖 AI-Powered Pressure Suggestions",
                 current_lang
               )
             } else {
               NULL
             }
      )
    ),

    br(),
    h4(t("gw_activity_pressure_connections_title", current_lang)),
    p(t("gw_link_activities", current_lang)),
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
             
             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 control_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
                   level1_controls <- vocabulary_data$controls[vocabulary_data$controls$level == 1 & !is.na(vocabulary_data$controls$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_controls) > 0) {
                     level1_controls <- level1_controls[!is.na(level1_controls$name) & !is.na(level1_controls$id), ]
                     if (nrow(level1_controls) > 0) {
                       control_groups <- setNames(level1_controls$id, level1_controls$name)
                     }
                   }
                 }

                 selectizeInput(ns("preventive_control_group"), "Step 1: Select Control Group",
                              choices = c("Choose a group..." = "", control_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a control category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("preventive_control_item"), "Step 2: Select Specific Control",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a control from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("preventive_control_custom_toggle"), "Or enter a custom control not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.preventive_control_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("preventive_control_custom_text"),
                     label = "Custom Control Name:",
                     placeholder = "Enter new control name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom preventive control measure not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_preventive_control"), tagList(icon("shield-alt"), t("gw_add_control", current_lang)),
                            class = "btn-success btn-block")
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
             ),

             # AI-powered suggestions for preventive controls (if available)
             if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
               create_ai_suggestions_ui(
                 ns,
                 "control_preventive",
                 "🤖 AI-Powered Control Suggestions",
                 current_lang
               )
             } else {
               NULL
             }
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
             
             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 consequence_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$consequences) && nrow(vocabulary_data$consequences) > 0) {
                   level1_consequences <- vocabulary_data$consequences[vocabulary_data$consequences$level == 1 & !is.na(vocabulary_data$consequences$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_consequences) > 0) {
                     level1_consequences <- level1_consequences[!is.na(level1_consequences$name) & !is.na(level1_consequences$id), ]
                     if (nrow(level1_consequences) > 0) {
                       consequence_groups <- setNames(level1_consequences$id, level1_consequences$name)
                     }
                   }
                 }

                 selectizeInput(ns("consequence_group"), "Step 1: Select Consequence Group",
                              choices = c("Choose a group..." = "", consequence_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a consequence category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("consequence_item"), "Step 2: Select Specific Consequence",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a consequence from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("consequence_custom_toggle"), "Or enter a custom consequence not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.consequence_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("consequence_custom_text"),
                     label = "Custom Consequence Name:",
                     placeholder = "Enter new consequence name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom environmental consequence not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_consequence"), tagList(icon("exclamation-triangle"), t("gw_add_consequence", current_lang)),
                            class = "btn-warning btn-block")
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
             ),

             # AI-powered suggestions for consequences (if available)
             if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
               create_ai_suggestions_ui(
                 ns,
                 "consequence",
                 "🤖 AI-Powered Consequence Suggestions",
                 current_lang
               )
             } else {
               NULL
             }
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
             
             # Hierarchical selection: Group first, then items
             fluidRow(
               column(12, {
                 # Prepare Level 1 (group) choices from vocabulary data
                 protective_control_groups <- character(0)
                 if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
                   level1_controls <- vocabulary_data$controls[vocabulary_data$controls$level == 1 & !is.na(vocabulary_data$controls$level), ]
                   # Additional safety: filter out any NA names or IDs
                   if (nrow(level1_controls) > 0) {
                     level1_controls <- level1_controls[!is.na(level1_controls$name) & !is.na(level1_controls$id), ]
                     if (nrow(level1_controls) > 0) {
                       protective_control_groups <- setNames(level1_controls$id, level1_controls$name)
                     }
                   }
                 }

                 selectizeInput(ns("protective_control_group"), "Step 1: Select Control Group",
                              choices = c("Choose a group..." = "", protective_control_groups),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a control category...",
                                maxOptions = 50
                              ))
               })
             ),

             fluidRow(
               column(12, {
                 # Items from selected group (populated dynamically)
                 selectizeInput(ns("protective_control_item"), "Step 2: Select Specific Control",
                              choices = c("First select a group above..." = ""),
                              selected = NULL,
                              options = list(
                                placeholder = "Select a control from the group...",
                                maxOptions = 100
                              ))
               })
             ),

             # Custom entry option
             fluidRow(
               column(12,
                 checkboxInput(ns("protective_control_custom_toggle"), "Or enter a custom control not in vocabulary", value = FALSE)
               )
             ),

             conditionalPanel(
               condition = "input.protective_control_custom_toggle",
               ns = ns,
               fluidRow(
                 column(12,
                   validated_text_input(
                     id = ns("protective_control_custom_text"),
                     label = "Custom Control Name:",
                     placeholder = "Enter new control name...",
                     required = TRUE,
                     min_length = 3,
                     max_length = 100,
                     help_text = "Enter a custom protective control measure not found in the vocabulary (3-100 characters)"
                   )
                 )
               )
             ),

             fluidRow(
               column(12,
                 actionButton(ns("add_protective_control"), tagList(icon("medkit"), t("gw_add_control", current_lang)),
                            class = "btn-primary btn-block")
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
             ),

             # AI-powered suggestions for protective controls (if available)
             if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE && exists("create_ai_suggestions_ui")) {
               create_ai_suggestions_ui(
                 ns,
                 "control_protective",
                 "🤖 AI-Powered Protective Control Suggestions",
                 current_lang
               )
             } else {
               NULL
             }
      )
    ),

    br(),
    h4(t("gw_link_protective_controls_title", current_lang)),
    p(t("gw_link_protective_controls_desc", current_lang)),
    DTOutput(ns("protective_control_links"))
  )
}

# Step 7: Escalation Factors
generate_step7_ui <- function(session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity

  tagList(
    # Custom Entries Review Section
    div(class = "alert alert-info",
        h5(icon("star"), " Custom Entries Review"),
        p("The following custom entries were added during the workflow. Please review them to ensure they are correct.")
    ),

    fluidRow(
      column(12,
             h5("📋 Custom Entries Summary"),
             DTOutput(ns("custom_entries_review_table")),
             br(),
             div(class = "alert alert-warning",
                 h6(icon("info-circle"), " Note"),
                 p("Custom entries are items you added that were not in the predefined vocabulary. Please verify they are accurate and relevant to your analysis.")
             )
      )
    ),

    br(),
    hr(),
    br(),

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
generate_step8_ui <- function(session = NULL, current_lang = "en") {
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
             
             div(class = "d-grid gap-2",
                 actionButton(ns("export_excel"), 
                            tagList(icon("file-excel"), t("gw_export_excel", current_lang)),
                            class = "btn-success"),
                 
                 actionButton(ns("export_pdf"), 
                            tagList(icon("file-pdf"), t("gw_export_pdf", current_lang)),
                            class = "btn-danger"),
                 
                 actionButton(ns("load_to_main"), 
                            tagList(icon("arrow-right"), t("gw_load_main", current_lang)),
                            class = "btn-primary")
             ),
             
             br(),
             div(class = "alert alert-warning",
                 h6(t("gw_note_title", current_lang)),
                 p(t("gw_load_note", current_lang))
             )
      )
    )
  )
}

# =============================================================================
# SERVER FUNCTIONS
# =============================================================================

# Server logic for the guided workflow module
guided_workflow_server <- function(id, vocabulary_data, lang = reactive({"en"}),
                                   ai_enabled = reactive({FALSE}),
                                   ai_methods = reactive({c("jaccard")}),
                                   ai_max_suggestions = reactive({5})) {
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
  # SMART AUTOSAVE SYSTEM
  # =============================================================================

  # Reactive values for autosave
  last_saved_hash <- reactiveVal(NULL)
  debounce_timer <- reactiveVal(NULL)
  autosave_enabled <- reactiveVal(TRUE)

  # Helper: Compute state hash for change detection
  compute_state_hash <- function(state) {
    tryCatch({
      if (!requireNamespace("digest", quietly = TRUE)) {
        return(NULL)
      }
      if (!requireNamespace("jsonlite", quietly = TRUE)) {
        return(NULL)
      }

      # Extract only the parts that matter for autosave
      hashable_state <- list(
        current_step = state$current_step,
        completed_steps = state$completed_steps,
        project_data = state$project_data,
        validation_status = state$validation_status,
        workflow_complete = state$workflow_complete
      )

      json_state <- jsonlite::toJSON(hashable_state, auto_unbox = TRUE)
      hash_value <- digest::digest(json_state, algo = "md5")

      return(hash_value)
    }, error = function(e) {
      cat("⚠️ Hash computation failed:", e$message, "\n")
      return(NULL)
    })
  }

  # Helper: Perform smart autosave
  perform_smart_autosave <- function() {
    isolate({
      state <- workflow_state()
      req(state)
      req(autosave_enabled())

      # Only autosave if we're past step 1
      if (state$current_step <= 1) {
        return(NULL)
      }

      current_hash <- compute_state_hash(state)

      # Only save if state actually changed
      if (!is.null(current_hash) &&
          (is.null(last_saved_hash()) || current_hash != last_saved_hash())) {

        tryCatch({
          if (requireNamespace("jsonlite", quietly = TRUE)) {
            state_json <- jsonlite::toJSON(state, auto_unbox = TRUE)
            timestamp <- format(Sys.time(), "%H:%M:%S")

            session$sendCustomMessage("smartAutosave", list(
              state = as.character(state_json),
              timestamp = timestamp,
              hash = current_hash
            ))

            last_saved_hash(current_hash)
            cat("✅ Autosaved at", timestamp, "(hash:", substr(current_hash, 1, 8), ")\n")
          }
        }, error = function(e) {
          cat("❌ Autosave failed:", e$message, "\n")
        })
      }
    })
  }

  # Helper: Trigger autosave with debouncing
  trigger_autosave_debounced <- function(delay_ms = 3000) {
    # Update debounce timer
    debounce_timer(Sys.time())

    # Schedule the autosave check
    invalidateLater(delay_ms, session)

    observe({
      timer_value <- debounce_timer()
      req(timer_value)

      time_diff <- difftime(Sys.time(), timer_value, units = "secs")

      # If enough time has passed since last change, perform autosave
      if (as.numeric(time_diff) >= (delay_ms / 1000)) {
        perform_smart_autosave()
        debounce_timer(NULL)  # Clear timer
      }
    }, priority = -1)  # Low priority to run after other observers
  }

  # Watch for workflow state changes and trigger autosave
  observe({
    state <- workflow_state()
    req(state)
    req(autosave_enabled())

    # Trigger debounced autosave on any state change
    trigger_autosave_debounced(delay_ms = 3000)
  }, priority = -1)  # Low priority to run after other state updates

  # =============================================================================
  # SESSION RESTORE
  # =============================================================================

  # On session start, check for autosaved state
  observeEvent(session$clientData$url_search, {
    if (requireNamespace("jsonlite", quietly = TRUE)) {
      session$sendCustomMessage("loadFromLocalStorage", list(
        key = "bowtie_workflow_autosave",
        inputId = "restored_workflow_state"
      ))
    }
  }, once = TRUE, priority = 100)  # High priority to run early

  # Handle restored state
  observeEvent(input$restored_workflow_state, {
    req(input$restored_workflow_state)

    tryCatch({
      if (requireNamespace("jsonlite", quietly = TRUE)) {
        restored <- jsonlite::fromJSON(input$restored_workflow_state, simplifyVector = FALSE)

        # Validate restored state
        if (is.list(restored) && "current_step" %in% names(restored)) {
          # Show restore dialog
          showModal(modalDialog(
            title = tagList(icon("history"), " Restore Previous Session?"),
            tagList(
              p(HTML(paste0(
                "A previous workflow session was found.<br>",
                "<strong>Step ", restored$current_step, " of ", restored$total_steps, "</strong>",
                if (!is.null(restored$project_data$project_name) && nchar(restored$project_data$project_name) > 0) {
                  paste0("<br>Project: <em>", restored$project_data$project_name, "</em>")
                } else { "" }
              ))),
              hr(),
              p("Would you like to restore this session or start fresh?")
            ),
            footer = tagList(
              actionButton("restore_yes", "Restore Session", class = "btn-primary", icon = icon("undo")),
              actionButton("restore_no", "Start Fresh", class = "btn-secondary", icon = icon("file"))
            ),
            size = "m",
            easyClose = FALSE
          ))
        }
      }
    }, error = function(e) {
      cat("⚠️ Error processing restored state:", e$message, "\n")
    })
  }, once = TRUE, ignoreNULL = TRUE)

  # Handle restore confirmation
  observeEvent(input$restore_yes, {
    req(input$restored_workflow_state)

    tryCatch({
      if (requireNamespace("jsonlite", quietly = TRUE)) {
        restored <- jsonlite::fromJSON(input$restored_workflow_state, simplifyVector = FALSE)

        # Convert list back to proper structure
        restored_state <- init_workflow_state()  # Start with default

        # Merge restored data
        for (name in names(restored)) {
          if (name %in% names(restored_state)) {
            restored_state[[name]] <- restored[[name]]
          }
        }

        # Update workflow state
        workflow_state(restored_state)

        # Update hash to current state
        last_saved_hash(compute_state_hash(restored_state))

        showNotification(
          paste("✅ Session restored successfully! Resuming at Step", restored_state$current_step),
          type = "message",
          duration = 5
        )

        cat("✅ Workflow session restored from autosave\n")
      }
    }, error = function(e) {
      showNotification(
        paste("❌ Error restoring session:", e$message),
        type = "error",
        duration = 10
      )
      cat("❌ Error restoring session:", e$message, "\n")
    })

    removeModal()
  })

  # Handle start fresh
  observeEvent(input$restore_no, {
    # Clear autosave from localStorage
    session$sendCustomMessage("clearAutosave", list())

    showNotification(
      "Starting fresh workflow session",
      type = "message",
      duration = 3
    )

    removeModal()
  })

  # =============================================================================
  # AI-POWERED SUGGESTIONS INITIALIZATION
  # =============================================================================

  # Initialize AI suggestion handlers if available
  if (exists("WORKFLOW_AI_AVAILABLE") && WORKFLOW_AI_AVAILABLE) {
    tryCatch({
      # Source the server-side suggestion handlers
      if (file.exists("guided_workflow_ai_suggestions_server.R")) {
        source("guided_workflow_ai_suggestions_server.R", local = TRUE)

        # Initialize handlers with workflow state and vocabulary data
        init_ai_suggestion_handlers(
          input = input,
          output = output,
          session = session,
          workflow_state = workflow_state,  # Pass reactive, not value
          vocabulary_data_reactive = vocab_data,
          ai_enabled = ai_enabled,  # User setting from settings panel
          ai_methods = ai_methods,  # Selected methods (jaccard, keyword, causal)
          ai_max_suggestions = ai_max_suggestions  # Max number of suggestions
        )

        cat("✅ AI suggestions module ready (controlled by settings)\n")
      }
    }, error = function(e) {
      cat("⚠️ Failed to initialize AI suggestions:", e$message, "\n")
    })
  }

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
      # Call with session parameter and vocabulary_data for steps that need it
      if (state$current_step %in% c(3, 4, 5, 6)) {
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
  
  # Create a reactive for just the current step
  # This prevents triggering when other parts of workflow_state change
  current_step <- reactive({
    state <- workflow_state()
    if (!is.null(state)) state$current_step else 0
  })

  # Update selectize choices when entering step 3
  # ONLY triggers when current_step changes, not when activities/pressures/etc change
  observeEvent(current_step(), {
    step <- current_step()

    if (step == 3) {
      cat("🔍 [VOCAB CHOICES] Step 3 entered - updating vocabulary choices (ONLY ON STEP CHANGE)\n")

      # Update activity choices
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities)) {
        activity_choices <- vocabulary_data$activities$name
        if (length(activity_choices) > 0) {
          cat("📝 [VOCAB CHOICES] Updating activity_search with", length(activity_choices), "choices\n")
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
          cat("📝 [VOCAB CHOICES] Updating pressure_search with", length(pressure_choices), "choices\n")
          updateSelectizeInput(session, "pressure_search",
                             choices = pressure_choices,
                             server = TRUE,
                             selected = character(0))
        }
      }

      cat("📝 [VOCAB CHOICES] Vocabulary choices updated. Will NOT trigger again until step number changes.\n")
    }
  }, ignoreInit = FALSE)
  
  # Handle "Next" button click
  observeEvent(input$next_step, {
    state <- workflow_state()
    
    # Validate current step before proceeding
    validation_result <- validate_current_step(state, input)
    if (!validation_result$is_valid) {
      showNotification(validation_result$message, type = "error", duration = 5)
      return()
    }
    
    # Save data from current step
    state <- save_step_data(state, input)
    
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
      state$current_step <- state$current_step - 1
      workflow_state(state)
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
  # STEP 3: ACTIVITY & PRESSURE MANAGEMENT
  # =============================================================================
  
  # Reactive values to store selected activities and pressures
  selected_activities <- reactiveVal(list())
  selected_pressures <- reactiveVal(list())

  # Reactive values to track custom entries (not in vocabulary)
  custom_entries <- reactiveVal(list(
    activities = character(0),
    pressures = character(0),
    preventive_controls = character(0),
    consequences = character(0),
    protective_controls = character(0)
  ))

  # =============================================================================
  # HIERARCHICAL SELECTION: Update item choices when group is selected
  # =============================================================================

  # Update activity items when group is selected
  observeEvent(input$activity_group, {
    req(input$activity_group)
    if (nchar(input$activity_group) > 0 && !is.null(vocabulary_data$activities)) {
      # Get children of selected group
      children <- vocabulary_data$activities[
        grepl(paste0("^", gsub("\\.", "\\\\.", input$activity_group), "\\."), vocabulary_data$activities$id),
      ]
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "activity_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Update pressure items when group is selected
  observeEvent(input$pressure_group, {
    req(input$pressure_group)
    if (nchar(input$pressure_group) > 0 && !is.null(vocabulary_data$pressures)) {
      # Get children of selected group
      children <- vocabulary_data$pressures[
        grepl(paste0("^", gsub("\\.", "\\\\.", input$pressure_group), "\\."), vocabulary_data$pressures$id),
      ]
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "pressure_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Update preventive control items when group is selected
  observeEvent(input$preventive_control_group, {
    req(input$preventive_control_group)
    if (nchar(input$preventive_control_group) > 0 && !is.null(vocabulary_data$controls)) {
      # Get children of selected group
      children <- vocabulary_data$controls[
        grepl(paste0("^", gsub("\\.", "\\\\.", input$preventive_control_group), "\\."), vocabulary_data$controls$id),
      ]
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "preventive_control_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Update consequence items when group is selected
  observeEvent(input$consequence_group, {
    req(input$consequence_group)
    if (nchar(input$consequence_group) > 0 && !is.null(vocabulary_data$consequences)) {
      # Get children of selected group
      children <- vocabulary_data$consequences[
        grepl(paste0("^", gsub("\\.", "\\\\.", input$consequence_group), "\\."), vocabulary_data$consequences$id),
      ]
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "consequence_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Update protective control items when group is selected
  observeEvent(input$protective_control_group, {
    req(input$protective_control_group)
    if (nchar(input$protective_control_group) > 0 && !is.null(vocabulary_data$controls)) {
      # Get children of selected group
      children <- vocabulary_data$controls[
        grepl(paste0("^", gsub("\\.", "\\\\.", input$protective_control_group), "\\."), vocabulary_data$controls$id),
      ]
      if (nrow(children) > 0) {
        item_choices <- setNames(children$name, children$name)
        updateSelectizeInput(session, "protective_control_item",
                           choices = c("Choose an item..." = "", item_choices),
                           selected = NULL)
      }
    }
  })

  # Sync reactive values with workflow state when entering Step 3
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == 3) {
      cat("\n🔄 [STATE SYNC] Step 3 state sync triggered\n")

      # Load activities from state if available
      if (!is.null(state$project_data$activities) && length(state$project_data$activities) > 0) {
        # Ensure it's a character vector
        activities <- as.character(state$project_data$activities)
        cat("🔄 [STATE SYNC] Loading", length(activities), "activities from state:", paste(activities, collapse = ", "), "\n")
        selected_activities(activities)
      } else {
        cat("🔄 [STATE SYNC] No activities in state - clearing list\n")
        selected_activities(list())
      }

      # Load pressures from state if available
      if (!is.null(state$project_data$pressures) && length(state$project_data$pressures) > 0) {
        # Ensure it's a character vector
        pressures <- as.character(state$project_data$pressures)
        cat("🔄 [STATE SYNC] Loading", length(pressures), "pressures from state:", paste(pressures, collapse = ", "), "\n")
        selected_pressures(pressures)
      } else {
        cat("🔄 [STATE SYNC] No pressures in state - clearing list\n")
        selected_pressures(list())
      }

      cat("🔄 [STATE SYNC] State sync completed. NOT touching input fields.\n")
    }
  })
  
  # Handle "Add Activity" button
  observeEvent(input$add_activity, {
    cat("\n📝 [ADD ACTIVITY] Button clicked!\n")
    cat("📝 [ADD ACTIVITY] Current activity_group input:", input$activity_group, "\n")
    cat("📝 [ADD ACTIVITY] Current activity_item input:", input$activity_item, "\n")

    # Determine if using custom entry or hierarchical selection
    activity_name <- NULL
    is_custom <- FALSE

    if (!is.null(input$activity_custom_toggle) && input$activity_custom_toggle) {
      # Custom entry mode
      activity_name <- input$activity_custom_text
      is_custom <- TRUE
      cat("📝 [ADD ACTIVITY] Using CUSTOM entry mode:", activity_name, "\n")
    } else {
      # Hierarchical selection mode
      activity_name <- input$activity_item
      cat("📝 [ADD ACTIVITY] Using HIERARCHICAL selection mode:", activity_name, "\n")
    }

    # Validate: not NULL, not NA, not empty after trimming
    if (!is.null(activity_name) && !is.na(activity_name) &&
        nchar(trimws(activity_name)) > 0) {
      # Get current list
      current <- selected_activities()
      cat("📝 [ADD ACTIVITY] Current activities list:", paste(current, collapse = ", "), "\n")

      # Check if already added
      if (!activity_name %in% current) {
        current <- c(current, activity_name)
        selected_activities(current)
        cat("📝 [ADD ACTIVITY] Updated activities list:", paste(current, collapse = ", "), "\n")

        # Track custom entries
        if (is_custom) {
          custom_list <- custom_entries()
          custom_list$activities <- c(custom_list$activities, activity_name)
          custom_entries(custom_list)
          showNotification(paste("✅ Added custom activity:", activity_name, "(marked for review)"), type = "message", duration = 3)
        } else {
          showNotification(paste(t("gw_added_activity", lang()), activity_name), type = "message", duration = 2)
        }

        cat("📝 [ADD ACTIVITY] Updating workflow state...\n")
        # Update workflow state
        state <- workflow_state()
        state$project_data$activities <- current
        state$project_data$custom_entries <- custom_entries()
        workflow_state(state)
        cat("📝 [ADD ACTIVITY] Workflow state updated successfully\n")

        cat("📝 [ADD ACTIVITY] Clearing activity_item input...\n")
        # Clear inputs
        updateSelectizeInput(session, session$ns("activity_item"), selected = character(0))
        if (is_custom) {
          updateTextInput(session, session$ns("activity_custom_text"), value = "")
        }
        cat("📝 [ADD ACTIVITY] Input cleared. NOT clearing activity_group.\n")
        cat("📝 [ADD ACTIVITY] Completed successfully!\n")
      } else {
        cat("📝 [ADD ACTIVITY] Activity already exists:", activity_name, "\n")
        showNotification(t("gw_activity_exists", lang()), type = "warning", duration = 2)
      }
    } else {
      cat("📝 [ADD ACTIVITY] Validation failed - empty or invalid input\n")
      showNotification("Please select an activity or enter a custom name", type = "warning", duration = 2)
    }
  })
  
  # Handle "Add Pressure" button
  observeEvent(input$add_pressure, {
    # Determine if using custom entry or hierarchical selection
    pressure_name <- NULL
    is_custom <- FALSE

    if (!is.null(input$pressure_custom_toggle) && input$pressure_custom_toggle) {
      # Custom entry mode
      pressure_name <- input$pressure_custom_text
      is_custom <- TRUE
    } else {
      # Hierarchical selection mode
      pressure_name <- input$pressure_item
    }

    # Validate: not NULL, not NA, not empty after trimming
    if (!is.null(pressure_name) && !is.na(pressure_name) &&
        nchar(trimws(pressure_name)) > 0) {
      # Get current list
      current <- selected_pressures()

      # Check if already added
      if (!pressure_name %in% current) {
        current <- c(current, pressure_name)
        selected_pressures(current)

        # Track custom entries
        if (is_custom) {
          custom_list <- custom_entries()
          custom_list$pressures <- c(custom_list$pressures, pressure_name)
          custom_entries(custom_list)
          showNotification(paste("✅ Added custom pressure:", pressure_name, "(marked for review)"), type = "message", duration = 3)
        } else {
          showNotification(paste(t("gw_added_pressure", lang()), pressure_name), type = "message", duration = 2)
        }

        # Update workflow state
        state <- workflow_state()
        state$project_data$pressures <- current
        state$project_data$custom_entries <- custom_entries()
        workflow_state(state)

        # Clear inputs
        updateSelectizeInput(session, session$ns("pressure_item"), selected = character(0))
        if (is_custom) {
          updateTextInput(session, session$ns("pressure_custom_text"), value = "")
        }
      } else {
        showNotification(t("gw_pressure_exists", lang()), type = "warning", duration = 2)
      }
    } else {
      showNotification("Please select a pressure or enter a custom name", type = "warning", duration = 2)
    }
  })
  
  # Render selected activities table
  output$selected_activities_table <- renderDT({
    activities <- selected_activities()
    
    if (length(activities) == 0) {
      # Return empty data frame with proper column name
      dt_data <- data.frame(Activity = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with activities
      dt_data <- data.frame(Activity = activities, stringsAsFactors = FALSE)
    }
    
    # Render with DT package - explicitly use DT::datatable
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 5,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })
  
  # Render selected pressures table
  output$selected_pressures_table <- renderDT({
    pressures <- selected_pressures()
    
    if (length(pressures) == 0) {
      # Return empty data frame with proper column name
      dt_data <- data.frame(Pressure = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with pressures
      dt_data <- data.frame(Pressure = pressures, stringsAsFactors = FALSE)
    }
    
    # Render with DT package - explicitly use DT::datatable
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 5,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't'
      ),
      rownames = FALSE,
      selection = 'none',
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
    # Determine if using custom entry or hierarchical selection
    control_name <- NULL
    is_custom <- FALSE

    if (!is.null(input$preventive_control_custom_toggle) && input$preventive_control_custom_toggle) {
      # Custom entry mode
      control_name <- input$preventive_control_custom_text
      is_custom <- TRUE
    } else {
      # Hierarchical selection mode
      control_name <- input$preventive_control_item
    }

    # Validate: not NULL, not NA, not empty after trimming
    if (!is.null(control_name) && !is.na(control_name) &&
        nchar(trimws(control_name)) > 0) {
      # Get current list
      current <- selected_preventive_controls()

      # Check if already added
      if (!control_name %in% current) {
        current <- c(current, control_name)
        selected_preventive_controls(current)

        # Track custom entries
        if (is_custom) {
          custom_list <- custom_entries()
          custom_list$preventive_controls <- c(custom_list$preventive_controls, control_name)
          custom_entries(custom_list)
          showNotification(paste("✅ Added custom preventive control:", control_name, "(marked for review)"), type = "message", duration = 3)
        } else {
          showNotification(paste(t("gw_added_control", lang()), control_name), type = "message", duration = 2)
        }

        # Update workflow state
        state <- workflow_state()
        state$project_data$preventive_controls <- current
        state$project_data$custom_entries <- custom_entries()
        workflow_state(state)

        # Clear inputs
        updateSelectizeInput(session, session$ns("preventive_control_item"), selected = character(0))
        if (is_custom) {
          updateTextInput(session, session$ns("preventive_control_custom_text"), value = "")
        }
      } else {
        showNotification(t("gw_control_exists", lang()), type = "warning", duration = 2)
      }
    } else {
      showNotification("Please select a control or enter a custom name", type = "warning", duration = 2)
    }
  })
  
  # Render selected preventive controls table
  output$selected_preventive_controls_table <- renderDT({
    controls <- selected_preventive_controls()
    
    if (length(controls) == 0) {
      # Return empty data frame with proper column name
      dt_data <- data.frame(Control = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with controls
      dt_data <- data.frame(Control = controls, stringsAsFactors = FALSE)
    }
    
    # Render with DT package - explicitly use DT::datatable
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't'
      ),
      rownames = FALSE,
      selection = 'none',
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
    # Determine if using custom entry or hierarchical selection
    consequence_name <- NULL
    is_custom <- FALSE

    if (!is.null(input$consequence_custom_toggle) && input$consequence_custom_toggle) {
      # Custom entry mode
      consequence_name <- input$consequence_custom_text
      is_custom <- TRUE
    } else {
      # Hierarchical selection mode
      consequence_name <- input$consequence_item
    }

    # Validate: not NULL, not NA, not empty after trimming
    if (!is.null(consequence_name) && !is.na(consequence_name) &&
        nchar(trimws(consequence_name)) > 0) {
      # Get current list
      current <- selected_consequences()

      # Check if already added
      if (!consequence_name %in% current) {
        current <- c(current, consequence_name)
        selected_consequences(current)

        # Track custom entries
        if (is_custom) {
          custom_list <- custom_entries()
          custom_list$consequences <- c(custom_list$consequences, consequence_name)
          custom_entries(custom_list)
          showNotification(paste("✅ Added custom consequence:", consequence_name, "(marked for review)"), type = "message", duration = 3)
        } else {
          showNotification(paste(t("gw_added_consequence", lang()), consequence_name), type = "message", duration = 2)
        }

        # Update workflow state
        state <- workflow_state()
        state$project_data$consequences <- current
        state$project_data$custom_entries <- custom_entries()
        workflow_state(state)

        # Clear inputs
        updateSelectizeInput(session, session$ns("consequence_item"), selected = character(0))
        if (is_custom) {
          updateTextInput(session, session$ns("consequence_custom_text"), value = "")
        }
      } else {
        showNotification(t("gw_consequence_exists", lang()), type = "warning", duration = 2)
      }
    } else {
      showNotification("Please select a consequence or enter a custom name", type = "warning", duration = 2)
    }
  })
  
  # Render selected consequences table
  output$selected_consequences_table <- renderDT({
    consequences <- selected_consequences()
    
    if (length(consequences) == 0) {
      # Return empty data frame with proper column name
      dt_data <- data.frame(Consequence = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with consequences
      dt_data <- data.frame(Consequence = consequences, stringsAsFactors = FALSE)
    }
    
    # Render with DT package - explicitly use DT::datatable
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't'
      ),
      rownames = FALSE,
      selection = 'none',
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
    # Determine if using custom entry or hierarchical selection
    control_name <- NULL
    is_custom <- FALSE

    if (!is.null(input$protective_control_custom_toggle) && input$protective_control_custom_toggle) {
      # Custom entry mode
      control_name <- input$protective_control_custom_text
      is_custom <- TRUE
    } else {
      # Hierarchical selection mode
      control_name <- input$protective_control_item
    }

    # Validate: not NULL, not NA, not empty after trimming
    if (!is.null(control_name) && !is.na(control_name) &&
        nchar(trimws(control_name)) > 0) {
      # Get current list
      current <- selected_protective_controls()

      # Check if already added
      if (!control_name %in% current) {
        current <- c(current, control_name)
        selected_protective_controls(current)

        # Track custom entries
        if (is_custom) {
          custom_list <- custom_entries()
          custom_list$protective_controls <- c(custom_list$protective_controls, control_name)
          custom_entries(custom_list)
          showNotification(paste("✅ Added custom protective control:", control_name, "(marked for review)"), type = "message", duration = 3)
        } else {
          showNotification(paste(t("gw_added_protective", lang()), control_name), type = "message", duration = 2)
        }

        # Update workflow state
        state <- workflow_state()
        state$project_data$protective_controls <- current
        state$project_data$custom_entries <- custom_entries()
        workflow_state(state)

        # Clear inputs
        updateSelectizeInput(session, session$ns("protective_control_item"), selected = character(0))
        if (is_custom) {
          updateTextInput(session, session$ns("protective_control_custom_text"), value = "")
        }
      } else {
        showNotification(t("gw_control_exists", lang()), type = "warning", duration = 2)
      }
    } else {
      showNotification("Please select a control or enter a custom name", type = "warning", duration = 2)
    }
  })
  
  # Render selected protective controls table
  output$selected_protective_controls_table <- renderDT({
    controls <- selected_protective_controls()
    
    if (length(controls) == 0) {
      # Return empty data frame with proper column name
      dt_data <- data.frame(Control = character(0), stringsAsFactors = FALSE)
    } else {
      # Create data frame with controls
      dt_data <- data.frame(Control = controls, stringsAsFactors = FALSE)
    }
    
    # Render with DT package - explicitly use DT::datatable
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't'
      ),
      rownames = FALSE,
      selection = 'none',
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

      # Load custom entries from state if available
      if (!is.null(state$project_data$custom_entries)) {
        custom_entries(state$project_data$custom_entries)
      }
    }
  })

  # Render custom entries review table
  output$custom_entries_review_table <- renderDT({
    custom_list <- custom_entries()

    # Create a data frame with all custom entries
    entries_data <- data.frame(
      Category = character(0),
      Item = character(0),
      stringsAsFactors = FALSE
    )

    if (length(custom_list$activities) > 0) {
      entries_data <- rbind(entries_data, data.frame(
        Category = rep("Activity", length(custom_list$activities)),
        Item = custom_list$activities,
        stringsAsFactors = FALSE
      ))
    }

    if (length(custom_list$pressures) > 0) {
      entries_data <- rbind(entries_data, data.frame(
        Category = rep("Pressure", length(custom_list$pressures)),
        Item = custom_list$pressures,
        stringsAsFactors = FALSE
      ))
    }

    if (length(custom_list$preventive_controls) > 0) {
      entries_data <- rbind(entries_data, data.frame(
        Category = rep("Preventive Control", length(custom_list$preventive_controls)),
        Item = custom_list$preventive_controls,
        stringsAsFactors = FALSE
      ))
    }

    if (length(custom_list$consequences) > 0) {
      entries_data <- rbind(entries_data, data.frame(
        Category = rep("Consequence", length(custom_list$consequences)),
        Item = custom_list$consequences,
        stringsAsFactors = FALSE
      ))
    }

    if (length(custom_list$protective_controls) > 0) {
      entries_data <- rbind(entries_data, data.frame(
        Category = rep("Protective Control", length(custom_list$protective_controls)),
        Item = custom_list$protective_controls,
        stringsAsFactors = FALSE
      ))
    }

    if (nrow(entries_data) == 0) {
      entries_data <- data.frame(
        Category = "No custom entries",
        Item = "All items were selected from the vocabulary",
        stringsAsFactors = FALSE
      )
    }

    # Render with DT package
    DT::datatable(
      entries_data,
      options = list(
        pageLength = 10,
        searching = TRUE,
        lengthChange = FALSE,
        info = TRUE,
        dom = 't'
      ),
      rownames = FALSE,
      selection = 'none',
      class = 'cell-border stripe'
    )
  })

  # Handle "Add Escalation Factor" button
  observeEvent(input$add_escalation_factor, {
    factor_name <- input$escalation_factor_input

    # Validate: not NULL, not NA, not empty after trimming
    if (!is.null(factor_name) && !is.na(factor_name) &&
        nchar(trimws(factor_name)) > 0) {
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
        updateTextInput(session, session$ns("escalation_factor_input"), value = "")
      } else {
        showNotification(t("gw_escalation_exists", lang()), type = "warning", duration = 2)
      }
    }
  })
  
  # Render selected escalation factors table
  output$selected_escalation_factors_table <- renderDT({
    factors <- selected_escalation_factors()
    
    if (length(factors) == 0) {
      # Return empty data frame with proper column name
      dt_data <- data.frame(`Escalation Factor` = character(0), stringsAsFactors = FALSE, check.names = FALSE)
    } else {
      # Create data frame with factors
      dt_data <- data.frame(`Escalation Factor` = factors, stringsAsFactors = FALSE, check.names = FALSE)
    }
    
    # Render with DT package - explicitly use DT::datatable
    DT::datatable(
      dt_data,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE,
        dom = 't'
      ),
      rownames = FALSE,
      selection = 'none',
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

    if (template_id != "") {
      template_data <- WORKFLOW_CONFIG$templates[[template_id]]

      if (!is.null(template_data)) {
        # Update Step 1 (Project Setup) fields
        updateTextInput(session, "project_name", value = template_data$project_name)
        updateTextInput(session, "project_location", value = template_data$project_location)
        updateSelectInput(session, "project_type", selected = template_data$project_type)
        updateTextAreaInput(session, "project_description", value = template_data$project_description)

        # Update Step 2 (Central Problem Definition) fields
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

        showNotification(
          paste0("✅ ", t("gw_applied_template", lang()), template_data$name,
                 " - Project Setup and Central Problem have been pre-filled!"),
          type = "message",
          duration = 5
        )
      }
    }
  })

  # Populate Step 2 fields from template data when navigating to Step 2
  observe({
    state <- workflow_state()
    req(state)
    req(state$current_step)

    # When user navigates to Step 2, populate fields from stored template data
    if (state$current_step == 2 && !is.null(state$project_data$template_applied)) {
      # Small delay to ensure Step 2 UI is fully rendered
      shinyjs::delay(100, {
        # Populate problem statement if available
        if (!is.null(state$project_data$problem_statement) && state$project_data$problem_statement != "") {
          updateTextInput(session, "problem_statement", value = state$project_data$problem_statement)
        }

        # Populate problem category if available
        if (!is.null(state$project_data$problem_category) && state$project_data$problem_category != "") {
          updateSelectInput(session, "problem_category", selected = state$project_data$problem_category)
        }

        # Populate problem details if available
        if (!is.null(state$project_data$problem_details) && state$project_data$problem_details != "") {
          updateTextAreaInput(session, "problem_details", value = state$project_data$problem_details)
        }

        # Populate problem scale if available
        if (!is.null(state$project_data$problem_scale) && state$project_data$problem_scale != "") {
          updateSelectInput(session, "problem_scale", selected = state$project_data$problem_scale)
        }

        # Populate problem urgency if available
        if (!is.null(state$project_data$problem_urgency) && state$project_data$problem_urgency != "") {
          updateSelectInput(session, "problem_urgency", selected = state$project_data$problem_urgency)
        }
      })
    }
  })

  # =============================================================================
  # FINALIZATION & EXPORT
  # =============================================================================
  
  # Handle workflow finalization
  observeEvent(input$finalize_workflow, {
    state <- workflow_state()

    # Final validation
    validation_result <- validate_current_step(state, input)
    if (!validation_result$is_valid) {
      showNotification(validation_result$message, type = "error")
      return()
    }

    # Save final step data
    state <- save_step_data(state, input)

    # Mark workflow as complete
    state$workflow_complete <- TRUE

    # Convert workflow data to main application format
    converted_data <- convert_to_main_data_format(state$project_data)
    state$converted_main_data <- converted_data

    workflow_state(state)

    # Clear autosave - workflow is complete, no need to keep autosave
    session$sendCustomMessage("clearAutosave", list())

    showNotification("🎉 Workflow complete! Data is ready for visualization.", type = "message")
  })

  # =============================================================================
  # EXPORT HANDLERS FOR STEP 8
  # =============================================================================

  # Handler for Export to Excel
  observeEvent(input$export_excel, {
    state <- workflow_state()

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      showNotification(
        "Please complete the workflow first by clicking 'Complete Workflow'.",
        type = "warning",
        duration = 4
      )
      return()
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

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      showNotification(
        "Please complete the workflow first by clicking 'Complete Workflow'.",
        type = "warning",
        duration = 4
      )
      return()
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

    # Check if workflow is complete
    if (!isTRUE(state$workflow_complete)) {
      showNotification(
        "Please complete the workflow first by clicking 'Complete Workflow'.",
        type = "warning",
        duration = 4
      )
      return()
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
    
    tryCatch({
      loaded_state <- readRDS(file$datapath)
      
      # Basic validation of loaded state
      if (is.list(loaded_state) && "current_step" %in% names(loaded_state)) {
        
        # Migrate old data structures if needed
        if (!is.null(loaded_state$project_data)) {
          # Ensure activities and pressures are character vectors, not data frames
          if (!is.null(loaded_state$project_data$activities)) {
            if (is.data.frame(loaded_state$project_data$activities)) {
              # Extract from old data frame format
              if (t("gw_col_activity", current_lang) %in% names(loaded_state$project_data$activities)) {
                loaded_state$project_data$activities <- loaded_state$project_data$activities$Activity
              } else if ("Actvity" %in% names(loaded_state$project_data$activities)) {
                # Fix old typo
                loaded_state$project_data$activities <- loaded_state$project_data$activities$Actvity
              }
            }
            # Convert to character vector
            loaded_state$project_data$activities <- as.character(loaded_state$project_data$activities)
          }
          
          if (!is.null(loaded_state$project_data$pressures)) {
            if (is.data.frame(loaded_state$project_data$pressures)) {
              # Extract from old data frame format
              if (t("gw_col_pressure", current_lang) %in% names(loaded_state$project_data$pressures)) {
                loaded_state$project_data$pressures <- loaded_state$project_data$pressures$Pressure
              }
            }
            # Convert to character vector
            loaded_state$project_data$pressures <- as.character(loaded_state$project_data$pressures)
          }
          
          # Ensure preventive controls are character vectors
          if (!is.null(loaded_state$project_data$preventive_controls)) {
            if (is.data.frame(loaded_state$project_data$preventive_controls)) {
              # Extract from old data frame format
              if (t("gw_col_control", current_lang) %in% names(loaded_state$project_data$preventive_controls)) {
                loaded_state$project_data$preventive_controls <- loaded_state$project_data$preventive_controls$Control
              }
            }
            # Convert to character vector
            loaded_state$project_data$preventive_controls <- as.character(loaded_state$project_data$preventive_controls)
          }
          
          # Ensure consequences are character vectors
          if (!is.null(loaded_state$project_data$consequences)) {
            if (is.data.frame(loaded_state$project_data$consequences)) {
              # Extract from old data frame format
              if (t("gw_col_consequence", current_lang) %in% names(loaded_state$project_data$consequences)) {
                loaded_state$project_data$consequences <- loaded_state$project_data$consequences$Consequence
              }
            }
            # Convert to character vector
            loaded_state$project_data$consequences <- as.character(loaded_state$project_data$consequences)
          }
          
          # Ensure protective controls are character vectors
          if (!is.null(loaded_state$project_data$protective_controls)) {
            if (is.data.frame(loaded_state$project_data$protective_controls)) {
              # Extract from old data frame format
              if (t("gw_col_control", current_lang) %in% names(loaded_state$project_data$protective_controls)) {
                loaded_state$project_data$protective_controls <- loaded_state$project_data$protective_controls$Control
              }
            }
            # Convert to character vector
            loaded_state$project_data$protective_controls <- as.character(loaded_state$project_data$protective_controls)
          }
          
          # Ensure escalation factors are character vectors
          if (!is.null(loaded_state$project_data$escalation_factors)) {
            if (is.data.frame(loaded_state$project_data$escalation_factors)) {
              # Extract from old data frame format
              if (t("gw_col_escalation", current_lang) %in% names(loaded_state$project_data$escalation_factors)) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors$`Escalation Factor`
              } else if ("escalation_factor" %in% names(loaded_state$project_data$escalation_factors)) {
                loaded_state$project_data$escalation_factors <- loaded_state$project_data$escalation_factors$escalation_factor
              }
            }
            # Convert to character vector
            loaded_state$project_data$escalation_factors <- as.character(loaded_state$project_data$escalation_factors)
          }
        }
        
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

      # Optionally clear autosave after successful manual save
      # (User has a manual copy now, so autosave is less critical)
      # session$sendCustomMessage("clearAutosave", list())

      showNotification(
        "✅ Workflow saved successfully! Autosave will continue protecting your work.",
        type = "message",
        duration = 3
      )
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
validate_current_step <- function(state, input) {
  step <- state$current_step
  
  # Basic validation based on step number
  validation <- switch(as.character(step),
    "1" = {
      # Step 1: Project Setup
      project_name <- input$project_name
      if (is.null(project_name) || nchar(trimws(project_name)) == 0) {
        list(is_valid = FALSE, message = t("gw_enter_project_name", current_lang))
      } else {
        list(is_valid = TRUE, message = "")
      }
    },
    "2" = {
      # Step 2: Central Problem
      problem <- input$problem_statement
      if (is.null(problem) || nchar(trimws(problem)) == 0) {
        list(is_valid = FALSE, message = t("gw_define_central_problem", current_lang))
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
    # Save project setup data
    state$project_data$project_name <- input$project_name
    state$project_data$project_location <- input$project_location
    state$project_data$project_type <- input$project_type
    state$project_data$project_description <- input$project_description
    state$project_name <- input$project_name  # Also save at top level
  } else if (step == 2) {
    # Save central problem data
    state$project_data$problem_statement <- input$problem_statement
    state$project_data$problem_category <- input$problem_category
    state$project_data$problem_details <- input$problem_details
    state$project_data$problem_scale <- input$problem_scale
    state$project_data$problem_urgency <- input$problem_urgency
    state$central_problem <- input$problem_statement  # Also save at top level
  } else if (step == 3) {
    # Save activities and pressures data
    # Note: The data is already being saved in real-time by the Add Activity/Pressure handlers
    # We just need to ensure it's preserved in the state
    # Don't overwrite with empty values
    if (is.null(state$project_data$activities)) {
      state$project_data$activities <- list()
    }
    if (is.null(state$project_data$pressures)) {
      state$project_data$pressures <- list()
    }
  } else if (step == 4) {
    # Save preventive controls data
    # Note: The data is already being saved in real-time by the Add Control handler
    # We just need to ensure it's preserved in the state
    if (is.null(state$project_data$preventive_controls)) {
      state$project_data$preventive_controls <- list()
    }
  } else if (step == 5) {
    # Save consequences data
    # Note: The data is already being saved in real-time by the Add Consequence handler
    # We just need to ensure it's preserved in the state
    if (is.null(state$project_data$consequences)) {
      state$project_data$consequences <- list()
    }
  } else if (step == 6) {
    # Save protective controls data
    # Note: The data is already being saved in real-time by the Add Protective Control handler
    # We just need to ensure it's preserved in the state
    if (is.null(state$project_data$protective_controls)) {
      state$project_data$protective_controls <- list()
    }
  } else if (step == 7) {
    # Save escalation factors data
    # Note: The data is already being saved in real-time by the Add Escalation Factor handler
    # We just need to ensure it's preserved in the state
    if (is.null(state$project_data$escalation_factors)) {
      state$project_data$escalation_factors <- list()
    }
  }
  # Step 8 is review only - no data to save
  
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
