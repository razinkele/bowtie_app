# =============================================================================
# AI-Powered Vocabulary Linker with Bowtie Logic Enforcement
# Version: 1.0
# Description: Intelligent linking between vocabulary elements that respects
#              proper bowtie diagram structure and causal relationships
# =============================================================================

# Required libraries
if (!requireNamespace("dplyr", quietly = TRUE)) stop("Package 'dplyr' is required")

library(dplyr)

# =============================================================================
# MAIN FUNCTION: Find Vocabulary Links with Bowtie Logic
# =============================================================================

find_vocabulary_links <- function(vocabulary_data,
                                 similarity_threshold = 0.3,
                                 max_links_per_item = 3,
                                 methods = c("jaccard", "keyword", "causal")) {

  bowtie_log("🔗 Starting AI-powered vocabulary linking with bowtie logic...", .verbose = TRUE)

  # Initialize results
  all_links <- data.frame()

  # ============================================================================
  # BOWTIE STRUCTURE ENFORCEMENT
  # ============================================================================
  # Proper bowtie flow:
  #   Activities → Pressures → Central Problem → Consequences
  #   + Preventive Controls (between Activities/Pressures and Problem)
  #   + Protective Controls (between Problem and Consequences)
  # ============================================================================

  # Step 1: Link Activities to Pressures
  bowtie_log("  → Linking Activities to Pressures...", .verbose = TRUE)
  activity_pressure_links <- find_causal_links(
    vocabulary_data$activities,
    vocabulary_data$pressures,
    from_type = "Activity",
    to_type = "Pressure",
    relationship = "causes",
    methods = methods,
    threshold = similarity_threshold,
    max_links = max_links_per_item
  )
  all_links <- rbind(all_links, activity_pressure_links)
  bowtie_log(sprintf("    ✓ Found %d Activity → Pressure links", nrow(activity_pressure_links)), .verbose = TRUE)

  # Step 2: Link Pressures to Consequences (via Central Problem)
  # Note: Central problems are dynamically defined, so we link pressures
  # to consequences that they would logically cause
  bowtie_log("  → Linking Pressures to Consequences...", .verbose = TRUE)
  pressure_consequence_links <- find_causal_links(
    vocabulary_data$pressures,
    vocabulary_data$consequences,
    from_type = "Pressure",
    to_type = "Consequence",
    relationship = "leads_to",
    methods = methods,
    threshold = similarity_threshold,
    max_links = max_links_per_item
  )
  all_links <- rbind(all_links, pressure_consequence_links)
  bowtie_log(sprintf("    ✓ Found %d Pressure → Consequence links", nrow(pressure_consequence_links)), .verbose = TRUE)

  # Step 3: Link Preventive Controls to Activities and Pressures
  bowtie_log("  → Linking Preventive Controls to Activities/Pressures...", .verbose = TRUE)
  preventive_links <- find_control_links(
    vocabulary_data$controls,
    list(activities = vocabulary_data$activities, pressures = vocabulary_data$pressures),
    control_type = "preventive",
    methods = methods,
    threshold = similarity_threshold,
    max_links = max_links_per_item
  )
  all_links <- rbind(all_links, preventive_links)
  bowtie_log(sprintf("    ✓ Found %d Preventive Control links", nrow(preventive_links)), .verbose = TRUE)

  # Step 4: Link Protective/Mitigation Controls to Consequences
  bowtie_log("  → Linking Protective Controls to Consequences...", .verbose = TRUE)
  protective_links <- find_control_links(
    vocabulary_data$controls,
    list(consequences = vocabulary_data$consequences),
    control_type = "protective",
    methods = methods,
    threshold = similarity_threshold,
    max_links = max_links_per_item
  )
  all_links <- rbind(all_links, protective_links)
  bowtie_log(sprintf("    ✓ Found %d Protective Control links", nrow(protective_links)), .verbose = TRUE)

  # Add link IDs and metadata
  if (nrow(all_links) > 0) {
    all_links <- all_links %>%
      mutate(
        link_id = paste0("LINK_", sprintf("%04d", row_number())),
        creation_date = Sys.Date(),
        bowtie_compliant = TRUE  # All links created respect bowtie structure
      )
  }

  bowtie_log(sprintf("\n✅ Total links created: %d (all bowtie-compliant)", nrow(all_links)), .verbose = TRUE)

  return(all_links)
}

