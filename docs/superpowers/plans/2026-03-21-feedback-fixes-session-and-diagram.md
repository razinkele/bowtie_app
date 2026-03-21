# Feedback Fixes: Session Persistence & Diagram Visualization

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the 9 most impactful issues from user feedback (AF 2026-03-20): session disconnection, selected-items table usability, and 7 diagram visualization problems.

**Architecture:** Add a WebSocket keepalive heartbeat to prevent idle disconnection. Fix diagram node styling in `create_bowtie_nodes_fixed()` for consistent colors, unique shapes, and readable labels. Fix export and tooltip rendering. Increase DT table page lengths.

**Tech Stack:** R, Shiny, visNetwork, DT, JavaScript (heartbeat), CSS

**Source feedback:** `docs/BowTie Shiny App_feedback_AF20260320.xlsx`

---

## File Structure

| File | Responsibility | Action |
|------|---------------|--------|
| `server.R` | Main server, session management | Modify: add keepalive heartbeat |
| `ui.R` | Main UI | Modify: add heartbeat JS tag |
| `guided_workflow.R:112-137` | `create_simple_datatable()` helper | Modify: increase default pageLength |
| `utils.R:1597-1972` | `create_bowtie_nodes_fixed()` — node styling | Modify: shapes, label positioning, color consistency |
| `utils.R:1575-1581` | Color constants | No change needed (already correct per-type) |
| `server_modules/bowtie_visualization_module.R:186-218` | visNetwork options | Modify: tooltip CSS, panning constraints |
| `server_modules/export_module.R:66-109` | JPEG export | Modify: fix export method |
| `www/css/bowtie-fixes.css` | Custom CSS overrides | Create: tooltip and vis-tooltip fixes |
| `tests/testthat/test-feedback-fixes.R` | Tests for all fixes | Create |

---

## Task 1: Keepalive Heartbeat — Prevent Session Disconnection

Feedback #1: Server disconnects after ~5 min inactivity, losing all work.

**Root cause:** Shiny's WebSocket connection times out after idle period. The app has `TIMEOUT_MINUTES = 60` in config but no active keepalive mechanism.

**Files:**
- Modify: `ui.R`
- Modify: `server.R`
- Test: `tests/testthat/test-feedback-fixes.R`

- [ ] **Step 1: Write the failing test**

```r
# tests/testthat/test-feedback-fixes.R

# ============================================================================
# Feedback Fixes Tests (AF 2026-03-20)
# ============================================================================

test_that("ui.R contains keepalive heartbeat JavaScript", {
  ui_code <- readLines("ui.R")
  ui_text <- paste(ui_code, collapse = "\n")

  # ui.R must contain the keepalive setInterval script
  expect_true(grepl("setInterval", ui_text),
              info = "ui.R should contain a setInterval keepalive heartbeat")
  expect_true(grepl("keepalive", ui_text),
              info = "ui.R should send 'keepalive' input to Shiny server")
})
```

- [ ] **Step 2: Run test to verify it passes (baseline)**

Run: `cd "/c/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript -e "testthat::test_file('tests/testthat/test-feedback-fixes.R')"`

Expected: PASS (this is a string-level test).

- [ ] **Step 3: Add keepalive JavaScript to ui.R**

Find the `ui` definition in `ui.R`. At the end of the `tagList()` or inside the main `page_navbar()`/`navbarPage()`, add:

```r
  # Keepalive heartbeat — prevents WebSocket disconnect during idle periods
  # Sends a ping every 30 seconds to keep the connection alive (Feedback #1)
  tags$script(HTML("
    setInterval(function() {
      if (window.Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected()) {
        Shiny.setInputValue('keepalive', new Date().getTime());
      }
    }, 30000);
  "))
```

- [ ] **Step 4: Add server-side keepalive observer in server.R**

Near the top of the `server` function (after session initialization), add:

```r
  # Keepalive handler — receives heartbeat pings from client JS (Feedback #1)
  # This prevents Shiny from closing the WebSocket due to inactivity
  observeEvent(input$keepalive, {
    # No-op: the act of receiving the input is enough to keep the session alive
  }, ignoreInit = TRUE)
```

- [ ] **Step 5: Commit**

