#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"

check_tree() {
  local root="$1" tree="$2" label="$3"
  local file rel skill skill_dir refs_in_file ref target
  local coupled=0 missing=0
  while IFS= read -r -d '' file; do
    rel="${file#$tree/}"
    skill="${rel%%/*}"
    skill_dir="$tree/$skill"
    refs_in_file="$(sed -nE 's/^[[:space:]]*reference:[[:space:]]*"([^"]+)".*$/\1/p' "$file")"
    while IFS= read -r ref; do
      [ -n "$ref" ] || continue
      case "$ref" in
        .tad/*) target="$root/$ref" ;;
        references/*|./references/*) target="$skill_dir/${ref#./}" ;;
        .claude/skills/*) coupled=$((coupled + 1)); target="$root/$ref" ;;
        /*) target="$ref" ;;
        *) continue ;;
      esac
      [ -f "$target" ] || missing=$((missing + 1))
    done <<< "$refs_in_file"
  done < <(find "$tree" -type f -name '*.md' -print0)
  printf '%s: coupled=%s missing=%s\n' "$label" "$coupled" "$missing"
  [ "$coupled" -eq 0 ] && [ "$missing" -eq 0 ]
}

check_tree "$REPO" "$REPO/.claude/skills" claude
check_tree "$REPO" "$REPO/.agents/skills" codex
echo 'AC4 PASS: all path-like references resolve with zero coupled or missing targets'
