# Integration Tests: Complete User Workflows
# Tests end-to-end user journeys across multiple functionalities

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

# Test 1: Complete Data Analysis Workflow
test_that("complete data analysis workflow integrates correctly", {
  # Mock complete workflow: Filter -> Analyze -> Visualize -> Export
  
  # Step 1: Data Filtering
  filter_data <- function(data, year_filter = NULL, sex_filter = NULL, breed_filter = NULL) {
    df <- data
    
    # Apply filters
    if (!is.null(year_filter) && year_filter != "" && !is.na(year_filter)) {
      df <- df %>% filter(year(date) == year_filter)
    }
    if (!is.null(sex_filter) && length(sex_filter) > 0 && !"Overall" %in% sex_filter && all(sex_filter != "")) {
      df <- df %>% filter(sex %in% sex_filter)
    }
    if (!is.null(breed_filter) && length(breed_filter) > 0 && !"Overall" %in% breed_filter && all(breed_filter != "")) {
      df <- df %>% filter(breed %in% breed_filter)
    }
    
    return(df)
  }
  
  # Step 2: Data Analysis
  analyze_data <- function(data) {
    if (nrow(data) == 0) return(data.frame())
    
    # Perform analysis
    analysis_results <- data %>%
      group_by(sex, treatment) %>%
      summarise(
        mean_weight = mean(finalpweight, na.rm = TRUE),
        mean_feed = mean(feedintake, na.rm = TRUE),
        mean_methane = mean(methane, na.rm = TRUE),
        count = n(),
        .groups = "drop"
      )
    
    return(analysis_results)
  }
  
  # Step 3: Visualization
  create_visualization <- function(data) {
    if (nrow(data) == 0) return(plotly_empty())
    
    p <- plot_ly(data, x = ~sex, y = ~mean_weight, color = ~treatment, type = "bar")
    return(p)
  }
  
  # Step 4: Export
  generate_export_filename <- function() {
    paste0("analysis_results_", format(Sys.Date(), "%Y%m%d"), ".csv")
  }
  
  # Test complete workflow
  # Step 1: Filter data
  filtered <- filter_data(test_data, year_filter = 2023, sex_filter = c("Male"), breed_filter = c("Angus"))
  expect_equal(nrow(filtered), 3)  # Should have 3 records (E001, E003, E007)
  expect_true(all(filtered$sex == "Male"))
  expect_true(all(filtered$breed == "Angus"))
  
  # Step 2: Analyze data
  analyzed <- analyze_data(filtered)
  expect_true("mean_weight" %in% names(analyzed))
  expect_true("sex" %in% names(analyzed))
  expect_true("treatment" %in% names(analyzed))
  
  # Step 3: Create visualization
  chart <- create_visualization(analyzed)
  expect_true(inherits(chart, "plotly"))
  
  # Step 4: Generate export filename
  filename <- generate_export_filename()
  expect_true(grepl("analysis_results_", filename))
  expect_true(grepl(".csv", filename))
})

