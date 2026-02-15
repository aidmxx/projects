# Time series page logic - UI and server functions
#
# NOTE: The Shiny-specific functions (timeseries_ui(), timeseries_server(), 
# renderPlotly outputs) are excluded from unit test coverage because they require 
# active Shiny session context. These functions should be tested via integration 
# tests (shinytest2) or manual testing. Only the business logic functions that 
# can be tested in isolation are covered by unit tests.

# ---- UI Function ----
timeseries_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    div(
      style = "margin-bottom: 15px; padding: 10px; background-color: #f8f9fa; 
                border-radius: 0.5rem; border: 1px solid #ddd; display: flex; 
                gap: 15px; align-items: center;",
      div(
        style = "flex: 1;",
        sliderInput(ns("ts_point_size"), "Point Size",
                    min = 1, max = 5, value = 3, step = 0.5,
                    ticks = FALSE, width = "100%")
      ),
      div(
        style = "flex: 1;",
        checkboxInput(ns("ts_show_smooth"), "Show Trend Line", value = FALSE)
      )
    ),
    card(card_header("Time Series Plot"),
          plotlyOutput(ns("ts_plot"), height = "500px", width = "100%"))
  )
}

# ---- Server Function ----
timeseries_server <- function(id, data_r, filtered, measure_sel, grouped_data) {
  moduleServer(id, function(input, output, session) {
    
    # Time series plot using shared grouped data
    output$ts_plot <- renderPlotly({
      df_combined <- grouped_data()
      req(!is.null(df_combined) && nrow(df_combined) > 0, cancelOutput = TRUE)
      
      m <- measure_sel()
      
      # Aggregate data by date and group
      df_daily <- df_combined |> 
        group_by(date, group) |>
        summarize(
          value = mean(.data[[m]], na.rm=TRUE),
          count = n(),
          .groups="drop"
        )
      
      # Use default ggplot2 colors to match cohorts page (no custom palette)
      unique_groups <- unique(df_daily$group)
      n_groups <- length(unique_groups)
        
        point_size <- if (!is.null(input$ts_point_size)) input$ts_point_size else 3
        show_smooth <- if (!is.null(input$ts_show_smooth)) input$ts_show_smooth else FALSE
        
        p <- ggplot(df_daily, aes(date, value, color = group, group = group,
                                        text = paste0(
                                          "<b>", group, "</b><br>",
                                          "Date: ", date, "<br>",
                                          "Average ", m, ": ", round(value, 2), "<br>",
                                          "Records: ", count
                                        ))) +
          geom_line() + 
          geom_point() +
          {if (show_smooth) geom_smooth(method = "loess", se = FALSE, alpha = 0.7)} +
          # No custom color scale - uses default ggplot2 colors like cohorts page
          labs(
            x = NULL, 
            y = paste(m, "(", measure_units[[tolower(m)]], ")"), 
            color = "Animal Group"
          ) +
          theme_minimal(base_size = 12)
        
      ggplotly(p, tooltip = "text", height = 500)
    })
  })
}