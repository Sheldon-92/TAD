Model: harness=claude-code | model=claude-opus-5 | route=host

# Architecture Review — YOLO 2.0 Phase 1 Recovery Slice

Reviewer scope: `.tad/scripts/yolo-recovery.mjs`, `.tad/guides/yolo-recovery.md`,
HANDOFF-20260824-yolo2-phase1-recovery-slice.md §1.3 / §3 / §4 / §7 / §10.
Architecture only — no style findings. All claims below were reproduced against
throwaway fixture repos in the session scratchpad; the TAD repo was not modified.

---

## 1. Authority model — enforced, not merely asserted

The stated order (approved handoff + immutable `goal.json` > journal + evidence
pointers > `checkpoint.json` > `recovery.md`/session-state) **is enforced by code**.
I could not find a path where a lower level wins.

| level | enforcement site | verdict |
|---|---|---|
| 1 goal immutability | `loadRun` → `events[0].payload.goal_sha256 !== goalSha` → `goal_mutated` (`yolo-recovery.mjs:638`) | enforced every command |
| 1 handoff revision | `loadRun` → `sha256File(handoff) !== goal.handoff_revision` → `handoff_revision_drift` (`:631`) | enforced every command |
| 1 worktree identity | `goal.worktree_realpath !== identity.worktree_realpath` (`:622`) | enforced every command |
| 2 journal | `readJournal` fails on partial line, blank line, seq break, unknown type, missing envelope field (`:232-264`) | fail-closed |
| 2 evidence pointers | `loadRun` re-hashes every verified slice's receipt (`:646-657`) | enforced every command |
| 3 checkpoint.json | read **only** in `cmdResume`, and only to refuse (`:1062-1078`); state always comes from `reduceRun` | never a source |
| 4 recovery.md | write-only (`:673`); never read | never a source |
| 4 session-state / PreCompact | zero references outside comments (grep confirms lines 12/18/554/588 are prose only) | never touched |

Reproduced: a `checkpoint.json` hand-edited to claim `S1` verified is discarded —
`verified_slices` stays `[]`, `unverified_slices` stays `["S1"]`. The derived file
never promotes itself.

**Second-writer hazard: none.** `recovery.md`, `session-state.md` and the PreCompact
snapshot are not writers and not authorities anywhere in this code.

One prose over-claim, filed as P2-1 below: the guide's general statement "it stops
and reports the conflict" is true only for `resume`.

## 2. Blast radius — clean

`git diff --name-only 323c380~1..HEAD`:

```
.tad/guides/yolo-recovery.md
.tad/scripts/yolo-recovery.mjs
.tad/scripts/yolo-recovery.test.mjs
```

3 files, +2612/-0, all inside `.tad/scripts/` and `.tad/guides/` as §7.1 requires.
Grep of the changed set for `workflow|hooks|settings|package|lock|tad.sh|SKILL`
returns nothing. The live `yolo-epic` workflow, the Gates, the PreCompact hook,
config, installer and lockfiles are untouched.

Working tree also carries `M NEXT.md` plus 4 untracked process artifacts
(the Epic, this handoff, 2 DRs). None is in the forbidden set; all are TAD
process documents, not product/runtime. No blast-radius finding.

## 3. Scope discipline — inside the line

Not a general workflow kernel, event-sourcing engine or sandbox in disguise:
6 fixed event types, one aggregate, one file, no hash chain, no fencing token,
no subscriptions, no replay-to-version API, no plugin loader, no eval/vm, no
state-machine DSL, no config surface. It is a purpose-built ledger with a pure
reducer — structurally event-sourcing-*shaped*, which is unavoidable for the
stated job, but it does not generalise. `deriveLegalNextAction` (`:408-460`)
embeds a little workflow policy, but in 5 fixed branches with no configuration.
Watch item, not a violation. (See P2-5 on export surface.)

---

