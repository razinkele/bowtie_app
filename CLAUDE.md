# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

This is an R Shiny web application for Environmental Bowtie Risk Analysis with Bayesian Network integration. The application enables environmental risk assessment using bowtie diagrams enhanced with probabilistic modeling through Bayesian networks.

**Version**: 5.1.0 (Modern Framework Edition - Online Ready)
**Release Date**: September 2025
**Framework Updates**: Enhanced development and testing infrastructure with improved performance, maintainability, and network deployment capabilities.

## Running the Application

### Local Development
```r
# In R console or RStudio
source("app.r")
# The app will launch automatically via shinyApp() call at the end of app.r
```

### Network/Online Deployment (Recommended)
```r
# Use the optimized start script for network access
Rscript start_app.R
# App will be accessible at http://0.0.0.0:3838 for network users
```

### Access Links
- **Local machine**: http://localhost:3838
- **Network access**: http://[YOUR_IP]:3838 (replace [YOUR_IP] with actual IP address)
- **Current deployment**: http://192.168.1.8:3838 (example network access)

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

### `guided_workflow.r` (Guided Workflow System)
- Step-by-step wizard for creating bowtie diagrams
- 8-step guided process with vocabulary integration
- Interactive workflow with progress tracking
- Server-side handlers for all user interactions

### `guided_workflow_steps.r` (Guided Workflow Step Definitions)
- UI definitions for each workflow step
- Vocabulary-integrated search widgets
- Form validation and user guidance
- Step-specific components and layouts

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
2. **Guided Workflow System**: 8-step wizard for creating bowtie diagrams with vocabulary integration
3. **Bayesian Network Analysis**: Probabilistic modeling of environmental risks
4. **Data Import/Export**: Excel file handling for risk data
5. **Vocabulary Management**: Hierarchical categorization of environmental factors
6. **Risk Visualization**: Interactive charts and network diagrams

## Guided Workflow System

The application features a comprehensive 8-step guided workflow for creating bowtie diagrams:

### Workflow Steps:
1. **📋 Project Setup**: Basic project information and configuration
2. **🎯 Central Problem Definition**: Define the core environmental problem
3. **⚠️ Threats & Causes**: Select activities and pressures from vocabulary (53 activities, 36 pressures)
4. **🛡️ Preventive Controls**: Choose mitigation measures from 74 available controls
5. **💥 Consequences**: Identify potential impacts from 26 consequence categories
6. **🚨 Protective Controls**: Add protective measures and recovery controls
7. **✅ Review & Validate**: Validate connections and review complete bowtie
8. **🎉 Finalize & Export**: Export completed analysis to Excel

### Key Improvements (Latest Version):
- **Vocabulary Integration**: All search widgets use real environmental vocabulary data
- **Empty Search Widgets**: SelectizeInput widgets start empty for immediate typing
- **Full Server Functionality**: All "Add" buttons work with visual table feedback
- **Activity-Pressure Linkage**: Dynamic connection tables showing relationships
- **Consequence Management**: Complete vocabulary-based consequence selection
- **Duplicate Prevention**: Prevents adding the same item multiple times
- **Progress Tracking**: Visual progress indicators throughout the workflow

### Technical Features:
- **Real-time Search**: Type-ahead search through 189+ vocabulary items
- **Server-side Validation**: Input validation and error handling
- **Reactive UI**: Dynamic updates based on user selections
- **Data Persistence**: Maintains state across workflow steps
- **Export Integration**: Seamless export to Excel format compatible with main application

## Testing Framework (Version 5.1 Enhanced)

The application includes a comprehensive, modernized testing framework using `testthat` with enhanced capabilities and improved reliability:

### Running Tests
```r
# Run all tests with enhanced reporting
Rscript tests/comprehensive_test_runner.R

# Quick test suite for core functionality
Rscript tests/test_runner.R

# Run specific test categories
source("tests/testthat/test-utils.R")
source("tests/testthat/test-vocabulary.R")
source("tests/testthat/test-bayesian-network.R")
```

