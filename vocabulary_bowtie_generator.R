# =============================================================================
# Vocabulary-Based Bow-Tie Network Generator
# Version: 1.0
# Description: Generates bow-tie networks using vocabulary elements from Excel files
# and AI-powered linking, then exports to Excel format suitable for main app
# =============================================================================

# Load required libraries
if (!require("openxlsx")) install.packages("openxlsx")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readxl")) install.packages("readxl")

library(openxlsx)
library(dplyr)
library(readxl)

# Source required functions
if (file.exists("vocabulary.r")) {
  source("vocabulary.r")
} else {
  stop("vocabulary.r file not found. Please ensure it's in the working directory.")
}

if (file.exists("vocabulary-ai-linker.r")) {
  source("vocabulary-ai-linker.r")
} else {
  warning("vocabulary-ai-linker.r not found. Will use basic linking only.")
}

# =============================================================================
# MAIN FUNCTION: Generate Bow-Tie Network from Vocabulary
# =============================================================================

generate_vocabulary_bowtie <- function(
  central_problems = c("Water Pollution", "Air Quality Degradation", "Biodiversity Loss", 
                      "Climate Change", "Soil Degradation"),
  output_file = "vocabulary_generated_bowtie_data.xlsx",
  similarity_threshold = 0.3,
  max_connections_per_item = 3,
  use_ai_linking = TRUE
) {
  
  cat("🚀 Starting vocabulary-based bow-tie network generation...\n")
  cat("Central problems:", paste(central_problems, collapse = ", "), "\n")
  
  # Step 1: Load vocabulary data
  cat("\n📚 Loading vocabulary data...\n")
  vocabulary_data <- tryCatch({
    load_vocabulary()
  }, error = function(e) {
    cat("⚠️ Warning: Could not load vocabulary from Excel files:", e$message, "\n")
    cat("Creating sample vocabulary data instead...\n")
    create_sample_vocabulary_data()
  })
  
  # Step 2: Generate AI-powered links between vocabulary items
  cat("\n🤖 Generating intelligent connections between vocabulary elements...\n")
  
  if (use_ai_linking && exists("find_vocabulary_links")) {
    vocabulary_links <- find_vocabulary_links(
      vocabulary_data, 
      similarity_threshold = similarity_threshold,
      max_links_per_item = max_connections_per_item,
      methods = c("jaccard", "keyword", "causal")
    )
  } else {
    cat("Using basic connection method...\n")
    vocabulary_links <- find_basic_connections(vocabulary_data)
  }
  
  # Step 3: Create bow-tie structures for each central problem
  cat("\n🎯 Creating bow-tie networks for", length(central_problems), "central problems...\n")
  
  all_bowtie_data <- data.frame()
  
  for (problem in central_problems) {
    cat("  Processing:", problem, "\n")
    
    # Create bow-tie structure for this problem
    problem_bowtie <- create_problem_specific_bowtie(
      problem, 
      vocabulary_data, 
      vocabulary_links,
      max_connections_per_item
    )
    
    # Add to overall dataset
    all_bowtie_data <- rbind(all_bowtie_data, problem_bowtie)
    
    cat("    Generated", nrow(problem_bowtie), "bow-tie entries\n")
  }
  
  # Step 4: Enhance with risk assessments
  cat("\n📊 Adding risk assessments and likelihood/severity ratings...\n")
  enhanced_bowtie_data <- enhance_with_risk_data(all_bowtie_data)
  
  # Step 5: Export to Excel file
  cat("\n💾 Exporting to Excel file:", output_file, "\n")
  export_bowtie_to_excel(enhanced_bowtie_data, output_file)
  
  cat("\n✅ Vocabulary-based bow-tie generation completed successfully!\n")
  cat("📁 Output file:", output_file, "\n")
  cat("📈 Total bow-tie entries generated:", nrow(enhanced_bowtie_data), "\n")
  
  return(list(
    data = enhanced_bowtie_data,
    file = output_file,
    vocabulary_used = vocabulary_data,
    links_generated = vocabulary_links
  ))
}

# =============================================================================
# HELPER FUNCTION: Create Problem-Specific Bow-Tie Structure
# =============================================================================

