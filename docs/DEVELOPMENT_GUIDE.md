# Development Guide - Environmental Bowtie Risk Analysis Application

**Version**: 5.2.0 (Advanced Framework Edition)
**Last Updated**: September 2025

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Testing Guidelines](#testing-guidelines)
- [Performance Optimization](#performance-optimization)
- [Deployment Process](#deployment-process)
- [Contributing Guidelines](#contributing-guidelines)

## Getting Started

### Prerequisites

- **R**: Version 4.3.2 or higher (4.4.3 recommended)
- **Git**: For version control
- **Docker**: For containerized development (optional but recommended)
- **RStudio**: For enhanced development experience (optional)

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/razinkele/bowtie_app.git
cd bowtie_app

# Install R dependencies
Rscript requirements.R

# Launch development environment
source("dev_config.R")

# Start the application
Rscript start_app.R
```

## Development Environment Setup

### Enhanced Development Framework

The application includes a comprehensive development framework with advanced tooling:

#### 1. Load Development Configuration

```r
# Load enhanced development environment
source("dev_config.R")

# Available development tools:
dev_log("INFO", "Development message", "CATEGORY")
dev_profile("event_name")
validate_icon_usage()
validate_dependencies()
```

#### 2. Development Features

- **Hot Reload**: Automatic application restart on file changes
- **Performance Profiling**: Real-time memory monitoring and benchmarking
- **Code Validation**: Automated consistency checks and dependency validation
- **Enhanced Logging**: Structured logging with file output and categorization

#### 3. Development Configuration Options

```r
dev_config <- list(
  mode = "development",           # development, testing, production
  debug = TRUE,                  # Enable debug mode
  hot_reload = TRUE,             # Enable hot reload
  cache_enabled = TRUE,          # Enable caching
  memory_monitoring = TRUE,      # Monitor memory usage
  profiling_enabled = TRUE,      # Enable performance profiling
  show_debug_panel = TRUE,       # Show debug information
  auto_test = FALSE,             # Run tests automatically
  log_level = "INFO"             # DEBUG, INFO, WARN, ERROR
)
```

### Docker Development Environment

For containerized development:

```bash
# Start development container with hot reload
docker-compose --profile dev up bowtie-app-dev

# Access the application at http://localhost:3839
# Development container includes enhanced debugging tools
```

## Project Structure

```
bowtie_app/
├── app.r                           # Application launcher
├── global.R                        # Global configuration and package loading
├── ui.R                           # User interface definition
├── server.R                       # Server logic
├── start_app.R                    # Network-ready application starter
├── dev_config.R                   # Development framework configuration
├── requirements.R                 # R package dependencies
├── Dockerfile                     # Docker containerization
├── docker-compose.yml             # Container orchestration
│
├── Core Application Modules/
│   ├── guided_workflow.r          # Guided workflow system core
│   ├── guided_workflow_steps.r    # Workflow step implementations
│   ├── utils.r                    # Utility functions and data generation
│   ├── vocabulary.r               # Vocabulary management system
│   └── bowtie_bayesian_network.r  # Bayesian network integration
│
├── Data Files/
│   ├── CAUSES.xlsx                # Activities and pressures vocabulary
│   ├── CONSEQUENCES.xlsx          # Environmental consequences
│   ├── CONTROLS.xlsx              # Risk controls and mitigation measures
│   └── environmental_bowtie_data_*.xlsx  # Sample datasets
│
├── Testing Framework/
│   ├── tests/
│   │   ├── comprehensive_test_runner.R    # Enhanced test runner
│   │   └── testthat/
│   │       ├── test-utils.R               # Utility function tests
│   │       ├── test-vocabulary.R          # Vocabulary system tests
│   │       ├── test-bayesian-network.R    # Bayesian network tests
│   │       ├── test-consistency-fixes.R   # Consistency validation tests
│   │       └── test-performance-regression.R  # Performance tests
│   │
│   └── fixtures/
│       ├── test_data.R            # Test data and fixtures
│       └── realistic_test_data.R  # Realistic test scenarios
│
├── Performance and Utilities/
│   ├── utils/
│   │   ├── performance_benchmark.R     # Performance benchmarking
│   │   ├── advanced_benchmarks.R       # Advanced performance analysis
│   │   ├── code_quality_check.R        # Code quality validation
│   │   └── ci_cd_pipeline.md           # CI/CD documentation
│
├── CI/CD and Deployment/
│   ├── .github/
│   │   └── workflows/
│   │       └── ci-cd-pipeline.yml       # GitHub Actions pipeline
│   │
│   ├── docker/                         # Docker configuration files
│   └── deployment/                     # Deployment scripts and configs
│
├── Documentation/
│   ├── docs/
│   │   ├── API_REFERENCE.md            # Comprehensive API documentation
│   │   ├── DEVELOPMENT_GUIDE.md        # This file
│   │   └── DEPLOYMENT_GUIDE.md         # Deployment instructions
│   │
│   ├── CLAUDE.md                       # Developer-focused documentation
│   └── README.md                       # Project overview and quick start
│
└── Web Assets/
    └── www/                            # Static web assets (CSS, JS, images)
```

## Development Workflow

### 1. Feature Development Process

#### Step 1: Environment Setup
```bash
# Start development environment
source("dev_config.R")

# Validate current state
validate_dependencies()
validate_icon_usage()
```

#### Step 2: Development with Hot Reload
```r
# Development tools are automatically available
dev_log("INFO", "Starting feature development", "FEATURE")

# Make code changes - application will auto-reload
# Monitor performance during development
dev_profile("feature_implementation")
```

#### Step 3: Testing During Development
```bash
# Run specific test categories
Rscript -e "testthat::test_dir('tests/testthat/', filter = 'consistency')"

# Run comprehensive test suite
Rscript tests/comprehensive_test_runner.R

# Performance regression testing
Rscript -e "source('utils/advanced_benchmarks.R'); run_complete_performance_suite()"
```

### 2. Code Quality Standards

#### Consistency Requirements
- **Icon Usage**: Use consistent `icon()` function, not `tags$i()`
- **Import Structure**: No circular dependencies
- **Documentation**: Keep CLAUDE.md and README.md updated
- **Error Handling**: Implement comprehensive try-catch blocks

#### Code Style Guidelines
```r
# Good: Consistent icon usage
icon("check-circle", class = "text-success")

# Bad: Mixed icon approaches
tags$i(class = "fas fa-check-circle text-success")

# Good: Proper error handling
tryCatch({
  result <- risky_operation()
  return(result)
}, error = function(e) {
  dev_log("ERROR", paste("Operation failed:", e$message), "FEATURE")
  return(fallback_value)
})
```

### 3. Performance Monitoring

#### Real-time Performance Tracking
```r
# Start performance monitoring
start_performance_monitor(interval_seconds = 5)

# Monitor specific operations
dev_profile("data_loading")
large_data <- generate_comprehensive_environmental_data(100, 5, 4, 3, 6)
dev_profile("data_processing_complete")
```

#### Benchmark New Features
```r
# Benchmark consistency fixes impact
consistency_results <- benchmark_consistency_fixes()

# Detect performance regressions
regression_results <- detect_performance_regression()
```

## Testing Guidelines

### Test Categories

#### 1. Consistency Tests (`test-consistency-fixes.R`)
- Validates circular dependency fixes
- Checks icon standardization
- Verifies documentation accuracy
- Tests import logic improvements

#### 2. Performance Tests (`test-performance-regression.R`)
- Application startup time validation
- Memory usage monitoring
- Large dataset processing tests
- Performance regression detection

#### 3. Integration Tests
- End-to-end workflow testing
- Multi-component integration validation
- User interface interaction testing

### Running Tests

#### Local Testing
```bash
# Run all tests
Rscript tests/comprehensive_test_runner.R

# Run specific test categories
Rscript -e "testthat::test_dir('tests/testthat/', filter = 'consistency')"
Rscript -e "testthat::test_dir('tests/testthat/', filter = 'performance')"

# Run tests with coverage
Rscript -e "testthat::test_dir('tests/testthat/', reporter = 'summary')"
```

#### Container Testing
```bash
# Run tests in container environment
docker-compose --profile test up bowtie-app-test
```

### Writing New Tests

#### Test Structure Template
```r
# tests/testthat/test-new-feature.R
library(testthat)

context("New Feature Testing")

test_that("feature works correctly", {
  # Setup
  test_data <- setup_test_data()

  # Execute
  result <- new_feature_function(test_data)

  # Validate
  expect_true(is.list(result))
  expect_equal(length(result), expected_length)
  expect_true(all(required_fields %in% names(result)))
})

test_that("feature handles errors gracefully", {
  # Test error conditions
  expect_error(new_feature_function(invalid_data), "Expected error message")
})
```

## Performance Optimization

### Memory Management

#### Best Practices
```r
# Use garbage collection in memory-intensive operations
gc()

# Monitor memory usage during development
initial_memory <- pryr::mem_used()
# ... perform operations ...
final_memory <- pryr::mem_used()
memory_increase <- final_memory - initial_memory
```

#### Large Dataset Handling
```r
# Use data.table for large datasets
library(data.table)

# Implement chunked processing for very large datasets
process_data_chunks <- function(data, chunk_size = 1000) {
  chunks <- split(data, ceiling(seq_along(data) / chunk_size))
  results <- lapply(chunks, process_chunk)
  return(do.call(rbind, results))
}
```

### Performance Monitoring

#### Automated Benchmarking
```r
# Set up performance baselines
baseline_metrics <- list(
  startup_time = 15.0,      # seconds
  vocabulary_load = 2.0,    # seconds
  workflow_init = 5.0,      # seconds
  memory_usage = 500        # MB
)

# Run performance comparison
current_metrics <- detect_performance_regression()
```

#### Real-time Monitoring
```r
# Monitor during development
performance_monitor <- setup_performance_profiler()
performance_monitor("feature_start")
# ... implement feature ...
performance_monitor("feature_complete")
```

## Deployment Process

### Local Deployment

#### Standard Deployment
```bash
# Start application with network access
Rscript start_app.R

# Application available at:
# - Local: http://localhost:3838
# - Network: http://[YOUR_IP]:3838
```

### Container Deployment

#### Development Environment
```bash
# Start development container
docker-compose --profile dev up bowtie-app-dev
```

#### Production Environment
```bash
# Build and start production container
docker-compose up bowtie-app

# With load balancing
docker-compose --profile production up
```

### CI/CD Pipeline

#### GitHub Actions Integration
The application includes automated CI/CD pipeline:

1. **Consistency Validation**: Automated checking of architectural improvements
2. **Multi-version Testing**: R 4.3.2 and 4.4.3 compatibility
3. **Performance Testing**: Automated regression detection
4. **Security Analysis**: Vulnerability scanning and code quality
5. **Deployment Preparation**: Automated package creation

#### Pipeline Triggers
- **Push to main**: Full pipeline execution
- **Pull requests**: Testing and validation
- **Daily schedule**: Performance regression monitoring

## Contributing Guidelines

### Contribution Process

1. **Fork the Repository**
   ```bash
   git fork https://github.com/razinkele/bowtie_app
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/new-feature-name
   ```

3. **Develop with Testing**
   ```bash
   # Make changes with hot reload enabled
   source("dev_config.R")

   # Run tests continuously
   Rscript tests/comprehensive_test_runner.R
   ```

4. **Validate Changes**
   ```bash
   # Check consistency
   validate_dependencies()
   validate_icon_usage()

   # Performance testing
   source("utils/advanced_benchmarks.R")
   run_complete_performance_suite()
   ```

5. **Submit Pull Request**
   - Include comprehensive test coverage
   - Update documentation as needed
   - Ensure CI/CD pipeline passes

### Code Review Guidelines

#### Review Checklist
- [ ] Code follows consistency standards
- [ ] Tests cover new functionality
- [ ] Performance impact assessed
- [ ] Documentation updated
- [ ] No circular dependencies
- [ ] Consistent icon usage
- [ ] Error handling implemented

#### Performance Requirements
- Startup time < 15 seconds
- Memory usage < 500MB for standard operations
- No performance regression > 5%
- All tests pass in CI/CD pipeline

### Issue Reporting

#### Bug Reports
- Use the issue template
- Include R version and platform
- Provide reproducible example
- Include relevant log output

#### Feature Requests
- Describe use case and benefits
- Consider performance implications
- Suggest implementation approach
- Include testing strategy

---

## Additional Resources

- **API Reference**: `docs/API_REFERENCE.md`
- **Deployment Guide**: `docs/DEPLOYMENT_GUIDE.md`
- **Developer Documentation**: `CLAUDE.md`
- **Project Overview**: `README.md`
- **Repository**: https://github.com/razinkele/bowtie_app

For questions or support, please create an issue in the GitHub repository.