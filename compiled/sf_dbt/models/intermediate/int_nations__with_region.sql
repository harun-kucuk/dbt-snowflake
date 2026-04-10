with nations as (
    select * from ANALYTICS.STAGING.stg_tpch__nations
),

regions as (
    select * from ANALYTICS.STAGING.stg_tpch__regions
),

joined as (
    select
        nations.nation_key,
        nations.nation_name,
        nations.region_key,
        nations.comment,
        regions.region_name
    from nations
    left join regions on nations.region_key = regions.region_key
)

select * from joined