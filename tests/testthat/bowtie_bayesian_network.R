# Shim so tests that expect to source bowtie_bayesian_network.r find it
tryCatch({
  source("../bowtie_bayesian_network.R", local = TRUE)
}, error = function(e) {
  message("Shim: failed to load bowtie_bayesian_network.R (", e$message, ")")
})
