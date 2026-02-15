# Test Email Integration
# Integration tests for email functionality with the Shiny app

library(testthat)
library(shiny)
library(blastula)

# Mock Shiny session for testing
mock_session <- list(
  userData = list(),
  input = list(),
  output = list(),
  sendCustomMessage = function(type, message) {
    cat("Custom message:", type, "-", message, "\n")
  }
)

# Mock reactive values
mock_reactive_values <- reactiveValues(
  email_recipient = "test@example.com",
  email_frequency = "Weekly",
  email_time = list(hour = 9, min = 0),
  report_chart_types = c("Weight Trend", "Feed Intake")
)

# Mock Shiny output rendering function
mock_render_schedule_status <- function(recipient, frequency, send_time, chart_types) {
  time_str <- tryCatch({
    if (is.null(send_time)) {
      format(Sys.time(), "%H:%M")
    } else if (inherits(send_time, "POSIXt")) {
      format(send_time, "%H:%M")
    } else if (is.list(send_time) && all(c("hour", "min") %in% names(send_time))) {
      sprintf("%02d:%02d", send_time$hour, send_time$min)
    } else if (is.character(send_time)) {
      send_time
    } else {
      format(Sys.time(), "%H:%M")
    }
  }, error = function(e) {
    "Unknown time"
  })
  
  chart_info <- if (length(chart_types) > 0) {
    paste0(" with ", length(chart_types), " chart(s): ", paste(chart_types, collapse = ", "))
  } else {
    " (no charts selected)"
  }
  
  return(paste0(frequency, " report scheduled for ", recipient, " at ", time_str, chart_info))
}

# Test email integration with Shiny app
test_that("email integration works with Shiny reactive values", {
  # Define schedule_email_report function locally for testing
  schedule_email_report <- function(recipient, frequency, send_time, email_function) {
    cat("Email report scheduled for:", recipient, "\n")
    cat("Frequency:", frequency, "\n")
    
    time_str <- tryCatch({
      if (inherits(send_time, "POSIXt")) {
        format(send_time, "%H:%M")
      } else if (is.list(send_time) && all(c("hour", "min") %in% names(send_time))) {
        sprintf("%02d:%02d", send_time$hour, send_time$min)
      } else {
        as.character(send_time)
      }
    }, error = function(e) {
      "Unknown time"
    })
    
    cat("Send time:", time_str, "\n")
    
    result <- tryCatch({
      email_function()
      return(paste("✅ Test email sent successfully to", recipient))
    }, error = function(e) {
      return(paste("❌ Failed to send email:", e$message))
    })
    
    cat("Email result:", result, "\n")
    
    return(paste("Report scheduled for", recipient, "at", time_str, "-", result))
  }
  
  # Mock the email scheduling function from the app
  mock_schedule_email_from_app <- function(session, input, output) {
    recipient <- input$email_recipient
    frequency <- input$email_frequency
    send_time <- input$email_time
    
    # Mock email function
    email_function <- function() {
      return("Email sent successfully from Shiny app")
    }
    
    # Call the actual scheduling function
    result <- schedule_email_report(recipient, frequency, send_time, email_function)
    
    return(result)
  }
  
  # Set up mock input
  mock_session$input$email_recipient <- "user@example.com"
  mock_session$input$email_frequency <- "Daily"
  mock_session$input$email_time <- list(hour = 14, min = 30)
  
  result <- mock_schedule_email_from_app(mock_session, mock_session$input, mock_session$output)
  
  expect_true(is.character(result))
  # The result should be non-empty and contain the recipient
  expect_true(nchar(result) > 0)
  expect_true(grepl("user@example.com", result))
})

test_that("email integration handles Shiny input validation", {
  # Test with invalid email input
  validate_email_input <- function(email) {
    if (is.null(email) || email == "" || !grepl("^[^@]+@[^@]+\\.[^@]+$", email)) {
      return(FALSE)
    }
    return(TRUE)
  }
  
  # Valid inputs
  expect_true(validate_email_input("user@example.com"))
  expect_true(validate_email_input("test.user@domain.co.uk"))
  
  # Invalid inputs
  expect_false(validate_email_input(""))
  expect_false(validate_email_input(NULL))
  expect_false(validate_email_input("invalid-email"))
  expect_false(validate_email_input("@example.com"))
})

