---
paths: ["dbt/models/intermediate/**"]
---

# Intermediate Conventions

The intermediate layer holds **shared enrichment helpers only** — logic that would otherwise
be duplicated across multiple mart models. It is not for consumer-facing entities; those
belong in `marts/` as `dim_*` or `fct_*` models.

## When to Add an Intermediate Model

Add a model to `intermediate/` when:
- The same join or transformation would be duplicated in 2+ mart models
- The logic is not independently useful to BI consumers

Do NOT add to intermediate:
- Dimension tables (→ `marts/dim_<entity>.sql`)
- Fact tables (→ `marts/fct_<process>.sql`)
- Wide analytical tables (→ `marts/<domain>_mart.sql`)

## Current Models

| Model | Purpose |
|---|---|
| `int_nations__with_region` | Nations joined to regions — shared by `dim_customers` and `dim_suppliers` |

## Naming

`int_<entity>s__<verb_phrase>.sql` — double underscore between entity and verb.

## Rules

- No surrogate keys in intermediate — enrichment helpers pass through natural keys only
- Marts reference intermediate helpers; intermediate never references marts
- Every model requires a YAML entry in `_intermediate.yml`
- All models use `{{ ref(...) }}` only — never `{{ source(...) }}`

## Materialization

Set in `dbt_project.yml`:
- All intermediate models: `table`
- Schema: `intermediate`

## Tests

- `unique` + `not_null` on the natural key (if one exists)
- `not_null` on all required columns

## Lessons Learned

- (Add entries here as issues are discovered)
