# Shim to let tests that source ../config.R succeed
tryCatch({
  source("../config.R", local = TRUE)
}, error = function(e) {
  message("Shim: failed to load config.R (", e$message, ")")
})
