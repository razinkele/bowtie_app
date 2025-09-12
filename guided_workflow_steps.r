# =============================================================================
# Guided Workflow Steps - Complete Step Implementations
# Version: 1.0.0
# Date: September 2025
# Description: Complete implementations of all 8 workflow steps
# =============================================================================

# Load required for step definitions
if (!exists("WORKFLOW_CONFIG")) {
  source("guided_workflow.r")
}

cat("📋 GUIDED WORKFLOW STEPS v1.0.0\n")
cat("===============================\n")
cat("Complete step implementations for bowtie creation wizard\n\n")

# =============================================================================
# STEP 4: PREVENTIVE CONTROLS
# =============================================================================

generate_step4_ui <- function() {
  tagList(
    div(class = "alert alert-success",
        h5("🛡️ Define Preventive Controls"),
        p("Preventive controls are measures that prevent or reduce the likelihood of threats reaching your central problem. These are proactive interventions.")
    ),
    
    fluidRow(
      column(8,
             h4("🔧 Preventive Measures"),
             
             fluidRow(
               column(6,
                      selectInput("control_type", "Control Type:",
                                choices = c(
                                  "Regulatory/Legal" = "regulatory",
                                  "Technical/Engineering" = "technical",
                                  "Management/Administrative" = "management",
                                  "Monitoring/Surveillance" = "monitoring",
                                  "Education/Training" = "education",
                                  "Economic/Financial" = "economic"
                                ))
               ),
               column(6,
                      selectInput("control_effectiveness", "Expected Effectiveness:",
                                choices = c(
                                  "High (>80% reduction)" = "high",
                                  "Medium (50-80% reduction)" = "medium",
                                  "Low (20-50% reduction)" = "low",
                                  "Very Low (<20% reduction)" = "very_low"
                                ))
               )
             ),
             
             textInput("control_name", "Control Measure Name:",
                      placeholder = "e.g., Wastewater Treatment Standards"),
             
             textAreaInput("control_description", "Detailed Description:",
                          placeholder = "Describe how this control works and what it prevents...",
                          rows = 3),
             
             fluidRow(
               column(6,
                      selectInput("control_stage", "Implementation Stage:",
                                choices = c(
                                  "Planning/Design" = "planning",
                                  "Construction/Setup" = "construction", 
                                  "Operation/Maintenance" = "operation",
                                  "Monitoring/Review" = "monitoring",
                                  "Emergency Response" = "emergency"
                                ))
               ),
               column(6,
                      numericInput("control_cost", "Implementation Cost (scale 1-5):",
                                 value = 3, min = 1, max = 5,
                                 help = "1 = Very Low, 5 = Very High")
               )
             ),
             
             actionButton("add_preventive_control", "➕ Add Preventive Control",
                        class = "btn-success")
      ),
      
      column(4,
             h4("📊 Control Categories"),
             div(class = "card",
                 div(class = "card-body",
                     h6("🏛️ Regulatory:"),
                     p("Laws, permits, standards, compliance requirements"),
                     
                     h6("⚙️ Technical:"),
                     p("Engineering solutions, equipment, infrastructure"),
                     
                     h6("📋 Management:"),
                     p("Policies, procedures, protocols, training"),
                     
                     h6("👁️ Monitoring:"),
                     p("Surveillance, inspection, early warning systems"),
                     
                     h6("💰 Economic:"),
                     p("Taxes, subsidies, market-based instruments")
                 )
             )
      )
    ),
    
    br(),
    h4("🛡️ Your Preventive Controls"),
    DTOutput("preventive_controls_table"),
    
    br(),
    div(class = "alert alert-info",
        h6("💡 Expert Guidance:"),
        p("Effective prevention requires multiple layers of controls. Consider controls at different stages: planning, implementation, operation, and monitoring.")
    )
  )
}

# =============================================================================
# STEP 5: CONSEQUENCES  
# =============================================================================

