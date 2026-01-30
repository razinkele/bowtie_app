@echo off
REM =============================================================================
REM Environmental Bowtie Risk Analysis - Remote Deployment to laguna.ku.lt
REM Enhanced CMD version with comprehensive error handling
REM Version: 5.4.1 - Updated January 2026
REM =============================================================================
REM
REM Features:
REM   - Comprehensive error handling with retry logic
REM   - Deployment logging to file
REM   - Rollback capability on critical failures
REM   - File transfer verification
REM   - Detailed error reporting
REM
REM Usage:
REM   deploy_remote.cmd              Full deployment
REM   deploy_remote.cmd --quick      Skip R package installation
REM   deploy_remote.cmd --dry-run    Preview without making changes
REM   deploy_remote.cmd --verbose    Show detailed output
REM   deploy_remote.cmd --help       Show help
REM
REM Essential files deployed:
REM   Core App:     app.R, global.R, server.R, ui.R, start_app.R
REM   Config:       config.R, constants.R, requirements.R
REM   Utilities:    utils.R, vocabulary.R, translations_data.R
REM   Workflow:     guided_workflow.R, environmental_scenarios.R
REM   Bayesian:     bowtie_bayesian_network.R, vocabulary_bowtie_generator.R
REM   AI/ML:        intelligent_bowtie_suggester.R, vocabulary-ai-*.R
REM   UI:           ui_components.R, ui_content_sections.R
REM   Data:         CAUSES.xlsx, CONSEQUENCES.xlsx, CONTROLS.xlsx
REM   Directories:  www/, data/, config/, helpers/, server_modules/
REM
REM Excluded (dev-only): dev_config.R, install_hooks.R, check_version.R,
REM                      compile_*.R, test_*.R, *_results*.rds
REM =============================================================================

setlocal enabledelayedexpansion

REM =============================================================================
REM CONFIGURATION
REM =============================================================================

REM Remote server settings (can be overridden by environment variables)
if defined BOWTIE_DEPLOY_HOST (
    set REMOTE_HOST=%BOWTIE_DEPLOY_HOST%
) else (
    set REMOTE_HOST=laguna.ku.lt
)

if defined BOWTIE_DEPLOY_USER (
    set REMOTE_USER=%BOWTIE_DEPLOY_USER%
) else (
    set REMOTE_USER=razinka
)

if defined BOWTIE_DEPLOY_PORT (
    set REMOTE_PORT=%BOWTIE_DEPLOY_PORT%
) else (
    set REMOTE_PORT=22
)

set APP_NAME=bowtie_app
set REMOTE_APP_DIR=/srv/shiny-server/%APP_NAME%
set REMOTE_BACKUP_DIR=/var/backups/shiny-apps
set SSH_EXE=C:\Windows\System32\OpenSSH\ssh.exe
set SCP_EXE=C:\Windows\System32\OpenSSH\scp.exe
set SSH_TARGET=%REMOTE_USER%@%REMOTE_HOST%

REM Get script directory and app source
set SCRIPT_DIR=%~dp0
set APP_SOURCE_DIR=%SCRIPT_DIR%..

REM Read version from VERSION file if exists
set APP_VERSION=5.4.1
if exist "%APP_SOURCE_DIR%\VERSION" (
    set /p APP_VERSION=<"%APP_SOURCE_DIR%\VERSION"
)

REM Initialize counters and flags
set ERROR_COUNT=0
set WARNING_COUNT=0
set FILES_COPIED=0
set FILES_FAILED=0
set QUICK_MODE=0
set DRY_RUN=0
set VERBOSE=0
set BACKUP_CREATED=0
set STAGING_DIR=
set BACKUP_FILE=

REM Log file
set LOG_FILE=%SCRIPT_DIR%deploy_log_%DATE:~-4,4%%DATE:~-7,2%%DATE:~-10,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.txt
set LOG_FILE=%LOG_FILE: =0%

REM Retry settings
set MAX_RETRIES=3
set RETRY_DELAY=2

