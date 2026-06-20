# Singapore Bank Analytics — SQL Portfolio

**Role target:** Business Analyst · Data Analyst · Business Intelligence Analyst  
**Sector:** Retail & Consumer Banking — Singapore  
**Stack:** PostgreSQL (ANSI SQL — runs on Redshift, Snowflake, BigQuery with minor tweaks)

---

## Why This Project Exists

Singapore's major banks (DBS, OCBC, UOB, Standard Chartered, Citibank) routinely test SQL in their BA/DA hiring process. This portfolio is built around the **actual problem domains** those teams work on every day:

- Customer segmentation and lifetime value
- Loan delinquency tracking and NPL reporting
- Net Interest Margin (NIM) and revenue decomposition
- MAS 610 regulatory return preparation
- IFRS 9 ECL provisioning analysis

Each query folder maps to a real team or use case inside a Singapore bank.

---

## Project Structure

```
sg-finance-sql/
├── schema/
│   └── tables.sql              ← Full DDL: 8 tables, partitioned transactions
├── seed/
│   └── sample_data.sql         ← Realistic SG banking test data
├── analysis/
│   ├── 01_customer_analytics/
│   │   ├── rfm_segmentation.sql          ← RFM scoring with churn flags
│   │   └── cohort_retention.sql          ← Monthly acquisition cohort retention
│   ├── 02_loan_risk/
│   │   ├── delinquency_aging.sql         ← DPD buckets + roll rate matrix
│   │   ├── vintage_analysis.sql          ← Loss curves by origination cohort
│   │   └── mortgage_ltv.sql              ← LTV distribution, MAS TDSR stress test
│   ├── 03_revenue_nim/
│   │   ├── net_interest_income.sql       ← NII waterfall: interest earned vs paid
│   │   └── product_profitability.sql     ← Revenue by product, NIM by segment
│   └── 04_regulatory/
│       ├── mas610_loans.sql              ← MAS 610 Table 1A/1B loan returns
│       └── npl_schedule.sql              ← NPA schedule aligned to MAS Notice 612
└── docs/
    ├── data_dictionary.md
    └── sg_banking_glossary.md
```

---

## Skills & Techniques Covered

| Technique | Where Used |
|-----------|-----------|
| Window functions (RANK, NTILE, LAG, LEAD, running totals) | RFM, roll rates, vintage curves |
| Multi-step CTEs | All analysis files |
| Conditional aggregation (CASE WHEN inside SUM) | NII decomposition, DPD aging |
| Date arithmetic (DATEDIFF, age buckets, MOB) | Vintage, delinquency, tenure |
| Self-joins for period comparison | Cohort retention, roll rate matrix |
| Partition-by-range table design | transactions table (monthly partitions) |
| Reconciliation / data quality checks | MAS 610, NPL schedule |
| IFRS 9 ECL stage logic | Loan schema, NPL schedule |
| MAS regulatory taxonomy | MAS 610 returns |

---

## Interview Prep Notes

These queries reflect common **take-home test questions** from Singapore bank hiring:

> *"Write a query to find customers who transacted last month but not this month"*
> → See `analysis/01_customer_analytics/cohort_retention.sql`

> *"Calculate the NPL ratio and provision coverage ratio for the mortgage book"*
> → See `analysis/04_regulatory/npl_schedule.sql`

> *"Produce a DPD roll rate matrix showing movement between delinquency buckets"*
> → See `analysis/02_loan_risk/delinquency_aging.sql`

> *"How would you calculate Net Interest Margin in SQL?"*
> → See `analysis/03_revenue_nim/net_interest_income.sql`

---

## Local Setup

```bash
# PostgreSQL 14+
createdb sg_bank_demo
psql sg_bank_demo < schema/tables.sql
psql sg_bank_demo < seed/sample_data.sql

# Then run any analysis query
psql sg_bank_demo < analysis/01_customer_analytics/rfm_segmentation.sql
```

---

*Built to demonstrate the SQL depth and Singapore financial domain knowledge expected at DBS, OCBC, UOB, Standard Chartered, Citibank, GIC, Temasek, and MAS.*
