# Test the uncovered code paths in create_simplified_group_labels

test_that("create_simplified_group_labels handles no variations with Overall values", {
  # Test data where all values are "Overall" - should trigger the "Overall Average" path
  test_data <- data.frame(
    sex = c("Overall", "Overall", "Overall"),
    treatment = c("Overall", "Overall", "Overall"),
    breed = c("Overall", "Overall", "Overall"),
    mob = c("Overall", "Overall", "Overall"),
    eid = c("Overall", "Overall", "Overall")
  )
  
  input <- list(sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should return a single "Overall Average" (not repeated)
  expect_equal(result, "Overall Average")
})

test_that("create_simplified_group_labels handles no variations with non-Overall values", {
  # Test data where all values are the same but not "Overall" - should trigger the full label path
  test_data <- data.frame(
    sex = c("Male", "Male", "Male"),
    treatment = c("A", "A", "A"),
    breed = c("Angus", "Angus", "Angus"),
    mob = c("Mob1", "Mob1", "Mob1"),
    eid = c("123", "123", "123")
  )
  
  input <- list(sex = "Male", treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should return a single full label (not repeated)
  expect_equal(length(result), 1)
  expect_true(grepl("Sex: Male", result))
  expect_true(grepl("Treatment: A", result))
  expect_true(grepl("Breed: Angus", result))
  expect_true(grepl("Mob: Mob1", result))
  expect_true(grepl("Eid: 123", result))
})

test_that("create_simplified_group_labels handles NA treatment in no variations scenario", {
  # Test data with NA treatment values - should convert to "No Treatment"
  test_data <- data.frame(
    sex = c("Male", "Male", "Male"),
    treatment = c(NA, NA, NA),
    breed = c("Angus", "Angus", "Angus"),
    mob = c("Mob1", "Mob1", "Mob1"),
    eid = c("123", "123", "123")
  )
  
  input <- list(sex = "Male", treatment = "No Treatment", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should return a single full label with "No Treatment"
  expect_equal(length(result), 1)
  expect_true(grepl("Treatment: No Treatment", result))
  expect_true(grepl("Sex: Male", result))
})

test_that("create_simplified_group_labels handles mixed Overall and non-Overall values", {
  # Test data with some "Overall" and some specific values
  test_data <- data.frame(
    sex = c("Overall", "Overall", "Overall"),
    treatment = c("A", "A", "A"),
    breed = c("Overall", "Overall", "Overall"),
    mob = c("Mob1", "Mob1", "Mob1"),
    eid = c("Overall", "Overall", "Overall")
  )
  
  input <- list(sex = "Overall", treatment = "A", breed = "Overall", mob = "Mob1", eid = "Overall")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should return a single full label (not "Overall Average" since not all are "Overall")
  expect_equal(length(result), 1)
  expect_true(grepl("Sex: Overall", result))
  expect_true(grepl("Treatment: A", result))
  expect_true(grepl("Breed: Overall", result))
  expect_true(grepl("Mob: Mob1", result))
  expect_true(grepl("Eid: Overall", result))
})

test_that("create_simplified_group_labels handles single row with Overall values", {
  # Test with single row where all values are "Overall"
  test_data <- data.frame(
    sex = "Overall",
    treatment = "Overall",
    breed = "Overall",
    mob = "Overall",
    eid = "Overall"
  )
  
  input <- list(sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should return "Overall Average"
  expect_equal(result, "Overall Average")
})

test_that("create_simplified_group_labels handles single row with non-Overall values", {
  # Test with single row where values are not "Overall"
  test_data <- data.frame(
    sex = "Male",
    treatment = "A",
    breed = "Angus",
    mob = "Mob1",
    eid = "123"
  )
  
  input <- list(sex = "Male", treatment = "A", breed = "Angus", mob = "Mob1", eid = "123")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should return full label
  expect_equal(length(result), 1)
  expect_true(grepl("Sex: Male", result))
  expect_true(grepl("Treatment: A", result))
  expect_true(grepl("Breed: Angus", result))
  expect_true(grepl("Mob: Mob1", result))
  expect_true(grepl("Eid: 123", result))
})

test_that("create_simplified_group_labels handles single group with NA treatment in Overall check", {
  # Test with single group where treatment is NA - should trigger line 108
  # This tests the specific case where NA treatment gets converted to "No Treatment"
  # during the "all Overall" check, which should set all_overall to FALSE
  test_data <- data.frame(
    sex = c("Overall", "Overall"),
    treatment = c(NA, NA),
    breed = c("Overall", "Overall"),
    mob = c("Overall", "Overall"),
    eid = c("Overall", "Overall")
  )
  
  input <- list(sex = "Overall", treatment = "No Treatment", breed = "Overall", mob = "Overall", eid = "Overall")
  result <- create_simplified_group_labels(test_data, input)
  
  # Should return a single full label with "No Treatment" (not "Overall Average")
  # because NA treatment gets converted to "No Treatment" which is not "Overall"
  expect_equal(length(result), 1)
  expect_true(grepl("Treatment: No Treatment", result))
  expect_true(grepl("Sex: Overall", result))
  expect_true(grepl("Breed: Overall", result))
  expect_true(grepl("Mob: Overall", result))
  expect_true(grepl("Eid: Overall", result))
})
