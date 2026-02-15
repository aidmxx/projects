# Livestock Dashboard Admin Guide
**Complete Management System for Multi-Farm Deployments**

---

## Table of Contents

1. [First Time Setup](#first-time-setup)
2. [Admin Panel Overview](#admin-panel-overview)
3. [Daily Operations](#daily-operations)
4. [Managing Farms](#managing-farms)
5. [Managing Logos](#managing-logos)
6. [Managing User Credentials](#managing-user-credentials)
7. [Troubleshooting](#troubleshooting)
8. [Reference](#reference)

---

## First Time Setup

### Prerequisites
- R version 4.0 or higher installed
- Internet connection
- shinyapps.io account

### Step 1: Configure shinyapps.io (One-Time)

1. Get your credentials from: https://www.shinyapps.io/admin/#/tokens
2. Click "Show" to reveal your token
3. Open R or RStudio and run:
   ```r
   rsconnect::setAccountInfo(
     name='your-account-name',
     token='YOUR-TOKEN',
     secret='YOUR-SECRET'
   )
   ```

### Step 2: Verify Setup

```cmd
check_setup.bat
```

This will check:
- ✓ R installation
- ✓ Required packages
- ✓ rsconnect configuration
- ✓ Database files
- ✓ Directory structure

### Step 3: Run the Admin Panel

```cmd
admin_panel.bat
```

---

## Admin Panel Overview

### Main Menu

```
═══════════════════════════════════════
  LIVESTOCK DASHBOARD ADMIN PANEL
═══════════════════════════════════════

Available Operations:

  1. Update Farm Databases (upload new data or create new farms)
  2. Deploy Code Changes to All Farms
  3. Revert Farm from Backup
  4. View Farm Status
  5. View All Backups
  6. Manage User Credentials
  7. Exit
```

### What Each Option Does

| Option | Purpose | When to Use |
|--------|---------|-------------|
| **1** | Update farm data | When you have new CSV data files |
| **2** | Deploy code changes | After fixing bugs or adding features |
| **3** | Restore from backup | When you need to undo bad data |
| **4** | View status | To check all farms at a glance |
| **5** | View backups | To see backup history |
| **6** | Manage users | To change passwords/usernames |

### Directory Structure

```
Project/
├── admin_panel.bat              ← Start here
├── farms.csv                    ← Farm configuration
│
├── src/                         ← Shared application code
│   ├── ui.R
│   ├── server.R
│   ├── global.R
│   ├── credentials.duckdb       ← User accounts
│   └── logo/                    ← Logos for local testing
│
├── farm_databases/              ← Each farm's data
│   ├── FarmA_data.duckdb
│   └── FarmB_data.duckdb
│
├── farm_backups/                ← Automatic backups
│   ├── FarmA/
│   │   └── FarmA_backup_20250122.duckdb
│   └── FarmB/
│
├── farm_logos/                  ← Farm-specific logos
│   ├── FarmA/
│   │   ├── 01_university.png
│   │   └── 02_sponsor.png
│   └── FarmB/
│
└── data_upload/                 ← Place CSV files here
    └── archive/                 ← Auto-archived after processing
```

---

## Daily Operations

### Updating Farm Data

**When**: You have new livestock data for one or more farms

**Steps**:

1. **Prepare your CSV file(s)**:
   - Name format: `{farm_id}_YYYY-MM-DD.csv`
   - Examples: `FarmA_2025-01-22.csv`, `FarmB_2025-01-23.csv`
   - Required columns: `eid`, `date`

2. **Place CSV(s) in `data_upload/` folder**:
   - You can add multiple CSVs for different farms
   - All will be processed in one run

3. **Run admin panel**:
   ```cmd
   admin_panel.bat
   ```

4. **Choose Option 1** (Update All Farms)

5. **Handle duplicates** (if found):
   - **Option 1 (SKIP)**: Only add new records *(Recommended)*
   - **Option 2 (OVERWRITE)**: Replace existing records

6. **Confirm deployment** (y/n)

**What happens**:
- ✓ Automatic backup created before update
- ✓ New data added to databases
- ✓ Deployed to shinyapps.io
- ✓ CSVs moved to `data_upload/archive/`

---

### Deploying Code Changes

**When**: You fixed a bug or added a new feature

**Steps**:

1. **Edit files** in `src/` directory:
   - `ui.R` - User interface
   - `server.R` - Server logic
   - `global.R` - Global settings
   - Other module files

2. **Test locally**:
   ```r
   shiny::runApp("src")
   ```
   Verify everything works correctly

3. **Run admin panel**:
   ```cmd
   admin_panel.bat
   ```

4. **Choose Option 2** (Deploy Code Changes)

5. **Confirm deployment** (y/n)

6. **Wait for completion**:
   - Farms deploy in parallel (batches of 5)
   - Total time for 25 farms: ~15 minutes

**What happens**:
- ✓ All farms get updated code
- ✓ Each farm keeps its own data
- ✓ No backups created (data unchanged)

---

### Reverting a Farm

**When**: You deployed bad data or need to restore previous state

**Steps**:

1. **Run admin panel**:
   ```cmd
   admin_panel.bat
   ```

2. **Choose Option 3** (Revert Farm from Backup)

3. **Select the farm** to revert (enter number)

4. **Choose backup** to restore (shows date, size, record count)

5. **Confirm revert** (y/n)
   - Safety backup of current state created automatically

6. **Choose deployment** (y/n):
   - **y** = Apply to live dashboard immediately
   - **n** = Revert locally only

**What happens**:
- ✓ Safety backup created (`{farm}_before_revert_YYYYMMDD_HHMMSS.duckdb`)
- ✓ Database restored from selected backup
- ✓ Optionally deployed to shinyapps.io

---

### Viewing Farm Status

**When**: You want an overview of all farms

**Steps**:

1. **Run admin panel**
2. **Choose Option 4** (View Farm Status)

**Shows**:
- Database size and location
- Record counts
- Last modified date
- Number of backups available
- Most recent backup date
- Deployment URL
- Pending CSV files in `data_upload/`

---

### Viewing All Backups

**When**: You want to see backup history across all farms

**Steps**:

1. **Run admin panel**
2. **Choose Option 5** (View All Backups)

**Shows**:
- List of all farms with backup folders
- All backup files for each farm
- Organized by farm ID
- Quick overview of backup availability

**Example output**:
```
========================================
Farm: FarmA
========================================
  - FarmA_backup_20250120.duckdb
  - FarmA_backup_20250121.duckdb
  - FarmA_backup_20250122.duckdb

========================================
Farm: FarmB
========================================
  - FarmB_backup_20250122.duckdb
```

**Use this to**:
- Check which farms have backups available
- See how many backup versions exist for each farm
- Identify farms that might need backup cleanup
- Verify backups were created after data updates

**Note**: This is a quick view only. For detailed backup info (size, record count, dates), use Option 3 (Revert Farm from Backup) which shows full backup details when you select a farm.

---

## Managing Farms

### Adding a New Farm

**Simple 3-Step Process**:

#### Step 1: Edit `farms.csv`

Add a new line with your farm details:

```csv
farm_id,farm_name,app_name
FarmA,Byrne Farm,byrne-farm-dashboard
FarmB,Smith Ranch,smith-ranch-dashboard    ← ADD THIS LINE
```

**Column details**:
- `farm_id`: Unique identifier (e.g., FarmB) - used for database files
- `farm_name`: Display name (e.g., "Smith Ranch")
- `app_name`: URL slug for shinyapps.io (e.g., "smith-ranch-dashboard")

#### Step 2: Prepare Initial Data

Create a CSV file with initial farm data:
- Name: `FarmB_2025-01-22.csv` (or `FarmB_initial.csv`)
- Place in: `data_upload/` folder
- Must include: `eid`, `date`, and other livestock data columns

#### Step 3: Run Update

```cmd
admin_panel.bat
```

1. Choose **Option 1** (Update All Farms)
2. The system will automatically:
   - ⭐ Detect FarmB as a new farm
   - Create database from CSV
   - Add performance indexes
   - Deploy to shinyapps.io

**Done!** Your new farm is live at:
```
https://your-account.shinyapps.io/smith-ranch-dashboard/
```

**Note**: New farms deploy one at a time (sequentially) to prevent data mixing. This is slower but safer.

---

### File Naming Conventions

#### CSV Data Files
**Format**: `{farm_id}_YYYY-MM-DD.csv`

**Examples**:
- `FarmA_2025-01-22.csv`
- `FarmB_2025-01-23.csv`

#### Database Files
**Format**: `{farm_id}_data.duckdb`

**Examples**:
- `FarmA_data.duckdb`
- `FarmB_data.duckdb`

#### Backup Files
**Format**: `{farm_id}_backup_YYYYMMDD.duckdb`

**Examples**:
- `FarmA_backup_20250122.duckdb`
- `FarmB_backup_20250123.duckdb`

---

## Managing Logos

### Overview

Each farm can have its own set of logos displayed in the dashboard header. Logos are:
- Automatically detected from farm-specific folders
- Displayed centered in the header
- Sorted alphabetically by filename

### Adding Logos to a Farm

#### Step 1: Create Logo Folder

Create a folder for your farm's logos:
```
farm_logos/{farm_id}/
```

**Example**: For `FarmB`, create `farm_logos/FarmB/`

#### Step 2: Add Logo Files

Place logo images in the folder:
- **Supported formats**: PNG, JPG, JPEG, SVG
- **Recommended height**: 50-60 pixels (width auto-scales)
- **File size**: < 100KB each (optimize for fast loading)

**Example structure**:
```
farm_logos/FarmB/
├── 01_university.png
├── 02_primary_sponsor.png
└── 03_partner.png
```

**Tip**: Prefix with numbers to control display order (01, 02, 03...)

#### Step 3: Deploy

```cmd
admin_panel.bat
```

Choose **Option 2** (Deploy Code Changes)

**Done!** Logos will appear in the dashboard header.

---

### Controlling Logo Order

Logos display in **alphabetical order** by filename.

**Use number prefixes**:
```
farm_logos/MyFarm/
├── 01_university.png        # Displays first
├── 02_sponsor.png           # Displays second
└── 03_partner.png           # Displays third
```

**Or letter prefixes**:
```
farm_logos/MyFarm/
├── a_university.png         # Displays first
├── b_sponsor.png            # Displays second
└── c_partner.png            # Displays third
```

---

### Updating Logos

**To add a logo**:
1. Add file to `farm_logos/{farm_id}/`
2. Run admin panel → Option 2

**To remove a logo**:
1. Delete file from `farm_logos/{farm_id}/`
2. Run admin panel → Option 2

**To replace a logo**:
1. Replace file in `farm_logos/{farm_id}/` (keep same filename)
2. Run admin panel → Option 2
3. Clear browser cache if needed (Ctrl+Shift+R)

**To reorder logos**:
1. Rename files to change alphabetical order
2. Run admin panel → Option 2

---

### Multiple Farms Example

Each farm has independent logos:

```
farm_logos/
├── SydneyFarm/
│   ├── 01_usyd.png
│   └── 02_mla.png
├── MelbourneFarm/
│   ├── 01_unimelb.png
│   └── 02_csiro.png
└── BrisbaneFarm/
    └── 01_uq.png
```

Batch deployment (Option 2) deploys each farm's specific logos automatically.

---

## Managing User Credentials

### Overview

The system has three built-in user accounts:
- **ID 1 - admin**: Administrator account
- **ID 2 - owner**: Farm owner account
- **ID 3 - user**: Regular user account

**Admin/Owner accounts**: Can see real Electronic IDs (EIDs)
**User account**: Sees anonymized EIDs (displayed as `*****`)

### Accessing Credential Management

1. **Run admin panel**:
   ```cmd
   admin_panel.bat
   ```

2. **Choose Option 6** (Manage User Credentials)

### Credential Management Menu

```
═══════════════════════════════════════
  CREDENTIAL MANAGEMENT
═══════════════════════════════════════

Available Operations:

  1. View All Users
  2. Change Username
  3. Change User Password
  4. Return to Main Menu
```

---

### Viewing Users

1. From credential menu, choose **Option 1**
2. See all users with their IDs:
   ```
   ID:1  admin [ADMIN]
   ID:2  owner [ADMIN]
   ID:3  user
   ```

---

### Changing Username

1. From credential menu, choose **Option 2**
2. **Enter user ID** (1, 2, or 3)
3. **Enter new username**
4. **Confirm change** (y/n)

**Example**:
```
Enter user ID to change username: 3
Changing username for: user (ID:3)
Enter new username: john_smith
Change username from 'user' to 'john_smith'?
Confirm? (y/n): y
```

**Note**: Username must be unique. System prevents duplicates.

---

### Changing Password

1. From credential menu, choose **Option 3**
2. **Enter user ID** (1, 2, or 3)
3. **Enter new password** (hidden)
4. **Confirm new password** (hidden)

**Example**:
```
Enter user ID to change password: 1
Changing password for: admin (ID:1)
Enter new password: [hidden]
Confirm new password: [hidden]
Hashing password... done
Password updated successfully for 'admin' (ID:1).
```

**Security**: All passwords are automatically hashed using **scrypt** before storage. Passwords are never stored in plaintext.

---

### Default Login Credentials

**Initial accounts** (after setup):
```
Username: admin      Password: admin123    Role: Admin
Username: owner      Password: owner123    Role: Admin
Username: user       Password: user123     Role: User
```

**⚠️ IMPORTANT**: Change these default passwords immediately after setup!

---

### User Roles Explained

| Role | Can See EIDs? | Purpose |
|------|---------------|---------|
| **Admin** (ID:1, ID:2) | ✓ Yes, real EIDs | Full access for management |
| **User** (ID:3) | ✗ No, shows `*****` | Privacy-protected access |

**Note**: Admin status is fixed per account. IDs cannot be changed.

---

## Troubleshooting

### Setup Issues

#### Error: "rsconnect credentials not configured"

**Solution**:
```r
# Run in R:
rsconnect::setAccountInfo(
  name='your-account-name',
  token='YOUR-TOKEN',
  secret='YOUR-SECRET'
)
```
Get credentials from: https://www.shinyapps.io/admin/#/tokens

#### Error: "R is not installed or not in PATH"

**Solution**:
1. Install R from: https://cran.r-project.org/
2. Add R to system PATH
3. Restart command prompt

---

### Data Update Issues

#### Error: "No CSV file found"

**Check**:
- ✓ CSV is in `data_upload/` folder
- ✓ Filename format: `{farm_id}_YYYY-MM-DD.csv`
- ✓ farm_id matches entry in `farms.csv`

#### Error: "Farm ID not found in farms.csv"

**Solution**:
1. Open `farms.csv`
2. Add farm configuration line
3. Ensure farm_id in CSV filename matches

#### Error: "Date parsing failed"

**Solution**:
- Check date column format
- Supported: DD/MM/YYYY, YYYY-MM-DD, MM/DD/YYYY
- Ensure dates are valid

#### Database update fails

**Check**:
- ✓ CSV has required columns (`eid`, `date`)
- ✓ CSV file is not corrupted
- ✓ Database file exists and is not locked
- ✓ Sufficient disk space

---

### Deployment Issues

#### Deployment fails

**Check**:
1. ✓ Internet connection active
2. ✓ rsconnect credentials configured
3. ✓ shinyapps.io account active
4. ✓ App name not already in use

#### Deployment slow

**Expected times**:
- Single farm: ~3 minutes
- 5 farms (parallel): ~3 minutes
- 25 farms (batches of 5): ~15 minutes

**Note**: New farms deploy sequentially (slower but safer).

#### App shows old data after deployment

**Solution**:
1. Check deployment completed successfully
2. Clear browser cache (Ctrl+Shift+R)
3. Wait 1-2 minutes for shinyapps.io to update

---

### Backup Issues

#### Backup not created

**Check**:
- ✓ `farm_backups/{farm_id}/` directory exists
- ✓ Sufficient disk space
- ✓ Write permissions on directory

#### Cannot restore from backup

**Check**:
- ✓ Backup file exists and is not corrupted
- ✓ Backup file has correct naming format
- ✓ Database not locked by another process

---

### Best Practices

**Before updating production**:
1. Test locally: `shiny::runApp("src")`
2. Update local database first
3. Verify data looks correct
4. Check CSV quality

**Managing multiple farms**:
1. Batch updates (drop all CSVs at once)
2. Use parallel deployment for speed
3. Stage rollouts (test farm first)
4. Keep recent backups

**Code changes**:
1. Test thoroughly locally
2. Deploy to all farms for consistency
3. Document changes
4. Keep all farms on same code version

**Security**:
1. Change default passwords immediately
2. Use strong passwords (8+ characters)
3. Limit admin access
4. Don't share credentials

---

### File Organization Tips

**Keep CSVs organized**:
```
data_upload/
  FarmA_2025-01-22.csv
  FarmA_2025-01-23.csv
  FarmB_2025-01-22.csv

After processing, auto-moved to:
data_upload/archive/
```

**Backups are automatic**:
```
farm_backups/
  FarmA/
    FarmA_backup_20250122.duckdb
    FarmA_backup_20250123.duckdb
  FarmB/
    FarmB_backup_20250122.duckdb
```

---

### Getting Help

1. Check this guide first
2. Run `check_setup.bat` to diagnose issues
3. Review error messages carefully
4. Check console output during deployment
5. Contact development team

---

### Quick Command Reference

```cmd
check_setup.bat         # Verify setup
admin_panel.bat         # Launch admin panel
shiny::runApp("src")    # Test locally (in R)
```
