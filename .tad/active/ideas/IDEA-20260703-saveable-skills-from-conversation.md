# IDEA: 对话中产出的 Workflow 可保存为可复用 Skill

**Date:** 2026-07-03
**Status:** captured
**Scope:** medium
**Source:** AI Tinkerers #33 — Linear Agent (linear.app)

---

## Context

Linear Agent 的 "Skills" 系统：当用户与 agent 的对话产出一个好的 workflow（比如 "收到 bug report → 打上 P1 标签 → 指派给 on-call → 创建 subtask"），用户可以一键保存为 reusable skill。下次遇到类似情况，Linear Agent 自动应用相关 skill。

另一个亮点：Code Intelligence — 连接 GitHub repo，让非技术团队成员通过 agent 查询代码库行为。

## Summary & Problem

TAD 已经有 skillify 机制（T1 ceremony、T2 skill-library、T3 harvest），但入口是 Gate 4 KA 时的 "triple-question" 评估。Linear 的方式更自然 — skill 从对话中直接 emerge，用户一键保存。

当前 TAD 的 skill 创建路径：做完任务 → Gate 4 → KA 问三个问题 → 发现模式 → 手动写 SCAND → 人类确认。Linear 的路径：对话中产出好 workflow → 一键保存 → 自动应用。

## Open Questions

- TAD 能否在 *discuss 或 *bug 过程中检测 "这个对话产出了一个可复用模式" 并提示保存？
- Linear 的 skill 是 prompt template 还是结构化 workflow？
- 自动应用 skill 的匹配机制是什么？keyword 还是 semantic？

## Relevance to Us

TAD 的 skill 创建太 ceremony-heavy（Gate → KA → SCAND → harvest → review）。Linear 的做法提示：skill 的产出应该是对话的自然副产品，不是事后回顾。
