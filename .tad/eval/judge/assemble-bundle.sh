#!/usr/bin/env bash
set -euo pipefail

SLUG="${1:?Usage: assemble-bundle.sh <slug>}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT_DIR="$(cd "$(dirname "$0")" && pwd)/bundles"
OUT="$OUT_DIR/${SLUG}.md"
MAX_LINES=1500

mkdir -p "$OUT_DIR"
: > "$OUT"

append() { cat >> "$OUT"; }
hr() { echo -e "\n---\n" >> "$OUT"; }
section() { echo -e "\n# $1\n" >> "$OUT"; }

# Find handoff
HF=$(ls "$ROOT/archive/handoffs/HANDOFF-"*"-${SLUG}.md" 2>/dev/null | head -1)
if [ -z "$HF" ]; then echo "ERROR: no handoff for slug '$SLUG'" >&2; exit 1; fi

# Find completion (may not exist — graceful)
CF=$(ls "$ROOT/archive/handoffs/COMPLETION-"*"-${SLUG}.md" 2>/dev/null | head -1 || true)

# --- Handoff excerpt (frontmatter + §9.1 + §6 head) ---
section "HANDOFF: ${SLUG}"
# Frontmatter (YAML block)
awk '/^---$/{c++} c==1{print} c==2{print;exit}' "$HF" | append
hr

# §9.1 Spec Compliance (if exists)
if grep -q '## 9.1\|Spec Compliance' "$HF" 2>/dev/null; then
  echo "## §9.1 Spec Compliance Checklist (excerpt)" >> "$OUT"
  awk '/^## 9\.1|Spec Compliance Checklist/,/^## [0-9]/' "$HF" | head -80 | append
  hr
fi

# §6 Implementation Steps (head)
if grep -q '## 6\.' "$HF" 2>/dev/null; then
  echo "## §6 Implementation Steps (head)" >> "$OUT"
  awk '/^## 6\./,/^## [7-9]/' "$HF" | head -40 | append
  hr
fi

# §9.2 Audit Trail (if exists)
if grep -q '## 9.2\|Audit Trail' "$HF" 2>/dev/null; then
  echo "## §9.2 Expert Review Audit Trail" >> "$OUT"
  awk '/^## 9\.2|Audit Trail/,/^## [0-9]/' "$HF" | head -40 | append
  hr
fi

# --- Completion (full, usually <200 lines) ---
if [ -n "$CF" ]; then
  section "COMPLETION: ${SLUG}"
  cat "$CF" | append
  hr
fi

# --- Review files (head 80 each) ---
for review_dir in "$ROOT/evidence/reviews/blake/${SLUG}" "$ROOT/evidence/reviews/alex/${SLUG}"; do
  if [ -d "$review_dir" ]; then
    for rf in "$review_dir"/*.md; do
      [ -f "$rf" ] || continue
      section "REVIEW: $(basename "$rf")"
      head -80 "$rf" | append
      hr
    done
  fi
done

# --- Acceptance tests (head 80 each) ---
AT_DIR="$ROOT/evidence/acceptance-tests/${SLUG}"
if [ -d "$AT_DIR" ]; then
  for af in "$AT_DIR"/*.md; do
    [ -f "$af" ] || continue
    section "ACCEPTANCE-TEST: $(basename "$af")"
    head -80 "$af" | append
    hr
  done
fi

# --- Trace events (grep by slug, sorted by timestamp) ---
TRACE_LINES=$(grep "\"slug\":\"${SLUG}\"" "$ROOT/evidence/traces/"*.jsonl 2>/dev/null | sort -t'"' -k4 || true)
if [ -n "$TRACE_LINES" ]; then
  section "TRACE EVENTS (slug=${SLUG}, sorted by ts)"
  echo "$TRACE_LINES" | append
  hr
fi

# --- Line count check ---
LINES=$(wc -l < "$OUT")
if [ "$LINES" -gt "$MAX_LINES" ]; then
  echo "WARNING: bundle $SLUG has $LINES lines (max $MAX_LINES). Truncating." >&2
  head -"$MAX_LINES" "$OUT" > "${OUT}.tmp" && mv "${OUT}.tmp" "$OUT"
fi

echo "Bundle assembled: $OUT ($LINES lines)"
