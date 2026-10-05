---
gate: 2
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
design: .tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md
reviewer: Reviewer 2 — Spec & Architecture Reviewer (independent, Cursor)
date: 2026-09-08
channel: cursor
model: gemini-3.8-flash-medium
scope: spec compliance, AC executability, shell contracts, failure modes, quarantine CLI integration, Gate 3 readiness
counts: {P0: 5, P1: 8, P2: 4}
verdict: FAIL
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only (tad.sh --quarantine-pk; no auto on update)"]
---

harness=Cursor | model=gemini-3.8-flash-medium | route=native

# Gate 2 Independent Spec & Architecture Review — HANDOFF-20260908-knowledge-seam-isolation

## 1. Independence & Method

- **Role**: Independent Gate 2 Spec & Architecture Reviewer (Agent A / Alex persona).
- **Execution Discipline**: Read-only review. No implementation code touched; no writes to repository sources, scripts, or skills outside of this review evidence file.
- **Artifacts Inspected**:
  - Handoff: `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md` (133 lines, status `READY_FOR_GATE2`).
  - Design Document: `.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`.
  - Upstream Framework Distribution Code:
    - `tad.sh` (`TAD_TOP_DENY` L566, `derive_framework_top_files` L593–603, `verify_denylist_drift` L1030–1077, `copy_framework_files` L1080–1250, `verify_install_complete` L1430–1485, CLI parser L315–375, install/upgrade/migrate L2640–2870).
    - `.tad/hooks/lib/derive-sync-set.sh` (L1–145).
    - `.tad/hooks/lib/brain-index-gen.sh` (L1–273).
    - Protocol files: `.claude/skills/alex/references/distillation-loop-protocol.md`, `.claude/skills/alex/references/acceptance-protocol.md`, and their `.agents/` mirrors.
    - Grounding Knowledge: `.tad/project-knowledge/principles.md`, `.tad/project-knowledge/patterns/shell-portability.md`, `.tad/project-knowledge/patterns/release-sync.md`, `.tad/project-knowledge/patterns/ac-verification.md`.
- **Locked Human Constraints**:
  - ① Project knowledge baseline: **Option A — Pure Isolation** (new installs receive only `.tad/project-knowledge/README.md`; no framework principles/patterns/incidents).
  - ② Quarantine invocation: **Opt-in only via `tad.sh --quarantine-pk`** (no automatic quarantine during `tad.sh update`).

---

## 2. Gate 2 Canonical Checklist Assessment

| Item | Status | Note |
|---|---|---|
| **Expert review complete (min 2)** | 🔄 In Progress | Reviewer 1 (Scope) landed in `2026-09-08-gate2-review-knowledge-seam-scope.md` (FAIL). Reviewer 2 (Spec & Architecture) executed here. |
| **All P0 resolved** | ❌ Fail | 5 P0 blocking issues identified (see Section 3). Handoff text requires amendment. |
| **Architecture complete** | ⚠️ Partial | Core seam design is solid, but `tad.sh` CLI wiring for `--quarantine-pk` is completely absent from task breakdown. |
| **Components specified** | ❌ Fail | Handoff completely omits `## 9.1 Spec Compliance Checklist` and `## Required Evidence Manifest`, which are mandatory TAD quality gates. |
| **Functions verified** | ❌ Fail | `TAD_TOP_DENY` single-string equality check in `tad.sh:599` will silently break upon adding a second file; pipefail sites in `brain-index-gen.sh` are under-enumerated. |
| **Data flow mapped** | ✅ Pass | Data flow from source `.tad/` to target project `.tad/` verified across `tad.sh` and sync routines. |

---

## 3. P0 Findings (Blocking Issues — Must Fix Before Implementation)

### 🚨 P0-1: Missing `## 9.1 Spec Compliance Checklist` (Triggers Gate 3 Empty Guard Hard Block)
- **Defect**: The handoff defines Section 4 as a high-level markdown checklist (`- [ ] **AC1**: ...`), but provides **zero** `## 9.1 Spec Compliance Checklist` table.
- **Protocol Contract**: Per `gate/SKILL.md` (lines 188–198, `Spec_Compliance_Empty_Guard`):
  > "active handoff 的 §9.1 Spec Compliance Checklist 表格是否为空或缺失？if_empty_or_missing: action: BLOCK Gate 3."
  Gate 3 is AC-driven; it executes each row's `Verification Method` verbatim and matches `Expected Evidence`.
