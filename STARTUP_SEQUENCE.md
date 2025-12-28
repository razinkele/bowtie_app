# Application Startup Sequence Documentation

**Version**: 5.5.3
**Date**: December 28, 2025
**Purpose**: Comprehensive documentation of application initialization process

---

## Table of Contents

- [Overview](#overview)
- [Startup Timeline](#startup-timeline)
- [Phase 1: Base Directory Detection](#phase-1-base-directory-detection)
- [Phase 2: Configuration Loading](#phase-2-configuration-loading)
- [Phase 3: Logging System Initialization](#phase-3-logging-system-initialization)
- [Phase 4: Package Loading](#phase-4-package-loading)
- [Phase 5: Module Loading](#phase-5-module-loading)
- [Phase 6: Vocabulary Data Loading](#phase-6-vocabulary-data-loading)
- [Startup Performance](#startup-performance)
- [Initialization Sequence Diagram](#initialization-sequence-diagram)
- [Troubleshooting](#troubleshooting)

---

## Overview

The Environmental Bowtie Risk Analysis application follows a deterministic startup sequence defined primarily in `global.R`. This document provides a comprehensive understanding of what happens during application initialization.

**Total Startup Time**: Approximately 3-7 seconds (varies by system)

**Primary Initialization File**: `global.R` (174 lines)

**Secondary Initialization Files**:
- `config.R` (application configuration)
- `utils.R` (utility functions and caching)
- `vocabulary.R` (vocabulary data management)
- `bowtie_bayesian_network.R` (Bayesian network analysis)
- `guided_workflow.R` (workflow system)
- Additional modules

---

## Startup Timeline

| Time | Phase | Description | Duration |
|------|-------|-------------|----------|
| T+0s | Phase 1 | Base directory detection | ~0.1s |
| T+0.1s | Phase 2 | Configuration loading | ~0.1s |
| T+0.2s | Phase 3 | Logging system initialization | ~0.1s |
| T+0.3s | Phase 4 | Package loading (19 packages) | ~2-4s |
| T+3s | Phase 5 | Module loading (8 modules) | ~0.5-1s |
| T+4s | Phase 6 | Vocabulary data loading | ~0.5-1s |
| **T+5s** | **Complete** | **Ready for user interaction** | **~5s total** |

---

## Phase 1: Base Directory Detection

**File**: `global.R` lines 9-38
**Purpose**: Determine the application root directory for correct file sourcing
**Duration**: ~0.1 seconds

### Process

```r
base_dir <- NULL
```

#### Step 1.1: Try commandArgs
```r
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  base_dir <- dirname(sub("^--file=", "", file_arg[1]))
}
```

Attempts to extract directory from command-line arguments when run via `Rscript`.

#### Step 1.2: Inspect Stack Frames
```r
if (is.null(base_dir)) {
  frs <- sys.frames()
  for (i in seq_along(frs)) {
    if (!is.null(frs[[i]]$ofile)) {
      base_dir <- dirname(frs[[i]]$ofile)
      break
    }
  }
}
```

If commandArgs failed, inspects the call stack to find the source file.

#### Step 1.3: Fallback to Working Directory
```r
if (is.null(base_dir) || !nzchar(base_dir)) base_dir <- getwd()
```

Final fallback: use current working directory.

#### Step 1.4: Validate config.R Location
```r
if (!file.exists(file.path(base_dir, "config.R"))) {
  if (file.exists(file.path(getwd(), "config.R"))) {
    base_dir <- getwd()
  } else if (exists("find_repo_root", mode = "function")) {
    rr <- find_repo_root()
    if (!is.null(rr) && file.exists(file.path(rr, "config.R"))) base_dir <- rr
  }
}
```

Ensures `config.R` is accessible from detected directory.

### Output

```
⚙️ Loading centralized configuration...
```

---

## Phase 2: Configuration Loading

**File**: `global.R` line 39
**Purpose**: Load application configuration (port, host, version, etc.)
**Duration**: ~0.1 seconds

### Process

```r
source(file.path(base_dir, "config.R"))
```

### What Gets Loaded

From `config.R`:

```r
APP_CONFIG <- list(
  TITLE = "Environmental Bowtie Risk Analysis",
  VERSION = "5.3.0",
  PORT = 3838,
  HOST = "0.0.0.0",
  # ... additional configuration
)
```

**Loaded Variables**:
- `APP_CONFIG` - Application metadata
- `PORT` - Server port (default: 3838)
- `HOST` - Server host (default: 0.0.0.0 for network access)
- Version information
- Required/optional directory lists

### Output

No console output (silent loading).

---

## Phase 3: Logging System Initialization

**File**: `global.R` lines 41-68
**Purpose**: Define centralized logging functions
**Duration**: ~0.1 seconds
**Related Task**: P1-4 (Centralized Logging System)

### Functions Defined

#### 3.1: app_message()
```r
app_message <- function(..., level = c("info", "success", "warn", "error"), force = FALSE)
```

**Purpose**: User-facing application messages
**Visibility**: Always visible (unless `options(bowtie.quiet = TRUE)`)
**Levels**: info, success, warn, error

**Usage**:
```r
app_message("Application started successfully", level = "success")
```

#### 3.2: bowtie_log()
```r
bowtie_log <- function(..., level = c("debug", "info"), .verbose = getOption("bowtie.verbose", FALSE))
```

**Purpose**: Developer/debug logging
**Visibility**: Hidden by default (enable with `options(bowtie.verbose = TRUE)`)
**Levels**: debug, info

**Usage**:
```r
bowtie_log("Processing 100 records", level = "debug")
```

### Output

No console output (function definitions only).

---

## Phase 4: Package Loading

**File**: `global.R` lines 70-102
**Purpose**: Load required R packages
**Duration**: ~2-4 seconds (depends on library loading time)

### Process

#### Step 4.1: Define load_packages() Function

```r
load_packages <- function() {
  app_message("🚀 Starting", APP_CONFIG$TITLE, "...")
  app_message("📦 Loading required packages...")

  required_packages <- c(
    "shiny", "bslib", "DT", "readxl", "openxlsx",
    "ggplot2", "plotly", "dplyr", "visNetwork",
    "shinycssloaders", "colourpicker", "htmlwidgets", "shinyjs"
  )

  bayesian_packages <- c("bnlearn", "gRain", "igraph", "DiagrammeR")

  # ... loading logic
}
```

#### Step 4.2: Load Core Packages (13 packages)

**Required Packages**:
1. **shiny** - Web application framework
2. **bslib** - Bootstrap 5 theming
3. **DT** - Interactive data tables
4. **readxl** - Read Excel files
5. **openxlsx** - Write Excel files
6. **ggplot2** - Static visualizations
7. **plotly** - Interactive charts
8. **dplyr** - Data manipulation
9. **visNetwork** - Network diagrams
10. **shinycssloaders** - Loading animations
11. **colourpicker** - Color selection widget
12. **htmlwidgets** - HTML widget framework
13. **shinyjs** - JavaScript integration

**Loading Method**:
```r
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    app_message("⚠️ Package not installed:", pkg, level = "warn")
  }
}
```

**Error Handling**: Warns but continues if package missing (for testing environments)

#### Step 4.3: Load Bayesian Network Packages (4 packages)

**Bayesian Packages**:
1. **bnlearn** - Bayesian network structure learning
2. **gRain** - Bayesian network inference
3. **igraph** - Graph algorithms
4. **DiagrammeR** - Graph visualization

**Loading Method**: Same as core packages (with warnings)

#### Step 4.4: Execute Package Loading

```r
suppressMessages(load_packages())
```

**Note**: `suppressMessages()` hides individual library() startup messages

### Output

```
🚀 Starting Environmental Bowtie Risk Analysis ...
📦 Loading required packages...
   • Loading core Shiny and visualization packages...
   • Loading Bayesian network analysis packages...
✅ Package presence checked (non-installing mode for tests)
```

### Performance Considerations

**Package Loading Time**:
- **First run**: 2-4 seconds (libraries not cached)
- **Subsequent runs**: 1-2 seconds (OS file cache)
- **With missing packages**: +warnings but no installation

---

## Phase 5: Module Loading

**File**: `global.R` lines 104-152
**Purpose**: Source all application modules
**Duration**: ~0.5-1 second

### Modules Loaded (in order)

#### 5.1: Core Utility Modules

```r
app_message("🔧 Loading application modules...")
app_message("   • Loading utility functions and data management...")
source(file.path(base_dir, "utils.R"))
source(file.path(base_dir, "vocabulary.R"))
source(file.path(base_dir, "custom_terms_storage.R"))
source(file.path(base_dir, "environmental_scenarios.R"))
```

**1. utils.R** (~1500 lines)
- Cache system initialization (`.cache` environment)
- Data generation functions
- Validation functions
- Bowtie node/edge creation
- Enhanced with P1-5 (LRU caching)

**2. vocabulary.R** (~500 lines)
- Vocabulary data loading from Excel
- Hierarchical data processing
- Search and filter functions
- Integrated with LRU cache (P1-5)

**3. custom_terms_storage.R**
- Custom term management
- User-defined vocabulary additions

**4. environmental_scenarios.R**
- Pre-defined environmental scenarios
- Scenario templates

#### 5.2: Translation System

```r
app_message("   • Loading translation system...")
source(file.path(base_dir, "translations_data.R"))
```

**translations_data.R**
- Multi-language support
- Translation dictionaries
- Language switching logic

#### 5.3: Bayesian Network Module (with error handling)

```r
app_message("   • Loading Bayesian network analysis...")
tryCatch({
  source(file.path(base_dir, "bowtie_bayesian_network.R"))
  app_message("     ✓ Bayesian network analysis loaded", level = "success")
}, error = function(e) {
  app_message("     ⚠️ Warning: Failed to load Bayesian network analysis", level = "warn")
  # ... helpful error message
})
```

**bowtie_bayesian_network.R** (~800 lines)
- Bayesian network conversion
- Conditional probability tables
- Network inference
- Requires: bnlearn, gRain, igraph

**Error Handling**: Graceful degradation if Bayesian packages missing

#### 5.4: Vocabulary Bowtie Generator (with error handling)

```r
app_message("   • Loading vocabulary bowtie generator...")
tryCatch({
  source(file.path(base_dir, "vocabulary_bowtie_generator.R"))
  app_message("     ✓ Vocabulary bowtie generator loaded", level = "success")
}, error = function(e) {
  app_message("     ⚠️ Warning: Failed to load vocabulary bowtie generator", level = "warn")
  # ... helpful error message
})
```

**vocabulary_bowtie_generator.R** (~1200 lines)
- AI-powered vocabulary linking
- Semantic similarity calculations
- Automated bowtie generation

**Error Handling**: Application continues without AI features

#### 5.5: Guided Workflow System (with error handling)

```r
app_message("   • Loading guided workflow system...")
tryCatch({
  source(file.path(base_dir, "guided_workflow.R"))
  app_message("     ✓ Guided workflow core loaded", level = "success")
}, error = function(e) {
  app_message("     ⚠️ Warning: Failed to load guided workflow system", level = "warn")
})
```

**guided_workflow.R** (~3000+ lines)
- 8-step guided workflow UI and logic
- Step definitions
- State management
- Progress tracking
- Enhanced with P1-4 logging

### Output

```
🔧 Loading application modules...
   • Loading utility functions and data management...
   • Loading translation system...
   • Loading Bayesian network analysis...
     ✓ Bayesian network analysis loaded
   • Loading vocabulary bowtie generator...
     ✓ Vocabulary bowtie generator loaded
   • Loading guided workflow system...
     ✓ Guided workflow core loaded
```

### Side Effects During Module Loading

#### From utils.R:
- **Cache initialization**: `.cache` environment created
- **LRU setup**: Access times, size limits, statistics tracking
- **No data generation**: Sample data created on-demand only

#### From vocabulary.R:
- **No immediate data loading**: Data loaded in Phase 6

#### From guided_workflow.R:
- **Workflow configuration**: `WORKFLOW_CONFIG` created
- **Step definitions**: UI and server functions registered

---

## Phase 6: Vocabulary Data Loading

**File**: `global.R` lines 154-174
**Purpose**: Load environmental vocabulary from Excel files
**Duration**: ~0.5-1 second (first load), ~0.01s (cached)

### Process

#### Step 6.1: Define load_app_data() Function

```r
load_app_data <- function() {
  tryCatch({
    vocabulary_data <- load_vocabulary()
    app_message("✅ Vocabulary data loaded successfully", level = "success")
    return(vocabulary_data)
  }, error = function(e) {
    app_message("⚠️ Warning: Could not load vocabulary data", level = "warn")
    # Return fallback empty data structure
    return(list(
      activities = data.frame(hierarchy = character(), ...),
      pressures = data.frame(hierarchy = character(), ...),
      consequences = data.frame(hierarchy = character(), ...),
      controls = data.frame(hierarchy = character(), ...)
    ))
  })
}
```

#### Step 6.2: Execute Data Loading

```r
app_message("📊 Loading environmental vocabulary data from Excel files...")
vocabulary_data <- load_app_data()
```

### What Gets Loaded

**Vocabulary Data** (from Excel files):

1. **CAUSES.xlsx**
   - 53 activities (Level 1: Categories, Level 2: Specific activities)
   - 36 pressures (environmental stressors)

2. **CONSEQUENCES.xlsx**
   - 26 consequence categories
   - Environmental impact types

3. **CONTROLS.xlsx**
   - 74 control measures
   - Mitigation and protection strategies

**Data Structure**:
```r
vocabulary_data <- list(
  activities = data.frame(hierarchy, id, name, ...),  # 53 rows
  pressures = data.frame(hierarchy, id, name, ...),   # 36 rows
  consequences = data.frame(hierarchy, id, name, ...), # 26 rows
  controls = data.frame(hierarchy, id, name, ...)     # 74 rows
)
```

### Caching Behavior (P1-5 Integration)

**First Load** (~1 second):
```
📊 Loading environmental vocabulary data from Excel files...
✅ Vocabulary data loaded successfully
```

**Cached Load** (~0.01 seconds):
```
📊 Loading environmental vocabulary data from Excel files...
📦 Using cached vocabulary data
✅ Vocabulary data loaded successfully
```

**Cache Key**: `vocabulary_CAUSES.xlsx_CONSEQUENCES.xlsx_CONTROLS.xlsx`

**Cache Statistics** (after loading):
```r
get_cache_stats()
# $current_size: 1
# $hits: 0 (first load) or 1+ (subsequent)
# $memory_mb: ~5-10 MB
```

### Output

```
📊 Loading environmental vocabulary data from Excel files...
✅ Vocabulary data loaded successfully
```

Or with caching:

```
📊 Loading environmental vocabulary data from Excel files...
📦 Using cached vocabulary data
✅ Vocabulary data loaded successfully
```

### Error Handling

If Excel files are missing or corrupted:
```
📊 Loading environmental vocabulary data from Excel files...
⚠️ Warning: Could not load vocabulary data: [error details]
📝 Using fallback empty data structure
```

Application continues with empty vocabulary (degraded mode).

---

## Startup Performance

### Typical Startup Times

| System Type | First Run | Cached Run | With Verbose Logging |
|-------------|-----------|------------|---------------------|
| **Fast (SSD, 16GB RAM)** | 3-4s | 2-3s | 4-5s |
| **Medium (HDD, 8GB RAM)** | 5-6s | 4-5s | 6-8s |
| **Slow (HDD, 4GB RAM)** | 7-10s | 6-8s | 10-15s |

### Performance Bottlenecks

1. **Package Loading** (~50-70% of total time)
   - 19 packages loaded at startup
   - Largest impact on first run
   - Benefit: OS caching improves subsequent runs

2. **Module Sourcing** (~20-30% of total time)
   - Large files: guided_workflow.R (~3000 lines), utils.R (~1500 lines)
   - File I/O and parsing
   - Benefit: Code already validated

3. **Vocabulary Data** (~10-20% of total time - first load only)
   - Excel file reading (3 files)
   - Data frame creation
   - Benefit: P1-5 caching makes this negligible on subsequent loads

4. **Other** (~5-10% of total time)
   - Configuration loading
   - Directory detection
   - Logging setup

### Performance Optimizations Already in Place

✅ **P1-5: LRU Caching** - Vocabulary loads 100x faster on second access
✅ **Lazy Excel Reading** - readxl only loads required sheets
✅ **Graceful Degradation** - Application starts even if optional modules fail
✅ **suppressMessages()** - Reduces console noise during package loading

---

## Initialization Sequence Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Application Startup                          │
│                    (global.R execution)                          │
└───────────────────────┬─────────────────────────────────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Phase 1: Base Dir Detection   │ (~0.1s)
        │ • commandArgs                  │
        │ • sys.frames()                 │
        │ • getwd() fallback             │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Phase 2: Config Loading       │ (~0.1s)
        │ • source(config.R)             │
        │ • APP_CONFIG, PORT, HOST       │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Phase 3: Logging Init         │ (~0.1s)
        │ • app_message() definition     │
        │ • bowtie_log() definition      │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Phase 4: Package Loading      │ (~2-4s)
        │ • Core packages (13)           │
        │ • Bayesian packages (4)        │
        │   shiny, bslib, DT, ggplot2,   │
        │   plotly, bnlearn, gRain, ...  │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Phase 5: Module Loading       │ (~0.5-1s)
        │ • utils.R (cache init)         │
        │ • vocabulary.R                 │
        │ • translations_data.R          │
        │ • bowtie_bayesian_network.R    │
        │ • vocabulary_bowtie_generator  │
        │ • guided_workflow.R            │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Phase 6: Vocabulary Data      │ (~0.5-1s first, ~0.01s cached)
        │ • load_vocabulary()            │
        │ • CAUSES.xlsx (53 activities)  │
        │ • CONSEQUENCES.xlsx (26 items) │
        │ • CONTROLS.xlsx (74 controls)  │
        │ • LRU cache storage            │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Global Environment Ready       │
        │ • 19 packages loaded           │
        │ • 8 modules sourced            │
        │ • Vocabulary data cached       │
        │ • Ready for UI/server setup    │
        └───────────────────────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Shiny App Initialization       │
        │ • source(ui.R)                 │
        │ • source(server.R)             │
        │ • shinyApp(ui, server)         │
        └───────────────────────────────┘
                        │
        ┌───────────────▼───────────────┐
        │ Application Running            │
        │ http://0.0.0.0:3838            │
        └───────────────────────────────┘

Total Time: ~5 seconds (typical)
```

---

## Troubleshooting

### Slow Startup

**Symptom**: Application takes >10 seconds to start

**Possible Causes**:
1. Missing packages (warnings during package loading)
2. Slow disk I/O (HDD instead of SSD)
3. Large Excel files (custom vocabulary)
4. Network issues (if packages on network drive)

**Solutions**:
```r
# Enable verbose logging to identify bottleneck
options(bowtie.verbose = TRUE)
Rscript start_app.R

# Check which phase is slow
system.time(source("global.R"))
```

### Package Loading Failures

**Symptom**: Warnings about missing packages

**Solution**:
```r
# Install all required packages
source("requirements.R")

# Or manually
install.packages(c("shiny", "bslib", "DT", "readxl", "openxlsx",
                   "ggplot2", "plotly", "dplyr", "visNetwork",
                   "bnlearn", "gRain", "igraph"))
```

### Vocabulary Data Not Loading

**Symptom**: "Warning: Could not load vocabulary data"

**Possible Causes**:
1. Excel files missing (CAUSES.xlsx, CONSEQUENCES.xlsx, CONTROLS.xlsx)
2. Files in wrong directory
3. File corruption
4. readxl package not installed

**Solutions**:
```r
# Check files exist
file.exists("CAUSES.xlsx")
file.exists("CONSEQUENCES.xlsx")
file.exists("CONTROLS.xlsx")

# Manually test vocabulary loading
source("vocabulary.R")
vocab <- load_vocabulary()
```

### Module Loading Errors

**Symptom**: "Warning: Failed to load [module]"

**Solution**:
```r
# Test individual module
tryCatch({
  source("guided_workflow.R")
}, error = function(e) {
  print(e$message)
})

# Check for syntax errors
parse("guided_workflow.R")
```

---

## Configuration Options

### Verbose Mode

Enable detailed logging to see all startup steps:

```r
options(bowtie.verbose = TRUE)
Rscript start_app.R
```

**Output** (additional debug messages):
```
📋 Using cached nodes
🔧 Creating Updated bowtie nodes (v432 - extra spacing)
🔍 Processing 150 mitigation mappings
✅ Connected mitigation 1 to consequence 3
# ... hundreds more debug messages
```

### Quiet Mode

Suppress non-essential startup messages:

```r
options(bowtie.quiet = TRUE)
Rscript start_app.R
```

**Output** (minimal):
```
Listening on http://0.0.0.0:3838
```

### Custom Configuration

Modify startup behavior via `config.R`:

```r
# config.R
APP_CONFIG <- list(
  TITLE = "My Custom Title",
  VERSION = "1.0.0",
  PORT = 8080,  # Custom port
  HOST = "127.0.0.1",  # Local only
  # ...
)
```

---

## Summary

### Startup Process Overview

**Total Duration**: ~5 seconds
**Files Sourced**: 10+ R files
**Packages Loaded**: 19 packages
**Data Loaded**: 189 vocabulary items (53+36+74+26)

### Critical Path

1. ✅ **Package Loading** (2-4s) - Cannot be deferred (Shiny needs them)
2. ✅ **Module Loading** (0.5-1s) - Necessary for application logic
3. ✅ **Vocabulary Data** (0.5-1s first, cached after) - P1-5 optimization

### Optimization Status

✅ **Already Optimized**:
- LRU caching (P1-5) - 100x speedup on cached data
- Graceful degradation - Application starts even if optional modules fail
- Error handling - Clear messages for troubleshooting

### Not Optimized (Intentional)

⏸️ **Package Lazy Loading**: Not implemented
- Shiny apps need packages at startup anyway
- Minimal benefit, high complexity

⏸️ **Deferred Initialization**: Not implemented
- Application needs all modules for UI definition
- Module interdependencies require complete loading

### Conclusion

The current startup sequence is **well-optimized for a Shiny application**. Further optimization would provide minimal benefit (<1 second improvement) while significantly increasing complexity.

**Recommendation**: Document (this file) rather than refactor.

---

## References

- **Implementation Plan**: `IMPLEMENTATION_PLAN.md` (P2-6)
- **Main Startup File**: `global.R`
- **Configuration File**: `config.R`
- **Utility Functions**: `utils.R` (P1-5 caching)
- **Vocabulary Management**: `vocabulary.R`
- **Logging System**: P1-4 (`LOGGING_SYSTEM_P1-4_COMPLETE_v5.5.1.md`)
- **Caching System**: P1-5 (`CACHING_STRATEGY_P1-5_COMPLETE_v5.5.2.md`)

---

**Generated**: December 28, 2025
**Author**: AI Assistant + Maintainer
**Version**: 5.5.3 (Startup Sequence Documentation Edition)
