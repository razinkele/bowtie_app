# =============================================================================
# Login Module for Environmental Bowtie Risk Analysis Application
# Version: 1.1.0
# Description: User authentication with Default (auto-login) and Admin roles
# =============================================================================

# =============================================================================
# USER CREDENTIALS
# =============================================================================

# User database (in production, use secure storage)
USER_CREDENTIALS <- list(
  default = list(
    username = "default",
    password = NULL,  # No password required
    role = "default",
    display_name = "Default User"
  ),
  admin = list(
    username = "admin",
    password = "admin",  # In production, use hashed passwords
    role = "admin",
    display_name = "Administrator"
  )
)

# =============================================================================
# LOGIN UI MODULE
# =============================================================================

#' Login UI Module
#' @param id Module namespace ID
login_ui <- function(id) {
  ns <- NS(id)

  # Admin Login Modal (only shown when "Login as Admin" is clicked)
  tagList(
    # Admin Login Modal
    div(
      id = ns("admin_login_modal"),
      class = "modal fade",
      tabindex = "-1",
      role = "dialog",
      `aria-labelledby` = ns("admin_login_modal_label"),
      `aria-hidden` = "true",

      div(
        class = "modal-dialog modal-dialog-centered modal-sm",
        role = "document",

        div(
          class = "modal-content",
          style = "border-radius: 12px; overflow: hidden;",

          # Modal Header
          div(
            class = "modal-header bg-danger text-white py-3",
            style = "border-bottom: none;",
            h5(
              class = "modal-title w-100 text-center mb-0",
              id = ns("admin_login_modal_label"),
              icon("user-shield", class = "me-2"),
              "Admin Login"
            ),
            tags$button(
              type = "button",
              class = "btn-close btn-close-white",
              `data-bs-dismiss` = "modal",
              `aria-label` = "Close",
              style = "position: absolute; right: 15px; top: 15px;"
            )
          ),

          # Modal Body
          div(
            class = "modal-body p-4",

            # Password field
            div(
              class = "mb-3",
              tags$label(
                `for` = ns("admin_password"),
                class = "form-label fw-bold",
                icon("lock", class = "me-1"),
                "Password"
              ),
              passwordInput(
                ns("admin_password"),
                label = NULL,
                placeholder = "Enter admin password",
                width = "100%"
              ),
              div(
                id = ns("password_error"),
                class = "text-danger small mt-2",
                style = "display: none;",
                icon("exclamation-circle"),
                " Incorrect password"
              )
            ),

            # Login Button
            div(
              class = "d-grid mt-4",
              actionButton(
                ns("admin_login_btn"),
                label = tagList(icon("sign-in-alt"), " Login as Admin"),
                class = "btn btn-danger btn-lg"
              )
            )
          )
        )
      )
    ),

    # JavaScript for handling modal and password
    tags$script(HTML(sprintf("
      // Handle Enter key press in password field
      $(document).on('keypress', '#%s', function(e) {
        if (e.which == 13) {
          e.preventDefault();
          $('#%s').click();
        }
      });

      // Clear error and password when modal is hidden
      $('#%s').on('hidden.bs.modal', function() {
        $('#%s').val('');
        $('#%s').hide();
        $('#%s').removeClass('is-invalid');
      });

      // Clear error when user starts typing
      $(document).on('input', '#%s', function() {
        $('#%s').hide();
        $(this).removeClass('is-invalid');
      });
    ",
    ns("admin_password"), ns("admin_login_btn"),
    ns("admin_login_modal"), ns("admin_password"), ns("password_error"), ns("admin_password"),
    ns("admin_password"), ns("password_error")
    )))
  )
}

# =============================================================================
# LOGIN SERVER MODULE
# =============================================================================

#' Login Server Module
#' @param id Module namespace ID
#' @return Reactive values containing user info and login status
login_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Reactive values for user state - AUTO-LOGIN as default user
    user <- reactiveValues(
      logged_in = TRUE,
      username = "default",
      role = "default",
      display_name = "Default User",
      login_time = Sys.time()
    )

    # Handle admin login button click
    observeEvent(input$admin_login_btn, {
      password <- input$admin_password

      if (!is.null(password) && password == USER_CREDENTIALS$admin$password) {
        # Correct password - switch to admin
        user$logged_in <- TRUE
        user$username <- "admin"
        user$role <- "admin"
        user$display_name <- "Administrator"
        user$login_time <- Sys.time()

        # Close modal
        shinyjs::runjs(sprintf("$('#%s').modal('hide');", ns("admin_login_modal")))

        # Clear password field
        updateTextInput(session, "admin_password", value = "")

        # Show welcome notification
        showNotification(
          tagList(icon("user-shield"), " Logged in as Administrator"),
          type = "message",
          duration = 3
        )
      } else {
        # Incorrect password
        shinyjs::runjs(sprintf("$('#%s').show();", ns("password_error")))
        shinyjs::runjs(sprintf("$('#%s').addClass('is-invalid');", ns("admin_password")))
      }
    })

    # Return user reactive values
    return(user)
  })
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

#' Check if user has admin role
#' @param user Reactive user object from login_server
#' @return Logical TRUE if user is admin
is_admin <- function(user) {
  if (is.null(user$role)) return(FALSE)
  return(user$role == "admin")
}

#' Get user display name
#' @param user Reactive user object from login_server
#' @return Character string with user display name
get_user_display_name <- function(user) {
  if (is.null(user$display_name)) return("Guest")
  return(user$display_name)
}

# =============================================================================
# CSS STYLES FOR LOGIN
# =============================================================================

login_css <- function() {
  tags$style(HTML("
    /* Admin Login Modal Styles */
    #login-admin_login_modal .modal-content {
      box-shadow: 0 10px 40px rgba(0,0,0,0.3);
    }

    #login-admin_login_modal .modal-header.bg-danger {
      background: linear-gradient(135deg, #dc3545 0%, #c82333 100%) !important;
    }

    /* Password input styling */
    #login-admin_password {
      border-radius: 8px;
      padding: 12px 15px;
      border: 2px solid #e9ecef;
      transition: all 0.2s ease;
    }

    #login-admin_password:focus {
      border-color: #dc3545;
      box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
    }

    #login-admin_password.is-invalid {
      border-color: #dc3545;
      background-color: #fff5f5;
    }

    /* Login button styling */
    #login-admin_login_btn {
      border-radius: 8px;
      padding: 12px;
      font-weight: 500;
      transition: all 0.3s ease;
    }

    #login-admin_login_btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(220, 53, 69, 0.4);
    }

    /* User role badge styles */
    .user-role-badge {
      display: inline-flex;
      align-items: center;
      padding: 4px 10px;
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 500;
    }

    .user-role-badge.admin {
      background-color: #dc3545;
      color: white;
    }

    .user-role-badge.default {
      background-color: #6c757d;
      color: white;
    }
  "))
}

cat("Login module loaded successfully (auto-login as default user)\n")
