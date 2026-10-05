Model: harness=claude-code | model=claude-opus-5 | route=host

# Layer 2 Security Review — YOLO 2.0 Phase 1 Recovery Recorder

**Scope:** `.tad/scripts/yolo-recovery.mjs`, `.tad/scripts/yolo-recovery.test.mjs`,
`.tad/guides/yolo-recovery.md` §7, `HANDOFF-20260824-yolo2-phase1-recovery-slice.md`
§3 / §4.2 / §10.
**Date:** 2026-08-24
**Threat model honoured:** the stated Phase-1 exclusion (a *malicious* local process
running as the same user) is accepted and is NOT reported as a finding. Every finding
below is reachable either by an ordinary, non-malicious operator following the
documented commands, or by ordinary repository events (checkout, cleanup, archive).

Findings were verified by running the CLI against throwaway git fixtures; each one
below records the observed output, not a reading-based hypothesis.

---

## Summary

| # | Severity | Finding |
|---|---|---|
| 1 | **HIGH (P0)** | Gate/review evidence is hash-checked only at `verify` time and never again — evidence can be replaced or deleted and the slice stays `VERIFIED` forever |
| 2 | **HIGH (P0)** | All repo-relative inputs resolve against `process.cwd()`, not the repo root — from a subdirectory the tool silently freezes a *different* file as the approved `handoff_revision` |
| 3 | MEDIUM | Evidence content is entirely unconstrained: two **empty** files pass as "Gate PASS" + "independent review PASS" |
| 4 | MEDIUM | `written_by_id != executor_id` is unbound and untyped — `{}` vs `{}` passes; `executor_id` is bound to nothing frozen |
| 5 | MEDIUM | `git status --porcelain` runs without `maxBuffer`; ~1 MB of output bricks *every* command with a misleading `git_unavailable` |
| 6 | LOW | Journal-recorded `payload.target` / `receipt_path` are re-resolved with no scope assertion |
| 7 | LOW | The scope guard protects the run-dir *path* but never the ledger files inside it (symlinked `journal.jsonl`) |
| 8 | LOW | `writeAtomic` uses `O_TRUNC`/symlink-following `writeFileSync`, default 0644, no fsync |
| 9 | LOW | `goal.handoff_path` is consumed before the `goal_mutated` integrity check |
| 10 | LOW | `parseArgs`: duplicate flags last-wins, positionals silently dropped, any `--`-prefixed value becomes boolean `true` |

**Clean:** no command or argument injection reaches `git` (§ "Injection" below).
Path traversal via `..`, absolute paths, and symlinked run directories is correctly
refused.

---

## 1. HIGH (P0) — A verified slice survives the destruction of the evidence it rests on

**Location:** `.tad/scripts/yolo-recovery.mjs:644-657` (`loadRun`), `:914-923` (`cmdVerify`
journal payload), `.tad/guides/yolo-recovery.md:45` (authority order).

**Description.** `validateVerificationReceipt` hashes every `gate_evidence[]` and
`review_evidence[]` entry — but only once, at `verify` time. The `verified` journal
event then records those entries as **bare path strings with no hashes**:

```js
gate_evidence: v.receipt.gate_evidence.map((e) => e.path),
review_evidence: v.receipt.review_evidence.map((e) => e.path),
```

On every subsequent load, `loadRun` re-checks **only the receipt file**:

```js
// Authority level 2 includes the journal's EVIDENCE POINTERS. A verified slice
// whose receipt has vanished or changed is not verified progress any more.
for (const v of state.verified) { /* … checks v.receipt_path / v.receipt_sha256 only … */ }
```

The evidence the receipt points at is never re-read. The comment, and guide §2's
authority order ("a fully parseable `journal.jsonl` **and the evidence it points at**"),
both describe a transitive check that is implemented only one level deep.

**Impact.** The single protection this tool exists to provide — "no unverified work is
ever reported as verified to a fresh context" — fails open. A recovering context with no
history is told `DO NOT redo this work` for a slice whose Gate evidence now says the Gate
failed and whose independent review no longer exists.

**Reachable without any malicious actor.** Evidence files disappear or change through
entirely ordinary events: `git checkout` / branch switch in the worktree, a rebase,
`*tad-maintain` cleanup, evidence archival, or a rerun that overwrites a report in place.
The tool already treats exactly these events as fatal for the *receipt* (test cases
`authority-conflicts` (i) and (j)) — the asymmetry is the bug.

