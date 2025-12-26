# =============================================================================
# Test Script for Intelligent Bowtie Suggestion Engine
# Demonstrates how to use the knowledge-based suggestion system
# =============================================================================

# Load the suggestion engine
source("intelligent_bowtie_suggester.R")

cat("\n")
cat("=================================================================\n")
cat("INTELLIGENT BOWTIE SUGGESTION ENGINE - TEST & DEMONSTRATION\n")
cat("=================================================================\n\n")

# Initialize vocabulary
cat("Step 1: Loading Marine Environmental Vocabulary\n")
cat("-------------------------------------------------\n")
vocabulary <- init_vocabulary()

cat("\n")
cat("Step 2: Available Central Problems\n")
cat("-------------------------------------------------\n")
central_problems <- get_all_central_problems(vocabulary)
cat("Total central problems available:", length(central_problems), "\n\n")

# Display central problems
for (i in 1:min(5, length(central_problems))) {
  cat(sprintf("  %d. %s (ID: %s)\n", i, names(central_problems)[i], central_problems[i]))
}
cat("  ... and", length(central_problems) - 5, "more\n")

# Test Case 1: Overfishing scenario
cat("\n")
cat("=================================================================\n")
cat("TEST CASE 1: Overfishing and Stock Depletion (CP003)\n")
cat("=================================================================\n\n")

suggestions_overfishing <- get_suggestions_for_problem("CP003", vocabulary)

cat("Pathway Strength:", suggestions_overfishing$pathway_strength, "\n\n")

cat("Suggested Activities (", nrow(suggestions_overfishing$activities), "):\n")
if (nrow(suggestions_overfishing$activities) > 0) {
  for (i in 1:min(3, nrow(suggestions_overfishing$activities))) {
    act <- suggestions_overfishing$activities[i, ]
    cat(sprintf("  • %s\n    Category: %s | Intensity: %s\n",
                act$name, act$category, act$intensity))
  }
}

cat("\nSuggested Pressures (", nrow(suggestions_overfishing$pressures), "):\n")
if (nrow(suggestions_overfishing$pressures) > 0) {
  for (i in 1:min(3, nrow(suggestions_overfishing$pressures))) {
    press <- suggestions_overfishing$pressures[i, ]
    cat(sprintf("  • %s\n    Reversibility: %s | Lag time: %s\n",
                press$name, press$reversibility, press$lag_time))
  }
}

cat("\nLikely Consequences (", nrow(suggestions_overfishing$consequences), "):\n")
if (nrow(suggestions_overfishing$consequences) > 0) {
  for (i in 1:min(3, nrow(suggestions_overfishing$consequences))) {
    cons <- suggestions_overfishing$consequences[i, ]
    cat(sprintf("  • %s\n    Severity: %s | Recovery: %s\n",
                cons$name, cons$severity, cons$recovery_time))
  }
}

cat("\nRecommended Preventive Controls (", nrow(suggestions_overfishing$preventive_controls), "):\n")
if (nrow(suggestions_overfishing$preventive_controls) > 0) {
  for (i in 1:min(3, nrow(suggestions_overfishing$preventive_controls))) {
    ctrl <- suggestions_overfishing$preventive_controls[i, ]
    cat(sprintf("  • %s\n    Effectiveness: %s | Cost: %s\n",
                ctrl$name, ctrl$effectiveness, ctrl$implementation_cost))
  }
}

cat("\nRecommended Mitigation Controls (", nrow(suggestions_overfishing$mitigation_controls), "):\n")
if (nrow(suggestions_overfishing$mitigation_controls) > 0) {
  for (i in 1:min(3, nrow(suggestions_overfishing$mitigation_controls))) {
    ctrl <- suggestions_overfishing$mitigation_controls[i, ]
    cat(sprintf("  • %s\n    Effectiveness: %s | Cost: %s\n",
                ctrl$name, ctrl$effectiveness, ctrl$implementation_cost))
  }
}

cat("\nEscalation Factors (", nrow(suggestions_overfishing$escalation_factors), "):\n")
if (nrow(suggestions_overfishing$escalation_factors) > 0) {
  for (i in 1:min(3, nrow(suggestions_overfishing$escalation_factors))) {
    esc <- suggestions_overfishing$escalation_factors[i, ]
    cat(sprintf("  • %s\n    Trend: %s | Frequency: %s\n",
                esc$name, esc$trend, esc$frequency))
  }
}

# Test Case 2: Ocean Pollution scenario
cat("\n")
cat("=================================================================\n")
cat("TEST CASE 2: Ocean Pollution (CP002)\n")
cat("=================================================================\n\n")

