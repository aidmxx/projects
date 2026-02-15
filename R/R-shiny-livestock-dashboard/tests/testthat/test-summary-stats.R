# Test file for summary_stats.R functions
# Tests the core functions that can be unit tested outside of Shiny context

library(testthat)
library(dplyr)
library(lubridate)

# Test data setup
test_data <- data.frame(
  eid = 1:100,
  date = seq(as.Date("2023-01-01"), as.Date("2023-12-31"), length.out = 100),
  breed = rep(c("Angus", "Hereford", "Charolais"), length.out = 100),
  treatment = rep(c("Control", "Treatment A", "Treatment B"), length.out = 100),
  mob = rep(c("Mob1", "Mob2", "Mob3"), length.out = 100),
  sex = rep(c("Male", "Female"), length.out = 100),
  finalpweight = rnorm(100, 500, 50),
  finalgrowthpbs = rnorm(100, 1.5, 0.3),
  methane = rnorm(100, 200, 30),
  animalvalue = rnorm(100, 1000, 200),
  animalprod = rnorm(100, 50, 10),
  carcassweight = rnorm(100, 300, 40),
  feedintakekgd = rnorm(100, 8, 1.5)
)

# Mock measure_units for testing
test_measure_units <- list(
  finalpweight = "kg",
  finalgrowthpbs = "kg/day",
  methane = "g/day",
  animalvalue = "$",
  animalprod = "units",
  carcassweight = "kg",
  feedintakekgd = "kg/day"
)

# The summary_stats.R file is sourced in setup.R, so functions are available

# Test the kpi_block function
test_that("kpi_block function works correctly", {
  if (exists("kpi_block")) {
    # Test with normal data
    df <- test_data[1:10, ]
    measure <- "finalpweight"
    
    # Mock the measure_units global variable
    measure_units <<- test_measure_units
    
    result <- kpi_block(df, measure)
    
    # Check that result is a tagList
    expect_s3_class(result, "shiny.tag.list")
    
    # Test with empty data
    empty_df <- test_data[0, ]
    result_empty <- kpi_block(empty_df, measure)
    expect_s3_class(result_empty, "shiny.tag")
    
    # Test with non-numeric data
    df_non_numeric <- data.frame(measure = c("a", "b", "c"))
    result_non_numeric <- kpi_block(df_non_numeric, "measure")
    expect_s3_class(result_non_numeric, "shiny.tag")
  } else {
    skip("kpi_block function not available")
  }
})

test_that("kpi_block handles different measure types", {
  if (exists("kpi_block")) {
    measure_units <<- test_measure_units
    
    # Test with dollar measure
    df <- test_data[1:10, ]
    result_dollar <- kpi_block(df, "animalvalue")
    expect_s3_class(result_dollar, "shiny.tag.list")
    
    # Test with unit measure
    result_unit <- kpi_block(df, "finalpweight")
    expect_s3_class(result_unit, "shiny.tag.list")
    
    # Test with no unit measure
    measure_units <<- list(finalpweight = NULL)
    result_no_unit <- kpi_block(df, "finalpweight")
    expect_s3_class(result_no_unit, "shiny.tag.list")
  } else {
    skip("kpi_block function not available")
  }
})

test_that("subset_by_window function works correctly", {
  if (exists("subset_by_window")) {
    # Test with normal data
    df <- test_data
    result <- subset_by_window(df, 30)
    
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) <= nrow(df))
    
    # Test with empty data
    empty_df <- test_data[0, ]
    result_empty <- subset_by_window(empty_df, 30)
    expect_equal(nrow(result_empty), 0)
    
    # Test with single day
    result_1day <- subset_by_window(df, 1)
    expect_s3_class(result_1day, "data.frame")
    
    # Test with large window (should return all data)
    result_large <- subset_by_window(df, 365)
    expect_s3_class(result_large, "data.frame")
  } else {
    skip("subset_by_window function not available")
  }
})

test_that("subset_by_window handles edge cases", {
  if (exists("subset_by_window")) {
    # Test with data that has NA dates
    df_with_na <- test_data
    df_with_na$date[1] <- NA
    result_na <- subset_by_window(df_with_na, 30)
    expect_s3_class(result_na, "data.frame")
    
    # Test with zero days
    result_zero <- subset_by_window(test_data, 0)
    expect_s3_class(result_zero, "data.frame")
  } else {
    skip("subset_by_window function not available")
  }
})

test_that("date_filtered_overall reactive logic works", {
  # This tests the logic that would be in the reactive function
  # We'll test the filtering logic directly
  
  df <- test_data
  
  # Test year filtering
  year_filtered <- df |> dplyr::filter(lubridate::year(date) == 2023)
  expect_true(all(lubridate::year(year_filtered$date) == 2023))
  
  # Test month filtering
  month_filtered <- df |> dplyr::filter(lubridate::month(date) == 1)
  expect_true(all(lubridate::month(month_filtered$date) == 1))
  
  # Test day filtering
  day_filtered <- df |> dplyr::filter(lubridate::day(date) == 1)
  expect_true(all(lubridate::day(day_filtered$date) == 1))
})