**Proof of concept (observed):**

```
A empty-evidence verify exit= 0 verified= ["S1"]
# then: gate.md overwritten with "THIS GATE ACTUALLY FAILED", review.md deleted
B post-swap status exit= 0 result= PASS verified= ["S1"]
B resume  exit= 0 verified= ["S1"]
B recovery.md says: - `S1` — receipt … verified at HEAD … DO NOT redo this work.
```

**Remediation.** In `loadRun`, for each verified slice, re-parse the (already
hash-pinned, therefore trustworthy) receipt and re-assert every
`gate_evidence`/`review_evidence` entry's existence and sha256 — new reasons
`verified_gate_evidence_missing` / `_hash_mismatch`. Alternatively record
`{path, sha256}` pairs in the `verified` event instead of bare paths. Note the declared
`e.path` must be resolved against **repoRoot**, not cwd (see Finding 2).

**Test gap.** `caseVerifiedAuthority` step 10 tampers evidence *before* verify;
`caseAuthorityConflicts` (i)/(j) tamper the receipt *after* verify. No case tampers
**evidence after verify**. Add one; it is a one-line fixture change and it is red today.

---

## 2. HIGH (P0) — Repo-relative paths resolve against `process.cwd()`, silently binding the run to the wrong handoff

**Location:** `.tad/scripts/yolo-recovery.mjs:126-139` (`realpathDeepest` →
`path.resolve(p)`), `:182-186` (`resolveInRepo`), `:799-800`, `:822`, `:691`, `:744`,
`:948`, `:991`, `:1035`.

**Description.** `realpathDeepest` starts with `path.resolve(p)`, which anchors a
relative path at `process.cwd()`. `repoRoot` is derived independently from
`git rev-parse --show-toplevel`, so any relative input resolves against the *current
directory*, not the repo root — while every doc, the goal spec's `oracle_path`, and the
receipt's `gate_evidence[].path` are written as **repo-relative**.

The guide (§3.1) prints the command with repo-relative paths and never says "run this
from the repo root". Agent harnesses reset cwd between calls; TAD's own agent notes state
this explicitly. So a subdirectory cwd is a normal condition, not an exotic one.

**Impact.** The top of the stated authority order — "the approved handoff revision" — is
bound to a file the human never approved, and stays bound for the life of the run. The
`init` succeeds with exit 0 and no warning. `oracle_path` is affected the same way even
when every command-line path is absolute, because it is always relative *inside the
spec*. At `verify`, receipt evidence paths are likewise resolved cwd-relative: they
either fail closed (`path_escape` / `receipt_evidence_missing`) or, if a same-named file
exists below the cwd, silently hash the **wrong file** as the Gate evidence.

**Proof of concept (observed).** Repo with an approved `docs/handoff.md` and a decoy
`sub/docs/handoff.md`; `init` run from `sub/` with an absolute `--run` and the documented
relative `--handoff docs/handoff.md`:

```
exit= 0 reason= null
frozen handoff_path = sub/docs/handoff.md
frozen oracle_path  = sub/.tad/evidence/yolo/oracle.md
```

**Mitigating factor (why HIGH, not CRITICAL).** `renderStatus` does print
`HANDOFF REVISION: <path> @ sha256 …`, so a careful operator can notice. Nothing flags it.

**Remediation.** Anchor every repo-relative input at the repo root before realpath:
`const abs = path.isAbsolute(input) ? input : path.join(repoRoot, input)` inside
`resolveInRepo` / `resolveRunDir`, then `realpathDeepest` + `assertInside` unchanged.
Apply identically to `oracle_path`, receipt evidence paths, `--target` and `--evidence`.
A `process.chdir(repoRoot)`-equivalent alone is not sufficient — fix the resolver.

**Test gap.** Every `cli(...)` invocation in the suite passes `repo.dir` as cwd, so this
entire class is invisible to the suite. Add one case that runs the documented command
from a subdirectory and asserts the frozen `handoff_path` is the approved one.

---

## 3. MEDIUM — Two empty files are accepted as "Gate PASS" and "independent review PASS"

