-- =============================================================
-- COHORT ANALYSIS
-- Cohorts defined by first PURCHASE month (not signup date)
-- =============================================================

-- ---------------------------------------------------------------
-- Q1: Cohort sizes — how many customers first purchased each month
-- ---------------------------------------------------------------
WITH first_purchases AS (
    SELECT
        o.customer_id,
        MIN(o.order_date) AS first_order_date,
        DATE_TRUNC('month', MIN(o.order_date)) AS cohort_month
    FROM orders o
    WHERE o.status != 'cancelled'
    GROUP BY o.customer_id
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM')  AS cohort,
    COUNT(customer_id)                AS cohort_size
FROM first_purchases
GROUP BY cohort_month
ORDER BY cohort_month;


-- ---------------------------------------------------------------
-- Q2: Retention rates — % returning within 30 / 60 / 90 days
-- ---------------------------------------------------------------
WITH first_purchases AS (
    SELECT
        o.customer_id,
        MIN(o.order_date)                        AS first_order_date,
        DATE_TRUNC('month', MIN(o.order_date))   AS cohort_month
    FROM orders o
    WHERE o.status != 'cancelled'
    GROUP BY o.customer_id
),
subsequent_orders AS (
    SELECT
        fp.customer_id,
        fp.cohort_month,
        fp.first_order_date,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY fp.customer_id
            ORDER BY o.order_date
        ) AS purchase_rank
    FROM first_purchases fp
    JOIN orders o
        ON fp.customer_id = o.customer_id
        AND o.order_date  > fp.first_order_date
        AND o.status     != 'cancelled'
),
retention AS (
    SELECT
        fp.cohort_month,
        COUNT(DISTINCT fp.customer_id)                                          AS cohort_size,
        COUNT(DISTINCT CASE WHEN so.order_date <= fp.first_order_date + INTERVAL '30 days'
                            THEN fp.customer_id END)                            AS retained_30d,
        COUNT(DISTINCT CASE WHEN so.order_date <= fp.first_order_date + INTERVAL '60 days'
                            THEN fp.customer_id END)                            AS retained_60d,
        COUNT(DISTINCT CASE WHEN so.order_date <= fp.first_order_date + INTERVAL '90 days'
                            THEN fp.customer_id END)                            AS retained_90d
    FROM first_purchases fp
    LEFT JOIN subsequent_orders so ON fp.customer_id = so.customer_id
    GROUP BY fp.cohort_month
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM')                                        AS cohort,
    cohort_size,
    retained_30d,
    ROUND(100.0 * retained_30d / cohort_size, 1)                           AS pct_30d,
    retained_60d,
    ROUND(100.0 * retained_60d / cohort_size, 1)                           AS pct_60d,
    retained_90d,
    ROUND(100.0 * retained_90d / cohort_size, 1)                           AS pct_90d
FROM retention
ORDER BY cohort_month;


-- ---------------------------------------------------------------
-- Q3: Rank cohorts by 90-day retention (best to worst)
-- ---------------------------------------------------------------
WITH first_purchases AS (
    SELECT
        o.customer_id,
        MIN(o.order_date)                        AS first_order_date,
        DATE_TRUNC('month', MIN(o.order_date))   AS cohort_month
    FROM orders o
    WHERE o.status != 'cancelled'
    GROUP BY o.customer_id
),
subsequent_orders AS (
    SELECT
        fp.customer_id,
        fp.cohort_month,
        fp.first_order_date,
        o.order_date
    FROM first_purchases fp
    JOIN orders o
        ON fp.customer_id  = o.customer_id
        AND o.order_date   > fp.first_order_date
        AND o.order_date  <= fp.first_order_date + INTERVAL '90 days'
        AND o.status      != 'cancelled'
),
retention AS (
    SELECT
        fp.cohort_month,
        COUNT(DISTINCT fp.customer_id)                      AS cohort_size,
        COUNT(DISTINCT so.customer_id)                      AS retained_90d
    FROM first_purchases fp
    LEFT JOIN subsequent_orders so ON fp.customer_id = so.customer_id
    GROUP BY fp.cohort_month
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM')                                AS cohort,
    cohort_size,
    retained_90d,
    ROUND(100.0 * retained_90d / cohort_size, 1)                   AS pct_90d,
    RANK() OVER (ORDER BY ROUND(100.0 * retained_90d / cohort_size, 1) DESC) AS retention_rank
FROM retention
ORDER BY retention_rank;
