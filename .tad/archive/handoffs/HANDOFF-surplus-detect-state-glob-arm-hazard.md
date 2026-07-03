---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: ["."]
skip_knowledge_assessment: yes
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-02
**Project:** TAD Framework
**Task ID:** surplus-detect-state-glob-arm-hazard
**Handoff Version:** 3.1.0
**Epic:** EPHEMERAL-surplus-detect-state-glob-arm-hazard.md (Phase 1/1)
**Supersedes:** N/A

---

## Gate 2: Design Completeness (Alex)

**Execution time**: 2026-07-02

### Gate 2 Check Results

| Check Item | Status | Notes |
|------------|--------|-------|
| Architecture Complete | OK | Single function edit; no new architecture |
| Components Specified | OK | Only `detect_state()` case arms in tad.sh |
| Functions Verified | OK | `detect_state()` at L1343, `_tad_ver_cmp()` at L1330 both confirmed |
| Data Flow Mapped | OK | detect_state returns state string to main() case at L1427 — no data flow change |

**Gate 2 Result**: PASS

**Alex confirmation**: I have verified all design elements. Blake can independently complete the implementation from this document.

---

## Checklist (Blake read before starting)

Blake, before starting implementation, confirm:
- [ ] Read all sections
- [ ] Read the "Project Knowledge" section's historical lessons
- [ ] All MQ answers have evidence
- [ ] Understand the true intent (not just literal requirements)
- [ ] Deliverables and evidence requirements for each Phase are clear
- [ ] Confirmed ability to independently complete from this document

If any part is unclear, **immediately return to Alex for clarification**, do not start implementation.

---

## 1. Task Overview

### 1.1 What We're Building

Replace prefix-glob patterns in `tad.sh` `detect_state()` cross-major case arms with dot-bounded patterns that cannot match across minor version boundaries. Currently the v1.x case arms use `1.8*`, `1.6*|1.5*`, `1.4*` — these are prefix globs that match any string starting with the prefix, including unintended versions (e.g., `1.8*` matches `1.80.0`).

### 1.2 Why We're Building It

**Business value**: Prevents silent misrouting of version detection that could cause wrong install actions (upgrade vs migrate) on future versions.
**User benefit**: Eliminates a latent bug before it manifests.
**Success looks like**: Every case arm in `detect_state()` uses dot-bounded patterns that only match versions in the intended minor series.

### 1.3 Intent Statement

**The real problem**: Shell case-statement prefix globs (`1.8*`) are structurally ambiguous for dotted version strings — they match any string starting with the literal prefix regardless of dot boundaries. This is a latent hazard: the current v1.x arms happen not to hit a real collision (no v1.80+ exists), but the pattern would be dangerous if replicated for v2.x cross-major arms.

**NOT the goal (avoid misunderstanding)**:
- NOT modifying `_tad_ver_cmp` — it already does correct numeric 3-part comparison
- NOT changing the same-major path (the `vmaj -eq tmaj` branch uses `_tad_ver_cmp` correctly)
- NOT adding v2.x cross-major routing arms — only fixing the pattern style so future additions are safe

**Blake confirm understanding**:
```
Before starting implementation, answer in your own words:
1. What problem does this fix solve?
2. Which exact lines/patterns change?
3. What is the success criterion?

Only proceed after Human confirms your understanding is correct.
```

---

## Project Knowledge (Blake mandatory read)

### Step 1: Identify relevant categories

This task involves:
- [x] code-quality - code patterns/anti-patterns
- [x] testing - shell edge cases
- [ ] security
- [ ] ux
- [ ] architecture
- [ ] performance
- [ ] api-integration
- [ ] mobile-platform

### Step 2: Historical lesson excerpts

**Project-knowledge files read**:

| File | Relevant entries | Key reminder |
|------|-----------------|--------------|
| patterns/shell-portability.md | Relevant | BSD/macOS compat, bash patterns |
| patterns/ac-verification.md | Relevant | AC dry-run discipline |
| principles.md | 0 directly | No directly relevant entries |

**Blake must note these historical lessons**:

1. **Shell Portability** (from patterns/shell-portability.md)
   - Problem: macOS ships bash 3.2; extended patterns may behave differently
   - Solution: The fix uses only POSIX case-glob syntax (`|` alternation + `*` wildcard), which is bash 3.2+ safe. No `extglob` needed.

2. **AC Verification / Dry-Run Discipline** (from patterns/ac-verification.md)
   - Problem: ACs that look green but test the wrong thing
   - Solution: All ACs in this handoff have been dry-run by Alex; pipe-escape note applies to grep patterns in markdown tables

### Blake confirmation

- [ ] I have read the above historical lessons
- [ ] I understand the problems to avoid
- [ ] If I encounter similar situations, I will reference the above solutions

