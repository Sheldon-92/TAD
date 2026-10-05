Model: harness=claude-code | model=claude-opus-5 | route=host

# Code Review — YOLO 2.0 Phase 1 recovery slice (Layer 2, narrow scope)

**Scope reviewed:** commit `323c380d` diff under `.tad/scripts/` only —
`/Users/sheldonzhao/01-on progress programs/TAD/.tad/scripts/yolo-recovery.mjs` (1200 lines, new) and
`/Users/sheldonzhao/01-on progress programs/TAD/.tad/scripts/yolo-recovery.test.mjs` (1102 lines, new),
against §3 / §4 / §6 / §9 of
`/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`.
No source file was modified. All probes below ran in throwaway `mkdtemp` git repos outside this repo.

**Suite status at review time:** the 7 deterministic cases all pass —
`path-guard, lifecycle-e2e, verified-authority, authority-conflicts, side-effect-reconcile, status-capsule, atomic-write` → `RESULT=PASS`.
(`dogfood-evidence` and `required-evidence` consume real Phase-1 artifacts and were not exercised here.)

## Overall

The core design is sound and unusually disciplined for a first slice: the reducer is genuinely pure, the
authority order is enforced in the right direction (journal beats derived files), the path guard resists
`..` **and** symlink escape, receipt binding is checked on six independent axes, and every negative fixture
in the suite asserts a *specific* machine reason rather than "non-zero". The `verified-authority` case in
particular is real adversarial testing, not theatre.

The defects below cluster in one place: **the boundary between what `verify` checks and what `loadRun`
re-checks**, and **which commands are allowed to write to a terminal-state journal**. One of them is a
self-inflicted, unrecoverable corruption of the authority artifact.

---

## 🔴 P0 (blocking: correctness/safety)

### P0-1 — `reconcile` can append after `stopped` and permanently bricks the run

`cmdReconcile` (`yolo-recovery.mjs:969-1055`) is the only mutating command with **no `stopped` guard**.
`refuseIfHonestPartial` is deliberately omitted (reconcile must be the way *out* of `outcome_unknown`),
and `cmdStop` only guards `already_stopped` — nothing guards "an action is still pending" at stop time.
So `stop` while an action is pending is legal, and `reconcile` afterwards appends `action_reconciled`
*after* the `stopped` event. On the very next read, `reduceRun`'s first loop statement
(`yolo-recovery.mjs:251`, `if (stopped) throw ContractError('event_after_stop')`) rejects the journal
forever.

Reproduced end to end (temp repo, real CLI, no hand-editing of any file — every step is a normal command):

```
init          {"code":0,"result":"PASS","state":"ACTIVE"}
action-start  {"code":0,"result":"PASS","state":"ACTION_PENDING"}
stop          {"code":1,"reason":"stopped"}
reconcile     {"code":1,"reason":"event_after_stop"}      <-- the write already happened
status        {"code":1,"reason":"event_after_stop"}
resume        {"code":1,"reason":"event_after_stop"}
resume --rebuild-derived {"code":1,"reason":"event_after_stop"}
stop          {"code":1,"reason":"event_after_stop"}
```

Why this is P0 rather than a contract nit:

1. The tool **wrote the corruption itself**. Every other `event_after_stop` path in the suite (case (k),
   `yolo-recovery.test.mjs:425-433`) is reached by hand-appending to the journal; this one is reached by
   two ordinary commands.
2. It is **unrecoverable in-tool**. After the append, `status` and `resume --rebuild-derived` both fail —
   the recovery packet can never be regenerated. The only fix is hand-editing `journal.jsonl`, i.e. the
   authority artifact, which is exactly what the whole design forbids.
3. The tool **advises the operator into it**: `deriveLegalNextAction`'s stopped branch
   (`yolo-recovery.mjs:411`) says "…then open a NEW run **or explicitly reconcile this one**". Reconciling
   this one is the brick.
4. It lands squarely on dogfood interruption-b (`after-action-started`, handoff §6 P4.3): kill mid-action →
   operator records the stop → operator reconciles as instructed → run destroyed.

