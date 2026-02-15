suppressPackageStartupMessages({
  library(DBI)
  library(duckdb)
  library(blastula)
  library(jsonlite)
  library(base64enc)
  library(ggplot2)
  library(dplyr)
  library(lubridate)
})

# Set timezone to Sydney
Sys.setenv(TZ = "Australia/Sydney")

source("src/email_automation.R")
source("src/report_generator.R")
source("src/summary_stats.R")

if (!dir.exists("logs")) {
  dir.create("logs")
}

log_message <- function(message) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_line <- paste(timestamp, ":", message)
  cat(log_line, "\n")
  
  write(log_line, file = "logs/email_daemon.log", append = TRUE)
}

run_email_daemon <- function() {
  log_message("=== Email Scheduler Daemon Started ===")
  con <- dbConnect(duckdb::duckdb(), "src/data.duckdb")
  run_count <- 0
  while (TRUE) {
    run_count <- run_count + 1
    tryCatch({
      log_message(paste("Run #", run_count, "- Checking for due emails..."))
      process_due_emails()
      log_message(paste("Run #", run_count, "completed successfully"))
    }, error = function(e) {
      log_message(paste("❌ Error in run #", run_count, ":", e$message))
    })
    log_message("Waiting 60 seconds before next check...")
    Sys.sleep(60)
  }
}

signal_handler <- function(sig) {
  log_message("=== Email Scheduler Daemon Stopped ===")
  if (exists("con") && inherits(con, "DBIConnection")) {
    dbDisconnect(con)
  }
  quit(save = "no")
}

if (.Platform$OS.type == "unix") {
  tools::pskill(Sys.getpid(), signal = "SIGTERM")
  tools::pskill(Sys.getpid(), signal = "SIGINT")
}

log_message("Starting email scheduler daemon...")
log_message("Press Ctrl+C to stop")

tryCatch({
  run_email_daemon()
}, finally = {
  if (exists("con") && inherits(con, "DBIConnection")) {
    dbDisconnect(con)
  }
  log_message("Email scheduler daemon stopped")
})
