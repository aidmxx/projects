# ===================================================
# Deploy Code Changes Script
# ===================================================
# Deploy code updates to all farms (no database changes)
# Use this when you've fixed a bug or added a feature
# ===================================================

source("admin_scripts/farm_utils.R")

cat("\n")
cat("=======================================\n")
cat("  DEPLOY CODE CHANGES TO ALL FARMS\n")
cat("=======================================\n")
cat("\n")

# Check rsconnect configuration
if (!check_rsconnect_configured()) {
  quit(status = 1)
}

# Load farm configuration
farms <- load_farms_config()

cat("This will deploy the current app code from src/ to ALL farms.\n")
cat("Each farm will keep its own database (data will NOT change).\n")
cat("\n")
cat(sprintf("Total farms to deploy: %d\n\n", nrow(farms)))

cat("Farms that will be updated:\n")
for (i in 1:nrow(farms)) {
  cat(sprintf("  %d. %s (%s)\n", i, farms$farm_name[i], farms$app_name[i]))
}
cat("\n")

cat("Proceed? (y/n): ")
confirm <- tolower(readLines(file("stdin"), n = 1))

if (confirm != "y" && confirm != "yes") {
  cat("\nCancelled.\n\n")
  quit(status = 0)
}

cat("\n")
cat("=======================================\n")
cat("  STARTING DEPLOYMENT\n")
cat("=======================================\n")
cat("\n")

# Deploy to all farms using parallel deployment
# Automatically uses sequential for 1 farm, parallel with batching for multiple
results <- deploy_farms(farms$farm_id, batch_size = 5, parallel = TRUE)

# Calculate summary
success_count <- sum(unlist(results))
failed_count <- length(results) - success_count
failed_farms <- c()

if (failed_count > 0) {
  for (farm_id in names(results)) {
    if (!results[[farm_id]]) {
      farm_name <- farms$farm_name[farms$farm_id == farm_id]
      failed_farms <- c(failed_farms, farm_name)
    }
  }
}

# Summary
cat("=======================================\n")
cat("  DEPLOYMENT COMPLETE\n")
cat("=======================================\n")
cat(sprintf("Successfully deployed: %d farm(s)\n", success_count))
cat(sprintf("Failed: %d farm(s)\n", failed_count))
cat("\n")

if (failed_count > 0) {
  cat("Failed farms:\n")
  for (farm_name in failed_farms) {
    cat(sprintf("  [FAILED] %s\n", farm_name))
  }
  cat("\n")
  cat("You can retry deploying failed farms individually.\n\n")
}

if (success_count > 0) {
  cat("All successfully deployed farms now have the latest code!\n\n")
}
