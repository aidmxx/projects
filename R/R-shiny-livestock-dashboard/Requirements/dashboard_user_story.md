# Epic: A Dashboard for the Livestock Industry

## User Story

**Title:** Multi‑Role, High‑Performance Shiny Dashboard for Farm Animal Performance Tracking

**As**  
Luciano Gonzalez — Animal Scientist and project owner?

**I want**  
a secure, role‑based web dashboard (built in R Shiny, with the option to integrate a performant database backend) that allows users to filter, visualize, download, and receive automated reports of cleaned farm data

**So that**  
I and other authorized stakeholders can monitor livestock growth, welfare, and production trends, make timely operational decisions, and communicate insights — even in rural areas with limited connectivity.

---

## Detailed Description

The dashboard will replace the client’s current basic Shiny interface with a more **visually appealing, responsive, and feature‑rich design** while keeping the underlying R Shiny environment for maintainability. It must handle **large datasets** (25k+ rows) without noticeable lag and support **multiple types of users** with different permissions.

---

## Acceptance Criteria

### 1. Data Handling & Updates

- Import cleaned datasets (CSV or Excel) produced in SAS by the client.
- Capability to connect to a relational database (e.g., PostgreSQL/MySQL) for better scalability.
- Automated daily (or scheduled) refresh of data, without manual upload.
- Retain option for manual uploads in early iterations.

### 2. Access Control & Security

- Password‑protected login.
- User roles:
  - **Owner/Farmer:** Full access, including data & chart downloads.
  - **Analyst:** View charts only; no raw data downloads.
- Ensure confidential information (farmer details, farm locations, EIDs) is not exposed to unauthorized users.
- Potential for admin role to manage user accounts.

### 3. Filtering & Search

- Minimum of 3 **search‑enabled** drop‑down selectors:
  - Year
  - Animal Class/Category (ewe, lamb, sire, etc.)
  - Additional field (e.g., breed, treatment status)
- Ability to extend filters beyond 3 fields if needed.
- Searchable drop‑downs to handle large lists (5,000+ IDs) efficiently.

### 4. Visualizations

- **Tab/Page 1:** Key Summary Stats
  - Min, max, mean, median, mode for:
    - Last day of data
    - Last 15 days
    - Last month
    - Overall period
  - Displayed prominently in metric “cards” at top of page.
- **Tab/Page 2:** Histograms
  - Distribution of weights or other selected metrics.
  - Adjustable bin sizes.
- **Tab/Page 3:** Time‑series Graphs
  - Growth rate, weight change over time, grouped and individual animals.
  - Option to overlay multiple years or groups.
- Remove display of empty or irrelevant data series.
- Responsive hover tooltips with point‑specific values.
- Potential for click‑through to secondary detail views.

### 5. Performance Optimisation

- Pre‑aggregate data where possible to reduce on‑the‑fly computation load.
- Consider database queries instead of in‑app filtering for heavy datasets.
- Maintain acceptable load times even with limited rural internet.

### 6. Downloads & Exports

- Owners can:
  - Download raw data filtered to current selection or full dataset.
  - Export charts as PNG/SVG.
- Analysts restricted to chart exports only.
- Default export format for data is CSV (Excel optional).

### 7. Automated Summary Reports

- Daily or weekly email to authorized users with:
  - Key summary stats
  - Small chart snapshots
  - Overall trend commentary
- Fully automated sending (via mail API or integration).
- Manual trigger option for ad‑hoc reports.

### 8. UI/UX & Aesthetics

- Clean, modern theme — more visually appealing than current dashboard.
- Logical grouping of features with intuitive navigation.
- Avoid clutter; only show relevant elements for selected data.

---

## Constraints & Dependencies

- Must remain in R Shiny for maintainability by the client.
- Database integration optional in first release but must be architected for possible future use.
- Needs to support integration of client‑generated scripts at later stages.
- Solution should not require advanced HTML/JS knowledge for client‑side maintenance.

---

## Priority Features (MVP)

1. Cleaned dataset import & refresh
2. Role‑based access control
3. Three search‑enabled filters
4. Summary stats tab
5. Time‑series chart tab
6. CSV download (role‑restricted)
