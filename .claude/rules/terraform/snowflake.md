---
paths: ["terraform/snowflake/**"]
---

# Terraform / Snowflake Conventions

## Architecture Overview

All Snowflake infrastructure is managed as code in `terraform/snowflake/`. Changes here affect the **production Snowflake account** — treat every `terraform apply` as a production operation.

## Configuration-Driven Design

Resources are **never hardcoded** in `.tf` files. All objects are declared in CSV files under `config/` and loaded via `csvdecode` in `locals.tf`. This is the single most important convention in this module.

| CSV file | What it controls |
|---|---|
| `config/databases.csv` | Databases (name, comment) |
| `config/schemas.csv` | Schemas — applied to **every** database as a cross-product |
| `config/warehouses.csv` | Compute warehouses |
| `config/roles.csv` | Account-level service roles with optional `parent_role` for hierarchy |
| `config/users.csv` | Human and service users |
| `config/functional_roles.csv` | Functional roles granted to end users |
| `config/functional_role_grants.csv` | Maps functional roles → account roles or database roles |

**Rule:** To add a database, schema, warehouse, role, or user — edit the relevant CSV. Do not add a new `resource` block.

## Role Model

Two layers of roles:

1. **Database roles** (generated in `locals.tf`) — scoped per database/schema, auto-generated from the database and schema CSVs:
   - `<DB>__READER` / `<DB>__WRITER` — database-level
   - `<DB>__<SCHEMA>__READER` / `<DB>__<SCHEMA>__WRITER` — schema-level
2. **Functional roles** (`functional_roles.csv`) — granted to humans; aggregate account + database roles via `functional_role_grants.csv`

**Rule:** Never grant privileges directly to a user. Always grant to a functional role, then assign the functional role to the user.

**Rule:** To give a functional role access to a warehouse, add a row to `functional_role_grants.csv` with the auto-generated `<WAREHOUSE_NAME>_USAGE` account role (e.g., `DATA_ENGINEER_VWH_USAGE`). The usage role is auto-generated — do not declare it manually.

## Grant Conventions

- Prefer **future grants** over current-object grants so new tables/views inherit access automatically.
- Database roles handle object-level access (SELECT, INSERT, etc.); account roles in this module are CSV-driven.

## Naming Conventions

- Databases: `UPPER_SNAKE_CASE` (e.g., `ANALYTICS`)
- Schemas: `UPPER_SNAKE_CASE` in CSV; `locals.tf` also applies `upper()` so casing is enforced even if CSV drifts
- Warehouses: `UPPER_SNAKE_CASE`
- Warehouse usage roles: auto-generated as `<WAREHOUSE_NAME>_USAGE` (uppercase)
- Functional roles: `UPPER_SNAKE_CASE` (e.g., `DATA_ENGINEER`, `FINANCE_ANALYST`)
- Database roles: auto-generated as `<DB>__READER`, `<DB>__<SCHEMA>__WRITER`, etc.

## Terraform Workflow

```bash
cd terraform/snowflake
terraform init          # first time or after provider changes
terraform plan          # always review before applying
terraform apply         # applies to production — confirm the plan carefully
```

- Provider: `snowflakedb/snowflake ~> 2.0`
- Required Terraform: `>= 1.9`
- Remote backend: Terraform Cloud (`sf-dbt-snowflake` workspace)
- Credentials: set in `terraform.tfvars` (gitignored) — use `terraform.tfvars.example` as the template

**Rule:** Never commit `terraform.tfvars` or any file containing credentials. It is gitignored.

**Rule:** Never run `terraform apply` without first reviewing `terraform plan`. The plan output must be shared/reviewed before any destructive changes (`destroy`, role removal, user deletion).

## Adding New Resources

### New database
1. Add a row to `config/databases.csv`
2. Terraform will auto-create the database, all schemas (cross-product), and all database roles for it

### New schema
1. Add a row to `config/schemas.csv`
2. All databases will get the new schema — this is intentional (shared schema topology)

### New warehouse
1. Add a row to `config/warehouses.csv`
2. A `<NAME>_USAGE` account role is auto-generated — assign it to functional roles via `functional_role_grants.csv`

### New service role
1. Add a row to `config/roles.csv` with `parent_role` set to `SYSADMIN` (or appropriate parent)
2. Add explicit grants for the role in `grants.tf` if needed

### New functional role (human access pattern)
1. Add a row to `config/functional_roles.csv`
2. Add grant rows to `config/functional_role_grants.csv`:
   - Use dotted notation for database roles: `ANALYTICS.READER`, `ANALYTICS.MARTS_WRITER`
   - Use plain name for account roles: `DATA_VWH_USAGE`, `FINANCE_VWH_USAGE`
3. Assign the functional role to users via `config/users.csv` `default_role` column

### New user
1. Add a row to `config/users.csv`
2. Set `default_role` to the appropriate functional role

## Lessons Learned

- Database roles use dotted notation in `functional_role_grants.csv` (`DATABASE.ROLE_NAME`). A dot in `granted_role` signals a database role grant; no dot = account role grant. This is how `locals.tf` splits them.
- Schemas are a cross-product of all databases × all schemas in the CSV. If a schema should not exist on every database, it needs a separate resource block, not a CSV row.
- `depends_on` is required on most grant resources because Snowflake provider v2 does not infer role/object dependencies automatically.
- The `try()` function is used throughout for optional CSV columns (e.g., `comment`, `display_name`) — always use `try(each.value.field, "")` rather than assuming the column exists.
