
    
    

select
    nation_name as unique_field,
    count(*) as n_records

from ANALYTICS.INTERMEDIATE.int_nations__with_region
where nation_name is not null
group by nation_name
having count(*) > 1


