# Epic: Cross-Model Orchestration — TAD 跨模型编排能力

**Epic ID**: EPIC-20260503-cross-model-orchestration
**Created**: 2026-05-03
**Owner**: Alex
**IDEA Source**: IDEA-20260503-cross-model-orchestration

---

## Objective

在 TAD 框架内实现原生跨模型编排：利用 Codex CLI、Gemini CLI 的差异化能力（Review、Research、多媒体生成等），通过 Claude Code 的 Agent/Bash tool 在单 session 内调度，提升代码审查质量 + 扩展 TAD 能力边界。协议固定、能力可插拔。

## Success Criteria

- [x] 至少 2 个跨模型能力通过 spike 验证（INTEGRATE 判定） — NotebookLM INTEGRATE + Codex Image-2 INTEGRATE
- [x] 编排协议设计完成：capability catalog YAML + prompt template + fallback chain — capabilities.yaml + *research-notebook SKILL 8 commands
- [x] TAD SKILL 集成完成：Blake 和/或 Alex SKILL 中有跨模型调用路径 — Alex step2c_github, research_notebook_awareness, *research-plan
- [x] 在至少 1 个真实项目任务中端到端使用跨模型能力，体验正向 — menu-snap: 4 notebooks, 646 sources, 10 research outputs

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Real-Scenario Spikes | ✅ Done | HANDOFF-20260503-cross-model-phase0-spikes.md (archived) | Spike A: SKIP, Spike B: DEFER, Spike C: INTEGRATE (Codex Image-2 → *publish) |
| 0b | NotebookLM Knowledge Layer Spike | ✅ Done | HANDOFF-20260503-notebooklm-knowledge-layer-spike.md (archived) | INTEGRATE: 15 sources (6 web + 9 YouTube), Q3-final 5/5 with 37 video citations, 6 video-exclusive findings |
| 1 | Protocol Design + Integration | ✅ Done | HANDOFF-20260503-cross-model-phase1-protocol.md (archived) | *research-notebook SKILL (8 commands) + REGISTRY + capabilities.yaml + Alex SKILL integration |
| 2 | Validation Run | ✅ Done | (validated organically) | menu-snap: 4 notebooks (646 sources), 10 research files, *research-plan pipeline used end-to-end (2026-05-04~05-14) |

### Phase Dependencies

- Phase 0 → Phase 1: spike 结果决定 Phase 1 协议范围（哪些能力做进去，哪些 SKIP）
- Phase 1 → Phase 2: 协议设计完成才能集成到 SKILL
- Phase 2 → Phase 3: 集成完成才能实战验证
- Phase 0 可以随真实任务自然触发（不需要专门安排时间）

### Phase 0 Spike 定义

**Spike A: Codex Code Review（真实场景）**
- 触发：下一个 Blake handoff 完成 Gate 3 时，同时发 diff 给 Codex 审查
- 对比：Codex review vs Claude code-reviewer 子 agent，看 Codex 是否发现 Claude 漏掉的问题
- 判定：发现额外 P0/P1 = INTEGRATE；无差异 = SKIP；格式问题严重 = DEFER

**Spike B: Gemini Deep Research（真实场景）**
- 触发：下一个 *discuss 或 *analyze 需要技术调研时，同时用 Gemini Deep Research
- 对比：Gemini Deep Research vs Alex WebSearch ×5，看研究深度和引用质量
- 判定：研究质量显著优于 WebSearch = INTEGRATE；无明显差异 = SKIP

**Spike C: Creative Capability（探索性）**
- 从能力扫描中选 1 个多媒体能力测试（Image-2 / Veo 3.1 / Lyria 3 / Deep Research Extension）
- 判定标准：输出质量可用 + 能集成到 TAD 工作流 = INTEGRATE

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Context for Next Phase

### Pre-Phase 0 Context (from *discuss + 已完成 spike)

**已验证（可行性 spike, commit fcd0ea6）：**
- Gemini CLI 可从 Claude Code sub-agent 调用（`gemini -p` 非交互模式）
- Codex + Gemini 统一 review 输出格式可行（同一 prompt 模板）
- Fallback 错误检测可行（exit code ≠ 0 + error keyword grep）

**已识别的风险（Socratic Inquiry）：**
1. 输出格式不稳定：模型版本更新可能破坏 prompt 模板
2. 共识解决难：不同模型对同一代码 severity 判定不一致（Gemini 3 P0 vs Codex 2 P0）
3. 维护成本高：平台 API/CLI 变化快，prompt 模板需要持续维护

**核心设计原则：**
- 协议固定、能力可插拔（类比 Domain Pack 机制）
- Shell access = 万能集成层（不绑定 Claude Code，任何 AI CLI 可做编排器）
- 用户已有资源：Claude Max 20% + GPT Plus + Gemini Pro 免费额度

### Completed Work Summary
- Phase 0: 3× spike 完成 (commit 2d5d5df)
  - Spike A (Codex Review): **SKIP** — 对 bash 脚本无增量价值，production code-reviewer 发现的 P0 Codex 没抓到
  - Spike B (Gemini Research): **DEFER** — 不对称 prompt 导致对比无效 + Gemini PCRE regex 在 macOS BSD grep 不兼容
  - Spike C (Codex Image-2): **INTEGRATE** — 生成 1774×887 PNG，质量可用，scoped to *publish ≤20/month

### Decisions Made So Far
- Full TAD + Epic 流程
- Phase 0 spike 结果大幅缩小 Phase 1 范围：只做 Codex Image-Gen → *publish 集成
- Codex Code Review 方向放弃（bash domain 无增量价值）
- Gemini Research 方向暂缓（需对称 prompt 重测）
- `codex exec review --commit` 不可用（--commit 与 positional prompt 互斥），用 stdin fallback
- Gemini -p 模式是只读工具集（无 write_file/shell exec）

### Known Issues / Carry-forward
- Codex stderr 噪音需过滤（`failed to record rollout items` 是 benign log）
- Gemini CLI 必须用 `-p` flag（非交互模式），且 -p 模式工具集只读
- Gemini PCRE regex (`(?!...)`) 在 macOS BSD grep -E 下静默失败
- 跨模型 prompt 对称性是 load-bearing 要求——不对称 prompt 产生的差异会被误归因为模型能力差异

### Next Phase Scope
Phase 1: Codex Image-Gen 协议设计 + *publish skill 集成。范围极窄——一个 prompt 模板 + *publish 触发点 + 月预算 cap。

---

## Notes

- IDEA: `.tad/active/ideas/IDEA-20260503-cross-model-orchestration.md`（含完整能力扫描 + 生态分析）
- 可行性 Spike: `.tad/evidence/spikes/SPIKE-20260503-cross-model-orchestration/`（archived, commit fcd0ea6）
- 生态观察：大部分开发者还在"手动切换"层次（~80%），我们的"原生 session 内编排"在 <5% 用户中
- 与 TAD Method 独立发展，未来可能交汇
