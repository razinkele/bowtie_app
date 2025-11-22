#!/bin/bash
# =============================================================================
# Shiny Server Management Helper Script
# Quick commands for managing the bowtie_app deployment
# =============================================================================

APP_NAME="bowtie_app"
APP_DIR="/srv/shiny-server/${APP_NAME}"
LOG_DIR="/var/log/shiny-server/${APP_NAME}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    cat << EOF
Shiny Server Management Helper for ${APP_NAME}

Usage: ./manage_app.sh [command]

Commands:
    status          Show shiny-server status
    start           Start shiny-server
    stop            Stop shiny-server
    restart         Restart shiny-server
    logs            View application logs (real-time)
    logs-sys        View system logs (real-time)
    logs-last       View last 100 lines of logs
    check           Check if application is responding
    url             Show access URLs
    permissions     Fix file permissions
    clean-logs      Clean old log files
    info            Show deployment information
    help            Show this help message

Examples:
    ./manage_app.sh status
    ./manage_app.sh logs
    ./manage_app.sh restart

EOF
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Note: Some commands require sudo${NC}"
        return 1
    fi
    return 0
}

case "${1:-help}" in
    status)
        echo -e "${BLUE}Shiny Server Status:${NC}"
        systemctl status shiny-server --no-pager
        ;;
        
    start)
        check_root || exit 1
        echo -e "${BLUE}Starting shiny-server...${NC}"
        systemctl start shiny-server
        systemctl status shiny-server --no-pager -l
        ;;
        
    stop)
        check_root || exit 1
        echo -e "${BLUE}Stopping shiny-server...${NC}"
        systemctl stop shiny-server
        ;;
        
    restart)
        check_root || exit 1
        echo -e "${BLUE}Restarting shiny-server...${NC}"
        systemctl restart shiny-server
        sleep 2
        systemctl status shiny-server --no-pager -l
        ;;
        
    logs)
        echo -e "${BLUE}Application logs (Ctrl+C to exit):${NC}"
        if [ -d "${LOG_DIR}" ]; then
            tail -f "${LOG_DIR}"/*.log 2>/dev/null || echo "No log files found in ${LOG_DIR}"
        else
            echo "Log directory not found: ${LOG_DIR}"
        fi
        ;;
        
    logs-sys)
        echo -e "${BLUE}System logs (Ctrl+C to exit):${NC}"
        journalctl -u shiny-server -f
        ;;
        
    logs-last)
        echo -e "${BLUE}Last 100 lines of logs:${NC}"
        if [ -d "${LOG_DIR}" ]; then
            tail -n 100 "${LOG_DIR}"/*.log 2>/dev/null || echo "No log files found"
        else
            echo "Log directory not found: ${LOG_DIR}"
        fi
        echo ""
        echo -e "${BLUE}Last 50 lines of system logs:${NC}"
        journalctl -u shiny-server -n 50 --no-pager
        ;;
        
    check)
        echo -e "${BLUE}Checking if application is responding...${NC}"
        
        # Check service
        if systemctl is-active --quiet shiny-server; then
            echo -e "${GREEN}✓${NC} Shiny Server service is running"
        else
            echo -e "${YELLOW}✗${NC} Shiny Server service is not running"
        fi
        
        # Check port
        if netstat -tuln 2>/dev/null | grep -q ":3838" || ss -tuln 2>/dev/null | grep -q ":3838"; then
            echo -e "${GREEN}✓${NC} Port 3838 is listening"
        else
            echo -e "${YELLOW}✗${NC} Port 3838 is not listening"
        fi
        
        # Check HTTP
        if command -v curl &> /dev/null; then
            if curl -f -s -o /dev/null --max-time 5 "http://localhost:3838/${APP_NAME}/"; then
                echo -e "${GREEN}✓${NC} Application is responding to HTTP requests"
            else
                echo -e "${YELLOW}✗${NC} Application is not responding (may still be starting)"
            fi
        fi
        
        # Check files
        if [ -d "${APP_DIR}" ]; then
            echo -e "${GREEN}✓${NC} Application directory exists"
        else
            echo -e "${YELLOW}✗${NC} Application directory not found"
        fi
        ;;
        
    url)
        echo -e "${BLUE}Access URLs:${NC}"
        echo ""
        echo "  Local:       http://localhost:3838/${APP_NAME}/"
        
        # Get IP addresses
        IPS=$(hostname -I 2>/dev/null || ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)
        if [ -n "$IPS" ]; then
            echo "  Network:     http://$(echo $IPS | awk '{print $1}'):3838/${APP_NAME}/"
        fi
        echo ""
        ;;
        
    permissions)
        check_root || exit 1
        echo -e "${BLUE}Fixing file permissions...${NC}"
        
        if [ -d "${APP_DIR}" ]; then
            chown -R shiny:shiny "${APP_DIR}"
            find "${APP_DIR}" -type d -exec chmod 755 {} \;
            find "${APP_DIR}" -type f -exec chmod 644 {} \;
            chmod 775 "${APP_DIR}/data" 2>/dev/null || true
            chmod 775 "${APP_DIR}/logs" 2>/dev/null || true
            chmod 775 "${APP_DIR}/Bow-tie guidance" 2>/dev/null || true
            echo -e "${GREEN}✓${NC} Permissions fixed"
        else
            echo "Application directory not found: ${APP_DIR}"
        fi
        ;;
        
    clean-logs)
        check_root || exit 1
        echo -e "${BLUE}Cleaning old log files...${NC}"
        
        if [ -d "${LOG_DIR}" ]; then
            # Remove logs older than 7 days
            find "${LOG_DIR}" -name "*.log" -type f -mtime +7 -delete
            echo -e "${GREEN}✓${NC} Old log files removed"
            
            # Show remaining logs
            LOG_COUNT=$(find "${LOG_DIR}" -name "*.log" -type f | wc -l)
            echo "Remaining log files: ${LOG_COUNT}"
        else
            echo "Log directory not found: ${LOG_DIR}"
        fi
        ;;
        
    info)
        echo -e "${BLUE}Deployment Information:${NC}"
        echo ""
        echo "Application:"
        echo "  Name:        ${APP_NAME}"
        echo "  Directory:   ${APP_DIR}"
        echo "  Logs:        ${LOG_DIR}"
        echo ""
        
        if [ -d "${APP_DIR}" ]; then
            echo "Files:"
            FILE_COUNT=$(find "${APP_DIR}" -type f | wc -l)
            DIR_COUNT=$(find "${APP_DIR}" -type d | wc -l)
            TOTAL_SIZE=$(du -sh "${APP_DIR}" 2>/dev/null | awk '{print $1}')
            echo "  Files:       ${FILE_COUNT}"
            echo "  Directories: ${DIR_COUNT}"
            echo "  Total Size:  ${TOTAL_SIZE}"
        fi
        
        echo ""
        echo "Service:"
        if systemctl is-active --quiet shiny-server; then
            echo "  Status:      Running"
            UPTIME=$(systemctl show shiny-server --property=ActiveEnterTimestamp | cut -d= -f2)
            echo "  Since:       ${UPTIME}"
        else
            echo "  Status:      Stopped"
        fi
        
        echo ""
        echo "Configuration:"
        echo "  Config:      /etc/shiny-server/shiny-server.conf"
        echo "  Service:     /etc/systemd/system/shiny-server.service"
        ;;
        
    help|--help|-h|"")
        show_usage
        ;;
        
    *)
        echo "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac

exit 0
