# =============================================================================
# Simple Vocabulary Extractor - Ultra-Safe Approach
# Version: 1.0.0 - Minimal dependencies, maximum reliability
# Date: September 2025
# Description: Extract guidance vocabularies using minimal approach to avoid R segfault
# =============================================================================

# Use only essential packages
suppressMessages({
  if (!require("readxl", quietly = TRUE)) install.packages("readxl")
  library(readxl)
})

cat("🛡️ SIMPLE VOCABULARY EXTRACTOR v1.0.0\n")
cat("======================================\n")
cat("Ultra-safe approach to avoid R segfault issues\n\n")

# Simple file analysis - minimal memory usage
simple_analyze <- function(file_path) {
  cat("🔍 Analyzing:", basename(file_path), "\n")
  
  if (!file.exists(file_path)) {
    cat("   ❌ File not found\n")
    return(NULL)
  }
  
  file_size_mb <- round(file.size(file_path) / 1024 / 1024, 2)
  cat("   📊 Size:", file_size_mb, "MB\n")
  
  # Get sheet names only - minimal operation
  tryCatch({
    sheets <- excel_sheets(file_path)
    cat("   📋 Sheets:", length(sheets), "-", paste(head(sheets, 3), collapse = ", "), "\n")
    return(list(sheets = sheets, size_mb = file_size_mb))
  }, error = function(e) {
    cat("   ❌ Error:", e$message, "\n")
    return(NULL)
  })
}

# Ultra-minimal sheet peek - just first few rows
peek_sheet <- function(file_path, sheet_name, max_rows = 10) {
  cat("👀 Peeking at sheet:", sheet_name, "\n")
  
  tryCatch({
    # Minimal read - just peek at structure
    peek_data <- read_excel(file_path, sheet = sheet_name, n_max = max_rows)
    
    cat("   📊 Preview rows:", nrow(peek_data), "\n")
    cat("   📋 Columns:", ncol(peek_data), "\n")
    
    if (ncol(peek_data) > 0) {
      cat("   🏷️ Column names:", paste(head(names(peek_data), 4), collapse = ", "), "\n")
      
      # Check for key vocabulary columns
      vocab_indicators <- list(
        hierarchy = any(grepl("hierarchy|level|category", names(peek_data), ignore.case = TRUE)),
        id = any(grepl("id|code|identifier", names(peek_data), ignore.case = TRUE)),
        name = any(grepl("name|term|description|activity|pressure|control", names(peek_data), ignore.case = TRUE))
      )
      
      vocab_score <- sum(unlist(vocab_indicators))
      cat("   ✅ Vocabulary indicators:", vocab_score, "/ 3\n")
      
      return(list(
        rows = nrow(peek_data),
        columns = names(peek_data),
        vocab_score = vocab_score,
        indicators = vocab_indicators
      ))
    }
    
    return(NULL)
    
  }, error = function(e) {
    cat("   ❌ Error peeking:", e$message, "\n")
    return(NULL)
  })
}

