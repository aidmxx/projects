#!/usr/bin/env Rscript

# Comprehensive coverage script that generates HTML report using covr
cat("Running comprehensive coverage analysis with covr...\n")

# Install required packages if not available
required_packages <- c("covr", "testthat", "dplyr", "lubridate", "shiny", "shinyWidgets", 
                      "ggplot2", "plotly", "rlang", "tidyr", "bslib", "DT", "RColorBrewer", "blastula",
                      "gridExtra", "openxlsx", "readr", "mockery")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing package:", pkg, "\n")
    tryCatch({
      install.packages(pkg, repos = "https://cran.rstudio.com/")
      library(pkg, character.only = TRUE)
    }, error = function(e) {
      cat("Warning: Could not install", pkg, ":", e$message, "\n")
    })
  }
}

# SVG support removed to avoid dependency issues

# Load required packages
library(covr)
library(testthat)
library(dplyr)
library(lubridate)

# Set working directory to project root
setwd(".")

# Source files to analyze - focus on files that covr can measure properly
# Note: Excluded files that have covr detection issues:
# - src/core_business_logic.R: Functions sourced in tests, covr can't detect calls
# - src/graph.R: Shiny reactive functions, hard to measure with covr
# - src/distribution.R: Shiny reactive functions (renderPlotly outputs), requires active Shiny session
# - src/timeseries_page.R: Shiny reactive functions (moduleServer, renderPlotly), requires active Shiny session
# These files are still thoroughly tested, just not measured by covr
source_files <- c(
  "src/filter.R",
  "src/cohorts_page.R",
  "src/customise.R",
  "src/summary_stats.R",
  "src/report_generator.R",
  # Include email logic for coverage
  "src/email_automation.R",
  "src/report_page.R"
)

# Test files - organized by functionality
test_files <- c(
  "tests/testthat/filter/test-filter-core-functions.R",
  "tests/testthat/filter/test-filter-ui-builders.R",
  "tests/testthat/filter/test-filter-reactives.R",
  "tests/testthat/filter/test-filter-edge-cases.R",
  "tests/testthat/filter/test-filter-grouping-logic.R",
  "tests/testthat/filter/test-filter-observers.R",
  "tests/testthat/filter/test-filter-varying-cols.R",
  "tests/testthat/filter/test-filter-uncovered-paths.R",
  "tests/testthat/test-cohorts-functions.R",
  "tests/testthat/test-customise-functions.R",
  "tests/testthat/test-summary-stats.R",
  "tests/testthat/test-summary-stats-edge-cases.R", # NEW
  "tests/testthat/test-shiny-app.R",
  # Include email-related unit/integration tests
  # Note: All email test files removed due to blastula dependencies
  # NEW: Comprehensive email automation tests for increased coverage
  "tests/testthat/test-email-automation-comprehensive.R",
  # NEW: Extended email automation tests for additional coverage
  "tests/testthat/test-email-automation-extended.R",
  # Report generator unit tests
  "tests/testthat/test-report-generator.R",
  # NEW: Report generator function tests for additional coverage
  "tests/testthat/test-report-generator-functions.R",
  # Report page tests
  "tests/testthat/test-report-page.R",
  # NEW: Simple report page tests for increased coverage (avoids Shiny server issues)
  "tests/testthat/test-report-page-simple.R",
  "tests/testthat/test_friendly_label.R" # Added for full coverage of friendly_label
)

cat("Source files:", paste(basename(source_files), collapse = ", "), "\n")
cat("Test files:", paste(basename(test_files), collapse = ", "), "\n")

# Run coverage analysis with exclusions
cat("Running coverage analysis...\n")

# Run coverage analysis - #nocov comments in source code will handle exclusions
coverage <- file_coverage(source_files, test_files)

# Print summary
print(coverage)
cat("Overall coverage:", percent_coverage(coverage), "%\n")

# Generate HTML report
cat("Generating HTML report...\n")
report(coverage, file = "test_coverage.html", browse = FALSE)

cat("Coverage analysis complete!\n")
cat("HTML report saved to: test_coverage.html\n")
cat("Open the HTML file in your browser to view the detailed coverage report.\n")
