# Handoff Code Review — memory-redirect-capture-layer

**Reviewer:** code-reviewer (narrow-scope, contract-preserving)
**Handoff:** HANDOFF-20260712-memory-redirect-capture-layer.md
**Date:** 2026-07-12
**Scope read:** §6 (T1–T7), §9 (incl 9.1 table), §10, plus T3/T4 target files. Blast-radius grep: `zero-touch|ZERO_TOUCH` across `.tad/hooks/` + `tad.sh` (the one sanctioned wider grep).
**Verdict:** CONDITIONAL PASS (1 P0 must be fixed before implementation)

---

## 1. Critical Issues (P0 — must fix before implementation)

### P0-1 — T3 zero-touch edit breaks `tad.sh --verify-denylist` (release-blocking drift)

The handoff's T3 (and its inline note) claims:

> "tad.sh 的 drift 检查通过 `--zero-touch` flag 读取,自动一致(公共 flag 接口,principles.md 2026-06-01)。**只加这一个词,不动其他行**。"

**This is factually wrong and will fail the release.** `tad.sh` keeps its **own hardcoded second copy** of the zero-touch list (`TAD_ZERO_TOUCH`, tad.sh:207–216) and `--verify-denylist` (tad.sh:709–735) asserts **set-equality** between that inline copy and the lib's `--zero-touch ∪ --transient` output:

```
here_set = sort -u TAD_DENY_LIST            # tad.sh's inline copy (15 entries today)
lib_set  = sort -u (lib --zero-touch ∪ --transient)
[ "$here_set" = "$lib_set" ] || DRIFT → return 1
```

The public-flag interface (2026-06-01 lesson) only removes the *awk-scraping-of-variable-names* fragility — it protects against a benign **rename/refold** of the lib's internals. It does **NOT** make a **value addition** propagate. Adding `memory` to the lib's `ZERO_TOUCH` makes `lib_set` = 16 entries while `here_set` stays 15 → `comm` reports "only in derive-sync-set.sh: memory" → `--verify-denylist` returns 1 → the release gate fails.

Verified live:
```
$ bash tad.sh --verify-denylist
✓ --verify-denylist: tad.sh inlined DENY_LIST == derive-sync-set.sh (15 entries)
```
This currently PASSES at 15. The T3 edit as written would flip it to FAIL.

**Fix:** T3 must edit **BOTH** copies symmetrically:
- `.tad/hooks/lib/derive-sync-set.sh` `ZERO_TOUCH` (add `memory`), AND
- `tad.sh` `TAD_ZERO_TOUCH` (add `memory`).
Then update the count comments (lib line 16 "the 10 category-A"; lib line 48 "category-A (zero-touch, 10)…= 15 dirs"; lib line 52 "NEVER sync, 10 dirs"; tad.sh:206 has no count but the header block near tad.sh:200–204 explicitly says *"If you edit DENY_LIST in either file, edit BOTH or the drift-check FAILS the release."* — that header is the ground truth the handoff contradicts).
- Add an AC that runs `bash tad.sh --verify-denylist` and expects exit 0 / "16 entries". **This AC is currently missing entirely** — AC3 only checks the lib's `--zero-touch`/`--dirs`, never the tad.sh drift gate, so a broken (lib-only) implementation would pass AC3 and still break the release.