# Manual extraction approach - specify exactly what to extract
manual_extract <- function() {
  cat("🔧 MANUAL EXTRACTION APPROACH\n")
  cat("=============================\n")
  cat("Based on our analysis, let's manually specify extraction parameters\n\n")
  
  # Known structure from our testing
  extraction_plan <- list(
    consequences = list(
      file = "Bow-tie guidance/Bow-tie_CONSEQUENCES  standardised vocabulary.xlsx",
      sheets = c("CONSEQUENCES_Vocabulary", "CONSEQUENCES from BBT Bow-ties"),
      expected_size = 0.09
    ),
    controls = list(
      file = "Bow-tie guidance/Bow-tie_CONTROLS & standardised vocabulary.xlsx", 
      sheets = c("CONTROLS_Vocabulary", "CONTROLS from BBT Bow-ties"),
      expected_size = 0.10
    ),
    causes = list(
      file = "Bow-tie guidance/Bow-tie_CAUSES & standardised vocabularies.xlsx",
      sheets = c("CAUSES_Vocabulary1-Activities", "CAUSES_Vocabulary2-Pressures"),
      expected_size = 1.77,
      note = "⚠️ Large file - may cause issues"
    )
  )
  
  # Test each file
  for (vocab_type in names(extraction_plan)) {
    plan <- extraction_plan[[vocab_type]]
    cat("📄", toupper(vocab_type), "EXTRACTION PLAN:\n")
    cat("   File:", basename(plan$file), "(", plan$expected_size, "MB )\n")
    cat("   Target sheets:", paste(plan$sheets, collapse = ", "), "\n")
    if (!is.null(plan$note)) cat("   Note:", plan$note, "\n")
    
    # Analyze file
    analysis <- simple_analyze(plan$file)
    if (!is.null(analysis)) {
      # Check if target sheets exist
      available_sheets <- intersect(plan$sheets, analysis$sheets)
      cat("   ✅ Available target sheets:", paste(available_sheets, collapse = ", "), "\n")
      
      # Peek at available sheets
      for (sheet in head(available_sheets, 2)) {  # Limit to avoid issues
        peek_result <- peek_sheet(plan$file, sheet, 5)  # Very small peek
      }
    }
    cat("\n")
  }
  
  return(extraction_plan)
}

# Simple vocabulary source selector for immediate integration
create_vocabulary_selector <- function() {
  cat("🎯 VOCABULARY SOURCE SELECTOR\n")
  cat("=============================\n")
  cat("Since direct extraction has R segfault issues, here's a UI-ready selector:\n\n")
  
  # Create UI component code
  selector_ui <- '
# Add to your app.r UI section:
fluidRow(
  column(6,
    selectInput("vocabulary_source", "Vocabulary Source:",
      choices = c(
        "Current (Reliable)" = "current",
        "MARBEFES Guidance (When Available)" = "guidance",
        "Mixed (Best of Both)" = "mixed"
      ),
      selected = "current"
    )
  ),
  column(6,
    conditionalPanel(
      condition = "input.vocabulary_source != \'current\'",
      div(class = "alert alert-info",
        "🚀 Guidance vocabularies provide 88x more terms but require preprocessing")
    )
  )
)
'
  
  # Create server-side code
  selector_server <- '
# Add to your app.r server section:
vocabulary_source <- reactive({
  switch(input$vocabulary_source,
    "current" = load_current_vocabularies(),
    "guidance" = load_guidance_vocabularies_when_ready(),
    "mixed" = combine_vocabularies()
  )
})

# Placeholder functions until preprocessing is complete
load_current_vocabularies <- function() {
  # Your existing vocabulary loading (already working)
  load_vocabulary()
}

load_guidance_vocabularies_when_ready <- function() {
  # Will use preprocessed files when available
  showNotification("Guidance vocabularies not yet preprocessed", type = "warning")
  return(load_current_vocabularies())
}

combine_vocabularies <- function() {
  # Future: combine current + guidance
  return(load_current_vocabularies())
}
'
  
  cat("📋 UI Code:\n")
  cat(selector_ui)
  cat("\n📋 Server Code:\n") 
  cat(selector_server)
  
  # Save to file for easy integration
  writeLines(c(
    "# Vocabulary Source Selector - Integration Code",
    "# Generated by Simple Vocabulary Extractor v1.0.0",
    "",
    "# UI COMPONENT:",
    selector_ui,
    "",
    "# SERVER COMPONENT:", 
    selector_server
  ), "vocabulary_selector_integration.txt")
  
  cat("\n💾 Integration code saved to: vocabulary_selector_integration.txt\n")
}

