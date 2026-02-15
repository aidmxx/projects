# Meeting minutes — Week 10

## Out-class tutorial meeting

### Subject: Weekly progress update and sprint planning

### Project Name: A dashboard for the livestock industry

### Facilitator: Nanami Kuranari

### Prepared by: Aaron Wang

### Mode: Online

### Date: 13/10/2025

### Time: 13:00-14:00

### Attendees: Nanami Kuranari, Yilin Li, Aaron Wang, Sarah Aiko Sitompul, Xinyu Shu, Shengjie Gu

### Absent: Fox Barancewicz

| # | Agenda Item | Description/Comments | Decision/Action | Who? | Items for escalation |
|---|---|---|---|---|---|
| 1 | What has been completed? | Refinements to individual components; minor bug fixes; filters stable; cohort page copy + header fix; skeleton for automated email flow; repo hygiene (PRs, lint). | Merge ready PRs; mark small fixes “done”; keep a changelog for the report. | All attendees (module owners to merge) | N/A |
| 2 | What is in progress? | Module integrations; separation of **Owner vs Analyst** roles; **start R unit testing** (`testthat`) for data utilities & cohort logic; group report drafting. | Finish integrations; create `tests/testthat/`; add basic tests for helpers, cohort selection, and wrangling; continue report sections. | All attendees; each module owner writes tests for their code | Need SMTP creds/content approval for email automation; confirm final dataset snapshot for tests |
| 3 | What is working well? | Strong comms & delegation; shared debugging sessions; steady progress despite no client meeting; UI consistency improving. | Maintain Slack updates & code reviews; keep short cross-module check-ins. | All attendees | N/A |
| 4 | What needs improvement? | Code cleanliness/duplication; low test coverage; security/access control paths need a pass. | Cleanup sweep (naming, dead code, comments); add edge-case tests; review auth & input validation. | All attendees; module owners lead | If blocked, seek quick tutor guidance on auth pattern |
| 5 | Reminders | Target: implement everything by end of week; confirm individual report sections; push to GitHub frequently; prep for next review. | Daily commits; short sync before week’s end; confirm report assignments in Slack thread. | All attendees | Post availability early; confirm next client/tutor demo slot |

---

## In-class tutorial meeting

### Subject: 

### Project Name: A dashboard for the livestock industry

### Facilitator: Nanami Kuranari

### Prepared by: Aaron Wang

### Mode: In person

### Date: 14/10/2025

### Time: 16:00–18:00

### Attendees: Nanami Kuranari, Yilin Li, Aaron Wang, Sarah Aiko Sitompul, Xinyu Shu, Shengjie Gu

### Absent: Fox Barancewicz

| # | Agenda Item | Description/Comments | Decision/Action | Who? | Items for escalation |
|---|---|---|---|---|---|
| 1 | What has been completed? | Week-10 deliverables confirmed: presentation slide deck outlined; report structure aligned to Report page; report intro drafted; testing plan split into test sets (1–6); coding ownership set for cohort plots, email workflow, testing, and anonymization. | Lock ownership in tracker; create/assign GitHub issues for each deliverable. | All attendees | N/A |
| 2 | What is in progress? | Cohort plots (breed & top/bottom); email workflow; anonymization; **R unit tests** (`testthat`) aligned to test sets; slide deck drafting; report intro polishing. | Push first PRs; create `tests/testthat/`; add baseline tests for data utilities & cohort logic; iterate on slide deck and intro. | Module owners | Need SMTP credentials/content for email; confirm dataset/privacy constraints for anonymization outputs. |
| 3 | What is working well? | Clear role allocation and deadlines; frequent Slack updates; stable branching/PR flow; collaborative debugging across modules. | Continue daily check-ins and code reviews; keep Report page as source of truth. | All attendees | N/A |
| 4 | What needs improvement? | Test coverage still low; some cross-module wiring pending; report sections need consistent style/references. | Add edge-case tests; complete integration stubs; perform style pass on report sections. | All attendees (test owners lead) | If blocked on integration or anonymization approach, raise to tutor quickly. |
| 5 | Reminders | **Deadlines:** slide deck by **Sunday W10**; report intro and QoGP by **W10**; assigned test sets before end of week. Keep committing frequently and updating the Report page. | Daily commits; post progress in Slack; tag PRs with `W10`. | All attendees | Share availability early; line up next review/demo slot. |



---

## Tutor meeting (No tutor meeting due to Tutor absent this week)

### Subject: 

### Project Name: A dashboard for the livestock industry

### Facilitator: Penghui Wen, Nanami Kuranari

### Prepared by: Aaron Wang

### Mode: In person

### Date: 14/10/2025

### Time: 16:00–18:00

### Attendees: 

### Absent: 

| #  | Agenda Item              | Description/Comments | Decision/Action | Who? | Items for escalation |
|----|--------------------------|----------------------|-----------------|------|----------------------|
| 1  | What has been completed? |                      |                 |      |                      |
| 2  | What is in progress?     |                      |                 |      |                      |
| 3  | What is working well?    |                      |                 |      |                      |
| 4  | What needs improvement?  |                      |                 |      |                      |
| 5  | Reminders                |                      |                 |      |                      |

## Client meeting

### Subject:

### Project Name: A dashboard for the livestock industry

### Facilitator:

### Prepared by:

### Mode:

### Date:

### Time:

### Attendees:

### Absent:

| #  | Agenda Item              | Description/Comments | Decision/Action | Who? | Items for escalation |
|----|--------------------------|----------------------|-----------------|------|----------------------|
| 1  | What has been completed? |                      |                 |      |                      |
| 2  | What is in progress?     |                      |                 |      |                      |
| 3  | What is working well?    |                      |                 |      |                      |
| 4  | What needs improvement?  |                      |                 |      |                      |
| 5  | Reminders                |                      |                 |      |                      |