with customers as (
    select * from ANALYTICS.STAGING.stg_tpch__customers
),

nations as (
    select * from ANALYTICS.INTERMEDIATE.int_nations__with_region
),

joined as (
    select
        md5(cast(coalesce(cast(customers.customer_key as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as customer_key,
        customers.customer_key                                              as customer_natural_key,
        customers.customer_name,
        customers.address,
        customers.phone,
        customers.account_balance,
        customers.market_segment,
        customers.comment,
        nations.nation_key,
        nations.nation_name,
        nations.region_key,
        nations.region_name
    from customers
    left join nations on customers.nation_key = nations.nation_key
)

select * from joined