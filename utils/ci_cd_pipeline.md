# CI/CD Pipeline for Environmental Bowtie Risk Analysis
Version: 5.1.0 (Modern Framework Edition)

## Overview

This document outlines the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the Environmental Bowtie Risk Analysis application, designed to ensure code quality, automated testing, and reliable deployment.

## Pipeline Architecture

### 1. Development Workflow

```
Developer → Git Push → CI Pipeline → Automated Tests → Quality Checks → Deployment
     ↓           ↓            ↓              ↓               ↓              ↓
   Local    Version     Build &       Unit Tests    Code Quality    Production
   Testing  Control     Package       Integration   Validation      Environment
```

### 2. Automated Testing Pipeline

```bash
# Stage 1: Environment Setup
Rscript -e "install.packages(c('testthat', 'lintr', 'devtools'))"

# Stage 2: Code Quality Check
Rscript utils/code_quality_check.R

# Stage 3: Comprehensive Testing
Rscript tests/comprehensive_test_runner.R

# Stage 4: Performance Benchmarking
Rscript utils/performance_benchmark.R

# Stage 5: Application Validation
Rscript -e "source('start_app.R')" &
sleep 30  # Allow app to start
curl -f http://localhost:3838 || exit 1
```

## GitHub Actions Configuration

### `.github/workflows/ci.yml`

```yaml
name: Environmental Bowtie CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        r-version: [4.3, 4.4]

    steps:
    - uses: actions/checkout@v4

    - name: Set up R
      uses: r-lib/actions/setup-r@v2
      with:
        r-version: ${{ matrix.r-version }}

    - name: Install system dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev

    - name: Install R dependencies
      run: |
        install.packages(c("remotes", "testthat", "lintr", "devtools"))
        remotes::install_deps(dependencies = TRUE)
      shell: Rscript {0}

    - name: Check R package
      run: R CMD check .

    - name: Run code quality checks
      run: Rscript utils/code_quality_check.R

    - name: Run comprehensive tests
      run: Rscript tests/comprehensive_test_runner.R

    - name: Performance benchmarks
      run: Rscript utils/performance_benchmark.R

    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results-r${{ matrix.r-version }}
        path: |
          test_results.xml
          code_quality_report.txt
          performance_benchmark_results.txt

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v4

    - name: Deploy to staging
      run: |
        echo "Deploying to staging environment"
        # Add deployment scripts here

    - name: Deploy to production
      if: github.event_name == 'push'
      run: |
        echo "Deploying to production environment"
        # Add production deployment scripts here
```

## Quality Gates

### 1. Pre-commit Hooks

```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running pre-commit quality checks..."

# Run code quality check
Rscript utils/code_quality_check.R

# Check exit code
if [ $? -ne 0 ]; then
    echo "❌ Code quality check failed!"
    exit 1
fi

# Run quick tests
Rscript tests/test_runner.R

if [ $? -ne 0 ]; then
    echo "❌ Tests failed!"
    exit 1
fi

echo "✅ Pre-commit checks passed!"
exit 0
```

### 2. Quality Metrics Thresholds

- **Test Coverage**: Minimum 85%
- **Lint Issues**: Maximum 10 per file
- **Complexity Score**: Maximum 50 per function
- **Performance**: Response time < 2 seconds
- **Memory Usage**: < 512MB for standard operations

## Deployment Strategies

### 1. Development Environment

```bash
# Local development
Rscript start_app.R
# App available at http://localhost:3838
```

### 2. Staging Environment

```bash
# Docker deployment
docker build -t bowtie-app-staging .
docker run -d -p 8080:3838 bowtie-app-staging
```

### 3. Production Environment

```bash
# Shiny Server deployment
sudo systemctl start shiny-server
sudo systemctl enable shiny-server

# Copy application files
sudo cp -r /app/bowtie_app /srv/shiny-server/
sudo chown -R shiny:shiny /srv/shiny-server/bowtie_app
```

