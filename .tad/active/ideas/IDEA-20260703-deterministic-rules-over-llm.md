# IDEA: 200 行确定性规则 > LLM 分类（特定场景）

**Date:** 2026-07-03
**Status:** captured
**Scope:** small
**Source:** AI Tinkerers #33 — Daria's Desk (Daria Svetlova, Berlin, 3 stars)

---

## Context

Daria's Desk 是一个本地 Slack 分流工具。核心分类逻辑是 ~200 行 regex/heuristic，刻意不用 LLM。单 HTML 文件前端（vanilla JS, no build step）。SQLite 后端。Slack token 存 macOS Keychain。

项目描述："Built by a designer pair-programming with Claude."

GitHub: github.com/dariasvetlovaa/darias-desk (3 stars, 4 commits, MIT)

## Summary & Problem

"什么时候 200 行规则够用，什么时候需要 LLM" 是一个重要的设计判断。Daria's Desk 表明：当分类任务有明确模式（greeting vs actionable request）且用户可以通过 "learning filter" 标记误报时，确定性规则比 LLM 更快、更可预测、更便宜。

另一个启发：设计师用 Claude 配对编程做出完整产品（Python Flask + SQLite + 单 HTML），说明 "non-developer + Claude" 组合的生产力边界在扩大。

## Open Questions

- TAD 的 intent router 目前用 LLM 做意图检测 — 有多少场景可以用 regex/keyword 规则替代？
- "learning filter"（用户标记误报来改进分类）模式是否适合 TAD 的 anti-rationalization 检测？
- 单 HTML 文件 + 无构建步骤的前端 — 是否适合 TAD 的工具（如 brain-index viewer）？

## Relevance to Us

TAD 的 SessionStart hook 和 intent router 在 "确定性规则 vs LLM 判断" 的边界上。这个 idea 提示：先用规则做能做的，LLM 只处理规则无法覆盖的模糊地带。
