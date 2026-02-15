# Set timezone to Sydney
Sys.setenv(TZ = "Australia/Sydney")

cat("=== Email Timing Debug (Simple) ===\n")
cat("Current time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("Current time (HH:MM:SS):", format(Sys.time(), "%H:%M:%S"), "\n")
cat("Current date:", Sys.Date(), "\n")
cat("Current weekday (1=Monday):", lubridate::wday(Sys.Date()), "\n")
cat("Current day of month:", lubridate::day(Sys.Date()), "\n\n")

test_time <- "09:00:00"
current_time <- format(Sys.time(), "%H:%M:%S")

cat("=== Time Comparison Test ===\n")
cat("Test time:", test_time, "\n")
cat("Current time:", current_time, "\n")
cat("Test time <= Current time:", test_time <= current_time, "\n")

past_time <- format(Sys.time() - 3600, "%H:%M:%S")
cat("\nPast time (1 hour ago):", past_time, "\n")
cat("Past time <= Current time:", past_time <= current_time, "\n")

future_time <- format(Sys.time() + 3600, "%H:%M:%S") 
cat("\nFuture time (1 hour from now):", future_time, "\n")
cat("Future time <= Current time:", future_time <= current_time, "\n")

cat("\n=== Recommendations ===\n")
if (test_time <= current_time) {
  cat("✅ Time comparison logic appears to be working correctly.\n")
} else {
  cat("❌ Time comparison logic may have issues.\n")
}

cat("\nTo test email sending:\n")
cat("1. Use the 'Force Send All' button in the web interface\n")
cat("2. Or run: Rscript test_email_immediate.R\n")
cat("3. Check your email inbox for the test email\n")
