#!/usr/bin/env bash
# Acceptance verification — HANDOFF-20260817-alex-review-loop-cap
# Runs all 12 ACs against BOTH mirror trees. exit 0 = PASS, exit 1 = FAIL
# Baseline SHA: 35187243 (the commit that added the handoff itself; the handoff
# text cites its parent 35d69228 — using 35187243 makes AC-N5 count exactly the
# 4 implementation files, excluding the handoff doc.)

set -u
cd "$(git rev-parse --show-toplevel)" || exit 1

SHA=35187243
CP=.claude/skills/alex/references/handoff-creation-protocol.md
AP=.agents/skills/alex/references/handoff-creation-protocol.md
CS=.claude/skills/alex/SKILL.md
AS=.agents/skills/alex/SKILL.md

fail=0
chk() { # name expected actual
  if [ "$2" = "$3" ]; then printf 'PASS  %-28s expected=%-10s got=%s\n' "$1" "$2" "$3"
  else printf 'FAIL  %-28s expected=%-10s got=%s\n' "$1" "$2" "$3"; fail=1; fi
}
chk_ge() { # name min actual
  if [ "$3" -ge "$2" ] 2>/dev/null; then printf 'PASS  %-28s expected>=%-9s got=%s\n' "$1" "$2" "$3"
  else printf 'FAIL  %-28s expected>=%-9s got=%s\n' "$1" "$2" "$3"; fail=1; fi
}

for P in "$CP" "$AP"; do
  tag=$([ "$P" = "$CP" ] && echo claude || echo agents)
  echo "--- protocol [$tag] ---"
  chk "AC-1  max_review_rounds"  1 "$(grep -c '^  max_review_rounds: 2$' "$P")"
  chk "AC-2  round_protocol"     1 "$(grep -c '^  round_protocol:$' "$P")"
  chk "AC-3  p0_resolved_def"    1 "$(grep -c '^  p0_resolved_definition: |$' "$P")"
  chk "AC-4a violation round3"   1 "$(grep -cF '自行进入第 3 轮 = VIOLATION' "$P")"
  chk "AC-4b violation diff"     1 "$(grep -cF '重发 handoff 全文而非 diff = VIOLATION' "$P")"
  chk "AC-N1 minimum_experts"    1 "$(grep -c '^  minimum_experts: 2$' "$P")"
  chk "AC-N6 violations count"   4 "$(sed -n '/^  violations:/,/^[a-z]/p' "$P" | grep -c '^    - ')"
  # AC-N7 incremental: file is broken at baseline (line 516); must not regress earlier
  chk "AC-N7 yaml err line"      "line 516" "$(yq '.handoff_creation_protocol' "$P" 2>&1 | grep -oE 'line [0-9]+' | head -1)"
done

echo "--- SKILL.md ---"
chk_ge "AC-5  max 2 rounds [claude]" 1 "$(grep -cF 'max 2 rounds' "$CS")"
chk_ge "AC-5  max 2 rounds [agents]" 1 "$(grep -cF 'max 2 rounds' "$AS")"

echo "--- negative controls ---"
# Scope is measured over the IMPLEMENTATION range only. After Gate 3, Blake's
# required doc outputs (COMPLETION report per step3c, NEXT.md per step7) land in
# a SEPARATE commit; counting them makes AC-N5 read 6 and masks the real
# question — "did the implementation touch anything beyond the 4 mirror files?"
# IMPL_END defaults to the implementation commit; before it exists (i.e. while
# the change is still unstaged) the working tree IS the implementation.
IMPL_END="${IMPL_END:-dab4daf1}"
if git cat-file -e "${IMPL_END}^{commit}" 2>/dev/null; then
  IMPL_FILES="$(git diff --name-only "$SHA" "$IMPL_END")"
else
  IMPL_FILES="$(git diff --name-only "$SHA")"
fi
chk "AC-N2 no blake touched"   0 "$(printf '%s\n' "$IMPL_FILES" | grep -cE 'blake')"
chk "AC-N3 no lite touched"    0 "$(printf '%s\n' "$IMPL_FILES" | grep -cE 'lite')"
chk "AC-N5 changed file count" 4 "$(printf '%s\n' "$IMPL_FILES" | grep -c .)"

echo "--- mirror parity (AC-N4) ---"
bash .tad/hooks/lib/skill-body-verify.sh >/dev/null 2>&1
chk "AC-N4 skill-body-verify"  0 "$?"

echo
[ $fail -eq 0 ] && echo "RESULT: ALL ACs PASS" || echo "RESULT: FAILURES PRESENT"
exit $fail
