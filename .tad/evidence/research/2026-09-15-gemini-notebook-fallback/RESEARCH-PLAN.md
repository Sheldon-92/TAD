# RESEARCH-PLAN — Gemini Notebook / TAD fallback 链

> RG2 = research-plan Phase 0 计划 + step2/step3 确认 + Phase 0class effort 分级 + Phase 0c plan-challenge。
> Engine: `.agents/skills/alex/references/research-plan-protocol.md`。

## 问题树（≥3，均带 specificity + decision anchor）

| # | 子问题 | 决策锚 | 优先 |
|---|--------|--------|------|
| Q1 | 官方一手来源是否确认 NotebookLM→Gemini Notebook 更名、生效日期、且产品是否仍独立？ | 决定"产品名是否已过时"的前提事实 | P0 |
| Q2 | 更名同期/之前的能力变化有哪些（模型、代码执行、跨端同步）？"源锚定（source-grounding）只读用户源"这一核心命题是否改变？ | 决定 fallback 链层的**用途描述**是否还成立 | P0 |
| Q3 | TAD 实际调用的客户端（`notebooklm-py` 的 `notebooklm` CLI）更名后是否仍可用？包名/CLI 名是否变化、是否已发布？ | 决定"工具标识符能不能动" | P0 |
| Q4 | 协议/技能文件里的 "NotebookLM" 字样，哪些是产品名（应更新）、哪些是工具标识符（必须保留）？ | 决定改动的**具体文件与 token 列表** | P0 |
| Q5 | `local_wiki → notebooklm_research → claude_websearch` 这条链是否需要改结构？ | 决定是否只是文案，还是动配置 | P0 |
| Q6（skeptic） | 有没有反例会推翻"只改文案、不动标识符"的推荐？ | 决定推荐的边界条件与未知风险 | P1 |

## Source 优先级（本主题）
1. Google 官方博客（2026-06-08 能力升级 / 2026-07-16 更名）
2. Workspace Updates（企业面命名证据）
3. 客户端项目一手：`teng-lin/notebooklm-py` README / ADR-0028 / CHANGELOG / releases + PyPI
4. 本仓库自证：`config-workflow.yaml`、`capabilities.yaml`、`setup-notebooklm.sh`、`research/CLAUDE.md`、全仓 grep 计数
5. 二手媒体仅交叉验证

## Phase 0class — Effort 分级
- **Tier = comparison**（触发：在「改全部 / 不改 / 拆分改」≥2 个命名方案间比较并推荐）。
- `run_dynamic_seeds = on`（comparison）
- `run_adversarial_challenge = off`（comparison → off；complex 才 on）
- ⚠️ display+override 在真人会话中本应展示；本次为一次性试跑，默认采用 comparison，记为机制反馈项。

## Phase 0c — Plan challenge
- `run_adversarial_challenge = off`（tier=comparison）→ 跳过 Phase 0c 外部 CLI challenge（DR-20260531 carve-out 允许按 tier 关闭）。
- 预检（始终运行）：`codex` 可用；`gemini` 不可用（单模型）。RG3 独立 Critic 仍为必需（wrapper 规则：Deep 一律要 Critic）。

## 轮次预算与停止规则
- **轮次预算 = 3**。
- **停止规则（任一即收）**：charter 6 条 AC 全部答完；或新一轮挖不出新东西（边际收益归零）；或预算耗尽。
- **close_shortlist**：轮次闭合时真人应被咨询一次（收 / 再深一轮 / 转向）；本次试跑自决，记为反馈项。

## 执行体（engine mapping）
- Phase 1–4：本主题 Local Wiki 无命中 → 按 fallback chain 降级。`~/.tad-notebooklm-venv` 在本机 **不存在** → 二级（notebooklm_research）不可用 → 实际走**三级降级 `claude_websearch`**（WebSearch/WebFetch）。此即本次试点真实观测到的降级路径。
- Phase 4c：tier=comparison → challenge off。
- RG3：independent-session Critic（不同 session）。
- RG4：verdict-first + SOURCES.md。
