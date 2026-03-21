# Conversion Fix & Review Step Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix silent element truncation in bowtie export and add an interactive Review & Adjust step (Step 8) to the guided workflow.

**Architecture:** Replace the nested-loop conversion with vector recycling to include all user-selected elements. Add a new Step 8 between current Step 7 (Escalation Factors) and current Step 8 (Finalize/Export, becomes Step 9). Step 8 uses `checkboxGroupInput` per element category + a connections toggle table. Persist connection data and exclusions in workflow state.

**Tech Stack:** R, Shiny, bslib, DT, checkboxGroupInput, reactiveVal

**Spec:** `docs/superpowers/specs/2026-03-21-conversion-fix-and-review-step-design.md`

---

## File Structure

| File | Responsibility | Action |
|------|---------------|--------|
| `guided_workflow_conversion.R` | Data conversion from workflow to bowtie format | Modify: replace nested loops with `rep_len()` |
| `utils.R` | Node/edge extraction for bowtie visualization | Modify: add NA-safety to `unique()` filters |
| `bowtie_bayesian_network.r` | Bayesian network structure building | Modify: filter NA before node ID creation |
| `guided_workflow_config.R` | Workflow step configuration | Modify: fix step 7 ID, add step 8, renumber step 9 |
| `guided_workflow_validation.R` | Step validation + data saving | Modify: add step 8/9 validation, connection persistence, step durations |
| `guided_workflow_ui.R` | Step UI generators | Modify: add `generate_step8_ui()`, rename old step8 to `generate_step9_ui()` |
| `guided_workflow.R` | Core server logic + navigation | Modify: step 8 server handlers, vocabulary routing, reviewed_selections reactive |
| `guided_workflow_export.R` | Export, save/load, finalization | Modify: replace hardcoded `8` with dynamic refs, migration handler, help modal |
| `server.R` | Main Shiny server | Modify: update completion check from `>= 8` to `>= state$total_steps` |
| `tests/testthat/test-conversion-fix.R` | Conversion function tests | Create |
| `tests/testthat/test-review-step.R` | Review & Adjust step tests | Create |
| `tests/testthat/helper-setup.R` | Test helpers/mock state | Modify: update `total_steps = 9` |
| Multiple test files | Various test assertions | Modify: update hardcoded `total_steps = 8` |

---

## Task 1: Conversion Fix — Write Tests

**Files:**
- Create: `tests/testthat/test-conversion-fix.R`
- Read: `guided_workflow_conversion.R` (understand current function signature)

- [ ] **Step 1: Create test file with conversion tests**

```r
# tests/testthat/test-conversion-fix.R
# Tests for convert_to_main_data_format() fix
# Verifies: no truncation, all elements included, NA handling, deterministic output

test_that("convert_to_main_data_format includes ALL activities (no truncation)", {
  project_data <- list(
    problem_statement = "Test Problem",
    project_name = "Test Project",
    activities = c("Act1", "Act2", "Act3", "Act4", "Act5", "Act6", "Act7", "Act8"),
    pressures = c("Pres1", "Pres2", "Pres3"),
    preventive_controls = c("PC1", "PC2", "PC3", "PC4"),
    consequences = c("Con1", "Con2", "Con3", "Con4", "Con5"),
    protective_controls = c("Prot1", "Prot2", "Prot3"),
    escalation_factors = c("EF1", "EF2")
  )

  result <- convert_to_main_data_format(project_data)

  # All 8 activities must appear
  unique_activities <- unique(result$Activity[!is.na(result$Activity) & result$Activity != ""])
  expect_equal(length(unique_activities), 8)
  expect_true(all(project_data$activities %in% unique_activities))
})

test_that("convert_to_main_data_format includes ALL pressures (no truncation)", {
  project_data <- list(
    problem_statement = "Test Problem",
    project_name = "Test Project",
    activities = c("Act1", "Act2"),
    pressures = c("Pres1", "Pres2", "Pres3", "Pres4", "Pres5"),
    preventive_controls = c("PC1"),
    consequences = c("Con1"),
    protective_controls = c("Prot1"),
    escalation_factors = c("EF1")
  )

  result <- convert_to_main_data_format(project_data)

  unique_pressures <- unique(result$Pressure[!is.na(result$Pressure) & result$Pressure != ""])
  expect_equal(length(unique_pressures), 5)
  expect_true(all(project_data$pressures %in% unique_pressures))
})

test_that("convert_to_main_data_format row count equals max vector length", {
  project_data <- list(
    problem_statement = "Test Problem",
    project_name = "Test Project",
    activities = c("A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10"),
    pressures = c("P1", "P2", "P3"),
    preventive_controls = c("PC1", "PC2"),
    consequences = c("C1", "C2", "C3", "C4", "C5"),
    protective_controls = c("Pr1"),
    escalation_factors = c("EF1", "EF2")
  )

  result <- convert_to_main_data_format(project_data)

  # Row count should equal max(10, 3, 2, 5, 1, 2) = 10
  expect_equal(nrow(result), 10)
})

test_that("convert_to_main_data_format has Escalation_Factor column", {
  project_data <- list(
    problem_statement = "Test Problem",
    project_name = "Test Project",
    activities = c("Act1"),
    pressures = c("Pres1"),
    preventive_controls = c("PC1"),
    consequences = c("Con1"),
    protective_controls = c("Prot1"),
    escalation_factors = c("EF1", "EF2")
  )

  result <- convert_to_main_data_format(project_data)

  expect_true("Escalation_Factor" %in% names(result))
  unique_efs <- unique(result$Escalation_Factor[!is.na(result$Escalation_Factor)])
  expect_true(all(c("EF1", "EF2") %in% unique_efs))
})

test_that("convert_to_main_data_format handles empty escalation factors with NA", {
  project_data <- list(
    problem_statement = "Test Problem",
    project_name = "Test Project",
    activities = c("Act1"),
    pressures = c("Pres1"),
    preventive_controls = c("PC1"),
    consequences = c("Con1"),
    protective_controls = c("Prot1"),
    escalation_factors = character(0)
  )

  result <- convert_to_main_data_format(project_data)

  expect_true("Escalation_Factor" %in% names(result))
  # Should be NA, not dummy text
  expect_true(all(is.na(result$Escalation_Factor)))
})

test_that("convert_to_main_data_format handles empty optional columns with NA", {
  project_data <- list(
    problem_statement = "Test Problem",
    project_name = "Test Project",
    activities = c("Act1", "Act2"),
    pressures = c("Pres1"),
    preventive_controls = character(0),
    consequences = c("Con1"),
    protective_controls = character(0),
    escalation_factors = character(0)
  )

  result <- convert_to_main_data_format(project_data)

  expect_true(all(is.na(result$Preventive_Control)))
  expect_true(all(is.na(result$Protective_Mitigation)))
  expect_true(all(is.na(result$Escalation_Factor)))
  # Non-empty columns should NOT have NA
  expect_false(any(is.na(result$Activity)))
  expect_false(any(is.na(result$Pressure)))
})

test_that("convert_to_main_data_format is deterministic (no random sampling)", {
  project_data <- list(
    problem_statement = "Test Problem",
    project_name = "Test Project",
    activities = c("Act1", "Act2"),
    pressures = c("Pres1", "Pres2"),
    preventive_controls = c("PC1"),
    consequences = c("Con1"),
    protective_controls = c("Prot1"),
    escalation_factors = c("EF1")
  )

  result1 <- convert_to_main_data_format(project_data)
  result2 <- convert_to_main_data_format(project_data)

  expect_identical(result1$Likelihood, result2$Likelihood)
  expect_identical(result1$Severity, result2$Severity)
  expect_identical(result1$Escalation_Factor, result2$Escalation_Factor)
})

test_that("convert_to_main_data_format has Risk_Level column", {
  project_data <- list(
    problem_statement = "Test Problem",
    project_name = "Test Project",
    activities = c("Act1"),
    pressures = c("Pres1"),
    preventive_controls = c("PC1"),
    consequences = c("Con1"),
    protective_controls = c("Prot1"),
    escalation_factors = c("EF1")
  )

  result <- convert_to_main_data_format(project_data)

  expect_true("Risk_Level" %in% names(result))
  # With Likelihood=3, Severity=3, Risk_Level = 3*3=9 -> "Medium"
  expect_equal(result$Risk_Level[1], "Medium")
})

test_that("convert_to_main_data_format Central_Problem is constant across all rows", {
  project_data <- list(
    problem_statement = "My Central Problem",
    project_name = "Test Project",
    activities = c("A1", "A2", "A3"),
    pressures = c("P1"),
    preventive_controls = c("PC1"),
    consequences = c("C1"),
    protective_controls = c("Pr1"),
    escalation_factors = c("EF1")
  )

  result <- convert_to_main_data_format(project_data)

  expect_true(all(result$Central_Problem == "My Central Problem"))
})
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd "C:/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript -e "source('guided_workflow_validation.R'); source('guided_workflow_conversion.R'); testthat::test_file('tests/testthat/test-conversion-fix.R')"`

