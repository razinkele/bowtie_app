# Centralized Configuration Guide

## Overview

The application now uses a centralized configuration system (`config.R`) that consolidates all settings in one place, making it easier to manage and maintain.

## 📁 Configuration Files

### `config.R` (Main Configuration)
- **Location:** Root directory
- **Purpose:** Single source of truth for all application settings
- **Versioned:** Yes (committed to git)
- **Contains:** Application metadata, deployment settings, UI theme, risk levels, and more

### `.env.R` (Environment-Specific Overrides)
- **Location:** Root directory
- **Purpose:** Override settings for different environments (dev/test/prod)
- **Versioned:** No (gitignored, create from `.env.R.example`)
- **Contains:** Environment-specific overrides like debug mode, database credentials

## 🚀 Quick Start

### 1. Basic Usage (Production)
No changes needed! The application works out of the box with default settings from `config.R`.

### 2. Development Environment
Create a `.env.R` file to enable development features:

```bash
cp .env.R.example .env.R
```

Edit `.env.R` to enable debug mode:

```r
ENV_CONFIG <- list(
  DEV = list(
    DEBUG_MODE = TRUE,
    ENABLE_PROFILING = TRUE,
    SHOW_ERRORS = TRUE
  )
)
```

### 3. Testing Environment
Create a separate `.env.R` for testing with test data:

```r
ENV_CONFIG <- list(
  APP_NAME = "bowtie_app_test",
  DATA_FILES = list(
    CAUSES = "test_data/CAUSES_test.xlsx",
    CONSEQUENCES = "test_data/CONSEQUENCES_test.xlsx",
    CONTROLS = "test_data/CONTROLS_test.xlsx"
  )
)
```

## 📋 Available Configuration Sections

### Application Metadata
```r
APP_CONFIG$APP_NAME          # "bowtie_app"
APP_CONFIG$VERSION           # "5.2.0"
APP_CONFIG$TITLE             # Full application title
```

### Deployment Settings
```r
APP_CONFIG$SHINY_SERVER_DIR  # "/srv/shiny-server"
APP_CONFIG$DEFAULT_PORT      # 3838
APP_CONFIG$REQUIRED_FILES    # List of required files
```

### UI Theme
```r
APP_CONFIG$THEME$PRIMARY_COLOR    # "#2C5F2D"
APP_CONFIG$THEME$SECONDARY_COLOR  # "#97BC62"
APP_CONFIG$THEME$SUCCESS_COLOR    # "#28a745"
```

### Risk Levels
```r
APP_CONFIG$RISK_LEVELS$HIGH$color      # "#dc3545"
APP_CONFIG$RISK_LEVELS$HIGH$threshold  # 0.7
```

### Report Settings
```r
APP_CONFIG$REPORT$FORMATS              # c("HTML", "PDF", "DOCX")
APP_CONFIG$REPORT$DEFAULT_FORMAT       # "HTML"
APP_CONFIG$REPORT$MAX_SCENARIOS_TABLE  # 50
```

### Language Settings
```r
APP_CONFIG$LANGUAGES$SUPPORTED  # c("en", "fr")
APP_CONFIG$LANGUAGES$DEFAULT    # "en"
```

## 🛠️ Helper Functions

### `get_config(path, default = NULL)`
Get nested configuration values:

```r
# Get primary color
primary_color <- get_config(c("THEME", "PRIMARY_COLOR"))

# Get with default fallback
port <- get_config(c("DEFAULT_PORT"), 3838)
```

### `get_risk_level(probability)`
Get risk level configuration by probability:

```r
risk <- get_risk_level(0.8)
# Returns: list(label = "High Risk", color = "#dc3545", threshold = 0.7)
```

### `is_required_file(filename)`
Check if a file is required:

```r
is_required_file("app.R")      # TRUE
is_required_file("test.R")     # FALSE
```

### `get_app_version()`
Get formatted version string:

