
    
    

select
    r_regionkey as unique_field,
    count(*) as n_records

from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.region
where r_regionkey is not null
group by r_regionkey
having count(*) > 1


