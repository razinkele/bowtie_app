# Deployment Framework - README
**Environmental Bowtie Risk Analysis Application**
**Version: 5.3.0** | **Updated: November 2025**

---

## 📁 Directory Structure

```
deployment/
├── README_DEPLOYMENT.md              # This file
├── LINUX_PRODUCTION_GUIDE.md         # Comprehensive Linux deployment guide
├── DEPLOYMENT_GUIDE.md                # General deployment guide (all platforms)
├── shiny-server.conf                  # Basic Shiny Server configuration
├── shiny-server-production.conf       # Production-optimized configuration
├── deploy_shiny_server.sh             # Main deployment script
├── check_deployment_readiness.sh      # Pre-deployment validation
├── systemd/
│   └── shiny-server-custom.service    # Enhanced systemd service file
├── scripts/
│   ├── quick_start.sh                 # One-command deployment
│   ├── health_check.sh                # Application health check
│   ├── monitor.sh                     # Real-time monitoring dashboard
│   └── performance_report.sh          # Detailed performance analysis
├── nginx/
│   └── nginx.conf                     # Reverse proxy configuration
├── Dockerfile                         # Docker container configuration
└── docker-compose.yml                 # Docker Compose orchestration
```

---

## 🚀 Quick Start

### For Ubuntu/Debian Linux (Production)

**One-command deployment:**

```bash
cd deployment
sudo bash scripts/quick_start.sh
```

This will:
1. Update system
2. Install R (4.4.0+)
3. Install system dependencies
4. Install Shiny Server
5. Deploy application
6. Run health check

**Manual deployment:**

```bash
# 1. Check readiness
sudo bash check_deployment_readiness.sh

# 2. Deploy
sudo bash deploy_shiny_server.sh --install-deps --backup

# 3. Verify
bash scripts/health_check.sh
```

### For Development

```bash
# From project root
Rscript start_app.R
```

Access at: `http://localhost:3838`

---

## 📖 Documentation

### Main Guides

1. **[LINUX_PRODUCTION_GUIDE.md](LINUX_PRODUCTION_GUIDE.md)** - **RECOMMENDED**
   - Complete Linux production deployment
   - System requirements
   - Installation steps
   - Configuration
   - Monitoring
   - Troubleshooting

2. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)**
   - Multi-platform deployment
   - Docker deployment
   - Cloud deployment (AWS, Azure, GCP)
   - Development setup

### Quick References

- **Deployment Checklist**: See section in LINUX_PRODUCTION_GUIDE.md
- **Troubleshooting**: See section in LINUX_PRODUCTION_GUIDE.md
- **Performance Tuning**: See section in LINUX_PRODUCTION_GUIDE.md

---

## 🔧 Configuration Files

### Shiny Server Configurations

#### shiny-server.conf (Basic)
- Minimal configuration
- Good for development/testing
- Use for quick setup

#### shiny-server-production.conf (Production)
- Optimized for production
- Extended timeouts for Bayesian networks
- Multiple concurrent users
- Enhanced logging

**Install production config:**

```bash
sudo cp shiny-server-production.conf /etc/shiny-server/shiny-server.conf
sudo systemctl restart shiny-server
```

### Systemd Service

Enhanced service file with:
- Resource limits
- Security hardening
- Better restart policies

**Install:**

```bash
sudo cp systemd/shiny-server-custom.service /etc/systemd/system/shiny-server.service
sudo systemctl daemon-reload
sudo systemctl restart shiny-server
```

---

## 🛠️ Scripts Reference

### Deployment Scripts

#### deploy_shiny_server.sh
Main deployment script with full control.

```bash
# Full deployment
sudo bash deploy_shiny_server.sh --install-deps --backup

# Quick update (no deps, no backup)
sudo bash deploy_shiny_server.sh --no-restart

# Custom app name
sudo bash deploy_shiny_server.sh --app-name my_bowtie_app
```

**Options:**
- `--app-name NAME` - Set custom application name
- `--install-deps` - Install/update R dependencies
- `--backup` - Create backup before deployment
- `--no-restart` - Skip service restart
- `--help` - Show help

#### check_deployment_readiness.sh
Pre-deployment validation.

```bash
sudo bash check_deployment_readiness.sh
```

**Checks:**
- Root/sudo access
- Shiny Server installed
- R version (>= 4.3.0)
- Required files present
- System resources
- Network ports

#### scripts/quick_start.sh
One-command deployment for new installations.

```bash
sudo bash scripts/quick_start.sh
```

**What it does:**
1. Installs R
2. Installs system dependencies
3. Installs Shiny Server
4. Deploys application
5. Runs health check

---

### Monitoring Scripts

#### scripts/health_check.sh
Quick application health check.

```bash
bash scripts/health_check.sh
```

**Checks:**
- Port 3838 listening
- HTTP response (200 OK)
- Service status

**Exit codes:**
- 0 = Healthy
- 1 = Unhealthy

**Use in cron:**

