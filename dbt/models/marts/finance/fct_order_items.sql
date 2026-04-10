with lineitems as (
    select * from {{ ref('stg_tpch__lineitems') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

parts as (
    select * from {{ ref('dim_parts') }}
),

suppliers as (
    select * from {{ ref('dim_suppliers') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['lineitems.order_key', 'lineitems.line_number']) }} as order_item_key,
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
