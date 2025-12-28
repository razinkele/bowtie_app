# Future Improvements & Enhancement Opportunities
**Environmental Bowtie Risk Analysis Application**
**Date**: 2025-12-28
**Current Version**: 5.5.1

---

## 📋 Overview

This document outlines potential improvements, enhancements, and optimizations for the Environmental Bowtie Risk Analysis application. Items are organized by category and priority level.

**Priority Levels**:
- **P0**: Critical - Should be done ASAP
- **P1**: High - Should be done soon
- **P2**: Medium - Nice to have
- **P3**: Low - Future consideration

---

## 🚀 From IMPLEMENTATION_PLAN.md (Remaining Tasks)

### **P1 - High Priority**

#### **P1-3: Add CI Checks for Code Quality & Performance** (1-2 days)
**Status**: Not started
**Effort**: Medium

**What**:
- Add GitHub Actions workflow for automated testing
- Run `utils/code_quality_check.R` in CI
- Add lintr for code style checking
- Performance baseline tests to detect regressions
- Multi-version R testing (4.1, 4.2, 4.3, 4.4)
- Multi-platform testing (Ubuntu, Windows, macOS)

**Files to Create**:
- `.github/workflows/ci.yml` - Main CI pipeline
- `.github/workflows/performance.yml` - Performance regression tests
- `.lintr` - Linting configuration

**Benefits**:
- Catch bugs before they reach production
- Ensure code quality standards
- Detect performance regressions automatically
- Platform compatibility verification

**Implementation Notes**:
```yaml
# .github/workflows/ci.yml example
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
        r-version: ['4.2', '4.3', '4.4']
    steps:
      - uses: actions/checkout@v3
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: ${{ matrix.r-version }}
      - name: Install dependencies
        run: Rscript -e 'install.packages(c("shiny", "testthat", ...))'
      - name: Run tests
        run: Rscript tests/test_runner.R
      - name: Code quality check
        run: Rscript utils/code_quality_check.R
```

---

#### **P1-5: Audit & Harden Caching Strategy** (2-4 days)
**Status**: Not started
**Effort**: Large

**What**:
- Audit all caching mechanisms (`.cache`, `.vocabulary_cache`)
- Implement LRU (Least Recently Used) eviction
- Add cache size limits
- Add cache clear points tied to data updates
- Add cache performance metrics
- Document caching behavior

**Current Issues**:
- Caches can grow unbounded
- No automatic cleanup
- Cache invalidation not tied to data changes
- No monitoring of cache effectiveness

**Proposed Solutions**:

1. **Create Centralized Cache Manager**:
```r
# New file: cache_manager.R
CacheManager <- R6::R6Class("CacheManager",
  public = list(
    max_size = 100,  # Maximum cache entries
    max_age = 3600,  # Maximum age in seconds

    get = function(key) {
      # Get with LRU tracking
    },

    set = function(key, value) {
      # Set with automatic eviction
    },

    clear = function() {
      # Clear all caches
    },

    stats = function() {
      # Cache hit/miss statistics
    }
  )
)
```

2. **Add Cache Monitoring**:
```r
cache_stats <- function() {
  list(
    size = length(.cache),
    hits = .perf$cache_hits %||% 0,
    misses = .perf$cache_misses %||% 0,
    hit_rate = hits / (hits + misses)
  )
}
```

3. **Tie Cache Clearing to Data Updates**:
```r
observeEvent(input$upload_new_data, {
  clear_all_caches()  # Invalidate when data changes
  app_message("Caches cleared due to data update")
})
```

**Benefits**:
- Predictable memory usage
- Better performance monitoring
- Automatic cache invalidation
- More robust caching system

---

### **P2 - Medium Priority**

#### **P2-6: Reduce Startup Side-Effects** (3-7 days)
**Status**: Not started
**Effort**: Large

**What**:
- Move heavy `source()` operations into lazy loading
- Create initialization routine instead of side-effects at source
- Allow modules to be loaded in isolation
- Document startup sequence
- Reduce initial memory footprint

