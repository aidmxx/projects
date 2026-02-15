#!/usr/bin/env Rscript

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  install.packages("rmarkdown", repos = "https://cran.rstudio.com/")
}

# Resolve project root to find the Rmd regardless of where this is run from
root_dir <- if (file.exists("../..//src")) {
  "../.."
} else if (file.exists("..//src")) {
  ".."
} else if (file.exists("src")) {
  "."
} else {
  ".."  # default fallback to project root from tests/testthat
}

input <- file.path(root_dir, "tests/testthat/email_tests_report.Rmd")
output <- file.path(root_dir, "email_tests_report.html")

if (!file.exists(input)) {
  stop("Cannot find Rmd at ", input)
}

rmarkdown::render(input = input, output_file = output, quiet = FALSE)
cat("\nReport generated:", normalizePath(output, winslash = "/", mustWork = FALSE), "\n")


