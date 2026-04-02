-- =============================================================
-- GROWTH ANALYSIS
-- LAG/LEAD for period-over-period revenue and order comparisons
-- =============================================================

-- ---------------------------------------------------------------
-- Q1: Month-over-month revenue AND order volume growth
-- ---------------------------------------------------------------
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)        AS month,
        COUNT(DISTINCT o.order_id)               AS order_count,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT
    TO_CHAR(month, 'YYYY-MM')                                               AS month,
    order_count,
    revenue,
    LAG(order_count) OVER (ORDER BY month)                                  AS prev_order_count,
    LAG(revenue)     OVER (ORDER BY month)                                  AS prev_revenue,
    ROUND(
        100.0 * (order_count - LAG(order_count) OVER (ORDER BY month))
              / NULLIF(LAG(order_count) OVER (ORDER BY month), 0), 1
    )                                                                        AS order_growth_pct,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
              / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1
    )                                                                        AS revenue_growth_pct
FROM monthly
ORDER BY month;


-- ---------------------------------------------------------------
-- Q2: Quarter-over-quarter revenue growth with decomposition
-- (is growth from more orders, or higher order value?)
-- ---------------------------------------------------------------
WITH quarterly AS (
    SELECT
        DATE_TRUNC('quarter', o.order_date)                                  AS quarter,
        COUNT(DISTINCT o.order_id)                                           AS order_count,
        COUNT(DISTINCT o.customer_id)                                        AS unique_customers,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2)                  AS revenue,
        ROUND(AVG(oi.quantity * oi.unit_price)::numeric, 2)                  AS avg_item_value,
        ROUND(
            SUM(oi.quantity * oi.unit_price)::numeric
            / NULLIF(COUNT(DISTINCT o.order_id), 0), 2
        )                                                                     AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY DATE_TRUNC('quarter', o.order_date)
)
SELECT
    TO_CHAR(quarter, 'YYYY-"Q"Q')                                           AS quarter,
    order_count,
    unique_customers,
    revenue,
    avg_order_value,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY quarter))
              / NULLIF(LAG(revenue) OVER (ORDER BY quarter), 0), 1
    )                                                                        AS revenue_growth_pct,
    ROUND(
        100.0 * (order_count - LAG(order_count) OVER (ORDER BY quarter))
              / NULLIF(LAG(order_count) OVER (ORDER BY quarter), 0), 1
    )                                                                        AS order_growth_pct,
    ROUND(
        100.0 * (unique_customers - LAG(unique_customers) OVER (ORDER BY quarter))
              / NULLIF(LAG(unique_customers) OVER (ORDER BY quarter), 0), 1
    )                                                                        AS customer_growth_pct,
    ROUND(
        100.0 * (avg_order_value - LAG(avg_order_value) OVER (ORDER BY quarter))
              / NULLIF(LAG(avg_order_value) OVER (ORDER BY quarter), 0), 1
    )                                                                        AS aov_growth_pct
FROM quarterly
ORDER BY quarter;


-- ---------------------------------------------------------------
-- Q3: Revenue by product category per month with MoM growth
-- (what's driving the top-line number?)
-- ---------------------------------------------------------------
WITH category_monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)                                    AS month,
        p.category,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2)                  AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id  = oi.order_id
    JOIN products   p  ON oi.product_id = p.product_id
    WHERE o.status != 'cancelled'
    GROUP BY DATE_TRUNC('month', o.order_date), p.category
)
SELECT
    TO_CHAR(month, 'YYYY-MM')                                               AS month,
    category,
    revenue,
    LAG(revenue) OVER (PARTITION BY category ORDER BY month)                AS prev_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (PARTITION BY category ORDER BY month))
              / NULLIF(LAG(revenue) OVER (PARTITION BY category ORDER BY month), 0), 1
    )                                                                        AS mom_growth_pct
FROM category_monthly
ORDER BY category, month;
