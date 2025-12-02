# Test script to verify template functionality
# This script tests that all environmental scenarios have corresponding templates

cat("🧪 Testing Template Configuration...\n\n")

# Load the necessary files
source("environmental_scenarios.R")
source("guided_workflow.R", local = TRUE)

# Get scenario choices
scenario_choices <- getEnvironmentalScenarioChoices(include_blank = TRUE)
cat("📋 Available scenarios:", length(scenario_choices) - 1, "\n")  # -1 for blank option
print(names(scenario_choices))

cat("\n🎯 Testing template availability...\n")

# Check each scenario has a corresponding template
missing_templates <- c()
for (scenario_id in scenario_choices) {
  if (scenario_id == "") next  # Skip blank option

  template <- WORKFLOW_CONFIG$templates[[scenario_id]]
  if (is.null(template)) {
    cat("❌ Missing template for:", scenario_id, "\n")
    missing_templates <- c(missing_templates, scenario_id)
  } else {
    cat("✅", scenario_id, "->", template$name, "\n")
  }
}

if (length(missing_templates) == 0) {
  cat("\n🎉 All scenarios have corresponding templates!\n")
} else {
  cat("\n⚠️ Missing templates for", length(missing_templates), "scenarios:\n")
  print(missing_templates)
}

# Test template data completeness
cat("\n📊 Testing template data completeness...\n")
required_fields <- c("project_name", "project_location", "project_type",
                     "project_description", "central_problem", "problem_category",
                     "problem_details", "problem_scale", "problem_urgency")

incomplete_templates <- c()
for (template_id in names(WORKFLOW_CONFIG$templates)) {
  template <- WORKFLOW_CONFIG$templates[[template_id]]
  missing_fields <- c()

  for (field in required_fields) {
    if (is.null(template[[field]])) {
      missing_fields <- c(missing_fields, field)
    }
  }

  if (length(missing_fields) > 0) {
    cat("⚠️", template_id, "missing:", paste(missing_fields, collapse = ", "), "\n")
    incomplete_templates <- c(incomplete_templates, template_id)
  }
}

if (length(incomplete_templates) == 0) {
  cat("✅ All templates have complete data!\n")
} else {
  cat("⚠️", length(incomplete_templates), "templates have missing fields\n")
}

cat("\n✅ Template test complete!\n")
