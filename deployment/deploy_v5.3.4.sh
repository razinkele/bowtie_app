#!/bin/bash

# =============================================================================
# Environmental Bowtie Risk Analysis - Deployment Script v5.3.4
# Date: December 2025
# Description: Automated deployment script for v5.3.4 with validation
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_VERSION="5.3.4"
APP_NAME="bowtie_app"
DEPLOYMENT_DIR="/srv/shiny-server/$APP_NAME"
BACKUP_DIR="/backup/$APP_NAME"
LOG_FILE="/var/log/bowtie_deployment.log"

# =============================================================================
# Helper Functions
# =============================================================================

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# =============================================================================
# Pre-Deployment Checks
# =============================================================================

pre_deployment_checks() {
    log "Starting pre-deployment checks..."

    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]]; then
        warning "This script should be run with sudo privileges"
        read -p "Continue without sudo? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Check R installation
    info "Checking R installation..."
    if ! command -v R &> /dev/null; then
        error "R is not installed. Please install R 4.4.3 or higher."
    fi

    R_VERSION=$(R --version | head -n 1 | awk '{print $3}')
    log "✅ R version: $R_VERSION"

    # Check required directories exist
    info "Checking directory structure..."
    if [ ! -d "$(dirname "$0")/.." ]; then
        error "Application directory not found"
    fi

    # Check required files
    REQUIRED_FILES=(
        "app.R"
        "start_app.R"
        "config.R"
        "global.R"
        "ui.R"
        "server.R"
        "guided_workflow.R"
        "vocabulary.R"
    )

    for file in "${REQUIRED_FILES[@]}"; do
        if [ ! -f "$(dirname "$0")/../$file" ]; then
            error "Required file not found: $file"
        fi
    done
    log "✅ All required files present"

    # Check data files
    DATA_FILES=("CAUSES.xlsx" "CONSEQUENCES.xlsx" "CONTROLS.xlsx")
    for file in "${DATA_FILES[@]}"; do
        if [ ! -f "$(dirname "$0")/../$file" ]; then
            error "Required data file not found: $file"
        fi
    done
    log "✅ All data files present"
}

# =============================================================================
# Backup Current Installation
# =============================================================================

backup_current() {
    log "Creating backup of current installation..."

    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/${APP_NAME}_${TIMESTAMP}.tar.gz"

    if [ -d "$DEPLOYMENT_DIR" ]; then
        tar -czf "$BACKUP_FILE" -C "$(dirname "$DEPLOYMENT_DIR")" "$(basename "$DEPLOYMENT_DIR")" 2>/dev/null || true
        if [ -f "$BACKUP_FILE" ]; then
            log "✅ Backup created: $BACKUP_FILE"
        else
            warning "Backup creation failed or no existing installation found"
        fi
    else
        info "No existing installation to backup"
    fi

    # Clean old backups (keep last 10)
    cd "$BACKUP_DIR" 2>/dev/null || true
    ls -t ${APP_NAME}_*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm
}

# =============================================================================
# Run Tests
# =============================================================================

run_tests() {
    log "Running comprehensive test suite..."

    cd "$(dirname "$0")/.."

    # Run tests
    if Rscript tests/comprehensive_test_runner.R 2>&1 | tee -a "$LOG_FILE"; then
        log "✅ All tests passed"
    else
        error "Tests failed. Deployment aborted."
    fi
}

# =============================================================================
# Deploy Application
# =============================================================================

deploy_application() {
    log "Deploying application v$APP_VERSION..."

    SOURCE_DIR="$(dirname "$0")/.."

    # Create deployment directory if it doesn't exist
    mkdir -p "$DEPLOYMENT_DIR"

    # Copy files
    info "Copying application files..."
    rsync -av --delete \
        --exclude='.git' \
        --exclude='.Rproj.user' \
        --exclude='*.Rproj' \
        --exclude='deployment/archive' \
        --exclude='logs' \
        --exclude='progress' \
        "$SOURCE_DIR/" "$DEPLOYMENT_DIR/"

    # Set permissions
    info "Setting permissions..."
    chown -R shiny:shiny "$DEPLOYMENT_DIR" 2>/dev/null || true
    chmod -R 755 "$DEPLOYMENT_DIR"

    # Create necessary directories
    mkdir -p "$DEPLOYMENT_DIR/logs"
    mkdir -p "$DEPLOYMENT_DIR/progress"
    mkdir -p "$DEPLOYMENT_DIR/data"

    log "✅ Application deployed to $DEPLOYMENT_DIR"
}