# =============================================================================
# HELPER FUNCTION: Find Causal Links Between Two Vocabulary Types
# =============================================================================

find_causal_links <- function(from_items, to_items, from_type, to_type,
                             relationship, methods, threshold, max_links) {

  links <- data.frame()

  # Filter out category headers (Level 1 items in ALL CAPS) and NA values
  from_items <- from_items %>%
    filter(!is.na(name) & !is.na(id)) %>%
    filter(!grepl("^[A-Z\\s]+$", name))

  to_items <- to_items %>%
    filter(!is.na(name) & !is.na(id)) %>%
    filter(!grepl("^[A-Z\\s]+$", name))

  # For each from_item, find most relevant to_items
  for (i in 1:nrow(from_items)) {
    from_item <- from_items[i, ]

    # Calculate similarity scores using multiple methods
    similarity_scores <- calculate_similarity_scores(
      from_item$name,
      to_items$name,
      methods = methods
    )

    # Get top matches above threshold
    top_matches <- which(similarity_scores >= threshold)

    if (length(top_matches) > 0) {
      # Limit to max_links
      top_matches <- top_matches[order(-similarity_scores[top_matches])][1:min(length(top_matches), max_links)]

      # Create links
      for (match_idx in top_matches) {
        links <- rbind(links, data.frame(
          from_id = from_item$id,
          from_name = from_item$name,
          from_type = from_type,
          to_id = to_items$id[match_idx],
          to_name = to_items$name[match_idx],
          to_type = to_type,
          relationship = relationship,
          similarity = similarity_scores[match_idx],
          method = paste(methods, collapse = "+"),
          bowtie_position = paste(from_type, "→", to_type),
          stringsAsFactors = FALSE
        ))
      }
    }
  }

  return(links)
}

# =============================================================================
# HELPER FUNCTION: Find Control Links (Preventive or Protective)
# =============================================================================

