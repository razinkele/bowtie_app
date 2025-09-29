# Deployment Guide - Environmental Bowtie Risk Analysis Application

**Version**: 5.2.0 (Advanced Framework Edition)
**Last Updated**: September 2025

## Table of Contents

- [Overview](#overview)
- [System Requirements](#system-requirements)
- [Local Deployment](#local-deployment)
- [Docker Deployment](#docker-deployment)
- [Production Deployment](#production-deployment)
- [Cloud Deployment](#cloud-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Troubleshooting](#troubleshooting)

## Overview

This guide provides comprehensive instructions for deploying the Environmental Bowtie Risk Analysis Application across different environments. The application supports multiple deployment scenarios from local development to enterprise production environments.

### Deployment Options

1. **Local Development**: Quick setup for development and testing
2. **Docker Containers**: Isolated, reproducible deployment
3. **Production Server**: Enterprise-grade deployment with monitoring
4. **Cloud Platforms**: Scalable cloud deployment (AWS, GCP, Azure)
5. **CI/CD Pipeline**: Automated deployment and testing

## System Requirements

### Minimum Requirements

- **Operating System**: Windows 10+, macOS 10.15+, Ubuntu 18.04+
- **R**: Version 4.3.2 or higher
- **Memory**: 4GB RAM minimum, 8GB recommended
- **Storage**: 2GB available disk space
- **Network**: Internet connection for package installation

### Recommended Requirements

- **R**: Version 4.4.3 (latest stable)
- **Memory**: 16GB RAM for production environments
- **CPU**: Multi-core processor (4+ cores recommended)
- **Storage**: SSD with 10GB available space
- **Network**: High-speed internet for optimal performance

### Additional Dependencies

#### For Docker Deployment
- **Docker**: Version 20.10+
- **Docker Compose**: Version 1.29+

#### For Production Deployment
- **Reverse Proxy**: Nginx or Apache (optional)
- **SSL Certificate**: For HTTPS deployment
- **Load Balancer**: For high-availability setups

## Local Deployment

### Quick Start (5 Minutes)

```bash
# 1. Clone the repository
git clone https://github.com/razinkele/bowtie_app.git
cd bowtie_app

# 2. Install R dependencies
Rscript requirements.R

# 3. Start the application
Rscript start_app.R
```

**Access**: http://localhost:3838

### Advanced Local Setup

#### 1. Development Environment
```bash
# Setup development environment with hot reload
source("dev_config.R")

# Start with development tools enabled
Rscript start_app.R
```

#### 2. Network Access Configuration
```r
# For network-accessible deployment
# Edit start_app.R to configure host and port
shiny::runApp(
  host = "0.0.0.0",    # Allow external connections
  port = 3838,         # Standard Shiny port
  launch.browser = FALSE
)
```

#### 3. Firewall Configuration (Windows)
```cmd
# Allow port 3838 through Windows Firewall
netsh advfirewall firewall add rule name="Shiny App" dir=in action=allow protocol=TCP localport=3838
```

### Local Testing

```bash
# Run comprehensive test suite
Rscript tests/comprehensive_test_runner.R

# Performance validation
Rscript -e "source('utils/advanced_benchmarks.R'); run_complete_performance_suite()"

# Consistency validation
Rscript -e "source('dev_config.R'); validate_dependencies(); validate_icon_usage()"
```

## Docker Deployment

### Quick Docker Setup

#### 1. Build and Run Production Container
```bash
# Build the application
docker build -t bowtie-app .

# Run production container
docker run -d -p 3838:3838 --name bowtie-app-prod bowtie-app
```

**Access**: http://localhost:3838

#### 2. Using Docker Compose (Recommended)
```bash
# Start production environment
docker-compose up -d bowtie-app

# View logs
docker-compose logs -f bowtie-app
```

### Development with Docker

```bash
# Start development environment with hot reload
docker-compose --profile dev up bowtie-app-dev

# Access development environment
# http://localhost:3839
```

### Container Management

#### Health Monitoring
```bash
# Check container health
docker ps

# View detailed health status
docker inspect bowtie-app-prod | grep Health -A 10
```

#### Resource Monitoring
```bash
# Monitor resource usage
docker stats bowtie-app-prod

# View container logs
docker logs bowtie-app-prod
```

#### Container Updates
```bash
# Pull latest code and rebuild
git pull origin main
docker-compose build bowtie-app
docker-compose up -d bowtie-app
```

### Multi-Service Deployment

#### Full Stack with Monitoring
```bash
# Start all services including monitoring
docker-compose --profile production up -d

# Services included:
# - bowtie-app: Main application
# - nginx: Load balancer
# - performance-monitor: Real-time monitoring
```

#### Load Balancing Setup
```bash
# Start with Nginx load balancer
docker-compose --profile loadbalancer up -d

# Configure SSL (optional)
# Place SSL certificates in nginx/ssl/
```

## Production Deployment

### Server Preparation

#### 1. System Setup (Ubuntu 20.04+)
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required system packages
sudo apt install -y software-properties-common dirmngr

# Add R repository
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Install R
sudo apt install -y r-base r-base-dev

# Install system dependencies
sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev libgit2-dev
```

#### 2. Application Deployment
```bash
# Create application user
sudo useradd -m -s /bin/bash shiny-app
sudo usermod -a -G sudo shiny-app

# Switch to application user
sudo su - shiny-app

# Clone and setup application
git clone https://github.com/razinkele/bowtie_app.git
cd bowtie_app

# Install R dependencies
Rscript requirements.R

# Setup as service (see systemd configuration below)
```

### Systemd Service Configuration

#### 1. Create Service File
```bash
sudo nano /etc/systemd/system/bowtie-app.service
```

```ini
[Unit]
Description=Environmental Bowtie Risk Analysis Application
After=network.target

[Service]
Type=simple
User=shiny-app
Group=shiny-app
WorkingDirectory=/home/shiny-app/bowtie_app
ExecStart=/usr/bin/Rscript start_app.R
Restart=always
RestartSec=10
Environment=SHINY_ENV=production
Environment=R_LIBS_USER=/home/shiny-app/R/library

[Install]
WantedBy=multi-user.target
```

#### 2. Enable and Start Service
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable auto-start
sudo systemctl enable bowtie-app

# Start service
sudo systemctl start bowtie-app

# Check status
sudo systemctl status bowtie-app
```

### Nginx Reverse Proxy (Optional)

#### 1. Install and Configure Nginx
```bash
# Install Nginx
sudo apt install -y nginx

# Create configuration
sudo nano /etc/nginx/sites-available/bowtie-app
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3838;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

#### 2. Enable Configuration
```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/bowtie-app /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### SSL Configuration (HTTPS)

#### Using Let's Encrypt (Recommended)
```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal setup (already configured by certbot)
sudo systemctl status certbot.timer
```

## Cloud Deployment

### AWS Deployment

#### 1. EC2 Instance Setup
```bash
# Launch Ubuntu 20.04 instance (t3.medium recommended)
# Configure security group: Allow HTTP (80), HTTPS (443), SSH (22)

# Connect and setup
ssh -i your-key.pem ubuntu@your-instance-ip

# Follow production deployment steps above
```

#### 2. Elastic Load Balancer (Optional)
```bash
# Create Application Load Balancer
# Target: EC2 instance on port 3838
# Health check: HTTP /
```

#### 3. RDS Database (Future Enhancement)
```bash
# For future database integration
# Create PostgreSQL RDS instance
# Configure security groups for database access
```

### Google Cloud Platform

#### 1. Compute Engine Deployment
```bash
# Create VM instance
gcloud compute instances create bowtie-app-vm \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=e2-medium \
    --tags=http-server,https-server

# SSH and setup
gcloud compute ssh bowtie-app-vm
```

#### 2. Container Deployment (Cloud Run)
```bash
# Build and push container
docker build -t gcr.io/your-project/bowtie-app .
docker push gcr.io/your-project/bowtie-app

# Deploy to Cloud Run
gcloud run deploy bowtie-app \
    --image gcr.io/your-project/bowtie-app \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated
```

### Azure Deployment

#### 1. Container Instances
```bash
# Create resource group
az group create --name bowtie-app-rg --location eastus

# Deploy container
az container create \
    --resource-group bowtie-app-rg \
    --name bowtie-app \
    --image your-registry/bowtie-app:latest \
    --dns-name-label bowtie-app-unique \
    --ports 3838
```

#### 2. App Service Deployment
```bash
# Create App Service plan
az appservice plan create \
    --name bowtie-app-plan \
    --resource-group bowtie-app-rg \
    --sku B1 \
    --is-linux

# Create web app
az webapp create \
    --resource-group bowtie-app-rg \
    --plan bowtie-app-plan \
    --name bowtie-app-unique \
    --deployment-container-image-name your-registry/bowtie-app:latest
```

## CI/CD Pipeline

### GitHub Actions Integration

The application includes automated CI/CD pipeline with GitHub Actions:

#### Pipeline Features
- **Consistency Validation**: Automated checking of architectural improvements
- **Multi-version Testing**: R 4.3.2 and 4.4.3 compatibility testing
- **Performance Testing**: Automated performance regression detection
- **Security Analysis**: Vulnerability scanning and code quality checks
- **Deployment Preparation**: Automated deployment package creation

#### Deployment Workflow
```yaml
# Trigger: Push to main branch
# Steps:
1. Consistency checks and validation
2. Comprehensive testing suite
3. Performance regression testing
4. Security analysis
5. Docker image build and push
6. Deployment package creation
```

### Automated Deployment

#### 1. Setup GitHub Secrets
```bash
# Required secrets for deployment:
DOCKER_USERNAME     # Docker Hub username
DOCKER_PASSWORD     # Docker Hub password
SERVER_HOST         # Production server IP
SERVER_USER         # SSH username
SERVER_SSH_KEY      # Private SSH key
```

#### 2. Deploy Configuration
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd bowtie_app
            git pull origin main
            docker-compose build
            docker-compose up -d
```

### Deployment Verification

#### Health Checks
```bash
# Verify deployment
curl -f http://your-server:3838/ || exit 1

# Check application logs
docker-compose logs bowtie-app

# Performance validation
curl -s http://your-server:3838/health | jq .
```

## Monitoring and Maintenance

### Application Monitoring

#### 1. Health Monitoring
```bash
# Docker health checks
docker ps --filter "name=bowtie-app" --format "table {{.Names}}\t{{.Status}}"

# Application logs
docker logs -f bowtie-app-prod
```

#### 2. Performance Monitoring
```bash
# Real-time performance monitoring
docker-compose --profile monitoring up performance-monitor

# Resource usage
docker stats bowtie-app-prod
```

#### 3. Log Management
```bash
# Rotate logs
docker run --rm -v /var/lib/docker/containers:/var/lib/docker/containers logrotate /etc/logrotate.conf

# Centralized logging (optional)
# Configure ELK stack or similar
```

### Backup and Recovery

#### 1. Data Backup
```bash
# Backup application data
docker exec bowtie-app-prod tar -czf /tmp/backup.tar.gz /srv/shiny-server/bowtie_app/data

# Copy backup
docker cp bowtie-app-prod:/tmp/backup.tar.gz ./backup-$(date +%Y%m%d).tar.gz
```

#### 2. Configuration Backup
```bash
# Backup Docker Compose configuration
cp docker-compose.yml docker-compose.yml.bak

# Backup environment files
cp .env .env.bak
```

### Updates and Maintenance

#### 1. Application Updates
```bash
# Pull latest changes
git pull origin main

# Update containers
docker-compose build
docker-compose up -d

# Verify update
curl -f http://localhost:3838/
```

#### 2. System Maintenance
```bash
# Update R packages
Rscript -e "update.packages(ask = FALSE)"

# Clean Docker resources
docker system prune -f

# Update system packages
sudo apt update && sudo apt upgrade -y
```

#### 3. Performance Optimization
```bash
# Run performance analysis
Rscript -e "source('utils/advanced_benchmarks.R'); run_complete_performance_suite()"

# Check for performance regressions
Rscript -e "source('utils/advanced_benchmarks.R'); detect_performance_regression()"
```

## Troubleshooting

### Common Issues

#### 1. Application Won't Start
```bash
# Check R dependencies
Rscript -e "missing_packages <- setdiff(readLines('requirements.txt'), rownames(installed.packages())); if(length(missing_packages) > 0) { print(paste('Missing:', paste(missing_packages, collapse=', '))) }"

# Check port availability
netstat -tulpn | grep :3838

# Check system resources
free -h
df -h
```

#### 2. Performance Issues
```bash
# Monitor memory usage
free -h
ps aux | grep R

# Check disk space
df -h

# Monitor network
netstat -i
```

#### 3. Container Issues
```bash
# Check container logs
docker logs bowtie-app-prod

# Inspect container
docker inspect bowtie-app-prod

# Restart container
docker-compose restart bowtie-app
```

#### 4. Database Connection Issues (Future)
```bash
# Test database connectivity
Rscript -e "library(DBI); con <- dbConnect(RPostgreSQL::PostgreSQL(), host='localhost'); dbDisconnect(con)"
```

### Error Resolution

#### R Package Installation Errors
```bash
# Install system dependencies
sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev

# Reinstall problematic packages
Rscript -e "remove.packages('problematic_package'); install.packages('problematic_package')"
```

#### Permission Issues
```bash
# Fix file permissions
sudo chown -R shiny-app:shiny-app /home/shiny-app/bowtie_app
chmod +x start_app.R
```

#### Network Access Issues
```bash
# Check firewall
sudo ufw status

# Test port accessibility
telnet localhost 3838
```

### Getting Help

#### Support Resources
- **GitHub Issues**: https://github.com/razinkele/bowtie_app/issues
- **Documentation**: See `docs/` directory
- **API Reference**: `docs/API_REFERENCE.md`
- **Development Guide**: `docs/DEVELOPMENT_GUIDE.md`

#### Diagnostic Information
When reporting issues, include:
- Operating system and version
- R version (`R.version.string`)
- Application version (5.2.0)
- Error messages and logs
- Steps to reproduce the issue

---

**Note**: This deployment guide is regularly updated. For the latest version, always refer to the documentation in the GitHub repository.