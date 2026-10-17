SELECT
    *
FROM
    {{ source('source', 'employees') }}