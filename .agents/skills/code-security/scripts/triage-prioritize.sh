#!/usr/bin/env bash
# triage-prioritize.sh — Deterministic vulnerability triage: CVSS + EPSS + KEV + reachability → P0-P3
#
# Ingests a findings file (CSV or JSON) and emits a priority + a CISA BOD 26-04
# risk-based remediation deadline per finding. This is the deterministic part of
# rule V1/V7 — it MUST NOT be punted to the model, because the priority formula and
# the BOD 26-04 tier deadlines are fixed contracts.
#
# Usage:
#   bash scripts/triage-prioritize.sh <findings.csv>
#   bash scripts/triage-prioritize.sh <findings.json>   # requires jq
#
# CSV columns (header required, order-independent):
#   id,cvss,epss,kev,reachable,internet_facing,automatable,control
#     cvss            float 0-10
#     epss            float 0-1 (probability)
#     kev             true|false  (CISA Known Exploited Vulnerabilities)
#     reachable       true|false  (reachability analysis, rule V6)
#     internet_facing true|false  (BOD 26-04 input)
#     automatable     true|false  (BOD 26-04 input)
#     control         none|partial|total  (degree of attacker control; BOD 26-04 input)
#
# JSON: array of objects with the same keys.
#
# Priority formula (rule V1):
#   P0 = KEV OR (cvss>=9.0 AND reachable AND epss>0.5)
#   P1 = (cvss>=7.0 AND reachable) OR (cvss>=9.0 AND NOT reachable)
#   P2 = cvss>=4.0 AND NOT reachable
#   P3 = otherwise
#
# BOD 26-04 deadline (rule V7 — supersedes BOD 22-01 flat 14/60-day):
#   3 days  : kev AND automatable AND internet_facing AND control in {partial,total}
#   14 days : kev AND control=partial AND NOT automatable
#   longer  : not-yet-exploited or not-internet-exposed
#
# Requirements: awk (always); jq only for JSON input.
# Exit: 0 always (this is a reporting tool, not a gate). See verify-pipeline-gates.sh for gating.

set -euo pipefail

FINDINGS="${1:-}"

if [ -z "$FINDINGS" ] || [ ! -f "$FINDINGS" ]; then
  echo "Usage: bash scripts/triage-prioritize.sh <findings.csv|findings.json>" >&2
  exit 2
fi

# ── Normalize JSON → CSV-on-stdin if needed ──────────────────────────────────
emit_rows() {
  case "$FINDINGS" in
    *.json)
      if ! command -v jq >/dev/null 2>&1; then
        echo "✗ jq not found (needed for JSON input). Install: brew install jq / apt-get install jq" >&2
        exit 2
      fi
      jq -r '.[] | [
        (.id // "?"),
        (.cvss // 0),
        (.epss // 0),
        (.kev // false),
        (.reachable // false),
        (.internet_facing // false),
        (.automatable // false),
        (.control // "none")
      ] | @tsv' "$FINDINGS"
      ;;
    *)
      # CSV: resolve columns by header name (order-independent), emit TSV in canonical order.
      awk -F',' '
        NR==1 {
          for (i=1;i<=NF;i++){ gsub(/^[ \t]+|[ \t]+$/,"",$i); h[$i]=i }
          next
        }
        {
          for (i=1;i<=NF;i++){ gsub(/^[ \t]+|[ \t]+$/,"",$i) }
          printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
            (h["id"]?$h["id"]:"?"),
            (h["cvss"]?$h["cvss"]:0),
            (h["epss"]?$h["epss"]:0),
            (h["kev"]?$h["kev"]:"false"),
            (h["reachable"]?$h["reachable"]:"false"),
            (h["internet_facing"]?$h["internet_facing"]:"false"),
            (h["automatable"]?$h["automatable"]:"false"),
            (h["control"]?$h["control"]:"none")
        }
      ' "$FINDINGS"
      ;;
  esac
}

printf '%-16s %-5s %-9s %-4s %-9s %-4s %s\n' "ID" "CVSS" "EPSS%ile" "KEV" "REACH" "PRIO" "BOD 26-04 DEADLINE"
printf '%s\n' "-------------------------------------------------------------------------------"

emit_rows | awk -F'\t' '
  function isTrue(v){ return (v=="true"||v=="True"||v=="TRUE"||v=="1"||v=="yes") }
  # crude percentile band for display: EPSS 0.10 ~ 88th percentile
  function pctBand(e){
    if (e>=0.10) return "≥88th"
    if (e>=0.01) return "<88th"
    return "low"
  }
  {
    id=$1; cvss=$2+0; epss=$3+0;
    kev=isTrue($4); reach=isTrue($5); inet=isTrue($6); auto=isTrue($7); ctrl=$8;

    # ── Priority (rule V1) ──
    if (kev || (cvss>=9.0 && reach && epss>0.5))            prio="P0"
    else if ((cvss>=7.0 && reach) || (cvss>=9.0 && !reach)) prio="P1"
    else if (cvss>=4.0 && !reach)                            prio="P2"
    else                                                     prio="P3"

    # ── BOD 26-04 deadline (rule V7) ──
    partialOrTotal=(ctrl=="partial"||ctrl=="total")
    if (kev && auto && inet && partialOrTotal) {
      dl="3 days (forensic triage if total control)"
    } else if (kev && ctrl=="partial" && !auto) {
      dl="14 days"
    } else if (kev) {
      dl="risk-band tier (per BOD 26-04)"
    } else {
      dl="normal patch cycle (not actively exploited)"
    }

    printf "%-16s %-5s %-9s %-4s %-9s %-4s %s\n", id, cvss, pctBand(epss), (kev?"yes":"no"), (reach?"yes":"no"), prio, dl
  }
'

echo ""
echo "Priority formula: rule V1 | Deadlines: CISA BOD 26-04 (supersedes BOD 22-01 flat 14/60-day)."
echo "Note: EPSS shown as percentile band (0.10 ≈ 88th pct). Present prob% (Nth pct) in reports."
