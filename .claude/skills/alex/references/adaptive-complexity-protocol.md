# Adaptive Complexity Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

adaptive_complexity_protocol:
  description: "When user first describes a task, Alex assesses complexity and suggests process depth. HUMAN makes the final decision."
  trigger: "User describes a task or need for the first time in the session"
  blocking: true

  # Alex's internal assessment signals
  assessment_signals:
    small:
      indicators:
        - "Single file or 2-3 closely related files"
        - "Configuration change, UI tweak, simple bug fix"
        - "Clear requirements, no ambiguity"
        - "No architectural impact"
      suggested_depth: "light"
    medium:
      indicators:
        - "3-8 files across 1-2 modules"
        - "New feature, API change, moderate refactor"
        - "Some ambiguity in requirements"
        - "Touches existing patterns but doesn't change them"
      suggested_depth: "standard"
    large:
      indicators:
        - "8+ files or 3+ modules"
        - "Architecture change, new system, complex feature"
        - "Significant ambiguity or trade-offs"
        - "Creates new patterns or changes existing ones"
      suggested_depth: "full"

  # Process depths (presented to user)
  process_depths:
    full:
      label: "Full TAD"
      description: "Complete Socratic Inquiry (6-8 questions) → Expert Review → Detailed Handoff → All Gates"
      when: "Architecture changes, complex features, high-risk work"
    standard:
      label: "Standard TAD"
      description: "Moderate Inquiry (4-5 questions) → Handoff → Gates"
      when: "New features, API changes, multi-file modifications"
    light:
      label: "Light TAD"
      description: "Brief Inquiry (2-3 questions) → Quick Handoff → Streamlined Gates"
      when: "Small features, config changes, straightforward modifications"
    skip:
      label: "Skip TAD"
      description: "Direct implementation, no formal handoff process"
      when: "Trivial fixes, user explicitly wants speed over process"

  # Execution flow
  execution:
    step1:
      name: "Assess"
      # ⚠️ ANTI-RATIONALIZATION: "这明显是 small 任务，问用户只是浪费时间"
      # → Alex 评估≠人类决策。人类可能知道看似简单需求背后有技术债务。跳过选择 = 剥夺控制权。
      action: |
        Analyze the user's request against assessment_signals.
        Determine complexity: small / medium / large.
        Map to suggested process depth.

    step2:
      name: "Suggest"
      action: |
        Use AskUserQuestion to present the assessment and let user decide.
        Alex explains WHY this depth is suggested (1-2 sentences).
        IMPORTANT: Alex SUGGESTS, human DECIDES. Never auto-select.

      format: |
        AskUserQuestion({
          questions: [{
            question: "我评估这个任务为 {complexity} 复杂度，建议使用 {suggested_depth} 流程。你觉得呢？",
            header: "Process depth",
            options: [
              {label: "{suggested option} (Recommended)", description: "{why this is recommended}"},
              {label: "{next higher option}", description: "{description}"},
              {label: "{next lower option}", description: "{description}"},
              {label: "Skip TAD", description: "Direct implementation, no formal process"}
            ],
            multiSelect: false
          }]
        })

    step2b:
      name: "Epic Assessment"
      action: |
        After user selects process depth (standard or full), assess if the task
        needs multiple phases (>1 handoff). This is an INTERNAL assessment.

        Epic assessment signals (any 2+ = suggest Epic):
        - User description contains sequential language ("first...then...after that...")
        - Task involves 3+ independent functional modules
        - Intermediate testing/validation needed before continuing
        - Involves progressive migration or refactoring
        - Estimated 3+ handoffs to complete

        Before creating Epic, check active count:
        1. Count files in .tad/active/epics/ (excluding .gitkeep)
        2. If count >= max_active_epics (3 from config):
           → Warn user: "已有 {N} 个活跃 Epic，建议先完成现有 Epic"
           → User can override via AskUserQuestion

        If signals detected AND user chose standard/full:
          Use AskUserQuestion:
            question: "这个任务预计需要多个阶段，建议创建 Epic Roadmap 来追踪整体进度。"
            options:
              - "创建 Epic (Recommended)": "先规划整体 Phase Map，再逐阶段创建 Handoff"
              - "直接用单个 Handoff": "作为一个大 Handoff 处理，不创建 Epic"

        If user chooses "创建 Epic":
          1. Create Epic file: .tad/active/epics/EPIC-{YYYYMMDD}-{slug}.md
             - Use .tad/templates/epic-template.md as base
             - Fill Objective, Success Criteria, Phase Map TABLE (overview)
          2. For EACH Phase in the Phase Map: fill the Phase Detail Block
             - Scope: derive from Socratic discussion context (≥2 sentences, explicit NOT-in-scope)
             - Input/Output: derive from phase sequencing (Phase N input = Phase N-1 output)
             - AC: at least 3 per Phase, specific and verifiable
             - Files Likely Affected: derive from scope + codebase knowledge (≥1 concrete path with CREATE/MODIFY)
             - Dependencies: derive from phase ordering
             - Execution: set to "pending" (user chooses mode at confirmation)
          3. AskUserQuestion: confirm Epic + Phase definitions
             question: "Epic 和 Phase 定义如下，确认后开始 Phase 1。"
             options:
               - "确认，开始 Phase 1": "创建 Phase 1 handoff，准备交给 Blake 实现"
               - "需要调整": "修改 Phase 定义后重新确认"
          4. After confirmation: create first Phase's Handoff (linked to Epic)
          5. Handoff header includes: **Epic:** EPIC-{YYYYMMDD}-{slug}.md (Phase 1/{N})

        If user chooses "单个 Handoff" or signals not detected:
          Proceed normally without Epic.

    step2b_phase_detail_check:
      name: "Phase Detail Block Sufficiency Check (pre-Socratic)"
      trigger: "After step2b, before Socratic Inquiry — only when continuing an existing Epic"
      action: |
        If an active Epic exists in .tad/active/epics/ AND the current task is
        starting the next Phase (not creating a new Epic):
          1. Read the Epic file
          2. Find the next ⬚ Planned Phase in the Phase Map
          3. Look for the corresponding Phase Detail Block (### Phase {N}: {name})
          4. If no Phase Detail Block found → skip (backward compat, normal Socratic)
          5. Run sufficiency check:
             - Scope: ≥2 sentences (not placeholder like "TBD" or "{...}")
             - AC: ≥3 items, each with checkbox (- [ ]) and ≥1 of: file path, command, numeric threshold, or comparison operator
             - Files: ≥1 concrete path with CREATE/MODIFY annotation (not "TBD" or "{...}")
          6. If ALL pass:
             → Set Socratic depth to "light" tier (2-3 questions per socratic_inquiry_protocol)
             → Announce: "Phase {N} 已有详细定义，苏格拉底提问将简化为 light 模式（2-3 个问题）。"
             → Light questions should focus on dimensions NOT in the Detail Block
               (risk_foresight, user_scenarios, edge cases)
          7. If ANY fail:
             → Normal Socratic depth
             → Announce: "Phase {N} 定义不够详细（{which check failed}），需要完整苏格拉底提问。"
        If no active Epic or creating a new Epic → skip entirely.

      epic_assessment_signals:
        sequential_language: ["first...then", "先...再...然后", "phase", "阶段", "分步"]
        multiple_modules: "3+ independent functional modules"
        intermediate_validation: "needs testing between stages"
        progressive_change: "migration, refactoring, gradual rollout"

    step2c_github:
      name: "GitHub Registry Check"
      trigger: "User confirmed process depth (step2 done), before Socratic Inquiry starts"
      error_blocking: false
      user_interaction: conditional
      skip_conditions:
        - "User chose 'Skip TAD' or 'Light TAD' in step2 — proceed directly without GitHub check"
        - ".tad/github-registry/REGISTRY.yaml not found → skip silently"
      failure_handling: |
        REGISTRY.yaml malformed → log warning, skip step entirely (do NOT clear notebook_id)
        Cross-reg notebook_id stale → write cleared value back to github-registry REGISTRY
        notebooklm CLI unavailable → skip refresh silently, still announce notebook exists
        notebooklm auth expired → skip refresh silently, announce "results may be slightly stale"
        Mutation policy: use Edit tool on REGISTRY.yaml; ONLY clear notebook_id and last_researched
                         fields for the matched domain; preserve all other fields and YAML comments
      action: |
        1. Read .tad/github-registry/REGISTRY.yaml (if not found → skip silently)
        2. Extract keywords from user's task description (LLM semantic match against domain name/slug)
        3. Match against domain names/slugs in REGISTRY

        4. If match found AND domain has notebook_id (notebook exists):
           a. Cross-check: Read .tad/research-notebooks/REGISTRY.yaml
              → Find entry by notebook_id
              → If status == "archived" → skip, clear notebook_id in github-registry REGISTRY
              → If entry not found → skip, clear notebook_id (stale reference)
              → If status == "active" or "dormant" → proceed to refresh
           b. Auto-refresh notebook (変更 A caps: ≤10 sources checked, ≤5 refreshed, 30s timeout)
           b2. After refresh: update last_refreshed for this notebook in .tad/research-notebooks/REGISTRY.yaml:
               yq -i '(.notebooks[] | select(.id == "<notebook_id>") | .last_refreshed) = "<YYYY-MM-DD>"' \
                 .tad/research-notebooks/REGISTRY.yaml
               (prevents *ask Step 2b from double-refreshing in the same session)
           c. Extract source_count from the research-notebooks REGISTRY entry found in step 4a.
              Output: "📦 Found research notebook for '{domain}' ({source_count} sources, refreshed). Key findings available during design."
           d. No AskUserQuestion — passively available for Socratic + design

        5. If match found AND no notebook_id (no notebook yet):
           → AskUserQuestion: "'{domain}' 领域有 {N} 个 awesome-list。要先研究参考项目再开始设计吗？"
             Options: "研究一下 (Recommended)" / "跳过，直接设计"
           → "研究一下" → delegate to *research-github explore <slug> + notebook <slug>
             → If user cancels notebook creation mid-delegation → announce "操作已取消。进入设计阶段。" and proceed to step3
             → After successful delegation: announce "Research complete. 回到你的任务。"
           → "跳过" → continue
        6. If no match → skip silently

        → ALWAYS proceed to step3 (Socratic Inquiry) after this step completes

    step3:
      name: "Proceed"
      action: |
        Based on user's choice:
        - full: Run Socratic Inquiry with ALL dimensions (6-8 questions)
        - standard: Run Socratic Inquiry with 4-5 questions (medium complexity rules)
        - light: Run Socratic Inquiry with 2-3 questions (small complexity rules)
        - skip: Inform user they can implement directly. Exit Alex if appropriate.

  # Integration with existing Socratic Inquiry
  integration: |
    The user's chosen depth OVERRIDES the internal complexity_detection in socratic_inquiry_protocol.
    If user picks "light" for a task Alex assessed as "large", respect the user's choice.
    The complexity_detection section still determines WHICH dimensions to ask about,
    but the depth choice controls HOW MANY questions and HOW DETAILED the process is.

