# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What This Is

A dbt + Snowflake data platform. Models transform raw TPCH sample data through three layers:

- **staging** — views, 1:1 with source tables (`stg_tpch__*`)
- **intermediate** — shared enrichment helpers (`int_*`); not consumer-facing
- **marts** — dimensions, facts, and wide tables organized by business domain (`shared/`, `finance/`, `supply_chain/`)

Snowflake infrastructure is managed as Terraform in `terraform/snowflake/`.

## Project Structure

```
dbt/
  models/
    staging/tpch/      # stg_tpch__customers, orders, lineitems, parts, suppliers,
                       # partsuppliers, nations, regions
    intermediate/      # int_nations__with_region (shared nations+regions enrichment)
    marts/
      shared/          # dim_customers, dim_dates (used across domains)
      finance/         # fct_orders, fct_order_items, orders_mart
      supply_chain/    # dim_suppliers, dim_parts
  macros/              # generate_schema_name (env-based schema routing)
  profiles.yml         # dev / prod / ci targets, driven by .env
terraform/snowflake/   # Snowflake infra as code (config-driven via CSV files)
.claude/rules/         # Auto-loading conventions (dbt/, terraform/)
.claude/settings.json  # Hooks — blocks --target prod outside CI/CD
```

## Layer Responsibilities

### Staging
- Rename and lightly cast source columns only — no joins, no business logic
- Materialized as views; the only layer that references `{{ source(...) }}`
- One model per source table

### Intermediate
- Shared join logic that would otherwise be duplicated across multiple mart models
- Currently: `int_nations__with_region` (used by both `dim_customers` and `dim_suppliers`)
- Not consumer-facing — never referenced directly by BI tools
- Add a model here only when the same logic would appear in 2+ marts

### Marts
Organized by business domain. Each domain gets its own subdirectory and Snowflake schema.

| Domain | Schema | Contains |
|---|---|---|
| `shared/` | `marts_shared` | `dim_customers`, `dim_dates` — used across domains |
| `finance/` | `marts_finance` | `fct_orders`, `fct_order_items`, `orders_mart` |
| `supply_chain/` | `marts_supply_chain` | `dim_suppliers`, `dim_parts` |

- **Dimensions** (`dim_*`): descriptive entity attributes with surrogate keys
- **Facts** (`fct_*`): measurable events/transactions with surrogate keys and FK references to dims
- **Wide tables** (`*_mart`): denormalized joins of dims + facts for a specific analytical use case
- The only layer BI tools and analysts query directly
- Add a new subdirectory when introducing a new business domain

## Surrogate Key Pattern

Every `dim_*` and `fct_*` model uses a surrogate key as PK and retains the natural key:

```sql
{{ dbt_utils.generate_surrogate_key(['entity_key']) }} as entity_key,
entity_key                                              as entity_natural_key,
```

Facts join to dimensions on surrogate keys. When joining from staging (natural keys), match on `dim_<entity>.entity_natural_key`. Wide mart tables expose natural keys as `<entity>_id`.

## Environment Setup

Before any dbt command:

```bash
source .venv/bin/activate
set -a && source .env && set +a
cd dbt
```

Required `.env` vars: `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`.

Dev runs write to a personal database (`dev_<username>`) isolated from prod. Schema routing is handled by the `generate_schema_name` macro.

## dbt Commands

```bash
dbt build --target dev -s <selection>   # build + test
dbt test --select <selection>           # test only
dbt docs generate                       # generate docs
```

**Never run `--target prod` directly.** A hook in `.claude/settings.json` blocks it — production deploys happen only via CI/CD on merge to `main`.

## Airflow (Local Orchestration)

The `airflow/` directory contains a self-contained Docker Compose stack that orchestrates the dbt pipeline on a daily schedule via [astronomer-cosmos](https://astronomer.github.io/astronomer-cosmos/). Cosmos reads `ref()` dependencies and creates one Airflow task per dbt model (16 tasks total).

### First-time setup

```bash
# 1. Copy env template and fill in credentials
cp airflow/.env.example airflow/.env

# 2. Generate a stable fernet key and add it to airflow/.env
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# 3. Initialise the DB, create admin user, and register the Snowflake connection
cd airflow
docker compose up airflow-init

# 4. Start the webserver and scheduler
docker compose up -d
```

### Access

- UI: http://localhost:8080 — username `admin`, password `admin`
- Trigger manually: DAGs → `sf_dbt_daily` → Trigger DAG

### Relationship to GitHub Actions

| | GitHub Actions | Airflow |
|---|---|---|
| **When** | On PR / on merge to `main` | Daily schedule (06:00 UTC) |
| **What** | CI validation + prod deploy | Scheduled prod runs |
| **Target** | `ci` (PR) / `prod` (main) | `prod` |

They are independent — Airflow does not replace CI/CD. The same dbt project runs in both contexts; only the trigger mechanism differs.

## SQL Style

- All logic in named CTEs; final `select * from <last_cte>`
- Name CTEs after what they represent: `source`, `renamed`, `joined`, `final`
- Snake_case everywhere
- Aggregations and window functions in their own CTE, not inline

## YAML Conventions

- One `_sources.yml` per source directory
- One `_<layer>.yml` per model directory with descriptions + tests
- Primary keys: `unique` + `not_null`
- Foreign keys: `not_null`
- Grain documented in every model `description`

## Terraform

See `.claude/rules/terraform/snowflake.md` for full conventions. Key rules:

- All resources declared in CSV files under `terraform/snowflake/config/` — never hardcode in `.tf` files
- Always run `terraform plan` before `terraform apply`
- Never commit `terraform.tfvars`

```bash
cd terraform/snowflake
terraform plan
terraform apply   # production — review plan carefully first
```

## Branching

Never commit directly to `main`. Always work on a feature branch:

```bash
git checkout -b feature/<description>
```

## Claude Code Rules

Rules in `.claude/rules/` auto-load based on which files are open:

| Rule file | Applies to |
|---|---|
| `.claude/rules/dbt/staging.md` | `dbt/models/staging/**` |
| `.claude/rules/dbt/intermediate.md` | `dbt/models/intermediate/**` |
| `.claude/rules/dbt/marts.md` | `dbt/models/marts/**` |
| `.claude/rules/airflow/airflow.md` | `airflow/**` |
| `.claude/rules/terraform/snowflake.md` | `terraform/snowflake/**` |

Update these files as new patterns and lessons emerge — they are the team's living conventions.
