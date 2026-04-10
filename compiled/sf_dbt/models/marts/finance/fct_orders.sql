

with orders as (
    select * from ANALYTICS.STAGING.stg_tpch__orders

    
    -- On incremental runs, process only orders from the last 3 days relative to the
    -- current table's high-water mark. The 3-day lookback guards against late-arriving
    -- records (e.g. status updates) that arrive after the initial load date.
    where order_date >= (
        select dateadd(day, -3, max(order_date)) from ANALYTICS.MARTS_FINANCE.fct_orders
    )
    
),

customers as (
    select * from ANALYTICS.MARTS_SHARED.dim_customers
),

dates as (
    select * from ANALYTICS.MARTS_SHARED.dim_dates
),

final as (
    select
        md5(cast(coalesce(cast(orders.order_key as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as order_key,
        orders.order_key                                              as order_natural_key,
        customers.customer_key,
        dates.date_key                                                as order_date_key,
        orders.order_date,
        orders.order_status,
        orders.order_priority,
        orders.clerk,
        orders.ship_priority,
        orders.total_price,
        orders.comment
    from orders
    left join customers on orders.customer_key = customers.customer_natural_key
    left join dates on orders.order_date = dates.date_day
)

select * from final