#!/usr/bin/env bash
# AC6: .agents parity — scope mirrors byte-identical; global parity recorded
cd "$(git rev-parse --show-toplevel)"
cmp .claude/skills/alex/references/distillation-loop-protocol.md .agents/skills/alex/references/distillation-loop-protocol.md || { echo "AC6 FAIL mirror1"; exit 1; }
cmp .claude/skills/release-runbook/SKILL.md .agents/skills/release-runbook/SKILL.md || { echo "AC6 FAIL mirror2"; exit 1; }
bash .tad/hooks/lib/release-verify.sh parity . >/tmp/ac6-global.txt 2>&1; G=$?
echo "AC6 scope PASS: both handoff mirrors byte-identical; global parity exit=$G (see /tmp/ac6-global.txt; concurrent workstream drift is out of handoff scope)"
exit 0
