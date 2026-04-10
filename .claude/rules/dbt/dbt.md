---
paths: ["dbt/**"]
---

# dbt Conventions

General rules that apply across all dbt layers in this project.

## Environment

Before running any dbt command:

```bash
source .venv/bin/activate
set -a && source .env && set +a
cd dbt
```

Required env vars: `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`.

## Data Flow

```
source (SNOWFLAKE_SAMPLE_DATA.TPCH_SF1)
  → staging (views, stg_tpch__*)
      → intermediate (tables, int_*) [shared enrichment helpers only]
          → marts (tables, dim_* / fct_* / *_mart)
```

- `{{ source(...) }}` is used **only** in staging models
- All other models use `{{ ref(...) }}` exclusively
- Marts reference intermediate or other marts — never staging directly

## Materialization

Set in `dbt_project.yml` — do not override per-model without a specific reason:

| Layer | Materialization | Schema |
|---|---|---|
| staging | view | `staging` |
| intermediate | table | `intermediate` |
| marts | table | `marts` |

## Naming

- Staging: `stg_<source>__<table>.sql` (double underscore between source and table)
- Intermediate: `int_<entity>s__<verb_phrase>.sql` (shared helpers only)
- Dimensions: `dim_<entity>.sql`
- Facts: `fct_<process>.sql`
- Wide marts: `<domain>_mart.sql`
- YAML files: `_sources.yml` for sources, `_<layer>.yml` for models

## SQL Style

- All logic in named CTEs; final `select * from <last_cte>`
- Name CTEs after what they represent: `source`, `renamed`, `joined`, `aggregated`, `final`
- Snake_case for all identifiers
- No subqueries — use CTEs instead
- Keep derived columns (calculations, expressions) in their own CTE, not mixed into joins

## Testing

Every model must have a YAML entry with:
- `unique` + `not_null` on the primary key
- `not_null` on all foreign keys
- `not_null` on columns documented as required
- Grain documented in the model `description`

## Packages in Use

- `dbt_utils`: `generate_surrogate_key` (dim_* and fct_* surrogate keys), `date_spine` (dim_dates)

## Lessons Learned

- (Add entries here as issues are discovered)
