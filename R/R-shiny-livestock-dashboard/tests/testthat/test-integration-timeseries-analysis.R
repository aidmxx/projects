# Integration Tests: Time Series Analysis Workflow
# Tests the complete workflow from time series configuration to analysis and visualization

library(testthat)
library(shiny)
library(dplyr)
library(plotly)
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
if (file.exists("src/timeseries_page.R")) {
  source("src/timeseries_page.R")
} else if (file.exists("../src/timeseries_page.R")) {
  source("../src/timeseries_page.R")
} else if (file.exists("../../src/timeseries_page.R")) {
  source("../../src/timeseries_page.R")
}

# Test 1: Complete Time Series Analysis Workflow
test_that("complete time series analysis workflow integrates correctly", {
  # Mock time series analysis function
  perform_timeseries_analysis <- function(data, measure, group_by_vars, aggregation_method, time_period) {
    if (nrow(data) == 0) {
      return(list(
        ts_data = data.frame(),
        summary_stats = data.frame(),
        trend_analysis = data.frame()
      ))
    }
    
    # Group by time period
    time_grouped <- switch(time_period,
      "daily" = data %>% mutate(time_group = date),
      "weekly" = data %>% mutate(time_group = floor_date(date, "week")),
      "monthly" = data %>% mutate(time_group = floor_date(date, "month")),
      "quarterly" = data %>% mutate(time_group = floor_date(date, "quarter"))
    )
    
    # Aggregate by time and grouping variables
    if (length(group_by_vars) > 0) {
      ts_data <- time_grouped %>%
        group_by(time_group, across(all_of(group_by_vars))) %>%
        summarise(
          mean_value = mean(.data[[measure]], na.rm = TRUE),
          median_value = median(.data[[measure]], na.rm = TRUE),
          count = n(),
          .groups = "drop"
        )
    } else {
      ts_data <- time_grouped %>%
        group_by(time_group) %>%
        summarise(
          mean_value = mean(.data[[measure]], na.rm = TRUE),
          median_value = median(.data[[measure]], na.rm = TRUE),
          count = n(),
          .groups = "drop"
        )
    }
    
    # Summary statistics
    summary_stats <- ts_data %>%
      summarise(
        total_points = n(),
        date_range = paste(min(time_group), "to", max(time_group)),
        mean_overall = mean(mean_value, na.rm = TRUE),
        trend_direction = ifelse(
          cor(as.numeric(time_group), mean_value, use = "complete.obs") > 0,
          "Increasing", "Decreasing"
        ),
        .groups = "drop"
      )
    
    # Trend analysis
    trend_analysis <- ts_data %>%
      arrange(time_group) %>%
      mutate(
        time_numeric = as.numeric(time_group),
        trend_line = predict(lm(mean_value ~ time_numeric, data = .))
      )
    
    return(list(
      ts_data = ts_data,
      summary_stats = summary_stats,
      trend_analysis = trend_analysis
    ))
  }
  
  # Test time series analysis
  ts_group_by <- c("sex")
  ts_aggregation <- "mean"
  ts_time_period <- "monthly"
  ts_measure <- "finalpweight"
  
  # Perform analysis
  analysis_result <- perform_timeseries_analysis(
    test_data,
    ts_measure,
    ts_group_by,
    ts_aggregation,
    ts_time_period
  )
  
  # Verify results
  expect_true(!is.null(analysis_result))
  expect_true("ts_data" %in% names(analysis_result))
  expect_true("summary_stats" %in% names(analysis_result))
  expect_true("trend_analysis" %in% names(analysis_result))
  
  # Check time series data
  ts_data <- analysis_result$ts_data
  expect_true("time_group" %in% names(ts_data))
  expect_true("mean_value" %in% names(ts_data))
  expect_true("count" %in% names(ts_data))
  
  # Check summary stats
  summary_stats <- analysis_result$summary_stats
  expect_true("total_points" %in% names(summary_stats))
  expect_true("date_range" %in% names(summary_stats))
  expect_true("trend_direction" %in% names(summary_stats))
  
  # Check trend analysis
  trend_analysis <- analysis_result$trend_analysis
  expect_true("trend_line" %in% names(trend_analysis))
})

