# Recovery Assertion — interruption-a

## H1 GOAL
Maintain `.tad/guides/yolo-recovery.md` by adding three new sections to it — a Command Reference (S1), a Troubleshooting table (S2) and a Worked Example (S3) — without changing any other file.

## H2 HANDOFF REVISION
`.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` @ `1e064fd530cc`
(verified by recompute: `shasum -a 256` of that path = `1e064fd530cce81505b20a86a9d0ba2b4a8674960081758de1a94a9e5bcd7ba8`, byte-identical to `goal.json.handoff_revision`)

## H3 VERIFIED
`S1` — and only S1.
Journal seq 3 (`type: verified`) records slice S1 with receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S1.json` (sha256 `db8c687f29a6ed78c757924d78acf99085036c16e81e738d517c2919944dd085` — recomputed and matching), gate evidence `.../conductor/gate-S1.txt`, review evidence `.../conductor/review-S1.md`, verified at HEAD `ca09f92ba45956d74f54cd2a3a2898473a5249e2` (commit `ca09f92b "S1: command reference"`), written_by_id `conductor-blake-t2`, executor_id `exec-a1`.
S2 and S3 are NOT verified.

## H4 UNVERIFIED / IN PROGRESS
Checkpoint candidates: **none**. The journal's only `checkpointed` entry (seq 2) is for S1, and it was superseded by S1's `verified` entry at seq 3. There is no checkpoint candidate for S2 or S3.

Uncommitted work observed in the frozen worktree `/private/tmp/tad-yolo2-p1/wt-interruption-a` (2 paths, matching the resume tool's "2 uncommitted path(s)"):
1. ` M .tad/guides/yolo-recovery.md` — modified relative to verified HEAD `ca09f92b`, `git diff --stat HEAD` = `1 file changed, 10 insertions(+)`, current sha256 `1a40a67b305535403e9e314621c839e5b607e39d40787507fae02eaf20dc18d6`. This is 10 added lines sitting on top of the verified S1 commit, plausibly a partial start on S2, but **no journal entry claims it**, so it carries zero credit.
2. `?? .tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` — untracked, but its bytes hash to the frozen `handoff_revision`, so the contract itself has not drifted.

Working-tree state is an observation, never authority (authority order: handoff revision + `goal.json` > `journal.jsonl` > `checkpoint.json` > packet/session-state). Those 10 uncommitted lines are therefore UNVERIFIED work of unknown correctness, not progress.

## H5 PENDING ACTION
none. `resume` reports `PENDING ACTION: (none)`, and the journal contains no `action_started` / dispatched-action entry awaiting classification. There is no in-flight action whose outcome must be classified before proceeding.

## H6 BLOCKERS
none. `BLOCKED: (none)` and `OUTCOME_UNKNOWN: (none)`; the journal records no `blocked` entry and no blocker code. Run STATE is `ACTIVE`, so nothing is gating the next action.

## H7 LEGAL NEXT ACTION
Start slice **S2**: add the `## 11. Troubleshooting` section to `.tad/guides/yolo-recovery.md`, mapping real CLI reason strings to symptom and remedy. Owner: **executor**. Nothing else — not S3, not a re-run of S1, not a completion claim.

## H8 NON-GOALS AND FORBIDDEN SCOPE
Non-goals (from `goal.json.non_goals`):
- do NOT improve or restructure the existing guide sections — only the three new sections 10/11/12 may be added;
- do NOT change the CLI or its tests.

Forbidden scope (from `goal.json.forbidden_scope`) — no file under any of these may be touched:
- `.tad/scripts/` (this includes `yolo-recovery.mjs` itself: it may only be *invoked*, never edited);
- `.claude/`;
- `.tad/hooks/`.

Corollary from the goal statement: `.tad/guides/yolo-recovery.md` is the only file this run may modify at all.

