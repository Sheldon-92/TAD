# Raw ask results — open-notebook evaluation (2026-07-01)
Notebook: d46515cf-2f48-4f43-a09c-2f9f7d04e947 | conversation: 1bbe11f1-e993-43b1-83a3-8f92f8811288
Main ask: architecture / quality-vs-NotebookLM / automation / self-hosting cost.
Key findings (citations refer to notebook sources):
- Three-tier async-first: Next.js15+React19 (8502) / FastAPI py3.11 (5055, Pydantic v2) / SurrealDB multi-model DB with NATIVE vector storage. LangGraph orchestrates 5 workflows. Esperanto + ModelManager = per-task model assignment, per-request override (RunnableConfig), fallback + token cost estimation.
- Chat Mode = full-context to LLM; Ask Mode = RAG (cosine vector + FTS over SurrealDB chunks).
- Quality: NotebookLM = fixed Gemini, mature citations w/ highlighting. open-notebook = quality tracks configured LLM; Transformations prompts fully customizable; 3-level per-source context visibility. Citation highlighting UNDER REBUILD as of 2026-06 ("Basic references" in comparison tables) though numbered clickable citation blocks work; notes saved with source citations.
- Automation: full REST API, 20+ endpoints, all CRUD (notebooks/sources/notes/chat_session/transformation/podcast), Swagger at :5055/docs. NO native CLI ("Docker required. No native binary"). Scripting via curl/Python against API.
- Cost/ops: all-local Ollama = $0 tokens (VRAM-bound: 4-bit ≈0.5GB/1B params; 8GB GPU→7-8B models); hybrid = pay per token. Default docker-compose = dev mode: no HTTPS, plaintext-password middleware, no health checks/auto-backup; sync text extraction can block API on large files; SurrealDB startup migration errors reported.
- Saturation check: COMPLETE — "ideal as COMPLEMENT; direct REPLACEMENT trades citation precision, speed, and production stability."

---

## Round 2 (2026-07-01 晚): Local Deep Research (LDR) 并入对比

**新增源**: 5 个 LDR 源（repo / raw README / api-quickstart.md / BENCHMARKING.md / YouTube API 评测），自动发现一轮跑偏（拉回 open-notebook 重复页），已清理 4 个无关/重复源。当前 21 sources。

**Ask 核心结果** (conversation 1bbe11f1):

1. **双重角色确认**: LDR 既是自主深度研究引擎（LangGraph agent 自主决定检索词、切换 arXiv/PubMed/SearXNG、判断何时合成报告），又是 source-grounded 知识库——研究中发现的文献可一键存入 AES-256 加密 Library，自动分块+向量化，之后可跨"本地已存文献 + 实时网络"提问并生成带引文报告。
2. **编程接入**: 原生 Python 客户端 LDRClient（自动处理 CSRF/session）；REST API（POST /api/start_research → GET /api/research/{id}/status → GET /api/report/{id}）；1.0 起所有端点强制认证（session cookie + X-CSRF-Token）；**内置 MCP server（`ldr-mcp`）暴露 quick_research/detailed_research/generate_report 给 Claude Code 直接调用**。
3. **引文对比**: 源内无 LDR vs NotebookLM 引文界面直接对比（信息缺口）。逻辑差异：NotebookLM 引文限于已上传文档；LDR 引用可跨本地库+学术库+live web。
4. **基准细节**: SimpleQA 95.7% (287/300) + xbench-DeepSearch 77% = RTX 3090 + 本地 Qwen3.6-27B + langgraph-agent 策略 + Serper 搜索。Caveats（BENCHMARKING.md 自己写明）: 污染风险、LLM grader ~1% 误判且偏保守、小样本 Wilson 区间大（<500 样本别优化 2-3pp 差距）、跨 run 不可比、高分不预测真实研究课题表现。
