# Test filter functions
source("tests/testthat/setup.R")

test_that("filter_data works with basic year filtering", {
  # Test data with different years
  test_data <- data.frame(
    eid = 1:6,
    date = as.Date(c("2023-01-01", "2023-06-15", "2024-01-01", "2024-06-15", "2025-01-01", "2025-06-15")),
    sex = rep(c("Male", "Female"), 3),
    treatment = rep(c("A", "B"), 3),
    breed = rep(c("Angus", "Hereford"), 3),
    mob = rep(c("Mob1", "Mob2"), 3),
    finalpweight = rnorm(6, 500, 50)
  )
  
  # Test year filtering
  input_2023 <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  result_2023 <- filter_data(test_data, input_2023)
  
  expect_equal(nrow(result_2023), 2)
  expect_true(all(lubridate::year(result_2023$date) == 2023))
})

test_that("filter_data works with month filtering", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-15", "2023-06-15", "2023-01-20", "2023-06-20")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  input_jan <- list(year = 2023, month = "January", day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  result_jan <- filter_data(test_data, input_jan)
  
  expect_equal(nrow(result_jan), 2)
  expect_true(all(lubridate::month(result_jan$date) == 1))
})

test_that("filter_data works with sex filtering", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  input_male <- list(year = 2023, month = NULL, day = NULL, sex = c("Male"), treatment = NULL, breed = NULL, mob = NULL)
  result_male <- filter_data(test_data, input_male)
  
  expect_equal(nrow(result_male), 2)
  expect_true(all(result_male$sex == "Male"))
})

test_that("filter_data works with treatment filtering including NA", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = rep(c("Male", "Female"), 2),
    treatment = c("A", NA, "B", NA),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test "No Treatment" filtering
  input_no_treatment <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = c("No Treatment"), breed = NULL, mob = NULL)
  result_no_treatment <- filter_data(test_data, input_no_treatment)
  
  expect_equal(nrow(result_no_treatment), 2)
  expect_true(all(is.na(result_no_treatment$treatment)))
})

test_that("filter_data works with breed filtering", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = c("Angus", "Hereford", "Angus", "Charolais"),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  input_angus <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = c("Angus"), mob = NULL)
  result_angus <- filter_data(test_data, input_angus)
  
  expect_equal(nrow(result_angus), 2)
  expect_true(all(result_angus$breed == "Angus"))
})

test_that("filter_data works with mob filtering", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = c("Mob1", "Mob2", "Mob1", "Mob3"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  input_mob1 <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = c("Mob1"))
  result_mob1 <- filter_data(test_data, input_mob1)
  
  expect_equal(nrow(result_mob1), 2)
  expect_true(all(result_mob1$mob == "Mob1"))
})

test_that("filter_data handles multiple filters", {
  test_data <- data.frame(
    eid = 1:8,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-06-01", "2023-06-02", "2024-01-01", "2024-01-02", "2024-06-01", "2024-06-02")),
    sex = rep(c("Male", "Female"), 4),
    treatment = rep(c("A", "B"), 4),
    breed = rep(c("Angus", "Hereford"), 4),
    mob = rep(c("Mob1", "Mob2"), 4),
    finalpweight = rnorm(8, 500, 50)
  )
  
  input_complex <- list(
    year = 2023, 
    month = "January", 
    day = NULL, 
    sex = c("Male"), 
    treatment = c("A"), 
    breed = c("Angus"), 
    mob = c("Mob1")
  )
  result_complex <- filter_data(test_data, input_complex)
  
  expect_equal(nrow(result_complex), 1)
  expect_equal(result_complex$sex, "Male")
  expect_equal(result_complex$treatment, "A")
  expect_equal(result_complex$breed, "Angus")
  expect_equal(result_complex$mob, "Mob1")
})

test_that("filter_data requires year input", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2023-01-02")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = rnorm(2, 500, 50)
  )
  
  input_no_year <- list(year = NULL, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  
  expect_error(filter_data(test_data, input_no_year), "Year is required for filtering")
})

test_that("get_year_choices returns unique years", {
  # Test that get_year_choices returns years from cached data
  years <- get_year_choices()
  
  # Verify it returns a numeric vector of years
  expect_type(years, "double")
  expect_true(length(years) > 0)
  
  # Verify years are sorted (as per the cache implementation)
  expect_equal(years, sort(years))
  
  # Verify all years are reasonable (between 1900 and 2100)
  expect_true(all(years >= 1900 & years <= 2100))
})

test_that("get_month_choices returns correct months", {
  months <- get_month_choices()
  expect_equal(months[1], "All")
  expect_equal(months[2], "January")
  expect_equal(months[13], "December")
})

