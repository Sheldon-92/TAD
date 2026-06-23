# Socratic Inquiry Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

socratic_inquiry_protocol:
  description: "写 handoff 之前必须用 AskUserQuestion 工具进行苏格拉底式提问，帮助用户发现需求盲点"
  blocking: true
  tool: "AskUserQuestion"
  violations:
    - "不调用 AskUserQuestion 直接写 handoff = VIOLATION"
    # ⚠️ ANTI-RATIONALIZATION: "用户描述已经很详细，不需要再问了"
    # → 提问目的不是获取信息，而是暴露盲点。详细描述仍可能遗漏边界条件。
    - "问完问题不等用户回答就开始写 = VIOLATION"
    - "跳过复杂度评估，问题数量与任务不匹配 = VIOLATION"

  purpose:
    - "发现用户没想到的问题和盲点"
    - "验证需求的完整性"
    - "帮助用户做出更好的决策"

  # 复杂度判断规则（映射到新的 Q1-Q5）
  complexity_detection:
    small:
      criteria: "单文件修改、配置调整、简单 UI 变更"
      question_count: "2-3 个问题"
      which_questions: "Q2(problem) + Q3a(scope 快速确认)"
      skip: "Q1(ICP — auto-skip per task_type_skip) + Q3b(exclusion) + Q4(risk) + Q5(AC) — Alex 内部处理不问用户"
      output_summary: "Q4/Q5 行显示 'Alex 内部处理' 或省略"
    medium:
      criteria: "多文件修改、新功能、API 变更"
      question_count: "4-5 个问题"
      which_questions: "Q1 + Q2 + Q3a + Q3b + Q4(两步) + Q5(确认)"
    large:
      criteria: "架构变更、复杂功能、跨模块重构"
      question_count: "6+ (Q2 有追问轮)"
      which_questions: "全部，Q2 问题定义可能需要 2-3 轮精炼"

  # 三阶段共同定义模型（Co-Definition Model）
  co_definition_model:
    phase1_understand:
      name: "理解"
      leader: "user + Alex 共创"
      questions:
        q1_icp:
          dimension: "用户画像锚定"
          format: "AskUserQuestion (4 options)"
          question: "这个设计/功能是给谁用的？"
          options:
            - "我来定义：用户提供 ICP，统一格式：[角色]在[场景]中需要[能力]，最关心[关注点]"
            - "TAD 内部：未来零上下文的我：自动填充为 'Solo developer returning after 3+ months with no session context. Cares about: understanding what this does and why without reading commit history.'"
            - "帮我推断：Alex 从已有上下文推断，输出同一 ICP 格式，用户确认"
            - "跳过 ICP：skip，合法无惩罚"
          stored_as: "icp_anchor — 存储在 Socratic 输出摘要的 ICP 行中，通过对话上下文传递到 design phase，无需文件持久化"
          icp_format: "[角色]在[场景]中需要[能力]，最关心[关注点]"
          downstream: "设计阶段用作检验锚点（design-protocol step3 检查对话上下文中是否有 icp_anchor）"
          task_type_skip: |
            如果 adaptive_complexity 检测到任务属于 bug_fix / refactor / doc_update 类型，
            Q1 自动跳过或自动填充为"开发者本人"。不问用户。
            判断依据：intent_router 已识别的 route（*bug → skip, *analyze → ask）。

        q2_problem:
          dimension: "问题共同定义"
          format: "开放问题 + 条件追问精炼"
          question: "你想解决什么问题？描述一个具体场景。"
          goal: "从模糊的'我想做 X'精炼为'当[场景]时，[ICP]需要[能力]，但现在[障碍]'"
          note: "参考 product-thinking /define 的结构化问题定义方法——协作式，不是审问式"
          vague_detection:
            description: "判断用户回答是否需要追问的两个触发条件"
            trigger_1: "回答只描述意图/想法，没有具体场景（缺'当X时'的情境描述）"
            trigger_2: "回答描述了场景但没有障碍/痛点（缺'但现在Y'的问题描述）"
            action_if_triggered: |
              追问："能描述一个具体的场景吗？比如你在做 X 的时候遇到了什么困难？"
              如果二次回答仍触发任一条件：记录当前答案并继续（不再追问，max 1 次追问）
            action_if_not_triggered: "回答包含场景+障碍 → 直接进入 Q3"

    phase2_scope:
      name: "范围"
      leader: "Alex 提议，user 确认"
      questions:
        q3a_scope:
          dimension: "正向范围确认"
          format: "AskUserQuestion"
          action: "Alex 基于 Q1+Q2 分析后提出核心范围"
          question: "基于你的描述，我理解的核心范围是 [X]。对吗？"
          options:
            - "对，就是这样"
            - "范围需要调整：Alex 追问哪里要调"
            - "还缺少东西：用户补充"
        q3b_exclusion:
          dimension: "排除项确认"
          format: "AskUserQuestion"
          action: "确认正向范围后，单独确认排除项（防止锚定效应掩盖遗漏）"
          question: "我理解以下不在本次范围内：[Y]。有什么我列为排除但你实际需要的吗？"
          options:
            - "确认，这些不做"
            - "其中 [Z] 其实需要：移回范围"
            - "都需要做：调整范围"

    phase3_validate:
      name: "验证"
      leader: "Alex 主导分析，user 确认"
      questions:
        q4_risk:
          dimension: "风险分析（两步防锚定）"
          format: "用户先答 + Alex 呈现 + AskUserQuestion 确认"
          step_1_blind_spot:
            action: "在 Alex 分析之前，先捕获用户自己看到的风险"
            question: "在我分析之前——你最担心的是什么？用一句话描述。"
            format: "开放问题（不给选项，防止锚定）"
            if_no_concern: "'没什么特别担心的' 也是有价值的信号，记录后继续"
          step_2_present:
            action: "Alex 内部分析风险，呈现时整合用户在 step_1 提到的担忧"
            presentation: "我识别到的风险：1. [risk A] 2. [risk B]。其中 [你提到的 C] 我也确认了。"
            question: "还有我遗漏的吗？"
            options:
              - "没有了"
              - "还有一个：用户补充"
          note: "两步顺序不可颠倒——用户必须在看到 Alex 分析前独立思考，防止 anchoring 屏蔽真实盲点"

        q5_ac:
          dimension: "验收标准"
          format: "Alex 起草 + AskUserQuestion 确认"
          action: "Alex 基于 Q1-Q4 起草验收标准"
          presentation: "我建议的验收标准：1. [AC1] 2. [AC2] 3. [AC3]。"
          question: "这些标准对吗？"
          options:
            - "确认"
            - "需要修改某条：用户指定哪条怎么改"
            - "还缺少一条：用户补充"

      removed:
        technical_constraints: # removed as independent dimension
          reason: "用户不管技术问题——Alex 内部调研，结果直接写入 design/handoff"
          migration: "移到 design-protocol step3 作为 Alex 的内部步骤"
        user_scenarios: # removed as independent dimension
          reason: "吸收进 Q2（问题定义含具体场景）和 Q4（风险分析含边界/误用场景）"
          migration: "Q2 的 vague_detection 确保场景被捕获；Q4 的风险分析覆盖边界情况"

  # 格式选择规则（指导 Alex 在执行中遇到边界情况时的判断依据）
  format_selection_rules:
    options: "答案集合可穷举且≤4个 → AskUserQuestion 选项"
    open: "答案需要用户提供具体信息（场景、内容、描述） → 开放问题"
    present_confirm: "Alex 已做分析，用户只需接受/修正 → 呈现+确认"
    hybrid: "Q4 风险的两步模式——先开放（捕获盲点），再呈现+确认（补充分析）"

  # 执行流程
  execution:
    step1:
      name: "Complexity Assessment"
      action: "使用 adaptive_complexity_protocol 的用户选择结果（如已运行），否则内部评估"
      note: "If adaptive_complexity_protocol already ran, use the user's chosen depth instead of re-assessing"

    step2:
      name: "Phase 1 — Understand"
      action: |
        根据复杂度执行：
        - small: Q2 only (Q1 auto-skip per task_type_skip)
        - medium/large: Q1 → Q2 (large 时 Q2 可追问)

    step3:
      name: "Phase 2 — Scope"
      action: |
        - small: Q3a 快速确认 (skip Q3b)
        - medium/large: Q3a → Q3b

    step4:
      name: "Phase 3 — Validate"
      action: |
        - small: skip (Alex 内部处理 risk + AC)
        - medium/large: Q4 两步 (user blind spot → Alex analysis) → Q5

    step5:
      name: "Output Summary + Confirmation"
      action: "生成 output_summary 表格，确认用户满意后进入 *design"

  # 输出摘要
  output_summary:
    action: "在写 handoff 前，输出苏格拉底提问的摘要"
    format: |
      ## Socratic Inquiry Summary (Co-Definition)

      | 阶段 | 问题 | 结果 |
      |------|------|------|
      | Phase 1 | Q1 ICP | {icp_anchor 或 "skipped" 或 "auto: 开发者本人"} |
      | Phase 1 | Q2 Problem | {精炼后的问题定义} |
      | Phase 2 | Q3a Scope | {确认的范围} |
      | Phase 2 | Q3b Exclusion | {确认的排除项} |
      | Phase 3 | Q4 Risk (user) | {用户的担忧 或 "无特别担心"} |
      | Phase 3 | Q4 Risk (Alex) | {Alex 分析的风险} |
      | Phase 3 | Q5 AC | {确认的验收标准} |

      **ICP Anchor**: {icp_anchor 全文，或 "N/A"}
    note: "small 任务跳过的行显示 'Alex 内部处理' 或省略。icp_anchor 通过此摘要在对话上下文中传递到 design phase。"
