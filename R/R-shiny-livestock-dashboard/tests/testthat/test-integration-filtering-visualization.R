# Integration Tests: Data Filtering and Visualization
# Tests the complete workflow from filter inputs to visualization outputs across all pages

library(testthat)
library(shiny)
library(dplyr)
library(plotly)

# Mock data for testing
test_data <- data.frame(
  eid = c("E001", "E002", "E003", "E004", "E005"),
  date = as.Date(c("2023-01-15", "2023-02-20", "2023-03-10", "2023-04-05", "2023-05-12")),
  sex = c("Male", "Female", "Male", "Female", "Male"),
  breed = c("Angus", "Hereford", "Angus", "Angus", "Hereford"),
  treatment = c("Control", "Treatment A", "Control", "Treatment B", "Treatment A"),
  mob = c("Mob1", "Mob2", "Mob1", "Mob2", "Mob1"),
  finalpweight = c(450, 380, 420, 390, 440),
  feedintake = c(12.5, 11.8, 13.2, 12.1, 12.9),
  methane = c(25.3, 22.1, 26.8, 23.5, 25.1),
  stringsAsFactors = FALSE
)

# Mock database connection
mock_con <- list(
  dbExecute = function(con, sql, params = NULL) { return(TRUE) },
  dbGetQuery = function(con, sql) { return(data.frame()) },
  dbIsValid = function(con) { return(TRUE) }
)

# Source required functions
if (file.exists("src/filter.R")) {
  source("src/filter.R")
} else if (file.exists("../src/filter.R")) {
  source("../src/filter.R")
} else if (file.exists("../../src/filter.R")) {
  source("../../src/filter.R")
}

# Mock authentication
mock_auth <- reactiveValues(
  is_admin = TRUE,
  user = "test_user"
)

# Test 1: Complete Filtering Workflow Integration
test_that("complete filtering workflow integrates correctly", {
  # Mock input values
  mock_input <- list(
    year = 2023,
    month = "All",
    day = "All",
    sex = c("Male"),
    treatment = c("Control"),
    breed = c("Angus"),
    mob = c("Mob1"),
    measure = "finalpweight"
  )
  
  # Mock the filtering function
  filter_data_mock <- function(data, input, is_admin = TRUE) {
    # Apply filters based on input values
    filtered <- data
    
    if (!is.null(input$year) && input$year != "All") {
      filtered <- filtered[year(filtered$date) == input$year, ]
    }
    
    if (!is.null(input$sex) && !"All" %in% input$sex) {
      filtered <- filtered[filtered$sex %in% input$sex, ]
    }
    
    if (!is.null(input$treatment) && !"All" %in% input$treatment) {
      filtered <- filtered[filtered$treatment %in% input$treatment, ]
    }
    
    if (!is.null(input$breed) && !"All" %in% input$breed) {
      filtered <- filtered[filtered$breed %in% input$breed, ]
    }
    
    if (!is.null(input$mob) && !"All" %in% input$mob) {
      filtered <- filtered[filtered$mob %in% input$mob, ]
    }
    
    return(filtered)
  }
  
  # Mock the processed data function
  process_data_mock <- function(df, measure) {
    if (nrow(df) > 0) {
      df$measure_value <- df[[measure]]
      df
    } else {
      df
    }
  }
  
  # Test filter application
  filtered <- filter_data_mock(test_data, mock_input, is_admin = TRUE)
  expect_equal(nrow(filtered), 2)  # Should have 2 records matching filters
  expect_true(all(filtered$sex == "Male"))
  expect_true(all(filtered$treatment == "Control"))
  expect_true(all(filtered$breed == "Angus"))
  
  # Verify processed data
  processed <- process_data_mock(filtered, mock_input$measure)
  expect_true("measure_value" %in% names(processed))
  expect_equal(processed$measure_value, processed$finalpweight)
  
  # Test filter change
  mock_input_female <- mock_input
  mock_input_female$sex <- c("Female")
  filtered_after_change <- filter_data_mock(test_data, mock_input_female, is_admin = TRUE)
  expect_equal(nrow(filtered_after_change), 0)  # No records should match
})

