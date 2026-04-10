
  
  
    create schema if not exists ANALYTICS.METADATA;

    create table if not exists ANALYTICS.METADATA.dbt_model_runs (
        invocation_id   varchar,
        model_name      varchar,
        schema_name     varchar,
        database_name   varchar,
        materialization varchar,
        row_count       integer,
        loaded_at       timestamp_ntz default current_timestamp()
    );
  
