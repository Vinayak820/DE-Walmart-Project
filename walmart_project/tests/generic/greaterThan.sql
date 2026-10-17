{% test greaterThan(model, column_name) %}

SELECT 
    *
FROM   
    {{ model }}
WHERE 
    TRY_CAST({{ column_name }} AS DOUBLE)< 0

{% endtest %}