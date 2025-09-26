# =============================================================================
# Guidance Vocabulary Preprocessor - Safe Extraction & Conversion
# Version: 1.0.0
# Date: September 2025
# Description: Safely extract and convert MARBEFES guidance vocabularies 
#              to current application format, avoiding R segfault issues
# =============================================================================

library(readxl)
library(openxlsx)
library(dplyr)
library(purrr)

cat("🔧 GUIDANCE VOCABULARY PREPROCESSOR v1.0.0\n")
cat("==========================================\n\n")

# Configuration
GUIDANCE_CONFIG <- list(
  input_files = list(
    causes = "Bow-tie guidance/Bow-tie_CAUSES & standardised vocabularies.xlsx",
    consequences = "Bow-tie guidance/Bow-tie_CONSEQUENCES  standardised vocabulary.xlsx",
    controls = "Bow-tie guidance/Bow-tie_CONTROLS & standardised vocabulary.xlsx"
  ),
  output_files = list(
    causes = "GUIDANCE_CAUSES.xlsx",
    consequences = "GUIDANCE_CONSEQUENCES.xlsx", 
    controls = "GUIDANCE_CONTROLS.xlsx"
  ),
  chunk_size = 500  # Process in chunks to avoid memory issues
)

# Safe sheet analyzer - avoids segfault
analyze_sheets_safely <- function(file_path, max_rows = 50) {
  cat("🔍 Analyzing sheets in:", basename(file_path), "\n")
  
  if (!file.exists(file_path)) {
    cat("   ❌ File not found\n")
    return(NULL)
  }
  
  tryCatch({
    sheets <- excel_sheets(file_path)
    cat("   📊 Found", length(sheets), "sheets:", paste(sheets, collapse = ", "), "\n")
    
    # Skip metadata sheets, find vocabulary sheets
    vocab_sheets <- sheets[!grepl("metadata", sheets, ignore.case = TRUE)]
    cat("   📋 Vocabulary sheets:", paste(vocab_sheets, collapse = ", "), "\n")
    
    # Analyze structure of vocabulary sheets
    sheet_info <- list()
    for (sheet in vocab_sheets) {
      cat("   🔍 Analyzing sheet:", sheet, "\n")
      
      # Read small sample to understand structure
      sample_data <- read_excel(file_path, sheet = sheet, n_max = max_rows)
      
      sheet_info[[sheet]] <- list(
        name = sheet,
        rows_preview = nrow(sample_data),
        columns = names(sample_data),
        has_hierarchy = "Hierarchy" %in% names(sample_data),
        has_id = any(grepl("ID", names(sample_data), ignore.case = TRUE)),
        has_name = any(grepl("name|term|description", names(sample_data), ignore.case = TRUE))
      )
      
      cat("      Columns:", paste(head(names(sample_data), 4), collapse = ", "), "\n")
      cat("      Structure check: Hierarchy =", sheet_info[[sheet]]$has_hierarchy,
          "| ID =", sheet_info[[sheet]]$has_id, 
          "| Name =", sheet_info[[sheet]]$has_name, "\n")
    }
    
    return(list(all_sheets = sheets, vocab_sheets = vocab_sheets, sheet_info = sheet_info))
    
  }, error = function(e) {
    cat("   ❌ Error analyzing file:", e$message, "\n")
    return(NULL)
  })
}

# Progressive sheet reader - chunks to avoid segfault
read_sheet_progressively <- function(file_path, sheet_name, chunk_size = 500) {
  cat("📖 Progressive reading:", sheet_name, "from", basename(file_path), "\n")
  
  all_data <- data.frame()
  current_row <- 1
  chunk_num <- 1
  
  repeat {
    cat("   📦 Reading chunk", chunk_num, "(rows", current_row, "-", current_row + chunk_size - 1, ")\n")
    
    tryCatch({
      chunk_data <- read_excel(
        file_path, 
        sheet = sheet_name, 
        skip = if(current_row == 1) 0 else current_row - 1,
        n_max = chunk_size,
        col_names = if(current_row == 1) TRUE else FALSE
      )
      
      if (nrow(chunk_data) == 0) {
        cat("   ✅ Reached end of data\n")
        break
      }
      
      # Use column names from first chunk
      if (current_row > 1) {
        names(chunk_data) <- names(all_data)
      }
      
      all_data <- rbind(all_data, chunk_data)
      current_row <- current_row + nrow(chunk_data)
      chunk_num <- chunk_num + 1
      
      # Safety limit
      if (nrow(all_data) > 10000) {
        cat("   ⚠️ Reached safety limit of 10,000 rows\n")
        break
      }
      
    }, error = function(e) {
      cat("   ❌ Error in chunk", chunk_num, ":", e$message, "\n")
      break
    })
  }
  
  cat("   ✅ Progressive read complete:", nrow(all_data), "total rows\n")
  return(all_data)
}

