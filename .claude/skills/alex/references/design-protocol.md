# Design Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

design_protocol:
  description: "Technical design creation workflow"
  tool: "AskUserQuestion"

  steps:
    step1:
      name: "Review Socratic Inquiry Results"
      action: "Confirm all requirements are clarified from Socratic Inquiry"

    step1_5:
      name: "Capability Pack Loading"
      action: |
        Merged into step1_5b below. This step is now a no-op placeholder for backward
        compatibility with existing handoff references. Proceed directly to step1_5b.

    step1_5b:
      name: "Capability Pack Loading (from registry)"
      trigger: "After Socratic Inquiry (step1)"
      action: |
        1. Read .tad/capability-packs/pack-registry.yaml
           If not found → skip this step entirely (no error)

        2. Match task keywords against each pack entry's `keywords` + `description`:
           - Use semantic matching (LLM judgment, same approach as step1_5)
           - Consider both Chinese and English keywords in the pack entry
           - A pack matches if it serves the user's stated task

        3. Dedup: if ≥2 matched packs share a domain, note the overlap but let user decide.

        4. If ≥1 match found — 3-tier pack lookup (AC2):
           For EACH matched pack, determine availability:

           Tier 1 — pack source installed (TAD project):
             Check: .tad/capability-packs/{pack_name}/CAPABILITY.md exists
             → Load CAPABILITY.md directly from this path

           Tier 2 — pack installed as skill (downstream project or manual install):
             Check: .claude/skills/{pack_name}/SKILL.md exists
             → Load that SKILL.md as the pack content

           Tier 3 — pack matched but not installed:
             Neither path exists → offer install via AskUserQuestion:
             "检测到 '{pack_name}' pack 与你的任务相关，但未安装。要安装吗？"
             Options: "安装 (Recommended)" / "跳过"

             If user chooses 安装:
               → Read registry fields: source_repo, source_branch, source_base_path
               → Display BOTH install commands (Alex does NOT run them — user copies):

               If source_repo is present in registry:
                 P1-4: Display pack URL first so user can verify before running pipe-to-bash:
                   "Pack 来源: https://github.com/{source_repo}/tree/{source_branch}/{source_base_path}/{pack_name}/
                    请先访问此 URL 确认 pack 存在，再运行下面的安装命令。"

                 私有仓库 (gh CLI, works with existing GitHub auth):
                   gh api "repos/{source_repo}/contents/{source_base_path}/{pack_name}/install.sh?ref={source_branch}" \
                     --jq '.content' | base64 -d | bash -s -- --agent=claude-code

                 公开仓库 (curl, no auth needed):
                   curl -sSL "https://raw.githubusercontent.com/{source_repo}/{source_branch}/{source_base_path}/{pack_name}/install.sh" \
                     | bash -s -- --agent=claude-code

                 Note: "私有仓库用 gh 命令，公开仓库用 curl 命令。运行后重启对话，pack 将在下次自动加载。"
                 P1-3 404 hint: "如果命令返回 404，pack 可能尚未推送到远端。请先检查上方 URL 确认文件存在。"

               If source_repo missing from registry (AC6 fallback):
                 Display: "无法自动安装 — pack registry 缺少 source_repo。
                           请手动从 GitHub clone TAD 仓库，然后运行：
                           bash .tad/capability-packs/{pack_name}/install.sh --agent=claude-code"

           a. Present matched packs (with tier labels) to user via AskUserQuestion:
              "Based on your task, these Capability Packs may be useful:
               - {pack.name} [{type}] {if Tier 2: '(installed as skill)'} {if Tier 3: '(not installed)'}:
                 {pack.description (first 80 chars)}
                 (CONSUMES: {pack.consumes} → PRODUCES: {pack.produces})
               Confirm which packs to use?"
              Options: up to 4 packs as options + "None — skip packs"
           b. On confirmation, load confirmed pack CAPABILITY.md (Tier 1) or SKILL.md (Tier 2)
           c. State persistence: Record confirmed packs as:
              "🎯 Loaded Capability Packs: {pack1}, {pack2}"

        5. If ≥2 confirmed packs:
           a. Analyze CONSUMES/PRODUCES chain from pack entries
              Order rule: if pack-A's `produces` contains keywords from pack-B's `consumes`,
              pack-A must run before pack-B. Check string overlap, not just LLM judgment.
              (e.g., web-ui-design.produces "DESIGN.md" matches web-frontend.consumes "DESIGN.md")
           b. Propose serial execution order based on data flow
              (e.g., web-ui-design → product-thinking → web-backend)
           c. AskUserQuestion:
              "建议按此顺序使用 {N} 个 pack:
               {pack1} → {pack2} (→ {pack3})
               确认顺序，或调整？"
              Options: "Confirmed order" / "Reorder" / "Run independently"

        6. Pack count guardrail:
           If registry has >12 packs, only show top 4 matches
           Ranking: by keyword overlap count (most overlapping keywords first),
           then alphabetical for ties. Cap at 4 to respect AskUserQuestion 4-option limit.
           Note to user: "Also potentially relevant (not shown): {5th, 6th ...}"
           (≤12 accuracy threshold — per research RS-20260508-002; AskUserQuestion 4-option cap)

        7. Use loaded Capability Pack content in subsequent *design steps:
           - Reference pack rules when designing architecture
           - Reference pack quality criteria when defining ACs
           - Reference pack anti-patterns when identifying risks

      note: |
        Capability Packs (SKILL.md based) are the only active pack format.
        YAML Domain Packs have been retired (2026-06-11) and archived to
        .tad/archive/domains/.

      skip_conditions:
        - "pack-registry.yaml not found (packs not installed)"
        - "No matching pack found for this task"
        - "User chose 'None — skip packs'"
        - "Light TAD process depth"

    step1_5c:
      name: "Tournament Option (competitive design exploration)"
      trigger: "After pack loading (step1_5b), for Full or Standard TAD depth"
      action: |
        If user chose Full TAD or Standard TAD depth:
        Use AskUserQuestion to offer tournament exploration:
          "This design has multiple valid approaches. Want to explore them via tournament?"
          Options:
            - "Tournament — 2 competing designs + judge + merge (~200-220K tokens) (Recommended for ambiguous decisions)"
            - "Deep tournament — 3 competitors + pairwise judges (~320K tokens, for high-stakes architecture)"
            - "Skip — single-agent design (faster, sufficient for clear requirements)"

        If user picks tournament or deep tournament:
          1. Collect prior_art: Ask user for 2-3 prior art sources (URLs, file paths, or descriptions).
             prior_art is REQUIRED — each competitor gets one source to base their design on.
             This forces divergent starting points (mitigates single-model convergence).
          2. Optionally collect custom rubric dimensions (or use defaults: feasibility, elegance, extensibility, principle_alignment)
          3. Detect platform and route:
             platform=$(bash .tad/hooks/lib/detect-platform.sh)
             If "workflow" → Invoke: Workflow({name: 'tournament-design', args: {task: <design_task>, prior_art: <sources>, mode: 'standard'|'deep'}})
             If "codex"    → Write task + prior_art to temp files, invoke: bash .tad/codex/tournament-codex.sh --task <file> --prior-art <f1> <f2> --output <result.json>
                             (Codex: standard mode only, deep not supported. Warn user if they chose deep.)
             If "none"     → Announce: "No multi-agent backend available. Running single-agent design (no tournament)."
                             Continue with normal *design flow (step2 onwards) using single-agent.
          4. Use the merged_design from the result as input for the rest of *design

        If user picks skip: continue normal *design flow (step2 onwards)

      skip_conditions:
        - "Light TAD process depth"
        - "User chose 'Skip TAD' in adaptive complexity"
        - "*express or *experiment paths (tournament not applicable)"

    step2:
      name: "Frontend Detection & Feedback Collector"
      action: |
        If any relevant Capability Pack was loaded in step1_5b, reference its rules
        in design suggestions (e.g., web-frontend pack for component patterns,
        web-backend pack for API conventions, ai-agent-architecture for agent design).
        If task involves frontend/UI, set feedback_required: true in handoff §8.5 with artifact_type: frontend_page.
        Blake will generate overlay feedback HTML alongside the artifact.
        Reference any existing design context in .tad/project-knowledge/frontend-design.md.

    step3:
      name: "Create Architecture Design"
      action: |
        If icp_anchor was defined in Socratic Inquiry:
          Use as design test anchor throughout architecture decisions.
          For each major design decision, ask: "Would [ICP] understand/value this?"
        Design system architecture, data flow, API contracts.

    step4:
      name: "Create Data Flow / State Flow Diagrams"
      action: "Map data flows and state management as required by MQ3/MQ5"

    step5:
      name: "Proceed to *handoff"
      action: "Transition to handoff_creation_protocol"

  note: "Playground is DEPRECATED (2026-06-10). Use Feedback Collector (handoff §8.5 feedback_required: true) for frontend/design tasks."

