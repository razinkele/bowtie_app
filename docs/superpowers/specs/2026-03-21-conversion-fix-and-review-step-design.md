# Design: Conversion Fix & Manual Review Step

**Date:** 2026-03-21
**Status:** Approved
**Scope:** Fix silent element truncation in bowtie export + add interactive review step

---

## Problem Statement

Two related issues degrade the guided workflow's reliability:

1. **Silent element truncation**: `convert_to_main_data_format()` in `guided_workflow_conversion.R` uses nested `for` loops with hardcoded limits (`min(3, ...)` for activities, `min(2, ...)` for everything else). Users who select more items than these limits see only a subset in the final diagram, with no warning.

2. **No manual review capability**: Steps 7-8 are read-only. Users cannot review, adjust, or deselect elements before export. AI-suggested links cannot be validated or overridden.

---

## Fix 1: Conversion — Include All User-Selected Elements

### Current behavior

```
guided_workflow_conversion.R lines 74-101:

for (activity in activities[1:min(3, length(activities))]) {
  for (pressure in pressures[1:min(2, length(pressures))]) {
    for (preventive in preventive_controls[1:min(2, ...)]) {
      for (consequence in consequences[1:min(2, ...)]) {
        for (protective in protective_controls[1:min(2, ...)]) {
          # Creates one row per combination
```

Max elements kept: 3 activities, 2 pressures, 2 preventive controls, 2 consequences, 2 protective controls. Everything else silently dropped.

### New behavior

Replace nested loops with vector recycling:

```r
n_rows <- max(
  length(activities), length(pressures),
  length(preventive_controls), length(consequences),
  length(protective_controls), 1
)

bowtie_data <- data.frame(
  Central_Problem = rep(central_problem, n_rows),
  Activity = if (length(activities) > 0) rep_len(activities, n_rows) else NA_character_,
  Pressure = if (length(pressures) > 0) rep_len(pressures, n_rows) else NA_character_,
  Preventive_Control = if (length(preventive_controls) > 0) rep_len(preventive_controls, n_rows) else NA_character_,
  Consequence = if (length(consequences) > 0) rep_len(consequences, n_rows) else NA_character_,
  Protective_Mitigation = if (length(protective_controls) > 0) rep_len(protective_controls, n_rows) else NA_character_,
  Escalation_Factor = if (length(escalation_factors) > 0) rep_len(escalation_factors, n_rows) else NA_character_,
  Likelihood = 3L,
  Severity = 3L,
  stringsAsFactors = FALSE
)
```

**Why recycling is correct for bowtie topology**: In a bowtie diagram, all causes converge on the central problem and all consequences fan out. The row-level pairings created by recycling are not meaningful relationships — downstream code extracts unique values per column for node creation (`utils.R` lines ~1654, ~1998 use `unique()` per column). A code comment will document this assumption.

**Row count comparison**: For 10 activities, 8 pressures, 7 controls, 5 consequences, 6 protective controls:
- Old approach: `3 * 2 * 2 * 2 * 2 = 48` rows (with truncation!)
- New approach: `max(10, 8, 7, 5, 6) = 10` rows (all elements included)

**Note on Excel export**: Row-level pairings in the exported spreadsheet are artifacts of the recycling and do not represent specific causal relationships. The bowtie topology (all-to-central-problem) is the semantic model. This will be documented in export comments.

### Additional changes in conversion

- **Remove dummy escalation factors** (lines 48-58): If user provides none, column is `NA`.
- **Replace `sample(1:5, 1)`** with `3L` for Likelihood/Severity defaults. Makes function deterministic.
- **Remove fallback sample data path** (lines 103-122): No more fabricated "Sample Activity" data. Empty columns stay `NA`.
- **Accept `excluded_items` and `disabled_connections` parameters** from the review step (Fix 2).
- **Replace `cat()` with `bowtie_log()`**: The conversion file loads after `global.R`, so per project logging standards, use `bowtie_log()` / `log_info()` instead of raw `cat()` calls (lines ~57, ~105, ~140-146). Also applies to `guided_workflow_validation.R` line ~249.

### NA-safety in downstream consumers

Three files use `unique()` extraction and must handle `NA`:

**`utils.R`** — Node/edge extraction (lines ~1654, ~1998):
```r
# Before:
unique(hazard_data$Activity[hazard_data$Activity != ""])
# After:
unique(hazard_data$Activity[!is.na(hazard_data$Activity) & hazard_data$Activity != ""])
```

**`bowtie_bayesian_network.r`** — BN structure building (lines ~89-95):