**Location:** `.tad/scripts/yolo-recovery.mjs:734-757` (`checkEvidence`).

`checkEvidence` requires that the entry declares `verdict: 'PASS'`, that the file exists,
is a regular file, and hashes as declared. It never requires the file to be non-empty or
to contain any verdict anchor. A zero-byte file with sha256 `e3b0c442…` satisfies it.

Verified: `A empty-evidence verify exit= 0 verified= ["S1"]` with both evidence files
zero bytes.

The design intent ("not a Gate and not a semantic verifier") makes some of this
deliberate, and guide §7 states the compensating control (Gate 3 cross-checks manually).
What makes it a finding is the **asymmetry with the suite's own dogfood checker**, which
for the same class of artifact rejects empty files and requires a `PASS` anchor
(`.tad/scripts/yolo-recovery.test.mjs:637-643`, `:716-720`). The stricter rule already
exists in this codebase; the receipt path does not apply it.

**Remediation.** In `checkEvidence`, reject size-0 evidence and require a `PASS` anchor in
the referenced file (`/\bPASS\b/`), mirroring `checkDogfoodEvidence`. Cheap, and it
closes the "hash-matched placeholder" hole without turning the CLI into a verifier.

---

## 4. MEDIUM — The self-authorship check is unbound and untyped

**Location:** `.tad/scripts/yolo-recovery.mjs:727-729`, `:679-683` (`RECEIPT_REQUIRED`).

`if (receipt.written_by_id === receipt.executor_id) throw …` compares two free-form
fields inside the *same* file. Two consequences:

1. **Untyped.** `RECEIPT_REQUIRED` only rejects `undefined`/`null`/`''`. Non-string values
   pass, and reference inequality makes the check vacuous for them. Verified:
   `executor_id: {}` + `written_by_id: {}` → `C object-ids verify exit= 0 verified= ["S1"]`.
   Those values are then written verbatim into the journal's `verified` payload.
2. **Unbound.** `executor_id` is never compared against anything frozen before the work
   started. Nothing prevents a different `executor_id` per slice, or an `executor_id`
   invented at receipt-writing time specifically to differ from `written_by_id`.

Guide §7's warning correctly says these are self-declared identifiers, so this is not an
overclaim — but the check is weaker than the sentence "no legitimate executor command
produces a receipt" implies, because the *content* requirement is only "two distinct
truthy values".

**Remediation (cheap, meaningfully raises the bar).** Freeze `executor_id` in `goal.json`
at `init` (the value is then chosen *before* the work and is immutable, since `goal.json`
is hash-pinned into the journal), and in `validateVerificationReceipt` require
`typeof receipt.executor_id === 'string' && typeof receipt.written_by_id === 'string'`
plus `receipt.executor_id === goal.executor_id`. A retroactively invented executor
identity then contradicts a frozen one.

---

## 5. MEDIUM — An observation-only git call can brick every command

**Location:** `.tad/scripts/yolo-recovery.mjs:152-158` (`git`), `:161-170`
(`readGitIdentity`).