- **Consequence**: If Blake receives this handoff as written, Gate 3 will immediately fail at the Prerequisite stage due to `Spec_Compliance_Empty_Guard`.
- **Required Fix**: Populate Section 9.1 with a strict 6-column table:
  `| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |`
  Classify every row as `pre-impl-verifiable` or `post-impl-verifiable`, provide literal runnable shell commands, and execute step1d dry-run.

---

### 🚨 P0-2: `TAD_TOP_DENY` Representation Trap in `tad.sh` (Breaks Top-Level Sync Exclusions)
- **Defect**: In `tad.sh`:
  - Line 566: `TAD_TOP_DENY="sync-registry.yaml"`
  - Line 599: `[ "$bn" = "$TAD_TOP_DENY" ] && continue`
  In `.tad/hooks/lib/derive-sync-set.sh`:
  - Line 77: `TOP_DENY="sync-registry.yaml"`
- **Failure Mode**: The consumer in `derive_framework_top_files()` performs a scalar string equality check (`[ "$bn" = "$TAD_TOP_DENY" ]`). If `TAD_TOP_DENY` is changed to a multi-line or space-delimited string (e.g. `TAD_TOP_DENY="sync-registry.yaml\nbrain-index.md"`), `$bn` will **never** equal `$TAD_TOP_DENY`.
  - **Catastrophic Result**: Neither `brain-index.md` nor `sync-registry.yaml` will be excluded! `sync-registry.yaml` will leak to downstream repos, and `brain-index.md` will continue to leak.
  - Furthermore, `verify_install_complete()` in `tad.sh` (line 1440) checks that every file emitted by `derive_framework_top_files "$src"` exists on target. If `brain-index.md` is emitted, target verification will fail because `brain-index.md` is not copied!
- **Required Fix**: Task 1 must explicitly specify:
  1. Multi-value representation: `TAD_TOP_DENY="sync-registry.yaml"$'\n'"brain-index.md"` (or newline-delimited block).
  2. Consumer update in `derive_framework_top_files()`: use set membership, e.g.:
     `printf '%s\n' "$TAD_TOP_DENY" | grep -Fxq "$bn" && continue`
  3. Complement assertions: verify that `derive_framework_top_files` excludes `brain-index.md` AND STILL excludes `sync-registry.yaml`, while retaining `version.txt`.

---

### 🚨 P0-3: Quarantine Script Unconditionally Clobbers Sanctioned `README.md` Seed
- **Defect**: Task 5 specifies:
  > "Contains hash manifest of upstream framework files. When run in a downstream repo, moves same-hash files to `.tad/archive/quarantine-framework-pk-<date>/`."
- **Failure Mode**: Under locked Human Decision ① (Option A), `tad.sh install` deliberately seeds `.tad/project-knowledge/README.md` from upstream. A clean downstream project has a byte-identical `README.md` by design. A naive same-hash sweep across `.tad/project-knowledge/` will detect that `README.md` matches upstream and move it into quarantine, leaving the target with 0 files in `.tad/project-knowledge/` and destroying the Option A invariant.
- **Required Fix**:
  1. Add strict exclusion in Task 5: `quarantine-framework-pk.sh` must **NEVER** touch `.tad/project-knowledge/README.md`.
  2. Scope constraint: `quarantine-framework-pk.sh` must operate strictly inside `.tad/project-knowledge/` and ignore all other directories.
  3. AC4 must verify: `README.md` remains in place and intact after quarantine runs.

---

### 🚨 P0-4: Quarantine Tool Lacks `tad.sh --quarantine-pk` CLI Wiring (Breaks Human Decision ②)
- **Defect**: Human Locked Decision ② mandates:
  > "quarantine opt-in only (`tad.sh --quarantine-pk`; no auto on update)."
  However, Task 5 only specifies creating `.tad/hooks/lib/quarantine-framework-pk.sh`. Neither Task 4 nor Task 5 specifies:
  - Adding `--quarantine-pk` to `tad.sh` CLI option parser (lines 322–350).
  - Adding `--quarantine-pk` to `tad.sh --help` text (line 353).
  - Adding the dispatcher in `tad.sh` to execute the hook script.
- **Failure Mode**: Downstream operators attempting to execute the documented command `tad.sh --quarantine-pk` will receive `tad.sh: unknown option '--quarantine-pk'`.
- **Required Fix**: Expand Task 4 / Task 5 to include `tad.sh` CLI flag integration and dispatch for `--quarantine-pk`, with a dedicated AC checking `tad.sh --quarantine-pk --help` or dry-run execution.

