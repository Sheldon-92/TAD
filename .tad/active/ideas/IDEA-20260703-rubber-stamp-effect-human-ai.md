# IDEA: AI/人能力边界意识 — Agent 应时刻自觉判断域归属

**Date:** 2026-07-03
**Status:** captured
**Scope:** large
**Source:** AI Tinkerers #33 — HitL LLM Judges + Voice Studio 播客制作实践 + 用户洞察

---

## Context

### 学术基础 (HitL LLM Judges, Laura Dietz, UNH)

1. **Rubber Stamp Effect**: 人类验证 LLM 判断时会盲目同意（即使 LLM 错了）
2. **Preview Anchoring**: 先展示 LLM 结论会锚定人后续判断
3. 解法：人做标注（高亮段落），LLM 做规范化（转成标准格式）。各做各擅长的。

### 实践基础 (Voice Studio 播客制作)

音频剪辑的人/AI 分工已经验证：

| 层 | 谁做 | 为什么 |
|---|------|--------|
| 语义层："这句是废话要切" | AI | 文本理解 AI 擅长 |
| 粗定位："大约在 3:42" | AI | forced alignment ±200ms |
| 精确切点："左移 80ms" | **人** | 听觉感知，AI 做不到 |

配乐选曲同理：
| 维度 | 谁判 |
|------|------|
| 情绪/能量/速度 | AI（可计算） |
| 乐器联想 | AI 建议 + 人确认 |
| 风格/文化/品味 | 人（从 shortlist 挑） |

### 用户核心洞察

> AI 活在文本/数据世界，人活在感知世界。Agent 应时刻绷着一根弦：这个判断是我该做的，还是需要人来做的？

这不是一条规则（"第 3 步问人"），而是一种**持续的自我觉察**：
- "我在验证代码逻辑" → AI 域，自己判
- "我在判断方向对不对" → 人的域，该问
- "我在判断切点是否自然" → 感知域，必须人来
- "我在判断 AC 是否全绿" → AI 域，能判
- "我在判断体验是否对" → 人的域

没有万能规则，但有这根弦在，agent 就不会盲目地要么什么都自己决定，要么什么都问人。

## Summary & Problem

TAD 的 Alex/Blake 需要一种内建的**能力边界意识**：

1. **AI 判 AI 的推理质量**（代码对不对、逻辑通不通、AC 是否满足）— 让 subagent 互审
2. **人判 AI 做不了的部分**（方向对不对、体验好不好、品味选择）— 给人 shortlist 让人选择，不是给人结论让人验证
3. **避免错配**：让人验证 AI 推理 = 橡皮图章；让 AI 判断感知体验 = 切不准

当前 TAD Gate 4 的问题：问人"Blake 做得对不对？"→ 人大概率橡皮图章。
应该改为：问人**只有人能答的问题**（"这个方向是你想要的吗？用起来感觉对吗？"）

## Open Questions

- 如何在 Alex/Blake SKILL.md 中体现这根弦？是 principles.md 新条目？还是 Gate 流程改造？
- "什么需要人判断" 在不同项目中不同（Voice Studio = 感知; 代码项目 = 产品方向）— 如何让 agent 自适应判断？
- 这个意识如何与 Adaptive Complexity 结合？复杂任务更多节点需要人判断？
- 对其他用 TAD 设计的 agent（Hermes/OpenClaw）：如何让它们也内建这种边界意识？

## Relevance to Us

**TAD 方法论层面的意识原则**，横跨所有项目：
- 改善 TAD Gate 的人类环节可靠性
- 指导 Voice Studio 的人/AI 协作设计
- 成为用 TAD 设计其他 agent 时的设计原则
- 可能升级为 principles.md 条目（如果验证有效）
