# Email Tests Documentation

This directory contains comprehensive unit tests for the email functionality in the Livestock Dashboard application.

## Test Files Overview

### 1. `test-email-features.R`
Tests the core email functionality including:
- `send_test_email()` function
- `schedule_email_report()` function
- Email composition and sending
- Error handling and edge cases
- Integration scenarios

**Key Test Categories:**
- Basic email sending functionality
- Time format handling (POSIXct, character, list)
- Error handling for failed email functions
- Email address validation
- Frequency validation
- Complete email workflow simulation

### 2. `test-email-credentials.R`
Tests email credential setup and management:
- `create_smtp_creds_key()` function
- Credential validation and storage
- Different email provider configurations
- Security and persistence
- Error handling for credential setup

**Key Test Categories:**
- Gmail, Outlook, and custom provider configurations
- Email address format validation
- SSL configuration validation
- Credential overwrite functionality
- Network and authentication error handling

### 3. `test-email-report-generation.R`
Tests email report composition and formatting:
- Email content generation with markdown
- Chart attachment handling
- Report content formatting
- Subject line generation
- Data processing and validation

**Key Test Categories:**
- Markdown content formatting
- Report content with summary statistics
- Email attachments (single and multiple)
- Subject line generation with dates
- Handling of missing data and special characters
- Number formatting (small and large numbers)

### 4. `test-email-integration.R`
Tests email functionality integration with Shiny app:
- Shiny reactive values and inputs
- UI validation and error handling
- Session management
- File upload handling
- Progress indicators and notifications
- Modal dialogs and bookmarking

**Key Test Categories:**
- Shiny input validation (email, frequency, time)
- Reactive dependency management
- File upload processing
- Progress and notification systems
- Modal dialog handling
- Bookmarking functionality

## Running the Tests

### Run All Email Tests
```r
# From the project root directory
source("run_email_tests.R")
```

### Run Individual Test Files
```r
# Run specific test file
testthat::test_file("tests/testthat/test-email-features.R")
testthat::test_file("tests/testthat/test-email-credentials.R")
testthat::test_file("tests/testthat/test-email-report-generation.R")
testthat::test_file("tests/testthat/test-email-integration.R")
```

### Run Tests with Coverage
```r
# Install covr if not already installed
install.packages("covr")

# Run tests with coverage
library(covr)
coverage <- package_coverage()
report(coverage)
```

## Test Data and Mocking

### Mock Functions
The tests use mock functions to simulate email functionality without actually sending emails:

- `mock_compose_email()` - Simulates email composition
- `mock_smtp_send()` - Simulates email sending
- `mock_creds_key()` - Simulates credential retrieval
- `mock_add_attachment()` - Simulates file attachments

### Test Data
```r
# Sample test data used in tests
test_report_data <- data.frame(
  date = seq(as.Date("2024-01-01"), as.Date("2024-01-07"), by = "day"),
  weight = c(450, 455, 460, 465, 470, 475, 480),
  feed_intake = c(8.5, 8.7, 8.9, 9.1, 9.3, 9.5, 9.7),
  methane = c(200, 205, 210, 215, 220, 225, 230)
)

test_chart_types <- c("Weight Trend", "Feed Intake", "Methane Production")
test_recipient <- "user@example.com"
```

## Test Coverage

The tests cover the following email functionality:

### Core Functions
- ✅ `send_test_email()` - Email sending with error handling
- ✅ `schedule_email_report()` - Email scheduling with time formatting
- ✅ `create_smtp_creds_key()` - Credential setup and validation
- ✅ Email composition with markdown content
- ✅ Email attachments handling

### Input Validation
- ✅ Email address format validation
- ✅ Frequency validation (Daily/Weekly/Monthly)
- ✅ Time input validation (various formats)
- ✅ Chart type validation
- ✅ File upload validation

### Error Handling
- ✅ Network connection errors
- ✅ Authentication failures
- ✅ Invalid input handling
- ✅ Missing data handling
- ✅ File system errors

### Integration
- ✅ Shiny app integration
- ✅ Reactive value handling
- ✅ UI component interaction
- ✅ Session management
- ✅ Progress indicators

## Dependencies

### Required Packages
- `testthat` - Testing framework
- `blastula` - Email functionality
- `shiny` - Shiny app integration
- `dplyr` - Data manipulation (for test data)
- `lubridate` - Date/time handling

### Optional Packages
- `covr` - Test coverage analysis
- `DT` - Data table functionality
- `ggplot2` - Chart generation (for attachment tests)

## Test Environment Setup

The tests are designed to run in isolation and don't require:
- Actual email server configuration
- Real email credentials
- Network connectivity
- Database connections

All external dependencies are mocked to ensure tests run reliably in any environment.

## Adding New Tests

When adding new email functionality, follow these guidelines:

1. **Add tests to the appropriate file** based on functionality:
   - Core email functions → `test-email-features.R`
   - Credential management → `test-email-credentials.R`
   - Report generation → `test-email-report-generation.R`
   - Shiny integration → `test-email-integration.R`

2. **Use descriptive test names** that clearly indicate what is being tested:
   ```r
   test_that("email validation rejects invalid addresses", {
     # test code
   })
   ```

3. **Mock external dependencies** to ensure tests are isolated and reliable

4. **Test both success and failure cases** to ensure robust error handling

5. **Include edge cases** such as empty inputs, special characters, and boundary conditions

## Troubleshooting

### Common Issues

1. **Package not found errors**
   ```r
   # Install missing packages
   install.packages(c("testthat", "blastula", "shiny"))
   ```

2. **File path issues**
   ```r
   # Ensure you're in the project root directory
   getwd()  # Should show the project directory
   list.files()  # Should include 'src' and 'tests' directories
   ```

3. **Mock function conflicts**
   - Ensure mock functions are properly defined before use
   - Use unique function names to avoid conflicts

4. **Test data issues**
   - Verify test data is properly formatted
   - Check that required columns exist in test data frames

### Debug Mode
To run tests with more verbose output:
```r
# Run with detailed reporter
testthat::test_file("tests/testthat/test-email-features.R", reporter = "verbose")
```

## Contributing

When contributing to email tests:

1. Follow the existing test structure and naming conventions
2. Add appropriate documentation for new test functions
3. Ensure all tests pass before submitting
4. Update this README if adding new test categories or functionality
5. Consider test performance and avoid unnecessary external dependencies

## Future Enhancements

Potential areas for test expansion:

1. **Performance testing** - Test email sending with large datasets
2. **Concurrent testing** - Test multiple simultaneous email operations
3. **Security testing** - Test credential security and data protection
4. **Load testing** - Test email functionality under high load
5. **Integration testing** - Test with real email providers (in controlled environment)
