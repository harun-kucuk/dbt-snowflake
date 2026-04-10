"""
sf_dbt_adhoc.py
---------------
Ad-hoc DAG that accepts a dbt command and selector as trigger-time parameters.
Credentials are pulled from the snowflake_default Airflow Connection — no
dependency on profiles.yml or environment variables.

Trigger from the UI (Trigger DAG w/ config) or CLI:

  # Run a model and all downstream
  airflow dags trigger sf_dbt_adhoc --conf '{"command": "run", "selector": "stg_tpch__orders+"}'

  # Test a specific intermediate model
  airflow dags trigger sf_dbt_adhoc --conf '{"command": "test", "selector": "int_nations__with_region"}'

  # Build (run + test) a whole layer
  airflow dags trigger sf_dbt_adhoc --conf '{"command": "build", "selector": "path:models/marts"}'

Supported commands: run, test, build
"""
from __future__ import annotations
from datetime import datetime
from pathlib import Path

from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.models.param import Param
from airflow.operators.bash import BashOperator

DBT = Path("/opt/airflow/dbt-venv/bin/dbt")
DBT_PROJECT_DIR = Path("/opt/airflow/dbt")


def _snowflake_env() -> dict[str, str]:
    """Pull credentials from the snowflake_default Airflow Connection."""
    conn = BaseHook.get_connection("snowflake_default")
    extra = conn.extra_dejson
    return {
        "SNOWFLAKE_ACCOUNT": extra.get("account", conn.host),
        "SNOWFLAKE_USER": conn.login,
        "SNOWFLAKE_PASSWORD": conn.password,
        "SNOWFLAKE_ROLE": extra.get("role", ""),
        "SNOWFLAKE_WAREHOUSE": extra.get("warehouse", ""),
        "SNOWFLAKE_DATABASE": extra.get("database", "ANALYTICS"),
        "SNOWFLAKE_SCHEMA": extra.get("schema", "public"),
    }


with DAG(
    dag_id="sf_dbt_adhoc",
    schedule=None,               # manual trigger only
    start_date=datetime(2025, 1, 1),
    catchup=False,
    default_args={
        "owner": "data-engineering",
        "retries": 0,
        "email_on_failure": False,
    },
    params={
        "command": Param(
            default="build",
            type="string",
            enum=["run", "test", "build"],
            description="dbt command to execute",
        ),
        "selector": Param(
            default="stg_tpch__orders+",
            type="string",
            description='dbt node selector, e.g. "stg_tpch__orders+", "dim_customer", "path:models/marts"',
        ),
    },
    tags=["dbt", "snowflake", "adhoc"],
) as dag:

    dbt_adhoc = BashOperator(
        task_id="dbt_adhoc",
        bash_command=(
            f"{DBT} deps "
            f"--project-dir {DBT_PROJECT_DIR} "
            f"--profiles-dir {DBT_PROJECT_DIR} "
            f"--target prod "
            f"&& "
            f"{DBT} {{{{ params.command }}}} "
            f"--select {{{{ params.selector }}}} "
            f"--project-dir {DBT_PROJECT_DIR} "
            f"--profiles-dir {DBT_PROJECT_DIR} "
            f"--target prod"
        ),
        env=_snowflake_env(),
    )
