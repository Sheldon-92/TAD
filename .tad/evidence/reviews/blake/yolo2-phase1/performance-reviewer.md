Model: harness=claude-code | model=claude-opus-5 | route=host

# Layer 2 Performance Review — YOLO 2.0 Phase 1 recovery slice

Scope read: `.tad/scripts/yolo-recovery.mjs` (full), `.tad/scripts/yolo-recovery.test.mjs` (full),
`HANDOFF-20260824-yolo2-phase1-recovery-slice.md` §3.2 + §8.

Calibration applied from §3.2: *"所有循环有界；读取 journal 对 Phase-1 dogfood 规模足够，无需提前优化。"*
Nothing below is a speculative-optimisation recommendation. Every cost claim is a measured number.

---

## 0. Measured baseline

All measurements on this host, Node v24.7.0, macOS (darwin 25.5.0).

| Measurement | Value |
|---|---|
| `node .tad/scripts/yolo-recovery.test.mjs --case lifecycle-e2e` (first, cold FS/module cache) | **10.697 s** wall (2.07 s user, 34% CPU) |
| same command, warm | **1.983 s** wall (1.35 s user, 98% CPU) |
| full suite `node .tad/scripts/yolo-recovery.test.mjs` | **21.906 s** wall (13.83 s user, 97% CPU) — 7/9 cases PASS; `dogfood-evidence` and `required-evidence` FAIL only because the Phase-1 evidence artifacts (this file included) do not exist yet. Not a performance signal. |
| bare `node` process spawn | 151 ms each (measured 10× = 1512 ms) |
| `git rev-parse HEAD` | 50 ms each (measured 10× = 503 ms) |
| `git status --porcelain` **in this repo** | **225 ms each** (measured 3× = 676 ms) |

The suite is 97% CPU-bound in process startup: 67 `cli([…])` call sites × 1 `node` spawn each,
23 `makeRepo()` sites × 6 `git` spawns each, plus 6–9 `git` spawns inside every CLI invocation.
That is the whole 21.9 s. Nothing in it grows superlinearly.

### Per-command I/O, measured (not asserted)

Instrumented in-process by wrapping `fs.readFileSync` and interposing a counting `git` shim on
`PATH`, then calling the exported `runCli()` against a throwaway git fixture:

| command | `git` subprocesses | `goal.json` reads | `journal.jsonl` reads | handoff reads | receipt reads |
|---|---|---|---|---|---|
| `init` | 6 | 3 | 1 | 2 | – |
| `status` | **6** | 2 | 1 | 1 | 1 per verified slice |
| `resume` | **6** | 2 | 1 | 1 | 1 per verified slice |
| `checkpoint` | **9** | **4** | **3** | 2 | 2 per verified slice |
| `verify` | **9** | **4** | **3** | 2 | **3** (the receipt under test) |

---

## 1. Unbounded loop / recursion / data-controlled bound

**Finding: none. This is a clean PASS on the §3.2 "所有循环有界" requirement.**

Enumerated every loop construct in the source (`for`, `for…of`, `forEach`, `map`, `filter`,
`some`, `find`, `reduce`). There is **no `while` loop and no recursion anywhere** in
`yolo-recovery.mjs`. Every loop is either a single pass over a finite in-memory collection or a
hard-capped counter:

- `realpathDeepest` (`yolo-recovery.mjs:130`) — the only loop that could conceptually run away
  (walks up a path). Explicitly capped at 4096 iterations **and** has two independent exit
  conditions (`fs.existsSync(cur)`, `parent === cur`). Correct.
- `readJournal` (`:243`) / `reduceRun` (`:283`) — one pass over journal events. Bound is the
  journal's own line count; the journal is append-only under a single-writer contract enforced at
  `:602-607`. Not attacker-controlled in any path the CLI exposes.
- `parseArgs` (`:769`) — bound is `argv.length`.
- `checkEvidence` (`:739`) and the verified-evidence loop (`:646`) — bound is the length of an array
  inside an operator-supplied JSON file (`receipt.gate_evidence` / `review_evidence`). This is the
  only bound in the program that comes from file *content* rather than from the run's own history.
  Each element costs one `fs.existsSync` + `lstat` + full-file sha256. A receipt declaring 100k
  evidence entries would do 100k file hashes. The receipt must be conductor-authored and inside the
  repo, so this is a self-inflicted foot-gun, not an attack surface. Recorded as **P2-4**.

## 2. O(n²) or worse on journal length / evidence list / capsule size

**Finding: no growth term that bites. Measured, not estimated.**

I built valid synthetic journals and timed `status` (the command that does a full read + full
reduce + full render) against journal length:

| events | journal size | `status` wall |
|---|---|---|
| 10 | 2.2 KB | 347.3 ms (cold) |
| 500 | 106.9 KB | 169.7 ms |
| 2 000 | 428.7 KB | 145.0 ms |
| 8 000 | 1 717.7 KB | **150.7 ms** |

