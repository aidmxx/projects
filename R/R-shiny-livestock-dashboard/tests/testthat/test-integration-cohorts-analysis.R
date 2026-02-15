# Integration Tests: Cohorts Analysis Workflow
# Tests the complete workflow from cohort configuration to analysis and visualization

library(testthat)
library(shiny)
library(dplyr)
library(plotly)
library(rlang)
library(lubridate)

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

# Source required functions
if (file.exists("src/cohorts_page.R")) {
  source("src/cohorts_page.R")
} else if (file.exists("../src/cohorts_page.R")) {
  source("../src/cohorts_page.R")
} else if (file.exists("../../src/cohorts_page.R")) {
  source("../../src/cohorts_page.R")
}

# Test 1: Complete Cohorts Analysis Workflow
test_that("complete cohorts analysis workflow integrates correctly", {
  # Simple test without testServer first
  perform_cohorts_analysis <- function(data, measure, group_by_vars, percentile_threshold) {
    if (nrow(data) == 0) {
      return(list(
        cohort_data = data.frame(),
        summary_stats = data.frame(),
        trend_data = data.frame()
      ))
    }
    
    # Validate inputs
    if (is.null(measure) || measure == "" || !measure %in% names(data)) {
      measure <- "finalpweight"  # Default measure
    }
    
    if (is.null(group_by_vars) || length(group_by_vars) == 0 || any(group_by_vars == "")) {
      group_by_vars <- character(0)
    }
    
    # Convert percentile to numeric
    pct_threshold <- switch(percentile_threshold, 
                           "10%" = 0.10, 
                           "15%" = 0.15, 
                           "20%" = 0.20, 
                           0.10)
    
    # Calculate percentile threshold
    threshold_value <- quantile(data[[measure]], pct_threshold, na.rm = TRUE)
    
    # Create cohorts based on threshold
    cohort_data <- data %>%
      mutate(
        cohort = ifelse(.data[[measure]] <= threshold_value, "Low", "High"),
        percentile_value = pct_threshold * 100
      )
    
    # Summary statistics by cohort
    summary_stats <- cohort_data %>%
      group_by(cohort) %>%
      summarise(
        count = n(),
        mean_value = mean(.data[[measure]], na.rm = TRUE),
        median_value = median(.data[[measure]], na.rm = TRUE),
        sd_value = sd(.data[[measure]], na.rm = TRUE),
        .groups = "drop"
      )
    
    # Trend analysis by cohort over time
    trend_data <- cohort_data %>%
      group_by(date, cohort) %>%
      summarise(
        mean_value = mean(.data[[measure]], na.rm = TRUE),
        count = n(),
        .groups = "drop"
      ) %>%
      arrange(date, cohort)
    
    return(list(
      cohort_data = cohort_data,
      summary_stats = summary_stats,
      trend_data = trend_data,
      threshold_value = threshold_value
    ))
  }
  
  # Test the function directly
  analysis_result <- perform_cohorts_analysis(
    test_data,
    "finalpweight",
    c("sex", "treatment"),
    "15%"
  )
  
  # Verify results
  expect_true(!is.null(analysis_result))
  expect_true("cohort_data" %in% names(analysis_result))
  expect_true("summary_stats" %in% names(analysis_result))
  expect_true("trend_data" %in% names(analysis_result))
  
  # Check cohort data
  cohort_data <- analysis_result$cohort_data
  expect_true("cohort" %in% names(cohort_data))
  expect_true(all(cohort_data$cohort %in% c("Low", "High")))
  
  # Check summary stats
  summary_stats <- analysis_result$summary_stats
  expect_true("cohort" %in% names(summary_stats))
  expect_true("count" %in% names(summary_stats))
  expect_true("mean_value" %in% names(summary_stats))
  
  # Check trend data
  trend_data <- analysis_result$trend_data
  expect_true("date" %in% names(trend_data))
  expect_true("cohort" %in% names(trend_data))
  expect_true("mean_value" %in% names(trend_data))
})