# Test 2: Complete Report Generation Workflow
test_that("complete report generation workflow integrates correctly", {
      # Mock complete report workflow: Configure -> Generate -> Schedule -> Send
      
  # Step 1: Report Configuration
  create_report_config <- function(title = "Livestock Dashboard Report", format = "PDF", charts = c("Weight Trend", "Feed Analysis")) {
    list(
      title = title,
      format = format,
      charts = charts,
      filters = list(
        year = 2023,
        sex = c("Male"),
        breed = c("Angus")
      )
    )
  }
      
      # Step 2: Report Generation
      generate_report <- function(config, data) {
        if (nrow(data) == 0) {
          return(list(
            success = FALSE,
            content = "No data available for report generation",
            charts = list()
          ))
        }
        
        # Generate report content
        content <- paste0(
          "# ", config$title, "\n\n",
          "Generated on: ", format(Sys.Date(), "%Y-%m-%d"), "\n\n",
          "## Data Summary\n",
          "- Total records: ", nrow(data), "\n",
          "- Date range: ", min(data$date), " to ", max(data$date), "\n\n"
        )
        
        # Generate charts
        charts <- list()
        if ("Weight Trend" %in% config$charts) {
          charts$weight_trend <- data %>%
            group_by(date) %>%
            summarise(avg_weight = mean(finalpweight, na.rm = TRUE), .groups = "drop")
        }
        
        if ("Feed Analysis" %in% config$charts) {
          charts$feed_analysis <- data %>%
            group_by(sex) %>%
            summarise(avg_feed = mean(feedintake, na.rm = TRUE), .groups = "drop")
        }
        
        return(list(
          success = TRUE,
          content = content,
          charts = charts
        ))
      }
      
      # Step 3: Email Scheduling
      schedule_email_report <- function(config, report_result, recipient, frequency, send_time) {
        if (!report_result$success) {
          return(list(
            success = FALSE,
            message = "Cannot schedule email for failed report"
          ))
        }
        
        # Mock schedule creation
        schedule <- list(
          id = paste0("schedule_", Sys.time()),
          recipient = recipient,
          frequency = frequency,
          send_time = send_time,
          report_config = config,
          created_at = Sys.time(),
          is_active = TRUE
        )
        
        return(list(
          success = TRUE,
          message = paste("Report scheduled for", recipient, "at", send_time),
          schedule = schedule
        ))
      }
      
      # Test complete report workflow
      
      # Step 1: Configure report
      config <- create_report_config("Monthly Livestock Report", "PDF", c("Weight Trend", "Feed Analysis"))
      expect_equal(config$title, "Monthly Livestock Report")
      expect_equal(config$format, "PDF")
      expect_equal(config$charts, c("Weight Trend", "Feed Analysis"))
      
      # Step 2: Generate report
      filtered_data <- test_data %>% filter(year(date) == 2023, sex == "Male", breed == "Angus")
      report_result <- generate_report(config, filtered_data)
      
      expect_true(report_result$success)
      expect_true(grepl("Monthly Livestock Report", report_result$content))
      expect_true(grepl("Total records: 3", report_result$content))  # Fixed: should be 3, not 2
      expect_true("weight_trend" %in% names(report_result$charts))
      expect_true("feed_analysis" %in% names(report_result$charts))
      
      # Step 3: Schedule email
      email_result <- schedule_email_report(
        config, report_result, "manager@farm.com", "Monthly", "09:00"
      )
      
      expect_true(email_result$success)
      expect_true(grepl("Report scheduled for manager@farm.com", email_result$message))
      expect_equal(email_result$schedule$recipient, "manager@farm.com")
      expect_equal(email_result$schedule$frequency, "Monthly")
})

# Test 3: Complete Dashboard Customization Workflow
test_that("complete dashboard customization workflow integrates correctly", {
      # Mock complete customization workflow: Select -> Apply -> Save -> Persist
      
      # Step 1: Theme Selection
      apply_theme <- function(theme_name) {
        themes <- list(
          "flatly" = list(primary = "#1B4332", secondary = "#5C4333"),
          "cerulean" = list(primary = "#2C3E50", secondary = "#3498DB"),
          "darkly" = list(primary = "#375A7F", secondary = "#222222")
        )
        return(themes[[theme_name]] %||% themes[["flatly"]])
      }
      
      # Step 2: Chart Customization
      customize_charts <- function(chart_settings) {
        default_settings <- list(
          line_width = 2,
          point_size = 4,
          show_legend = TRUE,
          show_grid = TRUE
        )
        
        # Merge with custom settings
        for (key in names(chart_settings)) {
          default_settings[[key]] <- chart_settings[[key]]
        }
        
        return(default_settings)
      }
      
      # Step 3: Display Options
      apply_display_options <- function(display_settings) {
        options <- list(
          show_tooltips = TRUE,
          show_animations = TRUE,
          compact_mode = FALSE,
          language = "en"
        )
        
        # Merge with custom settings
        for (key in names(display_settings)) {
          options[[key]] <- display_settings[[key]]
        }
        
        return(options)
      }
      
      # Step 4: Save Configuration
      save_configuration <- function(theme, charts, display) {
        config <- list(
          theme = theme,
          charts = charts,
          display = display,
          saved_at = Sys.time(),
          version = "1.0"
        )
        
        return(config)
      }
      
      # Test complete customization workflow
      
      # Step 1: Apply theme
      theme_config <- apply_theme("cerulean")
      expect_equal(theme_config$primary, "#2C3E50")
      expect_equal(theme_config$secondary, "#3498DB")
      
      # Step 2: Customize charts
      chart_settings <- list(
        line_width = 3,
        point_size = 5,
        show_legend = TRUE
      )
      chart_config <- customize_charts(chart_settings)
      expect_equal(chart_config$line_width, 3)
      expect_equal(chart_config$point_size, 5)
      expect_true(chart_config$show_legend)
      
      # Step 3: Apply display options
      display_settings <- list(
        show_tooltips = TRUE,
        compact_mode = FALSE,
        language = "en"
      )
      display_config <- apply_display_options(display_settings)
      expect_true(display_config$show_tooltips)
      expect_false(display_config$compact_mode)
      expect_equal(display_config$language, "en")
      
      # Step 4: Save configuration
      saved_config <- save_configuration(theme_config, chart_config, display_config)
      expect_equal(saved_config$theme$primary, "#2C3E50")
      expect_equal(saved_config$charts$line_width, 3)
      expect_true(saved_config$display$show_tooltips)
      expect_true(!is.null(saved_config$saved_at))
})

