# =============================================================================
# Continuous Integration Test Configuration
# Version: 1.0.0
# Description: CI/CD pipeline configuration for automated testing
# =============================================================================

# This file can be used with GitHub Actions, GitLab CI, or Jenkins

# =============================================================================
# GITHUB ACTIONS WORKFLOW
# =============================================================================

# Save as: .github/workflows/test.yml

github_actions_config <- '
name: Guided Workflow Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  schedule:
    # Run tests daily at 2 AM UTC
    - cron: "0 2 * * *"

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        r-version: ["4.3", "4.4", "4.5"]
        
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup R
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: ${{ matrix.r-version }}
          
      - name: Install system dependencies (Ubuntu)
        if: runner.os == \"Linux\"
        run: |
          sudo apt-get update
          sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev
          
      - name: Install R packages
        run: |
          install.packages(c("shiny", "bslib", "DT", "dplyr", "testthat", 
                           "htmltools", "microbenchmark"))
        shell: Rscript {0}
        
      - name: Run unit tests
        run: Rscript tests/run_guided_workflow_tests.R
        
      - name: Generate test report
        if: always()
        run: Rscript tests/generate_test_report.R
        
      - name: Upload test report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-report-${{ matrix.os }}-r${{ matrix.r-version }}
          path: tests/reports/*.html
          
      - name: Comment PR with results
        if: github.event_name == \"pull_request\"
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: \"✅ Guided Workflow tests completed on ${{ matrix.os }} with R ${{ matrix.r-version }}\"
            })
'

# =============================================================================
# GITLAB CI CONFIGURATION
# =============================================================================

# Save as: .gitlab-ci.yml

gitlab_ci_config <- '
image: rocker/r-ver:4.5

stages:
  - test
  - report
  - deploy

variables:
  R_LIBS_USER: "$CI_PROJECT_DIR/rlib"

before_script:
  - mkdir -p $R_LIBS_USER
  - R -e "install.packages(c(\"shiny\", \"bslib\", \"DT\", \"dplyr\", \"testthat\", \"htmltools\", \"microbenchmark\"), repos=\"https://cloud.r-project.org\")"

test:unit:
  stage: test
  script:
    - Rscript tests/run_guided_workflow_tests.R
  artifacts:
    when: always
    paths:
      - tests/reports/
    expire_in: 30 days

test:integration:
  stage: test
  script:
    - Rscript -e "testthat::test_file(\"tests/testthat/test-guided-workflow-integration.R\")"
  allow_failure: false

test:performance:
  stage: test
  script:
    - Rscript -e "testthat::test_file(\"tests/testthat/test-guided-workflow-performance.R\")"
  allow_failure: true  # Performance tests may fail on slower CI runners

generate_report:
  stage: report
  script:
    - Rscript tests/generate_test_report.R
  artifacts:
    paths:
      - tests/reports/*.html
    expire_in: 90 days
  dependencies:
    - test:unit
    - test:integration
    - test:performance
'

# =============================================================================
# JENKINS PIPELINE
# =============================================================================

# Save as: Jenkinsfile

jenkins_config <- '
pipeline {
    agent {
        docker {
            image "rocker/r-ver:4.5"
        }
    }
    
    triggers {
        cron("H 2 * * *")  // Run daily at 2 AM
        pollSCM("H/15 * * * *")  // Check for changes every 15 minutes
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: "30"))
        timeout(time: 30, unit: "MINUTES")
    }
    
    stages {
        stage("Setup") {
            steps {
                sh """
                    R -e "install.packages(c(\"shiny\", \"bslib\", \"DT\", \"dplyr\", \"testthat\", \"htmltools\", \"microbenchmark\"))"
                """
            }
        }
        
        stage("Unit Tests") {
            steps {
                sh "Rscript tests/run_guided_workflow_tests.R"
            }
        }
        
        stage("Integration Tests") {
            steps {
                sh "Rscript -e \"testthat::test_file(\"tests/testthat/test-guided-workflow-integration.R\")\""
            }
        }
        
        stage("Performance Tests") {
            steps {
                sh "Rscript -e \"testthat::test_file(\"tests/testthat/test-guided-workflow-performance.R\")\""
            }
        }
        
        stage("Generate Report") {
            steps {
                sh "Rscript tests/generate_test_report.R"
            }
        }
    }
    
    post {
        always {
            publishHTML([
                reportDir: "tests/reports",
                reportFiles: "test_report_*.html",
                reportName: "Test Report"
            ])
        }
        success {
            echo "✅ All tests passed!"
        }
        failure {
            echo "❌ Tests failed!"
            emailext (
                subject: "Guided Workflow Tests Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Check console output at ${env.BUILD_URL}",
                to: "dev-team@example.com"
            )
        }
    }
}
'

# =============================================================================
# DOCKER COMPOSE FOR LOCAL CI TESTING
# =============================================================================

# Save as: docker-compose.test.yml

docker_compose_config <- '
version: "3.8"

services:
  test-runner:
    image: rocker/r-ver:4.5
    working_dir: /app
    volumes:
      - .:/app
    command: >
      sh -c "
        R -e \"install.packages(c(\'shiny\', \'bslib\', \'DT\', \'dplyr\', \'testthat\', \'htmltools\', \'microbenchmark\'))\" &&
        Rscript tests/run_guided_workflow_tests.R &&
        Rscript tests/generate_test_report.R
      "
    environment:
      - R_LIBS_USER=/app/rlib
'

# =============================================================================
# MAKEFILE FOR TEST AUTOMATION
# =============================================================================

# Save as: Makefile

makefile_config <- '
.PHONY: test test-unit test-integration test-performance test-ui report clean install

# Install required packages
install:
\t@echo "Installing R packages..."
\t@Rscript -e "install.packages(c(\\"shiny\\", \\"bslib\\", \\"DT\\", \\"dplyr\\", \\"testthat\\", \\"htmltools\\", \\"microbenchmark\\"))"

# Run all tests
test: install
\t@echo "Running all tests..."
\t@Rscript tests/run_guided_workflow_tests.R

# Run specific test suites
test-unit:
\t@echo "Running unit tests..."
\t@Rscript -e "testthat::test_file(\\"tests/testthat/test-guided-workflow.R\\")"

test-integration:
\t@echo "Running integration tests..."
\t@Rscript -e "testthat::test_file(\\"tests/testthat/test-guided-workflow-integration.R\\")"

test-performance:
\t@echo "Running performance tests..."
\t@Rscript -e "testthat::test_file(\\"tests/testthat/test-guided-workflow-performance.R\\")"

test-ui:
\t@echo "Running UI tests..."
\t@Rscript -e "testthat::test_file(\\"tests/testthat/test-guided-workflow-ui.R\\")"

# Generate HTML report
report:
\t@echo "Generating test report..."
\t@Rscript tests/generate_test_report.R

# Interactive test app
test-interactive:
\t@echo "Starting interactive test app..."
\t@Rscript tests/test_guided_workflow_interactive.R

# Clean test artifacts
clean:
\t@echo "Cleaning test artifacts..."
\t@rm -rf tests/reports/*
\t@rm -rf rlib/*

# Run tests in Docker
test-docker:
\t@echo "Running tests in Docker..."
\t@docker-compose -f docker-compose.test.yml up --abort-on-container-exit

# Watch mode - run tests on file changes
watch:
\t@echo "Watching for changes..."
\t@while true; do \\
\t\tinotifywait -e modify guided_workflow.r tests/**/*.R; \\
\t\tmake test; \\
\tdone
'