create_problem_specific_bowtie <- function(central_problem, vocabulary_data, links, max_connections = 3) {
  
  # Extract relevant connections for this problem
  problem_activities <- find_connected_items(central_problem, "Activity", vocabulary_data, links, max_connections)
  problem_pressures <- find_connected_items(central_problem, "Pressure", vocabulary_data, links, max_connections)
  problem_consequences <- find_connected_items(central_problem, "Consequence", vocabulary_data, links, max_connections)
  problem_controls <- find_connected_items(central_problem, "Control", vocabulary_data, links, max_connections)
  
  # Create bow-tie combinations
  bowtie_entries <- expand.grid(
    Activity = problem_activities$name[1:min(length(problem_activities$name), max_connections)],
    Pressure = problem_pressures$name[1:min(length(problem_pressures$name), max_connections)],
    Consequence = problem_consequences$name[1:min(length(problem_consequences$name), max_connections)],
    stringsAsFactors = FALSE
  )
  
  # Add problem and controls
  bowtie_entries$Problem <- central_problem
  bowtie_entries$Preventive_Control <- sample(problem_controls$name, 
                                              nrow(bowtie_entries), 
                                              replace = TRUE)
  bowtie_entries$Protective_Mitigation <- sample(problem_controls$name, 
                                                 nrow(bowtie_entries), 
                                                 replace = TRUE)
  
  return(bowtie_entries)
}

# =============================================================================
# HELPER FUNCTION: Find Connected Items of Specific Type
# =============================================================================

find_connected_items <- function(central_problem, item_type, vocabulary_data, links, max_items = 5) {
  
  # Get vocabulary items of the specified type
  type_items <- switch(item_type,
    "Activity" = vocabulary_data$activities,
    "Pressure" = vocabulary_data$pressures, 
    "Consequence" = vocabulary_data$consequences,
    "Control" = vocabulary_data$controls,
    data.frame(id = character(0), name = character(0))
  )
  
  if (nrow(type_items) == 0) {
    return(data.frame(id = "DEFAULT", name = paste("Default", item_type)))
  }
  
  # If links exist, use them to find most relevant items
  if (!is.null(links) && "similarity" %in% names(links)) {
    # Find items connected to the central problem theme
    problem_keywords <- tolower(unlist(strsplit(central_problem, " ")))
    
    # Score items based on keyword relevance
    type_items$relevance_score <- sapply(type_items$name, function(name) {
      name_words <- tolower(unlist(strsplit(name, " ")))
      # Simple keyword matching score
      max(sapply(problem_keywords, function(keyword) {
        max(sapply(name_words, function(word) {
          if (grepl(keyword, word) || grepl(word, keyword)) 1 else 0
        }))
      }))
    })
    
    # Add semantic similarity if available
    if ("similarity" %in% names(links)) {
      # Add bonus for items that appear in links
      linked_items <- unique(c(links$from_id, links$to_id))
      type_items$link_bonus <- ifelse(type_items$id %in% linked_items, 0.5, 0)
      type_items$relevance_score <- type_items$relevance_score + type_items$link_bonus
    }
    
    # Sort by relevance and take top items
    type_items <- type_items[order(-type_items$relevance_score), ]
  }
  
  # Return top items
  top_items <- head(type_items, max_items)
  
  # If still empty, create fallback items
  if (nrow(top_items) == 0) {
    fallback_names <- create_fallback_items(central_problem, item_type)
    top_items <- data.frame(
      id = paste0("FALLBACK_", seq_along(fallback_names)),
      name = fallback_names,
      stringsAsFactors = FALSE
    )
  }
  
  return(top_items)
}

# =============================================================================
# HELPER FUNCTION: Create Fallback Items When Vocabulary is Missing
# =============================================================================

create_fallback_items <- function(central_problem, item_type) {
  switch(item_type,
    "Activity" = c(
      paste("Industrial operations affecting", tolower(central_problem)),
      paste("Agricultural practices contributing to", tolower(central_problem)),
      paste("Urban development related to", tolower(central_problem)),
      paste("Transportation activities causing", tolower(central_problem))
    ),
    "Pressure" = c(
      paste("Direct discharge causing", tolower(central_problem)),
      paste("Chemical contamination leading to", tolower(central_problem)),
      paste("Physical disturbance resulting in", tolower(central_problem)),
      paste("Resource depletion contributing to", tolower(central_problem))
    ),
    "Consequence" = c(
      paste("Ecosystem degradation from", tolower(central_problem)),
      paste("Human health impacts due to", tolower(central_problem)),
      paste("Economic losses from", tolower(central_problem)),
      paste("Long-term environmental damage from", tolower(central_problem))
    ),
    "Control" = c(
      paste("Regulatory controls for", tolower(central_problem)),
      paste("Technology solutions addressing", tolower(central_problem)),
      paste("Monitoring systems for", tolower(central_problem)),
      paste("Emergency response procedures for", tolower(central_problem))
    ),
    c("Generic item 1", "Generic item 2", "Generic item 3")
  )
}

