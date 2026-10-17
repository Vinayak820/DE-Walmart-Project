SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM {{ref("products_t")}}
GROUP BY product_id
HAVING COUNT(*) > 1;