generate_step5_ui <- function() {
  tagList(
    div(class = "alert alert-warning",
        h5("💥 Identify Potential Consequences"),
        p("What environmental impacts could result if your central problem occurs? Think about direct and indirect effects across different scales and timeframes.")
    ),
    
    fluidRow(
      column(6,
             h4("🌍 Environmental Impacts"),
             
             selectInput("consequence_category", "Impact Category:",
                        choices = c(
                          "Ecosystem Degradation" = "ecosystem",
                          "Species/Biodiversity Impact" = "biodiversity",
                          "Water Quality Impact" = "water_quality", 
                          "Air Quality Impact" = "air_quality",
                          "Soil/Land Impact" = "soil_land",
                          "Human Health Impact" = "human_health",
                          "Economic Impact" = "economic",
                          "Social/Cultural Impact" = "social"
                        )),
             
             textInput("consequence_name", "Consequence Description:",
                      placeholder = "e.g., Marine species population decline"),
             
             fluidRow(
               column(6,
                      selectInput("consequence_severity", "Severity Level:",
                                choices = c(
                                  "Catastrophic" = "catastrophic",
                                  "Major" = "major",
                                  "Moderate" = "moderate",
                                  "Minor" = "minor",
                                  "Negligible" = "negligible"
                                ))
               ),
               column(6,
                      selectInput("consequence_timeframe", "Timeframe:",
                                choices = c(
                                  "Immediate (hours-days)" = "immediate",
                                  "Short-term (weeks-months)" = "short_term",
                                  "Medium-term (1-5 years)" = "medium_term",
                                  "Long-term (5+ years)" = "long_term",
                                  "Permanent" = "permanent"
                                ))
               )
             ),
             
             selectInput("consequence_scale", "Spatial Scale:",
                        choices = c(
                          "Site-specific" = "site",
                          "Local community" = "local",
                          "Regional" = "regional",
                          "National" = "national", 
                          "International" = "international",
                          "Global" = "global"
                        )),
             
             textAreaInput("consequence_details", "Detailed Impact Description:",
                          placeholder = "Describe the specific environmental impact...",
                          rows = 3),
             
             actionButton("add_consequence", "➕ Add Consequence",
                        class = "btn-warning")
      ),
      
      column(6,
             h4("📈 Impact Assessment"),
             
             div(class = "card",
                 div(class = "card-header", h6("Severity Levels")),
                 div(class = "card-body",
                     tags$ul(
                       tags$li(strong("Catastrophic:"), "Irreversible ecosystem collapse"),
                       tags$li(strong("Major:"), "Significant long-term damage"),
                       tags$li(strong("Moderate:"), "Noticeable impacts, recovery possible"),
                       tags$li(strong("Minor:"), "Limited, temporary impacts"),
                       tags$li(strong("Negligible:"), "Minimal detectable effects")
                     )
                 )
             ),
             
             br(),
             div(class = "card",
                 div(class = "card-header", h6("Consider These Impact Types")),
                 div(class = "card-body",
                     h6("🌊 Direct Impacts:"),
                     p("Immediate effects on the environment"),
                     
                     h6("🔄 Indirect Impacts:"),
                     p("Secondary effects through ecosystem connections"),
                     
                     h6("📈 Cumulative Impacts:"),
                     p("Combined effects with other stressors"),
                     
                     h6("⏰ Temporal Aspects:"),
                     p("Short-term vs. long-term consequences")
                 )
             )
      )
    ),
    
    br(),
    h4("💥 Identified Consequences"),
    DTOutput("consequences_table")
  )
}

# =============================================================================
# STEP 6: PROTECTIVE CONTROLS
# =============================================================================

generate_step6_ui <- function() {
  tagList(
    div(class = "alert alert-info",
        h5("🚨 Define Protective Controls"),
        p("Protective controls are reactive measures that reduce the impact or severity of consequences once they begin to occur. These are mitigation and response measures.")
    ),
    
    fluidRow(
      column(8,
             h4("🛟 Protective Measures"),
             
             fluidRow(
               column(6,
                      selectInput("protective_type", "Protection Type:",
                                choices = c(
                                  "Emergency Response" = "emergency",
                                  "Damage Mitigation" = "mitigation",
                                  "Recovery/Restoration" = "recovery",
                                  "Containment/Isolation" = "containment",
                                  "Alternative Provision" = "alternative",
                                  "Compensation" = "compensation"
                                ))
               ),
               column(6,
                      selectInput("response_speed", "Response Speed:",
                                choices = c(
                                  "Immediate (< 1 hour)" = "immediate",
                                  "Rapid (< 24 hours)" = "rapid", 
                                  "Fast (< 1 week)" = "fast",
                                  "Moderate (< 1 month)" = "moderate",
                                  "Slow (> 1 month)" = "slow"
                                ))
               )
             ),
             
             textInput("protective_name", "Protective Measure Name:",
                      placeholder = "e.g., Emergency Marine Cleanup Response"),
             
             textAreaInput("protective_description", "Response Description:",
                          placeholder = "Describe how this protective measure works...",
                          rows = 3),
             
             fluidRow(
               column(4,
                      numericInput("mitigation_effectiveness", "Mitigation Effectiveness (%):",
                                 value = 70, min = 0, max = 100)
               ),
               column(4,
                      selectInput("resource_requirements", "Resource Needs:",
                                choices = c(
                                  "Low" = "low",
                                  "Medium" = "medium", 
                                  "High" = "high",
                                  "Very High" = "very_high"
                                ))
               ),
               column(4,
                      selectInput("stakeholders_involved", "Key Stakeholders:",
                                choices = c(
                                  "Government Agencies" = "government",
                                  "Emergency Services" = "emergency_services",
                                  "Environmental Organizations" = "environmental",
                                  "Local Communities" = "communities",
                                  "Private Companies" = "private",
                                  "International Bodies" = "international"
                                ))
               )
             ),
             
             actionButton("add_protective_control", "➕ Add Protective Control",
                        class = "btn-info")
      ),
      
      column(4,
             h4("🚨 Protection Strategies"),
             div(class = "card",
                 div(class = "card-body",
                     h6("⚡ Emergency Response:"),
                     p("Immediate actions to prevent escalation"),
                     
                     h6("🛡️ Damage Mitigation:"),
                     p("Measures to reduce impact severity"),
                     
                     h6("🔧 Recovery/Restoration:"),
                     p("Actions to restore environmental conditions"),
                     
                     h6("📦 Containment:"),
                     p("Prevent spread of environmental damage"),
                     
                     h6("🔄 Alternative Provision:"),
                     p("Backup systems or alternative resources")
                 )
             ),
             
             br(),
             div(class = "alert alert-warning",
                 h6("⚠️ Important:"),
                 p("Protective controls should be designed and prepared in advance, even though they activate after consequences begin.")
             )
      )
    ),
    
    br(),
    h4("🚨 Your Protective Controls"),
    DTOutput("protective_controls_table")
  )
}