**Current Issues**:
- Many files execute code when sourced
- Heavy computations during startup
- Difficult to test modules in isolation
- Circular dependencies possible

**Proposed Solutions**:

1. **Create Init System**:
```r
# New file: init.R
init_application <- function(modules = "all", verbose = FALSE) {
  if (verbose) options(bowtie.verbose = TRUE)

  if ("all" %in% modules || "vocabulary" %in% modules) {
    init_vocabulary()
  }

  if ("all" %in% modules || "guided_workflow" %in% modules) {
    init_guided_workflow()
  }

  # etc...
}
```

2. **Lazy Module Loading**:
```r
# Instead of sourcing everything at startup
get_vocabulary_module <- local({
  .module <- NULL
  function() {
    if (is.null(.module)) {
      source("vocabulary.R", local = TRUE)
      .module <<- environment()
    }
    .module
  }
})
```

3. **Document Startup**:
```r
# Startup sequence documentation
# 1. config.R - Load configuration
# 2. utils.R - Load utilities (no side effects)
# 3. vocabulary.R - Load vocab functions (no data loading)
# 4. init_application() - Initialize data and modules
```

**Benefits**:
- Faster startup time
- Testable modules
- Clearer dependencies
- Reduced memory usage

---

#### **P2-7: Pre-commit Hooks & Contributor Docs** (0.5-1 day)
**Status**: Not started
**Effort**: Small

**What**:
- Configure pre-commit hooks for linting
- Run unit tests before commit
- Style checking
- Create CONTRIBUTING.md
- Update developer documentation

**Files to Create**:
- `.pre-commit-config.yaml` - Pre-commit configuration
- `CONTRIBUTING.md` - Contributor guidelines
- `docs/DEVELOPMENT.md` - Development setup guide

**Example Pre-commit Hook**:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: r-lintr
        name: R lintr
        entry: Rscript -e 'lintr::lint_dir()'
        language: system
        files: \\.R$

      - id: r-tests
        name: R unit tests
        entry: Rscript tests/test_runner.R
        language: system
        pass_filenames: false
```

**Benefits**:
- Catch issues before commit
- Consistent code style
- Faster code reviews
- Easier onboarding

---

### **P3 - Low Priority**

#### **P3-8: Archive Cleanup** (0.5 day)
**Status**: Not started
**Effort**: Small

**What**:
- Move backup files to `/archive/` directory
- Remove `*.R.backup` from root
- Update references in documentation
- Add `.gitignore` rules for backups

**Current Issues**:
- `server.R.backup`, `ui.R.backup` in root directory
- Confusing for new developers
- Git history cluttered

**Proposed Structure**:
```
/archive/
  /backups/
    server.R.backup
    ui.R.backup
  /old-versions/
    app_fixed.r
    bowtie_bayesian_network_safe.r
  /development/
    (old development files)
```

**Benefits**:
- Cleaner repository
- Clear archive policy
- Better organization

---

## 🎨 User Experience Improvements

### **UX-1: Add Progress Indicators** (P1, 2-3 days)

**What**:
- Add loading spinners during data processing
- Progress bars for long operations
- Status messages during workflow completion
- Better feedback for user actions

**Implementation**:
```r
# Use shiny's built-in progress
withProgress(message = 'Processing data...', value = 0, {
  for (i in 1:n) {
    incProgress(1/n, detail = paste("Processing row", i))
    # ... do work ...
  }
})

# Or use shinycssloaders (already installed)
plotlyOutput("bowtie_plot") %>% withSpinner(type = 6)
```

**Benefits**:
- Better user experience
- Prevents "is it frozen?" questions
- Professional appearance

---

### **UX-2: Add Tooltips & Help Text** (P2, 1-2 days)

**What**:
- Add tooltips explaining technical terms
- Inline help for complex features
- Contextual guidance in guided workflow
- Glossary of environmental terms

**Implementation**:
```r
# Using bslib tooltips
tooltip(
  actionButton("analyze", "Run Analysis"),
  "Click to start Bayesian network analysis of your bowtie diagram"
)

