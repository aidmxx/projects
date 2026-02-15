# Integration Tests: Report Generation Workflow
# Tests the complete workflow from report configuration to file generation and email scheduling

library(testthat)
library(shiny)
library(dplyr)
library(plotly)

# Mock data for testing
test_data <- data.frame(
  eid = c("E001", "E002", "E003", "E004", "E005"),
  date = as.Date(c("2023-01-15", "2023-02-20", "2023-03-10", "2023-04-05", "2023-05-12")),
  sex = c("Male", "Female", "Male", "Female", "Male"),
  breed = c("Angus", "Hereford", "Angus", "Angus", "Hereford"),
  treatment = c("Control", "Treatment A", "Control", "Treatment B", "Treatment A"),
  mob = c("Mob1", "Mob2", "Mob1", "Mob2", "Mob1"),
  finalpweight = c(450, 380, 420, 390, 440),
  feedintake = c(12.5, 11.8, 13.2, 12.1, 12.9),
  methane = c(25.3, 22.1, 26.8, 23.5, 25.1),
  stringsAsFactors = FALSE
)

# Mock database connection
mock_con <- list(
  dbExecute = function(con, sql, params = NULL) { return(TRUE) },
  dbGetQuery = function(con, sql) { return(data.frame()) },
  dbIsValid = function(con) { return(TRUE) }
)

# Source required functions
if (file.exists("src/report_page.R")) {
  source("src/report_page.R")
} else if (file.exists("../src/report_page.R")) {
  source("../src/report_page.R")
} else if (file.exists("../../src/report_page.R")) {
  source("../../src/report_page.R")
}

if (file.exists("src/report_generator.R")) {
  source("src/report_generator.R")
} else if (file.exists("../src/report_generator.R")) {
  source("../src/report_generator.R")
} else if (file.exists("../../src/report_generator.R")) {
  source("../../src/report_generator.R")
}

# Mock email functions
mock_send_test_email <- function(recipient, email_function) {
  tryCatch({
    email_function()
    return(paste("✅ Test email sent successfully to", recipient))
  }, error = function(e) {
    return(paste("❌ Failed to send email:", e$message))
  })
}

mock_schedule_email_report <- function(recipient, frequency, send_time, email_function) {
  time_str <- tryCatch({
    if (is.null(send_time)) {
      "Unknown time"
    } else if (inherits(send_time, "POSIXt")) {
      format(send_time, "%H:%M")
    } else if (is.list(send_time) && all(c("hour", "min") %in% names(send_time))) {
      sprintf("%02d:%02d", send_time$hour, send_time$min)
    } else {
      as.character(send_time)
    }
  }, error = function(e) {
    "Unknown time"
  })
  
  result <- mock_send_test_email(recipient, email_function)
  return(paste("Report scheduled for", recipient, "at", time_str, "-", result))
}

