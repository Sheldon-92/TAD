---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: yes
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-11
**Project:** TAD Framework
**Task ID:** TASK-20260611-release-v2291
**Handoff Version:** 3.1.0

---

## Gate 2: Design Completeness

**Execution time**: 2026-06-11

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | Version bump scope fully derived from `release-verify.sh version` output |
| Components Specified | ✅ | All 27 edits across 15 files enumerated with exact line numbers |
| Functions Verified | ✅ | N/A — no code logic changes, only string replacements |
| Data Flow Mapped | ✅ | N/A — no data flow changes |

**Gate 2 Result**: ✅ PASS

**Alex confirms**: Expert review complete (code-reviewer + backend-architect). 4 P0 resolved (package.json missing, AC1 infeasible, historical ref DO-NOT-TOUCH gaps). 3 P1 resolved (config.yaml pack count, description accuracy, comment wording). Blake can independently complete this release.

---

## 1. Task Overview

### 1.1 What We're Building
Patch release v2.29.1: version bump across all files + CHANGELOG entry + fix three files stuck at 2.25.0 (INSTALLATION_GUIDE.md, tad-help/SKILL.md, package.json).

### 1.2 Why We're Building It
Pack System Unification Epic (3 phases) is complete and archived. These changes need to ship to downstream projects. A patch release tags the work and enables `*sync`.

### 1.3 Intent Statement

**The real problem:** 8 commits ahead of origin containing Pack System Unification work; version strings still read 2.29.0; three files (INSTALLATION_GUIDE.md, tad-help/SKILL.md, package.json) have been stale since v2.25.0.

**Not:**
- Not a minor release (no new features, just tagging completed work)
- Not changing any logic in tad.sh or migration-engine.sh (only their version strings)

---

## 📚 Project Knowledge

### Relevant knowledge

| File | Relevant Entries | Key Reminder |
|------|-----------------|--------------|
| patterns/shell-portability.md | 0 | No shell logic changes |
| principles.md | 1 (Deny-List / Version Grep) | Version grep must scope to `git ls-files`; prefer false-positive |

**Blake notes:**
- `release-verify.sh version` is the authoritative zero-stale gate. Run it after all bumps to catch stragglers.
- `sync-registry.yaml` versions are NOT bumped now — they update post-sync.
- `config.yaml:294` has `v2.29.0:` as a version_history entry key — do NOT change it (historical record).

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Bump version 2.29.0 → 2.29.1 in all live references
- FR2: Fix INSTALLATION_GUIDE.md stale 2.25.0 → 2.29.1
- FR3: Fix .claude/skills/tad-help/SKILL.md stale 2.25.0 → 2.29.1
- FR4: Fix package.json stale 2.25.0 → 2.29.1
- FR5: Add CHANGELOG.md [2.29.1] entry
- FR6: Update config.yaml `last_updated` to 2026-06-11
- FR7: Fix config.yaml description "24 capability packs" → "25" (actual registry count)

---

## 6. Implementation Steps

### Phase 1: Version Bump (all files)

#### Files + exact changes

**Core framework (4 files, 6 edits):**
1. `.tad/version.txt` — replace entire content with `2.29.1`
2. `.tad/config.yaml:1` — comment: `v2.29.0` → `v2.29.1`
3. `.tad/config.yaml:3` — `version: 2.29.0` → `version: 2.29.1`
4. `.tad/config.yaml:4` — description: `24 capability packs` → `25 capability packs`
5. `.tad/config.yaml:5` — `last_updated: 2026-06-10` → `last_updated: 2026-06-11`
6. `tad.sh:22` — `TARGET_VERSION="2.29.0"` → `TARGET_VERSION="2.29.1"`
7. `.tad/hooks/lib/migration-engine.sh:10` — `ENGINE_VERSION="2.29.0"` → `ENGINE_VERSION="2.29.1"`

