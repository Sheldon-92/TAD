# Epic: Claude Science Skill Architecture Borrowing

**Epic ID**: EPIC-20260703-claude-science-skill-architecture
**Created**: 2026-07-03
**Owner**: Alex
**Research Source**: Claude Science (Anthropic, launched 2026-06-30) — coordinating agent + 60+ skills + reviewer agent workbench for scientists

---

## Objective
Borrow 4 architectural patterns from Claude Science's skill system to upgrade TAD: open-standard alignment for cross-platform compatibility, description-based semantic discovery, pipeline-to-skill auto-capture, and provenance-tracked artifacts. Goal is not to replicate Claude Science but to adopt its proven patterns where they solve existing TAD friction.

## Success Criteria
- [ ] 25 Capability Packs' name/description fields comply with Anthropic SKILL.md open standard
- [ ] Intent router uses description semantic matching with ≥80% accuracy on 10 real task descriptions
- [ ] Blake workflow completion offers one-key SCAND generation for successful workflows
- [ ] Completion report template includes structured provenance section

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | SKILL.md Open Standard Alignment | ✅ Done | HANDOFF-20260703 | 27 Packs with Anthropic-compliant name/description |
| 2 | Description-based Skill Discovery | ✅ Done | HANDOFF-20260703 | Intent router semantic matching + 12-case eval 100% |
| 3 | Pipeline → Skill Auto-Capture | ✅ Done | HANDOFF-20260703 | Workflow completion → auto-gen SCAND with 13-field mapping |
| 4 | Provenance Auditable Artifacts | ✅ Done | HANDOFF-20260703 | Completion report provenance section + self-dogfood |

### Phase Dependencies
- Phase 2 depends on Phase 1 (needs standardized descriptions to do semantic matching)
- Phase 3 and Phase 4 are independent of each other and can run after Phase 1
- Recommended order: 1 → 2 → 3 → 4 (but 3 and 4 could swap)

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: SKILL.md Open Standard Alignment

**Status:** ✅ Done
**Execution:** Semi-auto (commit cda7732)

#### Scope
Audit and update all 25 Capability Pack SKILL.md files to comply with Anthropic's open SKILL.md standard. This means: `name` field ≤64 chars, lowercase letters/numbers/hyphens only, no reserved words; `description` field ≤1024 chars, non-empty, third-person, includes "what it does" AND "when to use it". NOT in scope: changing SKILL.md body content, changing references/ structure, or modifying non-Pack skills (alex, blake, gate, etc. are TAD framework skills, not Packs).

#### Input
- Current 25 Capability Pack SKILL.md files (all have name/description already)
- Anthropic standard spec: platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- Anthropic best practices: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

#### Output
- 25 updated SKILL.md files with compliant frontmatter
- Audit report: before/after for each Pack (name changes, description changes, char counts)
- Keyword preservation check: verify existing intent-router keyword matching still works after description changes

#### Acceptance Criteria
- [ ] AC1: All 25 Pack `name` fields pass validation: ≤64 chars, `[a-z0-9-]` only, no "anthropic"/"claude"
- [ ] AC2: All 25 Pack `description` fields pass validation: ≤1024 chars, non-empty, no XML tags
- [ ] AC3: All descriptions follow Anthropic best practice: third-person, includes "what + when", no vague terms ("helper", "utils")
- [ ] AC4: Before/after keyword matching test: run 10 task descriptions through intent router step4_5, verify same packs match as before (regression test)
- [ ] AC5: .agents/skills/ parity maintained (Codex mirror updated if applicable)

#### Files Likely Affected
- .claude/skills/{25-pack-names}/SKILL.md (MODIFY — frontmatter only)
- .agents/skills/{25-pack-names}/SKILL.md (MODIFY — parity)
- .tad/evidence/acceptance-tests/claude-science-p1/ (CREATE — audit report)

#### Dependencies
None (can execute independently)

#### Notes
- Risk: changing descriptions could break existing keyword matching in step4_5. Mitigation: AC4 regression test.
- Some descriptions already include Chinese characters (capability-upgrade) — decide whether to keep bilingual or standardize to English-only for cross-platform compatibility.
- academic-research description includes "Activates on: ..." keyword list — this is useful for matching but non-standard. Decide whether to keep as part of description or move to a separate mechanism.

