---
gate: 2
round: 3
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
handoff_status: Ready-for-Gate2-Round3
design: .tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md
prior_round2_scope: .tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-scope.md
reviewer: Independent Gate 2 Round3 scope reviewer (not the handoff author)
date: 2026-09-08
channel: opencode
model: opencode-go/muse-spark-1.3-contributor
scope: NEW-P0-1 closure confirmation, prior-P0 stays-closed, R2-P1/P2 incorporation, new-P0 scan
counts: {P0_closed: 7, P0_new: 1, P1: 1, P2: 2}
verdict: FAIL
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only, no auto quarantine on update"]
---

# Gate 2 Round3 Independent Scope Review — HANDOFF-20260908-knowledge-seam-isolation

## Independence & method

- Independent reviewer; no handoff authorship. Read-only review except writing this file. No implementation.
- Read: handoff (373 lines, full), design note (220 lines, full), `principles.md` (L1, full),
  `patterns/_index.md` + three pattern files (`ac-verification.md`, `gate-design.md`,
  `shell-portability.md`), Round2 scope review (FAIL, 1 NEW-P0 + 3 P1 + 2 P2).
- Executed (all read-only except one guarded `/tmp` redirect + one `head` read):
  AC6.1 stateful-awk baseline + simulated-GOOD runs, old-form collapse check,
  AC3.2 ERE discrimination probes (GOOD/BAD/see-file), `tad.sh` source-behavior probes
  (`echo PROBE-RAN` reachability, `tail`/exit scan), AC8.1–8.3 negative assertions live,
  AC1.1/1.2 baselines, `sed '/^main$/d'` filtered-source mechanism check.
- Human locks respected as constraints, not re-opened: ①A pure isolation, ②quarantine
  opt-in only. Findings tighten handoff text only; no redesign proposed.

## Gate 2 checklist mapping (canonical)

| Item | Status | Note |
|------|--------|------|
| Expert review complete (min 2) | ⚠️ Partial | Round1 had 2 (scope + spec). This is Round3 scope; a spec re-review is still needed before Blake start |
| All P0 resolved | ❌ Fail | All 7 prior P0 CLOSED (6 Round1 + R2 NEW-P0-1), but 1 NEW P0 open (R3-NEW-P0-1, AC1.4 vacuous) |
| Architecture complete | ✅ Pass | Design §3.1–3.4 intact; locks preserved |
| Components specified | ✅ Pass | §1 Target Files enumerates 11 files incl. both trees + CLI + tad-maintain |
| Functions verified | ❌ Fail | R3-NEW-P0-1: AC1.4 probe never executes (see below) |
| Data flow mapped | ✅ Pass | Unchanged |

## R2 NEW-P0-1 closure — CLOSED ✅

- **Claim**: §9.1 AC6.1 now uses `awk 'f&&/^## /{exit} /^## Step 6: Finalize/{f=1;next} f'`
  mirrored across both trees (handoff L312).
- **Evidence (executed live)**:
  - Baseline: stateful awk on both live protocol files → no match (exit 1) — fails-cleanly
    pre-impl, correct (trigger not yet implemented; `grep -n brain-index` on both files = 0 hits).
  - Simulated GOOD insertion (heading + trigger line + next heading) → `grep -F` MATCHes —
    a correct Blake implementation will PASS.
  - Old form `awk '/## Step 6: Finalize/,/## [A-Z0-9]/'` → 1 line (heading only),
    confirming the R2 diagnosis was real and this fix addresses exactly it.
- **Status: CLOSED.** The prescribed one-line fix was applied verbatim and discriminates
  correctly (BAD-at-baseline fails, GOOD passes).

## Prior P0 stay CLOSED (all 6 — spot re-verified, no regressions)

