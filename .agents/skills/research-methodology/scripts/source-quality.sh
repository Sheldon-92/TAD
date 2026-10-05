#!/usr/bin/env bash
# source-quality.sh — T1 ratio validation from research-state.yaml
#
# INPUT:  path to research-state.yaml (positional arg $1)
# OUTPUT: stdout "PASS {ratio}" or "FAIL {ratio}"
# EXIT:   0 when T1 ratio >= 0.30 (PASS)
#         1 when T1 ratio <  0.30 (FAIL)
#
# Usage: bash source-quality.sh .research/research-state.yaml
#        bash source-quality.sh --help

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat >&2 <<EOF
Usage: $SCRIPT_NAME <path-to-research-state.yaml>
       $SCRIPT_NAME --help

Reads curate.tier1_count, tier2_count, tier3_count from research-state.yaml.
Computes T1 ratio and checks against 0.30 threshold.

Output:
  PASS {ratio}  -- T1 ratio >= 0.30 (exit 0)
  FAIL {ratio}  -- T1 ratio <  0.30 (exit 1)

Example:
  if bash source-quality.sh .research/research-state.yaml; then
    echo "Source quality OK"
  else
    echo "Add more T1 sources"
  fi
EOF
  exit 0
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
fi

STATE_FILE="${1:-}"

if [[ -z "$STATE_FILE" ]]; then
  echo "FAIL 0.00" >&2
  echo "Error: state file path required" >&2
  exit 1
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "FAIL 0.00" >&2
  echo "Error: state file not found: $STATE_FILE" >&2
  exit 1
fi

# Extract tier counts from YAML
# Format: "  tier1_count: 8" (under curate: section)
extract_count() {
  local key="$1"
  local val
  # Scope to curate: section to avoid matching same field names in other sections
  val=$(awk "/^curate:/{flag=1;next} /^[a-z]/{flag=0} flag && /${key}:/{gsub(/.*:[[:space:]]*/,\"\"); print; exit}" "$STATE_FILE" | tr -d ' \t') || true
  if [[ -z "$val" || ! "$val" =~ ^[0-9]+$ ]]; then
    echo "0"
  else
    echo "$val"
  fi
}

tier1=$(extract_count "tier1_count")
tier2=$(extract_count "tier2_count")
tier3=$(extract_count "tier3_count")

total=$((tier1 + tier2 + tier3))

if [[ $total -eq 0 ]]; then
  echo "FAIL 0.00"
  exit 1
fi

# Compute ratio using awk (portable, no python dependency)
# Use awk for floating point arithmetic
ratio=$(awk -v t1="$tier1" -v tot="$total" 'BEGIN { printf "%.2f", t1 / tot }')

# Compare ratio >= 0.30
pass=$(awk -v r="$ratio" 'BEGIN { print (r >= 0.30) ? "1" : "0" }')

if [[ "$pass" == "1" ]]; then
  echo "PASS $ratio"
  exit 0
else
  echo "FAIL $ratio"
  exit 1
fi
