# test-causal-knowledge-base.R
# Tests for the scientific causal knowledge base (v2.0)
# =============================================================================

# Load KB without logging dependencies
bowtie_log <- function(...) invisible(NULL)
log_info <- bowtie_log; log_warning <- bowtie_log
log_success <- bowtie_log; log_debug <- bowtie_log

test_that("causal_knowledge_base.R can be sourced", {
  expect_no_error(source(file.path("..", "..", "causal_knowledge_base.R")))
  expect_true(exists("CAUSAL_KB"))
})

test_that("CAUSAL_KB has correct structure", {
  expect_type(CAUSAL_KB, "list")
  expect_named(CAUSAL_KB, c("activity_pressure", "pressure_consequence",
                             "control_pressure", "references"))
})

# =============================================================================
# TABLE STRUCTURE TESTS
# =============================================================================

test_that("activity_pressure table has correct columns including ODEMM scores", {
  ap <- CAUSAL_KB$activity_pressure
  expect_s3_class(ap, "data.frame")
  expect_true(all(c("from_id", "to_id", "confidence", "confidence_score",
                     "msfd_descriptor", "mechanism", "citation",
                     "spatial_extent", "frequency", "persistence", "severity") %in% names(ap)))
  expect_gt(nrow(ap), 100)
})

test_that("pressure_consequence table has correct columns including recovery info", {
  pc <- CAUSAL_KB$pressure_consequence
  expect_s3_class(pc, "data.frame")
  expect_true(all(c("from_id", "to_id", "confidence", "confidence_score",
                     "msfd_descriptor", "mechanism", "citation",
                     "recovery_years_min", "recovery_years_max", "reversibility") %in% names(pc)))
  expect_gt(nrow(pc), 60)
})

test_that("control_pressure table has correct columns", {
  cp <- CAUSAL_KB$control_pressure
  expect_s3_class(cp, "data.frame")
  expect_true(all(c("from_id", "to_id", "confidence", "confidence_score",
                     "effectiveness", "mechanism", "citation") %in% names(cp)))
  expect_gt(nrow(cp), 120)
})

test_that("references table has correct columns and URLs", {
  refs <- CAUSAL_KB$references
  expect_s3_class(refs, "data.frame")
  expect_true(all(c("key", "authors", "year", "title", "journal", "doi", "url") %in% names(refs)))
  expect_gt(nrow(refs), 10)
  expect_true(all(nzchar(refs$url)))
  expect_true(all(refs$year > 1900 & refs$year <= 2030))
})

# =============================================================================
# DATA INTEGRITY TESTS
# =============================================================================

test_that("confidence scores are valid", {
  for (tbl_name in c("activity_pressure", "pressure_consequence", "control_pressure")) {
    tbl <- CAUSAL_KB[[tbl_name]]
    expect_true(all(tbl$confidence %in% c("HIGH", "MEDIUM", "LOW")),
                info = paste(tbl_name, "has invalid confidence levels"))
    expect_true(all(tbl$confidence_score >= 0.5 & tbl$confidence_score <= 0.95),
                info = paste(tbl_name, "has scores out of range"))
  }
})

test_that("MSFD descriptors are valid", {
  valid_descriptors <- paste0("D", 1:11)
  for (tbl_name in c("activity_pressure", "pressure_consequence", "control_pressure")) {
    tbl <- CAUSAL_KB[[tbl_name]]
    expect_true(all(tbl$msfd_descriptor %in% valid_descriptors),
                info = paste(tbl_name, "has invalid MSFD descriptors"))
  }
})

test_that("all citations reference existing entries", {
  valid_keys <- CAUSAL_KB$references$key
  for (tbl_name in c("activity_pressure", "pressure_consequence", "control_pressure")) {
    tbl <- CAUSAL_KB[[tbl_name]]
    missing <- setdiff(unique(tbl$citation), valid_keys)
    expect_equal(length(missing), 0,
                 info = paste(tbl_name, "has citations not in references:", paste(missing, collapse = ", ")))
  }
})

