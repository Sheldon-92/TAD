# HANDOFF-20260904-publish-v2440-bundle — Publish v2.44.0 (3 accepted tracks)

**Task ID**: `TASK-20260904-PUBLISH-V2440` | **Owner**: Blake | **Author**: Alex
**Created**: 2026-09-04 | **Status**: READY FOR BLAKE
**Mode**: publish-only (stops after publish verification; NO sync)

---

## 1. Execution Mandate (accepted 2026-09-04, conversation)

Supersedes the earlier v2.43.1-exact mandate (same session, abandoned before any
mutation — zero remote actions taken under it).

- **Outcome**: publish **v2.44.0** = push release commit **R** (child of `f8af5be4`,
  version + CHANGELOG only) to `origin/main` (fast-forward) + create annotated tag
  `v2.44.0` on R + push only that tag. Then verify and report. NO sync.
- **Target**: `https://github.com/Sheldon-92/TAD.git`, `refs/heads/main`,
  `refs/tags/v2.44.0`. Nothing else.
- **Consequence**: public main moves `2af31d1e` → R (9 accepted commits + release
  commit); new public tag `v2.44.0`. Local commits after R: none expected.
  Dirty/untracked files untouched (see §7).
- **Blast radius**: remote main + one tag. No downstream, no registry, no sync.
- **Recovery policy**: ambiguous push/tag result → `ls-remote` classify
  (completed / not-started / partial / unknown); completed never repeats;
  verified not-started retries same action; unknown blocks. Remote-ahead → STOP,
  never `--force`. Tag collision → STOP.
- **Forbidden**: `--force`, `--tags`, unscoped refspecs, combined shell chains
  (`&&`/`;` between the 3 remote actions), absorbing any out-of-scope file into R.

---

## 2. Background — what R puts on top of

`git log --oneline 2af31d1e..HEAD` (all local, none pushed; remote pre-state
`refs/heads/main = 2af31d1e`, tag `v2.44.0` absent — verified 2026-09-04):

| Commit | Track | Gate 4 |
|---|---|---|
| `ef8734f0` feat v2.43.1 backup repair + shared updater | ① v2.43.1 trio | PASS `GATE4-20260902-tad-update-v2431.md` (69/69 on `8b8c7877`) |
| `6ebb5457` KA docs (4 shell-portability patterns) | ① | same Gate 4 (declared scope) |
| `8b8c7877` fixture fix (Gate-4 finding, test-tooling only) | ① | accepted SHA |
| `bba6ce84` Builder P23 evolve + package | ② | PASS `GATE4-20260903-capability-builder-phase23-evolve-package.md` |
| `f61c1892` FW-health A impl (FR-1 + fixes + guards + fixtures) | ③ | PASS `GATE4-20260903-framework-health-phase2-remainder.md` |
| `1a256534` fix round (manifest rollback, atomicity, guards) | ③ | same Gate 4 |
| `b09aa052` fixture cleanup-prefix fix | ③ | same Gate 4 (accepted commits §2) |
| `3cff36f9` + `f8af5be4` docs bookkeeping | docs-only | post-Gate-4, docs only |

Evidence dir: `.tad/archive/handoffs/` (`HANDOFF`/`COMPLETION`/`GATE4` × 3 tracks).
Publish ban: LIFTED by FW-health A Gate 4 (2026-09-03). Remaining precondition was
this mandate — now accepted.

Read-only preflight by Alex (2026-09-04, current tree): `parity` exit 0;
`migration` exit 0; `tad.sh --verify-denylist` PASS; `pack-registry-driftcheck`
advisory only (3 skill-only installs, pre-existing, NOT a blocker). Re-run all in
§5 order anyway — pre-state, not a substitute.

---

## 3. Requirements

### 3.1 Release commit R (local preparation, NOT publish authority)

1. Derive bump scope with fixed-string search for OLD (`2.43.1`), e.g.
   `git grep -l -F '2.43.1'`. Survey 2026-09-04 found 28 tracked hits, but the
   list is ILLUSTRATIVE ONLY — historical references (e.g.
   `.tad/migrations/2.43.0-to-2.43.1.yaml`, journals, archived docs) must NOT be
   bumped. Update only the verifier-approved identity-marker set, then re-run the
   version gates to confirm.
2. `NEW = 2.44.0` (minor: Builder evolve/package + installer safety are
   feature-level). `OLD = 2.43.1`. `.tad/version.txt` is the source of truth.
3. Stage EXPLICIT PATHS ONLY (`git add <path>...`, never `git add -A`).
   R's diff must contain version bumps + CHANGELOG only.
4. Verify R's staged diff and hash against this mandate BEFORE any remote action.

