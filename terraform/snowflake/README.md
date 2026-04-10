# Terraform — Snowflake Infrastructure

Manages all Snowflake infrastructure as code: databases, schemas, warehouses, roles, users, and grants.

## Design

**Config-driven** — all objects are declared in CSV files under `config/`. Never hardcode resources in `.tf` files.

| CSV | Controls |
|---|---|
| `config/databases.csv` | Databases |
| `config/schemas.csv` | Schemas (per database — not a cross-product) |
| `config/warehouses.csv` | Virtual warehouses |
| `config/functional_roles.csv` | Human-facing roles (per department) |
| `config/functional_role_grants.csv` | What each functional role can access |
| `config/users.csv` | Human and service users |

**Two-provider pattern** — `SYSADMIN` for objects, `SECURITYADMIN` for roles and grants.

**Role model:** functional roles aggregate database roles and warehouse usage roles declared through CSV config.

## Prerequisites

1. Run `bootstrap_terraform_user.sql` as ACCOUNTADMIN in Snowflake once
2. AWS credentials configured (state stored in S3 — see `../aws/remote_state/`)

## Usage

```bash
# First time
aws-vault exec snowflake-infra -- terraform init

# Day-to-day
aws-vault exec snowflake-infra -- terraform plan -var-file=envs/prod.tfvars
aws-vault exec snowflake-infra -- terraform apply -var-file=envs/prod.tfvars
```

## Adding Resources

| To add | Edit |
|---|---|
| New database | `config/databases.csv` |
| New schema | `config/schemas.csv` (specify `database` column) |
| New warehouse | `config/warehouses.csv` |
| New department role | `config/functional_roles.csv` + `config/functional_role_grants.csv` |
| New user | `config/users.csv` |

## CI/CD

- **PR** → `tf-ci` workflow runs `terraform plan` and posts output as a PR comment
- **Merge to main** → `tf-deploy` workflow runs `terraform apply` automatically