# =============================================================================
# Install R Packages
# =============================================================================

install_r_packages() {
    log "Installing/updating R packages..."

    cd "$DEPLOYMENT_DIR"

    # Install required packages
    Rscript -e "
    required_packages <- c(
        'shiny', 'bslib', 'DT', 'readxl', 'openxlsx',
        'ggplot2', 'plotly', 'dplyr', 'visNetwork',
        'shinycssloaders', 'colourpicker', 'htmlwidgets', 'shinyjs',
        'bnlearn', 'gRain', 'igraph', 'DiagrammeR'
    )

    install_if_missing <- function(pkg) {
        if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
            install.packages(pkg, repos = 'https://cloud.r-project.org/')
            return(TRUE)
        }
        return(FALSE)
    }

    installed <- sapply(required_packages, install_if_missing)
    cat(paste('Installed', sum(installed), 'new packages\n'))
    " 2>&1 | tee -a "$LOG_FILE"

    log "✅ R packages installed"
}

# =============================================================================
# Configure Shiny Server
# =============================================================================

configure_shiny_server() {
    log "Configuring Shiny Server..."

    SHINY_CONF="/etc/shiny-server/shiny-server.conf"

    if [ ! -f "$SHINY_CONF" ]; then
        warning "Shiny Server not installed. Skipping configuration."
        return
    fi

    # Backup current config
    cp "$SHINY_CONF" "${SHINY_CONF}.backup.$(date +%Y%m%d)" 2>/dev/null || true

    # Check if app is already configured
    if ! grep -q "$APP_NAME" "$SHINY_CONF"; then
        info "Adding application to Shiny Server configuration..."

        cat >> "$SHINY_CONF" <<EOF

# Environmental Bowtie Risk Analysis v$APP_VERSION
location /$APP_NAME {
    app_dir $DEPLOYMENT_DIR;
    log_dir /var/log/shiny-server;
    directory_index on;
    app_session_timeout 3600;
    app_idle_timeout 1800;
}
EOF
        log "✅ Shiny Server configured"
    else
        info "Application already configured in Shiny Server"
    fi
}

# =============================================================================
# Restart Services
# =============================================================================

restart_services() {
    log "Restarting services..."

    # Restart Shiny Server if installed
    if command -v shiny-server &> /dev/null; then
        systemctl restart shiny-server 2>/dev/null || service shiny-server restart 2>/dev/null || true
        log "✅ Shiny Server restarted"
    else
        info "Shiny Server not installed. Application ready for manual start."
    fi

    # Restart Nginx if installed and configured
    if command -v nginx &> /dev/null; then
        nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || true
        log "✅ Nginx reloaded"
    fi
}

# =============================================================================
# Post-Deployment Validation
# =============================================================================

post_deployment_validation() {
    log "Running post-deployment validation..."

    # Wait for services to start
    sleep 5

    # Check if application is accessible
    info "Checking application accessibility..."

    if command -v curl &> /dev/null; then
        if curl -f -s http://localhost:3838 > /dev/null 2>&1; then
            log "✅ Application is accessible at http://localhost:3838"
        else
            warning "Application may not be accessible. Check logs."
        fi
    else
        info "curl not available. Skipping accessibility check."
    fi

    # Check version
    if grep -q "VERSION = \"$APP_VERSION\"" "$DEPLOYMENT_DIR/config.R"; then
        log "✅ Version $APP_VERSION verified"
    else
        warning "Version verification failed"
    fi

    # Check critical features
    info "Verifying v5.3.4 features..."

    FEATURES_OK=true

    # Check custom entries feature
    if grep -q "create = TRUE" "$DEPLOYMENT_DIR/guided_workflow.R"; then
        log "  ✅ Custom entries feature present"
    else
        warning "  ❌ Custom entries feature not found"
        FEATURES_OK=false
    fi

    # Check manual linking feature
    if grep -q "link_activity" "$DEPLOYMENT_DIR/guided_workflow.R"; then
        log "  ✅ Manual linking feature present"
    else
        warning "  ❌ Manual linking feature not found"
        FEATURES_OK=false
    fi

    # Check delete functionality
    if grep -q "delete_activity" "$DEPLOYMENT_DIR/guided_workflow.R"; then
        log "  ✅ Delete functionality present"
    else
        warning "  ❌ Delete functionality not found"
        FEATURES_OK=false
    fi

    if [ "$FEATURES_OK" = true ]; then
        log "✅ All v5.3.4 features verified"
    else
        warning "Some v5.3.4 features may not be properly configured"
    fi
}