REM =============================================================================
REM PARSE COMMAND LINE ARGUMENTS
REM =============================================================================

:parse_args
if "%1"=="" goto :done_parsing
if /I "%1"=="--quick" set QUICK_MODE=1 & shift & goto :parse_args
if /I "%1"=="-q" set QUICK_MODE=1 & shift & goto :parse_args
if /I "%1"=="--dry-run" set DRY_RUN=1 & shift & goto :parse_args
if /I "%1"=="--verbose" set VERBOSE=1 & shift & goto :parse_args
if /I "%1"=="-v" set VERBOSE=1 & shift & goto :parse_args
if /I "%1"=="--help" goto :show_help
if /I "%1"=="-h" goto :show_help
echo [WARN] Unknown argument: %1
shift
goto :parse_args

:show_help
echo.
echo Environmental Bowtie Risk Analysis - Remote Deployment
echo =======================================================
echo.
echo Usage: %~nx0 [OPTIONS]
echo.
echo Options:
echo   --quick, -q     Skip R package installation on remote server
echo   --dry-run       Preview changes without executing them
echo   --verbose, -v   Show detailed output including all file transfers
echo   --help, -h      Show this help message
echo.
echo Environment Variables:
echo   BOWTIE_DEPLOY_HOST   Remote host (default: laguna.ku.lt)
echo   BOWTIE_DEPLOY_USER   Remote user (default: razinka)
echo   BOWTIE_DEPLOY_PORT   SSH port (default: 22)
echo.
echo Examples:
echo   %~nx0                    Full deployment
echo   %~nx0 --quick            Quick update (skip R packages)
echo   %~nx0 --dry-run          Preview what would be done
echo   %~nx0 --quick --verbose  Quick update with detailed output
echo.
exit /b 0

:done_parsing

REM =============================================================================
REM HELPER FUNCTIONS
REM =============================================================================

goto :skip_functions

:log_message
REM Usage: call :log_message "MESSAGE"
echo %~1
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
goto :eof

:log_error
REM Usage: call :log_error "MESSAGE"
echo [FAIL] %~1
echo [%DATE% %TIME%] [ERROR] %~1 >> "%LOG_FILE%"
set /a ERROR_COUNT+=1
goto :eof

:log_warning
REM Usage: call :log_warning "MESSAGE"
echo [WARN] %~1
echo [%DATE% %TIME%] [WARN] %~1 >> "%LOG_FILE%"
set /a WARNING_COUNT+=1
goto :eof

:log_success
REM Usage: call :log_success "MESSAGE"
echo [PASS] %~1
echo [%DATE% %TIME%] [OK] %~1 >> "%LOG_FILE%"
goto :eof

:log_info
REM Usage: call :log_info "MESSAGE"
echo [INFO] %~1
echo [%DATE% %TIME%] [INFO] %~1 >> "%LOG_FILE%"
goto :eof

:log_action
REM Usage: call :log_action "MESSAGE"
echo [....] %~1
echo [%DATE% %TIME%] [ACTION] %~1 >> "%LOG_FILE%"
goto :eof

:log_verbose
REM Usage: call :log_verbose "MESSAGE"
if %VERBOSE%==1 echo        %~1
echo [%DATE% %TIME%] [VERBOSE] %~1 >> "%LOG_FILE%"
goto :eof

:ssh_command
REM Usage: call :ssh_command "COMMAND" RESULT_VAR
REM Executes SSH command with retry logic
set "_ssh_cmd=%~1"
set "_retry=0"

:ssh_retry_loop
"%SSH_EXE%" -o ConnectTimeout=30 -o BatchMode=yes -p %REMOTE_PORT% %SSH_TARGET% "%_ssh_cmd%" 2>>"%LOG_FILE%"
if %ERRORLEVEL% EQU 0 goto :ssh_success
set /a _retry+=1
if %_retry% GEQ %MAX_RETRIES% goto :ssh_failed
call :log_verbose "Retry %_retry%/%MAX_RETRIES% for SSH command..."
timeout /t %RETRY_DELAY% /nobreak >nul
goto :ssh_retry_loop

