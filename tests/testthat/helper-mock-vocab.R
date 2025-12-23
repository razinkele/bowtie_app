# Helper: Mock vocabulary and workflow state for UI tests

create_mock_vocabulary <- function() {
  list(
    activities = data.frame(
      id = 1:3,
      name = c("Activity A", "Activity B", "Activity C"),
      category = c("Primary", "Secondary", "Primary"),
      stringsAsFactors = FALSE
    ),
    pressures = data.frame(
      id = 1:3,
      name = c("Pressure 1", "Pressure 2", "Pressure 3"),
      category = c("Chemical", "Physical", "Biological"),
      stringsAsFactors = FALSE
    ),
    controls = data.frame(
      id = 1:2,
      name = c("Control X", "Control Y"),
      type = c("Regulatory", "Technical"),
      stringsAsFactors = FALSE
    ),
    consequences = data.frame(
      id = 1:2,
      name = c("Consequence 1", "Consequence 2"),
      severity = c("High", "Medium"),
      stringsAsFactors = FALSE
    )
  )
}

create_test_workflow_state <- function() {
  list(
    current_step = 1,
    total_steps = 8,
    completed_steps = integer(0),
    progress_percentage = 0,
    project_name = "",
    central_problem = "",
    project_data = list(
      project_name = "",
      project_location = "",
      project_type = "",
      project_description = "",
      problem_statement = "",
      problem_category = "",
      problem_details = "",
      activities = list(),
      pressures = list(),
      preventive_controls = list(),
      consequences = list(),
      protective_controls = list(),
      escalation_factors = list()
    ),
    step_times = list()
  )
}