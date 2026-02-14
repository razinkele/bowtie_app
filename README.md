# Environmental Bowtie Risk Analysis Application

A comprehensive R Shiny web application for environmental risk assessment using bow-tie diagrams enhanced with Bayesian network analysis and AI-powered vocabulary linking.

> **Archive notice:** The original R Shiny application (`app.R`) has been archived and moved to `archive/archived_app_R_20260101.R`. A new Python Shiny app is available at `shiny_copernicus_app.py` — see `README_shiny_copernicus.md` for usage and authentication instructions.

![Version](https://img.shields.io/badge/version-5.3.0-blue.svg)
![R](https://img.shields.io/badge/R-%3E%3D4.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Documentation](#documentation)
- [Deployment](#deployment)
- [Quick Start](#quick-start)
- [Environmental Scenarios](#environmental-scenarios)
- [Data File Formats](#data-file-formats)
- [Application Architecture](#application-architecture)
- [Vocabulary System](#vocabulary-system)
- [Bayesian Network Analysis](#bayesian-network-analysis)
- [Vocabulary Bow-tie Generator](#vocabulary-bow-tie-generator)
- [Testing Framework](#testing-framework)
- [Development](#development)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## What's New in Version 5.3.0 (Production-Ready Edition)

### 📚 Comprehensive Documentation Package
- **Complete PDF Manual**: 118 KB comprehensive user and technical documentation
- **Automated Compilation**: New `compile_manual.R` script for PDF generation
- **Complete Coverage**: Installation, UI overview, all 12 scenarios, workflows, troubleshooting
- **Professional Format**: Optimized for distribution and user reference

### 🎨 UI/UX Enhancements
- **Vocabulary Statistics Card**: Real-time display of 53 activities, 36 pressures, 74 controls, 26 consequences
- **Vertically Aligned Selectors**: Improved environmental scenario selector layout in Data Input
- **Enhanced Information Density**: Optimized 3-column layout for better user experience
- **Better Visual Hierarchy**: Separated labels and improved visual flow

### 🐛 Critical Bug Fixes
- **Option 2b Scenario Generation Fixed**: Replaced non-existent function with correct `generateScenarioSpecificBowtie()`
- **All 12 Scenarios Working**: Both Option 2 and Option 2b now fully functional
- **Linux Case-Sensitivity Resolved**: Fixed utils.r filename references in deployment scripts
- **Enhanced Error Handling**: Added tryCatch blocks and graceful fallback mechanisms

### 🔧 Configuration & Deployment
- **Enhanced Directory Validation**: REQUIRED_DIRS and OPTIONAL_DIRS configuration in config.R
- **Windows PowerShell Support**: New `check_deployment_readiness.ps1` for Windows users
- **Improved Deployment Scripts**: config.R now properly copied, XLSX files validated
- **Linux Compatibility**: All case-sensitivity issues resolved for production deployment

### 📁 Codebase Cleanup
- **Professional Structure**: Removed 11 backup/temporary files (9 backups, 1 machine-specific, 1 temp)
- **Production-Ready Organization**: Clean directory structure with enhanced .gitignore
- **Version Standardization**: All configuration files and documentation updated to v5.3.0

## What's New in Version 5.2 (Advanced Framework Edition)

### 🚀 Advanced Development Framework
- **Hot Reload System**: Automatic file change detection and application restart
- **Performance Profiling**: Real-time memory monitoring and performance metrics
- **CI/CD Pipeline**: GitHub Actions integration with automated testing and deployment
- **Docker Containerization**: Multi-stage builds for development, testing, and production
- **Consistency Validation**: Automated checking of architectural improvements
- **Security Scanning**: Automated vulnerability detection and code quality analysis

### 🎯 Advanced Testing Framework
- **Consistency Fixes Testing**: Validates architectural improvements and circular dependency fixes
- **Performance Regression Testing**: Automated performance monitoring and baseline comparison
- **Icon Standardization Testing**: Ensures consistent FontAwesome icon usage across interfaces
- **Multi-version R Testing**: Automated testing across R 4.3.2 and 4.4.3
- **Parallel Test Execution**: Faster test runs with concurrent testing capabilities
- **Memory Usage Monitoring**: Prevents memory leaks in long-running processes

### 🔧 Modern CI/CD Pipeline
- **GitHub Actions Integration**: Complete automation for testing, security, and deployment
- **Docker Containerization**: Multi-stage builds for all environments
- **Container Orchestration**: Docker Compose with monitoring and load balancing
- **Automated Deployment**: Streamlined deployment package creation
- **Security Analysis**: Vulnerability scanning and code quality checks
- **Performance Monitoring**: Real-time performance tracking and regression detection

### 🎨 Consistency Improvements
- **Resolved Circular Dependencies**: Eliminated problematic import loops in guided workflow
- **Standardized Icon Usage**: Consistent FontAwesome icon implementation across all components
- **Updated Documentation**: Accurate architectural documentation matching actual file structure
- **Enhanced Module Loading**: Robust dependency management with error handling

## Overview

This application provides a comprehensive platform for environmental risk assessment using the bow-tie methodology, enhanced with advanced analytical capabilities including:

- **Interactive Bow-tie Diagrams**: Visual representation of environmental risks from activities through consequences
- **Bayesian Network Integration**: Probabilistic modeling for advanced risk analysis
- **AI-Powered Vocabulary Linking**: Intelligent connections between environmental components
- **Hierarchical Data Management**: Structured vocabulary for activities, pressures, consequences, and controls
- **Risk Assessment Tools**: Quantitative likelihood and severity analysis
- **Data Import/Export**: Excel-based data management with structured formats

### Target Users

- Environmental risk assessors
- Environmental consultants
- Regulatory agencies
- Research institutions
- Environmental managers

## Features

### Core Functionality

- **🎯 Interactive Bow-tie Creation**: Drag-and-drop interface for creating environmental risk bow-ties
- **🧭 Guided Workflow System**: 8-step wizard for systematic bowtie creation with vocabulary integration
- **📊 Risk Quantification**: Likelihood × Severity risk calculations with visual risk matrices
- **🔗 Network Visualization**: Interactive network diagrams with customizable styling
- **📈 Bayesian Analysis**: Advanced probabilistic modeling and inference
- **🤖 AI Vocabulary Linking**: Semantic similarity and causal relationship detection
- **📋 Structured Data Management**: Hierarchical vocabulary with Excel import/export
- **🎨 Customizable Visualizations**: Multiple color schemes, node sizes, and display options
- **💾 Data Persistence**: Save and load projects with complete data integrity

### Advanced Features

- **Multiple Risk Scenarios**: Compare different environmental management approaches
- **Sensitivity Analysis**: Understand parameter impacts on risk outcomes
- **Pathway Analysis**: Identify critical risk pathways and intervention points
- **Reporting**: Generate comprehensive risk assessment reports
- **Integration**: Compatible with existing environmental management systems

### Risk Matrix Functionality

The application includes an enhanced interactive risk matrix that provides visual risk assessment capabilities:

#### Features

- **📊 Interactive Risk Visualization**: Interactive scatter plot showing likelihood vs severity for all risk scenarios
- **🎨 Color-Coded Risk Levels**:
  - 🟢 **Low Risk** (Risk Score ≤ 6): Green indicators for minimal environmental concern
  - 🟡 **Medium Risk** (Risk Score 7-15): Yellow indicators for moderate environmental concern
  - 🔴 **High Risk** (Risk Score ≥ 16): Red indicators for significant environmental concern
- **🔍 Interactive Tooltips**: Hover over points to see detailed risk information including:
  - Central Problem identification
  - Associated Activity and Pressure
  - Protective Mitigation measures
  - Consequence description
  - Calculated Risk Level and Score
  - Bayesian Network integration status

#### Risk Calculation

The risk matrix uses a standard likelihood × severity calculation:

- **Likelihood Scale**: 1-5 (1=Very Low, 2=Low, 3=Medium, 4=High, 5=Very High)
- **Severity Scale**: 1-5 (1=Negligible, 2=Minor, 3=Moderate, 4=Major, 5=Catastrophic)
- **Risk Score**: Likelihood × Severity (Range: 1-25)
- **Risk Level Categories**:
  - Low: Risk Score ≤ 6
  - Medium: Risk Score 7-15
  - High: Risk Score ≥ 16

#### Error Handling

The risk matrix includes comprehensive error handling:

- **Data Validation**: Automatically validates Risk_Level column format and converts numeric to categorical as needed
- **Missing Data**: Creates default risk calculations when likelihood/severity columns are missing
- **Fallback Visualization**: Displays informative error messages if visualization fails
- **Column Mapping**: Handles both legacy (Likelihood/Severity) and new (Overall_Likelihood/Overall_Severity) column names

#### Technical Implementation

- **Location**: `app.r` lines 1833-1914 (`output$riskMatrix`)
- **Dependencies**: ggplot2, plotly for interactive visualization
- **Color Mapping**: Defined in `utils.r` as `RISK_COLORS`
- **Data Processing**: Includes automatic Risk_Level calculation and validation

## Installation

### Prerequisites

- R (>= 4.0.0)
- RStudio (recommended)
- Internet connection for package installation

### Required R Packages

The application automatically installs required packages, but you can install them manually:

```r
# Core Shiny packages
install.packages(c("shiny", "bslib", "DT", "shinycssloaders", 
                   "shinyjs", "colourpicker", "htmlwidgets"))

# Data manipulation
install.packages(c("dplyr", "tidyr", "readxl", "openxlsx"))

# Visualization
install.packages(c("ggplot2", "plotly", "visNetwork"))

# Text analysis and AI linking
install.packages(c("tm", "stringdist", "tidytext", "widyr", 
                   "textrank", "igraph"))

# Bayesian networks
install.packages(c("bnlearn", "gRain", "DiagrammeR"))

# BioConductor packages (for advanced Bayesian analysis)
if (!require("BiocManager")) install.packages("BiocManager")
BiocManager::install("Rgraphviz")

# Testing framework
install.packages("testthat")
```

### Installation Steps

1. **Clone or download** the repository
2. **Navigate** to the application directory
3. **Install dependencies** using the Makefile:
   ```bash
   make install
   ```
4. **Run the application**:
   ```bash
   make app
   # or
   Rscript -e "source('app.R')"
   ```

### Pre-commit Hooks (Recommended)

**IMPORTANT**: Install pre-commit hooks to ensure code quality before commits:

```r
# Install hooks (one-time setup)
Rscript install_hooks.R
```

The pre-commit hooks will automatically:
- ✅ Run lintr on staged R files
- ✅ Check for syntax errors
- ✅ Run fast tests (if available)
- ✅ Detect common issues (debug statements, large files)

**Benefits**:
- ⚡ Instant local feedback (vs minutes in CI)
- 🛡️ Prevents bad commits before push
- 📏 Consistent code style across contributors

For more details, see [CONTRIBUTING.md](CONTRIBUTING.md).

### CodeRabbit AI Code Review

**Automated AI-powered code reviews** on all pull requests:

- 🤖 **Automatic Reviews**: CodeRabbit analyzes all PRs for quality, security, and performance
- 💡 **Inline Suggestions**: Get specific, actionable feedback on code changes
- 🔒 **Security Scanning**: Identifies potential vulnerabilities
- ⚡ **Performance Analysis**: Detects bottlenecks and optimization opportunities
- 🧪 **Test Coverage**: Ensures adequate testing of changes

**Configuration**: `.coderabbit.yaml`
**Documentation**: [.github/CODERABBIT.md](.github/CODERABBIT.md)

**Interact with CodeRabbit** on PRs:
```
@coderabbitai review    # Request a review
@coderabbitai apply     # Apply suggested fixes
@coderabbitai explain   # Get clarification
```

## Documentation

### Comprehensive PDF Manual (New in v5.3.0)

A complete **118 KB PDF manual** is now available covering all aspects of the application:

- **File**: `docs/Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.pdf`
- **Content**:
  - Executive summary and system requirements
  - Installation and setup guide
  - Complete UI overview (all 8 tabs)
  - All 12 environmental scenarios documented
  - Step-by-step guided workflow instructions (8 steps)
  - Bayesian network analysis guide
  - Risk matrix and visualization tutorials
  - Advanced features and customization
  - Troubleshooting and support
  - Technical appendices and references

### Compile Manual from Source

```r
# Automated PDF generation from R Markdown source
Rscript compile_manual.R

# Manual will be generated at: docs/Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.pdf
# Source file: docs/USER_MANUAL.Rmd
```

The script automatically installs required packages (rmarkdown, knitr, TinyTeX) if needed.

## Deployment

For production deployment on shiny-server or Docker, see the **[deployment](./deployment/)** directory:

- **Shiny Server**: Use `deployment/deploy_shiny_server.sh` for automated deployment
- **Docker**: Use `deployment/docker-compose.yml` for containerized deployment
- **Quick Start**: See `deployment/README.md` for deployment options
- **Full Guide**: See `docs/DEPLOYMENT_GUIDE.md` for comprehensive instructions
- **PDF Manual**: Complete user and technical documentation in `docs/Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.pdf`

## Quick Start

### Basic Usage

1. **Start the application**:
   ```r
   source("app.R")
   ```

2. **Load or generate data**:
   - Upload Excel files with bow-tie data
   - Use sample data generation
   - Create vocabulary-based networks

3. **Create bow-tie diagrams**:
   - Select central environmental problem
   - Customize visualization options
   - Analyze risk levels and pathways

4. **Export results**:
   - Download bow-tie data as Excel
   - Export visualizations as images
   - Generate analysis reports

### Command Line Usage

```bash
# Run all tests
make test

# Generate vocabulary-based bow-tie network
make generate-bowtie

# Quick development setup
make setup

# Clean temporary files
make clean
```

## Environmental Scenarios

The application includes **12 comprehensive environmental scenarios** for risk assessment:

### General Environmental Scenarios (5)

1. **🌊 Marine pollution from shipping & coastal activities** - Comprehensive maritime pollution assessment
2. **🏭 Industrial contamination through chemical discharge** - Chemical pollutant risk analysis
3. **🚢 Oil spills from maritime transportation** - Petroleum-based contamination scenarios
4. **🌾 Agricultural runoff causing eutrophication** - Nutrient pollution and water quality impacts
5. **🐟 Overfishing and commercial stock depletion** - Marine resource depletion and ecosystem impacts

### Martinique-Specific Scenarios (7)

6. **🏖️ Martinique: Coastal erosion and beach degradation** - Shoreline erosion and habitat loss
7. **🌊 Martinique: Sargassum seaweed influx impacts** - Mass seaweed accumulation effects
8. **🪸 Martinique: Coral reef degradation and bleaching** - Coral ecosystem decline
9. **💧 Martinique: Watershed pollution from agriculture** - Agricultural runoff and water quality
10. **🌿 Martinique: Mangrove forest degradation** - Mangrove ecosystem threats
11. **🌀 Martinique: Hurricane and tropical storm impacts** - Extreme weather event risks
12. **🚤 Martinique: Marine tourism environmental pressures** - Tourism-related environmental impacts

### Data Generation Options

- **Option 1**: Upload custom Excel file with your own bow-tie data
- **Option 2**: Generate focused bow-tie from scenarios (~20-30 rows, streamlined analysis)
- **Option 2b**: Generate comprehensive bow-tie with multiple controls (~40-90 rows, detailed analysis)

All scenarios utilize the application's comprehensive vocabulary database of 189 elements (53 activities, 36 pressures, 74 controls, 26 consequences).

## Data File Formats

### Main Bow-tie Data Format

The primary data format is Excel (.xlsx) with the following structure:

#### Required Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `Activity` | Text | Human activity causing environmental pressure | "Industrial manufacturing" |
| `Pressure` | Text | Environmental pressure/stressor | "Chemical discharge" |
| `Problem` | Text | Central environmental problem | "Water pollution" |
| `Consequence` | Text | Environmental consequence/impact | "Ecosystem damage" |
| `Preventive_Control` | Text | Measures to prevent the activity/pressure | "Emission controls" |
| `Protective_Mitigation` | Text | Measures to mitigate consequences | "Emergency response" |
| `Threat_Likelihood` | Integer | Likelihood rating (1-5 scale) | 3 |
| `Consequence_Severity` | Integer | Severity rating (1-5 scale) | 4 |

#### Optional Columns

| Column | Type | Description |
|--------|------|-------------|
| `Risk_Level` | Integer | Calculated risk (Likelihood × Severity) |
| `Risk_Rating` | Text | Risk category (Low/Medium/High/Very High) |
| `Entry_ID` | Text | Unique identifier for each row |
| `Notes` | Text | Additional comments or details |

#### Example Data

```csv
Activity,Pressure,Problem,Consequence,Preventive_Control,Protective_Mitigation,Threat_Likelihood,Consequence_Severity
"Industrial manufacturing","Chemical discharge","Water pollution","Ecosystem damage","Treatment systems","Environmental monitoring",4,4
"Agricultural operations","Nutrient runoff","Water pollution","Algal blooms","Buffer strips","Water quality testing",3,3
"Urban development","Habitat fragmentation","Biodiversity loss","Species decline","Green corridors","Wildlife monitoring",3,4
```

### Vocabulary Data Format

The application uses hierarchical vocabulary stored in separate Excel files:

#### CAUSES.xlsx (Activities)
| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `Hierarchy` | Text | Hierarchical level (1, 1.1, 1.1.1) | "1.2.3" |
| `ID#` | Text | Unique identifier | "AGR.CROP.FERT" |
| `name` | Text | Activity description | "Fertilizer application" |

#### CONSEQUENCES.xlsx
| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `Hierarchy` | Text | Hierarchical level | "2.1" |
| `ID#` | Text | Unique identifier | "ECO.HAB.LOSS" |
| `name` | Text | Consequence description | "Habitat loss" |

#### CONTROLS.xlsx
| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `Hierarchy` | Text | Hierarchical level | "1.3.2" |
| `ID#` | Text | Unique identifier | "TECH.TREAT.ADV" |
| `name` | Text | Control measure description | "Advanced treatment systems" |

### Hierarchical Structure

The vocabulary system supports multi-level hierarchies:

```
1. Agriculture
  1.1. Crop Production
    1.1.1. Fertilizer Application
    1.1.2. Pesticide Use
  1.2. Livestock
    1.2.1. Cattle Farming
    1.2.2. Poultry Operations
2. Industry
  2.1. Manufacturing
    2.1.1. Chemical Production
```

## Application Architecture

### Core Components

The application follows a **modular architecture** with separate files for different concerns:

#### `app.R` - Application Launcher
- **Lightweight Entry Point**: Main application launcher
- **Module Loading**: Sources global.R, ui.R, and server.R
- **Startup Configuration**: Application initialization and messages
- **Shiny Entry Point**: `shinyApp(ui = ui, server = server)` (line 27)

#### `global.R` - Global Configuration
- **Package Management**: Automatic installation and loading of dependencies
- **Vocabulary Initialization**: Loads environmental vocabulary data (189 elements)
- **Utility Loading**: Sources all utility and workflow modules
- **BiocManager Support**: Enhanced package loading for Bayesian network packages

#### `ui.R` - User Interface Definition
- **Complete UI Definition**: All Shiny UI components and layouts
- **Bootstrap 5 Themes**: Zephyr theme with 21 available themes
- **Tabbed Interface**: 8 main tabs including Guided Workflow
- **FontAwesome Icons**: Standardized icon usage across all components
- **Environmental Scenario Selectors**: Integrated scenario selection widgets

#### `server.R` - Server Logic
- **Complete Server Function**: All reactive logic and event handlers
- **Data Processing**: Bow-tie generation, Bayesian network analysis
- **Visualization**: Interactive diagrams, risk matrices, network graphs
- **Session Management**: Multi-user support with session isolation
- **Export Functionality**: Excel, CSV, RDS data export capabilities

#### `utils.r` - Utility Functions
- **Data Generation**: `generateEnvironmentalDataFixed()` - Creates sample environmental data
- **Validation**: `validateDataColumns()` - Ensures data integrity
- **Risk Calculations**: `calculateRiskLevel()` - Computes risk scores
- **Visualization**: `createBowtieNodesFixed()`, `createBowtieEdgesFixed()` - Network components
- **Data Processing**: Various formatting and manipulation utilities

#### `vocabulary.r` - Vocabulary Management
- **Data Loading**: `load_vocabulary()` - Reads hierarchical vocabulary from Excel
- **Hierarchy Processing**: `create_hierarchy_list()` - Builds tree structures
- **Search Functions**: `search_vocabulary()` - Find vocabulary items
- **Tree Operations**: `get_children()`, `get_item_path()` - Navigate hierarchies

#### `vocabulary-ai-linker.r` - AI-Powered Linking
- **Semantic Analysis**: `calculate_semantic_similarity()` - Text similarity computation
- **Causal Detection**: `detect_causal_relationships()` - Environmental causal chains
- **Link Generation**: `find_vocabulary_links()` - Intelligent connections
- **Pathway Analysis**: `find_causal_paths()` - Risk pathway identification

#### `bowtie_bayesian_network.r` - Bayesian Networks
- **Network Creation**: `create_bayesian_structure()` - Convert bow-ties to Bayesian networks
- **Probability Tables**: `create_cpts()` - Conditional probability generation
- **Inference**: `perform_inference()` - Probabilistic reasoning
- **Risk Propagation**: `calculate_risk_propagation()` - Risk scenario analysis

#### `guided_workflow.r` - Guided Workflow System
- **8-Step Wizard**: Interactive step-by-step bowtie creation process
- **Vocabulary Integration**: Uses real environmental vocabulary data (189+ items)
- **Server Logic**: Complete reactive handlers for all user interactions
- **State Management**: Maintains workflow progress and user selections


#### `vocabulary_bowtie_generator.R` - Network Generator
- **Automated Generation**: `generate_vocabulary_bowtie()` - Create bow-ties from vocabulary
- **AI Integration**: Uses vocabulary linking for intelligent connections
- **Excel Export**: `export_bowtie_to_excel()` - Compatible output format
- **Batch Processing**: Support for multiple environmental problems

### Data Flow

```
Excel Files → Vocabulary System → AI Linking → Bow-tie Generation → Bayesian Analysis → Visualization
     ↓              ↓               ↓              ↓                    ↓              ↓
  CAUSES.xlsx   vocabulary.r   ai-linker.r   generator.r      bayesian.r      app.r
CONSEQUENCES.xlsx
 CONTROLS.xlsx
```

## Guided Workflow System

### Overview

The guided workflow system provides a step-by-step approach to creating environmental bowtie diagrams with vocabulary integration and real-time feedback.

### 8-Step Process

1. **📋 Project Setup**: Basic project information and configuration
2. **🎯 Central Problem Definition**: Define the core environmental problem
3. **⚠️ Activities & Pressures**: Select from 53 activities and 36 pressures with search functionality
4. **🛡️ Preventive Controls**: Choose from 74 mitigation measures with cost assessment
5. **💥 Consequences**: Identify potential impacts from 26 consequence categories
6. **🚨 Protective Controls**: Add protective measures and recovery controls
7. **✅ Review & Validate**: Validate connections and review complete bowtie structure
8. **🎉 Finalize & Export**: Export completed analysis to Excel format

### Key Features (Latest Version)

- **Real Vocabulary Integration**: All search widgets populated with actual Excel vocabulary data
- **Empty Search Start**: SelectizeInput widgets start empty for immediate typing
- **Full Server Functionality**: All "Add" buttons work with visual table feedback
- **Duplicate Prevention**: Prevents adding the same item multiple times
- **Activity-Pressure Linkage**: Dynamic tables showing potential connections
- **Progress Tracking**: Visual indicators throughout the workflow
- **State Persistence**: Maintains selections across workflow steps

### Using the Guided Workflow

```r
# Access guided workflow from main application
# 1. Launch the application: source("app.R")
# 2. Navigate to "Guided Workflow" tab
# 3. Follow the 8-step process
# 4. Export completed bowtie to Excel
```

## Vocabulary System

### Overview

The vocabulary system provides structured, hierarchical categorization of environmental components:

- **Activities**: Human activities that create environmental pressures (53 items)
- **Pressures**: Environmental stressors resulting from activities (36 items)
- **Consequences**: Environmental impacts from pressures (26 items)
- **Controls**: Mitigation measures and protective actions (74 items)

### Loading Vocabulary Data

```r
# Load from Excel files
vocabulary_data <- load_vocabulary(
  causes_file = "CAUSES.xlsx",
  consequences_file = "CONSEQUENCES.xlsx", 
  controls_file = "CONTROLS.xlsx"
)

# Access specific vocabulary types
activities <- vocabulary_data$activities
pressures <- vocabulary_data$pressures
consequences <- vocabulary_data$consequences
controls <- vocabulary_data$controls
```

### Working with Hierarchies

```r
# Get top-level items
top_level <- get_items_by_level(vocabulary_data$activities, 1)

# Get children of a specific item
children <- get_children(vocabulary_data$activities, "AGR")

# Get full path to an item
path <- get_item_path(vocabulary_data$activities, "AGR.CROP.FERT")
# Returns: c("Agriculture", "Crop Production", "Fertilizer Application")

# Search vocabulary
results <- search_vocabulary(vocabulary_data$activities, "fertilizer", "name")
```

### Creating Custom Vocabulary

```r
# Create custom vocabulary structure
custom_vocab <- data.frame(
  hierarchy = c("1", "1.1", "1.2", "2"),
  id = c("MAIN", "SUB1", "SUB2", "MAIN2"),
  name = c("Main Category", "Subcategory 1", "Subcategory 2", "Second Main"),
  stringsAsFactors = FALSE
)
```

## Bayesian Network Analysis

### Overview

The Bayesian network functionality converts bow-tie diagrams into probabilistic models, enabling advanced risk analysis and inference.

### Creating Bayesian Networks

```r
# Load bow-tie data
bowtie_data <- read.xlsx("environmental_data.xlsx")

# Create Bayesian network structure
bn_structure <- create_bayesian_structure(
  bowtie_data, 
  central_problem = "Water Pollution"
)

# Create conditional probability tables
cpts <- create_cpts(bn_structure, use_data = TRUE)

# Fit Bayesian network
fitted_bn <- create_bnlearn_network(bn_structure)
```

### Performing Inference

```r
# Set evidence and perform inference
evidence <- list("Activity_Level" = "High", "Control_Effectiveness" = "Low")
results <- perform_inference(fitted_bn, evidence)

# Calculate risk propagation
scenario <- list("Industrial_Activity" = "High")
risk_propagation <- calculate_risk_propagation(fitted_bn, scenario)

# Find critical pathways
critical_paths <- find_critical_paths(fitted_bn, target_node = "Consequence_Level")
```

### Visualization

```r
# Visualize Bayesian network
network_viz <- visualize_bayesian_network(bn_structure)

# Highlight critical pathways
network_viz_highlighted <- visualize_bayesian_network(
  bn_structure, 
  highlight_path = critical_paths[[1]]
)
```

## Vocabulary Bow-tie Generator

### Overview

The vocabulary bow-tie generator creates environmental risk networks automatically using the vocabulary system and AI-powered linking.

### Basic Usage

```r
# Generate bow-tie network with default settings
result <- generate_vocabulary_bowtie()

# Custom generation
result <- generate_vocabulary_bowtie(
  central_problems = c("Water Pollution", "Climate Change", "Biodiversity Loss"),
  output_file = "my_environmental_assessment.xlsx",
  similarity_threshold = 0.3,
  max_connections_per_item = 4,
  use_ai_linking = TRUE
)
```

### Advanced Configuration

```r
# Comprehensive assessment
comprehensive_result <- generate_vocabulary_bowtie(
  central_problems = c(
    "Water Pollution", "Air Quality Degradation", "Soil Contamination",
    "Biodiversity Loss", "Climate Change", "Noise Pollution"
  ),
  output_file = "comprehensive_assessment.xlsx",
  similarity_threshold = 0.25,  # Lower threshold = more connections
  max_connections_per_item = 6,  # More connections per vocabulary item
  use_ai_linking = TRUE
)
```

### Generated Output Structure

The generator creates Excel files with two sheets:

#### Bowtie_Data Sheet
Complete bow-tie entries with all required columns for the main application.

#### Summary Sheet
- Total entries generated
- Unique problems assessed
- Generation statistics
- Creation timestamp

### Integration with Main App

Generated files are directly compatible with the main application:

```r
# Generate network
result <- generate_vocabulary_bowtie(output_file = "generated_network.xlsx")

# Load in main application
# Use "Upload Excel File" feature in the web interface
# Select: generated_network.xlsx
```

## Testing Framework (Version 5.1 Enhanced)

### Overview

Comprehensive, modernized testing framework using `testthat` with enhanced capabilities, parallel execution, and advanced reporting designed for production-ready environmental risk assessment applications.

### Running Tests

```bash
# Run all tests with enhanced v5.1 reporting
Rscript tests/comprehensive_test_runner.R

# Run quick tests (core functionality)
make test-quick

# Run parallel test suite (new in v5.1)
make test-parallel

# Test specific components
make test-bowtie-generator     # Vocabulary generator tests
make test-integration          # End-to-end workflow tests
make test-themes              # Bootstrap theme validation (new in v5.1)
make test-performance         # Performance benchmarking (new in v5.1)
```

### Test Structure

- **Unit Tests**: Individual function validation
- **Integration Tests**: Complete workflow testing including guided workflow system
- **Performance Tests**: Large dataset handling
- **Quality Tests**: Data consistency validation
- **Compatibility Tests**: Excel format verification
- **Guided Workflow Tests**: Comprehensive testing of vocabulary integration and server functionality

### Writing Custom Tests

```r
# Example test
test_that("custom function works correctly", {
  # Test setup
  test_data <- create_test_data()
  
  # Function call
  result <- your_function(test_data)
  
  # Assertions
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_equal(result$risk_level, expected_values)
})
```

## Development

### Development Setup

```bash
# Initial setup
make setup

# Verify installation
make test

# Start development server
make app
```

### Code Style Guidelines

- **Functions**: Use clear, descriptive names with camelCase
- **Variables**: Use snake_case for data frame columns
- **Comments**: Document complex logic and function purposes
- **Error Handling**: Use `tryCatch()` for robust error management
- **Testing**: Write tests for all new functions

### Adding New Features

1. **Plan**: Document requirements and design
2. **Implement**: Write code following style guidelines
3. **Test**: Create comprehensive tests
4. **Document**: Update README and code comments
5. **Integrate**: Ensure compatibility with existing features

### File Organization

```
├── app.R                          # Application launcher (modular entry point)
├── global.R                       # Global configuration and package loading
├── ui.R                           # Complete UI definition (Bootstrap 5)
├── server.R                       # Complete server logic
├── config.R                       # Application configuration (v5.3.0)
├── utils.r                        # Utility functions
├── vocabulary.R                   # Vocabulary management
├── vocabulary-ai-linker.r         # AI-powered linking
├── bowtie_bayesian_network.r      # Bayesian analysis
├── vocabulary_bowtie_generator.R  # Network generator
├── guided_workflow.R              # 8-step guided workflow system
├── start_app.R                    # Network-ready launcher script
├── compile_manual.R               # PDF manual compilation (NEW v5.3.0)
├── docs/                          # Documentation
│   ├── Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.pdf  # Complete manual (NEW)
│   ├── USER_MANUAL.Rmd            # Manual source (NEW)
│   ├── DEPLOYMENT_GUIDE.md        # Deployment instructions
│   ├── CONFIGURATION_GUIDE.md     # Configuration reference
│   ├── DEVELOPMENT_GUIDE.md       # Development guide
│   ├── API_REFERENCE.md           # API documentation
│   └── release-notes/             # Version release notes
│       └── RELEASE_NOTES_v5.3.0.md  # v5.3.0 release notes (NEW)
├── deployment/                    # Deployment scripts
│   ├── deploy_shiny_server.sh     # Linux deployment script
│   ├── check_deployment_readiness.sh  # Linux validation
│   ├── check_deployment_readiness.ps1 # Windows validation (NEW)
│   └── docker-compose.yml         # Docker deployment
├── tests/                         # Testing framework
│   ├── testthat/                  # Test suites (11+ tests)
│   ├── fixtures/                  # Test data
│   ├── test_runner.R              # Quick test execution
│   └── comprehensive_test_runner.R  # Full test suite
├── www/                           # Web assets (CSS, JS, images)
├── CAUSES.xlsx                    # Activities vocabulary (53 items)
├── CONSEQUENCES.xlsx              # Consequences vocabulary (26 items)
├── CONTROLS.xlsx                  # Controls vocabulary (74 items)
├── environmental_bowtie_data_*.xlsx # Sample datasets
├── VERSION_HISTORY.md             # Complete version history (NEW)
├── CLAUDE.md                      # Development guidance (updated v5.3.0)
└── README.md                      # This file (updated v5.3.0)
```

## API Reference

### Core Functions

#### Data Generation
- `generateEnvironmentalDataFixed()` - Create sample environmental data
- `validateDataColumns(data)` - Validate data structure
- `addDefaultColumns(data)` - Add required columns

#### Risk Calculations
- `calculateRiskLevel(likelihood, severity)` - Compute risk scores
- `getRiskColor(risk_level)` - Get risk-appropriate colors
- `validateNumericInput(value, min_val, max_val)` - Input validation

#### Visualization
- `createBowtieNodesFixed(data, problem, size, show_risk, show_barriers)` - Create network nodes
- `createBowtieEdgesFixed(data, show_barriers)` - Create network edges

#### Vocabulary Management
- `load_vocabulary(causes_file, consequences_file, controls_file)` - Load vocabulary data
- `search_vocabulary(data, term, search_in)` - Search vocabulary items
- `get_children(data, parent_id)` - Get child items in hierarchy

#### Bayesian Networks
- `create_bayesian_structure(data, central_problem)` - Convert to Bayesian network
- `perform_inference(fitted_bn, evidence, query_nodes)` - Probabilistic inference
- `visualize_bayesian_network(structure, highlight_path)` - Network visualization

#### Network Generation
- `generate_vocabulary_bowtie(problems, output_file, threshold, max_connections, use_ai)` - Generate bow-tie networks

### Configuration Parameters

#### Risk Assessment
- `Threat_Likelihood`: 1-5 scale (1=Rare, 5=Almost Certain)
- `Consequence_Severity`: 1-5 scale (1=Insignificant, 5=Catastrophic)
- `Risk_Level`: Calculated as Likelihood × Severity (1-25)
- `Risk_Rating`: Categorical (Low ≤4, Medium 5-9, High 10-16, Very High >16)

#### Visualization
- `node_size`: Network node size (default: 50)
- `show_risk_levels`: Display risk colors (boolean)
- `show_barriers`: Display control measures (boolean)

#### AI Linking
- `similarity_threshold`: Minimum similarity for connections (0-1, default: 0.3)
- `max_connections`: Maximum connections per vocabulary item (default: 5)
- `methods`: Linking methods ("jaccard", "keyword", "causal")

## Examples

### Example 1: Basic Risk Assessment

```r
# Load the application
source("app.R")

# In the web interface:
# 1. Click "Generate Sample Environmental Data"
# 2. Select "Water Pollution" as central problem
# 3. Adjust visualization options
# 4. View bow-tie diagram and risk analysis
```

### Example 2: Custom Data Import

```r
# Prepare your Excel file with required columns
# Upload via web interface "Upload Excel File" button
# Select your prepared file
# Choose central environmental problem
# Analyze results
```

### Example 3: Vocabulary-Based Generation

```r
# Generate from vocabulary
result <- generate_vocabulary_bowtie(
  central_problems = c("Air Quality Issues", "Noise Pollution"),
  output_file = "air_quality_assessment.xlsx",
  use_ai_linking = TRUE
)

# Review generated file
generated_data <- read.xlsx("air_quality_assessment.xlsx")
print(summary(generated_data))
```

### Example 4: Bayesian Analysis

```r
# Load sample data
data <- generateEnvironmentalDataFixed()

# Create Bayesian network for water pollution
bn_structure <- create_bayesian_structure(data, "Water Pollution")

# Perform inference with high industrial activity
evidence <- list("Activity_Level" = "High")
results <- perform_inference(fitted_bn, evidence)

# Analyze results
print(results$posterior_probabilities)
```

### Example 5: Custom Vocabulary

```r
# Create custom vocabulary
custom_activities <- data.frame(
  hierarchy = c("1", "1.1", "1.2", "2", "2.1"),
  id = c("TRANS", "TRANS.ROAD", "TRANS.RAIL", "ENERGY", "ENERGY.FOSSIL"),
  name = c("Transportation", "Road Transport", "Rail Transport", 
           "Energy Production", "Fossil Fuel Combustion"),
  stringsAsFactors = FALSE
)

# Save to Excel
write.xlsx(custom_activities, "custom_causes.xlsx")

# Load in vocabulary system
custom_vocab <- load_vocabulary(causes_file = "custom_causes.xlsx")
```

## Troubleshooting

### Common Issues

#### Installation Problems

**Issue**: Package installation fails
```r
# Solution: Install packages individually
install.packages("shiny")
install.packages("bnlearn")
# etc.
```

**Issue**: BioConductor packages fail to install
```r
# Solution: Update BiocManager first
install.packages("BiocManager")
BiocManager::install(version = "3.18")
BiocManager::install("Rgraphviz")
```

#### Data Loading Issues

**Issue**: Excel file not loading
- Check file format is .xlsx (not .xls)
- Ensure required columns are present
- Verify column names match exactly
- Check for empty rows or invalid characters

**Issue**: Vocabulary loading fails
```r
# Check file exists
file.exists("CAUSES.xlsx")

# Validate structure
test_data <- read.xlsx("CAUSES.xlsx")
head(test_data)

# Check required columns
required_cols <- c("Hierarchy", "ID#", "name")
all(required_cols %in% names(test_data))
```

#### Application Runtime Issues

**Issue**: Shiny app won't start
```r
# Check R version
R.version.string

# Update packages
update.packages()

# Clear workspace
rm(list = ls())
source("app.R")
```

**Issue**: Bayesian network functions fail
- Ensure bnlearn and gRain packages are installed
- Check data has sufficient rows for analysis
- Verify network structure is valid

#### Performance Issues

**Issue**: Application runs slowly
- Reduce dataset size for testing
- Disable AI linking for faster processing
- Clear browser cache
- Close unnecessary browser tabs

### Error Messages

#### "Could not load vocabulary data"
- Check Excel files exist in working directory
- Verify file permissions
- Ensure files are not open in Excel

#### "Network creation failed"
- Check data has required columns
- Ensure sufficient data for network analysis
- Verify central problem exists in data

#### "Bayesian inference failed"
- Install missing Bayesian network packages
- Check evidence variables exist in network
- Ensure network is properly fitted

### Getting Help

1. **Check Documentation**: Review this README and CLAUDE.md
2. **Run Tests**: Use `make test` to verify installation
3. **Check Logs**: Review R console for error messages
4. **Sample Data**: Test with generated sample data first
5. **Issue Reporting**: Create detailed bug reports with:
   - R version and package versions
   - Operating system
   - Error messages
   - Steps to reproduce
   - Sample data (if applicable)

### Performance Optimization

- **Large Datasets**: Use data sampling for initial analysis
- **AI Linking**: Adjust similarity thresholds to balance speed/quality
- **Visualization**: Reduce node sizes and connections for complex networks
- **Memory**: Clear unused variables and restart R session periodically

## Contributing

We welcome contributions to improve the Environmental Bowtie Risk Analysis Application!

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes following coding guidelines
4. **Add** tests for new functionality
5. **Update** documentation as needed
6. **Commit** your changes (`git commit -m 'Add amazing feature'`)
7. **Push** to the branch (`git push origin feature/amazing-feature`)
8. **Open** a Pull Request

### Development Guidelines

- Follow existing code style and patterns
- Write comprehensive tests for new features
- Update documentation for user-facing changes
- Ensure backward compatibility when possible
- Test across different operating systems if possible

### Areas for Contribution

- **New Vocabulary Domains**: Additional environmental sectors
- **Visualization Enhancements**: New chart types and interactive features
- **Analysis Methods**: Additional risk assessment approaches
- **Data Connectors**: Integration with other environmental databases
- **User Interface**: Improved user experience and accessibility
- **Performance**: Optimization for large datasets
- **Testing**: Additional test coverage and edge cases

## License

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2024 Environmental Bowtie Risk Analysis Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Acknowledgments

- **HORIZON EUROPE Program** for funding and support
- **Marbefes Team** for domain expertise and requirements
- **R Community** for excellent packages and tools
- **Bow-tie Risk Assessment Methodology** practitioners and researchers

For questions, issues, or contributions, please visit the project repository or contact the development team.

**Version**: 5.3.0 (Production-Ready Edition)
**Last Updated**: November 2025
**Maintainer**: Marbefes Team & AI Assistant
**Framework Updates**: Production-ready with comprehensive deployment framework, UI/UX improvements, critical bug fixes, Linux compatibility, and complete documentation package