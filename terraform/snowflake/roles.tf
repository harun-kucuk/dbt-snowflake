# Generated warehouse usage roles
resource "snowflake_account_role" "warehouse_usage" {
  provider = snowflake.securityadmin
  for_each = local.warehouse_usage_roles
  name     = each.key
}

# Functional roles — aggregate account + database roles for end users
resource "snowflake_account_role" "functional" {
  provider = snowflake.securityadmin
  for_each = local.all_functional_roles
  name     = each.key
  comment  = try(each.value.comment, "")
}

# Generated DB-level and schema-level database roles (scoped per database)
resource "snowflake_database_role" "db_reader" {
  provider   = snowflake.sysadmin
  for_each   = local.db_reader_roles
  database   = each.value.database
  name       = each.value.name
  depends_on = [snowflake_database.this]
}

resource "snowflake_database_role" "db_writer" {
  provider   = snowflake.sysadmin
  for_each   = local.db_writer_roles
  database   = each.value.database
  name       = each.value.name
  depends_on = [snowflake_database.this]
}

resource "snowflake_database_role" "schema_reader" {
  provider   = snowflake.sysadmin
  for_each   = local.schema_reader_roles
  database   = each.value.database
  name       = each.value.name
  depends_on = [snowflake_database.this]
}

resource "snowflake_database_role" "schema_writer" {
  provider   = snowflake.sysadmin
  for_each   = local.schema_writer_roles
  database   = each.value.database
  name       = each.value.name
  depends_on = [snowflake_database.this]
}
