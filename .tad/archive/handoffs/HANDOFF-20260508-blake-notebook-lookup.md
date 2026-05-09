---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: yes
gate4_delta: []
---

# Mini-Handoff: Blake Research Capability (Lookup + Execution)
**From:** Alex | **To:** Blake | **Date:** 2026-05-08
**Type:** Express (skip Socratic, keep expert review)
**Priority:** P1

## Problem

Two gaps in Blake's research capability:

1. **Lookup gap:** Blake has `notebooklm_access` (line 808-857) with full query permissions, but `develop_command.1_5_context_refresh` (line 494-507) only reads project-knowledge files — never checks for relevant notebooks. Blake doesn't proactively query existing research.

2. **Execution gap:** When a handoff's purpose IS research (e.g., `task_type: research` or `research_required: yes` with research as primary deliverable), Blake has no mechanism to load and execute the research-methodology capability pack. Blake can only code — not run a 5-phase research pipeline.

## Fix 1: Notebook Lookup at Init (1_5b)

Add step 1_5b to `develop_command` in Blake SKILL, after `1_5_context_refresh` and before `1_6_tdd_check`:

```yaml
1_5b_notebook_check:
  description: "Check for relevant research notebooks before implementation"
  action: |
    1. Read .tad/research-notebooks/REGISTRY.yaml (if not found → skip silently)
    2. Check handoff §5 Research Evidence for notebook_id references
       → If found: use that specific notebook_id
       → If not: match handoff topic against notebook `topic` fields (LLM semantic)
    3. If relevant notebook found:
       a. Announce: "📚 Found relevant notebook: '{topic}' ({source_count} sources)"
       b. Run: *research-notebook ask --notebook {notebook_id} "What are the key implementation patterns and constraints for {handoff_task_summary}?"
          (uses allowed command from notebooklm_access — NOT raw CLI binary. Timeout: expect 23-43s latency.)
       c. Note key findings in context for use during implementation
    4. If NotebookLM CLI unavailable (preflight fail) → skip silently
    5. If no relevant notebook → skip silently
  blocking: false
  purpose: "Surface existing research findings before Blake starts coding — avoid re-searching what's already known"
```

Also add a reference to `notebooklm_access.when_to_use` from within `1_5b_notebook_check` so Blake knows the full set of allowed commands if deeper lookup is needed during implementation.

## Fix 2: Research-as-Task Execution (1_5c)

Add step 1_5c to `develop_command`, after `1_5b_notebook_check`:

