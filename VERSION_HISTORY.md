# Version History
## Environmental Bowtie Risk Analysis Application

---

## Version 5.5.0 (Codebase Cleanup Edition)
**Release Date:** 2026-02-14

### Critical Bug Fixes
- **Fixed `notify_info()` crash**: Changed invalid `type = "info"` to `type = "message"` in `helpers/notifications.R`
- **Fixed `showNotification` in test file**: Same fix in `tests/test_guided_workflow_interactive.R`
- **Fixed logging calls**: Replaced undefined `log_info`/`log_warning` with `bowtie_log()` in `vocabulary.R` and `vocabulary_bowtie_generator.R`
- **Fixed pre-existing bugs in AI linker**: Corrected positional argument mismatch in `check_parallel_capability()` and wrong field name `total_cores` → `cores`

### Performance Improvements
- **Vectorized O(n^2) loops**: Replaced nested for-loops with `expand.grid()` + vectorized filtering in `vocabulary_ai_linker.R`
- **Eliminated rbind-in-loop anti-patterns**: Converted to list accumulation + `do.call(rbind)` across 5 functions in AI linker, `custom_terms_module.R`, and `dev_config.R`
- **New `assemble_all_items()` helper**: Deduplicated 5 repeated vocabulary assembly blocks (~150 lines saved)

### Code Deduplication
- **Guided workflow factory functions**: Reduced `guided_workflow.R` from 4,364 to 4,034 lines (-330 net)
  - `create_add_item_observer()` replaces 5 identical ~60-line observer blocks
  - `create_step_sync_observer()` replaces 3 identical sync observer blocks
  - 4 table renderers consolidated to use existing `create_simple_datatable()` helper

### Dead Code Removal
- Removed duplicate `%||%` operator from `utils.R` (canonical definition in `guided_workflow_validation.R`)
- Removed unused `detect_browser()`, `get_browser_info()`, `format_browser_css()`, `render_user_avatar()` from `utils.R`
- Removed 13 OneDrive conflict / backup files from working directory
- Added `.gitignore` patterns for `*-laguna-safeBackup*`, `*.backup_*`, `_ul-*`

### Logging Consistency
- Replaced raw `cat()` with `bowtie_log()` in `custom_terms_module.R` and `environmental_scenarios.R`
- Updated CLAUDE.md with `log_success()` documentation and explicit `message()`/`warning()`/`print()` prohibitions

---

## Version 5.4.0 (Stability & Infrastructure Edition)
**Release Date:** 2025-12-26

### Infrastructure Improvements
- **Filename Normalization**: Standardized all `.r` files to `.R` extension for cross-platform compatibility
- **Enhanced Linux Support**: Eliminated case-sensitivity issues across all R source files
- **Test Suite Updates**: Fixed test file loading order and dependencies (utils.R sourced before vocabulary helpers)

### Comprehensive Bug Fixes (v5.3.7 - v5.3.10.1)
- **v5.3.7**: Fixed bowtie logic issues in diagram generation
- **v5.3.8**: Resolved manual opening functionality errors
- **v5.3.9**: Fixed NA value handling in data processing
- **v5.3.10**: Corrected AI display and linking functionality
- **v5.3.10.1**: Fixed critical syntax error in server.R preventing application startup

### Additional Enhancements
- **Macaronesian Scenarios**: Added 3 new environmental scenario templates (v5.3.6)
- **Navigation State Preservation**: Resolved guided workflow state management issues (v5.3.5)
- **Testing Framework**: Enhanced comprehensive test runner with better dependency management
- **Documentation**: Updated all version references and documentation to v5.4.0

### Development Status
- ✅ All critical bugs resolved
- ✅ Cross-platform filename compatibility
- ✅ Enhanced test suite stability
- ✅ Production-ready deployment

---

## Version 5.3.1 (Patch)
**Release Date:** 2025-12-23

