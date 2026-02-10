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
#'   primary_action = actionButton("upload", "Upload", class = "btn-primary")
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
#'
#' @param message Message text to display
#' @param action_buttons Optional action buttons div (for backward compatibility)
#' @param primary_action Primary action button (optional)
#' @param secondary_action Secondary action button (optional)
empty_state_table <- function(
  message = "No data available. Upload a file or generate sample.",
  action_buttons = NULL,
  primary_action = NULL,
  secondary_action = NULL
) {
  # Handle backward compatibility
  if (!is.null(action_buttons) && inherits(action_buttons, "shiny.tag")) {
    return(
      div(
        class = "empty-state text-center p-5",
        icon("table", class = "empty-state-icon fa-4x text-muted mb-3"),
        h4("No Data to Display", class = "text-muted mb-2"),
        p(message, class = "text-muted mb-4"),
        action_buttons
      )
    )
  }

  # Standard behavior with primary/secondary actions
  empty_state(
    icon_name = "table",
    title = "No Data to Display",
    message = message,
    primary_action = primary_action,
    secondary_action = secondary_action
  )
}

#' Empty state for network visualization
#'
#' @param icon_name FontAwesome icon name (default: "diagram-project")
#' @param message Message text to display
#' @param action_buttons Optional action buttons div (for backward compatibility)
#' @param primary_action Primary action button (optional)
#' @param secondary_action Secondary action button (optional)
empty_state_network <- function(
  icon_name = "diagram-project",
  message = "No network to display. Load data to visualize diagram.",
  action_buttons = NULL,
  primary_action = NULL,
  secondary_action = NULL
) {
  # Handle backward compatibility
  if (!is.null(action_buttons) && inherits(action_buttons, "shiny.tag")) {
    return(
      div(
        class = "empty-state text-center p-5",
        icon(icon_name, class = "empty-state-icon fa-4x text-muted mb-3"),
        h4("No Network Diagram", class = "text-muted mb-2"),
        p(message, class = "text-muted mb-4"),
        action_buttons
      )
    )
  }

  # Standard behavior with primary/secondary actions
  empty_state(
    icon_name = icon_name,
    title = "No Network Diagram",
    message = message,
    primary_action = primary_action,
    secondary_action = secondary_action
  )
}

#' Empty state for search results
#'
#' @param query Search query (optional)
#' @param message Custom message (optional, overrides default)
empty_state_search <- function(query = NULL, message = NULL) {
  # Use custom message if provided, otherwise generate based on query
  msg <- if (!is.null(message)) {
    message
  } else if (!is.null(query) && nchar(query) > 0) {
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

    // Initialize Bootstrap tooltips
    $('[data-toggle=\"tooltip\"]').tooltip({
      trigger: 'hover',
      delay: { show: 500, hide: 100 }
    });

    // Re-initialize tooltips after Shiny updates
    $(document).on('shiny:value', function() {
      $('[data-toggle=\"tooltip\"]').tooltip({
        trigger: 'hover',
        delay: { show: 500, hide: 100 }
      });
    });

    // Sidebar Search Functionality
    $('#sidebar_search').on('input', function() {
      var searchTerm = $(this).val().toLowerCase().trim();

      if (searchTerm === '') {
        // Show all menu items and headers
        $('.nav-sidebar .nav-item').show();
        $('.nav-sidebar .nav-header').show();
        $('.nav-sidebar .nav-treeview').show();
        return;
      }

      // Hide all items initially
      $('.nav-sidebar .nav-item').each(function() {
        var $item = $(this);
        var itemText = $item.find('.nav-link p').first().text().toLowerCase();
        var $subItems = $item.find('.nav-treeview .nav-item');

        // Check if main item matches
        var mainMatch = itemText.indexOf(searchTerm) > -1;

        // Check if any sub-items match
        var subMatch = false;
        $subItems.each(function() {
          var subText = $(this).text().toLowerCase();
          if (subText.indexOf(searchTerm) > -1) {
            subMatch = true;
            $(this).show();
          } else {
            $(this).hide();
          }
        });

        // Show item if main or sub matches
        if (mainMatch || subMatch) {
          $item.show();
          if (subMatch) {
            $item.addClass('menu-open');
            $item.find('.nav-treeview').show();
          }
        } else {
          $item.hide();
        }
      });

      // Hide/show headers based on visible items in section
      $('.nav-sidebar .nav-header').each(function() {
        var $header = $(this);
        var $nextItems = $header.nextUntil('.nav-header', '.nav-item');
        var hasVisibleItems = $nextItems.filter(':visible').length > 0;

        if (hasVisibleItems) {
          $header.show();
        } else {
          $header.hide();
        }
      });
    });

    // Clear search on Escape
    $(document).on('keydown', '#sidebar_search', function(e) {
      if (e.key === 'Escape') {
        $(this).val('').trigger('input');
      }
    });

    // Custom message handlers for network visualization actions
    Shiny.addCustomMessageHandler('fitBowtieNetwork', function(message) {
      if (typeof bowtieNetworkInstance !== 'undefined') {
        bowtieNetworkInstance.fit({animation: {duration: 500, easingFunction: 'easeInOutQuad'}});
      }
    });

    Shiny.addCustomMessageHandler('fitBayesianNetwork', function(message) {
      if (typeof bayesianNetworkInstance !== 'undefined') {
        bayesianNetworkInstance.fit({animation: {duration: 500, easingFunction: 'easeInOutQuad'}});
      }
    });

    // Trigger a download button click programmatically
    Shiny.addCustomMessageHandler('triggerDownload', function(downloadId) {
      var link = document.getElementById(downloadId);
      if (link) link.click();
    });

    // Store network instances when created (for fit functionality)
    $(document).on('shiny:value', function(event) {
      if (event.name === 'bowtieNetwork' && event.binding && event.binding.instance) {
        window.bowtieNetworkInstance = event.binding.instance;
      }
      if (event.name === 'bayesianNetworkVis' && event.binding && event.binding.instance) {
        window.bayesianNetworkInstance = event.binding.instance;
      }
    });

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

# Helper operator for default values
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