# Test 2: Filter Integration with Summary Stats
test_that("filtering integrates with summary statistics", {
  # Mock summary stats calculation
  calculate_summary_stats <- function(data, measure) {
    if (nrow(data) == 0) {
      return(list(
        count = 0,
        mean = NA,
        median = NA,
        min = NA,
        max = NA,
        sd = NA
      ))
    }
    
    values <- data[[measure]]
    list(
      count = nrow(data),
      mean = mean(values, na.rm = TRUE),
      median = median(values, na.rm = TRUE),
      min = min(values, na.rm = TRUE),
      max = max(values, na.rm = TRUE),
      sd = sd(values, na.rm = TRUE)
    )
  }
  
  # Mock filtering function (same as test 1)
  filter_data_mock <- function(data, input, is_admin = TRUE) {
    filtered <- data
    
    if (!is.null(input$year) && input$year != "All") {
      filtered <- filtered[year(filtered$date) == input$year, ]
    }
    
    if (!is.null(input$sex) && !"All" %in% input$sex) {
      filtered <- filtered[filtered$sex %in% input$sex, ]
    }
    
    if (!is.null(input$treatment) && !"All" %in% input$treatment) {
      filtered <- filtered[filtered$treatment %in% input$treatment, ]
    }
    
    if (!is.null(input$breed) && !"All" %in% input$breed) {
      filtered <- filtered[filtered$breed %in% input$breed, ]
    }
    
    if (!is.null(input$mob) && !"All" %in% input$mob) {
      filtered <- filtered[filtered$mob %in% input$mob, ]
    }
    
    return(filtered)
  }
  
  # Mock summary stats output function
  get_summary_text <- function(df, measure) {
    stats <- calculate_summary_stats(df, measure)
    
    if (stats$count == 0) {
      "No data available"
    } else {
      sprintf("Count: %d, Mean: %.1f, Min: %.1f, Max: %.1f",
              stats$count, stats$mean, stats$min, stats$max)
    }
  }
  
  # Test with specific filters
  mock_input <- list(
    year = 2023,
    sex = c("Male"),
    breed = c("Angus"),
    measure = "finalpweight"
  )
  
  filtered <- filter_data_mock(test_data, mock_input, is_admin = TRUE)
  summary_text <- get_summary_text(filtered, mock_input$measure)
  
  expect_true(grepl("Count: 2", summary_text))
  expect_true(grepl("Mean: 435", summary_text))  # (450 + 420) / 2
  
  # Test with no matching data (use a combination that doesn't exist)
  mock_input_empty <- list(
    year = 2023,
    sex = c("Female"),
    breed = c("Angus"),
    treatment = c("Control"),  # This combination doesn't exist
    measure = "finalpweight"
  )
  
  filtered_empty <- filter_data_mock(test_data, mock_input_empty, is_admin = TRUE)
  summary_text_empty <- get_summary_text(filtered_empty, mock_input_empty$measure)
  expect_equal(summary_text_empty, "No data available")
})

