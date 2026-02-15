# ===================================================
# Manage Credentials Script
# ===================================================
# Admin panel for managing user credentials
# ===================================================

# Load required libraries
suppressPackageStartupMessages({
  library(DBI)
  library(duckdb)
  library(scrypt)
})

# Locate credentials database
credentials_db_path <- if (file.exists("src/credentials.duckdb")) {
  "src/credentials.duckdb"
} else if (file.exists("credentials.duckdb")) {
  "credentials.duckdb"
} else {
  stop("Cannot find credentials.duckdb file.")
}

# Helper function to display all users
display_users <- function(con) {
  users <- dbGetQuery(con, "SELECT id, user, isAdmin FROM credentials ORDER BY id")

  cat("\n")
  cat("=======================================\n")
  cat("  CURRENT USERS\n")
  cat("=======================================\n\n")

  if (nrow(users) == 0) {
    cat("No users found.\n\n")
    return()
  }

  for (i in 1:nrow(users)) {
    admin_badge <- ifelse(users$isAdmin[i], " [ADMIN]", "")
    cat(sprintf("  ID:%d  %s%s\n", users$id[i], users$user[i], admin_badge))
  }

  cat("\n")
}

# Helper function to change password
change_password <- function(con, user_id) {
  # Check if user exists
  result <- dbGetQuery(con, "SELECT id, user FROM credentials WHERE id = ?",
                       params = list(user_id))

  if (nrow(result) == 0) {
    cat(sprintf("\nUser with ID %s not found.\n\n", user_id))
    return(FALSE)
  }

  username <- result$user[1]
  cat(sprintf("\nChanging password for: %s (ID:%d)\n", username, user_id))

  # Get new password (with confirmation)
  cat("Enter new password: ")
  new_password <- readLines(file("stdin"), n = 1)

  if (nchar(new_password) == 0) {
    cat("\nPassword cannot be empty.\n\n")
    return(FALSE)
  }

  cat("Confirm new password: ")
  confirm_password <- readLines(file("stdin"), n = 1)

  if (new_password != confirm_password) {
    cat("\nPasswords do not match.\n\n")
    return(FALSE)
  }

  # Hash the new password
  cat("Hashing password...")
  hashed_password <- scrypt::hashPassword(new_password)
  cat(" done\n")

  # Update database
  dbExecute(con, "UPDATE credentials SET password = ? WHERE id = ?",
            params = list(hashed_password, user_id))

  cat(sprintf("\nPassword updated successfully for '%s' (ID:%d).\n\n", username, user_id))
  return(TRUE)
}

# Helper function to change username
change_username <- function(con, user_id) {
  # Check if user exists
  result <- dbGetQuery(con, "SELECT id, user FROM credentials WHERE id = ?",
                       params = list(user_id))

  if (nrow(result) == 0) {
    cat(sprintf("\nUser with ID %s not found.\n\n", user_id))
    return(FALSE)
  }

  old_username <- result$user[1]
  cat(sprintf("\nChanging username for: %s (ID:%d)\n", old_username, user_id))

  # Get new username
  cat("Enter new username: ")
  new_username <- trimws(readLines(file("stdin"), n = 1))

  if (nchar(new_username) == 0) {
    cat("\nUsername cannot be empty.\n\n")
    return(FALSE)
  }

  # Check if new username already exists
  existing <- dbGetQuery(con, "SELECT user FROM credentials WHERE user = ? AND id != ?",
                         params = list(new_username, user_id))

  if (nrow(existing) > 0) {
    cat(sprintf("\nUsername '%s' is already taken.\n\n", new_username))
    return(FALSE)
  }

  # Confirm change
  cat(sprintf("\nChange username from '%s' to '%s'?\n", old_username, new_username))
  cat("Confirm? (y/n): ")
  response <- tolower(trimws(readLines(file("stdin"), n = 1)))

  if (response != "y") {
    cat("\nOperation cancelled.\n\n")
    return(FALSE)
  }

  # Update database
  dbExecute(con, "UPDATE credentials SET user = ? WHERE id = ?",
            params = list(new_username, user_id))

  cat(sprintf("\nUsername changed from '%s' to '%s'.\n\n", old_username, new_username))
  return(TRUE)
}


# Main menu loop
main_menu <- function() {
  con <- NULL

  tryCatch({
    # Connect to database (read-write mode)
    con <- dbConnect(duckdb(credentials_db_path), read_only = FALSE)

    repeat {
      cat("\n")
      cat("=======================================\n")
      cat("  CREDENTIAL MANAGEMENT\n")
      cat("=======================================\n\n")

      cat("Available Operations:\n\n")
      cat("  1. View All Users\n")
      cat("  2. Change Username\n")
      cat("  3. Change User Password\n")
      cat("  4. Return to Main Menu\n\n")
      cat("=======================================\n\n")

      cat("Enter your choice (1-4): ")
      choice <- trimws(readLines(file("stdin"), n = 1))

      if (choice == "1") {
        # View all users
        display_users(con)
        cat("\nPress Enter to continue...")
        readLines(file("stdin"), n = 1)

      } else if (choice == "2") {
        # Change username
        display_users(con)
        cat("Enter user ID to change username: ")
        user_id <- as.integer(trimws(readLines(file("stdin"), n = 1)))
        if (!is.na(user_id)) {
          change_username(con, user_id)
        } else {
          cat("\nInvalid ID. Please enter a number.\n\n")
        }
        cat("\nPress Enter to continue...")
        readLines(file("stdin"), n = 1)

      } else if (choice == "3") {
        # Change password
        display_users(con)
        cat("Enter user ID to change password: ")
        user_id <- as.integer(trimws(readLines(file("stdin"), n = 1)))
        if (!is.na(user_id)) {
          change_password(con, user_id)
        } else {
          cat("\nInvalid ID. Please enter a number.\n\n")
        }
        cat("\nPress Enter to continue...")
        readLines(file("stdin"), n = 1)

      } else if (choice == "4") {
        # Exit
        cat("\nReturning to main menu...\n\n")
        break

      } else {
        cat("\nInvalid choice. Please try again.\n")
        Sys.sleep(1)
      }
    }

  }, error = function(e) {
    cat(sprintf("\n[ERROR] %s\n\n", e$message))
  }, finally = {
    if (!is.null(con) && DBI::dbIsValid(con)) {
      dbDisconnect(con, shutdown = TRUE)
    }
  })
}

# Run main menu
main_menu()
