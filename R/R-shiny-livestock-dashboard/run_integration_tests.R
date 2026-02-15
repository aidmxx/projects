# Integration Test Runner
# This script runs all integration tests with proper setup

library(testthat)
library(shiny)
library(dplyr)
library(plotly)

# Set working directory to project root
if (!file.exists("src")) {
  setwd("..")
}

# Source the setup file if it exists
if (file.exists("tests/testthat/setup.R")) {
  source("tests/testthat/setup.R")
}

# Run integration tests
cat("Running Integration Tests...\n")
cat("============================\n\n")

# Run tests and capture results
test_results <- test_dir(
  "tests/testthat", 
  filter = "integration",
  reporter = "minimal"
)

cat("\n============================\n")
cat("Integration Tests Complete!\n")

# Check if all tests passed
if (length(test_results) > 0) {
  total_failed <- sum(test_results$failed)
  total_passed <- sum(test_results$passed)
  
  if (total_failed == 0) {
    cat("🎉 ALL TESTS PASSED! 🎉\n")
  } else {
    cat(sprintf("⚠️  %d test(s) failed, %d passed\n", total_failed, total_passed))
  }
} else {
  cat("❌ No test results found\n")
}