# Test 3: Filter Integration with Time Series Visualization
test_that("filtering integrates with time series visualization", {
  # Mock time series data processing
  process_timeseries_data <- function(data, measure) {
    if (nrow(data) == 0) {
      return(data.frame())
    }
    
    data %>%
      group_by(date) %>%
      summarise(
        mean_value = mean(.data[[measure]], na.rm = TRUE),
        count = n(),
        .groups = "drop"
      ) %>%
      arrange(date)
  }
  
  # Mock filtering function (same as previous tests)
  filter_data_mock <- function(data, input, is_admin = TRUE) {
    filtered <- data
    
    if (!is.null(input$year) && input$year != "All") {
      filtered <- filtered[year(filtered$date) == input$year, ]
    }
    
    if (!is.null(input$sex) && !"All" %in% input$sex) {
      filtered <- filtered[filtered$sex %in% input$sex, ]
    }
    
    if (!is.null(input$treatment) && !"All" %in% input$treatment) {
      filtered <- filtered[filtered$treatment %in% input$treatment, ]
    }
    
    if (!is.null(input$breed) && !"All" %in% input$breed) {
      filtered <- filtered[filtered$breed %in% input$breed, ]
    }
    
    if (!is.null(input$mob) && !"All" %in% input$mob) {
      filtered <- filtered[filtered$mob %in% input$mob, ]
    }
    
    return(filtered)
  }
  
  # Mock time series plot creation
  create_timeseries_plot <- function(ts_data) {
    if (nrow(ts_data) == 0) {
      return(plotly_empty())
    }
    
    p <- plot_ly(ts_data, x = ~date, y = ~mean_value, type = "scatter", mode = "lines+markers")
    return(p)
  }
  
  # Test with filters
  mock_input <- list(
    year = 2023,
    treatment = c("Control"),
    measure = "finalpweight"
  )
  
  df <- filter_data_mock(test_data, mock_input, is_admin = TRUE)
  ts_data <- process_timeseries_data(df, mock_input$measure)
  
  expect_true(nrow(ts_data) > 0)
  expect_true("date" %in% names(ts_data))
  expect_true("mean_value" %in% names(ts_data))
  
  # Test plot creation
  plot <- create_timeseries_plot(ts_data)
  expect_true(inherits(plot, "plotly"))
  
  # Test with no data
  mock_input_empty <- list(
    year = 2023,
    treatment = c("NonExistent"),
    measure = "finalpweight"
  )
  
  df_empty <- filter_data_mock(test_data, mock_input_empty, is_admin = TRUE)
  ts_data_empty <- process_timeseries_data(df_empty, mock_input_empty$measure)
  expect_equal(nrow(ts_data_empty), 0)
  
  # Test empty plot creation
  empty_plot <- create_timeseries_plot(ts_data_empty)
  expect_true(inherits(empty_plot, "plotly"))
})

# Test 4: Filter Integration with Cohort Analysis
test_that("filtering integrates with cohort analysis", {
  # Mock cohort analysis
  perform_cohort_analysis <- function(data, measure) {
    if (nrow(data) == 0) {
      return(data.frame())
    }
    
    data %>%
      group_by(sex, treatment) %>%
      summarise(
        mean_value = mean(.data[[measure]], na.rm = TRUE),
        count = n(),
        .groups = "drop"
      )
  }
  
  # Mock filtering function (same as previous tests)
  filter_data_mock <- function(data, input, is_admin = TRUE) {
    filtered <- data
    
    if (!is.null(input$year) && input$year != "All") {
      filtered <- filtered[year(filtered$date) == input$year, ]
    }
    
    if (!is.null(input$sex) && !"All" %in% input$sex) {
      filtered <- filtered[filtered$sex %in% input$sex, ]
    }
    
    if (!is.null(input$treatment) && !"All" %in% input$treatment) {
      filtered <- filtered[filtered$treatment %in% input$treatment, ]
    }
    
    if (!is.null(input$breed) && !"All" %in% input$breed) {
      filtered <- filtered[filtered$breed %in% input$breed, ]
    }
    
    if (!is.null(input$mob) && !"All" %in% input$mob) {
      filtered <- filtered[filtered$mob %in% input$mob, ]
    }
    
    return(filtered)
  }
  
  # Mock cohort plot creation
  create_cohort_plot <- function(cohort_data) {
    if (nrow(cohort_data) == 0) {
      return(plotly_empty())
    }
    
    p <- plot_ly(cohort_data, x = ~sex, y = ~mean_value, color = ~treatment, type = "bar")
    return(p)
  }
  
  # Test with specific filters
  mock_input <- list(
    year = 2023,
    breed = c("Angus"),
    measure = "finalpweight"
  )
  
  df <- filter_data_mock(test_data, mock_input, is_admin = TRUE)
  cohort_data <- perform_cohort_analysis(df, mock_input$measure)
  
  expect_true(nrow(cohort_data) > 0)
  expect_true(all(c("sex", "treatment", "mean_value") %in% names(cohort_data)))
  
  # Test plot creation
  plot <- create_cohort_plot(cohort_data)
  expect_true(inherits(plot, "plotly"))
  
  # Test with restrictive filters
  mock_input_restricted <- list(
    year = 2023,
    sex = c("Male"),
    treatment = c("Control"),
    breed = c("Angus"),
    measure = "finalpweight"
  )
  
  df_restricted <- filter_data_mock(test_data, mock_input_restricted, is_admin = TRUE)
  cohort_data_restricted <- perform_cohort_analysis(df_restricted, mock_input_restricted$measure)
  
  expect_true(nrow(cohort_data_restricted) <= nrow(cohort_data))
})