## P0-1 — `reconcile` after `stop` writes an event that permanently bricks the ledger, and the tool's own next-action text recommends doing it

`refuseIfHonestPartial` guards `checkpoint`, `verify` and `action-start`.
`cmdReconcile` (`:969`) has no such guard — correctly, because reconcile must work
while `HONEST_PARTIAL` (that is its purpose). But it also has no `stopped` guard.
So after `stop`, a reconcile of a still-open `outcome_unknown` action passes every
CLI check, calls `appendEvent` (`:1050`), **writes the event**, and only then does the
post-write `loadRun` hit `reduceRun`'s `event_after_stop` (`:284`).

The journal — the level-2 authority, append-only, and per guide §8 explicitly
never to be hand-repaired — now contains an unreducible event. Reproduced:

```
--- reconcile AFTER stop ---   reason: event_after_stop (event was written, seq 5)
--- status  ---> event_after_stop
--- stop    ---> event_after_stop
--- resume  ---> event_after_stop
```

Every command is dead. There is **no legal next action at all** and no operator
escape inside the tool.

This is not a hypothetical operator error. The state's own derived guidance
invites it verbatim:

> `legal_next_action`: "Do NOT continue. Resolve the recorded stop reason with the
> human, then open a NEW run **or explicitly reconcile this one**."

`deriveLegalNextAction`'s `stopped` branch (`:409-415`) names the exact command that
destroys the ledger.

The test suite reaches `event_after_stop` only by hand-appending a line to
`journal.jsonl` (`yolo-recovery.test.mjs:428-432`), i.e. it proves the *reducer*
rejects the corruption — never that the CLI refuses to *create* it. The gap is
untested.

**Fix:** add an explicit `if (r.state.stopped) throw ContractError('run_stopped', …)`
at the top of `cmdReconcile`, before `appendEvent`; and remove "or explicitly
reconcile this one" from the stopped branch of `deriveLegalNextAction` (or make it
name a real, legal command). More generally: **no command may append an event that
`reduceRun` would reject** — the cheapest structural guarantee is to run the
candidate event through `reduceRun` in memory *before* `appendEvent`, and refuse
on throw. That closes this whole class, not just this instance.

## P0-2 — A binding failure locks out `status` and `stop`, so the run can never be honestly closed; the most likely trigger is a normal handoff amendment

Every identity/evidence guard lives in `loadRun`, and `withRun` routes *all eight*
commands through it. There is no read-only diagnostic path and no honest-closure
path that survives a binding failure. Reproduced, all four commands, from a single
appended line to the handoff:

```
$ echo "## 9.2 Expert Review Status: added later" >> handoff.md
status     -> handoff_revision_drift
resume     -> handoff_revision_drift
stop       -> handoff_revision_drift   <-- cannot even record the truth
checkpoint -> handoff_revision_drift
```

There is no `reaffirm`, no `--accept-revision`, no `--force`, no read-only mode.
The only escape is out-of-band: restore the handoff to byte-identical content.
**For this very run that may be impossible — the handoff is untracked
(`?? .tad/active/handoffs/HANDOFF-20260824-…md` in `git status`), so git holds no
copy to restore from.**

Handoff amendment is not an edge case in TAD: §9.1 Spec Compliance rows, §9.2
Expert Review Status, Audit Trail rows and sanctioned degradation records are all
written into the handoff *during* the work this ledger is supposed to survive.
The guard treats a normal process action as unrecoverable corruption.

Two further confirmed triggers of the same total lockout:

- **Worktree relocation.** Renaming/moving the worktree directory (restore from
  backup, a different mount, machine migration — exactly the post-disaster
  situations a recovery tool exists for) gives `worktree_identity_mismatch` on
  `status` *and* `stop`. Reproduced.
