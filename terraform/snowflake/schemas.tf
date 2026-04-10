resource "snowflake_schema" "this" {
  provider = snowflake.sysadmin
  for_each   = local.all_schemas
  database   = each.value.database
  name       = each.value.schema
  depends_on = [snowflake_database.this]
}