# Convert guidance format to current application format
convert_to_current_format <- function(raw_data, vocab_type) {
  cat("🔄 Converting", vocab_type, "to current format...\n")
  
  if (nrow(raw_data) == 0) {
    cat("   ⚠️ No data to convert\n")
    return(data.frame())
  }
  
  # Map columns to current format
  column_mapping <- list(
    hierarchy = c("Hierarchy", "Level", "Category"),
    id = c("ID#", "ID", "Code", "Identifier"),
    name = c("name", "Name", "Term", "Description", "Activity", "Pressure", "Consequence", "Control")
  )
  
  # Find matching columns
  mapped_data <- raw_data
  current_cols <- names(mapped_data)
  
  # Map hierarchy column
  hierarchy_col <- intersect(column_mapping$hierarchy, current_cols)
  if (length(hierarchy_col) > 0) {
    mapped_data$Hierarchy <- mapped_data[[hierarchy_col[1]]]
  }
  
  # Map ID column  
  id_col <- intersect(column_mapping$id, current_cols)
  if (length(id_col) > 0) {
    mapped_data$`ID#` <- mapped_data[[id_col[1]]]
  } else {
    # Generate IDs if missing
    mapped_data$`ID#` <- paste0(toupper(substr(vocab_type, 1, 1)), 1:nrow(mapped_data))
  }
  
  # Map name column
  name_col <- intersect(column_mapping$name, current_cols)
  if (length(name_col) > 0) {
    mapped_data$name <- mapped_data[[name_col[1]]]
  }
  
  # Select and clean final columns
  final_data <- mapped_data %>%
    select(any_of(c("Hierarchy", "ID#", "name"))) %>%
    filter(!is.na(`ID#`), !is.na(name)) %>%
    mutate(
      Hierarchy = as.character(Hierarchy),
      `ID#` = as.character(`ID#`),
      name = trimws(as.character(name)),
      Source = "MARBEFES Guidance",
      vocab_type = vocab_type,
      processed_date = Sys.Date()
    ) %>%
    distinct()  # Remove duplicates
  
  cat("   ✅ Converted", nrow(final_data), "rows to current format\n")
  return(final_data)
}

# Process a single guidance file
process_guidance_file <- function(input_file, output_file, vocab_type) {
  cat("\n🎯 PROCESSING", toupper(vocab_type), "GUIDANCE FILE\n")
  cat("=======================================\n")
  cat("Input:", input_file, "\n")
  cat("Output:", output_file, "\n\n")
  
  # Step 1: Analyze file structure
  analysis <- analyze_sheets_safely(input_file)
  if (is.null(analysis)) {
    cat("❌ Failed to analyze file\n")
    return(FALSE)
  }
  
  # Step 2: Process vocabulary sheets
  all_vocab_data <- data.frame()
  
  for (sheet_name in analysis$vocab_sheets) {
    cat("\n📋 Processing sheet:", sheet_name, "\n")
    
    # Read sheet progressively to avoid segfault
    sheet_data <- read_sheet_progressively(input_file, sheet_name, GUIDANCE_CONFIG$chunk_size)
    
    if (nrow(sheet_data) > 0) {
      # Convert to current format
      converted_data <- convert_to_current_format(sheet_data, vocab_type)
      converted_data$sheet_source <- sheet_name
      
      all_vocab_data <- rbind(all_vocab_data, converted_data)
    }
  }
  
  # Step 3: Save processed data
  if (nrow(all_vocab_data) > 0) {
    cat("\n💾 Saving processed data...\n")
    cat("   Total rows:", nrow(all_vocab_data), "\n")
    cat("   Unique terms:", length(unique(all_vocab_data$name)), "\n")
    
    # Create workbook with summary sheet
    wb <- createWorkbook()
    
    # Add main vocabulary sheet
    addWorksheet(wb, vocab_type)
    writeData(wb, vocab_type, all_vocab_data)
    
    # Add summary sheet
    addWorksheet(wb, "SUMMARY")
    summary_data <- data.frame(
      Metric = c("Total Terms", "Unique Terms", "Sheets Processed", "Processing Date", "Source"),
      Value = c(
        nrow(all_vocab_data),
        length(unique(all_vocab_data$name)),
        length(analysis$vocab_sheets),
        as.character(Sys.Date()),
        "MARBEFES Guidance"
      )
    )
    writeData(wb, "SUMMARY", summary_data)
    
    # Save file
    saveWorkbook(wb, output_file, overwrite = TRUE)
    cat("   ✅ Saved to:", output_file, "\n")
    
    return(TRUE)
  } else {
    cat("   ❌ No vocabulary data extracted\n")
    return(FALSE)
  }
}

