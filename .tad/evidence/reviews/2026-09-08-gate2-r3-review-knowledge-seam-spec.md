---
gate: 2
round: 3
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
handoff_status: Ready-for-Gate2-Round3
design: .tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md
prior_reviews:
  r1_spec: .tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-spec.md
  r1_scope: .tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-scope.md
  r2_spec: .tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-spec.md
  r2_scope: .tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-scope.md
reviewer: Reviewer 2 — Spec & Architecture Reviewer (independent, Cursor)
date: 2026-09-08
channel: cursor
model: gemini-3.8-flash-medium
scope: Round 3 re-review: verification of NEW-P0-1 closure (AC6.1 stateful awk), confirmation of prior P0s staying CLOSED, advisory P1/P2 resolution verification, zero new P0s, human locks preservation, Gate 2 pass/fail verdict
counts: {P0: 0, P1: 3, P2: 0}
verdict: PASS
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only (tad.sh --quarantine-pk; no auto on update)"]
---

harness=Cursor | model=gemini-3.8-flash-medium | route=native

# Gate 2 Round 3 Independent Spec & Architecture Review — HANDOFF-20260908-knowledge-seam-isolation

## 1. Independence & Method

- **Role**: Independent Gate 2 Spec & Architecture Reviewer (Round 3 re-review). Not the handoff author (Alex).
- **Execution Discipline**: Read-only evaluation. No implementation code written or modified. Blake has not been dispatched. Only this review evidence file is generated.
- **Artifacts Inspected**:
  - Handoff under review: `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md` (372 lines, status `Ready-for-Gate2-Round3`).
  - Design Document: `.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`.
  - Prior Reviews:
    - Round 1 Spec Review: `.tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-spec.md` (FAIL: 5 P0s).
    - Round 1 Scope Review: `.tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-scope.md` (FAIL: 3 P0s).
    - Round 2 Scope Review: `.tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-scope.md` (FAIL: 1 NEW-P0, 3 P1s).
    - Round 2 Spec Review: `.tad/evidence/reviews/2026-09-08-gate2-r2-review-knowledge-seam-spec.md` (PASS).
  - Checkpoints:
    - `.tad/evidence/pm/2026-09-08-alex-knowledge-seam-amend-round3-checkpoint.md`.
  - Upstream Code & Target Locations:
    - `.tad/hooks/lib/derive-sync-set.sh` (`TOP_DENY` L77).
    - `tad.sh` (`TAD_TOP_DENY` L566, `derive_framework_top_files` L592–603, CLI parser L320–375, `copy_framework_files` L1149–1180 & L1250–1280, install/upgrade/migrate L2655–2860).
    - `.tad/hooks/lib/brain-index-gen.sh` (census of 7 grep sites + find precedence at L172 + config grep at L228).
    - Protocols: `.claude/skills/alex/references/distillation-loop-protocol.md` (L56–61) and `.agents/skills/alex/references/distillation-loop-protocol.md`.
    - Project Knowledge Principles: `principles.md:74`, `principles.md:94`, `principles.md:110`, `patterns/shell-portability.md`, `patterns/ac-verification.md`, `patterns/release-sync.md`.
- **Locked Human Constraints**:
  - ① Project knowledge baseline: **Option A — Pure Isolation** (new installs receive only `.tad/project-knowledge/README.md`; empty `patterns/` and `incidents/` subdirectories; no framework principles/incidents).
  - ② Quarantine invocation: **Opt-in only via `tad.sh --quarantine-pk`** (no automatic quarantine during `tad.sh update`).

---

## 2. Gate 2 Canonical Checklist Assessment

| Item | Status | Note |
|---|---|---|
| **Expert review complete (min 2)** | ✅ Pass | Round 1 completed by Reviewer 1 (Scope) and Reviewer 2 (Spec). Round 2 completed by Scope Reviewer (FAIL on NEW-P0-1) and Spec Reviewer (PASS). This Round 3 review provides the required independent verification of Alex's R3 amendment. |
| **All P0 resolved** | ✅ Pass | Scope R2 `NEW-P0-1` verified **CLOSED**. All 6 prior R1 P0 findings remain **CLOSED**. Zero new P0s introduced. |
| **Architecture complete** | ✅ Pass | Seam isolation, CLI integration, generator safety, soft triggers, and Option A baseline fully articulated across §§1–3. |
| **Components specified** | ✅ Pass | All 11 target files enumerated with dual-platform parity; Section 7 Required Evidence Manifest populated. |
| **Functions verified** | ✅ Pass | Set-membership consumer, pipefail guards across all sites, stateful awk extraction, portable sha256 helper, YAML quoting regex specified. |
| **Data flow mapped** | ✅ Pass | Distribution copy paths, quarantine archival paths, and manifest logging flows fully mapped. |

---

## 3. Verification of NEW-P0-1 Closure (Scope R2 Finding)

