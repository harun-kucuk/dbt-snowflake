resource "snowflake_database" "this" {
  provider = snowflake.sysadmin
  for_each = local.all_databases
  name     = each.key
  comment  = try(each.value.comment, "")
}
