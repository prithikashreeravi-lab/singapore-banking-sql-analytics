-- ================================================================
-- SEED DATA — Reference tables + sample customers
-- seed/sample_data.sql
-- ================================================================

-- ── RISK GRADES ──────────────────────────────────────────────────

INSERT INTO risk_grades (grade_code, description, pd_min, pd_max, ecl_provision_pct, is_impaired) VALUES
('AA', 'Prime — minimal risk',            0.0000, 0.0010, 0.0050, FALSE),
('A1', 'Very strong',                     0.0010, 0.0025, 0.0100, FALSE),
('A2', 'Strong',                          0.0025, 0.0050, 0.0150, FALSE),
('BB', 'Satisfactory',                    0.0050, 0.0100, 0.0200, FALSE),
('B1', 'Adequate',                        0.0100, 0.0200, 0.0350, FALSE),
('B2', 'Watch',                           0.0200, 0.0500, 0.0500, FALSE),
('CC', 'Special mention',                 0.0500, 0.1500, 0.1000, FALSE),
('C1', 'Substandard',                     0.1500, 0.3000, 0.2000, TRUE),
('C2', 'Doubtful',                        0.3000, 0.7000, 0.5000, TRUE),
('C3', 'Loss',                            0.7000, 1.0000, 1.0000, TRUE);

-- ── PRODUCTS ─────────────────────────────────────────────────────

INSERT INTO products (product_code, product_name, category, subcategory, base_rate, currency) VALUES
('DEP-SAV-01', 'eSavings Account',          'DEPOSIT', 'SAVINGS',       0.0025, 'SGD'),
('DEP-SAV-02', 'Multiplier Savings',        'DEPOSIT', 'SAVINGS',       0.0060, 'SGD'),
('DEP-CUR-01', 'Current Account',           'DEPOSIT', 'CURRENT',       0.0000, 'SGD'),
('DEP-FD-12M', '12-Month Fixed Deposit',    'DEPOSIT', 'FIXED_DEPOSIT', 0.0380, 'SGD'),
('DEP-FD-06M', '6-Month Fixed Deposit',     'DEPOSIT', 'FIXED_DEPOSIT', 0.0340, 'SGD'),
('LOAN-PL-01', 'Personal Loan',             'LOAN',    'PERSONAL',      0.0499, 'SGD'),
('LOAN-MTG-01','HDB Mortgage',              'LOAN',    'MORTGAGE',      0.0320, 'SGD'),
('LOAN-MTG-02','Private Property Mortgage', 'LOAN',    'MORTGAGE',      0.0350, 'SGD'),
('LOAN-AUTO-01','Car Loan',                 'LOAN',    'AUTO',          0.0280, 'SGD'),
('LOAN-RNV-01', 'Renovation Loan',          'LOAN',    'RENOVATION',    0.0399, 'SGD'),
('LOAN-EDU-01', 'Education Loan',           'LOAN',    'EDUCATION',     0.0450, 'SGD');

-- ── CUSTOMERS (20 representative profiles) ───────────────────────

