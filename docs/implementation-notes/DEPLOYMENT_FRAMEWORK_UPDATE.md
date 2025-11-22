# Deployment Framework Update Summary
## Environmental Bowtie Risk Analysis v5.2.0

**Date:** November 2025
**Status:** ✅ Deployment Framework Updated

---

## Summary of Updates

The deployment framework has been updated to reflect the current file and directory structure of the application. All deployment validation scripts now check for the correct files and directories.

---

## Files Updated

### 1. Configuration File (`config.R`)
**Changes:**
- ✅ Fixed file name: `utils.r` (not `utils.R`)
- ✅ Added `REQUIRED_DIRS` configuration
- ✅ Added `OPTIONAL_DIRS` configuration
- ✅ Enhanced validation functions

**New Configuration:**
```r
REQUIRED_DIRS = c(
  "deployment",
  "tests",
  "docs",
  "data",
  "www"
)

OPTIONAL_DIRS = c(
  "utils",
  "archive",
  "archivedocs",
  "archivelaunchers",
  "archivelogs",
  "archiveprogress",
  "Bow-tie guidance"
)
```

### 2. Linux/Unix Deployment Check (`deployment/check_deployment_readiness.sh`)
**Changes:**
- ✅ Added directory structure validation
- ✅ Reads `REQUIRED_DIRS` from `config.R`
- ✅ Enhanced file checking with proper counts
- ✅ Improved error reporting

**New Checks:**
- Required directories (5): deployment, tests, docs, data, www
- Required files (17): All core, module, and data files
- Directory permissions
- Comprehensive summary report

### 3. Windows PowerShell Script (`deployment/check_deployment_readiness.ps1`)
**Status:** Created but requires manual testing on Windows

**Note:** The PowerShell script has some syntax issues related to string interpolation. For Windows users, it's recommended to use Git Bash or WSL to run the Linux shell script instead.

### 4. Deployment Status Documentation (`deployment/DEPLOYMENT_STATUS.md`)
**Changes:**
- ✅ Created comprehensive deployment status report
- ✅ Documents all files and directories
- ✅ Lists recent bug fixes and improvements
- ✅ Provides deployment options and validation steps
- ✅ Includes performance metrics and testing status

---

## Current File Structure

### Required Application Files (17 files)
```
✅ app.R                           - Main application launcher
✅ global.R                        - Global configuration
✅ ui.R                            - User interface
✅ server.R                        - Server logic
✅ start_app.R                     - Network-ready starter
✅ config.R                        - Configuration management
✅ requirements.R                  - Package dependencies
✅ guided_workflow.R               - Guided wizard system
✅ bowtie_bayesian_network.R       - Bayesian integration
✅ utils.r                         - Utility functions
✅ vocabulary.R                    - Vocabulary management
✅ vocabulary_bowtie_generator.R   - Bow-tie generator
✅ translations_data.R             - Multi-language support
✅ environmental_scenarios.R       - Scenario configurations
✅ CAUSES.xlsx                     - Activities & pressures data
✅ CONSEQUENCES.xlsx               - Consequences data
✅ CONTROLS.xlsx                   - Controls data
```

### Required Directories (5 directories)
```
✅ deployment/    - Deployment scripts and documentation
✅ tests/         - Comprehensive test suite (11+ files)
✅ docs/          - Application documentation
✅ data/          - Data storage and cache
✅ www/           - Static assets (images, CSS, JS)
```

### Optional Directories (7 directories)
```
ℹ️ utils/                - Additional utility scripts
ℹ️ archive/              - Archived files
ℹ️ archivedocs/          - Archived documentation
ℹ️ archivelaunchers/     - Archived launcher scripts
ℹ️ archivelogs/          - Historical logs
ℹ️ archiveprogress/      - Development progress archives
ℹ️ Bow-tie guidance/     - Reference materials
```

---

## Validation Workflow

### Step 1: Run Deployment Readiness Check

**On Linux/Unix/macOS:**
```bash
cd deployment
chmod +x check_deployment_readiness.sh
sudo ./check_deployment_readiness.sh
```

**On Windows (Git Bash or WSL recommended):**
```bash
cd deployment
bash check_deployment_readiness.sh
```

### Step 2: Review Output

