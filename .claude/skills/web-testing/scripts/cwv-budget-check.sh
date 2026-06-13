#!/usr/bin/env bash
# cwv-budget-check.sh — Parse a Lighthouse JSON report and assert Core Web Vitals budgets.
#
# Thresholds (Rule P1, web.dev official — UNCHANGED in 2026, evaluated at the 75th pct of
# CrUX field data; reject the low-authority "LCP 2.0s" claim):
#   LCP <= 2500 ms   (Largest Contentful Paint)
#   INP <= 200  ms   (Interaction to Next Paint; lab reports fall back to TBT proxy)
#   CLS <= 0.1       (Cumulative Layout Shift, unitless)
#
# Usage: bash scripts/cwv-budget-check.sh <lighthouse-report.json>
#
# Exit 0: all three CWV within budget
# Exit 1: one or more budgets breached
# Exit 2: bad usage / file missing / unparseable

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: bash scripts/cwv-budget-check.sh <lighthouse-report.json>"
  echo "  Asserts LCP<=2500ms, INP<=200ms, CLS<=0.1 (Rule P1). Exit non-zero on breach."
  echo "  Generate input with: npx lighthouse URL --output=json --output-path=report.json"
  exit 0
fi

REPORT="${1:-}"
if [[ -z "$REPORT" || ! -f "$REPORT" ]]; then
  echo "✗ Lighthouse JSON report not found." >&2
  echo "  Generate with: npx lighthouse URL --output=json --output-path=report.json" >&2
  exit 2
fi

# Prefer jq; fall back to node. Both ship wherever Lighthouse runs.
if command -v jq >/dev/null 2>&1; then
  LCP=$(jq -r '.audits["largest-contentful-paint"].numericValue // empty' "$REPORT")
  CLS=$(jq -r '.audits["cumulative-layout-shift"].numericValue // empty' "$REPORT")
  # Real INP only exists in field reports; lab uses TBT as the documented proxy.
  INP=$(jq -r '(.audits["interaction-to-next-paint"].numericValue) // (.audits["total-blocking-time"].numericValue) // empty' "$REPORT")
  INP_LABEL=$(jq -r 'if .audits["interaction-to-next-paint"].numericValue then "INP" else "TBT (INP lab proxy)" end' "$REPORT")
elif command -v node >/dev/null 2>&1; then
  read -r LCP INP CLS INP_LABEL < <(node -e '
    const r = JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).audits;
    const lcp = r["largest-contentful-paint"]?.numericValue ?? "";
    const inpA = r["interaction-to-next-paint"]?.numericValue;
    const inp = inpA ?? r["total-blocking-time"]?.numericValue ?? "";
    const cls = r["cumulative-layout-shift"]?.numericValue ?? "";
    const label = inpA !== undefined ? "INP" : "TBT_(INP_lab_proxy)";
    console.log([lcp, inp, cls, label].join(" "));
  ' "$REPORT")
  INP_LABEL="${INP_LABEL//_/ }"
else
  echo "✗ Neither jq nor node available to parse the report." >&2
  exit 2
fi

if [[ -z "$LCP" || -z "$CLS" || -z "$INP" ]]; then
  echo "✗ Could not extract CWV metrics — is this a Lighthouse JSON report?" >&2
  exit 2
fi

# awk for float comparison (portable across BSD/GNU; bash has no float math).
PASS=$(awk -v lcp="$LCP" -v inp="$INP" -v cls="$CLS" \
  'BEGIN { print (lcp<=2500 && inp<=200 && cls<=0.1) ? 1 : 0 }')

LCP_ICON=$(awk -v v="$LCP" 'BEGIN{print (v<=2500)?"PASS":"FAIL"}')
INP_ICON=$(awk -v v="$INP" 'BEGIN{print (v<=200)?"PASS":"FAIL"}')
CLS_ICON=$(awk -v v="$CLS" 'BEGIN{print (v<=0.1)?"PASS":"FAIL"}')
LCP_S=$(awk -v v="$LCP" 'BEGIN{printf "%.2f", v/1000}')

echo "=== Core Web Vitals Budget Check (Rule P1) ==="
echo "  [$LCP_ICON] LCP: ${LCP_S}s        (budget <=2.5s)"
echo "  [$INP_ICON] $INP_LABEL: ${INP}ms  (budget <=200ms)"
echo "  [$CLS_ICON] CLS: $CLS             (budget <=0.1)"
echo ""

if [[ "$PASS" == "1" ]]; then
  echo "RESULT: PASS — all CWV within budget (75th-pct field target)."
  exit 0
else
  echo "RESULT: FAIL — one or more CWV exceed budget. INP is the most-failed CWV (~43% of origins fail)."
  exit 1
fi
