
    
    

select
    nation_key as unique_field,
    count(*) as n_records

from ANALYTICS.INTERMEDIATE.int_nations__with_region
where nation_key is not null
group by nation_key
having count(*) > 1