test_that("get_day_choices returns correct days", {
  days <- get_day_choices()
  expect_equal(days[1], "All")
  expect_equal(as.numeric(days[2]), 1)
  expect_equal(as.numeric(days[32]), 31)
})

test_that("get_sex_choices includes Overall", {
  # Test that get_sex_choices returns choices from cached data
  sex_choices <- get_sex_choices()
  
  # Verify it returns a character vector
  expect_type(sex_choices, "character")
  expect_true(length(sex_choices) > 0)
  
  # Verify "Overall" is the first choice
  expect_equal(sex_choices[1], "Overall")
  
  # Verify it contains some sex values (exact values depend on actual data)
  expect_true(length(sex_choices) > 1)
})

test_that("get_treatment_choices includes No Treatment", {
  # Test that get_treatment_choices returns choices from cached data
  treatment_choices <- get_treatment_choices()
  
  # Verify it returns a character vector
  expect_type(treatment_choices, "character")
  expect_true(length(treatment_choices) > 0)
  
  # Verify "Overall" is the first choice
  expect_equal(treatment_choices[1], "Overall")
  
  # Verify "No Treatment" is included (as per cache implementation)
  expect_true("No Treatment" %in% treatment_choices)
})

test_that("get_breed_choices includes Overall", {
  # Test that get_breed_choices returns choices from cached data
  breed_choices <- get_breed_choices()
  
  # Verify it returns a character vector
  expect_type(breed_choices, "character")
  expect_true(length(breed_choices) > 0)
  
  # Verify "Overall" is the first choice
  expect_equal(breed_choices[1], "Overall")
  
  # Verify it contains some breed values (exact values depend on actual data)
  expect_true(length(breed_choices) > 1)
})

test_that("get_mob_choices includes Overall", {
  # Test that get_mob_choices returns choices from cached data
  mob_choices <- get_mob_choices()
  
  # Verify it returns a character vector
  expect_type(mob_choices, "character")
  expect_true(length(mob_choices) > 0)
  
  # Verify "Overall" is the first choice
  expect_equal(mob_choices[1], "Overall")
  
  # Verify it contains some mob values (exact values depend on actual data)
  expect_true(length(mob_choices) > 1)
})

# Test get_eid_choices function
test_that("get_eid_choices returns cached eids", {
  # Test that get_eid_choices returns choices from cached data
  eid_choices <- get_eid_choices()
  
  # Verify it returns a character vector
  expect_type(eid_choices, "character")
  expect_true(length(eid_choices) > 0)
  
  # Verify "Overall" is the first choice
  expect_equal(eid_choices[1], "Overall")
  expect_true(is.character(eid_choices))
})

# Test measure_labels constant
test_that("measure_labels contains expected measurements", {
  expect_equal(measure_labels["finalpweight"], c(finalpweight = "Final processed weight (kg)"))
  expect_equal(measure_labels["methane"], c(methane = "Methane production (g/day)"))
  expect_equal(measure_labels["animalvalue"], c(animalvalue = "Animal value ($)"))
  expect_true(length(measure_labels) >= 7)
})

# Test create_simplified_group_labels function
test_that("create_simplified_group_labels handles empty data", {
  empty_df <- data.frame()
  result <- create_simplified_group_labels(empty_df, list())
  expect_equal(result, character(0))
})

