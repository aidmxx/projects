# Test edge cases and complex scenarios for filter.R functions

# Test complex filter_data scenarios
test_that("filter_data handles edge cases with null inputs", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", NA, "B", NA),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test with null month and day
  input_null_dates <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  result_null_dates <- filter_data(test_data, input_null_dates)
  expect_equal(nrow(result_null_dates), 4)
  
  # Test with null sex
  input_null_sex <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  result_null_sex <- filter_data(test_data, input_null_sex)
  expect_equal(nrow(result_null_sex), 4)
  
  # Test with empty vectors
  input_empty_vectors <- list(year = 2023, month = NULL, day = NULL, sex = character(0), treatment = character(0), breed = character(0), mob = character(0))
  result_empty_vectors <- filter_data(test_data, input_empty_vectors)
  expect_equal(nrow(result_empty_vectors), 4)
})

test_that("filter_data handles complex treatment scenarios", {
  test_data <- data.frame(
    eid = 1:8,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04", "2023-01-05", "2023-01-06", "2023-01-07", "2023-01-08")),
    sex = rep(c("Male", "Female"), 4),
    treatment = c("A", NA, "B", NA, "C", NA, "D", NA),
    breed = rep(c("Angus", "Hereford"), 4),
    mob = rep(c("Mob1", "Mob2"), 4),
    finalpweight = rnorm(8, 500, 50)
  )
  
  # Test only "No Treatment" (no other treatments)
  input_only_no_treatment <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = c("No Treatment"), breed = NULL, mob = NULL)
  result_only_no_treatment <- filter_data(test_data, input_only_no_treatment)
  expect_equal(nrow(result_only_no_treatment), 4)
  expect_true(all(is.na(result_only_no_treatment$treatment)))
  
  # Test multiple treatments including "No Treatment"
  input_mixed_treatments <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = c("No Treatment", "A", "B"), breed = NULL, mob = NULL)
  result_mixed_treatments <- filter_data(test_data, input_mixed_treatments)
  expect_equal(nrow(result_mixed_treatments), 6)  # 4 NA + 1 A + 1 B
  expect_true(all(is.na(result_mixed_treatments$treatment) | result_mixed_treatments$treatment %in% c("A", "B")))
})

test_that("filter_data handles multiple selections correctly", {
  test_data <- data.frame(
    eid = 1:8,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04", "2023-01-05", "2023-01-06", "2023-01-07", "2023-01-08")),
    sex = rep(c("Male", "Female"), 4),
    treatment = rep(c("A", "B"), 4),
    breed = rep(c("Angus", "Hereford", "Charolais", "Simmental"), 2),
    mob = rep(c("Mob1", "Mob2", "Mob3", "Mob4"), 2),
    finalpweight = rnorm(8, 500, 50)
  )
  
  # Test multiple sex selections
  input_multiple_sex <- list(year = 2023, month = NULL, day = NULL, sex = c("Male", "Female"), treatment = NULL, breed = NULL, mob = NULL)
  result_multiple_sex <- filter_data(test_data, input_multiple_sex)
  expect_equal(nrow(result_multiple_sex), 8)
  
  # Test multiple breed selections
  input_multiple_breed <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = c("Angus", "Hereford"), mob = NULL)
  result_multiple_breed <- filter_data(test_data, input_multiple_breed)
  expect_equal(nrow(result_multiple_breed), 4)
  expect_true(all(result_multiple_breed$breed %in% c("Angus", "Hereford")))
  
  # Test multiple mob selections
  input_multiple_mob <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = c("Mob1", "Mob2"))
  result_multiple_mob <- filter_data(test_data, input_multiple_mob)
  expect_equal(nrow(result_multiple_mob), 4)
  expect_true(all(result_multiple_mob$mob %in% c("Mob1", "Mob2")))
})

# Test create_simplified_group_labels edge cases
test_that("create_simplified_group_labels handles complex scenarios", {
  # Test with multiple groups and varying columns
  test_data <- data.frame(
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "A", "B", "B"),
    breed = c("Angus", "Angus", "Angus", "Angus"),
    mob = c("Mob1", "Mob1", "Mob1", "Mob1"),
    eid = c("123", "123", "123", "123")
  )
  input <- list(sex = c("Male", "Female"), treatment = c("A", "B"), breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  expect_equal(length(result), 4)
  expect_true(all(grepl("Sex:", result)))
  expect_true(all(grepl("Treatment:", result)))
  expect_false(any(grepl("Breed:", result)))
  expect_false(any(grepl("Mob:", result)))
  expect_false(any(grepl("Eid:", result)))
})

test_that("create_simplified_group_labels handles all varying columns", {
  test_data <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    eid = c("123", "456")
  )
  input <- list(sex = c("Male", "Female"), treatment = c("A", "B"), breed = c("Angus", "Hereford"), mob = c("Mob1", "Mob2"), eid = c("123", "456"))
  result <- create_simplified_group_labels(test_data, input)
  
  expect_equal(length(result), 2)
  expect_true(all(grepl("Sex:", result)))
  expect_true(all(grepl("Treatment:", result)))
  expect_true(all(grepl("Breed:", result)))
  expect_true(all(grepl("Mob:", result)))
  expect_true(all(grepl("Eid:", result)))
})

