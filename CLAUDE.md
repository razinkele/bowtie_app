# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

This is an R Shiny web application for Environmental Bowtie Risk Analysis with Bayesian Network integration. The application enables environmental risk assessment using bowtie diagrams enhanced with probabilistic modeling through Bayesian networks.

## Running the Application

To run the Shiny application:
```r
# In R console or RStudio
source("app.r")
# The app will launch automatically via shinyApp() call at the end of app.r
```

The application requires these R packages to be installed:
- shiny, bslib, DT, readxl, openxlsx
- ggplot2, plotly, dplyr, visNetwork
- shinycssloaders, colourpicker, htmlwidgets, shinyjs
- bnlearn, gRain, igraph, DiagrammeR (for Bayesian networks)

Missing packages are automatically installed when the application starts.

## Core Architecture

The application follows a modular Shiny architecture with four main R files:

### `app.r` (Main Application File)
- Contains the complete Shiny UI and server logic
- UI defined at line 55, server function at line 930
- Integrates all modules and handles the main application flow
- Entry point: `shinyApp(ui = ui, server = server)` at line 2356

### `utils.r` (Utility Functions)
- Environmental data generation and processing functions
- Sample data creation for bowtie analysis
- Data manipulation and formatting utilities
- Caching mechanisms for performance optimization

### `vocabulary.r` (Data Management)
- Hierarchical data reading from Excel files
- Functions for loading activities, pressures, consequences, and controls
- Data structure management for bowtie components

### `bowtie_bayesian_network.r` (Bayesian Network Integration)
- Converts bowtie diagrams to Bayesian network structures
- Probabilistic risk modeling and inference
- Network visualization and analysis functions

### `vocabulary_bowtie_generator.r` (Vocabulary-Based Network Generator)
- Generates bow-tie networks using vocabulary elements from Excel files
- AI-powered intelligent linking between vocabulary components
- Creates Excel output compatible with main application
- Supports multiple central problems and configurable parameters

## Data Structure

The application works with Excel files containing hierarchical environmental data:
- **Activities**: Human activities that create environmental pressures
- **Pressures**: Environmental stressors resulting from activities  
- **Consequences**: Environmental impacts from pressures
- **Controls**: Mitigation measures and protective controls

Key data files:
- `CAUSES.xlsx`, `CONSEQUENCES.xlsx`, `CONTROLS.xlsx`: Structured vocabulary data
- `environmental_bowtie_data_2025-06-19.xlsx`: Main dataset

## Key Features

1. **Interactive Bowtie Diagram Creation**: Visual risk assessment tool
2. **Bayesian Network Analysis**: Probabilistic modeling of environmental risks
3. **Data Import/Export**: Excel file handling for risk data
4. **Vocabulary Management**: Hierarchical categorization of environmental factors
5. **Risk Visualization**: Interactive charts and network diagrams

## Testing Framework

The application now includes a comprehensive testing framework using `testthat`:

### Running Tests
```r
# Run all tests
Rscript tests/test_runner.R

# Or run individual test suites
source("tests/testthat.R")
```

### Test Structure
- `tests/testthat/test-utils.R`: Tests utility functions, data generation, validation
- `tests/testthat/test-vocabulary.R`: Tests vocabulary management and hierarchical data processing  
- `tests/testthat/test-bayesian-network.R`: Tests Bayesian network creation and inference
- `tests/testthat/test-shiny-app.R`: Integration tests for Shiny application components
- `tests/testthat/test-vocabulary-bowtie-generator.R`: Tests vocabulary-based bow-tie generation
- `tests/testthat/test-integration-workflow.R`: End-to-end integration tests
- `tests/fixtures/test_data.R`: Mock data and test fixtures

### Test Coverage
- Unit tests for all major functions in utils.r, vocabulary.r, and bowtie_bayesian_network.r
- Integration tests for Shiny app components and reactive functionality
- Complete workflow testing for vocabulary bow-tie generation (vocabulary_bowtie_generator.r)
- Mock data fixtures for consistent testing across all components
- Error handling and edge case validation
- Performance testing for larger datasets
- Data quality and consistency validation
- Excel export/import compatibility testing

## Development Notes

- The application uses reactive programming patterns for real-time updates
- Bayesian network functionality requires BioConductor packages
- Image assets stored in `www/` directory (marbefes.png logo)
- Comprehensive test coverage with testthat framework
- No build system - direct R script execution