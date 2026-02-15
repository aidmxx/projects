#!/usr/bin/env Rscript
# Check Email Status
# This script checks the status of email schedules and recent activity

# Load required libraries
suppressPackageStartupMessages({
  library(DBI)
  library(duckdb)
  library(dplyr)
})

# Set timezone to Sydney
Sys.setenv(TZ = "Australia/Sydney")

# Connect to database
con <- dbConnect(duckdb::duckdb(), "src/data.duckdb")

cat("=== Email System Status Check ===\n")
cat("Current time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# Check active schedules
cat("--- Active Email Schedules ---\n")
active_schedules <- dbGetQuery(con, "
  SELECT 
    id,
    schedule_name,
    recipient_email,
    frequency,
    send_time,
    day_of_week,
    day_of_month,
    send_date,
    last_sent,
    created_at
  FROM email_schedules 
  WHERE is_active = TRUE
  ORDER BY id
")

if (nrow(active_schedules) > 0) {
  print(active_schedules)
} else {
  cat("No active schedules found.\n")
}

cat("\n--- Recent Email Activity (Last 10) ---\n")
recent_activity <- dbGetQuery(con, "
  SELECT 
    id,
    schedule_name,
    recipient_email,
    frequency,
    last_sent,
    created_at
  FROM email_schedules 
  WHERE last_sent IS NOT NULL
  ORDER BY last_sent DESC
  LIMIT 10
")

if (nrow(recent_activity) > 0) {
  print(recent_activity)
} else {
  cat("No recent email activity found.\n")
}

# Check for due emails
cat("\n--- Checking for Due Emails ---\n")
current_time <- Sys.time()
current_time_hms <- format(current_time, "%H:%M:%S")
current_date <- Sys.Date()
current_weekday <- lubridate::wday(Sys.Date())
current_day_of_month <- lubridate::day(Sys.Date())

cat("Current time components:\n")
cat("  Time:", current_time_hms, "\n")
cat("  Date:", as.character(current_date), "\n")
cat("  Weekday:", current_weekday, "\n")
cat("  Day of month:", current_day_of_month, "\n")

# Check daily schedules
daily_due <- dbGetQuery(con, "
  SELECT id, schedule_name, recipient_email, send_time, last_sent
  FROM email_schedules 
  WHERE is_active = TRUE 
    AND frequency = 'daily'
    AND send_time <= ?
    AND (last_sent IS NULL OR DATE(last_sent) < ?)
", list(current_time_hms, current_date))

if (nrow(daily_due) > 0) {
  cat("\n📧 Daily schedules due for sending:\n")
  print(daily_due)
} else {
  cat("\n✅ No daily schedules due for sending.\n")
}

# Check weekly schedules
weekly_due <- dbGetQuery(con, "
  SELECT id, schedule_name, recipient_email, send_time, day_of_week, last_sent
  FROM email_schedules 
  WHERE is_active = TRUE 
    AND frequency = 'weekly'
    AND day_of_week = ?
    AND send_time <= ?
    AND (last_sent IS NULL OR DATE(last_sent) < ?)
", list(current_weekday, current_time_hms, current_date))

if (nrow(weekly_due) > 0) {
  cat("\n📧 Weekly schedules due for sending:\n")
  print(weekly_due)
} else {
  cat("\n✅ No weekly schedules due for sending.\n")
}

# Check monthly schedules
monthly_due <- dbGetQuery(con, "
  SELECT id, schedule_name, recipient_email, send_time, day_of_month, last_sent
  FROM email_schedules 
  WHERE is_active = TRUE 
    AND frequency = 'monthly'
    AND day_of_month = ?
    AND send_time <= ?
    AND (last_sent IS NULL OR DATE(last_sent) < ?)
", list(current_day_of_month, current_time_hms, current_date))

if (nrow(monthly_due) > 0) {
  cat("\n📧 Monthly schedules due for sending:\n")
  print(monthly_due)
} else {
  cat("\n✅ No monthly schedules due for sending.\n")
}

# Check one-time schedules
once_due <- dbGetQuery(con, "
  SELECT id, schedule_name, recipient_email, send_time, send_date, last_sent
  FROM email_schedules 
  WHERE is_active = TRUE 
    AND frequency = 'once'
    AND send_date = ?
    AND send_time <= ?
    AND last_sent IS NULL
", list(current_date, current_time_hms))

if (nrow(once_due) > 0) {
  cat("\n📧 One-time schedules due for sending:\n")
  print(once_due)
} else {
  cat("\n✅ No one-time schedules due for sending.\n")
}

# Summary
total_due <- nrow(daily_due) + nrow(weekly_due) + nrow(monthly_due) + nrow(once_due)
cat("\n=== Summary ===\n")
cat("Total schedules due for sending:", total_due, "\n")
cat("Active schedules:", nrow(active_schedules), "\n")
cat("Recent activity entries:", nrow(recent_activity), "\n")

if (total_due > 0) {
  cat("\n⚠️  There are", total_due, "schedules due for sending!")
  cat("\nRun 'Rscript run_email_scheduler.R' to send them now.\n")
} else {
  cat("\n✅ No schedules are due for sending at this time.\n")
}

# Close database connection
dbDisconnect(con)

cat("\n=== Status Check Complete ===\n")
