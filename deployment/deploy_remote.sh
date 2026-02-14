#!/bin/bash
# =============================================================================
# Environmental Bowtie Risk Analysis - Remote Deployment to laguna.ku.lt
# Version: 5.4.0
#
# Deploys the application remotely via SSH/rsync to the Shiny Server
#
# Usage:
#   ./deploy_remote.sh                    # Full deployment
#   ./deploy_remote.sh --quick            # Quick update (skip R packages)
#   ./deploy_remote.sh --dry-run          # Show what would be transferred
#   ./deploy_remote.sh --skip-backup      # Skip backup on remote server
#
# Requirements:
#   - SSH key authentication configured for laguna.ku.lt
#   - rsync installed locally
#   - sudo access on remote server
# =============================================================================

set -e  # Exit on error

# =============================================================================
# CONFIGURATION
# =============================================================================

# Remote server settings
REMOTE_HOST="laguna.ku.lt"
REMOTE_USER="razinka"
REMOTE_PORT="22"

# Application settings
APP_NAME="bowtie_app"
APP_VERSION="5.4.0"
REMOTE_APP_DIR="/srv/shiny-server/${APP_NAME}"
REMOTE_BACKUP_DIR="/var/backups/shiny-apps"
REMOTE_LOG_DIR="/var/log/shiny-server/${APP_NAME}"

# Local paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# SSH connection string
SSH_CMD="ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}"
SCP_CMD="scp -P ${REMOTE_PORT}"
RSYNC_CMD="rsync -avz --progress -e 'ssh -p ${REMOTE_PORT}'"

# Parse command line arguments
QUICK_MODE=false
DRY_RUN=false
SKIP_BACKUP=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --quick        Skip R package installation on remote"
            echo "  --dry-run      Show what would be transferred without doing it"
            echo "  --skip-backup  Skip backup creation on remote server"
            echo "  --verbose, -v  Show detailed output"
            echo "  --help, -h     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

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

log_info() {
    echo -e "  ${BLUE}[INFO]${NC} $1"
}

log_pass() {
    echo -e "  ${GREEN}[PASS]${NC} $1"
}

log_fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
}

log_warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
}

log_action() {
    echo -e "  ${CYAN}[....]${NC} $1"
}

log_done() {
    echo -e "  ${GREEN}[DONE]${NC} $1"
}

# Remote command execution with sudo
remote_exec() {
    $SSH_CMD "sudo $1"
}

# Remote command execution without sudo
remote_exec_user() {
    $SSH_CMD "$1"
}

# =============================================================================
# PRE-FLIGHT CHECKS
# =============================================================================

