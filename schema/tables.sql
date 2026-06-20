-- ================================================================
-- SCHEMA: Singapore Retail Bank — Analytics Database
-- tables.sql
-- PostgreSQL 15 | Dialect-compatible with Redshift / Snowflake
-- ================================================================

-- ── REFERENCE TABLES ────────────────────────────────────────────

CREATE TABLE risk_grades (
    grade_code          CHAR(2)         PRIMARY KEY,
    description         VARCHAR(60)     NOT NULL,
    pd_min              NUMERIC(6,4)    NOT NULL,   -- probability of default, lower bound
    pd_max              NUMERIC(6,4)    NOT NULL,
    ecl_provision_pct   NUMERIC(6,4)    NOT NULL,   -- IFRS 9 expected credit loss %
    is_impaired         BOOLEAN         DEFAULT FALSE
);

CREATE TABLE products (
    product_id          SERIAL          PRIMARY KEY,
    product_code        VARCHAR(20)     UNIQUE NOT NULL,
    product_name        VARCHAR(100)    NOT NULL,
    category            VARCHAR(20)     NOT NULL,   -- DEPOSIT | LOAN | CARD
    subcategory         VARCHAR(30),                -- SAVINGS | FIXED_DEPOSIT | MORTGAGE | PERSONAL etc.
    base_rate           NUMERIC(6,4),               -- annualised, e.g. 0.0380 = 3.80% p.a.
    currency            CHAR(3)         DEFAULT 'SGD',
    is_active           BOOLEAN         DEFAULT TRUE
);

-- ── CORE TABLES ─────────────────────────────────────────────────

CREATE TABLE customers (
    customer_id         BIGSERIAL       PRIMARY KEY,
    -- PDPA: full NRIC not stored; only masked token (last 4 chars + checksum letter)
    nric_token          VARCHAR(9)      UNIQUE,
    segment             VARCHAR(20)     NOT NULL DEFAULT 'MASS',
    -- MASS | EMERGING | AFFLUENT | PRIORITY | PRIVATE (based on AUM tiers)
    residency           VARCHAR(10)     NOT NULL,
    -- CITIZEN | PR | EP | SP | WP
    nationality         CHAR(2),                    -- ISO 3166-1 alpha-2
    date_of_birth       DATE,
    gender              CHAR(1),                    -- M | F | U
    annual_income_sgd   NUMERIC(15,2),
    income_band         VARCHAR(20),                -- <30K | 30-80K | 80-200K | >200K
    employment_type     VARCHAR(20),                -- EMPLOYED | SELF_EMPLOYED | RETIREE
    channel             VARCHAR(20),                -- BRANCH | DIGITAL | REFERRAL | RM
    joined_date         DATE            NOT NULL,
    is_active           BOOLEAN         DEFAULT TRUE,
    churned_date        DATE,
    kyc_status          VARCHAR(20)     DEFAULT 'VERIFIED'
);

CREATE TABLE accounts (
    account_id          BIGSERIAL       PRIMARY KEY,
    customer_id         BIGINT          NOT NULL REFERENCES customers(customer_id),
    product_id          INT             NOT NULL REFERENCES products(product_id),
    account_number      VARCHAR(20)     UNIQUE NOT NULL,
    account_type        VARCHAR(20)     NOT NULL,   -- SAVINGS | CURRENT | FIXED_DEPOSIT
    balance_sgd         NUMERIC(18,2)   DEFAULT 0,
    interest_rate       NUMERIC(6,4),               -- negotiated rate override
    status              VARCHAR(15)     DEFAULT 'ACTIVE',
    opened_date         DATE            NOT NULL,
    closed_date         DATE,
    last_txn_date       DATE
);

