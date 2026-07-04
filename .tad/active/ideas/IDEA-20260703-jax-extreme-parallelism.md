# IDEA: JAX vmap 极限并行 — 消费级硬件做 AlphaZero

**Date:** 2026-07-03
**Status:** captured
**Scope:** small
**Source:** AI Tinkerers #33 — Jaxpot (bards.ai, 34 stars, MIT)

---

## Context

Jaxpot 用 JAX 的 `vmap`/`pmap` 把数万个棋类环境同时跑在单 GPU 上，实现 1 亿步/秒的 AlphaZero 自对弈训练。Hydra config 让换模型/loss 不用改训练循环。支持 PPO、league play、imperfect-information games。

GitHub: github.com/bards-ai/Jaxpot (34 stars, v1.0.0, MIT)
CEO Michal Pogoda-Rosikoń 是 Forbes 30 Under 30。

## Summary & Problem

两个可迁移的模式：

**1. 极限并行化**: 不是在多台机器上分布式训练，而是在单 GPU 上并行化数万个环境实例。JAX 的函数式编程模型（纯函数 + vmap）让这成为可能。

**2. Hydra config 模块化**: 换网络架构、loss function、环境只需改 config，不需改代码。这是 "configuration over code" 在 ML 领域的实践。

## Open Questions

- vmap 并行化模式是否可用于 agent evaluation？同时跑数千个 agent prompt 变体并比较
- Hydra config 的模块化思想是否适合 TAD 的 capability pack 管理？
- bards.ai 的 80K monthly model downloads 说明什么市场需求？

## Relevance to Us

**直接关联 Pokémon TCG AI 项目**：当前 self_play.py / selfplay_gen.py 做自对弈训练。Jaxpot 的 JAX vmap 极限并行化可能显著加速训练——在单 GPU 上同时跑数万局对战而不是逐局跑。

需要评估：
- Pokémon TCG 环境是否能用 JAX 重写（当前可能是 Python/NumPy）
- 卡牌游戏的状态空间比围棋/象棋复杂（不定长手牌、多种效果），并行化难度可能更高
- Jaxpot 支持 imperfect-information games (Dark Hex)，TCG 也是不完全信息博弈——方向对

GitHub: github.com/bards-ai/Jaxpot (MIT, 34 stars, v1.0.0)
