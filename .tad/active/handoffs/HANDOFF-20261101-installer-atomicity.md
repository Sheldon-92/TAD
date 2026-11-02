---
dispatch_id: hf-design-1
# Quality Chain Metadata
task_type: code
e2e_required: no            # behavioral evidence = data-safety fixture aw.* cases; release step3f consumes them (§4.7)
research_required: no        # design grounds in-repo: tad.sh source + two incident logs, all read first-hand at step1d
risk_triggers: [platform, data]
risk_card: .tad/evidence/risk-cards/risk-TASK-20261101-HF1.md
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
look_first: "§2 write-point table (every tad.sh mutation-phase write, line-anchored) → §4.1 helper contract → §4.4 version-stamp ordering → §4.5 rollback accounting → §4.6 fixture injection spec. Incident logs: ../grok-cloud/.tad/evidence/pm/2026-11-01-tad-409-upgrade/apply.log (in yun-sync sibling repo 商业洞见 path per epic §1) and agent-workshop sibling log; local copies of the load-bearing lines are quoted in §2.2."
real_paths:
  - "RP1 (Gate 4): in a throwaway copy of a real 4.0.8 project, run the new installer upgrade with fixture aw.1 injection armed → target tree byte-identical to pre-run, version.txt still 4.0.8, exit non-zero."
  - "RP2 (Gate 4): same copy, aw.2 injection (sync failure + one rollback-restore failure) → ROLLBACK-RESULT: partial line, MANUAL-RECOVERY block naming preserved backup + snapshot paths that exist on disk."
  - "RP3 (Gate 4): same copy, clean upgrade from a git-archive-shaped 4.0.10 source → exit 0, version.txt = 4.0.10, framework surfaces byte-match source."
---

# HANDOFF: Installer atomic writes + verified rollback accounting (v4.0.10 hotfix)

**Task ID:** TASK-20261101-HF1
**Epic:** EPIC-20261101-v4010-hotfix (single Phase; publish follows in-Epic)
**Ticket:** TICKET-20261101-installer-atomicity-rollback
**Created:** 2026-11-01
**Author:** Alex (Solution Lead) — dispatch hf-design-1
**Executor:** Blake (Execution Master)
**Reviewers:** Gate 3 = two independent non-Blake reviewers (code + run);
Gate 4 = independent Alex on RP1–RP3. Design author judges neither gate.

## 激活自报 (Activation Self-Report — Alex, hf-design-1)

- Role: Alex (Solution Lead), activated via `~/workspace/skills/tad-alex/SKILL.md`
  (thin shell) → this repo's originals, read this session before designing:
  `AGENTS.md`, `同步与推送.md`, `.tad/project-knowledge/principles.md`,
  `.tad/project-knowledge/patterns/_index.md` + full text of the two matching
  patterns (`shell-portability.md`, `release-sync.md`),
  `.tad/tasks/handoff-creation.md`, `.tad/gates/gate-canonical-checklist.md`,
  the Epic, and the HANDOFF house form (`HANDOFF-20261101-scan-surface.md` +
  `.tad/templates/handoff-a-to-b.md`).
- Grounding reads (first-hand, this session): `tad.sh` installer regions —
  copy_framework_files (L2583–2927), copy_pack_skill_smart (L2353–2468),
  generate_pack_meta (L2146–2190), projections (L4301–4421, L4825–4990),
  verify_install_complete (L2928–3173), snapshot/restore/rollback
  (L3499–3998), main flow + stamps (L6530–7136), EXIT trap (L4075);
  `.tad/tests/installer-data-safety-fixture.sh` (contract + case shapes);
  both incident logs in full (商业洞见 apply.log 63 lines; agent-workshop
  align log 883 lines, key bands read).
- Baseline probes recorded at `.tad/evidence/yolo/v4010-hotfix/design-baseline.txt`
  (bash -n exit 0; derive_framework_top_files emits version.txt, 23 files;
  suppressed-cp count in copy region = 4; echo stamps = 3; ROLLBACK-RESULT
  occurrences = 0; fixture `--case aw.1` → exit 2 unknown case).
- **Input anomaly, named:** on this machine
  `.tad/active/TICKET-20261101-installer-atomicity-rollback.md` is **0 bytes**
  (sync half-arrival; `wc -c` in baseline file). The design therefore grounds
  on the Epic's four-item scope text + the two incident logs + the ticket's
  fix directions as carried in the dispatch envelope. If the ticket's full
  text, once synced, contradicts any §4 decision, Gate 2 must flag it before
  Blake starts.
- Discipline: design only — no implementation code changed by this handoff;
  no git commands run in this repo; HALT → report only.

## Gate 2: Design Review

(chair: conductor-appointed independent reviewers — two-way, per canonical
Gate 2 and the Epic. Design author does not self-judge.)

- [x] Reviewer 1 — code lens (independence: not the design author):
      CONDITIONAL PASS (P0 = 0, P1 = 2, P2 = 4),
      `.tad/evidence/yolo/v4010-hotfix/p1-gate2-code.md`.
- [x] Reviewer 2 — domain lens (independence: not the design author):
      CONDITIONAL PASS (P0 = 0, P1 = 1, P2 = 3),
      `.tad/evidence/yolo/v4010-hotfix/p1-gate2-domain.md`.
- [x] High-risk (canonical Gate 2): risk card present —
      `.tad/evidence/risk-cards/risk-TASK-20261101-HF1.md`, five falsifiable
      assumptions A1–A5 each naming its check. The change touches the
      mechanism that writes and deletes files in real user projects.
- [x] Ticket-full-text check (see activation note): DISCHARGED by both
      lenses against the restored ticket text — no contradiction with §4
      (code report §"Ticket full-text cross-check"; domain report §1).
- Pilot: n/a — this change is a single installer + fixture + one protocol
  row, not a ≥3-unit isomorphic fan-out (Gate 2 code-lens G2-C6).

**Gate 2 Verdict:** CONDITIONAL PASS (dual lens; P0 = 0 both). All
conditions landed in the hf-design-2 revision (see the Gate 2 Revision
Record at the end of this handoff); a narrow re-review of the amendments
by a Gate 2 reviewer must complete before Blake starts S0.

---

## 1. Task Overview

### Background

The v4.0.9 fleet upgrade produced two real losses and a fleet-wide mixed
state (Epic §1). First-hand log evidence shows one mechanism behind both:
**the installer's forward write path overwrites live framework files in
place, and several of its write sites swallow errors**, so a write fault
mid-sync leaves truncated (0-byte or partial) files and a tree that is
neither the old nor the new version — while the version stamp has already
advanced, because `version.txt` is copied as an ordinary top file at sync
start. The rollback path, by contrast, already restores through
stage-verify-rename helpers — but its `.tad` step stops at the first failed
entry, and its closing accounting cannot say which entries failed.

This handoff designs the Epic's four fixes as one coherent change to
`tad.sh`, plus the regression cases that prove them and the release-wiring
that keeps them proven:

1. Atomic swap-in for framework writes (stage → verify → rename).
2. Rollback restores every entry from the preserved copies, verifies each,
   and reports the restored set truthfully (full / partial / none).
3. Version stamp moves to last: written only after everything else has
   landed and verified; first write failure stops the install.
4. Injected write-failure regression cases in the data-safety fixture,
   wired into release step3f evidence.

### Success Definition

With an arbitrary write failure injected at any framework write point:
the installer exits non-zero at the first failed write; no live framework
file is ever truncated; the target tree after rollback is byte-identical
to pre-run (or the shortfall is enumerated by name with preserved recovery
copies and a manual-recovery block); `version.txt` still reads the old
version. With no failure injected, a clean upgrade behaves exactly as
today, plus the stamp ordering.

## 1.5 Done check (Requirement — Alex step1d)

- Requirement (user, 2026-11-01 17:43 EST): "开 4.0.10 热修链，走完整流程修好再发"
  — the four ticket items, full TAD chain, publish only after the fix holds.
- Epic scope §2 (in/out) read and honored: §9 lists what this design
  deliberately does NOT do (EPERM root cause, content-layer interception,
  downstream recovery, backup subsystem).

## 2. Current State — the write path as it is (all anchors disk-verified)

### 2.1 Mutation-phase write points in `tad.sh`

| # | Site (line) | Form today | Failure behavior today |
|---|---|---|---|
| W1 | top-files loop, L2611 | `cp "$src/.tad/$tf" .tad/ 2>/dev/null \|\| true` | error swallowed; file truncated in place on mid-write fault |
| W2 | registry-only file, L2636 | `cp … 2>/dev/null \|\| true` | swallowed |
| W3 | framework dirs loop, L2643 | `cp -R "$sd/." "$dest/" 2>/dev/null \|\| true` | swallowed; per-file truncation inside the tree copy |
| W4 | non-pack skill copy, L2711 | `cp -R …` | propagates (abort) but truncation already done |
| W5 | pack smart copy, L2362/2368/2393/2418/2442; conflict resolution L2210/2224/2236 | bare `cp` per file | propagates, but the file being written is the live file |
| W6 | root files, L2779 | `cp "$src/$rf" ./ 2>/dev/null \|\| true` | swallowed — this is the AGENTS.md truncation site |
| W7 | pack meta, L2188 (`} > "$meta_file"`), called L2802 | shell redirect truncates the meta file, then writes | call site swallows with `\|\| log_warn … skipping` |
| W8 | `.codex/hooks.json`, L2832 | heredoc `cat >` direct write | mid-write fault leaves a partial hooks file |
| W9 | opencode/cursor projections, L4311 / L4372 / L4413 | bare `cp` onto the live file, `cmp` checked after | divergence is detected, but only after the live file was overwritten |
| W10 | claude settings L4869; claude agents L4950 | bare `cp`; L4950 stages to a tmp name + `cmp` (partial precedent) | L4869 overwrites in place |
| W11 | project-knowledge README seed copies, L6820 (install) / L6927 (upgrade) / L7010 (migrate) — added by S0 ruling R1 (hf-design-3) | `cp … 2>/dev/null \|\| true`; L6927/L7010 behind a create-only `[ ! -f … ]` guard, L6820 unconditional | swallowed; L6820 overwrites a pre-existing project-owned file in place (W6 class); the guarded sites can leave a partial new file |

