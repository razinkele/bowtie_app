#!/bin/bash
# =============================================================================
# Environmental Bowtie Risk Analysis - Direct Shiny Server Deployment
# Version: 5.4.0 (Stability & Infrastructure Edition)
#
# DEPLOYMENT SCRIPT - Supports both fresh install and updates
#
# This script performs a complete deployment to an existing Shiny Server:
#   1. Pre-flight checks (R, Shiny Server, files, permissions)
#   2. Version detection and comparison
#   3. Automatic backup of existing installation
#   4. R package dependency installation (skippable with --quick)
#   5. Application file deployment
#   6. Permission configuration
#   7. Service restart
#   8. Deployment verification
#
# Usage:
#   sudo ./deploy_to_shiny_server.sh                    # Full deployment
#   sudo ./deploy_to_shiny_server.sh --quick            # Quick update (skip dependencies)
#   sudo ./deploy_to_shiny_server.sh --skip-backup      # Skip backup (faster but riskier)
#   sudo ./deploy_to_shiny_server.sh --quick --skip-backup  # Fastest update
#   sudo ./deploy_to_shiny_server.sh --force            # Force full reinstall
# =============================================================================

set -e  # Exit on any error

# Parse command line arguments
QUICK_MODE=false
FORCE_MODE=false
SKIP_BACKUP=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --force)
            FORCE_MODE=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--quick] [--force] [--skip-backup]"
            exit 1
            ;;
    esac
done

# =============================================================================
# CONFIGURATION (hardcoded for simplicity)
# =============================================================================

APP_NAME="bowtie_app"
APP_VERSION="5.4.0"
SHINY_SERVER_DIR="/srv/shiny-server"
APP_DEST_DIR="${SHINY_SERVER_DIR}/${APP_NAME}"
LOG_DIR="/var/log/shiny-server/${APP_NAME}"
BACKUP_DIR="/var/backups/shiny-apps"

# Get script directory (deployment folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Application source directory (parent of deployment)
APP_SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Critical files that MUST exist for deployment
CRITICAL_R_FILES=(
    "app.R"
    "global.R"
    "ui.R"
    "server.R"
    "config.R"
)

# Important files (should exist but not critical)
IMPORTANT_R_FILES=(
    "start_app.R"
    "requirements.R"
    "guided_workflow.R"
    "bowtie_bayesian_network.R"
    "utils.R"
    "vocabulary.R"
    "vocabulary_bowtie_generator.R"
    "translations_data.R"
    "environmental_scenarios.R"
)

REQUIRED_DATA_FILES=(
    "CAUSES.xlsx"
    "CONSEQUENCES.xlsx"
    "CONTROLS.xlsx"
)

# Files to exclude from deployment (development/backup files)
EXCLUDE_PATTERNS=(
    "*-Dell-PCn.R"
    "*-laguna-safeBackup-*.R"
    "dev_config.R"
    "install_hooks.R"
    "compile_french_manual.R"
    "compile_manual.R"
    "check_version.R"
    "ui_header_extract.R"
    "ui_translations_helper.R"
)

# Version detection function
get_app_version() {
    local app_dir="$1"
    if [ -f "${app_dir}/VERSION_HISTORY.md" ]; then
        grep -m 1 "^## Version" "${app_dir}/VERSION_HISTORY.md" | grep -oP 'Version \K[0-9.]+' || echo "unknown"
    elif [ -f "${app_dir}/CLAUDE.md" ]; then
        grep -m 1 "**Version**:" "${app_dir}/CLAUDE.md" | grep -oP '\*\*Version\*\*: \K[0-9.]+' || echo "unknown"
    else
        echo "unknown"
    fi
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Counters for summary
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}${BOLD}► $1${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────${NC}"
}

log_check() {
    echo -e "  ${BLUE}[CHECK]${NC} $1"
}

log_pass() {
    echo -e "  ${GREEN}[PASS]${NC} $1"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

log_fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
}

log_warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

log_info() {
    echo -e "  ${BLUE}[INFO]${NC} $1"
}