The code uses `paste0("ACT_", .bn_clean_text(bowtie_data$Activity))` to create node IDs row-by-row, then calls `unique()` on the combined vector (line ~98). NA values will produce spurious `"ACT_NA"` / `"PRES_NA"` / `"ESC_NA"` nodes in the Bayesian network graph (not a crash, but incorrect nodes).

Fix: Filter NA rows before node ID creation:
```r
# Remove rows where key columns are NA before BN construction
bowtie_data <- bowtie_data[!is.na(bowtie_data$Activity) | !is.na(bowtie_data$Pressure), ]
# Also guard individual column access:
act_nodes <- if (any(!is.na(bowtie_data$Activity))) {
  unique(paste0("ACT_", .bn_clean_text(bowtie_data$Activity[!is.na(bowtie_data$Activity)])))
} else { character(0) }
```

### Files modified

| File | Change |
|------|--------|
| `guided_workflow_conversion.R` | Replace nested loops with `rep_len()`, remove truncation, remove dummy data, add parameters |
| `utils.R` | Add `!is.na()` checks in node/edge extraction |
| `bowtie_bayesian_network.r` | Add NA filtering before BN structure creation |
| `tests/testthat/test-guided-workflow.R` | Add tests: all elements appear, no truncation, NA handling |

---

## Fix 2: Manual Review & Adjust Step

### Workflow restructure: 8 steps → 9 steps

| Step | Current | New |
|------|---------|-----|
| 1-6 | Unchanged | Unchanged |
| 7 | Escalation Factors (config says "Review & Validate") | Escalation Factors (fix config ID) |
| 8 | Finalize & Export | **NEW: Review & Adjust** |
| 9 | — | Finalize & Export (moved from 8) |

### Config ID cleanup

The current config has a mismatch: step 7's config says `id = "review_validate"`, `title = "Review & Validate"` but the UI (`guided_workflow_ui.R` line ~837) generates escalation factor content. The sidebar displays "Review & Validate" while the actual content is escalation factors.

Fix both the ID and the title:
```r
# guided_workflow_config.R — fix mismatch between IDs and actual content
step7: id = "escalation_factors", title = "Escalation Factors"  # was id="review_validate", title="Review & Validate"
step8: id = "review_adjust",      title = "Review & Adjust"     # NEW
step9: id = "finalize_export",    title = "Finalize & Export"   # was step 8
```

Step duration vector: `c(2.5, 4, 7.5, 6.5, 4, 6.5, 4, 5, 2.5)` (insert 5 min for new step 8).

### Pre-requisite: Hardcoded step number audit

All literal references to step 8 as the final step must be replaced with dynamic references. Known locations:

| File | Location | Current | Change to |
|------|----------|---------|-----------|
| `guided_workflow_export.R` | line 82 | `if (!8 %in% state$completed_steps)` (add-if-not-present pattern) | Replace literal `8` with `state$total_steps` |
| `server.R` | line 1106 | `state$current_step >= 8` | `state$current_step >= state$total_steps` |
| `guided_workflow_validation.R` | line 28 | 8-element `step_durations` vector in `estimate_remaining_time()` | 9-element vector: `c(2.5, 4, 7.5, 6.5, 4, 6.5, 4, 5, 2.5)` |
| `guided_workflow_validation.R` | line 42 | `validate_step()` switch cases "1"-"8" | Add case "8" for review validation, case "9" for finalize |
| `guided_workflow_validation.R` | line 104 | `validate_current_step()` only validates steps 1-2, rest return TRUE | Add step 8 validation call (required categories check) — must wire into this function, not just `validate_step()` |
| `guided_workflow_export.R` | line 640 | `else if (loaded_state$current_step == 7)` branch for reactive restoration | Add `else if (loaded_state$current_step == 8)` branch to restore review exclusion data |
| `guided_workflow_export.R` | help modal (lines ~418-439) | Lists 8 steps in ordered list | Update to 9 steps with new Step 8 description |
| `guided_workflow.R` | line 662 | `step_num %in% c(3, 4, 5, 6)` | Add `8` for vocabulary data access in review step |
| Test files (5+) | Various | `total_steps = 8` | `total_steps = 9` |

### Pre-requisite: Persist connection data in workflow state

Currently, connections exist only as session-scoped reactiveVals:
- `activity_pressure_connections` (guided_workflow.R line ~557)
- `preventive_control_links` (line ~565)
- `consequence_protective_links` (line ~571)

