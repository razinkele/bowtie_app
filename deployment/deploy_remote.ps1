# =============================================================================
# Environmental Bowtie Risk Analysis - Remote Deployment to laguna.ku.lt
# PowerShell Version for Windows
# Version: 5.4.0
#
# Usage:
#   .\deploy_remote.ps1                    # Full deployment
#   .\deploy_remote.ps1 -Quick             # Quick update (skip R packages)
#   .\deploy_remote.ps1 -DryRun            # Show what would be transferred
#   .\deploy_remote.ps1 -SkipBackup        # Skip backup on remote server
#
# Requirements:
#   - SSH key authentication configured for laguna.ku.lt
#   - OpenSSH client (built into Windows 10+)
# =============================================================================

param(
    [switch]$Quick,
    [switch]$DryRun,
    [switch]$SkipBackup,
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$RemoteHost = "laguna.ku.lt"
$RemoteUser = "razinka"
$RemotePort = "22"

# Use Windows OpenSSH explicitly (more reliable in PowerShell)
$SshExe = "C:\Windows\System32\OpenSSH\ssh.exe"
$ScpExe = "C:\Windows\System32\OpenSSH\scp.exe"

$AppName = "bowtie_app"
$AppVersion = "5.4.0"
$RemoteAppDir = "/srv/shiny-server/$AppName"
$RemoteBackupDir = "/var/backups/shiny-apps"
$RemoteLogDir = "/var/log/shiny-server/$AppName"

# Local paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppSourceDir = Split-Path -Parent $ScriptDir

# SSH command base
$SshTarget = "$RemoteUser@$RemoteHost"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host ("=" * 65) -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host ("=" * 65) -ForegroundColor Cyan
}

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "> $Message" -ForegroundColor Blue
    Write-Host ("-" * 65) -ForegroundColor Blue
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor Blue
}

function Write-Pass {
    param([string]$Message)
    Write-Host "  [PASS] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-Action {
    param([string]$Message)
    Write-Host "  [....] $Message" -ForegroundColor Cyan
}

function Write-Done {
    param([string]$Message)
    Write-Host "  [DONE] $Message" -ForegroundColor Green
}

function Invoke-RemoteCommand {
    param(
        [string]$Command,
        [switch]$Sudo,
        [switch]$Silent,
        [int]$Timeout = 60
    )

    $fullCommand = if ($Sudo) { "sudo $Command" } else { $Command }

    if ($Silent) {
        $result = & $SshExe -o ConnectTimeout=$Timeout -t -p $RemotePort $SshTarget $fullCommand 2>&1
    } else {
        $result = & $SshExe -o ConnectTimeout=$Timeout -t -p $RemotePort $SshTarget $fullCommand
    }

    return $result
}

function Test-RemoteCommand {
    param(
        [string]$Command,
        [int]$Timeout = 30
    )

    # Use Windows OpenSSH with ConnectTimeout to prevent hanging
    $result = & $SshExe -o ConnectTimeout=$Timeout -p $RemotePort $SshTarget $Command 2>&1
    return $LASTEXITCODE -eq 0
}

# =============================================================================
# SHOW HELP
# =============================================================================

