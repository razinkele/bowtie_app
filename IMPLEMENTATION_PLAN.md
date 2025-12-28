# Implementation Plan: Codebase Consistency & Performance Improvements ✅

**Objective:** Review and remediate code inconsistencies and performance issues in the `bowtie_app` repository. This document summarizes findings, prioritised tasks, acceptance criteria, and an implementation roadmap (no code changes included here). 💡

---

## Executive summary
- The repo is mature with strong test and benchmarking tooling (e.g., `utils/code_quality_check.R`, `utils/performance_benchmark.R`) and caches in `utils.R` / `vocabulary.R`.
- Key issues discovered: naming and filename inconsistencies, duplicated code/prints, scattered backups, minor API/variable naming mismatches, and opportunities to harden CI and performance regression detection.
- This plan prioritises low-risk fixes (naming, CI) first, then medium-risk refactors (duplicate removal, caching improvements), and finally deeper performance & architecture work.

---

## High-level findings (concrete examples)
- **Filename / naming inconsistencies** ⚠️
  - References across the repo to variants such as `vocabulary-ai-linker.R`, `vocabulary_ai_linker.R` and (historically) `.r` vs `.R` files — see `vocabulary_bowtie_generator.R`, `vocabulary.R`, `tests/` and `VERSION_HISTORY.md`.
  - `Central_Problem` vs `Problem` naming mismatch flagged in `VISUALIZATION_FIX_v5.4.5.md` and earlier fixes; this can cause subtle validation mismatches.

- **Duplicate or repeated code blocks & noisy prints** 🧹
  - Several files (notably `utils.R` and `vocabulary_bowtie_generator.R`) contain repeated `cat()`/`print()` blocks and duplicated comments which increase maintenance burden and risk of divergence.

- **Global state and side-effects** 🔀
  - Use of global caches (`.cache`, `.vocabulary_cache`) and `source()`ing multiple top-level files increases implicit dependencies and startup cost.

- **Testing & CI gaps** 🧪
  - There are strong local tools for benchmarking and quality checks, but the CI documentation suggests adding these steps is desirable (e.g., run `utils/code_quality_check.R` and `utils/performance_benchmark.R` in CI matrix). Some test shims source repo files rather than using a packaged test harness.

- **Performance opportunities** ⚡
  - Caching is implemented but could be improved (LRU size management, memoisation usage consistent across heavy functions). There's an existing benchmarking suite but no automated regression guard in CI.

- **Repository hygiene** 📁
  - Backups (e.g., `ui.R.backup`, `server.R.backup`) and archived files exist in tree and docs referencing backups; archive policy should be clarified.

---

## Proposed prioritised tasks (short descriptions)
Priority legend: **P0** (critical), **P1** (high), **P2** (medium), **P3** (low) 

1. P0 — Normalize filenames & references (Safety / cross-platform) 🔧 (Effort: S)
   - Ensure canonical filenames (`*.R`) and consistent module names. Update any references in tests, scripts and docs.
   - Acceptance: All `source()`/test shims use the canonical names and tests run locally and in CI.

2. P0 — Fix naming mismatches (`Central_Problem` vs `Problem`) (Effort: S)
   - Decide canonical variable name and update validation/consumers to match. Add unit tests validating field names.
   - Acceptance: No failing tests related to Central_Problem/Problem, and a test that ensures the field exists after data generation.

3. P1 — Add/Enforce CI checks for code quality and performance guards (Effort: M)
   - Add steps to CI to run `utils/code_quality_check.R`, `lintr`, unit tests and optionally a short baseline performance check (fast microbenchmark) to detect regressions.
   - Acceptance: New CI runs (pass/fail) with documented run times; performance regression threshold fails CI when exceeded.

4. P1 — Remove duplicated code / reduce noisy logging (Effort: M)
   - Remove repeated `cat()` blocks and duplicate comments, centralize logging into `bowtie_log()` or `message()` with levels.
   - Acceptance: No duplicated message blocks remain (spot-checked), and logs are controllable via verbosity flags.

5. P1 — Make caching and memoisation consistent and safer (Effort: M)
   - Audit caches (`.cache`, `.vocabulary_cache`), add LRU eviction tests, and add clear points tied to data updates.
   - Acceptance: Unit tests verify caching behavior, and memory usage is documented by benchmarks.