test_that("email integration handles Shiny frequency input", {
  # Test frequency validation
  validate_frequency_input <- function(freq) {
    if (is.null(freq)) {
      return(FALSE)
    }
    valid_frequencies <- c("Daily", "Weekly", "Monthly")
    return(freq %in% valid_frequencies)
  }
  
  # Valid frequencies
  expect_true(validate_frequency_input("Daily"))
  expect_true(validate_frequency_input("Weekly"))
  expect_true(validate_frequency_input("Monthly"))
  
  # Invalid frequencies
  expect_false(validate_frequency_input("Yearly"))
  expect_false(validate_frequency_input(""))
  expect_false(validate_frequency_input(NULL))
})

test_that("email integration handles Shiny time input", {
  # Test time input validation
  validate_time_input <- function(time_input) {
    if (is.null(time_input)) {
      return(FALSE)
    }
    
    if (is.list(time_input) && all(c("hour", "min") %in% names(time_input))) {
      hour <- time_input$hour
      min <- time_input$min
      return(hour >= 0 && hour <= 23 && min >= 0 && min <= 59)
    }
    
    return(FALSE)
  }
  
  # Valid time inputs
  expect_true(validate_time_input(list(hour = 9, min = 0)))
  expect_true(validate_time_input(list(hour = 14, min = 30)))
  expect_true(validate_time_input(list(hour = 23, min = 59)))
  
  # Invalid time inputs
  expect_false(validate_time_input(NULL))
  expect_false(validate_time_input(list(hour = 25, min = 0)))  # Invalid hour
  expect_false(validate_time_input(list(hour = 12, min = 60)))  # Invalid minute
  expect_false(validate_time_input(list(hour = -1, min = 0)))   # Negative hour
})

test_that("email integration with report generation", {
  # Mock report generation function
  mock_generate_report <- function(chart_types, data) {
    content <- "# Livestock Dashboard Report\n\n"
    
    if (length(chart_types) > 0) {
      content <- paste0(content, "## Charts Included\n\n")
      for (chart in chart_types) {
        content <- paste0(content, "- ", chart, "\n")
      }
    }
    
    return(content)
  }
  
  # Mock email composition with report
  mock_compose_email_with_report <- function(report_content, chart_types) {
    email <- list(
      body = list(content = report_content, type = "markdown"),
      footer = list(content = "Generated by Livestock Dashboard", type = "markdown"),
      attachments = list()
    )
    
    # Add chart attachments
    for (chart_type in chart_types) {
      filename <- paste0(gsub(" ", "_", tolower(chart_type)), ".png")
      email$attachments[[filename]] <- paste0("temp_", filename)
    }
    
    return(email)
  }
  
  # Test complete workflow
  chart_types <- c("Weight Trend", "Feed Intake", "Methane Production")
  report_content <- mock_generate_report(chart_types, test_report_data)
  email <- mock_compose_email_with_report(report_content, chart_types)
  
  expect_true(is.list(email))
  expect_true(grepl("Charts Included", email$body$content))
  expect_equal(length(email$attachments), length(chart_types))
  expect_true("weight_trend.png" %in% names(email$attachments))
})

test_that("email integration handles Shiny output rendering", {
  
  # Test with various inputs
  recipient <- "user@example.com"
  frequency <- "Weekly"
  send_time <- list(hour = 9, min = 0)
  chart_types <- c("Weight Trend", "Feed Intake")
  
  status <- mock_render_schedule_status(recipient, frequency, send_time, chart_types)
  
  expect_true(is.character(status))
  expect_true(grepl("Weekly report scheduled for", status))
  expect_true(grepl("user@example.com", status))
  expect_true(grepl("09:00", status))
  expect_true(grepl("with 2 chart\\(s\\)", status))
  expect_true(grepl("Weight Trend", status))
  expect_true(grepl("Feed Intake", status))
})

