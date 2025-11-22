#!/bin/bash
# =============================================================================
# Environmental Bowtie Risk Analysis Application - Shiny Server Deployment
# Version: 5.2.0
# Last Updated: November 2025
# =============================================================================
#
# This script deploys the Bowtie App to shiny-server on this machine
# 
# Usage:
#   ./deploy_shiny_server.sh [OPTIONS]
#
# Options:
#   --app-name NAME         Set application name (default: bowtie_app)
#   --install-deps          Install/update R dependencies
#   --backup                Create backup before deployment
#   --no-restart            Don't restart shiny-server after deployment
#   --help                  Show this help message
#
# =============================================================================

set -e  # Exit on error

# =============================================================================
# CONFIGURATION - Read from centralized config.R
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Application source directory (parent of deployment directory)
APP_SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Load configuration from R config file
load_r_config() {
    Rscript --vanilla --quiet -e "
    suppressMessages({
      source('${APP_SOURCE_DIR}/config.R', local = TRUE)
      cat('APP_NAME=\"', APP_CONFIG\$APP_NAME, '\"\n', sep='')
      cat('VERSION=\"', APP_CONFIG\$VERSION, '\"\n', sep='')
      cat('SHINY_SERVER_DIR=\"', APP_CONFIG\$SHINY_SERVER_DIR, '\"\n', sep='')
      cat('REQUIRED_FILES=\"', paste(APP_CONFIG\$REQUIRED_FILES, collapse=' '), '\"\n', sep='')
    })
    " 2>/dev/null
}

# Parse R configuration or use defaults
if [ -f "${APP_SOURCE_DIR}/config.R" ]; then
    eval $(load_r_config)
else
    # Fallback to hardcoded defaults if config.R not found
    APP_NAME="bowtie_app"
    VERSION="5.2.0"
    SHINY_SERVER_DIR="/srv/shiny-server"
fi

APP_DEST_DIR="${SHINY_SERVER_DIR}/${APP_NAME}"
LOG_DIR="/var/log/shiny-server/${APP_NAME}"
BACKUP_DIR="/var/backups/shiny-apps"

# Options
INSTALL_DEPS=false
CREATE_BACKUP=false
RESTART_SERVER=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    head -n 20 "$0" | grep "^#" | sed 's/^# //' | sed 's/^#//'
    exit 0
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_shiny_server() {
    if ! command -v shiny-server &> /dev/null; then
        log_error "shiny-server is not installed"
        log_info "Install it from: https://posit.co/download/shiny-server/"
        exit 1
    fi
    log_success "shiny-server is installed"
}

check_r_installed() {
    if ! command -v R &> /dev/null; then
        log_error "R is not installed"
        exit 1
    fi
    
    R_VERSION=$(R --version | head -n1 | grep -oP 'R version \K[0-9.]+')
    log_success "R version ${R_VERSION} is installed"
}

create_backup() {
    if [ -d "${APP_DEST_DIR}" ]; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_PATH="${BACKUP_DIR}/${APP_NAME}_${TIMESTAMP}.tar.gz"
        
        log_info "Creating backup..."
        mkdir -p "${BACKUP_DIR}"
        
        tar -czf "${BACKUP_PATH}" -C "${SHINY_SERVER_DIR}" "${APP_NAME}" 2>/dev/null || true
        
        if [ -f "${BACKUP_PATH}" ]; then
            log_success "Backup created: ${BACKUP_PATH}"
        else
            log_warning "Backup failed, but continuing with deployment"
        fi
    else
        log_info "No existing installation to backup"
    fi
}

install_dependencies() {
    log_info "Installing R package dependencies..."
    
    if [ ! -f "${APP_SOURCE_DIR}/requirements.R" ]; then
        log_error "requirements.R not found in ${APP_SOURCE_DIR}"
        exit 1
    fi
    
    # Run as shiny user to ensure packages are installed in the right library
    su - shiny -c "cd ${APP_SOURCE_DIR} && Rscript requirements.R" || {
        log_warning "Some packages failed to install as shiny user, trying as root..."
        Rscript "${APP_SOURCE_DIR}/requirements.R"
    }
    
    log_success "Dependencies installed"
}