These must be saved into `project_data` during `save_step_data()` for Steps 3-6 so that:
1. They survive save/load cycles
2. The Review step can read them
3. The conversion function can consume them

**Persistence sketch for `save_step_data()`:**
```r
# Step 3: save activity-pressure connections
if (step == 3) {
  # ... existing element saves ...
  conn <- activity_pressure_connections()
  if (!is.null(conn) && nrow(conn) > 0) {
    state$project_data$connections_act_pres <- conn
  }
}
# Step 4: save control-pressure links
if (step == 4) {
  conn <- preventive_control_links()
  if (!is.null(conn) && nrow(conn) > 0) {
    state$project_data$connections_ctrl_pres <- conn
  }
}
# Step 6: save consequence-protective links (created in Step 6, not Step 5)
if (step == 6) {
  conn <- consequence_protective_links()
  if (!is.null(conn) && nrow(conn) > 0) {
    state$project_data$connections_cons_prot <- conn
  }
}
```

**Unified connection schema for review step (Tab 6):**

The three connection dataframes have different schemas. For the review table, normalize to:
```r
# Unified connection schema
connections_unified <- data.frame(
  from = character(),    # source element name
  to = character(),      # target element name
  type = character(),    # one of: "activity_pressure", "control_pressure", "consequence_protective"
  enabled = logical(),   # TRUE by default, user can toggle
  stringsAsFactors = FALSE
)
```

Type strings used in the connections table:
- `"activity_pressure"` — displayed as "Activity -> Pressure"
- `"control_pressure"` — displayed as "Control -> Pressure"
- `"consequence_protective"` — displayed as "Consequence -> Protective"

### Step 8 UI: Review & Adjust

**Layout**: `tabsetPanel` with 6 tabs.

**Tabs 1-5: Element review** (Activities, Pressures, Preventive Controls, Consequences, Protective Controls)

Each tab contains:
```
┌─────────────────────────────────────────┐
│ [Select All] [Deselect All]             │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ checkboxGroupInput (scrollable div) │ │
│ │ max-height: 400px, overflow-y: auto │ │
│ │                                     │ │
│ │ ☑ Item A                            │ │
│ │ ☑ Item B                            │ │
│ │ ☐ Item C  (unchecked = excluded)    │ │
│ │ ☑ Item D                            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Summary: 3 of 4 items included          │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ DT table (read-only, included only) │ │
│ │ Shows only checked items            │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

- All user-selected items shown, all pre-checked (included by default)
- Unchecking excludes from diagram but item stays visible (can re-check)
- Items from vocabulary and custom entries both shown

**Tab 6: Connections review**

```
┌───────────────────────────────────────────────────┐
│ Connection type filter: [All ▾]                    │
│                                                    │
│ ┌───────────────────────────────────────────────┐ │
│ │ From            │ To              │ Type   │ ✓ │ │
│ │─────────────────│─────────────────│────────│───│ │
│ │ Shipping        │ Oil pollution   │ Act→Pr │ ☑ │ │
│ │ Fishing         │ Bycatch         │ Act→Pr │ ☑ │ │
│ │ ⚠ Dredging*    │ Habitat loss    │ Act→Pr │ ☑ │ │
│ │ Oil pollution   │ Species decline │ Pr→Con │ ☐ │ │
│ └───────────────────────────────────────────────┘ │
│                                                    │
│ * ⚠ = parent element is deselected in element tabs │
│                                                    │
│ Enabled: 3 of 4 connections                        │
└───────────────────────────────────────────────────┘
```

- Pre-populated from persisted connection data (Steps 3-6)
- Toggle checkbox per row to enable/disable
- Warning icon on connections where either endpoint is deselected in element tabs (no auto-cascade — user decides)
- Type filter dropdown: All, Activity→Pressure, Control→Pressure, Consequence→Protective

### Server logic for Step 8

```r
# Reactive: reviewed_selections()
# Reads checkboxGroupInput values and disabled_connections
# Returns filtered lists ready for conversion

reviewed_selections <- reactive({
  list(
    activities = input$review_activities,          # checked items only
    pressures = input$review_pressures,
    preventive_controls = input$review_preventive,
    consequences = input$review_consequences,
    protective_controls = input$review_protective,
    connections = get_enabled_connections()          # only enabled rows
  )
})
```

### Data flow (complete)

```
Steps 3-6: User selects items + connections created
     ↓
save_step_data(): Persists items + connections in project_data
     ↓
Step 7: Escalation factors (unchanged)
     ↓
