---
title: Goal-Driven Research Director — 业务目标驱动的自主研究
date: 2026-05-04
status: promoted
scope: large
---

# IDEA: Goal-Driven Research Director

## Summary & Problem

当前 Alex 的研究总监能力是"工具层" — 会管理 notebook、会生成报告、会整合。但缺乏"战略层" — 不知道用户的业务目标是什么，不会从目标反推该研究什么，不会自主判断哪些研究缺失、哪些研究已经足够服务目标。

用户的期望：**"我不关心他建了多少 notebook，我只关心我的内容能不能更好触及业务价值。Alex 要竭尽全力帮我达成业务目标。研究多少、做什么，应该是他来定、他来判断。"**

## Core Gap

```
现在:  用户提需求 → Alex 执行研究 → 产出报告 → 结束
期望:  业务目标 → Alex 自主分解研究问题 → 自主发起研究 → 研究产出决策 → 决策驱动行动 → 行动反哺目标评估
```

缺失的环节：
1. **目标定义机制** — 没有 KPI/OKR 文件让 Alex 知道"成功长什么样"
2. **目标→研究问题分解** — Alex 不会说"目标是 X，所以需要研究 A、B、C"
3. **自主研究发起** — 只在用户进入 *discuss 时被动触发，不会主动说"你缺少关于 Y 的研究"
4. **研究→决策追踪** — 不知道哪个研究最终影响了哪个决策
5. **决策→结果评估** — 不追踪"这个决策产出了什么业务结果"

## Open Questions

- 业务目标定义放哪里？ROADMAP.md 扩展？还是独立的 OBJECTIVES.md？
- Alex 的自主程度：完全自主研究（后台运行）vs 每次发起前确认？
- 研究→决策追踪如何不变成额外的人工记录负担？
- 这是 TAD 框架功能还是特定项目（内容副业）的需求？

## Potential Scope

- 独立 Epic（4-5 phases）
- 核心改动：Alex SKILL 增加"业务目标感知"层 + 研究策略自动生成 + 闭环追踪
- 前置条件：Phase 3 E2E 验证完成后，用户有实际使用体验再设计

## Promoted To

Promoted To: Epic (via *analyze — 2026-05-04)
Epic: .tad/active/epics/EPIC-20260504-goal-driven-research.md
