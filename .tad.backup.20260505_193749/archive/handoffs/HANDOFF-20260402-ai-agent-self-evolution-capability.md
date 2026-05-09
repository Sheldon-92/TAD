# Mini-Handoff: ai-agent-architecture Pack 补充 — Self-Improvement Design Capability

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Task ID:** TASK-20260402-021

---

## 1. What We're Building

给 ai-agent-architecture.yaml 新增 `self_improvement_design` capability — 教用户在设计 agent 时就内置自我优化机制。

**为什么**：Domain Pack 和 TAD 可以自我优化（*optimize / *evolve），但用这些工具设计出来的 agent 运行在自己的环境里（OpenClaw / iOS app / 独立服务），TAD 管不到。agent 需要**天生自带进化能力**。

## 2. 必读

- `.tad/domains/ai-agent-architecture.yaml` — 现有 8 个 capability
- `.tad/spike-v3/domain-pack-tools/ai-agent-architecture-research.md` — 研究里的 8 个通用模式
- `.tad/spike-v3/domain-pack-tools/v28-research-synthesis.md` — Meta-Harness/EvoAgentX 的进化机制
- `.tad/active/ideas/IDEA-20260402-self-evolving-domain-pack.md` — 自我进化 idea（含 agent 扩展）

## 3. 新增 Capability

```yaml
self_improvement_design:
  description: "设计 agent 的自我优化机制 — 让 agent 能从执行历史中学习并改进自己"
  type: "doc_a"  # 搜索→分析→推导→生成

  steps:
    - id: research_evolution_patterns
      action: |
        搜索 agent 自我进化的模式和最佳实践：
        - EvoAgentX 模式：experience JSON + 收敛检测
        - Meta-Harness 模式：trace → proposer → evaluate
        - JiuwenClaw 模式：工具失败 → 根因分析 → 技能优化
        分析哪种模式适合当前 agent 的运行环境。
      tool_ref: web_scraping

    - id: define_trace_schema
      action: |
        定义 agent 需要记录的 trace 数据：
        1. 决策点 trace — agent 做了什么选择、为什么
        2. 结果 trace — 选择的结果是什么（成功/失败/用户反馈）
        3. 环境 trace — 运行时上下文（输入、工具状态、外部依赖）
        
        对每个 trace 字段回答：
        - 为什么要记这个？（优化什么用？）
        - 存在哪里？（文件/数据库/API？）
        - 保留多久？（按天/按月/永久？）
      output_file: "trace-schema.md"

    - id: design_analysis_loop
      action: |
        设计从 trace 到改进的闭环：
        1. 触发时机 — 每 N 次执行后？每天？人手动？
        2. 分析方式 — LLM 读 trace 聚合模式？规则匹配？统计分析？
        3. 可优化参数 — 哪些可以改（prompt/工具选择/重试策略）？
        4. 不可优化参数 — 哪些绝对不能改（安全约束/权限边界）？
        5. 收敛检测 — 什么时候停止优化（N 轮无改善）？
      output_file: "improvement-loop.md"

    - id: design_safety_boundaries
      action: |
        定义自我优化的安全边界：
        1. 不可变约束清单 — 列出所有不能被优化掉的行为（如"不推荐过敏食物"）
        2. 人审批触发条件 — 什么级别的修改需要人确认？
        3. 回滚机制 — 优化后效果变差怎么恢复？
        4. 审计日志 — 每次优化改了什么、基于什么证据
      output_file: "safety-boundaries.md"

    - id: generate_blueprint
      action: |
        综合以上分析，生成 agent 自我优化蓝图：
        - Trace schema（记什么）
        - Analysis loop（怎么分析）
        - Optimization parameters（改什么）
        - Safety boundaries（不能改什么）
        - Implementation guide（在具体运行环境中怎么实现）
      tool_ref: pdf_generation
      output_file: "self-improvement-blueprint.pdf"

  quality_criteria:
    - "trace schema 每个字段有'为什么记'的理由"
    - "不可变约束清单 ≥3 条"
    - "回滚机制明确定义"
    - "优化参数和不可优化参数有清晰边界"
    - "蓝图适配具体运行环境（不是通用空话）"
    - "编造数据 = FAIL"

  anti_patterns:
    - "❌ 没有安全边界的自我优化 = 危险"
    - "❌ 全自动无人审批 = 失控风险"
    - "❌ 只记录成功不记录失败 = 学不到教训"
    - "❌ 优化频率太高 = 噪音大于信号"

  reviewers:
    - persona: "AI 安全审查员"
      checklist:
        - "不可变约束是否覆盖了所有安全关键行为？"
        - "人审批流程是否在关键路径上？"
        - "回滚机制是否经过验证？"
```

## 4. AC

- [ ] AC1: ai-agent-architecture.yaml 新增 self_improvement_design capability
- [ ] AC2: 5 个 steps 完整（research → trace schema → analysis loop → safety → blueprint）
- [ ] AC3: quality_criteria + anti_patterns + reviewers 完整
- [ ] AC4: YAML 语法正确
- [ ] AC5: 必须走 Ralph Loop + Gate 3

## 5. Notes

- ⚠️ 只加一个 capability，不改现有 8 个
- ⚠️ 这个 capability 的产出是设计文档（Doc A），不是代码

**Handoff Created By**: Alex
