
    
    

select
    nation_name as unique_field,
    count(*) as n_records

from ANALYTICS.STAGING.stg_tpch__nations
where nation_name is not null
group by nation_name
having count(*) > 1