Step 8 (NEW): Review & Adjust
  - checkboxGroupInput per category (pre-populated from project_data)
  - Connections table (pre-populated from project_data connections)
  - User deselects items, toggles connections
  - reviewed_selections() reactive captures final state
     ↓
Step 9: Finalize & Export
  - convert_to_main_data_format(reviewed_selections())
  - Only included items + enabled connections used
     ↓
Bowtie diagram: Shows exactly what user approved
```

### Validation for Step 8

Required categories (at least 1 item must remain checked):
- Activities
- Pressures
- Consequences

Optional categories (can be empty):
- Preventive Controls
- Protective Controls

If a required category is fully deselected, the "Next" button is disabled and a message appears: "At least one [category] must be selected to proceed."

### State persistence

Exclusion state stored in `project_data`:
```r
project_data$excluded_activities     # character vector of unchecked items
project_data$excluded_pressures
project_data$excluded_preventive
project_data$excluded_consequences
project_data$excluded_protective
project_data$disabled_connections    # dataframe: from, to, type (disabled only)
```

Stored as exclusions (not inclusions) so that adding new items in earlier steps automatically includes them by default.

### Backward compatibility

Migration in load-progress handler:
```r
if (is.null(loaded_state$total_steps) || loaded_state$total_steps < 9) {
  loaded_state$total_steps <- 9
  # Remap old step 8 (finalize) to new step 9
  if (!is.null(loaded_state$current_step) && loaded_state$current_step == 8) {
    loaded_state$current_step <- 9
  }
  # Update completed_steps: 8 → 9
  if (8 %in% loaded_state$completed_steps) {
    loaded_state$completed_steps <- c(
      setdiff(loaded_state$completed_steps, 8), 9
    )
  }
  # Initialize empty exclusion fields
  if (is.null(loaded_state$project_data$excluded_activities)) {
    loaded_state$project_data$excluded_activities <- character(0)
    loaded_state$project_data$excluded_pressures <- character(0)
    loaded_state$project_data$excluded_preventive <- character(0)
    loaded_state$project_data$excluded_consequences <- character(0)
    loaded_state$project_data$excluded_protective <- character(0)
    loaded_state$project_data$disabled_connections <- data.frame(
      from = character(0), to = character(0), type = character(0),
      stringsAsFactors = FALSE
    )
  }
}
```

### Files modified

| File | Change | Effort |
|------|--------|--------|
| `guided_workflow_config.R` | Add step 8 config, renumber step 9, fix step 7 ID | Low |
| `guided_workflow_ui.R` | Add `generate_step8_ui()`, rename old step8 to `generate_step9_ui()` | High |
| `guided_workflow.R` | Step 8 server logic, vocabulary routing, connection persistence | High |
| `guided_workflow_validation.R` | `validate_step8()`, `save_step_data()` for step 8, step durations, step 9 case | Medium |
| `guided_workflow_export.R` | Replace hardcoded `8` with dynamic refs, migration handler, pass reviewed_selections | Medium |
| `guided_workflow_conversion.R` | Accept exclusions + connections parameters, filter before building dataframe | Medium |
| `server.R` | Update `>= 8` to `>= 9` check | Low |
| Test files (6+) | Update `total_steps` assertions, add Step 8 review tests | Medium |

---

## Implementation Order

1. **Hardcoded step number audit** — Replace all literal step references with dynamic ones
2. **Conversion fix** — Replace nested loops with `rep_len()`, add NA-safety downstream
3. **Conversion tests** — Test all elements appear, no truncation, NA handling, Escalation_Factor column present (test-first catches omissions early)
4. **Connection persistence** — Save connection reactiveVals into `project_data` in `save_step_data()`
5. **Config + navigation** — Add step 8 config, update step count, fix config IDs, update help modal
6. **Step 8 UI** — Build Review & Adjust interface with checkboxGroupInput + connections table
7. **Step 8 server logic** — Wire up reviewed_selections(), validation (in both `validate_step()` and `validate_current_step()`), state persistence
8. **Wire conversion to review** — Pass reviewed_selections() to convert_to_main_data_format()
9. **Backward compatibility** — Migration handler for 8-step saved files
10. **Integration tests** — Review step tests, end-to-end workflow tests with 9 steps

---

## Out of Scope (Future Work)

- **Provenance tracking** (AI-suggested vs Manual source column) — requires schema change across multiple files
- **Confidence score editing** — no current infrastructure for per-item metadata
- **Undo/redo in review** — reset to defaults covers the main case
- **Auto-cascade on deselect** — too much reactive complexity for v1
