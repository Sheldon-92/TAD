---
gate: 2
reviewer: A
date: 2026-09-29
task_id: TASK-20260929-AGENT-EVAL-HILLCLIMB-L2
verdict: PASS
p0: 0
p1: 1
p2: 2
channel: Cursor / grok-4.7-medium
lens: spec / pathspec / AC realism
---

# Gate 2 Reviewer A — spec / pathspec / AC realism

Independent seat. Read design, handoff, discuss vehicle §3 and §5, and the three live targets. Did not edit those targets, the handoff, or product files.

## P0

None.

## P1

1. **Handoff AC list drops one design negative grep.** Design acceptance §3 requires `grep -RIn '见过的题上变绿' .agents/skills/ai-evaluation/references` with empty output. Handoff §3 says the criteria are the same as the design, then numbers 13 commands and omits that grep (handoff jumps from the `patterns/pack-evaluation.md` references grep to `git diff --exit-code`). Pathspec still says `references/` zero edit, and the design list is complete, so this does not change what Blake may edit. A Blake who runs only the numbered handoff list would not catch that phrase if it were copied into `references/`.

## P2

1. **Index hook drops two existing retrieval tokens.** Replacement is 86 chars after ` — ` and keeps anti-slop, cross-model, discriminative, dogfood, blind A/B, plus 噪声地板 / held-out / 一轮一改. Current hook is 131 and also contains `pack quality` and `WebSearch fact-check`. Those two tokens leave the only Pack Evaluation index line. Required by the 120-char cap; keyword match on the dropped phrases will not open this file from the index line.
2. **`grep -c 'patterns/pack-evaluation.md'` is not fixed-string.** `.` matches any character. Today the count is 0. After the one paste-ready line it counts that line. Neighbor files are covered by the `references/` greps, which are also unescaped. Low false-count risk on this tree.

## Per-check

| ID | Check | Result | Evidence |
|----|--------|--------|----------|
| C1 | Paste-ready L2 is verbatim-appendable: Context, Discovery, Action, failure_mode, Grounded in; both fail-class sentences; 5-field audit shape as evidence; 无负对照即剧场 in Naive default / Why wrong | PASS | Design “Exact paste-ready L2 entry”. Action defines 「见过的题上变绿」 and 「结构绿冒充行为绿」. Action lists `task; harness; metrics; grader; can-this-set-detect-the-change` and says it is not a new Gate number. failure_mode uses Naive default / Why wrong and the phrase 无负对照即剧场. Grounded in cites vehicle §5.1 and optional-absorb rows 1–2. Scope matches discuss §5.1 (noise floor, held-out headline, one variable, fail samples kept off the optimized artifact, five-field shape). |
| C2 | Pack Evaluation replacement hook ≤120 after ` — `, and contains 噪声地板 / held-out / 一轮一改 | PASS | Paste hook length 86 (`python3` `len` on the hook text). All three tokens present. One replacement line, not a second index row. Current live hook length 131, so the ≤120 assert fails before the edit. |
| C3 | `ai-evaluation`: one cross-ref line; `references/` zero edit; insert after `No overlap.` | PASS | Decision is ONE line. Paste is a single line, no new heading, no subcommand. Insert point is SKILL.md line 25, which is exactly `Pack = evaluation judgment. Your workflow system = process constraints. No overlap.` (`grep -c` of that sentence is 1). Pack-wide search for the audit terms and for `patterns/pack-evaluation.md` is empty, so the “same sentence missing → one cross-ref” branch matches discuss §5.3. Cross-ref says 一轮一变; index says 一轮一改; that split matches §5.2 vs §5.3. |
| C4 | Pathspec is exactly three files | PASS | Design “Blake pathspec” and handoff §2: `pack-evaluation.md` append, `_index.md` Pack Evaluation line only, `SKILL.md` one inserted line. `principles.md`, `gate-design.md`, `agent-skill-evolution`, and `pack-registry.yaml` are absent from the pathspec. |
| C5 | “Must appear” greps fail on pre-Blake HEAD; negative checks and out-of-scope `git diff` targets are real | PASS | Ran on this tree. Exit 1 / no match: L2 title, 见过的题上变绿, 结构绿冒充行为绿, 无负对照即剧场, `can-this-set-detect-the-change` on `pack-evaluation.md`; 噪声地板, held-out, 一轮一改 on `_index.md`. Hook-length assert raises `AssertionError: 131`. `grep -c 'patterns/pack-evaluation.md'` on SKILL.md prints `0` (exit 1), not `1`. Empty already (correct for must-not-appear): `can-this-set-detect-the-change` in `gate-design.md`; both `references/` greps. `git diff --exit-code` on `principles.md`, `patterns/gate-design.md`, `agent-skill-evolution`, `pack-registry.yaml` exits 0. All four paths exist, so the fence is not a missing-path no-op. `references/` is fenced by grep, not by that diff. |
| C6 | Human locks held in the spec | PASS | Hybrid home is an append to existing `pack-evaluation.md` plus one index hook plus at most one pack pointer (discuss §3 / §5). No new Gate number, no hillclimb slash, no `*experiment` change. No principles / gate-design / agent-skill-evolution / pack-registry edits. Paste-ready L2 and the cross-ref line do not name Claude Code commands (`/claude-api` appears only in the prohibition bullets). No push. Both files stay `READY_FOR_GATE2` and tell Blake not to start. This seat did not implement. |

## Live targets (expected pre-Blake)

Still unmodified. `git diff --exit-code` on the three pathspec files exits 0.

- `pack-evaluation.md` last heading is still `Named Workflow Resolution Caches Script; Use scriptPath for Iteration — 2026-06-17`.
- `_index.md` Pack Evaluation line is still the 131-char hook (`Anti-slop metrics, cross-model review, … WebSearch fact-check`).
- `ai-evaluation/SKILL.md` line 25 is still the `No overlap.` sentence; the cross-ref line is not inserted.
- `principles.md` and `gate-design.md` are outside the three-file pathspec.

Draft text lives in the design and the handoff only.

## Verdict

PASS. P0 = 0. P1 = 1 (handoff run-list omits one negative `references/` grep that the design already specifies). P2 = 2.

SUMMARY: Spec, three-file pathspec, and acceptance greps are realistic for a verbatim hybrid L2 append; pre-Blake must-appear checks fail on the unedited tree; no P0.
