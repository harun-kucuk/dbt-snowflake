
    
    

select
    p_partkey as unique_field,
    count(*) as n_records

from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.part
where p_partkey is not null
group by p_partkey
having count(*) > 1


