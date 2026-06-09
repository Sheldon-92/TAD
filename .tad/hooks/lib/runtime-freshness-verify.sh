#!/usr/bin/env bash
# runtime-freshness-verify.sh — Runtime compatibility ledger freshness gate.
# Exit 0 = PASS/WARN; Exit 1 = freshness BLOCK; Exit 2 = wiring/malformed BLOCK.
# BSD/macOS safe: no GNU-only date, no grep -P, no associative arrays.
set -euo pipefail

REPO="${1:-.}"
TODAY="${2:-$(date +%Y-%m-%d)}"

COMPAT_DIR="$REPO/.tad/runtime-compat"
CODEX_LEDGER="$COMPAT_DIR/codex.md"
CLAUDE_LEDGER="$COMPAT_DIR/claude-code.md"

SAFETY_SURFACES="hooks ask_user_question_hook sandbox_approval_permissions trace_evidence_capture subagents_custom_agents context_compaction"

blocks=0
warns=0
pass=0
total=0

if ! echo "$TODAY" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  echo "ERROR: invalid date format '$TODAY' (expected YYYY-MM-DD)" >&2
  echo "GATE: runtime-freshness exit=2"
  exit 2
fi

if [ ! -f "$CODEX_LEDGER" ]; then
  echo "ERROR: missing ledger $CODEX_LEDGER" >&2
  echo "GATE: runtime-freshness exit=2"
  exit 2
fi
if [ ! -f "$CLAUDE_LEDGER" ]; then
  echo "ERROR: missing ledger $CLAUDE_LEDGER" >&2
  echo "GATE: runtime-freshness exit=2"
  exit 2
fi

date_to_epoch() {
  local d="$1"
  # macOS/BSD: date -j -f; Linux/GNU: date -d
  date -j -f "%Y-%m-%d" "$d" "+%s" 2>/dev/null && return 0
  date -d "$d" "+%s" 2>/dev/null && return 0
  return 1
}

days_between() {
  local d1="$1" d2="$2"
  local s1 s2
  s1=$(date_to_epoch "$d1") || { echo "ERROR: cannot parse date '$d1'" >&2; echo "GATE: runtime-freshness exit=2"; exit 2; }
  s2=$(date_to_epoch "$d2") || { echo "ERROR: cannot parse date '$d2'" >&2; echo "GATE: runtime-freshness exit=2"; exit 2; }
  echo $(( (s2 - s1) / 86400 ))
}

is_safety_surface() {
  local s="$1"
  for sf in $SAFETY_SURFACES; do
    if [ "$s" = "$sf" ]; then return 0; fi
  done
  return 1
}

check_ledger() {
  local platform="$1" ledger="$2"
  local in_table=0 header_seen=0

  while IFS= read -r line; do
    if echo "$line" | grep -qE '^\|[[:space:]]*surface[[:space:]]*\|.*owner'; then
      header_seen=1
      continue
    fi
    if [ "$header_seen" -eq 1 ] && echo "$line" | grep -qE '^\|[[:space:]]*[-]+'; then
      in_table=1
      continue
    fi
    if [ "$in_table" -eq 0 ]; then continue; fi
    if ! echo "$line" | grep -qE '^\|'; then break; fi

    total=$((total + 1))

    local surface vol last_ver next_rev status
    surface=$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$2); print $2}')
    vol=$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$8); print $8}')
    last_ver=$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$7); print $7}')
    next_rev=$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$9); print $9}')
    status=$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$12); print $12}')

    if [ -z "$surface" ] || [ -z "$vol" ] || [ -z "$last_ver" ] || [ -z "$status" ]; then
      echo "BLOCK [$platform] $surface: missing required field (surface/volatility/last_verified/status)" >&2
      echo "GATE: runtime-freshness exit=2"
      exit 2
    fi

    if ! echo "$last_ver" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
      echo "BLOCK [$platform] $surface: invalid last_verified date '$last_ver'" >&2
      echo "GATE: runtime-freshness exit=2"
      exit 2
    fi

    if [ "$status" = "unknown_current_behavior" ] && is_safety_surface "$surface"; then
      echo "BLOCK [$platform] $surface: unknown_current_behavior on safety/quality surface"
      blocks=$((blocks + 1))
      continue
    fi

    local age entry_result="pass"
    age=$(days_between "$last_ver" "$TODAY")

    case "$vol" in
      high)
        if [ "$age" -gt 30 ]; then
          echo "BLOCK [$platform] $surface: high-volatility stale ($age days > 30)"
          entry_result="block"
        fi
        ;;
      medium)
        if [ "$age" -gt 60 ]; then
          echo "WARN  [$platform] $surface: medium-volatility stale ($age days > 60)"
          entry_result="warn"
        fi
        ;;
      low)
        if [ "$age" -gt 180 ]; then
          echo "WARN  [$platform] $surface: low-volatility stale ($age days > 180)"
          entry_result="warn"
        fi
        ;;
      *)
        echo "BLOCK [$platform] $surface: invalid volatility '$vol' (expected high/medium/low)" >&2
        echo "GATE: runtime-freshness exit=2"
        exit 2
        ;;
    esac

    if [ -n "$next_rev" ] && echo "$next_rev" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
      local review_age
      review_age=$(days_between "$next_rev" "$TODAY")
      if [ "$review_age" -gt 0 ]; then
        case "$vol" in
          high)
            echo "BLOCK [$platform] $surface: next_review overdue ($next_rev < $TODAY, high-volatility)"
            entry_result="block"
            ;;
          *)
            if [ "$entry_result" != "block" ]; then
              echo "WARN  [$platform] $surface: next_review overdue ($next_rev < $TODAY)"
              entry_result="warn"
            fi
            ;;
        esac
      fi
    fi

    case "$entry_result" in
      block) blocks=$((blocks + 1)) ;;
      warn)  warns=$((warns + 1)) ;;
      pass)  pass=$((pass + 1)) ;;
    esac

  done < "$ledger"
}

echo "========================================="
echo "RUNTIME FRESHNESS VERIFY"
echo "  Repo:  $REPO"
echo "  Today: $TODAY"
echo "========================================="

check_ledger "codex" "$CODEX_LEDGER"
check_ledger "claude_code" "$CLAUDE_LEDGER"

echo "-----------------------------------------"
echo "Total: $total entries | PASS: $pass | WARN: $warns | BLOCK: $blocks"

if [ "$blocks" -gt 0 ]; then
  echo "VERDICT: runtime freshness BLOCK"
  echo "GATE: runtime-freshness exit=1"
  exit 1
elif [ "$warns" -gt 0 ]; then
  echo "VERDICT: runtime freshness WARN"
  exit 0
else
  echo "VERDICT: runtime freshness PASS"
  exit 0
fi