# Test 2: Time Series Visualization Integration
test_that("time series visualization integrates correctly", {
  # Mock time series visualization
  create_timeseries_visualization <- function(ts_data, chart_type, group_by_vars) {
    if (nrow(ts_data) == 0) {
      return(plotly_empty())
    }
    
    switch(chart_type,
      "line" = {
        if (length(group_by_vars) > 0) {
          p <- plot_ly(ts_data, x = ~time_group, y = ~mean_value, 
                      color = ~.data[[group_by_vars[1]]], type = "scatter", mode = "lines+markers")
        } else {
          p <- plot_ly(ts_data, x = ~time_group, y = ~mean_value, 
                      type = "scatter", mode = "lines+markers")
        }
        p
      },
      "area" = {
        if (length(group_by_vars) > 0) {
          p <- plot_ly(ts_data, x = ~time_group, y = ~mean_value, 
                      color = ~.data[[group_by_vars[1]]], type = "scatter", mode = "lines", 
                      fill = "tonexty")
        } else {
          p <- plot_ly(ts_data, x = ~time_group, y = ~mean_value, 
                      type = "scatter", mode = "lines", fill = "tozeroy")
        }
        p
      },
      "bar" = {
        if (length(group_by_vars) > 0) {
          p <- plot_ly(ts_data, x = ~time_group, y = ~mean_value, 
                      color = ~.data[[group_by_vars[1]]], type = "bar")
        } else {
          p <- plot_ly(ts_data, x = ~time_group, y = ~mean_value, type = "bar")
        }
        p
      }
    )
  }
  
  # Mock time series data
  ts_data <- test_data %>%
    mutate(time_group = floor_date(date, "month")) %>%
    group_by(time_group, sex) %>%
    summarise(mean_value = mean(finalpweight, na.rm = TRUE), .groups = "drop")
  
  # Test line chart
  ts_chart_type <- "line"
  ts_group_by <- c("sex")
  
  line_chart <- create_timeseries_visualization(ts_data, ts_chart_type, ts_group_by)
  expect_true(inherits(line_chart, "plotly"))
  
  # Test area chart
  ts_chart_type <- "area"
  
  area_chart <- create_timeseries_visualization(ts_data, ts_chart_type, ts_group_by)
  expect_true(inherits(area_chart, "plotly"))
  
  # Test bar chart
  ts_chart_type <- "bar"
  
  bar_chart <- create_timeseries_visualization(ts_data, ts_chart_type, ts_group_by)
  expect_true(inherits(bar_chart, "plotly"))
  
  # Test with no grouping
  ts_group_by <- character(0)
  
  ts_data_no_group <- test_data %>%
    mutate(time_group = floor_date(date, "month")) %>%
    group_by(time_group) %>%
    summarise(mean_value = mean(finalpweight, na.rm = TRUE), .groups = "drop")
  
  no_group_chart <- create_timeseries_visualization(ts_data_no_group, "line", character(0))
  expect_true(inherits(no_group_chart, "plotly"))
})