preflight_checks() {
    print_header "PRE-FLIGHT CHECKS"

    print_section "1. Local Environment"

    # Check rsync
    log_action "Checking rsync..."
    if command -v rsync &> /dev/null; then
        log_pass "rsync is installed"
    else
        log_fail "rsync is not installed"
        echo "  Install with: sudo apt install rsync (Linux) or brew install rsync (Mac)"
        exit 1
    fi

    # Check SSH
    log_action "Checking SSH..."
    if command -v ssh &> /dev/null; then
        log_pass "SSH is installed"
    else
        log_fail "SSH is not installed"
        exit 1
    fi

    # Check source directory
    log_action "Checking source directory..."
    if [ -d "${APP_SOURCE_DIR}" ]; then
        log_pass "Source directory exists: ${APP_SOURCE_DIR}"
    else
        log_fail "Source directory not found"
        exit 1
    fi

    # Check critical files exist
    log_action "Checking critical files..."
    CRITICAL_FILES=("app.R" "global.R" "ui.R" "server.R" "config.R")
    MISSING=()
    for file in "${CRITICAL_FILES[@]}"; do
        if [ ! -f "${APP_SOURCE_DIR}/${file}" ]; then
            MISSING+=("$file")
        fi
    done

    if [ ${#MISSING[@]} -eq 0 ]; then
        log_pass "All critical files present"
    else
        log_fail "Missing critical files: ${MISSING[*]}"
        exit 1
    fi

    print_section "2. Remote Server Connectivity"

    # Test SSH connection
    log_action "Testing SSH connection to ${REMOTE_HOST}..."
    if $SSH_CMD "echo 'SSH connection successful'" &> /dev/null; then
        log_pass "SSH connection successful"
    else
        log_fail "Cannot connect to ${REMOTE_HOST}"
        echo ""
        echo "  Make sure:"
        echo "    1. SSH key is configured: ssh-copy-id ${REMOTE_USER}@${REMOTE_HOST}"
        echo "    2. Server is reachable: ping ${REMOTE_HOST}"
        echo "    3. SSH port ${REMOTE_PORT} is open"
        exit 1
    fi

    # Check sudo access
    log_action "Checking sudo access..."
    if $SSH_CMD "sudo -n true" &> /dev/null; then
        log_pass "Passwordless sudo available"
    else
        log_warn "Sudo may require password (will prompt during deployment)"
    fi

    # Check Shiny Server on remote
    log_action "Checking Shiny Server on remote..."
    if $SSH_CMD "command -v shiny-server" &> /dev/null; then
        REMOTE_SHINY_VERSION=$($SSH_CMD "shiny-server --version 2>/dev/null || echo 'unknown'")
        log_pass "Shiny Server installed: ${REMOTE_SHINY_VERSION}"
    else
        log_fail "Shiny Server not found on remote"
        exit 1
    fi

    # Check if Shiny Server is running
    log_action "Checking Shiny Server status..."
    if $SSH_CMD "sudo systemctl is-active --quiet shiny-server"; then
        log_pass "Shiny Server is running"
    else
        log_warn "Shiny Server is not running (will start after deployment)"
    fi

    # Check R on remote
    log_action "Checking R on remote..."
    if $SSH_CMD "command -v R" &> /dev/null; then
        REMOTE_R_VERSION=$($SSH_CMD "R --version 2>/dev/null | head -n1 | grep -oP 'R version \\K[0-9.]+' || echo 'unknown'")
        log_pass "R version ${REMOTE_R_VERSION} installed"
    else
        log_fail "R not found on remote"
        exit 1
    fi

    # Check existing deployment
    log_action "Checking existing deployment..."
    if $SSH_CMD "[ -d ${REMOTE_APP_DIR} ]" 2>/dev/null; then
        REMOTE_FILE_COUNT=$($SSH_CMD "find ${REMOTE_APP_DIR} -name '*.R' -type f 2>/dev/null | wc -l")
        log_info "Existing deployment found: ${REMOTE_FILE_COUNT} R files"
    else
        log_info "Fresh installation (no existing deployment)"
    fi

    echo ""
    log_pass "All pre-flight checks passed!"
}

# =============================================================================
# CREATE REMOTE BACKUP
# =============================================================================

create_remote_backup() {
    print_header "CREATING REMOTE BACKUP"

    if [ "$SKIP_BACKUP" = true ]; then
        log_warn "Backup skipped (--skip-backup flag)"
        return 0
    fi

    if $SSH_CMD "[ -d ${REMOTE_APP_DIR} ]" 2>/dev/null; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="${REMOTE_BACKUP_DIR}/${APP_NAME}_${TIMESTAMP}.tar.gz"

        log_action "Creating backup directory on remote..."
        remote_exec "mkdir -p ${REMOTE_BACKUP_DIR}"

        log_action "Creating backup: ${BACKUP_FILE}..."
        if remote_exec "tar -czf ${BACKUP_FILE} -C /srv/shiny-server ${APP_NAME} 2>/dev/null"; then
            BACKUP_SIZE=$(remote_exec "du -h ${BACKUP_FILE} | cut -f1")
            log_done "Backup created: ${BACKUP_SIZE}"
        else
            log_warn "Backup failed - continuing anyway"
        fi
    else
        log_info "No existing installation - skipping backup"
    fi
}

# =============================================================================
# SYNC FILES TO REMOTE
# =============================================================================

sync_files() {
    print_header "SYNCING FILES TO REMOTE"

    # Create a temporary staging directory on remote
    STAGING_DIR="/tmp/${APP_NAME}_deploy_$$"

    log_action "Creating staging directory on remote..."
    remote_exec_user "mkdir -p ${STAGING_DIR}"

    # Build rsync exclude list
    EXCLUDE_OPTS=""
    EXCLUDE_PATTERNS=(
        "*-Dell-PCn.R"
        "*-Dell-PCn.md"
        "*-laguna-safeBackup-*"
        "dev_config.R"
        "install_hooks.R"
        "compile_french_manual.R"
        "compile_manual.R"
        "check_version.R"
        "ui_header_extract.R"
        "ui_translations_helper.R"
        ".git"
        ".github"
        ".Rhistory"
        ".RData"
        "*.Rproj"
        "__pycache__"
        "archive/"
        "tests/"
        "docs/"
        "deployment/"
        "logs/"
        ".claude/"
        "*.log"
        "*.tmp"
        "node_modules/"
    )

    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        EXCLUDE_OPTS="${EXCLUDE_OPTS} --exclude='${pattern}'"
    done

    # Count local files for progress info
    LOCAL_R_COUNT=$(find "${APP_SOURCE_DIR}" -maxdepth 1 -name "*.R" -type f | wc -l)
    log_info "Preparing to sync ${LOCAL_R_COUNT} R files + data files"

    if [ "$DRY_RUN" = true ]; then
        log_warn "DRY RUN - showing what would be transferred:"
        eval "rsync -avzn --progress -e 'ssh -p ${REMOTE_PORT}' ${EXCLUDE_OPTS} \
            '${APP_SOURCE_DIR}/' '${REMOTE_USER}@${REMOTE_HOST}:${STAGING_DIR}/'"
        return 0
    fi

    log_action "Syncing application files..."
    eval "rsync -avz --progress -e 'ssh -p ${REMOTE_PORT}' ${EXCLUDE_OPTS} \
        '${APP_SOURCE_DIR}/' '${REMOTE_USER}@${REMOTE_HOST}:${STAGING_DIR}/'"

    log_done "Files synced to staging directory"

    # Move files to final location with sudo
    print_section "Installing to Shiny Server Directory"

    log_action "Creating application directory..."
    remote_exec "mkdir -p ${REMOTE_APP_DIR}"

    log_action "Copying files to ${REMOTE_APP_DIR}..."
    remote_exec "cp -rf ${STAGING_DIR}/* ${REMOTE_APP_DIR}/"

    log_action "Creating runtime directories..."
    remote_exec "mkdir -p ${REMOTE_APP_DIR}/data"
    remote_exec "mkdir -p ${REMOTE_APP_DIR}/logs"
    remote_exec "mkdir -p ${REMOTE_LOG_DIR}"

    log_action "Cleaning up staging directory..."
    remote_exec_user "rm -rf ${STAGING_DIR}"

    log_done "Files installed successfully"
}

# =============================================================================
# SET PERMISSIONS
# =============================================================================

set_permissions() {
    print_header "SETTING PERMISSIONS"

    log_action "Setting ownership to shiny user..."
    remote_exec "chown -R shiny:shiny ${REMOTE_APP_DIR}"
    remote_exec "chown -R shiny:shiny ${REMOTE_LOG_DIR} 2>/dev/null || true"

    log_action "Setting directory permissions (755)..."
    remote_exec "find ${REMOTE_APP_DIR} -type d -exec chmod 755 {} \\;"

    log_action "Setting file permissions (644)..."
    remote_exec "find ${REMOTE_APP_DIR} -type f -exec chmod 644 {} \\;"

    log_action "Making data directories writable (775)..."
    remote_exec "chmod 775 ${REMOTE_APP_DIR}/data 2>/dev/null || true"
    remote_exec "chmod 775 ${REMOTE_APP_DIR}/logs 2>/dev/null || true"

    log_done "Permissions configured"
}

# =============================================================================
# INSTALL R DEPENDENCIES
# =============================================================================

install_dependencies() {
    print_header "R DEPENDENCIES"

    if [ "$QUICK_MODE" = true ]; then
        log_info "Quick mode: Skipping R package installation"
        log_warn "Ensure packages are already installed on remote"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: Would install R dependencies"
        return 0
    fi

    log_action "Installing R packages on remote (this may take several minutes)..."

    # Run requirements.R on remote
    if remote_exec "cd ${REMOTE_APP_DIR} && Rscript requirements.R 2>&1"; then
        log_done "R packages installed"
    else
        log_warn "Some packages may have failed - check remote logs"
    fi
}

# =============================================================================
# RESTART SHINY SERVER
# =============================================================================

restart_service() {
    print_header "RESTARTING SHINY SERVER"

    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: Would restart shiny-server"
        return 0
    fi

    log_action "Restarting shiny-server..."
    if remote_exec "systemctl restart shiny-server"; then
        log_done "Restart command sent"
    else
        log_fail "Failed to restart service"
        exit 1
    fi

    log_action "Waiting for service to start..."
    sleep 5

    if remote_exec "systemctl is-active --quiet shiny-server"; then
        log_done "Shiny Server is running"
    else
        log_fail "Shiny Server failed to start"
        log_info "Check logs: ssh ${REMOTE_USER}@${REMOTE_HOST} 'sudo journalctl -u shiny-server -n 50'"
        exit 1
    fi
}

# =============================================================================
# VERIFY DEPLOYMENT
# =============================================================================

verify_deployment() {
    print_header "VERIFYING DEPLOYMENT"

    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: Would verify deployment"
        return 0
    fi

    # Check service
    log_action "Checking service status..."
    if remote_exec "systemctl is-active --quiet shiny-server"; then
        log_pass "Shiny Server is active"
    else
        log_fail "Shiny Server is not running"
    fi

    # Check port
    log_action "Checking port 3838..."
    if remote_exec "ss -tuln 2>/dev/null | grep -q ':3838' || netstat -tuln 2>/dev/null | grep -q ':3838'"; then
        log_pass "Port 3838 is listening"
    else
        log_warn "Port 3838 may not be listening yet"
    fi

    # Check HTTP response
    log_action "Checking HTTP response..."
    sleep 3
    HTTP_CODE=$(remote_exec "curl -s -o /dev/null -w '%{http_code}' 'http://localhost:3838/${APP_NAME}/' --max-time 10 2>/dev/null || echo '000'")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        log_pass "Application responding (HTTP ${HTTP_CODE})"
    elif [ "$HTTP_CODE" = "000" ]; then
        log_warn "Could not connect - app may still be initializing"
    else
        log_warn "HTTP response: ${HTTP_CODE}"
    fi

    # Count deployed files
    log_action "Counting deployed files..."
    DEPLOYED_COUNT=$(remote_exec "find ${REMOTE_APP_DIR} -name '*.R' -type f 2>/dev/null | wc -l")
    log_pass "${DEPLOYED_COUNT} R files deployed"
}

# =============================================================================
# SHOW SUMMARY
# =============================================================================

show_summary() {
    print_header "DEPLOYMENT COMPLETE"

    if [ "$DRY_RUN" = true ]; then
        echo ""
        echo -e "  ${YELLOW}${BOLD}DRY RUN COMPLETE${NC} - No changes were made"
        echo ""
        return 0
    fi

    echo ""
    echo -e "  ${GREEN}${BOLD}SUCCESS!${NC} Application deployed to ${REMOTE_HOST}"
    echo ""
    echo -e "  ${BOLD}Application Details:${NC}"
    echo -e "    Name:      ${APP_NAME}"
    echo -e "    Version:   ${APP_VERSION}"
    echo -e "    Server:    ${REMOTE_HOST}"
    echo -e "    Location:  ${REMOTE_APP_DIR}"
    echo ""
    echo -e "  ${BOLD}Access URLs:${NC}"
    echo -e "    Public:    ${CYAN}http://${REMOTE_HOST}:3838/${APP_NAME}/${NC}"
    echo -e "    Direct:    ${CYAN}http://laguna.ku.lt:3838/${APP_NAME}/${NC}"
    echo ""
    echo -e "  ${BOLD}Useful Commands:${NC}"
    echo -e "    SSH:        ${BLUE}ssh ${REMOTE_USER}@${REMOTE_HOST}${NC}"
    echo -e "    Logs:       ${BLUE}ssh ${REMOTE_USER}@${REMOTE_HOST} 'sudo tail -f ${REMOTE_LOG_DIR}/*.log'${NC}"
    echo -e "    Restart:    ${BLUE}ssh ${REMOTE_USER}@${REMOTE_HOST} 'sudo systemctl restart shiny-server'${NC}"
    echo -e "    Status:     ${BLUE}ssh ${REMOTE_USER}@${REMOTE_HOST} 'sudo systemctl status shiny-server'${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║   Environmental Bowtie Risk Analysis                          ║"
    echo "║   Remote Deployment to laguna.ku.lt                           ║"
    echo "║                                                               ║"
    echo "║   Version: ${APP_VERSION}                                            ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "  Source:      ${APP_SOURCE_DIR}"
    echo -e "  Destination: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_APP_DIR}"
    echo -e "  Started:     $(date '+%Y-%m-%d %H:%M:%S')"

    # Show mode
    if [ "$DRY_RUN" = true ]; then
        echo -e "  Mode:        ${YELLOW}DRY RUN (no changes will be made)${NC}"
    elif [ "$QUICK_MODE" = true ]; then
        echo -e "  Mode:        ${YELLOW}Quick Update (skip R packages)${NC}"
    else
        echo -e "  Mode:        ${GREEN}Full Deployment${NC}"
    fi
    echo ""

    # Run deployment steps
    preflight_checks
    create_remote_backup
    sync_files

    if [ "$DRY_RUN" = false ]; then
        set_permissions
        install_dependencies
        restart_service
        verify_deployment
    fi

    show_summary

    exit 0
}

# Run main function
main
