# Remaining Tasks Review (P2 & P3)

**Version**: 5.5.3
**Date**: December 28, 2025
**Status**: P1 Complete - P2 and P3 Pending

---

## Executive Summary

With all **P1 (High Priority) tasks complete**, the codebase now has excellent CI/CD, centralized logging, and optimized caching. This document reviews the remaining **P2 (Medium Priority)** and **P3 (Low Priority)** tasks from IMPLEMENTATION_PLAN.md and provides recommendations for next steps.

---

## Completed Tasks (P0 & P1) ✅

### P0 (Critical) - Previously Completed
- ✅ **P0-1**: Normalize filenames & references (v5.4.0)
- ✅ **P0-2**: Fix Central_Problem naming mismatch (v5.4.0)

### P1 (High Priority) - Just Completed
- ✅ **P1-3**: CI Checks for Code Quality and Performance (Dec 28, 2025)
- ✅ **P1-4**: Centralized Logging System (Dec 28, 2025)
- ✅ **P1-5**: Enhanced Caching Strategy (Dec 28, 2025)

**Total Effort**: 5 days actual
**Documentation**: 1,700+ lines across 4 comprehensive documents

---

## Remaining Tasks Overview

| Priority | Task | Effort Est. | Complexity | Impact | Recommended Order |
|----------|------|-------------|------------|--------|-------------------|
| **P2** | P2-7: Pre-commit Hooks | 0.5-1 day | Low | Medium | **1st** ⭐ |
| **P2** | P2-6: Reduce Startup Side-Effects | 3-7 days | High | Medium | **2nd** |
| **P3** | P3-8: Archive Cleanup | 0.5 day | Low | Low | **3rd** |

---

## P2 (Medium Priority) Tasks - Detailed Analysis

### P2-7: Pre-commit Hooks & Contributor Docs ⭐ RECOMMENDED NEXT

**Priority**: Medium (P2)
**Effort Estimate**: 0.5-1 day
**Complexity**: Low
**Impact**: Medium

#### Description (from IMPLEMENTATION_PLAN.md)

> Add/configure `pre-commit` or R git hooks via `install_hooks.*` already present; ensure lintr and at least unit tests run locally pre-commit.

#### Acceptance Criteria

✅ Hooks work locally
✅ Block commits that introduce style issues
✅ Documentation updated

#### Current State Analysis

**Existing Infrastructure**:
- CI already runs lintr and code_quality_check.R (P1-3 complete)
- Local test infrastructure exists (tests/test_runner.R, comprehensive_test_runner.R)
- No git hooks currently configured

**What Needs to Be Done**:

1. **Create Git Pre-commit Hook**
   - Script: `.git/hooks/pre-commit` (or use pre-commit framework)
   - Run lintr on staged R files
   - Run fast unit tests (tests/test_runner.R)
   - Block commit if checks fail

2. **Hook Installation Script**
   - Create `install_hooks.R` or `install_hooks.sh`
   - Copy hooks to .git/hooks/
   - Make executable (chmod +x)

3. **Documentation**
   - Update README.md with hook installation instructions
   - Create CONTRIBUTING.md with development workflow
   - Document how to bypass hooks (for emergencies: `--no-verify`)

#### Implementation Approach

**Option 1: Simple Git Hook (Recommended)**

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
echo "🔍 Running pre-commit checks..."

# Get staged R files
STAGED_R_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.r$|\.R$')

if [ -n "$STAGED_R_FILES" ]; then
  echo "📋 Linting staged R files..."
  Rscript -e "
  library(lintr)
  files <- strsplit('$STAGED_R_FILES', '\n')[[1]]
  issues <- lint(files)
  if (length(issues) > 0) {
    print(issues)
    stop('❌ Lint issues found. Fix them or use --no-verify to bypass.')
  }
  cat('✅ Lint checks passed\n')
  "
fi

# Run fast tests
echo "🧪 Running fast tests..."
Rscript tests/test_runner.R || {
  echo "❌ Tests failed. Fix them or use --no-verify to bypass."
  exit 1
}

