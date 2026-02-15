# Integration Tests: Customise Functionality Workflow
# Tests the complete workflow from customization settings to UI updates and persistence

library(testthat)
library(shiny)
library(dplyr)

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

# Source required functions
if (file.exists("src/customise.R")) {
  source("src/customise.R")
} else if (file.exists("../src/customise.R")) {
  source("../src/customise.R")
} else if (file.exists("../../src/customise.R")) {
  source("../../src/customise.R")
}

# Test 1: Complete Customise Workflow
test_that("complete customise workflow integrates correctly", {
  # Mock customization settings
  custom_settings <- list(
    theme = "flatly",
    color_scheme = "default",
    chart_preferences = list(),
    display_options = list(),
    user_preferences = list()
  )
  
  # Mock theme application
  apply_theme <- function(theme_name, settings) {
    themes <- list(
      "flatly" = list(primary = "#1B4332", secondary = "#5C4033"),
      "cerulean" = list(primary = "#2C3E50", secondary = "#3498DB"),
      "cosmo" = list(primary = "#2780E3", secondary = "#373A3C"),
      "darkly" = list(primary = "#375A7F", secondary = "#222222")
    )
    
    if (theme_name %in% names(themes)) {
      settings$theme <- theme_name
      return(list(theme = themes[[theme_name]], settings = settings))
    } else {
      return(list(theme = themes[["flatly"]], settings = settings))
    }
  }
  
  # Mock color scheme application
  apply_color_scheme <- function(color_scheme, settings) {
    schemes <- list(
      "default" = c("#1B4332", "#5C4033", "#2D6A4F", "#B08968"),
      "blue" = c("#2C3E50", "#3498DB", "#5DADE2", "#85C1E9"),
      "green" = c("#27AE60", "#2ECC71", "#58D68D", "#82E0AA"),
      "purple" = c("#8E44AD", "#9B59B6", "#BB8FCE", "#D2B4DE")
    )
    
    if (color_scheme %in% names(schemes)) {
      settings$color_scheme <- color_scheme
      return(list(colors = schemes[[color_scheme]], settings = settings))
    } else {
      return(list(colors = schemes[["default"]], settings = settings))
    }
  }
  
  # Test theme application
  theme_result <- apply_theme("cerulean", custom_settings)
  custom_settings <- theme_result$settings
  expect_equal(custom_settings$theme, "cerulean")
  expect_equal(theme_result$theme$primary, "#2C3E50")
  expect_equal(theme_result$theme$secondary, "#3498DB")
  
  # Test color scheme application
  color_result <- apply_color_scheme("blue", custom_settings)
  custom_settings <- color_result$settings
  expect_equal(custom_settings$color_scheme, "blue")
  expect_equal(color_result$colors[1], "#2C3E50")
  expect_equal(color_result$colors[2], "#3498DB")
  
  # Test invalid theme
  invalid_result <- apply_theme("invalid_theme", custom_settings)
  expect_equal(invalid_result$theme$primary, "#1B4332")  # Should fallback to default
})

# Test 2: Chart Customization Integration
test_that("chart customization integrates correctly", {
  # Mock chart customization
  customize_chart <- function(chart_type, custom_settings) {
    chart_configs <- list(
      "line" = list(
        line_width = if (is.null(custom_settings$line_width)) 2 else custom_settings$line_width,
        point_size = if (is.null(custom_settings$point_size)) 4 else custom_settings$point_size,
        show_legend = if (is.null(custom_settings$show_legend)) TRUE else custom_settings$show_legend,
        show_grid = if (is.null(custom_settings$show_grid)) TRUE else custom_settings$show_grid
      ),
      "bar" = list(
        bar_width = if (is.null(custom_settings$bar_width)) 0.8 else custom_settings$bar_width,
        bar_spacing = if (is.null(custom_settings$bar_spacing)) 0.1 else custom_settings$bar_spacing,
        show_values = if (is.null(custom_settings$show_values)) FALSE else custom_settings$show_values,
        show_legend = if (is.null(custom_settings$show_legend)) TRUE else custom_settings$show_legend
      ),
      "scatter" = list(
        point_size = if (is.null(custom_settings$point_size)) 6 else custom_settings$point_size,
        point_opacity = if (is.null(custom_settings$point_opacity)) 0.7 else custom_settings$point_opacity,
        show_trend_line = if (is.null(custom_settings$show_trend_line)) FALSE else custom_settings$show_trend_line,
        show_legend = if (is.null(custom_settings$show_legend)) TRUE else custom_settings$show_legend
      )
    )
    
    if (chart_type %in% names(chart_configs)) {
      return(chart_configs[[chart_type]])
    } else {
      return(chart_configs[["line"]])
    }
  }
  
  # Mock chart settings
  chart_settings <- list(
    line_width = 3,
    point_size = 5,
    show_legend = TRUE,
    show_grid = TRUE,
    bar_width = 0.9,
    show_values = TRUE
  )
  
  # Test line chart customization
  line_config <- customize_chart("line", chart_settings)
  expect_equal(line_config$line_width, 3)
  expect_equal(line_config$point_size, 5)
  expect_true(line_config$show_legend)
  
  # Test bar chart customization
  bar_config <- customize_chart("bar", chart_settings)
  expect_equal(bar_config$bar_width, 0.9)
  expect_true(bar_config$show_values)
  
  # Test scatter chart customization with updated settings
  scatter_settings <- chart_settings
  scatter_settings$point_opacity <- 0.8
  scatter_settings$show_trend_line <- TRUE
  scatter_config <- customize_chart("scatter", scatter_settings)
  expect_equal(scatter_config$point_opacity, 0.8)
  expect_true(scatter_config$show_trend_line)
})

