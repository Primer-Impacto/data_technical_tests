"""
EJEMPLO RESUELTO: un DAG de Airflow que ejecuta dos tareas en orden.

1. cargar_datos       -> carga los CSV de la carpeta seeds en la base de datos.
2. construir_modelos  -> ejecuta los modelos de dbt (por ejemplo, stg_workers).

En la parte 2 de la prueba tendrás que añadir una tercera tarea a este fichero.
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

DBT_DIR = "/opt/airflow/dbt"  # ruta donde estaría la carpeta dbt dentro de Airflow

default_args = {
    "retries": 1,                         # si una tarea falla, se reintenta una vez
    "retry_delay": timedelta(minutes=5),  # esperando cinco minutos entre intentos
}

with DAG(
    dag_id="pipeline_prueba_junior",
    start_date=datetime(2026, 1, 1),
    schedule="0 6 * * *",  # todos los días a las 06:00
    catchup=False,
    default_args=default_args,
) as dag:

    cargar_datos = BashOperator(
        task_id="cargar_datos",
        bash_command=f"cd {DBT_DIR} && dbt seed --profiles-dir .",
    )

    construir_modelos = BashOperator(
        task_id="construir_modelos",
        bash_command=f"cd {DBT_DIR} && dbt run --profiles-dir .",
    )

    # La flecha indica el orden: construir_modelos solo empieza cuando
    # cargar_datos ha terminado correctamente.
    cargar_datos >> construir_modelos
