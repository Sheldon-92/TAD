---
gate: 2
round: 4
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
handoff_status: Ready-for-Gate2-Round4
design: .tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md
prior_reviews:
  r1_spec: .tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-spec.md
  r1_scope: .tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-scope.md
  r2_spec: .tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-spec.md
  r2_scope: .tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-scope.md
  r3_spec: .tad/evidence/reviews/2026-09-08-gate2-r3-review-knowledge-seam-spec.md
  r3_scope: .tad/evidence/reviews/2026-09-08-gate2-r3-review-knowledge-seam-scope.md
  r4_scope: .tad/evidence/reviews/2026-09-08-gate2-r4-review-knowledge-seam-scope.md
reviewer: Reviewer 2 — Spec & Architecture Reviewer (independent, Cursor)
date: 2026-09-08
channel: cursor
model: gemini-3.8-flash-medium
scope: Round 4 re-review: verification of R3-NEW-P0-1 closure in AC1.4 main-free loader, prior P0 stays-closed, R3-P1/P2 resolution, zero new P0s, human locks preservation, Gate 2 pass/fail verdict
counts: {P0: 0, P1: 0, P2: 1}
verdict: PASS
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only (tad.sh --quarantine-pk; no auto on update)"]
---

harness=Cursor | model=gemini-3.8-flash-medium | route=native

# Gate 2 Round 4 Independent Spec & Architecture Review — HANDOFF-20260908-knowledge-seam-isolation

## 1. Independence & Method

- **Role**: Independent Gate 2 Spec & Architecture Reviewer (Round 4 re-review). Not the handoff author (Alex).
- **Execution Discipline**: Strict read-only evaluation. No implementation code modified or written. Blake has not been dispatched. Only this review evidence file is created.
- **Artifacts Inspected**:
  - Handoff under review: `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md` (382 lines, status `Ready-for-Gate2-Round4`).
  - Design Document: `.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`.
  - Prior Reviews:
    - Round 1 Spec Review: `.tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-spec.md` (FAIL: 5 P0s).
    - Round 1 Scope Review: `.tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-scope.md` (FAIL: 3 P0s).
    - Round 2 Scope Review: `.tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-scope.md` (FAIL: 1 NEW-P0, 3 P1s).
    - Round 2 Spec Review: `.tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-spec.md` (PASS).
    - Round 3 Scope Review: `.tad/evidence/reviews/2026-09-08-gate2-r3-review-knowledge-seam-scope.md` (FAIL: R3-NEW-P0-1, 1 P1, 2 P2s).
    - Round 3 Spec Review: `.tad/evidence/reviews/2026-09-08-gate2-r3-review-knowledge-seam-spec.md` (PASS).
    - Round 4 Scope Review: `.tad/evidence/reviews/2026-09-08-gate2-r4-review-knowledge-seam-scope.md` (PASS).
  - Upstream Code & Target Locations:
    - `tad.sh` (`main` entrypoint at line 2954; `TAD_TOP_DENY` L566; `derive_framework_top_files` L592–603; CLI option parsing L320–375; `copy_framework_files` L1149–1180 & L1250–1280; installer/updater routines L2655–2860).
    - `.tad/hooks/lib/derive-sync-set.sh` (`TOP_DENY` L77).
    - `.tad/hooks/lib/brain-index-gen.sh` (census of 7 pipefail grep sites, find precedence at L172, config grep at L228).
    - Dual Protocol Trees: `.claude/skills/alex/references/` and `.agents/skills/alex/references/` (`distillation-loop-protocol.md`, `acceptance-protocol.md`).
    - Grounding Principles: `principles.md:74`, `principles.md:94`, `principles.md:110`, `patterns/shell-portability.md`, `patterns/ac-verification.md`, `patterns/release-sync.md`.
- **Locked Human Constraints**:
  - ① Project knowledge baseline: **Option A — Pure Isolation** (new installs receive only `.tad/project-knowledge/README.md`; empty `patterns/` and `incidents/` subdirectories; no framework principles/incidents).
  - ② Quarantine invocation: **Opt-in only via `tad.sh --quarantine-pk`** (no automatic quarantine during `tad.sh update`).

---

## 2. Gate 2 Canonical Checklist Assessment

