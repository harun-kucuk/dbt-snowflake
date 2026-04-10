{% test assert_no_orphaned_fk(model, column_name, parent_model, parent_column) %}
-- Fails for any row where the FK value does not exist in the parent table.
-- Stricter than the built-in `relationships` test: counts NULLs in the child
-- as orphans too, so use only on columns that should already be not_null.
select child.*
from {{ model }} as child
left join {{ parent_model }} as parent
    on child.{{ column_name }} = parent.{{ parent_column }}
where parent.{{ parent_column }} is null
{% endtest %}
