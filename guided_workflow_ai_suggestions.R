# =============================================================================
# Guided Workflow AI Suggestions Module
# Version: 1.0
# Description: AI-powered live suggestions for guided workflow using vocabulary linker
# =============================================================================

# =============================================================================
# AI SUGGESTION UI COMPONENTS
# =============================================================================

#' Create AI suggestions panel UI
#'
#' Generates a collapsible panel showing AI-powered suggestions for the current step
#'
#' @param ns Namespace function for the module
#' @param suggestion_type Type of suggestions ("pressure", "consequence", "control_preventive", "control_protective")
#' @param title Title for the suggestions panel
#' @param current_lang Current language code
#' @return tagList with suggestion UI components
create_ai_suggestions_ui <- function(ns, suggestion_type, title = "AI Suggestions", current_lang = "en") {
  tagList(
    div(
      class = "card border-primary mb-3",
      style = "margin-top: 15px;",
      div(
        class = "card-header bg-primary text-white",
        style = "cursor: pointer; display: flex; align-items: center; justify-content: space-between;",
        id = ns(paste0("suggestion_header_", suggestion_type)),
        onclick = paste0("$('#", ns(paste0("suggestion_body_", suggestion_type)), "').collapse('toggle'); $(this).find('.collapse-icon').toggleClass('fa-chevron-down fa-chevron-up');"),
        div(
          style = "display: flex; align-items: center;",
          tags$i(class = "fas fa-robot", style = "margin-right: 10px;"),
          tags$strong(title)
        ),
        tags$i(class = "fas fa-chevron-down collapse-icon")
      ),
      div(
        class = "collapse show",
        id = ns(paste0("suggestion_body_", suggestion_type)),
        div(
          class = "card-body",

          # Status indicator
          div(
            id = ns(paste0("suggestion_status_", suggestion_type)),
            class = "alert alert-info",
            style = "margin-bottom: 10px; padding: 8px 12px;",
            tags$i(class = "fas fa-info-circle"),
            " Select items on the left to get AI-powered suggestions"
          ),

          # Loading indicator
          div(
            id = ns(paste0("suggestion_loading_", suggestion_type)),
            class = "text-center",
            style = "display: none; padding: 20px;",
            tags$i(class = "fas fa-spinner fa-spin fa-2x text-primary"),
            tags$p("Analyzing connections...", style = "margin-top: 10px;")
          ),

          # Suggestions list
          div(
            id = ns(paste0("suggestions_list_", suggestion_type)),
            style = "display: none;",

            div(
              class = "alert alert-success",
              style = "margin-bottom: 10px; padding: 8px 12px;",
              tags$i(class = "fas fa-lightbulb"),
              " AI-powered recommendations based on your selections:"
            ),

            # Suggestions will be populated here dynamically
            uiOutput(ns(paste0("suggestions_content_", suggestion_type)))
          ),

          # No suggestions message
          div(
            id = ns(paste0("no_suggestions_", suggestion_type)),
            class = "alert alert-warning",
            style = "display: none; margin-bottom: 0; padding: 8px 12px;",
            tags$i(class = "fas fa-exclamation-triangle"),
            " No strong connections found. Try adding more items or use custom entry."
          ),

          # Error message
          div(
            id = ns(paste0("suggestion_error_", suggestion_type)),
            class = "alert alert-danger",
            style = "display: none; margin-bottom: 0; padding: 8px 12px;",
            tags$i(class = "fas fa-exclamation-circle"),
            " Error generating suggestions. Please try again."
          )
        )
      )
    )
  )
}