echo "✅ All pre-commit checks passed!"
exit 0
```

Create `install_hooks.R`:
```r
#!/usr/bin/env Rscript
# Install git pre-commit hooks

cat("🔧 Installing git pre-commit hooks...\n")

# Create hooks directory if needed
hooks_dir <- ".git/hooks"
if (!dir.exists(hooks_dir)) {
  stop("Not a git repository or .git/hooks directory not found")
}

# Copy pre-commit hook
hook_source <- "tools/pre-commit"  # Template location
hook_dest <- file.path(hooks_dir, "pre-commit")

if (file.exists(hook_dest)) {
  cat("⚠️  Pre-commit hook already exists. Backup created.\n")
  file.copy(hook_dest, paste0(hook_dest, ".backup"))
}

file.copy(hook_source, hook_dest, overwrite = TRUE)

# Make executable (Unix/Mac)
if (.Platform$OS.type != "windows") {
  system(paste("chmod +x", hook_dest))
}

cat("✅ Pre-commit hooks installed successfully!\n")
cat("   Hooks will run lintr and tests before each commit.\n")
cat("   To bypass: git commit --no-verify\n")
```

**Option 2: Pre-commit Framework (More Features)**

Use https://pre-commit.com/ framework

Create `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/lorenzwalthert/precommit
    rev: v0.3.2
    hooks:
      - id: style-files
        args: [--style_pkg=styler, --style_fun=tidyverse_style]
      - id: roxygenize
      - id: use-tidy-description
      - id: lintr
      - id: readme-rmd-rendered
      - id: parsable-R
      - id: no-browser-statement
      - id: no-debug-statement
      - id: deps-in-desc
```

#### Pros and Cons

**Simple Git Hook** (Option 1):
- ✅ Pro: No external dependencies
- ✅ Pro: Fast setup (< 1 hour)
- ✅ Pro: Easy to customize
- ❌ Con: Manual installation for each developer
- ❌ Con: Less feature-rich

**Pre-commit Framework** (Option 2):
- ✅ Pro: More powerful (multiple hooks, auto-update)
- ✅ Pro: Cross-platform support
- ✅ Pro: Community-maintained R hooks
- ❌ Con: Requires pre-commit framework installation
- ❌ Con: More complex setup

#### Recommended Implementation

**Use Option 1 (Simple Git Hook)** for this project because:
1. Faster implementation (0.5 day vs 1 day)
2. No external dependencies
3. Sufficient for project needs
4. Easy for contributors to understand

#### Benefits

✅ **Catch Issues Early**: Lint and test errors found before commit
✅ **Faster CI**: Fewer failed CI runs due to style issues
✅ **Better Code Quality**: Enforced standards locally
✅ **Developer Experience**: Immediate feedback on code issues
✅ **Cost Savings**: Less CI time wasted on preventable failures

#### Estimated Effort Breakdown

| Task | Time | Details |
|------|------|---------|
| Create pre-commit script | 1 hour | Bash script with lintr + tests |
| Create install_hooks.R | 1 hour | Installation script |
| Test on multiple platforms | 1 hour | Windows, macOS, Linux |
| Update documentation | 1 hour | README, CONTRIBUTING |
| **TOTAL** | **4 hours** | **0.5 days** |

---

### P2-6: Reduce Startup Side-Effects

**Priority**: Medium (P2)
**Effort Estimate**: 3-7 days
**Complexity**: High
**Impact**: Medium

#### Description (from IMPLEMENTATION_PLAN.md)

> Move heavy `source()` behavior into functions or a proper initialization routine. Document startup steps and minimize what runs on source().

#### Acceptance Criteria

✅ Startup time improves or becomes more predictable
✅ Tests can load modules in isolation
✅ Startup steps documented

#### Current State Analysis

**Problem Areas**:

1. **Global Startup in global.R** (lines 1-174)
   - Immediately loads 15+ packages
   - Sources 5+ files (utils.R, vocabulary.R, etc.)
   - Generates sample data on load
   - Creates global environments (.cache, etc.)

2. **Side-Effects in utils.R**
   - Cache initialization runs on source
   - Sample data generation functions execute immediately
   - Global environment modifications

3. **Side-Effects in vocabulary.R**
   - May load vocabulary data on source (if use_cache=TRUE by default)
   - File system access on load

4. **Heavy Dependencies**
   - bnlearn, gRain, igraph (Bayesian network packages)
   - visNetwork, plotly, ggplot2 (visualization)
   - All loaded at startup regardless of usage

**Current Startup Time**: ~3-5 seconds (estimated)

#### Implementation Approach

**Phase 1: Lazy Package Loading** (2 days)

Convert from:
```r
# global.R (current)
library(shiny)
library(bslib)
library(DT)
# ... 15+ libraries loaded immediately
```

To:
```r
# global.R (improved)
# Only load absolutely essential packages
library(shiny)