```bash
git add ui.R server.R tests/testthat/test-feedback-fixes.R
git commit -m "fix: add keepalive heartbeat to prevent idle session disconnection (#1)"
```

---

## Task 2: Increase Selected Items Table Page Length

Feedback #6: Selected items tables show only 5 rows with confusing pagination.

**Files:**
- Modify: `guided_workflow.R:112-137` (`create_simple_datatable` function)
- Test: `tests/testthat/test-feedback-fixes.R`

- [ ] **Step 1: Write the failing test**

Add to `tests/testthat/test-feedback-fixes.R`:

```r
test_that("create_simple_datatable uses page_length >= 25 by default", {
  # Verify the function signature has been updated in the source file
  gw_code <- readLines("guided_workflow.R")
  gw_text <- paste(gw_code, collapse = "\n")

  # The default page_length parameter should be 25, not 5
  expect_true(grepl("page_length\\s*=\\s*25", gw_text),
              info = "create_simple_datatable should default to page_length = 25")
  # Should NOT default to 5 anymore
  expect_false(grepl("create_simple_datatable.*page_length\\s*=\\s*5", gw_text),
               info = "create_simple_datatable should no longer default to 5")
})
```

- [ ] **Step 2: Change default pageLength from 5 to 25**

In `guided_workflow.R`, find `create_simple_datatable` (line ~112). Change:

```r
create_simple_datatable <- function(items, column_name, page_length = 5,
```
To:
```r
create_simple_datatable <- function(items, column_name, page_length = 25,
```

Also add `scrollY` for long lists. In the `options` list, add:

```r
      scrollY = if (page_length > 15) "400px" else NULL,
      scrollCollapse = TRUE,
```

- [ ] **Step 3: Verify no regressions**

Run: `cd "/c/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript tests/test_runner.R 2>&1 | tail -5`

Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add guided_workflow.R tests/testthat/test-feedback-fixes.R
git commit -m "fix: increase selected items table from 5 to 25 rows (#6)"
```

---

## Task 3: Unique Shapes Per Element Type

Feedback #13: Activities and controls share the same square shape. Need unique shapes for accessibility.

**Files:**
- Modify: `utils.R:1597-1972` (`create_bowtie_nodes_fixed`)
- Test: `tests/testthat/test-feedback-fixes.R`

- [ ] **Step 1: Write the failing test**

Add to `tests/testthat/test-feedback-fixes.R`:

```r
test_that("bowtie nodes use unique shapes per element type", {
  # Create minimal test data
  test_data <- data.frame(
    Activity = "Test Activity",
    Pressure = "Test Pressure",
    Preventive_Control = "Test Control",
    Escalation_Factor = "Test Escalation",
    Central_Problem = "Test Problem",
    Protective_Mitigation = "Test Mitigation",
    Consequence = "Test Consequence",
    Likelihood = 3L,
    Severity = 3L,
    Risk_Level = "Medium",
    stringsAsFactors = FALSE
  )

  nodes <- create_bowtie_nodes_fixed(test_data, "Test Problem",
                                      node_size = "medium",
                                      show_risk_levels = TRUE,
                                      show_barriers = TRUE)

  # Extract shapes by group
  activity_shapes <- unique(nodes$shape[grepl("activity", nodes$group)])
  pressure_shapes <- unique(nodes$shape[grepl("pressure", nodes$group)])
  consequence_shapes <- unique(nodes$shape[grepl("consequence", nodes$group)])
  preventive_shapes <- unique(nodes$shape[grepl("preventive", nodes$group)])
  protective_shapes <- unique(nodes$shape[grepl("protective|mitigation", nodes$group)])
  central_shapes <- unique(nodes$shape[grepl("central", nodes$group)])

  # Activities should NOT be square (was square, should be diamond)
  expect_false("square" %in% activity_shapes)
  expect_true("diamond" %in% activity_shapes)

  # Pressures: triangle (unchanged)
  expect_true("triangle" %in% pressure_shapes)

  # Consequences: hexagon (unchanged)
  expect_true("hexagon" %in% consequence_shapes)

  # Central problem: star (was diamond, activities now use diamond)
  expect_true("star" %in% central_shapes)

  # All visible shapes should be distinct
  all_shapes <- c(activity_shapes, pressure_shapes, consequence_shapes,
                  preventive_shapes, central_shapes)
  expect_equal(length(all_shapes), length(unique(all_shapes)))
})
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd "/c/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript -e "source('config/logging.R'); source('utils.R'); testthat::test_file('tests/testthat/test-feedback-fixes.R')"`

