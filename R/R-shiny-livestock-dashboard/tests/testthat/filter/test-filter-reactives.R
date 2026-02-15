# Test reactive functions from filter.R

library(shiny)
library(dplyr)
library(lubridate)

# Mock reactive environment for testing
create_mock_reactive_env <- function() {
  env <- new.env()
  env$input <- reactiveValues()
  env$session <- list()
  return(env)
}

# Test build_filtered_reactives function
test_that("build_filtered_reactives returns proper structure", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Create mock reactive environment
  mock_env <- create_mock_reactive_env()
  mock_env$input$year <- 2023
  mock_env$input$month <- "All"
  mock_env$input$day <- "All"
  mock_env$input$sex <- "Overall"
  mock_env$input$treatment <- "Overall"
  mock_env$input$breed <- "Overall"
  mock_env$input$mob <- "Overall"
  mock_env$input$eid <- "Overall"
  
  # Test that function returns expected structure
  result <- build_filtered_reactives(mock_env$input, test_data, reactive(FALSE))
  
  expect_true(is.list(result))
  expect_true("filtered" %in% names(result))
  expect_true("processed_data" %in% names(result))
  expect_true("grouped_data" %in% names(result))
  expect_true(is.reactive(result$filtered))
  expect_true(is.reactive(result$processed_data))
  expect_true(is.reactive(result$grouped_data))
})

# Test that the underlying filtering logic works correctly
test_that("filtering logic works with year filtering", {
  test_data <- data.frame(
    eid = 1:6,
    date = as.Date(c("2023-01-01", "2023-01-02", "2024-01-01", "2024-01-02", "2025-01-01", "2025-01-02")),
    sex = rep(c("Male", "Female"), 3),
    treatment = rep(c("A", "B"), 3),
    breed = rep(c("Angus", "Hereford"), 3),
    mob = rep(c("Mob1", "Mob2"), 3),
    finalpweight = rnorm(6, 500, 50)
  )
  
  # Test the core filter_data function directly
  input_2023 <- list(year = 2023, month = "All", day = "All", sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
  filtered_data <- filter_data(test_data, input_2023)
  
  expect_equal(nrow(filtered_data), 2)
  expect_true(all(lubridate::year(filtered_data$date) == 2023))
})

# Test that group label creation works correctly
test_that("group label creation works correctly", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2023-01-02")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = rnorm(2, 500, 50)
  )
  
  # Test the core create_simplified_group_labels function directly
  input <- list(sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
  group_labels <- create_simplified_group_labels(test_data, input)
  
  expect_true(length(group_labels) == 2)
  expect_true(is.character(group_labels))
})

# Test that admin privileges work correctly in filtering
test_that("admin privileges work correctly in filtering", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test with admin privileges - EID filtering should work
  input_admin <- list(year = 2023, month = "All", day = "All", sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = c(1, 2))
  result_admin <- filter_data(test_data, input_admin, is_admin = TRUE)
  expect_equal(nrow(result_admin), 2)
  expect_true(all(result_admin$eid %in% c(1, 2)))
  
  # Test without admin privileges - EID filtering should be ignored
  result_user <- filter_data(test_data, input_admin, is_admin = FALSE)
  expect_equal(nrow(result_user), 4)  # All records should be returned
})

# Test that filtering handles empty results correctly
test_that("filtering handles empty results correctly", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2023-01-02")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = rnorm(2, 500, 50)
  )
  
  # Test filtering for a year that doesn't exist
  input_2024 <- list(year = 2024, month = "All", day = "All", sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
  filtered_data <- filter_data(test_data, input_2024)
  
  # Test that empty data is handled gracefully
  expect_equal(nrow(filtered_data), 0)
  expect_true(is.data.frame(filtered_data))
  
  # Test that group label creation handles empty data
  group_labels <- create_simplified_group_labels(filtered_data, input_2024)
  expect_equal(group_labels, character(0))
})