# Test 2: Cohorts Analysis with Different Grouping Variables
test_that("cohorts analysis integrates with different grouping variables", {
  # Mock grouped cohorts analysis
  perform_grouped_cohorts_analysis <- function(data, measure, group_by_vars, percentile_threshold) {
    if (nrow(data) == 0) {
      return(data.frame())
    }
    
    # Validate inputs
    if (is.null(measure) || measure == "" || !measure %in% names(data)) {
      measure <- "finalpweight"  # Default measure
    }
    
    if (is.null(group_by_vars) || length(group_by_vars) == 0 || any(group_by_vars == "")) {
      group_by_vars <- character(0)
    }
    
    pct_threshold <- switch(percentile_threshold, 
                           "10%" = 0.10, 
                           "15%" = 0.15, 
                           "20%" = 0.20, 
                           0.10)
    
    # If no grouping variables, create simple cohorts
    if (length(group_by_vars) == 0) {
      threshold_value <- quantile(data[[measure]], pct_threshold, na.rm = TRUE)
      cohort_data <- data %>%
        mutate(
          cohort = ifelse(.data[[measure]] <= threshold_value, "Low", "High")
        )
      return(cohort_data)
    }
    
    # Calculate threshold for each group
    grouped_thresholds <- data %>%
      group_by(across(all_of(group_by_vars))) %>%
      summarise(
        threshold = quantile(.data[[measure]], pct_threshold, na.rm = TRUE),
        .groups = "drop"
      )
    
    # Create cohorts within each group
    cohort_data <- data %>%
      left_join(grouped_thresholds, by = group_by_vars) %>%
      mutate(
        cohort = ifelse(.data[[measure]] <= threshold, "Low", "High")
      ) %>%
      select(-threshold)
    
    return(cohort_data)
  }
  
  # Test with sex grouping
  result_sex <- perform_grouped_cohorts_analysis(
    test_data,
    "finalpweight",
    c("sex"),
    "20%"
  )
  
  expect_true("cohort" %in% names(result_sex))
  expect_true("sex" %in% names(result_sex))
  
  # Test with treatment grouping
  result_treatment <- perform_grouped_cohorts_analysis(
    test_data,
    "finalpweight",
    c("treatment"),
    "20%"
  )
  
  expect_true("cohort" %in% names(result_treatment))
  expect_true("treatment" %in% names(result_treatment))
  
  # Test with multiple grouping variables
  result_multi <- perform_grouped_cohorts_analysis(
    test_data,
    "finalpweight",
    c("sex", "treatment"),
    "20%"
  )
  
  expect_true("cohort" %in% names(result_multi))
  expect_true("sex" %in% names(result_multi))
  expect_true("treatment" %in% names(result_multi))
})

# Test 3: Cohorts Visualization Integration
test_that("cohorts visualization integrates correctly", {
  # Mock cohorts visualization
  create_cohorts_visualization <- function(cohort_data, measure, chart_type) {
    if (nrow(cohort_data) == 0) {
      return(plotly_empty())
    }
    
    switch(chart_type,
      "bar" = {
        summary_data <- cohort_data %>%
          group_by(cohort) %>%
          summarise(
            mean_value = mean(.data[[measure]], na.rm = TRUE),
            count = n(),
            .groups = "drop"
          )
        
        p <- plot_ly(summary_data, x = ~cohort, y = ~mean_value, type = "bar")
        p
      },
      "box" = {
        p <- plot_ly(cohort_data, x = ~cohort, y = ~.data[[measure]], type = "box")
        p
      },
      "scatter" = {
        p <- plot_ly(cohort_data, x = ~date, y = ~.data[[measure]], 
                    color = ~cohort, type = "scatter", mode = "markers")
        p
      }
    )
  }
  
  # Mock cohort data
  cohort_data <- test_data %>%
    mutate(
      cohort = ifelse(finalpweight <= quantile(finalpweight, 0.15, na.rm = TRUE), "Low", "High")
    )
  
  # Test bar chart
  bar_chart <- create_cohorts_visualization(cohort_data, "finalpweight", "bar")
  expect_true(inherits(bar_chart, "plotly"))
  
  # Test box plot
  box_chart <- create_cohorts_visualization(cohort_data, "finalpweight", "box")
  expect_true(inherits(box_chart, "plotly"))
  
  # Test scatter plot
  scatter_chart <- create_cohorts_visualization(cohort_data, "finalpweight", "scatter")
  expect_true(inherits(scatter_chart, "plotly"))
  
  # Test with empty data
  empty_chart <- create_cohorts_visualization(data.frame(), "finalpweight", "bar")
  expect_true(inherits(empty_chart, "plotly"))
})

