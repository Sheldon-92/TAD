# YOLO Recovery Recorder — Phase 1 Reference Flow

> **Status: experimental, opt-in, Claude-Code-only reference.**
> Nothing in TAD calls this automatically. The default `yolo-epic` workflow,
> the Gates, the PreCompact hook and every existing protocol are unchanged.
> Using it is a deliberate per-run decision by the Conductor.

This guide describes how to run **one** long YOLO task so that, after a compact
or a process kill, a context with **no chat history at all** can pick it up from
the run directory alone — and refuse to continue when it honestly cannot.

- Tool: `.tad/scripts/yolo-recovery.mjs`
- Contract suite: `.tad/scripts/yolo-recovery.test.mjs`
- Runtime: Node built-ins only, no npm packages, no lockfile change.

**Derived Node floor: ≥ 16.0.** That number is derived from the APIs actually
used, not guessed: `node:`-prefixed builtin imports (added in 14.18 / 16.0) set
the floor, with `fs.rmSync` (14.14) and stable `.mjs` ESM below it. It is
*measured* only on the version this was built and dogfooded with — Node
**24.7.0**. Treat 16.0 as "derived, untested" and 24.7.0 as "verified".

---

## 1. What this proves, and what it does not

**Phase 1 claim:** for one real task, three real interruptions were each
recovered by a fresh context that received only a run path, and the work then
continued through the existing Gate.

**Phase 1 does NOT claim:**

- that overall YOLO quality improved by any percentage — that is a later phase
  with a paired measurement against v1;
- that Codex or OpenCode behave the same way — the harness choice here is
  Claude Code because that is where the only real YOLO workflow lives;
- that a general workflow kernel, event-sourcing log, hash chain, fencing token
  or JS sandbox exists — none of that is built;
- that the receipt author check is cryptographic provenance (see §7).

---

## 2. Authority order (memorise this one)

1. the approved handoff revision + the immutable `goal.json`
2. a fully parseable `journal.jsonl` **and the evidence it points at**
3. the rebuildable `checkpoint.json`
4. `recovery.md`, `.tad/active/session-state.md`, PreCompact snapshots —
   **navigation only, never progress truth**

A stale `session-state.md` from an unrelated older handoff is a known way to
misroute a recovery. That is why every command takes an explicit `--run <dir>`
and there is deliberately **no global "active run" pointer**.

When a lower level disagrees with a higher one, the tool does not pick "the
newest file". It stops and reports the conflict.

---

## 3. Opt-in operational flow (Claude Code)

### 3.1 Freeze, then initialise

Before any work, the Conductor freezes three things on disk:

1. **the frozen goal file** — a small JSON with `run_id`, `goal_id`,
   `base_commit`, `goal`, `success[]`, `non_goals[]`, `forbidden_scope[]`,
   `oracle_path`, and (recommended) `slices[]` of `{id, statement}`;
2. **the frozen oracle** — the expected recovery answers, written *before* the
   run and never shown to an executing context;
3. **the worktree** — an isolated `git worktree` checked out at exactly
   `base_commit`.

```bash
node .tad/scripts/yolo-recovery.mjs init \
  --run .tad/evidence/yolo/<epic>/<phase>/run-1 \
  --handoff .tad/active/handoffs/HANDOFF-....md \
  --goal-file .tad/evidence/yolo/<epic>/<phase>/goal-spec.json
```

`init` refuses to run unless `HEAD` already equals the declared `base_commit`,
freezes `realpath(git rev-parse --show-toplevel)`, hashes the approved handoff
into `handoff_revision`, and writes `goal.json` atomically. It never overwrites
an existing run.

`goal.slices` is an additive field beyond the minimum data model: without a
frozen slice plan the tool cannot name a *specific* next legal action, so it
degrades honestly to "the Conductor must choose the next slice".

### 3.2 Work, and record only what is true

| moment | command |
|---|---|
| about to compact, about to stop, or a slice looks done | `checkpoint --slice <id> --reason <before-compact\|before-stop\|candidate> --next "<text>"` |
| an existing Gate **and** an independent reviewer have both PASSED a slice | `verify --slice <id> --receipt <receipt.json>` |
| about to touch something outside the ledger | `action-start …` then `reconcile …` |
| a human pauses the run | `stop --reason "<text>"` |

