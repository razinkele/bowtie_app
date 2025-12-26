# Test shim placeholder — intentionally left minimal to avoid recursive sourcing
# (originally a shim to source '../global.R'); kept intentionally inert

# Provide a safe translation helper for tests in case translations_data.R
# hasn't been sourced. This avoids failures when tests load guided_workflow
# directly (the real translation system is loaded in production via global.R).
if (!exists("t") || !is.function(t)) {
  t <- function(key, lang = "en", ...) {
    extra <- list(...)
    if (!is.null(extra$current_lang)) lang <- extra$current_lang
    if (!lang %in% c("en", "fr")) lang <- "en"
    # Fallback behavior: if TRANSLATIONS are present, use them; else return key
    if (exists("TRANSLATIONS") && is.list(TRANSLATIONS) && !is.null(TRANSLATIONS[[lang]][[key]])) {
      return(TRANSLATIONS[[lang]][[key]])
    }
    return(key)
  }
}

