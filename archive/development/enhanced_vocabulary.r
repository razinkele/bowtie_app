# =============================================================================
# Enhanced Vocabulary System - MARBEFES Guidance Integration
# Version: 6.0.0 (Prototype)
# Date: September 2025
# Description: Prototype for enhanced vocabulary loading with guidance integration
# =============================================================================

library(readxl)
library(dplyr)
library(purrr)

# Enhanced vocabulary configuration
VOCABULARY_CONFIG <- list(
  current = list(
    causes = "CAUSES.xlsx",
    consequences = "CONSEQUENCES.xlsx", 
    controls = "CONTROLS.xlsx"
  ),
  guidance = list(
    causes = "Bow-tie guidance/Bow-tie_CAUSES & standardised vocabularies.xlsx",
    consequences = "Bow-tie guidance/Bow-tie_CONSEQUENCES  standardised vocabulary.xlsx",
    controls = "Bow-tie guidance/Bow-tie_CONTROLS & standardised vocabulary.xlsx"
  )
)

# Safe Excel reader for large files
safe_read_excel <- function(file_path, max_rows = 10000, chunk_size = 1000) {
  cat("📖 Reading:", basename(file_path), "\n")
  
  if (!file.exists(file_path)) {
    warning("File not found: ", file_path)
    return(data.frame())
  }
  
  tryCatch({
    # Get sheet names
    sheets <- excel_sheets(file_path)
    cat("   📊 Found", length(sheets), "sheets:", paste(head(sheets, 3), collapse=", "), "\n")
    
    # Read primary sheet (usually first one with data)
    primary_sheet <- sheets[1]
    
    # Progressive reading for large files
    file_size <- file.size(file_path)
    if (file_size > 1000000) {  # > 1MB
      cat("   🔄 Large file detected, using progressive loading...\n")
      data <- read_excel(file_path, sheet = primary_sheet, n_max = max_rows)
    } else {
      data <- read_excel(file_path, sheet = primary_sheet)
    }
    
    cat("   ✅ Loaded", nrow(data), "rows,", ncol(data), "columns\n")
    return(data)
    
  }, error = function(e) {
    cat("   ❌ Error reading file:", e$message, "\n")
    return(data.frame())
  })
}

# Enhanced vocabulary loader with source selection
load_enhanced_vocabularies <- function(source = "current", include_guidance = FALSE) {
  cat("🔧 Enhanced Vocabulary Loader v6.0.0\n")
  cat("📋 Loading vocabularies from:", source, "\n")
  
  if (include_guidance) {
    cat("🌟 Including guidance vocabularies for comparison\n")
  }
  
  # Initialize vocabulary container
  vocabularies <- list()
  
  # Load primary vocabularies
  config <- VOCABULARY_CONFIG[[source]]
  
  for (vocab_type in names(config)) {
    file_path <- config[[vocab_type]]
    cat("\n🔄 Processing", toupper(vocab_type), "vocabulary...\n")
    
    vocab_data <- safe_read_excel(file_path)
    
    if (nrow(vocab_data) > 0) {
      # Standardize column names
      if ("Hierarchy" %in% names(vocab_data) && "ID#" %in% names(vocab_data)) {
        vocab_data <- vocab_data %>%
          select(hierarchy = Hierarchy, id = `ID#`, name = any_of(c("name", "Name", "Description", "Term"))) %>%
          filter(!is.na(id), !is.na(hierarchy)) %>%
          mutate(
            level = suppressWarnings(as.numeric(gsub("Level ", "", hierarchy))),
            name = trimws(as.character(name)),
            id = trimws(as.character(id)),
            source = source,
            vocab_type = vocab_type
          )
        
        vocabularies[[vocab_type]] <- vocab_data
        cat("   ✅", vocab_type, "loaded:", nrow(vocab_data), "terms\n")
      } else {
        cat("   ⚠️ Unexpected column structure in", vocab_type, "file\n")
        cat("   📋 Available columns:", paste(names(vocab_data), collapse=", "), "\n")
      }
    }
  }
  
  # Load guidance vocabularies for comparison if requested
  if (include_guidance && source == "current") {
    cat("\n🎯 Loading guidance vocabularies for comparison...\n")
    guidance_vocabularies <- load_enhanced_vocabularies("guidance", include_guidance = FALSE)
    
    for (vocab_type in names(guidance_vocabularies)) {
      guidance_data <- guidance_vocabularies[[vocab_type]]
      guidance_data$source <- "guidance"
      
      vocab_comparison <- list(
        current = vocabularies[[vocab_type]],
        guidance = guidance_data,
        combined = bind_rows(vocabularies[[vocab_type]], guidance_data)
      )
      
      vocabularies[[paste0(vocab_type, "_comparison")]] <- vocab_comparison
    }
  }
  
  # Summary statistics
  cat("\n📊 VOCABULARY LOADING SUMMARY\n")
  cat("============================\n")
  for (vocab_type in names(vocabularies)) {
    if (!grepl("_comparison", vocab_type)) {
      vocab_data <- vocabularies[[vocab_type]]
      unique_levels <- length(unique(vocab_data$level[!is.na(vocab_data$level)]))
      cat(sprintf("%-15s: %4d terms, %d hierarchy levels\n", 
                  toupper(vocab_type), nrow(vocab_data), unique_levels))
    }
  }
  
  return(vocabularies)
}

