# Email Setup Guide for Reports Page

## Step 1: Set up Gmail App Password

1. **Enable 2-Factor Authentication** on your Google Account
2. **Create an App Password**:
   - Go to Google account settings
   - Click "2-Step Verification" 
   - Scroll down to "App passwords"
   - Enter "R Shiny App"
   - Click "Generate"
   - **Copy the 16-character password** (we need to keep this password because it will be used when we run the setup script [step 2])

## Step 2: Run the Setup Script

```r
source("setup_email_credentials.R")
```

## Step 3: Test the Email Functionality

1. **Start your Shiny app**
2. **Go to the Reports page**
3. **Fill in the email form**:
   - Enter your email address
   - Select frequency (Daily/Weekly/Monthly)
   - Set a time
   - Click "Schedule Report"


## Alternative Email Providers

If you want to use a different email provider, modify the `setup_email_credentials.R` file:

```r
create_smtp_creds_key(
  id = "weekly_report_email",
  user = "your_email@yourdomain.com",
  provider = "gmail",
  use_ssl = TRUE,
  overwrite = TRUE
)
```