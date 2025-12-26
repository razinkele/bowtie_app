# Test helper: create minimal Excel fixtures in repo root for tests
# This helper runs before tests and ensures CAUSES.xlsx, CONSEQUENCES.xlsx, CONTROLS.xlsx exist

activities <- data.frame(Hierarchy = c("1", "1.1"), `ID#` = c("1", "1.1"), name = c("Activity 1", "Activity 1.1"))
pressures <- data.frame(Hierarchy = c("1", "1.1"), `ID#` = c("1", "1.1"), name = c("Pressure 1", "Pressure 1.1"))
consequences <- data.frame(Hierarchy = c("1", "1.1"), `ID#` = c("1", "1.1"), name = c("Consequence 1", "Consequence 1.1"))
controls <- data.frame(Hierarchy = c("1", "1.1"), `ID#` = c("1", "1.1"), name = c("Control 1", "Control 1.1"))

write_xlsx_if_missing <- function(path, sheets) {
  fullpath <- file.path("..", path)
  if (file.exists(fullpath)) return(invisible(NULL))
  if (!requireNamespace("writexl", quietly = TRUE)) {
    try(
      install.packages("writexl", repos = "https://cloud.r-project.org", quiet = TRUE),
      silent = TRUE
    )
  }
  if (requireNamespace("writexl", quietly = TRUE)) {
    writexl::write_xlsx(sheets, path = fullpath)
    message("Created test fixture:", fullpath)
  } else {
    # Fall back to CSV files (some tests may accept CSV if xlsx not available)
    for (name in names(sheets)) {
      write.csv(sheets[[name]], file = file.path("..", paste0(tools::file_path_sans_ext(path), "_", name, ".csv")), row.names = FALSE)
    }
    message("writexl not available; created CSV fallbacks for:", path)
  }
}

# Create CAUSES.xlsx with two sheets: Activities and Pressures
write_xlsx_if_missing("CAUSES.xlsx", list(Activities = activities, Pressures = pressures))
# Create CONSEQUENCES.xlsx
write_xlsx_if_missing("CONSEQUENCES.xlsx", list(Consequences = consequences))
# Create CONTROLS.xlsx
write_xlsx_if_missing("CONTROLS.xlsx", list(Controls = controls))
