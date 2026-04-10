{% test assert_column_sum_positive(model, column_name) %}
-- Fails if the sum of the column across all rows is zero or negative.
-- Use to catch silent zeroing bugs (e.g. a price column all-NULL or all-zero after a bad join).
select *
from (
    select sum({{ column_name }}) as total
    from {{ model }}
)
where total <= 0
{% endtest %}