---

## 2. Background Context

### 2.1 Previous Work

`detect_state()` was written to route version detection for the TAD installer. It handles:
- `fresh` / `current` / `upgrade` / `partial` / `old` for straightforward states
- Granular v1.x states (`v1.8`, `v1.6`, `v1.4`) for cross-major migration routing

The `_tad_ver_cmp()` function (L1330-1341) does correct 3-part numeric comparison (splits on `.`, compares each segment as integer).

### 2.2 Current State

Current code (tad.sh L1361-1366):
```bash
case "$ver" in
    1.8*)        echo "v1.8" ;;
    1.6*|1.5*)   echo "v1.6" ;;
    1.4*)        echo "v1.4" ;;
    *)           echo "old" ;;
esac
```

**Hazard**: `1.8*` is a prefix glob — it matches any string starting with `1.8`, including `1.80.0`, `1.89.1`, etc. The same-major path above this case block already uses `_tad_ver_cmp` correctly, but these cross-major arms use raw glob patterns.

### 2.3 Dependencies

- None. This is a self-contained edit to one function in one file.
- `_tad_ver_cmp` is NOT modified — only referenced for edge-case verification.

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: Replace all prefix-glob case arms in `detect_state()` with dot-bounded patterns
- FR2: Dot-bounded patterns must match the same valid versions as before (1.8, 1.8.x, 1.6, 1.6.x, etc.)
- FR3: Dot-bounded patterns must NOT match across minor boundaries (1.8 pattern must not match 1.80.x)
- FR4: Add a safety comment above the case block for future maintainers

### 3.2 Non-Functional Requirements

- NFR1: Shell compatibility — bash 3.2+ (macOS), no extglob
- NFR2: No functional behavior change for any version string that currently exists (1.4.x through 1.8.x)

---

## 4. Technical Design

### 4.1 Architecture Overview

Single-function edit. The `detect_state()` function's cross-major case block (3 arms + wildcard fallback) gets its glob patterns replaced. No structural change.

### 4.2 Component Specifications

**Pattern replacement table**:

| Current pattern | New pattern | Rationale |
|----------------|-------------|-----------|
| `1.8*` | `1.8\|1.8.*` | Matches `1.8` (bare) or `1.8.<anything>` but NOT `1.80`, `1.89.1` |
| `1.6*\|1.5*` | `1.6\|1.6.*\|1.5\|1.5.*` | Same logic for both v1.6 and v1.5 series |
| `1.4*` | `1.4\|1.4.*` | Same logic for v1.4 series |
| `*` | `*` | Unchanged — catch-all for truly old/unknown versions |

Note: The `|` in the table above is the shell case-statement OR operator, not markdown pipe. In the actual shell code, these are unescaped `|`.

### 4.3 Data Models

N/A — no data model changes.

### 4.4 API Specifications

N/A — no API changes.

### 4.5 User Interface Requirements

N/A — no UI changes.

---

## 5. Mandatory Questions (Evidence Required)

### MQ1: Historical Code Search

**Question**: Did the user mention "previous", "original", or "our approach"?

**Answer**:
- [x] No — skip this question

---

### MQ2: Function Existence Verification

**Question**: What functions does the design call? Do they all exist?

**Answer**:

| Function | File location | Line | Code snippet | Verified |
|----------|--------------|------|-------------|----------|
| `detect_state()` | tad.sh | 1343 | `detect_state() {` | OK |
| `_tad_ver_cmp()` | tad.sh | 1330 | `_tad_ver_cmp() {` | OK |
| `verify_denylist_drift()` | tad.sh | 696 | `verify_denylist_drift() {` | OK |

**Human verification**: Every function has a confirmed location and line number.

---

### MQ3: Data Flow Completeness

**Question**: What fields does the backend compute/return? Does the frontend display them all?

**Answer**: N/A — this is a shell script function, not a frontend/backend system. `detect_state()` returns a state string (`v1.8`, `v1.6`, `v1.4`, `old`) consumed by the `case $STATE in` block at L1427. The return values are unchanged.

---

### MQ4: Visual Hierarchy

**Question**: Does the feature have different states/types? How does the user distinguish them?

**Answer**:
- [x] No different states — skip

---

### MQ5: State Synchronization

**Question**: Does data exist in multiple places? When does it sync?

**Answer**:

```
detect_state() → STATE variable (single location)
STATE is only used in main() case block at L1427
No sync needed — single source of truth
```

---

## 6. Implementation Steps

### Phase 1: Fix glob patterns (estimated <30 min)

#### Deliverables
- [ ] All 3 case arms in `detect_state()` use dot-bounded patterns
- [ ] Safety comment added above the case block
- [ ] tad.sh passes syntax check

#### Implementation steps

