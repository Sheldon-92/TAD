---
gate: 3
handoff: HANDOFF-20260908-knowledge-seam-isolation.md
reviewer: Layer 2 Group 1 code-reviewer (independent, non-author)
verdict: PASS
p0_count: 0
p1_count: 0
p2_count: 5
date: 2026-09-09
scope_files:
  - tad.sh
  - .tad/hooks/lib/quarantine-framework-pk.sh
  - .tad/hooks/lib/brain-index-gen.sh
  - .tad/hooks/lib/derive-sync-set.sh
  - .agents/skills/alex/references/distillation-loop-protocol.md
  - .agents/skills/alex/references/acceptance-protocol.md
  - .agents/skills/tad-maintain/SKILL.md
  - .tad/project-knowledge/README.md
  - (.claude mirror copies of the three skill files)
---

# Gate 3 Layer 2 Code Review — Knowledge-Seam Isolation

## 1. Method (read-only; implementation untouched)

- Reviewed via `git diff` only (plus the untracked NEW file
  `.tad/hooks/lib/quarantine-framework-pk.sh`). `bash -n` syntax-clean on all
  four shell files. No implementation file was modified; the only write is
  this report.
- Executed behavior proofs in `/tmp` sandboxes (never in-repo, so the
  read-only rule and the generated `.tad/brain-index.md` were never touched):
  - Quarantine script against copies of real framework pk files (5/5 sampled
    manifest hashes match this repo's files byte-for-byte, so the fixture is
    faithful): quarantine path, rerun idempotency, clean-tree no-op (no
    archive dir created), missing-pk target — all exit 0 with correct
    file disposition and MANIFEST schema.
  - `brain-index-gen.sh` NEW vs `git show HEAD:` ORIG on a heading-less
    fixture: ORIG dies mid-run (truncated index), NEW completes; exit 0 on a
    full tree.
  - `tad_doctor` extracted verbatim with stub log fns: stale path warns,
    fresh path confirms, both exit 0.
  - Ownership regex extracted verbatim: 10-case accept/reject matrix correct.
  - TOP_DENY consumer: match-skip / no-match-emit correct; dash-leading
    basename probed (see P2-1).

## 2. Lock-decision conformance (all HOLD)

- **Option A pure isolation**: install seeds pk with README-only `cp`
  (tad.sh ~2738) + empty `patterns/` + `incidents/`; `project-knowledge` is in
  `TAD_ZERO_TOUCH` (tad.sh:553) so `copy_framework_files` structurally cannot
  copy it. Upgrade/migrate install the README seed only under `[ ! -f ]`
  (~2843, ~2927). Verified in diff + file.
- **Quarantine opt-in only**: the string `quarantine` occurs in tad.sh only at
  328/331 (parser dispatch) and 374 (help). Zero occurrences in `main()` body
  onward (checked via `awk '/^main\(\)/,0'`), i.e. no auto-quarantine in any
  install/upgrade/migrate/update path. Dispatch (`exec bash
  "$_qp_self_dir/..." "$@"`) and `--doctor` both run pre-trap (trap armed at
  ~2178; dispatch ~328, doctor exit ~2119) — consistent with the existing
  `--verify-denylist` pre-trap pattern.
- **Non-blocking refresh everywhere**: all brain-index refresh call-sites
  (distillation Step 6, acceptance step4f, tad-maintain SYNC/FULL,
  post-quarantine rebuild) are `... >/dev/null 2>&1 || true`; doctor is
  WARN-only with unconditional `return 0` / `exit 0` (execution-proven).
- **Sync-set exclusion complete**: `brain-index.md` added to TOP_DENY in both
  copies (tad.sh:575, derive-sync-set.sh:77 — byte-consistent multiline
  values); the set-membership consumer (`printf | grep -Fxq`, tad.sh:610) is
  used by both call-sites (1123, 1484). No stray `cp ... brain-index.md` or
  `sync-registry.yaml`-only singleton remains (`rg` clean).

## 3. Per-item checks

1. **tad.sh TOP_DENY + consumer**: multiline value correct; `grep -Fxq` is
   exact-line (no regex-injection from data). Under `set -e` the
   `grep ... && continue` AND-list is safe (failure path is shielded).
   Glob without nullglob is safe (`[ -f ] || continue`). See P2-1 (missing
   `-e`/`--`) and P2-2 (drift-check gap).
2. **`--quarantine-pk` dispatch**: script-dir resolution matches the repo's
   existing `self_dir` idiom (cf. `verify_denylist_drift`); `"$@"` forwarding
   is `set -u`-safe (plain `"$@"` with zero args is exempt in all bash
   versions, incl. 3.2); `TARGET="${1:-$PWD}"` in the callee is the correct
   `-u`-safe default idiom. Extra args beyond target-root are silently
   ignored — acceptable. Help entry present (see P2-5 nit).
3. **`tad_doctor`**: WARN-only, exit 0 on all three branches (proven). See
   P2-3 (`-quit` portability).
