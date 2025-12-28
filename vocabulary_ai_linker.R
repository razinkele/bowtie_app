# vocabulary_ai_linker.R
# AI-powered vocabulary relationship finder for Environmental Bowtie Analysis
# Version 3.0 - Production-ready with enhanced error handling and modularity
#
# This module provides intelligent linking between vocabulary elements using:
#   - Semantic similarity analysis (Jaccard, cosine)
#   - Keyword-based thematic connections
#   - Advanced causal relationship detection
#   - Environmental domain knowledge
#
# Usage:
#   source("vocabulary_ai_linker.R")
#   links <- find_vocabulary_links(vocabulary_data, methods = c("jaccard", "keyword", "causal"))
#
# Author: Claude Code (Enhanced Version)
# Date: 2025-12-28

# =============================================================================
# PACKAGE MANAGEMENT WITH GRACEFUL DEGRADATION
# =============================================================================

# Track which advanced features are available
AI_LINKER_CAPABILITIES <- list(
  text_mining = FALSE,
  string_distance = FALSE,
  text_analysis = FALSE,
  network_analysis = FALSE,
  basic_only = TRUE
)

# Function to safely load optional packages
load_optional_package <- function(package_name, quiet = TRUE) {
  tryCatch({
    if (!requireNamespace(package_name, quietly = quiet)) {
      if (!quiet) {
        cat("📦 Installing optional package:", package_name, "\n")
      }
      install.packages(package_name, quiet = quiet)
    }
    library(package_name, character.only = TRUE, quietly = quiet)
    TRUE
  }, error = function(e) {
    if (!quiet) {
      cat("⚠️ Optional package", package_name, "not available:", e$message, "\n")
    }
    FALSE
  })
}

# Load optional packages for advanced features
if (load_optional_package("tm", quiet = TRUE)) {
  AI_LINKER_CAPABILITIES$text_mining <- TRUE
}

if (load_optional_package("stringdist", quiet = TRUE)) {
  AI_LINKER_CAPABILITIES$string_distance <- TRUE
}

if (load_optional_package("tidytext", quiet = TRUE) &&
    load_optional_package("widyr", quiet = TRUE) &&
    load_optional_package("textrank", quiet = TRUE)) {
  AI_LINKER_CAPABILITIES$text_analysis <- TRUE
}

if (load_optional_package("igraph", quiet = TRUE)) {
  AI_LINKER_CAPABILITIES$network_analysis <- TRUE
}

# Core packages (required)
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
library(dplyr)

if (!requireNamespace("tidyr", quietly = TRUE)) {
  install.packages("tidyr")
}
library(tidyr)

# Update basic_only flag
AI_LINKER_CAPABILITIES$basic_only <- !(AI_LINKER_CAPABILITIES$text_mining ||
                                        AI_LINKER_CAPABILITIES$string_distance ||
                                        AI_LINKER_CAPABILITIES$text_analysis)

# =============================================================================
# CORE UTILITY FUNCTIONS
# =============================================================================

#' Preprocess text for analysis
#' @param text Character string to preprocess
#' @return Cleaned text string
preprocess_text <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text)) {
    return("")
  }

  text %>%
    tolower() %>%
    gsub("[[:punct:]]", " ", .) %>%
    gsub("\\s+", " ", .) %>%
    trimws()
}

#' Calculate semantic similarity between two text strings
#' @param text1 First text string
#' @param text2 Second text string
#' @param method Similarity method ("jaccard", "cosine", or "jw")
#' @return Similarity score (0-1)
calculate_semantic_similarity <- function(text1, text2, method = "jaccard") {
  # Validate inputs
  if (is.null(text1) || is.null(text2) || is.na(text1) || is.na(text2)) {
    return(0)
  }

  # Preprocess texts
  text1_clean <- preprocess_text(text1)
  text2_clean <- preprocess_text(text2)

  # Tokenize
  tokens1 <- unlist(strsplit(text1_clean, " "))
  tokens2 <- unlist(strsplit(text2_clean, " "))

  # Remove empty tokens
  tokens1 <- tokens1[tokens1 != ""]
  tokens2 <- tokens2[tokens2 != ""]

  if (length(tokens1) == 0 || length(tokens2) == 0) {
    return(0)
  }

  # Calculate similarity based on method
  if (method == "jaccard") {
    # Jaccard similarity
    intersection <- length(intersect(tokens1, tokens2))
    union <- length(union(tokens1, tokens2))
    similarity <- if (union > 0) intersection / union else 0

  } else if (method == "cosine") {
    # Cosine similarity using term frequency
    all_tokens <- unique(c(tokens1, tokens2))
    vec1 <- sapply(all_tokens, function(t) sum(tokens1 == t))
    vec2 <- sapply(all_tokens, function(t) sum(tokens2 == t))

    dot_product <- sum(vec1 * vec2)
    magnitude1 <- sqrt(sum(vec1^2))
    magnitude2 <- sqrt(sum(vec2^2))

    similarity <- if (magnitude1 > 0 && magnitude2 > 0) {
      dot_product / (magnitude1 * magnitude2)
    } else {
      0
    }

  } else if (method == "jw" && AI_LINKER_CAPABILITIES$string_distance) {
    # Jaro-Winkler string distance
    similarity <- 1 - stringdist::stringdist(text1_clean, text2_clean, method = "jw")

  } else {
    # Default to simple Jaccard if method unavailable
    warning("Method '", method, "' not available, using Jaccard")
    return(calculate_semantic_similarity(text1, text2, method = "jaccard"))
  }

  return(max(0, min(1, similarity)))  # Ensure 0-1 range
}