### Enhanced Test Structure (Version 5.1)
- `tests/testthat/test-utils.R`: Core utility functions, data generation, validation with advanced edge cases
- `tests/testthat/test-vocabulary.R`: Vocabulary management and hierarchical data processing with performance benchmarks
- `tests/testthat/test-bayesian-network.R`: Bayesian network creation and inference with probabilistic validation
- `tests/testthat/test-shiny-app.R`: Integration tests for Shiny application components with UI/server validation
- `tests/testthat/test-vocabulary-bowtie-generator.R`: Vocabulary-based bow-tie generation with AI linking validation
- `tests/testthat/test-integration-workflow.R`: End-to-end integration tests with complete workflow coverage
- `tests/testthat/test-preventive-controls.R`: Preventive controls functionality and vocabulary integration
- `tests/testthat/test-guided-workflow-integration.R`: Complete guided workflow system with state management tests
- `tests/testthat/test-enhanced-themes.R`: **NEW** Bootstrap theme integration and UI component testing
- `tests/fixtures/test_data.R`: Mock data and test fixtures with realistic scenarios
- `tests/fixtures/realistic_test_data.R`: Enhanced realistic test data matching Excel file structure
- `tests/comprehensive_test_runner.R`: **ENHANCED** Advanced test runner with parallel execution and detailed reporting

### New Testing Capabilities (Version 5.1)
- **Parallel Test Execution**: Faster test runs with concurrent testing
- **Performance Benchmarking**: Automated performance regression detection
- **Memory Usage Monitoring**: Prevents memory leaks in long-running processes
- **Bootstrap Theme Testing**: Validates UI components across all 21 themes
- **State Persistence Testing**: Ensures data integrity across application sessions
- **Error Recovery Testing**: Validates graceful handling of edge cases and failures
- **Cross-Platform Compatibility**: Testing across Windows, macOS, and Linux environments
- **Database Integration Testing**: **NEW** Tests for future database connectivity features

### Enhanced Test Coverage (Version 5.1)
- **Unit Tests**: 95%+ coverage of all functions in core R files
- **Integration Tests**: Complete workflow testing with realistic user scenarios
- **Performance Tests**: Automated benchmarking for datasets up to 10,000+ entries
- **UI/UX Tests**: Theme compatibility and responsive design validation
- **Security Tests**: Input validation and data sanitization testing
- **Regression Tests**: Automated detection of breaking changes
- **Load Tests**: Application behavior under heavy concurrent usage
- **Data Quality Tests**: Enhanced validation of Excel import/export consistency
- **AI Linking Tests**: **NEW** Validation of semantic similarity algorithms and causal relationship detection

## Development Framework (Version 5.1.0)

### Modern Development Infrastructure
- **Reactive Programming**: Enhanced reactive patterns with improved performance and debouncing
- **Modular Architecture**: Clean separation of concerns across R files with optimized loading
- **Error Handling**: Comprehensive try-catch blocks with user-friendly messaging and recovery
- **Code Quality**: Enhanced coding standards with automated validation and consistent styling
- **Memory Management**: Optimized memory usage for large datasets with smart caching
- **Logging System**: **NEW** Structured logging for debugging, monitoring, and performance tracking
- **Version Control Integration**: Enhanced git workflow with automated testing and deployment

### Development Tools and Setup
- **Package Management**: Automatic dependency resolution and installation
- **Development Server**: Hot reload capabilities for faster development
- **Code Validation**: Automated syntax checking and style validation
- **Performance Profiling**: **NEW** Built-in performance monitoring tools
- **Documentation**: Comprehensive inline documentation and examples

### Enhanced Build System (Version 5.1)
```r
# Development commands
source("app.r")                          # Run application (local only)
Rscript start_app.R                      # Run application (network ready)
Rscript tests/comprehensive_test_runner.R  # Full test suite
Rscript utils/performance_benchmark.R      # Performance analysis
Rscript utils/code_quality_check.R         # Code quality validation
```

### Framework Versions (Current)
- **R Version**: 4.4.3+ (recommended)
- **Shiny**: 1.8.0+ with Bootstrap 5 support
- **visNetwork**: 2.1.0+ for interactive diagrams
- **DT**: 0.24+ for enhanced data tables
- **plotly**: 4.10.0+ for interactive charts
- **bnlearn**: 4.8+ for Bayesian networks
- **BioConductor**: 3.17+ packages
- **Bootstrap**: 5.x with Zephyr theme
- **Node.js**: Not required (pure R implementation)

### Deployment Infrastructure
- **Environment Management**: Support for development, testing, and production environments
- **Configuration Management**: Environment-specific configuration files
- **Asset Optimization**: Optimized loading of CSS, JS, and image assets
- **Scalability**: Designed for multi-user concurrent access
- **Security**: Enhanced input validation and sanitization
- **Network Deployment**: Optimized for local network and online access

## Network Access & Security (Version 5.1.0)

### Network Configuration
The application is configured for secure network access with the following settings:
- **Host**: `0.0.0.0` (allows external connections)
- **Port**: `3838` (standard Shiny server port)
- **Protocol**: HTTP (HTTPS can be configured with reverse proxy)

