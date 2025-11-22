# Guided Workflow Test Suite

Comprehensive testing framework for the Guided Creation workflow module.

## Overview

This test suite provides both automated unit tests and an interactive testing application to ensure the guided workflow system functions correctly.

## Test Components

### 1. Automated Unit Tests (`test-guided-workflow.R`)

Comprehensive testthat-based tests covering:

- ✅ **Workflow Initialization** - State creation and setup
- ✅ **Step Validation** - Input validation for each step
- ✅ **Data Persistence** - Saving and retrieving workflow data
- ✅ **Navigation Logic** - Step progression and restrictions
- ✅ **Complete Scenarios** - End-to-end workflow testing
- ✅ **Data Conversion** - Export functionality
- ✅ **Edge Cases** - Error handling and boundary conditions
- ✅ **UI Generation** - Component rendering

### 2. Interactive Test Application (`test_guided_workflow_interactive.R`)

Full Shiny application for manual testing with:

- **Pre-configured Scenarios** - Load realistic test data
- **Auto-completion** - Fill step data automatically
- **Real-time Debugging** - View workflow state
- **Vocabulary Inspection** - Browse test vocabularies
- **Export Preview** - See how data will be exported

### 3. Quick Test Runner (`run_guided_workflow_tests.R`)

Command-line script for running tests quickly.

## Test Scenarios

### 1. Baltic Sea Eutrophication
**Type:** Marine  
**Focus:** Nutrient pollution management  
**Activities:** Agriculture, Urban development, Waste disposal  
**Pressures:** Nutrient pollution, Eutrophication, Chemical contamination

### 2. Great Barrier Reef Conservation
**Type:** Marine  
**Focus:** Multi-stressor coral reef management  
**Activities:** Agriculture, Tourism, Commercial fishing, Shipping  
**Pressures:** Temperature changes, Nutrient pollution, Physical disturbance

### 3. Industrial River Pollution
**Type:** Freshwater  
**Focus:** Heavy metal contamination  
**Activities:** Industrial discharge, Mining, Waste disposal, Urban development  
**Pressures:** Heavy metals, Chemical contamination, Sediment runoff

### 4. Coastal Fisheries Management
**Type:** Marine  
**Focus:** Sustainable fisheries  
**Activities:** Commercial fishing, Aquaculture, Port operations  
**Pressures:** Overfishing, Habitat destruction, Physical disturbance

### 5. Ocean Plastic Pollution
**Type:** Marine  
**Focus:** Plastic waste reduction  
**Activities:** Waste disposal, Tourism, Shipping, Commercial fishing  
**Pressures:** Plastic pollution, Chemical contamination, Physical disturbance

## Test Vocabulary Data

The test suite includes comprehensive vocabularies:

- **15 Activities** - From agriculture to shipping
- **15 Pressures** - Chemical, physical, and biological
- **12 Controls** - Regulatory, technical, and social
- **10 Consequences** - Ecosystem, human, and economic impacts

## Running Tests

### Option 1: Run Automated Tests

```r
# From R console
source("tests/run_guided_workflow_tests.R")

# Or from command line
Rscript tests/run_guided_workflow_tests.R
```

### Option 2: Run Interactive Test App

```r
# From R console
source("tests/test_guided_workflow_interactive.R")

# Or from command line
Rscript tests/test_guided_workflow_interactive.R
```

### Option 3: Run with testthat

```r
library(testthat)
test_file("tests/testthat/test-guided-workflow.R")
```

### Option 4: Run All Tests

```r
# From project root
library(testthat)
test_dir("tests/testthat")
```

## Using the Interactive Test App

### 1. Launch the App
```r
source("tests/test_guided_workflow_interactive.R")
```

### 2. Select a Test Scenario
- Choose from dropdown: "Baltic Sea Eutrophication", "Great Barrier Reef", etc.
- Click "Load Scenario"

### 3. Test Navigation
- Use "Auto-Complete Current Step" to fill in data
- Click "Next" to progress through workflow
- Test validation by leaving fields empty

