#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
scratch="$REPO/.tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only"
if [ -e "$scratch/.claude/skills" ]; then exit 1; fi
mkdir -p "$scratch/.agents/skills" "$scratch/.tad/guides"
rsync -a "$REPO/.agents/skills/" "$scratch/.agents/skills/"
rsync -a "$REPO/.tad/guides/cross-model-invocation.md" "$scratch/.tad/guides/"
missing=0
while IFS= read -r -d '' file; do
  rel="${file#$scratch/.agents/skills/}"
  skill="${rel%%/*}"
  skill_dir="$scratch/.agents/skills/$skill"
  refs_in_file="$(sed -nE 's/^[[:space:]]*reference:[[:space:]]*"([^"]+)".*$/\1/p' "$file")"
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    case "$ref" in
      .tad/*) target="$scratch/$ref" ;;
      references/*|./references/*) target="$skill_dir/${ref#./}" ;;
      .claude/skills/*) exit 1 ;;
      /*) target="$ref" ;;
      *) continue ;;
    esac
    [ -f "$target" ] || missing=$((missing + 1))
  done <<< "$refs_in_file"
done < <(find "$scratch/.agents/skills" -type f -name '*.md' -print0)
[ "$missing" -eq 0 ]
echo 'AC9 PASS: codex-only .agents tree resolves all path-like references with .claude absent'
