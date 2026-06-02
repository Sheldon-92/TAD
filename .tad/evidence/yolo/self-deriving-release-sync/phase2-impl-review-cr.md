# Phase 2 Implementation Review — Self-Deriving tad.sh Installer (code-reviewer)

**Scope**: `tad.sh` (commits f053f50 + de952b5), `.tad/hooks/lib/derive-sync-set.sh`, COMPLETION-20260601-self-deriving-release-sync-phase2.md
**Reviewer**: code-reviewer (blue-team)
**Date**: 2026-06-01
**Verdict**: **PASS** (no P0; P1/P2 are hardening, not blockers)

> Note: `de952b5` touches only EPIC docs (no `tad.sh` change). The implementation under review is entirely in `f053f50`.

---

## 1. Critical (P0)

**None.** Every load-bearing claim in the COMPLETION was independently re-derived and holds. Specifically verified by live re-run (not by reading Blake's summary):

- **Drift-check is REAL, not cosmetic.** `bash tad.sh --verify-denylist; echo $?` → `exit=0`, "12 entries". I then injected a lib-only deny-list addition (`NEWDIR` appended to `derive-sync-set.sh`'s `TRANSIENT`) and re-ran → **exit 1, DRIFT detected, `NEWDIR` named under "only in derive-sync-set.sh"**. The check genuinely compares the two sorted sets and fails closed on divergence.
- **Copy-set is genuinely derived, includes the formerly-omitted dirs.** `derive_framework_dirs .` emits 20 dirs including `codex`, `capability-packs`, `context`, `cross-model`, `scripts`, `tests` — exactly the dirs the old 14-entry allow-list silently dropped. All 12 deny-list dirs (`active`/`evidence`/`working`/… ) are excluded.
- **Self-check uses the SAME derivation, not a separate hardcoded list** (lines 308/325 reuse `derive_framework_dirs` via the identical `while read` pattern as the copy loop). So a future dir is auto-copied AND auto-verified from one source — the disease cannot silently recur. Confirmed it FAILS on omission: a live temp install + `rm -rf .tad/codex` → "MISSING or EMPTY: .tad/codex/", `missing=1`, return 1.
- **Registry-only honored**: live temp install left `.tad/capability-packs/` containing ONLY `pack-registry.yaml` (no pack tree).
- **No zero-touch clobber on a fresh install**: `.tad/active` was NOT created by the copy loop (deny-listed), so no harmful copy of `active`/`evidence` into a fresh tree. Concern #1's "could it copy a zero-touch dir" → **No.**
- **No framework dir MISSED**: the only dirs excluded are exactly the 12 deny + `sync-registry.yaml` (top file) + the pack tree (registry-only). `sync-registry.yaml` confirmed absent from the installed top-level.
- **dotfile fix works**: `.tad/context/.gitkeep` is copied (the mid-dogfood bug); `cp -R "$src/.tad/$dir/."` copies hidden files BSD/macOS-safely with no `shopt dotglob`.
- **version derivation safe**: source `version.txt` missing → fallback `2.21.0`; empty → fallback; junk/multiline → `head -1` + space-strip (reads the project's OWN trusted version.txt, so no validation needed). Cannot install with a stale literal once the source is fetched.
- `bash -n tad.sh` → clean. `--help` and existing `--yes/-y` + interactive-prompt UX preserved.

---

## 2. Recommendations (P1)

**P1-1 — Drift-check awk is coupled to the lib's variable NAMES (`ZERO_TOUCH=` / `TRANSIENT=`), not its public contract.**
`verify_denylist_drift` reconstructs the lib's deny set by awk-scraping two specific assignment lines (`tad.sh:209-213`). The lib (`derive-sync-set.sh`) already exposes a clean public API — `--zero-touch` — and could trivially expose the transient set too. Scraping internal variable assignments means a benign refactor of the lib (rename `ZERO_TOUCH`→`ZERO_TOUCH_DIRS`, fold the lists, switch to a heredoc) silently changes what the drift-check extracts.

*Mitigating factor (why this is P1, not P0):* I tested the worst case — both vars renamed so awk extracts **nothing** — and the check **fails closed** (`exit 1`, "only in tad.sh: <all 12>"). It can never false-PASS a drift into a release; the failure mode is a confusing-but-blocking error that forces a human to look. Still, the better design is to drive the comparison off the lib's existing flag interface:
```sh
# instead of awk-scraping ZERO_TOUCH/TRANSIENT:
lib_set="$( ( "$lib" --zero-touch "$root"; "$lib" --transient "$root" ) | LC_ALL=C sort -u )"
```
This requires the lib to add a `--transient` flag (it currently exposes `--zero-touch` but not `--transient`). That makes the drift-check robust to lib internal refactors and removes the fragile awk. (The lib's own header even says the constant block is the embeddable contract — so a flag that emits it is the natural seam.)

**P1-2 — `derive_framework_dirs` returns nonzero when the derivation yields zero dirs (grep -vxE no-match under `pipefail`).**
Reproduced: a `src` whose `.tad/` contains only deny-listed dirs → `derive_framework_dirs` exits 1 (the `grep -vxE` in the pipe finds no surviving line; `pipefail` propagates it). In the live copy/self-check loops this is consumed via `<<< "$(derive_framework_dirs "$src")"`, and command-substitution-in-a-here-string does NOT propagate the inner status to the enclosing `set -e` (verified: the `while` loop completes rc=0). So **no spurious abort today** — a real source always has ≥1 framework dir. But if either function is ever called in a pipeline/`if`/direct-status context, the empty case becomes a silent false signal. Recommend appending `|| true` to the pipeline inside `derive_framework_dirs`, or `{ grep -vxE "$deny_re" || true; }`.

**P1-3 — Self-check is fail-CLOSED on omission, which means a partial source rolls the whole install back.**
The COMPLETION's own "Carry-forwards" notes this: `verify_install_complete` returns 1 → under `main`'s `set -e` + `trap … ERR` this triggers `rollback_on_failure` (restore backup, exit 1). For a genuine omission this is correct ("fail the install"). But note the asymmetry vs the function's own comment (line 301: "Non-fatal: warns + records a count; the ERR trap is NOT triggered") — **the comment is wrong**: the `return 1` path IS fatal under `main`. Either fix the comment to say "fatal under main (rolls back)" or, if a warn-but-proceed semantics was intended, change the call site to `verify_install_complete "$src" || true`. As-is the behavior is defensible (fail the install on a broken source), but the in-code comment contradicts the actual behavior — a future maintainer will be misled.

---

## 3. Suggestions (P2)

- **P2-1 — Dead code in `verify_denylist_drift` (lines 200-206).** The `( set +euo pipefail … true ) >/dev/null 2>&1` subshell does nothing (its comment even says "Simpler: grep…"). It's a leftover of an abandoned source-the-lib approach. Remove it to reduce reader confusion; it has zero runtime effect but reads as if it matters.
- **P2-2 — `derive_target_version` does no format sanity-check.** A junk first line (`v9.9.9-beta`, or even a stray non-version string) is accepted verbatim and printed into the banner / written to `.tad/version.txt`. Acceptable because it reads the project's own committed `version.txt` (trusted), but a one-line guard (`[[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]` else fallback) would harden against a corrupted source tarball without cost.
- **P2-3 — File-count `find` exclusion list (lines 285-288) is still a hardcoded 5-dir subset** of the 12-dir deny-list (omits `decisions`, `github-registry`, `research-notebooks`, `working`, `spike-v3`, `reports`, `checklists`). This only affects the cosmetic "Synced N files" number, not correctness — but it's a small instance of the same hardcoded-vs-derived smell P2 exists to kill. Low priority; could derive the prune list from `$TAD_ZERO_TOUCH` if ever revisited.
- **P2-4 — `comm -23/-13` in the drift error path** correctly uses `LC_ALL=C` on both `comm` and the feeding `sort`s (matches the project's CJK-collation lesson). The deny-list is ASCII-only so this is belt-and-suspenders, but it's correct — noted as a positive.

---

## 4. Overall

**PASS.**

The implementation does exactly what P2 set out to do: it kills the hardcoded-list omission disease at the installer with a single derived copy-set, reuses that same derivation for the post-install self-check (so the cure cannot silently regress), and backs it with a real, fail-closed release-time drift check against the P1 lib. Every COMPLETION claim survived independent re-derivation — the dogfood was not theater. `codex` (the original symptom) is now installed and verified; the dotfile bug the self-check caught mid-dogfood is genuinely fixed.

No P0. The P1 items are hardening (awk→flag-interface, empty-derivation `|| true`, and one misleading comment) that improve robustness against FUTURE refactors but do not affect current correctness. Safe to ship; recommend addressing P1-1 and P1-3 (comment) opportunistically — ideally P1-1 alongside the lib gaining a `--transient` flag so the drift-check stops scraping internal variable names.

### Verification log (re-run, not read)
- `bash -n tad.sh` → clean (exit 0)
- `bash tad.sh --verify-denylist; echo $?` → `✓ … (12 entries)` **exit 0**
- drift injected (lib `TRANSIENT` += `NEWDIR`) → `✗ DRIFT … only in derive-sync-set.sh: NEWDIR` **exit 1**
- worst-case awk (both lib vars renamed → empty extraction) → **exit 1** (fails closed, no false-PASS)
- live temp install `copy_framework_files "$repo"` → 20/20 self-check PASS; `capability-packs/` = registry only; `codex/` present; `context/.gitkeep` present; `sync-registry.yaml` absent; `active/` not created
- inject omission (`rm -rf .tad/codex`) → self-check **return 1**, names `codex`
- `derive_target_version`: missing→fallback, empty→fallback, junk→head-1 verbatim
- empty-glob top-level loop under real bash → survives (exit 0)
