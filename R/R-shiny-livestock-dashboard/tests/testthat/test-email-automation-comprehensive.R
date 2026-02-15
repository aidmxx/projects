# Safe Email Automation Tests
# Tests email automation functions with proper blastula mocking

library(testthat)

# Mock blastula functions globally before sourcing
blastula <<- list(
  compose_email = function(body, footer = NULL) {
    return(list(body = body, footer = footer))
  },
  smtp_send = function(email, from, to, subject, credentials) {
    cat("Mock sending email to:", to, "\n")
    return(TRUE)
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

# Mock database connection for testing
con <- list(
  execute = function(sql, params = NULL) {
    # Mock successful execution
    return(TRUE)
  },
  getQuery = function(sql, params = NULL) {
    # Return mock data for different queries
    sql_str <- as.character(sql)
    if (length(grep("SELECT.*email_schedules", sql_str)) > 0) {
      return(data.frame(
        id = 1:3,
        recipient_email = c("test1@example.com", "test2@example.com", "test3@example.com"),
        schedule_name = c("Test Schedule 1", "Test Schedule 2", "Test Schedule 3"),
        frequency = c("daily", "weekly", "monthly"),
        send_time = c("09:00:00", "08:00:00", "10:00:00"),
        send_date = c(NA, NA, NA),
        day_of_week = c(NA, 1L, NA),
        day_of_month = c(NA, NA, 1L),
        is_active = c(TRUE, TRUE, FALSE),
        created_at = Sys.time(),
        last_sent = c(NA, Sys.time() - 3600, NA),
        email_subject = c("Daily Report", "Weekly Report", "Monthly Report"),
        email_body = c("", "", ""),
        report_filters = c(NA, NA, NA),
        created_by = c("system", "system", "system"),
        stringsAsFactors = FALSE
      ))
    } else if (length(grep("SELECT.*animal_data", sql_str)) > 0) {
      return(data.frame(
        id = 1:5,
        species = c("Dog", "Cat", "Bird", "Fish", "Hamster"),
        weight = c(25.5, 4.2, 0.3, 0.1, 0.2),
        age = c(3, 2, 1, 0.5, 1.5),
        date = Sys.Date() - 0:4
      ))
    }
    return(data.frame())
  },
  isValid = function() {
    return(TRUE)
  }
)

# Make con available globally
assign("con", con, envir = .GlobalEnv)

# Mock DBI functions and assign to global environment
assign("dbExecute", function(con, sql, params = NULL) {
  return(con$execute(sql, params))
}, envir = .GlobalEnv)

assign("dbGetQuery", function(con, sql, params = NULL) {
  return(con$getQuery(sql, params))
}, envir = .GlobalEnv)

assign("dbIsValid", function(con) {
  return(con$isValid())
}, envir = .GlobalEnv)

# Override DBI::dbIsValid in the global environment
DBI <- list(
  dbIsValid = function(con) {
    return(con$isValid())
  }
)

# Email automation functions are already sourced by setup.R

# ---- Basic Database Functions Tests ----

test_that("store_email_schedule works correctly", {
  result <- store_email_schedule(
    "test@example.com",
    "Test Schedule",
    "daily",
    "09:00"
  )
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
})

test_that("get_email_schedules works correctly", {
  result <- get_email_schedules()
  
  expect_true(is.data.frame(result))
  expect_true("id" %in% names(result))
})

test_that("update_schedule_status works correctly", {
  # Test deactivation
  result_deactivate <- update_schedule_status(1, FALSE)
  expect_true(is.character(result_deactivate))
  expect_true(grepl("deactivated", result_deactivate))
  
  # Test activation
  result_activate <- update_schedule_status(1, TRUE)
  expect_true(is.character(result_activate))
  expect_true(grepl("activated", result_activate))
})

test_that("delete_email_schedule works correctly", {
  result <- delete_email_schedule(1)
  
  expect_true(is.character(result))
  expect_true(grepl("deleted successfully", result))
})

test_that("update_last_sent works correctly", {
  # Should not throw error
  expect_no_error(update_last_sent(1))
})

# ---- Scheduling Helper Functions Tests ----

test_that("schedule_daily_report works correctly", {
  result <- schedule_daily_report("daily@example.com", "10:00", "Daily Test Report")
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
})

test_that("schedule_weekly_report works correctly", {
  result <- schedule_weekly_report("weekly@example.com", 2, "11:00", "Weekly Test Report")
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
})

test_that("schedule_one_time_report works correctly", {
  result <- schedule_one_time_report("onetime@example.com", Sys.Date() + 1, "12:00", "One-time Test Report")
  
  expect_true(is.character(result))
  expect_true(grepl("Email schedule stored successfully", result))
})

# ---- Data Processing Functions Tests ----

test_that("get_filtered_data_for_schedule works with no filters", {
  result <- get_filtered_data_for_schedule(NULL)
  
  expect_true(is.data.frame(result))
})

test_that("get_filtered_data_for_schedule works with filters", {
  filters <- list(year = 2023, species = "Dog")
  result <- get_filtered_data_for_schedule(filters)
  
  expect_true(is.data.frame(result))
})

test_that("get_measure_column works with empty data", {
  empty_data <- data.frame()
  result <- get_measure_column(empty_data)
  
  expect_true(is.null(result))
})

test_that("get_measure_column works with data containing weight column", {
  test_data <- data.frame(
    id = 1:3,
    species = c("Dog", "Cat", "Bird"),
    weight = c(25.5, 4.2, 0.3),
    age = c(3, 2, 1)
  )
  result <- get_measure_column(test_data)
  
  expect_equal(result, "weight")
})

test_that("get_measure_column works with data containing mass column", {
  test_data <- data.frame(
    id = 1:3,
    species = c("Dog", "Cat", "Bird"),
    mass = c(25.5, 4.2, 0.3),
    age = c(3, 2, 1)
  )
  result <- get_measure_column(test_data)
  
  expect_equal(result, "mass")
})

test_that("get_measure_column works with no numeric columns", {
  test_data <- data.frame(
    species = c("Dog", "Cat", "Bird"),
    breed = c("Labrador", "Persian", "Canary"),
    color = c("Brown", "White", "Yellow")
  )
  result <- get_measure_column(test_data)
  
  expect_true(is.null(result))
})

test_that("get_measure_column works with numeric columns but no weight/mass columns", {
  test_data <- data.frame(
    id = 1:3,
    species = c("Dog", "Cat", "Bird"),
    age = c(3, 2, 1)
  )
  result <- get_measure_column(test_data)
  
  expect_equal(result, "id")
})

# ---- Email Generation Tests (with mocked blastula) ----

test_that("generate_scheduled_email_report works correctly", {
  test_data <- data.frame(
    id = 1:3,
    species = c("Dog", "Cat", "Bird"),
    weight = c(25.5, 4.2, 0.3),
    age = c(3, 2, 1)
  )
  
  # Create a mock schedule object
  schedule <- list(
    email_subject = "Test Report",
    chart_types = c("Time Series", "Distribution")
  )
  
  # Create report filters
  report_filters <- list(year = 2023, species = "Dog")
  
  result <- generate_scheduled_email_report(
    test_data,
    schedule,
    report_filters
  )
  
  expect_true(is.character(result))
  expect_true(grepl("Livestock Dashboard", result))
})

test_that("send_no_data_email works correctly", {
  # Create a mock schedule object
  schedule <- list(
    schedule_name = "Test Schedule",
    recipient_email = "test@example.com",
    email_subject = "Test Subject"
  )
  
  # The function doesn't return anything (returns NULL), just sends email
  result <- send_no_data_email(schedule)
  
  # Should not throw an error
  expect_no_error(send_no_data_email(schedule))
  # Function returns NULL (no return statement)
  expect_true(is.null(result))
})

test_that("get_due_schedules function covers lines 193-221", {
  # Test the actual get_due_schedules function to cover lines 193-221
  # This calls the real function with specific mock data to trigger the uncovered lines
  
  # Get current time and create schedules that will trigger the conditions
  current_time <- Sys.time()
  current_hour <- lubridate::hour(current_time)
  current_minute <- lubridate::minute(current_time)
  current_weekday <- lubridate::wday(current_time)
  current_day <- lubridate::day(current_time)
  
  # Create send time that's within 5 minutes of current time
  send_hour <- current_hour
  send_minute <- current_minute + 2  # 2 minutes from now
  if (send_minute >= 60) {
    send_hour <- send_hour + 1
    send_minute <- send_minute - 60
  }
  send_time_str <- sprintf("%02d:%02d:00", send_hour, send_minute)
  
  # Mock schedules that will trigger the specific conditions
  mock_schedules <- data.frame(
    id = c(1, 2, 3, 4),
    frequency = c("daily", "weekly", "monthly", "once"),
    send_time = c(send_time_str, send_time_str, send_time_str, send_time_str),
    last_sent = c(NA, NA, NA, NA),  # Never sent to trigger is_due logic
    is_active = c(TRUE, TRUE, TRUE, TRUE),
    day_of_week = c(NA, current_weekday, NA, NA),  # Current weekday for weekly
    day_of_month = c(NA, NA, current_day, NA),  # Current day for monthly
    send_date = c(NA, NA, NA, as.character(Sys.Date())),  # Today for once
    stringsAsFactors = FALSE
  )
  
  # Mock the dbGetQuery function to return our test data
  original_dbGetQuery <- dbGetQuery
  assign("dbGetQuery", function(con, sql) {
    if (grepl("SELECT.*email_schedules", sql)) {
      return(mock_schedules)
    }
    return(data.frame())
  }, envir = .GlobalEnv)
  
  # Also ensure dbIsValid is properly mocked
  assign("dbIsValid", function(con) { return(TRUE) }, envir = .GlobalEnv)
  
  # Call the actual function
  result <- get_due_schedules()
  
  # Restore original functions
  assign("dbGetQuery", original_dbGetQuery, envir = .GlobalEnv)
  assign("dbIsValid", con$isValid, envir = .GlobalEnv)
  
  # Verify the function returns a data frame
  expect_true(is.data.frame(result))
  
  # The function should have processed the schedules and determined which are due
  # This will have executed the uncovered lines 193-221
})

test_that("get_due_schedules handles different time formats", {
  # Test the time parsing logic in lines 176-182
  # This covers HH:MM format parsing and invalid format handling
  
  # Get current time for realistic testing
  current_time <- Sys.time()
  current_hour <- lubridate::hour(current_time)
  current_minute <- lubridate::minute(current_time)
  
  # Create send time in HH:MM format (2 minutes from now)
  send_hour <- current_hour
  send_minute <- current_minute + 2
  if (send_minute >= 60) {
    send_hour <- send_hour + 1
    send_minute <- send_minute - 60
  }
  send_time_hhmm <- sprintf("%02d:%02d", send_hour, send_minute)
  
  # Mock schedules with different time formats to test parsing logic
  mock_schedules <- data.frame(
    id = c(1, 2, 3),
    frequency = c("daily", "daily", "daily"),
    send_time = c(
      send_time_hhmm,  # HH:MM format - should trigger lines 176-180
      "invalid_time",  # Invalid format - should trigger line 182 (next)
      "09:00:00"       # HH:MM:SS format - should trigger lines 171-175
    ),
    last_sent = c(NA, NA, NA),
    is_active = c(TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )
  
  # Mock the dbGetQuery function to return our test data
  original_dbGetQuery <- dbGetQuery
  assign("dbGetQuery", function(con, sql) {
    if (grepl("SELECT.*email_schedules", sql)) {
      return(mock_schedules)
    }
    return(data.frame())
  }, envir = .GlobalEnv)
  
  # Also ensure dbIsValid is properly mocked
  assign("dbIsValid", function(con) { return(TRUE) }, envir = .GlobalEnv)
  
  # Call the actual function
  result <- get_due_schedules()
  
  # Restore original functions
  assign("dbGetQuery", original_dbGetQuery, envir = .GlobalEnv)
  assign("dbIsValid", con$isValid, envir = .GlobalEnv)
  
  # Verify the function returns a data frame
  expect_true(is.data.frame(result))
  
  # The function should have processed the schedules and handled different time formats
  # This will have executed the uncovered lines 176-182
})

test_that("get_email_schedules handles database connection errors", {
  # Test the error handling logic in lines 73-80
  # This covers database connection existence and validity checks
  
  # Test case 1: Database connection doesn't exist
  # Remove the 'con' object from global environment
  if (exists("con", envir = .GlobalEnv)) {
    rm("con", envir = .GlobalEnv)
  }
  
  # Mock dbIsValid to handle the case when con doesn't exist
  assign("dbIsValid", function(con) { 
    if (!exists("con", envir = .GlobalEnv)) {
      return(FALSE)
    }
    return(con$isValid())
  }, envir = .GlobalEnv)
  
  # Call get_email_schedules when 'con' doesn't exist
  result1 <- get_email_schedules()
  
  # Should return empty data frame
  expect_true(is.data.frame(result1))
  expect_equal(nrow(result1), 0)
  
  # Test case 2: Database connection exists but is invalid
  # Create an invalid connection object
  invalid_con <- list(isValid = function() { return(FALSE) })
  assign("con", invalid_con, envir = .GlobalEnv)
  
  # Also mock the dbIsValid function to return FALSE
  assign("dbIsValid", function(con) { return(FALSE) }, envir = .GlobalEnv)
  
  # Call get_email_schedules with invalid connection
  result2 <- get_email_schedules()
  
  # Should return empty data frame
  expect_true(is.data.frame(result2))
  expect_equal(nrow(result2), 0)
  
  # Restore valid connection and functions for other tests
  assign("con", con, envir = .GlobalEnv)
  assign("dbIsValid", con$isValid, envir = .GlobalEnv)
})

test_that("store_email_schedule handles database connection errors", {
  # Test the error handling logic in lines 32-38
  # This covers database connection existence and validity checks in store_email_schedule
  
  # Test case 1: Database connection doesn't exist
  # Remove the 'con' object from global environment
  if (exists("con", envir = .GlobalEnv)) {
    rm("con", envir = .GlobalEnv)
  }
  
  # Mock dbIsValid to handle the case when con doesn't exist
  assign("dbIsValid", function(con) { 
    if (!exists("con", envir = .GlobalEnv)) {
      return(FALSE)
    }
    return(con$isValid())
  }, envir = .GlobalEnv)
  
  # Call store_email_schedule when 'con' doesn't exist
  result1 <- store_email_schedule("test@example.com", "daily", "09:00")
  
  # Should return error message (check for any error message)
  expect_true(is.character(result1))
  expect_true(grepl("❌", result1))  # Check for error indicator
  
  # Test case 2: Database connection exists but is invalid
  # Create an invalid connection object
  invalid_con <- list(isValid = function() { return(FALSE) })
  assign("con", invalid_con, envir = .GlobalEnv)
  
  # Mock dbIsValid to return FALSE
  assign("dbIsValid", function(con) { return(FALSE) }, envir = .GlobalEnv)
  
  # Call store_email_schedule with invalid connection
  result2 <- store_email_schedule("test@example.com", "daily", "09:00")
  
  # Should return error message (check for any error message)
  expect_true(is.character(result2))
  expect_true(grepl("❌", result2))  # Check for error indicator
  
  # Restore valid connection and functions for other tests
  assign("con", con, envir = .GlobalEnv)
  assign("dbIsValid", con$isValid, envir = .GlobalEnv)
})

test_that("get_due_schedules handles empty schedules", {
  # Test the empty schedules logic in lines 160-162
  # This covers the case when no schedules are found in the database
  
  # Mock the dbGetQuery function to return empty data frame
  original_dbGetQuery <- dbGetQuery
  assign("dbGetQuery", function(con, sql) {
    if (grepl("SELECT.*email_schedules", sql)) {
      return(data.frame())  # Empty data frame
    }
    return(data.frame())
  }, envir = .GlobalEnv)
  
  # Also ensure dbIsValid is properly mocked
  assign("dbIsValid", function(con) { return(TRUE) }, envir = .GlobalEnv)
  
  # Call get_due_schedules with empty schedules
  result <- get_due_schedules()
  
  # Should return empty data frame
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
  
  # Restore original functions
  assign("dbGetQuery", original_dbGetQuery, envir = .GlobalEnv)
  assign("dbIsValid", con$isValid, envir = .GlobalEnv)
})

test_that("get_email_schedules covers lines 78-79 when con doesn't exist", {
  # This test specifically covers lines 78-79 in get_email_schedules
  # where it checks if con exists and returns empty data frame
  
  # Store original con
  original_con <- con
  
  # Remove the 'con' object from global environment
  if (exists("con", envir = .GlobalEnv)) {
    rm("con", envir = .GlobalEnv)
  }
  
  # Temporarily override the exists function to return FALSE for 'con'
  # This will make the !exists("con") check return TRUE
  original_exists <- exists
  assign("exists", function(x, ...) {
    if (x == "con") {
      return(FALSE)
    }
    return(original_exists(x, ...))
  }, envir = .GlobalEnv)
  
  # Call get_email_schedules when 'con' doesn't exist
  result <- get_email_schedules()
  
  # Should return empty data frame
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
  
  # Restore original functions and con
  assign("exists", original_exists, envir = .GlobalEnv)
  assign("con", original_con, envir = .GlobalEnv)
  assign("dbIsValid", con$isValid, envir = .GlobalEnv)
})

test_that("store_email_schedule covers line 68 when con doesn't exist", {
  # This test specifically covers line 68 in store_email_schedule
  # where it returns error message when con doesn't exist
  
  # Store original con
  original_con <- con
  
  # Remove the 'con' object from global environment
  if (exists("con", envir = .GlobalEnv)) {
    rm("con", envir = .GlobalEnv)
  }
  
  # Temporarily override the exists function to return FALSE for 'con'
  # This will make the !exists("con") check return TRUE
  original_exists <- exists
  assign("exists", function(x, ...) {
    if (x == "con") {
      return(FALSE)
    }
    return(original_exists(x, ...))
  }, envir = .GlobalEnv)
  
  # Call store_email_schedule when 'con' doesn't exist
  result <- store_email_schedule("test@example.com", "daily", "09:00")
  
  # Should return error message
  expect_true(is.character(result))
  expect_true(grepl("❌", result))
  expect_true(grepl("Database connection 'con' does not exist", result))
  
  # Restore original functions and con
  assign("exists", original_exists, envir = .GlobalEnv)
  assign("con", original_con, envir = .GlobalEnv)
  assign("dbIsValid", con$isValid, envir = .GlobalEnv)
})

test_that("store_email_schedule covers line 68 in error handler", {
  # This test specifically covers line 68 in the error handler of store_email_schedule
  # where it catches "object 'con' not found" or "unused argument (con)" errors
  
  # Store original con
  original_con <- con
  
  # Remove the 'con' object from global environment
  if (exists("con", envir = .GlobalEnv)) {
    rm("con", envir = .GlobalEnv)
  }
  
  # Override exists to return TRUE for 'con' so it passes the !exists check
  # but then dbIsValid will fail because con doesn't actually exist
  original_exists <- exists
  assign("exists", function(x, ...) {
    if (x == "con") {
      return(TRUE)  # Make !exists("con") return FALSE
    }
    return(original_exists(x, ...))
  }, envir = .GlobalEnv)
  
  # Mock dbIsValid to throw an error when con doesn't exist
  assign("dbIsValid", function(con) {
    stop("object 'con' not found")
  }, envir = .GlobalEnv)
  
  # Call store_email_schedule - this should trigger the error handler
  result <- store_email_schedule("test@example.com", "daily", "09:00")
  
  # Should return error message from the error handler
  expect_true(is.character(result))
  expect_true(grepl("❌", result))
  expect_true(grepl("Database connection 'con' does not exist", result))
  
  # Restore original functions and con
  assign("exists", original_exists, envir = .GlobalEnv)
  assign("con", original_con, envir = .GlobalEnv)
  assign("dbIsValid", con$isValid, envir = .GlobalEnv)
})

cat("Safe email automation tests completed!\n")