### 3.2 CHANGELOG `[2.44.0]` entry (user-facing, on top of existing `[2.43.1]`)

Draft (finalize wording from the two Gate 4 docs, keep user-facing):

```markdown
## [2.44.0] - 2026-09-04

### Added

- **Capability Builder Phase 2 evolve + Phase 3 packaging.** The evolve protocol
  is live (including the no-signal idle gate) with eval-runner resource bounds,
  and one-Skill/one-Plugin packaging. Core-framework zero-change proof re-verified.
- **Installer data-safety remainder (framework-health Phase 2).** Manifest
  rollback restore, file-write atomicity, literal-prefix guards, and fixture
  cleanup-prefix family.

### Changed

- v2.43.1 trio included (macOS dangling-symlink backup repair + shared
  `$tad-update`/`/tad-update` updater with updater-only OpenCode entry).
```

### 3.3 Gate order (from physical root, record stdout/stderr/exit, branch exact)

Normative order, no parallelize/reorder; stop at first blocker. Exit `2` always
hard-blocks; exit `1` per-branch below:

1. `bash .tad/hooks/lib/release-verify.sh parity "$ROOT"` — `1` = report direction,
   heal ONLY via `parity --fix` for `claude-newer` under this mandate's scope
   (docs banners are byte-identical by Gate-4 record; any other direction → STOP).
2. `bash .tad/hooks/lib/derive-sync-set.sh --report "$ROOT"` (informational).
3. `bash .tad/hooks/lib/release-verify.sh version "$ROOT" "2.44.0" "2.43.1"` —
   `1` = stale-reference drift → STOP (minor may not proceed with drift).
4. `bash .tad/hooks/lib/release-verify.sh version-sweep "$ROOT" "2.44.0"` —
   Layer 1 `1` = BLOCKING; Layer 2 = advisory, record only.
5. `bash .tad/hooks/lib/release-verify.sh migration "$ROOT"` — `1` → STOP for minor.
6. `bash .tad/hooks/lib/pack-registry-driftcheck.sh` — `1` = advisory, record.
7. `tad.sh` is in range → `bash tad.sh --verify-denylist` must exit `0`.

### 3.4 Publish sequence (3 SEPARATE commands, separate messages/calls)

`<R>` = release-commit hash verified in §3.1 step 4. Never substitute HEAD.

1. `git push origin <R>:refs/heads/main`
2. `git tag -a "v2.44.0" <R> -m "v2.44.0 — bundle: v2.43.1 trio + Builder P23 + FW-health A"`
3. `git push origin "refs/tags/v2.44.0:refs/tags/v2.44.0"`

### 3.5 Post-publish verification

- `git ls-remote --heads origin refs/heads/main` == `<R>`.
- `git ls-remote --tags origin "refs/tags/v2.44.0" "refs/tags/v2.44.0^{}"` —
  annotated + peeled both resolve to `<R>`.
- `git status --short` shows no release residue (only the pre-existing §7 items).

---

## 4. Acceptance Criteria

- [ ] AC1 — version gates (§3.3 steps 3–4) exit 0 on the bumped tree.
- [ ] AC2 — CHANGELOG has `[2.44.0]` user-facing entry covering tracks ②+③.
- [ ] AC3 — parity / migration / denylist exit 0; pack-drift advisory recorded.
- [ ] AC4 — R's diff == version bumps + CHANGELOG only; dirty file absent from R
  (`git show --stat R` lists no §7 path).
- [ ] AC5 — remote `refs/heads/main` == `<R>` (exact hash in completion report).
- [ ] AC6 — `v2.44.0` annotated tag + peeled ref both == `<R>`.
- [ ] AC7 — dirty prestate unchanged: `shasum -a 256
  .tad/scripts/phase2-pair-driver.mjs` still
  `a76b5de93d65579cd672f6bcde154fd95377801ee9cea0bd035c8c337229eb9d`.
- [ ] AC8 — completion report records mandate ID/revision, all commands +
  exit codes, CAS transitions, pre/post SHAs, recovery classification (none
  expected), and remaining follow-ups (B-track, lite-mute — still local).

---

## 5. Key commands reference

```bash
repo_root=$(git rev-parse --show-toplevel)   # all git rooted here via git -C
git -C "$repo_root" status --short
git -C "$repo_root" log --oneline origin/main..HEAD
git -C "$repo_root" ls-remote --heads origin refs/heads/main
git -C "$repo_root" ls-remote --tags origin "refs/tags/v2.44.0" "refs/tags/v2.44.0^{}"
```

---

## 6. Ambiguous-result recovery

