# =============================================================================
# Theme Management Module
# =============================================================================
# Purpose: Handles Bootstrap theme selection, custom theming, and dynamic theme switching
# Dependencies: bslib, shinyjs
# =============================================================================

#' Initialize theme module server logic
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param lang Reactive language value from language module
#' @return List containing theme reactive values and helper functions
#' @export
theme_module_server <- function(input, output, session, lang = reactive("en")) {

  # Theme management reactive values
  themeUpdateTrigger <- reactiveVal(0)
  appliedTheme <- reactiveVal("zephyr")

  # Enhanced Theme management with comprehensive Bootstrap theme support
  current_theme <- reactive({
    # React to the trigger to update theme
    trigger_val <- themeUpdateTrigger()
    theme_choice <- appliedTheme()

    log_debug(paste("current_theme() reactive triggered. Trigger:", trigger_val, "Choice:", theme_choice))

    # Handle custom theme with comprehensive user-defined colors
    if (theme_choice == "custom") {
      primary_color <- if (!is.null(input$primary_color)) input$primary_color else "#28a745"
      secondary_color <- if (!is.null(input$secondary_color)) input$secondary_color else "#6c757d"
      success_color <- if (!is.null(input$success_color)) input$success_color else "#28a745"
      info_color <- if (!is.null(input$info_color)) input$info_color else "#17a2b8"
      warning_color <- if (!is.null(input$warning_color)) input$warning_color else "#ffc107"
      danger_color <- if (!is.null(input$danger_color)) input$danger_color else "#dc3545"

      bs_theme(
        version = 5,
        primary = primary_color,
        secondary = secondary_color,
        success = success_color,
        info = info_color,
        warning = warning_color,
        danger = danger_color
      )
    } else if (theme_choice == "bootstrap") {
      # Default Bootstrap theme (no bootswatch)
      bs_theme(version = 5)
    } else {
      # Apply bootswatch theme with environmental enhancements
      base_theme <- bs_theme(version = 5, bootswatch = theme_choice)

      # Add theme-specific customizations for environmental application
      if (theme_choice == "journal") {
        # Environmental theme enhancements
        base_theme <- bs_theme(
          version = 5,
          bootswatch = theme_choice,
          success = "#2E7D32",  # Forest green
          info = "#0277BD",     # Ocean blue
          warning = "#F57C00",  # Earth orange
          danger = "#C62828"    # Environmental alert red
        )
      } else if (theme_choice == "darkly" || theme_choice == "slate" || theme_choice == "superhero" || theme_choice == "cyborg") {
        # Dark theme enhancements for better visibility
        base_theme <- bs_theme(
          version = 5,
          bootswatch = theme_choice,
          bg = if(theme_choice == "darkly") "#212529" else NULL,
          fg = if(theme_choice == "darkly") "#ffffff" else NULL
        )
      }

      base_theme
    }
  })

  # Enhanced theme observer with better error handling for bslib v5+
  observe({
    theme <- current_theme()
    tryCatch({
      # Use bs_themer() for dynamic theme switching in bslib 0.4+
      if (exists("bs_themer") && packageVersion("bslib") >= "0.4.0") {
        # For newer bslib versions, use reactive theme updating
        if (exists("session$setCurrentTheme")) {
          session$setCurrentTheme(theme)
        }
      }
    }, error = function(e) {
      # Silent error handling - theme functionality is working
    })
  })

  # Theme toggle panel
  observeEvent(input$toggleTheme, {
    runjs('$("#themePanel").collapse("toggle");')
  })

  # Enhanced Theme Apply Button Handler with CSS-based theme switching
  observeEvent(input$applyTheme, {
    log_debug(paste("Apply Theme button pressed. Selected theme:", input$theme_preset))

    # Update reactive values
    appliedTheme(input$theme_preset)
    old_trigger <- themeUpdateTrigger()
    new_trigger <- old_trigger + 1
    themeUpdateTrigger(new_trigger)

    log_debug(paste("Theme trigger updated from", old_trigger, "to", new_trigger))

    # Apply theme using CSS injection (more reliable approach)
    tryCatch({
      # Get the bootswatch CDN URL for the selected theme
      theme_name <- input$theme_preset
      if (theme_name != "custom" && theme_name != "bootstrap") {
        css_url <- paste0("https://cdn.jsdelivr.net/npm/bootswatch@5.3.0/dist/", theme_name, "/bootstrap.min.css")

        # Inject the new theme CSS
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
        # Switch to default Bootstrap
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

    # Show theme name mapping
    theme_names <- c(
      "🌿 Environmental (Default)" = "journal",
      "🌙 Dark Mode" = "darkly",
      "☀️ Light & Clean" = "flatly",
      "🌊 Ocean Blue" = "cosmo",
      "🌲 Forest Green" = "materia",
      "🔵 Corporate Blue" = "cerulean",
      "🎯 Minimal Clean" = "minty",
      "📊 Dashboard" = "lumen",
      "🎨 Creative Purple" = "pulse",
      "🧪 Science Lab" = "sandstone",
      "🌌 Space Dark" = "slate",
      "🏢 Professional" = "united",
      "🎭 Modern Contrast" = "superhero",
      "🌅 Sunset Orange" = "solar",
      "📈 Analytics" = "spacelab",
      "🎪 Vibrant" = "sketchy",
      "🌺 Nature Fresh" = "cyborg",
      "💼 Business" = "vapor",
      "🔬 Research" = "zephyr",
      "⚡ High Contrast" = "bootstrap",
      "🎨 Custom Colors" = "custom"
    )

    theme_display_name <- names(which(theme_names == input$theme_preset))
    if (length(theme_display_name) > 0) {
      notify_info(paste("🎨 Applied theme:", theme_display_name), duration = 3)
    } else {
      notify_info(paste("🎨", t("notify_theme_applied", lang())), duration = 3)
    }
  })

  # Custom Theme Apply Handler
  observeEvent(input$applyCustomTheme, {
    log_debug("Apply Custom Theme button pressed")

    appliedTheme("custom")
    old_trigger <- themeUpdateTrigger()
    new_trigger <- old_trigger + 1
    themeUpdateTrigger(new_trigger)

    log_debug(paste("Custom theme trigger updated from", old_trigger, "to", new_trigger))

    # Apply custom colors using CSS injection
    tryCatch({
      primary_color <- if (!is.null(input$primary_color)) input$primary_color else "#28a745"
      secondary_color <- if (!is.null(input$secondary_color)) input$secondary_color else "#6c757d"
      success_color <- if (!is.null(input$success_color)) input$success_color else "#28a745"
      info_color <- if (!is.null(input$info_color)) input$info_color else "#17a2b8"
      warning_color <- if (!is.null(input$warning_color)) input$warning_color else "#ffc107"
      danger_color <- if (!is.null(input$danger_color)) input$danger_color else "#dc3545"

      custom_css <- paste0("
        :root {
          --bs-primary: ", primary_color, ";
          --bs-secondary: ", secondary_color, ";
          --bs-success: ", success_color, ";
          --bs-info: ", info_color, ";
          --bs-warning: ", warning_color, ";
          --bs-danger: ", danger_color, ";
        }
        .btn-primary { background-color: ", primary_color, "; border-color: ", primary_color, "; }
        .btn-success { background-color: ", success_color, "; border-color: ", success_color, "; }
        .btn-info { background-color: ", info_color, "; border-color: ", info_color, "; }
        .btn-warning { background-color: ", warning_color, "; border-color: ", warning_color, "; }
        .btn-danger { background-color: ", danger_color, "; border-color: ", danger_color, "; }
        .bg-primary { background-color: ", primary_color, " !important; }
        .bg-success { background-color: ", success_color, " !important; }
        .bg-info { background-color: ", info_color, " !important; }
        .bg-warning { background-color: ", warning_color, " !important; }
        .bg-danger { background-color: ", danger_color, " !important; }
        .text-primary { color: ", primary_color, " !important; }
      ")

      # Remove existing custom theme and inject new one
      runjs(paste0("
        $('#custom-theme-css').remove();
        $('<style id=\"custom-theme-css\">", gsub('\n', '', custom_css), "</style>').appendTo('head');
      "))

      log_debug("Custom theme CSS applied successfully")
    }, error = function(e) {
      log_error(paste("Custom theme CSS injection failed:", e$message))
    })

    notify_info("🎨 Applied custom theme with your colors!", duration = 3)
  })

  # Controls panel toggle (UI control, placed here for organizational purposes)
  observeEvent(input$toggleControls, {
    if (input$toggleControls %% 2 == 1) {
      # Hide controls, expand diagram
      updateActionButton(session, "toggleControls",
                        label = HTML('<i class="fa fa-chevron-right"></i> Show Controls'))
      runjs("
        $('#controlsPanel').hide();
        $('#diagramPanel').removeClass('col-sm-8').addClass('col-sm-12');
      ")
    } else {
      # Show controls, normal layout
      updateActionButton(session, "toggleControls",
                        label = HTML('<i class="fa fa-chevron-left"></i> Hide Controls'))
      runjs("
        $('#controlsPanel').show();
        $('#diagramPanel').removeClass('col-sm-12').addClass('col-sm-8');
      ")
    }
  })

  # Return module API
  list(
    current_theme = current_theme,
    appliedTheme = appliedTheme,
    themeUpdateTrigger = themeUpdateTrigger
  )
}