# Or custom help icons
helpText(icon("info-circle"), "Controls are measures that reduce risk...")
```

**Benefits**:
- Easier for new users
- Reduced support burden
- Self-documenting interface

---

### **UX-3: Keyboard Shortcuts** (P3, 1 day)

**What**:
- Keyboard shortcuts for common actions
- Navigate workflow steps with arrow keys
- Quick save/export shortcuts
- Accessibility improvements

**Implementation**:
```js
// In ui.R or custom.js
$(document).on('keydown', function(e) {
  if (e.ctrlKey && e.key === 's') {
    e.preventDefault();
    Shiny.setInputValue('keyboard_save', Math.random());
  }
});
```

**Benefits**:
- Power user efficiency
- Accessibility compliance
- Professional feel

---

### **UX-4: Undo/Redo Functionality** (P2, 3-4 days)

**What**:
- Undo/redo for guided workflow actions
- History of workflow state changes
- Ability to restore previous states
- Non-destructive editing

**Implementation**:
```r
# State history stack
workflow_history <- reactiveVal(list())

# Save state before changes
save_state_snapshot <- function() {
  history <- workflow_history()
  history[[length(history) + 1]] <- current_state()
  workflow_history(history)
}

# Undo action
observeEvent(input$undo, {
  history <- workflow_history()
  if (length(history) > 1) {
    restore_state(history[[length(history)]])
    workflow_history(history[-length(history)])
  }
})
```

**Benefits**:
- User confidence
- Exploration without fear
- Reduces need for "are you sure?" dialogs

---

## ⚡ Performance Optimizations

### **PERF-1: Lazy Data Loading** (P1, 2-3 days)

**What**:
- Load vocabulary data only when needed
- Paginate large data tables
- Load visualizations on-demand
- Incremental rendering

**Current Issues**:
- All vocabulary data loaded at startup (189 items)
- Large data tables render all rows
- All visualizations created even if not viewed

**Implementation**:
```r
# Lazy vocabulary loading
get_vocabulary <- local({
  .vocab <- NULL
  function(force_reload = FALSE) {
    if (is.null(.vocab) || force_reload) {
      .vocab <<- load_vocabulary()
    }
    .vocab
  }
})

# Paginated data tables (already using DT, optimize settings)
DT::datatable(data,
  options = list(
    pageLength = 25,
    lengthMenu = c(10, 25, 50, 100),
    deferRender = TRUE,  # Render only visible rows
    scroller = TRUE      # Virtual scrolling
  )
)
```

**Benefits**:
- Faster startup
- Lower memory usage
- Responsive interface

---

### **PERF-2: Optimize Vocabulary Search** (P2, 1-2 days)

**What**:
- Index vocabulary data for faster searching
- Use data.table for large datasets
- Cache search results
- Fuzzy matching optimization

**Implementation**:
```r
# Index vocabulary data
library(data.table)
vocab_index <- data.table(vocabulary_data$activities)
setkey(vocab_index, name, id)

# Fast search
search_vocabulary_fast <- function(term) {
  vocab_index[name %like% term | id %like% term]
}

# Fuzzy matching with caching
search_fuzzy <- memoise::memoise(function(term, data) {
  agrep(term, data$name, max.distance = 0.2, value = FALSE)
})
```

**Benefits**:
- Instant search results
- Better user experience
- Scales to larger vocabularies

---

### **PERF-3: Async Processing** (P2, 3-5 days)

**What**:
- Async/background processing for long operations
- Progress reporting from background tasks
- Non-blocking UI during computation
- Use promises or future package

**Implementation**:
```r
library(promises)
library(future)
plan(multisession)  # Enable parallel processing