4. **Skill copy loops (both)**: `skill_name`/`skill_name_b` assigned before
   guards; `[ -e ]` existence test gives exactly "fresh seed installed,
   existing preserved"; ownership regex construction `["'"'"']?` compiles to
   `["']?` (verified via `cat -A` + 10-case matrix: bare/indented/
   single-/double-quoted match; commented, prefixed-key, `project-forked`
   correctly rejected). `grep -qE` in AND-list after `[ -f ]` is `set -e`-safe.
5. **Quarantine script**: portable hash with `command -v` probe (no `|&`, no
   assoc arrays — bash 3.2 clean); strict pk-only scope (`find "$PK_DIR"
   -type f`, prefix-strip `rel`, no `..` traversable from find output);
   top-level `README.md` exclusion exact; lazy archive creation
   (execution-proven: clean tree creates no dir); MANIFEST header + row schema
   correct; post-quarantine rebuild guarded by `-f` + `|| true`. See P2-4
   (robustness edges).
6. **brain-index-gen.sh**: all 8 grep-in-`$()` sites wrapped (`rg` confirms no
   unwrapped site remains); the `{ grep || true; }` group additionally
   neutralizes SIGPIPE/pipefail from downstream `head -1/-5` (group exits 0).
   Execution-proven: ORIG truncates on heading-less input (the exact crash
   class), NEW completes. Find-parens fix in the archive section is
   precedence-hygiene (no behavior change — no sibling predicates). All
   patterns are `^`-anchored literals (no dash-leading/ugrep hazard).
   `task_type="${task_type:-unknown}"` is `set -u`-safe. (Note: brief says "9
   wraps"; file contains 8, all sites covered — no action.)
7. **derive-sync-set.sh**: TOP_DENY multiline byte-matches tad.sh. `--report`
   line 123 embeds the multiline var inside one `echo` (cosmetic two-line
   render, pre-existing format) — no action.
8. **Markdown insertions**: distillation Step 6 block sits before `## Step 7`
   with closed fence; acceptance step4f lines sit inside the `action: |`
   literal block at content indentation (6/8sp vs 2sp keys — YAML-safe,
   `step5:` alignment intact); tad-maintain Step 1.6 sits before `## Step 2`.
   Frontmatter: acceptance/distillation files have none (heading-led, untouched
   by construction); tad-maintain frontmatter (lines 1–4) is far from the
   insertion and is three plain `key: value` scalars (no pyyaml/ruby on host
   to machine-parse; structure is trivially valid and byte-identical to HEAD
   outside the insertion). `.agents` ↔ `.claude` parity confirmed
   (brain-index-gen.sh cited 1×/1×/2× in both trees).

## 4. Findings

### P0 — 0 (none)

### P1 — 0 (none)

### P2-1: `derive_framework_top_files` lacks `-e`/`--` on data-driven grep
`tad.sh:610`: `printf ... | grep -Fxq "$bn"`. A top-level basename starting
with `-` (e.g. `-e`) is parsed as an option → exit 2 → `&& continue` fails →
file is emitted (fail-open to sync). No such file exists; framework top-level
names are controlled. Fix: `grep -Fxq -e "$bn"`.

### P2-2: `--verify-denylist` does not cover TOP_DENY
The drift-check asserts DENY_LIST only; the diff doubles the TOP_DENY sync
surface (1→2 entries × 2 files) with no mechanical guard against future
one-copy divergence — the exact "stale-list disease" the check exists to kill.
Help text remains accurate (claims DENY_LIST only). Consider extending the
check or documenting TOP_DENY as manually synced.

### P2-3: non-POSIX `find -quit` in WARN-only freshness checks
`tad_doctor` (tad.sh:2105) and the tad-maintain Step 1.6 doc snippet use
`-print -quit`. If a host `find` rejects `-quit`, stderr is suppressed and the
advisory silently reports "fresh" — benign (WARN-only, never gates) but the
freshness signal is lost. Consider dropping `-quit` (pk tree is small).

### P2-4: quarantine-script robustness edges (all unlikely, none blocking)
(i) host with neither `sha256sum` nor `shasum` → `set -e` exit mid-loop,
non-zero (fails before any `mv`, so no partial state, but `exit 0` contract
broken); (ii) `mv` failure (perms) → partial quarantine + non-zero exit;
(iii) same-second rerun reuses timestamped dir and `>`-truncates the prior
MANIFEST; (iv) newline-containing filenames break the `read` loop and the
pipe-delimited MANIFEST row. Suggest: preflight hash tool, `mv ... || exit`
with explicit message, `>>`-with-exists-guard or unique-suffix loop for the
manifest.

### P2-5 (nit): `--help` Usage synopsis omits the new flags
`--quarantine-pk` / `--doctor` are listed in the option block (~374) but not
in the `Usage:` synopsis lines (~360), unlike peer standalone modes
(`--fork-pack` etc.). One-line doc touch.

## 5. Out-of-scope note (no severity, no action)
Adjacent pre-existing `sed … | head -1 | …` fallbacks in brain-index-gen.sh
(not in `$()`-grep form, untouched by this diff) retain the theoretical
SIGPIPE-under-pipefail shape; residual exit-1 observed in a minimal sandbox
traces to `find` on absent optional dirs (missing-dir artifact), identical in
ORIG. In-repo full tree exits 0. Not counted.

## VERDICT: PASS (P0: 0, P1: 0, P2: 5)