**README.md (3 edits):**
7. Line 3: `Version 2.29.0` → `Version 2.29.1`
8. Line 114: `Should show: 2.29.0` → `Should show: 2.29.1`
9. Line 410: `TAD v2.29.0` → `TAD v2.29.1`

**docs/ (7 edits):**
10. `docs/CODEX-USER-GUIDE.md:3` — `v2.29.0+` → `v2.29.1+`
11. `docs/CODEX-USER-GUIDE.md:59` — `2.29.0` → `2.29.1`
12. `docs/MULTI-PLATFORM.md:3` — `Version: 2.29.0` → `Version: 2.29.1`
13. `docs/MULTI-PLATFORM.md:215` — `v2.29.0` → `v2.29.1`
14. `docs/codex-guide.html:174` — `v2.29.0` → `v2.29.1`
15. `docs/codex-guide.html:257` — `2.29.0` → `2.29.1`
16. `docs/codex-guide.html:675` — `v2.29.0` → `v2.29.1`

**HTML intro pages (4 edits):**
17. `tad-intro-feedback.html:138` — `v2.29.0` → `v2.29.1`
18. `tad-intro-feedback.html:218` — `v2.29.0` → `v2.29.1`
19. `tad-intro.html:178` — `v2.29.0` → `v2.29.1`
20. `tad-intro.html:258` — `v2.29.0` → `v2.29.1`

### Phase 2: Fix 2.25.0 Stale Refs

These three files were never bumped past 2.25.0 — fix them to 2.29.1:

21. `package.json:3` — `"version": "2.25.0"` → `"version": "2.29.1"`
22. `INSTALLATION_GUIDE.md:3` — `Version 2.25.0 — Universal AC-Driven Gate` → `Version 2.29.1 — Pack System Unification`
23. `INSTALLATION_GUIDE.md:47` — `应显示 2.25.0` → `应显示 2.29.1`
24. `.claude/skills/tad-help/SKILL.md:17` — `v2.25.0` → `v2.29.1`
25. `.claude/skills/tad-help/SKILL.md:221` — `TAD v2.25.0 Highlights` → `TAD v2.29.1 Highlights`

**Historical 2.25.0 refs — DO NOT TOUCH (factual milestone statements):**
- `AGENTS.md:9` — "since v2.25.0" (Codex first-class platform date)
- `docs/MULTI-PLATFORM.md:14` — "since v2.25.0" (same milestone)
- `.tad/codex/README.md:3` — "since v2.25.0" (same milestone)

**tad-help Highlights content update:** Replace the 2.25.0 highlight list (lines 222-226) with current release highlights:
```
## TAD v2.29.1 Highlights
- **Pack System Unification**: YAML Domain Packs retired; Capability Packs are the sole active pack system
- **Installer Single-Sourcing**: 7 pack installers now copy prebuilt SKILL.md (byte-identical Claude/Codex)
- **Platform-Skills Verifier**: `release-verify.sh platform-skills` checks framework skill symmetry at release
- **Self-Evolution Pruning**: dream/evolve/optimize retired by measurement; 3-tier skill formalization live
- **Feedback Collector**: structured human feedback for non-code artifacts (overlay model, /playground deprecated)
```

### Phase 3: CHANGELOG Entry

Add `[2.29.1]` section at top of CHANGELOG.md (before `[2.29.0]`):

```markdown
## [2.29.1] - 2026-06-11

### New Features
- **Pack System Unification (3 phases)**: retired YAML Domain Packs as active runtime/sync mechanism; installer single-sourcing for 7 target packs (prebuilt SKILL.md, byte-identical Claude/Codex output); `release-verify.sh platform-skills` verifier for framework-owned skill symmetry with FR7 local-skill INFO exceptions

### Documentation
- Fixed INSTALLATION_GUIDE.md and tad-help/SKILL.md version references (stuck at 2.25.0 since v2.26.0)
- Updated docs/MULTI-PLATFORM.md and docs/CODEX-USER-GUIDE.md: SKILL.md Capability Packs declared as sole active pack system
```

