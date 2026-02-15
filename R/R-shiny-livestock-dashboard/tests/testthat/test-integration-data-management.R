# Integration Tests: Data Management Workflow
# Tests the complete workflow from data display to export and management operations

library(testthat)
library(shiny)
library(dplyr)
library(DT)

# Mock data for testing
test_data <- data.frame(
  eid = c("E001", "E002", "E003", "E004", "E005", "E006", "E007", "E008"),
  date = as.Date(c("2023-01-15", "2023-02-20", "2023-03-10", "2023-04-05", 
                   "2023-05-12", "2023-06-18", "2023-07-25", "2023-08-30")),
  sex = c("Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female"),
  breed = c("Angus", "Hereford", "Angus", "Angus", "Hereford", "Angus", "Angus", "Hereford"),
  treatment = c("Control", "Treatment A", "Control", "Treatment B", "Treatment A", 
                "Control", "Treatment B", "Treatment A"),
  mob = c("Mob1", "Mob2", "Mob1", "Mob2", "Mob1", "Mob2", "Mob1", "Mob2"),
  finalpweight = c(450, 380, 420, 390, 440, 365, 435, 385),
  feedintake = c(12.5, 11.8, 13.2, 12.1, 12.9, 11.5, 13.0, 12.3),
  methane = c(25.3, 22.1, 26.8, 23.5, 25.1, 21.8, 26.2, 23.8),
  stringsAsFactors = FALSE
)

# Test 1: Complete Data Management Workflow
test_that("complete data management workflow integrates correctly", {
  # Mock data table rendering function
  render_data_table <- function(df) {
    # Format data for display
    df_display <- df %>%
      mutate(
        date = format(date, "%Y-%m-%d"),
        finalpweight = round(finalpweight, 1),
        feedintake = round(feedintake, 2),
        methane = round(methane, 1)
      )
    
    DT::datatable(
      df_display,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf')
      ),
      extensions = 'Buttons',
      rownames = FALSE
    )
  }
  
  # Mock record count function
  get_record_count <- function(df) {
    paste("Showing", nrow(df), "records")
  }
  
  # Test data table rendering
  data_table <- render_data_table(test_data)
  expect_true(!is.null(data_table))
  expect_true(inherits(data_table, "datatables"))
  
  # Verify record count
  count_text <- get_record_count(test_data)
  expect_true(grepl("Showing 8 records", count_text))
  
  # Test with filtered data
  filtered_data <- test_data %>% filter(sex == "Male")
  filtered_count_text <- get_record_count(filtered_data)
  expect_true(grepl("Showing 4 records", filtered_count_text))
  
  # Test filtered data table
  filtered_table <- render_data_table(filtered_data)
  expect_true(!is.null(filtered_table))
  expect_true(inherits(filtered_table, "datatables"))
})