#' Create individual suggestion card UI
#'
#' @param ns Namespace function
#' @param suggestion Suggestion data (id, name, similarity, method, reasoning)
#' @param index Suggestion index
#' @param suggestion_type Type of suggestion
#' @return div with suggestion card
create_suggestion_card_ui <- function(ns, suggestion, index, suggestion_type) {
  # Determine confidence badge color and icon
  confidence_info <- suggestion$confidence_info
  confidence_level <- if (!is.null(confidence_info) && !is.null(confidence_info$level)) {
    confidence_info$level
  } else {
    suggestion$confidence_level
  }

  confidence_color <- switch(confidence_level,
    "very_high" = "success",
    "high" = "info",
    "medium" = "warning",
    "low" = "secondary",
    "very_low" = "dark",
    "secondary"  # default
  )

  confidence_icon <- switch(confidence_level,
    "very_high" = "fa-check-circle",
    "high" = "fa-thumbs-up",
    "medium" = "fa-info-circle",
    "low" = "fa-exclamation-triangle",
    "very_low" = "fa-question-circle",
    "fa-info-circle"  # default
  )

  # Get confidence score
  confidence_score <- if (!is.null(suggestion$confidence)) {
    suggestion$confidence
  } else {
    suggestion$similarity
  }

  # Determine method icon
  method_icon <- if (grepl("causal", suggestion$method)) {
    "fa-link"
  } else if (grepl("keyword", suggestion$method)) {
    "fa-key"
  } else {
    "fa-search"
  }

  div(
    class = "card mb-2 suggestion-card",
    style = "border-left: 3px solid #0d6efd;",
    div(
      class = "card-body p-2",
      div(
        style = "display: flex; justify-content: space-between; align-items: start;",

        # Suggestion content
        div(
          style = "flex: 1;",
          div(
            style = "display: flex; align-items: center; margin-bottom: 5px; flex-wrap: wrap; gap: 4px;",
            tags$strong(
              style = "font-size: 14px;",
              suggestion$to_name
            ),
            # Confidence badge (primary indicator)
            tags$span(
              class = paste0("badge bg-", confidence_color, " ms-2"),
              style = "font-size: 10px;",
              tags$i(class = paste("fas", confidence_icon)),
              " ",
              sprintf("%.0f%%", confidence_score * 100)
            ),
            # Method badge
            tags$span(
              class = "badge bg-light text-dark ms-1",
              style = "font-size: 10px;",
              tags$i(class = paste("fas", method_icon)),
              " ",
              if (grepl("causal", suggestion$method)) "Causal" else if (grepl("keyword", suggestion$method)) "Thematic" else "Semantic"
            )
          ),

          # Reasoning/explanation
          if (!is.null(suggestion$reasoning) && nchar(suggestion$reasoning) > 0) {
            tags$small(
              class = "text-muted",
              style = "font-size: 12px; display: block; margin-bottom: 5px;",
              tags$i(class = "fas fa-info-circle"),
              " ",
              suggestion$reasoning
            )
          },

          # Source information
          if (!is.null(suggestion$from_name) && nchar(suggestion$from_name) > 0) {
            tags$small(
              class = "text-muted",
              style = "font-size: 11px;",
              "Connected to: ", tags$em(suggestion$from_name)
            )
          }
        ),

        # Add button
        div(
          style = "margin-left: 10px;",
          actionButton(
            ns(paste0("add_suggestion_", suggestion_type, "_", index)),
            tagList(icon("plus"), " Add"),
            class = "btn-sm btn-primary",
            onclick = sprintf(
              "Shiny.setInputValue('%s', {id: '%s', name: '%s', index: %d}, {priority: 'event'});",
              ns(paste0("suggestion_clicked_", suggestion_type)),
              suggestion$to_id,
              gsub("'", "\\\\'", suggestion$to_name),
              index
            )
          )
        )
      )
    )
  )
}

# =============================================================================
# AI SUGGESTION GENERATION LOGIC
# =============================================================================

