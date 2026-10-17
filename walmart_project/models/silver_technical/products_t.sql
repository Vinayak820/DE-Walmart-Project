{{
    config(
        materialized = 'incremental',
        unique_id = 'product_id'
    )
}}

SELECT 
    *,
    current_timestamp() as processed_at
FROM 
    {{source('source','products')}}

{% if is_incremental() %}
  WHERE updated_timestamp > (SELECT COALESCE(MAX(updated_timestamp), '1900-01-01') FROM {{this}})
{% endif %}


{# {{ this }} ka matlab hai current dbt model ki target table, yaani products_t in Silver Technical. #}