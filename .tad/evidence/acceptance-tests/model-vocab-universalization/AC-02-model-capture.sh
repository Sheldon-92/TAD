#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

files=".claude/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md"

capture_section() {
  case "$1" in
    *alex-lite/SKILL.md)
      awk '
        /^### R0 — Route preflight/ { inside=1; start=NR; next }
        inside && /^### / { exit }
        inside { print }
      ' "$1"
      ;;
    *blake-lite/SKILL.md)
      awk '
        /^## L4 Completion/ { inside=1; start=NR; next }
        inside && /^## / { exit }
        inside { print }
      ' "$1"
      ;;
  esac
}

fail=0
for file in $files; do
  section="$(capture_section "$file")"
  for needle in \
    "CODEX_HOME" \
    "config.toml" \
    "route=unknown" \
    "model_reasoning_effort" \
    "OPENAI_BASE_URL" \
    "default_subagent_model"; do
    count="$(printf '%s\n' "$section" | grep -F -c -e "$needle" || true)"
    if [ "$count" -lt 1 ]; then
      echo "FAIL AC2 $file: capture section lacks '$needle'"
      fail=1
    fi
  done

  legacy="$(grep -F -c -e "ANTHROPIC_BASE_URL 的 host" "$file" 2>/dev/null || true)"
  if [ "$legacy" -ne 0 ]; then
    echo "FAIL AC2 $file: legacy Anthropic route phrase count=$legacy"
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "AC2 PASS: codex/other capture terms are section-scoped across all four lite mirrors"
