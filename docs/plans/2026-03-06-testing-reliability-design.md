# Testing & Reliability Improvement Plan

**Date:** 2026-03-06
**Version:** 1.0
**Status:** Approved
**Approach:** Fix-First (Approach A)

## Executive Summary

This design document outlines a systematic plan to improve testing infrastructure and reliability for the Environmental Bowtie Risk Analysis application. The current test coverage is estimated at ~15%, with 13 server modules completely untested and a broken test runner. This plan addresses these gaps through infrastructure fixes, priority module testing, coverage tooling, and CI/CD integration.

## Current State Analysis

### Test Infrastructure Issues

| Issue | Severity | Impact |
|-------|----------|--------|
| `comprehensive_test_runner.R` line 74 bug | Critical | Tests don't actually execute |
| 13 server modules untested | Critical | 200+ KB of business logic unvalidated |
| No code coverage metrics | High | Cannot track improvement progress |
| No CI/CD integration | High | No automated quality gates |
| Test isolation issues | Medium | Flaky tests, resource leaks |

### Coverage Gaps by Module

**Untested Server Modules (13 total, 234KB):**
- `local_storage_module.R` (39KB) - Data persistence
- `report_generation_module.R` (28KB) - Report exports
- `link_risk_module.R` (25KB) - Risk assessment
- `bayesian_module.R` (21KB) - Bayesian network UI
- `vocabulary_server_module.R` (20KB) - Vocabulary CRUD
- `help_module.R` (19KB) - Documentation
- `autosave_module.R` (18KB) - Auto-save logic
- `ai_analysis_module.R` (17KB) - AI suggestions
- `bowtie_visualization_module.R` (14KB) - Diagram rendering
- `data_management_module.R` (10KB) - Data CRUD
- `export_module.R` (9KB) - Export functionality
- `theme_module.R` (9KB) - Theme switching
- `language_module.R` (4KB) - i18n

**Partially Tested Modules:**
- `guided_workflow.R` - Good coverage (~800 lines of tests)
- `utils.R` - Moderate coverage (~450 lines of tests)
- `bayesian_network.R` - Good coverage (~600 lines of tests)

---

## Section 1: Infrastructure Fixes

### 1.1 Fix `comprehensive_test_runner.R`

**Problem:** Line 74 has a variable shadowing bug where `test_file` parameter shadows the `test_file()` function.

**Current (broken):**
```r
test_results <- test_file(test_file, reporter = "progress")
```

**Fixed:**
```r
test_results <- testthat::test_file(file_path, reporter = "progress")
```

**Additional fixes:**
- Replace manual file iteration with `testthat::test_dir()` for proper test discovery
- Add JUnit XML output for CI/CD compatibility
- Enable the configured but unused parallel execution flag
- Add proper error aggregation and reporting

### 1.2 Fix `test_runner.R` Integration

**Current gaps:**
- No code coverage analysis
- No CI/CD output format
- Limited to minimal reporter

**Enhancements:**
- Add `covr::package_coverage()` integration
- Output JUnit XML via `testthat::JunitReporter`
- Add summary statistics (pass/fail/skip counts)
- Add timing information per test file

### 1.3 Create Test Helper Improvements

**File:** `tests/testthat/helper-setup.R`

**Additions:**
- Shared mock data loaders (reduce duplication across 23 test files)
- Standard setup/teardown hooks for resource cleanup
- Session simulation helpers for server module testing
- Vocabulary data caching (load once, reuse across tests)

**New helper functions:**
```r
# Mock session for server module testing
create_mock_session <- function() { ... }

# Standard vocabulary fixture
get_test_vocabulary <- function() { ... }

# Cleanup hook
with_test_cleanup <- function(expr) { ... }
```

---

## Section 2: Priority Module Test Coverage

### 2.1 `local_storage_module.R` (39KB - Highest Priority)

**Why critical:** Largest untested module, handles all data persistence logic. Failures here cause data loss.

**Test coverage needed:**

