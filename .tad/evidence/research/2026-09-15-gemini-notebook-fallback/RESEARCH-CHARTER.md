# 研究 Charter: Gemini Notebook（原 NotebookLM）与 TAD research fallback 链的对接

> RG1 立项门前置 artifact（before Phase 0，需 human 授权）。语气对齐 `research-decision-brief.md`。

**决策问题**: NotebookLM 于 2026-07-16 更名 Gemini Notebook 后，TAD 的 research fallback 链（`local_wiki` 主 → `notebooklm_research` 备 → `claude_websearch` 降级）与协议文案是否需要改名 / 改对接方式？若要，具体改哪些 token、保留哪些 token？

**服务哪个决策**: 决定是否启动一次「更名对齐」的小改动（协议文案层面的产品名更新），以及它的范围边界——哪些标识符绝对不动（否则会打断 fallback 链）。结论直接决定 Alex 是否开 handoff、Blake 改哪几个文件。

**够深验收线**:（每条可判定）
- AC1：更名事实与生效日期有 ≥1 官方一手来源（Google 官方博客 / Workspace Updates），并有 ≥2 独立二手来源交叉验证。
- AC2：能力变化（Gemini 3.5 + Antigravity、secure cloud computer / 代码执行、跨端同步）有官方一手来源，且明确「源锚定核心命题是否改变」。
- AC3：TAD 实际调用的客户端（`notebooklm-py` 的 `notebooklm` CLI）在更名后是否仍可用的结论，有客户端项目一手来源（README / ADR / CHANGELOG / releases）支撑。
- AC4：给出一份可 grep 复核的「产品名（改）vs 工具标识符（留）」分类，且每类附判据。
- AC5：fallback 链是否结构变更，有明确结论；若不改，说明理由。
- AC6：每条 load-bearing 结论在 SOURCES.md 可追溯到来源 + 检索日期。

**明确不查**:（scope-out）
- Gemini Notebook 的定价 / 订阅档位横评（仅在影响 TAD 可用性时才引用）。
- 从 `notebooklm-py` 迁移到其它客户端（`nlm` / `gemini-notebook-mcp-cli` / Node 实现）的**实现方案**——本次只判定「是否需要迁移」，不设计迁移。
- 代码执行安全架构的完整评审（只作为风险条目记录，不展开）。
- 产品功能逐项横评（podcast / video / mind-map 等）。
- Local Wiki / canon 落盘（本次为有界机制试点，写 scope 限本目录，见"落盘边界"）。

**Source 策略**: 一手优先。
- 一手：`blog.google` 官方公告（2026-06-08 能力升级、2026-07-16 更名）、`workspaceupdates.googleblog.com`、`github.com/teng-lin/notebooklm-py`（README / ADR-0028 / CHANGELOG / releases）、`pypi.org`。
- 二手（仅交叉验证）：The Verge、TechCrunch、9to5Google、the-decoder、SiliconANGLE、DevGENT。
- 本仓库自证来源：`.tad/config-workflow.yaml`、`.tad/cross-model/capabilities.yaml`、`.tad/cross-model/setup-notebooklm.sh`、`research/CLAUDE.md`、技能文件 grep 计数。
- Local Wiki 优先：先跑 `search.py`；未命中则按 fallback 链降级（见"已有研究检查"）。

**轮次预算**: 3

**已有研究检查**: `python3 research/scripts/search.py query "Gemini Notebook NotebookLM rename fallback" --limit 8` → 无本主题命中（命中项均为历史 migrated 研究里对 notebooklm 的**方法性**引用，非本主题结论）。`--scope wiki` 亦无命中。→ 无命中，从零研究。

**落盘边界（试点约束）**: 写 scope 仅本目录 `.tad/evidence/research/2026-09-15-gemini-notebook-fallback/`；`docs/pm` 只读；不 commit / push。RG4 的 "Local Wiki canon/wiki landing" 这一步**本次不执行**（越出写 scope），作为机制反馈项记录。

**授权**: 试点由任务发起人（human, task owner）于 2026-09-15 以「完整试跑 RG1–RG4」的指令**一次性授权**；live 的 `charter_authorization` 逐条确认闸未被单独触发——这是本次试跑要观测的摩擦点之一（见 MECHANISM-FEEDBACK.md）。
