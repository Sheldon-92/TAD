---
name: project_ai-native-reading-companion
description: "Epic reimagining the reading experience — EPUB→AI co-read reader; Phase 2 Gate 3 PASS, Phase 3 bridge next"
metadata: 
  node_type: memory
  type: project
  originSessionId: 09bcd693-8bd4-45cc-8aec-5f8028653105
---

2026-06-13 新 Epic `EPIC-20260613-ai-native-reading-companion` (TAD 第3个活跃 Epic, 已达上限). 用户真实意图: **重新设计阅读体验**, 不只是做个 skill — 丢任意文件→AI 共读器, 北极星「让人想得更深而非更少」(有实证: AI 摘要会让理解变浅).

**4 Phase**: 1 研究(✅) → 2 EPUB 阅读器+计划+标注(✅ Gate4 ACCEPTED, 真书浏览器验过) → 3 实时共读桥(localhost SSE/POST + session 开关 + 选中讨论 + 苏格拉底式 AI)【下一个】 → 4 沉淀+多格式(PDF/TXT/URL).

**Phase 2 验收要点**: 真书(29章/832KB Yvon Chouinard EPUB)在 Chrome 实测——只有真浏览器才照出三击短行产生空 mark 的 bug(代码层11AC全绿+2 reviewer都漏了), 修后浏览器复验过. 教训: UI 类交付必须真浏览器验, 不能只靠 AC/node-check.

**锁定决策**: sidecar 桥 + HTML 是渲染视图; 标注真相源在数据文件(W3C TextQuote+prefix/suffix+refinedBy.pid+source_hash); AI=主动共研者(苏格拉底/先你综合, 不自动总结); session 开关(一次性发上下文/条, 手动关); 与 research-notebook 完全独立; MVP=EPUB; 实时双向用本地桥服务(Phase 2 暂用 download+`render --save` 合并, Phase 3 接管实时).

**Phase 2 产物**: skill `reading-companion` (stdlib-only py: epub-ingest/render/plan-gen/export-annotations + reader.html + 含重复句的 fixture). 排版 66ch/1.5/serif≥18px/cream+dark WCAG AA. §4.4 重挂载算法(段内 quote-match, 源变标 stale 不静默错挂).

**研究库**: NotebookLM `ai-native-reading` (189fbf20, 19源, 持久可再查). 设计规则: `.tad/evidence/research/ai-native-reading/DESIGN-FINDINGS.md`.

**Phase 3 ✅ Gate 4 ACCEPTED (2026-06-14/15, 真实共读跑通)**: localhost 桥(stdlib ThreadingHTTPServer + queue.Queue 长轮询 + SSE) + bridge-client(poll/reply/close/append-thread) + reader.html 聊天面板 + SKILL co-read loop. Gate2 安全审 8 P0(DNS-rebind Host 白名单/prompt-injection 隔离 envelope/header-token/CSP/路径穿越/queue+daemon_threads+分线程 shutdown). Gate3 独立审又抓 1 P0(**CSP default-src 'self' 无 nonce → 连自己内联脚本都被挡 → 真浏览器里面板是死的**; curl AC + agent 自报浏览器都漏了)→ 改 per-response nonce 修复. 真浏览器实测: open URL → SSE 连上(CSP nonce 生效活证) → 发「这本书说什么」→ 我苏格拉底式回(不直接总结,反问"你信公司能主动牺牲利润吗")→ SSE 流回面板 → thread 持久化 → 结束共读 关停释放端口. **核心教训: UI 类必须真浏览器验,curl/node-check/agent-自报浏览器都不算**.

**Phase 4 ✅ (2026-06-14) → Epic ✅ COMPLETE 4/4 + 已归档**: text/url/pdf ingest 适配器(全经 _rc_common 共享 helper 保 schema+决定性) + export-notes(按章节笔记+Open Questions[plan+thread]+对话精华) + ingest.py 路由. 全部产出字节兼容 content.json → 复用 render/plan/bridge 零改. Gate3 双审 0 P0,3 P1(安全分支验证空转/heading-only近空书/epub hash 漂移无守)全修+独立验. v2 延期: URL SSRF TOCTOU / PDF 整页成章 / export-notes 自身 hash gate / 闪卡+KM同步.

**交付**: skill `reading-companion`(14 stdlib 工具 + reader.html + fixtures), 已提交分支 `feat/reading-companion`(dc51f50 P2+3, 5efca79 P4). 运行: `python3 tools/ingest.py <file|url> -o .reading/x/content.json` → render/plan-gen → bridge-server 共读 → export-notes 沉淀.

**贯穿教训(已入 patterns/ac-verification)**: 每个 phase 独立 review 都抓到「AC 全绿/agent 自报浏览器通过」漏掉的真缺陷(P2 划线无反应/P3 CSP 让面板在真浏览器里死掉/P4 安全分支空转). UI 与安全分支必须在「被测属性真正生效的路径」上执行验证. 相关 [[user_agent-builder-goals]] [[feedback_pick-generative-directions]] [[feedback_yolo-epic-workflow-args]].
