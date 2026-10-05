# Code Review — f02-guarded-deletion (2026-08-17)

**Reviewer**: code-reviewer (Layer 2, independent subagent)
**Object**: `tad.sh` `apply_deprecations()` + `.tad/hooks/lib/migration-engine.sh`
**Baseline**: `cd70cf26`
**Reviewed snapshot**: `tad.sh` sha256 `5a747e713f820bcb08c64bf77493b60493dc0fa46eb311058f611f3e8d3a11d2`,
`migration-engine.sh` sha256 `4b941ceedf23507c534c64ddbd2dfc90d8b4b100f28fbb93ef957e2d8c65607a`
**Environments**: bash 5.3 + macOS native bash 3.2.57 (BSD grep) — every claim executed, not read

## Verdict timeline

| Round | Verdict | Findings |
|---|---|---|
| R1 | CONDITIONAL | no P0; **P1-1** authority-unreadable hard-kills install; **P1-2** `.`/`..` unscreened before `do_backup` |
| R2 | CONDITIONAL | P1-1 fixed (3/3); P1-2 named patterns fixed but **`./`-family still escaping** (recursive self-copy) |
| R3 | PASS | all three fixes verified; no P0/P1 |
| **R4 (frozen-hash confirmation)** | ✅ **PASS** | both hashes byte-matched the frozen delivery; three fixes re-confirmed on the frozen bytes |

**Frozen-hash confirmation (R4)**: reviewer independently verified
`tad.sh` = `5a747e71…11d2` and `migration-engine.sh` = `4b941cee…607a` match the reviewed
content byte-for-byte (git index `a6ea84eb`), so the PASS verdict applies to exactly the
delivered bytes. Fresh e2e on the frozen version: `deleted=2 refused=5`; refused zero-touch
entry triggered `[rollback-removed-copy]` with the original surviving; backup area file count
exactly 3 (2 accepted backups + 1 pre-seeded); pre-seeded backup content preserved verbatim
(`backup_preexisted` guard proven sufficient — resolution semantics make it unreachable for
traversal entries); `./`-family refused before `do_backup` with self-copy nesting = 1;
script survived rc=0, rollback never fired.

## R1: 8 handoff review items — all met (with evidence)

| # | Item | Result |
|---|---|---|
| 1 | `TARGET` assigned AFTER source (engine L15 resets it) | ✅ source at 1196, assignment 1199-1200 |
| 2 | `M_FROM`/`M_TO` set before `do_backup` uses them | ✅ 1206-1207; unset-is-fatal empirically confirmed; `current→current` namespace proven disjoint from migration's `old→new` (`resolve_chain` rejects from==to) |
| 3 | `load_zero_touch` called (else silent fail-OPEN) | ✅ 1215; e2e proved no fail-open |
| 4 | ERR-trap suppression via `\|\| rc=$?` | ✅ verified on 3 failure paths, both bash versions; `set +e` confirmed NOT to suppress |
| 5 | `source` inside the function (top-level would swap `main`) | ✅ 1196; BASH_SOURCE guard verified both directions |
| 6 | `version_le` override harmless | ✅ single call site; `LC_ALL=C` equivalent for pure semver |
| 7 | Engine diff minimal | ✅ one hunk, guard logic untouched |
| 8 | Shell hygiene (quoting/local/set -u/spaces) | ✅ incl. end-to-end run with spaces in both target and source paths |

## R3: the three fixes

**① `./`-family predicate `(^|/)\.\.?(/|$)`** — matrix verified on both bash versions:
- REJECT: `./` `./.` `a/./` `deeper/inner/./` `.//` `./foo` `a/./b` + all `..`-forms
- ALLOW: `..foo` `...` `.../a` `.foo` `a..` `a/..../b` `.tad/codex/schemas/` (NFR4), `%2e%2e`/`%2f` literals (correct — they are filenames, not traversal)
- **0 of 82 real manifest entries rejected** → NFR4 safe
- e2e: `./` refused before `do_backup`; no nested self-copy; rest of the run not poisoned

**② Probe hardening `( trap - ERR; load_zero_touch "$src" )`** — probe still works (ZT_LIST 12 lines);
the inherited-rollback-trap class is removed entirely.

**③ Refused-entry backup rollback** — verified (both bash, `deleted=4 refused=7`):
- zero-touch refusals: the copy `do_backup` made is rolled back by `find -depth -delete`; **original survives**; accepted entries keep their backup → P1-3 leak closed
- `backup_preexisted` guard sufficient: `[ -e ... ]` is resolution-semantic, so traversal entries either have no backup path or are marked pre-existing — they never reach the `find`. Pre-seeded backups verified intact.
- `find -depth -delete` vs `rm -rf` tradeoff **stands**: AC-2=0 / AC-2b=11 / AC-N2=4 all hold; `find` touches only the copy this run created, never target content; does not follow symlinks; partial-copy failures also get cleaned.

## Remaining P2 (known, non-blocking)
1. `main`/`version_le` definition replacement relies on the "main called once, deprecations runs inside it" invariant
2. macOS BSD `sort` has no `-V` → `version_le` degraded (pre-existing, not introduced here)
3. Probe double-call ~32ms (quantified, negligible)
4. Same-version rerun: accepted entries' backups block re-deletion of recreated files (see independent verifier's P2)

## Verdict: ✅ **PASS** — ready for acceptance