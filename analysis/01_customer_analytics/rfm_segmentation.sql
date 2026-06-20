-- ================================================================
-- RFM CUSTOMER SEGMENTATION
-- analysis/01_customer_analytics/rfm_segmentation.sql
--
-- Business question: Which customers are most valuable, and which
-- high-value customers are showing early signs of churn?
--
-- Used by: CRM / Marketing teams for campaign targeting
-- ================================================================

WITH txn_summary AS (
    SELECT
        c.customer_id,
        c.segment,
        c.income_band,
        c.channel,
        MAX(t.txn_date)                                              AS last_txn_date,
        COUNT(t.transaction_id)                                      AS txn_count_12m,
        SUM(CASE WHEN t.txn_type = 'DEBIT' THEN ABS(t.amount_sgd) ELSE 0 END)
                                                                     AS total_spend_sgd,
        COALESCE(SUM(a.balance_sgd), 0)                              AS total_balance_sgd
    FROM customers c
    JOIN accounts a      ON c.customer_id = a.customer_id AND a.status = 'ACTIVE'
    JOIN transactions t  ON a.account_id  = t.account_id
    WHERE t.txn_date >= CURRENT_DATE - INTERVAL '12 months'
      AND NOT t.is_reversed
      AND c.is_active
    GROUP BY c.customer_id, c.segment, c.income_band, c.channel
),

rfm_scored AS (
    SELECT
        customer_id,
        segment,
        income_band,
        channel,
        last_txn_date,
        CURRENT_DATE - last_txn_date                AS recency_days,
        txn_count_12m                                AS frequency,
        total_spend_sgd                              AS monetary,
        total_balance_sgd,
        NTILE(5) OVER (ORDER BY CURRENT_DATE - last_txn_date ASC)  AS r_score,  -- 5 = most recent
        NTILE(5) OVER (ORDER BY txn_count_12m DESC)                AS f_score,  -- 5 = most frequent
        NTILE(5) OVER (ORDER BY total_spend_sgd DESC)              AS m_score   -- 5 = highest spend
    FROM txn_summary
)

SELECT
    customer_id,
    segment,
    income_band,
    channel,
    recency_days,
    frequency,
    ROUND(monetary, 2)              AS monetary_sgd,
    ROUND(total_balance_sgd, 2)     AS total_balance_sgd,
    r_score, f_score, m_score,
    (r_score + f_score + m_score)   AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champion'
        WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'New / Recent'
        WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4  THEN 'At Risk'
        WHEN r_score <= 1 AND f_score >= 3                   THEN 'Cannot Lose'
        WHEN r_score <= 2 AND m_score >= 3                   THEN 'Hibernating'
        ELSE 'Needs Attention'
    END                              AS rfm_segment,
    -- Flag: valuable customer going quiet — priority for RM outreach
    CASE
        WHEN r_score <= 2 AND total_balance_sgd > 50000 THEN TRUE
        ELSE FALSE
    END                              AS high_value_churn_risk
FROM rfm_scored
ORDER BY rfm_total DESC, monetary DESC;