`checkpoint` deliberately has **no `verified` reason**. Checkpointing records
intent; it can never advance verified progress. That separation is the whole
point: `completion_written=true`, `layer1_passed=true`, a green test log, or a
completion report are all *ordinary files* to this ledger.

### 3.3 Side effects

Anything that changes the world outside the ledger is bracketed:

```bash
node .tad/scripts/yolo-recovery.mjs action-start --run <dir> \
  --action A1 --description "patch the frozen paragraph" \
  --target <repo-relative path> \
  --pre-sha256 <sha of the file right now> \
  --intended-post-sha256 <sha the file should have afterwards>
# ... perform the action ...
node .tad/scripts/yolo-recovery.mjs reconcile --run <dir> --action A1 --outcome confirmed
```

All five `action-start` flags are mandatory; omitting one is a usage error, not
a warning. `reconcile` re-reads the **real file** and classifies:

- `confirmed` — the file hashes to exactly `intended_post_sha256`;
- `outcome_unknown` — it is neither the pre nor the intended post state. The run
  drops to `honest_partial` and **re-running the same action id is permanently
  forbidden**, because a blind retry could double-apply the side effect;
- `reconciled` — a human/Conductor closes an unknown outcome with an explicit
  evidence file and the real observed hash.

### 3.4 Compact or die, then recover

After the interruption, the new context is given **only** the run path and the
assertion instruction in §5 — no transcript, no compact summary, no "here is
what we were doing". It runs:

```bash
node .tad/scripts/yolo-recovery.mjs resume --run <dir>
```

`resume` rebuilds the state from `goal.json` + `journal.jsonl`, writes
`checkpoint.json` and `recovery.md` atomically, and prints a one-screen status.
It **generates the recovery packet; it does not perform the next step.** The
reviewer PASS in §6 is the precondition for continuing.

If a derived file disagrees with what the journal reduces to, `resume` fails
with `derived_state_conflict` rather than silently overwriting it. The explicit
repair is `resume --run <dir> --rebuild-derived`, which rewrites the derived
files from the journal and can never invent verified progress.

### 3.5 The capsule budget

`recovery.md` targets ≤ **2500 tokens** (estimated conservatively: ASCII at four
characters per token, every non-ASCII character counted as a whole token). Over
budget, the tool writes the full packet, reports the per-section composition and
**stops**. Shorten the frozen goal text. Never buy headroom by deleting
non-goals, forbidden scope, blockers or the next-action reasoning — those are
the anchors the whole mechanism exists to carry.

---

## 4. The fresh-session prompt

Give the recovering context exactly this, with `<RUN_DIR>` substituted and
nothing else attached:

```text
You are taking over a task that was interrupted. You have NO history of it and
you will not be given any.

The only thing you get is this run directory: <RUN_DIR>

1. Run: node .tad/scripts/yolo-recovery.mjs resume --run <RUN_DIR>
2. Read <RUN_DIR>/goal.json and <RUN_DIR>/journal.jsonl yourself. They are the
   authority. recovery.md is a convenience view; if it disagrees with the
   journal, the journal wins.
3. Do NOT read .tad/active/session-state.md, any compact summary, or any other
   chat-derived file. They are navigation aids for humans, not progress truth.
4. Do NOT start any work yet.
5. Write your recovery assertion to <RUN_DIR>/assertion.md using the exact
   template you are given. Then stop and report that you have written it.
```

---

## 5. Semantic assertion template (fixed)

The recovering context fills every field. Missing a field scores as wrong, not
as blank.

```markdown
# Recovery Assertion — <run_id>

## H1 GOAL
<one sentence: what this run is trying to achieve>

## H2 HANDOFF REVISION
<handoff path> @ <first 12 chars of handoff_revision>

## H3 VERIFIED
<exact list of verified slice ids, or "none">

## H4 UNVERIFIED / IN PROGRESS
<checkpoint candidates and any uncommitted work observed, or "none">

## H5 PENDING ACTION
<action id, target, and its current classification, or "none">

## H6 BLOCKERS
<blocker codes and what they mean, or "none">

## H7 LEGAL NEXT ACTION
<the single next action that is legal right now>

## H8 NON-GOALS AND FORBIDDEN SCOPE
<at least one non-goal and one forbidden-scope item, stated correctly>

## S1 WHY THAT NEXT ACTION IS LEGAL
## S2 WHY THE VERIFIED WORK MUST NOT BE REDONE
## S3 WHY A BLIND RETRY / A SELF-DECLARED COMPLETION IS NOT AVAILABLE HERE
## S4 WHAT THIS RUN HAS EXPLICITLY REJECTED OR MUST NOT DO
```