# =============================================================================
# HELPER FUNCTION: Enhance Bow-Tie Data with Risk Assessments
# =============================================================================

enhance_with_risk_data <- function(bowtie_data) {
  
  cat("  Adding likelihood and severity assessments...\n")
  
  # Add realistic risk assessments based on content analysis
  enhanced_data <- bowtie_data %>%
    mutate(
      # Threat likelihood (1-5 scale)
      Threat_Likelihood = sapply(paste(Activity, Pressure), function(x) {
        # Higher likelihood for common environmental issues
        keywords_high <- c("agriculture", "urban", "industrial", "runoff", "discharge", "emission")
        keywords_medium <- c("transport", "construction", "mining", "waste", "chemical")
        
        text_lower <- tolower(x)
        if (any(sapply(keywords_high, function(k) grepl(k, text_lower)))) {
          sample(4:5, 1)  # High likelihood
        } else if (any(sapply(keywords_medium, function(k) grepl(k, text_lower)))) {
          sample(3:4, 1)  # Medium-high likelihood
        } else {
          sample(2:4, 1)  # Variable likelihood
        }
      }),
      
      # Consequence severity (1-5 scale)
      Consequence_Severity = sapply(paste(Problem, Consequence), function(x) {
        # Higher severity for serious environmental consequences
        keywords_severe <- c("ecosystem", "health", "biodiversity", "climate", "toxic", "cancer")
        keywords_moderate <- c("economic", "aesthetic", "recreational", "minor")
        
        text_lower <- tolower(x)
        if (any(sapply(keywords_severe, function(k) grepl(k, text_lower)))) {
          sample(4:5, 1)  # High severity
        } else if (any(sapply(keywords_moderate, function(k) grepl(k, text_lower)))) {
          sample(2:3, 1)  # Lower severity
        } else {
          sample(3:4, 1)  # Medium severity
        }
      }),
      
      # Calculate risk score (likelihood × severity)
      Risk_Score = Threat_Likelihood * Consequence_Severity,

      # Risk level categories (categorical)
      Risk_Level = case_when(
        Risk_Score <= 4 ~ "Low",
        Risk_Score <= 9 ~ "Medium",
        Risk_Score <= 16 ~ "High",
        Risk_Score > 16 ~ "Very High"
      ),

      # Keep Risk_Rating for backward compatibility
      Risk_Rating = Risk_Level,
      
      # Add unique identifiers
      Entry_ID = paste0("VocabGen_", sprintf("%04d", row_number())),
      
      # Add metadata
      Generation_Method = "Vocabulary_AI_Generated",
      Generation_Date = Sys.Date()
    )
  
  return(enhanced_data)
}

# =============================================================================
# HELPER FUNCTION: Export Bow-Tie Data to Excel
# =============================================================================

export_bowtie_to_excel <- function(bowtie_data, output_file) {
  
  # Create workbook
  wb <- createWorkbook()
  
  # Add main data sheet
  addWorksheet(wb, "Bowtie_Data")
  writeData(wb, "Bowtie_Data", bowtie_data)
  
  # Add summary sheet
  addWorksheet(wb, "Summary")
  
  summary_data <- data.frame(
    Metric = c("Total Entries", "Unique Problems", "Unique Activities", "Unique Consequences",
               "Average Risk Level", "High Risk Entries", "Generation Date"),
    Value = c(
      nrow(bowtie_data),
      length(unique(bowtie_data$Problem)),
      length(unique(bowtie_data$Activity)),
      length(unique(bowtie_data$Consequence)),
      round(mean(bowtie_data$Risk_Score, na.rm = TRUE), 2),
      sum(bowtie_data$Risk_Rating %in% c("High", "Very High"), na.rm = TRUE),
      as.character(Sys.Date())
    ),
    stringsAsFactors = FALSE
  )
  
  writeData(wb, "Summary", summary_data)
  
  # Add formatting
  addStyle(wb, "Bowtie_Data", style = createStyle(textDecoration = "bold"), rows = 1, cols = 1:ncol(bowtie_data))
  addStyle(wb, "Summary", style = createStyle(textDecoration = "bold"), rows = 1, cols = 1:2)
  
  # Save workbook
  saveWorkbook(wb, output_file, overwrite = TRUE)
  
  cat("  ✅ Excel file exported successfully\n")
}