- **A one-byte change to a receipt file.** `loadRun:646-657` re-hashes every
  verified slice's receipt on every command. The project's own test (j)
  (`yolo-recovery.test.mjs:415-423`) appends a single `\n` to a receipt and asserts
  `status` fails. Correct that the *slice* is no longer verified — but the chosen
  implementation kills the *whole run*, including `stop`. An editor adding a
  trailing newline, or an evidence-directory reorg, is enough.

For contrast, the design gets the *other* identity question right: **normal commits
after `init` correctly trip nothing** (base HEAD is validated at init only; later
events merely record `observed_head`). Verified. The defect is not over-binding of
HEAD; it is that every binding failure is routed to the same total-lockout outcome.

**Fix (three parts, all small):**
1. `status` must degrade, not die: report the binding failure as a blocker and still
   print goal + verified/unverified + owner from `goal.json` + `journal.jsonl`.
2. `stop` must always be able to record the truth — recording "this run was
   abandoned because the handoff drifted" is precisely the honest-partial behaviour
   the design is built around.
3. Freeze a copy of the approved handoff into the run dir at `init`
   (`handoff-frozen.md`) and compare against **that**, so the run owns its own
   authority instead of depending on an external mutable file. Optionally add a
   recorded `reaffirm --handoff-revision <sha> --reason <text>` event so a
   legitimate amendment becomes an auditable ledger entry rather than a brick.

## P1-1 — `capsule_over_budget` is a one-way trap whose documented remedy destroys the run

`finish()` (`:1098`) throws *after* the event and both derived files are written.
Reproduced with a ~2600-char CJK goal (the estimator counts 1 token per non-ASCII
character, and this project's goals are Chinese — a 2500-character Chinese goal
hits the cap):

```
init   -> capsule_over_budget (tokens 3021) — but goal.json, journal.jsonl,
          checkpoint.json and recovery.md were all written anyway
status -> PASS
resume -> capsule_over_budget   (permanently; resume is the fresh-context entry point)
```

Guide §3.5 and the error's own `note` prescribe: "shorten the frozen goal text."
Doing so is forbidden by the level-1 invariant:

```
$ (edit goal.json to shorten `goal`)
resume -> goal_mutated          <-- harder brick
init (same dir) -> run_already_initialized
```

So the documented remedy is unexecutable after `init`, and the only real escape is
abandoning the run directory. `status` still works, so this is not a total dead end
— but the sole command the §4 fresh-session prompt tells a recovering context to run
is permanently dead, and the tool's printed advice is actively destructive.

**Fix:** compute the packet and check the budget in `cmdInit` **before** the first
write (the budget is a property of the frozen goal text — it is knowable at spec
time); reword guide §3.5 to "shorten the goal text *in the goal spec, before
init*"; and for an already-initialised run, degrade to a loud warning rather than a
hard failure — an over-budget `recovery.md` is still infinitely better than no
recovery packet.

## P1-2 — `init` is not transactional

Same root cause, different consequence. `cmdInit` writes `goal.json`, then appends
seq 1, then writes derived files, then validates the budget. A kill between the
`goal.json` write (`:846`) and `appendEvent` (`:847`) leaves a run dir where `init`
refuses (`run_already_initialized`) and every other command refuses
(`journal_missing`). The dir is permanently unusable. Escape exists (choose another
run dir) but the tool never says so, and guide §8 covers it only by the generic
"open a new run".

**Fix:** validate everything validatable before the first write; write `goal.json`
and the seq-1 journal line into a temp dir and `rename` the directory into place; or
have `init` clean up a run dir it created when it fails, so the name stays usable.

## P1-3 — the receipt's HEAD binding is simultaneously too strict and too weak

`validateVerificationReceipt` requires `receipt.verified_head === identity.head`
(`:721`) — the HEAD at the moment `verify` runs.

*Too strict:* any commit between the Conductor authoring the receipt (after the
Gate) and running `verify` gives `receipt_head_mismatch`. Committing the Gate report
and reviewer report before recording the receipt is the natural TAD order and is
enough to trip it. The only escape is to edit the receipt's `verified_head` to the
current commit — i.e. to assert verification at a tree state that was never gated.
A binding whose repair procedure is "write a slightly false attestation" degrades
into ritual.