6. P2 — Reduce global side-effects and make startup deterministic (Effort: L)
   - Move heavy `source()` behavior into functions or a proper initialization routine. Document startup steps and minimize what runs on source().
   - Acceptance: Startup time improves or becomes more predictable; tests can load modules in isolation.

7. P2 — Add pre-commit hooks (linters, unit tests) & contributor docs (Effort: S)
   - Add/configure `pre-commit` or R git hooks via `install_hooks.*` already present; ensure lintr and at least unit tests run locally pre-commit.
   - Acceptance: Hook runs locally and blocks commits that introduce style issues.

8. P3 — Archive and cleanup (backups, large historical files) (Effort: S)
   - Move historical backups into `/archive/` and remove from top-level; update `README` and `VERSION_HISTORY` to reflect the change.
   - Acceptance: No top-level backup files remain; docs updated.

---

## Suggested task breakdown & owner & estimates
| # | Task | Priority | Est. Effort | Owner | Acceptance criteria |
|---|------|----------|-------------:|-------|---------------------|
| 1 | Filename & code reference normalization | P0 | 0.5–1 day | Maintainer / small PR | All references updated; tests pass locally & in CI |
| 2 | Fix Central_Problem naming mismatch | P0 | 0.5–1 day | Maintainer | Tests added; no validation errors remain |
| 3 | Add CI code-quality & perf steps | P1 | 1–2 days | DevOps / maintainer | CI runs `code_quality_check.R`, lintr, tests, and a short perf baseline |
| 4 | Remove duplicated prints & centralize logging | P1 | 1–3 days | Contributor | Duplicate blocks removed; logging via `bowtie_log()` or `message()`;
| 5 | Audit & harden caching strategy | P1 | 2–4 days | Contributor | Unit tests for cache; documented LRU behavior; memory benchmark shows improvement or no regressions |
| 6 | Reduce startup side-effects | P2 | 3–7 days | Contributor | Startup step documented; modules can be loaded isolated in tests |
| 7 | Pre-commit hooks & contributor docs | P2 | 0.5–1 day | Maintainer | Hooks work; docs updated; CI/PR template updated |
| 8 | Archive cleanup | P3 | 0.5 day | Maintainer | Backups moved to `/archive/`; docs updated |

---

## Tests & CI recommendations (detailed)
- CI (GitHub Actions) matrix should include: R versions (e.g., 4.1, 4.2, 4.3), OS (ubuntu-latest, windows-latest) and run:
  - `Rscript -e "install.packages(...); source('utils/code_quality_check.R')"`
  - `Rscript tests/test_runner.R` (fast unit/integration set) and a separate job for `utils/performance_benchmark.R` that runs only on `main` or nightly to detect regressions.
- Add a small `microbenchmark` based smoke test that checks a known function completes within a threshold (failure flags regression). Store baseline results in `utils/performance_benchmark.R`.
- Ensure tests don't rely on global environment side-effects; prefer test shims that `source(..., local = TRUE)`.

---

## Implementation notes & risk mitigation
- Make small, reviewable PRs — start with filename normalization and CI changes. This reduces risk and makes rollbacks easy.
- Add feature flags or config toggles for any behavioural changes (e.g., stricter cache eviction) to avoid breaking production workflows.
- When changing naming conventions, add compatibility shims for one release cycle (e.g., accept both `Problem` and `Central_Problem` with a NOTICE in logs) before removal.

---

## Documentation & deliverables
- Deliver `IMPLEMENTATION_PLAN.md` (this file) and propose issues/PRs for each P0/P1 task.
- Update `README.md` and `utils/README.md` with a short checklist for maintainers: `run code_quality_check.R`, `run performance_benchmark` and `how to add new caches`.

---

## Next steps (recommended immediate actions) ✅
1. Share this plan with maintainers for review and prioritisation. (Short-term: issue/PR referencing `IMPLEMENTATION_PLAN.md`)
2. Create smaller issues for each P0/P1 task with clear acceptance criteria and link to this plan.
3. Implement CI changes for `code_quality_check.R` and a short perf baseline as the first PR.

---

If you want, I can: 
- Create tracker issues for the top P0/P1 items, or
- Draft a CI workflow snippet that runs `code_quality_check.R` and a short perf baseline.

---

*Generated by static repo scan on Dec 27, 2025.*
