
-- Fails for any row where the column is strictly negative.
-- Use on price, quantity, tax, discount, and other columns that must be >= 0.
select *
from ANALYTICS.MARTS_FINANCE.fct_orders
where total_price < 0