*Too weak:* a commit id says nothing about a dirty worktree, and the YOLO worktree
is dirty most of the time. The tool knows this — it carries `dirty_count` and labels
it "observation only, never authority" (`:527`). So a receipt can bind perfectly to
`HEAD` while the verified tree contained arbitrary uncommitted content. FR3's claim
that the receipt binds to "当时 HEAD" is satisfied literally, but the property
readers will infer — "this exact tree was gated" — is not established.

**Fix:** record `gated_head` (from the Gate) *and* `observed_head_at_verify`, accept
when `gated_head` is an ancestor of the current head, and record the delta in the
journal instead of refusing. If the tree is dirty at `verify`, either refuse
explicitly or record the dirty path list into the `verified` event so the weakness is
visible in `recovery.md` rather than implied.

## P2-1 — derived-conflict detection exists only in `resume`

Reproduced: a `checkpoint.json` tampered to claim `S1` verified is caught by `resume`
(`derived_state_conflict`, with the `--rebuild-derived` remedy named — good), but a
subsequent mutating command silently overwrites it with no report. Authority is never
violated (the tampered claim is discarded), yet the forensic signal that someone
edited a derived file is erased. Guide §2's "it stops and reports the conflict" holds
for 1 of 8 commands. Either make `writeDerived` compare-then-report on every command,
or scope the guide's claim to `resume`.

## P2-2 — concurrency detection is TOCTOU and its failure mode is terminal

`appendEvent` (`:599-610`) re-reads and compares the line count, then appends. Two
processes can both pass the check and both append, producing a duplicate `seq` that
`readJournal` rejects forever (`journal_seq_broken`) — an unrepairable run, since
guide §8 forbids hand-repair. Single-writer is explicitly Phase-1 scope (§10.2), and
the check does fail closed *when it fires*; the race does not. `concurrent_writer_detected`
appears nowhere in the test suite. Given the outcome is permanent loss of the ledger,
an `O_EXCL` lockfile in the run dir — two lines, no dependency, no kernel — is a
cheaper guarantee than the detection that is already there.

## P2-3 — the ledger lives inside the blast radius of the rollback the guide recommends

The run dir is `<worktree>/.tad/evidence/yolo/…` and its files are untracked. Guide
§8 says "Rollback of *work* is ordinary git in the isolated worktree" without warning
that `git clean -fd`/`-fdx` — the usual companion to a rollback — deletes the entire
ledger, which is the one unrecoverable outcome in the whole design. Either warn
explicitly in §8, or `.gitignore`-and-preserve the run dir, or place the ledger
outside the worktree it governs.

## P2-4 — the fresh-session prompt has no branch for the errors `resume` actually returns

Guide §4 hands a zero-history context exactly one command (`resume`), tells it "do
NOT start any work yet", and gives no instruction for `derived_state_conflict`,
`handoff_revision_drift` or `capsule_over_budget` — the three most plausible non-happy
returns, two of which (P0-2, P1-1) that context cannot resolve at all. The remedy
string is in the error payload, so a competent agent may follow it, but the prompt is
the whole contract for that context. Add a short "if resume returns X, do Y; if it
returns anything else, stop and report the JSON status verbatim" clause.

## P2-5 — library-sized export surface on a single-purpose CLI

~20 internals are exported (`sha256File`, `estimateTokens`, `realpathDeepest`,
`assertInside`, `readGoal`, `readJournal`, `reduceRun`, `semanticCheckpoint`,
`writeAtomic`, `renderStatus`, `renderRecovery`, `validateVerificationReceipt`,
`parseArgs`, …). Justified for the sibling test file, but it is also the public API a
Phase-2 kernel would grow from, and it invites future callers to bind to internals
that §4.2 says may be renamed. Consider a single test-only export barrel so the
intended surface stays one command line.