| Item | Status | Note |
|---|---|---|
| **Expert review complete (min 2)** | ✅ Pass | Round 4 Scope Reviewer issued **PASS** (`2026-09-08-gate2-r4-review-knowledge-seam-scope.md`). This Round 4 Spec Review satisfies the canonical min-2 independent reviewer requirement. |
| **All P0 resolved** | ✅ Pass | All 8 cumulative P0s (6 Round 1 + R2 NEW-P0-1 + R3-NEW-P0-1) are verified **CLOSED**. Zero new P0s introduced. |
| **Architecture complete** | ✅ Pass | Seam isolation, CLI parser/help/dispatch, robust generator pipefail defense, soft triggers, Option A pure isolation baseline, and idempotent non-destructive quarantine fully articulated across §§1–3. |
| **Components specified** | ✅ Pass | All 11 target files with dual-platform parity explicitly enumerated in §1; Section 7 Required Evidence Manifest populated. |
| **Functions verified** | ✅ Pass | Main-free loader in AC1.4 verified; set-membership consumer `printf '%s\n' "$TAD_TOP_DENY" \| grep -Fxq "$bn"`; safe pipefail wrappers `{ grep ... \|\| true; }`; stateful awk range extractor in AC6.1; portable sha256 helper; YAML quoting regex. |
| **Data flow mapped** | ✅ Pass | Distribution copy paths with top-file exclusion, install/upgrade preservation flows, quarantine move and manifest logging flows mapped. |

---

## 3. Verification of R3-NEW-P0-1 Closure: Main-Free Loader in AC1.4

### Defect Identified in Round 3 Scope Review
In Round 3, §9.1 AC1.4 specified:
```bash
bash -c 'source tad.sh >/dev/null 2>&1; derive_framework_top_files . | { grep -Fx "brain-index.md" && exit 1 || true; } && ...'
```
Because `tad.sh` terminates with an unguarded `main` call at line 2954, `source tad.sh` executed the entire `main` function (version banner, environment validation), which then terminated the subshell before execution ever reached `derive_framework_top_files`. Consequently, the probe was vacuous: it exited 0 unconditionally, certifying a leaking repository as clean (always-green anti-pattern).

### R4 Resolution Inspection (§9.1 AC1.4, L302)
Alex amended the verification command in §9.1 AC1.4 to:
```bash
TMPF=$(mktemp) && sed '/^main$/d' tad.sh > "$TMPF" && bash -c 'source "$0" >/dev/null 2>&1; derive_framework_top_files . | { grep -Fx "brain-index.md" && exit 1 || true; } && derive_framework_top_files . | { grep -Fx "sync-registry.yaml" && exit 1 || true; } && derive_framework_top_files . | grep -Fxq "version.txt"' "$TMPF"; RC=$?; rm -f "$TMPF"; exit $RC
```

### Architectural & Spec Evaluation of the Fix
1. **Surgical Line Deletion**:
   - In `tad.sh`, line 2954 consists of exactly `main`.
   - `sed '/^main$/d'` strips exclusively line 2954 without altering function definitions, variable assignments (like `TAD_TOP_DENY`), or internal helpers.
2. **Subshell Argument Passing**:
   - `bash -c 'source "$0" ...' "$TMPF"` correctly binds `$0` to the temporary filtered file path `"$TMPF"`.
   - `source "$0"` loads all declarations in `tad.sh` into the subshell environment without calling `main`.
3. **Execution Reachability**:
   - Because `main` is not invoked, execution continues sequentially into the pipeline:
     - `derive_framework_top_files . | { grep -Fx "brain-index.md" && exit 1 || true; }`
     - `derive_framework_top_files . | { grep -Fx "sync-registry.yaml" && exit 1 || true; }`
     - `derive_framework_top_files . | grep -Fxq "version.txt"`
