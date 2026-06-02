---
handoff: HANDOFF-20260601-self-deriving-release-sync-phase2 (Epic P2 Detail Block)
epic: EPIC-20260601-self-deriving-release-sync
phase: 2
agent: Blake
date: 2026-06-01
gate3_verdict: pass
---

# COMPLETION — Self-Deriving tad.sh Installer (Epic P2)

## Summary

Replaced `tad.sh`'s three hardcoded release lists with **structure-derived** rules, mirroring P1's
`derive-sync-set.sh`:

1. The hardcoded 14-dir copy loop → **inlined deny-list derivation** (`{ ls -d .tad/*/ } − DENY_LIST`).
2. The hand-edited `TARGET_VERSION="2.21.0"` literal → **version derived from source `.tad/version.txt`** at install time (literal kept as fallback).
3. Added a **post-install completeness self-check** that asserts every derived framework dir is present + non-empty.
4. Added a **release-time drift check** (`tad.sh --verify-denylist`) so the inlined DENY_LIST cannot silently diverge from the lib.

## Files Changed

| File | Change |
|------|--------|
| `tad.sh` | +221/−20: inlined `TAD_DENY_LIST` + `derive_framework_dirs()`; `copy_framework_files()` derives copy-set (deny-list) instead of hardcoded loop; `derive_target_version()` reads source version.txt; `verify_install_complete()` post-install self-check; `verify_denylist_drift()` + `--verify-denylist` flag; dotfile-safe copy (`cp -R src/. dst/`). |
| `.claude/skills/release-runbook/SKILL.md` | +37/−... : documented the self-deriving installer (3 pieces) + the mandatory release-time `--verify-denylist` drift check; added drift-check to Phase 1 pre-flight checklist as HARD BLOCK when tad.sh/derive-sync-set.sh change. |

## bash -n

```
$ bash -n tad.sh
BASH-N: clean
$ bash tad.sh --help
Usage: tad.sh [--yes|-y] [--verify-denylist]
  --yes              skip the interactive confirmation prompt
  --verify-denylist  (TAD repo only) assert tad.sh's inlined DENY_LIST == derive-sync-set.sh
```

## AC4 Dogfood — fresh install into temp dir

Harness: sourced `tad.sh`'s function definitions (arg-loop / `main` / ERR-trap stripped) into a temp
TARGET dir with `src` = the live repo, invoked `copy_framework_files` + `verify_install_complete`.

### (a) Clean install — self-check passes + codex installed

```
=== AC4(a): fresh copy_framework_files + self-check ===
✓   → Synced 154 framework files to .tad/
✓     ✓ Self-check passed: all 20 derived framework dirs present + non-empty

=== codex (formerly-omitted) installed? ===
YES — codex present (10 files)

=== context (.gitkeep-only) now non-empty? ===
.gitkeep

=== self-check exit code (clean install) ===
exit=0
```

`codex` — the dir the old 14-list silently omitted — **IS now installed**. Also verified newly-covered:
`capability-packs` (registry-only: just `pack-registry.yaml`), `context`, `cross-model`, `scripts`, `tests`.

### (b) Inject omission — self-check catches it

```
=== AC4(b): inject omission — delete .tad/codex from installed tree ===
codex dir exists after delete? no
=== re-run self-check (should FAIL + name codex) ===
⚠     ✗ MISSING or EMPTY: .tad/codex/
✗     ✗ Self-check FAILED: 1 of 20 derived framework dir(s) missing/empty
   (exit=1)

=== empty-dir omission: empty out .tad/scripts ===
⚠     ✗ MISSING or EMPTY: .tad/scripts/
✗     ✗ Self-check FAILED: 1 of 20 derived framework dir(s) missing/empty   (exit=1)

=== registry-only omission: delete pack-registry.yaml ===
⚠     ✗ MISSING: .tad/capability-packs/pack-registry.yaml (registry index)
```

Self-check catches deleted-dir, emptied-dir, and the registry-only index file. Temp dirs cleaned up.

### Bug found + fixed during dogfood