# Test 4: Complete Data Exploration Workflow
test_that("complete data exploration workflow integrates correctly", {
      # Mock complete exploration workflow: Load -> Filter -> Analyze -> Visualize -> Export
      
  # Step 1: Data Loading and Initial Processing
  process_data <- function(data) {
    df <- data
    
    # Add calculated fields
    df$weight_category <- ifelse(df$finalpweight > 400, "Heavy", "Light")
    df$feed_efficiency <- df$finalpweight / df$feedintake
    df$methane_intensity <- df$methane / df$finalpweight
    
    return(df)
  }
      
  # Step 2: Interactive Filtering
  filter_data <- function(data, year_filter = NULL, sex_filter = NULL, weight_category_filter = NULL) {
    df <- data
    
    # Apply multiple filters
    if (!is.null(year_filter)) {
      df <- df %>% filter(year(date) == year_filter)
    }
    if (!is.null(sex_filter) && length(sex_filter) > 0) {
      df <- df %>% filter(sex %in% sex_filter)
    }
    if (!is.null(weight_category_filter)) {
      df <- df %>% filter(weight_category %in% weight_category_filter)
    }
    
    return(df)
  }
      
  # Step 3: Statistical Analysis
  statistical_analysis <- function(data) {
    df <- data
    if (nrow(df) == 0) return(data.frame())
    
    analysis <- df %>%
      summarise(
        count = n(),
        mean_weight = mean(finalpweight, na.rm = TRUE),
        sd_weight = sd(finalpweight, na.rm = TRUE),
        mean_feed_efficiency = mean(feed_efficiency, na.rm = TRUE),
        mean_methane_intensity = mean(methane_intensity, na.rm = TRUE),
        .groups = "drop"
      )
    
    return(analysis)
  }
      
      # Step 4: Multi-dimensional Visualization
      # Create a simple plotly chart for testing
      chart <- plot_ly(data = data.frame(x = 1, y = 1), x = ~x, y = ~y, type = "scatter", mode = "markers")
      
      # Step 5: Export Results
      # Generate export filename
      filename <- paste0("data_exploration_", format(Sys.Date(), "%Y%m%d"), ".csv")
      
  # Test complete exploration workflow
  # Create test data
  test_data <- data.frame(
    date = as.Date(c("2023-01-01", "2023-02-01", "2023-03-01", "2022-01-01", "2022-02-01")),
    sex = c("Male", "Female", "Male", "Female", "Male"),
    finalpweight = c(450, 380, 500, 350, 480),
    feedintake = c(3000, 2500, 3500, 2800, 3200),
    methane = c(5625, 3800, 6500, 3500, 5760),
    weight_category = c("Heavy", "Medium", "Heavy", "Medium", "Heavy")
  )
  
  # Verify data processing
  processed <- process_data(test_data)
  expect_true("weight_category" %in% names(processed))
  expect_true("feed_efficiency" %in% names(processed))
  expect_true("methane_intensity" %in% names(processed))
  
  # Verify filtering
  filtered <- filter_data(processed, year_filter = 2023, sex_filter = c("Male", "Female"), weight_category_filter = "Heavy")
  expect_true(nrow(filtered) > 0)
  expect_true(all(filtered$weight_category == "Heavy"))
  
  # Verify statistical analysis
  stats <- statistical_analysis(filtered)
  expect_true("count" %in% names(stats))
  expect_true("mean_weight" %in% names(stats))
  expect_true("mean_feed_efficiency" %in% names(stats))
      
      # Verify visualization
      chart <- plot_ly(data = data.frame(x = 1, y = 1), x = ~x, y = ~y, type = "bar")
      expect_true(inherits(chart, "plotly"))
      
      # Verify export
      filename <- paste0("data_exploration_", format(Sys.Date(), "%Y%m%d"), ".csv")
      expect_true(grepl("data_exploration_", filename))
})

