# =============================================================================
# guided_workflow_config.R
# Workflow Configuration and State Management
# =============================================================================
# Part of: Guided Workflow System modularization
# Version: 5.4.0
# Date: January 2026
# Description: Contains WORKFLOW_CONFIG, templates, and state management functions
# =============================================================================

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
    ),

    # ==========================================================================
    # OFFSHORE WIND FARM SCENARIO WITH NATURE INCLUSIVE DESIGN (NID)
    # ==========================================================================
    offshore_wind_biodiversity = list(
      name = "Offshore Wind Farm Biodiversity & Fishery Impact Assessment",
      project_name = "Offshore Wind Farm Impact on Marine Biodiversity and Fishery",
      project_location = "North Sea / Baltic Sea / Mediterranean Sea - Offshore Wind Farm Zone",
      project_type = "marine",
      project_description = paste0(
        "Comprehensive assessment of offshore wind energy development impacts on marine ecosystems, ",
        "fish populations, seabed habitats, marine mammals, seabirds, and commercial/artisanal fisheries. ",
        "Includes evaluation of Nature Inclusive Design (NID) measures for biodiversity enhancement ",
        "and ecosystem restoration within wind farm areas. Covers construction, operation, and ",
        "decommissioning phases with focus on both bottom-fixed (monopile, jacket) and floating ",
        "wind turbine installations."
      ),
      central_problem = "Offshore wind farm impacts on marine biodiversity and fishery resources",
      problem_category = "ecosystem_services",
      problem_details = paste0(
        "Assessment of multi-phase impacts from offshore wind energy development including: ",
        "(1) Construction phase - pile driving noise, seabed disturbance, sediment suspension, vessel traffic; ",
        "(2) Operation phase - electromagnetic fields from cables, operational noise, habitat modification, ",
        "fishing exclusion zones, collision risk for birds/bats; ",
        "(3) Decommissioning phase - structure removal, habitat loss, sediment disturbance. ",
        "Evaluation of effects on fish spawning grounds, nursery habitats, benthic communities, ",
        "marine mammals (especially harbor porpoises), migratory birds, and commercial fishery operations. ",
        "Integration of Nature Inclusive Design (NID) solutions including artificial reefs, biohuts, ",
        "enhanced scour protection, oyster restoration, and eco-friendly cable protection systems."
      ),
      problem_scale = "regional",
      problem_urgency = "high",
      example_activities = c(
        "Pile driving installation",
        "Cable laying operations",
        "Vessel traffic increase",
        "Seabed preparation works",
        "Turbine operation",
        "Maintenance activities",
        "Fishing exclusion enforcement"
      ),
      example_pressures = c(
        "Underwater noise pollution",
        "Seabed habitat disturbance",
        "Electromagnetic field exposure",
        "Sediment suspension and deposition",
        "Collision risk for birds and bats",
        "Fishing ground displacement",
        "Hydrodynamic changes"
      ),
      category = "Renewable Energy Infrastructure",

      # Extended NID-specific data for this scenario - COMPREHENSIVE LIST
      nid_preventive_controls = list(
        # Noise mitigation NIDs (Construction Phase)
        noise_mitigation = c(
          "Bubble curtain deployment during pile driving",
          "Double big bubble curtain (DBBC) systems",
          "Soft-start procedures for pile installation",
          "Noise-reduced foundation designs (vibro-piling, suction buckets)",
          "Hydrosound damper (HSD) deployment",
          "Isolation casings for noise reduction",
          "Seasonal timing restrictions for construction",
          "Real-time passive acoustic monitoring (PAM)",
          "Acoustic deterrent devices (ADD/AHD)",
          "Marine mammal observers (MMO) on vessels",
          "Pre-construction noise modeling",
          "Threshold noise level compliance monitoring"
        ),
        # Habitat protection NIDs
        habitat_protection = c(
          "Pre-construction habitat mapping and avoidance",
          "Benthic habitat sensitivity surveys",
          "Eco-friendly cable burial techniques",
          "Horizontal directional drilling (HDD) at landfall",
          "Micrositing to avoid sensitive habitats",
          "Avoidance of biogenic reefs and sensitive sediments",
          "Sediment control measures during dredging",
          "Turbidity curtains during construction",
          "Seasonal restrictions during fish spawning",
          "Cable route optimization to minimize habitat impact",
          "Post-construction seabed restoration"
        ),
        # Wildlife collision prevention NIDs
        collision_prevention = c(
          "Birds and bats radar monitoring systems",
          "DT Bird and bat detection systems",
          "Curtailment during peak migration periods",
          "Curtailment during poor visibility conditions",
          "Deterrent lighting systems for seabirds",
          "Bird-safe lighting configurations (red/green)",
          "Blade painting for improved visibility",
          "Single blade black paint pattern",
          "UV-reflective blade coatings",
          "Nacelle-mounted cameras for collision monitoring",
          "Post-construction mortality monitoring"
        ),
        # EMF and cable NIDs
        emf_mitigation = c(
          "Cable burial depth optimization",
          "EMF shielding for sensitive species areas",
          "Cable bundling to reduce EMF footprint",
          "Rock placement for cable protection and EMF barrier",
          "Spacing optimization between cables"
        ),
        # Fishery coexistence NIDs
        fishery_coexistence = c(
          "Co-location agreements with fishing industry",
          "Fishing access corridors within wind farm",
          "Real-time vessel traffic management",
          "Safety zones communication systems",
          "Compensation schemes for displaced fishing",
          "Alternative fishing grounds identification"
        )
      ),
      nid_mitigating_controls = list(
        # Artificial reef structures
        artificial_reefs = c(
          "3D-printed artificial reef modules",
          "Reef cubes for habitat creation",
          "AMA Artificial Modular Reefs on scour protection",
          "Rock reef placement around foundations",
          "Cod pipes for fish habitat",
          "ExoReef bespoke artificial reef structures",
          "Reef balls on scour protection",
          "Eco-concrete reef units",
          "Biorock reef structures",
          "Steel reef pyramids"
        ),
        # Nursery and shelter NIDs
        nursery_habitat = c(
          "Biohuts fish nursery installations",
          "Fish hotels on jacket foundations",
          "Artificial nursery structures (Creanurs)",
          "Water replenishment holes in monopiles",
          "Shelter structures in transition pieces",
          "Fish aggregation devices (FADs)",
          "Juvenile fish shelters",
          "Lobster habitat units",
          "Crab condos and shelters"
        ),
        # Ecosystem restoration NIDs - Bivalves
        bivalve_restoration = c(
          "Droppable oyster restoration structures",
          "Flat oyster (Ostrea edulis) reef restoration",
          "European flat oyster broodstock deployment",
          "Oyster shell cultch deployment",
          "Mussel bed enhancement on foundations",
          "Blue mussel (Mytilus edulis) spat collectors",
          "Horse mussel (Modiolus modiolus) restoration",
          "Scallop restoration areas"
        ),
        # Ecosystem restoration NIDs - Algae and plants
        algae_seaweed = c(
          "Native seaweed cultivation on structures",
          "Kelp forest restoration (Laminaria)",
          "Sugar kelp (Saccharina latissima) cultivation",
          "Seaweed longlines between turbines",
          "Seagrass (Zostera marina) restoration nearby",
          "Macroalgae colonization enhancement"
        ),
        # Enhanced infrastructure design NIDs
        infrastructure_enhancement = c(
          "Biodiversity-enhanced scour protection (BENSO)",
          "EcoScour cable crossing protection",
          "Eco-friendly cable protection systems",
          "Nature-inclusive monopile designs",
          "Textured foundation surfaces for colonization",
          "ECOncrete bio-enhancing concrete",
          "Grooved and pitted surface textures",
          "Tidal pools on foundation bases",
          "Vertical habitat structures on monopiles",
          "Multi-layer scour protection design"
        ),
        # Marine mammal and bird NIDs
        wildlife_enhancement = c(
          "Seal haul-out platforms on foundations",
          "Bird nesting platforms on turbines",
          "Porpoise-friendly maintenance schedules",
          "Quiet operational periods for marine mammals",
          "Bird feeding enhancement zones"
        ),
        # Monitoring and adaptive management NIDs
        monitoring_adaptive = c(
          "Long-term biodiversity monitoring programs",
          "Environmental DNA (eDNA) sampling",
          "Baited remote underwater video (BRUV)",
          "Acoustic telemetry fish tracking",
          "Adaptive management based on monitoring results",
          "Annual NID effectiveness assessments"
        )
      ),
      # Reference NID projects from the database - EXPANDED
      reference_projects = c(
        # North Sea operational projects
        "UNITED and ULTFARMS (Belwind OWF, North Sea) - Scour protection NID",
        "Luchterduinen 1 & 2 (Eneco, North Sea) - Stand-alone and scour protection",
        "Blauwwind (Borssele III/IV, North Sea) - Monopile scour protection",
        "Gemini/WINOR (Zee-energie, North Sea) - Stand-alone in wind farm",
        "Fish Hotels in Hollandse Kust Noord (TenneT) - Jacket foundation",
        "Cod pipes at Borssele I & II (Ørsted/WMR) - Fish habitat",
        "Rock Reefs HKZ (Vattenfall) - Monopile scour protection",
        "Ecocrossings (TenneT) - Cable crossing protection",
        "BENSO project (WMR/Waardenburg/Waterproof) - Research",
        "De Rijke Noordzee (various developers) - Multi-site restoration",
        # North Sea restoration projects
        "Borkumse stenen (ARK/WNF/Ørsted) - Degraded ecosystem restoration",
        "Eco-Friend (WMR) - Monopile testing",
        "EcoScour (Van Oord, Borssele V) - Cable crossing protection",
        # Baltic Sea projects
        "3D-printed reefs Anholt (Ørsted/WWF DK) - Offshore wind farm",
        "Eco-friendly reef cubes Karehamn (RWE) - Swedish OWF",
        "Kriegers Flak (Vattenfall) - Combined interconnector and OWF",
        # Mediterranean/Atlantic projects
        "Biohuts at BOB (Ecocean) - Biodiversity observation",
        "ReFish (Marinov, Toulon) - Underwater structures",
        "Recif'lab (Seaboost) - Port infrastructure",
        "REXCOR (Seaboost) - 3D printed artificial reefs",
        "Creanurs (Creocean, Cap Corse) - Artificial nursery",
        # UK projects
        "ORJIP (Offshore Renewables Joint Industry Programme) - Bird collision",
        "Dogger Bank (SSE/Equinor) - Oyster restoration",
        "Hornsea (Ørsted) - Marine mammal monitoring",
        # Planned/upcoming projects
        "EcoWende Wind Farm (Shell/Eneco, planned) - Nature-inclusive design",
        "IJmuiden Ver Alpha (SSE Renewables/Noordzeker) - Planned NID",
        "Princess Elisabeth Energy Island (Elia, Belgium) - Planned NID",
        "Hollandse Kust West (TenneT) - NID requirements tender",
        # Tropical/Asian projects
        "ReCoral Taiwan (Ørsted) - Coral restoration",
        "Greater Changhua (Ørsted, Taiwan) - Marine ecology program"
      ),
      # NID regulatory frameworks
      regulatory_frameworks = c(
        "OSPAR Commission Guidelines on Underwater Noise",
        "MSFD (Marine Strategy Framework Directive)",
        "Dutch Offshore Wind Ecological Programme (WOZEP)",
        "German BSH Standard for Noise Mitigation",
        "Belgian Nature Inclusive Design Requirements",
        "UK Habitats Regulations Assessment",
        "ASCOBANS Agreement (Small Cetaceans)"
      )
    )
  )
)

# =============================================================================
# WORKFLOW STATE MANAGEMENT
# =============================================================================

#' Initialize workflow state with complete structure
#' @return List containing initial workflow state
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

#' Update workflow progress
#' @param state Current workflow state
#' @param step_number Step number to update to
#' @param data Additional data to append
#' @return Updated workflow state
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

cat("   - guided_workflow_config.R loaded (WORKFLOW_CONFIG + state management)\n")