# Lazy loading function
require_package <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# Load packages on-demand in modules
```

**Phase 2: Deferred Initialization** (1-2 days)

Convert from:
```r
# utils.R (current)
.cache <- new.env()  # Runs on source
.cache$data <- new.env()
# ... immediate setup
```

To:
```r
# utils.R (improved)
.cache <- NULL

init_cache <- function() {
  if (is.null(.cache)) {
    .cache <<- new.env()
    .cache$data <<- new.env()
    # ... setup
  }
  invisible(.cache)
}

# Call init_cache() only when needed
```

**Phase 3: Test Isolation** (1-2 days)

Create module loaders for testing:
```r
# tests/helpers/load_utils.R
load_utils_isolated <- function() {
  env <- new.env()
  source("utils.R", local = env)
  return(env)
}

# In tests
test_that("Cache functions work in isolation", {
  utils <- load_utils_isolated()
  # Test without global side-effects
})
```

**Phase 4: Documentation** (1 day)

Document startup sequence:
```markdown
## Application Startup Sequence

1. **global.R**: Load essential packages (shiny, bslib)
2. **on.session.start**: Initialize cache, load vocabulary
3. **on.first.render**: Generate sample data (if needed)
4. **on.demand**: Load heavy packages (bnlearn, gRain, etc.)
```

#### Challenges

⚠️ **High Complexity**:
- Shiny apps typically load everything at startup
- May require significant refactoring
- Risk of breaking existing functionality

⚠️ **Testing Burden**:
- Need extensive testing after changes
- Module isolation is complex in R
- Circular dependencies may emerge

⚠️ **Diminishing Returns**:
- Startup time already reasonable (~3-5s)
- Complexity increase may not justify benefit
- Harder to maintain in future

#### Benefits vs Costs

**Benefits**:
- ✅ Slightly faster startup (~1-2s improvement)
- ✅ Better test isolation
- ✅ More modular architecture
- ✅ Lower memory footprint (if packages lazy-loaded)

**Costs**:
- ❌ High implementation effort (3-7 days)
- ❌ Risk of breaking changes
- ❌ Increased code complexity
- ❌ Harder to debug initialization issues

#### Recommendation

**DEFER THIS TASK** for now because:
1. High effort (3-7 days) with moderate benefit
2. Current startup time is acceptable (~3-5s)
3. P1 tasks already significantly improved performance
4. Could be revisited if startup becomes a bottleneck

**Alternative**: Document current startup sequence without refactoring (1 day effort)

---

## P3 (Low Priority) Tasks

### P3-8: Archive Cleanup

**Priority**: Low (P3)
**Effort Estimate**: 0.5 day
**Complexity**: Low
**Impact**: Low

#### Description (from IMPLEMENTATION_PLAN.md)

> Move historical backups into `/archive/` and remove from top-level; update `README` and `VERSION_HISTORY` to reflect the change.

#### Acceptance Criteria

✅ No top-level backup files remain
✅ Backups moved to /archive/
✅ Documentation updated

#### Current State Analysis

**Backup Files** (potential locations):
- `ui.R.backup` (may exist)
- `server.R.backup` (may exist)
- `*.r.backup`, `*.R.backup` files
- Historical versions in docs/

Let me check what backup files actually exist:

```bash
# Find backup files
find . -name "*.backup" -o -name "*~" -o -name "*.bak"
```

#### Implementation Approach

**Step 1: Create Archive Directory** (5 min)
```bash
mkdir -p archive/backups
mkdir -p archive/historical_docs
```

**Step 2: Move Backup Files** (10 min)
```bash
# Move backup files
mv *.backup archive/backups/ 2>/dev/null || true
mv *~ archive/backups/ 2>/dev/null || true