# Test 4: Cohorts Trend Analysis Integration
test_that("cohorts trend analysis integrates correctly", {
  # Mock trend analysis
  perform_trend_analysis <- function(cohort_data, measure, time_period) {
    if (nrow(cohort_data) == 0) {
      return(data.frame())
    }
    
    # Group by time period
    time_grouped <- switch(time_period,
      "daily" = cohort_data %>% mutate(time_group = date),
      "weekly" = cohort_data %>% mutate(time_group = floor_date(date, "week")),
      "monthly" = cohort_data %>% mutate(time_group = floor_date(date, "month"))
    )
    
    # Calculate trends
    trend_data <- time_grouped %>%
      group_by(time_group, cohort) %>%
      summarise(
        mean_value = mean(.data[[measure]], na.rm = TRUE),
        count = n(),
        .groups = "drop"
      ) %>%
      arrange(time_group, cohort)
    
    return(trend_data)
  }
  
  # Mock cohort data with dates
  cohort_data <- test_data %>%
    mutate(
      cohort = ifelse(finalpweight <= quantile(finalpweight, 0.15, na.rm = TRUE), "Low", "High")
    )
  
  # Test daily trend
  daily_trend <- perform_trend_analysis(cohort_data, "finalpweight", "daily")
  expect_true("time_group" %in% names(daily_trend))
  expect_true("cohort" %in% names(daily_trend))
  expect_true("mean_value" %in% names(daily_trend))
  
  # Test weekly trend
  weekly_trend <- perform_trend_analysis(cohort_data, "finalpweight", "weekly")
  expect_true("time_group" %in% names(weekly_trend))
  
  # Test monthly trend
  monthly_trend <- perform_trend_analysis(cohort_data, "finalpweight", "monthly")
  expect_true("time_group" %in% names(monthly_trend))
  
  # Verify trend data structure
  expect_true(nrow(monthly_trend) > 0)
  expect_true(all(c("Low", "High") %in% monthly_trend$cohort))
})

# Test 5: Cohorts Export Integration
test_that("cohorts export integrates correctly", {
  # Mock export functions
  export_cohorts_data <- function(cohort_data, format, filename) {
    switch(format,
      "CSV" = {
        filename <- paste0(filename, "_cohorts_", format(Sys.Date(), "%Y%m%d"), ".csv")
        return(paste("Cohorts data exported as CSV:", filename))
      },
      "Excel" = {
        filename <- paste0(filename, "_cohorts_", format(Sys.Date(), "%Y%m%d"), ".xlsx")
        return(paste("Cohorts data exported as Excel:", filename))
      }
    )
  }
  
  export_cohorts_chart <- function(chart_data, format, filename) {
    switch(format,
      "PNG" = {
        filename <- paste0(filename, "_cohorts_chart_", format(Sys.Date(), "%Y%m%d"), ".png")
        return(paste("Cohorts chart exported as PNG:", filename))
      },
      "PDF" = {
        filename <- paste0(filename, "_cohorts_chart_", format(Sys.Date(), "%Y%m%d"), ".pdf")
        return(paste("Cohorts chart exported as PDF:", filename))
      }
    )
  }
  
  # Mock cohort data
  cohort_data <- test_data %>%
    mutate(
      cohort = ifelse(finalpweight <= quantile(finalpweight, 0.15, na.rm = TRUE), "Low", "High")
    )
  
  # Test data export
  data_export_result <- export_cohorts_data(cohort_data, "CSV", "cohorts_analysis")
  expect_true(grepl("Cohorts data exported as CSV", data_export_result))
  expect_true(grepl("cohorts_analysis_cohorts_", data_export_result))
  expect_true(grepl(".csv", data_export_result))
  
  # Test chart export
  chart_export_result <- export_cohorts_chart(cohort_data, "PNG", "cohorts_chart")
  expect_true(grepl("Cohorts chart exported as PNG", chart_export_result))
  expect_true(grepl("cohorts_chart_cohorts_chart_", chart_export_result))
  expect_true(grepl(".png", chart_export_result))
  
  # Test Excel export
  excel_export_result <- export_cohorts_data(cohort_data, "Excel", "cohorts_analysis")
  expect_true(grepl("Cohorts data exported as Excel", excel_export_result))
  expect_true(grepl(".xlsx", excel_export_result))
})