:ssh_success
set %2=0
goto :eof

:ssh_failed
call :log_error "SSH command failed after %MAX_RETRIES% retries: %_ssh_cmd%"
set %2=1
goto :eof

:scp_file
REM Usage: call :scp_file "LOCAL_PATH" "REMOTE_PATH" RESULT_VAR
REM Copies file with retry logic and verification
set "_local=%~1"
set "_remote=%~2"
set "_filename=%~nx1"
set "_retry=0"

if %DRY_RUN%==1 (
    call :log_verbose "Would copy: %_filename%"
    set /a FILES_COPIED+=1
    set %3=0
    goto :eof
)

:scp_retry_loop
"%SCP_EXE%" -P %REMOTE_PORT% "%_local%" "%SSH_TARGET%:%_remote%" 2>>"%LOG_FILE%"
if %ERRORLEVEL% EQU 0 goto :scp_verify
set /a _retry+=1
if %_retry% GEQ %MAX_RETRIES% goto :scp_failed
call :log_verbose "Retry %_retry%/%MAX_RETRIES% for: %_filename%"
timeout /t %RETRY_DELAY% /nobreak >nul
goto :scp_retry_loop

:scp_verify
REM Verify file exists on remote
"%SSH_EXE%" -o ConnectTimeout=10 -o BatchMode=yes -p %REMOTE_PORT% %SSH_TARGET% "test -f %_remote%/%_filename%" 2>>"%LOG_FILE%"
if %ERRORLEVEL% EQU 0 (
    set /a FILES_COPIED+=1
    call :log_verbose "Copied: %_filename%"
    set %3=0
    goto :eof
)
call :log_warning "File transfer verification failed: %_filename%"
set /a _retry+=1
if %_retry% GEQ %MAX_RETRIES% goto :scp_failed
goto :scp_retry_loop

:scp_failed
call :log_error "Failed to copy: %_filename%"
set /a FILES_FAILED+=1
set %3=1
goto :eof

:scp_directory
REM Usage: call :scp_directory "LOCAL_DIR" "REMOTE_PATH" RESULT_VAR
REM Copies directory with retry logic
set "_local_dir=%~1"
set "_remote_dir=%~2"
set "_dirname=%~nx1"
set "_retry=0"

if not exist "%_local_dir%" (
    call :log_verbose "Directory does not exist: %_dirname%"
    set %3=0
    goto :eof
)

if %DRY_RUN%==1 (
    call :log_verbose "Would copy directory: %_dirname%/"
    set %3=0
    goto :eof
)

:scp_dir_retry
"%SCP_EXE%" -P %REMOTE_PORT% -r "%_local_dir%" "%SSH_TARGET%:%_remote_dir%/" 2>>"%LOG_FILE%"
if %ERRORLEVEL% EQU 0 (
    call :log_verbose "Copied directory: %_dirname%/"
    set %3=0
    goto :eof
)
set /a _retry+=1
if %_retry% GEQ %MAX_RETRIES% (
    call :log_error "Failed to copy directory: %_dirname%/"
    set %3=1
    goto :eof
)
call :log_verbose "Retry %_retry%/%MAX_RETRIES% for directory: %_dirname%/"
timeout /t %RETRY_DELAY% /nobreak >nul
goto :scp_dir_retry

:skip_functions

REM =============================================================================
REM MAIN SCRIPT START
REM =============================================================================

cls
echo.
echo ================================================================
echo   Environmental Bowtie Risk Analysis
echo   Remote Deployment to %REMOTE_HOST%
echo   Version: %APP_VERSION%
echo ================================================================
echo.
echo   Source:      %APP_SOURCE_DIR%
echo   Destination: %SSH_TARGET%:%REMOTE_APP_DIR%
echo   Started:     %DATE% %TIME%
echo   Log file:    %LOG_FILE%
echo.

REM Show mode
if %DRY_RUN%==1 (
    echo   Mode:        DRY RUN ^(no changes will be made^)
) else if %QUICK_MODE%==1 (
    echo   Mode:        Quick Update ^(skip R packages^)
) else (
    echo   Mode:        Full Deployment
)
if %VERBOSE%==1 echo   Verbose:     Enabled
echo.

