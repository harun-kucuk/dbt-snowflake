
    
    

select
    order_key as unique_field,
    count(*) as n_records

from ANALYTICS.STAGING.stg_tpch__orders
where order_key is not null
group by order_key
having count(*) > 1


