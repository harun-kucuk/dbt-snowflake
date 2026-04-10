
    
    

select
    date_key as unique_field,
    count(*) as n_records

from ANALYTICS.MARTS_SHARED.dim_dates
where date_key is not null
group by date_key
having count(*) > 1


