---
gate3_verdict: pass
---

# Completion Report: Installer Audit Fixes (5 bugs)

**Handoff**: .tad/active/handoffs/HANDOFF-20260617-installer-audit-fixes.md
**Task ID**: TASK-20260617-004
**Git Commit**: b58cdeb
**Date**: 2026-06-17

## What Was Done

### Bug 1 (P0): package.json version drift
- Changed `package.json` version from "2.30.0" to "2.31.0"

### Bug 2 (P1): CLAUDE.md marker-based merge
- Added `merge_claude_md()` function to tad.sh (~40 lines)
- Uses `grep -nF` (fixed string, no regex injection) + `mktemp` + `mv` (atomic write)
- Always backup first, cleanup temp files on failure
- Upgrade + migrate paths use merge; install path keeps bare cp
- Added `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker to source CLAUDE.md
- Legacy files (no marker): backup + overwrite + warn

### Bug 3 (P1): --force reinstall flag
- Added `--force` to tad.sh argument parsing + --help output
- Same-version: reinstall via upgrade path
- Newer-than-target: refuses downgrade (via `_tad_ver_cmp`)
- bin/tad-install.mjs passes `--force` through to tad.sh

### Bug 4 (P2): Documentation curl --yes
- Updated 9 files: README.md, INSTALLATION_GUIDE.md, tad-help SKILL, docs/README.md, docs/releases/v1.6-release.md, publish-protocol.md x2, sync-protocol.md x2
- Also fixed tad-help references from `install.sh` → `tad.sh`

### Bug 5 (P2): package.json files array
- Added `".agents/"` to files array

### AC10: release-runbook
- Added package.json as item #15 in version bump file list
- Updated "6 places" → "7 places" count
- Added package.json to quick grep verification command

## Deviations from Plan

None. All 12 ACs implemented as specified.

## Implementation Decisions (Made During Execution)

| # | Decision | Context | Chosen | Escalated? | Human Approved? |
|---|----------|---------|--------|------------|-----------------|
| 1 | Fix tad-help `install.sh` → `tad.sh` | tad-help referenced non-existent install.sh | Fixed alongside --yes | No | Default |
| 2 | Fix docs/ tree curl commands | spec-compliance flagged docs/README.md + v1.6-release.md | Added --yes to all | No | Default |

## Layer 1: Self-Check

| Check | Result |
|-------|--------|
| bash -n tad.sh | PASS |
| node --check bin/tad-install.mjs | PASS |
| python3 JSON validate package.json | PASS |
| AC12 integration test (install → edit → merge) | PASS |
| AC11 legacy test (no marker → backup + warn) | PASS |

## Layer 2: Expert Review

| Expert | Result | Findings | Evidence |
|--------|--------|----------|----------|
| spec-compliance | PASS (12/12 SATISFIED) | 0 NOT_SATISFIED | .tad/evidence/reviews/blake/installer-audit-fixes/spec-compliance.md |
| code-reviewer | PASS (P0=0, P1=0 after fixes) | 2 P0 fixed, 2 P1 fixed, 1 P1 by-design, 2 P1 cosmetic | .tad/evidence/reviews/blake/installer-audit-fixes/code-review.md |
| security-auditor | PASS (critical=0, high=0) | 1 P1 pre-existing, 3 P2 (1 fixed) | .tad/evidence/reviews/blake/installer-audit-fixes/security-review.md |

## Reflexion History

无 reflexion（Layer 1 一次通过）

## Friction Status

| Friction | Status | Resolution |
|----------|--------|------------|
| None encountered | READY | N/A |

## Evidence Checklist

- [x] spec-compliance review: .tad/evidence/reviews/blake/installer-audit-fixes/spec-compliance.md
- [x] code-review: .tad/evidence/reviews/blake/installer-audit-fixes/code-review.md
- [x] security-review: .tad/evidence/reviews/blake/installer-audit-fixes/security-review.md
- [x] Git commit: b58cdeb
- [x] Integration test: AC12 functional test passed
- [x] Legacy test: AC11 functional test passed

## Knowledge Assessment

**是否有新发现？** ❌ No

All patterns used (grep -nF, mktemp + mv atomic write, _tad_ver_cmp) are already documented in shell-portability.md and principles.md. No new discoveries.

**是否有可复用的工作模式？** ❌ No

**是否发现 workflow 模式？** ❌ No

**Skillify Candidate**: No (no new pattern — all techniques already documented)