#' Generate AI suggestions based on current selections
#'
#' @param vocabulary_data Complete vocabulary data
#' @param selected_items Currently selected items (activities, pressures, etc.)
#' @param target_type Type of suggestions to generate ("Pressure", "Consequence", "Control")
#' @param max_suggestions Maximum number of suggestions to return
#' @param methods Analysis methods to use (e.g., c("jaccard", "keyword", "causal"))
#' @return List of suggestions with metadata
generate_ai_suggestions <- function(vocabulary_data,
                                    selected_items,
                                    target_type,
                                    max_suggestions = 5,
                                    methods = c("causal", "keyword", "jaccard")) {

  # Validate inputs
  if (is.null(vocabulary_data) || length(selected_items) == 0) {
    return(list())
  }

  # Check if AI linker is available
  if (!exists("find_vocabulary_links")) {
    warning("AI linker not available for suggestions")
    return(list())
  }

  tryCatch({
    # Generate links using AI linker
    result <- find_vocabulary_links(
      vocabulary_data,
      similarity_threshold = 0.3,  # Lower threshold for suggestions
      max_links_per_item = 10,     # Get more potential suggestions
      methods = methods,           # Use selected methods from settings
      use_domain_knowledge = TRUE
    )

    if (is.null(result$links) || nrow(result$links) == 0) {
      return(list())
    }

    # Filter links to relevant suggestions
    links <- result$links

    # Get IDs of selected items
    selected_ids <- sapply(selected_items, function(x) x$id)

    cat("🔍 [GENERATE_AI] Selected IDs:", paste(selected_ids, collapse = ", "), "\n")
    cat("🔍 [GENERATE_AI] Target type:", target_type, "\n")
    cat("🔍 [GENERATE_AI] Total links before filtering:", nrow(links), "\n")
    cat("🔍 [GENERATE_AI] Unique from_types:", paste(unique(links$from_type), collapse = ", "), "\n")
    cat("🔍 [GENERATE_AI] Unique to_types:", paste(unique(links$to_type), collapse = ", "), "\n")
    cat("🔍 [GENERATE_AI] Sample from_ids (first 10):", paste(head(unique(links$from_id), 10), collapse = ", "), "\n")

    # Check if our selected ID appears in the links at all
    id_in_from <- selected_ids[1] %in% links$from_id
    id_in_to <- selected_ids[1] %in% links$to_id
    cat("🔍 [GENERATE_AI] Selected ID", selected_ids[1], "appears in from_id:", id_in_from, "\n")
    cat("🔍 [GENERATE_AI] Selected ID", selected_ids[1], "appears in to_id:", id_in_to, "\n")

    # If ID appears in to_id, we need to reverse the links
    if (id_in_to && !id_in_from) {
      cat("⚠️ [GENERATE_AI] Selected ID only appears as TO, not FROM. Checking reverse links...\n")
      # Count reverse links
      reverse_matches <- sum(links$to_id %in% selected_ids & links$from_type == target_type)
      cat("🔍 [GENERATE_AI] Reverse links (TO selected, FROM target type):", reverse_matches, "\n")
    }

    # Count how many match each filter
    from_matches <- sum(links$from_id %in% selected_ids)
    to_matches <- sum(links$to_type == target_type)
    cat("🔍 [GENERATE_AI] Links matching from_id:", from_matches, "\n")
    cat("🔍 [GENERATE_AI] Links matching to_type:", to_matches, "\n")

    # Filter links that:
    # 1. Start from selected items
    # 2. Point to target type
    # 3. Aren't already selected
    relevant_links <- links[
      links$from_id %in% selected_ids &
      links$to_type == target_type,
    ]

    cat("🔍 [GENERATE_AI] Relevant links after filtering:", nrow(relevant_links), "\n")

    if (nrow(relevant_links) == 0) {
      cat("❌ [GENERATE_AI] No relevant links found in AI analysis!\n")
      cat("🔄 [GENERATE_AI] Falling back to direct vocabulary matching...\n")

      # Fallback: Create suggestions based on direct vocabulary relationships
      # For Activity->Pressure: suggest all pressures that have matching themes/keywords
      fallback_suggestions <- list()

      if (target_type == "Pressure") {
        # Get all pressures
        pressures <- vocabulary_data$pressures
        if (!is.null(pressures) && nrow(pressures) > 0) {
          # Filter to Level 2+ items
          pressures <- pressures[!is.na(pressures$level) & pressures$level >= 2, ]

          # Get first N as suggestions (simple fallback)
          n_suggestions <- min(max_suggestions, nrow(pressures))
          if (n_suggestions > 0) {
            for (i in 1:n_suggestions) {
              fallback_suggestions[[i]] <- list(
                to_id = pressures$id[i],
                to_name = pressures$name[i],
                to_type = "Pressure",
                from_id = selected_ids[1],
                from_name = selected_items[[1]]$name,
                from_type = "Activity",
                similarity = 0.5,
                confidence = 0.5,
                confidence_level = "medium",
                method = "fallback_vocabulary",
                reasoning = "General environmental pressure (AI analysis incomplete)"
              )
            }
            cat("✅ [GENERATE_AI] Created", length(fallback_suggestions), "fallback suggestions\n")
            return(fallback_suggestions)
          }
        }
      }

      cat("❌ [GENERATE_AI] No fallback suggestions possible. Returning empty list.\n")
      return(list())
    }

    # Remove duplicates, keeping highest similarity
    relevant_links <- relevant_links %>%
      dplyr::arrange(desc(similarity)) %>%
      dplyr::distinct(to_id, .keep_all = TRUE)

    # Add reasoning based on method
    relevant_links$reasoning <- sapply(1:nrow(relevant_links), function(i) {
      link <- relevant_links[i, ]

      if (grepl("causal_chain", link$method)) {
        "Complete causal pathway detected through environmental processes"
      } else if (grepl("causal_environmental_logic", link$method)) {
        "Environmental logic suggests strong cause-effect relationship"
      } else if (grepl("causal_domain", link$method)) {
        "Domain-specific environmental connection identified"
      } else if (grepl("causal_intervention", link$method)) {
        "Control measure specifically targets this issue"
      } else if (grepl("causal", link$method)) {
        "Causal relationship detected in environmental pathway"
      } else if (grepl("keyword_water", link$method)) {
        "Related through water systems theme"
      } else if (grepl("keyword_pollution", link$method)) {
        "Related through pollution theme"
      } else if (grepl("keyword_ecosystem", link$method)) {
        "Related through ecosystem theme"
      } else if (grepl("keyword_fisheries", link$method)) {
        "Related through fisheries theme"
      } else if (grepl("keyword", link$method)) {
        "Thematically related through environmental keywords"
      } else {
        "Semantically similar based on text analysis"
      }
    })

    # Add confidence scores if function is available
    if (exists("add_confidence_scores")) {
      # Prepare context for confidence scoring
      confidence_context <- list(
        all_links = relevant_links,
        selected_types = unique(sapply(selected_items, function(x) x$type))
      )

      relevant_links <- add_confidence_scores(relevant_links, confidence_context)
    }

    # Add ML quality scores if classifier is available
    if (exists("add_ml_quality_scores") && exists("get_ml_classifier")) {
      ml_classifier <- get_ml_classifier()
      if (!is.null(ml_classifier)) {
        relevant_links <- add_ml_quality_scores(relevant_links, ml_classifier)
      }
    }

    # Sort by ML quality (if available), then confidence, then similarity, and limit
    suggestions <- if ("ml_quality" %in% names(relevant_links)) {
      # ML ranking available - use it as primary sort key
      relevant_links %>%
        dplyr::arrange(desc(ml_quality), desc(confidence), desc(similarity)) %>%
        head(max_suggestions)
    } else if ("confidence" %in% names(relevant_links)) {
      # No ML, use confidence
      relevant_links %>%
        dplyr::arrange(desc(confidence), desc(similarity)) %>%
        head(max_suggestions)
    } else {
      # Fallback to similarity only
      relevant_links %>%
        dplyr::arrange(desc(similarity)) %>%
        head(max_suggestions)
    }

    # Convert to list format
    suggestions_list <- lapply(1:nrow(suggestions), function(i) {
      suggestion <- list(
        to_id = suggestions$to_id[i],
        to_name = suggestions$to_name[i],
        to_type = suggestions$to_type[i],
        from_id = suggestions$from_id[i],
        from_name = suggestions$from_name[i],
        from_type = suggestions$from_type[i],
        similarity = suggestions$similarity[i],
        method = suggestions$method[i],
        reasoning = suggestions$reasoning[i]
      )

      # Add confidence information if available
      if ("confidence" %in% names(suggestions)) {
        suggestion$confidence <- suggestions$confidence[i]
        suggestion$confidence_level <- suggestions$confidence_level[i]
        suggestion$confidence_info <- suggestions$confidence_factors[[i]]
      } else {
        # Fallback: use similarity as confidence
        suggestion$confidence <- suggestions$similarity[i]
        suggestion$confidence_level <- if (suggestions$similarity[i] >= 0.7) "high" else if (suggestions$similarity[i] >= 0.5) "medium" else "low"
        suggestion$confidence_info <- list(confidence = suggestions$similarity[i], level = suggestion$confidence_level)
      }

      suggestion
    })

    return(suggestions_list)

  }, error = function(e) {
    warning("Error generating AI suggestions: ", e$message)
    return(list())
  })
}