---

## Summary

The authority model is real, not decorative: levels 1 and 2 are re-checked on every
command, level 3 can only refuse and never source state, level 4 is write-only, and
session-state / PreCompact are never read. Blast radius is exactly the three
permitted files. Nothing here is a kernel, event-sourcing engine or sandbox in
disguise. Normal commits after `init` correctly trip nothing.

The failure is in the *recoverability* dimension, and it is the one that matters for
a tool whose entire purpose is recovery. Two reachable states have no legal next
action at all: one reached by a command the tool itself recommends (P0-1), one reached
by appending a line to a handoff (P0-2). In both, `stop` — the mechanism for honestly
recording that the run failed — is unavailable, so the ledger cannot even record its
own death. Both fixes are small and local.

VERDICT: FAIL
P0: 2 | P1: 3 | P2: 5

---

## Incremental re-review (post-d7813c6b..HEAD) — independent verifier

Verifier model: opencode-go/ox-alpha-free
date: 2026-08-25
verified_head: fc7a07fceb1849e07075974c4475cecb945409d0
prior_verified_head: 019cdeb1e7137beaa6fe024ab30cb33a5d0348fe

Method: each original finding re-checked against `.tad/scripts/yolo-recovery.mjs`
and `.tad/scripts/yolo-recovery.test.mjs` at the verified head (fix commits
`d7813c6b` + `00570c00` + `0ccd30cd` + `84c3666c`, plus one later commit,
`fc7a07fc`). Full contract suite re-run at head: 10/10 cases PASS (including
the `binding-and-closure` case).

Head delta 019cdeb1..fc7a07fc: exactly one commit (`fc7a07fc`, security-driven)
— receipt-bound gate/review EVIDENCE is now re-hashed on every `loadRun`;
missing/tampered evidence becomes a binding blocker
(`verified_evidence_missing` / `_hash_mismatch`), consistent with the P0-2
blocker model. `git show fc7a07fc --stat`: touches ONLY
`.tad/scripts/yolo-recovery.mjs` (+19) and `.tad/scripts/yolo-recovery.test.mjs`
(+30, two red/green cases j2/j3). No architecture surface change; it tightens
the level-2 evidence-pointer check this review already relied on.