test_that("create_simplified_group_labels handles single group with all Overall", {
  test_data <- data.frame(
    sex = "Overall",
    treatment = "Overall", 
    breed = "Overall",
    mob = "Overall",
    eid = "Overall"
  )
  input <- list(sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
  result <- create_simplified_group_labels(test_data, input)
  expect_equal(result, "Overall Average")
})

test_that("create_simplified_group_labels handles single group with specific values", {
  test_data <- data.frame(
    sex = "Male",
    treatment = "A",
    breed = "Angus", 
    mob = "Mob1",
    eid = "123"
  )
  input <- list(sex = "Male", treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  expect_true(grepl("Sex: Male", result))
  expect_true(grepl("Treatment: A", result))
  expect_true(grepl("Breed: Angus", result))
  expect_true(grepl("Mob: Mob1", result))
  expect_true(grepl("Eid: 123", result))
})

test_that("create_simplified_group_labels handles NA treatment values", {
  test_data <- data.frame(
    sex = "Male",
    treatment = NA,
    breed = "Angus",
    mob = "Mob1", 
    eid = "123"
  )
  input <- list(sex = "Male", treatment = "No Treatment", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  expect_true(grepl("Treatment: No Treatment", result))
})

test_that("create_simplified_group_labels shows only varying columns", {
  test_data <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "A"),
    breed = c("Angus", "Angus"),
    mob = c("Mob1", "Mob1"),
    eid = c("123", "123")
  )
  input <- list(sex = c("Male", "Female"), treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  expect_equal(length(result), 2)
  expect_true(all(grepl("Sex:", result)))
  expect_false(any(grepl("Treatment:", result)))
  expect_false(any(grepl("Breed:", result)))
  expect_false(any(grepl("Mob:", result)))
  expect_false(any(grepl("Eid:", result)))
})

# Test filter_data with EID filtering for admin users
test_that("filter_data works with EID filtering for admin users", {
  test_data <- data.frame(
    eid = c(1, 2, 3, 4),
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  input_eid <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = NULL, eid = c(1, 2))
  result_eid <- filter_data(test_data, input_eid, is_admin = TRUE)
  
  expect_equal(nrow(result_eid), 2)
  expect_true(all(result_eid$eid %in% c(1, 2)))
})

test_that("filter_data ignores EID filtering for non-admin users", {
  test_data <- data.frame(
    eid = c(1, 2, 3, 4),
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  input_eid <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = NULL, breed = NULL, mob = NULL, eid = c(1, 2))
  result_eid <- filter_data(test_data, input_eid, is_admin = FALSE)
  
  expect_equal(nrow(result_eid), 4)  # All records should be returned
})

# Test filter_data with complex treatment filtering
test_that("filter_data handles mixed treatment filtering with No Treatment", {
  test_data <- data.frame(
    eid = 1:6,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04", "2023-01-05", "2023-01-06")),
    sex = rep(c("Male", "Female"), 3),
    treatment = c("A", NA, "B", NA, "C", NA),
    breed = rep(c("Angus", "Hereford"), 3),
    mob = rep(c("Mob1", "Mob2"), 3),
    finalpweight = rnorm(6, 500, 50)
  )
  
  input_mixed <- list(year = 2023, month = NULL, day = NULL, sex = NULL, treatment = c("No Treatment", "A"), breed = NULL, mob = NULL)
  result_mixed <- filter_data(test_data, input_mixed)
  
  expect_equal(nrow(result_mixed), 4)  # 3 NA + 1 A
  expect_true(all(is.na(result_mixed$treatment) | result_mixed$treatment == "A"))
})

# Test filter_data with day filtering
test_that("filter_data works with day filtering", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-15", "2023-01-20", "2023-01-15", "2023-01-25")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  input_day <- list(year = 2023, month = "January", day = 15, sex = NULL, treatment = NULL, breed = NULL, mob = NULL)
  result_day <- filter_data(test_data, input_day)
  
  expect_equal(nrow(result_day), 2)
  expect_true(all(lubridate::day(result_day$date) == 15))
})

# Test filter_data with "All" values
test_that("filter_data handles 'All' values correctly", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-15", "2023-06-20", "2023-01-15", "2023-06-20")),
    sex = rep(c("Male", "Female"), 2),
    treatment = rep(c("A", "B"), 2),
    breed = rep(c("Angus", "Hereford"), 2),
    mob = rep(c("Mob1", "Mob2"), 2),
    finalpweight = rnorm(4, 500, 50)
  )
  
  input_all <- list(year = 2023, month = "All", day = "All", sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall")
  result_all <- filter_data(test_data, input_all)
  
  expect_equal(nrow(result_all), 4)  # All records should be returned
})

# Test get_common_filters_note function
test_that("get_common_filters_note returns empty for single group", {
  test_data <- data.frame(
    sex = "Male",
    treatment = "A",
    breed = "Angus",
    mob = "Mob1",
    eid = "123"
  )
  input <- list(sex = "Male", treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- get_common_filters_note(test_data, input)
  expect_equal(result, "")
})

test_that("get_common_filters_note returns empty for empty data", {
  empty_df <- data.frame()
  result <- get_common_filters_note(empty_df, list())
  expect_equal(result, "")
})

test_that("get_common_filters_note identifies common filters", {
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

test_that("get_common_filters_note handles NA treatment values", {
  test_data <- data.frame(
    sex = c("Male", "Female"),
    treatment = c(NA, NA),
    breed = c("Angus", "Angus"),
    mob = c("Mob1", "Mob2"),
    eid = c("123", "123")
  )
  input <- list(sex = c("Male", "Female"), treatment = "No Treatment", breed = "Angus", mob = c("Mob1", "Mob2"), eid = "123")
  result <- get_common_filters_note(test_data, input)
  expect_true(grepl("Treatment: No Treatment", result))
})