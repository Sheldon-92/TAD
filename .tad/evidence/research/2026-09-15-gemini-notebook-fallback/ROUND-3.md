# ROUND 3 — 分类、链结构、反例（Q4, Q5, Q6）

> 检索日期 2026-09-15。本轮闭合：给出可 grep 的分类 + 链结构结论 + 最强反例。

## 本轮查什么
Q4 哪些 token 改/留；Q5 fallback 链是否改结构；Q6 推翻"只改文案"的反例。

## 本轮发现

### F3.1 全仓 "NotebookLM" 分布（去 evidence 后）
| 文件 | 计数 | 性质 |
|---|---|---|
| `.agents/skills/research-notebook/SKILL.md`（`.claude` 镜像同） | 96 | 绝大多数是 CLI/路径/标识符 |
| `.tad/cross-model/capabilities.yaml` | 39 | capability key `notebooklm_research` + CLI 命令 |
| `.agents/skills/alex/SKILL.md` | 29 | routing 文案 + 命令 |
| `research-plan-protocol.md` | 28 | 命令 + 说明 |
| `research-github/SKILL.md` | 26 | CLI/路径 |
| `setup-notebooklm.sh` | 18 | 路径/命令 |
| `blake/SKILL.md` + `notebooklm-access.md` | 14+4 | 协议名 + prose |
| 其余（academic-research / discuss-path / research-review 等） | 各 1–4 | prose 为主 | [S12]

### F3.2 可 grep 复核的分类：产品名（改）vs 工具标识符（留）
| Token / 模式 | 类别 | 处置 | 判据 |
|---|---|---|---|
| CLI 二进制 `notebooklm` 及子命令（`ask`/`source add`…） | 工具标识符 | **保留** | 上游 ADR-0028 永久保留、不弃用 [S5] |
| venv 路径 `~/.tad-notebooklm-venv` | TAD 本地路径 | **保留** | 改则需迁移已装环境，零功能收益 |
| pip 发行名 `notebooklm-py`（setup 脚本内） | 上游标识符 | **暂保留** | 上游 0.9.0 改为 `gemini-notebook-py`，旧名保留为 shim 继续可解析 [S5][S6] |
| `setup-notebooklm.sh` / `notebooklm-access.md` 文件名 | TAD 标识符 | **保留** | 被引用，改名=churn 无收益 |
| fallback key `notebooklm_research`（config-workflow / capabilities） | 配置标识符 | **保留** | 链引用它；改名会波及 routing 且无收益 |
| 环境变量 `NOTEBOOKLM_*` | 上游标识符 | **保留** | 非 TAD 所有 |
| prose 产品名：`云端 NotebookLM`、`fallback: NotebookLM`、`INTERNAL NotebookLM`、`auto-detected by NotebookLM`、`NotebookLM Integration`、`NotebookLM not ready` | 产品名 | **改** | 面向人/可发现性；官方名已切换 [S2][S3] |
| 首处出现 | 产品名 | **首次双标** `Gemini Notebook（原 NotebookLM）` | 兼容仍在搜旧名的人 [S2] |

### F3.3 fallback 链结构：**不改结构**
- `.tad/config-workflow.yaml`：`research.fallback_chains = primary local_wiki → secondary notebooklm_research → tertiary claude_websearch`。[S12]
- 更名未改服务/RPC（F2.4），层语义不变 → 无需动链结构，只需产品名文案。[S7]

### F3.4 反例搜寻（最强反方证据）
- **CE1 无官方消费级 API**：Google 只有企业版 API（Gemini Notebook Enterprise / Cloud），消费级官方 API "在做了"但无时间线。TAD 依赖的是**非官方**客户端（notebooklm-py，5.6k★）。→ 二级层天然脆弱。[S9][S13]
- **CE2 "只改文案"不完整**：更名打断了 `<0.8.0` 登录，TAD pin 0.3.4（F2.2/F2.3）→ 必须**同时升版本**，否则二级层是坏的。[S7]
- **CE3 上游 dist 名待变**：ADR-0028 的 0.9.0 尚未发布；旧名 shim 永久可解析，故低紧急，但 setup 脚本未来宜指向新 dist。[S5][S6]
- **CE4 代码执行扩大攻击面**：cloud computer 可对上传源写/跑代码；公开材料**缺完整安全规格**（隔离/出网/持久化/密钥）。TAD 若未来用其代码执行，需先安全评审。[S14]
- **CE5 可能再次改名**：ADR-0028 明写"若 Google 再改名，接受一个过时品牌 dist 名的风险"。→ 强化"品牌名不进承重标识符"。[S5]
- **CE6 pin 与"永不盲升"冲突**：0.3.4 是供应链安全 pin，但升到 ≥0.8.0 是登录可用的硬要求 → 需一次有意识的 re-pin（带证据），非盲升。[S7][S12]

## 本轮结论
分类成立且可 grep 复核：**改 prose 产品名、留全部工具标识符、链结构不动**；但推荐必须附一条功能项——把客户端 pin 从 0.3.4 抬到 ≥0.8.0（建议 0.8.2），否则"保留二级层"会保留一个坏掉的二级层。CE1/CE5 是最强反例：它们不推翻推荐，但要求把二级层标注为"脆弱、依赖非官方客户端"。
