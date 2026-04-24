# Spec-Compliance Review — Phase 2 Grounding

**Reviewer:** spec-compliance-reviewer
**Handoff:** `HANDOFF-20260424-phase2-grounding.md`
**Date:** 2026-04-24
**Method:** Re-derived each AC from primary evidence (ran both test scripts, read all 4 files, ran shellcheck, ran anti-Epic-1 greps myself).

---

## Per-AC Verdict Table

### Task P2.1 — stale-knowledge-check.sh + README + Alex step0_5 step 9

| AC | Verdict | Evidence (re-verified) |
|----|---------|------------------------|
| a — README Grounded in/Revalidated + grammar | SATISFIED | `README.md` lines 35–82 contain both bullets, strict grammar (comma/space/colon rules + `:42-55` forbidden), example legal + illegal, Revalidated rationale. |
| b — shellcheck + BSD-portable | SATISFIED | `shellcheck` PASS; script uses `stat -f '%m' -L` + `date -j -f "%Y-%m-%d %H:%M:%S"`; GNU fallback present (line 83–94). |
| c — fixture stale 7 days | SATISFIED | Test output: `days_delta=7`, STALE emitted. |
| d — fixture not-stale | SATISFIED | OK emitted. |
| e — fixture no-grounded INFO | SATISFIED | INFO `legacy entry, skip`. |
| f — fixture missing-file WARN | SATISFIED | WARN `Grounded in path '…' missing on disk`. |
| g — multi-path independent | SATISFIED | Multiple paths each emit their own line (OK + STALE). |
| h — revalidated baseline wins | SATISFIED | Revalidated 04-10 > mtime 04-08 → OK. |
| i — revalidated < mtime STALE | SATISFIED | `days_delta=7` relative to revalidated 04-05. |
| j — grace boundary | SATISFIED | +86399s OK / +86401s STALE. |
| k — malformed `:42-55` | SATISFIED | WARN + script still exits 0. |
| l — `(new — will be created)` | SATISFIED | INFO `marked as new`, no WARN. |
| m — title with dash (anchor LAST ` - `) | SATISFIED | Awk regex `[[:space:]]-[[:space:]][0-9]{4}…$` correctly uses last match; fixture passes. |
| n — `(consolidated)` suffix | SATISFIED | `sub(/ *\(consolidated\) *$/)` strips; date extracted. |
| o — --json schema | SATISFIED | 5 keys present; `days_delta` null or int; 5 status enum enforced by emitter switch. |
| p — real-corpus exit 0 + non-empty + no ERROR | SATISFIED | `real-corpus-output.txt` shows 30+ INFO rows, no ERROR, exit 0. |
| q — failure isolation | SATISFIED | Malformed header fixture → exit 0; `failure-isolation.txt` documents the fall-through contract with Alex step0_5 step 9. |
| r — NOT registered in settings.json | SATISFIED | `git diff HEAD -- .claude/settings.json` is empty; my own grep: no `stale-knowledge-check` in `.claude/settings.json` or any hook script other than the script itself. |
| s — cwd resolves / non-git exit 1 | SATISFIED | `git rev-parse --show-toplevel` used; test confirms non-git → `exit 1` with stderr message. |
| t — symlink follows target | SATISFIED | `stat -f '%m' -L` explicit; fixture test PASSes. |

**P2.1 subtotal: 20/20 SATISFIED.**

### Task P2.2 — Alex step1c + Grounded Against template

| AC | Verdict | Evidence (re-verified) |
|----|---------|------------------------|
| a — step1c between step1b and step2 | SATISFIED | `SKILL.md` line 1593 (`step1c`) between line 1584 (`step1b`) and line 1641 (`step2`). Ordering check passes. |
| b — template §7.3 Grounded Against | SATISFIED | `handoff-a-to-b.md` lines 424–440 contain the block with explanation + placeholder + exemption comment. |
| c — dogfood: handoff §6 has Grounded Against | SATISFIED | Handoff lines 369–377 list 7 real files (6 existing + 1 new-marker). |
| d — enforcement prompt-level-only + forbidden list | SATISFIED | `enforcement: "prompt-level-only"` (line 1596); `forbidden_implementations` (lines 1633–1639) lists PreToolUse, UserPromptSubmit, auto-fired, deny exit, no tool block, anti_rationalization parity. |
| e — `(new — will be created)` marker described | SATISFIED | step1c action step 3 + example output line 1620. |
| f — anti-Epic-1 grep 0 hits | SATISFIED | My own `grep -rE 'step1c\|grounding-pass\|grounded_against' .claude/settings.json .tad/hooks/*.sh` → 0 hits (exit 1). `anti-epic1-grep.txt` confirms. |
| g — pre-Phase-2 exemption fixture | SATISFIED | Fixture `fixtures/pre-phase2-handoff/` present; exemption documented in `exemption_pre_phase2_handoffs` (line 1621). |
| h — doc-only / empty §6 exemption | SATISFIED | Fixture `fixtures/doc-only-handoff/` has `task_type: doc-only`; SKILL line 1624–1625 describes auto-skip. |

**P2.2 subtotal: 8/8 SATISFIED.**

---

## Anti-Epic-1 Invariants (independently verified)

1. `stale-knowledge-check.sh` **NOT** registered in `.claude/settings.json` — confirmed by raw grep (only `.claude/settings.json` entries are pre-existing PreToolUse/UserPromptSubmit registrations for Phase-1/Phase-2b hooks, none reference stale-check or step1c).
2. Alex SKILL step1c has `enforcement: "prompt-level-only"` (line 1596) and `forbidden_implementations` listing all 4 forbidden paths (PreToolUse, UserPromptSubmit, auto-fired, deny-exit) plus 2 extras (tool-block, anti_rationalization parity).
3. `git diff HEAD -- .claude/settings.json` returns empty output — **Phase 2 did not modify settings.json**.

All 3 invariants PASS. Architecture is aligned with 2026-04-15 "Mechanical Enforcement Rejected" lesson.

---

## Cross-check on AC-P2.2-f script artifact

The P2.2 test script prints an arithmetic-syntax error on line 122 (`0\n0: arithmetic syntax error in expression`), but the subsequent three `[PASS]` lines for AC-P2.2-f show the check itself is correct — the error is a cosmetic bash-math glitch in the test harness, not a functional failure of the AC. My own re-run of the canonical grep confirms 0 hits. AC verdict remains SATISFIED; recommend Blake fix the harness in a follow-up (non-blocking).

---

## Verdict

**NOT_SATISFIED = 0**
**PARTIALLY_SATISFIED = 0**
**SATISFIED = 28/28**

Pass criteria (NOT_SATISFIED=0, PARTIALLY_SATISFIED≤3): **MET.**

## Bottom Line

**PASS.** Blake's Phase 2 implementation satisfies all 28 ACs with independently re-verified evidence. Both test scripts (34/34 + 21/21 = 55/55) run clean; `shellcheck` passes; anti-Epic-1 invariants hold (0 hook registrations, 0 settings.json edits, forbidden_implementations list complete). The dogfood meta-trifecta (handoff uses Grounded Against; stale-check self-ran against real corpus; step1c prompt-level enforcement) is intact. One cosmetic bash arithmetic error in the P2.2 test harness does not affect any AC verdict. Recommend accepting this Gate 3 submission.
