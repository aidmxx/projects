# ---- packages ----
library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(lubridate)
library(DT)
library(readr)
library(plotly)
library(shinymanager)
library(shinyWidgets)
library(rlang)
library(DBI)
library(duckdb)
library(openxlsx)
library(gridExtra)
library(blastula)
library(base64enc)
library(tidyr)
library(jsonlite)
library(rmarkdown)
library(scrypt)

Sys.setenv(TZ = "Australia/Sydney")

# Centralized filter and graph helpers
# Use absolute paths to avoid issues when sourcing from different directories
src_dir <- if (file.exists("filter.R")) {
  "."  # We're in the src directory
} else if (file.exists("src/filter.R")) {
  "src"  # We're in the project root
} else if (file.exists("../../src/filter.R")) {
  "../../src"  # We're in the tests/testthat directory
} else {
  # Try to find the src directory by looking for the project root
  current_dir <- getwd()
  if (grepl("tests/testthat", current_dir)) {
    "../../src"
  } else if (grepl("tests", current_dir)) {
    "../src"
  } else {
    "src"
  }
}

# Verify the directory exists
if (!dir.exists(src_dir)) {
  stop("Cannot find src directory. Current working directory: ", getwd())
}

# Add logo resource path only if directory exists
logo_dir <- file.path(src_dir, "logo")
if (dir.exists(logo_dir)) {
  tryCatch({
    addResourcePath("logo", logo_dir)
  }, error = function(e) {
    # Silently fail if addResourcePath has issues
    # This can happen during deployment if the directory structure is unusual
    warning("Could not add logo resource path: ", e$message)
  })
}

source(file.path(src_dir, "filter.R"), local = TRUE)
source(file.path(src_dir, "timeseries_page.R"), local = TRUE)
source(file.path(src_dir, "customise.R"), local = TRUE)
source(file.path(src_dir, "cohorts_page.R"), local = TRUE)

# ---- logo helper function ----
# Dynamically generate logo img tags from logo directory
generate_logo_tags <- function() {
  logo_dir <- file.path(src_dir, "logo")

  # Check if logo directory exists
  if (!dir.exists(logo_dir)) {
    return(list())
  }

  # Get all image files (png, jpg, jpeg, svg)
  logo_files <- list.files(
    logo_dir,
    pattern = "\\.(png|jpg|jpeg|svg)$",
    ignore.case = TRUE,
    full.names = FALSE
  )

  # Sort alphabetically for consistent ordering
  logo_files <- sort(logo_files)

  # Return empty list if no logos found
  if (length(logo_files) == 0) {
    return(list())
  }

  # Generate img tags for each logo
  logo_tags <- lapply(logo_files, function(filename) {
    tags$img(
      src = paste0("logo/", filename),
      height = 60,
      alt = "",
      class = "partner-logo"
    )
  })

  return(logo_tags)
}

# ---- theme ----
theme <- bs_theme(
  version = 5, bootswatch = "flatly",
  
  primary = "#1B4332", secondary = "#5C4033", success = "#2D6A4F",
  info = "#95A5A6", warning = "#B08968", danger = "#7B241C",
  
  "body-color" = "#40360c", "body_bg" = "#f4f5f6",
  "link-color" = "#8f892b", "headings-color" = "#40360c",
  
  base_font = font_google("Poppins"),
  heading_font = font_google("Poppins"),
  
  "border-radius" = "0.8rem",
  "border-radius-lg" = "1rem",
  "border-radius-sm" = ".5rem"
)

# ---- login page mods ----
set_labels(
  language = "en",
  "Please authenticate" = "Please Login"
)