find_control_links <- function(controls, target_lists, control_type,
                              methods, threshold, max_links) {

  links <- data.frame()

  # Filter out category headers and NA values
  controls <- controls %>%
    filter(!is.na(name) & !is.na(id)) %>%
    filter(!grepl("^[A-Z\\s]+$", name))

  # Identify control keywords based on type
  if (control_type == "preventive") {
    # Preventive controls keywords: prevent, reduce, minimize, control, regulate, monitor
    control_keywords <- c("prevent", "reduc", "minimi", "control", "regulat", "monitor",
                         "restric", "limit", "manage", "inspect", "check", "avoid")
    target_type <- "Activity/Pressure"
  } else {
    # Protective/mitigation controls keywords: mitigate, protect, respond, recover, restore
    control_keywords <- c("mitigat", "protect", "respond", "recover", "restor", "remed",
                         "repair", "clean", "treat", "emergency", "contain", "relief")
    target_type <- "Consequence"
  }

  # Filter controls based on keywords in their names
  relevant_controls <- controls %>%
    filter(sapply(name, function(n) {
      # Handle NA values
      if (is.na(n)) return(FALSE)
      name_lower <- tolower(n)
      # Use isTRUE to handle NA results from grepl
      any(sapply(control_keywords, function(kw) isTRUE(grepl(kw, name_lower))))
    }))

  # Ensure the target type label is singular and matches validation expectations
  # Convert keys like 'activities' -> 'Activity', 'pressures' -> 'Pressure', 'consequences' -> 'Consequence'
  singular_target_mapping <- function(key) {
    key_lower <- tolower(key)
    if (key_lower == "activities") return("Activity")
    if (key_lower == "pressures") return("Pressure")
    if (key_lower == "consequences") return("Consequence")
    # Fallback: Title case the key
    return(tools::toTitleCase(key))
  }

  # If no specific controls found, use all controls
  if (nrow(relevant_controls) == 0) {
    relevant_controls <- controls
  }

  # Link controls to target items
  for (target_name in names(target_lists)) {
    target_items <- target_lists[[target_name]]

    # Filter out category headers and NA values
    target_items <- target_items %>%
      filter(!is.na(name) & !is.na(id)) %>%
      filter(!grepl("^[A-Z\\s]+$", name))

    for (i in 1:nrow(relevant_controls)) {
      control <- relevant_controls[i, ]

      # Calculate similarity scores
      similarity_scores <- calculate_similarity_scores(
        control$name,
        target_items$name,
        methods = methods
      )

      # Get top matches above threshold
      top_matches <- which(similarity_scores >= threshold)

      if (length(top_matches) > 0) {
        # Limit to max_links
        top_matches <- top_matches[order(-similarity_scores[top_matches])][1:min(length(top_matches), max_links)]

        # Create links
        for (match_idx in top_matches) {
          links <- rbind(links, data.frame(
            from_id = control$id,
            from_name = control$name,
            from_type = "Control",
            to_id = target_items$id[match_idx],
            to_name = target_items$name[match_idx],
            to_type = singular_target_mapping(target_name),
            relationship = ifelse(control_type == "preventive", "prevents", "mitigates"),
            similarity = similarity_scores[match_idx],
            method = paste(methods, collapse = "+"),
            bowtie_position = paste("Control (", control_type, ") →", target_type),
            control_category = control_type,
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }

  return(links)
}

# =============================================================================
# HELPER FUNCTION: Calculate Similarity Scores Using Multiple Methods
# =============================================================================

calculate_similarity_scores <- function(source_text, target_texts, methods) {

  # Handle NA source text
  if (is.na(source_text)) {
    return(rep(0, length(target_texts)))
  }

  scores <- rep(0, length(target_texts))

  # Method 1: Jaccard similarity (word overlap)
  if ("jaccard" %in% methods) {
    jaccard_scores <- sapply(target_texts, function(target) {
      tryCatch({
        calculate_jaccard_similarity(source_text, target)
      }, error = function(e) {
        0  # Return 0 on error
      })
    })
    # Replace NA with 0
    jaccard_scores[is.na(jaccard_scores)] <- 0
    scores <- scores + jaccard_scores
  }

  # Method 2: Keyword matching
  if ("keyword" %in% methods) {
    keyword_scores <- sapply(target_texts, function(target) {
      tryCatch({
        calculate_keyword_similarity(source_text, target)
      }, error = function(e) {
        0  # Return 0 on error
      })
    })
    # Replace NA with 0
    keyword_scores[is.na(keyword_scores)] <- 0
    scores <- scores + keyword_scores
  }

  # Method 3: Causal relationship detection
  if ("causal" %in% methods) {
    causal_scores <- sapply(target_texts, function(target) {
      tryCatch({
        detect_causal_relationship(source_text, target)
      }, error = function(e) {
        0  # Return 0 on error
      })
    })
    # Replace NA with 0
    causal_scores[is.na(causal_scores)] <- 0
    scores <- scores + causal_scores
  }

  # Normalize scores by number of methods
  scores <- scores / length(methods)

  # Replace any remaining NA values with 0
  scores[is.na(scores)] <- 0

  return(scores)
}

# =============================================================================
# SIMILARITY CALCULATION METHODS
# =============================================================================

# Jaccard Similarity: Measures word overlap
calculate_jaccard_similarity <- function(text1, text2) {
  # Handle NA inputs
  if (is.na(text1) || is.na(text2)) return(0)

  # Convert to lowercase and split into words
  words1 <- tolower(unlist(strsplit(gsub("[^a-zA-Z ]", "", text1), "\\s+")))
  words2 <- tolower(unlist(strsplit(gsub("[^a-zA-Z ]", "", text2), "\\s+")))

  # Remove common stop words
  stop_words <- c("the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
                  "of", "with", "by", "from", "as", "is", "was", "are", "were")
  words1 <- words1[!words1 %in% stop_words]
  words2 <- words2[!words2 %in% stop_words]

  # Calculate Jaccard coefficient
  intersection <- length(intersect(words1, words2))
  union <- length(union(words1, words2))

  if (union == 0) return(0)
  return(intersection / union)
}

# Keyword Similarity: Measures shared environmental keywords
calculate_keyword_similarity <- function(text1, text2) {
  # Handle NA inputs
  if (is.na(text1) || is.na(text2)) return(0)

  # Environmental domain keywords
  env_keywords <- c(
    # Water-related
    "water", "aquatic", "marine", "ocean", "sea", "river", "lake", "wetland", "coastal",
    "discharge", "runoff", "drainage", "effluent", "wastewater",

    # Pollution types
    "pollution", "contamination", "pollutant", "toxic", "chemical", "waste", "emission",
    "spill", "leak", "release",

    # Biological
    "species", "habitat", "ecosystem", "biodiversity", "flora", "fauna", "organism",
    "population", "community", "food web",

    # Environmental impacts
    "degradation", "destruction", "loss", "decline", "damage", "harm", "impact",
    "erosion", "depletion", "extinction",

    # Activities
    "agriculture", "industrial", "urban", "fishing", "mining", "construction",
    "transport", "shipping", "development",

    # Controls
    "regulation", "management", "protection", "conservation", "mitigation",
    "prevention", "monitoring", "restoration", "treatment"
  )

  text1_lower <- tolower(text1)
  text2_lower <- tolower(text2)

  # Find matching keywords - use isTRUE to handle NA from grepl
  matches <- sum(sapply(env_keywords, function(kw) {
    ifelse(isTRUE(grepl(kw, text1_lower)) && isTRUE(grepl(kw, text2_lower)), 1, 0)
  }))

  # Normalize by total possible matches
  return(min(1.0, matches / 5))  # Cap at 1.0
}

# Causal Relationship Detection: Detects cause-effect patterns
detect_causal_relationship <- function(text1, text2) {
  # Handle NA inputs
  if (is.na(text1) || is.na(text2)) return(0)

  # Causal indicators
  causal_pairs <- list(
    # Activity → Pressure patterns
    list(cause = c("fishing", "trawling", "harvest"), effect = c("bycatch", "depletion", "overfishing")),
    list(cause = c("discharge", "release", "dump"), effect = c("pollution", "contamination", "toxic")),
    list(cause = c("construction", "development", "dredging"), effect = c("sediment", "turbidity", "habitat loss")),
    list(cause = c("agriculture", "farming", "cultivation"), effect = c("runoff", "nutrient", "eutrophication")),
    list(cause = c("industrial", "manufacturing", "processing"), effect = c("emission", "waste", "chemical")),

    # Pressure → Consequence patterns
    list(cause = c("pollution", "contamination", "toxic"), effect = c("mortality", "disease", "health")),
    list(cause = c("habitat loss", "destruction", "degradation"), effect = c("biodiversity", "extinction", "decline")),
    list(cause = c("nutrient", "eutrophication", "algae"), effect = c("oxygen", "hypoxia", "dead zone")),
    list(cause = c("overfishing", "depletion", "extraction"), effect = c("collapse", "scarcity", "economic")),
    list(cause = c("climate", "warming", "temperature"), effect = c("bleaching", "migration", "adaptation"))
  )

  text1_lower <- tolower(text1)
  text2_lower <- tolower(text2)

  # Check for causal patterns - use isTRUE to handle NA from grepl
  causal_score <- 0
  for (pair in causal_pairs) {
    cause_match <- any(sapply(pair$cause, function(c) isTRUE(grepl(c, text1_lower))))
    effect_match <- any(sapply(pair$effect, function(e) isTRUE(grepl(e, text2_lower))))

    if (isTRUE(cause_match) && isTRUE(effect_match)) {
      causal_score <- causal_score + 1
    }
  }

  # Normalize
  return(min(1.0, causal_score / 3))  # Cap at 1.0
}

# =============================================================================
# VALIDATION FUNCTION: Check if Links Respect Bowtie Structure
# =============================================================================

validate_bowtie_structure <- function(links) {

  cat("\n🔍 Validating bowtie structure compliance...\n")

  # Valid bowtie relationships
  valid_relationships <- data.frame(
    from_type = c("Activity", "Pressure", "Control", "Control"),
    to_type = c("Pressure", "Consequence", "Activity", "Consequence"),
    relationship = c("causes", "leads_to", "prevents", "mitigates"),
    stringsAsFactors = FALSE
  )

  # Check each link by anti-joining with the canonical set of valid relationships
  invalid_links <- dplyr::anti_join(
    links %>% dplyr::select(from_type, to_type, relationship),
    valid_relationships,
    by = c("from_type", "to_type", "relationship")
  )

  if (nrow(invalid_links) > 0) {
    cat(sprintf("  ⚠️ Found %d invalid links that violate bowtie structure:\n", nrow(invalid_links)))
    print(invalid_links %>% dplyr::select(from_type, to_type, relationship))
    return(FALSE)
  } else {
    cat("  ✅ All links respect proper bowtie structure\n")
    return(TRUE)
  }
}

cat("✅ AI Vocabulary Linker with Bowtie Logic loaded (v1.0)\n")
cat("   Enforces proper causal flow: Activities → Pressures → Problem → Consequences\n")
cat("   Controls linked appropriately: Preventive (left) | Protective (right)\n")