| Function Area | Test Cases | Risk Level |
|---------------|------------|------------|
| File save/load | Valid data, empty data, corrupt file, permission errors | Critical |
| Path validation | Valid paths, directory traversal attacks, special characters | Critical |
| Session isolation | Multi-user concurrent access, session cleanup | High |
| Error recovery | Disk full, network drive disconnect, file locked | High |

**Test file:** `tests/testthat/test-local-storage-module.R`
**Estimated size:** ~400 lines
**Key assertions:** ~50

### 2.2 `data_management_module.R` (10KB - Core CRUD)

**Why critical:** Handles all data upload, validation, and editing. Every user workflow depends on this.

**Test coverage needed:**

| Function Area | Test Cases | Risk Level |
|---------------|------------|------------|
| Excel import | Valid XLSX, malformed files, wrong format, oversized files | Critical |
| Data validation | Required columns, data types, missing values | Critical |
| Edit operations | Add row, delete row, modify cell, undo | High |
| Reactive state | `currentData`, `editedData`, `hasData` consistency | High |

**Test file:** `tests/testthat/test-data-management-module.R`
**Estimated size:** ~350 lines
**Key assertions:** ~45

### 2.3 `export_module.R` (9KB - Data Integrity)

**Why critical:** Data export is final output. Bugs here corrupt user's work product.

**Test coverage needed:**

| Function Area | Test Cases | Risk Level |
|---------------|------------|------------|
| Excel export | Full data, empty data, special characters, formulas | Critical |
| Format preservation | Column types, dates, numbers, text encoding | High |
| File operations | Valid path, permission denied, disk full | Medium |
| PDF/DOCX | Report generation with various data sizes | Medium |

**Test file:** `tests/testthat/test-export-module.R`
**Estimated size:** ~300 lines
**Key assertions:** ~40

### 2.4 Implementation Phases

```
Phase 1 (Week 1): Infrastructure fixes + local_storage tests
  - Fix comprehensive_test_runner.R
  - Fix test_runner.R
  - Enhance helper-setup.R
  - Write test-local-storage-module.R

Phase 2 (Week 2): data_management + export module tests
  - Write test-data-management-module.R
  - Write test-export-module.R
  - Add coverage tooling

Phase 3 (Week 3): Remaining 10 server modules (smoke tests)
  - Basic initialization tests for each module
  - Error handling tests
  - Integration with CI/CD
```

---

## Section 3: Code Coverage Tooling

### 3.1 Add `covr` Package Integration

**New file:** `tests/coverage_runner.R`

```r
library(covr)

# Generate coverage report for all R files
coverage <- file_coverage(
  source_files = c(
    "utils.R", "vocabulary.R", "server.R", "ui.R",
    list.files("server_modules", pattern = "\\.R$", full.names = TRUE)
  ),
  test_files = list.files("tests/testthat", pattern = "^test-.*\\.R$", full.names = TRUE)
)

# Output formats
report(coverage)                              # Interactive HTML
covr::to_cobertura(coverage, "coverage.xml")  # CI/CD compatible

# Print summary
print(coverage)
```

### 3.2 Coverage Targets

| Milestone | Target | Timeline |
|-----------|--------|----------|
| Baseline (current) | ~15% | Now |
| Phase 1 complete | 35% | +1 week |
| Phase 2 complete | 50% | +2 weeks |
| Phase 3 complete | 60% | +3 weeks |
| Long-term goal | 80% | +3 months |

### 3.3 Coverage Enforcement Rules

**Minimum thresholds:**

| Module Type | Minimum Coverage | Rationale |
|-------------|------------------|-----------|
| Server modules | 60% | Core business logic |
| Utility functions | 70% | Reused everywhere |
| UI components | 40% | Harder to unit test |
| Helpers | 80% | Simple, easy to test |

### 3.4 Coverage Report Integration

**Output locations:**
- `tests/coverage_report.html` - Human-readable report
- `tests/coverage.xml` - Cobertura format for CI/CD
- Console summary after each test run

**Metrics tracked:**
- Line coverage (primary metric)
- Function coverage (secondary)
- Branch coverage (for complex conditionals)

---

## Section 4: CI/CD Integration

### 4.1 GitHub Actions Workflow

