-- Run as ACCOUNTADMIN before the first terraform apply
-- Creates the Terraform service account and grants the roles it needs

USE ROLE ACCOUNTADMIN;

CREATE USER IF NOT EXISTS TERRAFORM_USER
  PASSWORD        = 'xxxxxxxxxx'  -- CHANGE THIS TO A STRONG PASSWORD
  DISPLAY_NAME    = 'Terraform Service Account'
  DEFAULT_ROLE    = SYSADMIN
  DEFAULT_WAREHOUSE = data_vwh
  MUST_CHANGE_PASSWORD = FALSE
  COMMENT = 'Service account used by Terraform to manage Snowflake infrastructure';

GRANT ROLE SYSADMIN       TO USER TERRAFORM_USER;
GRANT ROLE SECURITYADMIN  TO USER TERRAFORM_USER;
