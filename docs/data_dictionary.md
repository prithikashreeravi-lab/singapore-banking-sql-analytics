# Data Dictionary

## customers
| Column | Description |
|---|---|
| segment | AUM-based tier: MASS / EMERGING / AFFLUENT / PRIORITY / PRIVATE |
| residency | CITIZEN / PR / EP / SP / WP |
| income_band | <30K / 30-80K / 80-200K / >200K (annual SGD) |
| nric_token | PDPA-masked NRIC — full number never stored |

## loans
| Column | Description |
|---|---|
| status | CURRENT / DELINQUENT / NPL / RESTRUCTURED / WRITTEN_OFF / CLOSED |
| dpd | Days Past Due |
| dpd_bucket | CURRENT / 1-30 / 31-60 / 61-90 / >90 |
| ecl_stage | IFRS 9 stage: 1 (performing) / 2 (watch) / 3 (impaired) |
| ltv_ratio | Loan-to-Value, mortgages only (e.g. 0.7500 = 75%) |

## transactions
Partitioned by year on `txn_date`. `txn_type` is CREDIT / DEBIT / TRANSFER / FEE / INTEREST.

---

See `docs/sg_banking_glossary.md` for regulatory terms (MAS 610, NPL, TDSR, ECL, etc.)