suggestions_pollution <- get_suggestions_for_problem("CP002", vocabulary)

cat("Pathway Strength:", suggestions_pollution$pathway_strength, "\n\n")

cat("Suggested Activities:", nrow(suggestions_pollution$activities), "\n")
cat("Suggested Pressures:", nrow(suggestions_pollution$pressures), "\n")
cat("Likely Consequences:", nrow(suggestions_pollution$consequences), "\n")
cat("Preventive Controls:", nrow(suggestions_pollution$preventive_controls), "\n")
cat("Mitigation Controls:", nrow(suggestions_pollution$mitigation_controls), "\n")
cat("Escalation Factors:", nrow(suggestions_pollution$escalation_factors), "\n")

# Test Case 3: Coral Reef Degradation
cat("\n")
cat("=================================================================\n")
cat("TEST CASE 3: Coral Reef Degradation (CP010)\n")
cat("=================================================================\n\n")

suggestions_coral <- get_suggestions_for_problem("CP010", vocabulary)

cat("Pathway Strength:", suggestions_coral$pathway_strength, "\n\n")

cat("Top 3 Preventive Controls:\n")
if (nrow(suggestions_coral$preventive_controls) > 0) {
  top_controls <- head(suggestions_coral$preventive_controls, 3)
  for (i in 1:nrow(top_controls)) {
    ctrl <- top_controls[i, ]
    cat(sprintf("  %d. %s\n     %s\n     Effectiveness: %s | Implementation time: %s\n\n",
                i, ctrl$name, ctrl$description, ctrl$effectiveness, ctrl$implementation_time))
  }
}

# Test Case 4: Format for Shiny selectize
cat("\n")
cat("=================================================================\n")
cat("TEST CASE 4: Formatting for Shiny SelectizeInput\n")
cat("=================================================================\n\n")

# Format activities for selectize
activity_choices <- format_for_selectize(suggestions_overfishing$activities)
cat("Activity choices for selectizeInput:\n")
cat("  Length:", length(activity_choices), "\n")
if (length(activity_choices) > 0) {
  cat("  Example:", names(activity_choices)[1], "=", activity_choices[1], "\n")
}

# Format preventive controls
control_choices <- format_for_selectize(suggestions_overfishing$preventive_controls)
cat("\nPreventive control choices for selectizeInput:\n")
cat("  Length:", length(control_choices), "\n")
if (length(control_choices) > 0) {
  cat("  Example:", names(control_choices)[1], "=", control_choices[1], "\n")
}

# Test Case 5: Keyword search
cat("\n")
cat("=================================================================\n")
cat("TEST CASE 5: Keyword Search Functionality\n")
cat("=================================================================\n\n")

cat("Searching for 'plastic'...\n")
search_results <- search_vocabulary("plastic", vocabulary)

cat("Activities mentioning 'plastic':", nrow(search_results$activities), "\n")
if (nrow(search_results$activities) > 0) {
  cat("  •", paste(search_results$activities$name[1:min(2, nrow(search_results$activities))], collapse = "\n  • "), "\n")
}

cat("\nPressures mentioning 'plastic':", nrow(search_results$pressures), "\n")
if (nrow(search_results$pressures) > 0) {
  cat("  •", paste(search_results$pressures$name[1:min(2, nrow(search_results$pressures))], collapse = "\n  • "), "\n")
}

# Summary Statistics
cat("\n")
cat("=================================================================\n")
cat("SUMMARY STATISTICS\n")
cat("=================================================================\n\n")

cat("Vocabulary Size:\n")
cat(sprintf("  • Central Problems: %d\n", nrow(vocabulary$central_problems$central_problems)))
cat(sprintf("  • Activities: %d\n", nrow(vocabulary$causes$activities)))
cat(sprintf("  • Pressures: %d\n", nrow(vocabulary$causes$pressures)))
cat(sprintf("  • Consequences: %d\n", nrow(vocabulary$consequences$consequences)))
cat(sprintf("  • Preventive Controls: %d\n", nrow(vocabulary$controls$preventive_controls)))
cat(sprintf("  • Mitigation Controls: %d\n", nrow(vocabulary$controls$mitigation_controls)))
cat(sprintf("  • Escalation Factors: %d\n", nrow(vocabulary$escalation_factors$escalation_factors)))
cat(sprintf("  • Defined Relationships: %d\n", nrow(vocabulary$relationships$bowtie_relationships)))

cat("\n✅ All tests completed successfully!\n")
cat("\n=================================================================\n")
cat("INTEGRATION READY - See documentation for Shiny integration\n")
cat("=================================================================\n")
