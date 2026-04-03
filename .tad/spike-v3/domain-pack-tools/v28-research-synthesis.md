# TAD v2.8 Research Synthesis — Self-Evolving Framework

**Date**: 2026-04-02
**Sources**: 5 源码项目 + Claude Code 源码

---

## 从每个项目偷什么

### From Meta-Harness（最直接相关）
1. **Step trace 格式**: step_id + timestamp + tool_calls + observation + metrics
2. **Proposer 模式**: agent 读历史 trace → 诊断失败 → 提议 harness 改进
3. **环境快照**: 执行前一次性记录环境状态（工具版本、可用内存）
4. **Token 记账**: 精确追踪每步的 token 消耗和成本

### From EvoAgentX（反馈循环）
1. **Experience JSON**: {modification, before_score, after_score, succeed, round}
2. **收敛检测**: N 轮无改善 → 自动停止优化
3. **Round-based 版本**: 每轮优化保存为 round_N/，可追溯
4. **批量评估**: 多次运行取平均，避免单次噪音

### From NeMo Guardrails（质量执行）
1. **YAML Rail 定义**: input/output/execution 三层 rail 配置
2. **Short-circuit**: 第一个 rail 失败立即停止（fail-fast）
3. **Flow 复用**: 质量检查定义为可复用 flow，不是一次性代码

### From Claude Code（trace 机制）
1. **Span 层级**: root interaction → child tool spans（不是扁平日志）
2. **Timestamp + Sequence**: 同时记录时间和顺序
3. **JSONL 文件**: append-only，vendor-agnostic
4. **TTL 清理**: 定期清理过期 trace

---

## TAD v2.8 Trace 格式设计（综合以上研究）

```jsonl
{
  "execution_id": "exec-20260402-001",
  "timestamp": "2026-04-02T15:30:00Z",
  "domain_pack": "product-definition",
  "capability": "competitive_analysis",
  "step_id": "deep_analyze",
  "step_type": "analyze",
  "status": "completed|failed|skipped",
  "duration_ms": 1500,
  "tool_ref": "web_scraping",
  "tool_calls": [
    {"tool": "WebSearch", "query": "pet health monitoring competitors", "results": 5}
  ],
  "quality_check": {
    "criteria": "≥5 competitors found",
    "measured": 6,
    "passed": true
  },
  "tokens": {"input": 1200, "output": 800},
  "failure_reason": null,
  "project": "menu-snap"
}
```

每个 step 一行 JSONL。存储路径: `.tad/evidence/traces/{project}/{date}.jsonl`

---

## TAD v2.8 自动优化循环设计

```
[Gate 4 通过] 
  → PostToolUse Hook 检测到归档
  → 自动 spawn "Optimizer Agent"
  → Optimizer 读取最近 N 次 trace
  → 聚合失败模式
  → 生成提议:
    {
      "target": "product-definition.yaml",
      "capability": "competitive_analysis",
      "change_type": "tighten_criteria",
      "current": "≥5 competitors",
      "proposed": "≥5 competitors with real pricing data",
      "evidence": "3/5 recent runs had competitors without pricing",
      "confidence": 0.8
    }
  → AskUserQuestion 展示提议
  → 人审批
  → 应用变更

[跨项目聚合 — *evolve 命令]
  → Alex 读取所有项目的 .tad/evidence/traces/
  → 聚合跨项目的失败模式
  → 提议 SKILL.md / Hook / Gate 修改
  → 人审批
  → *sync 推送
```

---

## 深度源码研究补充发现（6 个 agent 完成）

### Claude Code Trace 机制（最完整的参考）
- **三层追踪**: OpenTelemetry spans + Perfetto 可视化 + JSONL transcript
- **Span 层级**: interaction → llm_request → tool → tool.execution
- **每个 span 记录**: timestamp, duration_ms, tokens, cost_usd, success/fail
- **transcript.jsonl**: 每个 session 持久化到 `~/.claude/projects/{hash}/sessions/{id}.jsonl`
- **成本追踪**: 每次 API 调用累计 token + USD，session 级别聚合
- **Compaction 保护**: 压缩对话时保留 pre-compact 段的工具调用摘要

### DeerFlow 最值得借鉴的 5 个模式
1. **Middleware Chain**: 14 个中间件按顺序执行，每个负责一个关注点（记忆、token 计数、循环检测、摘要）
2. **LLM 驱动的记忆更新**: 不靠规则提取事实，用 LLM 判断值得记住什么。有置信度评分 + 去重
3. **异步记忆队列**: 30秒 debounce，不阻塞 agent 响应
4. **Skill 渐进加载**: 技能按需加载到 prompt，不全量注入
5. **原子文件写入**: temp file + rename 防 crash 数据丢失

### Meta-Harness 核心机制
- **Proposer 读 82 个文件 + 20+ 历史候选**，消耗 10M tokens 做诊断
- **Step 对象**: step_id + timestamp + tool_calls + observation + metrics（每步记录完整上下文）
- **Marker-based 早停**: 命令执行不等满时长，检测到完成标记就退出（省 2-5%）
- **无显式评分循环**: 依赖外部 harness（Terminal-Bench）评估。搜索循环在单独系统中

### EvoAgentX 反馈循环
- **Experience JSON**: {father_node, modification, before, after, succeed, round}
- **收敛检测**: 连续 N 轮无改善 → 停止
- **Round-based 版本**: round_N/ 目录保存每轮状态

### NeMo Guardrails Rail 模式
- **YAML 定义 rails**: input/output/execution 三类
- **Short-circuit**: 第一个 rail 失败立即停止
- **RailResult**: {is_safe: bool, modified_output: str}

---

## Phase 实现映射

| Phase | 做什么 | 借鉴谁 |
|-------|--------|--------|
| Phase 1: Trace 基础设施 | PostToolUse hook 记录 JSONL trace | Claude Code transcript + Meta-Harness Step |
| Phase 2: 项目级分析 | Gate 4 后 spawn optimizer agent | Meta-Harness proposer + EvoAgentX experience |
| Phase 3: 跨项目聚合 | *evolve 命令聚合所有项目 trace | Meta-Harness 跨 candidate 分析 |
| Phase 4: 审批工作流 | AskUserQuestion + 变更应用 | NeMo Guardrails flow 模式 |
| Phase 5: 验证发布 | 真实项目验证 + v2.8 bump | — |