REM Initialize log file
echo ================================================================ > "%LOG_FILE%"
echo Environmental Bowtie Risk Analysis - Deployment Log >> "%LOG_FILE%"
echo Started: %DATE% %TIME% >> "%LOG_FILE%"
echo Version: %APP_VERSION% >> "%LOG_FILE%"
echo Target: %SSH_TARGET%:%REMOTE_APP_DIR% >> "%LOG_FILE%"
echo Mode: DRY_RUN=%DRY_RUN% QUICK=%QUICK_MODE% VERBOSE=%VERBOSE% >> "%LOG_FILE%"
echo ================================================================ >> "%LOG_FILE%"

REM =============================================================================
REM PRE-FLIGHT CHECKS
REM =============================================================================

call :log_message ""
call :log_message "================================================================"
call :log_message "  PRE-FLIGHT CHECKS"
call :log_message "================================================================"
echo.

REM Check SSH executable
call :log_action "Checking SSH installation..."
if not exist "%SSH_EXE%" (
    call :log_error "SSH not found at %SSH_EXE%"
    call :log_info "Please ensure OpenSSH client is installed"
    goto :deployment_failed
)
call :log_success "SSH is available"

REM Check SCP executable
call :log_action "Checking SCP installation..."
if not exist "%SCP_EXE%" (
    call :log_error "SCP not found at %SCP_EXE%"
    goto :deployment_failed
)
call :log_success "SCP is available"

REM Check source directory
call :log_action "Checking source directory..."
if not exist "%APP_SOURCE_DIR%" (
    call :log_error "Source directory not found: %APP_SOURCE_DIR%"
    goto :deployment_failed
)
call :log_success "Source directory exists"

REM Check critical files
call :log_action "Checking critical files..."
set CRITICAL_FILES=app.R global.R server.R ui.R config.R requirements.R
set MISSING_FILES=
for %%f in (%CRITICAL_FILES%) do (
    if not exist "%APP_SOURCE_DIR%\%%f" (
        set MISSING_FILES=!MISSING_FILES! %%f
    )
)
if defined MISSING_FILES (
    call :log_error "Missing critical files:%MISSING_FILES%"
    goto :deployment_failed
)
call :log_success "All critical files present"

REM Test SSH connection with retry
call :log_action "Testing SSH connection to %REMOTE_HOST%..."
set SSH_CONNECTED=0
for /L %%i in (1,1,%MAX_RETRIES%) do (
    if !SSH_CONNECTED!==0 (
        "%SSH_EXE%" -o ConnectTimeout=15 -o BatchMode=yes -p %REMOTE_PORT% %SSH_TARGET% "echo CONNECTED" >nul 2>&1
        if !ERRORLEVEL! EQU 0 (
            set SSH_CONNECTED=1
        ) else (
            if %%i LSS %MAX_RETRIES% (
                call :log_verbose "Connection attempt %%i failed, retrying..."
                timeout /t %RETRY_DELAY% /nobreak >nul
            )
        )
    )
)
if %SSH_CONNECTED%==0 (
    call :log_error "Cannot connect to %REMOTE_HOST%"
    echo.
    echo   Troubleshooting:
    echo     1. Check SSH key: ssh-copy-id %SSH_TARGET%
    echo     2. Test connection: ssh %SSH_TARGET%
    echo     3. Verify host: ping %REMOTE_HOST%
    echo     4. Check port %REMOTE_PORT% is open
    goto :deployment_failed
)
call :log_success "SSH connection successful"

REM Check Shiny Server on remote
call :log_action "Checking Shiny Server on remote..."
"%SSH_EXE%" -o ConnectTimeout=15 -o BatchMode=yes -p %REMOTE_PORT% %SSH_TARGET% "command -v shiny-server" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :log_error "Shiny Server not found on remote"
    goto :deployment_failed
)
call :log_success "Shiny Server installed"