| finding | severity | status (RESOLVED/OPEN) | evidence (file:line quotes) |
|---|---|---|---|
| P0-1 reconcile-after-stop bricks ledger; next-action text recommends it | P0 | RESOLVED | Explicit stopped guard before any append: `yolo-recovery.mjs:1233` `if (r.state.stopped) { throw new ContractError('run_stopped', …)`. Structural guarantee: `appendEventGuarded` (:659-678) reduces the candidate in memory first — `reduceRun(goal, events.concat([candidate]))` … `'refused before writing; the journal is unchanged'` — and ALL five append sites use it (:1150 checkpoint, :1169 verify, :1215 action-start, :1325 reconcile, :1364 stop). Guidance corrected: :445 stopped branch now reads `'…open a NEW run from a known commit. No further event may be recorded here.'` — reconcile no longer named. Test: `binding-and-closure` #1 (test:677-683) — reconcile after stop → reason `run_stopped`, `readJournalEvents(repo).length === afterStop`, status stays readable. |
| P0-2 binding failure locks out `status` AND `stop` (handoff amendment / worktree move / touched receipt) | P0 | RESOLVED | Binding failures are blockers, not throws (`loadRun`:746-810): worktree mismatch :748-753, handoff drift/missing :764-772, evidence hash mismatch :783-785 → merged into `state.blockers`, `state.state = 'HONEST_PARTIAL'`, legal_next_action points to `status`/`stop` (:803-809). `cmdStatus` renders under failure (no refusal, :1124-1132). `cmdStop` has NO honest-partial refusal (:1360-1364) and records truth. Init freezes its own authority copy: :1080-1082 `fs.copyFileSync(handoffAbs, frozenPath)` → tamper with THAT copy is fatal (`handoff_frozen_tampered`, :757-763) while live-file drift is a mere blocker. Tests: authority-conflicts (h) (test:396-412 — relocated worktree: status renders `GOAL:`, stop writes a `stopped` event); binding-and-closure #2 (test:686-701 — handoff amendment: drift reported, checkpoint refused, stop succeeds); #3 (test:703-714). |
| P1-1 `capsule_over_budget` one-way trap; documented remedy destroys the run | P1 | RESOLVED (residual noted) | Budget now checked BEFORE the first write: cmdInit preview :1051-1066 throws `capsule_over_budget` with note `'NOTHING was written. Shorten the goal/success text in the goal SPEC and re-run init.'`; combined with init's transactional rollback (:1092-1099). Test: status-capsule (test:596-608) — rejected init leaves no `goal.json` behind and the run-dir name stays usable. The reviewed reproduction chain (init wrote everything → resume permanently dead → shorten-frozen-goal ⇒ `goal_mutated`) is no longer reachable. Residual (not the reviewed defect): guide §3.5:151-153 still says "the tool writes the full packet … Shorten the frozen goal text" (stale wording), and `finish()` (:1374-1381) still throws post-write if the packet grows past budget AFTER init — degraded exit code only; event already recorded, nothing bricked. |
| P1-2 `init` not transactional (half-written run dir permanently unusable) | P1 | RESOLVED | All validation precedes the first write (cmdInit :1004-1066: `run_already_initialized`, handoff/goal-file existence, spec fields, base_commit, oracle, capsule preview). Writes wrapped in try/catch that removes created files and the run dir if newly created: :1092-1099 `for (const f of created.reverse()) { fs.rmSync(f, { force: true }) } … fs.rmSync(runDir, { recursive: true, force: true })`. Test: status-capsule (test:603-608). |
| P1-3 receipt HEAD binding too strict (exact equality) AND too weak (dirty tree invisible) | P1 | RESOLVED | Strict half fixed: validateVerificationReceipt :893-912 accepts the gated commit or any ancestor via `git merge-base --is-ancestor receipt.verified_head identity.head`, else `receipt_head_not_ancestor`. Weak half fixed: the verified event records what was actually observed — :1176-1177 `observed_head_at_verify: r.identity.head, dirty_paths_at_verify: r.identity.dirty_paths`. Test: binding-and-closure #4 (test:716-733) — Gate report committed after the receipt still verifies; both new payload fields asserted. |
| P2-1 derived-conflict detection only in `resume` (forensic signal erased) | P2 | RESOLVED | Option A implemented: `writeDerived` compare-then-reports on EVERY writing command (:820-828 compares on-disk `checkpoint.json` body vs reduced state; :840-844 prints `'!! WARNING: … disagreed with the journal and has been rebuilt'`). Test: binding-and-closure #7 (test:766-778) — forged checkpoint + `checkpoint` command → command succeeds (journal is authority) AND `/WARNING/.test(res.out)` asserted. Resume keeps the hard gate + `--rebuild-derived` (:1337-1353). |
| P2-2 concurrency check TOCTOU; duplicate seq permanently destroys ledger | P2 | RESOLVED | Exclusive O_EXCL lockfile added: `withRunLock` :685-706 (`fs.openSync(lock, 'wx')`, EEXIST → `run_locked` with recovery note), wrapped around every append site. Line-count backstop `concurrent_writer_detected` retained (:710-716). Test: binding-and-closure #6 (test:751-764) — held lock blocks writer; release restores operation; lock cleaned up after success. Note: a kill mid-command leaves a stale lock whose removal is operator-manual (named in the error note) — accepted Phase-1 trade-off, not a defect. |
| P2-3 ledger lives inside the blast radius of the recommended rollback (`git clean`) | P2 | OPEN — non-blocking P2 hardening — deferred to NEXT.md follow-up | Nothing changed. `git log -- .tad/guides/yolo-recovery.md` shows exactly one commit (323c380d, the original slice) — the guide is untouched by d7813c6b..HEAD. Guide §8:291-293 still reads "Rollback of *work* is ordinary git in the isolated worktree…" with no `git clean -fd/-fdx` warning. Run dir placement unchanged: `RUN_ROOT_REL = path.join('.tad','evidence','yolo')` (mjs:52) inside the governed worktree; no preserving `.gitignore` entry exists (grep of `.gitignore` finds none for `.tad/evidence/yolo`). None of the three offered alternatives (warn in §8 / ignore-and-preserve / move outside worktree) was taken. |
| P2-4 fresh-session prompt has no branch for the errors `resume` returns | P2 | OPEN — non-blocking P2 hardening — deferred to NEXT.md follow-up | Guide §4 (yolo-recovery.md:158-178) is byte-identical to the reviewed revision: it hands the zero-history context exactly one command (`resume --run <RUN_DIR>`), says "Do NOT start any work yet", and contains no "if resume returns X, do Y" clause for `derived_state_conflict` / `handoff_revision_drift` / `capsule_over_budget`. Context: two of those three returns are now far less likely (P0-2 degrades drift to a blocker the status output explains; P1-1 refuses over-budget at init), and error payloads carry remedy strings — but the requested prompt-contract clause was never added. |
| P2-5 library-sized export surface on a single-purpose CLI | P2 | OPEN — non-blocking P2 hardening — deferred to NEXT.md follow-up | Unchanged and slightly larger: ~26 exports including internals — `sha256File` (:95), `estimateTokens` (:107), `realpathDeepest` (:126), `assertInside` (:142), `readGoal` (:230), `readJournal` (:262), `reduceRun` (:302), `semanticCheckpoint` (:499), `writeAtomic` (:522), `renderStatus` (:546), `renderRecovery` (:580), `validateVerificationReceipt` (:861), `parseArgs` (:968), plus constants/errors. No test-only export barrel exists; the sibling test still imports internals directly (test:25-27 `import { writeAtomic, REQUIRED_LABELS, CAPSULE_TOKEN_BUDGET, reduceRun, renderRecovery } from './yolo-recovery.mjs'`). Advisory item never addressed. |

