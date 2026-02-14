# Codebase Audit Report - Bowtie R Shiny App

**Date**: 2026-02-14
**Version Audited**: 5.4.0 (Stability & Infrastructure Edition)
**Total Active Lines**: 49,164 across 98 R files
**Total Including Archive**: 56,226 across 115 R files

---

## Executive Summary

Six parallel analysis agents examined the codebase across bugs, dead files, architecture, duplication, performance, naming conventions, and logging. The audit found **1 critical runtime bug**, **~660 lines of duplicated code**, an **O(n^2) algorithm** in the AI linker, and **189 raw notification calls bypassing defined helpers**.

---

## 1. CRITICAL BUGS (Runtime Errors)

### 1.1 Invalid `showNotification` type: `"info"`

| File | Line | Impact |
|------|------|--------|
| `helpers/notifications.R` | 120 | **Runtime crash** via `match.arg` error |
| `tests/test_guided_workflow_interactive.R` | 471 | Runtime crash if reached |

The `notify_info()` function uses `type = "info"` which is not a valid Shiny `showNotification` type. Valid types: `"default"`, `"message"`, `"warning"`, `"error"`.

**Fix**: Change `type = "info"` to `type = "message"` at `helpers/notifications.R:120`.

**Severity: CRITICAL** - Will crash when this code path executes.

---

## 2. FILE BLOAT & DEAD FILES

### 2.1 OneDrive sync conflict files (31 items)

`laguna-safeBackup` files are OneDrive conflict artifacts:

| File | Size |
|------|------|
| `utils-laguna-safeBackup-0001.R` | 2,287 lines (full duplicate of utils.R) |
| `environmental_scenarios-laguna-safeBackup-0001.R` | Full duplicate |
| `guided_workflow_config-laguna-safeBackup-0001.R` | Full duplicate |
| `ui_content_sections-laguna-safeBackup-0001.R` | Full duplicate |
| `CONTROLS-laguna-safeBackup-0001.xlsx` | Excel duplicate |
| `server_modules/bowtie_visualization_module-laguna-safeBackup-0001.R` | Module duplicate |
| Plus ~25 more in `.git/`, `.Rproj.user/`, `.claude/` | Various |

### 2.2 Orphaned backup files in project root

| File | Size |
|------|------|
| `ui.R.backup_before_dashboard` | 120 KB |
| `ui.R.backup_original` | 120 KB |
| `ui_dashboard.R.backup_shinydashboard` | 13 KB |

### 2.3 Mystery directories

- `_ul-Dell-PCn`, `_ul-Dell-PCn-2`, `_ul-RazinkaX1` - Unknown purpose, likely editor/sync artifacts.

### 2.4 Large archive directory (6.1 MB)

Contains old app versions, development scripts, and backups. Files in `archive/` still contain known bugs (e.g., `type = "success"` in `app_backup_20250927_101705.R`).

### 2.5 Documentation directory (2.8 MB in `docs/`)

Many session summaries and implementation notes that are redundant with git history.

**Severity: MEDIUM** - Not causing bugs but adds confusion and repository size.

---

## 3. MONOLITH FILES (Architectural Debt)

### 3.1 Files exceeding recommended size

| File | Lines | Observers | Problem |
|------|-------|-----------|---------|
| `guided_workflow.R` | **4,364** | 44 | God-file: UI + server + validation + export |
| `server.R` | **3,506** | 49 | Still massive despite module extraction |
| `utils.R` | **2,475** | - | Kitchen-sink utility file |
| `vocabulary_ai_linker.R` | **2,295** | - | Complex AI logic in one file |
| `translations_data.R` | **1,221** | - | All translations in one file |
| `server_modules/local_storage_module.R` | **1,187** | - | Large for a single module |

### 3.2 Observer/Event density

- `server.R`: 49 `observe`/`observeEvent` handlers
- `guided_workflow.R`: 44 `observe`/`observeEvent` handlers
- **Total: 93 reactive observers** - extremely high for debugging and reactive graph complexity

**Severity: MEDIUM** - Maintainability and debugging difficulty.

---

## 4. CODE DUPLICATION

### 4.1 The Core Problem: Helpers Exist But Nobody Uses Them

| Helper Function | Defined In | Calls to Helper | Direct Calls Bypassing It |
|-----------------|-----------|-----------------|---------------------------|
| `notify_success()` | `notifications.R:19` | **0** in app code | 8+ raw `showNotification` |
| `notify_error()` | `notifications.R:62` | **0** in app code | 10+ raw `showNotification` |
| `notify_warning()` | `notifications.R:136` | **0** in app code | 5+ raw `showNotification` |
| `create_simple_datatable()` | `guided_workflow.R:118` | 2 tables | 4 tables duplicate logic |
| `safe_execute()` | `error_handling.R` | ~1 | 15+ raw `tryCatch` blocks |