# login system using duckdb with scrypt password hashing
check_credentials_duckdb <- function(credentials_con) {
  function(user, password) {
    # Query the credentials table in DuckDB (get user record)
    result <- dbGetQuery(credentials_con, "
      SELECT user, password, isAdmin
      FROM credentials
      WHERE user = ?
    ", params = list(user))

    # Check if user exists and verify password using scrypt
    if (nrow(result) > 0) {
      stored_hash <- result$password[1]

      # Verify password against stored hash
      if (scrypt::verifyPassword(stored_hash, password)) {
        return(list(
          result = TRUE,
          user_info = list(
            user = result$user[1],
            is_admin = result$isAdmin[1]
          )
        ))
      }
    }

    # Authentication failed
    return(list(result = FALSE))
  }
}

# ---- units map ----
measure_units <- list(
  finalpweight="kg",
  finalgrowthpbs="kg/day",
  methane="g/day",
  animalvalue="$",
  animalprod="units",
  carcassweight="kg",
  feedintakekgd="kg/day"
)

# Credentials database path resolution (shared by all farms)
credentials_db_path <- if (file.exists("src/credentials.duckdb")) {
  "src/credentials.duckdb"
} else if (file.exists("credentials.duckdb")) {
  "credentials.duckdb"
} else {
  # Check if we're in project root by looking for any .Rproj file
  rproj_files <- list.files(".", pattern = "\\.Rproj$", full.names = FALSE)
  if (length(rproj_files) > 0) {
    "src/credentials.duckdb"  # We're in project root
  } else {
    stop("Cannot find credentials.duckdb file. Please ensure you're running from the project root directory.")
  }
}

credentials_con <- dbConnect(
  duckdb(credentials_db_path),
  read_only = TRUE  # Read-only for security
)

# Farm data database path resolution (replaced during deployment)
data_db_path <- if (file.exists("src/data.duckdb")) {
  "src/data.duckdb"
} else if (file.exists("data.duckdb")) {
  "data.duckdb"
} else {
  # Check if we're in project root by looking for any .Rproj file
  rproj_files <- list.files(".", pattern = "\\.Rproj$", full.names = FALSE)
  if (length(rproj_files) > 0) {
    "src/data.duckdb"  # We're in project root
  } else {
    stop("Cannot find data.duckdb file. Please ensure you're running from the project root directory.")
  }
}

con <- dbConnect(
  duckdb(data_db_path),
  read_only = FALSE,
  config = list(
    "threads" = parallel::detectCores()
  )
)

# Create indexes on frequently filtered columns for faster queries
# Only create if they don't already exist
tryCatch({
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_eid ON animal_data(eid)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_date ON animal_data(date)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_breed ON animal_data(breed)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_treatment ON animal_data(treatment)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_mob ON animal_data(mob)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_sex ON animal_data(sex)")

  # Create email_schedules table for email automation
  # First create sequence if it doesn't exist
  dbExecute(con, "CREATE SEQUENCE IF NOT EXISTS email_schedules_id_seq")
  
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS email_schedules (
      id INTEGER PRIMARY KEY DEFAULT nextval('email_schedules_id_seq'),
      recipient_email VARCHAR(255) NOT NULL,
      schedule_name VARCHAR(255),
      frequency VARCHAR(50) NOT NULL, -- 'daily', 'weekly', 'monthly', 'once'
      send_time TIME NOT NULL,
      send_date DATE, -- for 'once' frequency
      day_of_week INTEGER, -- 1-7 for weekly (1=Monday)
      day_of_month INTEGER, -- 1-31 for monthly
      is_active BOOLEAN DEFAULT TRUE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      last_sent TIMESTAMP,
      email_subject VARCHAR(500),
      email_body TEXT,
      report_filters TEXT, -- Store filter parameters as JSON string
      created_by VARCHAR(100)
    )
  ")
  
  # Create indexes for email scheduling
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_email_schedules_active ON email_schedules(is_active)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_email_schedules_recipient ON email_schedules(recipient_email)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_email_schedules_time ON email_schedules(send_time)")

  # Update table statistics for optimal query planning
  dbExecute(con, "ANALYZE animal_data")
  dbExecute(con, "ANALYZE email_schedules")
}, error = function(e) {
  warning("Could not create indexes or analyze table: ", e$message)
})

# # Adds .duckdb file
# dbExecute(con, "
#   CREATE TABLE animal_data AS
#   SELECT
#     EID as eid,
#     Date as date,
#     Breed as breed,
#     Treatment as treatment,
#     Mob as mob,
#     Sex as sex,
#     FinalPWeight as finalpweight,
#     FinalGrowthPBS as finalgrowthpbs,
#     Methane as methane,
#     AnimalValue as animalvalue,
#     AnimalProd as animalprod,
#     CarcassWeight as carcassweight,
#     FeedIntakeKgd as feedintakekgd
#   FROM read_csv_auto('wowByrne_v2.csv', header = true)
# ")


# Optimized data loading with caching
load_data <- function(year = NULL, month = NULL, day = NULL,
                     sex = NULL, treatment = NULL, breed = NULL,
                     mob = NULL, eid = NULL, use_cache = TRUE) {
  
  # Build WHERE clause for SQL filtering
  where_conditions <- c()
  params <- list()
  param_idx <- 1

  if (!is.null(year)) {
    where_conditions <- c(where_conditions, "EXTRACT(YEAR FROM date) = ?")
    params[[param_idx]] <- year
    param_idx <- param_idx + 1
  }

  if (!is.null(month) && month != "All") {
    month_num <- match(month, month.name)
    if (!is.na(month_num)) {
      where_conditions <- c(where_conditions, "EXTRACT(MONTH FROM date) = ?")
      params[[param_idx]] <- month_num
      param_idx <- param_idx + 1
    }
  }

  if (!is.null(day) && day != "All") {
    where_conditions <- c(where_conditions, "EXTRACT(DAY FROM date) = ?")
    params[[param_idx]] <- as.integer(day)
    param_idx <- param_idx + 1
  }

  if (!is.null(sex) && length(sex) > 0 && !"Overall" %in% sex) {
    placeholders <- paste(rep("?", length(sex)), collapse = ", ")
    where_conditions <- c(where_conditions, paste0("sex IN (", placeholders, ")"))
    for (s in sex) {
      params[[param_idx]] <- s
      param_idx <- param_idx + 1
    }
  }

  if (!is.null(treatment) && length(treatment) > 0 && !"Overall" %in% treatment) {
    if ("No Treatment" %in% treatment) {
      non_null <- treatment[treatment != "No Treatment"]
      if (length(non_null) > 0) {
        placeholders <- paste(rep("?", length(non_null)), collapse = ", ")
        where_conditions <- c(where_conditions, paste0("(treatment IS NULL OR treatment IN (", placeholders, "))"))
        for (t in non_null) {
          params[[param_idx]] <- t
          param_idx <- param_idx + 1
        }
      } else {
        where_conditions <- c(where_conditions, "treatment IS NULL")
      }
    } else {
      placeholders <- paste(rep("?", length(treatment)), collapse = ", ")
      where_conditions <- c(where_conditions, paste0("treatment IN (", placeholders, ")"))
      for (t in treatment) {
        params[[param_idx]] <- t
        param_idx <- param_idx + 1
      }
    }
  }

  if (!is.null(breed) && length(breed) > 0 && !"Overall" %in% breed) {
    placeholders <- paste(rep("?", length(breed)), collapse = ", ")
    where_conditions <- c(where_conditions, paste0("breed IN (", placeholders, ")"))
    for (b in breed) {
      params[[param_idx]] <- b
      param_idx <- param_idx + 1
    }
  }

  if (!is.null(mob) && length(mob) > 0 && !"Overall" %in% mob) {
    placeholders <- paste(rep("?", length(mob)), collapse = ", ")
    where_conditions <- c(where_conditions, paste0("mob IN (", placeholders, ")"))
    for (m in mob) {
      params[[param_idx]] <- m
      param_idx <- param_idx + 1
    }
  }

  if (!is.null(eid) && length(eid) > 0 && !"Overall" %in% eid) {
    placeholders <- paste(rep("?", length(eid)), collapse = ", ")
    where_conditions <- c(where_conditions, paste0("eid IN (", placeholders, ")"))
    for (e in eid) {
      params[[param_idx]] <- e
      param_idx <- param_idx + 1
    }
  }

  # Build final SQL query
  sql <- "
    SELECT
      eid,
      date,
      breed,
      treatment,
      mob,
      sex,
      finalpweight,
      finalgrowthpbs,
      methane,
      animalvalue,
      animalprod,
      carcassweight,
      feedintakekgd
    FROM animal_data
  "

  if (length(where_conditions) > 0) {
    sql <- paste0(sql, " WHERE ", paste(where_conditions, collapse = " AND "))
  }

  # Execute query with parameters
  if (length(params) > 0) {
    data <- dbGetQuery(con, sql, params = params)
  } else {
    data <- dbGetQuery(con, sql)
  }

  # Convert date column to Date class
  if ("date" %in% names(data)) data$date <- as.Date(data$date)

  # Fill missing columns with default values
  if (!"sex" %in% names(data) || all(is.na(data$sex))) data$sex <- "Unknown"
  if (!"treatment" %in% names(data)) data$treatment <- "Unknown"
  if (!"mob" %in% names(data)) data$mob <- "Unknown"
  if (!"breed" %in% names(data)) data$breed <- "Unknown"

  return(data)
}

# Load data once and cache it
dat0 <- load_data()

# Pre-compute commonly used values using SQL queries instead of loading all data
dat0_cache <- list(
  years = sort(dbGetQuery(con, "SELECT DISTINCT EXTRACT(YEAR FROM date) as year FROM animal_data ORDER BY year")$year),
  months = c("All", month.name),
  days = c("All", 1:31),
  sexes = c("Overall", sort(dbGetQuery(con, "SELECT DISTINCT sex FROM animal_data WHERE sex IS NOT NULL ORDER BY sex")$sex)),
  treatments = c("Overall", "No Treatment", sort(dbGetQuery(con, "SELECT DISTINCT treatment FROM animal_data WHERE treatment IS NOT NULL ORDER BY treatment")$treatment)),
  breeds = c("Overall", sort(dbGetQuery(con, "SELECT DISTINCT breed FROM animal_data WHERE breed IS NOT NULL ORDER BY breed")$breed)),
  mobs = c("Overall", sort(dbGetQuery(con, "SELECT DISTINCT mob FROM animal_data WHERE mob IS NOT NULL ORDER BY mob")$mob)),
  eids = c("Overall", sort(dbGetQuery(con, "SELECT DISTINCT eid FROM animal_data WHERE eid IS NOT NULL ORDER BY eid")$eid)),
  max_year = dbGetQuery(con, "SELECT MAX(EXTRACT(YEAR FROM date)) as max_year FROM animal_data")$max_year
)

# to compute measure_choices without loading entire table
get_numeric_cols <- function(con, table, schema = "main") {
  q <- "
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = ? AND table_name = ?
    ORDER BY ordinal_position
  "
  types <- DBI::dbGetQuery(con, q, params = list(schema, table))

  is_num <- grepl(
    "TINYINT|SMALLINT|INTEGER|BIGINT|HUGEINT|UTINYINT|USMALLINT|UINTEGER|UBIGINT|REAL|DOUBLE|DECIMAL",
    toupper(types$data_type)
  )

  types$column_name[is_num]
}

measure_choices <- get_numeric_cols(con, "animal_data")

# Ensure database connections are properly closed when app stops
# This prevents connection leaks and ensures data integrity
onStop(function() {
  tryCatch({
    if (DBI::dbIsValid(con)) {
      DBI::dbDisconnect(con, shutdown = TRUE)
    }
  }, error = function(e) {
    warning("Error closing data database connection: ", e$message)
  })

  tryCatch({
    if (DBI::dbIsValid(credentials_con)) {
      DBI::dbDisconnect(credentials_con, shutdown = TRUE)
    }
  }, error = function(e) {
    warning("Error closing credentials database connection: ", e$message)
  })
})
