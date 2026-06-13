-- scd2-bloat-check.sql — DIM4 guard: flag SCD Type 2 current-state queries that
-- omit the `is_current = true` filter (the ~160M-row bloat full-scan).
--
-- SCD Type 2 tables grow unbounded: a 10M-entity dimension with 3 updates/entity/year
-- adds 30M rows/year -> ~160M rows after 5 years (10M initial + 30M x 5), of which only
-- ~10M are current. Any current-state query without `is_current = true` scans them all.
--
-- Usage (DuckDB):
--   duckdb mydw.duckdb -c ".read scripts/scd2-bloat-check.sql"
-- or set the table name explicitly:
--   duckdb mydw.duckdb -c "SET VARIABLE dim_table='main.dim_customer'; .read scripts/scd2-bloat-check.sql"
--
-- It reports total rows vs current rows and the bloat ratio. A ratio >> 1 means any
-- query missing `WHERE is_current = true` pays a full-table scan of dead history.

-- Default target table; override via: SET VARIABLE dim_table = '<schema.table>';
SET VARIABLE dim_table = COALESCE(TRY(getvariable('dim_table')), 'main.dim_customer');

SELECT
  getvariable('dim_table')                                   AS scd2_table,
  COUNT(*)                                                   AS total_rows,
  COUNT(*) FILTER (WHERE is_current = true)                  AS current_rows,
  COUNT(*) FILTER (WHERE is_current = false OR is_current IS NULL) AS historical_rows,
  ROUND(
    COUNT(*)::DOUBLE
    / NULLIF(COUNT(*) FILTER (WHERE is_current = true), 0), 2
  )                                                          AS bloat_ratio,
  CASE
    WHEN COUNT(*) FILTER (WHERE is_current = true) = 0
      THEN 'WARN: no is_current=true rows — wrong table or non-SCD2 schema'
    WHEN COUNT(*)::DOUBLE
       / NULLIF(COUNT(*) FILTER (WHERE is_current = true), 0) >= 2.0
      THEN 'FAIL: bloat_ratio >= 2.0 — current-state queries MUST filter is_current = true (DIM4)'
    ELSE 'OK: low bloat — still always filter is_current = true on current-state queries'
  END                                                        AS verdict
FROM query_table(getvariable('dim_table'));