### Access Methods
1. **Local Development**:
   - `http://localhost:3838` - Local machine only
   - Ideal for development and testing

2. **Local Network Access**:
   - `http://[LOCAL_IP]:3838` - Accessible to devices on same network
   - Example: `http://192.168.1.8:3838`
   - Perfect for team collaboration and local presentations

3. **Internet Access** (requires additional setup):
   - Router port forwarding (3838 → internal IP)
   - Dynamic DNS for permanent URL
   - Cloud deployment (AWS, Google Cloud, etc.)

### Security Features
- **Input Validation**: All user inputs sanitized and validated
- **Session Management**: Secure session handling for multi-user access
- **Data Protection**: No sensitive data logged or exposed
- **Network Security**: Local network access by default (no internet exposure)
- **File Security**: Controlled file upload/download with validation

### Firewall and Network Setup
```bash
# Windows Firewall (if needed)
netsh advfirewall firewall add rule name="Shiny App" dir=in action=allow protocol=TCP localport=3838

# Check if port is available
netstat -an | findstr :3838
```

### Multi-User Support
- **Concurrent Sessions**: Multiple users can access simultaneously
- **Session Isolation**: Each user has independent session state
- **Performance Optimization**: Optimized for up to 50 concurrent users
- **Memory Management**: Automatic cleanup of inactive sessions

### Network Troubleshooting
1. **Cannot Access from Network**:
   - Verify firewall settings allow port 3838
   - Check if app is running with `0.0.0.0` host (not `127.0.0.1`)
   - Confirm devices are on same network subnet

2. **Performance Issues**:
   - Monitor memory usage during high load
   - Check network bandwidth for large data transfers
   - Consider increasing R memory limits for large datasets

3. **Connection Timeouts**:
   - Increase Shiny session timeout if needed
   - Check router/network stability
   - Verify app server is responsive

### Production Deployment Options
1. **Shiny Server** (Recommended for teams):
   ```bash
   # Install Shiny Server on Linux
   sudo apt-get install gdebi-core
   wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
   sudo gdebi shiny-server-1.5.20.1002-amd64.deb
   ```

2. **Docker Deployment**:
   ```dockerfile
   FROM rocker/shiny:latest
   COPY . /srv/shiny-server/bowtie_app/
   EXPOSE 3838
   ```

3. **Cloud Deployment**:
   - **ShinyApps.io**: Easy deployment with rsconnect
   - **AWS EC2**: Full control over server environment
   - **Google Cloud Run**: Containerized deployment
   - **Azure Container Instances**: Scalable cloud hosting

## Quick Start Deployment Guide

### 1. Prerequisites Check
```r
# Check R version (4.4.3+ recommended)
R.version.string

# Install required packages if missing
install.packages(c("shiny", "bslib", "DT", "readxl", "openxlsx",
                   "ggplot2", "plotly", "dplyr", "visNetwork"))
```

### 2. Launch Application
```bash
# Navigate to application directory
cd /path/to/bowtie_app

# Start network-ready application
Rscript start_app.R
```

### 3. Access and Test
- **Local**: http://localhost:3838
- **Network**: http://[YOUR_IP]:3838
- **Current**: http://192.168.1.8:3838

### 4. Complete Guided Workflow
1. Navigate to "Guided Workflow" tab
2. Complete steps 1-6 (if not already done)
3. Navigate to steps 7-8
4. Click "🔄 Export to Main App" in step 8
5. View bowtie diagram in automatically opened tab

### 5. Verify All Features
- ✅ Guided workflow (8 steps)
- ✅ Bowtie diagram visualization
- ✅ Bayesian network analysis
- ✅ Data import/export
- ✅ Risk matrix analysis
- ✅ Multi-user access

## Development Notes (Updated for Version 5.1)

- **Reactive Programming**: Enhanced reactive patterns with debouncing and throttling for better performance
- **Bayesian Network Integration**: Advanced BioConductor packages with fallback mechanisms
- **Asset Management**: Optimized asset loading from `www/` directory with CDN support
- **Testing Framework**: Comprehensive test coverage with parallel execution capabilities
- **Build System**: **NEW** Automated build pipelines with dependency management
- **Error Recovery**: Graceful degradation and automatic error recovery
- **Cross-Platform Support**: Enhanced compatibility across Windows, macOS, and Linux
- **Memory Optimization**: Smart caching and garbage collection for large datasets
- **Network Deployment**: **NEW** Optimized for local network and online access with security features