# =============================================================================
# PRE-COMMIT HOOK
# =============================================================================

# Save as: .git/hooks/pre-commit

pre_commit_hook <- '#!/bin/bash
# Pre-commit hook to run tests before committing

echo "🧪 Running guided workflow tests before commit..."

# Run quick unit tests
Rscript -e "testthat::test_file(\"tests/testthat/test-guided-workflow.R\")"

# Check exit code
if [ $? -ne 0 ]; then
    echo "❌ Tests failed! Commit aborted."
    echo "Fix the tests or use \"git commit --no-verify\" to bypass."
    exit 1
fi

echo "✅ Tests passed! Proceeding with commit."
exit 0
'

# =============================================================================
# SAVE CONFIGURATIONS
# =============================================================================

cat("\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("📋 CI/CD CONFIGURATION GENERATOR\n")
cat("=" , rep("=", 78), "\n", sep = "")
cat("\n")
cat("Generated configurations for:\n")
cat("  • GitHub Actions\n")
cat("  • GitLab CI\n")
cat("  • Jenkins Pipeline\n")
cat("  • Docker Compose\n")
cat("  • Makefile\n")
cat("  • Pre-commit Hook\n")
cat("\n")
cat("To use these configurations:\n")
cat("  1. Copy relevant config to your project\n")
cat("  2. Adjust paths and settings as needed\n")
cat("  3. Commit and push to trigger CI/CD\n")
cat("\n")

# Save configurations to files
configs_dir <- "tests/ci_configs"
if (!dir.exists(configs_dir)) {
  dir.create(configs_dir, recursive = TRUE)
}

writeLines(github_actions_config, file.path(configs_dir, "github_actions.yml"))
writeLines(gitlab_ci_config, file.path(configs_dir, "gitlab_ci.yml"))
writeLines(jenkins_config, file.path(configs_dir, "Jenkinsfile"))
writeLines(docker_compose_config, file.path(configs_dir, "docker-compose.test.yml"))
writeLines(makefile_config, file.path(configs_dir, "Makefile"))
writeLines(pre_commit_hook, file.path(configs_dir, "pre-commit"))

cat("✅ Configuration files saved to:", configs_dir, "\n")
cat("\n")
