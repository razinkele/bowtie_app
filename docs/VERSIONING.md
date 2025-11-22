# Versioning System Documentation

## Environmental Bowtie Risk Analysis Application
**Current Version:** 5.3.0 (Production-Ready Edition)

---

## Versioning Strategy

This application uses **Semantic Versioning** (SemVer) following the pattern: `MAJOR.MINOR.PATCH`

- **MAJOR** version: Incompatible API changes or major architectural overhauls
- **MINOR** version: New features added in a backwards-compatible manner
- **PATCH** version: Backwards-compatible bug fixes

---

## Version Sources

The application version is centrally managed and should be updated in the following locations:

### Primary Version Source (Single Source of Truth)
1. **`config.R:13`** - `APP_CONFIG$VERSION = "5.3.0"`
   - This is the authoritative version number
   - All dynamic version displays reference this value

### Static Version Files
2. **`VERSION`** - Single line file containing version number (e.g., `5.3.0`)
   - Used for quick version checks and deployment scripts
   - Should be kept in sync with config.R

### File Headers (Documentation)
The following files contain version numbers in their header comments:
3. **`global.R:3`** - Version: 5.3.0 (Production-Ready Edition)
4. **`app.R:3`** - Version: 5.3.0 (Production-Ready Edition)
5. **`requirements.R:3`** - Version: 5.3.0 (Production-Ready Edition)
6. **`utils/performance_benchmark.R:3`** - Version: 5.3.0 (Production-Ready Edition)
7. **`utils/advanced_benchmarks.R:171`** - version = "5.3.0" (in baseline creation)
8. **`utils/advanced_benchmarks.R:220`** - Version: 5.3.0 (in HTML report template)

### Dynamic Version Display
9. **`ui.R:78`** - Uses `paste0("v", APP_CONFIG$VERSION)` for badge display
   - This automatically updates when config.R is changed
   - No hardcoded version number

---

## How to Update Version

When releasing a new version, follow this checklist:

### 1. Update Primary Source
```r
# In config.R
APP_CONFIG <- list(
  VERSION = "X.Y.Z",  # Update this line
  # ... rest of config
)
```

### 2. Update VERSION File
```bash
echo "X.Y.Z" > VERSION
```

### 3. Update File Headers
Update version numbers and edition names in:
- `global.R` (line 3)
- `app.R` (line 3)
- `requirements.R` (lines 3 and 5)
- `utils/performance_benchmark.R` (line 3)
- `utils/advanced_benchmarks.R` (lines 171 and 220)

### 4. Update Documentation
- `VERSION_HISTORY.md` - Add new version section with changes
- `RELEASE_NOTES_vX.Y.Z.md` - Create new release notes file
- `CLAUDE.md` - Update version references in application overview
- `README.md` - Update version badge and current version section

### 5. Update Deployment Files
- `deployment/DEPLOYMENT_READY.md` - Update version certification
- `.github/workflows/ci-cd-pipeline.yml` - Update version tags if needed
- `deployment/Dockerfile` - Update version labels

### 6. Verify Consistency
Run this command to verify all version numbers are consistent:
```bash
grep -r "5\.[0-9]\.[0-9]" *.R config.R VERSION | grep -v "archive" | grep -v "test"
```

---

## Version Naming Conventions

Each version follows this naming pattern:
- **Version Number**: X.Y.Z (e.g., 5.3.0)
- **Edition Name**: Descriptive subtitle (e.g., "Production-Ready Edition")

### Historical Edition Names
- 5.3.0 - Production-Ready Edition
- 5.2.0 - Advanced Framework Edition / Modern Framework Edition
- 5.1.0 - Enhanced Development Edition
- 5.0.0 - Major Rewrite Edition

---

## Automated Version Checking

### Git Tags
Create a git tag for each release:
```bash
git tag -a v5.3.0 -m "Version 5.3.0 - Production-Ready Edition"
git push origin v5.3.0
```

### Version Validation Script
A simple validation script can check version consistency:
```r
# Check version consistency
source("config.R")
version_file <- readLines("VERSION")[1]
config_version <- APP_CONFIG$VERSION

if (version_file != config_version) {
  stop("Version mismatch! VERSION file: ", version_file,
       " vs config.R: ", config_version)
}
cat("✅ Version consistency verified:", config_version, "\n")
```

---

## UI Version Display

The application UI displays the version dynamically:
- Location: Top navigation bar (right side of title)
- Format: Green badge with "vX.Y.Z" text
- Source: `APP_CONFIG$VERSION` from config.R
- Implementation: `ui.R:78` - `paste0("v", APP_CONFIG$VERSION)`

This ensures the displayed version always matches the configuration without manual updates.

---

## Troubleshooting

### Version Not Updating in UI
1. Check that `config.R` is loaded before `ui.R`
2. Verify `APP_CONFIG$VERSION` is accessible in global scope
3. Restart the Shiny application to clear cached values

### Version Mismatch Errors
1. Run version consistency check (see "Automated Version Checking")
2. Update all file headers to match `config.R`
3. Verify `VERSION` file matches `config.R`

### Deployment Issues
1. Ensure all deployment scripts reference `config.R` version
2. Check that version tags are pushed to git repository
3. Verify Docker images are tagged with correct version

---

## Best Practices

1. **Always update config.R first** - This is the single source of truth
2. **Use semantic versioning** - Follow MAJOR.MINOR.PATCH strictly
3. **Document changes** - Update VERSION_HISTORY.md for every release
4. **Tag releases in git** - Create version tags for traceability
5. **Verify consistency** - Run automated checks before deployment
6. **Update all locations** - Don't forget file headers and documentation

---

## Contact

For questions about versioning:
- Check `CLAUDE.md` for application overview
- See `VERSION_HISTORY.md` for version changelog
- Review `RELEASE_NOTES_vX.Y.Z.md` for specific release details

---

**Last Updated:** November 2025
**Current Stable Version:** 5.3.0 (Production-Ready Edition)
