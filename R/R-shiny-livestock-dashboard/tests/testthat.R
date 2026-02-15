# Setup for tests
library(testthat)
library(dplyr)
library(ggplot2)
library(plotly)

# ---- Test data ----
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

# Mock measure_units for testing
test_measure_units <- list(
  finalpweight = "kg",
  finalgrowthpbs = "kg/day",
  methane = "g/day",
  animalvalue = "$",
  animalprod = "units",
  carcassweight = "kg",
  feedintakekgd = "kg/day"
)

# ---- Source functions under test ----
src_files <- c("filter.R", "graph.R", "customise.R", "summary_stats.R")
for (f in src_files) {
  # Absolute path to src/
  fpath <- normalizePath(file.path("src", f), winslash = "/", mustWork = TRUE)
  source(fpath, local = TRUE)
}

# ---- Define minimal globals if missing ----
if (!exists("measure_choices")) {
  measure_choices <- c(
    "finalpweight", "finalgrowthpbs", "methane", 
    "animalvalue", "animalprod", "carcassweight", "feedintakekgd"
  )
}

if (!exists("measure_units")) {
  measure_units <- list(
    finalpweight = "kg",
    finalgrowthpbs = "kg/day", 
    methane = "g/day",
    animalvalue = "$",
    animalprod = "units",
    carcassweight = "kg",
    feedintakekgd = "kg/day"
  )
}

if (!exists("theme")) {
  library(bslib)
  theme <- bs_theme(version = 5, bootswatch = "flatly")
}