REM Check R on remote
call :log_action "Checking R on remote..."
"%SSH_EXE%" -o ConnectTimeout=15 -o BatchMode=yes -p %REMOTE_PORT% %SSH_TARGET% "command -v R" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :log_error "R not found on remote"
    goto :deployment_failed
)
call :log_success "R installed"

REM Check existing deployment
call :log_action "Checking existing deployment..."
"%SSH_EXE%" -o ConnectTimeout=15 -o BatchMode=yes -p %REMOTE_PORT% %SSH_TARGET% "test -d %REMOTE_APP_DIR%" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    call :log_info "Existing deployment found - will update"
    set EXISTING_DEPLOYMENT=1
) else (
    call :log_info "Fresh installation - no existing deployment"
    set EXISTING_DEPLOYMENT=0
)

echo.
call :log_success "All pre-flight checks passed!"
echo.

if %DRY_RUN%==1 (
    call :log_info "DRY RUN: Pre-flight checks complete"
)

REM =============================================================================
REM CREATE REMOTE BACKUP
REM =============================================================================

call :log_message ""
call :log_message "================================================================"
call :log_message "  CREATING REMOTE BACKUP"
call :log_message "================================================================"
echo.

if %EXISTING_DEPLOYMENT%==0 (
    call :log_info "No existing deployment - skipping backup"
    goto :skip_backup
)

if %DRY_RUN%==1 (
    call :log_info "DRY RUN: Would create backup of existing deployment"
    goto :skip_backup
)

REM Create backup
set TIMESTAMP=%DATE:~-4,4%%DATE:~-7,2%%DATE:~-10,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set BACKUP_FILE=%REMOTE_BACKUP_DIR%/%APP_NAME%_%TIMESTAMP%.tar.gz

call :log_action "Creating backup directory..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo mkdir -p %REMOTE_BACKUP_DIR%" 2>>"%LOG_FILE%"

call :log_action "Creating backup: %BACKUP_FILE%..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo tar -czf %BACKUP_FILE% -C /srv/shiny-server %APP_NAME% 2>/dev/null" 2>>"%LOG_FILE%"
if %ERRORLEVEL% EQU 0 (
    set BACKUP_CREATED=1
    call :log_success "Backup created successfully"
) else (
    call :log_warning "Backup creation failed - continuing anyway"
)

:skip_backup

REM =============================================================================
REM SYNC FILES TO REMOTE
REM =============================================================================

call :log_message ""
call :log_message "================================================================"
call :log_message "  SYNCING FILES TO REMOTE"
call :log_message "================================================================"
echo.

REM Create staging directory
set STAGING_DIR=/tmp/%APP_NAME%_deploy_%RANDOM%
call :log_action "Creating staging directory: %STAGING_DIR%"

if %DRY_RUN%==0 (
    "%SSH_EXE%" -p %REMOTE_PORT% %SSH_TARGET% "mkdir -p %STAGING_DIR%" 2>>"%LOG_FILE%"
    if %ERRORLEVEL% NEQ 0 (
        call :log_error "Failed to create staging directory"
        goto :deployment_failed
    )
)
call :log_success "Staging directory ready"

REM Define files to exclude
set EXCLUDE_FILES=dev_config.R install_hooks.R check_version.R compile_manual.R compile_french_manual.R

REM Copy R files
call :log_action "Copying R files..."
set R_FILE_COUNT=0
for %%f in ("%APP_SOURCE_DIR%\*.R") do (
    set "_skip=0"
    set "_filename=%%~nxf"

    REM Check if file should be excluded
    for %%x in (%EXCLUDE_FILES%) do (
        if /I "!_filename!"=="%%x" set "_skip=1"
    )

    REM Skip test files
    echo !_filename! | findstr /I /B "test_" >nul && set "_skip=1"

    REM Skip Dell-PC specific files
    echo !_filename! | findstr /I "Dell-PCn" >nul && set "_skip=1"

    if !_skip!==1 (
        call :log_verbose "Skipped: !_filename! [excluded]"
    ) else (
        call :scp_file "%%f" "%STAGING_DIR%" _result
        set /a R_FILE_COUNT+=1
    )
)
call :log_info "Processed %R_FILE_COUNT% R files"

