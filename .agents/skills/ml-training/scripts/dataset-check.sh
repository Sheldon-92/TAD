#!/usr/bin/env bash
# dataset-check.sh — Validate a fine-tune dataset (JSONL: ShareGPT / ChatML / Alpaca / preference)
#
# Usage: bash scripts/dataset-check.sh <file.jsonl>
#
# Checks (deterministic, per references/data-preparation.md + lora-finetune.md):
#   - file is valid JSONL (one JSON object per line)
#   - detects schema: sharegpt | chatml | alpaca | preference
#   - counts examples and applies the size-threshold verdict
#       <100 = DO-NOT-FINETUNE, 100-499 = narrow, 500-10000 = sweet spot, >10000 = diminishing
#   - flags exact-duplicate lines (dedup reminder)
#
# Requirements: jq

set -euo pipefail

FILE="${1:-}"

if ! command -v jq >/dev/null 2>&1; then
  echo "✗ jq not found. Install: brew install jq  (or apt-get install jq)" >&2
  exit 1
fi

if [ -z "$FILE" ]; then
  echo "Usage: bash scripts/dataset-check.sh <file.jsonl>" >&2
  exit 1
fi
if [ ! -f "$FILE" ]; then
  echo "✗ File not found: $FILE" >&2
  exit 1
fi

echo "=== Dataset Check: $FILE ==="
echo ""

# ── 1. Valid JSONL ───────────────────────────────────────────────────────────
BAD=0
LINENO=0
while IFS= read -r line || [ -n "$line" ]; do
  LINENO=$((LINENO + 1))
  [ -z "$line" ] && continue
  if ! printf '%s' "$line" | jq -e . >/dev/null 2>&1; then
    echo "  ✗ Line $LINENO is not valid JSON"
    BAD=$((BAD + 1))
  fi
done < "$FILE"

if [ "$BAD" -gt 0 ]; then
  echo "✗ FAIL — $BAD invalid JSON line(s). Fix before training."
  exit 1
fi
echo "  ✓ Valid JSONL"

# ── 2. Schema detection (sample first non-empty line) ────────────────────────
FIRST=$(grep -m1 -v '^[[:space:]]*$' "$FILE" || true)
SCHEMA="unknown"
if printf '%s' "$FIRST" | jq -e '.conversations' >/dev/null 2>&1; then
  SCHEMA="sharegpt"
elif printf '%s' "$FIRST" | jq -e '.messages' >/dev/null 2>&1; then
  SCHEMA="chatml"
elif printf '%s' "$FIRST" | jq -e '.chosen and .rejected' >/dev/null 2>&1; then
  SCHEMA="preference (DPO/GRPO)"
elif printf '%s' "$FIRST" | jq -e '.instruction and .output' >/dev/null 2>&1; then
  SCHEMA="alpaca"
fi
echo "  ✓ Detected schema: $SCHEMA"
if [ "$SCHEMA" = "unknown" ]; then
  echo "    ⚠ Not a recognized schema (expected conversations/messages/instruction+output/chosen+rejected)"
fi

# ── 3. Size threshold verdict ────────────────────────────────────────────────
N=$(grep -cv '^[[:space:]]*$' "$FILE" || true)
echo "  ✓ Examples: $N"

if [ "$N" -lt 100 ]; then
  VERDICT="DO-NOT-FINETUNE (<100 = below practical floor; use few-shot/RAG)"
elif [ "$N" -lt 500 ]; then
  VERDICT="NARROW-ONLY (100-499: classification/format tasks only)"
elif [ "$N" -le 10000 ]; then
  VERDICT="SWEET-SPOT (500-10000: recommended working range)"
else
  VERDICT="DIMINISHING (>10000: returns flatten unless complex domain shift)"
fi
echo "    → Size verdict: $VERDICT"

# ── 4. Exact-duplicate flag (dedup reminder) ─────────────────────────────────
DUPES=$(grep -v '^[[:space:]]*$' "$FILE" | sort | uniq -d | wc -l | tr -d ' ')
if [ "$DUPES" -gt 0 ]; then
  echo "  ⚠ $DUPES exact-duplicate line(s) — dedup before training (clean>noisy: 500 clean > 5000 noisy)"
else
  echo "  ✓ No exact duplicates"
fi

echo ""
if [ "$N" -lt 100 ]; then
  echo "✗ FAIL — dataset too small to fine-tune."
  exit 1
fi
echo "✓ PASS — dataset structurally valid; review size + dedup notes above."
exit 0