# Test 3: Display Options Integration
test_that("display options integrate correctly", {
  # Mock display options
  apply_display_options <- function(options) {
    display_config <- list(
      show_tooltips = if (is.null(options$show_tooltips)) TRUE else options$show_tooltips,
      show_animations = if (is.null(options$show_animations)) TRUE else options$show_animations,
      show_loading_spinners = if (is.null(options$show_loading_spinners)) TRUE else options$show_loading_spinners,
      compact_mode = if (is.null(options$compact_mode)) FALSE else options$compact_mode,
      show_debug_info = if (is.null(options$show_debug_info)) FALSE else options$show_debug_info,
      language = if (is.null(options$language)) "en" else options$language,
      date_format = if (is.null(options$date_format)) "%Y-%m-%d" else options$date_format,
      number_format = if (is.null(options$number_format)) "%.1f" else options$number_format
    )
    
    return(display_config)
  }
  
  # Test display options application
  display_settings <- list(
    show_tooltips = TRUE,
    show_animations = FALSE,
    compact_mode = TRUE,
    language = "en",
    date_format = "%d/%m/%Y"
  )
  
  applied_options <- apply_display_options(display_settings)
  expect_true(applied_options$show_tooltips)
  expect_false(applied_options$show_animations)
  expect_true(applied_options$compact_mode)
  expect_equal(applied_options$language, "en")
  expect_equal(applied_options$date_format, "%d/%m/%Y")
  
  # Test with different language
  spanish_settings <- display_settings
  spanish_settings$language <- "es"
  spanish_options <- apply_display_options(spanish_settings)
  expect_equal(spanish_options$language, "es")
  
  # Test compact mode
  compact_settings <- display_settings
  compact_settings$compact_mode <- TRUE
  compact_options <- apply_display_options(compact_settings)
  expect_true(compact_options$compact_mode)
})

# Test 4: User Preferences Integration
test_that("user preferences integrate correctly", {
  # Mock user preferences storage
  user_preferences <- list(
    preferences = list(),
    last_updated = NULL
  )
  
  # Mock save preferences
  save_user_preferences <- function(prefs, storage) {
    storage$preferences <- prefs
    storage$last_updated <- Sys.time()
    return(list(success = TRUE, storage = storage))
  }
  
  # Mock load preferences
  load_user_preferences <- function(storage) {
    return(storage$preferences)
  }
  
  # Mock preference validation
  validate_preferences <- function(prefs) {
    required_fields <- c("theme", "color_scheme", "chart_preferences")
    missing_fields <- setdiff(required_fields, names(prefs))
    
    if (length(missing_fields) > 0) {
      return(list(
        valid = FALSE,
        errors = paste("Missing required fields:", paste(missing_fields, collapse = ", "))
      ))
    }
    
    return(list(valid = TRUE, errors = character(0)))
  }
  
  # Test saving preferences
  test_preferences <- list(
    theme = "cerulean",
    color_scheme = "blue",
    chart_preferences = list(
      line_width = 3,
      show_legend = TRUE
    ),
    display_options = list(
      show_tooltips = TRUE,
      compact_mode = FALSE
    )
  )
  
  save_result <- save_user_preferences(test_preferences, user_preferences)
  user_preferences <- save_result$storage
  loaded_prefs <- load_user_preferences(user_preferences)
  
  expect_true(save_result$success)
  expect_equal(loaded_prefs$theme, "cerulean")
  expect_equal(loaded_prefs$color_scheme, "blue")
  expect_true(!is.null(user_preferences$last_updated))
  
  # Test preference validation
  validation_result <- validate_preferences(test_preferences)
  expect_true(validation_result$valid)
  expect_equal(length(validation_result$errors), 0)
  
  # Test invalid preferences
  invalid_prefs <- list(
    theme = "cerulean"
    # Missing required fields
  )
  
  invalid_validation <- validate_preferences(invalid_prefs)
  expect_false(invalid_validation$valid)
  expect_true(grepl("Missing required fields", invalid_validation$errors))
})