1. In `tad.sh`, locate the `detect_state()` function (L1343-1373)
2. Find the cross-major case block (L1361-1366)
3. Replace the 3 case arm patterns:
   - `1.8*)` becomes `1.8|1.8.*)`
   - `1.6*|1.5*)` becomes `1.6|1.6.*|1.5|1.5.*)`
   - `1.4*)` becomes `1.4|1.4.*)`
4. Add a comment above the case statement:
   ```bash
   # GLOB SAFETY: use dot-bounded patterns (1.8|1.8.*), NOT prefix globs (1.8*).
   # Prefix globs match across minor boundaries (1.8* matches 1.80.0).
   ```
5. Run `bash -n tad.sh` to verify syntax
6. Run `bash tad.sh --verify-denylist` from repo root to confirm no regression

#### Verification
- `bash -n tad.sh` should exit 0
- `grep -cE '1\.8\*|1\.6\*|1\.5\*|1\.4\*' tad.sh` should return 0

#### Phase 1 completion evidence (Blake must provide)
- [ ] **grep output**: No ambiguous prefix globs remain
- [ ] **bash -n**: Syntax check passes
- [ ] **AC pattern tests**: Dot-bounded patterns accept/reject correctly

**Human decision**: PASS / ADJUST

---

## 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | tad.sh | Add safety comment above L1361 case block | `grep -c 'GLOB SAFETY' tad.sh` returns 1 | 2 min |
| 2 | tad.sh | Replace `1.8*)` with `1.8\|1.8.*)` | `grep -c '1\.8|1\.8\.\*' tad.sh` returns 1 | 2 min |
| 3 | tad.sh | Replace `1.6*\|1.5*)` with `1.6\|1.6.*\|1.5\|1.5.*)` | `grep -c '1\.6|1\.6\.\*' tad.sh` returns 1 | 2 min |
| 4 | tad.sh | Replace `1.4*)` with `1.4\|1.4.*)` | `grep -c '1\.4|1\.4\.\*' tad.sh` returns 1 | 2 min |
| 5 | tad.sh | Run syntax check + denylist verify | `bash -n tad.sh && echo OK` returns OK | 2 min |

---

## 7. File Structure

### 7.1 Files to Create
None.

### 7.2 Files to Modify
```
tad.sh  # Replace 3 prefix-glob case arms with dot-bounded patterns + add safety comment
```

### 7.3 Grounded Against (Alex step1c read)

- `tad.sh` (lines 1325-1425 read at 2026-07-02, covers `_tad_ver_cmp`, `detect_state`, and STATE consumption in `main`)

---

## 8. Testing Requirements

### 8.1 Unit Tests

No formal unit test file — tad.sh is a standalone installer script. Verification is via inline bash tests and syntax checks.

### 8.2 Integration Tests

- Test: Run `bash tad.sh --verify-denylist` from TAD repo root — must pass (exit 0)
- This confirms the overall installer self-check still works after edits

### 8.3 Edge Cases

| Edge case | Input | Expected pattern match | How to verify |
|-----------|-------|----------------------|---------------|
| Bare minor version | `1.8` | MATCH on `1.8\|1.8.*` | `bash -c 'case "1.8" in 1.8\|1.8.*) echo MATCH;; *) echo NO;; esac'` |
| Patch version | `1.8.3` | MATCH on `1.8\|1.8.*` | `bash -c 'case "1.8.3" in 1.8\|1.8.*) echo MATCH;; *) echo NO;; esac'` |
| Cross-minor collision | `1.80.0` | NO-MATCH on `1.8\|1.8.*` | `bash -c 'case "1.80.0" in 1.8\|1.8.*) echo MATCH;; *) echo NO;; esac'` |
| Multi-digit patch | `1.4.12` | MATCH on `1.4\|1.4.*` | `bash -c 'case "1.4.12" in 1.4\|1.4.*) echo MATCH;; *) echo NO;; esac'` |
| v2 hypothetical | `2.19.1` | Falls to `*) old` (correct) | `bash -c 'case "2.19.1" in 1.8\|1.8.*) echo v1.8;; *) echo old;; esac'` |

### 8.4 Friction Preflight

No friction-sensitive prerequisites identified. This is a single-file edit to a bash script in the local repo.

### 8.5 Feedback Collection (Non-Code Artifacts)

N/A — code-only task.

### 8.6 Test Evidence Required

Blake must provide:
- [ ] grep output showing 0 ambiguous prefix globs
- [ ] `bash -n tad.sh` exit 0
- [ ] At least 3 edge-case pattern tests (bare version, patch version, cross-minor collision)

---

## 9. Acceptance Criteria

