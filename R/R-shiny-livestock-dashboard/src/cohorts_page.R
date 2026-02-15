# --- cohorts.R ---

cohorts_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Top header controls
    layout_columns(
      col_widths = c(12),
      div(
        tags$label("Top/Bottom percentile (this page only)", class="form-label"),
        shinyWidgets::pickerInput(
          ns("pct_cut"), NULL,
          choices = c("10%", "15%", "20%"),
          selected = "10%",
          multiple = FALSE
        )
      )
    ),
    # Warning for mixed selections
    conditionalPanel(
      condition = "output.show_mixed_warning",
      ns = ns,
      bslib::card(
        bslib::card_header("⚠️ Selection Notice", class = "text-warning"),
        div(
          class = "alert alert-warning mb-0",
          p("You have selected both 'Overall' and specific items in your filters. For cohorts to work clearly, please choose either 'Overall' OR specific items, not both."),
          p("This prevents confusing results where cohorts mix different types of data.")
        )
      )
    ),
    
    # Explanation for clients
    bslib::card(
      min_height = "300px",
      bslib::card_header("How Cohorts Work - Understanding Animal Performance"),
      div(
        class = "mb-3",
        style = "padding: 15px; line-height: 1.6;",
        p("Cohorts help you identify your best and worst performing individual animals based on their overall average performance across all measurement dates. This approach focuses on consistent performers over time."),
        
        h6("How Individual Animal Ranking Works:", class = "mt-4 mb-3 fw-bold"),
        p("Each animal's performance is averaged across all their measurement records. Animals are then ranked based on these individual averages to identify the top and bottom performers."),
        
        h6("How It Works:", class = "mt-4 mb-3 fw-bold"),
        tags$ul(
          tags$li(strong("Individual Averages:"), " Each animal's performance is averaged across all their measurement records."),
          tags$li(strong("Overall Ranking:"), " Animals are ranked based on their individual average performance."),
          tags$li(strong("Cohort Selection:"), " The top and bottom percentiles of animals are selected based on their overall averages."),
          tags$li(strong("Top Cohort:"), " Animals with the highest average performance across all their records."),
          tags$li(strong("Bottom Cohort:"), " Animals with the lowest average performance across all their records."),
          tags$li(strong("Percentile Setting:"), " You can adjust what percentage of animals go into each group (e.g. 10% = top 10% and bottom 10% of all animals).")
        ),
        
        h6("Real-World Example:", class = "mt-4 mb-3 fw-bold"),
        p("Consider two animals:"),
        tags$ul(
          tags$li("Animal A: Has measurements of 180kg, 200kg, 220kg, 240kg → Average = 210kg → Likely in top cohort"),
          tags$li("Animal B: Has measurements of 150kg, 160kg, 170kg, 180kg → Average = 165kg → Likely in bottom cohort")
        ),
        
        h6("Benefits for Your Farm:", class = "mt-4 mb-3 fw-bold"),
        tags$ul(
          tags$li(strong("Consistent Performers:"), " Identify animals that consistently perform well or poorly across all measurements."),
          tags$li(strong("Breeding Decisions:"), " Select top performers for breeding programs based on overall performance."),
          tags$li(strong("Management Focus:"), " Focus attention on bottom performers that may need special care or different management."),
          tags$li(strong("Stable Rankings:"), " Rankings are stable since they're based on overall performance, not daily fluctuations.")
        ),
        
        div(
          class = "alert alert-info mt-4 p-3",
          icon("lightbulb", class = "me-2"),
          strong("Tip:"), " The cards below summarise selected animals using their overall averages — they do not refer to a single date. The timeline shows how these selected animals performed on each date."
        )
      )
    ),

    # Cards
    layout_columns(
      col_widths = c(6, 6),
      bslib::card(
        bslib::card_header(
          div(
            icon("trophy", class = "me-2"),
            "Top Cohort - Individual Averages"
          )
        ),
        div(class = "text-muted small mb-2", "Based on each animal's overall average across all records (not a single date)."),
        div(class = "d-flex justify-content-between flex-wrap gap-2",
            div(
              p("Average", class="text-muted small mb-1"),
              h4(textOutput(ns("top_avg"), inline = TRUE))
            ),
            div(
              p("Min", class="text-muted small mb-1"),
              h4(textOutput(ns("top_min"), inline = TRUE))
            ),
            div(
              p("Max", class="text-muted small mb-1"),
              h4(textOutput(ns("top_max"), inline = TRUE))
            ),
            div(
              p(textOutput(ns("top_n_label"), inline = TRUE), class="text-muted small mb-1"),
              h5(textOutput(ns("top_n"), inline = TRUE))
            )
        ),
        div(
          class = "d-flex gap-2 mt-2",
          shiny::actionLink(ns("view_top"), 
            div(icon("eye", class = "me-1"), "View Animals"),
            class = "btn btn-outline-primary btn-sm"
          ),
          shiny::downloadButton(ns("dl_top"), 
            div(icon("download", class = "me-1"), "Export"),
            class = "btn btn-outline-success btn-sm"
          )
        )
      ),
      bslib::card(
        bslib::card_header(
          div(
            icon("exclamation-triangle", class = "me-2"),
            "Bottom Cohort - Individual Averages"
          )
        ),
        div(class = "text-muted small mb-2", "Based on each animal's overall average across all records (not a single date)."),
        div(class = "d-flex justify-content-between flex-wrap gap-2",
            div(
              p("Average", class="text-muted small mb-1"),
              h4(textOutput(ns("bot_avg"), inline = TRUE))
            ),
            div(
              p("Min", class="text-muted small mb-1"),
              h4(textOutput(ns("bot_min"), inline = TRUE))
            ),
            div(
              p("Max", class="text-muted small mb-1"),
              h4(textOutput(ns("bot_max"), inline = TRUE))
            ),
            div(
              p(textOutput(ns("bot_n_label"), inline = TRUE), class="text-muted small mb-1"),
              h5(textOutput(ns("bot_n"), inline = TRUE))
            )
        ),
        div(
          class = "d-flex gap-2 mt-2",
          shiny::actionLink(ns("view_bot"), 
            div(icon("eye", class = "me-1"), "View Animals"),
            class = "btn btn-outline-primary btn-sm"
          ),
          shiny::downloadButton(ns("dl_bot"), 
            div(icon("download", class = "me-1"), "Export"),
            class = "btn btn-outline-success btn-sm"
          )
        )
      )
    ),

    # Charts
    layout_columns(
      col_widths = c(12),
      bslib::card(
        bslib::card_header(
          div(class="d-flex justify-content-between align-items-center",
              h6(
                div(icon("chart-line", class = "me-2"), 
                    textOutput(ns("trend_title"))
                ), 
                class="m-0 text-white"
              ),
              downloadButton(ns("dl_trend"), 
                div(icon("download", class = "me-1"), "Export"),
                class = "btn btn-outline-primary btn-sm"
              )
          )
        ),
        plotly::plotlyOutput(ns("trend_plot"), height = "500px", width = "100%")
      )
    )
  )
}

