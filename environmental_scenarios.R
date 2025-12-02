# =============================================================================
# Environmental Scenarios Configuration
# Version: 5.3.6
# Date: December 2025
# Description: Centralized configuration for environmental risk scenarios
# Updated: Added 3 Macaronesian island scenarios (16 total scenarios)
#          Scenarios ordered: General (6) → Macaronesian (3) → Martinique (7)
# =============================================================================

# Environmental scenario definitions
# Used across UI (data upload and guided workflow)
ENVIRONMENTAL_SCENARIOS <- list(
  marine_pollution = list(
    id = "marine_pollution",
    icon = "water",
    label = "Marine pollution from shipping & coastal activities",
    description = "Comprehensive maritime pollution assessment including shipping operations, port activities, and coastal industrial discharge"
  ),

  industrial_contamination = list(
    id = "industrial_contamination",
    icon = "industry",
    label = "Industrial contamination through chemical discharge",
    description = "Chemical pollutant risk analysis from industrial processes, waste discharge, and manufacturing operations"
  ),

  oil_spills = list(
    id = "oil_spills",
    icon = "ship",
    label = "Oil spills from maritime transportation",
    description = "Petroleum-based contamination scenarios from tanker operations, pipeline leaks, and offshore drilling"
  ),

  agricultural_runoff = list(
    id = "agricultural_runoff",
    icon = "seedling",
    label = "Agricultural runoff causing eutrophication",
    description = "Nutrient pollution and water quality impacts from fertilizer use, livestock operations, and irrigation"
  ),

  overfishing = list(
    id = "overfishing",
    icon = "fish",
    label = "Overfishing and commercial stock depletion",
    description = "Marine resource depletion and ecosystem impacts from commercial fishing, bycatch, and habitat destruction"
  ),

  marine_biodiversity_loss = list(
    id = "marine_biodiversity_loss",
    icon = "fish",
    label = "Marine biodiversity loss and ecosystem degradation",
    description = "Comprehensive assessment of marine species decline, habitat destruction, ecosystem imbalance from multiple pressures including overfishing, pollution, climate change, invasive species, and coastal development affecting marine biodiversity and ecosystem services"
  ),

  # Macaronesian islands-specific scenarios (Azores, Madeira, Canary Islands, Cape Verde)
  macaronesia_volcanic_impacts = list(
    id = "macaronesia_volcanic_impacts",
    icon = "mountain",
    label = "Macaronesia: Volcanic activity impacts on marine ecosystems",
    description = "Assessment of volcanic eruptions, lava flows, ash deposition, and hydrothermal vents affecting coastal waters, marine life, fisheries, and ecosystem recovery in oceanic volcanic islands of Azores, Canary Islands, and Cape Verde archipelagos"
  ),

  macaronesia_endemic_species = list(
    id = "macaronesia_endemic_species",
    icon = "crow",
    label = "Macaronesia: Endemic marine species conservation threats",
    description = "Risk analysis for unique Macaronesian endemic species including monk seals, sea turtles, cetaceans, endemic fish, and invertebrates facing threats from habitat loss, invasive species, climate change, and human activities across Atlantic island ecosystems"
  ),

  macaronesia_deep_sea = list(
    id = "macaronesia_deep_sea",
    icon = "water",
    label = "Macaronesia: Deep-sea ecosystems and mining pressures",
    description = "Assessment of deep-sea habitats including seamounts, hydrothermal vents, cold-water corals, and abyssal plains threatened by potential deep-sea mining, fishing impacts, climate change, and research activities in Macaronesian waters"
  ),

  # Martinique-specific scenarios
  martinique_coastal_erosion = list(
    id = "martinique_coastal_erosion",
    icon = "mountain",
    label = "Martinique: Coastal erosion and beach degradation",
    description = "Assessment of coastal erosion from sea level rise, storm surge, infrastructure development, and sand mining affecting beaches and coastal ecosystems in Martinique's Caribbean and Atlantic coastlines"
  ),

  martinique_sargassum = list(
    id = "martinique_sargassum",
    icon = "leaf",
    label = "Martinique: Sargassum seaweed influx impacts",
    description = "Risk analysis of massive Sargassum seaweed arrivals affecting beaches, tourism, marine life, and coastal water quality across Martinique with hydrogen sulfide emissions and ecosystem disruption"
  ),

  martinique_coral_degradation = list(
    id = "martinique_coral_degradation",
    icon = "water",
    label = "Martinique: Coral reef degradation and bleaching",
    description = "Caribbean coral reef ecosystem assessment including bleaching events from rising sea temperatures, pollution runoff, overfishing, and physical damage from anchoring and tourism activities"
  ),

  martinique_watershed_pollution = list(
    id = "martinique_watershed_pollution",
    icon = "tint",
    label = "Martinique: Watershed pollution from agriculture",
    description = "Analysis of agricultural chemical contamination (chlordecone pesticide legacy), nutrient runoff from banana plantations, and sediment pollution affecting rivers, coastal waters, and drinking water sources"
  ),

  martinique_mangrove_loss = list(
    id = "martinique_mangrove_loss",
    icon = "tree",
    label = "Martinique: Mangrove forest degradation",
    description = "Assessment of mangrove ecosystem loss from coastal development, marina construction, pollution, and climate impacts affecting fish nurseries, coastal protection, and biodiversity in key areas like Baie de Fort-de-France"
  ),

  martinique_hurricane_impacts = list(
    id = "martinique_hurricane_impacts",
    icon = "wind",
    label = "Martinique: Hurricane and tropical storm impacts",
    description = "Comprehensive risk assessment of hurricane and tropical storm effects including infrastructure damage, coastal flooding, marine ecosystem disruption, pollution mobilization, and emergency response challenges"
  ),

  martinique_marine_tourism = list(
    id = "martinique_marine_tourism",
    icon = "ship",
    label = "Martinique: Marine tourism environmental pressures",
    description = "Analysis of environmental impacts from cruise ships, yacht anchoring, diving activities, beach recreation, and tourism infrastructure on coral reefs, seagrass beds, and coastal water quality"
  )
)