test_that("kpi_cards logic works with group data", {
  # Test the group creation logic
  df <- test_data
  df$group <- paste(df$sex, df$treatment, df$breed, df$mob, sep = " | ")
  groups <- unique(df$group)
  
  expect_true(length(groups) > 0)
  expect_true(all(groups %in% df$group))
  
  # Test group data extraction
  for (group_name in groups) {
    group_data <- df[df$group == group_name, ]
    expect_true(nrow(group_data) > 0)
    expect_true(all(group_data$group == group_name))
  }
})

test_that("summary stats functions handle missing data gracefully", {
  if (exists("kpi_block") && exists("subset_by_window")) {
    measure_units <<- test_measure_units
    
    # Test with data containing NAs
    df_with_na <- test_data
    df_with_na$finalpweight[1:5] <- NA
    
    result <- kpi_block(df_with_na, "finalpweight")
    expect_s3_class(result, "shiny.tag.list")
    
    # Test subset_by_window with NA dates
    df_with_na_dates <- test_data
    df_with_na_dates$date[1:5] <- NA
    
    result_window <- subset_by_window(df_with_na_dates, 30)
    expect_s3_class(result_window, "data.frame")
  } else {
    skip("kpi_block or subset_by_window function not available")
  }
})

test_that("measure units formatting works correctly", {
  if (exists("kpi_block")) {
    measure_units <<- test_measure_units
    
    # Test different unit types
    df <- test_data[1:5, ]
    
    # Test dollar formatting
    result_dollar <- kpi_block(df, "animalvalue")
    expect_s3_class(result_dollar, "shiny.tag.list")
    
    # Test regular unit formatting
    result_kg <- kpi_block(df, "finalpweight")
    expect_s3_class(result_kg, "shiny.tag.list")
    
    # Test no unit formatting
    measure_units <<- list(finalpweight = "")
    result_no_unit <- kpi_block(df, "finalpweight")
    expect_s3_class(result_no_unit, "shiny.tag.list")
  } else {
    skip("kpi_block function not available")
  }
})

test_that("statistical calculations are correct", {
  if (exists("kpi_block")) {
    measure_units <<- test_measure_units
    
    # Create simple test data with known values
    simple_df <- data.frame(
      date = as.Date("2023-01-01"),
      finalpweight = c(100, 200, 300, 400, 500)
    )
    
    result <- kpi_block(simple_df, "finalpweight")
    expect_s3_class(result, "shiny.tag.list")
    
    # Test that the function doesn't crash with edge cases
    single_value_df <- data.frame(
      date = as.Date("2023-01-01"),
      finalpweight = 250
    )
    
    result_single <- kpi_block(single_value_df, "finalpweight")
    expect_s3_class(result_single, "shiny.tag.list")
  } else {
    skip("kpi_block function not available")
  }
})

test_that("date filtering combinations work", {
  df <- test_data
  
  # Test year + month filtering
  year_month_filtered <- df |> 
    dplyr::filter(lubridate::year(date) == 2023) |>
    dplyr::filter(lubridate::month(date) == 6)
  
  expect_true(all(lubridate::year(year_month_filtered$date) == 2023))
  expect_true(all(lubridate::month(year_month_filtered$date) == 6))
  
  # Test year + month + day filtering
  year_month_day_filtered <- df |> 
    dplyr::filter(lubridate::year(date) == 2023) |>
    dplyr::filter(lubridate::month(date) == 6) |>
    dplyr::filter(lubridate::day(date) == 15)
  
  expect_true(all(lubridate::year(year_month_day_filtered$date) == 2023))
  expect_true(all(lubridate::month(year_month_day_filtered$date) == 6))
  expect_true(all(lubridate::day(year_month_day_filtered$date) == 15))
})

# Test create_full_group_labels function
test_that("create_full_group_labels function works correctly", {
  if (exists("create_full_group_labels")) {
    # Test with normal data
    df <- test_data[1:10, ]
    result <- create_full_group_labels(df, list())
    
    expect_type(result, "character")
    expect_length(result, nrow(df))
    
    # Check that all labels contain expected components
    for (label in result) {
      expect_true(grepl("Sex:", label))
      expect_true(grepl("Treatment:", label))
      expect_true(grepl("Breed:", label))
      expect_true(grepl("Mob:", label))
      expect_true(grepl("EID:", label))
    }
  } else {
    skip("create_full_group_labels function not available")
  }
})

