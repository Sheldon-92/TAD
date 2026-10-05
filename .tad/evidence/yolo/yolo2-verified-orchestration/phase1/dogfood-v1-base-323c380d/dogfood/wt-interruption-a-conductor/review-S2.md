# Independent slice review (round 2) — interruption-a — S2

Reviewer model: claude-opus-5

Scope: `.tad/guides/yolo-recovery.md` §11 (lines 346–408) as of worktree HEAD
`f1eb4ce5`, diffed against `039f68c2`, verified against
`.tad/scripts/yolo-recovery.mjs` **in this worktree** (1200 lines, last touched by
`323c380d`; unchanged by the fix commit). Verification was static (source read)
plus live execution of a *copy* of the CLI in a throwaway git repo in my
scratchpad. The worktree was not modified (`git status` shows only the
pre-existing untracked handoff).

## Round-1 findings

1. **FALSE ATTRIBUTION (`resume` refused with `run_in_honest_partial`) — CLOSED.**
   The row now reads: "The three state-advancing commands — `checkpoint`, `verify`
   and `action-start`, the only callers of the honest-partial guard — are refused;
   the run cannot move forward. `status` and `resume` deliberately still work…".
   `grep -n refuseIfHonestPartial` returns the definition (L863) and exactly three
   call sites: `cmdCheckpoint` L886, `cmdVerify` L905, `cmdActionStart` L939.
   Live, on a run in `HONEST_PARTIAL`: `checkpoint`, `verify` and `action-start`
   each returned `"reason":"run_in_honest_partial"` with `details.command`,
   `details.blockers`, `details.required`; `status` and `resume` both ran and
   returned the top-level status shape with `"reason":"outcome_unknown"` (the
   blocker code), never `run_in_honest_partial`. The false attribution is gone.

2. **OVER-CLAIM (intro implied the table was exhaustive) — CLOSED.**
   The intro now reads: "The table below covers the failure modes an operator
   actually hits; it is **not** exhaustive. The source defines many more reasons
   for corrupt or hand-edited ledgers and other rarer states (`goal_corrupt`,
   `journal_missing`, `unknown_event_type`, `duplicate_verified_slice`,
   `event_after_stop`, `receipt_not_json`, `verified_evidence_missing`,
   `git_unavailable` and others). For a reason you do not find here, search
   `.tad/scripts/yolo-recovery.mjs` for the literal string…". Checked: the source
   raises **76** distinct reason strings; the section mentions **45** of them, so
   **31** are undocumented — matching the round-1 estimate of ≈30. All 8 named
   examples exist in the source and none of them appears in the table, so the
   "for a reason you do not find here" framing is coherent, not decorative.

3. **RENDERING DEFECT (unescaped pipes in `pending_action_blocks_verify`) — CLOSED.**
   The remedy now reads `reconcile --action <id> --outcome
   <confirmed\|outcome_unknown\|reconciled>` — the three inner pipes are escaped,
   matching the convention already used in §3.2 (L93) and S1's §10 (L324, L327).
   Full-table pipe check below.

## New verification

**Rows verified independently against `.tad/scripts/yolo-recovery.mjs`** (†
= row the round-1 reviewer did not check; ‡ = claim newly written by this fix, so
effectively unchecked):

- † `action_target_missing` — `cmdActionStart` L948–950: `resolveInRepo(targetInput,
  …, '--target')` then `if (!fs.existsSync(targetAbs) || !fs.lstatSync(targetAbs).isFile())
  throw new ContractError('action_target_missing', { path: targetInput })`. Exit 1,
  `details.path` echoes the raw `--target` input, and a directory is rejected —
  exactly what the row claims. **TRUE.**
- ‡ `capsule_over_budget` "every command except `status`" / "earliest point is
  `init`" — `writeDerived(...)` is called by `cmdInit` L850, `cmdCheckpoint` L898,
  `cmdVerify` L925, `cmdActionStart` L964, `cmdReconcile` L1052, `cmdResume` L1079,
  `cmdStop` L1091; `cmdStatus` L874 alone calls `finish('status', r.runDir, r.state,
  null)`, and `finish` only throws `if (packet && packet.tokens > CAPSULE_TOKEN_BUDGET)`
  (L1099). So 7 of 8 commands can raise it, `status` cannot, and `init` is the
  first that can. `CAPSULE_TOKEN_BUDGET = 2500` (L53). **TRUE.**
- ‡ `path_escape` label taxonomy — `assertInside` L142–144 throws `UsageError`
  (hence exit 2) with `{ label, path, base }`. Labels: `run_dir` (`resolveRunDir`
  L178), `oracle_path` (L822), `` `${label}.path` `` with label ∈
  {`gate_evidence`, `review_evidence`} (L744, from `checkEvidence` L761–762), and
  the flag names `--handoff` / `--goal-file` / `--receipt` / `--target` /
  `--evidence`. Live: `status --run .tad/scripts` returned
  `{"label":"run_dir","path":…,"base":…/.tad/evidence/yolo}`. **TRUE** (round-1's
  P2 about "`label` naming the flag" is fixed).
