# Compatibility shims for tests to smooth over testthat version differences

# Provide expect_no_error that accepts an `info` argument for compatibility
expect_no_error <- function(code, info = NULL) {
  expr <- substitute(code)
  env <- parent.frame()
  res <- tryCatch(eval(expr, envir = env), error = function(e) e)
  if (inherits(res, "error")) {
    msg <- paste0("expect_no_error failed", if (!is.null(info)) paste0(" (", info, ")"), ": ", res$message)
    testthat::fail(msg)
  } else {
    testthat::succeed()
  }
  invisible(res)
}