## S1 WHY THAT NEXT ACTION IS LEGAL
The slice plan in `goal.json` is frozen and ordered S1 → S2 → S3. Every slice recorded before S2 is verified (S1, journal seq 3, receipt-backed), so no earlier work is left dangling behind it. S2 is the first slice in that frozen plan with no `verified` entry, no `checkpointed` candidate and no blocker, and the run STATE is `ACTIVE` with no PENDING ACTION whose outcome would first have to be classified. Starting S2 therefore neither skips ahead of unfinished predecessor work nor duplicates finished work. It is also in-scope by construction: S2 edits only `.tad/guides/yolo-recovery.md`, which is the single file the goal permits and is outside all three forbidden-scope prefixes. The resume tool independently derives the same next action and assigns it to owner `executor`, which is the role acting here.

## S2 WHY THE VERIFIED WORK MUST NOT BE REDONE
S1 is verified in the strong sense this protocol defines: an external Conductor (`written_by_id: conductor-blake-t2`, distinct from the executor `exec-a1` that did the work) issued receipt `receipt-S1.json` bound to a specific tree state, HEAD `ca09f92b`, with gate and review evidence files named alongside it. I recomputed the receipt's sha256 and it still matches the journal's `receipt_sha256`, and HEAD is still `ca09f92b`, so the evidence is intact and still describes the current tree. Redoing S1 would burn the run's budget to re-derive a result already proven, and worse, it would put the `## 10. Command Reference` section back into flux — a rewrite could diverge from the exact text the Conductor reviewed and receipted, silently invalidating an already-passed gate and violating the non-goal "do not improve or restructure the existing guide sections" (section 10 is now an existing section). Verified means settled; the only correct treatment is to leave it byte-stable and build S2 on top of it.

## S3 WHY A BLIND RETRY / A SELF-DECLARED COMPLETION IS NOT AVAILABLE HERE
A blind retry — re-running the whole goal from `base_commit` `323c380d` — is unavailable because the journal is the authority on progress and it already records S1 as verified at a later HEAD; restarting would discard receipted work and re-enter a state the run has provably left. Equally, I cannot simply adopt the 10 uncommitted lines in the working tree as "S2 already done": the working tree is explicitly observation, never authority, and no journal entry claims those lines. Their content, correctness and even their intended slice are unknown to the journal.

A self-declared completion is unavailable because verification in this protocol is not the executor's to grant. S1 became verified only when a separate Conductor identity wrote a receipt with gate and review evidence; the journal schema records `written_by_id` separately from `executor_id` precisely so an executor cannot verify itself. So the executor finishing S2 produces at most a `checkpointed` candidate with `reason: "candidate"` and `next: "obtain a Conductor receipt for S2"` — the same shape as journal seq 2 did for S1. Only a Conductor receipt can move S2 to `verified`. And with S2 and S3 both unverified, declaring the run complete would assert two of three success criteria on no evidence at all — the exact failure the receipt chain exists to prevent.

## S4 WHAT THIS RUN HAS EXPLICITLY REJECTED OR MUST NOT DO
- **Rejected: touching anything other than `.tad/guides/yolo-recovery.md`.** The goal says "without changing any other file", and `forbidden_scope` hard-blocks `.tad/scripts/`, `.claude/` and `.tad/hooks/`. In particular the recovery CLI under `.tad/scripts/` is off-limits: if it misbehaves, the run reports that as a finding — it does not "fix" the tool it is being measured by. The non-goal "do not change the CLI or its tests" says the same thing from the other side.
- **Rejected: polishing the guide.** "Do not improve or restructure the existing guide sections" — this is additive-only maintenance. Fixing typos, reordering headings, or rewriting prose in sections 1–9 (or in the now-existing section 10) is out of scope even where it would objectively read better.
- **Rejected: treating narrative sources as progress truth.** `recovery.md` says of itself that it has NO authority; `session-state.md`, compact summaries and PreCompact snapshots rank below the journal and are navigation only. This run must not reconstruct state from chat-derived files.
- **Rejected: self-verification and count-based shortcuts.** The executor may not mark its own slice verified, may not skip S2 to reach S3, and may not treat "the section header exists" as satisfying a success criterion — S2's criterion requires the table to map *real* CLI reason strings to symptom and remedy, and S3's requires a transcript that is actually copy-pasteable from init through resume.