test_that("create_simplified_group_labels handles single row data", {
  test_data <- data.frame(
    sex = "Male",
    treatment = "A",
    breed = "Angus",
    mob = "Mob1",
    eid = "123"
  )
  input <- list(sex = "Male", treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  expect_equal(length(result), 1)
  expect_true(grepl("Sex: Male", result))
  expect_true(grepl("Treatment: A", result))
  expect_true(grepl("Breed: Angus", result))
  expect_true(grepl("Mob: Mob1", result))
  expect_true(grepl("Eid: 123", result))
})

# Test get_common_filters_note edge cases
test_that("get_common_filters_note handles all varying columns", {
  test_data <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    eid = c("123", "456")
  )
  input <- list(sex = c("Male", "Female"), treatment = c("A", "B"), breed = c("Angus", "Hereford"), mob = c("Mob1", "Mob2"), eid = c("123", "456"))
  result <- get_common_filters_note(test_data, input)
  expect_equal(result, "")
})

test_that("get_common_filters_note handles mixed varying and common columns", {
  test_data <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "A"),
    breed = c("Angus", "Angus"),
    mob = c("Mob1", "Mob2"),
    eid = c("123", "123")
  )
  input <- list(sex = c("Male", "Female"), treatment = "A", breed = "Angus", mob = c("Mob1", "Mob2"), eid = "123")
  result <- get_common_filters_note(test_data, input)
  expect_true(grepl("Treatment: A", result))
  expect_true(grepl("Breed: Angus", result))
  expect_true(grepl("Eid: 123", result))
  expect_false(grepl("Sex:", result))
  expect_false(grepl("Mob:", result))
})

# Test choice functions with edge cases
test_that("choice functions handle empty data", {
  empty_data <- data.frame(
    eid = integer(0),
    date = as.Date(character(0)),
    sex = character(0),
    treatment = character(0),
    breed = character(0),
    mob = character(0),
    finalpweight = numeric(0)
  )
  
  # Test that choice functions work with cached data (not empty data)
  years <- get_year_choices()
  expect_type(years, "double")
  expect_true(length(years) > 0)
  
  sexes <- get_sex_choices()
  expect_equal(sexes[1], "Overall")
  expect_true(length(sexes) > 0)
  
  treatments <- get_treatment_choices()
  expect_equal(treatments[1], "Overall")
  expect_true("No Treatment" %in% treatments)
  
  breeds <- get_breed_choices()
  expect_equal(breeds[1], "Overall")
  expect_true(length(breeds) > 0)
  
  mobs <- get_mob_choices()
  expect_equal(mobs[1], "Overall")
  expect_true(length(mobs) > 0)
})

test_that("choice functions handle data with all NA treatments", {
  test_data <- data.frame(
    eid = 1:3,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03")),
    sex = c("Male", "Female", "Male"),
    treatment = c(NA, NA, NA),
    breed = c("Angus", "Hereford", "Angus"),
    mob = c("Mob1", "Mob2", "Mob1"),
    finalpweight = rnorm(3, 500, 50)
  )
  
  # Test that treatment choices include "No Treatment" from cached data
  treatments <- get_treatment_choices()
  expect_equal(treatments[1], "Overall")
  expect_true("No Treatment" %in% treatments)
})

test_that("choice functions handle data with mixed NA and non-NA treatments", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", NA, "B", NA),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test that treatment choices include "No Treatment" from cached data
  treatments <- get_treatment_choices()
  expect_equal(treatments[1], "Overall")
  expect_true("No Treatment" %in% treatments)
})

# Test month and day filtering edge cases
test_that("filter_data handles month name matching correctly", {
  test_data <- data.frame(
    eid = 1:6,
    date = as.Date(c("2023-01-15", "2023-02-15", "2023-03-15", "2023-04-15", "2023-05-15", "2023-06-15")),
    sex = rep(c("Male", "Female"), 3),
    treatment = rep(c("A", "B"), 3),
    breed = rep(c("Angus", "Hereford"), 3),
    mob = rep(c("Mob1", "Mob2"), 3),
    finalpweight = rnorm(6, 500, 50)
  )
  
  # Test each month
  months_to_test <- c("January", "February", "March", "April", "May", "June")
  for (i in 1:6) {
    input_month <- list(year = 2023, month = months_to_test[i], day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
    result_month <- filter_data(test_data, input_month)
    expect_equal(nrow(result_month), 1)
    expect_equal(lubridate::month(result_month$date), i)
  }
})

test_that("filter_data handles day filtering edge cases", {
  test_data <- data.frame(
    eid = 1:5,
    date = as.Date(c("2023-01-01", "2023-01-15", "2023-01-31", "2023-02-15", "2023-03-15")),
    sex = rep(c("Male", "Female"), length.out = 5),
    treatment = rep(c("A", "B"), length.out = 5),
    breed = rep(c("Angus", "Hereford"), length.out = 5),
    mob = rep(c("Mob1", "Mob2"), length.out = 5),
    finalpweight = rnorm(5, 500, 50)
  )
  
  # Test day 1
  input_day1 <- list(year = 2023, month = "January", day = 1, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  result_day1 <- filter_data(test_data, input_day1)
  expect_equal(nrow(result_day1), 1)
  expect_equal(lubridate::day(result_day1$date), 1)
  
  # Test day 31 (edge case)
  input_day31 <- list(year = 2023, month = "January", day = 31, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  result_day31 <- filter_data(test_data, input_day31)
  expect_equal(nrow(result_day31), 1)
  expect_equal(lubridate::day(result_day31$date), 31)
  
  # Test day that doesn't exist
  input_day_nonexistent <- list(year = 2023, month = "January", day = 30, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  result_day_nonexistent <- filter_data(test_data, input_day_nonexistent)
  expect_equal(nrow(result_day_nonexistent), 0)
})
