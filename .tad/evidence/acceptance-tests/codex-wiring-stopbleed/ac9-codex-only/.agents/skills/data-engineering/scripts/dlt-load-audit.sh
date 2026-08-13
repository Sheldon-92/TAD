#!/usr/bin/env bash
# dlt-load-audit.sh — Audit a dlt ingestion run via the _dlt_loads metadata table (ING5).
#
# A clean process exit is NOT proof of a successful, complete load. dlt records
# every load batch in <dataset>._dlt_loads with a status code per load_id:
#   status 0 = completed/succeeded   (non-zero / NULL = failed or aborted)
# This script queries the latest load_ids and FAILS (exit 1) if the most recent
# load did not complete, so the check is code — not "punt to Claude."
#
# Usage:
#   bash scripts/dlt-load-audit.sh <pipeline.duckdb> [dataset] [n]
#     <pipeline.duckdb>  path to the dlt DuckDB destination file
#     [dataset]          dataset/schema name (default: raw)
#     [n]                how many recent loads to print (default: 5)
#
# Requirements: duckdb CLI (https://duckdb.org/docs/installation/)

set -euo pipefail

DB_PATH="${1:-}"
DATASET="${2:-raw}"
N="${3:-5}"

if ! command -v duckdb >/dev/null 2>&1; then
  echo "X duckdb CLI not found. Install: https://duckdb.org/docs/installation/ (brew install duckdb)" >&2
  exit 1
fi

if [ -z "$DB_PATH" ]; then
  echo "Usage: bash scripts/dlt-load-audit.sh <pipeline.duckdb> [dataset] [n]" >&2
  echo "  Example: bash scripts/dlt-load-audit.sh ./financial_etl_dlt.duckdb raw" >&2
  exit 1
fi

if [ ! -f "$DB_PATH" ]; then
  echo "X DuckDB file not found: $DB_PATH" >&2
  exit 1
fi

echo "=== dlt load audit: $DB_PATH (dataset=$DATASET) ==="

# Print the most recent loads (status 0 = succeeded; anything else = investigate).
duckdb "$DB_PATH" -box "
  SELECT load_id, schema_name, status, inserted_at
  FROM ${DATASET}._dlt_loads
  ORDER BY inserted_at DESC
  LIMIT ${N};
" || {
  echo "X Could not query ${DATASET}._dlt_loads — wrong dataset name, or no loads recorded." >&2
  exit 1
}

# Assert the single most recent load completed (status = 0).
LATEST_STATUS="$(duckdb "$DB_PATH" -noheader -list "
  SELECT status FROM ${DATASET}._dlt_loads
  ORDER BY inserted_at DESC LIMIT 1;
" 2>/dev/null | tr -d '[:space:]')"

if [ -z "$LATEST_STATUS" ]; then
  echo "X No rows in ${DATASET}._dlt_loads — the pipeline has never completed a load." >&2
  exit 1
fi

if [ "$LATEST_STATUS" != "0" ]; then
  echo "X FAIL: latest load status = ${LATEST_STATUS} (expected 0=completed). Load did not finish cleanly." >&2
  exit 1
fi

echo "OK: latest load completed (status=0). ING5 audit passed."