# Async bowtie generation
generate_bowtie_async <- function(data) {
  future_promise({
    generate_bowtie(data)
  }) %...>% {
    # Success handler
    showNotification("Bowtie generated!", type = "message")
  } %...!% {
    # Error handler
    showNotification("Error generating bowtie", type = "error")
  }
}
```

**Benefits**:
- Responsive UI
- Utilize multiple CPU cores
- Better for large datasets

---

### **PERF-4: Database Backend** (P3, 1-2 weeks)

**What**:
- Replace Excel files with SQLite/PostgreSQL
- Faster queries and filtering
- Support larger datasets
- Better concurrent access

**Implementation**:
```r
library(DBI)
library(RSQLite)

# Create DB connection
con <- dbConnect(SQLite(), "bowtie_data.db")

# Load vocabulary from DB
load_vocabulary_db <- function() {
  list(
    activities = dbGetQuery(con, "SELECT * FROM activities"),
    pressures = dbGetQuery(con, "SELECT * FROM pressures"),
    controls = dbGetQuery(con, "SELECT * FROM controls"),
    consequences = dbGetQuery(con, "SELECT * FROM consequences")
  )
}

# Fast filtering
get_controls_by_category <- function(category) {
  dbGetQuery(con,
    "SELECT * FROM controls WHERE category = ?",
    params = list(category)
  )
}
```

**Benefits**:
- Scales to thousands of items
- Faster queries
- Atomic updates
- Multi-user support

---

## 🧪 Testing Improvements

### **TEST-1: Increase Test Coverage** (P1, 3-5 days)

**What**:
- Achieve 90%+ code coverage
- Add integration tests for workflows
- Add UI tests with shinytest2
- Test edge cases and error conditions

**Current Coverage**:
- Unit tests: ~70%
- Integration tests: Limited
- UI tests: None

**Implementation**:
```r
# shinytest2 for UI testing
library(shinytest2)

test_that("Guided workflow completes successfully", {
  app <- AppDriver$new()

  # Navigate to guided workflow
  app$click("guided_workflow_tab")

  # Complete step 1
  app$set_inputs(project_name = "Test Project")
  app$click("next_step")

  # Verify navigation
  expect_equal(app$get_value("current_step"), 2)
})

# More unit tests for edge cases
test_that("format_tree_display handles empty data", {
  result <- format_tree_display(data.frame())
  expect_equal(length(result), 0)
})

test_that("format_tree_display handles NA values", {
  data <- data.frame(level = NA, name = "Test", id = "T1")
  result <- format_tree_display(data)
  expect_true(length(result) == 1)
  expect_false(grepl("NA", result))
})
```

**Benefits**:
- Catch regressions
- Confidence in refactoring
- Documentation through tests

---

### **TEST-2: Performance Regression Tests** (P1, 1-2 days)

**What**:
- Automated performance benchmarks
- Track performance over time
- Alert on regressions
- Memory usage monitoring

**Implementation**:
```r
# tests/performance/benchmark_suite.R
library(microbenchmark)

# Baseline benchmarks
benchmarks <- list(
  vocabulary_load = microbenchmark(
    load_vocabulary(),
    times = 100
  ),

  bowtie_generation = microbenchmark(
    generate_bowtie_data(sample_data),
    times = 50
  ),

  search = microbenchmark(
    search_vocabulary("pollution"),
    times = 1000
  )
)

# Check against baselines
baseline_times <- read.csv("tests/performance/baseline.csv")
check_regression(benchmarks, baseline_times, threshold = 1.2)
```

**Benefits**:
- Prevent performance regressions
- Optimize slow operations
- Track improvements over time

---

### **TEST-3: Load Testing** (P3, 2-3 days)

**What**:
- Simulate multiple concurrent users
- Test under heavy load
- Identify bottlenecks
- Memory leak detection

**Implementation**:
```r
# Using shinyloadtest
library(shinyloadtest)

# Record user session
record_session("http://localhost:3838")

# Run load test
results <- load_test(
  url = "http://localhost:3838",
  duration = 300,  # 5 minutes
  workers = 10
)

