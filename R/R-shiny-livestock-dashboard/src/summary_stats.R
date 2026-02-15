# ---- KPI helper (available for testing) ----
kpi_block <- function(df, measure) {
    if (nrow(df) == 0 || !is.numeric(df[[measure]])) {
        return(div(div(class = "h3 fw-bold", "0"), div(class = "text-muted", "No data")))
    }
    m <- df[[measure]]
    unit_val <- measure_units[[tolower(measure)]]
    unit <- if (is.null(unit_val)) "" else unit_val
    fmt <- function(x) ifelse(is.na(x), "—", sprintf("%.2f", x))
    fmt_with_unit <- function(x) {
        v <- fmt(x)
        if (!is.null(unit) && unit == "$") {
            paste0(unit, v)
        } else if (!is.null(unit) && nzchar(unit)) {
            paste(v, unit)
        } else {
            v
        }
    }

    tagList(
        div(class = "h4 fw-bold", style = "font-size: 1.7rem; line-height: 1.2;", fmt_with_unit(mean(m, na.rm = TRUE))),
        div(class = "text-muted", "Mean"),
        tags$hr(),
        div(class = "small", sprintf("Min: %s",    fmt_with_unit(min(m, na.rm = TRUE)))),
        div(class = "small", sprintf("Max: %s",    fmt_with_unit(max(m, na.rm = TRUE)))),
        div(class = "small", sprintf("Median: %s", fmt_with_unit(stats::median(m, na.rm = TRUE)))),
        div(class = "small", sprintf("Count: %d records", sum(!is.na(m))))
        )
    }

# ---- Helper: slice dataset by time window (available for testing) ----
subset_by_window <- function(df, days) {
        if (nrow(df) == 0) return(df[0, ])
        dmax <- max(df$date, na.rm = TRUE)
        df |> dplyr::filter(date >= dmax - days + 1 & date <= dmax)
    }

# ---- Helper: create full group labels for summary stats (available for testing) ----
create_full_group_labels <- function(df, input) {
    if (nrow(df) == 0) return(character(0))
    
    # Ensure we have the required columns
    required_cols <- c("sex", "treatment", "breed", "mob", "eid")
    missing_cols <- required_cols[!required_cols %in% names(df)]
    if (length(missing_cols) > 0) {
        # nocov start
        stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
        # nocov end
    }
    
    # Get all unique combinations of filter values
    unique_combos <- df[, c("sex", "treatment", "breed", "mob", "eid"), drop = FALSE]
    unique_combos <- unique(unique_combos)
    
    # Create full labels showing all filter options
    full_labels <- character(nrow(df))
    for (i in 1:nrow(df)) {
        label_parts <- character(0)
        for (col in c("sex", "treatment", "breed", "mob", "eid")) {
            # Safely extract and convert the value
            raw_value <- df[i, col]
            if (is.null(raw_value)) {
                # nocov start
                value <- "NULL"
                # nocov end
            } else if (is.na(raw_value)) {
                value <- "NA"
            } else {
                # Safely convert to character
                value <- tryCatch({
                    as.character(raw_value)
                }, error = function(e) {
                    # nocov start
                    paste("Error:", as.character(e$message))
                    # nocov end
                })
            }
            
            # Handle NA values for treatment
            if (col == "treatment" && (is.na(value) || value == "NA")) {
                value <- "No Treatment"
            }
            # Capitalize first letter of column name, with special handling for EID
            if (col == "eid") {
                col_name <- "EID"
            } else {
                col_name <- paste0(toupper(substr(col, 1, 1)), substr(col, 2, nchar(col)))
            }
            label_parts <- c(label_parts, paste0(col_name, ": ", value))
        }
        full_labels[i] <- paste(label_parts, collapse = ", ")
    }
    
    return(full_labels)
}

