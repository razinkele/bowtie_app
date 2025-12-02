# Guided Workflow Usability Issues & Fixes

**Version**: 5.3.3 (Planned)
**Date**: December 2025
**Priority**: High - Critical usability improvements needed

---

## 📋 Issues Identified

### 1. Categories Can Be Selected (HIGH PRIORITY) ❌

**Issue**: Users can select category headers (Level 1 items in ALL CAPS) which are meant to organize items, not be selected.

**Example**:
- "PHYSICAL RESTRUCTURING OF RIVERS, COASTLINE OR SEABED" (Level 1 - Category)
- "Land claim" (Level 2 - Actual selectable item)

**Current Behavior**: Both can be selected
**Expected Behavior**: Only Level 2+ items should be selectable

**Impact**: Confusing for users, incorrect data in workflow

**Fix Required**:
```r
# In guided_workflow.R, filter vocabulary choices to exclude level 1 items:

# For activities
if (!is.null(vocabulary_data$activities)) {
  # Filter to only level 2 and above
  selectable_activities <- vocabulary_data$activities %>%
    filter(level > 1) %>%
    pull(name)

  selectizeInput(ns("activity_search"),
                choices = selectable_activities,  # Filtered choices
                ...)
}
```

**Files to Modify**:
- `guided_workflow.R` lines 761-767 (activities)
- `guided_workflow.R` lines 802-808 (pressures)
- `guided_workflow.R` lines 862-868 (preventive controls)
- `guided_workflow.R` lines 931-937 (consequences)
- `guided_workflow.R` lines 996-1002 (protective controls)

**Estimated Effort**: 2 hours

---

### 2. Cannot Add Custom Entries (HIGH PRIORITY) ❌

**Issue**: Users can only select from predefined lists. No way to add custom activities, pressures, or controls (e.g., "beach clean-up", "community outreach").

**Current Behavior**: `create: FALSE` in selectizeInput options
**Expected Behavior**: Allow custom entries with `create: TRUE`

**Impact**: Limits flexibility, doesn't fit all use cases

**Fix Required**:
```r
selectizeInput(ns("activity_search"),
              choices = activity_choices,
              options = list(
                placeholder = "Search or type custom activity...",
                create = TRUE,  # ENABLE custom entries
                maxOptions = 100,
                openOnFocus = TRUE,
                createFilter = '^.{3,}$'  # Minimum 3 characters
              ))
```

**Additional Changes Needed**:
- Add validation for custom entries
- Store custom entries separately in workflow state
- Add "(Custom)" label to distinguish from vocabulary items
- Ensure custom entries are included in export

**Files to Modify**:
- All selectizeInput instances in `guided_workflow.R`
- Add custom entry tracking in workflow state
- Update export function to handle custom entries

**Estimated Effort**: 3 hours

---

### 3. Cannot Specify "Other" Categories (MEDIUM PRIORITY) ⚠️

**Issue**: When selecting items with "other" in the name, users cannot specify what "other" means.

**Example**: "Other economic measures" - what specific measure?

**Current Behavior**: "Other" is added as-is
**Expected Behavior**: Prompt for specification when "other" selected

**Fix Required**:
```r
# When user selects an item containing "other"
observeEvent(input$activity_search, {
  if (grepl("other", input$activity_search, ignore.case = TRUE)) {
    showModal(modalDialog(
      title = "Specify 'Other'",
      textInput(ns("other_specification"),
               "Please specify what 'other' refers to:"),
      footer = tagList(
        actionButton(ns("confirm_other"), "Confirm"),
        modalButton("Cancel")
      )
    ))
  }
})
```

**Estimated Effort**: 2 hours

---

### 4. Cannot Delete Selected Items (CRITICAL) ❌

**Issue**: Once an item is added to a table (activities, pressures, controls), there's no way to remove it.

**Current Behavior**: No delete button in tables
**Expected Behavior**: Delete button for each row

