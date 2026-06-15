---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: ["."]
skip_knowledge_assessment: no
gate4_delta: []
express: true
---

# Handoff: Fix tad.sh detect_state glob-arm hazard (numeric semver routing)

**From:** Alex  **To:** Blake  **Date:** 2026-06-14
**Source:** SURPLUS-PLAN-2026-06-14 #8 (auto-eligible, safe) + NEXT.md Deferred "detect_state glob-arm hazard"
**Tier:** express (single-file bash fix + test harness). Express ≠ review-exempt → ≥1 independent reviewer at Gate 3.

## Gate 2 Audit Trail (expert review integrated)
| Reviewer | Issue | Resolution | Status |
|----------|-------|-----------|--------|
| code-reviewer | **P0** AC10 (same-major downgrade 2.30.0 vs 2.29.1) unsatisfiable by major-only compare | Switched to **full numeric semver compare** (`_tad_ver_cmp`); newer-than-target → `current` | ✅ resolved (§9) |
| code-reviewer | **P2(critical)** harness would read the REAL `.tad/version.txt` if run in repo root | AC harness MUST run each case in `mktemp -d` isolated dir | ✅ §9.1 mandated |
| code-reviewer | P1 CRLF/trailing-whitespace breaks `current` equality | trim `\r\n` + space before compare; AC13 fixture | ✅ §9 + §9.1 |
| code-reviewer | P2 keep/remove `v2.0` arm | `detect_state` no longer emits `v2.0` → REMOVE the dead arm (grep-verified sole producer) | ✅ §9 |
| backend-architect | **P0** §1.3 premise wrong — engine runs on BOTH paths; AC7 cross-major→upgrade recreates the under-protection | Reframed rationale (accurate); cross-major (vmaj<tmaj, v2) → **migrate** (gets `.tad-migrate-backup`) | ✅ §1.3 + §9 + AC7 |
| backend-architect | P1 "engine handles the delta" overclaims (chain may not reach 2.0) | Softened claim; 2.0–2.18 stay same-major→upgrade (correct) | ✅ §9 notes |
| backend-architect | P2 downgrade prints misleading "latest"; legacy rescue no-ops on v2 tree | acceptable; documented (cosmetic) | accepted |

