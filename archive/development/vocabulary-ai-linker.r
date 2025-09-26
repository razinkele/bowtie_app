# vocabulary_ai_linker.R
# AI-powered vocabulary relationship finder with ENHANCED causal analysis
# Version 2.0 - Advanced causal relationship detection for environmental bowtie analysis

# Load required libraries
if (!require("tm")) install.packages("tm")
if (!require("stringdist")) install.packages("stringdist")
if (!require("tidytext")) install.packages("tidytext")
if (!require("widyr")) install.packages("widyr")
if (!require("igraph")) install.packages("igraph")
if (!require("textrank")) install.packages("textrank")

library(tm)
library(stringdist)
library(tidytext)
library(widyr)
library(igraph)
library(textrank)
library(dplyr)
library(tidyr)

# Function to preprocess text for analysis
preprocess_text <- function(text) {
  text %>%
    tolower() %>%
    gsub("[[:punct:]]", " ", .) %>%
    gsub("\\s+", " ", .) %>%
    trimws()
}

# Function to extract key terms from vocabulary items
extract_key_terms <- function(vocab_data) {
  # Combine all text
  all_text <- paste(vocab_data$name, collapse = " ")
  
  # Create corpus
  corpus <- Corpus(VectorSource(all_text))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, stripWhitespace)
  
  # Create term-document matrix
  tdm <- TermDocumentMatrix(corpus)
  term_freq <- sort(rowSums(as.matrix(tdm)), decreasing = TRUE)
  
  # Get top terms
  top_terms <- names(term_freq)[1:min(50, length(term_freq))]
  
  return(list(
    terms = top_terms,
    frequencies = term_freq[top_terms]
  ))
}

# Function to calculate semantic similarity between two text strings
calculate_semantic_similarity <- function(text1, text2, method = "jaccard") {
  # Preprocess texts
  text1_clean <- preprocess_text(text1)
  text2_clean <- preprocess_text(text2)
  
  # Tokenize
  tokens1 <- unlist(strsplit(text1_clean, " "))
  tokens2 <- unlist(strsplit(text2_clean, " "))
  
  # Remove empty tokens
  tokens1 <- tokens1[tokens1 != ""]
  tokens2 <- tokens2[tokens2 != ""]
  
  if (length(tokens1) == 0 || length(tokens2) == 0) return(0)
  
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
    
    similarity <- sum(vec1 * vec2) / (sqrt(sum(vec1^2)) * sqrt(sum(vec2^2)))
  } else {
    # String distance similarity
    similarity <- 1 - stringdist(text1_clean, text2_clean, method = "jw")
  }
  
  return(similarity)
}

