# requirements.R
# R Package Dependencies for Environmental Bowtie Risk Analysis Application
# Version: 5.2.0 (Advanced Framework Edition)

cat("📦 Installing R Package Dependencies for Bowtie App v5.2\n")
cat("======================================================\n")

# Set CRAN mirror for faster downloads
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Core Shiny and UI packages
core_packages <- c(
  "shiny",
  "bslib",
  "DT",
  "shinycssloaders",
  "colourpicker",
  "htmlwidgets",
  "shinyjs"
)

# Data handling packages
data_packages <- c(
  "readxl",
  "openxlsx",
  "dplyr",
  "jsonlite"
)

# Visualization packages
viz_packages <- c(
  "ggplot2",
  "plotly",
  "visNetwork",
  "DiagrammeR"
)

# Bayesian network packages
bayesian_packages <- c(
  "bnlearn",
  "igraph"
)

# Development and testing packages
dev_packages <- c(
  "testthat",
  "microbenchmark",
  "pryr",
  "profvis",
  "devtools"
)

# Advanced packages (BioConductor)
bioc_packages <- c(
  "gRain",
  "Rgraphviz",
  "graph"
)

# Install function with error handling
install_packages_safely <- function(packages, source = "CRAN") {
  for (pkg in packages) {
    cat("Installing", pkg, "from", source, "...\n")

    tryCatch({
      if (source == "BioConductor") {
        if (!requireNamespace("BiocManager", quietly = TRUE)) {
          install.packages("BiocManager")
        }
        BiocManager::install(pkg, dependencies = TRUE, quiet = TRUE)
      } else {
        install.packages(pkg, dependencies = TRUE, quiet = TRUE)
      }

      # Verify installation
      if (requireNamespace(pkg, quietly = TRUE)) {
        cat("✅", pkg, "installed successfully\n")
      } else {
        cat("❌", pkg, "installation failed\n")
      }
    }, error = function(e) {
      cat("⚠️ Error installing", pkg, ":", e$message, "\n")
    })
  }
}

# Install packages in order
cat("\n1️⃣ Installing Core Shiny Packages...\n")
install_packages_safely(core_packages)

cat("\n2️⃣ Installing Data Handling Packages...\n")
install_packages_safely(data_packages)

cat("\n3️⃣ Installing Visualization Packages...\n")
install_packages_safely(viz_packages)

cat("\n4️⃣ Installing Bayesian Network Packages...\n")
install_packages_safely(bayesian_packages)

cat("\n5️⃣ Installing Development Packages...\n")
install_packages_safely(dev_packages)

cat("\n6️⃣ Installing BioConductor Packages...\n")
install_packages_safely(bioc_packages, "BioConductor")

# Verify all installations
cat("\n🔍 Verifying Package Installations...\n")
cat("=====================================\n")

all_packages <- c(core_packages, data_packages, viz_packages,
                 bayesian_packages, dev_packages, bioc_packages)

installed_count <- 0
failed_packages <- character()

for (pkg in all_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    installed_count <- installed_count + 1
    cat("✅", pkg, "\n")
  } else {
    failed_packages <- c(failed_packages, pkg)
    cat("❌", pkg, "\n")
  }
}

# Summary
cat("\n📊 Installation Summary\n")
cat("=======================\n")
cat("Total packages:", length(all_packages), "\n")
cat("Successfully installed:", installed_count, "\n")
cat("Failed installations:", length(failed_packages), "\n")

if (length(failed_packages) > 0) {
  cat("\n⚠️ Failed packages:\n")
  for (pkg in failed_packages) {
    cat("  -", pkg, "\n")
  }
  cat("\nNote: Some packages may be optional or require system dependencies\n")
} else {
  cat("\n🎉 All packages installed successfully!\n")
}

cat("\n✅ Package installation completed\n")