REM Copy Excel data files (excluding test output)
call :log_action "Copying Excel data files..."
for %%f in ("%APP_SOURCE_DIR%\*.xlsx") do (
    set "_filename=%%~nxf"
    REM Skip test output files
    echo !_filename! | findstr /I /B "test_" >nul
    if !ERRORLEVEL! EQU 0 (
        call :log_verbose "Skipped: !_filename! [test output]"
    ) else (
        call :scp_file "%%f" "%STAGING_DIR%" _result
    )
)

REM Copy directories
call :log_action "Copying directories..."
call :scp_directory "%APP_SOURCE_DIR%\www" "%STAGING_DIR%" _result
call :scp_directory "%APP_SOURCE_DIR%\data" "%STAGING_DIR%" _result
call :scp_directory "%APP_SOURCE_DIR%\config" "%STAGING_DIR%" _result
call :scp_directory "%APP_SOURCE_DIR%\helpers" "%STAGING_DIR%" _result
call :scp_directory "%APP_SOURCE_DIR%\server_modules" "%STAGING_DIR%" _result

echo.
call :log_info "Files copied: %FILES_COPIED%"
if %FILES_FAILED% GTR 0 (
    call :log_warning "Files failed: %FILES_FAILED%"
)

if %FILES_FAILED% GTR 5 (
    call :log_error "Too many file transfer failures (%FILES_FAILED%) - aborting"
    goto :deployment_failed
)

REM =============================================================================
REM DEPLOY TO SHINY SERVER
REM =============================================================================

call :log_message ""
call :log_message "================================================================"
call :log_message "  DEPLOYING TO SHINY SERVER"
call :log_message "================================================================"
echo.

if %DRY_RUN%==1 (
    call :log_info "DRY RUN: Would deploy files to %REMOTE_APP_DIR%"
    goto :skip_deploy
)

echo NOTE: You may be prompted for your sudo password.
echo.

REM Create app directory
call :log_action "Creating application directory..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo mkdir -p %REMOTE_APP_DIR%" 2>>"%LOG_FILE%"
if %ERRORLEVEL% NEQ 0 (
    call :log_error "Failed to create application directory"
    goto :deployment_failed
)

REM Copy files from staging
call :log_action "Installing files to %REMOTE_APP_DIR%..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo cp -rf %STAGING_DIR%/* %REMOTE_APP_DIR%/" 2>>"%LOG_FILE%"
if %ERRORLEVEL% NEQ 0 (
    call :log_error "Failed to copy files to application directory"
    goto :rollback
)
call :log_success "Files installed"

REM Set permissions
call :log_action "Setting ownership to shiny user..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo chown -R shiny:shiny %REMOTE_APP_DIR%" 2>>"%LOG_FILE%"
if %ERRORLEVEL% NEQ 0 (
    call :log_warning "Failed to set ownership - may need manual fix"
)

call :log_action "Setting file permissions..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo find %REMOTE_APP_DIR% -type d -exec chmod 755 {} \; && sudo find %REMOTE_APP_DIR% -type f -exec chmod 644 {} \;" 2>>"%LOG_FILE%"

REM Create runtime directories
call :log_action "Creating runtime directories..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo mkdir -p %REMOTE_APP_DIR%/data %REMOTE_APP_DIR%/logs && sudo chmod 775 %REMOTE_APP_DIR%/data %REMOTE_APP_DIR%/logs && sudo chown shiny:shiny %REMOTE_APP_DIR%/data %REMOTE_APP_DIR%/logs" 2>>"%LOG_FILE%"

REM Clean up staging
call :log_action "Cleaning up staging directory..."
"%SSH_EXE%" -p %REMOTE_PORT% %SSH_TARGET% "rm -rf %STAGING_DIR%" 2>>"%LOG_FILE%"

call :log_success "Deployment complete"

:skip_deploy