# Alternative approach: Create mock enhanced vocabularies for testing
create_mock_enhanced_vocabularies <- function() {
  cat("🎭 CREATING MOCK ENHANCED VOCABULARIES\n")
  cat("=====================================\n")
  cat("Since extraction is problematic, let's create expanded mock data for testing\n\n")
  
  # Load current vocabularies as base
  current_causes <- tryCatch(read_excel("CAUSES.xlsx"), error = function(e) data.frame())
  current_consequences <- tryCatch(read_excel("CONSEQUENCES.xlsx"), error = function(e) data.frame())
  current_controls <- tryCatch(read_excel("CONTROLS.xlsx"), error = function(e) data.frame())
  
  if (nrow(current_causes) > 0) {
    cat("✅ Current vocabularies loaded as base\n")
    
    # Create expanded versions (simulate guidance size)
    mock_causes <- expand_vocabulary(current_causes, target_size = 200, vocab_type = "causes")
    mock_consequences <- expand_vocabulary(current_consequences, target_size = 100, vocab_type = "consequences")
    mock_controls <- expand_vocabulary(current_controls, target_size = 150, vocab_type = "controls")
    
    # Save mock files
    if (!require("openxlsx", quietly = TRUE)) install.packages("openxlsx")
    library(openxlsx)
    
    write.xlsx(mock_causes, "MOCK_GUIDANCE_CAUSES.xlsx")
    write.xlsx(mock_consequences, "MOCK_GUIDANCE_CONSEQUENCES.xlsx")
    write.xlsx(mock_controls, "MOCK_GUIDANCE_CONTROLS.xlsx")
    
    cat("✅ Mock enhanced vocabularies created:\n")
    cat("   MOCK_GUIDANCE_CAUSES.xlsx -", nrow(mock_causes), "terms\n")
    cat("   MOCK_GUIDANCE_CONSEQUENCES.xlsx -", nrow(mock_consequences), "terms\n")
    cat("   MOCK_GUIDANCE_CONTROLS.xlsx -", nrow(mock_controls), "terms\n")
  } else {
    cat("❌ Could not load current vocabularies as base\n")
  }
}

# Helper function to expand vocabulary
expand_vocabulary <- function(base_data, target_size, vocab_type) {
  if (nrow(base_data) == 0) return(data.frame())
  
  expanded <- base_data
  base_size <- nrow(base_data)
  
  # Add variations and extensions
  while (nrow(expanded) < target_size) {
    # Duplicate and modify existing entries
    sample_rows <- sample(1:base_size, min(10, base_size))
    new_entries <- base_data[sample_rows, ]
    
    # Modify entries to create variations
    if ("name" %in% names(new_entries)) {
      new_entries$name <- paste(new_entries$name, "(Enhanced)")
      new_entries$`ID#` <- paste0(new_entries$`ID#`, "_E", nrow(expanded) + 1:nrow(new_entries))
      new_entries$Source <- "Mock Enhanced"
    }
    
    expanded <- rbind(expanded, new_entries)
  }
  
  return(expanded[1:target_size, ])
}

# Main demonstration
demo_simple_extraction <- function() {
  cat("🎯 SIMPLE VOCABULARY EXTRACTION DEMO\n")
  cat("====================================\n\n")
  
  # Step 1: Manual extraction analysis
  extraction_plan <- manual_extract()
  
  # Step 2: Create integration components
  cat("\n")
  create_vocabulary_selector()
  
  # Step 3: Create mock data for immediate testing
  cat("\n") 
  create_mock_enhanced_vocabularies()
  
  cat("\n🎉 DEMO COMPLETE!\n")
  cat("Next steps:\n")
  cat("1. Integrate vocabulary selector into your app\n")
  cat("2. Test with mock enhanced vocabularies\n") 
  cat("3. Work on alternative extraction methods\n")
}

cat("🛡️ Simple Vocabulary Extractor Ready!\n")
cat("📋 Available functions:\n")
cat("   - demo_simple_extraction(): Complete demo with safer approach\n")
cat("   - simple_analyze(file): Minimal file analysis\n") 
cat("   - create_vocabulary_selector(): Generate integration code\n")
cat("   - create_mock_enhanced_vocabularies(): Create test data\n")
cat("\n🎯 Run: demo_simple_extraction() for safer approach!\n")