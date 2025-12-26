# Autosave Feature Investigation Report

**Date**: 2025-12-26
**Application**: Environmental Bowtie Risk Analysis - Guided Workflow
**Branch**: claude/hierarchical-bowtie-selection-bJzNe
**Investigator**: Claude Code

---

## Executive Summary

**Finding**: ❌ **No automatic autosave functionality is currently implemented.**

The application has **manual save/load functionality** but does **not** include:
- Periodic/automatic saving
- Browser localStorage persistence
- Session-based autosave
- Background save timers

However, the application has:
- ✅ Manual save to file (RDS format)
- ✅ Manual load from file
- ✅ State preservation during step navigation
- ✅ Complete data structure for state management

---

## Current Save/Load Implementation

### 1. **Manual Save Functionality**

**Location**: `guided_workflow.R:3537-3548`

```r
output$workflow_download <- downloadHandler(
  filename = function() {
    project_name <- workflow_state()$project_data$project_name %||% "untitled"
    paste0(gsub(" ", "_", project_name), "_workflow_", Sys.Date(), ".rds")
  },
  content = function(file) {
    state_to_save <- workflow_state()
    state_to_save$last_saved <- Sys.time()
    saveRDS(state_to_save, file)
  },
  contentType = "application/octet-stream"
)
```

**Features**:
- ✅ Saves complete workflow state to RDS file
- ✅ Automatic filename generation (project_name + date)
- ✅ Timestamp of last save included
- ✅ Binary format for data integrity

**UI Component**: `guided_workflow.R:502`
```r
downloadButton(ns("workflow_download"),
               tagList(icon("save"), t("gw_save_progress", current_lang)),
               class = "btn-light btn-sm")
```

**User Action Required**: Click "Save Progress" button in workflow header

---

### 2. **Manual Load Functionality**

**Location**: `guided_workflow.R:3395-3520`

```r
# Load button triggers hidden file input
observeEvent(input$workflow_load_btn, {
  shinyjs::runjs("$('#guided_workflow-workflow_load_file_hidden').click();")
})

# Handle file loading
observeEvent(input$workflow_load_file_hidden, {
  file <- input$workflow_load_file_hidden
  req(file)

  tryCatch({
    loaded_state <- readRDS(file$datapath)

    # Validation and migration of old data structures
    if (is.list(loaded_state) && "current_step" %in% names(loaded_state)) {
      # ... extensive data migration code ...
      workflow_state(loaded_state)
      # ... update reactive values ...
    }
  }, error = function(e) {
    showNotification(paste("Error loading file:", e$message),
                    type = "error", duration = 5)
  })
})
```

**Features**:
- ✅ Loads RDS files created by save functionality
- ✅ Validates loaded state structure
- ✅ **Backward compatibility**: Migrates old data formats
- ✅ Error handling with user notifications
- ✅ Restores complete workflow state including:
  - Current step position
  - All selected items (activities, pressures, controls, consequences)
  - Custom entries
  - Project metadata
  - Connection data

**UI Component**: `guided_workflow.R:497-500`
```r
actionButton(ns("workflow_load_btn"),
             tagList(icon("folder-open"), t("gw_load_progress", current_lang)),
             class = "btn-light btn-sm")
# Hidden file input
fileInput(ns("workflow_load_file_hidden"), NULL, accept = ".rds")
```

**User Action Required**: Click "Load Progress" button → Select RDS file

---

### 3. **Implicit State Preservation**

**Location**: `guided_workflow.R:1558, 3086`

The workflow automatically saves data when:

#### **Step Navigation** (`save_step_data` function)
```r
observeEvent(input$next_step, {
  state <- workflow_state()

  # Save data from current step
  state <- save_step_data(state, input)

  # Mark step as complete
  if (!state$current_step %in% state$completed_steps) {
    state$completed_steps <- c(state$completed_steps, state$current_step)
  }

  # Move to next step
  if (state$current_step < state$total_steps) {
    state$current_step <- state$current_step + 1
  }

  workflow_state(state)
})
```

**Features**:
- ✅ Automatic state update on "Next" button click
- ✅ Data persists in reactive value during session
- ❌ **Not persistent across browser sessions/refreshes**

---

## State Management Structure

### Workflow State Schema

**Location**: `guided_workflow.R:366-394`

