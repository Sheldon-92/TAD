---
gate: 2
round: 2
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
design: .tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md
prior_review: .tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-spec.md
reviewer: Reviewer 2 — Spec & Architecture Reviewer (independent, Cursor)
date: 2026-09-08
channel: cursor
model: gemini-3.8-flash-medium
scope: Round 2 re-review: P0 closure verification (§9.1 checklist, Evidence Manifest, CLI wiring, TOP_DENY multi-value, README exclusion), no new P0, Gate 2 pass/fail verdict
counts: {P0: 0, P1: 3, P2: 2}
verdict: PASS
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only (tad.sh --quarantine-pk; no auto on update)"]
---

harness=Cursor | model=gemini-3.8-flash-medium | route=native

# Gate 2 Round 2 Independent Spec & Architecture Review — HANDOFF-20260908-knowledge-seam-isolation

## 1. Independence & Method

- **Role**: Independent Gate 2 Spec & Architecture Reviewer (Round 2 re-review). Not the handoff author (Alex).
- **Execution Discipline**: Read-only evaluation. No implementation code written or modified. Only this review evidence file is created.
- **Artifacts Inspected**:
  - Handoff under review: `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md` (363 lines, status `Ready-for-Gate2-rereview`).
  - Design Document: `.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`.
  - Prior Round 1 Reviews:
    - Spec Review: `.tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-spec.md` (verdict: FAIL, 5 P0s).
    - Scope Review: `.tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-scope.md` (verdict: FAIL, 3 P0s).
  - Upstream Code & Protocol Carriers:
    - `tad.sh` (`TAD_TOP_DENY` L566, `derive_framework_top_files` L592–603, CLI parser L320–375, `copy_framework_files` L1149–1180 & L1250–1280, install/upgrade/migrate L2655–2860).
    - `.tad/hooks/lib/derive-sync-set.sh` (L70–135).
    - `.tad/hooks/lib/brain-index-gen.sh` (L90–260).
    - Protocols: `.claude/skills/alex/references/distillation-loop-protocol.md`, `.claude/skills/alex/references/acceptance-protocol.md`, and `.agents/skills/` mirrors.
    - Grounding Principles: `principles.md:74`, `principles.md:94`, `principles.md:110`, `patterns/shell-portability.md`, `patterns/ac-verification.md`, `patterns/release-sync.md`.
- **Locked Human Constraints**:
  - ① Project knowledge baseline: **Option A — Pure Isolation** (new installs receive only `.tad/project-knowledge/README.md`; empty `patterns/` and `incidents/` subdirectories; no framework principles/incidents).
  - ② Quarantine invocation: **Opt-in only via `tad.sh --quarantine-pk`** (no automatic quarantine during `tad.sh update`).

---

## 2. Gate 2 Canonical Checklist Assessment

| Item | Status | Note |
|---|---|---|
| **Expert review complete (min 2)** | ✅ Pass | Round 1 completed by Reviewer 1 (Scope) and Reviewer 2 (Spec). Round 2 re-review executed independently here. |
| **All P0 resolved** | ✅ Pass | All 5 prior P0 findings verified **CLOSED** (see Section 3). Zero new P0s introduced. |
| **Architecture complete** | ✅ Pass | Seam isolation, CLI integration, generator safety, soft triggers, and Option A baseline fully articulated across §§1–3. |
| **Components specified** | ✅ Pass | All 11 target files enumerated with dual-platform parity; Section 7 Required Evidence Manifest populated. |
| **Functions verified** | ✅ Pass | Set-membership consumer, pipefail guards across all 7 sites, portable sha256 helper, YAML quoting regex specified. |
| **Data flow mapped** | ✅ Pass | Distribution copy paths, quarantine archival paths, and manifest logging flows fully mapped. |

---

## 3. Prior P0 Closure Verification

### Prior P0-1: Missing `## 9.1 Spec Compliance Checklist` (Gate 3 Hard Block)
- **Status in R1**: FAIL (Section 9.1 was completely missing, violating `gate/SKILL.md` `Spec_Compliance_Empty_Guard`).
- **R2 Inspection**:
  - Handoff lines 293–318 now provide a comprehensive 6-column `## 9.1 Spec Compliance Checklist` table.
  - Columns conform to canonical TAD specification: `| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |`.
  - Enumerates 19 discrete verification rows (AC1.1 through AC8.3) covering every behavioral requirement, CLI check, fixture simulation, and negative assertion.
  - Distinguishes `pre-impl-verifiable` baseline dry-runs (verified clean by Alex) from `post-impl-verifiable` execution contracts for Blake.
