# ===================================================
# Farm Management Utilities
# ===================================================
# Shared functions used by all farm management scripts
# ===================================================

options(warn = -1)

# Required packages
required_packages <- c("DBI", "duckdb", "readr", "rsconnect", "dplyr")
missing_packages <- required_packages[!required_packages %in% installed.packages()[, "Package"]]

if (length(missing_packages) > 0) {
  cat("Installing required packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, repos = "https://cran.rstudio.com/", quiet = TRUE)
}

suppressPackageStartupMessages({
  library(DBI)
  library(duckdb)
  library(readr)
  library(rsconnect)
  library(dplyr)
})

# Load farm configuration
load_farms_config <- function() {
  if (!file.exists("farms.csv")) {
    stop("farms.csv not found. Please create farm configuration file.")
  }

  farms <- read_csv("farms.csv", show_col_types = FALSE)

  # Validate required columns
  required_cols <- c("farm_id", "farm_name", "app_name")
  missing_cols <- setdiff(required_cols, names(farms))

  if (length(missing_cols) > 0) {
    stop("farms.csv is missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  return(farms)
}

# Get farm by ID
get_farm_by_id <- function(farm_id) {
  farms <- load_farms_config()
  farm <- farms[farms$farm_id == farm_id, ]

  if (nrow(farm) == 0) {
    stop("Farm ID '", farm_id, "' not found in farms.csv")
  }

  return(as.list(farm[1, ]))
}

# Get database path for farm
get_farm_db_path <- function(farm_id, must_exist = TRUE) {
  db_path <- file.path("farm_databases", paste0(farm_id, "_data.duckdb"))

  if (must_exist && !file.exists(db_path)) {
    stop("Database not found for farm '", farm_id, "': ", db_path)
  }

  return(db_path)
}

# Check if farm database exists
farm_db_exists <- function(farm_id) {
  db_path <- file.path("farm_databases", paste0(farm_id, "_data.duckdb"))
  return(file.exists(db_path))
}

# Helper function to parse dates with validation and fallback
parse_date_column <- function(date_vector, col_name = "date") {
  # Try DD/MM/YYYY format first (common in Australian exports)
  parsed <- as.Date(date_vector, format = "%d/%m/%Y")

  # If all failed, try ISO format (YYYY-MM-DD)
  if (all(is.na(parsed)) && !all(is.na(date_vector))) {
    parsed <- as.Date(date_vector, format = "%Y-%m-%d")
  }

  # If still failing, try MM/DD/YYYY
  if (all(is.na(parsed)) && !all(is.na(date_vector))) {
    parsed <- as.Date(date_vector, format = "%m/%d/%Y")
  }

  # Check for parsing failures
  failed_count <- sum(is.na(parsed) & !is.na(date_vector))
  if (failed_count > 0) {
    warning(sprintf("Failed to parse %d date values in '%s' column. Supported formats: DD/MM/YYYY, YYYY-MM-DD, MM/DD/YYYY",
                    failed_count, col_name))
  }

  # If ALL dates failed to parse, that's a critical error
  if (all(is.na(parsed)) && !all(is.na(date_vector))) {
    stop(sprintf("Could not parse any dates in '%s' column. Please use DD/MM/YYYY, YYYY-MM-DD, or MM/DD/YYYY format.", col_name))
  }

  return(parsed)
}

# Create new farm database from CSV file
create_farm_database <- function(farm_id, csv_file) {
  # Ensure farm_databases directory exists
  if (!dir.exists("farm_databases")) {
    dir.create("farm_databases")
  }

  db_path <- get_farm_db_path(farm_id, must_exist = FALSE)

  if (file.exists(db_path)) {
    stop("Database already exists for farm '", farm_id, "': ", db_path)
  }

  cat(sprintf("Creating new database for %s...\n", farm_id))

  # Read CSV data
  data <- read_csv(csv_file, show_col_types = FALSE)

  # Validate required columns
  required_cols <- c("EID", "Date")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("CSV is missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  # Convert Date column to proper date type (critical for EXTRACT queries)
  # Handle both "Date" and "date" column names
  date_col <- if ("Date" %in% names(data)) "Date" else if ("date" %in% names(data)) "date" else NULL
  if (!is.null(date_col)) {
    # Parse dates with validation and multiple format support
    data[[date_col]] <- parse_date_column(data[[date_col]], date_col)
  }

  # Convert all column names to lowercase to match app expectations
  names(data) <- tolower(names(data))

  cat(sprintf("  Creating database with %d initial records\n", nrow(data)))

  # Create database and table
  con <- dbConnect(duckdb(db_path))

  tryCatch({
    # Create table from data
    dbWriteTable(con, "animal_data", data, overwrite = TRUE)

    # Create indexes on frequently filtered columns
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_eid ON animal_data(eid)")
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_date ON animal_data(date)")
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_breed ON animal_data(breed)")
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_treatment ON animal_data(treatment)")
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_mob ON animal_data(mob)")
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_sex ON animal_data(sex)")

    # Analyze table for query optimization
    dbExecute(con, "ANALYZE animal_data")

    dbDisconnect(con, shutdown = TRUE)

    cat(sprintf("  Database created: %s (%.2f MB)\n",
                basename(db_path),
                file.info(db_path)$size / 1024^2))

    return(db_path)

  }, error = function(e) {
    dbDisconnect(con, shutdown = TRUE)
    if (file.exists(db_path)) {
      file.remove(db_path)
    }
    stop("Error creating database: ", e$message)
  })
}

# Create backup for farm
create_farm_backup <- function(farm_id) {
  # Ensure backup directory exists
  backup_dir <- file.path("farm_backups", farm_id)
  if (!dir.exists(backup_dir)) {
    dir.create(backup_dir, recursive = TRUE)
  }

  # Create dated backup
  backup_date <- format(Sys.Date(), "%Y%m%d")
  backup_name <- file.path(backup_dir, paste0(farm_id, "_backup_", backup_date, ".duckdb"))

  # Get source database
  source_db <- get_farm_db_path(farm_id)

  # Check if backup already exists for today, create numbered backup if needed
  if (file.exists(backup_name)) {
    counter <- 1
    base_name <- file.path(backup_dir, paste0(farm_id, "_backup_", backup_date))

    repeat {
      numbered_backup <- paste0(base_name, "(", counter, ").duckdb")
      if (!file.exists(numbered_backup)) {
        backup_name <- numbered_backup
        break
      }
      counter <- counter + 1
    }
  }

  # Create backup
  file.copy(source_db, backup_name)

  cat(sprintf("Backup created: %s (%.2f MB)\n",
              basename(backup_name),
              file.info(backup_name)$size / 1024^2))

  return(backup_name)
}

# List backups for farm
list_farm_backups <- function(farm_id) {
  backup_dir <- file.path("farm_backups", farm_id)

  if (!dir.exists(backup_dir)) {
    return(data.frame())
  }

  backup_files <- list.files(backup_dir,
                             pattern = paste0(farm_id, "_backup_.*\\.duckdb$"),
                             full.names = TRUE)

  if (length(backup_files) == 0) {
    return(data.frame())
  }

  # Get backup info
  backup_info <- data.frame(
    number = seq_along(backup_files),
    file = basename(backup_files),
    date = sub(paste0(farm_id, "_backup_(\\d{8})\\.duckdb"), "\\1", basename(backup_files)),
    size_mb = sapply(backup_files, function(f) file.info(f)$size / 1024^2),
    modified = sapply(backup_files, function(f) format(file.info(f)$mtime, "%Y-%m-%d %H:%M:%S")),
    full_path = backup_files,
    stringsAsFactors = FALSE
  )

  # Sort by date (newest first)
  backup_info <- backup_info[order(backup_info$date, decreasing = TRUE), ]
  backup_info$number <- seq_len(nrow(backup_info))

  return(backup_info)
}

# Get database record count
get_record_count <- function(db_path) {
  tryCatch({
    con <- dbConnect(duckdb(db_path))
    count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM animal_data")$n
    dbDisconnect(con, shutdown = TRUE)
    return(count)
  }, error = function(e) {
    return(NA)
  })
}

# Check for duplicates without updating
check_farm_duplicates <- function(farm_id, csv_file) {
  # Check if database exists - new farms can't have duplicates
  if (!farm_db_exists(farm_id)) {
    return(list(has_duplicates = FALSE, duplicate_count = 0, is_new_farm = TRUE))
  }

  db_path <- get_farm_db_path(farm_id)

  # Read new data
  new_data <- tryCatch({
    read_csv(csv_file, show_col_types = FALSE)
  }, error = function(e) {
    return(list(has_duplicates = FALSE, duplicate_count = 0, error = e$message))
  })

  if (is.list(new_data) && !is.data.frame(new_data)) {
    return(new_data)  # Return error info
  }

  if (nrow(new_data) == 0) {
    return(list(has_duplicates = FALSE, duplicate_count = 0))
  }

  # Validate required columns
  if (!all(c("EID", "Date") %in% names(new_data))) {
    return(list(has_duplicates = FALSE, duplicate_count = 0, error = "Missing EID or Date columns"))
  }

  # Convert column names to lowercase to match database schema
  names(new_data) <- tolower(names(new_data))

  # Connect to database
  con <- dbConnect(duckdb(db_path))

  tryCatch({
    # Create temporary table
    dbWriteTable(con, "temp_check_data", new_data, overwrite = TRUE, temporary = TRUE)

    # Check for duplicates
    duplicate_check <- dbGetQuery(con, "
      SELECT COUNT(*) as duplicate_count
      FROM temp_check_data t
      WHERE EXISTS (
        SELECT 1
        FROM animal_data a
        WHERE a.eid = t.eid AND a.date = t.date
      )
    ")

    duplicate_count <- duplicate_check$duplicate_count

    dbDisconnect(con, shutdown = TRUE)

    return(list(
      has_duplicates = duplicate_count > 0,
      duplicate_count = duplicate_count
    ))

  }, error = function(e) {
    dbDisconnect(con, shutdown = TRUE)
    return(list(has_duplicates = FALSE, duplicate_count = 0, error = e$message))
  })
}

# Update farm database from CSV
update_farm_database <- function(farm_id, csv_file, duplicate_action = "skip") {
  db_path <- get_farm_db_path(farm_id)

  # Read new data
  new_data <- read_csv(csv_file, show_col_types = FALSE)

  if (nrow(new_data) == 0) {
    stop("CSV file is empty")
  }

  # Validate required columns
  if (!all(c("EID", "Date") %in% names(new_data))) {
    stop("CSV must contain 'EID' and 'Date' columns")
  }

  # Convert Date column to proper date type (critical for EXTRACT queries)
  # Handle both "Date" and "date" column names
  date_col <- if ("Date" %in% names(new_data)) "Date" else if ("date" %in% names(new_data)) "date" else NULL
  if (!is.null(date_col)) {
    # Parse dates with validation and multiple format support
    new_data[[date_col]] <- parse_date_column(new_data[[date_col]], date_col)
  }

  # Convert all column names to lowercase to match app expectations
  names(new_data) <- tolower(names(new_data))

  # Connect to database
  con <- dbConnect(duckdb(db_path))

  tryCatch({
    # Create temporary table
    dbWriteTable(con, "temp_new_data", new_data, overwrite = TRUE, temporary = TRUE)

    # Check for duplicates
    duplicate_check <- dbGetQuery(con, "
      SELECT COUNT(*) as duplicate_count
      FROM temp_new_data t
      WHERE EXISTS (
        SELECT 1
        FROM animal_data a
        WHERE a.eid = t.eid AND a.date = t.date
      )
    ")

    duplicate_count <- duplicate_check$duplicate_count
    before_count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM animal_data")$n

    if (duplicate_count > 0) {
      cat(sprintf("Found %d duplicate records (same eid + date)\n", duplicate_count))

      if (duplicate_action == "skip") {
        cat("Skipping duplicates (only adding new records)...\n")
        dbExecute(con, "
          INSERT INTO animal_data
          SELECT t.*
          FROM temp_new_data t
          WHERE NOT EXISTS (
            SELECT 1
            FROM animal_data a
            WHERE a.eid = t.eid AND a.date = t.date
          )
        ")
      } else if (duplicate_action == "overwrite") {
        cat("Overwriting duplicates...\n")
        dbExecute(con, "
          DELETE FROM animal_data
          WHERE EXISTS (
            SELECT 1
            FROM temp_new_data t
            WHERE animal_data.eid = t.eid AND animal_data.date = t.date
          )
        ")
        dbExecute(con, "INSERT INTO animal_data SELECT * FROM temp_new_data")
      }
    } else {
      cat("No duplicates found. Adding all records...\n")
      dbExecute(con, "INSERT INTO animal_data SELECT * FROM temp_new_data")
    }

    after_count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM animal_data")$n
    rows_added <- after_count - before_count

    dbDisconnect(con, shutdown = TRUE)

    return(list(
      before_count = before_count,
      after_count = after_count,
      rows_added = rows_added,
      duplicates = duplicate_count
    ))

  }, error = function(e) {
    dbDisconnect(con, shutdown = TRUE)
    stop("Database update error: ", e$message)
  })
}

# Deploy farm to shinyapps.io
deploy_farm <- function(farm_id, quiet = FALSE) {
  farm <- get_farm_by_id(farm_id)

  if (!quiet) {
    cat(sprintf("\nDeploying %s to shinyapps.io/%s...\n", farm$farm_name, farm$app_name))
  }

  # Create temporary deployment directory
  temp_dir <- tempfile(pattern = paste0(farm_id, "_"))
  dir.create(temp_dir)

  tryCatch({
    # Copy app files
    file.copy("src", temp_dir, recursive = TRUE)

    # IMPORTANT: Remove the local dev database to avoid any confusion
    local_db <- file.path(temp_dir, "src", "data.duckdb")
    if (file.exists(local_db)) {
      file.remove(local_db)
    }

    # Copy farm-specific logos if they exist
    farm_logos_dir <- file.path("farm_logos", farm_id)
    if (dir.exists(farm_logos_dir)) {
      # Clear existing logos in temp directory
      temp_logo_dir <- file.path(temp_dir, "src", "logo")
      if (dir.exists(temp_logo_dir)) {
        unlink(temp_logo_dir, recursive = TRUE)
      }
      dir.create(temp_logo_dir, recursive = TRUE)

      # Copy farm-specific logos
      logo_files <- list.files(farm_logos_dir, pattern = "\\.(png|jpg|jpeg|svg)$", ignore.case = TRUE, full.names = TRUE)
      if (length(logo_files) > 0) {
        file.copy(logo_files, temp_logo_dir)
        if (!quiet) {
          cat(sprintf("  Copied %d logo(s) from %s\n", length(logo_files), farm_logos_dir))
        }
      } else {
        if (!quiet) {
          cat(sprintf("  Warning: No logos found in %s\n", farm_logos_dir))
        }
      }
    } else {
      if (!quiet) {
        cat(sprintf("  Note: No logos directory for %s (using default logos)\n", farm_id))
      }
    }

    # Copy farm-specific data database (ensures ONLY farm data is deployed)
    farm_db <- get_farm_db_path(farm_id)
    target_db <- file.path(temp_dir, "src", "data.duckdb")

    copy_success <- file.copy(farm_db, target_db, overwrite = FALSE)
    if (!copy_success) {
      stop(sprintf("Failed to copy database. Target may already exist: %s", target_db))
    }

    # Verify the correct database is in place
    deployed_db <- target_db
    deployed_db_size <- file.info(deployed_db)$size
    farm_db_size <- file.info(farm_db)$size

    if (deployed_db_size != farm_db_size) {
      stop(sprintf("Database file size mismatch!\nExpected: %.2f MB\nGot: %.2f MB\nDeployment cancelled to prevent wrong data.",
                   farm_db_size / 1024^2, deployed_db_size / 1024^2))
    }

    # Verify record count matches
    deployed_con <- dbConnect(duckdb(deployed_db))
    deployed_records <- dbGetQuery(deployed_con, "SELECT COUNT(*) as n FROM animal_data")$n
    dbDisconnect(deployed_con, shutdown = TRUE)

    if (!quiet) {
      cat(sprintf("  Verified: %s records from %s (%.2f MB)\n",
                  format(deployed_records, big.mark = ","),
                  basename(farm_db),
                  farm_db_size / 1024^2))
    }

    # Deploy with retry logic for timeouts
    max_retries <- 3
    deploy_success <- FALSE
    last_error <- NULL

    for (attempt in 1:max_retries) {
      if (attempt > 1) {
        if (!quiet) {
          cat(sprintf("  Retry %d/%d (waiting 10 seconds)...\n", attempt - 1, max_retries - 1))
        }
        Sys.sleep(10)  # Wait 10 seconds between retries
      }

      tryCatch({
        deployApp(
          appDir = file.path(temp_dir, "src"),
          appName = farm$app_name,
          appTitle = farm$farm_name,
          forceUpdate = TRUE,
          launch.browser = FALSE,
          lint = FALSE,
          metadata = list(asMultiple = FALSE, asStatic = FALSE),
          logLevel = if (quiet) "quiet" else "normal",
          appFiles = c(
            "global.R", "ui.R", "server.R",
            "filter.R", "timeseries_page.R", "distribution.R",
            "cohorts_page.R", "customise.R", "summary_stats.R",
            "report_page.R", "email_automation.R", "report_generator.R",
            "background_email_scheduler.R",
            "data.duckdb", "credentials.duckdb",
            "logo"
          )
        )

        deploy_success <- TRUE
        break  # Success, exit retry loop

      }, error = function(e) {
        last_error <<- e$message

        # Check if it's a timeout error
        is_timeout <- grepl("timeout|Timeout", e$message, ignore.case = TRUE)

        if (is_timeout && attempt < max_retries) {
          # Will retry
          if (!quiet) {
            cat(sprintf("  [WARNING] Timeout error (attempt %d/%d)\n", attempt, max_retries))
          }
        } else {
          # Won't retry or not a timeout
          if (attempt >= max_retries) {
            if (!quiet) {
              cat(sprintf("  [FAILED] Failed after %d attempts\n", max_retries))
            }
          }
        }
      })

      if (deploy_success) break
    }

    if (!deploy_success) {
      stop(last_error)
    }

    # Clean up
    unlink(temp_dir, recursive = TRUE)

    if (!quiet) {
      cat(sprintf("%s deployed successfully\n", farm$farm_name))
    }

    return(TRUE)

  }, error = function(e) {
    unlink(temp_dir, recursive = TRUE)
    if (!quiet) {
      cat(sprintf("[FAILED] Deployment failed: %s\n", e$message))
    }
    return(FALSE)
  })
}

# Deploy multiple farms (sequential or parallel)
deploy_farms <- function(farm_ids, batch_size = 5, parallel = TRUE) {
  n_farms <- length(farm_ids)

  # Smart detection: Use sequential for single farm (no overhead)
  if (n_farms == 1 || !parallel) {
    cat(sprintf("Deploying %d farm(s) sequentially...\n\n", n_farms))

    results <- list()
    for (i in seq_along(farm_ids)) {
      farm_id <- farm_ids[i]
      farm <- get_farm_by_id(farm_id)

      cat(sprintf("[%d/%d] %s\n", i, n_farms, farm$farm_name))
      results[[farm_id]] <- deploy_farm(farm_id, quiet = FALSE)
      cat("\n")
    }

    return(results)
  }

  # Parallel deployment with batching
  cat(sprintf("Deploying %d farm(s) in parallel (batch size: %d)...\n\n", n_farms, batch_size))

  # Split farms into batches
  batches <- split(farm_ids, ceiling(seq_along(farm_ids) / batch_size))
  n_batches <- length(batches)

  all_results <- list()
  overall_start <- Sys.time()

  for (batch_num in seq_along(batches)) {
    batch_farms <- batches[[batch_num]]
    batch_size_actual <- length(batch_farms)

    cat("=======================================\n")
    cat(sprintf(" BATCH %d/%d (%d farms)\n", batch_num, n_batches, batch_size_actual))
    cat("=======================================\n")

    # Show which farms are in this batch
    for (farm_id in batch_farms) {
      farm <- get_farm_by_id(farm_id)
      cat(sprintf("  - %s\n", farm$farm_name))
    }
    cat("\n")

    batch_start <- Sys.time()

    # Deploy farms in parallel using mclapply (Unix) or parLapply (Windows)
    if (.Platform$OS.type == "unix") {
      # Use mclapply for Unix/Mac (more efficient)
      batch_results <- parallel::mclapply(batch_farms, function(farm_id) {
        deploy_farm(farm_id, quiet = TRUE)
      }, mc.cores = batch_size_actual)
      names(batch_results) <- batch_farms

    } else {
      # Use parLapply for Windows
      cl <- parallel::makeCluster(min(batch_size_actual, parallel::detectCores()))

      # Export necessary functions and variables to cluster
      parallel::clusterExport(cl, c("deploy_farm", "get_farm_by_id", "get_farm_db_path",
                                    "load_farms_config"), envir = environment())

      # Load required packages on each worker
      parallel::clusterEvalQ(cl, {
        suppressPackageStartupMessages({
          library(DBI)
          library(duckdb)
          library(readr)
          library(rsconnect)
          library(dplyr)
        })
      })

      batch_results <- parallel::parLapply(cl, batch_farms, function(farm_id) {
        deploy_farm(farm_id, quiet = TRUE)
      })
      names(batch_results) <- batch_farms

      parallel::stopCluster(cl)
    }

    batch_elapsed <- as.numeric(difftime(Sys.time(), batch_start, units = "secs"))

    # Report batch results
    cat(sprintf("\nBatch %d completed in %.1f seconds\n", batch_num, batch_elapsed))
    for (farm_id in batch_farms) {
      farm <- get_farm_by_id(farm_id)
      status <- if (batch_results[[farm_id]]) "" else "[FAILED]"
      cat(sprintf("  %s %s\n", status, farm$farm_name))
    }
    cat("\n")

    # Accumulate results
    all_results <- c(all_results, batch_results)
  }

  overall_elapsed <- as.numeric(difftime(Sys.time(), overall_start, units = "mins"))
  cat(sprintf("Total deployment time: %.1f minutes\n\n", overall_elapsed))

  return(all_results)
}

# Check if rsconnect is configured
check_rsconnect_configured <- function() {
  accounts <- rsconnect::accounts()

  if (nrow(accounts) == 0) {
    cat("\n")
    cat("=======================================\n")
    cat("  RSCONNECT NOT CONFIGURED\n")
    cat("=======================================\n")
    cat("\n")
    cat("You need to configure shinyapps.io credentials.\n")
    cat("\n")
    cat("Steps:\n")
    cat("1. Go to https://www.shinyapps.io/admin/#/tokens\n")
    cat("2. Click 'Show' next to your token\n")
    cat("3. Click 'Show Secret'\n")
    cat("4. Copy the rsconnect::setAccountInfo(...) command\n")
    cat("5. Run that command in R\n")
    cat("6. Try this operation again\n")
    cat("\n")
    return(FALSE)
  }

  return(TRUE)
}
