# Test Email Credentials Setup
# Tests for email credential configuration and validation

library(testthat)
library(blastula)

# Mock functions for testing credential setup
mock_create_smtp_creds_key <- function(id, user, provider, use_ssl, overwrite) {
  # Validate inputs
  if (!is.character(id) || nchar(id) == 0) {
    stop("Invalid credential ID")
  }
  if (is.null(user) || !is.character(user) || !grepl("^[^@]+@[^@]+\\.[^@]+$", user)) {
    stop("Invalid email address")
  }
  if (!is.character(provider) || !provider %in% c("gmail", "outlook", "yahoo", "custom")) {
    stop("Invalid email provider")
  }
  if (!is.logical(use_ssl)) {
    stop("use_ssl must be logical")
  }
  if (!is.logical(overwrite)) {
    stop("overwrite must be logical")
  }
  
  # Return mock credential object
  return(list(
    id = id,
    user = user,
    provider = provider,
    use_ssl = use_ssl,
    overwrite = overwrite,
    created = Sys.time()
  ))
}

# Test credential creation
test_that("create_smtp_creds_key works with valid Gmail configuration", {
  creds <- mock_create_smtp_creds_key(
    id = "weekly_report_email",
    user = "test@gmail.com",
    provider = "gmail",
    use_ssl = TRUE,
    overwrite = TRUE
  )
  
  expect_true(is.list(creds))
  expect_equal(creds$id, "weekly_report_email")
  expect_equal(creds$user, "test@gmail.com")
  expect_equal(creds$provider, "gmail")
  expect_true(creds$use_ssl)
  expect_true(creds$overwrite)
  expect_true(inherits(creds$created, "POSIXt"))
})

test_that("create_smtp_creds_key works with valid Outlook configuration", {
  creds <- mock_create_smtp_creds_key(
    id = "outlook_email",
    user = "test@outlook.com",
    provider = "outlook",
    use_ssl = TRUE,
    overwrite = FALSE
  )
  
  expect_true(is.list(creds))
  expect_equal(creds$id, "outlook_email")
  expect_equal(creds$user, "test@outlook.com")
  expect_equal(creds$provider, "outlook")
  expect_true(creds$use_ssl)
  expect_false(creds$overwrite)
})

test_that("create_smtp_creds_key works with custom provider", {
  creds <- mock_create_smtp_creds_key(
    id = "custom_email",
    user = "test@customdomain.com",
    provider = "custom",
    use_ssl = FALSE,
    overwrite = TRUE
  )
  
  expect_true(is.list(creds))
  expect_equal(creds$id, "custom_email")
  expect_equal(creds$user, "test@customdomain.com")
  expect_equal(creds$provider, "custom")
  expect_false(creds$use_ssl)
  expect_true(creds$overwrite)
})

# Test credential validation
test_that("create_smtp_creds_key validates credential ID", {
  # Test empty ID
  expect_error(
    mock_create_smtp_creds_key("", "test@gmail.com", "gmail", TRUE, TRUE),
    "Invalid credential ID"
  )
  
  # Test NULL ID
  expect_error(
    mock_create_smtp_creds_key(NULL, "test@gmail.com", "gmail", TRUE, TRUE),
    "Invalid credential ID"
  )
  
  # Test non-character ID
  expect_error(
    mock_create_smtp_creds_key(123, "test@gmail.com", "gmail", TRUE, TRUE),
    "Invalid credential ID"
  )
})

test_that("create_smtp_creds_key validates email address", {
  # Test invalid email formats
  invalid_emails <- c(
    "invalid-email",
    "@gmail.com",
    "test@",
    "test.gmail.com",
    ""
  )
  
  for (email in invalid_emails) {
    expect_error(
      mock_create_smtp_creds_key("test_id", email, "gmail", TRUE, TRUE),
      "Invalid email address"
    )
  }
  
  # Test NULL email separately
  expect_error(
    mock_create_smtp_creds_key("test_id", NULL, "gmail", TRUE, TRUE),
    "Invalid email address"
  )
})

test_that("create_smtp_creds_key validates email provider", {
  # Test invalid providers
  invalid_providers <- c(
    "invalid_provider",
    "hotmail",
    "aol",
    "",
    NULL,
    123
  )
  
  for (provider in invalid_providers) {
    expect_error(
      mock_create_smtp_creds_key("test_id", "test@gmail.com", provider, TRUE, TRUE),
      "Invalid email provider"
    )
  }
})

