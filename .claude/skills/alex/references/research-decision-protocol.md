# Research Decision Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

research_decision_protocol:
  description: "Research before designing. Present options. Human decides."
  prerequisite: "Socratic Inquiry completed"
  blocking: true
  config: ".tad/config-cognitive.yaml"

  violations:
    - "Designing without researching existing solutions = VIOLATION"
    - "Not presenting alternatives to human = VIOLATION"
    - "Skipping research for important decisions = VIOLATION"

  # Step 1: Identify technical decisions in this task
  step1_identify_decisions:
    name: "Decision Point Identification"
    action: |
      After Socratic Inquiry, analyze the task requirements and identify:
      1. What technical decisions need to be made?
      2. Classify each as simple or important (per config depth_rules)

      Use AskUserQuestion to confirm identified decisions:
        "Based on our discussion, I've identified these technical decisions to research:"
        Options: each decision listed + "Add more" + "These are correct, proceed"

      <!-- research-gate:BEGIN -->
      # Research-gate (right-moment research nudge — suggestion only, NEVER stops the flow).
      # Runs at the TAIL of decision-identification, before step2_research.
      # Goal: nudge research ONLY when a decision provably turns on external info the
      # agent doesn't have — NOT to maximize any usage count.

      # Session-memory set (conversation-scoped, lives for this *discuss→*analyze session):
      #   declined_research_domains = {}   # domains the user already declined to research
      # This set is SHARED with STEP 3.8 and research_notebook_awareness (both append on
      # decline); the gate reads it. So the three nudge writers never double-prompt the same
      # domain in one *discuss→*analyze session via the backed declined-list.

      For EACH identified decision, apply the DEFAULT-SAFE decidability test:
        Q: "Is this decision decidable from the repo + requirements alone?"
        - YES, or AMBIGUOUS → stay silent (NO gate). This is the default and covers
          config values, naming, code style, refactor mechanics, pure preference,
          and anything where the answer lives in the codebase or the stated requirements.
          Ambiguity always defaults to NO-gate (mirrors Phase 4 effort-scaling
          "default to the lower tier").
        - NO — it provably depends on a fact ABSENT from repo+requirements (which
          library/vendor to pick, what production systems do for X, the current best
          approach, competitive/market/domain landscape) → this decision is ELIGIBLE.

      For each ELIGIBLE decision, before suggesting research, run the de-dup check:
        1. Is this decision's domain already in `declined_research_domains`? → if yes, skip (stay silent).
           (This is the backed dedup: STEP 3.8 + research_notebook_awareness both append to this
           same set on decline, so a domain the user already passed on this session is not re-asked.)
        2. Does a relevant notebook already exist? Run a lightweight REGISTRY existence read here
           (gate runs at step1-tail, BEFORE step2_5_notebook_check, so step2_5's result does not
           exist yet — do the cheap read now, using the SAME semantic-match criterion step2_5 uses
           so the two stay consistent). If a matching active notebook exists → skip (research already
           available). NOTE: step2_5 will re-confirm later with the identical criterion; the two are
           intentionally consistent, not divergent scans.

      If a decision is ELIGIBLE AND not de-duped (no declined-domain match, no existing
      notebook) → AskUserQuestion (suggestion only):
        "决策 '{decision}' 依赖外部信息，当前没有相关 notebook。要先研究吗？"
        Options:
          - "创建 notebook + *research-plan (Recommended)" → enter research_plan_protocol / *research-notebook create
          - "WebSearch 够了" → proceed; append this decision's domain to `declined_research_domains`
          - "我已了解，直接设计" → proceed; append this decision's domain to `declined_research_domains`

      Both non-create options ("WebSearch 够了" AND "我已了解，直接设计") count as a
      notebook-decline for this domain and write it to `declined_research_domains`, so a
      WebSearch choice does not re-prompt the same domain later this session.

      This is a suggestion only — Alex suggests, the human decides. Declining proceeds
      straight to design / step2_research; the gate stays silent and never stops the flow.
      <!-- research-gate:END -->

  # Step 2: Research each decision
  step2_research:
    name: "Research Phase"
    action: |
      For each identified decision:

      1. Execute Landscape Search (min 3 WebSearch queries):
         - "{problem} best practices {current_year}"
         - "{problem} open source solutions comparison"
         - "{problem} {our_tech_stack} recommended approach"

      2. WebFetch 1-2 high-quality results for deeper analysis

      3. Evaluate options found:
         - Maturity & community health
         - Fit with our project context
         - Cost & licensing
         - Learning curve

      4. Always include "build custom" as a comparison option

  # Step 2.5: Optional notebook check (before or alongside Landscape Search)
  step2_5_notebook_check:
    name: "Check Research Notebook (optional)"
    blocking: false
    action: |
      Before executing Landscape Search (WebSearch ×N):
      1. Check .tad/research-notebooks/REGISTRY.yaml for a notebook matching this decision's domain
      2. If found (active notebook) → query it first:
         notebooklm use <notebook_id>
         notebooklm ask "<decision question>"
      3. Use notebook answer as SUPPLEMENT to WebSearch, not replacement:
         - notebook = curated deep knowledge (cross-source, citations, video content)
         - WebSearch = current broad coverage (freshness, breadth)
      4. If not found → skip, proceed with standard WebSearch flow
    note: |
      This is optional — if REGISTRY.yaml doesn't exist or no matching notebook found,
      skip silently and proceed with WebSearch. Never block research on notebook availability.

  research_depth:
    simple: "3 search queries, 2+ options, quick_comparison table"
    important: "5+ search queries, 3+ options, quick_comparison + decision_record"

  time_budget:
    simple: "5-10 minutes per decision"
    important: "15-30 minutes per decision"

  # Step 3: Present to human
  step3_present:
    name: "Decision Presentation"
    action: |
      Present each decision using the appropriate format:

      Simple decision:
        Use AskUserQuestion with options based on research results.
        Include quick_comparison table in the question context.

      Important decision:
        1. Output the quick_comparison table
        2. Create draft Decision Record (.tad/decisions/DR-{date}-{slug}.md)
        3. Use AskUserQuestion for human to choose
        4. Record human's choice and rationale in Decision Record

    human_learning_enhancement:
      description: "Help human understand WHY each option matters"
      include_in_presentation:
        - "What does this choice enable/prevent in the future?"
        - "What's the risk if this turns out to be wrong?"
        - "What would experienced engineers consider here?"
        - "Real-world examples of projects using each option"

  # Step 4: Record and proceed
  step4_record:
    name: "Decision Recording"
    action: |
      After human decides:
      1. Record decision in handoff (Decision Summary section)
      2. If important: finalize Decision Record with human's rationale
      3. Add to .tad/project-knowledge/architecture.md if architecturally significant
      4. Proceed to design_protocol with decisions locked in

    handoff_integration:
      new_section: |
        ## Decision Summary

        | # | Decision | Options Considered | Chosen | Rationale |
        |---|----------|-------------------|--------|-----------|
        | 1 | {title} | {A, B, C} | {chosen} | {why} |

        Decision Records: .tad/decisions/DR-{date}-{slug}.md (if any)

