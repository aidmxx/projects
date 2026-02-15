Sys.setenv(TZ = "Australia/Sydney")

generate_summary_stats <- function(filtered_data) {
  if (is.null(filtered_data) || nrow(filtered_data) == 0) {
    return("No data available for the selected filters.")
  }
  
  numeric_cols <- sapply(filtered_data, is.numeric)
  if (sum(numeric_cols) == 0) {
    return("No numeric data available for summary.")
  }
  
  measure_col <- names(filtered_data)[numeric_cols][1]
  values <- filtered_data[[measure_col]]
  
  stats <- list(
    total_records = nrow(filtered_data),
    measure_name = measure_col,
    mean_value = round(mean(values, na.rm = TRUE), 2),
    median_value = round(median(values, na.rm = TRUE), 2),
    min_value = round(min(values, na.rm = TRUE), 2),
    max_value = round(max(values, na.rm = TRUE), 2),
    std_dev = round(sd(values, na.rm = TRUE), 2)
  )
  
  return(stats)
}

generate_filter_summary <- function(input) {
  filters <- list()
  
  if (!is.null(input$year)) {
    filters$year <- input$year
  }
  
  if (!is.null(input$month) && input$month != "All") {
    filters$month <- input$month
  }
  
  if (!is.null(input$day) && input$day != "All") {
    filters$day <- input$day
  }
  
  if (!is.null(input$sex) && length(input$sex) > 0 && !"Overall" %in% input$sex) {
    filters$sex <- paste(input$sex, collapse = ", ")
  }
  
  if (!is.null(input$treatment) && length(input$treatment) > 0 && !"Overall" %in% input$treatment) {
    filters$treatment <- paste(input$treatment, collapse = ", ")
  }
  
  if (!is.null(input$breed) && length(input$breed) > 0 && !"Overall" %in% input$breed) {
    filters$breed <- paste(input$breed, collapse = ", ")
  }
  
  if (!is.null(input$mob) && length(input$mob) > 0 && !"Overall" %in% input$mob) {
    filters$mob <- paste(input$mob, collapse = ", ")
  }
  
  return(filters)
}