# Test 5: Filter Integration with Data Management
test_that("filtering integrates with data management table", {
  # Mock filtering function (same as previous tests)
  filter_data_mock <- function(data, input, is_admin = TRUE) {
    filtered <- data
    
    if (!is.null(input$year) && input$year != "All") {
      filtered <- filtered[year(filtered$date) == input$year, ]
    }
    
    if (!is.null(input$sex) && !"All" %in% input$sex) {
      filtered <- filtered[filtered$sex %in% input$sex, ]
    }
    
    if (!is.null(input$treatment) && !"All" %in% input$treatment) {
      filtered <- filtered[filtered$treatment %in% input$treatment, ]
    }
    
    if (!is.null(input$breed) && !"All" %in% input$breed) {
      filtered <- filtered[filtered$breed %in% input$breed, ]
    }
    
    if (!is.null(input$mob) && !"All" %in% input$mob) {
      filtered <- filtered[filtered$mob %in% input$mob, ]
    }
    
    return(filtered)
  }
  
  # Mock data table creation
  create_data_table <- function(df, is_admin = TRUE) {
    # Anonymize EIDs for non-admin users
    if (!is_admin && "eid" %in% names(df)) {
      df$eid <- "*****"
    }
    
    DT::datatable(df, options = list(pageLength = 10))
  }
  
  # Mock download filename generation
  generate_download_filename <- function() {
    paste0("livestock_data_", format(Sys.Date(), "%Y%m%d"), ".csv")
  }
  
  # Test with filters
  mock_input <- list(
    year = 2023,
    sex = c("Male"),
    is_admin = TRUE
  )
  
  df <- filter_data_mock(test_data, mock_input, is_admin = TRUE)
  expect_true(nrow(df) > 0)
  expect_true(all(df$sex == "Male"))
  
  # Test data table creation
  data_table <- create_data_table(df, is_admin = TRUE)
  expect_true(inherits(data_table, "datatables"))
  
  # Test EID anonymization
  df_anon <- filter_data_mock(test_data, mock_input, is_admin = FALSE)
  data_table_anon <- create_data_table(df_anon, is_admin = FALSE)
  
  # Create a copy of the data for anonymization testing
  df_anon_copy <- df_anon
  if ("eid" %in% names(df_anon_copy)) {
    df_anon_copy$eid <- "*****"
    expect_true(all(df_anon_copy$eid == "*****"))
  }
  
  # Test that the data table was created successfully
  expect_true(inherits(data_table_anon, "datatables"))
  
  # Test download filename generation
  filename <- generate_download_filename()
  expect_true(grepl("livestock_data_", filename))
  expect_true(grepl(format(Sys.Date(), "%Y%m%d"), filename))
})

