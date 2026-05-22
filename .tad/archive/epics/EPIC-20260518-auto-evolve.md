# Epic: TAD Auto-Evolve — Self-Improving Agent Framework

**Epic ID**: EPIC-20260518-auto-evolve
**Created**: 2026-05-18
**Owner**: Alex

---

## Objective
Enable TAD to automatically learn from its own execution history and evolve its rules, knowledge, and protocols without requiring manual human intervention for every improvement cycle. Two tracks: Track A (framework-level evolve across 15 projects) and Track B (project-level knowledge accumulation within each project).

## Success Criteria
- [ ] Blake automatically reflects on failures during Ralph Loop (Reflexion pattern), producing structured diagnoses that feed into retries
- [ ] *dream auto-triggers via cron + SessionStart combination (24h timer), scanning session logs for corrections/failures and generating candidate playbooks
- [ ] Trace schema upgraded to decision-level with sampling/compression, supporting automated pattern detection
- [ ] *optimize produces actionable lifecycle health proposals from real trace data (not waiting for nonexistent event types)
- [ ] Clear separation: framework-level improvements (org-store → *sync) vs project-level knowledge (project-store → local only)

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Trace Infrastructure | ✅ Done | HANDOFF-20260518-auto-evolve-phase1-trace.md | Decision-level trace schema + writer + sampling/compression |
| 2 | Blake Reflexion | ✅ Done | HANDOFF-20260519-auto-evolve-phase2-reflexion.md | Structured post-failure reflection in Ralph Loop Layer 1 |
| 3 | Dream Upgrade | ✅ Done | HANDOFF-20260519-auto-evolve-phase3-dream.md | Auto-trigger + session log scanning + candidate playbook generation |
| 4 | Optimize/Evolve Redesign | ✅ Done | HANDOFF-20260520-auto-evolve-phase4-optimize.md | Automated pattern detection + three-store proposal classification |

### Phase Dependencies
Sequential: Phase 1 → Phase 2 → Phase 3 → Phase 4.
- Phase 2 depends on Phase 1 (Reflexion writes to new trace schema)
- Phase 3 depends on Phase 1 (Dream reads new trace data) and Phase 2 (learns from Reflexion outputs)
- Phase 4 depends on all previous phases (aggregates all new data types)

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Trace Infrastructure

**Status:** ✅ Done
**Execution:** complete (commit 4740def, archived 2026-05-19)

#### Scope
Upgrade TAD's trace system from file-level events (4 types: handoff_created, task_completed, evidence_created, domain_pack_step) to decision-level events that capture why agents made specific choices. Add sampling/compression: failed paths recorded in full detail, success paths as summaries. Add trace rotation/archival mechanism.

NOT in scope: changing what Alex/Blake do with traces (that's Phases 3-4). NOT in scope: cross-project trace aggregation (that's Phase 4).

#### Input
- Existing trace infrastructure: `.tad/evidence/traces/*.jsonl` (702+ entries in toy project)
- Research findings: notebook query on trace schema requirements (decision-level minimum)
- Existing hook infrastructure: `.tad/hooks/lib/trace-step.sh` (currently unwired)