This is the SAFETY red-line the handoff itself flags (§Project Knowledge #2, AC3 "load-bearing"), so the mis-specification is doubly important.

---

## 2. Recommendations (P1 — should address)

### P1-1 — T4 protocol: literal `find … -newer <cursor>` errors when cursor is absent (first-run path)

T4 step 2 gives the command `find .tad/memory -name '*.md' ! -name 'MEMORY.md' -newer <cursor>`, while step 1 says "Absent cursor (first run) → treat ALL .tad/memory/*.md as new". The two steps are only reconciled in prose. `find … -newer <nonexistent-file>` is a **hard error** on both BSD/macOS and GNU find (verified: errors, does not treat-all-as-new). A distiller (Alex) or any agent following the literal command on first run — exactly the migrated-36 full-sweep case, the most important run — hits an error instead of the intended full sweep.

**Fix:** Make the branch explicit and executable in the protocol text, e.g.:
```
if [ -f "$cursor" ]; then
  find .tad/memory -name '*.md' ! -name 'MEMORY.md' -newer "$cursor"
else
  find .tad/memory -name '*.md' ! -name 'MEMORY.md'   # first run: full sweep
fi
```
Since this is human-gated advisory prose (not code), at minimum reword step 2 so the `-newer` form is explicitly guarded by "only when the cursor file exists."

### P1-2 — AC8 (falsification test) has no rollback/abort action if `--enable` runs but redirect proves ineffective

AC8 correctly frames the doc-level evidence as unverified and says "停下并按 friction protocol 上报". But by the time AC8 runs (Gate 4, new session), T2 has **already** written `autoMemoryDirectory` into settings.local.json and migrated 36 files. If the redirect is inert (e.g., relative-path-only support, or the key is ignored), the repo is left in a half-applied state with a settings key that does nothing and a `.tad/memory/` that native never writes to. Recommend adding an explicit "if AC8 fails: `bash memory-redirect.sh --status` to confirm state, and document/revert the settings.local.json key" step so the falsification branch leaves a clean tree rather than a silently-inert config.

### P1-3 — AC9 "变更范围如计划" is non-discriminating as written

AC9 verifies via `git diff --stat` + `git status --short` and expects "仅 §7 列出的文件". But settings.local.json is gitignored (per T7 grounding: ".gitignore …settings.local.json 已 ignore") and `.tad/memory/` is a fresh untracked tree of 36+ files. The AC's parenthetical hand-waves this ("按其性质呈现") without a concrete pass/fail predicate. As written a reviewer cannot mechanically decide PASS vs FAIL. Recommend: assert the **tracked** diff set exactly equals {derive-sync-set.sh, distillation-loop-protocol.md, CLAUDE.md, release-runbook/SKILL.md, .agents/…/distillation-loop-protocol.md, **tad.sh** (per P0-1)} and separately assert `.tad/memory/` is present + untracked. Note: this AC list must be updated to include `tad.sh` once P0-1 is applied.

### P1-4 — T1 status()/enable() `ls | wc -l` counts are informational only, not asserted robustly

`status()` uses `ls "$DIR" 2>/dev/null | wc -l`. This counts dotfiles inconsistently and would miscount if native ever writes subdirectories. For AC2's load-bearing "旧 = 36 不变" assertion, prefer `find "$DIR" -maxdepth 1 -type f -name '*.md' | wc -l` in the AC verification command (the script's own echo can stay as-is since it's just operator feedback). Minor, but AC2 is the "migration didn't destroy the backup" guard.

---

## 3. Suggestions (P2 — nice to have)

- **P2-1 (AC4/AC5 line-set diff blind spots):** `comm -23 <(sort -u OLD) <(sort -u NEW)` correctly returns 0 for purely-additive edits (verified), but is blind to (a) line **reordering** and (b) removal of a **duplicate** line (sort -u collapses duplicates). For a strictly-additive task this is acceptable, but the AC claims "无删除行" more strongly than the command proves. Consider also asserting `git show HEAD:file | wc -l` ≤ current `wc -l` and that the old content appears as a contiguous prefix, if stronger additive proof is wanted.
- **P2-2 (T1 SLUG portability):** `sed 's![/ ]!-!g'` replaces `/` and space only. The implementation hint correctly says to verify against the real dir first. Worth noting for downstream opt-in: project paths containing other shell-special chars (`:`, `(`, `)` — this repo's path has none beyond space) may not match Claude Code's actual slugging. The `--status` diagnostic surfaces this (shows old-dir file count), which is a good safety valve; keep it.
- **P2-3 (T1 idempotency of repeated `--enable`):** The jq merge `. + {autoMemoryDirectory:$d}` is idempotent (overwrites same key with same value), and `cp -n` won't re-clobber — repeated `--enable` is safe (verified logic). AC7 checks this; good. One edge: if the user later manually edits a migrated file in `.tad/memory/`, a second `--enable` won't touch it (cp -n) — correct behavior, worth a one-line comment in the script so future maintainers don't "fix" it to `cp -f`.
- **P2-4 (mktemp location):** `mktemp` defaults to `$TMPDIR`; the subsequent `mv "$tmp" "$LOCAL_SETTINGS"` crosses filesystems on some setups (non-atomic, falls back to copy+unlink). Fine for a single config file, but `mktemp -p .claude` (or the settings dir) keeps it same-fs/atomic. Low priority.
- **P2-5 (`cp -n` + `set -e`):** `cp -n … || true` correctly neutralizes the non-zero exit when all targets already exist; the `2>/dev/null` also hides the "not overwritten" noise. Good pattern, no change needed — just confirming it's correct under `set -euo pipefail`.

---

## 4. Blast-Radius Findings (sanctioned grep)

`memory` added to ZERO_TOUCH touches these consumers (all READ the flag as single source of truth, so they inherit the new entry correctly **once the lib is edited** — none break):
- `release-verify.sh` (version mode L262–291, structural mode L407–424): reads `--zero-touch`, filters those dirs out of the version-scope / structural set by path-prefix. Adding `memory` correctly excludes `.tad/memory/` from version-string scanning and structural diff. ✅ desirable, no break.
- `migration-engine.sh` (L127–224): reads `--zero-touch` as the authority for REJECT-on-write protection. Adding `memory` means migration/install will now REJECT any attempt to write into a target's `.tad/memory/` — exactly the "sync never clobbers downstream memory" guarantee D4 wants. ✅ desirable.
- `migration-draft.sh` (L80–131): reads `--zero-touch` to filter draft diffs. Inherits correctly. ✅
- **`tad.sh` (L207–216, L709–735): the ONE consumer that does NOT auto-inherit — it holds a duplicate hardcoded list and asserts equality. → P0-1.**

No consumer is broken by the addition itself; the only break is the tad.sh duplicate-list drift gate (P0-1).

---

## 5. Verification-Command Sanity (as executed)

- AC3 `--zero-touch | grep -cx memory` → `-x` requires whole-line match; output is bare basenames one-per-line, so `-cx` correctly yields 1 post-impl with no substring false-positives. ✅
- AC3 `--dirs | grep -cx memory` → post-impl 0 because `memory` is deny-listed (excluded from emit_dirs). ✅ (ordering: T3 before/independent of T2's dir creation — either way `--dirs` excludes it.)
- AC4 `grep -c '^## Step'` = 7 today (verified); new heading `## Second Capture Source` does not match `^## Step`, so count stays 7. ✅
- AC1 baseline keys = `{permissions}` (verified via `jq -r 'keys[]'`); post-merge = `{autoMemoryDirectory, permissions}`. ✅
- Old memory dir = 36 files, all `.md`, MEMORY.md present (verified) → `cp -n "$OLD_DIR"/*.md` migrates cleanly, no non-.md surprises. ✅
- `.agents/skills/alex/references/distillation-loop-protocol.md` mirror exists (verified) → T6 parity target is real. ✅

---

## Summary

**P0: 1 | P1: 4 | P2: 5 | Verdict: CONDITIONAL PASS**

The design is sound and the additive/read-only discipline is well-reasoned. One release-blocking mis-specification: T3 asserts the tad.sh drift check auto-tracks the lib via the public flag, but tad.sh holds a duplicate hardcoded zero-touch list and `--verify-denylist` asserts set-equality — so `memory` must be added to BOTH files (+ count comments) and an AC must gate `bash tad.sh --verify-denylist` == exit 0. Fix P0-1 and address P1-1 (first-run `find -newer` error) and this is ready.
