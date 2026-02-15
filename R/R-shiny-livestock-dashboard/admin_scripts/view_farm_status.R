# ===================================================
# View Farm Status Script
# ===================================================
# Display status information for all farms
# ===================================================

source("admin_scripts/farm_utils.R")

cat("\n")
cat("=======================================\n")
cat("  FARM STATUS OVERVIEW\n")
cat("=======================================\n")
cat("\n")

# Load farm configuration
farms <- load_farms_config()

cat(sprintf("Total Farms: %d\n\n", nrow(farms)))

for (i in 1:nrow(farms)) {
  farm_id <- farms$farm_id[i]
  farm_name <- farms$farm_name[i]
  app_name <- farms$app_name[i]

  cat("=======================================\n")
  cat(sprintf(" %s (%s)\n", farm_name, farm_id))
  cat("=======================================\n")

  # Database info
  db_path <- file.path("farm_databases", paste0(farm_id, "_data.duckdb"))

  if (file.exists(db_path)) {
    db_size <- file.info(db_path)$size / 1024^2
    db_modified <- format(file.info(db_path)$mtime, "%Y-%m-%d %H:%M:%S")
    record_count <- get_record_count(db_path)

    cat(sprintf("Database: %s\n", basename(db_path)))
    cat(sprintf("  Size: %.2f MB\n", db_size))
    cat(sprintf("  Modified: %s\n", db_modified))

    if (!is.na(record_count)) {
      cat(sprintf("  Records: %s\n", format(record_count, big.mark = ",")))
    } else {
      cat("  Records: Unable to read\n")
    }
  } else {
    cat("Database: NOT FOUND\n")
    cat(sprintf("  Expected: %s\n", db_path))
  }

  # Backup info
  backups <- list_farm_backups(farm_id)
  if (nrow(backups) > 0) {
    most_recent <- backups[1, ]  # Already sorted newest first
    cat(sprintf("\nBackups: %d available\n", nrow(backups)))
    cat(sprintf("  Most recent: %s\n", most_recent$file))
    cat(sprintf("  Date: %s\n", most_recent$date))
  } else {
    cat("\nBackups: None\n")
  }

  # Deployment info
  cat(sprintf("\nDeployment:\n"))
  cat(sprintf("  App name: %s\n", app_name))

  # Get rsconnect account info if available
  accounts <- tryCatch(rsconnect::accounts(), error = function(e) data.frame())
  if (nrow(accounts) > 0) {
    # Use actual account name from rsconnect
    account_name <- accounts$name[1]
    cat(sprintf("  URL: https://%s.shinyapps.io/%s/\n", account_name, app_name))
  } else {
    cat(sprintf("  App name: %s (rsconnect not configured)\n", app_name))
  }

  cat("\n")
}

cat("=======================================\n\n")

# Show CSV files waiting to be processed
csv_files <- list.files("data_upload", pattern = "\\.csv$", full.names = FALSE)

if (length(csv_files) > 0) {
  cat("CSV files in data_upload/ (ready to process):\n")
  for (csv_file in csv_files) {
    file_info <- file.info(file.path("data_upload", csv_file))
    cat(sprintf("  - %s (%.2f KB, %s)\n",
                csv_file,
                file_info$size / 1024,
                format(file_info$mtime, "%Y-%m-%d %H:%M")))
  }
  cat("\n")
} else {
  cat("No CSV files in data_upload/ (no updates pending)\n\n")
}