- **Verdict**: **CLOSED** ✅

---

### Prior P0-2: `TAD_TOP_DENY` Representation Trap in `tad.sh`
- **Status in R1**: FAIL (Scalar string check `[ "$bn" = "$TAD_TOP_DENY" ]` would fail upon adding a second file, breaking exclusion of both `brain-index.md` and `sync-registry.yaml`).
- **R2 Inspection**:
  - Task 1 explicitly specifies newline-delimited representation for both `.tad/hooks/lib/derive-sync-set.sh` (`TOP_DENY`) and `tad.sh` (`TAD_TOP_DENY`).
  - Consumer in `derive_framework_top_files()` updated from scalar equality to set-membership:
    `printf '%s\n' "$TAD_TOP_DENY" | grep -Fxq "$bn" && continue`
  - Comment on line 592 updated to plural ("the excluded files").
  - Sibling complement assertion specified: `derive_framework_top_files "$TAD_ROOT"` must exclude `brain-index.md` AND STILL exclude `sync-registry.yaml`, while retaining `version.txt`.
  - Fully mapped into §9.1 AC1.1, AC1.2, AC1.3, AC1.4, and AC1.5.
- **Verdict**: **CLOSED** ✅

---

### Prior P0-3: Quarantine Script Unconditionally Clobbers Sanctioned `README.md` Seed
- **Status in R1**: FAIL (Naive hash-match sweep would delete the legitimate downstream `README.md` seeded by `tad.sh install`).
- **R2 Inspection**:
  - Task 5 adds explicit exclusion: `quarantine-framework-pk.sh` must **NEVER** move or modify `.tad/project-knowledge/README.md`.
  - Operation scope strictly constrained to `.tad/project-knowledge/` (never touches other directories).
  - Section 1 "Forbidden" explicitly prohibits deleting user-modified files or sanctioned `README.md`.
  - §4 AC4(a) and §9.1 AC4.3 require verification that `README.md` remains in place and byte-identical after quarantine execution.
- **Verdict**: **CLOSED** ✅

---

### Prior P0-4: Quarantine Tool Lacks `tad.sh --quarantine-pk` CLI Wiring
- **Status in R1**: FAIL (Handoff specified hook script but omitted CLI parser, help text, and dispatch in `tad.sh`, violating Human Lock ②).
- **R2 Inspection**:
  - Task 4 specifies adding `--quarantine-pk` to the `while [ $# -gt 0 ]` parser loop in `tad.sh` (lines 320–375) with dispatcher `exec bash .tad/hooks/lib/quarantine-framework-pk.sh "$@"`.
  - Help text entry specified in `tad.sh --help`: `echo "  --quarantine-pk    quarantine legacy framework project-knowledge pollution (opt-in)"`.
  - §4 AC4(e) and §9.1 AC4.1 mandate running `bash tad.sh --help | grep -F -- "--quarantine-pk"`.
- **Verdict**: **CLOSED** ✅

---

### Prior P0-5: Missing Required Evidence Manifest (A-02 Contract Violation)
- **Status in R1**: FAIL (Handoff omitted Section 7 `Required Evidence Manifest` YAML block required by `alex/SKILL.md`).
- **R2 Inspection**:
  - Lines 265–280 of handoff provide a valid YAML block under `## 7. Required Evidence Manifest (Phase 3 Anchor A-02)`.
  - Formally declares required evidence outputs:
    1. `.tad/evidence/reviews/gate3-evidence-knowledge-seam-isolation.md` (covering top-file probe, clean install simulation, brain index output, quarantine fixture, project skill protection, and dual platform parity).
    2. `.tad/evidence/fixtures/quarantine-test-manifest.md` (synthetic quarantine fixture dry-run report).
- **Verdict**: **CLOSED** ✅

---

## 4. Assessment of New P0 Risks