| # | Prior P0 | Re-check | Status |
|---|----------|----------|--------|
| 1 | Scope P0-1: AC1 vacuous | §9.1 AC1.1–1.3 representation + sibling-pin rows intact (L299–301); AC1.1/1.2 baselines live-verified 0 hits (greenfield) | **CLOSED** (but see R3-NEW-P0-1 on AC1.4) |
| 2 | Scope P0-2 / Spec P0-2: scalar-equality trap | Multiline deny + `printf … \| grep -Fxq` consumer + comment fix intact (L99–115, L300–301); live baseline still shows scalar trap (`tad.sh:566/599`-era, extracted fn L~2595 `[ "$bn" = "$TAD_TOP_DENY" ]`) so the fix targets real code | **CLOSED** |
| 3 | Scope P0-3 / Spec P0-3: quarantine clobbers README | NEVER-move-README + strict scope + AC4.3 intact (L191–214, L227–231, L309) | **CLOSED** |
| 4 | Spec P0-1: missing §9.1 | Full 6-column §9.1 table present, AC1.1–AC8.3 (L297–317) | **CLOSED** |
| 5 | Spec P0-4: no CLI wiring | Parser + `show_help` + dispatch + AC4.1/4.2/4.4 intact (L153–161, L307–310) | **CLOSED** |
| 6 | Spec P0-5: missing evidence manifest | §7 YAML manifest with 2 files + required_sections intact (L265–281) | **CLOSED** |

Human-lock preservation: Option A + opt-in encoded in §1 Out of Scope (L53–55),
Forbidden (L56–61), §4 AC8 (L236–239), §9.1 AC8.1–8.3 (L315–317, live-verified empty),
§6 Decision Log (L257–259). No lock re-opened. ✅

## R2 P1/P2 incorporation — all CLOSED ✅

| # | R2 finding | Resolution in amended handoff | Status |
|---|-----------|-------------------------------|--------|
| R2 P1-1 | AC3.2 BRE `\|` + missing content assertion | Count is now `grep -c "HANDOFF-"`; content assertion `grep -qE '\|\s*\||\(see file\)'` added (L306). Live discrimination: GOOD→no-match, empty-cell→MATCH, `(see file)`→MATCH — all three correct on this host | **CLOSED** |
| R2 P1-2 | AC4.3/AC6.2 prose methods | AC4.3, AC4.4, AC5.1, AC6.2 are now literal runnable commands (L309–313) | **CLOSED** |
| R2 P1-3 | Task 2 line drift + L228 | Re-pinned (L94/L135/L155/L172/L174/L177/L212/L251) with L228 config site explicitly wrapped (L124–134) | **CLOSED** |
| R2 P2-1 | "7 sites" vs 8 bullets | Reworded "7 handoff/doc grep sites + 1 find-precedence fix + 1 config grep site" (L124) | **CLOSED** |
| R2 P2-2 | README create-only-if-absent | Retained; acceptable for framework-owned seed, no action | **CLOSED** |

## NEW P0 findings (blocking — handoff-text fix, then Round4)

### R3-NEW-P0-1 — §9.1 AC1.4 is vacuous: `source tad.sh` executes `main` and never reaches the probe

- **Claim in handoff (§9.1 AC1.4):**
  `bash -c 'source tad.sh >/dev/null 2>&1; derive_framework_top_files . | { grep -Fx "brain-index.md" && exit 1 || true; } && …'` → Expected "Exit code 0".
- **Evidence (executed on live host, read-only):**
  - `bash -c 'source tad.sh >/dev/null 2>&1; echo PROBE-RAN'` → prints NOTHING, outer exit 0.
    The probe never runs; the AC exits 0 without executing a single check.
  - Root cause: `tad.sh` ends with a bare `main` call (L2954, no `BASH_SOURCE` guard —
    unlike `migration-engine.sh`, whose guard the repo itself documents at `tad.sh:1589`).
    Sourcing runs the full `main` (observed: banner, env validation, "Already v2.44.3"),
    which exits before the sourcing shell ever returns. Captured source output proves
    `main` ran; the absent `PROBE-RAN` proves nothing after `source` executed.
  - This is the exact failure class Round1 Scope P0-1 closed ("AC1 verification is vacuous"):
    AC1.4 PASSes on a leaking implementation — Gate 3 would certify a `brain-index.md`
    leak as clean. Always-green is validation theater (`ac-verification.md` 2026-07-13 entry:
    a post-impl AC that passes-trivially on the unmodified repo is broken by construction).
  - Secondary hazard: as a Gate 3 method, `source tad.sh` performs uncontrolled execution
    (full `main` — benign read-only from repo root today, but installer-adjacent in other
    cwds), not a pure function probe.
  - Blake-side incidental fix is impossible: §3 Task 1 mandates only TOP_DENY + consumer +
    comment changes, no `BASH_SOURCE` guard, so post-impl `source` still exits early.
