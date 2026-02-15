# Complete Email System Guide

## Overview

The Livestock Dashboard now has a complete email automation system that can:
- Schedule automated reports to be sent at regular intervals
- Store email schedules in a database
- Actually send emails with charts and data
- Process due emails automatically

## Setup Instructions

### 1. Email Credentials Setup

First, set up your email credentials:

```r
source("setup_email_credentials.R")
```

This will create the necessary SMTP credentials for sending emails.

### 2. Test Email Functionality

Test that your email setup works:

```r
source("test_email_credentials.R")
```

### 3. Test Email Sending

Test the complete email sending system:

```r
source("test_email_sending.R")
```

## How to Use the Email System

### 1. Schedule Reports via the Web Interface

1. **Start your Shiny app**
2. **Go to the Reports page**
3. **Fill in the email scheduling form**:
   - Enter recipient email address
   - Select frequency (Daily/Weekly/Monthly)
   - Set send time
   - Choose chart types to include
   - Click "Schedule Report"

### 2. Manage Scheduled Emails

- **View all schedules**: The "Scheduled Email Data" section shows all stored schedules
- **Activate/Deactivate**: Use the dropdown to manage individual schedules
- **Delete schedules**: Remove schedules you no longer need
- **Test sending**: Click "Test Send Emails" to manually trigger email sending

### 3. Automatic Email Processing

The system can automatically process and send due emails using:

```r
source("run_email_scheduler.R")
```

## Setting Up Automatic Email Processing

### Option 1: Manual Testing
Run the scheduler script manually when you want to test:

```bash
Rscript run_email_scheduler.R
```

### Option 2: Cron Job (Linux/Mac)
Add to your crontab to run every hour:

```bash
crontab -e

0 * * * * cd /path/to/your/project && Rscript run_email_scheduler.R
```

### Option 3: Task Scheduler (Windows)
1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (e.g., daily at specific time)
4. Set action to run: `Rscript run_email_scheduler.R`

## Email Content Features

### What Gets Sent
- **Report summary** with statistics
- **Applied filters** information
- **Charts** (if selected) as both inline images and attachments
- **Professional formatting** with markdown

### Chart Types Supported
- **Distribution**: Histogram of numeric data
- **Time Series**: Line charts over time
- **Cohorts**: Grouped analysis
- **Summary Statistics**: Combined statistical charts

## Troubleshooting

### Common Issues

1. **"Authentication failed" error**:
   - Ensure 2-Factor Authentication is enabled on Gmail
   - Use App Password, not regular password
   - Try generating a new App Password

2. **"No emails due for sending"**:
   - Check that schedules are active
   - Verify send times are correct
   - Ensure current time matches schedule criteria

3. **"No data available"**:
   - Check that your database has data
   - Verify filter criteria in stored schedules
   - Ensure data columns match expected format

### Debug Steps

1. **Check active schedules**:
   ```r
   source("src/email_automation.R")
   schedules <- get_email_schedules(active_only = TRUE)
   print(schedules)
   ```

2. **Test due schedules**:
   ```r
   due_schedules <- get_due_schedules()
   print(due_schedules)
   ```

3. **Manual email test**:
   ```r
   schedule <- schedules[1, ]
   send_scheduled_email(schedule)
   ```

## File Structure

```
├── src/
│   ├── email_automation.R          # Core email functions
│   ├── report_generator.R          # Chart generation
│   └── summary_stats.R             # Statistics functions
├── run_email_scheduler.R           # Scheduler script
├── test_email_sending.R           # Test script
├── setup_email_credentials.R     # Email setup
└── test_email_credentials.R       # Credential testing
```

## Security Notes

- **Email credentials** are stored securely in R keyring
- **Never commit** App Passwords to version control
- **Each user** needs to run setup on their machine
- **Database** contains only schedule metadata, not email content

## Advanced Configuration

### Custom Email Templates
Modify `generate_scheduled_email_report()` in `src/email_automation.R` to customize email content.

### Different Email Providers
Update `setup_email_credentials.R` to use different SMTP providers:

```r
create_smtp_creds_key(
  id = "weekly_report_email",
  user = "your_email@yourdomain.com",
  host = "smtp.yourdomain.com",
  port = 587,
  use_ssl = TRUE,
  overwrite = TRUE
)
```

### Custom Scheduling
Modify `get_due_schedules()` to implement custom scheduling logic.

## Support

If you encounter issues:
1. Check the console output for error messages
2. Verify email credentials are set up correctly
3. Test with the provided test scripts
4. Check that your database has the required data
5. Ensure all required R packages are installed

The system is now fully functional and ready to send automated livestock reports via email!
