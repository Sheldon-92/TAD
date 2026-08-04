#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

files=".claude/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md"

tier_section() {
  awk '
    /^### Reviewer 档位规则[[:space:]]*$/ {
      inside=1
      start=NR
      next
    }
    inside && /^### / { exit }
    inside { print }
  ' "$1"
}

fail=0
for file in $files; do
  heading_count="$(grep -F -c -e "### Reviewer 档位规则" "$file" 2>/dev/null || true)"
  if [ "$heading_count" -ne 1 ]; then
    echo "FAIL AC1 $file: Reviewer 档位规则 heading count=$heading_count"
    fail=1
  fi

  case "$file" in
    .claude/skills/alex-lite/SKILL.md|.agents/skills/alex-lite/SKILL.md)
      expected_line=235 ;;
    .claude/skills/blake-lite/SKILL.md|.agents/skills/blake-lite/SKILL.md)
      expected_line=233 ;;
  esac
  actual_line="$(grep -n -F -e "### Reviewer 档位规则" "$file" | cut -d: -f1)"
  if [ "$actual_line" != "$expected_line" ]; then
    echo "FAIL AC1 $file: heading line=$actual_line expected=$expected_line"
    fail=1
  fi

  section="$(tier_section "$file")"
  for needle in \
    "按能力档位判定，不按 SKU" \
    "route=unknown 按 alias-mapped" \
    "按非强档保守处理" \
    "minimal < low < medium < high"; do
    count="$(printf '%s\n' "$section" | grep -F -c -e "$needle" || true)"
    if [ "$count" -lt 1 ]; then
      echo "FAIL AC1 $file: tier section lacks '$needle'"
      fail=1
    fi
  done

  legacy="$(grep -F -c -e "强档定义：opus / fable 级" "$file" 2>/dev/null || true)"
  if [ "$legacy" -ne 0 ]; then
    echo "FAIL AC1 $file: legacy strong-tier phrase count=$legacy"
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "AC1 PASS: capability tier is section-scoped, line-anchored, mirrored, and legacy wording is absent"
