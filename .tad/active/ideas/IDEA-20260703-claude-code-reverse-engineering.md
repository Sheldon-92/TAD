# IDEA: Claude Code 自动化逆向工程 + 游戏数据→训练数据 Pipeline

**Date:** 2026-07-03
**Status:** captured
**Scope:** large
**Source:** AI Tinkerers #33 — Originlab 3D Game Capture (Antoine Gargot, $8M seed by Lightspeed)

---

## Context

Originlab 用 Claude Code (Opus) 自动化了完整的游戏引擎集成流程：memory-address hunting → DirectX hooking → NVENC encoding → remote build → first-run capture。一个不可见的 plugin 在游戏引擎内运行，采集同步的 camera pose、depth map、semantic masks、scene geometry。采集的数据作为 rights-cleared 多模态训练数据卖给 world-model AI lab。

$8M seed (2026-05, Lightspeed Venture Partners)。TechCrunch 报道。

## Summary & Problem

两个独立的 idea 点：

**1. Claude Code 作为逆向工程自动化工具**
传统逆向工程是深度手动工作（读汇编、找内存地址、写 hook）。Originlab 展示 Claude Code 可以自动化这个流程 — "chain it all from one terminal"。这把 Claude Code 的应用边界从 "写代码" 推到了 "理解和操纵已有的二进制系统"。

**2. 游戏玩法 → AI 训练数据的 Blueprint**
一个完整的数据 pipeline：游戏引擎内采集 → 结构化元数据 → 云存储 → 卖给 AI lab。这是 "synthetic data from games" 方向的商业化路径。

## Open Questions

- Claude Code 自动化逆向工程的边界在哪里？Originlab 需要多少人类指导？
- 这个模式是否可推广到其他 "理解已有系统" 的场景（legacy codebase migration、protocol reverse engineering）？
- 数据版权问题：从游戏中采集的数据的法律地位？

## Relevance to Us

扩展对 Claude Code 能力边界的认知。TAD 主要用 Claude Code 做 "写新代码"，而 Originlab 展示了 "理解和操纵已有系统" 的可能性。如果用户需要 legacy system integration 或 protocol reverse engineering，这是一个参考案例。