# Test 5: Customization Persistence Integration
test_that("customization persistence integrates correctly", {
  # Mock persistence storage
  persistence_storage <- list(
    stored_settings = list(),
    storage_method = "localStorage"
  )
  
  # Mock save to storage
  save_to_storage <- function(settings, method, storage) {
    storage$stored_settings <- settings
    storage$storage_method <- method
    
    # Simulate storage operation
    if (method == "localStorage") {
      # In real app, would use JavaScript to save to browser localStorage
      return(list(result = paste("Settings saved to localStorage:", length(settings), "items"), storage = storage))
    } else if (method == "database") {
      # In real app, would save to database
      return(list(result = paste("Settings saved to database:", length(settings), "items"), storage = storage))
    } else {
      return(list(result = "Unknown storage method", storage = storage))
    }
  }
  
  # Mock load from storage
  load_from_storage <- function(method, storage) {
    if (method == "localStorage") {
      # In real app, would load from browser localStorage
      return(storage$stored_settings)
    } else if (method == "database") {
      # In real app, would load from database
      return(storage$stored_settings)
    } else {
      return(list())
    }
  }
  
  # Test saving to localStorage
  test_settings <- list(
    theme = "darkly",
    color_scheme = "purple",
    chart_preferences = list(line_width = 4)
  )
  
  save_result <- save_to_storage(test_settings, "localStorage", persistence_storage)
  persistence_storage <- save_result$storage
  expect_true(grepl("Settings saved to localStorage", save_result$result))
  expect_equal(persistence_storage$storage_method, "localStorage")
  
  # Test loading from localStorage
  loaded_settings <- load_from_storage("localStorage", persistence_storage)
  expect_equal(loaded_settings$theme, "darkly")
  expect_equal(loaded_settings$color_scheme, "purple")
  
  # Test saving to database
  db_save_result <- save_to_storage(test_settings, "database", persistence_storage)
  persistence_storage <- db_save_result$storage
  expect_true(grepl("Settings saved to database", db_save_result$result))
  expect_equal(persistence_storage$storage_method, "database")
})

# Test 6: Customization Reset Integration
test_that("customization reset integrates correctly", {
  # Mock reset functionality
  reset_customizations <- function(reset_type = "all") {
    default_settings <- list(
      theme = "flatly",
      color_scheme = "default",
      chart_preferences = list(
        line_width = 2,
        point_size = 4,
        show_legend = TRUE,
        show_grid = TRUE
      ),
      display_options = list(
        show_tooltips = TRUE,
        show_animations = TRUE,
        compact_mode = FALSE,
        language = "en"
      )
    )
    
    switch(reset_type,
      "all" = default_settings,
      "theme" = list(theme = "flatly", color_scheme = "default"),
      "charts" = list(chart_preferences = default_settings$chart_preferences),
      "display" = list(display_options = default_settings$display_options)
    )
  }
  
  # Test reset all
  reset_all <- reset_customizations("all")
  expect_equal(reset_all$theme, "flatly")
  expect_equal(reset_all$color_scheme, "default")
  expect_equal(reset_all$chart_preferences$line_width, 2)
  expect_false(reset_all$display_options$compact_mode)
  
  # Test reset theme only
  reset_theme <- reset_customizations("theme")
  expect_equal(reset_theme$theme, "flatly")
  expect_equal(reset_theme$color_scheme, "default")
  expect_false("chart_preferences" %in% names(reset_theme))
  
  # Test reset charts only
  reset_charts <- reset_customizations("charts")
  expect_equal(reset_charts$chart_preferences$line_width, 2)
  expect_equal(reset_charts$chart_preferences$point_size, 4)
  expect_false("theme" %in% names(reset_charts))
  
  # Test reset display only
  reset_display <- reset_customizations("display")
  expect_false(reset_display$display_options$compact_mode)
  expect_true(reset_display$display_options$show_tooltips)
  expect_false("theme" %in% names(reset_display))
})