`execFileSync` is called with no `maxBuffer`, so Node's 1 MB default applies. `git status
--porcelain` output above that limit throws `ENOBUFS`, which `git()` converts into
`ContractError('git_unavailable')` — a **misleading** reason, since git is available and
succeeded.

Verified with ~7,000 modified tracked files (1,356,925 bytes of porcelain):

```
H status exit= 1 reason= git_unavailable details= {"args":["status","--porcelain"],"message":"spawnSync git ENOBUFS"}
```

**Impact.** `readGitIdentity` runs first in every command path, so `status`, `resume`,
`stop` and `verify` all become impossible — the recovery tool is unusable precisely in the
messy post-crash worktree state it exists to serve. It fails *closed* (no false verified
progress), which is why this is MEDIUM and not HIGH. The value it dies for,
`dirty_count`, is documented in-code and in the status output as "observation only, never
authority".

**Remediation.** Pass an explicit `maxBuffer` (e.g. 64 MB), or count lines without
buffering the whole output; and degrade `dirty_count` to `unknown` on failure rather than
aborting the command. Distinguish "git not found / not a repo" from "output too large" in
the reported reason.

---

## 6. LOW — Journal-recorded paths are re-resolved without a scope assertion

**Location:** `.tad/scripts/yolo-recovery.mjs:995`, `:1011` (`reconcile` target), `:647`
(`loadRun` receipt path).

`--target` is properly scope-checked at `action-start` via `resolveInRepo`, but on
re-read `reconcile` does `path.resolve(r.repoRoot, unknown.target)` / `pending.target`
with no `assertInside`; `loadRun` does the same for `v.receipt_path`. A journal whose
`payload.target` contains `../…` makes the tool hash a file outside the repo and write
that hash into the ledger.

Verified: journal `target` rewritten to `../../../../../../etc/hosts` →
`observed_sha256` recorded in the journal equals the real sha256 of `/etc/hosts`.

Read-only, requires prior journal tampering, and does not produce false verified
progress — hence LOW. Still worth closing: run every journal-sourced path back through
`assertInside(repoRoot, …)` so the scope guard is enforced on **read** as well as write,
and so Finding 1's fix inherits it.

---

## 7. LOW — The scope guard covers the run-dir path but not the ledger files inside it

`resolveRunDir` correctly refuses a symlinked run directory (verified:
`F symlink-rundir init exit= 2 reason= path_escape`). But `goal.json`, `journal.jsonl`,
`checkpoint.json` and `recovery.md` are opened by path with no `lstat` check, so a
symlinked `journal.jsonl` inside an in-scope run dir redirects the append-only ledger
outside the repo, silently.

Verified: `E symlinked-journal checkpoint exit= 0 … outside file lines= 2 … runDir journal still symlink= true`.

Creating that symlink is not something a documented command does, so this sits at the
edge of the excluded threat model — but the guard reads as absolute in §3.2 of the
handoff ("路径必须解析并限制在当前 repo 的 `.tad/evidence/yolo/` 内"), and an `lstat`
`isFile()` check on the four ledger files is a two-line fix.

---

## 8. LOW — `writeAtomic` file handling

**Location:** `.tad/scripts/yolo-recovery.mjs:488-498`.

- Temp name is `pid` + 32 bits of `crypto.randomBytes` in the target directory —
  unpredictable enough for the stated model.
- `fs.writeFileSync` uses `'w'` (`O_CREAT|O_WRONLY|O_TRUNC`), which **follows symlinks and
  truncates**. `flag: 'wx'` plus `mode: 0o600` is strictly better and costs nothing.
- Written files are 0644 under the default umask (verified). No secrets are stored, so
  this is informational.
- Neither the temp file nor the containing directory is `fsync`ed before/after `rename`.
  Correct against a process kill (page cache survives); a power loss can expose an empty
  or stale `checkpoint.json`. `journal.jsonl` is appended without fsync too — but a torn
  final line is already handled terminally (`journal_partial_line`), so the ledger stays
  honest. Note the limit in the guide rather than adding fsync, if that is the intent.

---

## 9. LOW — `goal.handoff_path` is used before the goal-integrity check

**Location:** `.tad/scripts/yolo-recovery.mjs:618-640` (`loadRun` ordering).

`loadRun` resolves, existence-checks and hashes `goal.handoff_path` (line 628, via
`path.resolve`, no `assertInside`) **before** verifying `events[0].payload.goal_sha256 ===
goalSha` (line 638). A tampered `goal.json` therefore steers a file read before it is
rejected as `goal_mutated`. Outcome is still fail-closed
(`handoff_revision_drift` / `handoff_missing`, or an `unexpected_error` on EACCES), so
impact is limited to an oracle on file existence outside the intended scope. Move the
`goal_mutated` check to immediately after `readJournal`, before any use of goal-supplied
paths, and route `handoff_path` through `resolveInRepo`.

---

## 10. LOW — `parseArgs` edge cases

**Location:** `.tad/scripts/yolo-recovery.mjs:766-785`.

- Duplicate flags silently last-wins (`--slice S1 --slice S2` → `S2`).
- Positional arguments are collected and then discarded by every caller — a typo like
  `verify --run D S1` loses `S1` with no error.
- Any value beginning with `--` turns the flag into boolean `true`; `need()` then reports
  `missing_flag`, so this fails closed, but the message points at the wrong flag.

No argument injection is possible (no value reaches a subprocess). Recommend rejecting
duplicate flags and non-empty `positional` as `UsageError`, so the failure names the real
mistake.

---

## Injection — clean

`git()` (`:152-158`) uses `execFileSync` with no `shell` option and three fully literal
argument arrays: `['rev-parse','--show-toplevel']`, `['rev-parse','HEAD']`,
`['status','--porcelain']`. **No user-controlled value reaches git at all**, so neither
command injection nor `git`-flag argument injection (`--upload-pack=`, `--output=`) is
reachable. `cwd` is `process.cwd()`. No other subprocess is spawned. No finding.

## Path traversal — the guard works as designed

- `..` escapes, an absolute path outside scope, and the scope root itself are refused
  (`path_escape`, exit 2) — covered by `casePathGuard`.
- A symlinked final component pointing outside is refused; re-verified independently
  (Finding 7, case F).
- `realpathDeepest` resolves the deepest existing ancestor and reuses that same resolved
  string for all subsequent filesystem operations, so the check and the use agree — the
  classic "validate one path, operate on another" split does not exist here.
- Because `path.resolve` collapses `..` lexically before any filesystem access, a
  `link/../../..` input never traverses the symlink at the OS layer either; the tool
  operates on the same normalized string it validated. Consistent.
- The 4096-iteration bound in `realpathDeepest` is only reachable with a >4096-segment
  path, which fails at the syscall layer first. Not exploitable.
- TOCTOU between the `lstat`/hash and the later write is inherent to the design (the
  operator performs the action between `action-start` and `reconcile`) and is squarely
  inside the excluded threat model.

## Denial of service / unbounded work

Beyond Finding 5: `readJournal` slurps the whole journal via `readFileSync`, and
`estimateTokens` is O(n) over the packet — both explicitly accepted in handoff §3.2
("所有循环有界；读取 journal 对 Phase-1 dogfood 规模足够，无需提前优化"), and both bounded
by files the Conductor writes. Deeply nested JSON is handled safely: V8's `JSON.parse` is
non-recursive, and the one recursive call — `JSON.stringify(body)` on a clobbered
`checkpoint.json` at `:1070` — raises a `RangeError` that the top-level handler in
`runCli` converts to exit 1 / `unexpected_error`, with `resume --rebuild-derived` as the
documented repair. No unbounded loop driven by file content. No finding.

## Does the guide's security warning overclaim?

**§7's `written_by_id != executor_id` warning: accurate.** It correctly names the check as
a process-integrity boundary rather than provenance, correctly says the identifiers are
self-declared, correctly scopes out the malicious same-user process, and correctly places
the compensating control on Gate 3. It understates *how* weak the check is (Finding 4)
but does not misstate it.

**§2's authority order: overclaims.** "a fully parseable `journal.jsonl` **and the
evidence it points at**" (guide:45) and the matching code comment
(`yolo-recovery.mjs:645-646`, "Authority level 2 includes the journal's EVIDENCE
POINTERS") both promise a transitive evidence check that is implemented one level deep
(Finding 1). Either implement it, or amend both sentences to say "and the receipt it
points at" — the code and the prose must not disagree about which authority level is
actually enforced.

**§7's "every referenced evidence file exists and hashes exactly as declared": accurate at
`verify` time**, silent about the fact that this is never re-checked. It should say so.

---

## Verdict

Findings 1 and 2 each break a protection the tool explicitly claims, are reachable by a
non-malicious operator or by ordinary repository events, and are invisible to the current
test suite. Both need a fix plus a red-state test before Gate 3.

CRITICAL: 0 | HIGH: 2 | MEDIUM: 3 | LOW: 5

VERDICT: FAIL

---

## Incremental re-review (post-d7813c6b..HEAD) — independent verifier

Verifier model: harness=opencode | model=ox-alpha-free (opencode-go/ox-alpha-free)
date: 2026-08-25
verified_head: fc7a07fceb1849e07075974c4475cecb945409d0
(round 1 verified head: 019cdeb1e7137beaa6fe024ab30cb33a5d0348fe — FAIL, finding 1 OPEN;
re-verified after commit fc7a07fc under TAD Layer-2 blocking semantics: P0/P1 blocking,
P2/LOW = non-blocking hardening follow-ups recorded in NEXT.md)

Method: every finding below was checked against the final code AND, where marked
"reproduced", against a throwaway git fixture run with the script at the verified
head. Contract suite at verified head: all cases PASS (including new
`binding-and-closure`). Findings were verified by observation, not reading alone.
Line citations are at the round-2 verified head fc7a07fc (round-1 rows 2/5/9 were
re-checked unchanged; their anchors sit before the +19-line insertion and are identical).

| finding | severity | status (RESOLVED/OPEN) | evidence (file:line quotes) |
|---|---|---|---|
| 1. Evidence never re-checked after verify — a verified slice survives destruction of its Gate/review evidence | HIGH (P0) | **RESOLVED** (fc7a07fc) | Round 1 (head 019cdeb1) was OPEN: loadRun re-checked only the receipt; the PoC (overwrite gate.md + delete review.md after verify) still returned `status` exit 0 PASS. FIXED by fc7a07fc: `loadRun` now walks `const boundEvidence = [...(Array.isArray(rec.gate_evidence) ? rec.gate_evidence : []), ...(Array.isArray(rec.review_evidence) ? rec.review_evidence : [])]` and for each entry runs `anchorAtRepoSafe(ev.path, repoRoot)` + existence/lstat check → binding blocker `verified_evidence_missing`, and `sha256File(eAbs) !== ev.sha256` → `verified_evidence_hash_mismatch` (yolo-recovery.mjs:802-815), routing to HONEST_PARTIAL (:818-829) which blocks every mutating command. Receipt is hash-pinned before parse, so these arrays/sha256 fields are exactly what validateVerificationReceipt already validated at verify time; evidence paths additionally get a read-time scope assertion. Red/green tests added: authority-conflicts (j2) destroyed gate evidence → exit 1 `verified_evidence_missing`; (j3) tampered review evidence → exit 1 `verified_evidence_hash_mismatch` (yolo-recovery.test.mjs:433-450). Manual repro of the round-1 attack at fc7a07fc: verify exit 0, then overwrite gate.md + delete review.md → `status` exit 1, `"result":"HONEST_PARTIAL","reason":"verified_evidence_hash_mismatch"`, blockers `[verified_evidence_hash_mismatch (evidence/gate.md), verified_evidence_missing (evidence/review.md)]`; follow-on `checkpoint` also refused exit 1. Fails closed. Full contract suite green at fc7a07fc (all cases RESULT=PASS). |
| 2. Repo-relative inputs anchored at `process.cwd()`, freezing a wrong handoff | HIGH (P0) | RESOLVED | New `anchorAtRepo` (yolo-recovery.mjs:190-192 `path.isAbsolute(input) ? input : path.join(repoRoot, input)`), applied in `resolveRunDir` (:207) and `resolveInRepo` (:214); covers `--handoff`/`--goal-file` (:1001-1002), `oracle_path` (:1024), receipt evidence paths (:942), journal-sourced `receipt_path` (:778) and `goal.handoff_path` (:764). Regression test added (yolo-recovery.test.mjs:735-749, init from `sub/` with decoy `sub/docs/handoff.md`). Reproduced fix: init from subdirectory freezes `handoff_path = docs/handoff.md` with the APPROVED file's sha256; decoy ignored. |
| 3. Empty evidence files accepted as Gate/review PASS | MEDIUM | RESOLVED | yolo-recovery.mjs:965-968 `if (fs.statSync(evAbs).size === 0) throw new ContractError('receipt_evidence_empty_file', …)`. Reproduced: zero-byte gate evidence → `verify` exit 1, `reason:"receipt_evidence_empty_file"`. Note (residual hardening, not the reported defect): the remediation's second half — requiring a `PASS` anchor inside the referenced file's CONTENT, mirroring `checkDogfoodEvidence` — was not adopted; a non-empty placeholder hashing as declared would still pass. |
| 4. `written_by_id != executor_id` unbound and untyped | MEDIUM | OPEN — **non-blocking P2 hardening** (typed checks exist; binding residual) — deferred to NEXT.md follow-up | Typed half FIXED: yolo-recovery.mjs:937-945 `if (typeof v !== 'string' \|\| v.trim().length === 0 \|\| v.length > 200) throw …('receipt_identity_malformed')` plus trimmed comparison at :943. Reproduced: `executor_id:{}` + `written_by_id:{}` → exit 1 `receipt_identity_malformed`. Unbound half NOT FIXED: `executor_id` is still bound to nothing frozen — the init-time goal-spec field list (yolo-recovery.mjs:1035) and `GOAL_REQUIRED` (:224-228) contain no `executor_id`, and nothing compares the receipt's `executor_id` to any value chosen before work started. An invented per-slice executor identity at receipt-writing time still satisfies the check. Guide §7's self-declared-identifier warning remains accurate; compensating control is Gate 3. |
| 5. `git status --porcelain` without maxBuffer bricks every command | MEDIUM | RESOLVED | yolo-recovery.mjs:164-171: `status` wrapped in try/catch, `dirtyPaths = null` on failure, `dirty_count: dirtyPaths === null ? null : dirtyPaths.length` — observation-only data can no longer fail any command, and the misleading `git_unavailable` from ENOBUFS is gone (the degrade-to-null alternative named in the remediation). |
| 6. Journal-recorded `target`/`receipt_path` re-resolved with no scope assertion | LOW | OPEN — **non-blocking P2/LOW hardening** (read-only oracle requiring prior journal tampering) — deferred to NEXT.md follow-up | `receipt_path` FIXED: yolo-recovery.mjs:778+ `anchorAtRepoSafe(v.receipt_path, repoRoot)` runs `assertInside` on read. Reconcile targets NOT fixed: :1289 `const targetAbs = path.resolve(r.repoRoot, unknown.target)` and :1305 `path.resolve(r.repoRoot, pending.target)` have no `assertInside`. Reproduced at verified head: hand-appended `action_started` with `target":"../../../../../../../../etc/hosts"` → `reconcile --outcome outcome_unknown` writes `{"action_id":"AX",…,"observed_sha256":"c7dd0e2ed261ce76…"}` into the ledger — the real sha256 of `/etc/hosts` (a first attempt with 7×`../` recorded `ABSENT` for `/private/var/etc/hosts`, equally outside scope). Read-only, requires prior journal tampering, does not produce false verified progress — as originally assessed. |
| 7. Scope guard protects run-dir path but not ledger files inside it (symlinked `journal.jsonl`) | LOW | OPEN — **non-blocking P2/LOW hardening** (edge of excluded threat model) — deferred to NEXT.md follow-up | Unchanged by any commit since 323c380d: `readGoal` (:230-260), `readJournal` (:262-294) and `writeAtomic` (:522-532) open/write the four ledger files by path with no `lstat` regular-file check; `fs.writeFileSync`/`appendFileSync` follow symlinks. A symlinked `journal.jsonl` inside an in-scope run dir still redirects the ledger outside the repo. Creating that symlink is not something a documented command does. |
| 8. `writeAtomic` O_TRUNC/symlink-following write, default 0644, no fsync | LOW | OPEN — **non-blocking P2/LOW hardening** (informational) — deferred to NEXT.md follow-up | yolo-recovery.mjs:522-532 byte-equivalent to the reviewed version: `fs.writeFileSync(tmp, content)` (default `'w'` = O_CREAT\|O_TRUNC, symlink-following; default mode 0644), `fs.renameSync`, no fsync of temp file or directory. Informational, as originally assessed. |
| 9. `goal.handoff_path` consumed before the goal-integrity check | LOW | RESOLVED | yolo-recovery.mjs:727-736: order is now `readGoal` → `readJournal` → `goal_mutated` throw (:732-734) → `reduceRun` (:736) → only THEN `anchorAtRepoSafe(goal.handoff_path, repoRoot)` (:764). A tampered `goal.json` is rejected before any goal-supplied path is touched, and the path is scope-asserted when it is used. |
| 10. `parseArgs`: duplicate flags last-wins, positionals dropped, `--`-values become boolean | LOW | OPEN — **non-blocking P2/LOW hardening** (fails closed; wrong-flag message only) — deferred to NEXT.md follow-up | yolo-recovery.mjs:987-1006 semantically identical to the reviewed version; every caller still destructures only `{ flags }` (:1472) so positionals remain silently discarded, duplicate flags last-win, and a `--`-prefixed value yields `true` (fails closed via `need()` :1008-1012 with the wrong flag named). |

