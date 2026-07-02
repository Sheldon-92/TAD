# 决策简报: Open Notebook (lfnovo) vs Google NotebookLM

**决策问题**: 是否用自托管 open-notebook 替代/补充 TAD 当前的 Google NotebookLM CLI 研究后端（现状：免费但 CLI 不稳定、速度慢）？
**Notebook**: d46515cf-2f48-4f43-a09c-2f9f7d04e947（10 sources，13 imported / 3 pruned）
**Date**: 2026-07-01

---

## 选项

| 选项 | 一句话 |
|------|--------|
| A. 保持 NotebookLM CLI | 免费 Gemini 算力 + 成熟引文，忍受不稳定与慢 |
| B. 切换到 open-notebook | 全 REST API 自动化 + 模型自选，自付 token + 自己运维 + 引文较弱 |
| C. 混合 | NotebookLM 继续做免费深度研究；open-notebook 承接需要稳定 API 自动化的管线 |
| **D. Google 官方 Enterprise API（2026-07-01 追加，新的最优候选）** | 官方 REST API 治稳定性 + 保留 Google 算力与引文，~$9/月/席位 |

## 追加发现：Google 官方 NotebookLM Enterprise API（2026-07-01）

- Google 2026 年推出官方 NotebookLM API，挂在 **NotebookLM Enterprise**（Gemini Enterprise）下，走 Discovery Engine REST（`v1alpha`）
- 文档覆盖：notebook CRUD、源管理、音频概览、notebook 查询、分享（IAM role）
- **鉴权 = gcloud 原生**：官方示例全部使用 `curl -H "Authorization: Bearer $(gcloud auth print-access-token)"`
- **本机实测（2026-07-01）**：gcloud SDK 562 已装、已登录（zhaosheldon92@gmail.com，5 个项目）；端点格式 `https://us-discoveryengine.googleapis.com/v1alpha/projects/{PROJECT_NUMBER}/locations/us/notebooks:listRecentlyViewed` 已验证可达（返回结构化 JSON 403 SERVICE_DISABLED，非 404）
- **两道剩余门槛**：(1) 项目启用 discoveryengine.googleapis.com（一条命令，免费可逆，未执行——用户选择到此为止）；(2) NotebookLM Enterprise license ~$9/月，14 天全功能免费试用，需走 Gemini Enterprise 设置流程
- **迁移注意**：Enterprise 是独立环境，消费版的 15 个 notebook 不会自动迁移，需用 API 重建（源列表在 REGISTRY 可复原）
- **未验证**（若重启此方向，POC 首先测这两项）：(a) ask 式带引文跨源问答端点的返回格式；(b) 是否有 "discover sources" 自动研究的 API 对应物——若无，`*research` 的 add-research 环节仍需 CLI 或自拼搜索
- Sources: docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/api-notebooks（+ api-notebooks-sources, set-up-licensing）

## 证据

### open-notebook 技术路线（已对 repo 权威源验证 ✅）
- **三层异步架构**: Next.js 15 + React 19 前端 (8502) / FastAPI + Python 3.11 后端 (5055) / SurrealDB 多模型库（原生向量检索，无需外部向量库）[repo docs/7-DEVELOPMENT/architecture.md]
- **工作流编排**: LangGraph 状态机（摄入/对话/RAG 问答/摘要/通用任务 5 条工作流）
- **模型路由**: Esperanto 框架 + ModelManager — 按任务分派不同模型（chat/embedding/transformation 可各配一个），支持单请求覆写、自动回退、token 成本估算。README 称 18+ providers（architecture doc 写 8+，以 README 较新为准，含 Ollama 全本地）
- **双模式**: Chat Mode = 全文直送 LLM（贵、上下文全）；Ask Mode = 标准 RAG（余弦向量 + 全文检索取 chunks，便宜、精准）