create_dashboard_chart <- function(filtered_data, chart_type = "Distribution", input = NULL, measure_col = NULL, grouped_data = NULL) {
  if (nrow(filtered_data) == 0) {
    return(NULL)
  }
  
  if (is.null(measure_col)) {
    numeric_cols <- sapply(filtered_data, is.numeric)
    if (sum(numeric_cols) == 0) {
      return(NULL)
    }
    measure_col <- names(filtered_data)[numeric_cols][1]
  }
  # Validate measure_col
  if (is.null(measure_col) || is.na(measure_col) || !(measure_col %in% names(filtered_data))) {
    numeric_cols <- sapply(filtered_data, is.numeric)
    if (sum(numeric_cols) == 0) {
      return(NULL)
    }
    measure_col <- names(filtered_data)[numeric_cols][1]
  }
  
  temp_file <- tempfile(fileext = ".png")
  
  if (chart_type == "Distribution") {
    p <- ggplot(filtered_data, aes(x = .data[[measure_col]])) +
      geom_histogram(bins = 20, fill = "#2c7fb8", color = "white", alpha = 0.7) +
      labs(title = paste("Distribution of", measure_col),
           x = measure_col, y = "Frequency") +
      theme_minimal() +
      theme(
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA)
      )
    ggsave(temp_file, plot = p, width = 8, height = 5, dpi = 300, bg = "white")
    return(temp_file)
      
  } else if (chart_type == "Time Series") {
    # Use grouped data if available and has required columns (matches main time series page)
    if (!is.null(grouped_data) && nrow(grouped_data) > 0 && 
        "date" %in% names(grouped_data) && "group" %in% names(grouped_data)) {
      # Aggregate data by date and group (same as main time series page)
      df_daily <- grouped_data |> 
        group_by(date, group) |>
        summarize(
          value = mean(.data[[measure_col]], na.rm=TRUE),
          count = n(),
          .groups="drop"
        )
      
      p <- ggplot(df_daily, aes(x = date, y = value, color = group, group = group)) +
        geom_line(linewidth = 1) +
        geom_point(size = 2) +
        labs(title = paste("Time Series of", measure_col),
             x = "Date", y = measure_col, color = "Animal Group") +
        theme_minimal() +
        theme(
          panel.background = element_rect(fill = "white", color = NA),
          plot.background = element_rect(fill = "white", color = NA)
        )
    } else {
      # Fallback to simple aggregation if no grouped data
      date_matches <- names(filtered_data)[grepl("date|time|record", names(filtered_data), ignore.case = TRUE)]
      date_col <- if (length(date_matches) > 0) date_matches[1] else NA_character_
      if (!is.null(date_col) && !is.na(date_col)) {
        # Properly aggregate data by date to avoid spiky appearance
        daily_data <- filtered_data %>%
          group_by(.data[[date_col]]) %>%
          summarise(
            avg_value = mean(.data[[measure_col]], na.rm = TRUE),
            count = n(),
            .groups = "drop"
          ) %>%
          # Sort by date to ensure proper line connection
          arrange(.data[[date_col]])
        
        p <- ggplot(daily_data, aes(x = .data[[date_col]], y = avg_value)) +
          geom_line(color = "#2c7fb8", linewidth = 1) +
          geom_point(color = "#2c7fb8", size = 2) +
          labs(title = paste("Time Series of", measure_col),
               x = "Date", y = measure_col) +
          theme_minimal() +
          theme(
            panel.background = element_rect(fill = "white", color = NA),
            plot.background = element_rect(fill = "white", color = NA)
          )
      } else {
        p <- ggplot(filtered_data, aes(x = seq_along(.data[[measure_col]]), y = .data[[measure_col]])) +
          geom_line(color = "#2c7fb8", linewidth = 1) +
          labs(title = paste("Trend of", measure_col),
               x = "Record Number", y = measure_col) +
          theme_minimal() +
          theme(
            panel.background = element_rect(fill = "white", color = NA),
            plot.background = element_rect(fill = "white", color = NA)
          )
      }
    }
    ggsave(temp_file, plot = p, width = 8, height = 5, dpi = 300, bg = "white")
    return(temp_file)
    
  } else if (chart_type == "Cohorts") {
    group_matches <- names(filtered_data)[grepl("breed|group|cohort|mob", names(filtered_data), ignore.case = TRUE)]
    group_col <- if (length(group_matches) > 0) group_matches[1] else NA_character_
    if (!is.null(group_col) && !is.na(group_col)) {
      p <- ggplot(filtered_data, aes(x = .data[[group_col]], y = .data[[measure_col]])) +
        geom_boxplot(fill = "#74a9cf", color = "#2c7fb8") +
        labs(title = paste("Cohort Analysis:", measure_col, "by", group_col),
             x = group_col, y = measure_col) +
        theme_minimal() +
        theme(
          panel.background = element_rect(fill = "white", color = NA),
          plot.background = element_rect(fill = "white", color = NA),
          axis.text.x = element_text(angle = 45, hjust = 1)
        )
    } else {
      p <- ggplot(filtered_data, aes(y = .data[[measure_col]])) +
        geom_boxplot(fill = "#74a9cf", color = "#2c7fb8") +
        labs(title = paste("Box Plot of", measure_col),
             y = measure_col) +
        theme_minimal() +
        theme(
          panel.background = element_rect(fill = "white", color = NA),
          plot.background = element_rect(fill = "white", color = NA)
        )
    }
    ggsave(temp_file, plot = p, width = 8, height = 5, dpi = 300, bg = "white")
    return(temp_file)
    
  } else if (chart_type == "Summary Statistics") {
    stats <- generate_summary_stats(filtered_data)
    values <- filtered_data[[measure_col]]
    p1 <- ggplot(data.frame(value = values), aes(x = value)) +
      geom_histogram(bins = 20, fill = "#2c7fb8", color = "white", alpha = 0.7) +
      labs(title = "Distribution", x = measure_col, y = "Frequency") +
      theme_minimal()
    p2 <- ggplot(data.frame(value = values), aes(y = value)) +
      geom_boxplot(fill = "#74a9cf", color = "#2c7fb8") +
      labs(title = "Summary", y = measure_col) +
      theme_minimal()
    p <- gridExtra::grid.arrange(p1, p2, ncol = 2)
    ggsave(temp_file, plot = p, width = 12, height = 6, dpi = 300, bg = "white")
    return(temp_file)
  }
  return(NULL)
}

