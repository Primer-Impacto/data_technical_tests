"""
SOLVED EXAMPLE: an Airflow DAG that runs two tasks in order.
In Part 2 you will add a third task to this file.
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

DBT_DIR = "/opt/airflow/dbt"  # where the dbt folder would live inside Airflow

default_args = {
    "retries": 1,                         # retry a failed task once
    "retry_delay": timedelta(minutes=5),  # after waiting five minutes
}

with DAG(
    dag_id="junior_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule="0 6 * * *",  # every day at 06:00
    catchup=False,
    default_args=default_args,
) as dag:

    load_data = BashOperator(
        task_id="load_data",
        bash_command=f"cd {DBT_DIR} && dbt seed --profiles-dir .",
    )

    build_models = BashOperator(
        task_id="build_models",
        bash_command=f"cd {DBT_DIR} && dbt run --profiles-dir .",
    )

    # build_models only starts once load_data has finished successfully.
    load_data >> build_models
