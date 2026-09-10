# Data Engineer — Technical test · Primer Impacto

## Context

Primer Impacto is a field marketing agency. We manage campaigns for FMCG and pharma clients in which field workers visit points of sale (also referred to as intervention points) following assigned routes, recording visit outcomes as they go.

This test is **not** about extracting business insights — it's about building a small, correct, tested, and production-minded pipeline: ingest raw data, reconcile it, model it in dbt, and orchestrate it. We want to see how you engineer, not just how you query.

You've been given **7 raw CSV files**, simplified but realistic, corresponding to activity in **2026**. Two of them (`pos_omni.csv` and `pos_gi.csv`) describe the **same kind of entity — points of sale — coming from two different source systems**, with different schemas, different IDs, and partial overlap. Reconciling them into a single trustworthy dimension is the core engineering challenge of this test.

You have **one week**.

---

## The data

| File | Description | Key columns |
|---|---|---|
| `raw_projects.csv` | Projects per client | `project_id`, `client_code`, `project_name` |
| `raw_campaigns.csv` | Campaigns per project | `campaign_id`, `project_id`, `campaign_start_date`, `campaign_end_date`, `total_visits_planned` |
| `raw_routes.csv` | Routes per campaign | `route_id`, `campaign_id`, `route_start_date`, `route_end_date`, `route_status` |
| `raw_workers.csv` | Field workers | `employee_id`, `employee_first_name`, `employee_address_province`, `employee_contract_type` |
| `raw_visits.csv` | Visits to points of sale | `visit_id`, `intervention_point_id`, `route_id`, `campaign_id`, `visit_date`, `visit_status`, `updated_at` |
| `pos_omni.csv` | Points of sale — **our own system** | `intervention_point_id`, `intervention_point_name`, `intervention_point_province`, `intervention_point_latitude/longitude` |
| `pos_gi.csv` | Points of sale — **a partner system in the group**, different schema | `ext_id`, `point_name`, `address_street`, `address_number`, `address_city`, `address_zip` |

Both POS files describe overlapping real-world locations exported independently, so names, formatting, and IDs don't line up — some stores appear (with variations) in both files, some only in one. That mismatch is intentional; figuring out how to reconcile it is part of the test.

### Visit status values

`OK` (completed), `INCID` (completed with incidence), `INFO` (informational), `NOVIS` (not carried out). The raw data is messier than this — inconsistent casing, trailing spaces, some nulls — cleaning that up is part of the staging layer.

---

## The challenge

### Phase 1 — Ingestion (`/ingestion`)

Use **Airbyte** (OSS, local) to ingest the raw CSVs into whatever destination your dbt project reads from (local Postgres or DuckDB).

- **Minimum required:** the Airbyte **connection configuration** (source: File/CSV, destination, sync mode per source — full refresh vs. incremental, and cursor field where relevant) committed as YAML/JSON under `/ingestion`, with a short note on why you chose that sync mode per source.
- **Bonus:** actually stand Airbyte up locally (`abctl` or the official docker-compose) and run the sync for real. If you do, say so in `notes.md` and how to reproduce it — but this is not required to pass the test, so don't burn your week on infra if your machine fights you.

### Phase 2 — dbt transformations (`/dbt`) — mandatory

Using **dbt Core** with **DuckDB** or a local **Postgres**:

1. **Staging layer** (`models/staging/stg_*.sql`) — one model per raw source: standardise types, dates, and strings; handle nulls. Justify every cleaning decision.
2. **`dim_pos_unified`** (mandatory) — reconcile `pos_omni` and `pos_gi` into a single points-of-sale dimension:
   - At minimum, a rule-based match (e.g. normalized name + postal code / city).
   - Each row should carry a match status (e.g. `MATCHED`, `OMNI_ONLY`, `GI_ONLY`) and which source(s) it came from.
   - **Bonus:** a fuzzy/similarity-based match (e.g. edit distance on normalized names, or distance-based if you keep coordinates) instead of, or in addition to, the exact rule — with a confidence score.
   - Document your matching logic and its false-positive/false-negative trade-offs in the dbt docs or `dbt/README.md`.
3. **An incremental model** (mandatory) — e.g. a `fct_visits` built with `materialized='incremental'`, a `unique_key`, and using `updated_at` to only process new/changed rows. Explain your incremental strategy.
4. **dbt tests** — `not_null`, `unique`, `relationships` on primary/foreign keys, plus **at least one custom test** (e.g. no duplicate matched POS in `dim_pos_unified`, valid lat/long ranges).
5. **One dbt macro of your own** (e.g. a `normalize_string()` used in staging) — doesn't need to be elaborate, just show you can abstract reusable SQL/Jinja.
6. **`dbt/README.md`** — layer decisions, how to run locally, what you'd add with more time.

### Phase 3 — Orchestration with Airflow (`/airflow`) — mandatory

Provide a local Airflow setup (docker-compose is fine — the official quickstart works) and build **one DAG** that:

1. Triggers the Airbyte sync (or a stub task representing it, consistent with what you did in Phase 1).
2. Runs `dbt build` (staging + marts + tests).
3. Notifies on failure (a log line or a stub callback is enough — no need to wire a real Slack/Teams webhook).
4. Has sensible task dependencies, a schedule, and basic retry/timeout config.

**Not required:** a DAG-per-source factory pattern, cross-DAG asset/dataset triggering, multi-environment (dev/staging/prod) branches, Terraform, or RBAC. If you have opinions on how you'd evolve toward any of that, put them in `notes.md` — we want to hear the reasoning, not see it built.

---

## Deliverables summary

```
/ingestion
  └── <airbyte connection config(s)>.yml

/dbt
  ├── dbt_project.yml
  ├── profiles.yml              (use env vars — do NOT commit credentials)
  ├── README.md
  ├── models/
  │   ├── staging/               stg_*.sql (one per raw source)
  │   └── marts/                 dim_pos_unified.sql, fct_visits.sql (incremental)
  └── tests/                     .yml or .sql test files

/airflow
  └── dags/                      your DAG

notes.md                         top-level file: assumptions, matching trade-offs,
                                  what you'd do with more time, how you'd scale this
                                  toward the "not required" items above
```

---

## Evaluation criteria

| Area | What we assess |
|---|---|
| Ingestion design | Do source/destination/sync-mode choices make sense per source? |
| Entity resolution | Is the POS matching logic sound and honestly evaluated (false positives/negatives discussed)? |
| dbt engineering | Staging cleanliness, incremental correctness, test coverage, macro reuse |
| Orchestration | DAG structure, dependencies, idempotency, failure handling |
| Judgement | Do you know what to leave out of a one-week test, and can you argue for what you'd add next? |
| Communication | Clarity of reasoning and justification at every step |

---

## Important notes

- **Justify everything.** A cleaning choice, a matching rule, a sync mode, a DAG design — write down your reasoning. We're as interested in *how you think* as in the output.
- **AI assistance is not recommended.** We want to assess your own engineering judgement. Using AI-generated code or analysis makes that impossible for us to evaluate, and it will show in the follow-up conversation.

---

## Getting started

1. **Fork this repository** to your own GitHub account.
2. Clone your fork locally:

```bash
git clone https://github.com/<your-github-username>/data_technical_tests.git
cd data_technical_tests/data-engineer-test

pip install dbt-duckdb
dbt --version
```

3. When you are done, make sure everything is pushed to your fork and reply to the email thread where you received this test with your fork URL.

> Questions? Open an issue in this repo.

Good luck!