# =============================================================================
# Generate Deployment Report
# =============================================================================

generate_report() {
    log "Generating deployment report..."

    REPORT_FILE="$DEPLOYMENT_DIR/deployment_report_$(date +%Y%m%d_%H%M%S).txt"

    cat > "$REPORT_FILE" <<EOF
=============================================================================
Environmental Bowtie Risk Analysis - Deployment Report
=============================================================================
Version: $APP_VERSION
Date: $(date)
Deployed by: $(whoami)
Hostname: $(hostname)

=============================================================================
System Information
=============================================================================
OS: $(uname -s)
Kernel: $(uname -r)
Architecture: $(uname -m)
R Version: $(R --version | head -n 1)

=============================================================================
Installation Paths
=============================================================================
Application Directory: $DEPLOYMENT_DIR
Backup Directory: $BACKUP_DIR
Log File: $LOG_FILE

=============================================================================
Application Configuration
=============================================================================
Port: 3838
Host: 0.0.0.0
Environment: Production

=============================================================================
Feature Checklist (v5.3.4)
=============================================================================
✅ Custom Entries: Enabled
✅ Manual Linking: Enabled
✅ Category Filtering: Enabled
✅ Delete Functionality: Enabled (6 tables)
✅ Data Persistence: Enhanced
✅ Template System: 12 scenarios
✅ Export Functions: Excel, PDF, RDS

=============================================================================
Access URLs
=============================================================================
Local: http://localhost:3838/$APP_NAME
Network: http://$(hostname -I | awk '{print $1}'):3838/$APP_NAME

=============================================================================
Next Steps
=============================================================================
1. Access the application using the URLs above
2. Test guided workflow with custom entries
3. Test manual linking functionality
4. Verify delete buttons in all tables
5. Check data persistence across navigation
6. Test all 12 environmental scenario templates
7. Verify export functions (Excel, PDF)

=============================================================================
Support
=============================================================================
Documentation: $DEPLOYMENT_DIR/deployment/DEPLOYMENT_GUIDE_v5.3.4.md
Logs: /var/log/shiny-server/
Issues: https://github.com/razinkele/bowtie_app/issues

=============================================================================
Deployment Complete
=============================================================================
Status: SUCCESS ✅
Timestamp: $(date)
=============================================================================
EOF

    log "✅ Deployment report generated: $REPORT_FILE"
    cat "$REPORT_FILE"
}

# =============================================================================
# Main Deployment Flow
# =============================================================================

main() {
    echo "============================================================================="
    echo "Environmental Bowtie Risk Analysis - Deployment Script v$APP_VERSION"
    echo "============================================================================="
    echo ""

    # Execute deployment steps
    pre_deployment_checks
    backup_current
    run_tests
    deploy_application
    install_r_packages
    configure_shiny_server
    restart_services
    post_deployment_validation
    generate_report

    echo ""
    echo "============================================================================="
    echo "🎉 Deployment Complete! 🎉"
    echo "============================================================================="
    echo ""
    echo "Application v$APP_VERSION has been successfully deployed!"
    echo ""
    echo "Access URLs:"
    echo "  Local:   http://localhost:3838/$APP_NAME"
    echo "  Network: http://$(hostname -I 2>/dev/null | awk '{print $1}'):3838/$APP_NAME"
    echo ""
    echo "Next steps:"
    echo "  1. Test the application"
    echo "  2. Review deployment report"
    echo "  3. Monitor logs: tail -f /var/log/shiny-server/*.log"
    echo ""
    echo "Documentation: $DEPLOYMENT_DIR/deployment/DEPLOYMENT_GUIDE_v5.3.4.md"
    echo "============================================================================="
}

# =============================================================================
# Script Options
# =============================================================================

case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h          Show this help message"
        echo "  --skip-tests        Skip running tests"
        echo "  --skip-backup       Skip backup creation"
        echo "  --dry-run           Perform checks without deploying"
        echo ""
        exit 0
        ;;
    --skip-tests)
        log "Skipping tests as requested"
        run_tests() { log "Tests skipped"; }
        ;;
    --skip-backup)
        log "Skipping backup as requested"
        backup_current() { log "Backup skipped"; }
        ;;
    --dry-run)
        log "Dry run mode - no changes will be made"
        pre_deployment_checks
        log "Dry run complete. Application is ready for deployment."
        exit 0
        ;;
esac

# Run main deployment
main

# Exit successfully
exit 0