### Finding: Scope R2 NEW-P0-1 — §9.1 AC6.1 Range Extractor Collapse
- **Defect in R2 Handoff**:
  The verification command in §9.1 AC6.1 utilized:
  `awk '/## Step 6: Finalize/,/## [A-Z0-9]/' ... | grep -F "brain-index-gen.sh"`
  Because the start heading `## Step 6: Finalize` contains `S` which matches the end pattern `[A-Z0-9]`, awk collapsed the range to a single line (the heading itself). This created an unsatisfiable false-FAIL condition at Gate 3.
- **R3 Inspection & Verification**:
  - Handoff line 312 now specifies the stateful pattern:
    ```bash
    awk 'f&&/^## /{exit} /^## Step 6: Finalize/{f=1;next} f' .claude/skills/alex/references/distillation-loop-protocol.md | grep -F "brain-index-gen.sh" && awk 'f&&/^## /{exit} /^## Step 6: Finalize/{f=1;next} f' .agents/skills/alex/references/distillation-loop-protocol.md | grep -F "brain-index-gen.sh"
    ```
  - **Logic Evaluation**:
    1. Lines before `## Step 6: Finalize`: `f` is uninitialized (0), condition `f` is false, nothing is output.
    2. At `## Step 6: Finalize`: matches `/^## Step 6: Finalize/`, sets `f=1`, executes `next` (skips outputting the start heading itself).
    3. Lines within Step 6: do not match `/^## /`, condition `f` is true, prints line content.
    4. At next section heading (e.g. `## Step 7: Codex upgrade`): condition `f && /^## /` evaluates to true, triggers `exit`, terminating awk cleanly.
    5. Baseline check: Neither protocol file currently contains `brain-index-gen.sh`, so `grep -F "brain-index-gen.sh"` exits 1 (expected pre-implementation baseline). Post-implementation, the inserted trigger line is cleanly matched and exits 0.
  - Applies symmetrically across both `.claude/` and `.agents/` protocol trees.
- **Verdict**: **CLOSED** ✅

---

## 4. Confirmation of Prior P0s Staying CLOSED

| Prior P0 ID | Original Finding | Current Status in R3 Handoff | Verdict |
|---|---|---|---|
| **Scope R1 P0-1** | AC1 vacuous (`--verify-denylist` never reads `TOP_DENY`) | Verified. Section 3 Task 1 and §9.1 AC1.1–1.4 specify direct representation checks in both files + direct behavioral probe of `derive_framework_top_files` asserting exclusion of `brain-index.md`, retention of sibling `sync-registry.yaml` exclusion, and retention of `version.txt`. `--verify-denylist` retained as companion check (AC1.5). | **CLOSED** ✅ |
| **Scope R1 P0-2 / Spec R1 P0-2** | `TAD_TOP_DENY` scalar string equality trap | Verified. Section 3 Task 1 mandates newline-delimited strings in both files; consumer in `derive_framework_top_files()` uses set-membership `printf '%s\n' "$TAD_TOP_DENY" \| grep -Fxq "$bn" && continue`; comment at `tad.sh:592` updated; sibling-pin ACs in place. | **CLOSED** ✅ |
| **Scope R1 P0-3 / Spec R1 P0-3** | Quarantine script unconditionally clobbers sanctioned `README.md` | Verified. Section 3 Task 5 explicitly prohibits moving or modifying `.tad/project-knowledge/README.md`. Section 1 Forbidden bans deleting sanctioned `README.md`. §4 AC4(a) and §9.1 AC4.3 verify `README.md` remains intact and byte-identical. | **CLOSED** ✅ |
| **Spec R1 P0-1** | Missing `## 9.1 Spec Compliance Checklist` (Gate 3 Hard Block) | Verified. Comprehensive 6-column `## 9.1 Spec Compliance Checklist` table present with 19 executable rows (AC1.1 through AC8.3) with explicit verification commands and baselines. | **CLOSED** ✅ |
| **Spec R1 P0-4** | Quarantine tool lacks `tad.sh --quarantine-pk` CLI wiring | Verified. Section 3 Task 4 details CLI option parsing in `tad.sh`, `--help` text documentation, and dispatcher invocation. §4 AC4(e) and §9.1 AC4.1 mandate verification via `bash tad.sh --help \| grep -F -- "--quarantine-pk"`. | **CLOSED** ✅ |
| **Spec R1 P0-5** | Missing Required Evidence Manifest (A-02 contract violation) | Verified. Section 7 provides a formal YAML `required_evidence_manifest` declaring required evidence files and section contents. | **CLOSED** ✅ |

---

## 5. Assessment of Advisory P1/P2 Resolutions from Alex's R3 Amendment

In addition to resolving `NEW-P0-1`, Alex incorporated the advisory P1 and P2 findings from Scope Reviewer R2 into the R3 handoff:

1. **P1-1 (AC3.2 Count Pattern & Content Assertion)**:
   - Fixed count regex from `grep -c "^\| HANDOFF-"` (which fell into the BRE `\|` alternation trap) to `grep -c "HANDOFF-"`.
   - Added explicit content assertion `{ grep -qE '\|\s*\||\(see file\)' && exit 1 || true; }` guaranteeing that every extracted row has non-empty `task_type` and `summary` fields (no empty cells or unextracted fallback).
   - **Status**: **RESOLVED** ✅