Named exclusions from the write set (with reason):
- **Update-helper swap, L2614–2625** — already the atomic idiom
  (stage `.tad-update.sh.new.$$` in the same directory, then `mv -f`).
  §4.1 generalizes this precedent; the site itself is unchanged.
- **Restore helpers, L3649–3700** (`restore_dir_entry` / `restore_file_entry`)
  — already stage (`.rollback-staging`) → `_tad_tree_equal` byte-equality
  verify → remove → rename → re-verify. Not rewritten; §4.5 builds on them.
- **Pre-mutation copies** — `backup_existing` (L936–1056; its copies abort
  the run on failure, e.g. L1010) and `take_rollback_snapshot` (L3514):
  they write into the backup/snapshot locations, never onto live surfaces,
  and already fail-stop. Unchanged.
- **`generate_target_brain_index`, L2566** — writes `.tad/brain-index.md`
  via the in-tree generator; the file is deny-listed (never synced),
  regenerable on demand, and not part of the version surface. Its
  `log_warn`-and-continue semantics stay. **Gate 2 ruling (Q2, both
  lenses): exclusion ACCEPTED, with two named riders.** (i) Residual,
  stated explicitly: a write fault mid-generation can leave a partial
  brain-index sitting in the tree until the next regeneration — routing
  degrades, no state is corrupted, and absence is already covered by the
  read-and-empty rule; the exclusion is a recorded risk acceptance, not
  an oversight. (ii) Scope narrowing, named: Epic item 1 says "every
  framework write"; this exclusion narrows that at exactly this one
  point, and the conductor's Epic closeout must show the narrowing —
  the item must not be closed under an unqualified "全部" wording.
- **Deletions** — `apply_deprecations` (called L2723) and the rollback
  created-entry sweep: deletion has no truncate-in-place failure shape;
  unchanged.
- **Migrate user-data rescue copies, L6982/6985/6988/6991 (S0 finding
  U2)** — `cp -R "$MIGRATE_BACKUP_DIR/<old layout>/"* .tad/active/…
  2>/dev/null || true`. Named exclusion per the S0 Ruling Record
  (hf-design-3, R2): the destinations are project-owned user data, not
  framework surfaces — Epic item 1 bounds this hotfix's write set to
  framework writes, and converting these sites is a scope expansion
  (see ruling). Their failure shape also differs from FR1: the source
  of every copy is the run's own structural backup
  (`$MIGRATE_BACKUP_DIR`, L6950–6956 — a uniquely-named full copy of
  the pre-migration `.tad/`, never deleted or overwritten by the run,
  its path printed in the run's final report), so a failed rescue copy
  cannot destroy the only copy of the data; the residual defect is a
  silently incomplete rescued tree, recorded as risk-card assumption
  A6 with a follow-up ticket obligation (ruling R3). The four sites
  stay byte-unchanged in this hotfix and MUST be listed by name in the
  COMPLETION's AC7 remaining-hits list.
- Report/ledger writes in `finalize_update` run after `NEED_ROLLBACK=0`
  (success path only). Unchanged.

### 2.2 How the two incidents map onto the table

- **商业洞见** (apply.log, 63 lines): L49 — one pack-copy `cp` (W5 form)
  fails `Operation not permitted` writing
  `.agents/skills/web-frontend/checklists/frontend-quality.md`; the run
  aborts, but the in-place `cp` has already truncated that file to 0 bytes
  (GM-verified on disk). Sync had already landed `version.txt` from W1, so
  the tree reads 4.0.9 at `.tad/version.txt` while AGENTS.md is still the
  4.0.8 bytes — the mixed state. Rollback: step 1 fails on its FIRST
  manifest entry (`.tad/CHANGELOG.md`) and breaks (see §2.3); step 2's
  staged restores hit the same write fault; closing line reports
  `restored: [none]` — truthful, but it cannot name what failed where.
- **agent-workshop** (align log, 883 lines): 808 lines of
  `tad.sh:2185/2186: printf: write error: Operation not permitted` — that
  is W7's block-redirect write region inside `generate_pack_meta`
  (L2146–2190), swallowed per skill at L2802, so sync "completes" with 24
  files updated and broken meta. Later `cat: write error` precedes
  `Installation failed` (the W8/verify band). AGENTS.md ends truncated to
  0 bytes (W6 form: pre-run md5 recorded in the log, post-run file empty),
  `.codex/hooks.json` missing, rollback reports seven FAILED restores and
  `restored: [none]`.

### 2.3 Rollback as it is (`rollback_on_failure`, L3714–3998)

- Step 1 restores `.tad/` from the backup per manifest, verifying each
  entry — but **breaks on the first failed entry** (the loop sets
  `_rb_ok=0` and stops), leaving the remaining `.tad` entries unrestored
  even when they would have succeeded. The created-entry sweep (step 1b)
  and backup consumption are correctly gated on full step-1 success; the
  backup is preserved on any failure.
- Step 2 restores snapshot surfaces per entry and CONTINUES past failures,
  accumulating restored/kept lists. Step 1 is the inconsistent one.
- The closing coverage line (L3989) enumerates restored /
  removed-run-created / preserved-for-manual-recovery — kept verbatim by
  this design. What it lacks: a failed-restore list and a machine-greppable
  full/partial/none verdict.
- Trap discipline: `main` sets `NEED_ROLLBACK=1` (L6776) after the snapshot
  (L6780); the EXIT trap (L4075) fires rollback once; success clears the
  flag (L7086) after `discard_rollback_snap` (L7085). Unchanged.

### 2.4 Version stamp as it is

- `derive_framework_top_files` (L2044) emits 23 top files including
  `version.txt` (step1d probe, baseline file) — so W1 lands the NEW
  version at sync start. The three branch-end stamps
  (`echo "$TARGET_VERSION" > .tad/version.txt`, L6882 install / L6938
  upgrade / L7067 migrate) are therefore redundant in the success path and
  useless in the failure path.
- Ordering constraint already in the code: `call_migration_engine` runs
  BEFORE the branch-end stamp in upgrade/migrate (its comment: "before
  version.txt update"), and the engine reads the target's current version.
  `pre_sync_version` is captured at L2605 before any copy. Both are
  preserved by §4.4.
- `verify_install_complete` (L2928, called L2901 at the end of the copy
  phase) byte-compares every derived top file against source — including
  `version.txt`. §4.4 must move that one comparison, or the new ordering
  fails its own verify.

## 3. Requirements

### Functional (mapped to Epic §2, in order)

- FR1 (item 1): every W1–W11 write lands atomically — a failed or partial
  write never modifies the live file's bytes.
- FR2 (item 2): rollback restores per entry from the preserved backup /
  snapshot, verifies each restored entry byte-equal, continues past a
  failed entry in step 1 as step 2 already does, and closes with a
  truthful full/partial/none accounting naming failed entries.
- FR3 (item 3): `version.txt` is written exactly once, last — after the
  copy phase verifies and after the migration engine (upgrade/migrate);
  any framework write failure aborts the install at that write.
- FR4 (item 4): fixture cases inject the incident failure shape
  (write begins → bytes truncated → error) at the sync phase, at the
  stamp point, and inside rollback; assertions are byte-level; the cases
  join release step3f evidence (§4.7).

### Non-functional

- NFR1 (shell-portability pattern): bash + zsh clean (`bash -n`, `zsh -n`,
  fixture zsh smoke stays green); no grep-in-`$()` status reliance in new
  code; helpers must work when called from the existing call contexts —
  in particular `copy_pack_skill_smart` is never invoked from a subshell
  or command substitution (existing warning at L2587 is a hard constraint,
  because a subshell would also break fail-stop propagation).
- NFR2 (release-sync pattern): Gate 4 evidence uses a download-shaped
  source (git archive export), not a working tree (RP3).
- NFR3: no new runtime dependencies; the helpers use only `cp`, `cmp`,
  `mv`, `ln`, `mkdir`, `rm` — tools the installer already requires.
- NFR4: the existing coverage line's text is not changed (external log
  readers may match it); new accounting is additive (a second line).

## 4. Design

### 4.1 The atomic write helpers (D1)

Two helpers, placed beside `copy_framework_files`, generalizing the two
in-repo precedents (update-helper swap L2614–2625; restore helpers
L3649–3700):

- `atomic_install_file <src_file> <dst_file>`:
  1. Stage path = same directory as the destination, name
     `.<base>.tad-new.$$` (`$$` makes concurrent runs collision-free;
     same directory = same filesystem, which is what makes the final
     rename atomic).
  2. `cp -p -- "$src_file" "$stage"` — NOT suppressed. On failure: remove
     the stage, return 1. The destination has not been touched.
  3. Verify: `cmp -s -- "$src_file" "$stage"`; mismatch → remove stage,
     return 1. (Byte equality is the verification oracle — the same
     standard `_tad_tree_equal` applies on the restore side.)
  4. `mv -f -- "$stage" "$dst_file"`; failure → return 1 (stage left in
     place for forensics; the fixture asserts the success and
     rollback paths leave no `.tad-new.*` behind).
  Mode note (named behavior delta): `cp -p` makes the landed file carry
  the SOURCE's mode. Today's in-place `cp` preserves an existing target's
  mode. Framework files' modes are source-owned (the update-helper swap
  already replaces wholesale), so source-wins is the intended semantics;
  Gate 2 may contest.
