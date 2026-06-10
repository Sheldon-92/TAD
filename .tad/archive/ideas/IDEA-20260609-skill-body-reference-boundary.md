---
id: IDEA-20260609-skill-body-reference-boundary
title: "SKILL Body vs Reference 边界重新定义"
created: 2026-06-09
status: active
scope: framework
priority: P0
source: "Codex dogfood 2026-06-09 — Blake 跳过 Layer 2 / completion report"
---

# SKILL Body vs Reference 边界重新定义

## 问题

SKILL Progressive Loading Epic (2026-06-08) 把 Alex body 从 6202→1485 行、Blake 从 2114→737 行。安全关键词零丢失 (142+114=256)。但 Codex 真实执行测试（GEN food 项目 2026-06-09）暴露了一个根本性问题：

**最需要遵守规则的 agent 最不会主动去 Read references/**。

Gate 3 checklist、Layer 2 要求、completion report 格式被移到 references/ 后，Blake 在 Codex 中全部跳过了——不是故意违规，是根本不知道这些规则存在（不在上下文里 = 不存在）。

这和 v2.7 质量链失效是同一类问题：v2.7 是删除规则，这次是把规则放到了 agent 够不到的地方。

## 核心洞察

两类内容有本质区别：

**"显式触发进入的协议"** — 放 references/ 安全
- *bug, *discuss, *idea, *learn 等路径协议
- handoff_creation, acceptance 等工作流协议
- 通过 intent router / *command 显式进入，stub 的 load_when 会提醒模型去读
- 模型知道"我要做 X，让我读 X 的规则"

**"每次都必须遵守的执行纪律"** — 必须留 body
- Gate 3 checklist（每次实现完都要跑）
- Layer 2 要求（≥2 专家，每次都要）
- Completion report 格式（每次都要写）
- Evidence manifest 要求
- 没有人会"触发"遵守纪律——它要么在 context 里，要么被忽略

## 判断标准提案

问一个问题：**"如果 agent 不主动去读这个 reference，会不会在不知不觉中违反流程？"**

- 回答"不会"（agent 会在需要时被 stub 提醒）→ references/ OK
- 回答"会"（agent 不知道自己在跳过什么）→ 必须留 body

## 下一步

需要对 Alex 和 Blake 的 31+5=36 个 reference 文件逐个做这个判断，把"执行纪律类"的内容 inline 回 body（预计 +200-300 行），保持"显式触发类"在 references/。

两个平台都需要验证修正后的效果。

## 关联

- EPIC-20260608-skill-progressive-loading (已完成 — 需要修正)
- v2.7 质量链失效 (principles.md — 同类问题)
- Platform Capability Assumptions Decay Fast (patterns/handoff-design.md)
- SKILL Progressive Loading: Activation Works But Deep Protocol References Don't Auto-Load on Codex (patterns/handoff-design.md — 刚记录)
