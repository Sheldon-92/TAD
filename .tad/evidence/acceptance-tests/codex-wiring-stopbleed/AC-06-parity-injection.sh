#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
cd "$REPO"
claude="$REPO/.claude/skills/alex/SKILL.md"
agents="$REPO/.agents/skills/alex/SKILL.md"
tmpdir="$(mktemp -d)"
cp "$claude" "$tmpdir/claude.SKILL.md"
cp "$agents" "$tmpdir/agents.SKILL.md"
restore() {
  cp "$tmpdir/claude.SKILL.md" "$claude"
  cp "$tmpdir/agents.SKILL.md" "$agents"
}
trap restore EXIT INT TERM
inject_double() {
  perl -0pi -e 's/\n\z/\n  reference: ".claude\/skills\/x.md"\n/' "$1"
}
inject_single() {
  perl -0pi -e 's/\n\z/\n  reference: '\''\.claude\/skills\/x.md'\''\n/' "$1"
}
inject_bare() {
  perl -0pi -e 's/\n\z/\n  reference: .claude\/skills\/x.md\n/' "$1"
}
assert_dual_fail() {
  set +e
  dual_out="$(bash .tad/hooks/lib/release-verify.sh parity . 2>&1)"
  dual_rc=$?
  set -e
  [ "$dual_rc" -eq 1 ]
  printf '%s\n' "$dual_out" | grep -q 'parity FAIL: platform-coupled reference path in .agents/skills/alex/SKILL.md:'
}

inject_double "$claude"
inject_double "$agents"
assert_dual_fail

restore
inject_single "$claude"
inject_single "$agents"
assert_dual_fail

restore
inject_bare "$claude"
inject_bare "$agents"
assert_dual_fail

restore
inject_double "$claude"
set +e
single_out="$(bash .tad/hooks/lib/release-verify.sh parity . 2>&1)"
single_rc=$?
set -e
[ "$single_rc" -eq 1 ]
printf '%s\n' "$single_out" | grep -Fq "Files $claude and $agents differ"
echo 'AC6 PASS: exact dual-tree specialized fail and single-tree byte-parity fail; trap restored files'