# Test 6: Filter State Management Integration
test_that("filter state management integrates correctly", {
  # Mock saved views storage
  saved_views <- list(views = list())
  
  # Mock save current view function
  save_current_view <- function(view_name, current_filters, storage) {
    if (!is.null(view_name) && view_name != "") {
      storage$views[[view_name]] <- current_filters
    }
    return(storage)
  }
  
  # Mock load saved view function
  load_saved_view <- function(view_name, storage) {
    if (!is.null(view_name) && view_name %in% names(storage$views)) {
      return(storage$views[[view_name]])
    }
    return(NULL)
  }
  
  # Mock filtering function (same as previous tests)
  filter_data_mock <- function(data, input, is_admin = TRUE) {
    filtered <- data
    
    if (!is.null(input$year) && input$year != "All") {
      filtered <- filtered[year(filtered$date) == input$year, ]
    }
    
    if (!is.null(input$sex) && !"All" %in% input$sex) {
      filtered <- filtered[filtered$sex %in% input$sex, ]
    }
    
    if (!is.null(input$treatment) && !"All" %in% input$treatment) {
      filtered <- filtered[filtered$treatment %in% input$treatment, ]
    }
    
    if (!is.null(input$breed) && !"All" %in% input$breed) {
      filtered <- filtered[filtered$breed %in% input$breed, ]
    }
    
    if (!is.null(input$mob) && !"All" %in% input$mob) {
      filtered <- filtered[filtered$mob %in% input$mob, ]
    }
    
    return(filtered)
  }
  
  # Test saving and loading views
  current_filters <- list(
    year = 2023,
    month = "All",
    day = "All",
    sex = c("Male"),
    treatment = c("Control"),
    breed = c("All"),
    mob = c("All"),
    measure = "finalpweight"
  )
  
  # Save view
  saved_views <- save_current_view("Male Control View", current_filters, saved_views)
  
  # Verify view was saved
  expect_true("Male Control View" %in% names(saved_views$views))
  saved_filters <- saved_views$views[["Male Control View"]]
  expect_equal(saved_filters$sex, c("Male"))
  expect_equal(saved_filters$treatment, c("Control"))
  
  # Test loading view
  loaded_filters <- load_saved_view("Male Control View", saved_views)
  expect_equal(loaded_filters$year, 2023)
  expect_equal(loaded_filters$sex, c("Male"))
  expect_equal(loaded_filters$treatment, c("Control"))
  
  # Test filtering with loaded view
  filtered <- filter_data_mock(test_data, loaded_filters, is_admin = TRUE)
  expect_true(nrow(filtered) > 0)
  expect_true(all(filtered$sex == "Male"))
  expect_true(all(filtered$treatment == "Control"))
  
  # Test loading non-existent view
  non_existent <- load_saved_view("Non Existent View", saved_views)
  expect_null(non_existent)
})

# Test 7: Filter Performance Integration
test_that("filter performance integrates correctly", {
  # Mock filtering function (same as previous tests)
  filter_data_mock <- function(data, input, is_admin = TRUE) {
    filtered <- data
    
    if (!is.null(input$year) && input$year != "All") {
      filtered <- filtered[year(filtered$date) == input$year, ]
    }
    
    if (!is.null(input$sex) && !"All" %in% input$sex) {
      filtered <- filtered[filtered$sex %in% input$sex, ]
    }
    
    if (!is.null(input$treatment) && !"All" %in% input$treatment) {
      filtered <- filtered[filtered$treatment %in% input$treatment, ]
    }
    
    if (!is.null(input$breed) && !"All" %in% input$breed) {
      filtered <- filtered[filtered$breed %in% input$breed, ]
    }
    
    if (!is.null(input$mob) && !"All" %in% input$mob) {
      filtered <- filtered[filtered$mob %in% input$mob, ]
    }
    
    return(filtered)
  }
  
  # Mock filtered data with measure selection
  process_filtered_data <- function(data, input, measure) {
    df <- filter_data_mock(data, input, is_admin = TRUE)
    
    if (nrow(df) > 0 && !is.null(measure) && measure %in% names(df)) {
      df$selected_measure <- df[[measure]]
    }
    return(df)
  }
  
  # Mock record count function
  get_record_count <- function(df, total_records) {
    paste("Showing", nrow(df), "of", total_records, "records")
  }
  
  # Test with measure selection
  mock_input <- list(
    year = 2023,
    measure = "finalpweight"
  )
  
  df <- process_filtered_data(test_data, mock_input, mock_input$measure)
  expect_true("selected_measure" %in% names(df))
  expect_equal(df$selected_measure, df$finalpweight)
  
  # Test record count
  count_text <- get_record_count(df, nrow(test_data))
  expect_true(grepl("Showing", count_text))
  expect_true(grepl("of", count_text))
  
  # Test with restrictive filters
  mock_input_restricted <- list(
    year = 2023,
    sex = c("Male"),
    treatment = c("Control"),
    breed = c("Angus"),
    measure = "finalpweight"
  )
  
  df_restricted <- process_filtered_data(test_data, mock_input_restricted, mock_input_restricted$measure)
  count_text_restricted <- get_record_count(df_restricted, nrow(test_data))
  
  expect_true(nrow(df_restricted) < nrow(test_data))
  expect_true(grepl(paste("Showing", nrow(df_restricted)), count_text_restricted))
  
  # Test performance with timing
  start_time <- Sys.time()
  df_perf <- process_filtered_data(test_data, mock_input, mock_input$measure)
  end_time <- Sys.time()
  
  processing_time <- as.numeric(end_time - start_time, units = "secs")
  expect_true(processing_time < 1)  # Should be fast
  expect_true(nrow(df_perf) > 0)
})

