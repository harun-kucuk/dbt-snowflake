{% macro generate_schema_name(custom_schema_name, node) %}

    {# If schema is defined in model config → use it directly #}
    {% if custom_schema_name is not none %}
        {{ custom_schema_name | upper }}
    {% else %}
        {{ target.schema }}
    {% endif %}

{% endmacro %}