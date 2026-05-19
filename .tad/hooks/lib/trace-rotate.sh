#!/bin/bash
# TAD Trace Rotation — archive old trace files
# Usage: bash .tad/hooks/lib/trace-rotate.sh [--days N] [--dry-run]
set -euo pipefail

ARCHIVE_DAYS=180
DRY_RUN=false

while [ $# -gt 0 ]; do
  case "$1" in
    --days) ARCHIVE_DAYS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

TRACE_DIR=".tad/evidence/traces"
ARCHIVE_DIR=".tad/archive/traces"

[ -d "$TRACE_DIR" ] || { echo "No trace directory found"; exit 0; }
mkdir -p "$ARCHIVE_DIR"

# macOS (BSD date -v) / Linux (date -d) compatible cutoff
CUTOFF=$(date -v-${ARCHIVE_DAYS}d +%Y-%m-%d 2>/dev/null || date -d "${ARCHIVE_DAYS} days ago" +%Y-%m-%d)
MOVED=0

for f in "$TRACE_DIR"/*.jsonl; do
  [ -f "$f" ] || continue
  FILE_DATE=$(basename "$f" .jsonl)
  # Skip files that don't match YYYY-MM-DD pattern
  [[ "$FILE_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue
  if [[ "$FILE_DATE" < "$CUTOFF" ]]; then
    if [ "$DRY_RUN" = true ]; then
      echo "Would archive: $f"
    else
      mv "$f" "$ARCHIVE_DIR/"
    fi
    MOVED=$((MOVED + 1))
  fi
done

echo "Trace rotation: $MOVED files archived (cutoff: $CUTOFF, threshold: ${ARCHIVE_DAYS} days)"
