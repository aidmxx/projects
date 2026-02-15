library(testthat)
library(dplyr)
library(lubridate)

# test ngrok

# Install required packages if not available
required_packages <- c("shiny", "shinyWidgets", "ggplot2", "plotly", "rlang", "tidyr", "bslib", "DT", "RColorBrewer")

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

# Create dat0_cache for testing (skip global.R to avoid database connection issues)
cat("Creating dat0_cache for testing (skipping database connection)...\n")
dat0_cache <<- list(
  years = 2023,
  months = c("All", month.name),
  days = c("All", 1:31),
  sexes = c("Overall", "Male", "Female"),
  treatments = c("Overall", "No Treatment", "Control", "Treatment A", "Treatment B"),
  breeds = c("Overall", "Angus", "Hereford", "Charolais"),
  mobs = c("Overall", "Mob1", "Mob2", "Mob3"),
  eids = c("Overall", 1:100),
  max_year = 2023
)
cat("Created minimal dat0_cache for testing\n")

# Source all the source files with error handling
source_files <- c("filter.R", "summary_stats.R", "cohorts_page.R", "customise.R", "distribution.R", "timeseries_page.R", "report_page.R", "email_automation.R", "report_generator.R")

# Determine the correct path to src directory
src_path <- if (file.exists("src")) {
  "src"  # We're in the project root
} else if (file.exists("../src")) {
  "../src"  # We're in tests directory
} else if (file.exists("../../src")) {
  "../../src"  # We're in tests/testthat directory
} else {
  stop("Cannot find src directory. Current working directory: ", getwd())
}

for (f in source_files) {
  fpath <- file.path(src_path, f)
  if (file.exists(fpath)) {
    tryCatch({
      source(fpath, local = TRUE)
      cat("Successfully sourced:", f, "\n")
    }, error = function(e) {
      cat("Warning: Could not source", f, ":", e$message, "\n")
    })
  } else {
    cat("Warning: File does not exist:", fpath, "\n")
  }
}

# Define global variables that might be needed
measure_units <- list(
  finalpweight = "kg",
  finalgrowthpbs = "kg/day", 
  methane = "g/day",
  animalvalue = "$",
  animalprod = "S/day",
  carcassweight = "kg",
  feedintakekgd = "kg/day"
)

measure_labels <- c(
  finalpweight   = "Final processed weight (kg)",
  finalgrowthpbs = "Final growth PBS (kg/day)",
  methane        = "Methane production (g/day)",
  animalvalue    = "Animal value ($)",
  animalprod     = "Animal production rate (S/day)",
  carcassweight  = "Carcass weight (kg)",
  feedintakekgd  = "Feed intake (kg/day)"
)

# Test data for comprehensive testing
test_data <- data.frame(
  eid = 1:100,
  date = seq(as.Date("2023-01-01"), as.Date("2023-12-31"), length.out = 100),
  breed = rep(c("Angus", "Hereford", "Charolais"), length.out = 100),
  treatment = rep(c("Control", "Treatment A", "Treatment B"), length.out = 100),
  mob = rep(c("Mob1", "Mob2", "Mob3"), length.out = 100),
  sex = rep(c("Male", "Female"), length.out = 100),
  finalpweight = rnorm(100, 500, 50),
  finalgrowthpbs = rnorm(100, 1.5, 0.3),
  methane = rnorm(100, 200, 30),
  animalvalue = rnorm(100, 1000, 200),
  animalprod = rnorm(100, 50, 10),
  carcassweight = rnorm(100, 300, 40),
  feedintakekgd = rnorm(100, 8, 1.5)
)

# Create test_measure_units for tests
test_measure_units <- measure_units