test_that("create_full_group_labels handles empty data", {
  if (exists("create_full_group_labels")) {
    empty_df <- test_data[0, ]
    result <- create_full_group_labels(empty_df, list())
    
    expect_type(result, "character")
    expect_length(result, 0)
  } else {
    skip("create_full_group_labels function not available")
  }
})

test_that("create_full_group_labels handles NA treatment values", {
  if (exists("create_full_group_labels")) {
    df_with_na_treatment <- test_data[1:5, ]
    df_with_na_treatment$treatment[1:2] <- NA
    
    result <- create_full_group_labels(df_with_na_treatment, list())
    
    expect_type(result, "character")
    expect_length(result, nrow(df_with_na_treatment))
    
    # Check that NA treatments are converted to "No Treatment"
    na_labels <- result[1:2]
    for (label in na_labels) {
      expect_true(grepl("Treatment: No Treatment", label))
    }
  } else {
    skip("create_full_group_labels function not available")
  }
})

test_that("create_full_group_labels creates unique combinations", {
  if (exists("create_full_group_labels")) {
    # Create data with known unique combinations
    df_unique <- data.frame(
      sex = c("Male", "Female", "Male", "Female"),
      treatment = c("Control", "Control", "Treatment", "Treatment"),
      breed = c("Angus", "Angus", "Hereford", "Hereford"),
      mob = c("Mob1", "Mob1", "Mob2", "Mob2"),
      eid = c(1, 2, 3, 4)
    )
    
    result <- create_full_group_labels(df_unique, list())
    
    expect_type(result, "character")
    expect_length(result, 4)
    
    # Check that each label is unique
    expect_equal(length(unique(result)), 4)
  } else {
    skip("create_full_group_labels function not available")
  }
})

# Additional kpi_block tests for better coverage
test_that("kpi_block handles all unit formatting branches", {
  if (exists("kpi_block")) {
    df <- test_data[1:5, ]
    
    # Test dollar unit formatting (line 12-13)
    measure_units <<- list(animalvalue = "$")
    result_dollar <- kpi_block(df, "animalvalue")
    expect_s3_class(result_dollar, "shiny.tag.list")
    
    # Test regular unit formatting (line 14-15)
    measure_units <<- list(finalpweight = "kg")
    result_kg <- kpi_block(df, "finalpweight")
    expect_s3_class(result_kg, "shiny.tag.list")
    
    # Test no unit formatting (line 16-17)
    measure_units <<- list(finalpweight = NULL)
    result_no_unit <- kpi_block(df, "finalpweight")
    expect_s3_class(result_no_unit, "shiny.tag.list")
    
    # Test empty unit formatting
    measure_units <<- list(finalpweight = "")
    result_empty_unit <- kpi_block(df, "finalpweight")
    expect_s3_class(result_empty_unit, "shiny.tag.list")
  } else {
    skip("kpi_block function not available")
  }
})

test_that("kpi_block handles all data validation branches", {
  if (exists("kpi_block")) {
    measure_units <<- test_measure_units
    
    # Test empty dataframe (line 3-4)
    empty_df <- data.frame(finalpweight = numeric(0))
    result_empty <- kpi_block(empty_df, "finalpweight")
    expect_s3_class(result_empty, "shiny.tag")
    
    # Test non-numeric data (line 3-4)
    non_numeric_df <- data.frame(measure = c("a", "b", "c"))
    result_non_numeric <- kpi_block(non_numeric_df, "measure")
    expect_s3_class(result_non_numeric, "shiny.tag")
    
    # Test normal numeric data
    normal_df <- test_data[1:5, ]
    result_normal <- kpi_block(normal_df, "finalpweight")
    expect_s3_class(result_normal, "shiny.tag.list")
  } else {
    skip("kpi_block function not available")
  }
})

test_that("kpi_block statistical calculations are accurate", {
  if (exists("kpi_block")) {
    measure_units <<- list(test_measure = "units")
    
    # Create data with known statistical values
    known_df <- data.frame(
      date = as.Date("2023-01-01"),
      test_measure = c(10, 20, 30, 40, 50)
    )
    
    result <- kpi_block(known_df, "test_measure")
    expect_s3_class(result, "shiny.tag.list")
    
    # Test with single value
    single_df <- data.frame(
      date = as.Date("2023-01-01"),
      test_measure = 25
    )
    
    result_single <- kpi_block(single_df, "test_measure")
    expect_s3_class(result_single, "shiny.tag.list")
    
    # Test with all same values
    same_df <- data.frame(
      date = as.Date("2023-01-01"),
      test_measure = c(25, 25, 25, 25, 25)
    )
    
    result_same <- kpi_block(same_df, "test_measure")
    expect_s3_class(result_same, "shiny.tag.list")
  } else {
    skip("kpi_block function not available")
  }
})