# Test 3: Time Series Aggregation Integration
test_that("time series aggregation integrates correctly", {
  # Mock aggregation functions
  aggregate_timeseries_data <- function(data, measure, aggregation_method, time_period) {
    if (nrow(data) == 0) {
      return(data.frame())
    }
    
    # Group by time period
    time_grouped <- switch(time_period,
      "daily" = data %>% mutate(time_group = date),
      "weekly" = data %>% mutate(time_group = floor_date(date, "week")),
      "monthly" = data %>% mutate(time_group = floor_date(date, "month")),
      "quarterly" = data %>% mutate(time_group = floor_date(date, "quarter"))
    )
    
    # Apply aggregation method
    aggregated <- switch(aggregation_method,
      "mean" = time_grouped %>%
        group_by(time_group) %>%
        summarise(aggregated_value = mean(.data[[measure]], na.rm = TRUE), .groups = "drop"),
      "median" = time_grouped %>%
        group_by(time_group) %>%
        summarise(aggregated_value = median(.data[[measure]], na.rm = TRUE), .groups = "drop"),
      "sum" = time_grouped %>%
        group_by(time_group) %>%
        summarise(aggregated_value = sum(.data[[measure]], na.rm = TRUE), .groups = "drop"),
      "min" = time_grouped %>%
        group_by(time_group) %>%
        summarise(aggregated_value = min(.data[[measure]], na.rm = TRUE), .groups = "drop"),
      "max" = time_grouped %>%
        group_by(time_group) %>%
        summarise(aggregated_value = max(.data[[measure]], na.rm = TRUE), .groups = "drop")
    )
    
    return(aggregated)
  }
  
  # Test different aggregation methods
  aggregation_methods <- c("mean", "median", "sum", "min", "max")
  
  for (method in aggregation_methods) {
    ts_aggregation <- method
    ts_time_period <- "monthly"
    
    aggregated_data <- aggregate_timeseries_data(
      test_data,
      "finalpweight",
      ts_aggregation,
      ts_time_period
    )
    
    expect_true("time_group" %in% names(aggregated_data))
    expect_true("aggregated_value" %in% names(aggregated_data))
    expect_true(nrow(aggregated_data) > 0)
  }
  
  # Test different time periods
  time_periods <- c("daily", "weekly", "monthly", "quarterly")
  
  for (period in time_periods) {
    ts_time_period <- period
    
    aggregated_data <- aggregate_timeseries_data(
      test_data,
      "finalpweight",
      "mean",
      ts_time_period
    )
    
    expect_true("time_group" %in% names(aggregated_data))
    expect_true("aggregated_value" %in% names(aggregated_data))
  }
})

# Test 4: Time Series Trend Analysis Integration
test_that("time series trend analysis integrates correctly", {
      # Mock trend analysis
      perform_trend_analysis <- function(ts_data, trend_method) {
        if (nrow(ts_data) < 2) {
          return(list(
            trend_result = NULL,
            trend_summary = "Insufficient data for trend analysis"
          ))
        }
        
        # Convert time to numeric for analysis
        ts_data$time_numeric <- as.numeric(ts_data$time_group)
        
        switch(trend_method,
          "linear" = {
            model <- lm(aggregated_value ~ time_numeric, data = ts_data)
            trend_result <- list(
              slope = coef(model)[2],
              r_squared = summary(model)$r.squared,
              p_value = summary(model)$coefficients[2, 4],
              trend_direction = ifelse(coef(model)[2] > 0, "Increasing", "Decreasing")
            )
          },
          "polynomial" = {
            model <- lm(aggregated_value ~ poly(time_numeric, 2), data = ts_data)
            trend_result <- list(
              r_squared = summary(model)$r.squared,
              p_value = anova(model)$`Pr(>F)`[1],
              trend_type = "Polynomial"
            )
          },
          "exponential" = {
            # Simple exponential trend (log transformation)
            ts_data$log_value <- log(ts_data$aggregated_value + 1)  # Add 1 to avoid log(0)
            model <- lm(log_value ~ time_numeric, data = ts_data)
            trend_result <- list(
              growth_rate = coef(model)[2],
              r_squared = summary(model)$r.squared,
              p_value = summary(model)$coefficients[2, 4],
              trend_type = "Exponential"
            )
          }
        )
        
        trend_summary <- paste0(
          "Trend: ", trend_result$trend_direction %||% trend_result$trend_type,
          ", R² = ", round(trend_result$r_squared, 3),
          ", p-value = ", round(trend_result$p_value, 4)
        )
        
        return(list(
          trend_result = trend_result,
          trend_summary = trend_summary
        ))
      }
      
      # Mock time series data
      ts_data <- test_data %>%
        mutate(time_group = floor_date(date, "month")) %>%
        group_by(time_group) %>%
        summarise(aggregated_value = mean(finalpweight, na.rm = TRUE), .groups = "drop")
      
      # Test linear trend
      ts_trend_method <- "linear"
      
      linear_trend <- perform_trend_analysis(ts_data, ts_trend_method)
      expect_true(!is.null(linear_trend$trend_result))
      expect_true("slope" %in% names(linear_trend$trend_result))
      expect_true("r_squared" %in% names(linear_trend$trend_result))
      expect_true(grepl("Trend:", linear_trend$trend_summary))
      
      # Test polynomial trend
      ts_trend_method <- "polynomial"
      
      poly_trend <- perform_trend_analysis(ts_data, ts_trend_method)
      expect_true(!is.null(poly_trend$trend_result))
      expect_true("trend_type" %in% names(poly_trend$trend_result))
      
      # Test exponential trend
      ts_trend_method <- "exponential"
      
      exp_trend <- perform_trend_analysis(ts_data, ts_trend_method)
      expect_true(!is.null(exp_trend$trend_result))
      expect_true("growth_rate" %in% names(exp_trend$trend_result))
      
      # Test with insufficient data
      insufficient_data <- ts_data[1, ]  # Only one data point
      insufficient_trend <- perform_trend_analysis(insufficient_data, "linear")
      expect_true(is.null(insufficient_trend$trend_result))
      expect_equal(insufficient_trend$trend_summary, "Insufficient data for trend analysis")
})

