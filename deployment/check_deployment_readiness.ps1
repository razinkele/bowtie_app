# =============================================================================
# Pre-Deployment Readiness Check Script (Windows PowerShell)
# Environmental Bowtie Risk Analysis Application
# =============================================================================

$ErrorActionPreference = "Continue"

$PASS = 0
$FAIL = 0
$WARN = 0

function Log-Pass {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
    $script:PASS++
}

function Log-Fail {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
    $script:FAIL++
}

function Log-Warn {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
    $script:WARN++
}

function Log-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

Write-Host "=============================================================================" -ForegroundColor White
Write-Host "  Pre-Deployment Readiness Check (Windows)" -ForegroundColor White
Write-Host "  Environmental Bowtie Risk Analysis Application" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor White
Write-Host ""

# Get script directory and application source directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$APP_SOURCE_DIR = Split-Path -Parent $SCRIPT_DIR

# Check R installation
if (Get-Command Rscript -ErrorAction SilentlyContinue) {
    $R_VERSION = (Rscript --version 2>&1 | Select-String -Pattern "R version ([0-9.]+)" | ForEach-Object { $_.Matches.Groups[1].Value })
    Log-Pass "R installed (version: $R_VERSION)"

    # Check R version is sufficient
    $R_MAJOR = [int]($R_VERSION.Split('.')[0])
    $R_MINOR = [int]($R_VERSION.Split('.')[1])
    if ($R_MAJOR -ge 4 -and $R_MINOR -ge 3) {
        Log-Pass "R version is sufficient (>= 4.3.0)"
    } else {
        Log-Warn "R version should be 4.3.0 or higher (current: $R_VERSION)"
    }
} else {
    Log-Fail "R not installed or not in PATH"
}

# Load configuration from config.R
$CONFIG_PATH = Join-Path $APP_SOURCE_DIR "config.R"
if (Test-Path $CONFIG_PATH) {
    Log-Pass "Configuration file found (config.R)"

    # Load required files from config.R
    $REQUIRED_FILES_CMD = "suppressMessages({source('$($CONFIG_PATH.Replace('\','/'))', local=TRUE); cat(APP_CONFIG`$REQUIRED_FILES)})"
    $REQUIRED_FILES = @(Rscript --vanilla --quiet -e $REQUIRED_FILES_CMD 2>$null)

    $REQUIRED_DIRS_CMD = "suppressMessages({source('$($CONFIG_PATH.Replace('\','/'))', local=TRUE); cat(APP_CONFIG`$REQUIRED_DIRS)})"
    $REQUIRED_DIRS = @(Rscript --vanilla --quiet -e $REQUIRED_DIRS_CMD 2>$null)
} else {
    Log-Warn "Configuration file not found, using fallback list"

    # Fallback list if config.R not available
    $REQUIRED_FILES = @(
        "app.R",
        "global.R",
        "ui.R",
        "server.R",
        "start_app.R",
        "config.R",
        "requirements.R",
        "guided_workflow.R",
        "utils.r",
        "vocabulary.R",
        "vocabulary_bowtie_generator.R",
        "bowtie_bayesian_network.R",
        "translations_data.R",
        "environmental_scenarios.R",
        "CAUSES.xlsx",
        "CONSEQUENCES.xlsx",
        "CONTROLS.xlsx"
    )

    $REQUIRED_DIRS = @(
        "deployment",
        "tests",
        "docs",
        "data",
        "www"
    )
}

# Check application files
Log-Info "Checking application files in $APP_SOURCE_DIR..."
$MISSING = 0
foreach ($file in $REQUIRED_FILES) {
    $filePath = Join-Path $APP_SOURCE_DIR $file
    if (Test-Path $filePath) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file (missing)" -ForegroundColor Red
        $MISSING++
    }
}

if ($MISSING -eq 0) {
    $fileCount = $REQUIRED_FILES.Count
    Log-Pass "All required application files present: $fileCount files"
} else {
    Log-Fail "$MISSING required files missing"
    $FAIL += $MISSING
}

# Check required directories
Log-Info "Checking required directories..."
$MISSING_DIRS = 0
foreach ($dir in $REQUIRED_DIRS) {
    $dirPath = Join-Path $APP_SOURCE_DIR $dir
    if (Test-Path $dirPath -PathType Container) {
        Write-Host "  ✓ $dir/" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $dir/ (missing)" -ForegroundColor Red
        $MISSING_DIRS++
    }
}

if ($MISSING_DIRS -eq 0) {
    $dirCount = $REQUIRED_DIRS.Count
    Log-Pass "All required directories present: $dirCount directories"
} else {
    Log-Fail "$MISSING_DIRS required directories missing"
    $FAIL += $MISSING_DIRS
}

