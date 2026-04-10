resource "snowflake_user" "this" {
  provider          = snowflake.securityadmin
  for_each          = local.all_users
  name              = each.key
  first_name        = try(each.value.first_name, "")
  last_name         = try(each.value.last_name, "")
  display_name      = try(each.value.display_name, each.key)
  default_role      = try(each.value.default_role, "PUBLIC")
  default_warehouse = try(each.value.default_warehouse, "")
  depends_on        = [snowflake_account_role.functional, snowflake_account_role.warehouse_usage]
}

resource "snowflake_grant_account_role" "user_roles" {
  provider   = snowflake.securityadmin
  for_each   = local.all_users
  role_name  = each.value.default_role
  user_name  = each.key
  depends_on = [snowflake_user.this, snowflake_account_role.functional, snowflake_account_role.warehouse_usage]
}
