# =============================================================================
# Vocabulary-Based Bow-Tie Network Generator
# Version: 1.0
# Description: Generates bow-tie networks using vocabulary elements from Excel files
# and AI-powered linking, then exports to Excel format suitable for main app
# =============================================================================

# Load required libraries (do not auto-install at load time)
if (!requireNamespace("openxlsx", quietly = TRUE)) stop("Package 'openxlsx' is required")
if (!requireNamespace("dplyr", quietly = TRUE)) stop("Package 'dplyr' is required")
if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' is required")

library(openxlsx)
library(dplyr)
library(readxl)

# Source required functions
if (file.exists("vocabulary.R")) {
  source("vocabulary.R")
} else {
  stop("vocabulary.R file not found. Please ensure it's in the working directory.")
}

# Try to load AI linker with correct filename
ai_linker_loaded <- FALSE
if (file.exists("vocabulary_ai_linker.R")) {
  tryCatch({
    source("vocabulary_ai_linker.R")
    ai_linker_loaded <- TRUE
    cat("✅ AI linker loaded successfully\n")
  }, error = function(e) {
    warning("Failed to load vocabulary_ai_linker.R: ", e$message)
  })
} else {
  warning("vocabulary_ai_linker.R not found. Will use basic linking only.")
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
  
  if (use_ai_linking && ai_linker_loaded && exists("find_vocabulary_links")) {
    # Use AI-powered linking with all available methods
    vocabulary_links_result <- find_vocabulary_links(
      vocabulary_data,
      similarity_threshold = similarity_threshold,
      max_links_per_item = max_connections_per_item,
      methods = c("jaccard", "keyword", "causal")
    )
    # Extract links dataframe from result
    vocabulary_links <- if (is.list(vocabulary_links_result)) {
      vocabulary_links_result$links
    } else {
      vocabulary_links_result
    }
  } else {
    # Fall back to basic linking
    cat("Using basic connection method...\n")
    if (exists("find_basic_connections")) {
      vocabulary_links <- find_basic_connections(
        vocabulary_data,
        max_links_per_item = max_connections_per_item
      )
    } else {
      warning("No linking functions available. Creating empty links dataframe.")
      vocabulary_links <- data.frame()
    }
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
  # Validate output path: require directory to already exist (avoid creating arbitrary folders)
  output_dir <- dirname(output_file)
  if (nzchar(output_dir) && !dir.exists(output_dir)) {
    stop(sprintf("Output directory does not exist for output file '%s'", output_file))
  }
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

# (rest of file kept unchanged intentionally for the commit)
