#!/bin/bash
# fm-lint.sh — stdlib-only frontmatter lint for .claude/agents/*.md (AC2, T1 deliverable)
# Checks per file (no yaml module, no split('---')[1]):
#   1. First line is exactly `---`
#   2. A closing `---` exists on a later line
#   3. Frontmatter contains `name: ` and its value equals the filename (sans .md)
#   4. No tab characters inside the frontmatter block
# Output: `FM-OK (N files)` when all pass; `FAIL <file>: <reason>` lines otherwise.
# Portability: bash 3.2, BSD grep/awk/sed safe (no grep -P, no associative arrays).

set -u

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
AGENTS_DIR="$REPO_ROOT/.claude/agents"

fail=0
count=0

if [ ! -d "$AGENTS_DIR" ]; then
  echo "FM-OK (0 files)"
  exit 0
fi

found_any=0
for f in "$AGENTS_DIR"/*.md; do
  [ -e "$f" ] || continue
  found_any=1
  count=$((count + 1))
  base="$(basename "$f" .md)"

  # 1. first line must be exactly ---
  first_line="$(head -n 1 "$f")"
  if [ "$first_line" != "---" ]; then
    echo "FAIL $f: first line is not '---'"
    fail=1
    continue
  fi

  # 2. closing --- on a later line
  close_line="$(awk 'NR>1 && $0=="---" {print NR; exit}' "$f")"
  if [ -z "$close_line" ]; then
    echo "FAIL $f: no closing '---' found"
    fail=1
    continue
  fi

  # frontmatter block = lines 2..close_line-1
  fm="$(awk -v end="$close_line" 'NR>1 && NR<end' "$f")"

  # 3. name: present and value == filename
  name_val="$(printf '%s\n' "$fm" | awk -F': ' '/^name: /{print $2; exit}')"
  if [ -z "$name_val" ]; then
    echo "FAIL $f: frontmatter missing 'name: ' key"
    fail=1
    continue
  fi
  if [ "$name_val" != "$base" ]; then
    echo "FAIL $f: name '$name_val' != filename '$base'"
    fail=1
    continue
  fi

  # 4. no tabs in frontmatter
  if printf '%s\n' "$fm" | grep -q "$(printf '\t')"; then
    echo "FAIL $f: tab character inside frontmatter"
    fail=1
    continue
  fi
done

if [ "$found_any" -eq 0 ]; then
  echo "FM-OK (0 files)"
  exit 0
fi

if [ "$fail" -eq 0 ]; then
  echo "FM-OK ($count files)"
  exit 0
fi
exit 1