# Analyze results
analyze_results(results)
```

**Benefits**:
- Know scalability limits
- Plan infrastructure
- Prevent crashes under load

---

## 🔒 Security & Robustness

### **SEC-1: Input Validation** (P1, 2-3 days)

**What**:
- Comprehensive input validation
- Sanitize user inputs
- Validate file uploads
- Prevent code injection

**Current Issues**:
- Some inputs not validated
- File upload size limits not enforced
- Potential for malformed data

**Implementation**:
```r
# Validation helpers
validate_project_name <- function(name) {
  if (is.null(name) || nchar(name) == 0) {
    stop("Project name cannot be empty")
  }
  if (nchar(name) > 100) {
    stop("Project name too long (max 100 characters)")
  }
  if (grepl("[<>:\"/\\|?*]", name)) {
    stop("Project name contains invalid characters")
  }
  name
}

# File upload validation
validate_upload <- function(file_info) {
  # Check file size (max 10MB)
  if (file_info$size > 10 * 1024^2) {
    stop("File too large (max 10MB)")
  }

  # Check file type
  allowed_types <- c(".xlsx", ".xls", ".csv", ".rds")
  ext <- tools::file_ext(file_info$name)
  if (!paste0(".", ext) %in% allowed_types) {
    stop("Invalid file type. Allowed: ", paste(allowed_types, collapse = ", "))
  }

  TRUE
}
```

**Benefits**:
- Prevent crashes
- Security hardening
- Better error messages

---

### **SEC-2: Error Boundaries** (P2, 1-2 days)

**What**:
- Graceful error handling
- User-friendly error messages
- Error logging
- Recovery from errors

**Implementation**:
```r
# Global error handler
safe_render <- function(expr, fallback = NULL) {
  tryCatch(
    expr,
    error = function(e) {
      bowtie_log("Error in render:", e$message, level = "error")

      # Show user-friendly message
      showNotification(
        "An error occurred. Please try again or contact support.",
        type = "error",
        duration = NULL
      )

      # Return fallback
      fallback
    }
  )
}

# Use in renders
output$bowtie_plot <- renderPlotly({
  safe_render({
    create_bowtie_plot(data())
  }, fallback = plotly_empty())
})
```

**Benefits**:
- Application doesn't crash
- Better debugging
- User confidence

---

### **SEC-3: Rate Limiting** (P3, 1 day)

**What**:
- Limit expensive operations
- Prevent abuse
- Throttle API calls
- Session timeouts

**Implementation**:
```r
# Rate limiter
library(ratelimitr)

generate_bowtie_limited <- limit_rate(
  generate_bowtie,
  rate = rate(n = 10, period = 60)  # 10 per minute
)

# In server
observeEvent(input$generate, {
  tryCatch({
    result <- generate_bowtie_limited(data())
    output$result <- renderPlot(result)
  }, error = function(e) {
    if (grepl("rate limit", e$message)) {
      showNotification("Too many requests. Please wait.", type = "warning")
    }
  })
})
```

**Benefits**:
- Prevent server overload
- Fair resource usage
- Cost control

---

## 📊 Data & Analytics

### **DATA-1: Export Enhancements** (P2, 2-3 days)

**What**:
- Multiple export formats (CSV, JSON, PDF)
- Customizable export templates
- Batch export functionality
- Export quality settings

**Implementation**:
```r
# Export to multiple formats
export_bowtie <- function(data, format = c("xlsx", "csv", "json", "pdf")) {
  format <- match.arg(format)

  switch(format,
    xlsx = export_to_excel(data),
    csv = export_to_csv(data),
    json = export_to_json(data),
    pdf = export_to_pdf_report(data)
  )
}