log_action() {
    echo -e "  ${CYAN}[....]${NC} $1"
}

log_done() {
    echo -e "  ${GREEN}[DONE]${NC} $1"
}

# =============================================================================
# PRE-FLIGHT CHECKS
# =============================================================================

preflight_checks() {
    print_header "PRE-FLIGHT CHECKS"

    # -------------------------------------------------------------------------
    print_section "1. System Requirements"
    # -------------------------------------------------------------------------

    # Check if running as root
    log_check "Checking root privileges..."
    if [ "$EUID" -eq 0 ]; then
        log_pass "Running as root"
    else
        log_fail "Not running as root - please use: sudo $0"
        echo ""
        echo -e "${RED}${BOLD}DEPLOYMENT ABORTED: Root privileges required${NC}"
        exit 1
    fi

    # Check R installation
    log_check "Checking R installation..."
    if command -v R &> /dev/null; then
        R_VERSION=$(R --version 2>/dev/null | head -n1 | grep -oP 'R version \K[0-9.]+' || echo "unknown")
        log_pass "R version ${R_VERSION} installed"

        # Check R version (minimum 4.0.0)
        if [ "$R_VERSION" != "unknown" ]; then
            R_MAJOR=$(echo "$R_VERSION" | cut -d. -f1)
            if [ "$R_MAJOR" -ge 4 ] 2>/dev/null; then
                log_pass "R version is 4.x or higher (recommended)"
            else
                log_warn "R version is below 4.0 - consider upgrading"
            fi
        fi
    else
        log_fail "R is not installed"
        echo ""
        echo -e "${RED}${BOLD}DEPLOYMENT ABORTED: R is required${NC}"
        exit 1
    fi

    # Check Shiny Server installation
    log_check "Checking Shiny Server installation..."
    if command -v shiny-server &> /dev/null; then
        SHINY_VERSION=$(shiny-server --version 2>/dev/null || echo "unknown")
        log_pass "Shiny Server installed: ${SHINY_VERSION}"
    else
        log_fail "Shiny Server is not installed"
        echo ""
        echo -e "${RED}${BOLD}DEPLOYMENT ABORTED: Shiny Server is required${NC}"
        echo -e "Install from: ${BLUE}https://posit.co/download/shiny-server/${NC}"
        exit 1
    fi

    # Check Shiny Server is running
    log_check "Checking Shiny Server service..."
    if systemctl is-active --quiet shiny-server 2>/dev/null; then
        log_pass "Shiny Server service is running"
    else
        log_warn "Shiny Server service is not running (will start after deployment)"
    fi

    # Check shiny user exists
    log_check "Checking shiny user..."
    if id "shiny" &>/dev/null; then
        log_pass "User 'shiny' exists"
    else
        log_fail "User 'shiny' does not exist"
        echo ""
        echo -e "${RED}${BOLD}DEPLOYMENT ABORTED: shiny user required${NC}"
        exit 1
    fi

    # Check destination directory
    log_check "Checking Shiny Server directory..."
    if [ -d "${SHINY_SERVER_DIR}" ]; then
        log_pass "Shiny Server directory exists: ${SHINY_SERVER_DIR}"
    else
        log_fail "Shiny Server directory not found: ${SHINY_SERVER_DIR}"
        exit 1
    fi

    # -------------------------------------------------------------------------
    print_section "2. Version Detection"
    # -------------------------------------------------------------------------

    # Detect source version
    SOURCE_VERSION=$(get_app_version "${APP_SOURCE_DIR}")
    log_info "Source version: ${SOURCE_VERSION}"

    # Detect deployed version (if exists)
    if [ -d "${APP_DEST_DIR}" ]; then
        DEPLOYED_VERSION=$(get_app_version "${APP_DEST_DIR}")
        log_info "Deployed version: ${DEPLOYED_VERSION}"

        if [ "$DEPLOYED_VERSION" != "unknown" ] && [ "$SOURCE_VERSION" != "unknown" ]; then
            if [ "$SOURCE_VERSION" = "$DEPLOYED_VERSION" ]; then
                log_warn "Same version already deployed"
                if [ "$FORCE_MODE" = false ]; then
                    log_info "Use --force to redeploy same version"
                fi
            else
                log_pass "Version will be updated: ${DEPLOYED_VERSION} → ${SOURCE_VERSION}"
            fi
        fi

        # Count files to show what will change
        SOURCE_R_COUNT=$(find "${APP_SOURCE_DIR}" -maxdepth 1 -name "*.R" -type f | wc -l)
        DEPLOYED_R_COUNT=$(find "${APP_DEST_DIR}" -maxdepth 1 -name "*.R" -type f 2>/dev/null | wc -l)
        log_info "R files: deployed=${DEPLOYED_R_COUNT}, source=${SOURCE_R_COUNT}"
    else
        log_info "Fresh installation (no existing deployment)"
    fi

    # -------------------------------------------------------------------------
    print_section "3. Source Files Validation"
    # -------------------------------------------------------------------------

    log_check "Checking source directory: ${APP_SOURCE_DIR}"
    if [ -d "${APP_SOURCE_DIR}" ]; then
        log_pass "Source directory exists"
    else
        log_fail "Source directory not found"
        exit 1
    fi

    # Check critical R files (must exist)
    log_check "Checking critical R files..."
    MISSING_CRITICAL_FILES=()
    for file in "${CRITICAL_R_FILES[@]}"; do
        if [ ! -f "${APP_SOURCE_DIR}/${file}" ]; then
            MISSING_CRITICAL_FILES+=("${file}")
        fi
    done

    if [ ${#MISSING_CRITICAL_FILES[@]} -eq 0 ]; then
        log_pass "All ${#CRITICAL_R_FILES[@]} critical R files present"
    else
        log_fail "Missing critical files: ${MISSING_CRITICAL_FILES[*]}"
        exit 1
    fi

    # Check important R files (should exist)
    log_check "Checking important R files..."
    MISSING_IMPORTANT_FILES=()
    FOUND_IMPORTANT=0
    for file in "${IMPORTANT_R_FILES[@]}"; do
        if [ ! -f "${APP_SOURCE_DIR}/${file}" ]; then
            MISSING_IMPORTANT_FILES+=("${file}")
        else
            FOUND_IMPORTANT=$((FOUND_IMPORTANT + 1))
        fi
    done

    if [ ${#MISSING_IMPORTANT_FILES[@]} -eq 0 ]; then
        log_pass "All ${#IMPORTANT_R_FILES[@]} important R files present"
    else
        log_warn "Missing ${#MISSING_IMPORTANT_FILES[@]} optional files: ${MISSING_IMPORTANT_FILES[*]}"
        log_info "Found ${FOUND_IMPORTANT}/${#IMPORTANT_R_FILES[@]} important files"
    fi

    # Check required data files
    log_check "Checking required data files..."
    MISSING_DATA_FILES=()
    for file in "${REQUIRED_DATA_FILES[@]}"; do
        if [ ! -f "${APP_SOURCE_DIR}/${file}" ]; then
            MISSING_DATA_FILES+=("${file}")
        fi
    done

    if [ ${#MISSING_DATA_FILES[@]} -eq 0 ]; then
        log_pass "All ${#REQUIRED_DATA_FILES[@]} required data files present"
    else
        log_fail "Missing data files: ${MISSING_DATA_FILES[*]}"
        exit 1
    fi

    # Check www directory
    log_check "Checking www directory..."
    if [ -d "${APP_SOURCE_DIR}/www" ]; then
        log_pass "www directory exists"
    else
        log_warn "www directory not found (optional)"
    fi

    # Check data directory
    log_check "Checking data directory..."
    if [ -d "${APP_SOURCE_DIR}/data" ]; then
        log_pass "data directory exists"
    else
        log_warn "data directory not found (will be created)"
    fi

    # -------------------------------------------------------------------------
    print_section "4. R Syntax Validation"
    # -------------------------------------------------------------------------

    log_check "Validating R file syntax..."
    SYNTAX_ERRORS=0
    SYNTAX_CHECKED=0

    # Check critical and important files
    for file in "${CRITICAL_R_FILES[@]}" "${IMPORTANT_R_FILES[@]}"; do
        if [ -f "${APP_SOURCE_DIR}/${file}" ]; then
            SYNTAX_CHECKED=$((SYNTAX_CHECKED + 1))
            if Rscript --vanilla -e "parse('${APP_SOURCE_DIR}/${file}')" &>/dev/null; then
                : # Syntax OK
            else
                log_fail "Syntax error in ${file}"
                SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
            fi
        fi
    done

    if [ $SYNTAX_ERRORS -eq 0 ]; then
        log_pass "All ${SYNTAX_CHECKED} R files have valid syntax"
    else
        log_fail "${SYNTAX_ERRORS} files have syntax errors"
        exit 1
    fi

    # -------------------------------------------------------------------------
    print_section "5. Disk Space Check"
    # -------------------------------------------------------------------------

    log_check "Checking available disk space..."
    AVAILABLE_SPACE=$(df -BM "${SHINY_SERVER_DIR}" | tail -1 | awk '{print $4}' | sed 's/M//')
    if [ "$AVAILABLE_SPACE" -gt 500 ]; then
        log_pass "Sufficient disk space available: ${AVAILABLE_SPACE}MB"
    elif [ "$AVAILABLE_SPACE" -gt 100 ]; then
        log_warn "Low disk space: ${AVAILABLE_SPACE}MB (recommended: 500MB+)"
    else
        log_fail "Insufficient disk space: ${AVAILABLE_SPACE}MB"
        exit 1
    fi

    # -------------------------------------------------------------------------
    print_section "Pre-flight Summary"
    # -------------------------------------------------------------------------

    echo ""
    echo -e "  Checks passed: ${GREEN}${CHECKS_PASSED}${NC}"
    echo -e "  Checks failed: ${RED}${CHECKS_FAILED}${NC}"
    echo -e "  Warnings:      ${YELLOW}${WARNINGS}${NC}"
    echo ""

    if [ $CHECKS_FAILED -gt 0 ]; then
        echo -e "${RED}${BOLD}PRE-FLIGHT CHECKS FAILED - DEPLOYMENT ABORTED${NC}"
        exit 1
    fi

    echo -e "${GREEN}${BOLD}All pre-flight checks passed!${NC}"
}

# =============================================================================
# BACKUP
# =============================================================================

create_backup() {
    print_header "CREATING BACKUP"

    if [ "$SKIP_BACKUP" = true ]; then
        log_warn "Backup skipped (--skip-backup flag used)"
        log_info "No backup will be created - deployment will be faster but riskier"
        return 0
    fi

    if [ -d "${APP_DEST_DIR}" ]; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="${BACKUP_DIR}/${APP_NAME}_${TIMESTAMP}.tar.gz"

        log_action "Creating backup directory..."
        mkdir -p "${BACKUP_DIR}"

        # Get directory size and file count for progress info
        log_action "Analyzing existing installation..."
        DIR_SIZE_BYTES=$(du -sb "${APP_DEST_DIR}" 2>/dev/null | cut -f1 || echo "0")
        DIR_SIZE_HUMAN=$(du -sh "${APP_DEST_DIR}" 2>/dev/null | cut -f1 || echo "unknown")
        FILE_COUNT=$(find "${APP_DEST_DIR}" -type f 2>/dev/null | wc -l || echo "unknown")
        log_info "Directory size: ${DIR_SIZE_HUMAN}, Files: ${FILE_COUNT}"

        echo ""
        log_action "Creating backup archive with progress..."

        # Create backup with pv progress bar
        if command -v pv &> /dev/null; then
            # Use pv for beautiful progress bar with ETA and transfer rate
            echo -e "  ${BLUE}[INFO]${NC} Using pv (pipe viewer) for progress display"
            echo ""
            tar -cf - -C "${SHINY_SERVER_DIR}" "${APP_NAME}" 2>/dev/null | \
                pv -p -t -e -r -b -s "${DIR_SIZE_BYTES}" -N "  Backup" | \
                gzip > "${BACKUP_FILE}"
            BACKUP_RESULT=$?
            echo ""
        else
            # Fallback: tar with spinner (user shouldn't see this since pv is installed)
            log_warn "pv not found - using fallback spinner"
            (
                tar -czf "${BACKUP_FILE}" -C "${SHINY_SERVER_DIR}" "${APP_NAME}" 2>&1 &
                TAR_PID=$!

                # Show spinner while backing up
                spin='-\|/'
                i=0
                while kill -0 $TAR_PID 2>/dev/null; do
                    i=$(( (i+1) %4 ))
                    printf "\r  ${CYAN}[${spin:$i:1}]${NC} Creating backup archive..."
                    sleep 0.1
                done
                printf "\r"
                wait $TAR_PID
            )
            BACKUP_RESULT=$?
        fi

        if [ $BACKUP_RESULT -eq 0 ]; then
            log_done "Backup created: ${BACKUP_FILE}"
            BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
            log_info "Backup size: ${BACKUP_SIZE}"
        else
            log_warn "Backup failed - continuing anyway"
        fi
    else
        log_info "No existing installation found - skipping backup"
    fi
}

# =============================================================================
# INSTALL DEPENDENCIES
# =============================================================================

install_dependencies() {
    print_header "INSTALLING R DEPENDENCIES"

    if [ "$QUICK_MODE" = true ]; then
        log_info "Quick mode: Skipping dependency installation"
        log_warn "Make sure all R packages are up to date"
        return 0
    fi

    if [ ! -f "${APP_SOURCE_DIR}/requirements.R" ]; then
        log_fail "requirements.R not found"
        exit 1
    fi

    log_action "Installing R packages (this may take several minutes)..."

    # Try to install as shiny user first (preferred)
    if su - shiny -c "cd '${APP_SOURCE_DIR}' && Rscript requirements.R" 2>/dev/null; then
        log_done "Dependencies installed as shiny user"
    else
        log_warn "Failed as shiny user, trying as root..."
        if Rscript "${APP_SOURCE_DIR}/requirements.R"; then
            log_done "Dependencies installed as root"
        else
            log_fail "Failed to install dependencies"
            exit 1
        fi
    fi
}

# =============================================================================
# DEPLOY APPLICATION
# =============================================================================

deploy_application() {
    print_header "DEPLOYING APPLICATION"

    # Create destination directory
    log_action "Creating destination directory..."
    mkdir -p "${APP_DEST_DIR}"
    log_done "Directory created: ${APP_DEST_DIR}"

    # Helper function to check if file should be excluded
    should_exclude() {
        local file="$1"
        local basename=$(basename "$file")
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$basename" == $pattern ]]; then
                return 0  # Should exclude
            fi
        done
        return 1  # Should include
    }

    # Copy all R files (excluding development files)
    log_action "Copying R application files..."
    R_FILES_COPIED=0
    R_FILES_EXCLUDED=0
    for rfile in "${APP_SOURCE_DIR}"/*.R; do
        if [ -f "$rfile" ]; then
            if should_exclude "$rfile"; then
                R_FILES_EXCLUDED=$((R_FILES_EXCLUDED + 1))
            else
                cp -f "$rfile" "${APP_DEST_DIR}/"
                R_FILES_COPIED=$((R_FILES_COPIED + 1))
            fi
        fi
    done
    log_done "R files copied: ${R_FILES_COPIED} (excluded ${R_FILES_EXCLUDED} dev files)"

    # Copy data files
    log_action "Copying data files..."
    for file in "${REQUIRED_DATA_FILES[@]}"; do
        if [ -f "${APP_SOURCE_DIR}/${file}" ]; then
            cp -f "${APP_SOURCE_DIR}/${file}" "${APP_DEST_DIR}/"
        fi
    done
    cp -f "${APP_SOURCE_DIR}"/*.xlsx "${APP_DEST_DIR}/" 2>/dev/null || true
    log_done "Data files copied"

    # Copy www directory
    if [ -d "${APP_SOURCE_DIR}/www" ]; then
        log_action "Copying www directory..."
        cp -rf "${APP_SOURCE_DIR}/www" "${APP_DEST_DIR}/"
        log_done "www directory copied"
    fi

    # Copy data directory
    if [ -d "${APP_SOURCE_DIR}/data" ]; then
        log_action "Copying data directory..."
        cp -rf "${APP_SOURCE_DIR}/data" "${APP_DEST_DIR}/"
        log_done "data directory copied"
    fi

    # Copy config directory
    if [ -d "${APP_SOURCE_DIR}/config" ]; then
        log_action "Copying config directory..."
        cp -rf "${APP_SOURCE_DIR}/config" "${APP_DEST_DIR}/"
        log_done "config directory copied"
    else
        log_warn "config directory not found (application may not start)"
    fi

    # Copy helpers directory
    if [ -d "${APP_SOURCE_DIR}/helpers" ]; then
        log_action "Copying helpers directory..."
        cp -rf "${APP_SOURCE_DIR}/helpers" "${APP_DEST_DIR}/"
        log_done "helpers directory copied"
    else
        log_warn "helpers directory not found (application may not start)"
    fi

    # Copy server_modules directory
    if [ -d "${APP_SOURCE_DIR}/server_modules" ]; then
        log_action "Copying server_modules directory..."
        cp -rf "${APP_SOURCE_DIR}/server_modules" "${APP_DEST_DIR}/"
        log_done "server_modules directory copied"
    else
        log_warn "server_modules directory not found (application may not start)"
    fi

    # Copy documentation
    log_action "Copying documentation..."
    cp -f "${APP_SOURCE_DIR}/README.md" "${APP_DEST_DIR}/" 2>/dev/null || true
    cp -f "${APP_SOURCE_DIR}/CLAUDE.md" "${APP_DEST_DIR}/" 2>/dev/null || true
    log_done "Documentation copied"

    # Create necessary directories
    log_action "Creating runtime directories..."
    mkdir -p "${APP_DEST_DIR}/data"
    mkdir -p "${APP_DEST_DIR}/logs"
    mkdir -p "${LOG_DIR}"
    log_done "Runtime directories created"
}

# =============================================================================
# SET PERMISSIONS
# =============================================================================

set_permissions() {
    print_header "SETTING PERMISSIONS"

    log_action "Setting ownership to shiny user..."
    chown -R shiny:shiny "${APP_DEST_DIR}"
    chown -R shiny:shiny "${LOG_DIR}" 2>/dev/null || true
    log_done "Ownership set"

    log_action "Setting directory permissions..."
    find "${APP_DEST_DIR}" -type d -exec chmod 755 {} \;
    log_done "Directory permissions set (755)"

    log_action "Setting file permissions..."
    find "${APP_DEST_DIR}" -type f -exec chmod 644 {} \;
    log_done "File permissions set (644)"

    log_action "Making data directories writable..."
    chmod 775 "${APP_DEST_DIR}/data" 2>/dev/null || true
    chmod 775 "${APP_DEST_DIR}/logs" 2>/dev/null || true
    chmod 775 "${LOG_DIR}" 2>/dev/null || true
    log_done "Data directories are writable"
}

# =============================================================================
# RESTART SERVICE
# =============================================================================

restart_service() {
    print_header "RESTARTING SHINY SERVER"

    log_action "Restarting shiny-server service..."
    if systemctl restart shiny-server; then
        log_done "Service restart command sent"
    else
        log_fail "Failed to restart service"
        exit 1
    fi

    log_action "Waiting for service to start..."
    sleep 5

    if systemctl is-active --quiet shiny-server; then
        log_done "Shiny Server is running"
    else
        log_fail "Shiny Server failed to start"
        log_info "Check logs: journalctl -u shiny-server -n 50"
        exit 1
    fi
}

# =============================================================================
# VERIFY DEPLOYMENT
# =============================================================================

verify_deployment() {
    print_header "VERIFYING DEPLOYMENT"

    # Check if service is running
    log_check "Service status..."
    if systemctl is-active --quiet shiny-server; then
        log_pass "Shiny Server is active"
    else
        log_fail "Shiny Server is not running"
    fi

    # Check if port is listening
    log_check "Port 3838..."
    sleep 2
    if ss -tuln 2>/dev/null | grep -q ":3838" || netstat -tuln 2>/dev/null | grep -q ":3838"; then
        log_pass "Port 3838 is listening"
    else
        log_warn "Port 3838 may not be listening yet"
    fi

    # Check HTTP response
    log_check "HTTP response..."
    if command -v curl &> /dev/null; then
        sleep 3
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3838/${APP_NAME}/" --max-time 10 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
            log_pass "Application responding (HTTP ${HTTP_CODE})"
        elif [ "$HTTP_CODE" = "000" ]; then
            log_warn "Could not connect - app may still be initializing"
        else
            log_warn "Unexpected HTTP response: ${HTTP_CODE}"
        fi
    else
        log_warn "curl not installed - skipping HTTP check"
    fi

    # Check deployed files
    log_check "Deployed files..."
    DEPLOYED_COUNT=$(find "${APP_DEST_DIR}" -name "*.R" -type f | wc -l)
    log_pass "${DEPLOYED_COUNT} R files deployed"
}

# =============================================================================
# SHOW SUMMARY
# =============================================================================

show_summary() {
    print_header "DEPLOYMENT COMPLETE"

    # Get IP address
    IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")

    # Get final deployed version
    FINAL_VERSION=$(get_app_version "${APP_DEST_DIR}")

    echo ""
    echo -e "  ${GREEN}${BOLD}SUCCESS!${NC} Application deployed successfully."
    echo ""
    echo -e "  ${BOLD}Application Details:${NC}"
    echo -e "    Name:      ${APP_NAME}"
    echo -e "    Version:   ${FINAL_VERSION}"
    echo -e "    Location:  ${APP_DEST_DIR}"
    echo -e "    Logs:      ${LOG_DIR}"

    # Show R file count
    FINAL_R_COUNT=$(find "${APP_DEST_DIR}" -maxdepth 1 -name "*.R" -type f 2>/dev/null | wc -l)
    echo -e "    R Files:   ${FINAL_R_COUNT}"
    echo ""
    echo -e "  ${BOLD}Access URLs:${NC}"
    echo -e "    Local:     ${CYAN}http://localhost:3838/${APP_NAME}/${NC}"
    echo -e "    Network:   ${CYAN}http://${IP_ADDR}:3838/${APP_NAME}/${NC}"
    echo ""
    echo -e "  ${BOLD}Useful Commands:${NC}"
    echo -e "    View logs:      ${BLUE}tail -f ${LOG_DIR}/*.log${NC}"
    echo -e "    Restart:        ${BLUE}sudo systemctl restart shiny-server${NC}"
    echo -e "    Status:         ${BLUE}sudo systemctl status shiny-server${NC}"
    echo -e "    System logs:    ${BLUE}journalctl -u shiny-server -f${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    clear

    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║   Environmental Bowtie Risk Analysis                          ║"
    echo "║   Direct Shiny Server Deployment                              ║"
    echo "║                                                               ║"
    echo "║   Version: ${APP_VERSION}                                            ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "Source:      ${APP_SOURCE_DIR}"
    echo -e "Destination: ${APP_DEST_DIR}"
    echo -e "Started:     $(date '+%Y-%m-%d %H:%M:%S')"

    # Show deployment mode
    if [ "$QUICK_MODE" = true ]; then
        echo -e "Mode:        ${YELLOW}Quick Update (skip dependencies)${NC}"
    elif [ "$FORCE_MODE" = true ]; then
        echo -e "Mode:        ${YELLOW}Force Reinstall${NC}"
    else
        echo -e "Mode:        ${GREEN}Full Deployment${NC}"
    fi
    echo ""

    # Run deployment steps
    preflight_checks
    create_backup
    install_dependencies
    deploy_application
    set_permissions
    restart_service
    verify_deployment
    show_summary

    exit 0
}

# Run main function
main
