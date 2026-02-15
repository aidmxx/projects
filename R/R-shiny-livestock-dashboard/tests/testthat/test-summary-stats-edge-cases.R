# Test edge cases for summary_stats.R functions
# Covers uncovered error handling paths and edge cases

library(testthat)

# Source the summary_stats functions
source("src/summary_stats.R")

# ---- Test create_full_group_labels edge cases ----

test_that("create_full_group_labels handles missing required columns", {
  # Test with missing columns
  df_missing_cols <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "B")
    # Missing: breed, mob, eid
  )
  
  # Test that the function throws an error for missing columns
  expect_error(
    create_full_group_labels(df_missing_cols, NULL),
    "Missing required columns: breed, mob, eid"
  )
  
  # Test with different missing columns to ensure the error message is correct
  df_missing_other <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Breed1", "Breed2")
    # Missing: mob, eid
  )
  
  expect_error(
    create_full_group_labels(df_missing_other, NULL),
    "Missing required columns: mob, eid"
  )
})

# Additional test to ensure the error path is executed for coverage
test_that("create_full_group_labels missing columns error path execution", {
  # Create a data frame with missing columns to trigger the error path
  df_missing <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "B")
    # Missing: breed, mob, eid
  )
  
  # Use tryCatch to capture the error but still execute the line
  error_caught <- tryCatch({
    create_full_group_labels(df_missing, NULL)
    FALSE
  }, error = function(e) {
    # Verify the error message contains the expected text
    grepl("Missing required columns", e$message)
  })
  
  expect_true(error_caught)
})

# Test to force execution of the error path without expect_error
test_that("create_full_group_labels forces error path execution", {
  # Create a minimal data frame with missing required columns
  df_minimal <- data.frame(
    sex = c("Male")
    # Missing: treatment, breed, mob, eid
  )
  
  # Force the function to execute the error path by calling it directly
  # This should trigger the stop() statement on line 47
  result <- tryCatch({
    create_full_group_labels(df_minimal, NULL)
    "success"
  }, error = function(e) {
    # The error should be caught here, but the line should still be executed
    "error_caught"
  })
  
  # Verify that an error was caught (meaning line 47 was executed)
  expect_equal(result, "error_caught")
})

# Test to ensure the function works with valid data (normal path)
test_that("create_full_group_labels works with valid data", {
  # Create a complete data frame with all required columns
  df_valid <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Breed1", "Breed2"),
    mob = c("Mob1", "Mob2"),
    eid = c("EID1", "EID2"),
    stringsAsFactors = FALSE
  )
  
  # This should work without errors
  result <- create_full_group_labels(df_valid, NULL)
  
  expect_true(is.character(result))
  expect_equal(length(result), 2)
  expect_true(grepl("Sex:", result[1]))
  expect_true(grepl("Treatment:", result[1]))
})

test_that("create_full_group_labels handles NULL values", {
  # Test with NULL values - create a list first, then convert to data frame
  df_with_nulls <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Breed1", "Breed2"),
    mob = c("Mob1", "Mob2"),
    eid = c("EID1", "EID2"),
    stringsAsFactors = FALSE
  )
  
  # Create a list with NULL value and convert to data frame
  eid_list <- list("EID1", NULL)
  df_with_nulls$eid <- eid_list
  
  result <- create_full_group_labels(df_with_nulls, NULL)
  
  expect_true(is.character(result))
  expect_equal(length(result), 2)
  # The second result should contain "NULL" due to the NULL value
  expect_true(grepl("NULL", result[2]))
})

test_that("create_full_group_labels handles NA values", {
  # Test with NA values
  df_with_nas <- data.frame(
    sex = c("Male", "Female"),
    treatment = c(NA, "B"),  # One NA value
    breed = c("Breed1", "Breed2"),
    mob = c("Mob1", "Mob2"),
    eid = c("EID1", "EID2")
  )
  
  result <- create_full_group_labels(df_with_nas, NULL)
  
  expect_true(is.character(result))
  expect_equal(length(result), 2)
  # The function converts NA treatment to "No Treatment"
  expect_true(grepl("No Treatment", result[1]))
})

test_that("create_full_group_labels handles NA treatment values", {
  # Test with NA treatment values (should become "No Treatment")
  df_na_treatment <- data.frame(
    sex = c("Male", "Female"),
    treatment = c(NA, "B"),  # One NA treatment
    breed = c("Breed1", "Breed2"),
    mob = c("Mob1", "Mob2"),
    eid = c("EID1", "EID2")
  )
  
  result <- create_full_group_labels(df_na_treatment, NULL)
  
  expect_true(is.character(result))
  expect_equal(length(result), 2)
  expect_true(grepl("No Treatment", result[1]))
})


test_that("create_full_group_labels handles empty data frame", {
  # Test with empty data frame
  df_empty <- data.frame(
    sex = character(0),
    treatment = character(0),
    breed = character(0),
    mob = character(0),
    eid = character(0)
  )
  
  result <- create_full_group_labels(df_empty, NULL)
  
  expect_true(is.character(result))
  expect_equal(length(result), 0)
})

test_that("create_full_group_labels handles single row data", {
  # Test with single row
  df_single <- data.frame(
    sex = "Male",
    treatment = "A",
    breed = "Breed1",
    mob = "Mob1",
    eid = "EID1"
  )
  
  result <- create_full_group_labels(df_single, NULL)
  
  expect_true(is.character(result))
  expect_equal(length(result), 1)
  expect_true(grepl("Sex: Male", result[1]))
  expect_true(grepl("Treatment: A", result[1]))
  expect_true(grepl("Breed: Breed1", result[1]))
  expect_true(grepl("Mob: Mob1", result[1]))
  expect_true(grepl("EID: EID1", result[1]))
})

test_that("create_full_group_labels handles multiple rows with same values", {
  # Test with duplicate rows
  df_duplicates <- data.frame(
    sex = c("Male", "Male", "Female"),
    treatment = c("A", "A", "B"),
    breed = c("Breed1", "Breed1", "Breed2"),
    mob = c("Mob1", "Mob1", "Mob2"),
    eid = c("EID1", "EID1", "EID2")
  )
  
  result <- create_full_group_labels(df_duplicates, NULL)
  
  expect_true(is.character(result))
  expect_equal(length(result), 3)
  # First two should be identical
  expect_equal(result[1], result[2])
  # Third should be different
  expect_false(result[1] == result[3])
})

cat("Summary stats edge cases tests completed!\n")
