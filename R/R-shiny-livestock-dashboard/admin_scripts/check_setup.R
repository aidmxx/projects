# ===================================================
# Setup Validation Script
# ===================================================
# Checks that the multi-farm system is configured correctly
# ===================================================

cat("\n")
cat("=======================================\n")
cat("  SETUP VALIDATION\n")
cat("=======================================\n")
cat("\n")

# Create required directories if they don't exist
cat("Creating/checking required directories...\n")
required_dirs <- c("data_upload", "data_upload/archive", "farm_databases", "farm_backups", "farm_logos")

for (dir in required_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat(sprintf("  Created: %s/\n", dir))
  } else {
    cat(sprintf("  Exists: %s/\n", dir))
  }
}

# Create farm-specific logo subdirectories based on farms.csv
if (file.exists("farms.csv")) {
  suppressMessages({
    farms_for_logos <- tryCatch({
      read.csv("farms.csv", stringsAsFactors = FALSE)
    }, error = function(e) {
      NULL
    })
  })

  if (!is.null(farms_for_logos) && "farm_id" %in% names(farms_for_logos)) {
    cat("\nCreating farm-specific logo directories...\n")
    for (farm_id in farms_for_logos$farm_id) {
      logo_dir <- file.path("farm_logos", farm_id)
      if (!dir.exists(logo_dir)) {
        dir.create(logo_dir, recursive = TRUE)
        cat(sprintf("  Created: %s/\n", logo_dir))
      } else {
        cat(sprintf("  Exists: %s/\n", logo_dir))
      }
    }
  }
}
cat("\n")

issues <- c()
warnings <- c()

# Check R packages
cat("Checking R packages...\n")
required_packages <- c("DBI", "duckdb", "readr", "rsconnect", "dplyr", "shiny",
                       "bslib", "ggplot2", "lubridate", "DT", "plotly",
                       "shinymanager", "shinyWidgets", "rlang", "openxlsx",
                       "gridExtra", "blastula", "base64enc", "tidyr", "RColorBrewer")

missing_packages <- required_packages[!required_packages %in% installed.packages()[, "Package"]]

if (length(missing_packages) > 0) {
  issues <- c(issues, sprintf("Missing R packages: %s", paste(missing_packages, collapse = ", ")))
} else {
  cat("All required packages installed\n")
}

# Check directory structure
cat("Checking additional directories...\n")

additional_dirs <- c("src", "admin_scripts")
for (dir in additional_dirs) {
  if (!dir.exists(dir)) {
    issues <- c(issues, sprintf("Missing directory: %s", dir))
  } else {
    cat(sprintf("%s/ exists\n", dir))
  }
}

# Check farms.csv
cat("\nChecking farms.csv...\n")

if (!file.exists("farms.csv")) {
  issues <- c(issues, "farms.csv not found")
} else {
  suppressMessages({
    farms <- tryCatch({
      read.csv("farms.csv", stringsAsFactors = FALSE)
    }, error = function(e) {
      issues <<- c(issues, paste("Cannot read farms.csv:", e$message))
      return(NULL)
    })
  })

  if (!is.null(farms)) {
    required_cols <- c("farm_id", "farm_name", "app_name")
    missing_cols <- setdiff(required_cols, names(farms))

    if (length(missing_cols) > 0) {
      issues <- c(issues, sprintf("farms.csv missing columns: %s",
                                 paste(missing_cols, collapse = ", ")))
    } else {
      cat(sprintf("farms.csv valid (%d farm(s) configured)\n", nrow(farms)))

      # Check each farm's database and logos
      for (i in 1:nrow(farms)) {
        farm_id <- farms$farm_id[i]
        db_path <- file.path("farm_databases", paste0(farm_id, "_data.duckdb"))

        if (!file.exists(db_path)) {
          warnings <- c(warnings,
                       sprintf("Database not found for farm '%s': %s", farm_id, db_path))
        }

        # Check for logo directory and files
        logo_dir <- file.path("farm_logos", farm_id)
        if (dir.exists(logo_dir)) {
          logo_files <- list.files(logo_dir, pattern = "\\.(png|jpg|jpeg|svg)$", ignore.case = TRUE)
          if (length(logo_files) == 0) {
            warnings <- c(warnings,
                         sprintf("No logo files found for farm '%s' in %s/", farm_id, logo_dir))
          }
        }
      }
    }
  }
}

# Check src/ directory contents
cat("\nChecking app files in src/...\n")

required_files <- c("global.R", "ui.R", "server.R", "filter.R")
for (file in required_files) {
  file_path <- file.path("src", file)
  if (!file.exists(file_path)) {
    issues <- c(issues, sprintf("Missing app file: %s", file_path))
  } else {
    cat(sprintf("%s exists\n", file))
  }
}

# Check rsconnect configuration
cat("\nChecking rsconnect configuration...\n")

suppressMessages({
  library(rsconnect)
})

accounts <- tryCatch({
  rsconnect::accounts()
}, error = function(e) {
  data.frame()
})

if (nrow(accounts) == 0) {
  warnings <- c(warnings,
               "rsconnect not configured. You won't be able to deploy to shinyapps.io.")
  cat("[WARNING] rsconnect NOT configured\n")
  cat("  Configure with: rsconnect::setAccountInfo(...)\n")
} else {
  cat(sprintf("rsconnect configured (account: %s)\n", accounts$name[1]))
}

# Check for pending CSV files
cat("\nChecking for pending data...\n")
csv_files <- list.files("data_upload", pattern = "\\.csv$", full.names = FALSE)

if (length(csv_files) > 0) {
  cat(sprintf("[WARNING] %d CSV file(s) in data_upload/ (ready to process)\n", length(csv_files)))
  for (csv in csv_files) {
    cat(sprintf("  - %s\n", csv))
  }
} else {
  cat("No pending CSV files\n")
}

# Summary
cat("\n")
cat("=======================================\n")
cat("  VALIDATION SUMMARY\n")
cat("=======================================\n")

if (length(issues) == 0 && length(warnings) == 0) {
  cat("\nSetup is valid! System ready to use.\n\n")
  cat("Next steps:\n")
  cat("  1. Configure rsconnect (if not done yet)\n")
  cat("  2. Add logos to farm_logos/{farm_id}/ directories\n")
  cat("  3. Place CSV files in data_upload/\n")
  cat("  4. Run admin_panel.bat\n\n")
} else {
  if (length(issues) > 0) {
    cat("\n[ERROR] ISSUES FOUND (must fix):\n")
    for (issue in issues) {
      cat(sprintf("  - %s\n", issue))
    }
    cat("\n")
  }

  if (length(warnings) > 0) {
    cat("\n[WARNING] WARNINGS (should address):\n")
    for (warning in warnings) {
      cat(sprintf("  - %s\n", warning))
    }
    cat("\n")
  }

  if (length(issues) > 0) {
    cat("Fix the issues above before using the admin panel.\n\n")
  } else {
    cat("System functional but has warnings.\n")
    cat("You can proceed but should address warnings.\n\n")
  }
}

# Installation help
if (length(missing_packages) > 0) {
  cat("=======================================\n")
  cat("  INSTALL MISSING PACKAGES\n")
  cat("=======================================\n")
  cat("\nRun this in R:\n\n")
  cat(sprintf("install.packages(c(%s))\n\n",
              paste(sprintf('"%s"', missing_packages), collapse = ", ")))
}
