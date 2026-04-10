{% docs __overview__ %}
# dbt-snowflake

An end-to-end analytics engineering project built on Snowflake with dbt, Terraform, Airflow, and GitHub Actions.

This project models Snowflake's TPC-H sample data through a layered dbt pipeline, provisions Snowflake infrastructure as code, and orchestrates dbt runs through Airflow.

## Model Layers

| Layer | Materialization | Purpose |
|---|---|---|
| **staging** | view | 1:1 with source tables — rename and cast only |
| **intermediate** | table | Shared enrichment helpers reused across marts |
| **marts** | table | Consumer-facing dims, facts, and wide tables |

## Mart Domains

- **shared** — `dim_customers`, `dim_dates`
- **finance** — `fct_orders`, `fct_order_items`, `orders_mart`
- **supply_chain** — `dim_suppliers`, `dim_parts`

## Source

[GitHub Repository](https://github.com/harun-kucuk/dbt-snowflake)
{% enddocs %}
