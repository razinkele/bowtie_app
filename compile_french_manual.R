#!/usr/bin/env Rscript

# Compile French Manual to PDF
# Version 5.3.0
# This script compiles the French user manual from R Markdown to PDF format

cat("===============================================\n")
cat("French Manual PDF Compilation Script\n")
cat("Version 5.3.0\n")
cat("===============================================\n\n")

# Check for required packages
required_packages <- c("rmarkdown", "knitr")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, repos = "https://cloud.r-project.org/")
}

# Load required libraries
library(rmarkdown)
library(knitr)

# Define paths
input_file <- "docs/MANUEL_UTILISATEUR.Rmd"
output_dir <- "docs"
output_file <- "Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0_FR.pdf"
output_path <- file.path(output_dir, output_file)

# Check if input file exists
if (!file.exists(input_file)) {
  stop("ERROR: Input file not found: ", input_file)
}

cat("Input file:", input_file, "\n")
cat("Output file:", output_path, "\n\n")

# Check for LaTeX engines (preferring Unicode-capable ones)
xelatex_available <- Sys.which("xelatex") != ""
lualatex_available <- Sys.which("lualatex") != ""
pdflatex_available <- Sys.which("pdflatex") != ""

if (!xelatex_available && !lualatex_available && !pdflatex_available) {
  cat("WARNING: No LaTeX engine found. Installing TinyTeX...\n")
  if (!requireNamespace("tinytex", quietly = TRUE)) {
    install.packages("tinytex", repos = "https://cloud.r-project.org/")
  }
  library(tinytex)
  tinytex::install_tinytex()
  xelatex_available <- TRUE
}

# Determine LaTeX engine (prefer Unicode-capable engines for French + emojis)
latex_engine <- if (xelatex_available) {
  "xelatex"
} else if (lualatex_available) {
  "lualatex"
} else {
  "pdflatex"
}
cat("Using LaTeX engine:", latex_engine, "\n")

# Warn if using pdflatex (doesn't support Unicode emojis well)
if (latex_engine == "pdflatex") {
  cat("WARNING: pdflatex doesn't fully support Unicode emojis.\n")
  cat("Consider installing xelatex or the document may need emoji removal.\n")
}
cat("\n")

# Compile the document
cat("Compiling French manual to PDF...\n")
cat("This may take a few minutes...\n\n")

tryCatch({
  # Render the R Markdown document to PDF
  rmarkdown::render(
    input = input_file,
    output_format = pdf_document(
      toc = TRUE,
      toc_depth = 3,
      number_sections = TRUE,
      fig_caption = TRUE,
      df_print = "kable",
      latex_engine = latex_engine,
      keep_tex = FALSE
    ),
    output_file = output_file,
    output_dir = output_dir,
    quiet = FALSE,
    encoding = "UTF-8"
  )

  cat("\n===============================================\n")
  cat("SUCCESS: PDF compiled successfully!\n")
  cat("===============================================\n\n")
  cat("Output location:", output_path, "\n")

  # Check file size
  if (file.exists(output_path)) {
    file_size <- file.info(output_path)$size
    file_size_mb <- round(file_size / (1024 * 1024), 2)
    cat("File size:", file_size_mb, "MB\n")
  }

  cat("\nYou can now view the French manual PDF at:\n")
  cat(output_path, "\n")

}, error = function(e) {
  cat("\n===============================================\n")
  cat("ERROR: Failed to compile PDF\n")
  cat("===============================================\n\n")
  cat("Error message:", conditionMessage(e), "\n\n")

  cat("Troubleshooting tips:\n")
  cat("1. Ensure LaTeX is installed (XeLaTeX or pdflatex)\n")
  cat("2. Check that all required R packages are installed\n")
  cat("3. Verify the input file exists and is valid R Markdown\n")
  cat("4. Try running: tinytex::install_tinytex() if LaTeX is missing\n")

  stop(e)
})

cat("\n===============================================\n")
cat("French Manual Compilation Complete\n")
cat("===============================================\n")
