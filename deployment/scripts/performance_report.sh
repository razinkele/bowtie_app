#!/bin/bash
# =============================================================================
# Performance Report Generator
# Generates a detailed performance report for the Bowtie App
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Output file
REPORT_FILE="/tmp/bowtie_performance_report_$(date +%Y%m%d_%H%M%S).txt"

# Start report
{
    echo "============================================================================="
    echo "  Bowtie App Performance Report"
    echo "  Generated: $(date)"
    echo "============================================================================="
    echo ""

    # System Information
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(lsb_release -d | cut -f2)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo ""

    # CPU Information
    echo "=== CPU Information ==="
    echo "Model: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    echo "Cores: $(nproc)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""

    # Memory Usage
    echo "=== Memory Usage ==="
    free -h
    echo ""

    # Disk Usage
    echo "=== Disk Usage ==="
    df -h /srv/shiny-server
    echo ""

    # Shiny Server Status
    echo "=== Shiny Server Status ==="
    if systemctl is-active --quiet shiny-server; then
        echo "Status: RUNNING"
        systemctl show shiny-server --property=MainPID --value | xargs -I {} echo "PID: {}"
        systemctl show shiny-server --property=ActiveEnterTimestamp --value | xargs -I {} echo "Started: {}"
    else
        echo "Status: STOPPED"
    fi
    echo ""

    # R Processes
    echo "=== R Processes ==="
    ps aux | head -1
    ps aux | grep -E "[R].*bowtie" || echo "No R processes found"
    echo ""
    echo "Total R processes: $(pgrep -c -f "R.*bowtie" || echo "0")"
    echo ""

    # Network Connections
    echo "=== Network Connections (Port 3838) ==="
    netstat -an 2>/dev/null | grep :3838 || ss -an 2>/dev/null | grep :3838
    echo ""
    echo "Active connections: $(netstat -an 2>/dev/null | grep :3838 | grep ESTABLISHED | wc -l || ss -an 2>/dev/null | grep :3838 | grep ESTABLISHED | wc -l)"
    echo ""

    # Log Summary
    echo "=== Log Summary (Last Hour) ==="
    if [ -d "/var/log/shiny-server/bowtie_app" ]; then
        echo "Log files:"
        ls -lh /var/log/shiny-server/bowtie_app/*.log 2>/dev/null || echo "No log files found"
        echo ""

        echo "Error count:"
        grep -i "error" /var/log/shiny-server/bowtie_app/*.log 2>/dev/null | wc -l
        echo ""

        echo "Warning count:"
        grep -i "warning" /var/log/shiny-server/bowtie_app/*.log 2>/dev/null | wc -l
    else
        echo "Log directory not found"
    fi
    echo ""

    # Service Logs (Last 20 lines)
    echo "=== Recent Service Logs ==="
    journalctl -u shiny-server -n 20 --no-pager
    echo ""

    # Performance Metrics
    echo "=== Performance Metrics ==="

    # CPU usage over last minute
    echo "CPU usage (1 min average): $(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)"

    # Memory usage percentage
    echo "Memory usage: $(free | grep Mem | awk '{printf "%.1f%%\n", $3/$2 * 100}')"

    # Disk I/O
    if command -v iostat &> /dev/null; then
        echo ""
        echo "Disk I/O:"
        iostat -x 1 2 | grep -A 2 "Device"
    fi
    echo ""

    # Network statistics
    echo "=== Network Statistics ==="
    if command -v netstat &> /dev/null; then
        echo "Listening ports:"
        netstat -tuln | grep LISTEN
    elif command -v ss &> /dev/null; then
        echo "Listening ports:"
        ss -tuln | grep LISTEN
    fi
    echo ""

    # Application-specific metrics
    echo "=== Application Metrics ==="
    if [ -d "/srv/shiny-server/bowtie_app" ]; then
        echo "Application size: $(du -sh /srv/shiny-server/bowtie_app | cut -f1)"
        echo "Data directory size: $(du -sh /srv/shiny-server/bowtie_app/data 2>/dev/null | cut -f1 || echo 'N/A')"
        echo "Number of R files: $(find /srv/shiny-server/bowtie_app -name "*.R" -o -name "*.r" | wc -l)"
        echo "Number of data files: $(find /srv/shiny-server/bowtie_app -name "*.xlsx" -o -name "*.csv" | wc -l)"
    fi
    echo ""

    # Configuration
    echo "=== Configuration ==="
    echo "Shiny Server config:"
    if [ -f "/etc/shiny-server/shiny-server.conf" ]; then
        grep -E "app_init_timeout|app_idle_timeout|simple_scheduler" /etc/shiny-server/shiny-server.conf | sed 's/^/  /'
    else
        echo "  Config file not found"
    fi
    echo ""

    # Recommendations
    echo "=== Recommendations ==="

    # Check memory
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100}')
    if (( $(echo "$MEM_USAGE > 80" | bc -l) )); then
        echo "⚠ High memory usage (${MEM_USAGE}%) - Consider increasing RAM or optimizing application"
    else
        echo "✓ Memory usage is acceptable"
    fi

    # Check disk
    DISK_USAGE=$(df /srv | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -gt 80 ]; then
        echo "⚠ High disk usage (${DISK_USAGE}%) - Consider cleaning up old logs or increasing disk space"
    else
        echo "✓ Disk usage is acceptable"
    fi

    # Check R processes
    R_PROCS=$(pgrep -c -f "R.*bowtie" || echo "0")
    if [ "$R_PROCS" -gt 10 ]; then
        echo "⚠ High number of R processes ($R_PROCS) - May indicate resource contention"
    else
        echo "✓ R process count is acceptable"
    fi

    echo ""
    echo "============================================================================="
    echo "  End of Report"
    echo "============================================================================="

} > "$REPORT_FILE"

# Display report
cat "$REPORT_FILE"

echo ""
echo -e "${GREEN}Report saved to: $REPORT_FILE${NC}"
echo ""
echo "To share this report:"
echo "  cat $REPORT_FILE | mail -s 'Bowtie Performance Report' admin@example.com"
echo "  or upload to your monitoring system"
