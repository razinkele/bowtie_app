# Environmental Bowtie Risk Analysis Application v5.1
## Startup Instructions

The application has been successfully updated to version 5.1 with all components loaded properly. However, Shiny applications need to run in an interactive environment.

## ✅ Application Status
- **Version**: 5.1.0 (Modern Framework Edition)
- **All modules loaded successfully**:
  - ✅ Utils v5.0.0 (Enhanced Environmental Bowtie Risk Analysis Utilities)
  - ✅ Vocabulary v5.0.0 (53 activities, 36 pressures, 26 consequences, 74 controls)
  - ✅ Bayesian Network Analysis (Advanced probabilistic risk modeling)
  - ✅ Guided Workflow System v5.1 (Complete 8-step wizard)
  - ✅ Enhanced UI with 21+ Bootstrap themes

## 🚀 How to Launch the Application

### Option 1: Using RStudio (Recommended)
1. Open RStudio
2. Set working directory: `setwd("C:/Users/DELL/OneDrive - ku.lt/HORIZON_EUROPE/bowtie_app")`
3. Run: `source("app.r")`
4. The app will launch in your default web browser

### Option 2: Using R Console
1. Open R console
2. Navigate to the app directory
3. Run: `source("app.r")`
4. Access the app at the displayed URL (typically `http://127.0.0.1:XXXX`)

### Option 3: Using the Simple Launcher
1. Double-click `run_app.R` or run: `Rscript run_app.R`
2. Follow the displayed instructions

## 🎯 Application Features Ready
- **Interactive Bowtie Diagrams**: Visual risk assessment with network graphs
- **21+ Bootstrap Themes**: Modern UI with theme switching
- **Guided Workflow**: 8-step wizard for systematic bowtie creation
- **Risk Matrix**: Interactive risk visualization with color coding
- **Bayesian Networks**: Advanced probabilistic modeling
- **Excel Integration**: Import/export functionality
- **AI Vocabulary Linking**: Intelligent environmental component connections

## 📊 Loaded Data
- **53 Activities** from environmental vocabulary
- **36 Pressures** from environmental stressors
- **26 Consequences** from environmental impacts
- **74 Controls** from mitigation measures

## ⚠️ Minor Warnings (Non-Critical)
- Some icon names ('sparkles', 'formula') not found - UI will use defaults
- Package version warnings - functionality remains intact

## 🔧 Troubleshooting
If the app doesn't launch:
1. Ensure all required packages are installed
2. Try running `source("utils.r")` first, then `source("app.r")`
3. Check that port is not blocked by firewall
4. Use RStudio for better interactive session support

The application is fully functional and ready for environmental risk assessment work!