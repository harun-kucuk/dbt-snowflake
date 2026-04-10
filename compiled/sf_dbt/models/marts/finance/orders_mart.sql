with order_items as (
    select * from ANALYTICS.MARTS_FINANCE.fct_order_items
),

orders as (
    select * from ANALYTICS.MARTS_FINANCE.fct_orders
),

customers as (
    select * from ANALYTICS.MARTS_SHARED.dim_customers
),

parts as (
    select * from ANALYTICS.MARTS_SUPPLY_CHAIN.dim_parts
),

suppliers as (
    select * from ANALYTICS.MARTS_SUPPLY_CHAIN.dim_suppliers
),

dates as (
    select * from ANALYTICS.MARTS_SHARED.dim_dates
),

joined as (
    select
        -- order item identifiers
        order_items.order_item_key,
        order_items.line_number,

        -- order context
        orders.order_natural_key                    as order_id,
        orders.order_date,
        orders.order_status,
        orders.order_priority,
        orders.clerk,
        orders.ship_priority,

        -- date attributes
        dates.year                                  as order_year,
        dates.quarter                               as order_quarter,
        dates.month                                 as order_month,
        dates.month_name                            as order_month_name,

        -- customer attributes
        customers.customer_natural_key              as customer_id,
        customers.customer_name,
        customers.market_segment,
        customers.nation_name                       as customer_nation,
        customers.region_name                       as customer_region,

        -- part attributes
        parts.part_natural_key                      as part_id,
        parts.part_name,
        parts.brand,
        parts.part_type,
        parts.manufacturer,

        -- supplier attributes
        suppliers.supplier_natural_key              as supplier_id,
        suppliers.supplier_name,
        suppliers.nation_name                       as supplier_nation,
        suppliers.region_name                       as supplier_region,

        -- measures
        order_items.quantity,
        order_items.extended_price,
        order_items.discount,
        order_items.tax,
        order_items.discounted_price,
        order_items.net_price,
        order_items.return_flag,
        order_items.line_status,
        order_items.ship_date,
        order_items.ship_mode,
        order_items.ship_instructions
    from order_items
    left join orders
        on order_items.order_key = orders.order_key
    left join customers
        on orders.customer_key = customers.customer_key
    left join parts
        on order_items.part_key = parts.part_key
    left join suppliers
        on order_items.supplier_key = suppliers.supplier_key
    left join dates
        on orders.order_date_key = dates.date_key
)

select * from joined