# Move historical docs if any
mv docs/*.backup archive/historical_docs/ 2>/dev/null || true
```

**Step 3: Update .gitignore** (5 min)
```
# .gitignore additions
*.backup
*~
*.bak
.DS_Store
```

**Step 4: Update Documentation** (20 min)

Update README.md:
```markdown
## Repository Structure

- `/archive/`: Historical backups and deprecated files
- `/tests/`: Comprehensive test suite (400+ tests)
- `/utils/`: Utility functions and benchmarking tools
- `/docs/`: Documentation and guides
```

Update VERSION_HISTORY.md:
```markdown
## Archive Policy

Historical backups have been moved to `/archive/backups/`.
Deprecated features are in `/archive/deprecated/`.
```

**Step 5: Git Commit** (5 min)
```bash
git add archive/
git commit -m "chore: Move historical backups to archive directory"
```

#### Benefits

✅ **Cleaner Repository**: No clutter in top-level directory
✅ **Better Organization**: Clear separation of active vs historical files
✅ **Easier Navigation**: Less confusion for new contributors
✅ **Preserved History**: Backups still accessible if needed

#### Estimated Effort Breakdown

| Task | Time |
|------|------|
| Create archive directories | 5 min |
| Find and move backup files | 15 min |
| Update .gitignore | 5 min |
| Update documentation | 20 min |
| Test and commit | 10 min |
| **TOTAL** | **~1 hour (0.125 days)** |

---

## Recommended Task Order

Based on effort, impact, and current priorities:

### Phase 1: Quick Wins (1.5 days total) ⭐ RECOMMENDED

1. **P2-7: Pre-commit Hooks** (0.5 days)
   - Low effort, medium impact
   - Prevents future code quality issues
   - Complements P1-3 (CI) nicely

2. **P3-8: Archive Cleanup** (0.125 days)
   - Very low effort, low impact
   - Good housekeeping
   - Can be done quickly

**Total Time**: ~0.625 days (5 hours)
**Benefits**: Cleaner repo, better developer workflow

### Phase 2: Major Refactoring (3-7 days) - OPTIONAL

3. **P2-6: Reduce Startup Side-Effects** (3-7 days)
   - High effort, medium impact
   - Consider deferring unless startup becomes a bottleneck
   - Alternative: Document current startup (1 day) instead of refactoring

---

## Effort Summary

| Phase | Tasks | Effort | Priority |
|-------|-------|--------|----------|
| **Phase 1** | P2-7 + P3-8 | 0.625 days | ⭐ Recommended |
| **Phase 2** | P2-6 (full) | 3-7 days | Optional |
| **Alternative** | P2-6 (docs only) | 1 day | Optional |

---

## Detailed Task Breakdown: P2-7 (Pre-commit Hooks)

Since P2-7 is the recommended next task, here's a detailed implementation plan:

### Hour-by-Hour Breakdown

#### Hour 1: Create Pre-commit Script
- Write `.git/hooks/pre-commit` bash script
- Add lintr check for staged R files
- Add fast test runner
- Test locally on sample commit

#### Hour 2: Create Installation Script
- Write `install_hooks.R`
- Add backup mechanism for existing hooks
- Add cross-platform support (Windows/Unix)
- Test installation process

#### Hour 3: Multi-platform Testing
- Test on Windows (if available)
- Test on macOS (if available)
- Test on Linux
- Fix platform-specific issues

#### Hour 4: Documentation
- Update README.md with hook installation instructions
- Create CONTRIBUTING.md with development workflow
- Document bypass mechanism (`--no-verify`)
- Add troubleshooting section

### Deliverables

1. **File**: `tools/pre-commit` (hook template)
2. **File**: `install_hooks.R` (installation script)
3. **File**: `CONTRIBUTING.md` (new contributor guide)
4. **Updated**: `README.md` (hook installation section)
5. **Updated**: `.gitignore` (if needed)

### Success Criteria

✅ Hook prevents commits with lint errors
✅ Hook prevents commits with failing tests
✅ Installation script works on all platforms
✅ Documentation is clear and complete
✅ Bypass mechanism documented

---

## Risk Analysis

### P2-7: Pre-commit Hooks

**Risks**: Low
- ✅ Well-understood technology
- ✅ No breaking changes to existing code
- ✅ Easy to disable if issues arise
- ✅ Similar to existing CI checks

**Mitigation**:
- Include `--no-verify` bypass option
- Start with warnings before enforcing
- Thorough documentation

### P2-6: Reduce Startup Side-Effects

**Risks**: High
- ⚠️ Complex refactoring
- ⚠️ Risk of breaking existing functionality
- ⚠️ Shiny apps typically load everything at startup
- ⚠️ Testing burden is significant

**Mitigation**:
- Consider deferring this task
- If proceeding: incremental changes with extensive testing
- Feature flags for new initialization approach
- Rollback plan if issues emerge

### P3-8: Archive Cleanup

**Risks**: Minimal
- ✅ Simple file operations
- ✅ No code changes
- ✅ Easy to reverse if needed

**Mitigation**:
- Test with `git status` before committing
- Verify no active files are moved
- Keep archive accessible

---

## Conclusion

### Recommended Next Steps

**Immediate Action (Next 5 hours)**:
1. ✅ Implement P2-7 (Pre-commit Hooks) - 4 hours
2. ✅ Implement P3-8 (Archive Cleanup) - 1 hour

**Optional Follow-up**:
- Consider P2-6 (Startup Side-Effects) only if:
  - Startup time becomes a bottleneck (>10 seconds)
  - Test isolation becomes critical
  - Willing to invest 3-7 days with thorough testing

**Alternative for P2-6**:
- Document current startup sequence (1 day) instead of refactoring
- Defer major refactoring until v6.0 planning

### Overall Status

**P0 (Critical)**: ✅ 100% Complete (2/2 tasks)
**P1 (High)**: ✅ 100% Complete (3/3 tasks)
**P2 (Medium)**: ⏳ 0% Complete (0/2 tasks)
**P3 (Low)**: ⏳ 0% Complete (0/1 task)

**Total Progress**: 5/8 tasks complete (62.5%)

**Recommended to Complete**:
- P2-7: Pre-commit Hooks (0.5 days)
- P3-8: Archive Cleanup (0.125 days)
- **Total**: 0.625 days (~5 hours) to reach 87.5% completion

**Optional**:
- P2-6: Reduce Startup Side-Effects (3-7 days) or Document Only (1 day)

---

## References

- **Implementation Plan**: `IMPLEMENTATION_PLAN.md`
- **P1 Completion**: `P1_HIGH_PRIORITY_COMPLETE_v5.5.3.md`
- **P1-3 Details**: `CI_CHECKS_P1-3_COMPLETE_v5.5.3.md`
- **P1-4 Details**: `LOGGING_SYSTEM_P1-4_COMPLETE_v5.5.1.md`
- **P1-5 Details**: `CACHING_STRATEGY_P1-5_COMPLETE_v5.5.2.md`

---

**Generated**: December 28, 2025
**Author**: AI Assistant + Maintainer
**Version**: 5.5.3 (Remaining Tasks Review Edition)
