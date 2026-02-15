# ===================================================
# Revert Farm
# ===================================================
# Restore a farm's database from a previous backup
# ===================================================

source("admin_scripts/farm_utils.R")

cat("\n")
cat("=======================================\n")
cat("  REVERT FARM FROM BACKUP\n")
cat("=======================================\n")
cat("\n")

# Load farm configuration
farms <- load_farms_config()

# Display available farms with backup counts
cat("Available farms:\n")
for (i in 1:nrow(farms)) {
  backups <- list_farm_backups(farms$farm_id[i])
  backup_count <- nrow(backups)
  cat(sprintf("  %d. %s (%s) - %d backup(s) available\n",
              i, farms$farm_name[i], farms$farm_id[i], backup_count))
}
cat("\n")

# Get farm selection
cat(sprintf("Select farm to revert (1-%d): ", nrow(farms)))
selection <- readLines(file("stdin"), n = 1)
selection <- as.integer(selection)

if (is.na(selection) || selection < 1 || selection > nrow(farms)) {
  cat("\nInvalid selection. Cancelled.\n\n")
  quit(status = 1)
}

farm_id <- farms$farm_id[selection]
farm <- get_farm_by_id(farm_id)

cat(sprintf("\nSelected: %s (%s)\n\n", farm$farm_name, farm_id))

# List backups for this farm
backups <- list_farm_backups(farm_id)

if (nrow(backups) == 0) {
  cat(sprintf("No backups found for %s\n", farm$farm_name))
  cat(sprintf("Backup directory: farm_backups/%s/\n\n", farm_id))
  quit(status = 1)
}

# Display backups
cat(sprintf("Available backups for %s:\n", farm$farm_name))
cat("=======================================\n")
for (i in 1:nrow(backups)) {
  cat(sprintf("\n%d. %s\n", backups$number[i], backups$file[i]))
  cat(sprintf("   Date: %s\n", backups$date[i]))
  cat(sprintf("   Size: %.2f MB\n", backups$size_mb[i]))
  cat(sprintf("   Modified: %s\n", backups$modified[i]))

  # Try to get record count
  record_count <- get_record_count(backups$full_path[i])
  if (!is.na(record_count)) {
    cat(sprintf("   Records: %s\n", format(record_count, big.mark = ",")))
  }
}
cat("\n=======================================\n")

# Get backup selection
cat(sprintf("\nSelect backup to restore (1-%d, or 0 to cancel): ", nrow(backups)))
backup_choice <- readLines(file("stdin"), n = 1)
backup_choice <- as.integer(backup_choice)

if (is.na(backup_choice) || backup_choice == 0) {
  cat("\nCancelled.\n\n")
  quit(status = 0)
}

if (backup_choice < 1 || backup_choice > nrow(backups)) {
  cat("\nInvalid selection. Cancelled.\n\n")
  quit(status = 1)
}

selected_backup <- backups[backups$number == backup_choice, ]
cat(sprintf("\nSelected: %s\n", selected_backup$file))

# Show current vs backup comparison
current_db <- get_farm_db_path(farm_id)
current_records <- get_record_count(current_db)
backup_records <- get_record_count(selected_backup$full_path)

cat("\n")
cat("=======================================\n")
cat("  COMPARISON\n")
cat("=======================================\n")

if (!is.na(current_records)) {
  cat(sprintf("Current database: %s records\n", format(current_records, big.mark = ",")))
} else {
  cat("Current database: Unable to read\n")
}

if (!is.na(backup_records)) {
  cat(sprintf("Backup database: %s records\n", format(backup_records, big.mark = ",")))
  if (!is.na(current_records)) {
    diff <- backup_records - current_records
    cat(sprintf("Change: %+d records\n", diff))
  }
} else {
  cat("Backup database: Unable to read\n")
}

cat("\n")
cat("=======================================\n")
cat("  [WARNING] [WARNING]\n")
cat("=======================================\n")
cat("This will REPLACE your current database!\n")
cat("\n")
cat("A safety backup will be created first:\n")
cat(sprintf("  %s_before_revert_%s.duckdb\n",
            farm_id, format(Sys.time(), "%Y%m%d_%H%M%S")))
cat("\n")

cat("Are you sure you want to continue? (y/n): ")
confirm <- tolower(trimws(readLines(file("stdin"), n = 1)))

if (confirm != "y") {
  cat("\nRevert cancelled.\n\n")
  quit(status = 0)
}

cat("\n")
cat("=======================================\n")
cat(sprintf(" Reverting %s\n", farm$farm_name))
cat("=======================================\n")

tryCatch({
  # Create safety backup of current database
  cat("Creating safety backup of current database...\n")
  safety_backup_dir <- file.path("farm_backups", farm_id)
  if (!dir.exists(safety_backup_dir)) {
    dir.create(safety_backup_dir, recursive = TRUE)
  }

  safety_backup <- file.path(safety_backup_dir,
                            paste0(farm_id, "_before_revert_",
                                  format(Sys.time(), "%Y%m%d_%H%M%S"), ".duckdb"))
  file.copy(current_db, safety_backup)
  cat(sprintf("Safety backup created: %s\n\n", basename(safety_backup)))

  # Restore from backup
  cat("Restoring from backup...\n")
  file.copy(selected_backup$full_path, current_db, overwrite = TRUE)

  # Verify restoration
  restored_records <- get_record_count(current_db)
  cat(sprintf("Database restored successfully\n"))
  if (!is.na(restored_records)) {
    cat(sprintf("  Records in restored database: %s\n\n", format(restored_records, big.mark = ",")))
  }

  # Ask about deployment
  cat("Deploy restored database to shinyapps.io? (y/n): ")
  deploy_choice <- tolower(readLines(file("stdin"), n = 1))

  if (deploy_choice == "y" || deploy_choice == "yes") {
    if (!check_rsconnect_configured()) {
      cat("\nDatabase reverted locally but not deployed.\n")
      cat("Configure rsconnect and deploy manually.\n\n")
      quit(status = 1)
    }

    cat("\n")
    deploy_result <- deploy_farm(farm_id)

    if (deploy_result) {
      cat("\n")
      cat("=======================================\n")
      cat("  REVERT COMPLETE\n")
      cat("=======================================\n")
      cat(sprintf("%s reverted and deployed successfully!\n", farm$farm_name))
      cat(sprintf("Dashboard URL: https://yourteam.shinyapps.io/%s/\n\n", farm$app_name))
    } else {
      cat("\nDatabase reverted locally but deployment failed.\n")
      cat("You can try deploying manually later.\n\n")
      quit(status = 1)
    }
  } else {
    cat("\n")
    cat("=======================================\n")
    cat("  REVERT COMPLETE (LOCAL ONLY)\n")
    cat("=======================================\n")
    cat("Database has been reverted locally.\n")
    cat("Live dashboard NOT updated.\n\n")
    cat("To deploy: Run admin panel and choose 'Deploy Code Changes'\n\n")
  }

}, error = function(e) {
  cat(sprintf("\n[ERROR] %s\n\n", e$message))
  if (exists("safety_backup") && file.exists(safety_backup)) {
    cat(sprintf("Your original database is safe in:\n  %s\n\n", safety_backup))
  }
  quit(status = 1)
})
