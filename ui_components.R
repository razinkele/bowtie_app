# =============================================================================
# UI Components Library
# Version: 1.0.0
# Date: 2025-12-26
# Description: Reusable UI components for improved user experience
# =============================================================================

# =============================================================================
# EMPTY STATE COMPONENTS
# =============================================================================

#' Create an empty state component
#'
#' @param icon_name FontAwesome icon name
#' @param title Main heading text
#' @param message Descriptive message text
#' @param primary_action Primary action button (optional)
#' @param secondary_action Secondary action button (optional)
#' @param class_modifier Additional CSS classes
#'
#' @return Shiny UI div element
#'
#' @examples
#' empty_state(
#'   icon_name = "upload",
#'   title = "No Data Uploaded",
#'   message = "Upload an Excel file to get started",
#'   primary_action = actionButton("upload", "Upload File", class = "btn-primary")
#' )
empty_state <- function(
    icon_name = "diagram-project",
    title = "No Data",
    message = "Get started by uploading data or using the guided workflow",
    primary_action = NULL,
    secondary_action = NULL,
    class_modifier = ""
) {
  div(
    class = paste("empty-state text-center p-5", class_modifier),
    icon(icon_name, class = "empty-state-icon fa-4x text-muted mb-3"),
    h4(title, class = "text-muted mb-2"),
    p(message, class = "text-muted mb-4"),
    if (!is.null(primary_action) || !is.null(secondary_action)) {
      div(
        class = "d-flex gap-2 justify-content-center mt-4",
        primary_action,
        secondary_action
      )
    }
  )
}

#' Empty state for data table
empty_state_table <- function(
    message = "No data available. Upload a file or generate sample data to get started."
) {
  empty_state(
    icon_name = "table",
    title = "No Data to Display",
    message = message
  )
}

#' Empty state for network visualization
empty_state_network <- function(
    message = "No network to display. Load data to visualize the bowtie diagram."
) {
  empty_state(
    icon_name = "diagram-project",
    title = "No Network Diagram",
    message = message
  )
}

#' Empty state for search results
empty_state_search <- function(query = NULL) {
  msg <- if (!is.null(query) && nchar(query) > 0) {
    paste0("No results found for '", query, "'. Try different search terms.")
  } else {
    "Enter search terms to find vocabulary items."
  }

  empty_state(
    icon_name = "search",
    title = "No Results Found",
    message = msg
  )
}

# =============================================================================
# FORM VALIDATION COMPONENTS
# =============================================================================

