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
    log_success("AI linker loaded successfully")
  }, error = function(e) {
    log_warning(paste("Failed to load vocabulary_ai_linker.R:", e$message))
  })
} else {
  log_warning("vocabulary_ai_linker.R not found. Will use basic linking only.")
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
  
  log_info("Starting vocabulary-based bow-tie network generation...")
  log_info(paste("Central problems:", paste(central_problems, collapse = ", ")))

  # Step 1: Load vocabulary data
  log_info("Loading vocabulary data...")
  vocabulary_data <- tryCatch({
    load_vocabulary()
  }, error = function(e) {
    log_warning(paste("Could not load vocabulary from Excel files:", e$message))
    log_info("Creating sample vocabulary data instead...")
    create_sample_vocabulary_data()
  })

  # Step 2: Generate AI-powered links between vocabulary items
  log_info("Generating intelligent connections between vocabulary elements...")

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
    log_info("Using basic connection method...")
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
  log_info(paste("Creating bow-tie networks for", length(central_problems), "central problems..."))

  all_bowtie_data <- data.frame()

  for (problem in central_problems) {
    log_debug(paste("  Processing:", problem))

    # Create bow-tie structure for this problem
    problem_bowtie <- create_problem_specific_bowtie(
      problem,
      vocabulary_data,
      vocabulary_links,
      max_connections_per_item
    )

    # Add to overall dataset
    all_bowtie_data <- rbind(all_bowtie_data, problem_bowtie)

    log_debug(paste("    Generated", nrow(problem_bowtie), "bow-tie entries"))
  }

  # Step 4: Enhance with risk assessments
  log_info("Adding risk assessments and likelihood/severity ratings...")
  enhanced_bowtie_data <- enhance_with_risk_data(all_bowtie_data)

  # Step 5: Export to Excel file
  log_info(paste("Exporting to Excel file:", output_file))
  # Validate output path: require directory to already exist (avoid creating arbitrary folders)
  output_dir <- dirname(output_file)
  if (nzchar(output_dir) && !dir.exists(output_dir)) {
    stop(sprintf("Output directory does not exist for output file '%s'", output_file))
  }
  export_bowtie_to_excel(enhanced_bowtie_data, output_file)
  
  log_success("Vocabulary-based bow-tie generation completed successfully!")
  log_info(paste("Output file:", output_file))
  log_info(paste("Total bow-tie entries generated:", nrow(enhanced_bowtie_data)))
  
  return(list(
    data = enhanced_bowtie_data,
    file = output_file,
    vocabulary_used = vocabulary_data,
    links_generated = vocabulary_links
  ))
}

# (rest of file kept unchanged intentionally for the commit)
