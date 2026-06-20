-- ================================================================
-- MORTGAGE LTV DISTRIBUTION & TDSR STRESS TEST
-- analysis/02_loan_risk/mortgage_ltv.sql
--
-- Business question: How exposed is the mortgage book to an
-- interest rate shock, given MAS TDSR rules?
--
-- Singapore context:
--   - MAS caps LTV at 75% for most first-property loans
--   - MAS TDSR cap: total debt repayments ≤ 55% of gross income
-- ================================================================

-- ── PART 1: LTV DISTRIBUTION ─────────────────────────────────────

SELECT
    property_type,
    CASE
        WHEN ltv_ratio < 0.60                  THEN '<60%'
        WHEN ltv_ratio BETWEEN 0.60 AND 0.7499 THEN '60-74.9%'
        WHEN ltv_ratio BETWEEN 0.75 AND 0.7999 THEN '75-79.9%'
        ELSE '>=80% (review)'
    END                                          AS ltv_bucket,
    COUNT(*)                                     AS loan_count,
    SUM(outstanding_sgd)                         AS total_exposure_sgd,
    ROUND(AVG(ltv_ratio) * 100, 2)               AS avg_ltv_pct
FROM loans
WHERE loan_type = 'MORTGAGE'
  AND status NOT IN ('CLOSED', 'WRITTEN_OFF')
  AND ltv_ratio IS NOT NULL
GROUP BY property_type, ltv_bucket
ORDER BY property_type, MIN(ltv_ratio);


-- ── PART 2: +200BPS INTEREST RATE STRESS TEST ────────────────────
-- Recalculates monthly instalment under a rate shock and flags
-- borrowers who would breach the 55% TDSR cap.

WITH stressed AS (
    SELECT
        l.loan_id,
        l.loan_type,
        l.outstanding_sgd,
        l.interest_rate                                    AS current_rate,
        l.interest_rate + 0.02                              AS stressed_rate,
        l.monthly_instalment                                AS current_instalment,
        l.remaining_months,
        c.annual_income_sgd,
        c.income_band,
        -- Standard amortising loan payment formula at the stressed rate
        CASE WHEN l.remaining_months > 0 THEN
            l.outstanding_sgd
            * ((l.interest_rate + 0.02) / 12)
            * POWER(1 + (l.interest_rate + 0.02) / 12, l.remaining_months)
            / (POWER(1 + (l.interest_rate + 0.02) / 12, l.remaining_months) - 1)
        ELSE l.monthly_instalment
        END                                                  AS stressed_instalment
    FROM loans l
    JOIN customers c ON l.customer_id = c.customer_id
    WHERE l.loan_type = 'MORTGAGE'
      AND l.status = 'CURRENT'
)

SELECT
    income_band,
    COUNT(*)                                                AS loan_count,
    ROUND(AVG(current_instalment), 0)                       AS avg_current_instalment_sgd,
    ROUND(AVG(stressed_instalment), 0)                       AS avg_stressed_instalment_sgd,
    ROUND(AVG(stressed_instalment - current_instalment), 0)  AS avg_increase_sgd,
    -- % of borrowers in this band who would exceed 55% TDSR after the shock
    ROUND(
        COUNT(CASE
            WHEN stressed_instalment * 12 / NULLIF(annual_income_sgd, 0) > 0.55
            THEN 1
        END) * 100.0 / COUNT(*)
    , 1)                                                     AS pct_exceeding_tdsr_55
FROM stressed
GROUP BY income_band
ORDER BY income_band;