**Journal length is not the cost driver at all up to 8 000 events / 1.7 MB — 16× more events, flat
wall time.** The floor (~150 ms) is the 6 `git` subprocesses. This directly validates the handoff's
"reading the journal is sufficient for Phase-1 dogfood scale" call: it is sufficient far beyond
Phase-1 scale.

Growth terms that exist but do not bite, for the record:

- **Cumulative O(C·n)** across a run of C commands, since every command re-reads and re-reduces the
  whole journal. At n = 8 000 that is 150 ms per command — the rebuild-from-journal design pays for
  itself in correctness. Explicitly sanctioned by §3.2.
- `reduceRun:337` `unknownActions.some(...)` and `:356` `findIndex` run per `action_reconciled`
  event → O(R·U). **U is capped at 1 through the CLI**: `outcome_unknown` sets state
  `HONEST_PARTIAL` (`:380`), and `action-start` is refused by `refuseIfHonestPartial`
  (`cmdActionStart:939`) plus the blind-retry guard (`:936`), so a second concurrent unknown cannot
  be recorded. Only a hand-forged journal could make U large, and even then n = 8 000 measures flat.
- `loadRun:646` re-hashes **every** verified receipt on **every** command, twice per mutating
  command (two `loadRun` calls). O(C·V). V is bounded by the frozen slice plan in `goal.json`
  (2 in the fixture). Non-issue at any realistic slice count.
- `state.verified_slices.includes(slice)` (`:730`, `:893`) — linear array scan, V small. Fine.
- Capsule size: `renderRecovery` grows linearly with `goal.success` / `non_goals` /
  `forbidden_scope` (frozen at init) and with the distinct-candidate-slice count. `estimateTokens`
  walks the text ~2× (once per section at `:592`, once for the whole text at `:594`) with a
  code-point iterator — linear, and the `capsule_over_budget` guard (`finish:1099`) fails closed
  rather than trimming. The `status-capsule` fixture exercises this at 400 × 120 chars ≈ 52 KB and
  the suite stays fast. Correct by construction.

## 3. Repeated full-file reads / re-hashing inside one invocation

These are the only findings with a real (if small) cost, and all are trivially hoistable. Counts are
the measured table in §0.

### P2-1 — `readGitIdentity` is called 2–3× per invocation; 9 `git` subprocesses per mutating command

`withRun` (`yolo-recovery.mjs:856`) calls `readGitIdentity(cwd)` **solely to obtain `repoRoot`**,
discards `head` and `dirty_count`, and then `loadRun` (`:619`) immediately re-derives the identical
identity from the same cwd in the same instant. Mutating commands call `loadRun` a second time after
the append (`cmdCheckpoint:897`, `cmdVerify:924`, `cmdActionStart:963`, `cmdReconcile:1051`,
`cmdStop:1090`) for a third `readGitIdentity`.

Each `readGitIdentity` spawns three subprocesses (`rev-parse --show-toplevel`, `rev-parse HEAD`,
`status --porcelain`). Measured: **6 subprocesses per `status`/`resume`, 9 per `checkpoint`/`verify`**.

The cost term that is data-controlled: `git status --porcelain` scales with worktree size and dirty
count. **Measured at 225 ms per call in this repo** (the handoff §8.4 itself notes the working tree
is dirty). So a `checkpoint` here pays ~675 ms of porcelain, ~450 ms of it purely redundant.

Trivially hoistable: `withRun` needs only `git rev-parse --show-toplevel`, or should pass its
`identity0` into `loadRun`. The third call (post-append) has a real reason — `dirty_count` is
re-observed after the journal write for the recovery.md "working tree observation" line — so only
the first is pure waste.

**Does it bite at Phase-1 scope? No.** Sub-second per command against a human-paced CLI. P2.

### P2-2 — `readGoal` reads `goal.json` twice; 4 reads per mutating command

`readGoal` does `JSON.parse(fs.readFileSync(file, 'utf8'))` at `:205` and then `sha256File(file)` at
`:229`, which re-reads the same file from disk. ×2 `loadRun` calls = **4 reads per `checkpoint`/`verify`**
(measured). One `fs.readFileSync(file)` buffer would serve both the hash and the parse. `goal.json`
is small and frozen; this is hygiene, not a bottleneck. P2.

### P2-3 — the receipt under test is read 3× in one `verify`

`validateVerificationReceipt` reads it for `JSON.parse` at `:698` and re-reads it for
`sha256File(abs)` at `:761`; the post-append `loadRun` then hashes it a third time at `:651`
(measured: 3). Same one-buffer fix. Each `gate_evidence` / `review_evidence` file is read once in
`checkEvidence` and, for already-verified slices, once more per `loadRun`. P2.

## 4. Whole file into memory where size is unbounded by design

### P2-4 — `sha256File` slurps, it does not stream

`sha256File` (`:95-97`) is `crypto.createHash('sha256').update(fs.readFileSync(p))` — the entire
file lands in one Buffer. It is applied to paths of genuinely unbounded size:

- `--target` in `action-start` (`cmdActionStart:952`) — any regular file in the repo.
- `--evidence` in `reconcile` (`:1005`, `:1044`).
- every `path` in `receipt.gate_evidence` / `review_evidence` (`checkEvidence:748`).