test_that("activity IDs follow MSFD naming convention", {
  ap <- CAUSAL_KB$activity_pressure
  expect_true(all(grepl("^A\\d", ap$from_id)), info = "Activity IDs should start with A")
  expect_true(all(grepl("^P\\d", ap$to_id)), info = "Pressure IDs should start with P")
})

test_that("no duplicate connections exist", {
  for (tbl_name in c("activity_pressure", "pressure_consequence", "control_pressure")) {
    tbl <- CAUSAL_KB[[tbl_name]]
    dupes <- duplicated(paste(tbl$from_id, tbl$to_id))
    expect_false(any(dupes),
                 info = paste(tbl_name, "has duplicate from_id/to_id pairs"))
  }
})

test_that("effectiveness values are valid for controls", {
  cp <- CAUSAL_KB$control_pressure
  valid_eff <- c("prevents", "reduces", "mitigates", "monitors", "reverses",
                 "compensates", "informs")
  expect_true(all(cp$effectiveness %in% valid_eff),
              info = paste("Invalid effectiveness values:",
                           paste(setdiff(cp$effectiveness, valid_eff), collapse = ", ")))
})

# =============================================================================
# ODEMM RISK SCORING TESTS
# =============================================================================

test_that("ODEMM scores are in valid 1-5 range", {
  ap <- CAUSAL_KB$activity_pressure
  for (col in c("spatial_extent", "frequency", "persistence", "severity")) {
    expect_true(all(ap[[col]] >= 1 & ap[[col]] <= 5),
                info = paste(col, "has values outside 1-5 range"))
  }
})

test_that("calculate_odemm_risk returns correct structure", {
  result <- calculate_odemm_risk("A4.1", "P1.6")
  expect_type(result, "list")
  expect_true(all(c("activity_id", "pressure_id", "spatial_extent", "frequency",
                     "persistence", "severity", "risk_score", "risk_level") %in% names(result)))
  expect_true(result$risk_score >= 1 & result$risk_score <= 5)
  expect_true(result$risk_level %in% c("low", "medium", "high", "very_high"))
})

test_that("calculate_odemm_risk returns NULL for missing pairs", {
  result <- calculate_odemm_risk("A99.99", "P99.99")
  expect_null(result)
})

test_that("high-impact activities have high ODEMM scores", {
  # Fishing -> species extraction should be high risk
  result <- calculate_odemm_risk("A4.1", "P1.6")
  expect_gte(result$risk_score, 3.0)
  # Agriculture -> nutrients should be significant
  result2 <- calculate_odemm_risk("A5.3", "P3.1")
  expect_gte(result2$risk_score, 2.5)
})

# =============================================================================
# RECOVERY TIME TESTS
# =============================================================================

test_that("recovery times are present and valid", {
  pc <- CAUSAL_KB$pressure_consequence
  expect_true(all(pc$recovery_years_min >= 0))
  expect_true(all(pc$recovery_years_max >= pc$recovery_years_min))
  valid_rev <- c("reversible", "slowly_reversible", "partially_reversible", "irreversible")
  expect_true(all(pc$reversibility %in% valid_rev),
              info = paste("Invalid reversibility:", paste(setdiff(pc$reversibility, valid_rev), collapse = ", ")))
})

test_that("get_kb_recovery_info returns correct data", {
  # Nutrients should be slowly reversible (10-30 years)
  r <- get_kb_recovery_info("P3.1")
  expect_type(r, "list")
  expect_equal(r$recovery_years_min, 10)
  expect_equal(r$recovery_years_max, 30)
  expect_equal(r$reversibility, "slowly_reversible")
})

test_that("get_kb_recovery_info returns NULL for unknown pressure", {
  expect_null(get_kb_recovery_info("P99.99"))
})