**Total**: 189 raw `showNotification()` calls vs 7 helper calls.

### 4.2 Five Identical "Add Item" Observers (~300 lines)

`guided_workflow.R` has 5 nearly identical 40-60 line `observeEvent` handlers:

| Observer | Line | Item Type |
|----------|------|-----------|
| `input$add_activity` | 2079 | Activities |
| `input$add_pressure` | 2187 | Pressures |
| `input$add_preventive_control` | 2363 | Preventive controls |
| `input$add_consequence` | 2557 | Consequences |
| `input$add_protective_control` | 2719 | Protective controls |

Each follows the identical template: check custom toggle, validate, check duplicates, update reactive, persist custom term, show notification, update workflow state, clear inputs.

**Consolidation**: A single factory function could replace ~300 lines with ~80 lines.

### 4.3 Six Identical Step-Sync Observers (~180 lines)

Lines 2020, 2333, 2507, 2673, 2829, 3312 each sync workflow state with reactive values when entering a step. Same structure, different vocabulary type and input IDs.

### 4.4 Four Tables Duplicating `create_simple_datatable()` (~80 lines)

Preventive controls, consequences, protective controls, and escalation factors tables manually implement what `create_simple_datatable()` already does.

### 4.5 Duplicate `%||%` Operator

Defined identically in both `guided_workflow_conversion.R:14` AND `guided_workflow_validation.R:21`.

### 4.6 Estimated Savings

| Pattern | Current Lines | After Consolidation | Reduction |
|---------|--------------|---------------------|-----------|
| Add item observers (x5) | ~300 | ~80 | 73% |
| Table rendering (x4) | ~80 | ~20 | 75% |
| Notification calls (x20+) | ~100 | ~30 | 70% |
| Step sync observers (x6) | ~180 | ~50 | 72% |
| **Total** | **~660** | **~180** | **~73%** |

**Severity: MEDIUM** - Maintainability debt; `guided_workflow.R` could shrink from 4,364 to ~3,700 lines.

---

## 5. PERFORMANCE ISSUES

### 5.1 CRITICAL: O(n^2) Nested Loops in AI Linker

`vocabulary_ai_linker.R:1323-1337` - Triple-nested loop computing semantic similarities:

```r
for (i in 1:(nrow(all_items) - 1)) {
  for (j in (i + 1):nrow(all_items)) {
    for (method in methods) {
      calculate_semantic_similarity_cached(...)
    }
  }
}
```

With 189+ vocabulary items and 3+ methods = **100,000+ comparisons** per call. Same pattern at lines 405-427, 432-450, 648-661, 790-825, 898-920, 1654-1680.

### 5.2 HIGH: `rbind()` Inside Loops

`vocabulary_ai_linker.R` lines 414, 441 - Growing data frames with `rbind()` inside loops: O(n^2) memory operations. 50+ instances.

Note: `utils.R` already uses the correct pattern (`do.call(rbind, list)`) at lines 1530, 2424.

### 5.3 HIGH: Reactive Cascade on `workflow_state`

`guided_workflow.R` has **10+ observers** all watching `workflow_state()`:

| Line | Purpose |
|------|---------|
| 1603 | Timer debounce |
| 1616 | Autosave trigger (no debounce on the `observe` itself) |
| 1851 | Vocab choices update |
| 2337 | Step 4 data loader |
| 2528 | Step 5 data loader |
| 2690 | Step 6 data loader |
| 2871 | Step 7 data loader |

Every state field change triggers ALL of them.

### 5.4 MEDIUM-HIGH: Missing `req()` Validation

Only ~27 `req()` calls across ~3,000 lines of server.R. Should be ~100+. Example: `server.R:1490-1497` - `filtered_vocabulary` chains off `current_vocabulary()` without `req()`, leading to silent empty-data propagation.

### 5.5 MEDIUM: Client-Side DT Filtering

`guided_workflow.R:118-144` - `create_simple_datatable()` sends all data to browser. Vocabulary lists (189+ items) generate large JSON payloads.

### 5.6 Positive Findings

- LRU cache with TTL in `utils.R:9-150` (excellent)
- Vectorized edge creation in `bowtie_bayesian_network.R:71-94`
- Correct `do.call(rbind)` pattern in `utils.R:1530, 2424`
- Timer-based debounce for autosave in `guided_workflow.R:1603-1613`