REM =============================================================================
REM R DEPENDENCIES
REM =============================================================================

call :log_message ""
call :log_message "================================================================"
call :log_message "  R DEPENDENCIES"
call :log_message "================================================================"
echo.

if %DRY_RUN%==1 (
    call :log_info "DRY RUN: Would install R packages"
    goto :skip_dependencies
)

if %QUICK_MODE%==1 (
    call :log_info "Quick mode - skipping R package installation"
    call :log_warning "Ensure packages are already installed on remote"
    goto :skip_dependencies
)

call :log_action "Installing R packages (this may take several minutes)..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "cd %REMOTE_APP_DIR% && sudo Rscript requirements.R" 2>>"%LOG_FILE%"
if %ERRORLEVEL% EQU 0 (
    call :log_success "R packages installed"
) else (
    call :log_warning "Some packages may have failed - check remote logs"
)

:skip_dependencies

REM =============================================================================
REM RESTART SHINY SERVER
REM =============================================================================

call :log_message ""
call :log_message "================================================================"
call :log_message "  RESTARTING SHINY SERVER"
call :log_message "================================================================"
echo.

if %DRY_RUN%==1 (
    call :log_info "DRY RUN: Would restart shiny-server"
    goto :skip_restart
)

call :log_action "Restarting shiny-server..."
"%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo systemctl restart shiny-server" 2>>"%LOG_FILE%"
if %ERRORLEVEL% NEQ 0 (
    call :log_error "Failed to restart shiny-server"
    goto :deployment_failed
)

call :log_action "Waiting for service to start..."
timeout /t 5 /nobreak >nul

REM Check service status with retry
call :log_action "Verifying service status..."
set SERVICE_OK=0
for /L %%i in (1,1,3) do (
    if !SERVICE_OK!==0 (
        "%SSH_EXE%" -p %REMOTE_PORT% %SSH_TARGET% "sudo systemctl is-active --quiet shiny-server" 2>>"%LOG_FILE%"
        if !ERRORLEVEL! EQU 0 (
            set SERVICE_OK=1
        ) else (
            timeout /t 2 /nobreak >nul
        )
    )
)

if %SERVICE_OK%==1 (
    call :log_success "Shiny Server is running"
) else (
    call :log_error "Shiny Server failed to start"
    call :log_info "Check logs: ssh %SSH_TARGET% 'sudo journalctl -u shiny-server -n 50'"
    goto :deployment_failed
)

:skip_restart

REM =============================================================================
REM VERIFY DEPLOYMENT
REM =============================================================================

call :log_message ""
call :log_message "================================================================"
call :log_message "  VERIFYING DEPLOYMENT"
call :log_message "================================================================"
echo.

if %DRY_RUN%==1 (
    call :log_info "DRY RUN: Would verify deployment"
    goto :skip_verify
)

REM Count deployed files
call :log_action "Counting deployed files..."
for /f %%a in ('"%SSH_EXE%" -p %REMOTE_PORT% %SSH_TARGET% "find %REMOTE_APP_DIR% -name \"*.R\" -type f 2>/dev/null | wc -l"') do set DEPLOYED_R_COUNT=%%a
call :log_success "%DEPLOYED_R_COUNT% R files deployed"

