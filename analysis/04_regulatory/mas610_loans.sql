-- ================================================================
-- MAS 610 — LOANS BY SECTOR & RESIDENCY
-- analysis/04_regulatory/mas610_loans.sql
--
-- Mirrors MAS Notice 610 Table 1A/1B structure (statistical return
-- on assets and liabilities of banks in Singapore).
--
-- DISCLAIMER: Illustrative only. Sector mapping is simplified for
-- portfolio purposes — real submissions require full MAS taxonomy
-- and compliance sign-off.
-- ================================================================

-- ── TABLE 1A: LOANS BY SECTOR ────────────────────────────────────

SELECT
    CASE loan_type
        WHEN 'MORTGAGE'   THEN 'Housing Loans'
        WHEN 'RENOVATION' THEN 'Housing — Renovation'
        WHEN 'AUTO'       THEN 'Transport'
        WHEN 'EDUCATION'  THEN 'Professional & Private Individuals'
        WHEN 'PERSONAL'   THEN 'Professional & Private Individuals'
        ELSE 'Others'
    END                                          AS mas_sector,
    COUNT(*)                                     AS facility_count,
    SUM(outstanding_sgd)                         AS outstanding_sgd,
    SUM(principal_sgd)                           AS approved_limit_sgd,
    ROUND(AVG(interest_rate) * 100, 2)           AS avg_rate_pct
FROM loans
WHERE status NOT IN ('WRITTEN_OFF', 'CLOSED')
GROUP BY mas_sector
ORDER BY outstanding_sgd DESC;


-- ── TABLE 1B: LOANS BY RESIDENCY OF BORROWER ─────────────────────

SELECT
    CASE c.residency
        WHEN 'CITIZEN' THEN 'Singapore Resident'
        WHEN 'PR'      THEN 'Singapore Resident'
        ELSE 'Non-Resident'
    END                                          AS residency_class,
    l.loan_type,
    COUNT(*)                                     AS facility_count,
    SUM(l.outstanding_sgd)                       AS outstanding_sgd,
    SUM(CASE WHEN l.dpd > 0 THEN l.outstanding_sgd ELSE 0 END)
                                                  AS overdue_amount_sgd
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
WHERE l.status NOT IN ('WRITTEN_OFF', 'CLOSED')
GROUP BY residency_class, l.loan_type
ORDER BY residency_class, l.loan_type;