### 质量对比
- **引文落地是 open-notebook 明显短板**: 引文高亮截至 2026-06 仍在重构中，功能对比表标注 "Basic references"；NotebookLM 引文成熟（原文定位 + 高亮）[多源一致 ⚠️ issues 搜索未直接确认重构状态]
- **回答质量 = 你配置的模型**: 配 Claude/GPT 级云模型可超过 NotebookLM 固定 Gemini；配本地小模型（<8B）则明显浅。NotebookLM 无法干预 system prompt，open-notebook 的 Transformations 提示词完全可定制
- **200+ 页 PDF 本地可处理**，但 CPU-only 机器上摄入向量化需数分钟

### 自动化能力（TAD 最关心的维度）
- ✅ **完整 REST API**: 5055 端口 20+ endpoints，notebooks/sources/notes/chat/transformations/podcast 全 CRUD，Swagger 自文档 (localhost:5055/docs) [已验证 ✅]
- ❌ **无原生 CLI**，Docker 部署必需（repo 根目录无 CLI 入口，Dockerfile + docker-compose）[已验证 ✅]
- ⚠️ **无内置自动 web 研究/源发现**——NotebookLM 的 "discover sources"（TAD `source add-research` 依赖的能力）没有对应物，需要自己用 API + 外部搜索拼

### 成本与运维
- Token: 全本地 Ollama = $0 但质量受 VRAM 制约（4-bit 下每 1B 参数 ≈ 0.5GB VRAM；8GB GPU 跑 7-8B）；混合模式 = 按用量付 API 费
- 稳定性: 默认 docker-compose 是开发模式——无 HTTPS、单用户明文口令认证、无健康检查/自动备份；本机 localhost 使用可接受，公网需硬化
- 同步文本提取处理大文件时可能短暂阻塞 API

## 推荐

**（2026-07-01 更新）首选探索方向改为 D（官方 Enterprise API）**：$9/月买"官方稳定 + Google 引文质量 + 不烧自己 token"，性价比优于自托管 open-notebook。重启条件：愿意开 14 天试用做 POC，首测上方两个未验证项。open-notebook 降级为备选（若 Google 官方路线的 license/迁移成本不可接受）。

原推荐（对 open-notebook 本身仍有效）——**方向 C（混合），但不建议现在动 TAD 管线**：
1. open-notebook 对 TAD 的真正吸引力是**官方 REST API 取代非官方 CLI**（稳定性根因），且答案质量可用自己的模型上限拉高
2. 但两个硬伤使"直接替换"不成立：(a) 引文落地弱于 NotebookLM——TAD 研究链严重依赖 citation-based saturation 检查；(b) 无自动源发现——`*research` Standard 流程的 `add-research` 步骤没有对应物
3. token 成本从 $0（Google 补贴）变为自付，与"不耗费我们自己的 token"的现有优势直接冲突
4. 合理动作：本机 Docker 起一个实例试用 1-2 周，重点实测 Ask Mode 引文质量 + API 脚本化体验，再决定是否为 TAD 加一个可切换后端

## 未知风险

- 引文高亮重构的实际完成度/时间表（issues 搜索未确认，仅媒体文章提及）
- Ask Mode RAG 检索质量 vs NotebookLM 的实测对比（无第三方 benchmark，只有主观评测文章）
- SurrealDB 长期数据迁移稳定性（有源提到启动时 migration 报错隐患）
- 多 notebook 规模化（TAD 有 15 个 notebook）下的检索/管理体验未知

## Claim 验证

| Claim | 验证方式 | 结果 |
|-------|---------|------|
| Next.js 15 + React 19 / FastAPI 5055 / SurrealDB / LangGraph / Esperanto | repo architecture.md | ✅ 已验证 |
| 完整 REST API + Swagger at :5055/docs | repo README | ✅ 已验证 |
| 无原生 CLI，Docker required | repo 根目录树 | ✅ 已验证 |
| 34.4k stars（源文章称 26k 为过时数据） | gh api (2026-07-01) | ✅ 已更正: 26k→34,362 |
| 18+ providers | README 18+ / architecture doc 8+ | ⚠️ 文档内部不一致，取 README |
| 引文高亮 2026-06 仍在重构 | gh issues 搜索无果 | ⚠️ 待验证（仅媒体源） |

