{% macro create_audit_log_table() %}
  {#
    Called via on-run-start in dbt_project.yml — runs once per invocation before
    any models build. Creates the audit table if it does not exist.
    Only runs in prod; dev and CI targets skip it.
  #}
  {% if target.name == 'prod' %}
    create schema if not exists {{ target.database }}.METADATA;

    create table if not exists {{ target.database }}.METADATA.dbt_model_runs (
        invocation_id   varchar,
        model_name      varchar,
        schema_name     varchar,
        database_name   varchar,
        materialization varchar,
        row_count       integer,
        loaded_at       timestamp_ntz default current_timestamp()
    );
  {% endif %}
{% endmacro %}


{% macro audit_log() %}
  {#
    Post-hook macro — runs after every model build in prod.
    Inserts one row per model per invocation into ANALYTICS.METADATA.dbt_model_runs.
    The table is guaranteed to exist because create_audit_log_table() runs on-run-start.

    Query example — last 7 days of prod runs:
      select * from ANALYTICS.METADATA.dbt_model_runs
      where loaded_at >= dateadd(day, -7, current_timestamp())
      order by loaded_at desc;
  #}
  {% if target.name == 'prod' %}
    insert into {{ target.database }}.METADATA.dbt_model_runs
        (invocation_id, model_name, schema_name, database_name, materialization, row_count)
    select
        '{{ invocation_id }}',
        '{{ this.name }}',
        '{{ this.schema }}',
        '{{ this.database }}',
        '{{ config.get("materialized") }}',
        count(*)
    from {{ this }}
  {% endif %}
{% endmacro %}