# =============================================================================
# ENVIRONMENTAL DOMAIN KNOWLEDGE
# =============================================================================

# Environmental keyword themes for thematic connections
ENVIRONMENTAL_THEMES <- list(
  water = list(
    keywords = c("water", "aquatic", "marine", "river", "lake", "ocean", "sea",
                "coastal", "wetland", "groundwater", "wastewater", "sewage",
                "stormwater", "hydrological", "riverine", "estuarine"),
    strength = 0.8,
    domain = "Water Systems"
  ),

  pollution = list(
    keywords = c("pollution", "contamination", "discharge", "emission", "runoff",
                "waste", "toxic", "chemical", "nutrient", "pollutant", "effluent",
                "leachate", "spill", "leak"),
    strength = 0.75,
    domain = "Pollution"
  ),

  ecosystem = list(
    keywords = c("ecosystem", "habitat", "biodiversity", "species", "wildlife",
                "fauna", "flora", "ecological", "environment", "conservation",
                "nature", "biome", "biotic"),
    strength = 0.75,
    domain = "Ecosystems"
  ),

  climate = list(
    keywords = c("climate", "greenhouse", "carbon", "emission", "warming",
                "temperature", "weather", "methane", "co2", "ghg", "fossil",
                "renewable", "atmosphere"),
    strength = 0.7,
    domain = "Climate"
  ),

  agriculture = list(
    keywords = c("agriculture", "farming", "livestock", "crop", "fertilizer",
                "pesticide", "soil", "erosion", "irrigation", "cultivation",
                "grazing", "tillage", "harvest"),
    strength = 0.75,
    domain = "Agriculture"
  ),

  industrial = list(
    keywords = c("industrial", "manufacturing", "factory", "production",
                "chemical", "waste", "discharge", "emission", "processing",
                "refinery", "mining", "extraction"),
    strength = 0.7,
    domain = "Industry"
  ),

  health = list(
    keywords = c("health", "disease", "illness", "respiratory", "contamination",
                "exposure", "toxic", "safety", "risk", "mortality", "morbidity",
                "pathogen", "infection"),
    strength = 0.7,
    domain = "Health"
  ),

  management = list(
    keywords = c("management", "control", "mitigation", "prevention", "monitoring",
                "treatment", "restoration", "protection", "regulation",
                "compliance", "policy", "governance"),
    strength = 0.65,
    domain = "Management"
  ),

  fisheries = list(
    keywords = c("fish", "fishing", "fishery", "fisheries", "catch", "stock",
                "overfishing", "bycatch", "trawl", "net", "harvest", "quota",
                "commercial fishing"),
    strength = 0.75,
    domain = "Fisheries"
  ),

  coastal = list(
    keywords = c("coastal", "beach", "shore", "dune", "erosion", "sediment",
                "wave", "tide", "littoral", "reef", "coral", "mangrove"),
    strength = 0.75,
    domain = "Coastal Systems"
  )
)

# Causal relationship patterns
CAUSAL_PATTERNS <- list(
  direct_cause = list(
    keywords = c("causes", "leads to", "results in", "creates", "generates",
                "produces", "induces", "triggers", "drives", "brings about"),
    strength = 0.9,
    direction = "forward"
  ),

  impact = list(
    keywords = c("impacts", "affects", "influences", "damages", "harms",
                "degrades", "threatens", "compromises", "disrupts", "impairs"),
    strength = 0.85,
    direction = "forward"
  ),

  source = list(
    keywords = c("from", "due to", "because of", "as a result of",
                "attributed to", "stemming from", "arising from", "caused by"),
    strength = 0.8,
    direction = "backward"
  ),

  contribution = list(
    keywords = c("contributes to", "adds to", "increases", "exacerbates",
                "intensifies", "amplifies", "worsens", "accelerates",
                "compounds", "magnifies"),
    strength = 0.75,
    direction = "forward"
  ),

  prevention = list(
    keywords = c("prevents", "reduces", "mitigates", "controls", "limits",
                "minimizes", "alleviates", "diminishes", "counters", "avoids"),
    strength = 0.7,
    direction = "intervention"
  )
)

