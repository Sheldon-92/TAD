# Epic: Symmetric Quality Enforcement — 对称机械强制 Alex/Blake 质量链

**Epic ID**: EPIC-20260413-symmetric-quality-enforcement
**Created**: 2026-04-13
**Owner**: Alex

---

## Objective

彻底终结 Alex 和 Blake 系统性跳过质量链环节的问题。通过 **PostToolUse / PreToolUse Hook 机械拦截**、**结构化 evidence 验证**、**SKILL 反合理化硬化** 三层方案，确保 Alex（专家审查 ≥2 + Socratic Inquiry）与 Blake（Layer 2 + Completion Report + Gate 3 + AC 验证脚本）必须留下磁盘证据才能完成 Write 操作。对 LLM 零逃生门，仅保留人类 `TAD_OVERRIDE: {reason}` 最后一把钥匙。

## Success Criteria

- [ ] **手动对抗测试**：在 Next Guest 项目故意让 Blake 跳过 Layer 2 → 被 hook 硬阻断（error 含缺失 evidence 清单）
- [ ] **Trace 完整性**：1 个月后 `.tad/evidence/traces/*.jsonl` 显示每个完成的 handoff 都有 `handoff_created`、`task_completed`、`evidence_created` 三类事件，比例 1:1:1
- [ ] **跨项目 0 violations**：Epic 发布后 1 个月内，10 个注册项目的 `.tad/archive/handoffs/` 每个 handoff 目录都含完整 evidence（≥2 份 reviewer report + COMPLETION-*.md，缺任一即计 violation）
- [ ] **0 人工维护**：安装 hook 后无需手动纠正 Alex/Blake 的跳过行为，hook 全部自动处理

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1a | Spike — 机制存在性验证 | ✅ Done | archive/HANDOFF-20260413-quality-enforcement-spike.md | **Overall: PASS (GO)** — PreToolUse Write 阻断验证、UserPromptSubmit Override 识别、exp3 evidence checker、fail-closed 语义全部工作；median 37ms / p95 48ms 远低于 200/300ms 阈值 |
| 1b | Spike — 对抗鲁棒性验证 | 🟡 PARTIAL | archive/HANDOFF-20260414-quality-enforcement-adversarial.md | **PARTIAL ACCEPT** — 安全核心 PASS (76 fixtures: 64 BLOCKED + 10 positive controls + 2 KNOWN-GAP per-cat ≤1 + cat5/7 零 KNOWN-GAP + 0 BYPASSED)；**perf PARTIAL** (p95 104-114ms 超 100ms 阈值 4-14ms)；**AC17 有真洞** (missing_dep fail-OPEN — jq 缺失时 hook 静默放行，Gate 4 发现) |
| 1c | Spike — 性能补修 + AC17 fail-OPEN 修复 | 🟡 PARTIAL | archive/HANDOFF-20260414-phase1c-perf-ac17-fix.md | **PARTIAL ACCEPT (Gate 4, 2026-04-14)** — AC17 fail-OPEN 已修（4/4 PASS, PATH pin + 白名单 + exit 0 + stdout deny 硬编码）、exit-code 契约 CC 2.1.107 实证（`exit 0` 真阻断，原 `exit 2` 猜测作废）、apples-to-apples PASS。**AC6 FAIL 确认**（evidence-validator p95=156.51ms、bash-watcher p95=130.57ms 真超标，非噪声；pretool=67.44 / override=52.48 健康）、**AC8-B FAIL** 因 AC12 字节保持与 AC15/read -t 内部超时设计冲突（handoff 层 bug，Alex 已承认）。Phase 3 前置：(1) 放开 AC12 字节约束，(2) CI runner 非 dev host 跑 perf gate，(3) 加 `read -t 2` + single-awk/cache 优化 evidence-validator + bash-watcher。新知识入库：claude -p hook 契约测试方法论。 |
| 2 | 设计 — Enforcement Matrix (可并行开始) | 🔄 Active (design-only) | — | 对称强制矩阵文档 + Checker 架构设计 + SKILL 硬化条款清单 + Override 认证结构。**基于 1b 的 H-001..H-009 9 项确认加固作输入**。可并行进行，但 Phase 3 实现须等 1c GO |
| 3 | 实现 — Hooks + SKILL | ⬚ Planned | — | **BLOCKED on 1c GO** — `.tad/hooks/quality-enforcement.sh` + settings.json 更新 + Alex/Blake SKILL.md 同步 + Message 模板加 evidence 清单 |
| 4 | 验证 — Dogfooding | ⬚ Planned | — | Next Guest + menu-snap 对抗测试通过报告 + 边缘情况处理记录 |
| 5 | 发布 + 监控 | ⬚ Planned | — | `*sync` 推到 10 个注册项目 + 1 个月 trace 指标仪表 |