Round-2 verification at fc7a07fc (2026-08-25): full contract suite run — all cases
RESULT=PASS (including authority-conflicts with new negatives (j2)/(j3), and
binding-and-closure). Original round-1 P0 attack manually reproduced against a fresh
throwaway fixture: verify exit 0 → overwrite gate evidence + delete review evidence →
`status` exit 1 HONEST_PARTIAL with blockers `verified_evidence_hash_mismatch` +
`verified_evidence_missing`, and `checkpoint` refused exit 1. Fails closed.

fc7a07fc diff scrutiny (`git show fc7a07fc`, +49 lines across the two files): adds only
(a) the boundEvidence re-validation loop in loadRun — pure hardening, no new write path,
no new subprocess, every journal/receipt-sourced path re-runs `anchorAtRepoSafe`; and
(b) the Gate 4 corrective amendment to the test file's dogfood ALLOW_EXACT list (exact
paths of TAD lifecycle artifacts — meta-test scope config, not runtime security
behavior of the recorder). No new P0/P1.

Attention items from the re-verification brief, checked at verified head:
- **Capsule budget enforcement**: now checked BEFORE the first write — init renders a
  preview packet from a synthetic event (yolo-recovery.mjs:1070-1085) and throws
  `capsule_over_budget` with nothing written; `finish()` re-checks (:1393-1401). Enforced.