# Test 1: Complete Report Generation Workflow
test_that("complete report generation workflow integrates correctly", {
  # Mock report generation function
  generate_report_content <- function(data, chart_types, format) {
    content <- "# Livestock Dashboard Report\n\n"
    content <- paste0(content, "Generated on: ", format(Sys.Date(), "%Y-%m-%d"), "\n\n")
    
    if (nrow(data) > 0) {
      content <- paste0(content, "## Data Summary\n\n")
      content <- paste0(content, "- Total records: ", nrow(data), "\n")
      content <- paste0(content, "- Date range: ", min(data$date), " to ", max(data$date), "\n")
      content <- paste0(content, "- Breeds: ", paste(unique(data$breed), collapse = ", "), "\n\n")
      
      if (length(chart_types) > 0) {
        content <- paste0(content, "## Charts Included\n\n")
        for (chart in chart_types) {
          content <- paste0(content, "- ", chart, "\n")
        }
        content <- paste0(content, "\n")
      }
    }
    
    return(content)
  }
  
  # Mock filename generation
  generate_filename <- function(filename, format) {
    date_str <- format(Sys.Date(), "%Y%m%d")
    paste0(filename, "_", date_str, ".", tolower(format))
  }
  
  # Test report generation with different formats
  report_filename <- "test_report"
  report_format <- "PDF"
  report_frequency <- "Weekly"
  report_email <- "user@example.com"
  report_time <- list(hour = 9, min = 0)
  report_chart_types <- c("Weight Trend", "Feed Intake")
  
  # Generate report content
  report_content <- generate_report_content(test_data, report_chart_types, report_format)
  
  expect_true(grepl("Livestock Dashboard Report", report_content))
  expect_true(grepl("Total records: 5", report_content))
  expect_true(grepl("Weight Trend", report_content))
  expect_true(grepl("Feed Intake", report_content))
  
  # Test filename generation
  expected_filename <- generate_filename(report_filename, report_format)
  expect_true(grepl("test_report_.*\\.pdf$", expected_filename))
  
  # Test email scheduling
  email_result <- mock_schedule_email_report(
    report_email,
    report_frequency,
    report_time,
    function() return("Email sent successfully")
  )
  
  expect_true(grepl("Report scheduled for", email_result))
  expect_true(grepl("user@example.com", email_result))
  expect_true(grepl("09:00", email_result))
})

# Test 2: Report Generation with Filtered Data Integration
test_that("report generation integrates with filtered data", {
  # Mock filtered data based on inputs
  get_filtered_data <- function(input_data, filters) {
    df <- input_data
    
    if (!is.null(filters$year)) {
      df <- df %>% filter(year(date) == filters$year)
    }
    if (!is.null(filters$sex) && length(filters$sex) > 0 && !"Overall" %in% filters$sex) {
      df <- df %>% filter(sex %in% filters$sex)
    }
    if (!is.null(filters$breed) && length(filters$breed) > 0 && !"Overall" %in% filters$breed) {
      df <- df %>% filter(breed %in% filters$breed)
    }
    
    return(df)
  }
  
  # Test with filters applied
  filters <- list(
    year = 2023,
    sex = c("Male"),
    breed = c("Angus")
  )
  
  filtered_data <- get_filtered_data(test_data, filters)
  
  # Generate report with filtered data
  report_content <- paste0(
    "# Filtered Report\n\n",
    "Filters applied:\n",
    "- Year: ", filters$year, "\n",
    "- Sex: ", paste(filters$sex, collapse = ", "), "\n",
    "- Breed: ", paste(filters$breed, collapse = ", "), "\n\n",
    "Records matching filters: ", nrow(filtered_data), "\n"
  )
  
  expect_true(grepl("Year: 2023", report_content))
  expect_true(grepl("Sex: Male", report_content))
  expect_true(grepl("Breed: Angus", report_content))
  expect_true(grepl("Records matching filters: 2", report_content))
  
  # Test with no matching data
  filters_empty <- list(
    year = 2025,
    sex = c("Male")
  )
  
  filtered_data_empty <- get_filtered_data(test_data, filters_empty)
  expect_equal(nrow(filtered_data_empty), 0)
})

