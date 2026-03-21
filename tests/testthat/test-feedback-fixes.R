# ============================================================================
# Feedback Fixes Tests (AF 2026-03-20)
# ============================================================================

test_that("ui.R contains keepalive heartbeat JavaScript", {
  ui_path <- file.path(find_app_root(), "ui.R")
  skip_if(!file.exists(ui_path), "ui.R not found")
  ui_code <- readLines(ui_path)
  ui_text <- paste(ui_code, collapse = "\n")

  expect_true(grepl("setInterval", ui_text),
              info = "ui.R should contain a setInterval keepalive heartbeat")
  expect_true(grepl("keepalive", ui_text),
              info = "ui.R should send 'keepalive' input to Shiny server")
})

# ============================================================================
# Fix A: Unique Shapes Per Element Type (Feedback #13)
# ============================================================================

test_that("bowtie nodes use unique shapes per element type", {
  test_data <- data.frame(
    Activity = "Test Activity",
    Pressure = "Test Pressure",
    Preventive_Control = "Test Control",
    Escalation_Factor = "Test Escalation",
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

  activity_shapes <- unique(nodes$shape[grepl("activity", nodes$group)])
  pressure_shapes <- unique(nodes$shape[grepl("pressure", nodes$group)])
  consequence_shapes <- unique(nodes$shape[grepl("consequence", nodes$group)])
  central_shapes <- unique(nodes$shape[grepl("central", nodes$group)])

  expect_true("diamond" %in% activity_shapes)
  expect_false("square" %in% activity_shapes)
  expect_true("triangle" %in% pressure_shapes)
  expect_true("hexagon" %in% consequence_shapes)
  expect_true("star" %in% central_shapes)
})

# ============================================================================
# Fix B: Label Positioning (Feedback #11)
# ============================================================================

test_that("bowtie nodes have negative font.vadjust for label positioning", {
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

  expect_true("font.vadjust" %in% names(nodes))
  expect_true(all(nodes$font.vadjust < 0))
})

# ============================================================================
# Fix C: Color Consistency (Feedback #12)
# ============================================================================

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

  pressure_nodes <- nodes[grepl("pressure", nodes$group), ]
  if (nrow(pressure_nodes) > 1) {
    expect_equal(length(unique(pressure_nodes$color)), 1,
                 info = "Pressures should all be the same color")
  }

  consequence_nodes <- nodes[grepl("consequence", nodes$group), ]
  if (nrow(consequence_nodes) > 1) {
    expect_equal(length(unique(consequence_nodes$color)), 1,
                 info = "Consequences should all be the same color")
  }
})

# ============================================================================
# Fix D: Tooltip CSS (Feedback #14)
# ============================================================================

test_that("bowtie-fixes.css file exists with vis-tooltip styles", {
  css_path <- file.path(find_app_root(), "www", "css", "bowtie-fixes.css")
  skip_if(!file.exists(css_path), "bowtie-fixes.css not found")

  css_content <- readLines(css_path)
  css_text <- paste(css_content, collapse = "\n")

  expect_true(grepl("\\.vis-tooltip", css_text))
  expect_true(grepl("color:", css_text))
  expect_true(grepl("background", css_text))
})