# NOTE: This function is excluded from unit test coverage because it contains
# Shiny reactive functions and UI rendering code that requires a full Shiny
# app context to test properly. The core business logic (cohorts_server function and related functions) will be tested separately in unit tests.

cohorts_server <- function(id, data_r, measure_col, date_col = NULL) { # nocov start
  label <- function(x) {tools::toTitleCase(gsub("_", " ", x))}
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # helpers
    pct_to_num <- function(x) switch(x, "10%" = 0.10, "15%" = 0.15, "20%" = 0.20, 0.10)

    # ---- Base data after all main filters ----
    base_df <- reactive({
      df <- data_r()
      m  <- measure_col()
      req(nrow(df) > 0, m %in% names(df))

      # standardise date column if not supplied
      dcol <- if (is.null(date_col)) {
        if ("date" %in% names(df)) "date" else NULL
      } else date_col

      # keep only needed cols
      cols <- unique(c("eid","sex","mob","treatment","breed", m, if (!is.null(dcol)) dcol))
      df[, intersect(cols, names(df)), drop = FALSE]
    })

    # ---- Check for mixed selections (Overall + specific items) ----
    has_mixed_selection <- reactive({
      df <- base_df()
      
      # Check each categorical column for mixed selections
      mixed_cols <- c()
      
      if ("sex" %in% names(df)) {
        sex_vals <- unique(df$sex)
        if ("Overall" %in% sex_vals && length(sex_vals) > 1) {
          mixed_cols <- c(mixed_cols, "Sex")
        }
      }
      
      if ("treatment" %in% names(df)) {
        treatment_vals <- unique(df$treatment)
        if ("Overall" %in% treatment_vals && length(treatment_vals) > 1) {
          mixed_cols <- c(mixed_cols, "Treatment")
        }
      }
      
      if ("breed" %in% names(df)) {
        breed_vals <- unique(df$breed)
        if ("Overall" %in% breed_vals && length(breed_vals) > 1) {
          mixed_cols <- c(mixed_cols, "Breed")
        }
      }
      
      if ("mob" %in% names(df)) {
        mob_vals <- unique(df$mob)
        if ("Overall" %in% mob_vals && length(mob_vals) > 1) {
          mixed_cols <- c(mixed_cols, "Month of Birth")
        }
      }
      
      list(has_mixed = length(mixed_cols) > 0, columns = mixed_cols)
    })

    # ---- Show warning for mixed selections ----
    output$show_mixed_warning <- reactive({
      has_mixed_selection()$has_mixed
    })
    outputOptions(output, "show_mixed_warning", suspendWhenHidden = FALSE)

    # ---- Compute top/bottom individual animals by overall average ----
    cohort_flags <- reactive({
      df <- base_df()
      m  <- measure_col()
      p  <- pct_to_num(if (is.null(input$pct_cut)) "10%" else input$pct_cut)

      dcol <- if (!is.null(date_col)) date_col else if ("date" %in% names(df)) "date" else NULL
      req(!is.null(dcol), m %in% names(df))

      # Calculate each animal's average performance across all their records
      animal_averages <- df |>
        dplyr::group_by(eid) |>
        dplyr::summarise(
          .animal_avg = mean(.data[[m]], na.rm = TRUE),
          .animal_count = dplyr::n(),
          .groups = "drop"
        ) |>
        dplyr::filter(.animal_count >= 2)

      # Percentile cutoffs across animals
      top_cutoff <- stats::quantile(animal_averages$.animal_avg, probs = 1 - p, na.rm = TRUE, type = 7)
      bot_cutoff <- stats::quantile(animal_averages$.animal_avg, probs = p, na.rm = TRUE, type = 7)

      # Identify top and bottom animals
      top_animals <- animal_averages |>
        dplyr::filter(.animal_avg >= top_cutoff) |>
        dplyr::pull(eid)
      bot_animals <- animal_averages |>
        dplyr::filter(.animal_avg <= bot_cutoff) |>
        dplyr::pull(eid)

      # Flag original data and standardise date
      df |>
        dplyr::mutate(
          .date = as.Date(.data[[dcol]]),
          .top = eid %in% top_animals,
          .bot = eid %in% bot_animals,
          .cut_top = top_cutoff,
          .cut_bot = bot_cutoff
        )
    })

    # ---- Cards ----
    summarise_card <- function(flag_col) {
      df <- cohort_flags()
      m  <- measure_col()
      sub <- df[df[[flag_col]], , drop = FALSE]
      
      # Calculate individual animal averages
      animal_stats <- sub |>
        dplyr::group_by(eid) |>
        dplyr::summarise(
          animal_avg = mean(.data[[m]], na.rm = TRUE),
          .groups = "drop"
        )

      list(
        n   = nrow(animal_stats),
        avg = mean(animal_stats$animal_avg, na.rm = TRUE),
        min = suppressWarnings(min(animal_stats$animal_avg, na.rm = TRUE)),
        max = suppressWarnings(max(animal_stats$animal_avg, na.rm = TRUE))
      )
    }

    observe({
      ptxt <- if (is.null(input$pct_cut)) "10%" else input$pct_cut
      output$top_n_label <- renderText(paste0("Animals (n)"))
      output$bot_n_label <- renderText(paste0("Animals (n)"))
    })

    output$top_n   <- renderText({ as.character(summarise_card(".top")$n) })
    output$top_avg <- renderText({ as.character(round(summarise_card(".top")$avg, 1)) })
    output$top_min <- renderText({ as.character(round(summarise_card(".top")$min, 1)) })
    output$top_max <- renderText({ as.character(round(summarise_card(".top")$max, 1)) })

    output$bot_n   <- renderText({ as.character(summarise_card(".bot")$n) })
    output$bot_avg <- renderText({ as.character(round(summarise_card(".bot")$avg, 1)) })
    output$bot_min <- renderText({ as.character(round(summarise_card(".bot")$min, 1)) })
    output$bot_max <- renderText({ as.character(round(summarise_card(".bot")$max, 1)) })

    # ---- Trend over time (avg value in each cohort) ----
    trend_data <- reactive({
      df <- cohort_flags()
      m  <- measure_col()

    df |>
      dplyr::filter(.top | .bot) |>
      dplyr::group_by(.date) |>
      dplyr::summarise(
        top_avg  = if (any(.top)) mean(.data[[m]][.top], na.rm = TRUE) else NA_real_,
        bot_avg  = if (any(.bot)) mean(.data[[m]][.bot], na.rm = TRUE) else NA_real_,
        top_cut  = dplyr::first(.cut_top),
        bot_cut  = dplyr::first(.cut_bot),
        top_n    = sum(.top, na.rm = TRUE),
        bot_n    = sum(.bot, na.rm = TRUE),
        total_n  = dplyr::n(),
        .groups  = "drop"
      ) |>
      tidyr::pivot_longer(
        cols = c(top_avg, bot_avg),
        names_to = "series",
        values_to = "value"
      ) |>
      dplyr::mutate(cohort = dplyr::recode(series, top_avg = "Top", bot_avg = "Bottom")) |>
      dplyr::filter(!is.na(value))
    })

    ## Trend title

    output$trend_title <- renderText({
      paste0("Cohort Average Over Time (", label(measure_col()), ")")
    })

    ## Trend plot
    output$trend_plot <- plotly::renderPlotly({
    d <- trend_data(); req(nrow(d) > 0)
    ylabel <- label(measure_col())

    # --- Cohort counts per date (for tooltip) ---
    counts <- cohort_flags() |>
      dplyr::filter(.top | .bot) |>
      dplyr::mutate(cohort = dplyr::case_when(.top ~ "Top", .bot ~ "Bottom", TRUE ~ NA_character_)) |>
      dplyr::filter(!is.na(cohort)) |>
      dplyr::count(.date, cohort, name = "n")

    # --- Fixed cutoff lines (based on individual-average thresholds) ---
    cuts <- cohort_flags() |>
      dplyr::summarise(
        top_cut = dplyr::first(.cut_top),
        bot_cut = dplyr::first(.cut_bot),
        .groups = "drop"
      ) |>
      dplyr::slice(1)
    cutoff_data <- data.frame(
      cutoff_label = c("Top cutoff", "Bottom cutoff"),
      cutoff_value = c(cuts$top_cut, cuts$bot_cut)
    )

    # Merge counts into the averages we plot
    d_plot <- d |>
      dplyr::left_join(counts, by = c(".date", "cohort"))

    # --- Build plot ---
    p <- ggplot2::ggplot(d_plot, ggplot2::aes(.date, value, color = cohort)) +
      # Add fixed (global) cutoff lines
      ggplot2::geom_hline(
        data = cutoff_data,
        ggplot2::aes(yintercept = cutoff_value, color = cutoff_label),
        linetype = "dashed",
        alpha = 0.7,
        linewidth = 0.8
      ) +
      ggplot2::geom_line() +
      ggplot2::geom_point(size = 1.7) +
      ggplot2::labs(
        x = NULL, 
        y = ylabel, 
        color = NULL,
        title = "Selected Animals Performance Over Time",
        subtitle = "Shows only the top and bottom performing individual animals based on their overall average performance. Dashed lines indicate fixed cutoff thresholds."
      ) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(plot.title = ggplot2::element_text(size = 12, hjust = 0.5),
                     plot.subtitle = ggplot2::element_text(size = 10, hjust = 0.5))

    plotly::ggplotly(p, tooltip = c(".date", "value", "cohort", "n"), height = 500)
  })

    # ---- Exports ----
    output$dl_trend <- downloadHandler(
      filename = function() paste0("cohort_trend_", Sys.Date(), ".csv"),
      content  = function(file) readr::write_csv(trend_data(), file)
    )

    # cohort member tables (Top / Bottom) - show selected individual animals
    top_tbl <- reactive({ 
      cohort_flags() |> 
        dplyr::filter(.top) |>
        dplyr::group_by(eid) |>
        dplyr::summarise(
          sex = dplyr::first(sex),
          mob = dplyr::first(mob),
          treatment = dplyr::first(treatment),
          breed = dplyr::first(breed),
          average_performance = mean(.data[[measure_col()]], na.rm = TRUE),
          latest_date = max(.date, na.rm = TRUE),
          latest_value = .data[[measure_col()]][.date == max(.date, na.rm = TRUE)][1],
          total_records = dplyr::n(),
          .groups = "drop"
        ) |>
        dplyr::arrange(desc(average_performance))
    })
    
    bot_tbl <- reactive({ 
      cohort_flags() |> 
        dplyr::filter(.bot) |>
        dplyr::group_by(eid) |>
        dplyr::summarise(
          sex = dplyr::first(sex),
          mob = dplyr::first(mob),
          treatment = dplyr::first(treatment),
          breed = dplyr::first(breed),
          average_performance = mean(.data[[measure_col()]], na.rm = TRUE),
          latest_date = max(.date, na.rm = TRUE),
          latest_value = .data[[measure_col()]][.date == max(.date, na.rm = TRUE)][1],
          total_records = dplyr::n(),
          .groups = "drop"
        ) |>
        dplyr::arrange(average_performance)
    })

    output$dl_top <- downloadHandler(
      filename = function() paste0("cohort_top_", Sys.Date(), ".csv"),
      content  = function(file) readr::write_csv(top_tbl(), file)
    )
    output$dl_bot <- downloadHandler(
      filename = function() paste0("cohort_bottom_", Sys.Date(), ".csv"),
      content  = function(file) readr::write_csv(bot_tbl(), file)
    )

    # “View Animals” modals
    observeEvent(input$view_top, {
      shiny::showModal(
        modalDialog(
          title = "Top cohort members",
          size = "l",
          easyClose = TRUE,
          DT::DTOutput(ns("tbl_top"))
        )
      )
    })
    output$tbl_top <- DT::renderDT({
      DT::datatable(top_tbl(), options = list(pageLength = 10, scrollX = TRUE))
    })

    observeEvent(input$view_bot, {
      shiny::showModal(
        modalDialog(
          title = "Bottom cohort members",
          size = "l",
          easyClose = TRUE,
          DT::DTOutput(ns("tbl_bot"))
        )
      )
    })
    output$tbl_bot <- DT::renderDT({
      DT::datatable(bot_tbl(), options = list(pageLength = 10, scrollX = TRUE))
    })
  })
}
# nocov end