A line-by-line inspection of the amended handoff was conducted to ensure no new defects or regressions were introduced:
1. **Human Decision Compliance**:
   - Locked Decision ① (Option A: Pure Isolation): Confirmed. No `framework-principles.md` or provenance machinery is introduced. `patterns/` and `incidents/` subdirectories initialized empty.
   - Locked Decision ② (Quarantine Opt-In): Confirmed. `tad.sh update` contains zero calls to quarantine; execution is strictly via `tad.sh --quarantine-pk`. Negative assertion AC8.1 verifies absence in update path.
2. **AC Executability & Determinism**:
   - All §9.1 commands are syntax-checked, portable, and contain explicit success criteria.
   - Dev regression floor and platform parity (`release-verify.sh parity .`) are properly wired.
3. **Cognitive Firewall & Gate Discipline**:
   - Knowledge distillation remains soft and non-blocking (principles.md:110 adhered to).
   - `brain-index.md` freshness is strictly WARN-only in `tad doctor` / `/tad-maintain` and non-blocking at Gates 3/4 (AC8.2).

**Conclusion**: **Zero new P0 issues identified.**

---

## 5. Advisory P1 Findings (Implementation Guidance for Blake)

The following items are non-blocking for Gate 2, but provide critical guidance for Blake during implementation:

### P1-1: Clean Formatting for Multi-Line `TOP_DENY` in `derive-sync-set.sh --report`
- **Context**: In `.tad/hooks/lib/derive-sync-set.sh` (line 122), `--report` mode prints:
  `echo "  (+ top-level file: $TOP_DENY)"`.
- **Guidance**: When `TOP_DENY` contains multiple lines, `echo` will print the second file un-indented without the closing parenthesis on each line. Blake should update the report formatting to iterate or format cleanly:
  ```bash
  printf '%s\n' "$TOP_DENY" | sed 's/^/  (+ top-level file: /;s/$/)/'
  ```

### P1-2: Canonical Upstream Hash Manifest Sourcing for Quarantine Script
- **Context**: Task 5 requires `quarantine-framework-pk.sh` to contain an inlined table of upstream framework files and their canonical sha256 hashes.
- **Guidance**: Blake should generate this manifest programmatically from git history for the 26 legacy files (e.g. at commit `v2.44.0` or git revs matching May/June 2026 incidents) rather than hand-typing hashes, ensuring 100% hash fidelity.

### P1-3: Strict Skill Protection Parity in Secondary Codex Copy Loop
- **Context**: In `tad.sh`, `copy_framework_files()` copies to `$TARGET_SKILL_DIR` (primary, lines 1149–1180) and to `.agents/skills/` (secondary for `--platform both`, lines 1250–1280).
- **Guidance**: Blake must ensure the project-owned skill preservation check (`local/` and `ownership: project-owned`) is placed in **both** copy loops, guaranteeing full protection on dual-platform setups.

---

## 6. Advisory P2 Findings (Polish & Cleanliness)

### P2-1: Error Handling When Quarantine Executed Outside a TAD Workspace
- If `tad.sh --quarantine-pk` is run in a directory lacking `.tad/`, `quarantine-framework-pk.sh` should check `[ -d .tad/project-knowledge ]` and exit cleanly with an informative error message: `Error: No .tad/project-knowledge directory found.`

### P2-2: Temporary Fixture Directory Cleanup Trap
- In §9.1 AC2.1, when testing install simulation with `TMPD=$(mktemp -d)`, ensure cleanup occurs even if a test assertion fails by using a shell trap (`trap 'rm -rf "$TMPD"' EXIT`).

---

## 7. Gate 2 Overall Verdict & Recommendations

### 🟢 Overall Verdict: PASS

The amended handoff `HANDOFF-20260908-knowledge-seam-isolation.md` is **APPROVED** at Gate 2 Round 2.
- All 5 prior P0 blocking issues have been thoroughly resolved.
- Canonical Gate 2 criteria (architecture, components, functions, data flow, expert review) are fully satisfied.
- Locked human constraints (Option A pure isolation, opt-in quarantine) are strictly enforced with negative proof assertions.
- §9.1 Spec Compliance Checklist is complete, robust, and ready to serve as the primary verification engine for Gate 3.

### Recommended Next Steps:
1. Alex updates handoff status frontmatter from `Ready-for-Gate2-rereview` to `Ready-for-Blake`.
2. Handoff is ready for Blake (Terminal 2) to begin implementation via `/blake`.