# Test 5: Complete User Session Workflow
test_that("complete user session workflow integrates correctly", {
  # Mock complete user session: Login -> Navigate -> Analyze -> Export -> Logout
  
  # Step 1: User Authentication
  user_session <- list(
    is_authenticated = FALSE,
    user_role = NULL,
    session_start = NULL,
    pages_visited = character(0),
    actions_performed = character(0)
  )
  
  authenticate_user <- function(username, password, session) {
    # Mock authentication
    if (username == "admin" && password == "admin123") {
      session$is_authenticated <- TRUE
      session$user_role <- "admin"
      session$session_start <- Sys.time()
      return(list(success = TRUE, message = "Login successful", session = session))
    } else if (username == "user" && password == "user123") {
      session$is_authenticated <- TRUE
      session$user_role <- "user"
      session$session_start <- Sys.time()
      return(list(success = TRUE, message = "Login successful", session = session))
    } else {
      return(list(success = FALSE, message = "Invalid credentials", session = session))
    }
  }
  
  # Step 2: Page Navigation Tracking
  track_page_visit <- function(page_name, session) {
    session$pages_visited <- c(session$pages_visited, page_name)
    return(session)
  }
  
  # Step 3: Action Tracking
  track_action <- function(action_name, session) {
    session$actions_performed <- c(session$actions_performed, action_name)
    return(session)
  }
  
  # Step 4: Session Summary
  generate_session_summary <- function(session) {
    if (!session$is_authenticated) {
      return("No active session")
    }
    
    session_duration <- as.numeric(Sys.time() - session$session_start, units = "mins")
    
    summary <- list(
      user_role = session$user_role,
      session_duration = round(session_duration, 2),
      pages_visited = length(unique(session$pages_visited)),
      actions_performed = length(session$actions_performed),
      unique_pages = unique(session$pages_visited),
      actions_list = session$actions_performed
    )
    
    return(summary)
  }
  
  # Test complete user session workflow
  
  # Step 1: Login
  login_result <- authenticate_user("admin", "admin123", user_session)
  expect_true(login_result$success)
  user_session <- login_result$session
  expect_true(user_session$is_authenticated)
  expect_equal(user_session$user_role, "admin")
  
  # Step 2: Navigate pages
  user_session <- track_page_visit("Summary Stats", user_session)
  user_session <- track_page_visit("Time Series", user_session)
  user_session <- track_page_visit("Reports", user_session)
  
  expect_equal(length(user_session$pages_visited), 3)
  expect_true("Summary Stats" %in% user_session$pages_visited)
  
  # Step 3: Perform actions
  user_session <- track_action("filter_data", user_session)
  user_session <- track_action("generate_chart", user_session)
  user_session <- track_action("export_report", user_session)
  
  expect_equal(length(user_session$actions_performed), 3)
  expect_true("filter_data" %in% user_session$actions_performed)
  
  # Step 4: Generate session summary
  summary <- generate_session_summary(user_session)
  expect_equal(summary$user_role, "admin")
  expect_true(summary$session_duration >= 0)
  expect_equal(summary$pages_visited, 3)
  expect_equal(summary$actions_performed, 3)
  expect_equal(length(summary$unique_pages), 3)
  
  # Test logout
  user_session$is_authenticated <- FALSE
  logout_summary <- generate_session_summary(user_session)
  expect_equal(logout_summary, "No active session")
})

