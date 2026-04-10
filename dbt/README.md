# dbt — Snowflake Transformation Layer

Transforms Snowflake's TPC-H sample data into documented dimensional models and analyst-facing marts using dbt Core.

## Model Layers

```
models/
  staging/
    tpch/             # stg_tpch__customers, stg_tpch__orders, etc.
  intermediate/
    int_*             # shared enrichment logic
  marts/
    shared/           # dim_customers, dim_dates
    finance/          # fct_orders, fct_order_items, orders_mart
    supply_chain/     # dim_suppliers, dim_parts
```

| Layer | Materialization | Selects from | Naming |
|---|---|---|---|
| staging | view | `source()` only | `stg_<source>__<table>.sql` |
| intermediate | table | `ref()` only | `int_<entity>__<purpose>.sql` |
| marts | table | `ref()` only | `dim_<entity>.sql`, `fct_<process>.sql`, `<subject>_mart.sql` |

## Current Model Inventory

- 8 staging models under `models/staging/tpch`
- 1 intermediate model: `int_nations__with_region`
- 7 mart models across `shared`, `finance`, and `supply_chain`
- 1 snapshot: `snp_customers`

## Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r ../requirements.txt
cp ../.env.example ../.env   # fill in Snowflake credentials
set -a && source ../.env && set +a
dbt deps
dbt debug   # should show "All checks passed!"
```

## Common Commands

```bash
dbt build --target dev                        # build + test all
dbt build --target dev -s staging.*           # staging layer only
dbt build --target dev -s +fct_orders         # model + upstream deps
dbt build --target dev -s path:models/marts/finance
dbt test --select <model>
dbt docs generate && dbt docs serve
```

## Profiles

| Target | Database | Used by |
|---|---|---|
| `dev` | `DEV_<username>` | local development |
| `ci` | `CI_<pr_number>` | GitHub Actions PR |
| `prod` | `ANALYTICS` | GitHub Actions on merge to main |
