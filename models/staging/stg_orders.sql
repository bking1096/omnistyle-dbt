{% set orders_relation = source('omnistyle_prod', 'orders') %}
{% set orders_columns = adapter.get_columns_in_relation(orders_relation) | map(attribute='name') | map('upper') | list %}

SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_total AS NUMBER(10, 2)) AS order_total_gbp,
    {% if 'PROMO_CODE' in orders_columns %}
    promo_code,
    {% else %}
    CAST(NULL AS VARCHAR(20)) AS promo_code,
    {% endif %}
    CASE
        WHEN order_total >= 250 THEN TRUE
        ELSE FALSE
    END AS is_high_value_order,
    updated_at,
    _fivetran_synced
FROM {{ orders_relation }}
WHERE COALESCE(_fivetran_deleted, FALSE) = FALSE
