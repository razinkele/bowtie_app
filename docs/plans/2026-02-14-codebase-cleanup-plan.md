# Codebase Cleanup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix all critical bugs, eliminate dead code/files, resolve logging inconsistencies, deduplicate guided workflow observers, and improve AI linker performance — based on the audit in `docs/plans/2026-02-14-codebase-audit.md`.

**Architecture:** Surgical fixes to existing files. No new architectural patterns introduced. Factory functions added to `guided_workflow.R` to replace duplicated observer code. AI linker loops vectorized in-place.

**Tech Stack:** R, Shiny, DT, openxlsx, dplyr

---

## Phase 1: Critical Bug Fixes & Quick Wins

### Task 1: Fix invalid notification type in `notify_info()`

**Files:**
- Modify: `helpers/notifications.R:120`
- Modify: `tests/test_guided_workflow_interactive.R:471`

**Step 1: Fix `helpers/notifications.R:120`**

Change `type = "info"` to `type = "message"`. The function `notify_info()` currently crashes at runtime because `"info"` is not a valid Shiny `showNotification` type. Valid types: `"default"`, `"message"`, `"warning"`, `"error"`.

```r
# Line 120 — BEFORE:
    type = "info",

# Line 120 — AFTER:
    type = "message",
```

**Step 2: Fix `tests/test_guided_workflow_interactive.R:471`**

```r
# Line 471 — BEFORE:
      showNotification(paste("Auto-complete not implemented for step", step), type = "info")

# Line 471 — AFTER:
      showNotification(paste("Auto-complete not implemented for step", step), type = "message")
```

**Step 3: Verify no other invalid types remain**

Run: `grep -rn 'type\s*=\s*"info"\|type\s*=\s*"success"' *.R helpers/*.R server_modules/*.R tests/testthat/*.R`

Expected: No matches in active production/test files (archive files are OK to ignore).

**Step 4: Commit**

```bash
git add helpers/notifications.R tests/test_guided_workflow_interactive.R
git commit -m "fix: replace invalid showNotification type 'info' with 'message'"
```

---

### Task 2: Fix logging inconsistencies in `vocabulary.R`

**Files:**
- Modify: `vocabulary.R:196-225`

**Step 1: Replace `message()` and `warning()` with proper log functions**

There are 4 tryCatch blocks (lines 194-227) that use `message()` for success and `warning()` for errors. Replace all 8 calls with the centralized logging system from `config/logging.R`.

```r
# Lines 194-200 — BEFORE:
  tryCatch({
    vocabulary$activities <- read_hierarchical_data(causes_file, sheet_name = "Activities")
    message("✓ Loaded Activities data: ", nrow(vocabulary$activities), " items")
  }, error = function(e) {
    warning("Failed to load Activities: ", e$message)
    vocabulary$activities <- data.frame()
  })

# Lines 194-200 — AFTER:
  tryCatch({
    vocabulary$activities <- read_hierarchical_data(causes_file, sheet_name = "Activities")
    log_info(paste("Loaded Activities data:", nrow(vocabulary$activities), "items"))
  }, error = function(e) {
    log_warning(paste("Failed to load Activities:", e$message))
    vocabulary$activities <- data.frame()
  })
```

Apply the same pattern to the 3 remaining blocks:
- Lines 203-209: Pressures (`message(...)` -> `log_info(...)`, `warning(...)` -> `log_warning(...)`)
- Lines 212-218: Consequences (same transformation)
- Lines 221-227: Controls (same transformation)

**Step 2: Commit**

```bash
git add vocabulary.R
git commit -m "fix: replace message()/warning() with log_info()/log_warning() in vocabulary.R"
```

---

### Task 3: Fix logging inconsistencies in `vocabulary_bowtie_generator.R`

**Files:**
- Modify: `vocabulary_bowtie_generator.R:32,35`

**Step 1: Replace `warning()` calls**

```r
# Line 32 — BEFORE:
    warning("Failed to load vocabulary_ai_linker.R: ", e$message)

# Line 32 — AFTER:
    log_warning(paste("Failed to load vocabulary_ai_linker.R:", e$message))

# Line 35 — BEFORE:
  warning("vocabulary_ai_linker.R not found. Will use basic linking only.")

# Line 35 — AFTER:
  log_warning("vocabulary_ai_linker.R not found. Will use basic linking only.")
```

