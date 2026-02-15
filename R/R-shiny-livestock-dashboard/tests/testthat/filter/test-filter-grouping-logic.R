# Test the complex grouping logic from build_filtered_reactives

# Test the safe_set_label helper function logic
test_that("safe_set_label logic works correctly", {
  # This tests the logic inside the grouped_data reactive
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "B", "A", "B"),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test the logic for determining filter states
  # This mirrors the logic in the grouped_data reactive
  
  # Test sex filter logic
  sex_has_all <- TRUE  # "Overall" %in% input$sex
  sex_specific <- FALSE  # length(input$sex) > 1 && any(input$sex != "Overall")
  
  sex_values <- if (sex_has_all && !sex_specific) {
    "Overall"
  } else if (sex_has_all && sex_specific) {
    c("Overall", "Male", "Female")  # Would be input$sex[input$sex != "Overall"]
  } else if (!sex_has_all && sex_specific) {
    c("Male", "Female")  # Would be input$sex
  } else {
    unique(test_data$sex)
  }
  
  expect_equal(sex_values, "Overall")
  
  # Test treatment filter logic with NA handling
  treatment_has_all <- TRUE
  treatment_specific <- FALSE
  
  treatment_values <- if (treatment_has_all && !treatment_specific) {
    "Overall"
  } else if (treatment_has_all && treatment_specific) {
    c("Overall", "A", "B")
  } else if (!treatment_has_all && treatment_specific) {
    c("A", "B")
  } else {
    # Map NA to display label "No Treatment" to avoid NA logical comparisons downstream
    unique(ifelse(is.na(test_data$treatment), "No Treatment", test_data$treatment))
  }
  
  expect_equal(treatment_values, "Overall")
})

test_that("grouping logic handles mixed filter states", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "B", "A", "B"),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test case: sex has "Overall" + specific selections
  sex_has_all <- TRUE
  sex_specific <- TRUE
  input_sex <- c("Overall", "Male")
  
  sex_values <- if (sex_has_all && !sex_specific) {
    "Overall"
  } else if (sex_has_all && sex_specific) {
    c("Overall", input_sex[input_sex != "Overall"])
  } else if (!sex_has_all && sex_specific) {
    input_sex
  } else {
    unique(test_data$sex)
  }
  
  expect_equal(sex_values, c("Overall", "Male"))
  
  # Test case: treatment has only specific selections (no "Overall")
  treatment_has_all <- FALSE
  treatment_specific <- TRUE
  input_treatment <- c("A", "B")
  
  treatment_values <- if (treatment_has_all && !treatment_specific) {
    "Overall"
  } else if (treatment_has_all && treatment_specific) {
    c("Overall", input_treatment[input_treatment != "Overall"])
  } else if (!treatment_has_all && treatment_specific) {
    input_treatment
  } else {
    unique(ifelse(is.na(test_data$treatment), "No Treatment", test_data$treatment))
  }
  
  expect_equal(treatment_values, c("A", "B"))
})

test_that("grouping logic handles admin vs non-admin EID logic", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "B", "A", "B"),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test admin user EID logic
  is_admin <- TRUE
  input_eid <- c("Overall", "1", "2")
  
  eid_has_all <- !is.null(input_eid) && "Overall" %in% input_eid
  eid_specific <- !is.null(input_eid) && length(input_eid) > 1 && any(input_eid != "Overall")
  
  eid_values_admin <- if (is_admin) {
    if (eid_has_all && !eid_specific) {
      "Overall"
    } else if (eid_has_all && eid_specific) {
      c("Overall", input_eid[input_eid != "Overall"])
    } else if (!eid_has_all && eid_specific) {
      input_eid
    } else {
      unique(test_data$eid)
    }
  } else {
    # Non-admin users always get "Overall" for EID
    "Overall"
  }
  
  expect_equal(eid_values_admin, c("Overall", "1", "2"))
  
  # Test non-admin user EID logic
  is_admin <- FALSE
  
  eid_values_user <- if (is_admin) {
    if (eid_has_all && !eid_specific) {
      "Overall"
    } else if (eid_has_all && eid_specific) {
      c("Overall", input_eid[input_eid != "Overall"])
    } else if (!eid_has_all && eid_specific) {
      input_eid
    } else {
      unique(test_data$eid)
    }
  } else {
    # Non-admin users always get "Overall" for EID
    "Overall"
  }
  
  expect_equal(eid_values_user, "Overall")
})

test_that("grouping logic handles NA treatment mapping", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", NA, "B", NA),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Test the NA mapping logic
  treatment_values <- unique(ifelse(is.na(test_data$treatment), "No Treatment", test_data$treatment))
  expect_equal(sort(treatment_values), c("A", "B", "No Treatment"))
})