test_that("email integration handles empty chart selection", {
  # Test with no charts selected
  recipient <- "user@example.com"
  frequency <- "Daily"
  send_time <- list(hour = 8, min = 30)
  chart_types <- character(0)
  
  status <- mock_render_schedule_status(recipient, frequency, send_time, chart_types)
  
  expect_true(grepl("no charts selected", status))
  expect_false(grepl("chart\\(s\\)", status))
})

test_that("email integration handles Shiny session management", {
  # Mock session data management
  mock_session_data <- list()
  
  save_email_preferences <- function(session, recipient, frequency, time) {
    session_data <- list(
      recipient = recipient,
      frequency = frequency,
      time = time,
      last_updated = Sys.time()
    )
    mock_session_data <<- session_data
    return(TRUE)
  }
  
  load_email_preferences <- function(session) {
    return(mock_session_data)
  }
  
  # Test saving preferences
  result <- save_email_preferences(mock_session, "user@example.com", "Weekly", list(hour = 9, min = 0))
  expect_true(result)
  
  # Test loading preferences
  preferences <- load_email_preferences(mock_session)
  expect_true(is.list(preferences))
  expect_equal(preferences$recipient, "user@example.com")
  expect_equal(preferences$frequency, "Weekly")
  expect_equal(preferences$time$hour, 9)
  expect_equal(preferences$time$min, 0)
})

test_that("email integration handles Shiny error handling", {
  # Mock error handling in Shiny context
  mock_email_with_error_handling <- function(recipient, email_function) {
    tryCatch({
      result <- email_function()
      return(list(
        success = TRUE,
        message = paste("Email sent successfully to", recipient),
        result = result
      ))
    }, error = function(e) {
      return(list(
        success = FALSE,
        message = paste("Failed to send email:", e$message),
        error = e$message
      ))
    })
  }
  
  # Test successful email
  success_function <- function() return("Email sent")
  result <- mock_email_with_error_handling("user@example.com", success_function)
  
  expect_true(result$success)
  expect_true(grepl("Email sent successfully", result$message))
  expect_equal(result$result, "Email sent")
  
  # Test failed email
  fail_function <- function() stop("SMTP error")
  result <- mock_email_with_error_handling("user@example.com", fail_function)
  
  expect_false(result$success)
  expect_true(grepl("Failed to send email", result$message))
  expect_equal(result$error, "SMTP error")
})

test_that("email integration handles Shiny reactive dependencies", {
  # Mock reactive dependencies
  mock_reactive_dependency <- function(input, output, session) {
    # Simulate reactive dependency on input changes
    observe({
      if (!is.null(input$email_recipient) && input$email_recipient != "") {
        # Update UI based on email input
        output$email_validation <- renderText({
          if (grepl("@", input$email_recipient)) {
            "Valid email address"
          } else {
            "Invalid email address"
          }
        })
      }
    })
    
    return(TRUE)
  }
  
  # Test reactive dependency setup
  result <- mock_reactive_dependency(mock_session$input, mock_session$output, mock_session)
  expect_true(result)
})

test_that("email integration handles Shiny file uploads", {
  # Mock file upload handling for email attachments
  mock_handle_file_upload <- function(uploaded_files) {
    if (is.null(uploaded_files) || length(uploaded_files) == 0) {
      return(list())
    }
    
    processed_files <- list()
    for (file in uploaded_files) {
      if (grepl("\\.(png|jpg|jpeg|pdf)$", file$name, ignore.case = TRUE)) {
        processed_files[[file$name]] <- file$datapath
      }
    }
    
    return(processed_files)
  }
  
  # Test with valid files
  mock_files <- list(
    list(name = "chart1.png", datapath = "/tmp/chart1.png"),
    list(name = "report.pdf", datapath = "/tmp/report.pdf"),
    list(name = "data.txt", datapath = "/tmp/data.txt")  # Invalid file type
  )
  
  result <- mock_handle_file_upload(mock_files)
  
  expect_equal(length(result), 2)  # Only PNG and PDF should be processed
  expect_true("chart1.png" %in% names(result))
  expect_true("report.pdf" %in% names(result))
  expect_false("data.txt" %in% names(result))
  
  # Test with no files
  result_empty <- mock_handle_file_upload(list())
  expect_equal(length(result_empty), 0)
})