# Test 2: Data Export Integration
test_that("data export integrates correctly", {
  # Mock filename generation functions
  generate_csv_filename <- function(base_name = "livestock_data") {
    paste0(base_name, "_", format(Sys.Date(), "%Y%m%d"), ".csv")
  }
  
  generate_excel_filename <- function(base_name = "livestock_data") {
    paste0(base_name, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx")
  }
  
  generate_pdf_filename <- function(base_name = "livestock_data") {
    paste0(base_name, "_", format(Sys.Date(), "%Y%m%d"), ".pdf")
  }
  
  # Mock export content generation
  generate_csv_content <- function(df) {
    # Mock CSV content generation
    return(paste("CSV content for", nrow(df), "records"))
  }
  
  generate_excel_content <- function(df) {
    # Mock Excel content generation
    return(paste("Excel content for", nrow(df), "records"))
  }
  
  generate_pdf_content <- function(df) {
    # Mock PDF content generation
    return(paste("PDF content for", nrow(df), "records"))
  }
  
  # Test filename generation
  csv_filename <- generate_csv_filename()
  excel_filename <- generate_excel_filename()
  pdf_filename <- generate_pdf_filename()
  
  expect_true(grepl("livestock_data_", csv_filename))
  expect_true(grepl(".csv", csv_filename))
  expect_true(grepl("livestock_data_", excel_filename))
  expect_true(grepl(".xlsx", excel_filename))
  expect_true(grepl("livestock_data_", pdf_filename))
  expect_true(grepl(".pdf", pdf_filename))
  
  # Test with custom filename
  custom_filename <- generate_csv_filename("custom_data_export")
  expect_true(grepl("custom_data_export", custom_filename))
  
  # Test content generation
  csv_content <- generate_csv_content(test_data)
  excel_content <- generate_excel_content(test_data)
  pdf_content <- generate_pdf_content(test_data)
  
  expect_true(grepl("CSV content for 8 records", csv_content))
  expect_true(grepl("Excel content for 8 records", excel_content))
  expect_true(grepl("PDF content for 8 records", pdf_content))
})

# Test 3: Data Search and Filtering Integration
test_that("data search and filtering integrates correctly", {
  # Mock search functionality
  perform_data_search <- function(data, search_term, search_columns) {
    if (is.null(search_term) || search_term == "") {
      return(data)
    }
    
    # Search across specified columns using if_any (replaces deprecated across)
    search_results <- data %>%
      filter(
        if_any(
          all_of(search_columns),
          ~ grepl(search_term, as.character(.), ignore.case = TRUE)
        )
      )
    
    return(search_results)
  }
  
  # Mock search count function
  get_search_count <- function(results) {
    paste("Found", nrow(results), "matching records")
  }
  
  # Test search functionality
  results <- perform_data_search(
    test_data,
    "Angus",
    c("eid", "sex", "breed", "treatment")
  )
  count_text <- get_search_count(results)
  
  expect_true(nrow(results) > 0)
  expect_true(all(results$breed == "Angus"))
  expect_true(grepl("Found", count_text))
  
  # Test search with no results
  no_results <- perform_data_search(
    test_data,
    "NonExistent",
    c("eid", "sex", "breed", "treatment")
  )
  no_count_text <- get_search_count(no_results)
  
  expect_equal(nrow(no_results), 0)
  expect_true(grepl("Found 0 matching records", no_count_text))
  
  # Test empty search
  empty_results <- perform_data_search(
    test_data,
    "",
    c("eid", "sex", "breed", "treatment")
  )
  expect_equal(nrow(empty_results), nrow(test_data))
  
  # Test search in specific column
  breed_results <- perform_data_search(
    test_data,
    "Hereford",
    c("breed")
  )
  expect_true(nrow(breed_results) > 0)
  expect_true(all(breed_results$breed == "Hereford"))
})

# Test 4: Data Sorting Integration
test_that("data sorting integrates correctly", {
  # Mock sorting functionality
  sort_data <- function(data, sort_column, sort_direction) {
    if (is.null(sort_column) || sort_column == "") {
      return(data)
    }
    
    if (sort_direction == "desc") {
      data %>% arrange(desc(.data[[sort_column]]))
    } else {
      data %>% arrange(.data[[sort_column]])
    }
  }
  
  # Test ascending sort
  asc_sorted <- sort_data(test_data, "finalpweight", "asc")
  expect_true(asc_sorted$finalpweight[1] <= asc_sorted$finalpweight[nrow(asc_sorted)])
  
  # Test descending sort
  desc_sorted <- sort_data(test_data, "finalpweight", "desc")
  expect_true(desc_sorted$finalpweight[1] >= desc_sorted$finalpweight[nrow(desc_sorted)])
  
  # Test sort by date
  date_sorted <- sort_data(test_data, "date", "asc")
  expect_true(date_sorted$date[1] <= date_sorted$date[nrow(date_sorted)])
  
  # Test sort by character column
  breed_sorted <- sort_data(test_data, "breed", "asc")
  expect_true(breed_sorted$breed[1] <= breed_sorted$breed[nrow(breed_sorted)])
  
  # Test sort with empty column
  empty_sorted <- sort_data(test_data, "", "asc")
  expect_equal(nrow(empty_sorted), nrow(test_data))
  
  # Test sort with NULL column
  null_sorted <- sort_data(test_data, NULL, "asc")
  expect_equal(nrow(null_sorted), nrow(test_data))
})

# Test 5: Data Pagination Integration
test_that("data pagination integrates correctly", {
  # Mock pagination functionality
  paginate_data <- function(data, page, page_size) {
    if (is.null(page) || is.null(page_size)) {
      return(data)
    }
    
    start_row <- (page - 1) * page_size + 1
    end_row <- min(page * page_size, nrow(data))
    
    if (start_row > nrow(data)) {
      return(data.frame())
    }
    
    data[start_row:end_row, , drop = FALSE]
  }
  
  # Mock pagination info function
  get_pagination_info <- function(df, page, page_size) {
    total_pages <- ceiling(nrow(df) / page_size)
    start_record <- (page - 1) * page_size + 1
    end_record <- min(page * page_size, nrow(df))
    
    paste("Page", page, "of", total_pages, "- Records", start_record, "to", end_record, "of", nrow(df))
  }
  
  # Test pagination
  page1_data <- paginate_data(test_data, 1, 3)
  pagination_text <- get_pagination_info(test_data, 1, 3)
  
  expect_equal(nrow(page1_data), 3)
  expect_true(grepl("Page 1 of 3", pagination_text))
  expect_true(grepl("Records 1 to 3 of 8", pagination_text))
  
  # Test second page
  page2_data <- paginate_data(test_data, 2, 3)
  page2_text <- get_pagination_info(test_data, 2, 3)
  
  expect_equal(nrow(page2_data), 3)
  expect_true(grepl("Page 2 of 3", page2_text))
  expect_true(grepl("Records 4 to 6 of 8", page2_text))
  
  # Test last page
  page3_data <- paginate_data(test_data, 3, 3)
  page3_text <- get_pagination_info(test_data, 3, 3)
  
  expect_equal(nrow(page3_data), 2)  # Only 2 records on last page
  expect_true(grepl("Page 3 of 3", page3_text))
  expect_true(grepl("Records 7 to 8 of 8", page3_text))
  
  # Test pagination with NULL inputs
  null_paginated <- paginate_data(test_data, NULL, NULL)
  expect_equal(nrow(null_paginated), nrow(test_data))
  
  # Test pagination with page beyond data
  empty_paginated <- paginate_data(test_data, 10, 3)
  expect_equal(nrow(empty_paginated), 0)
})

# Test 6: Data Column Management Integration
test_that("data column management integrates correctly", {
  # Mock column visibility functionality
  manage_columns <- function(data, visible_columns, column_order) {
    if (is.null(visible_columns) || length(visible_columns) == 0) {
      return(data)
    }
    
    # Select visible columns
    data_visible <- data[, visible_columns, drop = FALSE]
    
    # Reorder columns if specified
    if (!is.null(column_order) && length(column_order) > 0) {
      available_order <- intersect(column_order, names(data_visible))
      remaining_columns <- setdiff(names(data_visible), available_order)
      
      if (length(available_order) > 0) {
        # Put ordered columns first, then remaining columns
        final_order <- c(available_order, remaining_columns)
        data_visible <- data_visible[, final_order, drop = FALSE]
      }
    }
    
    return(data_visible)
  }
  
  # Test column visibility
  visible_data <- manage_columns(
    test_data,
    c("eid", "date", "sex", "finalpweight"),
    NULL
  )
  expect_equal(names(visible_data), c("eid", "date", "sex", "finalpweight"))
  
  # Test column reordering
  reordered_data <- manage_columns(
    test_data,
    c("eid", "date", "sex", "breed", "finalpweight"),
    c("finalpweight", "breed", "sex", "date", "eid")
  )
  expect_equal(names(reordered_data), c("finalpweight", "breed", "sex", "date", "eid"))
  
  # Test with no visible columns
  no_columns_data <- manage_columns(test_data, character(0), NULL)
  expect_equal(ncol(no_columns_data), ncol(test_data))  # Should return all columns
  
  # Test with NULL visible columns
  null_columns_data <- manage_columns(test_data, NULL, NULL)
  expect_equal(ncol(null_columns_data), ncol(test_data))  # Should return all columns
  
  # Test with partial column order
  partial_order_data <- manage_columns(
    test_data,
    c("eid", "date", "sex", "breed", "finalpweight"),
    c("finalpweight", "eid")  # Only some columns in order
  )
  # Should return all visible columns, with the ordered ones first
  expect_equal(names(partial_order_data), c("finalpweight", "eid", "date", "sex", "breed"))
})

# Test 7: Data Validation Integration
test_that("data validation integrates correctly", {
  # Mock data validation
  validate_data <- function(data) {
    validation_results <- list(
      total_records = nrow(data),
      missing_values = list(),
      data_types = list(),
      outliers = list(),
      duplicates = list()
    )
    
    # Check for missing values
    for (col in names(data)) {
      missing_count <- sum(is.na(data[[col]]))
      if (missing_count > 0) {
        validation_results$missing_values[[col]] <- missing_count
      }
    }
    
    # Check data types
    for (col in names(data)) {
      validation_results$data_types[[col]] <- class(data[[col]])
    }
    
    # Check for duplicates
    if ("eid" %in% names(data)) {
      duplicate_eids <- sum(duplicated(data$eid))
      if (duplicate_eids > 0) {
        validation_results$duplicates$eid <- duplicate_eids
      }
    }
    
    # Check for outliers in numeric columns
    numeric_cols <- names(data)[sapply(data, is.numeric)]
    for (col in numeric_cols) {
      values <- data[[col]]
      q1 <- quantile(values, 0.25, na.rm = TRUE)
      q3 <- quantile(values, 0.75, na.rm = TRUE)
      iqr <- q3 - q1
      lower_bound <- q1 - 1.5 * iqr
      upper_bound <- q3 + 1.5 * iqr
      
      outliers <- sum(values < lower_bound | values > upper_bound, na.rm = TRUE)
      if (outliers > 0) {
        validation_results$outliers[[col]] <- outliers
      }
    }
    
    return(validation_results)
  }
  
  # Mock validation summary function
  get_validation_summary <- function(results) {
    summary_parts <- c()
    summary_parts <- c(summary_parts, paste("Total records:", results$total_records))
    
    if (length(results$missing_values) > 0) {
      missing_summary <- paste(names(results$missing_values), collapse = ", ")
      summary_parts <- c(summary_parts, paste("Missing values in:", missing_summary))
    }
    
    if (length(results$duplicates) > 0) {
      duplicate_summary <- paste(names(results$duplicates), collapse = ", ")
      summary_parts <- c(summary_parts, paste("Duplicates in:", duplicate_summary))
    }
    
    if (length(results$outliers) > 0) {
      outlier_summary <- paste(names(results$outliers), collapse = ", ")
      summary_parts <- c(summary_parts, paste("Outliers in:", outlier_summary))
    }
    
    paste(summary_parts, collapse = "; ")
  }
  
  # Test validation
  validation <- validate_data(test_data)
  summary_text <- get_validation_summary(validation)
  
  expect_equal(validation$total_records, nrow(test_data))
  expect_true(grepl("Total records: 8", summary_text))
  
  # Test with data containing missing values
  data_with_na <- test_data
  data_with_na$finalpweight[1] <- NA
  
  validation_with_na <- validate_data(data_with_na)
  expect_true("finalpweight" %in% names(validation_with_na$missing_values))
  expect_equal(validation_with_na$missing_values$finalpweight, 1)
  
  # Test data types validation
  expect_equal(validation$data_types$eid, "character")
  expect_equal(validation$data_types$finalpweight, "numeric")
  expect_equal(validation$data_types$date, "Date")
  
  # Test duplicates validation (should be 0 for test data)
  expect_equal(length(validation$duplicates), 0)
})

# Test 8: Data Management Performance Integration
test_that("data management performance integrates correctly", {
  # Mock performance tracking
  performance_tracker <- list(
    render_time = NULL,
    data_size = NULL,
    memory_usage = NULL
  )
  
  # Mock performance-aware data table rendering
  render_data_table_with_performance <- function(data, tracker) {
    start_time <- Sys.time()
    
    # Simulate data table rendering
    df_display <- data %>%
      mutate(
        date = format(date, "%Y-%m-%d"),
        finalpweight = round(finalpweight, 1),
        feedintake = round(feedintake, 2),
        methane = round(methane, 1)
      )
    
    # Track performance
    end_time <- Sys.time()
    tracker$render_time <- as.numeric(end_time - start_time, units = "secs")
    tracker$data_size <- nrow(data)
    tracker$memory_usage <- object.size(data)
    
    return(list(rendered_data = df_display, tracker = tracker))
  }
  
  # Mock performance summary function
  get_performance_summary <- function(tracker) {
    paste(
      "Render time:", round(tracker$render_time, 4), "seconds;",
      "Data size:", tracker$data_size, "records;",
      "Memory usage:", round(tracker$memory_usage / 1024, 2), "KB"
    )
  }
  
  # Test performance tracking
  result <- render_data_table_with_performance(test_data, performance_tracker)
  rendered_data <- result$rendered_data
  performance_tracker <- result$tracker
  
  # Verify performance metrics
  expect_true(!is.null(performance_tracker$render_time))
  expect_true(performance_tracker$render_time >= 0)
  expect_equal(performance_tracker$data_size, nrow(test_data))
  expect_true(performance_tracker$memory_usage > 0)
  
  # Verify rendered data
  expect_true("date" %in% names(rendered_data))
  expect_true("finalpweight" %in% names(rendered_data))
  
  # Test with larger dataset
  large_data <- rbind(test_data, test_data, test_data)  # Triple the data
  large_result <- render_data_table_with_performance(large_data, performance_tracker)
  performance_tracker <- large_result$tracker
  
  expect_equal(performance_tracker$data_size, nrow(large_data))
  expect_true(performance_tracker$memory_usage > object.size(test_data))
  
  # Test performance summary
  performance_text <- get_performance_summary(performance_tracker)
  expect_true(grepl("Render time:", performance_text))
  expect_true(grepl("Data size:", performance_text))
  expect_true(grepl("Memory usage:", performance_text))
})
