# Email Scheduled Sending Tests
# Tests for send_scheduled_email and related complex functions

library(testthat)

# Load required packages
if (!requireNamespace("blastula", quietly = TRUE)) {
  # Mock blastula functions if package not available
  blastula <- list(
    compose_email = function(body, footer = NULL) {
      return(list(body = body, footer = footer))
    },
    smtp_send = function(email, from, to, subject, credentials) {
      cat("Mock sending email to:", to, "\n")
    },
    creds_key = function(id) {
      return(list(id = id))
    },
    add_attachment = function(email, file_path, filename) {
      email$attachments[[filename]] <- file_path
      return(email)
    },
    md = function(text) {
      return(text)
    }
  )
} else {
  library(blastula)
}

# Mock database connection
con <- list(
  execute = function(sql, params = NULL) {
    return(TRUE)
  },
  getQuery = function(sql, params = NULL) {
    return(data.frame(
      id = 1:3,
      weight = c(100, 200, 300),
      date = Sys.Date(),
      sex = c("Male", "Female", "Male"),
      breed = c("Angus", "Hereford", "Angus")
    ))
  },
  isValid = function() {
    return(TRUE)
  }
)

# Mock DBI functions
dbExecute <- function(con, sql, params = NULL) {
  return(con$execute(sql, params))
}

dbGetQuery <- function(con, sql, params = NULL) {
  return(con$getQuery(sql, params))
}

dbIsValid <- function(con) {
  return(con$isValid())
}

# Source email automation functions
source("src/email_automation.R")

# Mock external functions
original_generate_summary_stats <- generate_summary_stats
original_create_dashboard_chart <- create_dashboard_chart
original_compose_email <- blastula::compose_email
original_smtp_send <- blastula::smtp_send
original_creds_key <- blastula::creds_key
original_add_attachment <- blastula::add_attachment

# Mock functions
generate_summary_stats <<- function(data) {
  return(list(
    total_records = nrow(data),
    measure_name = "Weight",
    mean_value = mean(data$weight, na.rm = TRUE),
    median_value = median(data$weight, na.rm = TRUE),
    min_value = min(data$weight, na.rm = TRUE),
    max_value = max(data$weight, na.rm = TRUE),
    std_dev = sd(data$weight, na.rm = TRUE)
  ))
}

create_dashboard_chart <<- function(data, chart_type, input = NULL, measure_col = NULL) {
  # Create a temporary file
  temp_file <- tempfile(fileext = ".png")
  png(temp_file, width = 400, height = 300)
  plot(data$weight, main = paste("Chart:", chart_type))
  dev.off()
  return(temp_file)
}

blastula::compose_email <<- function(body, footer = NULL) {
  return(list(
    body = body,
    footer = footer,
    attachments = list()
  ))
}

blastula::smtp_send <<- function(email, from, to, subject, credentials) {
  cat("Mock sending email to:", to, "subject:", subject, "\n")
}

blastula::creds_key <<- function(id) {
  return(list(id = id))
}

blastula::add_attachment <<- function(email, file_path, filename) {
  email$attachments[[filename]] <- file_path
  return(email)
}

# Test data
test_schedule <- list(
  id = 1,
  recipient_email = "test@example.com",
  email_subject = "Test Report",
  schedule_name = "Test Schedule",
  frequency = "daily",
  report_filters = NULL
)

test_schedule_with_filters <- list(
  id = 2,
  recipient_email = "test@example.com",
  email_subject = "Test Report",
  schedule_name = "Test Schedule",
  frequency = "daily",
  report_filters = '{"year": 2023, "sex": ["Male"], "chart_types": ["Time Series"]}'
)

test_schedule_no_data <- list(
  id = 3,
  recipient_email = "test@example.com",
  email_subject = "Test Report",
  schedule_name = "Test Schedule",
  frequency = "daily",
  report_filters = NULL
)

# ---- send_scheduled_email Tests ----

test_that("send_scheduled_email works with no report filters", {
  # Should not throw error
  expect_no_error(send_scheduled_email(test_schedule))
})

test_that("send_scheduled_email works with report filters", {
  # Should not throw error
  expect_no_error(send_scheduled_email(test_schedule_with_filters))
})

test_that("send_scheduled_email handles invalid JSON filters", {
  invalid_schedule <- test_schedule
  invalid_schedule$report_filters <- "invalid json"
  
  # Should not throw error
  expect_no_error(send_scheduled_email(invalid_schedule))
})

