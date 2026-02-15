library(DBI)
library(duckdb)
library(lubridate)

# Set timezone to Sydney
Sys.setenv(TZ = "Australia/Sydney")

con <- dbConnect(duckdb::duckdb(), "src/data.duckdb")

cat("=== Email Timing Debug ===\n")
cat("Current time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("Current time (HH:MM:SS):", format(Sys.time(), "%H:%M:%S"), "\n")
cat("Current date:", Sys.Date(), "\n")
cat("Current weekday (1=Monday):", lubridate::wday(Sys.Date()), "\n")
cat("Current day of month:", lubridate::day(Sys.Date()), "\n\n")

cat("=== Active Schedules ===\n")
schedules <- dbGetQuery(con, "
  SELECT id, recipient_email, schedule_name, frequency, send_time, 
         send_date, day_of_week, day_of_month, is_active, created_at, last_sent
  FROM email_schedules 
  WHERE is_active = TRUE
  ORDER BY created_at DESC
")

if (nrow(schedules) == 0) {
  cat("No active schedules found.\n")
} else {
  print(schedules)
  
  cat("\n=== Time Comparison Analysis ===\n")
  current_time <- format(Sys.time(), "%H:%M:%S")
  
  for (i in 1:nrow(schedules)) {
    schedule <- schedules[i, ]
    cat("\nSchedule ID:", schedule$id, "\n")
    cat("Frequency:", schedule$frequency, "\n")
    cat("Stored send_time:", schedule$send_time, "\n")
    cat("Current time:", current_time, "\n")
    cat("Time comparison (send_time <= current_time):", schedule$send_time <= current_time, "\n")
    
    if (schedule$frequency == "daily") {
      cat("Should send daily? ", schedule$send_time <= current_time, "\n")
    } else if (schedule$frequency == "weekly") {
      cat("Day of week match? ", schedule$day_of_week == lubridate::wday(Sys.Date()), "\n")
      cat("Time match? ", schedule$send_time <= current_time, "\n")
      cat("Should send weekly? ", (schedule$day_of_week == lubridate::wday(Sys.Date())) && (schedule$send_time <= current_time), "\n")
    } else if (schedule$frequency == "monthly") {
      cat("Day of month match? ", schedule$day_of_month == lubridate::day(Sys.Date()), "\n")
      cat("Time match? ", schedule$send_time <= current_time, "\n")
      cat("Should send monthly? ", (schedule$day_of_month == lubridate::day(Sys.Date())) && (schedule$send_time <= current_time), "\n")
    } else if (schedule$frequency == "once") {
      cat("Date match? ", schedule$send_date == Sys.Date(), "\n")
      cat("Time match? ", schedule$send_time <= current_time, "\n")
      cat("Should send once? ", (schedule$send_date == Sys.Date()) && (schedule$send_time <= current_time), "\n")
    }
  }
}

cat("\n=== Testing get_due_schedules() ===\n")
source("src/email_automation.R")
due_schedules <- get_due_schedules()
cat("Due schedules found:", nrow(due_schedules), "\n")
if (nrow(due_schedules) > 0) {
  print(due_schedules)
}

dbDisconnect(con)