# Test 5: Time Series Export Integration
test_that("time series export integrates correctly", {
      # Mock export functions
      export_timeseries_data <- function(ts_data, format, filename) {
        switch(format,
          "CSV" = {
            filename <- paste0(filename, "_timeseries_", format(Sys.Date(), "%Y%m%d"), ".csv")
            return(paste("Time series data exported as CSV:", filename))
          },
          "Excel" = {
            filename <- paste0(filename, "_timeseries_", format(Sys.Date(), "%Y%m%d"), ".xlsx")
            return(paste("Time series data exported as Excel:", filename))
          }
        )
      }
      
      export_timeseries_chart <- function(chart_data, format, filename) {
        switch(format,
          "PNG" = {
            filename <- paste0(filename, "_timeseries_chart_", format(Sys.Date(), "%Y%m%d"), ".png")
            return(paste("Time series chart exported as PNG:", filename))
          },
          "PDF" = {
            filename <- paste0(filename, "_timeseries_chart_", format(Sys.Date(), "%Y%m%d"), ".pdf")
            return(paste("Time series chart exported as PDF:", filename))
          },
          "SVG" = {
            filename <- paste0(filename, "_timeseries_chart_", format(Sys.Date(), "%Y%m%d"), ".svg")
            return(paste("Time series chart exported as SVG:", filename))
          }
        )
      }
      
      # Mock time series data
      ts_data <- test_data %>%
        mutate(time_group = floor_date(date, "month")) %>%
        group_by(time_group) %>%
        summarise(aggregated_value = mean(finalpweight, na.rm = TRUE), .groups = "drop")
      
      # Test data export
      
      ts_export_format <- "CSV"
      ts_export_filename <- "timeseries_data"
      data_export_result <- export_timeseries_data(ts_data, ts_export_format, ts_export_filename)
      expect_true(grepl("Time series data exported as CSV", data_export_result))
      expect_true(grepl("timeseries_data_timeseries_", data_export_result))
      expect_true(grepl(".csv", data_export_result))
      
      # Test chart export
      
      ts_chart_export_format <- "PNG"
      ts_chart_export_filename <- "timeseries_chart"
      chart_export_result <- export_timeseries_chart(ts_data, ts_chart_export_format, ts_chart_export_filename)
      expect_true(grepl("Time series chart exported as PNG", chart_export_result))
      expect_true(grepl("timeseries_chart_timeseries_chart_", chart_export_result))
      expect_true(grepl(".png", chart_export_result))
      
      # Test Excel export
      
      ts_export_format <- "Excel"
      ts_export_filename <- "timeseries_analysis"
      excel_export_result <- export_timeseries_data(ts_data, ts_export_format, ts_export_filename)
      expect_true(grepl("Time series data exported as Excel", excel_export_result))
      expect_true(grepl(".xlsx", excel_export_result))
      
      # Test SVG export
      
      ts_chart_export_format <- "SVG"
      ts_chart_export_filename <- "timeseries_chart"
      svg_export_result <- export_timeseries_chart(ts_data, ts_chart_export_format, ts_chart_export_filename)
      expect_true(grepl("Time series chart exported as SVG", svg_export_result))
      expect_true(grepl(".svg", svg_export_result))
})