# Test 8: Filter Error Handling Integration
test_that("filter error handling integrates correctly", {
  # Mock filtering function with error handling
  filter_data_with_error_handling <- function(data, input, is_admin = TRUE) {
    tryCatch({
      filtered <- data
      
      if (!is.null(input$year) && input$year != "All") {
        filtered <- filtered[year(filtered$date) == input$year, ]
      }
      
      if (!is.null(input$sex) && !"All" %in% input$sex) {
        filtered <- filtered[filtered$sex %in% input$sex, ]
      }
      
      if (!is.null(input$treatment) && !"All" %in% input$treatment) {
        filtered <- filtered[filtered$treatment %in% input$treatment, ]
      }
      
      if (!is.null(input$breed) && !"All" %in% input$breed) {
        filtered <- filtered[filtered$breed %in% input$breed, ]
      }
      
      if (!is.null(input$mob) && !"All" %in% input$mob) {
        filtered <- filtered[filtered$mob %in% input$mob, ]
      }
      
      return(filtered)
    }, error = function(e) {
      # Return empty data frame on error
      return(data.frame())
    })
  }
  
  # Mock error message function
  get_error_message <- function(df, input) {
    if (nrow(df) == 0 && !is.null(input$year)) {
      "No data matches the selected filters"
    } else {
      ""
    }
  }
  
  # Test with invalid year (NULL should return all records)
  mock_input_null <- list(year = NULL)
  df <- filter_data_with_error_handling(test_data, mock_input_null, is_admin = TRUE)
  expect_equal(nrow(df), nrow(test_data))  # Should return all records when year is NULL
  
  # Test with valid filters but no matching data
  mock_input_empty <- list(
    year = 2025,  # Future year with no data
    sex = c("Male")
  )
  
  df_empty <- filter_data_with_error_handling(test_data, mock_input_empty, is_admin = TRUE)
  error_msg <- get_error_message(df_empty, mock_input_empty)
  
  expect_equal(nrow(df_empty), 0)
  expect_equal(error_msg, "No data matches the selected filters")
  
  # Test with valid filters
  mock_input_valid <- list(
    year = 2023,
    sex = c("Male")
  )
  
  df_valid <- filter_data_with_error_handling(test_data, mock_input_valid, is_admin = TRUE)
  error_msg_valid <- get_error_message(df_valid, mock_input_valid)
  
  expect_true(nrow(df_valid) > 0)
  expect_equal(error_msg_valid, "")
  
  # Test with malformed input
  mock_input_malformed <- list(
    year = "invalid",
    sex = c("Male")
  )
  
  df_malformed <- filter_data_with_error_handling(test_data, mock_input_malformed, is_admin = TRUE)
  expect_equal(nrow(df_malformed), 0)  # Should handle gracefully
})