- † `receipt_field_missing` "first required key that is absent, `null` or empty" —
  L707–711 iterates `RECEIPT_REQUIRED` (L676–680, 12 keys) in order and throws on
  the first `undefined | null | ''`. **TRUE.**
- † `journal_corrupt` family — `readJournal` L242–251: `journal_corrupt {line: idx+1,
  message: …slice(0,200)}` (1-based ✓, truncated ✓), `journal_blank_line {line}`,
  `journal_partial_line`, `journal_seq_broken {line, seq}` when `ev.seq !== idx+1`
  (i.e. numbering skips or repeats). Raised inside `loadRun`, so every command
  fails at load. **TRUE.**
- `unknown_command` "the eight legal commands" — `COMMANDS` L69–71 has exactly 8
  entries. **TRUE.**
- `handoff_revision_drift` "including read-only `status` and `resume`" —
  L639–643 inside `loadRun`, which every command reaches via `withRun` L856–861.
  **TRUE.** `goal_mutated` `details.frozen` = `events[0].payload.goal_sha256`
  (L645–647), i.e. the sha sealed into `seq: 1`. **TRUE.**
- `already_stopped` — live: second `stop` returned
  `{"reason":"already_stopped","details":{"reason":"human halt"}}`, quoting the
  *original* reason. **TRUE.**

**Pipe-count check (every row, not just the repaired one).** Stripping `\|` first,
then counting `|`: lines 358 (header), 359 (separator) and all 34 data rows
360–393 have **exactly 5** unescaped pipes each → 4 columns throughout, no row
over- or under-splits. 34 data rows, no duplicate first-column keys.

### NEW FALSE CLAIM introduced by the fix (P0)

The replacement `run_in_honest_partial` row ends with:

> "`status` and `resume` deliberately still work, so a blocked run can always be
> read and recovered, and `reconcile` and `stop` stay available so it can be
> resolved."

A run reaches `HONEST_PARTIAL` two ways (`reduceRun` L380: `if (stopped ||
unknownActions.length > 0)`). The sentence is true for the *outcome_unknown*
flavour and **false, destructively, for the *stopped* flavour**:

- `stop` is **not** available: `cmdStop` L1089 throws `already_stopped`.
  Live-confirmed.
- `reconcile` does not "resolve" a stopped run — it **bricks** it. `cmdReconcile`
  passes its own guards, calls `appendEvent` (L1052-adjacent), and only then
  re-loads; `reduceRun` L599 (`if (stopped) throw new ContractError(
  'event_after_stop', …)`) rejects the event it just wrote. Reproduced live on a
  clean run (init → action-start → stop → `reconcile --outcome outcome_unknown`):
  the reconcile returned `{"reason":"event_after_stop","details":{"seq":4,
  "type":"action_reconciled"}}` **and the illegal `seq: 4` line is now in
  `journal.jsonl`**. Afterwards `status` and `resume` both fail with
  `event_after_stop` — so the same sentence's promise that "a blocked run can
  always be read and recovered" is destroyed by the action it recommends, and the
  journal is append-only and must never be hand-repaired (the row's own
  `journal_corrupt` remedy, and §8).
- This contradicts a pre-existing section of the same guide, exactly as round-1
  finding 1 did: §8 (L284) states "`stop` … puts the run in `honest_partial` …
  **Nothing may be recorded afterwards.**"

Related, **pre-existing** (unchanged by this fix, not flagged in round 1, P1): the
same row's remedy cell says "open a new run or explicitly reconcile this one" —
"reconcile this one" carries the same hazard for a stopped run and should be
scoped in the same edit.

Minor (P2), same row: "The three state-advancing commands" reads as an exhaustive
claim about which commands advance state. `reconcile`, `stop` and `init` also
append events; the accurate set is "the only three callers of the honest-partial
guard", which the em-dash clause already says correctly.

Minor (P2), `path_escape` row, pre-existing: "Triggered by an absolute path
outside the repo, a `../` climb, or a path that resolves to the repo root itself"
is incomplete for `--run`, whose base is `.tad/evidence/yolo/` (`RUN_ROOT_REL`
L51, `resolveRunDir` L177) — a path inside the worktree but outside the run root
also escapes, so the remedy ("pass a path inside the worktree") is insufficient
for that flag. §12 states the run-dir rule, so this is imprecision, not a
contradiction.

Nothing else in the diff introduces a false claim: the `path_escape` and
`capsule_over_budget` expansions and the whole intro rewrite check out against the
source, and no invented identifier was introduced.

## Scope

`git diff --numstat 039f68c2..HEAD` = `13 5 .tad/guides/yolo-recovery.md` — one
file, no others. All five hunks (`@@ -348 +348,9`, `-353 +361`, `-357 +365`,
`-373 +381`, `-382 +390`) fall inside §11 (L346–408; §10 at L314, §12 at L411).
Byte-identical diffs confirm: file start → `## 10.` unchanged, `## 10.` → `## 11.`
(S1) unchanged, `## 12.` → EOF (S3) unchanged. **Scope held.**

independent: true
verdict: FAIL
