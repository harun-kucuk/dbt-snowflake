with date_spine as (
    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date="cast('1992-01-01' as date)",
            end_date="cast('1999-01-01' as date)"
        )
    }}
),

dates as (
    select
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_key,
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
