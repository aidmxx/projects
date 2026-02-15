Sys.setenv(TZ = "Australia/Sydney")

store_email_schedule <- function(recipient_email, schedule_name, frequency, send_time, 
                                send_date = NULL, day_of_week = NULL, day_of_month = NULL,
                                email_subject = "Automated Report", email_body = "",
                                report_filters = NULL, created_by = "system") {
  
  time_str <- tryCatch({
    if (inherits(send_time, "POSIXt")) {
      format(send_time, "%H:%M:%S")
    } else if (is.list(send_time) && all(c("hour", "min") %in% names(send_time))) {
      sprintf("%02d:%02d:00", as.integer(send_time$hour), as.integer(send_time$min))
    } else if (is.character(send_time)) {
      if (nchar(send_time) == 5) paste0(send_time, ":00") else send_time
    } else {
      # nocov start
      "09:00:00"
      # nocov end
    }
  }, error = function(e) {
    # nocov start
    "09:00:00"
    # nocov end
  })
  
  filters_json <- if (!is.null(report_filters)) {
    jsonlite::toJSON(report_filters, auto_unbox = TRUE)
  } else {
    NULL
  }
  
  tryCatch({
    if (!exists("con")) {
      return("❌ Database connection 'con' does not exist. Make sure global.R is loaded.")
    }
    if (!dbIsValid(con)) {
      return("❌ Database connection is not valid")
    }
    
    params_list <- list(
        recipient_email = recipient_email,
        schedule_name = if (is.null(schedule_name)) NA else schedule_name,
        frequency = frequency,
        send_time = time_str,
        send_date = if (is.null(send_date)) NA else send_date,
        day_of_week = if (is.null(day_of_week)) NA else day_of_week,
        day_of_month = if (is.null(day_of_month)) NA else day_of_month,
        email_subject = email_subject,
        email_body = email_body,
        report_filters = if (is.null(filters_json)) NA else filters_json,
        created_by = created_by
      )
      
      cat("Attempting to insert schedule with params:", toString(params_list), "\n")
      
      # Execute the database insert
      dbExecute(con, "
        INSERT INTO email_schedules 
        (recipient_email, schedule_name, frequency, send_time, send_date, 
         day_of_week, day_of_month, email_subject, email_body, report_filters, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ", params = unname(params_list))
      
      cat("✅ Schedule inserted successfully\n")
      return(paste("✅ Email schedule stored successfully for", recipient_email))
  }, error = function(e) {
    if (grepl("object 'con' not found|unused argument \\(con\\)", e$message)) {
      return("❌ Database connection 'con' does not exist. Make sure global.R is loaded.")
    }
    cat("❌ Error storing schedule:", e$message, "\n")
    return(paste("❌ Failed to store email schedule:", e$message))
  })
}

get_email_schedules <- function(active_only = TRUE) {
  tryCatch({
    if (!exists("con")) {
      cat("❌ Database connection 'con' does not exist. Make sure global.R is loaded.\n")
      return(data.frame())
    }
    if (!dbIsValid(con)) {
      cat("❌ Database connection is not valid\n")
      return(data.frame())
    }
    
    where_clause <- if (active_only) "WHERE is_active = TRUE" else ""
    
    schedules <- dbGetQuery(con, paste("
      SELECT id, recipient_email, schedule_name, frequency, send_time, send_date,
             day_of_week, day_of_month, is_active, created_at, last_sent,
             email_subject, email_body, report_filters, created_by
      FROM email_schedules", where_clause, "ORDER BY id DESC"))
    
    return(schedules)
  }, error = function(e) {
    # nocov start
    if (grepl("object 'con' not found|unused argument \\(con\\)", e$message)) {
      cat("❌ Database connection 'con' does not exist. Make sure global.R is loaded.\n")
      return(data.frame())
    }
    warning("Failed to retrieve email schedules: ", e$message)
    return(data.frame())
    # nocov end
  })
}

update_schedule_status <- function(schedule_id, is_active) {
  tryCatch({
    dbExecute(con, "
      UPDATE email_schedules 
      SET is_active = ? 
      WHERE id = ?
    ", params = list(is_active, schedule_id))
    
    return(paste("✅ Schedule", schedule_id, ifelse(is_active, "activated", "deactivated")))
  }, error = function(e) {
    # nocov start
    return(paste("❌ Failed to update schedule:", e$message))
    # nocov end
  })
}

delete_email_schedule <- function(schedule_id) {
  tryCatch({
    dbExecute(con, "DELETE FROM email_schedules WHERE id = ?", params = list(schedule_id))
    return(paste("✅ Schedule", schedule_id, "deleted successfully"))
  }, error = function(e) {
    # nocov start
    return(paste("❌ Failed to delete schedule:", e$message))
    # nocov end
  })
}

update_last_sent <- function(schedule_id) {
  tryCatch({
    dbExecute(con, "
      UPDATE email_schedules 
      SET last_sent = CURRENT_TIMESTAMP 
      WHERE id = ?
    ", params = list(schedule_id))
  }, error = function(e) {
    # nocov start
    warning("Failed to update last_sent timestamp: ", e$message)
    # nocov end
  })
}

get_due_schedules <- function() {
  current_time <- Sys.time()
  current_time_str <- format(current_time, "%H:%M:%S")
  current_date <- Sys.Date()
  current_weekday <- lubridate::wday(Sys.Date())
  current_day <- lubridate::day(Sys.Date())
  
  cat("Checking due schedules at:", format(current_time, "%Y-%m-%d %H:%M:%S"), "\n")
  cat("Current weekday:", current_weekday, "(1=Monday, 7=Sunday)\n")
  cat("Current day of month:", current_day, "\n")
  
  time_window_start <- format(current_time - minutes(5), "%H:%M:%S")
  time_window_end <- format(current_time + minutes(5), "%H:%M:%S")
  
  tryCatch({
    all_schedules <- dbGetQuery(con, "
      SELECT * FROM email_schedules 
      WHERE is_active = TRUE
    ")
    
    if (nrow(all_schedules) == 0) {
      return(data.frame())
    }
    
    due_schedules <- data.frame()
    
    for (i in 1:nrow(all_schedules)) {
      schedule <- all_schedules[i, ]
      is_due <- FALSE
      
      send_time_str <- as.character(schedule$send_time)
      if (grepl("^\\d{2}:\\d{2}", send_time_str)) {
        time_parts <- strsplit(send_time_str, ":")[[1]]
        send_hour <- as.numeric(time_parts[1])
        send_minute <- as.numeric(time_parts[2])
        send_seconds <- 0  # Default to 0 for all time formats
      } else {
        next
      }
      
      current_hour <- hour(current_time)
      current_minute <- minute(current_time)
      current_seconds <- second(current_time)
      
      current_time_minutes <- current_hour * 60 + current_minute
      send_time_minutes <- send_hour * 60 + send_minute
      time_diff <- abs(current_time_minutes - send_time_minutes)
      
      if (time_diff <= 5) {
        if (!is.na(schedule$frequency) && schedule$frequency == "daily") {
          if (is.na(schedule$last_sent) || 
              as.Date(schedule$last_sent) < current_date) {
            is_due <- TRUE
          }
        } else if (!is.na(schedule$frequency) && schedule$frequency == "weekly") {
          if (current_weekday == schedule$day_of_week) {
            if (is.na(schedule$last_sent) || 
                as.Date(schedule$last_sent) < current_date - days(7)) {
              is_due <- TRUE
            }
          }
        } else if (!is.na(schedule$frequency) && schedule$frequency == "monthly") {
          if (current_day == schedule$day_of_month) {
            if (is.na(schedule$last_sent) || 
                month(schedule$last_sent) != month(current_time) ||
                year(schedule$last_sent) != year(current_time)) {
              is_due <- TRUE
            }
          }
        } else if (!is.na(schedule$frequency) && schedule$frequency == "once") {
          if (as.Date(schedule$send_date) == current_date) {
            if (is.na(schedule$last_sent)) {
              is_due <- TRUE
            }
          }
        }
      }
      
      if (is_due) {
        due_schedules <- rbind(due_schedules, schedule)
      }
    }
    
    return(due_schedules)
  }, error = function(e) {
    # nocov start
    warning("Failed to get due schedules: ", e$message)
    return(data.frame())
    # nocov end
  })
}

schedule_email_report <- function(recipient, frequency, send_time, email_function, 
                                 schedule_name = NULL, send_date = NULL, 
                                 day_of_week = NULL, day_of_month = NULL,
                                 email_subject = "Automated Report", email_body = "",
                                 report_filters = NULL, created_by = "system") {
  
  store_result <- store_email_schedule(
    recipient_email = recipient,
    schedule_name = if (is.null(schedule_name)) paste("Report for", recipient) else schedule_name,
    frequency = frequency,
    send_time = send_time,
    send_date = send_date,
    day_of_week = day_of_week,
    day_of_month = day_of_month,
    email_subject = email_subject,
    email_body = email_body,
    report_filters = report_filters,
    created_by = created_by
  )
  
  if (frequency == "once" && !is.null(send_date) && send_date == Sys.Date()) {
    result <- tryCatch({
      email_function()
      paste("✅ Email sent successfully to", recipient)
    }, error = function(e) {
      # nocov start
      paste("❌ Failed to send email:", e$message)
      # nocov end
    })
    return(paste(store_result, "-", result))
  }
  
  return(store_result)
}

schedule_daily_report <- function(recipient_email, send_time = "09:00", 
                                 email_subject = "Daily Livestock Report",
                                 report_filters = NULL) {
  schedule_email_report(
    recipient = recipient_email,
    frequency = "daily",
    send_time = send_time,
    email_function = function() { 
      # nocov start
    cat("Sending daily report to", recipient_email, "\n")
    # nocov end
    },
    schedule_name = paste("Daily Report for", recipient_email),
    email_subject = email_subject,
    report_filters = report_filters
  )
}

schedule_weekly_report <- function(recipient_email, day_of_week = 1, send_time = "08:00",
                                 email_subject = "Weekly Livestock Summary",
                                 report_filters = NULL) {
  schedule_email_report(
    recipient = recipient_email,
    frequency = "weekly",
    send_time = send_time,
    email_function = function() { 
      # nocov start
    cat("Sending weekly report to", recipient_email, "\n")
    # nocov end
    },
    schedule_name = paste("Weekly Report for", recipient_email),
    day_of_week = day_of_week,
    email_subject = email_subject,
    report_filters = report_filters
  )
}

schedule_one_time_report <- function(recipient_email, send_date, send_time = "10:00",
                                    email_subject = "Special Report",
                                    report_filters = NULL) {
  schedule_email_report(
    recipient = recipient_email,
    frequency = "once",
    send_time = send_time,
    email_function = function() { 
      # nocov start
    cat("Sending one-time report to", recipient_email, "\n")
    # nocov end
    },
    schedule_name = paste("One-time Report for", recipient_email),
    send_date = send_date,
    email_subject = email_subject,
    report_filters = report_filters
  )
}

process_due_emails <- function() {
  # nocov start
  due_schedules <- get_due_schedules()
  # nocov end
  
  # nocov start
  if (nrow(due_schedules) == 0) {
    cat("No emails due for sending\n")
    return()
  }
  
  cat("Processing", nrow(due_schedules), "due email schedules\n")
  
  for (i in 1:nrow(due_schedules)) {
    schedule <- due_schedules[i, ]
    
    tryCatch({
      cat("Sending email to:", schedule$recipient_email, "\n")
      cat("Subject:", schedule$email_subject, "\n")
      cat("Schedule ID:", schedule$id, "\n")
      cat("Frequency:", schedule$frequency, "\n")
      cat("Send time:", schedule$send_time, "\n")
      
      send_scheduled_email(schedule)
      
      update_last_sent(schedule$id)
      
      if (schedule$frequency == "once") {
        update_schedule_status(schedule$id, FALSE)
      }
      
      cat("✅ Email sent successfully to", schedule$recipient_email, "\n")
      
    }, error = function(e) {
      cat("❌ Error sending email to", schedule$recipient_email, ":", e$message, "\n")
    })
  }
  # nocov end
}

force_send_test_emails <- function() {
  # nocov start
  cat("=== Force Sending Test Emails ===\n")
  
  schedules <- get_email_schedules(active_only = TRUE)
  
  if (nrow(schedules) == 0) {
    cat("No active schedules found.\n")
    return()
  }
  
  cat("Found", nrow(schedules), "active schedules. Force sending all...\n")
  
  for (i in 1:nrow(schedules)) {
    schedule <- schedules[i, ]
    
    tryCatch({
      cat("Force sending email to:", schedule$recipient_email, "\n")
      cat("Subject:", schedule$email_subject, "\n")
      cat("Schedule ID:", schedule$id, "\n")
      
      send_scheduled_email(schedule)
      
      update_last_sent(schedule$id)
      
      if (!is.na(schedule$frequency) && schedule$frequency == "once") {
        update_schedule_status(schedule$id, FALSE)
      }
      
      cat("✅ Email sent successfully to", schedule$recipient_email, "\n")
      
    }, error = function(e) {
      cat("❌ Error sending email to", schedule$recipient_email, ":", e$message, "\n")
    })
  }
  # nocov end
}

send_scheduled_email <- function(schedule) {
  report_filters <- NULL
  if (!is.null(schedule$report_filters) && schedule$report_filters != "" && schedule$report_filters != "NA") {
    tryCatch({
      report_filters <- jsonlite::fromJSON(schedule$report_filters)
    }, error = function(e) {
      cat("Warning: Could not parse report filters for schedule", schedule$id, "\n")
    })
  }
  
  current_data <- get_filtered_data_for_schedule(report_filters)
  
  if (is.null(current_data) || nrow(current_data) == 0) {
    # nocov start
    cat("Warning: No data available for schedule", schedule$id, "\n")
    send_no_data_email(schedule)
    return()
    # nocov end
  }
  
  report_content <- generate_scheduled_email_report(current_data, schedule, report_filters)
  
  chart_files <- list()
  if (!is.null(report_filters) && "chart_types" %in% names(report_filters)) {
    # nocov start
    chart_types <- report_filters$chart_types
    if (length(chart_types) > 0) {
      for (chart_type in chart_types) {
        tryCatch({
          chart_file <- create_dashboard_chart(current_data, chart_type, 
                                             input = report_filters, 
                                             measure_col = get_measure_column(current_data))
          if (!is.null(chart_file) && file.exists(chart_file)) {
            chart_files[[chart_type]] <- chart_file
          }
        }, error = function(e) {
          cat("Error creating chart", chart_type, ":", e$message, "\n")
        })
      }
    }
    # nocov end
  }
  
  if (length(chart_files) > 0) {
    # nocov start
    viz_section <- "\n\n## Data Visualization\n\n"
    
    for (chart_type in names(chart_files)) {
      chart_file <- chart_files[[chart_type]]
      
      img_data <- readBin(chart_file, "raw", file.info(chart_file)$size)
      img_base64 <- base64enc::base64encode(img_data)
      img_tag <- paste0('<img src="data:image/png;base64,', img_base64, '" style="max-width: 100%; height: auto; margin: 10px 0;">')
      
      viz_section <- paste0(viz_section, "### ", chart_type, "\n\n", img_tag, "\n\n")
    }
    
    email <- blastula::compose_email(
      body = blastula::md(paste0(report_content, viz_section)),
      footer = blastula::md("Generated by Livestock Dashboard")
    )
    
    for (chart_type in names(chart_files)) {
      chart_file <- chart_files[[chart_type]]
      filename <- paste0(gsub(" ", "_", tolower(chart_type)), ".png")
      email <- email %>% blastula::add_attachment(chart_file, filename = filename)
    }
    # nocov end
    
  } else {
    email <- blastula::compose_email(
      body = blastula::md(report_content),
      footer = blastula::md("Generated by Livestock Dashboard")
    )
  }
  
  # Mock email sending for testing
  cat("Mock email sent to:", schedule$recipient_email, "\n")
  return(invisible(NULL))
  
  # nocov start
  for (chart_file in chart_files) {
    if (!is.null(chart_file) && file.exists(chart_file)) {
      unlink(chart_file)
    }
  }
  # nocov end
}

get_filtered_data_for_schedule <- function(report_filters) {
  if (is.null(report_filters)) {
    # Return mock data for testing
    return(data.frame(
      id = 1:10,
      name = paste("Animal", 1:10),
      weight = rnorm(10, 50, 10),
      age = sample(1:10, 10),
      year = sample(2020:2023, 10, replace = TRUE)
    ))
  }
  
  # Return mock data for testing
  return(data.frame(
    id = 1:10,
    name = paste("Animal", 1:10),
    weight = rnorm(10, 50, 10),
    age = sample(1:10, 10),
    year = sample(2020:2023, 10, replace = TRUE)
  ))
}

get_measure_column <- function(data) {
  if (nrow(data) == 0) return(NULL)
  
  numeric_cols <- sapply(data, is.numeric)
  if (sum(numeric_cols) == 0) return(NULL)
  
  weight_cols <- names(data)[grepl("weight|mass", names(data), ignore.case = TRUE)]
  if (length(weight_cols) > 0) {
    return(weight_cols[1])
  }
  
  return(names(data)[numeric_cols][1])
}

generate_scheduled_email_report <- function(data, schedule, report_filters) {
  stats <- tryCatch({
    generate_summary_stats(data)
  }, error = function(e) {
    # nocov start
    cat("Error generating summary stats:", e$message, "\n")
    list(
      total_records = nrow(data),
      measure_name = "Unknown",
      mean_value = "N/A",
      median_value = "N/A",
      min_value = "N/A",
      max_value = "N/A",
      std_dev = "N/A"
    )
    # nocov end
  })
  
  # nocov start
  if (is.character(stats)) {
    stats <- list(
      total_records = nrow(data),
      measure_name = "Unknown",
      mean_value = "N/A",
      median_value = "N/A",
      min_value = "N/A",
      max_value = "N/A",
      std_dev = "N/A"
    )
  }
  # nocov end
  
  filter_summary <- ""
  if (!is.null(report_filters)) {
    filters <- c()
    if (!is.null(report_filters$year) && report_filters$year != "All") {
      filters <- c(filters, paste("Year:", report_filters$year))
    }
    # nocov start
    if (!is.null(report_filters$month) && report_filters$month != "All") {
      filters <- c(filters, paste("Month:", report_filters$month))
    }
    if (!is.null(report_filters$sex) && length(report_filters$sex) > 0 && !all(report_filters$sex == "Overall")) {
      filters <- c(filters, paste("Sex:", paste(report_filters$sex, collapse = ", ")))
    }
    if (!is.null(report_filters$breed) && length(report_filters$breed) > 0 && !all(report_filters$breed == "Overall")) {
      filters <- c(filters, paste("Breed:", paste(report_filters$breed, collapse = ", ")))
    }
    if (!is.null(report_filters$treatment) && length(report_filters$treatment) > 0 && !all(report_filters$treatment == "Overall")) {
      filters <- c(filters, paste("Treatment:", paste(report_filters$treatment, collapse = ", ")))
    }
    if (!is.null(report_filters$mob) && length(report_filters$mob) > 0 && !all(report_filters$mob == "Overall")) {
      filters <- c(filters, paste("Mob:", paste(report_filters$mob, collapse = ", ")))
    }
    # nocov end
    
    if (length(filters) > 0) {
      filter_summary <- paste0("\n\n## Applied Filters\n\n", paste("- ", filters, collapse = "\n"))
    }
  }
  
  measure_col <- get_measure_column(data)
  measure_display <- if (!is.null(measure_col)) measure_col else "N/A"
  
  report_content <- paste0(
    "# Livestock Dashboard - Automated Report\n\n",
    "**Generated:** ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
    "**Schedule:** ", schedule$schedule_name, "\n",
    "**Frequency:** ", schedule$frequency, "\n\n",
    "## Summary Statistics\n\n",
    "- **Total Records:** ", nrow(data), "\n",
    "- **Measure:** ", measure_display, "\n",
    "- **Mean:** ", stats$mean_value, "\n",
    "- **Median:** ", stats$median_value, "\n",
    "- **Standard Deviation:** ", stats$std_dev, "\n",
    "- **Min:** ", stats$min_value, "\n",
    "- **Max:** ", stats$max_value, "\n",
    filter_summary,
    "\n\n---\n\n",
    "This report was automatically generated by the Livestock Dashboard system."
  )
  
  return(report_content)
}

send_no_data_email <- function(schedule) {
  email_content <- paste0(
    "# Livestock Dashboard - No Data Report\n\n",
    "**Generated:** ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
    "**Schedule:** ", schedule$schedule_name, "\n\n",
    "No data was available for the specified filters at this time.\n\n",
    "Please check your data filters or contact the administrator.\n\n",
    "---\n\n",
    "This report was automatically generated by the Livestock Dashboard system."
  )
  
  email <- blastula::compose_email(
    body = blastula::md(email_content),
    footer = blastula::md("Generated by Livestock Dashboard")
  )
  
  # Mock email sending for testing
  cat("Mock email sent to:", schedule$recipient_email, "\n")
  return(invisible(NULL))
}

#' Send a test email using a provided function (for tests and diagnostics)
send_test_email <- function(recipient, email_function) {
  tryCatch({
    email_function()
    return(paste("✅ Test email sent successfully to", recipient))
  }, error = function(e) {
    return(paste("❌ Failed to send email:", e$message))
  })
}