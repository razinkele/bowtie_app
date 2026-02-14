# =============================================================================
# Environmental Bowtie Risk Analysis Application - Docker Configuration
# Version: 5.4.0 (Stability & Infrastructure Edition)
# Multi-stage build for optimized production deployment
# =============================================================================

# Base R image with Shiny
FROM rocker/shiny:4.4.3 as base

# Set maintainer information
LABEL maintainer="Environmental Bowtie App Team"
LABEL version="5.4.0"
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
COPY app.R global.R ui.R server.R start_app.R config.R ./
COPY guided_workflow.R bowtie_bayesian_network.R ./
COPY utils.R vocabulary.R translations_data.R ./
COPY environmental_scenarios.R ./
COPY vocabulary_bowtie_generator.R ./

# Copy data files (explicit list for clarity)
COPY CAUSES.xlsx CONSEQUENCES.xlsx CONTROLS.xlsx ./
COPY data/ ./data/

# Copy web assets and documentation
COPY www/ ./www/
COPY README.md CLAUDE.md ./

# Set proper permissions
RUN chown -R shiny:shiny /srv/shiny-server/bowtie_app
RUN chmod +r *.R *.xlsx

# Validate application structure
RUN Rscript -e "
# Validate essential files exist
required_files <- c('app.R', 'global.R', 'ui.R', 'server.R', 'start_app.R',
                   'config.R', 'guided_workflow.R', 'utils.R', 'vocabulary.R',
                   'bowtie_bayesian_network.R', 'translations_data.R',
                   'environmental_scenarios.R', 'vocabulary_bowtie_generator.R')

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop('Missing required files: ', paste(missing_files, collapse = ', '))
}

cat('✅ All required application files present\\n')

# Validate data files
data_files <- c('CAUSES.xlsx', 'CONSEQUENCES.xlsx', 'CONTROLS.xlsx')
missing_data <- data_files[!file.exists(data_files)]
if (length(missing_data) > 0) {
  warning('Missing data files: ', paste(missing_data, collapse = ', '))
} else {
  cat('✅ All data files present\\n')
}
"

# =============================================================================
# PRODUCTION STAGE
# =============================================================================
FROM base as production

# Install curl for healthcheck (minimal addition)
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Copy built application from build stage
COPY --from=build /srv/shiny-server/bowtie_app /srv/shiny-server/bowtie_app

# Copy R packages from dependencies stage
COPY --from=dependencies /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Create necessary directories
RUN mkdir -p /var/log/shiny-server \
    && mkdir -p /srv/shiny-server/bowtie_app/logs \
    && mkdir -p /srv/shiny-server/bowtie_app/performance_reports \
    && mkdir -p /srv/shiny-server/bowtie_app/data

# Set proper permissions
RUN chown -R shiny:shiny /srv/shiny-server/ \
    && chown -R shiny:shiny /var/log/shiny-server

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