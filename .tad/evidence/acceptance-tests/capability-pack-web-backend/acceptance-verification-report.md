# Acceptance Verification Report — Web Backend Capability Pack

**Date**: 2026-05-07
**Task**: capability-pack-web-backend
**Handoff**: HANDOFF-20260507-capability-pack-web-backend.md

Note: task_type=mixed. No npm/test-runner suite. AC verification via shell commands
on the ~/web-backend/ artifact. All 17 ACs verified against actual output.

---

## Results: 17/17 PASS

| AC# | Verification Command | Expected | Actual | Status |
|-----|---------------------|----------|--------|--------|
| AC1 | `ls ~/web-backend/ ~/web-backend/references/ ~/web-backend/scripts/` | 8 refs, 4 scripts | 8 refs, 4 scripts ✓ | ✅ PASS |
| AC2 | `head -5 ~/web-backend/CAPABILITY.md` | YAML frontmatter | `name: web-backend` + `description:` | ✅ PASS |
| AC3 | `grep -cE '^\*\*Rule' ~/web-backend/CAPABILITY.md` | 0 | 0 | ✅ PASS |
| AC4 | `grep -rcE '^\*\*Rule [0-9]+' references/*.md` | ≥43 | 43 (7+6+6+6+7+4+7) | ✅ PASS |
| AC5 | `grep -cE '^\- \[[ x]\] \*\*PC-[0-9]+' production.md` | 46 | 46 | ✅ PASS |
| AC6 | backtick lines in references/ | ≥60 | 197 | ✅ PASS |
| AC7 | `grep -rcE 'If Node\|If Python\|If Go'` refs + CONVENTIONS.md | ≥5 | 17 lines | ✅ PASS |
| AC8 | `bash -n` all scripts + `grep -l 'command -v' scripts/*.sh` | All 4 OK | 4/4 OK + 4/4 preflight | ✅ PASS |
| AC9 | `bash install.sh --agent=claude-code --dry-run` | Exit 0 | Exit 0 | ✅ PASS |
| AC10 | `grep -cE '^\|.*\|.*\|' CAPABILITY.md` | ≥6 | 35 | ✅ PASS |
| AC11 | `grep -cE 'Zalando\|OWASP\|Sairyss\|Mercari' LICENSE-ATTRIBUTION.md` | ≥4 | 14 | ✅ PASS |
| AC12 | `grep -cE 'Simple Layered\|Clean\|Hexagonal\|DDD\|CQRS\|Event Sourcing' architecture.md` | ≥6 | 9 | ✅ PASS |
| AC13 | TAD terminology grep (excl. LICENSE-ATTRIBUTION.md) | 0 | 0 | ✅ PASS |
| AC14 | `find ~/web-backend/ \( -name '*.md' -o -name '*.sh' \) -exec cat {} + \| wc -l` | ≤5000 | 3165 | ✅ PASS |
| AC15 | `git log --oneline -1` in ~/web-backend | commit exists | 5c4c6ab ✓ | ✅ PASS |
| AC16 | `grep -rcE 'If .+:' database.md infrastructure.md api-design.md` | ≥5 | 30 | ✅ PASS |
| AC17 | `wc -l ~/web-backend/references/application-logic.md` | ≥30 | 212 | ✅ PASS |

**FAIL count: 0**
**PASS count: 17/17**

---

## Intent-Pass notes (no LITERAL fails, for completeness)

AC3 verification `grep -cE '^\*\*Rule' CAPABILITY.md` outputs two lines ("0\n0") due to
shell echo behavior, but the count is confirmed 0 — intent passes.

No other intent/literal discrepancies.