### Phase 4: Codex Parity Sync

After all changes to `.claude/skills/tad-help/SKILL.md`:
- Copy the updated file to `.agents/skills/tad-help/SKILL.md` (maintain byte-parity)
- Verify: `bash .tad/hooks/lib/release-verify.sh parity "$PWD"` → exit 0

### Phase 5: Version Gate Verification

Run: `bash .tad/hooks/lib/release-verify.sh version "$PWD" "2.29.1" "2.29.0"`
- Expected: **exit 1 with exactly 15 known false-positives** (14 × sync-registry.yaml `last_synced_version` + 1 × config.yaml:294 version_history key)
- These are correctly excluded from bumping — sync-registry updates post-sync, config.yaml:294 is historical
- Verify: the ONLY stale hits are in `sync-registry.yaml` and `config.yaml:294`. Any other file = real stale ref, fix it
- Verification command: `bash .tad/hooks/lib/release-verify.sh version "$PWD" "2.29.1" "2.29.0" 2>&1 | grep -v 'sync-registry.yaml' | grep -v 'config.yaml:294' | grep '❌ STALE'` → should produce zero lines

### DO NOT TOUCH

- `.tad/sync-registry.yaml` — versions update post-sync, not at release (14 refs will show as stale — expected)
- `.tad/config.yaml:294` (`v2.29.0:`) — version_history entry key (historical record, NOT a live version ref)
- README.md version history entries for v2.29.0 — line ~90 bullet + line ~301 table row (both historical)
- AGENTS.md:9, docs/MULTI-PLATFORM.md:14, .tad/codex/README.md:3 — "since v2.25.0" milestone statements

---

## 7. File Structure

### 7.1 Files to Modify
```
.tad/version.txt                           # Version string
.tad/config.yaml                           # 2 version refs + description pack count + last_updated
package.json                               # version field (stuck at 2.25.0)
tad.sh                                     # TARGET_VERSION
.tad/hooks/lib/migration-engine.sh         # ENGINE_VERSION
README.md                                  # 3 version refs
INSTALLATION_GUIDE.md                      # 2 refs (stuck at 2.25.0)
CHANGELOG.md                               # New [2.29.1] entry
docs/CODEX-USER-GUIDE.md                   # 2 refs
docs/MULTI-PLATFORM.md                     # 2 refs
docs/codex-guide.html                      # 3 refs
tad-intro-feedback.html                    # 2 refs
tad-intro.html                             # 2 refs
.claude/skills/tad-help/SKILL.md           # 2 refs + highlights (stuck at 2.25.0)
.agents/skills/tad-help/SKILL.md           # Parity copy from .claude/skills
```

---

## 8. Testing Requirements

### 8.4 Friction Preflight

No friction-sensitive prerequisites identified. All tools (release-verify.sh, derive-sync-set.sh) are local shell scripts already present.

### 8.5 Feedback Collection

N/A (code-only release task)

