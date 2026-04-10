with parts as (
    select * from ANALYTICS.STAGING.stg_tpch__parts
),

final as (
    select
        md5(cast(coalesce(cast(part_key as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as part_key,
        part_key                                              as part_natural_key,
        part_name,
        manufacturer,
        brand,
        part_type,
        size,
        container,
        retail_price,
        comment
    from parts
)

select * from final