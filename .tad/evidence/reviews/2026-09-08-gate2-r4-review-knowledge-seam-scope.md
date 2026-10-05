---
gate: 2
round: 4
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
handoff_status: Ready-for-Gate2-Round4
design: .tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md
prior_round3_scope: .tad/evidence/reviews/2026-09-08-gate2-r3-review-knowledge-seam-scope.md
reviewer: Independent Gate 2 Round4 scope reviewer (not the handoff author)
date: 2026-09-08
channel: opencode
model: opencode-go/muse-spark-1.3-contributor
scope: R3-NEW-P0-1 closure confirmation, prior-P0 stays-closed, R3-P1/P2 incorporation, new-P0 scan
counts: {P0_closed: 8, P0_new: 0, P1: 0, P2: 1}
verdict: PASS
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only, no auto quarantine on update"]
---

# Gate 2 Round4 Independent Scope Review — HANDOFF-20260908-knowledge-seam-isolation

## Independence & method

- Independent reviewer; no handoff authorship. Read-only review except writing this file. No implementation.
- Read: handoff (382 lines, full), design note (220 lines, full), Round3 scope review (FAIL, 1 NEW-P0 + 1 P1 + 2 P2).
- Executed (all read-only except mktemp copies under /tmp, auto-removed):
  - `grep -n "^main$" tad.sh` → single hit L2954 (sed filter is surgical, no collateral).
  - Main-free loader reachability: `sed '/^main$/d'` copy + `source "$0"` → `PROBE-RAN` prints (probe executes; the R3 defect is gone).
  - AC1.4 baseline discrimination on live tree: full conjunction exits **1** (`brain-index.md` matched → leak detected → fails-cleanly, correct pre-impl behavior).
  - AC1.4 simulated-GOOD (stubbed denyпористая fn emitting only clean names): exits **0** (a correct Blake implementation will PASS).
  - Full `derive_framework_top_files .` output inspected: contains `brain-index.md` (leak, pre-impl) AND `version.txt` (sibling-pin target present) — both halves of the probe assert against real rows.
  - AC8.1: `grep -c quarantine tad.sh` → 0 (update path has zero quarantine calls, pre-impl negative holds).
  - AC8.3: `ls .tad/project-knowledge/framework-principles.md` → No such file (Option A negative holds).
  - Text checks: AC1.4 loader verbatim (L302), AC5.1 c1/c2/c3 variants (L311), AC2.1 `grep -vx` anchor (L304), AC6.2 `.bak` backup/restore (L313).
- Human locks respected as constraints, not re-opened: ①A pure isolation, ②quarantine opt-in only. No redesign proposed.

## Gate 2 checklist mapping (canonical)

| Item | Status | Note |
|------|--------|------|
| Expert review complete (min 2) | ⚠️ Partial | Round1 had 2 (scope + spec). This is Round4 scope PASS; a spec re-review of the amended AC1.4/AC5.1/AC2.1/AC6.2 text is still needed before Blake start |
| All P0 resolved | ✅ Pass | All 8 P0 CLOSED (6 Round1 + R2 NEW-P0-1 + R3-NEW-P0-1), 0 new P0 |
| Architecture complete | ✅ Pass | Design §3.1–3.4 intact; locks preserved |
| Components specified | ✅ Pass | §1 Target Files enumerates 11 files incl. both trees + CLI + tad-maintain |
| Functions verified | ✅ Pass | R3-NEW-P0-1 CLOSED: AC1.4 probe executes and discriminates (see below) |
| Data flow mapped | ✅ Pass | Unchanged |

## R3-NEW-P0-1 closure — CLOSED ✅

- **R3 claim**: §9.1 AC1.4 `bash -c 'source tad.sh …'` executed bare `main` (L2954, no `BASH_SOURCE` guard), exited 0 without ever running the probe — always-green on a leaking tree.
- **Fix in handoff (§9.1 AC1.4, L302)**: main-free loader applied verbatim —
  `TMPF=$(mktemp) && sed '/^main$/d' tad.sh > "$TMPF" && bash -c 'source "$0" >/dev/null 2>&1; derive_framework_top_files . | { grep -Fx "brain-index.md" && exit 1 || true; } && derive_framework_top_files . | { grep -Fx "sync-registry.yaml" && exit 1 || true; } && derive_framework_top_files . | grep -Fxq "version.txt"' "$TMPF"; RC=$?; rm -f "$TMPF"; exit $RC`.
  Audit-trail row added (§9.1-Round-3 table, L364) with live-tested claim.
