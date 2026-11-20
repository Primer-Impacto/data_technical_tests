# WEEKLY KPI tab: rules

*Copied from the "README" tab of the client's Google Sheet "Spain Field Programme FY26".
Written by the client.*

## Layout

- Every Monday, add one block of **9 rows** for the week that ended on the previous Saturday,
  below the previous week's block.
- Use exactly the row labels and the row order of the template.
- **Do not insert, rename, move or delete columns.** Our regional dashboards read this tab by
  column position.
- The block must be complete by **Monday 12:00 CET**.

## Calendar

- Our weeks run from **Sunday to Saturday**.
- Week 1 is the week that contains 1 January.
- Week label: `YYYY-Www`. Example: `2026-W46` = Sunday 8 November to Saturday 14 November 2026.

## KPI definitions

| Column | Definition |
|---|---|
| Visits | Number of completed store visits by the field team during the week. A visit that covers both product lines counts once in each line, and once in TOTAL. |
| Visits Goal | Weekly goal valid for the week (from the agreed goals file). |
| Visits % Goal | Visits / Visits Goal, as a whole percentage (e.g. `108%`). |
| Visits WoW | (this week − previous week) / previous week, as a whole percentage (e.g. `-9%`). Empty if the previous week is 0 or unknown. |
| Training Sessions | Training sessions reported on those visits. Same attribution rule as Visits. |
| RSAs Trained | Retail sales associates trained, as reported on those visits. Same attribution rule as Visits. |
| RSAs Trained Goal | Weekly goal valid for the week. |
| RSAs Trained % Goal | RSAs Trained / RSAs Trained Goal, as a whole percentage. |
| Sell-out Units | Units sold minus units returned, as reported by the retailers for the week. |
| Sell-out WoW | Same rule as Visits WoW, on Sell-out Units. |

## Totals

- `WEAR TOTAL` and `XR TOTAL`: sum of the three retailers. Their goals are the sum of the
  retailers' goals.
- `TOTAL`: all visits of the week, each counted once. Its goals are the `ALL` rows of the goals
  file. Sell-out is the sum of everything.
