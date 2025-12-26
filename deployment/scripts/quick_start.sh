#!/bin/bash
# =============================================================================
# Quick Start Deployment Script
# One-command deployment for new installations
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "============================================================================="
echo "  Environmental Bowtie Risk Analysis - Quick Start"
echo "  One-command deployment for Ubuntu/Debian"
echo "============================================================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOYMENT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_SOURCE_DIR="$(cd "${DEPLOYMENT_DIR}/.." && pwd)"

echo -e "${BLUE}Step 1/6:${NC} Updating system..."
apt-get update -qq

echo -e "${BLUE}Step 2/6:${NC} Installing R..."
if ! command -v R &> /dev/null; then
    apt-get install -y -qq software-properties-common dirmngr
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc > /dev/null
    add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" > /dev/null 2>&1
    apt-get update -qq
    apt-get install -y -qq r-base r-base-dev
    echo -e "  ${GREEN}✓ R installed${NC}"
else
    echo -e "  ${GREEN}✓ R already installed${NC}"
fi

echo -e "${BLUE}Step 3/6:${NC} Installing system dependencies..."
apt-get install -y -qq \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    gdebi-core \
    git \
    net-tools
echo -e "  ${GREEN}✓ Dependencies installed${NC}"

echo -e "${BLUE}Step 4/6:${NC} Installing Shiny Server..."
if ! command -v shiny-server &> /dev/null; then
    cd /tmp
    wget -q https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.21.1012-amd64.deb
    gdebi -n shiny-server-1.5.21.1012-amd64.deb > /dev/null 2>&1
    systemctl enable shiny-server > /dev/null 2>&1
    systemctl start shiny-server > /dev/null 2>&1
    echo -e "  ${GREEN}✓ Shiny Server installed and started${NC}"
else
    echo -e "  ${GREEN}✓ Shiny Server already installed${NC}"
fi

echo -e "${BLUE}Step 5/6:${NC} Deploying application..."
bash "${DEPLOYMENT_DIR}/deploy_shiny_server.sh" --install-deps > /dev/null 2>&1
echo -e "  ${GREEN}✓ Application deployed${NC}"

echo -e "${BLUE}Step 6/6:${NC} Running health check..."
sleep 5
if bash "${SCRIPT_DIR}/health_check.sh" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ Health check passed${NC}"
else
    echo -e "  ${YELLOW}⚠ Health check failed (check logs)${NC}"
fi

echo ""
echo "============================================================================="
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo "============================================================================="
echo ""
echo "Application is available at:"
echo "  http://localhost:3838/bowtie_app/"
echo "  http://$(hostname -I | awk '{print $1}'):3838/bowtie_app/"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status shiny-server"
echo "  tail -f /var/log/shiny-server/bowtie_app/*.log"
echo "  bash ${SCRIPT_DIR}/monitor.sh"
echo ""
echo "============================================================================="
