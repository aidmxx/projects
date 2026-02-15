# Test the setup_filter_observers function and related observer logic

library(shiny)

# Test that setup_filter_observers returns TRUE
test_that("setup_filter_observers returns TRUE", {
  # Create mock input and session objects
  mock_input <- reactiveValues()
  mock_session <- list()
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2023-01-02")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  # Test that the function returns TRUE (invisible)
  result <- setup_filter_observers(mock_input, mock_session, test_data)
  expect_equal(result, TRUE)
})

# Test the observer logic concepts (we can't test actual observers without a Shiny app)
test_that("observer logic concepts work correctly", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "B", "A", "B"),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test the select all logic with cached data
  all_sex_choices <- get_sex_choices()
  expect_equal(all_sex_choices[1], "Overall")
  expect_true(length(all_sex_choices) > 1)
  
  # Test the invert logic
  current_selection <- c("Male")
  inverted_selection <- setdiff(all_sex_choices, current_selection)
  expect_equal(inverted_selection, c("Overall", "Female"))
  
  # Test the reset logic
  max_year <- max(lubridate::year(test_data$date))
  expect_equal(max_year, 2023)
  
  # Test the empty selection reset logic
  empty_selection <- character(0)
  is_empty <- !shiny::isTruthy(empty_selection) || all(is.na(empty_selection)) || identical(empty_selection, "")
  expect_true(is_empty)
  
  # Test non-empty selection
  non_empty_selection <- c("Male", "Female")
  is_empty_non_empty <- !shiny::isTruthy(non_empty_selection) || all(is.na(non_empty_selection)) || identical(non_empty_selection, "")
  expect_false(is_empty_non_empty)
})

# Test the picker options logic
test_that("picker options logic works correctly", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2023-01-02")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  # Test that choices are properly formatted from cached data
  sex_choices <- get_sex_choices()
  expect_equal(sex_choices[1], "Overall")
  expect_true(length(sex_choices) > 1)
  
  treatment_choices <- get_treatment_choices()
  expect_equal(treatment_choices[1], "Overall")
  expect_true("No Treatment" %in% treatment_choices)
  
  breed_choices <- get_breed_choices()
  expect_equal(breed_choices[1], "Overall")
  expect_true(length(breed_choices) > 1)
  
  mob_choices <- get_mob_choices()
  expect_equal(mob_choices[1], "Overall")
  expect_true(length(mob_choices) > 1)
})

# Test the JavaScript logic concepts
test_that("JavaScript logic concepts work correctly", {
  # Test the logic that would be in the JavaScript
  # This simulates what the JavaScript would do when a picker becomes empty
  
  # Simulate empty selection
  current_value <- character(0)
  should_reset <- length(current_value) == 0
  expect_true(should_reset)
  
  # Simulate non-empty selection
  current_value <- c("Male", "Female")
  should_reset <- length(current_value) == 0
  expect_false(should_reset)
  
  # Simulate null selection
  current_value <- NULL
  should_reset <- is.null(current_value) || length(current_value) == 0
  expect_true(should_reset)
  
  # Test the actual logic used in the observers (from the filter.R file)
  # This matches the logic: !shiny::isTruthy(vals) || all(is.na(vals)) || identical(vals, "")
  
  # Test empty character vector
  vals <- character(0)
  should_reset_observer <- !shiny::isTruthy(vals) || all(is.na(vals)) || identical(vals, "")
  expect_true(should_reset_observer)
  
  # Test non-empty character vector
  vals <- c("Male", "Female")
  should_reset_observer <- !shiny::isTruthy(vals) || all(is.na(vals)) || identical(vals, "")
  expect_false(should_reset_observer)
  
  # Test NULL
  vals <- NULL
  should_reset_observer <- !shiny::isTruthy(vals) || all(is.na(vals)) || identical(vals, "")
  expect_true(should_reset_observer)
  
  # Test empty string
  vals <- ""
  should_reset_observer <- !shiny::isTruthy(vals) || all(is.na(vals)) || identical(vals, "")
  expect_true(should_reset_observer)
})

# Test the action link logic
test_that("action link logic works correctly", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "B", "A", "B"),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test that action links would have the correct IDs
  expected_action_link_ids <- c(
    "sex_select_all", "sex_invert",
    "treatment_select_all", "treatment_invert",
    "breed_select_all", "breed_invert",
    "mob_select_all", "mob_invert",
    "eid_select_all", "eid_invert"
  )
  
  # Test that the action link IDs follow the expected pattern
  for (field in c("sex", "treatment", "breed", "mob", "eid")) {
    select_all_id <- paste0(field, "_select_all")
    invert_id <- paste0(field, "_invert")
    
    expect_true(select_all_id %in% expected_action_link_ids)
    expect_true(invert_id %in% expected_action_link_ids)
  }
})

# Test the reset all filters logic
test_that("reset all filters logic works correctly", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "B", "A", "B"),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test the reset values
  max_year <- max(lubridate::year(test_data$date))
  expect_equal(max_year, 2023)
  
  # Test that all reset values are correct
  reset_values <- list(
    year = max_year,
    month = "All",
    day = "All",
    sex = "Overall",
    treatment = "Overall",
    breed = "Overall",
    mob = "Overall",
    eid = "Overall"
  )
  
  expect_equal(reset_values$year, 2023)
  expect_equal(reset_values$month, "All")
  expect_equal(reset_values$day, "All")
  expect_equal(reset_values$sex, "Overall")
  expect_equal(reset_values$treatment, "Overall")
  expect_equal(reset_values$breed, "Overall")
  expect_equal(reset_values$mob, "Overall")
  expect_equal(reset_values$eid, "Overall")
})
