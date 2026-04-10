terraform {
  required_version = ">= 1.9"
  required_providers {
    snowflake = { source = "snowflakedb/snowflake", version = "~> 2.0" }
  }

  backend "s3" {
    bucket       = "snowflake-infra-terraform-state-<aws-account-id>"
    key          = "snowflake/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}

provider "snowflake" {
  alias             = "sysadmin"
  organization_name = var.snowflake_org
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = "SYSADMIN"
}

provider "snowflake" {
  alias             = "securityadmin"
  organization_name = var.snowflake_org
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = "SECURITYADMIN"
}
