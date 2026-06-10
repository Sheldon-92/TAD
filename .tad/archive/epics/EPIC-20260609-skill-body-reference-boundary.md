# Epic: SKILL Body vs Reference Boundary Redesign

**Epic ID**: EPIC-20260609-skill-body-reference-boundary
**Created**: 2026-06-09
**Owner**: Alex
**Promoted from**: IDEA-20260609-skill-body-reference-boundary

---

## Objective

Audit all 36 reference files (Alex 31 + Blake 5), classify each as "must body" or "reference OK" using the criterion "will the agent unknowingly violate process if it doesn't proactively read this?", inline the "must body" content back into SKILL body files, add automated regression checks, and sync to all 14 downstream projects.

## Success Criteria

- [ ] All 36 references audited with human-confirmed classification
- [ ] "Must body" content inlined back into Alex/Blake SKILL.md — zero execution-discipline content left in references/
- [ ] Automated checker script validates keyword+structural integrity on every release
- [ ] Codex dogfood confirms Blake no longer skips Layer 2 / Gate 3 / completion report
- [ ] Claude Code compact test confirms no regression
- [ ] New principle recorded in principles.md
- [ ] v2.27.0 released and synced to 14 projects

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Audit & Classification | ✅ Done | HANDOFF-20260609-skill-body-reference-audit.md | 3 must-body (Blake), 33 reference-ok, Circular Trigger Pattern discovered |
| 2 | Inline & Automation | ✅ Done | HANDOFF-20260609-skill-body-inline.md | Blake SKILL 737→2005 lines, checker script, Circular Trigger principle (commit 6482af9) |
| 3 | Verify & Sync | ✅ Done | HANDOFF-20260609-verify-and-sync.md | v2.27.0 released (tags 8655d39+5c0be73+a582412), 14/14 synced, checker hardened, 人话版 rules rewritten |

### Phase Dependencies
All phases are sequential: Phase 1 → Phase 2 → Phase 3.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Audit & Classification

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Audit all 36 reference files across Alex (31) and Blake (5). For each reference, apply the judgment criterion: "If the agent does NOT proactively read this reference, will it unknowingly violate the process?" Produce a classification table with rationale. NOT in scope: modifying any SKILL files or reference files — this phase is read-only analysis.

#### Input
- `.claude/skills/alex/references/` (31 files)
- `.claude/skills/blake/references/` (5 files)
- `.claude/skills/alex/SKILL.md` (body stubs with load_when)
- `.claude/skills/blake/SKILL.md` (body stubs with load_when)
- IDEA-20260609-skill-body-reference-boundary.md (judgment criterion)
- Codex dogfood evidence: Blake skipped Layer 2, Gate 3 checklist, completion report format

#### Output
- Classification table: 36 rows × columns (file, agent, category: must-body/reference-ok, rationale, key content summary)
- Human-confirmed "must body" list

#### Acceptance Criteria
- [ ] All 36 reference files individually assessed with written rationale (no batch "all OK" shortcuts)
- [ ] Classification uses the single criterion: "unknowing violation if unread?" — Yes → must-body, No → reference-ok
- [ ] At minimum, these 3 known-broken refs classified as must-body: blake/execution-checklist.md, blake/completion-protocol.md, blake/ralph-loop.md (Codex dogfood evidence)
- [ ] Human reviews and confirms the "must body" list before Phase 2 begins
- [ ] Output stored in `.tad/evidence/designs/` as the Phase 1 audit artifact
- [ ] Scope verification uses task-scoped paths because the repository has unrelated dirty worktree state; no `.claude/skills/` files modified
- [ ] Completeness verification compares audit headings against `find ... -exec basename`, not multi-directory `ls` output

#### Files Likely Affected
- `.tad/evidence/designs/skill-body-reference-audit.md` (CREATE)

#### Dependencies
None (first phase)

#### Notes
- Blake performs the audit under Alex's methodology; human confirms the "must body" subset (per Socratic decision + Arch-P0-2 fix)
- The 3 Blake refs are near-certain "must body" based on Codex evidence; Alex refs need fresh analysis
- Watch for Alex refs that look like "explicit trigger" but actually contain discipline rules embedded within (e.g., does handoff-creation-protocol.md contain expert review MUST rules that could be silently skipped?)
- Phase 1 handoff AC7/AC8 were updated after Codex review: AC7 is task-scoped due to pre-existing dirty worktree; AC8 uses `find ... -exec basename` to avoid `ls` multi-directory headings.

---

### Phase 2: Inline & Automation

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Inline all confirmed "must body" reference content back into the respective SKILL.md body files. Create an automated checker script that verifies execution-discipline keywords remain in body on every release. Add a new principle to principles.md documenting the body/reference boundary rule. NOT in scope: platform testing or sync — those are Phase 3.

#### Input
- Phase 1 output: confirmed "must body" classification table
- Current SKILL.md files (Alex body 1485 lines, Blake body 737 lines)
- Current reference files to be inlined
- Existing release-verify.sh patterns

#### Output
- Modified `.claude/skills/alex/SKILL.md` with inlined execution discipline content
- Modified `.claude/skills/blake/SKILL.md` with inlined execution discipline content
- Deleted reference files that were fully inlined (or kept as redirect stubs if partially inlined)
- `.tad/hooks/lib/skill-body-verify.sh` (CREATE) — automated checker
- Updated `.tad/project-knowledge/principles.md` with new principle entry

