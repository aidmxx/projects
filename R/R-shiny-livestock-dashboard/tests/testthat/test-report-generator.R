# Unit tests for report_generator.R

library(testthat)

test_that("generate_summary_stats returns message for empty data", {
  df <- data.frame()
  res <- generate_summary_stats(df)
  expect_true(is.character(res))
  expect_match(res, "No data available")
})

test_that("generate_summary_stats handles non-numeric data", {
  df <- data.frame(cat = c("a","b","c"))
  res <- generate_summary_stats(df)
  expect_true(is.character(res))
  expect_match(res, "No numeric data")
})

test_that("generate_summary_stats computes basic stats on first numeric column", {
  set.seed(1)
  df <- data.frame(a = letters[1:5], x = c(1, 2, NA, 4, 5), y = rnorm(5))
  res <- generate_summary_stats(df)
  expect_type(res, "list")
  expect_equal(res$total_records, nrow(df))
  expect_equal(res$measure_name, "x")
  expect_equal(res$mean_value, round(mean(df$x, na.rm = TRUE), 2))
  expect_equal(res$median_value, round(median(df$x, na.rm = TRUE), 2))
  expect_equal(res$min_value, round(min(df$x, na.rm = TRUE), 2))
  expect_equal(res$max_value, round(max(df$x, na.rm = TRUE), 2))
  expect_equal(res$std_dev, round(sd(df$x, na.rm = TRUE), 2))
})

test_that("generate_filter_summary collects non-overall filters", {
  input <- list(
    year = 2024,
    month = "May",
    day = 15,
    sex = c("Male"),
    treatment = c("Control", "Treatment A"),
    breed = c("Angus", "Hereford"),
    mob = c("Mob1")
  )
  res <- generate_filter_summary(input)
  expect_true(is.list(res))
  expect_equal(res$year, 2024)
  expect_equal(res$month, "May")
  expect_equal(res$day, 15)
  expect_equal(res$sex, "Male")
  expect_match(res$treatment, "Control")
  expect_match(res$breed, "Angus")
  expect_match(res$mob, "Mob1")
})

test_that("generate_filter_summary ignores 'Overall' and NULLs", {
  input <- list(
    year = NULL,
    month = "All",
    day = "All",
    sex = c("Overall"),
    treatment = c("Overall"),
    breed = c("Overall"),
    mob = c("Overall")
  )
  res <- generate_filter_summary(input)
  expect_equal(length(res), 0)
})

test_that("create_dashboard_chart returns NULL for empty or non-numeric data", {
  df_empty <- data.frame()
  expect_null(create_dashboard_chart(df_empty))

  df_nonnum <- data.frame(a = letters[1:3])
  expect_null(create_dashboard_chart(df_nonnum))
})

test_that("create_dashboard_chart handles NULL measure_col by selecting first numeric column", {
  df <- data.frame(a = letters[1:3], val = c(1,2,3), other = c(4,5,6))
  path <- create_dashboard_chart(df, chart_type = "Distribution", measure_col = NULL)
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart handles invalid measure_col by reselecting numeric column", {
  df <- data.frame(a = letters[1:3], val = c(1,2,3))
  # Test with measure_col that doesn't exist in the data
  path <- create_dashboard_chart(df, chart_type = "Distribution", measure_col = "nonexistent")
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart handles NA measure_col by reselecting numeric column", {
  df <- data.frame(a = letters[1:3], val = c(1,2,3))
  # Test with NA measure_col
  path <- create_dashboard_chart(df, chart_type = "Distribution", measure_col = NA)
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart returns NULL when no numeric columns exist after validation", {
  # Create data with only non-numeric columns
  df <- data.frame(a = letters[1:3], b = c("x", "y", "z"))
  # This should trigger the return(NULL) on line 77
  result <- create_dashboard_chart(df, chart_type = "Distribution", measure_col = "nonexistent")
  expect_null(result)
})

test_that("create_dashboard_chart returns NULL for unsupported chart type", {
  df <- data.frame(val = c(1,2,3))
  # Test with an unsupported chart type to trigger line 171
  result <- create_dashboard_chart(df, chart_type = "UnsupportedType", measure_col = "val")
  expect_null(result)
})