# ENHANCED: Advanced causal relationship detection
detect_causal_relationships <- function(vocabulary_data) {
  cat("🔍 Performing advanced causal relationship analysis...\n")
  
  causal_links <- data.frame()
  
  # Enhanced causal patterns with environmental focus
  causal_patterns <- list(
    # Direct causation patterns
    direct_cause = list(
      keywords = c("causes", "leads to", "results in", "creates", "generates", 
                   "produces", "induces", "triggers", "drives", "brings about"),
      strength = 0.9,
      direction = "forward"
    ),
    
    # Impact patterns
    impact = list(
      keywords = c("impacts", "affects", "influences", "damages", "harms", 
                   "degrades", "threatens", "compromises", "disrupts", "impairs"),
      strength = 0.85,
      direction = "forward"
    ),
    
    # Source patterns
    source = list(
      keywords = c("from", "due to", "because of", "as a result of", 
                   "attributed to", "stemming from", "arising from"),
      strength = 0.8,
      direction = "backward"
    ),
    
    # Contribution patterns
    contribution = list(
      keywords = c("contributes to", "adds to", "increases", "exacerbates", 
                   "intensifies", "amplifies", "worsens", "accelerates"),
      strength = 0.75,
      direction = "forward"
    ),
    
    # Prevention/mitigation patterns
    prevention = list(
      keywords = c("prevents", "reduces", "mitigates", "controls", "limits", 
                   "minimizes", "alleviates", "diminishes", "counters"),
      strength = 0.7,
      direction = "intervention"
    )
  )
  
  # Environmental process chains
  process_chains <- list(
    # Pollution pathway
    pollution = list(
      chain = c("emission", "discharge", "release") %>% 
              c("contamination", "pollution") %>%
              c("degradation", "damage", "harm"),
      types = list(
        start = c("Activity", "Pressure"),
        middle = c("Pressure"),
        end = c("Consequence")
      )
    ),
    
    # Ecosystem impact pathway
    ecosystem = list(
      chain = c("disturbance", "alteration", "modification") %>%
              c("habitat loss", "fragmentation", "degradation") %>%
              c("biodiversity loss", "extinction", "ecosystem collapse"),
      types = list(
        start = c("Activity"),
        middle = c("Pressure"),
        end = c("Consequence")
      )
    ),
    
    # Water quality pathway
    water = list(
      chain = c("runoff", "discharge", "leakage") %>%
              c("nutrient loading", "contamination", "pollution") %>%
              c("eutrophication", "dead zones", "water quality degradation"),
      types = list(
        start = c("Activity", "Pressure"),
        middle = c("Pressure"),
        end = c("Consequence")
      )
    ),
    
    # Climate pathway
    climate = list(
      chain = c("emission", "release", "combustion") %>%
              c("greenhouse gas", "carbon", "methane") %>%
              c("warming", "climate change", "extreme weather"),
      types = list(
        start = c("Activity"),
        middle = c("Pressure"),
        end = c("Consequence")
      )
    )
  )
  
  # Get all vocabulary items
  all_activities <- vocabulary_data$activities
  all_pressures <- vocabulary_data$pressures
  all_consequences <- vocabulary_data$consequences
  all_controls <- vocabulary_data$controls
  
  # 1. Activity → Pressure causal analysis
  cat("  Analyzing Activity → Pressure causal links...\n")
  for (i in 1:nrow(all_activities)) {
    activity <- all_activities[i, ]
    activity_words <- tolower(strsplit(activity$name, " ")[[1]])
    
    for (j in 1:nrow(all_pressures)) {
      pressure <- all_pressures[j, ]
      pressure_words <- tolower(strsplit(pressure$name, " ")[[1]])
      
      # Check for causal keywords
      causal_score <- 0
      causal_method <- ""
      
      # Method 1: Direct word matching
      common_words <- intersect(activity_words, pressure_words)
      if (length(common_words) > 0) {
        causal_score <- length(common_words) / min(length(activity_words), length(pressure_words))
        causal_method <- "word_match"
      }
      
      # Method 2: Process chain detection
      for (chain_name in names(process_chains)) {
        chain <- process_chains[[chain_name]]
        
        # Check if activity contains chain start terms
        activity_has_start <- any(sapply(chain$chain[1:length(chain$chain)/3], 
                                       function(term) grepl(term, tolower(activity$name))))
        
        # Check if pressure contains chain middle terms
        pressure_has_middle <- any(sapply(chain$chain[(length(chain$chain)/3 + 1):(2*length(chain$chain)/3)], 
                                        function(term) grepl(term, tolower(pressure$name))))
        
        if (activity_has_start && pressure_has_middle) {
          causal_score <- max(causal_score, 0.8)
          causal_method <- paste("process_chain", chain_name, sep = "_")
        }
      }
      
      # Method 3: Environmental logic rules
      # Rule: "operations" → "emission/discharge"
      if (grepl("operation|practice|activity", tolower(activity$name)) && 
          grepl("emission|discharge|release|runoff", tolower(pressure$name))) {
        causal_score <- max(causal_score, 0.7)
        causal_method <- "environmental_logic"
      }
      
      # Rule: "industrial/agricultural" → "pollution/contamination"
      if (grepl("industrial|agricultural|manufacturing", tolower(activity$name)) && 
          grepl("pollution|contamination|waste", tolower(pressure$name))) {
        causal_score <- max(causal_score, 0.75)
        causal_method <- "sector_impact"
      }
      
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
  
  # 2. Pressure → Consequence causal analysis
  cat("  Analyzing Pressure → Consequence causal links...\n")
  for (i in 1:nrow(all_pressures)) {
    pressure <- all_pressures[i, ]
    
    for (j in 1:nrow(all_consequences)) {
      consequence <- all_consequences[j, ]
      
      causal_score <- 0
      causal_method <- ""
      
      # Enhanced causal detection
      # Method 1: Impact keywords
      for (pattern_name in names(causal_patterns)) {
        pattern <- causal_patterns[[pattern_name]]
        if (pattern$direction == "forward") {
          pattern_found <- any(sapply(pattern$keywords, 
                                     function(kw) grepl(kw, tolower(pressure$name))))
          if (pattern_found) {
            causal_score <- max(causal_score, pattern$strength * 0.6)
            causal_method <- pattern_name
          }
        }
      }
      
      # Method 2: Consequence keywords in pressure
      consequence_indicators <- c("loss", "degradation", "damage", "death", "extinction",
                                 "collapse", "depletion", "destruction", "impact")
      
      if (any(sapply(consequence_indicators, function(ind) grepl(ind, tolower(consequence$name))))) {
        # Check if pressure relates to consequence
        pressure_words <- tolower(strsplit(pressure$name, " ")[[1]])
        consequence_words <- tolower(strsplit(consequence$name, " ")[[1]])
        
        common_concepts <- intersect(pressure_words, consequence_words)
        if (length(common_concepts) > 0) {
          causal_score <- max(causal_score, 0.7)
          causal_method <- "impact_alignment"
        }
      }
      
      # Method 3: Domain-specific rules
      # Water pollution → water consequences
      if (grepl("water|aquatic|marine", tolower(pressure$name)) && 
          grepl("water|aquatic|marine|fish", tolower(consequence$name))) {
        causal_score <- max(causal_score, 0.8)
        causal_method <- "domain_water"
      }
      
      # Air pollution → air/health consequences
      if (grepl("air|emission|atmospheric", tolower(pressure$name)) && 
          grepl("respiratory|health|air quality", tolower(consequence$name))) {
        causal_score <- max(causal_score, 0.8)
        causal_method <- "domain_air"
      }
      
      # Habitat pressure → biodiversity consequences
      if (grepl("habitat|ecosystem", tolower(pressure$name)) && 
          grepl("biodiversity|species|extinction", tolower(consequence$name))) {
        causal_score <- max(causal_score, 0.85)
        causal_method <- "domain_biodiversity"
      }
      
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
  
  # 3. Control → Pressure/Consequence intervention analysis
  cat("  Analyzing Control intervention relationships...\n")
  for (i in 1:nrow(all_controls)) {
    control <- all_controls[i, ]
    
    # Check controls against pressures
    for (j in 1:nrow(all_pressures)) {
      pressure <- all_pressures[j, ]
      
      causal_score <- 0
      causal_method <- ""
      
      # Check for intervention keywords
      intervention_keywords <- c("prevent", "control", "reduce", "mitigate", "manage",
                               "treat", "filter", "clean", "protect", "restore")
      
      control_has_intervention <- any(sapply(intervention_keywords, 
                                           function(kw) grepl(kw, tolower(control$name))))
      
      if (control_has_intervention) {
        # Check if control targets the pressure
        control_words <- tolower(strsplit(control$name, " ")[[1]])
        pressure_words <- tolower(strsplit(pressure$name, " ")[[1]])
        
        target_match <- length(intersect(control_words, pressure_words))
        if (target_match > 0) {
          causal_score <- min(0.9, 0.4 + (target_match * 0.2))
          causal_method <- "targeted_intervention"
        }
      }
      
      # Specific intervention rules
      # Wastewater treatment → water pollution
      if (grepl("treatment|purification", tolower(control$name)) && 
          grepl("water|sewage|effluent", tolower(pressure$name))) {
        causal_score <- max(causal_score, 0.85)
        causal_method <- "treatment_intervention"
      }
      
      # Emission control → air pollution
      if (grepl("emission control|scrubber|filter", tolower(control$name)) && 
          grepl("emission|air|atmospheric", tolower(pressure$name))) {
        causal_score <- max(causal_score, 0.85)
        causal_method <- "emission_control"
      }
      
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
  
  # 4. Multi-hop causal chain detection
  cat("  Detecting multi-hop causal chains...\n")
  
  # Find Activity → Pressure → Consequence chains
  if (nrow(causal_links) > 0) {
    ap_links <- causal_links[causal_links$causal_type == "activity_pressure", ]
    pc_links <- causal_links[causal_links$causal_type == "pressure_consequence", ]
    
    for (i in 1:nrow(ap_links)) {
      ap_link <- ap_links[i, ]
      
      # Find consequences linked to this pressure
      matching_pc <- pc_links[pc_links$from_id == ap_link$to_id, ]
      
      if (nrow(matching_pc) > 0) {
        for (j in 1:nrow(matching_pc)) {
          pc_link <- matching_pc[j, ]
          
          # Create activity → consequence link with chain bonus
          chain_score <- (ap_link$similarity + pc_link$similarity) / 2 * 1.1  # 10% bonus for complete chain
          
          causal_links <- rbind(causal_links, data.frame(
            from_id = ap_link$from_id,
            from_name = ap_link$from_name,
            from_type = "Activity",
            to_id = pc_link$to_id,
            to_name = pc_link$to_name,
            to_type = "Consequence",
            similarity = min(1, chain_score),
            method = "causal_chain_complete",
            causal_type = "activity_consequence_chain",
            stringsAsFactors = FALSE
          ))
        }
      }
    }
  }
  
  cat("✅ Found", nrow(causal_links), "causal relationships\n")
  
  return(causal_links)
}

# Main function to find links between vocabulary groups
find_vocabulary_links <- function(vocabulary_data, 
                                 similarity_threshold = 0.3,
                                 max_links_per_item = 5,
                                 methods = c("jaccard", "keyword", "causal")) {
  
  cat("🤖 Starting AI-powered vocabulary link analysis...\n")
  
  # Extract data for each vocabulary type
  activities <- vocabulary_data$activities
  pressures <- vocabulary_data$pressures
  consequences <- vocabulary_data$consequences
  controls <- vocabulary_data$controls
  
  # Initialize results
  all_links <- data.frame()
  keyword_connections <- list()
  
  # Method 1: Direct semantic similarity analysis
  if ("jaccard" %in% methods || "cosine" %in% methods) {
    cat("📊 Analyzing semantic similarities...\n")
    
    similarity_method <- if ("cosine" %in% methods) "cosine" else "jaccard"
    
    # Create all vocabulary items with their types
    all_items <- rbind(
      data.frame(id = activities$id, name = activities$name, type = "Activity", stringsAsFactors = FALSE),
      data.frame(id = pressures$id, name = pressures$name, type = "Pressure", stringsAsFactors = FALSE),
      data.frame(id = consequences$id, name = consequences$name, type = "Consequence", stringsAsFactors = FALSE),
      data.frame(id = controls$id, name = controls$name, type = "Control", stringsAsFactors = FALSE)
    )
    
    # Calculate pairwise similarities between different types
    for (i in 1:(nrow(all_items) - 1)) {
      for (j in (i + 1):nrow(all_items)) {
        # Only link different types
        if (all_items$type[i] != all_items$type[j]) {
          similarity <- calculate_semantic_similarity(
            all_items$name[i], 
            all_items$name[j],
            method = similarity_method
          )
          
          if (similarity >= similarity_threshold) {
            all_links <- rbind(all_links, data.frame(
              from_id = all_items$id[i],
              from_name = all_items$name[i],
              from_type = all_items$type[i],
              to_id = all_items$id[j],
              to_name = all_items$name[j],
              to_type = all_items$type[j],
              similarity = similarity,
              method = similarity_method,
              stringsAsFactors = FALSE
            ))
          }
        }
      }
    }
  }
  
  # Method 2: Keyword-based connections
  if ("keyword" %in% methods) {
    cat("🔍 Identifying keyword-based connections...\n")
    
    # Define environmental keywords and their relationships
    keyword_rules <- list(
      # Water-related connections
      water = list(
        keywords = c("water", "aquatic", "marine", "river", "lake", "ocean", "sea", "coastal", 
                    "wetland", "groundwater", "wastewater", "sewage", "stormwater", "hydrological"),
        link_strength = 0.8
      ),
      # Pollution connections
      pollution = list(
        keywords = c("pollution", "contamination", "discharge", "emission", "runoff", "waste",
                    "toxic", "chemical", "nutrient", "pollutant", "effluent", "leachate"),
        link_strength = 0.7
      ),
      # Ecosystem connections
      ecosystem = list(
        keywords = c("ecosystem", "habitat", "biodiversity", "species", "wildlife", "fauna", 
                    "flora", "ecological", "environment", "conservation", "nature"),
        link_strength = 0.7
      ),
      # Climate connections
      climate = list(
        keywords = c("climate", "greenhouse", "carbon", "emission", "warming", "temperature",
                    "weather", "methane", "co2", "ghg", "fossil fuel"),
        link_strength = 0.6
      ),
      # Agriculture connections
      agriculture = list(
        keywords = c("agriculture", "farming", "livestock", "crop", "fertilizer", "pesticide",
                    "soil", "erosion", "irrigation", "cultivation", "grazing"),
        link_strength = 0.7
      ),
      # Industrial connections
      industrial = list(
        keywords = c("industrial", "manufacturing", "factory", "production", "chemical",
                    "waste", "discharge", "emission", "processing", "refinery"),
        link_strength = 0.6
      ),
      # Health connections
      health = list(
        keywords = c("health", "disease", "illness", "respiratory", "contamination", "exposure",
                    "toxic", "safety", "risk", "mortality", "morbidity"),
        link_strength = 0.6
      ),
      # Management connections
      management = list(
        keywords = c("management", "control", "mitigation", "prevention", "monitoring",
                    "treatment", "restoration", "protection", "regulation", "compliance"),
        link_strength = 0.5
      )
    )
    
    # Find keyword connections
    all_items <- rbind(
      data.frame(id = activities$id, name = activities$name, type = "Activity", stringsAsFactors = FALSE),
      data.frame(id = pressures$id, name = pressures$name, type = "Pressure", stringsAsFactors = FALSE),
      data.frame(id = consequences$id, name = consequences$name, type = "Consequence", stringsAsFactors = FALSE),
      data.frame(id = controls$id, name = controls$name, type = "Control", stringsAsFactors = FALSE)
    )
    
    # Analyze each item for keywords
    for (theme in names(keyword_rules)) {
      theme_keywords <- keyword_rules[[theme]]$keywords
      theme_strength <- keyword_rules[[theme]]$link_strength
      
      # Find items containing theme keywords
      theme_items <- all_items[grepl(paste(theme_keywords, collapse = "|"), 
                                    tolower(all_items$name)), ]
      
      if (nrow(theme_items) > 1) {
        # Create connections between items sharing the same theme
        for (i in 1:(nrow(theme_items) - 1)) {
          for (j in (i + 1):nrow(theme_items)) {
            if (theme_items$type[i] != theme_items$type[j]) {
              all_links <- rbind(all_links, data.frame(
                from_id = theme_items$id[i],
                from_name = theme_items$name[i],
                from_type = theme_items$type[i],
                to_id = theme_items$id[j],
                to_name = theme_items$name[j],
                to_type = theme_items$type[j],
                similarity = theme_strength,
                method = paste("keyword", theme, sep = "_"),
                stringsAsFactors = FALSE
              ))
            }
          }
        }
        
        keyword_connections[[theme]] <- theme_items
      }
    }
  }
  
  # Method 3: ENHANCED Causal relationship detection
  if ("causal" %in% methods) {
    causal_links <- detect_causal_relationships(vocabulary_data)
    all_links <- rbind(all_links, causal_links)
  }
  
  # Remove duplicate links and sort by similarity
  if (nrow(all_links) > 0) {
    all_links <- all_links %>%
      distinct(from_id, to_id, .keep_all = TRUE) %>%
      arrange(desc(similarity))
    
    # Limit links per item
    all_links <- all_links %>%
      group_by(from_id) %>%
      slice_head(n = max_links_per_item) %>%
      ungroup()
  }
  
  cat("✅ Found", nrow(all_links), "vocabulary links\n")
  
  return(list(
    links = all_links,
    keyword_connections = keyword_connections,
    summary = summarize_links(all_links),
    causal_summary = if("causal" %in% methods && nrow(all_links) > 0) {
      all_links %>%
        filter(grepl("causal", method)) %>%
        group_by(from_type, to_type, method) %>%
        summarise(
          count = n(),
          avg_similarity = mean(similarity),
          .groups = 'drop'
        )
    } else NULL
  ))
}

# Function to summarize discovered links
summarize_links <- function(links) {
  if (nrow(links) == 0) {
    return(data.frame())
  }
  
  summary <- links %>%
    group_by(from_type, to_type, method) %>%
    summarise(
      count = n(),
      avg_similarity = mean(similarity),
      max_similarity = max(similarity),
      min_similarity = min(similarity),
      .groups = 'drop'
    ) %>%
    arrange(desc(count))
  
  return(summary)
}

# Function to create a network graph of vocabulary links
create_vocabulary_network <- function(links, min_similarity = 0.3) {
  if (nrow(links) == 0) {
    return(NULL)
  }
  
  # Filter by minimum similarity
  filtered_links <- links %>%
    filter(similarity >= min_similarity)
  
  if (nrow(filtered_links) == 0) {
    return(NULL)
  }
  
  # Create igraph object
  g <- graph_from_data_frame(
    d = filtered_links %>% select(from_id, to_id, similarity),
    directed = TRUE  # Changed to directed for causal relationships
  )
  
  # Add node attributes
  node_data <- rbind(
    filtered_links %>% select(id = from_id, name = from_name, type = from_type) %>% distinct(),
    filtered_links %>% select(id = to_id, name = to_name, type = to_type) %>% distinct()
  ) %>% distinct()
  
  # Match node order with graph vertices
  vertex_ids <- V(g)$name
  node_data <- node_data[match(vertex_ids, node_data$id), ]
  
  V(g)$label <- node_data$name
  V(g)$type <- node_data$type
  
  # Set node colors by type
  type_colors <- c(
    "Activity" = "#8E44AD",
    "Pressure" = "#E74C3C",
    "Consequence" = "#E67E22",
    "Control" = "#27AE60"
  )
  V(g)$color <- type_colors[V(g)$type]
  
  # Set edge attributes
  E(g)$weight <- E(g)$similarity
  
  return(g)
}

# Function to find causal paths between vocabulary items
find_causal_paths <- function(links, start_type = "Activity", end_type = "Consequence", max_length = 4) {
  if (nrow(links) == 0) {
    return(list())
  }
  
  # Filter for causal links only
  causal_links <- links %>% filter(grepl("causal", method))
  
  if (nrow(causal_links) == 0) {
    return(list())
  }
  
  # Create directed graph
  g <- graph_from_data_frame(
    d = causal_links %>% select(from_id, to_id, similarity),
    directed = TRUE
  )
  
  # Get all start and end nodes
  all_nodes <- V(g)$name
  node_types <- sapply(all_nodes, function(id) {
    type_info <- unique(c(
      causal_links$from_type[causal_links$from_id == id],
      causal_links$to_type[causal_links$to_id == id]
    ))
    type_info[1]  # Take first if multiple
  })
  
  start_nodes <- all_nodes[node_types == start_type]
  end_nodes <- all_nodes[node_types == end_type]
  
  # Find all paths
  all_paths <- list()
  
  for (start in start_nodes) {
    for (end in end_nodes) {
      if (start %in% V(g)$name && end %in% V(g)$name) {
        paths <- all_simple_paths(g, from = start, to = end, mode = "out", cutoff = max_length)
        
        for (path in paths) {
          path_ids <- V(g)$name[path]
          path_edges <- E(g, path = path)
          
          # Get path details
          path_info <- list(
            path_ids = path_ids,
            path_length = length(path_ids) - 1,
            total_similarity = sum(path_edges$similarity),
            avg_similarity = mean(path_edges$similarity),
            path_string = paste(path_ids, collapse = " → ")
          )
          
          all_paths <- append(all_paths, list(path_info))
        }
      }
    }
  }
  
  # Sort by average similarity
  if (length(all_paths) > 0) {
    all_paths <- all_paths[order(sapply(all_paths, function(p) p$avg_similarity), decreasing = TRUE)]
  }
  
  return(all_paths)
}

# Function to identify vocabulary clusters
identify_vocabulary_clusters <- function(links, min_similarity = 0.4, focus_causal = TRUE) {
  if (nrow(links) == 0) {
    return(list())
  }
  
  # Filter for causal links if requested
  if (focus_causal) {
    links <- links %>% filter(grepl("causal", method))
  }
  
  if (nrow(links) == 0) {
    return(list())
  }
  
  # Create graph
  g <- create_vocabulary_network(links, min_similarity)
  
  if (is.null(g)) {
    return(list())
  }
  
  # Find communities using different algorithms
  communities_louvain <- cluster_louvain(g, weights = E(g)$weight)
  communities_walktrap <- cluster_walktrap(g, weights = E(g)$weight)
  
  # For causal analysis, also detect hierarchical structure
  if (focus_causal) {
    # Detect layers in the causal network
    layers <- list()
    node_types <- V(g)$type
    
    layers$sources <- V(g)$name[node_types == "Activity"]
    layers$intermediates <- V(g)$name[node_types %in% c("Pressure")]
    layers$interventions <- V(g)$name[node_types == "Control"]
    layers$outcomes <- V(g)$name[node_types == "Consequence"]
  }
  
  # Extract cluster information
  clusters <- list(
    louvain = data.frame(
      id = V(g)$name,
      cluster = membership(communities_louvain),
      type = V(g)$type,
      stringsAsFactors = FALSE
    ),
    walktrap = data.frame(
      id = V(g)$name,
      cluster = membership(communities_walktrap),
      type = V(g)$type,
      stringsAsFactors = FALSE
    )
  )
  
  if (exists("layers")) {
    clusters$causal_layers <- layers
  }
  
  return(clusters)
}

# Enhanced recommendation function with causal focus
generate_link_recommendations <- function(vocabulary_data, existing_links = NULL, focus = "causal") {
  cat("💡 Generating AI-powered link recommendations with", focus, "focus...\n")
  
  # Find all potential links
  methods_to_use <- if (focus == "causal") c("causal") else c("jaccard", "keyword", "causal")
  
  all_potential_links <- find_vocabulary_links(
    vocabulary_data,
    similarity_threshold = 0.2,
    max_links_per_item = 20,
    methods = methods_to_use
  )
  
  if (nrow(all_potential_links$links) == 0) {
    return(data.frame())
  }
  
  # If existing links provided, filter out already established connections
  if (!is.null(existing_links) && nrow(existing_links) > 0) {
    potential_links <- all_potential_links$links %>%
      anti_join(existing_links, by = c("from_id", "to_id"))
  } else {
    potential_links <- all_potential_links$links
  }
  
  # Enhanced ranking for causal relationships
  recommendations <- potential_links %>%
    mutate(
      # Score based on similarity and link type importance
      type_score = case_when(
        from_type == "Activity" & to_type == "Pressure" ~ 1.0,
        from_type == "Pressure" & to_type == "Consequence" ~ 0.95,
        from_type == "Control" & to_type %in% c("Pressure") ~ 0.9,
        from_type == "Activity" & to_type == "Consequence" & grepl("chain", method) ~ 0.85,
        from_type == "Control" & to_type == "Consequence" ~ 0.8,
        TRUE ~ 0.5
      ),
      # Boost causal links
      method_score = if_else(grepl("causal", method), 1.2, 1.0),
      # Final recommendation score
      recommendation_score = similarity * type_score * method_score
    ) %>%
    arrange(desc(recommendation_score)) %>%
    head(30)  # Top 30 recommendations
  
  # Add recommendation reasoning
  recommendations <- recommendations %>%
    mutate(
      reasoning = case_when(
        grepl("causal_chain", method) ~ "Complete causal pathway detected",
        grepl("causal_intervention", method) ~ "Control measure targets this issue",
        grepl("causal_impact", method) ~ "Direct impact relationship",
        grepl("causal_environmental_logic", method) ~ "Environmental process connection",
        grepl("causal_domain", method) ~ "Domain-specific causal link",
        grepl("causal", method) ~ "Causal relationship detected",
        TRUE ~ "Semantic similarity"
      )
    )
  
  return(recommendations)
}

# Function to analyze causal network structure
analyze_causal_structure <- function(links) {
  causal_links <- links %>% filter(grepl("causal", method))
  
  if (nrow(causal_links) == 0) {
    return(list(message = "No causal links found"))
  }
  
  # Create directed graph
  g <- create_vocabulary_network(causal_links, min_similarity = 0)
  
  analysis <- list(
    total_causal_links = nrow(causal_links),
    
    link_types = causal_links %>%
      group_by(from_type, to_type) %>%
      summarise(count = n(), avg_strength = mean(similarity), .groups = 'drop'),
    
    strongest_chains = find_causal_paths(causal_links, max_length = 5) %>%
      head(10),
    
    key_drivers = causal_links %>%
      group_by(from_id, from_name, from_type) %>%
      summarise(
        outgoing_links = n(),
        avg_impact = mean(similarity),
        .groups = 'drop'
      ) %>%
      arrange(desc(outgoing_links * avg_impact)) %>%
      head(10),
    
    key_outcomes = causal_links %>%
      group_by(to_id, to_name, to_type) %>%
      summarise(
        incoming_links = n(),
        avg_impact = mean(similarity),
        .groups = 'drop'
      ) %>%
      arrange(desc(incoming_links * avg_impact)) %>%
      head(10)
  )
  
  return(analysis)
}

# Export functions
cat("🎯 Enhanced AI-powered vocabulary linker loaded successfully!\n")
cat("Available functions:\n")
cat("  - find_vocabulary_links(): Find semantic and causal links between vocabulary items\n")
cat("  - detect_causal_relationships(): Advanced causal relationship detection\n")
cat("  - find_causal_paths(): Discover causal pathways from activities to consequences\n")
cat("  - analyze_causal_structure(): Analyze the causal network structure\n")
cat("  - create_vocabulary_network(): Create network graph of links\n")
cat("  - identify_vocabulary_clusters(): Find vocabulary clusters\n")
cat("  - generate_link_recommendations(): Get AI-powered link suggestions\n")
cat("\n🔗 Enhanced causal analysis includes:\n")
cat("  - Environmental process chains (pollution, ecosystem, water, climate)\n")
cat("  - Multi-hop causal path detection\n")
cat("  - Intervention relationship analysis\n")
cat("  - Domain-specific causal rules\n")