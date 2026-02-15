library(shiny)
library(DBI)
library(duckdb)
library(mailR)
library(dplyr)
library(lubridate)

# Set timezone to Sydney
Sys.setenv(TZ = "Australia/Sydney")

background_scheduler <- NULL

start_background_email_scheduler <- function() {
  cat("Starting background email scheduler...\n")
  
  background_scheduler <<- reactiveTimer(300000)
  
  observe({
    background_scheduler()
    
    tryCatch({
      process_due_emails_background()
    }, error = function(e) {
      cat("Background email scheduler error:", e$message, "\n")
    })
  })
}

process_due_emails_background <- function() {
  cat("=== Background Email Scheduler Running ===", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  
  tryCatch({
    due_schedules <- get_due_schedules_background()
    
    if (nrow(due_schedules) == 0) {
      cat("No emails due for sending\n")
      return()
    }
    
    cat("Processing", nrow(due_schedules), "due email schedules\n")
    
    for (i in 1:nrow(due_schedules)) {
      schedule <- due_schedules[i, ]
      cat("Sending email to:", schedule$recipient_email, "\n")
      cat("Subject:", schedule$email_subject, "\n")
      cat("Schedule ID:", schedule$id, "\n")
      cat("Frequency:", schedule$frequency, "\n")
      cat("Send time:", schedule$send_time, "\n")
      
      send_email_background(schedule)
    }
    
    cat("=== Background Email Scheduler Completed ===\n")
    
  }, error = function(e) {
    cat("❌ Error in background email scheduler:", e$message, "\n")
  })
}

get_due_schedules_background <- function() {
  current_time <- Sys.time()
  current_hour <- hour(current_time)
  current_minute <- minute(current_time)
  current_weekday <- wday(current_time)
  current_day <- day(current_time)
  
  cat("Checking due schedules at:", format(current_time, "%Y-%m-%d %H:%M:%S"), "\n")
  cat("Current weekday:", current_weekday, "(1=Monday, 7=Sunday)\n")
  cat("Current day of month:", current_day, "\n")
  
  schedules <- dbGetQuery(con, "SELECT * FROM email_schedules WHERE is_active = TRUE")
  
  if (nrow(schedules) == 0) {
    cat("No active schedules found\n")
    return(data.frame())
  }
  
  due_schedules <- data.frame()
  
  for (i in 1:nrow(schedules)) {
    schedule <- schedules[i, ]
    is_due <- FALSE
    
    send_time_str <- as.character(schedule$send_time)
    if (grepl("^\\d+$", send_time_str)) {
      send_time_seconds <- as.numeric(send_time_str)
      send_hour <- floor(send_time_seconds / 3600)
      send_minute <- floor((send_time_seconds %% 3600) / 60)
    } else if (grepl("^\\d{2}:\\d{2}:\\d{2}$", send_time_str)) {
      time_parts <- strsplit(send_time_str, ":")[[1]]
      send_hour <- as.numeric(time_parts[1])
      send_minute <- as.numeric(time_parts[2])
    } else if (grepl("^\\d{2}:\\d{2}$", send_time_str)) {
      time_parts <- strsplit(send_time_str, ":")[[1]]
      send_hour <- as.numeric(time_parts[1])
      send_minute <- as.numeric(time_parts[2])
    } else {
      cat("Warning: Unknown time format for schedule", schedule$id, ":", send_time_str, "\n")
      next
    }
    
    # Check if current time is within 5 minutes of scheduled time
    current_time_minutes <- current_hour * 60 + current_minute
    send_time_minutes <- send_hour * 60 + send_minute
    time_diff <- abs(current_time_minutes - send_time_minutes)
    
    cat("Schedule", schedule$id, "- Current:", current_hour, ":", current_minute, 
        " Scheduled:", send_hour, ":", send_minute, " Diff:", time_diff, "minutes\n")
    
    # Allow emails to be sent if we're within 5 minutes of the scheduled time
    # The scheduler runs every 5 minutes, so we don't need to check minute intervals
    if (time_diff <= 5) {
      cat("Schedule", schedule$id, "is within 5-minute time range (diff:", time_diff, "minutes)\n")
      if (schedule$frequency == "daily") {
        if (is.na(schedule$last_sent) || 
            as.Date(schedule$last_sent) < as.Date(current_time)) {
          is_due <- TRUE
        }
      } else if (schedule$frequency == "weekly") {
        if (current_weekday == schedule$day_of_week) {
          if (is.na(schedule$last_sent) || 
              as.Date(schedule$last_sent) < as.Date(current_time) - days(7)) {
            is_due <- TRUE
          }
        }
      } else if (schedule$frequency == "monthly") {
        if (current_day == schedule$day_of_month) { 
          if (is.na(schedule$last_sent) || 
              month(schedule$last_sent) != month(current_time) ||
              year(schedule$last_sent) != year(current_time)) {
            is_due <- TRUE
          }
        }
      } else if (schedule$frequency == "once") {
        if (is.na(schedule$last_sent)) {
          is_due <- TRUE
        }
      }
    }
    
    if (is_due) {
      due_schedules <- rbind(due_schedules, schedule)
    }
  }
  
  return(due_schedules)
}

send_email_background <- function(schedule) {
  tryCatch({
    data_query <- "SELECT * FROM animal_data"
    data <- dbGetQuery(con, data_query)
    
    if (nrow(data) == 0) {
      email_body <- paste0(
        "<h1>Livestock Dashboard - No Data Report</h1>",
        "<p><strong>Generated:</strong> ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "</p>",
        "<p><strong>Schedule:</strong> ", schedule$schedule_name, "</p>",
        "<p>No data was available for the specified filters at this time.</p>",
        "<p>Please check your data filters or contact the administrator.</p>",
        "<hr>",
        "<p><em>This report was automatically generated by the Livestock Dashboard system.</em></p>"
      )
    } else {
      total_records <- nrow(data)
      
      numeric_cols <- sapply(data, is.numeric)
      if (any(numeric_cols)) {
        numeric_data <- data[, numeric_cols, drop = FALSE]
        mean_val <- mean(numeric_data[, 1], na.rm = TRUE)
        median_val <- median(numeric_data[, 1], na.rm = TRUE)
        min_val <- min(numeric_data[, 1], na.rm = TRUE)
        max_val <- max(numeric_data[, 1], na.rm = TRUE)
      } else {
        mean_val <- "N/A"
        median_val <- "N/A"
        min_val <- "N/A"
        max_val <- "N/A"
      }
      
      email_body <- paste0(
        "<h1>Livestock Dashboard Report</h1>",
        "<p><strong>Generated:</strong> ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "</p>",
        "<p><strong>Schedule:</strong> ", schedule$schedule_name, "</p>",
        "<h2>Summary Statistics</h2>",
        "<ul>",
        "<li><strong>Total Records:</strong> ", total_records, "</li>",
        "<li><strong>Mean Value:</strong> ", round(mean_val, 2), "</li>",
        "<li><strong>Median Value:</strong> ", round(median_val, 2), "</li>",
        "<li><strong>Min Value:</strong> ", round(min_val, 2), "</li>",
        "<li><strong>Max Value:</strong> ", round(max_val, 2), "</li>",
        "</ul>",
        "<hr>",
        "<p><em>This report was automatically generated by the Livestock Dashboard system.</em></p>"
      )
    }
    
    send.mail(
      from = "sarahaikositompul0625@gmail.com",
      to = schedule$recipient_email,
      subject = schedule$email_subject,
      body = email_body,
      html = TRUE,
      smtp = list(
        host.name = "smtp.gmail.com",
        port = 587,
        user.name = "sarahaikositompul0625@gmail.com",
        passwd = "vbdityjvreplueun",
        ssl = TRUE,
        tls = TRUE
      ),
      authenticate = TRUE,
      send = TRUE
    )
    
    cat("✅ Email sent successfully to", schedule$recipient_email, "\n")
    
    dbExecute(con, "UPDATE email_schedules SET last_sent = ? WHERE id = ?", 
              list(Sys.time(), schedule$id))
    
    if (schedule$frequency == "once") {
      dbExecute(con, "UPDATE email_schedules SET is_active = FALSE WHERE id = ?", 
                list(schedule$id))
    }
    
  }, error = function(e) {
    cat("❌ Error sending email to", schedule$recipient_email, ":", e$message, "\n")
  })
}

stop_background_email_scheduler <- function() {
  if (!is.null(background_scheduler)) {
    cat("Stopping background email scheduler...\n")
    background_scheduler <<- NULL
  }
}