2. **P1-2 (AC4.3, AC4.4, AC5.1, AC6.2 Executable Commands)**:
   - Converted all remaining prose descriptions in §9.1 into literal, runnable bash commands utilizing temporary directories (`mktemp -d`), touch-stale fixtures, and proper cleanup traps.
   - **Status**: **RESOLVED** ✅

3. **P1-3 & P2-1 (Task 2 Live Line Re-Pin & Wording Clarification)**:
   - Line numbers re-pinned to live lines in `.tad/hooks/lib/brain-index-gen.sh` (L94, L135, L155, L172, L174, L177, L212, L251).
   - Line 228 config grep site explicitly wrapped for pipefail defense against empty lists.
   - Reworded description to eliminate self-contradiction: "across 7 handoff/doc grep sites + 1 find-precedence fix + 1 config grep site".
   - **Status**: **RESOLVED** ✅

---

## 6. Assessment of New P0 Risks & Invariants

A comprehensive review of the entire amended handoff confirms:
1. **Human Decision Locks Strictly Preserved**:
   - **Lock ① (Option A: Pure Isolation)**: Enforced in §1 (Out of Scope, Forbidden), §3 Task 4 (Install Routine), §4 AC2 & AC8(c), §6 Decision Log, and §9.1 AC2.1 & AC8.3. New installs receive only `README.md`; `patterns/` and `incidents/` subdirectories initialized empty. No `framework-principles.md` or provenance machinery is introduced.
   - **Lock ② (Quarantine Opt-In Only)**: Enforced in §1, §3 Task 4, §4 AC4 & AC8(a), §6 Decision Log, and §9.1 AC4.1 & AC8.1. `tad.sh update` contains zero invocations of quarantine.
2. **Cognitive Firewall & Gate Discipline**:
   - Distillation and `brain-index.md` freshness remain strictly soft and advisory.
   - Negative assertions §9.1 AC8.2 explicitly verifies that no Gate 3 or Gate 4 verification scripts block on `brain-index.md` freshness.
3. **Dual-Platform Parity**:
   - Both `.claude/skills/` and `.agents/skills/` trees are explicitly maintained in parity, with §9.1 AC7.1 requiring `release-verify.sh parity .` to exit 0.

**Conclusion**: **Zero new P0 issues identified.**

---

## 7. Advisory Guidance for Blake (Implementation Notes)

The following advisory items are non-blocking for Gate 2, but provide helpful implementation guidance for Blake:

### P1-1: Clean Formatting for Multi-Line `TOP_DENY` in `derive-sync-set.sh --report`
- In `.tad/hooks/lib/derive-sync-set.sh` (line 122), `--report` mode prints:
  `echo "  (+ top-level file: $TOP_DENY)"`.
- When `TOP_DENY` contains multiple lines, `echo` prints subsequent lines without indentation. Blake should iterate or format cleanly:
  ```bash
  printf '%s\n' "$TOP_DENY" | sed 's/^/  (+ top-level file: /;s/$/)/'
  ```

### P1-2: Canonical Upstream Hash Manifest Generation for Quarantine Script
- In Task 5 (`quarantine-framework-pk.sh`), Blake should generate the canonical sha256 hashes programmatically from git history for the 26 legacy files (e.g. at commit `v2.44.0` / May-June 2026 commits) to ensure 100% hash precision.

### P1-3: Strict Skill Protection Parity in Secondary Codex Copy Loop
- In `tad.sh`, `copy_framework_files()` copies to `$TARGET_SKILL_DIR` (primary, lines 1149–1180) and to `.agents/skills/` (secondary for `--platform both`, lines 1250–1280). Blake must ensure the project-owned skill preservation check (`local/` and `ownership: project-owned`) is placed in **both** copy loops.

---

## 8. Gate 2 Overall Verdict & Recommendations

### 🟢 Overall Verdict: PASS

The amended handoff `HANDOFF-20260908-knowledge-seam-isolation.md` is **APPROVED** at Gate 2 Round 3.
- Scope R2 `NEW-P0-1` (awk range collapse in AC6.1) has been completely resolved with the stateful pattern.
- All 6 prior R1 P0 issues remain verified **CLOSED**.
- Advisory items (P1-1, P1-2, P1-3, P2-1) have been cleanly addressed.
- Locked human constraints (Option A pure isolation, opt-in quarantine) are preserved and verified via negative proof assertions.
- §9.1 Spec Compliance Checklist is 100% executable and ready for Blake and `spec-compliance-reviewer`.

### Recommended Next Steps:
1. Alex updates handoff status frontmatter from `Ready-for-Gate2-Round3` to `Ready-for-Blake`.
2. Handoff is ready for Blake (Terminal 2) to begin implementation via `/blake`.
