# realistic_test_data.R
# Realistic test data that matches actual Excel file structure
# Based on the actual vocabulary data loaded from Excel files

# Create test data that matches the real structure
create_realistic_test_vocabulary <- function() {
  # Activities test data (matches real structure)
  activities_data <- data.frame(
    hierarchy = c("Level 1", "Level 2", "Level 2", "Level 3", "Level 3"),
    id = c("A1", "A1.1", "A1.2", "A1.2.1", "A1.2.2"),
    name = c(
      "PHYSICAL RESTRUCTURING OF RIVERS, COASTLINE OR SEABED",
      "Land claim",
      "Canalisation and other watercourse modifications",
      "River channelization",
      "Dam construction"
    ),
    level = c(1, 2, 2, 3, 3),
    stringsAsFactors = FALSE
  )

  # Pressures test data
  pressures_data <- data.frame(
    hierarchy = c("Level 1", "Level 2", "Level 2", "Level 3"),
    id = c("P1", "P1.1", "P1.2", "P1.1.1"),
    name = c(
      "BIOLOGICAL PRESSURES",
      "Input or spread of non-indigenous species",
      "Input of microbial pathogens",
      "Ballast water discharge"
    ),
    level = c(1, 2, 2, 3),
    stringsAsFactors = FALSE
  )

  # Consequences test data
  consequences_data <- data.frame(
    hierarchy = c("Level 1", "Level 2", "Level 3", "Level 3"),
    id = c("C1", "C1.1", "C1.1.1", "C1.1.2"),
    name = c(
      "Impacts on NATURE",
      "Change in ecosystem/marine processes",
      "Decrease in provisioning ES",
      "Decrease in regulating ES"
    ),
    level = c(1, 2, 3, 3),
    stringsAsFactors = FALSE
  )

  # Controls test data (the main focus of our fix)
  controls_data <- data.frame(
    hierarchy = c("Level 1", "Level 2", "Level 2", "Level 3", "Level 3", "Level 3"),
    id = c("Ctrl1", "Ctrl1.1", "Ctrl1.2", "Ctrl1.2.1", "Ctrl1.2.2", "Ctrl1.2.3"),
    name = c(
      "NATURE PROTECTION",
      "Nature conservation/management",
      "Nature restoration/enhancement",
      "Habitat/Ecosystem restoration/remediation/enhancement",
      "Species populations restocking",
      "Habitat creation or offsetting"
    ),
    level = c(1, 2, 2, 3, 3, 3),
    stringsAsFactors = FALSE
  )

  # Create hierarchy lists (simplified for testing)
  activities_hierarchy <- list()
  for (i in 1:nrow(activities_data)) {
    item <- list(
      id = activities_data$id[i],
      name = activities_data$name[i],
      level = activities_data$level[i],
      children = list()
    )

    # Add parent_id for non-root items
    if (activities_data$level[i] > 1) {
      parts <- strsplit(activities_data$id[i], "\\.")[[1]]
      if (length(parts) > 1) {
        parent_parts <- parts[1:(length(parts) - 1)]
        item$parent_id <- paste(parent_parts, collapse = ".")
      }
    }

    activities_hierarchy[[activities_data$id[i]]] <- item
  }

  return(list(
    activities = activities_data,
    pressures = pressures_data,
    consequences = consequences_data,
    controls = controls_data,
    activities_hierarchy = activities_hierarchy,
    pressures_hierarchy = list(),
    consequences_hierarchy = list(),
    controls_hierarchy = list()
  ))
}

# Create minimal test data for quick tests
create_minimal_test_data <- function() {
  data.frame(
    hierarchy = c("Level 1", "Level 2", "Level 2"),
    id = c("T1", "T1.1", "T1.2"),
    name = c("Test Category", "Test Item 1", "Test Item 2"),
    level = c(1, 2, 2),
    stringsAsFactors = FALSE
  )
}

# Create test bowtie data for integration tests
create_test_bowtie_data <- function() {
  data.frame(
    activity = c("A1.1", "A1.2"),
    pressure = c("P1.1", "P1.2"),
    central_problem = c("Test Problem 1", "Test Problem 1"),
    consequence = c("C1.1", "C1.2"),
    preventive_control = c("Ctrl1.1", "Ctrl1.2"),
    protective_control = c("Ctrl2.1", "Ctrl2.2"),
    stringsAsFactors = FALSE
  )
}

# Test data for specific guided workflow functionality
create_guided_workflow_test_data <- function() {
  list(
    project_name = "Test Environmental Project",
    central_problem = "Marine plastic pollution",
    selected_activities = data.frame(
      name = c("Waste disposal", "Shipping activities"),
      stringsAsFactors = FALSE
    ),
    selected_pressures = data.frame(
      name = c("Input of litter", "Physical disturbance"),
      stringsAsFactors = FALSE
    ),
    selected_controls = data.frame(
      name = c("Waste management regulations", "Marine protected areas"),
      stringsAsFactors = FALSE
    )
  )
}

cat("✅ Realistic test data module loaded\n")