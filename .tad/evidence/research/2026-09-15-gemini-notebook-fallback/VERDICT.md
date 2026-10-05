**Verdict-first**: 更名属实（2026-07-16，Google 官方），但**只需改"产品名 prose"，全部工具标识符保留**——`notebooklm` CLI、`~/.tad-notebooklm-venv`、`notebooklm-py`、`notebooklm_research`、`setup-notebooklm.sh`、`notebooklm-access.md` 一个都不动；fallback 链 `local_wiki → notebooklm_research → claude_websearch` **不改结构**。真正的动作不是文案，而是一条**功能修补**：TAD 把客户端 pin 在 `notebooklm-py==0.3.4`（更名敏感、且落在破坏性迁移的另一端），必须升到 ≥0.8.0（建议 0.8.2）并做一次跨 5 个 minor 的回归，否则二级 fallback 层"看起来保留、实际很可能不可用"。

# 决策简报: Gemini Notebook（原 NotebookLM）与 TAD research fallback 链

**决策问题**: NotebookLM 更名 Gemini Notebook 后，TAD 的 research fallback 链与协议文案是否改名/改对接？改哪些 token、留哪些？
**研究日期**: 2026-09-15
**研究级别**: Deep（RG1–RG4 wrapper；effort tier=comparison；引擎 Phase 1–4 走 `claude_websearch` 降级）
**Critic**: RG3 独立 session 判 **CONDITIONAL → 4 条件已闭合**（`CRITIC-REVIEW.md`）
**provenance**: 见 `SOURCES.md`（每条结论→来源→检索日期）

---

## 选项

1. **A｜全量改名** — 把仓库里所有 "NotebookLM" 字面量（含 CLI/路径/配置 key）统一改成 "Gemini Notebook"。
2. **B｜完全不动** — 保持现状，理由是更名是品牌层、工具照用。
3. **C｜拆分改（推荐）** — 只改面向人的**产品名 prose**（首处双标 `Gemini Notebook（原 NotebookLM）`），保留所有**工具标识符**；链结构不动。**并附功能项**：升级客户端 pin。

## 证据

### 选项 A（全量改名）— 不推荐
- 上游 ADR-0028 明确：dist 名可改，但 **import 包 `notebooklm` 与全部 `notebooklm*` CLI 脚本永久保留、不弃用**；品牌名刻意不进 wire/plumbing，正是为抗"再次改名"。[S5]
- 全仓 "NotebookLM" 约 90% 是工具标识符（CLI/路径/capability key/文件引用），改它们=高 churn、零收益，且会打断 `notebooklm_research` 链引用与已装环境。[S12]
- 反面警句：ADR-0028 自己把"品牌名写进不可事后修补的 plumbing"列为**决定性反对理由**。[S5]

### 选项 B（完全不动）— 不够
- 更名属实且有企业面证据（Workspace 2026-07-16 rollout；2026-09-10 管理员控制已用新名）；保留旧名损害新鲜度与可发现性。[S2][S3]
- 更关键：**"不动"会连同坏掉的 pin 一起保留**——见下。

### 选项 C（拆分改 + 升 pin）— 证据最强
- **产品名该改**：官方名已切换，prose 引用旧名是过时信息。[S2][S3]
- **标识符不能改**：上游已永久冻结 `notebooklm` CLI/import 名；TAD 的 venv 路径与配置 key 改名只会制造迁移与断链。[S5][S12]
- **链结构不该改**：更名未迁移服务/RPC（`batchexecute` 仍在 `notebooklm.google.com`），层语义不变。[S7]
- **pin 必须升（本研究的实质发现）**：
  - 更名把登录落地页改到 `notebook.google.com`，**0.7.3 与 0.8.0rc1 实测无法登录**，修复首发于 **v0.8.0（2026-08-03）**。[S7]
  - TAD 装的是 **`notebooklm-py==0.3.4`**（2026-03-12 发布）。tag v0.3.4 源码静态核验显示其登录/取 cookie 路径同样硬编码旧主机：`cli/session.py` 的 `NOTEBOOKLM_HOST="notebooklm.google.com"`（并在 `:234` 校验落地 URL）、`auth.py` 的 `ALLOWED_COOKIE_DOMAINS` 不含 `notebook.google.com` → **落在受影响区间**。[S12][S15]
  - 且升级不是"换个版本号"：0.3.4→0.8.2 跨 5 个 minor，0.8.0 落地 ADR-0019 破坏性错误/返回契约并移除 `NOTEBOOKLM_FUTURE_ERRORS` 等兼容机制。[S6]

