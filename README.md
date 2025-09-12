# Environmental Bowtie Risk Analysis Application

A comprehensive R Shiny web application for environmental risk assessment using bow-tie diagrams enhanced with Bayesian network analysis and AI-powered vocabulary linking.

![Version](https://img.shields.io/badge/version-4.4.0-blue.svg)
![R](https://img.shields.io/badge/R-%3E%3D4.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
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
   Rscript -e "source('app.r')"
   ```

## Quick Start

### Basic Usage

1. **Start the application**:
   ```r
   source("app.r")
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

#### `app.r` - Main Application
- **UI Definition**: Complete Shiny user interface (line 55)
- **Server Logic**: Application server function (line 930)
- **Integration Point**: Combines all modules and functionality
- **Entry Point**: `shinyApp(ui = ui, server = server)` (line 2356)

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

#### `vocabulary_bowtie_generator.r` - Network Generator
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

## Vocabulary System

### Overview

The vocabulary system provides structured, hierarchical categorization of environmental components:

- **Activities**: Human activities that create environmental pressures
- **Pressures**: Environmental stressors resulting from activities
- **Consequences**: Environmental impacts from pressures
- **Controls**: Mitigation measures and protective actions

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

## Testing Framework

### Overview

Comprehensive testing framework using `testthat` with full coverage of all application components.

### Running Tests

```bash
# Run all tests
make test

# Quick tests (utilities and vocabulary)
make test-quick

# Test specific components
make test-bowtie-generator     # Vocabulary generator tests
make test-integration          # End-to-end workflow tests
```

### Test Structure

- **Unit Tests**: Individual function validation
- **Integration Tests**: Complete workflow testing
- **Performance Tests**: Large dataset handling
- **Quality Tests**: Data consistency validation
- **Compatibility Tests**: Excel format verification

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
├── app.r                          # Main Shiny application
├── utils.r                        # Utility functions
├── vocabulary.r                   # Vocabulary management
├── vocabulary-ai-linker.r         # AI-powered linking
├── bowtie_bayesian_network.r      # Bayesian analysis
├── vocabulary_bowtie_generator.r   # Network generator
├── tests/                         # Testing framework
│   ├── testthat/                  # Test suites
│   ├── fixtures/                  # Test data
│   └── test_runner.R              # Test execution
├── www/                           # Web assets
├── CAUSES.xlsx                    # Activities vocabulary
├── CONSEQUENCES.xlsx              # Consequences vocabulary
├── CONTROLS.xlsx                  # Controls vocabulary
└── environmental_bowtie_data_*.xlsx # Sample data
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
source("app.r")

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
source("app.r")
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

**Version**: 4.4.0  
**Last Updated**: September 2024  
**Maintainer**: Marbefes Team & AI Assistant