---
paths: ["dbt/models/marts/**"]
---

# Marts Conventions

Marts are the final, consumer-facing layer. They contain dimensions, facts, and wide
denormalized tables optimized for BI tools and ad-hoc analytics.

## Model Types

- **`dim_<entity>.sql`** — descriptive attributes about an entity (one row per entity)
- **`fct_<process>.sql`** — measurable events or transactions (one row per event)
- **`<domain>_mart.sql`** — wide denormalized table joining dims + facts for a specific use case

## Rules

- Select only from `{{ ref(...) }}` pointing to intermediate helpers (`int_*`) or other marts — never from staging directly
- Dims and facts may reference each other within marts (e.g. `fct_orders` refs `dim_customers`)
- Materialized as tables
- One YAML file (`_marts.yml`) covers all models in the directory

## Domain Organization

Marts are organized by business domain — each subdirectory maps to its own Snowflake schema:

| Domain | Schema | Models |
|---|---|---|
| `shared/` | `marts_shared` | `dim_customers`, `dim_dates` |
| `finance/` | `marts_finance` | `fct_orders`, `fct_order_items`, `orders_mart` |
| `supply_chain/` | `marts_supply_chain` | `dim_suppliers`, `dim_parts` |

Each domain has its own `_<domain>.yml` YAML file. Add a new subdirectory + schema block in `dbt_project.yml` when introducing a new domain.

## Surrogate Key Pattern

Every `dim_*` and `fct_*` model uses a surrogate key as PK and retains the natural key:

```sql
{{ dbt_utils.generate_surrogate_key(['entity_key']) }} as entity_key,
entity_key                                              as entity_natural_key,
```

- Surrogate key: `<entity>_key` — used for joins between dims and facts
- Natural key: `<entity>_natural_key` — retained for traceability; exposed as `<entity>_id` in wide marts

## Naming

- `dim_<entity>.sql` — singular entity name (e.g. `dim_customers`, `dim_parts`)
- `fct_<process>.sql` — process or event name (e.g. `fct_orders`, `fct_order_items`)
- `<domain>_mart.sql` — business domain (e.g. `orders_mart`)
- Wide mart columns: expose natural keys as `<entity>_id` (not surrogates)

## SQL Structure

```sql
-- dim example
with source as (
    select * from {{ ref('stg_tpch__...') }}
),

enrichment as (
    select * from {{ ref('int_...') }}   -- intermediate helper if needed
),

joined as (
    select
        {{ dbt_utils.generate_surrogate_key([...]) }} as <entity>_key,
        source.<natural_key>                          as <entity>_natural_key,
        -- attributes
    from source
    left join enrichment on ...
)

select * from joined
```

```sql
-- fct example
with events as (
    select * from {{ ref('stg_tpch__...') }}
),

dim as (
    select * from {{ ref('dim_...') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key([...]) }} as <event>_key,
        events.<natural_key>                          as <event>_natural_key,
        dim.<entity>_key,   -- surrogate FK
        -- measures
    from events
    left join dim on events.<natural_key> = dim.<entity>_natural_key
)

select * from final
```

## YAML

Each domain directory has its own `_<domain>.yml` (e.g. `_finance.yml`). It must include for every model:
- Description with grain
- `unique` + `not_null` on surrogate PK
- `unique` + `not_null` on natural key (dim and fct models)
- `not_null` on all FK columns

## Lessons Learned

- (Add entries here as issues are discovered)