Expected: Multiple failures — truncation tests fail (only 3 activities kept), deterministic test fails (`sample()` used), empty escalation test fails (dummy data injected).

- [ ] **Step 3: Commit test file**

```bash
git add tests/testthat/test-conversion-fix.R
git commit -m "test: add conversion fix tests — verifies no truncation, NA handling, determinism"
```

---

## Task 2: Conversion Fix — Replace Nested Loops

**Files:**
- Modify: `guided_workflow_conversion.R:26-167` (the entire `convert_to_main_data_format` function)

- [ ] **Step 1: Replace the function body**

Replace lines 47-146 of `guided_workflow_conversion.R` with:

```r
    # If no escalation factors provided, leave as empty (NA in output)
    # Do NOT inject dummy escalation factors

    # =========================================================================
    # Build bowtie dataframe using vector recycling
    # =========================================================================
    # In bowtie topology, all causes converge on the central problem and all
    # consequences fan out. Row-level pairings from recycling are NOT meaningful
    # relationships — downstream code (utils.R, bowtie_bayesian_network.r)
    # extracts unique values per column for node creation.
    # This approach includes ALL user-selected elements with no truncation.
    # Row count = max of all vector lengths (linear, not exponential).
    # =========================================================================

    n_rows <- max(
      length(activities), length(pressures),
      length(preventive_controls), length(consequences),
      length(protective_controls), length(escalation_factors), 1
    )

    bowtie_data <- data.frame(
      Activity = if (length(activities) > 0) rep_len(activities, n_rows) else NA_character_,
      Pressure = if (length(pressures) > 0) rep_len(pressures, n_rows) else NA_character_,
      Preventive_Control = if (length(preventive_controls) > 0) rep_len(preventive_controls, n_rows) else NA_character_,
      Escalation_Factor = if (length(escalation_factors) > 0) rep_len(escalation_factors, n_rows) else NA_character_,
      Central_Problem = rep(central_problem, n_rows),
      Protective_Mitigation = if (length(protective_controls) > 0) rep_len(protective_controls, n_rows) else NA_character_,
      Consequence = if (length(consequences) > 0) rep_len(consequences, n_rows) else NA_character_,
      Likelihood = 3L,
      Severity = 3L,
      stringsAsFactors = FALSE
    )

    # Calculate risk level
    bowtie_data$Risk_Level <- ifelse(
      bowtie_data$Likelihood * bowtie_data$Severity <= 6, "Low",
      ifelse(bowtie_data$Likelihood * bowtie_data$Severity <= 15, "Medium", "High")
    )

    # Add metadata
    attr(bowtie_data, "project_name") <- project_name
    attr(bowtie_data, "created_from") <- "guided_workflow"
    attr(bowtie_data, "created_at") <- Sys.time()
    esc_count <- length(unique(escalation_factors[nchar(escalation_factors) > 0]))
    attr(bowtie_data, "escalation_factors_count") <- esc_count
    attr(bowtie_data, "note") <- "Escalation factors threaten control effectiveness, not the central problem directly"

    bowtie_log(paste("Generated", nrow(bowtie_data), "bow-tie pathway(s)"), level = "info")
    bowtie_log(paste("Components:",
        length(unique(bowtie_data$Activity[!is.na(bowtie_data$Activity)])), "activities,",
        length(unique(bowtie_data$Pressure[!is.na(bowtie_data$Pressure)])), "pressures,",
        length(unique(bowtie_data$Preventive_Control[!is.na(bowtie_data$Preventive_Control)])), "preventive controls,",
        length(unique(bowtie_data$Protective_Mitigation[!is.na(bowtie_data$Protective_Mitigation)])), "protective controls,",
        length(unique(bowtie_data$Consequence[!is.na(bowtie_data$Consequence)])), "consequences,",
        length(unique(bowtie_data$Escalation_Factor[!is.na(bowtie_data$Escalation_Factor)])), "escalation factors"),
        level = "info")

    return(bowtie_data)
```

Also replace the `cat()` at line 204 with:
```r
bowtie_log("   - guided_workflow_conversion.R loaded (data conversion + integration)", level = "debug")
```

- [ ] **Step 2: Run conversion tests to verify they pass**

Run: `cd "C:/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript -e "source('config/logging.R'); source('guided_workflow_validation.R'); source('guided_workflow_conversion.R'); testthat::test_file('tests/testthat/test-conversion-fix.R')"`

Expected: All 9 tests PASS.

- [ ] **Step 3: Commit**

```bash
git add guided_workflow_conversion.R
git commit -m "fix: replace nested loop truncation with rep_len — all elements now included"
```

---

## Task 3: NA-Safety in Downstream Consumers

**Files:**
- Modify: `utils.R:1654-1656` and `utils.R:1998-2000`
- Modify: `bowtie_bayesian_network.r:88-99`

- [ ] **Step 1: Add NA-safety to utils.R node extraction (line 1654)**

Replace the three lines at `utils.R:1654-1656`:
```r
  activities <- unique(hazard_data$Activity[hazard_data$Activity != ""])
  pressures <- unique(hazard_data$Pressure[hazard_data$Pressure != ""])
  consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
```
With:
```r
  activities <- unique(hazard_data$Activity[!is.na(hazard_data$Activity) & hazard_data$Activity != ""])
  pressures <- unique(hazard_data$Pressure[!is.na(hazard_data$Pressure) & hazard_data$Pressure != ""])
  consequences <- unique(hazard_data$Consequence[!is.na(hazard_data$Consequence) & hazard_data$Consequence != ""])
```

- [ ] **Step 2: Add NA-safety to utils.R edge extraction (line 1998)**

Replace the three lines at `utils.R:1998-2000`:
```r
  activities <- unique(hazard_data$Activity[hazard_data$Activity != ""])
  pressures <- unique(hazard_data$Pressure[hazard_data$Pressure != ""])
  consequences <- unique(hazard_data$Consequence[hazard_data$Consequence != ""])
```
With:
```r
  activities <- unique(hazard_data$Activity[!is.na(hazard_data$Activity) & hazard_data$Activity != ""])
  pressures <- unique(hazard_data$Pressure[!is.na(hazard_data$Pressure) & hazard_data$Pressure != ""])
  consequences <- unique(hazard_data$Consequence[!is.na(hazard_data$Consequence) & hazard_data$Consequence != ""])
```

