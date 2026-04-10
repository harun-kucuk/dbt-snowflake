
-- Fails for any row where the FK value does not exist in the parent table.
-- Stricter than the built-in `relationships` test: counts NULLs in the child
-- as orphans too, so use only on columns that should already be not_null.
select child.*
from ANALYTICS.MARTS_FINANCE.fct_order_items as child
left join ANALYTICS.MARTS_SUPPLY_CHAIN.dim_parts as parent
    on child.part_key = parent.part_key
where parent.part_key is null