#### Output
- New trace schema definition (YAML): event types, required fields, optional fields
- Trace writer library (shell functions Blake's hooks can call)
- Sampling/compression rules: what gets full trace vs summary
- Trace rotation config: max size per project, archival policy
- Actor tag field on all trace entries (human-stated vs agent-inferred)

#### Acceptance Criteria
- [ ] Trace schema has ≥6 event types: gate_result, expert_review_finding, reflexion_diagnosis, decision_point, tool_call_outcome, knowledge_extraction
- [ ] Each trace entry has actor_tag field (values: human_confirmed, agent_inferred, agent_verified)
- [ ] Failed paths (gate_result=FAIL, tool_call_outcome=error) recorded with full context (≤2KB per event)
- [ ] Success paths recorded as 1-line summary (≤200 bytes per event)
- [ ] Trace rotation: files older than 90 days auto-archived to `.tad/archive/traces/`
- [ ] Backward compatible: existing 4 event types still work, new types are additive

#### Files Likely Affected
- `.tad/schemas/trace-schema.yaml` (CREATE)
- `.tad/hooks/lib/trace-writer.sh` (CREATE)
- `.tad/hooks/lib/trace-rotate.sh` (CREATE)
- `.tad/config.yaml` trace section (MODIFY)
- `.claude/skills/blake/SKILL.md` trace integration points (MODIFY)

#### Dependencies
None (can execute independently)

#### Notes
- trace-step.sh exists but was never wired. Evaluate reuse vs replace.
- The lifecycle-health handoff (HANDOFF-20260517) is redesigning *optimize to work with existing 4 types — this Phase adds new types on top, not replacing that work.
- Risk: decision-level trace in a single long session could produce large files. Sampling rule is the mitigation.

### Phase 2: Blake Reflexion

**Status:** ✅ Done
**Execution:** complete (commit f5489e4, archived 2026-05-19)

#### Scope
Embed the Reflexion pattern (verbal reinforcement learning) into Blake's Ralph Loop. When Layer 1 self-check fails, instead of immediately retrying or escalating, Blake pauses to produce a structured diagnosis: what failed, why, and what to try differently. This diagnosis is written to the new trace schema (reflexion_diagnosis event) and feeds into the retry context.

NOT in scope: changing Gate 3 structure. NOT in scope: ToolObserver-style cross-session tool doc improvement (that's Phase 3/4 territory). NOT in scope: changing when circuit breaker fires (still 3 same errors).

#### Input
- Phase 1 trace schema + writer library
- Existing Ralph Loop in Blake SKILL.md (Layer 1 self-check, Layer 2 expert review, circuit breaker)
- Research findings: Reflexion works with in-context learning, no fine-tuning needed

#### Output
- Modified Ralph Loop: failure → reflection prompt → structured diagnosis → revised retry
- Reflexion prompt template (reusable across different failure types)
- reflexion_diagnosis trace events flowing to JSONL
- Diagnosis format: {what_failed, root_cause_hypothesis, revised_approach, confidence}

#### Acceptance Criteria
- [ ] Blake SKILL.md Ralph Loop Layer 1 has a reflection step between failure detection and retry
- [ ] Reflection produces structured output with 4 fields: what_failed, root_cause_hypothesis, revised_approach, confidence
- [ ] Each reflection writes a reflexion_diagnosis event to trace JSONL via trace-writer.sh
- [ ] Circuit breaker still fires after 3 same errors, but now includes accumulated reflection history in escalation report
- [ ] No regression: successful paths (no failures) have zero additional overhead

#### Files Likely Affected
- `.claude/skills/blake/SKILL.md` Ralph Loop section (MODIFY)
- `.tad/templates/reflexion-prompt.md` (CREATE)
- `.tad/evidence/traces/` reflexion events (new trace data)

#### Dependencies
Phase 1 (needs trace schema + writer)

#### Notes
- Reflexion is pure in-context learning — no model changes, no fine-tuning. It's a structured prompt inserted between failure and retry.
- Risk: reflection adds latency to each retry cycle (~5-10s per reflection). Acceptable trade-off for better retry quality.
- The reflection prompt must be generic enough for different failure types (tsc error, test failure, lint error, expert review P0).

### Phase 3: Dream Upgrade

**Status:** ✅ Done
**Execution:** complete (commit 9b51e1b, archived 2026-05-20)

#### Scope
Upgrade `*dream` from manual format-consolidation to Anthropic Dreaming-style automated knowledge extraction. Three sub-features: (A) auto-trigger via cron + SessionStart, (B) session log scanning (grep for corrections, failures, recurring patterns), (C) candidate playbook generation with human approval gate. Implement three-store layout: working-store (session lessons) → project-store (confirmed project knowledge) with human promotion gate.

NOT in scope: org-store / framework-level promotion (that's Phase 4). NOT in scope: auto-applying candidates without human review.

#### Input
- Phase 1 trace schema (decision-level events to scan)
- Phase 2 reflexion data (failure diagnoses as high-value signals)
- Existing *dream protocol in Alex SKILL.md
- Research findings: Anthropic Dreaming 4-phase (Orient, Gather Signal, Consolidate, Prune)

#### Output
- `/schedule` routine: daily scan of session traces → candidate generation
- SessionStart hook enhancement: display pending candidates on Alex activation
- Session log scanner: grep patterns for user corrections, recurring failures, preference changes
- Candidate playbook format: structured proposals with provenance + confidence
- Three-store awareness: candidates tagged as project-scope or framework-scope

#### Acceptance Criteria
- [ ] A cron routine (`/schedule`) runs daily, scanning `.tad/evidence/traces/*.jsonl` for patterns
- [ ] Candidate playbooks saved to `.tad/active/dream-candidates/` with provenance metadata
- [ ] Alex STEP 3.x displays pending candidates on startup with AskUserQuestion approval flow
- [ ] Scanner detects ≥3 signal types: user corrections, recurring gate failures, reflexion diagnosis patterns
- [ ] Each candidate has scope_tag: "project" or "framework" (framework candidates flagged for *evolve)
- [ ] Human approval required before any candidate is promoted to project-knowledge

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` dream_protocol section (MODIFY)
- `.claude/skills/alex/SKILL.md` STEP 3.x activation (MODIFY)
- `.tad/templates/dream-candidate.md` (CREATE)
- `.tad/hooks/lib/dream-scanner.sh` (CREATE)
- Session log scan patterns config (CREATE)

#### Dependencies
Phase 1 (trace schema), Phase 2 (reflexion data as input)

#### Notes
- Cron routine runs via Claude Code `/schedule` — this is a built-in feature, not a custom daemon.
- The scanner uses grep, not LLM judgment (per Anthropic's approach). LLM judgment only for consolidation.
- Risk: false positive candidates from noisy trace data. Mitigation: confidence threshold + human gate.
- *dream existing functionality (dedup/merge/prune format consolidation) is preserved as a sub-mode.

### Phase 4: Optimize/Evolve Redesign

**Status:** ✅ Done
**Execution:** complete (commit b904c9c, archived 2026-05-20)

#### Scope
Redesign `*optimize` and `*evolve` to consume decision-level trace data and dream candidates. `*optimize` (single project) uses new trace types for richer lifecycle analysis + automated proposal generation. `*evolve` (cross-project) aggregates patterns across projects and classifies them as framework-level vs project-specific using scope_tag. Framework-level proposals fed into *sync pipeline.

NOT in scope: auto-applying framework changes without human review. NOT in scope: changing *sync mechanics.

#### Input
- Phase 1 trace infrastructure (decision-level events across all projects)
- Phase 2 reflexion data (failure patterns)
- Phase 3 dream candidates (with scope_tag classification)
- Existing *optimize and *evolve protocols in Alex SKILL.md

#### Output
- Redesigned *optimize: lifecycle health + decision-pattern analysis + automated proposals
- Redesigned *evolve: cross-project aggregation + framework vs project classification
- Three-store promotion flow: project-store candidates stay local, framework-store candidates → *sync
- Integration with *sync: framework proposals as a new section in sync registry

#### Acceptance Criteria
- [ ] *optimize uses ≥4 new trace types (gate_result, reflexion_diagnosis, decision_point, knowledge_extraction) for analysis
- [ ] *optimize generates proposals targeting SKILL.md sections (not just frozen Domain Pack YAML)
- [ ] *evolve classifies proposals as project-scope vs framework-scope using scope_tag from Phase 3
- [ ] Framework-scope proposals are staged in `.tad/evidence/proposals/framework/` for *sync integration
- [ ] Cross-project aggregation handles trace format versioning (projects may be on different TAD versions)

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` optimize_protocol section (MODIFY)
- `.claude/skills/alex/SKILL.md` evolve_protocol section (MODIFY)
- `.tad/evidence/proposals/framework/` (CREATE directory)
- `.tad/sync-registry.yaml` framework proposals section (MODIFY)

#### Dependencies
Phase 1, Phase 2, Phase 3 (all previous phases)

#### Notes
- The lifecycle-health handoff (HANDOFF-20260517) already redesigns *optimize step2_aggregate for existing 4 types. Phase 4 builds on top of that work, not replacing it.
- Risk: cross-project trace format divergence. Mitigation: trace schema version field + backward-compat reader.
- *evolve has never been actually run. Phase 4 is the first real operationalization.

---

## Context for Next Phase
{Alex updates this section after each *accept, providing context
so the next phase can start without re-explaining everything}

### Completed Work Summary
- Phase 1: Trace Infrastructure — decision-level schema (11 types), trace-writer.sh (5 helpers), trace-rotate.sh (180-day), env-var convention. Commit 4740def.
- Phase 2: Blake Reflexion — reflexion_step in Layer 1, trace_reflexion_diagnosis helper, circuit breaker with reflection history, crash recovery JSONL reload. Commit f5489e4.
- Phase 3: Dream Upgrade — dream-scanner.sh (247 lines, 4-pass grep/jq), STEP 3.56, *dream --auto, double-parse pattern, rotation-safe, test fixtures. Commit 9b51e1b.
- Phase 4: Optimize/Evolve Redesign — 4 new v2 metrics (6-9), dream candidate integration, 3-tier scope classification, *evolve v2 cross-project analysis, MANIFEST.yaml staging. Commit b904c9c.

### Decisions Made So Far
- Two tracks cross-doing: trace infrastructure (shared) → B (Reflexion + Dream) → A (Optimize/Evolve)
- Auto-trigger: cron + SessionStart combination (no session-end hook available)
- Trace granularity: full decision-level with sampling (failed=detailed, success=summary)
- Reflexion: Ralph Loop Layer 1 every failure (not just circuit breaker)
- Human approval gate: candidates displayed, never auto-applied

### Known Issues / Carry-forward
- HANDOFF-20260517-lifecycle-health-improvements is in progress with Blake — it redesigns *optimize for existing 4 trace types. Phase 4 builds on that, doesn't replace it.
- trace-step.sh exists but was never wired — Phase 1 should evaluate reuse.

### Next Phase Scope
Phase 1: Trace Infrastructure — new schema, writer library, sampling rules, rotation config.

---

## Notes
- Research basis: TAD Evolution notebook (45 sources), 5-question deep ask session (2026-05-18)
- Key research references: Anthropic Dreaming, DSPy (not suitable for protocol rules), Reflexion, ToolObserver, Three-Store Layout
- Anti-pattern from research: DSPy-style prompt optimization is wrong for hard rules (MUST/MANDATORY/VIOLATION) — those should be deterministic validators, not optimizable prompts
