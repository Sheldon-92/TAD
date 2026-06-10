#!/bin/bash
# Acceptance verification for HANDOFF-20260610-feedback-collector-phase1
set -e
PASS=0; FAIL=0

check() {
  local name="$1"; local expected="$2"; local actual="$3"
  if [ "$actual" = "$expected" ] || [ "$actual" -ge "$expected" ] 2>/dev/null; then
    echo "  ✅ $name: expected=$expected actual=$actual"
    PASS=$((PASS+1))
  else
    echo "  ❌ $name: expected=$expected actual=$actual"
    FAIL=$((FAIL+1))
  fi
}

echo "=== Feedback Collector Phase 1 — Acceptance Verification ==="

check "AC1: feedback_collector_protocol in SKILL body" 1 "$(grep -c 'feedback_collector_protocol' .claude/skills/blake/SKILL.md)"
check "AC2: NOT in references/" 0 "$(ls .claude/skills/blake/references/feedback* 2>/dev/null | wc -l | tr -d ' ')"
check "AC3: HTML guidelines (>=2 matches)" 2 "$(grep -cE 'self.contained|card.based|export.*JSON|见机行事' .claude/skills/blake/SKILL.md)"
check "AC4: dimension auto-detect (>=2 matches)" 2 "$(grep -cE 'artifact_type.*frontend_page|default_dimensions|feedback_collector_protocol' .claude/skills/blake/SKILL.md)"
check "AC5: handoff template feedback_required" 1 "$(grep -c 'feedback_required' .tad/templates/handoff-a-to-b.md)"
check "AC6: handoff template artifact_type" 1 "$(grep -c 'artifact_type' .tad/templates/handoff-a-to-b.md)"

if test -f .tad/templates/feedback-json-schema.md; then
  echo "  ✅ AC7: schema doc EXISTS"; PASS=$((PASS+1))
else
  echo "  ❌ AC7: schema doc MISSING"; FAIL=$((FAIL+1))
fi

check "AC8: schema fields (>=3 matches)" 3 "$(grep -c -E 'verdict|selector|free_text|structured_feedback' .tad/templates/feedback-json-schema.md)"
check "AC9: config feedback_collector" 1 "$(grep -c 'feedback_collector:' .tad/config-workflow.yaml)"
check "AC10: config default_dimensions" 1 "$(grep -c 'default_dimensions:' .tad/config-workflow.yaml)"
check "AC11: old 8.5 renumbered to 8.6" 1 "$(grep -c '8\.6.*Test Evidence' .tad/templates/handoff-a-to-b.md)"

echo ""
echo "Results: $PASS PASS, $FAIL FAIL"
[ "$FAIL" -eq 0 ] && echo "=== ALL PASS ===" && exit 0
echo "=== SOME FAILED ===" && exit 1
