# SOFT3888_TU16_01_P16

## Company/Department

**SOLES** – School of Life and Environmental Sciences, The University of Sydney

## Project Title

A Dashboard for the Livestock Industry

## Project Description & Scope

This project aims to develop an **interactive Shiny dashboard** for farm data, enabling customers to visualise and monitor data from various agricultural systems. The dashboard will focus on **user interface design**, with interactive features such as drop-down menus, filtering, and data export.

The client will provide the dataset, which may require preprocessing and basic data management before integration into the Shiny app.

📂 Project materials and shared files are available on [OneDrive](https://unisydneyedu-my.sharepoint.com/:f:/g/personal/nkur9658_uni_sydney_edu_au/ElNvjaNpRVJAkyzYYP5XKxEBBMYIW9TUX0ZZt6LlfvBN0g?e=YQaNOC).

## Team Roles (Weeks 2–5)

| Week | Tracker | Manager | Customer Liaison | Programmer | Tester | Doomsayer | Software Researcher |
| ---- | ------- | ------- | ---------------- | ---------- | ------ | --------- | ------------------- |
| 2    | Xinyu   | Yilin   | Aaron            | All        | All    | Aiko      | All                 |
| 3    | Aiko    | Aaron   | Nanami           | All        | All    | Shengjie  | Aaron, Fox          |
| 4    | Nanami  | Aiko    | Yilin            | All        | All    | Fox       | Xinyu, Shengjie     |
| 5    | Fox     | Nanami  | Shengjie         | All        | All    | Xinyu     | Yilin, Aiko         |

## Team Roles (Weeks 6-13)

| Week | Tracker  | Manager | Customer Liaison | Programmer | Tester | Doomsayer |
| ---- | -------- | ------- | ---------------- | ---------- | ------ | --------- |
| 6    | Yilin    | Fox     | Nanami           | All        | All    | Aaron     |
| 7    | Aiko     | Xinyu   | Aaron            | All        | All    | Yilin     |
| 8    | Nanami   | Aiko    | Yilin            | All        | All    | Xinyu     |
| 9    | Shengjie | Fox     | Xinyu            | All        | All    | Fox       |
| 10   | Xinyu    | Aaron   | Aiko             | All        | All    | Nanami    |
| 11   | Fox      | Aiko    | Aaron            | All        | All    | Yilin     |
| 12   | Shengjie | Nanami  | Fox              | All        | All    | Shengjie  |
| 13   | Nanami   | Yilin   | Aiko             | All        | All    | Shengjie  |

## Meeting minutes

| Week | Directories |
| ---- | ----------- |
| 2    | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/main/Minutes_meeting/minutes_meeting_wk2.md |
| 3    | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/main/Minutes_meeting/minutes_meeting_wk3.md |
| 4    | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/main/Minutes_meeting/minutes_meeting_wk4.md |
| 5    | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/main/Minutes_meeting/minutes_meeting_wk5.md |
| 6    | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/main/Minutes_meeting/minutes_meeting_wk6.md |
| 7    | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/main/Minutes_meeting/minutes_meeting_wk7.md |
| 8    | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/main/Minutes_meeting/minutes_meeting_wk8.md |
| 9    | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/main/Minutes_meeting/minutes_meeting_wk9.md |
| 10   | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/yilin_branch/Minutes_meeting/minutes_meeting_wk10.md |
| 11   | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/yilin_branch/Minutes_meeting/minutes_meeting_wk11.md |
| 12   | https://github.sydney.edu.au/nkur9658/SOFT3888_TU16_01_P16/blob/yilin_branch/Minutes_meeting/minutes_meeting_wk12.md |
| 13   |  |

## Testing and Test Coverage

### Running Tests

#### Unit Tests and Coverage
To run the unit test suite and generate test coverage reports:

```bash
# Run unit tests and generate coverage report
Rscript run_coverage.R
```

This will:
- Execute all unit tests in the `tests/` directory
- Generate a comprehensive test coverage report
- Create an HTML coverage report (`test_coverage.html`)
- Output coverage statistics to the console
- Automatically install any missing required packages

#### Integration Tests
To run the comprehensive integration test suite:

```bash
# Run all integration tests
Rscript run_integration_tests.R
```

This will:
- Execute all integration tests covering complete workflows
- Test component interactions and data flow
- Show a clean summary with pass/fail counts
- Display success message if all tests pass

#### Email Integration Tests
To run email-specific integration tests:

```bash
# Run email integration tests
Rscript run_email_integration_tests.R
```

This will:
- Test email functionality and scheduling
- Validate email report generation
- Test email credentials and automation
- Generate detailed email test reports

### Test Coverage Structure
The project includes comprehensive test coverage organized by functionality:

#### Unit Tests
- **Filter functionality** (`tests/testthat/filter/`)
  - `test-filter-core-functions.R` - Core filtering logic and choice functions
  - `test-filter-edge-cases.R` - Edge cases and error handling
  - `test-filter-grouping-logic.R` - Data grouping and aggregation
  - `test-filter-observers.R` - UI observer logic
  - `test-filter-reactives.R` - Reactive data processing
  - `test-filter-ui-builders.R` - UI component builders
  - `test-filter-uncovered-paths.R` - Additional coverage paths
  - `test-filter-varying-cols.R` - Dynamic column handling

- **Application Component Tests**
  - `test-cohorts-functions.R` - Cohorts functionality
  - `test-customise-functions.R` - Customise functionality
  - `test-summary-stats.R` - Summary statistics
  - `test-shiny-app.R` - Shiny app integration

#### Integration Tests
- **Complete Workflow Tests** (`test-integration-*.R`)
  - `test-integration-complete-workflows.R` - End-to-end user journeys
  - `test-integration-cohorts-analysis.R` - Cohorts analysis workflows
  - `test-integration-data-management.R` - Data management workflows
  - `test-integration-filtering-visualization.R` - Filtering and visualization workflows
  - `test-integration-report-generation.R` - Report generation workflows
  - `test-integration-timeseries-analysis.R` - Time series analysis workflows
  - `test-integration-customise.R` - Customization workflows

- **Email Integration Tests**
  - `test-email-features.R` - Email functionality and features
  - `test-email-credentials.R` - Email credential management
  - `test-email-report-generation.R` - Email report generation
  - `test-email-integration.R` - Email integration with Shiny

#### Test Configuration
- `tests/testthat/setup.R` - Test setup and configuration
- `tests/testthat.R` - Test runner configuration
- `tests/testthat/_snaps/` - Test snapshots for UI testing
- `run_integration_tests.R` - Integration test runner
- `run_email_integration_tests.R` - Email integration test runner

### Test Statistics
The project includes a comprehensive test suite with:

- **613 Integration Tests** - Covering complete workflows and component interactions
- **75 Email Tests** - Testing email functionality, scheduling, and automation
- **Multiple Unit Test Suites** - Testing individual components and business logic
- **100% Test Coverage** - For core business logic and data processing functions

### Coverage Analysis
The coverage script focuses on testable business logic components:
- **Included in coverage**: Core filtering logic, data processing, choice functions, and business rules
- **Excluded from coverage**: Shiny reactive functions that require active session context (tested via integration tests)

Coverage reports are generated automatically and can be viewed in the HTML output file (`test_coverage.html`).

### Required R Packages

The test coverage script requires several R packages. The script will automatically install missing packages, but you can also install them manually:

```r
# Core packages for testing and coverage
install.packages(c("covr", "testthat"))

# Data manipulation and analysis
install.packages(c("dplyr", "lubridate", "tidyr", "rlang"))

# Shiny and web interface
install.packages(c("shiny", "shinyWidgets", "bslib", "DT"))

# Visualization
install.packages(c("ggplot2", "plotly", "RColorBrewer"))
```

**Note**: The `run_coverage.R` script will automatically install any missing packages from CRAN when executed.

## Repository Structure

This repository structure follows the format outlined in the [guideline](./.github/CONTRIBUTING/guideline.md). Weekly goals, role rotations, and task updates are documented in the [team contribution](./.github/CONTRIBUTING/team_contribution.md) file.

```
SOFT3888_TU16_01_P16/
├── run_coverage.R                   # Unit test coverage script
├── run_integration_tests.R          # Integration test runner
├── run_email_integration_tests.R    # Email integration test runner
├── test_coverage.html               # Generated test coverage report
├── Contracts_and_Deed_poll/         # Project contracts and signed deed poll files
│   ├── Deed_polls/                  # Individual deed poll documents
│   │   ├── Aaron deed poll.docx
│   │   ├── Deed Poll Fox B.docx
│   │   ├── deed poll YL.pdf
│   │   ├── Nanami_Kuranari_deed_poll.pdf
│   │   ├── Sarah deed poll.pdf
│   │   ├── ShengjieGu_deeppoll.pdf
│   │   └── Xinyu_Deed poll .pdf
│   ├── Group_Contract_Week_2_5-2-1.pdf
│   └── group_contract.pdf
├── lib/                            # R package dependencies (auto-generated)
│   ├── bootstrap-3.3.5/            # Bootstrap CSS framework
│   ├── crosstalk-1.2.1/            # Interactive widgets
│   ├── datatables-binding-0.34.0/  # DataTables integration
│   ├── dt-core-1.13.6/             # DataTables core
│   ├── highlight.js-6.2/           # Syntax highlighting
│   ├── htmltools-fill-0.5.8.1/     # HTML tools
│   ├── htmlwidgets-1.6.4/          # HTML widgets
│   └── jquery-3.6.0/               # jQuery library
├── Minutes_meeting/                 # Meeting minutes and documentation
│   ├── minutes_meeting_wk2.md
│   ├── minutes_meeting_wk3.md
│   ├── minutes_meeting_wk4.md
│   ├── minutes_meeting_wk5.md
│   ├── minutes_meeting_wk6.md
│   ├── minutes_meeting_wk7.md
│   ├── minutes_meeting_wk8.md
│   ├── minutes_meeting_wk9.md
│   └── minutes_meeting_wk10.md
├── Original_Code/                   # Original source code and datasets
│   ├── app.R                       # Original Shiny app entry point
│   ├── wowByrne_v2.xlsx
│   └── wowByrne.xlsx
├── Requirements/                    # User stories, acceptance criteria, scope docs
│   ├── dashboard_user_story.md
│   ├── SOFT3888_Client_Meeting_checklists.pdf
│   ├── User Story & Acceptance Criteria.pdf
│   └── yilin_specification.md
├── src/                            # Main application source code
│   ├── app.R                       # Main Shiny application entry point
│   ├── ui.R                        # User interface definition
│   ├── server.R                    # Server logic
│   ├── global.R                    # Global variables and setup
│   ├── cohorts_page.R              # Cohorts page functionality
│   ├── customise.R                 # Customization features
│   ├── distribution.R              # Distribution analysis and visualization
│   ├── filter.R                    # Data filtering functionality
│   ├── report_page.R               # Report generation functionality
│   ├── summary_stats.R             # Summary statistics
│   ├── timeseries_page.R           # Time series analysis
│   ├── data.duckdb                 # Database file
│   └── wowByrne_v2.csv             # Main dataset
├── tests/                          # Comprehensive test suite
│   ├── testthat.R                  # Test runner configuration
│   └── testthat/                   # Testthat test files
│       ├── setup.R                 # Test setup and configuration
│       ├── _snaps/                 # Test snapshots
│       ├── filter/                 # Filter functionality unit tests
│       │   ├── test-filter-core-functions.R
│       │   ├── test-filter-edge-cases.R
│       │   ├── test-filter-grouping-logic.R
│       │   ├── test-filter-observers.R
│       │   ├── test-filter-reactives.R
│       │   ├── test-filter-ui-builders.R
│       │   ├── test-filter-uncovered-paths.R
│       │   └── test-filter-varying-cols.R
│       ├── test-cohorts-functions.R    # Cohorts unit tests
│       ├── test-customise-functions.R  # Customise unit tests
│       ├── test-shiny-app.R            # Shiny app unit tests
│       ├── test-summary-stats.R        # Summary stats unit tests
│       ├── test-email-features.R       # Email functionality tests
│       ├── test-email-credentials.R    # Email credential tests
│       ├── test-email-report-generation.R # Email report tests
│       ├── test-email-integration.R    # Email integration tests
│       ├── test-integration-complete-workflows.R # Complete workflow tests
│       ├── test-integration-cohorts-analysis.R   # Cohorts integration tests
│       ├── test-integration-data-management.R    # Data management integration tests
│       ├── test-integration-filtering-visualization.R # Filtering integration tests
│       ├── test-integration-report-generation.R  # Report generation integration tests
│       ├── test-integration-timeseries-analysis.R # Time series integration tests
│       └── test-integration-customise.R          # Customise integration tests
├── XP_summaries/                   # eXtreme Programming (XP) summaries
│   ├── Aaron_XP_Summary.md
│   ├── Fox_XP_Summary.md
│   ├── Nanami_XP_Summary.md
│   ├── Sarah_XP_Summary.md
│   ├── Shengjie_XP_Summary.md
│   ├── Xinyu_XP_summary.md
│   └── Yilin_XP_Summary.md
└── README.md                       # Project overview and repo guide
```

**Note**: The `lib/` directory contains R package dependencies and is auto-generated when running the application. It is not tracked in git (see `.gitignore`).