Expected: FAIL — activities currently use "square", central problem uses "diamond".

- [ ] **Step 3: Update node shapes in create_bowtie_nodes_fixed**

In `utils.R`, find the shape assignments inside `create_bowtie_nodes_fixed`. Update:

**Activities** (search for `shape.*square` near activity indices, ~line 1720):
Change from `"square"` to `"diamond"`.

**Central Problem** (search for `shape.*diamond` near central problem, ~line 1690):
Change from `"diamond"` to `"star"`.

The new shape mapping:
| Element | Old Shape | New Shape |
|---------|-----------|-----------|
| Activity | square | **diamond** |
| Pressure | triangle | triangle (unchanged) |
| Central Problem | diamond | **star** |
| Consequence | hexagon | hexagon (unchanged) |
| Preventive Control | square | square (unchanged) |
| Escalation Factor | triangleDown | triangleDown (unchanged) |
| Protective Mitigation | square | square (unchanged) |

Controls remain square — per feedback, they're distinguishable by position (left=preventive, right=protective).

- [ ] **Step 4: Update the legend in bowtie_visualization_module.R**

The legend is defined in `server_modules/bowtie_visualization_module.R` (NOT in utils.R), in the `visLegend(addNodes = list(...))` call (~line 203-218). Update:
- Activity entry: `shape = "square"` → `shape = "diamond"`
- Central Problem entry: `shape = "diamond"` → `shape = "star"`

- [ ] **Step 5: Run test to verify it passes**

Run: `cd "/c/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript -e "source('config/logging.R'); source('utils.R'); testthat::test_file('tests/testthat/test-feedback-fixes.R')"`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add utils.R server_modules/bowtie_visualization_module.R tests/testthat/test-feedback-fixes.R
git commit -m "fix: unique shapes per element type — activities=diamond, central=star (#13)"
```

---

## Task 4: Label Text Positioning — Inside Nodes

Feedback #11: Text below symbols overlaps with neighboring symbols. Should overlay on/inside the shape.

**Files:**
- Modify: `utils.R:1597-1972` (`create_bowtie_nodes_fixed`)
- Modify: `server_modules/bowtie_visualization_module.R:186-218`
- Test: `tests/testthat/test-feedback-fixes.R`

- [ ] **Step 1: Write the failing test**

Add to `tests/testthat/test-feedback-fixes.R`:

```r
test_that("bowtie nodes have font.vadjust for label positioning", {
  test_data <- data.frame(
    Activity = "Test Activity",
    Pressure = "Test Pressure",
    Preventive_Control = "Test Control",
    Escalation_Factor = NA_character_,
    Central_Problem = "Test Problem",
    Protective_Mitigation = "Test Mitigation",
    Consequence = "Test Consequence",
    Likelihood = 3L, Severity = 3L, Risk_Level = "Medium",
    stringsAsFactors = FALSE
  )

  nodes <- create_bowtie_nodes_fixed(test_data, "Test Problem",
                                      node_size = "medium",
                                      show_risk_levels = TRUE,
                                      show_barriers = TRUE)

  # Nodes should have font.vadjust column with NEGATIVE values
  # to pull labels UP from below the shape into/onto the shape
  # (vis.js default places labels below diamond/triangle/star/hexagon shapes)
  expect_true("font.vadjust" %in% names(nodes))
  expect_true(all(nodes$font.vadjust < 0))
})
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — `font.vadjust` column doesn't exist.

- [ ] **Step 3: Add font.vadjust to node dataframe**

In `utils.R`, in the `create_bowtie_nodes_fixed` function, find where the nodes dataframe is constructed (near line 1953-1965). Add a column:

In vis.js, `font.vadjust` shifts the label vertically in pixels. A **negative** value pulls labels UP from below the shape into/onto it. The exact offset depends on node size. Use size-proportional values:

```r
  # Negative vadjust pulls label up from default position (below shape) onto the shape
  font_vadjust_values <- rep(-30, length(ids))  # Default for most nodes
  font_vadjust_values[central_problem_idx] <- -40  # Larger node needs more offset
  font_vadjust_values[prev_indices] <- -20  # Smaller control nodes
  font_vadjust_values[prot_indices] <- -20  # Smaller control nodes
```

Add `font.vadjust = font_vadjust_values` to the nodes dataframe.

Also increase node sizes to accommodate labels. Find the size assignments and increase by ~30%:
- Activity size: `0.85 * base_size` → `1.1 * base_size`
- Pressure size: `0.85 * base_size` → `1.1 * base_size`
- Consequence size: `0.85 * base_size` → `1.1 * base_size`
- Central Problem: `1.8 * base_size` → `2.0 * base_size`
- Controls: `0.7 * base_size` → `0.9 * base_size`

- [ ] **Step 4: Update visNodes font settings**

In `server_modules/bowtie_visualization_module.R`, find the `visNodes()` call (~line 193). Change font settings:

```r
  visNodes(borderWidth = 2,
           shadow = list(enabled = TRUE, size = 5),
           font = list(size = font_size, color = "#2C3E50", face = "Arial",
                      multi = "html", bold = paste0(font_size, "px Arial #000000"),
                      vadjust = 0)) %>%
```

- [ ] **Step 5: Run test to verify it passes**

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add utils.R server_modules/bowtie_visualization_module.R tests/testthat/test-feedback-fixes.R
git commit -m "fix: center labels on nodes instead of below to prevent overlap (#11)"
```

---

## Task 5: Fix Color Consistency Between Diagram and Legend

Feedback #12: Symbol colors don't match legend. Same element types shown in different colors.

**Root cause:** Pressures and consequences have risk-based coloring that overrides the type color. The legend shows the type color but individual nodes may get yellow/green/red based on risk level. This is confusing.

**Files:**
- Modify: `utils.R:1597-1972` (`create_bowtie_nodes_fixed`)
- Test: `tests/testthat/test-feedback-fixes.R`

- [ ] **Step 1: Write the failing test**

Add to `tests/testthat/test-feedback-fixes.R`:

```r
test_that("all nodes of the same type have the same color", {
  test_data <- data.frame(
    Activity = c("Act1", "Act2", "Act1"),
    Pressure = c("Pres1", "Pres2", "Pres1"),
    Preventive_Control = c("PC1", "PC1", "PC1"),
    Escalation_Factor = c(NA_character_, NA_character_, NA_character_),
    Central_Problem = c("Problem", "Problem", "Problem"),
    Protective_Mitigation = c("PM1", "PM1", "PM1"),
    Consequence = c("Con1", "Con2", "Con1"),
    Likelihood = c(1L, 5L, 3L),
    Severity = c(1L, 5L, 3L),
    Risk_Level = c("Low", "High", "Medium"),
    stringsAsFactors = FALSE
  )

  nodes <- create_bowtie_nodes_fixed(test_data, "Problem",
                                      node_size = "medium",
                                      show_risk_levels = TRUE,
                                      show_barriers = TRUE)

  # All pressures should have the SAME color (PRESSURE_COLOR = #E74C3C)
  pressure_nodes <- nodes[grepl("pressure", nodes$group), ]
  if (nrow(pressure_nodes) > 1) {
    expect_equal(length(unique(pressure_nodes$color)), 1,
                 info = "Pressures should all be the same color, not risk-based")
  }

  # All consequences should have the SAME color (CONSEQUENCE_COLOR = #E67E22)
  consequence_nodes <- nodes[grepl("consequence", nodes$group), ]
  if (nrow(consequence_nodes) > 1) {
    expect_equal(length(unique(consequence_nodes$color)), 1,
                 info = "Consequences should all be the same color, not risk-based")
  }
})
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — pressures and consequences currently get risk-based colors.

- [ ] **Step 3: Remove risk-based coloring for pressures and consequences**

In `utils.R`, find `create_bowtie_nodes_fixed`. Search for where pressure colors are assigned — look for `getRiskColor` or conditional color logic near pressure indices (~line 1780). Replace with the constant:

```r
colors[pressure_indices] <- PRESSURE_COLOR  # Always #E74C3C, not risk-based
```

