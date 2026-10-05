# Independent slice review — interruption-a — S3 (`## 12. Worked Example`)

Reviewer model: claude-opus-5

Scope reviewed: `.tad/guides/yolo-recovery.md` lines 403–616, against
`.tad/scripts/yolo-recovery.mjs` (read in full) and the frozen spec
`.../phase1/dogfood/task.md` §"Slice S3 — Worked Example". Verification was static
**plus** a full end-to-end replay of the documented transcript in an isolated
throwaway git repo in my scratchpad (a copy of the script only — the reviewed
worktree was not touched; its `git status` is unchanged).

## Q1 — Does the section meet its slice spec in substance?

Yes. Heading is exactly `## 12. Worked Example` (line 403). The spec asks for
"a copy-pasteable shell transcript of one minimal run, from `init` through
`resume`, using clearly-marked placeholder paths", showing (a) what a checkpoint
looks like, (b) what a receipt-backed verify looks like, (c) what `resume` prints
back. All three are delivered, in order, across six sub-sections: 12.1 freeze →
12.2 `init` → 12.3 work + `checkpoint` → 12.4 receipt → 12.5 `verify` → 12.6
interruption + `resume`. Placeholders are consistently and clearly marked
(`<angle brackets>`, stated as a convention at line 406), and the section opens by
declaring `$WT`/`$RUN`, the `.tad/evidence/yolo/` run-root requirement, and the
`[...]` elision marker — so a reader knows exactly which tokens to substitute.

