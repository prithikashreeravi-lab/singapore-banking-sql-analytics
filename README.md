# Singapore Bank Analytics — SQL Portfolio

**Role target:** Business Analyst · Data Analyst · Business Intelligence Analyst
**Sector:** Retail & Consumer Banking — Singapore
**Stack:** PostgreSQL 15 (ANSI SQL — portable to Redshift, Snowflake, BigQuery with minor syntax changes)

---

## Why this project exists

Singapore's major banks (DBS, OCBC, UOB, Standard Chartered, Citibank) routinely test SQL in their BA/DA hiring process, and the questions cluster around a small set of recurring problem domains. This portfolio is built directly around those domains, using a schema and seed data realistic enough to reflect actual production patterns rather than a generic tutorial database:

- Customer segmentation and lifetime value
- Loan delinquency tracking and NPL reporting
- Net Interest Margin (NIM) and revenue decomposition
- MAS 610 regulatory return preparation
- IFRS 9 expected credit loss (ECL) provisioning

Every query folder maps to a function a BA/DA team actually owns inside a Singapore bank.

---

## Schema overview

Seven tables: two reference tables (`products`, `risk_grades`), and five core tables that mirror how a retail bank's data warehouse is typically modeled — customers fan out into accounts and loans, accounts generate transactions, and loans generate a repayment schedule. `transactions` is partitioned by year, which is the standard pattern for high-volume bank transaction tables.

```
risk_grades ──┐
              ├──< loans ──< loan_repayments
products ─────┤
              └──< accounts ──< transactions
customers ────┴──< (accounts, loans)
```

Design choices worth noting if you're reviewing this as a hiring manager:
- `customers.nric_token` stores a masked identifier, not the raw NRIC — a PDPA-aware modeling choice, not an oversight.
- `loans.ecl_stage` and `risk_grades.ecl_provision_pct` implement IFRS 9's three-stage impairment model.
- `loans.property_type` distinguishes HDB / private condo / landed, which matters for MAS TDSR/LTV stress-testing logic.

---

## Project structure

```
singapore-banking-sql-analytics/
├── schema/
│   └── tables.sql                        ← Full DDL: 7 tables, partitioned transactions
├── seed/
│   └── sample_data.sql                   ← Realistic SG banking test data
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
└── README.md
```

> **Note:** earlier commits had duplicate `tables.sql` / `sample_data.sql` files sitting at the repo root alongside `schema/` and `seed/`. Those have been removed — `schema/` and `seed/` are now the single source of truth.

---

## Skills & techniques covered

| Technique                                                  | Where used                              |
| ------------------------------------------------------------ | ---------------------------------------- |
| Window functions (RANK, NTILE, LAG, LEAD, running totals)    | RFM, roll rates, vintage curves          |
| Multi-step CTEs                                               | All analysis files                       |
| Conditional aggregation (CASE WHEN inside SUM)                | NII decomposition, DPD aging             |
| Date arithmetic (DATEDIFF, age buckets, MOB)                  | Vintage, delinquency, tenure             |
| Self-joins for period comparison                              | Cohort retention, roll rate matrix       |
| Partition-by-range table design                                | `transactions` (yearly partitions)       |
| Reconciliation / data quality checks                          | MAS 610, NPL schedule                    |
| IFRS 9 ECL stage logic                                          | Loan schema, NPL schedule                |
| MAS regulatory taxonomy                                        | MAS 610 returns                          |

---

## Interview prep notes

These queries reflect common take-home test questions from Singapore bank hiring:

> *"Write a query to find customers who transacted last month but not this month"*
> → `analysis/01_customer_analytics/cohort_retention.sql`

> *"Calculate the NPL ratio and provision coverage ratio for the mortgage book"*
> → `analysis/04_regulatory/npl_schedule.sql`

> *"Produce a DPD roll rate matrix showing movement between delinquency buckets"*
> → `analysis/02_loan_risk/delinquency_aging.sql`

> *"How would you calculate Net Interest Margin in SQL?"*
> → `analysis/03_revenue_nim/net_interest_income.sql`

---

## Local setup

```bash
# Requires PostgreSQL 14+
createdb sg_bank_demo
psql sg_bank_demo < schema/tables.sql
psql sg_bank_demo < seed/sample_data.sql

# Run any analysis query
psql sg_bank_demo < analysis/01_customer_analytics/rfm_segmentation.sql
```

To verify the full set runs cleanly end to end:

```bash
for f in analysis/*/*.sql; do
  echo "Running $f"
  psql sg_bank_demo -f "$f" -v ON_ERROR_STOP=1 || echo "FAILED: $f"
done
```

---

## Roadmap

- [ ] Add a `docs/data_dictionary.md` describing every column and its business meaning
- [ ] Add expected-output snippets (markdown tables) under each query so reviewers don't need to spin up Postgres
- [x] Add a `LICENSE` file (MIT)
- [ ] Expand seed data beyond the current illustrative set for more realistic roll-rate/vintage curves

---

## License

MIT — see [LICENSE](LICENSE).

---

*Built to demonstrate SQL depth and Singapore financial domain knowledge expected at DBS, OCBC, UOB, Standard Chartered, Citibank, GIC, Temasek, and MAS.*
