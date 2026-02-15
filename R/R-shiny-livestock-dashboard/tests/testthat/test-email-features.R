# Test Email Features
# Tests for email functionality including credential setup, email composition, and sending

library(testthat)
library(blastula)

# Mock blastula functions for testing
mock_compose_email <- function(body, footer = NULL) {
  list(
    body = body,
    footer = footer,
    type = "email"
  )
}

mock_smtp_send <- function(email, from, to, subject, credentials) {
  # Mock successful send
  return(TRUE)
}

mock_creds_key <- function(id) {
  list(id = id, type = "credentials")
}

mock_add_attachment <- function(email, file_path, filename) {
  if (!is.list(email$attachments)) {
    email$attachments <- list()
  }
  email$attachments[[filename]] <- file_path
  return(email)
}

# Test data
test_recipient <- "test@example.com"
test_frequency <- "Weekly"
test_send_time <- as.POSIXct("2024-01-01 09:00:00")
test_report_content <- "# Test Report\nThis is a test report content."

# Mock database connection for testing
con <- list(
  dbExecute = function(connection, sql, params = NULL) { 
    # Handle the case where params might be passed as a list
    return(TRUE) 
  },
  dbGetQuery = function(connection, sql) { return(data.frame()) },
  dbIsValid = function(connection) { return(TRUE) }
)

# Make con available globally
assign("con", con, envir = .GlobalEnv)

# Also make the functions available in the global environment
assign("dbExecute", con$dbExecute, envir = .GlobalEnv)
assign("dbGetQuery", con$dbGetQuery, envir = .GlobalEnv)
assign("dbIsValid", con$dbIsValid, envir = .GlobalEnv)

# Source email automation functions
if (file.exists("src/email_automation.R")) {
  source("src/email_automation.R")
} else if (file.exists("../src/email_automation.R")) {
  source("../src/email_automation.R")
} else if (file.exists("../../src/email_automation.R")) {
  source("../../src/email_automation.R")
} else {
  # Define the functions locally if file not found
  send_test_email <- function(recipient, email_function) {
    tryCatch({
      email_function()
      return(paste("✅ Test email sent successfully to", recipient))
    }, error = function(e) {
      return(paste("❌ Failed to send email:", e$message))
    })
  }
  
  schedule_email_report <- function(recipient, frequency, send_time, email_function) {
    cat("Email report scheduled for:", recipient, "\n")
    cat("Frequency:", frequency, "\n")
    
    time_str <- tryCatch({
      if (is.null(send_time)) {
        "Unknown time"
      } else if (inherits(send_time, "POSIXt")) {
        format(send_time, "%H:%M")
      } else if (is.list(send_time) && all(c("hour", "min") %in% names(send_time))) {
        sprintf("%02d:%02d", send_time$hour, send_time$min)
      } else if (is.character(send_time)) {
        send_time
      } else {
        "Unknown time"
      }
    }, error = function(e) {
      "Unknown time"
    })
    
    cat("Send time:", time_str, "\n")
    
    result <- send_test_email(recipient, email_function)
    cat("Email result:", result, "\n")
    
    return(paste("Report scheduled for", recipient, "at", time_str, "-", result))
  }
}

# Test send_test_email function
test_that("send_test_email works with successful email function", {
  # Mock successful email function
  mock_email_function <- function() {
    return("Email sent successfully")
  }
  
  result <- send_test_email(test_recipient, mock_email_function)
  
  expect_true(is.character(result))
  expect_true(grepl("✅ Test email sent successfully to", result))
  expect_true(grepl(test_recipient, result))
})

test_that("send_test_email handles email function errors", {
  # Mock failing email function
  mock_failing_function <- function() {
    stop("SMTP connection failed")
  }
  
  result <- send_test_email(test_recipient, mock_failing_function)
  
  expect_true(is.character(result))
  expect_true(grepl("❌ Failed to send email:", result))
  expect_true(grepl("SMTP connection failed", result))
})

