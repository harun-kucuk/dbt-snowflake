# Terraform — AWS Remote State Bootstrap

Provisions the S3 bucket and lock file configuration used as the Terraform remote backend for the Snowflake module.

> **Run once.** After applying, add the backend block to `terraform/snowflake/main.tf` and run `terraform init -migrate-state` there.

## Resources

| Resource | Name |
|---|---|
| S3 bucket | `snowflake-infra-terraform-state-<account-id>` |
| Bucket versioning | Enabled |
| Bucket encryption | AES-256 |
| State locking | S3 native (`use_lockfile = true`) |

## Usage

```bash
aws-vault exec snowflake-infra -- terraform init
aws-vault exec snowflake-infra -- terraform plan
aws-vault exec snowflake-infra -- terraform apply
```

Or via Makefile:

```bash
make init
make plan
make apply
```

## State

This module uses **local state** intentionally — it cannot use the remote backend it is creating to store its own state.

## Backend config to add to `terraform/snowflake/main.tf`

```hcl
backend "s3" {
  bucket       = "snowflake-infra-terraform-state-<aws-account-id>"
  key          = "snowflake/terraform.tfstate"
  region       = "<aws-region>"
  use_lockfile = true
}
```
