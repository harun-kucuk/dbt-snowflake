
    
    

select
    region_key as unique_field,
    count(*) as n_records

from ANALYTICS.STAGING.stg_tpch__regions
where region_key is not null
group by region_key
having count(*) > 1


