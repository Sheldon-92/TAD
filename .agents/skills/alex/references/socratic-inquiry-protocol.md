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

  # 复杂度判断规则
  complexity_detection:
    small:
      criteria: "单文件修改、配置调整、简单 UI 变更"
      question_count: "2-3 个问题"
    medium:
      criteria: "多文件修改、新功能、API 变更"
      question_count: "4-5 个问题"
    large:
      criteria: "架构变更、复杂功能、跨模块重构"
      question_count: "6-8 个问题"

  # 提问维度（根据复杂度选择）
  question_dimensions:
    value_validation:
      name: "价值验证"
      questions:
        - "这个功能解决了什么具体问题？"
        - "如果不做这个功能，会有什么影响？"
        - "目标用户是谁？他们真正需要的是什么？"

    boundary_clarification:
      name: "边界澄清"
      questions:
        - "MVP 必须包含哪些功能？哪些可以以后再做？"
        - "有什么是明确不做的？"
        - "这个功能的边界在哪里？"

    risk_foresight:
      name: "风险预见"
      questions:
        - "如果这个方案失败了，最可能是什么原因？"
        - "你假设了什么是成立的？这些假设可靠吗？"
        - "这个功能依赖什么外部条件？"

    acceptance_criteria:
      name: "验收标准"
      questions:
        - "怎么知道这个功能做完了？"
        - "用户会如何验证这个功能是否正确？"
        - "成功的标准是什么？"

    user_scenarios:
      name: "用户场景"
      questions:
        - "典型用户会怎么使用这个功能？"
        - "有什么边界情况或异常场景需要处理？"
        - "用户可能会误用这个功能吗？"

    technical_constraints:
      name: "技术约束"
      questions:
        - "有什么技术限制需要考虑？"
        - "需要兼容什么现有系统？"
        - "性能要求是什么？"
        - "如果本地硬件不够（GPU/内存/存储），是否考虑过云计算资源（Colab/Kaggle 免费 GPU，RunPod/Vast.ai 付费 GPU）？"

  # 执行流程
  execution:
    step1:
      name: "Complexity Assessment"
      action: "使用 adaptive_complexity_protocol 的用户选择结果（如已运行），否则内部评估"
      note: "If adaptive_complexity_protocol already ran, use the user's chosen depth instead of re-assessing"

    step2:
      name: "Dimension Selection"
      action: "根据复杂度（或用户选择的 depth）选择提问维度"
      small: ["value_validation", "acceptance_criteria"]
      medium: ["value_validation", "boundary_clarification", "acceptance_criteria", "risk_foresight"]
      large: "all dimensions"

    step3:
      name: "Socratic Inquiry"
      action: "使用 AskUserQuestion 工具提问"
      format: |
        必须调用 AskUserQuestion 工具，格式：
        - questions: 2-4 个问题（AskUserQuestion 限制）
        - 每个问题提供 2-4 个选项 + 用户可选择 Other 自由输入
        - multiSelect: 根据问题类型决定

      example: |
        AskUserQuestion({
          questions: [
            {
              question: "这个功能解决了什么具体问题？",
              header: "价值验证",
              options: [
                {label: "提升用户体验", description: "改善现有功能的易用性"},
                {label: "新增能力", description: "提供之前没有的功能"},
                {label: "修复问题", description: "解决已知的 bug 或缺陷"},
                {label: "技术优化", description: "提升性能或代码质量"}
              ],
              multiSelect: false
            },
            {
              question: "MVP 必须包含哪些功能？",
              header: "边界澄清",
              options: [
                {label: "核心功能 A", description: "..."},
                {label: "核心功能 B", description: "..."},
                {label: "增强功能 C", description: "可以后续迭代"}
              ],
              multiSelect: true
            }
          ]
        })

    step4:
      name: "Follow-up Discussion"
      action: "根据用户回答，用自由对话补充细节"
      note: "如果用户回答揭示了新的问题，可以再次调用 AskUserQuestion"

    step5:
      name: "Final Confirmation"
      action: "用 AskUserQuestion 做最终确认"
      format: |
        AskUserQuestion({
          questions: [{
            question: "基于以上讨论，需求理解是否完整？可以开始写 Handoff 了吗？",
            header: "最终确认",
            options: [
              {label: "✅ 确认，开始写 Handoff", description: "需求已清晰，可以进入设计"},
              {label: "🔄 还需要澄清", description: "有些地方还不清楚"},
              {label: "📝 需要调整方向", description: "讨论中发现需要改变思路"}
            ],
            multiSelect: false
          }]
        })

  # 输出摘要
  output_summary:
    action: "在写 handoff 前，输出苏格拉底提问的摘要"
    format: |
      ## 📋 需求澄清摘要 (Socratic Inquiry Summary)

      **任务复杂度**: {small/medium/large}
      **提问轮数**: {N} 轮

      ### 关键确认
      | 维度 | 问题 | 用户回答 |
      |------|------|----------|
      | 价值验证 | ... | ... |
      | 边界澄清 | ... | ... |
      | ... | ... | ... |

      ### 发现的盲点/调整
      - {如果提问过程中发现了用户最初没考虑到的问题，列在这里}

      ### 最终确认
      ✅ 用户确认需求完整，可以开始写 Handoff