`H1`–`H8` are the **hard anchors**. `S1`–`S4` are the **soft rationale**.

---

## 6. Reviewer rubric

The reviewer must be a different context from the one that wrote the assertion.
Read the **assertion first**, then unseal the oracle — never the other way
round, or the oracle anchors the score.

- **Hard anchors: 8/8 required.** Each of `H1`–`H8` is scored `1` only if it
  matches the frozen oracle in substance. Partial credit does not exist.
- **Soft rationale: ≥ 0.90 required.** Each of `S1`–`S4` scores `1.0`
  (correct and complete), `0.5` (correct but thin) or `0` (absent or wrong);
  `soft_score` is their mean.
- **Escalation rule:** any omission that would change *which next action is
  legal* is a **hard** failure, even if it appears in a soft field. A
  plausible-sounding rationale that would authorise redoing verified work, or
  retrying an `outcome_unknown` action, fails the whole run.

The reviewer writes a report containing the verdict `PASS` or `FAIL`, the hard
tally, the soft score, and the sha256 of both the assertion and the oracle it
scored. `FAIL` means the recovery did not work — record it honestly; do not
feed the fresh context extra history to rescue the number.

---

## 7. The verification receipt (and its real limits)

Only a receipt can advance `last_verified`. It is **not a new Gate and not a
verifier** — it is a binding record written *after* the existing Gate and the
independent reviewer have already passed:

```json
{
  "format": "yolo-recovery-verification-v1",
  "verdict": "PASS",
  "run_id": "...", "slice": "...", "handoff_revision": "...",
  "worktree_realpath": "...", "verified_head": "...",
  "gate_evidence":   [{"path": "...", "sha256": "...", "verdict": "PASS"}],
  "review_evidence": [{"path": "...", "sha256": "...", "independent": true, "verdict": "PASS"}],
  "executor_id": "...", "written_by": "conductor", "written_by_id": "..."
}
```

The CLI checks binding (run, slice, handoff revision, real worktree, current
HEAD), shape, that every referenced evidence file exists and hashes exactly as
declared, that at least one review is marked independent, and that
`written_by_id != executor_id`.

> ⚠️ **`written_by_id != executor_id` is a process-integrity boundary, not
> cryptographic provenance.** These are self-declared identifiers. Phase 1's
> threat model does **not** defend against a malicious local process running as
> the same user, which could simply write whatever it likes. What it does buy is
> that no legitimate executor command produces a receipt: the Conductor writes
> it by hand, after the Gate. **Gate 3 must therefore manually cross-check each
> receipt against the original Gate and review evidence it names** — the CLI
> proves the binding, a human proves the semantics.

---

## 8. Stopping and rolling back

- `stop --reason "<text>"` records the reason and puts the run in
  `honest_partial` with a non-zero exit. Nothing may be recorded afterwards.
  This is the correct ending for "we ran out of budget", "the human paused it",
  or "recovery failed" — it is *not* a failure of the tool.
- An unrecoverable ledger (corrupt JSONL, a half-written final line from a
  kill, a mutated `goal.json`) is intentionally terminal. Do not hand-repair the
  journal to keep going: open a new run from a known commit and record what was
  actually salvaged.
- Rollback of *work* is ordinary git in the isolated worktree. The ledger is
  append-only and is never rewritten to match a rollback; record the truth with
  a new `checkpoint` or `stop`.
- `recovery.md` may be deleted at any time; `resume` rebuilds it. It never has
  authority, so a stale copy can mislead a human but cannot corrupt the run.

---

## 9. Exit contract

| exit | meaning |
|---|---|
| `0` | PASS |
| `1` | contract failure — the run is in `honest_partial` |
| `2` | usage / input error (missing flag, unknown command, path escape) |

The last line of stdout is always a single-line JSON status object
(`format: yolo-recovery-status-v1`) carrying `result`, `state`, `reason`,
`verified_slices`, `unverified_slices`, `blockers` and `legal_next_action`.
Parse that line; do not scrape the human-readable text above it.