```bash
# Check every 5 minutes
*/5 * * * * /srv/shiny-server/bowtie_app/deployment/scripts/health_check.sh
```

#### scripts/monitor.sh
Real-time monitoring dashboard.

```bash
bash scripts/monitor.sh
```

**Displays:**
- Service status & uptime
- Resource usage (CPU, RAM, Disk)
- Active connections
- R process details
- Recent log entries
- Error/warning counts

**Add as alias:**

```bash
echo "alias bowtie-monitor='sudo bash /srv/shiny-server/bowtie_app/deployment/scripts/monitor.sh'" >> ~/.bashrc
```

#### scripts/performance_report.sh
Detailed performance analysis.

```bash
bash scripts/performance_report.sh
```

**Generates report with:**
- System information
- CPU/Memory/Disk metrics
- Service status
- Network connections
- Log analysis
- Performance recommendations

**Report saved to:** `/tmp/bowtie_performance_report_TIMESTAMP.txt`

---

## 🐳 Docker Deployment

### Using Docker Compose

```bash
# Start
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

### Manual Docker

```bash
# Build
docker build -t bowtie-app:5.3.0 -f Dockerfile ..

# Run
docker run -d \
  --name bowtie-app \
  -p 3838:3838 \
  -v $(pwd)/data:/srv/shiny-server/bowtie_app/data \
  bowtie-app:5.3.0

# Logs
docker logs -f bowtie-app
```

---

## 🔍 Troubleshooting

### Quick Diagnostics

```bash
# Check service
sudo systemctl status shiny-server

# View logs
tail -f /var/log/shiny-server/bowtie_app/*.log
journalctl -u shiny-server -f

# Test connection
curl http://localhost:3838/bowtie_app/

# Check resources
bash scripts/monitor.sh
```

### Common Issues

#### Service won't start
```bash
# Check logs
sudo journalctl -u shiny-server -n 50

# Test config
shiny-server --test-config

# Verify R packages
su - shiny -c "R -e 'library(shiny)'"
```

#### High memory usage
```bash
# Find memory hogs
ps aux | grep [R] | sort -k4 -rn | head -5

# Restart service
sudo systemctl restart shiny-server
```

#### Port already in use
```bash
# Find process
sudo netstat -tulpn | grep :3838

# Kill process
sudo kill -9 <PID>
```

**Full troubleshooting guide:** See LINUX_PRODUCTION_GUIDE.md

---

## 📊 Monitoring & Maintenance

### Daily

```bash
# Health check
bash scripts/health_check.sh

# Resource check
bash scripts/monitor.sh
```

### Weekly

```bash
# Performance report
bash scripts/performance_report.sh

# Log cleanup
find /var/log/shiny-server -type f -mtime +30 -delete
```

### Monthly

```bash
# Update packages
Rscript requirements.R

# Full deployment
sudo bash deploy_shiny_server.sh --install-deps --backup
```

---

## 🔒 Security

### Best Practices

1. **Run as non-root:** Service runs as `shiny` user
2. **Firewall:** Only expose port 3838 (or use reverse proxy)
3. **Updates:** Keep R and packages updated
4. **Backups:** Daily automated backups
5. **Logging:** Monitor logs for suspicious activity
6. **SSL:** Use Nginx reverse proxy with SSL certificates

### Firewall Configuration

```bash
# UFW (Ubuntu)
sudo ufw allow 3838/tcp
sudo ufw enable

# firewalld (CentOS)
sudo firewall-cmd --permanent --add-port=3838/tcp
sudo firewall-cmd --reload
```

---

## 📞 Support

### Resources

- **Documentation:** `/docs` directory
- **GitHub:** https://github.com/razinkele/bowtie_app
- **Issues:** https://github.com/razinkele/bowtie_app/issues
- **Shiny Server Docs:** https://posit.co/products/open-source/shinyserver/

### Getting Help

1. Check logs: `tail -f /var/log/shiny-server/bowtie_app/*.log`
2. Run diagnostics: `bash scripts/monitor.sh`
3. Review troubleshooting guide: LINUX_PRODUCTION_GUIDE.md
4. Open GitHub issue with:
   - System info (`lsb_release -a`)
   - R version (`R --version`)
   - Error logs
   - Steps to reproduce

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.3.0 | Nov 2025 | Enhanced deployment framework, production configs |
| 5.2.0 | Nov 2025 | Updated deployment scripts, added monitoring |
| 5.1.0 | Nov 2025 | Initial deployment framework |

---

## 🎯 Next Steps

After deployment:

1. ✅ Verify deployment: `bash scripts/health_check.sh`
2. ✅ Set up monitoring: Add health check to cron
3. ✅ Configure backups: Set up daily backup script
4. ✅ Set up reverse proxy (optional): Use Nginx with SSL
5. ✅ Configure monitoring (optional): Prometheus + Grafana
6. ✅ Train team: Share LINUX_PRODUCTION_GUIDE.md

---

**Last Updated:** November 22, 2025
**Version:** 5.3.0
**Maintainer:** Environmental Bowtie App Team
