"""
sf_dbt_marts.py — Marts DAG (full upstream chain)
Selector: +orders_mart
Models: everything orders_mart depends on — all staging, all intermediate, orders_mart
Use case: guarantee a fully fresh mart by rebuilding the entire upstream graph.
"""
from __future__ import annotations

from datetime import datetime

from cosmos import DbtDag, RenderConfig
from cosmos.constants import LoadMode

from common import default_args, execution_config, operator_args, profile_config, project_config

sf_dbt_marts_dag = DbtDag(
    dag_id="sf_dbt_marts",
    schedule=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    default_args=default_args,
    project_config=project_config,
    profile_config=profile_config,
    execution_config=execution_config,
    render_config=RenderConfig(
        load_method=LoadMode.DBT_MANIFEST,
        select=["+orders_mart"],
    ),
    operator_args=operator_args,
    tags=["dbt", "snowflake", "marts", "subset"],
)