- **Receipt forgery surface**: reduced further — receipt must re-read as a bound
  Conductor PASS receipt at every load (:786-791), typed distinct identities (:937-945),
  gated head may be HEAD or an ancestor (:917-931), and verify additionally journals
  `observed_head_at_verify` + `dirty_paths_at_verify` (:1195-1196) instead of implying a
  clean tree.
- **Author separation**: `written_by !== 'conductor'` (:932-934), typed non-equal ids,
  and loadRun re-assertion of `rec.written_by !== 'conductor' || rec.written_by_id ===
  rec.executor_id` (:789-791). Still self-declared identities (Finding 4 residual).
- **Lock handling**: NEW exclusive lockfile `withRunLock` (:685-706, O_EXCL) wraps
  checkpoint/verify/action-start/reconcile/stop, combined with reduce-before-write
  `appendEventGuarded` (:659-678). Note: `init`'s transactional block (:1090-1119) does
  not take the lock — a same-name concurrent-init race remains theoretically possible;
  low impact, not one of the original findings.
- **Secrets/PII in emitted files**: journal now stores `dirty_paths_at_verify`
  (worktree-relative porcelain paths) — repo-relative paths and hashes only; the new
  packet sections are static safety prose. No secret/PII exposure introduced.

Post-d7813c6b commits spot-check (Step 3): `00570c00`, `0ccd30cd`, `84c3666c` —
`git show --stat` each confirms only `.tad/scripts/yolo-recovery.mjs` +
`.tad/scripts/yolo-recovery.test.mjs` changed; full diffs show exclusively
`renderRecovery` prose (new VERIFICATION MODEL / PROHIBITIONS sections, PENDING ACTION
classification rule, inspect-don't-discard wording) and matching test assertions. All
added text is static safety guidance containing field names and hashes placeholders
only — no sensitive material leaked.

New defects introduced since d7813c6b: none (commits d7813c6b..fc7a07fc reviewed in
full: 00570c00 / 0ccd30cd / 84c3666c are renderRecovery prose + test assertions only;
fc7a07fc is the boundEvidence hardening + test ALLOW_EXACT amendment — see round-2
scrutiny above. The init-lock observation is pre-existing surface, noted for
completeness, not a regression.)

incremental_verdict (round 2, TAD blocking semantics: PASS requires all P0/P1
RESOLVED at verified head and no NEW P0/P1 since d7813c6b): **PASS**

- P0/P1 at fc7a07fc: finding 1 RESOLVED, finding 2 RESOLVED. All P0/P1 resolved.
- Remaining opens (4, 6, 7, 8, 10) are MEDIUM-typed-check-residual and LOW/P2
  hardening items, non-blocking under TAD Layer-2 semantics; recorded here as
  NEXT.md follow-up candidates.
- No new P0/P1 introduced d7813c6b..fc7a07fc.

(Round 1 verdict at 019cdeb1 was FAIL on finding 1; superseded by this round-2 PASS
after commit fc7a07fc demonstrably closes it.)