# Test 6: Time Series Forecasting Integration
test_that("time series forecasting integrates correctly", {
      # Mock forecasting function
      perform_forecasting <- function(ts_data, forecast_periods, forecast_method) {
        if (nrow(ts_data) < 3) {
          return(list(
            forecast_data = data.frame(),
            forecast_summary = "Insufficient data for forecasting"
          ))
        }
        
        # Simple linear forecasting
        ts_data$time_numeric <- as.numeric(ts_data$time_group)
        model <- lm(aggregated_value ~ time_numeric, data = ts_data)
        
        # Generate future dates
        last_date <- max(ts_data$time_group)
        future_dates <- seq(last_date + days(1), by = "month", length.out = forecast_periods)
        future_numeric <- as.numeric(future_dates)
        
        # Generate forecasts
        forecast_values <- predict(model, newdata = data.frame(time_numeric = future_numeric))
        
        forecast_data <- data.frame(
          time_group = future_dates,
          aggregated_value = forecast_values,
          forecast_type = "forecast",
          confidence_lower = forecast_values * 0.9,  # Simple confidence interval
          confidence_upper = forecast_values * 1.1
        )
        
        forecast_summary <- paste0(
          "Forecast for ", forecast_periods, " periods ahead using ", forecast_method,
          ". Expected trend: ", ifelse(coef(model)[2] > 0, "Increasing", "Decreasing")
        )
        
        return(list(
          forecast_data = forecast_data,
          forecast_summary = forecast_summary
        ))
      }
      
      # Mock time series data
      ts_data <- test_data %>%
        mutate(time_group = floor_date(date, "month")) %>%
        group_by(time_group) %>%
        summarise(aggregated_value = mean(finalpweight, na.rm = TRUE), .groups = "drop")
      
      # Test forecasting
      ts_forecast_periods <- 3
      ts_forecast_method <- "linear"
      
      forecast_result <- perform_forecasting(
        ts_data,
        ts_forecast_periods,
        ts_forecast_method
      )
      
      # Verify forecast results
      expect_true(!is.null(forecast_result))
      expect_true("forecast_data" %in% names(forecast_result))
      expect_true("forecast_summary" %in% names(forecast_result))
      
      forecast_data <- forecast_result$forecast_data
      expect_true("time_group" %in% names(forecast_data))
      expect_true("aggregated_value" %in% names(forecast_data))
      expect_true("forecast_type" %in% names(forecast_data))
      expect_equal(nrow(forecast_data), 3)
      
      # Test with insufficient data
      insufficient_data <- ts_data[1:2, ]  # Only two data points
      insufficient_forecast <- perform_forecasting(insufficient_data, 3, "linear")
      expect_equal(nrow(insufficient_forecast$forecast_data), 0)
      expect_equal(insufficient_forecast$forecast_summary, "Insufficient data for forecasting")
})

# Test 7: Time Series Performance Integration
test_that("time series performance integrates correctly", {
      # Mock performance tracking
      performance_tracker <- list(
        analysis_time = NULL,
        data_size = NULL,
        memory_usage = NULL
      )
      
      # Mock performance-aware analysis
      perform_timeseries_analysis_with_performance <- function(data, measure, time_period, tracker) {
        start_time <- Sys.time()
        
        # Perform analysis
        time_grouped <- switch(time_period,
          "daily" = data %>% mutate(time_group = date),
          "weekly" = data %>% mutate(time_group = floor_date(date, "week")),
          "monthly" = data %>% mutate(time_group = floor_date(date, "month")),
          "quarterly" = data %>% mutate(time_group = floor_date(date, "quarter"))
        )
        
        ts_data <- time_grouped %>%
          group_by(time_group) %>%
          summarise(aggregated_value = mean(.data[[measure]], na.rm = TRUE), .groups = "drop")
        
        # Track performance
        end_time <- Sys.time()
        tracker$analysis_time <- as.numeric(end_time - start_time, units = "secs")
        tracker$data_size <- nrow(data)
        tracker$memory_usage <- object.size(data)
        
        return(list(ts_data = ts_data, tracker = tracker))
      }
      
      # Test performance tracking
      
      ts_time_period <- "monthly"
      result <- perform_timeseries_analysis_with_performance(test_data, "finalpweight", ts_time_period, performance_tracker)
      performance_tracker <- result$tracker
      
      # Verify performance metrics
      expect_true(!is.null(performance_tracker$analysis_time))
      expect_true(performance_tracker$analysis_time >= 0)
      expect_equal(performance_tracker$data_size, nrow(test_data))
      expect_true(performance_tracker$memory_usage > 0)
      
      # Verify analysis result
      expect_true("time_group" %in% names(result$ts_data))
      expect_true("aggregated_value" %in% names(result$ts_data))
      
      # Test with different time periods
      time_periods <- c("daily", "weekly", "monthly", "quarterly")
      
      for (period in time_periods) {
        ts_time_period <- period
        
        period_result <- perform_timeseries_analysis_with_performance(test_data, "finalpweight", period, performance_tracker)
        expect_true("time_group" %in% names(period_result$ts_data))
        expect_true("aggregated_value" %in% names(period_result$ts_data))
      }
})

