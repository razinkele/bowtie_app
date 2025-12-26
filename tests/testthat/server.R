# Shim to load server.R for tests that source it from tests directory
tryCatch({
  source("../server.R", local = TRUE)
}, error = function(e) {
  message("Shim: failed to load server.R (", e$message, ")")
})