- `atomic_install_tree <src_dir> <dst_dir>`: a `find` walk of the source —
  directories → `mkdir -p`; regular files → `atomic_install_file`;
  symlinks → stage the link itself (`ln -s` to the stage name, then
  `mv -f`), tested with `[ -L ]` BEFORE `[ -f ]` so dangling links are
  carried as links (the fleet has them; `_tad_tree_equal` L3617 documents
  why). Merge semantics preserved: target-only files are never deleted.
  First failure returns 1 immediately.
- Generated-content writes (W7, W8) use the same shape: produce the
  content into the stage path, then `mv -f` over the destination. For W7
  the block redirect targets the stage name; for W8 the heredoc does.

### 4.2 Write-site conversion (D2)

Every W-row in §2.1 converts to the helpers: W1/W2/W6 → `atomic_install_file`
per file; W3/W4 → `atomic_install_tree`; W5 → `atomic_install_file` per
file (including the three conflict-resolution copies); W7/W8 → stage +
rename per §4.1; W9 → `atomic_install_file` (their divergence pre-checks
stay — they refuse BEFORE writing, which is compatible); W10 →
`atomic_install_file` (L4950's hand-rolled tmp+cmp is retired into the
helper so there is exactly one idiom). W11 → `atomic_install_file` per
site; the install-branch site additionally gains the create-only
`[ ! -f … ]` guard its two sibling sites already carry (S0 ruling R1).

### 4.3 Error propagation — first failure stops (D3)

- No converted call site may carry `2>/dev/null || true`, `|| true`, or a
  `|| log_warn` continuation. The four suppressed copy sites (W1/W2/W3/W6)
  and the W7 call site (L2802) are the named set; step S0 sweeps for any
  other mutation-phase suppression and reports it rather than silently
  extending scope. S0's sweep found two further groups (S0 Ruling
  Record, hf-design-3): the W11 seed copies join the named set — their
  three suppressed forms are removed by the W11 conversion; the U2
  rescue copies are a named exclusion (see §2.1) and stay suppressed
  in this hotfix by ruling, listed in the COMPLETION per AC7.
- Clarification (hf-design-4, D6 ruling): suppression means masking the
  failure of an operation the installer performs. A precondition guard
  that skips an inapplicable operation because its input does not exist
  — the loop form already used beside the W7 call site
  (`[ -d … ] || continue`, `is_pack_skill … || continue`) — is not
  suppression, provided the guarded operation stays unsuppressed
  whenever it does run and the skip is logged. This clarification
  changes no converted site; it names the line the D6 guard stands on.
- Helpers return non-zero on the first failed file; callers return 1
  immediately; under `set -e` in `main` the EXIT trap performs rollback.
  This is what "首个失败点停步" means mechanically: after the first failed
  write, no later surface is written. (agent-workshop's 808 swallowed
  printf errors are the counter-example this rule exists to prevent.)

### 4.4 Version stamp last (D4)

- The top-files loop (W1) skips `version.txt` by name — a named special
  case beside the existing registry-only special case (L2626). The
  derivation itself is NOT changed (release-sync derivations mirror it;
  touching `TAD_TOP_DENY` would desync them).
- `verify_install_complete` excludes `version.txt` from its top-file
  byte-compare (it legitimately still holds the old value at that point);
  the stamp step below owns its verification.
- New `atomic_stamp_version`: `atomic_install_file "$src/.tad/version.txt"
  .tad/version.txt`, then `cmp -s` target vs source; any failure returns 1
  (→ rollback). It replaces the three `echo` stamps at their existing
  positions — install L6882, upgrade L6938, migrate L7067 — preserving
  today's ordering relative to `call_migration_engine` (engine first,
  stamp after, in upgrade/migrate).
