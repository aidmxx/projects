# Email Integration Tests Runner (consolidated)
library(testthat)

# Set up test environment
cat("Setting up email test environment...\n")

# Check if required packages are available
required_packages <- c("testthat", "blastula", "shiny")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing package:", pkg, "\n")
    install.packages(pkg, repos = "https://cran.rstudio.com/")
    library(pkg, character.only = TRUE)
  }
}

# Set working directory to project root
if (!file.exists("src")) {
  if (file.exists("../src")) {
    setwd("..")
  } else if (file.exists("../../src")) {
    setwd("../..")
  }
}

cat("Running email tests from:", getwd(), "\n")

# Run all email tests
test_files <- c(
  "tests/testthat/test-email-features.R",
  "tests/testthat/test-email-credentials.R", 
  "tests/testthat/test-email-report-generation.R",
  "tests/testthat/test-email-integration.R"
)

# Check which test files exist
existing_test_files <- test_files[file.exists(test_files)]

if (length(existing_test_files) == 0) {
  cat("No email test files found!\n")
  cat("Expected test files:\n")
  for (file in test_files) {
    cat("  -", file, "\n")
  }
  stop("Please ensure test files are in the correct location")
}

cat("Found", length(existing_test_files), "email test files:\n")
for (file in existing_test_files) {
  cat("  -", file, "\n")
}

# Run tests
cat("\n==================================================\n")
cat("RUNNING EMAIL TESTS\n")
cat("==================================================\n")

test_results <- list()
total_tests <- 0

for (test_file in existing_test_files) {
  cat("\nRunning tests in:", test_file, "\n")
  cat("----------------------------------------\n")
  
  tryCatch({
    # Count tests by scanning for test_that( occurrences
    lines <- readLines(test_file, warn = FALSE)
    file_total <- sum(grepl("\\btest_that\\s*\\(", lines))
    total_tests <- total_tests + file_total
    test_results[[test_file]] <- list(n = file_total)

    # Show human-friendly summary output
    testthat::test_file(test_file, reporter = "summary")
    
    cat("Tests completed for:", basename(test_file), "\n")
    
  }, error = function(e) {
    cat("Error running tests in:", test_file, "\n")
    cat("Error:", e$message, "\n")
  })
}

# Summary
cat("\n==================================================\n")
cat("EMAIL TESTS SUMMARY\n")
cat("==================================================\n")

cat("Total test files run:", length(existing_test_files), "\n")
cat("Total tests:", total_tests, "\n")
cat("(See console output above for pass/fail details.)\n")

if (length(test_results) > 0) {
  cat("\nDetailed Results:\n")
  cat("------------------------------\n")
  for (file in names(test_results)) {
    result <- test_results[[file]]
    cat("File:", basename(file), "\n")
    cat("  Tests:", result$n, "\n\n")
  }
}

cat("\nEmail tests completed!\n")
cat("To run individual test files, use:\n")
cat("  testthat::test_file('tests/testthat/test-email-features.R')\n")
cat("  testthat::test_file('tests/testthat/test-email-credentials.R')\n")
cat("  testthat::test_file('tests/testthat/test-email-report-generation.R')\n")
cat("  testthat::test_file('tests/testthat/test-email-integration.R')\n")

# Auto-generate HTML report
cat("\nGenerating HTML report (email_tests_report.html)...\n")
if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  install.packages("rmarkdown", repos = "https://cran.rstudio.com/")
}

# Determine project root for robust rendering
root_dir <- if (file.exists("src")) {
  "."
} else if (file.exists("../src")) {
  ".."
} else if (file.exists("../../src")) {
  "../.."
} else {
  "."
}

rmd_input <- file.path(root_dir, "tests/testthat/email_tests_report.Rmd")
out_file <- file.path(root_dir, "email_tests_report.html")

if (file.exists(rmd_input)) {
  tryCatch({
    rmarkdown::render(input = rmd_input, output_file = out_file, quiet = TRUE)
    cat("Report generated at:", normalizePath(out_file, winslash = "/", mustWork = FALSE), "\n")
  }, error = function(e) {
    cat("Warning: Failed to generate HTML report:", e$message, "\n")
  })
} else {
  cat("Warning: Could not find Rmd at:", rmd_input, "\n")
}



