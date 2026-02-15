# ===================================================
# Update All Farms Script
# ===================================================
# Updates databases and deploys for all farms with new CSV data
# ===================================================

source("admin_scripts/farm_utils.R")

# Start timer
start_time <- Sys.time()

cat("\n")
cat("=======================================\n")
cat("  UPDATE FARMS\n")
cat("=======================================\n")
cat("\n")

# Check rsconnect configuration
if (!check_rsconnect_configured()) {
  quit(status = 1)
}

# Load farm configuration
farms <- load_farms_config()
cat(sprintf("Loaded %d farm(s) from configuration\n\n", nrow(farms)))

# Scan for CSV files in data_upload
csv_files <- list.files("data_upload", pattern = "\\.csv$", full.names = FALSE)

if (length(csv_files) == 0) {
  cat("No CSV files found in data_upload/ folder\n")
  cat("Please place CSV files named: {farm_id}_YYYY-MM-DD.csv\n")
  cat("\n")
  quit(status = 0)
}

# Match CSV files to farms
farm_updates <- list()

for (csv_file in csv_files) {
  # Extract farm_id from filename (e.g., "FarmA_2025-01-22.csv" -> "FarmA")
  farm_id <- sub("_.*", "", csv_file)

  # Check if this farm exists in configuration
  if (farm_id %in% farms$farm_id) {
    farm_updates[[farm_id]] <- file.path("data_upload", csv_file)
  } else {
    cat(sprintf("WARNING: Skipping %s (farm ID '%s' not in farms.csv)\n", csv_file, farm_id))
  }
}

if (length(farm_updates) == 0) {
  cat("\nNo valid CSV files found for configured farms\n")
  cat("CSV files must be named: {farm_id}_date.csv\n")
  cat("\nConfigured farm IDs:\n")
  for (i in 1:nrow(farms)) {
    cat(sprintf("  - %s (%s)\n", farms$farm_id[i], farms$farm_name[i]))
  }
  cat("\n")
  quit(status = 0)
}

# Show what will be updated
cat(sprintf("Found data for %d farm(s):\n", length(farm_updates)))
for (farm_id in names(farm_updates)) {
  farm_name <- farms$farm_name[farms$farm_id == farm_id]
  csv_file <- basename(farm_updates[[farm_id]])
  cat(sprintf("  %s (%s) - %s\n", farm_name, farm_id, csv_file))
}
cat("\n")

cat("Proceed with update? (y/n): ")
confirm <- tolower(readLines(file("stdin"), n = 1))

if (confirm != "y" && confirm != "yes") {
  cat("\nCancelled.\n\n")
  quit(status = 0)
}

cat("\n")

# Check for duplicates across all farms
cat("Checking for duplicate records...\n")
total_duplicates <- 0
farms_with_duplicates <- c()

for (farm_id in names(farm_updates)) {
  csv_file <- farm_updates[[farm_id]]
  dup_check <- check_farm_duplicates(farm_id, csv_file)

  if (dup_check$has_duplicates) {
    total_duplicates <- total_duplicates + dup_check$duplicate_count
    farms_with_duplicates <- c(farms_with_duplicates, farm_id)
  }
}

# Only ask for duplicate handling if duplicates were found
if (total_duplicates > 0) {
  cat(sprintf("\nFound %d duplicate record(s) across %d farm(s)\n",
              total_duplicates, length(farms_with_duplicates)))
  cat("\nHow should duplicates be handled?\n")
  cat("  1 = SKIP duplicates (only add new records)\n")
  cat("  2 = OVERWRITE duplicates (update existing with new values)\n")
  cat("\n")
  cat("Choice (1 or 2): ")
  choice <- readLines(file("stdin"), n = 1)

  if (choice == "1") {
    duplicate_action <- "skip"
    cat("\nWill skip duplicate records\n\n")
  } else if (choice == "2") {
    duplicate_action <- "overwrite"
    cat("\nWill overwrite duplicate records\n\n")
  } else {
    cat("\nInvalid choice. Cancelled.\n\n")
    quit(status = 1)
  }
} else {
  cat("No duplicates found. Proceeding with update...\n\n")
  duplicate_action <- "skip"  # Default action when no duplicates
}

# ===================================================
# PHASE 1: Setup/Update databases (sequential - safer)
# ===================================================

cat("=======================================\n")
cat("  PHASE 1: Setup/Update Databases\n")
cat("=======================================\n")
cat("\n")

db_update_results <- list()
farms_to_deploy <- c()
new_farms <- c()

for (farm_id in names(farm_updates)) {
  farm <- get_farm_by_id(farm_id)
  csv_file <- farm_updates[[farm_id]]

  cat(sprintf("[%s] %s\n", farm_id, farm$farm_name))

  tryCatch({
    # Check if this is a NEW farm (database doesn't exist yet)
    if (!farm_db_exists(farm_id)) {
      cat("  NEW FARM DETECTED - Creating database...\n")
      create_farm_database(farm_id, csv_file)

      # Get record count from newly created database
      total_records <- get_record_count(get_farm_db_path(farm_id))

      db_update_results[[farm_id]] <- list(
        status = "success",
        rows_added = total_records,
        total_records = total_records,
        is_new = TRUE
      )
      farms_to_deploy <- c(farms_to_deploy, farm_id)
      new_farms <- c(new_farms, farm_id)

      cat(sprintf("  New farm database created with %d records\n", total_records))

    } else {
      # EXISTING farm - update database
      cat("  Existing farm - updating database...\n")

      # Create backup first
      cat("  Creating backup...\n")
      create_farm_backup(farm_id)

      # Update database
      cat(sprintf("  Updating from %s...\n", basename(csv_file)))
      update_result <- update_farm_database(farm_id, csv_file, duplicate_action)

      cat(sprintf("  Database updated\n"))
      cat(sprintf("    Records before: %d\n", update_result$before_count))
      cat(sprintf("    Records after: %d\n", update_result$after_count))
      cat(sprintf("    Net change: %+d\n", update_result$rows_added))

      db_update_results[[farm_id]] <- list(
        status = "success",
        rows_added = update_result$rows_added,
        total_records = update_result$after_count,
        is_new = FALSE
      )
      farms_to_deploy <- c(farms_to_deploy, farm_id)
    }

  }, error = function(e) {
    cat(sprintf("  [ERROR] %s\n", e$message))
    db_update_results[[farm_id]] <<- list(status = "error", message = e$message)
  })

  cat("\n")
}

