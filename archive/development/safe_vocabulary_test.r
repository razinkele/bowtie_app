# =============================================================================
# Safe Vocabulary Testing - Avoiding R Segfault with Large Files
# Version: 6.0.0 (Safe Test Version)
# =============================================================================

library(readxl)
library(dplyr)

cat("🧪 SAFE VOCABULARY TESTING v6.0.0\n")
cat("==================================\n\n")

# Function to safely analyze file without full loading
analyze_file_safely <- function(file_path, max_preview_rows = 100) {
  cat("📄 Analyzing:", basename(file_path), "\n")
  
  if (!file.exists(file_path)) {
    cat("   ❌ File not found\n")
    return(NULL)
  }
  
  # Get file size
  file_size <- file.size(file_path)
  file_size_mb <- round(file_size / 1024 / 1024, 2)
  cat("   📊 File size:", file_size_mb, "MB\n")
  
  tryCatch({
    # Get sheet information
    sheets <- excel_sheets(file_path)
    cat("   📋 Sheets (", length(sheets), "):", paste(head(sheets, 3), collapse = ", "), "\n")
    
    # Preview first sheet with limited rows
    primary_sheet <- sheets[1]
    preview_data <- read_excel(file_path, sheet = primary_sheet, n_max = max_preview_rows)
    
    cat("   🔍 Preview from sheet '", primary_sheet, "':\n")
    cat("      Rows in preview:", nrow(preview_data), "\n")
    cat("      Columns:", ncol(preview_data), "\n")
    cat("      Column names:", paste(head(names(preview_data), 5), collapse = ", "), "\n")
    
    # Check for standard vocabulary structure
    has_hierarchy <- "Hierarchy" %in% names(preview_data)
    has_id <- "ID#" %in% names(preview_data) || "ID" %in% names(preview_data)
    has_name <- any(c("name", "Name", "Description", "Term") %in% names(preview_data))
    
    cat("   ✅ Standard structure check:\n")
    cat("      Has Hierarchy:", has_hierarchy, "\n")
    cat("      Has ID field:", has_id, "\n")
    cat("      Has Name field:", has_name, "\n")
    
    # Sample data preview
    if (nrow(preview_data) > 0 && has_hierarchy) {
      unique_hierarchies <- unique(preview_data$Hierarchy[!is.na(preview_data$Hierarchy)])
      cat("   📊 Hierarchy levels found:", paste(head(unique_hierarchies, 5), collapse = ", "), "\n")
    }
    
    return(list(
      file_size_mb = file_size_mb,
      sheets = sheets,
      preview_rows = nrow(preview_data),
      columns = names(preview_data),
      has_standard_structure = has_hierarchy && has_id && has_name
    ))
    
  }, error = function(e) {
    cat("   ❌ Error analyzing file:", e$message, "\n")
    return(NULL)
  })
}

# Test current vocabulary files
cat("📋 TESTING CURRENT VOCABULARY FILES\n")
cat("====================================\n")

current_files <- c(
  "CAUSES.xlsx",
  "CONSEQUENCES.xlsx", 
  "CONTROLS.xlsx"
)

current_results <- list()
for (file in current_files) {
  result <- analyze_file_safely(file)
  current_results[[file]] <- result
  cat("\n")
}

# Test guidance vocabulary files
cat("\n📋 TESTING GUIDANCE VOCABULARY FILES\n")
cat("=====================================\n")

guidance_files <- c(
  "Bow-tie guidance/Bow-tie_CAUSES & standardised vocabularies.xlsx",
  "Bow-tie guidance/Bow-tie_CONSEQUENCES  standardised vocabulary.xlsx",
  "Bow-tie guidance/Bow-tie_CONTROLS & standardised vocabulary.xlsx"
)

guidance_results <- list()
for (file in guidance_files) {
  result <- analyze_file_safely(file, max_preview_rows = 50)  # Smaller preview for large files
  guidance_results[[basename(file)]] <- result
  cat("\n")
}

# Comparison analysis
cat("\n📊 VOCABULARY COMPARISON ANALYSIS\n")
cat("==================================\n")