#### Acceptance Criteria
- [ ] Every "must body" reference's content present in the corresponding SKILL.md body — `diff` verification against Phase 1 list
- [ ] No "reference OK" file accidentally modified or deleted
- [ ] `skill-body-verify.sh` passes when run against modified SKILL files
- [ ] `skill-body-verify.sh` FAILS when a known execution-discipline keyword is manually removed (false-negative test)
- [ ] Safety keyword count (Alex 142 + Blake 114 = 256) maintained or increased — zero loss
- [ ] New principle in principles.md: "Execution Discipline Content Must Stay in SKILL Body"
- [ ] SKILL files pass syntax/structure sanity check (no broken YAML, no orphan stubs pointing to deleted refs)

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` (MODIFY)
- `.claude/skills/blake/SKILL.md` (MODIFY)
- `.claude/skills/alex/references/*.md` (DELETE — must-body files only)
- `.claude/skills/blake/references/*.md` (DELETE — must-body files only)
- `.tad/hooks/lib/skill-body-verify.sh` (CREATE)
- `.tad/project-knowledge/principles.md` (MODIFY)

#### Dependencies
Phase 1 (confirmed classification table)

#### Notes
- No body size red line — quality chain completeness > file size
- Inlining strategy: insert content at the location of the existing stub (replace reference/load_when block with actual content)
- If a reference is partially "must body" (some sections discipline, some trigger-only), split: inline discipline parts, keep trigger parts as reference
- Safety keyword count is the non-negotiable regression gate (same pattern as v2.26.0 progressive loading)

---

### Phase 3: Verify & Sync

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Dual-platform verification: test modified SKILL files on both Claude Code (compact scenario) and Codex (dogfood). Run automated checker. Release as v2.27.0 and sync to all 14 downstream projects. NOT in scope: further SKILL modifications — if verification fails, loop back to Phase 2 for fixes.

#### Input
- Phase 2 output: modified SKILL files + checker script
- GEN food project (Codex dogfood target)
- 14 registered sync projects
- release-verify.sh + skill-body-verify.sh

#### Output
- Codex dogfood report: Blake completes full flow (Layer 2 + Gate 3 + completion report)
- Claude Code compact test report: no regression after context compression
- Codex regression harness report: `$alex activation → handoff → $blake implementation → Gate 3 → Gate 4 → trace/evidence`
- Updated multi-platform documentation removing stale "Codex as specialized executor" language
- v2.27.0 release (tag + changelog)
- 14 projects synced to v2.27.0

#### Acceptance Criteria
- [ ] Codex dogfood: Blake on GEN food project follows Layer 2 (≥2 expert review), writes Gate 3 checklist, produces completion report — all previously skipped items now executed
- [ ] Codex full-cycle regression harness passes end-to-end at least once; n=3 stability run is recommended and recorded if time permits
- [ ] Claude Code: After compact (long conversation), Blake still follows execution discipline from body content
- [ ] `skill-body-verify.sh` passes in CI-equivalent check
- [ ] `release-verify.sh` passes (version consistency, structural diff)
- [ ] `docs/MULTI-PLATFORM.md` updated to v2.27 reality: Codex is a first-class platform, not only a specialized executor
- [ ] v2.27.0 tagged and pushed
- [ ] `*sync` completes for all 14 projects with `diff -rq` verification

#### Files Likely Affected
- `version.txt` (MODIFY — bump to 2.27.0)
- `CHANGELOG.md` (MODIFY)
- `docs/MULTI-PLATFORM.md` (MODIFY — remove stale specialized-executor framing)
- `.tad/evidence/dogfood/` (CREATE — test reports)
- `.tad/evidence/codex-regression/` (CREATE — full-cycle regression harness evidence)

#### Dependencies
Phase 2 (modified SKILL files + checker script)

#### Notes
- Codex dogfood is the critical acceptance test — it's where the original failure was observed
- Full-cycle regression should validate the actual quality chain, not just activation: handoff creation, Blake implementation, Layer 2, Gate 3, Gate 4, and trace/evidence presence.
- Claude Code compact test is informational but important — answers the open question from Socratic inquiry
- If Codex dogfood still fails after inlining, investigate whether the problem is deeper than reference loading (e.g., SKILL body size exceeding Codex context window)
- Sync must use the deny-list mechanism (v2.26.0 pattern), not hardcoded paths
- Do NOT add `.codex/config.toml` policy or `.codex/agents/` migration to this P0 Epic. Those are tracked as follow-up platform hardening to avoid delaying the quality-chain fix.

---

## Context for Next Phase

### Completed Work Summary
- Phase 1: Audited all 36 refs. Result: 3 must-body (Blake), 33 reference-ok, 0 partial-body. Circular Trigger Pattern discovered.
- Phase 2: Inlined 3 Blake refs (1280 lines). Blake SKILL 737→2005 lines. Checker script created. .agents/ mirror synced. Principle recorded (14/15). Commit 6482af9.

### Decisions Made So Far
- Binary classification: "must body" vs "reference OK" — delayed loading abandoned as unreliable
- No body size red line — quality chain completeness takes priority
- Automated regression checker required (keyword + structural integrity)
- New principle in principles.md for prevention
- Fix then sync immediately (P0 quality chain break)

### Known Issues / Carry-forward
- Claude Code compact behavior unknown — Phase 3 will determine if it's also affected
- 4 active Epics reduced to 2 by parking security-domain-pack-chain + goal-driven-research
- Follow-up needed after v2.27: Codex Native Runtime Hardening (`.codex/config.toml`, `.codex/agents/`, native review/MCP/cloud strategy) — tracked as IDEA-20260609-codex-native-runtime-hardening.md

### Next Phase Scope
Phase 1: Read-only audit of all 36 reference files with classification table.

---

## Notes
- This Epic is a corrective action for EPIC-20260608-skill-progressive-loading
- Same failure class as v2.7 quality chain failure (principles.md entry exists)
- Idea source: IDEA-20260609-skill-body-reference-boundary.md
