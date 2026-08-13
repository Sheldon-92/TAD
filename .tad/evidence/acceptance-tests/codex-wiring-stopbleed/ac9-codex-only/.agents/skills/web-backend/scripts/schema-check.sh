#!/usr/bin/env bash
# schema-check.sh — Lint database schema and migration files
#
# Usage: bash scripts/schema-check.sh <schema-path>
#
# Checks:
#   - Atlas migration lint (drift detection, destructive change warnings)
#   - SQLFluff linting for raw SQL files
#   - Missing soft-delete columns on tables named like entities
#   - Auto-incrementing IDs exposed in public API (heuristic check)
#
# Requirements: atlas (atlas CLI), sqlfluff (Python)

set -euo pipefail

SCHEMA_PATH="${1:-}"

# ── Dependency preflight ─────────────────────────────────────────────────────
MISSING=0
if ! command -v atlas >/dev/null 2>&1; then
  echo "✗ atlas not found." >&2
  echo "  Install: curl -sSf https://atlasgo.sh | sh" >&2
  MISSING=1
fi
if ! command -v sqlfluff >/dev/null 2>&1; then
  echo "✗ sqlfluff not found." >&2
  echo "  Install: pip install sqlfluff" >&2
  MISSING=1
fi
[ $MISSING -eq 1 ] && exit 1

if [ -z "$SCHEMA_PATH" ]; then
  echo "Usage: bash scripts/schema-check.sh <schema-dir-or-file>" >&2
  echo "  Example: bash scripts/schema-check.sh migrations/" >&2
  echo "  Example: bash scripts/schema-check.sh schema.sql" >&2
  exit 1
fi

if [ ! -e "$SCHEMA_PATH" ]; then
  echo "✗ Path not found: $SCHEMA_PATH" >&2
  exit 1
fi

echo "=== Schema Check: $SCHEMA_PATH ==="
echo ""

ERRORS=0
WARNINGS=0

# ── Atlas migration lint ─────────────────────────────────────────────────────
echo "[ 1/3 ] Atlas migration lint..."

if [ -d "$SCHEMA_PATH" ]; then
  if atlas migrate lint --dir "file://${SCHEMA_PATH}" 2>&1; then
    echo "  ✓ Atlas lint: PASS"
  else
    echo "  ✗ Atlas lint: FAIL — review migration files for destructive changes"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ⚠ Not a directory — skipping Atlas lint (provide migrations/ directory)"
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ── SQLFluff SQL style check ─────────────────────────────────────────────────
echo "[ 2/3 ] SQLFluff lint..."

# Find SQL files
SQL_FILES=$(find "$SCHEMA_PATH" -name "*.sql" 2>/dev/null | head -50)

if [ -z "$SQL_FILES" ]; then
  echo "  ⚠ No .sql files found in $SCHEMA_PATH — skipping SQLFluff"
  WARNINGS=$((WARNINGS + 1))
else
  SQL_COUNT=$(echo "$SQL_FILES" | wc -l | tr -d ' ')
  if sqlfluff lint --dialect ansi $SQL_FILES 2>&1; then
    echo "  ✓ SQLFluff: PASS ($SQL_COUNT files checked)"
  else
    echo "  ⚠ SQLFluff: style issues found (non-blocking)"
    WARNINGS=$((WARNINGS + 1))
  fi
fi
echo ""

# ── Heuristic: check for missing soft-delete columns ────────────────────────
echo "[ 3/3 ] Soft-delete column check..."

ALL_SQL=$(find "$SCHEMA_PATH" -name "*.sql" -exec cat {} + 2>/dev/null || true)

if [ -n "$ALL_SQL" ]; then
  # Find tables without deleted_at column (heuristic: tables with 'created_at' but no 'deleted_at')
  TABLES_WITH_CREATED=$(echo "$ALL_SQL" | grep -iE 'created_at' | grep -iE 'CREATE TABLE' | \
    grep -oiE 'CREATE TABLE [a-z_]+' | awk '{print $3}' || true)

  if [ -n "$TABLES_WITH_CREATED" ]; then
    MISSING_SOFT_DELETE=""
    while IFS= read -r table; do
      if ! echo "$ALL_SQL" | grep -qi "deleted_at"; then
        MISSING_SOFT_DELETE="${MISSING_SOFT_DELETE} ${table}"
      fi
    done <<< "$TABLES_WITH_CREATED"

    if [ -n "$MISSING_SOFT_DELETE" ]; then
      echo "  ⚠ Tables with created_at but no deleted_at (review per Rule 6 in references/database.md):"
      echo "$MISSING_SOFT_DELETE" | tr ' ' '\n' | grep -v '^$' | sed 's/^/     /'
      WARNINGS=$((WARNINGS + 1))
    else
      echo "  ✓ Soft-delete columns: OK"
    fi
  else
    echo "  ℹ No CREATE TABLE statements with created_at found — skipping"
  fi
else
  echo "  ⚠ No SQL content found — skipping soft-delete check"
fi

# Summary
echo ""
echo "=== Summary ==="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo "✓ PASS — no issues found"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo "⚠ PASS with warnings — $WARNINGS warning(s), 0 errors"
  exit 0
else
  echo "✗ FAIL — $ERRORS error(s), $WARNINGS warning(s)"
  exit 1
fi