# PDF report generation
export_to_pdf_report <- function(data) {
  rmarkdown::render(
    "templates/bowtie_report.Rmd",
    params = list(bowtie_data = data),
    output_file = tempfile(fileext = ".pdf")
  )
}
```

**Benefits**:
- Flexibility
- Integration with other tools
- Professional reports

---

### **DATA-2: Data Versioning** (P2, 3-4 days)

**What**:
- Track changes to bowtie diagrams
- Version history
- Diff between versions
- Restore previous versions

**Implementation**:
```r
# Version tracking
save_version <- function(data, comment = "") {
  version <- list(
    timestamp = Sys.time(),
    data = data,
    comment = comment,
    hash = digest::digest(data)
  )

  # Save to version history
  versions <- read_versions() %||% list()
  versions[[length(versions) + 1]] <- version
  saveRDS(versions, "data/version_history.rds")
}

# View version history
get_version_history <- function() {
  versions <- read_versions()
  data.frame(
    version = seq_along(versions),
    timestamp = sapply(versions, `[[`, "timestamp"),
    comment = sapply(versions, `[[`, "comment")
  )
}
```

**Benefits**:
- Audit trail
- Recover from mistakes
- Collaborative work

---

### **DATA-3: Data Validation Rules** (P1, 2-3 days)

**What**:
- Custom validation rules for bowtie data
- Consistency checks
- Business logic validation
- Warning system for potential issues

**Implementation**:
```r
# Validation framework
validate_bowtie_data <- function(data) {
  errors <- list()
  warnings <- list()

  # Rule 1: Every pressure must have at least one control
  pressures_without_controls <- data %>%
    filter(is.na(Preventive_Control)) %>%
    pull(Pressure) %>%
    unique()

  if (length(pressures_without_controls) > 0) {
    warnings$unprotected_pressures <- paste(
      "Pressures without controls:",
      paste(pressures_without_controls, collapse = ", ")
    )
  }

  # Rule 2: Central problem must be consistent
  problems <- unique(data$Central_Problem)
  if (length(problems) > 1) {
    errors$multiple_problems <- paste(
      "Multiple central problems found:",
      paste(problems, collapse = ", ")
    )
  }

  # Rule 3: All consequences should have mitigations
  consequences_without_mitigations <- data %>%
    filter(is.na(Protective_Mitigation)) %>%
    pull(Consequence) %>%
    unique()

  if (length(consequences_without_mitigations) > 0) {
    warnings$unmitigated_consequences <- paste(
      "Consequences without mitigations:",
      paste(consequences_without_mitigations, collapse = ", ")
    )
  }

  list(
    valid = length(errors) == 0,
    errors = errors,
    warnings = warnings
  )
}
```

**Benefits**:
- Data quality
- Catch mistakes early
- Professional analysis

---

## 🎨 Visualization Improvements

### **VIZ-1: Interactive Bowtie Customization** (P2, 3-4 days)

**What**:
- Drag-and-drop node positioning
- Custom colors for nodes
- Adjustable edge thickness
- Hide/show node groups
- Zoom and pan controls

**Implementation**:
```r
# Enhanced visNetwork options
visNetwork(nodes, edges) %>%
  visOptions(
    manipulation = list(
      enabled = TRUE,
      initiallyActive = FALSE
    ),
    interaction = list(
      dragNodes = TRUE,
      dragView = TRUE,
      zoomView = TRUE
    )
  ) %>%
  visInteraction(
    navigationButtons = TRUE,
    keyboard = TRUE
  ) %>%
  visLayout(randomSeed = 123)  # Reproducible layout
```

**Benefits**:
- Customizable visualizations
- Better presentations
- Clearer diagrams

---

### **VIZ-2: Multiple Layout Algorithms** (P3, 1-2 days)

**What**:
- Different layout options (hierarchical, force-directed, circular)
- Auto-layout based on diagram complexity
- Save/restore layouts
- Export layout configurations

**Implementation**:
```r
# Layout selector
selectInput("layout", "Layout Algorithm",
  choices = c(
    "Hierarchical" = "hierarchical",
    "Force-directed" = "forceAtlas2Based",
    "Circular" = "circular",
    "Grid" = "grid"
  )
)