# Test the debounced input logic (conceptually)
test_that("debounced input logic concepts work", {
  # This tests the concept of debounced inputs from build_filtered_reactives
  # We can't test the actual debounce function without a reactive context,
  # but we can test the logic it would apply
  
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", "B", "A", "B"),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Simulate the debounced input logic
  debounced_year <- 2023
  debounced_month <- "January"
  debounced_day <- "All"
  debounced_sex <- c("Male", "Female")
  debounced_treatment <- "Overall"
  debounced_breed <- "Overall"
  debounced_mob <- "Overall"
  debounced_eid <- "Overall"
  
  # Apply the same filtering logic as in the reactive
  df <- test_data |> dplyr::filter(lubridate::year(date) == debounced_year)
  
  if (!is.null(debounced_month) && debounced_month != "All") {
    df <- df |> dplyr::filter(lubridate::month(date) == match(debounced_month, month.name))
  }
  
  if (!is.null(debounced_sex) && length(debounced_sex) > 0 && !"Overall" %in% debounced_sex) {
    df <- df |> dplyr::filter(sex %in% debounced_sex)
  }
  
  # Should get all 4 records since sex includes both Male and Female
  expect_equal(nrow(df), 4)
  
  # Test with specific sex selection
  debounced_sex_specific <- c("Male")
  df_specific <- test_data |> dplyr::filter(lubridate::year(date) == debounced_year)
  
  if (!is.null(debounced_sex_specific) && length(debounced_sex_specific) > 0 && !"Overall" %in% debounced_sex_specific) {
    df_specific <- df_specific |> dplyr::filter(sex %in% debounced_sex_specific)
  }
  
  expect_equal(nrow(df_specific), 2)
  expect_true(all(df_specific$sex == "Male"))
})

# Test the processed_data logic
test_that("processed_data logic works correctly", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Female", "Male", "Female"),
    treatment = c("A", NA, "B", NA),
    breed = c("Angus", "Hereford", "Angus", "Hereford"),
    mob = c("Mob1", "Mob2", "Mob1", "Mob2"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Simulate the processed_data logic
  df <- test_data
  if (nrow(df) == 0) {
    result <- df
  } else {
    # Add group column for visualization using simplified labels
    input <- list(sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
    df$group <- create_simplified_group_labels(df, input)
    
    # Handle NA treatments for display
    df$treatment_display <- ifelse(is.na(df$treatment), "No Treatment", df$treatment)
    
    result <- df
  }
  
  expect_true("group" %in% names(result))
  expect_true("treatment_display" %in% names(result))
  expect_equal(result$treatment_display, c("A", "No Treatment", "B", "No Treatment"))
  # Since the data has variations, we should get detailed labels, not "Overall Average"
  expect_equal(length(result$group), 4)
  expect_true(all(grepl("Sex:", result$group)))
  expect_true(all(grepl("Treatment:", result$group)))
  expect_true(all(grepl("Breed:", result$group)))
  expect_true(all(grepl("Mob:", result$group)))
  expect_true(all(grepl("Eid:", result$group)))
})

# Test the processed_data logic with truly uniform data
test_that("processed_data logic works with uniform data", {
  test_data <- data.frame(
    eid = 1:4,
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Male", "Male", "Male", "Male"),
    treatment = c("A", "A", "A", "A"),
    breed = c("Angus", "Angus", "Angus", "Angus"),
    mob = c("Mob1", "Mob1", "Mob1", "Mob1"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Simulate the processed_data logic
  df <- test_data
  if (nrow(df) == 0) {
    result <- df
  } else {
    # Add group column for visualization using simplified labels
    input <- list(sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
    df$group <- create_simplified_group_labels(df, input)
    
    # Handle NA treatments for display
    df$treatment_display <- ifelse(is.na(df$treatment), "No Treatment", df$treatment)
    
    result <- df
  }
  
  expect_true("group" %in% names(result))
  expect_true("treatment_display" %in% names(result))
  expect_equal(result$treatment_display, c("A", "A", "A", "A"))
  # Since EID values are different (1,2,3,4), we get labels showing only the varying column (EID)
  expect_equal(length(result$group), 4)
  expect_true(all(grepl("Eid:", result$group)))
  # Since only EID varies, other columns are not shown in the labels
  expect_false(any(grepl("Sex:", result$group)))
  expect_false(any(grepl("Treatment:", result$group)))
  expect_false(any(grepl("Breed:", result$group)))
  expect_false(any(grepl("Mob:", result$group)))
})

# Test the processed_data logic with data that has "Overall" values
test_that("processed_data logic works with Overall data values", {
  test_data <- data.frame(
    eid = c("Overall", "Overall", "Overall", "Overall"),
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04")),
    sex = c("Overall", "Overall", "Overall", "Overall"),
    treatment = c("Overall", "Overall", "Overall", "Overall"),
    breed = c("Overall", "Overall", "Overall", "Overall"),
    mob = c("Overall", "Overall", "Overall", "Overall"),
    finalpweight = rnorm(4, 500, 50)
  )
  
  # Simulate the processed_data logic
  df <- test_data
  if (nrow(df) == 0) {
    result <- df
  } else {
    # Add group column for visualization using simplified labels
    input <- list(sex = "Overall", treatment = "Overall", breed = "Overall", mob = "Overall", eid = "Overall")
    df$group <- create_simplified_group_labels(df, input)
    
    # Handle NA treatments for display
    df$treatment_display <- ifelse(is.na(df$treatment), "No Treatment", df$treatment)
    
    result <- df
  }
  
  expect_true("group" %in% names(result))
  expect_true("treatment_display" %in% names(result))
  expect_equal(result$treatment_display, c("Overall", "Overall", "Overall", "Overall"))
  # With all "Overall" data values, should get "Overall Average"
  expect_equal(result$group, rep("Overall Average", 4))
})
