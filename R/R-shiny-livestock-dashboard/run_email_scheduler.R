#!/usr/bin/env Rscript
# Email Scheduler Script
# This script checks for due email schedules and sends them
# Can be run manually or scheduled with cron/task scheduler

# Load required libraries
library(DBI)
library(duckdb)
library(blastula)
library(jsonlite)
library(base64enc)
library(ggplot2)
library(dplyr)
library(lubridate)

# Set timezone to Sydney
Sys.setenv(TZ = "Australia/Sydney")

# Source the email automation functions
source("src/email_automation.R")
source("src/report_generator.R")
source("src/summary_stats.R")

# Connect to database
con <- dbConnect(duckdb::duckdb(), "src/data.duckdb")

# Main function to run the email scheduler
run_email_scheduler <- function() {
  cat("=== Email Scheduler Started ===", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  
  tryCatch({
    # Process all due emails
    process_due_emails()
    
    cat("=== Email Scheduler Completed Successfully ===\n")
    
  }, error = function(e) {
    cat("❌ Error in email scheduler:", e$message, "\n")
    cat("Stack trace:\n")
    print(traceback())
  })
  
  # Close database connection
  dbDisconnect(con)
}

# Run the scheduler
run_email_scheduler()
