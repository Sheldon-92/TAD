---
title: Self-Evolving System — Domain Pack + Agent 基于执行历史自动优化
date: 2026-04-02
status: captured
scope: large
---

## Summary & Problem

Domain Pack 目前是手工设计、手工测试、手工改进。每次发现质量问题都需要人分析原因并修改 YAML。

Meta-Harness 研究证明：同一模型，不同 harness（指令+工具+上下文管理），性能差 6 倍。优化 harness 比换模型更有效。

## Proposed Solution: 三阶段自动优化

### Stage 1: 执行 Trace 记录（基础设施）
- Domain Pack 每次执行时记录 trace：step ID、工具调用、耗时、成功/失败、失败原因
- 存为 .tad/evidence/domain-traces/{domain}/{date}.jsonl
- 这是所有后续优化的数据基础

### Stage 2: 失败模式聚合 + 质量标准优化
- 用 agent 读 N 次 trace → 聚合失败模式（"accessibility 检查在 3/5 次跑时被跳过"）
- 自动提议 quality_criteria 更新（"加一条：accessibility 检查必须执行"）
- 人审批更新（Gate 系统已有）

### Stage 3: Step 设计优化（Meta-Harness 式）
- 用 agent 读历史 trace + 当前 YAML → 提议 step 重写
- 评估新 step 效果（E2E 测试对比）
- 保留更好的版本

## Research Basis

| 来源 | 学到什么 | 可行性 |
|------|---------|--------|
| Meta-Harness (Stanford) | 搜索式学习，proposer 读 trace 提议优化，76.4% vs 手工 74.7% | 高 — TAD 的 Gate 可当 evaluator |
| EvoAgentX | 通过 TextGrad 优化 prompt | 中 — 需要评估指标 |
| Self-Evolving Survey | Layer 1 (prompt opt) 已生产就绪 | 高 — TAD 只需加 trace + 聚合 |
| JiuwenClaw | 工具失败 → 根因分析 → 技能优化 | 中 — 需要结构化失败日志 |

## TAD 已有的基础设施

- ✅ E2E 测试产出 pass/fail（评估信号）
- ✅ Quality criteria 在 YAML 中（可修改的 target）
- ✅ Gate 系统（人审批门控）
- ✅ project-knowledge（经验积累）
- ❌ 缺：执行 trace 记录
- ❌ 缺：失败模式聚合 step
- ❌ 缺：自动提议 criteria 更新的 agent

## 扩展：Agent 自我优化（同一机制）

不只是 Domain Pack — 用户设计的每个 agent 都应该能自我优化：

| 优化对象 | 什么在进化 | 数据来源 |
|---------|-----------|---------|
| Domain Pack | quality_criteria + steps | E2E 测试 trace |
| OpenClaw Agent | AGENTS.md + SOUL.md + HEARTBEAT.md | 执行日志 + 用户反馈 |
| Menu Snap Agent | system prompt + tool schema | API 调用日志 + 用户行为 |
| TAD Alex/Blake | SKILL.md 行为规则 | Gate pass/fail + Knowledge Assessment |

底层机制一样：**记录 trace → 聚合失败模式 → 提议配置更新 → 人审批**

这意味着 ai-agent-architecture pack 应该有一个 capability 叫 `self_improvement_design` — 教用户在设计 agent 时就把自我优化机制内置进去：
- 定义要记录什么 trace（哪些决策点、哪些结果）
- 定义聚合周期（多少次执行后分析一次）
- 定义可优化的参数（prompt 可以改、安全约束不能改）
- 定义审批流程（人必须审批哪些变更）

## Open Questions

- Trace 格式：JSONL？YAML？每个 step 记什么？
- 多少次执行后才有足够数据做聚合？
- 自动更新的范围：只改 quality_criteria 还是也改 steps？
- 安全边界：自动更新不能删除"编造=FAIL"这类核心约束
- Agent 自我优化的安全边界：哪些行为规则永远不能被自动修改？