# Test 6: Complete Error Handling Workflow
test_that("complete error handling workflow integrates correctly", {
  # Mock complete error handling workflow: Detect -> Log -> Recover -> Notify
  
  # Step 1: Error Detection
  error_log <- list(
    errors = list(),
    warnings = list(),
    last_error = NULL
  )
  
  detect_error <- function(operation, error, log) {
    error_entry <- list(
      timestamp = Sys.time(),
      operation = operation,
      error_type = class(error)[1],
      error_message = error$message,
      severity = "error"
    )
    
    log$errors <- c(log$errors, list(error_entry))
    log$last_error <- error_entry
    
    return(list(error_entry = error_entry, log = log))
  }
  
  # Step 2: Error Logging
  log_error <- function(error_entry) {
    # In real app, would log to file or database
    cat("ERROR:", error_entry$timestamp, "-", error_entry$operation, "-", error_entry$error_message, "\n")
    return(TRUE)
  }
  
  # Step 3: Error Recovery
  recover_from_error <- function(error_entry) {
    recovery_strategies <- list(
      "data_not_found" = "Load default dataset",
      "connection_failed" = "Retry with backup connection",
      "validation_failed" = "Use default values",
      "permission_denied" = "Redirect to login"
    )
    
    strategy <- recovery_strategies[[error_entry$operation]]
    if (is.null(strategy)) strategy <- "Show error message"
    return(strategy)
  }
  
  # Step 4: User Notification
  notify_user <- function(error_entry, recovery_strategy) {
    notification <- list(
      type = "error",
      title = paste("Error in", error_entry$operation),
      message = error_entry$error_message,
      recovery = recovery_strategy,
      timestamp = error_entry$timestamp
    )
    
    return(notification)
  }
  
  # Test complete error handling workflow
  
  # Simulate different types of errors
  test_errors <- list(
    list(operation = "data_not_found", error = simpleError("Data file not found")),
    list(operation = "connection_failed", error = simpleError("Database connection failed")),
    list(operation = "validation_failed", error = simpleError("Invalid input data")),
    list(operation = "permission_denied", error = simpleError("Access denied"))
  )
  
  for (test_error in test_errors) {
    # Step 1: Detect error
    result <- detect_error(test_error$operation, test_error$error, error_log)
    error_entry <- result$error_entry
    error_log <- result$log
    expect_equal(error_entry$operation, test_error$operation)
    expect_equal(error_entry$error_message, test_error$error$message)
    
    # Step 2: Log error
    log_result <- log_error(error_entry)
    expect_true(log_result)
    
    # Step 3: Recover from error
    recovery_strategy <- recover_from_error(error_entry)
    expect_true(is.character(recovery_strategy))
    expect_true(nchar(recovery_strategy) > 0)
    
    # Step 4: Notify user
    notification <- notify_user(error_entry, recovery_strategy)
    expect_equal(notification$type, "error")
    expect_equal(notification$title, paste("Error in", test_error$operation))
    expect_equal(notification$recovery, recovery_strategy)
  }
  
  # Verify error log
  expect_equal(length(error_log$errors), 4)
  expect_true(!is.null(error_log$last_error))
})

