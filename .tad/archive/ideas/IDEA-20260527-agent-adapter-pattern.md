# Idea: Unified Agent Adapter Pattern

**ID:** IDEA-20260527-agent-adapter-pattern
**Date:** 2026-05-27
**Status:** captured
**Scope:** large

---

## Summary & Problem

为 TAD 建立统一的 agent 检测 + 调用协议层，让 TAD 能在 Claude Code 以外的 coding agent 上运行（Codex、Gemini CLI、Cursor Agent、OpenCode、Qwen 等）。当前 TAD 的 cross-model invocation 只是一个 markdown guide（手写 bash 命令调 codex/gemini），没有统一的类型定义、自动检测、协议抽象。html-anything 的 `detect.ts` 用一个 `AgentDef` 接口适配了 17 个 agent（3 种协议：stdin / argv / argv-message），自动扫 PATH + 20 个常见安装目录 — 这是 TAD Universal Method 方向的必备基础设施。

## Open Questions

- TAD 需要适配的协议层跟 html-anything 不同：html-anything 是"给 agent 一个 prompt，收 HTML 输出"（单轮），TAD 是"让 agent 加载 SKILL.md 并执行多步任务"（多轮 + 文件读写）。协议层需要怎么调整？
- 最小可行集：先支持哪几个 agent？Claude Code + Codex（已有经验）+ Gemini（已有经验）？
- 检测机制：html-anything 用 PATH 扫描 + existsSync。TAD 是 CLI framework，同样的方式可行吗？还是需要更复杂的 capability probing？
- 输出在哪里：独立的 `.tad/agents/` 适配器目录？还是扩展现有 `.tad/guides/cross-model-invocation.md`？
- 与 IDEA-20260527-codex-adapter-yaml 的关系：那个 idea 是 pack 级别的 Codex YAML 适配（6 行），这个是 TAD 框架级别的 agent 统一层。是包含关系还是并列？
- 与 IDEA-20260527-tad-methodology-skeleton 的关系：methodology skeleton 是跨领域流程抽象，adapter pattern 是跨 agent 运行时抽象。两者是 TAD Universal Method 的两个独立支柱。

## Notes

- 研究来源：html-anything deep research notebook `d7022a6e-8de5-4e52-8f7c-1518cd4f6d76` (19 sources, 4 ask rounds)
- 关键源文件：`next/src/lib/agents/detect.ts`（17 agent 定义 + PATH 扫描）、`invoke.ts`（spawn + SSE streaming）、`argv.ts`（per-agent CLI flags + parseLine）
- html-anything 的限制（NotebookLM Round 4 发现）：parser fragility — 每个 agent 的 JSON stream 格式不同，upstream schema 变化直接 break。TAD 设计时需要考虑更鲁棒的解析
- 现有 TAD 资产：`.tad/guides/cross-model-invocation.md`（codex + gemini 手动指南）、`AGENTS.md`（Codex 路由）

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
