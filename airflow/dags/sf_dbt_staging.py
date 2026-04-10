"""
sf_dbt_staging.py — Staging layer DAG
Selector: path:models/staging
Models: all 8 stg_tpch__* views (no warehouse or marts)
Fast to run — all views, no Snowflake compute cost.
"""
from __future__ import annotations

from datetime import datetime

from cosmos import DbtDag, RenderConfig
from cosmos.constants import LoadMode

from common import default_args, execution_config, operator_args, profile_config, project_config

sf_dbt_staging_dag = DbtDag(
    dag_id="sf_dbt_staging",
    schedule=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    default_args=default_args,
    project_config=project_config,
    profile_config=profile_config,
    execution_config=execution_config,
    render_config=RenderConfig(
        load_method=LoadMode.DBT_MANIFEST,
        select=["path:models/staging"],
    ),
    operator_args=operator_args,
    tags=["dbt", "snowflake", "staging", "subset"],
)