- [ ] **Step 3: Add NA-safety to bowtie_bayesian_network.r (lines 88-99)**

Before line 89 (`act_nodes <- paste0(...)`), add NA filtering:
```r
  # Filter out rows where ALL key columns are NA (from rep_len recycling with empty vectors)
  valid_rows <- !is.na(bowtie_data$Activity) | !is.na(bowtie_data$Pressure) |
                !is.na(bowtie_data$Consequence)
  bowtie_data <- bowtie_data[valid_rows, , drop = FALSE]

  if (nrow(bowtie_data) == 0) {
    bowtie_log("No valid rows for Bayesian network after NA filtering", level = "warning")
    return(list(nodes = data.frame(), edges = data.frame(), dag = NULL))
  }
```

Then wrap each node ID creation (lines 89-95) with NA guards:
```r
  # Create node IDs, filtering NA values per column to avoid spurious "ACT_NA" nodes
  act_nodes <- if (any(!is.na(bowtie_data$Activity))) {
    paste0("ACT_", .bn_clean_text(bowtie_data$Activity[!is.na(bowtie_data$Activity)]))
  } else { character(0) }

  pres_nodes <- if (any(!is.na(bowtie_data$Pressure))) {
    paste0("PRES_", .bn_clean_text(bowtie_data$Pressure[!is.na(bowtie_data$Pressure)]))
  } else { character(0) }

  ctrl_nodes <- if (any(!is.na(bowtie_data$Preventive_Control))) {
    paste0("CTRL_", .bn_clean_text(bowtie_data$Preventive_Control[!is.na(bowtie_data$Preventive_Control)]))
  } else { character(0) }

  esc_nodes <- if (any(!is.na(bowtie_data$Escalation_Factor))) {
    paste0("ESC_", .bn_clean_text(bowtie_data$Escalation_Factor[!is.na(bowtie_data$Escalation_Factor)]))
  } else { character(0) }

  prob_nodes <- paste0("PROB_", .bn_clean_text(bowtie_data$Central_Problem))

  mit_nodes <- if (any(!is.na(protective_col))) {
    paste0("MIT_", .bn_clean_text(protective_col[!is.na(protective_col)]))
  } else { character(0) }

  cons_nodes <- if (any(!is.na(bowtie_data$Consequence))) {
    paste0("CONS_", .bn_clean_text(bowtie_data$Consequence[!is.na(bowtie_data$Consequence)]))
  } else { character(0) }
```

- [ ] **Step 4: Run existing tests to verify no regressions**

Run: `cd "C:/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript tests/test_runner.R`

Expected: All existing tests pass.

- [ ] **Step 5: Commit**

```bash
git add utils.R bowtie_bayesian_network.r
git commit -m "fix: add NA-safety to node/edge extraction — prevents spurious NA nodes"
```

---

## Task 4: Hardcoded Step Number Audit

**Files:**
- Modify: `guided_workflow_export.R:82-83`
- Modify: `server.R:1106-1107`
- Modify: `server.R:1355-1367`
- Modify: `guided_workflow_validation.R:28`
- Modify: `guided_workflow_validation.R:104`
- Modify: `guided_workflow_validation.R:249`

- [ ] **Step 1: Fix guided_workflow_export.R line 82**

Replace:
```r
    if (!8 %in% state$completed_steps) {
      state$completed_steps <- c(state$completed_steps, 8)
    }
```
With:
```r
    if (!state$total_steps %in% state$completed_steps) {
      state$completed_steps <- c(state$completed_steps, state$total_steps)
    }
```

- [ ] **Step 2: Fix server.R line 1106**

Replace:
```r
        state$current_step >= 8 &&
        length(state$completed_steps) >= 7) {
```
With:
```r
        state$current_step >= state$total_steps &&
        length(state$completed_steps) >= (state$total_steps - 1)) {
```

- [ ] **Step 3: Fix server.R badge renderer (line 1355 area)**

Replace:
```r
      if (current_step > 0 && current_step <= 8) {
```
With:
```r
      if (current_step > 0 && current_step <= 9) {
```

Note: This could also use a dynamic reference, but the badge renderer doesn't have access to `workflow_state()`. Using `9` is acceptable since it matches the new total.

- [ ] **Step 4: Fix guided_workflow_validation.R line 249**

Replace:
```r
cat("   - guided_workflow_validation.R loaded (validation + save functions)\n")
```
With:
```r
bowtie_log("   - guided_workflow_validation.R loaded (validation + save functions)", level = "debug")
```

- [ ] **Step 5: Run tests to verify no regressions**

Run: `cd "C:/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript tests/test_runner.R`

Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add guided_workflow_export.R server.R guided_workflow_validation.R
git commit -m "fix: replace hardcoded step-8 references with dynamic total_steps"
```

---

## Task 5: Config + Navigation — Add Step 8, Renumber Step 9

**Files:**
- Modify: `guided_workflow_config.R:59-72`
- Modify: `guided_workflow_validation.R:28` (step durations)
- Modify: `guided_workflow_validation.R:42-53` (validate_step switch)
- Modify: `guided_workflow_validation.R:99-106` (validate_current_step)
- Modify: `guided_workflow_validation.R:167-172` (validate_step8 function)
- Modify: `guided_workflow.R:662` (vocabulary routing)

- [ ] **Step 1: Update guided_workflow_config.R steps**

Replace lines 59-72:
```r
    step7 = list(
      id = "review_validate",
      title = "Review & Validate",
      description = "gw_step7_desc",
      icon = "check-circle",
      estimated_time = "gw_step7_time"
    ),
    step8 = list(
      id = "finalize_export",
      title = "Finalize & Export",
      description = "gw_step8_desc",
      icon = "download",
      estimated_time = "gw_step8_time"
    )
```
With:
```r
    step7 = list(
      id = "escalation_factors",
      title = "Escalation Factors",
      description = "gw_step7_desc",
      icon = "bolt",
      estimated_time = "gw_step7_time"
    ),
    step8 = list(
      id = "review_adjust",
      title = "Review & Adjust",
      description = "gw_step8_desc",
      icon = "check-double",
      estimated_time = "gw_step8_time"
    ),
    step9 = list(
      id = "finalize_export",
      title = "Finalize & Export",
      description = "gw_step9_desc",
      icon = "download",
      estimated_time = "gw_step9_time"
    )
```

- [ ] **Step 2: Update step durations vector**

In `guided_workflow_validation.R` line 28, replace:
```r
  step_durations <- c(2.5, 4, 7.5, 6.5, 4, 6.5, 4, 2.5)  # Average minutes per step
```
With:
```r
  step_durations <- c(2.5, 4, 7.5, 6.5, 4, 6.5, 4, 5, 2.5)  # Average minutes per step (9 steps)
