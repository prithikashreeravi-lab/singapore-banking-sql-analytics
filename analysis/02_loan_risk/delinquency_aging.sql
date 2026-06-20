-- ================================================================
-- DELINQUENCY AGING & ROLL RATE MATRIX
-- analysis/02_loan_risk/delinquency_aging.sql
--
-- Business question: How is the loan book aging, and what % of
-- loans roll from one DPD bucket to the next, month over month?
--
-- Used by: Credit Risk, Collections, ALCO reporting
-- ================================================================

-- ── PART 1: CURRENT DPD AGING SNAPSHOT ──────────────────────────

SELECT
    loan_type,
    dpd_bucket,
    COUNT(*)                                   AS loan_count,
    SUM(outstanding_sgd)                       AS total_outstanding_sgd,
    ROUND(AVG(interest_rate) * 100, 3)         AS avg_rate_pct,
    ROUND(
        SUM(outstanding_sgd) * 100.0 /
        SUM(SUM(outstanding_sgd)) OVER (PARTITION BY loan_type)
    , 1)                                       AS pct_of_book
FROM loans
WHERE status NOT IN ('CLOSED', 'WRITTEN_OFF')
GROUP BY loan_type, dpd_bucket
ORDER BY loan_type,
    CASE dpd_bucket
        WHEN 'CURRENT' THEN 0
        WHEN '1-30'    THEN 1
        WHEN '31-60'   THEN 2
        WHEN '61-90'   THEN 3
        WHEN '>90'     THEN 4
    END;


-- ── PART 2: ROLL RATE MATRIX ─────────────────────────────────────
-- Shows what % of loans in bucket X last month moved to bucket Y
-- this month. Standard ALCO / Risk Committee output.

WITH monthly_bucket AS (
    SELECT
        l.loan_id,
        l.loan_type,
        DATE_TRUNC('month', lr.due_date)::DATE   AS repayment_month,
        CASE
            WHEN lr.days_late = 0                THEN 'CURRENT'
            WHEN lr.days_late BETWEEN 1  AND 30  THEN '1-30'
            WHEN lr.days_late BETWEEN 31 AND 60  THEN '31-60'
            WHEN lr.days_late BETWEEN 61 AND 90  THEN '61-90'
            ELSE '>90'
        END                                       AS bucket,
        l.outstanding_sgd
    FROM loans l
    JOIN loan_repayments lr ON l.loan_id = lr.loan_id
    WHERE lr.due_date < CURRENT_DATE
      AND l.status NOT IN ('CLOSED', 'WRITTEN_OFF')
),

with_prior AS (
    SELECT
        loan_id,
        loan_type,
        repayment_month,
        bucket                                          AS current_bucket,
        LAG(bucket) OVER (PARTITION BY loan_id ORDER BY repayment_month)
                                                          AS prior_bucket,
        outstanding_sgd
    FROM monthly_bucket
)

SELECT
    loan_type,
    prior_bucket,
    current_bucket,
    COUNT(*)                                            AS loan_count,
    SUM(outstanding_sgd)                                AS exposure_sgd,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY loan_type, prior_bucket)
    , 1)                                                AS roll_rate_pct
FROM with_prior
WHERE prior_bucket IS NOT NULL
GROUP BY loan_type, prior_bucket, current_bucket
ORDER BY loan_type, prior_bucket, current_bucket;