# =============================================================================
# STEP 7: REVIEW & VALIDATE
# =============================================================================

generate_step7_ui <- function() {
  tagList(
    div(class = "alert alert-primary",
        h5("✅ Review & Validate Your Bowtie"),
        p("Review all components of your bowtie diagram and validate the logical connections between elements.")
    ),
    
    fluidRow(
      column(6,
             h4("📊 Bowtie Summary"),
             div(class = "card",
                 div(class = "card-body",
                     h6("🎯 Central Problem:"),
                     verbatimTextOutput("review_central_problem"),
                     
                     h6("👥 Activities (", textOutput("activity_count", inline = TRUE), "):"),
                     DTOutput("review_activities"),
                     
                     h6("🌊 Pressures (", textOutput("pressure_count", inline = TRUE), "):"),
                     DTOutput("review_pressures"),
                     
                     h6("🛡️ Preventive Controls (", textOutput("preventive_count", inline = TRUE), "):"),
                     DTOutput("review_preventive"),
                     
                     h6("💥 Consequences (", textOutput("consequence_count", inline = TRUE), "):"),
                     DTOutput("review_consequences"),
                     
                     h6("🚨 Protective Controls (", textOutput("protective_count", inline = TRUE), "):"),
                     DTOutput("review_protective")
                 )
             )
      ),
      
      column(6,
             h4("🔍 Validation Checks"),
             
             uiOutput("validation_results"),
             
             br(),
             h4("📈 Bowtie Statistics"),
             div(class = "card",
                 div(class = "card-body",
                     verbatimTextOutput("bowtie_statistics")
                 )
             ),
             
             br(),
             h4("🎯 Completeness Score"),
             uiOutput("completeness_score")
      )
    ),
    
    br(),
    fluidRow(
      column(6,
             h4("🔧 Final Adjustments"),
             p("Make any final modifications before completing your bowtie:"),
             actionButton("edit_central_problem", "✏️ Edit Problem", class = "btn-outline-primary btn-sm me-2"),
             actionButton("add_more_threats", "➕ Add Threats", class = "btn-outline-warning btn-sm me-2"),
             actionButton("add_more_consequences", "➕ Add Consequences", class = "btn-outline-danger btn-sm")
      ),
      column(6,
             h4("✅ Validation Actions"),
             checkboxInput("confirm_completeness", "I confirm the bowtie is complete", FALSE),
             checkboxInput("confirm_accuracy", "I confirm the information is accurate", FALSE),
             checkboxInput("confirm_stakeholder_review", "Stakeholders have reviewed this assessment", FALSE)
      )
    )
  )
}

# =============================================================================
# STEP 8: FINALIZE & EXPORT
# =============================================================================

