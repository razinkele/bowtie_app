#' UI Translation Helper Functions
#'
#' Helper functions to create translatable UI elements
#'
#' @author Environmental Risk Assessment Team
#' @version 1.0.0

#' Create Translatable Card Header
#'
#' @param icon_name Character string. Font Awesome icon name
#' @param title_key Character string. Translation key for title
#' @param lang Character string. Language code
#' @param bg_class Character string. Background class (e.g., "bg-primary text-white")
#' @return Card header element
#' @export
tr_card_header <- function(icon_name, title_key, lang = "en", bg_class = "bg-primary text-white") {
  card_header(
    tagList(icon(icon_name), t(title_key, lang)),
    class = bg_class
  )
}

#' Create Translatable Action Button
#'
#' @param inputId Character string. Input ID
#' @param label_key Character string. Translation key for label
#' @param lang Character string. Language code
#' @param icon_name Character string. Icon name (optional)
#' @param btn_class Character string. Button class
#' @return Action button element
#' @export
tr_action_button <- function(inputId, label_key, lang = "en", icon_name = NULL, btn_class = "btn-primary") {
  label <- t(label_key, lang)
  if (!is.null(icon_name)) {
    label <- tagList(icon(icon_name), label)
  }
  actionButton(inputId, label, class = btn_class)
}

#' Create Translatable Select Input
#'
#' @param inputId Character string. Input ID
#' @param label_key Character string. Translation key for label
#' @param lang Character string. Language code
#' @param choices Named vector of choices
#' @param ... Additional parameters for selectInput
#' @return Select input element
#' @export
tr_select_input <- function(inputId, label_key, lang = "en", choices, ...) {
  selectInput(inputId, t(label_key, lang), choices = choices, ...)
}

#' Update Tab Titles Based on Language
#'
#' @param session Shiny session object
#' @param lang Character string. Language code
#' @export
updateTabTitles <- function(session, lang) {
  # This function would be called when language changes
  # Since Shiny doesn't easily support dynamic tab titles,
  # we use JavaScript to update them

  tab_translations <- list(
    upload = t("tab_data_upload", lang),
    diagram = t("tab_bowtie_diagram", lang),
    bayesian = t("tab_bayesian_network", lang),
    risk = t("tab_risk_matrix", lang),
    workflow = t("tab_guided_workflow", lang),
    about = t("tab_about", lang)
  )

  # Send translations to JavaScript for updating
  session$sendCustomMessage("updateTabTitles", tab_translations)
}