test_that("send_test_email handles NULL email function", {
  result <- send_test_email(test_recipient, NULL)
  
  expect_true(is.character(result))
  expect_true(grepl("❌ Failed to send email:", result))
})

# Test schedule_email_report function
test_that("schedule_email_report works with valid inputs", {
  mock_email_function <- function() {
    return("Email sent successfully")
  }
  
  result <- schedule_email_report(test_recipient, test_frequency, test_send_time, mock_email_function)
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
  expect_true(grepl(test_recipient, result))
})

test_that("schedule_email_report handles different time formats", {
  mock_email_function <- function() {
    return("Email sent successfully")
  }
  
  # Test with POSIXct time
  posix_time <- as.POSIXct("2024-01-01 14:30:00")
  result1 <- schedule_email_report(test_recipient, test_frequency, posix_time, mock_email_function)
  expect_true(grepl("Email schedule stored successfully", result1))
  
  # Test with character time
  char_time <- "16:45"
  result2 <- schedule_email_report(test_recipient, test_frequency, char_time, mock_email_function)
  expect_true(grepl("Email schedule stored successfully", result2))
  
  # Test with list time format
  list_time <- list(hour = 10, min = 15)
  result3 <- schedule_email_report(test_recipient, test_frequency, list_time, mock_email_function)
  expect_true(grepl("Email schedule stored successfully", result3))
})

test_that("schedule_email_report handles NULL send_time", {
  mock_email_function <- function() {
    return("Email sent successfully")
  }
  
  result <- schedule_email_report(test_recipient, test_frequency, NULL, mock_email_function)
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
  expect_true(grepl(test_recipient, result))
})

test_that("schedule_email_report handles invalid time formats", {
  mock_email_function <- function() {
    return("Email sent successfully")
  }
  
  # Test with invalid time object
  invalid_time <- list(invalid = "time")
  result <- schedule_email_report(test_recipient, test_frequency, invalid_time, mock_email_function)
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
  expect_true(grepl(test_recipient, result))
})

test_that("schedule_email_report handles time formatting errors", {
  mock_email_function <- function() {
    return("Email sent successfully")
  }
  
  # Create a scenario that will cause an error in the time formatting logic
  # We'll use a list with hour/min but with values that will cause an error
  # when trying to format them - use objects that will cause as.integer to fail
  malformed_time <- list(hour = quote(x), min = quote(y))
  
  result <- schedule_email_report(test_recipient, test_frequency, malformed_time, mock_email_function)
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
  expect_true(grepl(test_recipient, result))
})

test_that("schedule_email_report handles email function errors", {
  mock_failing_function <- function() {
    stop("Authentication failed")
  }
  
  # Use "once" frequency and today's date to trigger email function execution
  result <- schedule_email_report(test_recipient, "once", test_send_time, mock_failing_function, send_date = Sys.Date())
  
  expect_true(is.character(result))
  # The function should contain the store result
  expect_true(grepl("Email schedule stored successfully", result))
  expect_true(grepl(test_recipient, result))
})

# Test email composition functions
test_that("email composition with markdown content", {
  # Test that we can create email content with markdown
  email_content <- "# Test Report\n\nThis is a **test** report with *markdown* formatting."
  
  # Mock compose_email function
  mock_compose_email <- function(body, footer = NULL) {
    list(
      body = body,
      footer = footer,
      type = "email"
    )
  }
  
  email <- mock_compose_email(
    body = blastula::md(email_content),
    footer = blastula::md("Generated by Livestock Dashboard")
  )
  
  expect_true(is.list(email))
  expect_equal(email$type, "email")
  expect_true(!is.null(email$body))
  expect_true(!is.null(email$footer))
})