**Severity: CRITICAL (AI linker) / HIGH (reactive cascade) / MEDIUM (others)**

---

## 6. NAMING CONVENTION VIOLATIONS

### 6.1 camelCase Functions (Should Be snake_case)

Per CLAUDE.md: new functions must use `snake_case`. These are actively maintained but use camelCase:

**`utils.R` (16 violations)**:
| Line | Function |
|------|----------|
| 442 | `generateEnvironmentalDataFixed` |
| 677 | `validateDataColumnsDetailed` |
| 691 | `validateDataColumns` |
| 697 | `addDefaultColumns` |
| 829 | `calculateRiskLevel` |
| 855 | `getRiskColor` |
| 868 | `createBowtieNodesFixed` |
| 1250 | `createBowtieEdgesFixed` |
| 1550 | `createDefaultRowFixed` |
| 1598 | `validateNumericInputDetailed` |
| 1609 | `validateNumericInput` |
| 1618 | `getDataSummaryFixed` |
| 1641 | `validateProtectiveMitigations` |
| 1674 | `generateEnvironmentalDataWithMultipleControls` |
| 2017 | `generateDataFromVocabulary` |
| 2023 | `generateScenarioSpecificBowtie` |

**`environmental_scenarios.R` (4 violations)**:
- Line 119: `getEnvironmentalScenarioChoices`
- Line 137: `getScenarioIcon`
- Line 151: `getScenarioLabel`
- Line 165: `getScenarioDescription`

### 6.2 Split Personality in `utils.R`

Lines 155-217 use correct snake_case (`get_cache_stats`, `invalidate_bowtie_caches`), while lines 442+ use camelCase. The file has no consistent convention.

### 6.3 Compliant Areas

- All reactive values correctly use camelCase
- All constants correctly use UPPER_SNAKE_CASE
- Helper functions in `constants.R` correctly use snake_case
- Function parameters consistently use snake_case

**Severity: LOW** - Style issue, not functional.

---

## 7. LOGGING INCONSISTENCIES

### 7.1 `vocabulary.R` Uses `message()`/`warning()` (8 violations)

Lines 196, 198, 205, 207, 214, 216, 223, 225 - bypass the centralized logging system:

```r
message("Loaded Activities data: ", nrow(...))   # should be log_info()
warning("Failed to load Activities: ", e$message)  # should be log_warning()
```

### 7.2 `vocabulary_bowtie_generator.R` Mixed Logging (2 violations)

Lines 32, 35 - Uses `warning()` for errors but `log_success()` for success within the same tryCatch block.

### 7.3 `server_modules/data_management_module.R` Missing Error Logging

Lines 43-45, 89-92 - Errors only show `showNotification()` to the user but never call `log_error()`.

### 7.4 `log_success` Not Documented in CLAUDE.md

`log_success()` is used 19 times in production code but isn't listed in CLAUDE.md's "Preferred logging functions" section. It exists in `config/logging.R:253`.

### 7.5 `cat()` in Post-Logging Files

`server.R` (2 calls) and `utils.R` (2 calls) use `cat()` after the logging system has loaded.

**Severity: LOW-MEDIUM** - Inconsistency, not causing failures.

---

## 8. PSEUDO-MODULARIZATION

### 8.1 Server Modules Are Not Proper Shiny Modules

Only 2 files use proper `moduleServer`:
- `guided_workflow.R`
- `login_module.R`

The other 10 server module files are plain functions receiving `input, output, session` directly - they're sourced code, not namespaced Shiny modules:
- `language_module.R`, `theme_module.R`, `bayesian_module.R`, `data_management_module.R`, `export_module.R`, `autosave_module.R`, `local_storage_module.R`, `bowtie_visualization_module.R`, `report_generation_module.R`, `ai_analysis_module.R`

This means no namespace isolation and all input/output IDs must be globally unique.

**Severity: LOW-MEDIUM** - Works fine but limits reusability and increases ID collision risk.

---

## Priority Matrix