```r
get_app_version()  # "bowtie_app v5.2.0"
```

### `get_data_file_path(file_key)`
Get path to data files:

```r
get_data_file_path("CAUSES")        # "CAUSES.xlsx"
get_data_file_path("CONSEQUENCES")  # "CONSEQUENCES.xlsx"
```

## 🔧 Using Configuration in Code

### In R Code
```r
# Source config first (if not already loaded by global.R)
source("config.R")

# Access configuration
app_name <- APP_CONFIG$APP_NAME
version <- APP_CONFIG$VERSION

# Use helper functions
risk_info <- get_risk_level(0.75)
```

### In Deployment Scripts (Bash)
The deployment scripts automatically load configuration from `config.R`:

```bash
# deploy_shiny_server.sh automatically loads:
# - APP_NAME from config.R
# - VERSION from config.R
# - REQUIRED_FILES from config.R
```

## 📝 Common Configuration Tasks

### Change Application Port
In `.env.R`:
```r
ENV_CONFIG <- list(
  DEFAULT_PORT = 8080
)
```

### Enable Debug Logging
In `.env.R`:
```r
ENV_CONFIG <- list(
  LOGGING = list(
    ENABLED = TRUE,
    LEVEL = "DEBUG",
    FILE = "debug.log"
  )
)
```

### Use Custom Theme Colors
In `.env.R`:
```r
ENV_CONFIG <- list(
  THEME = list(
    PRIMARY_COLOR = "#1a5490",
    SECONDARY_COLOR = "#6fa8dc"
  )
)
```

### Add Database Connection
In `.env.R`:
```r
ENV_CONFIG <- list(
  DATABASE = list(
    ENABLED = TRUE,
    TYPE = "postgres",
    HOST = "localhost",
    PORT = 5432,
    NAME = "bowtie_app",
    USER = Sys.getenv("DB_USER"),
    PASSWORD = Sys.getenv("DB_PASSWORD")
  )
)
```

## ⚠️ Best Practices

1. **Never commit `.env.R`** - It's gitignored for security
2. **Use environment variables** for sensitive data:
   ```r
   PASSWORD = Sys.getenv("DB_PASSWORD")
   ```
3. **Keep `config.R` environment-agnostic** - Put environment-specific settings in `.env.R`
4. **Document custom settings** - Add comments explaining why you override defaults
5. **Test configuration changes** - Verify the app starts after modifying config

## 🔍 Troubleshooting

### Configuration not loading
```r
# Check if config.R exists
file.exists("config.R")

# Test loading manually
source("config.R")
print(APP_CONFIG$VERSION)
```

### Environment overrides not applied
```r
# Check if .env.R exists
file.exists(".env.R")

# Check if ENV_CONFIG is defined in .env.R
source(".env.R")
print(exists("ENV_CONFIG"))
```

### Deployment script can't find config
```bash
# Ensure you're in the project root
cd /path/to/bowtie_app

# Check if config.R exists
ls -la config.R

# Test loading from R
Rscript -e "source('config.R'); print(APP_CONFIG$APP_NAME)"
```

## 📚 Benefits of Centralized Configuration

✅ **Single Source of Truth** - All settings in one place
✅ **Easy Maintenance** - Change once, update everywhere
✅ **Environment Flexibility** - Override for dev/test/prod
✅ **Deployment Integration** - Scripts read from same config
✅ **Type Safety** - Structured lists instead of scattered variables
✅ **Documentation** - Self-documenting with clear structure
✅ **Version Control** - Track configuration changes in git

## 🎯 Migration from Old System

If you have hardcoded values in your code:

**Before:**
```r
app_name <- "bowtie_app"
port <- 3838
```

**After:**
```r
source("config.R")
app_name <- APP_CONFIG$APP_NAME
port <- APP_CONFIG$DEFAULT_PORT
```

---

**Version:** 5.2.0  
**Last Updated:** November 2025
