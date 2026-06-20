-- ================================================================
-- MONTHLY ACQUISITION COHORT RETENTION
-- analysis/01_customer_analytics/cohort_retention.sql
--
-- Business question: Of customers acquired in month X, what % are
-- still transacting N months later? Classic cohort retention curve.
--
-- This pattern also answers the common interview question:
-- "Find customers who transacted last month but not this month"
-- (see Part 2 below)
-- ================================================================

-- ── PART 1: COHORT RETENTION CURVE ──────────────────────────────

WITH cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', joined_date)::DATE   AS cohort_month
    FROM customers
),

monthly_activity AS (
    SELECT DISTINCT
        a.customer_id,
        DATE_TRUNC('month', t.txn_date)::DATE    AS activity_month
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    WHERE NOT t.is_reversed
),

cohort_activity AS (
    SELECT
        c.cohort_month,
        m.activity_month,
        -- Months since acquisition
        (DATE_PART('year', m.activity_month) - DATE_PART('year', c.cohort_month)) * 12
        + (DATE_PART('month', m.activity_month) - DATE_PART('month', c.cohort_month))
                                                  AS months_since_acquisition,
        c.customer_id
    FROM cohorts c
    JOIN monthly_activity m ON c.customer_id = m.customer_id
    WHERE m.activity_month >= c.cohort_month
),

cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    cs.cohort_size,
    ca.months_since_acquisition,
    COUNT(DISTINCT ca.customer_id)                                   AS active_customers,
    ROUND(
        COUNT(DISTINCT ca.customer_id) * 100.0 / cs.cohort_size
    , 1)                                                             AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
GROUP BY ca.cohort_month, cs.cohort_size, ca.months_since_acquisition
ORDER BY ca.cohort_month, ca.months_since_acquisition;


-- ── PART 2: ACTIVE LAST MONTH, INACTIVE THIS MONTH ──────────────
-- Common take-home test phrasing: "customers who transacted last
-- month but not this month"

WITH last_month_active AS (
    SELECT DISTINCT a.customer_id
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    WHERE t.txn_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
      AND t.txn_date <  DATE_TRUNC('month', CURRENT_DATE)
      AND NOT t.is_reversed
),

this_month_active AS (
    SELECT DISTINCT a.customer_id
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    WHERE t.txn_date >= DATE_TRUNC('month', CURRENT_DATE)
      AND NOT t.is_reversed
)

SELECT
    c.customer_id,
    c.segment,
    c.income_band,
    c.channel,
    lm.customer_id IS NOT NULL  AS was_active_last_month,
    tm.customer_id IS NOT NULL  AS active_this_month
FROM customers c
JOIN last_month_active lm  ON c.customer_id = lm.customer_id
LEFT JOIN this_month_active tm ON c.customer_id = tm.customer_id
WHERE tm.customer_id IS NULL   -- dropped off this month
ORDER BY c.segment;
