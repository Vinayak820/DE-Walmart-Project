SELECT
    *
FROM
    {{ source('source', 'order_items') }}