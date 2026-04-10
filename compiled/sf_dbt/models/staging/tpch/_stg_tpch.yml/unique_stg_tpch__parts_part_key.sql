
    
    

select
    part_key as unique_field,
    count(*) as n_records

from ANALYTICS.STAGING.stg_tpch__parts
where part_key is not null
group by part_key
having count(*) > 1


