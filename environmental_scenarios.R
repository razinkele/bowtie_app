# =============================================================================
# Environmental Scenarios Configuration
# Version: 5.1.0
# Date: November 2025
# Description: Centralized configuration for environmental risk scenarios
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
    icon = "fish-fins",
    label = "Marine biodiversity loss and ecosystem degradation",
    description = "Species decline, habitat destruction, and ecosystem imbalance from multiple anthropogenic pressures"
  ),

  # Offshore Wind Farm scenario
  offshore_wind_biodiversity = list(
    id = "offshore_wind_biodiversity",
    icon = "wind",
    label = "Offshore wind farm impacts on marine biodiversity and fishery",
    description = "Comprehensive assessment of offshore wind energy development impacts on marine ecosystems, fish populations, seabed habitats, and commercial/artisanal fisheries, with Nature Inclusive Design (NID) mitigation measures"
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
#'
#' @param include_blank Logical. Include blank/custom option? Default TRUE
#' @return Named character vector with scenario IDs as values and labels as names
#' @export
getEnvironmentalScenarioChoices <- function(include_blank = TRUE) {
  choices <- sapply(ENVIRONMENTAL_SCENARIOS, function(s) s$id)
  names(choices) <- sapply(ENVIRONMENTAL_SCENARIOS, function(s) s$label)

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
log_debug("Environmental scenarios configuration loaded")
log_debug(paste("   Available scenarios:", length(ENVIRONMENTAL_SCENARIOS)))
