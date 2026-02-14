# =============================================================================
# Language and Translation Module
# =============================================================================
# Purpose: Handles language switching and UI translation updates
# Dependencies: translations_data.R (for t() function)
# =============================================================================

#' Initialize language module server logic
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @return List containing reactive language value and helper functions
#' @export
language_module_server <- function(input, output, session) {

  # Translation reactive value (triggered by button click)
  currentLanguage <- reactiveVal("en")

  # Language change observer
  observeEvent(input$applyLanguage, {
    new_lang <- input$app_language
    currentLanguage(new_lang)

    # Update button labels
    tryCatch({
      updateActionButton(session, "loadData",
                        label = t("upload_button", new_lang), icon = icon("upload"))
      updateActionButton(session, "generateMultipleControls",
                        label = t("generate_data_button", new_lang), icon = icon("seedling"))
      updateActionButton(session, "applyLanguage",
                        label = t("apply_language", new_lang), icon = icon("check"))
    }, error = function(e) {
      log_debug("Note: Some UI elements may not update until page refresh")
    })

    # Update main navigation tab titles using JavaScript
    translations <- list(
      upload = t("tab_data_input", new_lang),
      guided_workflow = paste0("🧙 ", t("tab_guided_creation", new_lang)),
      bowtie = t("tab_bowtie_diagram", new_lang),
      bayesian = t("tab_bayesian", new_lang),
      table = t("tab_data_table", new_lang),
      matrix = t("tab_risk_matrix", new_lang),
      vocabulary = t("tab_vocabulary_management", new_lang),
      help = t("tab_help", new_lang)
    )

    # Target the nav-link elements by their data-value attribute
    # Multiple selectors to handle different bslib structures
    tab_updates <- list(
      list(value = "upload", icon = "upload", text = translations$upload),
      list(value = "guided_workflow", icon = "magic", text = translations$guided_workflow),
      list(value = "bowtie", icon = "project-diagram", text = translations$bowtie),
      list(value = "bayesian", icon = "brain", text = translations$bayesian),
      list(value = "table", icon = "table", text = translations$table),
      list(value = "matrix", icon = "chart-line", text = translations$matrix),
      list(value = "vocabulary", icon = "book", text = translations$vocabulary),
      list(value = "help", icon = "question-circle", text = translations$help)
    )

    # Generate JavaScript to update each tab - use data-value attribute
    js_code <- paste(
      sapply(tab_updates, function(tab) {
        sprintf(
          "setTimeout(function() {
             var $tab = $('#main_tabs a.nav-link[data-value=\"%s\"]');
             if ($tab.length > 0) {
               $tab.html('<i class=\"fa fa-%s\"></i> %s');
             }
           }, 100);",
          tab$value, tab$icon, tab$text
        )
      }),
      collapse = "\n"
    )

    runjs(js_code)

    notify_info(paste(t("language_label", new_lang), ":", ifelse(new_lang == "en", "English", "Français")), duration = 3)
  })

  # Reactive language getter
  lang <- reactive({
    currentLanguage()
  })

  # Return module API
  list(
    lang = lang,
    currentLanguage = currentLanguage
  )
}