# Check for optional directories
$OPTIONAL_DIRS = @("utils", "archive", "archivedocs", "archivelaunchers", "archivelogs", "archiveprogress")
Log-Info "Checking optional directories..."
$FOUND_OPTIONAL = 0
foreach ($dir in $OPTIONAL_DIRS) {
    $dirPath = Join-Path $APP_SOURCE_DIR $dir
    if (Test-Path $dirPath -PathType Container) {
        Write-Host "  ✓ $dir/ (optional)" -ForegroundColor Gray
        $FOUND_OPTIONAL++
    }
}
if ($FOUND_OPTIONAL -gt 0) {
    Log-Info "$FOUND_OPTIONAL optional directories found"
}

# Check network port 3838
$PORT_CHECK = Get-NetTCPConnection -LocalPort 3838 -ErrorAction SilentlyContinue
if ($PORT_CHECK) {
    Log-Pass "Port 3838 is in use (Application may be running)"
} else {
    Log-Warn "Port 3838 not in use (Application not running)"
}

# Check disk space
$DRIVE = (Get-Item $APP_SOURCE_DIR).PSDrive.Name
$DISK = Get-PSDrive $DRIVE
$FREE_GB = [math]::Round($DISK.Free / 1GB, 2)
if ($FREE_GB -gt 2) {
    Log-Pass "Sufficient disk space: $FREE_GB GB available"
} else {
    Log-Warn "Low disk space: $FREE_GB GB available, recommend > 2GB"
}

# Check memory
$TOTAL_MEM_GB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
if ($TOTAL_MEM_GB -ge 4) {
    Log-Pass "Sufficient memory: $TOTAL_MEM_GB GB total"
} else {
    Log-Warn "Low memory: $TOTAL_MEM_GB GB total, recommend >= 4GB"
}

# Check if required R packages are installed
Log-Info "Checking R package dependencies..."
$PACKAGES_CHECK = @"
required_packages <- c('shiny', 'bslib', 'DT', 'readxl', 'openxlsx',
                       'ggplot2', 'plotly', 'dplyr', 'visNetwork',
                       'shinycssloaders', 'colourpicker', 'htmlwidgets', 'shinyjs',
                       'bnlearn', 'gRain', 'igraph', 'DiagrammeR')
installed <- sapply(required_packages, requireNamespace, quietly=TRUE)
cat(sum(installed), '/', length(required_packages))
"@

$PKG_RESULT = Rscript --vanilla --quiet -e $PACKAGES_CHECK 2>$null
if ($PKG_RESULT -match "(\d+)\s*/\s*(\d+)") {
    $INSTALLED = [int]$Matches[1]
    $TOTAL = [int]$Matches[2]
    if ($INSTALLED -eq $TOTAL) {
        Log-Pass "All required R packages installed: $INSTALLED/$TOTAL"
    } else {
        Log-Warn "Some R packages missing: $INSTALLED/$TOTAL installed"
    }
}

# Check test framework
$TEST_DIR = Join-Path $APP_SOURCE_DIR "tests"
if (Test-Path $TEST_DIR) {
    $TEST_FILES = Get-ChildItem -Path $TEST_DIR -Filter "*.R" -Recurse
    if ($TEST_FILES.Count -gt 0) {
        $testCount = $TEST_FILES.Count
        Log-Pass "Test framework found: $testCount test files"
    } else {
        Log-Warn "Test directory exists but no test files found"
    }
}

# Summary
Write-Host ""
Write-Host "=============================================================================" -ForegroundColor White
Write-Host "  Summary" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor White
Write-Host "Passed:   " -NoNewline
Write-Host $PASS -ForegroundColor Green
Write-Host "Failed:   " -NoNewline
Write-Host $FAIL -ForegroundColor Red
Write-Host "Warnings: " -NoNewline
Write-Host $WARN -ForegroundColor Yellow
Write-Host ""

if ($FAIL -eq 0) {
    Write-Host "System is ready for deployment!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To run the application:" -ForegroundColor Cyan
    Write-Host "  Rscript start_app.R" -ForegroundColor White
    Write-Host ""
    Write-Host "Or for network access:" -ForegroundColor Cyan
    Write-Host "  Rscript start_app.R" -ForegroundColor White
    Write-Host "  Access at: http://localhost:3838" -ForegroundColor White
    exit 0
} else {
    Write-Host "System is NOT ready for deployment" -ForegroundColor Red
    Write-Host "Please resolve the issues above before deploying." -ForegroundColor Red
    exit 1
}