New defects introduced since d7813c6b: none.
Spot-check of `00570c00` (+10: VERIFICATION MODEL section + 2 packet assertions),
`0ccd30cd` (+17: PROHIBITIONS section + 2 packet assertions) and `84c3666c`
(±3: pending-action classification rule + double-application rationale prose)
confirms they touch ONLY `renderRecovery` strings and `caseStatusCapsule`
assertions in the two permitted files (`git show --stat`: no other paths).
Minor notes, not defects: (1) `84c3666c` modified prose only — its claims are
covered by pre-existing assertions, no new test line was added;
(2) the working tree carries an UNCOMMITTED allowlist amendment to
`yolo-recovery.test.mjs` (`ALLOW_EXACT` += six TAD lifecycle docs, the Gate 4
corrective amendment) — process scope only, not runtime code, and not counted
as a change since d7813c6b.

incremental_verdict: PASS

Rationale (TAD blocking semantics — P0/P1 blocking, P2 non-blocking follow-up):
every BLOCKING finding (P0-1, P0-2, P1-1, P1-2, P1-3) is demonstrably RESOLVED
at fc7a07fc with structural (not point) fixes and red/green test evidence; the
full contract suite is 10/10 green at the verified head. No new P0/P1 was
introduced since d7813c6b (the sole later commit, fc7a07fc, only tightens the
level-2 bound-evidence check and stays inside the two permitted files). The
three remaining OPEN items (P2-3, P2-4, P2-5) are non-blocking P2 hardening,
recorded here verbatim and deferred to a NEXT.md follow-up handoff; under Gate 3
acceptance semantics they do not block this verdict.
