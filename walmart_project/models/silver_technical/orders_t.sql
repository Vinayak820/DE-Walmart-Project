
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
WHERE
    is_active = 'Y'

{% if is_incremental() %}
    AND updated_timestamp > (
        SELECT MAX(updated_timestamp) FROM {{ this }}
    )
{% endif %}
