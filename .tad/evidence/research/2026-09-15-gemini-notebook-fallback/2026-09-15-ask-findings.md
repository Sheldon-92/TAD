---
research_complexity: comparison
---
# Ask Findings — Gemini Notebook（原 NotebookLM）与 TAD research fallback 链

> 检索日期 2026-09-15。来源编号见 `SOURCES.md`。落盘路径本目录（试点写 scope 约束）。
> 降级路径：Local Wiki 无命中 → `~/.tad-notebooklm-venv` 缺 → `claude_websearch`（WebSearch/WebFetch）。

## Q1 更名事实与独立性

**结论**：NotebookLM 于 **2026-07-16** 正式更名为 **Gemini Notebook**；仍为独立产品，非并入通用 Gemini 助手。[S2][S3][S10]

- 官方原文："We're renaming NotebookLM to Gemini Notebook. It's the same standalone product." [S2]
- Workspace 侧：2026-07-16 起 Extended rollout；2026-09-10 发布 Gemini Notebook 管理员外部分享控制（企业面命名已切换）。[S3]
- 引述规模（未独立验证）：30M 用户 / 600k 组织。[S2][S10]

## Q2 能力变化与"源锚定"命题

**结论**：实质能力升级发生在更名约 5 周前（**2026-06-08**），更名本身是品牌动作。**"只基于用户提供的源作答"核心命题未改变。**[S1][S2][S11]

- 2026-06-08：升级 Gemini 3.5 + Antigravity；每个 notebook 配 secure cloud computer（写/跑代码，Python 沙箱）；100+ curated software skills；新增 PNG/SVG、PDF/DOCX/MD、CSV/JSON、XLSX、PPTX 等输出；可由"松散想法"起步自发现来源（仍需用户批准加入）。[S1]
- 2026-07-16：重申 Pro 网页端将开放代码执行；Ultra + 合格 Workspace 已可用。[S2]
- 可用性分层：免代码执行于免费档；TAD 不依赖代码执行，影响有限。[S2][S14]

## Q3 客户端可用性（TAD 实际调用 `notebooklm` CLI）

**结论**（RG3 后收窄）：RPC 服务层未迁移，库"照用"对 **≥0.8.0** 成立；更名**已实测打断 0.7.3 / 0.8.0rc1 的登录**（[S7] live 实测），并经 **tag v0.3.4 源码静态核验**确认 0.3.4 的登录/取 cookie 路径含更名敏感硬编码（[S15]）——**TAD 固定的 0.3.4 落在受影响区间**（机制吻合；0.3.4 本身未 live 复现，见"未解决/低置信"）。[S4][S7][S12][S15]

- README（2026-07）："existing links redirect automatically, and this library drives the same underlying service and works unchanged." [S4]
- Issue #2022：更名后登录落地页 302 到 `notebook.google.com`，客户端 host 白名单硬编码只允许 `notebooklm.google.com` → `notebooklm login` 5 分钟超时。0.7.3 与 0.8.0rc1 实测失败；修复 #2015 首发于 **v0.8.0（2026-08-03）**。[S7][S6]
- RPC 未迁移：`/_/LabsTailwindUi/data/batchexecute` 仍在 `notebooklm.google.com` 无重定向；只有页面路由 302。真正后端/域迁移 tracked in #1977 + ADR-0028。[S7]
- **TAD pin**：`setup-notebooklm.sh:40` 装 `notebooklm-py[browser]==0.3.4`；技能版本下限 `≥0.3.4`。0.3.4 位于登录断带内（推断，未直接实测 0.3.4）。[S12][S7]
- 上游命名策略：ADR-0028 把 dist 改 `gemini-notebook-py`（0.9.0 一次完成），**import 包 `notebooklm` 与 `notebooklm*` CLI 永久保留**，另加 `gemini-notebook*` 脚本。0.9.0 尚未发布；最新 0.8.2（2026-09-02）。[S5][S6]

## Q4 产品名 vs 工具标识符分类

**结论**：只改 prose 产品名；全部工具标识符保留（可 grep 复核，分类见 ROUND-3 §F3.2）。[S5][S12]

- 保留：`notebooklm` CLI/子命令、`~/.tad-notebooklm-venv`、pip 名 `notebooklm-py`、`setup-notebooklm.sh`、`notebooklm-access.md`、fallback key `notebooklm_research`、`NOTEBOOKLM_*` 环境变量。
- 改：prose 产品名（如 `fallback: NotebookLM`、`云端 NotebookLM`、`INTERNAL NotebookLM`、`auto-detected by NotebookLM`、`NotebookLM Integration`、`NotebookLM not ready`），首次出现双标 `Gemini Notebook（原 NotebookLM）`。

## Q5 fallback 链是否改结构

**结论**：**不改结构**。`primary local_wiki → secondary notebooklm_research → tertiary claude_websearch` 语义不变。[S12][S7]

## Q6 反例 / 风险

