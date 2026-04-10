with lineitems as (
    select * from ANALYTICS.STAGING.stg_tpch__lineitems
),

orders as (
    select * from ANALYTICS.MARTS_FINANCE.fct_orders
),

parts as (
    select * from ANALYTICS.MARTS_SUPPLY_CHAIN.dim_parts
),

suppliers as (
    select * from ANALYTICS.MARTS_SUPPLY_CHAIN.dim_suppliers
),

final as (
    select
        md5(cast(coalesce(cast(lineitems.order_key as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(lineitems.line_number as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as order_item_key,
        orders.order_key,
        parts.part_key,
        suppliers.supplier_key,
        lineitems.line_number,
        lineitems.quantity,
        lineitems.extended_price,
        lineitems.discount,
        lineitems.tax,
        lineitems.extended_price * (1 - lineitems.discount)                        as discounted_price,
        lineitems.extended_price * (1 - lineitems.discount) * (1 + lineitems.tax)  as net_price,
        lineitems.return_flag,
        lineitems.line_status,
        lineitems.ship_date,
        lineitems.commit_date,
        lineitems.receipt_date,
        lineitems.ship_instructions,
        lineitems.ship_mode,
        lineitems.comment
    from lineitems
    left join orders    on lineitems.order_key    = orders.order_natural_key
    left join parts     on lineitems.part_key     = parts.part_natural_key
    left join suppliers on lineitems.supplier_key = suppliers.supplier_natural_key
)

select * from final