**Impact**: Users stuck with mistakes, have to restart workflow

**Fix Required**:
```r
# Add delete column to all data tables
output$selected_activities_table <- renderDT({
  data <- selected_activities()
  if (length(data) == 0) {
    return(data.frame(Activity = character(0), Delete = character(0)))
  }

  df <- data.frame(
    Activity = data,
    Delete = sprintf('<button class="btn btn-danger btn-sm delete-btn" data-value="%s">
                      <i class="fa fa-trash"></i> Delete</button>', data)
  )

  datatable(df,
           escape = FALSE,  # Allow HTML
           options = list(dom = 't', pageLength = 100))
}, server = FALSE)

# Handle delete clicks
observeEvent(input$selected_activities_table_cell_clicked, {
  info <- input$selected_activities_table_cell_clicked
  if (info$col == 1) {  # Delete column
    # Remove item from selected_activities
    current <- selected_activities()
    selected_activities(current[current != info$value])

    showNotification("Item removed", type = "message")
  }
})
```

**Files to Modify**:
- All table outputs in `guided_workflow.R`
- Add JavaScript for delete button handling
- Update all reactive values when items deleted

**Estimated Effort**: 4 hours

---

### 5. Overlap Between Preventive & Protective Controls (LOW PRIORITY) ℹ️

**Issue**: Some controls appear in both preventive and protective categories.

**Example**: "Emergency response plans" could be both

**Current Behavior**: Same control vocabulary for both
**Expected Behavior**:
- Option A: Separate vocabularies
- Option B: Mark controls as "preventive", "protective", or "both"

**Fix Required**:
This requires updating the vocabulary Excel files:
- Add "type" column to CONTROLS.xlsx
- Values: "preventive", "protective", "both"
- Filter based on context

**Estimated Effort**: 3 hours + data cleanup

---

### 6. Escalation Factors Lack Library (MEDIUM PRIORITY) ⚠️

**Issue**: No predefined options for escalation factors - users must type everything.

**Current Behavior**: Free text input only
**Expected Behavior**: Predefined library + custom option

**Fix Required**:
```r
# Create escalation factors library
ESCALATION_FACTORS_LIBRARY <- c(
  # Resource-related
  "Budget constraints",
  "Staff shortages",
  "Equipment failures",
  "Supply chain disruptions",

  # Human factors
  "Training deficiencies",
  "Human error",
  "Fatigue",
  "Communication breakdowns",

  // Technical
  "Technology failures",
  "System malfunctions",
  "Maintenance delays",
  "Software bugs",

  # Organizational
  "Policy changes",
  "Regulatory changes",
  "Management turnover",
  "Organizational restructuring",

  # External
  "Extreme weather",
  "Natural disasters",
  "Economic downturns",
  "Political instability"
)

# Update Step 7 UI
selectizeInput(ns("escalation_factor_search"),
              "Select or enter escalation factor:",
              choices = ESCALATION_FACTORS_LIBRARY,
              options = list(
                placeholder = "Search library or type custom...",
                create = TRUE,  # Allow custom
                maxOptions = 50
              ))
```

**Estimated Effort**: 2 hours

---

### 7. Cannot Link Connections (CRITICAL) ❌

**Issue**: Users cannot manually create links between:
- Activities ↔ Pressures
- Controls ↔ Activities/Pressures
- Consequences ↔ Protective Controls

**Current Behavior**: Automatic linking or no linking
**Expected Behavior**: Manual linking interface

**Fix Required**:
```r
# Add linking interface after selection
fluidRow(
  column(6,
         h5("Selected Activities"),
         selectInput(ns("link_activity"), NULL,
                    choices = selected_activities())
  ),
  column(6,
         h5("Link to Pressure"),
         selectInput(ns("link_pressure"), NULL,
                    choices = selected_pressures())
  )
),
actionButton(ns("create_link"), "Create Link",
            icon = icon("link"))

# Store links in reactive value
activity_pressure_links <- reactiveVal(data.frame(
  Activity = character(),
  Pressure = character()
))

observeEvent(input$create_link, {
  new_link <- data.frame(
    Activity = input$link_activity,
    Pressure = input$link_pressure
  )

  current_links <- activity_pressure_links()
  activity_pressure_links(rbind(current_links, new_link))
})
```

