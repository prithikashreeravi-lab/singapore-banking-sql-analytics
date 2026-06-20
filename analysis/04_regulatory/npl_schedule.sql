-- ================================================================
-- NPL SCHEDULE & PROVISION COVERAGE
-- analysis/04_regulatory/npl_schedule.sql
--
-- Business question: What's our Non-Performing Loan ratio and is
-- our provisioning adequate (per MAS Notice 612 classification)?
--
-- MAS NPL definition: >90 days past due, or classified
-- Substandard / Doubtful / Loss.
-- ================================================================

WITH book_summary AS (
    SELECT
        loan_type,
        SUM(outstanding_sgd)                                       AS total_book_sgd,
        SUM(CASE WHEN dpd > 90 OR status = 'NPL'
                 THEN outstanding_sgd ELSE 0 END)                  AS npl_balance_sgd,
        COUNT(*)                                                   AS total_loans,
        COUNT(CASE WHEN dpd > 90 OR status = 'NPL' THEN 1 END)     AS npl_count,
        SUM(ecl_provision_sgd)                                     AS total_ecl_sgd
    FROM loans
    WHERE status NOT IN ('CLOSED')
    GROUP BY loan_type
)

SELECT
    loan_type,
    total_loans,
    total_book_sgd,
    npl_count,
    npl_balance_sgd,
    ROUND(npl_balance_sgd * 100.0 / NULLIF(total_book_sgd, 0), 2)   AS npl_ratio_pct,
    total_ecl_sgd,
    ROUND(total_ecl_sgd * 100.0 / NULLIF(npl_balance_sgd, 0), 2)    AS provision_coverage_pct
FROM book_summary
ORDER BY npl_ratio_pct DESC;
