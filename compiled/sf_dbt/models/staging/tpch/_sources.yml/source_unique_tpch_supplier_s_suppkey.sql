
    
    

select
    s_suppkey as unique_field,
    count(*) as n_records

from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.supplier
where s_suppkey is not null
group by s_suppkey
having count(*) > 1