Timeout/disconnect/truncated output after any §3.4 action → do NOT blind-retry.
Read remote state (§3.5 commands), classify per mandate §1: completed (never
repeat) / verified not-started (retry same action, same transaction) /
partial (deterministic same-outcome recovery only) / unknown (BLOCK read-only).
A divergent visible result = boundary change → return to Alex. Unresolved
unknown stays read-only then blocks.

---

## 7. Explicitly OUT of scope (touch = VIOLATION)

- Dirty: `.tad/scripts/phase2-pair-driver.mjs` (M, 1 line, portable-ROOT fix —
  beneficial-looking but UNRELATED; prestate sha in AC7; leave in worktree).
- Untracked: `.tad/active/handoffs/HANDOFF-20260903-bugfix-lite-mute.md` (separate
  P2, implement via its own flow), `.worktrees/`, `progress/`.
- B-track design (1b搬运 + SC2/SC3 re-slim) — still in Alex design.
- Any `*sync` / downstream / registry write — publish-only mandate.
- Any `--force`, `--tags`, unscoped refspec, chained remote commands.

---

## 8. Friction preflight (§8.4) + MQ/Gate record

- **Friction-sensitive prerequisites**: `git` + network to `origin` + existing
  hook scripts (`release-verify.sh`, `derive-sync-set.sh`, `tad.sh`). No new
  dependency, tool install, auth change, or external reviewer required. If any is
  missing → fix-or-BLOCKED, never skip the gate that needs it.
- **MQ1–MQ6**: N/A with concrete reasons — scope is a FIXED commit set (no
  history search needed, MQ1); no new function/component references (MQ2); no
  data-flow or UI-state change (MQ3–MQ5); no technology decision (version bump
  only, MQ6). Evidence: §2 commit table + gate outputs.
- **Gate 1 (requirements)**: PASS — scope bounded (§2), AC runnable (§4).
- **Gate 2 (design)**: plan reviewed by HUMAN via mandate acceptance (2026-09-04,
  exact outcome/target/recovery binding in §1). Code review INHERITED (not
  skipped): three Gate-4 Layer-2 chains on disk — code-reviewer +
  spec-compliance + test-runner PASS, 0 P0 each track (see §2 paths). No new
  subagent spawned for the 3-command push/tag plan: review target is fully pinned
  by Gate-4 evidence + human mandate, which is the concrete reason (not a waiver).

---

## 9. Completion report must return (for Alex NEXT bookkeeping)

`<R>` hash, remote SHAs post-push, tag peeled SHA, gate exit-code table,
CHANGELOG diff stat, AC1–AC8 verdicts, confirmation §7 items untouched,
follow-ups (B-track, lite-mute) still local. Then STOP — Alex (Terminal 1) does
Gate-4-style verification + NEXT update; Blake does not publish anything further.

---

## 10. Amendment A1 — version-gate scoped exception (human-accepted 2026-09-04)

Context: Blake STOPPED per §3.3 at step 3 (`version` exit 1, 14 survivors, zero
remote actions). Completion: `.tad/active/COMPLETION-20260904-publish-v2440-STOPPED.md`.
Alex independently re-verified: R `40cf3234` (20 files, no §7 path), remote
`origin/main = 2af31d1e`, tag absent, 11/14 survivors sampled and classification
confirmed (fixture self-consistent pins / provenance comments / planning records /
CHANGELOG back-ref — none user-facing; 33 identity lines bumped, parity exit 0).

- **A1 ruling**: the exact 14 survivors in COMPLETION §3 are accepted as
  classified NON-DRIFT **for this release only**. This is DEGRADED_WITH_APPROVAL:
  rationale above + human sign-off 2026-09-04. It sets no precedent — P1 follow-up
  (version-gate exclusion contract update, separate design flow) is filed in NEXT.
- **Authorized**: execute §3.4 three-command sequence on hash-pinned
  `<R> = 40cf3234ade45a5ef1fdf0afc729b2537347a1ca` ONLY. Re-verify
  `git rev-parse R == 40cf3234` immediately before command 1; any other hash → STOP.
- **Unchanged**: all other mandate terms (§1 forbiddens, §6 recovery, §7
  out-of-scope, AC7 prestate check). CHANGELOG stays verbatim (P3 = no change).
- **Resume protocol**: re-run §3.3 steps 1–2 (parity + sync-report, expect 0),
  record step 3 as `1-ACCEPTED-PER-A1` (do NOT re-argue), steps 4–7 informational
  best-effort AFTER publish verification (they were never reached pre-publish;
  run post-publish read-only and report — migration/denylist expected 0,
  version-sweep Layer-2 advisory tolerated, pack-drift advisory). Then §3.4, §3.5,
  and a final completion report (AC1 marked `PASS-PER-A1` with pointer here).
