# =============================================================================
# Guided Workflow Integration Guide
# Version: 1.0.0
# Date: September 2025
# Description: Complete integration instructions and demo for guided workflow
# =============================================================================

cat("🔧 GUIDED WORKFLOW INTEGRATION GUIDE\n")
cat("====================================\n\n")

# =============================================================================
# INTEGRATION INSTRUCTIONS
# =============================================================================

integration_instructions <- function() {
  cat("📋 STEP-BY-STEP INTEGRATION INSTRUCTIONS\n")
  cat("========================================\n\n")
  
  cat("1. 📂 FILE SETUP:\n")
  cat("   - guided_workflow.r (main workflow engine)\n")
  cat("   - guided_workflow_steps.r (complete step implementations)\n")
  cat("   - guided_workflow_integration.r (this file)\n\n")
  
  cat("2. 🔧 ADD TO YOUR APP.R:\n")
  cat("   A. In the source section (after line 38):\n")
  cat('      source("guided_workflow.r")\n')
  cat('      source("guided_workflow_steps.r")\n\n')
  
  cat("   B. In the UI section (add new tab to navset_card_tab):\n")
  cat("      Add after existing tabs (around line 200):\n\n")
  
  ui_code <- '
    # Guided Workflow Tab
    nav_panel(
      title = "🧙 Guided Creation",
      icon = icon("magic-wand-sparkles"),
      value = "guided_workflow",
      guided_workflow_ui()
    ),
  '
  
  cat(ui_code)
  cat("\n")
  
  cat("   C. In the server section (add after line 930):\n")
  cat("      Add this server logic:\n\n")
  
  server_code <- '
  # Guided Workflow Server Logic
  guided_workflow_state <- guided_workflow_server(
    input, output, session, 
    vocabulary_data = vocabulary_data
  )
  
  # Optional: React to workflow completion
  observeEvent(guided_workflow_state()$workflow_complete, {
    showNotification("🎉 Bowtie workflow completed successfully!", 
                    type = "success", duration = 5)
    
    # Auto-switch to visualization tab
    updateNavsetCardTab(session, "main_tabs", selected = "network_viz")
  })
  '
  
  cat(server_code)
  cat("\n")
  
  cat("3. 🎨 OPTIONAL CUSTOMIZATION:\n")
  cat("   - Modify WORKFLOW_CONFIG in guided_workflow.r\n")
  cat("   - Add custom templates for your domain\n")
  cat("   - Customize step validation rules\n")
  cat("   - Add organization-specific guidance\n\n")
  
  cat("4. ✅ INTEGRATION COMPLETE!\n")
  cat("   Your app will now have a '🧙 Guided Creation' tab\n")
  cat("   Users can follow the 8-step wizard to create bowtie diagrams\n\n")
}

# =============================================================================
# DEMO SYSTEM
# =============================================================================

demo_guided_workflow <- function() {
  cat("🎭 GUIDED WORKFLOW DEMO\n")
  cat("======================\n")
  
  # Load the workflow system
  tryCatch({
    source("guided_workflow.r")
    source("guided_workflow_steps.r")
    cat("✅ Guided workflow system loaded successfully\n")
    
    # Display workflow configuration
    cat("\n📋 WORKFLOW CONFIGURATION:\n")
    for (i in 1:length(WORKFLOW_CONFIG$steps)) {
      step <- WORKFLOW_CONFIG$steps[[i]]
      cat(sprintf("   Step %d: %s (%s)\n", i, step$title, step$estimated_time))
    }
    
    cat("\n🎯 AVAILABLE TEMPLATES:\n")
    for (template_id in names(WORKFLOW_CONFIG$templates)) {
      template <- WORKFLOW_CONFIG$templates[[template_id]]
      cat(sprintf("   %s: %s\n", template$name, template$central_problem))
    }
    
    cat("\n✅ Demo complete! System ready for integration.\n")
    
  }, error = function(e) {
    cat("❌ Error loading guided workflow:", e$message, "\n")
  })
}

# =============================================================================
# TESTING FUNCTIONS
# =============================================================================