First dogfood run FAILED the self-check on `.tad/context/` (a `.gitkeep`-only dir): the copy loop used
`"$src/.tad/$dir/"*` which a bare glob does NOT expand for dotfiles → target left empty → self-check
(correctly) flagged it. Fixed by copying with `cp -R "$src/.tad/$dir/." ".tad/$dir/"` (trailing `/.` copies
contents incl. dotfiles, BSD/macOS-safe, no `shopt dotglob`). Re-ran → clean 20/20. The self-check did its
job — it caught a real copy gap.

## Drift-check Dogfood — AC drift-check (arch P1-3)

```
=== drift-check (in sync, should PASS exit 0) ===
✓ --verify-denylist: tad.sh inlined DENY_LIST == derive-sync-set.sh (12 entries)
exit=0

=== drift-check on FLIPPED temp tad.sh (checklists → checklists-DRIFT; should FAIL exit 1) ===
✗ --verify-denylist: DRIFT detected between tad.sh and derive-sync-set.sh
  --- only in tad.sh ---
    checklists-DRIFT
  --- only in derive-sync-set.sh ---
    checklists
exit=1
```

tad.sh's inlined DENY_LIST (12: 8 zero-touch + 4 transient) == derive-sync-set.sh's authoritative set;
flipping one entry is caught and both sides are named.

## AC2 — version-from-source unit test

```
after derive (source=9.9.9): TARGET_VERSION=9.9.9   (expect 9.9.9)
after derive (no source):    TARGET_VERSION=2.21.0  (expect 2.21.0 fallback)
```

## AC1–AC5 Table

| AC | Requirement | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | Copy-set derived (deny-list), not hardcoded; new dir auto-copies | ✅ PASS | `derive_framework_dirs` + deny-list loop; `codex` auto-installed; comment block "MUST stay == derive-sync-set.sh DENY_LIST" present; capability-packs registry-only + sync-registry.yaml exclusion honored |
| AC2 | TARGET_VERSION from `$src/.tad/version.txt`, sane fallback | ✅ PASS | `derive_target_version` wired post-download; unit test 9.9.9 ↔ 2.21.0 fallback |
| AC3 | Post-install completeness self-check; warn/fail on omission | ✅ PASS | `verify_install_complete` reuses deny-list derivation; clean=exit 0, omission=exit 1 |
| AC drift | Release-time check: tad.sh inlined DENY_LIST == lib DENY_LIST; documented | ✅ PASS | `tad.sh --verify-denylist` (repo-only, not install-time); in-sync exit 0, flipped exit 1; documented in release-runbook SKILL + Phase 1 pre-flight |
| AC5 | Existing UX unchanged; `bash -n` clean; help/dry path works | ✅ PASS | `--yes/-y` + prompts intact; `bash -n` clean; `--help` works; arg-parse only added `--verify-denylist` |

## Notes / Carry-forwards

- **Fail-closed on omission**: the self-check returns non-zero → under `main`'s `set -e` + ERR trap this
  triggers rollback. This is the intended "fail the install on omission" behavior (AC3 "warn/fail"); a real
  fresh install passes (proven 20/20).
- **detect_state pre-derivation**: `detect_state`/banner run BEFORE download, so they compare against the
  literal fallback; the derived version is applied for `version.txt` write + all post-download messaging.
  Acceptable — the "current vs upgrade" decision is robust to a stale literal because the post-download
  derived version is authoritative.