```yaml
1_5c_research_task_detection:
  description: "Detect if this handoff's primary deliverable is research, and load research-methodology pack"
  action: |
    1. Read handoff frontmatter `task_type` field
    2. Check if task_type == "research" OR (research_required == "yes" AND
       handoff §1 Task Overview explicitly says deliverable is a research report/QCE/findings)
    3. If research task detected:
       a. Announce: "🔬 This is a research task. Loading research-methodology capability pack."
       b. Read .tad/capability-packs/research-methodology/CAPABILITY.md
       c. Execute the pack's 5-phase pipeline (Plan→Source→Curate→Analyze→Output)
          as the primary implementation workflow — INSTEAD of normal code implementation.
       d. Pack outputs (.research/report.md + .research/acs.md) are the deliverables.
          Blake's completion report references these as evidence.
    4. If NOT a research task → skip, proceed to normal 1_6_tdd_check → implementation
    5. If CAPABILITY.md not found at .tad/capability-packs/research-methodology/:
       → Warn: "⚠️ research-methodology pack not installed. Falling back to WebSearch."
       → Execute WebSearch-based research inline (per pack's DEGRADED MODE spec)
  blocking: true  # if detected, this REPLACES normal implementation flow
  
  notebooklm_access_override:
    description: "CR-P0-1 fix: research-task mode temporarily expands allowed commands"
    rationale: |
      notebooklm_access.forbidden was designed for Blake-as-code-implementer.
      When Blake executes research-methodology pack as primary task, the pack
      requires source management operations (add, research, curate) that are
      normally Alex-only. The override is scoped: ONLY active during 1_5c
      pipeline execution, reverts to normal forbidden list after pack completes.
    temporarily_allowed_during_pack_execution:
      - "*research-notebook research --mode fast/deep"  # pack Phase 2 SOURCE
      - "*research-notebook add <url>"                  # pack Phase 2 SOURCE
      - "*research-notebook curate"                     # pack Phase 3 CURATE
      - "*research-notebook report"                     # pack Phase 4 ANALYZE baseline
    still_forbidden_even_during_pack:
      - "*research-notebook create"        # notebook must exist before handoff (Alex creates)
      - "*research-notebook configure"     # Alex sets persona/mode
      - "*research-notebook consolidate"   # Alex manages portfolio
      - "*research-notebook archive"       # Alex manages lifecycle
      - "*research-notebook sync"          # Alex reconciles with cloud
    enforcement: "Blake MUST announce 'Entering research-task mode — expanded notebook access active' at step 3a and 'Exiting research-task mode — notebook access reverted to read-only' after pipeline completes"

  quality_assurance:
    description: "CR-P0-2 fix: quality gates for research output (replacing Ralph Loop)"
    rationale: |
      H1/H2/H3 are scope-approval gates, not quality-verification gates.
      Ralph Loop Layer 1 (build/lint/test) and Layer 2 (expert review) have
      no direct equivalent in the research pipeline. This section defines
      what replaces them.
    layer_1_equivalent: |
      Pack's anti-hallucination layers (§5 of CAPABILITY.md) serve as Layer 1:
      - URL existence check (every source validated)
      - Citation traceability (every claim cited)
      - QCE structure enforcement (contradictory evidence required)
      - Dead-end registry check (no refuted findings cited)
      These run automatically during pack execution — no manual invocation.
    layer_2_equivalent: |
      H3 (output review) is UPGRADED from simple scope-approval to quality gate:
      At H3, BEFORE presenting to user, Blake must verify:
      - Citation count: ≥3 unique sources cited per Claim
      - T1 source ratio: ≥30% of cited sources are T1 (official/academic)
      - Contradictory evidence: every Claim has a non-empty "Contradictory evidence" section
      - Extracted ACs: ≥1 concrete AC per research question in the question tree
      If any check fails → Blake notes the gap and presents to user with warning.
      This is a self-check (like Ralph Loop Layer 1), not expert-subagent review.

  detection_tightening:
    description: "CR-P1-3 fix: prevent false-positive detection"
    rule: "task_type == 'research' is the ONLY trigger. research_required: yes alone is NOT sufficient. research_required: yes with task_type: code/yaml/mixed means 'research supports the implementation' — Blake reads findings, doesn't run a research pipeline."

  constraints:
    - "Blake executes the pack pipeline but does NOT modify the pack itself"
    - "notebooklm_access_override applies ONLY during 1_5c pipeline execution"
    - "After pack pipeline completes, Blake writes normal completion report referencing pack outputs"
  purpose: "Enable Blake to execute complete research workflows when research IS the deliverable"
```

## Files to Modify
- `.claude/skills/blake/SKILL.md` — add `1_5b_notebook_check` + `1_5c_research_task_detection` between `1_5_context_refresh` and `1_6_tdd_check`

## Acceptance Criteria

### Fix 1 (Lookup)
- [ ] **AC1**: Blake SKILL has `1_5b_notebook_check` step between `1_5_context_refresh` and `1_6_tdd_check`
- [ ] **AC2**: Step reads REGISTRY.yaml and matches notebook by handoff §5 reference OR topic semantic match
- [ ] **AC3**: Step uses `*research-notebook ask --notebook <id>` command form (not raw CLI binary) per notebooklm_access.allowed
- [ ] **AC4**: Step is non-blocking (skip silently on: no REGISTRY, no match, CLI unavailable)

### Fix 2 (Execution)
- [ ] **AC5**: Blake SKILL has `1_5c_research_task_detection` step after `1_5b`
- [ ] **AC6**: Detection triggers ONLY on `task_type: research` (NOT `research_required: yes` alone — CR-P1-3 fix)
- [ ] **AC7**: When triggered, step loads `.tad/capability-packs/research-methodology/CAPABILITY.md` and follows its 5-phase pipeline
- [ ] **AC8**: `notebooklm_access_override` section defined — temporarily allows `research`, `add`, `curate`, `report` ONLY during 1_5c pipeline; `create`/`configure`/`consolidate`/`archive`/`sync` remain forbidden (CR-P0-1 fix)
- [ ] **AC9**: Blake completion report references `.research/report.md` and `.research/acs.md` as evidence
- [ ] **AC10**: H3 gate upgraded with quality criteria: ≥3 citations/claim, ≥30% T1 ratio, non-empty contradictory evidence, ≥1 AC per question (CR-P0-2 fix)
- [ ] **AC11**: Blake announces "Entering research-task mode" at start and "Exiting research-task mode" at end (override scope visibility)
- [ ] **AC12**: Fallback: if CAPABILITY.md missing → warn + WebSearch degraded mode (CR-P1-4 fix)
