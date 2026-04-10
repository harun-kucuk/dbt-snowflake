
    
    

select
    customer_natural_key as unique_field,
    count(*) as n_records

from ANALYTICS.MARTS_SHARED.dim_customers
where customer_natural_key is not null
group by customer_natural_key
having count(*) > 1


