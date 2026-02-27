# =============================================================================
# Theme Management Module (Proper Shiny Module with Namespace Isolation)
# =============================================================================
# Purpose: Handles Bootstrap theme selection and dynamic theme switching
# Dependencies: bslib, shinyjs
# Pattern: moduleServer with NS() for full namespace isolation
# =============================================================================

# =============================================================================
# THEME MODULE UI
# =============================================================================

#' Theme module UI component
#'
#' Creates the theme selection card for the controlbar settings panel.
#' All input IDs are namespaced via NS(id) to avoid collisions.
#'
#' @param id Module namespace ID (e.g., "theme")
#' @return A tagList containing the theme selection UI
#' @export
theme_module_ui <- function(id) {
  ns <- NS(id)

  div(class = "card",
    div(class = "card-header bg-primary text-white py-2",
      icon("brush"), " Theme"
    ),
    div(class = "card-body",
      # Theme header (translated label) rendered server-side
      uiOutput(ns("settings_theme_header")),

      selectInput(ns("theme_preset"), NULL,
                  choices = c(
                    "Environmental (Default)" = "journal",
                    "Dark Mode" = "darkly",
                    "Light & Clean" = "flatly",
                    "Ocean Blue" = "cosmo",
                    "Forest Green" = "materia",
                    "Corporate Blue" = "cerulean",
                    "Minimal Clean" = "minty",
                    "Dashboard" = "lumen",
                    "Creative Purple" = "pulse",
                    "Science Lab" = "sandstone",
                    "Space Dark" = "slate",
                    "Professional" = "united",
                    "Modern Contrast" = "superhero",
                    "Sunset Orange" = "solar",
                    "Analytics" = "spacelab",
                    "Vibrant" = "sketchy",
                    "Nature Fresh" = "cyborg",
                    "Business" = "vapor",
                    "Research" = "zephyr",
                    "High Contrast" = "bootstrap"
                  ),
                  selected = "journal"),

      actionButton(ns("applyTheme"),
                   "Apply Theme",
                   icon = icon("check"),
                   class = "btn-primary btn-sm w-100 mt-2")
    )
  )
}

# =============================================================================
# THEME MODULE SERVER
# =============================================================================

