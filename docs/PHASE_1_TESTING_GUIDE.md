# Phase 1: Foundation - Testing & Validation Guide

**Version**: 1.0
**Date**: 2025-12-26
**Status**: Ready for Testing

---

## Overview

This guide provides comprehensive testing procedures for all Phase 1 UI/UX improvements. Complete each section to validate that all components work correctly and meet accessibility standards.

---

## 🎯 Testing Objectives

1. **Functional Testing**: Verify all components work as intended
2. **Accessibility Testing**: Ensure WCAG AA compliance
3. **Cross-browser Testing**: Validate across major browsers
4. **Responsive Testing**: Confirm mobile and desktop compatibility
5. **User Experience Testing**: Validate smooth user workflows

---

## 📋 Testing Checklist

### 1. UI Components Library

#### Empty State Components
- [ ] **Data Preview Empty State**
  - Navigate to Data Upload tab
  - Without loading data, verify empty state displays
  - Verify "Upload Data" button navigates to upload section
  - Verify "Generate Sample" button navigates to generate section
  - Check icon displays correctly (table icon)
  - Verify message is clear and helpful

- [ ] **Bowtie Network Empty State**
  - Navigate to Bowtie Diagram tab without data
  - Verify enhanced empty state with network icon
  - Verify action buttons present and functional
  - Check message clarity

- [ ] **Bayesian Network Empty States** (2 states)
  - Test "No data loaded" state (before data upload)
  - Test "Network not created" state (after data upload, before network creation)
  - Verify both states display correctly
  - Verify upload button works in first state

- [ ] **Vocabulary Search Empty State**
  - Navigate to Vocabulary tab
  - Go to "Search Results" sub-tab
  - Verify search empty state displays
  - Check search icon and message

- [ ] **Risk Matrix Empty State**
  - Navigate to Risk Matrix tab without data
  - Verify empty state with chart icon
  - Verify primary and secondary action buttons
  - Test button navigation

#### Form Validation Components
- [ ] **Project Name Validation (Step 1)**
  - Open Guided Workflow
  - Try entering 1 character - should show error (min 3)
  - Try entering 101+ characters - should show error (max 100)
  - Enter valid name (3-100 chars) - should show green checkmark
  - Verify red asterisk indicates required field
  - Check help text displays

- [ ] **Project Location Validation (Step 1)**
  - Try entering 1 character - should show error (min 2)
  - Enter valid location - should show green checkmark
  - Verify required field indicator

- [ ] **Project Type Validation (Step 1)**
  - Verify dropdown is required
  - Select a value - should accept
  - Verify help text displays

- [ ] **Problem Statement Validation (Step 2)**
  - Navigate to Step 2
  - Try entering 4 characters - should show error (min 5)
  - Try entering 201+ characters - should show error (max 200)
  - Enter valid statement - should show green checkmark

- [ ] **Custom Entry Validations (Steps 3-6)**
  - Test activity_custom_text validation
  - Test pressure_custom_text validation
  - Test preventive_control_custom_text validation
  - Test consequence_custom_text validation
  - Test protective_control_custom_text validation
  - Each should enforce 3-100 character limit

#### Error Display Components
- [ ] **Data Loading Error Display**
  - Upload an invalid file (wrong format)
  - Verify error display appears
  - Check title: "Data Loading Error"
  - Verify 4 recovery suggestions display
  - Verify technical details are collapsible
  - Click "Retry" button - should clear error and focus file input
  - Verify Bootstrap alert styling (red/danger)

- [ ] **Data Generation Error Display**
  - Simulate generation error (if possible)
  - Verify error display with suggestions
  - Test retry button functionality

- [ ] **Bayesian Network Error Display**
  - Create network with invalid data
  - Verify error display appears
  - Check suggestions are helpful
  - Test retry button

- [ ] **Bayesian Inference Error Display**
  - Trigger inference error
  - Verify error display
  - Test retry functionality

- [ ] **Vocabulary Error Display**
  - Test vocabulary loading error scenario
  - Verify error display in vocabulary browser
  - Test retry button

---

### 2. Accessibility Features

#### ARIA Labels
- [ ] **Settings Button (Gear Icon)**
  - Use browser inspector to verify `aria-label="Open settings panel"`
  - Test with screen reader - should announce label

- [ ] **Help Button (Question Circle Icon)**
  - Verify `aria-label="Show bowtie diagram legend and help"`
  - Test with screen reader

- [ ] **All Icon-Only Buttons**
  - Review all buttons without text labels
  - Verify each has appropriate aria-label
  - Test with screen reader for clarity