-- Partitioned by month — standard pattern in bank data warehouses
CREATE TABLE transactions (
    transaction_id      BIGSERIAL,
    account_id          BIGINT          NOT NULL REFERENCES accounts(account_id),
    txn_date            DATE            NOT NULL,
    txn_type            VARCHAR(20)     NOT NULL,   -- CREDIT | DEBIT | TRANSFER | FEE | INTEREST
    txn_code            VARCHAR(20),                -- internal posting code
    amount_sgd          NUMERIC(18,2)   NOT NULL,
    channel             VARCHAR(15),                -- ATM | BRANCH | ONLINE | MOBILE | POS | FAST
    description         VARCHAR(200),
    is_reversed         BOOLEAN         DEFAULT FALSE,
    PRIMARY KEY (transaction_id, txn_date)
) PARTITION BY RANGE (txn_date);

CREATE TABLE transactions_2023 PARTITION OF transactions FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE transactions_2024 PARTITION OF transactions FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE transactions_2025 PARTITION OF transactions FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE loans (
    loan_id             BIGSERIAL       PRIMARY KEY,
    customer_id         BIGINT          NOT NULL REFERENCES customers(customer_id),
    product_id          INT             NOT NULL REFERENCES products(product_id),
    loan_number         VARCHAR(20)     UNIQUE NOT NULL,
    loan_type           VARCHAR(20)     NOT NULL,   -- PERSONAL | MORTGAGE | AUTO | RENOVATION | EDUCATION
    origination_date    DATE            NOT NULL,
    maturity_date       DATE            NOT NULL,
    principal_sgd       NUMERIC(18,2)   NOT NULL,
    outstanding_sgd     NUMERIC(18,2)   NOT NULL,
    interest_rate       NUMERIC(6,4)    NOT NULL,   -- annualised nominal rate
    tenure_months       INT             NOT NULL,
    remaining_months    INT,
    monthly_instalment  NUMERIC(18,2),
    status              VARCHAR(20)     DEFAULT 'CURRENT',
    -- CURRENT | DELINQUENT | NPL | RESTRUCTURED | WRITTEN_OFF | CLOSED
    dpd                 INT             DEFAULT 0,  -- days past due
    dpd_bucket          VARCHAR(15),                -- CURRENT | 1-30 | 31-60 | 61-90 | >90
    ecl_stage           SMALLINT        DEFAULT 1,  -- IFRS 9: 1 = performing, 2 = watch, 3 = impaired
    ecl_provision_sgd   NUMERIC(18,2)   DEFAULT 0,
    risk_grade          CHAR(2)         REFERENCES risk_grades(grade_code),
    ltv_ratio           NUMERIC(6,4),               -- loan-to-value, mortgages only
    property_type       VARCHAR(20),                -- HDB | PRIVATE_CONDO | LANDED
    collateral_type     VARCHAR(20)                 -- PROPERTY | VEHICLE | NONE
);

CREATE TABLE loan_repayments (
    repayment_id        BIGSERIAL       PRIMARY KEY,
    loan_id             BIGINT          NOT NULL REFERENCES loans(loan_id),
    due_date            DATE            NOT NULL,
    paid_date           DATE,
    instalment_no       INT             NOT NULL,
    scheduled_sgd       NUMERIC(18,2)   NOT NULL,
    principal_portion   NUMERIC(18,2)   NOT NULL,
    interest_portion    NUMERIC(18,2)   NOT NULL,
    paid_sgd            NUMERIC(18,2)   DEFAULT 0,
    days_late           INT             DEFAULT 0,
    status              VARCHAR(15)     DEFAULT 'SCHEDULED'
    -- SCHEDULED | PAID | PARTIAL | MISSED | WAIVED
);

-- ── INDEXES ─────────────────────────────────────────────────────

CREATE INDEX idx_customers_segment   ON customers(segment);
CREATE INDEX idx_customers_joined    ON customers(joined_date);
CREATE INDEX idx_accounts_customer   ON accounts(customer_id);
CREATE INDEX idx_txn_account_date    ON transactions(account_id, txn_date);
CREATE INDEX idx_loans_customer      ON loans(customer_id);
CREATE INDEX idx_loans_status_dpd    ON loans(status, dpd);
CREATE INDEX idx_loans_origination   ON loans(origination_date);
CREATE INDEX idx_repayments_loan     ON loan_repayments(loan_id, due_date);
