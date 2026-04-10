# ── Functional roles ───────────────────────────────────────────────────────────

# Grant account roles into functional roles
resource "snowflake_grant_account_role" "functional_account" {
  provider         = snowflake.securityadmin
  for_each         = local.functional_account_grants
  role_name        = each.value.granted_role
  parent_role_name = each.value.functional_role
  depends_on       = [snowflake_account_role.functional, snowflake_account_role.warehouse_usage]
}

# Grant database roles into functional roles
resource "snowflake_grant_database_role" "functional_db" {
  provider           = snowflake.securityadmin
  for_each           = local.functional_db_grants
  database_role_name = "\"${each.value.database}\".\"${each.value.db_role}\""
  parent_role_name   = each.value.functional_role
  depends_on         = [snowflake_account_role.functional, snowflake_database_role.db_reader, snowflake_database_role.db_writer, snowflake_database_role.schema_reader, snowflake_database_role.schema_writer]
}

# ── Warehouse usage roles ──────────────────────────────────────────────────────

resource "snowflake_grant_privileges_to_account_role" "warehouse_usage_role" {
  provider          = snowflake.securityadmin
  for_each          = local.warehouse_usage_roles
  account_role_name = each.key
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = each.value.warehouse
  }
  depends_on = [snowflake_warehouse.this, snowflake_account_role.warehouse_usage]
}

# ── Schema → DB role hierarchy ────────────────────────────────────────────────
# Grant each schema reader into its database's READER role
# so ANALYTICS.READER inherits all ANALYTICS.STAGING_*_READER, ANALYTICS.MARTS_*_READER, etc.

resource "snowflake_grant_database_role" "schema_reader_to_db_reader" {
  provider           = snowflake.sysadmin
  for_each           = local.schema_reader_roles
  database_role_name = snowflake_database_role.schema_reader[each.key].fully_qualified_name
  parent_database_role_name = snowflake_database_role.db_reader["${each.value.database}__READER"].fully_qualified_name
  depends_on         = [snowflake_database_role.schema_reader, snowflake_database_role.db_reader]
}

resource "snowflake_grant_database_role" "schema_writer_to_db_writer" {
  provider           = snowflake.sysadmin
  for_each           = local.schema_writer_roles
  database_role_name = snowflake_database_role.schema_writer[each.key].fully_qualified_name
  parent_database_role_name = snowflake_database_role.db_writer["${each.value.database}__WRITER"].fully_qualified_name
  depends_on         = [snowflake_database_role.schema_writer, snowflake_database_role.db_writer]
}

# ── DB-level database roles ────────────────────────────────────────────────────

resource "snowflake_grant_privileges_to_database_role" "db_reader_schema_usage" {
  provider           = snowflake.sysadmin
  for_each           = local.all_schemas
  database_role_name = snowflake_database_role.db_reader["${each.value.database}__READER"].fully_qualified_name
  privileges         = ["USAGE"]
  on_schema {
    schema_name = "\"${each.value.database}\".\"${each.value.schema}\""
  }
  depends_on = [snowflake_schema.this, snowflake_database_role.db_reader]
}

resource "snowflake_grant_privileges_to_database_role" "db_reader_future_tables" {
  provider           = snowflake.sysadmin
  for_each           = local.db_reader_roles
  database_role_name = snowflake_database_role.db_reader[each.key].fully_qualified_name
  privileges         = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = each.value.database
    }
  }
  depends_on = [snowflake_database.this, snowflake_database_role.db_reader]
}

resource "snowflake_grant_privileges_to_database_role" "db_reader_future_views" {
  provider           = snowflake.sysadmin
  for_each           = local.db_reader_roles
  database_role_name = snowflake_database_role.db_reader[each.key].fully_qualified_name
  privileges         = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = each.value.database
    }
  }
  depends_on = [snowflake_database.this, snowflake_database_role.db_reader]
}

resource "snowflake_grant_privileges_to_database_role" "db_writer_schema_usage" {
  provider           = snowflake.sysadmin
  for_each           = local.all_schemas
  database_role_name = snowflake_database_role.db_writer["${each.value.database}__WRITER"].fully_qualified_name
  privileges         = ["USAGE"]
  on_schema {
    schema_name = "\"${each.value.database}\".\"${each.value.schema}\""
  }
  depends_on = [snowflake_schema.this, snowflake_database_role.db_writer]
}

resource "snowflake_grant_privileges_to_database_role" "db_writer_future_tables" {
  provider           = snowflake.sysadmin
  for_each           = local.db_writer_roles
  database_role_name = snowflake_database_role.db_writer[each.key].fully_qualified_name
  privileges         = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = each.value.database
    }
  }
  depends_on = [snowflake_database.this, snowflake_database_role.db_writer]
}

# ── Schema-level database roles ────────────────────────────────────────────────

resource "snowflake_grant_privileges_to_database_role" "schema_reader_schema_usage" {
  provider           = snowflake.sysadmin
  for_each           = local.schema_reader_roles
  database_role_name = snowflake_database_role.schema_reader[each.key].fully_qualified_name
  privileges         = ["USAGE"]
  on_schema {
    schema_name = "\"${each.value.database}\".\"${each.value.schema}\""
  }
  depends_on = [snowflake_schema.this, snowflake_database_role.schema_reader]
}

resource "snowflake_grant_privileges_to_database_role" "schema_reader_future_tables" {
  provider           = snowflake.sysadmin
  for_each           = local.schema_reader_roles
  database_role_name = snowflake_database_role.schema_reader[each.key].fully_qualified_name
  privileges         = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${each.value.database}\".\"${each.value.schema}\""
    }
  }
  depends_on = [snowflake_schema.this, snowflake_database_role.schema_reader]
}

resource "snowflake_grant_privileges_to_database_role" "schema_reader_future_views" {
  provider           = snowflake.sysadmin
  for_each           = local.schema_reader_roles
  database_role_name = snowflake_database_role.schema_reader[each.key].fully_qualified_name
  privileges         = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = "\"${each.value.database}\".\"${each.value.schema}\""
    }
  }
  depends_on = [snowflake_schema.this, snowflake_database_role.schema_reader]
}

resource "snowflake_grant_privileges_to_database_role" "schema_writer_schema_usage" {
  provider           = snowflake.sysadmin
  for_each           = local.schema_writer_roles
  database_role_name = snowflake_database_role.schema_writer[each.key].fully_qualified_name
  privileges         = ["USAGE"]
  on_schema {
    schema_name = "\"${each.value.database}\".\"${each.value.schema}\""
  }
  depends_on = [snowflake_schema.this, snowflake_database_role.schema_writer]
}

resource "snowflake_grant_privileges_to_database_role" "schema_writer_future_tables" {
  provider           = snowflake.sysadmin
  for_each           = local.schema_writer_roles
  database_role_name = snowflake_database_role.schema_writer[each.key].fully_qualified_name
  privileges         = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${each.value.database}\".\"${each.value.schema}\""
    }
  }
  depends_on = [snowflake_schema.this, snowflake_database_role.schema_writer]
}
