<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Byte-identical to the original block. Cross-referenced protocols (notebook_consolidation_suggestion / adaptive_complexity_protocol / research_plan_protocol) remain INLINE in alex/SKILL.md and resolve in-session via the router. -->

research_review_protocol:
  description: "Research portfolio review — classify all notebooks by goal alignment + produce action plan"
  trigger: "User types *research-review OR Alex proactively suggests it in *discuss when research is scattered"

  execution:
    step1:
      name: "全景扫描"
      action: |
        1. Read REGISTRY.yaml → all notebooks (active, dormant, archived)
        2. Read ROADMAP.md → project themes + goals (if exists)
        3. Read NEXT.md → current tasks + epics
        4. For each active/dormant notebook:
           → last_queried date (freshness)
           → source_count (depth)
           → Alignment with current project goals (LLM semantic judgment)

    step2:
      name: "分类诊断"
      action: |
        将所有 active/dormant notebooks 分为四类:
        - 🔥 **加强**: 与当前目标强相关 + 最近活跃 → "这个研究应该继续深入"
        - ✅ **维持**: 与当前目标相关 + 已有充足成果 → "保持，需要时查询"
        - 🔄 **转向**: 与当前目标不再相关但有价值 → "话题需要调整方向"
        - 📦 **关闭**: 与当前目标无关 + 长期不活跃 → "建议归档"

        # ---- 新增：OBJECTIVES 对齐维度 ----
        如果 OBJECTIVES.md 存在（项目根目录）：
        → 每个 notebook 的 "Relevance to Current Goals" 直接对标 Objective：
          - notebook topic 匹配某 Objective → "🎯 Serves O{N}: {objective title}"
          - notebook topic 不匹配任何 Objective → "❓ No objective alignment"
        → 分类优先级调整：
          - 匹配 ⬚ Key Result（未完成） → 倾向 🔥 加强（需要更多研究来推进这个 KR）
          - 匹配 ✅ Key Result（已达成） → 倾向 ✅ 维持（目标已达成，研究够了）
          - 不匹配任何 Objective → 倾向 🔄 转向 或 📦 关闭

        Output: 分类表格 + 每个 notebook 一句话理由（含 Objective 对标，如有）

    step3:
      name: "行动建议"
      action: |
        AskUserQuestion: "这是你的研究组合诊断。要执行哪些操作？"
        Options:
          - "执行全部建议" → step4 (execute per category)
          - "只执行关闭/归档" → step4_close only
          - "逐个确认" → per-notebook AskUserQuestion
          - "只看看，不操作" → exit → standby

    step4_strengthen:
      name: "加强研究"
      action: |
        For each 🔥 notebook:
        → AskUserQuestion: "'{topic}' 需要加强。怎么做？"
          Options:
            - "Deep research (自动加源)" → *research-notebook research --mode deep
            - "生成一份综合报告" → *research-notebook report "comprehensive summary of {topic}"
            - "我来指定新源" → *research-notebook add
            - "跳过"

    step4_close:
      name: "关闭研究"
      action: |
        For each 📦 notebook:
        → *research-notebook archive (with user confirmation per existing archive flow)

    step4_pivot:
      name: "研究转向"
      action: |
        For each 🔄 notebook:
        → AskUserQuestion: "'{topic}' 需要转向。新方向是什么？"
          Options:
            - "重新定向" → create new notebook with new topic + *research-notebook consolidate to migrate + archive old
              (notebooklm rename 不存在 — use create+consolidate+archive pattern)
            - "保留源，新建角度" → *research-notebook configure --persona to reframe research lens
            - "整合到另一个 notebook" → trigger notebook_consolidation_suggestion
            - "直接归档" → *research-notebook archive

# *idea Path Protocol