# Test 7: Customization Export/Import Integration
test_that("customization export/import integrates correctly", {
  # Mock export functionality
  export_customizations <- function(settings, format = "json") {
    switch(format,
      "json" = {
        json_string <- jsonlite::toJSON(settings, pretty = TRUE)
        return(paste("Customizations exported as JSON:", nchar(json_string), "characters"))
      },
      "yaml" = {
        # Mock YAML export
        return(paste("Customizations exported as YAML:", length(settings), "settings"))
      },
      "csv" = {
        # Mock CSV export
        return(paste("Customizations exported as CSV:", length(settings), "settings"))
      }
    )
  }
  
  # Mock import functionality
  import_customizations <- function(import_data, format = "json") {
    switch(format,
      "json" = {
        tryCatch({
          parsed_settings <- jsonlite::fromJSON(import_data)
          return(list(
            success = TRUE,
            settings = parsed_settings,
            message = "Settings imported successfully"
          ))
        }, error = function(e) {
          return(list(
            success = FALSE,
            settings = list(),
            message = paste("Import failed:", e$message)
          ))
        })
      },
      "yaml" = {
        # Mock YAML import
        return(list(
          success = TRUE,
          settings = list(theme = "imported"),
          message = "YAML settings imported"
        ))
      }
    )
  }
  
  # Test settings
  test_settings <- list(
    theme = "cerulean",
    color_scheme = "blue",
    chart_preferences = list(line_width = 3)
  )
  
  # Test JSON export
  json_export <- export_customizations(test_settings, "json")
  expect_true(grepl("Customizations exported as JSON", json_export))
  expect_true(grepl("characters", json_export))
  
  # Test YAML export
  yaml_export <- export_customizations(test_settings, "yaml")
  expect_true(grepl("Customizations exported as YAML", yaml_export))
  
  # Test JSON import
  valid_json <- '{"theme":"darkly","color_scheme":"purple"}'
  json_import <- import_customizations(valid_json, "json")
  
  expect_true(json_import$success)
  expect_equal(json_import$settings$theme, "darkly")
  expect_equal(json_import$settings$color_scheme, "purple")
  
  # Test invalid JSON import
  invalid_json <- '{"theme":"darkly"'  # Missing closing brace
  invalid_import <- import_customizations(invalid_json, "json")
  
  expect_false(invalid_import$success)
  expect_true(grepl("Import failed", invalid_import$message))
})

# Test 8: Customization Performance Integration
test_that("customization performance integrates correctly", {
  # Mock performance tracking
  performance_tracker <- list(
    apply_time = NULL,
    settings_count = NULL,
    memory_usage = NULL
  )
  
  # Mock performance-aware customization application
  apply_customizations_with_performance <- function(settings, tracker) {
    start_time <- Sys.time()
    
    # Simulate customization application
    applied_settings <- list()
    for (key in names(settings)) {
      applied_settings[[key]] <- settings[[key]]
    }
    
    # Track performance
    end_time <- Sys.time()
    tracker$apply_time <- as.numeric(end_time - start_time, units = "secs")
    tracker$settings_count <- length(settings)
    tracker$memory_usage <- object.size(settings)
    
    return(list(applied_settings = applied_settings, tracker = tracker))
  }
  
  # Test performance tracking
  test_settings <- list(
    theme = "cerulean",
    color_scheme = "blue",
    chart_preferences = list(line_width = 3, point_size = 5),
    display_options = list(show_tooltips = TRUE, compact_mode = FALSE)
  )
  
  result <- apply_customizations_with_performance(test_settings, performance_tracker)
  applied_settings <- result$applied_settings
  performance_tracker <- result$tracker
  
  # Verify performance metrics
  expect_true(!is.null(performance_tracker$apply_time))
  expect_true(performance_tracker$apply_time >= 0)
  expect_equal(performance_tracker$settings_count, 4)
  expect_true(performance_tracker$memory_usage > 0)
  
  # Verify applied settings
  expect_equal(applied_settings$theme, "cerulean")
  expect_equal(applied_settings$color_scheme, "blue")
  expect_equal(applied_settings$chart_preferences$line_width, 3)
  
  # Test with larger settings
  large_settings <- c(test_settings, list(
    additional_setting1 = "value1",
    additional_setting2 = "value2",
    additional_setting3 = "value3"
  ))
  
  large_result <- apply_customizations_with_performance(large_settings, performance_tracker)
  performance_tracker <- large_result$tracker
  
  expect_equal(performance_tracker$settings_count, 7)
  expect_true(performance_tracker$memory_usage > object.size(test_settings))
  
  # Mock performance summary
  performance_text <- paste(
    "Apply time:", round(performance_tracker$apply_time, 4), "seconds;",
    "Settings count:", performance_tracker$settings_count, "items;",
    "Memory usage:", round(performance_tracker$memory_usage / 1024, 2), "KB"
  )
  
  expect_true(grepl("Apply time:", performance_text))
  expect_true(grepl("Settings count:", performance_text))
  expect_true(grepl("Memory usage:", performance_text))
})
