# IDEA: 模仿学习 + 经典 AI 的跨域桥接模式

**Date:** 2026-07-03
**Status:** captured
**Scope:** small
**Source:** AI Tinkerers #33 — LeRobot Connect Four Robot (Tilmann Böhme, Berlin)

---

## Context

Tilmann Böhme 的 Connect Four Robot 桥接了两个 AI 域：
- **经典游戏 AI**: 计算最优列（搜索/规划）
- **模仿学习 (ACT)**: 控制机械臂物理落子（感知-执行）

系统用摄像头读取物理棋盘 → 游戏 AI 规划最优走法 → 学习到的运动策略执行物理操作。

GitHub: tilmann/lerobot (HuggingFace LeRobot fork)。上游 huggingface/lerobot ~10k stars。
关键困难：真实世界光照变化、传感器噪声。可能的下一步：用 VLA (Vision-Language-Action) 模型替代从头训练的策略。

## Summary & Problem

"两个 AI 系统各管各的擅长领域" 模式：
- 经典算法做擅长的事（搜索/规划/优化 — 确定性、可证明最优）
- 学习系统做擅长的事（感知/执行 — 处理不确定性、适应真实世界）
- 桥接层把两者连接起来

这与 "cheap loop + expensive LLM" (petri) 和 "确定性规则 > LLM" (Daria's Desk) 是同一个大主题的不同面向：**不是所有事都需要端到端 LLM**。

## Open Questions

- HuggingFace LeRobot 生态的成熟度 — 是否到了 "业余爱好者可以入门" 的阶段？
- VLA 模型（Vision-Language-Action）的 2026 进展 — 是否能替代定制策略训练？
- "unglamorous parts"（数据采集、光照适应、传感器校准）在所有机器人项目中都是主要时间消耗

## Relevance to Us

设计哲学层面的启发：TAD 的 "经典规则系统 (Gates, protocols) + LLM 判断 (agent review)" 本身就是一种跨域桥接。LeRobot 的案例强化了这个方向 — 不要试图用 LLM 替代确定性系统已经解决好的问题。
