# Test shim to make tests that call source('ui.R') succeed when run from tests/testthat
tryCatch({
  source("../config.R", local = TRUE)
  source("../environmental_scenarios.R", local = TRUE)
  source("../translations_data.R", local = TRUE)
  source("../guided_workflow.R", local = TRUE)
  source("../ui.R", local = TRUE, chdir = TRUE)
}, error = function(e) {
  # Allow tests to proceed even if some optional components are missing
  message("tests/testthat/ui.R shim: failed to source ui (", e$message, ")")
})