---

### 🚨 P0-5: Missing Required Evidence Manifest (A-02 Contract Violation)
- **Defect**: The handoff contains no `Required Evidence Manifest` section.
- **Protocol Contract**: Per `alex/SKILL.md` (line 155):
  > "Required Evidence Manifest — MANDATORY section (Phase 3 anchor A-02): explicit YAML block listing every evidence file Blake must produce... PreToolUse hook AW-1/BW-1 will reject the handoff Write if this section is missing."
- **Required Fix**: Add an explicit YAML manifest declaring the evidence files Blake must produce for Gate 3, including unit test logs, simulation outputs, and quarantine dry-run reports.

---

## 4. P1 Findings (Important Gaps — Must Address in Handoff Amendment)

### ⚠️ P1-1: Target Files and Blast Radius Omit Dual-Platform Mirrors and Carriers
- In §1 Target Files: lists only `.claude/skills/alex/references/distillation-loop-protocol.md` and `acceptance-protocol.md`.
- **Missing Carriers**:
  - `.agents/skills/alex/references/distillation-loop-protocol.md` (mandatory for platform parity).
  - `.agents/skills/alex/references/acceptance-protocol.md`.
  - `tad.sh` CLI parser and help sections (for `--quarantine-pk`).
  - `.claude/skills/tad-maintain/SKILL.md` and `.agents/skills/tad-maintain/SKILL.md` (if maintain checks freshness).
- **Fix**: Exhaustively enumerate every file in §1 Target Files.

### ⚠️ P1-2: Incomplete Catalog of `brain-index-gen.sh` Pipefail Sites
- Task 2 notes: `grep -m1 '^task_type:' "$file"`.
- **Actual Code Read**: Under `set -euo pipefail`, ANY failed `grep` in a pipeline causes immediate script termination. Vulnerable sites in `brain-index-gen.sh`:
  - Line 98: `summary=$(grep -m1 '^## \|^### ' "$file" 2>/dev/null | ...)`
  - Line 136: `task_type=$(grep '^task_type:' "$file" 2>/dev/null | head -1 | ...)`
  - Line 156: `summary=$(grep -m1 '^[^#>|!-]' "$file" 2>/dev/null | ...)`
  - Line 174: `task_type=$(grep -m1 '^task_type:' "$file" 2>/dev/null | ...)` (crashes on legacy handoffs)
  - Line 177: `summary=$(grep -m1 '^# ' "$file" 2>/dev/null | ...)`
  - Line 212: `summary=$(grep -m1 '^# \|^## ' "$file" 2>/dev/null | ...)`
  - Line 251: `summary=$(grep -m1 '^[^#>|!-]' "$file" 2>/dev/null | ...)`
- **Fix**: Task 2 must mandate wrapping ALL `grep -m1` invocations with `{ grep ... 2>/dev/null || true; } | ...` and providing default fallback variables.

### ⚠️ P1-3: AC1 Verifier is Vacuous (`tad.sh --verify-denylist` Does Not Check Top Files)
- AC1 states: "`bash tad.sh --verify-denylist` exits 0".
- As proven by code read of `verify_denylist_drift()` (`tad.sh` lines 1050–1064), `--verify-denylist` checks directory sync lists (`TAD_DENY_LIST` vs `derive-sync-set.sh --zero-touch ∪ --transient`). It **never** inspects `TOP_DENY` or `TAD_TOP_DENY`.
- **Fix**: AC1 must assert direct behavioral proof:
  `derive_framework_top_files "$TAD_ROOT" | grep -Fxq 'brain-index.md'` returns exit code 1 (absent).

### ⚠️ P1-4: Portable Hash Calculation Required for `quarantine-framework-pk.sh`
- Per `shell-portability.md`, macOS provides `shasum` (or `shasum -a 256`), while Linux typically provides `sha256sum`.
- **Fix**: Task 5 must mandate a portable hash helper:
  ```bash
  hash_file() {
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$1" | awk '{print $1}'
    else
      shasum -a 256 "$1" | awk '{print $1}'
    fi
  }
  ```