- **First real release** must use `TAD_RELEASE_GATE=warn` shadow (P1 carry-forward #2) before hard-block — out of P2 scope (that gate is in *publish/*sync, not the installer).

## Escalations

None. All Layer 1 checks passed within retry budget; no faked results. One real copy bug (dotfile omission)
was found by the self-check during dogfood and fixed.

---

## P1-Fix Log (P2)

Round-2 fix pass addressing the impl-review P1 findings (arch P1-1/P1-2, cr P1-1/P1-3). Edited `tad.sh`
+ `.tad/hooks/lib/derive-sync-set.sh` in place; re-verified by dogfood.

### arch-P1-1 (MANDATORY — the Epic's own thesis: a 2nd hardcoded allow-list survived)
- **Root cause**: `copy_framework_files` copied top-level `.tad/` files via the fixed extension allow-list
  `*.yaml *.md *.txt` → it **silently dropped** `.tad/portable-extract.sh` (git-tracked, runbook-referenced)
  and any future top-level `.sh`/`.json`. Same disease class as the old 14-dir allow-list, merely relocated
  from dirs to file-extensions.
- **Fix**: new `derive_framework_top_files <src>` helper — copies **every** regular file under `$src/.tad/`
  MINUS `TAD_TOP_DENY` (deny-list, any extension). The copy loop now reads from it. A new top-level framework
  file auto-copies with zero edits.
- **Before → After (portable-extract.sh copied?)**: **BEFORE = NO** (`.sh` ∉ `{yaml,md,txt}` glob, dropped) →
  **AFTER = YES** (dogfood: `.tad/portable-extract.sh` 2436 bytes, executable, present in temp install).

### arch-P1-1 cont. — verifiers extended to top-level files
- `verify_install_complete` now ALSO asserts each derived top-level file landed AND matches source (`cmp -s`).
  Dogfood: deleting `.tad/portable-extract.sh` from the target → self-check reports
  "MISSING top-level file: .tad/portable-extract.sh" + FAILED (was previously **undetected** by every gate).
- **Follow-up (recorded, not done here)**: P1's `release-verify.sh structural` likewise diffs `--dirs` +
  `.claude/skills` only — it should be extended to cover top-level files too. tad.sh's OWN self-check now
  covers them; the release-gate parity is a small P1 follow-up.

### arch-P1-2 / P1-3 — self-check = content diff, not just presence
- `verify_install_complete` now runs `diff -rq "$src/.tad/$dir" ".tad/$dir"` per derived framework dir (source
  is LOCAL at install time), catching **partial** copies, not just empty dirs. Presence + non-empty kept as
  fallback. registry-only + top-level files use `cmp -s`.
- **Before → After (partial-copy caught?)**: **BEFORE = NO** (presence-only: a dir with 1-of-50 files passes) →
  **AFTER = YES** (dogfood: deleted one file from a copied `.tad/agents/` → "PARTIAL/STALE: .tad/agents/ differs
  from source (diff -rq)" + FAILED, rc=1).

### cr-P1-3 — corrected the misleading comment (~old L301)
- The header comment claimed "Non-fatal: … the ERR trap is NOT triggered". This was **wrong** — `return 1`
  propagates under `main`'s `set -e` + `trap … ERR` → `rollback_on_failure`. Comment now states: "FATAL under
  main … → rollback. This is the desired behavior — a broken/partial source must fail the install."

### cr-P1-1 — drift-check off the lib's PUBLIC FLAGS, not internal var-name scraping
- Added `--transient` flag to `derive-sync-set.sh` (it already had `--zero-touch`). Together they are the public
  interface to the full DENY_LIST.
- `verify_denylist_drift` now reconstructs the lib's set via `bash "$lib" --zero-touch` + `--transient` instead
  of awk-scraping `ZERO_TOUCH=`/`TRANSIENT=` assignment lines → robust to benign lib refactors (rename/fold/
  re-quote). **Removed the dead `( set +euo … true )` no-op subshell** (P2-1).
- **Before → After (drift-flag works?)**: in-sync → exit 0 ("12 entries"); flipped a lib `TRANSIENT` entry
  (`DRIFTDIR`) → exit 1, named under "only in derive-sync-set.sh"; restored → exit 0. Robust-to-rename verified
  by the new flag path (no longer reads var names).

### Verification summary (re-run, not read)
- `bash -n tad.sh` → clean; `bash -n .tad/hooks/lib/derive-sync-set.sh` → clean.
- Fresh-install dogfood (temp dir, repo as src): `copy_framework_files` → "Synced 171 files",
  self-check "20 derived dirs (diff-clean) + 17 top-level files present", rc=0. `portable-extract.sh` copied;
  `codex/` present; `capability-packs/` = registry-only; `sync-registry.yaml` absent.
- Partial-copy injection (rm 1 file from `.tad/agents/`) → diff self-check CATCHES it (presence-only would miss).
- Top-level omission injection (rm `portable-extract.sh`) → self-check CATCHES it.
- `bash tad.sh --verify-denylist; echo $?` → 0 in-sync; lib deny flip → exit 1.
