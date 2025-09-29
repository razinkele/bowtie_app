# Environmental Bowtie Risk Analysis Application - API Reference

**Version**: 5.2.0 (Advanced Framework Edition)
**Last Updated**: September 2025

## Table of Contents

- [Overview](#overview)
- [Core Application Functions](#core-application-functions)
- [Vocabulary Management](#vocabulary-management)
- [Guided Workflow System](#guided-workflow-system)
- [Bayesian Network Analysis](#bayesian-network-analysis)
- [Data Generation and Processing](#data-generation-and-processing)
- [Development Framework](#development-framework)
- [Performance Monitoring](#performance-monitoring)
- [Testing Framework](#testing-framework)
- [CI/CD and Deployment](#cicd-and-deployment)

## Overview

This document provides comprehensive API reference for the Environmental Bowtie Risk Analysis Application. All functions are designed for environmental risk assessment using bow-tie methodology with Bayesian network integration.

## Core Application Functions

### Application Launcher

#### `shinyApp(ui = ui, server = server)`
**File**: `app.r:27`
**Description**: Main application entry point that launches the Shiny web application.

**Usage**:
```r
# Launch application locally
source("app.r")

# Launch with network access
Rscript start_app.R
```

### Global Configuration

#### `load_packages()`
**File**: `global.R:10-49`
**Description**: Enhanced package loading with BiocManager support and error handling.

**Returns**: None (loads packages into environment)

**Features**:
- Automatic installation of missing packages
- BiocManager integration for Bioconductor packages
- Graceful error handling and logging

#### `load_app_data()`
**File**: `global.R:68-83`
**Description**: Loads vocabulary data with graceful fallback mechanisms.

**Returns**: List containing vocabulary data structures

**Error Handling**: Returns empty data structures if loading fails

## Vocabulary Management

### Data Loading Functions

#### `load_vocabulary(causes_file, consequences_file, controls_file)`
**File**: `vocabulary.r:114-165`
**Description**: Loads hierarchical vocabulary data from Excel files.

**Parameters**:
- `causes_file` (string): Path to CAUSES.xlsx file (default: "CAUSES.xlsx")
- `consequences_file` (string): Path to CONSEQUENCES.xlsx file (default: "CONSEQUENCES.xlsx")
- `controls_file` (string): Path to CONTROLS.xlsx file (default: "CONTROLS.xlsx")

**Returns**: List with components:
- `activities`: Data frame with 53 environmental activities
- `pressures`: Data frame with 36 environmental pressures
- `consequences`: Data frame with 26 environmental consequences
- `controls`: Data frame with 74 environmental controls

**Example**:
```r
vocabulary_data <- load_vocabulary()
print(paste("Loaded", nrow(vocabulary_data$activities), "activities"))
```

#### `read_hierarchical_data(file_path, sheet_name)`
**File**: `vocabulary.r:9-65`
**Description**: Reads hierarchical data from Excel sheets with category processing.

**Parameters**:
- `file_path` (string): Path to Excel file
- `sheet_name` (string): Name of the sheet to read

**Returns**: Data frame with hierarchical structure

## Guided Workflow System

### Workflow Configuration

#### `WORKFLOW_CONFIG`
**File**: `guided_workflow.r:88-176`
**Description**: Configuration object defining all 8 workflow steps.

**Structure**:
```r
WORKFLOW_CONFIG$steps
# Step 1: Project Setup
# Step 2: Central Problem Definition
# Step 3: Threats & Causes
# Step 4: Preventive Controls
# Step 5: Consequences
# Step 6: Protective Controls
# Step 7: Review & Validate
# Step 8: Finalize & Export
```

### Workflow Functions

#### `init_workflow_state()`
**File**: `guided_workflow.r:178-191`
**Description**: Initializes a new guided workflow session.

**Returns**: List containing:
- `current_step`: Current step number (starts at 1)
- `total_steps`: Total number of steps (8)
- `completed_steps`: Vector of completed step numbers
- `project_data`: Project information and selections

#### `guided_workflow_ui()`
**File**: `guided_workflow.r:286-350`
**Description**: Generates the complete guided workflow user interface.

**Returns**: Shiny UI object for guided workflow

#### `guided_workflow_server(input, output, session)`
**File**: `guided_workflow.r:675-2850`
**Description**: Server logic for guided workflow with complete step implementations.

**Parameters**:
- `input`: Shiny input object
- `output`: Shiny output object
- `session`: Shiny session object

### Step-Specific Functions

#### `workflow_step_1_ui()` through `workflow_step_8_ui()`
**File**: `guided_workflow_steps.r`
**Description**: UI components for each workflow step with vocabulary integration.

**Features**:
- Real-time search through vocabulary items
- Server-side validation and error handling
- Progress tracking and state management
- Export integration with main application

## Bayesian Network Analysis

### Network Creation

#### `bowtie_to_bayesian(bowtie_data)`
**File**: `bowtie_bayesian_network.r:15-89`
**Description**: Converts bow-tie diagram data to Bayesian network structure.

**Parameters**:
- `bowtie_data`: Data frame with bow-tie relationships

**Returns**: Bayesian network object (bnlearn)

**Example**:
```r
sample_data <- generate_sample_environmental_data()
bn_network <- bowtie_to_bayesian(sample_data)
```

#### `perform_inference(network, evidence, query)`
**File**: `bowtie_bayesian_network.r:91-142`
**Description**: Performs probabilistic inference on Bayesian network.

**Parameters**:
- `network`: Bayesian network object
- `evidence`: List of evidence variables and values
- `query`: Variable to query

**Returns**: Probability distribution for query variable

### Risk Analysis Functions

#### `calculate_risk_propagation(network, scenario)`
**File**: `bowtie_bayesian_network.r:144-198`
**Description**: Analyzes risk propagation through the network.

**Parameters**:
- `network`: Bayesian network object
- `scenario`: Risk scenario definition

**Returns**: Risk propagation analysis results

#### `find_critical_paths(network, threshold)`
**File**: `bowtie_bayesian_network.r:200-253`
**Description**: Identifies critical risk pathways in the network.

**Parameters**:
- `network`: Bayesian network object
- `threshold`: Probability threshold for critical paths

**Returns**: List of critical pathways with probabilities

## Data Generation and Processing

### Sample Data Functions

#### `generate_sample_environmental_data(scenario_type)`
**File**: `utils.r:15-89`
**Description**: Generates sample environmental bow-tie data.

**Parameters**:
- `scenario_type` (string): Type of environmental scenario (optional)

**Returns**: Data frame with sample bow-tie relationships

#### `generate_comprehensive_environmental_data(num_scenarios, activities_per_scenario, pressures_per_scenario, consequences_per_scenario, controls_per_scenario)`
**File**: `utils.r:650-750`
**Description**: Generates comprehensive environmental data for testing.

**Parameters**:
- `num_scenarios` (numeric): Number of scenarios to generate
- `activities_per_scenario` (numeric): Activities per scenario
- `pressures_per_scenario` (numeric): Pressures per scenario
- `consequences_per_scenario` (numeric): Consequences per scenario
- `controls_per_scenario` (numeric): Controls per scenario

**Returns**: Large-scale environmental dataset

### Data Validation

#### `validate_bowtie_data(data)`
**File**: `utils.r:450-520`
**Description**: Validates bow-tie data structure and relationships.

**Parameters**:
- `data`: Data frame to validate

**Returns**: List with validation results and error messages

## Development Framework

### Development Configuration

#### `init_dev_environment()`
**File**: `dev_config.R:200-250`
**Description**: Initializes enhanced development environment with monitoring tools.

**Returns**: List containing:
- `logger`: Development logging function
- `profiler`: Performance profiling function
- `hot_reload`: File change monitoring function
- `config`: Development configuration

**Usage**:
```r
source("dev_config.R")
dev_tools <- init_dev_environment()

# Use development tools
dev_tools$logger("INFO", "Development message", "CATEGORY")
dev_tools$profiler("operation_name")
```

### Development Utilities

#### `setup_hot_reload(watch_files)`
**File**: `dev_config.R:60-85`
**Description**: Sets up automatic file change detection and reload.

**Parameters**:
- `watch_files` (vector): Files to monitor for changes

**Returns**: Function for checking file changes

#### `validate_icon_usage()`
**File**: `dev_config.R:120-155`
**Description**: Validates consistent icon usage across application files.

**Returns**: List of icon usage issues (empty if all consistent)

#### `validate_dependencies()`
**File**: `dev_config.R:160-195`
**Description**: Checks for circular dependencies and import issues.

**Returns**: Boolean indicating dependency structure validity

## Performance Monitoring

### Benchmarking Functions

#### `benchmark_consistency_fixes()`
**File**: `utils/advanced_benchmarks.R:15-85`
**Description**: Analyzes performance impact of consistency fixes.

**Returns**: List containing:
- `module_loading`: Module loading performance metrics
- `icon_performance`: Icon rendering performance comparison
- `memory_impact`: Memory usage analysis

#### `detect_performance_regression(baseline_file)`
**File**: `utils/advanced_benchmarks.R:90-155`
**Description**: Detects performance regression against established baselines.

**Parameters**:
- `baseline_file` (string): Path to baseline performance file

**Returns**: Current performance metrics with comparison to baseline

#### `run_complete_performance_suite()`
**File**: `utils/advanced_benchmarks.R:200-240`
**Description**: Executes comprehensive performance test suite.

**Returns**: Complete performance analysis results

### Real-time Monitoring

#### `start_performance_monitor(interval_seconds)`
**File**: `utils/advanced_benchmarks.R:290-315`
**Description**: Starts real-time performance monitoring.

**Parameters**:
- `interval_seconds` (numeric): Monitoring interval in seconds

**Usage**:
```r
# Start monitoring with 5-second intervals
start_performance_monitor(5)
```

## Testing Framework

### Test Execution

#### `run_test_safely(test_name, test_file, skip_on_error)`
**File**: `tests/comprehensive_test_runner.R:49-85`
**Description**: Safely executes test suites with error handling.

**Parameters**:
- `test_name` (string): Name of the test suite
- `test_file` (string): Path to test file
- `skip_on_error` (boolean): Whether to skip on errors

**Returns**: Test execution results

### Consistency Testing

#### Consistency Validation Tests
**File**: `tests/testthat/test-consistency-fixes.R`

**Functions**:
- `test_circular_dependency_resolved()`: Tests circular dependency fixes
- `test_icon_usage_standardized()`: Validates icon standardization
- `test_documentation_accuracy()`: Checks documentation accuracy
- `test_import_logic_enhanced()`: Tests import logic improvements

### Performance Testing

#### Performance Regression Tests
**File**: `tests/testthat/test-performance-regression.R`

**Functions**:
- `test_startup_performance()`: Application startup time testing
- `test_memory_usage_bounds()`: Memory usage validation
- `test_performance_regression()`: Regression detection testing
- `test_large_dataset_performance()`: Large dataset processing tests

## CI/CD and Deployment

### GitHub Actions Integration

#### CI/CD Pipeline
**File**: `.github/workflows/ci-cd-pipeline.yml`

**Jobs**:
- `consistency-checks`: Validates consistency fixes and architectural improvements
- `comprehensive-testing`: Multi-version R testing across environments
- `performance-testing`: Automated performance regression testing
- `security-analysis`: Code quality and vulnerability scanning
- `deployment-preparation`: Automated deployment package creation

### Docker Containerization

#### Container Builds
**File**: `Dockerfile`

**Build Targets**:
- `base`: Base R environment with system dependencies
- `dependencies`: R packages installation stage
- `build`: Application build and validation stage
- `production`: Optimized production container
- `development`: Development container with enhanced tools

#### Container Orchestration
**File**: `docker-compose.yml`

**Services**:
- `bowtie-app`: Production application service
- `bowtie-app-dev`: Development environment with hot reload
- `bowtie-app-test`: Testing service for CI/CD
- `performance-monitor`: Real-time performance monitoring
- `nginx`: Load balancer and reverse proxy

### Deployment Commands

```bash
# Production deployment
docker-compose up bowtie-app

# Development environment
docker-compose --profile dev up bowtie-app-dev

# Run test suite
docker-compose --profile test up bowtie-app-test

# Performance monitoring
docker-compose --profile monitoring up performance-monitor
```

## Error Handling and Logging

### Error Handling Patterns

All major functions implement comprehensive error handling:

```r
tryCatch({
  # Function logic
  result <- some_operation()
  return(result)
}, error = function(e) {
  cat("Error in function_name:", e$message, "\n")
  return(fallback_value)
})
```

### Logging Standards

Development logging follows structured format:

```r
dev_log("LEVEL", "message", "CATEGORY")
# Levels: DEBUG, INFO, WARN, ERROR
# Categories: STARTUP, VALIDATION, PERFORMANCE, etc.
```

## Version History

### Version 5.2.0 (Current)
- Advanced development framework with hot reload
- CI/CD pipeline with GitHub Actions integration
- Docker containerization and orchestration
- Consistency fixes and architectural improvements
- Performance regression testing and monitoring

### Version 5.1.0
- Enhanced testing framework with parallel execution
- Performance benchmarking and memory monitoring
- Bootstrap theme testing and validation
- Cross-platform compatibility improvements

## Support and Contributing

For questions, issues, or contributions:
- **Repository**: https://github.com/razinkele/bowtie_app
- **Issues**: https://github.com/razinkele/bowtie_app/issues
- **Documentation**: See CLAUDE.md for detailed developer guidance

---

*This API reference is automatically updated with each release. For the most current information, always refer to the latest version in the repository.*