**Step 2: Commit**

```bash
git add vocabulary_bowtie_generator.R
git commit -m "fix: replace warning() with log_warning() in vocabulary_bowtie_generator.R"
```

---

### Task 4: Remove duplicate `%||%` operator

**Files:**
- Modify: `guided_workflow_conversion.R:11-16`

**Step 1: Remove the conditional definition in `guided_workflow_conversion.R`**

`guided_workflow_validation.R:20-22` is the canonical definition (it's sourced first by `guided_workflow.R`). The duplicate in `guided_workflow_conversion.R:11-16` is guarded by `if (!exists("%||%"))` so it's already safe — but it's dead code and should be removed for clarity.

```r
# Lines 11-16 — REMOVE ENTIRELY:
# Ensure %||% operator is available (may be defined in validation module)
if (!exists("%||%")) {
  `%||%` <- function(x, y) {
    if (is.null(x) || length(x) == 0 || (is.character(x) && all(nchar(x) == 0))) y else x
  }
}
```

Replace with a comment:

```r
# %||% operator is defined in guided_workflow_validation.R (loaded before this file)
```

**Step 2: Verify the operator still works**

Run: `Rscript -e "source('guided_workflow_validation.R'); source('guided_workflow_conversion.R'); cat('OK\n')"`

Expected: `OK` with no errors.

**Step 3: Commit**

```bash
git add guided_workflow_conversion.R
git commit -m "refactor: remove duplicate %||% operator from guided_workflow_conversion.R"
```

---

### Task 5: Remove dead code from `utils.R`

**Files:**
- Modify: `utils.R` (lines 197-213, 235-268, 274-290, 399-436, 1598-1615, 1641-1672)

**Step 1: Remove 8 unused functions**

Remove the following functions that are never called in production code:

1. `print_cache_stats()` (lines ~197-213) — developer utility, never invoked
2. `memoize()` (lines ~235-268) — never invoked
3. `memoize_simple()` (lines ~274-290) — never invoked
4. `get_benchmark_history()` (lines ~399) — never invoked
5. `clear_benchmark_history()` (lines ~404) — never invoked
6. `compare_benchmarks()` (lines ~410-436) — never invoked
7. `validateNumericInputDetailed()` (lines ~1598-1615) — only `validateNumericInput()` is used
8. `validateProtectiveMitigations()` (lines ~1641-1672) — never invoked

**Important:** Remove each function one at a time, bottom-to-top (highest line numbers first), to avoid shifting line numbers. After each removal, verify no callers exist with grep.

**Step 2: Verify nothing breaks**

Run: `Rscript -e "source('config/logging.R'); source('constants.R'); source('utils.R'); cat('All utils loaded OK\n')"`

Expected: `All utils loaded OK`

**Step 3: Commit**

```bash
git add utils.R
git commit -m "refactor: remove 8 unused functions from utils.R"
```

---

### Task 6: Delete OneDrive conflict files and backup files

**Files:**
- Delete: All `*-laguna-safeBackup*` files outside `.git/`
- Delete: `ui.R.backup_before_dashboard`
- Delete: `ui.R.backup_original`
- Delete: `ui_dashboard.R.backup_shinydashboard`
- Delete: `_ul-Dell-PCn`, `_ul-Dell-PCn-2`, `_ul-RazinkaX1`
- Delete: `.Rhistory-laguna-safeBackup-0001`
- Delete: `CONTROLS-laguna-safeBackup-0001.xlsx`
- Delete: `CONTROLS_WITH_NID.xlsx` (if confirmed unused)

**Step 1: Remove R backup files from project root (NOT in .git)**

```bash
rm -f utils-laguna-safeBackup-0001.R
rm -f environmental_scenarios-laguna-safeBackup-0001.R
rm -f guided_workflow_config-laguna-safeBackup-0001.R
rm -f ui_content_sections-laguna-safeBackup-0001.R
rm -f server_modules/bowtie_visualization_module-laguna-safeBackup-0001.R
rm -f deployment/deploy_remote-laguna-safeBackup-0001.cmd
rm -f .claude/settings.local-laguna-safeBackup-0001.json
rm -f .Rhistory-laguna-safeBackup-0001
rm -f CONTROLS-laguna-safeBackup-0001.xlsx
```

**Step 2: Remove orphaned backup files**

```bash
rm -f ui.R.backup_before_dashboard
rm -f ui.R.backup_original
rm -f ui_dashboard.R.backup_shinydashboard
```

**Step 3: Remove mystery directories**

```bash
rm -rf _ul-Dell-PCn _ul-Dell-PCn-2 _ul-RazinkaX1
```

**Step 4: Add patterns to `.gitignore`**

Append to `.gitignore`:

```
# OneDrive sync conflict files
*-laguna-safeBackup*
# Editor backup files
*.backup_*
# Unknown sync artifacts
_ul-*
```

**Step 5: Commit**

```bash
git add -A .gitignore
git add utils-laguna-safeBackup-0001.R environmental_scenarios-laguna-safeBackup-0001.R guided_workflow_config-laguna-safeBackup-0001.R ui_content_sections-laguna-safeBackup-0001.R server_modules/bowtie_visualization_module-laguna-safeBackup-0001.R ui.R.backup_before_dashboard ui.R.backup_original ui_dashboard.R.backup_shinydashboard
git commit -m "chore: remove OneDrive conflict files, backup files, and sync artifacts"
```

---

### Task 7: Fix `cat()` in post-logging files

**Files:**
- Modify: `server.R` (2 cat() calls)
- Modify: `utils.R` (2 cat() calls)

**Step 1: Find and replace cat() calls in `server.R`**

Search for `cat(` in server.R. These should be changed to `log_debug()` or `log_info()` since server.R loads after `config/logging.R`.

**Step 2: Find and replace cat() calls in `utils.R`**

Same treatment for utils.R.

**Step 3: Commit**

```bash
git add server.R utils.R
git commit -m "fix: replace cat() with log_debug() in files loaded after logging system"
```

---

## Phase 2: Performance Fixes

### Task 8: Vectorize O(n^2) loops in `vocabulary_ai_linker.R`

**Files:**
- Modify: `vocabulary_ai_linker.R` (lines 403-455 — Activity->Pressure and Pressure->Consequence loops)

**Step 1: Replace nested for-loops with vectorized cross-join + apply**

The current pattern (lines 405-427):
```r
for (i in 1:nrow(activities)) {
  for (j in 1:nrow(pressures)) {
    score <- get_word_overlap_score(activities[i,]$name, pressures[j,]$name)
    if (score > 0.2) {
      basic_links <- rbind(basic_links, data.frame(...))
    }
  }
}
```

Replace with vectorized approach:

```r
# Activity → Pressure connections
if (nrow(vocabulary_data$activities) > 0 && nrow(vocabulary_data$pressures) > 0) {
  pairs <- expand.grid(
    i = seq_len(nrow(vocabulary_data$activities)),
    j = seq_len(nrow(vocabulary_data$pressures)),
    KEEP.OUT.ATTRS = FALSE
  )

  scores <- mapply(
    function(i, j) get_word_overlap_score(
      vocabulary_data$activities$name[i],
      vocabulary_data$pressures$name[j]
    ),
    pairs$i, pairs$j
  )

  keep <- scores > 0.2
  if (any(keep)) {
    kept_pairs <- pairs[keep, ]
    activity_pressure_links <- data.frame(
      from_id = vocabulary_data$activities$id[kept_pairs$i],
      from_name = vocabulary_data$activities$name[kept_pairs$i],
      from_type = "Activity",
      to_id = vocabulary_data$pressures$id[kept_pairs$j],
      to_name = vocabulary_data$pressures$name[kept_pairs$j],
      to_type = "Pressure",
      similarity = scores[keep],
      method = "basic_word_overlap",
      stringsAsFactors = FALSE
    )
    basic_links <- rbind(basic_links, activity_pressure_links)
  }
}
```

Apply the same vectorization to the Pressure→Consequence loop (lines 432-455).

**Step 2: Apply the same pattern to all other nested loop sites**

Grep for the same pattern at lines 648-661, 790-825, 898-920, 1323-1337, 1654-1680.

Each site should be converted from:
```r
for (i in ...) { for (j in ...) { rbind(...) } }
```
To:
```r
pairs <- expand.grid(i, j); scores <- mapply(...); filter; single rbind
```

**Step 3: Verify the AI linker still works**

Run: `Rscript -e "source('global.R'); cat('Vocabulary loaded:', nrow(vocabulary_data$activities), 'activities\n')"`

Expected: No errors, vocabulary loads successfully.

**Step 4: Commit**

```bash
git add vocabulary_ai_linker.R
git commit -m "perf: vectorize O(n^2) nested loops in vocabulary AI linker"
```

---

### Task 9: Replace `rbind()` in loops with list accumulation

**Files:**
- Modify: `vocabulary_ai_linker.R` (any remaining rbind-in-loop patterns after Task 8)
- Modify: `custom_terms_module.R:189,303`
- Modify: `dev_config.R:112`

**Step 1: Fix pattern in each file**

For any remaining `rbind()` in loop patterns, convert from:

```r
result <- data.frame()
for (...) {
  result <- rbind(result, data.frame(...))
}
```

To:

```r
result_list <- list()
for (...) {
  result_list[[length(result_list) + 1]] <- data.frame(...)
}
result <- if (length(result_list) > 0) do.call(rbind, result_list) else data.frame()
```

This is the same pattern already used correctly in `utils.R:1530` and `utils.R:2424`.

**Step 2: Commit**

```bash
git add vocabulary_ai_linker.R custom_terms_module.R dev_config.R
git commit -m "perf: replace rbind-in-loops with list accumulation + do.call(rbind)"
```

---

## Phase 3: Guided Workflow Deduplication

### Task 10: Replace 4 duplicating tables with `create_simple_datatable()`

**Files:**
- Modify: `guided_workflow.R` (lines ~2428-2453, ~2622-2650, ~2785-2810, ~3000-3025)

**Step 1: Replace preventive controls table (lines ~2428-2453)**

```r
# BEFORE (20+ lines):
  output$selected_preventive_controls_table <- renderDT({
    controls <- selected_preventive_controls()
    if (length(controls) == 0) {
      dt_data <- data.frame(Control = character(0), stringsAsFactors = FALSE)
    } else {
      dt_data <- data.frame(Control = controls, stringsAsFactors = FALSE)
    }
    DT::datatable(dt_data, options = list(...), ...)
  })

# AFTER (3 lines):
  output$selected_preventive_controls_table <- renderDT({
    create_simple_datatable(selected_preventive_controls(), "Control")
  })
```

**Step 2: Apply same replacement to consequences, protective controls, and escalation factors tables**

Each follows the identical pattern — replace with a one-liner calling `create_simple_datatable()`.

**Step 3: Verify tables still render**

Start the app and navigate through workflow steps 4-7, confirming tables display correctly.

**Step 4: Commit**

```bash
git add guided_workflow.R
git commit -m "refactor: replace 4 duplicate table renderers with create_simple_datatable()"
```

---

### Task 11: Create factory function for 5 add-item observers

**Files:**
- Modify: `guided_workflow.R`

This is the highest-impact deduplication. The 5 observers at lines 2079 (activities), 2187 (pressures), 2363 (preventive controls), 2557 (consequences), 2719 (protective controls) follow an identical pattern.

**Step 1: Define the factory function**

Add this near the top of the `moduleServer` block (around line 1490, after reactive values are defined):

```r
# Factory function for "add item" observers
# Replaces 5 identical ~60-line observeEvent handlers with a parameterized version
create_add_item_observer <- function(
  add_button_id,        # e.g., "add_activity"
  item_type,            # e.g., "activities" (key in project_data)
  custom_toggle_id,     # e.g., "activity_custom_toggle"
  custom_text_id,       # e.g., "activity_custom_text"
  item_input_id,        # e.g., "activity_item"
  reactive_selected,    # e.g., selected_activities (reactiveVal)
  translation_added,    # e.g., "gw_added_activity"
  translation_exists,   # e.g., "gw_activity_exists"
  group_input_id = NULL # e.g., "activity_group" (for selectize restore)
) {
  observeEvent(input[[add_button_id]], {
    item_name <- NULL
    is_custom <- FALSE

    if (!is.null(input[[custom_toggle_id]]) && input[[custom_toggle_id]]) {
      item_name <- input[[custom_text_id]]
      is_custom <- TRUE
    } else {
      item_name <- input[[item_input_id]]
    }

    if (!is.null(item_name) && !is.na(item_name) && nchar(trimws(item_name)) > 0) {
      current <- reactive_selected()

      if (!item_name %in% current) {
        current <- c(current, item_name)
        reactive_selected(current)

        if (is_custom) {
          custom_list <- custom_entries()
          custom_list[[item_type]] <- c(custom_list[[item_type]], item_name)
          custom_entries(custom_list)

          tryCatch({
            state <- workflow_state()
            project_name <- if (!is.null(state$project_data$project_name)) state$project_data$project_name else ""
            add_custom_term(item_type, item_name, "default", project_name)
          }, error = function(e) {
            log_warning(paste("Failed to persist custom term:", e$message))
          })

          showNotification(
            paste("Added custom", gsub("_", " ", sub("s$", "", item_type)), ":", item_name, "(marked for review)"),
            type = "message", duration = 3
          )
        } else {
          showNotification(paste(t(translation_added, lang()), item_name), type = "message", duration = 2)
        }

        state <- workflow_state()
        state$project_data[[item_type]] <- current
        state$project_data$custom_entries <- custom_entries()
        workflow_state(state)

        # Save parent group before clearing child (prevents Selectize.js cascade)
        saved_group <- if (!is.null(group_input_id)) input[[group_input_id]] else NULL

        updateSelectizeInput(session, session$ns(item_input_id), selected = character(0))
        if (is_custom) {
          updateTextInput(session, session$ns(custom_text_id), value = "")
        }

        # Restore parent group via JS if needed
        if (!is.null(saved_group) && !is.null(group_input_id) && nchar(saved_group) > 0) {
          ns_id <- session$ns(group_input_id)
          shinyjs::runjs(sprintf(
            "setTimeout(function() {
              var elem = $('#%s');
              if (elem.length > 0 && elem[0].selectize) {
                elem[0].selectize.setValue('%s', false);
              }
            }, 200);",
            ns_id, saved_group
          ))
        }
      } else {
        showNotification(t(translation_exists, lang()), type = "warning", duration = 2)
      }
    } else {
      showNotification(
        paste("Please select a", gsub("_", " ", sub("s$", "", item_type)), "or enter a custom name"),
        type = "warning", duration = 2
      )
    }
  })
}
```

**Step 2: Replace the 5 observers with factory calls**

Replace the ~300 lines of 5 observers with:

```r
# Step 3: Add Activity observer
create_add_item_observer(
  add_button_id = "add_activity",
  item_type = "activities",
  custom_toggle_id = "activity_custom_toggle",
  custom_text_id = "activity_custom_text",
  item_input_id = "activity_item",
  reactive_selected = selected_activities,
  translation_added = "gw_added_activity",
  translation_exists = "gw_activity_exists",
  group_input_id = "activity_group"
)

# Step 3: Add Pressure observer
create_add_item_observer(
  add_button_id = "add_pressure",
  item_type = "pressures",
  custom_toggle_id = "pressure_custom_toggle",
  custom_text_id = "pressure_custom_text",
  item_input_id = "pressure_item",
  reactive_selected = selected_pressures,
  translation_added = "gw_added_pressure",
  translation_exists = "gw_pressure_exists",
  group_input_id = "pressure_group"
)

# Step 4: Add Preventive Control observer
create_add_item_observer(
  add_button_id = "add_preventive_control",
  item_type = "preventive_controls",
  custom_toggle_id = "preventive_control_custom_toggle",
  custom_text_id = "preventive_control_custom_text",
  item_input_id = "preventive_control_item",
  reactive_selected = selected_preventive_controls,
  translation_added = "gw_added_control",
  translation_exists = "gw_control_exists"
)

# Step 5: Add Consequence observer
create_add_item_observer(
  add_button_id = "add_consequence",
  item_type = "consequences",
  custom_toggle_id = "consequence_custom_toggle",
  custom_text_id = "consequence_custom_text",
  item_input_id = "consequence_item",
  reactive_selected = selected_consequences,
  translation_added = "gw_added_consequence",
  translation_exists = "gw_consequence_exists"
)

# Step 6: Add Protective Control observer
create_add_item_observer(
  add_button_id = "add_protective_control",
  item_type = "protective_controls",
  custom_toggle_id = "protective_control_custom_toggle",
  custom_text_id = "protective_control_custom_text",
  item_input_id = "protective_control_item",
  reactive_selected = selected_protective_controls,
  translation_added = "gw_added_protective",
  translation_exists = "gw_protective_exists"
)
```

**Step 3: Carefully verify input IDs match**

Before committing, grep each input ID (e.g., `add_preventive_control`, `preventive_control_custom_toggle`, etc.) in `guided_workflow.R` and `guided_workflow_ai_suggestions.R` to confirm they match the UI definitions.

**Step 4: Test**

Start the app, navigate to guided workflow, and test adding items in each step (3-6) — both from vocabulary selection and custom entry mode. Confirm:
- Items appear in the table
- Duplicate prevention works
- Custom entries get the "marked for review" notification
- Parent group selectize restores correctly for activities and pressures

**Step 5: Commit**

```bash
git add guided_workflow.R
git commit -m "refactor: replace 5 identical add-item observers with factory function (~220 lines removed)"
```

---

### Task 12: Replace 4 duplicate step-sync observers with factory function

**Files:**
- Modify: `guided_workflow.R`

**Step 1: Define factory for step-sync observers**

The 6 observers at lines 2020, 2333, 2507, 2673, 2829, 3312 follow the same pattern. Create:

```r
create_step_sync_observer <- function(
  step_number,
  vocab_type,        # e.g., "activities", "pressures", "controls", "consequences"
  search_input_id,   # e.g., "activity_search", "preventive_control_search"
  reactive_selected, # e.g., selected_activities
  state_key          # e.g., "activities" (key in project_data)
) {
  observe({
    state <- workflow_state()
    if (!is.null(state) && state$current_step == step_number) {
      # Update vocabulary choices
      if (!is.null(vocabulary_data) && !is.null(vocabulary_data[[vocab_type]])) {
        choices <- vocabulary_data[[vocab_type]]$name
        if (length(choices) > 0) {
          log_debug(paste("Updating", search_input_id, "with", length(choices), "choices"))
          updateSelectizeInput(session, search_input_id,
                             choices = choices, server = TRUE, selected = character(0))
        }
      }

      # Load from state if available
      if (!is.null(state$project_data[[state_key]]) && length(state$project_data[[state_key]]) > 0) {
        reactive_selected(as.character(state$project_data[[state_key]]))
      }
    }
  })
}
```

**Step 2: Replace the 4 most clearly identical observers**

Read each observer carefully first. Some may have slight differences (extra vocabulary types, group selectors). Only replace observers that are truly identical after parameterization.

**Step 3: Test by navigating through all 8 workflow steps**

**Step 4: Commit**

```bash
git add guided_workflow.R
git commit -m "refactor: replace duplicate step-sync observers with factory function"
```

---

## Phase 4: Documentation & CLAUDE.md Updates

### Task 13: Update CLAUDE.md logging documentation

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Add `log_success` to the documented logging functions**

In the "Logging Standards" section, add:

```r
log_success("Success message")           # Success level
```

**Step 2: Add explicit prohibitions**

After the "Avoid" section, add:

```markdown
**Never use after global.R loads:**
- `message()` — bypasses centralized logging configuration
- `warning()` — bypasses centralized logging configuration
- `print()` — use `log_debug()` instead
```

**Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add log_success to CLAUDE.md, document logging prohibitions"
```

---

### Task 14: Final verification

**Step 1: Run the test suite**

```bash
Rscript tests/run_tests.R
```

Expected: All existing tests pass.

**Step 2: Start the app and smoke-test critical paths**

```bash
Rscript start_app.R
```

Test:
- Load sample data on main page
- Navigate to guided workflow
- Complete steps 1-3 (add activities, pressures)
- Add/remove items in steps 4-6
- Export from step 8
- View bowtie diagram

**Step 3: Final commit with version bump**

Update `VERSION` file and commit all remaining changes.

```bash
git add VERSION VERSION_HISTORY.md
git commit -m "chore: bump version after codebase cleanup"
```

---

## Out of Scope (Deferred to Future Work)

The following items from the audit are **intentionally excluded** from this plan because they require multi-day architectural changes and should be planned separately:

- **Monolith splitting** — `guided_workflow.R` (4,364 lines), `server.R` (3,506 lines) decomposition
- **Naming convention migration** — Renaming 20 camelCase functions to snake_case (requires updating all call sites)
- **Proper Shiny modularization** — Converting 10 pseudo-modules to `moduleServer` pattern
- **Notification helper migration** — Replacing 189 raw `showNotification` calls with `notify_*()` helpers
- **Missing `req()` audit** — Adding ~70+ missing `req()` calls across server.R reactive chains
- **Reactive cascade optimization** — Adding debounce/throttle to `workflow_state` observers