- **CE1（最强）**：无官方消费级 API，TAD 依赖非官方客户端（5.6k★）；企业版 API 仅限 Cloud。二级层天然脆弱。[S9][S13]
- **CE2**："只改文案"不完整——必须同时把 pin 从 0.3.4 抬到 ≥0.8.0（建议 0.8.2）。0.3.4 的登录/取 cookie 代码含更名敏感硬编码（[S15] 静态核验，非 live 复现）；不升则保留的是**很可能坏掉**的二级层。本机 `~/.tad-notebooklm-venv` 不存在 → 这是"未部署态"，不是"已部署且已损坏"。[S7][S12][S15]
- **CE3**：上游 dist 名 0.9.0 待变（旧名 shim 永久可解析，低紧急）。[S5]
- **CE4**：cloud computer 代码执行扩大攻击面，公开安全规格缺失；TAD 若用它需先安全评审。[S14]
- **CE5**：品牌可能再变（ADR-0028 已计入）→ 品牌名不进承重标识符。[S5]
- **CE6**：pin 与"永不盲升"冲突 → 需一次带证据的有意识 re-pin。[S12]

## 未解决 / 低置信
- "TAD pin 0.3.4 受影响"已有 **tag v0.3.4 源码静态证据**（[S15]：`cli/session.py` 硬编码 `NOTEBOOKLM_HOST="notebooklm.google.com"` 并在 `:234` 校验登录落地 URL；`auth.py` 的 `ALLOWED_COOKIE_DOMAINS` 不含 `notebook.google.com`），但**未在本机 live 复现**（本机无该 venv、无 Google 账号）。0.3.4 的确切运行时失败模式（硬中止 vs 降级会话）未 live 验证。
- 30M 用户 / 600k 组织为 Google 自报，未见独立核验。[S2]
- 代码执行安全架构、真实后端迁移（#1977）未展开（charter scope-out）。

## RG3 后修正与补强（作者回应 Critic 条件）

> RG3 Critic 判 CONDITIONAL（见 `CRITIC-REVIEW.md`）。以下为条件闭合后的补强项。

- **CE2/CE6 升级为跨 minor 破坏性迁移**：0.3.4→0.8.2 跨 5 个 minor。0.8.0 落地 ADR-0019 错误/返回契约破坏半边（"absence and refusal raise"），并**移除** `NOTEBOOKLM_FUTURE_ERRORS` 预览开关、dict-subscript、get-returns-None、kwarg-alias 兼容机制；`0.7.0→0.8.0` 有专门 upgrading 指南。→ "抬 pin"需附**回归清单**：TAD 依赖的 CLI 形态（`ask`/`source add`/`source add-research --import-all`/`source list --json`/`summary --topics`/`source guide --json`/`configure --persona`/`generate report --wait`/`download report`）+ 错误处理假设 + 回退方案（保留 0.3.4 与 0.8.2 两套 venv 或 pin 回退）。[S6]
- **CE3'（新）ADR-0028 供应链反模式**：ADR-0028 明写裸 `notebooklm` dist 名在 PyPI **未注册、无预留机制、成为永久 typosquat 目标**；旧名 shim 永久可解析。TAD 的 pin 理由恰是 "supply-chain safety"——把安全 pin 钉在**已被上游放弃的旧版本**上，本身是供应链反模式。升 pin 时应同步评估 dist 名迁移到 `gemini-notebook-py`（0.9.0 发布后）。[S5]
- **CE7（新）0.8.2 Android gRPC backend 作为加固候选**：0.8.2（2026-09-02）新增 Android backend，直连原生 gRPC、按需签发短时 OAuth bearer，避开 Web backend 的过期 cookie / 混淆 RPC ID，官方定位即"Web UI 变更打断自动化时的独立路径"。**取舍**：master token 是比 cookie 快照更强的凭证，需专用账号 + 妥善保护；两 backend 均依赖未文档化 API。→ 本次**登记为候选、暂不采纳**（TAD 当前只需 `ask`+`source`，且切 backend 是又一次迁移面）；若二级层再遭 Web UI 变更，这是首选加固路径。[S16]
- **版本耦合 prose（新）**：`research-notebook/SKILL.md` 含 0.3.4 专属说明（`:347` "`--new` flag does NOT exist in 0.3.4"、`:771/:774` "`download report` ships in all notebooklm-py 0.3.4+ builds"、`:1157` "Minimum version: 0.3.4+"）与两处 `on_fail_version` 文案 "notebooklm-py < 0.3.4 has broken AI endpoints"。升 pin 后这些**必须连带改**（否则语义反转/自相矛盾）——它们不在"产品名 vs 工具标识符"二分内，属第三类"版本耦合 prose"。
- **"源锚定未变"标注为推断**：官方无一句字面"source-grounding 核心命题不变"的声明，系由 [S1][S2] "grounded in your sources" 措辞推断，属合理但非直证。
- **输出格式逐项归因**：PNG/SVG、PDF/DOCX/MD、CSV/JSON、XLSX、PPTX 的**逐后缀清单**部分来自二手汇总，[S1] 原文为泛述；不承重。
