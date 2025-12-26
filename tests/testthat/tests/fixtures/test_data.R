# Nested shim so source('tests/fixtures/test_data.R') (from tests/testthat) finds the canonical fixtures
tryCatch({
  source("../../fixtures/test_data.R", local = TRUE)
}, error = function(e) {
  message("Shim: failed to source fixtures/test_data.R (", e$message, ")")
})
