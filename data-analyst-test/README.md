# Data Analyst — Technical test · Primer Impacto

## Context

Primer Impacto is a field marketing agency. We manage campaigns for FMCG (Fast-Moving Consumer Goods) and pharma clients in which field workers visit points of sale (also referred to as intervention points or points of intervention) — pharmacies, parapharmacies, supermarkets, etc. — following assigned routes. During each visit, workers complete a form with questions: checking product facings, training pharmacy staff, recording visit outcomes, and more.

You have been given **10 raw CSV files** that represent a simplified but realistic version of our operational data model. The data corresponds to activity in **2026** across a portfolio of pharma and parapharmacy clients.

Your mission is to clean the data, model it, and extract business insights from it — exactly as you would in your first weeks in the role.

---

## The data model

The dataset covers the following entities and their relationships:

- **Clients** have one or more **projects**
- **Projects** have one or more **campaigns**, each with a date range and a planned number of visits
- **Campaigns** have **form questions** associated to them (the questionnaire field workers fill in during visits)
- **Campaigns** are executed through **routes**, and each route is assigned to one or more **workers**
- **Visits** are carried out at **points of sale (intervention points)** and are linked to a campaign and a route
- Each visit generates **responses**, one per question answered

Part of the challenge is to figure out the correct dimensional model from the data itself.

### Files

| File | Description | Key columns |
|---|---|---|
| `raw_clients.csv` | Clients (pharma / FMCG companies) | `client_id`, `client_name`, `sector` |
| `raw_projects.csv` | Projects per client | `project_id`, `client_id`, `project_name` |
| `raw_campaigns.csv` | Campaigns per project | `campaign_id`, `project_id`, `campaign_start_date`, `campaign_end_date`, `total_visits_planned` |
| `raw_questions.csv` | Form questions per campaign | `question_id`, `campaign_id`, `question_name`, `question_type`, `question_category` |
| `raw_workers.csv` | Field workers | `employee_id`, `employee_first_name`, `employee_address_province`, `employee_contract_type` |
| `raw_pos.csv` | Points of sale / intervention points | `intervention_point_id`, `intervention_point_name`, `intervention_point_province` |
| `raw_routes.csv` | Routes per campaign | `route_id`, `campaign_id`, `route_start_date`, `route_end_date` |
| `raw_route_employee.csv` | Worker ↔ route assignment | `route_employee_id`, `route_id`, `employee_id`, `main_employee` |
| `raw_visits.csv` | Visits to points of sale | `visit_id`, `campaign_id`, `intervention_point_id`, `route_id`, `visit_date`, `visit_status` |
| `raw_responses.csv` | Form answers per visit | `answer_id`, `visit_id`, `question_id`, `question_type`, `answer` |

### Visit status values

| Value | Meaning |
|---|---|
| `OK` | Visit completed successfully |
| `INCID` | Visit completed with an incidence |
| `INFO` | Informational visit (no full report) |
| `NOVIS` | Visit not carried out |

### Question types

| Code | Type |
|---|---|
| `S` | Single selector (pick one option) |
| `M` | Multi selector (pick several options) |
| `N` | Numeric |
| `T` | Free text |
| `D` | Date |

---

## The challenge

The test has **three phases** that build on each other. You have **one week**.

---

### Phase 1 — EDA & data quality (`/eda`)

Deliver a Jupyter notebook (or equivalent) with:

1. **Exploratory data analysis** — distributions, nulls, cardinalities, outliers, and date ranges across all tables
2. **Data quality issues** — identify at least 3 problems in the raw data and explain how you would handle them, justifying your approach
3. **Star schema proposal** — propose the dimensional model you will build in Phase 2; draw it or describe it clearly, and justify your grain and dimension choices

---

### Phase 2 — dbt transformations (`/dbt`) — mandatory

Using **dbt Core** with **DuckDB** (free, local, zero setup) or **BigQuery Sandbox** (free tier):

1. **Staging layer** (`models/staging/stg_*.sql`) — one model per raw CSV: standardise date formats, cast types, trim strings, handle nulls. Justify every cleaning decision.
2. **Marts layer** (`models/marts/`) — at least two business-ready models:
   - `mart_campaign_performance` — campaign-level visit KPIs
   - `mart_visit_responses` — flattened visit + answer table ready for BI consumption
3. **dbt tests** (`tests/`) — at minimum `not_null`, `unique`, and `relationships` tests on primary and foreign keys
4. **`dbt/README.md`** — explain your layer decisions, how to run the project locally, and what you would add with more time

> **DuckDB quickstart:** `pip install dbt-duckdb`. Place the raw CSVs in `/data/raw` (already there) and load them as dbt seeds or external sources. No database credentials needed.

---

### Phase 3 — Dashboard (`/dashboard`)

Using **Power BI**, **Tableau**, **Looker Studio**, or **Python** (Streamlit / Plotly / Seaborn):

Build a dashboard that answers the following business question:

> *"The operations team needs to understand how active campaigns are performing and whether field workers are completing their routes. Management wants a portfolio view across clients and projects."*

**We do not prescribe which metrics to show.** A senior analyst should identify the relevant KPIs from the data and the business context. For every metric you include, explain in your notes why you chose it and what business decision it supports.

Deliverable: push a `.pbix`, `.twbx`, Looker Studio link, or Streamlit app to `/dashboard`.

---

## Deliverables summary

```
/eda
  └── eda.ipynb                 (or .html export)

/dbt
  ├── dbt_project.yml
  ├── profiles.yml              (use env vars — do NOT commit credentials)
  ├── README.md
  ├── models/
  │   ├── staging/              stg_*.sql  (one per raw table)
  │   └── marts/                mart_*.sql (at least 2)
  └── tests/                    .yml or .sql test files

/dashboard
  └── <your file, link, or app>

notes.md                        top-level file with decisions, assumptions, and what you'd do with more time
```

---

## Evaluation criteria

| Area | What we assess |
|---|---|
| SQL & modelling | Star schema quality, correct grain, clean joins |
| dbt | Layer structure, test coverage, documentation |
| EDA | Depth of analysis, ability to spot and explain data quality issues |
| BI / visualisation | Clarity, hierarchy, metric relevance to the business |
| Business judgement | Do the chosen KPIs make sense for a field marketing company? |
| Communication | Clarity of reasoning and justification at every step |

---

## Important notes

- **Justify everything.** For every decision you make — a cleaning choice, a model design, a metric you pick or discard — write down your reasoning. We are as interested in *how you think* as in the final output. An answer without justification will not be evaluated.
- **AI assistance is not recommended.** We want to assess your own analytical thinking and SQL/dbt skills. Using AI-generated code or analysis makes it impossible for us to do that, and it will show in the follow-up conversation.

---

## Getting started

1. **Fork this repository** to your own GitHub account using the "Fork" button at the top right of this page
2. Clone your fork locally:

```bash
git clone https://github.com/<your-github-username>/data_technical_tests.git
cd data_technical_tests

# install dbt with DuckDB adapter (recommended)
pip install dbt-duckdb

# verify
dbt --version
```

3. When you are done, make sure everything is pushed to your fork and reply to the email thread where you received this test with your fork URL.

> Questions? Open an issue in this repo.

Good luck!
