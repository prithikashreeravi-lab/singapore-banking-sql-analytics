-- ================================================================
-- VINTAGE LOSS ANALYSIS
-- analysis/02_loan_risk/vintage_analysis.sql
--
-- Business question: How do loans originated in each quarter
-- perform as they age? Are recent vintages riskier than older ones?
--
-- Used by: Credit Risk to evaluate underwriting quality over time
-- ================================================================

WITH loan_cohorts AS (
    SELECT
        l.loan_id,
        l.loan_type,
        l.principal_sgd,
        DATE_TRUNC('quarter', l.origination_date)::DATE   AS vintage_quarter,
        lr.due_date,
        lr.days_late,
        (lr.scheduled_sgd - lr.paid_sgd)                  AS shortfall_sgd,
        -- Months on book at this repayment
        (DATE_PART('year', lr.due_date) - DATE_PART('year', l.origination_date)) * 12
        + (DATE_PART('month', lr.due_date) - DATE_PART('month', l.origination_date))
                                                            AS mob
    FROM loans l
    JOIN loan_repayments lr ON l.loan_id = lr.loan_id
    WHERE lr.due_date <= CURRENT_DATE
),

vintage_summary AS (
    SELECT
        vintage_quarter,
        loan_type,
        mob,
        COUNT(DISTINCT loan_id)                            AS loans_in_cohort,
        SUM(principal_sgd)                                 AS cohort_principal_sgd,
        SUM(CASE WHEN days_late > 90 THEN shortfall_sgd ELSE 0 END)
                                                            AS cumulative_90dpd_loss_sgd
    FROM loan_cohorts
    GROUP BY vintage_quarter, loan_type, mob
)

SELECT
    vintage_quarter,
    loan_type,
    mob                                                     AS months_on_book,
    loans_in_cohort,
    cohort_principal_sgd,
    cumulative_90dpd_loss_sgd,
    ROUND(
        cumulative_90dpd_loss_sgd * 100.0 / NULLIF(cohort_principal_sgd, 0)
    , 3)                                                    AS cumulative_loss_rate_pct
FROM vintage_summary
ORDER BY vintage_quarter, loan_type, mob;
