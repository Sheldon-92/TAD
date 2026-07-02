# EPIC: Local Deep Research as TAD Deep-Research Backend

**Created:** 2026-07-01
**Status:** CLOSED (2026-07-02) — Phase 1 POC Verdict FAIL → Phase 2 gated off per门槛条款

## NEGATIVE-RESULT (2026-07-02)

**结论**: LDR 1.7.0 不满足 TAD deep-research 层的引文落地门槛，Phase 2（接入 *research）不启动。

**证据链**（两轮实测，.tad/evidence/research/ldr-poc/）:
- Round 1（默认 quick_research，开放网络）: LDR pooled citation-resolution = 5/45 = 11%
- Round 2（Library-scoped，search_tool=collection）: Blake 报告 23%；Alex file-provenance
  复核修正为 **5/30 = 16.7%**（judge Q3 标签倒转，详见 handoff gate4_delta）。FAIL 对该错误鲁棒。
- 基线对照: NotebookLM 同 rubric 得 0%（CLI 无 URL 对照表——形式归因，非事实错误）
- 双方 0 幻觉引文、内容准确性 100%、coverage 满分——差距在引文可审计性，不在事实正确性
- Gate-B（MCP 链路）: PASS（EQUIVALENT_SUBSTITUTE，STDIO 注册 + REST 引擎验证）

**根因**（修正后）: (1) Library-scoped 模式存在且可用（search_tool=collection），但 LLM 合成层
不约束引文只指向 collection 源；(2) LDR 持久 KB 跨 run 渗漏（round 1 下载的 arXiv 论文渗入
round 2 引文）；(3) 模型因素（qwen3.7-max 中文回答省略 URL 书目）放大了形式归因失败。

**窄重开条件**（满足任一可重开 Phase 1 补测）:
- LDR 后续版本提供"引文强制约束到 collection 源"的模式（synthesis-level scoping）
- 换 Claude/GPT 级模型 + 全新 LDR 实例（无 KB 污染）重测且 pooled ≥ 80%

**保留资产**: 安装知识（1.7.0 CLI broken / llvmlite override / CSRF 细节）在 Blake journal；
盲评方法论教训已提炼至 patterns/pack-evaluation.md（2026-07-02 条目）；
venv `~/.tad-ldr-venv` + 数据 `~/.tad-ldr-data` 保留在 repo 外（用户可手动删除释放磁盘）。
**Owner:** Alex
**Origin:** Research round 2 of open-notebook-evaluation notebook (d46515cf) — LDR folded in as candidate E, layered verdict: D (Google official API) for notebook layer, E (LDR) preferred for deep-research/discovery layer. Decision brief: `.tad/evidence/research/open-notebook-vs-notebooklm/2026-07-01-decision-brief-open-notebook.md`

## Goal

把 LearningCircuit/local-deep-research (LDR) 内化为 TAD 研究栈的 deep-research 层能力：
自主源发现 + 带引文报告 + MCP 直调，补上 NotebookLM 管线没有的"自主找源"能力，
并为 `*research --deep` 提供比裸 WebSearch 更强的执行后端。

## Why Now

- NotebookLM CLI 不稳定（本次研究会话中 ask 即超时一次），是既有痛点
- 研究已完成（21 sources，2 轮 ask，claim 验证），LDR 在 deep-research 层无对手：
  源发现（open-notebook 没有）+ MCP server（open-notebook 没有）+ 加密知识库
- 用户明确要求"内化为 TAD 的能力"（2026-07-01 Socratic Q3b）

## Phase Map

| Phase | Name | Status | Handoff | Gate |
|-------|------|--------|---------|------|
| 1 | POC 验证（安装 + 引文 A/B + MCP 全链路） | ✅ Complete (Gate 4 accepted 2026-07-02, Verdict FAIL) | HANDOFF-20260701-ldr-poc-phase1.md (archived) | Gate 3 PASS + Gate 4 PASS |
| 2 | 接入 `*research` 管线 | ❌ Not Started (gate condition failed) | — | Gate-A 16.7% < 80% |

**Phase 2 进入门槛（AC6，硬条件）：**
- Phase 1 POC 报告 Verdict = PASS，定义为：
  (a) LDR cited-ask 引文可定位率 ≥80%（固定 3 问 × 固定 rubric × 独立 judge）
  (b) MCP server 在 Claude Code 内 headless 全链路实测通过
- 任一不满足 → Phase 2 不启动，Epic 关闭并记录 NEGATIVE-RESULT，现状（NotebookLM 管线）不动

### Phase 1: POC 验证

- **Scope**: 独立 venv 安装 LDR 1.7.0（钉版）；headless 研究链路实测；MCP project-scoped
  注册 + 实调；引文质量 A/B（LDR vs NotebookLM，同源同问固定 rubric）；POC 报告落盘。
- **AC**: 见 handoff §9.1（6 条，源自 2026-07-01 Socratic Q5 确认）
- **Files Likely Affected**: `.mcp.json`（新建）、`.tad/evidence/research/ldr-poc/*`（新建）、
  `~/.tad-ldr-venv`（repo 外）
- **Input**: 决策简报 Round 2 + notebook d46515cf 的 5 个 LDR 源
- **Output**: POC 报告（PASS/FAIL + 前提标注）→ Phase 2 的 go/no-go 依据

### Phase 2: 接入 `*research` 管线（Planned — 细节在 Phase 1 结论后设计）

- **Scope（草案，Phase 1 后细化）**: `*research --deep` 增加 LDR 执行路径（MCP 优先）；
  research_unified_protocol 路由表更新；降级链（LDR 不可用 → 现有 WebSearch 路径）；
  与 NotebookLM 沉淀层的组合协议（LDR 找→筛，NotebookLM 存→问）。
- **Constraint**: 现有 NotebookLM 管线保持默认，LDR 是增强不是替换（除非 Phase 1 证据支持更激进的定位）