# Apply layout
output$bowtie <- renderVisNetwork({
  visNetwork(nodes(), edges()) %>%
    visHierarchicalLayout(
      enabled = input$layout == "hierarchical",
      direction = "LR"
    )
})
```

**Benefits**:
- Visual clarity
- Presentation options
- User preference

---

### **VIZ-3: Real-time Collaboration** (P3, 2+ weeks)

**What**:
- Multiple users editing same bowtie
- See other users' cursors
- Conflict resolution
- Chat/comments

**Implementation**:
(This is a major feature requiring WebSocket integration, operational transformation, etc.)

**Benefits**:
- Team collaboration
- Faster workflow development
- Remote teamwork

---

## 🌍 Internationalization & Accessibility

### **I18N-1: Complete Translation System** (P2, 1-2 weeks)

**Current**: Partial translation support exists
**What**:
- Translate all UI text
- Support multiple languages (EN, FR, ES, etc.)
- Language selector
- RTL language support
- Locale-specific formatting

**Implementation**:
```r
# Expand translations_data.R
translations <- list(
  en = list(
    app_title = "Environmental Bowtie Risk Analysis",
    guided_workflow = "Guided Workflow",
    # ... all UI strings
  ),
  fr = list(
    app_title = "Analyse des Risques Environnementaux Bowtie",
    guided_workflow = "Flux de Travail Guidé",
    # ... all UI strings
  ),
  es = list(
    app_title = "Análisis de Riesgos Ambientales Bowtie",
    guided_workflow = "Flujo de Trabajo Guiado",
    # ... all UI strings
  )
)

# Translation function
t <- function(key, lang = getOption("bowtie.language", "en")) {
  translations[[lang]][[key]] %||% key
}

# Use in UI
titlePanel(t("app_title"))
```

**Benefits**:
- International users
- Market expansion
- Professional appearance

---

### **A11Y-1: Accessibility Compliance** (P1, 2-3 days)

**What**:
- WCAG 2.1 AA compliance
- Screen reader support
- Keyboard navigation
- High contrast mode
- Focus indicators
- ARIA labels

**Implementation**:
```r
# Accessible buttons
actionButton("analyze",
  "Run Analysis",
  icon = icon("play"),
  `aria-label` = "Run bowtie analysis",
  class = "btn-primary"
)

# Skip navigation links
tags$a(
  href = "#main-content",
  class = "skip-link",
  "Skip to main content"
)

# Semantic HTML
tags$nav(role = "navigation", ...)
tags$main(id = "main-content", role = "main", ...)

# Focus management
observeEvent(input$next_step, {
  runjs("$('#step-content').focus()")
})
```

**Benefits**:
- Legal compliance
- Inclusive design
- Better UX for everyone

---

## 📱 Mobile & Responsive

### **MOBILE-1: Responsive Design** (P2, 3-5 days)

**What**:
- Mobile-friendly layouts
- Touch-optimized controls
- Responsive visualizations
- Offline capability (PWA)

**Implementation**:
```r
# Responsive layouts with bslib
page_fluid(
  theme = bs_theme(version = 5),

  layout_columns(
    col_widths = c(12, 12, 6, 6),  # Mobile, tablet, desktop

    card(...),  # Full width on mobile
    card(...)   # Full width on mobile, half on desktop
  )
)

# Mobile detection
is_mobile <- reactive({
  session$clientData$pixelratio > 1 &&
  session$clientData$output_bowtie_width < 768
})