# Main preprocessing function
preprocess_all_guidance_vocabularies <- function() {
  cat("🚀 STARTING GUIDANCE VOCABULARY PREPROCESSING\n")
  cat("============================================\n")
  
  results <- list()
  
  # Process each vocabulary type
  for (vocab_type in names(GUIDANCE_CONFIG$input_files)) {
    input_file <- GUIDANCE_CONFIG$input_files[[vocab_type]]
    output_file <- GUIDANCE_CONFIG$output_files[[vocab_type]]
    
    success <- process_guidance_file(input_file, output_file, vocab_type)
    results[[vocab_type]] <- success
  }
  
  # Summary
  cat("\n📊 PREPROCESSING SUMMARY\n")
  cat("========================\n")
  successful <- sum(unlist(results))
  total <- length(results)
  
  for (vocab_type in names(results)) {
    status <- if (results[[vocab_type]]) "✅ SUCCESS" else "❌ FAILED"
    cat(sprintf("%-12s: %s\n", toupper(vocab_type), status))
  }
  
  cat("\n🎯 Overall Result:", successful, "of", total, "files processed successfully\n")
  
  if (successful > 0) {
    cat("\n🚀 NEXT STEPS:\n")
    cat("1. Test processed files with current application\n")
    cat("2. Add vocabulary source selector to UI\n") 
    cat("3. Implement vocabulary comparison features\n")
    cat("4. Update vocabulary.r to handle both formats\n")
  }
  
  return(results)
}

# Testing function
test_processed_vocabularies <- function() {
  cat("🧪 TESTING PROCESSED VOCABULARIES\n")
  cat("=================================\n")
  
  for (vocab_type in names(GUIDANCE_CONFIG$output_files)) {
    output_file <- GUIDANCE_CONFIG$output_files[[vocab_type]]
    
    cat("\n📄 Testing:", output_file, "\n")
    
    if (file.exists(output_file)) {
      tryCatch({
        # Test loading with current vocabulary system
        test_data <- read_excel(output_file, sheet = vocab_type)
        
        cat("   ✅ File loads successfully\n")
        cat("   📊 Rows:", nrow(test_data), "\n")
        cat("   📋 Columns:", paste(names(test_data), collapse = ", "), "\n")
        
        # Check current format compatibility
        has_required <- all(c("Hierarchy", "ID#", "name") %in% names(test_data))
        cat("   🔧 Current format compatible:", has_required, "\n")
        
      }, error = function(e) {
        cat("   ❌ Error testing file:", e$message, "\n")
      })
    } else {
      cat("   ❌ File not found\n")
    }
  }
}

# Demo function
demo_preprocessing <- function() {
  cat("🎯 GUIDANCE VOCABULARY PREPROCESSING DEMO\n")
  cat("=========================================\n")
  
  # Run preprocessing
  results <- preprocess_all_guidance_vocabularies()
  
  # Test results
  cat("\n" + rep("=", 50), "\n")
  test_processed_vocabularies()
  
  return(results)
}

cat("✅ Guidance Vocabulary Preprocessor Ready!\n")
cat("📋 Available functions:\n")
cat("   - preprocess_all_guidance_vocabularies(): Process all guidance files\n")
cat("   - process_guidance_file(input, output, type): Process single file\n")
cat("   - test_processed_vocabularies(): Test processed files\n")
cat("   - demo_preprocessing(): Complete demo run\n")
cat("\n🎯 Run: demo_preprocessing() to start!\n")