#' Get Environmental Scenario Choices
#'
#' Returns a named vector of scenario choices suitable for selectInput
#' Ordered by category: General scenarios, Macaronesian, Martinique
#'
#' @param include_blank Logical. Include blank/custom option? Default TRUE
#' @return Named character vector with scenario IDs as values and labels as names
#' @export
getEnvironmentalScenarioChoices <- function(include_blank = TRUE) {
  # Define scenario order: General, Macaronesian, Martinique
  general_scenarios <- c(
    "marine_pollution",
    "industrial_contamination",
    "oil_spills",
    "agricultural_runoff",
    "overfishing",
    "marine_biodiversity_loss"
  )

  macaronesia_scenarios <- c(
    "macaronesia_volcanic_impacts",
    "macaronesia_endemic_species",
    "macaronesia_deep_sea"
  )

  martinique_scenarios <- c(
    "martinique_coastal_erosion",
    "martinique_sargassum",
    "martinique_coral_degradation",
    "martinique_watershed_pollution",
    "martinique_mangrove_loss",
    "martinique_hurricane_impacts",
    "martinique_marine_tourism"
  )

  # Combine in desired order
  ordered_ids <- c(general_scenarios, macaronesia_scenarios, martinique_scenarios)

  # Build choices vector in order
  choices <- character(0)
  for (id in ordered_ids) {
    if (id %in% names(ENVIRONMENTAL_SCENARIOS)) {
      scenario <- ENVIRONMENTAL_SCENARIOS[[id]]
      choices[scenario$label] <- scenario$id
    }
  }

  if (include_blank) {
    choices <- c("Custom scenario" = "", choices)
  }

  return(choices)
}

#' Get Scenario Icon
#'
#' Returns the FontAwesome icon name for a given scenario
#'
#' @param scenario_id Character. The scenario ID
#' @return Character. FontAwesome icon name, or "circle-question" if not found
#' @export
getScenarioIcon <- function(scenario_id) {
  if (scenario_id %in% names(ENVIRONMENTAL_SCENARIOS)) {
    return(ENVIRONMENTAL_SCENARIOS[[scenario_id]]$icon)
  }
  return("circle-question")
}

#' Get Scenario Label
#'
#' Returns the display label for a given scenario
#'
#' @param scenario_id Character. The scenario ID
#' @return Character. Scenario label, or "Custom" if not found
#' @export
getScenarioLabel <- function(scenario_id) {
  if (scenario_id %in% names(ENVIRONMENTAL_SCENARIOS)) {
    return(ENVIRONMENTAL_SCENARIOS[[scenario_id]]$label)
  }
  return("Custom")
}

#' Get Scenario Description
#'
#' Returns the description for a given scenario
#'
#' @param scenario_id Character. The scenario ID
#' @return Character. Scenario description, or empty string if not found
#' @export
getScenarioDescription <- function(scenario_id) {
  if (scenario_id %in% names(ENVIRONMENTAL_SCENARIOS)) {
    return(ENVIRONMENTAL_SCENARIOS[[scenario_id]]$description)
  }
  return("")
}

# Export for use in other modules
cat("✅ Environmental scenarios configuration loaded\n")
cat("   Available scenarios:", length(ENVIRONMENTAL_SCENARIOS), "\n")
