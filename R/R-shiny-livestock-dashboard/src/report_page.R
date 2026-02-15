report_ui <- function(id) {
 ns <- NS(id)
 tagList(
   tags$style(HTML("
     .tall-section {
       height: 1000px;
       overflow-y: auto;
       padding: 30px;
       border: 1px solid #dee2e6;
       border-radius: 0.375rem;
       background-color: #f8f9fa;
       margin-bottom: 0px;
     }
     .section-header {
       font-weight: 600;
       color: #1B4332;
       margin-bottom: 10px;
       padding-bottom: 10px;
       border-bottom: 2px solid #1B4332;
       font-size: 1.2rem;
     }
     body {
       overflow-y: auto;
       height: auto;
       min-height: 100vh;
     }
     .main-content {
       overflow-y: visible;
       height: auto;
     }
     .container-fluid {
       overflow-y: auto;
       height: auto;
     }
   ")),
  
  # Export Section (Chart and Report)
   div(
     class = "tall-section",
     div(
       class = "row",
      # Export Chart - Left Side
       div(
        class = "col-md-6",
         div(
           class = "card h-100",
           div(
             class = "card-header",
             h5(
               div(icon("chart-bar", class = "me-2"), "Export Chart"), 
               class = "mb-0 text-white"
             )
           ),
           div(
             class = "card-body",
     selectInput(ns("chart_source"), "Chart Type",
                             c("Time Series", "Distribution", "Summary"), width = "100%"),
             br(),
             selectInput(ns("chart_format"), "Chart Format", c("PNG"), width = "100%"),
             br(),
             downloadButton(ns("download_chart"), "Download Chart", class = "btn btn-primary btn-lg", style = "width: 100%;")
           )
         )
      ),
      # Export Report - Right Side
      div(
        class = "col-md-6",
         div(
           class = "card h-100",
           div(
             class = "card-header",
             h5(
               div(icon("file-export", class = "me-2"), "Export Report"), 
               class = "mb-0 text-white"
             )
           ),
          div(
            class = "card-body",
            textInput(ns("report_filename"), "Report Filename", "", width = "100%"),
            br(),
            selectInput(ns("report_format"), "Report Format", 
                       c("PDF" = "PDF", "HTML" = "PRINT_HTML"), width = "100%"),
            tags$small("PDF: Basic PDF with text and statistics. HTML: HTML optimized for PDF conversion and online viewing.", 
                      style = "color: #666; font-style: italic;"),
            br(),
            checkboxGroupInput(
              ns("report_charts"), 
              "Include Charts:",
              choices = c(
                "Time Series" = "Time Series",
                "Distribution" = "Distribution", 
                "Cohorts" = "Cohorts",
                "Summary Statistics" = "Summary Statistics"
              ),
              selected = c("Distribution", "Summary Statistics")
            ),
            br(),
            downloadButton(ns("download_report"), "Download Report", class = "btn btn-success btn-lg", style = "width: 100%;")
           )
         )
       )
     )
   ),
   
   # Export status message
   br(),
   textOutput(ns("export_status")),
   
   # email automation section
     div(
       class = "tall-section",
       div(class = "section-header", 
           div(icon("clock", class = "me-2"), "Schedule Automated Reports")
       ),
     div(
       class = "row",
       div(
         class = "col-md-6",
         radioButtons(ns("email_mode"), "Email Mode", 
                      choices = list("Send Now" = "now", "Schedule" = "schedule"),
                      selected = "now", inline = TRUE),
         br(),
         conditionalPanel(
           condition = "input.email_mode == 'schedule'",
           ns = ns,
           selectInput(ns("report_frequency"), "Frequency", c("Daily", "Weekly", "Monthly"), width = "100%"),
           br()
         ),
         textInput(ns("report_email"), "Recipient Email", "", width = "100%"),
         br(),
         conditionalPanel(
           condition = "input.email_mode == 'schedule'",
           ns = ns,
           selectInput(ns("report_time"), "Send Time", 
                     choices = list(
                       "00:00" = "00:00",
                       "00:15" = "00:15", 
                       "00:30" = "00:30",
                       "00:45" = "00:45",
                       "01:00" = "01:00",
                       "01:15" = "01:15",
                       "01:30" = "01:30",
                       "01:45" = "01:45",
                       "02:00" = "02:00",
                       "02:15" = "02:15",
                       "02:30" = "02:30",
                       "02:45" = "02:45",
                       "03:00" = "03:00",
                       "03:15" = "03:15",
                       "03:30" = "03:30",
                       "03:45" = "03:45",
                       "04:00" = "04:00",
                       "04:15" = "04:15",
                       "04:30" = "04:30",
                       "04:45" = "04:45",
                       "05:00" = "05:00",
                       "05:15" = "05:15",
                       "05:30" = "05:30",
                       "05:45" = "05:45",
                       "06:00" = "06:00",
                       "06:15" = "06:15",
                       "06:30" = "06:30",
                       "06:45" = "06:45",
                       "07:00" = "07:00",
                       "07:15" = "07:15",
                       "07:30" = "07:30",
                       "07:45" = "07:45",
                       "08:00" = "08:00",
                       "08:15" = "08:15",
                       "08:30" = "08:30",
                       "08:45" = "08:45",
                       "09:00" = "09:00",
                       "09:15" = "09:15",
                       "09:30" = "09:30",
                       "09:45" = "09:45",
                       "10:00" = "10:00",
                       "10:15" = "10:15",
                       "10:30" = "10:30",
                       "10:45" = "10:45",
                       "11:00" = "11:00",
                       "11:15" = "11:15",
                       "11:30" = "11:30",
                       "11:45" = "11:45",
                       "12:00" = "12:00",
                       "12:15" = "12:15",
                       "12:30" = "12:30",
                       "12:45" = "12:45",
                       "13:00" = "13:00",
                       "13:15" = "13:15",
                       "13:30" = "13:30",
                       "13:45" = "13:45",
                       "14:00" = "14:00",
                       "14:15" = "14:15",
                       "14:30" = "14:30",
                       "14:45" = "14:45",
                       "15:00" = "15:00",
                       "15:15" = "15:15",
                       "15:30" = "15:30",
                       "15:45" = "15:45",
                       "16:00" = "16:00",
                       "16:15" = "16:15",
                       "16:30" = "16:30",
                       "16:45" = "16:45",
                       "17:00" = "17:00",
                       "17:15" = "17:15",
                       "17:30" = "17:30",
                       "17:45" = "17:45",
                       "18:00" = "18:00",
                       "18:15" = "18:15",
                       "18:30" = "18:30",
                       "18:45" = "18:45",
                       "19:00" = "19:00",
                       "19:15" = "19:15",
                       "19:30" = "19:30",
                       "19:45" = "19:45",
                       "20:00" = "20:00",
                       "20:15" = "20:15",
                       "20:30" = "20:30",
                       "20:45" = "20:45",
                       "21:00" = "21:00",
                       "21:15" = "21:15",
                       "21:30" = "21:30",
                       "21:45" = "21:45",
                       "22:00" = "22:00",
                       "22:15" = "22:15",
                       "22:30" = "22:30",
                       "22:45" = "22:45",
                       "23:00" = "23:00",
                       "23:15" = "23:15",
                       "23:30" = "23:30",
                       "23:45" = "23:45"
                     ),
                     selected = sprintf("%02d:%02d", hour(Sys.time()), floor(minute(Sys.time())/15)*15),
                     width = "100%"),
         br()
         )
       ),
       div(
         class = "col-md-6",
         div(
           class = "card h-100",
           div(
             class = "card-header",
             h5(
               div(icon("cog", class = "me-2"), "Chart Options"), 
               class = "mb-0 text-white"
             )
           ),
           div(
             class = "card-body",
      tags$label("Select Charts to Include:", class = "form-label"),
      checkboxGroupInput(
        ns("report_chart_types"), 
        NULL,
        choices = c(
          "Time Series" = "Time Series",
          "Distribution" = "Distribution", 
          "Cohorts" = "Cohorts",
          "Summary Statistics" = "Summary Statistics"
        ),
               selected = c("Distribution")
             ),
             br(),
             div(
               class = "d-grid gap-2",
               conditionalPanel(
                 condition = "input.email_mode == 'now'",
                 ns = ns,
                 actionButton(ns("send_now"), "Send Now", class = "btn btn-primary btn-lg")
               ),
               conditionalPanel(
                 condition = "input.email_mode == 'schedule'",
                 ns = ns,
                 actionButton(ns("schedule_report"), "Schedule Report", class = "btn btn-success btn-lg")
               )
             )
           )
         )
       )
     ),
     br(),
     div(
       class = "alert alert-info",
    textOutput(ns("schedule_status"))
     ),
     
     br(),
     div(
       class = "mt-4",
         div(
           class = "section-header d-flex justify-content-between align-items-center",
           div(icon("list", class = "me-2"), "Manage Scheduled Emails"),
         div(
           actionButton(ns("refresh_schedules"), "Refresh", 
                       class = "btn btn-sm btn-outline-primary me-2",
                       icon = icon("refresh")),
           actionButton(ns("force_send_emails"), "Force Send All", 
                       class = "btn btn-sm btn-danger",
                       icon = icon("bolt")),
         )
       ),
       # Data table
       DT::dataTableOutput(ns("schedules_table")),
       br(),
       # Action dropdown below the table
       div(
         class = "mt-4",
         uiOutput(ns("schedule_actions"))
       )
     )
   )
 )
}


report_server <- function(id, filtered, grouped_data, measure_sel, is_admin) {
 moduleServer(id, function(input, output, session) {
   ns <- session$ns


# nocov start
   generate_filename <- function(base_name, ext, input) {
     filters <- c(
       paste0("year-", ifelse(is.null(input$year), "all", input$year)),
       paste0("sex-", ifelse(length(input$sex) == 0, "all", paste(input$sex, collapse = "_"))),
       paste0("breed-", ifelse(length(input$breed) == 0, "all", paste(input$breed, collapse = "_")))
     )
     paste0(
       ifelse(base_name == "", paste(filters, collapse = "_"), base_name),
       "_", format(Sys.Date(), "%Y%m%d"),
       ".", ext
     )
   }
  # nocov end



   # chart export
   output$download_chart <- downloadHandler(
     filename = function() {
      # Only PNG format supported
      # nocov start
      paste0("chart_", input$chart_source, "_", format(Sys.Date(), "%Y%m%d"), ".png")
     },
     content = function(file) {
       df <- filtered()
       shiny::validate(shiny::need(nrow(df) > 0, "No data to export."))

       available_cols <- names(df)
       date_col <- names(df)[grepl("date|time|record", names(df), ignore.case = TRUE)][1]
       weight_col <- names(df)[grepl("weight|mass|value|amount", names(df), ignore.case = TRUE)][1]
       breed_col <- names(df)[grepl("breed|type|class|category", names(df), ignore.case = TRUE)][1]

       p <- switch(input$chart_source,
         "Time Series" = {
           # Use the same logic as the main time series page
           df_combined <- grouped_data()
           if (!is.null(df_combined) && nrow(df_combined) > 0) {
             m <- measure_sel()
             
             # Aggregate data by date and group (same as main time series page)
             df_daily <- df_combined |> 
               group_by(date, group) |>
               summarize(
                 value = mean(.data[[m]], na.rm=TRUE),
                 count = n(),
                 .groups="drop"
               )
             
             ggplot(df_daily, aes(x = date, y = value, color = group, group = group)) +
               geom_line(linewidth = 1) +
               geom_point(size = 2) +
               theme_minimal() +
               theme(
                 panel.background = element_rect(fill = "white", color = NA),
                 plot.background = element_rect(fill = "white", color = NA)
               ) +
               labs(x = "Date", y = paste(m, "(", measure_units[[tolower(m)]], ")"), 
                    title = "Time Series Chart", color = "Animal Group")
           } else {
             ggplot() +
               annotate("text", x = 0.5, y = 0.5,
                       label = "No data available for time series", size = 6) +
               theme_void()
           }
         },
         "Distribution" = {
           if (!is.null(weight_col)) {
             ggplot(df, aes(x = .data[[weight_col]])) +
               geom_histogram(bins = 30, fill = "#2c7fb8", color = "white") +
               theme_minimal() +
               theme(
                 panel.background = element_rect(fill = "white", color = NA),
                 plot.background = element_rect(fill = "white", color = NA)
               ) +
               labs(x = weight_col, title = "Distribution Chart")
           } else {
             ggplot() +
               annotate("text", x = 0.5, y = 0.5,
                       label = "Missing numeric column for distribution", size = 6) +
               theme_void()
           }
         },
         "Summary" = {
           if (!is.null(breed_col) && !is.null(weight_col)) {
             ggplot(df, aes(x = .data[[breed_col]], y = .data[[weight_col]])) +
               geom_boxplot(fill = "#74a9cf") +
               theme_minimal() +
               theme(
                 panel.background = element_rect(fill = "white", color = NA),
                 plot.background = element_rect(fill = "white", color = NA)
               ) +
               labs(x = breed_col, y = weight_col, title = "Summary Chart")
           } else {
             ggplot() +
               annotate("text", x = 0.5, y = 0.5,
                       label = "Missing breed or weight column", size = 6) +
               theme_void()
           }
         }
       )

      # Only PNG format supported (SVG removed to avoid svglite dependency)
         ggsave(file, p, width = 8, height = 5, dpi = 300, bg = "white")
     }
   )
   
   # report export
   output$download_report <- downloadHandler(
     filename = function() {
       base_name <- ifelse(input$report_filename == "", "livestock_report", input$report_filename)
       date_str <- format(Sys.Date(), "%Y%m%d")
       
       switch(input$report_format,
         "PDF" = paste0(base_name, "_", date_str, ".pdf"),
         "PRINT_HTML" = paste0(base_name, "_", date_str, ".html")
       )
     },
     content = function(file) {
       df <- filtered()
       shiny::validate(shiny::need(nrow(df) > 0, "No data available for report generation."))
       report_content_md <- generate_email_report(df, input, "summary")
       
       report_content <- convert_markdown_to_html(report_content_md)
       
       chart_files <- list()
       if (length(input$report_charts) > 0) {
         current_grouped_data <- grouped_data()
         current_measure <- measure_sel()
         
         for (chart_type in input$report_charts) {
           chart_file <- create_dashboard_chart(df, chart_type, input, 
                                              grouped_data = current_grouped_data, 
                                              measure_col = current_measure)
           if (!is.null(chart_file) && file.exists(chart_file)) {
             chart_files[[chart_type]] <- chart_file
           }
         }
       }
       
       if (input$report_format == "PDF") {
         tryCatch({
           pdf(file, width = 8.5, height = 11, paper = "letter")
           plot.new()
           par(mar = c(1, 1, 1, 1))
           
           text(0.5, 0.9, "LIVESTOCK DASHBOARD REPORT", cex = 2.5, font = 2)
           text(0.5, 0.85, paste("Generated on:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")), cex = 1.3)
           text(0.5, 0.8, paste("Total Records:", nrow(df)), cex = 1.3)
           
           stats <- generate_summary_stats(df)
           text(0.5, 0.7, "STATISTICS", cex = 1.8, font = 2)
           text(0.5, 0.65, paste("Mean:", stats$mean_value), cex = 1.2)
           text(0.5, 0.62, paste("Median:", stats$median_value), cex = 1.2)
           text(0.5, 0.59, paste("Minimum:", stats$min_value), cex = 1.2)
           text(0.5, 0.56, paste("Maximum:", stats$max_value), cex = 1.2)
           text(0.5, 0.53, paste("Standard Deviation:", stats$std_dev), cex = 1.2)
           
           filters <- generate_filter_summary(input)
           if (length(filters) > 0) {
             text(0.5, 0.45, "APPLIED FILTERS", cex = 1.8, font = 2)
             y_pos <- 0.4
             for (filter_name in names(filters)) {
               text(0.5, y_pos, paste(tools::toTitleCase(filter_name), ":", filters[[filter_name]]), cex = 1.1)
               y_pos <- y_pos - 0.03
             }
           }
           
           if (length(input$report_charts) > 0) {
             current_grouped_data <- grouped_data()
             current_measure <- measure_sel()
             
             for (chart_type in input$report_charts) {
               plot.new()
               par(mar = c(0.5, 0.5, 0.5, 0.5))
               
               text(0.5, 0.95, paste("CHART:", chart_type), cex = 0.8, font = 2)
               
               par(fig = c(0.1, 0.9, 0.3, 0.7), new = TRUE)
               
               tryCatch({
                 if (chart_type == "Distribution") {
                   numeric_cols <- sapply(df, is.numeric)
                   if (sum(numeric_cols) > 0) {
                     measure_col <- names(df)[numeric_cols][1]
                     hist(df[[measure_col]], 
                          main = paste("Distribution of", measure_col),
                          xlab = measure_col, 
                          ylab = "Frequency",
                          col = "lightblue",
                          border = "black",
                          breaks = 8,
                          cex.main = 0.6,
                          cex.lab = 0.5,
                          cex.axis = 0.4)
                   } else {
                     text(0.5, 0.5, "No numeric data available", cex = 0.4)
                   }
                   
                 } else if (chart_type == "Time Series") {
                   if (!is.null(current_grouped_data) && nrow(current_grouped_data) > 0) {
                     df_daily <- current_grouped_data |> 
                       group_by(date, group) |>
                       summarize(
                         value = mean(.data[[current_measure]], na.rm=TRUE),
                         count = n(),
                         .groups="drop"
                       )
                     
                     plot(df_daily$date, df_daily$value, 
                          type = "l", 
                          main = paste("Time Series of", current_measure),
                          xlab = "Date", 
                          ylab = current_measure,
                          col = "blue",
                          lwd = 1,
                          cex.main = 0.6,
                          cex.lab = 0.5,
                          cex.axis = 0.4)
                     
                     points(df_daily$date, df_daily$value, col = "red", pch = 19, cex = 0.4)
                   } else {
                     text(0.5, 0.5, "No grouped data available", cex = 0.4)
                   }
                   
                 } else if (chart_type == "Cohorts") {
                   numeric_cols <- sapply(df, is.numeric)
                   group_cols <- names(df)[grepl("breed|group|cohort|mob", names(df), ignore.case = TRUE)]
                   
                   if (sum(numeric_cols) > 0 && length(group_cols) > 0) {
                     measure_col <- names(df)[numeric_cols][1]
                     group_col <- group_cols[1]
                     
                     boxplot(df[[measure_col]] ~ df[[group_col]], 
                             main = paste("Cohort Analysis:", measure_col, "by", group_col),
                             xlab = group_col, 
                             ylab = measure_col,
                             col = "lightgreen",
                             border = "black",
                             cex.main = 0.6,
                             cex.lab = 0.5,
                             cex.axis = 0.4)
                   } else {
                     text(0.5, 0.5, "No suitable data for cohort analysis", cex = 0.4)
                   }
                   
                 } else if (chart_type == "Summary Statistics") {
                   par(fig = c(0.05, 0.95, 0.3, 0.7), new = TRUE)
                   par(mfrow = c(1, 2))
                   
                   hist(df[[measure_col]], 
                        main = "Distribution",
                        xlab = measure_col, 
                        ylab = "Frequency",
                        col = "lightblue",
                        border = "black",
                        cex.main = 0.6,
                        cex.lab = 0.5,
                        cex.axis = 0.4)
                   
                   boxplot(df[[measure_col]], 
                           main = "Summary",
                           ylab = measure_col,
                           col = "lightgreen",
                           border = "black",
                           cex.main = 0.6,
                           cex.lab = 0.5,
                           cex.axis = 0.4)
                   
                   par(mfrow = c(1, 1))
                 }
                 
               }, error = function(e) {
                 text(0.5, 0.5, paste("Error creating", chart_type, "chart"), cex = 0.4, col = "red")
                 text(0.5, 0.45, "For full visualization, use Print-Ready HTML format", cex = 0.3, col = "blue")
               })
               
               par(fig = c(0, 1, 0, 1))
             }
           }
           
           dev.off()
           
         }, error = function(e) {
           create_simple_pdf_report(df, input, report_content_md, chart_files, file)
         })
         
         for (chart_file in chart_files) {
           if (file.exists(chart_file)) unlink(chart_file)
         }
         
       } else if (input$report_format == "PRINT_HTML") {
         temp_html <- tempfile(fileext = ".html")
         
         html_content <- paste0(
           "<!DOCTYPE html>
           <html>
           <head>
             <title>Livestock Dashboard Report</title>
             <style>
               @media print {
                 body { margin: 0; }
                 .page-break { page-break-before: always; }
               }
               body { 
                 font-family: Arial, sans-serif; 
                 margin: 40px; 
                 line-height: 1.6; 
                 color: #333;
               }
               h1 { 
                 color: #1B4332; 
                 border-bottom: 2px solid #1B4332; 
                 padding-bottom: 10px; 
                 margin-top: 0;
               }
               h2 { 
                 color: #2c7fb8; 
                 margin-top: 30px; 
                 margin-bottom: 15px;
               }
               h3 { 
                 color: #74a9cf; 
                 margin-bottom: 10px;
               }
               .stats-table { 
                 border-collapse: collapse; 
                 width: 100%; 
                 margin: 20px 0; 
                 border: 1px solid #ddd;
               }
               .stats-table th, .stats-table td { 
                 border: 1px solid #ddd; 
                 padding: 8px; 
                 text-align: left; 
               }
               .stats-table th { 
                 background-color: #f2f2f2; 
                 font-weight: bold;
               }
               .chart-container { 
                 text-align: center; 
                 margin: 20px 0; 
                 page-break-inside: avoid;
               }
               .chart-container img { 
                 max-width: 100%; 
                 height: auto; 
                 border: 1px solid #ddd;
                 border-radius: 4px;
               }
               .filters { 
                 background-color: #f8f9fa; 
                 padding: 15px; 
                 border-radius: 5px; 
                 margin: 20px 0; 
                 border-left: 4px solid #1B4332;
               }
               .report-header {
                 text-align: center;
                 margin-bottom: 30px;
                 padding-bottom: 20px;
                 border-bottom: 2px solid #1B4332;
               }
             </style>
           </head>
           <body>
           <div class='report-header'>
             <h1>Livestock Dashboard Report</h1>
             <p>Generated on: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "</p>
           </div>",
           report_content
         )
         
         if (length(chart_files) > 0) {
           html_content <- paste0(html_content, "<h2>Data Visualizations</h2>")
           for (chart_type in names(chart_files)) {
             chart_file <- chart_files[[chart_type]]
             img_data <- readBin(chart_file, "raw", file.info(chart_file)$size)
             img_base64 <- base64enc::base64encode(img_data)
             html_content <- paste0(html_content, 
               "<div class='chart-container'>",
               "<h3>", chart_type, "</h3>",
               "<img src='data:image/png;base64,", img_base64, "' alt='", chart_type, " Chart'>",
               "</div>")
           }
         }
         
         html_content <- paste0(html_content, "</body></html>")
         writeLines(html_content, temp_html)
         
         print_js <- "
         <script>
           // Auto-print when opened (optional - user can disable)
           // window.onload = function() { window.print(); }
           
           // Add print button
           function addPrintButton() {
             var button = document.createElement('button');
             button.innerHTML = 'Print to PDF';
             button.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 1000; background: #1B4332; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-size: 14px;';
             button.onclick = function() { window.print(); };
             document.body.appendChild(button);
           }
           
           // Add the button when page loads
           if (document.readyState === 'loading') {
             document.addEventListener('DOMContentLoaded', addPrintButton);
           } else {
             addPrintButton();
           }
         </script>"
         
         # Enhanced print styling
         print_css <- "
         <style>
           @media print {
             body { margin: 0; font-size: 12px; }
             .no-print { display: none !important; }
             .page-break { page-break-before: always; }
             .chart-container { page-break-inside: avoid; }
             h1, h2, h3 { page-break-after: avoid; }
           }
           @media screen {
             .print-instructions {
               background: #e3f2fd;
               border: 1px solid #2196f3;
               border-radius: 5px;
               padding: 15px;
               margin: 20px 0;
               font-size: 14px;
             }
           }
         </style>"
         
         print_instructions <- "
         <div class='print-instructions no-print'>
           <h3>Convert to PDF - Easy Steps</h3>
           <div style='background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 5px; padding: 15px; margin: 10px 0;'>
             <p><strong>Important:</strong> This is a print-ready HTML file, not a PDF yet.</p>
             <p><strong>To create a PDF:</strong></p>
             <ol>
               <li><strong>Click the 'Print to PDF' button above</strong> (easiest method), or</li>
               <li>Use <strong>Ctrl+P</strong> (Windows) or <strong>Cmd+P</strong> (Mac)</li>
               <li>In the print dialog, select <strong>'Save as PDF'</strong> or <strong>'Print to PDF'</strong></li>
               <li>Choose your desired settings and save the PDF</li>
             </ol>
             <p><em>This file is optimized for PDF conversion with proper page breaks and professional styling.</em></p>
           </div>
         </div>"
         
         # Combine everything
         final_html <- gsub("</head>", paste0(print_css, "</head>"), html_content)
         final_html <- gsub("</body>", paste0(print_instructions, print_js, "</body>"), final_html)
         
         # Write the final HTML file
         writeLines(final_html, file)
         
         # Clean up
         unlink(temp_html)
         for (chart_file in chart_files) {
           if (file.exists(chart_file)) unlink(chart_file)
         }
         
       }
     }
   )
   



   #   observeEvent(input$schedule_report, {
   #   freq <- input$report_frequency
   #   email <- input$report_email
    
   #   # Safely handle timeInput (works with both shiny::timeInput and plain POSIXt)
   #   time_val <- input$report_time
   #   if (is.list(time_val) && all(c("hour", "min") %in% names(time_val))) {
   #     time <- sprintf("%02d:%02d", time_val$hour, time_val$min)
   #   } else if (inherits(time_val, "POSIXt")) {
   #     time <- format(time_val, "%H:%M")
   #   } else {
   #     time <- "Unknown time"
   #   }


   #   if (email == "") {
   #     output$schedule_status <- renderText("❌ Please enter a valid email address.")
   #     return()
   #   }


   #   output$schedule_status <- renderText({
   #     paste("✅", freq, "report scheduled for", email, "at", time)
   #   })
   # })


   # Email automation related


   observeEvent(input$schedule_report, {
     # Only proceed if in schedule mode
     if (input$email_mode != "schedule") {
       showNotification("Please select 'Schedule' mode to schedule reports", type = "warning")
       return()
     }

     recipient <- input$report_email
     freq <- input$report_frequency
     send_time <- input$report_time  # This is now a string like "14:30"

     if (recipient == "") {
       output$schedule_status <- renderText("Please enter a valid email address.")
       return()
     }


     email_fun <- function() {
       current_data <- filtered()
      current_grouped_data <- grouped_data()
      current_measure <- measure_sel()
       
       # generate report content
       report_content <- generate_email_report(current_data, input, "summary")
       
       # create charts
       chart_files <- list()
       if (nrow(current_data) > 0) {
         selected_chart_types <- input$report_chart_types
         if (length(selected_chart_types) > 0) {
           for (chart_type in selected_chart_types) {
            chart_file <- create_dashboard_chart(current_data, chart_type, input, 
                                               grouped_data = current_grouped_data, 
                                               measure_col = current_measure)
             if (!is.null(chart_file) && file.exists(chart_file)) {
               chart_files[[chart_type]] <- chart_file
             }
           }
         }
       }
       
       if (length(chart_files) > 0) {
         viz_section <- "\n\n## Data Visualization\n\n"
         
         for (chart_type in names(chart_files)) {
           chart_file <- chart_files[[chart_type]]
           
           # read the image file + convert
           img_data <- readBin(chart_file, "raw", file.info(chart_file)$size)
           img_base64 <- base64enc::base64encode(img_data)
           img_tag <- paste0('<img src="data:image/png;base64,', img_base64, '" style="max-width: 100%; height: auto; margin: 10px 0;">')
           
           viz_section <- paste0(viz_section, "### ", chart_type, "\n\n", img_tag, "\n\n")
         }
         
         email <- blastula::compose_email(
           body = md(paste0(report_content, viz_section)),
           footer = md("Generated by Livestock Dashboard")
         )
         
         # add charts as attachments
         for (chart_type in names(chart_files)) {
           chart_file <- chart_files[[chart_type]]
           filename <- paste0(gsub(" ", "_", tolower(chart_type)), ".png")
           email <- email %>% blastula::add_attachment(chart_file, filename = filename)
         }
         
       } else {
         email <- blastula::compose_email(
           body = md(report_content),
           footer = md("Generated by Livestock Dashboard")
         )
       }
       
       # send email
       blastula::smtp_send(
         email,
         from = "sarahaikositompul0625@gmail.com",
         to = recipient,
         subject = paste("Livestock Dashboard Report -", Sys.Date()),
         credentials = blastula::creds_key("weekly_report_email")
       )
       
       for (chart_file in chart_files) {
         if (!is.null(chart_file) && file.exists(chart_file)) {
           unlink(chart_file)
         }
       }
     }

     # report filters
     report_filters <- list(
       chart_types = input$report_chart_types
     )
     
     day_of_week <- NULL
     day_of_month <- NULL
     
     if (freq == "Weekly") {
       day_of_week <- lubridate::wday(Sys.Date())
     } else if (freq == "Monthly") {
       day_of_month <- lubridate::day(Sys.Date())
     }
     
    schedule_result <- tryCatch({
      schedule_email_report(recipient, tolower(freq), send_time, email_fun, 
                           schedule_name = paste(freq, "Report for", recipient),
                           email_subject = paste("Livestock Dashboard Report -", Sys.Date()),
                           report_filters = report_filters,
                           day_of_week = day_of_week,
                           day_of_month = day_of_month)
    }, error = function(e) {
      cat("Error creating schedule:", e$message, "\n")
      return(paste("❌ Failed to create schedule:", e$message))
    })
    
    cat("Schedule creation result:", schedule_result, "\n")
      # nocov end
     
    output$schedule_status <- renderText({ # nocov start
       time_str <- tryCatch({
         if (is.null(send_time)) {
           format(Sys.time(), "%H:%M")
        } else if (is.character(send_time)) {
          send_time
         } else if (inherits(send_time, "POSIXt")) {
           format(send_time, "%H:%M")
         } else if (is.list(send_time) && all(c("hour", "min") %in% names(send_time))) {
           sprintf("%02d:%02d", send_time$hour, send_time$min)
         } else {
           format(Sys.time(), "%H:%M")
         }
       }, error = function(e) {
         "Unknown time"
       })
       
       selected_charts <- input$report_chart_types
       chart_info <- if (length(selected_charts) > 0) {
         paste0(" with ", length(selected_charts), " chart(s): ", paste(selected_charts, collapse = ", "))
       } else {
         " (no charts selected)"
       }
      if (grepl("✅", schedule_result)) {
        paste0("✅ ", freq, " report scheduled for ", recipient, " at ", time_str, chart_info)
      } else {
        paste0("❌ ", schedule_result)
      }
    }) # nocov end
    
    schedule_update_trigger(schedule_update_trigger() + 1)
   })
   
   # Send Now button - send email immediately
   # nocov start
   observeEvent(input$send_now, {
     # Only proceed if in now mode
     if (input$email_mode != "now") {
       showNotification("Please select 'Send Now' mode to send immediately", type = "warning")
       return()
     }
     
     recipient <- input$report_email
     
     if (recipient == "") {
       output$schedule_status <- renderText("Please enter a valid email address.")
       return()
     }
     
     showNotification("Sending email now...", type = "message")
     
     tryCatch({
       # Create email function for immediate sending
       email_fun <- function() {
         current_data <- filtered()
         current_grouped_data <- grouped_data()
         current_measure <- measure_sel()
         
         # Generate report content
         report_content <- generate_email_report(current_data, input, "summary")
         
         # Create charts
         chart_files <- list()
         if (nrow(current_data) > 0) {
           selected_chart_types <- input$report_chart_types
           if (length(selected_chart_types) > 0) {
             for (chart_type in selected_chart_types) {
               chart_file <- create_dashboard_chart(current_data, chart_type, input, 
                                                  grouped_data = current_grouped_data, 
                                                  measure_col = current_measure)
               if (!is.null(chart_file) && file.exists(chart_file)) {
                 chart_files[[chart_type]] <- chart_file
               }
             }
           }
         }
         
         if (length(chart_files) > 0) {
           viz_section <- "\n\n## Data Visualization\n\n"
           
           for (chart_type in names(chart_files)) {
             chart_file <- chart_files[[chart_type]]
             
             # Read the image file and convert to base64
             img_data <- readBin(chart_file, "raw", file.info(chart_file)$size)
             img_base64 <- base64enc::base64encode(img_data)
             img_tag <- paste0('<img src="data:image/png;base64,', img_base64, '" style="max-width: 100%; height: auto; margin: 10px 0;">')
             
             viz_section <- paste0(viz_section, "### ", chart_type, "\n\n", img_tag, "\n\n")
           }
           
           email <- blastula::compose_email(
             body = blastula::md(paste0(report_content, viz_section)),
             footer = blastula::md("Generated by Livestock Dashboard")
           )
           
           # Add charts as attachments
           for (chart_type in names(chart_files)) {
             chart_file <- chart_files[[chart_type]]
             filename <- paste0(gsub(" ", "_", tolower(chart_type)), ".png")
             email <- email %>% blastula::add_attachment(chart_file, filename = filename)
           }
           
         } else {
           email <- blastula::compose_email(
             body = blastula::md(report_content),
             footer = blastula::md("Generated by Livestock Dashboard")
           )
         }
         
         # Send the email
         blastula::smtp_send(
           email,
           from = "sarahaikositompul0625@gmail.com",
           to = recipient,
           subject = paste("Livestock Dashboard Report -", Sys.Date()),
           credentials = blastula::creds_key("weekly_report_email")
         )
         
         # Clean up chart files
         for (chart_file in chart_files) {
           if (!is.null(chart_file) && file.exists(chart_file)) {
             unlink(chart_file)
           }
         }
       }
       
       # Send the email immediately
       email_fun()
       
       output$schedule_status <- renderText({
         selected_charts <- input$report_chart_types
         chart_info <- if (length(selected_charts) > 0) {
           paste0(" with ", length(selected_charts), " chart(s): ", paste(selected_charts, collapse = ", "))
         } else {
           " (no charts selected)"
         }
         paste0("✅ Email sent immediately to ", recipient, chart_info)
       })
       
       showNotification("✅ Email sent successfully!", type = "message")
       
     }, error = function(e) {
       output$schedule_status <- renderText(paste("❌ Error sending email:", e$message))
       showNotification(paste("❌ Error sending email:", e$message), type = "error")
     })
   })
   
   # ---- Scheduled Email Management ----
   schedules_data <- reactive({
     trigger_value <- schedule_update_trigger()
     cat("schedules_data reactive triggered with value:", trigger_value, "\n")
     
     if (!is_admin()) {
       return(data.frame(Message = "Access restricted to administrators only."))
     }
     
     tryCatch({
       schedules <- get_email_schedules(active_only = FALSE)
       cat("Retrieved", nrow(schedules), "schedules from database\n")
       
       if (nrow(schedules) == 0) {
         return(data.frame(Message = "No scheduled reports found."))
       }
       
       display_data <- schedules %>%
         mutate(
           Frequency = case_when(
             frequency == "daily" ~ "Daily",
             frequency == "weekly" ~ paste("Weekly (Day", day_of_week, ")"),
             frequency == "monthly" ~ paste("Monthly (Day", day_of_month, ")"),
             frequency == "once" ~ paste("One-time (", send_date, ")"),
             TRUE ~ frequency
           ),
           Status = ifelse(is_active, "Active", "Inactive"),
           `Last Sent` = ifelse(is.na(last_sent), "Never", 
                               format(with_tz(as.POSIXct(last_sent, tz = "UTC"), "Australia/Sydney"), "%Y-%m-%d %H:%M")),
           Created = format(with_tz(as.POSIXct(created_at, tz = "UTC"), "Australia/Sydney"), "%Y-%m-%d %H:%M"),
           `Send Time` = sapply(send_time, function(time_val) {
             if (is.na(time_val)) {
               "Not set"
             } else if (grepl("^\\d{2}:\\d{2}:\\d{2}$", time_val)) {
               time_val 
             } else if (grepl("^\\d{2}:\\d{2}$", time_val)) {
               paste0(time_val, ":00") 
             } else if (grepl("^\\d+$", time_val)) {
               time_val_num <- as.numeric(time_val)
               hours <- floor(time_val_num / 3600)
               minutes <- floor((time_val_num %% 3600) / 60)
               seconds <- time_val_num %% 60
               sprintf("%02d:%02d:%02d", hours, minutes, seconds)
             } else if (is.numeric(time_val)) {
               hours <- floor(time_val / 3600)
               minutes <- floor((time_val %% 3600) / 60)
               seconds <- time_val %% 60
               sprintf("%02d:%02d:%02d", hours, minutes, seconds)
             } else {
               as.character(time_val)
             }
           })
         ) %>%
         select(
           ID = id,
           `Recipient Email` = recipient_email,
           Frequency,
           `Send Time`,
           Status,
           `Email Subject` = email_subject,
           `Created By` = created_by,
           Created,
           `Last Sent`
         )
       
       return(display_data)
       
     }, error = function(e) {
       return(data.frame(Error = paste("Error loading schedules:", e$message)))
     })
   })
   
   output$schedules_table <- DT::renderDT({
     data <- schedules_data()
     cat("Rendering table with", nrow(data), "rows\n")
     data
   }, 
   options = list(
     pageLength = 10,
     scrollX = TRUE,
     dom = 'Bfrtip',
     buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
   ),
   escape = FALSE,
   server = FALSE)
   
   output$schedule_actions <- renderUI({
     if (!is_admin()) {
       return(div("Access restricted to administrators only."))
     }
     
     tryCatch({
       schedules <- get_email_schedules(active_only = FALSE)
       
       if (nrow(schedules) == 0) {
         return(div("No scheduled reports found."))
       }
       
      schedule_options <- setNames(
        schedules$id, 
        paste0(
          "ID: ", schedules$id, " | ",
          schedules$recipient_email,
          " | ", schedules$frequency,
          " | ", ifelse(schedules$is_active, "Active", "Inactive")
        )
      )
       
       div(
         class = "card",
         div(
           class = "card-header",
           h5("Manage Schedules", class = "mb-0")
         ),
         div(
           class = "card-body",
           div(
             class = "row",
             div(
               class = "col-md-8",
               selectInput(
                 ns("selected_schedule"),
                 "Select Schedule to Manage (ID | Email | Frequency | Status):",
                 choices = schedule_options,
                 width = "100%"
               )
             ),
             div(
               class = "col-md-4",
               div(
                 textInput(
                   ns("search_schedule_id"),
                   "Quick Search by ID:",
                   placeholder = "Enter schedule ID",
                   width = "100%"
                 ),
                 actionButton(
                   ns("clear_search"),
                   "Clear",
                   class = "btn btn-sm btn-outline-secondary mt-1",
                   icon = icon("times")
                 )
               )
             ),
             div(
               class = "col-md-6",
               div(
                 class = "btn-group",
                 role = "group",
                 actionButton(
                   ns("activate_selected"),
                   "Activate",
                   class = "btn btn-success me-2"
                 ),
                 actionButton(
                   ns("deactivate_selected"),
                   "Deactivate", 
                   class = "btn btn-warning me-2"
                 ),
                 actionButton(
                   ns("delete_selected"),
                   "Delete",
                   class = "btn btn-danger"
                 )
               )
             )
           ),
           div(
             class = "mt-3",
             textOutput(ns("selected_schedule_info"))
           )
         )
       )
       
     }, error = function(e) {
       return(div(paste("Error loading schedules:", e$message), class = "alert alert-danger"))
     })
   })
   
  # Export status output
  output$export_status <- renderText({
    # This will be updated when exports complete
    ""
  })
  
  output$selected_schedule_info <- renderText({
    if (!is.null(input$selected_schedule) && input$selected_schedule != "") {
      schedules <- get_email_schedules(active_only = FALSE)
      schedule <- schedules[schedules$id == input$selected_schedule, ]
      
      if (nrow(schedule) > 0) {
        formatted_time <- if (is.na(schedule$send_time)) {
          "Not set"
        } else if (grepl("^\\d{2}:\\d{2}:\\d{2}$", schedule$send_time)) {
          schedule$send_time  
        } else if (grepl("^\\d{2}:\\d{2}$", schedule$send_time)) {
          paste0(schedule$send_time, ":00") 
        } else if (is.numeric(schedule$send_time)) {
          hours <- floor(schedule$send_time / 3600)
          minutes <- floor((schedule$send_time %% 3600) / 60)
          seconds <- schedule$send_time %% 60
          sprintf("%02d:%02d:%02d", hours, minutes, seconds)
        } else {
          as.character(schedule$send_time)
        }
        
        paste(
          "Selected Schedule ID: ", schedule$id,
          " | Recipient: ", schedule$recipient_email,
          " | Frequency: ", schedule$frequency,
          " | Send Time: ", formatted_time,
          " | Status: ", ifelse(schedule$is_active, "Active", "Inactive"),
          " | Last Sent: ", ifelse(is.na(schedule$last_sent), "Never", 
                                  format(as.POSIXct(schedule$last_sent), "%Y-%m-%d %H:%M"))
        )
      }
    } else {
      "Please select a schedule to manage"
    }
  })
   
   observeEvent(input$search_schedule_id, {
     if (!is.null(input$search_schedule_id) && input$search_schedule_id != "") {
       tryCatch({
         search_id <- as.numeric(input$search_schedule_id)
         if (!is.na(search_id)) {
           schedules <- get_email_schedules(active_only = FALSE)
           if (search_id %in% schedules$id) {
             updateSelectInput(session, "selected_schedule", selected = search_id)
             showNotification(paste("Found schedule ID:", search_id), type = "message")
           } else {
             showNotification(paste("Schedule ID", search_id, "not found"), type = "warning")
           }
         } else {
           showNotification("Please enter a valid numeric ID", type = "warning")
         }
       }, error = function(e) {
         showNotification(paste("Error searching for ID:", e$message), type = "error")
       })
     }
   })
   
   observeEvent(input$clear_search, {
     updateTextInput(session, "search_schedule_id", value = "")
     updateSelectInput(session, "selected_schedule", selected = "")
   })
   
   observeEvent(input$activate_selected, {
     if (!is.null(input$selected_schedule) && input$selected_schedule != "") {
       cat("Activating selected schedule ID:", input$selected_schedule, "\n")
       result <- update_schedule_status(input$selected_schedule, TRUE)
       showNotification(result, type = "message")
       schedule_update_trigger(schedule_update_trigger() + 1)
     } else {
       showNotification("Please select a schedule first", type = "warning")
     }
   })
   
   observeEvent(input$deactivate_selected, {
     if (!is.null(input$selected_schedule) && input$selected_schedule != "") {
       cat("Deactivating selected schedule ID:", input$selected_schedule, "\n")
       result <- update_schedule_status(input$selected_schedule, FALSE)
       showNotification(result, type = "message")
       schedule_update_trigger(schedule_update_trigger() + 1)
     } else {
       showNotification("Please select a schedule first", type = "warning")
     }
   })
   
   observeEvent(input$delete_selected, {
     if (!is.null(input$selected_schedule) && input$selected_schedule != "") {
       cat("Deleting selected schedule ID:", input$selected_schedule, "\n")
       result <- delete_email_schedule(input$selected_schedule)
       showNotification(result, type = "message")
       schedule_update_trigger(schedule_update_trigger() + 1)
     } else {
       showNotification("Please select a schedule first", type = "warning")
     }
   })
   
   observeEvent(input$refresh_schedules, {
     cat("Refresh button clicked\n")
     old_trigger <- schedule_update_trigger()
     new_trigger <- old_trigger + 1
     cat("Refreshing - updating trigger from", old_trigger, "to", new_trigger, "\n")
     schedule_update_trigger(new_trigger)
   })
   
   observeEvent(input$force_send_emails, {
     if (!is_admin()) {
       showNotification("Access restricted to administrators only", type = "warning")
       return()
     }
     
     showNotification("Force sending all emails... This may take a moment.", type = "message")
     
     tryCatch({
       force_send_test_emails()
       showNotification("✅ Force send completed! Check console for details.", type = "message")
       schedule_update_trigger(schedule_update_trigger() + 1)
     }, error = function(e) {
       showNotification(paste("❌ Error force sending emails:", e$message), type = "error")
     })
   })
   
   schedule_update_trigger <- reactiveVal(0)
   
   observeEvent(schedule_update_trigger(), {
     if (schedule_update_trigger() > 0) {
     }
   })
   
   current_action <- reactiveVal(list(type = NULL, schedule_id = NULL))
   
   observe({
     all_inputs <- reactiveValuesToList(input)
     delete_inputs <- all_inputs[grepl("^delete_\\d+$", names(all_inputs))]
     for (input_name in names(delete_inputs)) {
       if (delete_inputs[[input_name]] > 0) {
         schedule_id <- gsub("^delete_", "", input_name)
         cat("Delete button clicked for schedule ID:", schedule_id, "\n")
         
         schedules <- get_email_schedules(active_only = FALSE)
         schedule_info <- schedules[schedules$id == schedule_id, ]
         
         if (nrow(schedule_info) > 0) {
           cat("Proceeding with deletion of schedule ID:", schedule_id, "\n")
           result <- delete_email_schedule(schedule_id)
           cat("Deletion result:", result, "\n")
           showNotification(result, type = "message")
           schedule_update_trigger(schedule_update_trigger() + 1)
         }
       }
     }
     
     activate_inputs <- all_inputs[grepl("^activate_\\d+$", names(all_inputs))]
     for (input_name in names(activate_inputs)) {
       if (activate_inputs[[input_name]] > 0) {
         schedule_id <- gsub("^activate_", "", input_name)
         cat("Activate button clicked for schedule ID:", schedule_id, "\n")
         result <- update_schedule_status(schedule_id, TRUE)
         showNotification(result, type = "message")
         schedule_update_trigger(schedule_update_trigger() + 1)
       }
     }
     
     deactivate_inputs <- all_inputs[grepl("^deactivate_\\d+$", names(all_inputs))]
     for (input_name in names(deactivate_inputs)) {
       if (deactivate_inputs[[input_name]] > 0) {
         schedule_id <- gsub("^deactivate_", "", input_name)
         cat("Deactivate button clicked for schedule ID:", schedule_id, "\n")
         result <- update_schedule_status(schedule_id, FALSE)
         showNotification(result, type = "message")
         schedule_update_trigger(schedule_update_trigger() + 1)
       }
     }
   })
   # nocov end
  
 })
}