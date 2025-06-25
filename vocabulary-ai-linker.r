# vocabulary_ai_linker.R
# AI-powered vocabulary relationship finder for environmental bowtie analysis
# Uses text mining and semantic analysis to find links between vocabulary groups

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

# Main function to find links between vocabulary groups
find_vocabulary_links <- function(vocabulary_data, 
                                 similarity_threshold = 0.3,
                                 max_links_per_item = 5,
                                 methods = c("jaccard", "keyword")) {
  
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
                    "wetland", "groundwater", "wastewater", "sewage", "stormwater"),
        link_strength = 0.8
      ),
      # Pollution connections
      pollution = list(
        keywords = c("pollution", "contamination", "discharge", "emission", "runoff", "waste",
                    "toxic", "chemical", "nutrient", "pollutant"),
        link_strength = 0.7
      ),
      # Ecosystem connections
      ecosystem = list(
        keywords = c("ecosystem", "habitat", "biodiversity", "species", "wildlife", "fauna", 
                    "flora", "ecological", "environment"),
        link_strength = 0.7
      ),
      # Climate connections
      climate = list(
        keywords = c("climate", "greenhouse", "carbon", "emission", "warming", "temperature",
                    "weather", "methane", "co2"),
        link_strength = 0.6
      ),
      # Agriculture connections
      agriculture = list(
        keywords = c("agriculture", "farming", "livestock", "crop", "fertilizer", "pesticide",
                    "soil", "erosion", "irrigation"),
        link_strength = 0.7
      ),
      # Industrial connections
      industrial = list(
        keywords = c("industrial", "manufacturing", "factory", "production", "chemical",
                    "waste", "discharge", "emission"),
        link_strength = 0.6
      ),
      # Health connections
      health = list(
        keywords = c("health", "disease", "illness", "respiratory", "contamination", "exposure",
                    "toxic", "safety", "risk"),
        link_strength = 0.6
      ),
      # Management connections
      management = list(
        keywords = c("management", "control", "mitigation", "prevention", "monitoring",
                    "treatment", "restoration", "protection"),
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
  
  # Method 3: Causal relationship detection
  if ("causal" %in% methods) {
    cat("🔗 Detecting causal relationships...\n")
    
    # Define causal patterns
    causal_patterns <- list(
      # Activity → Pressure patterns
      activity_pressure = list(
        patterns = c("leads to", "causes", "results in", "creates", "generates", "produces"),
        from_type = "Activity",
        to_type = "Pressure",
        strength = 0.8
      ),
      # Pressure → Consequence patterns
      pressure_consequence = list(
        patterns = c("impacts", "affects", "damages", "harms", "threatens", "degrades"),
        from_type = "Pressure",
        to_type = "Consequence",
        strength = 0.8
      ),
      # Control → Pressure/Consequence patterns
      control_effect = list(
        patterns = c("prevents", "reduces", "mitigates", "controls", "manages", "treats"),
        from_type = "Control",
        to_type = c("Pressure", "Consequence"),
        strength = 0.7
      )
    )
    
    # Apply causal patterns (simplified for demonstration)
    # In practice, this would use more sophisticated NLP
    for (pattern_name in names(causal_patterns)) {
      pattern_info <- causal_patterns[[pattern_name]]
      
      # Find potential causal links based on vocabulary structure
      if (pattern_name == "activity_pressure") {
        # Link activities to pressures with similar themes
        for (i in 1:nrow(activities)) {
          activity_terms <- tolower(strsplit(activities$name[i], " ")[[1]])
          matching_pressures <- pressures[sapply(pressures$name, function(p) {
            any(activity_terms %in% tolower(strsplit(p, " ")[[1]]))
          }), ]
          
          if (nrow(matching_pressures) > 0) {
            for (j in 1:nrow(matching_pressures)) {
              all_links <- rbind(all_links, data.frame(
                from_id = activities$id[i],
                from_name = activities$name[i],
                from_type = "Activity",
                to_id = matching_pressures$id[j],
                to_name = matching_pressures$name[j],
                to_type = "Pressure",
                similarity = pattern_info$strength,
                method = "causal_pattern",
                stringsAsFactors = FALSE
              ))
            }
          }
        }
      }
    }
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
    summary = summarize_links(all_links)
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
    directed = FALSE
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

# Function to find link paths between specific vocabulary items
find_link_paths <- function(links, from_id, to_id, max_length = 3) {
  if (nrow(links) == 0) {
    return(list())
  }
  
  # Create graph
  g <- graph_from_data_frame(
    d = links %>% select(from_id, to_id, similarity),
    directed = FALSE
  )
  
  # Check if both nodes exist
  if (!(from_id %in% V(g)$name) || !(to_id %in% V(g)$name)) {
    return(list())
  }
  
  # Find all simple paths
  paths <- all_simple_paths(g, from = from_id, to = to_id, mode = "all", cutoff = max_length)
  
  # Convert to readable format
  path_details <- lapply(paths, function(path) {
    path_ids <- V(g)$name[path]
    path_edges <- E(g, path = path)
    
    list(
      path_ids = path_ids,
      path_length = length(path_ids) - 1,
      total_similarity = sum(path_edges$similarity)
    )
  })
  
  return(path_details)
}

# Function to identify vocabulary clusters
identify_vocabulary_clusters <- function(links, min_similarity = 0.4) {
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
  
  return(clusters)
}

# Function to generate link recommendations
generate_link_recommendations <- function(vocabulary_data, existing_links = NULL) {
  cat("💡 Generating AI-powered link recommendations...\n")
  
  # Find all potential links
  all_potential_links <- find_vocabulary_links(
    vocabulary_data,
    similarity_threshold = 0.2,
    max_links_per_item = 10,
    methods = c("jaccard", "keyword", "causal")
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
  
  # Rank recommendations
  recommendations <- potential_links %>%
    mutate(
      # Score based on similarity and link type importance
      type_score = case_when(
        from_type == "Activity" & to_type == "Pressure" ~ 1.0,
        from_type == "Pressure" & to_type == "Consequence" ~ 0.9,
        from_type == "Control" & to_type %in% c("Pressure", "Consequence") ~ 0.8,
        TRUE ~ 0.5
      ),
      recommendation_score = similarity * type_score
    ) %>%
    arrange(desc(recommendation_score)) %>%
    head(20)  # Top 20 recommendations
  
  return(recommendations)
}

# Export functions
cat("🎯 AI-powered vocabulary linker loaded successfully!\n")
cat("Available functions:\n")
cat("  - find_vocabulary_links(): Find semantic links between vocabulary items\n")
cat("  - create_vocabulary_network(): Create network graph of links\n")
cat("  - identify_vocabulary_clusters(): Find vocabulary clusters\n")
cat("  - generate_link_recommendations(): Get AI-powered link suggestions\n")