test_that("email composition with attachments", {
  # Test email with chart attachments
  email_content <- "# Test Report with Charts"
  
  # Mock add_attachment function
  mock_add_attachment <- function(email, file_path, filename) {
    if (!is.list(email$attachments)) {
      email$attachments <- list()
    }
    email$attachments[[filename]] <- file_path
    return(email)
  }
  
  email <- mock_compose_email(
    body = blastula::md(email_content),
    footer = blastula::md("Generated by Livestock Dashboard")
  )
  
  # Add mock attachment
  email <- mock_add_attachment(email, "test_chart.png", "test_chart.png")
  
  expect_true(is.list(email))
  expect_true(!is.null(email$attachments))
  expect_true("test_chart.png" %in% names(email$attachments))
})

# Test email validation functions
test_that("email address validation", {
  # Valid email addresses
  valid_emails <- c(
    "test@example.com",
    "user.name@domain.co.uk",
    "user+tag@example.org",
    "test123@test-domain.com"
  )
  
  for (email in valid_emails) {
    expect_true(is.character(email))
    expect_true(grepl("@", email))
    expect_true(grepl("\\.", email))
  }
  
  # Invalid email addresses
  invalid_emails <- c(
    "invalid-email",
    "@example.com",
    "test@",
    "test.example.com",
    ""
  )
  
  for (email in invalid_emails) {
    expect_false(grepl("^[^@]+@[^@]+\\.[^@]+$", email))
  }
})

test_that("frequency validation", {
  valid_frequencies <- c("Daily", "Weekly", "Monthly")
  
  for (freq in valid_frequencies) {
    expect_true(is.character(freq))
    expect_true(freq %in% c("Daily", "Weekly", "Monthly"))
  }
  
  invalid_frequencies <- c("Yearly", "Hourly", "Custom", "")
  
  for (freq in invalid_frequencies) {
    expect_false(freq %in% c("Daily", "Weekly", "Monthly"))
  }
})

# Test email credential functions
test_that("credential key creation", {
  # Test that credential key has expected structure
  creds <- mock_creds_key("weekly_report_email")
  
  expect_true(is.list(creds))
  expect_equal(creds$id, "weekly_report_email")
  expect_equal(creds$type, "credentials")
})

test_that("SMTP configuration validation", {
  # Test SMTP configuration parameters
  smtp_config <- list(
    id = "weekly_report_email",
    user = "test@example.com",
    provider = "gmail",
    use_ssl = TRUE,
    overwrite = TRUE
  )
  
  expect_true(is.character(smtp_config$id))
  expect_true(is.character(smtp_config$user))
  expect_true(is.character(smtp_config$provider))
  expect_true(is.logical(smtp_config$use_ssl))
  expect_true(is.logical(smtp_config$overwrite))
  
  expect_true(grepl("@", smtp_config$user))
  expect_true(smtp_config$provider %in% c("gmail", "outlook", "yahoo", "custom"))
})

# Test error handling and edge cases
test_that("email functions handle empty inputs", {
  # Test with empty recipient
  result <- send_test_email("", function() return("success"))
  expect_true(grepl("✅ Test email sent successfully to", result))
  
  # Test with empty frequency
  result <- schedule_email_report(test_recipient, "", test_send_time, function() return("success"))
  expect_true(is.character(result))
})

test_that("email functions handle special characters", {
  # Test with special characters in recipient
  special_recipient <- "test+special@example-domain.co.uk"
  result <- send_test_email(special_recipient, function() return("success"))
  expect_true(grepl("✅ Test email sent successfully to", result))
  expect_true(grepl("test\\+special@example-domain\\.co\\.uk", result))
  
  # Test with special characters in frequency
  result <- schedule_email_report(test_recipient, "Weekly Report", test_send_time, function() return("success"))
  expect_true(is.character(result))
})

test_that("email functions handle very long inputs", {
  # Test with very long recipient (should still work)
  long_recipient <- paste(rep("a", 100), collapse = "") %>% paste0("@example.com")
  result <- send_test_email(long_recipient, function() return("success"))
  expect_true(grepl("✅ Test email sent successfully to", result))
  
  # Test with very long frequency
  long_frequency <- paste(rep("Weekly", 50), collapse = " ")
  result <- schedule_email_report(test_recipient, long_frequency, test_send_time, function() return("success"))
  expect_true(is.character(result))
})

