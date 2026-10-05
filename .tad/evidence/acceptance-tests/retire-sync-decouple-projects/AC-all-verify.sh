#!/usr/bin/env bash
# Acceptance verification — HANDOFF-20260817-retire-sync-decouple-projects
# Runs all §7 ACs. exit 0 = all pass; exit 1 = failures present.
# ⚠️ AC-7 expectation is 3 after human ruling 2026-08-22 (history preserved:
# config.yaml changelog, migrations yaml, ac-verification pattern — Alex to
# amend AC-7 exclusion regex via addendum). Gate 3 records this as PARTIAL.

set -u
cd "$(git rev-parse --show-toplevel)" || exit 1

SHA=0566ee4d
fail=0
chk() { # name expected actual
  if [ "$2" = "$3" ]; then printf 'PASS  %-34s expected=%-8s got=%s\n' "$1" "$2" "$3"
  else printf 'FAIL  %-34s expected=%-8s got=%s\n' "$1" "$2" "$3"; fail=1; fi
}
chk_ge() { # name min actual
  if [ "$3" -ge "$2" ] 2>/dev/null; then printf 'PASS  %-34s expected>=%-7s got=%s\n' "$1" "$2" "$3"
  else printf 'FAIL  %-34s expected>=%-7s got=%s\n' "$1" "$2" "$3"; fail=1; fi
}

echo "--- 正向 AC ---"
chk   "AC-1 registry deleted"      0 "$(ls .tad/sync-registry.yaml 2>/dev/null | wc -l | tr -d ' ')"
chk   "AC-2 sync protocols (6)"    0 "$(ls .claude/skills/alex/references/sync*.md .agents/skills/alex/references/sync*.md 2>/dev/null | wc -l | tr -d ' ')"
chk   "AC-3 reg blocks removed"    0 "$(grep -cE '^(sync_protocol|sync_add_protocol|sync_list_protocol):' .claude/skills/alex/SKILL.md)"
chk_ge "AC-3b retire note present" 1 "$(grep -cF '*sync / *sync-add / *sync-list 已于 2026-08-17 退休' .claude/skills/alex/SKILL.md)"
chk   "AC-4 desc no *sync"         0 "$(sed -n '3p' .claude/skills/alex/SKILL.md | grep -cF '*sync')"
chk   "AC-5 CLAUDE.md no *sync"    0 "$(grep -cF '*sync' CLAUDE.md)"
chk   "AC-6 harvest exit 0"        0 "$(bash .tad/hooks/lib/harvest-scan.sh >/dev/null 2>&1; echo $?)"
chk   "AC-7 live sync-registry"    3 "$(git ls-files -z | xargs -0 grep -ln 'sync-registry' 2>/dev/null | grep -vcE '\.tad/(evidence|archive|decisions)/|CHANGELOG|AUDIT|HANDOFF|\.gitignore|derive-sync-set|tad\.sh')"

echo "--- 负控 AC ---"
chk "AC-N1 tad.sh untouched"       0 "$(git diff --name-only $SHA..HEAD 2>/dev/null | grep -cE '^tad\.sh$')"
chk_ge "AC-N2 *publish alive"      1 "$(grep -cF '*publish' .claude/skills/alex/SKILL.md)"
chk "AC-N2b publish-protocol md"   1 "$(ls .claude/skills/alex/references/publish-protocol.md | wc -l | tr -d ' ')"
chk "AC-N3 DR file kept"           1 "$(ls .tad/decisions/DR-20260601-self-deriving-release-sync.md | wc -l | tr -d ' ')"
chk "AC-N4 derive-sync-set"        1 "$(grep -c 'TOP_DENY="sync-registry.yaml"' .tad/hooks/lib/derive-sync-set.sh)"
chk "AC-N5 skill-body-verify"      0 "$(bash .tad/hooks/lib/skill-body-verify.sh >/dev/null 2>&1; echo $?)"
chk "AC-N6 bash -n tad.sh"         0 "$(bash -n tad.sh; echo $?)"

echo
[ $fail -eq 0 ] && echo "RESULT: ALL ACs PASS" || echo "RESULT: FAILURES PRESENT"
exit $fail