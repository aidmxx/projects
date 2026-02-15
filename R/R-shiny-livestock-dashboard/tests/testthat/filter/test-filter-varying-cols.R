# Test the varying_cols logic in create_simplified_group_labels and get_common_filters_note

test_that("varying_cols logic works with no variations", {
  # All columns have the same value - no varying columns
  test_data <- data.frame(
    sex = c("Male", "Male", "Male"),
    treatment = c("A", "A", "A"),
    breed = c("Angus", "Angus", "Angus"),
    mob = c("Mob1", "Mob1", "Mob1"),
    eid = c("123", "123", "123")
  )
  
  input <- list(sex = "Male", treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  # With no variations and identical rows, should get a single label showing all values
  expect_equal(length(result), 1)
  expect_true(grepl("Sex: Male", result))
  expect_true(grepl("Treatment: A", result))
  expect_true(grepl("Breed: Angus", result))
  expect_true(grepl("Mob: Mob1", result))
  expect_true(grepl("Eid: 123", result))
})

test_that("varying_cols logic works with one varying column", {
  # Only sex varies
  test_data <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "A"),
    breed = c("Angus", "Angus"),
    mob = c("Mob1", "Mob1"),
    eid = c("123", "123")
  )
  
  input <- list(sex = c("Male", "Female"), treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should show only the varying column (sex)
  expect_equal(length(result), 2)
  expect_true(all(grepl("Sex:", result)))
  expect_false(any(grepl("Treatment:", result)))
  expect_false(any(grepl("Breed:", result)))
})

test_that("varying_cols logic works with multiple varying columns", {
  # Sex and treatment vary
  test_data <- data.frame(
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "A", "B", "B"),
    breed = c("Angus", "Angus", "Angus", "Angus"),
    mob = c("Mob1", "Mob1", "Mob1", "Mob1"),
    eid = c("123", "123", "123", "123")
  )
  
  input <- list(sex = c("Male", "Female"), treatment = c("A", "B"), breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should show both varying columns
  expect_equal(length(result), 4)
  expect_true(all(grepl("Sex:", result)))
  expect_true(all(grepl("Treatment:", result)))
  expect_false(any(grepl("Breed:", result)))
  expect_false(any(grepl("Mob:", result)))
})

test_that("get_common_filters_note varying_cols logic works", {
  # Test with one varying column
  test_data <- data.frame(
    sex = c("Male", "Female"),
    treatment = c("A", "A"),
    breed = c("Angus", "Angus"),
    mob = c("Mob1", "Mob1"),
    eid = c("123", "123")
  )
  
  input <- list(sex = c("Male", "Female"), treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- get_common_filters_note(test_data, input)
  
  # Should show the non-varying (common) filters
  expect_true(grepl("Treatment: A", result))
  expect_true(grepl("Breed: Angus", result))
  expect_true(grepl("Mob: Mob1", result))
  expect_true(grepl("Eid: 123", result))
  expect_false(grepl("Sex:", result))
})

test_that("NA treatment handling in create_simplified_group_labels works", {
  # Test with NA treatment value - should be converted to "No Treatment"
  test_data <- data.frame(
    sex = c("Male", "Male"),
    treatment = c(NA, NA),
    breed = c("Angus", "Angus"),
    mob = c("Mob1", "Mob1"),
    eid = c("123", "123")
  )
  
  input <- list(sex = "Male", treatment = "No Treatment", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should show "No Treatment" instead of NA
  expect_true(all(grepl("Treatment: No Treatment", result)))
})

test_that("NA treatment handling in get_common_filters_note works", {
  # Test with NA treatment value in common filters
  test_data <- data.frame(
    sex = c("Male", "Female"),
    treatment = c(NA, NA),
    breed = c("Angus", "Angus"),
    mob = c("Mob1", "Mob1"),
    eid = c("123", "123")
  )
  
  input <- list(sex = c("Male", "Female"), treatment = "No Treatment", breed = "Angus", mob = "Mob1", eid = "123")
  result <- get_common_filters_note(test_data, input)
  
  # Should show "No Treatment" instead of NA
  expect_true(grepl("Treatment: No Treatment", result))
})

