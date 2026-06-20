-- ================================================================
-- NET INTEREST INCOME (NII) & MARGIN (NIM)
-- analysis/03_revenue_nim/net_interest_income.sql
--
-- Business question: What is the bank earning on loans, paying on
-- deposits, and what's the resulting margin?
--
-- Used by: Finance / Treasury for monthly P&L reporting
-- ================================================================

WITH interest_income AS (
    -- Interest earned on the loan book (monthly accrual: P × r / 12)
    SELECT
        loan_type                                            AS product,
        SUM(outstanding_sgd * interest_rate / 12)             AS monthly_interest_income_sgd
    FROM loans
    WHERE status = 'CURRENT'
    GROUP BY loan_type
),

interest_expense AS (
    -- Interest paid on deposits
    SELECT
        p.subcategory                                        AS product,
        SUM(a.balance_sgd * COALESCE(a.interest_rate, p.base_rate) / 12)
                                                              AS monthly_interest_expense_sgd
    FROM accounts a
    JOIN products p ON a.product_id = p.product_id
    WHERE a.status = 'ACTIVE'
      AND a.account_type IN ('SAVINGS', 'CURRENT', 'FIXED_DEPOSIT')
    GROUP BY p.subcategory
),

totals AS (
    SELECT
        (SELECT SUM(monthly_interest_income_sgd)  FROM interest_income)  AS total_income,
        (SELECT SUM(monthly_interest_expense_sgd) FROM interest_expense) AS total_expense
),

earning_assets AS (
    SELECT SUM(outstanding_sgd) AS total_earning_assets
    FROM loans
    WHERE status NOT IN ('WRITTEN_OFF', 'CLOSED')
)

SELECT
    t.total_income                                            AS interest_income_sgd,
    t.total_expense                                           AS interest_expense_sgd,
    (t.total_income - t.total_expense)                        AS net_interest_income_sgd,
    ROUND(
        (t.total_income - t.total_expense) * 12 / NULLIF(ea.total_earning_assets, 0)
    , 4)                                                       AS net_interest_margin,
    ea.total_earning_assets                                    AS earning_assets_sgd
FROM totals t
CROSS JOIN earning_assets ea;
