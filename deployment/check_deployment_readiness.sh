#!/bin/bash
# =============================================================================
# Pre-Deployment Readiness Check Script
# Environmental Bowtie Risk Analysis Application
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

log_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS++))
}

log_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL++))
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN++))
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo "============================================================================="
echo "  Pre-Deployment Readiness Check"
echo "  Environmental Bowtie Risk Analysis Application"
echo "============================================================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_pass "Running as root/sudo"
else
    log_fail "Not running as root (deployment requires sudo)"
fi

# Check shiny-server
if command -v shiny-server &> /dev/null; then
    SHINY_VERSION=$(dpkg -l | grep shiny-server | awk '{print $3}')
    log_pass "Shiny Server installed (version: ${SHINY_VERSION})"
else
    log_fail "Shiny Server not installed"
fi

# Check R installation
if command -v R &> /dev/null; then
    R_VERSION=$(R --version | head -n1 | grep -oP 'R version \K[0-9.]+')
    log_pass "R installed (version: ${R_VERSION})"
    
    # Check R version is sufficient
    R_MAJOR=$(echo $R_VERSION | cut -d. -f1)
    R_MINOR=$(echo $R_VERSION | cut -d. -f2)
    if [ "$R_MAJOR" -ge 4 ] && [ "$R_MINOR" -ge 3 ]; then
        log_pass "R version is sufficient (>= 4.3.0)"
    else
        log_warn "R version should be 4.3.0 or higher (current: ${R_VERSION})"
    fi
else
    log_fail "R not installed"
fi

# Check shiny-server service
if systemctl is-active --quiet shiny-server; then
    log_pass "Shiny Server service is running"
elif systemctl is-enabled --quiet shiny-server; then
    log_warn "Shiny Server service is enabled but not running"
else
    log_fail "Shiny Server service is not running or enabled"
fi

# Check directories
if [ -d "/srv/shiny-server" ]; then
    log_pass "Shiny Server directory exists (/srv/shiny-server)"
else
    log_fail "Shiny Server directory not found (/srv/shiny-server)"
fi

if [ -d "/var/log/shiny-server" ]; then
    log_pass "Log directory exists (/var/log/shiny-server)"
else
    log_warn "Log directory not found (/var/log/shiny-server)"
fi

# Check application files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Application source directory (parent of deployment directory)
APP_SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Load required files from config.R
if [ -f "${APP_SOURCE_DIR}/config.R" ]; then
    REQUIRED_FILES=($(Rscript --vanilla --quiet -e "suppressMessages({source('${APP_SOURCE_DIR}/config.R', local=TRUE); cat(APP_CONFIG\$REQUIRED_FILES)})" 2>/dev/null))
    REQUIRED_DIRS=($(Rscript --vanilla --quiet -e "suppressMessages({source('${APP_SOURCE_DIR}/config.R', local=TRUE); cat(APP_CONFIG\$REQUIRED_DIRS)})" 2>/dev/null))
else
    # Fallback list if config.R not available
    REQUIRED_FILES=(
        "app.R"
        "global.R"
        "ui.R"
        "server.R"
        "start_app.R"
        "config.R"
        "requirements.R"
        "guided_workflow.R"
        "utils.r"
        "vocabulary.R"
        "vocabulary_bowtie_generator.R"
        "bowtie_bayesian_network.R"
        "translations_data.R"
        "environmental_scenarios.R"
        "CAUSES.xlsx"
        "CONSEQUENCES.xlsx"
        "CONTROLS.xlsx"
    )
    REQUIRED_DIRS=(
        "deployment"
        "tests"
        "docs"
        "data"
        "www"
    )
fi

log_info "Checking application files in ${APP_SOURCE_DIR}..."
MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "${APP_SOURCE_DIR}/${file}" ]; then
        echo -e "  ${GREEN}✓${NC} ${file}"
    else
        echo -e "  ${RED}✗${NC} ${file} (missing)"
        ((MISSING++))
    fi
done

if [ $MISSING -eq 0 ]; then
    log_pass "All required application files present (${#REQUIRED_FILES[@]} files)"
else
    log_fail "${MISSING} required files missing"
    FAIL=$((FAIL + MISSING))
fi

# Check required directories
log_info "Checking required directories..."
MISSING_DIRS=0
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "${APP_SOURCE_DIR}/${dir}" ]; then
        echo -e "  ${GREEN}✓${NC} ${dir}/"
    else
        echo -e "  ${RED}✗${NC} ${dir}/ (missing)"
        ((MISSING_DIRS++))
    fi
done

if [ $MISSING_DIRS -eq 0 ]; then
    log_pass "All required directories present (${#REQUIRED_DIRS[@]} directories)"
else
    log_fail "${MISSING_DIRS} required directories missing"
    FAIL=$((FAIL + MISSING_DIRS))
fi

# Check network port
if netstat -tuln 2>/dev/null | grep -q ":3838" || ss -tuln 2>/dev/null | grep -q ":3838"; then
    log_pass "Port 3838 is in use (Shiny Server listening)"
else
    log_warn "Port 3838 not in use (Shiny Server may not be running)"
fi

# Check disk space
AVAILABLE=$(df -BG /srv | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE" -gt 2 ]; then
    log_pass "Sufficient disk space (${AVAILABLE}G available)"
else
    log_warn "Low disk space (${AVAILABLE}G available, recommend > 2GB)"
fi

# Check memory
TOTAL_MEM=$(free -g | grep Mem | awk '{print $2}')
if [ "$TOTAL_MEM" -ge 4 ]; then
    log_pass "Sufficient memory (${TOTAL_MEM}GB total)"
else
    log_warn "Low memory (${TOTAL_MEM}GB total, recommend >= 4GB)"
fi

# Check if curl is available for testing
if command -v curl &> /dev/null; then
    log_pass "curl installed (for HTTP testing)"
else
    log_warn "curl not installed (recommended for testing)"
fi

# Summary
echo ""
echo "============================================================================="
echo "  Summary"
echo "============================================================================="
echo -e "Passed:   ${GREEN}${PASS}${NC}"
echo -e "Failed:   ${RED}${FAIL}${NC}"
echo -e "Warnings: ${YELLOW}${WARN}${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}System is ready for deployment!${NC}"
    echo ""
    echo "To deploy, run:"
    echo "  sudo ${SCRIPT_DIR}/deploy_shiny_server.sh --install-deps --backup"
    exit 0
else
    echo -e "${RED}System is NOT ready for deployment${NC}"
    echo "Please resolve the issues above before deploying."
    exit 1
fi