INSERT INTO customers (nric_token, segment, residency, nationality, date_of_birth, gender, annual_income_sgd, income_band, employment_type, channel, joined_date, is_active) VALUES
('XXXXX123A', 'PRIORITY',  'CITIZEN', 'SG', '1978-03-15', 'M', 320000, '>200K',   'EMPLOYED',      'RM',       '2018-06-01', TRUE),
('XXXXX456B', 'AFFLUENT',  'CITIZEN', 'SG', '1985-07-22', 'F', 145000, '80-200K', 'EMPLOYED',      'DIGITAL',  '2019-02-14', TRUE),
('XXXXX789C', 'MASS',      'CITIZEN', 'SG', '1990-11-05', 'M',  52000, '30-80K',  'EMPLOYED',      'BRANCH',   '2020-09-10', TRUE),
('XXXXX012D', 'EMERGING',  'EP',      'CN', '1988-04-30', 'F',  88000, '80-200K', 'EMPLOYED',      'DIGITAL',  '2021-01-03', TRUE),
('XXXXX345E', 'PRIVATE',   'CITIZEN', 'SG', '1965-09-12', 'M', 850000, '>200K',   'SELF_EMPLOYED', 'RM',       '2017-03-20', TRUE),
('XXXXX678F', 'MASS',      'CITIZEN', 'SG', '1995-02-28', 'F',  38000, '30-80K',  'EMPLOYED',      'DIGITAL',  '2022-08-15', TRUE),
('XXXXX901G', 'AFFLUENT',  'PR',      'SG', '1980-12-01', 'M', 185000, '80-200K', 'EMPLOYED',      'REFERRAL', '2019-11-20', TRUE),
('XXXXX234H', 'MASS',      'CITIZEN', 'SG', '1993-06-17', 'F',  41000, '30-80K',  'EMPLOYED',      'BRANCH',   '2020-04-01', TRUE),
('XXXXX567I', 'EMERGING',  'CITIZEN', 'SG', '1987-08-09', 'M',  72000, '30-80K',  'SELF_EMPLOYED', 'DIGITAL',  '2021-12-05', TRUE),
('XXXXX890J', 'MASS',      'CITIZEN', 'SG', '1998-01-25', 'F',  28000, '<30K',    'EMPLOYED',      'DIGITAL',  '2023-03-10', TRUE),
('XXXXX111K', 'AFFLUENT',  'CITIZEN', 'SG', '1982-05-19', 'M', 162000, '80-200K', 'EMPLOYED',      'RM',       '2018-09-01', TRUE),
('XXXXX222L', 'MASS',      'CITIZEN', 'SG', '1991-10-03', 'F',  46000, '30-80K',  'EMPLOYED',      'DIGITAL',  '2021-06-22', TRUE),
('XXXXX333M', 'EMERGING',  'PR',      'MY', '1986-02-14', 'M',  95000, '80-200K', 'EMPLOYED',      'BRANCH',   '2020-01-15', TRUE),
('XXXXX444N', 'MASS',      'CITIZEN', 'SG', '1996-07-08', 'F',  35000, '30-80K',  'EMPLOYED',      'DIGITAL',  '2022-11-30', FALSE),
('XXXXX555O', 'PRIORITY',  'CITIZEN', 'SG', '1972-11-27', 'M', 280000, '>200K',   'SELF_EMPLOYED', 'RM',       '2016-04-10', TRUE),
('XXXXX666P', 'MASS',      'CITIZEN', 'SG', '1994-03-21', 'F',  44000, '30-80K',  'EMPLOYED',      'BRANCH',   '2021-08-05', TRUE),
('XXXXX777Q', 'AFFLUENT',  'CITIZEN', 'SG', '1983-09-16', 'M', 155000, '80-200K', 'EMPLOYED',      'DIGITAL',  '2019-05-25', TRUE),
('XXXXX888R', 'EMERGING',  'CITIZEN', 'SG', '1989-12-30', 'F',  78000, '30-80K',  'EMPLOYED',      'REFERRAL', '2020-07-18', TRUE),
('XXXXX999S', 'MASS',      'CITIZEN', 'SG', '1997-04-11', 'M',  31000, '30-80K',  'EMPLOYED',      'DIGITAL',  '2023-01-20', TRUE),
('XXXXX000T', 'PRIVATE',   'CITIZEN', 'SG', '1968-06-05', 'F', 620000, '>200K',   'SELF_EMPLOYED', 'RM',       '2015-10-12', TRUE);

-- ── ACCOUNTS ─────────────────────────────────────────────────────
-- One savings account per customer (product_id 1), varying balances

INSERT INTO accounts (customer_id, product_id, account_number, account_type, balance_sgd, status, opened_date, last_txn_date)
SELECT
    customer_id,
    1,
    'SGB' || LPAD(customer_id::TEXT, 10, '0'),
    'SAVINGS',
    CASE income_band
        WHEN '>200K'   THEN 80000 + (customer_id * 3700)
        WHEN '80-200K' THEN 25000 + (customer_id * 1200)
        WHEN '30-80K'  THEN 6000  + (customer_id * 300)
        ELSE 1500 + (customer_id * 80)
    END,
    'ACTIVE',
    joined_date,
    CURRENT_DATE - (customer_id % 25)
FROM customers;

-- ── SAMPLE TRANSACTIONS (last 3 months, illustrative) ────────────

