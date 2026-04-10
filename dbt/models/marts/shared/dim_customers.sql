with customers as (
    select * from {{ ref('stg_tpch__customers') }}
),

nations as (
    select * from {{ ref('int_nations__with_region') }}
),

joined as (
    select
        {{ dbt_utils.generate_surrogate_key(['customers.customer_key']) }} as customer_key,
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