The strongest evidence for Q1 is that the transcript is *actually runnable*: I
executed it verbatim (substituting only the placeholders) and every stage worked
first time, including the hand-written receipt in 12.4, which validated and
advanced the slice. The `checkpoint` sub-section additionally carries the
conceptual point the guide needs it to carry ("A checkpoint is a **claim of
intent, not of progress**") and demonstrates it through the ownership handoff in
the status block. One judgement call: 12.3 shows the checkpoint as the *command
plus the resulting ledger rendering* rather than dumping `checkpoint.json`; given
the spec explicitly asked for "a shell transcript", that is the right reading and
is more useful to an operator.

## Q2 — Is every technical claim actually true against the CLI source?

Yes. I replayed the whole transcript live and diffed the real output against what
the guide prints; I also traced each construct back to the source. Well over five
items, spot-checked:

1. **Goal-file schema (12.1).** The eight required keys the example supplies —
   `run_id`, `goal_id`, `base_commit`, `goal`, `success`, `non_goals`,
   `forbidden_scope`, `oracle_path` — are exactly `cmdInit`'s required list
   (L814–818). Optional `slices[]` of `{id, statement}` matches L836 + the
   `goal_slice_malformed` shape check at L188–192. ✔live: `init` exit `0`.
2. **`base_commit` must equal HEAD, `oracle_path` must already exist (12.1).**
   Both are real preconditions (`base_commit_mismatch` L818–820, `oracle_missing`
   L822–823), and the example's ordering (write oracle → write goal → `init`)
   satisfies them. ✔live.
3. **The `init` status block (12.2).** Byte-for-byte structural match to
   `renderStatus` (L510–545): the `════════ YOLO RECOVERY STATUS (Phase 1,
   opt-in) ════════` banner, `RUN: demo   STATE: ACTIVE` (three spaces, as in
   source), `RUN DIR:`, the blank line, `GOAL:`, `HANDOFF REVISION: <path> @
   sha256 <hex>`, `WORKTREE: … (base X → latest observed Y)`, then
   `VERIFIED/UNVERIFIED/BLOCKED/OUTCOME_UNKNOWN/PENDING ACTION` each with
   two-space `(none)`, the `working tree observation: N uncommitted path(s) —
   observation only, never authority` line in its correct position inside
   UNVERIFIED, `LEGAL NEXT ACTION:` / `  WHY:` / `OWNER:` / `RESUME COMMAND:`, and
   the closing rule. ✔live — my run reproduced this exactly.
4. **The trailing JSON line (12.2 and 12.6).** Key order in the guide is
   `format, command, result, run_dir, state, reason, verified_slices,
   unverified_slices, blockers, legal_next_action, capsule_tokens` — the exact
   emission order of `finish()` (L1112–1130), with `legal_next_action` as
   `{action, why, owner}` (the source's own order). ✔live.
5. **`LEGAL NEXT ACTION` strings.** All three quoted strings are verbatim from
   `deriveLegalNextAction`: `Start slice S1: add section A` with why "all recorded
   slices before it are verified; this is the first unverified slice in the frozen
   plan" / owner `executor` (L440–447); the candidate string `Slice S1 is a
   CANDIDATE only. Obtain a Conductor PASS receipt (existing Gate/reviewer must
   pass first), then run verify --slice S1 --receipt <receipt.json>` with its why
   and owner `conductor` (L431–437); and `Start slice S2: add section B` after
   verification. ✔live, all three.
6. **Checkpoint rendering (12.3).** `  - S1  (checkpoint candidate,
   reason=candidate, next="obtain a Conductor receipt for S1")` matches L525
   including the double space after the slice id. The note that `--reason` also
   accepts `before-compact` and `before-stop` matches `CHECKPOINT_REASONS` (L48).
   ✔live.
7. **Receipt shape (12.4).** All twelve keys match `RECEIPT_REQUIRED` (L666–670)
   exactly, with nothing extra and nothing missing. Evidence entries carry
   `path`/`sha256`/`verdict: "PASS"` — the `verdict` field matters, since
   `checkEvidence` raises `receipt_evidence_not_pass` without it (L748) — and the
   review entry carries `independent: true`, required by L760–762. The claim
   "`executor_id` and `written_by_id` must differ, or `verify` refuses with
   `receipt_self_authored`" matches L727–729. ✔live: I built this receipt verbatim
   and `verify` accepted it, exit `0`.
8. **Verify rendering (12.5).** `  - S1  (receipt <repo-relative path>, head
   <verified-head>)` matches L523; the path really is repo-relative
   (`repoRel`, L761 / L924). "This is the only command that moves a slice into
   `VERIFIED`" is true — `'verified'` is appended only in `cmdVerify` (L919).
   ✔live.
9. **Resume output (12.6).** `RECOVERY PACKET: <abs>/recovery.md (<n> est. tokens,
   budget 2500)` matches L1088 with `CAPSULE_TOKEN_BUDGET = 2500` (L57); the
   trailing JSON shows `"command":"resume"`, `verified_slices:["S1"]`. The
   `derived_state_conflict` fallback and the bare `--rebuild-derived` flag match
   L1066 (`flags['rebuild-derived'] === true || === 'true'`). ✔live: I tampered
   with `checkpoint.json`, got `derived_state_conflict` at exit `1`, and
   `resume --rebuild-derived` repaired it at exit `0`.
10. **`RESUME COMMAND` line.** Repo-relative script path + absolute run dir matches
    `resumeCommand` (L502–507). ✔live.
11. **`$RUN` must live under `.tad/evidence/yolo/`.** Matches `RUN_ROOT_REL`
    (L56) + `resolveRunDir` (L153–158). The example never `mkdir`s `$RUN` itself,
    which is correct — `init` creates it (`fs.mkdirSync … recursive`, L843).

Minor (P3) imprecision, not a false claim: line 411 says "every relative path is
resolved against `$WT`". Mechanically, `realpathDeepest` resolves against
`process.cwd()` (L122), not against the frozen worktree root. The transcript is
correct because it opens with `cd "$(git rev-parse --show-toplevel)"` and repeats
`cd "$WT"` in 12.4 and 12.6, and §11's `path_escape` remedy states the same
requirement explicitly — so the stated convention holds throughout the example and
no reader following it is misled.

## Q3 — Is anything fabricated?

**No.** Every command (`init`, `checkpoint`, `verify`, `resume`), every flag
(`--run`, `--handoff`, `--goal-file`, `--slice`, `--reason`, `--next`,
`--receipt`, `--rebuild-derived`), every reason string (`receipt_self_authored`,
`derived_state_conflict`), every format identifier
(`yolo-recovery-verification-v1`, `yolo-recovery-status-v1`), every JSON field and
every quoted output line exists in the source. The exit codes referenced (`0`, `1`)
are real. No invented output text: the status blocks are not paraphrases — they are
reproductions, which I confirmed by generating the real thing and comparing. The
only non-source strings are the deliberately marked placeholders
(`<your-epic>`, `<YOUR-HANDOFF>`, `<64-hex>`, `<n>`, `$WT`, `$RUN`) and the
illustrative identifiers `exec-a1` / `conductor-blake-t2`, which the surrounding
prose plainly presents as example values.

## Q4 — Was any pre-existing guide content deleted or reworded?

**No.** `git diff --numstat 323c380d..HEAD` reports `306 0
.tad/guides/yolo-recovery.md` — 306 insertions, **zero** deletions, one file
changed. The S3 commit `039f68c2` is `+217/-0`, purely appended after §11. §§1–11
and the CLI, tests, task spec and all config are untouched.

## Additional structural check

Section 12 contains 24 code-fence markers — 12 balanced pairs (`bash`×6,
`text`×4, `json`×1, plus the goal-file heredoc block), and the whole file's fence
count is 36, i.e. even. Sub-headings run 12.1→12.6 with no gaps or repeats. The
`<<EOF` heredoc in 12.1 is deliberately unquoted so `$(git rev-parse HEAD)` and
`$(dirname "$RUN")` expand — which is required for the example to work, and does.

independent: true
verdict: PASS