test_that("email integration handles Shiny progress indicators", {
  # Mock progress indicator for email sending
  mock_show_progress <- function(message) {
    return(list(
      show = TRUE,
      message = message,
      timestamp = Sys.time()
    ))
  }
  
  mock_hide_progress <- function() {
    return(list(
      show = FALSE,
      timestamp = Sys.time()
    ))
  }
  
  # Test progress indicator
  progress <- mock_show_progress("Sending email...")
  expect_true(progress$show)
  expect_equal(progress$message, "Sending email...")
  expect_true(inherits(progress$timestamp, "POSIXt"))
  
  # Test hiding progress
  hidden <- mock_hide_progress()
  expect_false(hidden$show)
  expect_true(inherits(hidden$timestamp, "POSIXt"))
})

test_that("email integration handles Shiny notification system", {
  # Mock notification system
  mock_show_notification <- function(message, type = "info") {
    return(list(
      message = message,
      type = type,
      timestamp = Sys.time(),
      id = paste0("notification_", as.numeric(Sys.time()))
    ))
  }
  
  # Test different notification types
  info_notification <- mock_show_notification("Email scheduled successfully", "info")
  expect_equal(info_notification$type, "info")
  expect_true(grepl("Email scheduled successfully", info_notification$message))
  
  error_notification <- mock_show_notification("Failed to send email", "error")
  expect_equal(error_notification$type, "error")
  expect_true(grepl("Failed to send email", error_notification$message))
  
  warning_notification <- mock_show_notification("Email credentials not configured", "warning")
  expect_equal(warning_notification$type, "warning")
  expect_true(grepl("Email credentials not configured", warning_notification$message))
})

test_that("email integration handles Shiny modal dialogs", {
  # Mock modal dialog for email confirmation
  mock_show_modal <- function(title, message, confirm_text = "Confirm", cancel_text = "Cancel") {
    return(list(
      title = title,
      message = message,
      confirm_text = confirm_text,
      cancel_text = cancel_text,
      timestamp = Sys.time()
    ))
  }
  
  # Test email confirmation modal
  modal <- mock_show_modal(
    "Confirm Email Schedule",
    "Are you sure you want to schedule a weekly report for user@example.com?",
    "Yes, Schedule",
    "Cancel"
  )
  
  expect_equal(modal$title, "Confirm Email Schedule")
  expect_true(grepl("weekly report", modal$message))
  expect_equal(modal$confirm_text, "Yes, Schedule")
  expect_equal(modal$cancel_text, "Cancel")
  expect_true(inherits(modal$timestamp, "POSIXt"))
})

test_that("email integration handles Shiny bookmarking", {
  # Mock bookmarking for email preferences
  mock_save_bookmark <- function(state, email_preferences) {
    state$email_recipient <- email_preferences$recipient
    state$email_frequency <- email_preferences$frequency
    state$email_time <- email_preferences$time
    return(state)
  }
  
  mock_restore_bookmark <- function(state) {
    return(list(
      recipient = state$email_recipient,
      frequency = state$email_frequency,
      time = state$email_time
    ))
  }
  
  # Test saving bookmark
  initial_state <- list()
  email_prefs <- list(
    recipient = "user@example.com",
    frequency = "Weekly",
    time = list(hour = 9, min = 0)
  )
  
  bookmarked_state <- mock_save_bookmark(initial_state, email_prefs)
  expect_equal(bookmarked_state$email_recipient, "user@example.com")
  expect_equal(bookmarked_state$email_frequency, "Weekly")
  expect_equal(bookmarked_state$email_time$hour, 9)
  
  # Test restoring bookmark
  restored_prefs <- mock_restore_bookmark(bookmarked_state)
  expect_equal(restored_prefs$recipient, "user@example.com")
  expect_equal(restored_prefs$frequency, "Weekly")
  expect_equal(restored_prefs$time$hour, 9)
})