# Test 7: Complete Performance Monitoring Workflow
test_that("complete performance monitoring workflow integrates correctly", {
  # Mock complete performance monitoring workflow: Measure -> Analyze -> Alert -> Optimize
  
  # Step 1: Performance Measurement
  performance_metrics <- list(
    measurements = list(),
    alerts = list(),
    optimizations = list()
  )
  
  measure_performance <- function(operation, start_time, end_time, metrics) {
    duration <- as.numeric(end_time - start_time, units = "secs")
    memory_usage <- 100  # Mock memory usage (replacing deprecated memory.size())
    
    measurement <- list(
      timestamp = Sys.time(),
      operation = operation,
      duration = duration,
      memory_usage = memory_usage,
      status = ifelse(duration > 5, "slow", "normal")
    )
    
    metrics$measurements <- c(metrics$measurements, list(measurement))
    return(list(measurement = measurement, metrics = metrics))
  }
  
  # Step 2: Performance Analysis
  analyze_performance <- function(measurements) {
    if (length(measurements) == 0) {
      return(list(
        avg_duration = 0,
        slow_operations = character(0),
        memory_trend = "stable",
        total_operations = 0
      ))
    }
    
    durations <- sapply(measurements, function(m) m$duration)
    slow_ops <- sapply(measurements, function(m) if(m$duration > 5) m$operation else NULL)
    slow_ops <- slow_ops[!sapply(slow_ops, is.null)]
    
    analysis <- list(
      avg_duration = mean(durations),
      max_duration = max(durations),
      slow_operations = unique(slow_ops),
      memory_trend = "stable",  # Simplified
      total_operations = length(measurements)
    )
    
    return(analysis)
  }
  
  # Step 3: Performance Alerting
  check_performance_alerts <- function(analysis, metrics) {
    alerts <- list()
    
    if (analysis$avg_duration > 3) {
      alerts <- c(alerts, list(list(
        type = "performance",
        severity = "warning",
        message = paste("Average operation duration is", round(analysis$avg_duration, 2), "seconds")
      )))
    }
    
    if (length(analysis$slow_operations) > 0) {
      alerts <- c(alerts, list(list(
        type = "performance",
        severity = "error",
        message = paste("Slow operations detected:", paste(analysis$slow_operations, collapse = ", "))
      )))
    }
    
    metrics$alerts <- alerts
    return(list(alerts = alerts, metrics = metrics))
  }
  
  # Step 4: Performance Optimization
  suggest_optimizations <- function(analysis, metrics) {
    optimizations <- character(0)
    
    if (analysis$avg_duration > 2) {
      optimizations <- c(optimizations, "Consider caching frequently accessed data")
    }
    
    if (length(analysis$slow_operations) > 0) {
      optimizations <- c(optimizations, "Optimize slow operations with better algorithms")
    }
    
    if (analysis$total_operations > 100) {
      optimizations <- c(optimizations, "Consider implementing pagination for large datasets")
    }
    
    metrics$optimizations <- optimizations
    return(list(optimizations = optimizations, metrics = metrics))
  }
  
  # Test complete performance monitoring workflow
  
  # Simulate performance measurements
  operations <- c("data_load", "data_filter", "chart_render", "export_data")
  
  for (op in operations) {
    start_time <- Sys.time()
    Sys.sleep(0.1)  # Simulate operation
    end_time <- Sys.time()
    
    result <- measure_performance(op, start_time, end_time, performance_metrics)
    measurement <- result$measurement
    performance_metrics <- result$metrics
    expect_equal(measurement$operation, op)
    expect_true(measurement$duration > 0)
  }
  
  # Analyze performance
  analysis <- analyze_performance(performance_metrics$measurements)
  expect_equal(analysis$total_operations, 4)
  expect_true(analysis$avg_duration > 0)
  
  # Check for alerts
  alert_result <- check_performance_alerts(analysis, performance_metrics)
  alerts <- alert_result$alerts
  performance_metrics <- alert_result$metrics
  expect_true(is.list(alerts))
  
  # Suggest optimizations
  opt_result <- suggest_optimizations(analysis, performance_metrics)
  optimizations <- opt_result$optimizations
  performance_metrics <- opt_result$metrics
  expect_true(is.character(optimizations))
  
  # Verify performance metrics
  expect_equal(length(performance_metrics$measurements), 4)
  expect_true(is.list(performance_metrics$alerts))
  expect_true(is.character(performance_metrics$optimizations))
})

