# Acceptance Verification — TASK-20260903-LITEMUTE

**When**: 2026-09-06
**Source**: HANDOFF-20260903-bugfix-lite-mute.md §9.1
**Tree**: AGENTS.md + CLAUDE.md staged; lite SKILLs untouched; CLAUDE.md §2.5 md5 `3a95595ff8191b9a037aa86cf202a4b0` unchanged

| AC | Actual | Expected | Verdict |
|----|--------|----------|---------|
| AC1 | Role-Switching section: 0 lite-trigger hits; `Alex is the Solution Lead`=1; `Blake is the Execution Master`=1 | 0 then two `1` | PASS (first segment is empty = 0 matches) |
| AC2 | 4 lines: isolation rule; Default Behavior LITE branch; two footer mappings; then `Full roles ignore` count=1 | those 4 + `1` | PASS |
| AC3 | `sed -n '3,5p' \| grep -c "^>"` → 1; `方向互斥：full` → 1 | `1` then `1` | PASS |
| AC4 | porcelain + diff on `*lite*` skills empty | empty | PASS |
| AC5 | verbatim `grep -v "^\?\?"` empty on BSD; equivalent `grep -v '^??'` → AGENTS.md + CLAUDE.md; Frozen heading count=1 | two paths + `1` | PASS-equivalent / verbatim BSD false-FAIL |

**§2.5**: byte-identical before/after (md5 match).
**Lite SKILLs**: zero diff vs HEAD.
