"""
sf_dbt_intermediate.py — Intermediate layer DAG
Selector: path:models/intermediate
Models: int_nations__with_region
Use case: refresh shared enrichment logic independently of staging or marts.
"""
from __future__ import annotations

from datetime import datetime

from cosmos import DbtDag, RenderConfig
from cosmos.constants import LoadMode

from common import default_args, execution_config, operator_args, profile_config, project_config

sf_dbt_intermediate_dag = DbtDag(
    dag_id="sf_dbt_intermediate",
    schedule=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    default_args=default_args,
    project_config=project_config,
    profile_config=profile_config,
    execution_config=execution_config,
    render_config=RenderConfig(
        load_method=LoadMode.DBT_MANIFEST,
        select=["path:models/intermediate"],
    ),
    operator_args=operator_args,
    tags=["dbt", "snowflake", "intermediate", "subset"],
)
