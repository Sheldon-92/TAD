# ROUND 2 — 客户端可用性（Q3）

> 检索日期 2026-09-15。本轮为深挖轮，主攻"工具层能否照用"。

## 本轮查什么
TAD 实际调用的 `notebooklm` CLI（`teng-lin/notebooklm-py`）在更名后是否仍可用、命名是否变化、是否已发布修复。

## 本轮发现

### F2.1 客户端项目主张"服务未变、库照用"
- `notebooklm-py` README 顶部 July 2026 注记："existing links redirect automatically, and this library drives the same underlying service and works unchanged. The package keeps the `notebooklm-py` name." [S4]
- README 另一处已把标题改为 "Google Gemini Notebook Skill & Unofficial Python API"。[S4]
- 结论方向：**RPC 服务未迁移**（见 F2.4），故库的协议层不变。

### F2.2 ⚠️ 但更名**确实打断了登录**：`< 0.8.0` 的客户端会失败
- Issue #2022 (2026-07-29)：《Login fails: Google rebranded NotebookLM to "Gemini Notebook"》。症状：`notebooklm login` 在 Google 登录成功后仍 5 分钟超时 "Login not detected"。[S7]
- 根因：登录落地页从 `notebooklm.google.com` 302 到 `notebook.google.com`；`playwright_login.py` / `_env.py` 的 host 白名单**硬编码**只允许 `notebooklm.google.com`，`NOTEBOOKLM_BASE_URL` 覆盖也被拒。[S7]
- 修复：#2015（2026-07-27 合入 main），**首个含修复的发布是 v0.8.0（2026-08-03）**。[S7][S6]
- 报告者实测 0.7.3 与 0.8.0rc1 均失败；install-from-PyPI 当时无法认证。[S7]
- Issue #2019 佐证：更名 cutover 当天（2026-07-28）起 RPC health 脚本失败，同一 commit 前一后失败，外部变更而非代码提交；CLI/库本身免疫，损坏的是脚本 cookie 域处理。[S8]

### F2.3 ⚠️⚠️ TAD 的固定版本远低于修复线
- `.tad/cross-model/setup-notebooklm.sh:40` 安装 `notebooklm-py[browser]==0.3.4`（"pinned for supply-chain safety"）。[S12]
- 技能 preflight 的版本下限是 `≥0.3.4`（`research-github/SKILL.md`、`research-notebook/SKILL.md`）。[S12]
- 0.3.4 早于更名修复线 0.8.0 多个 minor；按 F2.2 的同一白名单缺陷推断，TAD 当前 pin 的客户端**很可能无法完成更名后的登录**（推断，非直接实测 0.3.4；见"未解决弱点"）。
- 另佐证：0.3.4 本身曾在 2026-04 有 `GET_NOTEBOOK` RPC null-result 读取 bug（issue #294），后修复。[S8]

### F2.4 服务/RPC 层未迁移（命名变化是浅层的）
- Issue #2022 排查结论：`POST /_/LabsTailwindUi/data/batchexecute` **仍服务在 `notebooklm.google.com` 无重定向**；只有页面路由（`/`、`/notebook/`）302 到 `notebook.google.com`。RPC 基址覆盖被"刻意不做"。真正的后端/域迁移 tracked in issue #1977 + ADR-0028。[S7]
- 这意味着：**未来可能存在一次真正的后端/域迁移**（不同于本次品牌更名），届时才是工具层会断的时候。

### F2.5 上游命名策略：dist 会改名，但 CLI/import 名永久保留
- ADR-0028（Proposed v3, 2026-08-03 前后）：PyPI 发行名 `notebooklm-py` → `gemini-notebook-py`（0.9.0 单次完成）；**import 包 `notebooklm` 与全部 `notebooklm*` CLI 脚本永久保留**（不弃用），同时**新增** `gemini-notebook{,-mcp,-server}` 脚本。[S5]
- 现状：`gemini-notebook-py` 在 PyPI 只有 0.0.1 占位（2026-08-03）。最新实发布为 0.8.2（2026-09-02）；0.9.0 尚未发布。[S5][S6]

## 本轮结论
- 库的**协议/服务**层未变（RPC 未迁移），README"works unchanged"对**已升级到 ≥0.8.0** 的用户成立。
- 但"works unchanged"**不是跨版本无条件成立**：更名打断了 `< 0.8.0` 的登录，TAD 的 pin（0.3.4）落在断带内。
- 上游已把 CLI/import 标识符**永久冻结**（ADR-0028），因此 TAD 的 `notebooklm` 命令/venv 路径无需因命名而改。

## 新冒出的问题
- Q4/Q5：本地协议里哪些 token 属"产品名"、哪些属"已被上游永久冻结的工具标识符"？→ R3。
- Q6：还有哪些反例？→ R3。
