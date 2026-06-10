#!/usr/bin/env bash
# friction-status-check.sh — Advisory Friction Status SMOKE ALARM.
#
# Scans completion reports for contradictory or missing Friction Status evidence:
#   1. Gate 3 PASS but Friction Status has an unresolved BLOCKED row.
#   2. Gate 3 PASS but Friction Status section is missing entirely.
#   3. gate3_verdict: pass in frontmatter but prose/checklist still says pending.
#
# Usage:
#   friction-status-check.sh                          # scan active COMPLETION-*.md
#   friction-status-check.sh <report.md> [report2.md] # scan explicit files
#
# Exit:
#   0 — no warnings (RESULT: clean)
#   1 — warnings detected (RESULT: WARNINGS DETECTED (advisory))
#
# -----------------------------------------------------------------------
# SAFETY — This script is a SMOKE ALARM, NOT a fire suppressor.
#   - MUST NOT be registered as a PreToolUse / PostToolUse / SessionStart hook.
#   - MUST NOT be added to .claude/settings.json or .codex/hooks.json.
#   - MUST NOT fail-closed or abort on malformed markdown.
#   - advisory exit code only: 0 = clean, 1 = warnings.
#   BSD/macOS-safe shell only. No grep -P, no GNU-only sed -r, no Python/Node.
# -----------------------------------------------------------------------

WARN_COUNT=0

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  printf "  WARN [%s]: %s\n" "$1" "$2"
}

# Resolve repo root from script location
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd -P)"

# Collect files to scan into a temp list (one path per line, handles spaces)
FILE_LIST=$(mktemp 2>/dev/null || echo "/tmp/fsc_files.$$")
trap 'rm -f "$FILE_LIST" 2>/dev/null' EXIT

if [ $# -gt 0 ]; then
  for arg in "$@"; do
    printf '%s\n' "$arg"
  done > "$FILE_LIST"
else
  ACTIVE_DIR="$REPO_ROOT/.tad/active/handoffs"
  if [ -d "$ACTIVE_DIR" ]; then
    find "$ACTIVE_DIR" -maxdepth 1 -name 'COMPLETION-*.md' -type f 2>/dev/null | sort > "$FILE_LIST"
  fi
  if [ ! -s "$FILE_LIST" ]; then
    printf "RESULT: clean — no active completion reports found\n"
    rm -f "$FILE_LIST" 2>/dev/null
    exit 0
  fi
fi

while IFS= read -r file; do
  if [ ! -r "$file" ]; then
    warn "$file" "file not readable or does not exist"
    continue
  fi

  printf "Scanning: %s\n" "$file"

  # --- Detect Gate 3 PASS ---
  gate3_pass=false

  # Check frontmatter gate3_verdict (extract between --- delimiters)
  if awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$file" | grep -q '^gate3_verdict:[[:space:]]*pass' 2>/dev/null; then
    gate3_pass=true
  fi

  # Check prose Gate 3 result line
  if grep -q 'Gate 3 v2.*PASS' "$file" 2>/dev/null; then
    gate3_pass=true
  fi

  # --- Check 1: Friction Status section existence (heading-anchored) ---
  has_friction_section=false
  if grep -q '^#.*Friction Status' "$file" 2>/dev/null; then
    has_friction_section=true
  fi

  if [ "$gate3_pass" = true ] && [ "$has_friction_section" = false ]; then
    warn "$file" "Gate 3 PASS but no Friction Status section found"
  fi

  # --- Check 2: BLOCKED row in Friction Status ---
  if [ "$has_friction_section" = true ]; then
    # Extract Friction Status section: from heading to next heading
    in_section=false
    header_skipped=false
    while IFS= read -r line; do
      case "$line" in
        '#'*Friction\ Status*|'#'*Friction\ Status*)
          in_section=true
          header_skipped=false
          continue
          ;;
      esac
      if [ "$in_section" = true ]; then
        # Stop at next markdown heading
        case "$line" in
          '#'*) break ;;
        esac
        # Check table rows
        case "$line" in
          '|'*)
            # Skip separator rows (contain ---)
            case "$line" in
              *'---'*) continue ;;
            esac
            # Skip the first non-separator row (header row)
            if [ "$header_skipped" = false ]; then
              header_skipped=true
              continue
            fi
            # Extract second cell (Status column)
            status_cell=$(printf '%s' "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3); print $3}')
            if [ "$status_cell" = "BLOCKED" ]; then
              friction_point=$(printf '%s' "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
              if [ "$gate3_pass" = true ]; then
                warn "$file" "Gate 3 PASS but Friction Status has unresolved BLOCKED row: $friction_point"
              else
                warn "$file" "Friction Status has unresolved BLOCKED row: $friction_point"
              fi
            fi
            ;;
        esac
      fi
    done < "$file"
  fi

  # --- Check 3: Verdict/prose/checklist consistency ---
  if [ "$gate3_pass" = true ]; then
    # Check for pending Gate 3 prose
    if grep -Eq 'Gate 3 v2.*pending|Gate 3 v2.*to be filled' "$file" 2>/dev/null; then
      warn "$file" "gate3_verdict says pass but Gate 3 prose still says pending/to-be-filled"
    fi

    # Check for unchecked Gate 3 checklist item
    if grep -q '\- \[ \].*Gate 3 v2' "$file" 2>/dev/null; then
      warn "$file" "gate3_verdict says pass but Gate 3 checklist item is still unchecked"
    fi
  fi

done < "$FILE_LIST"

rm -f "$FILE_LIST" 2>/dev/null

# --- Summary ---
printf "\n"
if [ "$WARN_COUNT" -eq 0 ]; then
  printf "RESULT: clean\n"
  exit 0
else
  printf "RESULT: WARNINGS DETECTED (advisory) — %d warning(s)\n" "$WARN_COUNT"
  exit 1
fi
