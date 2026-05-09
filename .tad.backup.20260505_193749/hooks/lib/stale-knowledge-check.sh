#!/usr/bin/env bash
# stale-knowledge-check.sh — Phase 2 P2.1 (2026-04-24)
#
# Smoke-alarm CLI: detects project-knowledge entries whose `Grounded in` files
# have been modified after the entry's baseline date (max of entry_date and
# any optional Revalidated date). Always advisory — never blocks Claude.
# Anti-Epic-1 (BA-P0-1): plain CLI tool, NOT registered in settings.json,
# NOT a PreToolUse / UserPromptSubmit hook.
#
# Precedent: toy 2026-04-21 OPRO incident — entry from 04-07 cited "Qwen Plus",
# but underlying config.py migrated to qwen3-omni-flash on 04-11~14. No alert.
#
# Usage:
#   stale-knowledge-check.sh                 # check all *.md (excl README)
#   stale-knowledge-check.sh <file.md>       # check one file
#   stale-knowledge-check.sh --json          # JSONL output for Alex step0_5
#   stale-knowledge-check.sh --help          # usage
# Exit: 0 always (drift in stdout). 1 internal error (missing dep / not in git).
# Symlinks: `stat -L` follows them (target's mtime is what matters).
# BSD-portable: stat -f, date -j -f, no GNU-isms.

set -uo pipefail

SCRIPT_VERSION="1.0.0"
PROJECT_KNOWLEDGE_DIR=".tad/project-knowledge"
GRACE_SECONDS=86400  # +1 day buffer per BA-P0-2 (entry-night vs file-morning edits)
JSON_MODE=false

# ─── Output helpers ─────────────────────────────────────────────────────
_y=""; _r=""; _g=""; _x=""
[ -z "${NO_COLOR:-}" ] && [ -t 2 ] && { _y=$'\033[33m'; _r=$'\033[31m'; _g=$'\033[32m'; _x=$'\033[0m'; }