INSERT INTO transactions (account_id, txn_date, txn_type, txn_code, amount_sgd, channel, description)
SELECT
    a.account_id,
    CURRENT_DATE - (s.n * 7),
    CASE WHEN s.n % 3 = 0 THEN 'CREDIT' ELSE 'DEBIT' END,
    CASE WHEN s.n % 3 = 0 THEN 'SALARY' ELSE 'POS_PURCHASE' END,
    CASE WHEN s.n % 3 = 0 THEN a.balance_sgd * 0.15 ELSE -(50 + (s.n * 13)) END,
    CASE s.n % 4 WHEN 0 THEN 'MOBILE' WHEN 1 THEN 'ONLINE' WHEN 2 THEN 'POS' ELSE 'ATM' END,
    'Sample transaction'
FROM accounts a
CROSS JOIN generate_series(0, 11) AS s(n)
WHERE a.status = 'ACTIVE';

-- ── SAMPLE LOANS ─────────────────────────────────────────────────

INSERT INTO loans (customer_id, product_id, loan_number, loan_type, origination_date, maturity_date,
                    principal_sgd, outstanding_sgd, interest_rate, tenure_months, remaining_months,
                    monthly_instalment, status, dpd, dpd_bucket, risk_grade, ltv_ratio, property_type)
VALUES
(1,  7, 'LN0000001', 'MORTGAGE', '2020-01-15', '2045-01-15', 850000, 720000, 0.0320, 300, 240, 3650, 'CURRENT',    0,  'CURRENT', 'AA', 0.6800, 'PRIVATE_CONDO'),
(2,  6, 'LN0000002', 'PERSONAL', '2023-03-01', '2026-03-01', 25000,  14200,  0.0499, 36,  16,  748,  'CURRENT',    0,  'CURRENT', 'A1', NULL,   NULL),
(3,  7, 'LN0000003', 'MORTGAGE', '2019-06-10', '2044-06-10', 420000, 365000, 0.0280, 300, 222, 1820, 'DELINQUENT', 25, '1-30',    'B1', 0.7900, 'HDB'),
(5,  8, 'LN0000004', 'MORTGAGE', '2021-09-01', '2046-09-01', 1800000,1620000,0.0350, 300, 258, 8950, 'CURRENT',    0,  'CURRENT', 'AA', 0.5500, 'LANDED'),
(7,  9, 'LN0000005', 'AUTO',     '2022-05-15', '2027-05-15', 95000,  58000,  0.0280, 60,  35,  1720, 'CURRENT',    0,  'CURRENT', 'A2', NULL,   NULL),
(9,  6, 'LN0000006', 'PERSONAL', '2022-11-01', '2025-11-01', 18000,  3200,   0.0499, 36,  5,   540,  'DELINQUENT', 65, '61-90',   'CC', NULL,   NULL),
(11, 7, 'LN0000007', 'MORTGAGE', '2018-02-20', '2043-02-20', 600000, 480000, 0.0300, 300, 200, 2840, 'CURRENT',    0,  'CURRENT', 'A1', 0.7200, 'PRIVATE_CONDO'),
(13, 10,'LN0000008', 'RENOVATION','2023-07-01','2028-07-01', 40000,  31000,  0.0399, 60,  46,  735,  'CURRENT',    0,  'CURRENT', 'A2', NULL,   NULL),
(15, 7, 'LN0000009', 'MORTGAGE', '2017-04-05', '2042-04-05', 950000, 695000, 0.0310, 300, 188, 4520, 'CURRENT',    0,  'CURRENT', 'AA', 0.6100, 'LANDED'),
(19, 6, 'LN0000010', 'PERSONAL', '2024-01-10', '2027-01-10', 12000,  9800,   0.0499, 36,  28,  360,  'NPL',        110,'>90',     'C2', NULL,   NULL);

-- Update ECL provisions based on risk grade
UPDATE loans l
SET ecl_provision_sgd = l.outstanding_sgd * rg.ecl_provision_pct,
    ecl_stage = CASE WHEN rg.is_impaired THEN 3 WHEN l.dpd > 30 THEN 2 ELSE 1 END
FROM risk_grades rg
WHERE l.risk_grade = rg.grade_code;
