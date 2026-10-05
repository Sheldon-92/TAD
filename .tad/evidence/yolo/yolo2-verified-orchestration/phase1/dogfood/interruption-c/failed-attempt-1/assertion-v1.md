# Recovery Assertion — interruption-c

## H1 GOAL
Maintain `.tad/guides/yolo-recovery.md` by adding three new sections — S1 `## 10. Command Reference`, S2 `## 11. Troubleshooting`, S3 `## 12. Worked Example` — without changing any other file.

## H2 HANDOFF REVISION
`.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` @ `1e064fd530cc`
(re-hashed in the worktree just now: `1e064fd530cce81505b20a86a9d0ba2b4a8674960081758de1a94a9e5bcd7ba8` — byte-identical to the revision frozen in `goal.json`, so the plan is still anchored to the approved handoff.)

## H3 VERIFIED
none — `journal.jsonl` contains exactly one record (`seq:1`, `type:"initialized"`, `2026-08-24T22:28:01.161Z`, `observed_head 323c380d`). No `S1`, `S2` or `S3` has any verification record, so zero slices are verified.

## H4 UNVERIFIED / IN PROGRESS
No checkpoint candidates are recorded in the journal (no slice-start, no slice-complete, no evidence pointer).

Working-tree observation only (never authority), from `git status --porcelain` in `/private/tmp/tad-yolo2-p1/wt-interruption-c`, HEAD `323c380d` = `base_commit`:
- `M .tad/guides/yolo-recovery.md` — 14 uncommitted insertions, 0 deletions vs HEAD (`git diff --stat HEAD`); current file sha256 `dbb0d6b79d20a4fd28c234a07274968bfa7d724dc0bde1b3ac5562d09d6880a0`. These lines are the target file of S1/S2/S3 and are plausibly a partial, interrupted edit, but nothing in the journal claims them, so their slice membership and their correctness are both UNKNOWN. They may not be counted as progress on S1.
- `?? .tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` — untracked in this worktree; it is the handoff itself and its hash matches H2, so it is plan input, not work product.

These two paths are the "2 uncommitted path(s)" the resume command reported.

## H5 PENDING ACTION
none — no action is recorded in the journal awaiting classification, and `resume` reports `PENDING ACTION: (none)` with no `OUTCOME_UNKNOWN` entries. Nothing was left mid-flight with an undetermined outcome at the protocol level.

## H6 BLOCKERS
none — `resume` reports `BLOCKED: (none)`; run `STATE: ACTIVE`, `result: PASS`. There is no blocker code to clear before proceeding.

## H7 LEGAL NEXT ACTION
Start slice S1: add the `## 10. Command Reference` section to `.tad/guides/yolo-recovery.md`, documenting every CLI command with its required flags and exit codes. Owner: `executor`. Because the file already carries 14 unjournaled uncommitted lines, starting S1 means first observing the current state of that file and reconciling it against the S1 statement — not appending on top of an assumed-clean base and not silently discarding it.

## H8 NON-GOALS AND FORBIDDEN SCOPE
Non-goals (from `goal.json`): (a) do not improve or restructure the existing guide sections — only the three new sections may be added; (b) do not change the CLI or its tests.
Forbidden scope (paths that must not be touched): `.tad/scripts/`, `.claude/`, `.tad/hooks/`. Notably `.tad/scripts/yolo-recovery.mjs` — the CLI this run documents — is inside the forbidden `.tad/scripts/` prefix: S1 and S2 must describe its commands, flags, exit codes and reason strings, never edit them to fit the docs.

## S1 WHY THAT NEXT ACTION IS LEGAL
The frozen plan in `goal.json` orders the slices S1 → S2 → S3. The journal's only record is `initialized`, so no slice has been verified and no slice is recorded as in progress; there is no blocker and no pending action whose outcome must be settled first. S1 is therefore the first unverified slice in the frozen order, which is exactly the condition the `resume` command states for legality ("all recorded slices before it are verified; this is the first unverified slice in the frozen plan"). The handoff still hashes to the frozen revision and HEAD still equals `base_commit`, so the plan the legality argument rests on has not drifted. S1 also writes only to `.tad/guides/yolo-recovery.md`, which is inside the goal's single permitted target and outside every forbidden prefix.

## S2 WHY THE VERIFIED WORK MUST NOT BE REDONE
Vacuously, there is no verified work in this run to redo — H3 is genuinely `none`, not "unknown". The principle still governs the uncommitted edit: verification status comes from the journal, not from the working tree, and the rule runs in both directions. Work the journal records as verified is settled and must not be re-executed; work the journal is silent about — including these 14 lines — earns no credit and must not be claimed as a completed slice. Redoing verified work would waste the run and risk mutating an already-accepted artifact into a different state than the one that was verified, breaking the evidence pointer that made it verified in the first place.

## S3 WHY A BLIND RETRY / A SELF-DECLARED COMPLETION IS NOT AVAILABLE HERE
A blind retry — re-running S1 from an assumed-clean file — would collide with the 14 lines already present and could produce a duplicated or half-merged `## 10.` section that no record explains. A self-declared completion is unavailable because completion in this protocol is a journal fact backed by an evidence pointer, not an executor's assertion: the run carries a sealed oracle (`oracle.sealed.txt`, sha256 `dc95fe23…`) that this executor may not read, so the executor structurally cannot be the judge of its own output. The success criteria are also externally checkable (named section headings, real CLI reason strings, a transcript that actually runs from init through resume), which means "I think it's done" carries no weight against a check that can be re-run. The authority order is explicit that the packet, `session-state.md` and compact summaries are navigation only — a claim of doneness sourced from any of them is not evidence.

## S4 WHAT THIS RUN HAS EXPLICITLY REJECTED OR MUST NOT DO
- Rejected: improving or restructuring the guide's existing sections. The mandate is strictly additive — three new sections, nothing else.
- Rejected: changing the CLI or its tests, and any write under `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. If the CLI's actual behaviour contradicts what the docs would like to say, the docs bend, not the CLI.
- Rejected: touching any file other than `.tad/guides/yolo-recovery.md` ("without changing any other file").
- Rejected as sources of truth: `recovery.md` itself, `session-state.md`, and PreCompact/compact summaries. The authority order is approved handoff revision + immutable `goal.json` first, then a fully parseable `journal.jsonl` with its evidence pointers, then a rebuildable `checkpoint.json`; if the packet disagrees with the journal, the journal wins and the packet is rebuilt.
- Rejected: treating the dirty working tree as progress. The uncommitted 14 lines are recorded as an observation and carry no verification weight.