# NOTE: This function is excluded from unit test coverage because it contains
# Shiny reactive functions and UI rendering code that requires a full Shiny
# app context to test properly. The core business logic (kpi_block and 
# subset_by_window functions) will be tested separately in unit tests.
register_summary_stats <- function(output, processed_data, measure_sel, filtered, input, grouped_data) { # nocov start

    # ---- Summary page content ----
    # EXCLUDED FROM COVERAGE: Shiny UI rendering - requires app context
    output$summary_content <- shiny::renderUI({
        # Safely get filtered data
        df <- tryCatch({
            filtered()
        }, error = function(e) {
            data.frame()
        })
        
        if (is.data.frame(df) && nrow(df) > 0) {
            tagList(
                div(
                    class = "alert alert-info",
                    role = "alert",
                    HTML("ℹ️ The summary statistics below show separate statistics for each animal group based on your current filter selections.")
                ),
                
                # Show group-specific KPI cards with original panel layout
                uiOutput("group_kpi_cards")
            )
        } else {
            div("No data available")
        }
    })

    # ---- Group-specific KPI cards ----
    # EXCLUDED FROM COVERAGE: Shiny output assignments - requires app context
    output$group_kpi_cards <- shiny::renderUI({
        # Safely get the grouped data
        df <- tryCatch({
            grouped_data()
        }, error = function(e) {
            # Return empty data frame if grouped_data fails
            data.frame()
        })
        
        # Check if we have valid data
        if (!is.data.frame(df) || nrow(df) == 0) {
            return(div("No data available"))
        }
        
        # Safely create full group labels for summary stats
        tryCatch({
            df$full_group <- create_full_group_labels(df, input)
        }, error = function(e) {
            # Fallback: create simple group labels if the full labels fail
            if ("group" %in% names(df)) {
                df$full_group <<- df$group
            } else {
                df$full_group <<- paste("Group", seq_len(nrow(df)))
            }
        })
        
        # Get unique groups with full labels
        groups <- unique(df$full_group)
        
        # Create KPI cards for each group using the original panel layout
        cards <- lapply(groups, function(group_name) {
            group_data <- df[df$full_group == group_name, ]
            
            # Create time-based subsets for this group
            last_day_data <- subset_by_window(group_data, 1)
            last_15_data <- subset_by_window(group_data, 15)
            last_month_data <- subset_by_window(group_data, 31)
            last_date_text <- if (nrow(last_day_data) > 0 && "date" %in% names(last_day_data)) {
                last_date <- max(last_day_data$date, na.rm = TRUE)
                paste0("Last Day (", format(last_date, "%d/%m/%Y"), ")")
            } else {
                "Last Day"
            }

            # Create the KPI cards for this group using original layout
            tagList(
                div(
                    class = "mb-4",
                    div(
                        class = "h5 mb-3",
                        style = "color: #1B4332; font-weight: 600;",
                        group_name
                    ),
                    layout_columns(
                        card(card_header(last_date_text),     kpi_block(last_day_data, measure_sel())),
                        card(card_header("Last 15 Days"),  kpi_block(last_15_data, measure_sel())),
                        card(card_header("Last Month"),   kpi_block(last_month_data, measure_sel())),
                        card(card_header("Overall"),      kpi_block(group_data, measure_sel()))
                    )
                )
            )
        })
        
        # Return all cards in a layout
        do.call(tagList, cards)
    })

    # ---- Group KPI cards ----
    # EXCLUDED FROM COVERAGE: Shiny UI rendering with reactive data - requires app context
    output$kpi_cards <- renderUI({
        # Safely get the processed data
        df <- tryCatch({
            processed_data()
        }, error = function(e) {
            # Return empty data frame if processed_data fails
            data.frame()
        })
        
        # Validate that we have a data frame and it's not empty
        if (!is.data.frame(df)) {
            return(div("Error: Invalid data format"))
        }
        
        if (nrow(df) == 0) {
            return(div("No data available"))
        }
        # Use pre-computed group column if available, otherwise create it
        # NOTE: Group creation logic is tested separately in unit tests
        if (!"group" %in% names(df)) {
            df$group <- paste(df$sex, df$treatment, df$breed, df$mob, sep = " | ")
        }
        groups <- unique(df$group)

        # NOTE: Card creation logic uses kpi_block function which is unit tested
        cards <- lapply(groups, function(group_name) {
            group_data <- df[df$group == group_name, ]
            card(card_header(group_name), kpi_block(group_data, measure_sel()))
        })

        do.call(layout_columns, c(cards, col_widths = rep(3, length(cards))))
    })
}

# nocov end