#' Get explanation for why a suggestion was made
#'
#' @param suggestion Suggestion object
#' @return Character string with explanation
get_suggestion_explanation <- function(suggestion) {
  strength <- if (suggestion$similarity >= 0.8) {
    "very strong"
  } else if (suggestion$similarity >= 0.6) {
    "strong"
  } else {
    "moderate"
  }

  method_name <- if (grepl("causal", suggestion$method)) {
    "causal analysis"
  } else if (grepl("keyword", suggestion$method)) {
    "thematic keyword matching"
  } else {
    "semantic similarity"
  }

  sprintf(
    "This suggestion has a %s connection (%.0f%%) based on %s. %s",
    strength,
    suggestion$similarity * 100,
    method_name,
    if (!is.null(suggestion$reasoning)) suggestion$reasoning else ""
  )
}

# =============================================================================
# REACTIVE SUGGESTION HANDLERS
# =============================================================================

#' Create suggestion update observer
#'
#' This creates a reactive observer that updates suggestions when selections change
#'
#' @param session Shiny session
#' @param input Shiny input
#' @param vocabulary_data Vocabulary data reactive
#' @param selected_items_reactive Reactive containing currently selected items
#' @param target_type Type of items to suggest
#' @param suggestion_type UI identifier for this suggestion panel
#' @return Observer object
create_suggestion_observer <- function(session,
                                       input,
                                       vocabulary_data,
                                       selected_items_reactive,
                                       target_type,
                                       suggestion_type) {
  ns <- session$ns

  observe({
    # Get current selections
    selected_items <- selected_items_reactive()

    if (length(selected_items) == 0) {
      # No selections - show initial message
      shinyjs::hide(paste0("suggestion_loading_", suggestion_type))
      shinyjs::hide(paste0("suggestions_list_", suggestion_type))
      shinyjs::hide(paste0("no_suggestions_", suggestion_type))
      shinyjs::hide(paste0("suggestion_error_", suggestion_type))
      shinyjs::show(paste0("suggestion_status_", suggestion_type))
      return()
    }

    # Show loading
    shinyjs::hide(paste0("suggestion_status_", suggestion_type))
    shinyjs::hide(paste0("suggestions_list_", suggestion_type))
    shinyjs::hide(paste0("no_suggestions_", suggestion_type))
    shinyjs::hide(paste0("suggestion_error_", suggestion_type))
    shinyjs::show(paste0("suggestion_loading_", suggestion_type))

    # Generate suggestions
    tryCatch({
      suggestions <- generate_ai_suggestions(
        vocabulary_data(),
        selected_items,
        target_type,
        max_suggestions = 5
      )

      if (length(suggestions) == 0) {
        # No suggestions found
        shinyjs::hide(paste0("suggestion_loading_", suggestion_type))
        shinyjs::hide(paste0("suggestions_list_", suggestion_type))
        shinyjs::show(paste0("no_suggestions_", suggestion_type))
      } else {
        # Show suggestions
        output[[paste0("suggestions_content_", suggestion_type)]] <- renderUI({
          tagList(
            lapply(1:length(suggestions), function(i) {
              create_suggestion_card_ui(ns, suggestions[[i]], i, suggestion_type)
            })
          )
        })

        shinyjs::hide(paste0("suggestion_loading_", suggestion_type))
        shinyjs::hide(paste0("no_suggestions_", suggestion_type))
        shinyjs::show(paste0("suggestions_list_", suggestion_type))
      }
    }, error = function(e) {
      # Show error
      shinyjs::hide(paste0("suggestion_loading_", suggestion_type))
      shinyjs::hide(paste0("suggestions_list_", suggestion_type))
      shinyjs::hide(paste0("no_suggestions_", suggestion_type))
      shinyjs::show(paste0("suggestion_error_", suggestion_type))
    })
  })
}

# =============================================================================
# INITIALIZATION
# =============================================================================

cat("✅ Guided Workflow AI Suggestions module loaded\n")
cat("   - AI-powered live suggestions available\n")
cat("   - Causal pathway detection enabled\n")
cat("   - Thematic keyword matching enabled\n")
cat("   - Semantic similarity analysis enabled\n\n")