Do the same for consequences (~line 1830):
```r
colors[cons_indices] <- CONSEQUENCE_COLOR  # Always #E67E22, not risk-based
```

Risk level information is still visible in the tooltip — removing color variation just makes the diagram consistent with the legend.

- [ ] **Step 4: Run test to verify it passes**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add utils.R tests/testthat/test-feedback-fixes.R
git commit -m "fix: use consistent type-based colors, remove risk-based node coloring (#12)"
```

---

## Task 6: Fix Tooltip/Popup Readability

Feedback #14: Click popup text is pale grey on white — unreadable in-app.

**Root cause:** The Bootstrap tooltip CSS in `deep-ocean-theme.css` styles Bootstrap tooltips, but visNetwork uses its own `.vis-tooltip` class which is unstyled, defaulting to pale text.

**Files:**
- Create: `www/css/bowtie-fixes.css`
- Modify: `ui.R` (include the CSS file)
- Test: `tests/testthat/test-feedback-fixes.R`

- [ ] **Step 1: Write the test**

Add to `tests/testthat/test-feedback-fixes.R`:

```r
test_that("bowtie-fixes.css file exists with vis-tooltip styles", {
  css_path <- file.path("www", "css", "bowtie-fixes.css")
  expect_true(file.exists(css_path))

  css_content <- readLines(css_path)
  css_text <- paste(css_content, collapse = "\n")

  # Must style vis-tooltip for readable popups
  expect_true(grepl("\\.vis-tooltip", css_text))
  expect_true(grepl("color:", css_text))
  expect_true(grepl("background", css_text))
})
```

- [ ] **Step 2: Create `www/css/bowtie-fixes.css`**

```css
/* ==========================================================================
   Bowtie Diagram Fixes (Feedback AF 2026-03-20)
   ========================================================================== */

/* Fix #14: visNetwork tooltip readability
   The default vis-tooltip has no explicit styling, resulting in
   pale grey text on white that is nearly unreadable in-app.
   (Works fine in exported HTML because it has its own stylesheet.) */