REM Check HTTP response
call :log_action "Testing HTTP response..."
timeout /t 3 /nobreak >nul
for /f %%a in ('"%SSH_EXE%" -p %REMOTE_PORT% %SSH_TARGET% "curl -s -o /dev/null -w '%%{http_code}' 'http://localhost:3838/%APP_NAME%/' --max-time 10 2>/dev/null"') do set HTTP_CODE=%%a

if "%HTTP_CODE%"=="200" (
    call :log_success "Application responding (HTTP 200)"
) else if "%HTTP_CODE%"=="302" (
    call :log_success "Application responding (HTTP 302 redirect)"
) else if "%HTTP_CODE%"=="000" (
    call :log_warning "Could not connect - app may still be initializing"
) else (
    call :log_warning "HTTP response: %HTTP_CODE%"
)

:skip_verify

REM =============================================================================
REM DEPLOYMENT SUMMARY
REM =============================================================================

call :log_message ""
call :log_message "================================================================"
call :log_message "  DEPLOYMENT SUMMARY"
call :log_message "================================================================"
echo.

if %DRY_RUN%==1 (
    echo   DRY RUN COMPLETE - No changes were made
    echo.
    echo   What would have happened:
    echo     - %FILES_COPIED% files would be copied
    echo     - Application would be deployed to %REMOTE_APP_DIR%
    echo     - Shiny Server would be restarted
    echo.
    goto :deployment_success
)

echo   Status:        SUCCESS
echo   Version:       %APP_VERSION%
echo   Files copied:  %FILES_COPIED%
if %FILES_FAILED% GTR 0 echo   Files failed:  %FILES_FAILED%
echo   Errors:        %ERROR_COUNT%
echo   Warnings:      %WARNING_COUNT%
echo.
echo   Access URL:    http://%REMOTE_HOST%:3838/%APP_NAME%/
echo.
echo   Useful commands:
echo     View logs:   ssh %SSH_TARGET% "sudo tail -f /var/log/shiny-server/*.log"
echo     Restart:     ssh %SSH_TARGET% "sudo systemctl restart shiny-server"
echo     Status:      ssh %SSH_TARGET% "sudo systemctl status shiny-server"
echo.
echo   Log file:      %LOG_FILE%
echo.

goto :deployment_success

REM =============================================================================
REM ERROR HANDLING
REM =============================================================================

:rollback
echo.
call :log_message "================================================================"
call :log_message "  ATTEMPTING ROLLBACK"
call :log_message "================================================================"
echo.

if %BACKUP_CREATED%==1 (
    call :log_action "Restoring from backup: %BACKUP_FILE%"
    "%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo rm -rf %REMOTE_APP_DIR%/* && sudo tar -xzf %BACKUP_FILE% -C /srv/shiny-server" 2>>"%LOG_FILE%"
    if %ERRORLEVEL% EQU 0 (
        call :log_success "Rollback successful"
        "%SSH_EXE%" -t -p %REMOTE_PORT% %SSH_TARGET% "sudo systemctl restart shiny-server" 2>>"%LOG_FILE%"
    ) else (
        call :log_error "Rollback failed - manual intervention required"
    )
) else (
    call :log_warning "No backup available for rollback"
)

REM Clean up staging if it exists
if defined STAGING_DIR (
    "%SSH_EXE%" -p %REMOTE_PORT% %SSH_TARGET% "rm -rf %STAGING_DIR%" 2>>"%LOG_FILE%"
)

goto :deployment_failed

:deployment_failed
echo.
call :log_message "================================================================"
echo   DEPLOYMENT FAILED
echo.
echo   Errors:   %ERROR_COUNT%
echo   Warnings: %WARNING_COUNT%
echo.
echo   Check the log file for details:
echo   %LOG_FILE%
call :log_message "================================================================"
echo.

REM Log final status
echo. >> "%LOG_FILE%"
echo ================================================================ >> "%LOG_FILE%"
echo DEPLOYMENT FAILED >> "%LOG_FILE%"
echo Ended: %DATE% %TIME% >> "%LOG_FILE%"
echo Errors: %ERROR_COUNT%, Warnings: %WARNING_COUNT% >> "%LOG_FILE%"
echo ================================================================ >> "%LOG_FILE%"

endlocal
exit /b 1

:deployment_success
call :log_message "================================================================"

REM Log final status
echo. >> "%LOG_FILE%"
echo ================================================================ >> "%LOG_FILE%"
echo DEPLOYMENT SUCCESSFUL >> "%LOG_FILE%"
echo Ended: %DATE% %TIME% >> "%LOG_FILE%"
echo Files: %FILES_COPIED%, Errors: %ERROR_COUNT%, Warnings: %WARNING_COUNT% >> "%LOG_FILE%"
echo ================================================================ >> "%LOG_FILE%"

endlocal
exit /b 0