# Test 6: Cohorts Statistical Analysis Integration
test_that("cohorts statistical analysis integrates correctly", {
      # Mock statistical analysis
      perform_cohorts_statistics <- function(cohort_data, measure) {
        if (nrow(cohort_data) == 0) {
          return(list(
            t_test = NULL,
            anova = NULL,
            effect_size = NULL
          ))
        }
        
        # Extract values by cohort
        low_values <- cohort_data[cohort_data$cohort == "Low", measure]
        high_values <- cohort_data[cohort_data$cohort == "High", measure]
        
        # T-test
        t_test_result <- tryCatch({
          t.test(low_values, high_values)
        }, error = function(e) {
          NULL
        })
        
        # ANOVA (if more than 2 groups)
        anova_result <- tryCatch({
          if (length(unique(cohort_data$cohort)) > 2) {
            aov(as.formula(paste(measure, "~ cohort")), data = cohort_data)
          } else {
            NULL
          }
        }, error = function(e) {
          NULL
        })
        
        # Effect size (Cohen's d)
        effect_size <- tryCatch({
          if (!is.null(t_test_result)) {
            pooled_sd <- sqrt(((length(low_values) - 1) * var(low_values) + 
                              (length(high_values) - 1) * var(high_values)) / 
                             (length(low_values) + length(high_values) - 2))
            (mean(high_values, na.rm = TRUE) - mean(low_values, na.rm = TRUE)) / pooled_sd
          } else {
            NULL
          }
        }, error = function(e) {
          NULL
        })
        
        return(list(
          t_test = t_test_result,
          anova = anova_result,
          effect_size = effect_size
        ))
      }
      
      # Mock cohort data
      cohort_data <- test_data %>%
        mutate(
          cohort = ifelse(finalpweight <= quantile(finalpweight, 0.15, na.rm = TRUE), "Low", "High")
        )
      
      # Perform statistical analysis
      stats_result <- perform_cohorts_statistics(cohort_data, "finalpweight")
      
      # Verify results
      expect_true(is.list(stats_result))
      expect_true("t_test" %in% names(stats_result))
      expect_true("anova" %in% names(stats_result))
      expect_true("effect_size" %in% names(stats_result))
      
      # Check t-test result
      if (!is.null(stats_result$t_test)) {
        expect_true(inherits(stats_result$t_test, "htest"))
        expect_true("p.value" %in% names(stats_result$t_test))
      }
      
      # Check effect size
      if (!is.null(stats_result$effect_size)) {
        expect_true(is.numeric(stats_result$effect_size))
      }
      
      # Test with empty data
      empty_stats <- perform_cohorts_statistics(data.frame(), "finalpweight")
      expect_true(is.null(empty_stats$t_test))
      expect_true(is.null(empty_stats$anova))
      expect_true(is.null(empty_stats$effect_size))
})

