# =============================================================================
# Code Quality Validation Tool for Environmental Bowtie Risk Analysis
# Version: 5.1.0
# Author: Enhanced Development Framework
# Description: Comprehensive code quality analysis and validation
# =============================================================================

# Load required libraries
suppressPackageStartupMessages({
  library(lintr)
  library(codetools)
})

# =============================================================================
# Code Quality Analysis Functions
# =============================================================================

run_code_quality_check <- function() {
  cat("🔍 Environmental Bowtie Risk Analysis - Code Quality Check\n")
  cat("=========================================================\n\n")

  # Get all R files in the project
  r_files <- list.files(pattern = "\\.r$|\\.R$", recursive = TRUE, full.names = TRUE)
  r_files <- r_files[!grepl("tests/|archive/|utils/", r_files)]  # Exclude test and archive files

  cat("📁 Found", length(r_files), "R files for analysis:\n")
  for (file in r_files) {
    cat("   -", basename(file), "\n")
  }
  cat("\n")

  # Initialize results
  quality_results <- list()

  # Run checks for each file
  for (file in r_files) {
    cat("🔍 Analyzing:", basename(file), "\n")
    file_results <- analyze_file_quality(file)
    quality_results[[basename(file)]] <- file_results
  }

  # Generate summary report
  generate_quality_report(quality_results)

  cat("\n✅ Code quality analysis completed!\n")
  cat("📋 Detailed report saved to: code_quality_report.txt\n")

  return(quality_results)
}

analyze_file_quality <- function(file_path) {
  results <- list(
    file = basename(file_path),
    size_kb = round(file.size(file_path) / 1024, 2),
    line_count = count_lines(file_path),
    lint_issues = list(),
    syntax_issues = list(),
    complexity_metrics = list(),
    best_practices = list()
  )

  tryCatch({
    # 1. Lint Analysis
    cat("   📝 Running lint analysis...\n")
    lint_results <- lintr::lint(file_path)
    results$lint_issues <- process_lint_results(lint_results)

    # 2. Syntax Check
    cat("   🔧 Checking syntax...\n")
    results$syntax_issues <- check_syntax(file_path)

    # 3. Code Complexity
    cat("   📊 Analyzing complexity...\n")
    results$complexity_metrics <- analyze_complexity(file_path)

    # 4. Best Practices Check
    cat("   ✅ Checking best practices...\n")
    results$best_practices <- check_best_practices(file_path)

  }, error = function(e) {
    cat("   ⚠️ Error analyzing file:", e$message, "\n")
    results$error <- e$message
  })

  return(results)
}

count_lines <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  list(
    total = length(lines),
    code = sum(!grepl("^\\s*$|^\\s*#", lines)),  # Non-empty, non-comment lines
    comments = sum(grepl("^\\s*#", lines)),
    blank = sum(grepl("^\\s*$", lines))
  )
}

process_lint_results <- function(lint_results) {
  if (length(lint_results) == 0) {
    return(list(count = 0, issues = list()))
  }

  issues <- lapply(lint_results, function(issue) {
    list(
      line = issue$line_number,
      column = issue$column_number,
      type = issue$type,
      message = issue$message,
      linter = issue$linter
    )
  })

  list(
    count = length(issues),
    issues = issues,
    by_type = table(sapply(lint_results, function(x) x$type))
  )
}

check_syntax <- function(file_path) {
  issues <- list()

  tryCatch({
    # Parse the file to check for syntax errors
    parsed <- parse(file_path)
    issues$syntax_valid <- TRUE
  }, error = function(e) {
    issues$syntax_valid <- FALSE
    issues$syntax_error <- e$message
  })

  # Check for common issues
  content <- readLines(file_path, warn = FALSE)

  # Check for unmatched parentheses, brackets, braces
  issues$parentheses_balanced <- check_balanced_delimiters(content, "(", ")")
  issues$brackets_balanced <- check_balanced_delimiters(content, "[", "]")
  issues$braces_balanced <- check_balanced_delimiters(content, "{", "}")

  return(issues)
}

check_balanced_delimiters <- function(content, open_char, close_char) {
  text <- paste(content, collapse = " ")
  open_count <- length(gregexpr(paste0("\\", open_char), text, fixed = FALSE)[[1]])
  close_count <- length(gregexpr(paste0("\\", close_char), text, fixed = FALSE)[[1]])

  if (open_count == 1 && close_count == 1 &&
      gregexpr(paste0("\\", open_char), text)[[1]][1] == -1) {
    open_count <- 0
  }
  if (close_count == 1 && gregexpr(paste0("\\", close_char), text)[[1]][1] == -1) {
    close_count <- 0
  }

  return(open_count == close_count)
}

