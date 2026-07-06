# Regulatory Payments Analytics — dbt + SQLite

[![dbt CI](https://github.com/YOUR_GITHUB_USERNAME/regulatory-payments-dbt/actions/workflows/dbt_ci.yml/badge.svg)](https://github.com/YOUR_GITHUB_USERNAME/regulatory-payments-dbt/actions/workflows/dbt_ci.yml)

A portfolio-ready dbt project that turns raw payments data into **tested, documented and auditable regulatory reporting marts**.

> **Data note:** all CSV data is synthetic. The project intentionally includes a few bad records so that the data-quality workflow is visible rather than theoretical.

## Business problem

A payments business needs reproducible monthly reporting for:

- **R1:** UK customers’ cross-currency payments where the route involves GBP
- **R2:** US customers’ cross-currency payment volume
- **R2:** US customers’ same-currency payment volume

The pipeline must make its definitions explicit, validate quality, exclude invalid records from trusted facts and keep an audit trail of every exception.

## Architecture

```mermaid
flowchart LR
    A[Seeds: synthetic raw customers & transactions] --> B[Staging: standardise, parse, deduplicate]
    B --> C[Intermediate: enrich with customer data & business flags]
    C --> D[Trusted fact: fct_payments]
    C --> E[DQ audit: mart_data_quality_exceptions]
    D --> F[Regulatory mart]
    D --> G[Monthly KPI mart]
```

## Data lineage

```text
raw_customers ──> stg_customers ──┐
                                   ├──> int_payment_enriched ──> fct_payments ──> mart_regulatory_payment_volume
raw_transactions ─> stg_transactions ┘                           └─────────────> mart_monthly_payment_kpis
                                               └──────────────────────────────────> mart_data_quality_exceptions
```

## Key design choices

| Area | Implementation |
|---|---|
| Modelling | Layered `raw → staging → intermediate → marts` design |
| Reusability | `source()` at entry point and `ref()` for all model dependencies |
| Data quality | Standard dbt tests plus two custom generic tests |
| Auditability | Bad rows appear in `mart_data_quality_exceptions` with a human-readable reason |
| Reporting definition | The reporting period is **2022-04-01 inclusive to 2023-08-01 exclusive** |
| Amounts | Refunds may be negative in `signed_amount_gbp`; reporting volume uses `abs(amount_gbp)` |
| Deployment | GitHub Actions runs `dbt seed`, `dbt build` and `dbt docs generate` on every push or pull request |

## Run locally on Windows

### 1. Create and activate a virtual environment

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 2. Set the local SQLite paths

```powershell
$env:DBT_SQLITE_MAIN_DB = "$PWD\data\warehouse.db"
$env:DBT_SQLITE_SCHEMA_DIR = "$PWD\data"
```

### 3. Validate, build and test

```powershell
dbt debug --profiles-dir .
dbt seed --full-refresh --profiles-dir .
dbt build --profiles-dir .
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

Or run the included script:

```powershell
.\scripts\run_local.ps1
```

## What to show in an interview

1. Open **dbt docs** and show the lineage graph.
2. Open `models/marts/mart_regulatory_payment_volume.sql` and explain the business rules.
3. Open `models/marts/mart_data_quality_exceptions.sql` and demonstrate that invalid data is surfaced, not hidden.
4. Run `dbt build` and show the automated test results.
5. Open `.github/workflows/dbt_ci.yml` and explain that the quality gate runs on every GitHub push or pull request.

## Interview walkthrough

See [`SHOWCASE_SCRIPT.md`](SHOWCASE_SCRIPT.md) for a concise 90-second project demo.

## Expected project outputs

- `fct_payments`: trusted transaction-level payments
- `mart_regulatory_payment_volume`: monthly regulated payment volume
- `mart_monthly_payment_kpis`: operational payment KPIs by country
- `mart_data_quality_exceptions`: rejected rows with clear reasons


## Tech stack

`dbt Core` · `dbt-sqlite` · `SQLite` · `SQL` · `Git` · `GitHub Actions`