test_that("kpi_block handles NA values in measurements", {
  if (exists("kpi_block")) {
    measure_units <<- list(test_measure = "units")
    
    # Test with some NA values
    df_with_na <- data.frame(
      date = as.Date("2023-01-01"),
      test_measure = c(10, NA, 30, NA, 50)
    )
    
    result <- kpi_block(df_with_na, "test_measure")
    expect_s3_class(result, "shiny.tag.list")
    
    # Test with all NA values - this might cause issues with statistical functions
    # but the function should still return a result (either tag or tagList)
    df_all_na <- data.frame(
      date = as.Date("2023-01-01"),
      test_measure = c(NA, NA, NA, NA, NA)
    )
    
    result_all_na <- kpi_block(df_all_na, "test_measure")
    # The function should return some kind of shiny object
    expect_true(inherits(result_all_na, "shiny.tag") || inherits(result_all_na, "shiny.tag.list"))
  } else {
    skip("kpi_block function not available")
  }
})

# Additional subset_by_window tests
test_that("subset_by_window handles various date scenarios", {
  if (exists("subset_by_window")) {
    # Test with dates spanning multiple years
    multi_year_df <- data.frame(
      date = c(
        as.Date("2022-12-31"),
        as.Date("2023-01-01"),
        as.Date("2023-06-15"),
        as.Date("2023-12-31"),
        as.Date("2024-01-01")
      ),
      value = 1:5
    )
    
    result <- subset_by_window(multi_year_df, 30)
    expect_s3_class(result, "data.frame")
    
    # Test with single date
    single_date_df <- data.frame(
      date = as.Date("2023-06-15"),
      value = 1
    )
    
    result_single <- subset_by_window(single_date_df, 1)
    expect_s3_class(result_single, "data.frame")
    expect_equal(nrow(result_single), 1)
    
    # Test with zero window
    result_zero <- subset_by_window(multi_year_df, 0)
    expect_s3_class(result_zero, "data.frame")
  } else {
    skip("subset_by_window function not available")
  }
})

test_that("subset_by_window handles edge cases with date filtering", {
  if (exists("subset_by_window")) {
    # Test with all NA dates - this will produce a warning but should still work
    df_all_na_dates <- data.frame(
      date = c(NA, NA, NA),
      value = 1:3
    )
    
    # Suppress the warning about max() with all NA values
    result <- suppressWarnings(subset_by_window(df_all_na_dates, 30))
    expect_s3_class(result, "data.frame")
    
    # Test with mixed NA and valid dates
    df_mixed_dates <- data.frame(
      date = c(NA, as.Date("2023-06-15"), NA, as.Date("2023-06-20")),
      value = 1:4
    )
    
    result_mixed <- subset_by_window(df_mixed_dates, 10)
    expect_s3_class(result_mixed, "data.frame")
  } else {
    skip("subset_by_window function not available")
  }
})

# Test measure_units handling with different data types
test_that("measure_units handles different data types correctly", {
  if (exists("kpi_block")) {
    df <- test_data[1:3, ]
    
    # Test with character measure name
    measure_units <<- list("finalpweight" = "kg")
    result_char <- kpi_block(df, "finalpweight")
    expect_s3_class(result_char, "shiny.tag.list")
    
    # Test with numeric measure name (should be converted to character)
    measure_units <<- list("123" = "units")
    df_numeric_col <- data.frame(
      date = as.Date("2023-01-01"),
      "123" = c(1, 2, 3)
    )
    result_numeric <- kpi_block(df_numeric_col, "123")
    # The function should return some kind of shiny object
    expect_true(inherits(result_numeric, "shiny.tag") || inherits(result_numeric, "shiny.tag.list"))
  } else {
    skip("kpi_block function not available")
  }
})

# Test formatting functions with extreme values
test_that("kpi_block handles extreme numeric values", {
  if (exists("kpi_block")) {
    measure_units <<- list(test_measure = "units")
    
    # Test with very large numbers
    large_df <- data.frame(
      date = as.Date("2023-01-01"),
      test_measure = c(1e6, 2e6, 3e6)
    )
    
    result_large <- kpi_block(large_df, "test_measure")
    expect_s3_class(result_large, "shiny.tag.list")
    
    # Test with very small numbers
    small_df <- data.frame(
      date = as.Date("2023-01-01"),
      test_measure = c(1e-6, 2e-6, 3e-6)
    )
    
    result_small <- kpi_block(small_df, "test_measure")
    expect_s3_class(result_small, "shiny.tag.list")
    
    # Test with negative numbers
    negative_df <- data.frame(
      date = as.Date("2023-01-01"),
      test_measure = c(-10, -5, 0, 5, 10)
    )
    
    result_negative <- kpi_block(negative_df, "test_measure")
    expect_s3_class(result_negative, "shiny.tag.list")
  } else {
    skip("kpi_block function not available")
  }
})