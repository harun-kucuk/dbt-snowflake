
    
    

select
    supplier_natural_key as unique_field,
    count(*) as n_records

from ANALYTICS.MARTS_SUPPLY_CHAIN.dim_suppliers
where supplier_natural_key is not null
group by supplier_natural_key
having count(*) > 1