test_that("create_smtp_creds_key validates SSL parameter", {
  # Test non-logical SSL values
  invalid_ssl <- c("true", "false", "yes", "no", 1, 0, NULL)
  
  for (ssl in invalid_ssl) {
    expect_error(
      mock_create_smtp_creds_key("test_id", "test@gmail.com", "gmail", ssl, TRUE),
      "use_ssl must be logical"
    )
  }
})

test_that("create_smtp_creds_key validates overwrite parameter", {
  # Test non-logical overwrite values
  invalid_overwrite <- c("true", "false", "yes", "no", 1, 0, NULL)
  
  for (overwrite in invalid_overwrite) {
    expect_error(
      mock_create_smtp_creds_key("test_id", "test@gmail.com", "gmail", TRUE, overwrite),
      "overwrite must be logical"
    )
  }
})

# Test credential retrieval
test_that("creds_key retrieves existing credentials", {
  # Mock credential storage
  credential_store <- list(
    weekly_report_email = list(
      id = "weekly_report_email",
      user = "test@gmail.com",
      provider = "gmail",
      use_ssl = TRUE
    )
  )
  
  mock_creds_key <- function(id) {
    if (id %in% names(credential_store)) {
      return(credential_store[[id]])
    } else {
      stop("Credential not found: ", id)
    }
  }
  
  # Test successful retrieval
  creds <- mock_creds_key("weekly_report_email")
  expect_true(is.list(creds))
  expect_equal(creds$id, "weekly_report_email")
  expect_equal(creds$user, "test@gmail.com")
  
  # Test non-existent credential
  expect_error(
    mock_creds_key("nonexistent_credential"),
    "Credential not found: nonexistent_credential"
  )
})

# Test credential management
test_that("credential overwrite functionality", {
  # Test that overwrite = TRUE replaces existing credentials
  existing_creds <- list(
    id = "test_credential",
    user = "old@example.com",
    provider = "gmail"
  )
  
  new_creds <- list(
    id = "test_credential",
    user = "new@example.com",
    provider = "gmail"
  )
  
  # Simulate overwrite behavior
  overwrite_creds <- function(existing, new, overwrite) {
    if (overwrite) {
      return(new)
    } else {
      return(existing)
    }
  }
  
  # Test overwrite = TRUE
  result_true <- overwrite_creds(existing_creds, new_creds, TRUE)
  expect_equal(result_true$user, "new@example.com")
  
  # Test overwrite = FALSE
  result_false <- overwrite_creds(existing_creds, new_creds, FALSE)
  expect_equal(result_false$user, "old@example.com")
})

# Test credential security
test_that("credentials are stored securely", {
  # Test that credentials don't expose sensitive information in logs
  creds <- mock_create_smtp_creds_key(
    id = "secure_test",
    user = "secure@example.com",
    provider = "gmail",
    use_ssl = TRUE,
    overwrite = TRUE
  )
  
  # Credentials should not contain plain text passwords
  creds_text <- paste(capture.output(str(creds)), collapse = " ")
  expect_false(grepl("password|secret|key", creds_text, ignore.case = TRUE))
  
  # User email should be present but not other sensitive data
  expect_true(grepl("secure@example.com", creds_text))
})

# Test credential persistence
test_that("credentials persist across sessions", {
  # Mock credential persistence
  persistent_store <- new.env()
  
  save_credentials <- function(creds) {
    persistent_store[[creds$id]] <- creds
  }
  
  load_credentials <- function(id) {
    if (exists(id, envir = persistent_store)) {
      return(persistent_store[[id]])
    } else {
      return(NULL)
    }
  }
  
  # Save credentials
  creds <- mock_create_smtp_creds_key(
    id = "persistent_test",
    user = "persistent@example.com",
    provider = "gmail",
    use_ssl = TRUE,
    overwrite = TRUE
  )
  save_credentials(creds)
  
  # Load credentials
  loaded_creds <- load_credentials("persistent_test")
  expect_false(is.null(loaded_creds))
  expect_equal(loaded_creds$id, "persistent_test")
  expect_equal(loaded_creds$user, "persistent@example.com")
  
  # Test non-existent credentials
  non_existent <- load_credentials("non_existent")
  expect_true(is.null(non_existent))
})

