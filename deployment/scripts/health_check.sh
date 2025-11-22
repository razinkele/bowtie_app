#!/bin/bash
# =============================================================================
# Health Check Script for Bowtie App
# Checks if application is running and responsive
# =============================================================================

set -e

# Configuration
APP_URL="${APP_URL:-http://localhost:3838/bowtie_app/}"
TIMEOUT=10
MAX_RETRIES=3

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Health check function
check_health() {
    local attempt=$1

    echo -n "Health check (attempt $attempt/$MAX_RETRIES): "

    # Check if port is listening
    if ! netstat -tuln 2>/dev/null | grep -q ":3838" && ! ss -tuln 2>/dev/null | grep -q ":3838"; then
        echo -e "${RED}FAIL${NC} - Port 3838 not listening"
        return 1
    fi

    # Check HTTP response
    if command -v curl &> /dev/null; then
        response=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT "$APP_URL" 2>/dev/null)

        if [ "$response" = "200" ]; then
            echo -e "${GREEN}OK${NC} - HTTP 200"
            return 0
        else
            echo -e "${RED}FAIL${NC} - HTTP $response"
            return 1
        fi
    else
        # Fallback: just check if port is listening
        echo -e "${YELLOW}WARNING${NC} - curl not available, port check only"
        return 0
    fi
}

# Main health check with retries
for i in $(seq 1 $MAX_RETRIES); do
    if check_health $i; then
        echo -e "\n${GREEN}✓ Application is healthy${NC}"
        exit 0
    fi

    if [ $i -lt $MAX_RETRIES ]; then
        echo "  Retrying in 5 seconds..."
        sleep 5
    fi
done

echo -e "\n${RED}✗ Application health check failed${NC}"
echo "Please check:"
echo "  - sudo systemctl status shiny-server"
echo "  - tail -f /var/log/shiny-server/bowtie_app/*.log"
exit 1
