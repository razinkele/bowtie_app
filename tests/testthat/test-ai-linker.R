test_that("validate_bowtie_structure accepts valid links and rejects invalid ones", {
  # Source the AI linker to ensure functions are available in test environment
  source(file.path("..", "..", "vocabulary_ai_linker.R"), local = TRUE)

  valid_links <- data.frame(
    from_type = c("Activity","Pressure","Control"),
    to_type = c("Pressure","Consequence","Consequence"),
    relationship = c("causes","leads_to","mitigates"),
    stringsAsFactors = FALSE
  )

  expect_true(validate_bowtie_structure(valid_links))

  invalid_links <- rbind(valid_links, data.frame(from_type = "Activity", to_type = "Consequence", relationship = "causes", stringsAsFactors = FALSE))
  expect_false(validate_bowtie_structure(invalid_links))
})


test_that("find_control_links sets singular to_type correctly", {
  source(file.path("..", "..", "vocabulary_ai_linker.R"), local = TRUE)

  controls <- data.frame(id = c('C1'), name = c('Emergency response team'), stringsAsFactors = FALSE)
  activities <- data.frame(id = c('A1'), name = c('Fishing activity'), stringsAsFactors = FALSE)
  pressures <- data.frame(id = c('P1'), name = c('Overfishing'), stringsAsFactors = FALSE)
  consequences <- data.frame(id = c('CO1'), name = c('Species decline'), stringsAsFactors = FALSE)

  targets <- list(activities = activities, pressures = pressures, consequences = consequences)

  links <- find_control_links(controls, targets, control_type = 'protective', methods = c('keyword'), threshold = 0, max_links = 1)

  # Ensure produced to_type values are singular and expected
  expect_true(all(links$to_type %in% c('Activity', 'Pressure', 'Consequence')))
})