- **Required fix (handoff-text only):** load the function without executing `main`.
  Verified mechanism on this host: `sed '/^main$/d'` a copy, then source the filtered copy —
  `PROBE-RAN` prints and the probe correctly reports `LEAKS` at baseline (discriminating).
  Suggested AC1.4 method shape (Alex to word precisely):
  `TMPF=$(mktemp) && sed '/^main$/d' tad.sh > "$TMPF" && bash -c 'source "$0" >/dev/null 2>&1; derive_framework_top_files . | …' "$TMPF"; RC=$?; rm -f "$TMPF"; exit $RC`
  (or any equivalent main-free loader). Dry-run post-fix: must FAIL-cleanly at baseline
  (leak detected — proves it checks something) and PASS post-impl.
  Do NOT "fix" by adding a `BASH_SOURCE` guard to `tad.sh` inside this handoff — that is
  installer-behavior scope creep beyond the locked mandate; keep the fix in the AC text.

## P1 findings (advisory — fix alongside R3-NEW-P0-1)

### P1-1 — AC5.1 fixture covers only the bare `ownership: project-owned` form

- §3 Task 4 mandates the regex cover bare, single-quoted, and double-quoted YAML forms;
  the AC5.1 fixture only installs the bare form. The preservation mechanism is proven
  end-to-end, but the quoting-variant half of the mandate has zero executable coverage.
  Add two sibling skills to the fixture (single-quoted + double-quoted frontmatter) and
  assert both survive re-sync. (Mechanism-green/variant-uncovered — P1, not P0.)

## P2 nits

- **P2-1:** AC2.1 uses unanchored `grep -v 'README.md'` (also filters `README.md.bak`-style
  names). Anchor (`grep -vx 'README.md'`) or accept as-is; fixture-controlled, negligible.
- **P2-2:** AC6.2 `touch -t 202001010000 .tad/brain-index.md` mutates the LIVE workspace file
  and relies on regen to restore it; if regen output differs from committed bytes the tree is
  left dirty by a "verification" step. Back up and restore the file around the staleness
  probe (or run the touch-fixture against a temp copy of the doctor logic).

## No-Gate-hard-journal check — PASS (unchanged)

- Forbidden (L57–58) still bans per-ticket journal and `brain-index.md` freshness as
  Gate 3/4 PASS requirements; §9.1 AC8.2 + Task 3 WARN-only freshness (L145–149)
  keep triggers soft. Aligns with L1 "Knowledge Is Forged at Distill" and design §3.4.

## Verdict

- **VERDICT: FAIL** — all 7 prior P0 CLOSED (6 Round1 + R2 NEW-P0-1) and both human locks
  intact, but **1 new P0 (R3-NEW-P0-1)** blocks: §9.1 AC1.4 as written exits 0 without
  ever running its probe, so the headline deny-list behavioral guarantee is uncertified.
- **To pass re-review (Round4):** apply the R3-NEW-P0-1 main-free loader fix (+ P1-1
  quoting-variant fixtures), dry-run every touched AC command on this host per the
  GOOD-must-pass / BAD-must-fail-cleanly discipline, then request the spec re-review
  (canonical min-2 rule) before flipping to Blake start.
- **Explicit non-reopen:** Option A pure isolation + quarantine opt-in-only confirmed
  correctly encoded. Do not relitigate.