# Environmental process chains
PROCESS_CHAINS <- list(
  pollution_pathway = list(
    start = c("emission", "discharge", "release", "disposal", "dumping"),
    middle = c("contamination", "pollution", "accumulation", "transport"),
    end = c("degradation", "damage", "harm", "loss", "death"),
    description = "Pollution pathway from source to impact"
  ),

  ecosystem_pathway = list(
    start = c("disturbance", "alteration", "modification", "extraction", "removal"),
    middle = c("habitat loss", "fragmentation", "degradation", "disruption"),
    end = c("biodiversity loss", "extinction", "ecosystem collapse", "species decline"),
    description = "Ecosystem degradation pathway"
  ),

  water_quality_pathway = list(
    start = c("runoff", "discharge", "leakage", "overflow", "seepage"),
    middle = c("nutrient loading", "contamination", "pollution", "eutrophication"),
    end = c("hypoxia", "dead zones", "water quality degradation", "algal blooms"),
    description = "Water quality degradation pathway"
  ),

  climate_pathway = list(
    start = c("emission", "release", "combustion", "deforestation", "land use"),
    middle = c("greenhouse gas", "carbon", "methane", "warming", "acidification"),
    end = c("climate change", "extreme weather", "sea level rise", "temperature increase"),
    description = "Climate change pathway"
  ),

  fisheries_pathway = list(
    start = c("fishing", "harvesting", "extraction", "catching", "trawling"),
    middle = c("overfishing", "stock depletion", "bycatch", "habitat damage"),
    end = c("fishery collapse", "species decline", "ecosystem disruption", "food security threat"),
    description = "Fisheries depletion pathway"
  )
)

# =============================================================================
# BASIC LINKING FUNCTION (Always Available)
# =============================================================================