| # | Issue | Severity | Fix Effort | Category |
|---|-------|----------|------------|----------|
| 1 | `type = "info"` in notifications.R:120 | **CRITICAL** | 1 minute | Bug |
| 2 | O(n^2) loops in vocabulary_ai_linker.R | **CRITICAL** | 2-3 hours | Performance |
| 3 | rbind in loops (ai_linker) | **HIGH** | 1 hour | Performance |
| 4 | Reactive cascade on workflow_state | **HIGH** | 2 hours | Performance |
| 5 | 31+ dead/backup/conflict files | **MEDIUM** | 30 minutes | Dead files |
| 6 | Missing req() across server.R | **MEDIUM-HIGH** | 2 hours | Performance |
| 7 | 189 raw showNotification vs 7 helper calls | **MEDIUM** | 4 hours | Duplication |
| 8 | 5 identical add-item observers (~300 lines) | **MEDIUM** | 2 hours | Duplication |
| 9 | 6 identical step-sync observers (~180 lines) | **MEDIUM** | 1.5 hours | Duplication |
| 10 | vocabulary.R uses message()/warning() | **MEDIUM** | 15 minutes | Logging |
| 11 | Monolith files (4K+ lines) | **MEDIUM** | Days | Architecture |
| 12 | Naming convention violations (20 functions) | **LOW** | 2 hours | Naming |
| 13 | Pseudo-modularization (10 modules) | **LOW-MEDIUM** | Days | Architecture |
| 14 | cat() in post-logging files | **LOW** | 10 minutes | Logging |
| 15 | Duplicate %||% operator | **LOW** | 5 minutes | Duplication |

---

## Recommended Fix Order

### Phase 1: Quick Wins (< 1 hour)
1. Fix `type = "info"` -> `type = "message"` in `notifications.R:120`
2. Replace `message()`/`warning()` in `vocabulary.R` with `log_*()`
3. Replace `warning()` in `vocabulary_bowtie_generator.R` with `log_warning()`
4. Remove duplicate `%||%` operator
5. Delete OneDrive conflict files and backup files from project root

### Phase 2: Performance (2-4 hours)
6. Vectorize O(n^2) loops in `vocabulary_ai_linker.R`
7. Replace `rbind()` in loops with list accumulation + `do.call(rbind)`
8. Add debounce/throttle to `workflow_state` observers
9. Add missing `req()` calls in reactive chains

### Phase 3: Deduplication (4-6 hours)
10. Create factory function for 5 add-item observers
11. Create factory function for 6 step-sync observers
12. Use `create_simple_datatable()` in 4 duplicating tables
13. Migrate 189 raw `showNotification` calls to use `notify_*()` helpers

### Phase 4: Architecture (Multi-day)
14. Split `guided_workflow.R` into smaller focused files
15. Rename camelCase functions to snake_case
16. Convert pseudo-modules to proper `moduleServer` pattern

---

## 9. DEAD CODE & UNUSED FUNCTIONS

### 9.1 Unused Developer Utilities in `utils.R`

| Line | Function | Status |
|------|----------|--------|
| 197 | `print_cache_stats()` | Never called in production code |
| 235 | `memoize()` | Never called anywhere |
| 274 | `memoize_simple()` | Never called anywhere |
| 399 | `get_benchmark_history()` | Never called anywhere |
| 404 | `clear_benchmark_history()` | Never called anywhere |
| 410 | `compare_benchmarks()` | Never called anywhere |
| 1598 | `validateNumericInputDetailed()` | Never called - only `validateNumericInput()` is used |
| 1641 | `validateProtectiveMitigations()` | Never called anywhere |

### 9.2 Unused Vocabulary Functions in `vocabulary.R`

| Line | Function | Status |
|------|----------|--------|
| 244 | `get_children()` | Likely superseded by other hierarchy functions |
| 251 | `get_item_path()` | Only referenced in test files |
| 278 | `create_tree_structure()` | Only found at definition site |

### 9.3 Unused UI Component Stubs in `ui_components.R`

| Line | Function | Status |
|------|----------|--------|
| 30 | `empty_state()` | Never called in production code |
| 129 | `empty_state_search()` | Not used in active codebase |
| 163 | `validated_text_input()` | Not used in active codebase |

### 9.4 Functions Only Used in Tests/Docs

| File | Function | Usage |
|------|----------|-------|
| `utils.R:2017` | `generateDataFromVocabulary()` | Only in documentation (Rmd) |
| `utils.R:2023` | `generateScenarioSpecificBowtie()` | Only in documentation |
| `word_embeddings.R:223` | `calculate_embedding_similarity()` | Only in tests |
| `word_embeddings.R:300` | `find_similar_words()` | Only in tests |

### 9.5 No Large Commented-Out Code Blocks

The codebase is clean in this regard - no large blocks of commented-out code were found in main files.

**Severity: LOW** - Dead code adds confusion but doesn't cause bugs. ~8 functions in `utils.R` can be safely removed.