#' Theme module server logic (proper moduleServer pattern)
#'
#' Handles theme selection, CSS injection, and dynamic theme switching.
#' Uses Shiny's moduleServer for namespace isolation -- all input/output IDs
#' inside this function are automatically namespaced.
#'
#' @param id Module namespace ID (must match the id used in theme_module_ui)
#' @param lang Reactive expression returning the current language code ("en"/"fr")
#' @return List containing theme reactive values for use by other modules
#' @export
theme_module_server <- function(id, lang = reactive("en")) {
  moduleServer(id, function(input, output, session) {

    # Theme management reactive values
    theme_update_trigger <- reactiveVal(0)
    applied_theme <- reactiveVal("zephyr")

    # -------------------------------------------------------------------------
    # Translated theme header
    # -------------------------------------------------------------------------
    output$settings_theme_header <- renderUI({
      current_lang <- lang()
      h6(tagList(icon("palette"), " ", t("theme_settings", current_lang)),
         class = "text-primary")
    })

    # -------------------------------------------------------------------------
    # Reactive: current bslib theme object
    # -------------------------------------------------------------------------
    current_theme <- reactive({
      trigger_val <- theme_update_trigger()
      theme_choice <- applied_theme()

      log_debug(paste("current_theme() reactive triggered. Trigger:",
                      trigger_val, "Choice:", theme_choice))

      if (theme_choice == "bootstrap") {
        # Default Bootstrap theme (no bootswatch)
        bs_theme(version = 5)
      } else {
        # Apply bootswatch theme with environmental enhancements
        base_theme <- bs_theme(version = 5, bootswatch = theme_choice)

        # Theme-specific customizations for environmental application
        if (theme_choice == "journal") {
          base_theme <- bs_theme(
            version = 5,
            bootswatch = theme_choice,
            success = "#2E7D32",
            info = "#0277BD",
            warning = "#F57C00",
            danger = "#C62828"
          )
        } else if (theme_choice %in% c("darkly", "slate", "superhero", "cyborg")) {
          base_theme <- bs_theme(
            version = 5,
            bootswatch = theme_choice,
            bg = if (theme_choice == "darkly") "#212529" else NULL,
            fg = if (theme_choice == "darkly") "#ffffff" else NULL
          )
        }

        base_theme
      }
    })

    # -------------------------------------------------------------------------
    # Observer: attempt to push theme to bslib session (if supported)
    # -------------------------------------------------------------------------
    observe({
      theme <- current_theme()
      tryCatch({
        if (exists("bs_themer") && packageVersion("bslib") >= "0.4.0") {
          if (exists("session$setCurrentTheme")) {
            session$setCurrentTheme(theme)
          }
        }
      }, error = function(e) {
        # Silent -- CSS injection is the primary mechanism
      })
    })

    # -------------------------------------------------------------------------
    # Apply Theme button handler
    # -------------------------------------------------------------------------
    observeEvent(input$applyTheme, {
      req(input$theme_preset)
      log_debug(paste("Apply Theme button pressed. Selected theme:",
                      input$theme_preset))

      # Update reactive values
      applied_theme(input$theme_preset)
      old_trigger <- theme_update_trigger()
      new_trigger <- old_trigger + 1
      theme_update_trigger(new_trigger)

      log_debug(paste("Theme trigger updated from", old_trigger, "to",
                      new_trigger))

      # Apply theme using CSS injection (most reliable across bs4Dash/bslib)
      tryCatch({
        theme_name <- input$theme_preset
        if (theme_name != "custom" && theme_name != "bootstrap") {
          css_url <- paste0(
            "https://cdn.jsdelivr.net/npm/bootswatch@5.3.0/dist/",
            theme_name, "/bootstrap.min.css"
          )

          runjs(paste0("
            // Remove existing bootswatch theme
            $('link[href*=\"bootswatch\"]').remove();
            $('link[href*=\"bootstrap\"]').last().remove();

            // Add new theme
            $('<link>').attr({
              rel: 'stylesheet',
              type: 'text/css',
              href: '", css_url, "'
            }).appendTo('head');
          "))

          log_debug("Theme CSS injected successfully")

        } else if (theme_name == "bootstrap") {
          runjs("
            $('link[href*=\"bootswatch\"]').remove();
            $('<link>').attr({
              rel: 'stylesheet',
              type: 'text/css',
              href: 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css'
            }).appendTo('head');
          ")
          log_debug("Default Bootstrap theme applied")
        }
      }, error = function(e) {
        log_error(paste("Theme CSS injection failed:", e$message))
      })

      # Display name lookup for the notification
      theme_names <- c(
        "Environmental (Default)" = "journal",
        "Dark Mode" = "darkly",
        "Light & Clean" = "flatly",
        "Ocean Blue" = "cosmo",
        "Forest Green" = "materia",
        "Corporate Blue" = "cerulean",
        "Minimal Clean" = "minty",
        "Dashboard" = "lumen",
        "Creative Purple" = "pulse",
        "Science Lab" = "sandstone",
        "Space Dark" = "slate",
        "Professional" = "united",
        "Modern Contrast" = "superhero",
        "Sunset Orange" = "solar",
        "Analytics" = "spacelab",
        "Vibrant" = "sketchy",
        "Nature Fresh" = "cyborg",
        "Business" = "vapor",
        "Research" = "zephyr",
        "High Contrast" = "bootstrap"
      )

      theme_display_name <- names(which(theme_names == input$theme_preset))
      if (length(theme_display_name) > 0) {
        notify_info(paste("Applied theme:", theme_display_name), duration = 3)
      } else {
        notify_info(paste(t("notify_theme_applied", lang())), duration = 3)
      }
    })

    # -------------------------------------------------------------------------
    # Return module API (accessible to callers via the return value)
    # -------------------------------------------------------------------------
    list(
      current_theme = current_theme,
      applied_theme = applied_theme,
      theme_update_trigger = theme_update_trigger
    )
  })
}