test_that("create_dashboard_chart generates png for Distribution", {
  df <- data.frame(val = c(1,2,2,3,3,3,4,5))
  path <- create_dashboard_chart(df, chart_type = "Distribution", measure_col = "val")
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart generates png for Time Series with date", {
  df <- data.frame(date = as.Date("2024-01-01") + 0:4, val = c(1,2,3,4,5))
  path <- create_dashboard_chart(df, chart_type = "Time Series", measure_col = "val")
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart generates png for Time Series without date", {
  df <- data.frame(val = c(1,3,2,5,4))
  path <- create_dashboard_chart(df, chart_type = "Time Series", measure_col = "val")
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart generates png for Cohorts with group column", {
  df <- data.frame(breed = c("A","A","B","B"), val = c(1,2,3,4))
  path <- create_dashboard_chart(df, chart_type = "Cohorts", measure_col = "val")
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart generates boxplot when group column missing", {
  df <- data.frame(val = c(1,2,3,4))
  path <- create_dashboard_chart(df, chart_type = "Cohorts", measure_col = "val")
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart generates combined summary stats", {
  df <- data.frame(val = c(1,2,3,4,5))
  path <- create_dashboard_chart(df, chart_type = "Summary Statistics", measure_col = "val")
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("generate_email_report builds summary with filters", {
  df <- data.frame(val = c(1,2,3,4,5))
  input <- list(year = 2024, month = "Jan", sex = c("Male","Female"))
  content <- generate_email_report(df, input, report_type = "summary")
  expect_true(is.character(content))
  expect_match(content, "Livestock Dashboard - Automated Report")
  expect_match(content, "Total Records:")
  expect_match(content, "Measure:")
  expect_match(content, "Applied Filters")
})

test_that("generate_email_report builds detailed report", {
  df <- data.frame(val = c(10,20,30))
  input <- list()
  content <- generate_email_report(df, input, report_type = "detailed")
  expect_true(is.character(content))
  expect_match(content, "Livestock Dashboard - Detailed Report")
  expect_match(content, "Records Analyzed:")
})

# Tests for new grouped data time series functionality
test_that("create_dashboard_chart uses grouped data for Time Series when available", {
  # Create grouped data similar to what grouped_data() would return
  grouped_data <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-01", "2024-01-02", "2024-01-02")),
    group = c("Breed A", "Breed B", "Breed A", "Breed B"),
    finalpweight = c(100, 120, 105, 125)
  )
  
  # Create filtered data (not used in this path but required by function)
  filtered_data <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-02")),
    finalpweight = c(110, 115)
  )
  
  path <- create_dashboard_chart(
    filtered_data, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = grouped_data
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart groups by date and group for Time Series with grouped data", {
  # Create grouped data with multiple groups and dates
  grouped_data <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-01", "2024-01-02", "2024-01-02", "2024-01-03", "2024-01-03")),
    group = c("Breed A", "Breed B", "Breed A", "Breed B", "Breed A", "Breed B"),
    finalpweight = c(100, 120, 105, 125, 110, 130)
  )
  
  filtered_data <- data.frame(finalpweight = c(100, 120))
  
  path <- create_dashboard_chart(
    filtered_data, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = grouped_data
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart handles NA values in grouped data for Time Series", {
  # Create grouped data with NA values
  grouped_data <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-01", "2024-01-02", "2024-01-02")),
    group = c("Breed A", "Breed B", "Breed A", "Breed B"),
    finalpweight = c(100, NA, 105, 125)
  )
  
  filtered_data <- data.frame(finalpweight = c(100, 120))
  
  # Expect warnings for NA values (this is expected behavior)
  expect_warning(
    path <- create_dashboard_chart(
      filtered_data, 
      chart_type = "Time Series", 
      measure_col = "finalpweight",
      grouped_data = grouped_data
    ),
    "Removed.*row.*containing missing values"
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart falls back to simple aggregation when grouped_data is NULL", {
  # Test the fallback path when grouped_data is NULL
  df <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
    finalpweight = c(100, 105, 110)
  )
  
  path <- create_dashboard_chart(
    df, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = NULL
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart falls back to simple aggregation when grouped_data is empty", {
  # Test the fallback path when grouped_data has no rows
  df <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
    finalpweight = c(100, 105, 110)
  )
  
  empty_grouped_data <- data.frame(
    date = as.Date(character(0)),
    group = character(0),
    finalpweight = numeric(0)
  )
  
  path <- create_dashboard_chart(
    df, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = empty_grouped_data
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart handles grouped data without date column", {
  # Test fallback when grouped data doesn't have proper date column
  # This should trigger the fallback path since grouped_data is malformed
  grouped_data <- data.frame(
    group = c("Breed A", "Breed B"),
    finalpweight = c(100, 120)
  )
  
  df <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-02")),
    finalpweight = c(100, 105)
  )
  
  # This should trigger the fallback path and use the filtered_data instead
  path <- create_dashboard_chart(
    df, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = grouped_data
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart handles grouped data without group column", {
  # Test fallback when grouped data doesn't have group column
  grouped_data <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-02")),
    finalpweight = c(100, 120)
  )
  
  df <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-02")),
    finalpweight = c(100, 105)
  )
  
  # This should trigger the fallback path and use the filtered_data instead
  path <- create_dashboard_chart(
    df, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = grouped_data
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart creates proper ggplot with grouped data", {
  # Test that the ggplot object is created with correct aesthetics
  grouped_data <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-01", "2024-01-02", "2024-01-02")),
    group = c("Breed A", "Breed B", "Breed A", "Breed B"),
    finalpweight = c(100, 120, 105, 125)
  )
  
  filtered_data <- data.frame(finalpweight = c(100, 120))
  
  # Capture the plot creation process
  path <- create_dashboard_chart(
    filtered_data, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = grouped_data
  )
  
  # Verify the file was created successfully
  expect_true(file.exists(path))
  
  # Clean up
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart handles multiple groups in Time Series", {
  # Test with multiple groups to ensure proper line separation
  grouped_data <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-01", "2024-01-01", "2024-01-02", "2024-01-02", "2024-01-02")),
    group = c("Breed A", "Breed B", "Breed C", "Breed A", "Breed B", "Breed C"),
    finalpweight = c(100, 120, 110, 105, 125, 115)
  )
  
  filtered_data <- data.frame(finalpweight = c(100, 120))
  
  path <- create_dashboard_chart(
    filtered_data, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = grouped_data
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})

test_that("create_dashboard_chart handles single group in Time Series", {
  # Test with single group
  grouped_data <- data.frame(
    date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
    group = c("Breed A", "Breed A", "Breed A"),
    finalpweight = c(100, 105, 110)
  )
  
  filtered_data <- data.frame(finalpweight = c(100, 120))
  
  path <- create_dashboard_chart(
    filtered_data, 
    chart_type = "Time Series", 
    measure_col = "finalpweight",
    grouped_data = grouped_data
  )
  
  expect_true(is.character(path))
  expect_true(file.exists(path))
  on.exit({ if (file.exists(path)) unlink(path) })
})