generate_email_report <- function(filtered_data, input, report_type = "summary") {
  stats <- generate_summary_stats(filtered_data)
  filters <- generate_filter_summary(input)
  
  if (report_type == "summary") {
    report_content <- paste0(
      "# Livestock Dashboard - Automated Report\n\n",
      "## Report Summary\n\n",
      "**Generated on:** ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n",
      "**Total Records:** ", stats$total_records, "\n\n",
      "**Measure:** ", stats$measure_name, "\n\n",
      "## Statistics\n\n",
      "- **Mean:** ", stats$mean_value, "\n",
      "- **Median:** ", stats$median_value, "\n",
      "- **Minimum:** ", stats$min_value, "\n",
      "- **Maximum:** ", stats$max_value, "\n",
      "- **Standard Deviation:** ", stats$std_dev, "\n\n"
    )
    
    if (length(filters) > 0) {
      report_content <- paste0(report_content, "## Applied Filters\n\n")
      for (filter_name in names(filters)) {
        report_content <- paste0(report_content, "- **", 
                               tools::toTitleCase(filter_name), ":** ", 
                               filters[[filter_name]], "\n")
      }
      report_content <- paste0(report_content, "\n")
    }
    
    report_content <- paste0(report_content,
      "## Data Quality\n\n",
      "This report is based on the current filter settings in your dashboard. ",
      "The data represents the filtered dataset as of the report generation time.\n\n"
    )
    
  } else {
    report_content <- paste0(
      "# Livestock Dashboard - Detailed Report\n\n",
      "## Overview\n\n",
      "This is a detailed automated report from your Livestock Dashboard.\n\n",
      "**Report Date:** ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
      "**Records Analyzed:** ", stats$total_records, "\n\n"
    )
  }
  
  return(report_content)
}

convert_markdown_to_html <- function(markdown_text) {
  # Split into lines for processing
  lines <- strsplit(markdown_text, "\n")[[1]]
  result_lines <- c()
  in_list <- FALSE
  
  for (i in seq_along(lines)) {
    line <- lines[i]
    
    # Process headers
    if (grepl("^# ", line)) {
      line <- gsub("^# (.*)$", "<h1>\\1</h1>", line)
    } else if (grepl("^## ", line)) {
      line <- gsub("^## (.*)$", "<h2>\\1</h2>", line)
    } else if (grepl("^### ", line)) {
      line <- gsub("^### (.*)$", "<h3>\\1</h3>", line)
    }
    
    # Process bold text
    line <- gsub("\\*\\*(.*?)\\*\\*", "<strong>\\1</strong>", line)
    
    # Process list items
    if (grepl("^- ", line)) {
      line <- gsub("^- (.*)$", "<li>\\1</li>", line)
      
      # Handle list wrapping
      if (!in_list) {
        result_lines <- c(result_lines, "<ul>")
        in_list <- TRUE
      }
    } else {
      # Not a list item, close list if we were in one
      if (in_list) {
        result_lines <- c(result_lines, "</ul>")
        in_list <- FALSE
      }
    }
    
    result_lines <- c(result_lines, line)
  }
  
  # Close list if still in one
  if (in_list) {
    result_lines <- c(result_lines, "</ul>")
  }
  
  # Join lines and convert newlines to <br>
  html_text <- paste(result_lines, collapse = "\n")
  html_text <- gsub("\n", "<br>\n", html_text)
  
  return(html_text)
}


create_simple_pdf_report <- function(df, input, report_content_md, chart_files, file) {
  stats <- generate_summary_stats(df)
  filters <- generate_filter_summary(input)
  
  text_content <- paste0(
    "LIVESTOCK DASHBOARD REPORT\n",
    "========================\n\n",
    "Generated on: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n",
    "REPORT SUMMARY\n",
    "==============\n",
    "Total Records: ", stats$total_records, "\n",
    "Measure: ", stats$measure_name, "\n\n",
    "STATISTICS\n",
    "==========\n",
    "Mean: ", stats$mean_value, "\n",
    "Median: ", stats$median_value, "\n",
    "Minimum: ", stats$min_value, "\n",
    "Maximum: ", stats$max_value, "\n",
    "Standard Deviation: ", stats$std_dev, "\n\n"
  )
  
  if (length(filters) > 0) {
    text_content <- paste0(text_content, "APPLIED FILTERS\n", "===============\n")
    for (filter_name in names(filters)) {
      text_content <- paste0(text_content, tools::toTitleCase(filter_name), ": ", filters[[filter_name]], "\n")
    }
    text_content <- paste0(text_content, "\n")
  }
  
  text_content <- paste0(text_content,
    "DATA QUALITY\n",
    "============\n",
    "This report is based on the current filter settings in your dashboard.\n",
    "The data represents the filtered dataset as of the report generation time.\n\n"
  )
  
  if (length(chart_files) > 0) {
    text_content <- paste0(text_content, "CHARTS INCLUDED\n", "===============\n")
    for (chart_type in names(chart_files)) {
      text_content <- paste0(text_content, "- ", chart_type, "\n")
    }
    text_content <- paste0(text_content, "\n")
  }
  
  writeLines(text_content, file)
}