generate_step8_ui <- function() {
  tagList(
    div(class = "workflow-header",
        h3("🎉 Congratulations! Your Bowtie is Complete"),
        p("Your environmental risk assessment bowtie diagram is ready. Choose how you'd like to save and share your work.")
    ),
    
    fluidRow(
      column(6,
             h4("💾 Save & Export Options"),
             
             div(class = "card mb-3",
                 div(class = "card-body",
                     h5("📊 Export Formats"),
                     checkboxGroupInput("export_formats", "",
                                      choices = c(
                                        "Excel Data File (.xlsx)" = "excel",
                                        "PDF Report (.pdf)" = "pdf",
                                        "PNG Diagram (.png)" = "png",
                                        "Interactive HTML (.html)" = "html",
                                        "CSV Data (.csv)" = "csv",
                                        "JSON Data (.json)" = "json"
                                      ),
                                      selected = c("excel", "pdf"))
                 )
             ),
             
             div(class = "card mb-3",
                 div(class = "card-body",
                     h5("📝 Report Options"),
                     checkboxGroupInput("report_sections", "",
                                      choices = c(
                                        "Executive Summary" = "executive",
                                        "Detailed Methodology" = "methodology",
                                        "Risk Assessment Tables" = "tables",
                                        "Bowtie Diagram" = "diagram",
                                        "Recommendations" = "recommendations",
                                        "Appendices" = "appendices"
                                      ),
                                      selected = c("executive", "diagram", "tables"))
                 )
             ),
             
             fluidRow(
               column(6,
                      downloadButton("download_bowtie", "📥 Download Files",
                                   class = "btn-success btn-lg")
               ),
               column(6,
                      actionButton("save_to_cloud", "☁️ Save to Cloud",
                                 class = "btn-primary btn-lg")
               )
             )
      ),
      
      column(6,
             h4("🚀 Next Steps"),
             
             div(class = "card mb-3",
                 div(class = "card-body",
                     h5("🔄 Ongoing Management"),
                     tags$ul(
                       tags$li("Schedule regular review updates"),
                       tags$li("Monitor control effectiveness"),
                       tags$li("Update risk assessments"),
                       tags$li("Share with stakeholders")
                     )
                 )
             ),
             
             div(class = "card mb-3",
                 div(class = "card-body",
                     h5("📈 Advanced Analysis"),
                     p("Consider these advanced features:"),
                     tags$ul(
                       tags$li("Bayesian network modeling"),
                       tags$li("Monte Carlo simulation"),
                       tags$li("Sensitivity analysis"),
                       tags$li("Multi-criteria decision analysis")
                     ),
                     actionButton("explore_advanced", "🧠 Explore Advanced Features",
                                class = "btn-outline-primary")
                 )
             ),
             
             h4("📊 Project Summary"),
             verbatimTextOutput("final_project_summary")
      )
    ),
    
    br(),
    div(class = "alert alert-success",
        h5("🎯 Workflow Complete!"),
        p("Your environmental bowtie risk assessment has been successfully created using the guided workflow. The systematic approach ensures comprehensive coverage of threats, controls, and consequences.")
    )
  )
}

# =============================================================================
# TEMPLATE SYSTEM
# =============================================================================

# Template selector UI
generate_template_selector_ui <- function() {
  templates <- WORKFLOW_CONFIG$templates
  
  template_cards <- lapply(names(templates), function(template_id) {
    template <- templates[[template_id]]
    div(class = "template-card", 
        onclick = paste0("Shiny.setInputValue('select_template', '", template_id, "')"),
        h6(template$name),
        p(class = "text-muted small", template$central_problem),
        span(class = "badge bg-secondary", template$category)
    )
  })
  
  tagList(
    div(class = "template-selector", template_cards),
    br(),
    actionButton("clear_template", "🗑️ Start from Scratch", class = "btn-outline-secondary btn-sm")
  )
}

# Apply template to workflow
apply_template <- function(template_id, workflow_state) {
  if (template_id %in% names(WORKFLOW_CONFIG$templates)) {
    template <- WORKFLOW_CONFIG$templates[[template_id]]
    
    # Pre-fill template data
    workflow_state$project_data$template_applied <- template_id
    workflow_state$project_data$central_problem <- template$central_problem
    workflow_state$project_data$example_activities <- template$example_activities
    workflow_state$project_data$example_pressures <- template$example_pressures
    workflow_state$project_data$project_type <- tolower(gsub(" ", "_", template$category))
  }
  
  return(workflow_state)
}

cat("✅ Guided Workflow Steps Complete!\n")
cat("📋 All 8 workflow steps implemented:\n")
cat("   Step 1: 📋 Project Setup\n")
cat("   Step 2: 🎯 Central Problem Definition\n")
cat("   Step 3: ⚠️ Threats & Causes\n")
cat("   Step 4: 🛡️ Preventive Controls\n")
cat("   Step 5: 💥 Consequences\n")
cat("   Step 6: 🚨 Protective Controls\n")
cat("   Step 7: ✅ Review & Validate\n")
cat("   Step 8: 🎉 Finalize & Export\n")
cat("\n🎯 Complete guided workflow system ready for integration!\n")