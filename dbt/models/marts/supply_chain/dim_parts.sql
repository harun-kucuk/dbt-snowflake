with parts as (
    select * from {{ ref('stg_tpch__parts') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['part_key']) }} as part_key,
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
