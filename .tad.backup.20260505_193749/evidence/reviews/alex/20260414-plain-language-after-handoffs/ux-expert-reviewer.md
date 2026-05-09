# ux-expert-reviewer Review — HANDOFF-20260414-plain-language-after-handoffs.md (v1)

**Reviewed**: 2026-04-14
**Verdict**: CONDITIONAL PASS

## P0 Issues (2)

1. **P0-1**: Blake's format guidance written as "same as Alex SKILL step8" — that's a **reference, not inline content**. 同一类 bug 导致了 v2.7 quality chain failure（约束分散在多文件互相引用，最终静默漂移）。Blake 那一份必须 inline 完整 format guidance。
2. **P0-2**: Negative example 只展示"用术语" vs "不用术语"，没展示真正风险 —— **formulaic compliance**（格式正确但内容空洞）。需要替换为"hollow checkbox 通过但零信息"的反例。

## P1 Issues (4)

- P1-1: 长度该按 handoff 复杂度 scale。Express handoff 1-2 段，full TAD 4-5 段。固定 3-5 段会导致简单任务被 padding。
- P1-2: 必须显式指定**人话版在响应中放哪儿**。如果 agent 把它放结构化 message 后面，用户要滚很多行才看到。要明确"人话版 FIRST"。
- P1-3: 没有 anti-theater 机制。Mandatory + violation 只防漏写，不防写得空洞。需要："必须含 ≥1 句话如果换个任务就会是错的"（强制 task-specific）。
- P1-4: 两个 heading 都带"人话版"后缀，差异（这一步是什么 vs 我刚做了什么）藏在前缀里。

## P2 Issues

- P2-1: Audience 定义可以更具体："Someone who understands the goal (because they requested it) but has zero TAD knowledge"
- P2-2: dogfood note 保留（Blake 第一次完成必须自己用新规则）✅
- P2-3: 加 purpose anchor 让 agent 自检："如果用户读了发现哪儿不对，能问出有意义的澄清问题吗？"

## v2 Resolution
- P0-1 ✅ Blake 的 format guidance 全部 inline（不"同 Alex"）
- P0-2 ✅ negative example 换成 formulaic compliance（"已完成所有任务请验证"）
- P1-1 ✅ Length scaling 三档（express/standard/full）
- P1-2 ✅ ORDER REQUIREMENT 段：人话版 FIRST
- P1-3 ✅ Anti-theater rule 入 step 内文
- P1-4 ✅ Heading 改 `🗣️ 人话版：{differentiator}`（人话版在前，差异在后扫描清晰）
- P2-1 ✅ Audience 改"requested the goal, knows zero TAD"
- P2-3 ✅ Purpose anchor self-check 入文