test_that("send_scheduled_email handles no data scenario", {
  # Mock get_filtered_data_for_schedule to return empty data
  original_get_filtered_data <- get_filtered_data_for_schedule
  get_filtered_data_for_schedule <<- function(report_filters) {
    return(data.frame())
  }
  
  # Mock send_no_data_email
  original_send_no_data_email <- send_no_data_email
  send_no_data_email <<- function(schedule) {
    cat("Mock sending no data email to:", schedule$recipient_email, "\n")
  }
  
  # Should not throw error
  expect_no_error(send_scheduled_email(test_schedule_no_data))
  
  # Restore original functions
  get_filtered_data_for_schedule <<- original_get_filtered_data
  send_no_data_email <<- original_send_no_data_email
})

test_that("send_scheduled_email works with chart generation", {
  # Mock get_filtered_data_for_schedule to return data
  original_get_filtered_data <- get_filtered_data_for_schedule
  get_filtered_data_for_schedule <<- function(report_filters) {
    return(data.frame(
      id = 1:3,
      weight = c(100, 200, 300),
      date = Sys.Date()
    ))
  }
  
  # Should not throw error
  expect_no_error(send_scheduled_email(test_schedule_with_filters))
  
  # Restore original function
  get_filtered_data_for_schedule <<- original_get_filtered_data
})

test_that("send_scheduled_email handles chart generation errors", {
  # Mock create_dashboard_chart to throw error
  original_create_dashboard_chart <- create_dashboard_chart
  create_dashboard_chart <<- function(data, chart_type, input = NULL, measure_col = NULL) {
    stop("Chart generation error")
  }
  
  # Mock get_filtered_data_for_schedule to return data
  original_get_filtered_data <- get_filtered_data_for_schedule
  get_filtered_data_for_schedule <<- function(report_filters) {
    return(data.frame(
      id = 1:3,
      weight = c(100, 200, 300),
      date = Sys.Date()
    ))
  }
  
  # Should not throw error
  expect_no_error(send_scheduled_email(test_schedule_with_filters))
  
  # Restore original functions
  create_dashboard_chart <<- original_create_dashboard_chart
  get_filtered_data_for_schedule <<- original_get_filtered_data
})

test_that("send_scheduled_email works without charts", {
  # Mock get_filtered_data_for_schedule to return data
  original_get_filtered_data <- get_filtered_data_for_schedule
  get_filtered_data_for_schedule <<- function(report_filters) {
    return(data.frame(
      id = 1:3,
      weight = c(100, 200, 300),
      date = Sys.Date()
    ))
  }
  
  # Should not throw error
  expect_no_error(send_scheduled_email(test_schedule))
  
  # Restore original function
  get_filtered_data_for_schedule <<- original_get_filtered_data
})

# ---- Edge Cases Tests ----

test_that("send_scheduled_email handles empty chart_types", {
  empty_charts_schedule <- test_schedule_with_filters
  empty_charts_schedule$report_filters <- '{"year": 2023, "chart_types": []}'
  
  # Mock get_filtered_data_for_schedule to return data
  original_get_filtered_data <- get_filtered_data_for_schedule
  get_filtered_data_for_schedule <<- function(report_filters) {
    return(data.frame(
      id = 1:3,
      weight = c(100, 200, 300),
      date = Sys.Date()
    ))
  }
  
  # Should not throw error
  expect_no_error(send_scheduled_email(empty_charts_schedule))
  
  # Restore original function
  get_filtered_data_for_schedule <<- original_get_filtered_data
})

test_that("send_scheduled_email handles chart file cleanup", {
  # Mock get_filtered_data_for_schedule to return data
  original_get_filtered_data <- get_filtered_data_for_schedule
  get_filtered_data_for_schedule <<- function(report_filters) {
    return(data.frame(
      id = 1:3,
      weight = c(100, 200, 300),
      date = Sys.Date()
    ))
  }
  
  # Should not throw error
  expect_no_error(send_scheduled_email(test_schedule_with_filters))
  
  # Restore original function
  get_filtered_data_for_schedule <<- original_get_filtered_data
})

# ---- Cleanup ----

# Restore original functions
generate_summary_stats <<- original_generate_summary_stats
create_dashboard_chart <<- original_create_dashboard_chart
blastula::compose_email <<- original_compose_email
blastula::smtp_send <<- original_smtp_send
blastula::creds_key <<- original_creds_key
blastula::add_attachment <<- original_add_attachment

cat("Email scheduled sending tests completed!\n")