#' Basic vocabulary connection finder (fallback when AI unavailable)
#' @param vocabulary_data List containing vocabulary dataframes (activities, pressures, consequences, controls)
#' @param max_links_per_item Maximum number of links per vocabulary item
#' @return Data frame of basic connections
find_basic_connections <- function(vocabulary_data, max_links_per_item = 5) {
  cat("📌 Using basic connection method (AI features unavailable)\n")

  # Validate input
  if (is.null(vocabulary_data) || !is.list(vocabulary_data)) {
    warning("Invalid vocabulary_data provided to find_basic_connections")
    return(data.frame())
  }

  required_components <- c("activities", "pressures", "consequences", "controls")
  missing_components <- setdiff(required_components, names(vocabulary_data))

  if (length(missing_components) > 0) {
    warning("Missing vocabulary components: ", paste(missing_components, collapse = ", "))
    return(data.frame())
  }

  basic_links <- data.frame()

  # Helper function to find word overlap
  get_word_overlap_score <- function(text1, text2) {
    words1 <- tolower(unlist(strsplit(text1, "\\s+")))
    words2 <- tolower(unlist(strsplit(text2, "\\s+")))

    # Remove common words
    stopwords <- c("and", "or", "the", "a", "an", "in", "on", "at", "to", "for",
                  "of", "with", "from", "by", "as", "is", "are", "was", "were")
    words1 <- setdiff(words1, stopwords)
    words2 <- setdiff(words2, stopwords)

    if (length(words1) == 0 || length(words2) == 0) return(0)

    overlap <- length(intersect(words1, words2))
    score <- overlap / min(length(words1), length(words2))
    return(score)
  }

  # Activity → Pressure connections
  if (nrow(vocabulary_data$activities) > 0 && nrow(vocabulary_data$pressures) > 0) {
    for (i in 1:nrow(vocabulary_data$activities)) {
      activity <- vocabulary_data$activities[i, ]

      for (j in 1:nrow(vocabulary_data$pressures)) {
        pressure <- vocabulary_data$pressures[j, ]

        score <- get_word_overlap_score(activity$name, pressure$name)

        if (score > 0.2) {
          basic_links <- rbind(basic_links, data.frame(
            from_id = activity$id,
            from_name = activity$name,
            from_type = "Activity",
            to_id = pressure$id,
            to_name = pressure$name,
            to_type = "Pressure",
            similarity = score,
            method = "basic_word_overlap",
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }

  # Pressure → Consequence connections
  if (nrow(vocabulary_data$pressures) > 0 && nrow(vocabulary_data$consequences) > 0) {
    for (i in 1:nrow(vocabulary_data$pressures)) {
      pressure <- vocabulary_data$pressures[i, ]

      for (j in 1:nrow(vocabulary_data$consequences)) {
        consequence <- vocabulary_data$consequences[j, ]

        score <- get_word_overlap_score(pressure$name, consequence$name)

        if (score > 0.2) {
          basic_links <- rbind(basic_links, data.frame(
            from_id = pressure$id,
            from_name = pressure$name,
            from_type = "Pressure",
            to_id = consequence$id,
            to_name = consequence$name,
            to_type = "Consequence",
            similarity = score,
            method = "basic_word_overlap",
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }

  # Limit links per item
  if (nrow(basic_links) > 0) {
    basic_links <- basic_links %>%
      arrange(desc(similarity)) %>%
      group_by(from_id) %>%
      slice_head(n = max_links_per_item) %>%
      ungroup()
  }

  cat("✅ Found", nrow(basic_links), "basic connections\n")

  return(basic_links)
}

# =============================================================================
# ADVANCED CAUSAL RELATIONSHIP DETECTION
# =============================================================================

#' Detect causal relationships between vocabulary elements
#' @param vocabulary_data List containing vocabulary dataframes
#' @param use_domain_knowledge Whether to use environmental domain rules
#' @return Data frame of detected causal relationships
detect_causal_relationships <- function(vocabulary_data, use_domain_knowledge = TRUE) {
  cat("🔍 Performing causal relationship analysis...\n")

  # Validate input
  if (is.null(vocabulary_data) || !is.list(vocabulary_data)) {
    warning("Invalid vocabulary_data provided")
    return(data.frame())
  }

  causal_links <- data.frame()

  # Extract vocabulary components
  all_activities <- vocabulary_data$activities
  all_pressures <- vocabulary_data$pressures
  all_consequences <- vocabulary_data$consequences
  all_controls <- vocabulary_data$controls

  # 1. Activity → Pressure causal analysis
  if (!is.null(all_activities) && !is.null(all_pressures) &&
      nrow(all_activities) > 0 && nrow(all_pressures) > 0) {

    cat("  Analyzing Activity → Pressure causal links...\n")

    for (i in 1:nrow(all_activities)) {
      activity <- all_activities[i, ]
      activity_text <- tolower(activity$name)

      for (j in 1:nrow(all_pressures)) {
        pressure <- all_pressures[j, ]
        pressure_text <- tolower(pressure$name)

        causal_score <- 0
        causal_method <- "unknown"

        # Method 1: Direct word matching
        activity_words <- unlist(strsplit(activity_text, "\\s+"))
        pressure_words <- unlist(strsplit(pressure_text, "\\s+"))
        common_words <- intersect(activity_words, pressure_words)

        if (length(common_words) > 0) {
          causal_score <- length(common_words) / min(length(activity_words), length(pressure_words))
          causal_method <- "word_match"
        }

        # Method 2: Environmental logic rules (if domain knowledge enabled)
        if (use_domain_knowledge) {
          # Rule: operations → emissions/discharges
          if (grepl("operation|practice|activity|process", activity_text) &&
              grepl("emission|discharge|release|runoff|waste", pressure_text)) {
            causal_score <- max(causal_score, 0.7)
            causal_method <- "environmental_logic"
          }

          # Rule: industrial/agricultural → pollution/contamination
          if (grepl("industrial|agricultural|manufacturing|farming", activity_text) &&
              grepl("pollution|contamination|waste|runoff", pressure_text)) {
            causal_score <- max(causal_score, 0.75)
            causal_method <- "sector_impact"
          }

          # Rule: fishing → overfishing/depletion
          if (grepl("fish|harvest|catch|trawl", activity_text) &&
              grepl("overfish|deplet|stock|bycatch", pressure_text)) {
            causal_score <- max(causal_score, 0.8)
            causal_method <- "fisheries_impact"
          }
        }

        # Add link if score sufficient
        if (causal_score > 0.3) {
          causal_links <- rbind(causal_links, data.frame(
            from_id = activity$id,
            from_name = activity$name,
            from_type = "Activity",
            to_id = pressure$id,
            to_name = pressure$name,
            to_type = "Pressure",
            similarity = causal_score,
            method = paste("causal", causal_method, sep = "_"),
            causal_type = "activity_pressure",
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }

  # 2. Pressure → Consequence causal analysis
  if (!is.null(all_pressures) && !is.null(all_consequences) &&
      nrow(all_pressures) > 0 && nrow(all_consequences) > 0) {

    cat("  Analyzing Pressure → Consequence causal links...\n")

    for (i in 1:nrow(all_pressures)) {
      pressure <- all_pressures[i, ]
      pressure_text <- tolower(pressure$name)

      for (j in 1:nrow(all_consequences)) {
        consequence <- all_consequences[j, ]
        consequence_text <- tolower(consequence$name)

        causal_score <- 0
        causal_method <- "unknown"

        # Method 1: Impact keywords
        consequence_indicators <- c("loss", "degradation", "damage", "death",
                                   "extinction", "collapse", "depletion",
                                   "destruction", "decline", "reduction")

        if (any(sapply(consequence_indicators, function(ind) grepl(ind, consequence_text)))) {
          pressure_words <- unlist(strsplit(pressure_text, "\\s+"))
          consequence_words <- unlist(strsplit(consequence_text, "\\s+"))
          common_concepts <- intersect(pressure_words, consequence_words)

          if (length(common_concepts) > 0) {
            causal_score <- 0.7
            causal_method <- "impact_alignment"
          }
        }

        # Method 2: Domain-specific rules
        if (use_domain_knowledge) {
          # Water pollution → water consequences
          if (grepl("water|aquatic|marine", pressure_text) &&
              grepl("water|aquatic|marine|fish|ecosystem", consequence_text)) {
            causal_score <- max(causal_score, 0.8)
            causal_method <- "domain_water"
          }

          # Habitat pressure → biodiversity consequences
          if (grepl("habitat|ecosystem|land", pressure_text) &&
              grepl("biodiversity|species|extinction|ecosystem", consequence_text)) {
            causal_score <- max(causal_score, 0.85)
            causal_method <- "domain_biodiversity"
          }

          # Pollution → health/environmental consequences
          if (grepl("pollution|contamination|toxic", pressure_text) &&
              grepl("health|disease|mortality|degradation", consequence_text)) {
            causal_score <- max(causal_score, 0.8)
            causal_method <- "domain_health"
          }
        }

        # Add link if score sufficient
        if (causal_score > 0.3) {
          causal_links <- rbind(causal_links, data.frame(
            from_id = pressure$id,
            from_name = pressure$name,
            from_type = "Pressure",
            to_id = consequence$id,
            to_name = consequence$name,
            to_type = "Consequence",
            similarity = causal_score,
            method = paste("causal", causal_method, sep = "_"),
            causal_type = "pressure_consequence",
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }

  # 3. Control → Pressure intervention analysis
  if (!is.null(all_controls) && !is.null(all_pressures) &&
      nrow(all_controls) > 0 && nrow(all_pressures) > 0) {

    cat("  Analyzing Control intervention relationships...\n")

    for (i in 1:nrow(all_controls)) {
      control <- all_controls[i, ]
      control_text <- tolower(control$name)

      # Check for intervention keywords
      intervention_keywords <- c("prevent", "control", "reduce", "mitigate",
                                "manage", "treat", "filter", "clean", "protect",
                                "restore", "monitor", "regulate")

      control_has_intervention <- any(sapply(intervention_keywords,
                                            function(kw) grepl(kw, control_text)))

      if (control_has_intervention) {
        for (j in 1:nrow(all_pressures)) {
          pressure <- all_pressures[j, ]
          pressure_text <- tolower(pressure$name)

          causal_score <- 0
          causal_method <- "unknown"

          # Check if control targets the pressure
          control_words <- unlist(strsplit(control_text, "\\s+"))
          pressure_words <- unlist(strsplit(pressure_text, "\\s+"))
          target_match <- length(intersect(control_words, pressure_words))

          if (target_match > 0) {
            causal_score <- min(0.9, 0.4 + (target_match * 0.2))
            causal_method <- "targeted_intervention"
          }

          # Domain-specific intervention rules
          if (use_domain_knowledge) {
            # Treatment → pollution
            if (grepl("treatment|purification|filter", control_text) &&
                grepl("water|sewage|effluent|waste|pollution", pressure_text)) {
              causal_score <- max(causal_score, 0.85)
              causal_method <- "treatment_intervention"
            }

            # Regulation/management → activity-based pressures
            if (grepl("regulation|policy|management|quota", control_text) &&
                grepl("fishing|harvest|extraction|emission", pressure_text)) {
              causal_score <- max(causal_score, 0.8)
              causal_method <- "regulatory_intervention"
            }
          }

          # Add link if score sufficient
          if (causal_score > 0.4) {
            causal_links <- rbind(causal_links, data.frame(
              from_id = control$id,
              from_name = control$name,
              from_type = "Control",
              to_id = pressure$id,
              to_name = pressure$name,
              to_type = "Pressure",
              similarity = causal_score,
              method = paste("causal_intervention", causal_method, sep = "_"),
              causal_type = "control_pressure",
              stringsAsFactors = FALSE
            ))
          }
        }
      }
    }
  }

  cat("✅ Found", nrow(causal_links), "causal relationships\n")

  return(causal_links)
}

# =============================================================================
# KEYWORD-BASED THEMATIC LINKING
# =============================================================================

#' Find keyword-based thematic connections
#' @param vocabulary_data List containing vocabulary dataframes
#' @param themes List of environmental themes (default: ENVIRONMENTAL_THEMES)
#' @return Data frame of keyword-based connections
find_keyword_connections <- function(vocabulary_data, themes = ENVIRONMENTAL_THEMES) {
  cat("🔍 Identifying keyword-based connections...\n")

  # Validate input
  if (is.null(vocabulary_data) || !is.list(vocabulary_data)) {
    warning("Invalid vocabulary_data provided")
    return(data.frame())
  }

  keyword_links <- data.frame()

  # Create combined vocabulary items
  all_items <- tryCatch({
    rbind(
      if (!is.null(vocabulary_data$activities) && nrow(vocabulary_data$activities) > 0) {
        data.frame(id = vocabulary_data$activities$id,
                  name = vocabulary_data$activities$name,
                  type = "Activity",
                  stringsAsFactors = FALSE)
      } else { data.frame() },

      if (!is.null(vocabulary_data$pressures) && nrow(vocabulary_data$pressures) > 0) {
        data.frame(id = vocabulary_data$pressures$id,
                  name = vocabulary_data$pressures$name,
                  type = "Pressure",
                  stringsAsFactors = FALSE)
      } else { data.frame() },

      if (!is.null(vocabulary_data$consequences) && nrow(vocabulary_data$consequences) > 0) {
        data.frame(id = vocabulary_data$consequences$id,
                  name = vocabulary_data$consequences$name,
                  type = "Consequence",
                  stringsAsFactors = FALSE)
      } else { data.frame() },

      if (!is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
        data.frame(id = vocabulary_data$controls$id,
                  name = vocabulary_data$controls$name,
                  type = "Control",
                  stringsAsFactors = FALSE)
      } else { data.frame() }
    )
  }, error = function(e) {
    warning("Error combining vocabulary items: ", e$message)
    return(data.frame())
  })

  if (nrow(all_items) == 0) {
    warning("No vocabulary items found")
    return(data.frame())
  }

  # Analyze each theme
  for (theme_name in names(themes)) {
    theme <- themes[[theme_name]]
    theme_keywords <- theme$keywords
    theme_strength <- theme$strength

    # Find items containing theme keywords
    keyword_pattern <- paste(theme_keywords, collapse = "|")
    theme_items <- all_items[grepl(keyword_pattern, tolower(all_items$name)), ]

    if (nrow(theme_items) > 1) {
      # Create connections between items sharing the same theme
      for (i in 1:(nrow(theme_items) - 1)) {
        for (j in (i + 1):nrow(theme_items)) {
          # Only link different types
          if (theme_items$type[i] != theme_items$type[j]) {
            keyword_links <- rbind(keyword_links, data.frame(
              from_id = theme_items$id[i],
              from_name = theme_items$name[i],
              from_type = theme_items$type[i],
              to_id = theme_items$id[j],
              to_name = theme_items$name[j],
              to_type = theme_items$type[j],
              similarity = theme_strength,
              method = paste("keyword", theme_name, sep = "_"),
              stringsAsFactors = FALSE
            ))
          }
        }
      }
    }
  }

  cat("✅ Found", nrow(keyword_links), "keyword-based connections\n")

  return(keyword_links)
}

# =============================================================================
# SEMANTIC SIMILARITY LINKING
# =============================================================================

#' Find semantic similarity connections
#' @param vocabulary_data List containing vocabulary dataframes
#' @param method Similarity method ("jaccard" or "cosine")
#' @param threshold Minimum similarity threshold (0-1)
#' @return Data frame of semantic connections
find_semantic_connections <- function(vocabulary_data, method = "jaccard", threshold = 0.3) {
  cat("📊 Analyzing semantic similarities using", method, "method...\n")

  # Validate input
  if (is.null(vocabulary_data) || !is.list(vocabulary_data)) {
    warning("Invalid vocabulary_data provided")
    return(data.frame())
  }

  semantic_links <- data.frame()

  # Create combined vocabulary items
  all_items <- tryCatch({
    rbind(
      if (!is.null(vocabulary_data$activities) && nrow(vocabulary_data$activities) > 0) {
        data.frame(id = vocabulary_data$activities$id,
                  name = vocabulary_data$activities$name,
                  type = "Activity",
                  stringsAsFactors = FALSE)
      } else { data.frame() },

      if (!is.null(vocabulary_data$pressures) && nrow(vocabulary_data$pressures) > 0) {
        data.frame(id = vocabulary_data$pressures$id,
                  name = vocabulary_data$pressures$name,
                  type = "Pressure",
                  stringsAsFactors = FALSE)
      } else { data.frame() },

      if (!is.null(vocabulary_data$consequences) && nrow(vocabulary_data$consequences) > 0) {
        data.frame(id = vocabulary_data$consequences$id,
                  name = vocabulary_data$consequences$name,
                  type = "Consequence",
                  stringsAsFactors = FALSE)
      } else { data.frame() },

      if (!is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
        data.frame(id = vocabulary_data$controls$id,
                  name = vocabulary_data$controls$name,
                  type = "Control",
                  stringsAsFactors = FALSE)
      } else { data.frame() }
    )
  }, error = function(e) {
    warning("Error combining vocabulary items: ", e$message)
    return(data.frame())
  })

  if (nrow(all_items) < 2) {
    warning("Not enough vocabulary items for semantic analysis")
    return(data.frame())
  }

  # Calculate pairwise similarities between different types
  total_comparisons <- choose(nrow(all_items), 2)
  cat("  Processing", total_comparisons, "pairwise comparisons...\n")

  for (i in 1:(nrow(all_items) - 1)) {
    for (j in (i + 1):nrow(all_items)) {
      # Only link different types
      if (all_items$type[i] != all_items$type[j]) {
        similarity <- calculate_semantic_similarity(
          all_items$name[i],
          all_items$name[j],
          method = method
        )

        if (similarity >= threshold) {
          semantic_links <- rbind(semantic_links, data.frame(
            from_id = all_items$id[i],
            from_name = all_items$name[i],
            from_type = all_items$type[i],
            to_id = all_items$id[j],
            to_name = all_items$name[j],
            to_type = all_items$type[j],
            similarity = similarity,
            method = method,
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }

  cat("✅ Found", nrow(semantic_links), "semantic connections\n")

  return(semantic_links)
}

# =============================================================================
# MAIN LINKING FUNCTION
# =============================================================================

#' Find vocabulary links using AI-powered analysis
#'
#' This is the main entry point for vocabulary linking. It combines multiple
#' linking methods (semantic, keyword, causal) to discover connections between
#' vocabulary elements.
#'
#' @param vocabulary_data List with components: activities, pressures, consequences, controls
#'        Each component should be a data frame with columns: id, name
#' @param similarity_threshold Minimum similarity score for semantic links (0-1), default 0.3
#' @param max_links_per_item Maximum number of links to keep per vocabulary item, default 5
#' @param methods Character vector of methods to use: "jaccard", "cosine", "keyword", "causal"
#' @param use_domain_knowledge Whether to use environmental domain knowledge (default TRUE)
#'
#' @return List with components:
#'   - links: Data frame of all discovered links
#'   - summary: Summary statistics by link type
#'   - causal_summary: Summary of causal links (if causal method used)
#'   - capabilities: List of available AI capabilities
#'
#' @examples
#' # Find links using all methods
#' result <- find_vocabulary_links(vocab_data, methods = c("jaccard", "keyword", "causal"))
#'
#' # Use only causal analysis
#' result <- find_vocabulary_links(vocab_data, methods = "causal")
#'
#' # Access results
#' all_links <- result$links
#' summary_stats <- result$summary
#'
#' @export
find_vocabulary_links <- function(vocabulary_data,
                                 similarity_threshold = 0.3,
                                 max_links_per_item = 5,
                                 methods = c("jaccard", "keyword", "causal"),
                                 use_domain_knowledge = TRUE) {

  cat("\n🤖 Starting AI-powered vocabulary link analysis...\n")
  cat("📋 Capabilities:",
      if(AI_LINKER_CAPABILITIES$basic_only) "Basic" else "Advanced", "\n")

  # Validate input
  if (is.null(vocabulary_data) || !is.list(vocabulary_data)) {
    stop("vocabulary_data must be a list containing vocabulary components")
  }

  # Validate methods
  valid_methods <- c("jaccard", "cosine", "keyword", "causal", "basic")
  invalid_methods <- setdiff(methods, valid_methods)
  if (length(invalid_methods) > 0) {
    warning("Invalid methods specified: ", paste(invalid_methods, collapse = ", "))
    methods <- intersect(methods, valid_methods)
  }

  if (length(methods) == 0) {
    warning("No valid methods specified, using default: jaccard, keyword, causal")
    methods <- c("jaccard", "keyword", "causal")
  }

  # Initialize results
  all_links <- data.frame()

  # Method 1: Semantic similarity analysis
  if (("jaccard" %in% methods || "cosine" %in% methods) && !AI_LINKER_CAPABILITIES$basic_only) {
    similarity_method <- if ("cosine" %in% methods) "cosine" else "jaccard"

    tryCatch({
      semantic_links <- find_semantic_connections(
        vocabulary_data,
        method = similarity_method,
        threshold = similarity_threshold
      )
      all_links <- rbind(all_links, semantic_links)
    }, error = function(e) {
      warning("Semantic analysis failed: ", e$message)
    })
  }

  # Method 2: Keyword-based connections
  if ("keyword" %in% methods) {
    tryCatch({
      keyword_links <- find_keyword_connections(vocabulary_data, ENVIRONMENTAL_THEMES)
      all_links <- rbind(all_links, keyword_links)
    }, error = function(e) {
      warning("Keyword analysis failed: ", e$message)
    })
  }

  # Method 3: Causal relationship detection
  if ("causal" %in% methods) {
    tryCatch({
      causal_links <- detect_causal_relationships(vocabulary_data, use_domain_knowledge)
      all_links <- rbind(all_links, causal_links)
    }, error = function(e) {
      warning("Causal analysis failed: ", e$message)
    })
  }

  # Fallback: Basic connections if no links found or only basic method requested
  if (nrow(all_links) == 0 || "basic" %in% methods) {
    cat("📌 Falling back to basic connection method...\n")
    basic_links <- find_basic_connections(vocabulary_data, max_links_per_item)
    all_links <- rbind(all_links, basic_links)
  }

  # Post-processing: Remove duplicates and limit links per item
  if (nrow(all_links) > 0) {
    all_links <- all_links %>%
      distinct(from_id, to_id, .keep_all = TRUE) %>%
      arrange(desc(similarity)) %>%
      group_by(from_id) %>%
      slice_head(n = max_links_per_item) %>%
      ungroup()
  }

  cat("✅ Total links found:", nrow(all_links), "\n\n")

  # Generate summary
  summary_stats <- if (nrow(all_links) > 0) {
    all_links %>%
      group_by(from_type, to_type, method) %>%
      summarise(
        count = n(),
        avg_similarity = mean(similarity),
        max_similarity = max(similarity),
        min_similarity = min(similarity),
        .groups = 'drop'
      ) %>%
      arrange(desc(count))
  } else {
    data.frame()
  }

  # Generate causal summary if causal method was used
  causal_summary <- if ("causal" %in% methods && nrow(all_links) > 0) {
    all_links %>%
      filter(grepl("causal", method)) %>%
      group_by(from_type, to_type, method) %>%
      summarise(
        count = n(),
        avg_similarity = mean(similarity),
        .groups = 'drop'
      )
  } else {
    NULL
  }

  # Return comprehensive results
  return(list(
    links = all_links,
    summary = summary_stats,
    causal_summary = causal_summary,
    capabilities = AI_LINKER_CAPABILITIES,
    methods_used = methods,
    parameters = list(
      similarity_threshold = similarity_threshold,
      max_links_per_item = max_links_per_item,
      use_domain_knowledge = use_domain_knowledge
    )
  ))
}

# =============================================================================
# INITIALIZATION MESSAGE
# =============================================================================

cat("\n🎯 Vocabulary AI Linker v3.0 loaded successfully!\n")
cat("==================================================\n\n")
cat("📦 Capabilities:\n")
cat("  - Text Mining:", if(AI_LINKER_CAPABILITIES$text_mining) "✅" else "❌", "\n")
cat("  - String Distance:", if(AI_LINKER_CAPABILITIES$string_distance) "✅" else "❌", "\n")
cat("  - Text Analysis:", if(AI_LINKER_CAPABILITIES$text_analysis) "✅" else "❌", "\n")
cat("  - Network Analysis:", if(AI_LINKER_CAPABILITIES$network_analysis) "✅" else "❌", "\n")
cat("  - Basic Mode:", if(AI_LINKER_CAPABILITIES$basic_only) "⚠️ Yes (limited features)" else "✅ No (all features available)", "\n\n")

cat("🔧 Available Functions:\n")
cat("  - find_vocabulary_links()          : Main linking function (all methods)\n")
cat("  - detect_causal_relationships()    : Causal relationship detection\n")
cat("  - find_keyword_connections()       : Keyword-based thematic linking\n")
cat("  - find_semantic_connections()      : Semantic similarity analysis\n")
cat("  - find_basic_connections()         : Basic fallback linking\n")
cat("  - calculate_semantic_similarity()  : Pairwise similarity calculation\n\n")

cat("📚 Usage Example:\n")
cat('  result <- find_vocabulary_links(vocab_data, \n')
cat('                                   methods = c("jaccard", "keyword", "causal"))\n')
cat('  links <- result$links\n')
cat('  summary <- result$summary\n\n')

cat("✅ Ready for vocabulary linking!\n")
cat("==================================================\n\n")