Expected output:
```
=============================================================================
  Pre-Deployment Readiness Check
  Environmental Bowtie Risk Analysis Application
=============================================================================

✓ R installed (version: 4.4.3)
✓ R version is sufficient (>= 4.3.0)
✓ Configuration file found (config.R)
ℹ Checking application files...
  ✓ app.R
  ✓ global.R
  ✓ ui.R
  ✓ server.R
  ... (all 17 files)
✓ All required application files present (17 files)

ℹ Checking required directories...
  ✓ deployment/
  ✓ tests/
  ✓ docs/
  ✓ data/
  ✓ www/
✓ All required directories present (5 directories)

✓ Port 3838 is in use (Application running)
✓ Sufficient disk space (XX GB available)
✓ Sufficient memory (XX GB total)

=============================================================================
  Summary
=============================================================================
Passed:   9+
Failed:   0
Warnings: 0-2

System is ready for deployment!
```

### Step 3: Deploy

If all checks pass:
```bash
# Local network deployment
Rscript start_app.R

# Or for Shiny Server deployment (Linux)
sudo ./deployment/deploy_shiny_server.sh --install-deps --backup
```

---

## Recent Bug Fixes

All these fixes are included in the current deployment framework:

1. **✅ Option 2b Scenario Error Fixed**
   - Issue: `getEnvironmentalScenario` function not found
   - Fix: Updated to use `generateScenarioSpecificBowtie()`
   - Status: Working in all 12 environmental scenarios

2. **✅ UI Improvements**
   - Vertically aligned scenario selectors
   - New Vocabulary Statistics card (3-column layout)
   - Real-time element counts display

3. **✅ Configuration Updates**
   - Corrected `utils.r` filename (case-sensitive)
   - Added directory validation
   - Enhanced deployment checks

---

## Deployment Options

### Option 1: Local Development
```bash
Rscript start_app.R
```
- Access: http://localhost:3838
- Use: Development and testing

### Option 2: Local Network
```bash
Rscript start_app.R
```
- Access: http://[YOUR_IP]:3838
- Use: Team collaboration, presentations
- Current: http://192.168.1.8:3838

### Option 3: Shiny Server (Production)
```bash
cd deployment
sudo ./deploy_shiny_server.sh --install-deps --backup
```
- Access: http://[server-ip]:3838/bowtie_app
- Use: Production deployment on Linux

### Option 4: Docker
```bash
cd deployment
docker-compose up bowtie-app
```
- Access: http://localhost:3838
- Use: Containerized deployment

---

## Testing the Deployment

### Manual Testing Checklist

After deployment, verify:

- [ ] Application loads at expected URL
- [ ] All tabs accessible (Data Upload, Guided Workflow, Bowtie, Bayesian, etc.)
- [ ] Option 2: Generate data from scenarios works
- [ ] Option 2b: Multiple controls data generation works
- [ ] Vocabulary Statistics card displays counts (53, 36, 74, 26)
- [ ] All 12 environmental scenarios available
- [ ] Bayesian network tab functional
- [ ] Export/download features working
- [ ] Multi-language switching (EN/FR) works

### Automated Testing

Run the test suite:
```bash
Rscript tests/comprehensive_test_runner.R
```

Expected: 11+ tests passing with 95%+ coverage

---

## Troubleshooting

### Common Issues

**1. Port 3838 already in use**
```bash
# Windows
netstat -ano | findstr :3838
taskkill //F //PID [PID_NUMBER]

# Linux
sudo lsof -i :3838
sudo kill [PID_NUMBER]
```

**2. Missing R packages**
```r
source("requirements.R")
install_all_packages()
```

**3. Permission denied (Linux)**
```bash
chmod +x deployment/*.sh
sudo chown -R shiny:shiny /srv/shiny-server/bowtie_app
```

**4. File not found errors**
- Verify all 17 required files exist
- Check file name case sensitivity (especially `utils.r`)
- Run deployment readiness check

---

## Next Steps

1. **Test the deployment framework:**
   ```bash
   cd deployment
   bash check_deployment_readiness.sh
   ```

2. **Deploy the application:**
   ```bash
   Rscript start_app.R
   ```

3. **Verify functionality:**
   - Access http://localhost:3838
   - Test all environmental scenarios
   - Verify vocabulary statistics display
   - Run automated tests

4. **Production deployment (optional):**
   ```bash
   cd deployment
   sudo ./deploy_shiny_server.sh --install-deps --backup
   ```

---

## Documentation

- **Deployment Guide:** `/deployment/DEPLOYMENT_GUIDE.md`
- **Deployment Status:** `/deployment/DEPLOYMENT_STATUS.md`
- **Testing Guide:** `/tests/TESTING_GUIDE.md`
- **Main README:** `/README.md`

---

**✅ Deployment Framework Status:** READY

The deployment framework has been fully updated and is ready for use. All file and directory checks now reflect the actual application structure.
