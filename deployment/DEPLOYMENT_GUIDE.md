# Environmental Bowtie Risk Analysis - Deployment Guide
**Version: 5.4.0** | **Updated: January 2026**

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Deployment Options](#deployment-options)
4. [Local Development](#local-development)
5. [Production Deployment](#production-deployment)
6. [Docker Deployment](#docker-deployment)
7. [Cloud Deployment](#cloud-deployment)
8. [Troubleshooting](#troubleshooting)
9. [Maintenance](#maintenance)

---

## Overview

This guide covers all deployment scenarios for the Environmental Bowtie Risk Analysis application, a Shiny-based web application for environmental risk assessment with Bayesian network analysis.

**Key Features:**
- Interactive bowtie diagrams
- Bayesian network analysis
- Guided workflow wizard
- Multi-language support (EN/FR)
- Risk matrix visualization
- Comprehensive reporting

---

## Prerequisites

### System Requirements

**Minimum:**
- CPU: 2 cores
- RAM: 4 GB
- Storage: 2 GB free space
- OS: Linux (Ubuntu 20.04+), macOS, Windows 10+

**Recommended:**
- CPU: 4+ cores
- RAM: 8+ GB
- Storage: 5+ GB free space
- OS: Linux (Ubuntu 22.04 LTS)

### Software Dependencies

**Required:**
- R 4.4.0 or higher
- R packages (see `requirements.R`)
- Shiny Server (for production) or RStudio (for development)

**Optional:**
- Docker & Docker Compose
- Nginx (reverse proxy)
- SSL certificates

---

## Deployment Options

### 1. Local Development
- Quick testing and development
- No external dependencies
- Single user access

### 2. Shiny Server (Production)
- Multi-user support
- Production-ready
- Requires server setup

### 3. Docker Container
- Isolated environment
- Easy scaling
- Cross-platform

### 4. Cloud Platforms
- shinyapps.io
- AWS/Azure/GCP
- High availability

---

## Local Development

### Quick Start

```r
# 1. Clone repository
git clone https://github.com/razinkele/bowtie_app.git
cd bowtie_app

# 2. Install dependencies
Rscript requirements.R

# 3. Run application
Rscript start_app.R
```

### Using RStudio

1. Open `bowtie_app.Rproj` in RStudio
2. Install packages: `source("requirements.R")`
3. Open `app.R` and click "Run App"
4. Access at: `http://localhost:3838`

### Manual Package Installation

```r
# Core packages
install.packages(c("shiny", "bslib", "DT", "readxl", "openxlsx"))

# Visualization
install.packages(c("ggplot2", "plotly", "visNetwork"))

# Bayesian networks
install.packages(c("bnlearn", "igraph"))

# BioConductor packages
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(c("gRain", "Rgraphviz", "graph"))
```

---

## Production Deployment

### Shiny Server on Linux

#### 1. Install Shiny Server

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y r-base

# Install Shiny Server
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.21.1012-amd64.deb
sudo gdebi shiny-server-1.5.21.1012-amd64.deb
```

#### 2. Deploy Application

```bash
# Copy application files
sudo mkdir -p /srv/shiny-server/bowtie_app
sudo cp -r * /srv/shiny-server/bowtie_app/
sudo chown -R shiny:shiny /srv/shiny-server/bowtie_app

# Install R packages
cd /srv/shiny-server/bowtie_app
sudo su - -c "R -e \"source('/srv/shiny-server/bowtie_app/requirements.R')\""
```

#### 3. Configure Shiny Server

Edit `/etc/shiny-server/shiny-server.conf`:

```nginx
# Shiny Server Configuration
run_as shiny;

server {
  listen 3838;

  # Define location for bowtie app
  location /bowtie {
    app_dir /srv/shiny-server/bowtie_app;
    
    # Logs
    log_dir /var/log/shiny-server;
    
    # Connection settings
    app_idle_timeout 600;
    app_init_timeout 120;
  }
}
```

#### 4. Start Service

```bash
sudo systemctl restart shiny-server
sudo systemctl enable shiny-server
sudo systemctl status shiny-server
```

Access: `http://your-server:3838/bowtie`

### Nginx Reverse Proxy (Optional)

For HTTPS and custom domain:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/ssl/certs/your-cert.crt;
    ssl_certificate_key /etc/ssl/private/your-key.key;

    location / {
        proxy_pass http://localhost:3838;
        proxy_redirect / $scheme://$host/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 20d;
        proxy_buffering off;
    }
}
```

---

## Docker Deployment

### Using Docker Compose (Recommended)

#### 1. Build and Run

```bash
cd deployment
docker-compose up -d
```

#### 2. Access Application

- Application: `http://localhost:3838`
- Logs: `docker-compose logs -f`

#### 3. Stop Application

```bash
docker-compose down
```

### Manual Docker Build

```bash
# Build image
docker build -t bowtie-app:5.1.0 -f deployment/Dockerfile .

# Run container
docker run -d \
  --name bowtie-app \
  -p 3838:3838 \
  -v $(pwd)/data:/srv/shiny-server/bowtie_app/data \
  bowtie-app:5.1.0
```

### Docker Image Management

```bash
# View logs
docker logs -f bowtie-app

# Enter container
docker exec -it bowtie-app /bin/bash

# Stop container
docker stop bowtie-app

# Remove container
docker rm bowtie-app

# Remove image
docker rmi bowtie-app:5.1.0
```

---

## Cloud Deployment

### ShinyApps.io

```r
# Install rsconnect
install.packages("rsconnect")

# Configure account
rsconnect::setAccountInfo(
  name = "your-account",
  token = "your-token",
  secret = "your-secret"
)

# Deploy
rsconnect::deployApp(
  appDir = ".",
  appName = "environmental-bowtie-analysis",
  appTitle = "Environmental Bowtie Risk Analysis"
)
```

### AWS EC2

1. Launch Ubuntu EC2 instance
2. Install R and Shiny Server (see Production Deployment)
3. Configure security group (port 3838)
4. Deploy application files
5. Set up Elastic IP (optional)

### Azure Web Apps

```bash
# Using Azure CLI
az webapp up \
  --name bowtie-analysis \
  --resource-group myResourceGroup \
  --runtime "R|4.4"
```

### Google Cloud Run

```bash
# Build and push image
gcloud builds submit --tag gcr.io/PROJECT-ID/bowtie-app

# Deploy
gcloud run deploy bowtie-app \
  --image gcr.io/PROJECT-ID/bowtie-app \
  --platform managed \
  --port 3838 \
  --allow-unauthenticated
```

---

## Troubleshooting

### Common Issues

#### Application won't start

**Problem:** Missing packages or dependencies

**Solution:**
```bash
# Check R packages
Rscript -e "source('requirements.R')"

# Check system dependencies
sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev
```

#### High memory usage

**Problem:** Large datasets or memory leaks

**Solution:**
```r
# Optimize in server.R
options(shiny.maxRequestSize = 50*1024^2)  # Limit upload size

# Use reactive debouncing
observe({...}) %>% debounce(1000)
```

#### Slow loading times

**Problem:** Package loading overhead

**Solution:**
```r
# Preload packages in global.R
library(shiny)
library(bslib)
# ... other packages

# Cache data
vocabulary_data <- load_vocabulary()  # Only once
```

#### Connection timeout

**Problem:** Long-running computations

**Solution:**
```nginx
# In shiny-server.conf
app_init_timeout 120;
app_idle_timeout 600;
```

### Logs and Debugging

```bash
# Shiny Server logs
tail -f /var/log/shiny-server.log
tail -f /var/log/shiny-server/bowtie_app-*.log

# Docker logs
docker-compose logs -f

# R session logs
R CMD BATCH script.R output.log
```

---

## Maintenance

### Regular Tasks

#### Daily
- Monitor application logs
- Check system resources (CPU, RAM, disk)

#### Weekly
- Review user activity
- Backup data files
- Update vocabulary files

#### Monthly
- Update R packages
- Review security updates
- Performance optimization

### Backup Strategy

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backups/bowtie_app"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup data files
tar -czf "$BACKUP_DIR/data_$DATE.tar.gz" \
  /srv/shiny-server/bowtie_app/*.xlsx \
  /srv/shiny-server/bowtie_app/data/

# Backup configurations
cp /etc/shiny-server/shiny-server.conf "$BACKUP_DIR/config_$DATE.conf"

# Keep last 30 days
find "$BACKUP_DIR" -mtime +30 -delete
```

### Update Procedure

```bash
# 1. Backup current version
sudo tar -czf /tmp/bowtie_app_backup.tar.gz /srv/shiny-server/bowtie_app

# 2. Pull latest changes
cd /path/to/repo
git pull origin main

# 3. Update packages
Rscript requirements.R

# 4. Copy updated files
sudo cp -r * /srv/shiny-server/bowtie_app/

# 5. Restart service
sudo systemctl restart shiny-server

# 6. Verify
curl http://localhost:3838/bowtie
```

### Monitoring

#### System Monitoring

```bash
# CPU and Memory
htop

# Disk usage
df -h

# Network
netstat -tuln | grep 3838
```

#### Application Monitoring

```r
# Add to server.R
observe({
  cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), 
      "- Active connections:", 
      length(session$clientData$url), "\n")
})
```

---

## Security Considerations

### Best Practices

1. **Update regularly** - Keep R and packages up to date
2. **Use HTTPS** - Configure SSL certificates
3. **Limit access** - Implement authentication if needed
4. **Validate inputs** - Sanitize user inputs
5. **Backup data** - Regular automated backups
6. **Monitor logs** - Check for suspicious activity

### Authentication (Optional)

```r
# Add to server.R
if (!is.null(session$user)) {
  # User authenticated
} else {
  # Redirect to login
}
```

---

## Support and Resources

- **Documentation:** `/docs` directory
- **GitHub Issues:** https://github.com/razinkele/bowtie_app/issues
- **R Shiny Docs:** https://shiny.posit.co/
- **Docker Docs:** https://docs.docker.com/

---

**Last Updated:** January 6, 2026
**Version:** 5.4.0
**Maintainer:** Environmental Bowtie App Team
