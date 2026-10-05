#!/usr/bin/env bash
# saturation-check.sh — Compute saturation status from research-state.yaml
#
# INPUT:  path to research-state.yaml (positional arg $1)
# OUTPUT: stdout one of:
#   SATURATED {latest_count}   — rate=0 for >=2 rounds AND total>=3
#   DIMINISHING {latest_count} — rate<=1 for >=3 rounds (secondary signal)
#   CONTINUE {latest_count}    — all other cases
# EXIT:   always 0 (status communicated via stdout, not exit code)
#
# Usage: bash saturation-check.sh .research/research-state.yaml
#        bash saturation-check.sh --help

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat >&2 <<EOF
Usage: $SCRIPT_NAME <path-to-research-state.yaml>
       $SCRIPT_NAME --help

Reads analyze.new_findings_per_round from research-state.yaml and outputs
saturation status. Exit code is always 0; status is in stdout.

Output formats:
  SATURATED {N}   -- rate=0 for >=2 consecutive rounds AND total findings>=3
  DIMINISHING {N} -- rate<=1 for >=3 consecutive rounds
  CONTINUE {N}    -- continue researching

Example:
  result=\$(bash saturation-check.sh .research/research-state.yaml)
  echo "\$result"  # "CONTINUE 6" or "SATURATED 0" or "DIMINISHING 1"
EOF
  exit 0
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
fi

STATE_FILE="${1:-}"

if [[ -z "$STATE_FILE" ]]; then
  echo "CONTINUE 0"
  exit 0
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "CONTINUE 0"
  exit 0
fi

# Extract the new_findings_per_round array from YAML
# Format in state file: new_findings_per_round: [12, 8, 6, 4, 1]
# or multiline:
#   new_findings_per_round:
#   - 12
#   - 8

# Try inline format first
inline=$(grep -E '^[[:space:]]+new_findings_per_round:[[:space:]]*\[' "$STATE_FILE" 2>/dev/null || true)

if [[ -n "$inline" ]]; then
  # Extract content between [ and ]
  array_str=$(echo "$inline" | sed 's/.*\[\(.*\)\].*/\1/')
  # Split by comma and trim spaces
  IFS=',' read -ra rounds <<< "$array_str"
else
  # Try multiline format — collect lines after the key until next key
  in_array=false
  rounds=()
  while IFS= read -r line; do
    if echo "$line" | grep -qE '^[[:space:]]+new_findings_per_round:'; then
      in_array=true
      continue
    fi
    if $in_array; then
      # Line is a list item: "  - N" or "    - N"
      if echo "$line" | grep -qE '^[[:space:]]+-[[:space:]]+[0-9]+'; then
        val=$(echo "$line" | sed 's/.*-[[:space:]]*//')
        rounds+=("$val")
      elif echo "$line" | grep -qE '^[[:space:]]+[a-z_]+:'; then
        # New key — end of array
        break
      fi
    fi
  done < "$STATE_FILE"
fi

# Count total rounds
total_rounds=${#rounds[@]}
latest_count=0

if [[ $total_rounds -eq 0 ]]; then
  echo "CONTINUE 0"
  exit 0
fi

# Get latest count (last element)
latest_count="${rounds[$((total_rounds - 1))]}"
# Trim whitespace
latest_count=$(echo "$latest_count" | tr -d ' \t')

# Compute total findings
total_findings=0
for r in "${rounds[@]}"; do
  r=$(echo "$r" | tr -d ' \t')
  if [[ "$r" =~ ^[0-9]+$ ]]; then
    total_findings=$((total_findings + r))
  fi
done

# ---- SATURATION CHECK ----
# Condition: rate=0 for >=2 consecutive rounds AND total>=3
if [[ $total_rounds -ge 2 && $total_findings -ge 3 ]]; then
  last_two_zero=true
  for i in $((total_rounds - 1)) $((total_rounds - 2)); do
    val="${rounds[$i]}"
    val=$(echo "$val" | tr -d ' \t')
    if [[ "$val" != "0" ]]; then
      last_two_zero=false
      break
    fi
  done
  if $last_two_zero; then
    echo "SATURATED $latest_count"
    exit 0
  fi
fi

# ---- DIMINISHING CHECK ----
# Condition: rate<=1 for >=3 consecutive rounds
if [[ $total_rounds -ge 3 ]]; then
  last_three_low=true
  for i in $((total_rounds - 1)) $((total_rounds - 2)) $((total_rounds - 3)); do
    val="${rounds[$i]}"
    val=$(echo "$val" | tr -d ' \t')
    if [[ ! "$val" =~ ^[0-9]+$ ]] || [[ "$val" -gt 1 ]]; then
      last_three_low=false
      break
    fi
  done
  if $last_three_low; then
    echo "DIMINISHING $latest_count"
    exit 0
  fi
fi

# ---- DEFAULT: CONTINUE ----
echo "CONTINUE $latest_count"
exit 0
