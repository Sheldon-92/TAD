#!/usr/bin/env bash
# knowledge-lint.sh — soft lint for playbook entries
# ALWAYS exits 0 (never blocks). Reports violations to stdout.
# Usage: bash .tad/hooks/lib/knowledge-lint.sh [directory]
# Default directory: .tad/project-knowledge/

set -euo pipefail

DIR="${1:-.tad/project-knowledge}"
VIOLATIONS=0

for file in "$DIR"/*.md "$DIR"/patterns/*.md; do
  [ -f "$file" ] || continue
  base=$(basename "$file")
  [[ "$base" == "README.md" || "$base" == "_index.md" || "$base" == "principles.md" ]] && continue

  # Check 1: failure_mode present in entries that have ### headers
  entry_count=$(grep -c '^### ' "$file" 2>/dev/null || true)
  if [ "$entry_count" -gt 0 ]; then
    fm_count=$(grep -ciE 'failure.mode|naive.default|错误默认' "$file" 2>/dev/null || true)
    if [ "$fm_count" -eq 0 ]; then
      echo "WARN: $file — $entry_count entries but 0 failure_mode mentions"
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  fi

  # Check 2: relative time words
  # macOS BSD grep does not support \b — use bracket-class word boundary
  rel_time=$(grep -niE '(^|[^a-zA-Z])today([^a-zA-Z]|$)|(^|[^a-zA-Z])recently([^a-zA-Z]|$)|(^|[^a-zA-Z])yesterday([^a-zA-Z]|$)|last week|今天|最近|上次|昨天' "$file" 2>/dev/null || true)
  if [ -n "$rel_time" ]; then
    echo "WARN: $file — relative time detected:"
    echo "$rel_time" | head -3
    VIOLATIONS=$((VIOLATIONS + 1))
  fi

  # Check 3: ALL-CAPS MUST/NEVER/ALWAYS on non-SAFETY entries
  must_lines=$(grep -nE '[[:space:]]MUST[[:space:]]|[[:space:]]NEVER[[:space:]]|[[:space:]]ALWAYS[[:space:]]' "$file" 2>/dev/null || true)
  if [ -n "$must_lines" ]; then
    non_safety_musts=$(echo "$must_lines" | grep -viE 'SAFETY|read_only' || true)
    if [ -n "$non_safety_musts" ]; then
      echo "INFO: $file — ALL-CAPS imperative on non-SAFETY entry (yellow flag per Anthropic rule):"
      echo "$non_safety_musts" | head -3
    fi
  fi
done

echo ""
echo "knowledge-lint: $VIOLATIONS warnings found"
exit 0
