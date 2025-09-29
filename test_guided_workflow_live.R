# Live Test of Guided Workflow System
# This script tests the key functionality while the app is running

cat("🧪 GUIDED WORKFLOW LIVE TESTING\n")
cat("===============================\n")

# Test 1: Validate all workflow steps are available
cat("1. Testing workflow step availability...\n")
if (exists("WORKFLOW_CONFIG")) {
  cat("✅ WORKFLOW_CONFIG available with", length(WORKFLOW_CONFIG$steps), "steps\n")
  for (i in 1:length(WORKFLOW_CONFIG$steps)) {
    step_name <- names(WORKFLOW_CONFIG$steps)[i]
    step_title <- WORKFLOW_CONFIG$steps[[i]]$title
    cat("   Step", i, ":", step_title, "\n")
  }
} else {
  cat("❌ WORKFLOW_CONFIG not available\n")
}

# Test 2: Check guided workflow functions
cat("\n2. Testing guided workflow functions...\n")
required_functions <- c(
  "guided_workflow_ui",
  "guided_workflow_server",
  "create_guided_workflow_tab",
  "init_workflow_state"
)

for (func in required_functions) {
  if (exists(func, mode = "function")) {
    cat("✅", func, "available\n")
  } else {
    cat("❌", func, "missing\n")
  }
}

# Test 3: Test step UI generation functions
cat("\n3. Testing step UI generation...\n")
step_functions <- c(
  "generate_step1_ui",
  "generate_step2_ui",
  "generate_step3_ui",
  "generate_step4_ui",
  "generate_step5_ui",
  "generate_step6_ui",
  "generate_step7_ui",
  "generate_step8_ui"
)

for (func in step_functions) {
  if (exists(func, mode = "function")) {
    cat("✅", func, "available\n")
  } else {
    cat("❌", func, "missing\n")
  }
}

# Test 4: Test workflow state initialization
cat("\n4. Testing workflow state initialization...\n")
if (exists("init_workflow_state", mode = "function")) {
  tryCatch({
    test_state <- init_workflow_state()
    required_fields <- c("current_step", "total_steps", "project_data",
                        "project_name", "central_problem", "workflow_complete")

    missing_fields <- setdiff(required_fields, names(test_state))
    if (length(missing_fields) == 0) {
      cat("✅ Workflow state structure complete\n")
      cat("   Current step:", test_state$current_step, "\n")
      cat("   Total steps:", test_state$total_steps, "\n")
      cat("   Project data structure:", length(test_state$project_data), "fields\n")
    } else {
      cat("❌ Missing fields:", paste(missing_fields, collapse = ", "), "\n")
    }
  }, error = function(e) {
    cat("❌ Error initializing workflow state:", e$message, "\n")
  })
} else {
  cat("❌ init_workflow_state function not available\n")
}

# Test 5: Test vocabulary data integration
cat("\n5. Testing vocabulary data availability...\n")
if (exists("vocabulary_data")) {
  vocab_items <- c("activities", "pressures", "consequences", "controls")
  for (item in vocab_items) {
    if (!is.null(vocabulary_data[[item]]) && nrow(vocabulary_data[[item]]) > 0) {
      cat("✅", item, ":", nrow(vocabulary_data[[item]]), "items\n")
    } else {
      cat("⚠️", item, ": no data\n")
    }
  }
} else {
  cat("❌ vocabulary_data not available\n")
}

# Test 6: Test template system
cat("\n6. Testing template system...\n")
if (exists("WORKFLOW_CONFIG") && !is.null(WORKFLOW_CONFIG$templates)) {
  template_count <- length(WORKFLOW_CONFIG$templates)
  cat("✅ Templates available:", template_count, "\n")
  for (template_id in names(WORKFLOW_CONFIG$templates)) {
    template <- WORKFLOW_CONFIG$templates[[template_id]]
    cat("   -", template$name, "(", template$category, ")\n")
  }
} else {
  cat("❌ Template system not available\n")
}

cat("\n🎯 LIVE TESTING COMPLETE\n")
cat("App is running on: http://0.0.0.0:3838\n")
cat("Access from network: http://192.168.1.8:3838\n")
cat("================================\n")