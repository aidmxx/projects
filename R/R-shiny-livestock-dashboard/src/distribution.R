# Distribution page logic - histogram and boxplot outputs
#
# NOTE: This file contains Shiny reactive functions (distribution_outputs(), 
# renderPlotly outputs) that are excluded from unit test coverage because they 
# require active Shiny session context. These functions should be tested via 
# integration tests (shinytest2) or manual testing. The business logic within 
# these functions (data sampling, statistical calculations, plot configuration) 
# can be tested in isolation, but the Shiny-specific reactive wrappers require 
# a running Shiny application.

distribution_outputs <- function(input, output, session, processed_data, measure_sel, filtered, grouped_data) {
  
  # Create shared sampled data reactive with aggressive optimization
  sampled_data <- reactive({
    df_combined <- grouped_data()
    if (nrow(df_combined) == 0) return(df_combined)
    
    # More aggressive sampling for distribution plots
    if (nrow(df_combined) > 5000) {
      # Reduce to 500 points per group for better performance
      df_combined |>
        group_by(group) |>
        slice_sample(n = 500, replace = FALSE) |>
        ungroup()
    } else if (nrow(df_combined) > 2000) {
      # Medium datasets: 300 points per group
      df_combined |>
        group_by(group) |>
        slice_sample(n = 300, replace = FALSE) |>
        ungroup()
    } else {
      df_combined
    }
  })
  
  # Create histogram-specific data with even more aggressive sampling
  hist_data <- reactive({
    df_combined <- grouped_data()
    if (nrow(df_combined) == 0) return(df_combined)
    
    # Very aggressive sampling for histogram (most expensive plot)
    if (nrow(df_combined) > 3000) {
      # Only 200 points per group for histogram
      df_combined |>
        group_by(group) |>
        slice_sample(n = 200, replace = FALSE) |>
        ungroup()
    } else {
      df_combined
    }
  })
  
  # histogram with group comparisons (optimized for performance)
  output$hist_plot <- renderPlotly({
    df_sampled <- hist_data()  # Use histogram-specific aggressive sampling
    req(nrow(df_sampled) > 0, cancelOutput = TRUE)
    m <- measure_sel()
    
    # Use slider input for bins, with default of 20
    bins <- if (!is.null(input$hist_bins)) input$hist_bins else 20
    
    # Calculate overall statistics (simplified)
    mean_val <- mean(df_sampled[[m]], na.rm = TRUE)
    median_val <- median(df_sampled[[m]], na.rm = TRUE)
    
    # Simplified tooltip for better performance
    p <- ggplot(df_sampled, aes(.data[[m]], fill = group, color = group,
                                text = paste0(
                                  "<b>", group, "</b><br>",
                                  "Value: ", round(.data[[m]], 2)
                                ))) + 
      geom_histogram(bins = bins, alpha = 0.7, position = "identity", linewidth = 0.2) +
      geom_vline(xintercept = mean_val, color = "#B08968", linetype = "dashed", linewidth = 0.8) +
      geom_vline(xintercept = median_val, color = "#7B241C", linetype = "dotted", linewidth = 0.8) +
      labs(
        x = paste(m, "(", measure_units[[tolower(m)]], ")"), 
        y = "Frequency",
        title = paste("Distribution Comparison:", m, "by Group"),
        fill = "Group",
        color = "Group"
      ) +
      theme_minimal(base_size = 11) +
      theme(
        plot.title = element_text(face = "plain", hjust = 0.5, color = "#1B4332", size = 13),
        panel.grid.minor = element_blank(),
        axis.text = element_text(color = "#40360c", size = 9),
        axis.title = element_text(color = "#40360c", face = "plain", size = 10),
        legend.position = "bottom",
        legend.title = element_text(color = "#40360c", face = "plain", size = 10),
        legend.text = element_text(color = "#40360c", size = 9)
      )
    
    # Simplified plotly rendering with explicit sizing
    ggplotly(p, tooltip = "text", height = 500, width = NULL) %>%
      layout(
        autosize = FALSE,
        margin = list(l = 50, r = 50, t = 50, b = 80),
        hoverlabel = list(
          bgcolor = "white",
          bordercolor = "#1B4332",
          font = list(color = "#40360c", size = 11)
        ),
        legend = list(
          orientation = "h",
          x = 0.5,
          xanchor = "center",
          y = -0.15
        )
      )
  })
  
  # boxplot - optimized with shared data processing
  output$box_plot <- renderPlotly({
    df_sampled <- sampled_data()
    req(nrow(df_sampled) > 0, cancelOutput = TRUE)
    m <- measure_sel()
    
    # Simplified tooltip for better performance
    p <- ggplot(df_sampled, aes(group, .data[[m]], fill = group,
                                text = paste0(
                                  "<b>", group, "</b><br>",
                                  "Value: ", round(.data[[m]], 2)
                                ))) +
      geom_boxplot(outlier.alpha = 0.5, outlier.size = 0.8, alpha = 0.8) +
      labs(
        x = "Animal Group",
        y = paste(m, "(", measure_units[[tolower(m)]], ")"),
        title = paste("Distribution Comparison:", m, "by Group"),
        fill = "Group"
      ) +
      theme_minimal(base_size = 11) +
      theme(
        plot.title = element_text(face = "plain", hjust = 0.5, color = "#1B4332", size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1, color = "#40360c", size = 9),
        axis.text.y = element_text(color = "#40360c", size = 9),
        axis.title = element_text(color = "#40360c", face = "plain", size = 10),
        panel.grid.minor = element_blank(),
        legend.position = "none"
      )
    
    # Simplified plotly rendering with explicit sizing
    ggplotly(p, tooltip = "text", height = 500, width = NULL) %>%
      layout(
        autosize = FALSE,
        margin = list(l = 50, r = 50, t = 50, b = 50),
        hoverlabel = list(
          bgcolor = "white",
          bordercolor = "#1B4332",
          font = list(color = "#40360c", size = 11)
        )
      )
  })
}

