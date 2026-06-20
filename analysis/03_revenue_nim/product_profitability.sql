-- ================================================================
-- PRODUCT PROFITABILITY BY LOAN TYPE
-- analysis/03_revenue_nim/product_profitability.sql
--
-- Business question: Which loan products are the most profitable
-- after accounting for credit risk provisions?
--
-- Used by: Product Managers for monthly performance reviews
-- ================================================================

SELECT
    loan_type,
    COUNT(*)                                               AS active_loans,
    SUM(outstanding_sgd)                                   AS book_size_sgd,
    ROUND(AVG(interest_rate) * 100, 3)                     AS avg_yield_pct,
    ROUND(SUM(outstanding_sgd * interest_rate / 12), 0)    AS monthly_interest_income_sgd,
    ROUND(SUM(ecl_provision_sgd), 0)                       AS ecl_provision_sgd,
    ROUND(
        SUM(outstanding_sgd * interest_rate / 12) - SUM(ecl_provision_sgd)
    , 0)                                                   AS risk_adjusted_income_sgd,
    -- Risk-adjusted yield: income net of expected credit loss, annualised, as % of book
    ROUND(
        (SUM(outstanding_sgd * interest_rate / 12) - SUM(ecl_provision_sgd)) * 12
        / NULLIF(SUM(outstanding_sgd), 0) * 100
    , 3)                                                   AS risk_adjusted_yield_pct
FROM loans
WHERE status NOT IN ('WRITTEN_OFF', 'CLOSED')
GROUP BY loan_type
ORDER BY risk_adjusted_income_sgd DESC;
