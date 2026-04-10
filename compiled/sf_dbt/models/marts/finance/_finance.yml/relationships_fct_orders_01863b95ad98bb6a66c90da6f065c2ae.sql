
    
    

with child as (
    select customer_key as from_field
    from ANALYTICS.MARTS_FINANCE.fct_orders
    where customer_key is not null
),

parent as (
    select customer_key as to_field
    from ANALYTICS.MARTS_SHARED.dim_customers
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


