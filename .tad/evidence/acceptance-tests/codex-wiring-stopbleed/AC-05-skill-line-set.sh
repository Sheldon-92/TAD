#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
cd "$REPO"
base=e5b810d7ab1bf1a61d7ad5372a174b95b007c5e3
changed="$(git diff --unified=0 "$base" -- \
  .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md \
  .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md | awk '/^[+-][^+-]/ {print}')"
added="$(printf '%s\n' "$changed" | grep '^+' || true)"
removed="$(printf '%s\n' "$changed" | grep '^-' || true)"
invalid_added="$(printf '%s\n' "$added" | grep -vE '^\+# reference 相对路径以本 skill 基目录解析（两平台激活均提供该目录）——维护者注记，勿改回 \.claude/skills 绝对形式$|^\+[[:space:]]*reference: "references/[^" ]+"$' || true)"
invalid_removed="$(printf '%s\n' "$removed" | grep -vE '^-[[:space:]]*reference: "\.claude/skills/(alex|blake)/references/[^" ]+"$' || true)"
note_count="$(printf '%s\n' "$added" | grep -c '^+# reference 相对路径以本 skill 基目录解析（两平台激活均提供该目录）——维护者注记，勿改回 \.claude/skills 绝对形式$' || true)"
relative_count="$(printf '%s\n' "$added" | grep -cE '^\+[[:space:]]*reference: "references/[^" ]+"$' || true)"
old_count="$(printf '%s\n' "$removed" | grep -cE '^-[[:space:]]*reference: "\.claude/skills/(alex|blake)/references/[^" ]+"$' || true)"
[ -z "$invalid_added" ] && [ -z "$invalid_removed" ]
[ "$note_count" -eq 4 ] && [ "$relative_count" -eq 72 ] && [ "$old_count" -eq 72 ]
echo 'AC5 PASS: line-set contains only 72 reference replacements plus one exact note per file'