- **Evidence (executed live)**:
  - `sed '/^main$/d'` copy + source → `PROBE-RAN` prints: the probe now executes (R3's absent-`PROBE-RAN` defect gone). Filter safety: `^main$` matches exactly one line (L2954).
  - Baseline full conjunction → exit **1** with `brain-index.md` echoed by the matcher: fails-cleanly on the leaking tree, proving the AC checks something (GOOD-must-pass / BAD-must-fail-cleanly discipline satisfied).
  - Simulated GOOD (clean stub fn) → exit **0**: post-impl PASS is reachable.
  - `version.txt` confirmed present in live `derive_framework_top_files .` output, so the include-pin is a live assertion, not a vacuous match against an absent row.
- **Status: CLOSED.** The prescribed fix was applied verbatim and discriminates correctly (BAD-at-baseline fails with leak detected, GOOD passes). No `BASH_SOURCE`-guard scope creep added to `tad.sh` — fix stays in AC text per R3 instruction. ✅

## Prior P0 stay CLOSED (all 7 — spot re-verified, no regressions)

| # | Prior P0 | Re-check | Status |
|---|----------|----------|--------|
| 1 | Scope P0-1: AC1 vacuous | AC1.1–1.3 representation + sibling-pin rows intact (L299–301); AC1.4 now executable (see above) | **CLOSED** |
| 2 | Scope P0-2 / Spec P0-2: scalar-equality trap | Multiline deny + `printf … \| grep -Fxq` consumer + comment fix intact (L99–115, L300–301); live baseline still scalar (`tad.sh:566/599`) so fix targets real code | **CLOSED** |
| 3 | Scope P0-3 / Spec P0-3: quarantine clobbers README | NEVER-move-README + strict scope + AC4.3 intact (L191–214, L227–231, L309) | **CLOSED** |
| 4 | Spec P0-1: missing §9.1 | Full 6-column §9.1 table present, AC1.1–AC8.3 (L297–317) | **CLOSED** |
| 5 | Spec P0-4: no CLI wiring | Parser + `show_help` + dispatch + AC4.1/4.2/4.4 intact (L153–161, L307–310) | **CLOSED** |
| 6 | Spec P0-5: missing evidence manifest | §7 YAML manifest with 2 files + required_sections intact (L265–281) | **CLOSED** |
| 7 | Scope R2 NEW-P0-1: AC6.1 range collapse | Stateful-awk form intact in AC6.1, mirrored both trees (L312); closed in R3 and untouched since | **CLOSED** |

Human-lock preservation: Option A + opt-in encoded in §1 Out of Scope (L53–55), Forbidden (L56–61), §4 AC8 (L236–239), §9.1 AC8.1–8.3 (L315–317; AC8.1/8.3 live-verified empty pre-impl), §6 Decision Log (L257–259). No lock re-opened. ✅

## R3 P1/P2 incorporation — all CLOSED ✅

| # | R3 finding | Resolution in amended handoff | Status |
|---|-----------|-------------------------------|--------|
| R3 P1-1 | AC5.1 fixture covers only bare YAML form | Fixture now creates `c1` (bare), `c2` (single-quoted), `c3` (double-quoted) + `local/keep.txt`, asserts all four survive re-sync (L311) | **CLOSED** |
| R3 P2-1 | AC2.1 unanchored `grep -v 'README.md'` | Anchored `grep -vx 'README.md'` (L304); audit row L366 | **CLOSED** |
| R3 P2-2 | AC6.2 mutates live brain-index.md | Wrapped with `cp -p … .bak` + `mv -f … .bak …` restore around the staleness probe, `;`-chained so restore runs regardless (L313); audit row L367 | **CLOSED** |

## NEW P0 scan — none found ✅

- AC1.4 loader shape audited token-by-token: `source "$0"` receives `"$TMPF"` as `$0` (correct); `RC=$?; rm -f "$TMPF"; exit $RC` propagates the conjunction status and cleans the temp copy; `{ grep … && exit 1 || true; }` idiom preserves `set`-safety while inverting match → failure. `derive_framework_top_files .` resolves ` ./.tad/*` from repo root, the documented Gate 3 cwd. No vacuity, no uncontrolled execution (filtered copy never runs `main`), no installer-behavior creep.
- AC2.1/AC4.3/AC4.4/AC5.1/AC6.2 commands are literal, temp-dir isolated (except AC6.2's intentional live-file probe, now backup-guarded), with explicit expected evidence. No always-green / always-red construction detected.
- Negative invariants AC8.1–8.3 remain absence-proofs with live-verified pre-impl baselines; §3 Task 1 still mandates only TOP_DENY + consumer + comment (no guard creep).

## P1 findings — none

## P2 nits (non-blocking, Blake/Gate 3 may accept as-is)

- **P2-1:** AC4.3/AC4.4 reference `"$OLDPWD"` for the source tree. In a freshly spawned non-interactive Gate 3 shell `OLDPWD` may be unset (expands empty unless `set -u`, yielding a wrong `--quarantine-pk` path, not a crash). Consider `SRC="$PWD"` captured before `cd`, or absolute source path. Fixture-controlled, negligible — not a scope defect.

## No-Gate-hard-journal check — PASS (unchanged)

- Forbidden (L57–58) still bans per-ticket journal and `brain-index.md` freshness as Gate 3/4 PASS requirements; §9.1 AC8.2 + Task 3 WARN-only freshness (L145–149) keep triggers soft. Aligns with L1 "Knowledge Is Forged at Distill" and design §3.4.

## Verdict

- **VERDICT: PASS** — R3-NEW-P0-1 CLOSED (AC1.4 main-free loader executes and discriminates: baseline exit 1 leak-detected, simulated-GOOD exit 0), all 7 prior P0 stay CLOSED, all R3 P1/P2 incorporated, 0 new P0, both human locks intact.
- **Next:** request the spec re-review of the amended handoff (canonical min-2 rule) before flipping to Blake start. Scope side imposes no further handoff-text changes.
- **Explicit non-reopen:** Option A pure isolation + quarantine opt-in-only confirmed correctly encoded. Do not relitigate.