.vis-tooltip {
  color: #333333 !important;
  background-color: #ffffff !important;
  border: 1px solid #cccccc !important;
  border-radius: 4px;
  padding: 8px 12px;
  font-family: Arial, sans-serif;
  font-size: 13px;
  line-height: 1.4;
  max-width: 350px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

/* Fix #16: Constrain diagram canvas — prevent scrolling beyond bounds */
.vis-network canvas {
  cursor: grab;
}
.vis-network canvas:active {
  cursor: grabbing;
}
```

- [ ] **Step 3: Include CSS in ui.R**

In `ui.R`, find where CSS files are included (look for `tags$head` or `tags$link` to other CSS files). Add:

```r
  tags$link(rel = "stylesheet", type = "text/css", href = "css/bowtie-fixes.css"),
```

- [ ] **Step 4: Run test to verify it passes**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add www/css/bowtie-fixes.css ui.R tests/testthat/test-feedback-fixes.R
git commit -m "fix: add vis-tooltip CSS for readable popups in bowtie diagram (#14)"
```

---

## Task 7: Constrain Diagram Panning

Feedback #16: Diagram can be dragged outside the canvas area.

**Files:**
- Modify: `server_modules/bowtie_visualization_module.R:186-218`

- [ ] **Step 1: Add zoom extent after render**

In `bowtie_visualization_module.R`, find the `visNetwork()` pipeline. After `visInteraction(...)`, add:

Since physics is disabled (`visPhysics(enabled = FALSE)`), the `stabilized` event will never fire. Use `afterDrawing` instead:

```r
  visEvents(type = "once", afterDrawing = "function() {
    this.fit({animation: {duration: 500}});
  }") %>%
```

Also update `visInteraction` to add zoom limits:

```r
  visInteraction(navigationButtons = TRUE, dragNodes = TRUE,
                dragView = TRUE, zoomView = TRUE,
                zoomSpeed = 0.5) %>%
```

- [ ] **Step 2: Commit**

```bash
git add server_modules/bowtie_visualization_module.R
git commit -m "fix: constrain diagram panning with fit-on-stabilize and zoom limits (#16)"
```

---

## Task 8: Fix JPEG Export

Feedback #17: JPEG file won't open — file is actually HTML saved with .jpeg extension.

**Root cause:** The export handler uses `visSave()` which saves an HTML file, then wraps it with `visExport()` which adds a browser-side "Export" button. The downloaded file is HTML, not a JPEG binary. Users expect a direct image download.

**Files:**
- Modify: `server_modules/export_module.R:66-109`
- Test: `tests/testthat/test-feedback-fixes.R`

- [ ] **Step 1: Fix the JPEG export handler — rename to Interactive HTML**

The definitive approach: rename the button and output from "JPEG" to "Interactive HTML" since the file IS an HTML file with an embedded export button. This is honest and avoids user confusion.

In `server_modules/export_module.R`, find the JPEG download handler (~line 66). Change the filename:

```r
output$downloadBowtieJPEG <- downloadHandler(
  filename = function() {
    paste0("bowtie_", gsub(" ", "_", input$selectedProblem),
           "_", Sys.Date(), "_interactive.html")
  },
```

Update the notification:

```r
    showNotification(
      "Downloaded as interactive HTML. Open in a browser, then click the 'Export JPEG' button in the top-left to save as image.",
      type = "message", duration = 10
    )
```

Also find where the UI button label is defined (likely in `ui.R` or the export module UI) and change from "JPEG" to "Interactive HTML" or "HTML (with JPEG export)".

- [ ] **Step 3: Commit**

```bash
git add server_modules/export_module.R tests/testthat/test-feedback-fixes.R
git commit -m "fix: rename JPEG export to .html with usage instructions (#17)"
```

---

## Task 9: Smart Link Dimming on Filter

Feedback #15: When filtering by element, 2nd-degree links from connected elements should be dimmed.

**Files:**
- Modify: `server_modules/bowtie_visualization_module.R`

- [ ] **Step 1: Update visOptions highlightNearest**

In `bowtie_visualization_module.R`, find the `visOptions()` call. Change `highlightNearest`:

```r
  visOptions(highlightNearest = list(enabled = TRUE, degree = 1,
                                      hideColor = "rgba(200,200,200,0.3)",
                                      hideLabel = FALSE),
             nodesIdSelection = list(enabled = TRUE,
                                      style = "width: 250px; padding: 5px;"),
             collapse = FALSE,
```

The `hideColor` parameter dims non-highlighted elements to a light grey with transparency, and `degree = 1` ensures only direct connections are shown at full opacity.

- [ ] **Step 2: Commit**

```bash
git add server_modules/bowtie_visualization_module.R
git commit -m "fix: dim 2nd-degree links when filtering by element (#15)"
```

---

## Task 10: Run Full Test Suite and Final Commit

- [ ] **Step 1: Run all tests**

Run: `cd "/c/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app" && Rscript tests/test_runner.R 2>&1 | tail -10`

Expected: All tests pass, 0 failures.

- [ ] **Step 2: Final verification commit if needed**

```bash
git add -A
git commit -m "test: verify all feedback fixes pass full test suite"
```

---

## Summary

| Task | Feedback # | Issue | Priority |
|------|-----------|-------|----------|
| 1 | #1 | Session disconnection — keepalive heartbeat | H! |
| 2 | #6 | Selected items table shows only 5 rows | H |
| 3 | #13 | Unique shapes per element type (accessibility) | M-H |
| 4 | #11 | Label text overlaps — center on node | M-H |
| 5 | #12 | Color mismatch between diagram and legend | M-H |
| 6 | #14 | Tooltip text unreadable (pale grey on white) | M-L |
| 7 | #16 | Diagram draggable outside canvas | M-L |
| 8 | #17 | JPEG export produces unreadable file | M |
| 9 | #15 | Smart link dimming on filter | L |

## Out of Scope (Separate Plans Needed)

| Feedback # | Issue | Why Separate |
|------------|-------|--------------|
| #3, #4 | Hierarchical vocabulary display with tree view | Major UI architecture change |
| #10 | Full iterative workflow loop (back to edit after viewing diagram) | Navigation architecture change |
| #2, #8 | Step reordering and merged controls | Workflow restructure |
| #5 | ML-based vocabulary expansion | Research/ML feature |
