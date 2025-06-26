# example_bayesian_analysis.R
# Example of using Bayesian network analysis with environmental bowtie data

# Load required files
source("utils.r")
source("bowtie_bayesian_network.R")

# Create sample environmental bowtie data
sample_data <- data.frame(
  Activity = c(
    "Industrial manufacturing",
    "Agricultural operations",
    "Urban development",
    "Shipping operations"
  ),
  Pressure = c(
    "Chemical discharge",
    "Nutrient runoff",
    "Habitat fragmentation",
    "Marine pollution"
  ),
  Preventive_Control = c(
    "Wastewater treatment",
    "Buffer strips",
    "Green corridors",
    "Waste management"
  ),
  Escalation_Factor = c(
    "Treatment failure",
    "Heavy rainfall",
    "Urban sprawl",
    "Accidents"
  ),
  Central_Problem = c(
    "Water contamination",
    "Water contamination",
    "Biodiversity loss",
    "Marine ecosystem degradation"
  ),
  Protective_Mitigation = c(
    "Emergency response",
    "Nutrient management",
    "Habitat restoration",
    "Spill containment"
  ),
  Consequence = c(
    "Drinking water unsafe",
    "Eutrophication",
    "Species extinction",
    "Fish mortality"
  ),
  Likelihood = c(3, 4, 3, 2),
  Severity = c(5, 4, 5, 4),
  Risk_Level = c("High", "High", "High", "Medium"),
  stringsAsFactors = FALSE
)

# Example 1: Basic Bayesian Network Creation
cat("=== EXAMPLE 1: Creating Bayesian Network ===\n")

# Convert to Bayesian network
bn_result <- bowtie_to_bayesian(
  sample_data,
  central_problem = "Water contamination",
  learn_from_data = FALSE,
  visualize = TRUE
)

cat("\nNetwork created with", 
    nrow(bn_result$structure$nodes), "nodes and",
    nrow(bn_result$structure$edges), "edges\n")

# Example 2: Inference without Evidence
cat("\n=== EXAMPLE 2: Baseline Probabilities ===\n")

baseline <- bn_result$inference_function(
  evidence = list(),
  query = c("Consequence_Level", "Problem_Severity")
)

cat("\nBaseline risk levels:\n")
print(baseline)

# Example 3: Inference with Evidence
cat("\n=== EXAMPLE 3: What if we observe high industrial activity? ===\n")

evidence_scenario1 <- list(
  Activity = "Present",
  Pressure_Level = "High"
)

scenario1_results <- bn_result$inference_function(
  evidence = evidence_scenario1,
  query = c("Consequence_Level", "Problem_Severity")
)

cat("\nUpdated probabilities with high industrial pressure:\n")
print(scenario1_results)

# Example 4: Control Intervention Analysis
cat("\n=== EXAMPLE 4: Effect of Effective Controls ===\n")

evidence_scenario2 <- list(
  Activity = "Present",
  Pressure_Level = "High",
  Control_Effect = "Effective"
)

scenario2_results <- bn_result$inference_function(
  evidence = evidence_scenario2,
  query = c("Consequence_Level", "Escalation_Level")
)

cat("\nProbabilities with effective controls:\n")
print(scenario2_results)

# Example 5: Risk Propagation Analysis
cat("\n=== EXAMPLE 5: Risk Propagation Analysis ===\n")

if (exists("calculate_risk_propagation")) {
  # Worst case scenario
  worst_case <- list(
    Activity = "Present",
    Control_Effect = "Failed"
  )
  
  # Note: This requires a fitted network, which needs proper CPT formatting
  cat("\nRisk propagation analysis requires fitted network with proper CPTs.\n")
  cat("In the Shiny app, this is handled automatically.\n")
}

# Example 6: Network Statistics
cat("\n=== EXAMPLE 6: Network Structure Analysis ===\n")

# Node type distribution
node_types <- table(bn_result$structure$nodes$node_type)
cat("\nNode type distribution:\n")
print(node_types)

# Edge analysis
edge_types <- table(bn_result$structure$edges$type)
cat("\nEdge type distribution:\n")
print(edge_types)

# Example 7: Critical Path Analysis (Conceptual)
cat("\n=== EXAMPLE 7: Critical Path Identification ===\n")

# Identify paths from activities to consequences
activities <- bn_result$structure$nodes$node_id[
  bn_result$structure$nodes$node_type == "Activity"
]
consequences <- bn_result$structure$nodes$node_id[
  bn_result$structure$nodes$node_type == "Consequence"
]

cat("\nPotential critical paths:\n")
cat("From", length(activities), "activities to", 
    length(consequences), "consequences\n")

# Example path
cat("\nExample path:\n")
cat("Industrial manufacturing → Chemical discharge → Treatment failure →\n")
cat("Water contamination → Emergency response → Drinking water unsafe\n")

# Visualization
cat("\n=== VISUALIZATION ===\n")
cat("The Bayesian network visualization shows:\n")
cat("- Purple boxes: Activities (root causes)\n")
cat("- Red triangles: Pressures\n")
cat("- Green squares: Controls\n")
cat("- Orange triangles: Escalation factors\n")
cat("- Red diamonds: Central problems\n")
cat("- Blue squares: Mitigations\n")
cat("- Orange hexagons: Consequences\n")

# Return the visualization
bn_result$visualization