```r
init_workflow_state <- function() {
  list(
    current_step = 1,
    total_steps = length(WORKFLOW_CONFIG$steps),
    completed_steps = numeric(0),
    project_data = list(
      # Template system compatibility
      template_applied = NULL,
      project_type = NULL,
      project_location = NULL,
      project_description = NULL,
      analysis_scope = NULL,
      # Example data for templates
      example_activities = character(0),
      example_pressures = character(0)
    ),
    validation_status = list(),
    progress_percentage = 0,
    start_time = Sys.time(),
    step_times = list(),
    # Core integration properties
    project_name = "",
    central_problem = "",
    # Additional workflow metadata
    workflow_complete = FALSE,
    converted_main_data = NULL,
    last_saved = NULL  # ← Timestamp of last manual save
  )
}
```

**Storage Mechanism**:
- Type: `reactiveVal()` - Shiny reactive value
- Scope: Current session only
- Persistence: **In-memory only** (lost on browser refresh/close)

---

## What's Missing: Autosave Functionality

### NOT Implemented:

❌ **Periodic Autosave**
```r
# Example of what's NOT present:
autoSaveTimer <- reactiveTimer(60000)  # Every 60 seconds

observe({
  autoSaveTimer()
  # Automatically save state to file or localStorage
})
```

❌ **Browser localStorage Persistence**
```r
# Example of what's NOT present:
observe({
  state <- workflow_state()
  # Save to browser localStorage
  session$sendCustomMessage("saveToLocalStorage",
                           list(key = "workflow_state",
                                value = jsonlite::toJSON(state)))
})
```

❌ **Session Recovery**
```r
# Example of what's NOT present:
session$onSessionEnded(function() {
  # Save state before session ends
})
```

❌ **Bookmarking**
```r
# Example of what's NOT present:
enableBookmarking("url")
# or
enableBookmarking("server")
```

---

## Risk Assessment: Data Loss Scenarios

### 🔴 **High Risk Scenarios** (No Protection)

1. **Browser Refresh/Reload**
   - Current state: ❌ **All progress lost**
   - User must manually save before refresh
   - No warning dialog

2. **Browser Crash**
   - Current state: ❌ **All progress lost**
   - No recovery mechanism

3. **Accidental Tab Close**
   - Current state: ❌ **All progress lost**
   - No browser confirmation dialog

4. **Network Interruption**
   - Current state: ❌ **Session may be lost**
   - No offline persistence

5. **Idle Session Timeout**
   - Current state: ❌ **Session expires, data lost**
   - No automatic session extension

6. **User Forgets to Save**
   - Current state: ❌ **Hours of work potentially lost**
   - No periodic reminders

---

## Recommendations for Autosave Implementation

### Priority 1: Browser localStorage Autosave (Recommended)

**Benefits**:
- ✅ Persists across browser refreshes
- ✅ No server storage required
- ✅ Fast and reliable
- ✅ Works offline

**Implementation Approach**:

```r
# 1. Create custom message handler in UI
tags$script(HTML("
  Shiny.addCustomMessageHandler('saveToLocalStorage', function(data) {
    localStorage.setItem(data.key, data.value);
  });

  Shiny.addCustomMessageHandler('loadFromLocalStorage', function(data) {
    var value = localStorage.getItem(data.key);
    Shiny.setInputValue(data.inputId, value);
  });
"))

# 2. Add periodic autosave in server
autoSaveTimer <- reactiveTimer(30000)  # Every 30 seconds

observe({
  autoSaveTimer()
  isolate({
    state <- workflow_state()
    if (!is.null(state) && state$current_step > 1) {
      session$sendCustomMessage("saveToLocalStorage", list(
        key = "bowtie_workflow_autosave",
        value = jsonlite::toJSON(state, auto_unbox = TRUE)
      ))
      cat("✅ Autosaved at", format(Sys.time(), "%H:%M:%S"), "\n")
    }
  })
})

# 3. Restore on session start
observeEvent(session$clientData$url_search, {
  session$sendCustomMessage("loadFromLocalStorage", list(
    key = "bowtie_workflow_autosave",
    inputId = "restored_state"
  ))
}, once = TRUE)

observeEvent(input$restored_state, {
  if (!is.null(input$restored_state) && nchar(input$restored_state) > 0) {
    tryCatch({
      restored <- jsonlite::fromJSON(input$restored_state)
      # Show restore dialog
      showModal(modalDialog(
        title = "Restore Previous Session?",
        "A previous workflow session was found. Would you like to restore it?",
        footer = tagList(
          actionButton("restore_yes", "Restore", class = "btn-primary"),
          actionButton("restore_no", "Start Fresh", class = "btn-secondary")
        )
      ))
    }, error = function(e) {
      cat("Error restoring state:", e$message, "\n")
    })
  }
}, once = TRUE)
```

