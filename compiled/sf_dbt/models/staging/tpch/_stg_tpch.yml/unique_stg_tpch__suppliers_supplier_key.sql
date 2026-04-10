
    
    

select
    supplier_key as unique_field,
    count(*) as n_records

from ANALYTICS.STAGING.stg_tpch__suppliers
where supplier_key is not null
group by supplier_key
having count(*) > 1