#### ARIA Live Regions
- [ ] **Notification Announcer**
  - Load data successfully
  - Verify screen reader announces success message
  - Trigger an error
  - Verify screen reader announces error message
  - Check announcements are polite (don't interrupt)

#### Keyboard Navigation
- [ ] **Skip Links**
  - Press Tab immediately after page load
  - Verify "Skip to main content" link appears
  - Press Enter on skip link
  - Verify focus moves to main content area

- [ ] **Keyboard Shortcuts**
  - Press **Alt+G** - should navigate to Guided Workflow tab
  - Press **Alt+D** - should navigate to Data Upload tab
  - Press **Alt+V** - should navigate to Visualization/Bowtie tab
  - Press **Escape** with modal open - should close modal
  - Verify shortcuts work consistently

- [ ] **Tab Navigation**
  - Use Tab key to navigate through entire page
  - Verify focus is visible on all interactive elements
  - Verify tab order is logical
  - No elements should be unreachable by keyboard

- [ ] **Focus Management**
  - Verify focus outlines are visible
  - Check focus doesn't get trapped
  - Verify focus returns appropriately after actions

#### Screen Reader Testing
- [ ] **NVDA/JAWS Testing** (if available)
  - Navigate entire application with screen reader
  - Verify all content is readable
  - Test form inputs are properly labeled
  - Verify error messages are announced
  - Check table navigation works
  - Verify network diagrams have alt text or descriptions

---

### 3. Form Validation System

#### Real-Time Validation
- [ ] **Character Counter**
  - Type in project name field
  - Verify character count updates in real-time (if implemented)
  - Verify validation triggers as you type

- [ ] **Visual Feedback**
  - Valid input shows green border and checkmark
  - Invalid input shows red border and error message
  - Required fields show red asterisk (*)
  - Help text displays below each field

#### Server-Side Validation
- [ ] **Submit Validation**
  - Try submitting form with empty required fields
  - Verify validation prevents submission
  - Verify all errors highlight simultaneously
  - Fix errors and verify submission works

#### Edge Cases
- [ ] **Whitespace Handling**
  - Try entering only spaces
  - Verify validation rejects whitespace-only input

- [ ] **Special Characters**
  - Test inputs with special characters
  - Verify they're handled appropriately

- [ ] **Unicode Characters**
  - Test non-ASCII characters
  - Verify system handles them correctly

---

### 4. Cross-Browser Testing

Test the following in each browser:

#### Chrome/Chromium
- [ ] Empty states render correctly
- [ ] Form validation works
- [ ] Error displays show properly
- [ ] ARIA features functional
- [ ] Keyboard shortcuts work
- [ ] CSS styling correct

#### Firefox
- [ ] All components display correctly
- [ ] JavaScript validation works
- [ ] Keyboard navigation functional
- [ ] No console errors

#### Safari (if available)
- [ ] Component rendering
- [ ] Validation functionality
- [ ] Accessibility features

#### Edge
- [ ] Full functionality check
- [ ] CSS compatibility
- [ ] JavaScript compatibility

---

### 5. Responsive Design Testing

#### Desktop (1920x1080)
- [ ] Layout is appropriate
- [ ] All components visible
- [ ] No horizontal scrolling
- [ ] Text is readable

#### Laptop (1366x768)
- [ ] Components adapt correctly
- [ ] No layout breaking
- [ ] Functionality maintained

#### Tablet (768x1024)
- [ ] Mobile-friendly layout
- [ ] Touch targets appropriate size
- [ ] Forms usable on touch devices

#### Mobile (375x667)
- [ ] Fully responsive layout
- [ ] All features accessible
- [ ] Touch interactions work
- [ ] Text remains readable

---

### 6. User Workflow Testing

#### Workflow 1: New User - Upload Data
1. [ ] User lands on application
2. [ ] Sees empty state in Data Preview
3. [ ] Clicks "Upload Data" button from empty state
4. [ ] Navigates to upload section
5. [ ] Uploads file successfully
6. [ ] Empty state disappears, data table shows
7. [ ] No errors encountered

#### Workflow 2: New User - Generate Sample
1. [ ] User lands on application
2. [ ] Clicks "Generate Sample" from empty state
3. [ ] Selects environmental scenario
4. [ ] Clicks generate button
5. [ ] Data generates successfully
6. [ ] Can view bowtie diagram
7. [ ] Can create Bayesian network

#### Workflow 3: Guided Workflow Completion
1. [ ] User navigates to Guided Workflow
2. [ ] Completes Step 1 with validated inputs
3. [ ] Form validation prevents invalid submission
4. [ ] Progresses through all 8 steps
5. [ ] Exports completed workflow
6. [ ] Reviews bowtie in main visualization

#### Workflow 4: Error Recovery
1. [ ] User triggers error (e.g., upload invalid file)
2. [ ] Error display appears with suggestions
3. [ ] User reads suggestions
4. [ ] User clicks "Retry" button
5. [ ] Error clears, user can retry action
6. [ ] Successful completion after retry

#### Workflow 5: Keyboard-Only Navigation
1. [ ] User navigates entire app using only keyboard
2. [ ] Uses Tab to move between elements
3. [ ] Uses Enter/Space to activate buttons
4. [ ] Uses arrow keys in dropdowns
5. [ ] Uses keyboard shortcuts (Alt+G, etc.)
6. [ ] Completes full workflow without mouse

---

## 🔍 Detailed Testing Procedures

### Testing Empty States

**Procedure:**
1. Open application in clean state (no data loaded)
2. Navigate to each tab that implements empty states
3. For each empty state:
   - Verify icon displays correctly
   - Read message for clarity and helpfulness
   - Click each action button
   - Verify navigation works correctly
   - Check responsive behavior

**Expected Results:**
- Empty states display when no data is present
- Icons are centered and appropriately sized
- Messages are clear and actionable
- Action buttons navigate to correct sections
- Layout is responsive

**How to Fail:**
- Empty state doesn't appear when expected
- Icon is missing or broken
- Message is unclear or unhelpful
- Buttons don't navigate correctly
- Layout breaks on mobile

---

### Testing Form Validation

**Procedure:**
1. Navigate to Guided Workflow
2. For each validated input:
   - Leave field empty (if required)
   - Enter text below minimum length
   - Enter text above maximum length
   - Enter valid text
3. Observe visual feedback
4. Attempt to submit/proceed

**Expected Results:**
- Required fields show asterisk (*)
- Invalid input shows red border
- Error message displays below field
- Valid input shows green border and checkmark
- Help text provides guidance
- Cannot proceed with invalid input

**How to Fail:**
- Validation doesn't trigger
- Visual feedback is unclear
- Can submit invalid data
- Error messages are unhelpful

---

### Testing Error Displays

**Procedure:**
1. Trigger each error type:
   - Upload invalid file → Data loading error
   - Generate with issue → Data generation error
   - Create network with bad data → Bayesian network error
   - Run inference incorrectly → Inference error
   - Corrupt vocabulary files → Vocabulary error
2. For each error:
   - Read error title and message
   - Expand technical details
   - Read all suggestions
   - Click retry button
   - Verify error clears

**Expected Results:**
- Error displays appear immediately
- Title is clear and descriptive
- Message explains what went wrong
- Technical details are collapsible
- Suggestions are actionable and helpful
- Retry button clears error and retriggers action
- Error displays are dismissible

**How to Fail:**
- Error doesn't display
- Message is confusing
- Suggestions are generic/unhelpful
- Retry button doesn't work
- Error persists after retry

---

### Testing Accessibility

**Procedure:**
1. **Keyboard Navigation Test:**
   - Disconnect mouse
   - Navigate entire app with keyboard only
   - Complete a full workflow
   - Verify all features accessible

2. **Screen Reader Test:**
   - Enable screen reader (NVDA/JAWS)
   - Navigate through all tabs
   - Fill out forms
   - Trigger errors
   - Verify all content is announced

3. **Focus Visibility Test:**
   - Tab through all interactive elements
   - Verify focus indicator visible
   - Check focus doesn't get trapped

**Expected Results:**
- All features accessible via keyboard
- Screen reader announces all content clearly
- Focus indicator is always visible
- Logical tab order throughout
- Skip links work correctly
- Keyboard shortcuts functional

**How to Fail:**
- Features unreachable by keyboard
- Screen reader can't announce content
- Focus indicator invisible or unclear
- Tab order is illogical
- Users get trapped in sections

---

## 📊 Test Results Template

Use this template to document test results:

```markdown
## Test Session: [Date/Time]
**Tester**: [Name]
**Browser**: [Chrome/Firefox/Safari/Edge] [Version]
**Screen Size**: [Resolution]

### Component: [Component Name]

#### Test: [Test Name]
- **Status**: ✅ Pass / ❌ Fail / ⚠️ Partial
- **Notes**: [Observations]
- **Issues Found**: [List any issues]
- **Screenshots**: [If applicable]

#### Test: [Next Test]
...
```

---

## 🐛 Issue Reporting Template

When issues are found, document them as follows:

```markdown
### Issue #[Number]: [Brief Description]

**Component**: [Which component]
**Severity**: Critical / High / Medium / Low
**Browser**: [Browser and version]
**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior**: [What should happen]
**Actual Behavior**: [What actually happens]
**Screenshots**: [If applicable]
**Suggested Fix**: [If known]
```

---

## ✅ Completion Criteria

Phase 1 testing is complete when:

1. [ ] All checklist items are tested and pass
2. [ ] All components work across major browsers
3. [ ] Accessibility standards are met (WCAG AA)
4. [ ] No critical or high-severity bugs remain
5. [ ] User workflows complete successfully
6. [ ] Documentation is updated with any findings
7. [ ] Final sign-off from stakeholders

---

## 🎯 Next Steps After Testing

1. **Document Results**: Complete test results template
2. **File Issues**: Create issues for any bugs found
3. **Fix Critical Issues**: Address any blocking problems
4. **Update Documentation**: Reflect any changes made
5. **Phase 1 Completion**: Mark Phase 1 as 100% complete
6. **Phase 2 Planning**: Begin planning Phase 2 improvements

---

**Testing Guide Version**: 1.0
**Last Updated**: 2025-12-26
**Phase**: 1 - Foundation
**Status**: Ready for Validation

---

*This testing guide ensures comprehensive validation of all Phase 1 UI/UX improvements before deployment.*
