
{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

SELECT
    *,
    current_timestamp() AS processed_at
FROM
    {{ source('source', 'orders') }}

{% if is_incremental() %}
    AND updated_timestamp > (SELECT COALESCE(MAX(updated_timestamp), '1900-01-01') FROM {{this}})
{% endif %}


{# {{ this }} ka matlab hai current dbt model ki target table, yaani products_t in Silver Technical. #}