### ⚠️ P1-5: Project-Owned Skill Matcher Regex Must Support YAML Quoting Variations
- Task 4 specifies checking `ownership: project-owned`.
- In YAML, users and formatters may write `ownership: project-owned`, `ownership: "project-owned"`, or `ownership: 'project-owned'`.
- **Fix**: Specify regex: `grep -qE '^ownership:[[:space:]]*["'\'']?project-owned["'\'']?' "$skill_file"`.
- Furthermore, ensure `copy_framework_files()` checks both `.claude/skills/` and `.agents/skills/`.

### ⚠️ P1-6: `tad.sh upgrade` / `migrate` Overwrite of Customized `README.md`
- In `tad.sh` lines 2770 and 2850, `upgrade` and `migrate` execute:
  `cp -r "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true`.
- If a downstream user customized their `README.md`, an update will clobber it.
- **Fix**: Add a check: if `[ -f .tad/project-knowledge/README.md ]`, do not overwrite, or back up if different (following FR-4b root file backup discipline).

### ⚠️ P1-7: Missing Negative Assertions (Absence Proofs) for Locks and Gates
- To guarantee adherence to the locked human decisions, the handoff must include negative ACs:
  1. `tad.sh update` execution does NOT trigger quarantine (assert absence of quarantine invocation in upgrade path).
  2. No Gate 3 or Gate 4 acceptance check enforces `brain-index.md` freshness as a blocking condition.
  3. Freshness checks in `tad doctor` / `tad-maintain` are **WARN-only** (must exit 0 on stale).

### ⚠️ P1-8: Missing Project Knowledge & Historical Lessons Section
- Per TAD handoff protocol, the handoff must include "📚 Project Knowledge" with mandatory historical lessons:
  - `principles.md:74` ("Deny-List Beats Allow-List for Sync Sets").
  - `principles.md:94` ("Deny-List Must Be Applied at EVERY Copy Granularity").
  - `shell-portability.md:5` ("Hook Shell Portability Rules — macOS/BSD compat").
  - `ac-verification.md` ("A verifier is only as good as the granularity it inspects").

---

## 5. P2 Findings (Nits & Structural Polish)

- **P2-1: Quarantine Directory Timestamp Precision**:
  Specify quarantine path as `.tad/archive/quarantine-framework-pk-YYYYMMDD-HHMMSS/` to prevent collisions if run multiple times on the same date.
- **P2-2: Quarantine Manifest Schema**:
  Specify `MANIFEST.md` table headers:
  `| Original File | Sha256 | Action | Reason | Timestamp |`
- **P2-3: Quarantine Idempotency**:
  Running `tad.sh --quarantine-pk` on an already clean repo must exit 0 with "0 files quarantined", without error or creating empty archive directories.
- **P2-4: Operator Parens in `brain-index-gen.sh` Find Command**:
  Line 173 has `find "$ARCHIVE_DIR" -name "HANDOFF-*.md" -o -name "handoff-*.md"`. Group with `\( ... \)` to prevent precedence issues.

---

## 6. Verdict & Actionable Remediation Plan

### 🔴 Overall Verdict: FAIL

The handoff `HANDOFF-20260908-knowledge-seam-isolation.md` is **NOT READY** for Blake to begin implementation. Handing this to Blake would result in:
1. Immediate Gate 3 failure due to missing §9.1.
2. Silent distribution bug leaking `sync-registry.yaml` and `brain-index.md` due to the `TAD_TOP_DENY` string-equality trap.
3. Inability for downstream users to invoke `--quarantine-pk` via `tad.sh`.
4. Accidental destruction of the clean `README.md` seed during quarantine.

### 📋 Actionable Steps for Alex to Reach PASS:
1. **Amend Handoff Text**:
   - Add `## 9.1 Spec Compliance Checklist` table with runnable commands covering all 7 ACs + negative assertions.
   - Add `## Required Evidence Manifest` YAML block.
   - Add `## 📚 Project Knowledge` section citing the relevant L1/L2 lessons.
   - Update Task 1 with explicit multi-line representation and set-membership consumer for `TAD_TOP_DENY`.
   - Update Task 4 & 5 to include `tad.sh --quarantine-pk` CLI parsing and dispatch.
   - Update Task 5 to explicitly exclude `.tad/project-knowledge/README.md` and use a portable sha256 helper.
   - Expand Task 2 to cover all 7 pipefail sites in `brain-index-gen.sh`.
   - Complete §1 Target Files and Blast Radius.
2. **Re-Review**:
   - Once amended, perform Gate 2 re-evaluation. With P0-1 through P0-5 resolved, the handoff can flip to `READY_FOR_BLAKE`.
