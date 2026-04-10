output "database_names" {
  description = "All managed Snowflake database names"
  value       = keys(snowflake_database.this)
}

output "warehouse_names" {
  description = "All managed Snowflake warehouse names"
  value       = keys(snowflake_warehouse.this)
}

output "role_names" {
  description = "All managed Snowflake role names"
  value       = sort(concat(keys(snowflake_account_role.functional), keys(snowflake_account_role.warehouse_usage)))
}

output "user_names" {
  description = "All managed Snowflake user names"
  value       = keys(snowflake_user.this)
}

output "schema_names" {
  description = "All managed Snowflake schemas (database__schema)"
  value       = keys(snowflake_schema.this)
}
