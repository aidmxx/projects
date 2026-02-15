# Test UI builder functions from filter.R

# Mock Shiny functions for testing
library(shiny)
library(shinyWidgets)

# Test build_date_row function
test_that("build_date_row creates proper layout", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  # Test that function returns a layout_columns object
  result <- build_date_row(test_data)
  expect_true(inherits(result, "shiny.tag"))
  expect_true(grepl("layout_columns", as.character(result)))
})

# Test build_sex_picker function
test_that("build_sex_picker creates proper picker input", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  result <- build_sex_picker(test_data)
  expect_true(inherits(result, "shiny.tag"))
  
  # Check for HTML elements and content instead of function names
  result_text <- as.character(result)
  expect_true(grepl("select", result_text, ignore.case = TRUE))
  expect_true(grepl("Select All", result_text))
  expect_true(grepl("Invert", result_text))
  expect_true(grepl("Overall", result_text))
  expect_true(grepl("Male", result_text))
  expect_true(grepl("Female", result_text))
})

# Test build_treatment_picker function
test_that("build_treatment_picker creates proper picker input", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", NA),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  result <- build_treatment_picker(test_data)
  expect_true(inherits(result, "shiny.tag"))
  
  result_text <- as.character(result)
  expect_true(grepl("select", result_text, ignore.case = TRUE))
  expect_true(grepl("Select All", result_text))
  expect_true(grepl("Invert", result_text))
  expect_true(grepl("Overall", result_text))
  expect_true(grepl("No Treatment", result_text))
})

# Test build_breed_picker function
test_that("build_breed_picker creates proper picker input", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  result <- build_breed_picker(test_data)
  expect_true(inherits(result, "shiny.tag"))
  
  result_text <- as.character(result)
  expect_true(grepl("select", result_text, ignore.case = TRUE))
  expect_true(grepl("Select All", result_text))
  expect_true(grepl("Invert", result_text))
  expect_true(grepl("Overall", result_text))
  expect_true(grepl("Angus", result_text))
  expect_true(grepl("Hereford", result_text))
})

# Test build_mob_picker function
test_that("build_mob_picker creates proper picker input", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  result <- build_mob_picker(test_data)
  expect_true(inherits(result, "shiny.tag"))
  
  result_text <- as.character(result)
  expect_true(grepl("select", result_text, ignore.case = TRUE))
  expect_true(grepl("Select All", result_text))
  expect_true(grepl("Invert", result_text))
  expect_true(grepl("Overall", result_text))
  expect_true(grepl("Mob1", result_text))
  expect_true(grepl("Mob2", result_text))
})

# Test build_eid_picker function
test_that("build_eid_picker creates proper picker input", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  result <- build_eid_picker(test_data)
  expect_true(inherits(result, "shiny.tag"))
  
  result_text <- as.character(result)
  expect_true(grepl("select", result_text, ignore.case = TRUE))
  expect_true(grepl("Select All", result_text))
  expect_true(grepl("Invert", result_text))
  expect_true(grepl("Overall", result_text))
})

# Test build_sex_treatment_row function
test_that("build_sex_treatment_row creates proper layout", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  result <- build_sex_treatment_row(test_data)
  expect_true(inherits(result, "shiny.tag"))
  expect_true(grepl("layout_columns", as.character(result)))
})

# Test build_breed_mob_row function
test_that("build_breed_mob_row creates proper layout", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  result <- build_breed_mob_row(test_data)
  expect_true(inherits(result, "shiny.tag"))
  expect_true(grepl("layout_columns", as.character(result)))
})

# Test build_eid_row function
test_that("build_eid_row creates proper layout", {
  test_data <- data.frame(
    eid = 1:2,
    date = as.Date(c("2023-01-01", "2024-01-01")),
    sex = c("Male", "Female"),
    treatment = c("A", "B"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1", "Mob2"),
    finalpweight = c(500, 600)
  )
  
  result <- build_eid_row(test_data)
  expect_true(inherits(result, "shiny.tag"))
  expect_true(grepl("layout_columns", as.character(result)))
})