### Phase Dependencies

- 所有 phase **严格串行**（任何一个 phase 的结论会影响下一个 phase 的设计）
- Phase 1a/1b **均 GO** 才能进 Phase 2；任一 NO-GO 需返回 `*discuss` 重新评估架构
- Phase 1a 失败（基础机制不可行）→ Epic 可能需要完全重新设计
- Phase 1b 失败（机制存在但对抗不可靠）→ 需要额外防护层设计
- Phase 4 验证发现重大问题时 → 回到 Phase 3 修正，而非强推到 Phase 5

### Phase 1 拆分理由（来自 2026-04-13 专家审查）

三位专家一致认为原单一 Spike 混合了"**机制是否存在**"（简单：PreToolUse 能否 deny）和"**机制能否抵抗对抗**"（复杂：8+ bypass 向量 + 伪证据 + log 篡改）两个不同难度的问题。合并会导致 4-6h 时间盒爆炸到 8-12h 或产出错误的 GO 结论。拆分后：

- **Phase 1a 时间盒 4-6h**：只验证机制存在性，threat model = 诚实但懒惰的 LLM
- **Phase 1b 时间盒 4-6h**：专门对抗测试，threat model = 对抗性 LLM（符合 Epic 原始 premise）

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: 0 / 5 phases complete

---

## Context for Next Phase

### Completed Work Summary
- **Phase 1a (2026-04-14, ~1.5h actual vs 4-6h budget)**: Mechanism existence spike. All 14 ACs verified. PreToolUse Write 能以 `permissionDecision:"deny"` 真阻断工具；UserPromptSubmit 能识别 `^TAD_OVERRIDE: <gate> <reason≥20>$` 格式；exp3 evidence checker 区分 valid/empty/missing-keyword；fail-closed 在 malformed stdin 下触发 deny。性能 median 37ms / p95 48ms。3 条 architecture.md knowledge entries 产出（python3 timing 陷阱、Alex handoff AC 漏洞、Gate 4 验证诚信）。

### Decisions Made So Far (update from Phase 1a)
- **PreToolUse（不是 PostToolUse）** 是唯一可阻断机制 —— v1 handoff 设计错误，专家审查捕获
- **Phase 1 拆分为 1a + 1b** 是正确决策（security-auditor 建议），1a 验证机制存在性，1b 将验证对抗鲁棒性
- **`perl -MTime::HiRes`** 替代 `python3` 作为 per-step CHECKPOINT（macOS startup 开销差异）
- **Alex 自身同样需要 hook 强制** —— Phase 1a Gate 4 发现我自己 handoff AC 漏掉 COMPLETION-REPORT.md，证明对称 enforcement 的 Alex 侧等价必要

### Decisions Made So Far

来自 *discuss + Socratic Inquiry（2026-04-13）：