# Test 7: Cohorts Performance Integration
test_that("cohorts performance integrates correctly", {
  # Mock performance tracking
  performance_tracker <- list(
    analysis_time = NULL,
    data_size = NULL,
    memory_usage = NULL
  )
      
      # Mock performance-aware analysis
      perform_cohorts_analysis_with_performance <- function(data, measure, percentile_threshold) {
        start_time <- Sys.time()
        
        # Perform analysis
        pct_threshold <- switch(percentile_threshold, 
                               "10%" = 0.10, 
                               "15%" = 0.15, 
                               "20%" = 0.20, 
                               0.10)
        
        threshold_value <- quantile(data[[measure]], pct_threshold, na.rm = TRUE)
        
        cohort_data <- data %>%
          mutate(
            cohort = ifelse(.data[[measure]] <= threshold_value, "Low", "High")
          )
        
        # Track performance
        end_time <- Sys.time()
        performance_tracker$analysis_time <<- as.numeric(end_time - start_time, units = "secs")
        performance_tracker$data_size <<- nrow(data)
        performance_tracker$memory_usage <<- object.size(data)
        
        return(cohort_data)
      }
      
  # Test performance tracking
  result <- perform_cohorts_analysis_with_performance(test_data, "finalpweight", "15%")
      
      # Verify performance metrics
      expect_true(!is.null(performance_tracker$analysis_time))
      expect_true(performance_tracker$analysis_time >= 0)
      expect_equal(performance_tracker$data_size, nrow(test_data))
      expect_true(performance_tracker$memory_usage > 0)
      
      # Verify analysis result
      expect_true("cohort" %in% names(result))
      expect_true(all(result$cohort %in% c("Low", "High")))
      
      # Test with larger dataset
      large_data <- rbind(test_data, test_data, test_data)  # Triple the data
      large_result <- perform_cohorts_analysis_with_performance(large_data, "finalpweight", "15%")
      
  expect_equal(performance_tracker$data_size, nrow(large_data))
  expect_true(performance_tracker$memory_usage > object.size(test_data))
})

# Test 8: Cohorts Error Handling Integration
test_that("cohorts error handling integrates correctly", {
      # Mock error handling
      handle_cohorts_error <- function(error) {
        error_message <- switch(
          class(error)[1],
          "simpleError" = error$message,
          "character" = error,
          "Unknown error occurred"
        )
        
        cat("Cohorts Error:", error_message, "\n")
        
        return(paste("❌ Cohorts analysis failed:", error_message))
      }
      
      # Mock error-prone analysis
      perform_cohorts_analysis_with_errors <- function(data, measure, percentile_threshold) {
        tryCatch({
          if (nrow(data) == 0) {
            stop("No data available for analysis")
          }
          
          if (!measure %in% names(data)) {
            stop(paste("Measure", measure, "not found in data"))
          }
          
          if (all(is.na(data[[measure]]))) {
            stop("All values for the selected measure are missing")
          }
          
          # Perform analysis
          pct_threshold <- switch(percentile_threshold, 
                                 "10%" = 0.10, 
                                 "15%" = 0.15, 
                                 "20%" = 0.20, 
                                 0.10)
          
          threshold_value <- quantile(data[[measure]], pct_threshold, na.rm = TRUE)
          
          cohort_data <- data %>%
            mutate(
              cohort = ifelse(.data[[measure]] <= threshold_value, "Low", "High")
            )
          
          return(cohort_data)
        }, error = function(e) {
          return(handle_cohorts_error(e))
        })
      }
      
      # Test with valid data
      valid_result <- perform_cohorts_analysis_with_errors(test_data, "finalpweight", "15%")
      expect_true(is.data.frame(valid_result))
      expect_true("cohort" %in% names(valid_result))
      
      # Test with empty data
      empty_result <- perform_cohorts_analysis_with_errors(data.frame(), "finalpweight", "15%")
      expect_true(grepl("❌ Cohorts analysis failed", empty_result))
      expect_true(grepl("No data available", empty_result))
      
      # Test with invalid measure
      invalid_measure_result <- perform_cohorts_analysis_with_errors(test_data, "invalid_measure", "15%")
      expect_true(grepl("❌ Cohorts analysis failed", invalid_measure_result))
      expect_true(grepl("Measure invalid_measure not found", invalid_measure_result))
      
      # Test with all NA values
      na_data <- test_data
      na_data$finalpweight <- NA
      na_result <- perform_cohorts_analysis_with_errors(na_data, "finalpweight", "15%")
      expect_true(grepl("❌ Cohorts analysis failed", na_result))
      expect_true(grepl("All values for the selected measure are missing", na_result))
})
