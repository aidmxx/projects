# Specification: Download Feature after Filtering

## Background
The client requires the ability to extract filtered data from the dashboard for offline analysis, reporting, and record-keeping. This feature is essential for supporting decision-making in the livestock industry, where stakeholders may need raw datasets or formatted reports outside of the application.

## Purpose
Enable users to download filtered data from the dashboard so they can perform offline analysis, share results, or generate reports in different formats.

## Functional Requirements
- The system shall provide a Download Data option after filters are applied.
- The download must allow exporting either:
    - Filtered raw table data only, or
    - Filtered data including charts/reports (if selected by the user).
- The system shall support downloads in CSV, Excel, and PDF formats.
- File names must reflect selected filters and the export date (e.g., `filteredData_AnimalClass_Lamb_2025-08-15.csv`).
- The system shall check user permissions:
    - Owners can download both raw data and reports.
    - Analysts can download reports but not raw datasets.
- The system shall enforce any defined size limits (e.g., up to 25k rows per export).
- Export must complete within 3 seconds for datasets ≤25k rows.

## Non-Functional Requirements
- The system shall ensure downloaded files maintain correct encoding (UTF-8).
- Data security must be preserved (e.g., anonymized identifiers for Analysts).
- The system shall prevent unauthorized downloads via direct URL access.

## Acceptance Criteria
- Users can select and download filtered datasets in the chosen format.
- File names correctly display applied filters and date.
- Permissions correctly restrict access by role (Owner vs Analyst).
- Downloads complete within acceptable time limits.
- Attempts to bypass restrictions are blocked and logged.