Blake's implementation is considered complete when:
- [ ] All prefix-glob case arms replaced with dot-bounded patterns
- [ ] Safety comment added above the case block
- [ ] `bash -n tad.sh` passes
- [ ] Pattern tests confirm correct accept/reject behavior
- [ ] No other code in `detect_state()` changed

---

## 9.1 Spec Compliance Checklist — PRIMARY VERIFICATION SOURCE (Gate 3)

> Pipe-escape note: `|` inside regex is written `\|` for markdown cell rendering.
> When extracting commands to run in bash, **un-escape**: `grep -cE 'a\|b'` (rendered) becomes `grep -cE 'a|b'` (run).

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | No ambiguous prefix globs remain in detect_state | post-impl-verifiable | `grep -cE '1\.8\*\|1\.6\*\|1\.5\*\|1\.4\*' tad.sh` | 0 | (post-impl) |
| AC2 | Dot-bounded pattern rejects cross-minor collision | pre-impl-verifiable | `bash -c 'case "1.80.0" in 1.8\|1.8.*) echo MATCH;; *) echo NO-MATCH;; esac'` | NO-MATCH | NO-MATCH |
| AC3 | Dot-bounded pattern accepts valid patch version | pre-impl-verifiable | `bash -c 'case "1.8.3" in 1.8\|1.8.*) echo MATCH;; *) echo NO-MATCH;; esac'` | MATCH | MATCH |
| AC4 | tad.sh syntax valid after edit | post-impl-verifiable | `bash -n tad.sh` | exit 0 | (post-impl) |
| AC5 | Safety comment present | post-impl-verifiable | `grep -c 'GLOB SAFETY' tad.sh` | 1 | (post-impl) |
| AC6 | Change scope limited to detect_state case arms + comment | post-impl-verifiable | `git diff --stat tad.sh` | only tad.sh changed, ~6-8 lines delta | (post-impl) |

---

## 9.2 Expert Review Status (Alex)

> Conductor handles expert review for YOLO Epics. This section is intentionally left for the Conductor to fill.

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| (Conductor-managed) | — | — | — |

### Experts Selected

1. (Conductor-managed — YOLO Epic workflow handles expert review externally)

### Overall Assessment (post-integration)

Pending Conductor review.

---

## 10. Important Notes

### 10.1 Critical Warnings
- WARNING: The `|` character in case arms is the shell OR operator. Do NOT quote or escape it in the actual bash code.
- WARNING: Do NOT use `extglob` patterns (e.g., `@(1.8|1.8.*)`) — tad.sh does not enable extglob and must stay bash 3.2 compatible.

### 10.2 Known Constraints
- The `*)` fallback arm must remain as catch-all — do NOT add an explicit `*.*` or similar pattern before it.
- `_tad_ver_cmp` must NOT be modified — it is out of scope and already correct.
- The same-major path (`vmaj -eq tmaj` at L1357-1358) must NOT be touched — it already uses `_tad_ver_cmp`.

### 10.3 Sub-Agent Usage Suggestions

Blake should consider:
- [ ] **parallel-coordinator** — No, single-file edit
- [ ] **bug-hunter** — No, straightforward pattern fix
- [ ] **test-runner** — Yes, to verify edge-case bash tests after edit
- [ ] **refactor-specialist** — No, minimal change

---

## 11. Learning Content (Optional)

### 11.1 Decision Rationale: Dot-bounded vs other approaches

**Chosen approach**: Dot-bounded case patterns (`1.8|1.8.*`)

**Alternatives considered**:

| Approach | Pros | Cons | Why not chosen |
|----------|------|------|---------------|
| Dot-bounded patterns (chosen) | Simple, POSIX case-glob, bash 3.2 safe | Slightly more verbose | CHOSEN |
| Move all routing to `_tad_ver_cmp` | Most correct numeric comparison | Requires restructuring `detect_state` control flow; overkill for granular v1.x routing that only needs range grouping | Too much blast radius for a surplus fix |
| Use `extglob` `@(1.8\|1.8.*)` | Compact | Requires `shopt -s extglob`; tad.sh does not enable it; bash 3.2 compat risk | Not compatible with existing script style |
| Regex match `[[ "$ver" =~ ^1\.8(\..+)?$ ]]` | Most precise | Replaces case-arm with if-elif chain; changes control flow structure | Unnecessary restructuring |

**Tradeoff**: Simplicity and backward compatibility vs maximum precision. Dot-bounded patterns are the minimal-risk fix.

---

## 12. Sub-Agent Usage Log

Blake fills after completion:

| Sub-Agent | Called | When | Output summary | Evidence link |
|-----------|--------|------|----------------|---------------|
| parallel-coordinator | — | — | — | — |
| bug-hunter | — | — | — | — |
| test-runner | — | — | — | — |

**Human verification**: Were all necessary sub-agents called?

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-07-02
**Version**: 3.1.0