# Test 8: Complete Integration Test Workflow
test_that("complete integration test workflow integrates correctly", {
  # Mock complete integration test: Setup -> Execute -> Validate -> Cleanup
  
  # Create test data
  test_data <- data.frame(
    sex = c("Male", "Female", "Male", "Female", "Male"),
    finalpweight = c(450, 380, 500, 350, 480),
    feedintake = c(3000, 2500, 3500, 2800, 3200),
    methane = c(5625, 3800, 6500, 3500, 5760)
  )
  
  # Step 1: Test Setup
  test_environment <- list(
    test_data = NULL,
    test_config = NULL,
    test_results = list(),
    cleanup_required = FALSE
  )
  
  setup_test_environment <- function(test_name, data, env) {
    env$test_data <- data
    env$test_config <- list(
      name = test_name,
      start_time = Sys.time(),
      data_size = nrow(data),
      expected_results = list()
    )
    env$cleanup_required <- TRUE
    
    return(list(success = TRUE, environment = env))
  }
  
  # Step 2: Execute Test Scenarios
  execute_test_scenario <- function(scenario_name, test_function, env) {
    tryCatch({
      result <- test_function(env$test_data)
      
      test_result <- list(
        scenario = scenario_name,
        success = TRUE,
        result = result,
        timestamp = Sys.time()
      )
      
      env$test_results <- c(env$test_results, list(test_result))
      return(list(test_result = test_result, environment = env))
    }, error = function(e) {
      test_result <- list(
        scenario = scenario_name,
        success = FALSE,
        error = e$message,
        timestamp = Sys.time()
      )
      
      env$test_results <- c(env$test_results, list(test_result))
      return(list(test_result = test_result, environment = env))
    })
  }
  
  # Step 3: Validate Results
  validate_test_results <- function(env) {
    if (length(env$test_results) == 0) {
      return(list(
        valid = FALSE,
        message = "No test results to validate"
      ))
    }
    
    successful_tests <- sum(sapply(env$test_results, function(r) r$success))
    total_tests <- length(env$test_results)
    
    validation <- list(
      valid = successful_tests == total_tests,
      successful_tests = successful_tests,
      total_tests = total_tests,
      success_rate = successful_tests / total_tests,
      failed_scenarios = sapply(env$test_results, function(r) if(!r$success) r$scenario else NULL)
    )
    
    validation$failed_scenarios <- validation$failed_scenarios[!sapply(validation$failed_scenarios, is.null)]
    
    return(validation)
  }
  
  # Step 4: Cleanup
  cleanup_test_environment <- function(env) {
    if (env$cleanup_required) {
      env$test_data <- NULL
      env$test_config <- NULL
      env$test_results <- list()
      env$cleanup_required <- FALSE
      return(list(success = TRUE, environment = env))
    }
    return(list(success = FALSE, environment = env))
  }
  
  # Test complete integration test workflow
  
  # Step 1: Setup
  setup_result <- setup_test_environment("Integration Test Suite", test_data, test_environment)
  expect_true(setup_result$success)
  test_environment <- setup_result$environment
  expect_equal(test_environment$test_config$name, "Integration Test Suite")
  expect_equal(test_environment$test_config$data_size, nrow(test_data))
  
  # Step 2: Execute test scenarios
  test_scenarios <- list(
    "data_filtering" = function(data) nrow(data %>% filter(sex == "Male")),
    "data_analysis" = function(data) mean(data$finalpweight, na.rm = TRUE),
    "data_export" = function(data) paste("Exported", nrow(data), "records")
  )
  
  for (scenario_name in names(test_scenarios)) {
    result <- execute_test_scenario(scenario_name, test_scenarios[[scenario_name]], test_environment)
    test_environment <- result$environment
    expect_equal(result$test_result$scenario, scenario_name)
    expect_true(result$test_result$success)
  }
  
  # Step 3: Validate results
  validation <- validate_test_results(test_environment)
  expect_true(validation$valid)
  expect_equal(validation$successful_tests, 3)
  expect_equal(validation$total_tests, 3)
  expect_equal(validation$success_rate, 1.0)
  
  # Step 4: Cleanup
  cleanup_result <- cleanup_test_environment(test_environment)
  expect_true(cleanup_result$success)
  test_environment <- cleanup_result$environment
  expect_true(is.null(test_environment$test_data))
  expect_false(test_environment$cleanup_required)
})