if ($Help) {
    Write-Host @"

Environmental Bowtie Risk Analysis - Remote Deployment
=======================================================

Usage: .\deploy_remote.ps1 [OPTIONS]

Options:
  -Quick        Skip R package installation on remote server
  -DryRun       Show what would be done without making changes
  -SkipBackup   Skip backup creation on remote server
  -Verbose      Show detailed output
  -Help         Show this help message

Examples:
  .\deploy_remote.ps1                    # Full deployment
  .\deploy_remote.ps1 -Quick             # Quick update
  .\deploy_remote.ps1 -DryRun            # Preview changes
  .\deploy_remote.ps1 -Quick -SkipBackup # Fastest update

Requirements:
  - SSH key configured: ssh-copy-id $SshTarget
  - OpenSSH client (Windows 10+ built-in)

"@
    exit 0
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

Clear-Host

Write-Host @"

  ================================================================
  |                                                              |
  |   Environmental Bowtie Risk Analysis                         |
  |   Remote Deployment to laguna.ku.lt                          |
  |                                                              |
  |   Version: $AppVersion                                             |
  |                                                              |
  ================================================================

"@ -ForegroundColor Cyan

Write-Host "  Source:      $AppSourceDir"
Write-Host "  Destination: $SshTarget`:$RemoteAppDir"
Write-Host "  Started:     $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

if ($DryRun) {
    Write-Host "  Mode:        DRY RUN (no changes will be made)" -ForegroundColor Yellow
} elseif ($Quick) {
    Write-Host "  Mode:        Quick Update (skip R packages)" -ForegroundColor Yellow
} else {
    Write-Host "  Mode:        Full Deployment" -ForegroundColor Green
}
Write-Host ""

# =============================================================================
# PRE-FLIGHT CHECKS
# =============================================================================

Write-Header "PRE-FLIGHT CHECKS"

Write-Section "1. Local Environment"

# Check SSH
Write-Action "Checking SSH..."
if (Test-Path $SshExe) {
    Write-Pass "SSH is available ($SshExe)"
} else {
    Write-Fail "SSH not found at $SshExe"
    exit 1
}

# Check SCP
Write-Action "Checking SCP..."
if (Test-Path $ScpExe) {
    Write-Pass "SCP is available"
} else {
    Write-Fail "SCP not found - install OpenSSH client"
    exit 1
}

# Check source directory
Write-Action "Checking source directory..."
if (Test-Path $AppSourceDir) {
    Write-Pass "Source directory exists"
} else {
    Write-Fail "Source directory not found: $AppSourceDir"
    exit 1
}

# Check critical files
Write-Action "Checking critical files..."
$criticalFiles = @("app.R", "global.R", "ui.R", "server.R", "config.R")
$missingFiles = @()
foreach ($file in $criticalFiles) {
    if (-not (Test-Path "$AppSourceDir\$file")) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -eq 0) {
    Write-Pass "All critical files present"
} else {
    Write-Fail "Missing critical files: $($missingFiles -join ', ')"
    exit 1
}

Write-Section "2. Remote Server Connectivity"

# Test SSH connection
Write-Action "Testing SSH connection to $RemoteHost..."
$sshTestResult = & $SshExe -p $RemotePort -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new $SshTarget "echo connected" 2>&1
if ($sshTestResult -match "connected") {
    Write-Pass "SSH connection successful"
} else {
    Write-Fail "Cannot connect to $RemoteHost"
    Write-Host ""
    Write-Host "  Make sure:" -ForegroundColor Yellow
    Write-Host "    1. SSH key is configured: ssh-copy-id $SshTarget"
    Write-Host "    2. Server is reachable: ping $RemoteHost"
    Write-Host "    3. SSH port $RemotePort is open"
    Write-Info "  Error: $sshTestResult"
    exit 1
}

# Check Shiny Server
Write-Action "Checking Shiny Server on remote..."
if (Test-RemoteCommand "which shiny-server") {
    Write-Pass "Shiny Server is installed"
} else {
    Write-Fail "Shiny Server not found on remote"
    exit 1
}

# Check R
Write-Action "Checking R on remote..."
if (Test-RemoteCommand "which R") {
    $rVersion = Invoke-RemoteCommand "R --version 2>/dev/null | head -n1" -Silent
    Write-Pass "R installed: $rVersion"

    # Check R library path
    Write-Action "Checking R library paths..."
    $rLibPaths = Invoke-RemoteCommand "Rscript -e '.libPaths()' 2>/dev/null" -Silent
    if ($rLibPaths) {
        $rLibPaths -split "`n" | Where-Object { $_ -match '^\[1\]' } | ForEach-Object {
            Write-Info "  Library: $($_ -replace '^\[1\] ', '' -replace '\"', '')"
        }
    }

    # Check key R packages
    Write-Action "Checking key R packages..."
    $packagesToCheck = @("shiny", "bslib", "DT", "bnlearn", "visNetwork")
    $packageCheck = Invoke-RemoteCommand "Rscript -e `"pkgs <- c('shiny','bslib','DT','bnlearn','visNetwork'); installed <- sapply(pkgs, requireNamespace, quietly=TRUE); cat(paste(pkgs, ifelse(installed, 'OK', 'MISSING'), sep='=', collapse=','))`" 2>/dev/null" -Silent

    if ($packageCheck) {
        $installedCount = 0
        $missingPackages = @()
        $packageCheck -split ',' | ForEach-Object {
            $parts = $_ -split '='
            if ($parts.Count -eq 2) {
                if ($parts[1] -eq 'OK') {
                    $installedCount++
                } else {
                    $missingPackages += $parts[0]
                }
            }
        }

        if ($missingPackages.Count -eq 0) {
            Write-Pass "All $($packagesToCheck.Count) key packages installed"
        } else {
            Write-Warn "Missing packages: $($missingPackages -join ', ')"
            Write-Info "  Run full deployment (without -Quick) to install"
        }
    }
} else {
    Write-Fail "R not found on remote"
    exit 1
}

Write-Host ""
Write-Pass "All pre-flight checks passed!"

# =============================================================================
# CREATE REMOTE BACKUP
# =============================================================================

Write-Header "CREATING REMOTE BACKUP"

if ($SkipBackup) {
    Write-Warn "Backup skipped (-SkipBackup flag)"
} else {
    $existsCheck = Test-RemoteCommand "[ -d $RemoteAppDir ]"
    if ($existsCheck) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "$RemoteBackupDir/${AppName}_${timestamp}.tar.gz"

        Write-Action "Creating backup directory..."
        Invoke-RemoteCommand "mkdir -p $RemoteBackupDir" -Sudo | Out-Null

        Write-Action "Creating backup: $backupFile..."
        if (-not $DryRun) {
            Invoke-RemoteCommand "tar -czf $backupFile -C /srv/shiny-server $AppName 2>/dev/null" -Sudo | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Done "Backup created"
            } else {
                Write-Warn "Backup may have failed - continuing"
            }
        } else {
            Write-Info "DRY RUN: Would create backup"
        }
    } else {
        Write-Info "No existing installation - skipping backup"
    }
}

# =============================================================================
# SYNC FILES TO REMOTE
# =============================================================================

Write-Header "SYNCING FILES TO REMOTE"

$stagingDir = "/tmp/${AppName}_deploy_$(Get-Random)"

Write-Action "Creating staging directory..."
if (-not $DryRun) {
    Invoke-RemoteCommand "mkdir -p $stagingDir" | Out-Null
}

# Files/folders to exclude
$excludePatterns = @(
    "*-Dell-PCn*",
    "*-laguna-safeBackup-*",
    "dev_config.R",
    "install_hooks.R",
    ".git",
    ".github",
    ".Rhistory",
    ".RData",
    "*.Rproj",
    "__pycache__",
    "archive",
    "tests",
    "docs",
    "deployment",
    "logs",
    ".claude",
    "*.log",
    "*.tmp",
    "node_modules"
)

# Count files to sync
$rFileCount = (Get-ChildItem "$AppSourceDir\*.R" -File).Count
Write-Info "Preparing to sync $rFileCount R files + data files"

if ($DryRun) {
    Write-Warn "DRY RUN - would sync files to $stagingDir"
} else {
    Write-Action "Syncing files via SCP..."

    # Get list of files to copy (excluding patterns)
    $filesToCopy = @()

    # Add R files (excluding dev files)
    Get-ChildItem "$AppSourceDir\*.R" -File | ForEach-Object {
        $exclude = $false
        foreach ($pattern in $excludePatterns) {
            if ($_.Name -like $pattern) {
                $exclude = $true
                break
            }
        }
        if (-not $exclude) {
            $filesToCopy += $_.FullName
        }
    }

    # Add Excel files
    Get-ChildItem "$AppSourceDir\*.xlsx" -File -ErrorAction SilentlyContinue | ForEach-Object {
        $filesToCopy += $_.FullName
    }

    # Copy files
    foreach ($file in $filesToCopy) {
        $fileName = Split-Path $file -Leaf
        & $ScpExe -P $RemotePort "$file" "${SshTarget}:${stagingDir}/" 2>$null
    }

    # Copy directories
    $dirsToSync = @("www", "data", "config", "helpers", "server_modules")
    foreach ($dir in $dirsToSync) {
        $localDir = "$AppSourceDir\$dir"
        if (Test-Path $localDir) {
            Write-Action "Copying $dir directory..."
            & $ScpExe -P $RemotePort -r "$localDir" "${SshTarget}:${stagingDir}/" 2>$null
        }
    }

    Write-Done "Files synced to staging"

    Write-Section "Installing to Shiny Server Directory"

    Write-Action "Creating application directory..."
    Invoke-RemoteCommand "mkdir -p $RemoteAppDir" -Sudo | Out-Null

    Write-Action "Copying files to $RemoteAppDir..."
    Invoke-RemoteCommand "cp -rf $stagingDir/* $RemoteAppDir/" -Sudo | Out-Null

    Write-Action "Creating runtime directories..."
    Invoke-RemoteCommand "mkdir -p $RemoteAppDir/data $RemoteAppDir/logs $RemoteLogDir" -Sudo | Out-Null

    Write-Action "Cleaning up staging..."
    Invoke-RemoteCommand "rm -rf $stagingDir" | Out-Null

    Write-Done "Files installed successfully"
}

# =============================================================================
# SET PERMISSIONS
# =============================================================================

if (-not $DryRun) {
    Write-Header "SETTING PERMISSIONS"

    Write-Action "Setting ownership to shiny user..."
    Invoke-RemoteCommand "chown -R shiny:shiny $RemoteAppDir" -Sudo | Out-Null
    Invoke-RemoteCommand "chown -R shiny:shiny $RemoteLogDir 2>/dev/null || true" -Sudo | Out-Null

    Write-Action "Setting permissions..."
    Invoke-RemoteCommand "find $RemoteAppDir -type d -exec chmod 755 {} \;" -Sudo | Out-Null
    Invoke-RemoteCommand "find $RemoteAppDir -type f -exec chmod 644 {} \;" -Sudo | Out-Null
    Invoke-RemoteCommand "chmod 775 $RemoteAppDir/data $RemoteAppDir/logs 2>/dev/null || true" -Sudo | Out-Null

    Write-Done "Permissions configured"
}

# =============================================================================
# INSTALL R DEPENDENCIES
# =============================================================================

Write-Header "R DEPENDENCIES"

if ($Quick) {
    Write-Info "Quick mode: Skipping R package installation"
    Write-Warn "Ensure packages are already installed on remote"
} elseif ($DryRun) {
    Write-Info "DRY RUN: Would install R dependencies"
} else {
    Write-Action "Installing R packages (this may take several minutes)..."
    $result = Invoke-RemoteCommand "cd $RemoteAppDir && Rscript requirements.R 2>&1" -Sudo
    if ($LASTEXITCODE -eq 0) {
        Write-Done "R packages installed"
    } else {
        Write-Warn "Some packages may have failed - check remote logs"
    }
}

# =============================================================================
# RESTART SHINY SERVER
# =============================================================================

if (-not $DryRun) {
    Write-Header "RESTARTING SHINY SERVER"

    Write-Action "Restarting shiny-server..."
    Invoke-RemoteCommand "systemctl restart shiny-server" -Sudo | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Done "Restart command sent"
    } else {
        Write-Fail "Failed to restart service"
        exit 1
    }

    Write-Action "Waiting for service to start..."
    Start-Sleep -Seconds 5

    if (Test-RemoteCommand "sudo systemctl is-active --quiet shiny-server") {
        Write-Done "Shiny Server is running"
    } else {
        Write-Fail "Shiny Server may have failed to start"
        Write-Info "Check logs: ssh $SshTarget 'sudo journalctl -u shiny-server -n 50'"
    }
}

# =============================================================================
# VERIFY DEPLOYMENT
# =============================================================================

if (-not $DryRun) {
    Write-Header "VERIFYING DEPLOYMENT"

    Write-Action "Checking service status..."
    if (Test-RemoteCommand "sudo systemctl is-active --quiet shiny-server") {
        Write-Pass "Shiny Server is active"
    } else {
        Write-Warn "Shiny Server may not be running"
    }

    Write-Action "Counting deployed files..."
    $deployedCount = Invoke-RemoteCommand "find $RemoteAppDir -name '*.R' -type f 2>/dev/null | wc -l" -Sudo
    Write-Pass "$deployedCount R files deployed"
}

# =============================================================================
# SHOW SUMMARY
# =============================================================================

Write-Header "DEPLOYMENT COMPLETE"

if ($DryRun) {
    Write-Host ""
    Write-Host "  DRY RUN COMPLETE - No changes were made" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  SUCCESS! Application deployed to $RemoteHost" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Application Details:" -ForegroundColor White
    Write-Host "    Name:      $AppName"
    Write-Host "    Version:   $AppVersion"
    Write-Host "    Server:    $RemoteHost"
    Write-Host "    Location:  $RemoteAppDir"
    Write-Host ""
    Write-Host "  Access URLs:" -ForegroundColor White
    Write-Host "    Public:    " -NoNewline
    Write-Host "http://${RemoteHost}:3838/${AppName}/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Useful Commands:" -ForegroundColor White
    Write-Host "    SSH:       ssh $SshTarget"
    Write-Host "    Logs:      ssh $SshTarget 'sudo tail -f $RemoteLogDir/*.log'"
    Write-Host "    Restart:   ssh $SshTarget 'sudo systemctl restart shiny-server'"
    Write-Host ""
}

Write-Host ("=" * 65) -ForegroundColor Cyan