comparison_table <- data.frame(
  Component = c("CAUSES", "CONSEQUENCES", "CONTROLS"),
  Current_Size_MB = c(
    ifelse(!is.null(current_results[["CAUSES.xlsx"]]), current_results[["CAUSES.xlsx"]]$file_size_mb, NA),
    ifelse(!is.null(current_results[["CONSEQUENCES.xlsx"]]), current_results[["CONSEQUENCES.xlsx"]]$file_size_mb, NA),
    ifelse(!is.null(current_results[["CONTROLS.xlsx"]]), current_results[["CONTROLS.xlsx"]]$file_size_mb, NA)
  ),
  Guidance_Size_MB = c(
    ifelse(!is.null(guidance_results[["Bow-tie_CAUSES & standardised vocabularies.xlsx"]]), 
           guidance_results[["Bow-tie_CAUSES & standardised vocabularies.xlsx"]]$file_size_mb, NA),
    ifelse(!is.null(guidance_results[["Bow-tie_CONSEQUENCES  standardised vocabulary.xlsx"]]), 
           guidance_results[["Bow-tie_CONSEQUENCES  standardised vocabulary.xlsx"]]$file_size_mb, NA),
    ifelse(!is.null(guidance_results[["Bow-tie_CONTROLS & standardised vocabulary.xlsx"]]), 
           guidance_results[["Bow-tie_CONTROLS & standardised vocabulary.xlsx"]]$file_size_mb, NA)
  )
)

comparison_table$Expansion_Factor <- round(comparison_table$Guidance_Size_MB / comparison_table$Current_Size_MB, 1)

cat("📈 SIZE COMPARISON:\n")
for (i in 1:nrow(comparison_table)) {
  cat(sprintf("   %-12s: %5.2f MB → %6.2f MB (%.1fx larger)\n", 
              comparison_table$Component[i],
              comparison_table$Current_Size_MB[i],
              comparison_table$Guidance_Size_MB[i], 
              comparison_table$Expansion_Factor[i]))
}

# Structure compatibility check
cat("\n🔍 STRUCTURE COMPATIBILITY CHECK:\n")
cat("==================================\n")

for (component in c("CAUSES", "CONSEQUENCES", "CONTROLS")) {
  current_key <- paste0(component, ".xlsx")
  guidance_key <- switch(component,
                        "CAUSES" = "Bow-tie_CAUSES & standardised vocabularies.xlsx",
                        "CONSEQUENCES" = "Bow-tie_CONSEQUENCES  standardised vocabulary.xlsx", 
                        "CONTROLS" = "Bow-tie_CONTROLS & standardised vocabulary.xlsx")
  
  current_compatible <- ifelse(!is.null(current_results[[current_key]]), 
                              current_results[[current_key]]$has_standard_structure, FALSE)
  guidance_compatible <- ifelse(!is.null(guidance_results[[guidance_key]]), 
                               guidance_results[[guidance_key]]$has_standard_structure, FALSE)
  
  cat(sprintf("   %-12s: Current %-5s | Guidance %-5s\n", 
              component, 
              ifelse(current_compatible, "✅", "❌"),
              ifelse(guidance_compatible, "✅", "❌")))
}

# Recommendations
cat("\n🎯 INTEGRATION RECOMMENDATIONS:\n")
cat("===============================\n")

total_guidance_size <- sum(comparison_table$Guidance_Size_MB, na.rm = TRUE)
if (total_guidance_size > 2) {
  cat("⚠️  Large guidance files detected (", round(total_guidance_size, 1), "MB total)\n")
  cat("🔧 Recommended approach:\n")
  cat("   1. Implement progressive loading (chunk-based reading)\n")
  cat("   2. Add vocabulary caching system\n") 
  cat("   3. Provide vocabulary source selection in UI\n")
  cat("   4. Enable partial vocabulary loading\n")
} else {
  cat("✅ Guidance files manageable size - direct integration possible\n")
}

cat("\n✅ SAFE VOCABULARY TESTING COMPLETE!\n")
cat("=====================================\n")
cat("📊 Results saved in workspace for further analysis\n")

# Return results for programmatic access
invisible(list(
  current = current_results,
  guidance = guidance_results,
  comparison = comparison_table
))