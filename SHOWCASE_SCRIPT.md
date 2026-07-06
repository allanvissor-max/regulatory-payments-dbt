# 90-second showcase script

> “This is a dbt project I built to demonstrate how I would turn raw payment data into a trustworthy regulatory data product. I used SQLite locally so that the complete project can run without cloud credentials; the dbt structure is portable to a warehouse such as Snowflake or BigQuery.”

1. **Start with the business requirement.**
   - The pipeline produces three regulatory categories: UK cross-currency GBP routes, US cross-currency payments and US same-currency payments.
   - The reporting period is explicitly defined as `2022-04-01` inclusive to `2023-08-01` exclusive.

2. **Show modular lineage.**
   - `raw` seeds simulate source extracts.
   - `staging` standardises country codes, parses currency routes and flags duplicate IDs.
   - `intermediate` applies customer joins and business validity rules.
   - `marts` exposes trusted facts, reports and a data-quality exceptions table.

3. **Explain quality and auditability.**
   - The project has schema tests for uniqueness, completeness, allowed values and two custom tests.
   - Invalid rows are not silently discarded. They are excluded from `fct_payments` but remain visible in `mart_data_quality_exceptions` with an explanation such as “orphan customer” or “invalid currency route”.

4. **Show engineering practices.**
   - `ref()` makes dependencies explicit and produces lineage documentation.
   - `dbt build` runs the models and tests together.
   - GitHub Actions repeats `dbt seed`, `dbt build` and `dbt docs generate` for every push and pull request.

5. **Close with the outcome.**
   - The result is a reproducible, documented and testable reporting pipeline rather than a one-off SQL query.

## Useful commands during a demo

```powershell
# Rebuild everything and run all quality checks
dbt build --profiles-dir .

# Generate and open interactive lineage documentation
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```