### 4. Inspect Results
- **Test Data tab** - View vocabulary tables
- **Test Results tab** - See workflow state and exported data
- **Status sidebar** - Monitor progress

### 5. Debug Issues
- Check "Workflow State Debug View" for internal state
- View "Exported Data Preview" to verify data structure

## Test Coverage

### Step 1: Project Setup ✅
- Empty project name validation
- Special characters handling
- Long text inputs
- Data persistence

### Step 2: Central Problem ✅
- Problem statement validation
- Category selection
- Multi-field data saving
- Template application

### Step 3: Activities & Pressures ✅
- Vocabulary loading
- Search functionality
- Adding/removing items
- Table rendering
- Data persistence

### Steps 4-8: Future Implementation 🔄
- Placeholder validation (all pass)
- UI generation tested
- Ready for full implementation

## Expected Test Results

When running automated tests, you should see:

```
✅ Workflow initialization: 2 tests passed
✅ Step validation: 3 tests passed
✅ Data saving: 2 tests passed
✅ Navigation: 2 tests passed
✅ Complete scenarios: 2 tests passed
✅ Data conversion: 1 test passed
✅ Edge cases: 4 tests passed
✅ UI generation: 1 test passed
```

**Total: ~17 test cases**

## Troubleshooting

### Tests Fail to Load

**Issue:** `guided_workflow_server` not found

**Solution:**
```r
# Ensure you're in project root
setwd("/path/to/bowtie_app")

# Source guided workflow first
source("guided_workflow.r")

# Then run tests
source("tests/run_guided_workflow_tests.R")
```

### Vocabulary Data Missing

**Issue:** Vocabulary not loading in tests

**Solution:**
```r
# Tests create mock vocabulary automatically
# If using real app data:
source("vocabulary.r")
vocabulary_data <- load_vocabulary()
```

### Interactive App Won't Start

**Issue:** Missing packages

**Solution:**
```r
install.packages(c("shiny", "bslib", "DT", "dplyr", "testthat"))
```

## Adding New Tests

### 1. Add Test Case to Unit Tests

```r
# In tests/testthat/test-guided-workflow.R

test_that("My new test", {
  # Setup
  state <- create_test_workflow_state()
  
  # Test logic
  result <- my_function(state)
  
  # Assertions
  expect_true(result$is_valid)
  expect_equal(result$value, expected_value)
})
```

### 2. Add New Test Scenario

```r
# In test_guided_workflow_interactive.R
# Add to test_scenarios list:

my_scenario = list(
  name = "My Test Scenario",
  description = "Description of test case",
  data = list(
    project_name = "Test Project",
    problem_statement = "Test Problem",
    activities = c("Activity 1", "Activity 2"),
    pressures = c("Pressure 1", "Pressure 2")
  )
)
```

## Continuous Integration

For CI/CD pipelines:

```bash
# In .github/workflows/test.yml or similar
Rscript -e "testthat::test_dir('tests/testthat')"
```

## Performance Testing

Monitor test execution time:

```r
system.time({
  test_file("tests/testthat/test-guided-workflow.R")
})
```

Expected execution time: < 5 seconds

## Coverage Analysis

Check test coverage:

```r
library(covr)
coverage <- file_coverage("guided_workflow.r", 
                         "tests/testthat/test-guided-workflow.R")
report(coverage)
```

## Next Steps

- [ ] Add tests for Steps 4-8 when implemented
- [ ] Add performance benchmarks
- [ ] Add integration tests with main app
- [ ] Add screenshot/snapshot tests for UI
- [ ] Add accessibility tests

## Support

For issues or questions:
1. Check test output for detailed error messages
2. Review this README for troubleshooting
3. Check `DEVELOPMENT_GUIDE.md` for architecture details
4. Enable debug output: `options(shiny.trace = TRUE)`

---

**Last Updated:** November 14, 2025  
**Version:** 1.0.0