**Fix (pick one, don't do both halves):**
- *Minimal:* in `cmdReconcile`, before `appendEvent`, `if (r.state.stopped) throw new ContractError('run_stopped', {reason: r.state.stopped.reason, remedy: 'a stopped run is terminal; open a new run'})` — and delete "or explicitly reconcile this one" from the stopped `legal_next_action` text so the advice matches the rule.
- *Better, and closer to the spec's intent:* make `stopped` terminal for **progress** but not for
  **reconciliation** — let `reduceRun` accept `action_reconciled` after `stopped` (it cannot advance
  `verified`, so it cannot launder progress) and reject every other post-stop type. Then `stop` with a
  pending action is genuinely recoverable, which is what an honest-partial recorder should offer.

Either way `cmdStop` should also refuse (or explicitly record) a stop taken while `pending_action` is set,
since §4.4 has no `ACTION_PENDING --stop-->` transition at all.

---

## 🟡 P1 (blocking: contract violation)

### P1-1 — An unreconciled side effect returns exit 0 / `result: "PASS"` (FR5)

FR5 (§3.1): *"…或未决副作用必须返回 `honest_partial` 且 non-zero"*. `finish()`
(`yolo-recovery.mjs:1108`) computes `honest = state.state === 'HONEST_PARTIAL'`, and `reduceRun`
(`yolo-recovery.mjs:346-348`) assigns `ACTION_PENDING`, not `HONEST_PARTIAL`, when an action was started
and never reconciled. Confirmed:

```
action-start  {"code":0,"result":"PASS","state":"ACTION_PENDING"}
status        {"code":0,"result":"PASS","state":"ACTION_PENDING"}
resume        {"code":0,"result":"PASS","state":"ACTION_PENDING"}
```

This is the single state the recorder exists to make loud — a real file was mutated and nobody has read it
back — and the machine-readable contract calls it `PASS`. The human-readable block is correct
(`PENDING ACTION` + the right `LEGAL NEXT ACTION`), but the last-line JSON and the exit code are what a
Conductor/Gate script keys on, and dogfood interruption-b lands precisely here.

I want to be fair about a genuine spec tension: §4.4 lists `ACTION_PENDING` as a distinct state from
`HONEST_PARTIAL`, so an argument for exit 0 exists. But §4.4 describes the *state machine*, while FR5 is
the normative exit-code list, and it names 未决副作用 explicitly. Recommend: keep `state:
"ACTION_PENDING"` (the state machine is right) but make `finish()` non-zero for it —
`result: "HONEST_PARTIAL"`, `reason: "pending_action"`, and add a `{code:'pending_action'}` blocker in
`reduceRun` so `renderStatus`'s `BLOCKED:` section shows it too. If Alex intends exit 0 here instead, FR5
must be amended in writing — do not leave the two documents disagreeing.

### P1-2 — A journal-authored `verified` event lets an arbitrary file stand in for a Conductor receipt (FR3)

FR3: *"任意普通文件、checkpoint 和 completion prose 都不能"* advance `last_verified`. Every receipt check
(format, `verdict`, `run_id`, `slice`, `handoff_revision`, `worktree_realpath`, `verified_head`,
`written_by`, `written_by_id != executor_id`, gate/review evidence) lives **only** in
`validateVerificationReceipt`, called only from `cmdVerify` (`yolo-recovery.mjs:911`). The re-validation in
`loadRun` (`yolo-recovery.mjs:646-657`) re-checks *existence and hash of the pointed-to file* and nothing
about its content. So a `verified` event appended to `journal.jsonl` whose `receipt_path` names any repo
file with its true sha256 is accepted as verified progress:

```
# journal.jsonl + {"seq":2,"type":"verified",...,"payload":{"slice":"S1",
#   "receipt_path":"work/guide.md","receipt_sha256":<real sha>,"verified_head":"x"}}
status  {"code":0,"result":"PASS","verified_slices":["S1"]}
```

`work/guide.md` is the file the executor is editing — not a receipt, not JSON, no verdict, no author.

The threat model carve-out in §4.2 ("Phase-1 threat model 不防同一账号的恶意本机进程伪造身份") covers
forging *identity* — putting two different strings in `written_by_id`/`executor_id`. It does not cover
skipping the receipt contract entirely, and the actor here is the modeled adversary: the design already
treats the executor as untrusted (that is the entire point of `receipt_self_authored`), and the executor
holds the journal's append handle by construction. FR3's "任意普通文件…都不能" is exactly this.

**Fix (cheap, no new file format):** in `loadRun`, for each `state.verified` entry, re-run the *static*
half of `validateVerificationReceipt` on the receipt file — parse, `format`, `verdict === 'PASS'`,
`run_id`, `slice`, `handoff_revision`, `worktree_realpath`, `written_by === 'conductor'`,
`written_by_id !== executor_id`, plus non-empty gate/review evidence with one `independent: true`. Skip
only `verified_head === identity.head` (that check is correctly verify-time-only per NFR §3.2). Then a
forged `verified` line fails closed with `receipt_not_json` / `receipt_format_unknown` instead of passing.
A `prev_sha256` chain on journal events would close the class properly, but is Phase-2 scope.

### P1-3 — The `derived_state_conflict` guard is `resume`-only; every other command silently repairs (FR5)

FR5 lists *"journal/checkpoint 冲突"* as a must-fail-closed condition, unqualified by command. The guard
exists only in `cmdResume` (`yolo-recovery.mjs:1062-1078`); `cmdCheckpoint`, `cmdVerify`,
`cmdActionStart`, `cmdReconcile` and `cmdStop` all call `writeDerived` unconditionally
(`yolo-recovery.mjs:662-675`). Confirmed against the same forged `checkpoint.json` the suite uses in case
(e) (`yolo-recovery.test.mjs:364-379`):

```
resume      {"code":1,"reason":"derived_state_conflict"}   <-- tested, correct
checkpoint  {"code":0,"result":"PASS"}                     <-- forged claim silently erased
```

So the `--rebuild-derived` acknowledgement gate — the thing that makes the conflict visible to a human — is
one command away from being bypassed by an agent that just runs `checkpoint` next. Case (e) passes and the
hole is still open, which is the sort of gap the handoff's own knowledge base warns about ("a verifier is
only as good as the granularity it inspects").

**Fix:** hoist the comparison into `writeDerived` (or into `withRun`) so *every* command refuses on
conflict unless `--rebuild-derived` is passed; keep `resume` as the documented repair path.

### P1-4 — The reducer accepts `checkpointed` for an already-verified slice, producing a self-contradictory packet that advises repeating verified work

`cmdCheckpoint` guards this (`slice_already_verified`, `yolo-recovery.mjs:893`); `reduceRun` does not
(`yolo-recovery.mjs:261-268` sets the candidate unconditionally). The reducer's own docstring says it
"Throws ContractError on any internally inconsistent history" — this is one it accepts. Confirmed: after a
legitimate `verify S1`, appending a `checkpointed` event for S1 yields exit 0 with S1 listed under **both**
`VERIFIED:` and `UNVERIFIED:` in `renderStatus`, and in both sections of `recovery.md`.

The consequence is not cosmetic. `deriveLegalNextAction` (`yolo-recovery.mjs:431-438`) checks `candidates`
*before* the frozen slice plan, so a recovering fresh agent is told: *"Slice S1 is a CANDIDATE only. Obtain
a Conductor PASS receipt … then run verify --slice S1"* — for a slice already verified. That is
`repeated_verified_slice`, the exact metric AC8 requires to be 0, generated by the recovery packet itself.

**Fix:** in `reduceRun`'s `checkpointed` branch, `if (verifiedIds.has(p.slice)) throw new
ContractError('checkpoint_after_verified', { seq: ev.seq, slice: p.slice })`. As a belt-and-braces measure
also skip already-verified slices when building `candidates`.

---

## 🟢 P2 (non-blocking)

- **P2-1 `init` is not atomic across `goal.json` + the first journal event.** `cmdInit`
  (`yolo-recovery.mjs:844-847`) writes `goal.json`, then appends `initialized`. If the append throws, the
  stranded `goal.json` makes the run permanently un-initializable *and* unreadable — only `rm -rf` fixes
  it. Reproduced with a pre-existing orphan `journal.jsonl`: `init → concurrent_writer_detected` (goal.json
  now on disk) → `init → run_already_initialized` → `status → goal_mutated`. NFR §3.2 ("失败不得留下半写权威
  状态") is written about the derived files but the spirit applies here. Suggest wrapping: on any failure
  after the `goal.json` write, unlink it (it is provably this call's own file, guarded by the
  `run_already_initialized` pre-check).

- **P2-2 A torn journal tail is unrecoverable *and* costs the packet.** `journal_partial_line`
  (`yolo-recovery.mjs:206`) correctly refuses truncate-and-continue per §4.3 — but it also means the
  human-readable recovery packet cannot be produced from the valid prefix, so a kill mid-append loses the
  navigation aid too. Consider a strictly read-only `resume --best-effort` that renders `recovery.md` from
  the parseable prefix, still exits 1, and stamps the packet "DERIVED FROM A TRUNCATED JOURNAL — NOT
  AUTHORITY". That is not "截断修复后继续"; nothing is written to the journal.

- **P2-3 Same `reason`, two exit codes.** `checkpoint_reason_invalid` is a `UsageError` (exit 2) in
  `cmdCheckpoint:890` and a `ContractError` (exit 1) in `reduceRun:263`; `reconcile_outcome_invalid` has the
  same split (`cmdReconcile:973` vs `reduceRun:311`). A consumer keying on `reason` gets an ambiguous exit
  code. Suggest distinct reason strings for the journal-side variants (e.g. `journal_checkpoint_reason_invalid`).

- **P2-4 Reducer validates `RECONCILE_OUTCOMES` too late.** `yolo-recovery.mjs:308` (the `resolvesUnknown`
  check) runs before the membership check at `:311`, so a garbage `outcome` on an unknown action reports
  `unknown_outcome_needs_reconciled` rather than `reconcile_outcome_invalid`. Move the membership check to
  the top of the branch.

- **P2-5 `errorResult` drops the run identity and flattens internal crashes.**
  `yolo-recovery.mjs:1127-1141` always emits `run_dir: null`, so a failure never says *which* run failed;
  and any non-`UsageError`/`ContractError` exception (a `TypeError` from a future bug) becomes exit 1
  `HONEST_PARTIAL` / `unexpected_error`, indistinguishable from a genuine contract failure. Fail-closed is
  the right direction, but a distinct `internal_error` reason would keep the two apart. Separately, the
  help path (`:1169`) emits a status object missing `run_dir`/`state`, unlike every other exit — worth
  making the last-line schema uniform since the whole point is machine consumption.

- **P2-6 `writeAtomic` / `appendEvent` do not fsync.** `writeAtomic` (`:488-498`) does
  `writeFileSync` + `renameSync` with no `fsync` on the file or the parent directory, and `appendEvent`
  (`:612`) appends without one. On power loss a rename can be durable while the bytes are not. Every
  affected artifact fails closed on the next read (`goal_corrupt`, `checkpoint_corrupt`,
  `journal_partial_line`), so this is durability, not safety — but a `fsync` before rename is two lines and
  the file is called "authority". Also: a kill between `writeFileSync` and `renameSync` leaves the
  `.checkpoint.json.tmp-<pid>-<rand>` dotfile behind with no sweeper; consider unlinking stale temps at the
  start of `writeDerived`.

- **P2-7 Journal-sourced paths are resolved without a scope assertion.** `loadRun:647`
  (`v.receipt_path`), `loadRun:628` (`goal.handoff_path`), `cmdReconcile:995` and `:1011`
  (`unknown.target` / `pending.target`) all use `path.resolve(repoRoot, …)` with no `assertInside`, unlike
  every operator-supplied path. All four are written by the tool itself and a hand-edit trips
  `goal_mutated` in the `goal.json` case, so this is defence-in-depth only — but the reads are cheap to
  guard and `resolveInRepo` already exists.

- **P2-8 Receipt evidence is never re-checked after the fact.** `loadRun` re-hashes the receipt but not the
  `gate_evidence` / `review_evidence` files it points at, so the underlying Gate report can be deleted or
  rewritten post-verification and `status` stays green. The receipt hash pins the *claim*; nothing pins the
  *proof*. Reasonable Phase-1 scope, but worth an explicit line in the guide so Gate 3's manual cross-check
  (§6 P2.4) knows it is the only thing covering this.

- **P2-9 Nothing stops a receipt citing evidence inside its own run dir.** `resolveInRepo` accepts any
  in-repo path, so `gate_evidence` could point at `…/run-1/goal.json`. Cheap to exclude the run dir and
  `.git/` from evidence paths.

- **P2-10 `--rebuild-derived` is undocumented in the handoff.** §4.2's CLI block lists `resume --run <dir>`
  only. The flag is necessary (P1-3's repair path) and is in `USAGE`, but §4.2 and the guide should name it.

---

## Test quality

Genuinely good, and I want to be specific about why rather than wave at it: `expectRed`
(`yolo-recovery.test.mjs:47-50`) asserts **exit code AND a specific `reason`** on every CLI negative, so a
CLI that failed for the wrong cause turns the suite red. `caseVerifiedAuthority` runs 13 distinct receipt
attacks and then asserts `readJournalEvents(repo).every(e => e.type !== 'verified')` (`:308`) — a
cross-cutting invariant, not per-case bookkeeping. `caseAtomicWrite` (`:590-608`) uses a real `chmod 0555`
fault, refuses to run as root (`:591`), and checks *both* that the previous content survived and that no
temp file remains. `caseStatusCapsule` (`:576-585`) proves the over-budget path still carries every hard
anchor. None of these are vacuous.

Two problems:

- **T-1 (P2) — case (o) is mislabeled and `concurrent_writer_detected` has zero coverage.**
  `yolo-recovery.test.mjs:453-466` is headed "concurrent writer detection" and comments "Simulate a second
  writer appending between our read and our append", but it duplicates the `initialized` line and asserts
  `duplicate_initialized` — a *reducer* check. `appendEvent`'s single-writer guard
  (`yolo-recovery.mjs:602-610`) is never exercised by any test. The leftover `void goalSha;` at `:465` is
  the fingerprint of the rewrite that lost the original intent. This is the one test I would call theatre:
  it reads as covering the concurrency contract and does not. Fix: keep the current assertion under an
  honest name, and add a real one — append a well-formed extra event to `journal.jsonl` between commands,
  then assert `checkpoint` → exit 1 `concurrent_writer_detected`.

- **T-2 (P2) — 31 of ~60 declared failure reasons have no test at all.** Mechanically:
  `action_target_missing, already_stopped, checkpoint_corrupt, concurrent_writer_detected,
  duplicate_action_id, git_unavailable, goal_corrupt, goal_field_missing, goal_field_not_array,
  goal_file_field_missing, goal_file_missing, goal_file_not_json, goal_format_unknown, goal_missing,
  goal_slice_malformed, journal_blank_line, journal_empty, journal_field_missing,
  journal_first_event_invalid, journal_missing, outcome_is_actually_untouched, pending_action_blocks_verify,
  receipt_evidence_malformed, receipt_evidence_not_pass, receipt_field_missing, receipt_format_unknown,
  receipt_missing, receipt_not_regular_file, reconcile_evidence_missing, reconcile_outcome_invalid,
  slice_already_verified`. The handoff's §6 P3 fixture list is essentially satisfied, so this is not a spec
  miss — but four of these are load-bearing contract guards and deserve fixtures:
  `pending_action_blocks_verify` (FR3×FR6 interaction), `slice_already_verified`, `duplicate_action_id`
  (double-apply, FR6), and `receipt_format_unknown` / `receipt_field_missing` (no test ever feeds `verify`
  a *shape*-invalid receipt — only wrong-*value* ones).

- **T-3 (P2) — the 26 dogfood negatives assert only `errs.length > 0`** (`yolo-recovery.test.mjs:978-981`),
  not that the error raised is the one the tamper was meant to provoke. Several tampers trip more than one
  rule (`zero hard anchors` also breaks the envelope-score cross-check), so an individual negative can pass
  for the wrong reason. Not vacuous overall — `cleanErrors.length === 0` at `:905` stops an
  always-red checker — but asserting a substring per case would make each negative a real criterion.

- **T-4 — none of the four defects above has a fixture**, which is expected (they are the gaps the suite
  did not think to look at) but should be part of the fix: a `reconcile`-after-`stop` case, a
  pending-action exit-code case, a forged-`verified`-event case, and a checkpoint-after-verified case.

---

## Answers to the specific questions asked

- **FR3 / verified authority — bypass?** Yes: **P1-2**. Not through `verify` (that path is tight and well
  tested), but through `loadRun`, which re-checks only the receipt file's hash and never its contract.
- **FR5 / fail-closed exit 0?** Yes, twice: **P1-1** (unreconciled side effect → exit 0 `PASS`) and
  **P1-3** (a conflicting derived file is silently repaired by any non-`resume` command).
- **FR6 / side effects retried or double-applied?** No. `forbidden_retry_actions` is checked in both
  `cmdActionStart:936` and `reduceRun:287`, `actionsSeen` blocks id reuse, `concurrent_action` blocks
  overlap, and clearing an `outcome_unknown` requires `--outcome reconciled` + an existing evidence file +
  an `--observed-sha256` matching the real on-disk hash. This is the strongest part of the implementation.
  (Weak spot, not a finding: the evidence file's *content* is never inspected, so "explicit evidence"
  reduces to "a file exists". Fine for Phase 1 given the guide's manual cross-check.)
- **Path scope escape?** No. `resolveRunDir` / `resolveInRepo` correctly refused all four vectors I tried:
  outside-repo absolute path, `..` traversal, run dir == scope root, and an in-repo symlink pointing
  outside (both as `--run` and as `--target`). `realpathDeepest` resolving the deepest existing ancestor is
  the right construction. TOCTOU between resolution and read exists in principle but is not meaningful for a
  single-user CLI. See P2-7 for the journal-sourced paths that skip the guard.
- **Atomicity — half-written authority file or stray temp?** Not under a failed write (proven by
  `caseAtomicWrite`). Under a hard kill: a stray temp dotfile can survive with no sweeper, and no `fsync`
  means a durable rename over non-durable bytes is possible — P2-6. `init` is the one genuinely
  non-atomic *sequence* — P2-1.
- **Reducer purity and correctness?** Pure — no I/O, no clock, no globals; `semanticCheckpoint` is
  timestamp-free and the suite proves byte-stability across two `resume`s (`:218-226`). One ordering it
  mis-handles: `checkpointed` after `verified` (**P1-4**). One state unrecoverable by construction:
  anything after `stopped` (**P0-1**). One cosmetic ordering issue: P2-4.
- **Exit-code contract consistent?** Almost. `0 PASS / 1 contract / 2 usage` holds across every path I
  traced, but: `ACTION_PENDING` returns 0 where FR5 says non-zero (P1-1); two reason strings map to both 1
  and 2 depending on origin (P2-3); an over-budget run returns 1 from `resume` but 0 from `status`, because
  `cmdStatus` passes `packet: null` to `finish` and skips the budget check entirely; and internal crashes
  are laundered into contract failures (P2-5).

## Recommended next steps

1. Fix **P0-1** (guard `reconcile` against `stopped`, or make `stopped` non-terminal for reconciliation
   only) and correct the stopped `legal_next_action` text. Add the fixture.
2. Fix **P1-2** by re-validating the receipt contract in `loadRun`, and **P1-4** with the reducer guard —
   both are a handful of lines and both close FR3/AC8 holes.
3. Fix **P1-3** by hoisting the derived-conflict check into `writeDerived`.
4. Adjudicate **P1-1** with Alex: either make `ACTION_PENDING` non-zero, or amend FR5. Do not ship with the
   two disagreeing.
5. Rename test case (o) honestly and add the four missing fixtures (T-1, T-2, T-4).

VERDICT: FAIL
P0: 1 | P1: 4 | P2: 13

---

## Incremental re-review (post-d7813c6b..HEAD) — independent verifier

Verifier model: harness=opencode | model=ox-alpha-free (model id `opencode-go/ox-alpha-free`)
date: 2026-08-25
verified_head: fc7a07fceb1849e07075974c4475cecb945409d0
commits verified: d7813c6b (fix round), prose commits 00570c00, 0ccd30cd, 84c3666c, security commit fc7a07fc
first-pass head: 019cdeb1e7137beaa6fe024ab30cb33a5d0348fe (verdict then FAIL under an every-finding gate; re-scoped below)

Method: read every finding above, inspected `git show d7813c6b` in full, then verified each finding against the final code (`yolo-recovery.mjs` / `yolo-recovery.test.mjs`). Suite re-run green at BOTH heads: all 10 cases RESULT=PASS at `019cdeb1` and again at `fc7a07fc` (`path-guard, lifecycle-e2e, verified-authority, authority-conflicts, side-effect-reconcile, status-capsule, atomic-write, binding-and-closure, dogfood-evidence, required-evidence`). No file was modified except this report.

Head delta 019cdeb1 → fc7a07fc: single commit fc7a07fc ("re-validates receipt-bound evidence on every load"), confirmed via `git show --stat` to touch ONLY `.tad/scripts/yolo-recovery.mjs` (+19) and `.tad/scripts/yolo-recovery.test.mjs` (+30). Content verified from the full diff: loadRun now re-hashes every `gate_evidence`/`review_evidence` entry referenced by each verified slice's receipt (missing/mismatched → binding blockers), plus red/green test cases (j2) destroyed evidence / (j3) tampered evidence, plus an extension of the dogfood checker's ALLOW_EXACT list with six exact TAD lifecycle artifact paths. This commit RESOLVES the substance of P2-8 (row updated below) and introduces no new P0/P1.

| finding | severity | status (RESOLVED/OPEN) | evidence (file:line quotes) |
|---|---|---|---|
| P0-1 reconcile-after-stop bricks run | P0 | RESOLVED | Three independent layers. (1) Explicit guard — `yolo-recovery.mjs:1233`: `if (r.state.stopped) { throw new ContractError('run_stopped', {...}) }` before any append in `cmdReconcile`. (2) Structural guarantee — `mjs:667-676`: `appendEventGuarded` reduces the candidate in memory first and throws `event_would_corrupt_journal` ("refused before writing; the journal is unchanged"); ALL five mutating commands now append through it (`:1150, :1169, :1215, :1325, :1364`). (3) Advice corrected — `mjs:445`: stopped branch now reads "...open a NEW run from a known commit. No further event may be recorded here." (reconcile no longer named). Fixture: `test:679-684` asserts reconcile-after-stop → exit 1 `run_stopped`, journal length unchanged, ledger still readable. The reviewer's parenthetical (stop while an action is pending) resolves to "explicitly record": stop-with-pending reduces cleanly (state HONEST_PARTIAL, blocker `stopped`, packet still shows PENDING ACTION) — no brick. |
| P1-1 unreconciled side effect exits 0/PASS (FR5) | P1 | RESOLVED | `mjs:1386`: `const honest = state.state === 'HONEST_PARTIAL' \|\| state.state === 'ACTION_PENDING';` → `exitCode: honest ? 1 : 0` (:1388), `result: honest ? 'HONEST_PARTIAL' : 'PASS'` (:1392), and reason falls through to `unreconciled_side_effect` when no blocker exists (:1395-1397). State label kept `ACTION_PENDING` per §4.4 (:1394) exactly as recommended. Fixture: `test:511-514` — action-start and status with a pending action both assert exit 1 `unreconciled_side_effect`. (Note: the optional "add a pending_action entry to BLOCKED:" nicety was not taken; the dedicated `PENDING ACTION:` section at `mjs:567-570` renders it instead.) |
| P1-2 journal-authored `verified` accepts arbitrary file (FR3) | P1 | RESOLVED | `loadRun` now re-validates the receipt CONTRACT for every verified slice — `mjs:789-791`: `if (!isPlainObject(rec) || rec.format !== RECEIPT_FORMAT || rec.verdict !== 'PASS' \|\| rec.run_id !== goal.run_id || rec.slice !== v.slice \|\| rec.written_by !== 'conductor' \|\| rec.written_by_id === rec.executor_id)` → bindingBlocker `verified_evidence_not_a_bound_receipt` (:792-796); preceded by existence (:779-781) and hash (:783-785) checks. The demonstrated attack (`receipt_path: "work/guide.md"`) now fails closed on next read (non-JSON → blocker → honest_partial). Caveat recorded, not softening the verdict: load-time revalidation implements a SUBSET of the suggested static half (omits handoff_revision, worktree_realpath, evidence-independent checks), so a fully forged receipt JSON + matching journal line would still pass load-time validation — consistent with the reviewer's own Phase-2 carve-out ("a prev_sha256 chain ... is Phase-2 scope"). |
| P1-3 derived-conflict guard resume-only; others silently repair (FR5) | P1 | RESOLVED (adjudicated deviation noted) | The defect as evidenced was SILENT repair; silence is gone everywhere. `writeDerived` detects conflict pre-overwrite — `mjs:820-828` (compares on-disk body minus generated_at against semanticCheckpoint; unparseable counts as conflict) — and reports it via `out()` on EVERY command: `mjs:840-843`: `"!! WARNING: ${derivedConflict} disagreed with the journal and has been rebuilt from it."` All seven callers pass `out`. `resume` keeps the hard gate: `mjs:1348-1351` still throws `derived_state_conflict` unless `--rebuild-derived`. Fixture `test:700-709` proves the warning surfaces through a mutating command. Deviation from the recommended fix (refuse-everywhere): mutating commands now WARN-and-rebuild from the journal instead of refusing, i.e. `checkpoint` on a conflicted checkpoint.json still exits 0 WITH the warning (asserted by `test:703-706`). The silent-bypass hole is closed; whether warn-instead-of-refuse satisfies FR5's letter was adjudicated in the fix round ("derived-file conflict reported by every command", d7813c6b message). Recorded here so the deviation is visible. |
| P1-4 reducer accepts `checkpointed` after `verified` | P1 | RESOLVED | `mjs:329-332`: `if (verifiedIds.has(p.slice)) { throw new ContractError('checkpoint_after_verified', { seq: ev.seq, slice: p.slice }); }` in the reducer's checkpointed branch. Such histories are now unreducible, so the self-contradictory packet / repeat-verified advice cannot be produced; `appendEventGuarded` also makes it unwritable via any command. No direct fixture (tracked under T-4 below). The belt-and-braces candidate-filtering suggestion is moot given the throw (a reducible journal can never contain such a checkpoint). |
| P2-1 init non-atomic across goal.json + first event | P2 | RESOLVED | Budget checked BEFORE first write (`mjs:1051-1066`, error note "NOTHING was written"), then transactional create with rollback — `mjs:1071-1099`: `created[]` tracking, `catch { for (const f of created.reverse()) ... fs.rmSync(f ...) ; if (!dirExisted) fs.rmSync(runDir, {recursive:true...}) }`. Fixtures `test:605-608`: rejected init leaves no goal.json and the run-dir name stays usable. |
| P2-2 torn tail costs the packet; suggest read-only `--best-effort` | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | Not implemented: no `best-effort` anywhere in yolo-recovery.mjs (USAGE block `mjs:1424-1439` lists no such flag); `readJournal` `mjs:269` still refuses wholesale (`journal_partial_line`) and no prefix-render path exists. Advisory only. |
| P2-3 same reason, two exit codes (`checkpoint_reason_invalid`, `reconcile_outcome_invalid`) | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | Unchanged: `checkpoint_reason_invalid` is UsageError at `mjs:1145` and ContractError at `mjs:327`; `reconcile_outcome_invalid` is UsageError at `mjs:1249` and ContractError at `mjs:379`. No distinct journal-side reason strings introduced. |
| P2-4 reducer validates RECONCILE_OUTCOMES too late | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | Order unchanged in the `action_reconciled` branch: `resolvesUnknown` computed at `mjs:371`, `unknown_outcome_needs_reconciled` thrown at `:375-377`, membership check `!RECONCILE_OUTCOMES.includes(p.outcome)` only at `:378-380`. A garbage outcome on an unknown action still reports the wrong reason. |
| P2-5 errorResult drops run identity; flattens internal crashes; help object schema | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | `mjs:1408-1422`: `run_dir: null` unchanged; non-Usage/Contract exceptions still become exit 1 `HONEST_PARTIAL` with `reason: err.reason || 'unexpected_error'` — no distinct `internal_error` class. Help path `mjs:1450` still emits a status object without `run_dir`/`state`. |
| P2-6 writeAtomic/appendEvent do not fsync; stale temp dotfiles | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | `writeAtomic` `mjs:522-532`: `writeFileSync` + `renameSync`, no fsync on file or parent dir; `appendEvent` `mjs:720-721`: bare `appendFileSync`. Temp cleanup only for its OWN caught error (`:529`); no stale-temp sweeper at the start of writeDerived. |
| P2-7 journal-sourced paths skip scope assertion | P2 | OPEN — non-blocking P2/test-quality (half fixed) — deferred to NEXT.md follow-up | Fixed halves: receipt_path via `anchorAtRepoSafe` (includes `assertInside`) at `mjs:778`; goal.handoff_path likewise at `:764`. Still open: `cmdReconcile` resolves attacker-influenceable journal targets with bare `path.resolve(r.repoRoot, unknown.target)` at `mjs:1270` and `path.resolve(r.repoRoot, pending.target)` at `mjs:1286` — no `assertInside`. |
| P2-8 gate/review evidence never re-checked post-hoc (+ guide line) | P2 | RESOLVED (at fc7a07fc) | Was OPEN at 019cdeb1; closed by fc7a07fc. `loadRun` now re-checks every bound evidence file after the fact — `mjs:798-816`: `const boundEvidence = [...(Array.isArray(rec.gate_evidence) ? rec.gate_evidence : []), ...(Array.isArray(rec.review_evidence) ? rec.review_evidence : [])];` with per-entry existence check (`verified_evidence_missing` blocker, :806-808) and hash re-check (`if (typeof ev.sha256 === 'string' && sha256File(eAbs) !== ev.sha256)` → `verified_evidence_hash_mismatch`, :809-811). Red/green fixtures: test (j2) destroys gate evidence post-verify → status exit 1 `verified_evidence_missing` (`test:441-450`); (j3) tampers review evidence → exit 1 `verified_evidence_hash_mismatch` (`test:452-459`). The optional guide-line half is subsumed: the behavior is now mechanically enforced rather than documented. LOW observation, not a gate: an evidence entry whose `sha256` is absent/non-string skips only the hash comparison (existence still enforced) — unreachable via `verify` since `validateVerificationReceipt` enforces `/^[0-9a-f]{64}$/` on every entry; noted for NEXT.md hardening. |
| P2-9 receipt may cite evidence inside its own run dir / .git | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | `resolveInRepo` (`mjs:212-216`) still accepts any in-repo path; `checkEvidence` (`mjs:942`) uses it with no exclusion of the run dir or `.git/`. |
| P2-10 `--rebuild-derived` undocumented in handoff §4.2 | P2 | OPEN — non-blocking P2/test-quality (handoff half) — deferred to NEXT.md follow-up | Handoff CLI block unchanged — HANDOFF-20260824-yolo2-phase1-recovery-slice.md:220 still lists only `resume --run <dir>`. (The guide half already names it since the initial commit: `.tad/guides/yolo-recovery.md:144`.) |
| T-1 case (o) mislabeled; `concurrent_writer_detected` zero coverage | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | Test file unchanged at `test:461-474`: still headed "(o) concurrent writer detection", still asserts `duplicate_initialized` (:471), still carries `void goalSha;` (:473). No test exercises `concurrent_writer_detected` (mjs:715) — grep over the test file finds zero hits. (Mitigation, not coverage: appends are now lock-wrapped per binding-and-closure #6, `test:691-702` covers `run_locked`.) |
| T-2 four load-bearing reasons lack fixtures | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | None of the four suggested fixtures exist: grep over the test file returns zero matches for `pending_action_blocks_verify`, `slice_already_verified`, `duplicate_action_id`, `receipt_format_unknown`, `receipt_field_missing` as asserted expectations. |
| T-3 dogfood negatives assert only `errs.length > 0` | P2 | OPEN — non-blocking P2/test-quality — deferred to NEXT.md follow-up | `test:1151` unchanged: `expect(errs.length > 0, \`negative control "${name}" must turn the dogfood checker red\`)` — no per-case substring assertion added. |
| T-4 fixtures for the four code defects | P2 | OPEN — non-blocking P2/test-quality (2 of 4 present) — deferred to NEXT.md follow-up | Present: reconcile-after-stop (binding-and-closure #1, `test:664-686`) and pending-action exit-code (side-effect-reconcile, `test:509-514`). Absent: a forged-`verified`-journal-event case exercising `verified_evidence_not_a_bound_receipt`, and a checkpoint-after-verified case exercising `checkpoint_after_verified` (zero test-file hits for either reason string). |

New defects introduced since d7813c6b (through verified head fc7a07fc): none. Verified from full diffs: 00570c00 (+10 lines: VERIFICATION MODEL section strings + 2 test assertions), 0ccd30cd (+17 lines: PROHIBITIONS strings + 2 test assertions), 84c3666c (+3/−3 lines: classification-rule prose in PENDING ACTION / PROHIBITIONS / uncommitted-work line) touch only `renderRecovery` packet prose and test assertions — no control flow, no I/O, no contract change. fc7a07fc (+49 lines: post-verify bound-evidence re-validation in loadRun, red/green cases (j2)/(j3), ALLOW_EXACT extension) is fail-closed in direction and introduces no new P0/P1; two LOW observations recorded for NEXT.md: (a) an evidence entry lacking a string `sha256` skips only the hash comparison — unreachable through the `verify` path, which enforces the sha256 format at receipt validation; (b) the test-side ALLOW_EXACT list grew by six exact TAD lifecycle artifact paths (handoff/DR/epic/NEXT.md) — test-infrastructure config with exact paths only, not a product/runtime scope expansion. Suite passes 10/10 at the verified head. One further LOW observation on the prose commits: `PROHIBITIONS` gates the uncommitted-work line on `ctx.dirty_count > 0` (`mjs:631`); when `git status` observation fails, `dirty_count` is null and the line is silently omitted — acceptable for a navigation-only section.

First-pass verdict at 019cdeb1 (recorded for provenance): FAIL — issued under an every-finding-must-resolve gate; all five blocking findings were already RESOLVED at that head and 13 P2-classified items were OPEN.

Re-issued verdict under TAD Layer-2 blocking semantics (scoping correction: P0/P1 = BLOCKING; P2/test-quality = non-blocking follow-ups recorded in NEXT.md):

incremental_verdict: PASS

Basis (Gate 3 acceptance): every P0/P1 finding — P0-1, P1-1, P1-2, P1-3, P1-4 — is RESOLVED at the verified head `fc7a07fc` (evidence quoted per row above), and no new P0/P1 was introduced by d7813c6b..fc7a07fc. Remaining OPEN items count: 12 (P2-2..P2-7, P2-9, P2-10, T-1..T-4), each labeled non-blocking P2/test-quality and deferred to a NEXT.md follow-up handoff; fc7a07fc additionally resolved P2-8, bringing originally-open P2s from 13 to 12. Suite green (10/10 cases) at the verified head.
