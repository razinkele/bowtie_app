# Debug Guide: AI Suggestions Testing

## 🔍 Application Status

✅ App is running with **extensive debug logging** enabled
✅ Access at: **http://localhost:4848**

---

## 📊 What the Debug Logs Show

### Current Startup Logs:
```
🔍 [AI SUGGESTIONS] Pressure observer triggered!
🔍 [AI SUGGESTIONS] Got workflow state
🔍 [AI SUGGESTIONS] State structure: current_step, total_steps, completed_steps, project_data, ...
🔍 [AI SUGGESTIONS] project_data structure: template_applied, project_type, project_location, ...
🔍 [AI SUGGESTIONS] Selected activities: NULL
🔍 [AI SUGGESTIONS] Activity count: 0
🔍 [AI SUGGESTIONS] No activities selected - hiding suggestions UI
```

**Key Finding:** The observer IS working and triggers at startup. It correctly detects no activities.

---

## 🧪 Test Procedure

### Step 1: Open the Application
1. Go to: http://localhost:4848
2. Navigate to: **Guided Creation** tab
3. Go to: **Step 3: Threats & Causes**

### Step 2: Add an Activity
1. Select **Activity Group**: "SHIPPING & NAVIGATION"
2. Select **Specific Activity**: "Commercial shipping operations"
3. Click **"Add Activity"** button
4. ✅ Activity should appear in "Selected Activities" table

### Step 3: Watch the Console

**IMPORTANT:** Keep the console window visible where you started `Rscript start_app.R`

**After clicking "Add Activity", look for these debug messages:**

```
🔍 [AI SUGGESTIONS] Pressure observer triggered!
🔍 [AI SUGGESTIONS] Got workflow state
🔍 [AI SUGGESTIONS] Selected activities: Commercial shipping operations
🔍 [AI SUGGESTIONS] Activity count: 1
🔍 [AI SUGGESTIONS] Activities found! Showing loading UI...
🔍 [AI SUGGESTIONS] Starting suggestion generation...
🔍 [CONVERT] convert_to_item_list called
🔍 [CONVERT] vocab_type: Activity
🔍 [CONVERT] names_vector: Commercial shipping operations
🔍 [CONVERT] Processing item: 'Commercial shipping operations'
🔍 [CONVERT] Matching rows found: 1
🔍 [CONVERT] Found in vocabulary! ID: 1.2.3
🔍 [AI SUGGESTIONS] Calling generate_ai_suggestions()...
🔍 [AI SUGGESTIONS] generate_ai_suggestions() returned. Count: 5
🔍 [AI SUGGESTIONS] Got 5 suggestions! Rendering UI...
✅ [AI SUGGESTIONS] Pressure suggestions displayed successfully!
```

---

## ❓ What to Report

### If Observer Doesn't Trigger After Adding Activity:

**You'll see:**
- ❌ No new debug messages after clicking "Add Activity"
- ❌ Only the startup messages remain

**This means:** The observer is not watching the right reactive dependency

**Report:** "Observer not re-triggering when activity added"

---

### If Observer Triggers But No Activities Found:

**You'll see:**
```
🔍 [AI SUGGESTIONS] Pressure observer triggered!
🔍 [AI SUGGESTIONS] Selected activities: NULL
🔍 [AI SUGGESTIONS] Activity count: 0
```

**This means:** Activities are not being stored in `state$project_data$activities`

**Report:** "Activities not being stored correctly in workflow state"

---

### If Observer Triggers But Conversion Fails:

**You'll see:**
```
🔍 [CONVERT] convert_to_item_list called
🔍 [CONVERT] Matching rows found: 0
🔍 [CONVERT] Not found in vocabulary - creating custom entry
```

**This means:** Activity name doesn't match vocabulary names

**Report:** "Activity name mismatch in vocabulary lookup"

---

### If Suggestions Generation Fails:

**You'll see:**
```
❌ [AI SUGGESTIONS] ERROR in pressure suggestions:
   Error message: ...
```

**This means:** The `generate_ai_suggestions()` function is failing

**Report:** Copy the full error message and traceback

---

### If Everything Works:

**You'll see:**
```
✅ [AI SUGGESTIONS] Pressure suggestions displayed successfully!
```

