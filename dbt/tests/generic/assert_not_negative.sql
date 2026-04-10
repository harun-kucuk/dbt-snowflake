{% test assert_not_negative(model, column_name) %}
-- Fails for any row where the column is strictly negative.
-- Use on price, quantity, tax, discount, and other columns that must be >= 0.
select *
from {{ model }}
where {{ column_name }} < 0
{% endtest %}
