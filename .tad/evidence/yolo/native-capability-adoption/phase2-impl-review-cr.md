# Phase 2 Implementation Review — Code-Reviewer Lens

- **Epic**: EPIC-20260712-native-capability-adoption (Phase 2/4)
- **Handoff**: HANDOFF-20260713-native-capability-adoption-phase2.md
- **Worktree**: `.claude/worktrees/wf_f91fb5e4-5de-1` (commit `8b6f0a5`)
- **Reviewer**: code-reviewer (Group 1 lens)
- **Date**: 2026-07-13
- **Verdict**: PASS (DEGRADED as designed) — 0 P0, 0 P1, 3 P2

## Summary

Phase 2 is a spike-gated task whose two headline features (`memory` and `skills` frontmatter
fields) were empirically proven inert on CLI 2.1.172. The implementation follows the handoff's
§4.1 degradation matrix faithfully: it ships the one unconditional deliverable
(`spec-compliance-reviewer.md`), preserves the spike rig as fixtures, escalates every FAIL branch,
and drops nothing silently. This is a textbook honest-partial execution — exactly the anti-Validation-Theater
discipline the handoff's Project Knowledge section demanded.

I re-ran every post-impl AC command in the worktree; all reproduce the completion report's claimed
outputs byte-for-byte. The diff (8 files, +443) matches the completion report's file table exactly.

## AC re-verification (independently reproduced)

| AC | Report claim | My re-run | Match |
|----|--------------|-----------|-------|
| AC1 spike 3 verdicts | `3` | `3` | ✅ |
| AC2 fm-lint | `FM-OK (1 files)` | `FM-OK (1 files)` | ✅ |
| AC3 boundary | `VACUOUS-PASS (no memory defs)` | `VACUOUS-PASS (no memory defs)` | ✅ |
| AC5 memory recall PASS count | `0` (degraded) | `0` | ✅ |
| AC6 skills preload PASS count | `0` (degraded); actual `SKILLS-PRELOAD: FAIL` | `0` / `FAIL` | ✅ |
| AC7 machine-global writes | `0` | `0` | ✅ |
| AC8 reviewer registered | `1` | `1` | ✅ |
| AC9 blake SKILL/template diff | `0` | `0` | ✅ |
| AC10 scope | only trace file outside scope | only `.tad/evidence/traces/2026-07-13.jsonl` | ✅ |

AC3's VACUOUS-PASS is legitimately sanctioned here: it is legal ONLY under memory-VERDICT=FAIL,
which is the actual spike result. No live `memory:` key exists in `spec-compliance-reviewer.md`
(confirmed via grep) — a dead key would have been config theater, correctly avoided.

## Code quality assessment

**fm-lint.sh** — solid stdlib-only implementation. Confirmed:
- Portability claims hold: no `grep -P`, no associative arrays, bash 3.2 / BSD safe.
- Discriminative — I fed it a crafted bad file (name≠filename) and it correctly emitted
  `FAIL ... name 'wrong-name' != filename 'testfile'` and exited 1. Not a rubber-stamp linter.
- `set -u` guards unset vars; empty-dir and no-`.md` cases both handled (early `FM-OK (0 files)`).
- The AC2 result is a GENUINE pass (`1 files`), not the empty-dir vacuous branch.

**spec-compliance-reviewer.md** — well-scoped persona. Body carries the literal AC3 anchor
`MUST NOT store past verdicts` (grep count 1) inside a clearly-labeled *dormant* Memory Protocol
section, with an honest inline note that the field is inert on 2.1.172. Anti-rationalization rules
(§6) and the "patterns in, verdicts out" boundary directly encode the Rubber-Stamp defense from
principles.md 2026-07-03. `model: sonnet` chosen for row-by-row mechanical work (flagged as E6 for
human override).

**Spike evidence** — the FAIL verdicts are backed by raw transcripts, not paraphrase. The memory
probe even caught and corrected its own false positive (project auto-memory `.tad/memory/` ≠
agent-specific memory) via a discriminating re-probe — genuinely rigorous. The skills-preload test
was actually executed with tools hard-banned (`--disallowedTools`), producing `NO-PRELOADED-SKILLS`
against a distinctive pack the agent could have quoted but didn't.

## Findings

### P0 — none

### P1 — none

### P2-1 (Suggestion): fm-lint `name:` parse is `awk -F': '` — fragile to descriptions containing `: `
The name extraction `awk -F': ' '/^name: /{print $2; exit}'` splits on the first `: ` and takes
field 2. For `name: foo` this is correct. But a value like `name: foo: bar` would silently truncate
to `foo`. Not a real risk for the current single file (`name: spec-compliance-reviewer`), and the
name would then mismatch the filename and FAIL anyway — so it fails safe. Consider
`sed -n 's/^name: //p'` to capture the full value if future agent names ever contain `: `.

### P2-2 (Suggestion): fm-lint `REPO_ROOT` falls back to `pwd` on non-git dirs
`REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"` means if the script is ever run
from a non-git subdirectory it lints `$(pwd)/.claude/agents` rather than the intended repo. Harmless
in this repo (always run from root), but a comment noting the "run from repo root" assumption would
prevent a future maintainer from being surprised. Low priority.

### P2-3 (Process, already escalated): trace file outside AC10 scope
`.tad/evidence/traces/2026-07-13.jsonl` is emitted by TAD's own PostToolUse trace hook recording
this task's evidence writes. It is left uncommitted+undeleted (deleting a trace = tampering with the
audit trail). Correctly documented as Escalation E5 with a sensible future recommendation
(exempt `.tad/evidence/traces/` in AC10 scope regex). No action needed this phase.

## Escalations review

E1–E7 in the completion report are all accurate and actionable. Two worth a human's attention before
next steps:
- **E3** (`.claude/agents/` invisible to both distribution paths) — correctly identifies the
  2026-06-01 silent-omission failure class. Recommends main-repo-only, which is sound since the
  reviewer def is TAD-project-specific. Human decision required before next `*publish`.
- **E1/E2** — memory/skills natively unavailable; the value is deferred (dormant boundary already
  ships), not lost. The proposal to build `.tad/`-managed self-managed memory is correctly flagged
  as a NEW design, not done here.

## Conclusion

No correctness bugs, no security issues (no secrets, no injection surface — these are markdown agent
defs + a read-only lint script), no regressions (AC9 confirms zero changes to Blake SKILL / handoff
template). The degradation is honest and fully escalated. The three P2s are minor robustness/process
polish, none blocking. Recommend Gate 3 PASS (DEGRADED-by-design per §4.1 rows 1+2).
