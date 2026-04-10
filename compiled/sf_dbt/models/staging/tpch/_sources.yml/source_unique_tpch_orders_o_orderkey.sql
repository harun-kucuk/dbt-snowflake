
    
    

select
    o_orderkey as unique_field,
    count(*) as n_records

from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.orders
where o_orderkey is not null
group by o_orderkey
having count(*) > 1