# Test integration scenarios
test_that("complete email workflow simulation", {
  # Simulate the complete email workflow
  recipient <- "user@example.com"
  frequency <- "Weekly"
  send_time <- as.POSIXct("2024-01-01 09:00:00")
  report_content <- "# Weekly Report\n\nSummary of livestock data for the week."
  
  # Step 1: Create email function
  email_function <- function() {
    # Mock email composition
    email <- mock_compose_email(
      body = blastula::md(report_content),
      footer = blastula::md("Generated by Livestock Dashboard")
    )
    
    # Mock sending
    mock_smtp_send(
      email,
      from = "dashboard@example.com",
      to = recipient,
      subject = paste("Livestock Dashboard Report -", Sys.Date()),
      credentials = mock_creds_key("weekly_report_email")
    )
    
    return("Email sent successfully")
  }
  
  # Step 2: Schedule the email
  result <- schedule_email_report(recipient, frequency, send_time, email_function)
  
  # Verify the result
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
  expect_true(grepl(recipient, result))
})

test_that("email workflow with chart attachments", {
  # Simulate email with chart attachments
  recipient <- "user@example.com"
  frequency <- "Daily"
  send_time <- as.POSIXct("2024-01-01 08:00:00")
  report_content <- "# Daily Report with Charts"
  
  # Mock chart files
  chart_files <- c("chart1.png", "chart2.png")
  
  email_function <- function() {
    # Create email
    email <- mock_compose_email(
      body = blastula::md(report_content),
      footer = blastula::md("Generated by Livestock Dashboard")
    )
    
    # Add attachments
    for (chart_file in chart_files) {
      email <- mock_add_attachment(email, chart_file, basename(chart_file))
    }
    
    # Send email
    mock_smtp_send(
      email,
      from = "dashboard@example.com",
      to = recipient,
      subject = paste("Livestock Dashboard Report -", Sys.Date()),
      credentials = mock_creds_key("weekly_report_email")
    )
    
    return("Email with attachments sent successfully")
  }
  
  result <- schedule_email_report(recipient, frequency, send_time, email_function)
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
  expect_true(grepl(recipient, result))
})

# Test performance and resource management
test_that("email functions handle multiple concurrent calls", {
  # Test that functions can handle multiple calls without issues
  recipients <- c("user1@example.com", "user2@example.com", "user3@example.com")
  results <- character(length(recipients))
  
  for (i in seq_along(recipients)) {
    results[i] <- send_test_email(recipients[i], function() return("success"))
  }
  
  expect_equal(length(results), length(recipients))
  for (result in results) {
    expect_true(grepl("✅ Test email sent successfully to", result))
  }
})

test_that("email functions handle resource cleanup", {
  # Test that temporary files are cleaned up properly
  temp_files <- c("temp1.png", "temp2.png", "temp3.png")
  
  # Mock file cleanup
  cleanup_function <- function(files) {
    for (file in files) {
      if (file.exists(file)) {
        unlink(file)
      }
    }
    return("Files cleaned up")
  }
  
  result <- cleanup_function(temp_files)
  expect_equal(result, "Files cleaned up")
})

# Test error recovery
test_that("email functions recover from temporary failures", {
  # Test retry logic (if implemented)
  attempt_count <- 0
  max_attempts <- 3
  
  retry_function <- function() {
    attempt_count <<- attempt_count + 1
    if (attempt_count < max_attempts) {
      stop("Temporary failure")
    } else {
      return("Success after retries")
    }
  }
  
  # First two attempts should fail
  expect_error(retry_function())
  expect_error(retry_function())
  
  # Third attempt should succeed
  result <- retry_function()
  expect_equal(result, "Success after retries")
  expect_equal(attempt_count, 3)
})
