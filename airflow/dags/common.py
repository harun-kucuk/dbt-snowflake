"""
common.py
---------
Shared cosmos configuration reused across all sf-dbt DAGs.
Import profile_config, execution_config, and operator_args instead of
repeating them in every DAG file.
"""
from __future__ import annotations

import os
from pathlib import Path

from cosmos import ExecutionConfig, ProfileConfig, ProjectConfig
from cosmos.constants import ExecutionMode, InvocationMode
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

DBT_PROJECT_PATH = Path("/opt/airflow/dbt")
DBT_VENV_PATH = Path("/opt/airflow/dbt-venv")
DBT_EXECUTABLE_PATH = DBT_VENV_PATH / "bin" / "dbt"
DBT_MANIFEST_PATH = DBT_PROJECT_PATH / "target" / "manifest.json"

profile_config = ProfileConfig(
    profile_name="sf_dbt",
    target_name="prod",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_default",
        profile_args={
            "database": "ANALYTICS",
            "schema": "public",
            "role": os.environ["SNOWFLAKE_ROLE"],
            "warehouse": os.environ["SNOWFLAKE_WAREHOUSE"],
            "threads": 8,
        },
    ),
)

execution_config = ExecutionConfig(
    execution_mode=ExecutionMode.LOCAL,
    dbt_executable_path=DBT_EXECUTABLE_PATH,
    invocation_mode=InvocationMode.SUBPROCESS,
)

operator_args = {
    "install_deps": True,
}

default_args = {
    "owner": "data-engineering",
    "retries": 2,
    "retry_delay_seconds": 30,
    "email_on_failure": False,
}

project_config = ProjectConfig(
    dbt_project_path=DBT_PROJECT_PATH,
    manifest_path=DBT_MANIFEST_PATH,
)
