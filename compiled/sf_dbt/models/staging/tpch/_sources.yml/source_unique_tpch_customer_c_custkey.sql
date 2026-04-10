
    
    

select
    c_custkey as unique_field,
    count(*) as n_records

from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.customer
where c_custkey is not null
group by c_custkey
having count(*) > 1


