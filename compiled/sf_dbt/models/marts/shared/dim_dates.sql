with date_spine as (
    





with rawdata as (

    

    

    with p as (
        select 0 as generated_number union all select 1
    ), unioned as (

    select

    
    p0.generated_number * power(2, 0)
     + 
    
    p1.generated_number * power(2, 1)
     + 
    
    p2.generated_number * power(2, 2)
     + 
    
    p3.generated_number * power(2, 3)
     + 
    
    p4.generated_number * power(2, 4)
     + 
    
    p5.generated_number * power(2, 5)
     + 
    
    p6.generated_number * power(2, 6)
     + 
    
    p7.generated_number * power(2, 7)
     + 
    
    p8.generated_number * power(2, 8)
     + 
    
    p9.generated_number * power(2, 9)
     + 
    
    p10.generated_number * power(2, 10)
     + 
    
    p11.generated_number * power(2, 11)
    
    
    + 1
    as generated_number

    from

    
    p as p0
     cross join 
    
    p as p1
     cross join 
    
    p as p2
     cross join 
    
    p as p3
     cross join 
    
    p as p4
     cross join 
    
    p as p5
     cross join 
    
    p as p6
     cross join 
    
    p as p7
     cross join 
    
    p as p8
     cross join 
    
    p as p9
     cross join 
    
    p as p10
     cross join 
    
    p as p11
    
    

    )

    select *
    from unioned
    where generated_number <= 2557
    order by generated_number



),

all_periods as (

    select (
        

    dateadd(
        day,
        row_number() over (order by generated_number) - 1,
        cast('1992-01-01' as date)
        )


    ) as date_day
    from rawdata

),

filtered as (

    select *
    from all_periods
    where date_day <= cast('1999-01-01' as date)

)

select * from filtered


),

dates as (
    select
        md5(cast(coalesce(cast(date_day as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as date_key,
        cast(date_day as date)                                as date_day,
        extract(year from date_day)                           as year,
        extract(quarter from date_day)                        as quarter,
        extract(month from date_day)                          as month,
        extract(week from date_day)                           as week_of_year,
        extract(day from date_day)                            as day_of_month,
        extract(dayofweek from date_day)                      as day_of_week,
        to_char(date_day, 'Month')                            as month_name,
        to_char(date_day, 'Day')                              as day_name,
        case when extract(dayofweek from date_day) in (0, 6)
            then true else false end                          as is_weekend,
        year(date_day) * 100 + month(date_day)                as year_month
    from date_spine
)

select * from dates