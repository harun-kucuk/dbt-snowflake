{% snapshot snp_customers %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_key',
        strategy='check',
        check_cols=[
            'customer_name',
            'address',
            'phone',
            'account_balance',
            'market_segment',
            'nation_key'
        ],
        invalidate_hard_deletes=True
    )
}}

-- Tracks Type 2 slowly changing dimension history for customers.
-- Each time any of the check_cols changes, dbt closes the old row
-- (sets dbt_valid_to) and inserts a new one (dbt_valid_from = now).
--
-- Columns added by dbt automatically:
--   dbt_scd_id       -- surrogate key for the snapshot row
--   dbt_updated_at   -- when dbt last evaluated this record
--   dbt_valid_from   -- when this version became effective
--   dbt_valid_to     -- when this version was superseded (NULL = current)
--
-- To query only current customer records:
--   select * from snp_customers where dbt_valid_to is null
--
-- In production (Fivetran source), replace `strategy='check'` with
-- `strategy='timestamp'` and `updated_at='_fivetran_synced'` for
-- more reliable change detection without full-row comparison.

select * from {{ ref('stg_tpch__customers') }}

{% endsnapshot %}