```

- [ ] **Step 3: Update validate_step switch statement**

In `guided_workflow_validation.R` lines 42-53, replace:
```r
validate_step <- function(step_number, data) {
  switch(as.character(step_number),
         "1" = validate_step1(data),
         "2" = validate_step2(data),
         "3" = validate_step3(data),
         "4" = validate_step4(data),
         "5" = validate_step5(data),
         "6" = validate_step6(data),
         "7" = validate_step7(data),
         "8" = validate_step8(data),
         # Default
         list(valid = TRUE, message = "")
  )
}
```
With:
```r
validate_step <- function(step_number, data) {
  switch(as.character(step_number),
         "1" = validate_step1(data),
         "2" = validate_step2(data),
         "3" = validate_step3(data),
         "4" = validate_step4(data),
         "5" = validate_step5(data),
         "6" = validate_step6(data),
         "7" = validate_step7(data),
         "8" = validate_step8_review(data),
         "9" = validate_step9(data),
         # Default
         list(valid = TRUE, message = "")
  )
}
```

- [ ] **Step 4: Rename old validate_step8 and add new functions**

Replace lines 167-172:
```r
#' Step 8 validation: Export
#' @param data Project data
#' @return List with valid and message
validate_step8 <- function(data) {
  list(valid = TRUE, message = "")
}
```
With:
```r
#' Step 8 validation: Review & Adjust
#' Requires at least 1 activity, 1 pressure, and 1 consequence
#' @param data Project data (with exclusion lists)
#' @return List with valid and message
validate_step8_review <- function(data) {
  # Check required categories have at least 1 included item
  activities <- data$activities %||% list()
  excluded_act <- data$excluded_activities %||% character(0)
  included_act <- setdiff(as.character(activities), excluded_act)

  pressures <- data$pressures %||% list()
  excluded_pres <- data$excluded_pressures %||% character(0)
  included_pres <- setdiff(as.character(pressures), excluded_pres)

  consequences <- data$consequences %||% list()
  excluded_cons <- data$excluded_consequences %||% character(0)
  included_cons <- setdiff(as.character(consequences), excluded_cons)

  if (length(included_act) == 0) {
    return(list(valid = FALSE, message = "At least one activity must be selected to proceed."))
  }
  if (length(included_pres) == 0) {
    return(list(valid = FALSE, message = "At least one pressure must be selected to proceed."))
  }
  if (length(included_cons) == 0) {
    return(list(valid = FALSE, message = "At least one consequence must be selected to proceed."))
  }

  list(valid = TRUE, message = "")
}

#' Step 9 validation: Finalize & Export
#' @param data Project data
#' @return List with valid and message
validate_step9 <- function(data) {
  list(valid = TRUE, message = "")
}
```

- [ ] **Step 5: Update validate_current_step for step 8**

In `guided_workflow_validation.R` lines 99-106, replace:
```r
    # Steps 3-8: Optional validation - can proceed without entries
    list(is_valid = TRUE, message = "")
```
With:
```r
    # Step 8: Review & Adjust — require at least 1 activity, pressure, consequence
    "8" = {
      state_data <- if (!is.null(input$review_activities)) {
        list(
          activities = input$review_activities,
          pressures = input$review_pressures,
          consequences = input$review_consequences,
          excluded_activities = character(0),
          excluded_pressures = character(0),
          excluded_consequences = character(0)
        )
      } else {
        list(activities = list(), pressures = list(), consequences = list(),
             excluded_activities = character(0), excluded_pressures = character(0),
             excluded_consequences = character(0))
      }
      result <- validate_step8_review(state_data)
      list(is_valid = result$valid, message = result$message)
    },
    # Steps 3-7, 9: Optional validation
    list(is_valid = TRUE, message = "")
