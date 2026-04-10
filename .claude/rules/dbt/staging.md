---
paths: ["dbt/models/staging/**"]
---

# Staging Conventions

Staging is the first transformation layer. It is a thin, mechanical pass over raw source data.

## Rules

- **1:1 with source tables** — one staging model per source table, nothing more
- **No joins** — staging models never join to other models or sources
- **No business logic** — no conditional logic, no derived metrics, no aggregations
- **No filtering** — bring all rows through; filtering is a downstream concern
- Only staging models may use `{{ source(...) }}`; all downstream models use `{{ ref(...) }}`
- Always materialized as views (set in `dbt_project.yml` — do not override)

## Naming

- File: `stg_<source>__<table>.sql` (double underscore between source and table name)
- Source for this project: `tpch` → e.g., `stg_tpch__customers.sql`

## SQL Structure

```sql
with source as (
    select * from {{ source('tpch', 'customer') }}
),

renamed as (
    select
        c_custkey   as customer_key,
        c_name      as customer_name,
        -- ... rename all columns
    from source
)

select * from renamed
```

- Always two CTEs: `source` and `renamed`
- Final `select * from renamed`
- Rename every column to be self-describing (remove source prefixes like `c_`, `o_`, `l_`)
- Cast types if the source column type is wrong (e.g., string date → date), but don't transform values

## Column Naming

- Remove source system prefixes (`c_`, `o_`, `l_`, `n_`, `r_`, `p_`, `s_`, `ps_`)
- Use `_key` suffix for all key/ID columns (`customer_key`, `nation_key`, etc.)
- Use snake_case throughout

## YAML Files

Each staging directory must have:
- `_sources.yml` — declares the source, database, schema, and source-level tests
- `_stg_tpch.yml` — documents every staging model with descriptions and column tests

## Tests

- `unique` + `not_null` on the primary key of each staging model
- `not_null` on foreign key columns

## Lessons Learned

- (Add entries here as issues are discovered)
