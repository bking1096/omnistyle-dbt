WITH customer_order_metrics AS (
    SELECT
        customer_id,
        COUNT(order_id) AS active_orders,
        ROUND(SUM(order_total_gbp), 2) AS lifetime_spend_gbp,
        MAX(CASE WHEN promo_code IS NOT NULL THEN 1 ELSE 0 END) AS used_black_friday_promo,
        MAX(_fivetran_synced) AS last_order_synced_at
    FROM {{ ref('stg_orders') }}
    GROUP BY 1
)

SELECT
    c.customer_id,
    c.full_name,
    c.country,
    c.hashed_email,
    COALESCE(m.active_orders, 0) AS active_orders,
    COALESCE(m.lifetime_spend_gbp, 0.00) AS lifetime_spend_gbp,
    CASE
        WHEN COALESCE(m.lifetime_spend_gbp, 0) >= 500 THEN 'VIP_HIGH_VALUE'
        WHEN COALESCE(m.used_black_friday_promo, 0) = 1 THEN 'PROMO_ENGAGED'
        ELSE 'STANDARD'
    END AS activation_cohort,
    CASE
        WHEN COALESCE(m.lifetime_spend_gbp, 0) >= 500 THEN 'Braze: VIP Early Access / Suppress Discount Ads'
        WHEN COALESCE(m.used_black_friday_promo, 0) = 1 THEN 'Klaviyo: Black Friday Cross-Sell Bundle'
        ELSE 'Meta Ads: Re-Engagement Offer'
    END AS recommended_activation_action,
    m.last_order_synced_at
FROM {{ ref('stg_customers') }} c
LEFT JOIN customer_order_metrics m
    ON c.customer_id = m.customer_id
ORDER BY lifetime_spend_gbp DESC