### Phase 2: Description-based Skill Discovery

**Status:** ✅ Done
**Execution:** Semi-auto (commit ab092b3)

#### Scope
Upgrade intent router step4_5 from keyword-list matching (pack-registry.yaml) to description-based semantic matching. The LLM already does semantic matching but against a keyword list; this phase changes it to match against the full description field directly from SKILL.md. Also create a discriminative eval with 10 real task descriptions to measure matching accuracy. NOT in scope: changing step1_5b in *design (it has its own confirmation flow), or changing Blake's 1_5a pack detection.

#### Input
- Phase 1 output: 25 Packs with standardized descriptions
- Current intent-router-protocol.md step4_5 implementation
- pack-registry.yaml (current keyword-based registry)

#### Output
- Updated intent-router-protocol.md step4_5 (description-based matching)
- Discriminative eval fixture: 10 task descriptions → expected pack matches
- Eval results: ≥80% accuracy
- Decision: whether to deprecate pack-registry.yaml keywords or keep as fallback

#### Acceptance Criteria
- [ ] AC1: step4_5 reads description directly from SKILL.md instead of pack-registry.yaml keywords
- [ ] AC2: Discriminative eval with 10 real task descriptions achieves ≥80% accuracy (correct pack matched)
- [ ] AC3: False positive rate ≤20% (packs loaded that shouldn't be)
- [ ] AC4: Max 2 packs per session limit preserved
- [ ] AC5: No user-facing latency regression (step4_5 remains "lightweight and silent")

#### Files Likely Affected
- .claude/skills/alex/references/intent-router-protocol.md (MODIFY — step4_5)
- .tad/eval/pack-discovery-eval.md (CREATE — discriminative eval fixture)
- .tad/evidence/acceptance-tests/claude-science-p2/ (CREATE — eval results)

#### Dependencies
Phase 1 (needs standardized descriptions)

#### Notes
- Risk: semantic matching may be slower than keyword matching. Mitigation: AC5 latency check.
- Risk: false triggers loading irrelevant packs. Mitigation: AC3 false positive gate.
- Decision needed: deprecate pack-registry.yaml entirely or keep as fallback? If descriptions are good enough, the registry becomes redundant.

### Phase 3: Pipeline → Skill Auto-Capture

**Status:** ✅ Done
**Execution:** Semi-auto (commit 37e5028)

#### Scope
Add a "Save as reusable skill?" option to Blake's workflow completion trigger (triple-question KA). When user confirms, auto-generate a SCAND (skillify candidate) file with proper SKILL.md-compatible frontmatter and extracted steps. This extends the existing T1/T2/T3 system by lowering the barrier to capture. NOT in scope: auto-deploying captured skills (they still go through human review via *harvest), or changing the T1 ceremony itself.

#### Input
- Blake's workflow_completion_trigger (triple-question KA) in Alex SKILL.md
- Blake's skillify_evaluation step 5 (T1 ceremony)
- SCAND template (.tad/templates/)
- Workflow results from the Workflow tool

#### Output
- Updated workflow_completion_trigger with "Save as skill?" option
- Auto-SCAND generation logic (extract workflow pattern → SCAND file)
- Template for auto-generated SCAND with Anthropic-standard frontmatter

#### Acceptance Criteria
- [ ] AC1: After successful Workflow completion (agent_count ≥ 3), user is offered "Save as reusable skill?"
- [ ] AC2: If accepted, SCAND file auto-generated at .tad/active/skillify-candidates/SCAND-{date}-{slug}.md
- [ ] AC3: Generated SCAND has Anthropic-standard name/description in frontmatter
- [ ] AC4: Generated SCAND captures the workflow pattern (not raw prompts) — variabilizable
- [ ] AC5: "Skip" option available (not forced)

#### Files Likely Affected
- .claude/skills/alex/references/workflow-completion-trigger.md (MODIFY)
- .tad/templates/scand-auto-template.md (CREATE)
- .tad/evidence/acceptance-tests/claude-science-p3/ (CREATE)

#### Dependencies
None (independent of Phase 1/2, but recommended after Phase 1 for description format consistency)

#### Notes
- This ONLY generates a draft SCAND — it does NOT bypass T1/T2/T3 review. The human still decides via *harvest.
- Key design question: how to "variabilize" a workflow? Claude Science saves the pipeline as-is; TAD should abstract episode-specific values per Knowledge Recording principle.

### Phase 4: Provenance Auditable Artifacts

**Status:** ✅ Done
**Execution:** Semi-auto (commit 3633796)

#### Scope
Add a structured `provenance` section to Blake's completion report template. For each key artifact produced during implementation, record: what was generated, which command/code produced it, which sub-agent was involved, and environment info. Lightweight — just a new template section, not a full lineage tracking system. NOT in scope: retroactive provenance for existing completions, or building a provenance query system.

#### Input
- Blake's completion report template
- Claude Science's provenance model (code + env + conversation bundled per artifact)
- Existing .tad/evidence/ structure

#### Output
- Updated completion report template with provenance section
- Blake SKILL.md updated to populate provenance during execution
- Example provenance from a real completion

#### Acceptance Criteria
- [ ] AC1: Completion report template has a `## Provenance` section with structured format
- [ ] AC2: Format includes: artifact path → generating command → sub-agent used → environment notes
- [ ] AC3: Blake SKILL.md instructs Blake to fill provenance section during Layer 2
- [ ] AC4: Gate 3 checklist updated to verify provenance section is non-empty
- [ ] AC5: First real completion after this Phase includes populated provenance

#### Files Likely Affected
- .tad/templates/completion-report-template.md (MODIFY)
- .claude/skills/blake/SKILL.md (MODIFY — provenance instruction)
- .tad/gates/gate-canonical-checklist.md (MODIFY — Gate 3 item)
- .tad/evidence/acceptance-tests/claude-science-p4/ (CREATE)

#### Dependencies
None (independent of other phases)

#### Notes
- Keep it lightweight. Claude Science bundles full environment snapshots; TAD just needs structured metadata.
- Risk: Blake might fill provenance mechanically ("used code-reviewer") without useful detail. Mitigation: AC2 format requires specific command, not just agent name.

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
- Phase 1: 27 Capability Pack SKILL.md frontmatter standardized to Anthropic open standard (commit cda7732). 8 descriptions rewritten, 19 verified, three-copy parity maintained, pack-registry.yaml regenerated.
- Phase 2: Intent router step4_5 switched from keyword to description matching (commit ab092b3). 12-case eval 100% (8 direct + 3 indirect + 1 negative). Note block documents mechanism divergence vs step1_5b.
- Phase 3: Workflow completion trigger auto-generates SCAND on Q2/Q3 "yes" (commit 37e5028). 13-field frontmatter mapping, 4-gate booleans = ~ (deferred to *harvest), variabilize test gate, dual-yes handling with type suffix, skip option.
- Phase 4: Completion report template has Provenance section (commit 3633796). step3d_provenance in Blake SKILL.md body, Gate 3 advisory check, self-dogfood in P4's own completion report.

### Decisions Made So Far
- Phase order: D→B→A→C (D is foundation, B depends on D, A and C are independent)
- Exclusions: no Gate changes, no Alex/Blake merge, no VM env, no science domain skills
- Provenance is lightweight (template section, not full lineage system)
- D1: Chinese activation keywords converted to English in description (cross-platform compat)
- D5: CAPABILITY.md included in three-copy parity (pack-registry.yaml regenerated via scan-packs.sh)
- D6: Pack count is 27 (video-creation + web-ui-design confirmed as Packs by expert review)

### Known Issues / Carry-forward
- 3 Packs missing CAPABILITY.md (agent-computer-interface, agent-skill-evolution, reading-companion) — pre-existing gap, not blocking
- pack-registry.yaml may become redundant after Phase 2 — deferred decision
- keywords field in frontmatter kept as-is (not part of Anthropic standard, Phase 2 will address)

### Next Phase Scope
Phase 4: Provenance Auditable Artifacts — add structured provenance section to completion report template, track artifact → command → sub-agent → environment.

---

## Notes
- Research source: Claude Science workbench (Anthropic, 2026-06-30)
- Key insight: "workflow > model" — Claude Science differentiates through skill architecture, not model power. TAD shares this philosophy.
- This Epic borrows patterns only, not domain content. TAD remains a general-purpose methodology framework.
