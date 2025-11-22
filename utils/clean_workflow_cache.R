#!/usr/bin/env Rscript
# Clean and repair workflow cache files
# This script will scan for .rds workflow files and fix any data structure issues

library(tools)

# Function to repair a workflow file
repair_workflow_file <- function(filepath) {
  cat("Checking:", filepath, "\n")
  
  tryCatch({
    # Load the workflow
    workflow <- readRDS(filepath)
    
    modified <- FALSE
    
    # Check and fix activities
    if (!is.null(workflow$project_data$activities)) {
      if (is.data.frame(workflow$project_data$activities)) {
        cat("  - Found data.frame activities, converting to vector\n")
        
        # Try different column name variations
        if ("Activity" %in% names(workflow$project_data$activities)) {
          workflow$project_data$activities <- as.character(workflow$project_data$activities$Activity)
          modified <- TRUE
        } else if ("Actvity" %in% names(workflow$project_data$activities)) {
          cat("  - Found TYPO 'Actvity', fixing...\n")
          workflow$project_data$activities <- as.character(workflow$project_data$activities$Actvity)
          modified <- TRUE
        }
      } else {
        workflow$project_data$activities <- as.character(workflow$project_data$activities)
      }
    }
    
    # Check and fix pressures
    if (!is.null(workflow$project_data$pressures)) {
      if (is.data.frame(workflow$project_data$pressures)) {
        cat("  - Found data.frame pressures, converting to vector\n")
        
        if ("Pressure" %in% names(workflow$project_data$pressures)) {
          workflow$project_data$pressures <- as.character(workflow$project_data$pressures$Pressure)
          modified <- TRUE
        }
      } else {
        workflow$project_data$pressures <- as.character(workflow$project_data$pressures)
      }
    }
    
    # Save if modified
    if (modified) {
      backup_file <- paste0(filepath, ".backup")
      cat("  - Creating backup:", backup_file, "\n")
      file.copy(filepath, backup_file, overwrite = TRUE)
      
      cat("  - Saving repaired file\n")
      saveRDS(workflow, filepath)
      cat("  ✅ File repaired successfully\n\n")
    } else {
      cat("  ✅ File is OK\n\n")
    }
    
  }, error = function(e) {
    cat("  ❌ Error processing file:", e$message, "\n\n")
  })
}

# Main execution
cat("===========================================\n")
cat("Workflow Cache Repair Tool\n")
cat("===========================================\n\n")

# Find all .rds files in Bow-tie guidance directory
workflow_dir <- "Bow-tie guidance"

if (dir.exists(workflow_dir)) {
  rds_files <- list.files(workflow_dir, pattern = "\\.rds$", full.names = TRUE)
  
  if (length(rds_files) > 0) {
    cat("Found", length(rds_files), "workflow file(s)\n\n")
    
    for (file in rds_files) {
      repair_workflow_file(file)
    }
    
    cat("===========================================\n")
    cat("Repair complete!\n")
    cat("===========================================\n")
  } else {
    cat("No .rds files found in", workflow_dir, "\n")
  }
} else {
  cat("Directory not found:", workflow_dir, "\n")
}
