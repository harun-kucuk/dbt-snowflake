
    
    

select
    order_natural_key as unique_field,
    count(*) as n_records

from ANALYTICS.MARTS_FINANCE.fct_orders
where order_natural_key is not null
group by order_natural_key
having count(*) > 1