test_that("irreversible pressures have high recovery times", {
  pc <- CAUSAL_KB$pressure_consequence
  irrev <- pc[pc$reversibility == "irreversible", ]
  if (nrow(irrev) > 0) {
    expect_true(all(irrev$recovery_years_max >= 100))
  }
})

test_that("sound pressure is quickly reversible", {
  r <- get_kb_recovery_info("P3.5")
  expect_lte(r$recovery_years_max, 1)
  expect_equal(r$reversibility, "reversible")
})

# =============================================================================
# COVERAGE TESTS
# =============================================================================

test_that("expanded coverage meets targets", {
  stats <- get_kb_stats()
  expect_gte(stats$total_connections, 280)
  expect_gte(stats$unique_activities, 35)
  expect_gte(stats$unique_pressures, 17)
  expect_gte(stats$unique_consequences, 20)
  expect_gte(stats$unique_controls, 80)
})

# =============================================================================
# LOOKUP FUNCTION TESTS
# =============================================================================

test_that("find_kb_connections returns correct results", {
  result <- find_kb_connections("A4.1", "Activity", "Pressure")
  expect_gt(nrow(result), 0)
  expect_true("P1.6" %in% result$to_id)

  result_empty <- find_kb_connections(character(0), "Activity", "Pressure")
  expect_equal(nrow(result_empty), 0)

  result_invalid <- find_kb_connections("A1.1", "Activity", "Control")
  expect_equal(nrow(result_invalid), 0)
})

test_that("get_kb_item_connections works bidirectionally", {
  result <- get_kb_item_connections("P1.6")
  expect_type(result, "list")
  expect_true(nrow(result$causes) > 0)
  expect_true(nrow(result$effects) > 0)
  expect_true(nrow(result$controls) > 0)
})

test_that("get_kb_references returns formatted citations", {
  refs <- get_kb_references(c("knights_2015", "borgwardt_2019"))
  expect_equal(nrow(refs), 2)
  expect_true("formatted" %in% names(refs))
  expect_true(all(grepl("DOI:", refs$formatted)))

  all_refs <- get_kb_references()
  expect_equal(nrow(all_refs), nrow(CAUSAL_KB$references))
})

test_that("get_kb_stats reports new fields", {
  stats <- get_kb_stats()
  expect_type(stats, "list")
  expect_equal(stats$total_connections,
               stats$activity_pressure_links + stats$pressure_consequence_links + stats$control_pressure_links)
  expect_true(stats$has_odemm_scores)
  expect_true(stats$has_recovery_info)
  expect_gt(stats$mean_odemm_risk, 0)
})

# =============================================================================
# KEY SCIENTIFIC CONNECTIONS
# =============================================================================

test_that("key scientific connections are present", {
  ap <- CAUSAL_KB$activity_pressure
  pc <- CAUSAL_KB$pressure_consequence
  cp <- CAUSAL_KB$control_pressure

  # Shipping -> non-indigenous species (via ballast water)
  expect_true(any(ap$from_id == "A6.2" & ap$to_id == "P1.1"))
  # Nutrients -> ecosystem change (eutrophication)
  expect_true(any(pc$from_id == "P3.1" & pc$to_id == "C1.1"))
  # MPAs -> prevent extraction
  expect_true(any(cp$from_id == "Ctrl1.3.5" & cp$to_id == "P1.6"))
  # Bubble curtains -> reduce noise
  expect_true(any(cp$from_id == "Ctrl2.3.1" & cp$to_id == "P3.5"))
  # Agriculture -> nutrient input
  expect_true(any(ap$from_id == "A5.3" & ap$to_id == "P3.1"))
  # Newly added: Freshwater aquaculture -> nutrients
  expect_true(any(ap$from_id == "A5.2" & ap$to_id == "P3.1"))
  # Newly added: NIS -> governance impacts
  expect_true(any(pc$from_id == "P1.1" & pc$to_id == "C1.5"))
})