---

# 追加 Round 2 (2026-07-01 晚): Local Deep Research 并入为第三候选

**新增选项 E**: LearningCircuit/local-deep-research (LDR) — 8,632 stars, MIT, 活跃（最后 push 2026-07-02）

## E 的画像与定位

| 维度 | 事实 | 对 TAD 的意义 |
|------|------|--------------|
| 范式 | **双重角色**：自主深度研究引擎（LangGraph agent 自主选引擎/追问/合成）+ source-grounded 加密知识库（存档文献→分块向量化→跨"本地库+live web"带引文提问） | 不只是组件，是完整第三候选 |
| 编程接入 | Python LDRClient + REST API (start_research/status/report) + **内置 MCP server (`ldr-mcp`, STDIO, `pip install "local-deep-research[mcp]"`)** | MCP = Claude Code 零胶水直调 quick_research/detailed_research/generate_report，集成成本远低于 open-notebook 的裸 REST |
| 源发现 | 10+ 引擎（arXiv/PubMed/Semantic Scholar/SearXNG/GitHub…）自主检索 | **正好填 open-notebook 的最大短板**（无 discover sources） |
| 引文 | 报告带引用；但源内**无与 NotebookLM 引文落地质量的直接对比**（信息缺口，POC 首测项） | TAD 研究链依赖 citation saturation，此项必须实测 |
| 基准 | SimpleQA ~95% (n=500, RTX 3090 + Qwen3.6-27B + langgraph-agent + Serper)；xbench-DeepSearch 77%。项目自己写明 caveats：污染风险、grader ~1% 误判、小样本区间大 | 声称诚实（自带 caveats + HF leaderboard），但 3090 配置不可直接迁移到本机 Mac |
| 成本运维 | pip/Docker；全本地 Ollama = $0（质量受硬件限）；云模型自付 token；1.0 起全端点强制认证（session + CSRF），SQLCipher 加密 | 自付 token 与"不烧自己 token"冲突——除非本地模型质量够用 |

## 更新后的推荐（Round 2）

三候选分层定位，**不再是单选题**：

1. **Notebook 层（囤源→带引文追问）**: 首选仍是 **D（Google 官方 Enterprise API）** — 引文成熟度 + Google 补贴算力无可替代。
2. **Deep-research 层（自主找源→初筛→报告）**: **E (LDR) 成为新首选**，取代 open-notebook 的备选地位 — 它同时有源发现（open-notebook 没有）+ MCP 集成（open-notebook 没有）+ 加密知识库。潜在组合："LDR 负责找+初筛，NotebookLM 负责沉淀+引文追问"，或 LDR MCP 直接增强 `*research --deep` 的 WebSearch 路径。
3. **open-notebook**: 降为第三 — 它的两个卖点（REST API、模型自选）LDR 都有，且 LDR 多出源发现 + MCP。

**下一步动作（若推进）**: 本机 `pip install "local-deep-research[mcp]"` POC，首测两项：(a) Library 存档后 cited-ask 的引文落地质量 vs NotebookLM；(b) MCP server 在 Claude Code 里的实际调用体验（headless research run 全链路）。

## Round 2 Claim 验证

| Claim | 验证方式 | 结果 |
|-------|---------|------|
| 8.6K stars / MIT / 活跃 | gh api (2026-07-01) | ✅ 8,632 stars, MIT, pushed 2026-07-02 |
| MCP server 存在 (`ldr-mcp`) | README L364-383 + docs/mcp-server.md | ✅ 已验证（STDIO 本地 only，无内置认证——README 自带安全警告） |
| SimpleQA ~95% | README badge (n=500) + BENCHMARKING.md | ✅ 声称存在且 caveats 自述完整；⚠️ n 值文档间有 300/500 出入 |
| REST API + LDRClient + CSRF auth | api-quickstart.md (notebook source) | ✅ 已验证 |
| 引文质量 vs NotebookLM | 源内无直接对比 | ⚠️ 信息缺口 → POC 首测项 |