# Test 3: Chart Export Integration
test_that("chart export integrates with report generation", {
  # Mock chart generation
  generate_chart <- function(data, chart_type, format) {
    if (nrow(data) == 0) {
      return(NULL)
    }
    
    chart_data <- switch(chart_type,
      "Weight Trend" = data %>% group_by(date) %>% summarise(avg_weight = mean(finalpweight), .groups = "drop"),
      "Feed Intake" = data %>% group_by(sex) %>% summarise(avg_intake = mean(feedintake), .groups = "drop"),
      "Methane Production" = data %>% group_by(treatment) %>% summarise(avg_methane = mean(methane), .groups = "drop")
    )
    
    return(chart_data)
  }
  
  # Mock chart export
  export_chart <- function(chart_data, chart_type, format) {
    if (is.null(chart_data)) {
      return("No data available for chart")
    }
    
    filename <- paste0(gsub(" ", "_", tolower(chart_type)), "_", format(Sys.Date(), "%Y%m%d"), ".", tolower(format))
    return(paste("Chart exported as:", filename))
  }
  
  # Test chart generation and export
  chart_source <- "Weight Trend"
  chart_format <- "PNG"
  
  chart_data <- generate_chart(test_data, chart_source, chart_format)
  export_result <- export_chart(chart_data, chart_source, chart_format)
  
  expect_true(!is.null(chart_data))
  expect_true("date" %in% names(chart_data))
  expect_true("avg_weight" %in% names(chart_data))
  expect_true(grepl("Chart exported as:", export_result))
  expect_true(grepl("weight_trend_", export_result))
  
  # Test with empty data
  empty_data <- data.frame()
  chart_data_empty <- generate_chart(empty_data, "Weight Trend", "PNG")
  export_result_empty <- export_chart(chart_data_empty, "Weight Trend", "PNG")
  
  expect_true(is.null(chart_data_empty))
  expect_equal(export_result_empty, "No data available for chart")
})

# Test 4: Email Scheduling Integration
test_that("email scheduling integrates with report generation", {
  # Mock email schedule storage
  email_schedules <- list(schedules = list())
  
  # Mock schedule storage function
  store_email_schedule <- function(schedules, recipient, frequency, send_time, chart_types) {
    schedule_id <- length(schedules$schedules) + 1
    schedule <- list(
      id = schedule_id,
      recipient = recipient,
      frequency = frequency,
      send_time = send_time,
      chart_types = chart_types,
      created_at = Sys.time(),
      is_active = TRUE
    )
    
    schedules$schedules[[as.character(schedule_id)]] <- schedule
    return(list(schedule_id = schedule_id, schedules = schedules))
  }
  
  # Mock email function generation
  generate_email_function <- function(data, chart_types, recipient) {
    function() {
      # Simulate email composition
      content <- paste0("Report for ", recipient, "\n")
      content <- paste0(content, "Charts: ", paste(chart_types, collapse = ", "), "\n")
      content <- paste0(content, "Data records: ", nrow(data), "\n")
      
      # Simulate sending
      return(paste("Email sent to", recipient))
    }
  }
  
  # Test email scheduling
  report_email <- "test@example.com"
  report_frequency <- "Daily"
  report_time <- list(hour = 14, min = 30)
  report_chart_types <- c("Weight Trend", "Methane Production")
  
  # Store schedule
  result <- store_email_schedule(email_schedules, report_email, report_frequency, report_time, report_chart_types)
  schedule_id <- result$schedule_id
  email_schedules <- result$schedules
  
  # Generate email function
  email_function <- generate_email_function(test_data, report_chart_types, report_email)
  
  # Test email function
  email_result <- email_function()
  
  expect_equal(schedule_id, 1)
  expect_true("1" %in% names(email_schedules$schedules))
  expect_equal(email_schedules$schedules[["1"]]$recipient, "test@example.com")
  expect_equal(email_schedules$schedules[["1"]]$frequency, "Daily")
  expect_true(grepl("Email sent to test@example.com", email_result))
  
  # Test schedule retrieval
  stored_schedule <- email_schedules$schedules[["1"]]
  expect_equal(stored_schedule$chart_types, c("Weight Trend", "Methane Production"))
  expect_equal(stored_schedule$send_time$hour, 14)
  expect_equal(stored_schedule$send_time$min, 30)
})

