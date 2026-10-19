# Handoff Creation Protocol (extracted from SKILL.md for progressive loading)
# Source: skills/alex/SKILL.md (platform tree)
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 1)

handoff_creation_protocol:
  description: "创建 handoff 时必须经过专家审查，确保设计完整且可执行"
  prerequisite: "必须先完成需求澄清（逐块复述经人确认；Cora 派发的 Epic 阶段即 Epic ## Requirement）"

  workflow:
    step0:
      name: "Prerequisite Check"
      action: "检查需求澄清是否完成（逐块复述已经人确认）"
      violation: "未完成需求澄清（逐块复述未经人确认）就开始写 handoff = VIOLATION"

    step0_5_conflict_matrix:
      name: "AC Conflict Matrix Self-Check"  # Phase 3 anchor A-01 (per HANDOFF-20260415-phase3 §3.1)
      action: |
        Before step0_5 knowledge reload, for every triple of structural ACs
        (byte-preservation × performance-budget × behavioral-invariant), self-check:
        "Can all three be simultaneously satisfied?" If not, document the resolution
        (phase-ordering hard-constraint, override path, PARTIAL-GO acceptance) BEFORE
        writing the AC list. This catches logical contradictions that individual
        expert reviewers miss (each reviewer evaluates their slice in isolation).
      reference: "Phase 1c knowledge — Handoff Design Conflict: Byte-Preservation vs Optimization vs Internal Timeout"
      blocking: true

    step0_5:
      name: "Context Refresh — Full Knowledge Reload"
      action: |
        Before writing handoff draft, reload **relevant** project knowledge.
        L2 lazy-load (2026-04-27): only read files matching task keywords, not all.

        1. **Identify task keywords** from the requirement (block lines, Q→A log) / *discuss
           context (topics, technologies, file paths, domain). Output: keyword list.
        2. **Read .tad/project-knowledge/principles.md** (always — L1 methodology rules).
        3. **Read .tad/project-knowledge/patterns/_index.md** — match task keywords
           against index entries to identify relevant pattern files (typically 1-3 of:
           gate-design, handoff-design, shell-portability, ac-verification,
           hook-contracts, pack-build-rules, pack-evaluation, research-methodology,
           memory-and-learning).
        4. **Read ONLY matched pattern files** (max 3): .tad/project-knowledge/patterns/{matched}.md.
           L3 incidents are NOT pre-loaded — queried on demand via knowledge-blame.sh.
           Legacy category files (ux, performance, testing, etc.) still loaded if they
           have content and match keywords.
        5. Read handoff_creation_protocol key rules from THIS file:
           - lens_selection (which Gate 2 lenses to dispatch)
           - review composition: .tad/templates/review-contract.md §8 (Gate 2: consistency + risk or fit; two reviewers)
           - step7 STOP rule (must generate Blake message, must not call /blake)
        6. Read the handoff template: .tad/templates/handoff-a-to-b.md
           (to ensure template structure is fresh in context)
        7. Brief output: "📖 Knowledge refreshed: README + {N} matched files (skipped {M}) + handoff protocol + template"
        # Knowledge Matching — ensure relevant history reaches Blake (BA-P1-3: scan operates on partial corpus per L2 lazy-load; inclusivity rule below preserves "false negatives are not acceptable")
        8. After reading matched knowledge files (per step 4 — partial corpus by design),
           scan each entry (### title - date) for relevance:
           a. Extract task keywords from the requirement (block lines, Q→A log) (topics, technologies, file paths, domain)
           b. For each knowledge entry: does its Context/Discovery mention any of these keywords?
           c. Collect all matching entries into a "relevant_knowledge" list
        9. When writing handoff §📚 Project Knowledge → "⚠️ Blake 必须注意的历史教训":
           a. ALL entries from relevant_knowledge list MUST be included (not optional, not "Alex picks")
           b. Format: entry title + source file + 1-line summary of why it's relevant to this task
           c. If relevant_knowledge is empty: write "✅ 已检查匹配类别 knowledge 文件，无与本任务直接相关的历史教训"
        10. This replaces the current manual "Alex reads and picks relevant entries" approach.
            The scan is keyword-based and exhaustive within the matched corpus — Alex cannot silently skip a matching entry.
        11. Matching is LLM semantic scan, not regex. Match related concepts
            (e.g., "hook" matches entries about hook scripts, shell portability).
            When in doubt, include — false positives acceptable, false negatives are not.
            If keyword identification (step 1) feels under-coverage for a cross-cutting task,
            EXPAND step 3 category match (e.g., add architecture.md as broad fallback).
        12. After knowledge matching, run stale-knowledge-check.sh (Phase 2 P2.1, advisory only):
              bash .tad/hooks/lib/stale-knowledge-check.sh --json 2>/dev/null
            Failure handling:
              - If exit code != 0: emit stderr warning
                "stale-check.sh failed (exit {code}); continuing without staleness data"
                and proceed. Handoff drafting MUST NOT be blocked by this advisory tool.
              - If exit code == 0: parse JSONL.
                For each entry in relevant_knowledge with status="STALE":
                  output to user: "⚠️ Knowledge entry '{title}' may be stale:
                  {path} changed {N} days after baseline"
                  Do NOT block. User may re-verify and bump `Revalidated` (per README
                  Entry Format), or proceed with awareness.
                INFO/WARN entries: just count for transparency; no UI noise.
            Anti-Epic-1 reminder: stale-check is a CLI tool, NOT a hook. Never
            registered in settings.json. Failure here MUST fall through.
      purpose: "Last line of defense — all known pitfalls must be in context when writing handoff"

    step0_5b:
      name: "Research Asset Check (post-clarification)"
      trigger: "After step0_5 knowledge reload completes, before step1 draft creation"
      action: |
        0. Prefer Local Wiki first: search `research/canon/_index.md` or run
           `python3 research/scripts/search.py query "<handoff scope>" --scope wiki`.
           If a related wiki is found → extract conclusions + raw_refs into handoff
           §📚 Project Knowledge and §5 Research Evidence.
           Only when Local Wiki has no hit → degrade to WebSearch; NotebookLM layer deprecated 2.44.6.
        1. Read REGISTRY.yaml → find notebooks relevant to this handoff's scope (fallback)
           (match against task keywords from step0_5 step 1)
        2. If relevant notebook exists:
           a. Run: *research-notebook topics (get suggested queries for that notebook)
           b. Check: are there research findings in .tad/evidence/research/ for this topic?
           c. If findings exist → note them for citation in handoff §📚 Project Knowledge section
           d. If notebook exists but no findings → AskUserQuestion:
              "有一个相关 notebook '{topic}' 但还没产出研究报告。要现在生成吗？"
              Options:
                - "生成 briefing report" → *research-notebook report "...related to handoff scope"
                - "跳过，不影响 handoff" → continue
        3. If no relevant notebook → skip (existing research_decision_protocol handles WebSearch)
        → ALWAYS continue to step0_6_deliverable_classification (MUST run before step1 — every branch above falls through here, never jump straight to step1).
      blocking: false

    step0_6_deliverable_classification:
      name: "Deliverable Classification — Touchpoint 0 (PRODUCER touchpoint)"
      trigger: "After step0_5b research-asset check, BEFORE step1 draft creation (must precede template selection)"
      additive: true  # ⚠️ Does NOT change intent_router signal detection or the default analyze→code template path.
      action: |
        Classify the unit of work BEFORE selecting a handoff template:

        Rule of thumb (contract §A.4): if the unit of work is a **pack-produced content
        artifact** — the artifact IS the product (a research report / audiobook / video cut /
        PRD), judged by a pack-specific rubric rather than build/test/lint — then this is a
        DELIVERABLE, not a code handoff.
          - if the artifact IS the product → task_type: deliverable
          - if the artifact informs a downstream build → task_type: research (unchanged path)

        IF deliverable:
          1. Set frontmatter `task_type: deliverable`. (The enum value is PRESERVED — it signals
             "this handoff's §9.1 contains rubric/judge ACs" and triggers gate's Rubric Evaluation Protocol.)
          2. Select the UNIVERSAL `.tad/templates/handoff-a-to-b.md` template (NOT a separate
             deliverable template — that template is DEPRECATED). The rubric ACs are written in
             the universal §9.1 Spec Compliance Checklist like any other AC.
          3. Fill the rubric frontmatter keys: `pack`, `rubric_ref`, `pass_threshold`,
             `deliverable_paths: []` (rubric_ref/pass_threshold precedence per contract §A.2 —
             frontmatter overrides .tad/capability-packs/deliverable-rubrics.yaml; both absent → Gate 3 BLOCKS).
          4. In §9.1, write at least one rubric AC whose Verification Method is "spawn independent
             judge per Rubric Evaluation Protocol against {rubric_ref} → verdict: PASS" (step1_ac_generation.non_dev_and_rubric).
          5. Producer is Conductor-side (contract §B.6) — NOT Blake; the gate spawns an independent judge (judge ≠ producer).
          → Continue to step1 (Draft Creation) using the universal handoff-a-to-b.md template.
        ELSE (code/yaml/research/e2e/mixed):
          → Continue to step1 with the existing default template selection (handoff-a-to-b.md). No change.
      note: "This is the PRODUCER touchpoint: it sets task_type: deliverable and fills rubric frontmatter. Template routing is now UNIVERSAL (handoff-a-to-b.md for all task_types) — deliverable-handoff.md is deprecated. Additive — existing code routing untouched."

    step1:
      name: "Draft Creation"
      action: "创建 handoff 初稿（框架+核心内容）"
      output: ".tad/active/handoffs/HANDOFF-{date}-{name}.md"
      content:
        - Executive Summary
        - Task breakdown (numbered)
        - Implementation details (code snippets)
        - Acceptance criteria
        - Files to modify
        - Testing checklist
        - "Micro-Tasks (optional — include for Full/Standard TAD when task has 5+ files)"
        - "YAML frontmatter (MANDATORY — task_type, e2e_required, research_required must be filled)"
        - "Capability Pack References (if packs loaded in *design step1_5b)"
        - "Required Evidence Manifest — MANDATORY section (Phase 3 anchor A-02): explicit YAML block listing every evidence file Blake must produce (expert_reviews, gate_verdicts, completion, blake_reviews, perf_evidence, fixture_results, dogfood, knowledge_updates). PreToolUse hook AW-1/BW-1 will reject the handoff Write if this section is missing."
        - "(skip when dispatched by a conductor: the conductor owns session-state during a run) Write .tad/active/session-state.md (keep any `## Conductor run (Cora)` section unchanged): Status=ACTIVE, Active Agent=Alex, Mode={current_mode}, Active Task.Handoff=<draft_path>, Current Position='handoff_creation step1 — drafting', Big Picture.Goal/Why Now/Key Constraint/Success When from task requirements"
      epic_linkage: |
        If this session was dispatched by a conductor (references/conductor-dispatch-mode.md): do steps 1, 1b and 2 only. The conductor has already set this phase 🔄 Active and owns the Epic file: do not edit it, except your own phase's Phase Detail block (skip 3 and 3b). Step 4 then means: the only 🔄 Active phase is the one named in the dispatch; if another phase is Active, stop and report to the conductor.
        If an active Epic exists in .tad/active/epics/:
        1. Read the Epic's Phase Map to find the next ⬚ Planned phase
        1b. Read the Phase Detail Block for this Phase (### Phase {N}: {name}),
            using Phase number N and name from step 1:
            - Extract Scope → use as task description context for design
            - Extract AC → pre-fill handoff AC section
            - Extract Files Likely Affected → pre-fill handoff §5 Files to Modify
            - Extract Input/Output → inform design context
            NOTE: Clarification depth follows clarity; a sufficient Phase Detail Block leaves fewer unclear blocks (step2b_phase_detail_check).
            This step only pre-fills handoff sections.
            If no Phase Detail Block found (backward compat):
              → No pre-fill available (behavior unchanged from pre-enhancement)
        2. Add **Epic** metadata field to handoff header:
           **Epic:** EPIC-{YYYYMMDD}-{slug}.md (Phase {N}/{M})
        3. Update the Epic Phase Map: set the corresponding phase to 🔄 Active
           and fill in the handoff filename
        3b. Update the Phase Detail Block Status (if exists): ⬚ Planned → 🔄 Active
            If no Phase Detail Block → skip (backward compat)
        4. Verify: no other phase is already 🔄 Active (concurrent control)
           - If another phase is Active → BLOCK, do not create handoff
        If no active Epic → omit the Epic field (normal handoff)
      # principles.md protection check (Knowledge Lifecycle System)
      principles_protection: |
        If any file in §6 "Files to Modify" targets .tad/project-knowledge/principles.md:
          Check: does the current handoff have an Epic field?
          → If yes (Epic context active) → allow modification, log: "principles.md edit authorized by Epic {slug}"
          → If no (standalone handoff) → WARN:
            "⚠️ principles.md contains L1 methodology rules. Modifying it requires an
            Epic-level TAD flow. Either create an Epic first, or reclassify this change
            as an L2 pattern edit (patterns/*.md) if it's not truly a methodology change."
            Use AskUserQuestion: "Override?" / "Create Epic first" / "Change target to patterns/"

    step1_ac_generation:
      name: "§9.1 Acceptance Criteria Auto-Generation (task-scoped)"
      trigger: "After step1 draft creation, before step1a — populates the §9.1 Spec Compliance Checklist"
      why: |
        Gate 3 is now AC-driven: it executes each §9.1 row's Verification Method (gate/SKILL.md
        Spec_Compliance_Verification). An empty §9.1 → Gate 3 BLOCKS (empty guard). So Alex MUST
        populate §9.1 with executable Verification Methods. For dev projects these are the
        tsc/test/lint checks that USED to be hardcoded in Gate 3; for non-dev projects they are
        domain-specific commands.
      detection: |
        Detection is TASK-SCOPED (based on THIS task's §6 Files to Modify + requirement),
        NOT purely project-scoped (ARCH-P1-1 fix). Inspect the files THIS handoff touches:
          - §6 has .ts/.tsx files → generate `npx tsc --noEmit` AC (if a tsconfig.json exists in the project)
          - §6 has .py files → detect pytest/unittest → generate `pytest` (or `python -m pytest`) AC
          - §6 has .js/.jsx files + a package.json with a test script → generate `npm test` AC
          - project has a linter config (.eslintrc*, pyproject.toml [tool.ruff], etc.) AND §6 touches lintable files → generate the lint AC (`npm run lint` / `eslint .` / `ruff check`)
          - ALWAYS generate `git diff --stat` AC (confirm change scope) for code/mixed handoffs
          - task is pure doc/audio/video/content (no code surface) → generate NO dev AC; write domain-specific Verification Methods instead
      generated_rows: |
        Write each generated check as a §9.1 row with a real, runnable Verification Method:
          | AC# | Description | Verification Method | Expected Evidence |
          | ACn | TypeScript compiles | `npx tsc --noEmit` | exit 0, no errors |
          | ACn | Tests pass | `npm test` (or `pytest`) | all pass |
          | ACn | Lint clean | `npm run lint` (or `ruff check`) | 0 errors |
          | ACn | Change scope as planned | `git diff --stat` | only §6 files changed |
        These are DEFAULTS — Alex adjusts per task (e.g. a pure-doc change skips tsc; a podcast
        handoff writes `python scripts/measure_consistency.py EP04 | grep overall` → > 70).
      non_dev_and_rubric: |
        - Non-dev project (Colin声音/播客, Sober Creator/content, 买卖/electronics): §9.1 ACs come
          entirely from the requirement-determined quality standards (domain-specific commands).
        - When task_type: deliverable (rubric/judge ACs): write a §9.1 row whose Verification
          Method is "spawn independent judge per Rubric Evaluation Protocol against {rubric_ref}
          → verdict: PASS" so Gate 3's Rubric Evaluation Protocol activates.
      empty_guard_reminder: "NEVER leave §9.1 empty — Gate 3 BLOCKS on an empty §9.1 (gate/SKILL.md Spec_Compliance_Empty_Guard)."
      method_legality: |
        Every landing-tier §9.1 Verification Method cell must be LEGAL — exactly one of:
        runnable command in backticks | evidence path-check | fixture runner | rubric-spawn |
        light-tier N/A with reason (light tiers only). An ILLEGAL (prose-only) Method cell is
        NOT shippable: rewrite it into a runnable command BEFORE ship — Gate 3 marks the row
        FAIL (prose-only Verification Method = FAIL) and Gate 4 cannot PASS on missing/unrun
        Methods. Do NOT invent a new `verify:` column or frontmatter key; tighten the Method cell.

    step1a:
      name: "Capability Pack Injection"
      action: |
        If Capability Packs were loaded during *design step1_5b:

        1. Add a new section to the handoff draft after "📚 Project Knowledge":

           ## 🔧 Capability Pack References (Blake 必读)

           **Loaded Packs:**
           | Pack | File | Matched Capabilities |
           |------|------|---------------------|
           | {pack1} | .agents/skills/{pack1}/SKILL.md | {cap1, cap2} |
           | {pack2} | .agents/skills/{pack2}/SKILL.md | {cap3, cap4} |

           **⚠️ Blake 必须在开始实现前 Read 上述 pack 文件。**

        2. Merge pack quality_criteria into "## 9. Acceptance Criteria":
           For each matched capability's quality_criteria:
           - Append as supplementary AC items
           - Tag each with source: `[from: {pack-name} → {capability}]`
           - These are ADVISORY, not mandatory — Blake uses judgment on applicability

        3. Merge pack anti_patterns into "## 10. Important Notes":
           Append under a sub-heading:
           ```
           ### 10.4 Pack Anti-Patterns
           - ⚠️ [web-frontend] Don't use inline styles for layout — use design tokens
           - ⚠️ [web-backend] Don't expose internal IDs in API responses
           ```

        4. Merge pack tool recommendations into "## 10.3 Sub-Agent 使用建议":
           If pack has tool_ref that maps to CLI tools, suggest Blake use them.

        If no Capability Packs were loaded: skip this step entirely.
      skip_conditions:
        - "No Capability Packs loaded during *design"
        - "Light TAD (skip for lightweight process)"

    step1b:
      name: "Frontmatter Validation"
      action: "验证 handoff 草稿的 YAML frontmatter 三个字段都已填写且值合法"
      validation:
        task_type: "must be one of: code, yaml, research, e2e, mixed, deliverable"
        e2e_required: "must be yes or no"
        research_required: "must be yes or no"
        risk_triggers: "list from the closed set security | data | money | ui | platform | domain, or [none]"
        real_paths: "≥1 entry {id, path, run} or {id, path, not-run: <reason>}; protocol text: a named scenario walk"
      violation: "frontmatter 字段缺失或值非法 = VIOLATION — 不能继续 step2"

    step1c:
      name: "Grounding Pass — Read target files before sending to Expert Review"
      trigger: "After step1b frontmatter validation, before step2 expert selection"
      enforcement: "prompt-level-only"  # ⚠️ NOT a hook, NOT in settings.json, NOT a tool block
      rationale: |
        Phase 2 P2.2 (2026-04-24) — Alex 经常基于过期或想当然的代码认知写 handoff
        (toy OPRO 2026-04-21 case). 在 step1 draft 完成、§6 Files to Modify 已存在
        之后，强制 Read 目标文件 head 50 行作为 reality check。
        先 reload knowledge (step0_5) 是 Alex 已知的"过去印象"; 后做 grounding (step1c)
        是验证印象是否仍准确。顺序不可颠倒——step0_5 之前 §6 不存在。
      blocking_in_alex_protocol: true  # Alex 自身 protocol 流程内必做才能进 step2
                                        # 但**不**是 hook-level / tool-block — 是 SKILL 顺序约束
      action: |
        1. Identify target files in handoff scope:
           a. Parse step1 draft's §6 (Files to Modify / Create) section
           b. Plus paths under frontmatter `git_tracked_dirs[]` if relevant
        2. For each EXISTING target file:
           - Use Read tool with offset=1 limit=50 to fetch head 50 lines
           - Note any surprises vs Alex's design-time assumptions (renamed function,
             changed interface, moved path, etc.)
           - On significant surprise: return to step1 to revise §6, or escalate to user
        3. For files Alex plans to CREATE (don't yet exist):
           - Skip Read; mark as `(new — will be created)` in Grounded Against
        4. Append to handoff §6 末尾:
           **Grounded Against** (Alex step1c 实际 Read 过的源文件):
           - .tad/hooks/lib/foo.sh (head 50, read at YYYY-MM-DD HH:MM)
           - .tad/templates/handoff-a-to-b.md (head 50, read at YYYY-MM-DD HH:MM)
           - .tad/hooks/lib/bar.sh (new — will be created)
      exemption_pre_phase2_handoffs: |
        Skip step1c for handoffs that predate Phase 2 (filename date < 2026-04-24
        OR no git_tracked_dirs frontmatter present): warn-only on revision.
        Skip automatically for `task_type: doc-only` handoffs (no source files).
        Skip automatically for handoffs with empty §6 (no files to modify/create).
      exemption_express:
        note: "*express path 是否豁免 grounding pass 留待 Phase 3 决定"
        until_phase3: "*express 暂时也跑 step1c (与 standard 一致)，Phase 3 再 revisit"
      violation_self_audit: |
        At step2 (expert review), if §6 has no Grounded Against line AND §6 is non-empty
        AND no exemption applies: self-audit failed → return to step1c.
        This is Alex's own check — NOT a hook, NOT a tool block.
      forbidden_implementations:
        - "MUST NOT register hooks or modify settings"
        - "violation level mirrors anti_rationalization_registry: prompt-only enforcement"

    # ──────────────────────────────────────────────────────────
    # LSP Auto-Provision Protocol (shared by Alex + Blake)
    # ──────────────────────────────────────────────────────────
    lsp_provision_protocol:
      description: "Graph → Detect → try → install → fallback. Zero user interaction."

      step0_graph:
        name: "Graph Intelligence Check"
        action: |
          Before LSP detection, check if codebase-memory-mcp is available:
          1. Bash: command -v codebase-memory-mcp >/dev/null 2>&1
          2. If found: Bash: codebase-memory-mcp cli list_projects '{}' 2>/dev/null
             Parse output via jq for project matching current working directory
          3. Staleness check: extract last_indexed timestamp from list_projects output.
             If index is older than 7 days → treat as unavailable (stale index = wrong blast radius)
          4. If project found AND indexed AND fresh (≤7 days):
             → Set graph_available=true, graph_project=<project_name>
             → ⚠️ Do NOT skip step1_detect through step4_install — LSP provisioning
               still runs (other SKILL features may use LSP directly; if graph crashes
               mid-session there is no LSP fallback if provisioning was skipped)
             → Graph mode only replaces the QUERY step inside step1c_lsp, not the
               PROVISIONING steps
          5. If binary not found OR project not indexed OR stale:
             → Set graph_available=false
             → Continue to existing step1_detect (LSP path, unchanged)
        time_budget: "<500ms (CLI probe is ~30ms)"
        skip_if:
          - "§6 is empty or all files are new (create, not modify)"
          - "task_type is doc-only, yaml, or research"
        forbidden_implementations:
          - "MUST NOT auto-index the repository (TAD never triggers indexing)"
          - "MUST NOT block or slow down if graph probe fails (strict <500ms budget)"

      step1_detect:
        action: "Extract primary file extensions from §6 Files to Modify"
        output: "dominant_extension (e.g., '.ts')"

      step2_lookup:
        action: "Match dominant_extension against .tad/guides/lsp-language-map.yaml"
        output: "plugin_name, prereq_command"

      step3_try:
        action: "LSP documentSymbol on first existing file in §6 (line=1, character=1)"
        on_success: "LSP available → proceed to impact analysis"
        on_no_server: "goto step4_install"

      step4_install:
        action: |
          a. Prereq install (split by weight):
             - npm-based prereqs (typescript-lsp, pyright-lsp, php-lsp): auto-install silently
               Bash("npm i -g {prereq_package}") — lightweight, seconds, standard dev tooling
             - brew-based prereqs (rust-analyzer, jdtls, llvm, kotlin-lsp, etc.): DO NOT auto-install
               Log: "LSP prereq needs: {prereq_command}. Run manually if you want LSP for {language}."
               Reason: brew packages can be 2GB+ (llvm); silent install violates user's env safety rule
          b. Plugin install: Bash("claude plugin install {plugin_name}")
          c. Retry LSP documentSymbol (line=1, character=1)
        on_retry_success: "LSP available → proceed to impact analysis"
        on_retry_fail: |
          LSP installed but needs new session to activate.
          Log: "LSP plugin {plugin_name} installed. Available next session."
          Fallback to grep for this session.
        time_budget: "step3_try: <2s. step4_install npm prereq: 5-30s. step4_install plugin: <5s. If total >60s, abort and fallback."

      step5_fallback:
        action: "Use existing grep + Read approach (current behavior, zero regression)"
        note: "No error output, no user prompt. Silent degradation."

    # ──────────────────────────────────────────────────────────
    # step1c_lsp: LSP Impact Analysis — scope gap detection
    # ──────────────────────────────────────────────────────────
    step1c_lsp:
      name: "LSP Impact Analysis — scope gap detection"
      trigger: "After step1c grounding pass, before step1d AC Dry-Run pass"
      prerequisite: "lsp_provision_protocol completed (step0_graph succeeded OR step3/step4 succeeded)"
      enforcement: "prompt-level-only"

      action: |
        # ── Graph-first path (if graph_available from lsp_provision_protocol.step0_graph) ──
        If graph_available:
          1. Run: codebase-memory-mcp cli detect_changes "$(jq -nc --arg p "$graph_project" '{project: $p}')"
             → Parse changed_files + impacted_symbols + downstream_dependents
             → If detect_changes returns empty (clean working tree — no git diff yet during design):
               Fall through to LSP path below instead of returning DONE with empty results.
               Empty graph results are WORSE than LSP analysis of §6 files.
          2. For each impacted symbol with label Function/Method/Class:
             Validate symbol_name: [[ "$symbol_name" =~ ^[A-Za-z0-9_.\-]+$ ]] || skip
             Run: codebase-memory-mcp cli query_graph "$(jq -nc --arg p "$graph_project" --arg s "$symbol_name" \
               '{query: "MATCH (caller)-[:CALLS]->(fn {name: \"\($s)\"}) RETURN caller.name AS caller, caller.file_path AS file, caller.start_line AS line", project: $p}')"
             ⚠️ Two-layer injection defense: jq --arg prevents shell/JSON injection; the regex validation prevents Cypher injection — both are required
          3. Collect all caller file paths into graph_callers set
          4. Compare graph_callers against §6 file list (same logic as LSP path step 5)
          5. Append to Grounded Against:
             "Graph impact: {N} symbols checked via codebase-memory-mcp, {M} callers found, {G} scope gaps added"
          6. DONE — skip the LSP QUERY path below (but LSP provisioning already ran in step1-4)

        # ── LSP path (existing, unchanged — runs when graph_available=false) ──
        For each EXISTING file in §6 that handoff proposes to MODIFY (not create):

        1. Run LSP documentSymbol (line=1, character=1 — required by tool schema but not
           semantically used for this operation) → identify exported functions/classes/constants
        2. Cross-reference with handoff task description: which symbols will change?
           (LLM judgment — match task description against symbol names.
           Bias: when uncertain, CHECK the symbol. False positive = cheap extra LSP call.
           False negative = missed scope gap, defeating the entire purpose.)
        3. For each symbol identified as "will be modified":
           Extract the symbol's line and character position from the documentSymbol result,
           then run LSP incomingCalls with those coordinates → get all callers
        4. Collect all caller file paths into a set: lsp_callers
        5. Compare lsp_callers against §6 file list:
           - Caller in §6 → ✅ covered
           - Caller NOT in §6 → ⚠️ scope gap
        6. If scope gaps found:
           a. Output: "⚠️ LSP: {N} files call modified symbols but are not in §6: {list}"
           b. Add to §6 with annotation: "(LSP: calls modified {symbol_name})"
           c. Read head 30 of each gap file (lightweight grounding)
        7. Append to Grounded Against:
           "LSP impact: {N} symbols checked, {M} callers found, {G} scope gaps added"

      skip_if:
        - "LSP not available (provision failed) → existing step1c is sufficient"
        - "§6 is empty or all files are new (create, not modify)"
        - "task_type is doc-only, yaml, or research"

      token_budget: "~5 LSP calls per file × ~3 files = ~15 calls. Each returns ~200 tokens."

      compact_recovery: "LSP annotations in §6 are idempotent. Re-running after compact is safe but redundant if Grounded Against already shows LSP impact line."

      known_limitations: "Provisions one language per session. Multi-language handoffs get LSP for dominant extension only; others fall back to grep."

      forbidden_implementations:
        - "MUST NOT register hooks or modify settings"

    step1d:
      name: "AC Dry-Run Pass — verify §9.1 verification commands actually work (P6-A.1, 2026-04-25)"
      trigger: "After step1c_lsp (or step1c if LSP unavailable), before step2 expert review"
      enforcement: "prompt-level-only"  # ⚠️ NOT a hook, NOT in settings.json, NOT a tool block
      rationale: |
        Phase 3 / 4 / 5 累积 3 次 §9.1 verification command 在 Blake runtime 出错
        (Phase 3 模板 anchor / Phase 4 grep scope / Phase 5 grep -n single-file output format).
        根因是 Alex 脑内模拟 grep/awk/jq/markdown-table-pipe-escape output shape 不可靠。
        step1d 强制实跑 + 3 self-defending sub-rules (CR self-dogfood verdict).
      blocking_in_alex_protocol: true
      action: |
        1. Parse step1 draft's §9.1 Spec Compliance Checklist table.
           NOTE: handoff template numbering — §9.1 = Spec Compliance, §9.2 = Expert Review.
           Don't confuse with the handoff's own internal §9.x numbering.
        2. For each §9.1 row, classify per Verification Type:
           a. **pre-impl-verifiable**: command can run NOW on existing artifacts
           b. **post-impl-verifiable**: command requires Blake's NEW artifacts
        3. **Sub-rule 1: Raw-form-before-rendered-form (CR self-dogfood)**:
           - Author commands in RAW shell form first (e.g., `grep -cE 'a|b|c'`)
           - Dry-run from RAW form, NOT from markdown-rendered escaped form
           - Only escape pipes (`|` → `\|`) when inserting into markdown table cells
           - In §6.7 dry-run log, paste BOTH raw command + un-escaped output
        4. **Sub-rule 2: Syntax-validate even post-impl-verifiable rows**:
           - Even rows that can't fully run (file doesn't exist yet), run `bash -n` /
             shellcheck on the command, OR run a syntactic dry-run with `--help`-style
             expansion to confirm command parses
           - Catches `\|` literal-pipe-in-grep-E and similar regex bugs that don't
             require the target file to exist
        5. **Sub-rule 3: Re-derive every pre-impl AC value with a one-liner**:
           - Never quote AC values from memory or another section of the same doc
           - For pre-impl rows, run the command exactly as written, paste actual output
           - Cross-check against §6.7 dry-run log to catch mismatches early
             (Phase 6-A v1 caught its OWN AC-G2 quoting wrong number due to violation
              of this rule — fixed by pasting the actual `grep -c '"deny"'` output)
        6. For each pre-impl-verifiable row:
           - Run command, capture stdout + exit code
           - Paste result into "Verified Output" column of handoff §9.1
           - If output ≠ AC's "Expected Evidence" → fix the AC's Verification Method
        7. For each post-impl-verifiable row:
           - Mark "Verified Output" column as "(post-impl — Blake runs at Gate 3 v2 Layer 1)"
           - Apply Sub-rule 2 (syntax-validate)
           - DO NOT mock the future artifact (no `echo > /tmp/...` hacks)
        8. Append `## AC Dry-Run Log` (or "Step1d Dry-Run Log") to handoff §6.5 / §6.7:
           ```
           **AC Dry-Run Log** (Alex step1d 实际 dry-runs at YYYY-MM-DD HH:MM):
           - AC-X-y: ✅ pre-impl-verifiable, raw cmd: <cmd>, output matched expected
           - AC-X-z: ✅ post-impl-verifiable, syntax-validated, deferred to Gate 3
           - AC-X-w: ⚠️ pre-impl-verifiable, output mismatch — Verification Method revised
           ```
        9. **Advisory tail — §9.1 AC-command linter (P4, 2026-05-31)**:
           Run `bash .tad/hooks/lib/verify-ac-commands.sh <this-handoff>`; surface any
           WARN/INFO findings to the author and reconcile them with the step1d dry-run
           above (e.g. a Rule A `grep -c … | sort -u | wc -l` WARN → switch to
           `grep -oE … | sort -u | wc -l`; a Rule B `\|`-in-ERE WARN → treat as a LIKELY
           REAL broken-when-run bug: in ERE `\|` is a literal pipe, so an intended OR is
           broken — confirm the *runnable* form uses a bare `|` (even if a markdown
           renderer forced the `\|` in the table cell, the command you actually run must
           use bare `|`); do NOT dismiss it as "probably benign escaping").
           This is ADVISORY (warn, continue) — it NEVER blocks step1d or the handoff,
           and its exit code is always 0. It complements (does NOT replace) the manual
           dry-run; treat it as a smoke alarm that mechanically catches the lintable
           subset of the recurring AC-verification-drift class.
      exemption_doc_only: |
        Skip step1d for handoffs with task_type=doc-only AND empty §9.1.
      exemption_pre_phase6: |
        BA-P1-1 fix: AND not OR. Pre-Phase-6 handoffs (filename date < 2026-04-25
        AND no §9.1 dual columns): skip step1d.
        NEW handoffs (date >= 2026-04-25) MUST have dual columns; missing dual cols
        is a step1 draft error, not exemption case.
      violation_self_audit: |
        At step2, if §9.1 has rows but no AC Dry-Run Log section AND no exemption:
        self-audit failed → return to step1d.
      forbidden_implementations:
        - "MUST NOT skip step1d under Anti-AR-001 rationalizations ('small handoff = step1d skippable' OR 'all post-impl so step1d value-less'); step1d's value includes Sub-rule 2 syntax validation regardless of pre/post split."
        <!-- Platform binding: harness hook config (`.codex/hooks.json`) -->
        - "MUST NOT turn verify-ac-commands.sh (the step1d advisory tail linter) into a blocking gate: it MUST NOT be registered as a PreToolUse / UserPromptSubmit / SessionStart hook, MUST NOT be added to .claude/settings.json, MUST NOT return a deny/blocking exit, and a WARN/INFO from it MUST NOT block the handoff (advisory smoke alarm only — single-user-CLI mechanical-enforcement-rejected lesson 2026-04-15)."

    step2:
      name: "Gate 2 reviewers"
      action: "根据 risk_triggers 确定两个不同 lens 的 reviewer"
      rule: "Two reviewers with different lenses per the review contract: consistency (MANDATORY; code-reviewer on Claude Code) plus one risk reviewer covering risk_triggers, or fit when none"

    step3:
      name: "Parallel Gate 2 Review"
      action: "dispatch both in parallel; each prompt = the contract's §0 list; outputs under `.tad/evidence/reviews/alex/<slug>/`"
      execution: "使用 Task tool 并行调用两个 reviewer"

    # Agent Teams review mode retired 2026-10-19 (EPIC-20261019-review-redesign): its cross-challenge asked reviewers whether a P0 "could be downgraded", against AR-001; Gate 2 composition is the review contract's.

    step4:
      name: "Feedback Integration"
      action: "整合专家反馈，更新 handoff"
      updates:
        - "添加 Expert Review Status 表格"
        - "添加 P0 Blocking Issues（如有）"
        - "补充专家建议的类型定义/测试/安全措施"
      audit_trail_requirement: |
        (Phase 1 P1.5, 2026-04-24) 将每个专家反馈 integrate 为 Audit Trail 4-列表格一行：
        | Reviewer | Issue | Resolution Section | Status |
        Status 字段必填（Resolved / Open / Deferred）。
        Resolved MUST point to the resolution section in the handoff
        (e.g., "§Task P1.2 实现提示 #3" or "AC-P1.2-i") — 不是"已修复"这种自由文本。
        自由文本不可接受；表格是 canonical format。
        Rationale: toy 项目自发演化出此格式，比自由文本更可审计，且使未来 /tad-maintain
        能对"哪些 P0 被真正解决"做结构化扫描。
        Template reference: .tad/templates/handoff-a-to-b.md §9.2.

    step5:
      name: "Gate 2 Check"
      action: "执行 Gate 2: Design Completeness"

    step6:
      name: "Ready for Implementation"
      action: "更新 handoff 状态为 Ready for Implementation"
      final_status: "Expert Review Complete - Ready for Implementation"

    step7_execution_mode:
      name: "Execution Mode Selection"
      trigger: "Handoff 通过 Gate 2 AND handoff 有 Epic 字段（多 Phase 任务）AND not dispatched by a conductor"
      skip_if: "Handoff 没有 Epic 字段（单 handoff → 直接走手动 step7）; or this session was dispatched by a conductor (the conductor routes)"
      action: |
        AskUserQuestion:
        question: "Handoff 已通过设计审查。这是 Epic {slug} 的 Phase {N}/{M}。怎么执行？"
        options:
          - "我来传递给 Blake（手动）": "生成 Blake message，你来复制到 Terminal 2"
          - "交给 Cora 跑完这个 Epic": "Alex 到此为止；你新开一个会话，第一句话说：Read .agents/skills/cora/SKILL.md and follow it. You are Cora. 她从磁盘接手并派发后续步骤"
        If "手动" → proceed to step7 (existing Human Handover)
        If "交给 Cora" → give the human that sentence and stop. Alex does not conduct. Note for the human: an Epic that Alex created has no `**Conductor**: Cora` line; Cora will ask before she takes it over.

    step7:
      name: "⚠️ STOP - Human Handover"
      action: "停止当前会话，生成给 Blake 的信 + 人话版解释，等待人类传递"
      blocking: true
      generate_message: |
        Alex MUST auto-generate the following structured message.
        All {placeholders} must be replaced with actual values from the handoff.
        The message inside the code block is designed for the human to copy-paste directly to Terminal 2.

        ⚠️ ORDER REQUIREMENT (MANDATORY):
        The response output MUST be in this exact order:
          1. The 人话版 section (defined below) — appears FIRST
          2. The structured Blake message in code block — appears SECOND
        Rationale: user sees the explanation before the technical block they need to copy.

        Output format (structured Blake message — appears SECOND in response):
        ---
        ## ✅ Handoff Complete

        我已生成一封给 Blake 的信，请复制下方内容到 Terminal 2：

        ```
        📨 Message from Alex (Terminal 1)
        ────────────────────────────────
        Task:     {handoff title from the handoff document}
        Handoff:  .tad/active/handoffs/HANDOFF-{date}-{name}.md
        Priority: {P0/P1/P2/P3 - from handoff or assessment}
        Scope:    {1-line summary of what Blake needs to implement}

        Key files:
        {list of primary files to create/modify, one per line, prefixed with "  - "}

        ⚠️ Notes:
        {any warnings, constraints, or special instructions - or "None" if straightforward}

        Action: *develop {task-id if applicable}
        ────────────────────────────────
        ```

        ⚠️ **我不会在这个 Terminal 调用 /blake**
        手动路径：由人类把这封信转给 Blake。Cora 运行的 Epic 里由 Cora 派发 Blake。

        > 💡 如果 Blake 已经在运行，直接粘贴即可。
        > 如果 Blake 尚未启动，先执行 `/blake`，Blake 会自动检测到这个 handoff。
        ---

        ---

        PLAIN-LANGUAGE EXPLANATION (MANDATORY)

        After the structured Blake message above, the response MUST also include
        a plain-Chinese explanation section addressed to the human user (NOT Blake).
        As specified by ORDER REQUIREMENT, this section appears FIRST in the
        actual response output, even though it is documented here second.

        Heading: ## 🗣️ 人话版：这一步是什么意思

        plain_language_rules:
          description: "人话版质量规则 — 读者价值测试，不是结构合规检查"
          test: |
            读完人话版，用户应该能回答：
            1. 这件事改完后我的体验具体哪里不同了？（不是"改了哪些文件"）
            2. 为什么走这条路而不是其他路？（不是"TAD 流程规定"）
            3. 接下来我需要做什么决定或注意什么？
          fail_condition: "如果任何一个答案换个任务也能用 → 重写"
          length: "上限 2-3 段。说不清楚不是因为篇幅不够，是因为没想清楚。"
          anti_patterns:
            - "❌ 模板化：每次差不多的套话（'Blake 将按照 handoff 执行...'）"
            - "❌ 啰嗦：重复 handoff 里已有的信息"
            - "❌ 不解释为什么：只说做了什么，不说为什么这么选择"
            - "❌ TAD 术语堆砌：Gate/Phase/Layer 对用户无意义时不用"
      forbidden: "在同一个 terminal 调用 /blake = VIOLATION"
      violation_plain_language: "Generating Blake message without the 人话版 section in same response = VIOLATION. Wrong order (technical block before 人话版) = VIOLATION. Formulaic compliance (no task-specific content) = VIOLATION."

  lens_selection:
    always: "consistency (code-reviewer on Claude Code): contradictions, consumers of changed lines, the baseline run of every §9.1 command"
    from_risk_triggers: "one risk reviewer covers every listed trigger (security | data | money | ui | platform | domain), one section per lens"
    when_none: "fit (is this what the requirement asks, is the size proportionate, does the premise hold); yields questions or P1, never P0"
    examples: "the review contract §9 mapping (Claude Code examples: security-auditor, database-expert, backend-architect, ux-expert-reviewer, devops-engineer, product-expert)"

  reviewer_prompt: "Load .tad/templates/review-contract.md and follow it. Lens: {lens}. Object: {handoff_path}. Reference: the handoff's §1.5 (carrying the human's request verbatim) and §9 (or the Epic's ## Requirement and ## Result contract). Previous round: {file|none}. Questions path (fit only): {path}. Write {path}; start with the verdict header (model: key included)."
  # The narrow-scope rule of the old prompt template is replaced by review contract §2 ("read the object and the reference first"): consistency needs the consumers of changed lines.

  minimum_reviewers: 2  # two different lenses; never below one independent reviewer (AR-001)

  # Rounds (review contract §7), restated for direct /alex. History: the 2026-08-17 cap of 2 rounds
  # (EPIC-20260816: a single review ran 5 rounds polishing one markdown link) is replaced by the
  # round-3 upstream rule below; the rule keeps the loop bounded without forcing new findings to P1.
  rounds:
    round_1: "both lenses review the whole handoff."
    round_k_ge_2: |
      Only the lens(es) whose latest file has a P0, FAIL or PARTIAL are re-dispatched. Each reviewer receives:
        (a) the fix diff
        (b) the open P0 list with the full reason of each, not only the title
        (c) the full text of every section the diff touches
      MUST NOT re-send the whole handoff: re-reading everything lets a reviewer re-open parts unrelated to the fix, which feeds the loop.
      A fix that changes risk_triggers re-dispatches the risk lens. Each reviewer labels new_p0 and origin from its own lens's previous file; an introduced_by_fix P0 is fixed as a class.
    round_3_open_p0: |
      Round 3 (counted from round 1 or the last re-plan) with an open P0 -> stop reviewing and look upstream: Alex writes the premise (one sentence the failed fixes share, one observation that differs if it is false), checks it by a read, grep or local command, and re-plans the handoff once.
      A second time, or a re-plan that would change the result or scope, goes to the human:
        "本单 3 轮审查后仍有 P0，任务可能超出范围或方案不成立。P0 列表：{每条含标题 + 完整理由 + 影响面}。请裁定：缩小范围 / 换方案 / 撤单。"
      There is no option "accept the risk and continue": it turns an agent-side loop into a human-side one, Alex controls the wording, and an unfixed P0 vanishes at the human's nod.
      There is no round 4 without a re-plan, whatever the human says.
      MUST NOT start a 4th review round with an open P0 before the premise re-plan.
      MUST NOT hand a FAIL handoff to Blake.

  p0_resolved_definition: |
    Gate 2 "P0 resolved" = the latest round's file of every lens is PASS or CONDITIONAL (`p0_count: 0`).
    Alex's own assertion "fixed" is not resolved.
    A "fixed" claim MUST NOT stand in for the latest round's files.
    A CONDITIONAL file has no P0; its open P1s go into handoff §10 as known trade-offs (carried).
    There is no third way: "the human decides to go on" is not a resolution; the human's options at round 3 are narrow the scope / change the approach / withdraw, none of which leads into Gate 2 with an unresolved P0.

  violations:
    - "No handoff to Blake without the two Gate 2 lenses = VIOLATION"
    - "Ignoring a P0 a reviewer found = VIOLATION"
    - "A 4th review round with an open P0 and no premise re-plan = VIOLATION (whatever the human says)"
    - "A FAIL handoff to Blake, or re-sending the whole handoff from round 2 instead of the diff = VIOLATION"
    - "Offering 'accept the risk and continue' = VIOLATION"
