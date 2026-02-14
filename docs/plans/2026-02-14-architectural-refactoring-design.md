# Architectural Refactoring Design

**Goal:** Complete all 6 deferred items from the v5.5.0 codebase audit — naming migration, notification helpers, req() audit, reactive cascades, monolith splitting, and Shiny modularization.

**Date:** 2026-02-14

---

## Execution Order

Mechanical fixes first (low risk, high volume), then structural changes (higher risk).

### Phase 1 — Mechanical Fixes

1. **Naming migration** — 19 camelCase functions → snake_case
2. **Notification migration** — 201 raw `showNotification` → `notify_*()` helpers
3. **`req()` audit** — ~60 missing input validations
4. **Reactive cascade optimization** — debounce/throttle 16 `workflow_state` watchers

### Phase 2 — Structural Changes

5. **Monolith splitting** — extract sections from guided_workflow.R and server.R
6. **Shiny modularization** — convert 10 pseudo-modules to `moduleServer` pattern

---

## Phase 1 Details

### 1. Naming Migration (19 functions, 3 files)

**utils.R (14 functions):**
- `generateEnvironmentalDataFixed` → `generate_environmental_data_fixed`
- `validateDataColumnsDetailed` → `validate_data_columns_detailed`
- `validateDataColumns` → `validate_data_columns`
- `addDefaultColumns` → `add_default_columns`
- `calculateRiskLevel` → `calculate_risk_level`
- `getRiskColor` → `get_risk_color`
- `createBowtieNodesFixed` → `create_bowtie_nodes_fixed`
- `createBowtieEdgesFixed` → `create_bowtie_edges_fixed`
- `createDefaultRowFixed` → `create_default_row_fixed`
- `validateNumericInput` → `validate_numeric_input`
- `getDataSummaryFixed` → `get_data_summary_fixed`
- `generateEnvironmentalDataWithMultipleControls` → `generate_environmental_data_with_multiple_controls`
- `generateDataFromVocabulary` → `generate_data_from_vocabulary`
- `generateScenarioSpecificBowtie` → `generate_scenario_specific_bowtie`

**environmental_scenarios.R (4 functions):**
- `getEnvironmentalScenarioChoices` → `get_environmental_scenario_choices`
- `getScenarioIcon` → `get_scenario_icon`
- `getScenarioLabel` → `get_scenario_label`
- `getScenarioDescription` → `get_scenario_description`

**translations_data.R (1 function):**
- `getScenarioChoices` → `get_scenario_choices`

**Approach:** For each function, grep all call sites, then `replace_all` across definition + callers. Run `parse()` after each file.

### 2. Notification Migration (201 calls, 16 files)

**Mapping:**
- `showNotification(..., type = "message")` → `notify_info(...)`
- `showNotification(..., type = "warning")` → `notify_warning(...)`
- `showNotification(..., type = "error")` → `notify_error(...)`
- `showNotification(..., type = "default")` → `notify_info(...)`
- `showNotification(...)` (no type) → `notify_info(...)`

Extra parameters (`duration`, `id`, `closeButton`, `action`) pass through via `...` in the helpers.

**Files by call count:**
- server.R: 47
- guided_workflow.R: 46
- server_modules/local_storage_module.R: 38
- guided_workflow_ai_suggestions_server.R: 12
- server_modules/bayesian_module.R: 11
- server_modules/data_management_module.R: 9
- server_modules/autosave_module.R: 8
- server_modules/ai_analysis_module.R: 6
- server_modules/theme_module.R: 3
- server_modules/export_module.R: 2
- Others: ~19

### 3. `req()` Audit (~60 missing)

**Rules:**
- `observeEvent(input$x, { ... })` — trigger `x` is guarded, but other `input$` inside needs `req()`
- `observe({ ... })` — ALL `input$` references need `req()`
- `reactive({ ... })` and `render*({ ... })` — ALL `input$` references need `req()`
- Skip inputs already wrapped in `if (!is.null(input$x))` — equivalent
- Skip inputs after existing `req()` in the same block

**Estimated scope:**
- server.R: ~30-40 missing
- guided_workflow.R: ~15-20 missing
- server_modules: ~5-10 missing

### 4. Reactive Cascade Optimization (16 watchers)

**Techniques:**
- `debounce(millis = 300)` for frequently-triggered reactives (typing, rapid clicks)
- `throttle(millis = 500)` for expensive computations (autosave hash, AI suggestions)
- Narrow dependencies: `workflow_state()$specific_field` instead of full state object

**Candidates:**
- `compute_state_hash()` — throttle
- Step sync observers — debounce
- AI suggestion triggers — throttle
- Table renderers dependent on state — debounce

---

## Phase 2 Details

### 5. Monolith Splitting

**guided_workflow.R (4,034 → ~2,400 lines):**

| Extracted File | Content | ~Lines |
|---------------|---------|--------|
| `guided_workflow_ui.R` | 8 step UI generators | 900 |
| `guided_workflow_export.R` | Export pipeline, PDF, load-to-main | 600 |
| `guided_workflow_autosave.R` | Smart autosave system | 130 |
| `guided_workflow.R` (remains) | Orchestrator: state, event handlers | 2,400 |

**server.R (3,506 → ~2,500 lines):**

| Extracted File | Content | ~Lines |
|---------------|---------|--------|
| `server_modules/help_module.R` | Help menus, doc modals | 160 |
| `server_modules/vocabulary_server_module.R` | Vocabulary search/filter/display | 270 |
| `server_modules/download_handlers_module.R` | Download/export handlers | 540 |
| `server.R` (remains) | Orchestrator: init, session mgmt | 2,500 |

Each extracted file is a function taking `input`, `output`, `session` plus needed reactive values. Parent file sources and calls them.

### 6. Shiny Modularization (10 modules)

**Convert from pseudo-module:**
```r
init_theme_module <- function(input, output, session) {
  observeEvent(input$theme_selector, { ... })
}
```

**To proper moduleServer:**
```r
theme_module_ui <- function(id) {
  ns <- NS(id)
  tagList(selectInput(ns("theme_selector"), ...))
}

theme_module_server <- function(id, shared_data) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$theme_selector, { ... })
  })
}
```

**Conversion order (smallest to largest):**
1. theme_module (3 notifications)
2. language_module (1 notification)
3. login_module (1 notification)
4. export_module (2 notifications)
5. bowtie_visualization_module (1 notification)
6. ai_analysis_module (6 notifications)
7. autosave_module (8 notifications)
8. data_management_module (9 notifications)
9. bayesian_module (11 notifications)
10. local_storage_module (38 notifications)

Convert one at a time, test between each.

---

## Risk Assessment

| Item | Risk | Mitigation |
|------|------|------------|
| Naming migration | Low | `parse()` after each file, grep to verify no stale references |
| Notification migration | Low | Helpers pass `...` through, test app after batch |
| `req()` audit | Low-Medium | `req()` silently cancels — cannot break working flows |
| Reactive cascades | Medium | Conservative debounce values (200-500ms) |
| Monolith splitting | Medium | Extract as functions, no behavioral change, test after each split |
| Shiny modularization | High | One module at a time, full app test between each |

## Success Criteria

- All 19 camelCase functions renamed, zero stale references
- Zero raw `showNotification` calls remaining (all use `notify_*()`)
- Every `input$` access inside reactive contexts has `req()` or null-check
- No unnecessary reactive re-executions on unrelated state changes
- guided_workflow.R < 2,500 lines, server.R < 2,500 lines
- All 10 modules use `moduleServer` with proper namespacing
- App starts and passes smoke test after each phase