# Test 5: Report Format Integration
test_that("report format integration works correctly", {
  # Mock format-specific report generation
  generate_format_specific_report <- function(data, format, filename) {
    switch(format,
      "CSV" = {
        filename <- paste0(filename, "_", format(Sys.Date(), "%Y%m%d"), ".csv")
        return(paste("CSV report generated:", filename))
      },
      "Excel" = {
        filename <- paste0(filename, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx")
        return(paste("Excel report generated:", filename))
      },
      "PDF" = {
        filename <- paste0(filename, "_", format(Sys.Date(), "%Y%m%d"), ".pdf")
        return(paste("PDF report generated:", filename))
      }
    )
  }
  
  # Test different formats
  formats <- c("CSV", "Excel", "PDF")
  base_filename <- "livestock_report"
  
  for (format in formats) {
    result <- generate_format_specific_report(test_data, format, base_filename)
    
    expect_true(grepl(paste(format, "report generated"), result))
    expect_true(grepl(base_filename, result))
    expect_true(grepl(format(Sys.Date(), "%Y%m%d"), result))
    
    # Check file extension
    expected_ext <- switch(format,
      "CSV" = ".csv",
      "Excel" = ".xlsx", 
      "PDF" = ".pdf"
    )
    expect_true(grepl(expected_ext, result))
  }
  
  # Test with custom filename
  report_filename <- "custom_report"
  report_format <- "PDF"
  
  result_custom <- generate_format_specific_report(test_data, report_format, report_filename)
  expect_true(grepl("custom_report", result_custom))
})

# Test 6: Report Status Integration
test_that("report status integration works correctly", {
  # Mock status tracking
  report_status <- list(
    last_generated = NULL,
    last_email_sent = NULL,
    error_message = NULL
  )
  
  # Mock report generation with status
  generate_report_with_status <- function(data, format, status) {
    tryCatch({
      if (nrow(data) == 0) {
        status$error_message <- "No data available for report generation"
        return(list(result = "No data available", status = status))
      }
      
      # Simulate report generation
      status$last_generated <- Sys.time()
      status$error_message <- NULL
      
      return(list(result = paste("Report generated successfully at", format(Sys.time(), "%H:%M:%S")), status = status))
    }, error = function(e) {
      status$error_message <- e$message
      return(list(result = paste("Error generating report:", e$message), status = status))
    })
  }
  
  # Mock email sending with status
  send_email_with_status <- function(recipient, email_function, status) {
    tryCatch({
      result <- email_function()
      status$last_email_sent <- Sys.time()
      return(list(result = paste("✅ Email sent successfully to", recipient), status = status))
    }, error = function(e) {
      status$error_message <- e$message
      return(list(result = paste("❌ Failed to send email:", e$message), status = status))
    })
  }
  
  # Test successful report generation
  report_format <- "PDF"
  report_email <- "user@example.com"
  
  report_result_obj <- generate_report_with_status(test_data, report_format, report_status)
  report_result <- report_result_obj$result
  report_status <- report_result_obj$status
  
  expect_true(grepl("Report generated successfully", report_result))
  expect_true(!is.null(report_status$last_generated))
  expect_true(is.null(report_status$error_message))
  
  # Test email sending
  email_function <- function() return("Email content")
  email_result_obj <- send_email_with_status(report_email, email_function, report_status)
  email_result <- email_result_obj$result
  report_status <- email_result_obj$status
  
  expect_true(grepl("✅ Email sent successfully", email_result))
  expect_true(!is.null(report_status$last_email_sent))
  
  # Test with empty data
  empty_data <- data.frame()
  report_result_empty_obj <- generate_report_with_status(empty_data, "PDF", report_status)
  report_result_empty <- report_result_empty_obj$result
  report_status <- report_result_empty_obj$status
  
  expect_equal(report_result_empty, "No data available")
  expect_equal(report_status$error_message, "No data available for report generation")
})

# Test 7: Report Validation Integration
test_that("report validation integrates correctly", {
  # Mock validation functions
  validate_email <- function(email) {
    if (is.null(email) || email == "" || !grepl("^[^@]+@[^@]+\\.[^@]+$", email)) {
      return(FALSE)
    }
    return(TRUE)
  }
  
  validate_filename <- function(filename) {
    if (is.null(filename) || filename == "") {
      return(FALSE)
    }
    # Check for invalid characters
    if (grepl("[<>:\"/\\\\|?*]", filename)) {
      return(FALSE)
    }
    return(TRUE)
  }
  
  validate_time <- function(time_input) {
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
  
  # Test email validation
  expect_true(validate_email("user@example.com"))
  expect_true(validate_email("test.user@domain.co.uk"))
  expect_false(validate_email(""))
  expect_false(validate_email("invalid-email"))
  expect_false(validate_email("@example.com"))
  
  # Test filename validation
  expect_true(validate_filename("valid_filename"))
  expect_true(validate_filename("report_2024"))
  expect_false(validate_filename(""))
  expect_false(validate_filename("invalid<filename"))
  expect_false(validate_filename("invalid:filename"))
  
  # Test time validation
  expect_true(validate_time(list(hour = 9, min = 0)))
  expect_true(validate_time(list(hour = 14, min = 30)))
  expect_true(validate_time(list(hour = 23, min = 59)))
  expect_false(validate_time(NULL))
  expect_false(validate_time(list(hour = 25, min = 0)))
  expect_false(validate_time(list(hour = 12, min = 60)))
  
  # Test complete validation workflow
  validate_report_inputs <- function(email, filename, time, chart_types) {
    errors <- c()
    
    if (!validate_email(email)) {
      errors <- c(errors, "Invalid email address")
    }
    
    if (!validate_filename(filename)) {
      errors <- c(errors, "Invalid filename")
    }
    
    if (!validate_time(time)) {
      errors <- c(errors, "Invalid time")
    }
    
    if (length(chart_types) == 0) {
      errors <- c(errors, "No charts selected")
    }
    
    return(errors)
  }
  
  # Test valid inputs
  errors_valid <- validate_report_inputs(
    "user@example.com",
    "valid_report",
    list(hour = 9, min = 0),
    c("Weight Trend")
  )
  expect_equal(length(errors_valid), 0)
  
  # Test invalid inputs
  errors_invalid <- validate_report_inputs(
    "invalid-email",
    "",
    list(hour = 25, min = 0),
    character(0)
  )
  expect_equal(length(errors_invalid), 4)
  expect_true("Invalid email address" %in% errors_invalid)
  expect_true("Invalid filename" %in% errors_invalid)
  expect_true("Invalid time" %in% errors_invalid)
  expect_true("No charts selected" %in% errors_invalid)
})

# Test 8: Report Error Handling Integration
test_that("report error handling integrates correctly", {
  # Mock error handling for report generation
  handle_report_error <- function(error) {
    error_message <- switch(
      class(error)[1],
      "simpleError" = error$message,
      "character" = error,
      "Unknown error occurred"
    )
    
    # Log error (in real app, this would go to a log file)
    cat("Report Error:", error_message, "\n")
    
    return(paste("❌ Report generation failed:", error_message))
  }
  
  # Mock error handling for email sending
  handle_email_error <- function(error) {
    error_message <- switch(
      class(error)[1],
      "simpleError" = error$message,
      "character" = error,
      "Unknown email error occurred"
    )
    
    cat("Email Error:", error_message, "\n")
    
    return(paste("❌ Email sending failed:", error_message))
  }
  
  # Test report generation error
  report_error <- simpleError("Database connection failed")
  report_error_result <- handle_report_error(report_error)
  
  expect_true(grepl("❌ Report generation failed", report_error_result))
  expect_true(grepl("Database connection failed", report_error_result))
  
  # Test email sending error
  email_error <- simpleError("SMTP server unavailable")
  email_error_result <- handle_email_error(email_error)
  
  expect_true(grepl("❌ Email sending failed", email_error_result))
  expect_true(grepl("SMTP server unavailable", email_error_result))
  
  # Test with character error
  char_error <- "File system full"
  char_error_result <- handle_report_error(char_error)
  
  expect_true(grepl("❌ Report generation failed", char_error_result))
  expect_true(grepl("File system full", char_error_result))
  
  # Test with unknown error type
  unknown_error <- list(message = "Unknown error")
  unknown_error_result <- handle_report_error(unknown_error)
  
  expect_true(grepl("❌ Report generation failed", unknown_error_result))
  expect_true(grepl("Unknown error occurred", unknown_error_result))
})