analyze_complexity <- function(file_path) {
  content <- readLines(file_path, warn = FALSE)
  code_lines <- content[!grepl("^\\s*$|^\\s*#", content)]

  metrics <- list(
    total_lines = length(content),
    code_lines = length(code_lines),
    comment_ratio = round((length(content) - length(code_lines)) / length(content) * 100, 2),
    function_count = length(grep("^\\s*[a-zA-Z_][a-zA-Z0-9_]*\\s*<-\\s*function", content)),
    if_statements = length(grep("\\bif\\s*\\(", content)),
    for_loops = length(grep("\\bfor\\s*\\(", content)),
    while_loops = length(grep("\\bwhile\\s*\\(", content)),
    nested_depth = calculate_nesting_depth(content)
  )

  # Calculate complexity score
  metrics$complexity_score <- calculate_complexity_score(metrics)

  return(metrics)
}

calculate_nesting_depth <- function(content) {
  max_depth <- 0
  current_depth <- 0

  for (line in content) {
    # Count opening braces
    opens <- length(gregexpr("\\{", line)[[1]])
    if (opens == 1 && gregexpr("\\{", line)[[1]][1] == -1) opens <- 0

    # Count closing braces
    closes <- length(gregexpr("\\}", line)[[1]])
    if (closes == 1 && gregexpr("\\}", line)[[1]][1] == -1) closes <- 0

    current_depth <- current_depth + opens - closes
    max_depth <- max(max_depth, current_depth)
  }

  return(max_depth)
}

calculate_complexity_score <- function(metrics) {
  score <- 0

  # Base score from code lines
  score <- score + metrics$code_lines * 0.1

  # Add points for control structures
  score <- score + metrics$if_statements * 2
  score <- score + metrics$for_loops * 3
  score <- score + metrics$while_loops * 3

  # Add points for nesting
  score <- score + metrics$nested_depth * 5

  # Subtract points for good commenting
  if (metrics$comment_ratio > 20) score <- score * 0.8
  if (metrics$comment_ratio > 30) score <- score * 0.7

  return(round(score, 2))
}

check_best_practices <- function(file_path) {
  content <- readLines(file_path, warn = FALSE)
  practices <- list()

  # Check for header comments
  practices$has_header <- any(grepl("^#.*=.*=", content[1:10]))

  # Check for function documentation
  practices$documented_functions <- check_function_documentation(content)

  # Check for library loading patterns
  practices$proper_library_loading <- check_library_loading(content)

  # Check for hardcoded paths
  practices$no_hardcoded_paths <- !any(grepl("C:|D:|/home/|/Users/", content))

  # Check for magic numbers
  practices$magic_numbers <- find_magic_numbers(content)

  # Check for consistent naming
  practices$naming_consistency <- check_naming_consistency(content)

  return(practices)
}

check_function_documentation <- function(content) {
  function_lines <- grep("^\\s*[a-zA-Z_][a-zA-Z0-9_]*\\s*<-\\s*function", content)
  documented_count <- 0

  for (func_line in function_lines) {
    # Check if there's a comment block before the function
    if (func_line > 3) {
      prev_lines <- content[(func_line-3):(func_line-1)]
      if (any(grepl("^\\s*#", prev_lines))) {
        documented_count <- documented_count + 1
      }
    }
  }

  return(list(
    total_functions = length(function_lines),
    documented = documented_count,
    documentation_ratio = ifelse(length(function_lines) > 0,
                                round(documented_count / length(function_lines) * 100, 2), 0)
  ))
}

check_library_loading <- function(content) {
  library_lines <- grep("library\\(|require\\(", content)
  proper_loading <- TRUE

  # Check if libraries are loaded at the top of the file
  if (length(library_lines) > 0) {
    if (max(library_lines) > 50) {  # Libraries loaded after line 50
      proper_loading <- FALSE
    }
  }

  return(list(
    library_count = length(library_lines),
    proper_placement = proper_loading
  ))
}

find_magic_numbers <- function(content) {
  # Find numeric literals that might be magic numbers
  magic_pattern <- "\\b[0-9]{2,}\\b"  # Numbers with 2+ digits
  magic_lines <- grep(magic_pattern, content, value = TRUE)

  # Exclude common non-magic numbers
  exclude_pattern <- "\\b(100|1000|2000|2024|2025|0\\.0|1\\.0)\\b"
  magic_lines <- magic_lines[!grepl(exclude_pattern, magic_lines)]

  return(list(
    count = length(magic_lines),
    examples = head(magic_lines, 5)
  ))
}

check_naming_consistency <- function(content) {
  # Extract variable names
  var_pattern <- "\\b[a-zA-Z_][a-zA-Z0-9_]*\\s*<-"
  var_matches <- gregexpr(var_pattern, paste(content, collapse = " "))[[1]]

  # Check for snake_case vs camelCase consistency
  snake_case_count <- length(grep("_", content))
  camel_case_count <- length(grep("[a-z][A-Z]", content))

  return(list(
    snake_case_usage = snake_case_count,
    camel_case_usage = camel_case_count,
    consistent_style = abs(snake_case_count - camel_case_count) < 5
  ))
}