**Estimated Effort**: 6 hours

---

### 8. Terminology Issues (LOW PRIORITY) ℹ️

**Issue**: Technical terms like "nodes" not user-friendly for stakeholders.

**Current Terms** → **Suggested Terms**:
- "Nodes" → "Elements" or "Components"
- "Central Problem" → "Main Issue" or "Core Risk"
- "Escalation Factors" → "Risk Amplifiers" or "Worsening Factors"
- "Preventive Controls" → "Prevention Measures"
- "Protective Controls" → "Recovery Measures" or "Mitigation Measures"

**Fix Required**:
- Update all UI labels
- Update translations_data.R
- Update documentation

**Estimated Effort**: 2 hours

---

### 9. Node Movement Restrictions (UI/VISUAL) 🎨

**Issue**: In diagram view, can only move nodes vertically, not horizontally.

**This is a visNetwork limitation**, not a guided workflow issue.

**Possible Solutions**:
1. Update visNetwork options to allow full movement
2. Add "Reset Layout" button
3. Provide layout presets (hierarchical, circular, force-directed)

**Fix Required**:
```r
visNetwork(...) %>%
  visInteraction(
    dragNodes = TRUE,
    dragView = TRUE,
    zoomView = TRUE
  ) %>%
  visLayout(
    improvedLayout = TRUE,
    hierarchical = FALSE  # Allows free movement
  )
```

**Note**: This is in the main visualization, not guided workflow

**Estimated Effort**: 2 hours

---

### 10. Cannot Delete Nodes (UI/VISUAL) 🎨

**Issue**: In diagram view, cannot delete nodes after adding them.

**This relates to the main visualization**, not guided workflow step-by-step process.

**Fix Required**:
- Add context menu on right-click
- Add "Delete Node" option
- Update data when node deleted

**Note**: In guided workflow, use solution #4 (delete from tables)

**Estimated Effort**: 3 hours

---

### 11. Nodes Disappear (CRITICAL BUG) 🐛

**Issue**: Data/nodes disappear when "playing around with the system".

**This is a data persistence bug**

**Possible Causes**:
1. Reactive values not properly updated
2. State not saved when navigating
3. Data overwritten by empty values

**Investigation Needed**:
- Add console logging to track data changes
- Check save_step_data() function
- Verify reactive value updates

**Fix Required**:
```r
# Add debugging
observe({
  state <- workflow_state()
  cat("DEBUG - Current activities:",
      paste(state$project_data$activities, collapse = ", "), "\n")
})

# Ensure data not overwritten
save_step_data <- function(state, input) {
  # DON'T overwrite with NULL
  if (!is.null(input$activity_search)) {
    state$project_data$new_activity <- input$activity_search
  }
  # Keep existing data if input is NULL
  return(state)
}
```

**Estimated Effort**: 4 hours investigation + fix

---

### 12. Font Size Cannot Be Changed (LOW PRIORITY) ℹ️

**Issue**: Can change element size but not font size in diagram.

**Current Behavior**: Fixed font size, must zoom browser
**Expected Behavior**: Font size control

**Fix Required**:
```r
# Add font size control
sliderInput(ns("diagram_font_size"),
           "Font Size:",
           min = 8, max = 24, value = 14, step = 2)

# Apply to visNetwork
observe({
  visNetwork(...) %>%
    visNodes(font = list(size = input$diagram_font_size))
})
```

**Estimated Effort**: 1 hour

---

## 📊 Priority Matrix

