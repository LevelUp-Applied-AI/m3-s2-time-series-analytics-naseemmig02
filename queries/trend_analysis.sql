-- =============================================================
-- TREND ANALYSIS
-- Moving averages using ROWS BETWEEN frame specifications
-- =============================================================

-- ---------------------------------------------------------------
-- Q1: Daily revenue with 7-day and 30-day moving averages
-- ---------------------------------------------------------------
WITH daily_revenue AS (
    SELECT
        o.order_date,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS daily_rev
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY o.order_date
)
SELECT
    order_date,
    daily_rev,
    ROUND(AVG(daily_rev) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)                                                      AS ma_7day,
    ROUND(AVG(daily_rev) OVER (
        ORDER BY order_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2)                                                      AS ma_30day
FROM daily_revenue
ORDER BY order_date;


-- ---------------------------------------------------------------
-- Q2: Daily order count with 7-day moving average
-- ---------------------------------------------------------------
WITH daily_orders AS (
    SELECT
        order_date,
        COUNT(DISTINCT order_id) AS daily_orders
    FROM orders
    WHERE status != 'cancelled'
    GROUP BY order_date
)
SELECT
    order_date,
    daily_orders,
    ROUND(AVG(daily_orders) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 1)                                                      AS ma_7day_orders
FROM daily_orders
ORDER BY order_date;


-- ---------------------------------------------------------------
-- Q3: Weekly revenue summary — raw vs smoothed signal
-- Shows where moving average reveals trend vs noise
-- ---------------------------------------------------------------
WITH daily_revenue AS (
    SELECT
        o.order_date,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2)  AS daily_rev
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY o.order_date
),
with_moving_avgs AS (
    SELECT
        order_date,
        daily_rev,
        ROUND(AVG(daily_rev) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2)                                                  AS ma_7day,
        ROUND(AVG(daily_rev) OVER (
            ORDER BY order_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 2)                                                  AS ma_30day
    FROM daily_revenue
)
SELECT
    DATE_TRUNC('week', order_date)                            AS week_start,
    ROUND(SUM(daily_rev), 2)                                  AS weekly_revenue,
    ROUND(AVG(daily_rev), 2)                                  AS avg_daily_rev,
    ROUND(AVG(ma_7day), 2)                                    AS avg_7day_ma,
    ROUND(AVG(ma_30day), 2)                                   AS avg_30day_ma,
    ROUND(MAX(daily_rev) - MIN(daily_rev), 2)                 AS daily_volatility
FROM with_moving_avgs
GROUP BY DATE_TRUNC('week', order_date)
ORDER BY week_start;
