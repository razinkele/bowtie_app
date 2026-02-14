# Architectural Refactoring Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete all 6 deferred architectural items from the v5.5.0 audit — rename 19 camelCase functions, migrate 201 showNotification calls to helpers, add ~60 missing req() guards, optimize 16 reactive cascades, split 2 monolith files, and convert 10 modules to proper moduleServer pattern.

**Architecture:** Two phases — mechanical fixes first (naming, notifications, req, reactive), then structural changes (monolith splitting, Shiny modularization). Each task commits independently. Phase 1 items are independent of each other; Phase 2 depends on Phase 1 being complete.

**Tech Stack:** R, Shiny, testthat

---

## Phase 1: Mechanical Fixes

### Task 1: Rename 19 camelCase functions to snake_case

**Files:**
- Modify: `utils.R` (14 function definitions)
- Modify: `environmental_scenarios.R` (4 function definitions)
- Modify: `translations_data.R` (1 function definition)
- Modify: All files that call these functions (server.R, guided_workflow.R, server_modules/*, tests/*)

**Step 1: Rename all 19 functions**

For each function below, rename the definition AND all call sites across the entire codebase. Use `replace_all` on each file that contains the old name. Grep for each old name first to find all call sites.

**utils.R renames (14):**

| Old Name | New Name |
|----------|----------|
| `generateEnvironmentalDataFixed` | `generate_environmental_data_fixed` |
| `validateDataColumnsDetailed` | `validate_data_columns_detailed` |
| `validateDataColumns` | `validate_data_columns` |
| `addDefaultColumns` | `add_default_columns` |
| `calculateRiskLevel` | `calculate_risk_level` |
| `getRiskColor` | `get_risk_color` |
| `createBowtieNodesFixed` | `create_bowtie_nodes_fixed` |
| `createBowtieEdgesFixed` | `create_bowtie_edges_fixed` |
| `createDefaultRowFixed` | `create_default_row_fixed` |
| `validateNumericInput` | `validate_numeric_input` |
| `getDataSummaryFixed` | `get_data_summary_fixed` |
| `generateEnvironmentalDataWithMultipleControls` | `generate_environmental_data_with_multiple_controls` |
| `generateDataFromVocabulary` | `generate_data_from_vocabulary` |
| `generateScenarioSpecificBowtie` | `generate_scenario_specific_bowtie` |

**environmental_scenarios.R renames (4):**

| Old Name | New Name |
|----------|----------|
| `getEnvironmentalScenarioChoices` | `get_environmental_scenario_choices` |
| `getScenarioIcon` | `get_scenario_icon` |
| `getScenarioLabel` | `get_scenario_label` |
| `getScenarioDescription` | `get_scenario_description` |

**translations_data.R renames (1):**

| Old Name | New Name |
|----------|----------|
| `getScenarioChoices` | `get_scenario_choices` |

**Step 2: Verify syntax**

Run `parse()` on every modified file to confirm no syntax errors.

```r
Rscript -e "files <- list.files('.', pattern='\\.R$', recursive=TRUE, full.names=TRUE); files <- files[!grepl('archive|docs|\\.playwright', files)]; for(f in files) tryCatch({parse(file=f); cat(f,': OK\n')}, error=function(e) cat(f,': ERROR\n'))"
```

**Step 3: Verify no stale references remain**

Grep for each old camelCase name across the codebase. Expected: zero matches in non-archive .R files.

**Step 4: Commit**

```bash
git add -u
git commit -m "refactor: rename 19 camelCase functions to snake_case"
```

---

### Task 2: Fix notification helpers and migrate 201 showNotification calls

This task has two sub-parts: first fix the helper signatures, then migrate all calls.

**Files:**
- Modify: `helpers/notifications.R` (fix helper signatures)
- Modify: All 16 files containing `showNotification` calls

**Step 1: Fix `notify_info` signature**

The current `notify_info(icon_name, message, ...)` signature is awkward — most callers just want to pass a message. Change to `notify_info(message, duration = NULL, lang = "en")` to match `notify_warning` and `notify_success` patterns.

In `helpers/notifications.R`, replace the `notify_info` function (lines 92-125) with:

```r
#' Show info notification
#'
#' @param message Message text or translation key
#' @param duration Duration in seconds (uses constant if not specified)
#' @param lang Language code
#' @return NULL (invisible)
notify_info <- function(message, duration = NULL, lang = "en") {
  if (is.null(duration)) {
    duration <- NOTIFICATION_DURATION_INFO
  }

  translated <- tryCatch({
    if (exists("t") && is.function(t)) {
      t(message, lang)
    } else {
      message
    }
  }, error = function(e) {
    message
  })

  showNotification(
    translated,
    type = "message",
    duration = duration
  )

  invisible(NULL)
}
```

Also update `notify_success` to not prepend emoji (callers already include their own emojis):

```r
  showNotification(
    message_text,
    type = "message",
    duration = duration
  )
```

And update `notify_error` similarly:

```r
  showNotification(
    paste("Error:", full_message),
    type = "error",
    duration = duration
  )
```

And `notify_warning`:

```r
  showNotification(
    translated,
    type = "warning",
    duration = duration
  )
```

**Step 2: Migrate showNotification calls**

For each file, replace `showNotification(...)` calls with the appropriate `notify_*()` helper based on the `type =` argument:

| Pattern | Replacement |
|---------|-------------|
| `showNotification(msg, type = "message", duration = N)` | `notify_info(msg, duration = N)` |
| `showNotification(msg, type = "message")` | `notify_info(msg)` |
| `showNotification(msg, type = "error", duration = N)` | `notify_error(msg, duration = N)` |
| `showNotification(msg, type = "error")` | `notify_error(msg)` |
| `showNotification(msg, type = "warning", duration = N)` | `notify_warning(msg, duration = N)` |
| `showNotification(msg, type = "warning")` | `notify_warning(msg)` |
| `showNotification(msg, type = "default", duration = N)` | `notify_info(msg, duration = N)` |
| `showNotification(msg)` (no type) | `notify_info(msg)` |

Process files in order of call count (highest first):
1. server.R (47)
2. guided_workflow.R (46)
3. server_modules/local_storage_module.R (38)
4. guided_workflow_ai_suggestions_server.R (12)
5. server_modules/bayesian_module.R (11)
6. server_modules/data_management_module.R (9)
7. server_modules/autosave_module.R (8)
8. server_modules/ai_analysis_module.R (6)
9. server_modules/theme_module.R (3)
10. server_modules/export_module.R (2)
11. Remaining files (~19)

**Step 3: Verify zero raw showNotification calls remain**

```bash
grep -rn 'showNotification(' *.R server_modules/*.R helpers/*.R guided_workflow*.R | grep -v 'helpers/notifications.R' | grep -v '#'
```

Expected: zero matches outside `helpers/notifications.R` (where the helpers themselves call showNotification internally).

**Step 4: Run parse() on all modified files**

**Step 5: Commit**

```bash
git add -u
git commit -m "refactor: migrate 201 showNotification calls to notify_*() helpers"
```

---

### Task 3: Add missing req() guards (~60 locations)

**Files:**
- Modify: `server.R` (~30-40 additions)
- Modify: `guided_workflow.R` (~15-20 additions)
- Modify: `server_modules/*.R` (~5-10 additions)

**Step 1: Audit server.R**

Search for all `observeEvent`, `observe`, `reactive`, `renderDT`, `renderUI`, `renderPlot`, `renderText`, `renderPrint` blocks. For each block:

1. Identify all `input$xxx` references inside the block
2. Check if each `input$xxx` has a `req()` guard or `if (!is.null(...))` check
3. If not, add `req(input$xxx)` at the top of the block

Rules:
- For `observeEvent(input$x, { ... })` — the trigger `input$x` is auto-guarded by Shiny, but OTHER `input$` refs inside need `req()`
- For `observe({ ... })` — ALL `input$` refs need `req()`
- For `reactive({ ... })` and all `render*({ ... })` — ALL `input$` refs need `req()`
- Skip if already guarded by `req()` or `if (!is.null(...))`
- Group related inputs into a single `req()` call: `req(input$a, input$b)`

**Step 2: Audit guided_workflow.R**

Same process as Step 1.

**Step 3: Audit server_modules/*.R**

Same process for each server module file.

**Step 4: Run parse() on all modified files**

**Step 5: Commit**

```bash
git add -u
git commit -m "fix: add ~60 missing req() guards to prevent NULL input errors"
```

---

### Task 4: Optimize reactive cascades with debounce/throttle

**Files:**
- Modify: `guided_workflow.R` (16 workflow_state watchers)

**Step 1: Identify all workflow_state watchers**

Search for `observe` and `reactive` blocks that reference `workflow_state()`. For each, determine:
- Is it triggered frequently (typing, rapid navigation)? → `debounce(300)`
- Is it computationally expensive (hash computation, AI calls)? → `throttle(500)`
- Does it only need a specific field? → Narrow dependency to `workflow_state()$field`

**Step 2: Apply debounce/throttle**

For reactive expressions that read `workflow_state()` and are used by observers:

```r
# BEFORE:
some_reactive <- reactive({
  state <- workflow_state()
  # expensive computation
})

# AFTER:
some_reactive_raw <- reactive({
  state <- workflow_state()
  # expensive computation
})
some_reactive <- some_reactive_raw %>% debounce(300)
```

For the autosave hash computation:

```r
# Throttle to max 2x/second
state_hash <- reactive({ compute_state_hash(workflow_state()) }) %>% throttle(500)
```

**Step 3: Narrow broad dependencies where possible**

For observers that only care about a specific field:

```r
# BEFORE: triggers on ANY state change
observe({
  step <- workflow_state()$current_step
  # update UI for current step
})

# AFTER: only triggers when current_step changes
current_step <- reactive({ workflow_state()$current_step })
observe({
  step <- current_step()
  # update UI for current step
})
```

**Step 4: Run parse() on modified files**

**Step 5: Start the app and verify workflow responsiveness**

Navigate through all 8 steps, add/remove items, verify no lag introduced by debounce.

**Step 6: Commit**

```bash
git add -u
git commit -m "perf: add debounce/throttle to 16 reactive cascade watchers"
```

---

## Phase 2: Structural Changes

### Task 5: Split guided_workflow.R (4,034 → ~2,400 lines)

**Files:**
- Create: `guided_workflow_ui.R` (~900 lines)
- Create: `guided_workflow_export.R` (~600 lines)
- Create: `guided_workflow_autosave.R` (~130 lines)
- Modify: `guided_workflow.R` (remove extracted sections, add source() calls)

**Step 1: Extract step UI generators to `guided_workflow_ui.R`**

Move the 8 `generate_step*` functions (lines ~575-1475) to a new file `guided_workflow_ui.R`. These are pure UI generators with no server-side dependencies.

The new file should start with:

```r
# =============================================================================
# Guided Workflow - Step UI Generators
# Extracted from guided_workflow.R for maintainability
# =============================================================================
```

In `guided_workflow.R`, replace the extracted section with:

```r
# Step UI generators (extracted)
source("guided_workflow_ui.R", local = TRUE)
```

**Step 2: Extract export pipeline to `guided_workflow_export.R`**

Move the export functions (export to Excel, PDF generation, load-to-main-app, save/load progress) to `guided_workflow_export.R`. These functions take `input`, `output`, `session`, and reactive values as parameters.

Wrap them in a single function:

```r
# =============================================================================
# Guided Workflow - Export & Persistence Functions
# =============================================================================

init_workflow_export <- function(input, output, session, workflow_state,
                                 selected_activities, selected_pressures,
                                 ...) {
  # All export observers and handlers here
}
```

In `guided_workflow.R`, call:

```r
source("guided_workflow_export.R", local = TRUE)
init_workflow_export(input, output, session, workflow_state, ...)
```

**Step 3: Extract autosave to `guided_workflow_autosave.R`**

Move `compute_state_hash()` and `perform_smart_autosave()` and related observers.

**Step 4: Verify guided_workflow.R is under 2,500 lines**

```bash
wc -l guided_workflow.R
```

**Step 5: Run parse() on all new and modified files**

**Step 6: Start app and smoke-test the full 8-step workflow**

**Step 7: Commit**

```bash
git add guided_workflow.R guided_workflow_ui.R guided_workflow_export.R guided_workflow_autosave.R
git commit -m "refactor: split guided_workflow.R into 4 focused files"
```

---

### Task 6: Split server.R (3,506 → ~2,500 lines)

**Files:**
- Create: `server_modules/help_module.R` (~160 lines) — if not already existing
- Create: `server_modules/vocabulary_server_module.R` (~270 lines)
- Create: `server_modules/download_handlers_module.R` (~540 lines)
- Modify: `server.R` (remove extracted sections, add initialization calls)

**Step 1: Extract help/documentation handlers**

Move help menu observers, user guide modals, and documentation display (lines ~649-810) to `server_modules/help_module.R`.

Wrap in a function:

```r
init_help_module <- function(input, output, session) {
  # Help menu observers
  # User guide modals
  # Documentation display
}
```

**Step 2: Extract vocabulary management**

Move vocabulary search, filtering, display, and refresh (lines ~1458-1727) to `server_modules/vocabulary_server_module.R`.

```r
init_vocabulary_server_module <- function(input, output, session, vocabulary_data) {
  # Vocabulary search, filter, display
}
```

**Step 3: Extract download/export handlers**

Move all download handlers (bowtie PNG/HTML/JPEG, analysis reports, manual downloads) to `server_modules/download_handlers_module.R`.

```r
init_download_handlers_module <- function(input, output, session, current_data, ...) {
  # All downloadHandler definitions
}
```

**Step 4: Update server.R to source and initialize extracted modules**

Add to the module initialization section:

```r
source("server_modules/help_module.R")
source("server_modules/vocabulary_server_module.R")
source("server_modules/download_handlers_module.R")

init_help_module(input, output, session)
init_vocabulary_server_module(input, output, session, vocabulary_data)
init_download_handlers_module(input, output, session, current_data, ...)
```

**Step 5: Verify server.R is under 2,500 lines**

**Step 6: Run parse(), start app, smoke-test all pages**

**Step 7: Commit**

```bash
git add server.R server_modules/help_module.R server_modules/vocabulary_server_module.R server_modules/download_handlers_module.R
git commit -m "refactor: split server.R into focused modules"
```

---

### Task 7: Convert theme_module to moduleServer (proof-of-concept)

**Files:**
- Modify: `server_modules/theme_module.R`
- Modify: `ui.R` (namespace theme-related inputs)
- Modify: `server.R` (change initialization call)

**Step 1: Add UI function with namespacing**

In `server_modules/theme_module.R`, add a UI function:

```r
theme_module_ui <- function(id) {
  ns <- NS(id)
  # Return namespaced UI elements for theme selection
  # Find all input IDs used by this module and wrap with ns()
}
```

**Step 2: Convert server function to moduleServer**

```r
# BEFORE:
init_theme_module <- function(input, output, session, ...) {
  observeEvent(input$theme_selector, { ... })
}

# AFTER:
theme_module_server <- function(id, shared_data = NULL) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$theme_selector, { ... })
  })
}
```

**Step 3: Update ui.R**

Replace theme-related input IDs with namespaced versions using `theme_module_ui("theme")`.

**Step 4: Update server.R**

```r
# BEFORE:
init_theme_module(input, output, session)

# AFTER:
theme_module_server("theme")
```

**Step 5: Test theme switching works**

Start app, switch themes, verify CSS changes apply.

**Step 6: Commit**

```bash
git add server_modules/theme_module.R ui.R server.R
git commit -m "refactor: convert theme_module to proper moduleServer pattern"
```

---

### Task 8: Convert remaining 9 modules to moduleServer

**Files:**
- Modify: Each `server_modules/*.R` file
- Modify: `ui.R` (namespace inputs for each module)
- Modify: `server.R` (update initialization calls)

Convert one module at a time, in order from smallest to largest:

1. `language_module` (1 notification)
2. `login_module` (1 notification)
3. `export_module` (2 notifications)
4. `bowtie_visualization_module` (1 notification)
5. `ai_analysis_module` (6 notifications)
6. `autosave_module` (8 notifications)
7. `data_management_module` (9 notifications)
8. `bayesian_module` (11 notifications)
9. `local_storage_module` (38 notifications)

For each module, follow the same pattern as Task 7:
1. Add `<module>_ui(id)` function with `NS(id)` namespacing
2. Convert `init_<module>(input, output, session, ...)` to `<module>_server(id, ...)`
3. Update `ui.R` with namespaced inputs
4. Update `server.R` initialization
5. Test the module's functionality
6. Commit

After each module conversion, start the app and verify the converted functionality works. Do NOT batch multiple modules — convert and test one at a time.

**Final commit after all 9:**

```bash
git commit -m "refactor: convert all 10 modules to proper moduleServer pattern"
```

---

### Task 9: Final verification and version bump

**Step 1: Run full test suite**

```bash
Rscript tests/run_tests.R
```

**Step 2: Start app and full smoke test**

- Dashboard loads
- Data upload with scenario generation
- Guided workflow (all 8 steps, add/remove items)
- Bowtie diagram rendering
- Bayesian network creation and inference
- Theme switching
- Export functionality

**Step 3: Update VERSION and VERSION_HISTORY.md**

Bump to v5.6.0 with comprehensive changelog.

**Step 4: Commit and push**

```bash
git add VERSION VERSION_HISTORY.md
git commit -m "chore: bump version to 5.6.0 after architectural refactoring"
git push
```
