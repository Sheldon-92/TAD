---
name: project_tier1-workflow-formalization
description: 2026-06-13/14 ✅ COMPLETE：把 4 个反复手工编排的 TAD 实践固化成 .claude/workflows/(handoff-review/pack-dogfood/pack-upgrade/research-engine)
metadata: 
  node_type: memory
  type: project
  originSessionId: 171b1263-2f86-44fb-89c9-ed31cb384805
---

EPIC-20260613-tier1-workflow-formalization ✅ COMPLETE+ARCHIVED (commits 404034d, 9bbb0ca, e76efc0)。把日常"靠 agent 临场编排"的高价值实践固化成确定性 workflow。`.claude/workflows/` 6→10。

**新增 4 个 workflow**：
- `pack-upgrade` + `pack-dogfood`（Phase 1）：从本 session 已跑通的 batch-upgrade/dogfood-all 泛化。
- `handoff-review`（Phase 2）：固化 Alex Gate 2 专家审查(handoff_creation_protocol step2-4)。改协议契约 → 过专家审查。
- `research-engine`（Phase 3）：deep-research 升级——加 plan + 动态 follow-up(从 gap 生成) + saturation 循环 + 反幻觉 + 带引用综合。补内置 deep-research 缺的层。

**关键决策**：
- workflows = **Claude-only**（用户决定 A）。Codex 没有 Workflow 原语（它靠单 agent 串行 + sandbox 脚本 + AGENTS.md）。workflows 不在 .claude↔.agents parity 范围,天然 Claude 专属,零额外工作。
- deep-research 是**内置 skill 不可编辑** → "升级"= 建 TAD workflow wrap 补层,不是改内置。

**方法论收获(可复用)——YOLO 建 workflow 守住 no-code**：
Alex 不手写交付物(SAFETY: Alex-No-Code-Violation)。模式 = **sub-agent 实现 → sub-agent/专家审查 → Conductor 跑 Gate(含 LIVE test-run)**。关键:**sub-agent 不能调 Workflow,只有主循环 Conductor 能** → live test-run 必须 Conductor 自己跑。每个 workflow 都真跑一遍闭合 gate(pack-dogfood 1包/handoff-review 归档handoff→p0=2 FAIL/research-engine 1轮 34findings 22sources)。
**契约类 workflow 必须把 invariant 做成真 JS guard,不是 prompt**(handoff-review: terminal min-2 断言 + Resolved 必引§/AC + 空review→FAIL + p0>0强制FAIL)——project 自己的"claims-need-carriers"教训。

**未来 workflow 候选(Tier 2,未做)**：Gate 4 验收 recompute、跨项目 sync fan-out、bug 多假设并查、知识审计。不该 workflow 化:苏格拉底/需求澄清(人机对话非 fan-out)。

Related: [[project_pack-quality-leveling-epic]] [[feedback_alex-no-code-violation]] [[project_conductor-architecture]]。
