
    
    

select
    region_name as unique_field,
    count(*) as n_records

from ANALYTICS.STAGING.stg_tpch__regions
where region_name is not null
group by region_name
having count(*) > 1


