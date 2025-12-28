# Contributing to Environmental Bowtie Risk Analysis

Thank you for your interest in contributing to the Environmental Bowtie Risk Analysis application! This document provides guidelines and workflows for contributors.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Development Workflow](#development-workflow)
- [Code Quality Standards](#code-quality-standards)
- [Testing Requirements](#testing-requirements)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

- **R**: Version 4.3.2 or higher (4.4.3 recommended)
- **Git**: For version control
- **RStudio**: Optional but recommended for R development

### Required R Packages

The application will auto-install missing packages, but you can install them manually:

```r
install.packages(c(
  "shiny", "bslib", "DT", "readxl", "openxlsx",
  "ggplot2", "plotly", "dplyr", "visNetwork",
  "shinycssloaders", "colourpicker", "htmlwidgets", "shinyjs",
  "bnlearn", "gRain", "igraph", "DiagrammeR"
))
```

### Development Tools

```r
# For code quality checks
install.packages("lintr")

# For testing
install.packages("testthat")

# For performance benchmarking
install.packages("microbenchmark")
```

---

## Development Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd bowtie_app
```

### 2. Install Pre-commit Hooks

**IMPORTANT**: Install pre-commit hooks to ensure code quality:

```r
# Run the installation script
Rscript install_hooks.R
```

This will:
- Install git pre-commit hooks
- Check for code style issues before commits
- Run syntax validation
- Execute fast tests (if available)

### 3. Verify Installation

```bash
# Test that the app runs
Rscript start_app.R
```

Access the application at http://localhost:3838

---

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
# or
git checkout -b docs/documentation-improvement
```

**Branch Naming Conventions**:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `test/` - Test improvements
- `refactor/` - Code refactoring
- `perf/` - Performance improvements

### 2. Make Your Changes

Follow the code quality standards (see below) while making changes.

### 3. Test Your Changes

```r
# Run the comprehensive test suite
source("tests/comprehensive_test_runner.R")

# Or run specific tests
library(testthat)
test_file("tests/testthat/test-your-feature.R")
```

### 4. Check Code Quality

```r
# Run code quality checks
source("utils/code_quality_check.R")
run_code_quality_check()

# Run lintr
library(lintr)
lint_package()
```

### 5. Commit Your Changes

The pre-commit hooks will automatically run when you commit:

```bash
git add .
git commit -m "feat: Add your feature description"
```

If the hooks fail, fix the issues and try again. To bypass (not recommended):

```bash
git commit --no-verify -m "your message"
```

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

---

## Code Quality Standards

### R Code Style

Follow the [tidyverse style guide](https://style.tidyverse.org/):

```r
# Good
calculate_risk_score <- function(probability, impact) {
  score <- probability * impact
  return(score)
}

# Bad
CalculateRiskScore<-function(p,i){score<-p*i;return(score)}
```

### File Naming

- Use `.R` extension (capital R) for all R files
- Use snake_case for file names: `my_module.R`
- Avoid spaces in file names

### Function Documentation

Document all exported functions:

```r
#' Calculate Environmental Risk Score
#'
#' Computes a risk score based on probability and impact values.
#'
#' @param probability Numeric value between 0 and 1
#' @param impact Numeric value representing potential impact
#' @return Numeric risk score
#' @examples
#' calculate_risk_score(0.7, 5)
calculate_risk_score <- function(probability, impact) {
  # Implementation
}
```

### Logging

Use the centralized logging system:

```r
# For user-facing messages
app_message("Operation completed successfully", level = "success")

# For debug messages
bowtie_log("Processing 100 records", level = "debug")
```

**Do NOT use**:
- `cat()` for logging (except in renderPrint() blocks)
- `print()` for user messages
- Direct `message()` calls

### Caching

Use the centralized cache system:

```r
# Check cache
cached_data <- get_cache("my_data_key")
if (!is.null(cached_data)) {
  return(cached_data)
}

# Compute expensive operation
result <- expensive_computation()

# Store in cache
set_cache("my_data_key", result)
```

---

## Testing Requirements

### Required Tests

Every new feature or bug fix should include tests:

```r
# tests/testthat/test-your-feature.R
library(testthat)

test_that("Feature works correctly", {
  result <- your_function(input)
  expect_equal(result, expected_output)
})

test_that("Feature handles edge cases", {
  expect_error(your_function(NULL))
  expect_warning(your_function(invalid_input))
})
```

### Test Coverage

Aim for:
- **90%+ coverage** for new utility functions
- **80%+ coverage** for Shiny reactive logic
- **100% coverage** for critical functions (data validation, security)

### Running Tests

```r
# Fast test suite
source("tests/test_runner.R")

# Comprehensive test suite
source("tests/comprehensive_test_runner.R")

# Specific test file
library(testthat)
test_file("tests/testthat/test-your-feature.R")
```

---

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
# Feature
git commit -m "feat(guided-workflow): Add custom entries feature"

# Bug fix
git commit -m "fix(cache): Resolve LRU eviction issue"

# Documentation
git commit -m "docs(readme): Update installation instructions"

# Performance
git commit -m "perf(vocabulary): Optimize data loading with caching"
```

### Commit Message Body (Optional)

For complex changes, add a detailed body:

```
feat(bayesian-network): Add conditional probability tables

Implement CPT generation for Bayesian network nodes based on
expert knowledge and historical data. Includes validation and
error handling for malformed probability distributions.

Resolves #123
```

---

## Pull Request Process

### Before Submitting

1. ✅ All tests pass locally
2. ✅ Code quality checks pass (lintr, code_quality_check.R)
3. ✅ Pre-commit hooks pass
4. ✅ Documentation updated (if needed)
5. ✅ CHANGELOG updated (for significant changes)

### PR Title Format

Same as commit messages:

```
feat(scope): Brief description
fix(scope): Brief description
```

### PR Description Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe how you tested your changes

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Code quality checks pass
- [ ] Pre-commit hooks pass
- [ ] CI pipeline passes
```

### Review Process

1. Create PR against `main` branch
2. Wait for CI checks to pass
3. Request review from maintainers
4. Address review comments
5. Wait for approval
6. Squash and merge (or rebase)

---

## Project Structure

```
bowtie_app/
├── app.R                    # Standard Shiny launcher
├── start_app.R              # Network-ready launcher
├── config.R                 # Application configuration
├── global.R                 # Global setup and initialization
├── ui.R                     # Shiny UI definition
├── server.R                 # Shiny server logic
├── utils.R                  # Utility functions and caching
├── vocabulary.R             # Vocabulary data management
├── guided_workflow.R        # Guided workflow system
├── bowtie_bayesian_network.R # Bayesian network integration
├── vocabulary_bowtie_generator.R # AI-powered generator
│
├── tests/
│   ├── testthat/           # Unit and integration tests
│   ├── test_runner.R       # Fast test runner
│   └── comprehensive_test_runner.R # Complete test suite
│
├── utils/
│   ├── code_quality_check.R      # Code quality tool
│   ├── performance_benchmark.R   # Performance testing
│   └── advanced_benchmarks.R     # Advanced benchmarking
│
├── tools/
│   └── pre-commit          # Git pre-commit hook template
│
├── .github/
│   └── workflows/
│       ├── ci.yml                # Fast CI workflow
│       └── ci-cd-pipeline.yml    # Advanced CI/CD pipeline
│
├── docs/                   # Additional documentation
├── www/                    # Static web assets
└── data/                   # Data files (Excel vocabularies)
```

---

## Common Tasks

### Running the Application

```bash
# Network-ready (recommended)
Rscript start_app.R

# Local only
Rscript app.R
```

### Running Tests

```r
# Fast tests
source("tests/test_runner.R")

# All tests
source("tests/comprehensive_test_runner.R")

# Specific category
library(testthat)
test_dir("tests/testthat", filter = "cache")
```

### Code Quality Checks

```r
# Run all checks
source("utils/code_quality_check.R")
run_code_quality_check()

# Just lintr
library(lintr)
lint_package()
```

### Performance Benchmarking

```r
# Basic benchmarks
source("utils/performance_benchmark.R")

# Advanced benchmarks
source("utils/advanced_benchmarks.R")
results <- run_complete_performance_suite()
```

### Cache Management

```r
# View cache statistics
print_cache_stats()

# Clear cache
clear_cache(reset_stats = TRUE)

# Enable verbose mode
options(bowtie.verbose = TRUE)
```

---

## Troubleshooting

### Pre-commit Hooks Failing

**Problem**: Hooks fail with lintr errors

```bash
# Fix style issues automatically (if possible)
Rscript -e "library(styler); style_dir('.')"

# Or bypass (not recommended)
git commit --no-verify
```

**Problem**: Tests fail in pre-commit hook

```r
# Run tests manually to see details
source("tests/test_runner.R")

# Fix issues and try again
git add .
git commit -m "your message"
```

### Application Won't Start

**Problem**: Missing packages

```r
# Install all dependencies
source("requirements.R")
```

**Problem**: Port already in use

```r
# Edit config.R to change port
PORT <- 3839  # Or another available port
```

### Tests Failing

**Problem**: Cache interference

```r
# Clear cache before tests
clear_cache(reset_stats = TRUE)
```

**Problem**: File paths (Windows vs Unix)

```r
# Use file.path() for cross-platform compatibility
file.path("data", "file.xlsx")  # Good
"data/file.xlsx"                # May fail on Windows
```

---

## Code Review Checklist

When reviewing code, check for:

- [ ] **Functionality**: Does it work as intended?
- [ ] **Tests**: Are there adequate tests?
- [ ] **Documentation**: Are functions documented?
- [ ] **Code Style**: Follows style guide?
- [ ] **Performance**: Any performance concerns?
- [ ] **Security**: No security vulnerabilities?
- [ ] **Logging**: Uses centralized logging?
- [ ] **Caching**: Uses centralized cache (if applicable)?
- [ ] **Error Handling**: Handles errors gracefully?
- [ ] **Backwards Compatibility**: No breaking changes (or documented)?

---

## Getting Help

### Resources

- **CLAUDE.md**: Detailed project documentation
- **README.md**: Quick start guide
- **Documentation**: Check `docs/` directory
- **Issues**: GitHub issue tracker

### Contact

- Open an issue on GitHub
- Tag maintainers in PRs: @maintainer

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

## Thank You!

Thank you for contributing to the Environmental Bowtie Risk Analysis application! Your contributions help make environmental risk assessment more accessible and effective.

---

**Version**: 5.5.3
**Last Updated**: December 28, 2025