test_workflow_components <- function() {
  cat("🧪 TESTING WORKFLOW COMPONENTS\n")
  cat("==============================\n")
  
  # Test 1: Initialize workflow state
  cat("1. Testing workflow state initialization...\n")
  tryCatch({
    state <- init_workflow_state()
    cat(sprintf("   ✅ Initial state: Step %d/%d, Progress: %.1f%%\n", 
               state$current_step, state$total_steps, state$progress_percentage))
  }, error = function(e) {
    cat("   ❌ Error initializing state:", e$message, "\n")
  })
  
  # Test 2: Progress update
  cat("2. Testing progress updates...\n")
  tryCatch({
    state <- update_workflow_progress(state, step_number = 3)
    cat(sprintf("   ✅ Updated state: Step %d, Completed: %s\n", 
               state$current_step, paste(state$completed_steps, collapse = ", ")))
  }, error = function(e) {
    cat("   ❌ Error updating progress:", e$message, "\n")
  })
  
  # Test 3: Template application
  cat("3. Testing template application...\n")
  tryCatch({
    state <- apply_template("marine_pollution", state)
    cat("   ✅ Template applied:", state$project_data$central_problem, "\n")
  }, error = function(e) {
    cat("   ❌ Error applying template:", e$message, "\n")
  })
  
  # Test 4: Validation functions
  cat("4. Testing validation functions...\n")
  tryCatch({
    validation <- validate_step1(list(project_name = "Test Project"))
    cat(sprintf("   ✅ Step 1 validation: %s\n", 
               if(validation$valid) "PASSED" else "FAILED"))
  }, error = function(e) {
    cat("   ❌ Error in validation:", e$message, "\n")
  })
  
  cat("\n✅ Component testing complete!\n")
}

# =============================================================================
# CUSTOMIZATION HELPERS
# =============================================================================

create_custom_template <- function(name, central_problem, category, 
                                 example_activities, example_pressures) {
  template <- list(
    name = name,
    central_problem = central_problem,
    example_activities = example_activities,
    example_pressures = example_pressures,
    category = category
  )
  
  cat("🎨 CUSTOM TEMPLATE CREATED:\n")
  cat("Name:", name, "\n")
  cat("Problem:", central_problem, "\n")
  cat("Category:", category, "\n")
  cat("Activities:", paste(example_activities, collapse = ", "), "\n")
  cat("Pressures:", paste(example_pressures, collapse = ", "), "\n\n")
  
  cat("To add to your workflow, append to WORKFLOW_CONFIG$templates:\n")
  cat(sprintf('WORKFLOW_CONFIG$templates$%s <- list(\n', gsub("[^a-z0-9_]", "_", tolower(name))))
  cat(sprintf('  name = "%s",\n', name))
  cat(sprintf('  central_problem = "%s",\n', central_problem))
  cat(sprintf('  category = "%s"\n', category))
  cat(')\n\n')
  
  return(template)
}

# =============================================================================
# MAIN DEMO FUNCTION
# =============================================================================

run_complete_demo <- function() {
  cat("🚀 COMPLETE GUIDED WORKFLOW DEMO\n")
  cat("================================\n\n")
  
  # Step 1: Show integration instructions
  integration_instructions()
  
  cat("\n" + paste(rep("=", 50), collapse = "") + "\n\n")
  
  # Step 2: Demo the system
  demo_guided_workflow()
  
  cat("\n" + paste(rep("=", 50), collapse = "") + "\n\n")
  
  # Step 3: Test components
  test_workflow_components()
  
  cat("\n" + paste(rep("=", 50), collapse = "") + "\n\n")
  
  # Step 4: Show customization example
  cat("🎨 CUSTOMIZATION EXAMPLE:\n")
  create_custom_template(
    name = "Urban Air Quality Assessment",
    central_problem = "Urban air pollution and health impacts",
    category = "Urban Environment",
    example_activities = c("Vehicle emissions", "Industrial activities", "Construction"),
    example_pressures = c("PM2.5 concentrations", "NOx emissions", "Dust particles")
  )
  
  cat("\n🎉 COMPLETE DEMO FINISHED!\n")
  cat("================================\n")
  cat("Your guided workflow system is ready for integration!\n")
  cat("Users will have access to:\n")
  cat("  - 8-step guided bowtie creation\n")
  cat("  - 3 pre-built templates\n")
  cat("  - Progress tracking and validation\n")
  cat("  - Expert guidance at each step\n")
  cat("  - Professional export options\n\n")
}

cat("✅ Guided Workflow Integration System Ready!\n")
cat("📋 Available functions:\n")
cat("   - run_complete_demo(): Complete demonstration\n")
cat("   - integration_instructions(): Step-by-step integration guide\n")
cat("   - demo_guided_workflow(): System demonstration\n")
cat("   - test_workflow_components(): Component testing\n")
cat("   - create_custom_template(): Template creation helper\n")
cat("\n🎯 Run: run_complete_demo() to see everything!\n")