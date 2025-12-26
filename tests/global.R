# Test shim at tests/ to source repo-level global.R
# Some tests call source('../global.R') from deeper test files; this shim makes that safe
source(file.path('..', 'global.R'), local = TRUE)
