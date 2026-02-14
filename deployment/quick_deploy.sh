#!/bin/bash
# =============================================================================
# Quick Deployment Script for Environmental Bowtie Risk Analysis
# Version: 5.4.0 (Stability & Infrastructure Edition)
# Usage: ./quick_deploy.sh [local|production|docker]
# Updated: January 2026
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="bowtie_app"
APP_VERSION="5.4.0"
SHINY_SERVER_VERSION="1.5.22.1017"  # Latest stable version as of Jan 2026
DEPLOY_MODE="${1:-local}"
APP_DIR="/srv/shiny-server/$APP_NAME"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check R installation
    if command -v R &> /dev/null; then
        R_VERSION=$(R --version | head -n1)
        print_success "R found: $R_VERSION"
    else
        print_error "R is not installed!"
        exit 1
    fi
    
    # Check if running as root for production
    if [ "$DEPLOY_MODE" == "production" ] && [ "$EUID" -ne 0 ]; then
        print_error "Please run as root for production deployment (use sudo)"
        exit 1
    fi
    
    # Check required files
    REQUIRED_FILES=("app.R" "global.R" "ui.R" "server.R" "start_app.R" "requirements.R")
    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$file" ]; then
            print_success "Found: $file"
        else
            print_error "Missing required file: $file"
            exit 1
        fi
    done
}

install_dependencies() {
    print_header "Installing R Dependencies"
    
    print_info "This may take 10-15 minutes..."
    Rscript requirements.R
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

deploy_local() {
    print_header "Starting Local Development Server"
    
    print_info "Application will be available at: http://localhost:3838"
    print_info "Press Ctrl+C to stop the server"
    
    Rscript start_app.R
}

deploy_production() {
    print_header "Deploying to Production"

    # Install Shiny Server if not present
    if ! command -v shiny-server &> /dev/null; then
        print_warning "Shiny Server not found. Installing version ${SHINY_SERVER_VERSION}..."

        # Detect OS
        if [ -f /etc/debian_version ]; then
            # Debian/Ubuntu
            print_info "Detected Debian/Ubuntu system"
            wget "https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-${SHINY_SERVER_VERSION}-amd64.deb"
            sudo gdebi -n "shiny-server-${SHINY_SERVER_VERSION}-amd64.deb"
            rm "shiny-server-${SHINY_SERVER_VERSION}-amd64.deb"
        elif [ -f /etc/redhat-release ]; then
            # RedHat/CentOS/Rocky/Alma
            print_info "Detected RedHat-based system"
            wget "https://download3.rstudio.org/centos7/x86_64/shiny-server-${SHINY_SERVER_VERSION}-x86_64.rpm"
            sudo yum install -y --nogpgcheck "shiny-server-${SHINY_SERVER_VERSION}-x86_64.rpm"
            rm "shiny-server-${SHINY_SERVER_VERSION}-x86_64.rpm"
        else
            print_error "Unsupported OS. Please install Shiny Server manually."
            print_info "Visit: https://posit.co/download/shiny-server/"
            exit 1
        fi

        print_success "Shiny Server ${SHINY_SERVER_VERSION} installed"
    else
        print_success "Shiny Server already installed"
    fi
    
    # Create backup if app exists
    if [ -d "$APP_DIR" ]; then
        BACKUP_DIR="/tmp/${APP_NAME}_backup_$(date +%Y%m%d_%H%M%S)"
        print_info "Creating backup: $BACKUP_DIR"
        sudo cp -r "$APP_DIR" "$BACKUP_DIR"
        print_success "Backup created"
    fi
    
    # Create app directory
    print_info "Creating application directory: $APP_DIR"
    sudo mkdir -p "$APP_DIR"
    
    # Copy application files
    print_info "Copying application files..."
    sudo cp -r ./* "$APP_DIR/"
    
    # Set permissions
    print_info "Setting permissions..."
    sudo chown -R shiny:shiny "$APP_DIR"
    sudo chmod -R 755 "$APP_DIR"
    
    # Configure Shiny Server
    print_info "Configuring Shiny Server..."
    sudo tee /etc/shiny-server/shiny-server.conf > /dev/null <<EOF
# Shiny Server Configuration
run_as shiny;

server {
  listen 3838;

  location /$APP_NAME {
    app_dir $APP_DIR;
    log_dir /var/log/shiny-server;
    app_idle_timeout 600;
    app_init_timeout 120;
  }
}
EOF
    
    # Restart Shiny Server
    print_info "Restarting Shiny Server..."
    sudo systemctl restart shiny-server
    sudo systemctl enable shiny-server
    
    # Check status
    if sudo systemctl is-active --quiet shiny-server; then
        print_success "Shiny Server is running"
        print_success "Application deployed successfully!"
        print_info "Access at: http://$(hostname -I | awk '{print $1}'):3838/$APP_NAME"
    else
        print_error "Shiny Server failed to start"
        print_info "Check logs: sudo journalctl -u shiny-server -n 50"
        exit 1
    fi
}

deploy_docker() {
    print_header "Deploying with Docker"
    
    # Check Docker installation
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed!"
        exit 1
    fi
    
    print_success "Docker found"
    
    # Navigate to deployment directory
    cd deployment
    
    # Build and run
    print_info "Building and starting containers..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        print_success "Containers started successfully"
        print_info "Application: http://localhost:3838"
        print_info "View logs: docker-compose logs -f"
        print_info "Stop: docker-compose down"
    else
        print_error "Failed to start containers"
        exit 1
    fi
}

show_usage() {
    cat << EOF
Environmental Bowtie Risk Analysis - Deployment Script
Version: $APP_VERSION

Usage: $0 [MODE]

Deployment Modes:
  local       - Start local development server (default)
  production  - Deploy to Shiny Server (requires sudo)
  docker      - Deploy with Docker Compose

Examples:
  $0                  # Local development
  $0 local            # Same as above
  sudo $0 production  # Production deployment
  $0 docker           # Docker deployment

EOF
}

# Main execution
main() {
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        show_usage
        exit 0
    fi
    
    print_header "Environmental Bowtie Analysis Deployment"
    print_info "Version: $APP_VERSION"
    print_info "Mode: $DEPLOY_MODE"
    echo ""
    
    check_prerequisites
    
    case $DEPLOY_MODE in
        local)
            install_dependencies
            deploy_local
            ;;
        production)
            install_dependencies
            deploy_production
            ;;
        docker)
            deploy_docker
            ;;
        *)
            print_error "Unknown deployment mode: $DEPLOY_MODE"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
