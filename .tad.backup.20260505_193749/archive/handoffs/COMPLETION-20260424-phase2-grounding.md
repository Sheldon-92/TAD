# Completion Report — Phase 2 Grounding & Anti-Stale-Knowledge

**Handoff**: `HANDOFF-20260424-phase2-grounding.md`
**Epic**: `EPIC-20260424-tad-self-upgrade-from-consumers.md` (Phase 2/6)
**Date**: 2026-04-24
**Agent**: Blake (Execution Master, Terminal 2)
**Status**: ✅ Gate 3 v2 PASS

---

## What was delivered

All 2 tasks + 28 ACs implemented. Per the handoff's recommended order: P2.1 first (more fixtures, larger surface), P2.2 second.

### Task P2.1 — Knowledge Grounded in / Revalidated + stale-knowledge-check.sh

- README Entry Format extended with `Grounded in` + `Revalidated` bullets, plus strict grammar (single `:LINE` int, no `:42-55` ranges, no spaces/commas in path).
- `.tad/hooks/lib/stale-knowledge-check.sh` — NEW 282-line BSD-portable CLI tool.
  - Output modes: human-readable text + `--json` JSONL.
  - 5-state status enum: STALE / INFO / WARN / OK / ERROR.
  - Algorithm: `baseline = max(entry_date, revalidated_date)`; STALE when file mtime > baseline + 86400s grace.
  - cwd auto-resolves to git root; non-git → exit 1 with clear message.
  - Symlinks followed via `stat -L`.
  - Subshell-safe: `_validate_path` returns `STATUS\tSTRIPPED_PATH` on stdout (not via global side effects).
  - Date normalization to midnight (`%Y-%m-%d %H:%M:%S` with `00:00:00` appended) prevents BSD wall-clock leakage.
- Alex SKILL `step0_5` step 9: stale-check called advisory-only at handoff drafting; failure → stderr warn + continue (never blocks).
- 15 minimum fixtures in `.tad/evidence/completions/phase2-grounding/fixtures/`.
- 34/34 fixture assertions PASS.

### Task P2.2 — Alex step1c grounding pass + handoff template

- Alex SKILL `step1c` block inserted between step1b and step2.
  - `enforcement: "prompt-level-only"` explicit.
  - `forbidden_implementations` list bans: PreToolUse hook, UserPromptSubmit hook, auto-fired script, deny exit code, tool blocking.
  - Exemptions for pre-Phase-2 handoffs / doc-only / empty §6.
  - `*express` exemption deferred to Phase 3.
- Handoff template `.tad/templates/handoff-a-to-b.md` §7.3 — Grounded Against placeholder + step1c reference.
- 21/21 fixture assertions PASS.

## Implementation Decisions (made during execution)

| # | Decision | Context | Chosen |
|---|----------|---------|--------|
| 1 | First draft 433 lines exceeded 350 escalation threshold | Handoff estimated 200-280; first cut had verbose comments + bloated _validate_path | Trimmed to 282 lines, same algorithm, same coverage |
| 2 | _validate_path subshell bug | Function set `_stripped_path` global; broke under `$()` capture | Refactored to return `STATUS\tSTRIPPED_PATH` via stdout |
| 3 | Date wall-clock leakage | BSD `date -j -f "%Y-%m-%d"` inherits current time for missing fields → days_delta=6 instead of 7 | Force `"%Y-%m-%d %H:%M:%S"` with `00:00:00` |
| 4 | New knowledge entry to satisfy dogfood | Test-runner caught: §5 requires new entry with Grounded in | Added "Revalidated State Defeats Alarm Fatigue" entry with Grounded in + Revalidated, runtime-verified |

## Deviations from plan

None. All 28 ACs satisfied; stale-check.sh at 282 lines (under 350); zero anti-Epic-1 leaks.

## Required Evidence Manifest compliance

```
✓ COMPLETION report (this file)
✓ Alex pre-handoff reviews (code-reviewer + backend-architect + feedback-integration)
✓ GATE3-REPORT.md
✓ Blake reviews (spec-compliance + code-reviewer + test-runner + self-review + feedback-integration)
✓ 15 fixtures in fixtures/
✓ real-corpus-output.txt (47 INFO entries, 0 ERROR, exit 0)
✓ failure-isolation.txt (malformed header → skip + exit 0)
✓ anti-epic1-grep.txt (Phase 2 keywords: 0 leaks; settings.json: unchanged)
✓ dogfood.md (4 dogfood proofs)
✓ architecture.md +1 entry with Grounded in + Revalidated (meta-trifecta)
```

## Knowledge Assessment

**New discovery?** Yes
**Category**: architecture
**Entry**: `### Revalidated State Defeats Alarm Fatigue in mtime-Based Staleness Detection - 2026-04-24`
**Summary**: Designing a "still-true?" smoke alarm needs a quieting path on day one — without `Revalidated`, alarm fatigue collapses the system in ~3 months. Two related portability traps captured: BSD `date -j -f` partial-format wall-clock leakage; bash function side-effect globals breaking under `$()` subshell. Entry has Grounded in + Revalidated bullets and is verified live by the new tool (meta-trifecta dogfood).

## Git commit

**Hash**: `0b2e25d`
**Message**: `feat(TAD): implement phase2-grounding [Gate 3 pending]`
**Verified**: `git log --oneline -1 0b2e25d` → valid in history

## Next steps

1. Alex executes Gate 4 v2 (acceptance) on this handoff
2. Alex archives handoff + COMPLETION pair to `.tad/archive/handoffs/`
3. Epic Phase 2 → ✅ Done; Phases 3-6 remain ⬚ Planned
