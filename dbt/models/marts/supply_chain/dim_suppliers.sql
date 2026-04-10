with suppliers as (
    select * from {{ ref('stg_tpch__suppliers') }}
),

nations as (
    select * from {{ ref('int_nations__with_region') }}
),

joined as (
    select
        {{ dbt_utils.generate_surrogate_key(['suppliers.supplier_key']) }} as supplier_key,
        suppliers.supplier_key                                              as supplier_natural_key,
        suppliers.supplier_name,
        suppliers.address,
        suppliers.phone,
        suppliers.account_balance,
        suppliers.comment,
        nations.nation_key,
        nations.nation_name,
        nations.region_key,
        nations.region_name
    from suppliers
    left join nations on suppliers.nation_key = nations.nation_key
)

select * from joined