## 1.3 Intent
1. **Problem:** `detect_state()` in `tad.sh` routes by **string-prefix version globs** (`2.0*`/`2.1*`/`2.2*` → state `v2.0`). With `TARGET_VERSION="2.29.1"`, the `2.2*` arm now swallows every `2.20.x`–`2.29.x`. The defect is the **brittle glob routing**, which cannot distinguish *same-major* (plain upgrade) from *cross-major* (needs the migrate path's structural backup). Today it's latent (2.x→2.29.1 still gets `ACTION=upgrade`, which is acceptable since `call_migration_engine` runs on the upgrade path too). It bites at the **next major bump**: a modern `2.29.x` project upgrading to a `3.x` target would still match `2.2*` and route to `upgrade` — i.e. it would **forgo the `.tad-migrate-backup` structural backup** that the `migrate` path provides before a major-version migration.
2. **Accurate mechanics (per Gate-2 architect review):** `call_migration_engine "$SRC" "$CURRENT" "$TARGET"` is invoked on BOTH the upgrade and migrate handlers with identical args — so `ACTION=upgrade` does **not** skip the engine. What `ACTION=migrate` adds over `upgrade` is (a) a `.tad-migrate-backup` structural backup and (b) legacy v1.x-layout data rescue (`handoffs/`→`.tad/active/` etc.). The real win of this fix: route a cross-major jump to `migrate` so it gets the backup.
3. **Fix:** replace the glob ladder with **numeric semver comparison** so routing is correct for any future `TARGET_VERSION`, and route cross-major (installed major < target major, v2) to the migrate path.
4. **Success:** `2.29.0` → plain `upgrade`; `1.x` keep their existing granular routing; `2.30.0` (newer than a `2.29.1` target) → `current`/no-op (no accidental downgrade); `2.29.1` against a `3.0.0` target → `migrate` (gets the structural backup); behavior unchanged for every real downstream version under the current `TARGET=2.29.1`.

## 6 Scope (files)
- `tad.sh` — add a `_tad_ver_cmp` helper; rewrite the `version.txt` branch of `detect_state()` (≈ 872–895); ADD an `"upgrade")` arm and REMOVE the now-dead `"v2.0")` arm in `main()`'s `case $STATE` (≈ 951–985). Nothing else in tad.sh.
- NEW: `.tad/hooks/lib/detect-state-test.sh` — standalone isolated-tempdir fixture harness (see §9.1).
- **OUT OF SCOPE (DO NOT TOUCH):** anything under `.claude/skills/reading-companion/` (another Alex owns Phase 4). No other files.

## 9 Design
Add a pure-bash, BSD/macOS-safe semver comparator (NO `sort -V` — that's a GNU extension), then rewrite the version branch:

```sh
# numeric semver compare. echoes -1 if $1<$2, 0 if ==, 1 if $1>$2. Pure bash, BSD-safe.
_tad_ver_cmp() {
    [ "$1" = "$2" ] && { echo 0; return; }
    local IFS=.; local -a A=($1) B=($2); local i ai bi
    for i in 0 1 2; do
        ai="${A[i]:-0}"; bi="${B[i]:-0}"
        [[ "$ai" =~ ^[0-9]+$ ]] || ai=0
        [[ "$bi" =~ ^[0-9]+$ ]] || bi=0
        if [ "$ai" -gt "$bi" ]; then echo 1; return; fi
        if [ "$ai" -lt "$bi" ]; then echo -1; return; fi
    done
    echo 0
}

detect_state() {
    if [ ! -d ".tad" ] && [ ! -d ".claude/commands" ]; then
        echo "fresh"
    elif [ -f ".tad/version.txt" ]; then
        local ver; ver=$(cat .tad/version.txt)
        ver="${ver//[$'\r\n ']/}"               # CRLF/whitespace trim (safe equality)
        local tmaj="${TARGET_VERSION%%.*}"       # TARGET_VERSION is a trusted constant
        local vmaj="${ver%%.*}"
        if [ "$ver" = "$TARGET_VERSION" ]; then
            echo "current"
        elif ! [[ "$vmaj" =~ ^[0-9]+$ ]]; then
            echo "old"                            # unparseable → fail-safe to migrate path
        elif [ "$(_tad_ver_cmp "$ver" "$TARGET_VERSION")" = "1" ]; then
            echo "current"                        # installed NEWER than target → no-op (never downgrade)
        elif [ "$vmaj" -eq "$tmaj" ]; then
            echo "upgrade"                         # same major, older → plain upgrade
        else
            # installed major < target major → cross-major migration territory.
            case "$ver" in
                1.8*)        echo "v1.8" ;;        # preserve existing v1.x granular routing
                1.6*|1.5*)   echo "v1.6" ;;
                1.4*)        echo "v1.4" ;;
                *)           echo "old" ;;         # incl. v2-into-newer-major → migrate (gets .tad-migrate-backup)
            esac
        fi
    elif [ -d ".tad" ]; then
        echo "old"
    else
        echo "partial"
    fi
}
```

`main()` `case $STATE` changes:
- **ADD** an `"upgrade")` arm that prints `Status: Upgrade available` + the `Current → Target` line and sets `ACTION="upgrade"` (mirror the prior `"v2.0")` arm).
- **REMOVE** the `"v2.0")` arm — `detect_state` no longer emits `v2.0`. **Before removing, grep-verify** `detect_state` is the sole producer of the literal `v2.0` state and nothing else in `tad.sh` emits/compares it.
- Leave `fresh`/`current`/`v1.8`/`v1.6`/`v1.4`/`old`/`partial` arms unchanged.

### Why correct
- `2.29.0` vs `2.29.1`: same major, older → `upgrade`. (was misleading `v2.0`)
- `2.20.0`/`2.0.0` vs `2.29.1`: same major → `upgrade`. Engine runs on the upgrade path; 2.0–2.18 are same-major so the migrate path's v1-layout rescue is irrelevant — `upgrade` is correct. (Engine is *invoked*; if its manifest chain doesn't reach back that far it warns+skips — pre-existing, not introduced here.)
- `1.8.0`/`1.4.0`: unchanged granular v1 routing.
- `2.29.1` vs `3.0.0` target: cross-major → `old` → `ACTION=migrate` → **gets the `.tad-migrate-backup`** before the major migration. (The v1-layout rescue no-ops on a v2 tree — harmless.)
- `2.30.0` vs `2.29.1`: full compare → newer → `current` → no-op (never downgrades).
- empty/garbage `version.txt` → `old` → migrate (fail-safe superset path).

## 9.1 Acceptance Criteria (Blake MUST run — behavioral, not paper)
Create `.tad/hooks/lib/detect-state-test.sh`. It MUST, for each row, run in an **isolated `mktemp -d` dir** (create `.tad/version.txt` there, `cd` in) with `TARGET_VERSION` pinned per row, call `detect_state`, AND derive ACTION via the same `case $STATE` mapping. Extract `detect_state` + `_tad_ver_cmp` + the STATE→ACTION case from `tad.sh` (e.g. `source` a sub-shell that defines them, or `sed`-extract) — do NOT hand-reimplement the logic.

| AC | TARGET_VERSION | version.txt | Expect state | Expect ACTION |
|----|----------------|-------------|--------------|---------------|
| AC1 | 2.29.1 | 2.29.1 | current | none |
| AC2 | 2.29.1 | 2.29.0 | **upgrade** | upgrade |
| AC3 | 2.29.1 | 2.20.0 | upgrade | upgrade |
| AC4 | 2.29.1 | 2.0.0  | upgrade | upgrade |
| AC5 | 2.29.1 | 1.8.0  | v1.8 | upgrade |
| AC6 | 2.29.1 | 1.4.0  | v1.4 | migrate |
| AC7 | 3.0.0  | 2.29.1 | old | **migrate** |
| AC8 | 2.29.1 | (empty file) | old | migrate |
| AC9 | 2.29.1 | `garbage` | old | migrate |
| AC10 | 2.29.1 | 2.30.0 | **current** | none |
| AC11 | 2.29.1 | 2.9.0 (same major, < target) | upgrade | upgrade |
| AC13 | 2.29.1 | `2.29.1\r\n` (CRLF) | current | none |

- Harness exits 0 only if all rows pass; prints `TALLY: PASS=n FAIL=0`.
- AC-syntax: `bash -n tad.sh` passes.
- AC-deadcode: `grep -n '"v2.0")' tad.sh` returns nothing after the edit; `grep -c 'echo "v2.0"' tad.sh` == 0.
- AC-scope: `git status --porcelain` shows ONLY `tad.sh` + `.tad/hooks/lib/detect-state-test.sh`; nothing under `reading-companion/`.

## 10 Notes
- Pure bash; macOS/BSD safe. The numeric guard (`[[ =~ ^[0-9]+$ ]]`) prevents arithmetic errors on garbage.
- `TARGET_VERSION` is a trusted in-repo constant; `tmaj` is not separately guarded by design (document with a comment).
- Express tier: skip e2e; Gate 3 needs ≥1 independent reviewer (code-reviewer) on the diff + the AC-harness output (actual run, not claimed).