generate_quality_report <- function(results) {
  sink("code_quality_report.txt")

  cat("Environmental Bowtie Risk Analysis - Code Quality Report\n")
  cat("=======================================================\n")
  cat("Generated:", as.character(Sys.time()), "\n\n")

  total_files <- length(results)
  total_lines <- sum(sapply(results, function(x) x$line_count$total))
  total_lint_issues <- sum(sapply(results, function(x) x$lint_issues$count))

  cat("Summary Statistics:\n")
  cat("- Total files analyzed:", total_files, "\n")
  cat("- Total lines of code:", total_lines, "\n")
  cat("- Total lint issues:", total_lint_issues, "\n")
  cat("- Average file size:", round(mean(sapply(results, function(x) x$size_kb)), 2), "KB\n\n")

  for (file_name in names(results)) {
    file_result <- results[[file_name]]
    cat("File:", file_name, "\n")
    cat(paste0(rep("=", nchar(file_name) + 5), collapse = ""), "\n")

    cat("Basic Metrics:\n")
    cat("- Size:", file_result$size_kb, "KB\n")
    cat("- Total lines:", file_result$line_count$total, "\n")
    cat("- Code lines:", file_result$line_count$code, "\n")
    cat("- Comment lines:", file_result$line_count$comments, "\n")
    cat("- Blank lines:", file_result$line_count$blank, "\n")

    if (!is.null(file_result$complexity_metrics)) {
      cat("\nComplexity Metrics:\n")
      cat("- Functions:", file_result$complexity_metrics$function_count, "\n")
      cat("- Complexity score:", file_result$complexity_metrics$complexity_score, "\n")
      cat("- Max nesting depth:", file_result$complexity_metrics$nested_depth, "\n")
      cat("- Comment ratio:", file_result$complexity_metrics$comment_ratio, "%\n")
    }

    cat("\nLint Issues:", file_result$lint_issues$count, "\n")

    if (!is.null(file_result$best_practices)) {
      cat("\nBest Practices:\n")
      cat("- Has header:", ifelse(file_result$best_practices$has_header, "✅", "❌"), "\n")
      cat("- Function documentation:", file_result$best_practices$documented_functions$documentation_ratio, "%\n")
      cat("- Proper library loading:", ifelse(file_result$best_practices$proper_library_loading$proper_placement, "✅", "❌"), "\n")
      cat("- No hardcoded paths:", ifelse(file_result$best_practices$no_hardcoded_paths, "✅", "❌"), "\n")
    }

    cat("\n" , paste0(rep("-", 80), collapse = ""), "\n\n")
  }

  # Recommendations
  cat("Recommendations:\n")
  cat("================\n")
  cat("1. Address high-priority lint issues\n")
  cat("2. Add documentation to undocumented functions\n")
  cat("3. Reduce complexity in files with high complexity scores\n")
  cat("4. Ensure consistent coding style across all files\n")
  cat("5. Add header comments to files that lack them\n")

  sink()

  # Also save as RDS for programmatic access
  saveRDS(results, "code_quality_results.rds")
}

# =============================================================================
# Style Guide Enforcement
# =============================================================================

create_style_guide <- function() {
  style_guide <- "
Environmental Bowtie Risk Analysis - R Style Guide
==================================================

1. File Structure:
   - Header comment with file description
   - Library imports at the top
   - Function definitions
   - Main execution code

2. Naming Conventions:
   - Variables: snake_case (e.g., user_input, data_frame)
   - Functions: camelCase (e.g., createBowtieNodes, analyzeRisk)
   - Constants: UPPER_CASE (e.g., MAX_ITERATIONS)

3. Code Organization:
   - Maximum line length: 80 characters
   - Indentation: 2 spaces (no tabs)
   - Blank lines to separate logical sections

4. Comments:
   - Function documentation before each function
   - Inline comments for complex logic
   - Section headers with # ============

5. Best Practices:
   - Avoid magic numbers
   - Use meaningful variable names
   - Keep functions focused and small
   - Handle errors gracefully with tryCatch
"

  writeLines(style_guide, "R_STYLE_GUIDE.txt")
  cat("📋 Style guide saved to: R_STYLE_GUIDE.txt\n")
}

# =============================================================================
# Main Execution
# =============================================================================

if (!interactive()) {
  # Install required packages if missing
  required_packages <- c("lintr", "codetools")
  missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]

  if (length(missing_packages) > 0) {
    cat("📦 Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
    install.packages(missing_packages)
  }

  # Run code quality check
  results <- run_code_quality_check()

  # Create style guide
  create_style_guide()

  cat("\n🎉 Code quality analysis complete!\n")
  cat("📁 Reports saved in current directory\n")
} else {
  cat("📋 Code quality tools loaded. Available functions:\n")
  cat("   - run_code_quality_check(): Run full quality analysis\n")
  cat("   - analyze_file_quality(file): Analyze specific file\n")
  cat("   - create_style_guide(): Generate style guide\n")
}