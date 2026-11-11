WITH joined_orders AS (
    SELECT
        c.country,
        COALESCE(o.promo_code, 'Standard Checkout') AS campaign_name,
        o.order_id,
        o.order_total_gbp,
        o.is_high_value_order
    FROM {{ ref('stg_orders') }} o
    INNER JOIN {{ ref('stg_customers') }} c
        ON o.customer_id = c.customer_id
),

campaign_totals AS (
    SELECT
        country,
        campaign_name,
        COUNT(order_id) AS active_orders,
        SUM(CASE WHEN is_high_value_order THEN 1 ELSE 0 END) AS high_value_orders,
        ROUND(SUM(order_total_gbp), 2) AS net_revenue_gbp,
        ROUND(AVG(order_total_gbp), 2) AS avg_order_value_gbp
    FROM joined_orders
    GROUP BY 1, 2
)

SELECT
    country,
    campaign_name,
    active_orders,
    high_value_orders,
    net_revenue_gbp,
    avg_order_value_gbp,
    ROUND(
        net_revenue_gbp * 100.0 / NULLIF(SUM(net_revenue_gbp) OVER (), 0),
        1
    ) AS pct_of_total_revenue
FROM campaign_totals
ORDER BY net_revenue_gbp DESC