_usage() {
  cat <<EOF
stale-knowledge-check.sh v${SCRIPT_VERSION} — TAD project-knowledge staleness detector

Usage:
  stale-knowledge-check.sh                 Check all .tad/project-knowledge/*.md
  stale-knowledge-check.sh <file.md>       Check one knowledge file
  stale-knowledge-check.sh --json          JSONL output
  stale-knowledge-check.sh --help          This help

Exit: 0 always (drift count is in stdout, not exit code). 1 internal error.

JSONL schema:
  {"file":...,"title":...,"path":...,"status":<enum>,"days_delta":<int|null>,"msg":...}
  status: STALE|INFO|WARN|OK|ERROR
EOF
}

_emit() {
  local file="$1" title="$2" path="$3" status="$4" days_delta="$5" msg="$6"
  if [ "$JSON_MODE" = "true" ]; then
    if [ "$days_delta" = "null" ] || [ -z "$days_delta" ]; then
      jq -nc --arg f "$file" --arg t "$title" --arg p "$path" \
             --arg s "$status" --arg m "$msg" \
        '{file:$f,title:$t,path:$p,status:$s,days_delta:null,msg:$m}'
    else
      jq -nc --arg f "$file" --arg t "$title" --arg p "$path" \
             --arg s "$status" --arg m "$msg" --argjson d "$days_delta" \
        '{file:$f,title:$t,path:$p,status:$s,days_delta:$d,msg:$m}'
    fi
  else
    case "$status" in
      STALE) printf '%s[STALE]%s %s — %s\n' "$_r" "$_x" "$title" "$msg" ;;
      WARN)  printf '%s[WARN ]%s %s — %s\n' "$_y" "$_x" "$title" "$msg" ;;
      ERROR) printf '%s[ERROR]%s %s — %s\n' "$_r" "$_x" "$title" "$msg" ;;
      OK)    printf '%s[ OK  ]%s %s\n' "$_g" "$_x" "$title" ;;
      INFO)  printf '[INFO ] %s — %s\n' "$title" "$msg" ;;
    esac
  fi
}

# ─── Pre-flight ─────────────────────────────────────────────────────────
command -v jq >/dev/null 2>&1 || { echo 'stale-knowledge-check.sh: jq required' >&2; exit 1; }

if ! REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo 'stale-knowledge-check.sh: not inside a git repo' >&2; exit 1
fi
cd "$REPO_ROOT" || { echo "cannot cd to $REPO_ROOT" >&2; exit 1; }

# Portability shims (detect once)
if stat --version >/dev/null 2>&1; then
  _file_mtime() { stat -c '%Y' --dereference -- "$1" 2>/dev/null || echo 0; }
else
  _file_mtime() { stat -f '%m' -L -- "$1" 2>/dev/null || echo 0; }
fi
# Always normalize to midnight 00:00:00 — BSD date -j -f with partial formats
# inherits the current wall clock for missing fields, which leaks into deltas.
if date -j -f "%Y-%m-%d %H:%M:%S" "2024-01-01 00:00:00" "+%s" >/dev/null 2>&1; then
  _date_to_ts() { date -j -f "%Y-%m-%d %H:%M:%S" "$1 00:00:00" "+%s" 2>/dev/null || echo 0; }
else
  _date_to_ts() { date -d "$1 00:00:00" "+%s" 2>/dev/null || echo 0; }
fi

# ─── Argparse ───────────────────────────────────────────────────────────
TARGET_FILE=""
for arg in "$@"; do
  case "$arg" in
    --help|-h|help) _usage; exit 0 ;;
    --json) JSON_MODE=true ;;
    -*) echo "unknown option: $arg" >&2; _usage >&2; exit 1 ;;
    *)
      [ -n "$TARGET_FILE" ] && { echo "only one file argument allowed" >&2; exit 1; }
      TARGET_FILE="$arg"
      ;;
  esac
done

# ─── File list ──────────────────────────────────────────────────────────
declare -a FILES=()
if [ -n "$TARGET_FILE" ]; then
  [ -r "$TARGET_FILE" ] || { echo "file not readable: $TARGET_FILE" >&2; exit 1; }
  FILES=("$TARGET_FILE")
else
  [ -d "$PROJECT_KNOWLEDGE_DIR" ] || { echo "$PROJECT_KNOWLEDGE_DIR/ not found" >&2; exit 1; }
  while IFS= read -r f; do
    [ -n "$f" ] && FILES+=("$f")
  done < <(find "$PROJECT_KNOWLEDGE_DIR" -maxdepth 1 -type f -name '*.md' \
           ! -name 'README.md' 2>/dev/null | sort)
fi

# ─── Path validation ────────────────────────────────────────────────────
# Stdout: "STATUS<TAB>STRIPPED_PATH"
#   STATUS ∈ NEW_MARKER | OK | MISSING | MALFORMED:<reason>
# Note: function runs in a subshell when called via $(...), so we return
# both the status and the anchor-stripped path via stdout instead of relying
# on global side effects (which don't survive the subshell).
_validate_path() {
  local p="$1"
  local stripped=""

  # New-marker exception (only pattern allowed to embed spaces)
  if printf '%s' "$p" | grep -qE '\(new — will be created\)[[:space:]]*$'; then
    printf 'NEW_MARKER\t\n'; return
  fi

  # Reject illegal chars
  printf '%s' "$p" | grep -qE ' ' && { printf 'MALFORMED:contains_space\t\n'; return; }
  printf '%s' "$p" | grep -qE ',' && { printf 'MALFORMED:contains_comma\t\n'; return; }
  local cc; cc=$(printf '%s' "$p" | tr -cd ':' | wc -c | tr -d ' ')
  [ "$cc" -ge 2 ] && { printf 'MALFORMED:multi_colon\t\n'; return; }

  if [ "$cc" = "1" ]; then
    local before="${p%:*}" after="${p##*:}"
    if [ -z "$before" ] || [ -z "$after" ]; then
      printf 'MALFORMED:empty_path_or_anchor\t\n'; return
    fi
    if printf '%s' "$after" | grep -qE '^[0-9]+-[0-9]+$'; then
      printf 'MALFORMED:line_range\t\n'; return
    fi
    if ! printf '%s' "$after" | grep -qE '^([A-Za-z_][A-Za-z0-9_]*|[0-9]+)$'; then
      printf 'MALFORMED:invalid_anchor\t\n'; return
    fi
    stripped="$before"
  else
    stripped="$p"
  fi

  if [ ! -e "$stripped" ]; then
    printf 'MISSING\t%s\n' "$stripped"; return
  fi
  printf 'OK\t%s\n' "$stripped"
}

# ─── Process one knowledge file ─────────────────────────────────────────
_process_file() {
  local kfile="$1"

  # Parse entries via awk: emit TITLE\tDATE\tGROUNDED\tREVALIDATED per entry.
  # Header anchor: trailing ` - YYYY-MM-DD` (LAST occurrence — titles may contain `-`).
  # Allow optional ` (consolidated)` suffix.
  local entries
  entries=$(awk '
    function flush() {
      if (T != "") printf "%s\t%s\t%s\t%s\n", T, D, G, R
      T=""; D=""; G=""; R=""
    }
    /^### / {
      flush()
      h = substr($0, 5)
      sub(/[[:space:]]*\(consolidated\)[[:space:]]*$/, "", h)
      if (match(h, /[[:space:]]-[[:space:]][0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) > 0) {
        D = substr(h, RSTART + 3); T = substr(h, 1, RSTART - 1)
      }
      next
    }
    /^[[:space:]]*-[[:space:]]+\*\*Grounded in\*\*:/ {
      if (T != "") {
        line = $0
        sub(/^[[:space:]]*-[[:space:]]+\*\*Grounded in\*\*:[[:space:]]*/, "", line)
        sub(/[[:space:]]+$/, "", line)
        G = line
      }
      next
    }
    /^[[:space:]]*-[[:space:]]+\*\*Revalidated\*\*:/ {
      if (T != "") {
        line = $0
        sub(/^[[:space:]]*-[[:space:]]+\*\*Revalidated\*\*:[[:space:]]*/, "", line)
        sub(/[[:space:]]+$/, "", line)
        if (line ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) R = line
      }
      next
    }
    END { flush() }
  ' "$kfile")

  while IFS=$'\t' read -r title entry_date grounded revalidated; do
    [ -z "$title" ] || [ -z "$entry_date" ] && continue

    # baseline = max(entry_ts, revalidated_ts)
    local entry_ts baseline_ts baseline_date
    entry_ts=$(_date_to_ts "$entry_date")
    baseline_ts="$entry_ts"; baseline_date="$entry_date"
    if [ -n "$revalidated" ]; then
      local rts; rts=$(_date_to_ts "$revalidated")
      if [ "$rts" -gt "$entry_ts" ] 2>/dev/null; then
        baseline_ts="$rts"; baseline_date="$revalidated"
      fi
    fi

    # Legacy entry — INFO and skip
    if [ -z "$grounded" ]; then
      _emit "$kfile" "$title" "" "INFO" "null" "no Grounded in declared (legacy entry, skip)"
      continue
    fi

    # Split paths on `, ` (comma+space) using perl for safety
    local paths_blob
    paths_blob=$(printf '%s' "$grounded" | perl -e '
      my $s = do { local $/; <STDIN> }; chomp $s;
      print join("\n", split /, /, $s), "\n";
    ' 2>/dev/null)

    while IFS= read -r raw_path; do
      raw_path=$(printf '%s' "$raw_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      [ -z "$raw_path" ] && continue

      local v_line v_status v_stripped
      v_line=$(_validate_path "$raw_path")
      v_status="${v_line%%$'\t'*}"
      v_stripped="${v_line#*$'\t'}"

      case "$v_status" in
        NEW_MARKER)
          _emit "$kfile" "$title" "$raw_path" "INFO" "null" \
            "'$raw_path' marked as new (will be created)"
          ;;
        MALFORMED:*)
          _emit "$kfile" "$title" "$raw_path" "WARN" "null" \
            "malformed path '$raw_path' (${v_status#MALFORMED:})"
          ;;
        MISSING)
          _emit "$kfile" "$title" "$raw_path" "WARN" "null" \
            "Grounded in path '$raw_path' missing on disk"
          ;;
        OK)
          local m
          m=$(_file_mtime "$v_stripped")
          if [ "$m" -eq 0 ] 2>/dev/null; then
            _emit "$kfile" "$title" "$raw_path" "ERROR" "null" \
              "could not stat '$v_stripped'"
            continue
          fi
          if [ "$m" -gt $((baseline_ts + GRACE_SECONDS)) ] 2>/dev/null; then
            local dd=$(( (m - baseline_ts) / 86400 ))
            _emit "$kfile" "$title" "$raw_path" "STALE" "$dd" \
              "'$raw_path' mtime is $dd days newer than baseline $baseline_date"
          else
            _emit "$kfile" "$title" "$raw_path" "OK" "null" "fresh"
          fi
          ;;
      esac
    done <<< "$paths_blob"
  done <<< "$entries"
}

# ─── Main ───────────────────────────────────────────────────────────────
for f in "${FILES[@]}"; do
  _process_file "$f" \
    || _emit "$f" "*" "" "ERROR" "null" "internal processing error for $f"
done
exit 0
