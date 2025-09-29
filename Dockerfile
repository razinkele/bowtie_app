# =============================================================================
# Environmental Bowtie Risk Analysis Application - Docker Configuration
# Version: 5.2.0 (Advanced Framework Edition)
# Multi-stage build for optimized production deployment
# =============================================================================

# Base R image with Shiny
FROM rocker/shiny:4.4.3 as base

# Set maintainer information
LABEL maintainer="Environmental Bowtie App Team"
LABEL version="5.2.0"
LABEL description="Environmental Bowtie Risk Analysis with Bayesian Networks"

# Set working directory
WORKDIR /srv/shiny-server/bowtie_app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libudunits2-dev \
    libgdal-dev \
    libproj-dev \
    pandoc \
    pandoc-citeproc \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# DEPENDENCY INSTALLATION STAGE
# =============================================================================
FROM base as dependencies

# Copy package requirements
COPY requirements.R .

# Install R packages
RUN Rscript requirements.R

# =============================================================================
# APPLICATION BUILD STAGE
# =============================================================================
FROM dependencies as build

# Copy application files
COPY *.r *.R ./
COPY *.xlsx ./
COPY www/ ./www/
COPY tests/ ./tests/
COPY utils/ ./utils/
COPY .github/ ./.github/
COPY CLAUDE.md README.md ./

# Copy development and testing frameworks
COPY dev_config.R ./
COPY utils/advanced_benchmarks.R ./utils/

# Set proper permissions
RUN chown -R shiny:shiny /srv/shiny-server/bowtie_app
RUN chmod +x start_app.R

# Validate application structure
RUN Rscript -e "
# Validate essential files exist
required_files <- c('app.r', 'global.R', 'ui.R', 'server.R', 'start_app.R',
                   'guided_workflow.r', 'guided_workflow_steps.r',
                   'utils.r', 'vocabulary.r', 'bowtie_bayesian_network.r')

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop('Missing required files: ', paste(missing_files, collapse = ', '))
}

cat('✅ All required application files present\n')
"

# Run consistency validation
RUN Rscript -e "
# Validate consistency fixes
source('dev_config.R')
validation_passed <- validate_dependencies() && length(validate_icon_usage()) == 0

if (!validation_passed) {
  stop('❌ Application consistency validation failed')
}

cat('✅ Application consistency validation passed\n')
"

# =============================================================================
# PRODUCTION STAGE
# =============================================================================
FROM base as production

# Copy built application from build stage
COPY --from=build /srv/shiny-server/bowtie_app /srv/shiny-server/bowtie_app

# Copy R packages from dependencies stage
COPY --from=dependencies /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Create necessary directories
RUN mkdir -p /var/log/shiny-server
RUN mkdir -p /srv/shiny-server/bowtie_app/logs
RUN mkdir -p /srv/shiny-server/bowtie_app/performance_reports
RUN mkdir -p /srv/shiny-server/bowtie_app/dev_logs

# Set proper permissions
RUN chown -R shiny:shiny /srv/shiny-server/
RUN chown -R shiny:shiny /var/log/shiny-server

# Configure Shiny Server
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3838/ || exit 1

# Expose port
EXPOSE 3838

# Switch to non-root user
USER shiny

# Start command
CMD ["/usr/bin/shiny-server"]

# =============================================================================
# DEVELOPMENT STAGE (for development builds)
# =============================================================================
FROM build as development

# Install additional development tools
USER root
RUN apt-get update && apt-get install -y \
    vim \
    git \
    curl \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Install development R packages
RUN Rscript -e "
install.packages(c('testthat', 'microbenchmark', 'profvis', 'pryr', 'devtools'))
"

# Create development user
RUN useradd -m -s /bin/bash developer
RUN usermod -a -G shiny developer

# Development configuration
ENV SHINY_ENV=development
ENV R_PROFILE_USER=/srv/shiny-server/bowtie_app/.Rprofile

# Create R profile for development
RUN echo '
# Development R Profile
cat("🔧 Loading Development Environment\n")
source("dev_config.R")

# Enable development features
options(shiny.error = browser)
options(shiny.trace = TRUE)
options(shiny.autoreload = TRUE)

cat("✅ Development environment ready!\n")
' > /srv/shiny-server/bowtie_app/.Rprofile

# Development startup script
COPY docker-dev-start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-dev-start.sh

USER developer
WORKDIR /srv/shiny-server/bowtie_app

CMD ["/usr/local/bin/docker-dev-start.sh"]