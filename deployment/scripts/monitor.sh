#!/bin/bash
# =============================================================================
# Monitoring Script for Bowtie App
# Displays real-time metrics and status
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Clear screen
clear

echo "============================================================================="
echo "  Bowtie App Monitoring Dashboard"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================================="
echo ""

# =============================================================================
# Service Status
# =============================================================================
echo -e "${BLUE}[Service Status]${NC}"
if systemctl is-active --quiet shiny-server; then
    echo -e "  Status: ${GREEN}RUNNING${NC}"
    UPTIME=$(systemctl show shiny-server --property=ActiveEnterTimestamp --value)
    echo "  Started: $UPTIME"
else
    echo -e "  Status: ${RED}STOPPED${NC}"
fi
echo ""

# =============================================================================
# Resource Usage
# =============================================================================
echo -e "${BLUE}[Resource Usage]${NC}"

# CPU usage of shiny-server processes
if pgrep -f "shiny-server" > /dev/null; then
    CPU=$(ps aux | grep -E "[s]hiny-server|[R]script.*bowtie" | awk '{sum+=$3} END {print sum}')
    echo "  CPU Usage: ${CPU}%"

    MEM=$(ps aux | grep -E "[s]hiny-server|[R]script.*bowtie" | awk '{sum+=$4} END {print sum}')
    echo "  Memory Usage: ${MEM}%"
else
    echo -e "  ${YELLOW}No shiny-server processes running${NC}"
fi

# System memory
TOTAL_MEM=$(free -h | grep Mem | awk '{print $2}')
USED_MEM=$(free -h | grep Mem | awk '{print $3}')
echo "  System Memory: $USED_MEM / $TOTAL_MEM"

# Disk space
DISK_USAGE=$(df -h /srv/shiny-server | tail -1 | awk '{print $5}')
echo "  Disk Usage: $DISK_USAGE"
echo ""

# =============================================================================
# Active Connections
# =============================================================================
echo -e "${BLUE}[Active Connections]${NC}"
CONNECTIONS=$(netstat -an 2>/dev/null | grep :3838 | grep ESTABLISHED | wc -l || ss -an 2>/dev/null | grep :3838 | grep ESTABLISHED | wc -l)
echo "  Active Connections: $CONNECTIONS"

# List unique IP addresses
if [ $CONNECTIONS -gt 0 ]; then
    echo "  Connected IPs:"
    netstat -an 2>/dev/null | grep :3838 | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c || \
    ss -an 2>/dev/null | grep :3838 | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c
fi
echo ""

# =============================================================================
# R Processes
# =============================================================================
echo -e "${BLUE}[R Processes]${NC}"
R_PROCESSES=$(pgrep -c -f "R.*bowtie_app" || echo "0")
echo "  Active R processes: $R_PROCESSES"

if [ $R_PROCESSES -gt 0 ]; then
    echo "  Details:"
    ps aux | grep -E "[R].*bowtie_app" | awk '{printf "    PID %s - CPU: %s%% - MEM: %s%% - Time: %s\n", $2, $3, $4, $10}'
fi
echo ""

# =============================================================================
# Recent Logs
# =============================================================================
echo -e "${BLUE}[Recent Log Entries]${NC}"
if [ -d "/var/log/shiny-server/bowtie_app" ]; then
    LATEST_LOG=$(ls -t /var/log/shiny-server/bowtie_app/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ]; then
        echo "  Latest log: $LATEST_LOG"
        echo "  Last 5 entries:"
        tail -5 "$LATEST_LOG" | sed 's/^/    /'
    else
        echo -e "  ${YELLOW}No logs found${NC}"
    fi
else
    echo -e "  ${YELLOW}Log directory not found${NC}"
fi
echo ""

# =============================================================================
# Error Count
# =============================================================================
echo -e "${BLUE}[Error Summary]${NC}"
if [ -d "/var/log/shiny-server" ]; then
    ERRORS=$(grep -i "error" /var/log/shiny-server/bowtie_app/*.log 2>/dev/null | wc -l || echo "0")
    WARNINGS=$(grep -i "warning" /var/log/shiny-server/bowtie_app/*.log 2>/dev/null | wc -l || echo "0")

    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  Errors: ${RED}$ERRORS${NC}"
    else
        echo -e "  Errors: ${GREEN}$ERRORS${NC}"
    fi

    if [ "$WARNINGS" -gt 0 ]; then
        echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
    else
        echo -e "  Warnings: ${GREEN}$WARNINGS${NC}"
    fi
fi
echo ""

# =============================================================================
# Quick Actions
# =============================================================================
echo "============================================================================="
echo "Quick Actions:"
echo "  Restart:     sudo systemctl restart shiny-server"
echo "  Stop:        sudo systemctl stop shiny-server"
echo "  View logs:   tail -f /var/log/shiny-server/bowtie_app/*.log"
echo "  System logs: journalctl -u shiny-server -f"
echo "============================================================================="
