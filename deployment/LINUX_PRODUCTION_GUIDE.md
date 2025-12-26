# Linux Production Deployment Guide
**Environmental Bowtie Risk Analysis Application**
**Version: 5.3.0** | **Updated: November 2025**

---

## 📋 Table of Contents

1. [System Requirements](#system-requirements)
2. [Prerequisites Installation](#prerequisites-installation)
3. [Shiny Server Installation](#shiny-server-installation)
4. [Application Deployment](#application-deployment)
5. [Configuration](#configuration)
6. [Service Management](#service-management)
7. [Monitoring](#monitoring)
8. [Backup & Restore](#backup--restore)
9. [Troubleshooting](#troubleshooting)
10. [Performance Tuning](#performance-tuning)

---

## System Requirements

### Minimum Requirements
- **OS**: Ubuntu 20.04 LTS or later, Debian 11+, CentOS 8+
- **CPU**: 2 cores
- **RAM**: 4 GB
- **Disk**: 5 GB free space
- **Network**: Open port 3838

### Recommended for Production
- **OS**: Ubuntu 22.04 LTS
- **CPU**: 4+ cores
- **RAM**: 8+ GB
- **Disk**: 20+ GB free space (SSD)
- **Network**: Reverse proxy (Nginx) with SSL

---

## Prerequisites Installation

### 1. Update System

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2. Install R (4.4.0 or higher)

```bash
# Add R repository
sudo apt-get install -y software-properties-common dirmngr
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# Add repository
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Install R
sudo apt-get update
sudo apt-get install -y r-base r-base-dev

# Verify installation
R --version
```

### 3. Install System Dependencies

```bash
# Essential build tools
sudo apt-get install -y \
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
    git

# For network monitoring
sudo apt-get install -y net-tools
```

---

## Shiny Server Installation

### 1. Download and Install Shiny Server

```bash
# Download latest version (check https://posit.co/download/shiny-server/)
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.21.1012-amd64.deb

# Install
sudo gdebi -n shiny-server-1.5.21.1012-amd64.deb

# Verify installation
shiny-server --version
```

### 2. Start and Enable Service

```bash
# Start service
sudo systemctl start shiny-server

# Enable on boot
sudo systemctl enable shiny-server

# Check status
sudo systemctl status shiny-server
```

### 3. Verify Installation

```bash
# Check if service is running
systemctl is-active shiny-server

# Check if port 3838 is listening
netstat -tuln | grep 3838

# Test HTTP connection
curl http://localhost:3838
```

---

## Application Deployment

### 1. Pre-Deployment Check

```bash
cd /path/to/bowtie_app
sudo bash deployment/check_deployment_readiness.sh
```

This script checks:
- ✅ Root/sudo access
- ✅ Shiny Server installed
- ✅ R installation and version
- ✅ Required files present
- ✅ Directory structure
- ✅ System resources

### 2. Install R Package Dependencies

```bash
# Install packages as shiny user
sudo su - shiny -c "cd /path/to/bowtie_app && Rscript requirements.R"

# Or install system-wide
sudo Rscript /path/to/bowtie_app/requirements.R
```

### 3. Deploy Application (Automated)

```bash
cd /path/to/bowtie_app/deployment

# Full deployment with backup and dependency installation
sudo bash deploy_shiny_server.sh --install-deps --backup

# Quick deployment (no backup, no dep install)
sudo bash deploy_shiny_server.sh
```

### 4. Manual Deployment

```bash
# Create application directory
sudo mkdir -p /srv/shiny-server/bowtie_app

# Copy application files
sudo cp -r /path/to/bowtie_app/* /srv/shiny-server/bowtie_app/

# Set permissions
sudo chown -R shiny:shiny /srv/shiny-server/bowtie_app
sudo chmod -R 755 /srv/shiny-server/bowtie_app

# Create log directory
sudo mkdir -p /var/log/shiny-server/bowtie_app
sudo chown shiny:shiny /var/log/shiny-server/bowtie_app
```

---

## Configuration

### 1. Shiny Server Configuration

**Use the optimized production config:**

```bash
# Backup original config
sudo cp /etc/shiny-server/shiny-server.conf \
       /etc/shiny-server/shiny-server.conf.backup

# Install production config
sudo cp deployment/shiny-server-production.conf \
       /etc/shiny-server/shiny-server.conf

# Test configuration
shiny-server --test-config

# Restart service
sudo systemctl restart shiny-server
```

**Key configuration settings:**

```nginx
# /etc/shiny-server/shiny-server.conf
location /bowtie_app {
    app_dir /srv/shiny-server/bowtie_app;
    log_dir /var/log/shiny-server/bowtie_app;

    # Timeout settings
    app_init_timeout 180;      # 3 minutes for startup
    app_idle_timeout 3600;     # 1 hour idle timeout
    connection_timeout 30;
    read_timeout 600;          # 10 minutes for long operations

    # Session management
    reconnect true;

    # Concurrency
    simple_scheduler 10;       # Max 10 concurrent sessions
}
```

### 2. Systemd Service (Optional Enhancement)

For better process management:

```bash
# Install custom service file
sudo cp deployment/systemd/shiny-server-custom.service \
       /etc/systemd/system/shiny-server.service

# Reload systemd
sudo systemctl daemon-reload

# Restart with new config
sudo systemctl restart shiny-server
```

### 3. Firewall Configuration

```bash
# UFW (Ubuntu)
sudo ufw allow 3838/tcp
sudo ufw reload

# firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-port=3838/tcp
sudo firewall-cmd --reload
```

---

## Service Management

### Basic Commands

```bash
# Start service
sudo systemctl start shiny-server

# Stop service
sudo systemctl stop shiny-server

# Restart service
sudo systemctl restart shiny-server

# Reload configuration (without restarting)
sudo systemctl reload shiny-server

# Check status
sudo systemctl status shiny-server

# Enable on boot
sudo systemctl enable shiny-server

# Disable on boot
sudo systemctl disable shiny-server
```

### View Logs

```bash
# Application logs
tail -f /var/log/shiny-server/bowtie_app/*.log

# System logs
journalctl -u shiny-server -f

# Last 100 lines
journalctl -u shiny-server -n 100

# Logs since specific time
journalctl -u shiny-server --since "1 hour ago"
```

---

## Monitoring

### 1. Health Check Script

```bash
# Run health check
bash deployment/scripts/health_check.sh

# Add to crontab for periodic checks (every 5 minutes)
*/5 * * * * /srv/shiny-server/bowtie_app/deployment/scripts/health_check.sh
```

### 2. Monitoring Dashboard

```bash
# Real-time monitoring
bash deployment/scripts/monitor.sh

# Add as an alias for quick access
echo "alias bowtie-monitor='sudo bash /srv/shiny-server/bowtie_app/deployment/scripts/monitor.sh'" >> ~/.bashrc
source ~/.bashrc

# Then use:
bowtie-monitor
```

### 3. Resource Monitoring

```bash
# CPU and Memory usage
htop

# Disk usage
df -h /srv/shiny-server

# Network connections
netstat -an | grep :3838 | wc -l

# R process count
pgrep -c -f "R.*bowtie_app"
```

### 4. Automated Monitoring with Prometheus/Grafana (Advanced)

See `docs/MONITORING_GUIDE.md` for Prometheus + Grafana setup.

---

## Backup & Restore

### 1. Backup Script

Create `/srv/scripts/backup_bowtie.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/bowtie_app"
DATE=$(date +%Y%m%d_%H%M%S)
APP_DIR="/srv/shiny-server/bowtie_app"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup application files
tar -czf "$BACKUP_DIR/app_${DATE}.tar.gz" \
    "$APP_DIR" \
    --exclude="$APP_DIR/logs" \
    --exclude="$APP_DIR/.git"

# Backup configuration
cp /etc/shiny-server/shiny-server.conf \
   "$BACKUP_DIR/config_${DATE}.conf"

# Keep only last 30 days
find "$BACKUP_DIR" -type f -mtime +30 -delete

echo "Backup completed: $BACKUP_DIR/app_${DATE}.tar.gz"
```

Make executable and add to crontab:

```bash
chmod +x /srv/scripts/backup_bowtie.sh

# Daily backup at 2 AM
crontab -e
# Add:
0 2 * * * /srv/scripts/backup_bowtie.sh >> /var/log/bowtie_backup.log 2>&1
```

### 2. Restore from Backup

```bash
# List available backups
ls -lh /var/backups/bowtie_app/

# Restore application
sudo systemctl stop shiny-server
sudo tar -xzf /var/backups/bowtie_app/app_20250122_020000.tar.gz -C /
sudo systemctl start shiny-server

# Restore configuration
sudo cp /var/backups/bowtie_app/config_20250122_020000.conf \
       /etc/shiny-server/shiny-server.conf
sudo systemctl restart shiny-server
```

---

## Troubleshooting

### Application Won't Start

**Symptom:** Service fails to start or application not accessible

```bash
# Check service status
sudo systemctl status shiny-server

# Check logs for errors
sudo journalctl -u shiny-server -n 50

# Check application logs
tail -100 /var/log/shiny-server/bowtie_app/*.log

# Verify R packages
su - shiny -c "R -e 'library(shiny)'"

# Test configuration
shiny-server --test-config
```

### High Memory Usage

**Symptom:** Server running out of memory

```bash
# Check memory usage
free -h

# Find R processes consuming memory
ps aux | grep -E "[R]" | sort -k4 -rn | head -10

# Kill specific R process if needed
sudo kill -9 <PID>

# Restart service to clear memory
sudo systemctl restart shiny-server
```

### Connection Timeouts

**Symptom:** Users experience disconnections

```bash
# Increase timeouts in /etc/shiny-server/shiny-server.conf
app_idle_timeout 7200;    # 2 hours
connection_timeout 60;
read_timeout 900;

# Restart service
sudo systemctl restart shiny-server
```

### Port Already in Use

**Symptom:** Port 3838 already in use

```bash
# Find what's using port 3838
sudo netstat -tulpn | grep :3838
# or
sudo ss -tulpn | grep :3838

# Kill the process
sudo kill -9 <PID>

# Start shiny-server
sudo systemctl start shiny-server
```

### Permissions Issues

**Symptom:** "Permission denied" errors in logs

```bash
# Fix ownership
sudo chown -R shiny:shiny /srv/shiny-server/bowtie_app
sudo chown -R shiny:shiny /var/log/shiny-server/bowtie_app

# Fix permissions
sudo chmod -R 755 /srv/shiny-server/bowtie_app
sudo chmod -R 775 /srv/shiny-server/bowtie_app/data
sudo chmod -R 775 /var/log/shiny-server/bowtie_app
```

---

## Performance Tuning

### 1. Optimize R

Add to `/srv/shiny-server/bowtie_app/.Renviron`:

```bash
# Memory limits
R_MAX_VSIZE=8Gb

# Number of cores for parallel processing
MC_CORES=4

# Disable bytecode compilation (faster startup)
R_COMPILE_PKGS=0
```

### 2. Optimize Shiny Server

Edit `/etc/shiny-server/shiny-server.conf`:

```nginx
# Increase concurrent sessions
simple_scheduler 20;

# Optimize timeouts
app_init_timeout 180;
app_idle_timeout 3600;
connection_timeout 30;
read_timeout 600;

# Enable reconnect
reconnect true;

# Disable unnecessary features
directory_index off;
sanitize_errors true;
```

### 3. System Tuning

```bash
# Increase file descriptor limit
sudo vim /etc/security/limits.conf
# Add:
shiny soft nofile 65536
shiny hard nofile 65536

# Optimize network
sudo vim /etc/sysctl.conf
# Add:
net.core.somaxconn=1024
net.ipv4.tcp_max_syn_backlog=2048
net.ipv4.ip_local_port_range=1024 65535

# Apply changes
sudo sysctl -p
```

### 4. Database Connection Pooling (if using databases)

```r
# In global.R
library(pool)
pool <- dbPool(
  drv = RMySQL::MySQL(),
  dbname = "mydb",
  host = "localhost",
  username = "user",
  password = "password",
  maxSize = 10
)

# Use pool in server.R instead of direct connections
```

---

## Production Checklist

Before going live:

- [ ] R 4.4.0+ installed
- [ ] Shiny Server installed and running
- [ ] All R packages installed
- [ ] Application deployed to `/srv/shiny-server/bowtie_app`
- [ ] Permissions set correctly (shiny:shiny)
- [ ] Production config applied
- [ ] Firewall configured (port 3838 open)
- [ ] Health check passing
- [ ] Logs accessible and monitored
- [ ] Backup script configured
- [ ] Reverse proxy configured (if using)
- [ ] SSL certificate installed (if using HTTPS)
- [ ] Monitoring set up
- [ ] Documentation updated
- [ ] Team trained on deployment

---

## Quick Reference Commands

```bash
# Deploy
sudo bash deployment/deploy_shiny_server.sh --install-deps --backup

# Check status
sudo systemctl status shiny-server

# View logs
tail -f /var/log/shiny-server/bowtie_app/*.log

# Restart
sudo systemctl restart shiny-server

# Health check
bash deployment/scripts/health_check.sh

# Monitor
bash deployment/scripts/monitor.sh

# Backup
bash /srv/scripts/backup_bowtie.sh

# Test application
curl http://localhost:3838/bowtie_app/
```

---

## Support

- **Documentation**: `/srv/shiny-server/bowtie_app/docs/`
- **GitHub Issues**: https://github.com/razinkele/bowtie_app/issues
- **Shiny Server Docs**: https://posit.co/products/open-source/shinyserver/
- **R Shiny Docs**: https://shiny.posit.co/

---

**Last Updated:** November 22, 2025
**Version:** 5.3.0
**Maintainer:** Environmental Bowtie App Team