## 推荐

**推荐**: **选项 C** —— 改产品名 prose、保留全部工具标识符、链结构不动；**同时**执行一次受控的客户端升级（0.3.4 → 0.8.2）。

**具体改造清单**（供后续 handoff 使用）：
1. **产品名 prose（改）**：`.agents/skills/*`（含 `.claude` 镜像）与 `research/CLAUDE.md` 中面向人的 "NotebookLM"（如 `fallback: NotebookLM`、`云端 NotebookLM`、`INTERNAL NotebookLM`、`auto-detected by NotebookLM`、`NotebookLM Integration`、`NotebookLM not ready`）。首处双标，后文用 "Gemini Notebook"。
2. **工具标识符（留）**：`notebooklm` CLI/子命令、`~/.tad-notebooklm-venv`、pip 名 `notebooklm-py`（0.9.0 前）、`setup-notebooklm.sh`、`notebooklm-access.md`、fallback key `notebooklm_research`、`NOTEBOOKLM_*` 环境变量。
3. **版本耦合 prose（连带改）**：`research-notebook/SKILL.md` 的 0.3.4 专属说明（`--new`、`download report`、Minimum version）与 `on_fail_version` 文案（"< 0.3.4 has broken AI endpoints" 语义已反转）。
4. **升级回归（改动主体）**：`setup-notebooklm.sh` pin → `notebooklm-py[browser]==0.8.2`；技能版本闸 `0.3.4` → `0.8.2`；回归 TAD 依赖的 CLI（`ask`/`source add`/`source add-research --import-all`/`source list --json`/`summary --topics`/`source guide --json`/`configure`/`generate report`/`download report`），核对 ADR-0019 错误契约，准备回退（双 venv 或 pin 回退）。
5. **链结构（不改）**：`config-workflow.yaml` 的 `primary/secondary/tertiary` 保持不动。

## 未知风险

- **CE1 结构性脆弱不可由升版本消除**：无官方消费级 API，TAD 依赖**非官方**客户端（仅 Google Cloud 企业 API 为官方）。任何后端/域迁移（在途项 #1977）都可能再次打断二级层。[S9][S13][S7]
- **CE7 加固候选未采纳**：0.8.2 Android gRPC backend 可绕开 Web cookie 脆弱性，但 master token 是更强凭证，本次登记不采纳。[S16]
- **CE3' 供应链**：旧 dist 名 `notebooklm-py` 将成为永久 typosquat 目标；pin 的"供应链安全"理由与固定旧版本存在张力。[S5]
- **CE4**：cloud computer 代码执行扩大攻击面且缺公开安全规格；TAD 目前不用，若用需先安全评审。[S14]
- **置信边界**：0.3.4 受影响为**源码静态证据**，非本机 live 复现；本机无 `~/.tad-notebooklm-venv`（未部署态）。[S15][S12]

## Claim 验证

| Claim | 验证方式 | 结果 |
|-------|---------|------|
| 更名生效 2026-07-16、仍独立 | 官方博客 + Workspace Updates + 3 家媒体 | ✅ |
| 2026-06-08 升 Gemini 3.5 + cloud computer + 100+ skills | 官方博客 + The Verge | ✅ |
| 更名打断 <0.8.0 登录、v0.8.0 修复 | Issue #2022（0.7.3/0.8.0rc1 实测） | ✅ |
| RPC 未迁移、仅页面路由 302 | Issue #2022 维护者排查 | ✅ |
| ADR-0028 CLI/import 永久保留 | ADR-0028 原文 | ✅ |
| TAD pin 0.3.4 落在受影响区间 | tag v0.3.4 源码静态核验 + 更名事实 | ⚠️ 代码级证据，未 live 复现 |
| 0.9.0 未发布、最新 0.8.2 | PyPI/releases | ✅ |
| 无官方消费级 API | Google Cloud 企业 API 文档 | ✅（否定命题，一手锚 + Tier-3 辅助） |

---

## 人 CHECK（RG4 决策点）

本 verdict 为**推荐**。以下属判断类结论，需人拍板后才进入下一步（是否开 handoff）：
1. 是否采纳"选项 C（拆分改 + 升 pin）"，还是仅做文案、不动 pin（接受二级层风险）。
2. pin 目标选 **0.8.2** 还是等 **0.9.0**（dist 名迁移点）。
3. 升级回归的回退方案（双 venv vs pin 回退）。

> 本次为机制试点，上述人 CHECK 未真实触发（自决），已记入 `MECHANISM-FEEDBACK.md`。