# Vocabulary comparison function
compare_vocabularies <- function(current_vocab, guidance_vocab) {
  cat("🔍 Vocabulary Comparison Analysis\n")
  cat("=================================\n")
  
  comparison <- list(
    current_count = nrow(current_vocab),
    guidance_count = nrow(guidance_vocab),
    expansion_factor = round(nrow(guidance_vocab) / nrow(current_vocab), 1),
    common_terms = length(intersect(current_vocab$name, guidance_vocab$name)),
    new_terms = length(setdiff(guidance_vocab$name, current_vocab$name))
  )
  
  cat("📈 Current vocabulary:", comparison$current_count, "terms\n")
  cat("📈 Guidance vocabulary:", comparison$guidance_count, "terms\n") 
  cat("🚀 Expansion factor:", comparison$expansion_factor, "x\n")
  cat("🔄 Common terms:", comparison$common_terms, "\n")
  cat("✨ New terms:", comparison$new_terms, "\n")
  
  return(comparison)
}

# Vocabulary search function
search_vocabularies <- function(vocabularies, search_term, vocab_type = "all") {
  cat("🔍 Searching for:", search_term, "\n")
  
  results <- list()
  
  search_vocabs <- if (vocab_type == "all") {
    names(vocabularies)[!grepl("_comparison", names(vocabularies))]
  } else {
    vocab_type
  }
  
  for (vtype in search_vocabs) {
    if (vtype %in% names(vocabularies)) {
      vocab_data <- vocabularies[[vtype]]
      matches <- vocab_data[grepl(search_term, vocab_data$name, ignore.case = TRUE), ]
      
      if (nrow(matches) > 0) {
        results[[vtype]] <- matches
        cat("📋", toupper(vtype), ":", nrow(matches), "matches\n")
      }
    }
  }
  
  return(results)
}

# Integration with existing app
create_vocabulary_selector_ui <- function() {
  # UI component for vocabulary source selection
  fluidRow(
    column(4,
      selectInput("vocab_source", "Vocabulary Source:",
        choices = c(
          "Current (Fast)" = "current",
          "MARBEFES Guidance (Comprehensive)" = "guidance", 
          "Combined (Best of Both)" = "combined"
        ),
        selected = "current"
      )
    ),
    column(4,
      checkboxInput("include_comparison", "Enable Vocabulary Comparison", FALSE)
    ),
    column(4,
      actionButton("refresh_vocabularies", "🔄 Refresh Vocabularies",
                   class = "btn-primary")
    )
  )
}

# Server-side vocabulary management
manage_vocabularies_server <- function(input, output, session) {
  # Reactive vocabulary loader
  vocabularies <- reactive({
    req(input$vocab_source)
    
    showNotification("Loading vocabularies...", type = "default", duration = 2)
    
    tryCatch({
      vocab_data <- load_enhanced_vocabularies(
        source = input$vocab_source,
        include_guidance = input$include_comparison
      )
      
      showNotification("✅ Vocabularies loaded successfully!", 
                      type = "default", duration = 3)
      return(vocab_data)
      
    }, error = function(e) {
      showNotification(paste("❌ Error loading vocabularies:", e$message), 
                      type = "error")
      return(NULL)
    })
  })
  
  return(vocabularies)
}

# Example usage function
demo_enhanced_vocabularies <- function() {
  cat("🎯 ENHANCED VOCABULARY SYSTEM DEMO\n")
  cat("==================================\n")
  
  # Load current vocabularies
  current_vocabs <- load_enhanced_vocabularies("current")
  
  # Load with comparison
  cat("\n" + rep("=", 50), "\n")
  comparison_vocabs <- load_enhanced_vocabularies("current", include_guidance = TRUE)
  
  # Search demo
  cat("\n🔍 SEARCH DEMO\n")
  search_results <- search_vocabularies(current_vocabs, "pollution")
  
  cat("\n✅ Enhanced vocabulary system demonstration complete!\n")
  
  return(list(
    current = current_vocabs,
    comparison = comparison_vocabs,
    search_example = search_results
  ))
}

cat("🎯 Enhanced Vocabulary System v6.0.0 Loaded\n")
cat("📋 Available functions:\n")
cat("   - load_enhanced_vocabularies(source, include_guidance)\n")
cat("   - safe_read_excel(file_path, max_rows, chunk_size)\n") 
cat("   - compare_vocabularies(current, guidance)\n")
cat("   - search_vocabularies(vocabularies, search_term)\n")
cat("   - demo_enhanced_vocabularies()\n")
cat("🚀 Ready for integration into main application!\n")