---
paths: ["airflow/**"]
---

# Airflow Conventions

Airflow orchestrates the sf-dbt pipeline via [astronomer-cosmos](https://astronomer.github.io/astronomer-cosmos/). The stack lives in `airflow/` and runs locally via Docker Compose.

## Architecture

```
airflow/
├── Dockerfile              # extends apache/airflow:2.10.4-python3.11
│                           # installs cosmos; bakes dbt-snowflake venv at /opt/airflow/dbt-venv
├── requirements.txt        # astronomer-cosmos==1.14.0 (no dbt here — avoids dep conflicts)
├── docker-compose.yml      # LocalExecutor + Postgres; bind-mounts ../dbt into container
├── .env.example            # template — copy to .env, never commit .env
└── dags/
    ├── common.py               # shared cosmos config (project, profile, execution, operator args)
    ├── sf_dbt.py               # full pipeline DAG, runs daily at 06:00 UTC
    ├── sf_dbt_staging.py       # subset: path:models/staging (manual)
    ├── sf_dbt_intermediate.py  # subset: path:models/intermediate (manual)
    ├── sf_dbt_marts.py         # subset: +orders_mart (manual)
    ├── sf_dbt_orders.py        # subset: stg_tpch__orders+ (manual)
    └── sf_dbt_adhoc.py         # ad-hoc: accepts command + selector at trigger time (manual)
```

## How Cosmos Works Here

- `ExecutionMode.LOCAL` + `InvocationMode.SUBPROCESS`: each dbt task calls the pre-built dbt binary at `/opt/airflow/dbt-venv/bin/dbt` as a subprocess — no venv recreation, no lock contention
- `LoadMode.DBT_MANIFEST`: cosmos reads `dbt/target/manifest.json` at DAG parse time (bind-mounted from host) — no Snowflake call needed, parse completes in ~60ms
- `SnowflakeUserPasswordProfileMapping`: cosmos generates a dbt profile at runtime from the `snowflake_default` Airflow Connection — `dbt/profiles.yml` is bypassed for Airflow runs
- One Airflow task is created per dbt model: `<model>.run` and `<model>.test`

## Adding a New DAG

All DAGs share `project_config`, `profile_config`, `execution_config`, and `operator_args` from `common.py`. To add a subset DAG, copy `sf_dbt_orders.py` and change:

```python
dag_id="sf_dbt_<name>",
schedule=None,              # manual, or a cron string
render_config=RenderConfig(
    load_method=LoadMode.DBT_MANIFEST,
    select=["<dbt selector>"],   # e.g. "tag:daily", "path:models/marts", "int_customers__enriched+"
),
tags=["dbt", "snowflake", "<name>"],
```

Common dbt selectors:
- `stg_tpch__orders+` — model and all downstream
- `+orders_mart` — orders_mart and all upstream
- `path:models/staging` — all staging models
- `path:models/intermediate` — all intermediate models
- `path:models/marts` — all mart models
- `tag:daily` — all models tagged `daily` in dbt_project.yml

## Snowflake Connection

The `snowflake_default` Airflow Connection must have `account` in the `extra` JSON — cosmos reads it from there:

```json
{
  "account": "<org>-<account>",
  "role": "SYSADMIN",
  "warehouse": "DATA_VWH",
  "database": "ANALYTICS",
  "schema": "public"
}
```

Missing `account` in extra causes: `Credentials in profile "sf_dbt" invalid: 'account' is a required property`

## Known Gotchas

- **`dag_discovery_safe_mode`**: Airflow only processes files containing the literal string `"DAG"` or `"airflow"`. Cosmos DAGs import `DbtDag` (mixed-case "Dag") and nothing from `airflow`, so they're silently skipped. Fixed via `AIRFLOW__CORE__DAG_DISCOVERY_SAFE_MODE: "false"` in docker-compose.yml
- **`LoadMode.DBT_MANIFEST` requires manifest.json**: cosmos reads `/opt/airflow/dbt/target/manifest.json` at parse time. This file is bind-mounted from the host's `dbt/target/`. Run any dbt command once to generate it. If it doesn't exist, DAGs will fail to parse
- **Don't use `ExecutionMode.VIRTUALENV` with a pre-built venv**: cosmos always calls `python -m virtualenv <path>` at task time to recreate the venv, which fails if seed packages (pip/wheel) in the existing venv don't match what the virtualenv tool expects. Use `LOCAL` + `SUBPROCESS` instead
- **Adhoc DAG uses Airflow connection, not profiles.yml**: `BashOperator.env` is populated from `snowflake_default` via `BaseHook.get_connection()` — never from env vars, so credentials can't drift
- **FERNET_KEY must be stable**: changing it after first run makes the stored Snowflake connection password undecryptable. Generate once, put in `airflow/.env`, never rotate
- **`dbt/profiles.yml` is not used by cosmos**: cosmos bypasses it via the Airflow Connection. `profiles.yml` is used only for local dev and GitHub Actions CI
- **dbt dep conflicts**: never add `dbt-snowflake` to `airflow/requirements.txt` — it conflicts with the Airflow base image. dbt lives only in the baked venv at `/opt/airflow/dbt-venv`

## Local Commands

```bash
# First-time setup
cp airflow/.env.example airflow/.env   # fill in credentials + fernet key
cd airflow
docker compose up airflow-init         # DB migration + admin user + Snowflake connection
docker compose up -d                   # start webserver + scheduler

# UI: http://localhost:8080 — admin / admin

# Trigger a DAG manually
docker compose exec airflow-scheduler airflow dags trigger sf_dbt_daily

# Clear a stale lock file
docker compose exec airflow-scheduler rm -f /opt/airflow/dbt-venv/cosmos_virtualenv.lock

# Check run states
docker compose exec airflow-scheduler airflow dags list-runs -d sf_dbt_daily

# Rebuild after Dockerfile changes
docker compose down && docker compose build && docker compose up airflow-init && docker compose up -d
```

## Relationship to GitHub Actions

| | GitHub Actions | Airflow |
|---|---|---|
| Trigger | PR open / merge to `main` | Schedule / manual |
| Purpose | CI validation + prod deploy | Scheduled orchestration |
| Target | `ci` (PR) / `prod` (merge) | `prod` |

They are independent. Never replace the GitHub Actions deploy with Airflow.