Node's `readFileSync` throws `ERR_FS_FILE_TOO_LARGE` above ~2 GiB. That escapes as a plain `Error`,
so `errorResult` (`:1127`) classifies it as a contract failure with
`reason: 'unexpected_error'` — it **fails closed**, but with a reason that does not name the real
problem. A streaming hash would remove the ceiling; at Phase-1 scope the targets are markdown
guides. P2.

### P2-5 — `git status --porcelain` is buffered into `execFileSync`'s 1 MiB default `maxBuffer`

`git()` (`:152-158`) passes no `maxBuffer`. Node's default is 1 MiB. A worktree with roughly 10k+
dirty paths overflows it; I confirmed the failure mode is `ENOBUFS`, which `git()`'s catch converts
into `ContractError('git_unavailable')` — again fail-closed but misnamed. Current repo:
`git status --porcelain` = **270 bytes / 5 lines**, three orders of magnitude below the limit. Also
note `readGitIdentity:168` only uses `.length` of that split, so the whole porcelain body is
materialised, split into an array, and thrown away. P2.

`readJournal:235` reads the whole journal into a string, then `raw.split('\n')` (`:240`) allocates a
second full copy as an array, then `events` a third — roughly 3× file size resident. At the measured
8 000-event / 1.7 MB ceiling that is ~5 MB. `appendEvent:603-604` re-reads the whole journal and
allocates another full line array purely to count lines; that read is *semantically required* (the
single-writer re-check must happen after the reduce, not before), so it is correctly placed, not
hoistable.

## 5. Test-suite runtime hazards

### P2-6 — no `timeout` on any child process; a hung child hangs the suite forever

`cli()` (`yolo-recovery.test.mjs:59`) `spawnSync(process.execPath, …, { cwd, encoding: 'utf8' })` and
`git()` (`:68`) `execFileSync('git', …)` pass **no `timeout` option**, and there is no suite-level
watchdog. Structurally this is an unbounded wait. Realistic probability is low: the CLI never reads
stdin, `makeRepo` explicitly sets `commit.gpgsign false` (`:91`), and all git work is on local temp
repos with no remotes and no credential path. Adding `timeout: 30000` to both helpers would close it
outright. P2.

### Temp-dir growth: bounded and measured, not a hazard

`TMP_DIRS` accumulates **every** fixture dir for the whole run and only deletes them in `main`'s
`finally` → `cleanupTmp` (`:1096-1102`), so peak usage is the *sum* of all fixtures, not the max of
one. I sampled the real peak during a full suite run:

- **peak concurrent temp dirs: 48**
- **peak temp disk: 7 636 KB (7.6 MB)**
- **leftover dirs after normal exit: 0** (verified by glob after the run)

That is bounded and cleaned. `cleanupTmp` also `chmod 0755`s first, which correctly handles the
`atomic-write` case's `chmod 0555` dir (`:600`). The only leak path is `SIGKILL`/hard crash, where
`finally` never runs — acceptable for a dev-machine suite. Not raised as a numbered finding.

### Fixture cost is linear, not superlinear

`buildDogfoodFixture` (`:799`) is O(3 runs × ~9 files) and is rebuilt once per `tamper()` call —
1 clean + 29 negatives = 30 builds ≈ 270 small file writes plus as many sha256 of tiny files.
Linear in the negative-control count. `caseAuthorityConflicts` calls `makeRepo()` 16 times, each
~6 git spawns — linear. `caseStatusCapsule`'s deliberately fat fixture is 400 × ~130 chars ≈ 52 KB
and renders in one linear pass. **No fixture in the suite has superlinear cost.**

---

## Summary

| # | Finding | Class |
|---|---|---|
| P2-1 | `readGitIdentity` duplicated 2–3× per invocation → 6/9 `git` subprocesses per command; `git status --porcelain` measured 225 ms/call in this repo | P2 |
| P2-2 | `readGoal` re-reads `goal.json` for its hash → 4 reads per mutating command | P2 |
| P2-3 | `verify` reads the receipt file 3× (parse, hash, post-append re-hash) | P2 |
| P2-4 | `sha256File` slurps unbounded-size files (`--target`, `--evidence`, evidence lists) instead of streaming; >2 GiB surfaces as `unexpected_error` | P2 |
| P2-5 | `git status --porcelain` buffered into the 1 MiB default `maxBuffer`; overflow reported as `git_unavailable` (current repo: 270 bytes) | P2 |
| P2-6 | Test suite sets no `timeout` on `spawnSync`/`execFileSync` — structurally unbounded wait, no watchdog | P2 |

No unbounded loop. No recursion. No attacker- or data-controlled loop bound in any CLI-reachable
path. No O(n²) term that bites: journal cost measured **flat from 500 to 8 000 events**. Peak test
temp usage measured at 7.6 MB with zero leaks. Every finding above is hygiene that costs
milliseconds at Phase-1 dogfood scale, exactly as §3.2 anticipated — none is blocking, and none
justifies restructuring this code now.

VERDICT: PASS
P0: 0 | P1: 0 | P2: 6
