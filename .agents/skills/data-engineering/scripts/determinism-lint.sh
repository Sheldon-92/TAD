#!/usr/bin/env bash
# determinism-lint.sh — Annotation linter for the data-engineering pack references.
#
# Deterministic structural checks (code, not "punt to Claude"):
#   1. Every rule heading (### XYZn:) is followed by a `**determinismLevel**:` line
#      before the next rule heading.
#   2. determinismLevel values are restricted to the allowed vocabulary
#      (deterministic | semi-deterministic | non-deterministic).
#   3. Every `> Source:` depth-claim line carries either a source URL (http...) or a
#      findings.md citation — no orphan depth claims (per QUALITY-BAR Layer B + the
#      2026-05-15 YOLO-audit action D: auditable research evidence).
#
# Usage:
#   bash scripts/determinism-lint.sh
#   bash scripts/determinism-lint.sh /path/to/data-engineering   # explicit pack root
#
# Exit 0 = all checks pass; exit 1 = at least one violation.

set -euo pipefail

# Resolve pack root: arg 1, else parent of this script's dir.
if [ "${1:-}" != "" ]; then
  PACK_ROOT="$1"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PACK_ROOT="$(dirname "$SCRIPT_DIR")"
fi

REF_DIR="$PACK_ROOT/references"

if [ ! -d "$REF_DIR" ]; then
  echo "X references/ not found under $PACK_ROOT" >&2
  exit 1
fi

ALLOWED='deterministic|semi-deterministic|non-deterministic'
FAIL=0

for f in "$REF_DIR"/*.md; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"

  # Rule headings like "### ING4: ..." or "### STR2: ..." (letters + digit, then colon).
  rule_count=$(grep -cE '^### [A-Z]+[0-9]+:' "$f" || true)
  det_count=$(grep -cE '^\*\*determinismLevel\*\*:' "$f" || true)

  if [ "$rule_count" -ne "$det_count" ]; then
    echo "X $base: $rule_count rule headings but $det_count determinismLevel lines (must match)" >&2
    FAIL=1
  fi

  # Every determinismLevel value must be in the allowed vocabulary.
  bad_det=$(grep -E '^\*\*determinismLevel\*\*:' "$f" \
            | grep -vE "\*\*determinismLevel\*\*: ($ALLOWED)" || true)
  if [ -n "$bad_det" ]; then
    echo "X $base: determinismLevel value(s) outside {$ALLOWED}:" >&2
    echo "$bad_det" | sed 's/^/    /' >&2
    FAIL=1
  fi

  # Every "> Source:" line must carry a URL or a findings.md citation (no orphan claims).
  orphan=$(grep -E '^> Source:' "$f" | grep -vE 'http|findings\.md' || true)
  if [ -n "$orphan" ]; then
    echo "X $base: depth claim(s) with no source URL or findings.md citation:" >&2
    echo "$orphan" | sed 's/^/    /' >&2
    FAIL=1
  fi
done

if [ "$FAIL" -eq 0 ]; then
  echo "OK: all rules carry a determinismLevel; all depth claims carry a source."
  exit 0
fi

echo "FAIL: determinism-lint found violations above." >&2
exit 1
