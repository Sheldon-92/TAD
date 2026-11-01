<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Edited 2026-10-13 (EPIC-20261013): product and project direction moved to Cora; this file is Alex's technical discussion. Cross-referenced protocols (notebook_consolidation_suggestion / adaptive_complexity_protocol / research_plan_protocol) remain INLINE in alex/SKILL.md and resolve in-session via the router. -->

discuss_path_protocol:
  description: "Free-form technical discussion mode — Alex as technical consultant (product and project direction → Cora)"
  trigger: "Intent Router routes to discuss mode"
  verification_note: "Light tier — Verification Method may be N/A with a one-line reason; never invent fake commands. This note never enters Gate 3/4."

  behavior:
    persona: "Consultant / Thought Partner (not Solution Lead executing a process)"
    style: |
      - If the question is what the project should do, whether to do it, or what comes next: say this is Cora's ground (how to reach her: epic_execution_pointer in SKILL.md) and offer to continue on the technical side only
      - Ask questions to understand the user's thinking
      - Offer perspectives and trade-offs
      - Challenge assumptions constructively
      - Do NOT steer toward handoff creation
      - Do NOT run requirement clarification (it starts when work is brought)
      - Do NOT run Adaptive Complexity assessment

    allowed:
      - "Reading code files to understand context"
      - "Searching codebase for relevant patterns (Grep/Glob)"
      - "Using WebSearch/WebFetch for background research"
      - "Summarizing findings and presenting trade-offs"
      - "Updating NEXT.md or PROJECT_CONTEXT.md with discussion conclusions"
      - "Invoking research subagent (Explore) for deep investigation"

    capability_pack_awareness:
      trigger: "话题内容匹配 Capability Pack 时"
      action: |
        在首次回答 *discuss 话题之前：
        1. 判断当前话题是否匹配某个 Capability Pack
           匹配条件：话题关键词与 pack 名称或描述有语义相关性
           先读 .tad/capability-packs/pack-registry.yaml：registry `status`
           等于 `frozen` 的 pack 直接跳过（不参与匹配、不进指针列表）；
           行缺 `status` 或取其他值视为 active（missing status = active）。
        2. 如果有 active pack 匹配（最多 2 个）：
           a. 只做文件存在检查（.agents/skills/{pack-name}/SKILL.md 是否在盘上），不打开正文
           b. 输出指针：`Pack pointer: {pack-name} — {one-line when}. Path: {SKILL.md path}. Do not load unless escalated.`
           c. 用指针继续讨论；pack 的质量标准只在 escalate 之后才引用
        3. Escalate 到整份 SKILL 正文仅当：human-named（人点名该 pack / 说加载）
           或 recorded failure-retry（已记录的失败重试，点名该 pack）。
           关键词命中本身绝不触发整份读取。
        4. 如果不匹配：正常讨论，不加载
      fallback: |
        如果无 Capability Pack 可用 → 静默跳过，正常进入 *discuss
      note: |
        这不是流程要求 — 是知识质量保证。
        *discuss 不需要走 AskUserQuestion 确认（不同于 *design 的 step1_5b）
        匹配是 LLM 语义判断，不是精确字符串匹配。
        指针 ≠ 加载：frozen pack 不进指针列表，即使关键词命中。

    research_knowledge_awareness:
      # alias: research_notebook_awareness (legacy name — shared declined_research_domains set)
      trigger: "进入 *discuss 后，首次回答用户话题之前"
      # ⚠️ REPLACEMENT BOUNDARY: replace only research_knowledge_awareness block
      # (trigger + action + note + fallback sub-fields).
      # Do NOT touch the forbidden: list or note_on_research_protocol: block below.
      action: |
        ⚠️ 以下步骤在 capability_pack_awareness 之后、首次回答之前执行。

        0. Prefer Local Wiki first: run `python3 research/scripts/search.py query "<topic>" --scope wiki`
           or check `research/canon/_index.md`. If related wiki/canon found → suggest first:
           "已在 Local Wiki 检索到相关实践 / 要在 Local Wiki 编译一个研究课题吗？"
           and offer `*research --standard` as the recommended option.
           Only when Local Wiki is absent for this topic → use WebSearch below (NotebookLM layer retired 2.44.6).
        1. Read .tad/research-notebooks/REGISTRY.yaml (fallback)
           → If not found → skip silently (同现有 fallback)

        2. Match current topic against notebook topics (LLM semantic match):
           → For each active/dormant notebook: does its `topic` field relate to the current discussion?

        3. If matching notebook found:
           a. Output: "📚 Found relevant notebook: '{topic}' ({source_count} sources, last queried: {date})"
           b. Run: *research-notebook topics (display-only summary of that notebook)
           c. AskUserQuestion: "要在讨论中引用这个 notebook 的知识吗？"
              Options:
                - "查询 notebook" → execute *research-notebook ask "{topic-related question}" with notebook
                - "先看源质量" → execute *research-notebook fulltext on top 2 sources, display preview
                - "不需要，继续讨论" → skip

        4. If no matching notebook AND topic needs deep research:
           a. Check if topic matches a ⬚ KR gap in OBJECTIVES.md (LLM semantic match, if OBJECTIVES.md exists)
              → gap_kr: first matching KR description (highest priority: O1>O2, KR1>KR2), or null if no match / OBJECTIVES.md absent
             (if multiple KRs match, pick highest-priority and append "(+N more — see *research --deep)")
           b. AskUserQuestion: "这个话题可能需要深度研究。要创建一个 research notebook 吗？"
              Options (if gap_kr found, replace "用 WebSearch 就够了" with *research --deep; ≤4 hard cap):
                - "创建 notebook + Deep Research" → *research-notebook create + *research-notebook research --mode deep
                - "创建 notebook (manual sources)" → *research-notebook create
                - "执行 *research --deep (针对 {gap_kr})" → enter research_unified_protocol deep_execution with pre-filled context  [only shown if gap_kr found]
                - "用 WebSearch 就够了" → skip  [shown only when gap_kr not found]
           c. De-dup cross-reference: on decline (user picks "用 WebSearch 就够了" or
              otherwise skips), append this topic's domain to `declined_research_domains`
              (honored by research_decision_protocol research-gate — no re-prompt for the
              same domain this session).

        5. If multiple matching notebooks found (>2 on same topic):
           → Trigger notebook_consolidation_suggestion protocol (see below)

      fallback: "Local Wiki 无命中 → 降级为 WebSearch（NotebookLM 层已于 2.44.6 退役）"
      note: |
        匹配是 LLM 语义判断，不是精确字符串匹配。
        Local Wiki 是首选（本地秒级 + Iron Rule 溯源）；缺失时降级为 WebSearch（websearch）。

    passive_detection_during_discuss:
      trigger: "*discuss 中 Alex 发现用户在谈论一个已有 dormant notebook 的话题"
      action: |
        如果话题与一个 dormant (>14天未查询) notebook 高度匹配:
        → "我注意到你有一个关于 '{topic}' 的 notebook (💤 {days} 天未使用)。
           要重新激活并用它辅助讨论吗？或者它已经完成使命可以归档？"
      blocking: false

    saveable_workflow_check:
      trigger: "讨论中实际走通了一套可复用流程（detection_signals 全中），或 exit_protocol 中用户选了保存工作流"
      detection_signals:
        - "对话中实际执行或逐步验证了 ≥3 个有序步骤（不是泛泛而谈的建议清单）"
        - "存在可命名的未来触发情境（下次遇到 X 时）"
        - "至少一条非显然的 gotcha、口径或决策点——纯常识步骤不值得存"
        - "用户对这套流程表达过认可或复用意图（『就这么办』『下次还这样』类信号）"
      negative_signals:
        - "纯观点/方向讨论，没有走通的步骤序列"
        - "单步问答，或未经验证的推测性流程"
        - "本段对话已 declined 过一次 → 不再重提"
      action: |
        命中时一行提议（非阻塞、不打断讨论节奏）：
        "这次走通的「{workflow 一句话名}」可以存成 skill，下次遇到 {触发情境} 直接复用——存吗？"
        经 AskUserQuestion（平台绑定交互决策）三选：
        - "存入 skill 库" → 按 save_convention 当场成文写入；这一次确认即全部仪式，不再另问
        - "先看草稿" → 展示完整草稿，用户一次确认后写入（改稿后仍只确认一次）
        - "不用" → 不写任何文件，本段对话不再重提
      save_convention:
        target: ".tad/skill-library/<project>--<slug>.md（与库内现有条目同形），并在 .tad/skill-library/_index.md 追加一行索引"
        entry_shape: "标题 / Source project / Date / Origin: conversation light path (*discuss) / Type: workflow / Triggers: 触发关键词 / 有序步骤（真实命令与口径） / Gotchas"
        bypass: |
          轻路径绕过的是重仪式前端：不写 T1 SCAND、不经 Gate 4 KA 三问、不等收获环节——
          T2 入库的实质（会话内人类确认）收敛为上面这一次确认本身。
          条目以 Origin 行标明轻路径出身，事后评审可按出身区分对待；T3 晋升规则不变（仍需 ≥2 项目证据）。
        boundary: |
          本检查只做捕获提议，不触碰下方 forbidden 清单：存 skill 不是建 handoff、
          不生成设计文档、不跑 Gate 检查。
          与既有 *save-skill / *save-workflow（存 .claude/skills/local/ 的本地战术捕获）分工：
          彼者是用户显式命令、存项目本地；本路径是讨论中被动检测、存跨项目参考库（T2 层）。
          用户点名彼者命令时按彼者走，不重复提议。
      blocking: false

    forbidden:
      - "Auto-generating handoff or design documents"
      - "Running Gate checks"
      - "Suggesting 'let me create a handoff for this'"
      - "Creating HANDOFF-*.md files"
      - "Running requirement clarification (it starts when work is brought)"
      - "Writing implementation code"
    note_on_research_protocol: |
      *discuss mode and research_decision_protocol (Cognitive Firewall) are COMPATIBLE:
      - If a discussion surfaces a technical decision with risk implications,
        the research_decision_protocol still applies (research → present options → let human decide)
      - The difference: *discuss does not FORCE research protocol on every topic,
        only on topics that match Cognitive Firewall triggers (architecture, dependency, security decisions)

  soft_checkpoint:
    trigger: "After 6+ exchanges (user messages) in discuss mode without natural conclusion"
    action: |
      Gently check in (NOT a forced exit):
      "We've been discussing for a while. Quick check — want to keep going, or capture what we have so far?"
      This is a SOFT prompt, not blocking. If user continues the conversation, Alex follows along.

  exit_protocol:
    trigger: "User signals they want to wrap up, OR natural conclusion reached"
    action: |
      Use AskUserQuestion:
      "Discussion seems to be wrapping up. Would you like to capture anything?"
      Options:
      - "Save the workflow we built as a skill" → run saveable_workflow_check 的保存腿（草稿＋一次确认＋写入 skill 库）
      - "Record conclusions to NEXT.md" → append summary to NEXT.md
      - "This is a direction question — take it to Cora" → give the human the sentence from epic_execution_pointer; end
      - "This needs proper design — start *analyze" → switch to adaptive_complexity_protocol
      - "No need to record, just a chat" → end, return to Alex standby
    note: "If user doesn't signal wrap-up, Alex does NOT proactively suggest ending"