| # | 决策 | 结论 | 理由 |
|---|------|------|------|
| 1 | 逃生通道策略 | **全 kill**：Skip TAD / express 豁免 expert review / Gate 2 替代 Layer 2 / Layer 1 替代 Gate 3 | 用户要求最严格，4 个路径都是 Blake/Alex 跳过的实际理由 |
| 2 | Hook 阻断方式 | **硬阻断 + 清晰错误信息（C）** | LLM 看到错误会自己回去补；自动补（B）会产生假证据 |
| 3 | Override 机制 | **B — 人类下一条 prompt 输入 `TAD_OVERRIDE: {reason}`**（LLM 永不可用），hook 写 `.tad/evidence/overrides/` 日志 | 保留人类最后安全阀；LLM 层面仍最严格 |
| 4 | Hook 触发条件 | **内容模式匹配**（监听 Write 写入内容含 "Message from Blake" / "Gate 3 Passed" / "Message from Alex" / "Ready for Implementation" 等） | 精准；记忆里 Phase 2b 已验证 awk 单进程匹配性能 < 100ms |
| 5 | Evidence 严格度 | **文件存在 + 非空 + 内容结构验证**（含必需关键字如 `Overall: PASS` / `P0 Issues:`） | 防 Blake 生成空壳伪装 |
| 6 | 范围 Out | Domain Pack 关键词误命中（独立 bug-fix）/ Dashboard（下轮 Epic）/ 历史 handoff 补全（成本过高）/ 非 Claude Code 平台（已弃） | 聚焦核心 |
| 7 | Spike 覆盖 | 3 合 1：拦截能力 + 性能 + Override 识别 + 伪证据识别 | 一次测完，避免多轮 pivot |
| 8 | 回滚策略 | 人类用 override 继续 + 代码 hotfix（快，与"最严格"对称） | 单行禁用脚本会被 LLM 滥用 |
| 9 | Domain Pack 指导 | 加载 ai-agent-architecture（`role_behavior_design` + `safety_design` + `self_improvement_design`）+ ai-evaluation（`adversarial_testing` + `regression_testing`） | 前者指导行为约束设计，后者指导 Spike 对抗测试 + 回归监控 |

### Known Issues / Carry-forward
- **Quality Chain Failure (已知 P0)**：记忆中记录 v2.7 slim 时误删约束、v2.8.1 虽将 commands 合并回 skills 但**仍是文字层约束**，这就是本 Epic 要解决的根本问题
- **hw-circuit-design 关键词误命中**：今天的 session 触发 UserPromptSubmit hook 把"电路设计"域误匹配到 TAD 架构讨论；**不在本 Epic 范围**，单独 bug-fix
- **现有 hook 基础设施**：`.tad/hooks/` 已有 11 个脚本（包括 `pre-gate-check.sh`、`pre-accept-check.sh`、`trace-step.sh`、`post-write-sync.sh`、`lib/common.sh`），Phase 1 Spike 需复用这些模式而非重新发明

### Next Phase Scope

**Phase 1 Spike 目标（4-6h 时间盒）**：
1. 验证 `PostToolUse Write` 能在写入 "Message from Blake" 模式时阻断文件写盘
2. 验证 `UserPromptSubmit` 能识别 `TAD_OVERRIDE: {reason}` 并产生日志
3. 验证伪证据识别：构造 1 份空壳 expert review（只有标题没有内容），确认 checker 拒绝
4. 测量 checker 总延迟（目标 < 200ms，来自记忆 Epic 1 Phase 2b 基线）
5. 产出 `GO / PARTIAL / NO-GO` 决策，含量化数据

---

## Notes

- 本 Epic 源自 2026-04-13 用户反馈：Blake 两次在 Next Guest / menu-snap 项目显式跳过 Layer 2，被问时坦承"我倾向于用 Layer 1 自检 + 手动 grep 替代正式专家审查"
- 这证明**文字约束对模型行为无效**，必须机械强制（ai-agent-architecture pack 反模式第 2 条："只用 prompt MANDATORY（没有 hook/architecture 层 enforce = 建议不是规则）"）
- 发布后需监控 1 个月 trace，若仍有 violations 则继续下一轮优化