validate_app_structure() {
    log_info "Validating application structure in ${APP_SOURCE_DIR}..."
    
    # Use config.R to get required files list
    if [ -f "${APP_SOURCE_DIR}/config.R" ]; then
        REQUIRED_FILES=($(Rscript --vanilla --quiet -e "suppressMessages({source('${APP_SOURCE_DIR}/config.R', local=TRUE); cat(APP_CONFIG\$REQUIRED_FILES)})" 2>/dev/null))
    else
        # Fallback list if config.R not available
        REQUIRED_FILES=(
            "app.R"
            "global.R"
            "ui.R"
            "server.R"
            "start_app.R"
            "config.R"
            "guided_workflow.R"
            "utils.R"
            "vocabulary.R"
            "bowtie_bayesian_network.R"
            "translations_data.R"
            "environmental_scenarios.R"
            "vocabulary_bowtie_generator.R"
            "requirements.R"
            "CAUSES.xlsx"
            "CONSEQUENCES.xlsx"
            "CONTROLS.xlsx"
        )
    fi
    
    MISSING_FILES=()
    for file in "${REQUIRED_FILES[@]}"; do
        if [ ! -f "${APP_SOURCE_DIR}/${file}" ]; then
            MISSING_FILES+=("${file}")
        fi
    done
    
    if [ ${#MISSING_FILES[@]} -ne 0 ]; then
        log_error "Missing required files:"
        printf '  - %s\n' "${MISSING_FILES[@]}"
        exit 1
    fi
    
    log_success "All required files present"
}

deploy_application() {
    log_info "Deploying application from ${APP_SOURCE_DIR} to ${APP_DEST_DIR}..."
    
    # Create destination directory
    mkdir -p "${APP_DEST_DIR}"
    
    # Copy application files
    log_info "Copying application files..."
    
    # Copy core R files explicitly
    log_info "Copying core application files..."
    cp -f "${APP_SOURCE_DIR}/app.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "app.R not found"
    cp -f "${APP_SOURCE_DIR}/global.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "global.R not found"
    cp -f "${APP_SOURCE_DIR}/ui.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "ui.R not found"
    cp -f "${APP_SOURCE_DIR}/server.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "server.R not found"
    cp -f "${APP_SOURCE_DIR}/start_app.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "start_app.R not found"
    cp -f "${APP_SOURCE_DIR}/requirements.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "requirements.R not found"
    
    # Copy module files explicitly
    log_info "Copying module files..."
    cp -f "${APP_SOURCE_DIR}/guided_workflow.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "guided_workflow.R not found"
    cp -f "${APP_SOURCE_DIR}/bowtie_bayesian_network.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "bowtie_bayesian_network.R not found"
    cp -f "${APP_SOURCE_DIR}/utils.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "utils.r not found"
    cp -f "${APP_SOURCE_DIR}/vocabulary.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "vocabulary.R not found"
    cp -f "${APP_SOURCE_DIR}/vocabulary_bowtie_generator.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "vocabulary_bowtie_generator.R not found"
    cp -f "${APP_SOURCE_DIR}/translations_data.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "translations_data.R not found"
    cp -f "${APP_SOURCE_DIR}/environmental_scenarios.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "environmental_scenarios.R not found"
    cp -f "${APP_SOURCE_DIR}/config.R" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "config.R not found"
    
    # Copy any additional .R files (for future additions)
    log_info "Copying any additional R files..."
    for rfile in "${APP_SOURCE_DIR}"/*.R; do
        if [ -f "$rfile" ]; then
            filename=$(basename "$rfile")
            # Skip if already copied
            if [ ! -f "${APP_DEST_DIR}/$filename" ]; then
                cp -f "$rfile" "${APP_DEST_DIR}/"
            fi
        fi
    done
    
    # Copy Excel data files
    log_info "Copying data files..."
    cp -f "${APP_SOURCE_DIR}/CAUSES.xlsx" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "CAUSES.xlsx not found"
    cp -f "${APP_SOURCE_DIR}/CONSEQUENCES.xlsx" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "CONSEQUENCES.xlsx not found"
    cp -f "${APP_SOURCE_DIR}/CONTROLS.xlsx" "${APP_DEST_DIR}/" 2>/dev/null || log_warning "CONTROLS.xlsx not found"
    cp -f "${APP_SOURCE_DIR}"/*.xlsx "${APP_DEST_DIR}/" 2>/dev/null || true
    
    # Copy documentation
    log_info "Copying documentation..."
    cp -f "${APP_SOURCE_DIR}/README.md" "${APP_DEST_DIR}/" 2>/dev/null || true
    cp -f "${APP_SOURCE_DIR}/CLAUDE.md" "${APP_DEST_DIR}/" 2>/dev/null || true
    
    # Copy directories
    if [ -d "${APP_SOURCE_DIR}/www" ]; then
        cp -rf "${APP_SOURCE_DIR}/www" "${APP_DEST_DIR}/"
    fi
    
    if [ -d "${APP_SOURCE_DIR}/tests" ]; then
        cp -rf "${APP_SOURCE_DIR}/tests" "${APP_DEST_DIR}/"
    fi
    
    if [ -d "${APP_SOURCE_DIR}/utils" ]; then
        cp -rf "${APP_SOURCE_DIR}/utils" "${APP_DEST_DIR}/"
    fi
    
    if [ -d "${APP_SOURCE_DIR}/docs" ]; then
        cp -rf "${APP_SOURCE_DIR}/docs" "${APP_DEST_DIR}/"
    fi
    
    # Create necessary directories
    mkdir -p "${APP_DEST_DIR}/data"
    mkdir -p "${APP_DEST_DIR}/logs"
    mkdir -p "${APP_DEST_DIR}/Bow-tie guidance"
    mkdir -p "${LOG_DIR}"
    
    log_success "Application files copied"
}

set_permissions() {
    log_info "Setting permissions..."
    
    # Set ownership to shiny user
    chown -R shiny:shiny "${APP_DEST_DIR}"
    
    # Set directory permissions
    find "${APP_DEST_DIR}" -type d -exec chmod 755 {} \;
    
    # Set file permissions
    find "${APP_DEST_DIR}" -type f -exec chmod 644 {} \;
    
    # Make R scripts executable
    chmod 755 "${APP_DEST_DIR}"/*.r 2>/dev/null || true
    chmod 755 "${APP_DEST_DIR}"/*.R 2>/dev/null || true
    
    # Ensure data and logs directories are writable
    chmod 775 "${APP_DEST_DIR}/data"
    chmod 775 "${APP_DEST_DIR}/logs"
    chmod 775 "${APP_DEST_DIR}/Bow-tie guidance"
    chmod 775 "${LOG_DIR}"
    
    log_success "Permissions set"
}

update_shiny_config() {
    log_info "Updating shiny-server configuration..."
    
    CONFIG_FILE="/etc/shiny-server/shiny-server.conf"
    
    # Check if our app is already configured
    if grep -q "location /${APP_NAME}" "${CONFIG_FILE}"; then
        log_info "Configuration for ${APP_NAME} already exists"
    else
        log_info "Adding configuration for ${APP_NAME}..."
        
        # Backup original config
        cp "${CONFIG_FILE}" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Add configuration before the closing brace of the server block
        sed -i "/^server {/,/^}/ {
            /^}/i\\
\\
  # Environmental Bowtie Risk Analysis Application\\
  location /${APP_NAME} {\\
    app_dir ${APP_DEST_DIR};\\
    log_dir ${LOG_DIR};\\
    \\
    # Increase timeout for long-running operations\\
    app_init_timeout 90;\\
    app_idle_timeout 3600;\\
    \\
    # Allow reconnect\\
    reconnect true;\\
    \\
    # Disable directory index for this app\\
    directory_index off;\\
  }
        }" "${CONFIG_FILE}"
        
        log_success "Configuration added"
    fi
}

restart_shiny_server() {
    log_info "Restarting shiny-server..."
    
    systemctl restart shiny-server
    
    # Wait for service to start
    sleep 3
    
    if systemctl is-active --quiet shiny-server; then
        log_success "shiny-server restarted successfully"
    else
        log_error "Failed to restart shiny-server"
        log_info "Check logs: journalctl -u shiny-server -n 50"
        exit 1
    fi
}

test_deployment() {
    log_info "Testing deployment..."
    
    # Wait a bit for app to initialize
    sleep 5
    
    # Test if port 3838 is listening
    if netstat -tuln 2>/dev/null | grep -q ":3838"; then
        log_success "Shiny server is listening on port 3838"
    elif ss -tuln 2>/dev/null | grep -q ":3838"; then
        log_success "Shiny server is listening on port 3838"
    else
        log_warning "Could not verify if port 3838 is listening"
    fi
    
    # Test HTTP connection
    if command -v curl &> /dev/null; then
        if curl -f -s -o /dev/null "http://localhost:3838/${APP_NAME}/"; then
            log_success "Application is responding to HTTP requests"
        else
            log_warning "Application may not be responding yet (check logs)"
        fi
    fi
}

show_deployment_info() {
    echo ""
    echo "============================================================================="
    log_success "Deployment completed successfully!"
    echo "============================================================================="
    echo ""
    echo "Application Details:"
    echo "  Name:        ${APP_NAME}"
    echo "  Location:    ${APP_DEST_DIR}"
    echo "  Logs:        ${LOG_DIR}"
    echo ""
    echo "Access URLs:"
    echo "  Local:       http://localhost:3838/${APP_NAME}/"
    echo "  Network:     http://$(hostname -I | awk '{print $1}'):3838/${APP_NAME}/"
    echo ""
    echo "Useful Commands:"
    echo "  View logs:           tail -f ${LOG_DIR}/*.log"
    echo "  Restart service:     sudo systemctl restart shiny-server"
    echo "  Check status:        sudo systemctl status shiny-server"
    echo "  View system logs:    journalctl -u shiny-server -f"
    echo ""
    echo "Configuration:"
    echo "  Config file:         /etc/shiny-server/shiny-server.conf"
    echo "  Service file:        /etc/systemd/system/shiny-server.service"
    echo ""
    echo "============================================================================="
}

# =============================================================================
# COMMAND LINE ARGUMENTS
# =============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --app-name)
            APP_NAME="$2"
            APP_DEST_DIR="${SHINY_SERVER_DIR}/${APP_NAME}"
            LOG_DIR="/var/log/shiny-server/${APP_NAME}"
            shift 2
            ;;
        --install-deps)
            INSTALL_DEPS=true
            shift
            ;;
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        --no-restart)
            RESTART_SERVER=false
            shift
            ;;
        --help)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            ;;
    esac
done

# =============================================================================
# MAIN DEPLOYMENT PROCESS
# =============================================================================

echo "============================================================================="
echo "  Environmental Bowtie Risk Analysis - Shiny Server Deployment"
echo "  Version: 5.2.0"
echo "============================================================================="
echo ""

# Pre-deployment checks
log_info "Running pre-deployment checks..."
check_root
check_shiny_server
check_r_installed
validate_app_structure

# Optional: Create backup
if [ "${CREATE_BACKUP}" = true ]; then
    create_backup
fi

# Optional: Install dependencies
if [ "${INSTALL_DEPS}" = true ]; then
    install_dependencies
fi

# Deploy application
deploy_application
set_permissions
update_shiny_config

# Restart service
if [ "${RESTART_SERVER}" = true ]; then
    restart_shiny_server
    test_deployment
else
    log_warning "Skipping service restart (use --no-restart)"
    log_info "Remember to restart manually: sudo systemctl restart shiny-server"
fi

# Show deployment information
show_deployment_info

exit 0
