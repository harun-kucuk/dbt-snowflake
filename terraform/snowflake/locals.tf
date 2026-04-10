locals {
  databases        = csvdecode(file("${path.module}/config/databases.csv"))
  schemas_list     = csvdecode(file("${path.module}/config/schemas.csv"))
  warehouses       = csvdecode(file("${path.module}/config/warehouses.csv"))
  users            = csvdecode(file("${path.module}/config/users.csv"))
  functional_roles = csvdecode(file("${path.module}/config/functional_roles.csv"))
  fn_grants        = csvdecode(file("${path.module}/config/functional_role_grants.csv"))

  all_databases = { for db in local.databases : db.name => db }

  # Per-database schemas declared explicitly in schemas.csv
  # Key: "ANALYTICS__STAGING"
  all_schemas = {
    for row in local.schemas_list :
    "${row.database}__${upper(row.name)}" => { database = row.database, schema = upper(row.name) }
  }

  all_warehouses = { for wh in local.warehouses : wh.name => wh }
  all_users      = { for u in local.users : u.login_name => u }

  all_functional_roles = { for r in local.functional_roles : r.name => r }

  # Rows where granted_role has no dot → account role grant
  functional_account_grants = {
    for g in local.fn_grants : "${g.functional_role}__${g.granted_role}" => g
    if !strcontains(g.granted_role, ".")
  }

  # Rows where granted_role has a dot → database role grant; split into database + role name
  functional_db_grants = {
    for g in local.fn_grants : "${g.functional_role}__${g.granted_role}" => {
      functional_role = g.functional_role
      database        = split(".", g.granted_role)[0]
      db_role         = split(".", g.granted_role)[1]
    }
    if strcontains(g.granted_role, ".")
  }

  # Generated warehouse usage roles — one per warehouse
  warehouse_usage_roles = {
    for wh in local.warehouses : upper("${wh.name}_usage") => { warehouse = wh.name }
  }

  # Generated database roles — reader/writer scoped to each database and schema
  db_reader_roles = {
    for db in local.databases : "${db.name}__READER" => { database = db.name, name = "READER" }
  }
  db_writer_roles = {
    for db in local.databases : "${db.name}__WRITER" => { database = db.name, name = "WRITER" }
  }

  schema_reader_roles = {
    for k, v in local.all_schemas :
    "${v.database}__${upper(v.schema)}__READER" => { database = v.database, schema = v.schema, name = "${upper(v.schema)}_READER" }
  }
  schema_writer_roles = {
    for k, v in local.all_schemas :
    "${v.database}__${upper(v.schema)}__WRITER" => { database = v.database, schema = v.schema, name = "${upper(v.schema)}_WRITER" }
  }
}
