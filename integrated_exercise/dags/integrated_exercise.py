import datetime

from airflow import DAG
from airflow.providers.amazon.aws.operators.batch import BatchOperator

dag = DAG(
    dag_id="niels-integrated-exercise-dag",
    default_view="graph",
    schedule_interval=None,
    start_date=datetime.datetime(2023, 11, 10),
    catchup=False,
)

BatchOperator(
    dag=dag,
    task_id="raw_ingest",
    job_definition="niels-integrated-exercise",
    job_queue="niels-integrated-exercise-job-queue",
    job_name="niels_raw_ingest",
    overrides={
        "executionDate": "{{ ds }}"
    }
)
