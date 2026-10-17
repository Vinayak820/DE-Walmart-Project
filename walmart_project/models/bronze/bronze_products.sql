SELECT
    *
FROM
    {{ source('source', 'products') }}