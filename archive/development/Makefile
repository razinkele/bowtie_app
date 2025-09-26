# Makefile for Environmental Bowtie Risk Analysis Application
# Provides common development tasks

# Default target
.PHONY: help
help:
	@echo "Environmental Bowtie Risk Analysis App"
	@echo "Available commands:"
	@echo "  make test            - Run all tests"
	@echo "  make test-quick      - Run quick tests only"
	@echo "  make test-bowtie-generator - Test vocabulary bowtie generator"
	@echo "  make test-integration      - Run integration tests"
	@echo "  make app             - Run the Shiny application"  
	@echo "  make install         - Install required R packages"
	@echo "  make clean           - Clean cache and temporary files"
	@echo "  make check           - Check code syntax and dependencies"

# Run all tests
.PHONY: test
test:
	@echo "Running all tests..."
	Rscript tests/test_runner.R

# Run the application
.PHONY: app  
app:
	@echo "Starting Shiny application..."
	Rscript -e "source('app.r')"

# Install required packages
.PHONY: install
install:
	@echo "Installing required R packages..."
	Rscript -e "pkgs <- c('shiny', 'bslib', 'DT', 'readxl', 'openxlsx', 'ggplot2', 'plotly', 'dplyr', 'visNetwork', 'shinycssloaders', 'colourpicker', 'htmlwidgets', 'shinyjs', 'testthat'); install.packages(pkgs[!pkgs %in% installed.packages()])"
	Rscript -e "if (!require('BiocManager')) install.packages('BiocManager'); BiocManager::install(c('Rgraphviz'))"
	Rscript -e "pkgs <- c('bnlearn', 'gRain', 'igraph', 'DiagrammeR'); install.packages(pkgs[!pkgs %in% installed.packages()])"

# Clean cache and temporary files
.PHONY: clean
clean:
	@echo "Cleaning cache and temporary files..."
	Rscript -e "if (file.exists('.cache')) { rm(list = ls(envir = .cache), envir = .cache) }"
	find . -name "*.RData" -delete 2>/dev/null || true
	find . -name "*.Rhistory" -delete 2>/dev/null || true

# Check code syntax and dependencies
.PHONY: check
check:
	@echo "Checking R code syntax..."
	Rscript -e "parse('app.r')"
	Rscript -e "parse('utils.r')"  
	Rscript -e "parse('vocabulary.r')"
	Rscript -e "parse('bowtie_bayesian_network.r')"
	Rscript -e "if (file.exists('vocabulary_bowtie_generator.r')) parse('vocabulary_bowtie_generator.r')"
	@echo "All R files parsed successfully!"

# Quick test (run only fast tests)
.PHONY: test-quick
test-quick:
	@echo "Running quick tests (utilities and vocabulary only)..."
	Rscript -e "library(testthat); test_file('tests/testthat/test-utils.R'); test_file('tests/testthat/test-vocabulary.R')"

# Test vocabulary bowtie generator specifically
.PHONY: test-bowtie-generator
test-bowtie-generator:
	@echo "Running vocabulary bowtie generator tests..."
	Rscript -e "library(testthat); test_file('tests/testthat/test-vocabulary-bowtie-generator.R')"

# Run integration tests
.PHONY: test-integration
test-integration:
	@echo "Running integration workflow tests..."
	Rscript -e "library(testthat); test_file('tests/testthat/test-integration-workflow.R')"

# Full test suite including new components
.PHONY: test-all
test-all: test
	@echo "All tests completed including vocabulary bowtie generation"

# Development setup
.PHONY: setup
setup: install
	@echo "Setting up development environment..."
	@echo "✓ Packages installed"
	@echo "✓ Test framework ready"
	@echo "✓ Vocabulary bowtie generator available"
	@echo "Run 'make test' to verify installation"

# Generate vocabulary-based bowtie network
.PHONY: generate-bowtie
generate-bowtie:
	@echo "Generating vocabulary-based bowtie network..."
	Rscript -e "source('vocabulary_bowtie_generator.r'); result <- example_usage(); cat('Generated file:', result$$file, '\n')"