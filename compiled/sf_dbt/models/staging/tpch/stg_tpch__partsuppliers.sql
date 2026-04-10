with source as (
    select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.partsupp
),

renamed as (
    select
        ps_partkey    as part_key,
        ps_suppkey    as supplier_key,
        ps_availqty   as available_quantity,
        ps_supplycost as supply_cost,
        ps_comment    as comment
    from source
)

select * from renamed