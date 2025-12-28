# PowerShell script to modify ui.R - Remove Option 2

$uiFile = "C:\Users\DELL\OneDrive - ku.lt\HORIZON_EUROPE\bowtie_app\ui.R"

# Read the file
$content = Get-Content $uiFile -Raw

# Replace the three-column layout with two-column layout
# This removes Option 2 (middle column) and updates Option 2b to Option 2

$oldPattern = @"

                    # Middle column - Generate from vocabulary
                    column\(4,
                      div\(style = "min-height: 150px;",
                        uiOutput\("data_upload_option2_title"\),
                        uiOutput\("data_option2_desc"\)
                      \),
                      div\(class = "mb-3",
                        selectInput\("data_scenario_template", "Select environmental scenario:",
                                    choices = getEnvironmentalScenarioChoices\(include_blank = TRUE\),
                                    selected = ""\)
                      \),
                      div\(class = "d-grid", actionButton\("generateSample",
                                                        tagList\(icon\("seedling"\), "Generate Data"\),
                                                        class = "btn-success"\)\)
                    \),

                    # Right column - Multiple controls
                    column\(4,
                      div\(style = "min-height: 150px;",
                        uiOutput\("data_upload_option2b_title"\),
                        uiOutput\("data_option2b_desc"\)
                      \),
                      div\(class = "mb-3",
                        selectInput\("data_scenario_template_2b", "Select environmental scenario:",
"@

$newPattern = @"

                    # Right column - Generate from environmental scenarios
                    column(6,
                      div(style = "min-height: 150px;",
                        uiOutput("data_upload_option2_title"),
                        uiOutput("data_option2_desc")
                      ),
                      div(class = "mb-3",
                        selectInput("data_scenario_template", "Select environmental scenario:",
"@

# Apply replacement using regex
$content = $content -replace [regex]::Escape($oldPattern), $newPattern

# Also need to update the remaining parts
$content = $content -replace 'selectInput\("data_scenario_template_2b"', 'selectInput("data_scenario_template"'
$content = $content -replace 'actionButton\("generateMultipleControls",\s+tagList\(icon\("shield-alt"\), "Multiple Controls"\),\s+class = "btn-info"\)', 'actionButton("generateMultipleControls",
                                                        tagList(icon("seedling"), "Generate Sample Data"),
                                                        class = "btn-success")'
$content = $content -replace 'class = "btn-info"\)\)', 'class = "btn-success"))'

# Update left column to column(6)
$content = $content -replace '# Left column - File upload\s+column\(4,', '# Left column - File upload
                    column(6,'

# Write back
Set-Content $uiFile -Value $content

Write-Host "✅ Successfully modified ui.R"