### Patch fixes (test-driven)
- Fixed risk calculation naming & types in `vocabulary_bowtie_generator.R` to ensure numeric `Risk_Level` and un-named `Risk_Rating` values (PR #2). ✅
- Validate output export path and fail early if destination directory cannot be used (PR #2). ✅
- Add defensive input validation for `createBowtieNodesFixed()` to error on invalid hazard data, with test updates (PR #3). ✅
- Silence expected warnings/messages in guided workflow tests to make test runs deterministic across environments (PR #4). ✅
- Local full test run: 0 failures; skips expected for optional packages and performance tests; warnings are informational about optional components (AI linker missing, package build version messages).

---

## Version 5.3.0 (Production-Ready Edition)
**Release Date:** November 2025

### Major Enhancements
- **Comprehensive PDF Manual**: Created complete user and technical documentation (118 KB)
- **Codebase Cleanup**: Removed 11 backup/temporary files for production-ready structure
- **Version Standardization**: Updated all configuration files and documentation to v5.3.0

### UI/UX Improvements
- Vertically aligned environmental scenario selectors in Data Input options
- New Vocabulary Statistics card displaying real-time element counts (53, 36, 74, 26)
- Enhanced 3-column layout for better information density

### Critical Bug Fixes
- **Fixed Option 2b scenario error**: Replaced non-existent `getEnvironmentalScenario()` with `generateScenarioSpecificBowtie()`
- All 12 environmental scenarios now working correctly in both Option 2 and Option 2b
- Enhanced error handling with graceful fallback mechanisms

### Configuration & Deployment
- Fixed case-sensitive filename issues (`utils.r`) for Linux compatibility
- Added directory validation (REQUIRED_DIRS and OPTIONAL_DIRS in config.R)
- Enhanced deployment checks to include XLSX data files
- Fixed deploy_shiny_server.sh: Corrected utils.r filename, added config.R to deployment
- Updated check_deployment_readiness.sh with directory structure validation
- Created Windows PowerShell script (check_deployment_readiness.ps1)

### Documentation
- Created comprehensive deployment documentation suite
- LINUX_COMPATIBILITY_CHECK.md for Linux deployment guidance
- DEPLOYMENT_STATUS.md with current status
- DEPLOYMENT_READY.md production readiness certification
- CLEANUP_SUMMARY.md documenting codebase cleanup
- **NEW**: Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.pdf (118 KB comprehensive manual)

### Files Added
- `docs/USER_MANUAL.Rmd` - R Markdown source for PDF manual
- `docs/Environmental_Bowtie_Risk_Analysis_Manual_v5.3.0.pdf` - Compiled PDF manual
- `compile_manual.R` - Automated PDF compilation script
- `deployment/check_deployment_readiness.ps1` - Windows validation script
- `VERSION_HISTORY.md` - This file

### Files Removed (Cleanup)
- 9 backup files (*-laguna-safeBackup-*.R)
- 1 machine-specific file (start_app-Dell-PCn.R)
- 1 temporary file (_ul)

---

## Version 5.2.0 (Modern Framework Edition)
**Release Date:** September 2025

### Framework Updates
- Enhanced development and testing infrastructure
- Improved performance, maintainability, and network deployment capabilities
- Optimized for local network and online access

### Testing Framework
- Comprehensive test suite with 11+ tests
- 95%+ code coverage across core functionality
- Advanced testing categories: consistency, performance, integration

### Environmental Scenarios
- Added overfishing and commercial stock depletion scenario
- Complete synchronization between guided workflow and data upload interfaces
- All 5 general scenarios available across application

### UI/UX
- FontAwesome icon standardization
- Bootstrap 5 Zephyr theme integration
- Consistent icon display across all interfaces

### Data Generation
- Enhanced scenario coverage: 53/53 activities, 35/36 pressures, 74/74 controls, 26/26 consequences
- Realistic environmental modeling with multi-dimensional risk analysis
- Comprehensive vocabulary coverage with 189+ elements

---

## Version 5.1.0
**Release Date:** August 2025

### Initial Modern Framework
- Modular Shiny architecture with separate files
- Bayesian network integration for risk analysis
- Guided workflow system (8 steps)
- Multi-language support (EN/FR)
- Network deployment capabilities

### Core Features
- Interactive bowtie diagram creation
- Data import/export (Excel, CSV)
- Risk visualization and analysis
- Vocabulary management system
- Environmental scenario templates

---

## Version Information

### Current Version
- **Version:** 5.4.0 (Stability & Infrastructure Edition)
- **R Required:** >= 4.3.0
- **Shiny Server:** 1.5.21+ recommended
- **Documentation:** Complete PDF manual included

### Development Status
- ✅ Production Ready
- ✅ All Tests Passing
- ✅ Linux Compatible
- ✅ Documentation Complete
- ✅ Deployment Validated

### Support
- Full deployment framework
- Comprehensive testing suite
- Complete documentation package
- Multi-platform compatibility (Windows, Linux, macOS)

---

**Last Updated:** November 2025