| Priority | Issues | Estimated Effort |
|----------|--------|------------------|
| **CRITICAL** | #4 (Delete items), #7 (Linking), #11 (Data loss) | 14 hours |
| **HIGH** | #1 (Categories), #2 (Custom entries) | 5 hours |
| **MEDIUM** | #3 (Specify other), #6 (Escalation library) | 4 hours |
| **LOW** | #5 (Overlap), #8 (Terminology), #9 (Movement), #10 (Delete nodes), #12 (Font) | 11 hours |

**Total Estimated Effort**: 34 hours

---

## 🚀 Recommended Implementation Order

### Phase 1: Critical Fixes (Week 1)
1. **Issue #4**: Add delete functionality (4 hours)
2. **Issue #11**: Fix data disappearing bug (4 hours)
3. **Issue #1**: Filter out categories (2 hours)

**Phase 1 Total**: 10 hours

### Phase 2: High Priority (Week 2)
4. **Issue #2**: Enable custom entries (3 hours)
5. **Issue #7**: Add linking interface (6 hours)

**Phase 2 Total**: 9 hours

### Phase 3: Medium Priority (Week 3)
6. **Issue #6**: Escalation factors library (2 hours)
7. **Issue #3**: Specify "other" prompt (2 hours)

**Phase 3 Total**: 4 hours

### Phase 4: Polish (Week 4)
8. **Issue #8**: Update terminology (2 hours)
9. **Issue #12**: Font size control (1 hour)
10. **Issue #9**: Node movement (2 hours)
11. **Issue #5**: Review control overlap (3 hours)

**Phase 4 Total**: 8 hours

---

## 🧪 Testing Requirements

After each fix:
- [ ] Manual testing of affected feature
- [ ] Test with 10+ items
- [ ] Test navigation back/forth
- [ ] Test save/load progress
- [ ] Test export functionality
- [ ] Cross-browser testing
- [ ] Mobile responsiveness check

---

## 📝 Version Planning

### v5.3.3 (Phase 1 - Critical)
- Delete functionality
- Data persistence fix
- Category filtering

### v5.3.4 (Phase 2 - High Priority)
- Custom entries
- Manual linking

### v5.3.5 (Phase 3 - Medium Priority)
- Escalation library
- "Other" specification

### v5.4.0 (Phase 4 - Polish)
- Terminology updates
- UI improvements
- Full feature set

---

## 📚 Documentation Updates Needed

After fixes:
- Update QUICK_START guide
- Update USER_MANUAL
- Add LINKING_GUIDE.md
- Update screenshots
- Update video tutorials (if any)

---

## 💬 User Communication

**Interim Solution** (Before fixes):

Add help text to guide users:
```r
div(class = "alert alert-info",
   icon("info-circle"),
   h6("Tips for Current Version:"),
   tags$ul(
     tags$li("Skip category headers (ALL CAPS) - select specific items below them"),
     tags$li("Need a custom option? Contact support or use 'other' category"),
     tags$li("To remove an item, save progress and restart step"),
     tags$li("Links are created automatically based on selections")
   )
)
```

---

## 🎯 Success Criteria

Fixes successful when:
- [ ] Users cannot select category headers
- [ ] Users can add custom entries (>3 chars)
- [ ] Users can delete any selected item
- [ ] Data persists through navigation
- [ ] Manual linking works for all connections
- [ ] Escalation factors have 20+ library options
- [ ] "Other" prompts for specification
- [ ] Zero data loss reports
- [ ] User satisfaction survey >4.0/5.0

---

## 🔗 Related Issues

- Template system (already fixed in v5.3.2)
- Export functionality (already fixed in v5.3.2)
- Server disconnection (already fixed in v5.3.2)

---

**Next Steps**:
1. Review and prioritize with stakeholders
2. Create detailed technical specifications for Phase 1
3. Set up development branch for v5.3.3
4. Begin implementation

---

*Document created: December 2, 2025*
*Status: Awaiting approval for implementation*
*Target: v5.3.3 release in 2 weeks*
