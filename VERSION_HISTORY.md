## Version 5.3.1 (Patch)
**Release Date:** 2025-12-23

### Patch fixes (test-driven)
- Fixed risk calculation naming & types in `vocabulary_bowtie_generator.R` to ensure numeric `Risk_Level` and un-named `Risk_Rating` values (PR #2). ✅
- Validate output export path and fail early if destination directory cannot be used (PR #2). ✅
- Add defensive input validation for `createBowtieNodesFixed()` to error on invalid hazard data, with test updates (PR #3). ✅
- Silence expected warnings/messages in guided workflow tests to make test runs deterministic across environments (PR #4). ✅
- Local full test run: 0 failures; skips expected for optional packages and performance tests; warnings are informational about optional components (AI linker missing, package build version messages).

---

