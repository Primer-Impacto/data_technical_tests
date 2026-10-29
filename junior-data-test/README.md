# Junior Data — Technical test · Primer Impacto

Primer Impacto is a field marketing agency: our field workers follow routes, visit points of sale (pharmacies, supermarkets…) and record the outcome of each visit. This test is for recent graduates, so we don't expect you to know our tools. It starts with a short guide built around a solved example, and then asks you to apply the same ideas to a different case. We care far more about how you reason and explain your choices than about a perfect solution. Expect around 30–45 minutes for the guide and two to three hours for the exercise.

## Part 1 — Guided example

Everything runs locally with **dbt** and **DuckDB**. From this folder, run:

```bash
pip install dbt-duckdb
cd dbt
dbt seed --profiles-dir .    # loads the CSVs in seeds/ as tables
dbt run --profiles-dir .     # builds the models in models/
dbt test --profiles-dir .    # runs the data quality tests
```

Then read the following files in order:

1. **`dbt/models/staging/stg_workers.sql`** is a model that cleans the raw workers table. The same province arrives written in several ways (`Málaga` / `MALAGA`, `Valencia/València`, `Coruña, A`), so the model trims, upper-cases and removes accents, and replaces empty values with `UNKNOWN` instead of guessing or silently leaving them blank.
2. **`dbt/models/staging/schema.yml`** declares quality tests on that model (`unique`, `not_null` and `accepted_values`), and **`dbt/tests/`** contains a hand-written test, which fails if its query returns any rows.
3. **`airflow/dags/junior_pipeline.py`** is an Airflow DAG with two tasks, where `load_data >> build_models` means the models are only built once the data has loaded successfully. You don't need to install Airflow; reading and editing the file is enough.

To inspect results, use `dbt show --select stg_workers --profiles-dir .`. When something fails, the full detail is in `logs/dbt.log` and the compiled SQL of each test is in `target/compiled/`. In Airflow, the same output appears in each task's log in the web UI.

## Part 2 — Exercise

The file `dbt/seeds/raw_visits.csv` contains visits, and each visit should have one of four statuses: `OK` (completed), `INCID` (completed with an incident), `INFO` (informational) and `NOVIS` (not carried out). In practice the raw values are messier than that, and some are missing.

1. Create `dbt/models/staging/stg_visits.sql` so that IDs are integers, dates are dates, and the status is always one of the four valid values or `UNKNOWN`.
2. Add tests for `stg_visits` in `schema.yml`: at least a unique, non-null `visit_id` and accepted values for the status. Then write one custom test of your own in `dbt/tests/` that makes sense for visits.
3. Add a third task to the DAG that runs the dbt tests, and place it where you think it belongs in the sequence.

## Part 3 — Questions

Answer these in a `answers.md` file in this folder, briefly and in your own words. Also use that file to explain the decisions you made in Part 2, including what you found in the raw status values.

1. Why place the test task where you did, and what happens to the pipeline if the tests fail?
2. What would your model and your tests do if a new status such as `CANCEL` started arriving next month? Is that the behaviour you want?
3. Why mark missing statuses as `UNKNOWN` rather than dropping those rows? Is there a case where dropping them would be better?

## Submission and rules

Fork this repository, work only inside `junior-data-test`, push to your fork and reply to the email thread with its URL. If something didn't run on your machine, say so in `answers.md` and carry on, since a simple solution that is well explained scores better than a complex one you can't justify. AI assistance (ChatGPT, Copilot, Claude or similar) is not allowed, but official documentation is fine, and we will discuss your decisions in the follow-up conversation.