4. **Behavioral Discrimination**:
   - **At Baseline (Pre-Implementation)**:
     `TAD_TOP_DENY="sync-registry.yaml"` in unmodified `tad.sh`. `derive_framework_top_files .` outputs `brain-index.md`. `grep -Fx "brain-index.md"` matches (exit 0) and triggers `exit 1`. The pipeline terminates with exit code 1. `RC=$?` captures 1, cleans up `"$TMPF"`, and exits 1. **Fails cleanly on leakage.**
   - **Post-Implementation (Blake's fix)**:
     `brain-index.md` is added to `TAD_TOP_DENY` and excluded by `derive_framework_top_files`. `grep -Fx "brain-index.md"` finds no match (exit 1), triggering `|| true` (exit 0). `sync-registry.yaml` is similarly excluded (exit 0). `version.txt` is output and matched by `grep -Fxq "version.txt"` (exit 0). The entire pipeline exits 0. `RC=$?` captures 0, cleans up `"$TMPF"`, and exits 0. **Passes cleanly when fixed.**
5. **Absence of Scope Creep**:
   - The fix is strictly confined to the verification command text in the handoff. No `BASH_SOURCE` guard or installer-behavior changes were introduced into `tad.sh`, keeping Blake's implementation mandate focused strictly on the locked scope.

**Verdict**: **CLOSED** ✅

---

## 4. Confirmation of Prior P0s Staying CLOSED (All 7 Prior P0s)

| # | Prior P0 ID | Original Concern | Current Status in R4 Handoff | Verdict |
|---|---|---|---|---|
| 1 | **Scope R1 P0-1** | AC1 vacuous (`--verify-denylist` never reads `TOP_DENY`) | Addressed in §3 Task 1 & §9.1 AC1.1–1.5 with direct representation assertions, sibling-pin checks, and live behavioral probe in AC1.4. | **CLOSED** ✅ |
| 2 | **Scope R1 P0-2 / Spec R1 P0-2** | `TAD_TOP_DENY` scalar string equality trap (`[ "$bn" = "$TAD_TOP_DENY" ]`) | Mandates multiline newline-delimited strings; consumer updated to set membership `printf '%s\n' "$TAD_TOP_DENY" \| grep -Fxq "$bn" && continue`; comment at L592 updated (§3 Task 1, §9.1 AC1.3). | **CLOSED** ✅ |
| 3 | **Scope R1 P0-3 / Spec R1 P0-3** | Quarantine script unconditionally clobbers sanctioned `README.md` | Task 5, §1 Forbidden, and §4 AC4 explicitly mandate NEVER moving or modifying `README.md`; AC4.3 verifies `README.md` remains intact and byte-identical. | **CLOSED** ✅ |
| 4 | **Spec R1 P0-1** | Missing `## 9.1 Spec Compliance Checklist` table | Fully populated 6-column checklist table with 19 executable rows (AC1.1–AC8.3) and clear expected evidence. | **CLOSED** ✅ |
| 5 | **Spec R1 P0-4** | Quarantine tool lacks `tad.sh --quarantine-pk` CLI wiring | Task 4 details CLI option parsing in `tad.sh`, `--help` text documentation, and dispatcher invocation. Verified in AC4.1. | **CLOSED** ✅ |
| 6 | **Spec R1 P0-5** | Missing Required Evidence Manifest (A-02 contract violation) | Formal YAML `required_evidence_manifest` in §7 specifies required review files and section headings. | **CLOSED** ✅ |
| 7 | **Scope R2 NEW-P0-1** | AC6.1 awk range `/## Step 6: Finalize/,/## [A-Z0-9]/` collapsed to 1 line | Stateful awk pattern `awk 'f&&/^## /{exit} /^## Step 6: Finalize/{f=1;next} f'` correctly extracts section body across dual trees (§9.1 AC6.1). | **CLOSED** ✅ |

---

## 5. Assessment of Round 3 Advisory P1/P2 Resolutions

Alex incorporated all advisory findings from Round 3 into the R4 handoff:

1. **R3 P1-1: YAML Quoting Variants in AC5.1 Fixture**:
   - **Resolution**: §9.1 AC5.1 now creates three distinct skills in the fixture:
     - `c1/SKILL.md`: `ownership: project-owned` (bare)
     - `c2/SKILL.md`: `ownership: 'project-owned'` (single-quoted)
     - `c3/SKILL.md`: `ownership: "project-owned"` (double-quoted)
     - `local/keep.txt`: directory preservation
   - All four are verified to survive `tad.sh --source . --platform both --yes` re-sync.
   - **Status**: **RESOLVED** ✅

2. **R3 P2-1: Anchored Exact Match in AC2.1**:
   - **Resolution**: §9.1 AC2.1 upgraded `grep -v 'README.md'` to `grep -vx 'README.md'`, preventing accidental false-negative filtering of files like `README.md.bak`.
   - **Status**: **RESOLVED** ✅

3. **R3 P2-2: Live Workspace Brain-Index Guard in AC6.2**:
   - **Resolution**: §9.1 AC6.2 now creates a timestamped backup before touching mtime and restores it via a chained command:
     `cp -p .tad/brain-index.md .tad/brain-index.md.bak && touch -t 202001010000 .tad/brain-index.md && ... ; mv -f .tad/brain-index.md.bak .tad/brain-index.md; test $STAT -eq 0`
   - Prevents leaving dirty workspace modifications after verification runs.
   - **Status**: **RESOLVED** ✅

---

## 6. Comprehensive Zero-New-P0 & Invariant Scan

### 6.1 Human Decision Locks Strictly Preserved
- **Lock ① (Option A: Pure Isolation)**:
  - Enforced across §1 (Out of Scope, Forbidden), §3 Task 4 (Install Routine), §4 AC2 & AC8(c), §6 Decision Log, and §9.1 AC2.1 & AC8.3.
  - Fresh installs receive only `.tad/project-knowledge/README.md`. Subdirectories `patterns/` and `incidents/` are initialized empty. Zero `framework-principles.md` or provenance machinery is introduced into business projects.
- **Lock ② (Quarantine Opt-In Only)**:
  - Enforced across §1, §3 Task 4, §4 AC4 & AC8(a), §6 Decision Log, and §9.1 AC4.1 & AC8.1.
  - `tad.sh update` execution path contains zero calls to `quarantine-framework-pk.sh`.

### 6.2 Cognitive Firewall & Gate Integrity
- Freshness of `brain-index.md` remains strictly soft and advisory.
- Negative assertion §9.1 AC8.2 explicitly verifies that no Gate 3 or Gate 4 verification scripts block on `brain-index.md` freshness.
- Aligns with L1 principle: "Knowledge Is Forged at Distill, Not Captured".

### 6.3 Dual-Platform Mirror Parity
- Modified files under `.claude/skills/` are mirrored byte-identically in `.agents/skills/`.
- §9.1 AC7.1 enforces `release-verify.sh parity .` exit 0.

### 6.4 MECE Verification Coverage in §9.1
All 19 AC rows in §9.1 provide executable commands, clear expected evidence, and non-vacuous baselines:
- AC1.1–1.5: Top-file denylist declaration, consumer logic, behavioral probe, denylist check.
- AC2.1: Option A clean install isolation.
- AC3.1–3.2: Generator pipefail resilience and complete field extraction under cap.
- AC4.1–4.4: Quarantine CLI help, syntax/executable check, preservation of customized files, idempotency.
- AC5.1: Project-owned skill protection across YAML quoting variants and `local/`.
- AC6.1–6.2: Soft distillation trigger insertion across dual trees and WARN-only freshness check.
- AC7.1: Dual-platform mirror parity.
- AC8.1–8.3: Negative invariants (update never quarantines, gates never block on freshness, no framework principles file).

**Conclusion**: **Zero new P0 or blocking issues found.**

---

## 7. Advisory Guidance for Blake (Non-Blocking P2)

### P2-1: `$OLDPWD` Evaluation in Non-Interactive Gate 3 Contexts
- In §9.1 AC4.3 and AC4.4:
  `... (cd "$TMPD" && bash "$OLDPWD/tad.sh" --quarantine-pk >/dev/null 2>&1) ...`
- In some subshell or non-interactive environments, `$OLDPWD` may not be populated prior to an internal `cd`.
- **Recommendation for Blake**: During test execution or script authoring, prefer capturing an explicit variable before entering the subshell:
  `SRC_DIR="$PWD"; (cd "$TMPD" && bash "$SRC_DIR/tad.sh" --quarantine-pk ...)`
  This ensures 100% deterministic path resolution regardless of shell initialization flags.

---

## 8. Gate 2 Overall Verdict & Recommendations

### 🟢 Overall Verdict: PASS

The handoff `HANDOFF-20260908-knowledge-seam-isolation.md` (status `Ready-for-Gate2-Round4`) is **APPROVED** at Gate 2 Round 4.
- `R3-NEW-P0-1` (vacuous `source tad.sh` probe) is completely resolved by the main-free loader in AC1.4.
- All 7 prior P0 issues remain verified **CLOSED**.
- Advisory items (R3 P1-1 YAML quoting variants, R3 P2-1 anchored regex, R3 P2-2 backup/restore) are cleanly incorporated.
- Locked human constraints (Option A pure isolation, opt-in quarantine) are preserved and verified via negative proof assertions.
- Both independent reviews for Round 4 (Scope Reviewer and Spec Reviewer) have returned **PASS**.

### Next Actions:
1. Alex updates handoff status frontmatter to `Ready-for-Blake`.
2. Transition to Terminal 2: Blake is authorized to begin implementation via `/blake`.
