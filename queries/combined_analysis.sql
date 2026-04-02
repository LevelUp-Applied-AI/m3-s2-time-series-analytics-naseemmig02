-- =============================================================
-- COMBINED ANALYSIS
-- Multiple window functions in a single query
-- =============================================================

-- ---------------------------------------------------------------
-- Q1: Monthly revenue by customer segment
--     WITH: running total + MoM growth rate (LAG + SUM window)
-- ---------------------------------------------------------------
WITH segment_monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)                       AS month,
        c.segment,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2)     AS revenue,
        COUNT(DISTINCT o.order_id)                              AS order_count
    FROM orders o
    JOIN order_items oi ON o.order_id   = oi.order_id
    JOIN customers   c  ON o.customer_id = c.customer_id
    WHERE o.status != 'cancelled'
    GROUP BY DATE_TRUNC('month', o.order_date), c.segment
)
SELECT
    TO_CHAR(month, 'YYYY-MM')                                   AS month,
    segment,
    revenue,
    order_count,
    -- Window 1: running total per segment
    ROUND(SUM(revenue) OVER (
        PARTITION BY segment
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2)                                                        AS running_total,
    -- Window 2: MoM revenue growth per segment
    LAG(revenue) OVER (
        PARTITION BY segment ORDER BY month
    )                                                            AS prev_month_rev,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (PARTITION BY segment ORDER BY month))
              / NULLIF(LAG(revenue) OVER (PARTITION BY segment ORDER BY month), 0)
    , 1)                                                         AS mom_growth_pct,
    -- Window 3: segment revenue share of total that month
    ROUND(
        100.0 * revenue
              / NULLIF(SUM(revenue) OVER (PARTITION BY month), 0)
    , 1)                                                         AS pct_of_month_revenue
FROM segment_monthly
ORDER BY segment, month;


-- ---------------------------------------------------------------
-- Q2: Cohort retention trend with period-over-period change
--     (ROW_NUMBER to define cohorts + LAG on retention rate)
--     Shows whether retention is improving or declining over time
-- ---------------------------------------------------------------
WITH first_purchases AS (
    SELECT
        o.customer_id,
        MIN(o.order_date)                                       AS first_order_date,
        DATE_TRUNC('month', MIN(o.order_date))                  AS cohort_month
    FROM orders o
    WHERE o.status != 'cancelled'
    GROUP BY o.customer_id
),
retention AS (
    SELECT
        fp.cohort_month,
        COUNT(DISTINCT fp.customer_id)                          AS cohort_size,
        COUNT(DISTINCT CASE
            WHEN o.order_date > fp.first_order_date
             AND o.order_date <= fp.first_order_date + INTERVAL '90 days'
             AND o.status != 'cancelled'
            THEN fp.customer_id
        END)                                                     AS retained_90d
    FROM first_purchases fp
    LEFT JOIN orders o ON fp.customer_id = o.customer_id
    GROUP BY fp.cohort_month
),
retention_rates AS (
    SELECT
        cohort_month,
        cohort_size,
        retained_90d,
        ROUND(100.0 * retained_90d / NULLIF(cohort_size, 0), 1) AS pct_90d,
        -- Window 1: rank cohorts by size
        RANK() OVER (ORDER BY cohort_size DESC)                  AS size_rank
    FROM retention
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM')                            AS cohort,
    cohort_size,
    size_rank,
    pct_90d,
    -- Window 2: MoM change in retention rate (is it getting better?)
    LAG(pct_90d) OVER (ORDER BY cohort_month)                   AS prev_cohort_retention,
    ROUND(
        pct_90d - LAG(pct_90d) OVER (ORDER BY cohort_month)
    , 1)                                                         AS retention_change_ppts,
    -- Window 3: 3-cohort moving average of retention (smoothed trend)
    ROUND(AVG(pct_90d) OVER (
        ORDER BY cohort_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 1)                                                        AS ma_3cohort_retention
FROM retention_rates
ORDER BY cohort_month;
