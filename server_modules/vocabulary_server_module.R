# =============================================================================
# Server Module - Vocabulary Management
# =============================================================================
# Purpose: Handles all vocabulary search, filtering, display, and management
# Dependencies: vocabulary.R (vocabulary_data, search_vocabulary, etc.), DT
# =============================================================================

#' Initialize vocabulary management server module
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param vocabulary_data The global vocabulary data list
#' @return NULL (module defines outputs and observers directly)
init_vocabulary_server_module <- function(input, output, session, vocabulary_data) {

  # ===========================================================================
  # REACTIVE VALUES
  # ===========================================================================

  vocab_search_results <- reactiveVal(data.frame())
  selected_vocab_item <- reactiveVal(NULL)

  # ===========================================================================
  # VOCABULARY TAB - CORE REACTIVES
  # ===========================================================================

  # Get current vocabulary based on selection
  current_vocabulary <- reactive({
    req(input$vocab_type)
    if (exists("vocabulary_data") && !is.null(vocabulary_data[[input$vocab_type]])) {
      vocabulary_data[[input$vocab_type]]
    } else {
      data.frame()
    }
  })

  # Update level filter based on selected vocabulary
  output$vocab_level_filter <- renderUI({
    vocab <- current_vocabulary()
    if (nrow(vocab) > 0) {
      levels <- sort(unique(vocab$level))
      checkboxGroupInput("vocab_levels", "Show levels:",
                         choices = levels,
                         selected = levels)
    } else {
      p(class = "text-muted", "No levels available")
    }
  })

  # Filtered vocabulary based on level selection
  filtered_vocabulary <- reactive({
    vocab <- current_vocabulary()
    if (!is.null(input$vocab_levels) && length(input$vocab_levels) > 0) {
      vocab %>% filter(level %in% input$vocab_levels)
    } else {
      vocab
    }
  })

  # ===========================================================================
  # VOCABULARY TREE AND TABLE
  # ===========================================================================

  # Vocabulary tree view
  output$vocab_tree <- renderPrint({
    vocab <- filtered_vocabulary()
    if (nrow(vocab) > 0) {
      tree <- create_tree_structure(vocab)
      cat(paste(tree$display, collapse = "\n"))
    } else {
      cat("No vocabulary data available.\nPlease ensure CAUSES.xlsx, CONSEQUENCES.xlsx, and CONTROLS.xlsx files are in the app directory.")
    }
  })

  # Vocabulary data table
  output$vocab_table <- DT::renderDataTable({
    vocab <- filtered_vocabulary()
    if (nrow(vocab) > 0) {
      DT::datatable(
        vocab %>% select(level, id, name),
        options = list(
          pageLength = 15,
          searching = TRUE,
          ordering = TRUE,
          columnDefs = list(
            list(width = '10%', targets = 0),
            list(width = '15%', targets = 1),
            list(width = '75%', targets = 2)
          )
        ),
        selection = 'single',
        rownames = FALSE
      )
    }
  })

  # Track selected item from table
  observeEvent(input$vocab_table_rows_selected, {
    row <- input$vocab_table_rows_selected
    if (!is.null(row)) {
      vocab <- filtered_vocabulary()
      if (row <= nrow(vocab)) {
        selected_vocab_item(vocab[row, ])
      }
    }
  })

  # Display selected item info
  output$selected_item_info <- renderUI({
    item <- selected_vocab_item()
    if (!is.null(item)) {
      vocab <- current_vocabulary()
      children <- get_children(vocab, item$id)
      path <- get_item_path(vocab, item$id)

      tagList(
        tags$strong("ID:"), tags$br(),
        tags$code(item$id), tags$br(), tags$br(),

        tags$strong("Name:"), tags$br(),
        tags$small(item$name), tags$br(), tags$br(),

        tags$strong("Level:"), " ", item$level, tags$br(), tags$br(),

        if (nrow(path) > 1) {
          tagList(
            tags$strong("Path:"), tags$br(),
            tags$small(paste(path$name, collapse = " -> ")), tags$br(), tags$br()
          )
        },

        if (nrow(children) > 0) {
          tagList(
            tags$strong("Children (", nrow(children), "):")
          )
        }
      )
    } else {
      p(class = "text-muted small", "Select an item to view details")
    }
  })

  # ===========================================================================
  # VOCABULARY SEARCH
  # ===========================================================================

  # Search vocabulary
  observeEvent(input$search_vocab, {
    req(input$vocab_search, input$search_in)
    vocab <- current_vocabulary()
    if (nrow(vocab) > 0 && nchar(input$vocab_search) > 0) {
      results <- search_vocabulary(vocab, input$vocab_search, input$search_in)
      vocab_search_results(results)
    }
  })

  # Search results table
  output$vocab_search_results <- DT::renderDataTable({
    results <- vocab_search_results()
    if (nrow(results) > 0) {
      DT::datatable(
        results %>% select(level, id, name),
        options = list(
          pageLength = 10,
          searching = FALSE
        ),
        rownames = FALSE
      )
    }
  })

  output$hasSearchResults <- reactive({
    nrow(vocab_search_results()) > 0
  })
  outputOptions(output, "hasSearchResults", suspendWhenHidden = FALSE)

  # ===========================================================================
  # VOCABULARY STATISTICS AND RELATIONSHIPS
  # ===========================================================================

  # Vocabulary statistics
  output$vocab_stats <- renderTable({
    vocab <- current_vocabulary()
    if (nrow(vocab) > 0) {
      stats <- vocab %>%
        group_by(level) %>%
        summarise(Count = n(), .groups = 'drop') %>%
        mutate(Percent = paste0(round(Count / sum(Count) * 100, 1), "%"))

      rbind(stats,
            data.frame(level = "Total",
                      Count = sum(stats$Count),
                      Percent = "100%"))
    }
  }, striped = TRUE, hover = TRUE, width = "100%")

  # Vocabulary relationships
  output$vocab_relationships <- renderUI({
    item <- selected_vocab_item()
    if (!is.null(item)) {
      vocab <- current_vocabulary()
      children <- get_children(vocab, item$id)

      if (nrow(children) > 0) {
        tagList(
          h5(tagList(icon("sitemap"), " Children of ", tags$code(item$id))),
          tags$ul(
            lapply(seq_len(nrow(children)), function(i) {
              tags$li(
                tags$strong(children$id[i]), " - ",
                children$name[i],
                tags$span(class = "badge bg-secondary ms-2",
                         paste("Level", children$level[i]))
              )
            })
          )
        )
      } else {
        p(class = "text-muted", "This item has no children")
      }
    }
  })

  # Vocabulary info summary
  output$vocab_info <- renderUI({
    if (exists("vocabulary_data") && !is.null(vocabulary_data)) {
      total_items <- sum(sapply(vocabulary_data[c("activities", "pressures", "consequences", "controls")],
                               function(x) if (!is.null(x)) nrow(x) else 0))

      tagList(
        div(class = "row",
            div(class = "col-md-3",
                div(class = "text-center",
                    icon("play", class = "fa-2x text-primary mb-2"),
                    h5("Activities"),
                    p(class = "display-6", nrow(vocabulary_data$activities))
                )
            ),
            div(class = "col-md-3",
                div(class = "text-center",
                    icon("triangle-exclamation", class = "fa-2x text-danger mb-2"),
                    h5("Pressures"),
                    p(class = "display-6", nrow(vocabulary_data$pressures))
                )
            ),
            div(class = "col-md-3",
                div(class = "text-center",
                    icon("burst", class = "fa-2x text-warning mb-2"),
                    h5("Consequences"),
                    p(class = "display-6", nrow(vocabulary_data$consequences))
                )
            ),
            div(class = "col-md-3",
                div(class = "text-center",
                    icon("shield", class = "fa-2x text-success mb-2"),
                    h5("Controls"),
                    p(class = "display-6", nrow(vocabulary_data$controls))
                )
            )
        ),
        hr(),
        p(class = "text-center text-muted",
          strong("Total vocabulary items: "), total_items,
          " | Data source: CAUSES.xlsx, CONSEQUENCES.xlsx, CONTROLS.xlsx")
      )
    } else {
      div(class = "alert alert-warning",
          tagList(icon("exclamation-triangle"), " "),
          "Vocabulary data not loaded. Please ensure the Excel files are in the app directory.")
    }
  })

  # ===========================================================================
  # VOCABULARY DOWNLOAD AND REFRESH
  # ===========================================================================

  # Download vocabulary
  output$download_vocab <- downloadHandler(
    filename = function() {
      req(input$vocab_type)
      paste0("vocabulary_", input$vocab_type, "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      vocab <- current_vocabulary()
      if (nrow(vocab) > 0) {
        tree_data <- create_tree_structure(vocab)
        export_data <- tree_data %>% select(level, id, name, path)
        openxlsx::write.xlsx(export_data, file, rowNames = FALSE)
      }
    }
  )

  # Refresh vocabulary
  observeEvent(input$refresh_vocab, {
    notify_info("Refreshing vocabulary data...", duration = 2)
    tryCatch({
      vocabulary_data <<- load_vocabulary()
      vocab_search_results(data.frame())
      selected_vocab_item(NULL)
      notify_success("Vocabulary refreshed successfully!", duration = 3)
    }, error = function(e) {
      notify_error(paste("Error refreshing vocabulary:", e$message))
    })
  })

  # ===========================================================================
  # VOCABULARY TAB - SECONDARY OUTPUTS
  # ===========================================================================

  # Vocabulary count box outputs for vocabulary tab
  output$vocab_activities_count_box <- renderText({
    if (exists("vocabulary_data") && !is.null(vocabulary_data$activities)) {
      nrow(vocabulary_data$activities)
    } else {
      "0"
    }
  })

  output$vocab_pressures_count_box <- renderText({
    if (exists("vocabulary_data") && !is.null(vocabulary_data$pressures)) {
      nrow(vocabulary_data$pressures)
    } else {
      "0"
    }
  })

  output$vocab_controls_count_box <- renderText({
    if (exists("vocabulary_data") && !is.null(vocabulary_data$controls)) {
      nrow(vocabulary_data$controls)
    } else {
      "0"
    }
  })

  output$vocab_consequences_count_box <- renderText({
    if (exists("vocabulary_data") && !is.null(vocabulary_data$consequences)) {
      nrow(vocabulary_data$consequences)
    } else {
      "0"
    }
  })

  # Reactive filtered vocabulary data (for vocabulary tab with category filter)
  vocab_filtered <- reactive({
    req(input$vocab_category)
    # Start with all vocabulary data
    all_vocab <- data.frame()

    if (!exists("vocabulary_data")) {
      return(all_vocab)
    }

    # Combine all vocabulary types based on selected category
    category <- input$vocab_category
    search_term <- tolower(trimws(input$vocab_search %||% ""))

    if (is.null(category)) category <- "all"

    # Build combined dataset
    if (category == "all" || category == "activities") {
      if (!is.null(vocabulary_data$activities) && nrow(vocabulary_data$activities) > 0) {
        activities <- vocabulary_data$activities %>%
          mutate(category = "Activity") %>%
          select(category, id, name, hierarchy)
        all_vocab <- bind_rows(all_vocab, activities)
      }
    }

    if (category == "all" || category == "pressures") {
      if (!is.null(vocabulary_data$pressures) && nrow(vocabulary_data$pressures) > 0) {
        pressures <- vocabulary_data$pressures %>%
          mutate(category = "Pressure") %>%
          select(category, id, name, hierarchy)
        all_vocab <- bind_rows(all_vocab, pressures)
      }
    }

    if (category == "all" || category == "controls") {
      if (!is.null(vocabulary_data$controls) && nrow(vocabulary_data$controls) > 0) {
        controls <- vocabulary_data$controls %>%
          mutate(category = "Control") %>%
          select(category, id, name, hierarchy)
        all_vocab <- bind_rows(all_vocab, controls)
      }
    }

    if (category == "all" || category == "consequences") {
      if (!is.null(vocabulary_data$consequences) && nrow(vocabulary_data$consequences) > 0) {
        consequences <- vocabulary_data$consequences %>%
          mutate(category = "Consequence") %>%
          select(category, id, name, hierarchy)
        all_vocab <- bind_rows(all_vocab, consequences)
      }
    }

    # Apply search filter if provided
    if (nchar(search_term) > 0 && nrow(all_vocab) > 0) {
      all_vocab <- all_vocab %>%
        filter(grepl(search_term, tolower(name)) | grepl(search_term, tolower(id)))
    }

    return(all_vocab)
  })

  # Render vocabulary table (vocabulary tab)
  output$vocabularyTable <- DT::renderDataTable({
    data <- vocab_filtered()

    if (nrow(data) == 0) {
      # Return empty table with message
      return(datatable(
        data.frame(Message = "No vocabulary items found. Try adjusting your search or category filter."),
        options = list(dom = 't', ordering = FALSE),
        rownames = FALSE
      ))
    }

    # Render the filtered data
    datatable(
      data,
      options = list(
        pageLength = 25,
        lengthMenu = c(10, 25, 50, 100),
        order = list(list(0, 'asc'), list(1, 'asc')),
        searchHighlight = TRUE,
        dom = 'Blfrtip',
        buttons = c('copy', 'csv', 'excel')
      ),
      rownames = FALSE,
      colnames = c('Category', 'ID', 'Name', 'Hierarchy'),
      filter = 'top',
      selection = 'none'
    ) %>%
      formatStyle(
        'category',
        backgroundColor = styleEqual(
          c('Activity', 'Pressure', 'Control', 'Consequence'),
          c('#e3f2fd', '#ffebee', '#e8f5e9', '#fff3e0')
        )
      )
  })

  # ===========================================================================
  # VOCABULARY STATISTICS OUTPUTS (Dashboard & Sidebar)
  # ===========================================================================

  output$vocab_activities_count <- renderText({
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities)) {
      return(as.character(nrow(vocabulary_data$activities)))
    }
    return("0")
  })

  output$vocab_pressures_count <- renderText({
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures)) {
      return(as.character(nrow(vocabulary_data$pressures)))
    }
    return("0")
  })

  output$vocab_controls_count <- renderText({
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls)) {
      return(as.character(nrow(vocabulary_data$controls)))
    }
    return("0")
  })

  output$vocab_consequences_count <- renderText({
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$consequences)) {
      return(as.character(nrow(vocabulary_data$consequences)))
    }
    return("0")
  })

  output$vocab_total_count <- renderText({
    total <- 0
    if (!is.null(vocabulary_data)) {
      if (!is.null(vocabulary_data$activities)) total <- total + nrow(vocabulary_data$activities)
      if (!is.null(vocabulary_data$pressures)) total <- total + nrow(vocabulary_data$pressures)
      if (!is.null(vocabulary_data$controls)) total <- total + nrow(vocabulary_data$controls)
      if (!is.null(vocabulary_data$consequences)) total <- total + nrow(vocabulary_data$consequences)
    }
    return(as.character(total))
  })

  # Sidebar badge for vocabulary
  output$badge_vocabulary <- renderText({
    total <- 0
    if (!is.null(vocabulary_data)) {
      if (!is.null(vocabulary_data$activities)) total <- total + nrow(vocabulary_data$activities)
      if (!is.null(vocabulary_data$pressures)) total <- total + nrow(vocabulary_data$pressures)
      if (!is.null(vocabulary_data$controls)) total <- total + nrow(vocabulary_data$controls)
      if (!is.null(vocabulary_data$consequences)) total <- total + nrow(vocabulary_data$consequences)
    }
    if (total > 0) {
      return(as.character(total))
    }
    return("")
  })

  # ===========================================================================
  # DASHBOARD VOCABULARY INFOBOXES
  # ===========================================================================

  output$vocab_activities_infobox <- renderUI({
    count <- 0
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$activities)) {
      count <- nrow(vocabulary_data$activities)
    }

    bs4InfoBox(
      title = "Activities",
      value = count,
      subtitle = "From environmental vocabulary database",
      icon = icon("play"),
      iconElevation = 2,
      color = "info",
      gradient = TRUE,
      width = 12,
      fill = TRUE
    )
  })

  output$vocab_pressures_infobox <- renderUI({
    count <- 0
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$pressures)) {
      count <- nrow(vocabulary_data$pressures)
    }

    bs4InfoBox(
      title = "Pressures",
      value = count,
      subtitle = "Environmental stressor categories",
      icon = icon("triangle-exclamation"),
      iconElevation = 2,
      color = "danger",
      gradient = TRUE,
      width = 12,
      fill = TRUE
    )
  })

  output$vocab_controls_infobox <- renderUI({
    count <- 0
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$controls)) {
      count <- nrow(vocabulary_data$controls)
    }

    bs4InfoBox(
      title = "Controls",
      value = count,
      subtitle = "Mitigation & protective measures",
      icon = icon("shield-halved"),
      iconElevation = 2,
      color = "success",
      gradient = TRUE,
      width = 12,
      fill = TRUE
    )
  })

  output$vocab_consequences_infobox <- renderUI({
    count <- 0
    if (!is.null(vocabulary_data) && !is.null(vocabulary_data$consequences)) {
      count <- nrow(vocabulary_data$consequences)
    }

    bs4InfoBox(
      title = "Consequences",
      value = count,
      subtitle = "Environmental impact categories",
      icon = icon("burst"),
      iconElevation = 2,
      color = "warning",
      gradient = TRUE,
      width = 12,
      fill = TRUE
    )
  })

  # ===========================================================================
  # VOCABULARY DROPDOWN MENU HANDLERS
  # ===========================================================================

  observeEvent(input$refresh_vocabulary_menu, {
    # Trigger reactive update
    updateTextInput(session, "vocab_search", value = input$vocab_search)
    notify_info("Vocabulary data refreshed!", duration = 3)
  })

  observeEvent(input$export_vocabulary_menu, {
    session$sendCustomMessage("triggerDownload", "download_vocab")
  })

  observeEvent(input$clear_vocab_filters_menu, {
    updateTextInput(session, "vocab_search", value = "")
    updateSelectInput(session, "vocab_category", selected = "all")
    notify_info("Filters cleared!", duration = 3)
  })

  observeEvent(input$vocab_stats_menu, {
    total <- 0
    if (!is.null(vocabulary_data)) {
      if (!is.null(vocabulary_data$activities)) total <- total + nrow(vocabulary_data$activities)
      if (!is.null(vocabulary_data$pressures)) total <- total + nrow(vocabulary_data$pressures)
      if (!is.null(vocabulary_data$controls)) total <- total + nrow(vocabulary_data$controls)
      if (!is.null(vocabulary_data$consequences)) total <- total + nrow(vocabulary_data$consequences)
    }
    notify_info(paste("Vocabulary Statistics: Total Elements:", total), duration = 5)
  })

  bowtie_log("Vocabulary management module initialized", level = "info")
}
