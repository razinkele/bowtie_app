#!/bin/bash
# Development Docker Container Startup Script
# Version: 5.1.0
# Purpose: Start Shiny application in development mode with hot reload

set -e

echo "==================================="
echo "Bowtie App Development Environment"
echo "Version: 5.1.0"
echo "==================================="

# Set development environment variables
export SHINY_LOG_LEVEL=TRACE
export R_PROFILE_USER=/srv/shiny-server/bowtie_app/.Rprofile

echo "📦 Checking R package dependencies..."
Rscript -e "
  required_pkgs <- c('shiny', 'bslib', 'DT', 'readxl', 'openxlsx',
                     'ggplot2', 'plotly', 'dplyr', 'visNetwork',
                     'shinycssloaders', 'colourpicker', 'htmlwidgets', 'shinyjs',
                     'bnlearn', 'gRain', 'igraph', 'DiagrammeR')

  missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]

  if (length(missing_pkgs) > 0) {
    cat('Installing missing packages:', paste(missing_pkgs, collapse=', '), '\n')
    install.packages(missing_pkgs, dependencies = TRUE, repos = 'https://cloud.r-project.org/')
  } else {
    cat('All required packages are installed ✓\n')
  }
"

echo "🔧 Setting up file permissions..."
chown -R shiny:shiny /srv/shiny-server/bowtie_app
chmod -R 755 /srv/shiny-server/bowtie_app

echo "📊 Validating data files..."
if [ -f "/srv/shiny-server/bowtie_app/CAUSES.xlsx" ] && \
   [ -f "/srv/shiny-server/bowtie_app/CONSEQUENCES.xlsx" ] && \
   [ -f "/srv/shiny-server/bowtie_app/CONTROLS.xlsx" ]; then
    echo "   ✓ All vocabulary data files found"
else
    echo "   ⚠️  Warning: Some vocabulary data files are missing"
fi

echo "🚀 Starting Shiny Server in development mode..."
echo "   Application will be available at: http://localhost:3838/bowtie_app"
echo "   Hot reload enabled - changes will be reflected automatically"
echo ""

# Start Shiny Server with development settings
exec shiny-server 2>&1