---

### Priority 2: Periodic Save Reminders

**Benefits**:
- ✅ Encourages manual saving
- ✅ Low complexity
- ✅ No data loss if user complies

**Implementation**:

```r
# Reminder timer (every 5 minutes if unsaved changes)
reminderTimer <- reactiveTimer(300000)  # 5 minutes

last_manual_save <- reactiveVal(Sys.time())

observe({
  reminderTimer()
  isolate({
    state <- workflow_state()
    if (!is.null(state$last_saved)) {
      time_since_save <- difftime(Sys.time(), state$last_saved, units = "mins")
      if (time_since_save > 5) {
        showNotification(
          "💾 Reminder: You haven't saved in over 5 minutes. Click 'Save Progress' to avoid losing work.",
          type = "warning",
          duration = 10
        )
      }
    }
  })
})
```

---

### Priority 3: Browser Unload Warning

**Benefits**:
- ✅ Warns before accidental close
- ✅ Simple to implement
- ✅ Standard browser feature

**Implementation**:

```r
# Add JavaScript to warn before leaving page
tags$script(HTML("
  window.addEventListener('beforeunload', function (e) {
    // Check if workflow is in progress
    var currentStep = $('#guided_workflow-current_step').val();
    if (currentStep && currentStep > 1) {
      e.preventDefault();
      e.returnValue = 'You have unsaved workflow progress. Are you sure you want to leave?';
      return e.returnValue;
    }
  });
"))
```

---

### Priority 4: Server-Side Session Storage (Optional)

**Benefits**:
- ✅ Centralized storage
- ✅ Can be shared across devices
- ✅ Database-backed persistence

**Considerations**:
- ⚠️ Requires database setup
- ⚠️ Privacy/security considerations
- ⚠️ More complex implementation

---

## Comparison: Current vs. Proposed

| Feature | Current Status | With localStorage Autosave | With Session Storage |
|---------|---------------|---------------------------|---------------------|
| **Manual Save** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Manual Load** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Auto Save** | ❌ No | ✅ Every 30s | ✅ Every 30s |
| **Browser Refresh Protection** | ❌ No | ✅ Yes | ✅ Yes |
| **Session Recovery** | ❌ No | ✅ Yes | ✅ Yes |
| **Cross-Device Sync** | ❌ No | ❌ No | ✅ Yes |
| **Offline Support** | ⚠️ Partial | ✅ Yes | ❌ No |
| **Storage Location** | User's computer (manual) | Browser localStorage | Server database |
| **Data Loss Risk** | 🔴 High | 🟢 Low | 🟢 Low |
| **Implementation Complexity** | N/A | 🟢 Low | 🟡 Medium |

---

## Testing Checklist for Autosave

If implementing autosave, test these scenarios:

- [ ] Autosave triggers every N seconds
- [ ] Autosave only occurs when data has changed
- [ ] Autosave timestamp is displayed to user
- [ ] Restore prompt appears on page reload
- [ ] User can choose to restore or start fresh
- [ ] Restored data matches saved state exactly
- [ ] Multiple tabs don't conflict
- [ ] localStorage quota isn't exceeded
- [ ] Old autosaves are cleaned up
- [ ] Manual save overrides autosave
- [ ] Autosave doesn't interfere with user input
- [ ] Autosave status indicator works
- [ ] Browser close warning appears when unsaved
- [ ] Privacy: autosave can be disabled by user

---

## Implementation Effort Estimate

### localStorage Autosave
- **Effort**: 4-6 hours
- **Lines of Code**: ~150-200
- **Files Modified**:
  - `guided_workflow.R` (UI + server logic)
  - New file: `autosave.js` (JavaScript handlers)
- **Testing**: 2-3 hours
- **Documentation**: 1 hour

### Total Estimate: **1 day** for complete autosave feature

---

## Conclusion

**Current State**:
- ✅ Solid manual save/load foundation
- ✅ Complete state management structure
- ✅ Good data migration support
- ❌ **No autosave protection against data loss**

**Recommendation**:
Implement **Priority 1 (localStorage autosave)** to significantly reduce data loss risk with minimal complexity. This would provide automatic recovery from browser crashes, accidental refreshes, and tab closures.

**Alternative**:
If localStorage autosave is not desired, at minimum implement **Priority 2 (save reminders)** and **Priority 3 (unload warning)** to protect users from accidental data loss.

---

**Investigation Status**: ✅ Complete
**Next Steps**: Awaiting decision on autosave implementation priority

---

*Report generated by Claude Code investigation of bowtie_app repository*
