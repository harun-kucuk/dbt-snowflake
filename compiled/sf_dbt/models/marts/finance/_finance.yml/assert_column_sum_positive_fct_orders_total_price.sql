
-- Fails if the sum of the column across all rows is zero or negative.
-- Use to catch silent zeroing bugs (e.g. a price column all-NULL or all-zero after a bad join).
select *
from (
    select sum(total_price) as total
    from ANALYTICS.MARTS_FINANCE.fct_orders
)
where total <= 0
