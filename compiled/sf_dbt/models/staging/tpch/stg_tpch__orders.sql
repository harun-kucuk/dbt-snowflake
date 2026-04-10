-- stg_tpch__orders: rename and light-cast raw orders source columns

with source as (
    select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.orders
),

renamed as (
    select
        o_orderkey      as order_key,
        o_custkey       as customer_key,
        o_orderstatus   as order_status,
        o_totalprice    as total_price,
        o_orderdate     as order_date,
        o_orderpriority as order_priority,
        o_clerk         as clerk,
        o_shippriority  as ship_priority,
        o_comment       as comment
    from source
)

select * from renamed