**New file:** `.github/workflows/test.yml`

```yaml
name: R Tests & Coverage

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.4.3'

      - name: Install system dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y libcurl4-openssl-dev libxml2-dev

      - name: Install R dependencies
        run: |
          Rscript -e "install.packages(c('testthat', 'covr', 'shiny', 'DT', 'dplyr', 'readxl', 'openxlsx'))"

      - name: Run tests
        run: Rscript tests/test_runner.R

      - name: Generate coverage
        run: Rscript tests/coverage_runner.R

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: tests/coverage.xml
          fail_ci_if_error: false
```

### 4.2 PR Quality Gates

**Enforce on pull requests:**

| Check | Threshold | Action on Failure |
|-------|-----------|-------------------|
| All tests pass | 100% | Block merge |
| Coverage delta | >= 0% (no decrease) | Block merge |
| New code coverage | >= 60% | Warning |
| Critical module coverage | >= 50% | Block merge |

### 4.3 Codecov Configuration

**New file:** `codecov.yml`

```yaml
coverage:
  status:
    project:
      default:
        target: 60%
        threshold: 2%
    patch:
      default:
        target: 60%

comment:
  layout: "reach,diff,flags,files"
  behavior: default
  require_changes: true
```

### 4.4 Local Pre-commit Hook (Optional)

**File:** `.git/hooks/pre-commit`

```bash
#!/bin/bash
echo "Running quick tests..."
Rscript -e "testthat::test_dir('tests/testthat', filter='unit', reporter='minimal')"
if [ $? -ne 0 ]; then
  echo "Tests failed. Commit blocked."
  exit 1
fi
```

---

## Implementation Checklist

### Phase 1: Infrastructure (Week 1)
- [ ] Fix `comprehensive_test_runner.R` line 74 bug
- [ ] Add `testthat::test_dir()` integration
- [ ] Enhance `helper-setup.R` with mock session helpers
- [ ] Write `test-local-storage-module.R` (~400 lines, ~50 assertions)
- [ ] Verify tests execute correctly

### Phase 2: Core Modules (Week 2)
- [ ] Write `test-data-management-module.R` (~350 lines)
- [ ] Write `test-export-module.R` (~300 lines)
- [ ] Create `tests/coverage_runner.R`
- [ ] Generate baseline coverage report
- [ ] Verify coverage reaches 50%

### Phase 3: CI/CD & Remaining Modules (Week 3)
- [ ] Create `.github/workflows/test.yml`
- [ ] Create `codecov.yml`
- [ ] Add smoke tests for remaining 10 server modules
- [ ] Verify CI pipeline runs on PR
- [ ] Document test conventions in CONTRIBUTING.md

---

## Success Metrics

| Metric | Current | Target (3 weeks) | Target (3 months) |
|--------|---------|------------------|-------------------|
| Test files | 23 | 30+ | 45+ |
| Test assertions | ~340 | ~600 | ~1200 |
| Code coverage | ~15% | 60% | 80% |
| Server modules tested | 0/13 | 13/13 | 13/13 |
| CI/CD integration | None | Full | Full |
| Test run time | N/A | <5 min | <3 min |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Server module mocking complexity | Medium | High | Start with simpler modules, build mock library |
| Test flakiness from Shiny reactives | Medium | Medium | Use `shinytest2` for integration tests |
| Coverage tool compatibility | Low | Medium | Test `covr` locally before CI integration |
| CI runtime too long | Low | Low | Parallelize tests, cache dependencies |

---

## Appendix: Files to Create/Modify

### New Files
- `tests/testthat/test-local-storage-module.R`
- `tests/testthat/test-data-management-module.R`
- `tests/testthat/test-export-module.R`
- `tests/coverage_runner.R`
- `.github/workflows/test.yml`
- `codecov.yml`

### Modified Files
- `tests/comprehensive_test_runner.R` (fix line 74 bug)
- `tests/test_runner.R` (add coverage integration)
- `tests/testthat/helper-setup.R` (add mock helpers)

---

*Document created: 2026-03-06*
*Next step: Invoke writing-plans skill to create implementation plan*
