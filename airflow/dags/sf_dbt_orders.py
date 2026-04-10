"""
sf_dbt_orders.py — Orders subset DAG
Selector: stg_tpch__orders+
Models: stg_tpch__orders and all downstream dependencies selected by dbt
"""
from __future__ import annotations

from datetime import datetime

from cosmos import DbtDag, RenderConfig
from cosmos.constants import LoadMode

from common import default_args, execution_config, operator_args, profile_config, project_config

sf_dbt_orders_dag = DbtDag(
    dag_id="sf_dbt_orders",
    schedule=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    default_args=default_args,
    project_config=project_config,
    profile_config=profile_config,
    execution_config=execution_config,
    render_config=RenderConfig(
        load_method=LoadMode.DBT_MANIFEST,
        select=["stg_tpch__orders+"],
    ),
    operator_args=operator_args,
    tags=["dbt", "snowflake", "orders", "subset"],
)
