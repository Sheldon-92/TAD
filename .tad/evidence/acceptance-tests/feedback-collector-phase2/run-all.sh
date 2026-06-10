#!/bin/bash
set -e
PASS=0; FAIL=0

check() {
  local name="$1"; local expected="$2"; local actual="$3"
  if [ "$actual" = "$expected" ] || [ "$actual" -ge "$expected" ] 2>/dev/null; then
    echo "  ✅ $name: expected=$expected actual=$actual"; PASS=$((PASS+1))
  else
    echo "  ❌ $name: expected=$expected actual=$actual"; FAIL=$((FAIL+1))
  fi
}

echo "=== Feedback Collector Phase 2 — Acceptance Verification ==="
check "AC1: read_feedback_protocol in Alex SKILL" 1 "$(grep -c 'read_feedback_protocol' .claude/skills/alex/SKILL.md)"
check "AC2: NOT in references/" 0 "$(ls .claude/skills/alex/references/read-feedback* 2>/dev/null | wc -l | tr -d ' ')"
check "AC3: 5 protocol steps" 5 "$(grep -cE '1_load_json|2_summarize|3_group_by_verdict|4_generate_handoff|5_confirm' .claude/skills/alex/SKILL.md)"
check "AC4: Gate4_Feedback_Check" 1 "$(grep -c 'Gate4_Feedback_Check' .claude/skills/gate/SKILL.md)"
check "AC5: conditional on feedback_required" 1 "$(grep -cE 'feedback_required.*true|skip_if.*feedback_required' .claude/skills/gate/SKILL.md)"
test -f tad-intro.html && { echo "  ✅ AC6: tad-intro.html EXISTS"; PASS=$((PASS+1)); } || { echo "  ❌ AC6: MISSING"; FAIL=$((FAIL+1)); }
test -f tad-intro-feedback.html && { echo "  ✅ AC7: tad-intro-feedback.html EXISTS"; PASS=$((PASS+1)); } || { echo "  ❌ AC7: MISSING"; FAIL=$((FAIL+1)); }
check "AC8: export JSON in feedback HTML" 1 "$(grep -cE 'exportJSON|Export.*JSON.*button|download.*json' tad-intro-feedback.html)"
test -d .tad/evidence/e2e/feedback-collector-dogfood && { echo "  ✅ AC9: E2E evidence dir EXISTS"; PASS=$((PASS+1)); } || { echo "  ❌ AC9: MISSING"; FAIL=$((FAIL+1)); }
check "AC10a: read_feedback_protocol in SKILL body" 1 "$(grep -c 'read_feedback_protocol' .claude/skills/alex/SKILL.md)"
check "AC10b: feedback_required in acceptance-protocol.md" 1 "$(grep -c 'feedback_required' .claude/skills/alex/references/acceptance-protocol.md)"

echo ""
echo "Results: $PASS PASS, $FAIL FAIL"
[ "$FAIL" -eq 0 ] && echo "=== ALL PASS ===" && exit 0
echo "=== SOME FAILED ===" && exit 1
