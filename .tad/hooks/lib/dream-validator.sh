#!/usr/bin/env bash
# dream-validator.sh — Safety validator for *dream knowledge consolidation
# Compares original knowledge file against candidate to ensure no safety regression.
# Usage: dream-validator.sh <original> <candidate>
# Exit codes: 0 = PASS, 1 = FAIL (with details), 2 = usage error
# NOTE: Run from the project root directory. Grounded-in path checks use relative paths.

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: dream-validator.sh <original.md> <candidate.md>"
  exit 2
fi

ORIGINAL="$1"
CANDIDATE="$2"

if [ ! -f "$ORIGINAL" ]; then
  echo "FAIL: Original file not found: $ORIGINAL"
  exit 1
fi
if [ ! -f "$CANDIDATE" ]; then
  echo "FAIL: Candidate file not found: $CANDIDATE"
  exit 1
fi

ERRORS=0

# Check 1: Safety keyword count — counts LINES containing any keyword (grep -cE)
ORIG_KEYWORDS=$(grep -cE 'MUST|MANDATORY|VIOLATION|BLOCKING' "$ORIGINAL" || true)
CAND_KEYWORDS=$(grep -cE 'MUST|MANDATORY|VIOLATION|BLOCKING' "$CANDIDATE" || true)

if [ "$CAND_KEYWORDS" -lt "$ORIG_KEYWORDS" ]; then
  echo "FAIL: Safety keyword lines decreased: $ORIG_KEYWORDS → $CAND_KEYWORDS"
  ERRORS=$((ERRORS + 1))
else
  echo "PASS: Safety keyword lines preserved: $ORIG_KEYWORDS → $CAND_KEYWORDS"
fi

# Check 2: Entry count (### headers) — can decrease (merges) but not to zero
ORIG_ENTRIES=$(grep -c '^### ' "$ORIGINAL" || true)
CAND_ENTRIES=$(grep -c '^### ' "$CANDIDATE" || true)

if [ "$CAND_ENTRIES" -eq 0 ]; then
  echo "FAIL: Candidate has zero entries (all content lost)"
  ERRORS=$((ERRORS + 1))
elif [ "$ORIG_ENTRIES" -eq 0 ]; then
  echo "PASS: Entry count: 0 → $CAND_ENTRIES (original had no entries)"
else
  echo "PASS: Entry count: $ORIG_ENTRIES → $CAND_ENTRIES ($(( (ORIG_ENTRIES - CAND_ENTRIES) * 100 / ORIG_ENTRIES ))% reduction)"
fi

# Check 3: Foundational section byte-identical
FOUND_BOUNDARY="## Accumulated Learnings"

ORIG_FOUND=$(sed -n "1,/^${FOUND_BOUNDARY}/p" "$ORIGINAL")
CAND_FOUND=$(sed -n "1,/^${FOUND_BOUNDARY}/p" "$CANDIDATE")

if [ "$ORIG_FOUND" = "$CAND_FOUND" ]; then
  echo "PASS: Foundational section is byte-identical"
else
  echo "FAIL: Foundational section differs between original and candidate"
  diff <(sed -n "1,/^${FOUND_BOUNDARY}/p" "$ORIGINAL") \
       <(sed -n "1,/^${FOUND_BOUNDARY}/p" "$CANDIDATE") || true
  ERRORS=$((ERRORS + 1))
fi

# Check 4: Grounded-in path existence (advisory)
STALE_REFS=0
TOTAL_REFS=0
while IFS= read -r line; do
  paths=$(echo "$line" | grep -oE '[^ ,()]+\.(md|sh|yaml|json|ts|js|py)' || true)
  for p in $paths; do
    case "$p" in
      http*|*.example.*) continue ;;
    esac
    # Expand tilde paths
    resolved="${p/#\~/$HOME}"
    TOTAL_REFS=$((TOTAL_REFS + 1))
    if [ ! -e "$resolved" ]; then
      STALE_REFS=$((STALE_REFS + 1))
    fi
  done
done < <(grep -i 'grounded in' "$CANDIDATE" || true)

if [ "$TOTAL_REFS" -gt 0 ]; then
  echo "INFO: Grounded-in refs checked: $TOTAL_REFS total, $STALE_REFS stale"
else
  echo "INFO: No Grounded-in references found in candidate"
fi

# Check 5: Line count
ORIG_LINES=$(wc -l < "$ORIGINAL")
CAND_LINES=$(wc -l < "$CANDIDATE")

if [ "$ORIG_LINES" -eq 0 ]; then
  echo "INFO: Line count: 0 → $CAND_LINES (original was empty)"
elif [ "$CAND_LINES" -gt "$ORIG_LINES" ]; then
  echo "WARN: Candidate is longer than original ($CAND_LINES > $ORIG_LINES lines)"
else
  REDUCTION=$(( (ORIG_LINES - CAND_LINES) * 100 / ORIG_LINES ))
  echo "INFO: Line count: $ORIG_LINES → $CAND_LINES ($REDUCTION% reduction)"
fi

# Summary
echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "RESULT: FAIL ($ERRORS checks failed)"
  exit 1
else
  echo "RESULT: PASS (all safety checks passed)"
  exit 0
fi