#' Create a validated input field
#'
#' @param id Input ID
#' @param label Field label
#' @param type Input type (text, number, email, etc.)
#' @param value Initial value
#' @param placeholder Placeholder text
#' @param required Whether field is required
#' @param help_text Help text to display below input
#' @param validation_rules List of validation rules
#'
#' @return Shiny UI div element
validated_text_input <- function(
    id,
    label,
    value = "",
    placeholder = "",
    required = FALSE,
    help_text = NULL,
    pattern = NULL,
    min_length = NULL,
    max_length = NULL
) {
  div(
    class = "form-group mb-3",
    tags$label(
      `for` = id,
      class = paste("form-label", if (required) "required"),
      label,
      if (required) {
        tags$span(class = "text-danger ms-1", "*")
      }
    ),
    textInput(
      id,
      label = NULL,
      value = value,
      placeholder = placeholder
    ),
    if (!is.null(help_text)) {
      div(class = "form-text text-muted small", help_text)
    },
    div(
      class = "invalid-feedback",
      id = paste0(id, "_error"),
      uiOutput(paste0(id, "_error_msg"))
    ),
    div(
      class = "valid-feedback",
      icon("check-circle"), " Looks good!"
    ),
    # Store validation rules as data attributes
    tags$script(HTML(paste0("
      $('#", id, "').data('required', ", tolower(as.character(required)), ");
      ", if (!is.null(min_length)) paste0("$('#", id, "').data('minLength', ", min_length, ");") else "", "
      ", if (!is.null(max_length)) paste0("$('#", id, "').data('maxLength', ", max_length, ");") else "", "
      ", if (!is.null(pattern)) paste0("$('#", id, "').data('pattern', '", pattern, "');") else "", "
    ")))
  )
}

#' Create a validated select input
validated_select_input <- function(
    id,
    label,
    choices,
    selected = NULL,
    required = FALSE,
    help_text = NULL,
    multiple = FALSE
) {
  div(
    class = "form-group mb-3",
    tags$label(
      `for` = id,
      class = paste("form-label", if (required) "required"),
      label,
      if (required) {
        tags$span(class = "text-danger ms-1", "*")
      }
    ),
    selectInput(
      id,
      label = NULL,
      choices = choices,
      selected = selected,
      multiple = multiple
    ),
    if (!is.null(help_text)) {
      div(class = "form-text text-muted small", help_text)
    },
    div(
      class = "invalid-feedback",
      uiOutput(paste0(id, "_error_msg"))
    )
  )
}

# =============================================================================
# ERROR DISPLAY COMPONENTS
# =============================================================================

#' Create a friendly error message display
#'
#' @param title Error title
#' @param message Main error message
#' @param details Technical details (optional, collapsible)
#' @param suggestions List of suggested actions
#' @param retry_button Include retry button
#' @param retry_id ID for retry button
#'
#' @return Shiny UI div element
error_display <- function(
    title = "Something Went Wrong",
    message = "We encountered an error while processing your request.",
    details = NULL,
    suggestions = NULL,
    retry_button = FALSE,
    retry_id = "retry_action"
) {
  div(
    class = "alert alert-danger alert-dismissible fade show",
    role = "alert",

    # Header
    h5(
      class = "alert-heading mb-2",
      icon("exclamation-triangle"), " ", title
    ),

    # Main message
    p(class = "mb-2", message),

    # Suggestions
    if (!is.null(suggestions) && length(suggestions) > 0) {
      tagList(
        hr(),
        p(class = "mb-1", strong("What you can do:")),
        tags$ul(
          class = "mb-2",
          lapply(suggestions, function(s) tags$li(s))
        )
      )
    },

    # Technical details (collapsible)
    if (!is.null(details)) {
      tagList(
        hr(),
        div(
          class = "mb-0",
          tags$a(
            href = "#errorDetails",
            class = "text-decoration-none",
            `data-bs-toggle` = "collapse",
            icon("chevron-down"), " Show technical details"
          ),
          div(
            id = "errorDetails",
            class = "collapse mt-2",
            div(
              class = "bg-light p-2 rounded",
              tags$pre(
                class = "mb-0",
                style = "font-size: 0.8em; max-height: 200px; overflow-y: auto;",
                details
              )
            )
          )
        )
      )
    },

    # Retry button
    if (retry_button) {
      div(
        class = "mt-3",
        actionButton(
          retry_id,
          tagList(icon("rotate-right"), " Try Again"),
          class = "btn-warning btn-sm"
        )
      )
    },

    # Close button
    tags$button(
      type = "button",
      class = "btn-close",
      `data-bs-dismiss` = "alert",
      `aria-label` = "Close"
    )
  )
}

#' Create a warning display
warning_display <- function(
    title = "Warning",
    message,
    dismissible = TRUE
) {
  div(
    class = paste(
      "alert alert-warning",
      if (dismissible) "alert-dismissible fade show"
    ),
    role = "alert",
    h6(
      class = "alert-heading mb-1",
      icon("exclamation-circle"), " ", title
    ),
    p(class = "mb-0", message),
    if (dismissible) {
      tags$button(
        type = "button",
        class = "btn-close",
        `data-bs-dismiss` = "alert",
        `aria-label` = "Close"
      )
    }
  )
}

#' Create an info display
info_display <- function(
    title = "Information",
    message,
    dismissible = TRUE
) {
  div(
    class = paste(
      "alert alert-info",
      if (dismissible) "alert-dismissible fade show"
    ),
    role = "alert",
    h6(
      class = "alert-heading mb-1",
      icon("info-circle"), " ", title
    ),
    p(class = "mb-0", message),
    if (dismissible) {
      tags$button(
        type = "button",
        class = "btn-close",
        `data-bs-dismiss` = "alert",
        `aria-label` = "Close"
      )
    }
  )
}

#' Create a success display
success_display <- function(
    title = "Success",
    message,
    dismissible = TRUE
) {
  div(
    class = paste(
      "alert alert-success",
      if (dismissible) "alert-dismissible fade show"
    ),
    role = "alert",
    h6(
      class = "alert-heading mb-1",
      icon("check-circle"), " ", title
    ),
    p(class = "mb-0", message),
    if (dismissible) {
      tags$button(
        type = "button",
        class = "btn-close",
        `data-bs-dismiss` = "alert",
        `aria-label` = "Close"
      )
    }
  )
}

# =============================================================================
# LOADING STATE COMPONENTS
# =============================================================================

#' Create a skeleton loader for tables
skeleton_table <- function(rows = 5, cols = 4, height = "400px") {
  div(
    class = "skeleton-table",
    style = paste0("height: ", height, "; overflow: hidden;"),

    # Header
    div(
      class = "skeleton-table-header d-flex gap-2 mb-2 p-2",
      lapply(1:cols, function(i) {
        div(
          class = "skeleton-col flex-fill",
          style = "height: 20px; background: #e9ecef; border-radius: 4px;"
        )
      })
    ),

    # Rows
    lapply(1:rows, function(i) {
      div(
        class = "skeleton-row d-flex gap-2 mb-2 p-2",
        lapply(1:cols, function(j) {
          div(
            class = "skeleton-cell flex-fill",
            style = "height: 16px; background: #f8f9fa; border-radius: 4px;"
          )
        })
      )
    })
  )
}

#' Create a skeleton loader for network diagrams
skeleton_network <- function(height = "500px") {
  div(
    class = "skeleton-network d-flex align-items-center justify-content-center",
    style = paste0("height: ", height, "; background: #f8f9fa; border-radius: 8px;"),
    div(
      class = "text-center",
      div(
        class = "spinner-border text-primary mb-3",
        role = "status",
        style = "width: 3rem; height: 3rem;",
        tags$span(class = "visually-hidden", "Loading...")
      ),
      p(class = "text-muted", "Loading network diagram...")
    )
  )
}

# =============================================================================
# ACCESSIBILITY COMPONENTS
# =============================================================================

#' Create skip navigation links
skip_links <- function() {
  div(
    class = "skip-links",
    tags$a(
      href = "#main-content",
      class = "skip-link visually-hidden-focusable",
      "Skip to main content"
    ),
    tags$a(
      href = "#navigation",
      class = "skip-link visually-hidden-focusable",
      "Skip to navigation"
    )
  )
}

#' Create an accessible button with proper ARIA labels
accessible_button <- function(
    id,
    label,
    icon_name = NULL,
    class = "btn-primary",
    aria_label = NULL,
    title = NULL
) {
  actionButton(
    id,
    label = if (!is.null(icon_name)) {
      tagList(icon(icon_name), " ", label)
    } else {
      label
    },
    class = class,
    `aria-label` = aria_label %||% label,
    title = title %||% label
  )
}

# =============================================================================
# CSS STYLES FOR COMPONENTS
# =============================================================================

#' Get CSS for UI components
ui_components_css <- function() {
  tags$style(HTML("
    /* Empty State Styles */
    .empty-state {
      min-height: 300px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
    }

    .empty-state-icon {
      opacity: 0.3;
    }

    /* Form Validation Styles */
    .form-label.required::after {
      content: '';
      margin-left: 0.25rem;
    }

    .form-control.is-invalid {
      border-color: #dc3545;
      padding-right: calc(1.5em + .75rem);
      background-image: url(\"data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linejoin='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e\");
      background-repeat: no-repeat;
      background-position: right calc(.375em + .1875rem) center;
      background-size: calc(.75em + .375rem) calc(.75em + .375rem);
    }

    .form-control.is-valid {
      border-color: #28a745;
      padding-right: calc(1.5em + .75rem);
      background-image: url(\"data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 8 8'%3e%3cpath fill='%2328a745' d='M2.3 6.73L.6 4.53c-.4-1.04.46-1.4 1.1-.8l1.1 1.4 3.4-3.8c.6-.63 1.6-.27 1.2.7l-4 4.6c-.43.5-.8.4-1.1.1z'/%3e%3c/svg%3e\");
      background-repeat: no-repeat;
      background-position: right calc(.375em + .1875rem) center;
      background-size: calc(.75em + .375rem) calc(.75em + .375rem);
    }

    .invalid-feedback {
      display: none;
      width: 100%;
      margin-top: 0.25rem;
      font-size: 0.875em;
      color: #dc3545;
    }

    .form-control.is-invalid ~ .invalid-feedback {
      display: block;
    }

    .valid-feedback {
      display: none;
      width: 100%;
      margin-top: 0.25rem;
      font-size: 0.875em;
      color: #28a745;
    }

    .form-control.is-valid ~ .valid-feedback {
      display: block;
    }

    /* Skeleton Loading Styles */
    .skeleton-cell, .skeleton-col {
      animation: skeleton-loading 1.5s ease-in-out infinite;
    }

    @keyframes skeleton-loading {
      0% {
        opacity: 1;
      }
      50% {
        opacity: 0.4;
      }
      100% {
        opacity: 1;
      }
    }

    /* Skip Links */
    .skip-links {
      position: absolute;
      top: 0;
      left: 0;
      z-index: 9999;
    }

    .skip-link {
      position: absolute;
      left: -9999px;
      z-index: 999;
      padding: 0.5rem 1rem;
      background-color: #007bff;
      color: white;
      text-decoration: none;
      border-radius: 0 0 0.25rem 0.25rem;
    }

    .skip-link:focus {
      left: 0;
      top: 0;
    }

    /* Accessibility - Focus Visible */
    *:focus-visible {
      outline: 2px solid #007bff;
      outline-offset: 2px;
    }

    /* Alert improvements */
    .alert {
      border-left-width: 4px;
    }

    .alert-heading {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    /* Responsive gap utility */
    .gap-2 {
      gap: 0.5rem !important;
    }
  "))
}

#' Get JavaScript for UI components
ui_components_js <- function() {
  tags$script(HTML("
    // Real-time form validation
    $(document).ready(function() {
      // Add input event listeners for validation
      $('input[type=\"text\"], input[type=\"email\"], input[type=\"number\"], textarea').on('input', function() {
        validateField(this);
      });

      // Add change event for selects
      $('select').on('change', function() {
        validateField(this);
      });
    });

    function validateField(field) {
      var $field = $(field);
      var value = $field.val();
      var isValid = true;
      var errorMsg = '';

      // Required validation
      if ($field.data('required') && (!value || value.trim() === '')) {
        isValid = false;
        errorMsg = 'This field is required.';
      }

      // Min length validation
      if (isValid && $field.data('minLength') && value.length < $field.data('minLength')) {
        isValid = false;
        errorMsg = 'Minimum ' + $field.data('minLength') + ' characters required.';
      }

      // Max length validation
      if (isValid && $field.data('maxLength') && value.length > $field.data('maxLength')) {
        isValid = false;
        errorMsg = 'Maximum ' + $field.data('maxLength') + ' characters allowed.';
      }

      // Pattern validation
      if (isValid && $field.data('pattern')) {
        var pattern = new RegExp($field.data('pattern'));
        if (!pattern.test(value)) {
          isValid = false;
          errorMsg = 'Invalid format.';
        }
      }

      // Update field state
      if (value && value.trim() !== '') {
        if (isValid) {
          $field.removeClass('is-invalid').addClass('is-valid');
        } else {
          $field.removeClass('is-valid').addClass('is-invalid');
          $field.siblings('.invalid-feedback').find('[id$=\"_error_msg\"]').text(errorMsg);
        }
      } else {
        $field.removeClass('is-valid is-invalid');
      }
    }

    // Keyboard shortcuts
    $(document).on('keydown', function(e) {
      // Alt+G: Guided Workflow
      if (e.altKey && e.key === 'g') {
        e.preventDefault();
        $('a[data-value=\"guided\"]').click();
      }

      // Alt+D: Data Upload
      if (e.altKey && e.key === 'd') {
        e.preventDefault();
        $('a[data-value=\"upload\"]').click();
      }

      // Alt+V: Visualization
      if (e.altKey && e.key === 'v') {
        e.preventDefault();
        $('a[data-value=\"visualization\"]').click();
      }

      // Escape: Close modals
      if (e.key === 'Escape') {
        $('.modal').modal('hide');
      }
    });
  "))
}

# =============================================================================
# RESPONSIVE DESIGN COMPONENTS (Phase 3)
# =============================================================================

#' Responsive container helper
#'
#' @param ... Content to wrap
#' @param mobile_cols Column width on mobile (default 12 - full width)
#' @param tablet_cols Column width on tablet (default 6 - half width)
#' @param desktop_cols Column width on desktop (default 4 - third width)
#'
#' @return Shiny UI div element with responsive column classes
responsive_container <- function(..., mobile_cols = 12, tablet_cols = 6, desktop_cols = 4) {
  div(
    class = sprintf("col-%d col-md-%d col-lg-%d", mobile_cols, tablet_cols, desktop_cols),
    ...
  )
}

#' Mobile-friendly card component
#'
#' @param title Card title
#' @param content Card content
#' @param icon_name Optional FontAwesome icon
#' @param mobile_padding Reduced padding on mobile (default TRUE)
#'
#' @return Shiny card element optimized for mobile
mobile_card <- function(title, content, icon_name = NULL, mobile_padding = TRUE) {
  card(
    card_header(
      div(class = "d-flex justify-content-between align-items-center",
          div(
            if (!is.null(icon_name)) tagList(icon(icon_name), " "),
            span(title)
          )
      )
    ),
    card_body(
      class = if (mobile_padding) "p-2 p-md-3" else "",
      content
    )
  )
}

#' Responsive data table wrapper
#'
#' @param output_id Output ID for the data table
#' @param mobile_message Optional message to show on mobile instead of table
#' @param show_on_mobile Whether to show table on mobile (default TRUE)
#'
#' @return Shiny UI div with responsive table handling
responsive_table <- function(output_id, mobile_message = NULL, show_on_mobile = TRUE) {
  if (show_on_mobile) {
    div(class = "table-responsive",
        DT::dataTableOutput(output_id)
    )
  } else {
    tagList(
      # Desktop view
      div(class = "d-none d-md-block",
          DT::dataTableOutput(output_id)
      ),
      # Mobile message
      if (!is.null(mobile_message)) {
        div(class = "d-md-none",
            div(class = "alert alert-info",
                icon("mobile-alt"), " ",
                mobile_message
            )
        )
      }
    )
  }
}

#' Touch-optimized button
#'
#' @param id Button ID
#' @param label Button label
#' @param icon_name Optional icon
#' @param class Additional classes
#'
#' @return Action button with minimum touch target size
touch_button <- function(id, label, icon_name = NULL, class = "btn-primary") {
  actionButton(
    id,
    label = if (!is.null(icon_name)) tagList(icon(icon_name), " ", label) else label,
    class = paste("btn touch-target", class),
    style = "min-height: 44px; min-width: 44px;"
  )
}

# =============================================================================
# RESPONSIVE CSS ADDITIONS
# =============================================================================

responsive_css <- function() {
  tags$style(HTML("
    /* =================================================================
       RESPONSIVE DESIGN - PHASE 3
       ================================================================= */

    /* Mobile-first approach */
    @media (max-width: 768px) {
      /* Touch targets - minimum 44x44px */
      .btn, .touch-target {
        min-height: 44px !important;
        min-width: 44px !important;
        padding: 12px 20px !important;
      }

      /* Full-width inputs on mobile */
      input[type='text'],
      input[type='email'],
      input[type='password'],
      select,
      textarea {
        width: 100% !important;
        font-size: 16px !important; /* Prevents zoom on iOS */
        padding: 12px !important;
      }

      /* Larger select dropdowns */
      select {
        min-height: 44px !important;
      }

      /* Improved form spacing */
      .form-group,
      .mb-3 {
        margin-bottom: 1.5rem !important;
      }

      /* Simplified navigation */
      .nav-tabs {
        flex-direction: column;
      }

      .nav-tabs .nav-link {
        text-align: left;
        border-radius: 0;
        padding: 12px 16px;
      }

      /* Card spacing */
      .card {
        margin-bottom: 1rem;
        border-radius: 8px;
      }

      .card-body {
        padding: 1rem;
      }

      /* Network diagram adjustments */
      .network-container {
        height: 350px !important;
        border-radius: 8px;
      }

      /* Hide less important columns in tables */
      .hide-mobile {
        display: none !important;
      }

      /* Stack columns vertically */
      .row > div[class*='col-'] {
        margin-bottom: 1rem;
      }

      /* Larger modal dialogs */
      .modal-dialog {
        margin: 0.5rem;
      }

      /* Better alert spacing */
      .alert {
        font-size: 14px;
        padding: 12px;
      }

      /* Improved empty state spacing */
      .empty-state {
        padding: 2rem 1rem !important;
      }

      .empty-state-icon {
        font-size: 3rem !important;
      }

      /* Action button group spacing */
      .d-flex.gap-2 {
        gap: 0.75rem !important;
        flex-direction: column;
      }

      .d-flex.gap-2 .btn {
        width: 100%;
      }
    }

    /* Tablet optimizations (768px - 1024px) */
    @media (min-width: 768px) and (max-width: 1024px) {
      .network-container {
        height: 450px;
      }

      .card-body {
        padding: 1.25rem;
      }

      /* Two-column layout for tablets */
      .responsive-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 1rem;
      }
    }

    /* Desktop optimizations (1024px+) */
    @media (min-width: 1024px) {
      .network-container {
        height: 600px;
      }

      /* Three-column layout for desktop */
      .responsive-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 1.5rem;
      }
    }

    /* Landscape orientation adjustments */
    @media (max-width: 768px) and (orientation: landscape) {
      .network-container {
        height: 300px !important;
      }

      .modal-dialog {
        max-height: 90vh;
        overflow-y: auto;
      }
    }

    /* Print styles */
    @media print {
      .btn, .nav-tabs, .sidebar {
        display: none;
      }

      .network-container {
        height: auto !important;
      }

      .card {
        break-inside: avoid;
      }
    }

    /* High DPI display support */
    @media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
      /* Sharper borders */
      .card, .btn, input, select {
        border-width: 0.5px;
      }
    }

    /* Reduced motion for accessibility */
    @media (prefers-reduced-motion: reduce) {
      * {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
      }
    }
  "))
}

# =============================================================================
# DARK MODE OPTIMIZATION (Phase 3)
# =============================================================================

dark_mode_css <- function() {
  tags$style(HTML("
    /* =================================================================
       DARK MODE OPTIMIZATION - PHASE 3
       ================================================================= */

    [data-bs-theme='dark'] {
      /* Better contrast for inputs */
      input[type='text'],
      input[type='email'],
      input[type='password'],
      input[type='number'],
      select,
      textarea {
        background-color: #2d3748 !important;
        border-color: #4a5568 !important;
        color: #e2e8f0 !important;
      }

      input:focus,
      select:focus,
      textarea:focus {
        background-color: #374151 !important;
        border-color: #60a5fa !important;
        box-shadow: 0 0 0 0.25rem rgba(96, 165, 250, 0.25) !important;
      }

      /* Empty state optimization */
      .empty-state {
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 8px;
      }

      .empty-state-icon {
        opacity: 0.6;
      }

      /* Error display optimization */
      .alert-danger {
        background-color: rgba(220, 38, 38, 0.15) !important;
        border-color: rgba(220, 38, 38, 0.3) !important;
        color: #fca5a5 !important;
      }

      .alert-warning {
        background-color: rgba(245, 158, 11, 0.15) !important;
        border-color: rgba(245, 158, 11, 0.3) !important;
        color: #fcd34d !important;
      }

      .alert-info {
        background-color: rgba(59, 130, 246, 0.15) !important;
        border-color: rgba(59, 130, 246, 0.3) !important;
        color: #93c5fd !important;
      }

      .alert-success {
        background-color: rgba(16, 185, 129, 0.15) !important;
        border-color: rgba(16, 185, 129, 0.3) !important;
        color: #6ee7b7 !important;
      }

      /* Card backgrounds */
      .card {
        background-color: #1f2937 !important;
        border-color: #374151 !important;
      }

      .card-header {
        background-color: #111827 !important;
        border-bottom-color: #374151 !important;
      }

      /* Table styling */
      .table {
        --bs-table-bg: #1f2937;
        --bs-table-border-color: #374151;
        color: #e5e7eb;
      }

      .table-striped > tbody > tr:nth-of-type(odd) > * {
        background-color: rgba(255, 255, 255, 0.02);
      }

      /* Network container */
      .network-container {
        background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
        border-color: #374151;
      }

      /* Form validation states */
      .is-valid {
        border-color: #10b981 !important;
        color: #6ee7b7 !important;
      }

      .is-invalid {
        border-color: #ef4444 !important;
        color: #fca5a5 !important;
      }

      .valid-feedback {
        color: #6ee7b7 !important;
      }

      .invalid-feedback {
        color: #fca5a5 !important;
      }

      /* Modal backgrounds */
      .modal-content {
        background-color: #1f2937;
        border-color: #374151;
      }

      .modal-header {
        border-bottom-color: #374151;
      }

      .modal-footer {
        border-top-color: #374151;
      }

      /* Dropdown menus */
      .dropdown-menu {
        background-color: #1f2937;
        border-color: #374151;
      }

      .dropdown-item {
        color: #e5e7eb;
      }

      .dropdown-item:hover {
        background-color: #374151;
      }

      /* Navigation tabs */
      .nav-tabs {
        border-bottom-color: #374151;
      }

      .nav-tabs .nav-link {
        color: #9ca3af;
      }

      .nav-tabs .nav-link:hover {
        border-color: #4b5563 #4b5563 #374151;
      }

      .nav-tabs .nav-link.active {
        background-color: #1f2937;
        border-color: #374151 #374151 #1f2937;
        color: #e5e7eb;
      }

      /* Skeleton loaders */
      .skeleton {
        background: linear-gradient(
          90deg,
          #2d3748 25%,
          #374151 50%,
          #2d3748 75%
        );
        background-size: 1000px 100%;
      }
    }

    /* Smooth theme transitions */
    * {
      transition: background-color 0.3s ease,
                  color 0.3s ease,
                  border-color 0.3s ease;
    }

    /* Prevent transition on page load */
    .preload * {
      transition: none !important;
    }
  "))
}

# =============================================================================
# MICRO-INTERACTIONS (Phase 3)
# =============================================================================

micro_interactions_css <- function() {
  tags$style(HTML("
    /* =================================================================
       MICRO-INTERACTIONS - PHASE 3
       ================================================================= */

    /* Button hover effects */
    .btn {
      position: relative;
      overflow: hidden;
      transition: all 0.3s ease;
    }

    .btn:hover:not(:disabled) {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    .btn:active:not(:disabled) {
      transform: translateY(0);
    }

    /* Card hover animations */
    .card {
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .card.interactive:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0,0,0,0.12);
    }

    /* Fade in animation */
    @keyframes fadeIn {
      from {
        opacity: 0;
        transform: translateY(20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .fade-in {
      animation: fadeIn 0.5s ease;
    }

    /* Success pulse animation */
    @keyframes successPulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.05); }
    }

    .is-valid {
      animation: successPulse 0.5s ease;
    }

    /* Error shake animation */
    @keyframes shake {
      0%, 100% { transform: translateX(0); }
      25% { transform: translateX(-10px); }
      75% { transform: translateX(10px); }
    }

    .is-invalid {
      animation: shake 0.5s ease;
    }

    /* Pulse animation for loading states */
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.5; }
    }

    .loading {
      animation: pulse 2s infinite;
    }

    /* Skeleton shimmer */
    @keyframes shimmer {
      0% { background-position: -1000px 0; }
      100% { background-position: 1000px 0; }
    }

    .skeleton {
      background: linear-gradient(
        90deg,
        #f0f0f0 25%,
        #e0e0e0 50%,
        #f0f0f0 75%
      );
      background-size: 1000px 100%;
      animation: shimmer 2s infinite;
    }

    /* Icon spin animation */
    @keyframes spin {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }

    .spin {
      animation: spin 1s linear infinite;
    }

    /* Bounce animation */
    @keyframes bounce {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-10px); }
    }

    .bounce {
      animation: bounce 1s ease infinite;
    }

    /* Focus ring enhancement */
    input:focus,
    select:focus,
    textarea:focus,
    button:focus {
      outline: none;
      box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
    }

    /* Smooth scrolling */
    html {
      scroll-behavior: smooth;
    }

    /* Link hover underline effect */
    a {
      text-decoration: none;
      position: relative;
      transition: color 0.3s ease;
    }

    a::after {
      content: '';
      position: absolute;
      width: 0;
      height: 2px;
      bottom: -2px;
      left: 0;
      background-color: currentColor;
      transition: width 0.3s ease;
    }

    a:hover::after {
      width: 100%;
    }

    /* Empty state icon pulse */
    .empty-state-icon {
      animation: pulse 2s ease-in-out infinite;
    }

    /* Alert slide-in */
    @keyframes slideIn {
      from {
        transform: translateX(100%);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }

    .alert {
      animation: slideIn 0.3s ease;
    }

    /* Modal backdrop fade */
    .modal.fade .modal-dialog {
      transition: transform 0.3s ease-out;
    }

    .modal.show .modal-dialog {
      transform: scale(1);
    }

    /* Checkbox/Radio custom animations */
    input[type='checkbox'],
    input[type='radio'] {
      transition: all 0.2s ease;
    }

    input[type='checkbox']:checked,
    input[type='radio']:checked {
      transform: scale(1.1);
    }

    /* Tab navigation smooth transition */
    .nav-tabs .nav-link {
      transition: all 0.3s ease;
    }

    .nav-tabs .nav-link:hover {
      background-color: rgba(0, 0, 0, 0.03);
    }

    /* Progress bar animation */
    @keyframes progressBar {
      from { width: 0%; }
      to { width: var(--progress-value); }
    }

    .progress-bar {
      animation: progressBar 1s ease;
    }
  "))
}

# ==============================================================================
# HELP SYSTEM & TOOLTIPS (Phase 3 - Component 4)
# ==============================================================================

#' Create a button with Bootstrap tooltip
#'
#' @param id Button input ID
#' @param label Button label text
#' @param tooltip Tooltip text to display on hover
#' @param icon_name Optional FontAwesome icon name
#' @param class Button CSS class (default: "btn-secondary")
#' @param placement Tooltip placement: "top", "bottom", "left", "right"
#'
#' @return HTML for button with tooltip
#'
#' @examples
#' tooltip_button("help_btn", "Help", "Click for assistance", icon_name = "question-circle")
tooltip_button <- function(id, label, tooltip, icon_name = NULL,
                          class = "btn-secondary", placement = "top") {
  actionButton(
    inputId = id,
    label = if (!is.null(icon_name)) tagList(icon(icon_name), " ", label) else label,
    class = paste("btn", class),
    `data-bs-toggle` = "tooltip",
    `data-bs-placement` = placement,
    title = tooltip
  )
}

#' Create a help icon with popover
#'
#' @param id Unique identifier for this help icon
#' @param title Popover title
#' @param content Popover content (can be HTML)
#' @param icon_name FontAwesome icon (default: "question-circle")
#' @param placement Popover placement: "top", "bottom", "left", "right", "auto"
#' @param size Icon size class (e.g., "fa-lg", "fa-2x")
#'
#' @return HTML for help icon with popover
#'
#' @examples
#' help_icon("upload_help", "Data Upload", "Upload Excel files with bowtie data")
help_icon <- function(id, title, content, icon_name = "question-circle",
                     placement = "auto", size = NULL) {
  icon_class <- paste(c("text-info", size), collapse = " ")

  tags$a(
    href = "#",
    id = id,
    class = "help-icon ms-2",
    tabindex = "0",
    role = "button",
    `data-bs-toggle` = "popover",
    `data-bs-placement` = placement,
    `data-bs-trigger` = "focus hover",
    `data-bs-title` = title,
    `data-bs-content` = content,
    `data-bs-html` = "true",
    icon(icon_name, class = icon_class),
    tags$span(class = "visually-hidden", paste("Help:", title))
  )
}

#' Create a section help alert
#'
#' @param content Help content (text or HTML)
#' @param type Alert type: "info", "tip", "warning"
#' @param title Optional alert title
#' @param dismissible Whether alert can be dismissed (default: FALSE)
#' @param icon_name Optional FontAwesome icon
#'
#' @return HTML for help alert
#'
#' @examples
#' section_help("Upload an Excel file to get started", type = "info", title = "Getting Started")
section_help <- function(content, type = "info", title = NULL,
                        dismissible = FALSE, icon_name = NULL) {
  # Map type to Bootstrap alert class and default icon
  alert_map <- list(
    info = list(class = "alert-info", icon = "info-circle"),
    tip = list(class = "alert-success", icon = "lightbulb"),
    warning = list(class = "alert-warning", icon = "exclamation-triangle")
  )

  alert_config <- alert_map[[type]] %||% alert_map$info
  icon_to_use <- icon_name %||% alert_config$icon
  alert_class <- paste("alert", alert_config$class, if (dismissible) "alert-dismissible fade show")

  div(
    class = alert_class,
    role = "alert",
    if (dismissible) {
      tags$button(
        type = "button",
        class = "btn-close",
        `data-bs-dismiss` = "alert",
        `aria-label` = "Close"
      )
    },
    if (!is.null(title)) {
      h6(class = "alert-heading mb-2", icon(icon_to_use), " ", title)
    } else {
      tagList(icon(icon_to_use), " ")
    },
    content
  )
}

#' Create comprehensive help modal with tabbed interface
#'
#' @param id Modal ID
#' @param title Modal title (default: "Help & Documentation")
#' @param tabs List of tab content (list with name and content)
#'
#' @return HTML for help modal
#'
#' @examples
#' help_modal("main_help", tabs = list(
#'   "Getting Started" = "Upload data...",
#'   "Keyboard Shortcuts" = "Alt+G: Guided Workflow..."
#' ))
help_modal <- function(id = "help_modal",
                      title = "Help & Documentation",
                      tabs = NULL) {
  # Default tabs if none provided
  if (is.null(tabs)) {
    tabs <- list(
      "Getting Started" = tagList(
        h5("Welcome to Environmental Bowtie Risk Analysis"),
        p("This application helps you create and analyze environmental risk assessments using bowtie diagrams and Bayesian networks."),
        h6("Quick Start:"),
        tags$ol(
          tags$li("Upload your data or generate sample data in the ", strong("Data Upload"), " tab"),
          tags$li("Use the ", strong("Guided Workflow"), " to create a complete bowtie diagram"),
          tags$li("Visualize your bowtie in the ", strong("Bowtie Diagram"), " tab"),
          tags$li("Create a Bayesian network for probabilistic analysis"),
          tags$li("Export your results for further analysis")
        )
      ),
      "Keyboard Shortcuts" = tagList(
        h5("Keyboard Navigation"),
        tags$dl(
          tags$dt(tags$kbd("Alt"), " + ", tags$kbd("G")), tags$dd("Navigate to Guided Workflow tab"),
          tags$dt(tags$kbd("Alt"), " + ", tags$kbd("D")), tags$dd("Navigate to Data Upload tab"),
          tags$dt(tags$kbd("Alt"), " + ", tags$kbd("V")), tags$dd("Navigate to Visualization/Bowtie tab"),
          tags$dt(tags$kbd("Tab")), tags$dd("Move to next interactive element"),
          tags$dt(tags$kbd("Shift"), " + ", tags$kbd("Tab")), tags$dd("Move to previous interactive element"),
          tags$dt(tags$kbd("Escape")), tags$dd("Close open modals or dialogs"),
          tags$dt(tags$kbd("Enter")), tags$dd("Activate focused button or link")
        )
      ),
      "Accessibility" = tagList(
        h5("Accessibility Features"),
        p("This application is designed to be accessible to all users:"),
        tags$ul(
          tags$li(strong("Screen Reader Support:"), " All components have appropriate ARIA labels and announcements"),
          tags$li(strong("Keyboard Navigation:"), " Full keyboard support with visible focus indicators"),
          tags$li(strong("Skip Links:"), " Press Tab after page load to skip to main content"),
          tags$li(strong("High Contrast:"), " Works with high contrast modes and themes"),
          tags$li(strong("Text Scaling:"), " All text remains readable when zoomed up to 200%"),
          tags$li(strong("Form Validation:"), " Clear error messages with visual and text feedback")
        )
      ),
      "Data Format" = tagList(
        h5("Expected Data Format"),
        p("The application accepts Excel files (.xlsx, .xls) with the following structure:"),
        tags$ul(
          tags$li(strong("Activities:"), " Human activities causing environmental pressures"),
          tags$li(strong("Pressures:"), " Environmental stressors from activities"),
          tags$li(strong("Preventive Controls:"), " Measures to prevent pressures"),
          tags$li(strong("Consequences:"), " Environmental impacts from pressures"),
          tags$li(strong("Protective Controls:"), " Measures to mitigate consequences")
        ),
        p("You can also generate sample data to explore the application features.")
      ),
      "About" = tagList(
        h5("About This Application"),
        p(strong("Version:"), " 5.3.0 (Production-Ready Edition)"),
        p(strong("Framework:"), " R Shiny with Bootstrap 5"),
        p("This application enables environmental risk assessment using bowtie diagrams enhanced with probabilistic modeling through Bayesian networks."),
        hr(),
        p(class = "text-muted small", "For support or questions, refer to the documentation or contact your administrator.")
      )
    )
  }

  # Generate tab navigation
  tab_navs <- lapply(seq_along(tabs), function(i) {
    tab_name <- names(tabs)[i]
    tab_id <- paste0("help_tab_", gsub("[^a-zA-Z0-9]", "_", tolower(tab_name)))
    tags$li(
      class = "nav-item",
      role = "presentation",
      tags$button(
        class = paste("nav-link", if (i == 1) "active"),
        id = paste0(tab_id, "_tab"),
        `data-bs-toggle` = "tab",
        `data-bs-target` = paste0("#", tab_id),
        type = "button",
        role = "tab",
        `aria-controls` = tab_id,
        `aria-selected` = if (i == 1) "true" else "false",
        tab_name
      )
    )
  })

  # Generate tab content
  tab_contents <- lapply(seq_along(tabs), function(i) {
    tab_name <- names(tabs)[i]
    tab_id <- paste0("help_tab_", gsub("[^a-zA-Z0-9]", "_", tolower(tab_name)))
    div(
      class = paste("tab-pane fade", if (i == 1) "show active"),
      id = tab_id,
      role = "tabpanel",
      `aria-labelledby` = paste0(tab_id, "_tab"),
      tabindex = "0",
      div(class = "p-3", tabs[[i]])
    )
  })

  # Build modal
  bslib::modal_dialog(
    title = tagList(icon("circle-question"), " ", title),
    id = id,
    size = "lg",
    easyClose = TRUE,
    footer = tagList(
      actionButton(paste0(id, "_close"), "Close",
                  class = "btn-secondary",
                  `data-bs-dismiss` = "modal")
    ),
    tags$ul(class = "nav nav-tabs", role = "tablist", tab_navs),
    div(class = "tab-content border border-top-0 rounded-bottom", tab_contents)
  )
}

#' Initialize tooltips and popovers JavaScript
#'
#' @return HTML with JavaScript to initialize Bootstrap tooltips and popovers
#'
#' @examples
#' # Add to UI after other content
#' help_system_js()
help_system_js <- function() {
  tags$script(HTML("
    // Initialize Bootstrap tooltips
    document.addEventListener('DOMContentLoaded', function() {
      // Initialize all tooltips
      var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle=\"tooltip\"]'));
      var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl, {
          trigger: 'hover focus',
          delay: { show: 500, hide: 100 }
        });
      });

      // Initialize all popovers
      var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle=\"popover\"]'));
      var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl, {
          trigger: 'focus hover',
          html: true,
          delay: { show: 300, hide: 100 }
        });
      });

      // Reinitialize tooltips/popovers when Shiny updates content
      $(document).on('shiny:value', function(event) {
        setTimeout(function() {
          $('[data-bs-toggle=\"tooltip\"]').each(function() {
            new bootstrap.Tooltip(this, {
              trigger: 'hover focus',
              delay: { show: 500, hide: 100 }
            });
          });

          $('[data-bs-toggle=\"popover\"]').each(function() {
            new bootstrap.Popover(this, {
              trigger: 'focus hover',
              html: true,
              delay: { show: 300, hide: 100 }
            });
          });
        }, 100);
      });
    });
  "))
}

# Helper operator for default values
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
