#!/usr/bin/env bash
set -euo pipefail

# knowledge-blame.sh — Query provenance of a TAD knowledge or protocol rule
# Usage: knowledge-blame.sh <file> [--line N | --search "pattern"]
# Output: structured RULE/COMMIT/DATE/AUTHOR/MESSAGE fields (no context — use Read tool)

[ "${1:-}" = "--help" ] && { echo "Usage: knowledge-blame.sh <file> [--line N | --search \"pattern\"]"; exit 0; }
FILE="${1:-}"; shift || { echo "Usage: knowledge-blame.sh <file> [--line N | --search pattern]"; exit 1; }

# ── P0-4 fix: Path normalization (absolute → relative, reject traversal) ──
case "$FILE" in *..*) echo "ERROR: path traversal not allowed"; exit 2 ;; esac
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "ERROR: not a git repository"; exit 1; }
case "$FILE" in
  /*) FILE="${FILE#"$REPO_ROOT/"}" ;;
esac

# ── Scope guard: project-knowledge + SKILL.md + hooks/lib (ARCH P1-4 widened) ──
case "$FILE" in
  .tad/project-knowledge/*|.claude/skills/*/SKILL.md|.tad/hooks/lib/*.sh) ;;
  *) echo "ERROR: out of scope. Allowed: .tad/project-knowledge/, .claude/skills/*/SKILL.md, .tad/hooks/lib/*.sh"; exit 2 ;;
esac

[ -L "$FILE" ] && { echo "ERROR: symlinks not supported"; exit 2; }
[ -f "$FILE" ] || { echo "ERROR: file not found: $FILE"; exit 1; }

MODE="summary"
LINE_NUM=""
PATTERN=""

while [ $# -gt 0 ]; do
  case "$1" in
    --line) [ $# -ge 2 ] || { echo "ERROR: --line requires a value"; exit 1; }; LINE_NUM="$2"; MODE="line"; shift 2 ;;
    --search) [ $# -ge 2 ] || { echo "ERROR: --search requires a value"; exit 1; }; PATTERN="$2"; MODE="search"; shift 2 ;;
    --help) echo "Usage: knowledge-blame.sh <file> [--line N | --search \"pattern\"]"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── P1-5 fix: validate --line is a positive integer ──
if [ "$MODE" = "line" ]; then
  [[ "$LINE_NUM" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --line requires a positive integer, got: $LINE_NUM"; exit 1; }
fi

# ── CR P0-1 fix: grep -Fn (fixed-string) + || true (no crash on no-match) ──
if [ "$MODE" = "search" ]; then
  LINE_NUM=$(grep -Fn "$PATTERN" "$FILE" | head -1 | cut -d: -f1) || true
  [ -z "$LINE_NUM" ] && { echo "PATTERN_NOT_FOUND: $PATTERN"; exit 0; }
fi

# ── ARCH P1-3 fix: summary mode capped at 5 lines (not 20) ──
if [ "$MODE" = "summary" ]; then
  git log -5 --format='%ad %an: %s' --date=short -- "$FILE"
  exit 0
fi

# ── CR P0-2 fix: validate line number against file length ──
TOTAL_LINES=$(wc -l < "$FILE" | tr -d ' ')
if [ "$LINE_NUM" -gt "$TOTAL_LINES" ]; then
  echo "ERROR: line $LINE_NUM exceeds file length ($TOTAL_LINES lines)"
  exit 0
fi

# ── Blame the specific line ──
BLAME_LINE=$(git blame -L "${LINE_NUM},${LINE_NUM}" --porcelain "$FILE" 2>/dev/null | head -1) || true
COMMIT_HASH=$(echo "$BLAME_LINE" | awk '{print $1}')

[ -z "$COMMIT_HASH" ] && { echo "BLAME_FAILED: could not blame line $LINE_NUM"; exit 0; }

# ── CR P0-3 + ARCH P0-3 fix: handle uncommitted content (zero hash) ──
if [[ "$COMMIT_HASH" == 0000000* ]]; then
  RULE=$(sed -n "${LINE_NUM}p" "$FILE")
  printf 'RULE: %s\n' "$RULE"
  printf 'COMMIT: uncommitted\n'
  printf 'DATE: (working tree)\n'
  printf 'AUTHOR: (not yet committed)\n'
  printf 'MESSAGE: Content exists in working tree but has not been committed\n'
  exit 0
fi

RULE=$(sed -n "${LINE_NUM}p" "$FILE")
COMMIT_DATE=$(git log -1 --format='%ad' --date=short "$COMMIT_HASH" 2>/dev/null) || true
COMMIT_AUTHOR=$(git log -1 --format='%an' "$COMMIT_HASH" 2>/dev/null) || true
COMMIT_MSG=$(git log -1 --format='%s' "$COMMIT_HASH" 2>/dev/null) || true

# ── ARCH P0-1 fix: NO context output (Blake uses Read tool for surrounding lines) ──
printf 'RULE: %s\n' "$RULE"
printf 'COMMIT: %s\n' "$COMMIT_HASH"
printf 'DATE: %s\n' "$COMMIT_DATE"
printf 'AUTHOR: %s\n' "$COMMIT_AUTHOR"
printf 'MESSAGE: %s\n' "$COMMIT_MSG"