# Conditional rendering
output$controls <- renderUI({
  if (is_mobile()) {
    # Mobile-optimized controls
    column(12, ...)
  } else {
    # Desktop controls
    column(3, ...)
  }
})
```

**Benefits**:
- Mobile accessibility
- Field work support
- Broader user base

---

## 🔧 Developer Experience

### **DEV-1: Developer Documentation** (P1, 2-3 days)

**What**:
- Architecture documentation
- API documentation
- Contributing guide
- Code examples
- Development setup guide

**Files to Create**:
- `docs/ARCHITECTURE.md` - System architecture
- `docs/API.md` - Function documentation
- `docs/CONTRIBUTING.md` - How to contribute
- `docs/EXAMPLES.md` - Code examples
- `docs/DEVELOPMENT.md` - Dev environment setup

**Benefits**:
- Easier onboarding
- Better contributions
- Maintainability

---

### **DEV-2: Hot Reload for Development** (P3, 1 day)

**What**:
- Auto-reload on file changes
- Live code reloading
- Preserve session state during reload
- Dev mode toggle

**Implementation**:
```r
# dev_tools.R
if (Sys.getenv("SHINY_DEV_MODE") == "true") {
  library(reactlog)
  reactlog_enable()

  # File watcher
  library(later)

  watch_files <- function() {
    files <- list.files(pattern = "\\.R$", full.names = TRUE)
    mtimes <- file.mtime(files)

    later(function() {
      new_mtimes <- file.mtime(files)
      if (!identical(mtimes, new_mtimes)) {
        session$reload()
      }
      watch_files()
    }, delay = 1)
  }

  watch_files()
}
```

**Benefits**:
- Faster development
- Immediate feedback
- Better DX

---

### **DEV-3: API for External Integration** (P3, 1-2 weeks)

**What**:
- REST API for bowtie operations
- Programmatic access
- Webhook support
- API documentation

**Implementation**:
```r
# Using plumber
library(plumber)

#* @apiTitle Bowtie Risk Analysis API
#* @apiDescription API for environmental bowtie analysis

#* Generate bowtie diagram
#* @param central_problem The central problem
#* @post /api/bowtie/generate
function(central_problem, req, res) {
  result <- generate_bowtie_data(central_problem)
  return(result)
}

#* Get vocabulary
#* @param type Type of vocabulary (activities, pressures, etc.)
#* @get /api/vocabulary/<type>
function(type) {
  vocabulary_data[[type]]
}

# Run API server
pr <- plumb("api.R")
pr$run(port = 8000)
```

**Benefits**:
- Integration with other systems
- Automation
- Programmatic access

---

## 🎯 Summary of Priorities

### **Should Do Soon** (P0-P1):

1. ✅ **DONE**: P0-1 Filename normalization
2. ✅ **DONE**: P0-2 Central_Problem naming
3. ✅ **DONE**: P1-4 Centralized logging
4. **P1-3**: CI/CD pipeline (1-2 days)
5. **P1-5**: Cache hardening (2-4 days)
6. **TEST-1**: Increase test coverage (3-5 days)
7. **PERF-1**: Lazy data loading (2-3 days)
8. **SEC-1**: Input validation (2-3 days)
9. **DATA-3**: Data validation rules (2-3 days)
10. **A11Y-1**: Accessibility compliance (2-3 days)

### **Nice to Have** (P2):

11. **P2-6**: Reduce startup side-effects (3-7 days)
12. **UX-1**: Progress indicators (2-3 days)
13. **UX-2**: Tooltips & help (1-2 days)
14. **PERF-2**: Optimize search (1-2 days)
15. **DATA-1**: Export enhancements (2-3 days)
16. **VIZ-1**: Interactive customization (3-4 days)
17. **I18N-1**: Complete translations (1-2 weeks)
18. **MOBILE-1**: Responsive design (3-5 days)

### **Future Consideration** (P3):

19. **P3-8**: Archive cleanup (0.5 day)
20. **UX-3**: Keyboard shortcuts (1 day)
21. **PERF-4**: Database backend (1-2 weeks)
22. **VIZ-2**: Multiple layouts (1-2 days)
23. **DEV-2**: Hot reload (1 day)

---

**Total Estimated Effort**:
- **P0-P1**: ~15-25 days
- **P2**: ~20-35 days
- **P3**: ~15-25 days
- **Grand Total**: ~50-85 days of development work

---

**Last Updated**: 2025-12-28
**Version**: 1.0
**Author**: Claude Code Assistant
