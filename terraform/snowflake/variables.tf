variable "snowflake_org" {
  description = "Snowflake organization name"
  type        = string
}

variable "snowflake_account" {
  description = "Snowflake account name"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake user for Terraform"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password for Terraform user"
  type        = string
  sensitive   = true
}