```

- [ ] **Step 6: Update vocabulary routing in guided_workflow.R**

At `guided_workflow.R` line 662, replace:
```r
      if (step_num %in% c(3, 4, 5, 6)) {
```
With:
```r
      if (step_num %in% c(3, 4, 5, 6, 8)) {
```

- [ ] **Step 7: Run tests**

Run: `cd "C:/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript tests/test_runner.R`

Expected: Tests pass. Some test files with hardcoded `total_steps = 8` may fail — that's expected and addressed in Task 9.

- [ ] **Step 8: Commit**

```bash
git add guided_workflow_config.R guided_workflow_validation.R guided_workflow.R
git commit -m "feat: add step 8 config (Review & Adjust), renumber finalize to step 9"
```

---

## Task 6: Connection Persistence in save_step_data

**Files:**
- Modify: `guided_workflow_validation.R:201-241` (save_step_data function)

- [ ] **Step 1: Add connection persistence to save_step_data**

After the existing step 3 block (line 211), add connection save. After step 4 block (line 218), add. After step 6 block (line 232), add.

Replace lines 201-241 with:
```r
  } else if (step == 3) {
    # Save activities and pressures data
    if (is.null(state$project_data$activities)) {
      state$project_data$activities <- list()
    }
    if (is.null(state$project_data$pressures)) {
      state$project_data$pressures <- list()
    }
    # Note: Connection persistence happens in the next_step observer in guided_workflow.R
    # (where the reactiveVals are in scope), NOT here. See Task 8, Step 7.
  } else if (step == 4) {
    # Save preventive controls data
    if (is.null(state$project_data$preventive_controls)) {
      state$project_data$preventive_controls <- list()
    }
  } else if (step == 5) {
    # Save consequences data
    if (is.null(state$project_data$consequences)) {
      state$project_data$consequences <- list()
    }
  } else if (step == 6) {
    # Save protective controls data
    if (is.null(state$project_data$protective_controls)) {
      state$project_data$protective_controls <- list()
    }
  } else if (step == 7) {
    # Save escalation factors data
    if (is.null(state$project_data$escalation_factors)) {
      state$project_data$escalation_factors <- list()
    }
  } else if (step == 8) {
    # Review exclusions saved by next_step observer in guided_workflow.R
  }
  # Step 9 is finalize only - no data to save
```

**IMPORTANT:** `save_step_data()` does NOT have access to connection reactiveVals (they are scoped inside `moduleServer()` in `guided_workflow.R`). Connection persistence is handled in the `observeEvent(input$next_step, ...)` handler in `guided_workflow.R` — see Task 8, Step 7 — where the reactiveVals are in scope. Do NOT use `parent.frame()` or similar environment tricks.

- [ ] **Step 2: Commit**

```bash
git add guided_workflow_validation.R
git commit -m "feat: add connection persistence to save_step_data for steps 3, 4, 6"
```

---

## Task 7: Step 8 UI — Review & Adjust Interface

**Files:**
- Modify: `guided_workflow_ui.R:925-992` (rename old step8 UI, add new review UI)

- [ ] **Step 1: Rename old generate_step8_ui to generate_step9_ui**

At line 925, replace:
```r
# Step 8: Review & Finalize
generate_step8_ui <- function(session = NULL, current_lang = "en") {
```
With:
```r
# Step 9: Finalize & Export (was Step 8)
generate_step9_ui <- function(session = NULL, current_lang = "en") {
```

- [ ] **Step 2: Add new generate_step8_ui function before the renamed step 9**

**IMPORTANT:** The function MUST be named `generate_step8_ui` (not `generate_step8_ui`) because the dynamic routing at `guided_workflow.R` line 657 constructs function names via `paste0("generate_step", step_num, "_ui")`. Using any other name will cause a "UI for step 8 not found" error.

Insert before the renamed `generate_step9_ui` (before old line 925):

```r
# Step 8: Review & Adjust
generate_step8_ui <- function(vocabulary_data = NULL, session = NULL, current_lang = "en") {
  ns <- if (!is.null(session)) session$ns else identity

  tagList(
    div(class = "alert alert-info",
        h5(icon("check-double"), " Review & Adjust Your Selections"),
        p("Review all elements selected in previous steps. Uncheck items to exclude them from the final bowtie diagram. Toggle connections on/off in the Connections tab.")
    ),

    tabsetPanel(
      id = ns("review_tabs"),

      # Tab 1: Activities
      tabPanel("Activities",
        br(),
        fluidRow(
          column(6,
            actionButton(ns("select_all_activities"), "Select All", class = "btn-sm btn-outline-primary"),
            actionButton(ns("deselect_all_activities"), "Deselect All", class = "btn-sm btn-outline-secondary")
          ),
          column(6, class = "text-end",
            uiOutput(ns("activities_count_summary"))
          )
        ),
        br(),
        div(style = "max-height: 400px; overflow-y: auto; border: 1px solid #dee2e6; border-radius: 4px; padding: 10px;",
          checkboxGroupInput(ns("review_activities"), label = NULL, choices = character(0), selected = character(0))
        ),
        br(),
        h6("Included Activities:"),
        DT::DTOutput(ns("review_activities_table"))
      ),

      # Tab 2: Pressures
      tabPanel("Pressures",
        br(),
        fluidRow(
          column(6,
            actionButton(ns("select_all_pressures"), "Select All", class = "btn-sm btn-outline-primary"),
            actionButton(ns("deselect_all_pressures"), "Deselect All", class = "btn-sm btn-outline-secondary")
          ),
          column(6, class = "text-end",
            uiOutput(ns("pressures_count_summary"))
          )
        ),
        br(),
        div(style = "max-height: 400px; overflow-y: auto; border: 1px solid #dee2e6; border-radius: 4px; padding: 10px;",
          checkboxGroupInput(ns("review_pressures"), label = NULL, choices = character(0), selected = character(0))
        ),
        br(),
        h6("Included Pressures:"),
        DT::DTOutput(ns("review_pressures_table"))
      ),

      # Tab 3: Preventive Controls
      tabPanel("Preventive Controls",
        br(),
        fluidRow(
          column(6,
            actionButton(ns("select_all_preventive"), "Select All", class = "btn-sm btn-outline-primary"),
            actionButton(ns("deselect_all_preventive"), "Deselect All", class = "btn-sm btn-outline-secondary")
          ),
          column(6, class = "text-end",
            uiOutput(ns("preventive_count_summary"))
          )
        ),
        br(),
        div(style = "max-height: 400px; overflow-y: auto; border: 1px solid #dee2e6; border-radius: 4px; padding: 10px;",
          checkboxGroupInput(ns("review_preventive"), label = NULL, choices = character(0), selected = character(0))
        ),
        br(),
        h6("Included Preventive Controls:"),
        DT::DTOutput(ns("review_preventive_table"))
      ),

      # Tab 4: Consequences
      tabPanel("Consequences",
        br(),
        fluidRow(
          column(6,
            actionButton(ns("select_all_consequences"), "Select All", class = "btn-sm btn-outline-primary"),
            actionButton(ns("deselect_all_consequences"), "Deselect All", class = "btn-sm btn-outline-secondary")
          ),
          column(6, class = "text-end",
            uiOutput(ns("consequences_count_summary"))
          )
        ),
        br(),
        div(style = "max-height: 400px; overflow-y: auto; border: 1px solid #dee2e6; border-radius: 4px; padding: 10px;",
          checkboxGroupInput(ns("review_consequences"), label = NULL, choices = character(0), selected = character(0))
        ),
        br(),
        h6("Included Consequences:"),
        DT::DTOutput(ns("review_consequences_table"))
      ),

      # Tab 5: Protective Controls
      tabPanel("Protective Controls",
        br(),
        fluidRow(
          column(6,
            actionButton(ns("select_all_protective"), "Select All", class = "btn-sm btn-outline-primary"),
            actionButton(ns("deselect_all_protective"), "Deselect All", class = "btn-sm btn-outline-secondary")
          ),
          column(6, class = "text-end",
            uiOutput(ns("protective_count_summary"))
          )
        ),
        br(),
        div(style = "max-height: 400px; overflow-y: auto; border: 1px solid #dee2e6; border-radius: 4px; padding: 10px;",
          checkboxGroupInput(ns("review_protective"), label = NULL, choices = character(0), selected = character(0))
        ),
        br(),
        h6("Included Protective Controls:"),
        DT::DTOutput(ns("review_protective_table"))
      ),

      # Tab 6: Connections
      tabPanel("Connections",
        br(),
        fluidRow(
          column(6,
            selectInput(ns("connection_type_filter"), "Filter by type:",
                       choices = c("All", "Activity -> Pressure", "Control -> Pressure", "Consequence -> Protective"),
                       selected = "All")
          ),
          column(6, class = "text-end",
            uiOutput(ns("connections_count_summary"))
          )
        ),
        br(),
        DT::DTOutput(ns("review_connections_table")),
        br(),
        p(class = "text-muted small", "Uncheck connections to exclude them from the final bowtie diagram. Connections involving deselected elements are marked with a warning icon.")
      )
    )
  )
}

```

- [ ] **Step 3: Verify routing works automatically**

The routing at `guided_workflow.R` line 657 uses `paste0("generate_step", step_num, "_ui")` to dynamically find UI functions. Since we named the new function `generate_step8_ui` and the old one `generate_step9_ui`, the routing will find both automatically — **no code changes needed for routing**. Just update the file header comment in `guided_workflow_ui.R` (lines 1-16) to list the correct step structure:
```r
#   - generate_step7_ui()           - Escalation Factors
#   - generate_step8_ui()           - Review & Adjust
#   - generate_step9_ui()           - Finalize & Export
```

- [ ] **Step 4: Commit**

```bash
git add guided_workflow_ui.R guided_workflow.R
git commit -m "feat: add Step 8 Review & Adjust UI with tabbed element checkboxes and connections"
```

---

## Task 8: Step 8 Server Logic

**Files:**
- Modify: `guided_workflow.R` (add server handlers for Step 8)

This is the largest task. Add the following server-side handlers inside the `moduleServer()` function in `guided_workflow.R`:

- [ ] **Step 1: Add reviewed_selections reactive and step 8 initialization observer**

Add near the other step-specific reactive values:

```r
  # =========================================================================
  # STEP 8: Review & Adjust — Server Logic
  # =========================================================================

  # Initialize Step 8 checkboxes when entering the step
  observeEvent(current_step_reactive(), {
    req(current_step_reactive() == 8)
    state <- workflow_state()
    pd <- state$project_data

    # Populate checkboxGroupInputs with user's selections from Steps 3-6
    activities <- as.character(pd$activities %||% list())
    pressures <- as.character(pd$pressures %||% list())
    preventive <- as.character(pd$preventive_controls %||% list())
    consequences <- as.character(pd$consequences %||% list())
    protective <- as.character(pd$protective_controls %||% list())

    # Determine which items are excluded (restore from saved state)
    excl_act <- pd$excluded_activities %||% character(0)
    excl_pres <- pd$excluded_pressures %||% character(0)
    excl_prev <- pd$excluded_preventive %||% character(0)
    excl_cons <- pd$excluded_consequences %||% character(0)
    excl_prot <- pd$excluded_protective %||% character(0)

    # Update checkboxes: all items as choices, selected = included (not excluded)
    updateCheckboxGroupInput(session, "review_activities",
      choices = activities, selected = setdiff(activities, excl_act))
    updateCheckboxGroupInput(session, "review_pressures",
      choices = pressures, selected = setdiff(pressures, excl_pres))
    updateCheckboxGroupInput(session, "review_preventive",
      choices = preventive, selected = setdiff(preventive, excl_prev))
    updateCheckboxGroupInput(session, "review_consequences",
      choices = consequences, selected = setdiff(consequences, excl_cons))
    updateCheckboxGroupInput(session, "review_protective",
      choices = protective, selected = setdiff(protective, excl_prot))

    # Build unified connections table
    connections <- build_unified_connections(pd)
    review_connections_data(connections)
  })

  # Reactive store for connections data (with enabled toggles)
  review_connections_data <- reactiveVal(data.frame(
    from = character(0), to = character(0), type = character(0), enabled = logical(0),
    stringsAsFactors = FALSE
  ))
```

- [ ] **Step 2: Add helper function to build unified connections**

Add before or after the observer:

```r
  # Build unified connections from project_data's three connection sources
  build_unified_connections <- function(pd) {
    rows <- list()

    # Activity -> Pressure connections
    conn1 <- pd$connections_act_pres
    if (!is.null(conn1) && is.data.frame(conn1) && nrow(conn1) > 0) {
      for (i in seq_len(nrow(conn1))) {
        rows[[length(rows) + 1]] <- data.frame(
          from = conn1$Activity[i], to = conn1$Pressure[i],
          type = "activity_pressure", enabled = TRUE, stringsAsFactors = FALSE)
      }
    }

    # Control -> Pressure connections
    conn2 <- pd$connections_ctrl_pres
    if (!is.null(conn2) && is.data.frame(conn2) && nrow(conn2) > 0) {
      for (i in seq_len(nrow(conn2))) {
        rows[[length(rows) + 1]] <- data.frame(
          from = conn2$Control[i], to = conn2$Target[i],
          type = "control_pressure", enabled = TRUE, stringsAsFactors = FALSE)
      }
    }

    # Consequence -> Protective connections
    conn3 <- pd$connections_cons_prot
    if (!is.null(conn3) && is.data.frame(conn3) && nrow(conn3) > 0) {
      for (i in seq_len(nrow(conn3))) {
        rows[[length(rows) + 1]] <- data.frame(
          from = conn3$Consequence[i], to = conn3$Control[i],
          type = "consequence_protective", enabled = TRUE, stringsAsFactors = FALSE)
      }
    }

    result <- if (length(rows) > 0) do.call(rbind, rows) else {
      data.frame(from = character(0), to = character(0), type = character(0),
                 enabled = logical(0), stringsAsFactors = FALSE)
    }

    # Apply saved disabled connections (restore from persisted state)
    disabled <- pd$disabled_connections
    if (!is.null(disabled) && is.data.frame(disabled) && nrow(disabled) > 0 && nrow(result) > 0) {
      for (i in seq_len(nrow(disabled))) {
        match_idx <- which(result$from == disabled$from[i] &
                           result$to == disabled$to[i] &
                           result$type == disabled$type[i])
        if (length(match_idx) > 0) {
          result$enabled[match_idx] <- FALSE
        }
      }
    }

    result
  }
```

- [ ] **Step 3: Add Select All / Deselect All handlers**

```r
  # Select All / Deselect All button handlers
  observeEvent(input$select_all_activities, {
    state <- workflow_state()
    all_items <- as.character(state$project_data$activities %||% list())
    updateCheckboxGroupInput(session, "review_activities", selected = all_items)
  })
  observeEvent(input$deselect_all_activities, {
    updateCheckboxGroupInput(session, "review_activities", selected = character(0))
  })

  observeEvent(input$select_all_pressures, {
    state <- workflow_state()
    all_items <- as.character(state$project_data$pressures %||% list())
    updateCheckboxGroupInput(session, "review_pressures", selected = all_items)
  })
  observeEvent(input$deselect_all_pressures, {
    updateCheckboxGroupInput(session, "review_pressures", selected = character(0))
  })

  observeEvent(input$select_all_preventive, {
    state <- workflow_state()
    all_items <- as.character(state$project_data$preventive_controls %||% list())
    updateCheckboxGroupInput(session, "review_preventive", selected = all_items)
  })
  observeEvent(input$deselect_all_preventive, {
    updateCheckboxGroupInput(session, "review_preventive", selected = character(0))
  })

  observeEvent(input$select_all_consequences, {
    state <- workflow_state()
    all_items <- as.character(state$project_data$consequences %||% list())
    updateCheckboxGroupInput(session, "review_consequences", selected = all_items)
  })
  observeEvent(input$deselect_all_consequences, {
    updateCheckboxGroupInput(session, "review_consequences", selected = character(0))
  })

  observeEvent(input$select_all_protective, {
    state <- workflow_state()
    all_items <- as.character(state$project_data$protective_controls %||% list())
    updateCheckboxGroupInput(session, "review_protective", selected = all_items)
  })
  observeEvent(input$deselect_all_protective, {
    updateCheckboxGroupInput(session, "review_protective", selected = character(0))
  })
```

- [ ] **Step 4: Add count summary renderers**

```r
  # Count summaries
  output$activities_count_summary <- renderUI({
    total <- length(as.character(workflow_state()$project_data$activities %||% list()))
    selected <- length(input$review_activities)
    tags$span(class = if (selected == 0 && total > 0) "text-danger" else "text-muted",
              paste(selected, "of", total, "included"))
  })

  output$pressures_count_summary <- renderUI({
    total <- length(as.character(workflow_state()$project_data$pressures %||% list()))
    selected <- length(input$review_pressures)
    tags$span(class = if (selected == 0 && total > 0) "text-danger" else "text-muted",
              paste(selected, "of", total, "included"))
  })

  output$preventive_count_summary <- renderUI({
    total <- length(as.character(workflow_state()$project_data$preventive_controls %||% list()))
    selected <- length(input$review_preventive)
    tags$span(class = if (selected == 0) "text-muted" else "text-muted",
              paste(selected, "of", total, "included"))
  })

  output$consequences_count_summary <- renderUI({
    total <- length(as.character(workflow_state()$project_data$consequences %||% list()))
    selected <- length(input$review_consequences)
    tags$span(class = if (selected == 0 && total > 0) "text-danger" else "text-muted",
              paste(selected, "of", total, "included"))
  })

  output$protective_count_summary <- renderUI({
    total <- length(as.character(workflow_state()$project_data$protective_controls %||% list()))
    selected <- length(input$review_protective)
    tags$span(class = if (selected == 0) "text-muted" else "text-muted",
              paste(selected, "of", total, "included"))
  })

  output$connections_count_summary <- renderUI({
    conn <- review_connections_data()
    total <- nrow(conn)
    enabled <- sum(conn$enabled)
    tags$span(class = "text-muted", paste(enabled, "of", total, "connections enabled"))
  })
```

- [ ] **Step 5: Add DT table renderers for included items**

```r
  # Read-only DT tables showing included items
  output$review_activities_table <- DT::renderDT({
    items <- input$review_activities
    if (length(items) > 0) {
      DT::datatable(data.frame(Activity = items), options = list(pageLength = 10, dom = 't'),
                    rownames = FALSE, selection = 'none')
    }
  })

  output$review_pressures_table <- DT::renderDT({
    items <- input$review_pressures
    if (length(items) > 0) {
      DT::datatable(data.frame(Pressure = items), options = list(pageLength = 10, dom = 't'),
                    rownames = FALSE, selection = 'none')
    }
  })

  output$review_preventive_table <- DT::renderDT({
    items <- input$review_preventive
    if (length(items) > 0) {
      DT::datatable(data.frame(Preventive_Control = items), options = list(pageLength = 10, dom = 't'),
                    rownames = FALSE, selection = 'none')
    }
  })

  output$review_consequences_table <- DT::renderDT({
    items <- input$review_consequences
    if (length(items) > 0) {
      DT::datatable(data.frame(Consequence = items), options = list(pageLength = 10, dom = 't'),
                    rownames = FALSE, selection = 'none')
    }
  })

  output$review_protective_table <- DT::renderDT({
    items <- input$review_protective
    if (length(items) > 0) {
      DT::datatable(data.frame(Protective_Control = items), options = list(pageLength = 10, dom = 't'),
                    rownames = FALSE, selection = 'none')
    }
  })

  # Connections table with toggle checkboxes
  output$review_connections_table <- DT::renderDT({
    conn <- review_connections_data()
    if (nrow(conn) == 0) return(NULL)

    # Apply type filter
    filter_type <- input$connection_type_filter
    if (!is.null(filter_type) && filter_type != "All") {
      type_map <- c(
        "Activity -> Pressure" = "activity_pressure",
        "Control -> Pressure" = "control_pressure",
        "Consequence -> Protective" = "consequence_protective"
      )
      conn <- conn[conn$type == type_map[[filter_type]], ]
    }

    # Format type for display
    display_type <- dplyr::case_when(
      conn$type == "activity_pressure" ~ "Activity -> Pressure",
      conn$type == "control_pressure" ~ "Control -> Pressure",
      conn$type == "consequence_protective" ~ "Consequence -> Protective",
      TRUE ~ conn$type
    )

    display_df <- data.frame(
      From = conn$from,
      To = conn$to,
      Type = display_type,
      Enabled = ifelse(conn$enabled, "Yes", "No"),
      stringsAsFactors = FALSE
    )

    DT::datatable(display_df, options = list(pageLength = 20, dom = 'tp'),
                  rownames = FALSE, selection = 'single')
  })
```

- [ ] **Step 6: Add connection toggle handler (click row to toggle enabled)**

```r
  # Toggle connection enabled/disabled when row is clicked
  observeEvent(input$review_connections_table_rows_selected, {
    row <- input$review_connections_table_rows_selected
    if (!is.null(row) && row > 0) {
      conn <- review_connections_data()
      if (row <= nrow(conn)) {
        conn$enabled[row] <- !conn$enabled[row]
        review_connections_data(conn)
      }
    }
  })
```

- [ ] **Step 7: Add reviewed_selections reactive for export consumption**

```r
  # Reactive: final reviewed selections ready for conversion
  reviewed_selections <- reactive({
    list(
      activities = input$review_activities %||% character(0),
      pressures = input$review_pressures %||% character(0),
      preventive_controls = input$review_preventive %||% character(0),
      consequences = input$review_consequences %||% character(0),
      protective_controls = input$review_protective %||% character(0),
      connections = {
        conn <- review_connections_data()
        conn[conn$enabled, , drop = FALSE]
      }
    )
  })
```

- [ ] **Step 8: Save exclusions and connections when leaving step 8**

In the `observeEvent(input$next_step, ...)` handler, add exclusion saving AND connection persistence before `save_step_data()`. This is the PRIMARY mechanism for persisting connection data (reactiveVals are in scope here, unlike in `save_step_data()`):

```r
    # Persist connection data when leaving steps 3, 4, 6 (reactiveVals in scope here)
    if (state$current_step == 3) {
      conn <- tryCatch(activity_pressure_connections(), error = function(e) NULL)
      if (!is.null(conn) && is.data.frame(conn) && nrow(conn) > 0) {
        state$project_data$connections_act_pres <- conn
      }
    } else if (state$current_step == 4) {
      conn <- tryCatch(preventive_control_links(), error = function(e) NULL)
      if (!is.null(conn) && is.data.frame(conn) && nrow(conn) > 0) {
        state$project_data$connections_ctrl_pres <- conn
      }
    } else if (state$current_step == 6) {
      conn <- tryCatch(consequence_protective_links(), error = function(e) NULL)
      if (!is.null(conn) && is.data.frame(conn) && nrow(conn) > 0) {
        state$project_data$connections_cons_prot <- conn
      }
    }

    # Persist review exclusions for step 8
    if (state$current_step == 8) {
      all_act <- as.character(state$project_data$activities %||% list())
      state$project_data$excluded_activities <- setdiff(all_act, input$review_activities %||% character(0))

      all_pres <- as.character(state$project_data$pressures %||% list())
      state$project_data$excluded_pressures <- setdiff(all_pres, input$review_pressures %||% character(0))

      all_prev <- as.character(state$project_data$preventive_controls %||% list())
      state$project_data$excluded_preventive <- setdiff(all_prev, input$review_preventive %||% character(0))

      all_cons <- as.character(state$project_data$consequences %||% list())
      state$project_data$excluded_consequences <- setdiff(all_cons, input$review_consequences %||% character(0))

      all_prot <- as.character(state$project_data$protective_controls %||% list())
      state$project_data$excluded_protective <- setdiff(all_prot, input$review_protective %||% character(0))

      # Save disabled connections
      conn <- review_connections_data()
      disabled_conn <- conn[!conn$enabled, c("from", "to", "type")]
      state$project_data$disabled_connections <- disabled_conn
    }
```

- [ ] **Step 9: Commit**

```bash
git add guided_workflow.R
git commit -m "feat: add Step 8 server logic — checkboxes, connections, select all, exclusion persistence"
```

---

## Task 9: Wire Conversion to Review + Export Updates

**Files:**
- Modify: `guided_workflow_export.R` (pass reviewed selections to conversion, update help modal)
- Modify: `guided_workflow_conversion.R` (accept optional reviewed_selections parameter)

- [ ] **Step 1: Update conversion function to accept reviewed selections**

In `guided_workflow_conversion.R`, update the function signature and add filtering at the top:

```r
convert_to_main_data_format <- function(project_data, reviewed_selections = NULL) {
  tryCatch({
    # If reviewed_selections provided, use filtered data
    if (!is.null(reviewed_selections)) {
      activities <- as.character(reviewed_selections$activities)
      pressures <- as.character(reviewed_selections$pressures)
      preventive_controls <- as.character(reviewed_selections$preventive_controls)
      consequences <- as.character(reviewed_selections$consequences)
      protective_controls <- as.character(reviewed_selections$protective_controls)
      escalation_factors <- as.character(project_data$escalation_factors %||% list())
    } else {
      # Fallback: use project_data directly (backward compatible)
      activities <- as.character(project_data$activities %||% list())
      pressures <- as.character(project_data$pressures %||% list())
      preventive_controls <- as.character(project_data$preventive_controls %||% list())
      consequences <- as.character(project_data$consequences %||% list())
      protective_controls <- as.character(project_data$protective_controls %||% list())
      escalation_factors <- as.character(project_data$escalation_factors %||% list())
    }
    # ... rest of function unchanged ...
```

- [ ] **Step 2: Update export handlers to pass reviewed_selections**

In `guided_workflow_export.R`, find where `convert_to_main_data_format(state$project_data)` is called and update to:

```r
    # Use reviewed selections if available (from Step 8)
    reviewed <- tryCatch(reviewed_selections(), error = function(e) NULL)
    converted_data <- convert_to_main_data_format(state$project_data, reviewed_selections = reviewed)
```

This applies to:
- The `finalize_workflow_btn` handler (~line 93)
- The `export_excel` handler
- The `load_to_main` handler

- [ ] **Step 3: Update help modal to list 9 steps**

In `guided_workflow_export.R` lines 418-439, replace the `tags$ol` content:

```r
        tags$ol(
          tags$li(strong("Project Setup"), " - Enter basic project information and select an environmental scenario template"),
          tags$li(strong("Central Problem"), " - Define the core environmental problem to analyze"),
          tags$li(strong("Threats & Causes"), " - Select activities and pressures from the vocabulary"),
          tags$li(strong("Preventive Controls"), " - Choose mitigation measures"),
          tags$li(strong("Consequences"), " - Identify potential environmental impacts"),
          tags$li(strong("Protective Controls"), " - Add protective measures and recovery controls"),
          tags$li(strong("Escalation Factors"), " - Define threats to control effectiveness"),
          tags$li(strong("Review & Adjust"), " - Review selections, toggle connections, exclude items"),
          tags$li(strong("Finalize & Export"), " - Export your completed bowtie analysis")
        ),
```

- [ ] **Step 4: Commit**

```bash
git add guided_workflow_conversion.R guided_workflow_export.R
git commit -m "feat: wire reviewed_selections to conversion, update help modal for 9 steps"
```

---

## Task 10: Backward Compatibility — Migration Handler

**Files:**
- Modify: `guided_workflow_export.R` (load progress handler, ~line 600-644 area)

- [ ] **Step 1: Add migration logic to load-progress handler**

Find the section that processes `loaded_state` after reading a saved JSON file. Add migration before using the state:

```r
    # Migrate 8-step saved files to 9-step format
    if (is.null(loaded_state$total_steps) || loaded_state$total_steps < 9) {
      loaded_state$total_steps <- 9
      # Remap old step 8 (finalize) to new step 9
      if (!is.null(loaded_state$current_step) && loaded_state$current_step == 8) {
        loaded_state$current_step <- 9
      }
      # Update completed_steps: 8 -> 9
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
      bowtie_log("Migrated saved workflow from 8-step to 9-step format", level = "info")
    }
```

- [ ] **Step 2: Add step 8 branch to reactive restoration chain**

After the `else if (loaded_state$current_step == 7)` block (~line 640), add:

```r
        } else if (loaded_state$current_step >= 8) {
          # Restore all reactive values for review/finalize steps
          if (!is.null(loaded_state$project_data$activities)) {
            selected_activities(loaded_state$project_data$activities)
          }
          if (!is.null(loaded_state$project_data$pressures)) {
            selected_pressures(loaded_state$project_data$pressures)
          }
          if (!is.null(loaded_state$project_data$preventive_controls)) {
            selected_preventive_controls(loaded_state$project_data$preventive_controls)
          }
          if (!is.null(loaded_state$project_data$consequences)) {
            selected_consequences(loaded_state$project_data$consequences)
          }
          if (!is.null(loaded_state$project_data$protective_controls)) {
            selected_protective_controls(loaded_state$project_data$protective_controls)
          }
          if (!is.null(loaded_state$project_data$escalation_factors)) {
            selected_escalation_factors(loaded_state$project_data$escalation_factors)
          }
        }
```

- [ ] **Step 3: Commit**

```bash
git add guided_workflow_export.R
git commit -m "feat: add backward compatibility migration for 8-step saved workflows"
```

---

## Task 11: Update Test Files

**Files:**
- Modify: `tests/testthat/helper-setup.R:143`
- Modify: `tests/testthat/test-guided-workflow.R:90,172,495`
- Modify: `tests/testthat/test-guided-workflow-performance.R:187,194,266,385`
- Create: `tests/testthat/test-review-step.R`

- [ ] **Step 1: Update helper-setup.R**

Replace `total_steps = 8` with `total_steps = 9` at line 143.

- [ ] **Step 2: Update test-guided-workflow.R**

- Line 90: `total_steps = 8` -> `total_steps = 9`
- Line 172: `expect_equal(state$total_steps, 8)` -> `expect_equal(state$total_steps, 9)`
- Line 495: `state$completed_steps <- 1:8` -> `state$completed_steps <- 1:9`

- [ ] **Step 3: Update test-guided-workflow-performance.R**

- Line 187: `for (step in 1:8)` -> `for (step in 1:9)`
- Line 194: `expect_equal(state$total_steps, 8)` -> `expect_equal(state$total_steps, 9)`
- Line 266: `state$current_step <- (i %% 8) + 1` -> `state$current_step <- (i %% 9) + 1`
- Line 385: `for (step in 1:8)` -> `for (step in 1:9)`

- [ ] **Step 4: Update any other test files with hardcoded step 8 references**

Search for and update:
- `tests/testthat/test-autosave-integration.R`: lines 184, 196, 484, 503-504
- `tests/testthat/test-autosave-unit.R`: line 310
- `tests/testthat/test-hierarchical-integration.R`: lines 349, 373
- `tests/testthat/test-review-round2-fixes.R`: line 63

For each, update `total_steps = 8` to `9`, `1:8` to `1:9`, and step 8 finalize references to step 9.

- [ ] **Step 5: Create test-review-step.R with basic review step tests**

```r
# tests/testthat/test-review-step.R
# Tests for Step 8: Review & Adjust

test_that("validate_step8_review requires at least 1 activity", {
  data <- list(
    activities = c("A1", "A2"),
    excluded_activities = c("A1", "A2"),
    pressures = c("P1"),
    excluded_pressures = character(0),
    consequences = c("C1"),
    excluded_consequences = character(0)
  )
  result <- validate_step8_review(data)
  expect_false(result$valid)
  expect_true(grepl("activity", result$message, ignore.case = TRUE))
})

test_that("validate_step8_review requires at least 1 pressure", {
  data <- list(
    activities = c("A1"),
    excluded_activities = character(0),
    pressures = c("P1"),
    excluded_pressures = c("P1"),
    consequences = c("C1"),
    excluded_consequences = character(0)
  )
  result <- validate_step8_review(data)
  expect_false(result$valid)
  expect_true(grepl("pressure", result$message, ignore.case = TRUE))
})

test_that("validate_step8_review requires at least 1 consequence", {
  data <- list(
    activities = c("A1"),
    excluded_activities = character(0),
    pressures = c("P1"),
    excluded_pressures = character(0),
    consequences = c("C1"),
    excluded_consequences = c("C1")
  )
  result <- validate_step8_review(data)
  expect_false(result$valid)
  expect_true(grepl("consequence", result$message, ignore.case = TRUE))
})

test_that("validate_step8_review passes with at least 1 of each required", {
  data <- list(
    activities = c("A1", "A2"),
    excluded_activities = c("A2"),
    pressures = c("P1", "P2"),
    excluded_pressures = c("P2"),
    consequences = c("C1"),
    excluded_consequences = character(0)
  )
  result <- validate_step8_review(data)
  expect_true(result$valid)
})

test_that("validate_step8_review allows empty optional categories", {
  data <- list(
    activities = c("A1"),
    excluded_activities = character(0),
    pressures = c("P1"),
    excluded_pressures = character(0),
    consequences = c("C1"),
    excluded_consequences = character(0),
    preventive_controls = character(0),
    excluded_preventive = character(0),
    protective_controls = character(0),
    excluded_protective = character(0)
  )
  result <- validate_step8_review(data)
  expect_true(result$valid)
})

test_that("validate_step9 always passes", {
  result <- validate_step9(list())
  expect_true(result$valid)
})

test_that("step_durations vector has 9 elements", {
  state <- list(total_steps = 9, completed_steps = integer(0))
  remaining <- estimate_remaining_time(state)
  # Should not error — means the vector has enough elements
  expect_true(is.numeric(remaining))
  expect_true(remaining > 0)
})

test_that("workflow config has 9 steps", {
  expect_equal(length(WORKFLOW_CONFIG$steps), 9)
  expect_equal(WORKFLOW_CONFIG$steps$step8$id, "review_adjust")
  expect_equal(WORKFLOW_CONFIG$steps$step9$id, "finalize_export")
})

test_that("step 7 config ID is escalation_factors not review_validate", {
  expect_equal(WORKFLOW_CONFIG$steps$step7$id, "escalation_factors")
})
```

- [ ] **Step 6: Run all tests**

Run: `cd "C:/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript tests/test_runner.R`

Expected: All tests pass.

- [ ] **Step 7: Commit**

```bash
git add tests/
git commit -m "test: update all test files for 9-step workflow, add review step validation tests"
```

---

## Summary

| Task | Description | Effort |
|------|-------------|--------|
| 1 | Conversion fix tests (TDD) | Low |
| 2 | Conversion fix implementation | Medium |
| 3 | NA-safety downstream | Low |
| 4 | Hardcoded step number audit | Low |
| 5 | Config + navigation (9 steps) | Medium |
| 6 | Connection persistence | Medium |
| 7 | Step 8 UI | High |
| 8 | Step 8 server logic | High |
| 9 | Wire conversion to review + export | Medium |
| 10 | Backward compatibility migration | Low |
| 11 | Update test files | Medium |