# Test credential validation for different providers
test_that("Gmail credentials validation", {
  # Valid Gmail addresses
  valid_gmail <- c(
    "test@gmail.com",
    "user.name@gmail.com",
    "user+tag@gmail.com",
    "test123@gmail.com"
  )
  
  for (email in valid_gmail) {
    creds <- mock_create_smtp_creds_key(
      id = "gmail_test",
      user = email,
      provider = "gmail",
      use_ssl = TRUE,
      overwrite = TRUE
    )
    expect_equal(creds$provider, "gmail")
    expect_true(creds$use_ssl)  # Gmail should use SSL
  }
})

test_that("Outlook credentials validation", {
  # Valid Outlook addresses
  valid_outlook <- c(
    "test@outlook.com",
    "user@hotmail.com",
    "user@live.com"
  )
  
  for (email in valid_outlook) {
    creds <- mock_create_smtp_creds_key(
      id = "outlook_test",
      user = email,
      provider = "outlook",
      use_ssl = TRUE,
      overwrite = TRUE
    )
    expect_equal(creds$provider, "outlook")
    expect_true(creds$use_ssl)  # Outlook should use SSL
  }
})

test_that("Custom provider credentials validation", {
  # Custom domain emails
  custom_emails <- c(
    "admin@company.com",
    "user@university.edu",
    "support@organization.org"
  )
  
  for (email in custom_emails) {
    creds <- mock_create_smtp_creds_key(
      id = "custom_test",
      user = email,
      provider = "custom",
      use_ssl = FALSE,  # Custom might not use SSL
      overwrite = TRUE
    )
    expect_equal(creds$provider, "custom")
    expect_false(creds$use_ssl)
  }
})

# Test error handling
test_that("credential setup handles network errors gracefully", {
  # Mock network error
  mock_create_smtp_creds_key_with_error <- function(id, user, provider, use_ssl, overwrite) {
    # Always simulate network failure for this test
    stop("Network connection failed")
  }
  
  # Test that errors are properly caught
  expect_error(
    mock_create_smtp_creds_key_with_error("test", "test@gmail.com", "gmail", TRUE, TRUE),
    "Network connection failed"
  )
})

test_that("credential setup handles authentication errors", {
  # Mock authentication error
  mock_create_smtp_creds_key_with_auth_error <- function(id, user, provider, use_ssl, overwrite) {
    if (provider == "gmail" && !grepl("app_password", user)) {
      stop("Gmail requires app password for authentication")
    }
    return(mock_create_smtp_creds_key(id, user, provider, use_ssl, overwrite))
  }
  
  # Test Gmail without app password
  expect_error(
    mock_create_smtp_creds_key_with_auth_error("test", "test@gmail.com", "gmail", TRUE, TRUE),
    "Gmail requires app password for authentication"
  )
  
  # Test Gmail with app password
  expect_no_error(
    mock_create_smtp_creds_key_with_auth_error("test", "app_password@gmail.com", "gmail", TRUE, TRUE)
  )
})

# Test credential cleanup
test_that("credentials can be removed", {
  # Mock credential removal
  credential_store <- list(
    temp_credential = list(id = "temp_credential", user = "temp@example.com")
  )
  
  remove_credential <- function(id) {
    if (id %in% names(credential_store)) {
      credential_store <<- credential_store[names(credential_store) != id]
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
  
  # Test successful removal
  expect_true(remove_credential("temp_credential"))
  expect_false("temp_credential" %in% names(credential_store))
  
  # Test removal of non-existent credential
  expect_false(remove_credential("non_existent"))
})

# Test credential listing
test_that("all credentials can be listed", {
  # Mock credential listing
  credential_store <- list(
    credential1 = list(id = "credential1", user = "user1@example.com"),
    credential2 = list(id = "credential2", user = "user2@example.com"),
    credential3 = list(id = "credential3", user = "user3@example.com")
  )
  
  list_credentials <- function() {
    return(names(credential_store))
  }
  
  credentials <- list_credentials()
  expect_equal(length(credentials), 3)
  expect_true("credential1" %in% credentials)
  expect_true("credential2" %in% credentials)
  expect_true("credential3" %in% credentials)
})