# Test 8: Time Series Error Handling Integration
test_that("time series error handling integrates correctly", {
      # Mock error handling
      handle_timeseries_error <- function(error) {
        error_message <- switch(
          class(error)[1],
          "simpleError" = error$message,
          "character" = error,
          "Unknown error occurred"
        )
        
        cat("Time Series Error:", error_message, "\n")
        
        return(paste("❌ Time series analysis failed:", error_message))
      }
      
      # Mock error-prone analysis
      perform_timeseries_analysis_with_errors <- function(data, measure, time_period) {
        tryCatch({
          if (nrow(data) == 0) {
            stop("No data available for analysis")
          }
          
          if (!measure %in% names(data)) {
            stop(paste("Measure", measure, "not found in data"))
          }
          
          if (!"date" %in% names(data)) {
            stop("Date column not found in data")
          }
          
          if (all(is.na(data[[measure]]))) {
            stop("All values for the selected measure are missing")
          }
          
          # Perform analysis
          time_grouped <- switch(time_period,
            "daily" = data %>% mutate(time_group = date),
            "weekly" = data %>% mutate(time_group = floor_date(date, "week")),
            "monthly" = data %>% mutate(time_group = floor_date(date, "month")),
            "quarterly" = data %>% mutate(time_group = floor_date(date, "quarter"))
          )
          
          ts_data <- time_grouped %>%
            group_by(time_group) %>%
            summarise(aggregated_value = mean(.data[[measure]], na.rm = TRUE), .groups = "drop")
          
          return(ts_data)
        }, error = function(e) {
          return(handle_timeseries_error(e))
        })
      }
      
      # Test with valid data
      valid_result <- perform_timeseries_analysis_with_errors(test_data, "finalpweight", "monthly")
      expect_true(is.data.frame(valid_result))
      expect_true("time_group" %in% names(valid_result))
      
      # Test with empty data
      empty_result <- perform_timeseries_analysis_with_errors(data.frame(), "finalpweight", "monthly")
      expect_true(grepl("❌ Time series analysis failed", empty_result))
      expect_true(grepl("No data available", empty_result))
      
      # Test with invalid measure
      invalid_measure_result <- perform_timeseries_analysis_with_errors(test_data, "invalid_measure", "monthly")
      expect_true(grepl("❌ Time series analysis failed", invalid_measure_result))
      expect_true(grepl("Measure invalid_measure not found", invalid_measure_result))
      
      # Test with missing date column
      no_date_data <- test_data %>% select(-date)
      no_date_result <- perform_timeseries_analysis_with_errors(no_date_data, "finalpweight", "monthly")
      expect_true(grepl("❌ Time series analysis failed", no_date_result))
      expect_true(grepl("Date column not found", no_date_result))
      
      # Test with all NA values
      na_data <- test_data
      na_data$finalpweight <- NA
      na_result <- perform_timeseries_analysis_with_errors(na_data, "finalpweight", "monthly")
      expect_true(grepl("❌ Time series analysis failed", na_result))
      expect_true(grepl("All values for the selected measure are missing", na_result))
})
