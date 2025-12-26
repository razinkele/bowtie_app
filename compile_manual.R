#!/usr/bin/env Rscript
# Compile USER_MANUAL.Rmd to PDF
# Version: 5.3.0

cat("=============================================================================\n")
cat("  Environmental Bowtie Risk Analysis - PDF Manual Compilation\n")
cat("  Version: 5.3.0\n")
cat("=============================================================================\n\n")

# Check and install required packages
cat("[INFO] Checking required packages...\n")

if (!require("rmarkdown", quietly = TRUE)) {
  cat("[INFO] Installing rmarkdown package...\n")
  install.packages("rmarkdown", repos = "https://cran.r-project.org", quiet = TRUE)
}

if (!require("knitr", quietly = TRUE)) {
  cat("[INFO] Installing knitr package...\n")
  install.packages("knitr", repos = "https://cran.r-project.org", quiet = TRUE)
}

# Check for LaTeX installation
cat("[INFO] Checking LaTeX installation...\n")
has_latex <- FALSE

tryCatch({
  if (require("tinytex", quietly = TRUE)) {
    has_latex <- tinytex::tinytex_root() != ""
  }
}, error = function(e) {
  has_latex <- FALSE
})

if (!has_latex) {
  cat("[WARNING] LaTeX not found. Installing TinyTeX (this may take a few minutes)...\n")
  if (!require("tinytex", quietly = TRUE)) {
    install.packages("tinytex", repos = "https://cran.r-project.org")
  }
  tinytex::install_tinytex()
  cat("[SUCCESS] TinyTeX installed successfully!\n")
}

# Compile the manual
cat("\n[INFO] Compiling USER_MANUAL.Rmd to PDF...\n")

input_file <- "docs/USER_MANUAL.Rmd"
output_file <- "Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.pdf"
output_dir <- "docs"

if (!file.exists(input_file)) {
  stop("ERROR: USER_MANUAL.Rmd not found at: ", input_file)
}

tryCatch({
  rmarkdown::render(
    input = input_file,
    output_format = "pdf_document",
    output_file = output_file,
    output_dir = output_dir,
    quiet = FALSE
  )

  cat("\n=============================================================================\n")
  cat("[SUCCESS] PDF Manual compiled successfully!\n")
  cat("=============================================================================\n\n")
  cat("Manual Details:\n")
  cat("  File: ", output_file, "\n")
  cat("  Location: ", file.path(output_dir, output_file), "\n")
  cat("  Version: 5.3.0\n")

  # Get file size
  file_path <- file.path(output_dir, output_file)
  if (file.exists(file_path)) {
    file_size <- file.info(file_path)$size
    cat("  Size: ", round(file_size / 1024, 2), " KB\n")
  }

  cat("\n✅ Manual is ready for distribution!\n")

}, error = function(e) {
  cat("\n=============================================================================\n")
  cat("[ERROR] Failed to compile PDF manual\n")
  cat("=============================================================================\n\n")
  cat("Error message:\n", e$message, "\n\n")
  cat("Note: PDF compilation requires LaTeX. Attempting HTML output as fallback...\n\n")

  # Fallback to HTML
  tryCatch({
    rmarkdown::render(
      input = input_file,
      output_format = "html_document",
      output_file = "Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.html",
      output_dir = output_dir,
      quiet = FALSE
    )
    cat("[SUCCESS] HTML manual created as fallback!\n")
    cat("Location: docs/Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.html\n")
  }, error = function(e2) {
    cat("[ERROR] HTML fallback also failed:\n", e2$message, "\n")
    stop("Manual compilation failed")
  })
})
