resource "snowflake_warehouse" "this" {
  provider = snowflake.sysadmin
  for_each                     = local.all_warehouses
  name                         = each.key
  warehouse_size               = each.value.size
  auto_suspend                 = tonumber(each.value.auto_suspend_seconds)
  auto_resume                  = tobool(each.value.auto_resume)
  initially_suspended          = tobool(each.value.initially_suspended)
  statement_timeout_in_seconds = tonumber(each.value.statement_timeout_seconds)
  comment                      = try(each.value.comment, "")
}