**AND in the browser:**
- Suggestion cards appear in "🤖 AI-Powered Pressure Suggestions" panel
- Can click suggestions to add them

---

## 📋 Debug Output Sections

### Section 1: Observer Trigger
```
🔍 [AI SUGGESTIONS] Pressure observer triggered!
```
**Meaning:** The observer is running. This should appear:
- Once at startup
- Every time workflow_state() changes (including when activity added)

---

### Section 2: State Inspection
```
🔍 [AI SUGGESTIONS] State structure: ...
🔍 [AI SUGGESTIONS] project_data structure: ...
```
**Meaning:** Shows what fields exist in the state

---

### Section 3: Activity Detection
```
🔍 [AI SUGGESTIONS] Selected activities: Commercial shipping operations
🔍 [AI SUGGESTIONS] Activity count: 1
```
**Meaning:** Observer found the activities in the state

---

### Section 4: Conversion
```
🔍 [CONVERT] convert_to_item_list called
🔍 [CONVERT] Processing item: '...'
🔍 [CONVERT] Matching rows found: N
```
**Meaning:** Converting activity names to vocab item format

---

### Section 5: Suggestion Generation
```
🔍 [AI SUGGESTIONS] Calling generate_ai_suggestions()...
🔍 [AI SUGGESTIONS] generate_ai_suggestions() returned. Count: N
```
**Meaning:** AI function is generating suggestions

---

### Section 6: UI Rendering
```
🔍 [AI SUGGESTIONS] Got N suggestions! Rendering UI...
✅ [AI SUGGESTIONS] Pressure suggestions displayed successfully!
```
**Meaning:** Suggestions are being displayed in the UI

---

## 🎯 Most Likely Issues

### Issue 1: Observer Not Re-Triggering
**Symptom:** No new logs after adding activity
**Cause:** Observer not properly watching `workflow_state()`
**Fix:** Modify observer to explicitly invalidate on state changes

---

### Issue 2: Activities Stored in Wrong Field
**Symptom:** Logs show "Selected activities: NULL" after adding
**Cause:** Activities might be stored elsewhere (like `example_activities`)
**Fix:** Update observer to check correct field name

---

### Issue 3: Namespace Issues
**Symptom:** Button clicks don't trigger observer
**Cause:** Input IDs might have namespace prefix issues
**Fix:** Check input namespacing in add_activity observer

---

## 📞 What to Send Me

**After testing, please provide:**

1. **Screenshot of "Selected Activities" table** (after adding activity)

2. **Full console output** from when you clicked "Add Activity" button:
   - Copy all lines starting with 🔍 [AI SUGGESTIONS]
   - Copy all lines starting with 🔍 [CONVERT]
   - Include any error messages

3. **Browser console output** (F12 → Console tab):
   - Any JavaScript errors
   - Any network request failures

4. **What you see in the UI**:
   - Does the "Add Activity" button work?
   - Does activity appear in table?
   - Do you see loading spinner in AI suggestions panel?
   - Do suggestions appear?

---

## 🔧 Quick Test Commands

**Check if app is running:**
```bash
netstat -ano | findstr :4848
```

**View live console output:**
```bash
# Output file location:
C:\Users\DELL\AppData\Local\Temp\claude\C--Users-DELL-OneDrive---ku-lt-HORIZON-EUROPE-bowtie-app\tasks\bb82788.output
```

**Restart app if needed:**
```bash
# Kill current app (if needed)
taskkill /F /IM Rscript.exe

# Start with visible output
Rscript start_app.R
```

---

## ✅ Success Criteria

**AI Suggestions are working if you see:**
1. ✅ Activity appears in "Selected Activities" table
2. ✅ Console shows: `🔍 [AI SUGGESTIONS] Activity count: 1`
3. ✅ Console shows: `✅ [AI SUGGESTIONS] Pressure suggestions displayed successfully!`
4. ✅ Browser shows suggestion cards in AI panel
5. ✅ Can click suggestion cards to add pressures

---

*Debug version created: December 30, 2025*
*Purpose: Diagnose why AI suggestions don't appear after selecting activities*
*Key: Look for 🔍 prefixed messages in console output*
