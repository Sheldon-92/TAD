# Independent slice review — interruption-b — S3 (`## 12. Worked Example`)
Reviewer model: claude-opus-5

## Q1 — Does the section meet its slice spec in substance?

Yes. `## 12. Worked Example` exists with the exact required heading (guide L403) and is a real
end-to-end transcript, not a stub: a placeholder block (`WT`, `RUN`, `HANDOFF`, `ORACLE`, `CLI`),
then 12.1 freeze-goal + `init`, 12.2 `checkpoint`, 12.3 the Conductor receipt + `verify`, 12.4
`resume` (including the `--rebuild-derived` remediation), 12.5 the `action-start` / `reconcile`
bracket. All three mandated artifacts are shown: what a checkpoint looks like (the rendered
`UNVERIFIED: - D1 (checkpoint candidate, reason=candidate, next="…")` block plus the `OWNER` flip to
`conductor`), what a receipt-backed verify looks like (a complete `yolo-recovery-verification-v1`
JSON with all twelve required fields and the four load-bearing constraints spelled out), and what
`resume` prints back (status block + `RECOVERY PACKET:` line + trailing JSON). Placeholders are
clearly marked in `<ANGLE BRACKETS>` as the spec allows. Two nits, neither spec-breaking: the
transcript says "every command after them is copy-pasteable as written", but the sealed oracle at
`$ORACLE` is never created even though `init` refuses with `oracle_missing` if it is absent (source
L822-823), and 12.2's `git add <FILES YOU CHANGED>` still contains a placeholder. All code fences in
the section are balanced (7 opened, 7 closed).

## Q2 — Is every technical claim true against the CLI source?

Yes. I checked every command invocation, every field name and every quoted output line against
`.tad/scripts/yolo-recovery.mjs`; spot-checks (well past five):
1. Flag sets. `init --run/--handoff/--goal-file` (L795-800), `checkpoint --run/--slice/--reason/--next`
   (L887-889), `verify --run/--slice/--receipt` (L909-910), `action-start --run/--action/--description/
   --target/--pre-sha256/--intended-post-sha256` (L934-946), `reconcile --run/--action/--outcome`
   (L959-960), `resume --run [--rebuild-derived]` (L1043) — all exact, none invented.
2. Goal-file fields. The heredoc uses `run_id, goal_id, base_commit, goal, success, non_goals,
   forbidden_scope, oracle_path, slices` — the first eight are exactly the required loop at L815 and
   `slices` is the genuine optional array (L836, validated at L211-218). `RUN` "MUST live under
   .tad/evidence/yolo" matches `RUN_ROOT_REL` + `resolveRunDir` (L51, L171-176).
3. Receipt fields. All twelve keys in the 12.3 heredoc match `RECEIPT_REQUIRED` (L671-675) exactly,
   with no extras and none missing; evidence entries carry `path`/`sha256`/`verdict`, and the review
   entry carries `independent: true` — matching `checkEvidence` (L737-757).
4. The four "load-bearing" refusals are all correct: `receipt_verdict_not_pass` on a non-PASS verdict
   (L712), `receipt_author_role_invalid` / `receipt_self_authored` on `written_by` and
   `written_by_id === executor_id` (L722-728), `receipt_no_independent_review` when no entry is
   `independent: true` (L754-756), `receipt_evidence_hash_mismatch` on a stale hash (L750-752).
   `verified_head` must equal the *current* HEAD else `receipt_head_mismatch` (L719-721) — correct,
   including the "do not commit again between the gate and verify" advice.
5. Quoted output is verbatim, not paraphrased. `grep -F` confirms each of these appears exactly once
   in the CLI: "all recorded slices before it are verified; this is the first unverified slice in the
   frozen plan"; "a checkpoint records intent, not verified progress; only a bound Conductor receipt
   may advance verified state"; "is a CANDIDATE only. Obtain a Conductor PASS receipt"; "a side effect
   was started but never reconciled; real file state must be read before anything else happens";
   "checkpoint candidate, reason="; "observation only, never authority"; "est. tokens, budget".
   The banner, `RUN:`/`RUN DIR:`/`GOAL:`/`HANDOFF REVISION:`/`WORKTREE:` lines and the
   VERIFIED→UNVERIFIED→BLOCKED→OUTCOME_UNKNOWN→PENDING ACTION ordering match `renderStatus`
   (L510-547), including the dirty-count line's position immediately after `UNVERIFIED`.
6. Trailing JSON. Key order `format, command, result, …, state, reason, verified_slices,
   unverified_slices, blockers, legal_next_action, capsule_tokens` matches `finish` (L1105-L1120);
   `result":"PASS"` with `state":"ACTIVE"` and `reason":null` is what a non-honest-partial run emits.
   I confirmed the shape empirically with a read-only `status` against this run directory.
7. Exit-code claims: `checkpoint_reason_invalid` is exit `2` — correct, it is a `UsageError` (L891).
   The closing `set -e` caveat ("a **successful** `stop` exits `1`") matches `finish`'s
   `honest ? 1 : 0` (L1112) given `stop` always leaves the run `HONEST_PARTIAL` (L378).
8. `resume` behaviour: rewrites `recovery.md`, prints the packet line
   `RECOVERY PACKET: … (<N> est. tokens, budget 2500)` (L1067), and `derived_state_conflict` /
   `checkpoint_corrupt` are remediated by `--rebuild-derived` (L1046-L1063). `blind_retry_forbidden`
   on re-running `action-start --action A1` after an `outcome_unknown` is L936-938 + L339.

One fidelity nit: the 12.4 `resume` excerpt shows `UNVERIFIED: (none)` immediately followed by
`BLOCKED:` with no elision marker, but `renderStatus` always emits the `working tree observation:`
line there for `resume` too (`writeDerived` always supplies `dirty_count`). The line is silently
dropped rather than misstated, and 12.1/12.2 both show it correctly.

## Q3 — Is anything fabricated?

No. Every reason string quoted in S3 (`base_commit_mismatch`, `run_already_initialized`,
`checkpoint_reason_invalid`, `receipt_verdict_not_pass`, `receipt_author_role_invalid`,
`receipt_self_authored`, `receipt_no_independent_review`, `receipt_evidence_hash_mismatch`,
`receipt_head_mismatch`, `derived_state_conflict`, `checkpoint_corrupt`, `blind_retry_forbidden`),
every flag, every command name, every JSON field and both quoted exit codes (`1`, `2`) exist in
`.tad/scripts/yolo-recovery.mjs`. I found no invented token. In particular S3 does **not** repeat the
fabricated `CONTRACT_FAIL` `result` value that appears in §11's preamble.

## Q4 — Was any pre-existing guide content deleted or reworded?

No. `git show --stat 3baa842e` (the S3 commit) is `271 insertions(+), 0 deletions(-)` on
`.tad/guides/yolo-recovery.md` and no other file. `git diff 1b704cb3 3baa842e` contains zero `-`
lines, so S3 is purely additive, appended at the end of the file as the task spec requires.

## Q5 — Controlled patch verification

Correct. `grep -Fxc` for
`- Runtime: Node built-ins only, no npm packages, no lockfile change. See the Command Reference section for per-command flags.`
returns **1** (guide L14); `grep -Fxc` for the un-patched original
`- Runtime: Node built-ins only, no npm packages, no lockfile change.` returns **0**; and `grep -n
'Runtime:'` matches only L14, ruling out a duplicate or a partially-applied survivor. The patch
itself was applied in the S2 commit (`1b704cb3`) and was untouched by S3.

independent: true
verdict: PASS