## Monitoring and Alerting

### 1. Application Health Checks

```bash
# Health check script
#!/bin/bash
APP_URL="http://localhost:3838"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL)

if [ $RESPONSE -eq 200 ]; then
    echo "✅ Application is healthy"
    exit 0
else
    echo "❌ Application health check failed: HTTP $RESPONSE"
    exit 1
fi
```

### 2. Performance Monitoring

```r
# Automated performance monitoring
monitor_performance <- function() {
  start_time <- Sys.time()

  # Run benchmark suite
  source("utils/performance_benchmark.R")
  results <- run_performance_benchmarks()

  end_time <- Sys.time()
  duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

  # Alert if performance degrades
  if (duration > 300) {  # 5 minutes threshold
    send_alert("Performance degradation detected")
  }

  return(results)
}
```

## Release Management

### 1. Semantic Versioning

- **Major** (X.0.0): Breaking changes, major feature releases
- **Minor** (X.Y.0): New features, backward compatible
- **Patch** (X.Y.Z): Bug fixes, minor improvements

### 2. Release Process

```bash
# 1. Update version in global.R
# 2. Run full test suite
Rscript tests/comprehensive_test_runner.R

# 3. Generate release notes
git log --oneline v5.0.0..HEAD > RELEASE_NOTES.md

# 4. Create release tag
git tag -a v5.1.0 -m "Release version 5.1.0"
git push origin v5.1.0

# 5. Deploy to production
./deploy/production_deploy.sh
```

## Environment Configuration

### 1. Development (.env.development)

```
R_ENV=development
SHINY_HOST=127.0.0.1
SHINY_PORT=3838
LOG_LEVEL=DEBUG
ENABLE_PROFILING=true
```

### 2. Production (.env.production)

```
R_ENV=production
SHINY_HOST=0.0.0.0
SHINY_PORT=3838
LOG_LEVEL=INFO
ENABLE_PROFILING=false
MAX_UPLOAD_SIZE=30MB
SESSION_TIMEOUT=3600
```

## Security Considerations

### 1. Input Validation

- All user inputs are sanitized before processing
- File uploads are restricted to approved formats
- SQL injection protection (if using databases)

### 2. Access Control

- Network-level access restrictions
- Session management and timeouts
- Secure headers configuration

### 3. Data Protection

- No sensitive data in logs
- Encrypted data transmission (HTTPS in production)
- Regular security audits

## Rollback Procedures

### 1. Application Rollback

```bash
# Quick rollback to previous version
./deploy/rollback.sh v5.0.0

# Verify rollback success
curl -f http://production-url:3838
```

### 2. Database Rollback (if applicable)

```bash
# Restore from backup
./backup/restore_database.sh backup_20240927.sql
```

## Documentation Updates

### 1. Automated Documentation

```r
# Generate API documentation
devtools::document()

# Update README with latest features
roxygen2::roxygenise()
```

### 2. Changelog Maintenance

- Automatic changelog generation from commit messages
- Release notes with feature highlights
- Breaking changes documentation

## Best Practices

1. **Commit Messages**: Follow conventional commit format
2. **Branch Strategy**: GitFlow with feature branches
3. **Code Reviews**: Mandatory for all changes
4. **Testing**: Write tests before implementing features
5. **Documentation**: Update docs with code changes

## Troubleshooting

### Common Issues

1. **Test Failures**: Check dependencies and R version compatibility
2. **Deployment Issues**: Verify environment variables and permissions
3. **Performance Problems**: Run benchmark suite and check logs
4. **Memory Leaks**: Monitor memory usage during long-running tests

### Support Contacts

- **Development Team**: development@bowtie-analysis.org
- **DevOps Team**: devops@bowtie-analysis.org
- **Emergency Contact**: emergency@bowtie-analysis.org

---

*This CI/CD pipeline documentation is maintained as part of the Environmental Bowtie Risk Analysis project. Last updated: September 2025*