- Invariants: any failure before the stamp leaves `.tad/version.txt`
  reading the pre-run version (fresh-install failure has no version file
  and rolls back its created entries as today); within the
  copy/migration sequence the stamp is the final write, and every
  post-stamp write (the genesis manifest at L6883, finalize bookkeeping)
  runs ONLY on the success path — no post-stamp write ever runs on a
  failure path. (Gate 2 code-lens narrowing, G2-C3: the unqualified
  claim "the stamp is the last framework mutation of a run" is NOT made
  — `write_genesis_manifest` follows the stamp on the success path.
  The load-bearing claim is the failure-path one above, and it is what
  AC1/AC4 test.) `config.yaml`'s `version:` field is content, not a
  stamp — it rides the atomic copy like any top file (named so Gate 2
  doesn't have to guess).

### 4.5 Rollback accounting (D5)

- Step 1 loop: remove the break. Per manifest entry — success appends to
  the restored list; failure appends `.tad/<rel>` to a NEW failed list,
  logs the error, and CONTINUES with the remaining entries. The step-1b
  created-entry sweep and backup consumption stay gated on zero step-1
  failures (that gating is the safety invariant; only the abandonment of
  the remaining restores changes). Risk-card assumption A3 covers this.
- Closing output: the existing coverage line stays byte-identical. A
  second line is added immediately after it, exactly:
  `ROLLBACK-RESULT: <full|partial|none> restored=<n> failed=<n> removed=<n> preserved=<n>`
  where full = failed and preserved both empty; none = restored and
  removed both empty; otherwise partial. Counts come from the same lists
  the coverage line prints, plus the new failed list.
- When the result is not full, a MANUAL-RECOVERY block prints before exit:
  the backup absolute path, the snapshot absolute path, the failed-entry
  list, and a per-copy statement of what each preserved copy covers
  (Gate 2 domain-lens C4 — the two copies are complementary, and neither
  alone is claimed to be the complete pre-run tree):
  the backup (`~/.tad-backups/<project>/<run>/`) holds the pre-run bytes
  of the surfaces this run backed up (the changed/deleted set taken by
  `backup_existing`) and is named **the durable recovery source**;
  the snapshot (`/tmp/tad-rollback.*`) holds the mutation-start state of
  the snapshot surfaces (root files and projection surfaces taken by
  `take_rollback_snapshot`) and lives in /tmp — it is NOT reboot-safe,
  so the block points recovery at the `~/.tad-backups` copy first.
  Neither copy is auto-deleted on failure paths (already true: snapshot
  discard happens only on success, L7085; the backup is consumed only
  on full step-1 success). This is the designed fallback for "rollback
  itself fails inside the write fault": truthful accounting + preserved
  copies + named paths — never silence, never a claim of recovery that
  did not happen.

### 4.6 Regression cases — injected write failure (D6)

Placement: extend `.tad/tests/installer-data-safety-fixture.sh` with
cases `aw.1`, `aw.2`, `aw.2b`, `aw.3`, `aw.4`, under its existing
contract (throwaway sandbox, pruned source made ONLY by deleting named
heavy paths, `--yes`, `--skip-claude-plugin`, snapshots/backups outside
the target, never a live repo).

Injection mechanism: an exported bash `cp` shim, following the fixture's
existing fail-closed `curl` shim precedent. The shim delegates to the
real `cp` except when armed by env `TAD_FIXTURE_FAIL_CP`, in which case
it writes 16 partial bytes to the destination and returns 1 — the exact
observable shape of both incidents. Matching rules (Gate 2 code-lens
G2-C2 — both rules are load-bearing):

- **Target-tree scoping.** An invocation can arm ONLY when its
  destination is inside the target tree (the fixture exports the target
  root; the match tests the destination path against it).
  `backup_existing` and `take_rollback_snapshot` also `cp` the armed
  basenames (`AGENTS.md`, `version.txt`) — to the backup and /tmp
  snapshot locations, BEFORE the mutation phase — and those destinations
  must NEVER match; otherwise the install aborts pre-mutation and the
  case passes vacuously without the sync/stamp path ever being
  exercised.
- **Phase discrimination** stays by destination form, inside the target
  tree: sync/stamp writes land as `.<base>.tad-new.$$` stage paths in
  the destination directory (basename matching strips the `.tad-new.*.`
  stage prefix); rollback restores write through `.rollback-staging`
  paths (basename matching strips that suffix).
- **Phase witness.** Every shim invocation appends one line
  `dest=<destination as passed> armed=<0|1>` to `$TAD_FIXTURE_SHIM_LOG`
  (a case-owned file outside the target). aw.1 and aw.4 assert against
  this log (below) — the case must prove the armed failure fired at the
  intended in-tree destination, in the intended phase, AFTER earlier
  sync writes had already landed.

**Manifest-order pinning (aw.2 / aw.2b; Gate 2 G2-C1 + domain C1).**
Rollback step 1 iterates the backup manifest; whether a case proves
continuation-past-failure depends entirely on where the armed entry
sits in that order, so the cases pin it instead of assuming it. The
fixture builds the target's `.tad/` with entries `a.md`, `b.md`, `c.md`
(plus the required version/config files). After the run, the case reads
the PRESERVED backup manifest (never consumed in these cases), records
the a/b/c iteration order from disk, and FAILS LOUDLY if the recorded
order is not a → b → c — the pin is verified, not assumed. aw.2 arms a
non-last entry (`b.md`); aw.2b arms the first entry (`a.md`), exactly
as risk-card A3 names it. Cases:

- **aw.1** (sync-phase single failure): arm basename `AGENTS.md`,
  non-staging destinations. Assert: installer exit ≠ 0; after rollback,
  the whole target tree is byte-identical to the pre-run snapshot the
  case took; `version.txt` = old version; coverage line occurs exactly
  once; zero `.tad-new.*` leftovers; no 0-byte framework file. Phase
  witness asserts: the shim log holds exactly one `armed=1` line and
  its destination is the AGENTS.md stage path inside the target tree;
  at least one earlier `armed=0` line names a destination inside the
  target tree (an earlier sync write — e.g. a `.tad` top-file stage
  write — landed before the failure, so the sync path was genuinely
  exercised); no `armed=1` line names a destination outside the target
  tree (the backup/snapshot copies never matched). (On the old code
  this case fails the run differently: W6's `|| true` lets the install
  "succeed" with a truncated AGENTS.md and an advanced stamp.)
  Pass line: `pass "aw.1: injected sync write failure left target tree byte-identical"`.
- **aw.2** (rollback itself partially fails; continuation proof): arm
  `AGENTS.md` non-staging (forces rollback) AND arm basename `b.md` on
  `.rollback-staging` destinations, with the manifest order pinned as
  above (a → b → c, verified from the preserved manifest; `b.md` is
  therefore a NON-LAST entry). Assert: `ROLLBACK-RESULT: partial` line
  present; failed list names `.tad/b.md`; `a.md` restored; **`c.md` —
  the entry ordered AFTER the failed `b.md` in the pinned order —
  restored** (this is the assertion that proves step 1 continued past
  the failure; under today's break-on-first-failure code `c.md` stays
  unrestored); the created-entry sweep did NOT run — one named
  run-created entry (a file the sync phase created before the failure;
  the case names it) is still present after rollback; backup NOT
  consumed (path exists); MANUAL-RECOVERY block present and both paths
  it names exist; `version.txt` = old version.
  Pass line: `pass "aw.2: rollback partial failure accounted, recovery copies preserved"`.
- **aw.2b** (first manifest entry fails; risk-card A3's named check):
  arm `AGENTS.md` non-staging (forces rollback) AND arm basename
  `a.md` — the FIRST entry in the pinned manifest order — on
  `.rollback-staging` destinations. Assert: failed list names
  `.tad/a.md`; `b.md` and `c.md` (both ordered after the failed entry)
  restored; the created-entry sweep did NOT run — the named
  run-created entry is still present; backup NOT consumed;
  `ROLLBACK-RESULT: partial` present and its failed count agrees with
  the failed list; MANUAL-RECOVERY block present, named paths exist;
  `version.txt` = old version.
  Pass line: `pass "aw.2b: first-entry rollback failure accounted, later entries restored, sweep held"`.
- **aw.3** (clean control): no shim. A 4.0.8-shaped target upgrades to
  the fixture source version: exit 0, `version.txt` advanced, framework
  surfaces byte-match source (reuse the fixture's existing positive-proof
  helpers), zero `.tad-new.*` leftovers. Mode spot-check (Gate 2
  code-lens G2-C4 — the operational half of the Q1 source-wins ruling):
  the landed mode equals the source mode for two executable files that
  land through `atomic_install_tree` — one `.tad/scripts/*` script and
  one `.tad/hooks/*` script (the case compares source vs target modes
  via `stat` for both and prints both pairs it compared). Pair form
  corrected by ruling hf-design-4 (AC3): the pair as first written
  named `tad.sh`, but the installer never copies `tad.sh` itself into
  a target tree (it is the executing program, not payload — no copy
  set contains it), so the checked property — landed mode == source
  mode through the atomic idiom — is carried by the two executables
  above. Migration-engine coverage
  attribution (Gate 2 domain-lens C2), named so nobody has to guess:
  the fixture's pruned source carries no migration hop for the fixture
  version pair, so `call_migration_engine` is NOT exercised by aw.3;
  the engine-before-stamp relative order at the three branch ends is
  carried by Gate 3 code read (Blake's COMPLETION quotes the branch-end
  call order). What aw.3 itself asserts on this surface is the
  fixture-observable half: `pre_sync_version` capture is unchanged
  (§2.4) and the version advances only in this clean run — aw.1/aw.4
  witness it unadvanced under failure.
  Pass line: `pass "aw.3: clean upgrade lands atomically, stamp last"`.
- **aw.4** (stamp-point failure): arm basename `version.txt`, non-staging
  destinations (with §4.4 in place, the only such write is the stamp
  itself). Assert: exit ≠ 0; `version.txt` still old; tree restored
  after rollback (identity in the named-set form below);
  `ROLLBACK-RESULT:` line present. Tree identity for this case —
  re-scoped by ruling hf-design-4 (D4), aligning this clause with the
  §1 Success Definition, which always read "byte-identical to pre-run
  (OR the shortfall is enumerated by name with preserved recovery
  copies)": identity holds modulo the preserved-recovery-copy
  convention (the `.tad-backup` filter the fixture already applies)
  AND the set of differing surfaces is a subset of exactly two named
  surfaces — `.tad/brain-index.md` (generated content embedding a
  minute-resolution timestamp, outside both rollback domains;
  excluded from coverage by the Gate 2 Q2 ruling, see the ruling
  record) and `.codex/hooks.json` (pre-existing deprecation-delete →
  regenerate-as-run-created → rollback-removal gap; defect named,
  ticket obligation at Epic closeout, risk-card A7). Any THIRD
  differing surface fails the case. Implementation form for Blake:
  from the same pre-filtered signature diff the case already computes,
  extract the differing path set; PASS requires the filtered identity
  to hold apart from that set and the set ⊆ the two named paths; the
  case prints the differing set either way (it is the evidence). The
  pinned pass line below is unchanged. (aw.1's identity clause is NOT
  re-scoped: its armed point fires inside the copy phase, before the
  deprecation/regeneration and brain-index phases run — disk-verified
  by its green run — so the two surfaces cannot arise there.)
  Phase witness asserts:
  the shim log's `armed=1` line names the `.tad/version.txt` stage path
  inside the target tree (the stamp write — not the backup copy of
  version.txt, which target-tree scoping excludes); at least one
  earlier `armed=0` line names a destination inside the target tree
  (the copy phase genuinely ran before the stamp was attempted); no
  `armed=1` line names a destination outside the target tree.
  Pass line: `pass "aw.4: stamp failure leaves version unadvanced, tree restored"`.

The aw cases are bash-only (zsh cannot import the exported function —
named limitation, consistent with the fixture's existing shim).

### 4.7 Release wiring (D7)

`.agents/skills/alex/references/publish-protocol.md`, step3f, gains one
required row: run the aw cases against the candidate tree
(`bash .tad/tests/installer-data-safety-fixture.sh --case aw.1`,
`aw.2`, `aw.2b`, `aw.3`, `aw.4`, or a case-set selector if Blake adds
one) and file the transcript at
`.tad/evidence/live-regression/installer-atomic-<YYYYMMDD>.md` in the
standard six-field live-regression form. This joins the existing step3f
surface list; it does not replace any surface. (The Epic's publish step
executes this; this Phase only lands the wiring and the cases.)
Transcript field values for this non-runtime surface (Gate 2
domain-lens C3 — named here so the release executor never improvises):
field 1 (runtime) = `none — installer fixture (no harness runtime)`;
field 2 (harness name and version) = `tad.sh installer +
installer-data-safety-fixture.sh @ candidate tree version`. The
remaining four fields take their standard meanings (execution date;
chain type = installer-atomic; PASS/FAIL + one line; raw-output
pointer).

## 5. Implementation Steps (Blake)

- [x] S0 — Write-point sweep: grep `tad.sh` for every copy/redirect/heredoc
      write and reconcile against §2.1 + the named exclusions. Any
      unlisted mutation-phase write → STOP and report to the conductor
      (do not silently extend scope). DONE 2026-11-01 (hf-impl-1):
      sweep filed at `.tad/evidence/yolo/v4010-hotfix/p1-s0-sweep-report.md`,
      found U1/U2 and stopped as designed; rulings in the S0 Ruling
      Record (hf-design-3) — U1 = W11 in scope (R1), U2 = named
      exclusion (R2). Blake resumes at S1.
- [ ] S1 — Implement `atomic_install_file` / `atomic_install_tree` (§4.1).
- [ ] S2 — Convert W1–W11 (§4.2) and strip the named error suppressions (§4.3).
- [ ] S3 — Version stamp: loop skip + verify exclusion + `atomic_stamp_version`
      at the three branch positions (§4.4).
- [ ] S4 — Rollback step-1 continuation + failed list + `ROLLBACK-RESULT:`
      line + MANUAL-RECOVERY block (§4.5). Coverage line text untouched.
- [ ] S5 — Fixture: `cp` shim (target-tree-scoped matching + shim-log
      witness per §4.6) + cases aw.1, aw.2, aw.2b, aw.3, aw.4 with the
      §4.6 assertions and pinned pass lines.
- [ ] S6 — Publish-protocol step3f row (§4.7); then the full local proof:
      `bash -n tad.sh`, `zsh -n tad.sh`,
      `bash .tad/tests/installer-data-safety-fixture.sh` (all cases,
      existing + aw), `bash .tad/tests/run-all.sh`. NEVER run the
      installer against any real project, including this repo.

## 6. File Structure

Write set (exhaustive):
- `tad.sh` — helpers, W1–W11 conversion, stamp, rollback accounting.
- `.tad/tests/installer-data-safety-fixture.sh` — shim + aw.1, aw.2, aw.2b, aw.3, aw.4.
- `.agents/skills/alex/references/publish-protocol.md` — one step3f row.

Plus Blake's COMPLETION at `.tad/active/handoffs/` per house form and run
evidence under `.tad/evidence/yolo/v4010-hotfix/`. Nothing else. In
particular: no changes to `backup_existing`, `take_rollback_snapshot`,
the restore helpers' internals, `apply_deprecations`, or the coverage
line's text.

## 7. Testing Strategy

- Unit-ish: the fixture IS the test harness (sandboxed, deterministic,
  offline). Existing `fx.*` cases must stay green — they pin the
  no-mutation-on-failure and positive-install contracts this change must
  not regress.
- New behavior: aw.1, aw.2, aw.2b, aw.3, aw.4 (§4.6), byte-level assertions via sha256 /
  full-tree comparison against the case's own pre-run snapshot.
- Static: `bash -n` + `zsh -n`; the §9.1 greps.
- Real paths: RP1–RP3 at Gate 4 (independent Alex), download-shaped
  source for RP3 per the release-sync pattern.

## 8. Acceptance Criteria (summary)

Full checkable table in §9.1. Headline: aw.1, aw.2, aw.2b, aw.3, aw.4 pass; existing fixture
+ run-all green; no suppressed framework write remains in the copy phase;
stamp greps show the old `echo` stamps gone and `atomic_stamp_version`
defined once + called at the three branch positions; coverage line
unchanged with `ROLLBACK-RESULT:` emitted from exactly one site.

## 9. Explicitly NOT doing (Epic §2 out-list, restated for the executor)

- EPERM / write-fault root cause — infra's investigation, not this chain.
  The design holds GIVEN arbitrary write failures.
- Content-layer interception: if infra confirms content-triggered
  blocking, whether framework content must change is a separate matter
  for GM routing — not decided or implemented here.
- Downstream repo recovery / re-upgrade ordering — GM-orchestrated after
  the hotfix publishes; the fleet install pause stays in force meanwhile.
- Backup/snapshot subsystem redesign; migration-engine internals;
  deprecation behavior; the sync tree's half-arrived ticket file.
- Migrate user-data rescue conversion (S0 finding U2): excluded by
  ruling (hf-design-3, R2) — follow-up ticket obligation at Epic
  closeout (ruling R3), residual carried as risk-card A6.
- `.codex/hooks.json` rollback-fidelity gap (hf-impl-2 finding D4):
  when a run both deprecates-deletes the file and regenerates it in
  the same run, rollback step 2 restores the snapshot bytes and step 4
  then removes the file as run-created — a failed run can leave the
  target without its live hooks.json (bytes preserved in the
  deprecation backup). The fix sits in deprecation behavior /
  created-entry tracking, both already out-listed above; excluded
  from this hotfix by ruling (hf-design-4, D4) — follow-up ticket
  obligation at Epic closeout (ruling record D4-R), residual carried
  as risk-card A7. aw.4's identity clause names the surface so the
  gap stays visible at every release run (§4.6 / AC4).

## 9.1 Acceptance Criteria — §9.1 Form A (Phase 4 定版表头)

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---|---|---|---|---|
| AC1 | aw.1: injected sync-phase write failure leaves the target tree byte-identical, version unadvanced, exit ≠ 0; shim log witnesses the armed failure at the in-tree AGENTS.md stage path after an earlier in-tree sync write, and no armed hit outside the target tree | fixture | `bash .tad/tests/installer-data-safety-fixture.sh --case aw.1` | exit 0; output contains the pinned pass line `pass "aw.1: injected sync write failure left target tree byte-identical"` | baseline: `--case aw.1` → exit 2 `unknown case 'aw.1'` (design-baseline.txt) |
| AC2 | aw.2: rollback continues past a failed entry — manifest order pinned a → b → c and verified from the preserved backup manifest; non-last entry `b.md` fails restore; `c.md` (ordered after `b.md`) and `a.md` restored; sweep does not run (named run-created entry still present); `ROLLBACK-RESULT: partial` names `.tad/b.md`; backup preserved; MANUAL-RECOVERY block names existing paths | fixture | `bash .tad/tests/installer-data-safety-fixture.sh --case aw.2` | exit 0; pinned pass line `pass "aw.2: rollback partial failure accounted, recovery copies preserved"` | baseline: case does not exist (same probe as AC1) |
| AC2b | aw.2b: first manifest entry `a.md` fails restore — `b.md` and `c.md` restored; sweep does not run (named run-created entry still present); backup not consumed; `ROLLBACK-RESULT: partial` failed count agrees with the failed list naming `.tad/a.md` | fixture | `bash .tad/tests/installer-data-safety-fixture.sh --case aw.2b` | exit 0; pinned pass line `pass "aw.2b: first-entry rollback failure accounted, later entries restored, sweep held"` | baseline: case does not exist (same probe as AC1) |
| AC3 | aw.3: clean upgrade control — exit 0, version advanced, surfaces byte-match source, no stage leftovers; landed modes equal source modes for two executables landing through the atomic tree copy (one `.tad/scripts/*` + one `.tad/hooks/*` script; pair form per ruling hf-design-4 — `tad.sh` itself never lands in a target tree); migration-engine order carried by Gate 3 code read per §4.6 attribution (engine not exercised by the fixture) | fixture | `bash .tad/tests/installer-data-safety-fixture.sh --case aw.3` | exit 0; pinned pass line `pass "aw.3: clean upgrade lands atomically, stamp last"`; output prints the source/target mode pairs compared for both executables | baseline: case does not exist (same probe as AC1) |
| AC4 | aw.4: stamp-point failure leaves version unadvanced and tree restored — identity in the §4.6 named-set form (ruling hf-design-4 D4): modulo preserved recovery copies, the differing-surface set ⊆ {`.tad/brain-index.md`, `.codex/hooks.json`} and is printed by the case; any third differing surface fails; shim log witnesses the armed failure at the in-tree `.tad/version.txt` stamp stage path after earlier in-tree sync writes, and no armed hit outside the target tree | fixture | `bash .tad/tests/installer-data-safety-fixture.sh --case aw.4` | exit 0; pinned pass line `pass "aw.4: stamp failure leaves version unadvanced, tree restored"`; output prints the differing-surface set | baseline: case does not exist (same probe as AC1) |
| AC5 | No regression: full fixture (existing fx.* + aw.*) and run-all green | command | `bash .tad/tests/installer-data-safety-fixture.sh` then `bash .tad/tests/run-all.sh` | both exit 0 | baseline: fixture + run-all green at v4.0.9 (release record); aw.* absent |
| AC6 | Stamp mechanics: old echo stamps gone; `atomic_stamp_version` defined once, called at the three branch positions | command | `grep -c 'echo "$TARGET_VERSION" > .tad/version.txt' tad.sh` and `grep -cn 'atomic_stamp_version' tad.sh` | first = 0; second ≥ 4 (1 definition + 3 calls) | baseline: echo stamps = 3; `atomic_stamp_version` = 0 (design-baseline.txt) |
| AC7 | Error suppression removed at the named sites: pack-meta call no longer swallows; no suppressed `cp` remains in the copy phase | command | `grep -cF '\|\| log_warn "Meta generation failed' tad.sh`; reviewer greps `2>/dev/null \|\| true` across tad.sh and confirms every remaining hit is outside the §2.1 write set or a §2.1 named exclusion — the four U2 rescue sites (L6982/6985/6988/6991) must appear in the list, named as excluded-by-ruling (hf-design-3 R2); any other unlisted hit fails this row (list in COMPLETION) | first = 0; reviewer list shows zero copy-phase hits | baseline: genpack log-warn sites = 1; suppressed-cp count in copy region (L2583–2927) = 4 (design-baseline.txt) |
| AC8 | Dual-shell syntax clean | command | `bash -n tad.sh && zsh -n tad.sh` | exit 0 | baseline: `bash -n tad.sh` exit 0 (design-baseline.txt) |
| AC9 | Accounting output shape: coverage line text unchanged (one emission site); `ROLLBACK-RESULT:` emitted from exactly one site | command | `grep -cF 'Rollback coverage — restored:' tad.sh` and `grep -cF 'ROLLBACK-RESULT:' tad.sh` | both = 1 | baseline: coverage = 1; ROLLBACK-RESULT = 0 (design-baseline.txt) |
| AC10 | Helpers exist with the §4.1 contract (stage in destination dir, cmp verify, rename) | command + code read | `grep -cn 'atomic_install_file\|atomic_install_tree' tad.sh` + code read of the two bodies against §4.1 steps 1–4 | count ≥ 3; bodies match the contract (reviewer-confirmed) | baseline: helper names = 0 (design-baseline.txt) |
| AC11 | Release wiring present: publish-protocol step3f names the aw cases and the transcript path | command | `grep -n 'installer-atomic-' .agents/skills/alex/references/publish-protocol.md` | ≥ 1 hit, naming `.tad/evidence/live-regression/installer-atomic-<YYYYMMDD>.md` | baseline: no such row (step3f predates the cases) |
| AC12 | Gate 4 real paths RP1–RP3 hold on a genuine 4.0.8 project copy | real-path | independent Alex executes RP1/RP2/RP3 from the front matter | per-RP assertions in the front matter all true; transcripts filed under `.tad/evidence/yolo/v4010-hotfix/` | n/a at design time (Gate 4 executes) |
| AC13 | W11 seed copies (S0 ruling R1): no suppressed seed-copy form remains; all three sites call `atomic_install_file`; the install-branch site carries the create-only guard (three guarded seed sites in total) | command + code read | `grep -cF 'project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null \|\| true' tad.sh` and `grep -c 'if \[ ! -f .tad/project-knowledge/README.md \]' tad.sh` + code read of the three seed sites | first = 0; second = 3; code read confirms each site calls the helper, the two pre-guarded sites keep their guards, and the install site gained the guard | baseline: suppressed seed form = 3; guard count = 2 (Alex hf-design-3 probes, 2026-11-01) |
| AC14 | D6 fix (ruling hf-design-4): a target skill dir with no source counterpart no longer aborts the install — the pack-meta loop skips it by a logged precondition guard on the SOURCE dir's existence, and `generate_pack_meta` stays unsuppressed whenever it runs; fx.b3 passes unmodified | fixture + code read | `bash .tad/tests/installer-data-safety-fixture.sh --case fx.b3` + code read of the pack-meta loop and the `generate_pack_meta` call site | exit 0; fx.b3's pinned pass lines print (incl. "changes.tsv has the header…" and "a path holding a newline is excluded"); code read confirms: guard form is `[ -d "$src/.agents/skills/$sn" ] || continue` with a log line naming the skipped dir; no `2>/dev/null`, `|| true`, or `|| log_warn` on or around the call; failures inside `generate_pack_meta` (find on an existing dir, stage write, rename) still propagate | baseline (pre-fix, hf-impl-2): fx.b3 FAILS — upgrade aborts into rollback at the newline-named target skill dir (COMPLETION D6; s6-fixture-named-rest.log) |

## 10. Gate 2 rulings on the author's open questions (both lenses — final)

- Q1 (`cp -p` mode semantics): **RULED — accept source-wins** (code
  lens §10/Q1; domain lens §5/Q1). Framework files are source-owned and
  replaced wholesale every update; preserving a destination's mode
  would mask source-side mode fixes (e.g. hook exec bits). The
  operational half of the ruling is the aw.3 mode spot-check (§4.6).
  §4.1's mode note stands as the intended semantics.
- Q2 (brain-index exclusion): **RULED — accept the exclusion** (code
  lens §10/Q2; domain lens §5/Q2), with the residual and the
  scope-narrowing riders now written into the §2.1 exclusion note.
- Q3 (aw.2 assertion sufficiency): **RULED — the order-free form is NOT
  sufficient; closed in this round's strict form** (code lens G2-C1;
  domain lens C1). §4.6 now pins the manifest order (verified from the
  preserved manifest), arms a non-last entry in aw.2 with an
  after-entry-restored assertion, and adds aw.2b (first entry fails)
  exactly as risk-card A3 names it; §9.1 gains AC2b; A3's check line
  names both cases.

## Gate 2 Revision Record (hf-design-2, 2026-11-01)

### 激活自报 (Activation Self-Report — Alex, hf-design-2)

- Role: Alex (Solution Lead), design-revision round, activated via
  `~/workspace/skills/tad-alex/SKILL.md` (thin shell) → this repo's
  originals, read this session before revising: `AGENTS.md`,
  `.tad/project-knowledge/principles.md`,
  `.tad/project-knowledge/patterns/_index.md` (matched: shell-portability,
  ac-verification, gate-design, release-sync — index level; this round
  revises text against the two review reports, not new design).
- Revision inputs read in full this session: both Gate 2 reports
  (`.tad/evidence/yolo/v4010-hotfix/p1-gate2-code.md`,
  `p1-gate2-domain.md`), the HANDOFF as reviewed, risk card
  `risk-TASK-20261101-HF1.md` (A3/A4 check lines synced this round).
- Discipline: HANDOFF + risk-card text only — no implementation code
  touched; no git commands run in this repo; this round does not judge
  its own amendments (narrow re-review is a separate reviewer's).

### Condition reconciliation (every Gate 2 condition → where it landed)

| Condition | Source | Landed at |
|---|---|---|
| aw.2 continuation proof: pin/document manifest order, arm a non-last entry, assert an after-entry restored; one case name across A3 / §4.6 / §9.1 | code G2-C1 + domain C1 (same root) | §4.6 manifest-order pinning paragraph + aw.2 rewritten (c.md-after-b.md assertion, sweep-not-run assertion); §9.1 AC2 rewritten |
| aw.2b: first manifest entry fails — later entries restore, sweep does not run (run-created entry present), backup not consumed, ROLLBACK-RESULT agrees with failed list; §9.1 AC row | domain C1 (risk card A3's named check) | §4.6 new case aw.2b; §9.1 new row AC2b; risk card A3 check now names aw.2 + aw.2b |
| Shim matching scoped to destinations inside the target tree (backup/snapshot copies never match) + phase-witness assertion in aw.1 and aw.4 | code G2-C2 | §4.6 injection-mechanism rules (target-tree scoping; `$TAD_FIXTURE_SHIM_LOG` witness) + witness asserts in aw.1 / aw.4; §9.1 AC1 / AC4 criterion text |
| aw.3 migration-engine coverage attribution named (fixture assertion or Gate 3 code read) | domain C2 | §4.6 aw.3 attribution paragraph (engine NOT exercised by the fixture; branch-end order carried by Gate 3 code read, COMPLETION quotes it); §9.1 AC3; risk card A4 check synced |
| §4.7 installer-atomic transcript: runtime / harness field values named | domain C3 | §4.7 closing paragraph (field 1 = `none — installer fixture (no harness runtime)`; field 2 = `tad.sh installer + installer-data-safety-fixture.sh @ candidate tree version`); case list now includes aw.2b |
| MANUAL-RECOVERY text: per-copy coverage, `~/.tad-backups` named as the durable source | domain C4 | §4.5 MANUAL-RECOVERY paragraph rewritten per-copy (backup = durable source; snapshot = /tmp, not reboot-safe; neither alone claimed complete) |
| §4.4 "last framework mutation" sentence narrowed to the failure-path claim | code G2-C3 (P2) | §4.4 invariants rewritten (genesis-manifest counterexample named; post-stamp writes success-path only) |
| aw.3 mode spot-check (source vs target mode, `tad.sh` + one hook) | code G2-C4 (P2; operational half of Q1) | §4.6 aw.3; §9.1 AC3 evidence column |
| brain-index residual stated explicitly + Epic item-1 narrowing named for conductor closeout | code G2-C5 (P2) + domain Q2 rider (merged into one item) | §2.1 exclusion note, riders (i) and (ii) |
| Gate 2 section: `Pilot: n/a` with reason; AC10 type labeled command + code read | code G2-C6 (P2) | Gate 2 section (Pilot line); §9.1 AC10 Verification Type |
| §10 Q1 / Q2 / Q3 dispositions | both lenses §10/§5 | §10 rewritten as final rulings (Q1 accept source-wins; Q2 accept + riders; Q3 closed in this round's strict form) |

**Post-revision state:** Gate 2 remains CONDITIONAL PASS (dual lens)
until a Gate 2 reviewer's narrow re-read of these amendments lands;
Blake starts S0 only after that re-read (per both reports' conditions).

## S0 Ruling Record (hf-design-3, 2026-11-01)

### 激活自报 (Activation Self-Report — Alex, hf-design-3)

- Role: Alex (Solution Lead), design-ruling round, activated via
  `~/workspace/skills/tad-alex/SKILL.md` (thin shell) → this repo's
  originals, read this session before ruling: `AGENTS.md`,
  `.tad/project-knowledge/principles.md`,
  `.tad/project-knowledge/patterns/_index.md` + full text of the three
  matching patterns (`shell-portability.md`, `ac-verification.md`,
  `handoff-design.md`), `.tad/brain-index.md` (route check),
  `.tad/tasks/handoff-creation.md`, `.tad/tasks/gate-execution.md`,
  `.tad/gates/gate-canonical-checklist.md`, the Epic, this HANDOFF as
  Gate-2-passed, the risk card, and the restored ticket full text.
- Ruling inputs, first-hand: the S0 sweep report
  (`.tad/evidence/yolo/v4010-hotfix/p1-s0-sweep-report.md`) in full;
  `tad.sh` branch contexts L6760–7075 (backup_existing +
  NEED_ROLLBACK arming before the action branches; the three seed
  sites; migrate backup creation, rescue copies, and the final
  backup-report line); baseline probes run this session (suppressed
  seed-copy form = 3; seed guard count = 2; no `rm` of
  MIGRATE_BACKUP_DIR anywhere in `tad.sh`; `set -euo pipefail` at L7).
- Discipline: rulings + HANDOFF / risk-card text only — no
  implementation code touched; no git commands run in this repo;
  this round does not judge its own amendments (see "Effect on the
  chain" below).

### R1 — U1 (project-knowledge README seed copies ×3): (a) ADD to the write set as W11

- Sites: L6820 (install, unconditional), L6927 (upgrade, create-only
  guard), L7010 (migrate, create-only guard) — all
  `cp … 2>/dev/null || true`.
- Conversion: every site → `atomic_install_file`, suppression
  removed (fail-stop per §4.3); the two guarded sites keep their
  guards unchanged.
- The install site additionally gains the create-only guard
  `[ ! -f .tad/project-knowledge/README.md ]`. Grounds: the
  destination is project-owned — AGENTS.md (File Ownership) states
  project-owned files, `.tad/project-knowledge/` among them, are
  created by the installer only when missing; both sibling branches
  already implement exactly that rule, under the comment "preserve a
  downstream-customized README (knowledge-seam isolation)"; the
  install branch is the only site missing it. An unconditional
  in-place overwrite of a pre-existing project-owned file is the W6
  failure class, and no restore coverage for this path is named in
  §2.1/§2.3 (the path sits outside copy_framework_files and outside
  the snapshot surface set), so the guard — not rollback — is the
  protection. This is conformance to the repo's existing contract at
  the same site, not a new feature.
- **Scope relation: INSIDE Epic item 1's本义.** The seed copy is an
  installer mutation-phase write of a framework-supplied file in all
  three action branches — the same fix class as W1–W10. No new Epic
  item; no conductor/GM scope decision needed.
- Verification: new §9.1 row AC13 (baselines probed this session:
  suppressed form 3 → 0; guard count 2 → 3; plus code read of the
  three sites). Risk card A2 is amended — its sweep check is what
  surfaced U1/U2.

### R2 — U2 (migrate user-data rescue copies ×4): (b) NAMED EXCLUSION from this hotfix's write set

- Sites: L6982/6985/6988/6991 — byte-unchanged in this hotfix; MUST
  be listed by name in the COMPLETION's AC7 remaining-hits list as
  excluded-by-ruling (AC7's criterion text is amended to require
  exactly that; if they do not appear there, AC7 is not met).
- Reasons (each load-bearing):
  1. **Boundary.** The destinations are project-owned user data
     (`.tad/active/…`); the sources are a preservation backup. Epic
     item 1 bounds this hotfix to framework-surface writes
     (「框架面全部写入」), and §9 already places the migration /
     backup neighborhood out of scope. **Scope relation: converting
     U2 here WOULD be扩围** — if the conductor/GM want it in this
     chain, that is their decision to record; this ruling does not
     take it.
  2. **Different failure shape.** Every byte a rescue copy can
     overwrite or truncate also exists in its source,
     `$MIGRATE_BACKUP_DIR` — a uniquely-named (collision-incremented,
     L6950–6954) full `cp -R` of the pre-migration `.tad/` taken
     before the rescue copies run (L6956), never deleted or
     overwritten anywhere in the run (verified this session: no `rm`
     reference), and its path is printed in the run's final report
     (L7070, "Backup saved to …"). A failed rescue therefore cannot
     destroy the only copy; the residual defect is a silently
     incomplete rescued `.tad/active/` tree — serious, but a
     different defect from FR1's destroyed-only-copy, and recoverable
     by hand from a named location.
  3. **Conversion is not mechanical.** The sites' semantics differ
     from the §4.1 helper contract: glob expansion over mixed
     entries including dangling symlinks (the L6978 comment records
     `cp -R` was chosen for exactly that), two source layouts merging
     sequentially into one destination with load-bearing order, and
     glob skipping dotfiles where the tree helper's `find` walk
     includes them. Each delta needs fixture coverage, and this
     chain's fixture cannot exercise the migrate path (§4.6 already
     records the migration engine is not exercised by it). Shipping
     an unverifiable conversion inside a data-safety hotfix would
     trade a known, bounded residual for an unmeasured one.
  4. **Exposure bound.** U2 fires only on ACTION=migrate (legacy
     layout migration). The fleet wave this hotfix unblocks is
     4.0.8→4.0.10 `upgrade` actions, which never reach these lines;
     the exclusion does not gate the unblock.

### R3 — Residual obligations bound to R2

- The risk card gains assumption A6 (the falsifiable form of R2
  reason 2); Gate 3 reviewers re-check it by code read.
- Before this Epic closes, the conductor files a follow-up ticket —
  "migrate user-data rescue copies: fail-stop or verified rescue" —
  whose Gate 2 precondition is a migrate-path fixture able to
  exercise the rescue copies (the coverage this chain lacks). The
  ticket reference belongs in the Epic closeout record.
- AC7's remaining-hits list is the in-chain witness for the
  exclusion (see R2, first bullet).

### Effect on the chain

- Amended in this round: §2.1 (W11 row + U2 named exclusion), §4.2,
  §4.3, §5 (S0 done; S2 covers W1–W11), §9 (U2 out-list line), §9.1
  (AC7 criterion + new AC13); risk card A2 amended, A6 added.
- Gate 2 status: the W11/AC13 delta is a design amendment after
  Gate 2 PASS → a narrow Gate 2 re-review of this delta (one
  reviewer, code lens) must land before Blake resumes; the rest of
  the Gate 2 verdict stands untouched.
- Blake resume point: S1, with S0 marked done (sweep + this ruling).

## Project Knowledge Used (step1d excerpts)

- principles.md: file-as-memory (design + baselines on disk, not in chat);
  verify-don't-assume (every §2 anchor read first-hand; baselines probed,
  not recalled); disk-state-over-model (the 0-byte ticket is reported as
  found, not papered over).
- patterns/shell-portability.md (matched: shell installer change): the
  islands are the test scope — fixture green + `zsh -n` + no
  grep-in-`$()` status reliance in new code (NFR1).
- patterns/release-sync.md (matched: release-wiring change): Gate 4 uses a
  download-shaped source (RP3); yunpush, not git, moves this repo.

## Post-Implementation Ruling Record (hf-design-4, 2026-11-01)

### 激活自报 (Activation Self-Report — Alex, hf-design-4)

- Role: Alex (Solution Lead), post-implementation design-ruling round,
  activated via `~/workspace/skills/tad-alex/SKILL.md` (thin shell) →
  this repo's originals, read this session before ruling: `AGENTS.md`,
  `.tad/project-knowledge/principles.md`,
  `.tad/project-knowledge/patterns/_index.md` (index level; matched
  entries for this step: gate-design, ac-verification, handoff-design —
  the round rules on named findings against already-landed text, it
  does not introduce new design), `.tad/gates/gate-canonical-checklist.md`
  (Gate 2 / Gate 3 sections), this HANDOFF in full (Gate-2-passed +
  hf-design-2 revision record + hf-design-3 S0 ruling record), and the
  COMPLETION in full (D1–D6, Friction table, §9.1 measured values).
- Ruling inputs, first-hand this session (disk, not the COMPLETION's
  word): `generate_pack_meta` body (tad.sh L2146–2196 — the `find` over
  `hash_dir` sits inside the stage block whose status `pipefail`
  carries to the function's return) and its only call site (L2894,
  inside the loop over the TARGET's skill dirs, guarded by
  `[ -d … ] || continue` and `is_pack_skill … || continue`);
  `is_pack_skill` (L2131 — a fixed-string grep over the source
  registry text: a membership heuristic, not proof a source directory
  exists; a newline-bearing name splits the grep pattern, which is
  exactly the fx.b3 shape); fixture `case_fxb3` (target skill dir
  literally named `fx-x\ny`; the case's premise is that the upgrade
  SUCCEEDS); `.tad/hooks/lib/brain-index-gen.sh` (the `Generated:`
  line embeds `date '+%Y-%m-%d %H:%M'` — minute resolution);
  `.tad/deprecation.yaml` (`.codex/hooks.json` is a listed
  deprecation file); the three W11 seed sites as landed (guard line
  verbatim at all three, source-existence check nested inside);
  `aw_assert_tree_restored` in the fixture (signature streams filtered
  BEFORE diffing); the aw.4 run log
  (`.tad/evidence/yolo/v4010-hotfix/s6-aw4-run2.log`) — the differing
  set is exactly {`./.codex/hooks.json`, `./.tad/brain-index.md`},
  the other four aw.4 assertions pass; the root-file derivation
  (`platform_root_files_all` over platform-codes.yaml) — no copy set
  (top files, framework dirs, skill trees, platform root files)
  contains `tad.sh`.
- Discipline: rulings + HANDOFF / risk-card text only — no
  implementation code touched; no git commands run in this repo;
  this round does not judge its own amendments (Gate 3 dual review
  of the final state is the verification point, per the dispatch).

### D6 — W7 propagation × target-side skill dirs: RULED (b), caller precondition guard

- The defect, restated from disk: §4.3 removed the `|| log_warn`
  swallow at the `generate_pack_meta` call site (correct — that
  swallow is what hid the agent-workshop printf storm). But the
  caller iterates the TARGET's skill dirs and passes
  `$src/.agents/skills/<name>` as the hash source; when that source
  dir does not exist, the hash walk's `find` fails, `pipefail`
  carries it out of the stage block, the function returns 1, and the
  install aborts into rollback. Pre-hotfix the same failure died
  inside the suppressed block — which ALSO wrote a header-only meta
  for such a dir, a silently-wrong artifact in its own right.
- **Ruling: (b) — the caller skips a skill dir that has no source
  counterpart**, in this exact form (Blake fix-round口径):
  in the pack-meta loop, after the `is_pack_skill` guard and before
  the `generate_pack_meta` call, add a precondition guard on the
  SOURCE dir — `[ -d "$src/.agents/skills/$sn" ] || { log_info
  "  → Pack meta skipped for $sn: no upstream skill dir"; continue; }`
  (log wording may vary; the line must name the skipped dir). No
  change to `generate_pack_meta` itself; its call stays unsuppressed.
- Why this does not breach the no-swallow invariant (§4.3, clarified
  this round): the invariant governs failures of writes the installer
  PERFORMS — a failed stage write, a `find` failing on a dir that
  exists, a failed rename all still propagate and abort, unchanged.
  A nonexistent hash source is not a failed write; the meta's whole
  content is "upstream hashes", and for a dir with no upstream there
  is nothing to record — the operation is inapplicable, not failed.
  The guard is the same form as the two guards already standing in
  the same loop. The skip is logged, so it is observable, never
  silent (the stance §4.5 takes for rollback accounting, applied
  here).
- Why not (a) (treat a nonexistent hash dir as an empty file list):
  it would write a meta asserting an EMPTY upstream file list for a
  dir that may hold real files. That meta is the baseline the next
  run's customized-file detection trusts (the function's own header
  comment), so an empty baseline misclassifies files downstream —
  and it resurrects, deliberately this time, the header-only meta
  artifact the incident record names as corruption. A knowingly
  false record is worse than no record.
- Why not (c) (accept the strictness, re-pin fx.b3): it contradicts
  this handoff's own §1 Success Definition — "with no failure
  injected, a clean upgrade behaves exactly as today" — and today
  such upgrades succeed. It would also make install success depend
  on `is_pack_skill` being a proof of source-dir existence; it is a
  fixed-string grep over registry text (a newline in a dir name
  splits its pattern — the fx.b3 shape), i.e. a heuristic promoted
  to a hard dependency. fx.b3's premise (upgrade succeeds with such
  a dir present, changes.tsv still correct) is the pre-hotfix
  behavior contract and stands unmodified.
- Verification: new §9.1 row AC14 (fx.b3 green unmodified + code read
  of the guard's form). AC5's fx.b3 component becomes satisfiable by
  this fix; AC7 is unaffected (the guard adds no suppression — AC7's
  reviewer grep must show the call site still bare).

### D4 — aw.4 tree-identity clause: RULED re-scope to named-set identity; hooks.json gap ticketed

- The clause as written ("tree byte-identical after rollback") is
  unsatisfiable in principle for a stamp-point failure, for two
  distinct reasons that must not be merged:
  1. `.tad/brain-index.md` — the run regenerates it after the copy
     phase; the generator embeds a minute-resolution timestamp, so
     even a hypothetical perfect restore of everything else cannot
     make post-run bytes equal pre-run bytes unless the file itself
     is restored — and it is in NEITHER rollback domain (deny-listed
     from the backup derivation; rollback step 2 skips `.tad/*`).
  2. `.codex/hooks.json` — the 2.3.0-era deprecation entry deletes it
     mid-run (bytes preserved under `.tad-backup/…-deprecations/`);
     the same run regenerates it and, the file being absent at
     generation time, records it as run-created; rollback step 2
     restores the snapshot copy and step 4 then removes it as
     run-created. Net: a failed run past both points loses the live
     file (bytes survive only in the deprecation backup).
- **Consistency with Gate 2 Q2, stated explicitly:** Q2 accepted
  brain-index's exclusion from the WRITE set with rider (i) — a
  mid-generation fault may leave a partial brain-index; recorded
  risk acceptance, because the file is regenerable routing, never
  state. D4 extends the SAME position to the identity side: a file
  the chain already ruled out of the write set, whose content is
  timestamped by construction, cannot be inside a byte-identity
  claim. One position, two surfaces — not a new exception.
  `.codex/hooks.json` is NOT covered by Q2 and is NOT waved through
  on the same logic: it is a framework surface and its loss is a
  genuine pre-existing rollback-fidelity defect (step 4 removing
  what step 2 restored). It is excluded from this hotfix only
  because its fix sits in two §9 out-listed areas (deprecation
  behavior; created-entry tracking in the backup/snapshot
  subsystem) — the same treatment U2 received (R2/R3), not a
  dismissal.
- **Ruling: re-scope the clause** (§4.6 aw.4 and AC4 amended this
  round): identity modulo preserved recovery copies, with the
  differing-surface set required to be a subset of exactly the two
  named surfaces and printed by the case either way; any third
  differing surface fails. This is the §1 Success Definition's own
  fallback form ("or the shortfall is enumerated by name with
  preserved recovery copies") made mechanical — the clause now
  matches the definition it serves, and it keeps discriminating
  power: the aw.4 run log shows the mechanism isolates exactly the
  two surfaces out of the whole tree. aw.1's clause is unchanged
  (its failure point precedes both mechanisms; §4.6 note).
- **D4-R — residual obligations:** (i) risk card gains assumption A7
  (the falsifiable form of the hooks.json gap; added this round);
  (ii) before this Epic closes, the conductor files a follow-up
  ticket — "rollback removes a deprecation-deleted, same-run-
  regenerated file it restored (`.codex/hooks.json`)" — whose Gate 2
  precondition is a fixture able to reproduce the delete → regenerate
  → restore → remove sequence standalone; the ticket reference
  belongs in the Epic closeout record; (iii) aw.4's named set keeps
  the gap visible at every release run until the ticket lands —
  removing hooks.json from the named set without the ticket's fix
  is not permitted by this ruling.

### D1 — W11 source-absence tolerance: ACCEPTED as implemented

- The landed form keeps R1's guard line verbatim at all three sites
  and nests a source-existence check inside it (disk-verified this
  session). The acceptance grounds: R1's load-bearing claims are
  untouched — a PRESENT seed still lands via `atomic_install_file`
  or fails the run (fail-stop intact), a pre-existing project-owned
  README is still never overwritten (the create-only guard is the
  outer condition), and AC13's two greps still read 0 / 3 as R1's
  baselines require. The delta covers only a source that has no seed
  at all — a real shape (the fixture's pruned source; project-
  knowledge is deny-listed from distributions) under which R1's
  literal form would fail EVERY install, contradicting §1's clean-
  run success definition. Restoring the pre-hotfix net effect for
  the absent-source case while keeping the atomic form for the
  present case is conformance, not a softening. No AC change.

### D3 — fixture shim matching precision + pre-diff filtering: ACCEPTED as implemented

- §4.6's load-bearing requirements are: arm ONLY inside the target
  tree; discriminate phases by destination form; the witness proves
  the armed failure at the intended destination in the intended
  phase after earlier in-tree writes landed. Basename matching
  failed the first requirement in practice — the framework ships
  same-basename files inside itself (`.tad/tests/state-surface-
  fixture/**`), so the shim armed REAL but WRONG writes and the
  witness log named them (R3). Matching by target-relative path
  after stage-suffix stripping keeps phase discrimination (the
  stage / `.rollback-staging` forms are suffix shapes on that path)
  and is strictly stronger on all three requirements — it arms
  exactly the named write, never a same-named bystander. The
  tree-identity half (filter preserved-copy signature lines BEFORE
  diffing) is the fixture's own documented fx_diff convention for
  the same assertion class; fx_diff's post-diff filtering leaked
  bare hunk headers (R4), a reporting defect, not an assertion
  change. No §4.6 assertion loses a clause under either refinement;
  Gate 3 reviewers are asked to confirm that explicitly when they
  re-run the aw cases (their AC runs, not this ruling, are the
  evidence).

### AC3 — mode-pair substitution: ACCEPTED; the spec text, not the check, was wrong

- The substitution (`.tad/scripts/evidence-freshness-check.sh` and
  `.tad/hooks/startup-health.sh`, both 750=750, printed) is accepted,
  and §4.6 / AC3 are amended this round to the executable-pair form.
  Grounds, disk-verified: `tad.sh` appears in NO copy set — top
  files are `.tad/*` files, framework dirs are `.tad/*` trees,
  root files derive from platform-codes `extra_root_files`; the
  installer is the executing program, never payload, and no fixture
  target has ever contained a target-root `tad.sh`. The design-side
  text named an object that cannot exist in the checked position —
  a factual error in the design, recorded as such. The checked
  property (landed mode == source mode through the atomic tree
  copy), which is the operational half of the Q1 source-wins ruling,
  is identical for the substituted pair: both files land through
  `atomic_install_tree`, the path whose mode semantics Q1 governs.

### Fix-round口径 for Blake (the only code this ruling authorizes)

1. D6: the pack-meta loop guard exactly as ruled above (one guard +
   log line; `generate_pack_meta` and its call otherwise untouched).
   Proof: `--case fx.b3` green, unmodified case; AC14 code read.
2. D4: fixture-only — aw.4's tree-identity assertion takes the
   named-set form of §4.6 (extract the differing path set from the
   existing pre-filtered signature diff; require set ⊆
   {`.tad/brain-index.md`, `.codex/hooks.json`}; print the set either
   way; pinned pass line unchanged). No `tad.sh` change for D4.
3. D1 / D3 / AC3: no code change — accepted as implemented.
4. After the fix round, update the COMPLETION's D4/D6 rows and §9.1
   values (AC4, AC5, AC14) with the new measured outputs; the
   remaining AC5 environment-bound failures keep their attributions
   (they are not this ruling's business). Gate 3 dual review then
   runs against the final state and must name the fix-round deltas
   (D6 guard, aw.4 assertion form) in its review scope.

## Gate Rounds

### Gate 3: Code Review (post-implementation; two independent reviewers)
- [ ] Code review (independence: not Blake): PENDING
- [ ] Run review (independence: not Blake): PENDING

### Gate 4: Acceptance (independent Alex; RP1–RP3)
- [x] Acceptor (independence: not the design author, not Blake):
      CONDITIONAL PASS (p0=0, p1=0), dispatch hf-gate4-1, 2026-11-01 —
      RP1/RP2/RP3 all PASS first-hand on a real 4.0.8 project copy
      (allround); three carries named (gate3-check form reconciliation;
      ROLLBACK-RESULT verdict calculus, RP1 real-project confirmation;
      COMPLETION evidence-pointer hygiene). Report:
      `.tad/evidence/yolo/v4010-hotfix/p1-gate-report.md`.

## Sign-off

- [x] Alex (design): 2026-11-01, dispatch hf-design-1 — design only.
- [x] Alex (Gate 2 revision): 2026-11-01, dispatch hf-design-2 — all
      dual-lens conditions landed (see Gate 2 Revision Record).
- [x] Alex (S0 ruling): 2026-11-01, dispatch hf-design-3 — U1 added as
      W11 (R1), U2 named exclusion with residual obligations (R2/R3);
      narrow Gate 2 re-review of the delta PENDING.
- [x] Alex (post-implementation ruling): 2026-11-01, dispatch
      hf-design-4 — D6 ruled (b) logged caller precondition guard
      (AC14 added); D4 aw.4 clause re-scoped to named-set identity,
      hooks.json gap ticketed at closeout (D4-R, risk-card A7);
      D1 / D3 accepted as implemented; AC3 pair substitution
      accepted, spec text corrected. See Post-Implementation Ruling
      Record.
- [ ] Gate 2 dual review: CONDITIONAL PASS (both lenses, 2026-11-01);
      narrow re-review of the hf-design-2 amendments PENDING
- [ ] Blake (implementation): PENDING
- [ ] Gate 3 dual review: PENDING
- [x] Gate 4 (independent Alex): CONDITIONAL PASS, 2026-11-01,
      dispatch hf-gate4-1 — see Gate Rounds / Gate 4 above and
      `.tad/evidence/yolo/v4010-hotfix/p1-gate-report.md`.
