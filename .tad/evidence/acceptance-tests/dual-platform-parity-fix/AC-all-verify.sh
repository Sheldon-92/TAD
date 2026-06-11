#!/bin/bash
set -euo pipefail
PASS=0; FAIL=0; TOTAL=10

run_ac() {
  local ac="$1" desc="$2"
  shift 2
  if "$@" >/dev/null 2>&1; then
    echo "✅ $ac: $desc"
    PASS=$((PASS + 1))
  else
    echo "❌ $ac: $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Dual-Platform Parity Fix — Acceptance Verification ==="
echo ""

run_ac "AC1" "Full skills-tree parity" diff -qr .agents/skills .claude/skills
run_ac "AC2" "publish-protocol byte-identical" diff -u .agents/skills/alex/references/publish-protocol.md .claude/skills/alex/references/publish-protocol.md
run_ac "AC3" "sync-protocol byte-identical" diff -u .agents/skills/alex/references/sync-protocol.md .claude/skills/alex/references/sync-protocol.md
run_ac "AC4" "yolo-execution-protocol byte-identical" diff -u .agents/skills/alex/references/yolo-execution-protocol.md .claude/skills/alex/references/yolo-execution-protocol.md
run_ac "AC5" "Runtime freshness passes" bash .tad/hooks/lib/runtime-freshness-verify.sh
run_ac "AC6" "MULTI-PLATFORM.md no stale claims" bash -c '! rg -n "Runtime Freshness Layer \(Phase 4 — pending\)|Phase 4.*pending.*will create|Runtime freshness ledger not created|Full-cycle regression not yet run|runtime freshness pending" docs/MULTI-PLATFORM.md'
run_ac "AC7" "Codex README no stale claims" bash -c '! rg -n "Runtime freshness \| Pending Phase 4|Runtime freshness ledger missing|Full-cycle regression not run|hook matcher unknown" .tad/codex/README.md'
run_ac "AC8" "Config/agents remain draft-only" bash -c 'test ! -f .codex/config.toml && test ! -d .codex/agents && rg -q "Human explicitly approves" .tad/codex/README.md docs/MULTI-PLATFORM.md'
run_ac "AC9" "No runtime config changes" bash -c '! git diff --name-only | rg -e "^\.codex/hooks\.json$|^\.claude/settings\.json$|^\.codex/config\.toml$|^\.codex/agents/"'
run_ac "AC10" "Commit f428d70 did not touch feedback-collector" bash -c '! git show f428d70 --name-only --format="" | rg -e "feedback-collector"'

echo ""
echo "=== Results: $PASS/$TOTAL PASS, $FAIL/$TOTAL FAIL ==="
[ "$FAIL" -eq 0 ] && echo "VERDICT: ALL PASS" || echo "VERDICT: FAIL"
exit "$FAIL"