---

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | Zero unexpected stale 2.29.0 refs | post-impl-verifiable | `bash .tad/hooks/lib/release-verify.sh version "$PWD" "2.29.1" "2.29.0" 2>&1 \| grep -v 'sync-registry.yaml' \| grep -v 'config.yaml:294' \| grep -c '❌ STALE'` | `0` (only sync-registry + config.yaml:294 remain) | (post-impl) |
| AC2 | version.txt correct | post-impl-verifiable | `cat .tad/version.txt` | `2.29.1` | (post-impl) |
| AC3 | config.yaml version correct | post-impl-verifiable | `grep '^version:' .tad/config.yaml` | `version: 2.29.1` | (post-impl) |
| AC4 | No stale 2.25.0 refs in INSTALLATION_GUIDE | post-impl-verifiable | `grep -c '2\.25\.0' INSTALLATION_GUIDE.md` | `0` | (post-impl) |
| AC5 | No stale 2.25.0 refs in tad-help | post-impl-verifiable | `grep -c '2\.25\.0' .claude/skills/tad-help/SKILL.md` | `0` | (post-impl) |
| AC10 | package.json version correct | post-impl-verifiable | `grep '"version"' package.json` | `"version": "2.29.1"` | (post-impl) |
| AC11 | config.yaml description pack count | post-impl-verifiable | `grep 'description:' .tad/config.yaml \| grep -o '[0-9]* [Cc]apability'` | `25 Capability` | (post-impl) |
| AC6 | Codex parity holds | post-impl-verifiable | `bash .tad/hooks/lib/release-verify.sh parity "$PWD"` | exit 0, VERDICT: parity PASS | (post-impl) |
| AC7 | CHANGELOG has 2.29.1 entry | post-impl-verifiable | `grep -c '^\#\# \[2\.29\.1\]' CHANGELOG.md` | `1` | (post-impl) |
| AC8 | tad.sh TARGET_VERSION correct | post-impl-verifiable | `grep 'TARGET_VERSION=' tad.sh` | `TARGET_VERSION="2.29.1"` | (post-impl) |
| AC9 | Change scope as planned | post-impl-verifiable | `git diff --stat` | only §7 files changed | (post-impl) |

---

## 9.2 Expert Review Status

### Experts Selected

1. **code-reviewer** — version string coverage completeness, AC verification command correctness
2. **backend-architect** — version gate architecture, Codex parity scope, migration manifest gap

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0: AC1 structurally impossible — sync-registry (14) + config.yaml:294 (1) not in version gate exclusion list → exit 1 even after correct impl | AC1 rewritten to filter known false-positives via grep -v; Phase 5 expected output corrected | Resolved |
| code-reviewer | P0: 2.25.0 historical refs in AGENTS.md/MULTI-PLATFORM.md/codex/README.md not called out → risk of accidental bump | §6 Phase 2 "DO NOT TOUCH" sub-list added for 3 historical milestone refs | Resolved |
| code-reviewer | P1: config.yaml §7.1 comment said "3 version refs" but only 2 version refs + description + last_updated | §7.1 comment corrected to "2 version refs + description pack count + last_updated" | Resolved |
| backend-architect | P0: package.json stuck at 2.25.0 — not in handoff | Added as Phase 2 item #21 + AC10 + §7.1 file list | Resolved |
| backend-architect | P0: AC1 exit 0 impossible (same root cause as code-reviewer P0) | Same fix as code-reviewer P0 above | Resolved |
| backend-architect | P1: config.yaml description says "24 capability packs" but registry has 25 | Added as Phase 1 item #4 + AC11 + FR7 | Resolved |
| backend-architect | P1: CHANGELOG "New Features" section for a patch release — internal consistency | Noted; this is a judgment call — the work was done post-v2.29.0 tag, so it belongs in v2.29.1 CHANGELOG regardless of semver label | Deferred (human decision) |

### Overall Assessment (post-integration)

- code-reviewer: CONDITIONAL PASS → **PASS after P0 fixes** (2 P0 resolved, 1 P1 resolved)
- backend-architect: CONDITIONAL PASS → **PASS after P0 fixes** (2 P0 resolved, 2 P1 resolved, 1 P1 deferred)

---

## 10. Important Notes

### 10.1 Critical Warnings
- Do NOT bump sync-registry.yaml versions — that happens during *sync
- Do NOT change the v2.29.0 version_history key in config.yaml:294 (historical record)
- The README.md version history entries for v2.29.0 stay as-is (line ~90 bullet + line ~301 table row)
- After modifying tad-help/SKILL.md, MUST copy to .agents/skills/ for parity

### 10.2 Commit Message
```
chore: release v2.29.1 — Pack System Unification + stale version fixes
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-11
**Version**: 3.1.0