# Show summary of new farms
if (length(new_farms) > 0) {
  cat("=======================================\n")
  cat(sprintf("  %d NEW FARM(S) CREATED!\n", length(new_farms)))
  cat("=======================================\n")
  for (farm_id in new_farms) {
    farm_name <- farms$farm_name[farms$farm_id == farm_id]
    cat(sprintf("  [NEW] %s (%s)\n", farm_name, farm_id))
  }
  cat("\n")
}

# ===================================================
# PHASE 2: Deploy to shinyapps.io (parallel)
# ===================================================

if (length(farms_to_deploy) == 0) {
  cat("No farms to deploy (all database updates failed)\n")
  quit(status = 1)
}

cat("=======================================\n")
cat("  PHASE 2: Deploying to shinyapps.io\n")
cat("=======================================\n")
cat("\n")

cat(sprintf("%d farm(s) ready for deployment\n\n", length(farms_to_deploy)))

# Check if we have any NEW farms
has_new_farms <- length(new_farms) > 0

if (has_new_farms) {
  cat("NEW FARMS DETECTED - Using sequential deployment for safety\n\n")
}

# Deploy using parallel deployment ONLY if no new farms
# New farms MUST be deployed sequentially to prevent data mixing
deploy_results <- deploy_farms(farms_to_deploy, batch_size = 5, parallel = !has_new_farms)

# Combine results
results <- list()
success_count <- 0
failed_count <- 0

for (farm_id in names(farm_updates)) {
  if (db_update_results[[farm_id]]$status == "error") {
    # Database update failed
    results[[farm_id]] <- db_update_results[[farm_id]]
    failed_count <- failed_count + 1
  } else if (!deploy_results[[farm_id]]) {
    # Deployment failed
    results[[farm_id]] <- list(
      status = "deploy_failed",
      rows_added = db_update_results[[farm_id]]$rows_added,
      total_records = db_update_results[[farm_id]]$total_records
    )
    failed_count <- failed_count + 1
  } else {
    # Success
    results[[farm_id]] <- list(
      status = "success",
      rows_added = db_update_results[[farm_id]]$rows_added,
      total_records = db_update_results[[farm_id]]$total_records
    )
    success_count <- success_count + 1
  }
}

# Archive processed CSV files
cat("=======================================\n")
cat(" Archiving CSV Files\n")
cat("=======================================\n")

if (!dir.exists("data_upload/archive")) {
  dir.create("data_upload/archive")
}

for (farm_id in names(farm_updates)) {
  csv_file <- farm_updates[[farm_id]]
  archive_name <- file.path("data_upload/archive",
                            sprintf("%s_%s",
                                   format(Sys.time(), "%Y%m%d_%H%M%S"),
                                   basename(csv_file)))
  file.rename(csv_file, archive_name)
  cat(sprintf("Archived: %s\n", basename(csv_file)))
}

# Summary
elapsed_time <- as.numeric(difftime(Sys.time(), start_time, units = "mins"))

cat("\n")
cat("=======================================\n")
cat("  UPDATE COMPLETE\n")
cat("=======================================\n")
cat(sprintf("Successfully updated: %d farm(s)\n", success_count))
cat(sprintf("Failed: %d farm(s)\n", failed_count))
cat(sprintf("Total time: %.1f minutes\n", elapsed_time))
cat("\n")

if (success_count > 0) {
  # Separate new farms from updated farms
  successful_new <- c()
  successful_updated <- c()

  for (farm_id in names(results)) {
    if (results[[farm_id]]$status == "success") {
      if (farm_id %in% new_farms) {
        successful_new <- c(successful_new, farm_id)
      } else {
        successful_updated <- c(successful_updated, farm_id)
      }
    }
  }

  if (length(successful_new) > 0) {
    cat("New farms deployed:\n")
    for (farm_id in successful_new) {
      farm_name <- farms$farm_name[farms$farm_id == farm_id]
      cat(sprintf("  [NEW] %s (%d initial records)\n", farm_name, results[[farm_id]]$total_records))
    }
    cat("\n")
  }

  if (length(successful_updated) > 0) {
    cat("Existing farms updated:\n")
    for (farm_id in successful_updated) {
      farm_name <- farms$farm_name[farms$farm_id == farm_id]
      cat(sprintf("  %s (%+d records)\n", farm_name, results[[farm_id]]$rows_added))
    }
    cat("\n")
  }
}

if (failed_count > 0) {
  cat("Failed farms:\n")
  for (farm_id in names(results)) {
    if (results[[farm_id]]$status != "success") {
      farm_name <- farms$farm_name[farms$farm_id == farm_id]
      cat(sprintf("  [FAILED] %s\n", farm_name))
    }
  }
  cat("\n")
}

cat("Backups saved in: farm_backups/\n")
cat("\n")