# =============================================================================
# HELPER FUNCTION: Create Sample Vocabulary Data (fallback)
# =============================================================================

create_sample_vocabulary_data <- function() {
  list(
    activities = data.frame(
      hierarchy = c("1", "1.1", "1.2", "2", "2.1", "3", "3.1"),
      id = c("AGR", "AGR.CROP", "AGR.LIVE", "IND", "IND.MANF", "URB", "URB.DEV"),
      name = c("Agricultural Operations", "Crop Production", "Livestock Farming",
               "Industrial Activities", "Manufacturing Processes", 
               "Urban Development", "Construction Activities"),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      hierarchy = c("1", "1.1", "1.2", "2", "2.1", "3", "3.1"),
      id = c("WTR", "WTR.POLL", "WTR.NUTR", "AIR", "AIR.POLL", "SOIL", "SOIL.DEG"),
      name = c("Water Pollution", "Chemical Contamination", "Nutrient Loading",
               "Air Pollution", "Particulate Emissions",
               "Soil Degradation", "Erosion"),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      hierarchy = c("1", "1.1", "2", "2.1", "3", "3.1"),
      id = c("ECO", "ECO.HAB", "HUM", "HUM.HLTH", "ECON", "ECON.LOSS"),
      name = c("Ecosystem Impact", "Habitat Loss", "Human Health Impact", 
               "Respiratory Issues", "Economic Impact", "Property Damage"),
      stringsAsFactors = FALSE
    ),
    controls = data.frame(
      hierarchy = c("1", "1.1", "2", "2.1", "3", "3.1"),
      id = c("PREV", "PREV.TECH", "REG", "REG.COMP", "RESP", "RESP.EMER"),
      name = c("Prevention Controls", "Technology Solutions", 
               "Regulatory Controls", "Compliance Monitoring",
               "Response Measures", "Emergency Procedures"),
      stringsAsFactors = FALSE
    )
  )
}

# =============================================================================
# USAGE EXAMPLE AND MAIN EXECUTION
# =============================================================================

# Example usage function
example_usage <- function() {
  cat("=== Vocabulary Bow-Tie Generator Example ===\n")
  
  # Generate bow-tie network with default settings
  result <- generate_vocabulary_bowtie(
    central_problems = c("Water Pollution", "Air Quality Issues", "Biodiversity Loss"),
    output_file = "example_vocabulary_bowtie.xlsx",
    similarity_threshold = 0.25,
    max_connections_per_item = 4,
    use_ai_linking = TRUE
  )
  
  cat("\n📊 Generation Results:\n")
  cat("  - File created:", result$file, "\n")
  cat("  - Data rows:", nrow(result$data), "\n")
  cat("  - Vocabulary items used:\n")
  cat("    * Activities:", nrow(result$vocabulary_used$activities), "\n")
  cat("    * Pressures:", nrow(result$vocabulary_used$pressures), "\n")
  cat("    * Consequences:", nrow(result$vocabulary_used$consequences), "\n")
  cat("    * Controls:", nrow(result$vocabulary_used$controls), "\n")
  
  return(result)
}

# Print usage information
cat("=== Vocabulary-Based Bow-Tie Network Generator ===\n")
cat("Functions available:\n")
cat("  • generate_vocabulary_bowtie() - Main generation function\n")
cat("  • example_usage() - Run example generation\n")
cat("\nExample usage:\n")
cat('  result <- generate_vocabulary_bowtie(\n')
cat('    central_problems = c("Water Pollution", "Climate Change"),\n')
cat('    output_file = "my_bowtie_network.xlsx"\n')
cat('  )\n')
cat("\n")